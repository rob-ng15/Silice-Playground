// 7 bit colour either ALPHA (background or lower layer) or red, green, blue { Arrggbb }
bitfield colour7 {
    uint1   alpha,
    uint2   red,
    uint2   green,
    uint2   blue
}

// 6 bit colour red, green, blue { rrggbb }
bitfield colour6 {
    uint2   red,
    uint2   green,
    uint2   blue
}

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

// Simplify access to high/low word
bitfield words {
    uint16  hword,
    uint16  lword
}

// Simplify access to high/low byte
bitfield bytes {
    uint8   byte1,
    uint8   byte0
}

// Simplify access to 4bit nibbles (used to extract shift left/right amount)
bitfield nibbles {
    uint4   nibble3,
    uint4   nibble2,
    uint4   nibble1,
    uint4   nibble0
}

algorithm main(
    // LEDS (8 of)
    output  uint8   leds,
    input   uint$NUM_BTNS$ btns,

$$if ULX3S then
    output  uint4   gpdi_dp,
    output  uint4   gpdi_dn,
$$end

    // UART
    output! uint1   uart_tx,
    input   uint1   uart_rx,

    // AUDIO
    output! uint4   audio_l,
    output! uint4   audio_r,

    // VGA/HDMI
    output! uint6   video_r,
    output! uint6   video_g,
    output! uint6   video_b,
    output! uint1   video_hs,
    output! uint1   video_vs
)
$$if ULX3S then
<@clock_50mhz> // ULX3S has a 25 MHz clock, so we use a PLL to bring it up to 50 MHz
$$end
{
    // 1hz timers (p1hz used for systemClock and systemClockMHz, timer1hz for user purposes)
    uint16 systemClock = uninitialized;
    uint32 systemClockMHz = uninitialized;
    pulse1hz p1hz (
        counter1hz :> systemClock,
        counter50mhz :> systemClockMHz
    );
    pulse1hz timer1hz( );

    // 1khz timers (sleepTimer used for sleep command, timer1khz for user purposes)
    pulse1khz sleepTimer( );
    pulse1khz timer1khz( );

    // RNG random number generator
    uint16 staticGenerator = 0;
    random rng (
        g_noise_out :> staticGenerator
    );

    // UART tx and rx
    // UART written in Silice by https://github.com/sylefeb/Silice
    uart_out uo;
    uart_sender usend (
        io      <:> uo,
        uart_tx :>  uart_tx
    );

    uart_in ui;
    uart_receiver urecv (
        io      <:> ui,
        uart_rx <:  uart_rx
    );

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
    uint1   active = uninitialized;
    uint1   vblank = uninitialized;
    uint10  pix_x  = uninitialized;
    uint10  pix_y  = uninitialized;

    // VGA or HDMI driver
$$if DE10NANO then
    vga vga_driver <@video_clock,!video_reset> (
        vga_hs :> video_hs,
        vga_vs :> video_vs,
        active :> active,
        vblank :> vblank,
        vga_x  :> pix_x,
        vga_y  :> pix_y
    );
$$end

$$if ULX3S then
    // Adjust 6 bit rgb to 8 bit rgb for HDMI output
    uint8   video_r8 := video_r << 2;
    uint8   video_g8 := video_g << 2;
    uint8   video_b8 := video_b << 2;

    hdmi video<@clock,!reset> (
        x       :> pix_x,
        y       :> pix_y,
        active  :> active,
        vblank  :> vblank,
        gpdi_dp :> gpdi_dp,
        gpdi_dn :> gpdi_dn,
        red     <: video_r8,
        green   <: video_g8,
        blue    <: video_b8
    );
$$end

    // Build up the display layers
    // BACKGROUND
    uint2   background_r = uninitialized;
    uint2   background_g = uninitialized;
    uint2   background_b = uninitialized;
    background background_generator <@video_clock,!video_reset>  (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> background_r,
        pix_green  :> background_g,
        pix_blue   :> background_b,
        staticGenerator <: staticGenerator
    );

    // TILEMAP
    uint2   tilemap_r = uninitialized;
    uint2   tilemap_g = uninitialized;
    uint2   tilemap_b = uninitialized;
    uint1   tilemap_display = uninitialized;

    tilemap tile_map <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> tilemap_r,
        pix_green  :> tilemap_g,
        pix_blue   :> tilemap_b,
        tilemap_display :> tilemap_display,
    );

    // Bitmap Window
    uint2   bitmap_r = uninitialized;
    uint2   bitmap_g = uninitialized;
    uint2   bitmap_b = uninitialized;
    // From GPU to set a pixel
    uint1   bitmap_display = uninitialized;
    int11   bitmap_x_write = uninitialized;
    int11   bitmap_y_write = uninitialized;
    uint7   bitmap_colour_write = uninitialized;
    uint2   bitmap_write = uninitialized;

    bitmap bitmap_window <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> bitmap_r,
        pix_green  :> bitmap_g,
        pix_blue   :> bitmap_b,
        bitmap_display :> bitmap_display,
        bitmap_x_write <: bitmap_x_write,
        bitmap_y_write <: bitmap_y_write,
        bitmap_colour_write <: bitmap_colour_write,
        bitmap_write <: bitmap_write
    );

    // Lower Sprite Layer - Between BACKGROUND and BITMAP
    uint2   lower_sprites_r = uninitialized;
    uint2   lower_sprites_g = uninitialized;
    uint2   lower_sprites_b = uninitialized;
    uint1   lower_sprites_display = uninitialized;

    sprite_layer lower_sprites <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> lower_sprites_r,
        pix_green  :> lower_sprites_g,
        pix_blue   :> lower_sprites_b,
        sprite_layer_display :> lower_sprites_display,
        bitmap_display <: bitmap_display
    );

    // Upper Sprite Layer - Between BITMAP and CHARACTER MAP
    uint2   upper_sprites_r = uninitialized;
    uint2   upper_sprites_g = uninitialized;
    uint2   upper_sprites_b = uninitialized;
    uint1   upper_sprites_display = uninitialized;

    sprite_layer upper_sprites <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> upper_sprites_r,
        pix_green  :> upper_sprites_g,
        pix_blue   :> upper_sprites_b,
        sprite_layer_display :> upper_sprites_display,
        bitmap_display <: bitmap_display
    );

    // Character Map Window
    uint2   character_map_r = uninitialized;
    uint2   character_map_g = uninitialized;
    uint2   character_map_b = uninitialized;
    uint1   character_map_display = uninitialized;

    character_map character_map_window <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> character_map_r,
        pix_green  :> character_map_g,
        pix_blue   :> character_map_b,
        character_map_display :> character_map_display
    );

    // Terminal window at the bottom of the screen
    uint2   terminal_r = uninitialized;
    uint2   terminal_g = uninitialized;
    uint2   terminal_b = uninitialized;
    uint1   terminal_display = uninitialized;

    terminal terminal_window <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> terminal_r,
        pix_green  :> terminal_g,
        pix_blue   :> terminal_b,
        terminal_display :> terminal_display,
        timer1hz   <: systemClock
    );

    // Combine the display layers for display
    multiplex_display display <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> video_r,
        pix_green  :> video_g,
        pix_blue   :> video_b,

        background_r <: background_r,
        background_g <: background_g,
        background_b <: background_b,

        tilemap_r <: tilemap_r,
        tilemap_g <: tilemap_g,
        tilemap_b <: tilemap_b,
        tilemap_display <: tilemap_display,

        lower_sprites_r <: lower_sprites_r,
        lower_sprites_g <: lower_sprites_g,
        lower_sprites_b <: lower_sprites_b,
        lower_sprites_display <: lower_sprites_display,

        bitmap_r <: bitmap_r,
        bitmap_g <: bitmap_g,
        bitmap_b <: bitmap_b,
        bitmap_display <: bitmap_display,

        upper_sprites_r <: upper_sprites_r,
        upper_sprites_g <: upper_sprites_g,
        upper_sprites_b <: upper_sprites_b,
        upper_sprites_display <: upper_sprites_display,

        character_map_r <: character_map_r,
        character_map_g <: character_map_g,
        character_map_b <: character_map_b,
        character_map_display <: character_map_display,

        terminal_r <: terminal_r,
        terminal_g <: terminal_g,
        terminal_b <: terminal_b,
        terminal_display <: terminal_display
    );

    // Left and Right audio channels
    // Sync'd with video_clock
    apu apu_processor_L <@video_clock,!video_reset> (
        staticGenerator <: staticGenerator,
        audio_output :> audio_l
    );
    apu apu_processor_R <@video_clock,!video_reset> (
        staticGenerator <: staticGenerator,
        audio_output :> audio_r
    );

    // GPU, VECTOR DRAWER and DISPLAY LIST DRAWER
    // The GPU sends rendered pixels to the BITMAP LAYER
    // The VECTOR DRAWER sends lines to be rendered
    // The DISPLAY LIST DRAWER can send pixels, rectangles, lines, circles, blit1s to the GPU
    // and vector blocks to draw to the VECTOR DRAWER
    // VECTOR DRAWER to GPU
    int11   v_gpu_x = uninitialized;
    int11   v_gpu_y = uninitialized;
    uint7   v_gpu_colour = uninitialized;
    int11   v_gpu_param0 = uninitialized;
    int11   v_gpu_param1 = uninitialized;
    uint4   v_gpu_write = uninitialized;
    // Display list to GPU or VECTOR DRAWER
    int11   dl_gpu_x = uninitialized;
    int11   dl_gpu_y = uninitialized;
    uint7   dl_gpu_colour = uninitialized;
    int11   dl_gpu_param0 = uninitialized;
    int11   dl_gpu_param1 = uninitialized;
    int11   dl_gpu_param2 = uninitialized;
    int11   dl_gpu_param3 = uninitialized;
    uint4   dl_gpu_write = uninitialized;
    uint5   dl_vector_block_number = uninitialized;
    uint7   dl_vector_block_colour = uninitialized;
    int11   dl_vector_block_xc = uninitialized;
    int11   dl_vector_block_yc =uninitialized;
    uint1   dl_draw_vector = uninitialized;
    // Status flags
    uint3   vector_block_active = uninitialized;
    uint6   gpu_active = uninitialized;

    gpu gpu_processor <@video_clock,!video_reset> (
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_colour_write :> bitmap_colour_write,
        bitmap_write :> bitmap_write,
        gpu_active :> gpu_active,

        v_gpu_x <: v_gpu_x,
        v_gpu_y <: v_gpu_y,
        v_gpu_colour <: v_gpu_colour,
        v_gpu_param0 <: v_gpu_param0,
        v_gpu_param1 <: v_gpu_param1,
        v_gpu_write <: v_gpu_write,

        dl_gpu_x <: dl_gpu_x,
        dl_gpu_y <: dl_gpu_y,
        dl_gpu_colour <: dl_gpu_colour,
        dl_gpu_param0 <: dl_gpu_param0,
        dl_gpu_param1 <: dl_gpu_param2,
        dl_gpu_param2 <: dl_gpu_param3,
        dl_gpu_param3 <: dl_gpu_param1,
        dl_gpu_write <: dl_gpu_write
    );

    // Vector drawer
    vectors vector_drawer <@video_clock,!video_reset> (
        gpu_x :> v_gpu_x,
        gpu_y :> v_gpu_y,
        gpu_colour :> v_gpu_colour,
        gpu_param0 :> v_gpu_param0,
        gpu_param1 :> v_gpu_param1,
        gpu_write :> v_gpu_write,
        vector_block_active :> vector_block_active,
        gpu_active <: gpu_active,

        dl_vector_block_number <: dl_vector_block_number,
        dl_vector_block_colour <: dl_vector_block_colour,
        dl_vector_block_xc <: dl_vector_block_xc,
        dl_vector_block_yc <: dl_vector_block_yc,
        dl_draw_vector <: dl_draw_vector,
    );

    // Display list
    displaylist displaylist_drawer <@video_clock,!video_reset> (
        gpu_x :> dl_gpu_x,
        gpu_y :> dl_gpu_y,
        gpu_colour :> dl_gpu_colour,
        gpu_param0 :> dl_gpu_param0,
        gpu_param1 :> dl_gpu_param1,
        gpu_param2 :> dl_gpu_param2,
        gpu_param3 :> dl_gpu_param3,
        gpu_write :> dl_gpu_write,
        vector_block_number :> dl_vector_block_number,
        vector_block_colour :> dl_vector_block_colour,
        vector_block_xc :> dl_vector_block_xc,
        vector_block_yc :> dl_vector_block_yc,
        draw_vector :> dl_draw_vector,
        vector_block_active <: vector_block_active,
        gpu_active <: gpu_active
    );

    // Mathematics Cop Processors
    divmod32by16 divmod32by16to16qr ();
    divmod16by16 divmod16by16to16qr ();
    multi16by16to32DSP multiplier16by16to32 ();

    doubleaddsub doperations ();

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

    // UART input FIFO (4096 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 uartInBuffer[4096] = uninitialized;
    uint13  uartInBufferNext = 0;
    uint13  uartInBufferTop = 0;

    // UART output FIFO (256 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 uartOutBuffer[256] = uninitialized;
    uint8   uartOutBufferNext = 0;
    uint8   uartOutBufferTop = 0;
    uint8   newuartOutBufferTop = 0;

    // register buttons
    uint$NUM_BTNS$ reg_btns = 0;
    reg_btns ::= btns;

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

    // UART Buffers
    uartInBuffer.wenable0  := 0;  // always read  on port 0
    uartInBuffer.wenable1  := 1;  // always write on port 1
    uartInBuffer.addr0     := uartInBufferNext; // FIFO reads on next
    uartInBuffer.addr1     := uartInBufferTop;  // FIFO writes on top

    uartOutBuffer.wenable0 := 0; // always read  on port 0
    uartOutBuffer.wenable1 := 1; // always write on port 1
    uartOutBuffer.addr0    := uartOutBufferNext; // FIFO reads on next
    uartOutBuffer.addr1    := uartOutBufferTop;  // FIFO writes on top

    // Setup the UART
    uo.data_in_ready := 0; // maintain low

    // RESET Mathematics Co-Processor Controls
    divmod32by16to16qr.start := 0;
    divmod16by16to16qr.start := 0;
    multiplier16by16to32.start := 0;

    // UART input and output buffering
    always {
        // READ from UART if character available and store
        if( ui.data_out_ready ) {
            // writes at uartInBufferTop (code from @sylefeb)
            uartInBuffer.wdata1  = ui.data_out;
            uartInBufferTop      = uartInBufferTop + 1;
        }
        // WRITE to UART if characters in buffer and UART is ready
        if( (uartOutBufferNext != uartOutBufferTop) && ( !uo.busy ) ) {
            // reads at uartOutBufferNext (code from @sylefeb)
            uo.data_in      = uartOutBuffer.rdata0;
            uo.data_in_ready     = 1;
            uartOutBufferNext = uartOutBufferNext + 1;
        }
    }

    // Setup the terminal
    terminal_window.showterminal = 1;
    terminal_window.showcursor = 1;

    // EXECUTE J1 CPU
    while( 1 ) {
        // Update UART output buffer top if character has been put into buffer
        uartOutBufferTop = newuartOutBufferTop;

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
                                            switch( stackTop[12,4] ) {
                                                default: { newStackTop = memoryInput; }
                                                case 4hf: {
                                                    switch( stackTop[8,4] ) {
                                                        case 4h0: {
                                                            switch( stackTop[0,4] ) {
                                                                // f000
                                                                case 4h0: { newStackTop = { 8b0, uartInBuffer.rdata0 }; uartInBufferNext = uartInBufferNext + 1; }
                                                                case 4h1: { newStackTop = { 14b0, ( uartOutBufferTop + 1 == uartOutBufferNext ), ( uartInBufferNext != uartInBufferTop )}; }
                                                                case 4h2: { newStackTop = leds; }
                                                                case 4h3: { newStackTop = {$16-NUM_BTNS$b0, reg_btns[0,$NUM_BTNS$]}; }
                                                                case 4h4: { newStackTop = systemClock; }
                                                            }
                                                        }
                                                        case 4hf: {
                                                            switch( stackTop[4,4] ) {
                                                                case 4h0: {
                                                                    switch( stackTop[0,4] ) {
                                                                        // ff00 -
                                                                        case 4h7: { newStackTop = gpu_processor.gpu_active; }
                                                                        case 4h8: { newStackTop = bitmap_window.bitmap_colour_read; }
                                                                    }
                                                                }
                                                                case 4h1: {
                                                                   switch( stackTop[0,4] ) {
                                                                        // ff10 -
                                                                        case 4h5: { newStackTop = character_map_window.tpu_active; }
                                                                   }
                                                                }
                                                                case 4h2: {
                                                                    switch( stackTop[0,4] ) {
                                                                        // ff20 -
                                                                        case 4h0: { newStackTop = terminal_window.terminal_active; }
                                                                    }
                                                                }
                                                                case 4h3: {
                                                                    switch( stackTop[0,4] ) {
                                                                        // ff30 -
                                                                        case 4h1: { newStackTop = lower_sprites.sprite_read_active; }
                                                                        case 4h2: { newStackTop = lower_sprites.sprite_read_tile; }
                                                                        case 4h3: { newStackTop = lower_sprites.sprite_read_colour; }
                                                                        case 4h4: { newStackTop = lower_sprites.sprite_read_x; }
                                                                        case 4h5: { newStackTop = lower_sprites.sprite_read_y; }
                                                                        case 4h6: { newStackTop = lower_sprites.sprite_read_double; }
                                                                        case 4h7: { newStackTop = lower_sprites.sprite_read_colmode; }
                                                                    }
                                                                }
                                                                case 4h4: {
                                                                    switch( stackTop[0,4] ) {
                                                                        // ff40 -
                                                                        case 4h1: { newStackTop = upper_sprites.sprite_read_active; }
                                                                        case 4h2: { newStackTop = upper_sprites.sprite_read_tile; }
                                                                        case 4h3: { newStackTop = upper_sprites.sprite_read_colour; }
                                                                        case 4h4: { newStackTop = upper_sprites.sprite_read_x; }
                                                                        case 4h5: { newStackTop = upper_sprites.sprite_read_y; }
                                                                        case 4h6: { newStackTop = upper_sprites.sprite_read_double; }
                                                                        case 4h7: { newStackTop = upper_sprites.sprite_read_colmode; }
                                                                    }
                                                                }
                                                                case 4h5: {
                                                                    switch( stackTop[0,4] ) {
                                                                        // ff50 -
                                                                        case 4h0: { newStackTop = lower_sprites.collision_0; }
                                                                        case 4h1: { newStackTop = lower_sprites.collision_1; }
                                                                        case 4h2: { newStackTop = lower_sprites.collision_2; }
                                                                        case 4h3: { newStackTop = lower_sprites.collision_3; }
                                                                        case 4h4: { newStackTop = lower_sprites.collision_4; }
                                                                        case 4h5: { newStackTop = lower_sprites.collision_5; }
                                                                        case 4h6: { newStackTop = lower_sprites.collision_6; }
                                                                        case 4h7: { newStackTop = lower_sprites.collision_7; }
                                                                        case 4h8: { newStackTop = lower_sprites.collision_8; }
                                                                        case 4h9: { newStackTop = lower_sprites.collision_9; }
                                                                        case 4ha: { newStackTop = lower_sprites.collision_10; }
                                                                        case 4hb: { newStackTop = lower_sprites.collision_11; }
                                                                        case 4hc: { newStackTop = lower_sprites.collision_12; }
                                                                    }
                                                                }
                                                                case 4h6: {
                                                                    switch( stackTop[0,4] ) {
                                                                        // ff60 -
                                                                        case 4h0: { newStackTop = upper_sprites.collision_0; }
                                                                        case 4h1: { newStackTop = upper_sprites.collision_1; }
                                                                        case 4h2: { newStackTop = upper_sprites.collision_2; }
                                                                        case 4h3: { newStackTop = upper_sprites.collision_3; }
                                                                        case 4h4: { newStackTop = upper_sprites.collision_4; }
                                                                        case 4h5: { newStackTop = upper_sprites.collision_5; }
                                                                        case 4h6: { newStackTop = upper_sprites.collision_6; }
                                                                        case 4h7: { newStackTop = upper_sprites.collision_7; }
                                                                        case 4h8: { newStackTop = upper_sprites.collision_8; }
                                                                        case 4h9: { newStackTop = upper_sprites.collision_9; }
                                                                        case 4ha: { newStackTop = upper_sprites.collision_10; }
                                                                        case 4hb: { newStackTop = upper_sprites.collision_11; }
                                                                        case 4hc: { newStackTop = upper_sprites.collision_12; }
                                                                    }
                                                                }
                                                                case 4h7: {
                                                                    switch( stackTop[0,4] ) {
                                                                        // ff70 -
                                                                        case 4h4: { newStackTop = vector_drawer.vector_block_active; }
                                                                    }
                                                                }
                                                                case 4h8: {
                                                                    switch( stackTop[0,4] ) {
                                                                        // ff80 -
                                                                        case 4h2: { newStackTop = displaylist_drawer.display_list_active; }
                                                                        case 4h4: { newStackTop = displaylist_drawer.read_active; }
                                                                        case 4h5: { newStackTop = displaylist_drawer.read_command; }
                                                                        case 4h6: { newStackTop = displaylist_drawer.read_colour; }
                                                                        case 4h7: { newStackTop = displaylist_drawer.read_x; }
                                                                        case 4h8: { newStackTop = displaylist_drawer.read_y; }
                                                                        case 4h9: { newStackTop = displaylist_drawer.read_p0; }
                                                                        case 4ha: { newStackTop = displaylist_drawer.read_p1; }
                                                                        case 4hb: { newStackTop = displaylist_drawer.read_p2; }
                                                                        case 4hc: { newStackTop = displaylist_drawer.read_p3; }
                                                                    }
                                                                }
                                                                case 4h9: {
                                                                    switch( stackTop[0,4] ) {
                                                                        // ff90 -
                                                                        case 4h9: { newStackTop = tile_map.tm_lastaction; }
                                                                        case 4ha: { newStackTop = tile_map.tm_active; }
                                                                    }
                                                                }
                                                                case 4ha: {
                                                                    switch( stackTop[0,4] ) {
                                                                        case 4h0: { newStackTop = words(doperations.total).hword; }
                                                                        case 4h1: { newStackTop = words(doperations.total).lword; }
                                                                        case 4h2: { newStackTop = words(doperations.difference).hword; }
                                                                        case 4h3: { newStackTop = words(doperations.difference).lword; }
                                                                        case 4h4: { newStackTop = words(doperations.increment).hword; }
                                                                        case 4h5: { newStackTop = words(doperations.increment).lword; }
                                                                        case 4h6: { newStackTop = words(doperations.decrement).hword; }
                                                                        case 4h7: { newStackTop = words(doperations.decrement).lword; }
                                                                        case 4h8: { newStackTop = words(doperations.times2).hword; }
                                                                        case 4h9: { newStackTop = words(doperations.times2).lword; }
                                                                        case 4ha: { newStackTop = words(doperations.divide2).hword; }
                                                                        case 4hb: { newStackTop = words(doperations.divide2).lword; }
                                                                        case 4hc: { newStackTop = words(doperations.negation).hword; }
                                                                        case 4hd: { newStackTop = words(doperations.negation).lword; }
                                                                        case 4he: { newStackTop = words(doperations.binaryinvert).hword; }
                                                                        case 4hf: { newStackTop = words(doperations.binaryinvert).lword; }
                                                                    }
                                                                }
                                                                case 4hb: {
                                                                    switch( stackTop[0,4] ) {
                                                                        case 4h0: { newStackTop = words(doperations.binaryxor).hword; }
                                                                        case 4h1: { newStackTop = words(doperations.binaryxor).lword; }
                                                                        case 4h2: { newStackTop = words(doperations.binaryand).hword; }
                                                                        case 4h3: { newStackTop = words(doperations.binaryand).lword; }
                                                                        case 4h4: { newStackTop = words(doperations.binaryor).hword; }
                                                                        case 4h5: { newStackTop = words(doperations.binaryor).lword; }
                                                                        case 4h6: { newStackTop = words(doperations.absolute).hword; }
                                                                        case 4h7: { newStackTop = words(doperations.absolute).lword; }
                                                                        case 4h8: { newStackTop = words(doperations.maximum).hword; }
                                                                        case 4h9: { newStackTop = words(doperations.maximum).lword; }
                                                                        case 4ha: { newStackTop = words(doperations.minimum).hword; }
                                                                        case 4hb: { newStackTop = words(doperations.minimum).lword; }
                                                                        case 4hc: { newStackTop = doperations.zeroequal; }
                                                                        case 4hd: { newStackTop = doperations.zeroless; }
                                                                        case 4he: { newStackTop = doperations.equal; }
                                                                        case 4hf: { newStackTop = doperations.lessthan; }
                                                                    }
                                                                }
                                                                case 4hd: {
                                                                    switch( stackTop[0,4] ) {
                                                                        case 4h0: { newStackTop = divmod32by16to16qr.quotient[0,16]; }
                                                                        case 4h1: { newStackTop = divmod32by16to16qr.remainder[0,16]; }
                                                                        case 4h3: { newStackTop = divmod32by16to16qr.active; }
                                                                        case 4h4: { newStackTop = divmod16by16to16qr.quotient; }
                                                                        case 4h5: { newStackTop = divmod16by16to16qr.remainder; }
                                                                        case 4h6: { newStackTop = divmod16by16to16qr.active; }
                                                                        case 4h7: { newStackTop = multiplier16by16to32.product[16,16]; }
                                                                        case 4h8: { newStackTop = multiplier16by16to32.product[0,16]; }
                                                                        case 4h9: { newStackTop = multiplier16by16to32.active; }
                                                                    }
                                                                }
                                                                case 4he: {
                                                                    switch( stackTop[0,4] ) {
                                                                        // ffe0 -
                                                                        case 4h0: { newStackTop = staticGenerator; }
                                                                        case 4h3: { newStackTop = apu_processor_L.audio_active; }
                                                                        case 4h7: { newStackTop = apu_processor_R.audio_active; }
                                                                        case 4hd: { newStackTop = timer1hz.counter1hz; }
                                                                        case 4he: { newStackTop = timer1khz.counter1khz; }
                                                                        case 4hf: { newStackTop = sleepTimer.counter1khz; }
                                                                    }
                                                                }
                                                                case 4hf: {
                                                                    switch( stackTop[0,4] ) {
                                                                        // fff0 -
                                                                        case 4hf: { newStackTop = vblank; }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
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
                                        case 4b0111: {newStackTop = { stackTop[15,1], stackTop[1,15] }; }
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
                                switch( stackTop[12,4] ) {
                                    case 4hf: {
                                        switch( stackTop[8,4] ) {
                                            case 4h0: {
                                                switch( stackTop[0,4] ) {
                                                    // f000 -
                                                    case 4h0: { uartOutBuffer.wdata1 = bytes(stackNext).byte0; newuartOutBufferTop = uartOutBufferTop + 1; }
                                                    case 4h2: { leds = stackNext; }
                                                }
                                            }
                                            case 4hf: {
                                                switch( stackTop[4,4] ) {
                                                    case 4h0: {
                                                        switch( stackTop[0,4] ) {
                                                            // ff00 -
                                                            case 4h0: { gpu_processor.gpu_x = stackNext; }
                                                            case 4h1: { gpu_processor.gpu_y = stackNext; }
                                                            case 4h2: { gpu_processor.gpu_colour = stackNext; }
                                                            case 4h3: { gpu_processor.gpu_param0 = stackNext; }
                                                            case 4h4: { gpu_processor.gpu_param1 = stackNext; }
                                                            case 4h5: { gpu_processor.gpu_param2 = stackNext; }
                                                            case 4h6: { gpu_processor.gpu_param3 = stackNext; }
                                                            case 4h7: { gpu_processor.gpu_write = stackNext; }
                                                            case 4h9: { bitmap_window.bitmap_x_read = stackNext; }
                                                            case 4ha: { bitmap_window.bitmap_y_read = stackNext; }
                                                            case 4hb: { gpu_processor.blit1_writer_tile = stackNext; }
                                                            case 4hc: { gpu_processor.blit1_writer_line = stackNext; }
                                                            case 4hd: { gpu_processor.blit1_writer_bitmap = stackNext;  gpu_processor.blit1_writer_active = 1; }
                                                        }
                                                    }
                                                    case 4h1: {
                                                        switch( stackTop[0,4] ) {
                                                            // ff10 -
                                                            case 4h0: { character_map_window.tpu_x = stackNext; }
                                                            case 4h1: { character_map_window.tpu_y = stackNext; }
                                                            case 4h2: { character_map_window.tpu_character = stackNext; }
                                                            case 4h3: { character_map_window.tpu_background = stackNext; }
                                                            case 4h4: { character_map_window.tpu_foreground = stackNext; }
                                                            case 4h5: { character_map_window.tpu_write = stackNext; }
                                                        }
                                                    }
                                                    case 4h2: {
                                                        switch( stackTop[0,4] ) {
                                                            // ff20 -
                                                            case 4h0: { terminal_window.terminal_character = stackNext; terminal_window.terminal_write = 1; }
                                                            case 4h1: { terminal_window.showterminal = stackNext; }
                                                        }
                                                    }
                                                    case 4h3: {
                                                        switch( stackTop[0,4] ) {
                                                            // ff30 -
                                                            case 4h0: { lower_sprites.sprite_set_number = stackNext; }
                                                            case 4h1: { lower_sprites.sprite_set_active = stackNext; lower_sprites.sprite_layer_write = 1; }
                                                            case 4h2: { lower_sprites.sprite_set_tile = stackNext; lower_sprites.sprite_layer_write = 2; }
                                                            case 4h3: { lower_sprites.sprite_set_colour = stackNext; lower_sprites.sprite_layer_write = 3; }
                                                            case 4h4: { lower_sprites.sprite_set_x = stackNext; lower_sprites.sprite_layer_write = 4; }
                                                            case 4h5: { lower_sprites.sprite_set_y = stackNext; lower_sprites.sprite_layer_write = 5; }
                                                            case 4h6: { lower_sprites.sprite_set_double = stackNext; lower_sprites.sprite_layer_write = 6; }
                                                            case 4h7: { lower_sprites.sprite_set_colmode = stackNext; lower_sprites.sprite_layer_write = 7; }
                                                            case 4h8: { lower_sprites.sprite_writer_sprite = stackNext; }
                                                            case 4h9: { lower_sprites.sprite_writer_line = stackNext; }
                                                            case 4ha: { lower_sprites.sprite_writer_bitmap = stackNext; lower_sprites.sprite_writer_active = 1; }
                                                            case 4he: { lower_sprites.sprite_update = stackNext; lower_sprites.sprite_layer_write = 10; }
                                                        }
                                                    }
                                                    case 4h4: {
                                                        switch( stackTop[0,4] ) {
                                                            // ff40 -
                                                            case 4h0: { upper_sprites.sprite_set_number = stackNext; }
                                                            case 4h1: { upper_sprites.sprite_set_active = stackNext; upper_sprites.sprite_layer_write = 1; }
                                                            case 4h2: { upper_sprites.sprite_set_tile = stackNext; upper_sprites.sprite_layer_write = 2; }
                                                            case 4h3: { upper_sprites.sprite_set_colour = stackNext; upper_sprites.sprite_layer_write = 3; }
                                                            case 4h4: { upper_sprites.sprite_set_x = stackNext; upper_sprites.sprite_layer_write = 4; }
                                                            case 4h5: { upper_sprites.sprite_set_y = stackNext; upper_sprites.sprite_layer_write = 5; }
                                                            case 4h6: { upper_sprites.sprite_set_double = stackNext; upper_sprites.sprite_layer_write = 6; }
                                                            case 4h7: { upper_sprites.sprite_set_colmode = stackNext; upper_sprites.sprite_layer_write = 7; }
                                                            case 4h8: { upper_sprites.sprite_writer_sprite = stackNext; }
                                                            case 4h9: { upper_sprites.sprite_writer_line = stackNext; }
                                                            case 4ha: { upper_sprites.sprite_writer_bitmap = stackNext; upper_sprites.sprite_writer_active = 1; }
                                                            case 4he: { upper_sprites.sprite_update = stackNext; upper_sprites.sprite_layer_write = 10; }
                                                        }
                                                    }
                                                    case 4h5: {
                                                        switch( stackTop[0,4] ) {
                                                            // ff50 -
                                                            case 4h1: { lower_sprites.sprite_palette_1 = stackNext; }
                                                            case 4h2: { lower_sprites.sprite_palette_2 = stackNext; }
                                                            case 4h3: { lower_sprites.sprite_palette_3 = stackNext; }
                                                            case 4h4: { lower_sprites.sprite_palette_4 = stackNext; }
                                                            case 4h5: { lower_sprites.sprite_palette_5 = stackNext; }
                                                            case 4h6: { lower_sprites.sprite_palette_6 = stackNext; }
                                                            case 4h7: { lower_sprites.sprite_palette_7 = stackNext; }
                                                            case 4h8: { lower_sprites.sprite_palette_8 = stackNext; }
                                                            case 4h9: { lower_sprites.sprite_palette_9 = stackNext; }
                                                            case 4ha: { lower_sprites.sprite_palette_10 = stackNext; }
                                                            case 4hb: { lower_sprites.sprite_palette_11 = stackNext; }
                                                            case 4hc: { lower_sprites.sprite_palette_12 = stackNext; }
                                                            case 4hd: { lower_sprites.sprite_palette_13 = stackNext; }
                                                            case 4he: { lower_sprites.sprite_palette_14 = stackNext; }
                                                            case 4hf: { lower_sprites.sprite_palette_15 = stackNext; }
                                                        }
                                                    }
                                                    case 4h6: {
                                                        switch( stackTop[0,4] ) {
                                                            // ff60 -
                                                            case 4h1: { upper_sprites.sprite_palette_1 = stackNext; }
                                                            case 4h2: { upper_sprites.sprite_palette_2 = stackNext; }
                                                            case 4h3: { upper_sprites.sprite_palette_3 = stackNext; }
                                                            case 4h4: { upper_sprites.sprite_palette_4 = stackNext; }
                                                            case 4h5: { upper_sprites.sprite_palette_5 = stackNext; }
                                                            case 4h6: { upper_sprites.sprite_palette_6 = stackNext; }
                                                            case 4h7: { upper_sprites.sprite_palette_7 = stackNext; }
                                                            case 4h8: { upper_sprites.sprite_palette_8 = stackNext; }
                                                            case 4h9: { upper_sprites.sprite_palette_9 = stackNext; }
                                                            case 4ha: { upper_sprites.sprite_palette_10 = stackNext; }
                                                            case 4hb: { upper_sprites.sprite_palette_11 = stackNext; }
                                                            case 4hc: { upper_sprites.sprite_palette_12 = stackNext; }
                                                            case 4hd: { upper_sprites.sprite_palette_13 = stackNext; }
                                                            case 4he: { upper_sprites.sprite_palette_14 = stackNext; }
                                                            case 4hf: { upper_sprites.sprite_palette_15 = stackNext; }
                                                        }
                                                    }
                                                    case 4h7: {
                                                        switch( stackTop[0,4] ) {
                                                            // ff70 -
                                                            case 4h0: { vector_drawer.vector_block_number = stackNext; }
                                                            case 4h1: { vector_drawer.vector_block_colour = stackNext; }
                                                            case 4h2: { vector_drawer.vector_block_xc = stackNext; }
                                                            case 4h3: { vector_drawer.vector_block_yc = stackNext; }
                                                            case 4h4: { vector_drawer.draw_vector = 1; }
                                                            case 4h5: { vector_drawer.vertices_writer_block = stackNext; }
                                                            case 4h6: { vector_drawer.vertices_writer_vertex = stackNext; }
                                                            case 4h7: { vector_drawer.vertices_writer_xdelta = stackNext; }
                                                            case 4h8: { vector_drawer.vertices_writer_ydelta = stackNext; }
                                                            case 4h9: { vector_drawer.vertices_writer_active = stackNext; }
                                                            case 4ha: { vector_drawer.vertices_writer_write = 1; }
                                                        }
                                                    }
                                                    case 4h8: {
                                                        switch( stackTop[0,4] ) {
                                                            // ff80 -
                                                            case 4h0: { displaylist_drawer.start_entry = stackNext; }
                                                            case 4h1: { displaylist_drawer.finish_entry = stackNext; }
                                                            case 4h2: { displaylist_drawer.start_displaylist = 1; }
                                                            case 4h3: { displaylist_drawer.writer_entry_number = stackNext; }
                                                            case 4h4: { displaylist_drawer.writer_active = stackNext; }
                                                            case 4h5: { displaylist_drawer.writer_command = stackNext; }
                                                            case 4h6: { displaylist_drawer.writer_colour = stackNext; }
                                                            case 4h7: { displaylist_drawer.writer_x = stackNext; }
                                                            case 4h8: { displaylist_drawer.writer_y = stackNext; }
                                                            case 4h9: { displaylist_drawer.writer_p0 = stackNext; }
                                                            case 4ha: { displaylist_drawer.writer_p1 = stackNext; }
                                                            case 4hb: { displaylist_drawer.writer_p2 = stackNext; }
                                                            case 4hc: { displaylist_drawer.writer_p3 = stackNext; }
                                                            case 4hd: { displaylist_drawer.writer_write = stackNext; }
                                                        }
                                                    }
                                                    case 4h9: {
                                                        switch( stackTop[0,4] ) {
                                                            // ff90 -
                                                            case 4h0: { tile_map.tm_x = stackNext; }
                                                            case 4h1: { tile_map.tm_y = stackNext; }
                                                            case 4h2: { tile_map.tm_character = stackNext; }
                                                            case 4h3: { tile_map.tm_background = stackNext; }
                                                            case 4h4: { tile_map.tm_foreground = stackNext; }
                                                            case 4h5: { tile_map.tm_write = 1; }
                                                            case 4h6: { tile_map.tile_writer_tile = stackNext; }
                                                            case 4h7: { tile_map.tile_writer_line = stackNext; }
                                                            case 4h8: { tile_map.tile_writer_bitmap = stackNext; tile_map.tile_writer_write = 1; }
                                                            case 4h9: { tile_map.tm_scrollwrap = stackNext; }
                                                        }
                                                    }
                                                    case 4ha: {
                                                        switch( stackTop[0,4] ) {
                                                            case 4h0:  {doperations.operand1h = stackNext; }
                                                            case 4h1: { doperations.operand1l = stackNext; }
                                                            case 4h2: { doperations.operand2h = stackNext; }
                                                            case 4h3: { doperations.operand2l = stackNext; }
                                                        }
                                                    }
                                                    case 4hd: {
                                                        switch( stackTop[0,4] ) {
                                                            case 4h0: { divmod32by16to16qr.dividendh = stackNext; }
                                                            case 4h1: { divmod32by16to16qr.dividendl = stackNext; }
                                                            case 4h2: { divmod32by16to16qr.divisor = stackNext; }
                                                            case 4h3: { divmod32by16to16qr.start = stackNext; }
                                                            case 4h4: { divmod16by16to16qr.dividend = stackNext; }
                                                            case 4h5: { divmod16by16to16qr.divisor = stackNext; }
                                                            case 4h6: { divmod16by16to16qr.start = stackNext; }
                                                            case 4h7: { multiplier16by16to32.factor1 = stackNext; }
                                                            case 4h8: { multiplier16by16to32.factor2 = stackNext; }
                                                            case 4h9: { multiplier16by16to32.start = stackNext; }
                                                        }
                                                    }
                                                    case 4he: {
                                                        switch( stackTop[0,4] ) {
                                                            // ffe0 -
                                                            case 4h0: { apu_processor_L.waveform = stackNext; }
                                                            case 4h1: { apu_processor_L.note = stackNext; }
                                                            case 4h2: { apu_processor_L.duration = stackNext; }
                                                            case 4h3: { apu_processor_L.apu_write = stackNext; }
                                                            case 4h4: { apu_processor_R.waveform = stackNext; }
                                                            case 4h5: { apu_processor_R.note = stackNext; }
                                                            case 4h6: { apu_processor_R.duration = stackNext; }
                                                            case 4h7: { apu_processor_R.apu_write = stackNext; }
                                                            case 4h8: { rng.resetRandom = 1; }
                                                            case 4hd: { timer1hz.resetCounter = 1; }
                                                            case 4he: { timer1khz.resetCount = stackNext; timer1khz.resetCounter = 1; }
                                                            case 4hf: { sleepTimer.resetCount = stackNext; sleepTimer.resetCounter = 1; }
                                                        }
                                                    }
                                                    case 4hf: {
                                                        switch( stackTop[0,4] ) {
                                                            // fff0 -
                                                            case 4h0: { background_generator.backgroundcolour = stackNext; background_generator.background_write = 1; }
                                                            case 4h1: { background_generator.backgroundcolour_alt = stackNext; background_generator.background_write = 2; }
                                                            case 4h2: { background_generator.backgroundcolour_mode = stackNext; background_generator.background_write = 3; }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    default: {
                                        // WRITE to RAM
                                        ram_0.wenable0 = ( stackTop < 16384 );
                                        ram_1.wenable0 = ( stackTop > 16383 ) && ( stackTop < 32768 );
                                    }
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

            case 3: {
                // RESET Co-Processor Controls
                background_generator.background_write = 0;
                tile_map.tile_writer_write = 0;
                tile_map.tm_write = 0;
                tile_map.tm_scrollwrap = 0;
                lower_sprites.sprite_layer_write = 0;
                lower_sprites.sprite_writer_active = 0;
                gpu_processor.gpu_write = 0;
                gpu_processor.blit1_writer_active = 0;
                upper_sprites.sprite_layer_write = 0;
                upper_sprites.sprite_writer_active = 0;
                character_map_window.tpu_write = 0;
                terminal_window.terminal_write = 0;
                vector_drawer.draw_vector = 0;
                vector_drawer.vertices_writer_write = 0;
                displaylist_drawer.start_displaylist = 0;
                displaylist_drawer.writer_write = 0;
                apu_processor_L.apu_write = 0;
                apu_processor_R.apu_write = 0;
                p1hz.resetCounter = 0;
                sleepTimer.resetCounter = 0;
                timer1hz.resetCounter = 0;
                timer1khz.resetCounter = 0;
                rng.resetRandom = 0;
            }
        } // switch(CYCLE)

        // Move to next CYCLE ( 0 to 3 , then back to 0 )
        CYCLE = ( CYCLE == 3 ) ? 0 : CYCLE + 1;
    } // execute J1 CPU
}
