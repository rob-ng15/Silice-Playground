#include "PAWSlibrary.h"

int main( void ) {
    INITIALISEMEMORY();

    // CODE GOES HERE
    set_background( DKBLUE - 1, BLACK, BKG_SOLID );
    gpu_cs();

    gpu_rectangle( WHITE, 0, 0, 16, 16 );
    gpu_line( WHITE, 0, 32, 64, 64 );

    sleep( 8000, 0 );
}

// EXIT WILL RETURN TO BIOS
