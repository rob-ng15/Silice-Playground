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
    // 1hz timers (p1hz used for systemClock, timer1hz for user purposes)
    uint16 systemClock = uninitialized;
    pulse1hz p1hz <@clock_25mhz> (
        counter1hz :> systemClock,
    );
    pulse1hz timer1hz0 <@clock_25mhz> ( );
    pulse1hz timer1hz1 <@clock_25mhz> ( );

    // 1khz timers (sleepTimers used for sleep command, timer1khzs for user purposes)
    pulse1khz sleepTimer0 <@clock_25mhz> ( );
    pulse1khz timer1khz0 <@clock_25mhz> ( );
    pulse1khz sleepTimer1 <@clock_25mhz> ( );
    pulse1khz timer1khz1 <@clock_25mhz> ( );

    // RNG random number generator
    uint16  staticGenerator = uninitialized;
    uint16  staticGeneratorALT = uninitialized;
    uint1   static1bit <: staticGenerator[0,1];
    uint2   static2bit <: staticGenerator[0,2];
    uint4   static4bit <: staticGenerator[0,4];
    uint6   static6bit <: staticGenerator[0,6];
    random rng <@clock_25mhz> (
        g_noise_out :> staticGenerator,
        u_noise_out :> staticGeneratorALT
    );

    // HDMI driver
    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1   vblank = uninitialized;
    uint1   pix_active = uninitialized;
    uint10  pix_x  = uninitialized;
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
    uint10  pix_y  = uninitialized;
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

    // Bitmap Window
    uint2   bitmap_r = uninitialized;
    uint2   bitmap_g = uninitialized;
    uint2   bitmap_b = uninitialized;
    uint9  x_offset = uninitialized;
    uint8  y_offset = uninitialized;
    // From GPU to set a pixel
    uint1   bitmap_display = uninitialized;
    int10   bitmap_x_write = uninitialized;
    int10   bitmap_y_write = uninitialized;
    uint7   bitmap_colour_write = uninitialized;
    uint7   bitmap_colour_write_alt = uninitialized;
    uint4   gpu_active_dithermode = uninitialized;
    uint1   bitmap_write = uninitialized;
    // 640 x 480 x 7 bit { Arrggbb } colour bitmap
    simple_dualport_bram uint7 bitmap_0 <@video_clock,@gpu_clock,input!> [ 76800 ] = uninitialized;
    simple_dualport_bram uint7 bitmap_1 <@video_clock,@gpu_clock,input!> [ 76800 ] = uninitialized;
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
        bitmap_0 <:> bitmap_0,
        bitmap_1 <:> bitmap_1
    );
    bitmapwriter pixel_writer <@gpu_clock> (
        bitmap_x_write <: bitmap_x_write,
        bitmap_y_write <: bitmap_y_write,
        bitmap_colour_write <: bitmap_colour_write,
        bitmap_colour_write_alt <: bitmap_colour_write_alt,
        bitmap_write <: bitmap_write,
        gpu_active_dithermode <: gpu_active_dithermode,
        static1bit <: static1bit,
        static6bit <: static6bit,
        x_offset <: x_offset,
        y_offset <: y_offset,
        bitmap_0 <:> bitmap_0,
        bitmap_1 <:> bitmap_1
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

    gpu gpu_processor <@gpu_clock> (
        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_colour_write :> bitmap_colour_write,
        bitmap_colour_write_alt :> bitmap_colour_write_alt,
        bitmap_write :> bitmap_write,
        gpu_active_dithermode :> gpu_active_dithermode
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
    uint$NUM_BTNS$ reg_btns = 0;
    reg_btns ::= btns;

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
                case 16h8000: { readData = { 8b0, UART.inchar }; UART.inread = 1; }
                case 16h8004: { readData = { 14b0, UART.outfull, UART.inavailable }; }
                case 16h8008: { readData = { $16-NUM_BTNS$b0, reg_btns[0,$NUM_BTNS$] }; }
                case 16h800c: { readData = leds; }
                case 16h8010: { readData = systemClock; }

                // PS2
                case 16h8040: { readData = PS2.inavailable; }
                case 16h8044: { readData = PS2.inchar; PS2.inread = 1; }

                // BACKGROUND

                // TILE MAP
                case 16h8230: { readData = lower_tile_map.tm_lastaction; }
                case 16h8234: { readData = lower_tile_map.tm_active; }
                case 16h82b0: { readData = upper_tile_map.tm_lastaction; }
                case 16h82b4: { readData = upper_tile_map.tm_active; }

                // LOWER SPRITE LAYER - MAIN
                case 16h8304: { readData = lower_sprites.sprite_read_active; }
                case 16h8308: { readData = lower_sprites.sprite_read_tile; }
                case 16h830c: { readData = lower_sprites.sprite_read_colour; }
                case 16h8310: { readData = __unsigned(lower_sprites.sprite_read_x); }
                case 16h8314: { readData = __unsigned(lower_sprites.sprite_read_y); }
                case 16h8318: { readData = lower_sprites.sprite_read_double; }

                // LOWER SPRITE LAYER - SMT
                case 16h9304: { readData = lower_sprites.sprite_read_active_SMT; }
                case 16h9308: { readData = lower_sprites.sprite_read_tile_SMT; }
                case 16h930c: { readData = lower_sprites.sprite_read_colour_SMT; }
                case 16h9310: { readData = __unsigned(lower_sprites.sprite_read_x_SMT); }
                case 16h9314: { readData = __unsigned(lower_sprites.sprite_read_y_SMT); }
                case 16h9318: { readData = lower_sprites.sprite_read_double_SMT; }

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
                case 16h841c: { readData = ( gpu_processor.gpu_active || gpu_processor.vector_block_active ) ? 1 : 0; }
                case 16h8448: { readData = gpu_processor.vector_block_active ? 1 : 0; }
                case 16h8470: { readData = bitmap_window.bitmap_colour_read; }

                // UPPER SPRITE LAYER - MAIN
                case 16h8504: { readData = upper_sprites.sprite_read_active; }
                case 16h8508: { readData = upper_sprites.sprite_read_tile; }
                case 16h850c: { readData = upper_sprites.sprite_read_colour; }
                case 16h8510: { readData = __unsigned(upper_sprites.sprite_read_x); }
                case 16h8514: { readData = __unsigned(upper_sprites.sprite_read_y); }
                case 16h8518: { readData = upper_sprites.sprite_read_double; }

                // UPPER SPRITE LAYER - SMT
                case 16h9504: { readData = upper_sprites.sprite_read_active_SMT; }
                case 16h9508: { readData = upper_sprites.sprite_read_tile_SMT; }
                case 16h950c: { readData = upper_sprites.sprite_read_colour_SMT; }
                case 16h9510: { readData = __unsigned(upper_sprites.sprite_read_x_SMT); }
                case 16h9514: { readData = __unsigned(upper_sprites.sprite_read_y_SMT); }
                case 16h9518: { readData = upper_sprites.sprite_read_double_SMT; }

                // UPPER SPRITE LAYER - COLLISION DETECTION
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
                case 16h854a: { readData = upper_sprites.collision_13; }
                case 16h854c: { readData = upper_sprites.collision_14; }
                case 16h854e: { readData = upper_sprites.collision_15; }
                case 16h8550: { readData = upper_sprites.layer_collision_0; }
                case 16h8552: { readData = upper_sprites.layer_collision_1; }
                case 16h8554: { readData = upper_sprites.layer_collision_2; }
                case 16h8556: { readData = upper_sprites.layer_collision_3; }
                case 16h8558: { readData = upper_sprites.layer_collision_4; }
                case 16h855a: { readData = upper_sprites.layer_collision_5; }
                case 16h855c: { readData = upper_sprites.layer_collision_6; }
                case 16h855e: { readData = upper_sprites.layer_collision_7; }
                case 16h8560: { readData = upper_sprites.layer_collision_8; }
                case 16h8562: { readData = upper_sprites.layer_collision_9; }
                case 16h8564: { readData = upper_sprites.layer_collision_10; }
                case 16h8566: { readData = upper_sprites.layer_collision_11; }
                case 16h8568: { readData = upper_sprites.layer_collision_12; }
                case 16h856a: { readData = upper_sprites.layer_collision_13; }
                case 16h856c: { readData = upper_sprites.layer_collision_14; }
                case 16h856e: { readData = upper_sprites.layer_collision_15; }

                // CHARACTER MAP
                case 16h8614: { readData = character_map_window.tpu_active; }

                // AUDIO
                case 16h8808: { readData = apu_processor_L.audio_active; }
                case 16h8818: { readData = apu_processor_R.audio_active; }

                // TIMERS and RNG
                case 16h8900: { readData = staticGenerator; }
                case 16h8904: { readData = staticGeneratorALT; }
                case 16h8910: { readData = timer1hz0.counter1hz; }
                case 16h8920: { readData = timer1khz0.counter1khz; }
                case 16h8930: { readData = sleepTimer0.counter1khz; }
                case 16h8914: { readData = timer1hz1.counter1hz; }
                case 16h8924: { readData = timer1khz1.counter1khz; }
                case 16h8934: { readData = sleepTimer1.counter1khz; }

                // SDCARD
                case 16h8f00: { readData = SDCARD.ready; }
                case 16h8f10: { readData = SDCARD.bufferdata; }

                // VBLANK
                case 16h8ff0: { readData = vblank ? 1 : 0; }

                // SMT STATUS
                case 16hffff: { readData = SMTRUNNING ? 1 : 0; }

                // RETURN NULL VALUE
                default: { readData = 0; }
            }
        }

        // WRITE IO Memory
        if( memoryWrite && ~LATCHmemoryWrite ) {
            switch( memoryAddress[0,16] ) {
                // UART, LEDS
                case 16h8000: { UART.outchar = writeData[0,8]; UART.outwrite = 1; }
                case 16h800c: { leds = writeData; }

                // BACKGROUND
                case 16h8100: { background_generator.backgroundcolour = writeData; background_generator.background_update = 1; }
                case 16h8104: { background_generator.backgroundcolour_alt = writeData; background_generator.background_update = 2; }
                case 16h8108: { background_generator.backgroundcolour_mode = writeData; background_generator.background_update = 3; }
                case 16h8180: { background_generator.copper_program = writeData; }
                case 16h8181: { background_generator.copper_status = writeData; }
                case 16h8182: { background_generator.copper_address = writeData; }
                case 16h8183: { background_generator.copper_command = writeData; }
                case 16h8184: { background_generator.copper_condition = writeData; }
                case 16h8186: { background_generator.copper_coordinate = writeData; }
                case 16h8188: { background_generator.copper_mode = writeData; }
                case 16h8189: { background_generator.copper_alt = writeData; }
                case 16h818a: { background_generator.copper_colour = writeData; }

                // TILE MAP
                case 16h8200: { lower_tile_map.tm_x = writeData; }
                case 16h8204: { lower_tile_map.tm_y = writeData; }
                case 16h8208: { lower_tile_map.tm_character = writeData; }
                case 16h820c: { lower_tile_map.tm_background = writeData; }
                case 16h8210: { lower_tile_map.tm_foreground = writeData; }
                case 16h8214: { lower_tile_map.tm_write = 1; }
                case 16h8220: { lower_tile_map.tile_writer_tile = writeData; }
                case 16h8224: { lower_tile_map.tile_writer_line = writeData; }
                case 16h8228: { lower_tile_map.tile_writer_bitmap = writeData; }
                case 16h8230: { lower_tile_map.tm_scrollwrap = writeData; }
                case 16h8280: { upper_tile_map.tm_x = writeData; }
                case 16h8284: { upper_tile_map.tm_y = writeData; }
                case 16h8288: { upper_tile_map.tm_character = writeData; }
                case 16h828c: { upper_tile_map.tm_background = writeData; }
                case 16h8290: { upper_tile_map.tm_foreground = writeData; }
                case 16h8294: { upper_tile_map.tm_write = 1; }
                case 16h82a0: { upper_tile_map.tile_writer_tile = writeData; }
                case 16h82a4: { upper_tile_map.tile_writer_line = writeData; }
                case 16h82a8: { upper_tile_map.tile_writer_bitmap = writeData; }
                case 16h82b0: { upper_tile_map.tm_scrollwrap = writeData; }

                // LOWER SPRITE LAYER - MAIN
                case 16h8300: { lower_sprites.sprite_set_number = writeData; }
                case 16h8304: { lower_sprites.sprite_set_active = writeData; lower_sprites.sprite_layer_write = 1; }
                case 16h8308: { lower_sprites.sprite_set_tile = writeData; lower_sprites.sprite_layer_write = 2; }
                case 16h830c: { lower_sprites.sprite_set_colour = writeData; lower_sprites.sprite_layer_write = 3; }
                case 16h8310: { lower_sprites.sprite_set_x = writeData; lower_sprites.sprite_layer_write = 4; }
                case 16h8314: { lower_sprites.sprite_set_y = writeData; lower_sprites.sprite_layer_write = 5; }
                case 16h8318: { lower_sprites.sprite_set_double = writeData; lower_sprites.sprite_layer_write = 6; }
                case 16h831c: { lower_sprites.sprite_update = writeData; lower_sprites.sprite_layer_write = 10; }

                // LOWER SPRITE LAYER - SMT
                case 16h9300: { lower_sprites.sprite_set_number_SMT = writeData; }
                case 16h9304: { lower_sprites.sprite_set_active_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 1; }
                case 16h9308: { lower_sprites.sprite_set_tile_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 2; }
                case 16h930c: { lower_sprites.sprite_set_colour_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 3; }
                case 16h9310: { lower_sprites.sprite_set_x_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 4; }
                case 16h9314: { lower_sprites.sprite_set_y_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 5; }
                case 16h9318: { lower_sprites.sprite_set_double_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 6; }
                case 16h931c: { lower_sprites.sprite_update_SMT = writeData; lower_sprites.sprite_layer_write_SMT = 10; }

                // LOWER SPRITE LAYER BITMAP WRITER
                case 16h8320: { lower_sprites.sprite_writer_sprite = writeData; }
                case 16h8324: { lower_sprites.sprite_writer_line = writeData; }
                case 16h8328: { lower_sprites.sprite_writer_bitmap = writeData; lower_sprites.sprite_writer_active = 1; }

                // GPU and BITMAP
                case 16h8400: { gpu_processor.gpu_x = writeData; }
                case 16h8404: { gpu_processor.gpu_y = writeData; }
                case 16h8408: { gpu_processor.gpu_colour = writeData; }
                case 16h8409: { gpu_processor.gpu_colour_alt = writeData; }
                case 16h840a: { gpu_processor.gpu_dithermode = writeData; }
                case 16h840c: { gpu_processor.gpu_param0 = writeData; }
                case 16h8410: { gpu_processor.gpu_param1 = writeData; }
                case 16h8414: { gpu_processor.gpu_param2 = writeData; }
                case 16h8418: { gpu_processor.gpu_param3 = writeData; }
                case 16h841c: { gpu_processor.gpu_write = writeData; }

                case 16h8420: { gpu_processor.vector_block_number = writeData; }
                case 16h8424: { gpu_processor.vector_block_colour = writeData; }
                case 16h8428: { gpu_processor.vector_block_xc = writeData; }
                case 16h842c: { gpu_processor.vector_block_yc = writeData; }
                case 16h842e: { gpu_processor.vector_block_scale = writeData; }
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

                case 16h8490: { gpu_processor.colourblit_writer_tile = writeData; }
                case 16h8492: { gpu_processor.colourblit_writer_line = writeData; }
                case 16h8494: { gpu_processor.colourblit_writer_pixel = writeData; }
                case 16h8496: { gpu_processor.colourblit_writer_colour = writeData; }

                // UPPER SPRITE LAYER - MAIN
                case 16h8500: { upper_sprites.sprite_set_number = writeData; }
                case 16h8504: { upper_sprites.sprite_set_active = writeData; upper_sprites.sprite_layer_write = 1; }
                case 16h8508: { upper_sprites.sprite_set_tile = writeData; upper_sprites.sprite_layer_write = 2; }
                case 16h850c: { upper_sprites.sprite_set_colour = writeData; upper_sprites.sprite_layer_write = 3; }
                case 16h8510: { upper_sprites.sprite_set_x = writeData; upper_sprites.sprite_layer_write = 4; }
                case 16h8514: { upper_sprites.sprite_set_y = writeData; upper_sprites.sprite_layer_write = 5; }
                case 16h8518: { upper_sprites.sprite_set_double = writeData; upper_sprites.sprite_layer_write = 6; }
                case 16h851c: { upper_sprites.sprite_update = writeData; upper_sprites.sprite_layer_write = 10; }

                // UPPER SPRITE LAYER - SMT
                case 16h9500: { upper_sprites.sprite_set_number_SMT = writeData; }
                case 16h9504: { upper_sprites.sprite_set_active_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 1; }
                case 16h9508: { upper_sprites.sprite_set_tile_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 2; }
                case 16h950c: { upper_sprites.sprite_set_colour_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 3; }
                case 16h9510: { upper_sprites.sprite_set_x_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 4; }
                case 16h9514: { upper_sprites.sprite_set_y_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 5; }
                case 16h9518: { upper_sprites.sprite_set_double_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 6; }
                case 16h951c: { upper_sprites.sprite_update_SMT = writeData; upper_sprites.sprite_layer_write_SMT = 10; }

                // UPPER SPRITE LAYER BITMAP WRITER
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
                case 16h8910: { timer1hz0.resetCounter = 1; }
                case 16h8920: { timer1khz0.resetCount = writeData; }
                case 16h8930: { sleepTimer0.resetCount = writeData; }
                case 16h8914: { timer1hz1.resetCounter = 1; }
                case 16h8924: { timer1khz1.resetCount = writeData; }
                case 16h8934: { sleepTimer1.resetCount = writeData; }

                // SDCARD
                case 16h8f00: { SDCARD.readsector = 1; }
                case 16h8f04: { SDCARD.sectoraddressH = writeData; }
                case 16h8f08: { SDCARD.sectoraddressL = writeData; }
                case 16h8f10: { SDCARD.bufferaddress = writeData; }

                 // DISPLAY LAYER ORDERING / FRAMEBUFFER SELECTION
                case 16h8ff0: { display.display_order = writeData; }
                case 16h8ff2: { bitmap_window.framebuffer = writeData; }
                case 16h8ff4: { pixel_writer.framebuffer = writeData; }

                // SMT STATUS
                case 16hfff0: { SMTSTARTPC[16,16] = writeData; }
                case 16hfff2: { SMTSTARTPC[0,16] = writeData; }
                case 16hffff: { SMTRUNNING = writeData; }
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
            gpu_processor.gpu_write = 0;
            gpu_processor.draw_vector = 0;
            character_map_window.tpu_write = 0;

            // RESET TIMER and AUDIO Co-Processor Controls
            p1hz.resetCounter = 0;
            timer1hz0.resetCounter = 0;
            sleepTimer0.resetCount = 0;
            timer1khz0.resetCount = 0;
            timer1hz1.resetCounter = 0;
            sleepTimer1.resetCount = 0;
            timer1khz1.resetCount = 0;
            apu_processor_L.apu_write = 0;
            apu_processor_R.apu_write = 0;

            // RESET PS2 Buffer Controls
            PS2.inread = 0;
        }

        LATCHmemoryRead = memoryRead;
        LATCHmemoryWrite = memoryWrite;
    } // while(1)
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
    uartOutBuffer.addr1 := uartOutBufferTop;  // FIFO writes on top
    uartInBuffer.wdata1 := ui.data_out;
    uartInBufferTop := ui.data_out_ready ? uartInBufferTop + 1 : uartInBufferTop;
    uo.data_in := uartOutBuffer.rdata0;
    uo.data_in_ready := ( uartOutBufferNext != uartOutBufferTop ) && ( !uo.busy );
    uartOutBufferNext := ( (uartOutBufferNext != uartOutBufferTop) && ( !uo.busy ) ) ? uartOutBufferNext + 1 : uartOutBufferNext;

    while(1) {
        if( inread ) {
            uartInBufferNext = uartInBufferNext + 1;
        }
        if( outwrite ) {
            uartOutBuffer.wdata1 = outchar;
            uartOutBufferTop = uartOutBufferTop + 1;
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
    ps2Buffer.addr1 := ps2BufferTop;  // FIFO writes on top
    ps2Buffer.wdata1 := PS2.ascii;
    ps2BufferTop := PS2.asciivalid ? ps2BufferTop + 1 : ps2BufferTop;

    // FLAGS
    inavailable := ( ps2BufferNext != ps2BufferTop ) ? 1 : 0;
    inchar := ps2Buffer.rdata0;

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
