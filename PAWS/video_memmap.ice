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
    input   uint6   static16bit
) <autorun> {
    // CURSOR CLOCK
    uint1   blink = uninitialised;
    pulsecursor CURSOR <@clock_25mhz> ( show :> blink );

    // Video Reset
    uint1   video_reset := reset;

    // RNG random number generator
    uint1   static1bit <:: static16bit[0,1];
    uint2   static2bit <:: static16bit[0,2];
    uint6   static6bit <:: static16bit;

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
    uint1   BACKGROUNDmemoryWrite = uninitialized;
    background_memmap BACKGROUND(
        video_clock <: clock_25mhz,
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
        video_clock <: clock_25mhz,
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
        video_clock <: clock_25mhz,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> character_map_p,
        pixel_display :> character_map_display,
        blink <: blink,
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
        int11   Lsprite_read_x_$i$ = uninitialized;
        int10   Lsprite_read_y_$i$ = uninitialized;
        uint3   Lsprite_read_tile_$i$ = uninitialized;
        uint16  Lcollision_$i$ = uninitialized;
        uint4   Llayer_collision_$i$ = uninitialized;
    $$end
    sprite_memmap LOWER_SPRITE(
        video_clock <: clock_25mhz,
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
        int11   Usprite_read_x_$i$ = uninitialized;
        int10   Usprite_read_y_$i$ = uninitialized;
        uint3   Usprite_read_tile_$i$ = uninitialized;
        uint16  Ucollision_$i$ = uninitialized;
        uint4   Ulayer_collision_$i$ = uninitialized;
    $$end
    sprite_memmap UPPER_SPRITE(
        video_clock <: clock_25mhz,
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
    uint1   terminal_p = uninitialized;
    uint1   terminal_display = uninitialized;
    uint2   terminal_active = uninitialized;
    uint1   TERMINALmemoryWrite = uninitialized;
    terminal_memmap TERMINAL(
        video_clock <: clock_25mhz,
        video_reset <: video_reset,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> terminal_p,
        pixel_display :> terminal_display,
        blink <: blink,
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
        video_clock <: clock_25mhz,
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
        video_clock <: clock_25mhz,
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
    uint1   colour = uninitialized;
    multiplex_display display <@clock_25mhz,!video_reset> (
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
        display_order <: display_order,
        colour <: colour
    );

    BACKGROUNDmemoryWrite := 0; BITMAPmemoryWrite := 0; CHARACTER_MAPmemoryWrite := 0; LOWER_SPRITEmemoryWrite := 0; UPPER_SPRITEmemoryWrite := 0; TERMINALmemoryWrite := 0; LOWER_TILEmemoryWrite := 0; UPPER_TILEmemoryWrite := 0;

    always {
        // READ IO Memory
        if( memoryRead ) {
            switch( memoryAddress[8,4] ) {
                case 4h1: { readData = memoryAddress[1,1] ? Ltm_active : Ltm_lastaction; }
                case 4h2: { readData = memoryAddress[1,1] ? Utm_active : Utm_lastaction; }
                case 4h3: {
                    switch( memoryAddress[1,7] ) {
                        $$for i=0,15 do
                            case $0x00 + i$: { readData = Lsprite_read_active_$i$; }
                            case $0x10 + i$: { readData = Lsprite_read_double_$i$; }
                            case $0x20 + i$: { readData = Lsprite_read_colour_$i$; }
                            case $0x30 + i$: { readData = {{5{Lsprite_read_x_$i$[10,1]}}, Lsprite_read_x_$i$}; }
                            case $0x40 + i$: { readData = {{6{Lsprite_read_y_$i$[9,1]}}, Lsprite_read_y_$i$}; }
                            case $0x50 + i$: { readData = Lsprite_read_tile_$i$; }
                            case $0x60 + i$: { readData = Lcollision_$i$; }
                            case $0x70 + i$: { readData = Llayer_collision_$i$; }
                        $$end
                    }
                }
                case 4h4: {
                    switch( memoryAddress[1,7] ) {
                        $$for i=0,15 do
                            case $0x00 + i$: { readData = Usprite_read_active_$i$; }
                            case $0x10 + i$: { readData = Usprite_read_double_$i$; }
                            case $0x20 + i$: { readData = Usprite_read_colour_$i$; }
                            case $0x30 + i$: { readData = {{5{Usprite_read_x_$i$[10,1]}}, Usprite_read_x_$i$}; }
                            case $0x40 + i$: { readData = {{6{Usprite_read_y_$i$[9,1]}}, Usprite_read_y_$i$}; }
                            case $0x50 + i$: { readData = Usprite_read_tile_$i$; }
                            case $0x60 + i$: { readData = Ucollision_$i$; }
                            case $0x70 + i$: { readData = Ulayer_collision_$i$; }
                        $$end
                    }
                    }
                case 4h5: {
                    switch( memoryAddress[1,3] ) {
                        case 3h2: { readData = curses_character; }
                        case 3h3: { readData = curses_background; }
                        case 3h4: { readData = curses_foreground; }
                        case 3h5: { readData = tpu_active; }
                        default: { readData = 0; }
                    }
                }
                case 4h6: {
                    switch( memoryAddress[1,7] ) {
                        case 7h0b: { readData = gpu_queue_full; }
                        case 7h0c: { readData = gpu_queue_complete; }
                        case 7h15: { readData = vector_block_active; }
                        case 7h6a: { readData = bitmap_colour_read; }
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
                case 4hf: {
                    if( memoryAddress[0,1] ) {
                        colour = writeData;
                    } else {
                        display_order = writeData;
                    }
                }
                default: {}
            }
        }
    }

    if( ~reset ) {
        // SET DEFAULT DISPLAY ORDER AND COLOUR MODE
        display_order = 0; colour = 1;
    }
}

// ALL DISPLAY GENERATOR UNITS RUN AT 25MHz, 640 x 480 @ 60fps
// WRITING TO THE DISPLAY GENERATOR UNITS THEREFORE LATCHES THEREFORE
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
) <autorun> {
    // BACKGROUND GENERATOR
    uint6   BACKGROUNDcolour = uninitialised;
    uint6   BACKGROUNDalt = uninitialised;
    uint4   BACKGROUNDmode = uninitialised;
    background_display BACKGROUND <@video_clock,!video_reset> (
        pix_x <: pix_x,
        pix_y <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel :> pixel,
        staticGenerator <: static2bit,
        b_colour <: BACKGROUNDcolour,
        b_alt <: BACKGROUNDalt,
        b_mode <: BACKGROUNDmode
    );

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
    background_writer BACKGROUND_WRITER <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
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
        copper_colour <: copper_colour,
        BACKGROUNDcolour :> BACKGROUNDcolour,
        BACKGROUNDalt :> BACKGROUNDalt,
        BACKGROUNDmode :> BACKGROUNDmode
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress ) {
                    case 6h00: { backgroundcolour = writeData; background_update = 1; }
                    case 6h02: { backgroundcolour_alt = writeData; background_update = 2; }
                    case 6h04: { backgroundcolour_mode = writeData; background_update = 3; }
                    case 6h10: { copper_program = writeData; }
                    case 6h12: { copper_status = writeData; }
                    case 6h20: { copper_address = writeData; }
                    case 6h22: { copper_command = writeData; }
                    case 6h24: { copper_condition = writeData; }
                    case 6h26: { copper_coordinate = writeData; }
                    case 6h28: { copper_cpu_input = writeData; }
                    case 6h2a: { copper_mode = writeData; }
                    case 6h2c: { copper_alt = writeData; }
                    case 6h2e: { copper_colour = writeData; }
                    default: {}
                }
            }
            case 2b00: { background_update = 0; copper_program = 0; }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }
}

algorithm bitmap_memmap(
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
    simple_dualport_bram uint1 bitmap_0A <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint1 bitmap_1A <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint2 bitmap_0R <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint2 bitmap_1R <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint2 bitmap_0G <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint2 bitmap_1G <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint2 bitmap_0B <@video_clock,@video_clock> [ 76800 ] = uninitialized;
    simple_dualport_bram uint2 bitmap_1B <@video_clock,@video_clock> [ 76800 ] = uninitialized;

    // BITMAP DISPLAY
    uint1   framebuffer = uninitialized;
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
        bitmap_display :> pixel_display,
        bitmap_x_read <: bitmap_x_read,
        bitmap_y_read <: bitmap_y_read,
        framebuffer <: framebuffer
   );

    // BITMAP WRITER AND GPU
    uint1   writer_framebuffer = uninitialized;
    int11   bitmap_x_read = uninitialized;
    int11   bitmap_y_read = uninitialized;
    int11   gpu_x = uninitialized;
    int11   gpu_y = uninitialized;
    uint7   gpu_colour = uninitialized;
    uint7   gpu_colour_alt = uninitialized;
    int11   gpu_param0 = uninitialized;
    int11   gpu_param1 = uninitialized;
    int11   gpu_param2 = uninitialized;
    int11   gpu_param3 = uninitialized;
    int11   gpu_param4 = uninitialized;
    int11   gpu_param5 = uninitialized;
    uint4   gpu_write = uninitialized;
    uint4   gpu_dithermode = uninitialized;
    uint9   gpu_crop_left = uninitialized;
    uint9   gpu_crop_right = uninitialized;
    uint8   gpu_crop_top = uninitialized;
    uint8   gpu_crop_bottom = uninitialized;
    uint6   blit1_writer_tile = uninitialized;
    uint4   blit1_writer_line = uninitialized;
    uint16  blit1_writer_bitmap = uninitialized;
    uint9   character_writer_character = uninitialized;
    uint3   character_writer_line = uninitialized;
    uint8   character_writer_bitmap = uninitialized;
    uint6   colourblit_writer_tile = uninitialized;
    uint4   colourblit_writer_line = uninitialized;
    uint4   colourblit_writer_pixel = uninitialized;
    uint7   colourblit_writer_colour = uninitialized;
    uint7   pb_colour7 = uninitialized;
    uint8   pb_colour8r = uninitialized;
    uint8   pb_colour8g = uninitialized;
    uint8   pb_colour8b = uninitialized;
    uint2   pb_newpixel = uninitialized;
    uint6   vector_block_number = uninitialized;
    uint7   vector_block_colour = uninitialized;
    int11   vector_block_xc = uninitialized;
    int11   vector_block_yc = uninitialized;
    uint3   vector_block_scale = uninitialized;
    uint3   vector_block_action = uninitialized;
    uint1   draw_vector = uninitialized;
    uint6   vertices_writer_block = uninitialized;
    uint6   vertices_writer_vertex = uninitialized;
    int6    vertices_writer_xdelta = uninitialized;
    int6    vertices_writer_ydelta = uninitialized;
    uint1   vertices_writer_active = uninitialized;
    bitmapwriter pixel_writer <@video_clock,!video_reset> (
        crop_left <: gpu_crop_left,
        crop_right <: gpu_crop_right,
        crop_top <: gpu_crop_top,
        crop_bottom <: gpu_crop_bottom,
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
        framebuffer <: writer_framebuffer,
        static1bit <: static1bit,
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

    always {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress[4,4] ) {
                    case 4h0: {
                        switch( memoryAddress[1,3] ) {
                            case 3h0: { gpu_x = writeData; }
                            case 3h1: { gpu_y = writeData; }
                            case 3h2: { gpu_colour = writeData; }
                            case 3h3: { gpu_colour_alt = writeData; }
                            case 3h4: { gpu_dithermode = writeData; }
                            case 3h5: { gpu_param0 = writeData; }
                            case 3h6: { gpu_param1 = writeData; }
                            case 3h7: { gpu_param2 = writeData; }
                        }
                    }
                    case 4h1: {
                        switch( memoryAddress[1,2] ) {
                            case 2h0: { gpu_param3 = writeData; }
                            case 2h1: { gpu_param4 = writeData; }
                            case 2h2: { gpu_param5 = writeData; }
                            case 2h3: { gpu_write = writeData; }
                        }
                    }
                    case 4h2: {
                        switch( memoryAddress[1,3] ) {
                            case 3h0: { vector_block_number = writeData; }
                            case 3h1: { vector_block_colour = writeData; }
                            case 3h2: { vector_block_xc = writeData; }
                            case 3h3: { vector_block_yc = writeData; }
                            case 3h4: { vector_block_scale = writeData; }
                            case 3h5: { vector_block_action = writeData; }
                            case 3h6: { draw_vector = 1; }
                            default: {}
                        }
                    }
                    case 4h3: {
                        switch( memoryAddress[1,3] ) {
                            case 3h0: { vertices_writer_block = writeData; }
                            case 3h1: { vertices_writer_vertex = writeData; }
                            case 3h2: { vertices_writer_xdelta = writeData; }
                            case 3h3: { vertices_writer_ydelta = writeData; }
                            case 3h4: { vertices_writer_active = writeData; }
                            default: {}
                        }
                    }
                    case 4h4: {
                        switch( memoryAddress[1,3] ) {
                            case 3h0: { blit1_writer_tile = writeData; }
                            case 3h1: { blit1_writer_line = writeData; }
                            case 3h2: { blit1_writer_bitmap = writeData; }
                            default: {}
                        }
                    }
                    case 4h5: {
                        switch( memoryAddress[1,2] ) {
                            case 2h0: { character_writer_character = writeData; }
                            case 2h1: { character_writer_line = writeData; }
                            case 2h2: { character_writer_bitmap = writeData; }
                            default: {}
                        }
                    }
                    case 4h6: {
                        switch( memoryAddress[1,2] ) {
                            case 2h0: { colourblit_writer_tile = writeData; }
                            case 2h1: { colourblit_writer_line = writeData; }
                            case 2h2: { colourblit_writer_pixel = writeData; }
                            case 2h3: { colourblit_writer_colour = writeData; }
                        }
                    }
                    case 4h7: {
                        switch( memoryAddress[1,3] ) {
                            case 3h0: { pb_colour7 = writeData; pb_newpixel = 1; }
                            case 3h1: { pb_colour8r = writeData; }
                            case 3h2: { pb_colour8g = writeData; }
                            case 3h3: { pb_colour8b = writeData; pb_newpixel = 2; }
                            case 3h4: { pb_newpixel = 3; }
                            default: {}
                        }
                    }
                    case 4hd: {
                        if( memoryAddress[1,1] ) {
                             bitmap_y_read = writeData;
                        } else {
                             bitmap_x_read = writeData;
                        }
                    }
                    case 4he: {
                        switch( memoryAddress[1,3] ) {
                            case 3h1: { gpu_crop_left = writeData[15,1] ? 0 : writeData; }
                            case 3h2: { gpu_crop_right = __signed(writeData) > 319 ? 319 : writeData; }
                            case 3h3: { gpu_crop_top = writeData[15,1] ? 0 : writeData; }
                            case 3h4: { gpu_crop_bottom = __signed(writeData) > 239 ? 239 : writeData; }
                            default: {}
                        }
                    }
                    case 4hf: {
                        if( memoryAddress[1,1] ) {
                            framebuffer = writeData;
                        } else {
                            writer_framebuffer = writeData;
                        }
                    }
                    default: {}

                }
            }
            case 2b00: { gpu_write = 0;  pb_newpixel = 0; draw_vector = 0; }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }

    if( ~reset ) {
        // ON RESET STOP THE PIXEL BLOCK
        pb_newpixel = 3;

        // RESET THE CROPPING RECTANGLE
        gpu_crop_left = 0; gpu_crop_right = 319; gpu_crop_top = 0; gpu_crop_bottom = 239;
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
) <autorun> {
    // 80 x 30 character buffer
    // Setting background to 40 (ALPHA) allows the bitmap/background to show through, charactermap { BOLD, character }
    simple_dualport_bram uint9 charactermap <@video_clock,@video_clock> [4800] = uninitialized;
    simple_dualport_bram uint13 colourmap <@video_clock,@video_clock> [4800] = uninitialized;

    // CHARACTER MAP WRITER
    int7    tpu_x = uninitialized;
    uint6   tpu_y = uninitialized;
    uint9   tpu_character = uninitialized;
    uint6   tpu_foreground = uninitialized;
    uint7   tpu_background = uninitialized;
    uint3   tpu_write = uninitialized;
    uint7   cursor_x = uninitialized;
    uint6   cursor_y = uninitialized;
    character_map_writer CMW <@video_clock,!video_reset> (
        charactermap <:> charactermap,
        colourmap <:> colourmap,
        tpu_x <: tpu_x,
        tpu_y <: tpu_y,
        tpu_character <: tpu_character,
        tpu_foreground <: tpu_foreground,
        tpu_background <: tpu_background,
        tpu_write <: tpu_write,
        tpu_active :> tpu_active,
        curses_character :> curses_character,
        curses_background :> curses_background,
        curses_foreground :> curses_foreground,
        cursor_x :> cursor_x,
        cursor_y :> cursor_y
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
        tpu_showcursor <: tpu_showcursor,
        cursor_x <: cursor_x,
        cursor_y <: cursor_y
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress[1,3] ) {
                    case 3h0: { tpu_x = writeData; }
                    case 3h1: { tpu_y = writeData; }
                    case 3h2: { tpu_character = writeData; }
                    case 3h3: { tpu_background = writeData; }
                    case 3h4: { tpu_foreground = writeData; }
                    case 3h5: { tpu_write = writeData; }
                    case 3h6: { tpu_showcursor = writeData; }
                    default: {}
                }
            }
            case 2b00: { tpu_write = 0; }
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
) <autorun> {
    $$for i=0,15 do
        // Sprite Tiles
        simple_dualport_bram uint16 tiles_$i$ <@video_clock,@video_clock> [128] = uninitialised;
    $$end

    uint4   sprite_set_number = uninitialized;
    uint13  sprite_write_value = uninitialized;
    uint3   sprite_layer_write = uninitialized;
    uint4   sprite_writer_sprite = uninitialized;
    uint7   sprite_writer_line = uninitialized;
    uint16  sprite_writer_bitmap = uninitialized;
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
        sprite_set_number  <: sprite_set_number,
        sprite_write_value  <: sprite_write_value,
        sprite_layer_write  <: sprite_layer_write
    );

    // UPDATE THE SPRITE TILE BITMAPS
    spritebitmapwriter SBMW <@video_clock,!video_reset> (
        sprite_writer_sprite <: sprite_writer_sprite,
        sprite_writer_line <: sprite_writer_line,
        sprite_writer_bitmap <: sprite_writer_bitmap,
        $$for i=0,15 do
            tiles_$i$ <:> tiles_$i$,
        $$end
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                if( bitmapwriter ) {
                    switch( memoryAddress[1,2] ) {
                        case 2h0: { sprite_writer_sprite = writeData; }
                        case 2h1: { sprite_writer_line = writeData; }
                        case 2h2: { sprite_writer_bitmap = writeData; }
                        default: {}
                    }
                } else {
                    // SET SPRITE ATTRIBUTE
                    sprite_set_number = memoryAddress[1,4];
                    sprite_write_value = writeData;
                    sprite_layer_write = memoryAddress[5,3] + 1;
                }
            }
            case 2b00: { sprite_layer_write = 0; }
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
) <autorun> {
    // 80 x 4 character buffer for the input/output terminal
    simple_dualport_bram uint8 terminal <@video_clock,@video_clock> [640] = uninitialized;

    uint8   terminal_character = uninitialized;
    uint2   terminal_write = uninitialized;
    uint1   showterminal = 0;
    terminal terminal_window <@video_clock,!video_reset> (
        terminal <:> terminal,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        terminal_display :> pixel_display,
        blink <: blink,
        showterminal <: showterminal,
        terminal_x <: terminal_x,
        terminal_y <: terminal_y
    );

    uint7 terminal_x = uninitialised;
    uint3 terminal_y = uninitialised;
    terminal_writer TW <@video_clock,!video_reset> (
        terminal <:> terminal,
        terminal_character <: terminal_character,
        terminal_write <: terminal_write,
        terminal_active :> terminal_active,
        terminal_x :> terminal_x,
        terminal_y :> terminal_y
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress[1,2] ) {
                    case 2h0: { terminal_character = writeData; terminal_write = 1; }
                    case 2h1: { showterminal = writeData; }
                    case 2h2: { terminal_write = 2; }
                    default: {}
                }
            }
            case 2b00: { terminal_write = 0; }
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
) <autorun> {
    // Tiles 64 x 16 x 16
    simple_dualport_bram uint16 tiles16x16 <@video_clock,@video_clock> [ 1024 ] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, pad(uninitialized) };

    // 42 x 32 tile map, allows for pixel scrolling with border { 2 bit reflection, 7 bits background, 6 bits foreground, 5 bits tile number }
    simple_dualport_bram uint6 tiles <@video_clock,@video_clock> [1344] = uninitialized;
    simple_dualport_bram uint15 colours <@video_clock,@video_clock> [1344] = uninitialized;

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
        tiles16x16 <:> tiles16x16,
        tiles <:> tiles,
        colours <:> colours,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        tm_offset_x <: tm_offset_x,
        tm_offset_y <: tm_offset_y,
        tilemap_display :> pixel_display,
    );

    // Scroll position - -15 to 0 to 15
    // -15 or 15 will trigger appropriate scroll when next moved in that direction
    int5    tm_offset_x = uninitialized;
    int5    tm_offset_y = uninitialized;
    tile_map_writer TMW <@video_clock,!video_reset> (
        tiles <:> tiles,
        colours <:> colours,
        tm_x <: tm_x,
        tm_y <: tm_y,
        tm_character <: tm_character,
        tm_foreground <: tm_foreground,
        tm_background <: tm_background,
        tm_reflection <: tm_reflection,
        tm_write <: tm_write,
        tm_offset_x :> tm_offset_x,
        tm_offset_y :> tm_offset_y,
        tm_scrollwrap <: tm_scrollwrap,
        tm_lastaction :> tm_lastaction,
        tm_active :> tm_active
    );

    tilebitmapwriter TBMW <@video_clock,!video_reset> (
        tile_writer_tile <: tile_writer_tile,
        tile_writer_line <: tile_writer_line,
        tile_writer_bitmap <: tile_writer_bitmap,
        tiles16x16 <:> tiles16x16
    );

     // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress[1,5] ) {
                    case 5h00: { tm_x = writeData; }
                    case 5h01: { tm_y = writeData; }
                    case 5h02: { tm_character = writeData; }
                    case 5h03: { tm_background = writeData; }
                    case 5h04: { tm_foreground = writeData; }
                    case 5h05: { tm_reflection = writeData; }
                    case 5h06: { tm_write = 1; }
                    case 5h08: { tile_writer_tile = writeData; }
                    case 5h09: { tile_writer_line = writeData; }
                    case 5h0a: { tile_writer_bitmap = writeData; }
                    case 5h10: { tm_scrollwrap = writeData; }
                    default: {}
                }
            }
            case 2b00: { tm_write = 0; tm_scrollwrap = 0; }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }
}
