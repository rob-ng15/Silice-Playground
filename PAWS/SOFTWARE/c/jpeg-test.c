#include "PAWSlibrary.h"
#include "GALAXYJPG.h"
#include <stdio.h>

int main( void ) {
    INITIALISEMEMORY();

    int width, height,counter;
    unsigned char *imagebuffer, colour;

    // JPEG LIBRARY
    njInit();
    njDecode( &galaxyjpg[0], 71555 );
    width = njGetWidth();
    height = njGetHeight();
    imagebuffer=njGetImage();

    printf("JPEG: width <%d> height <%d>\n", width, height );

    counter = 0;
    for( short y = 0; y < height; y++ ) {
        for( short x = 0; x < width; x++ ) {
            colour = ( imagebuffer[ counter++ ] & 0xc0 ) >> 2;
            colour = colour + ( ( imagebuffer[ counter++ ] & 0xc0 ) >> 4 );
            colour = colour + ( ( imagebuffer[ counter++ ] & 0xc0 ) >> 6 );
            gpu_pixel( colour, x, y );
        }
    }

    while(1) {
    }
}
