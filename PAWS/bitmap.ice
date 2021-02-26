algorithm bitmap(
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
    output  uint10  x_offset,
    output  uint10  y_offset,

    // Pixel reader
    input   int16   bitmap_x_read,
    input   int16   bitmap_y_read,
    output  uint7   bitmap_colour_read,

    simple_dualport_bram_port0 bitmap
) <autorun> {
    // Pixel x and y fetching ( adjusting for offset )
    uint10  x_plus_one := ( pix_x + x_offset + 1 ) > 639 ? ( pix_x + x_offset + 1 ) - 640 : ( pix_x + x_offset + 1 );
    uint10  y_line := pix_vblank ? y_offset : ( ( pix_y + y_offset ) > 479 ? ( pix_y + y_offset ) - 480 : ( pix_y + y_offset ) );
    uint10  x_pixel := pix_active ? x_plus_one : x_offset;

    // Pixel being read?
    bitmap_colour_read := ( pix_x == bitmap_x_read ) && ( pix_y == bitmap_y_read ) ? bitmap.rdata0 : bitmap_colour_read;

    // Setup the address in the bitmap for the pixel being rendered
    // Use pre-fetching of the next pixel ready for the next cycle
    // y_line * 640 + x_pixel
    bitmap.addr0 := y_line * 640 + x_pixel;
    //bitmap.addr0 := { y_line, 7b0 } + { y_line, 9b0 } + x_pixel;

    // RENDER - Default to transparent
    bitmap_display := pix_active && ~bitmap.rdata0[6,1];
    pix_red := bitmap.rdata0[4,2];
    pix_green := bitmap.rdata0[2,2];
    pix_blue := bitmap.rdata0[0,2];

    while(1) {
        switch( bitmap_write_offset ) {
            case 1: {
                x_offset = ( x_offset == 639 ) ? 0 : x_offset + 1;
            }
            case 2: {
                y_offset = ( y_offset == 479 ) ? 0 : y_offset + 1;
            }
            case 3: {
                x_offset = ( x_offset == 0 ) ? 639 : x_offset - 1;
            }
            case 4: {
                y_offset = ( y_offset == 0 ) ? 479 : y_offset - 1;
            }
            case 5: {
                x_offset = 0;
                y_offset = 0;
            }
        }
   }
}

algorithm bitmapwriter (
    // GPU to SET and GET pixels
    input   int11   bitmap_x_write,
    input   int11   bitmap_y_write,
    input   uint7   bitmap_colour_write,
    input   uint7   bitmap_colour_write_alt,
    input   uint1   bitmap_write,
    input   uint4   gpu_active_dithermode,
    input   uint1   static1bit,
    input   uint6   static6bit,
    input   uint10  x_offset,
    input   uint10  y_offset,

    simple_dualport_bram_port1 bitmap
) <autorun> {
    // Pixel x and y for writing ( adjusting for offset )
    uint10  x_write_pixel := ( bitmap_x_write + x_offset ) > 639 ? ( bitmap_x_write + x_offset ) - 640 : ( bitmap_x_write + x_offset );
    uint10  y_write_pixel := ( bitmap_y_write + y_offset ) > 479 ? ( bitmap_y_write + y_offset ) - 480 : ( bitmap_y_write + y_offset );

    // Write in range?
    uint1 write_pixel := (bitmap_x_write >= 0 ) && (bitmap_x_write < 640) && (bitmap_y_write >= 0) && (bitmap_y_write <= 479) && bitmap_write;

    // Bitmap write access for the GPU - Only enable when x and y are in range
    bitmap.wenable1 := 1;

    while(1) {
        if( write_pixel ) {
            // SET PIXEL ADDRESSS y_write_pixel * 640 + x_write_pixel
            bitmap.addr1 = y_write_pixel * 640 + x_write_pixel;
            //bitmap.addr1 = { y_write_pixel, 7b0 } + { y_write_pixel, 9b0 } + x_write_pixel;

            // DITHER PATTERNS
            // == 0 SOLID == 1 SMALL CHECKERBOARD == 2 MED CHECKERBOARD == 3 LARGE CHECKERBOARD == 4 VERTICAL STRIPES == 5 HORIZONTAL STRIPES == 6 CROSSHATCH == 7 LEFT SLOPE
            // == 8 RIGHT SLOPE == 9 LEFT TRIANGLE == 10 RIGHT TRIANGLE == 15 STATIC
            switch( gpu_active_dithermode ) {
                case 0: { bitmap.wdata1 = bitmap_colour_write; }
                case 1: { bitmap.wdata1 = ( bitmap_x_write[0,1] == bitmap_y_write[0,1] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 2: { bitmap.wdata1 = ( bitmap_x_write[1,1] == bitmap_y_write[1,1] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 3: { bitmap.wdata1 = ( bitmap_x_write[2,1] == bitmap_y_write[2,1] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 4: { bitmap.wdata1 = bitmap_x_write[0,1] ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 5: { bitmap.wdata1 = bitmap_y_write[0,1] ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 6: { bitmap.wdata1 = ( bitmap_x_write[0,1] || bitmap_y_write[0,1] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 7: { bitmap.wdata1 = ( bitmap_x_write[0,2] == bitmap_y_write[0,2] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 8: { bitmap.wdata1 = ( bitmap_x_write[0,2] == ~bitmap_y_write[0,2] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                case 9: {
                    switch( bitmap_y_write[0,2] ) {
                        case 2b00: { bitmap.wdata1 = ( bitmap_x_write[0,2] == 2b00 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b01: { bitmap.wdata1 = ( bitmap_x_write[0,2] < 2b10 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b10: { bitmap.wdata1 = ( bitmap_x_write[0,2] != 2b11 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b11: { bitmap.wdata1 = bitmap_colour_write; }
                    }
                }
                case 10: {
                    switch( bitmap_y_write[0,2] ) {
                        case 2b00: { bitmap.wdata1 = ( bitmap_x_write[0,2] == 2b11 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b01: { bitmap.wdata1 = ( bitmap_x_write[0,2] > 2b01 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b10: { bitmap.wdata1 = ( bitmap_x_write[0,2] != 2b00 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b11: { bitmap.wdata1 = bitmap_colour_write; }
                    }
                }
                case 11: {
                    switch( bitmap_y_write[0,2] ) {
                        case 2b01: { bitmap.wdata1 = ( bitmap_x_write[0,1] == bitmap_x_write[1,1] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 2b10: { bitmap.wdata1 = ( bitmap_x_write[0,1] == bitmap_x_write[1,1] ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        default:  { bitmap.wdata1 = bitmap_colour_write; }
                    }
                }
                case 12: {
                    switch( bitmap_y_write[0,2] ) {
                        case 2b00: { bitmap.wdata1 = ( bitmap_x_write[0,1] == bitmap_x_write[1,1] ) ? bitmap_colour_write_alt : bitmap_colour_write; }
                        case 2b11: { bitmap.wdata1 = ( bitmap_x_write[0,1] == bitmap_x_write[1,1] ) ? bitmap_colour_write_alt : bitmap_colour_write; }
                        default: { bitmap.wdata1 = bitmap_colour_write; }
                    }
                }
                case 13: {
                    switch( bitmap_y_write[0,3] ) {
                        case 3b000: { bitmap.wdata1 = bitmap_colour_write; }
                        case 3b001: { bitmap.wdata1 = ( bitmap_x_write[0,2] == 2b00 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 3b010: { bitmap.wdata1 = ( bitmap_x_write[0,2] == 2b00 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 3b011: { bitmap.wdata1 = ( bitmap_x_write[0,2] == 2b00 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 3b100: { bitmap.wdata1 = bitmap_colour_write; }
                        case 3b101: { bitmap.wdata1 = ( bitmap_x_write[0,2] == 2b10 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 3b110: { bitmap.wdata1 = ( bitmap_x_write[0,2] == 2b10 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                        case 3b111: { bitmap.wdata1 = ( bitmap_x_write[0,2] == 2b10 ) ? bitmap_colour_write : bitmap_colour_write_alt; }
                    }
                }
                case 14: { bitmap.wdata1 = static6bit; }
                case 15: { bitmap.wdata1 = ( static1bit ? bitmap_colour_write : bitmap_colour_write_alt ); }
                default: { bitmap.wdata1 = bitmap_colour_write; }
            }
        }
    }
}
