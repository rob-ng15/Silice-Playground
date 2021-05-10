#include "PAWSlibrary.h"

// STORAGE FOR COLOUR BLITTER
unsigned char colour_blitter_strings[][16] = {

    "....C.C.........",
    "....C.C.........",
    "C..CCCCC..C.....",
    "CCCCYCYCCCC.....",
    "...CCCCC........",
    ".BBBCCCBBB......",
    "BBB.CCC.BBB.....",
    "BB...C...BB.....",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",

    "....C.C.........",
    "C...C.C...C.....",
    "CCCCCCCCCCC.....",
    "...CYCYC........",
    "BBBCCCCCBBB.....",
    "BB.CCCCC.BB.....",
    "B...CCC...B.....",
    ".....C..........",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",

    "C...C.C...C.....",
    "C..CCCCC..C.....",
    ".CCCYCYCCC......",
    "B..CCCCC..B.....",
    "BBBBCCCBBBB.....",
    ".BB.CCC.BB......",
    ".....C..........",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................"
};

unsigned char colour_blitter_bitmap[ 256 ];

int main( void ) {
    unsigned char colour = 0, i;
    INITIALISEMEMORY();

    // SET COLOUR BLITTER OBJECTS - ALIENS FROM GALAXIAN
    for( short i = 0; i < 3; i++ ) {
        for( short j = 0; j < 3; j++ ) {
            for( short y = 0; y < 16; y++ ) {
                for( short x = 0; x < 16; x++ ) {
                    switch( colour_blitter_strings[ j * 16 + y ][x] ) {
                        case '.':
                            colour = TRANSPARENT;
                            break;
                        case 'B':
                            colour = DKBLUE;
                            break;
                        case 'C':
                            switch( i ) {
                                case 0:
                                    colour = RED;
                                    break;
                                case 1:
                                    colour = DKMAGENTA;
                                    break;
                                case 2:
                                    colour = DKCYAN - 1;
                                    break;
                            }
                            break;
                        case 'Y':
                            colour = YELLOW;
                            break;
                    }
                    colour_blitter_bitmap[ y * 16 + x ] = colour;
                }
            }
            set_colourblitter_bitmap( i * 3 + j, &colour_blitter_bitmap[ 0 ] );
        }
    }

    while(1) {
        gpu_cs();
        tpu_printf_centre( 29, TRANSPARENT, WHITE, "GPU Colour Blitter Test" );
        for( i = 0; i < 9; i++ ) {
            gpu_colourblit( rng( 320 ), rng( 240 ), i, rng( 4 ) );

        }
        sleep( 1000, 0 );
    }
}
