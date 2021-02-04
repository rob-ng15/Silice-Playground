#include "PAWSlibrary.h"
#include "curses.h"

void terminalrefresh( void ) {
    // SETUP STACKPOINTER FOR THE SMT THREAD
    asm volatile ("li sp ,0x2000");
    while(1) {
        sleep( 250, 1 );
        refresh();
    }
}

void main( void ) {
    INITIALISEMEMORY();
    // set up curses library
    initscr();

    SMTSTART( (unsigned int )terminalrefresh );

    for( unsigned char i = 0; i < 255; i++ ) {
        addch( i );
    }

    while(1) {
    }
}
