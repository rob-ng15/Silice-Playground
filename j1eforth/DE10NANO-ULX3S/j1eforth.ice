// 10 bit colour either ALPHA (background or lower layer) or red, green, blue { Arrggbb }
bitfield colour7 {
    uint1   alpha,
    uint2   red,
    uint2   green, 
    uint2   blue
}

// 9bit colour red, green, blue { rrggbb }
bitfield colour6 {
    uint2   red,
    uint2   green, 
    uint2   blue
}

algorithm multiplex_display(
    input   uint10 pix_x,
    input   uint10 pix_y,
    input   uint1  pix_active,
    input   uint1  pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,

    // BACKGROUND
    input uint$color_depth$ background_r,
    input uint$color_depth$ background_g,
    input uint$color_depth$ background_b,

    // LOWER SPRITES
    input uint$color_depth$ lower_sprites_r,
    input uint$color_depth$ lower_sprites_g,
    input uint$color_depth$ lower_sprites_b,
    input uint1   lower_sprites_display,

    // BITMAP
    input uint$color_depth$ bitmap_r,
    input uint$color_depth$ bitmap_g,
    input uint$color_depth$ bitmap_b,
    input uint1   bitmap_display,

    // UPPER SPRITES
    input uint$color_depth$ upper_sprites_r,
    input uint$color_depth$ upper_sprites_g,
    input uint$color_depth$ upper_sprites_b,
    input uint1   upper_sprites_display,

    // CHARACTER MAP
    input uint$color_depth$ character_map_r,
    input uint$color_depth$ character_map_g,
    input uint$color_depth$ character_map_b,
    input uint1   character_map_display,
    
    // TERMINAL
    input uint$color_depth$ terminal_r,
    input uint$color_depth$ terminal_g,
    input uint$color_depth$ terminal_b,
    input uint1   terminal_display
) <autorun> {
    // RGB is { 0, 0, 0 } by default
    pix_red   := 0;
    pix_green := 0;
    pix_blue  := 0;
        
    // Draw the screen
    while (1) {        
        if( pix_active ) {
            // wait until pix_active THEN BACKGROUND -> LOWER SPRITES -> BITMAP -> UPPER SPRITES -> CHARACTER MAP -> TERMINAL
            pix_red = ( terminal_display ) ? terminal_r : ( character_map_display ) ? character_map_r : ( upper_sprites_display ) ? upper_sprites_r : ( bitmap_display ) ? bitmap_r : ( lower_sprites_display ) ? lower_sprites_r : background_r;
            pix_green = ( terminal_display ) ? terminal_g : ( character_map_display ) ? character_map_g : ( upper_sprites_display ) ? upper_sprites_g : ( bitmap_display ) ? bitmap_g : ( lower_sprites_display ) ? lower_sprites_g : background_g;
            pix_blue = ( terminal_display ) ? terminal_b : ( character_map_display ) ? character_map_b : ( upper_sprites_display ) ? upper_sprites_b : ( bitmap_display ) ? bitmap_b : ( lower_sprites_display ) ? lower_sprites_b : background_b;
        } // pix_active
    }
}

// J1+ CPU Starts here
// BITFIELDS to help with bit/field access

// Instruction is 3 bits 1xx = literal value, 000 = branch, 001 = 0branch, 010 = call, 011 = alu, followed by 13 bits of instruction specific data
bitfield instruction {
    uint3 is_litcallbranchalu,
    uint13 padding
}

// A literal instruction is 1 followed by a 15 bit UNSIGNED literal value
bitfield literal {
    uint1  is_literal,
    uint15 literalvalue
}

// A branch, 0branch or call instruction is 0 followed by 00 = branch, 01 = 0branch, 10 = call followed by 13bit target address 
bitfield callbranch {
    uint1  is_literal,
    uint2  is_callbranchalu,
    uint13 address
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

// Create 1hz (1 second counter, also can output the baseline 50MHz counter)
algorithm pulse1hz(
    output uint32 counter50mhz,
    output uint16 counter1hz,
    input  uint1  resetCounter
) <autorun> {
    counter50mhz = 0;
    counter1hz = 0;
    
    while (1) {
        counter1hz = ( resetCounter == 1 ) ? 0 : ( counter50mhz == 50000000 ) ? counter1hz + 1 : counter1hz;
        counter50mhz = ( resetCounter == 1 ) ? 0 : ( counter50mhz == 50000000 ) ? 0 : counter50mhz + 1;
    }
}

// Create 1khz (1 milli-second counter)
algorithm pulse1khz(
    output uint16 counter1khz,
    input  uint16 resetCount,
    input  uint1  resetCounter
) <autorun> {
    uint32 counter50mhz = 0;
    
    while (1) {
        counter1khz = ( resetCounter == 1 ) ? resetCount : ( counter1khz == 0 ) ? 0 : ( counter50mhz == 50000 ) ? counter1khz - 1 : counter1khz;
        counter50mhz = ( resetCounter == 1 ) ? 0 : ( counter50mhz == 50000 ) ? 0 : counter50mhz + 1;
    }
}

algorithm main(
    // LEDS (8 of)
    output  uint8          leds,
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
    output! uint$color_depth$ video_r,
    output! uint$color_depth$ video_g,
    output! uint$color_depth$ video_b,
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
    uint1 video_reset = uninitialized;
    uint1 video_clock = uninitialized;
    uint1 pll_lock = uninitialized;
    
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
    uint1  active = uninitialized;
    uint1  vblank = uninitialized;
    uint10 pix_x  = uninitialized;
    uint10 pix_y  = uninitialized;

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
    // Adjust 6 biut rgb to 8 bit rgb for HDMI output
    uint8 video_r8 := video_r << 2;
    uint8 video_g8 := video_g << 2;
    uint8 video_b8 := video_b << 2;

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
    uint$color_depth$   background_r = uninitialized;
    uint$color_depth$   background_g = uninitialized;
    uint$color_depth$   background_b = uninitialized;
    background background_generator <@video_clock,!video_reset>  (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> background_r,
        pix_green  :> background_g,
        pix_blue   :> background_b,
    );

    // Lower Sprite Layer - Between BACKGROUND and BITMAP
    uint$color_depth$   lower_sprites_r = uninitialized;
    uint$color_depth$   lower_sprites_g = uninitialized;
    uint$color_depth$   lower_sprites_b = uninitialized;
    uint1               lower_sprites_display = uninitialized;
    
    sprite_layer lower_sprites <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> lower_sprites_r,
        pix_green  :> lower_sprites_g,
        pix_blue   :> lower_sprites_b,
        sprite_layer_display :> lower_sprites_display
    );
        
    // Bitmap Window
    uint$color_depth$   bitmap_r = uninitialized;
    uint$color_depth$   bitmap_g = uninitialized;
    uint$color_depth$   bitmap_b = uninitialized;
    // From GPU to set a pixel
    uint1               bitmap_display = uninitialized;
    int11               bitmap_x_write = uninitialized;
    int11               bitmap_y_write = uninitialized;
    uint7               bitmap_colour_write = uninitialized;
    uint2               bitmap_write = uninitialized;
    uint3               bitmapcolour_fade = uninitialized;
    
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
        bitmapcolour_fade <: bitmapcolour_fade,
        bitmap_write <: bitmap_write
    );

    // Upper Sprite Layer - Between BITMAP and CHARACTER MAP
    uint$color_depth$   upper_sprites_r = uninitialized;
    uint$color_depth$   upper_sprites_g = uninitialized;
    uint$color_depth$   upper_sprites_b = uninitialized;
    uint1               upper_sprites_display = uninitialized;
    
    sprite_layer upper_sprites <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> upper_sprites_r,
        pix_green  :> upper_sprites_g,
        pix_blue   :> upper_sprites_b,
        sprite_layer_display :> upper_sprites_display
    );
        
    // Character Map Window
    uint$color_depth$   character_map_r = uninitialized;
    uint$color_depth$   character_map_g = uninitialized;
    uint$color_depth$   character_map_b = uninitialized;
    uint1               character_map_display = uninitialized;
    
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
    uint$color_depth$   terminal_r = uninitialized;
    uint$color_depth$   terminal_g = uninitialized;
    uint$color_depth$   terminal_b = uninitialized;
    uint1               terminal_display = uninitialized;
    
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
        audio_output :> audio_l,
    );
    apu apu_processor_R <@video_clock,!video_reset> (
        audio_output :> audio_r,
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
    uint4   dl_gpu_write = uninitialized;
    uint5   dl_vector_block_number = uninitialized;
    uint7   dl_vector_block_colour = uninitialized;
    int11   dl_vector_block_xc = uninitialized;
    int11   dl_vector_block_yc =uninitialized;
    uint1   dl_draw_vector = uninitialized;   
    // Status flags
    uint3   vector_block_active = uninitialized;
    uint4   gpu_active = uninitialized;

    gpu gpu_processor <@video_clock,!video_reset> (
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_colour_write :> bitmap_colour_write,
        bitmapcolour_fade :> bitmapcolour_fade,
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
        dl_gpu_param1 <: dl_gpu_param1,
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
        gpu_write :> dl_gpu_write,
        vector_block_number :> dl_vector_block_number,
        vector_block_colour :> dl_vector_block_colour,
        vector_block_xc :> dl_vector_block_xc,
        vector_block_yc :> dl_vector_block_yc,
        draw_vector :> dl_draw_vector,
        vector_block_active <: vector_block_active,
        gpu_active <: gpu_active
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
    bram uint16 dstack[256] = uninitialized; // bram (code from @sylefeb)
    uint16  stackTop = 0;
    uint8   dsp = 0;
    uint8   newDSP = uninitialized;
    uint16  newStackTop = uninitialized;

    // rstack 256x16bit and pointer, next pointer, write line
    bram uint16 rstack[256] = uninitialized; // bram (code from @sylefeb)
    uint8   rsp = 0;
    uint8   newRSP = uninitialized;
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
    uint3 CYCLE = 0;
    
    // UART input FIFO (4096 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 uartInBuffer[4096] = uninitialized;
    uint13 uartInBufferNext = 0;
    uint13 uartInBufferTop = 0;

    // UART output FIFO (512 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 uartOutBuffer[512] = uninitialized;
    uint9 uartOutBufferNext = 0;
    uint9 uartOutBufferTop = 0;
    uint9 newuartOutBufferTop = 0;
    
    // register buttons
    uint$NUM_BTNS$ reg_btns = 0;

    reg_btns ::= btns;

    // BRAM for CPU ram write enable mainained low, pulsed high
    ram_0.wenable0 := 0;
    ram_0.wenable1 := 0;
    ram_1.wenable0 := 0;
    ram_1.wenable1 := 0;

    // bram for dstack and rstack write enable, maintained low, pulsed high (code from @sylefeb)
    dstack.wenable         := 0;  
    rstack.wenable         := 0;

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
                // read dtsack and rstack brams (code from @sylefeb)
                stackNext = dstack.rdata;
                rStackTop = rstack.rdata;
            
                // start READ memoryInput = [stackTop] and instruction = [pc] result ready in 1 cycles
                // PC can only ever be 0 - 8191
                ram_0.addr1 = pc;
                // stackTop could be 0 - 32767 with WORD level access
                ram_0.addr0 = stackTop >> 1;
                ram_1.addr0 = stackTop >> 1;
            }
            case 1: {
                // wait then read the data from RAM
                instruction = ram_0.rdata1;
                memoryInput = ( stackTop > 16383 ) ? ram_1.rdata0 : ram_0.rdata0;
            }
            
            // J1 CPU Instruction Execute
            case 2: {
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
                                            // UART or memoryInput
                                            switch( stackTop ) {
                                                // INPUT from UART reads at uartInBufferNext (code from @sylefeb)
                                                // UART status register { 14b0, tx full, rx available }
                                                case 16hf000: { newStackTop = { 8b0, uartInBuffer.rdata0 }; uartInBufferNext = uartInBufferNext + 1; } 
                                                case 16hf001: { newStackTop = {14b0, ( uartOutBufferTop + 1 == uartOutBufferNext ), ( uartInBufferNext != uartInBufferTop )}; }
                                                
                                                // LED status
                                                case 16hf002: { newStackTop = leds; }
                                                
                                                // BUTTONS
                                                case 16hf003: { newStackTop = {$16-NUM_BTNS$b0, reg_btns[0,$NUM_BTNS$]}; }
                                                
                                                // GPU Active Status
                                                case 16hff07: { newStackTop = gpu_processor.gpu_active; }
                                                
                                                // Read BITMAP pixel
                                                case 16hff08: { newStackTop = bitmap_window.bitmap_colour_read; }
                                                
                                                // Terminal Active Status
                                                case 16hff20: { newStackTop = terminal_window.terminal_active; }
                                                
                                                // LOWER SPRITES READ
                                                case 16hff31: { newStackTop = lower_sprites.sprite_read_active; }
                                                case 16hff32: { newStackTop = lower_sprites.sprite_read_tile; }
                                                case 16hff33: { newStackTop = lower_sprites.sprite_read_colour; }
                                                case 16hff34: { newStackTop = lower_sprites.sprite_read_x; }
                                                case 16hff35: { newStackTop = lower_sprites.sprite_read_y; }
                                                case 16hff39: { newStackTop = lower_sprites.sprites_at_xy; }
                                                
                                                // UPPER SPRITES READ
                                                case 16hff41: { newStackTop = upper_sprites.sprite_read_active; }
                                                case 16hff42: { newStackTop = upper_sprites.sprite_read_tile; }
                                                case 16hff43: { newStackTop = upper_sprites.sprite_read_colour; }
                                                case 16hff44: { newStackTop = upper_sprites.sprite_read_x; }
                                                case 16hff45: { newStackTop = upper_sprites.sprite_read_y; }
                                                case 16hff49: { newStackTop = upper_sprites.sprites_at_xy; }
                                                
                                                // VECTORS
                                                case 16hff74: { newStackTop = vector_drawer.vector_block_active; }

                                                // DISPLATY LIST
                                                case 16hff82: { newStackTop = displaylist_drawer.display_list_active; }
                                                
                                                // AUDIO
                                                case 16hffe3: { newStackTop = apu_processor_L.selected_duration; }
                                                case 16hffe7: { newStackTop = apu_processor_R.selected_duration; }
                                                
                                                // TIMERS
                                                case 16hf004: { newStackTop = systemClock; }
                                                case 16hffed: { newStackTop = timer1hz.counter1hz; }
                                                case 16hffee: { newStackTop = timer1khz.counter1khz; }
                                                case 16hffef: { newStackTop = sleepTimer.counter1khz; }
                                                
                                                // VBLANK status
                                                case 16hffff: { newStackTop = vblank; }
                                                
                                                // MEMORY
                                                default: {newStackTop = memoryInput;}
                                            }
                                        }
                                        case 4b1101: {newStackTop = stackNext << nibbles(stackTop).nibble0;}
                                        case 4b1110: {newStackTop = {rsp, dsp};}
                                        case 4b1111: {newStackTop = {16{(__unsigned(stackNext) < __unsigned(stackTop))}};}
                                    }
                                }
                                
                                case 1b1: {
                                    switch( aluop(instruction).operation ) {
                                        case 4b0000: {newStackTop = {16{(stackTop == 0)}};}
                                        case 4b0001: {newStackTop = ~{16{(stackTop == 0)}};}
                                        case 4b0010: {newStackTop = ~{16{(stackNext == stackTop)}};}
                                        case 4b0011: {newStackTop = stackTop + 1;}
                                        case 4b0100: {newStackTop = stackTop << 1;}
                                        case 4b0101: {newStackTop = stackTop >> 1;}
                                        case 4b0110: {newStackTop = {16{(__signed(stackNext) > __signed(stackTop))}};}
                                        case 4b0111: {newStackTop = {16{(__unsigned(stackNext) > __unsigned(stackTop))}};}
                                        case 4b1000: {newStackTop = {16{(__signed(stackTop) < __signed(0))}};}
                                        case 4b1001: {newStackTop = {16{(__signed(stackTop) > __signed(0))}};}
                                        case 4b1010: {newStackTop = ( __signed(stackTop) < __signed(0) ) ?  - stackTop : stackTop;}
                                        case 4b1011: {newStackTop = ( __signed(stackNext) > __signed(stackTop) ) ? stackNext : stackTop;}
                                        case 4b1100: {newStackTop = ( __signed(stackNext) < __signed(stackTop) ) ? stackNext : stackTop;}
                                        case 4b1101: {newStackTop = -stackTop;}
                                        case 4b1110: {newStackTop = stackNext - stackTop;}
                                        case 4b1111: {newStackTop = {16{(__signed(stackNext) >= __signed(stackTop))}};}
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
                                switch( stackTop ) {
                                    default: {
                                        // WRITE to SPRAM
                                        if( stackTop > 16383 ) {
                                            ram_1.addr0 = stackTop >> 1;
                                            ram_1.wdata0 = stackNext;
                                            ram_1.wenable0 = 1;
                                        } else {
                                            ram_0.addr0 = stackTop >> 1;
                                            ram_0.wdata0 = stackNext;
                                            ram_0.wenable0 = 1;
                                       }
                                    }
                                    // UART output
                                    case 16hf000: { uartOutBuffer.wdata1 = bytes(stackNext).byte0; newuartOutBufferTop = uartOutBufferTop + 1; }
                                    
                                    // LED set
                                    case 16hf002: { leds = stackNext; }
                                    
                                    // GPU Controls and BITMAP reader
                                    case 16hff00: { gpu_processor.gpu_x = stackNext; }
                                    case 16hff01: { gpu_processor.gpu_y = stackNext; }
                                    case 16hff02: { gpu_processor.gpu_colour = stackNext; }
                                    case 16hff03: { gpu_processor.gpu_param0 = stackNext; }
                                    case 16hff04: { gpu_processor.gpu_param1 = stackNext; }
                                    case 16hff05: { gpu_processor.gpu_param2 = stackNext; }
                                    case 16hff06: { gpu_processor.gpu_param3 = stackNext; }
                                    case 16hff07: { gpu_processor.gpu_write = stackNext; }
                                    case 16hff09: { bitmap_window.bitmap_x_read = stackNext; }
                                    case 16hff0a: { bitmap_window.bitmap_y_read = stackNext; }
                                    case 16hff0f: { gpu_processor.gpu_param0 = stackNext; gpu_processor.gpu_write = 7; }
                                    
                                    // TPU Controls
                                    case 16hff10: { character_map_window.tpu_x = stackNext; }
                                    case 16hff11: { character_map_window.tpu_y = stackNext; }
                                    case 16hff12: { character_map_window.tpu_character = stackNext; }
                                    case 16hff13: { character_map_window.tpu_background = stackNext; }
                                    case 16hff14: { character_map_window.tpu_foreground = stackNext; }
                                    case 16hff15: { character_map_window.tpu_write = stackNext; }
                                    
                                    // TERMINAL Output + SHOW/HIDE
                                    case 16hff20: { terminal_window.terminal_character = stackNext; terminal_window.terminal_write = 1; }
                                    case 16hff21: { terminal_window.showterminal = stackNext; }
                                    
                                    // LOWER SPRITE LAYER CONTROLS
                                    case 16hff30: { lower_sprites.sprite_set_number = stackNext; }
                                    case 16hff31: { lower_sprites.sprite_set_active = stackNext; lower_sprites.sprite_layer_write = 1; }
                                    case 16hff32: { lower_sprites.sprite_set_tile = stackNext; lower_sprites.sprite_layer_write = 2; }
                                    case 16hff33: { lower_sprites.sprite_set_colour = stackNext; lower_sprites.sprite_layer_write = 3; }
                                    case 16hff34: { lower_sprites.sprite_set_x = stackNext; lower_sprites.sprite_layer_write = 4; }
                                    case 16hff35: { lower_sprites.sprite_set_y = stackNext; lower_sprites.sprite_layer_write = 5; }
                                    case 16hff36: { lower_sprites.sprite_writer_sprite = stackNext; }
                                    case 16hff37: { lower_sprites.sprite_writer_line = stackNext; }
                                    case 16hff38: { lower_sprites.sprite_writer_bitmap = stackNext; lower_sprites.sprite_writer_active = 1; }
                                    case 16hff3a: { lower_sprites.sprites_at_x = stackNext; }
                                    case 16hff3b: { lower_sprites.sprites_at_y = stackNext; }
                                    case 16hff3c: { lower_sprites.sprite_update = stackNext; lower_sprites.sprite_layer_write = 10; }
                                    case 16hff3f: { lower_sprites.sprite_layer_fade = stackNext; lower_sprites.sprite_layer_write = 9; }
                                    
                                    // UPPER SPRITE LAYER CONTROLS
                                    case 16hff40: { upper_sprites.sprite_set_number = stackNext; }
                                    case 16hff41: { upper_sprites.sprite_set_active = stackNext; upper_sprites.sprite_layer_write = 1; }
                                    case 16hff42: { upper_sprites.sprite_set_tile = stackNext; upper_sprites.sprite_layer_write = 2; }
                                    case 16hff43: { upper_sprites.sprite_set_colour = stackNext; upper_sprites.sprite_layer_write = 3; }
                                    case 16hff44: { upper_sprites.sprite_set_x = stackNext; upper_sprites.sprite_layer_write = 4; }
                                    case 16hff45: { upper_sprites.sprite_set_y = stackNext; upper_sprites.sprite_layer_write = 5; }
                                    case 16hff46: { upper_sprites.sprite_writer_sprite = stackNext; }
                                    case 16hff47: { upper_sprites.sprite_writer_line = stackNext; }
                                    case 16hff48: { upper_sprites.sprite_writer_bitmap = stackNext; upper_sprites.sprite_writer_active = 1; }
                                    case 16hff4a: { upper_sprites.sprites_at_x = stackNext; }
                                    case 16hff4b: { upper_sprites.sprites_at_y = stackNext; }
                                    case 16hff4c: { upper_sprites.sprite_update = stackNext; upper_sprites.sprite_layer_write = 10; }
                                    case 16hff4f: { upper_sprites.sprite_layer_fade = stackNext; upper_sprites.sprite_layer_write = 9; }
                                    
                                    // VECTOR DRAWER
                                    case 16hff70: { vector_drawer.vector_block_number = stackNext; }
                                    case 16hff71: { vector_drawer.vector_block_colour = stackNext; }
                                    case 16hff72: { vector_drawer.vector_block_xc = stackNext; }
                                    case 16hff73: { vector_drawer.vector_block_yc = stackNext; }
                                    case 16hff74: { vector_drawer.draw_vector = 1; }
                                    case 16hff75: { vector_drawer.vertices_writer_block = stackNext; }
                                    case 16hff76: { vector_drawer.vertices_writer_vertex = stackNext; }
                                    case 16hff77: { vector_drawer.vertices_writer_xdelta = stackNext; }
                                    case 16hff78: { vector_drawer.vertices_writer_ydelta = stackNext; }
                                    case 16hff79: { vector_drawer.vertices_writer_active = stackNext; }
                                    case 16hff7a: { vector_drawer.vertices_writer_write = 1; }

                                    // DISPLAY LIST
                                    case 16hff80: { displaylist_drawer.start_entry = stackNext; }
                                    case 16hff81: { displaylist_drawer.finish_entry = stackNext; }
                                    case 16hff82: { displaylist_drawer.start_displaylist = 1; }
                                    case 16hff83: { displaylist_drawer.writer_entry_number = stackNext; }
                                    case 16hff84: { displaylist_drawer.writer_active = stackNext; }
                                    case 16hff85: { displaylist_drawer.writer_command = stackNext; }
                                    case 16hff86: { displaylist_drawer.writer_colour = stackNext; }
                                    case 16hff87: { displaylist_drawer.writer_x = stackNext; }
                                    case 16hff88: { displaylist_drawer.writer_y = stackNext; }
                                    case 16hff89: { displaylist_drawer.writer_p0 = stackNext; }
                                    case 16hff8a: { displaylist_drawer.writer_p1 = stackNext; }
                                    case 16hff8b: { displaylist_drawer.writer_write = stackNext; }

                                    // APU
                                    case 16hffe0: { apu_processor_L.waveform = stackNext; }
                                    case 16hffe1: { apu_processor_L.note = stackNext; }
                                    case 16hffe2: { apu_processor_L.duration = stackNext; }
                                    case 16hffe3: { apu_processor_L.apu_write = 1; }
                                    case 16hffe4: { apu_processor_R.waveform = stackNext; }
                                    case 16hffe5: { apu_processor_R.note = stackNext; }
                                    case 16hffe6: { apu_processor_R.duration = stackNext; }
                                    case 16hffe7: { apu_processor_R.apu_write = 1; }

                                    // TIMERS
                                    case 16hffed: { timer1hz.resetCounter = 1; }
                                    case 16hffee: { timer1khz.resetCount = stackNext; timer1khz.resetCounter = 1; }
                                    case 16hffef: { sleepTimer.resetCount = stackNext; sleepTimer.resetCounter = 1; }
                                    
                                    // BACKGROUND Controls
                                    case 16hfff0: { background_generator.backgroundcolour = stackNext; background_generator.backgroundcolour_write = 1; }
                                    case 16hfff1: { background_generator.backgroundcolour_alt = stackNext; background_generator.backgroundcolour_write = 2; }
                                    case 16hfff2: { background_generator.backgroundcolour_mode = stackNext; background_generator.backgroundcolour_write = 3; }
                                    case 16hffff: { background_generator.backgroundcolour_fade = stackNext; background_generator.backgroundcolour_write = 4; }
                               }
                            }
                        } // ALU
                    }
                }
            } // J1 CPU Instruction Execute

            // update pc and perform mem[t] = n
            case 3: {
                // Write to dstack and rstack
                if( dstackWrite ) {
                    // bram code for dstack (code from @sylefeb)
                    dstack.wenable = 1;
                    dstack.addr    = newDSP;
                    dstack.wdata   = stackTop;
                }
                if( rstackWrite ) {
                    // bram code for rstack (code from @sylefeb)
                    rstack.wenable = 1;
                    rstack.addr    = newRSP;
                    rstack.wdata   = rstackWData;
                }
            }
            
            // Update dsp, rsp, pc, stackTop
            case 4: {
                dsp = newDSP;
                pc = newPC;
                stackTop = newStackTop;
                rsp = newRSP;
                
                // Setup addresses for dstack and rstack brams (code from @sylefeb)
                dstack.addr = newDSP;
                rstack.addr = newRSP;
            
                // RESET BACKGROUND, LOWER SPRITE LAYER, BITMAP, UPPER SPRITE LAYER, CHARACTER MAP and TERMINAL controls
                background_generator.backgroundcolour_write = 0;
                lower_sprites.sprite_layer_write = 0;
                lower_sprites.sprite_writer_active = 0;
                gpu_processor.gpu_write = 0;
                character_map_window.tpu_write = 0;
                upper_sprites.sprite_layer_write = 0;
                upper_sprites.sprite_writer_active = 0;
                terminal_window.terminal_write = 0;
                
                // RESET VECTOR controls
                vector_drawer.draw_vector = 0;
                vector_drawer.vertices_writer_write = 0;

                // RESET DISPLAY LIST controls
                displaylist_drawer.start_displaylist = 0;
                displaylist_drawer.writer_write = 0;
                
                // RESET AUDIO controls
                apu_processor_L.apu_write = 0;
                apu_processor_R.apu_write = 0;
                
                // RESET TIMER controls
                p1hz.resetCounter = 0;
                sleepTimer.resetCounter = 0;
                timer1hz.resetCounter = 0;
                timer1khz.resetCounter = 0;
            }
            
            default: {}
        } // switch(CYCLE)
        
    
        // Move to next CYCLE ( 0 to 4 , then back to 0 )
        CYCLE = ( CYCLE == 4 ) ? 0 : CYCLE + 1;
    } // execute J1 CPU
}
