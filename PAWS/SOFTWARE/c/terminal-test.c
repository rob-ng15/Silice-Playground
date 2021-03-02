#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>

unsigned short volatile * myPS2_VALID = (unsigned short volatile *) 0x8040;
unsigned short volatile * myPS2_KEYCODE = (unsigned short volatile *) 0x8044;

int main( void ) {
    int i, j, k;
    float x, y;

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
        j = rng(32) - 16; x = (float) j;
        k = rng(32) - 16; y= (float) k;
        printw( "j = %d, k = %d, x = %f, y = %f\n\n", j, k, x, y );

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
        sleep( 16000, 0 );
    }
}
