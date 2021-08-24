#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

static inline float maxf(float x, float y) { return x>y?x:y; }
static inline float minf(float x, float y) { return x<y?x:y; }

int main( void ) {
    unsigned char lastPS2_KEYCODE = 0;
    int i, j, k, l, m;
    float x, y;

    INITIALISEMEMORY();

    // set up curses library
    initscr();
    start_color();

    unsigned long cycles, time, insn;
    unsigned char *oldmemorytop, *memoryblock, *newmemorytop;
    oldmemorytop = MEMORYTOP; memoryblock = malloc( 320 * 240 ); newmemorytop = MEMORYTOP;

    for( int loop = 0; loop < 4; loop++ ) {
        clear();
        move( 0, 0 );
        for( i = 1; i < 8 ; i++ ) {
            attron( COLOR_PAIR(i) );
            printw( "Terminal Test: Colour <%d>\n", i );
        }

        printw( "\nFloating Point Tests:\n\n" );
        j = rng(32) - 16; x = (float) j;
        k = rng(32) - 16; y = (float) k;
        printw( "j = %d, k = %d, x = %f, y = %f\n", j, k, x, y );
        l = rng(8) + 1; m = rng(8) + 1; x = x / l; y = y /m;
        printw( "new x / %d = %f, y / %d  = %f\n\n", l, x, m, y );
        refresh();

        for( i = 0; i < 4; i++ ) {
            printw("x %f, y %f\n    + = %f, - = %f, * = %f, / = %f\n    sqrt = %f, min = %f, max = %f\n    =%d <%d <=%d    ", x, y, x+y, x-y, x*y, x/y, sqrtf(x), minf(x,y), maxf(x,y) ,x==y, x<y, x<=y );
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
                    printw( "x / 2 , y * 2\n\n" );
                    x = x / 2; y = y * 2;
                    break;
            }
            refresh();
        }

        sleep( 4000, 0 );
    }
}
