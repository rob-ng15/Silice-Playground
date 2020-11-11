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

algorithm memmap_io (
    // LEDS (8 of)
    output  uint8   leds,
    input   uint$NUM_BTNS$ btns,

    // UART
    output! uint1   uart_tx,
    input   uint1   uart_rx,

    // AUDIO
    output! uint4   audio_l,
    output! uint4   audio_r,

    // VGA/HDMI
    output! uint8   video_r,
    output! uint8   video_g,
    output! uint8   video_b,
    input   uint1   vblank,
    input   uint1   pix_active,
    input   uint10  pix_x,
    input   uint10  pix_y,

    // CLOCKS
    input   uint1   clock_50mhz,
    input   uint1   video_clock,
    input   uint1   video_reset,

    // Memory access
    input   uint16  memoryAddress,
    input   uint16  writeData,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,
    output! uint16  readData,
    input   uint1   resetCoPro
) <autorun> {
    // 1hz timers (p1hz used for systemClock, timer1hz for user purposes)
    uint16 systemClock = uninitialized;
    pulse1hz p1hz <@clock_50mhz,!reset> (
        counter1hz :> systemClock,
    );
    pulse1hz timer1hz <@clock_50mhz,!reset> ( );

    // 1khz timers (sleepTimer used for sleep command, timer1khz for user purposes)
    pulse1khz sleepTimer <@clock_50mhz,!reset> ( );
    pulse1khz timer1khz <@clock_50mhz,!reset> ( );

    // RNG random number generator
    uint16 staticGenerator = 0;
    random rng <@clock_50mhz,!reset> (
        g_noise_out :> staticGenerator
    );

    // UART tx and rx
    // UART written in Silice by https://github.com/sylefeb/Silice
    uart_out uo;
    uart_sender usend <@clock_50mhz,!reset> (
        io      <:> uo,
        uart_tx :>  uart_tx
    );
    uart_in ui;
    uart_receiver urecv <@clock_50mhz,!reset> (
        io      <:> ui,
        uart_rx <:  uart_rx
    );

    // CREATE DISPLAY LAYERS
    // BACKGROUND
    uint2   background_r = uninitialized;
    uint2   background_g = uninitialized;
    uint2   background_b = uninitialized;
    background background_generator <@video_clock,!video_reset>  (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
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
        pix_active <: pix_active,
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
        pix_active <: pix_active,
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
    // Upper Sprite Layer - Between BITMAP and CHARACTER MAP
    uint2   lower_sprites_r = uninitialized;
    uint2   lower_sprites_g = uninitialized;
    uint2   lower_sprites_b = uninitialized;
    uint1   lower_sprites_display = uninitialized;
    uint2   upper_sprites_r = uninitialized;
    uint2   upper_sprites_g = uninitialized;
    uint2   upper_sprites_b = uninitialized;
    uint1   upper_sprites_display = uninitialized;

    sprite_layer lower_sprites <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> lower_sprites_r,
        pix_green  :> lower_sprites_g,
        pix_blue   :> lower_sprites_b,
        sprite_layer_display :> lower_sprites_display,
        collision_layer_1 <: bitmap_display,
        collision_layer_2 <: tilemap_display,
        collision_layer_3 <: upper_sprites_display
    );

    sprite_layer upper_sprites <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> upper_sprites_r,
        pix_green  :> upper_sprites_g,
        pix_blue   :> upper_sprites_b,
        sprite_layer_display :> upper_sprites_display,
        collision_layer_1 <: bitmap_display,
        collision_layer_2 <: tilemap_display,
        collision_layer_3 <: lower_sprites_display
    );

    // Character Map Window
    uint2   character_map_r = uninitialized;
    uint2   character_map_g = uninitialized;
    uint2   character_map_b = uninitialized;
    uint1   character_map_display = uninitialized;

    character_map character_map_window <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
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
        pix_active <: pix_active,
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
        pix_active <: pix_active,
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

    // Mathematics Co-Processors
    divmod32by16 divmod32by16to16qr <@clock_50mhz,!reset> ();
    divmod16by16 divmod16by16to16qr <@clock_50mhz,!reset> ();
    multi16by16to32DSP multiplier16by16to32 <@clock_50mhz,!reset> ();
    doubleaddsub2input doperations2 <@clock_50mhz,!reset> ();
    doubleaddsub1input doperations1 <@clock_50mhz,!reset> ();

    // UART input FIFO (4096 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 uartInBuffer[4096] = uninitialized;
    uint13  uartInBufferNext = 0;
    uint13  uartInBufferTop = 0;

    // UART output FIFO (16 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 uartOutBuffer[256] = uninitialized;
    uint8   uartOutBufferNext = 0;
    uint8   uartOutBufferTop = 0;
    uint8   newuartOutBufferTop = 0;

    // Co-Processor reset counter
    uint2   coProReset = 0;

    // register buttons
    uint$NUM_BTNS$ reg_btns = 0;
    reg_btns ::= btns;

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

    // RESET Timer Co-Processor Controls
    p1hz.resetCounter := 0;
    sleepTimer.resetCounter := 0;
    timer1hz.resetCounter := 0;
    timer1khz.resetCounter := 0;
    rng.resetRandom := 0;

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

    while(1) {
        // Update UART output buffer top if character has been put into buffer
        uartOutBufferTop = newuartOutBufferTop;

        // READ IO Memory
        if( memoryRead ) {
            switch( memoryAddress[12,4] ) {
                case 4hf: {
                    switch( memoryAddress[8,4] ) {
                        case 4h0: {
                            switch( memoryAddress[0,4] ) {
                                // f000
                                case 4h0: { readData = { 8b0, uartInBuffer.rdata0 }; uartInBufferNext = uartInBufferNext + 1; }
                                case 4h1: { readData = { 14b0, ( uartOutBufferTop + 1 == uartOutBufferNext ), ( uartInBufferNext != uartInBufferTop )}; }
                                case 4h2: { readData = leds; }
                                case 4h3: { readData = {$16-NUM_BTNS$b0, reg_btns[0,$NUM_BTNS$]}; }
                                case 4h4: { readData = systemClock; }
                            }
                        }
                        case 4hf: {
                            switch( memoryAddress[4,4] ) {
                                case 4h0: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff00 -
                                        case 4h7: { readData = gpu_processor.gpu_active; }
                                        case 4h8: { readData = bitmap_window.bitmap_colour_read; }
                                    }
                                }
                                case 4h1: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff10 -
                                        case 4h5: { readData = character_map_window.tpu_active; }
                                    }
                                }
                                case 4h2: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff20 -
                                        case 4h0: { readData = terminal_window.terminal_active; }
                                    }
                                }
                                case 4h3: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff30 -
                                        case 4h1: { readData = lower_sprites.sprite_read_active; }
                                        case 4h2: { readData = lower_sprites.sprite_read_tile; }
                                        case 4h3: { readData = lower_sprites.sprite_read_colour; }
                                        case 4h4: { readData = lower_sprites.sprite_read_x; }
                                        case 4h5: { readData = lower_sprites.sprite_read_y; }
                                        case 4h6: { readData = lower_sprites.sprite_read_double; }
                                    }
                                }
                                case 4h4: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff40 -
                                        case 4h1: { readData = upper_sprites.sprite_read_active; }
                                        case 4h2: { readData = upper_sprites.sprite_read_tile; }
                                        case 4h3: { readData = upper_sprites.sprite_read_colour; }
                                        case 4h4: { readData = upper_sprites.sprite_read_x; }
                                        case 4h5: { readData = upper_sprites.sprite_read_y; }
                                        case 4h6: { readData = upper_sprites.sprite_read_double; }
                                    }
                                }
                                case 4h5: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff50 -
                                        case 4h0: { readData = lower_sprites.collision_0; }
                                        case 4h1: { readData = lower_sprites.collision_1; }
                                        case 4h2: { readData = lower_sprites.collision_2; }
                                        case 4h3: { readData = lower_sprites.collision_3; }
                                        case 4h4: { readData = lower_sprites.collision_4; }
                                        case 4h5: { readData = lower_sprites.collision_5; }
                                        case 4h6: { readData = lower_sprites.collision_6; }
                                        case 4h7: { readData = lower_sprites.collision_7; }
                                        case 4h8: { readData = lower_sprites.collision_8; }
                                        case 4h9: { readData = lower_sprites.collision_9; }
                                        case 4ha: { readData = lower_sprites.collision_10; }
                                        case 4hb: { readData = lower_sprites.collision_11; }
                                        case 4hc: { readData = lower_sprites.collision_12; }
                                    }
                                }
                                case 4h6: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff60 -
                                        case 4h0: { readData = upper_sprites.collision_0; }
                                        case 4h1: { readData = upper_sprites.collision_1; }
                                        case 4h2: { readData = upper_sprites.collision_2; }
                                        case 4h3: { readData = upper_sprites.collision_3; }
                                        case 4h4: { readData = upper_sprites.collision_4; }
                                        case 4h5: { readData = upper_sprites.collision_5; }
                                        case 4h6: { readData = upper_sprites.collision_6; }
                                        case 4h7: { readData = upper_sprites.collision_7; }
                                        case 4h8: { readData = upper_sprites.collision_8; }
                                        case 4h9: { readData = upper_sprites.collision_9; }
                                        case 4ha: { readData = upper_sprites.collision_10; }
                                        case 4hb: { readData = upper_sprites.collision_11; }
                                        case 4hc: { readData = upper_sprites.collision_12; }
                                    }
                                }
                                case 4h7: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff70 -
                                        case 4h4: { readData = vector_drawer.vector_block_active; }
                                    }
                                }
                                case 4h8: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff80 -
                                        case 4h2: { readData = displaylist_drawer.display_list_active; }
                                        case 4h4: { readData = displaylist_drawer.read_active; }
                                        case 4h5: { readData = displaylist_drawer.read_command; }
                                        case 4h6: { readData = displaylist_drawer.read_colour; }
                                        case 4h7: { readData = displaylist_drawer.read_x; }
                                        case 4h8: { readData = displaylist_drawer.read_y; }
                                        case 4h9: { readData = displaylist_drawer.read_p0; }
                                        case 4ha: { readData = displaylist_drawer.read_p1; }
                                        case 4hb: { readData = displaylist_drawer.read_p2; }
                                        case 4hc: { readData = displaylist_drawer.read_p3; }
                                    }
                                }
                                case 4h9: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff90 -
                                        case 4h9: { readData = tile_map.tm_lastaction; }
                                        case 4ha: { readData = tile_map.tm_active; }
                                    }
                                }
                                case 4ha: {
                                    switch( memoryAddress[0,4] ) {
                                        case 4h0: { readData = words(doperations2.total).hword; }
                                        case 4h1: { readData = words(doperations2.total).lword; }
                                        case 4h2: { readData = words(doperations2.difference).hword; }
                                        case 4h3: { readData = words(doperations2.difference).lword; }
                                        case 4h4: { readData = words(doperations1.increment).hword; }
                                        case 4h5: { readData = words(doperations1.increment).lword; }
                                        case 4h6: { readData = words(doperations1.decrement).hword; }
                                        case 4h7: { readData = words(doperations1.decrement).lword; }
                                        case 4h8: { readData = words(doperations1.times2).hword; }
                                        case 4h9: { readData = words(doperations1.times2).lword; }
                                        case 4ha: { readData = words(doperations1.divide2).hword; }
                                        case 4hb: { readData = words(doperations1.divide2).lword; }
                                        case 4hc: { readData = words(doperations1.negation).hword; }
                                        case 4hd: { readData = words(doperations1.negation).lword; }
                                        case 4he: { readData = words(doperations1.binaryinvert).hword; }
                                        case 4hf: { readData = words(doperations1.binaryinvert).lword; }
                                    }
                                }
                                case 4hb: {
                                    switch( memoryAddress[0,4] ) {
                                        case 4h0: { readData = words(doperations2.binaryxor).hword; }
                                        case 4h1: { readData = words(doperations2.binaryxor).lword; }
                                        case 4h2: { readData = words(doperations2.binaryand).hword; }
                                        case 4h3: { readData = words(doperations2.binaryand).lword; }
                                        case 4h4: { readData = words(doperations2.binaryor).hword; }
                                        case 4h5: { readData = words(doperations2.binaryor).lword; }
                                        case 4h6: { readData = words(doperations1.absolute).hword; }
                                        case 4h7: { readData = words(doperations1.absolute).lword; }
                                        case 4h8: { readData = words(doperations2.maximum).hword; }
                                        case 4h9: { readData = words(doperations2.maximum).lword; }
                                        case 4ha: { readData = words(doperations2.minimum).hword; }
                                        case 4hb: { readData = words(doperations2.minimum).lword; }
                                        case 4hc: { readData = doperations1.zeroequal; }
                                        case 4hd: { readData = doperations1.zeroless; }
                                        case 4he: { readData = doperations2.equal; }
                                        case 4hf: { readData = doperations2.lessthan; }
                                    }
                                }
                                case 4hd: {
                                    switch( memoryAddress[0,4] ) {
                                        case 4h0: { readData = divmod32by16to16qr.quotient[0,16]; }
                                        case 4h1: { readData = divmod32by16to16qr.remainder[0,16]; }
                                        case 4h3: { readData = divmod32by16to16qr.active; }
                                        case 4h4: { readData = divmod16by16to16qr.quotient; }
                                        case 4h5: { readData = divmod16by16to16qr.remainder; }
                                        case 4h6: { readData = divmod16by16to16qr.active; }
                                        case 4h7: { readData = multiplier16by16to32.product[16,16]; }
                                        case 4h8: { readData = multiplier16by16to32.product[0,16]; }
                                        case 4h9: { readData = multiplier16by16to32.active; }
                                    }
                                }
                                case 4he: {
                                    switch( memoryAddress[0,4] ) {
                                        // ffe0 -
                                        case 4h0: { readData = staticGenerator; }
                                        case 4h3: { readData = apu_processor_L.audio_active; }
                                        case 4h7: { readData = apu_processor_R.audio_active; }
                                        case 4hd: { readData = timer1hz.counter1hz; }
                                        case 4he: { readData = timer1khz.counter1khz; }
                                        case 4hf: { readData = sleepTimer.counter1khz; }
                                    }
                                }
                                case 4hf: {
                                    switch( memoryAddress[0,4] ) {
                                        // fff0 -
                                        case 4hf: { readData = vblank; }
                                    }
                                }
                            }
                        }
                    }
                }
            } // READ IO Memory
        } // memoryRead

        // WRITE IO Memory
        if( memoryWrite ) {
            coProReset = 3;

            switch( memoryAddress[12,4] ) {
                case 4hf: {
                    switch( memoryAddress[8,4] ) {
                        case 4h0: {
                            switch( memoryAddress[0,4] ) {
                                // f000 -
                                case 4h0: { uartOutBuffer.wdata1 = writeData[0,8]; newuartOutBufferTop = uartOutBufferTop + 1; }
                                case 4h2: { leds = writeData; }
                            }
                        }
                        case 4hf: {
                            switch( memoryAddress[0,8] ) {
                                // ff00 -
                                case 8h00: { gpu_processor.gpu_x = writeData; }
                                case 8h01: { gpu_processor.gpu_y = writeData; }
                                case 8h02: { gpu_processor.gpu_colour = writeData; }
                                case 8h03: { gpu_processor.gpu_param0 = writeData; }
                                case 8h04: { gpu_processor.gpu_param1 = writeData; }
                                case 8h05: { gpu_processor.gpu_param2 = writeData; }
                                case 8h06: { gpu_processor.gpu_param3 = writeData; }
                                case 8h07: { gpu_processor.gpu_write = writeData; }
                                case 8h08: { bitmap_window.bitmap_write_offset = writeData; }
                                case 8h09: { bitmap_window.bitmap_x_read = writeData; }
                                case 8h0a: { bitmap_window.bitmap_y_read = writeData; }
                                case 8h0b: { gpu_processor.blit1_writer_tile = writeData; }
                                case 8h0c: { gpu_processor.blit1_writer_line = writeData; }
                                case 8h0d: { gpu_processor.blit1_writer_bitmap = writeData;  gpu_processor.blit1_writer_active = 1; }

                                // ff10 -
                                case 8h10: { character_map_window.tpu_x = writeData; }
                                case 8h11: { character_map_window.tpu_y = writeData; }
                                case 8h12: { character_map_window.tpu_character = writeData; }
                                case 8h13: { character_map_window.tpu_background = writeData; }
                                case 8h14: { character_map_window.tpu_foreground = writeData; }
                                case 8h15: { character_map_window.tpu_write = writeData; }

                                // ff20 -
                                case 8h20: { terminal_window.terminal_character = writeData; terminal_window.terminal_write = 1; }
                                case 8h21: { terminal_window.showterminal = writeData; }

                                // ff30 -
                                case 8h30: { lower_sprites.sprite_set_number = writeData; }
                                case 8h31: { lower_sprites.sprite_set_active = writeData; lower_sprites.sprite_layer_write = 1; }
                                case 8h32: { lower_sprites.sprite_set_tile = writeData; lower_sprites.sprite_layer_write = 2; }
                                case 8h33: { lower_sprites.sprite_set_colour = writeData; lower_sprites.sprite_layer_write = 3; }
                                case 8h34: { lower_sprites.sprite_set_x = writeData; lower_sprites.sprite_layer_write = 4; }
                                case 8h35: { lower_sprites.sprite_set_y = writeData; lower_sprites.sprite_layer_write = 5; }
                                case 8h36: { lower_sprites.sprite_set_double = writeData; lower_sprites.sprite_layer_write = 6; }
                                case 8h38: { lower_sprites.sprite_writer_sprite = writeData; }
                                case 8h39: { lower_sprites.sprite_writer_line = writeData; }
                                case 8h3a: { lower_sprites.sprite_writer_bitmap = writeData; lower_sprites.sprite_writer_active = 1; }
                                case 8h3e: { lower_sprites.sprite_update = writeData; lower_sprites.sprite_layer_write = 10; }

                                // ff40 -
                                case 8h40: { upper_sprites.sprite_set_number = writeData; }
                                case 8h41: { upper_sprites.sprite_set_active = writeData; upper_sprites.sprite_layer_write = 1; }
                                case 8h42: { upper_sprites.sprite_set_tile = writeData; upper_sprites.sprite_layer_write = 2; }
                                case 8h43: { upper_sprites.sprite_set_colour = writeData; upper_sprites.sprite_layer_write = 3; }
                                case 8h44: { upper_sprites.sprite_set_x = writeData; upper_sprites.sprite_layer_write = 4; }
                                case 8h45: { upper_sprites.sprite_set_y = writeData; upper_sprites.sprite_layer_write = 5; }
                                case 8h46: { upper_sprites.sprite_set_double = writeData; upper_sprites.sprite_layer_write = 6; }
                                case 8h48: { upper_sprites.sprite_writer_sprite = writeData; }
                                case 8h49: { upper_sprites.sprite_writer_line = writeData; }
                                case 8h4a: { upper_sprites.sprite_writer_bitmap = writeData; upper_sprites.sprite_writer_active = 1; }
                                case 8h4e: { upper_sprites.sprite_update = writeData; upper_sprites.sprite_layer_write = 10; }

                                // ff70 -
                                case 8h70: { vector_drawer.vector_block_number = writeData; }
                                case 8h71: { vector_drawer.vector_block_colour = writeData; }
                                case 8h72: { vector_drawer.vector_block_xc = writeData; }
                                case 8h73: { vector_drawer.vector_block_yc = writeData; }
                                case 8h74: { vector_drawer.draw_vector = 1; }
                                case 8h75: { vector_drawer.vertices_writer_block = writeData; }
                                case 8h76: { vector_drawer.vertices_writer_vertex = writeData; }
                                case 8h77: { vector_drawer.vertices_writer_xdelta = writeData; }
                                case 8h78: { vector_drawer.vertices_writer_ydelta = writeData; }
                                case 8h79: { vector_drawer.vertices_writer_active = writeData; }
                                case 8h7a: { vector_drawer.vertices_writer_write = 1; }

                                // ff80 -
                                case 8h80: { displaylist_drawer.start_entry = writeData; }
                                case 8h81: { displaylist_drawer.finish_entry = writeData; }
                                case 8h82: { displaylist_drawer.start_displaylist = 1; }
                                case 8h83: { displaylist_drawer.writer_entry_number = writeData; }
                                case 8h84: { displaylist_drawer.writer_active = writeData; }
                                case 8h85: { displaylist_drawer.writer_command = writeData; }
                                case 8h86: { displaylist_drawer.writer_colour = writeData; }
                                case 8h87: { displaylist_drawer.writer_x = writeData; }
                                case 8h88: { displaylist_drawer.writer_y = writeData; }
                                case 8h89: { displaylist_drawer.writer_p0 = writeData; }
                                case 8h8a: { displaylist_drawer.writer_p1 = writeData; }
                                case 8h8b: { displaylist_drawer.writer_p2 = writeData; }
                                case 8h8c: { displaylist_drawer.writer_p3 = writeData; }
                                case 8h8d: { displaylist_drawer.writer_write = writeData; }

                                // ff90 -
                                case 8h90: { tile_map.tm_x = writeData; }
                                case 8h91: { tile_map.tm_y = writeData; }
                                case 8h92: { tile_map.tm_character = writeData; }
                                case 8h93: { tile_map.tm_background = writeData; }
                                case 8h94: { tile_map.tm_foreground = writeData; }
                                case 8h95: { tile_map.tm_write = 1; }
                                case 8h96: { tile_map.tile_writer_tile = writeData; }
                                case 8h97: { tile_map.tile_writer_line = writeData; }
                                case 8h98: { tile_map.tile_writer_bitmap = writeData; tile_map.tile_writer_write = 1; }
                                case 8h99: { tile_map.tm_scrollwrap = writeData; }

                                // ffa0 -
                                case 8ha0: { doperations2.operand1h = writeData; doperations1.operand1h = writeData; }
                                case 8ha1: { doperations2.operand1l = writeData; doperations1.operand1l = writeData; }
                                case 8ha2: { doperations2.operand2h = writeData; }
                                case 8ha3: { doperations2.operand2l = writeData; }

                                // ffd0 -
                                case 8hd0: { divmod32by16to16qr.dividendh = writeData; }
                                case 8hd1: { divmod32by16to16qr.dividendl = writeData; }
                                case 8hd2: { divmod32by16to16qr.divisor = writeData; }
                                case 8hd3: { divmod32by16to16qr.start = writeData; }
                                case 8hd4: { divmod16by16to16qr.dividend = writeData; }
                                case 8hd5: { divmod16by16to16qr.divisor = writeData; }
                                case 8hd6: { divmod16by16to16qr.start = writeData; }
                                case 8hd7: { multiplier16by16to32.factor1 = writeData; }
                                case 8hd8: { multiplier16by16to32.factor2 = writeData; }
                                case 8hd9: { multiplier16by16to32.start = writeData; }

                                // ffe0 -
                                case 8he0: { apu_processor_L.waveform = writeData; }
                                case 8he1: { apu_processor_L.note = writeData; }
                                case 8he2: { apu_processor_L.duration = writeData; }
                                case 8he3: { apu_processor_L.apu_write = writeData; }
                                case 8he4: { apu_processor_R.waveform = writeData; }
                                case 8he5: { apu_processor_R.note = writeData; }
                                case 8he6: { apu_processor_R.duration = writeData; }
                                case 8he7: { apu_processor_R.apu_write = writeData; }
                                case 8he8: { rng.resetRandom = 1; }
                                case 8hed: { timer1hz.resetCounter = 1; }
                                case 8hee: { timer1khz.resetCount = writeData; timer1khz.resetCounter = 1; }
                                case 8hef: { sleepTimer.resetCount = writeData; sleepTimer.resetCounter = 1; }

                                // fff0 -
                                case 8hf0: { background_generator.backgroundcolour = writeData; background_generator.background_write = 1; }
                                case 8hf1: { background_generator.backgroundcolour_alt = writeData; background_generator.background_write = 2; }
                                case 8hf2: { background_generator.backgroundcolour_mode = writeData; background_generator.background_write = 3; }
                            }
                        }
                    }
                }
            }
        } else { // WRITE IO Memory
            coProReset = ( coProReset == 0 ) ? 0 : coProReset - 1;
        }

        // RESET Co-Processor Controls
        // Main processor and memory map runs at 50MHz, display co-processors at 25MHz
        // Delay to reset co-processors therefore required
        if( coProReset == 1 ) {
            background_generator.background_write = 0;
            tile_map.tile_writer_write = 0;
            tile_map.tm_write = 0;
            tile_map.tm_scrollwrap = 0;
            lower_sprites.sprite_layer_write = 0;
            lower_sprites.sprite_writer_active = 0;
            bitmap_window.bitmap_write_offset = 0;
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
        }
    } // while(1)
}
