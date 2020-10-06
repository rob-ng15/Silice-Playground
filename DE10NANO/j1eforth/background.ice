algorithm background(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,

    input uint9 backgroundcolour
) <autorun> {
    // Expansion map for { rrr } to { rrrrrr }, { ggg } to { gggggg }, { bbb } to { bbbbbb }
    uint6 colourexpand3to6[8] = {  0, 9, 18, 27, 36, 45, 54, 63 };

    pix_red = colourexpand3to6[ colour9(backgroundcolour).red ];
    pix_green = colourexpand3to6[ colour9(backgroundcolour).green ];
    pix_blue = colourexpand3to6[ colour9(backgroundcolour).blue ];
}
