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
) <autorun> {
    // Variables for SNOW (from @sylefeb)
    int10   dotpos = 0;
    int2    speed = 0;
    int2    inv_speed = 0;
    int12   rand_x = 0;
    int32   frame = 0;

    uint1   tophalf := pix_y < 240;
    uint1   lefthalf := pix_x < 320;

    while(1) {
        // Increment frame number for the snow/star field
        frame = ( ( pix_x == 639 ) && ( pix_y == 470 ) ) ? frame + 1 : frame;

        // RENDER
        if( pix_active ) {
            switch( backgroundcolour_mode ) {
                case 0: {
                    // SOLID
                    pix_red = colour6(backgroundcolour).red;
                    pix_green = colour6(backgroundcolour).green;
                    pix_blue = colour6(backgroundcolour).blue;
                }
                case 1: {
                    // 50:50 HORIZONTAL SPLIT
                    pix_red = ( tophalf ) ? colour6(backgroundcolour).red : colour6(backgroundcolour_alt).red;
                    pix_green = ( tophalf ) ? colour6(backgroundcolour).green : colour6(backgroundcolour_alt).green;
                    pix_blue = ( tophalf ) ? colour6(backgroundcolour).blue : colour6(backgroundcolour_alt).blue;
                }
                case 2: {
                // 50:50 VERTICAL SPLIT
                    pix_red = ( lefthalf ) ? colour6(backgroundcolour).red : colour6(backgroundcolour_alt).red;
                    pix_green = ( lefthalf ) ? colour6(backgroundcolour).green : colour6(backgroundcolour_alt).green;
                    pix_blue = ( lefthalf ) ? colour6(backgroundcolour).blue : colour6(backgroundcolour_alt).blue;
                }
                case 3: {
                // QUARTERS
                    pix_red = ( lefthalf == tophalf ) ? colour6(backgroundcolour).red : colour6(backgroundcolour_alt).red;
                    pix_green = ( lefthalf == tophalf ) ? colour6(backgroundcolour).green : colour6(backgroundcolour_alt).green;
                    pix_blue = ( lefthalf == tophalf ) ? colour6(backgroundcolour).blue : colour6(backgroundcolour_alt).blue;
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
                        pix_red   = (pix_y == dotpos) ? colour6(backgroundcolour).red : colour6(backgroundcolour_alt).red;
                        pix_green = (pix_y == dotpos) ? colour6(backgroundcolour).green : colour6(backgroundcolour_alt).green;
                        pix_blue  = (pix_y == dotpos) ? colour6(backgroundcolour).blue : colour6(backgroundcolour_alt).blue;
                }
                case 6: {
                    // STATIC
                    pix_red = staticGenerator;
                    pix_green = staticGenerator;
                    pix_blue = staticGenerator;
                }

                default: {
                    // CHECKERBOARDS
                    pix_red = ( pix_x[backgroundcolour_mode-7,1] == pix_y[backgroundcolour_mode-7,1] ) ? colour6(backgroundcolour).red : colour6(backgroundcolour_alt).red;
                    pix_green = ( pix_x[backgroundcolour_mode-7,1] == pix_y[backgroundcolour_mode-7,1] ) ? colour6(backgroundcolour).green : colour6(backgroundcolour_alt).green;
                    pix_blue = ( pix_x[backgroundcolour_mode-7,1] == pix_y[backgroundcolour_mode-7,1] ) ? colour6(backgroundcolour).blue : colour6(backgroundcolour_alt).blue;
                }
            }
        }
    }
}
