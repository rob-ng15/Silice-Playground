algorithm background(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,

    input uint9 backgroundcolour,
    input uint9 backgroundcolour_alt,
    input uint3 backgroundcolour_mode,
    input uint3 backgroundcolour_fade,
    input uint3 backgroundcolour_write
) <autorun> {
    // Expansion map for { rrr } to { rrrrrr }, { ggg } to { gggggg }, { bbb } to { bbbbbb }
    // or { rrr } tp { rrrrrrrr }, { ggg } to { gggggggg }, { bbb } to { bbbbbbbb }
    uint6 colourexpand3to6[8] = {  0, 9, 18, 27, 36, 45, 54, 255 };
    uint6 colourexpand3to8[8] = {  0, 36, 73, 109, 145, 182, 218, 255 };

    uint9 background = 0;
    uint9 background_alt = 0;
    uint9 background_mode = 0;
    uint3 background_fade = 0;
    
    always {
        switch( backgroundcolour_write ) {
            case 1: {
                background = backgroundcolour;
            }
            case 2: {
                background_alt = backgroundcolour_alt;
            }
            case 3: {
                background_mode = backgroundcolour_mode;
            }
            case 4: {
                background_fade = backgroundcolour_fade;
            }
            default: {}
        }
    }
    
    while(1) {
        switch( backgroundcolour_mode ) {
            case 0: {
                pix_red = colourexpand3to$color_depth$[ colour9(background).red ] >> background_fade;
                pix_green = colourexpand3to$color_depth$[ colour9(background).green ] >> background_fade;
                pix_blue = colourexpand3to$color_depth$[ colour9(background).blue ] >> background_fade;
            }
            default: {
                pix_red = 0;
                pix_green = 0;
                pix_blue = 0;
            }
        }
    }
}
