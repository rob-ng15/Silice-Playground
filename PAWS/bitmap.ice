algorithm bitmap(
    input   uint1   gpu_clock,

    input   uint1   framebuffer,
    input   uint1   writer_framebuffer,
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,
    output! uint1   bitmap_display,

    // STATIC GENERATOR
    input   uint1   static1bit,
    input   uint6   static6bit,

    // Hardware scrolling
    input   uint3   bitmap_write_offset,

    // Pixel reader
    input   int10   bitmap_x_read,
    input   int10   bitmap_y_read,
    output  uint7   bitmap_colour_read,

    // GPU Parameters
    input   int10   gpu_x,
    input   int10   gpu_y,
    input   uint7   gpu_colour,
    input   uint7   gpu_colour_alt,
    input   int10   gpu_param0,
    input   int10   gpu_param1,
    input   int10   gpu_param2,
    input   int10   gpu_param3,
    input   uint4   gpu_write,
    input   uint4   gpu_dithermode,

    // For setting blit1 tile bitmaps
    input   uint5   blit1_writer_tile,
    input   uint4   blit1_writer_line,
    input   uint16  blit1_writer_bitmap,

    // For setting character generator bitmaps
    input   uint8   character_writer_character,
    input   uint3   character_writer_line,
    input   uint8   character_writer_bitmap,

    // For set colourblit tile bitmaps
    input   uint5   colourblit_writer_tile,
    input   uint4   colourblit_writer_line,
    input   uint4   colourblit_writer_pixel,
    input   uint7   colourblit_writer_colour,

    // VECTOR BLOCK
    input   uint5   vector_block_number,
    input   uint7   vector_block_colour,
    input   int10   vector_block_xc,
    input   int10   vector_block_yc,
    input   uint3   vector_block_scale,
    input   uint1   draw_vector,
    // For setting vertices
    input   uint5   vertices_writer_block,
    input   uint6   vertices_writer_vertex,
    input   int6    vertices_writer_xdelta,
    input   int6    vertices_writer_ydelta,
    input   uint1   vertices_writer_active,

    output  uint1   gpu_active,
    output  uint1   vector_block_active
) <autorun> {
    simple_dualport_bram uint7 bitmap_0 <input!> [ 76800 ] = uninitialized;
    simple_dualport_bram uint7 bitmap_1 <input!> [ 76800 ] = uninitialized;

    // Pixel x and y fetching ( adjusting for offset )
    uint9  x_plus_one <: ( pix_x[1,9] + x_offset + 1 ) > 319 ? ( pix_x[1,9] + x_offset + 1 ) - 320 : ( pix_x[1,9] + x_offset + 1 );
    uint8  y_line <: pix_vblank ? y_offset : ( ( pix_y[1,9] + y_offset ) > 239 ? ( pix_y[1,9] + y_offset ) - 240 : ( pix_y[1,9] + y_offset ) );
    uint9  x_pixel <: pix_active ? x_plus_one : x_offset;

    // BITMAP HARDWARE SCROLLING
    uint9  x_offset = uninitialized;
    uint8  y_offset = uninitialized;

    // From GPU to set a pixel
    int10   bitmap_x_write = uninitialized;
    int10   bitmap_y_write = uninitialized;
    uint7   bitmap_colour_write = uninitialized;
    uint7   bitmap_colour_write_alt = uninitialized;
    uint4   gpu_active_dithermode = uninitialized;
    uint1   bitmap_write = uninitialized;

    bitmapwriter pixel_writer(
        framebuffer <: writer_framebuffer,
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

    gpu gpu_processor(
        gpu_x <: gpu_x,
        gpu_y <: gpu_y,
        gpu_colour <: gpu_colour,
        gpu_colour_alt <: gpu_colour_alt,
        gpu_param0 <: gpu_param0,
        gpu_param1 <: gpu_param1,
        gpu_param2 <: gpu_param2,
        gpu_param3 <: gpu_param3,
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
        vector_block_number <: vector_block_number,
        vector_block_colour <: vector_block_colour,
        vector_block_xc <: vector_block_xc,
        vector_block_yc <: vector_block_yc,
        vector_block_scale <: vector_block_scale,
        draw_vector <: draw_vector,
        vertices_writer_block <: vertices_writer_block,
        vertices_writer_vertex <: vertices_writer_vertex,
        vertices_writer_xdelta <: vertices_writer_xdelta,
        vertices_writer_ydelta <: vertices_writer_ydelta,
        vertices_writer_active <: vertices_writer_active,

        gpu_active :> gpu_active,
        vector_block_active :> vector_block_active,

        bitmap_x_write :> bitmap_x_write,
        bitmap_y_write :> bitmap_y_write,
        bitmap_colour_write :> bitmap_colour_write,
        bitmap_colour_write_alt :> bitmap_colour_write_alt,
        bitmap_write :> bitmap_write,
        gpu_active_dithermode :> gpu_active_dithermode
    );

    // Pixel being read?
    bitmap_colour_read := ( pix_x[1,9] == bitmap_x_read ) && ( pix_y[1,9] == bitmap_y_read ) ? ( framebuffer ? bitmap_1.rdata0 : bitmap_0.rdata0 ) : bitmap_colour_read;

    // Setup the address in the bitmap for the pixel being rendered
    // Use pre-fetching of the next pixel ready for the next cycle
    // y_line * 320 + x_pixel
    bitmap_0.addr0 := y_line * 320 + x_pixel;
    bitmap_1.addr0 := y_line * 320 + x_pixel;

    // RENDER - Default to transparent
    bitmap_display := pix_active && ~( framebuffer ? bitmap_1.rdata0[6,1] : bitmap_0.rdata0[6,1] );
    pix_red := framebuffer ? bitmap_1.rdata0[4,2] : bitmap_0.rdata0[4,2];
    pix_green := framebuffer ? bitmap_1.rdata0[2,2] : bitmap_0.rdata0[2,2];
    pix_blue := framebuffer ? bitmap_1.rdata0[0,2] : bitmap_0.rdata0[0,2];

    while(1) {
        switch( bitmap_write_offset ) {
            case 1: { x_offset = ( x_offset == 319 ) ? 0 : x_offset + 1; }
            case 2: { y_offset = ( y_offset == 239 ) ? 0 : y_offset + 1; }
            case 3: { x_offset = ( x_offset == 0 ) ? 319 : x_offset - 1; }
            case 4: { y_offset = ( y_offset == 0 ) ? 239 : y_offset - 1; }
            case 5: { x_offset = 0; y_offset = 0; }
        }
   }
}

algorithm bitmapwriter(
    // SET pixels
    input   uint1   framebuffer,
    input   int10   bitmap_x_write,
    input   int10   bitmap_y_write,
    input   uint7   bitmap_colour_write,
    input   uint7   bitmap_colour_write_alt,
    input   uint1   bitmap_write,
    input   uint4   gpu_active_dithermode,
    input   uint1   static1bit,
    input   uint6   static6bit,
    input   uint9   x_offset,
    input   uint8   y_offset,

    simple_dualport_bram_port1 bitmap_0,
    simple_dualport_bram_port1 bitmap_1
) <autorun> {
    uint7   pixeltowrite = uninitialised;

    // Pixel x and y for writing ( adjusting for offset )
    int10  x_write_pixel <: ( bitmap_x_write + x_offset ) > 319 ? ( bitmap_x_write + x_offset ) - 320 : ( bitmap_x_write + x_offset );
    int10  y_write_pixel <: ( bitmap_y_write + y_offset ) > 239 ? ( bitmap_y_write + y_offset ) - 240 : ( bitmap_y_write + y_offset );

    // Write in range?
    uint1 write_pixel <: (bitmap_x_write >= 0 ) && (bitmap_x_write < 320) && (bitmap_y_write >= 0) && (bitmap_y_write <= 239) && bitmap_write;

    // Bitmap write access for the GPU - Only enable when x and y are in range
    bitmap_0.wenable1 := 1;
    bitmap_1.wenable1 := 1;

    while(1) {
        if( write_pixel ) {
            // DITHER PATTERNS
            // == 0 SOLID == 1 SMALL CHECKERBOARD == 2 MED CHECKERBOARD == 3 LARGE CHECKERBOARD
            // == 4 VERTICAL STRIPES == 5 HORIZONTAL STRIPES == 6 CROSSHATCH == 7 LEFT SLOPE
            // == 8 RIGHT SLOPE == 9 LEFT TRIANGLE == 10 RIGHT TRIANGLE == 11 ENCLOSED
            // == 12 OCTRAGON == 13 BRICK == 14 COLOUR STATIC == 15 STATIC
            switch( gpu_active_dithermode ) {
                case 0: { pixeltowrite = bitmap_colour_write; }
                case 1: { pixeltowrite = ( bitmap_x_write[0,1] == bitmap_y_write[0,1] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 2: { pixeltowrite = ( bitmap_x_write[1,1] == bitmap_y_write[1,1] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 3: { pixeltowrite = ( bitmap_x_write[2,1] == bitmap_y_write[2,1] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 4: { pixeltowrite = bitmap_x_write[0,1] ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 5: { pixeltowrite = bitmap_y_write[0,1] ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 6: { pixeltowrite = ( bitmap_x_write[0,1] || bitmap_y_write[0,1] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 7: { pixeltowrite = ( bitmap_x_write[0,2] == bitmap_y_write[0,2] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 8: { pixeltowrite = ( bitmap_x_write[0,2] == ~bitmap_y_write[0,2] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 9: {
                    switch( bitmap_y_write[0,2] ) {
                        case 2b00: { pixeltowrite = ( bitmap_x_write[0,2] == 2b00 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b01: { pixeltowrite = ( bitmap_x_write[0,2] < 2b10 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b10: { pixeltowrite = ( bitmap_x_write[0,2] != 2b11 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b11: { pixeltowrite = bitmap_colour_write; }
                    }
                }
                case 10: {
                    switch( bitmap_y_write[0,2] ) {
                        case 2b00: { pixeltowrite = ( bitmap_x_write[0,2] == 2b11 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b01: { pixeltowrite = ( bitmap_x_write[0,2] > 2b01 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b10: { pixeltowrite = ( bitmap_x_write[0,2] != 2b00 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b11: { pixeltowrite = bitmap_colour_write; }
                    }
                }
                case 11: {
                    switch( bitmap_y_write[0,2] ) {
                        case 2b01: { pixeltowrite = ( bitmap_x_write[0,1] == bitmap_x_write[1,1] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b10: { pixeltowrite = ( bitmap_x_write[0,1] == bitmap_x_write[1,1] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        default:  { pixeltowrite = bitmap_colour_write; }
                    }
                }
                case 12: {
                    switch( bitmap_y_write[0,2] ) {
                        case 2b00: { pixeltowrite = ( bitmap_x_write[0,1] == bitmap_x_write[1,1] ) ? bitmap_colour_write_alt : bitmap_colour_write; }
                        case 2b11: { pixeltowrite = ( bitmap_x_write[0,1] == bitmap_x_write[1,1] ) ? bitmap_colour_write_alt : bitmap_colour_write; }
                        default: { pixeltowrite = bitmap_colour_write; }
                    }
                }
                case 13: {
                    switch( bitmap_y_write[0,3] ) {
                        case 3b000: { pixeltowrite = bitmap_colour_write; }
                        case 3b001: { pixeltowrite = ( bitmap_x_write[0,2] == 2b00 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 3b010: { pixeltowrite = ( bitmap_x_write[0,2] == 2b00 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 3b011: { pixeltowrite = ( bitmap_x_write[0,2] == 2b00 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 3b100: { pixeltowrite = bitmap_colour_write; }
                        case 3b101: { pixeltowrite = ( bitmap_x_write[0,2] == 2b10 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 3b110: { pixeltowrite = ( bitmap_x_write[0,2] == 2b10 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 3b111: { pixeltowrite = ( bitmap_x_write[0,2] == 2b10 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                    }
                }
                case 14: { pixeltowrite = static6bit; }
                case 15: { pixeltowrite = ( static1bit ? bitmap_colour_write : bitmap_colour_write_alt ); }
                default: { pixeltowrite = bitmap_colour_write; }
            }

            // SET PIXEL ADDRESSS y_write_pixel * 320 + x_write_pixel
            switch( framebuffer ) {
                case 0: {
                    bitmap_0.addr1 = y_write_pixel * 320 + x_write_pixel;
                    bitmap_0.wdata1 = pixeltowrite;
                }
                case 1: {
                    bitmap_1.addr1 = y_write_pixel * 320 + x_write_pixel;
                    bitmap_1.wdata1 = pixeltowrite;
                }
            }
        }
    }
}
