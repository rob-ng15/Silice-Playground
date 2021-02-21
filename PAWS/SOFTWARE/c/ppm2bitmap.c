#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>

// INCLUDE TOMBSTONE IMAGE
#include "TOMBSTONEPPM.h"
unsigned char *tombstonebitmap;

// INCLUDE CONTROLS IMAGE
#include "ULX3SPPM.h"
unsigned char *ulx3sbitmap;

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

    // DECODE TOMBSTONE PPM TO BITMAP
    tpu_printf_centre(  1, TRANSPARENT, WHITE, "Decoding TOMBSTONE.PPM" );
    tombstonebitmap = malloc( 320 * 298 );
    netppm_decoder( &tombstoneppm[0], tombstonebitmap );
    tpu_printf_centre(  1, TRANSPARENT, WHITE, "Outputing TOMBSTONE bitmap" );

    printf( "unsigned char tombstone_bitmap[] = {\n" );
    count = 0; location = 0;
    for( y = 0; y < 298; y++ ) {
        for( x = 0; x < 320; x++ ) {
            switch( count ) {
                case 16:
                    printf( "\n" );
                    count = 0;
                    break;
            }
            printf( "0x%x,", tombstonebitmap[ location++ ] );
            count++;
        }
    }
    printf( "\n};\n" );

    // DECODE CONTROLS PPM TO BITMAP
    tpu_printf_centre(  1, TRANSPARENT, WHITE, "Decoding ULX3S.PPM" );
    ulx3sbitmap = malloc( 320 * 219 );
    netppm_decoder( &ulx3sppm[0], ulx3sbitmap );
    tpu_printf_centre(  1, TRANSPARENT, WHITE, "Outputing ULX3S bitmap" );

    printf( "unsigned char ulx3s_bitmap[] = {\n" );
    count = 0; location = 0;
    for( y = 0; y < 219; y++ ) {
        for( x = 0; x < 320; x++ ) {
            switch( count ) {
                case 16:
                    printf( "\n" );
                    count = 0;
                    break;
            }
            printf( "0x%x,", ulx3sbitmap[ location++ ] );
            count++;
        }
    }
    printf( "\n};\n" );

    // DECODE 3D PACMAN TO BITMAP
    tpu_printf_centre(  1, TRANSPARENT, WHITE, "Decoding PACMAN3D.PPM" );
    pacman3dbitmap = malloc( 640 * 480 );
    netppm_decoder( &pacman3dppm[0], pacman3dbitmap );
    tpu_printf_centre(  1, TRANSPARENT, WHITE, "Outputing PACMAN3D bitmap" );

    printf( "unsigned char pacman3d_bitmap[] = {\n" );
    count = 0; location = 0;
    for( y = 0; y < 480; y++ ) {
        for( x = 0; x < 640; x++ ) {
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
    tpu_printf_centre(  1, TRANSPARENT, WHITE, "Decoding GALAXY.PPM" );
    galaxybitmap = malloc( 640 * 480 );
    netppm_decoder( &galaxyppm[0], galaxybitmap );
    tpu_printf_centre(  1, TRANSPARENT, WHITE, "Outputing GALAXY bitmap" );

    printf( "unsigned char galaxy_bitmap[] = {\n" );
    count = 0; location = 0;
    for( y = 0; y < 480; y++ ) {
        for( x = 0; x < 640; x++ ) {
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

    tpu_printf_centre(  1, TRANSPARENT, WHITE, "FINISHED" );

    while(1) {
    }
}
