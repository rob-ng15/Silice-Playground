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
    input   uint4   tm_scrollwrap
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

    // Character position on the screen x 0-41, y 0-31 * 42 ( fetch it two pixels ahead of the actual x pixel, so it is always ready )
    // Adjust for the offsets, effective 0 point margin is ( 1,1 ) to ( 40,30 ) with a 1 tile border
    uint6   xtmpos := ( pix_active ? (pix_x < 640 ) ? pix_x + ( 10d18 + {{5{tm_offset_x[4,1]}}, tm_offset_x} ) : ( 10d16 + {{5{tm_offset_x[4,1]}}, tm_offset_x} ) : ( 10d16 + {{5{tm_offset_x[4,1]}}, tm_offset_x} ) ) >> 4;
    uint10  ytmpos := (( pix_vblank ? 0 : pix_y + ( 10d16 + {{5{tm_offset_y[4,1]}}, tm_offset_y} ) ) >> 4) * 42; 
    
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
    foreground.addr0 := xtmpos + ytmpos;
    foreground.wenable0 := 0;
    background.addr0 := xtmpos + ytmpos;
    background.wenable0 := 0;

    // BRAM write access for the tm writer 
    tile.addr1 := tm_x + tm_y * 42;
    tile.wdata1 := tm_character;
    tile.wenable1 := tm_write;
    background.addr1 := tm_x + tm_y * 42;
    background.wdata1 := tm_background;
    background.wenable1 := tm_write;
    foreground.addr1 := tm_x + tm_y * 42;
    foreground.wdata1 := tm_foreground;
    foreground.wenable1 := tm_write;

    // Setup the reading and writing of the tiles16x16
    tiles16x16.addr0 :=  tile.rdata0 * 16 + yintm;
    tiles16x16.addr1 := tile_writer_tile * 16 + tile_writer_line; 
    tiles16x16.wdata1 := tile_writer_bitmap;
    tiles16x16.wenable1 := tile_writer_write;

    // Default to transparent
    tilemap_display := pix_active && (( tmpixel ) || ( ~colour7(background.rdata0).alpha ));

    // Scroll/wrap
    always {
        switch( tm_scrollwrap ) {
            case 1: {
                // SCROLL LEFT
                tm_offset_x = ( tm_offset_x == (15) ) ? 0 : tm_offset_x + 1;
            }
            case 2: {
                // SCROLL UP
                tm_offset_y = ( tm_offset_y == (15) ) ? 0 : tm_offset_y + 1;
            }
            case 3: {
                // SCROLL RIGHT
                tm_offset_x = ( tm_offset_x == (-15) ) ? 0 : tm_offset_x - 1;
            }
            case 4: {
                // SCROLL DOWN
                tm_offset_y = ( tm_offset_y == (-15) ) ? 0 : tm_offset_y - 1;
            }
            case 5: {
                // WRAP LEFT
                tm_offset_x = ( tm_offset_x == (15) ) ? 0 : tm_offset_x + 1;
            }
            case 6: {
                // WRAP UP
                tm_offset_y = ( tm_offset_y == (15) ) ? 0 : tm_offset_y + 1;
            }
            case 7: {
                // WRAP RIGHT
                tm_offset_x = ( tm_offset_x == (-15) ) ? 0 : tm_offset_x - 1;
            }
            case 8: {
                // WRAP DOWN
                tm_offset_y = ( tm_offset_y == (-15) ) ? 0 : tm_offset_y - 1;
            }
            default: {}
        }
    }
    
    // Render the tilemap
    while(1) {
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
