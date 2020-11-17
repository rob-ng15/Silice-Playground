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
    uint5   destReg,
    uint7   opCode
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

    // RISC-V
    bram    uint32  ram[8192] = {
        $include('ROM/BIOS.inc')
        , pad(uninitialized)
    };

    uint32  pc = 0;
    uint32  newPC = uninitialized;
    uint32  instruction = uninitialized;

    int32   registers[32] = { 0, pad(0) };
    int32   sourceReg1 := registers[ Rtype(instruction).sourceReg1 ];
    int32   sourceReg2 := registers[ Rtype(instruction).sourceReg2 ];

    uint5   destReg := Rtype(instruction).destReg;
    int32   result = uninitialized;
    uint1   writeResult = uninitialized;

    uint32  branchAddress := pc + { {20{Btype(instruction).immediate_bits_12}}, Btype(instruction).immediate_bits_11, Btype(instruction).immediate_bits_10_5, Btype(instruction).immediate_bits_4_1, 1b0 };
    uint32  immediateValue := { {20{instruction[31,1]}}, Itype(instruction).immediate };

    uint32  memoryRead = uninitialized;
    uint32  memoryAddress = uninitialized;

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

    // RAM/IO Read/Write Flags
    ram.wenable := 0;
    IO_Map.memoryWrite := 0;
    IO_Map.memoryRead := 0;

    while(1) {
        // RISC-V
        writeResult = 0;

        // FETCH - 32 bit instruction
        ram.addr = pc[2,14];
        ++:
        instruction = ram.rdata;
        ++:
        // DECODE + EXECUTE
        switch( Utype(instruction).opCode ) {
            case 7b0010111: {
                // ADD UPPER IMMEDIATE TO PC
                result = { Utype(instruction).immediate_bits_31_12, 12b0 } + pc;

                writeResult = 1;
                newPC = pc + 4;
            }

            case 7b0110111: {
                // LOAD UPPER IMMEDIATE
                result = { Utype(instruction).immediate_bits_31_12, 12b0 };

                writeResult = 1;
                newPC = pc + 4;
            }

            case 7b1101111: {
                // JUMP AND LINK
                result = pc + 4;

                writeResult = 1;
                newPC = { {12{Jtype(instruction).immediate_bits_20}}, Jtype(instruction).immediate_bits_19_12, Jtype(instruction).immediate_bits_11, Jtype(instruction).immediate_bits_10_1, 1b0 } + pc;
            }

            case 7b1100111: {
                // JUMP AND LINK REGISTER
                result = pc + 4;

                writeResult = 1;
                newPC = immediateValue + sourceReg1;
            }

            case 7b1100011: {
                // BRANCH on CONDITION
                switch( Btype(instruction).function3 ) {
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
                memoryAddress = immediateValue + registers[ Itype(instruction).sourceReg1 ];
                ++:
                switch( memoryAddress[15,1] ) {
                    case 0: {
                        ram.addr = memoryAddress[2,14];
                        ++:
                        switch( Itype(instruction).function3 & 3 ) {
                            case 2b00: {
                                switch( memoryAddress[0,2] ) {
                                    case 2b00: { memoryRead = { 24b0, ram.rdata[0,8] }; }
                                    case 2b01: { memoryRead = { 24b0, ram.rdata[8,8] }; }
                                    case 2b10: { memoryRead = { 24b0, ram.rdata[16,8] }; }
                                    case 2b11: { memoryRead = { 24b0, ram.rdata[24,8] }; }
                                }
                            }
                            case 2b01: {
                                switch( memoryAddress[1,1] ) {
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
                        IO_Map.memoryAddress = memoryAddress[0,16];
                        IO_Map.memoryRead = 1;
                        memoryRead = IO_Map.readData;
                    }
                }
                ++:
                switch( Itype(instruction).function3  ) {
                    case 3b000: { result = { {24{memoryRead[7,1]}}, memoryRead[0,8] }; }
                    case 3b001: { result = { {16{memoryRead[15,1]}}, memoryRead[0,16] }; }
                    case 3b010: { result = memoryRead; }
                    case 3b100: { result = { 24b0, memoryRead[0,8] }; }
                    case 3b101: { result = { 16b0, memoryRead[0,16] }; }
                }

                writeResult = 1;
                newPC = pc + 4;
            }

            case 7b0100011: {
                // STORE
                memoryAddress = { {20{instruction[31,1]}}, Stype(instruction).immediate_bits_11_5, Stype(instruction).immediate_bits_4_0 } + sourceReg1;
                ++:
                switch( memoryAddress[15,1] ) {
                    case 1b0: {
                        ram.addr = memoryAddress[2,14];
                        ++:
                        switch( Stype(instruction).function3 & 3 ) {
                            case 2b00: {
                                switch( memoryAddress[0,2] ) {
                                    case 2b00: { ram.wdata = { ram.rdata[8,24], sourceReg2[0,8] }; }
                                    case 2b01: { ram.wdata = { ram.rdata[16,16], sourceReg2[0,8], ram.rdata[0,8] }; }
                                    case 2b10: { ram.wdata = { ram.rdata[24,8], sourceReg2[0,8], ram.rdata[0,16] }; }
                                    case 2b11: { ram.wdata = { sourceReg2[0,8], ram.rdata[0,24] }; }
                                }
                            }
                            case 2b01: {
                                switch( memoryAddress[1,1] ) {
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
                        IO_Map.memoryAddress = memoryAddress[0,16];
                        IO_Map.writeData = sourceReg2[0,16];
                        IO_Map.memoryWrite = 1;
                    }
                }

                newPC = pc + 4;
            }

            case 7b0010011: {
                // INTEGER OPERATION WITH IMMEDIATE PARAMETER
                    switch( Rtype(instruction).function7) {
                        case 7b0000000: {
                            switch( Rtype(instruction).function3 ) {
                                case 3b000: { result = sourceReg1 + immediateValue; }
                                case 3b001: { result = sourceReg1 << ItypeSHIFT( instruction ).shiftCount; }
                                case 3b010: { result = __signed( sourceReg1 ) < __signed( immediateValue ) ? 1 : 0; }
                                case 3b011: { result = __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ? 1 : 0; }
                                case 3b100: { result = sourceReg1 ^ immediateValue; }
                                case 3b101: { result = sourceReg1 >> ItypeSHIFT( instruction ).shiftCount; }
                                case 3b110: { result = sourceReg1 | immediateValue; }
                                case 3b111: { result = sourceReg1 & immediateValue; }
                            }
                        }
                        case 7b0100000: {
                            switch( Rtype(instruction).function3 ) {
                                case 3b101: { result = __signed( sourceReg1 ) >>> ItypeSHIFT( instruction ).shiftCount; }
                            }
                        }
                    }

                writeResult = 1;
                newPC = pc + 4;
            }

            case 7b0110011: {
                // INTEGER OPERATION WITH REGISTER PARAMETER
                    switch( Rtype(instruction).function7) {
                        case 7b0000000: {
                            switch( Rtype(instruction).function3 ) {
                                case 3b000: { result = sourceReg1 + sourceReg2; }
                                case 3b001: { result = sourceReg1 << sourceReg2[0,5]; }
                                case 3b010: { result = __signed( sourceReg1 ) < __signed( sourceReg2 ) ? 1 : 0; }
                                case 3b011: { result = __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ? 1 : 0; }
                                case 3b100: { result = sourceReg1 ^ sourceReg2; }
                                case 3b101: { result = sourceReg1 >> sourceReg2[0,5]; }
                                case 3b110: { result = sourceReg1 | sourceReg2; }
                                case 3b111: { result = sourceReg1 & sourceReg2; }
                            }
                        }
                        case 7b0100000: {
                            switch( Rtype(instruction).function3 ) {
                                case 3b000: { result = sourceReg1 - sourceReg2; }
                                case 3b101: { result = __signed( sourceReg1 ) >>> sourceReg2[0,5]; }
                            }
                        }
                    }

                writeResult = 1;
                newPC = pc + 4;
            }

            default: {
                newPC = pc + 4;
            }
        }

        ++:

        if( writeResult && ( destReg != 0 ) ) {
            registers[ destReg ] = result;
        }

        pc = newPC;
    } // RISC-V
}
