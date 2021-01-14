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

    // SDCARD
    output! uint1   sd_clk,
    output! uint1   sd_mosi,
    output! uint1   sd_csn,
    input   uint1   sd_miso,

    // HDMI
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
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output! uint32  readData,
) <autorun> {
    // 1hz timers (p1hz used for systemClock, timer1hz for user purposes)
    uint16 systemClock = uninitialized;
    pulse1hz p1hz(
        counter1hz :> systemClock,
    );
    pulse1hz timer1hz( );

    // 1khz timers (sleepTimer used for sleep command, timer1khz for user purposes)
    pulse1khz sleepTimer( );
    pulse1khz timer1khz( );

    // RNG random number generator
    uint16  staticGenerator = uninitialized;
    uint16  staticGeneratorALT = uninitialized;
    random rng(
        g_noise_out :> staticGenerator,
        u_noise_out :> staticGeneratorALT
    );


    // UART tx and rx
    // UART written in Silice by https://github.com/sylefeb/Silice
    uart_out uo;
    uart_sender usend(
        io      <:> uo,
        uart_tx :>  uart_tx
    );
    uart_in ui;
    uart_receiver urecv(
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
    uint10  x_offset = uninitialized;
    uint10  y_offset = uninitialized;
    // From GPU to set a pixel
    uint1   bitmap_display = uninitialized;
    int11   bitmap_x_write = uninitialized;
    int11   bitmap_y_write = uninitialized;
    uint7   bitmap_colour_write = uninitialized;
    uint1   bitmap_write = uninitialized;

    // 640 x 480 x 7 bit { Arrggbb } colour bitmap
    simple_dualport_bram uint7 bitmap <@video_clock,@video_clock,input!> [ 307200 ] = uninitialized;
    bitmap bitmap_window <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> bitmap_r,
        pix_green  :> bitmap_g,
        pix_blue   :> bitmap_b,
        bitmap_display :> bitmap_display,
        x_offset :> x_offset,
        y_offset :> y_offset,
        bitmap <:> bitmap
    );
    bitmapwriter pixel_writer <@video_clock> (
        bitmap_x_write <: bitmap_x_write,
        bitmap_y_write <: bitmap_y_write,
        bitmap_colour_write <: bitmap_colour_write,
        bitmap_write <: bitmap_write,
        x_offset <: x_offset,
        y_offset <: y_offset,
        bitmap <:> bitmap
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
    apu apu_processor_L(
        staticGenerator <: staticGenerator,
        audio_output :> audio_l
    );
    apu apu_processor_R(
        staticGenerator <: staticGenerator,
        audio_output :> audio_r
    );

    gpu gpu_processor <@video_clock> (
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_colour_write :> bitmap_colour_write,
        bitmap_write :> bitmap_write,
    );

    // SDCARD - Code for the SDCARD from @sylefeb
    simple_dualport_bram uint8 sdbuffer[512] = uninitialized;

    sdcardio sdcio;
    sdcard sd (
        // pins
        sd_clk      :> sd_clk,
        sd_mosi     :> sd_mosi,
        sd_csn      :> sd_csn,
        sd_miso     <: sd_miso,
        // io
        io          <:> sdcio,
        // bram port
        store       <:> sdbuffer
    );

    // UART input FIFO (4096 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartInBuffer [4096] = uninitialized;
    uint13  uartInBufferNext = 0;
    uint13  uartInBufferTop = 0;

    // UART output FIFO (16 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartOutBuffer [256] = uninitialized;
    uint8   uartOutBufferNext = 0;
    uint8   uartOutBufferTop = 0;
    uint8   newuartOutBufferTop = 0;

    // LATCH MEMORYREAD MEMORYWRITE
    uint1   LATCHmemoryRead = uninitialized;
    uint1   LATCHmemoryWrite = uninitialized;

    // register buttons
    uint$NUM_BTNS$ reg_btns = 0;
    reg_btns ::= btns;

    // UART Buffers ( code from @sylefeb )
    uartInBuffer.wenable1 := 1;  // always write on port 1
    uartInBuffer.addr0 := uartInBufferNext; // FIFO reads on next
    uartInBuffer.addr1 := uartInBufferTop;  // FIFO writes on top
    uartOutBuffer.wenable1 := 1; // always write on port 1
    uartOutBuffer.addr0 := uartOutBufferNext; // FIFO reads on next
    uartOutBuffer.addr1 := uartOutBufferTop;  // FIFO writes on top
    uartInBuffer.wdata1 := ui.data_out;
    uartInBufferTop := ( ui.data_out_ready ) ? uartInBufferTop + 1 : uartInBufferTop;
    uo.data_in := uartOutBuffer.rdata0;
    uo.data_in_ready := ( uartOutBufferNext != uartOutBufferTop ) && ( !uo.busy );
    uartOutBufferNext := ( (uartOutBufferNext != uartOutBufferTop) && ( !uo.busy ) ) ? uartOutBufferNext + 1 : uartOutBufferNext;

    // Setup the UART
    //uo.data_in_ready := 0; // maintain low

    // SDCARD Commands
    sdcio.read_sector := 0;

    // RESET TIMER and AUDIO Co-Processor Controls
    p1hz.resetCounter := 0;
    timer1hz.resetCounter := 0;
    sleepTimer.resetCount := 0;
    timer1khz.resetCount := 0;
    apu_processor_L.apu_write := 0;
    apu_processor_R.apu_write := 0;

    // Setup the terminal
    terminal_window.showterminal = 1;

    while(1) {
        // Update UART output buffer top if character has been put into buffer
        uartOutBufferTop = newuartOutBufferTop;

        // READ IO Memory
        if( memoryRead && ~LATCHmemoryRead ) {
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
                case 16h8310: { readData = { {5{lower_sprites.sprite_read_x[10,1]}}, lower_sprites.sprite_read_x }; }
                case 16h8314: { readData = { {5{lower_sprites.sprite_read_y[10,1]}}, lower_sprites.sprite_read_y }; }
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
                case 16h8510: { readData = { {5{upper_sprites.sprite_read_x[10,1]}}, upper_sprites.sprite_read_x }; }
                case 16h8514: { readData = { {5{upper_sprites.sprite_read_y[10,1]}}, upper_sprites.sprite_read_y }; }
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
                case 16h8900: { readData = staticGenerator; }
                case 16h8904: { readData = staticGeneratorALT; }
                case 16h8910: { readData = timer1hz.counter1hz; }
                case 16h8920: { readData = timer1khz.counter1khz; }
                case 16h8930: { readData = sleepTimer.counter1khz; }

                // SDCARD
                case 16h8f00: { readData = sdcio.ready; }
                case 16h8f10: { readData = sdbuffer.rdata0; }

                // VBLANK
                case 16h8ff0: { readData = vblank; }
            }
        }

        // WRITE IO Memory
        if( memoryWrite && ~LATCHmemoryWrite ) {
            switch( memoryAddress ) {
                // UART, LEDS
                case 16h8000: { uartOutBuffer.wdata1 = writeData[0,8]; newuartOutBufferTop = uartOutBufferTop + 1; }
                case 16h800c: { leds = writeData; }

                // BACKGROUND
                case 16h8100: { background_generator.backgroundcolour = writeData; }
                case 16h8104: { background_generator.backgroundcolour_alt = writeData; }
                case 16h8108: { background_generator.backgroundcolour_mode = writeData; }

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

                case 16h8480: { gpu_processor.character_writer_character = writeData; }
                case 16h8484: { gpu_processor.character_writer_line = writeData; }
                case 16h8488: { gpu_processor.character_writer_bitmap = writeData; }

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
                case 16h8708: { terminal_window.terminal_write = 2; }

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
                case 16h8910: { timer1hz.resetCounter = 1; }
                case 16h8920: { timer1khz.resetCount = writeData; }
                case 16h8930: { sleepTimer.resetCount = writeData; }

                // SDCARD
                case 16h8f00: { sdcio.read_sector = 1; }
                case 16h8f04: { sdcio.addr_sector[16,16] = writeData; }
                case 16h8f08: { sdcio.addr_sector[0,16] = writeData; }
                case 16h8f10: { sdbuffer.addr0 = writeData; }
            }
        }

        // RESET Co-Processor Controls
        // IO memory map runs at 50MHz, display co-processors at 25MHz
        // Delay to reset co-processors therefore required
        if( ~memoryWrite && ~LATCHmemoryWrite ) {
            tile_map.tm_write = 0;
            tile_map.tm_scrollwrap = 0;
            lower_sprites.sprite_layer_write = 0;
            lower_sprites.sprite_writer_active = 0;
            bitmap_window.bitmap_write_offset = 0;
            gpu_processor.gpu_write = 0;
            gpu_processor.draw_vector = 0;
            upper_sprites.sprite_layer_write = 0;
            upper_sprites.sprite_writer_active = 0;
            character_map_window.tpu_write = 0;
            terminal_window.terminal_write = 0;
        }

        LATCHmemoryRead = memoryRead;
        LATCHmemoryWrite = memoryWrite;
    } // while(1)
}
