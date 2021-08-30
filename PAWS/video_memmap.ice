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
        clkVIDEO :> video_clock,
        clkGPU :> gpu_clock,
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
    uint1   static1bit <:: rng.u_noise_out[0,1];
    uint2   static2bit <:: rng.u_noise_out[0,2];
    uint6   static6bit <:: rng.u_noise_out[0,6];
    random rng <@clock_25mhz> ();

    // HDMI driver
    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1   vblank = uninitialized;
    uint1   pix_active = uninitialized;
    uint16  pix_x  = uninitialized;
    uint16  pix_y  = uninitialized;
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
    uint1   BACKGROUNDmemoryWrite = uninitialized;
    background_memmap BACKGROUND(
        video_clock <: video_clock,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> background_p,
        memoryAddress <: memoryAddress,
        writeData <: writeData,
        memoryWrite <: BACKGROUNDmemoryWrite,
        static2bit <: static2bit
    );

    // Bitmap Window with GPU
    uint6   bitmap_p = uninitialized;
    uint1   bitmap_display = uninitialized;
    // 320 x 240 x 7 bit { Arrggbb } colour bitmap
    uint1   gpu_queue_full = uninitialized;
    uint1   gpu_queue_complete = uninitialized;
    uint1   vector_block_active = uninitialized;
    uint7   bitmap_colour_read = uninitialized;
    uint1   BITMAPmemoryWrite = uninitialized;
    bitmap_memmap BITMAP(
        video_clock <: video_clock,
        gpu_clock <: gpu_clock,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> bitmap_p,
        pixel_display :> bitmap_display,
        memoryAddress <: memoryAddress,
        writeData <: writeData,
        memoryWrite <: BITMAPmemoryWrite,
        static1bit <: static1bit,
        static6bit <: static6bit,
        gpu_queue_full :> gpu_queue_full,
        gpu_queue_complete :> gpu_queue_complete,
        vector_block_active :> vector_block_active,
        bitmap_colour_read :> bitmap_colour_read
    );

    // Character Map Window
    uint6   character_map_p = uninitialized;
    uint1   character_map_display = uninitialized;
    uint2   tpu_active = uninitialized;
    uint9   curses_character = uninitialized;
    uint7   curses_background = uninitialized;
    uint6   curses_foreground = uninitialized;
    uint1   CHARACTER_MAPmemoryWrite = uninitialized;
    charactermap_memmap CHARACTER_MAP(
        video_clock <: video_clock,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> character_map_p,
        pixel_display :> character_map_display,
        memoryAddress <: memoryAddress,
        writeData <: writeData,
        memoryWrite <: CHARACTER_MAPmemoryWrite,
        tpu_active :> tpu_active,
        curses_character :> curses_character,
        curses_background :> curses_background,
        curses_foreground :> curses_foreground
    );

    // Sprite Layers - Lower and Upper
    uint6   lower_sprites_p = uninitialized;
    uint1   lower_sprites_display = uninitialized;
    uint1   LOWER_SPRITEmemoryWrite = uninitialized;
    uint1   LOWER_SPRITEbitmapwriter = uninitialized;
    $$for i=0,15 do
        uint1   Lsprite_read_active_$i$ = uninitialized;
        uint3   Lsprite_read_double_$i$ = uninitialized;
        uint6   Lsprite_read_colour_$i$ = uninitialized;
        int16   Lsprite_read_x_$i$ = uninitialized;
        int16   Lsprite_read_y_$i$ = uninitialized;
        uint3   Lsprite_read_tile_$i$ = uninitialized;
        uint16  Lcollision_$i$ = uninitialized;
        uint4   Llayer_collision_$i$ = uninitialized;
    $$end
    sprite_memmap LOWER_SPRITE(
        video_clock <: video_clock,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> lower_sprites_p,
        pixel_display :> lower_sprites_display,
        memoryAddress <: memoryAddress,
        writeData <: writeData,
        memoryWrite <: LOWER_SPRITEmemoryWrite,
        bitmapwriter <: LOWER_SPRITEbitmapwriter,
        collision_layer_1 <: bitmap_display,
        collision_layer_2 <: lower_tilemap_display,
        collision_layer_3 <: upper_tilemap_display,
        collision_layer_4 <: upper_sprites_display,
        $$for i=0,15 do
            sprite_read_active_$i$ :> Lsprite_read_active_$i$,
            sprite_read_double_$i$ :> Lsprite_read_double_$i$,
            sprite_read_colour_$i$ :> Lsprite_read_colour_$i$,
            sprite_read_x_$i$ :> Lsprite_read_x_$i$,
            sprite_read_y_$i$ :> Lsprite_read_y_$i$,
            sprite_read_tile_$i$ :> Lsprite_read_tile_$i$,
            collision_$i$ :> Lcollision_$i$,
            layer_collision_$i$ :> Llayer_collision_$i$,
        $$end
    );
    uint6   upper_sprites_p = uninitialized;
    uint1   upper_sprites_display = uninitialized;
    uint1   UPPER_SPRITEmemoryWrite = uninitialized;
    uint1   UPPER_SPRITEbitmapwriter = uninitialized;
    $$for i=0,15 do
        uint1   Usprite_read_active_$i$ = uninitialized;
        uint3   Usprite_read_double_$i$ = uninitialized;
        uint6   Usprite_read_colour_$i$ = uninitialized;
        int16   Usprite_read_x_$i$ = uninitialized;
        int16   Usprite_read_y_$i$ = uninitialized;
        uint3   Usprite_read_tile_$i$ = uninitialized;
        uint16  Ucollision_$i$ = uninitialized;
        uint4   Ulayer_collision_$i$ = uninitialized;
    $$end
    sprite_memmap UPPER_SPRITE(
        video_clock <: video_clock,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> upper_sprites_p,
        pixel_display :> upper_sprites_display,
        memoryAddress <: memoryAddress,
        writeData <: writeData,
        memoryWrite <: UPPER_SPRITEmemoryWrite,
        bitmapwriter <: UPPER_SPRITEbitmapwriter,
        collision_layer_1 <: bitmap_display,
        collision_layer_2 <: lower_tilemap_display,
        collision_layer_3 <: upper_tilemap_display,
        collision_layer_4 <: lower_sprites_display,
        $$for i=0,15 do
            sprite_read_active_$i$ :> Usprite_read_active_$i$,
            sprite_read_double_$i$ :> Usprite_read_double_$i$,
            sprite_read_colour_$i$ :> Usprite_read_colour_$i$,
            sprite_read_x_$i$ :> Usprite_read_x_$i$,
            sprite_read_y_$i$ :> Usprite_read_y_$i$,
            sprite_read_tile_$i$ :> Usprite_read_tile_$i$,
            collision_$i$ :> Ucollision_$i$,
            layer_collision_$i$ :> Ulayer_collision_$i$,
        $$end
    );

    // Terminal Window
    uint6   terminal_p = uninitialized;
    uint1   terminal_display = uninitialized;
    uint2   terminal_active = uninitialized;
    uint1   TERMINALmemoryWrite = uninitialized;
    terminal_memmap TERMINAL(
        video_clock <: video_clock,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> terminal_p,
        pixel_display :> terminal_display,
        memoryAddress <: memoryAddress,
        writeData <: writeData,
        memoryWrite <: TERMINALmemoryWrite,
        terminal_active :> terminal_active
    );

    // Tilemaps - Lower and Upper
    uint6   lower_tilemap_p = uninitialized;
    uint1   lower_tilemap_display = uninitialized;
    uint4   Ltm_lastaction = uninitialized;
    uint2   Ltm_active = uninitialized;
    uint1   LOWER_TILEmemoryWrite = uninitialized;
    tilemap_memmap LOWER_TILE(
        video_clock <: video_clock,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> lower_tilemap_p,
        pixel_display :> lower_tilemap_display,
        memoryAddress <: memoryAddress,
        writeData <: writeData,
        memoryWrite <: LOWER_TILEmemoryWrite,
        tm_lastaction :> Ltm_lastaction,
        tm_active :> Ltm_active
    );
    uint6   upper_tilemap_p = uninitialized;
    uint1   upper_tilemap_display = uninitialized;
    uint4   Utm_lastaction = uninitialized;
    uint2   Utm_active = uninitialized;
    uint1   UPPER_TILEmemoryWrite = uninitialized;
    tilemap_memmap UPPER_TILE(
        video_clock <: video_clock,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> upper_tilemap_p,
        pixel_display :> upper_tilemap_display,
        memoryAddress <: memoryAddress,
        writeData <: writeData,
        memoryWrite <: UPPER_TILEmemoryWrite,
        tm_lastaction :> Utm_lastaction,
        tm_active :> Utm_active
    );

    // Combine the display layers for display
    uint2   display_order = uninitialized;
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
        terminal_display <: terminal_display,
        display_order <: display_order
    );

    BACKGROUNDmemoryWrite := 0; BITMAPmemoryWrite := 0; CHARACTER_MAPmemoryWrite := 0; LOWER_SPRITEmemoryWrite := 0; UPPER_SPRITEmemoryWrite := 0; TERMINALmemoryWrite := 0; LOWER_TILEmemoryWrite := 0; UPPER_TILEmemoryWrite := 0;

    always {
        // READ IO Memory
        if( memoryRead ) {
            switch( memoryAddress[8,4] ) {
                case 4h1: {
                    switch( memoryAddress[0,8] ) {
                        case 8h20: { readData = Ltm_lastaction; }
                        case 8h22: { readData = Ltm_active; }
                        default: { readData = 0; }
                    }
                }
                case 4h2: {
                    switch( memoryAddress[0,8] ) {
                        case 8h20: { readData = Utm_lastaction; }
                        case 8h22: { readData = Utm_active; }
                        default: { readData = 0; }
                    }
                }
                case 4h3: {
                    switch( memoryAddress[0,8] ) {
                        $$for i=0,15 do
                            case $0x00 + i*2$: { readData = Lsprite_read_active_$i$; }
                            case $0x20 + i*2$: { readData = Lsprite_read_double_$i$; }
                            case $0x40 + i*2$: { readData = Lsprite_read_colour_$i$; }
                            case $0x60 + i*2$: { readData = {{5{Lsprite_read_x_$i$[10,1]}}, Lsprite_read_x_$i$}; }
                            case $0x80 + i*2$: { readData = {{5{Lsprite_read_y_$i$[10,1]}}, Lsprite_read_y_$i$}; }
                            case $0xa0 + i*2$: { readData = Lsprite_read_tile_$i$; }
                            case $0xc0 + i*2$: { readData = Lcollision_$i$; }
                            case $0xe0 + i*2$: { readData = Llayer_collision_$i$; }
                        $$end
                        default: { readData = 0; }
                    }
                }
                case 4h4: {
                    switch( memoryAddress[0,8] ) {
                        $$for i=0,15 do
                            case $0x00 + i*2$: { readData = Usprite_read_active_$i$; }
                            case $0x20 + i*2$: { readData = Usprite_read_double_$i$; }
                            case $0x40 + i*2$: { readData = Usprite_read_colour_$i$; }
                            case $0x60 + i*2$: { readData = {{5{Usprite_read_x_$i$[10,1]}}, Usprite_read_x_$i$}; }
                            case $0x80 + i*2$: { readData = {{5{Usprite_read_y_$i$[10,1]}}, Usprite_read_y_$i$}; }
                            case $0xa0 + i*2$: { readData = Usprite_read_tile_$i$; }
                            case $0xc0 + i*2$: { readData = Ucollision_$i$; }
                            case $0xe0 + i*2$: { readData = Ulayer_collision_$i$; }
                        $$end
                        default: { readData = 0; }
                    }
                    }
                case 4h5: {
                    switch( memoryAddress[0,8] ) {
                        case 8h04: { readData = curses_character; }
                        case 8h06: { readData = curses_background; }
                        case 8h08: { readData = curses_foreground; }
                        case 8h0a: { readData = tpu_active; }
                        default: { readData = 0; }
                    }
                }
                case 4h6: {
                    switch( memoryAddress[0,8] ) {
                        case 8h16: { readData = gpu_queue_full; }
                        case 8h18: { readData = gpu_queue_complete; }
                        case 8h2a: { readData = vector_block_active; }
                        case 8hd4: { readData = bitmap_colour_read; }
                        default: { readData = 0; }
                    }
                }
                case 4h7: { readData = terminal_active; }
                case 4hf: { readData = vblank; }
                default: { readData = 0; }
            }
        }

        // WRITE IO Memory
        if( memoryWrite ) {
            switch( memoryAddress[8,4] ) {
                case 4h0: { BACKGROUNDmemoryWrite = 1; }
                case 4h1: { LOWER_TILEmemoryWrite = 1; }
                case 4h2: { UPPER_TILEmemoryWrite = 1; }
                case 4h3: { LOWER_SPRITEmemoryWrite = 1; LOWER_SPRITEbitmapwriter = 0;  }
                case 4h4: { UPPER_SPRITEmemoryWrite = 1; UPPER_SPRITEbitmapwriter = 0;  }
                case 4h5: { CHARACTER_MAPmemoryWrite = 1; }
                case 4h6: { BITMAPmemoryWrite = 1; }
                case 4h7: { TERMINALmemoryWrite = 1; }
                case 4h8: { LOWER_SPRITEmemoryWrite = 1; LOWER_SPRITEbitmapwriter = 1; }
                case 4h9: { UPPER_SPRITEmemoryWrite = 1; UPPER_SPRITEbitmapwriter = 1; }
                case 4hf: { display_order = writeData; }
                default: {}
            }
        }
    }
}

// ALL DISPLAY GENERATOR UNITS RUN AT 25MHz, 640 x 480 @ 60fps
// WRITING TO THE DISPLAY GENERATOR UNITS THEREFORE LATCHES THEREFORE
// LATCHES THE OUTPUT FOR 2 x 50MHz clock cycles
// AND THEN RESETS ANY CONTROLS
//
//         switch( { memoryWrite, LATCHmemoryWrite } ) {
//             case 2b10: {
//                  PERFORM THE WRITE
//             }
//             case 2b00: {
//                  RESET
//             }
//             default: { HOLD THE OUTPUT }
//         }
//
//         LATCHmemoryWrite = memoryWrite;

algorithm background_memmap(
    // Clocks
    input   uint1   video_clock,
    input   uint1   video_reset,

    // Pixels
    input   uint16  pix_x,
    input   uint16  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint16  writeData,

    input   uint2   static2bit
) <autorun> {
    uint6   backgroundcolour = uninitialized;
    uint6   backgroundcolour_alt = uninitialized;
    uint4   backgroundcolour_mode = uninitialized;
    uint2   background_update = uninitialized;
    uint1   copper_status = uninitialized;
    uint1   copper_program = uninitialized;
    uint6   copper_address = uninitialized;
    uint3   copper_command = uninitialized;
    uint3   copper_condition = uninitialized;
    uint11  copper_coordinate = uninitialized;
    uint16  copper_cpu_input = uninitialized;
    uint4   copper_mode = uninitialized;
    uint6   copper_alt = uninitialized;
    uint6   copper_colour = uninitialized;
    background background_generator <@video_clock,!video_reset>  (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        staticGenerator <: static2bit,
        backgroundcolour <: backgroundcolour,
        backgroundcolour_alt <: backgroundcolour_alt,
        backgroundcolour_mode <: backgroundcolour_mode,
        background_update <: background_update,
        copper_status <: copper_status,
        copper_program <: copper_program,
        copper_address <: copper_address,
        copper_command <: copper_command,
        copper_condition <: copper_condition,
        copper_coordinate <: copper_coordinate,
        copper_cpu_input <: copper_cpu_input,
        copper_mode <: copper_mode,
        copper_alt <: copper_alt,
        copper_colour <: copper_colour
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress ) {
                    case 8h00: { backgroundcolour = writeData; background_update = 1; }
                    case 8h02: { backgroundcolour_alt = writeData; background_update = 2; }
                    case 8h04: { backgroundcolour_mode = writeData; background_update = 3; }
                    case 8h10: { copper_program = writeData; }
                    case 8h12: { copper_status = writeData; }
                    case 8h20: { copper_address = writeData; }
                    case 8h22: { copper_command = writeData; }
                    case 8h24: { copper_condition = writeData; }
                    case 8h26: { copper_coordinate = writeData; }
                    case 8h28: { copper_cpu_input = writeData; }
                    case 8h2a: { copper_mode = writeData; }
                    case 8h2c: { copper_alt = writeData; }
                    case 8h2e: { copper_colour = writeData; }
                    default: {}
                }
            }
            case 2b00: {
                background_update = 0;
                copper_program = 0;
            }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }
}

algorithm bitmap_memmap(
    // Clocks
    input   uint1   video_clock,
    input   uint1   video_reset,
    input   uint1   gpu_clock,

    // Pixels
    input   uint16  pix_x,
    input   uint16  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   pixel_display,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint16  writeData,

    input   uint1   static1bit,
    input   uint6   static6bit,

    output  uint1   gpu_queue_full,
    output  uint1   gpu_queue_complete,
    output  uint1   vector_block_active,
    output  uint7   bitmap_colour_read
) <autorun> {
    uint1   framebuffer = uninitialized;
    uint1   writer_framebuffer = uninitialized;
    uint3   bitmap_write_offset = uninitialized;
    int16   bitmap_x_read = uninitialized;
    int16   bitmap_y_read = uninitialized;
    int16   gpu_x = uninitialized;
    int16   gpu_y = uninitialized;
    uint7   gpu_colour = uninitialized;
    uint7   gpu_colour_alt = uninitialized;
    int16   gpu_param0 = uninitialized;
    int16   gpu_param1 = uninitialized;
    int16   gpu_param2 = uninitialized;
    int16   gpu_param3 = uninitialized;
    int16   gpu_param4 = uninitialized;
    int16   gpu_param5 = uninitialized;
    uint4   gpu_write = uninitialized;
    uint4   gpu_dithermode = uninitialized;
    uint9   gpu_crop_left = uninitialized;
    uint9   gpu_crop_right = uninitialized;
    uint8   gpu_crop_top = uninitialized;
    uint8   gpu_crop_bottom = uninitialized;
    uint5   blit1_writer_tile = uninitialized;
    uint4   blit1_writer_line = uninitialized;
    uint16  blit1_writer_bitmap = uninitialized;
    uint8   character_writer_character = uninitialized;
    uint3   character_writer_line = uninitialized;
    uint8   character_writer_bitmap = uninitialized;
    uint5   colourblit_writer_tile = uninitialized;
    uint4   colourblit_writer_line = uninitialized;
    uint4   colourblit_writer_pixel = uninitialized;
    uint7   colourblit_writer_colour = uninitialized;
    uint7   pb_colour7 = uninitialized;
    uint8   pb_colour8r = uninitialized;
    uint8   pb_colour8g = uninitialized;
    uint8   pb_colour8b = uninitialized;
    uint2   pb_newpixel = uninitialized;
    uint5   vector_block_number = uninitialized;
    uint7   vector_block_colour = uninitialized;
    int16   vector_block_xc = uninitialized;
    int16   vector_block_yc = uninitialized;
    uint3   vector_block_scale = uninitialized;
    uint3   vector_block_action = uninitialized;
    uint1   draw_vector = uninitialized;
    uint5   vertices_writer_block = uninitialized;
    uint6   vertices_writer_vertex = uninitialized;
    int6    vertices_writer_xdelta = uninitialized;
    int6    vertices_writer_ydelta = uninitialized;
    uint1   vertices_writer_active = uninitialized;
    bitmap bitmap_window <@video_clock,!video_reset> (
        gpu_clock <: gpu_clock,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        bitmap_display :> pixel_display,
        static1bit <: static1bit,
        static6bit <: static6bit,
        gpu_queue_full :> gpu_queue_full,
        gpu_queue_complete :> gpu_queue_complete,
        vector_block_active :> vector_block_active,
        bitmap_colour_read :> bitmap_colour_read,
        bitmap_write_offset <: bitmap_write_offset,
        bitmap_x_read <: bitmap_x_read,
        bitmap_y_read <: bitmap_y_read,
        gpu_x <: gpu_x,
        gpu_y <: gpu_y,
        gpu_colour <: gpu_colour,
        gpu_colour_alt <: gpu_colour_alt,
        gpu_param0 <: gpu_param0,
        gpu_param1 <: gpu_param1,
        gpu_param2 <: gpu_param2,
        gpu_param3 <: gpu_param3,
        gpu_param4 <: gpu_param4,
        gpu_param5 <: gpu_param5,
        gpu_write <: gpu_write,
        gpu_dithermode <: gpu_dithermode,
        crop_left <: gpu_crop_left,
        crop_right <: gpu_crop_right,
        crop_top <: gpu_crop_top,
        crop_bottom <: gpu_crop_bottom,
        blit1_writer_tile <: blit1_writer_tile,
        blit1_writer_line <: blit1_writer_line,
        blit1_writer_bitmap <: blit1_writer_bitmap,
        character_writer_character <: character_writer_character,
        character_writer_line <: character_writer_line,
        character_writer_bitmap <: character_writer_bitmap,
        colourblit_writer_tile <: colourblit_writer_tile,
        colourblit_writer_line <: colourblit_writer_line,
        colourblit_writer_pixel <: colourblit_writer_pixel,
        colourblit_writer_colour <: colourblit_writer_colour,
        pb_colour7 <: pb_colour7,
        pb_colour8r <: pb_colour8r,
        pb_colour8g <: pb_colour8g,
        pb_colour8b <: pb_colour8b,
        pb_newpixel <: pb_newpixel,
        vector_block_number <: vector_block_number,
        vector_block_colour <: vector_block_colour,
        vector_block_xc <: vector_block_xc,
        vector_block_yc <: vector_block_yc,
        vector_block_scale <: vector_block_scale,
        vector_block_action <: vector_block_action,
        draw_vector <: draw_vector,
        vertices_writer_block <: vertices_writer_block,
        vertices_writer_vertex <: vertices_writer_vertex,
        vertices_writer_xdelta <: vertices_writer_xdelta,
        vertices_writer_ydelta <: vertices_writer_ydelta,
        vertices_writer_active <: vertices_writer_active,
        framebuffer <: framebuffer,
        writer_framebuffer <: writer_framebuffer
   );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress ) {
                    case 8h00: { gpu_x = writeData; }
                    case 8h02: { gpu_y = writeData; }
                    case 8h04: { gpu_colour = writeData; }
                    case 8h06: { gpu_colour_alt = writeData; }
                    case 8h08: { gpu_dithermode = writeData; }
                    case 8h0a: { gpu_param0 = writeData; }
                    case 8h0c: { gpu_param1 = writeData; }
                    case 8h0e: { gpu_param2 = writeData; }
                    case 8h10: { gpu_param3 = writeData; }
                    case 8h12: { gpu_param4 = writeData; }
                    case 8h14: { gpu_param5 = writeData; }
                    case 8h16: { gpu_write = writeData; }

                    case 8h20: { vector_block_number = writeData; }
                    case 8h22: { vector_block_colour = writeData; }
                    case 8h24: { vector_block_xc = writeData; }
                    case 8h26: { vector_block_yc = writeData; }
                    case 8h28: { vector_block_scale = writeData; }
                    case 8h2a: { vector_block_action = writeData; }
                    case 8h2c: { draw_vector = 1; }

                    case 8h30: { vertices_writer_block = writeData; }
                    case 8h32: { vertices_writer_vertex = writeData; }
                    case 8h34: { vertices_writer_xdelta = writeData; }
                    case 8h36: { vertices_writer_ydelta = writeData; }
                    case 8h38: { vertices_writer_active = writeData; }

                    case 8h40: { blit1_writer_tile = writeData; }
                    case 8h42: { blit1_writer_line = writeData; }
                    case 8h44: { blit1_writer_bitmap = writeData; }

                    case 8h50: { character_writer_character = writeData; }
                    case 8h52: { character_writer_line = writeData; }
                    case 8h54: { character_writer_bitmap = writeData; }

                    case 8h60: { colourblit_writer_tile = writeData; }
                    case 8h62: { colourblit_writer_line = writeData; }
                    case 8h64: { colourblit_writer_pixel = writeData; }
                    case 8h66: { colourblit_writer_colour = writeData; }

                    case 8h70: { pb_colour7 = writeData; pb_newpixel = 1; }
                    case 8h72: { pb_colour8r = writeData; }
                    case 8h74: { pb_colour8g = writeData; }
                    case 8h76: { pb_colour8b = writeData; pb_newpixel = 2; }
                    case 8h78: { pb_newpixel = 3; }

                    case 8hd0: { bitmap_x_read = writeData; }
                    case 8hd2: { bitmap_y_read = writeData; }

                    case 8he0: { bitmap_write_offset = writeData; }
                    case 8he2: { gpu_crop_left = writeData[15,1] ? 0 : writeData; }
                    case 8he4: { gpu_crop_right = __signed(writeData) > 319 ? 319 : writeData; }
                    case 8he6: { gpu_crop_top = writeData[15,1] ? 0 : writeData; }
                    case 8he8: { gpu_crop_bottom = __signed(writeData) > 239 ? 239 : writeData; }
                    case 8hf0: { framebuffer = writeData; }
                    case 8hf2: { writer_framebuffer = writeData; }
                    default: {}
                }
            }
            case 2b00: {
                bitmap_write_offset = 0;
                gpu_write = 0;
                pb_newpixel = 0;
                draw_vector = 0;
            }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }

    // ON RESET STOP THE PIXEL BLOCK
    if( ~reset ) { pb_newpixel = 3; }

    // RESET THE CROPPING RECTANGLE
    gpu_crop_left = 0; gpu_crop_right = 319; gpu_crop_top = 0; gpu_crop_bottom = 239;
}

algorithm charactermap_memmap(
    // Clocks
    input   uint1   video_clock,
    input   uint1   video_reset,

    // Pixels
    input   uint16  pix_x,
    input   uint16  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   pixel_display,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint16  writeData,

    output  uint2   tpu_active,
    output  uint9   curses_character,
    output  uint7   curses_background,
    output  uint6   curses_foreground
) <autorun> {
    uint7   tpu_x = uninitialized;
    uint6   tpu_y = uninitialized;
    uint9   tpu_character = uninitialized;
    uint6   tpu_foreground = uninitialized;
    uint7   tpu_background = uninitialized;
    uint3   tpu_write = uninitialized;
    uint1   tpu_showcursor = uninitialized;
    character_map character_map_window <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        character_map_display :> pixel_display,
        tpu_active :> tpu_active,
        curses_character :> curses_character,
        curses_background :> curses_background,
        curses_foreground :> curses_foreground,
        tpu_x <: tpu_x,
        tpu_y <: tpu_y,
        tpu_character <: tpu_character,
        tpu_foreground <: tpu_foreground,
        tpu_background <: tpu_background,
        tpu_write <: tpu_write,
        tpu_showcursor <: tpu_showcursor
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress ) {
                    case 8h00: { tpu_x = writeData; }
                    case 8h02: { tpu_y = writeData; }
                    case 8h04: { tpu_character = writeData; }
                    case 8h06: { tpu_background = writeData; }
                    case 8h08: { tpu_foreground = writeData; }
                    case 8h0a: { tpu_write = writeData; }
                    case 8h0c: { tpu_showcursor = writeData; }
                    default: {}
                }
            }
            case 2b00: {
                tpu_write = 0;
            }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }

    // HIDE CURSOR AT STARTUP
    tpu_showcursor = 0;
}

algorithm sprite_memmap(
    // Clocks
    input   uint1   video_clock,
    input   uint1   video_reset,

    // Pixels
    input   uint16  pix_x,
    input   uint16  pix_y,
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
        output  int16   sprite_read_x_$i$,
        output  int16   sprite_read_y_$i$,
        output  uint3   sprite_read_tile_$i$,
        output uint16   collision_$i$,
        output uint4    layer_collision_$i$,
    $$end
) <autorun> {
    uint4   sprite_set_number = uninitialized;
    uint1   sprite_set_active = uninitialized;
    uint3   sprite_set_double = uninitialized;
    uint6   sprite_set_colour = uninitialized;
    int11   sprite_set_x = uninitialized;
    int11   sprite_set_y = uninitialized;
    uint3   sprite_set_tile = uninitialized;
    uint3   sprite_layer_write = uninitialized;
    uint13  sprite_update = uninitialized;
    uint4   sprite_writer_sprite = uninitialized;
    uint7   sprite_writer_line = uninitialized;
    uint16  sprite_writer_bitmap = uninitialized;
    uint1   sprite_writer_active = uninitialized;
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
            sprite_read_active_$i$ :> sprite_read_active_$i$,
            sprite_read_double_$i$ :> sprite_read_double_$i$,
            sprite_read_colour_$i$ :> sprite_read_colour_$i$,
            sprite_read_x_$i$ :> sprite_read_x_$i$,
            sprite_read_y_$i$ :> sprite_read_y_$i$,
            sprite_read_tile_$i$ :> sprite_read_tile_$i$,
            collision_$i$ :> collision_$i$,
            layer_collision_$i$ :> layer_collision_$i$,
        $$end
        sprite_set_number  <: sprite_set_number,
        sprite_set_active  <: sprite_set_active,
        sprite_set_double  <: sprite_set_double,
        sprite_set_colour  <: sprite_set_colour,
        sprite_set_x  <: sprite_set_x,
        sprite_set_y  <: sprite_set_y,
        sprite_set_tile  <: sprite_set_tile,
        sprite_layer_write  <: sprite_layer_write,
        sprite_update  <: sprite_update,
        sprite_writer_sprite  <: sprite_writer_sprite,
        sprite_writer_line  <: sprite_writer_line,
        sprite_writer_bitmap  <: sprite_writer_bitmap,
        sprite_writer_active  <: sprite_writer_active
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( { bitmapwriter, memoryAddress } ) {
                    $$for i=0,15 do
                        case $0x00 + i*2$: { sprite_set_number = $i$; sprite_set_active = writeData; sprite_layer_write = 1; }
                        case $0x20 + i*2$: { sprite_set_number = $i$; sprite_set_double = writeData; sprite_layer_write = 2; }
                        case $0x40 + i*2$: { sprite_set_number = $i$; sprite_set_colour = writeData; sprite_layer_write = 3; }
                        case $0x60 + i*2$: { sprite_set_number = $i$; sprite_set_x = writeData; sprite_layer_write = 4; }
                        case $0x80 + i*2$: { sprite_set_number = $i$; sprite_set_y = writeData; sprite_layer_write = 5; }
                        case $0xa0 + i*2$: { sprite_set_number = $i$; sprite_set_tile = writeData; sprite_layer_write = 6; }
                        case $0xc0 + i*2$: { sprite_set_number = $i$; sprite_update = writeData; sprite_layer_write = 7; }
                    $$end
                    case 9h100: { sprite_writer_sprite = writeData; }
                    case 9h102: { sprite_writer_line = writeData; }
                    case 9h104: { sprite_writer_bitmap = writeData; sprite_writer_active = 1; }
                    default: {}
                }
            }
            case 2b00: {
                sprite_layer_write = 0;
                sprite_writer_active = 0;
            }
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
    input   uint16  pix_x,
    input   uint16  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   pixel_display,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint16  writeData,

    output  uint2   terminal_active
) <autorun> {
    uint8   terminal_character = uninitialized;
    uint2   terminal_write = uninitialized;
    uint1   showterminal = 0;
    terminal terminal_window <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        terminal_display :> pixel_display,
        terminal_active :> terminal_active,
        terminal_character <: terminal_character,
        terminal_write <: terminal_write,
        showterminal <: showterminal
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress ) {
                    case 8h00: { terminal_character = writeData; terminal_write = 1; }
                    case 8h02: { showterminal = writeData; }
                    default: {}
                }
            }
            case 2b00: {
                terminal_write = 0;
            }
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
    input   uint16  pix_x,
    input   uint16  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   pixel_display,

    // Memory access
    input   uint8   memoryAddress,
    input   uint1   memoryWrite,
    input   uint16  writeData,
    output  uint4   tm_lastaction,
    output  uint2   tm_active
) <autorun> {
    uint6   tm_x = uninitialized;
    uint6   tm_y = uninitialized;
    uint6   tm_character = uninitialized;
    uint6   tm_foreground = uninitialized;
    uint7   tm_background = uninitialized;
    uint2   tm_reflection = uninitialized;
    uint1   tm_write = uninitialized;
    uint6   tile_writer_tile = uninitialized;
    uint4   tile_writer_line = uninitialized;
    uint16  tile_writer_bitmap = uninitialized;
    uint4   tm_scrollwrap = uninitialized;
    tilemap tile_map <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        tilemap_display :> pixel_display,
        tm_lastaction :> tm_lastaction,
        tm_active :> tm_active,
        tm_x <: tm_x,
        tm_y <: tm_y,
        tm_character <: tm_character,
        tm_foreground <: tm_foreground,
        tm_background <: tm_background,
        tm_reflection <: tm_reflection,
        tm_write <: tm_write,
        tile_writer_tile <: tile_writer_tile,
        tile_writer_line <: tile_writer_line,
        tile_writer_bitmap <: tile_writer_bitmap,
        tm_scrollwrap <: tm_scrollwrap
    );

     // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress ) {
                    case 8h00: { tm_x = writeData; }
                    case 8h02: { tm_y = writeData; }
                    case 8h04: { tm_character = writeData; }
                    case 8h06: { tm_background = writeData; }
                    case 8h08: { tm_foreground = writeData; }
                    case 8h0a: { tm_reflection = writeData; }
                    case 8h0c: { tm_write = 1; }
                    case 8h10: { tile_writer_tile = writeData; }
                    case 8h12: { tile_writer_line = writeData; }
                    case 8h14: { tile_writer_bitmap = writeData; }
                    case 8h20: { tm_scrollwrap = writeData; }
                    default: {}
                }
            }
            case 2b00: {
                tm_write = 0;
                tm_scrollwrap = 0;
            }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }
}
