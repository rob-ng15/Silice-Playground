algorithm memmap_io (
    // LEDS (8 of)
    output  uint8   leds,
    input   uint$NUM_BTNS$ btns,

   // GPIO
    input   uint28  gn,
    output  uint28  gp,

    // UART
    output  uint1   uart_tx,
    input   uint1   uart_rx,

    // USB for PS/2
    input   uint1   us2_bd_dp,
    input   uint1   us2_bd_dn,

    // AUDIO
    output  uint4   audio_l,
    output  uint4   audio_r,

    // SDCARD
    output  uint1   sd_clk,
    output  uint1   sd_mosi,
    output  uint1   sd_csn,
    input   uint1   sd_miso,

    // HDMI OUTPUT
    output  uint4   gpdi_dp,

    // CLOCKS
    input   uint1   clock_25mhz,
    input   uint1   video_clock,
    input   uint1   video_reset,
    input   uint1   gpu_clock,
    input   uint1   clock_usb,

    // Memory access
    input   uint32  memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData,

    // SMT STATUS
    output  uint1   SMTRUNNING,
    output  uint32  SMTSTARTPC
) <autorun> {
    // TIMERS and RNG
    uint1   static1bit <: timers.u_noise_out[0,1];
    uint2   static2bit <: timers.u_noise_out[0,2];
    uint4   static4bit <: timers.u_noise_out[0,4];
    uint6   static6bit <: timers.u_noise_out[0,6];
    timers_rng timers <@clock_25mhz> ( );

    // HDMI driver
    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1   vblank = uninitialized;
    uint1   pix_active = uninitialized;
    uint10  pix_x  = uninitialized;
    uint10  pix_y  = uninitialized;
    uint8   video_r = uninitialized;
    uint8   video_g = uninitialized;
    uint8   video_b = uninitialized;
    hdmi video<@clock_25mhz,!reset> (
        vblank  :> vblank,
        active  :> pix_active,
        x       :> pix_x,
        y       :> pix_y,
        gpdi_dp :> gpdi_dp,
        red     <: video_r,
        green   <: video_g,
        blue    <: video_b
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
        staticGenerator <: static2bit
    );

    // Tilemaps - Lower and Upper
    uint2   lower_tilemap_r = uninitialized;
    uint2   lower_tilemap_g = uninitialized;
    uint2   lower_tilemap_b = uninitialized;
    uint1   lower_tilemap_display = uninitialized;
    uint2   upper_tilemap_r = uninitialized;
    uint2   upper_tilemap_g = uninitialized;
    uint2   upper_tilemap_b = uninitialized;
    uint1   upper_tilemap_display = uninitialized;
    tilemap lower_tile_map <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> lower_tilemap_r,
        pix_green  :> lower_tilemap_g,
        pix_blue   :> lower_tilemap_b,
        tilemap_display :> lower_tilemap_display,
    );
    tilemap upper_tile_map <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> upper_tilemap_r,
        pix_green  :> upper_tilemap_g,
        pix_blue   :> upper_tilemap_b,
        tilemap_display :> upper_tilemap_display,
    );

    // Bitmap Window with GPU
    uint1   bitmap_display = uninitialized;
    uint2   bitmap_r = uninitialized;
    uint2   bitmap_g = uninitialized;
    uint2   bitmap_b = uninitialized;
    // 640 x 480 x 7 bit { Arrggbb } colour bitmap
    bitmap bitmap_window <@video_clock,!video_reset> (
        gpu_clock <: gpu_clock,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> bitmap_r,
        pix_green  :> bitmap_g,
        pix_blue   :> bitmap_b,
        bitmap_display :> bitmap_display,
        static1bit <: static1bit,
        static6bit <: static6bit
   );

    // Sprite Layers - Lower and Upper
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
        collision_layer_2 <: lower_tilemap_display,
        collision_layer_3 <: upper_tilemap_display,
        collision_layer_4 <: upper_sprites_display
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
        collision_layer_2 <: lower_tilemap_display,
        collision_layer_3 <: upper_tilemap_display,
        collision_layer_4 <: lower_sprites_display
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

        lower_tilemap_r <: lower_tilemap_r,
        lower_tilemap_g <: lower_tilemap_g,
        lower_tilemap_b <: lower_tilemap_b,
        lower_tilemap_display <: lower_tilemap_display,

        upper_tilemap_r <: upper_tilemap_r,
        upper_tilemap_g <: upper_tilemap_g,
        upper_tilemap_b <: upper_tilemap_b,
        upper_tilemap_display <: upper_tilemap_display,

        lower_sprites_r <: lower_sprites_r,
        lower_sprites_g <: lower_sprites_g,
        lower_sprites_b <: lower_sprites_b,
        lower_sprites_display <: lower_sprites_display,

        upper_sprites_r <: upper_sprites_r,
        upper_sprites_g <: upper_sprites_g,
        upper_sprites_b <: upper_sprites_b,
        upper_sprites_display <: upper_sprites_display,

        bitmap_r <: bitmap_r,
        bitmap_g <: bitmap_g,
        bitmap_b <: bitmap_b,
        bitmap_display <: bitmap_display,

        character_map_r <: character_map_r,
        character_map_g <: character_map_g,
        character_map_b <: character_map_b,
        character_map_display <: character_map_display
    );

    // Left and Right audio channels
    apu apu_processor_L <@clock_25mhz> (
        staticGenerator <: static4bit,
        audio_output :> audio_l
    );
    apu apu_processor_R <@clock_25mhz> (
        staticGenerator <: static4bit,
        audio_output :> audio_r
    );

    // UART CONTROLLER, CONTAINS BUFFERS FOR INPUT/OUTPUT
    uart UART(
        uart_tx :> uart_tx,
        uart_rx <: uart_rx
    );

    // PS2 CONTROLLER, CONTAINS BUFFERS FOR INPUT/OUTPUT
    ps2buffer PS2 <@clock_25mhz> (
        clock_25mhz <: clock_25mhz,
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn
    );

    // SDCARD AND BUFFER
    sdcardbuffer SDCARD(
        sd_clk :> sd_clk,
        sd_mosi :> sd_mosi,
        sd_csn :> sd_csn,
        sd_miso <: sd_miso
    );

    // LATCH MEMORYREAD MEMORYWRITE
    uint1   LATCHmemoryRead = uninitialized;
    uint1   LATCHmemoryWrite = uninitialized;

    // register buttons
    //uint$NUM_BTNS$ reg_btns = 0;
    //reg_btns ::= btns;

    // UART FLAGS
    UART.inread := 0;
    UART.outwrite := 0;

    // SDCARD FLAGS
    SDCARD.readsector := 0;

    // DISBLE SMT ON STARTUP
    SMTRUNNING = 0;
    SMTSTARTPC = 0;

    while(1) {
        // READ IO Memory
        if( memoryRead && ~LATCHmemoryRead ) {
            switch( memoryAddress[0,16] ) {
                // UART, LEDS, BUTTONS and CLOCK
                case 16hf100: { readData = { 8b0, UART.inchar }; UART.inread = 1; }
                case 16hf102: { readData = { 14b0, UART.outfull, UART.inavailable }; }
                case 16hf120: { readData = { $16-NUM_BTNS$b0, btns[0,$NUM_BTNS$] }; }
                case 16hf130: { readData = leds; }
                // PS2
                case 16hf110: { readData = PS2.inavailable; }
                case 16hf112: { readData = PS2.inchar; PS2.inread = 1; }

                // TILE MAP
                case 16h8120: { readData = lower_tile_map.tm_lastaction; }
                case 16h8122: { readData = lower_tile_map.tm_active; }
                case 16h8220: { readData = upper_tile_map.tm_lastaction; }
                case 16h8222: { readData = upper_tile_map.tm_active; }

                // LOWER SPRITE LAYER - MAIN
                case 16h8302: { readData = lower_sprites.sprite_read_active; }
                case 16h8304: { readData = lower_sprites.sprite_read_tile; }
                case 16h8306: { readData = lower_sprites.sprite_read_colour; }
                case 16h8308: { readData = __unsigned(lower_sprites.sprite_read_x); }
                case 16h830a: { readData = __unsigned(lower_sprites.sprite_read_y); }
                case 16h830c: { readData = lower_sprites.sprite_read_double; }

                // LOWER SPRITE LAYER - SMT
                case 16h8312: { readData = lower_sprites.sprite_read_active_SMT; }
                case 16h8314: { readData = lower_sprites.sprite_read_tile_SMT; }
                case 16h8316: { readData = lower_sprites.sprite_read_colour_SMT; }
                case 16h8318: { readData = __unsigned(lower_sprites.sprite_read_x_SMT); }
                case 16h831a: { readData = __unsigned(lower_sprites.sprite_read_y_SMT); }
                case 16h831c: { readData = lower_sprites.sprite_read_double_SMT; }

                // LOWER SPRITE LAYER - COLLISION DETECTION
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
                case 16h834a: { readData = lower_sprites.collision_13; }
                case 16h834c: { readData = lower_sprites.collision_14; }
                case 16h834e: { readData = lower_sprites.collision_15; }
                case 16h8350: { readData = lower_sprites.layer_collision_0; }
                case 16h8352: { readData = lower_sprites.layer_collision_1; }
                case 16h8354: { readData = lower_sprites.layer_collision_2; }
                case 16h8356: { readData = lower_sprites.layer_collision_3; }
                case 16h8358: { readData = lower_sprites.layer_collision_4; }
                case 16h835a: { readData = lower_sprites.layer_collision_5; }
                case 16h835c: { readData = lower_sprites.layer_collision_6; }
                case 16h835e: { readData = lower_sprites.layer_collision_7; }
                case 16h8360: { readData = lower_sprites.layer_collision_8; }
                case 16h8362: { readData = lower_sprites.layer_collision_9; }
                case 16h8364: { readData = lower_sprites.layer_collision_10; }
                case 16h8366: { readData = lower_sprites.layer_collision_11; }
                case 16h8368: { readData = lower_sprites.layer_collision_12; }
                case 16h836a: { readData = lower_sprites.layer_collision_13; }
                case 16h836c: { readData = lower_sprites.layer_collision_14; }
                case 16h836e: { readData = lower_sprites.layer_collision_15; }

                // GPU and BITMAP
                case 16h8612: { readData = ( bitmap_window.gpu_active || bitmap_window.vector_block_active ) ? 1 : 0; }
                case 16h862a: { readData = bitmap_window.vector_block_active; }
                case 16h8674: { readData = bitmap_window.bitmap_colour_read; }

                // UPPER SPRITE LAYER - MAIN
                case 16h8402: { readData = upper_sprites.sprite_read_active; }
                case 16h8404: { readData = upper_sprites.sprite_read_tile; }
                case 16h8406: { readData = upper_sprites.sprite_read_colour; }
                case 16h8408: { readData = __unsigned(upper_sprites.sprite_read_x); }
                case 16h840a: { readData = __unsigned(upper_sprites.sprite_read_y); }
                case 16h840c: { readData = upper_sprites.sprite_read_double; }

                // UPPER SPRITE LAYER - SMT
                case 16h8412: { readData = upper_sprites.sprite_read_active_SMT; }
                case 16h8414: { readData = upper_sprites.sprite_read_tile_SMT; }
                case 16h8416: { readData = upper_sprites.sprite_read_colour_SMT; }
                case 16h8418: { readData = __unsigned(upper_sprites.sprite_read_x_SMT); }
                case 16h841a: { readData = __unsigned(upper_sprites.sprite_read_y_SMT); }
                case 16h841c: { readData = upper_sprites.sprite_read_double_SMT; }

                // UPPER SPRITE LAYER - COLLISION DETECTION
                case 16h8430: { readData = upper_sprites.collision_0; }
                case 16h8432: { readData = upper_sprites.collision_1; }
                case 16h8434: { readData = upper_sprites.collision_2; }
                case 16h8436: { readData = upper_sprites.collision_3; }
                case 16h8438: { readData = upper_sprites.collision_4; }
                case 16h843a: { readData = upper_sprites.collision_5; }
                case 16h843c: { readData = upper_sprites.collision_6; }
                case 16h843e: { readData = upper_sprites.collision_7; }
                case 16h8440: { readData = upper_sprites.collision_8; }
                case 16h8442: { readData = upper_sprites.collision_9; }
                case 16h8444: { readData = upper_sprites.collision_10; }
                case 16h8446: { readData = upper_sprites.collision_11; }
                case 16h8448: { readData = upper_sprites.collision_12; }
                case 16h844a: { readData = upper_sprites.collision_13; }
                case 16h844c: { readData = upper_sprites.collision_14; }
                case 16h844e: { readData = upper_sprites.collision_15; }
                case 16h8450: { readData = upper_sprites.layer_collision_0; }
                case 16h8452: { readData = upper_sprites.layer_collision_1; }
                case 16h8454: { readData = upper_sprites.layer_collision_2; }
                case 16h8456: { readData = upper_sprites.layer_collision_3; }
                case 16h8458: { readData = upper_sprites.layer_collision_4; }
                case 16h845a: { readData = upper_sprites.layer_collision_5; }
                case 16h845c: { readData = upper_sprites.layer_collision_6; }
                case 16h845e: { readData = upper_sprites.layer_collision_7; }
                case 16h8460: { readData = upper_sprites.layer_collision_8; }
                case 16h8462: { readData = upper_sprites.layer_collision_9; }
                case 16h8464: { readData = upper_sprites.layer_collision_10; }
                case 16h8466: { readData = upper_sprites.layer_collision_11; }
                case 16h8468: { readData = upper_sprites.layer_collision_12; }
                case 16h846a: { readData = upper_sprites.layer_collision_13; }
                case 16h846c: { readData = upper_sprites.layer_collision_14; }
                case 16h846e: { readData = upper_sprites.layer_collision_15; }

                // CHARACTER MAP
                case 16h8504: { readData = character_map_window.curses_character; }
                case 16h8506: { readData = character_map_window.curses_background; }
                case 16h8508: { readData = character_map_window.curses_foreground; }
                case 16h850a: { readData = character_map_window.tpu_active; }

                // AUDIO
                case 16hf204: { readData = apu_processor_L.audio_active; }
                case 16hf214: { readData = apu_processor_R.audio_active; }

                // TIMERS and RNG
                case 16hf000: { readData = timers.g_noise_out; }
                case 16hf002: { readData = timers.u_noise_out; }
                case 16hf010: { readData = timers.timer1hz0; }
                case 16hf012: { readData = timers.timer1hz1; }
                case 16hf020: { readData = timers.timer1khz0; }
                case 16hf022: { readData = timers.timer1khz1; }
                case 16hf030: { readData = timers.sleepTimer0; }
                case 16hf032: { readData = timers.sleepTimer1; }
                case 16hf040: { readData = timers.systemclock; }

                // SDCARD
                case 16hf140: { readData = SDCARD.ready; }
                case 16hf150: { readData = SDCARD.bufferdata; }

                // VBLANK
                case 16hf800: { readData = vblank ? 1 : 0; }

                // SMT STATUS
                case 16hfffe: { readData = SMTRUNNING ? 1 : 0; }

                // RETURN NULL VALUE
                default: { readData = 0; }
            }
        }

        // WRITE IO Memory
        if( memoryWrite && ~LATCHmemoryWrite ) {
            switch( memoryAddress[0,16] ) {
                // UART, LEDS
                case 16hf100: { UART.outchar = writeData[0,8]; UART.outwrite = 1; }
                case 16hf130: { leds = writeData; }

                // BACKGROUND
                case 16h8000: { background_generator.backgroundcolour = writeData; background_generator.background_update = 1; }
                case 16h8002: { background_generator.backgroundcolour_alt = writeData; background_generator.background_update = 2; }
                case 16h8004: { background_generator.backgroundcolour_mode = writeData; background_generator.background_update = 3; }
                case 16h8010: { background_generator.copper_program = writeData; }
                case 16h8012: { background_generator.copper_status = writeData; }
                case 16h8020: { background_generator.copper_address = writeData; }
                case 16h8022: { background_generator.copper_command = writeData; }
                case 16h8024: { background_generator.copper_condition = writeData; }
                case 16h8026: { background_generator.copper_coordinate = writeData; }
                case 16h8028: { background_generator.copper_mode = writeData; }
                case 16h802a: { background_generator.copper_alt = writeData; }
                case 16h802c: { background_generator.copper_colour = writeData; }

                // TILE MAP
                case 16h8100: { lower_tile_map.tm_x = writeData; }
                case 16h8102: { lower_tile_map.tm_y = writeData; }
                case 16h8104: { lower_tile_map.tm_character = writeData; }
                case 16h8106: { lower_tile_map.tm_background = writeData; }
                case 16h8108: { lower_tile_map.tm_foreground = writeData; }
                case 16h810a: { lower_tile_map.tm_write = 1; }
                case 16h8110: { lower_tile_map.tile_writer_tile = writeData; }
                case 16h8112: { lower_tile_map.tile_writer_line = writeData; }
                case 16h8114: { lower_tile_map.tile_writer_bitmap = writeData; }
                case 16h8120: { lower_tile_map.tm_scrollwrap = writeData; }

                case 16h8200: { upper_tile_map.tm_x = writeData; }
                case 16h8202: { upper_tile_map.tm_y = writeData; }
                case 16h8204: { upper_tile_map.tm_character = writeData; }
                case 16h8206: { upper_tile_map.tm_background = writeData; }
                case 16h8208: { upper_tile_map.tm_foreground = writeData; }
                case 16h820a: { upper_tile_map.tm_write = 1; }
                case 16h8210: { upper_tile_map.tile_writer_tile = writeData; }
                case 16h8212: { upper_tile_map.tile_writer_line = writeData; }
                case 16h8214: { upper_tile_map.tile_writer_bitmap = writeData; }
                case 16h8220: { upper_tile_map.tm_scrollwrap = writeData; }

                // LOWER SPRITE LAYER - MAIN
                case 16h8300: { lower_sprites.sprite_set_number = writeData; }
                case 16h8302: { lower_sprites.sprite_set_active = writeData; lower_sprites.sprite_layer_write = 1; }
                case 16h8304: { lower_sprites.sprite_set_tile = writeData; lower_sprites.sprite_layer_write = 2; }
                case 16h8306: { lower_sprites.sprite_set_colour = writeData; lower_sprites.sprite_layer_write = 3; }
                case 16h8308: { lower_sprites.sprite_set_x = writeData; lower_sprites.sprite_layer_write = 4; }
                case 16h830a: { lower_sprites.sprite_set_y = writeData; lower_sprites.sprite_layer_write = 5; }
                case 16h830c: { lower_sprites.sprite_set_double = writeData; lower_sprites.sprite_layer_write = 6; }
                case 16h830e: { lower_sprites.sprite_update = writeData; lower_sprites.sprite_layer_write = 10; }

                // LOWER SPRITE LAYER - SMT
                case 16h8310: { lower_sprites.sprite_set_number_SMT = writeData; }
                case 16h8312: { lower_sprites.sprite_set_active_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 1; }
                case 16h8314: { lower_sprites.sprite_set_tile_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 2; }
                case 16h8316: { lower_sprites.sprite_set_colour_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 3; }
                case 16h8318: { lower_sprites.sprite_set_x_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 4; }
                case 16h831a: { lower_sprites.sprite_set_y_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 5; }
                case 16h831c: { lower_sprites.sprite_set_double_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 6; }
                case 16h831e: { lower_sprites.sprite_update_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 10; }

                // LOWER SPRITE LAYER BITMAP WRITER
                case 16h8320: { lower_sprites.sprite_writer_sprite = writeData; }
                case 16h8322: { lower_sprites.sprite_writer_line = writeData; }
                case 16h8324: { lower_sprites.sprite_writer_bitmap = writeData; lower_sprites.sprite_writer_active = 1; }

                // GPU and BITMAP
                case 16h8600: { bitmap_window.gpu_x = writeData; }
                case 16h8602: { bitmap_window.gpu_y = writeData; }
                case 16h8604: { bitmap_window.gpu_colour = writeData; }
                case 16h8606: { bitmap_window.gpu_colour_alt = writeData; }
                case 16h8608: { bitmap_window.gpu_dithermode = writeData; }
                case 16h860a: { bitmap_window.gpu_param0 = writeData; }
                case 16h860c: { bitmap_window.gpu_param1 = writeData; }
                case 16h860e: { bitmap_window.gpu_param2 = writeData; }
                case 16h8610: { bitmap_window.gpu_param3 = writeData; }
                case 16h8612: { bitmap_window.gpu_write = writeData; }

                case 16h8620: { bitmap_window.vector_block_number = writeData; }
                case 16h8622: { bitmap_window.vector_block_colour = writeData; }
                case 16h8624: { bitmap_window.vector_block_xc = writeData; }
                case 16h8826: { bitmap_window.vector_block_yc = writeData; }
                case 16h8628: { bitmap_window.vector_block_scale = writeData; }
                case 16h862a: { bitmap_window.draw_vector = 1; }

                case 16h8630: { bitmap_window.vertices_writer_block = writeData; }
                case 16h8632: { bitmap_window.vertices_writer_vertex = writeData; }
                case 16h8634: { bitmap_window.vertices_writer_xdelta = writeData; }
                case 16h8636: { bitmap_window.vertices_writer_ydelta = writeData; }
                case 16h8638: { bitmap_window.vertices_writer_active = writeData; }

                case 16h8640: { bitmap_window.blit1_writer_tile = writeData; }
                case 16h8642: { bitmap_window.blit1_writer_line = writeData; }
                case 16h8644: { bitmap_window.blit1_writer_bitmap = writeData; }

                case 16h8650: { bitmap_window.character_writer_character = writeData; }
                case 16h8652: { bitmap_window.character_writer_line = writeData; }
                case 16h8654: { bitmap_window.character_writer_bitmap = writeData; }

                case 16h8660: { bitmap_window.colourblit_writer_tile = writeData; }
                case 16h8662: { bitmap_window.colourblit_writer_line = writeData; }
                case 16h8664: { bitmap_window.colourblit_writer_pixel = writeData; }
                case 16h8666: { bitmap_window.colourblit_writer_colour = writeData; }

                case 16h8670: { bitmap_window.bitmap_x_read = writeData; }
                case 16h8672: { bitmap_window.bitmap_y_read = writeData; }

                case 16h8680: { bitmap_window.bitmap_write_offset = writeData; }
                case 16h8690: { bitmap_window.framebuffer = writeData; }
                case 16h8692: { bitmap_window.writer_framebuffer = writeData; }

                // UPPER SPRITE LAYER - MAIN
                case 16h8400: { upper_sprites.sprite_set_number = writeData; }
                case 16h8402: { upper_sprites.sprite_set_active = writeData; upper_sprites.sprite_layer_write = 1; }
                case 16h8404: { upper_sprites.sprite_set_tile = writeData; upper_sprites.sprite_layer_write = 2; }
                case 16h8406: { upper_sprites.sprite_set_colour = writeData; upper_sprites.sprite_layer_write = 3; }
                case 16h8408: { upper_sprites.sprite_set_x = writeData; upper_sprites.sprite_layer_write = 4; }
                case 16h840a: { upper_sprites.sprite_set_y = writeData; upper_sprites.sprite_layer_write = 5; }
                case 16h840c: { upper_sprites.sprite_set_double = writeData; upper_sprites.sprite_layer_write = 6; }
                case 16h840e: { upper_sprites.sprite_update = writeData; upper_sprites.sprite_layer_write = 10; }

                // UPPER SPRITE LAYER - SMT
                case 16h8410: { upper_sprites.sprite_set_number_SMT = writeData; }
                case 16h8412: { upper_sprites.sprite_set_active_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 1; }
                case 16h8414: { upper_sprites.sprite_set_tile_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 2; }
                case 16h8416: { upper_sprites.sprite_set_colour_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 3; }
                case 16h8418: { upper_sprites.sprite_set_x_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 4; }
                case 16h841a: { upper_sprites.sprite_set_y_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 5; }
                case 16h841c: { upper_sprites.sprite_set_double_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 6; }
                case 16h841e: { upper_sprites.sprite_update_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 10; }

                // UPPER SPRITE LAYER BITMAP WRITER
                case 16h8420: { upper_sprites.sprite_writer_sprite = writeData; }
                case 16h8422: { upper_sprites.sprite_writer_line = writeData; }
                case 16h8424: { upper_sprites.sprite_writer_bitmap = writeData; upper_sprites.sprite_writer_active = 1; }

                // CHARACTER MAP
                case 16h8500: { character_map_window.tpu_x = writeData; }
                case 16h8502: { character_map_window.tpu_y = writeData; }
                case 16h8504: { character_map_window.tpu_character = writeData; }
                case 16h8506: { character_map_window.tpu_background = writeData; }
                case 16h8508: { character_map_window.tpu_foreground = writeData; }
                case 16h850a: { character_map_window.tpu_write = writeData; }

                // AUDIO
                case 16hf200: { apu_processor_L.waveform = writeData; }
                case 16hf202: { apu_processor_L.note = writeData; }
                case 16hf204: { apu_processor_L.duration = writeData; }
                case 16hf206: { apu_processor_L.apu_write = writeData; }
                case 16hf210: { apu_processor_R.waveform = writeData; }
                case 16hf212: { apu_processor_R.note = writeData; }
                case 16hf214: { apu_processor_R.duration = writeData; }
                case 16hf216: { apu_processor_R.apu_write = writeData; }

                // TIMERS and RNG
                case 16hf010: { timers.resetcounter = 1; }
                case 16hf012: { timers.resetcounter = 2; }
                case 16hf020: { timers.counter = writeData; timers.resetcounter = 3; }
                case 16hf022: { timers.counter = writeData; timers.resetcounter = 4; }
                case 16hf030: { timers.counter = writeData; timers.resetcounter = 5; }
                case 16hf032: { timers.counter = writeData; timers.resetcounter = 6; }

                // SDCARD
                case 16hf140: { SDCARD.readsector = 1; }
                case 16hf142: { SDCARD.sectoraddressH = writeData; }
                case 16hf144: { SDCARD.sectoraddressL = writeData; }
                case 16hf150: { SDCARD.bufferaddress = writeData; }

                 // DISPLAY LAYER ORDERING / FRAMEBUFFER SELECTION
                case 16hf800: { display.display_order = writeData; }

                // SMT STATUS
                case 16hfff0: { SMTSTARTPC[16,16] = writeData; }
                case 16hfff2: { SMTSTARTPC[0,16] = writeData; }
                case 16hfffe: { SMTRUNNING = writeData; }
            }
        }

        // RESET Co-Processor Controls
        // IO memory map runs at 50MHz, display co-processors at 25MHz
        // Delay to reset co-processors therefore required
        if( ~memoryWrite && ~LATCHmemoryWrite ) {
            // RESET DISPLAY Co-Processor Controls
            background_generator.background_update = 0;
            background_generator.copper_program = 0;
            lower_tile_map.tm_write = 0;
            lower_tile_map.tm_scrollwrap = 0;
            upper_tile_map.tm_write = 0;
            upper_tile_map.tm_scrollwrap = 0;
            lower_sprites.sprite_layer_write = 0;
            lower_sprites.sprite_layer_write_SMT = 0;
            lower_sprites.sprite_writer_active = 0;
            upper_sprites.sprite_layer_write = 0;
            upper_sprites.sprite_layer_write_SMT = 0;
            upper_sprites.sprite_writer_active = 0;
            bitmap_window.bitmap_write_offset = 0;
            bitmap_window.gpu_write = 0;
            bitmap_window.draw_vector = 0;
            character_map_window.tpu_write = 0;

            // RESET TIMER and AUDIO Co-Processor Controls
            timers.resetcounter = 0;
            apu_processor_L.apu_write = 0;
            apu_processor_R.apu_write = 0;

            // RESET PS2 Buffer Controls
            PS2.inread = 0;
        }

        LATCHmemoryRead = memoryRead;
        LATCHmemoryWrite = memoryWrite;
    } // while(1)
}

// TIMERS and RNG Controllers
algorithm timers_rng(
    output  uint16  systemclock,
    output  uint16  timer1hz0,
    output  uint16  timer1hz1,
    output  uint16  timer1khz0,
    output  uint16  timer1khz1,
    output  uint16  sleepTimer0,
    output  uint16  sleepTimer1,
    output  uint16  u_noise_out,
    output  uint16  g_noise_out,
    input   uint16  counter,
    input   uint3   resetcounter
) <autorun> {
    // RNG random number generator
    random rng( u_noise_out :> u_noise_out,  g_noise_out :> g_noise_out );

    // 1hz timers (p1hz used for systemClock, timer1hz for user purposes)
    pulse1hz P1( counter1hz :> systemclock );
    pulse1hz T1hz0( counter1hz :> timer1hz0 );
    pulse1hz T1hz1( counter1hz :> timer1hz1 );

    // 1khz timers (sleepTimers used for sleep command, timer1khzs for user purposes)
    pulse1khz T0khz0( counter1khz :> timer1khz0 );
    pulse1khz T1khz1( counter1khz :> timer1khz1 );
    pulse1khz STimer0( counter1khz :> sleepTimer0 );
    pulse1khz STimer1( counter1khz :> sleepTimer1 );

    P1.resetCounter := 0;
    T1hz0.resetCounter := 0;
    T1hz1.resetCounter := 0;
    T0khz0.resetCounter := 0;
    T1khz1.resetCounter := 0;
    STimer0.resetCounter := 0;
    STimer1.resetCounter := 0;

    while(1) {
        switch( resetcounter ) {
            case 1: { T1hz0.resetCounter = 1; }
            case 2: { T1hz1.resetCounter = 1; }
            case 3: { T0khz0.resetCounter = counter; }
            case 4: { T1khz1.resetCounter = counter; }
            case 5: { STimer0.resetCounter = counter; }
            case 6: { STimer1.resetCounter = counter; }
        }
    }
}

// UART BUFFER CONTROLLER
algorithm uart(
    // UART
    output  uint1   uart_tx,
    input   uint1   uart_rx,

    output  uint1   inavailable,
    output  uint1   outfull,

    output  uint8   inchar,
    input   uint1   inread,
    input   uint8   outchar,
    input   uint1   outwrite
) <autorun> {
    uint1   update = uninitialized;

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

    // UART input FIFO (256 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartInBuffer <input!> [256] = uninitialized;
    uint8  uartInBufferNext = 0;
    uint8  uartInBufferTop = 0;

    // UART output FIFO (256 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartOutBuffer <input!> [256] = uninitialized;
    uint8   uartOutBufferNext = 0;
    uint8   uartOutBufferTop = 0;
    uint8   newuartOutBufferTop = 0;

    // FLAGS
    inavailable := ( uartInBufferNext != uartInBufferTop ) ? 1b1 : 1b0;
    outfull := ( uartOutBufferTop + 1 == uartOutBufferNext ) ? 1b1 : 1b0;
    inchar := uartInBuffer.rdata0;

    // UART Buffers ( code from @sylefeb )
    uartInBuffer.wenable1 := 1;  // always write on port 1
    uartInBuffer.addr0 := uartInBufferNext; // FIFO reads on next
    uartInBuffer.addr1 := uartInBufferTop;  // FIFO writes on top
    uartOutBuffer.wenable1 := 1; // always write on port 1
    uartOutBuffer.addr0 := uartOutBufferNext; // FIFO reads on next
    uartInBuffer.wdata1 := ui.data_out;
    uartInBufferTop := ui.data_out_ready ? uartInBufferTop + 1 : uartInBufferTop;
    uo.data_in := uartOutBuffer.rdata0;
    uo.data_in_ready := ( uartOutBufferNext != uartOutBufferTop ) && ( !uo.busy );
    uartOutBufferNext := ( (uartOutBufferNext != uartOutBufferTop) && ( !uo.busy ) ) ? uartOutBufferNext + 1 : uartOutBufferNext;

    always {
        if( outwrite ) {
            uartOutBuffer.addr1 = uartOutBufferTop;
            uartOutBuffer.wdata1 = outchar;
            update = 1;
        } else {
            if( update != 0 ) {
                uartOutBufferTop = uartOutBufferTop + 1;
                update = 0;
            }
        }
    }
    while(1) {
        if( inread ) {
            uartInBufferNext = uartInBufferNext + 1;
        }
    }
}

// PS2 BUFFER CONTROLLER
algorithm ps2buffer(
    input   uint1   clock_25mhz,

    // USB for PS/2
    input   uint1   us2_bd_dp,
    input   uint1   us2_bd_dn,

    output  uint1   inavailable,
    output  uint8   inchar,
    input   uint1   inread
) <autorun> {
    uint1   update = uninitialized;

    // PS/2 input FIFO (256 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 ps2Buffer <input!> [256] = uninitialized;
    uint8  ps2BufferNext = 0;
    uint7  ps2BufferTop = 0;

    // PS 2 ASCII
    ps2ascii PS2(
        clock_25mhz <: clock_25mhz,
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,
    );

    // PS2 Buffers
    ps2Buffer.wenable1 := 1;  // always write on port 1
    ps2Buffer.addr0 := ps2BufferNext; // FIFO reads on next

    // FLAGS
    inavailable := ( ps2BufferNext != ps2BufferTop ) ? 1 : 0;
    inchar := ps2Buffer.rdata0;

    always {
        if( PS2.asciivalid ) {
            ps2Buffer.addr1 = ps2BufferTop;
            ps2Buffer.wdata1 = PS2.ascii;
            update = 1;
        } else {
            if( update != 0 ) {
                ps2BufferTop = ps2BufferTop + 1;
                update = 0;
            }
        }
    }

    while(1) {
        if( inread ) {
            ps2BufferNext = ps2BufferNext + 1;
        }
    }
}

// SDCARD AND BUFFER CONTROLLER
algorithm sdcardbuffer(
    // SDCARD
    output  uint1   sd_clk,
    output  uint1   sd_mosi,
    output  uint1   sd_csn,
    input   uint1   sd_miso,

    input   uint1   readsector,
    input   uint16  sectoraddressH,
    input   uint16  sectoraddressL,
    input   uint9   bufferaddress,
    output  uint1   ready,
    output  uint8   bufferdata
) <autorun> {
    // SDCARD - Code for the SDCARD from @sylefeb
    simple_dualport_bram uint8 sdbuffer[512] = uninitialized;
    sdcardio sdcio;
    sdcard sd(
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

    // SDCARD Commands
    sdcio.read_sector := readsector;
    sdcio.addr_sector := { sectoraddressH, sectoraddressL };
    sdbuffer.addr0 := bufferaddress;
    ready := sdcio.ready;
    bufferdata := sdbuffer.rdata0;
}
