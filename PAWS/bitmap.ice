algorithm bitmap(
    input   uint1   framebuffer,
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,
    output! uint1   bitmap_display,

    // Hardware scrolling
    input   uint3   bitmap_write_offset,
    output  uint9   x_offset,
    output  uint8   y_offset,

    // Pixel reader
    input   int10   bitmap_x_read,
    input   int10   bitmap_y_read,
    output  uint7   bitmap_colour_read,

    simple_dualport_bram_port0 bitmap_0,
    simple_dualport_bram_port0 bitmap_1
) <autorun> {
    // Pixel x and y fetching ( adjusting for offset )
    uint9  x_plus_one <: ( pix_x[1,9] + x_offset + 1 ) > 319 ? ( pix_x[1,9] + x_offset + 1 ) - 320 : ( pix_x[1,9] + x_offset + 1 );
    uint8  y_line <: pix_vblank ? y_offset : ( ( pix_y[1,9] + y_offset ) > 239 ? ( pix_y[1,9] + y_offset ) - 240 : ( pix_y[1,9] + y_offset ) );
    uint9  x_pixel <: pix_active ? x_plus_one : x_offset;

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
            case 1: {
                x_offset = ( x_offset == 319 ) ? 0 : x_offset + 1;
            }
            case 2: {
                y_offset = ( y_offset == 239 ) ? 0 : y_offset + 1;
            }
            case 3: {
                x_offset = ( x_offset == 0 ) ? 319 : x_offset - 1;
            }
            case 4: {
                y_offset = ( y_offset == 0 ) ? 239 : y_offset - 1;
            }
            case 5: {
                x_offset = 0;
                y_offset = 0;
            }
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
            // == 0 SOLID == 1 SMALL CHECKERBOARD == 2 MED CHECKERBOARD == 3 LARGE CHECKERBOARD == 4 VERTICAL STRIPES == 5 HORIZONTAL STRIPES == 6 CROSSHATCH == 7 LEFT SLOPE
            // == 8 RIGHT SLOPE == 9 LEFT TRIANGLE == 10 RIGHT TRIANGLE == 15 STATIC
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
