#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

unsigned short volatile * myPS2_AVAILABLE = (unsigned short volatile *) 0x8040;
unsigned short volatile * myPS2_KEYCODE = (unsigned short volatile *) 0x8044;

int main( void ) {
    unsigned short lastPS2_KEYCODE = 0;
    int i, j, k;
    float x, y;

    INITIALISEMEMORY();

    // set up curses library
    initscr();
    start_color();

    unsigned char *oldmemorytop, *memoryblock, *newmemorytop;
    oldmemorytop = MEMORYTOP; memoryblock = malloc( 320 * 240 ); newmemorytop = MEMORYTOP;

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

        for( i = 0; i < 4; i++ ) {
            printw("x %f, y %f\n    + = %f, - = %f, * = %f, / = %f\n    =%d <%d <=%d    ", x, y, x+y, x-y, x*y, x/y, x==y, x<y, x<=y );
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
        }
        set_timer1khz( 16000, 0 );
        while( get_timer1khz(0) ) {
            if( *myPS2_AVAILABLE ) {
                lastPS2_KEYCODE = *myPS2_KEYCODE;
            }
            mvprintw( 27, 0, "MEMORY TOP OLD <%ud> BLOCK <%ud> TOP NEW <%ud>", (int)oldmemorytop, (int)memoryblock, (int)newmemorytop );
            mvprintw( 29, 0, "PS2 AVAILABLE <%1x> LAST CHARACTER <%2x>", *myPS2_AVAILABLE, lastPS2_KEYCODE );
            refresh();
        }
        clear();

    }
}
