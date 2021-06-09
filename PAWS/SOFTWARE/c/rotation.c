#include "PAWSlibrary.h"
#include <stdio.h>
#include <math.h>

float newX( float x, float y, float xorigin, float yorigin, float angle ) {
    return( (x-xorigin)*cosf(angle*0.0174533)-(y-yorigin)*sinf(angle*0.0174533)+xorigin );
}
float newY( float x, float y, float xorigin, float yorigin, float angle ) {
    return( (x-xorigin)*sinf(angle*0.0174533)+(y-yorigin)*cosf(angle*0.0174533)+yorigin );
}
int main( void ) {
    INITIALISEMEMORY();

    initscr();
    start_color();
    clear();
    move( 0, 0 );
    attron( 7 );

    for( int i = 0; i < 90; i += 10 ) {
        printw( " angle = %d, (60,20) becomes (%f,%f)\n", i, newX(60, 20, 160, 120, i), newY(60, 20, 160, 120, i) );
        gpu_line( WHITE, newX(60, 20, 160, 120, i), newY(60, 20, 160, 120, i), newX( 260, 20, 160, 120, i), newY( 260, 20, 160, 120, i) );
        gpu_line( WHITE, newX(260, 20, 160, 120, i), newY(260, 20, 160, 120, i), newX( 260, 220, 160, 120, i), newY( 260, 220, 160, 120, i) );
        gpu_line( WHITE, newX(260, 220, 160, 120, i), newY(260, 220, 160, 120, i), newX( 60, 220, 160, 120, i), newY( 60, 220, 160, 120, i) );
        gpu_line( WHITE, newX(60, 220, 160, 120, i), newY(60, 220, 160, 120, i), newX( 60, 20, 160, 120, i), newY( 60, 20, 160, 120, i) );
    }
    refresh();

    while(1) {}
}
