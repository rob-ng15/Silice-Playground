#include "PAWSlibrary.h"
#include <stdlib.h>

int main( void ) {
    INITIALISEMEMORY();

    int width, height; unsigned int filesize;
    unsigned char *imagebuffer, colour, *filebuffer;

    filebuffer = sdcard_selectfile( "Please select a JPEG", "JPG", &filesize );

    // JPEG LIBRARY
    if( filebuffer ) {
        njInit();
        njDecode( filebuffer, filesize );
        width = njGetWidth();
        height = njGetHeight();
        imagebuffer=njGetImage();
        gpu_pixelblock24( 0, 0, width, height, imagebuffer );
        free( filebuffer );
    } else {
        gpu_print_centre( WHITE, 160, 120, BOLD, 0, 0, "NO FILE FOUND!" );
    }

    sleep( 4000, 0 );
}
