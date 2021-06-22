#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

int main( void ) {
    unsigned char lastPS2_KEYCODE = 0;
    int i, j, k;
    float x, y;

    INITIALISEMEMORY();

    // set up curses library
    initscr();
    start_color();

    unsigned long cycles, time, insn;
    unsigned char *oldmemorytop, *memoryblock, *newmemorytop;
    oldmemorytop = MEMORYTOP; memoryblock = malloc( 320 * 240 ); newmemorytop = MEMORYTOP;

    while(1) {
        clear();
        move( 0, 0 );
        for( i = 1; i < 8 ; i++ ) {
            attron( i );
            printw( "Terminal Test: Colour <%d>\n", i );
        }

        printw( "\nFloating Point Tests:\n\n" );
        j = rng(32) - 16; x = (float) j;
        k = rng(32) - 16; y = (float) k;
        printw( "j = %d, k = %d, x = %f, y = %f, ", j, k, x, y );
        x = x / rng(8); y = y / rng(8);
        printw( " new x = %f, y = %f\n\n", x, y );
        refresh();

        for( i = 0; i < 4; i++ ) {
            printw("x %f, y %f\n    + = %f, - = %f, * = %f, / = %f sqrt = %f\n    =%d <%d <=%d    ", x, y, x+y, x-y, x*y, x/y, sqrtf(x), x==y, x<y, x<=y );
            switch( rng(4 ) ) {
                case 0:
                    printw( "x + 2 , y - 2\n" );
                    x = x + 2; y = y - 2;
                    break;
                case 1:
                    printw( "x - 2 , y + 2\n" );
                    x = x - 2; y = y + 2;
                    break;
                case 2:
                    printw( "x * 2 , y / 2\n" );
                    x = x * 2; y = y / 2;
                    break;
                case 3:
                    printw( "x / 2 , y * 2\n" );
                    x = x / 2; y = y * 2;
                    break;
            }
            refresh();
        }

        sleep( 1000, 0 );
    }
}
