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
            switch( memoryAddress ) {
                case 16h1000: { readData = { 8b0, uartInBuffer.rdata0 }; uartInBufferNext = uartInBufferNext + 1; }
                case 16h1002: { readData = { 14b0, ( uartOutBufferTop + 1 == uartOutBufferNext ), ( uartInBufferNext != uartInBufferTop )}; }
                default:    { readData = 0; }
            }
        } // memoryRead

        // WRITE IO Memory
        if( memoryWrite ) {
            coProReset = 3;
            switch( memoryAddress ) {
                case 16h1000: { uartOutBuffer.wdata1 = writeData[0,8]; newuartOutBufferTop = uartOutBufferTop + 1; }
                case 16h1004: { terminal_window.terminal_character = writeData; terminal_window.terminal_write = 1; }
                case 16h1008: { leds = writeData; }
                default: {  }
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
