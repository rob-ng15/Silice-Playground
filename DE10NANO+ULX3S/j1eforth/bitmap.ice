$$WIDTH = 640
$$HEIGHT = 480
$$SIZE = 307200

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
    input int11 bitmap_x_write,
    input int11 bitmap_y_write,
    input uint7 bitmap_colour_write,
    input uint2 bitmap_write,
    input int16 bitmap_x_read,
    input int16 bitmap_y_read,
    output uint7 bitmap_colour_read,
    
    // BITMAP fade level
    input uint3 bitmapcolour_fade

) <autorun> {
    // 640 x 480 (de10nano) or 320 x 240 (ulx3s) x 10 bit { Arrrgggbbb } colour bitmap
    dualport_bram uint1 bitmap_A[ $SIZE$ ] = uninitialized;
    dualport_bram uint2 bitmap_R[ $SIZE$ ] = uninitialized;
    dualport_bram uint2 bitmap_G[ $SIZE$ ] = uninitialized;
    dualport_bram uint2 bitmap_B[ $SIZE$ ] = uninitialized;

    // Expansion map for { rr } to { rrrrrr }, { gg } to { gggggg }, { bb } to { bbbbbb }
    // or { rr } tp { rrrrrrrr }, { gg } to { gggggggg }, { bb } to { bbbbbbbb }
    uint6 colourexpand2to6[4] = {  0, 21, 42, 63 };
    uint8 colourexpand2to8[4] = {  0, 85, 170, 255 };

    uint3 bitmap_fade = 0;

    // Setup the address in the bitmap for the pixel being rendered
    // ULX3S half the pix_x and pix_y to double the pixels
    bitmap_A.addr0 := pix_x + pix_y * $WIDTH$;
    bitmap_A.wenable0 := 0;
    bitmap_R.addr0 := pix_x + pix_y * $WIDTH$;
    bitmap_R.wenable0 := 0;
    bitmap_G.addr0 := pix_x + pix_y * $WIDTH$;
    bitmap_G.wenable0 := 0;
    bitmap_B.addr0 := pix_x + pix_y * $WIDTH$;
   bitmap_B.wenable0 := 0;
    
    // Bitmap write access for the GPU - Only enable when x and y are in range
    bitmap_A.addr1 := bitmap_x_write + bitmap_y_write * $WIDTH$;
    bitmap_A.wdata1 := colour7(bitmap_colour_write).alpha;
    bitmap_A.wenable1 := 0;
    bitmap_R.addr1 := bitmap_x_write + bitmap_y_write * $WIDTH$;
    bitmap_R.wdata1 := colour7(bitmap_colour_write).red;
    bitmap_R.wenable1 := 0;
    bitmap_G.addr1 := bitmap_x_write + bitmap_y_write * $WIDTH$;
    bitmap_G.wdata1 := colour7(bitmap_colour_write).green;
    bitmap_G.wenable1 := 0;
    bitmap_B.addr1 := bitmap_x_write + bitmap_y_write * $WIDTH$;
    bitmap_B.wdata1 := colour7(bitmap_colour_write).blue;
    bitmap_B.wenable1 := 0;

    // Default to transparent
    bitmap_display := 0;
    
    // Write to the bitmap
    always {
        switch( bitmap_write ) {
            case 1: {
                if( (bitmap_x_write >= 0 ) & (bitmap_x_write < $WIDTH$) & (bitmap_y_write >= 0) & (bitmap_y_write < $HEIGHT$) ) {
                    bitmap_A.wenable1 = 1;
                    bitmap_R.wenable1 = 1;
                    bitmap_G.wenable1 = 1;
                    bitmap_B.wenable1 = 1;
                }
            }
            case 2: {
                bitmap_fade = bitmapcolour_fade;
            }
        }
    }
    
    // Render the bitmap
    while(1) {
        if( ~bitmap_A.rdata0 ) {
            pix_red = colourexpand2to$color_depth$[ bitmap_R.rdata0 ] >> bitmap_fade;
            pix_green = colourexpand2to$color_depth$[ bitmap_G.rdata0 ] >> bitmap_fade;
            pix_blue = colourexpand2to$color_depth$[ bitmap_B.rdata0 ] >> bitmap_fade;
            bitmap_display = 1;
        }
    }
}
