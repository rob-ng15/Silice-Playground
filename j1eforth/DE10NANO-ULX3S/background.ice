algorithm background(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,

    input uint16 staticGenerator,
    
    input uint6 backgroundcolour,
    input uint6 backgroundcolour_alt,
    input uint3 backgroundcolour_mode,
    input uint3 backgroundcolour_fade,
    input uint3 backgroundcolour_write
) <autorun> {
    // Expansion map for { rr } to { rrrrrr }, { gg } to { gggggg }, { bb } to { bbbbbb }
    // or { rr } tp { rrrrrrrr }, { gg } to { gggggggg }, { bb } to { bbbbbbbb }
    uint6 colourexpand2to6[4] = {  0, 21, 42, 63 };
    uint8 colourexpand2to8[4] = {  0, 85, 170, 255 };

    uint6 background = 0;
    uint6 background_alt = 0;
    uint3 background_mode = 0;
    uint3 background_fade = 0;
    
    // Variables for SNOW (from @sylefeb)
    int10   dotpos = 0;
    int2    speed = 0;
    int2    inv_speed = 0;
    int12   rand_x = 0;
    int32   frame = 0;
    
    // Default to black
    pix_red := 0;
    pix_green := 0;
    pix_blue := 0;

    always {
        switch( backgroundcolour_write ) {
            case 1: { background = backgroundcolour; }
            case 2: { background_alt = backgroundcolour_alt; }
            case 3: { background_mode = backgroundcolour_mode; }
            case 4: { background_fade = backgroundcolour_fade; }
            default: {}
        }

        // Increment frame number
        frame = ( ( pix_x == 639 ) && ( pix_y == 470 ) ) ? frame + 1 : frame;
    }
    
    while(1) {
        switch( backgroundcolour_mode ) {
            case 0: {
                // SOLID
                pix_red = colourexpand2to$color_depth$[ colour6(background).red ] >> background_fade;
                pix_green = colourexpand2to$color_depth$[ colour6(background).green ] >> background_fade;
                pix_blue = colourexpand2to$color_depth$[ colour6(background).blue ] >> background_fade;
            }
            case 1: {
                // SMALL checkerboard
                switch( { pix_x[0,1], pix_y[0,1] } ) {
                    case 2b00: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background).blue ] >> background_fade;
                    }
                    case 2b01: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background_alt).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background_alt).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background_alt).blue ] >> background_fade;
                    }
                    case 2b10: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background_alt).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background_alt).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background_alt).blue ] >> background_fade;
                    }
                    case 2b11: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background).blue ] >> background_fade;
                    }
                }
            }
            case 2: {
                // MEDIUM checkerboard
                switch( { pix_x[1,1], pix_y[1,1] } ) {
                    case 2b00: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background).blue ] >> background_fade;
                    }
                    case 2b01: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background_alt).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background_alt).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background_alt).blue ] >> background_fade;
                    }
                    case 2b10: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background_alt).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background_alt).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background_alt).blue ] >> background_fade;
                    }
                    case 2b11: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background).blue ] >> background_fade;
                    }
                }
            }
            case 3: {
                // LARGE checkerboard
                switch( { pix_x[2,1], pix_y[2,1] } ) {
                    case 2b00: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background).blue ] >> background_fade;
                    }
                    case 2b01: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background_alt).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background_alt).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background_alt).blue ] >> background_fade;
                    }
                    case 2b10: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background_alt).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background_alt).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background_alt).blue ] >> background_fade;
                    }
                    case 2b11: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background).blue ] >> background_fade;
                    }
                }
            }
            case 4: {
                // HUGE checkerboard
                switch( { pix_x[3,1], pix_y[3,1] } ) {
                    case 2b00: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background).blue ] >> background_fade;
                    }
                    case 2b01: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background_alt).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background_alt).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background_alt).blue ] >> background_fade;
                    }
                    case 2b10: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background_alt).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background_alt).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background_alt).blue ] >> background_fade;
                    }
                    case 2b11: {
                        pix_red = colourexpand2to$color_depth$[ colour6(background).red ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ colour6(background).green ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ colour6(background).blue ] >> background_fade;
                    }
                }
            }
            case 5: {
                // 8 colour rainbow
                switch( pix_y[6,3] ) {
                    case 3b000: {
                        pix_red = colourexpand2to$color_depth$[ 2 ] >> background_fade;
                        pix_green = 0;
                        pix_blue = 0;
                    }
                    case 3b001: {
                        pix_red = colourexpand2to$color_depth$[ 3 ] >> background_fade;
                        pix_green = 0;
                        pix_blue = 0;
                    }
                    case 3b010: {
                        pix_red = colourexpand2to$color_depth$[ 3 ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ 2 ] >> background_fade;
                        pix_blue = 0;
                    }
                    case 3b011: {
                        pix_red = colourexpand2to$color_depth$[ 3 ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ 3 ] >> background_fade;
                        pix_blue = 0;
                    }
                    case 3b100: {
                        pix_red = 0;
                        pix_green = colourexpand2to$color_depth$[ 3 ] >> background_fade;
                        pix_blue = 0;
                    }
                    case 3b101: {
                        pix_red = 0;
                        pix_green = 0;
                        pix_blue = colourexpand2to$color_depth$[ 3 ] >> background_fade;
                    }
                    case 3b110: {
                        pix_red = colourexpand2to$color_depth$[ 1 ] >> background_fade;
                        pix_green = 0;
                        pix_blue = colourexpand2to$color_depth$[ 2 ] >> background_fade;
                    }
                    case 3b111: {
                        pix_red = colourexpand2to$color_depth$[ 1 ] >> background_fade;
                        pix_green = colourexpand2to$color_depth$[ 2 ] >> background_fade;
                        pix_blue = colourexpand2to$color_depth$[ 3 ] >> background_fade;
                    }
                }
            }
            case 6: {
                // Static
                pix_red = colourexpand2to$color_depth$[ staticGenerator[0,2] ] >> background_fade;
                pix_green = colourexpand2to$color_depth$[ staticGenerator[0,2] ] >> background_fade;
                pix_blue = colourexpand2to$color_depth$[ staticGenerator[0,2] ] >> background_fade;
            }
            case 7: {
                // Snow
                rand_x = (pix_x == 0) ? 1 : rand_x * 31421 + 6927;
                speed  = rand_x[10,2];
                dotpos = (frame >> speed) + rand_x;
                if (pix_y == dotpos) {
                    pix_red   = colourexpand2to$color_depth$[ colour6(background).red ] >> background_fade;
                    pix_green = colourexpand2to$color_depth$[ colour6(background).green ] >> background_fade;
                    pix_blue  = colourexpand2to$color_depth$[ colour6(background).blue ] >> background_fade;
                } else {
                    pix_red   = colourexpand2to$color_depth$[ colour6(background_alt).red ] >> background_fade;
                    pix_green = colourexpand2to$color_depth$[ colour6(background_alt).green ] >> background_fade;
                    pix_blue  = colourexpand2to$color_depth$[ colour6(background_alt).blue ] >> background_fade;
                }
            }                
            default: {}
        }
    }
}
