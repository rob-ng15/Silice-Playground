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

    // Setup Memory Mapped I/O
    memmap_io IO_Map (
        //leds :> leds,
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

    // CPU <-> MEMORY CONTROLLER
    uint32  memoryAddress = uninitialized;
    uint32  memoryWriteData = uninitialized;
    uint2   memoryWriteStart = uninitialized;
    uint32  memoryReadData = uninitialized;
    uint2   memoryReadStart = uninitialized;
    uint1   memoryBusy = uninitialized;

    // RISC-ICE-V CPU
    icev CPU (
        memoryAddress :> memoryAddress,
        memoryWriteData :> memoryWriteData,
        memoryWriteStart :> memoryWriteStart,
        memoryReadData <: memoryReadData,
        memoryReadStart :> memoryReadStart,
        memoryBusy <: memoryBusy
    );

    // RAM/IO Read/Write Flags
    ram.wenable := 0;
    IO_Map.memoryWrite := 0;
    IO_Map.memoryRead := 0;

    while(1) {
        if( memoryWriteStart != 0 ) {
            leds = 8haa;
            if( memoryAddress[16,16] == 0 ) {
                // BRAM / IO_Map
                if( memoryAddress[15,1] ) {
                    // IO_Map
                    IO_Map.memoryAddress = memoryAddress[0,16];
                    IO_Map.writeData = memoryWriteData[0,16];
                    IO_Map.memoryWrite = 1;
                } else {
                    // BRAM
                    memoryBusy = 1;
                    ram.addr = memoryAddress[2,14];
                    switch( memoryWriteStart ) {
                        case 1: {
                            ++:
                            switch( memoryAddress[0,2] ) {
                                case 2b00: { ram.wdata = { ram.rdata[8,24], memoryWriteData[0,8] }; }
                                case 2b01: { ram.wdata = { ram.rdata[16,16], memoryWriteData[0,8], ram.rdata[0,8] }; }
                                case 2b10: { ram.wdata = { ram.rdata[24,8], memoryWriteData[0,8], ram.rdata[0,16] }; }
                                case 2b11: { ram.wdata = { memoryWriteData[0,8], ram.rdata[0,24] }; }
                            }
                        }
                        case 2: {
                            ++:
                            switch( memoryAddress[1,1] ) {
                                case 1b0: { ram.wdata = { ram.rdata[16,16], memoryWriteData[0,16] }; }
                                case 1b1: { ram.wdata = { memoryWriteData[0,16], ram.rdata[0,16] }; }
                            }
                        }
                        case 3: {
                            switch( memoryAddress[1,1] ) {
                                case 1b0: {
                                    // ALIGNED 32 bit write
                                    ram.wdata = memoryWriteData;
                                }
                                case 1b1: {
                                    // UNALIGNED 32 bit write
                                    // NEEDS CHECKING if correct way around
                                    ram.wdata = { ram.rdata[16,16], memoryWriteData[16,16] };
                                    ram.wenable = 1;
                                    ++:
                                    ram.addr = memoryAddress[2,14] + 1;
                                    ++:
                                    ram.wdata = { memoryWriteData[0,16], ram.rdata[0,16] };
                                }
                            }
                        }
                    }
                    ram.wenable = 1;
                    memoryBusy = 0;
                }
            } else {
                // SDRAM
                //memoryBusy = 1;
            }
        }

        if( memoryReadStart != 0 ) {
            leds = 8h55;
            if( memoryAddress[16,16] == 0 ) {
                // BRAM / IO_Map
                if( memoryAddress[15,1] ) {
                    // IO_Map
                    IO_Map.memoryAddress = memoryAddress[0,16];
                    IO_Map.memoryRead = 1;
                    memoryReadData = IO_Map.readData;
                } else {
                    // BRAM
                    memoryBusy = 1;
                    ram.addr = memoryAddress[2,14];
                    ++:
                    switch( memoryReadStart ) {
                        case 1: {
                            switch( memoryAddress[0,2] ) {
                                case 2b00: { memoryReadData = { 24b0, ram.rdata[0,8] }; }
                                case 2b01: { memoryReadData = { 24b0, ram.rdata[8,8] }; }
                                case 2b10: { memoryReadData = { 24b0, ram.rdata[16,8] }; }
                                case 2b11: { memoryReadData = { 24b0, ram.rdata[24,8] }; }
                            }
                        }
                        case 2: {
                            switch( memoryAddress[1,1] ) {
                                case 1b0: { memoryReadData = { 16b0, ram.rdata[0,16] }; }
                                case 1b1: { memoryReadData = { 16b0, ram.rdata[16,16] }; }
                            }
                        }
                        case 3: {
                            switch( memoryAddress[1,1] ) {
                                case 1b0: {
                                    // ALIGNED 32 bit read
                                    memoryReadData = ram.rdata;
                                }
                                case 1b1: {
                                    // UNALIGNED 32 bit read
                                    // NEEDS CHECKING if correct way around
                                    memoryReadData[16,16] = ram.rdata[0,16];
                                    ram.addr = memoryAddress[2,14] + 1;
                                    ++:
                                    memoryReadData[0,16] = ram.rdata[16,16];
                                }
                            }
                        }
                    }
                    memoryBusy = 0;
                }
            } else {
                // SDRAM
                //memoryBusy = 1;
            }
        }
    }
}

algorithm icev (
    output  uint32  memoryAddress,
    output  uint32  memoryWriteData,
    output  uint2   memoryWriteStart,
    input   uint32  memoryReadData,
    output  uint2   memoryReadStart,

    input   uint1   memoryBusy
) <autorun> {
    uint16  delayCounter = 0;

    uint32  pc = 0;
    uint32  newPC = uninitialized;
    uint1   pcIncrement = uninitialized;

    uint32  instruction = uninitialized;

    dualport_bram uint32 registers_1[32] = { 0, pad(0) };
    dualport_bram uint32 registers_2[32] = { 0, pad(0) };

    int32   sourceReg1 := registers_1.rdata0;
    int32   sourceReg2 := registers_1.rdata0;

    uint5   destReg := Rtype(instruction).destReg;
    int32   result = uninitialized;
    uint1   writeResult = uninitialized;

    uint32  branchAddress := pc + { {20{Btype(instruction).immediate_bits_12}}, Btype(instruction).immediate_bits_11, Btype(instruction).immediate_bits_10_5, Btype(instruction).immediate_bits_4_1, 1b0 };
    uint32  immediateValue := { {20{instruction[31,1]}}, Itype(instruction).immediate };

    // FLAGS for memory access
    memoryReadStart := 0;
    memoryWriteStart := 0;

    // REGISTERS Read/Write Flags
    registers_1.addr0 := Rtype(instruction).sourceReg1;
    registers_1.wenable0 := 0;
    registers_1.wenable1 := 1;
    registers_2.addr0 := Rtype(instruction).sourceReg1;
    registers_2.wenable0 := 0;
    registers_2.wenable1 := 1;

    while( delayCounter < 65535 ) {
        delayCounter = delayCounter + 1;
    }

    while(1) {
        // RISC-V
        writeResult = 0;
        pcIncrement = 0;

        // FETCH - 32 bit instruction
        memoryAddress = pc;
        memoryReadStart = 3;
        ++:
        ++:
        ++:
        instruction = memoryReadData;
        ++:
        // DECODE + EXECUTE
        switch( Utype(instruction).opCode ) {
            case 7b0010111: {
                // ADD UPPER IMMEDIATE TO PC
                result = { Utype(instruction).immediate_bits_31_12, 12b0 } + pc;

                writeResult = 1;
                pcIncrement = 1;
            }

            case 7b0110111: {
                // LOAD UPPER IMMEDIATE
                result = { Utype(instruction).immediate_bits_31_12, 12b0 };

                writeResult = 1;
                pcIncrement = 1;
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
                memoryAddress = immediateValue + sourceReg;
                memoryReadStart = ( Itype(instruction).function3 & 3 ) + 1;
                ++:
                ++:
                ++:
                switch( Itype(instruction).function3  ) {
                    case 3b000: { result = { {24{memoryReadData[7,1]}}, memoryReadData[0,8] }; }
                    case 3b001: { result = { {16{memoryReadData[15,1]}}, memoryReadData[0,16] }; }
                    case 3b010: { result = memoryReadData; }
                    case 3b100: { result = { 24b0, memoryReadData[0,8] }; }
                    case 3b101: { result = { 16b0, memoryReadData[0,16] }; }
                }

                writeResult = 1;
                pcIncrement = 1;
            }

            case 7b0100011: {
                // STORE
                memoryAddress = { {20{instruction[31,1]}}, Stype(instruction).immediate_bits_11_5, Stype(instruction).immediate_bits_4_0 } + sourceReg1;
                memoryWriteData = sourceReg2;
                memoryWriteStart = ( Stype(instruction).function3 & 3 ) + 1;

                pcIncrement = 1;
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
                pcIncrement = 1;
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
                pcIncrement = 1;
            }

            default: {
                pcIncrement = 1;
            }
        }

        ++:

        if( writeResult && ( destReg != 0 ) ) {
            registers_1.addr1 = destReg;
            registers_1.wdata1 = result;
            registers_2.addr1 = destReg;
            registers_2.wdata1 = result;
        }

        pc = pcIncrement ? pc + 4 : newPC;
    }
}
