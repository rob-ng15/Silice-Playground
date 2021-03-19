#include <stdlib.h>
#include <stdio.h>

// INCLUDE 3D PACMAN BACKDROP
#include "3DPACMAN.h"
unsigned char *pacman3dbitmap;

// INCLUDE GALAXY BACKDROP
#include "GALAXYPPM.h"
unsigned char *galaxybitmap;

// NETPBM DECODER
unsigned int skipcomment( unsigned char *netppmimagefile, unsigned int location ) {
    while( netppmimagefile[ location ] != 0x0a )
        location++;
    location++;
    return( location );
}

// DECODE NETPPM FILE TO ARRAY
void netppm_decoder( unsigned char *netppmimagefile, unsigned char *buffer ) {
    unsigned int location = 3, bufferpos = 0;
    unsigned short width = 0, height = 0, depth = 0;
    unsigned char colour;

    // CHECK HEADER
    if( ( netppmimagefile[0] == 0x50 ) && ( netppmimagefile[1] == 0x36 ) && ( netppmimagefile[2] == 0x0a ) ) {
        // VALID HEADER

        // SKIP COMMENT
        while( netppmimagefile[ location ] == 0x23 ) {
            location = skipcomment( netppmimagefile, location );
        }

        // READ WIDTH
        while( netppmimagefile[ location ] != 0x20 ) {
            width = width * 10 + netppmimagefile[ location ] - 0x30;
            location++;
        }
        location++;

        // READ HEIGHT
        while( netppmimagefile[ location ] != 0x0a ) {
            height = height * 10 + netppmimagefile[ location ] - 0x30;
            location++;
        }
        location++;

        // READ DEPTH
        while( netppmimagefile[ location ] != 0x0a ) {
            depth = depth * 10 + netppmimagefile[ location ] - 0x30;
            location++;
        }
        location++;

        // 24 bit image
        if( depth == 255 ) {
            for( unsigned short y = 0; y < height; y++ ) {
                for( unsigned short x = 0; x < width; x++ ) {
                    colour = ( netppmimagefile[ location++ ] & 0xc0 ) >> 2;
                    colour = colour + ( ( netppmimagefile[ location++ ] & 0xc0 ) >> 4 );
                    colour = colour + ( ( netppmimagefile[ location++ ] & 0xc0 ) >> 6 );
                    buffer[ bufferpos++ ] = colour;
                }
            }
        }
    }
}

void main( void ) {
    int x, y, count, location;

    // DECODE 3D PACMAN TO BITMAP
    pacman3dbitmap = malloc( 320 * 240 );
    netppm_decoder( &pacman3dppm[0], pacman3dbitmap );

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
    galaxybitmap = malloc( 320 * 240 );
    netppm_decoder( &galaxyppm[0], galaxybitmap );

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
}
