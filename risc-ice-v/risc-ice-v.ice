// RISC-ICE-V
// inspired by https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice
//
// A simple Risc-V RV32I processor

// RISC-V INSTRUCTION BITFIELDS
bitfield    Btype {
    uint1   immediate_bits_12,
    uint6   immediate_bits_10_5,
    uint5   sourceReg2,
    uint5   sourceReg1,
    uint3   function3,
    uint4   immediate_bits_4_1,
    uint1   immediate_bits_11,
    uint7   opcode
}

bitfield    Itype {
    uint12  immediate,
    uint5   sourceReg1,
    uint3   function3,
    uint5   destReg,
    uint7   opcode
}

bitfield    ItypeSHIFT {
    uint7   function7,
    uint5   shiftCount,
    uint5   sourceReg1,
    uint3   function3,
    uint5   destReg,
    uint7   opcode
}

bitfield    Jtype {
    uint1   immediate_bits_20,
    uint10  immediate_bits_10_1,
    uint1   immediate_bits_11,
    uint8   immediate_bits_19_12,
    uint5   destReg,
    uint7   opcode
}

bitfield    Rtype {
    uint7   function7,
    uint5   sourceReg2,
    uint5   sourceReg1,
    uint3   function3,
    uint5   destReg,
    uint7   opCode
}

bitfield Stype {
    uint7  immediate_bits_11_5,
    uint5  sourceReg2,
    uint5  sourceReg1,
    uint3  function3,
    uint5  immediate_bits_4_0,
    uint7  opcode
}

bitfield Utype {
    uint20 immediate_bits_31_12,
    uint5  destReg,
    uint7  opCode
}

algorithm main(
    // LEDS (8 of)
    output  uint8   leds,
    input   uint$NUM_BTNS$ btns,

    // HDMI OUTPUT
    output  uint4   gpdi_dp,
    output  uint4   gpdi_dn,

    // UART
    output! uint1   uart_tx,
    input   uint1   uart_rx,

    // AUDIO
    output! uint4   audio_l,
    output! uint4   audio_r

) {
    // VGA/HDMI Display
    uint1   video_reset = uninitialized;
    uint1   video_clock = uninitialized;
    uint1   pll_lock = uninitialized;

    // Generate the 100MHz SDRAM and 25MHz VIDEO clocks
    uint1 clock_50mhz = uninitialized;
    ulx3s_clk_50_25 clk_gen (
        clkin    <: clock,
        clkout0  :> clock_50mhz,
        clkout1  :> video_clock,
        locked   :> pll_lock
    );

    // Video Reset
    reset_conditioner vga_rstcond (
        rcclk <: video_clock ,
        in  <: reset,
        out :> video_reset
    );

    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1   vblank = uninitialized;
    uint1   pix_active = uninitialized;
    uint10  pix_x  = uninitialized;
    uint10  pix_y  = uninitialized;

    // VGA or HDMI driver
    uint8   video_r = uninitialized;
    uint8   video_g = uninitialized;
    uint8   video_b = uninitialized;

    hdmi video<@clock,!reset> (
        vblank  :> vblank,
        active  :> pix_active,
        x       :> pix_x,
        y       :> pix_y,
        gpdi_dp :> gpdi_dp,
        gpdi_dn :> gpdi_dn,
        red     <: video_r,
        green   <: video_g,
        blue    <: video_b
    );

    // RISC-V RAM and BIOS
    bram uint32 ram[8192] = {
        $include('ROM/BIOS.inc')
        , pad(uninitialized)
    };

    // RISC-V REGISTERS
    dualport_bram int32 registers_1[32] = { 0, pad(0) };
    dualport_bram int32 registers_2[32] = { 0, pad(0) };

    // RISC-V PROGRAM COUNTER
    uint32  pc = 0;
    uint32  newPC = uninitialized;
    uint1   pcIncrement = uninitialized;

    // RISC-V INSTRUCTION and DECODE
    uint32  instruction = uninitialized;
    uint7   opCode := Utype(instruction).opCode;
    uint3   function3 := Rtype(instruction).function3;
    uint7   function7 := Rtype(instruction).function7;

    // RISC-V SOURCE REGISTER VALUES and IMMEDIATE VALUE and DESTINATION REGISTER ADDRESS
    int32   sourceReg1 := registers_1.rdata0;
    int32   sourceReg2 := registers_2.rdata0;
    uint32  immediateValue := { {20{instruction[31,1]}}, Itype(instruction).immediate };
    uint5   destReg := Rtype(instruction).destReg;

    // RISC-V ALU RESULTS
    int32   result = uninitialized;
    int32   Uresult := { Utype(instruction).immediate_bits_31_12, 12b0 };
    uint1   writeResult = uninitialized;

    // RISC-V ADDRESS CALCULATIONS
    int32   jumpAddress := { {12{Jtype(instruction).immediate_bits_20}}, Jtype(instruction).immediate_bits_19_12, Jtype(instruction).immediate_bits_11, Jtype(instruction).immediate_bits_10_1, 1b0 } + pc;
    int32   branchAddress := pc + { {20{Btype(instruction).immediate_bits_12}}, Btype(instruction).immediate_bits_11, Btype(instruction).immediate_bits_10_5, Btype(instruction).immediate_bits_4_1, 1b0 };
    int32   loadAddress := immediateValue + sourceReg1;
    int32   storeAddress := { {20{instruction[31,1]}}, Stype(instruction).immediate_bits_11_5, Stype(instruction).immediate_bits_4_0 } + sourceReg1;

    // RETRIEVE FROM MEMORY
    uint32  memoryRead = uninitialized;

    // Setup Memory Mapped I/O
    memmap_io IO_Map (
        leds :> leds,
        btns <: btns,

        // UART
        uart_tx :> uart_tx,
        uart_rx <: uart_rx,

        // AUDIO
        audio_l :> audio_l,
        audio_r :> audio_r,

        // VGA/HDMI
        video_r :> video_r,
        video_g :> video_g,
        video_b :> video_b,
        vblank <: vblank,
        pix_active <: pix_active,
        pix_x <: pix_x,
        pix_y <: pix_y,

        // CLOCKS
        video_clock <:video_clock,
        video_reset <: video_reset
    );

    // MULTIPLICATION and DIVISION units
    divideremainder dividerunit ();
    multiplicationDSP multiplicationuint ();

    // RAM/IO Read/Write Flags
    ram.wenable := 0;
    IO_Map.memoryWrite := 0;
    IO_Map.memoryRead := 0;

    // REGISTER Read/Write Flags
    registers_1.addr0 := Rtype(instruction).sourceReg1;
    registers_1.wenable0 := 0;
    registers_1.wenable1 := 1;
    registers_2.addr0 := Rtype(instruction).sourceReg2;
    registers_2.wenable0 := 0;
    registers_2.wenable1 := 1;

    registers_1.addr1 = 0; registers_1.wdata1 = 0;
    registers_2.addr1 = 0; registers_2.wdata1 = 0;

    ram.addr = pc[2,14];
    ++:

    while(1) {
        // RISC-V
        writeResult = 0;
        pcIncrement = 0;

        // FETCH - 32 bit instruction
        ram.addr = pc[2,14];
        ++:
        instruction = ram.rdata;
        ++:
        ++:

        // DECODE + EXECUTE
        switch( opCode ) {
            case 7b0010111: {
                // ADD UPPER IMMEDIATE TO PC
                result = Uresult + pc;

                writeResult = 1;
                pcIncrement = 1;
            }

            case 7b0110111: {
                // LOAD UPPER IMMEDIATE
                result = Uresult;

                writeResult = 1;
                pcIncrement = 1;
            }

            case 7b1101111: {
                // JUMP AND LINK
                result = pc + 4;

                writeResult = 1;
                newPC = jumpAddress;
            }

            case 7b1100111: {
                // JUMP AND LINK REGISTER
                result = pc + 4;

                writeResult = 1;
                newPC = loadAddress;
            }

            case 7b1100011: {
                // BRANCH on CONDITION
                switch( function3 ) {
                    case 3b000: { newPC = ( sourceReg1 == sourceReg2 ) ? branchAddress : pc + 4; }
                    case 3b001: { newPC = ( sourceReg1 != sourceReg2 ) ? branchAddress : pc + 4; }
                    case 3b100: { newPC = ( __signed(sourceReg1) < __signed(sourceReg2) ) ? branchAddress : pc + 4; }
                    case 3b101: { newPC = ( __signed(sourceReg1) >= __signed(sourceReg2) )  ? branchAddress : pc + 4; }
                    case 3b110: { newPC = ( __unsigned(sourceReg1) < __unsigned(sourceReg2) ) ? branchAddress : pc + 4; }
                    case 3b111: { newPC = ( __unsigned(sourceReg1) >= __unsigned(sourceReg2) ) ? branchAddress : pc + 4; }
                    default: { newPC = pc + 4; }
                }
            }

            case 7b0000011: {
                // LOAD execute even if rd == 0 as may be discarding values in a buffer
                switch( loadAddress[15,1] ) {
                    case 0: {
                        ram.addr = loadAddress[2,14];
                        ++:
                        switch( function3 & 3 ) {
                            case 2b00: {
                                switch( loadAddress[0,2] ) {
                                    case 2b00: { memoryRead = { 24b0, ram.rdata[0,8] }; }
                                    case 2b01: { memoryRead = { 24b0, ram.rdata[8,8] }; }
                                    case 2b10: { memoryRead = { 24b0, ram.rdata[16,8] }; }
                                    case 2b11: { memoryRead = { 24b0, ram.rdata[24,8] }; }
                                }
                            }
                            case 2b01: {
                                switch( loadAddress[1,1] ) {
                                    case 1b0: { memoryRead = { 16b0, ram.rdata[0,16] }; }
                                    case 1b1: { memoryRead = { 16b0, ram.rdata[16,16] }; }
                                }
                            }
                            case 2b10: {
                                memoryRead = ram.rdata;
                            }
                        }
                    }

                    case 1: {
                        IO_Map.memoryAddress = loadAddress[0,16];
                        IO_Map.memoryRead = 1;
                        memoryRead = IO_Map.readData;
                    }
                }
                ++:
                switch( function3  ) {
                    case 3b000: { result = { {24{memoryRead[7,1]}}, memoryRead[0,8] }; }
                    case 3b001: { result = { {16{memoryRead[15,1]}}, memoryRead[0,16] }; }
                    case 3b010: { result = memoryRead; }
                    case 3b100: { result = { 24b0, memoryRead[0,8] }; }
                    case 3b101: { result = { 16b0, memoryRead[0,16] }; }
                }

                writeResult = 1;
                pcIncrement = 1;
            }

            case 7b0100011: {
                // STORE
                switch( storeAddress[15,1] ) {
                    case 1b0: {
                        ram.addr = storeAddress[2,14];
                        ++:
                        switch( function3 & 3 ) {
                            case 2b00: {
                                switch( storeAddress[0,2] ) {
                                    case 2b00: { ram.wdata = { ram.rdata[8,24], sourceReg2[0,8] }; }
                                    case 2b01: { ram.wdata = { ram.rdata[16,16], sourceReg2[0,8], ram.rdata[0,8] }; }
                                    case 2b10: { ram.wdata = { ram.rdata[24,8], sourceReg2[0,8], ram.rdata[0,16] }; }
                                    case 2b11: { ram.wdata = { sourceReg2[0,8], ram.rdata[0,24] }; }
                                }
                            }
                            case 2b01: {
                                switch( storeAddress[1,1] ) {
                                    case 1b0: { ram.wdata = { ram.rdata[16,16], sourceReg2[0,16] }; }
                                    case 1b1: { ram.wdata = { sourceReg2[0,16], ram.rdata[0,16] }; }
                                }
                            }
                            case 2b10: {
                                ram.wdata = sourceReg2;
                            }
                        }
                        ram.wenable = 1;
                    }
                    case 1b1: {
                        IO_Map.memoryAddress = storeAddress[0,16];
                        IO_Map.writeData = sourceReg2[0,16];
                        IO_Map.memoryWrite = 1;
                    }
                }

                pcIncrement = 1;
            }

            case 7b0010011: {
                // INTEGER OPERATION WITH IMMEDIATE PARAMETER
                switch( function3 ) {
                    case 3b000: { result = sourceReg1 + immediateValue; }
                    case 3b001: { result = sourceReg1 << ItypeSHIFT( instruction ).shiftCount; }
                    case 3b010: { result = __signed( sourceReg1 ) < __signed( immediateValue ) ? 32b1 : 32b0; }
                    case 3b011: {
                        if( immediateValue == 1 ) {
                            // SLTIU rd, rs1, 1 ( equivalent to SEQZ rd, rs )
                            result = ( sourceReg1 == 0 ) ? 32b1 : 0;
                        } else {
                            result = __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ? 32b1 : 32b0;
                        }
                    }
                    case 3b100: { result = sourceReg1 ^ immediateValue; }
                    case 3b101: {
                        if( function7[5,1] == 0 ) {
                            result = sourceReg1 >> ItypeSHIFT( instruction ).shiftCount;
                        } else {
                            result = __signed(sourceReg1) >>> ItypeSHIFT( instruction ).shiftCount;
                            //result = { {32{sourceReg1[31,1]}}, sourceReg1 } >> ItypeSHIFT( instruction ).shiftCount;
                        }
                    }
                    case 3b110: { result = sourceReg1 | immediateValue; }
                    case 3b111: { result = sourceReg1 & immediateValue; }
                }

                writeResult = 1;
                pcIncrement = 1;

            }

            case 7b0110011: {
                // INTEGER OPERATION WITH REGISTER PARAMETER
                switch( { function7[5,1] , function7[0,1] } ) {
                    case 2b00: {
                        switch( function3 ) {
                            case 3b000: { result = sourceReg1 + sourceReg2; }
                            case 3b001: { result = sourceReg1 << sourceReg2[0,5]; }
                            case 3b010: { result = __signed( sourceReg1 ) < __signed( sourceReg2 ) ? 1 : 0; }
                            case 3b011: {
                                if( Rtype(instruction).sourceReg1 == 0 ) {
                                    // SLTU rd, x0, rs2 ( equivalent to SNEZ rd, rs )
                                    result = ( sourceReg2 != 0 ) ? 32b1 : 32b0;
                                } else {
                                    result = __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ? 1 : 0;
                                }
                            }
                            case 3b100: { result = sourceReg1 ^ sourceReg2; }
                            case 3b101: { result = sourceReg1 >> sourceReg2[0,5]; }
                            case 3b110: { result = sourceReg1 | sourceReg2; }
                            case 3b111: { result = sourceReg1 & sourceReg2; }
                        }
                    }

                    case 2b10: {
                        switch( function3 ) {
                            case 3b000: { result = sourceReg1 - sourceReg2; }
                            case 3b101: {
                                //result = { {32{sourceReg1[31,1]}}, sourceReg1 } >> sourceReg2[0,5];
                                result = __signed(sourceReg1) >>> sourceReg2[0,5];
                            }
                        }
                    }

                    case 2b01: {
                        // MULTIPLY / DIVIDE extension decoding
                        switch( function3[2,1] ) {
                            case 1b0: {
                                // MULTIPLICATION
                                multiplicationuint.factor_1 = sourceReg1;
                                multiplicationuint.factor_2 = sourceReg2;

                                multiplicationuint.dosigned = ( function3[1,1] == 0 ) ? 1 : ( ( function3[0,1] == 0 ) ? 2 : 0 );

                                () <- multiplicationuint <- ();

                                result = ( function3 == 0 ) ? multiplicationuint.product[0,32] : multiplicationuint.product[32,32];
                            }
                            case 1b1: {
                                // DIVISION / REMAINDER
                                dividerunit.dividend = sourceReg1;
                                dividerunit.divisor = sourceReg2;

                                dividerunit.dosigned = ~function3[0,1];

                                () <- dividerunit <- ();

                                result = function3[1,1] ? dividerunit.remainder : dividerunit.quotient;
                            }
                        }
                    }
                }

                writeResult = 1;
                pcIncrement = 1;
            }

            default: {
                // NOP or ILLEGAL INSTRUCTION
                pcIncrement = 1;
            }
        }

        ++:

        // NEVER write to registers[0]
        if( writeResult && ( destReg != 0 ) ) {
            registers_1.addr1 = destReg;
            registers_1.wdata1 = result;
            registers_2.addr1 = destReg;
            registers_2.wdata1 = result;
        }

        pc = pcIncrement ? pc + 4 : newPC;
    } // RISC-V
}
