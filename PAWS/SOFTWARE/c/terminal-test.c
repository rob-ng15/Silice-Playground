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

unsigned short volatile * myUSBHID_VALID = (unsigned short volatile *) 0x8080;
unsigned short volatile * myUSBHID_MODIFIERS = (unsigned short volatile *) 0x8082;
unsigned short volatile * myUSBHID_KEYS12 = (unsigned short volatile *) 0x8084;
unsigned short volatile * myUSBHID_KEYS34 = (unsigned short volatile *) 0x8086;
unsigned short volatile * myUSBHID_KEYS56 = (unsigned short volatile *) 0x8088;

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

    printw("\nFLOAT TEST: x = %f, y = %f, x * y = %f, x / y = %f\n\n", x, y, x*y, x / y );

    while(1) {
        mvprintw( 15, 0, "SYSTEMTIME <%lu>\n  CPU CYCLES <%lu>\n  CPU INSTRUCTIONS <%lu>\n    CYCLES / INSTRUCTIONS <%f>", CSRtime(), CSRcycles(), CSRinstructions(), CSRcycles()/CSRinstructions() );
        mvprintw( 27, 0, "PS2 Valid <%x> Keycode <%x>", *myPS2_VALID, *myPS2_KEYCODE );
        mvprintw( 29, 0, "USB HID Valid <%x> Modifiers <%x> Keycodes <%x> <%x> <%x>", *myUSBHID_VALID, *myUSBHID_MODIFIERS, *myUSBHID_KEYS12, *myUSBHID_KEYS34, *myUSBHID_KEYS56 );
    }
}

extern long CSRcycles( void );
extern long CSRinstructions( void );
extern long CSRtime( void );
