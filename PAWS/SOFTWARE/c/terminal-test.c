#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>

void terminalrefresh( void ) {
    // SETUP STACKPOINTER FOR THE SMT THREAD
    asm volatile ("li sp ,0x2000");
    while(1) {
        await_vblank();
        refresh();
    }
}

unsigned short volatile * myPS2_VALID = (unsigned short volatile *) 0x8040;
unsigned short volatile * myPS2_KEYCODE = (unsigned short volatile *) 0x8044;

int main( void ) {
    int i;

    float x = 0.5, y = 0.75;

    INITIALISEMEMORY();

    // set up curses library
    initscr();
    start_color();

    SMTSTART( (unsigned int )terminalrefresh );

    move( 0, 0 );
    for( i = 1; i < 8 ; i++ ) {
        attron( i );
        printw( "Terminal Test: Colour <%d>\n", i );
    }

    mvprintw( 9, 0, "START: x = %8.2f, y = %8.2f, x * y = %8.2f, x / y = %8.2f", x, y, x*y, x / y );


    while(1) {
        mvprintw( 12, 0, "FLOAT TEST: x = %12.2f, y = %12.2f\n            x * y = %12.2f, x / y = %12.2f", x, y, x*y, x / y );
        switch( rng(4) ) {
            case 0:
                x += rng(4) - 2;
                break;
            case 1:
                y +=  rng(4) - 2;
                break;
            case 2:
                x *= 2; y /= 2;
                break;
            case 3:
                x /= 2; y *= 2;
                break;
        }
        mvprintw( 15, 0, "SYSTEMTIME <%lu>\n  CPU CYCLES <%lu>\n  CPU INSTRUCTIONS <%lu>\n    CYCLES / INSTRUCTIONS <%d>", CSRtime(), CSRcycles(), CSRinstructions(), (int)CSRcycles()/(int)CSRinstructions() );
        mvprintw( 27, 0, "PS2 Valid <%x> Keycode <%x>", *myPS2_VALID, *myPS2_KEYCODE );
    }
}
