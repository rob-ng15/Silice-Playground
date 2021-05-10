#include "PAWSlibrary.h"

// STORAGE FOR COLOUR BLITTER
unsigned char colour_blitter_bitmap[ 256 * 8 ];

int main( void ) {
    short colour = 0, i;
    INITIALISEMEMORY();

    for( i = 0; i < 256 * 8; i++ ) {
        colour_blitter_bitmap[i] = colour;
        colour = ( colour == 64 ) ? 0 : colour + 1;
    }
    for( i = 0; i < 8; i++ )
        set_colourblitter_bitmap( i, &colour_blitter_bitmap[ 256 * i ] );

    while(1) {
        gpu_cs();
        tpu_printf_centre( 29, TRANSPARENT, WHITE, "GPU Colour Blitter Test" );
        for( i = 0; i < 8; i++ ) {
            gpu_colourblit( rng( 320 ), rng( 240 ), i, rng( 4 ) );

        }
        sleep( 1000, 0 );
    }
}
