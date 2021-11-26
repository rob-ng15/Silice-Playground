algorithm terminal(
    simple_dualport_bram_port0 terminal,

    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint1   pixel,
    output! uint1   terminal_display,

    input   uint1   blink,
    input   uint1   showterminal,
    input   uint7   terminal_x,
    input   uint3   terminal_y
) <autorun,reginputs> {
    // Character ROM 8x8 x 256
    brom uint8 characterGenerator8x8[] = {
        $include('ROM/characterROM8x8nobold.inc')
    };

    // Character position on the terminal x 0-79, y 0-7 * 80 ( fetch it one pixel ahead of the actual x pixel, so it is always ready )
    uint7   xterminalpos <: ( pix_active ? pix_x + 2 : 0 ) >> 3;
    uint3   yterminalpos <: ( pix_vblank ? 0 : pix_y - 416 ) >> 3;

    // Determine if cursor, and if cursor is flashing
    uint1 is_cursor <: blink & ( xterminalpos == terminal_x ) & ( yterminalpos == terminal_y );

    // Derive the x and y coordinate within the current 8x8 terminal character block x 0-7, y 0-7
    uint3 xinterminal <: pix_x[0,3];
    uint3 yinterminal <: pix_y[0,3];

    // Derive the actual pixel in the current terminal
    uint1 terminalpixel <: characterGenerator8x8.rdata[ 7 - xinterminal, 1 ];

    // Setup the reading of the terminal memory
    terminal.addr0 := xterminalpos + yterminalpos * 80;

    // Setup the reading of the characterGenerator8x8 ROM
    characterGenerator8x8.addr :=  { terminal.rdata0, yinterminal };

    // Default to transparent and active pixels always blue
    terminal_display := pix_active & showterminal & ( pix_y > 415 );
    pixel := terminalpixel ^ is_cursor;
}

algorithm terminal_writer(
    simple_dualport_bram_port1 terminal,

    input   uint8   terminal_character,
    input   uint2   terminal_write,
    output  uint2   terminal_active(0),
    output  uint7   terminal_x(0),
    output  uint3   terminal_y(7)
) <autorun,reginputs> {
    simple_dualport_bram uint8 terminal_copy[640] = uninitialized;

    // Terminal active (scroll) flag and temporary storage for scrolling
    uint10  terminal_scroll = uninitialised;
    uint10  terminal_scroll_next <:: terminal_scroll + 1;
    uint1   scrolling <:: ( terminal_scroll < 560 );
    uint1   endofline <:: ( terminal_x == 79 );
    uint1   working <:: ( terminal_scroll != 640 );

    // Setup the writing to the terminal memory
    uint10  terminal_address <:: terminal_x + terminal_y * 80;
    terminal.wenable1 := 1; terminal_copy.wenable1 := 1;

    // READ CHARACTER ON THE NEXT LINE FOR SCROLLING
    terminal_copy.addr0 := terminal_scroll + 80;

    always {
        switch( terminal_write ) {
            case 1: {
                // Display character
                switch( terminal_character ) {
                    case 8: {
                        // BACKSPACE, move back one character
                        switch( terminal_x ) {
                            default: {
                                terminal_x = terminal_x - 1;
                                terminal.addr1 = terminal_address; terminal.wdata1 = 0;
                                terminal_copy.addr1 = terminal_address; terminal_copy.wdata1 = 0;
                            }
                            case 0: {}
                        }
                    }
                    case 10: { terminal_active = 1; } // LINE FEED, force scroll
                    case 13: { terminal_x = 0; } // CARRIAGE RETURN, return to left
                    default: {
                        // Display character
                        terminal.addr1 = terminal_address; terminal.wdata1 = terminal_character;
                        terminal_copy.addr1 = terminal_address; terminal_copy.wdata1 = terminal_character;
                        terminal_active = endofline;
                        terminal_x = endofline ? 0 : terminal_x + 1;
                    }
                }
            }
            case 2: { terminal_active = 2; } // RESET
            default: {}
        }
    }

    while(1) {
        switch( terminal_active ) {
            default: { terminal_scroll = 0; }
            case 1: {
                // SCROLL AND BLANK LAST LINE
                while( working ) {
                    ++:
                    terminal.addr1 = terminal_scroll;
                    terminal.wdata1 = scrolling ? terminal_copy.rdata0 : 0;
                    terminal_copy.addr1 = terminal_scroll;
                    terminal_copy.wdata1 = scrolling ? terminal_copy.rdata0 : 0;
                    terminal_scroll = terminal_scroll_next;
                }
                terminal_active = 0;
            }
            case 2: {
                while( working ) {
                    terminal.addr1 = terminal_scroll;
                    terminal.wdata1 = 0;
                    terminal_copy.addr1 = terminal_scroll;
                    terminal_copy.wdata1 = 0;
                    terminal_scroll = terminal_scroll_next;
                }
                terminal_x = 0;
                terminal_y = 7;
                terminal_active = 0;
            }
        }
    }
}
