#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

int main( void ) {

    INITIALISEMEMORY();

    // set up curses library
    initscr();
    start_color();

    clear();
    move( 0, 0 );
    attron( 7 );

    printw( "Square Root Tests:\n\n" );
    for( int i = -4; i < 16; i++ ) {
        printw("i =  %d sqrt = %f\n", i, sqrtf(i) );
        refresh();
    }

    while(1) {}
}
