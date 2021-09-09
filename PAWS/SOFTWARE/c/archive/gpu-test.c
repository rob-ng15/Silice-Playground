#include "PAWSlibrary.h"

int main( void ) {
    INITIALISEMEMORY();

    // CODE GOES HERE
    set_background( VDKBLUE, BLACK, BKG_SOLID );

    gpu_crop( 0, 0, 100, 100 );
    for( int i = 0; i < 32; i++ ) {
        gpu_rectangle( rng(64), rng(320), rng(240), rng(320), rng(240) );
    }

    sleep( 4000, 0 );
}

// EXIT WILL RETURN TO BIOS
