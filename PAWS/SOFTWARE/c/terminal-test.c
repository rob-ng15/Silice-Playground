#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>

unsigned short volatile * myPS2_VALID = (unsigned short volatile *) 0x8040;
unsigned short volatile * myPS2_KEYCODE = (unsigned short volatile *) 0x8044;

int main( void ) {
    int i;
    float x = 0.50f, y = 0.25f;

    INITIALISEMEMORY();

    // set up curses library
    initscr();
    start_color();


    while(1) {
        move( 0, 0 );
        for( i = 1; i < 8 ; i++ ) {
            attron( i );
            printw( "Terminal Test: Colour <%d>\n", i );
        }

        printw( "\nFloating Point Tests:\n\n" );
        for( i = 0; i < 8; i++ ) {
            printw("x %f, y %f\n    + %f, - %f, * %f, / %f, =%d <%d <=%d\n", x, y, x+y, x-y, x*y, x/y, x==y, x<y, x<=y );
            switch( rng(4 ) ) {
                case 0:
                    x += 2.0f;
                    y -= 2.0f;
                    break;
                case 1:
                    x -= 2.0f;
                    y += 2.0f;
                    break;
                case 2:
                    x *= 2.0f;
                    y /= 2.0f;
                    break;
                case 3:
                    y *= 2.0f;
                    x /= 2.0f;
                    break;
            }
        }
        refresh();
        clear();
        sleep( 4000, 0 );
        x = (float)rng(8);
        y = (float)rng(8);
    }
}
