algorithm background(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,

    input uint9 backgroundcolour,
    input uint1 backgroundcolour_write
) <autorun> {
    // Expansion map for { rrr } to { rrrrrr }, { ggg } to { gggggg }, { bbb } to { bbbbbb }
    uint6 colourexpand3to6[8] = {  0, 9, 18, 27, 36, 45, 54, 63 };

    uint9 background = 0;
    
    always {
        if( backgroundcolour_write ) {
            background = backgroundcolour;
        }
    }
    
    while(1) {
        pix_red = colourexpand3to6[ colour9(background).red ];
        pix_green = colourexpand3to6[ colour9(background).green ];
        pix_blue = colourexpand3to6[ colour9(background).blue ];
    }
}
