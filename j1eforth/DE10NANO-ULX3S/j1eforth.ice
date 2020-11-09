// BITFIELDS to help with bit/field access

// Instruction is 3 bits 1xx = literal value, 000 = branch, 001 = 0branch, 010 = call, 011 = alu, followed by 13 bits of instruction specific data
bitfield instruction {
    uint3   is_litcallbranchalu,
    uint13   padding
}

// A literal instruction is 1 followed by a 15 bit UNSIGNED literal value
bitfield literal {
    uint1   is_literal,
    uint15  literalvalue
}

// A branch, 0branch or call instruction is 0 followed by 00 = branch, 01 = 0branch, 10 = call followed by 13bit target address
bitfield callbranch {
    uint1   is_literal,
    uint2   is_callbranchalu,
    uint13  address
}
// An alu instruction is 0 (not literal) followed by 11 = alu
bitfield aluop {
    uint1   is_literal,
    uint2   is_callbranchalu,
    uint1   is_r2pc,                // return from subroutine
    uint4   operation,              // arithmetic / memory read/write operation to perform
    uint1   is_t2n,                 // top to next in stack
    uint1   is_t2r,                 // top to return stack
    uint1   is_n2memt,              // write to memory
    uint1   is_j1j1plus,            // Original J1 or extra J1+ alu operations
    uint1   rdelta1,                // two's complement adjustment for rsp
    uint1   rdelta0,
    uint1   ddelta1,                // two's complement adjustment for dsp
    uint1   ddelta0
}

algorithm main(
    // LEDS (8 of)
    output  uint8   leds,
    input   uint$NUM_BTNS$ btns,

$$if ULX3S then
    output  uint4   gpdi_dp,
    output  uint4   gpdi_dn,
$$end
$$if DE10NANO then
    // VGA
    output! uint6   video_r,
    output! uint6   video_g,
    output! uint6   video_b,
    output! uint1   video_hs,
    output! uint1   video_vs,
$$end

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
$$if DE10NANO then
    uint1 sdram_clock = uninitialized;
    de10nano_clk_100_25 clk_gen (
        refclk    <: clock,
        outclk_0  :> sdram_clock,
        outclk_1  :> video_clock,
        locked    :> pll_lock,
        rst       <: reset
    );
$$end
$$if ULX3S then
    uint1 clock_50mhz = uninitialized;
    ulx3s_clk_50_25 clk_gen (
        clkin    <: clock,
        clkout0  :> clock_50mhz,
        clkout1  :> video_clock,
        locked   :> pll_lock
    );
$$end

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
$$if DE10NANO then
    vga vga_driver <@video_clock,!video_reset> (
        vga_hs :> video_hs,
        vga_vs :> video_vs,
        vblank :> vblank,
        active :> pix_active,
        vga_x  :> pix_x,
        vga_y  :> pix_y
    );
$$end

$$if ULX3S then
    // Adjust 6 bit rgb to 8 bit rgb for HDMI output
    uint6   video_r = 0;
    uint6   video_g = 0;
    uint6   video_b = 0;

    uint8   video_r8 := { video_r, video_r[0,2] };
    uint8   video_g8 := { video_g, video_g[0,2] };
    uint8   video_b8 := { video_b, video_b[0,2] };

    hdmi video<@clock,!reset> (
        vblank  :> vblank,
        active  :> pix_active,
        x       :> pix_x,
        y       :> pix_y,
        gpdi_dp :> gpdi_dp,
        gpdi_dn :> gpdi_dn,
        red     <: video_r8,
        green   <: video_g8,
        blue    <: video_b8
    );
$$end

    // UART tx and rx
    // UART written in Silice by @sylefeb https://github.com/sylefeb/Silice
    uart_out uo;
    uart_sender usend <@clock,!reset> (
        io      <:> uo,
        uart_tx :>  uart_tx
    );
    uart_in ui;
    uart_receiver urecv <@clock,!reset> (
        io      <:> ui,
        uart_rx <:  uart_rx
    );

    // J1+ CPU
    // instruction being executed, plus decoding, including 5bit deltas for dsp and rsp expanded from 2bit encoded in the alu instruction
    uint16  instruction = uninitialized;
    uint16  immediate := ( literal(instruction).literalvalue );
    uint1   is_alu := ( instruction(instruction).is_litcallbranchalu == 3b011 );
    uint1   is_call := ( instruction(instruction).is_litcallbranchalu == 3b010 );
    uint1   is_lit := literal(instruction).is_literal;
    uint1   dstackWrite := ( is_lit | (is_alu & aluop(instruction).is_t2n) );
    uint1   rstackWrite := ( is_call | (is_alu & aluop(instruction).is_t2r) );
    uint8   ddelta := { {7{aluop(instruction).ddelta1}}, aluop(instruction).ddelta0 };
    uint8   rdelta := { {7{aluop(instruction).rdelta1}}, aluop(instruction).rdelta0 };

    // program counter
    uint13  pc = 0;
    uint13  pcPlusOne := pc + 1;
    uint13  newPC = uninitialized;

    // dstack 257x16bit (as 3256 array + stackTop) and pointer, next pointer, write line, delta
    dualport_bram uint16 dstack[256] = uninitialized; // bram (code from @sylefeb)
    uint16  stackTop = 0;
    uint8   dsp = 0;
    uint8   newDSP = 0;
    uint16  newStackTop = uninitialized;

    // rstack 256x16bit and pointer, next pointer, write line
    dualport_bram uint16 rstack[256] = uninitialized; // bram (code from @sylefeb)
    uint8   rsp = 0;
    uint8   newRSP = 0;
    uint16  rstackWData = uninitialized;

    uint16  stackNext = uninitialized;
    uint16  rStackTop = uninitialized;
    uint16  memoryInput = uninitialized;

    // 16bit ROM with included with compiled j1eForth developed from https://github.com/samawati/j1eforth
    dualport_bram uint16 ram_0[8192] = {
        $include('ROM/j1eforthROM.inc')
        , pad(uninitialized)
    };
    dualport_bram uint16 ram_1[8192] = uninitialized;

    // CYCLE to control each stage
    // CYCLE allows 1 clock cycle for BRAM access
    uint2 CYCLE = 0;

    // Setup Memory Mapped I/O
    memmap_io IO_Map
$$if ULX3S then
<@clock,!reset>
$$end
(
        leds :> leds,
        btns <: btns,

        // UART
        ui <:> ui,
        uo <:> uo,

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
        video_reset <: video_reset,

        // Memory Address/Data
        memoryAddress <: stackTop,
        writeData <: stackNext
    );

    // Setup addresses for the ram
    // General memory accessed via port 0, Instruction data accessed via port 1
    ram_0.addr0 := stackTop >> 1;
    ram_0.wdata0 := stackNext;
    ram_0.wenable0 := 0;
    ram_1.addr0 := stackTop >> 1;
    ram_1.wdata0 := stackNext;
    ram_1.wenable0 := 0;
    ram_1.wenable1 := 0;
    // PC for instruction
    ram_0.addr1 := pc;
    ram_0.wenable1 := 0;

    // Setup addresses for the dstack and rstack
    // Read via port 0, write via port 1
    dstack.addr0 := dsp;
    dstack.wenable0 := 0;
    dstack.wenable1 := 1;
    rstack.addr0 := rsp;
    rstack.wenable0 := 0;
    rstack.wenable1 := 1;

    // IO Map Read / Write Flags
    IO_Map.memoryWrite := 0;
    IO_Map.memoryRead := 0;
    $$if ULX3S then
        IO_Map.resetCoPro := ( CYCLE == 2 );
    $$end
    $$if DE10NANO then
        IO_Map.resetCoPro := ( CYCLE == 3 );
    $$end

    // EXECUTE J1 CPU
    while( 1 ) {
        switch( CYCLE ) {
            // Read stackNext, rStackTop
            case 0: {
                // read dstack and rstack brams (code from @sylefeb)
                stackNext = dstack.rdata0;
                rStackTop = rstack.rdata0;

                // read instruction and pre-emptively the memory
                instruction = ram_0.rdata1;
                memoryInput = ( stackTop > 16383 ) ? ram_1.rdata0 : ram_0.rdata0;
            }

            // J1 CPU Instruction Execute
            case 1: {
                // +---------------------------------------------------------------+
                // | F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
                // +---------------------------------------------------------------+
                // | 1 |                    LITERAL VALUE                          |
                // +---------------------------------------------------------------+
                // | 0 | 0 | 0 |            BRANCH TARGET ADDRESS                  |
                // +---------------------------------------------------------------+
                // | 0 | 0 | 1 |            CONDITIONAL BRANCH TARGET ADDRESS      |
                // +---------------------------------------------------------------+
                // | 0 | 1 | 0 |            CALL TARGET ADDRESS                    |
                // +---------------------------------------------------------------+
                // | 0 | 1 | 1 |R2P| ALU OPERATION |T2N|T2R|N2A|J1P| RSTACK| DSTACK|
                // +---------------------------------------------------------------+
                // | F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
                // +---------------------------------------------------------------+
                //
                // T   : Top of data stack
                // N   : Next on data stack
                // PC  : Program Counter
                //
                // LITERAL VALUES : push a value onto the data stack
                // CONDITIONAL    : BRANCHS pop and test the T
                // CALLS          : PC+1 onto the return stack
                //
                // T2N : Move T to N
                // T2R : Move T to top of return stack
                // N2A : STORE T to memory location addressed by N
                // R2P : Move top of return stack to PC
                //
                // RSTACK and DSTACK are signed values (twos compliment) that are
                // the stack delta (the amount to increment or decrement the stack
                // by for their respective stacks: return and data)

                if(is_lit) {
                    // LITERAL Push value onto stack
                    newStackTop = immediate;
                    newPC = pcPlusOne;
                    newDSP = dsp + 1;
                    newRSP = rsp;
                } else {
                    switch( callbranch(instruction).is_callbranchalu ) { // BRANCH 0BRANCH CALL ALU
                        case 2b00: {
                            // BRANCH
                            newStackTop = stackTop;
                            newPC = callbranch(instruction).address;
                            newDSP = dsp;
                            newRSP = rsp;
                        }
                        case 2b01: {
                            // 0BRANCH
                            newStackTop = stackNext;
                            newPC = ( stackTop == 0 ) ? callbranch(instruction).address : pcPlusOne;
                            newDSP = dsp - 1;
                            newRSP = rsp;
                        }
                        case 2b10: {
                            // CALL
                            newStackTop = stackTop;
                            newPC = callbranch(instruction).address;
                            newDSP = dsp;
                            newRSP = rsp + 1;
                            rstackWData = pcPlusOne << 1;
                        }
                        case 2b11: {
                            // ALU
                            switch( aluop(instruction).is_j1j1plus ) {
                                case 1b0: {
                                    switch( aluop(instruction).operation ) {
                                        case 4b0000: {newStackTop = stackTop;}
                                        case 4b0001: {newStackTop = stackNext;}
                                        case 4b0010: {newStackTop = stackTop + stackNext;}
                                        case 4b0011: {newStackTop = stackTop & stackNext;}
                                        case 4b0100: {newStackTop = stackTop | stackNext;}
                                        case 4b0101: {newStackTop = stackTop ^ stackNext;}
                                        case 4b0110: {newStackTop = ~stackTop;}
                                        case 4b0111: {newStackTop = {16{(stackNext == stackTop)}};}
                                        case 4b1000: {newStackTop = {16{(__signed(stackNext) < __signed(stackTop))}};}
                                        case 4b1001: {newStackTop = stackNext >> nibbles(stackTop).nibble0;}
                                        case 4b1010: {newStackTop = stackTop - 1;}
                                        case 4b1011: {newStackTop = rStackTop;}
                                        case 4b1100: {
                                            if( stackTop < 32768 ) {
                                                newStackTop = memoryInput;
                                            } else {
                                               IO_Map.memoryRead = 1;
                                               newStackTop = IO_Map.readData;
                                            }
                                        }
                                        case 4b1101: {newStackTop = stackNext << nibbles(stackTop).nibble0;}
                                        case 4b1110: {newStackTop = {rsp, dsp};}
                                        case 4b1111: {newStackTop = {16{(__unsigned(stackNext) < __unsigned(stackTop))}};}
                                    }
                                }

                                case 1b1: {
                                    // Extra J1+ CPU Operations
                                    switch( aluop(instruction).operation ) {
                                         case 4b0000: {newStackTop = {16{(stackTop == 0)}};}
                                        case 4b0001: {newStackTop = {16{(stackTop != 0)}};}
                                        case 4b0010: {newStackTop = {16{(stackNext != stackTop)}};}
                                        case 4b0011: {newStackTop = stackTop + 1;}
                                        case 4b0100: {newStackTop = stackNext * stackTop;}
                                        case 4b0101: {newStackTop = stackTop << 1;}
                                        case 4b0110: {newStackTop = -stackTop;}
                                        case 4b0111: {newStackTop = { stackTop[15,1], stackTop[1,15]}; }
                                        case 4b1000: {newStackTop = stackNext - stackTop;}
                                        case 4b1001: {newStackTop = {16{(__signed(stackTop) < __signed(0))}};}
                                        case 4b1010: {newStackTop = {16{(__signed(stackTop) > __signed(0))}};}
                                        case 4b1011: {newStackTop = {16{(__signed(stackNext) > __signed(stackTop))}};}
                                        case 4b1100: {newStackTop = {16{(__signed(stackNext) >= __signed(stackTop))}};}
                                        case 4b1101: {newStackTop = ( __signed(stackTop) < __signed(0) ) ?  -stackTop : stackTop;}
                                        case 4b1110: {newStackTop = ( __signed(stackNext) > __signed(stackTop) ) ? stackNext : stackTop;}
                                        case 4b1111: {newStackTop = ( __signed(stackNext) < __signed(stackTop) ) ? stackNext : stackTop;}
                                    }
                                }
                            } // ALU Operation

                            // UPDATE newDSP newRSP
                            newDSP = dsp + ddelta;
                            newRSP = rsp + rdelta;
                            rstackWData = stackTop;

                            // Update PC for next instruction, return from call or next instruction
                            newPC = ( aluop(instruction).is_r2pc ) ? rStackTop >> 1 : pcPlusOne;

                            // n2memt mem[t] = n
                            if( aluop(instruction).is_n2memt ) {
                                if( stackTop < 32768 ) {
                                    ram_0.wenable0 = ( stackTop < 16384 );
                                    ram_1.wenable0 = ( stackTop > 16383 ) && ( stackTop < 32768 );
                                } else {
                                    IO_Map.memoryWrite = 1;
                                }
                            }
                        } // ALU
                    }
                }
            } // J1 CPU Instruction Execute

            // update pc and perform mem[t] = n
            case 2: {
                // Commit to dstack and rstack
                if( dstackWrite ) {
                    dstack.addr1 = newDSP;
                    dstack.wdata1 = stackTop;
                }
                if( rstackWrite ) {
                    rstack.addr1 = newRSP;
                    rstack.wdata1 = rstackWData;
                }

                // Update dsp, rsp, pc, stackTop
                dsp = newDSP;
                pc = newPC;
                stackTop = newStackTop;
                rsp = newRSP;
            }

            default: {}
        } // switch(CYCLE)

        // Move to next CYCLE ( 0 to 3 , then back to 0 )
        CYCLE = ( CYCLE == 3 ) ? 0 : CYCLE + 1;
    } // execute J1 CPU
}
