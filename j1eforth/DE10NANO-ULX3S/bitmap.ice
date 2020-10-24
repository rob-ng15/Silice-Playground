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
    input int11 bitmap_x_write,
    input int11 bitmap_y_write,
    input uint7 bitmap_colour_write,
    input uint2 bitmap_write,
    input int16 bitmap_x_read,
    input int16 bitmap_y_read,
    output uint7 bitmap_colour_read
) <autorun> {
    // 640 x 480 x 7 bit { Arrggbb } colour bitmap
    dualport_bram uint7 bitmap[ 307200 ] = uninitialized;

    // Write in range?
    uint1 write_pixel := (bitmap_x_write >= 0 ) && (bitmap_x_write < 640) && (bitmap_y_write >= 0) && (bitmap_y_write < 480) && ( bitmap_write == 1 );
    
    // Pixel being read?
    bitmap_colour_read := ( pix_x == bitmap_x_read ) && ( pix_y == bitmap_y_read ) ? bitmap.rdata0 : bitmap_colour_read;

    // Setup the address in the bitmap for the pixel being rendered
    // Use pre-fetching of the next pixel ready for the next cycle
    bitmap.addr0 := ( pix_active ? pix_x + 1 : 0 ) + ( pix_vblank ? 0 : pix_y * 640 );
    bitmap.wenable0 := 0;
    
    // Bitmap write access for the GPU - Only enable when x and y are in range
    bitmap.addr1 := bitmap_x_write + bitmap_y_write * 640;
    bitmap.wdata1 := bitmap_colour_write;
    bitmap.wenable1 := write_pixel;

    // Default to transparent
    bitmap_display := pix_active && ~colour7(bitmap.rdata0).alpha;

    // Render the bitmap
    while(1) {
        if( bitmap_display ) {
            pix_red = colour7( bitmap.rdata0 ).red;
            pix_green = colour7( bitmap.rdata0).green;
            pix_blue = colour7(bitmap.rdata0).blue;
        }
    }
}
