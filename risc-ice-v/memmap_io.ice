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
    input   uint1   clock_25mhz,
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
    pulse1hz p1hz <@clock_50mhz> (
        counter1hz :> systemClock,
    );
    pulse1hz timer1hz <@clock_50mhz> ( );

    // 1khz timers (sleepTimer used for sleep command, timer1khz for user purposes)
    pulse1khz sleepTimer <@clock_50mhz> ( );
    pulse1khz timer1khz <@clock_50mhz> ( );

    // RNG random number generator
    uint16 staticGenerator = 0;
    random rng <@clock_50mhz> (
        g_noise_out :> staticGenerator,
    );

    // UART tx and rx
    // UART written in Silice by https://github.com/sylefeb/Silice
    uart_out uo;
    uart_sender usend <@clock_25mhz> (
        io      <:> uo,
        uart_tx :>  uart_tx
    );
    uart_in ui;
    uart_receiver urecv <@clock_25mhz> (
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
    uint1   bitmap_write = uninitialized;

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
    apu apu_processor_L <@clock_50mhz> (
        staticGenerator <: staticGenerator,
        audio_output :> audio_l
    );
    apu apu_processor_R <@clock_50mhz> (
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
    simple_dualport_bram uint8 uartInBuffer[4096] = uninitialized;
    uint13  uartInBufferNext = 0;
    uint13  uartInBufferTop = 0;

    // UART output FIFO (16 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartOutBuffer[256] = uninitialized;
    uint8   uartOutBufferNext = 0;
    uint8   uartOutBufferTop = 0;
    uint8   newuartOutBufferTop = 0;

    // register buttons
    uint$NUM_BTNS$ reg_btns = 0;
    reg_btns ::= btns;

    // UART Buffers
    uartInBuffer.wenable1  := 1;  // always write on port 1
    uartInBuffer.addr0     := uartInBufferNext; // FIFO reads on next
    uartInBuffer.addr1     := uartInBufferTop;  // FIFO writes on top

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
    tile_map.tm_write := 0;
    tile_map.tm_scrollwrap := 0;
    lower_sprites.sprite_layer_write := 0;
    lower_sprites.sprite_writer_active := 0;
    bitmap_window.bitmap_write_offset := 0;
    gpu_processor.gpu_write := 0;
    gpu_processor.draw_vector := 0;
    upper_sprites.sprite_layer_write := 0;
    upper_sprites.sprite_writer_active := 0;
    character_map_window.tpu_write := 0;
    terminal_window.terminal_write := 0;
    apu_processor_L.apu_write := 0;
    apu_processor_R.apu_write := 0;

    // UART input and output buffering
    uartInBuffer.wdata1  := ui.data_out;
    uartInBufferTop      := ( ui.data_out_ready ) ? uartInBufferTop + 1 : uartInBufferTop;

    uo.data_in      := uartOutBuffer.rdata0;
    uo.data_in_ready     := (uartOutBufferNext != uartOutBufferTop) && ( !uo.busy );
    uartOutBufferNext := ( (uartOutBufferNext != uartOutBufferTop) && ( !uo.busy ) ) ? uartOutBufferNext + 1 : uartOutBufferNext;

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
                case 16h8230: { readData = tile_map.tm_lastaction; }
                case 16h8234: { readData = tile_map.tm_active; }

                // LOWER SPRITE LAYER
                case 16h8304: { readData = lower_sprites.sprite_read_active; }
                case 16h8308: { readData = lower_sprites.sprite_read_tile; }
                case 16h830c: { readData = lower_sprites.sprite_read_colour; }
                case 16h8310: { readData = lower_sprites.sprite_read_x[10,1] ? 16hf800 : 16h0000 | lower_sprites.sprite_read_x; }
                case 16h8314: { readData = lower_sprites.sprite_read_y[10,1] ? 16hf800 : 16h0000 | lower_sprites.sprite_read_y; }
                case 16h8318: { readData = lower_sprites.sprite_read_double; }

                case 16h8330: { readData = lower_sprites.collision_0; }
                case 16h8332: { readData = lower_sprites.collision_1; }
                case 16h8334: { readData = lower_sprites.collision_2; }
                case 16h8336: { readData = lower_sprites.collision_3; }
                case 16h8338: { readData = lower_sprites.collision_4; }
                case 16h833a: { readData = lower_sprites.collision_5; }
                case 16h833c: { readData = lower_sprites.collision_6; }
                case 16h833e: { readData = lower_sprites.collision_7; }
                case 16h8340: { readData = lower_sprites.collision_8; }
                case 16h8342: { readData = lower_sprites.collision_9; }
                case 16h8344: { readData = lower_sprites.collision_10; }
                case 16h8346: { readData = lower_sprites.collision_11; }
                case 16h8348: { readData = lower_sprites.collision_12; }

                // GPU and BITMAP
                case 16h841c: { readData = gpu_processor.gpu_active; }
                case 16h8448: { readData = gpu_processor.vector_block_active; }
                case 16h8470: { readData = bitmap_window.bitmap_colour_read; }

                // UPPER SPRITE LAYER
                case 16h8504: { readData = upper_sprites.sprite_read_active; }
                case 16h8508: { readData = upper_sprites.sprite_read_tile; }
                case 16h850c: { readData = upper_sprites.sprite_read_colour; }
                case 16h8510: { readData = upper_sprites.sprite_read_x[10,1] ? 16hf800 : 16h0000 | upper_sprites.sprite_read_x; }
                case 16h8514: { readData = upper_sprites.sprite_read_y[10,1] ? 16hf800 : 16h0000 | upper_sprites.sprite_read_y; }
                case 16h8518: { readData = upper_sprites.sprite_read_double; }

                case 16h8530: { readData = upper_sprites.collision_0; }
                case 16h8532: { readData = upper_sprites.collision_1; }
                case 16h8534: { readData = upper_sprites.collision_2; }
                case 16h8536: { readData = upper_sprites.collision_3; }
                case 16h8538: { readData = upper_sprites.collision_4; }
                case 16h853a: { readData = upper_sprites.collision_5; }
                case 16h853c: { readData = upper_sprites.collision_6; }
                case 16h853e: { readData = upper_sprites.collision_7; }
                case 16h8540: { readData = upper_sprites.collision_8; }
                case 16h8542: { readData = upper_sprites.collision_9; }
                case 16h8544: { readData = upper_sprites.collision_10; }
                case 16h8546: { readData = upper_sprites.collision_11; }
                case 16h8548: { readData = upper_sprites.collision_12; }

                // CHARACTER MAP
                case 16h8614: { readData = character_map_window.tpu_active; }

                // TERMINAL
                case 16h8700: { readData = terminal_window.terminal_active; }

                // AUDIO
                case 16h8808: { readData = apu_processor_L.audio_active; }
                case 16h8818: { readData = apu_processor_R.audio_active; }

                // TIMERS and RNG
                case 16h8900: { readData = rng.g_noise_out; }
                case 16h8904: { readData = rng.u_noise_out; }
                case 16h8910: { readData = timer1hz.counter1hz; }
                case 16h8920: { readData = timer1khz.counter1khz; }
                case 16h8930: { readData = sleepTimer.counter1khz; }

                // VBLANK
                case 16h8ff0: { readData = vblank; }
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
                case 16h8200: { tile_map.tm_x = writeData; }
                case 16h8204: { tile_map.tm_y = writeData; }
                case 16h8208: { tile_map.tm_character = writeData; }
                case 16h820c: { tile_map.tm_background = writeData; }
                case 16h8210: { tile_map.tm_foreground = writeData; }
                case 16h8214: { tile_map.tm_write = 1; }

                case 16h8220: { tile_map.tile_writer_tile = writeData; }
                case 16h8224: { tile_map.tile_writer_line = writeData; }
                case 16h8228: { tile_map.tile_writer_bitmap = writeData; }

                case 16h8230: { tile_map.tm_scrollwrap = writeData; }

                // LOWER SPRITE LAYER
                case 16h8300: { lower_sprites.sprite_set_number = writeData; }
                case 16h8304: { lower_sprites.sprite_set_active = writeData; lower_sprites.sprite_layer_write = 1; }
                case 16h8308: { lower_sprites.sprite_set_tile = writeData; lower_sprites.sprite_layer_write = 2; }
                case 16h830c: { lower_sprites.sprite_set_colour = writeData; lower_sprites.sprite_layer_write = 3; }
                case 16h8310: { lower_sprites.sprite_set_x = writeData; lower_sprites.sprite_layer_write = 4; }
                case 16h8314: { lower_sprites.sprite_set_y = writeData; lower_sprites.sprite_layer_write = 5; }
                case 16h8318: { lower_sprites.sprite_set_double = writeData; lower_sprites.sprite_layer_write = 6; }
                case 16h831c: { lower_sprites.sprite_update = writeData; lower_sprites.sprite_layer_write = 10; }

                case 16h8320: { lower_sprites.sprite_writer_sprite = writeData; }
                case 16h8324: { lower_sprites.sprite_writer_line = writeData; }
                case 16h8328: { lower_sprites.sprite_writer_bitmap = writeData; lower_sprites.sprite_writer_active = 1; }

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

                case 16h8450: { gpu_processor.blit1_writer_tile = writeData; }
                case 16h8454: { gpu_processor.blit1_writer_line = writeData; }
                case 16h8458: { gpu_processor.blit1_writer_bitmap = writeData; }

                case 16h8460: { bitmap_window.bitmap_write_offset = writeData; }

                case 16h8470: { bitmap_window.bitmap_x_read = writeData; }
                case 16h8474: { bitmap_window.bitmap_y_read = writeData; }

                // UPPER SPRITE LAYER
                case 16h8500: { upper_sprites.sprite_set_number = writeData; }
                case 16h8504: { upper_sprites.sprite_set_active = writeData; upper_sprites.sprite_layer_write = 1; }
                case 16h8508: { upper_sprites.sprite_set_tile = writeData; upper_sprites.sprite_layer_write = 2; }
                case 16h850c: { upper_sprites.sprite_set_colour = writeData; upper_sprites.sprite_layer_write = 3; }
                case 16h8510: { upper_sprites.sprite_set_x = writeData; upper_sprites.sprite_layer_write = 4; }
                case 16h8514: { upper_sprites.sprite_set_y = writeData; upper_sprites.sprite_layer_write = 5; }
                case 16h8518: { upper_sprites.sprite_set_double = writeData; upper_sprites.sprite_layer_write = 6; }
                case 16h851c: { upper_sprites.sprite_update = writeData; upper_sprites.sprite_layer_write = 10; }

                case 16h8520: { upper_sprites.sprite_writer_sprite = writeData; }
                case 16h8524: { upper_sprites.sprite_writer_line = writeData; }
                case 16h8528: { upper_sprites.sprite_writer_bitmap = writeData; upper_sprites.sprite_writer_active = 1; }

                // CHARACTER MAP
                case 16h8600: { character_map_window.tpu_x = writeData; }
                case 16h8604: { character_map_window.tpu_y = writeData; }
                case 16h8608: { character_map_window.tpu_character = writeData; }
                case 16h860c: { character_map_window.tpu_background = writeData; }
                case 16h8610: { character_map_window.tpu_foreground = writeData; }
                case 16h8614: { character_map_window.tpu_write = writeData; }

                // TERMINAL
                case 16h8700: { terminal_window.terminal_character = writeData; terminal_window.terminal_write = 1; }
                case 16h8704: { terminal_window.showterminal = writeData; }

                // AUDIO
                case 16h8800: { apu_processor_L.waveform = writeData; }
                case 16h8804: { apu_processor_L.note = writeData; }
                case 16h8808: { apu_processor_L.duration = writeData; }
                case 16h880c: { apu_processor_L.apu_write = writeData; }
                case 16h8810: { apu_processor_R.waveform = writeData; }
                case 16h8814: { apu_processor_R.note = writeData; }
                case 16h8818: { apu_processor_R.duration = writeData; }
                case 16h881c: { apu_processor_R.apu_write = writeData; }

                // TIMERS and RNG
                case 16h8900: { rng.resetRandom = 1; }
                case 16h8910: { timer1hz.resetCounter = 1; }
                case 16h8920: { timer1khz.resetCount = writeData; timer1khz.resetCounter = 1; }
                case 16h8930: { sleepTimer.resetCount = writeData; sleepTimer.resetCounter = 1; }
            }
        }

    } // while(1)
}
