#include "PAWSlibrary.h"

void terminalrefresh( void ) {
    // SETUP STACKPOINTER FOR THE SMT THREAD
    asm volatile ("li sp ,0x2000");
    while(1) {
        sleep( 250, 1 );
        refresh();
    }
}

void main( void ) {
    int i;

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

    while(1) {
    }
}
