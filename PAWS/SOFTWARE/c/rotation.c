#include "PAWSlibrary.h"
#include <math.h>

char framebuffer = 0;
float scale = 1.0, scaledx = -0.1;

struct Point2D {
    int dx;
    int dy;
};

struct Point2D Rotate2D( struct Point2D point, int xc, int yc, int angle, float scale ) {
    struct Point2D newpoint;
    float radians = angle*0.01745329252;

    newpoint.dx = ( (point.dx * scale)*cosf(radians)-(point.dy * scale)*sinf(radians) ) + xc;
    newpoint.dy = ( (point.dx * scale)*sinf(radians)+(point.dy * scale)*cosf(radians) ) + yc;

    return( newpoint );
}

int main( void ) {
    INITIALISEMEMORY();

    struct Point2D Square[4] = { { -100, -100 }, { 100, -100 }, { 100, 100 }, { -100, 100 } };
    struct Point2D NewSquare[4];

    while(1) {
        for( int angle = 0; angle < 180; angle++ ) {
            for( int vertex = 0; vertex < 4; vertex++ ) {
                NewSquare[ vertex ] = Rotate2D( Square[vertex], 160, 120, angle, scale );
            }

            // SWITCH TO ALTERNATE FRAMEBUFFER FOR DRAWING
            bitmap_draw( 1 - framebuffer );
            gpu_cs();

            for( int vertex = 0; vertex < 4; vertex++ ) {
                gpu_line( WHITE, NewSquare[ vertex ].dx, NewSquare[ vertex ].dy, NewSquare[ ( vertex == 3 ) ? 0 : vertex + 1 ].dx, NewSquare[ ( vertex == 3 ) ? 0 : vertex + 1 ].dy );
            }

            // SWITCH THE FRAMEBUFFER
            framebuffer = 1 - framebuffer;
            bitmap_display( framebuffer );

            // ADJUST THE SCALE
            if( scaledx > 0 ) {
                if( scale >= 2.0 ) {
                    scaledx = -0.1;
                }
            } else {
                if( scale <= 0.1 ) {
                    scaledx = 0.1;
                }
            }
            scale = scale + scaledx;
        }
    }
}
