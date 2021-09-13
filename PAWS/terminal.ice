algorithm terminal(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   terminal_display,

    input   uint8   terminal_character,
    input   uint2   terminal_write,
    input   uint1   showterminal,
    output  uint2   terminal_active
) <autorun> {
    // CURSOR CLOCK
    pulse1hz P1();
    uint1   timer1hz := P1.counter1hz[0,1];

    // Character ROM 8x8 x 256
    brom uint8 characterGenerator8x8[] = {
        $include('ROM/characterROM8x8nobold.inc')
    };

    // 80 x 4 character buffer for the input/output terminal
    simple_dualport_bram uint8 terminal <input!> [640] = uninitialized;

    uint7 terminal_x = uninitialised;
    uint3 terminal_y = uninitialised;
    terminal_writer TW(
        terminal <:> terminal,
        terminal_character <: terminal_character,
        terminal_write <: terminal_write,
        terminal_active :> terminal_active,
        terminal_x :> terminal_x,
        terminal_y :> terminal_y
    );

    // Character position on the terminal x 0-79, y 0-7 * 80 ( fetch it one pixel ahead of the actual x pixel, so it is always ready )
    uint7 xterminalpos <: ( pix_active ? pix_x + 2 : 0 ) >> 3;
    uint10 yterminalpos <: (( pix_vblank ? 0 : pix_y - 416 ) >> 3) * 80;

    // Determine if cursor, and if cursor is flashing
    uint1 is_cursor <: ( xterminalpos == terminal_x ) && ( ( ( pix_y - 416) >> 3 ) == terminal_y );

    // Derive the x and y coordinate within the current 8x8 terminal character block x 0-7, y 0-7
    uint3 xinterminal <: pix_x[0,3];
    uint3 yinterminal <: pix_y[0,3];

    // Derive the actual pixel in the current terminal
    uint1 terminalpixel <: characterGenerator8x8.rdata[ 7 - xinterminal, 1 ];

    // Setup the reading of the terminal memory
    terminal.addr0 := xterminalpos + yterminalpos;

    // Setup the reading of the characterGenerator8x8 ROM
    characterGenerator8x8.addr :=  { terminal.rdata0, yinterminal };

    // Default to transparent and active pixels always blue
    terminal_display := pix_active & showterminal & ( pix_y > 415 );
    pixel := ( terminalpixel ) ? ( ( is_cursor && timer1hz ) ? 6b000011 : 6b111111 ) : ( ( is_cursor && timer1hz ) ? 6b111111 : 6b000011 );
}

algorithm terminal_writer(
    simple_dualport_bram_port1 terminal,

    input   uint8   terminal_character,
    input   uint2   terminal_write,
    output  uint2   terminal_active(0),
    output  uint7   terminal_x(0),
    output  uint3   terminal_y(7)
) <autorun> {
    simple_dualport_bram uint8 terminal_copy <input!> [640] = uninitialized;

    // Terminal active (scroll) flag and temporary storage for scrolling
    uint10  terminal_scroll = uninitialised;
    uint1   scrolling <:: ( terminal_scroll < 560 );
    uint1   endofline <:: ( terminal_x == 79 );

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
                while( terminal_scroll != 640 ) {
                    ++:
                    terminal.addr1 = terminal_scroll;
                    terminal.wdata1 = scrolling ? terminal_copy.rdata0 : 0;
                    terminal_copy.addr1 = terminal_scroll;
                    terminal_copy.wdata1 = scrolling ? terminal_copy.rdata0 : 0;
                    terminal_scroll = terminal_scroll + 1;
                }
                terminal_active = 0;
            }
            case 2: {
                while( terminal_scroll != 640 ) {
                    terminal.addr1 = terminal_scroll;
                    terminal.wdata1 = 0;
                    terminal_copy.addr1 = terminal_scroll;
                    terminal_copy.wdata1 = 0;
                    terminal_scroll = terminal_scroll + 1;
                }
                terminal_x = 0;
                terminal_y = 7;
                terminal_active = 0;
            }
        }
    }
}
