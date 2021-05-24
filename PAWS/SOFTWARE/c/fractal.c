#include "PAWSlibrary.h"
#include <stdint.h>

// NORMAL IS 1023 AND 4, FAST IS 63 AND 0
#define MAXITER 63
#define ITERSHIFT 0

int main( void ) {
    INITIALISEMEMORY();

    /* The window in the plane. */
    const float xmin = 0.27085;
    const float xmax = 0.27100;
    const float ymin = 0.004640;
    const float ymax = 0.004810;
    /* Maximum number of iterations, at most 65535. */
    const uint16_t maxiter = MAXITER;
    /* Image size */
    const int xres = 320;
    const int yres = 240;

    /* Precompute pixel width and height. */
    float dx=(xmax-xmin)/xres;
    float dy=(ymax-ymin)/yres;

    float x, y; /* Coordinates of the current point in the complex plane. */
    float u, v; /* Coordinates of the iterated point. */
    float u2, v2;
    int i,j; /* Pixel counters */
    int k; /* Iteration counter */
    for (j = 0; j < yres; j++) {
        bitmap_scrollwrap( 2 );
        y = ymax - j * dy;
        for(i = 0; i < xres; i++) {
            gpu_pixel( WHITE, i, 239);
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
            gpu_pixel( (k >= maxiter) ? BLACK : k>>ITERSHIFT, i , 239 );
            }
    }

    while(1) {}
}
