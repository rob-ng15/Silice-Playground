algorithm bitmap(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,
    output! uint1   bitmap_display,

    // GPU to SET and GET pixels
    input   int11   bitmap_x_write,
    input   int11   bitmap_y_write,
    input   uint7   bitmap_colour_write,
    input   uint1   bitmap_write,

    // Hardware scrolling
    input   uint3   bitmap_write_offset,

    // Pixel reader
    input   int16   bitmap_x_read,
    input   int16   bitmap_y_read,
    output  uint7   bitmap_colour_read
) <autorun> {
    // 640 x 480 x 7 bit { Arrggbb } colour bitmap
    dualport_bram uint7 bitmap[ 307200 ] = uninitialized;

    // Offset from ( 0, 0 ) to start drawing
    uint10  x_offset = 0;
    uint10  y_offset = 0;

    // Pixel x and y fetching ( adjusting for offset )
    uint10  x_plus_one := ( pix_x + x_offset + 1 ) > 639 ? ( pix_x + x_offset + 1 ) - 639 : ( pix_x + x_offset + 1 );
    uint10  y_line := pix_vblank ? y_offset : ( ( pix_y + y_offset ) > 479 ? ( pix_y + y_offset ) - 479 : ( pix_y + y_offset ) );
    uint10  x_pixel := pix_active ? x_plus_one : x_offset;

    // Pixel x and y for writing ( adjusting for offset )
    uint10  x_write_pixel := ( bitmap_x_write + x_offset ) > 639 ? ( bitmap_x_write + x_offset ) - 639 : ( bitmap_x_write + x_offset );
    uint10  y_write_pixel := ( bitmap_y_write + y_offset ) > 479 ? ( bitmap_y_write + y_offset ) - 479 : ( bitmap_y_write + y_offset );

    // Write in range?
    uint1 write_pixel := (bitmap_x_write >= 0 ) && (bitmap_x_write < 640) && (bitmap_y_write >= 0) && (bitmap_y_write <= 479) && bitmap_write;

    // Pixel being read?
    bitmap_colour_read := ( pix_x == bitmap_x_read ) && ( pix_y == bitmap_y_read ) ? bitmap.rdata0 : bitmap_colour_read;

    // Setup the address in the bitmap for the pixel being rendered
    // Use pre-fetching of the next pixel ready for the next cycle
    bitmap.addr0 := x_pixel + ( y_line * 640 );
    bitmap.wenable0 := 0;

    // Bitmap write access for the GPU - Only enable when x and y are in range
    bitmap.wenable1 := 1;

    // Default to transparent
    bitmap_display := pix_active && ~colour7(bitmap.rdata0).alpha;

    always {
        if( bitmap_display ) {
            pix_red = colour7(bitmap.rdata0).red;
            pix_green = colour7(bitmap.rdata0).green;
            pix_blue = colour7(bitmap.rdata0).blue;
        }
    }

    // Render the bitmap
    while(1) {
        if( write_pixel == 1 ) {
            bitmap.addr1 = x_write_pixel + y_write_pixel * 640;
            bitmap.wdata1 = bitmap_colour_write;
        }

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
