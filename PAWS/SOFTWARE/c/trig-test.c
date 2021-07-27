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

    printw( "Trigonometry Tests:\n\n" );
    for( int i = -360; i < 360; i += 30 ) {
        float angle = i *0.01745329252;
        printw("deg =  %d rad = %f sin = %f cos = %f tan = %f\n", i, angle, sinf(angle), cosf(angle), tanf(angle) );
        refresh();
    }

    while(1) {}
}
