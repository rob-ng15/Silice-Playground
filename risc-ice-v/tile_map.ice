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

    // For scrolling/wrapping
    input   uint4   tm_scrollwrap,
    output  uint4   tm_lastaction,
    output  uint3   tm_active
) <autorun> {
    // Tile Map 32 x 16 x 16
    simple_dualport_bram uint16 tiles16x16[ 512 ] = { 0, pad(0) };

    // 42 x 32 tile map, allows for pixel scrolling with border { 7 bits background, 6 bits foreground, 5 bits tile number }
    // Setting background to 40 (ALPHA) allows the bitmap/background to show through
    simple_dualport_bram uint18 tiles[1344] = { 18b100000000000000000, pad(18b100000000000000000) };
    simple_dualport_bram uint18 tiles_copy[1344] = { 18b100000000000000000, pad(18b100000000000000000) };

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
    tiles.wenable1 := 1;
    tiles_copy.wenable1 := 1;

    // Setup the reading and writing of the tiles16x16
    tiles16x16.addr0 :=  tilemapentry(tiles.rdata0).tilenumber * 16 + yintm;
    tiles16x16.addr1 := tile_writer_tile * 16 + tile_writer_line;
    tiles16x16.wdata1 := tile_writer_bitmap;
    tiles16x16.wenable1 := 1;

    // RENDER - Default to transparent
    tilemap_display := pix_active && ( ( tmpixel ) || ( ~tilemapentry(tiles.rdata0).alpha ) );
    pix_red := tmpixel ? tiles.rdata0[9,2] : tiles.rdata0[15,2];
    pix_green := tmpixel ? tiles.rdata0[7,2] : tiles.rdata0[13,2];
    pix_blue := tmpixel ?  tiles.rdata0[5,2] : tiles.rdata0[11,2];

    // Default to 0,0 and transparent
    tiles.addr1 = 0; tiles.wdata1 = { 1b1, 6b0, 6b0, 5b0 };
    tiles_copy.addr1 = 0; tiles_copy.wdata1 = { 1b1, 6b0, 6b0, 5b0 };

    while(1) {
        // Write character to the tilemap
        if( tm_write == 1 ) {
            tiles.addr1 = tm_x + tm_y * 42;
            tiles.wdata1 = { tm_background, tm_foreground, tm_character };
            tiles_copy.addr1 = tm_x + tm_y * 42;
            tiles_copy.wdata1 = { tm_background, tm_foreground, tm_character };
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
                            tm_active = 3;
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
                            tm_active = 2;
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
                            tm_active = 4;
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
                            tm_active = 3;
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
                            tm_active = 2;
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
                            tm_active = 4;
                        } else {
                            tm_offset_y = tm_offset_y - 1;
                            tm_lastaction = 0;
                        }
                    }

                    // CLEAR
                    case 9: {
                        tm_active = 5;
                        tm_lastaction = 9;
                    }
                }
            }

            // SCROLL/WRAP LEFT
            case 1: {
                y_cursor = 0;
                y_cursor_addr = 0;
                ++:
                while( y_cursor < 32 ) {
                    x_cursor = 0;
                    tiles_copy.addr0 = y_cursor_addr;
                    ++:
                    new_tile = ( tm_scroll == 1 ) ? { 1b1, 6b0, 6b0, 5b0 } : tiles_copy.rdata0;
                    ++:
                    while( x_cursor < 42 ) {
                        tiles_copy.addr0 = ( x_cursor + 1 ) + y_cursor_addr;
                        ++:
                        scroll_tile = tiles_copy.rdata0;
                        ++:
                        tiles.addr1 = ( x_cursor ) + y_cursor_addr;
                        tiles.wdata1 = scroll_tile;
                        tiles_copy.addr1 = ( x_cursor ) + y_cursor_addr;
                        tiles_copy.wdata1 = scroll_tile;
                        x_cursor = x_cursor + 1;
                    }
                    ++:
                    tiles.addr1 = ( 41 ) + y_cursor_addr;
                    tiles.wdata1 = new_tile;
                    tiles_copy.addr1 = ( 41 ) + y_cursor_addr;
                    tiles_copy.wdata1 = new_tile;
                    y_cursor = y_cursor + 1;
                    y_cursor_addr = y_cursor_addr + 42;
                }
                ++:
                tm_offset_x = 0;
                tm_active = 0;
            }

            // SCROLL/WRAP RIGHT
            case 2: {
                y_cursor = 0;
                y_cursor_addr = 0;
                ++:
                while( y_cursor < 32 ) {
                    x_cursor = 41;
                    tiles_copy.addr0 = 41 + y_cursor_addr;
                    ++:
                    new_tile = ( tm_scroll == 1 ) ? { 1b1, 6b0, 6b0, 5b0 } : tiles_copy.rdata0;
                    ++:
                    while( x_cursor > 0 ) {
                        tiles_copy.addr0 = ( x_cursor - 1 ) + y_cursor_addr;
                        ++:
                        scroll_tile = tiles_copy.rdata0;
                        ++:
                        tiles.addr1 = ( x_cursor ) + y_cursor_addr;
                        tiles.wdata1 = scroll_tile;
                        tiles_copy.addr1 = ( x_cursor ) + y_cursor_addr;
                        tiles_copy.wdata1 = scroll_tile;
                        x_cursor = x_cursor - 1;
                    }
                    ++:
                    tiles.addr1 = y_cursor_addr;
                    tiles.wdata1 = new_tile;
                    tiles_copy.addr1 = y_cursor_addr;
                    tiles_copy.wdata1 = new_tile;
                    y_cursor = y_cursor + 1;
                    y_cursor_addr = y_cursor_addr + 42;
                }
                ++:
                tm_offset_x = 0;
                tm_active = 0;
            }

            // SCROLL/WRAP UP
            case 3: {
                x_cursor = 0;
                ++:
                while( x_cursor < 42 ) {
                    y_cursor = 0;
                    y_cursor_addr = 0;
                    tiles_copy.addr0 = x_cursor;
                    ++:
                    new_tile = ( tm_scroll == 1 ) ? { 1b1, 6b0, 6b0, 5b0 } : tiles_copy.rdata0;
                    ++:
                    while( y_cursor < 31 ) {
                        tiles_copy.addr0 = x_cursor + y_cursor_addr + 42;
                        ++:
                        scroll_tile = tiles_copy.rdata0;
                        ++:
                        tiles.addr1 = ( x_cursor ) + y_cursor_addr;
                        tiles.wdata1 = scroll_tile;
                        tiles_copy.addr1 = ( x_cursor ) + y_cursor_addr;
                        tiles_copy.wdata1 = scroll_tile;
                        y_cursor = y_cursor + 1;
                        y_cursor_addr = y_cursor_addr + 42;
                    }
                    tiles.addr1 = x_cursor + 1302;
                    tiles.wdata1 = new_tile;
                    tiles_copy.addr1 = x_cursor + 1302;
                    tiles_copy.wdata1 = new_tile;
                    x_cursor = x_cursor + 1;
                }
                ++:
                tm_offset_y = 0;
                tm_active = 0;
            }

            // SCROLL/WRAP DOWN
            case 4: {
                x_cursor = 0;
                ++:
                while( x_cursor < 42 ) {
                    y_cursor = 0;
                    y_cursor_addr = 1302;
                    tiles_copy.addr0 = x_cursor;
                    ++:
                    new_tile = ( tm_scroll == 1 ) ? { 1b1, 6b0, 6b0, 5b0 } : tiles_copy.rdata0;
                    ++:
                    while( y_cursor > 0 ) {
                        tiles_copy.addr0 = x_cursor + y_cursor_addr - 42;
                        ++:
                        scroll_tile = tiles_copy.rdata0;
                        ++:
                        tiles.addr1 = ( x_cursor ) + y_cursor_addr;
                        tiles.wdata1 = scroll_tile;
                        tiles_copy.addr1 = ( x_cursor ) + y_cursor_addr;
                        tiles_copy.wdata1 = scroll_tile;
                        y_cursor = y_cursor - 1;
                        y_cursor_addr = y_cursor_addr - 42;
                    }
                    tiles.addr1 = x_cursor;
                    tiles.wdata1 = new_tile;
                    tiles_copy.addr1 = x_cursor;
                    tiles_copy.wdata1 = new_tile;
                    x_cursor = x_cursor + 1;
                }
                ++:
                tm_offset_y = 0;
                tm_active = 0;
            }

            // CLEAR
            case 5: {
                tmcsaddr = 0;
                tiles.wdata1 = { 1b1, 6b0, 6b0, 5b0 };
                tiles_copy.wdata1 = { 1b1, 6b0, 6b0, 5b0 };
                ++:
                while( tmcsaddr < 1344 ) {
                    tiles.addr1 = tmcsaddr;
                    tiles_copy.addr1 = tmcsaddr;
                    tmcsaddr = tmcsaddr + 1;
                }
                ++:

                tm_offset_x = 0;
                tm_offset_y = 0;
                tm_active = 0;
            }
        }
    }
}
