        switch( { opCode[6,1], opCode[4,1] } ) {
            case 2b00: {
                // LOAD STORE
                switch( opCode[5,1] ) {
                    case 1b0: {
                        // LOAD executes even if rd == 0 as may be discarding values in a buffer
                        writeRegister = 1;
                        if( ~loadAddress[28,1] && loadAddress[15,1] ) {
                            // I/O
                            IO_Map.memoryAddress = loadAddress[0,16];
                            IO_Map.memoryRead = 1;
                            switch( function3 & 3 ) {
                                case 2b10: { result = IO_Map.readData; }
                                default: { result = ( ( function3 & 3 ) == 0 ) ? IO_Map.readData8 : IO_Map.readData16; }
                            }
                        } else {
                            // SDRAM or BRAM ( mark as using data cache )
                            ram.address = loadAddress;
                            ram.Icache = 0;
                            ram.readflag = 1;
                            while( ram.busy ) {}
                            switch( function3 & 3 ) {
                                case 2b10: {
                                    // 32 bit READ as 2 x 16 bit
                                    combiner161632unit.LOW = ram.readdata;
                                    ram.address = loadAddressPLUS2;
                                    ram.readflag = 1;
                                    while( ram.busy ) {}
                                    combiner161632unit.HIGH = ram.readdata;
                                    result = combiner161632unit.HIGHLOW;
                                }
                                default: {
                                    // 8/16 bit with optional sign extension
                                    result = ( ( function3 & 3 ) == 0 ) ? ram.readdata8 : ram.readdata16;
                                }
                            }
                        }
                    }
                    case 1b1: {
                        // STORE
                        if( ~storeAddress[28,1] && storeAddress[15,1] ) {
                            // I/O ALWAYS 16 bit WRITES
                            IO_Map.memoryAddress = storeAddress[0,16];
                            IO_Map.writeData = __unsigned( sourceReg2[0,16] );
                            IO_Map.memoryWrite = 1;
                        } else {
                            // SDRAM or BRAM
                            ram.address = storeAddress;
                            ram.Icache = 0;
                            // 8 bit, READ then WRITE, 16 bit just WRITE, 32 bit just WRITE LOWER 16 bits
                            if( ( function3 & 3 ) == 0 ) {
                                ram.readflag = 1;
                                while( ram.busy ) {}
                            }
                            ram.writedata = sourceReg2[0,16];
                            ram.writeflag = 1;
                            // 32 bit, WRITE UPPER 16 bits
                            if(  ( function3 & 3 ) == 2b10 ) {
                                while( ram.busy ) {}
                                ram.address = storeAddressPLUS2;
                                ram.writedata = sourceReg2[16,16];
                                ram.writeflag = 1;
                            }
                        }
                    }
                }
            }

            // AUIPC LUI ALUI ALUR
            case 2b01: {
                writeRegister = 1;

                switch( opCode[2,1] ) {
                    // ALU BASE & M EXTENSION
                    case 1b0: {
                        if( opCode[5,1] && function7[0,1] ) {
                            // START DIVISION / MULTIPLICATION
                            ALU.start = 1;
                            while( ALU.busy ) {}
                        }
                        result = ( opCode[5,1] && function7[0,1] ) ? ALU.Mresult : ALU.result;
                    }
                    // AUIPC LUI
                    case 1b1: { result = AUIPCLUI; }
                }
            }

            case 2b10: {
                // JUMP BRANCH
                switch( opCode[2,1] ) {
                    // BRANCH on CONDITION
                    case 1b0: { takeBranch = branchcomparisonunit.takeBranch; }
                    // JUMP AND LINK / JUMP AND LINK REGISTER
                    case 1b1: { writeRegister = 1; incPC = 0; result = nextPC; }
                }
            }

            // FORCE registers to BRAM - NO FLOATING POINT AT PRESENT!
            default: { floatingpoint = 1; }
        }
