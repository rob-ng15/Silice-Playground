        switch( tm_active ) {
            case 1: {
                // Setup for scroll/wrap LEFT
                x_cursor = 0;
                y_cursor = 0;
                tm_active = 2;
            }
            case 2: {
                // Setup addresses for the first column
                tile.addr1 = 0 + ( y_cursor * 42 );
                foreground.addr1 = 0 + ( y_cursor * 42 );
                background.addr1 = 0 + ( y_cursor * 42 );
                tm_active = 3;
            }
            case 3: {
                // Save the first column
                new_tile = ( tm_scroll == 1 ) ? 0 : tile.rdata1;
                new_foreground = ( tm_scroll == 1 ) ? 0 : foreground.rdata1;
                new_background = ( tm_scroll == 1 ) ? 7h40 : background.rdata1;
                tm_active = 4;
            }
            case 4: {
                // Setup addresses for the next column
                tile.addr1 = ( x_cursor + 1 ) + ( y_cursor * 42 );
                foreground.addr1 = ( x_cursor + 1 ) + ( y_cursor * 42 );
                background.addr1 = ( x_cursor + 1 ) + ( y_cursor * 42 );
                tm_active = 5;
            }
            case 5: {
                // Save the next column
                scroll_tile = tile.rdata1;
                scroll_foreground = foreground.rdata1;
                scroll_background = background.rdata1;
                tm_active = 6;
            }
            case 6: {
                // Write into the present column
                tile.addr1 = ( x_cursor ) + ( y_cursor * 42 );
                tile.wdata1 = scroll_tile;
                tile.wenable1 = 1;
                foreground.addr1 = ( x_cursor ) + ( y_cursor * 42 );
                foreground.wdata1 = scroll_foreground;
                foreground.wenable1 = 1;
                background.addr1 = ( x_cursor ) + ( y_cursor * 42 );
                background.wdata1 = scroll_background;
                background.wenable1 = 1;
                tm_active = 7;
            }
            case 7: {
                if( x_cursor == 40 ) {
                    // At the last, but one column
                    // Write into the column
                    // Move to the next row
                    tile.addr1 = ( 41 ) + ( y_cursor * 42 );
                    tile.wdata1 = new_tile;
                    tile.wenable1 = 1;
                    foreground.addr1 = ( 41 ) + ( y_cursor * 42 );
                    foreground.wdata1 = new_foreground;
                    foreground.wenable1 = 1;
                    background.addr1 = ( 41 ) + ( y_cursor * 42 );
                    background.wdata1 = new_background;
                    background.wenable1 = 1;
                    if( y_cursor == 31 ) {
                        // FINISHED
                        tm_active = 0;
                    } else {
                        x_cursor = 0;
                        y_cursor = y_cursor + 1;
                        tm_active = 2;
                    }
                } else {
                    // Move to the next column
                    x_cursor = x_cursor + 1;
                    tm_active = 4;
                }
            }

            case 8: {
                // Setup for scroll/wrap RIGHT
                x_cursor = 41;
                y_cursor = 0;
                tm_active = 9;
            }
            case 9: {
                // Setup addresses for the last column
                tile.addr1 = 41 + ( y_cursor * 42 );
                foreground.addr1 = 41 + ( y_cursor * 42 );
                background.addr1 = 41 + ( y_cursor * 42 );
                tm_active = 10;
            }
            case 10: {
                // Save the last column
                new_tile = ( tm_scroll == 1 ) ? 0 : tile.rdata1;
                new_foreground = ( tm_scroll == 1 ) ? 0 : foreground.rdata1;
                new_background = ( tm_scroll == 1 ) ? 7h40 : background.rdata1;
                tm_active = 11;
            }
            case 11: {
                // Setup addresses for the next column
                tile.addr1 = ( x_cursor - 1 ) + ( y_cursor * 42 );
                foreground.addr1 = ( x_cursor - 1 ) + ( y_cursor * 42 );
                background.addr1 = ( x_cursor - 1 ) + ( y_cursor * 42 );
                tm_active = 12;
            }
            case 12: {
                // Save the next column
                scroll_tile = tile.rdata1;
                scroll_foreground = foreground.rdata1;
                scroll_background = background.rdata1;
                tm_active = 13;
            }
            case 13: {
                // Write into the present column
                tile.addr1 = ( x_cursor ) + ( y_cursor * 42 );
                tile.wdata1 = scroll_tile;
                tile.wenable1 = 1;
                foreground.addr1 = ( x_cursor ) + ( y_cursor * 42 );
                foreground.wdata1 = scroll_foreground;
                foreground.wenable1 = 1;
                background.addr1 = ( x_cursor ) + ( y_cursor * 42 );
                background.wdata1 = scroll_background;
                background.wenable1 = 1;
                tm_active = 14;
            }
            case 14: {
                if( x_cursor == 1 ) {
                    // At the last, but one column
                    // Write into the column
                    // Move to the next row
                    tile.addr1 = ( 0 ) + ( y_cursor * 42 );
                    tile.wdata1 = new_tile;
                    tile.wenable1 = 1;
                    foreground.addr1 = ( 0 ) + ( y_cursor * 42 );
                    foreground.wdata1 = new_foreground;
                    foreground.wenable1 = 1;
                    background.addr1 = ( 0 ) + ( y_cursor * 42 );
                    background.wdata1 = new_background;
                    background.wenable1 = 1;
                    if( y_cursor == 31 ) {
                        // FINISHED
                        tm_active = 0;
                    } else {
                        x_cursor = 41;
                        y_cursor = y_cursor + 1;
                        tm_active = 9;
                    }
                } else {
                    // Move to the next column
                    x_cursor = x_cursor - 1;
                    tm_active = 11;
                }
            }

            case 15: {
                // Setup for scroll/wrap UP
                x_cursor = 0;
                y_cursor = 0;
                tm_active = 16;
            }
            case 16: {
                // Setup addresses for the first row
                tile.addr1 = x_cursor + ( 0 * 42 );
                foreground.addr1 = x_cursor + ( 0 * 42 );
                background.addr1 = x_cursor + ( 0 * 42 );
                tm_active = 17;
            }
            case 17: {
                // Save the last row
                new_tile = ( tm_scroll == 1 ) ? 0 : tile.rdata1;
                new_foreground = ( tm_scroll == 1 ) ? 0 : foreground.rdata1;
                new_background = ( tm_scroll == 1 ) ? 7h40 : background.rdata1;
                tm_active = 18;
            }
            case 18: {
                // Setup addresses for the next row
                tile.addr1 = ( x_cursor  ) + ( y_cursor * 42 ) + 42;
                foreground.addr1 = ( x_cursor  ) + ( y_cursor * 42 ) + 42;
                background.addr1 = ( x_cursor  ) + ( y_cursor * 42 ) + 42;
                tm_active = 19;
            }
            case 19: {
                // Save the next row
                scroll_tile = tile.rdata1;
                scroll_foreground = foreground.rdata1;
                scroll_background = background.rdata1;
                tm_active = 20;
            }
            case 20: {
                // Write into the present row
                tile.addr1 = ( x_cursor ) + ( y_cursor * 42 );
                tile.wdata1 = scroll_tile;
                tile.wenable1 = 1;
                foreground.addr1 = ( x_cursor ) + ( y_cursor * 42 );
                foreground.wdata1 = scroll_foreground;
                foreground.wenable1 = 1;
                background.addr1 = ( x_cursor ) + ( y_cursor * 42 );
                background.wdata1 = scroll_background;
                background.wenable1 = 1;
                tm_active = 21;
            }
            case 21: {
                if( y_cursor == 30 ) {
                    // At the last, but one row
                    // Write into the last row
                    // Move to the next column
                    tile.addr1 = ( x_cursor ) + ( 31 * 42 );
                    tile.wdata1 = new_tile;
                    tile.wenable1 = 1;
                    foreground.addr1 = ( x_cursor ) + ( 31 * 42 );
                    foreground.wdata1 = new_foreground;
                    foreground.wenable1 = 1;
                    background.addr1 = ( x_cursor ) + ( 31 * 42 );
                    background.wdata1 = new_background;
                    background.wenable1 = 1;
                    if( x_cursor == 41 ) {
                        // FINISHED
                        tm_active = 0;
                    } else {
                        x_cursor = x_cursor + 1;
                        y_cursor = 0;
                        tm_active = 16;
                    }
                } else {
                    // Move to the next row
                    y_cursor = y_cursor + 1;
                    tm_active = 18;
                }
            }

            case 22: {
                // Setup for scroll/wrap DOWN
                x_cursor = 0;
                y_cursor = 31;
                tm_active = 23;
            }
            case 23: {
                // Setup addresses for the last row
                tile.addr1 = x_cursor + ( 31 * 42 );
                foreground.addr1 = x_cursor + ( 31 * 42 );
                background.addr1 = x_cursor + ( 31 * 42 );
                tm_active = 24;
            }
            case 24: {
                // Save the last row
                new_tile = ( tm_scroll == 1 ) ? 0 : tile.rdata1;
                new_foreground = ( tm_scroll == 1 ) ? 0 : foreground.rdata1;
                new_background = ( tm_scroll == 1 ) ? 7h40 : background.rdata1;
                tm_active = 25;
            }
            case 25: {
                // Setup addresses for the next row
                tile.addr1 = ( x_cursor  ) + ( y_cursor * 42 ) - 42;
                foreground.addr1 = ( x_cursor  ) + ( y_cursor * 42 ) - 42;
                background.addr1 = ( x_cursor  ) + ( y_cursor * 42 ) - 42;
                tm_active = 26;
            }
            case 26: {
                // Save the next row
                scroll_tile = tile.rdata1;
                scroll_foreground = foreground.rdata1;
                scroll_background = background.rdata1;
                tm_active = 27;
            }
            case 27: {
                // Write into the present row
                tile.addr1 = ( x_cursor ) + ( y_cursor * 42 );
                tile.wdata1 = scroll_tile;
                tile.wenable1 = 1;
                foreground.addr1 = ( x_cursor ) + ( y_cursor * 42 );
                foreground.wdata1 = scroll_foreground;
                foreground.wenable1 = 1;
                background.addr1 = ( x_cursor ) + ( y_cursor * 42 );
                background.wdata1 = scroll_background;
                background.wenable1 = 1;
                tm_active = 28;
            }
            case 28: {
                if( y_cursor == 1 ) {
                    // At the last, but one row
                    // Write into the last row
                    // Move to the next column
                    tile.addr1 = ( x_cursor ) + ( 0 * 42 );
                    tile.wdata1 = new_tile;
                    tile.wenable1 = 1;
                    foreground.addr1 = ( x_cursor ) + ( 0 * 42 );
                    foreground.wdata1 = new_foreground;
                    foreground.wenable1 = 1;
                    background.addr1 = ( x_cursor ) + ( 0 * 42 );
                    background.wdata1 = new_background;
                    background.wenable1 = 1;
                    if( x_cursor == 41 ) {
                        // FINISHED
                        tm_active = 0;
                    } else {
                        x_cursor = x_cursor + 1;
                        y_cursor = 0;
                        tm_active = 23;
                    }
                } else {
                    // Move to the next row
                    y_cursor = y_cursor - 1;
                    tm_active = 26;
                }
            }

            case 29: {
                // tmcs!
                x_cursor = 0;
                y_cursor = 0;
                tm_offset_x = 0;
                tm_offset_y = 0;
                tm_active = 30;
            }
            case 30: {
                tile.addr1 = ( x_cursor  ) + ( y_cursor * 42 ) - 42;
                tile.wdata1 = 0;
                tile.wenable1 = 1;
                foreground.addr1 = ( x_cursor  ) + ( y_cursor * 42 ) - 42;
                foreground.wdata1 = 0;
                foreground.wenable1 = 1;
                background.addr1 = ( x_cursor  ) + ( y_cursor * 42 ) - 42;
                background.wdata1 = 64;
                background.wenable1 = 1;
                x_cursor = ( x_cursor == 41 ) ? 0 : x_cursor + 1;
                y_cursor = ( x_cursor == 41 ) ? y_cursor + 1 : y_cursor;
                tm_active = ( x_cursor == 41 ) && ( y_cursor == 31 ) ? 0 : 30;
            }

            default: { tm_active = 0; }
        }
