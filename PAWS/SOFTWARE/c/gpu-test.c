#include "PAWSlibrary.h"

int main( void ) {
    INITIALISEMEMORY();

    // CODE GOES HERE
    set_background( DKBLUE - 1, BLACK, BKG_SOLID );

    unsigned char sectormap = 1;
    for( int i = 0; i < 8; i++ ) {
        gpu_cs();
        gpu_circle( WHITE, 160, 120, 40, sectormap, 1 );
        gpu_printf( WHITE, 16, 16, 2, 0, "%d", i );
        sectormap = sectormap << 1;
        sleep( 2000, 0 );
    }

    for( int i = 0; i < 8; i++ ) {
        gpu_cs();
        gpu_character_blit( WHITE, 160, 120, 64, 3, i );
        gpu_printf( WHITE, 16, 16, 2, 0, "%d", i );
        sleep( 2000, 0 );
    }
}

// EXIT WILL RETURN TO BIOS
