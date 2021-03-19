#include "PAWSlibrary.h"
#include "GALAXYJPG.h"
#include <stdio.h>

int main( void ) {
    INITIALISEMEMORY();

    int width, height,counter;
    unsigned char *imagebuffer, colour;

    printf( "JPEG DECODER:\n" );
    tpu_printf_centre( 0, TRANSPARENT, WHITE, "DECODING JPEG" );

    // JPEG LIBRARY
    njInit(); printf( "    njInit()\n");
    njDecode( &galaxyjpg[0], 71555 ); printf( "    njDecode()\n" );
    width = njGetWidth();
    height = njGetHeight(); printf( "    Image %u x %u()\n", width, height );
    imagebuffer=njGetImage(); printf( "    Buffer %u\n", (unsigned int)imagebuffer );

    tpu_printf_centre( 0, TRANSPARENT, WHITE, "DISPLAYING JPEG %d x %d", width, height );

    counter = 0;
    for( short y = 0; y < height; y++ ) {
        for( short x = 0; x < width; x++ ) {
            colour = ( imagebuffer[ counter++ ] & 0xc0 ) >> 2;
            colour = colour + ( ( imagebuffer[ counter++ ] & 0xc0 ) >> 4 );
            colour = colour + ( ( imagebuffer[ counter++ ] & 0xc0 ) >> 6 );
            gpu_pixel( colour, x, 239 );
        }
        bitmap_scrollwrap( 2 );
    }

    tpu_printf_centre( 0, TRANSPARENT, WHITE, "" );
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "FINISHED" );

    while(1) {
    }
}
