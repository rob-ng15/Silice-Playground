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

    // PS2
    output  uint1   usb_fpga_pu_dp,
    output  uint1   usb_fpga_pu_dn,
    input   uint1   usb_fpga_bd_dp,
    input   uint1   usb_fpga_bd_dn,

    // AUDIO
    output! uint4   audio_l,
    output! uint4   audio_r

)
$$if ULX3S then
<@clock_50mhz>
$$end
{
    // VGA/HDMI Display
    uint1   video_reset = uninitialized;
    uint1   video_clock = uninitialized;
    uint1   pll_lock = uninitialized;

    // Generate the 100MHz SDRAM and 25MHz VIDEO clocks
$$if DE10NANO then
    uint1 sdram_clock = uninitialized;
    uint1 clock_50mhz = uninitialized;

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
$$end

    // J1+ CPU
    // instruction being executed, plus decoding, including 5bit deltas for dsp and rsp expanded from 2bit encoded in the alu instruction
    uint16  instruction = uninitialized;
    uint16  immediate := ( literal(instruction).literalvalue );
    uint1   is_alu := ( instruction(instruction).is_litcallbranchalu == 3b011 );
    uint1   is_call := ( instruction(instruction).is_litcallbranchalu == 3b010 );
    uint1   is_lit := literal(instruction).is_literal;
    uint1   is_n2memt := is_alu && aluop(instruction).is_n2memt;
    uint2   is_callbranchalu := callbranch(instruction).is_callbranchalu;
    uint1   dstackWrite := ( is_lit | (is_alu & aluop(instruction).is_t2n) );
    uint1   rstackWrite := ( is_call | (is_alu & aluop(instruction).is_t2r) );
    uint8   ddelta := { {7{aluop(instruction).ddelta1}}, aluop(instruction).ddelta0 };
    uint8   rdelta := { {7{aluop(instruction).rdelta1}}, aluop(instruction).rdelta0 };

    // program counter
    uint13  pc = 0;
    uint13  pcPlusOne := pc + 1;
    uint13  newPC = uninitialized;
    uint13  callBranchAddress := callbranch(instruction).address;

    // dstack 257x16bit (as 3256 array + stackTop) and pointer, next pointer, write line, delta
    simple_dualport_bram uint16 dstack[256] = uninitialized; // bram (code from @sylefeb)
    uint16  stackTop = 0;
    uint8   dsp = 0;
    uint8   newDSP = uninitialized;
    uint16  newStackTop = uninitialized;

    // rstack 256x16bit and pointer, next pointer, write line
    simple_dualport_bram uint16 rstack[256] = uninitialized; // bram (code from @sylefeb)
    uint8   rsp = 0;
    uint8   newRSP = uninitialized;
    uint16  rstackWData = uninitialized;

    uint16  stackNext := dstack.rdata0;
    uint16  rStackTop := rstack.rdata0;

    uint16  IOmemoryRead := IO_Map.readData;
    uint16  RAMmemoryRead := ram.rdata0;

    j1eforthALU ALU
    $$if ULX3S then
        <@clock_50mhz,!reset>
    $$end
    (
        instruction <: instruction,

        dsp <: dsp,
        rsp <: rsp,

        stackTop <: stackTop,
        stackNext <: stackNext,
        rStackTop <: rStackTop,

        IOmemoryRead <: IOmemoryRead,
        RAMmemoryRead <: RAMmemoryRead
    );

    j1eforthplusALU ALUplus
    $$if ULX3S then
        <@clock_50mhz,!reset>
    $$end
    (
        instruction <: instruction,

        dsp <: dsp,
        rsp <: rsp,

        stackTop <: stackTop,
        stackNext <: stackNext
    );

    j1eforthcallbranch CALLBRANCH
    $$if ULX3S then
        <@clock_50mhz,!reset>
    $$end
    (
        is_callbranchalu <: is_callbranchalu,
        stackTop <: stackTop,
        stackNext <: stackNext,
        pcPlusOne <: pcPlusOne,
        callBranchAddress <: callBranchAddress,
        dsp <: dsp,
        rsp <: rsp,
    );

    // 16bit ROM with included with compiled j1eForth developed from https://github.com/samawati/j1eforth
    simple_dualport_bram uint16 ram[16384] = {
        $include('ROM/j1eforthROM.inc')
        , pad(uninitialized)
    };

    // Setup Memory Mapped I/O
    memmap_io IO_Map
    $$if ULX3S then
        <@clock_50mhz,!reset>
    $$end
    (
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
        clock_50mhz <: clock_50mhz,
$$if ULX3S then
        clock_25mhz <: clock,
$$end
        video_clock <:video_clock,
        video_reset <: video_reset,

        // Memory Address/Data
        memoryAddress <: stackTop,
        writeData <: stackNext
    );

    // RAM is read via port 0, written via port 1
    ram.wenable1 := 1;

    // Setup addresses for the dstack and rstack
    // Read via port 0, write via port 1
    dstack.addr0 := dsp;
    dstack.wenable1 := 1;
    rstack.addr0 := rsp;
    rstack.wenable1 := 1;

    // IO Map Read / Write Flags
    IO_Map.memoryWrite := 0;
    IO_Map.memoryRead := 0;

    $$if DE10NANO then
        // 50MHz clock specifically named for de10nano
        clock_50mhz := clock;
    $$end

    // ALU START FLAGS
    ALU.start := 0;
    ALUplus.start := 0;

    // Set initial write to top of memory
    ram.addr1 = 16383;
    ram.wdata1 = 0;

    // EXECUTE J1 CPU
    while( 1 ) {
        // FETCH INSTRUCTION
        ram.addr0 = pc;
        ++:
        instruction = ram.rdata0;
        ram.addr0 = {1b0,stackTop[1,15]};
        ++:

        // J1 CPU Instruction Execute
        if(is_lit) {
            // LITERAL Push value onto stack
            newStackTop = immediate;
            newPC = pcPlusOne;
            newDSP = dsp + 1;
            newRSP = rsp;
        } else {
            switch( callbranch(instruction).is_callbranchalu ) { // BRANCH 0BRANCH CALL ALU
                case 2b11: {
                    // ALU - fetch from memory or IO if needed
                    if( ~aluop(instruction).is_j1j1plus && ( aluop(instruction).operation == 4b1100 ) && stackTop[15,1] ) {
                        IO_Map.memoryRead = 1;
                    }
                    ALU.start = ~aluop(instruction).is_j1j1plus;
                    ALUplus.start = aluop(instruction).is_j1j1plus;
                    newStackTop = aluop(instruction).is_j1j1plus ? ALUplus.newStackTop : ALU.newStackTop;

                    // UPDATE newDSP newRSP
                    newDSP = dsp + ddelta;
                    newRSP = rsp + rdelta;
                    rstackWData = stackTop;

                    // Update PC for next instruction, return from call or next instruction
                    newPC = ( aluop(instruction).is_r2pc ) ? {1b0,rStackTop[1,15]} : pcPlusOne;

                    // n2memt mem[t] = n
                    if( is_n2memt && ~stackTop[15,1] ) {
                        ram.addr1 = {1b0,stackTop[1,15]};
                        ram.wdata1 = stackNext;
                    }
                    IO_Map.memoryWrite = is_n2memt && ( stackTop[15,1] );
                } // ALU

                default: {
                    newStackTop = CALLBRANCH.newStackTop;
                    newPC = CALLBRANCH.newPC;
                    newDSP = CALLBRANCH.newDSP;
                    newRSP = CALLBRANCH.newRSP;
                    rstackWData = {pcPlusOne[0,15],1b0};
                }
            }
        } // J1 CPU Instruction Execute

        ++:

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

        ++:
    } // execute J1 CPU
}

algorithm j1eforthALU(
    input   uint1   start,
    input   uint16  instruction,

    input   uint8   dsp,
    input   uint8   rsp,

    input   uint16  stackTop,
    input   uint16  stackNext,
    input   uint16  rStackTop,

    input   uint16  IOmemoryRead,
    input   uint16  RAMmemoryRead,

    output! uint16  newStackTop
) <autorun> {
    while(1) {
        if( start ) {
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
                case 4b1001: {newStackTop = __signed(stackNext) >>> nibbles(stackTop).nibble0;}
                case 4b1010: {newStackTop = stackTop - 1;}
                case 4b1011: {newStackTop = rStackTop;}
                case 4b1100: {newStackTop = stackTop[15,1] ? IOmemoryRead : RAMmemoryRead;}
                case 4b1101: {newStackTop = stackNext << nibbles(stackTop).nibble0;}
                case 4b1110: {newStackTop = {rsp, dsp};}
                case 4b1111: {newStackTop = {16{(__unsigned(stackNext) < __unsigned(stackTop))}};}
            }
        }
    }
}
algorithm j1eforthplusALU(
    input   uint1   start,
    input   uint16  instruction,

    input   uint8   dsp,
    input   uint8   rsp,

    input   uint16  stackTop,
    input   uint16  stackNext,

    output! uint16  newStackTop
) <autorun> {
    while(1) {
        if( start ) {
            switch( aluop(instruction).operation ) {
                case 4b0000: {newStackTop = {16{(stackTop == 0)}};}
                case 4b0001: {newStackTop = {16{(stackTop != 0)}};}
                case 4b0010: {newStackTop = {16{(stackNext != stackTop)}};}
                case 4b0011: {newStackTop = stackTop + 1;}
                case 4b0100: {newStackTop = stackNext * stackTop;}
                case 4b0101: {newStackTop = {stackTop[0,15], 1b0 };}
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
    }
}

algorithm j1eforthcallbranch(
    input   uint2   is_callbranchalu,
    input   uint16  stackTop,
    input   uint16  stackNext,
    input   uint13  callBranchAddress,
    input   uint13  pcPlusOne,
    input   uint8   dsp,
    input   uint8   rsp,

    output! uint16  newStackTop,
    output! uint13  newPC,
    output! uint8   newDSP,
    output! uint8   newRSP,
) <autorun> {
    while(1) {
        // ONLY TRIGGER IF CALL BRANCH 0BRANCH
        switch( is_callbranchalu ) {
            case 2b00: {
                // BRANCH
                newStackTop = stackTop;
                newPC = callBranchAddress;
                newDSP = dsp;
                newRSP = rsp;
            }
            case 2b01: {
                // 0BRANCH
                newStackTop = stackNext;
                newPC = ( stackTop == 0 ) ? callBranchAddress : pcPlusOne;
                newDSP = dsp - 1;
                newRSP = rsp;
            }
            case 2b10: {
                // CALL
                newStackTop = stackTop;
                newPC = callBranchAddress;
                newDSP = dsp;
                newRSP = rsp + 1;
            }
        }
    }
}
