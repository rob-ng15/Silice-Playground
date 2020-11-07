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

$$if ULX3S then
    output! uint4   gpdi_dp,
    output! uint4   gpdi_dn,
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
    output! uint1   video_vs,

    // CLOCKS
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

    // CREATE DISPLAY LAYERS
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

    // UART input FIFO (4096 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 uartInBuffer[4096] = uninitialized;
    uint13  uartInBufferNext = 0;
    uint13  uartInBufferTop = 0;

    // UART output FIFO (16 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 uartOutBuffer[256] = uninitialized;
    uint8   uartOutBufferNext = 0;
    uint8   uartOutBufferTop = 0;
    uint8   newuartOutBufferTop = 0;

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

        // WRITE IO Memory
        if( memoryWrite ) {
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
                            switch( memoryAddress[4,4] ) {
                                case 4h0: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff00 -
                                        case 4h0: { gpu_processor.gpu_x = writeData; }
                                        case 4h1: { gpu_processor.gpu_y = writeData; }
                                        case 4h2: { gpu_processor.gpu_colour = writeData; }
                                        case 4h3: { gpu_processor.gpu_param0 = writeData; }
                                        case 4h4: { gpu_processor.gpu_param1 = writeData; }
                                        case 4h5: { gpu_processor.gpu_param2 = writeData; }
                                        case 4h6: { gpu_processor.gpu_param3 = writeData; }
                                        case 4h7: { gpu_processor.gpu_write = writeData; }
                                        case 4h9: { bitmap_window.bitmap_x_read = writeData; }
                                        case 4ha: { bitmap_window.bitmap_y_read = writeData; }
                                        case 4hb: { gpu_processor.blit1_writer_tile = writeData; }
                                        case 4hc: { gpu_processor.blit1_writer_line = writeData; }
                                        case 4hd: { gpu_processor.blit1_writer_bitmap = writeData;  gpu_processor.blit1_writer_active = 1; }
                                    }
                                }
                                case 4h1: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff10 -
                                        case 4h0: { character_map_window.tpu_x = writeData; }
                                        case 4h1: { character_map_window.tpu_y = writeData; }
                                        case 4h2: { character_map_window.tpu_character = writeData; }
                                        case 4h3: { character_map_window.tpu_background = writeData; }
                                        case 4h4: { character_map_window.tpu_foreground = writeData; }
                                        case 4h5: { character_map_window.tpu_write = writeData; }
                                    }
                                }
                                case 4h2: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff20 -
                                        case 4h0: { terminal_window.terminal_character = writeData; terminal_window.terminal_write = 1; }
                                        case 4h1: { terminal_window.showterminal = writeData; }
                                    }
                                }
                                case 4h3: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff30 -
                                        case 4h0: { lower_sprites.sprite_set_number = writeData; }
                                        case 4h1: { lower_sprites.sprite_set_active = writeData; lower_sprites.sprite_layer_write = 1; }
                                        case 4h2: { lower_sprites.sprite_set_tile = writeData; lower_sprites.sprite_layer_write = 2; }
                                        case 4h3: { lower_sprites.sprite_set_colour = writeData; lower_sprites.sprite_layer_write = 3; }
                                        case 4h4: { lower_sprites.sprite_set_x = writeData; lower_sprites.sprite_layer_write = 4; }
                                        case 4h5: { lower_sprites.sprite_set_y = writeData; lower_sprites.sprite_layer_write = 5; }
                                        case 4h6: { lower_sprites.sprite_set_double = writeData; lower_sprites.sprite_layer_write = 6; }
                                        case 4h7: { lower_sprites.sprite_set_colmode = writeData; lower_sprites.sprite_layer_write = 7; }
                                        case 4h8: { lower_sprites.sprite_writer_sprite = writeData; }
                                        case 4h9: { lower_sprites.sprite_writer_line = writeData; }
                                        case 4ha: { lower_sprites.sprite_writer_bitmap = writeData; lower_sprites.sprite_writer_active = 1; }
                                        case 4he: { lower_sprites.sprite_update = writeData; lower_sprites.sprite_layer_write = 10; }
                                    }
                                }
                                case 4h4: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff40 -
                                        case 4h0: { upper_sprites.sprite_set_number = writeData; }
                                        case 4h1: { upper_sprites.sprite_set_active = writeData; upper_sprites.sprite_layer_write = 1; }
                                        case 4h2: { upper_sprites.sprite_set_tile = writeData; upper_sprites.sprite_layer_write = 2; }
                                        case 4h3: { upper_sprites.sprite_set_colour = writeData; upper_sprites.sprite_layer_write = 3; }
                                        case 4h4: { upper_sprites.sprite_set_x = writeData; upper_sprites.sprite_layer_write = 4; }
                                        case 4h5: { upper_sprites.sprite_set_y = writeData; upper_sprites.sprite_layer_write = 5; }
                                        case 4h6: { upper_sprites.sprite_set_double = writeData; upper_sprites.sprite_layer_write = 6; }
                                        case 4h7: { upper_sprites.sprite_set_colmode = writeData; upper_sprites.sprite_layer_write = 7; }
                                        case 4h8: { upper_sprites.sprite_writer_sprite = writeData; }
                                        case 4h9: { upper_sprites.sprite_writer_line = writeData; }
                                        case 4ha: { upper_sprites.sprite_writer_bitmap = writeData; upper_sprites.sprite_writer_active = 1; }
                                        case 4he: { upper_sprites.sprite_update = writeData; upper_sprites.sprite_layer_write = 10; }
                                    }
                                }
                                case 4h5: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff50 -
                                        case 4h1: { lower_sprites.sprite_palette_1 = writeData; }
                                        case 4h2: { lower_sprites.sprite_palette_2 = writeData; }
                                        case 4h3: { lower_sprites.sprite_palette_3 = writeData; }
                                        case 4h4: { lower_sprites.sprite_palette_4 = writeData; }
                                        case 4h5: { lower_sprites.sprite_palette_5 = writeData; }
                                        case 4h6: { lower_sprites.sprite_palette_6 = writeData; }
                                        case 4h7: { lower_sprites.sprite_palette_7 = writeData; }
                                        case 4h8: { lower_sprites.sprite_palette_8 = writeData; }
                                        case 4h9: { lower_sprites.sprite_palette_9 = writeData; }
                                        case 4ha: { lower_sprites.sprite_palette_10 = writeData; }
                                        case 4hb: { lower_sprites.sprite_palette_11 = writeData; }
                                        case 4hc: { lower_sprites.sprite_palette_12 = writeData; }
                                        case 4hd: { lower_sprites.sprite_palette_13 = writeData; }
                                        case 4he: { lower_sprites.sprite_palette_14 = writeData; }
                                        case 4hf: { lower_sprites.sprite_palette_15 = writeData; }
                                    }
                                }
                                case 4h6: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff60 -
                                        case 4h1: { upper_sprites.sprite_palette_1 = writeData; }
                                        case 4h2: { upper_sprites.sprite_palette_2 = writeData; }
                                        case 4h3: { upper_sprites.sprite_palette_3 = writeData; }
                                        case 4h4: { upper_sprites.sprite_palette_4 = writeData; }
                                        case 4h5: { upper_sprites.sprite_palette_5 = writeData; }
                                        case 4h6: { upper_sprites.sprite_palette_6 = writeData; }
                                        case 4h7: { upper_sprites.sprite_palette_7 = writeData; }
                                        case 4h8: { upper_sprites.sprite_palette_8 = writeData; }
                                        case 4h9: { upper_sprites.sprite_palette_9 = writeData; }
                                        case 4ha: { upper_sprites.sprite_palette_10 = writeData; }
                                        case 4hb: { upper_sprites.sprite_palette_11 = writeData; }
                                        case 4hc: { upper_sprites.sprite_palette_12 = writeData; }
                                        case 4hd: { upper_sprites.sprite_palette_13 = writeData; }
                                        case 4he: { upper_sprites.sprite_palette_14 = writeData; }
                                        case 4hf: { upper_sprites.sprite_palette_15 = writeData; }
                                    }
                                }
                                case 4h7: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff70 -
                                        case 4h0: { vector_drawer.vector_block_number = writeData; }
                                        case 4h1: { vector_drawer.vector_block_colour = writeData; }
                                        case 4h2: { vector_drawer.vector_block_xc = writeData; }
                                        case 4h3: { vector_drawer.vector_block_yc = writeData; }
                                        case 4h4: { vector_drawer.draw_vector = 1; }
                                        case 4h5: { vector_drawer.vertices_writer_block = writeData; }
                                        case 4h6: { vector_drawer.vertices_writer_vertex = writeData; }
                                        case 4h7: { vector_drawer.vertices_writer_xdelta = writeData; }
                                        case 4h8: { vector_drawer.vertices_writer_ydelta = writeData; }
                                        case 4h9: { vector_drawer.vertices_writer_active = writeData; }
                                        case 4ha: { vector_drawer.vertices_writer_write = 1; }
                                    }
                                }
                                case 4h8: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff80 -
                                        case 4h0: { displaylist_drawer.start_entry = writeData; }
                                        case 4h1: { displaylist_drawer.finish_entry = writeData; }
                                        case 4h2: { displaylist_drawer.start_displaylist = 1; }
                                        case 4h3: { displaylist_drawer.writer_entry_number = writeData; }
                                        case 4h4: { displaylist_drawer.writer_active = writeData; }
                                        case 4h5: { displaylist_drawer.writer_command = writeData; }
                                        case 4h6: { displaylist_drawer.writer_colour = writeData; }
                                        case 4h7: { displaylist_drawer.writer_x = writeData; }
                                        case 4h8: { displaylist_drawer.writer_y = writeData; }
                                        case 4h9: { displaylist_drawer.writer_p0 = writeData; }
                                        case 4ha: { displaylist_drawer.writer_p1 = writeData; }
                                        case 4hb: { displaylist_drawer.writer_p2 = writeData; }
                                        case 4hc: { displaylist_drawer.writer_p3 = writeData; }
                                        case 4hd: { displaylist_drawer.writer_write = writeData; }
                                    }
                                }
                                case 4h9: {
                                    switch( memoryAddress[0,4] ) {
                                        // ff90 -
                                        case 4h0: { tile_map.tm_x = writeData; }
                                        case 4h1: { tile_map.tm_y = writeData; }
                                        case 4h2: { tile_map.tm_character = writeData; }
                                        case 4h3: { tile_map.tm_background = writeData; }
                                        case 4h4: { tile_map.tm_foreground = writeData; }
                                        case 4h5: { tile_map.tm_write = 1; }
                                        case 4h6: { tile_map.tile_writer_tile = writeData; }
                                        case 4h7: { tile_map.tile_writer_line = writeData; }
                                        case 4h8: { tile_map.tile_writer_bitmap = writeData; tile_map.tile_writer_write = 1; }
                                        case 4h9: { tile_map.tm_scrollwrap = writeData; }
                                    }
                                }
                                case 4ha: {
                                    switch( memoryAddress[0,4] ) {
                                        case 4h0:  {doperations.operand1h = writeData; }
                                        case 4h1: { doperations.operand1l = writeData; }
                                        case 4h2: { doperations.operand2h = writeData; }
                                        case 4h3: { doperations.operand2l = writeData; }
                                    }
                                }
                                case 4hd: {
                                    switch( memoryAddress[0,4] ) {
                                        case 4h0: { divmod32by16to16qr.dividendh = writeData; }
                                        case 4h1: { divmod32by16to16qr.dividendl = writeData; }
                                        case 4h2: { divmod32by16to16qr.divisor = writeData; }
                                        case 4h3: { divmod32by16to16qr.start = writeData; }
                                        case 4h4: { divmod16by16to16qr.dividend = writeData; }
                                        case 4h5: { divmod16by16to16qr.divisor = writeData; }
                                        case 4h6: { divmod16by16to16qr.start = writeData; }
                                        case 4h7: { multiplier16by16to32.factor1 = writeData; }
                                        case 4h8: { multiplier16by16to32.factor2 = writeData; }
                                        case 4h9: { multiplier16by16to32.start = writeData; }
                                    }
                                }
                                case 4he: {
                                    switch( memoryAddress[0,4] ) {
                                        // ffe0 -
                                        case 4h0: { apu_processor_L.waveform = writeData; }
                                        case 4h1: { apu_processor_L.note = writeData; }
                                        case 4h2: { apu_processor_L.duration = writeData; }
                                        case 4h3: { apu_processor_L.apu_write = writeData; }
                                        case 4h4: { apu_processor_R.waveform = writeData; }
                                        case 4h5: { apu_processor_R.note = writeData; }
                                        case 4h6: { apu_processor_R.duration = writeData; }
                                        case 4h7: { apu_processor_R.apu_write = writeData; }
                                        case 4h8: { rng.resetRandom = 1; }
                                        case 4hd: { timer1hz.resetCounter = 1; }
                                        case 4he: { timer1khz.resetCount = writeData; timer1khz.resetCounter = 1; }
                                        case 4hf: { sleepTimer.resetCount = writeData; sleepTimer.resetCounter = 1; }
                                    }
                                }
                                case 4hf: {
                                    switch( memoryAddress[0,4] ) {
                                        // fff0 -
                                        case 4h0: { background_generator.backgroundcolour = writeData; background_generator.background_write = 1; }
                                        case 4h1: { background_generator.backgroundcolour_alt = writeData; background_generator.background_write = 2; }
                                        case 4h2: { background_generator.backgroundcolour_mode = writeData; background_generator.background_write = 3; }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } // WRITE IO Memory

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
                                        case 4h7: { readData = lower_sprites.sprite_read_colmode; }
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
                                        case 4h7: { readData = upper_sprites.sprite_read_colmode; }
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
                                        case 4h0: { readData = words(doperations.total).hword; }
                                        case 4h1: { readData = words(doperations.total).lword; }
                                        case 4h2: { readData = words(doperations.difference).hword; }
                                        case 4h3: { readData = words(doperations.difference).lword; }
                                        case 4h4: { readData = words(doperations.increment).hword; }
                                        case 4h5: { readData = words(doperations.increment).lword; }
                                        case 4h6: { readData = words(doperations.decrement).hword; }
                                        case 4h7: { readData = words(doperations.decrement).lword; }
                                        case 4h8: { readData = words(doperations.times2).hword; }
                                        case 4h9: { readData = words(doperations.times2).lword; }
                                        case 4ha: { readData = words(doperations.divide2).hword; }
                                        case 4hb: { readData = words(doperations.divide2).lword; }
                                        case 4hc: { readData = words(doperations.negation).hword; }
                                        case 4hd: { readData = words(doperations.negation).lword; }
                                        case 4he: { readData = words(doperations.binaryinvert).hword; }
                                        case 4hf: { readData = words(doperations.binaryinvert).lword; }
                                    }
                                }
                                case 4hb: {
                                    switch( memoryAddress[0,4] ) {
                                        case 4h0: { readData = words(doperations.binaryxor).hword; }
                                        case 4h1: { readData = words(doperations.binaryxor).lword; }
                                        case 4h2: { readData = words(doperations.binaryand).hword; }
                                        case 4h3: { readData = words(doperations.binaryand).lword; }
                                        case 4h4: { readData = words(doperations.binaryor).hword; }
                                        case 4h5: { readData = words(doperations.binaryor).lword; }
                                        case 4h6: { readData = words(doperations.absolute).hword; }
                                        case 4h7: { readData = words(doperations.absolute).lword; }
                                        case 4h8: { readData = words(doperations.maximum).hword; }
                                        case 4h9: { readData = words(doperations.maximum).lword; }
                                        case 4ha: { readData = words(doperations.minimum).hword; }
                                        case 4hb: { readData = words(doperations.minimum).lword; }
                                        case 4hc: { readData = doperations.zeroequal; }
                                        case 4hd: { readData = doperations.zeroless; }
                                        case 4he: { readData = doperations.equal; }
                                        case 4hf: { readData = doperations.lessthan; }
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

        // RESET Co-Processor Controls
        if( resetCoPro ) {
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
    } // while(1)
}
