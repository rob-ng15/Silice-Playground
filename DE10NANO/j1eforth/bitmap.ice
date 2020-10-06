algorithm bitmap(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,
    output! uint1   bitmap_display,
    
    // GPU to SET and GET pixels
    input int16 bitmap_x_write,
    input int16 bitmap_y_write,
    input uint10 bitmap_colour_write,
    input uint1 bitmap_write,
    input int16 bitmap_x_read,
    input int16 bitmap_y_read,
    output uint10 bitmap_colour_read
) <autorun> {
    // 640 x 480 x 10 bit { Arrrgggbbb } colour bitmap
    dualport_bram uint10 bitmap[ 307200 ] = uninitialized;  // { Arrrgggbbb }

    // Expansion map for { rrr } to { rrrrrr }, { ggg } to { gggggg }, { bbb } to { bbbbbb }
    uint6 colourexpand3to6[8] = {  0, 9, 18, 27, 36, 45, 54, 63 };

    // Setup the address in the bitmap for the pixel being rendered
    bitmap.addr0 := pix_x + pix_y * 640;
    bitmap.wenable0 := 0;
    
    // Bitmap write access for the GPU - Only enable when x and y are in range
    bitmap.addr1 := bitmap_x_write + bitmap_y_write * 640;
    bitmap.wdata1 := bitmap_colour_write;
    bitmap.wenable1 := 0;

    // Write to the bitmap
    always {
        if( bitmap_write ) {
            if( (bitmap_x_write >= 0 ) & (bitmap_x_write < 640) & (bitmap_y_write >= 0) & (bitmap_y_write < 480) ) {
                bitmap.wenable1 = 1;
            }
        }
    }
    
    // Render the bitmap
    while(1) {
        if( ~colour10(bitmap.rdata0).alpha ) {
            pix_red = colourexpand3to6[ colour10(bitmap.rdata0).red ];
            pix_green = colourexpand3to6[ colour10(bitmap.rdata0).green ];
            pix_blue = colourexpand3to6[ colour10(bitmap.rdata0).blue ];
            bitmap_display = 1;
        } else {
            bitmap_display = 0;
        }
    }
}
