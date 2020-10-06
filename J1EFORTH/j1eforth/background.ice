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
    // or { rrr } tp { rrrrrrrr }, { ggg } to { gggggggg }, { bbb } to { bbbbbbbb }
    uint6 colourexpand3to6[8] = {  0, 9, 18, 27, 36, 45, 54, 255 };
    uint6 colourexpand3to8[8] = {  0, 36, 73, 109, 145, 182, 218, 255 };

    uint9 background = 0;
    
    always {
        if( backgroundcolour_write ) {
            background = backgroundcolour;
        }
    }
    
    while(1) {
        pix_red = colourexpand3to$color_depth$[ colour9(background).red ];
        pix_green = colourexpand3to$color_depth$[ colour9(background).green ];
        pix_blue = colourexpand3to$color_depth$[ colour9(background).blue ];
    }
}
