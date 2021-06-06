#include "PAWSlibrary.h"
#include "PAWSJPG.h"
#include <stdio.h>

int main( void ) {
    INITIALISEMEMORY();

    int width, height,counter;
    unsigned char *imagebuffer, colour;

    printf( "JPEG DECODER:\n" );
    tpu_printf_centre( 0, TRANSPARENT, WHITE, "DECODING JPEG" );

    // JPEG LIBRARY
    njInit(); printf( "    njInit()\n");
    njDecode( &pawsjpg[0], 71555 ); printf( "    njDecode()\n" );
    width = njGetWidth();
    height = njGetHeight(); printf( "    Image %u x %u()\n", width, height );
    imagebuffer=njGetImage(); printf( "    Buffer %u\n", (unsigned int)imagebuffer );

    tpu_printf_centre( 0, TRANSPARENT, WHITE, "DISPLAYING JPEG %d x %d", width, height );

    counter = 0;
    gpu_pixelblock24( 0, 0, width, height, imagebuffer );

    tpu_printf_centre( 0, TRANSPARENT, WHITE, "" );
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "FINISHED" );

    while(1) {
    }
}
