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
    output  uint6   tm_active
) <autorun> {
    // Tile Map 32 x 16 x 16
    dualport_bram uint16 tiles16x16[ 512 ] = { 0, pad(0) };

    // 42 x 32 tile map, allows for pixel scrolling with border
    // Setting background to 40 (ALPHA) allows the bitmap/background to show through
    dualport_bram uint5 tile[1344] = uninitialized;
    dualport_bram uint6 foreground[1344] = uninitialized;
    dualport_bram uint7 background[1344] = { 7h40, pad(7h40) };

    // Scroll position - -15 to 0 to 15
    // -15 or 15 will trigger appropriate scroll when next moved in that direction
    int5    tm_offset_x = 0;
    int5    tm_offset_y = 0;

    // Scroller/Wrapper storage
    uint1   tm_scroll = uninitialized;
    uint6   x_cursor = uninitialized;
    uint6   y_cursor = uninitialized;
    uint6   new_tile = uninitialized;
    uint7   new_background = uninitialized;
    uint6   new_foreground = uninitialized;
    uint6   scroll_tile = uninitialized;
    uint7   scroll_background = uninitialized;
    uint6   scroll_foreground = uninitialized;

    // Character position on the screen x 0-41, y 0-31 * 42 ( fetch it two pixels ahead of the actual x pixel, so it is always ready )
    // Adjust for the offsets, effective 0 point margin is ( 1,1 ) to ( 40,30 ) with a 1 tile border
    uint11   xtmpos := ( pix_active ? (pix_x < 640 ) ? pix_x + ( 11d18 + {{6{tm_offset_x[4,1]}}, tm_offset_x} ) : ( 11d16 + {{6{tm_offset_x[4,1]}}, tm_offset_x} ) : ( 11d16 + {{6{tm_offset_x[4,1]}}, tm_offset_x} ) ) >> 4;
    uint11  ytmpos := (( pix_vblank ? 0 : pix_y + ( 11d16 + {{6{tm_offset_y[4,1]}}, tm_offset_y} ) ) >> 4) * 42;

    // Derive the x and y coordinate within the current 16x16 tilemap block x 0-7, y 0-15
    // Needs adjusting for the offsets
    uint4   xintm := { 1b0, (pix_x) & 15 } + tm_offset_x;
    uint4   yintm := { 1b0, (pix_y) & 15 } + tm_offset_y;

    // Derive the actual pixel in the current character
    uint1   tmpixel := tiles16x16.rdata0[15 - xintm,1];

    // Set up reading of tilemap and attribute memory
    // tile.rdata0 is the tile, foreground.rdata0 and background.rdata0 are the attribute being rendered
    tile.addr0 := xtmpos + ytmpos;
    tile.wenable0 := 0;
    tile.wenable1 := 1;
    foreground.addr0 := xtmpos + ytmpos;
    foreground.wenable0 := 0;
    foreground.wenable1 := 1;
    background.addr0 := xtmpos + ytmpos;
    background.wenable0 := 0;
    background.wenable1 := 1;

    // Setup the reading and writing of the tiles16x16
    tiles16x16.addr0 :=  tile.rdata0 * 16 + yintm;
    tiles16x16.wenable0 := 0;
    tiles16x16.wenable1 := 1;

    // Default to transparent
    tilemap_display := pix_active && (( tmpixel ) || ( ~colour7(background.rdata0).alpha ));

    // Scroll/wrap
    always {
        if( tile_writer_write ) {
            tiles16x16.addr1 = tile_writer_tile * 16 + tile_writer_line;
            tiles16x16.wdata1 = tile_writer_bitmap;
        }

        switch( tm_write ) {
            case 1: {
                tile.addr1 = tm_x + tm_y * 42;
                tile.wdata1 = tm_character;
                tile.wenable1 = 1;
                background.addr1 = tm_x + tm_y * 42;
                background.wdata1 = tm_background;
                background.wenable1 = 1;
                foreground.addr1 = tm_x + tm_y * 42;
                foreground.wdata1 = tm_foreground;
                foreground.wenable1 = 1;
            }
        }

        switch( tm_scrollwrap ) {
           case 1: {
                // SCROLL/WRAP LEFT
                tm_offset_x = ( tm_offset_x == (15) ) ? 0 : tm_offset_x + 1;
                tm_active = ( tm_offset_x == (15) ) ? 1 : 0;
                tm_scroll = 1;
                tm_lastaction = ( tm_offset_x == (15) ) ? tm_scrollwrap : 0;
            }
            case 2: {
                // SCROLL/WRAP UP
                tm_offset_y = ( tm_offset_y == (15) ) ? 0 : tm_offset_y + 1;
                tm_active = ( tm_offset_y == (15) ) ? 15 : 0;
                tm_scroll = 1;
                tm_lastaction = ( tm_offset_y == (15) ) ? tm_scrollwrap : 0;
            }
            case 3: {
                // SCROLL/WRAP RIGHT
                tm_offset_x = ( tm_offset_x == (-15) ) ? 0 : tm_offset_x - 1;
                tm_active = ( tm_offset_x == (-15) ) ? 8 : 0;
                tm_scroll = 1;
                tm_lastaction = ( tm_offset_x == (-15) ) ? tm_scrollwrap : 0;
            }
            case 4: {
                // SCROLL/WRAP DOWN
                tm_offset_y = ( tm_offset_y == (-15) ) ? 0 : tm_offset_y - 1;
                tm_active = ( tm_offset_y == (-15) ) ? 22 : 0;
                tm_scroll = 1;
                tm_lastaction = ( tm_offset_y == (-15) ) ? tm_scrollwrap : 0;
            }
           case 5: {
                // SCROLL/WRAP LEFT
                tm_offset_x = ( tm_offset_x == (15) ) ? 0 : tm_offset_x + 1;
                tm_active = ( tm_offset_x == (15) ) ? 1 : 0;
                tm_scroll = 1;
                tm_lastaction = ( tm_offset_x == (15) ) ? tm_scrollwrap : 0;
            }
            case 6: {
                // SCROLL/WRAP UP
                tm_offset_y = ( tm_offset_y == (15) ) ? 0 : tm_offset_y + 1;
                tm_active = ( tm_offset_y == (15) ) ? 15 : 0;
                tm_scroll = 1;
                tm_lastaction = ( tm_offset_y == (15) ) ? tm_scrollwrap : 0;
            }
            case 7: {
                // SCROLL/WRAP RIGHT
                tm_offset_x = ( tm_offset_x == (-15) ) ? 0 : tm_offset_x - 1;
                tm_active = ( tm_offset_x == (-15) ) ? 8 : 0;
                tm_scroll = 0;
                tm_lastaction = ( tm_offset_x == (-15) ) ? tm_scrollwrap : 0;
            }
            case 8: {
                // SCROLL/WRAP DOWN
                tm_offset_y = ( tm_offset_y == (-15) ) ? 0 : tm_offset_y - 1;
                tm_active = ( tm_offset_y == (-15) ) ? 22 : 0;
                tm_scroll = 0;
                tm_lastaction = ( tm_offset_y == (-15) ) ? tm_scrollwrap : 0;
            }
            case 9: {
                // CLEAR
                tm_active = 29;
            }
        }
    }

    // Default to 0,0 and transparent
    tile.addr1 = 0; tile.wdata1 = 0;
    background.addr1 = 0; background.wdata1 = 64;
    foreground.addr1 = 0; foreground.wdata1 = 0;


    // Render the tilemap
    while(1) {
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

        if( tilemap_display ) {
            // Determine if background or foreground
            pix_red = tmpixel ? colour6(foreground.rdata0).red : colour7(background.rdata0).red;
            pix_green = tmpixel ? colour6(foreground.rdata0).green : colour7(background.rdata0).green;
            pix_blue = tmpixel ?  colour6(foreground.rdata0).blue : colour7(background.rdata0).blue;
        }
    }
}
