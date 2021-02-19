#include "PAWSlibrary.h"

void terminalrefresh( void ) {
    // SETUP STACKPOINTER FOR THE SMT THREAD
    asm volatile ("li sp ,0x2000");
    while(1) {
        await_vblank();
        refresh();
    }
}

extern int _bss_start, _bss_end, _end;
extern char *MEMORYTOP;

unsigned short volatile * myUSBHID_VALID = (unsigned short volatile *) 0x8080;
unsigned short volatile * myUSBHID_MODIFIERS = (unsigned short volatile *) 0x8082;
unsigned short volatile * myUSBHID_KEYS12 = (unsigned short volatile *) 0x8084;
unsigned short volatile * myUSBHID_KEYS34 = (unsigned short volatile *) 0x8086;
unsigned short volatile * myUSBHID_KEYS56 = (unsigned short volatile *) 0x8088;

void main( void ) {
    int i;
    unsigned char *memoryblock, *memoryblock2;

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

    printw( "\nBSS START <%x> END <%x>\n", &_bss_start, &_bss_end );
    printw( "HEAP START <%x> MEMORYTOP <%x>\n", &_end, MEMORYTOP );

    memoryblock = malloc( 1024 );
    printw( "\nMEMORYBLOCK <%x>\n", memoryblock );
    memoryblock2 = malloc( 2048 );
    printw( "\nMEMORYBLOCK2 <%x>\n", memoryblock2 );

    while(1) {
        if( *myUSBHID_VALID ) {
            mvprintw( 29, 0, "USB HID Modifiers <%x> Keycodes <%x> <%x> <%x>\n", *myUSBHID_MODIFIERS, *myUSBHID_KEYS12, *myUSBHID_KEYS34, *myUSBHID_KEYS56 );
        }
    }
}
