#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>

// INCLUDE 3D PACMAN BACKDROP
#include "3DPACMAN.h"
unsigned char *pacman3dbitmap;

// INCLUDE GALAXY BACKDROP
#include "GALAXYPPM.h"
unsigned char *galaxybitmap;

void main( void ) {
    int x, y, count, location;

    INITIALISEMEMORY();
    set_background( 0, 0, BKG_RAINBOW );

    // DECODE 3D PACMAN TO BITMAP
    tpu_print_centre(  1, TRANSPARENT, WHITE, "Decoding PACMAN3D.PPM" );
    pacman3dbitmap = malloc( 320 * 240 );
    netppm_decoder( &pacman3dppm[0], pacman3dbitmap );
    tpu_print_centre(  1, TRANSPARENT, WHITE, "Outputing PACMAN3D bitmap" );

    printf( "unsigned char pacman3d_bitmap[] = {\n" );
    count = 0; location = 0;
    for( y = 0; y < 240; y++ ) {
        for( x = 0; x < 320; x++ ) {
            switch( count ) {
                case 16:
                    printf( "\n" );
                    count = 0;
                    break;
            }
            printf( "0x%x,", pacman3dbitmap[ location++ ] );
            count++;
        }
    }
    printf( "\n};\n" );

    // DECODE GALAXY TO BITMAP
    tpu_print_centre(  1, TRANSPARENT, WHITE, "Decoding GALAXY.PPM" );
    galaxybitmap = malloc( 320 * 240 );
    netppm_decoder( &galaxyppm[0], galaxybitmap );
    tpu_print_centre(  1, TRANSPARENT, WHITE, "Outputing GALAXY bitmap" );

    printf( "unsigned char galaxy_bitmap[] = {\n" );
    count = 0; location = 0;
    for( y = 0; y < 240; y++ ) {
        for( x = 0; x < 320; x++ ) {
            switch( count ) {
                case 16:
                    printf( "\n" );
                    count = 0;
                    break;
            }
            printf( "0x%x,", galaxybitmap[ location++ ] );
            count++;
        }
    }
    printf( "\n};\n" );

    tpu_print_centre(  1, TRANSPARENT, WHITE, "FINISHED" );

    sleep( 4000, 0 );
}
