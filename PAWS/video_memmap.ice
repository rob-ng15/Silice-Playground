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
    output! uint4   gpdi_dp
$$end
$$if VGA then
    // VGA OUTPUT
    output! uint$color_depth$ video_r,
    output! uint$color_depth$ video_g,
    output! uint$color_depth$ video_b,
    output  uint1 video_hs,
    output  uint1 video_vs,
$$end
) <autorun> {
    // VIDEO + CLOCKS
    uint1   pll_lock_VIDEO = uninitialized;
    uint1   video_clock = uninitialized;
    uint1   gpu_clock = uninitialized;
$$if not SIMULATION then
    ulx3s_clk_risc_ice_v_VIDEO clk_gen_VIDEO (
        clkin    <: clock_25mhz,
        clkGPU :> gpu_clock,
        clkVIDEO :> video_clock,
        locked   :> pll_lock_VIDEO
    );
$$else
    passthrough p1(i<:clock_25mhz,o:>gpu_clock);
    passthrough p2(i<:clock_25mhz,o:>video_clock);
$$end
    // Video Reset
    uint1   video_reset = uninitialized;
    clean_reset video_rstcond<@video_clock,!reset> ( out :> video_reset );

    // RNG random number generator
    uint1   static1bit <: rng.u_noise_out[0,1];
    uint2   static2bit <: rng.u_noise_out[0,2];
    uint6   static6bit <: rng.u_noise_out[0,6];
    random rng <@clock_25mhz> ();

    // HDMI driver
    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1   vblank = uninitialized;
    uint1   pix_active = uninitialized;
    uint10  pix_x  = uninitialized;
    uint10  pix_y  = uninitialized;
$$if VGA then
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
$$end
    // CREATE DISPLAY LAYERS
    // BACKGROUND
    uint6   background_p = uninitialized;
    background background_generator <@video_clock,!video_reset>  (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> background_p,
        staticGenerator <: static2bit
    );

    // Tilemaps - Lower and Upper
    uint6   lower_tilemap_p = uninitialized;
    uint1   lower_tilemap_display = uninitialized;
    uint6   upper_tilemap_p = uninitialized;
    uint1   upper_tilemap_display = uninitialized;
    tilemap lower_tile_map <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> lower_tilemap_p,
        tilemap_display :> lower_tilemap_display
    );
    tilemap upper_tile_map <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> upper_tilemap_p,
        tilemap_display :> upper_tilemap_display
    );

    // Bitmap Window with GPU
    uint1   bitmap_display = uninitialized;
    uint6   bitmap_p = uninitialized;
    // 640 x 480 x 7 bit { Arrggbb } colour bitmap
    bitmap bitmap_window <@video_clock,!video_reset> (
        gpu_clock <: gpu_clock,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> bitmap_p,
        bitmap_display :> bitmap_display,
        static1bit <: static1bit,
        static6bit <: static6bit
   );

    // Sprite Layers - Lower and Upper
    uint6   lower_sprites_p = uninitialized;
    uint1   lower_sprites_display = uninitialized;
    uint6   upper_sprites_p = uninitialized;
    uint1   upper_sprites_display = uninitialized;
    sprite_layer lower_sprites <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> lower_sprites_p,
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
        pixel    :> upper_sprites_p,
        sprite_layer_display :> upper_sprites_display,
        collision_layer_1 <: bitmap_display,
        collision_layer_2 <: lower_tilemap_display,
        collision_layer_3 <: upper_tilemap_display,
        collision_layer_4 <: lower_sprites_display
    );

    // Character Map Window
    uint6   character_map_p = uninitialized;
    uint1   character_map_display = uninitialized;
    character_map character_map_window <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> character_map_p,
        character_map_display :> character_map_display
    );

    // Terminal Window
    uint6   terminal_p = uninitialized;
    uint1   terminal_display = uninitialized;
    terminal terminal_window <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> terminal_p,
        terminal_display :> terminal_display
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

        background_p <: background_p,

        lower_tilemap_p <: lower_tilemap_p,
        lower_tilemap_display <: lower_tilemap_display,

        upper_tilemap_p <: upper_tilemap_p,
        upper_tilemap_display <: upper_tilemap_display,

        lower_sprites_p <: lower_sprites_p,
        lower_sprites_display <: lower_sprites_display,

        upper_sprites_p <: upper_sprites_p,
        upper_sprites_display <: upper_sprites_display,

        bitmap_p <: bitmap_p,
        bitmap_display <: bitmap_display,

        character_map_p <: character_map_p,
        character_map_display <: character_map_display,

        terminal_p <: terminal_p,
        terminal_display <: terminal_display
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        // READ IO Memory
        switch( memoryRead ) {
            case 1: {
                switch( memoryAddress ) {
                    // TILE MAP
                    case 12h120: { readData = lower_tile_map.tm_lastaction; }
                    case 12h122: { readData = lower_tile_map.tm_active; }
                    case 12h220: { readData = upper_tile_map.tm_lastaction; }
                    case 12h222: { readData = upper_tile_map.tm_active; }

                    // LOWER SPRITE LAYER
                    $$for i=0,15 do
                        case $0x300 + i*2$: { readData = lower_sprites.sprite_read_active_$i$; }
                        case $0x320 + i*2$: { readData = lower_sprites.sprite_read_double_$i$; }
                        case $0x340 + i*2$: { readData = lower_sprites.sprite_read_colour_$i$; }
                        case $0x360 + i*2$: { readData = {{5{lower_sprites.sprite_read_x_$i$[10,1]}}, lower_sprites.sprite_read_x_$i$}; }
                        case $0x380 + i*2$: { readData = {{5{lower_sprites.sprite_read_y_$i$[10,1]}}, lower_sprites.sprite_read_y_$i$}; }
                        case $0x3a0 + i*2$: { readData = lower_sprites.sprite_read_tile_$i$; }
                        case $0x3c0 + i*2$: { readData = lower_sprites.collision_$i$; }
                        case $0x3e0 + i*2$: { readData = lower_sprites.layer_collision_$i$; }
                    $$end

                    // UPPER SPRITE LAYER
                    $$for i=0,15 do
                        case $0x400 + i*2$: { readData = upper_sprites.sprite_read_active_$i$; }
                        case $0x420 + i*2$: { readData = upper_sprites.sprite_read_double_$i$; }
                        case $0x440 + i*2$: { readData = upper_sprites.sprite_read_colour_$i$; }
                        case $0x460 + i*2$: { readData = {{5{upper_sprites.sprite_read_x_$i$[10,1]}}, upper_sprites.sprite_read_x_$i$}; }
                        case $0x480 + i*2$: { readData = {{5{upper_sprites.sprite_read_y_$i$[10,1]}}, upper_sprites.sprite_read_y_$i$}; }
                        case $0x4a0 + i*2$: { readData = upper_sprites.sprite_read_tile_$i$; }
                        case $0x4c0 + i*2$: { readData = upper_sprites.collision_$i$; }
                        case $0x4e0 + i*2$: { readData = upper_sprites.layer_collision_$i$; }
                    $$end

                    // CHARACTER MAP
                    case 12h504: { readData = character_map_window.curses_character; }
                    case 12h506: { readData = character_map_window.curses_background; }
                    case 12h508: { readData = character_map_window.curses_foreground; }
                    case 12h50a: { readData = character_map_window.tpu_active; }

                    // GPU and BITMAP
                    case 12h612: { readData = bitmap_window.gpu_queue_full; }
                    case 12h614: { readData = bitmap_window.gpu_queue_complete; }
                    case 12h62a: { readData = bitmap_window.vector_block_active; }
                    case 12h6d4: { readData = bitmap_window.bitmap_colour_read; }

                    // TERMINAL
                    case 12h700: { readData = terminal_window.terminal_active; }

                    // VBLANK
                    case 12hf00: { readData = vblank; }

                    default: { readData = 0; }
                }
            }
            default: {}
        }

        // WRITE IO Memory
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress ) {
                    // BACKGROUND
                    case 12h000: { background_generator.backgroundcolour = writeData; background_generator.background_update = 1; }
                    case 12h002: { background_generator.backgroundcolour_alt = writeData; background_generator.background_update = 2; }
                    case 12h004: { background_generator.backgroundcolour_mode = writeData; background_generator.background_update = 3; }
                    case 12h010: { background_generator.copper_program = writeData; }
                    case 12h012: { background_generator.copper_status = writeData; }
                    case 12h020: { background_generator.copper_address = writeData; }
                    case 12h022: { background_generator.copper_command = writeData; }
                    case 12h024: { background_generator.copper_condition = writeData; }
                    case 12h026: { background_generator.copper_coordinate = writeData; }
                    case 12h028: { background_generator.copper_mode = writeData; }
                    case 12h02a: { background_generator.copper_alt = writeData; }
                    case 12h02c: { background_generator.copper_colour = writeData; }

                    // TILE MAP
                    case 12h100: { lower_tile_map.tm_x = writeData; }
                    case 12h102: { lower_tile_map.tm_y = writeData; }
                    case 12h104: { lower_tile_map.tm_character = writeData; }
                    case 12h106: { lower_tile_map.tm_background = writeData; }
                    case 12h108: { lower_tile_map.tm_foreground = writeData; }
                    case 12h10a: { lower_tile_map.tm_write = 1; }
                    case 12h110: { lower_tile_map.tile_writer_tile = writeData; }
                    case 12h112: { lower_tile_map.tile_writer_line = writeData; }
                    case 12h114: { lower_tile_map.tile_writer_bitmap = writeData; }
                    case 12h120: { lower_tile_map.tm_scrollwrap = writeData; }

                    case 12h200: { upper_tile_map.tm_x = writeData; }
                    case 12h202: { upper_tile_map.tm_y = writeData; }
                    case 12h204: { upper_tile_map.tm_character = writeData; }
                    case 12h206: { upper_tile_map.tm_background = writeData; }
                    case 12h208: { upper_tile_map.tm_foreground = writeData; }
                    case 12h20a: { upper_tile_map.tm_write = 1; }
                    case 12h210: { upper_tile_map.tile_writer_tile = writeData; }
                    case 12h212: { upper_tile_map.tile_writer_line = writeData; }
                    case 12h214: { upper_tile_map.tile_writer_bitmap = writeData; }
                    case 12h220: { upper_tile_map.tm_scrollwrap = writeData; }

                    // LOWER SPRITE LAYER
                    $$for i=0,15 do
                        case $0x300 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_set_active = writeData; lower_sprites.sprite_layer_write = 1; }
                        case $0x320 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_set_double = writeData; lower_sprites.sprite_layer_write = 2; }
                        case $0x340 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_set_colour = writeData; lower_sprites.sprite_layer_write = 3; }
                        case $0x360 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_set_x = writeData; lower_sprites.sprite_layer_write = 4; }
                        case $0x380 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_set_y = writeData; lower_sprites.sprite_layer_write = 5; }
                        case $0x3a0 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_set_tile = writeData; lower_sprites.sprite_layer_write = 6; }
                        case $0x3c0 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_update = writeData; lower_sprites.sprite_layer_write = 7; }
                    $$end

                    // UPPER SPRITE LAYER
                    $$for i=0,15 do
                        case $0x400 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_set_active = writeData; upper_sprites.sprite_layer_write = 1; }
                        case $0x420 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_set_double = writeData; upper_sprites.sprite_layer_write = 2; }
                        case $0x440 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_set_colour = writeData; upper_sprites.sprite_layer_write = 3;  }
                        case $0x460 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_set_x = writeData; upper_sprites.sprite_layer_write = 4; }
                        case $0x480 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_set_y = writeData; upper_sprites.sprite_layer_write = 5; }
                        case $0x4a0 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_set_tile = writeData; upper_sprites.sprite_layer_write = 6; }
                        case $0x4c0 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_update = writeData; upper_sprites.sprite_layer_write = 7; }
                    $$end

                    // LOWER SPRITE LAYER BITMAP WRITER
                    case 12h800: { lower_sprites.sprite_writer_sprite = writeData; }
                    case 12h802: { lower_sprites.sprite_writer_line = writeData; }
                    case 12h804: { lower_sprites.sprite_writer_bitmap = writeData; lower_sprites.sprite_writer_active = 1; }

                    // UPPER SPRITE LAYER BITMAP WRITER
                    case 12h810: { upper_sprites.sprite_writer_sprite = writeData; }
                    case 12h812: { upper_sprites.sprite_writer_line = writeData; }
                    case 12h814: { upper_sprites.sprite_writer_bitmap = writeData; upper_sprites.sprite_writer_active = 1; }

                    // CHARACTER MAP
                    case 12h500: { character_map_window.tpu_x = writeData; }
                    case 12h502: { character_map_window.tpu_y = writeData; }
                    case 12h504: { character_map_window.tpu_character = writeData; }
                    case 12h506: { character_map_window.tpu_background = writeData; }
                    case 12h508: { character_map_window.tpu_foreground = writeData; }
                    case 12h50a: { character_map_window.tpu_write = writeData; }

                    // GPU and BITMAP
                    case 12h600: { bitmap_window.gpu_x = writeData; }
                    case 12h602: { bitmap_window.gpu_y = writeData; }
                    case 12h604: { bitmap_window.gpu_colour = writeData; }
                    case 12h606: { bitmap_window.gpu_colour_alt = writeData; }
                    case 12h608: { bitmap_window.gpu_dithermode = writeData; }
                    case 12h60a: { bitmap_window.gpu_param0 = writeData; }
                    case 12h60c: { bitmap_window.gpu_param1 = writeData; }
                    case 12h60e: { bitmap_window.gpu_param2 = writeData; }
                    case 12h610: { bitmap_window.gpu_param3 = writeData; }
                    case 12h612: { bitmap_window.gpu_write = writeData; }

                    case 12h620: { bitmap_window.vector_block_number = writeData; }
                    case 12h622: { bitmap_window.vector_block_colour = writeData; }
                    case 12h624: { bitmap_window.vector_block_xc = writeData; }
                    case 12h826: { bitmap_window.vector_block_yc = writeData; }
                    case 12h628: { bitmap_window.vector_block_scale = writeData; }
                    case 12h62a: { bitmap_window.draw_vector = 1; }

                    case 12h630: { bitmap_window.vertices_writer_block = writeData; }
                    case 12h632: { bitmap_window.vertices_writer_vertex = writeData; }
                    case 12h634: { bitmap_window.vertices_writer_xdelta = writeData; }
                    case 12h636: { bitmap_window.vertices_writer_ydelta = writeData; }
                    case 12h638: { bitmap_window.vertices_writer_active = writeData; }

                    case 12h640: { bitmap_window.blit1_writer_tile = writeData; }
                    case 12h642: { bitmap_window.blit1_writer_line = writeData; }
                    case 12h644: { bitmap_window.blit1_writer_bitmap = writeData; }

                    case 12h650: { bitmap_window.character_writer_character = writeData; }
                    case 12h652: { bitmap_window.character_writer_line = writeData; }
                    case 12h654: { bitmap_window.character_writer_bitmap = writeData; }

                    case 12h660: { bitmap_window.colourblit_writer_tile = writeData; }
                    case 12h662: { bitmap_window.colourblit_writer_line = writeData; }
                    case 12h664: { bitmap_window.colourblit_writer_pixel = writeData; }
                    case 12h666: { bitmap_window.colourblit_writer_colour = writeData; }

                    case 12h670: { bitmap_window.pb_colour7 = writeData; bitmap_window.pb_newpixel = 1; }
                    case 12h672: { bitmap_window.pb_colour8r = writeData; }
                    case 12h674: { bitmap_window.pb_colour8g = writeData; }
                    case 12h676: { bitmap_window.pb_colour8b = writeData; bitmap_window.pb_newpixel = 2; }
                    case 12h678: { bitmap_window.pb_newpixel = 3; }

                    case 12h6d0: { bitmap_window.bitmap_x_read = writeData; }
                    case 12h6d2: { bitmap_window.bitmap_y_read = writeData; }

                    case 12h6e0: { bitmap_window.bitmap_write_offset = writeData; }
                    case 12h6f0: { bitmap_window.framebuffer = writeData; }
                    case 12h6f2: { bitmap_window.writer_framebuffer = writeData; }

                    case 12h700: { terminal_window.terminal_character = writeData; terminal_window.terminal_write = 1; }
                    case 12h702: { terminal_window.showterminal = writeData; }

                    // DISPLAY LAYER ORDERING / FRAMEBUFFER SELECTION
                    case 12hf00: { display.display_order = writeData; }

                    default: {}
                }
            }
            case 2b00: {
                // RESET DISPLAY Co-Processor Controls
                background_generator.background_update = 0;
                background_generator.copper_program = 0;
                lower_tile_map.tm_write = 0;
                lower_tile_map.tm_scrollwrap = 0;
                upper_tile_map.tm_write = 0;
                upper_tile_map.tm_scrollwrap = 0;
                lower_sprites.sprite_layer_write = 0;
                lower_sprites.sprite_writer_active = 0;
                upper_sprites.sprite_layer_write = 0;
                upper_sprites.sprite_writer_active = 0;
                bitmap_window.bitmap_write_offset = 0;
                bitmap_window.gpu_write = 0;
                bitmap_window.pb_newpixel = 0;
                bitmap_window.draw_vector = 0;
                character_map_window.tpu_write = 0;
                terminal_window.terminal_write = 0;
            }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }

    // HIDE TERMINAL WINDOW
    terminal_window.showterminal = 0;
}
