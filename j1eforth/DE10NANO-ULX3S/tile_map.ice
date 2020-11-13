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
    input   uint5   tm_scrollwrap,
    output  uint5   tm_lastaction,
    output  uint1   tm_active
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
    uint11  xtmpos :=  ( pix_active ? pix_x + ( 11d18 + {{6{tm_offset_x[4,1]}}, tm_offset_x} ) : pix_x + ( 11d16 + {{6{tm_offset_x[4,1]}}, tm_offset_x} ) ) >> 4;
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

    always {
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
    }

    // Default to 0,0 and transparent
    tiles.addr1 = 0; tiles.wdata1 = { 1b1, 6b0, 6b0, 5b0 };

    while(1) {
        // Perform Scrolling/Wrapping
        if( ( tm_scrollwrap >= 0 ) && ( tm_scrollwrap <=8 ) ) {
            switch( ( tm_scrollwrap - 1 ) & 3 ) {
                // LEFT
                case 0: {
                    if( tm_offset_x == 15 ) {
                        tm_scroll = ( tm_scrollwrap == 1 ) ? 1 : 0;
                        tm_lastaction = tm_scrollwrap;
                        x_cursor = 0;
                        y_cursor = 0;
                        y_cursor_addr = 0;
                        tm_offset_x = 0;
                        tm_active = 1;

                        ++:

                        while( y_cursor < 32 ) {
                            x_cursor = 0;
                            // Setup addresses for the first column
                            tiles.addr1 = y_cursor_addr;
                            ++:
                            // Save the first column
                            new_tile = ( tm_scroll == 1 ) ? { 1b1, 6b0, 6b0, 5b0 } : tiles.rdata1;
                            while( x_cursor < 41 ) {
                                // Setup addresses for the next column
                                tiles.addr1 = ( x_cursor + 1 ) + y_cursor_addr;
                                ++:
                                scroll_tile = tiles.rdata1;
                                ++:
                                tiles.addr1 = ( x_cursor ) + y_cursor_addr;
                                tiles.wdata1 = scroll_tile;
                                tiles.wenable1 = 1;

                                x_cursor = x_cursor + 1;
                            }
                            tiles.addr1 = ( 41 ) + y_cursor_addr;
                            tiles.wdata1 = new_tile;
                            tiles.wenable1 = 1;

                            y_cursor = y_cursor + 1;
                            y_cursor_addr = y_cursor_addr + 42;
                        }
                        tm_active = 0;
                    } else {
                        tm_offset_x = tm_offset_x + 1;
                        tm_lastaction = 0;
                    }
                }

                // UP
                case 1: {
                    if( tm_offset_y == 15 ) {
                        tm_scroll = ( tm_scrollwrap == 2 ) ? 1 : 0;
                        tm_lastaction = tm_scrollwrap;
                        x_cursor = 0;
                        y_cursor = 0;
                        y_cursor_addr = 0;
                        tm_offset_y = 0;
                        tm_active = 1;

                        ++:

                        while( x_cursor < 42 ) {
                            y_cursor = 0;
                            // Setup addresses for the first row
                            tiles.addr1 = x_cursor;
                            ++:
                            // Save the first row
                            new_tile = ( tm_scroll == 1 ) ? { 1b1, 6b0, 6b0, 5b0 } : tiles.rdata1;
                            while( y_cursor < 31 ) {
                                // Setup addresses for the next row
                                tiles.addr1 = x_cursor + y_cursor_addr + 42;
                                ++:
                                // Save the next row
                                scroll_tile = tiles.rdata1;
                                ++:
                                // Setup addresses for the present row and write the next row to it
                                tiles.addr1 = x_cursor + y_cursor_addr;
                                tiles.wdata1 = scroll_tile;
                                tiles.wenable1 = 1;

                                y_cursor = y_cursor + 1;
                                y_cursor_addr = y_cursor_addr + 42;
                            }
                            // Copy the last row or blank
                            tiles.addr1 = x_cursor + 1302;
                            tiles.wdata1 = new_tile;
                            tiles.wenable1 = 1;

                            x_cursor = x_cursor + 1;
                        }
                        tm_active = 0;
                    } else {
                        tm_offset_y = tm_offset_y + 1;
                        tm_lastaction = 0;
                    }
                }

                // RIGHT
                case 2: {
                    if( tm_offset_x == -15 ) {
                        tm_scroll = ( tm_scrollwrap == 3 ) ? 1 : 0;
                        tm_lastaction = tm_scrollwrap;
                        x_cursor = 0;
                        y_cursor = 0;
                        y_cursor_addr = 0;
                        tm_offset_x = 0;
                        tm_active = 1;

                        ++:

                        while( y_cursor < 32 ) {
                            x_cursor = 41;
                            // Setup addresses for the last column
                            tiles.addr1 = 41 + y_cursor_addr;
                            ++:
                            // Save the last column
                            new_tile = ( tm_scroll == 1 ) ? { 1b1, 6b0, 6b0, 5b0 } : tiles.rdata1;
                            while( x_cursor > 0 ) {
                                // Setup addresses for the next column
                                tiles.addr1 = ( x_cursor + 1 ) + y_cursor_addr;
                                ++:
                                scroll_tile = tiles.rdata1;
                                ++:
                                tiles.addr1 = ( x_cursor ) + y_cursor_addr;
                                tiles.wdata1 = scroll_tile;
                                tiles.wenable1 = 1;

                                x_cursor = x_cursor - 1;
                            }
                            tiles.addr1 = ( 0 ) + y_cursor_addr;
                            tiles.wdata1 = new_tile;
                            tiles.wenable1 = 1;

                            y_cursor = y_cursor + 1;
                            y_cursor_addr = y_cursor_addr + 42;
                        }
                        tm_active = 0;
                    } else {
                        tm_offset_x = tm_offset_x - 1;
                        tm_lastaction = 0;
                    }
                }

                // DOWN
                case 3: {
                    if( tm_offset_y == -15 ) {
                        tm_scroll = ( tm_scrollwrap == 4 ) ? 1 : 0;
                        tm_lastaction = tm_scrollwrap;
                        x_cursor = 0;
                        y_cursor = 31;
                        y_cursor_addr = 1302;
                        tm_offset_y = 0;
                        tm_active = 1;

                        ++:

                        while( x_cursor < 42 ) {
                            y_cursor = 0;
                            // Setup addresses for the last row
                            tiles.addr1 = x_cursor + 1302;
                            ++:
                            // Save the last row
                            new_tile = ( tm_scroll == 1 ) ? { 1b1, 6b0, 6b0, 5b0 } : tiles.rdata1;

                            while( y_cursor > 0 ) {
                                // Setup addresses for the previous row
                                tiles.addr1 = x_cursor + y_cursor_addr - 42;
                                ++:
                                // Save the next row
                                scroll_tile = tiles.rdata1;
                                ++:
                                // Setup addresses for the present row and write the next row to it
                                tiles.addr1 = x_cursor + y_cursor_addr;
                                tiles.wdata1 = scroll_tile;
                                tiles.wenable1 = 1;

                                y_cursor = y_cursor - 1;
                                y_cursor_addr = y_cursor_addr - 42;
                            }
                            // Copy the last row or blank
                            tiles.addr1 = x_cursor;
                            tiles.wdata1 = new_tile;
                            tiles.wenable1 = 1;

                            x_cursor = x_cursor - 1;
                        }
                        tm_active = 0;
                    } else {
                        tm_offset_y = tm_offset_y - 1;
                        tm_lastaction = 0;
                    }
                }
            }
        } else {
            // CLEAR
            if( tm_scrollwrap == 9 ) {
                tmcsaddr = 0;
                tiles.wdata1 = { 1b1, 6b0, 6b0, 5b0 };

                tm_offset_x = 0;
                tm_offset_y = 0;
                tm_active = 1;

                ++:

                while( tmcsaddr < 1344 ) {
                    tiles.addr1 = tmcsaddr;
                    tmcsaddr = tmcsaddr + 1;
                }

                tm_active = 0;
            }
        }
    }
}
