#include "PAWSlibrary.h"
#include <stdio.h>
#include <stdint.h>

// NORMAL IS 1023 AND 4, FAST IS 63 AND 0
#define MAXITER 64
#define ITERSHIFT 0

int main( void ) {
    INITIALISEMEMORY();

    // set up curses library
    initscr();
    start_color();

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

    short i,j; /* Pixel counters */
    short k; /* Iteration counter */
    short ysize = yres, xsize = xres, ypixel, xpixel, z;

    for( z = 0; z < 6; z++ ) {
        ysize = ysize >> 1; ypixel = ysize >> 1;
        xsize = xsize >> 1; xpixel = xsize >> 1;

        for(j = ysize; j < yres; j += ysize ) {
            y = ymax - j * dy;
            for(i = xsize; i < xres; i += xsize ) {
                //clear();
                //move( 0, 0 );
                //attron( 7 );
                u = 0.0;
                v = 0.0;
                u2 = u * u;
                v2 = v*v;
                x = xmin + i * dx;
                //printw( "( %3d, %3d ) x = %f, y = %f\n", i , j, x, y );
                /* iterate the point */
                for (k = 1; k < maxiter && (u2 + v2 < 4.0); k++) {
                        v = 2 * u * v + y;
                        u = u2 - v2 + x;
                        u2 = u * u;
                        v2 = v * v;
                        //printw( "  k = %d u = %f v = %f u2 = %f v2 = %f u2 + v2 = %f < = %d\n", k, u, v, u2, v2, u2 + v2, (u2 + v2 < 4.0) );
                };
                //refresh();
                //sleep( 1000, 0 );
                /* compute  pixel color and write it to file */
                gpu_rectangle( (k >= maxiter) ? BLACK : k>>ITERSHIFT, i - xpixel , j - ypixel, i + xpixel, j + ypixel );
            }
        }
    }
    for (j = 0; j < yres; j++) {
        y = ymax - j * dy;
        for(i = 0; i < xres; i++) {
            //clear();
            //move( 0, 0 );
            //attron( 7 );
            //printw( "( %3d, %3d )\n", i , j );
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
            //refresh();
            /* compute  pixel color and write it to file */
            gpu_pixel( (k >= maxiter) ? BLACK : k>>ITERSHIFT, i , j );
        }
    }

    while(1) {}
}
