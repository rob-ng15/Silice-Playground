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
    input uint6 tm_character,
    input uint6 tm_foreground,
    input uint7 tm_background,
    input uint1 tm_write,

    // For setting tile bitmaps
    input   uint6   tile_writer_tile,
    input   uint4   tile_writer_line,
    input   uint16  tile_writer_bitmap,  
    input   uint1   tile_writer_write,
    
    // For scrolling/wrapping
    input   uint4   tm_scrollwrap,
    output  uint6   tm_active
) <autorun> {
    // Tile Map 64 x 16 x 16
    dualport_bram uint16 tiles16x16[ 1024 ] = { 0, pad(0) };
    
    // 42 x 32 tile map, allows for pixel scrolling with border
    // Setting background to 40 (ALPHA) allows the bitmap/background to show through
    dualport_bram uint6 tile[1344] = uninitialized;
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
    tile.wenable1 := 0;
    foreground.addr0 := xtmpos + ytmpos;
    foreground.wenable0 := 0;
    foreground.wenable1 := 0;
    background.addr0 := xtmpos + ytmpos;
    background.wenable0 := 0;
    background.wenable1 := 0;

    // Setup the reading and writing of the tiles16x16
    tiles16x16.addr0 :=  tile.rdata0 * 16 + yintm;
    tiles16x16.addr1 := tile_writer_tile * 16 + tile_writer_line; 
    tiles16x16.wdata1 := tile_writer_bitmap;
    tiles16x16.wenable1 := tile_writer_write;

    // Default to transparent
    tilemap_display := pix_active && (( tmpixel ) || ( ~colour7(background.rdata0).alpha ));

    // Scroll/wrap
    always {
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
                // SCROLL LEFT
                tm_offset_x = ( tm_offset_x == (15) ) ? 0 : tm_offset_x + 1;
                tm_active = ( tm_offset_x == (15) ) ? 1 : 0;
                tm_scroll = 1;
            }
            case 2: {
                // SCROLL UP
                tm_offset_y = ( tm_offset_y == (15) ) ? 0 : tm_offset_y + 1;
                tm_active = ( tm_offset_y == (15) ) ? 15 : 0;
                tm_scroll = 1;
            }
            case 3: {
                // SCROLL RIGHT
                tm_offset_x = ( tm_offset_x == (-15) ) ? 0 : tm_offset_x - 1;
                tm_active = ( tm_offset_x == (-15) ) ? 8 : 0;
                tm_scroll = 1;
            }
            case 4: {
                // SCROLL DOWN
                tm_offset_y = ( tm_offset_y == (-15) ) ? 0 : tm_offset_y - 1;
                tm_active = ( tm_offset_y == (-15) ) ? 22 : 0;
                tm_scroll = 1;
            }
            case 5: {
                // WRAP LEFT
                tm_offset_x = ( tm_offset_x == (15) ) ? 0 : tm_offset_x + 1;
                tm_active = ( tm_offset_x == (15) ) ? 1 : 0;
                tm_scroll = 0;
            }
            case 6: {
                // WRAP UP
                tm_offset_y = ( tm_offset_y == (15) ) ? 0 : tm_offset_y + 1;
                tm_active = ( tm_offset_y == (15) ) ? 15 : 0;
                tm_scroll = 0;
            }
            case 7: {
                // WRAP RIGHT
                tm_offset_x = ( tm_offset_x == (-15) ) ? 0 : tm_offset_x - 1;
                tm_active = ( tm_offset_x == (-15) ) ? 8 : 0;
                tm_scroll = 0;
            }
            case 8: {
                // WRAP DOWN
                tm_offset_y = ( tm_offset_y == (-15) ) ? 0 : tm_offset_y - 1;
                tm_active = ( tm_offset_y == (-15) ) ? 22 : 0;
                tm_scroll = 0;
            }
        }
    }
    
    // Render the tilemap
    while(1) {
        switch( tm_active ) {
            case 1: {
                // Scroll/Wrap Left Setup
                x_cursor = 0;
                y_cursor = 0;
                tile.addr1 = 0;
                background.addr1 = 0;
                foreground.addr1 = 0;
                tm_active = 2;
            }
            case 2: {
                // Scroll/Wrap Left New Row - Save or wipe end column
                new_tile = ( tm_scroll == 1 ) ? 0 : tile.rdata1;
                new_foreground = ( tm_scroll == 1 ) ? 0 : foreground.rdata1;
                new_background = ( tm_scroll == 1 ) ? 7h40 : background.rdata1;
                tm_active = 3;
            }
            case 3: {
                // Scroll/Wrap Left Read Next Column
                tile.addr1 = x_cursor + 1 + ( y_cursor * 42);
                background.addr1 = x_cursor + 1 + ( y_cursor * 42);
                foreground.addr1 = x_cursor + 1 + ( y_cursor * 42);
                tm_active = 4;
            }
            case 4: {
                // Scroll/Wrap Left Read Next Column
                scroll_tile = tile.rdata1;
                scroll_foreground = foreground.rdata1;
                scroll_background = background.rdata1;
                tile.addr1 = x_cursor + ( y_cursor * 42);
                background.addr1 = x_cursor + ( y_cursor * 42);
                foreground.addr1 = x_cursor + ( y_cursor * 42);
                tm_active = 5;
            }
            case 5: {
                // Scroll/Wrap Left Write Column
                tile.wdata1 = scroll_tile;
                tile.wenable1 = 1;
                foreground.wdata1 = scroll_foreground;
                foreground.wenable1 = 1;
                background.wdata1 = scroll_background;
                background.wenable1 = 1;
                tm_active = 6;
            }
            case 6: {
                // Move to next column
                if( x_cursor == 41 ) {
                    tile.addr1 = 41 + ( y_cursor * 42);
                    tile.wdata1 = new_tile;
                    tile.wenable1 = 1;
                    foreground.addr1 = 41 + ( y_cursor * 42);
                    foreground.wdata1 = new_foreground;
                    foreground.wenable1 = 1;
                    background.addr1 = 41 + ( y_cursor * 42);
                    background.wdata1 = new_background;
                    background.wenable1 = 1;
                    x_cursor = 0;
                    y_cursor = ( y_cursor == 31 ) ? 0 : y_cursor + 1;
                    tm_active = ( y_cursor == 31 ) ? 0 : 7;
                } else {
                    x_cursor = x_cursor + 1;
                    tm_active = 3;
                }
            }
            case 7: {
                // Set address for the next row
                tile.addr1 = x_cursor + ( y_cursor * 42);
                background.addr1 = x_cursor + ( y_cursor * 42);
                foreground.addr1 = x_cursor + ( y_cursor * 42);
                tm_active = 2;
            }
            case 8: {
                // Scroll/Wrap Right Setup
                x_cursor = 41;
                y_cursor = 0;
                tile.addr1 = 0;
                background.addr1 = 0;
                foreground.addr1 = 0;
                tm_active = 9;
            }
            case 9: {
                // Scroll/Wrap Right New Row - Save or wipe end column
                new_tile = ( tm_scroll == 1 ) ? 0 : tile.rdata1;
                new_foreground = ( tm_scroll == 1 ) ? 0 : foreground.rdata1;
                new_background = ( tm_scroll == 1 ) ? 7h40 : background.rdata1;
                tm_active = 10;
            }
            case 10: {
                // Scroll/Wrap Right Read Next Column
                tile.addr1 = x_cursor - 1 + ( y_cursor * 42);
                background.addr1 = x_cursor - 1 + ( y_cursor * 42);
                foreground.addr1 = x_cursor - 1 + ( y_cursor * 42);
                tm_active = 11;
            }
            case 11: {
                // Scroll/Wrap Right Read Next Column
                scroll_tile = tile.rdata1;
                scroll_foreground = foreground.rdata1;
                scroll_background = background.rdata1;
                tile.addr1 = x_cursor + ( y_cursor * 42);
                background.addr1 = x_cursor + ( y_cursor * 42);
                foreground.addr1 = x_cursor + ( y_cursor * 42);
                tm_active = 12;
            }
            case 12: {
                // Scroll/Wrap Right Write Column
                tile.wdata1 = scroll_tile;
                tile.wenable1 = 1;
                foreground.wdata1 = scroll_foreground;
                foreground.wenable1 = 1;
                background.wdata1 = scroll_background;
                background.wenable1 = 1;
                tm_active = 13;
            }
            case 13: {
                // Move to next column
                if( x_cursor == 1 ) {
                    tile.addr1 = ( y_cursor * 42);
                    tile.wdata1 = new_tile;
                    tile.wenable1 = 1;
                    foreground.addr1 = ( y_cursor * 42);
                    foreground.wdata1 = new_foreground;
                    foreground.wenable1 = 1;
                    background.addr1 = ( y_cursor * 42);
                    background.wdata1 = new_background;
                    background.wenable1 = 1;
                    x_cursor = 41;
                    y_cursor = ( y_cursor == 31 ) ? 0 : y_cursor + 1;
                    tm_active = ( y_cursor == 31 ) ? 0 : 14;
                } else {
                    x_cursor = x_cursor - 1;
                    tm_active = 10;
                }
            }
            case 14: {
                // Set address for the next row
                tile.addr1 = x_cursor + ( y_cursor * 42);
                background.addr1 = x_cursor + ( y_cursor * 42);
                foreground.addr1 = x_cursor + ( y_cursor * 42);
                tm_active = 8;
            }
            case 15: {
                // Scroll/Wrap Up Setup
                x_cursor = 0;
                y_cursor = 0;
                tile.addr1 = 0;
                background.addr1 = 0;
                foreground.addr1 = 0;
                tm_active = 16;
            }
            case 16: {
                // Scroll/Wrap Up New Column - Save or wipe end row
                new_tile = ( tm_scroll == 1 ) ? 0 : tile.rdata1;
                new_foreground = ( tm_scroll == 1 ) ? 0 : foreground.rdata1;
                new_background = ( tm_scroll == 1 ) ? 7h40 : background.rdata1;
                tm_active = 17;
            }
            case 17: {
                // Scroll/Wrap Up Read Next Row
                tile.addr1 = x_cursor + 42 + ( y_cursor * 42);
                background.addr1 = x_cursor + 42 + ( y_cursor * 42);
                foreground.addr1 = x_cursor + 42 + ( y_cursor * 42);
                tm_active = 18;
            }
            case 18: {
                // Scroll/Wrap Right Read Next Row
                scroll_tile = tile.rdata1;
                scroll_foreground = foreground.rdata1;
                scroll_background = background.rdata1;
                tm_active = 19;
            }
            case 19: {
                // Scroll/Wrap Up Write Row
                tile.addr1 = x_cursor + ( y_cursor * 42);
                tile.wdata1 = scroll_tile;
                tile.wenable1 = 1;
                background.addr1 = x_cursor + ( y_cursor * 42);
                background.wdata1 = scroll_background;
                background.wenable1 = 1;
                foreground.addr1 = x_cursor + ( y_cursor * 42);
                foreground.wdata1 = scroll_foreground;
                foreground.wenable1 = 1;
                tm_active = 20;
            }
            case 20: {
                // Move to next row
                if( y_cursor == 30 ) {
                    tile.addr1 = ( x_cursor ) + ( 31 * 42);
                    tile.wdata1 = new_tile;
                    tile.wenable1 = 1;
                    foreground.addr1 = ( x_cursor ) + ( 31 * 42);
                    foreground.wdata1 = new_foreground;
                    foreground.wenable1 = 1;
                    background.addr1 = ( x_cursor ) + ( 31 * 42);
                    background.wdata1 = new_background;
                    background.wenable1 = 1;
                    y_cursor = 0;
                    x_cursor = ( x_cursor == 41 ) ? 0 : x_cursor + 1;
                    tm_active = ( x_cursor == 41 ) ? 0 : 21;
                } else {
                    y_cursor = y_cursor + 1;
                    tm_active = 17;
                }
            }
            case 21: {
                // Set address for the next row
                tile.addr1 = x_cursor;
                background.addr1 = x_cursor;
                foreground.addr1 = x_cursor;
                tm_active = 16;
            }
            case 22: {
                // Scroll/Wrap Down Setup
                x_cursor = 0;
                y_cursor = 31;
                tile.addr1 = 31 * 42;
                background.addr1 = 31 * 42;
                foreground.addr1 = 31 * 42;
                tm_active = 23;
            }
            case 23: {
                // Scroll/Wrap Up New Column - Save or wipe end row
                new_tile = ( tm_scroll == 1 ) ? 0 : tile.rdata1;
                new_foreground = ( tm_scroll == 1 ) ? 0 : foreground.rdata1;
                new_background = ( tm_scroll == 1 ) ? 7h40 : background.rdata1;
                tm_active = 24;
            }
            case 24: {
                // Scroll/Wrap Up Read Next Row
                tile.addr1 = x_cursor + ( y_cursor * 42) - 42;
                background.addr1 = x_cursor + ( y_cursor * 42) - 42;
                foreground.addr1 = x_cursor + ( y_cursor * 42) - 42;
                tm_active = 25;
            }
            case 25: {
                // Scroll/Wrap Up Read Next Row
                scroll_tile = tile.rdata1;
                scroll_foreground = foreground.rdata1;
                scroll_background = background.rdata1;
                tile.addr1 = x_cursor + ( y_cursor * 42);
                background.addr1 = x_cursor + ( y_cursor * 42);
                foreground.addr1 = x_cursor + ( y_cursor * 42);
                tm_active = 26;
            }
            case 26: {
                // Scroll/Wrap Up Write Row
                tile.wdata1 = scroll_tile;
                tile.wenable1 = 1;
                foreground.wdata1 = scroll_foreground;
                foreground.wenable1 = 1;
                background.wdata1 = scroll_background;
                background.wenable1 = 1;
                tm_active = 27;
            }
            case 27: {
                // Move to next row
                if( y_cursor == 0 ) {
                    tile.addr1 = ( x_cursor );
                    tile.wdata1 = new_tile;
                    tile.wenable1 = 1;
                    foreground.addr1 = ( x_cursor );
                    foreground.wdata1 = new_foreground;
                    foreground.wenable1 = 1;
                    background.addr1 = ( x_cursor );
                    background.wdata1 = new_background;
                    background.wenable1 = 1;
                    y_cursor = 31;
                    x_cursor = ( x_cursor == 41 ) ? 0 : x_cursor + 1;
                    tm_active = ( x_cursor == 41 ) ? 0 : 28;
                } else {
                    y_cursor = y_cursor + 1;
                    tm_active = 24;
                }
            }
            case 28: {
                // Set address for the next row
                tile.addr1 = x_cursor + ( 31 * 42);
                background.addr1 = x_cursor + ( 31 * 42);
                foreground.addr1 = x_cursor + ( 31 * 42);
                tm_active = 23;
            }
            default: { tm_active = 0; }
        }
        
        if( tilemap_display ) {
            // Determine if background or foreground
            switch( tmpixel ) {
                case 0: {
                    // BACKGROUND
                    pix_red = colour7(background.rdata0).red;
                    pix_green = colour7(background.rdata0).green;
                    pix_blue = colour7(background.rdata0).blue;
                }
                case 1: {
                    // foreground
                    pix_red = colour6(foreground.rdata0).red;
                    pix_green = colour6(foreground.rdata0).green;
                    pix_blue = colour6(foreground.rdata0).blue;
                }
            }
        } 
    }
}
