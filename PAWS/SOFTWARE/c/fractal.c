#include "PAWSlibrary.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>

int main( void ) {
    INITIALISEMEMORY();

  /* The window in the plane. */
  const float xmin = 0.27085;
  const float xmax = 0.27100;
  const float ymin = 0.004640;
  const float ymax = 0.004810;
  /* Maximum number of iterations, at most 65535. */
  const uint16_t maxiter = 1023;
  /* Image size */
  const int xres = 640;
  const int yres = 480;

  /* Precompute pixel width and height. */
  float dx=(xmax-xmin)/xres;
  float dy=(ymax-ymin)/yres;

  float x, y; /* Coordinates of the current point in the complex plane. */
  float u, v; /* Coordinates of the iterated point. */
  int i,j; /* Pixel counters */
  int k; /* Iteration counter */
  for (j = 0; j < yres; j++) {
    y = ymax - j * dy;
    for(i = 0; i < xres; i++) {
      float u = 0.0;
      float v= 0.0;
      float u2 = u * u;
      float v2 = v*v;
      x = xmin + i * dx;
      /* iterate the point */
      for (k = 1; k < maxiter && (u2 + v2 < 4.0); k++) {
            v = 2 * u * v + y;
            u = u2 - v2 + x;
            u2 = u * u;
            v2 = v * v;
      };
      /* compute  pixel color and write it to file */
      if (k >= maxiter) {
        /* interior */
        //const unsigned char black[] = {0, 0, 0, 0, 0, 0};
        //fwrite (black, 6, 1, fp);
      }
      else {
        /* exterior */
        gpu_pixel( k>>4, i, j);
      };
    }
  }

    while(1) {
    }
}
