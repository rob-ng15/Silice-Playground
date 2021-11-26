algorithm tilemap(
    simple_dualport_bram_port0 tiles16x16,
    simple_dualport_bram_port0 tiles,
    simple_dualport_bram_port0 colours,

    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   tilemap_display,

    // Set TM at x, y, character with foreground and background
    input   uint6   tm_x,
    input   uint6   tm_y,
    input   uint6   tm_character,
    input   uint6   tm_foreground,
    input   uint7   tm_background,
    input   uint2   tm_reflection,
    input   uint1   tm_write,

    // For scrolling/wrapping
    input   int5    tm_offset_x,
    input   int5    tm_offset_y
) <autorun> {
    // Character position on the screen x 0-41, y 0-31 * 42 ( fetch it two pixels ahead of the actual x pixel, so it is always ready, colours 1 pixel ahead )
    // Adjust for the offsets, effective 0 point margin is ( 1,1 ) to ( 40,30 ) with a 1 tile border
    uint6   xtmpos <: ( {{6{tm_offset_x[4,1]}}, tm_offset_x} + ( pix_active ? ( pix_x + 11d18 ) : 11d16 ) ) >> 4;
    uint6   xtmposcolour <: ( {{6{tm_offset_x[4,1]}}, tm_offset_x} + ( pix_active ? ( pix_x + 11d17 ) : 11d16 ) ) >> 4;
    uint11  ytmpos <: ( {{6{tm_offset_y[4,1]}}, tm_offset_y} + ( pix_vblank ? 11d16 : 11d16 + pix_y ) ) >> 4;

    // Derive the x and y coordinate within the current 16x16 tilemap block x 0-15, y 0-15
    // Needs adjusting for the offsets
    uint4   xintm <: { 1b0, pix_x[0,4] } + tm_offset_x;
    uint4   yintm <: { 1b0, pix_y[0,4] } + tm_offset_y;

    // Derive the actual pixel in the current character
    uint1   tmpixel <: colour15(colours.rdata0).x_reflect ? tiles16x16.rdata0[xintm, 1] :tiles16x16.rdata0[4b1111 - xintm, 1];

    // Set up reading of the tilemap
    tiles.addr0 := xtmpos + ytmpos * 42; colours.addr0 := xtmposcolour + ytmpos * 42;

    // Setup the reading and writing of the tiles16x16
    tiles16x16.addr0 := colour15(colours.rdata0).y_reflect ? { tiles.rdata0, 4b1111 - yintm } :{ tiles.rdata0, yintm };

    // RENDER - Default to transparent
    tilemap_display := pix_active & ( tmpixel | ~colour15(colours.rdata0).alpha );
    pixel := tmpixel ? colour15(colours.rdata0).foreground : colour15(colours.rdata0).background;
}

algorithm tile_map_writer(
    simple_dualport_bram_port1 tiles,
    simple_dualport_bram_port1 colours,

    // Set TM at x, y, character with foreground, background and rotation
    input   uint6   tm_x,
    input   uint6   tm_y,
    input   uint6   tm_character,
    input   uint6   tm_foreground,
    input   uint7   tm_background,
    input   uint2   tm_reflection,
    input   uint1   tm_write,

    // For scrolling/wrapping
    output  int5    tm_offset_x(0),
    output  int5    tm_offset_y(0),

    input   uint4   tm_scrollwrap,
    output  uint4   tm_lastaction,
    output  uint2   tm_active
) <autorun> {
    // COPY OF TILEMAP FOR SCROLLING
    simple_dualport_bram uint6 tiles_copy[1344] = uninitialized;
    simple_dualport_bram uint15 colours_copy[1344] = uninitialized;

    // Scroller/Wrapper storage
    uint1   tm_scroll = uninitialized;
    uint1   tm_goleft = uninitialized;
    uint1   tm_goup = uninitialized;
    uint6   x_cursor = uninitialized;
    uint11  y_cursor_addr = uninitialized;
    uint6   new_tile = uninitialized;
    uint15  new_colour = uninitialized;

    uint11  temp_1 = uninitialized;
    uint11  temp_2 <:: x_cursor + y_cursor_addr;
    uint11  write_address <:: tm_x + tm_y * 42;

    // CLEARSCROLL address
    uint11  tmcsaddr = uninitialized;

    // TILEMAP WRITE FLAGS
    tiles.wenable1 := 1; tiles_copy.wenable1 := 1; colours.wenable1 := 1; colours_copy.wenable1 := 1;

    always {
        if( tm_write ) {
            // Write character to the tilemap
            tiles.addr1 = write_address; tiles.wdata1 = tm_character;
            tiles_copy.addr1 =write_address; tiles_copy.wdata1 = tm_character;
            colours.addr1 = write_address; colours.wdata1 = { tm_reflection, tm_background, tm_foreground };
            colours_copy.addr1 = write_address; colours_copy.wdata1 = { tm_reflection, tm_background, tm_foreground };
        }

        // Perform Scrolling/Wrapping
        switch( tm_scrollwrap ) {
            // NO ACTION
            case 0: {}
            // CLEAR
            case 9: {
                tm_active = 3;
                tm_lastaction = 9;
            }

            // SCROLL / WRAP
            default: {
                tm_scroll = ( tm_scrollwrap < 5 );
                switch( ( tm_scrollwrap - 1 ) & 3  ) {
                    case 0: {
                        switch( tm_offset_x ) {
                            case 15: { tm_goleft = 1; tm_active = 1; }
                            default: { tm_offset_x = tm_offset_x + 1; }
                        }
                    }
                    // UP
                    case 1: {
                        switch( tm_offset_y ) {
                            case 15: { tm_goup = 1; tm_active = 2; }
                            default: { tm_offset_y = tm_offset_y + 1; }
                        }
                    }
                    // RIGHT
                    case 2: {
                        switch( tm_offset_x ) {
                            case -15: { tm_goleft = 0; tm_active = 1; }
                            default: { tm_offset_x = tm_offset_x - 1; }
                        }
                    }
                    // DOWN
                    case 3: {
                        switch( tm_offset_y ) {
                            case -15: { tm_goup = 0; tm_active = 2; }
                            default: { tm_offset_y = tm_offset_y - 1; }
                        }
                    }
                }
                tm_lastaction = ( tm_active != 0 ) ? tm_scrollwrap : 0;
            }
        }
    }

    while(1) {
        switch( tm_active ) {
            default:  {
                tmcsaddr = 0;
                y_cursor_addr = 0;
                x_cursor = 0;
            }
            // SCROLL/WRAP LEFT/RIGHT
            case 1: {
                while( y_cursor_addr != 1344 ) {
                    x_cursor = tm_goleft ? 0 : 41;
                    temp_1 = y_cursor_addr + x_cursor;
                    tiles_copy.addr0 = temp_1; colours_copy.addr0 = temp_1;
                    ++:
                    new_tile = tm_scroll ? 0 : tiles_copy.rdata0;
                    new_colour = tm_scroll ? 15h1000 : colours_copy.rdata0;
                    while( tm_goleft ? ( x_cursor != 42 ) : ( x_cursor != 0 ) ) {
                        temp_1 = tm_goleft ? temp_2 + 1 : temp_2 - 1;
                        tiles_copy.addr0 = temp_1; colours_copy.addr0 = temp_1;
                        ++:
                        tiles.addr1 = temp_2; tiles.wdata1 = tiles_copy.rdata0;
                        tiles_copy.addr1 = temp_2; tiles_copy.wdata1 = tiles_copy.rdata0;
                        colours.addr1 = temp_2; colours.wdata1 = colours_copy.rdata0;
                        colours_copy.addr1 = temp_2; colours_copy.wdata1 = colours_copy.rdata0;
                        x_cursor = tm_goleft ? x_cursor + 1 : x_cursor - 1;
                    }
                    temp_1 = y_cursor_addr + ( tm_goleft ? 41 : 0 );
                    tiles.addr1 = temp_1; tiles.wdata1 = new_tile;
                    tiles_copy.addr1 = temp_1; tiles_copy.wdata1 = new_tile;
                    colours.addr1 = temp_1; colours.wdata1 = new_colour;
                    colours_copy.addr1 = temp_1; colours_copy.wdata1 = new_colour;
                    y_cursor_addr = y_cursor_addr + 42;
                }
                tm_offset_x = 0;
                tm_active = 0;
            }

            // SCROLL/WRAP UP/DOWN
            case 2: {
                while( x_cursor != 42 ) {
                    y_cursor_addr = tm_goup ? 0 : 1302;
                    temp_1 = x_cursor + y_cursor_addr;
                    tiles_copy.addr0 = temp_1; colours_copy.addr0 = temp_1;
                    ++:
                    new_tile = tm_scroll ? 0 : tiles_copy.rdata0;
                    new_colour = tm_scroll ? 15h1000 : colours_copy.rdata0;
                    while( tm_goup ? ( y_cursor_addr != 1302 ) : ( y_cursor_addr != 0 ) ) {
                        temp_1 = tm_goup ? temp_2 + 42 : temp_2 - 42;
                        tiles_copy.addr0 = temp_1; colours_copy.addr0 = temp_1;
                        ++:
                        tiles.addr1 = temp_2; tiles.wdata1 = tiles_copy.rdata0;
                        tiles_copy.addr1 = temp_2; tiles_copy.wdata1 = tiles_copy.rdata0;
                        colours.addr1 = temp_2; colours.wdata1 = colours_copy.rdata0;
                        colours_copy.addr1 = temp_2; colours_copy.wdata1 = colours_copy.rdata0;
                        y_cursor_addr = tm_goup ? y_cursor_addr + 42 : y_cursor_addr - 42;
                    }
                    temp_1 = x_cursor + ( tm_goup ? 1302 : 0 );
                    tiles.addr1 = temp_1; tiles.wdata1 = new_tile;
                    tiles_copy.addr1 = temp_1; tiles_copy.wdata1 = new_tile;
                    colours.addr1 = temp_1; colours.wdata1 = new_colour;
                    colours_copy.addr1 = temp_1; colours_copy.wdata1 = new_colour;
                    x_cursor = x_cursor + 1;
                }
                tm_offset_y = 0;
                tm_active = 0;
            }

            // CLEAR
            case 3: {
                while( tmcsaddr != 1344 ) {
                    tiles.addr1 = tmcsaddr; tiles.wdata1 = 0;
                    tiles_copy.addr1 = tmcsaddr; tiles_copy.wdata1 = 0;
                    colours.addr1 = tmcsaddr; colours.wdata1 = 15h1000;
                    colours_copy.addr1 = tmcsaddr; colours_copy.wdata1 = 15h1000;
                    tmcsaddr = tmcsaddr + 1;
                }
                tm_offset_x = 0;
                tm_offset_y = 0;
                tm_active = 0;
            }
        }
    }
}

algorithm tilebitmapwriter(
    input   uint6   tile_writer_tile,
    input   uint4   tile_writer_line,
    input   uint16  tile_writer_bitmap,

    simple_dualport_bram_port1 tiles16x16
) <autorun> {
    tiles16x16.wenable1 := 1;
    tiles16x16.addr1 := { tile_writer_tile, tile_writer_line };
    tiles16x16.wdata1 := tile_writer_bitmap;
}
