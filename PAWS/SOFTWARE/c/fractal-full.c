#include "PAWSlibrary.h"
#include <stdint.h>
#include <stdio.h>

// NORMAL IS 1023 AND 4, FAST IS 63 AND 0
#define MAXITER 1024
#define ITERSHIFT 4

int main( void ) {
    INITIALISEMEMORY();

    /* Maximum number of iterations, at most 65535. */
    const unsigned short maxiter = MAXITER;

    /* Image size */
    const short xres = 320;
    const short yres = 240;

    /* The window in the plane. */
    const float xmin = 0.27085;
    const float xmax = 0.27100;
    const float ymin = 0.004640;
    const float ymax = 0.004810;

    /* Precompute pixel width and height. */
    const float dx=(xmax-xmin)/xres;
    const float dy=(ymax-ymin)/yres;

    float x, y; /* Coordinates of the current point in the complex plane. */
    float u, v; /* Coordinates of the iterated point. */
    float u2, v2;
    float jdy, idx;

    short i,j; /* Pixel counters */
    short k; /* Iteration counter */
    short ysize = yres, xsize = xres, ypixel, xpixel, z;

    for( z = 0; z < 6; z++ ) {
        ysize = ysize >> 1; ypixel = ysize >> 1;
        xsize = xsize >> 1; xpixel = xsize >> 1;
        for(j = ysize; j < yres; j += ysize ) {
            jdy = j*dy;
            y = ymax - jdy;
            for(i = xsize; i < xres; i += xsize ) {
                u = 0.0;
                v = 0.0;
                u2 = u * u;
                v2 = v*v;
                idx = i*dx;
                x = xmin + idx;
                //printf( "Iteration %d at ( %d, %d ) with x = %f, y = %f, dx = %f, dy = %f\n", z, i, j, x, y, dx, dy );
                /* iterate the point */
                for (k = 1; k < maxiter && (u2 + v2 < 4.0); k++) {
                        v = 2 * u * v + y;
                        u = u2 - v2 + x;
                        u2 = u * u;
                        v2 = v * v;
                        //printf( "  k = %d with u = %f, v = %f, u2 = %f, v2 = %f, u2 + v2 = %f\n", k, u, v, u2, v2, u2 + v2 );
                };
                //printf( "  finished at k = %d and ( u2 + v2 = % f ) < 4.0 =%d\n", k, u2 + v2, ( u2 + v2 ) < 4.0 );
                //sleep( 1000, 0 );
                /* compute  pixel color and write it to file */
                gpu_rectangle( (k >= maxiter) ? BLACK : k>>ITERSHIFT, i - xpixel , j - ypixel, i + xpixel, j + ypixel );
            }
        }
    }
    for (j = 0; j < yres; j++) {
        y = ymax - j * dy;
        for(i = 0; i < xres; i++) {
            u = 0.0;
            v = 0.0;
            u2 = u * u;
            v2 = v*v;
            x = xmin + i * dx;
            /* iterate the point */
            for (k = 1; k < maxiter && (u2 + v2 < 4.0); k++) {
                    v = 2 * u * v + y;
                    u = u2 - v2 + x;
                    u2 = u * u;
                    v2 = v * v;
            };
            /* compute  pixel color and write it to file */
            gpu_pixel( (k >= maxiter) ? BLACK : k>>ITERSHIFT, i , j );
        }
    }

    while(1) {}
}
