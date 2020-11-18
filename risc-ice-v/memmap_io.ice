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
    input   uint1   video_clock,
    input   uint1   video_reset,

    // Memory access
    input   uint16  memoryAddress,
    input   uint16  writeData,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,
    output! uint16  readData,
) <autorun> {
    // 1hz timers (p1hz used for systemClock, timer1hz for user purposes)
    uint16 systemClock = uninitialized;
    pulse1hz p1hz (
        counter1hz :> systemClock,
    );
    pulse1hz timer1hz ( );

    // 1khz timers (sleepTimer used for sleep command, timer1khz for user purposes)
    pulse1khz sleepTimer ( );
    pulse1khz timer1khz ( );

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
    apu apu_processor_L (
        staticGenerator <: staticGenerator,
        audio_output :> audio_l
    );
    apu apu_processor_R (
        staticGenerator <: staticGenerator,
        audio_output :> audio_r
    );

    gpu gpu_processor <@video_clock,!video_reset> (
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_colour_write :> bitmap_colour_write,
        bitmap_write :> bitmap_write,
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

    // RESET Co-Processor Controls
    background_generator.background_write := 0;
    tile_map.tile_writer_write := 0;
    tile_map.tm_write := 0;
    tile_map.tm_scrollwrap := 0;
    lower_sprites.sprite_layer_write := 0;
    lower_sprites.sprite_writer_active := 0;
    bitmap_window.bitmap_write_offset := 0;
    gpu_processor.gpu_write := 0;
    gpu_processor.draw_vector := 0;
    gpu_processor.dl_start := 0;
    gpu_processor.blit1_writer_active := 0;
    gpu_processor.vertices_writer_write := 0;
    gpu_processor.dl_writer_write := 0;
    upper_sprites.sprite_layer_write := 0;
    upper_sprites.sprite_writer_active := 0;
    character_map_window.tpu_write := 0;
    terminal_window.terminal_write := 0;
    apu_processor_L.apu_write := 0;
    apu_processor_R.apu_write := 0;

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
                // UART, LEDS, BUTTONS and CLOCK
                case 16h8000: { readData = { 8b0, uartInBuffer.rdata0 }; uartInBufferNext = uartInBufferNext + 1; }
                case 16h8004: { readData = { 14b0, ( uartOutBufferTop + 1 == uartOutBufferNext ), ( uartInBufferNext != uartInBufferTop )}; }
                case 16h8008: { readData = { $16-NUM_BTNS$b0, reg_btns[0,$NUM_BTNS$] }; }
                case 16h800c: { readData = leds; }
                case 16h8010: { readData = systemClock; }

                // BACKGROUND

                // TILE MAP

                // LOWER SPRITE LAYER

                // GPU and BITMAP
                case 16h841c: { readData = gpu_processor.gpu_active; }
                case 16h84b0: { readData = bitmap_window.bitmap_colour_read; }

                // UPPER SPRITE LAYER

                // CHARACTER MAP

                // TERMINAL
                case 16h8700: { readData = terminal_window.terminal_active; }

                // TIMERS and RNG

                // VBLANK

            }
        }

        // WRITE IO Memory
        if( memoryWrite ) {
            switch( memoryAddress ) {
                // UART, LEDS
                case 16h8000: { uartOutBuffer.wdata1 = writeData[0,8]; newuartOutBufferTop = uartOutBufferTop + 1; }
                case 16h800c: { leds = writeData; }

                // BACKGROUND
                case 16h8100: { background_generator.backgroundcolour = writeData; background_generator.background_write = 1; }
                case 16h8104: { background_generator.backgroundcolour_alt = writeData; background_generator.background_write = 2; }
                case 16h8108: { background_generator.backgroundcolour_mode = writeData; background_generator.background_write = 3; }

                // TILE MAP

                // LOWER SPRITE LAYER

                // GPU and BITMAP
                case 16h8400: { gpu_processor.gpu_x = writeData; }
                case 16h8404: { gpu_processor.gpu_y = writeData; }
                case 16h8408: { gpu_processor.gpu_colour = writeData; }
                case 16h840c: { gpu_processor.gpu_param0 = writeData; }
                case 16h8410: { gpu_processor.gpu_param1 = writeData; }
                case 16h8414: { gpu_processor.gpu_param2 = writeData; }
                case 16h8418: { gpu_processor.gpu_param3 = writeData; }
                case 16h841c: { gpu_processor.gpu_write = writeData; }

                case 16h8420: { gpu_processor.vector_block_number = writeData; }
                case 16h8424: { gpu_processor.vector_block_colour = writeData; }
                case 16h8428: { gpu_processor.vector_block_xc = writeData; }
                case 16h842c: { gpu_processor.vector_block_yc = writeData; }
                case 16h8430: { gpu_processor.draw_vector = 1; }

                case 16h8434: { gpu_processor.vertices_writer_block = writeData; }
                case 16h8438: { gpu_processor.vertices_writer_vertex = writeData; }
                case 16h843c: { gpu_processor.vertices_writer_xdelta = writeData; }
                case 16h8440: { gpu_processor.vertices_writer_ydelta = writeData; }
                case 16h8444: { gpu_processor.vertices_writer_active = writeData; }
                case 16h8448: { gpu_processor.vertices_writer_write = 1; }

                case 16h8450: { gpu_processor.dl_start_entry = writeData; }
                case 16h8454: { gpu_processor.dl_finish_entry = writeData; }
                case 16h8458: { gpu_processor.dl_start = 1; }

                case 16h845c: { gpu_processor.dl_writer_entry_number = writeData; }
                case 16h8460: { gpu_processor.dl_writer_active = writeData; }
                case 16h8464: { gpu_processor.dl_writer_colour = writeData; }
                case 16h8468: { gpu_processor.dl_writer_x = writeData; }
                case 16h846c: { gpu_processor.dl_writer_y = writeData; }
                case 16h8470: { gpu_processor.dl_writer_p0 = writeData; }
                case 16h8474: { gpu_processor.dl_writer_p1 = writeData; }
                case 16h8478: { gpu_processor.dl_writer_p2 = writeData; }
                case 16h847c: { gpu_processor.dl_writer_p3 = writeData; }
                case 16h8480: { gpu_processor.dl_writer_write = 1; }

                case 16h8490: { gpu_processor.blit1_writer_tile = writeData; }
                case 16h8494: { gpu_processor.blit1_writer_line = writeData; }
                case 16h8498: { gpu_processor.blit1_writer_bitmap = writeData;  gpu_processor.blit1_writer_active = 1; }

                case 16h84a0: { bitmap_window.bitmap_write_offset = writeData; }

                case 16h84b0: { bitmap_window.bitmap_x_read = writeData; }
                case 16h84b4: { bitmap_window.bitmap_y_read = writeData; }

                // UPPER SPRITE LAYER

                // CHARACTER MAP

                // TERMINAL
                case 16h8700: { terminal_window.terminal_character = writeData; terminal_window.terminal_write = 1; }
                case 16h8704: { terminal_window.showterminal = writeData; }

                // TIMERS and RNG

            }
        }
    } // while(1)
}
