#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

unsigned short volatile * myPS2_AVAILABLE = (unsigned short volatile *) 0x8040;
unsigned short volatile * myPS2_KEYCODE = (unsigned short volatile *) 0x8044;

int main( void ) {
    INITIALISEMEMORY();

    // set up curses library
    initscr();
    start_color();

    move( 0, 0 );
    for( int i = 1; i < 8 ; i++ ) {
        attron( i );
        printw( "Terminal Test: Colour <%d>\n", i );
    }
    printw( "PS/2 Keyboard Test\n\n" );
    while(1) {
        if( ps2_character_available() ) {
            addch( ps2_inputcharacter() );
        }
        refresh();
    }
}
