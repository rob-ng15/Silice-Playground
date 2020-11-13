bitfield tilemapentry {
    uint1   alpha,
    uint6   background,
    uint6   foreground,
    uint5   tilenumber
}

algorithm tilemap(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,
    output! uint1   tilemap_display,

    // Set TM at x, y, character with foreground and background
    input uint6 tm_x,
    input uint6 tm_y,
    input uint5 tm_character,
    input uint6 tm_foreground,
    input uint7 tm_background,
    input uint1 tm_write,

    // For setting tile bitmaps
    input   uint5   tile_writer_tile,
    input   uint4   tile_writer_line,
    input   uint16  tile_writer_bitmap,
    input   uint1   tile_writer_write,

    // For scrolling/wrapping
    input   uint4   tm_scrollwrap,
    output  uint4   tm_lastaction,
    output  uint8   tm_active
) <autorun> {
    // Tile Map 32 x 16 x 16
    dualport_bram uint16 tiles16x16[ 512 ] = { 0, pad(0) };

    // 42 x 32 tile map, allows for pixel scrolling with border
    // Setting background to 40 (ALPHA) allows the bitmap/background to show through
    dualport_bram uint18 tiles[1344] = { 18b100000000000000000, pad(18b100000000000000000) };

    // Scroll position - -15 to 0 to 15
    // -15 or 15 will trigger appropriate scroll when next moved in that direction
    int5    tm_offset_x = 0;
    int5    tm_offset_y = 0;

    // Scroller/Wrapper storage
    uint1   tm_scroll = uninitialized;
    uint6   x_cursor = uninitialized;
    uint6   y_cursor = uninitialized;
    uint11  y_cursor_addr = uninitialized;
    uint18  new_tile = uninitialized;
    uint18  scroll_tile = uninitialized;

    // CS address
    uint11  tmcsaddr = uninitialized;

    // Character position on the screen x 0-41, y 0-31 * 42 ( fetch it two pixels ahead of the actual x pixel, so it is always ready )
    // Adjust for the offsets, effective 0 point margin is ( 1,1 ) to ( 40,30 ) with a 1 tile border
    uint11  xtmpos :=  ( pix_active ? pix_x + ( 11d18 + {{6{tm_offset_x[4,1]}}, tm_offset_x} ) : ( 11d16 + {{6{tm_offset_x[4,1]}}, tm_offset_x} ) ) >> 4;
    uint11  ytmpos := (( pix_vblank ? ( 11d16 + {{6{tm_offset_y[4,1]}}, tm_offset_y} ) : pix_y + ( 11d16 + {{6{tm_offset_y[4,1]}}, tm_offset_y} ) ) >> 4) * 42;

    // Derive the x and y coordinate within the current 16x16 tilemap block x 0-7, y 0-15
    // Needs adjusting for the offsets
    uint4   xintm := { 1b0, (pix_x) & 15 } + tm_offset_x;
    uint4   yintm := { 1b0, (pix_y) & 15 } + tm_offset_y;

    // Derive the actual pixel in the current character
    uint1   tmpixel := tiles16x16.rdata0[15 - xintm,1];

    // Set up reading of the tilemap
    tiles.addr0 := xtmpos + ytmpos;
    tiles.wenable0 := 0;
    tiles.wenable1 := 0;

    // Setup the reading and writing of the tiles16x16
    tiles16x16.addr0 :=  tilemapentry(tiles.rdata0).tilenumber * 16 + yintm;
    tiles16x16.wenable0 := 0;
    tiles16x16.wenable1 := 1;

    // Default to transparent
    tilemap_display := pix_active && (( tmpixel ) || ( ~tilemapentry(tiles.rdata0).alpha ));

    // Default to 0,0 and transparent
    tiles.addr1 = 0; tiles.wdata1 = { 1b1, 6b0, 6b0, 5b0 };

    while(1) {
        // Render the tilemap
        if( tilemap_display ) {
            // Determine if background or foreground
            pix_red = tmpixel ? tiles.rdata0[9,2] : tiles.rdata0[15,2];
            pix_green = tmpixel ? tiles.rdata0[7,2] : tiles.rdata0[13,2];
            pix_blue = tmpixel ?  tiles.rdata0[5,2] : tiles.rdata0[11,2];
        }

        // Update tiles
        if( tile_writer_write ) {
            tiles16x16.addr1 = tile_writer_tile * 16 + tile_writer_line;
            tiles16x16.wdata1 = tile_writer_bitmap;
        }

        // Write character to the tilemap
        switch( tm_write ) {
            case 1: {
                tiles.addr1 = tm_x + tm_y * 42;
                tiles.wdata1 = { tm_background, tm_foreground, tm_character };
                tiles.wenable1 = 1;
            }
        }

        switch( tm_active ) {
            case 0: {
                // Perform Scrolling/Wrapping
                switch( tm_scrollwrap ) {
                    // LEFT
                    case 1: {
                        if( tm_offset_x == 15 ) {
                            tm_scroll = 1;
                            tm_lastaction = tm_scrollwrap;
                            tm_active = 1;
                        } else {
                            tm_offset_x = tm_offset_x + 1;
                            tm_lastaction = 0;
                        }
                    }

                    // UP
                    case 2: {
                        if( tm_offset_y == 15 ) {
                            tm_scroll = 1;
                            tm_lastaction = tm_scrollwrap;
                            tm_active = 41;
                        } else {
                            tm_offset_y = tm_offset_y + 1;
                            tm_lastaction = 0;
                        }
                    }

                    // RIGHT
                    case 3: {
                        if( tm_offset_x == -15 ) {
                            tm_scroll = 1;
                            tm_lastaction = tm_scrollwrap;
                            tm_active = 21;
                        } else {
                            tm_offset_x = tm_offset_x - 1;
                            tm_lastaction = 0;
                        }
                    }

                    // DOWN
                    case 4: {
                        if( tm_offset_y == -15 ) {
                            tm_scroll = 1;
                            tm_lastaction = tm_scrollwrap;
                            tm_active = 61;
                        } else {
                            tm_offset_y = tm_offset_y - 1;
                            tm_lastaction = 0;
                        }
                    }
                    // LEFT
                    case 5: {
                        if( tm_offset_x == 15 ) {
                            tm_scroll = 0;
                            tm_lastaction = tm_scrollwrap;
                            tm_active = 1;
                        } else {
                            tm_offset_x = tm_offset_x + 1;
                            tm_lastaction = 0;
                        }
                    }

                    // UP
                    case 6: {
                        if( tm_offset_y == 15 ) {
                            tm_scroll = 0;
                            tm_lastaction = tm_scrollwrap;
                            tm_active = 41;
                        } else {
                            tm_offset_y = tm_offset_y + 1;
                            tm_lastaction = 0;
                        }
                    }

                    // RIGHT
                    case 7: {
                        if( tm_offset_x == -15 ) {
                            tm_scroll = 0;
                            tm_lastaction = tm_scrollwrap;
                            tm_active = 21;
                        } else {
                            tm_offset_x = tm_offset_x - 1;
                            tm_lastaction = 0;
                        }
                    }

                    // DOWN
                    case 8: {
                        if( tm_offset_y == -15 ) {
                            tm_scroll = 0;
                            tm_lastaction = tm_scrollwrap;
                            tm_active = 61;
                        } else {
                            tm_offset_y = tm_offset_y - 1;
                            tm_lastaction = 0;
                        }
                    }

                    // CLEAR
                    case 9: {
                        tm_active = 81;
                    }
                }
            }

            // SCROLL/WRAP LEFT
            case 1: {
                y_cursor = 0;
                y_cursor_addr = 0;

                tm_active = 2;
            }
            case 2: {
                // New row
                x_cursor = 0;
                tiles.addr1 = y_cursor_addr;

                tm_active = 3;
            }
            case 3: {
                new_tile = ( tm_scroll == 1 ) ? { 1b1, 6b0, 6b0, 5b0 } : tiles.rdata1;

                tm_active = 4;
            }
            case 4: {
                tiles.addr1 = ( x_cursor + 1 ) + y_cursor_addr;

                tm_active = 5;
            }
            case 5: {
                scroll_tile = tiles.rdata1;

                tm_active = 6;
            }
            case 6: {
                tiles.addr1 = ( x_cursor ) + y_cursor_addr;
                tiles.wdata1 = scroll_tile;
                tiles.wenable1 = 1;

                tm_active = 7;
            }
            case 7: {
                x_cursor = x_cursor + 1;

                tm_active = 8;
            }
            case 8: {
                tm_active = ( x_cursor < 41 ) ? 4 : 9;
            }
            case 9: {
                tiles.addr1 = ( 41 ) + y_cursor_addr;
                tiles.wdata1 = new_tile;
                tiles.wenable1 = 1;

                y_cursor = y_cursor + 1;
                y_cursor_addr = y_cursor_addr + 42;

                tm_active = 10;
            }
            case 10: {
                tm_active = ( y_cursor < 32 ) ? 2 : 11;
            }
            case 11: {
                tm_offset_x = 0;
                tm_active = 0;
            }

            // SCROLL/WRAP RIGHT
            case 21: {
                y_cursor = 0;
                y_cursor_addr = 0;

                tm_active = 22;
            }
            case 22: {
                // New row
                x_cursor = 41;
                tiles.addr1 = 41 + y_cursor_addr;

                tm_active = 23;
            }
            case 23: {
                new_tile = ( tm_scroll == 1 ) ? { 1b1, 6b0, 6b0, 5b0 } : tiles.rdata1;

                tm_active = 24;
            }
            case 24: {
                tiles.addr1 = ( x_cursor - 1 ) + y_cursor_addr;

                tm_active = 25;
            }
            case 25: {
                scroll_tile = tiles.rdata1;

                tm_active = 26;
            }
            case 26: {
                tiles.addr1 = ( x_cursor ) + y_cursor_addr;
                tiles.wdata1 = scroll_tile;
                tiles.wenable1 = 1;

                tm_active = 27;
            }
            case 27: {
                x_cursor = x_cursor - 1;

                tm_active = 28;
            }
            case 28: {
                tm_active = ( x_cursor > 0 ) ? 24 : 29;
            }

            case 29: {
                tiles.addr1 = y_cursor_addr;
                tiles.wdata1 = new_tile;
                tiles.wenable1 = 1;

                y_cursor = y_cursor + 1;
                y_cursor_addr = y_cursor_addr + 42;

                tm_active = 30;
            }
            case 30: {
                tm_active = ( y_cursor < 32 ) ? 32 : 31;
            }

            case 31: {
                tm_offset_x = 0;
                tm_active = 0;
            }

            // SCROLL/WRAP UP
            case 41: {
                x_cursor = 0;

                tm_active = 42;
            }
            case 42: {
                // New Column
                y_cursor = 0;
                y_cursor_addr = 0;
                tiles.addr1 = x_cursor;

                tm_active = 43;
            }
            case 43: {
                new_tile = ( tm_scroll == 1 ) ? { 1b1, 6b0, 6b0, 5b0 } : tiles.rdata1;

                tm_active = 44;
            }
            case 44: {
                tiles.addr1 = x_cursor + y_cursor_addr + 42;

                tm_active = 45;
            }
            case 45: {
                scroll_tile = tiles.rdata1;

                tm_active = 46;
            }
            case 46: {
                tiles.addr1 = ( x_cursor ) + y_cursor_addr;
                tiles.wdata1 = scroll_tile;
                tiles.wenable1 = 1;

                tm_active = 47;
            }
            case 47: {
                y_cursor = y_cursor + 1;
                y_cursor_addr = y_cursor_addr + 42;

                tm_active = 48;
            }
            case 48: {
                tm_active = ( y_cursor < 31 ) ? 44 : 49;
            }
            case 49: {
                tiles.addr1 = x_cursor + 1302;
                tiles.wdata1 = new_tile;
                tiles.wenable1 = 1;

                x_cursor = x_cursor + 1;

                tm_active = 50;
            }
            case 50: {
                tm_active = ( x_cursor < 42 ) ? 42 : 51;
            }
            case 51: {
                tm_offset_y = 0;
                tm_active = 0;
            }

            // SCROLL/WRAP DOWN
            case 61: {
                x_cursor = 0;

                tm_active = 62;
            }
            case 62: {
                // New Column
                y_cursor = 31;
                y_cursor_addr = 1302;
                tiles.addr1 = x_cursor;

                tm_active = 63;
            }
            case 63: {
                new_tile = ( tm_scroll == 1 ) ? { 1b1, 6b0, 6b0, 5b0 } : tiles.rdata1;

                tm_active = 64;
            }
            case 64: {
                tiles.addr1 = x_cursor + y_cursor_addr - 42;

                tm_active = 65;
            }
            case 65: {
                scroll_tile = tiles.rdata1;

                tm_active = 66;
            }
            case 66: {
                tiles.addr1 = ( x_cursor ) + y_cursor_addr;
                tiles.wdata1 = scroll_tile;
                tiles.wenable1 = 1;

                tm_active = 67;
            }
            case 67: {
                y_cursor = y_cursor - 1;
                y_cursor_addr = y_cursor_addr - 42;

                tm_active = 68;
            }
            case 68: {
                tm_active = ( y_cursor > 0 ) ? 64 : 69;
            }
            case 69: {
                tiles.addr1 = x_cursor;
                tiles.wdata1 = new_tile;
                tiles.wenable1 = 1;

                x_cursor = x_cursor + 1;

                tm_active = 70;
            }
            case 70: {
                tm_active = ( x_cursor < 42 ) ? 62 : 71;
            }
            case 71: {
                tm_offset_y = 0;
                tm_active = 0;
            }

            // CLEAR
            case 81: {
                tmcsaddr = 0;
                tiles.wdata1 = { 1b1, 6b0, 6b0, 5b0 };

                tm_active = 82;
            }
            case 82: {
                tiles.addr1 = tmcsaddr;
                tiles.wenable1 = 1;
                tmcsaddr = tmcsaddr + 1;
                tm_active = 83;
            }
            case 83: {
                tm_active = ( tmcsaddr < 1344 ) ? 82: 84;
            }
            case 84: {
                tm_offset_x = 0;
                tm_offset_y = 0;
                tm_active = 0;
            }
        }
    }
}
