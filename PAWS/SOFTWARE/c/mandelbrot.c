#include "PAWSlibrary.h"
#include <stdio.h>

// TRANSLATION OF http://www.rosettacode.org/wiki/Mandelbrot_set#BASIC256 to C and PAWSlibrary

int main( void ) {
    INITIALISEMEMORY();

    const int graphwidth = 320, graphheight = 240;
    float kt = 255, m = 4.0;
    float xmin = -2.1, xmax = 0.6, ymin = -1.35, ymax = 1.35;
    float dx = (xmax - xmin) / graphwidth, dy = (ymax - ymin) / graphheight;
    float jx, jy, tx, ty, wx, wy, r;
    int k;

    for( int x = 0; x < graphwidth; x++ ) {
        jx = xmin + x * dx;
        for( int y = 0; y < graphheight; y++ ) {
            //tpu_printf_centre( 0, TRANSPARENT, WHITE, "( %3d, %3d )", x, y );
            jy = ymin + y * dy;
            k = 0; wx = 0.0; wy = 0.0;
            do {
                tx = wx * wx - wy * wy + jx;
                ty = 2.0 * wx * wy + jy;
                wx = tx;
                wy = ty;
                r = wx * wx + wy * wy;
                k = k + 1;
            } while( ( r < m ) && ( k < kt ) );

            gpu_pixel( ( k > kt ) ? BLACK : ( k >> 2 ) + 1, x, y );
        }
    }

    while(1) {}
}
