algorithm background(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,

    input   uint16  staticGenerator,

    input uint6 backgroundcolour,
    input uint6 backgroundcolour_alt,
    input uint4 backgroundcolour_mode,
    input uint3 background_write
) <autorun> {
    uint6 background = 0;
    uint6 background_alt = 0;
    uint4 background_mode = 0;

    // Variables for SNOW (from @sylefeb)
    int10   dotpos = 0;
    int2    speed = 0;
    int2    inv_speed = 0;
    int12   rand_x = 0;
    int32   frame = 0;

    while(1) {
        // UPDATE BACKGROUND GENERATOR PARAMETERS
        switch( background_write ) {
            case 1: { background = backgroundcolour; }
            case 2: { background_alt = backgroundcolour_alt; }
            case 3: { background_mode = backgroundcolour_mode; }
        }

        // Increment frame number for the snow/star field
        frame = ( ( pix_x == 639 ) && ( pix_y == 470 ) ) ? frame + 1 : frame;

        // RENDER
        if( pix_active ) {
            switch( background_mode ) {
                case 0: {
                    // SOLID
                    pix_red = colour6(background).red;
                    pix_green = colour6(background).green;
                    pix_blue = colour6(background).blue;
                }
                case 1: {
                    // 50:50 HORIZONTAL SPLIT
                    pix_red = ( pix_y < 240 ) ? colour6(background).red : colour6(background_alt).red;
                    pix_green = ( pix_y < 240 ) ? colour6(background).green : colour6(background_alt).green;
                    pix_blue = ( pix_y < 240 ) ? colour6(background).blue : colour6(background_alt).blue;
                }
                case 2: {
                // 50:50 VERTICAL SPLIT
                    pix_red = ( pix_x < 320 ) ? colour6(background).red : colour6(background_alt).red;
                    pix_green = ( pix_x < 320 ) ? colour6(background).green : colour6(background_alt).green;
                    pix_blue = ( pix_x < 320 ) ? colour6(background).blue : colour6(background_alt).blue;
                }
                case 3: {
                // QUARTERS
                    if( pix_x < 320 ) {
                        pix_red = ( pix_y < 240 ) ? colour6(background).red : colour6(background_alt).red;
                        pix_green = ( pix_y < 240 ) ? colour6(background).green : colour6(background_alt).green;
                        pix_blue = ( pix_y < 240 ) ? colour6(background).blue : colour6(background_alt).blue;
                    } else {
                        pix_red = ( pix_y >= 240 ) ? colour6(background).red : colour6(background_alt).red;
                        pix_green = ( pix_y >= 240 ) ? colour6(background).green : colour6(background_alt).green;
                        pix_blue = ( pix_y >= 240 ) ? colour6(background).blue : colour6(background_alt).blue;
                    }
                }
                case 4: {
                    // 8 colour rainbow
                    switch( pix_y[6,3] ) {
                        case 3b000: { pix_red = 2; pix_green = 0; pix_blue = 0; }
                        case 3b001: { pix_red = 3; pix_green = 0; pix_blue = 0; }
                        case 3b010: { pix_red = 3; pix_green = 2; pix_blue = 0; }
                        case 3b011: { pix_red = 3; pix_green = 3; pix_blue = 0; }
                        case 3b100: { pix_red = 0; pix_green = 3; pix_blue = 0; }
                        case 3b101: { pix_red = 0; pix_green = 0; pix_blue = 3; }
                        case 3b110: { pix_red = 1; pix_green = 0; pix_blue = 2; }
                        case 3b111: { pix_red = 1; pix_green = 2; pix_blue = 3; }
                    }
                }
                case 5: {
                    // SNOW (from @sylefeb)
                    rand_x = ( pix_x == 0)  ? 1 : rand_x * 31421 + 6927;
                    speed  = rand_x[10,2];
                    dotpos = ( frame >> speed ) + rand_x;
                        pix_red   = (pix_y == dotpos) ? colour6(background).red : colour6(background_alt).red;
                        pix_green = (pix_y == dotpos) ? colour6(background).green : colour6(background_alt).green;
                        pix_blue  = (pix_y == dotpos) ? colour6(background).blue : colour6(background_alt).blue;
                }
                case 6: {
                    // STATIC
                    pix_red = staticGenerator;
                    pix_green = staticGenerator;
                    pix_blue = staticGenerator;
                }

                default: {
                    // CHECKERBOARDS
                        switch( { pix_x[background_mode-7,1], pix_y[background_mode-7,1] } ) {
                            case 2b00: {
                                pix_red = colour6(background).red;
                                pix_green = colour6(background).green;
                                pix_blue = colour6(background).blue;
                            }
                            case 2b01: {
                                pix_red = colour6(background_alt).red;
                                pix_green = colour6(background_alt).green;
                                pix_blue = colour6(background_alt).blue;
                            }
                            case 2b10: {
                                pix_red = colour6(background_alt).red;
                                pix_green = colour6(background_alt).green;
                                pix_blue = colour6(background_alt).blue;
                            }
                            case 2b11: {
                                pix_red = colour6(background).red;
                                pix_green = colour6(background).green;
                                pix_blue = colour6(background).blue;
                            }
                        }
                }
            }
        }
    }
}
