#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>


int main( void ) {
    INITIALISEMEMORY();
    ps2_keyboardmode(PS2_KEYBOARD);

    // set up curses library
    initscr();
    start_color();

    move( 0, 0 );
    for( int i = 1; i < 8 ; i++ ) {
        attron( i );
        printw( "Terminal Test: Colour <%d>\n", i );
    }
    printw( "\nPS/2 Keyboard Test PS/2 in WHITE, UART in YELLOW\n\n");

    int cursor_x, cursor_y;
    unsigned short thecharacter;

    while(1) {
        if( ps2_character_available() ) {
            thecharacter = ps2_inputcharacter();
            if( thecharacter & 0x100 ) {
                attron( 6); getyx( &cursor_y, &cursor_x );
                // ESCAPE CHARACTER
                getyx( &cursor_y, &cursor_x );
                switch( thecharacter ) {
                    case 0x141: // UP
                        move( cursor_y != 0 ? cursor_y - 1 : 29, cursor_x );
                        break;
                    case 0x142: // DOWN
                        move( cursor_y != 29 ? cursor_y + 1 : 0, cursor_x );
                        break;
                    case 0x143: // RIGHT
                        if( ( cursor_y == 29 ) && ( cursor_x == 79 ) ) {
                            move( 0, 0 );
                        } else {
                            move( cursor_x == 79 ? cursor_y + 1 : cursor_y, cursor_x == 79 ? 0 : cursor_x + 1 );
                        }
                        break;
                    case 0x144: // LEFT
                        if( ( cursor_y == 0 ) && ( cursor_x == 0 ) ) {
                            move( 29, 79 );
                        } else {
                            move( cursor_x == 0 ? cursor_y - 1 : cursor_y, cursor_x == 0 ? 79 : cursor_x - 1 );
                        }
                        break;
                    case 0x131: // HOME
                        move( cursor_y, 0 ); printw("HOME");
                        break;
                    case 0x134: // END
                        move( cursor_y, 77 ); printw("END");
                        break;
                    case 0x135: // PGUP
                        move( 0, cursor_x ); printw("PGUP");
                        break;
                    case 0x136: // PGDN
                        move( 29, cursor_x ); printw("PGDN");
                        break;
                    case 0x133: // DELETE
                        deleteln(); printw("DELETE");
                        break;
                    case 0x132: // INSERT
                        clrtoeol(); printw("INSERT");
                        break;
                    default: // PROBABLY A FUNCTION
                        printw("F%d",( thecharacter & 0xf ) + 12 * ( ( thecharacter & 0x10 ) >> 4 ) );
                }
            } else {
                // PRINTABLE CHARACTER
                attron(7); addch( (unsigned char )thecharacter & 0xff );
            }
            printf("PS/2 = %x\n",thecharacter);
        }
        if( character_available() ) {
            attron(3); thecharacter = inputcharacter(); addch( thecharacter );
            printf("UART = %x\n",thecharacter);
        }

        refresh();
    }
}
