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

        switch( tm_scrollwrap - 1 ) {
           case 0: {
                // SCROLL/WRAP LEFT
                tm_offset_x = ( tm_offset_x == (15) ) ? 0 : tm_offset_x + 1;
                tm_active = ( tm_offset_x == (15) ) ? 1 : 0;
                tm_scroll = ( tm_scrollwrap > 5 );
                tm_lastaction = ( tm_offset_x == (15) ) ? tm_scrollwrap : 0;
            }
            case 1: {
                // SCROLL/WRAP UP
                tm_offset_y = ( tm_offset_y == (15) ) ? 0 : tm_offset_y + 1;
                tm_active = ( tm_offset_y == (15) ) ? 15 : 0;
                tm_scroll = ( tm_scrollwrap > 5 );
                tm_lastaction = ( tm_offset_y == (15) ) ? tm_scrollwrap : 0;
            }
            case 2: {
                // SCROLL/WRAP RIGHT
                tm_offset_x = ( tm_offset_x == (-15) ) ? 0 : tm_offset_x - 1;
                tm_active = ( tm_offset_x == (-15) ) ? 8 : 0;
                tm_scroll = ( tm_scrollwrap > 5 );
                tm_lastaction = ( tm_offset_x == (-15) ) ? tm_scrollwrap : 0;
            }
            case 3: {
                // SCROLL/WRAP DOWN
                tm_offset_y = ( tm_offset_y == (-15) ) ? 0 : tm_offset_y - 1;
                tm_active = ( tm_offset_y == (-15) ) ? 22 : 0;
                tm_scroll = ( tm_scrollwrap > 5 );
                tm_lastaction = ( tm_offset_y == (-15) ) ? tm_scrollwrap : 0;
            }
            case 8: {
                // CLEAR
                tm_active = 29;
            }
        }
    }

    // Render the tilemap
    while(1) {
        switch( tm_active ) {
            case 29: {
                // tmcs!
                x_cursor = 0;
                y_cursor = 0;
                tm_offset_x = 0;
                tm_offset_y = 0;
                tile.wdata1 = 0;
                foreground.wdata1 = 0;
                background.wdata1 = 64;
                tm_active = 30;
            }
            case 30: {
                tile.addr1 = ( x_cursor  ) + ( y_cursor * 42 ) - 42;
                foreground.addr1 = ( x_cursor  ) + ( y_cursor * 42 ) - 42;
                background.addr1 = ( x_cursor  ) + ( y_cursor * 42 ) - 42;
                x_cursor = ( x_cursor == 41 ) ? 0 : x_cursor + 1;
                y_cursor = ( x_cursor == 41 ) ? y_cursor + 1 : y_cursor;
                tm_active = ( x_cursor == 41 ) && ( y_cursor == 31 ) ? 0 : 30;
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
