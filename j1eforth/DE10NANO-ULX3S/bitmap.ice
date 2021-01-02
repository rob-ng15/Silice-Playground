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

    simple_dualbram_port0 bitmap
) <autorun> {
    // Pixel x and y fetching ( adjusting for offset )
    uint10  x_plus_one := ( pix_x + x_offset + 1 ) > 639 ? ( pix_x + x_offset + 1 ) - 639 : ( pix_x + x_offset + 1 );
    uint10  y_line := pix_vblank ? y_offset : ( ( pix_y + y_offset ) > 479 ? ( pix_y + y_offset ) - 479 : ( pix_y + y_offset ) );
    uint10  x_pixel := pix_active ? x_plus_one : x_offset;

    // Pixel being read?
    bitmap_colour_read := ( pix_x == bitmap_x_read ) && ( pix_y == bitmap_y_read ) ? bitmap.rdata0 : bitmap_colour_read;

    // Setup the address in the bitmap for the pixel being rendered
    // Use pre-fetching of the next pixel ready for the next cycle
    bitmap.addr0 := x_pixel + ( y_line * 640 );

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
    input   uint1   bitmap_write,

    input   uint10  x_offset,
    input   uint10  y_offset,

    simple_dualbram_port1 bitmap
) <autorun> {
    // Pixel x and y for writing ( adjusting for offset )
    uint10  x_write_pixel := ( bitmap_x_write + x_offset ) > 639 ? ( bitmap_x_write + x_offset ) - 639 : ( bitmap_x_write + x_offset );
    uint10  y_write_pixel := ( bitmap_y_write + y_offset ) > 479 ? ( bitmap_y_write + y_offset ) - 479 : ( bitmap_y_write + y_offset );

    // Write in range?
    uint1 write_pixel := (bitmap_x_write >= 0 ) && (bitmap_x_write < 640) && (bitmap_y_write >= 0) && (bitmap_y_write <= 479) && bitmap_write;

    // Bitmap write access for the GPU - Only enable when x and y are in range
    bitmap.wenable1 := 1;

    while(1) {
        if( write_pixel == 1 ) {
            bitmap.addr1 = x_write_pixel + y_write_pixel * 640;
            bitmap.wdata1 = bitmap_colour_write;
        }
    }
}
