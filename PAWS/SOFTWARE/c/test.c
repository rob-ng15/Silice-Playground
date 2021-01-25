#include "PAWSlibrary.h"

void displayreset( void ) {
    // RESET THE DISPLAY
    terminal_showhide( 0 );
    terminal_reset();
    gpu_cs();
    tpu_cs();
    tilemap_scrollwrapclear( 9 );
    set_background( BLACK, BLACK, BKG_SOLID );
}

// DISPLAY COLOUR CHART
void colourtable( void ) {
    displayreset();
    tpu_outputstringcentre( 29, TRANSPARENT, WHITE, "Colour Test" );

    uint8 colour = 0;
    for( uint16 x = 0; x < 8; x++ ) {
        for( uint16 y = 0; y < 8; y++ ) {
            gpu_rectangle( colour++, x * 80, y * 60, 79 + x * 80, 59 + y * 60 );
        }
    }
}

// DISPLAY THE BACKGROUNDS
void backgrounddemo( void ) {
    displayreset();
    tpu_outputstringcentre( 29, TRANSPARENT, WHITE, "Background Generator Test" );

    for( uint8 bkg = 0; bkg < 16; bkg++ ) {
        set_background( PURPLE, ORANGE, bkg );
        sleep( 1000 );
    }
}

void main( void ) {
    INITIALISEMEMORY();
	while(1) {
        colourtable();
        sleep( 2000 );

        backgrounddemo();
    }
}
