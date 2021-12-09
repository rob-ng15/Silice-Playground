algorithm passthrough(input uint1 i,output! uint1 o)
{
  always { o=i; }
}

algorithm video_memmap(
    // CLOCKS
    input   uint1   clock_25mhz,

    // Memory access
    input   uint12  memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,
    input   uint16  writeData,
    output  uint16  readData,
$$if HDMI then
    // HDMI OUTPUT
    output! uint4   gpdi_dp,
$$end
$$if VGA then
    // VGA OUTPUT
    output! uint$color_depth$ video_r,
    output! uint$color_depth$ video_g,
    output! uint$color_depth$ video_b,
    output  uint1 video_hs,
    output  uint1 video_vs,
$$end

    // RNG
    input   uint6   static6bit
) <autorun,reginputs> {
    // CURSOR CLOCK
    uint1   blink = uninitialised;
    pulsecursor CURSOR <@clock_video> ( show :> blink );

    // Video Reset
    uint1   video_reset = uninitialised; clean_reset sdram_rstcond<@clock_video,!reset> ( out :> video_reset );

    // HDMI driver
    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1   vblank = uninitialized;
    uint1   pix_active = uninitialized;
    uint10  pix_x  = uninitialized;
    uint10  pix_y  = uninitialized;
$$if VGA then
    uint1   clock_video <: clock_25mhz;
    uint1   clock_gpu <: clock;
  vga vga_driver<@clock_25mhz,!reset>(
    vga_hs :> video_hs,
    vga_vs :> video_vs,
    vga_x  :> pix_x,
    vga_y  :> pix_y,
    vblank :> vblank,
    active :> pix_active,
  );
$$end
$$if HDMI then
    uint1   clock_video = uninitialised;
    uint1   clock_gpu = uninitialised;
    uint1   pll_lock_VIDEO = uninitialized;
    ulx3s_clk_risc_ice_v_VIDEO clk_gen_VIDEO (
        clkin    <: clock_25mhz,
        clkGPU  :> clock_gpu,
        clkVIDEO  :> clock_video,
        locked   :> pll_lock_VIDEO
    );
    uint8   video_r = uninitialized;
    uint8   video_g = uninitialized;
    uint8   video_b = uninitialized;
    hdmi video<@clock_video,!reset> (
        vblank  :> vblank,
        active  :> pix_active,
        x       :> pix_x,
        y       :> pix_y,
        gpdi_dp :> gpdi_dp,
        red     <: video_r,
        green   <: video_g,
        blue    <: video_b
    );
$$end
    // CREATE DISPLAY LAYERS
    // BACKGROUND
    background_memmap BACKGROUND(
        video_clock <: clock_video,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        memoryAddress <: memoryAddress,
        writeData <: writeData,
        static2bit <: static6bit[0,2]
    );

    // Bitmap Window with GPU
    // 320 x 240 x 7 bit { Arrggbb } colour bitmap
    bitmap_memmap BITMAP(
        gpu_clock <: clock_gpu,
        video_clock <: clock_video,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        memoryAddress <: memoryAddress,
        writeData <: writeData,
        static6bit <: static6bit
    );

    // Character Map Window
    charactermap_memmap CHARACTER_MAP(
        video_clock <: clock_video,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        blink <: blink,
        memoryAddress <: memoryAddress,
        writeData <: writeData
    );

    // Sprite Layers - Lower and Upper
    sprite_memmap LOWER_SPRITE(
        video_clock <: clock_video,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        memoryAddress <: memoryAddress,
        writeData <: writeData,
        collision_layer_1 <: BITMAP.pixel_display,
        collision_layer_2 <: LOWER_TILE.pixel_display,
        collision_layer_3 <: UPPER_TILE.pixel_display,
        collision_layer_4 <: UPPER_SPRITE.pixel_display
    );
    sprite_memmap UPPER_SPRITE(
        video_clock <: clock_video,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        memoryAddress <: memoryAddress,
        writeData <: writeData,
        collision_layer_1 <: BITMAP.pixel_display,
        collision_layer_2 <: LOWER_TILE.pixel_display,
        collision_layer_3 <: UPPER_TILE.pixel_display,
        collision_layer_4 <: LOWER_SPRITE.pixel_display
    );

    // Terminal Window
    uint2   terminal_active = uninitialized;
    terminal_memmap TERMINAL(
        video_clock <: clock_video,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        blink <: blink,
        memoryAddress <: memoryAddress,
        writeData <: writeData
    );

    // Tilemaps - Lower and Upper
    tilemap_memmap LOWER_TILE(
        video_clock <: clock_video,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        memoryAddress <: memoryAddress,
        writeData <: writeData
    );
    tilemap_memmap UPPER_TILE(
        video_clock <: clock_video,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        memoryAddress <: memoryAddress,
        writeData <: writeData
    );

    // Combine the display layers for display
    multiplex_display display <@clock_video,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> video_r,
        pix_green  :> video_g,
        pix_blue   :> video_b,
        background_p <: BACKGROUND.pixel,
        lower_tilemap_p <: LOWER_TILE.pixel,
        lower_tilemap_display <: LOWER_TILE.pixel_display,
        upper_tilemap_p <: UPPER_TILE.pixel,
        upper_tilemap_display <: UPPER_TILE.pixel_display,
        lower_sprites_p <: LOWER_SPRITE.pixel,
        lower_sprites_display <: LOWER_SPRITE.pixel_display,
        upper_sprites_p <: UPPER_SPRITE.pixel,
        upper_sprites_display <: UPPER_SPRITE.pixel_display,
        bitmap_p <: BITMAP.pixel,
        bitmap_display <: BITMAP.pixel_display,
        character_map_p <: CHARACTER_MAP.pixel,
        character_map_display <: CHARACTER_MAP.pixel_display,
        terminal_p <: TERMINAL.pixel,
        terminal_display <: TERMINAL.pixel_display
    );

    BACKGROUND.memoryWrite := 0; BITMAP.memoryWrite := 0; CHARACTER_MAP.memoryWrite := 0; LOWER_SPRITE.memoryWrite := 0; UPPER_SPRITE.memoryWrite := 0; TERMINAL.memoryWrite := 0;
    LOWER_TILE.memoryWrite := 0; UPPER_TILE.memoryWrite := 0;

    always_before {
        // READ IO Memory
        if( memoryRead ) {
            switch( memoryAddress[8,4] ) {
                case 4h1: { readData = memoryAddress[1,1] ? LOWER_TILE.tm_active : LOWER_TILE.tm_lastaction; }
                case 4h2: { readData = memoryAddress[1,1] ? UPPER_TILE.tm_active : UPPER_TILE.tm_lastaction; }
                case 4h3: {
                    switch( memoryAddress[1,7] ) {
                        $$for i=0,15 do
                            case $0x00 + i$: { readData = LOWER_SPRITE.sprite_read_active_$i$; }
                            case $0x10 + i$: { readData = LOWER_SPRITE.sprite_read_double_$i$; }
                            case $0x20 + i$: { readData = LOWER_SPRITE.sprite_read_colour_$i$; }
                            case $0x30 + i$: { readData = {{5{LOWER_SPRITE.sprite_read_x_$i$[10,1]}}, LOWER_SPRITE.sprite_read_x_$i$}; }
                            case $0x40 + i$: { readData = {{6{LOWER_SPRITE.sprite_read_y_$i$[9,1]}}, LOWER_SPRITE.sprite_read_y_$i$}; }
                            case $0x50 + i$: { readData = LOWER_SPRITE.sprite_read_tile_$i$; }
                            case $0x60 + i$: { readData = LOWER_SPRITE.collision_$i$; }
                            case $0x70 + i$: { readData = LOWER_SPRITE.layer_collision_$i$; }
                        $$end
                    }
                }
                case 4h4: {
                    switch( memoryAddress[1,7] ) {
                        $$for i=0,15 do
                            case $0x00 + i$: { readData = UPPER_SPRITE.sprite_read_active_$i$; }
                            case $0x10 + i$: { readData = UPPER_SPRITE.sprite_read_double_$i$; }
                            case $0x20 + i$: { readData = UPPER_SPRITE.sprite_read_colour_$i$; }
                            case $0x30 + i$: { readData = {{5{UPPER_SPRITE.sprite_read_x_$i$[10,1]}}, UPPER_SPRITE.sprite_read_x_$i$}; }
                            case $0x40 + i$: { readData = {{6{UPPER_SPRITE.sprite_read_y_$i$[9,1]}}, UPPER_SPRITE.sprite_read_y_$i$}; }
                            case $0x50 + i$: { readData = UPPER_SPRITE.sprite_read_tile_$i$; }
                            case $0x60 + i$: { readData = UPPER_SPRITE.collision_$i$; }
                            case $0x70 + i$: { readData = UPPER_SPRITE.layer_collision_$i$; }
                        $$end
                    }
                    }
                case 4h5: {
                    switch( memoryAddress[1,3] ) {
                        case 3h2: { readData = CHARACTER_MAP.curses_character; }
                        case 3h3: { readData = CHARACTER_MAP.curses_background; }
                        case 3h4: { readData = CHARACTER_MAP.curses_foreground; }
                        case 3h5: { readData = CHARACTER_MAP.tpu_active; }
                        default: { readData = 0; }
                    }
                }
                case 4h6: {
                    switch( memoryAddress[1,7] ) {
                        case 7h0b: { readData = BITMAP.gpu_queue_full; }
                        case 7h0c: { readData = BITMAP.gpu_queue_complete; }
                        case 7h15: { readData = BITMAP.vector_block_active; }
                        case 7h6a: { readData = BITMAP.bitmap_colour_read; }
                        default: { readData = 0; }
                    }
                }
                case 4h7: { readData = TERMINAL.terminal_active; }
                case 4hf: { readData = vblank; }
                default: { readData = 0; }
            }
        }
    }
    always_after {
        // WRITE IO Memory
        if( memoryWrite ) {
            switch( memoryAddress[8,4] ) {
                case 4h0: { BACKGROUND.memoryWrite = 1; }
                case 4h1: { LOWER_TILE.memoryWrite = 1; }
                case 4h2: { UPPER_TILE.memoryWrite = 1; }
                case 4h3: { LOWER_SPRITE.memoryWrite = 1; LOWER_SPRITE.bitmapwriter = 0;  }
                case 4h4: { UPPER_SPRITE.memoryWrite = 1; UPPER_SPRITE.bitmapwriter = 0;  }
                case 4h5: { CHARACTER_MAP.memoryWrite = 1; }
                case 4h6: { BITMAP.memoryWrite = 1; }
                case 4h7: { TERMINAL.memoryWrite = 1; }
                case 4h8: { LOWER_SPRITE.memoryWrite = 1; LOWER_SPRITE.bitmapwriter = 1; }
                case 4h9: { UPPER_SPRITE.memoryWrite = 1; UPPER_SPRITE.bitmapwriter = 1; }
                case 4hf: {
                    if( memoryAddress[0,1] ) {
                        display.colour = writeData;
                    } else {
                        display.display_order = writeData;
                    }
                }
                default: {}
            }
        }
    }

    if( ~reset ) {
        // SET DEFAULT DISPLAY ORDER AND COLOUR MODE
        display.display_order = 0; display.colour = 1;
    }
}

// ALL DISPLAY GENERATOR UNITS RUN AT 25MHz, 640 x 480 @ 60fps
// WRITING TO THE DISPLAY GENERATOR UNITS THEREFORE
// LATCHES THE OUTPUT FOR 2 x 50MHz clock cycles
// AND THEN RESETS ANY CONTROLS
//
//         switch( { memoryWrite, LATCHmemoryWrite } ) {
//             case 2b10: { PERFORM THE WRITE }
//             case 2b00: { RESET }
//             default: { HOLD THE OUTPUT }
//         }
//
//         LATCHmemoryWrite = memoryWrite;

algorithm background_memmap(
    // Clocks
    input   uint1   video_clock,
    input   uint1   video_reset,

    // Pixels
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,

    // Memory access
    input   uint6   memoryAddress,
    input   uint1   memoryWrite,
    input   uint16  writeData,

    input   uint2   static2bit
) <autorun,reginputs> {
    // BACKGROUND GENERATOR
    background_display BACKGROUND <@video_clock,!video_reset> (
        pix_x <: pix_x,
        pix_y <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel :> pixel,
        staticGenerator <: static2bit,
        b_colour <: BACKGROUND_WRITER.BACKGROUNDcolour,
        b_alt <: BACKGROUND_WRITER.BACKGROUNDalt,
        b_mode <: BACKGROUND_WRITER.BACKGROUNDmode
    );

    background_writer BACKGROUND_WRITER <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always_after {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress ) {
                    case 6h00: { BACKGROUND_WRITER.backgroundcolour = writeData; BACKGROUND_WRITER.background_update = 1; }
                    case 6h02: { BACKGROUND_WRITER.backgroundcolour_alt = writeData; BACKGROUND_WRITER.background_update = 2; }
                    case 6h04: { BACKGROUND_WRITER.backgroundcolour_mode = writeData; BACKGROUND_WRITER.background_update = 3; }
                    case 6h10: { BACKGROUND_WRITER.copper_program = writeData; }
                    case 6h12: { BACKGROUND_WRITER.copper_status = writeData; }
                    case 6h20: { BACKGROUND_WRITER.copper_address = writeData; }
                    case 6h22: { BACKGROUND_WRITER.copper_command = writeData; }
                    case 6h24: { BACKGROUND_WRITER.copper_condition = writeData; }
                    case 6h26: { BACKGROUND_WRITER.copper_coordinate = writeData; }
                    case 6h28: { BACKGROUND_WRITER.copper_cpu_input = writeData; }
                    case 6h2a: { BACKGROUND_WRITER.copper_mode = writeData; }
                    case 6h2c: { BACKGROUND_WRITER.copper_alt = writeData; }
                    case 6h2e: { BACKGROUND_WRITER.copper_colour = writeData; }
                    default: {}
                }
            }
            case 2b00: { BACKGROUND_WRITER.background_update = 0; BACKGROUND_WRITER.copper_program = 0; }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }
}

algorithm bitmap_memmap(
    // Clocks
    input   uint1   gpu_clock,
    input   uint1   video_clock,
    input   uint1   video_reset,

    // Pixels
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   pixel_display,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint16  writeData,

    input   uint6   static6bit,

    output  uint1   gpu_queue_full,
    output  uint1   gpu_queue_complete,
    output  uint1   vector_block_active,
    output  uint7   bitmap_colour_read
) <autorun,reginputs> {
    simple_dualport_bram uint1 bitmap_0A <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint1 bitmap_1A <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint2 bitmap_0R <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint2 bitmap_1R <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint2 bitmap_0G <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint2 bitmap_1G <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint2 bitmap_0B <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint2 bitmap_1B <@video_clock,@video_clock> [ 76800 ] = uninitialized;

    // BITMAP DISPLAY
    bitmap bitmap_window <@video_clock,!video_reset> (
        bitmap_0A <:> bitmap_0A,
        bitmap_1A <:> bitmap_1A,
        bitmap_0R <:> bitmap_0R,
        bitmap_1R <:> bitmap_1R,
        bitmap_0G <:> bitmap_0G,
        bitmap_1G <:> bitmap_1G,
        bitmap_0B <:> bitmap_0B,
        bitmap_1B <:> bitmap_1B,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        bitmap_display :> pixel_display
   );

    // 32 vector blocks each of 16 vertices
    simple_dualport_bram uint13 vertex <@video_clock,@video_clock> [1024] = uninitialised;
    vertexwriter VW <@video_clock> ( vertex <:> vertex );

    // 32 x 16 x 16 1 bit tilemap for blit1tilemap
    simple_dualport_bram uint16 blit1tilemap <@video_clock,@video_clock> [ 1024 ] = uninitialized;
    // Character ROM 8x8 x 256 for character blitter
    simple_dualport_bram uint8 characterGenerator8x8 <@video_clock,@video_clock> [] = {
        $include('ROM/characterROM8x8.inc')
    };
    // BLIT TILE WRITER
    blittilebitmapwriter BTBM <@video_clock> ( blit1tilemap <:> blit1tilemap, characterGenerator8x8 <:> characterGenerator8x8 );

    // 32 x 16 x 16 7 bit tilemap for colour
    simple_dualport_bram uint7 colourblittilemap <@video_clock,@video_clock> [ 16384 ] = uninitialized;
    // COLOURBLIT TILE WRITER
    colourblittilebitmapwriter CBTBM <@video_clock> ( colourblittilemap <:> colourblittilemap );

    // BITMAP WRITER AND GPU
    bitmapwriter pixel_writer <@video_clock,!video_reset> (
        blit1tilemap <:> blit1tilemap,
        characterGenerator8x8 <:> characterGenerator8x8,
        colourblittilemap <:> colourblittilemap,
        vertex <:> vertex,
        static6bit <: static6bit,
        bitmap_0A <:> bitmap_0A,
        bitmap_1A <:> bitmap_1A,
        bitmap_0R <:> bitmap_0R,
        bitmap_1R <:> bitmap_1R,
        bitmap_0G <:> bitmap_0G,
        bitmap_1G <:> bitmap_1G,
        bitmap_0B <:> bitmap_0B,
        bitmap_1B <:> bitmap_1B,
        vector_block_active :> vector_block_active,
        gpu_queue_full :> gpu_queue_full,
        gpu_queue_complete :> gpu_queue_complete
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always_after {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress[4,4] ) {
                    case 4h0: {
                        switch( memoryAddress[1,3] ) {
                            case 3h0: { pixel_writer.gpu_x = writeData; }
                            case 3h1: { pixel_writer.gpu_y = writeData; }
                            case 3h2: { pixel_writer.gpu_colour = writeData; }
                            case 3h3: { pixel_writer.gpu_colour_alt = writeData; }
                            case 3h4: { pixel_writer.gpu_dithermode = writeData; }
                            case 3h5: { pixel_writer.gpu_param0 = writeData; }
                            case 3h6: { pixel_writer.gpu_param1 = writeData; }
                            case 3h7: { pixel_writer.gpu_param2 = writeData; }
                        }
                    }
                    case 4h1: {
                        switch( memoryAddress[1,2] ) {
                            case 2h0: { pixel_writer.gpu_param3 = writeData; }
                            case 2h1: { pixel_writer.gpu_param4 = writeData; }
                            case 2h2: { pixel_writer.gpu_param5 = writeData; }
                            case 2h3: { pixel_writer.gpu_write = writeData; }
                        }
                    }
                    case 4h2: {
                        switch( memoryAddress[1,3] ) {
                            case 3h0: { pixel_writer.vector_block_number = writeData; }
                            case 3h1: { pixel_writer.vector_block_colour = writeData; }
                            case 3h2: { pixel_writer.vector_block_xc = writeData; }
                            case 3h3: { pixel_writer.vector_block_yc = writeData; }
                            case 3h4: { pixel_writer.vector_block_scale = writeData; }
                            case 3h5: { pixel_writer.vector_block_action = writeData; }
                            case 3h6: { pixel_writer.draw_vector = 1; }
                            default: {}
                        }
                    }
                    case 4h3: {
                        switch( memoryAddress[1,3] ) {
                            case 3h0: { VW.vertices_writer_block = writeData; }
                            case 3h1: { VW.vertices_writer_vertex = writeData; }
                            case 3h2: { VW.vertices_writer_xdelta = writeData; }
                            case 3h3: { VW.vertices_writer_ydelta = writeData; }
                            case 3h4: { VW.vertices_writer_active = writeData; }
                            default: {}
                        }
                    }
                    case 4h4: {
                        switch( memoryAddress[1,2] ) {
                            case 2h0: { BTBM.blit1_writer_tile = writeData; }
                            case 2h1: { BTBM.blit1_writer_line = writeData; }
                            case 2h2: { BTBM.blit1_writer_bitmap = writeData; }
                            default: {}
                        }
                    }
                    case 4h5: {
                        switch( memoryAddress[1,2] ) {
                            case 2h0: { BTBM.character_writer_character = writeData; }
                            case 2h1: { BTBM.character_writer_line = writeData; }
                            case 2h2: { BTBM.character_writer_bitmap = writeData; }
                            default: {}
                        }
                    }
                    case 4h6: {
                        switch( memoryAddress[1,2] ) {
                            case 2h0: { CBTBM.colourblit_writer_tile = writeData; }
                            case 2h1: { CBTBM.colourblit_writer_line = writeData; }
                            case 2h2: { CBTBM.colourblit_writer_pixel = writeData; }
                            case 2h3: { CBTBM.colourblit_writer_colour = writeData; }
                        }
                    }
                    case 4h7: {
                        switch( memoryAddress[1,3] ) {
                            case 3h0: { pixel_writer.pb_colour7 = writeData; pixel_writer.pb_newpixel = 1; }
                            case 3h1: { pixel_writer.pb_colour8r = writeData; }
                            case 3h2: { pixel_writer.pb_colour8g = writeData; }
                            case 3h3: { pixel_writer.pb_colour8b = writeData; pixel_writer.pb_newpixel = 2; }
                            case 3h4: { pixel_writer.pb_newpixel = 3; }
                            default: {}
                        }
                    }
                    case 4hd: {
                        if( memoryAddress[1,1] ) {
                             bitmap_window.bitmap_y_read = writeData;
                        } else {
                             bitmap_window.bitmap_x_read = writeData;
                        }
                    }
                    case 4he: {
                        switch( memoryAddress[1,2] ) {
                            case 2h1: { pixel_writer.crop_left = writeData; }
                            case 2h2: { pixel_writer.crop_right = writeData; }
                            case 2h3: { pixel_writer.crop_top = writeData; }
                            case 2h0: { pixel_writer.crop_bottom = writeData; }
                        }
                    }
                    case 4hf: {
                        if( memoryAddress[1,1] ) {
                            pixel_writer.framebuffer = writeData;
                        } else {
                            bitmap_window.framebuffer = writeData;
                        }
                    }
                    default: {}

                }
            }
            case 2b00: { pixel_writer.gpu_write = 0;  pixel_writer.pb_newpixel = 0; pixel_writer.draw_vector = 0; }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }

    if( ~reset ) {
        // RESET THE CROPPING RECTANGLE
        pixel_writer.crop_left = 0; pixel_writer.crop_right = 319; pixel_writer.crop_top = 0; pixel_writer.crop_bottom = 239;
    }
}

algorithm charactermap_memmap(
    // Clocks
    input   uint1   video_clock,
    input   uint1   video_reset,

    // Pixels
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   pixel_display,
    input   uint1   blink,

    // Memory access
    input   uint4   memoryAddress,
    input   uint1   memoryWrite,
    input   uint16  writeData,

    output  uint2   tpu_active,
    output  uint9   curses_character,
    output  uint7   curses_background,
    output  uint6   curses_foreground
) <autorun,reginputs> {
    // 80 x 30 character buffer
    // Setting background to 40 (ALPHA) allows the bitmap/background to show through, charactermap { BOLD, character }
    simple_dualport_bram uint9 charactermap <@video_clock,@video_clock> [4800] = uninitialized;
    simple_dualport_bram uint13 colourmap <@video_clock,@video_clock> [4800] = uninitialized;

    // CHARACTER MAP WRITER
    uint6   tpu_foreground = uninitialized;
    uint7   tpu_background = uninitialized;
    character_map_writer CMW <@video_clock,!video_reset> (
        charactermap <:> charactermap,
        colourmap <:> colourmap,
        tpu_foreground <: tpu_foreground,
        tpu_background <: tpu_background,
        tpu_active :> tpu_active,
        curses_character :> curses_character,
        curses_background :> curses_background,
        curses_foreground :> curses_foreground,
    );

    // CHARACTER MAP DISPLAY
    uint1   tpu_showcursor = uninitialized;
    character_map character_map_window <@video_clock,!video_reset> (
        charactermap <:> charactermap,
        colourmap <:> colourmap,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        character_map_display :> pixel_display,
        blink <: blink,
        tpu_foreground <: tpu_foreground,
        tpu_background <: tpu_background,
        cursor_x <: CMW.cursor_x,
        cursor_y <: CMW.cursor_y
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always_after {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress[1,3] ) {
                    case 3h0: { CMW.tpu_x = writeData; }
                    case 3h1: { CMW.tpu_y = writeData; }
                    case 3h2: { CMW.tpu_character = writeData; }
                    case 3h3: { tpu_background = writeData; }
                    case 3h4: { tpu_foreground = writeData; }
                    case 3h5: { CMW.tpu_write = writeData; }
                    case 3h6: { character_map_window.tpu_showcursor = writeData; }
                    default: {}
                }
            }
            case 2b00: { CMW.tpu_write = 0; }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }

    // HIDE CURSOR AT RESET
    if( ~reset ) { character_map_window.tpu_showcursor = 0; }
}

algorithm sprite_memmap(
    // Clocks
    input   uint1   video_clock,
    input   uint1   video_reset,

    // Pixels
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   pixel_display,

    // Memory access
    input   uint1   bitmapwriter,
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint16  writeData,

    input   uint1   collision_layer_1,
    input   uint1   collision_layer_2,
    input   uint1   collision_layer_3,
    input   uint1   collision_layer_4,

    // For reading sprite characteristics
    $$for i=0,15 do
        output  uint1   sprite_read_active_$i$,
        output  uint3   sprite_read_double_$i$,
        output  uint6   sprite_read_colour_$i$,
        output  int11   sprite_read_x_$i$,
        output  int10   sprite_read_y_$i$,
        output  uint3   sprite_read_tile_$i$,
        output uint16   collision_$i$,
        output uint4    layer_collision_$i$,
    $$end
) <autorun,reginputs> {
    $$for i=0,15 do
        // Sprite Tiles
        simple_dualport_bram uint16 tiles_$i$ <@video_clock,@video_clock> [128] = uninitialised;
    $$end

    sprite_layer sprites <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        sprite_layer_display :> pixel_display,
        collision_layer_1 <: collision_layer_1,
        collision_layer_2 <: collision_layer_2,
        collision_layer_3 <: collision_layer_3,
        collision_layer_4 <: collision_layer_4,
        $$for i=0,15 do
            sprite_read_active_$i$ <: sprite_read_active_$i$,
            sprite_read_double_$i$ <: sprite_read_double_$i$,
            sprite_read_colour_$i$ <: sprite_read_colour_$i$,
            sprite_read_x_$i$ <: sprite_read_x_$i$,
            sprite_read_y_$i$ <: sprite_read_y_$i$,
            sprite_read_tile_$i$ <: sprite_read_tile_$i$,
            collision_$i$ :> collision_$i$,
            layer_collision_$i$ :> layer_collision_$i$,
        $$end
        $$for i=0,15 do
            tiles_$i$ <:> tiles_$i$,
        $$end
    );
    sprite_layer_writer SLW <@video_clock,!video_reset> (
        $$for i=0,15 do
            sprite_read_active_$i$ :> sprite_read_active_$i$,
            sprite_read_double_$i$ :> sprite_read_double_$i$,
            sprite_read_colour_$i$ :> sprite_read_colour_$i$,
            sprite_read_x_$i$ :> sprite_read_x_$i$,
            sprite_read_y_$i$ :> sprite_read_y_$i$,
            sprite_read_tile_$i$ :> sprite_read_tile_$i$,
        $$end
    );

    // UPDATE THE SPRITE TILE BITMAPS
    spritebitmapwriter SBMW <@video_clock,!video_reset> (
        $$for i=0,15 do
            tiles_$i$ <:> tiles_$i$,
        $$end
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always_after {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                if( bitmapwriter ) {
                    switch( memoryAddress[1,2] ) {
                        case 2h0: { SBMW.sprite_writer_sprite = writeData; }
                        case 2h1: { SBMW.sprite_writer_line = writeData; }
                        case 2h2: { SBMW.sprite_writer_bitmap = writeData; }
                        default: {}
                    }
                } else {
                    // SET SPRITE ATTRIBUTE
                    SLW.sprite_set_number = memoryAddress[1,4];
                    SLW.sprite_write_value = writeData;
                    SLW.sprite_layer_write = memoryAddress[5,3] + 1;
                }
            }
            case 2b00: { SLW.sprite_layer_write = 0; }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }
}

algorithm terminal_memmap(
    // Clocks
    input   uint1   video_clock,
    input   uint1   video_reset,

    // Pixels
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   pixel_display,
    input   uint1   blink,

    // Memory access
    input   uint3   memoryAddress,
    input   uint1   memoryWrite,
    input   uint16  writeData,

    output  uint2   terminal_active
) <autorun,reginputs> {
    // 80 x 4 character buffer for the input/output terminal
    simple_dualport_bram uint8 terminal <@video_clock,@video_clock> [640] = uninitialized;

    terminal terminal_window <@video_clock,!video_reset> (
        terminal <:> terminal,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        terminal_display :> pixel_display,
        blink <: blink,
        terminal_x <: TW.terminal_x
    );

    terminal_writer TW <@video_clock,!video_reset> (
        terminal <:> terminal,
        terminal_active :> terminal_active
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always_after {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress[1,2] ) {
                    case 2h0: { TW.terminal_character = writeData; TW.terminal_write = 1; }
                    case 2h1: { terminal_window.showterminal = writeData; }
                    case 2h2: { TW.terminal_write = 2; }
                    default: {}
                }
            }
            case 2b00: { TW.terminal_write = 0; }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }
}

algorithm tilemap_memmap(
    // Clocks
    input   uint1   video_clock,
    input   uint1   video_reset,

    // Pixels
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   pixel_display,

    // Memory access
    input   uint6   memoryAddress,
    input   uint1   memoryWrite,
    input   uint16  writeData,
    output  uint4   tm_lastaction,
    output  uint2   tm_active
) <autorun,reginputs> {
    // Tiles 64 x 16 x 16
    simple_dualport_bram uint16 tiles16x16 <@video_clock,@video_clock> [ 1024 ] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, pad(uninitialized) };

    // 42 x 32 tile map, allows for pixel scrolling with border { 2 bit reflection, 7 bits background, 6 bits foreground, 5 bits tile number }
    simple_dualport_bram uint6 tiles <@video_clock,@video_clock> [1344] = uninitialized;
    simple_dualport_bram uint15 colours <@video_clock,@video_clock> [1344] = uninitialized;

    tilemap tile_map <@video_clock,!video_reset> (
        tiles16x16 <:> tiles16x16,
        tiles <:> tiles,
        colours <:> colours,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        tm_offset_x <: TMW.tm_offset_x,
        tm_offset_y <: TMW.tm_offset_y,
        tilemap_display :> pixel_display
    );

    tile_map_writer TMW <@video_clock,!video_reset> ( tiles <:> tiles, colours <:> colours, );
    tilebitmapwriter TBMW <@video_clock,!video_reset> ( tiles16x16 <:> tiles16x16 );

     // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always_after {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress[1,5] ) {
                    case 5h00: { TMW.tm_x = writeData; }
                    case 5h01: { TMW.tm_y = writeData; }
                    case 5h02: { TMW.tm_character = writeData; }
                    case 5h03: { TMW.tm_background = writeData; }
                    case 5h04: { TMW.tm_foreground = writeData; }
                    case 5h05: { TMW.tm_reflection = writeData; }
                    case 5h06: { TMW.tm_write = 1; }
                    case 5h08: { TBMW.tile_writer_tile = writeData; }
                    case 5h09: { TBMW.tile_writer_line = writeData; }
                    case 5h0a: { TBMW.tile_writer_bitmap = writeData; }
                    case 5h10: { TMW.tm_scrollwrap = writeData; }
                    default: {}
                }
            }
            case 2b00: { TMW.tm_write = 0; TMW.tm_scrollwrap = 0; }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }
}
