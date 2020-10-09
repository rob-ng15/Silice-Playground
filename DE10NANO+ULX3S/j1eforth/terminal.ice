algorithm terminal(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,
    output! uint1   terminal_display,
    
    input   uint8   terminal_character,
    input   uint1   terminal_write,
    input   uint1   showterminal,
    input   uint1   showcursor,
    input   uint1   timer1hz,
    output uint3    terminal_active
) <autorun> {
    // Character ROM 8x8 x 256
    uint8 characterGenerator8x8[] = {
        $include('characterROM8x8.inc')
    };
    
    // 80 x 4 character buffer for the input/output terminal
    dualport_bram uint8 terminal[640] = uninitialized;

    // Character position on the terminal x 0-79, y 0-7 * 80 ( fetch it one pixel ahead of the actual x pixel, so it is always ready )
    uint7 terminal_x = 0;
    uint3 terminal_y = 7;
    uint7 xterminalpos := (pix_x+1) >> 3;
    uint10 yterminalpos := ((pix_y - 416) >> 3) * 80; // 8 pixel high characters

    // Determine if cursor, and if cursor is flashing
    uint1 is_cursor := ( xterminalpos == terminal_x ) & ( ( ( pix_y - 416) >> 3 ) == terminal_y );
    
    // Derive the x and y coordinate within the current 8x8 terminal character block x 0-7, y 0-7
    uint3 xinterminal := (pix_x) & 7;
    uint3 yinterminal := (pix_y) & 7;

    // Derive the actual pixel in the current terminal
    uint1 terminalpixel := ((characterGenerator8x8[ terminal.rdata0 * 8 + yinterminal ] << xinterminal) >> 7) & 1;

    // Terminal active (scroll) flag and temporary storage for scrolling
    uint10 terminal_scroll = 0;
    uint10 terminal_scroll_next = 0;

    // Setup the reading of the terminal memory
    terminal.addr0 := xterminalpos + yterminalpos;
    terminal.wenable0 := 0;

    // Setup the writing to the terminal memory
    terminal.wenable1 := 0;

    // Default to transparent
    terminal_display := 0;
    
    // TERMINAL Actions
    // Write to terminal, move to next character and scroll
    always {
         switch( terminal_active ) {
             case 0: {
                switch( terminal_write ) {
                    case 1: {
                        // Display character
                        switch( terminal_character ) {
                            case 8: {
                                // BACKSPACE, move back one character
                                if( terminal_x > 0 ) {
                                    terminal_x = terminal_x - 1;
                                    terminal.addr1 = terminal_x - 1 + terminal_y * 80;
                                    terminal.wdata1 = 0;
                                    terminal.wenable1 = 1;
                                }
                            }
                            case 10: {
                                // LINE FEED, scroll
                                terminal_scroll = 0;
                                terminal_active = 1;
                            }
                            case 13: {
                                // CARRIAGE RETURN
                                terminal_x = 0;
                            }
                            default: {
                                // Display character
                                terminal.addr1 = terminal_x + terminal_y * 80;
                                terminal.wdata1 = terminal_character;
                                terminal.wenable1 = 1;
                                if( terminal_x == 79 ) {
                                    terminal_x = 0;
                                    terminal_scroll = 0;
                                    terminal_active = 1;
                                } else {
                                    terminal_x = terminal_x + 1;
                                }
                            }
                        }
                    }
                    default: {}
                }
            }
            // TERMINAL SCROLL
            case 1: {
                // SCROLL
                if( terminal_scroll == 560 ) {
                    // Finished Scroll, Move to blank
                    terminal_active = 4;
                } else {
                    // Read the next character down
                    terminal.addr1 = terminal_scroll + 80;
                    terminal_active = 2;
                }
            }
            case 2: {
                // Retrieve the character to move up
                terminal_scroll_next = terminal.rdata1;
                terminal_active = 3;
            }
            case 3: {
                // Write the character one line up and move onto the next character
                terminal.addr1 = terminal_scroll;
                terminal.wdata1 = terminal_scroll_next;
                terminal.wenable1 = 1;
                terminal_scroll = terminal_scroll + 1;
                terminal_active = 1;
            }
            case 4: {
                // Blank out the last line
                terminal.addr1 = terminal_scroll;
                terminal.wdata1 = 0;
                terminal.wenable1 = 1;
                if( terminal_scroll == 640 ) {
                    // Finish Blank
                    terminal_active = 0;
                } else {
                    terminal_scroll = terminal_scroll + 1;
                }
            }
            default: {terminal_active = 0;}
         } // TERMINAL
    }

    // Render the terminal
    while(1) {
        if( pix_active & showterminal & (pix_y > 415) ) {
            // TERMINAL is in range and showterminal flag
            // Invert colours for cursor if flashing
            switch( terminalpixel ) {
                case 0: {
                    if( is_cursor & timer1hz ) {
                        pix_red = $color_depth$==6 ? 63 : 255;
                        pix_green = $color_depth$==6 ? 63 : 255;
                        pix_blue = $color_depth$==6 ? 63 : 255;
                    } else {
                        pix_red = 0;
                        pix_green = 0;
                        pix_blue = $color_depth$==6 ? 63 : 255;
                    }
                }
                case 1: {
                    if( is_cursor & timer1hz ) {
                        pix_red = 0;
                        pix_green = 0;
                        pix_blue = $color_depth$==6 ? 63 : 255;
                    } else {
                        pix_red = $color_depth$==6 ? 63 : 255;
                        pix_green = $color_depth$==6 ? 63 : 255;
                        pix_blue = $color_depth$==6 ? 63 : 255;
                    }
                }
            }
            terminal_display = 1;
        } else {
            terminal_display = 0;
        }
    }

}
