switch( FSM ) {
    // FETCH + EXPANSION OF COMPRESSED INSTRUCTIONS
    case 0: {
        // READ 16 bits of instruction
        switch( ram.rdata[0,2] ) {
            // DECODE COMPRESSED / STORE 16 bits of 32 bit instruction
            case 2b00: {
                compressed = 1; newPC = pc + 2;
                FSM = 2;
            }
            case 2b01: {
                compressed = 1; newPC = pc + 2;
                FSM = 2;
            }
            case 2b10: {
                compressed = 1; newPC = pc + 2;
                FSM = 2;
            }
            case 2b11: {
                // 32 bit instruction
                compressed = 0;
                instruction = { 16b0, ram.rdata };
                ram.addr = pc[1,15] + 1;
                newPC = pc + 4;
                FSM = 1;
            }
        }
    }
    case 1: {
        // READ 2nd 16 bits of 32 bit instruction
        instruction = { ram.rdata, instruction[0,16] };
        FSM = 2;
    }

    // PARTIAL DECODE
    case 2: {
        switch( { opCode[6,1], opCode[4,1] } ) {
            case 2b00: {
                // LOAD / STORE
                switch( opCode[5,1] ) {
                    case 1b0: {
                        // LOAD
                        FSM = 4;
                    }
                    case 1b1: {
                        // STORE
                        FSM = 7;
                    }
                }
            }
            case 2b01: {
                // ALU -> AUIPC LUI ALUI ALUR
                FSM = 10;
            }
            case 2b10: {
                // JUMP BRANCH
                FSM  = 3;
            }
        }
    }

    // INSTRUCTION FULLY DECODED - REGISTERS FETCHED, ADDRESSES CALCULATED

    // EXECUTE JUMP / BRANCH
    case 3: {
        // JUMP BRANCH
        switch( opCode[2,1] ) {
            case 1b0: {
                // BRANCH on CONDITION
                writeRegister = 0;
                switch( function3 ) {
                    case 3b000: { takeBranch = ( sourceReg1 == sourceReg2 ) ? 1 : 0; }
                    case 3b001: { takeBranch = ( sourceReg1 != sourceReg2 ) ? 1 : 0; }
                    case 3b100: { takeBranch = ( __signed(sourceReg1) < __signed(sourceReg2) ) ? 1 : 0; }
                    case 3b101: { takeBranch = ( __signed(sourceReg1) >= __signed(sourceReg2) )  ? 1 : 0; }
                    case 3b110: { takeBranch = ( __unsigned(sourceReg1) < __unsigned(sourceReg2) ) ? 1 : 0; }
                    case 3b111: { takeBranch = ( __unsigned(sourceReg1) >= __unsigned(sourceReg2) ) ? 1 : 0; }
                }
            }
            case 1b1: {
                // JUMP AND LINK / JUMP AND LINK REGISTER
                result = pc + ( compressed ? 2 : 4 );
                newPC = ( opCode[3,1] == 1 ) ?
                            { {12{Jtype(instruction).immediate_bits_20}}, Jtype(instruction).immediate_bits_19_12, Jtype(instruction).immediate_bits_11, Jtype(instruction).immediate_bits_10_1, 1b0 } + pc :
                            loadAddress;
            }
        }
        FSM = 14;
    }

    // LOAD UNIT
    case 4: {
        // I/O or BRAM
        switch( loadAddress[15,1] ) {
            case 0: {
                // SET BRAM ADDRESS
                ram.addr = loadAddress[1,15];
                FSM = 5;
            }
            case 1: {
                // I/O READ
                IO_Map.memoryAddress = loadAddress[0,16];
                IO_Map.memoryRead = 1;
                switch( function3 & 3 ) {
                    case 2b00: { result = { {24{IO_Map.readData[7,1] & ~function3[2,1]}}, IO_Map.readData[0,8] }; }
                    case 2b01: { result = { {16{IO_Map.readData[15,1] & ~function3[2,1]}}, IO_Map.readData }; }
                    case 2b10: { result = IO_Map.readData; }
                }
                FSM = 14;
            }
        }
    }
    case 5: {
        // COMPLETE 8/16 bit, START 32 bit
        switch( function3 & 3 ) {
            case 2b00: {
                switch( loadAddress[0,1] ) {
                    case 1b0: { result = { {24{ram.rdata[7,1] & ~function3[2,1]}}, ram.rdata[0,8] }; }
                    case 1b1: { result = { {24{ram.rdata[15,1] & ~function3[2,1]}}, ram.rdata[8,8] }; }
                }
                FSM = 14;
            }
            case 2b01: {
                result =  { {16{ram.rdata[15,1] & ~function3[2,1]}}, ram.rdata[0,16] };
                FSM = 14;
            }
            case 2b10: {
                result = { 16b0, ram.rdata };
                ram.addr = loadAddress[1,15] + 1;
                FSM = 6;
            }
        }
    }
    case 6: {
        // COMPLETE 32 bit
        result = { ram.rdata, result[0,16] };
        FSM = 14;
    }

    // STORE UNIT
    case 7: {
        // I/O or BRAM
        writeRegister = 0;
        switch( storeAddress[15,1] ) {
            case 1b0: {
                // BRAM START 8 bit and 32 bit STORE, COMPLETE 16 bit STORE
                ram.addr = storeAddress[1,15];
                switch( function3 & 3 ) {
                    case 2b00: {
                        // 8 BIT STORE
                        FSM = 8;
                    }
                    case 2b01: {
                        // 16 BIT STORE
                        ram.wdata = sourceReg2[0,16];
                        ram.wenable = 1;
                        FSM = 14;
                    }
                    case 2b10: {
                        // 32 BIT STORE
                        ram.wdata = sourceReg2[0,16];
                        ram.wenable = 1;
                        FSM = 9;
                    }
            }
            case 1b1: {
                // I/O WRITE
                IO_Map.memoryAddress = storeAddress[0,16];
                IO_Map.writeData = sourceReg2[0,16];
                IO_Map.memoryWrite = 1;
                FSM = 14;
            }
        }
    }
    case 8: {
        // COMPLETE 8 BIT STORE
        switch( storeAddress[0,1] ) {
            case 1b0: { ram.wdata = { ram.rdata[8,8], sourceReg2[0,8] }; }
            case 1b1: { ram.wdata = { sourceReg2[0,8], ram.rdata[0,8] }; }
        }
        ram.wenable = 1;
        FSM = 14;
    }
    case 9: {
        // COMPLETE 32 BIT STORE
        ram.addr = storeAddress[1,15] + 1;
        ram.wdata = sourceReg2[16,16];
        ram.wenable = 1;
        FSM = 14;
    }

    // ALU
    case 10: {
        // AUIPC LUI ALUI ALUR
        switch( opCode[2,1] ) {
            case 1b0: {
                if( ( opCode[5,1] == 1 ) && ( function7[0,1] == 1 ) ) {
                    // M EXTENSION
                    switch( function3[2,1] ) {
                        case 1b0: {
                            // MULTIPLICATION
                            multiplicationuint.dosigned = ( function3[1,1] == 0 ) ? 1 : ( ( function3[0,1] == 0 ) ? 2 : 0 );
                            multiplicationuint.start = 1;
                            FSM = 11;
                        }
                        case 1b1: {
                            // DIVISION / REMAINDER
                            dividerunit.dosigned = ~function3[0,1];
                            dividerunit.start = 1;
                            FSM = 12;
                        }
                    }
                } else {
                    // I ALU OPERATIONS
                    switch( function3 ) {
                        case 3b000: {
                            if( ( opCode[5,1] == 1 ) && ( function7[5,1] == 1 ) ) {
                                result =sourceReg1 - sourceReg2;
                            } else {
                                result = sourceReg1 + ( ( opCode[5,1] == 1 ) ? sourceReg2 : immediateValue ); }
                            }
                        case 3b001: { result = sourceReg1 << ( ( opCode[5,1] == 1 ) ? sourceReg2[0,5] : ItypeSHIFT( instruction ).shiftCount ); }
                        case 3b010: { result = __signed( sourceReg1 ) < ( ( opCode[5,1] == 1 ) ? __signed(sourceReg2) : __signed(immediateValue) ) ? 32b1 : 32b0; }
                        case 3b011: {
                            switch( opCode[5,1] ) {
                                case 1b0: {
                                    if( immediateValue == 1 ) {
                                        result = ( sourceReg1 == 0 ) ? 32b1 : 32b0;
                                    } else {
                                        result = ( __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ) ? 32b1 : 32b0;
                                    }
                                }
                                case 1b1: {
                                    if( Rtype(instruction).sourceReg1 == 0 ) {
                                        result = ( sourceReg2 != 0 ) ? 32b1 : 32b0;
                                    } else {
                                        result = ( __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ) ? 32b1 : 32b0;
                                    }
                                }
                            }
                        }
                        case 3b100: { result = sourceReg1 ^ ( ( opCode[5,1] == 1 ) ? sourceReg2 : immediateValue ); }
                        case 3b101: {
                            switch( function7[5,1] ) {
                                case 1b0: {
                                    result = __signed(sourceReg1) >>> ( ( opCode[5,1] == 1 ) ? sourceReg2[0,5] : ItypeSHIFT( instruction ).shiftCount );
                                }
                                case 1b1: {
                                    result = sourceReg1 >> ( ( opCode[5,1] == 1 ) ? sourceReg2[0,5] : ItypeSHIFT( instruction ).shiftCount );
                                }
                            }
                        }
                        case 3b110: { result = sourceReg1 | ( ( opCode[5,1] == 1 ) ? sourceReg2 : immediateValue ); }
                        case 3b111: { result = sourceReg1 & ( ( opCode[5,1] == 1 ) ? sourceReg2 : immediateValue ); }
                    }
                     FSM = 14;
                }
            }
            case 1b1: {
                // AUIPC LUI
                result = { Utype(instruction).immediate_bits_31_12, 12b0 } + ( ( opCode[5,1] == 0 ) ? pc : 0 );
                FSM = 14;
            }
        }
    }
    case 11: {
        // WAIT FOR MULTIPLICATION UNIT
        result = ( function3 == 0 ) ? multiplicationuint.product[0,32] : multiplicationuint.product[32,32];
        FSM = multiplicationuint.active ? 11 : 14;
    }
    case 12: {
    // WAIT FOR DIVIDER UNIT
        result = function3[1,1] ? dividerunit.remainder : dividerunit.quotient;
        FSM = dividerunit.active ? 12 : 14;
    }

    // COMMIT
    case 14: {
        // NEVER write to registers[0]
        if( writeRegister && ( Rtype(instruction).destReg != 0 ) ) {
            registers_1.addr1 = Rtype(instruction).destReg + ( floatingpoint ? 32 : 0 );
            registers_1.wdata1 = result;
            registers_2.addr1 = Rtype(instruction).destReg + ( floatingpoint ? 32 : 0 );
            registers_2.wdata1 = result;
        }

        pc = takeBranch ? pc + branchOffset : newPC;
        FSM = 15;
    }

    // SET ADDRESS FOR FETCH + RESET INSTRUCTION STATE
    case 15: {
        ram.addr = pc[1,15];

        writeRegister = 1; takeBranch = 0;
        floatingpoint = 0;

        FSM = 0;
    }
}
