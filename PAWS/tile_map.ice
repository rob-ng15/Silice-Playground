algorithm tilemap(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
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

    // For scrolling/wrapping
    input   uint4   tm_scrollwrap,
    output  uint4   tm_lastaction,
    output  uint2   tm_active
) <autorun> {
    // Tiles 64 x 16 x 16
    simple_dualport_bram uint16 tiles16x16 <input!> [ 1024 ] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, pad(uninitialized) };

    // 42 x 32 tile map, allows for pixel scrolling with border { 7 bits background, 6 bits foreground, 5 bits tile number }
    // Setting background to 40 (ALPHA) allows the bitmap/background to show through
    simple_dualport_bram uint6 tiles <input!> [1344] = uninitialized;
    simple_dualport_bram uint13 colours <input!> [1344] = uninitialized;

    // Scroll position - -15 to 0 to 15
    // -15 or 15 will trigger appropriate scroll when next moved in that direction
    int5    tm_offset_x = uninitialized;
    int5    tm_offset_y = uninitialized;
    tile_map_writer TMW(
        tiles <:> tiles,
        colours <:> colours,
        tm_x <: tm_x,
        tm_y <: tm_y,
        tm_character <: tm_character,
        tm_foreground <: tm_foreground,
        tm_background <: tm_background,
        tm_write <: tm_write,
        tm_offset_x :> tm_offset_x,
        tm_offset_y :> tm_offset_y,
        tm_scrollwrap <: tm_scrollwrap,
        tm_lastaction :> tm_lastaction,
        tm_active :> tm_active
    );

    tilebitmapwriter TBMW(
        tile_writer_tile <: tile_writer_tile,
        tile_writer_line <: tile_writer_line,
        tile_writer_bitmap <: tile_writer_bitmap,
        tiles16x16 <:> tiles16x16
    );

    // Character position on the screen x 0-41, y 0-31 * 42 ( fetch it two pixels ahead of the actual x pixel, so it is always ready, colours 1 pixel ahead )
    // Adjust for the offsets, effective 0 point margin is ( 1,1 ) to ( 40,30 ) with a 1 tile border
    uint11  xtmpos <: ( {{6{tm_offset_x[4,1]}}, tm_offset_x} + ( pix_active ? ( pix_x + 11d18 ) : 11d16 ) ) >> 4;
    uint11  ytmpos <: ( {{6{tm_offset_y[4,1]}}, tm_offset_y} + ( pix_vblank ? 11d16 : 11d16 + pix_y ) ) >> 4;
    uint11  xtmposcolour <: ( {{6{tm_offset_x[4,1]}}, tm_offset_x} + ( pix_active ? ( pix_x + 11d17 ) : 11d16 ) ) >> 4;

    // Derive the x and y coordinate within the current 16x16 tilemap block x 0-7, y 0-15
    // Needs adjusting for the offsets
    uint4   xintm <: { 1b0, pix_x[0,4] } + tm_offset_x;
    uint4   yintm <: { 1b0, pix_y[0,4] } + tm_offset_y;

    // Derive the actual pixel in the current character
    uint1   tmpixel <: tiles16x16.rdata0[15 - xintm, 1];

    // Set up reading of the tilemap
    tiles.addr0 := xtmpos + ytmpos * 42;
    colours.addr0 := xtmposcolour + ytmpos * 42;

    // Setup the reading and writing of the tiles16x16
    tiles16x16.addr0 :=  { tiles.rdata0, yintm };

    // RENDER - Default to transparent
    tilemap_display := pix_active & ( tmpixel | ~colours.rdata0[12,1] );
    pixel := tmpixel ? colour13(colours.rdata0).foreground : colour13(colours.rdata0).background;
}

algorithm tile_map_writer(
    simple_dualport_bram_port1 tiles,
    simple_dualport_bram_port1 colours,

    // Set TM at x, y, character with foreground and background
    input uint6 tm_x,
    input uint6 tm_y,
    input uint6 tm_character,
    input uint6 tm_foreground,
    input uint7 tm_background,
    input uint1 tm_write,

    // For scrolling/wrapping
    output  int5    tm_offset_x,
    output  int5    tm_offset_y,

    input   uint4   tm_scrollwrap,
    output  uint4   tm_lastaction,
    output  uint2   tm_active
) <autorun> {
    uint2   FSM = uninitialized;
    uint4   FSM2 = uninitialized;
    uint2   FSM3 = uninitialized;

    // COPY OF TILEMAP FOR SCROLLING
    simple_dualport_bram uint6 tiles_copy <input!> [1344] = uninitialized;
    simple_dualport_bram uint13 colours_copy <input!> [1344] = uninitialized;

    // Scroller/Wrapper storage
    uint1   tm_scroll = uninitialized;
    uint1   tm_goleft = uninitialized;
    uint1   tm_goup = uninitialized;
    uint6   x_cursor = uninitialized;
    uint11  y_cursor_addr = uninitialized;
    uint6   new_tile = uninitialized;
    uint13  new_colour = uninitialized;

    uint11  temp_1 = uninitialized;
    uint11  temp_2 = uninitialized;

    // CLEARSCROLL address
    uint11  tmcsaddr = uninitialized;

    // TILEMAP WRITE FLAGS
    tiles.wenable1 := 1;
    tiles_copy.wenable1 := 1;
    colours.wenable1 := 1;
    colours_copy.wenable1 := 1;

    // Default to 0,0 and transparent
    tiles.addr1 = 0; tiles.wdata1 = 0;
    tiles_copy.addr1 = 0; tiles_copy.wdata1 = 0;
    colours.addr1 = 0; colours.wdata1 = 13h1000;
    colours_copy.addr1 = 0; colours_copy.wdata1 = 13h1000;

    tm_offset_x = 0;
    tm_offset_y = 0;

    while(1) {
        // Write character to the tilemap
        switch( tm_write ) {
            case 0: {}
            case 1: {
                tiles.addr1 = tm_x + tm_y * 42;
                tiles.wdata1 = tm_character;
                tiles_copy.addr1 = tm_x + tm_y * 42;
                tiles_copy.wdata1 = tm_character;
                colours.addr1 = tm_x + tm_y * 42;
                colours.wdata1 = { tm_background, tm_foreground };
                colours_copy.addr1 = tm_x + tm_y * 42;
                colours_copy.wdata1 = { tm_background, tm_foreground };
            }
        }

        switch( tm_active ) {
            case 0: {
                // Perform Scrolling/Wrapping
                switch( tm_scrollwrap ) {
                    // NO ACTION
                    case 0: {}
                    // CLEAR
                    case 9: {
                        tm_active = 3;
                        tm_lastaction = 9;
                        tmcsaddr = 0;
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

            // SCROLL/WRAP LEFT/RIGHT
            case 1: {
                FSM = 1;
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: {  y_cursor_addr = 0; }
                        case 1: {
                            while( y_cursor_addr != 1344 ) {
                                FSM2 = 1;
                                while( FSM2 != 0 ) {
                                    onehot( FSM2 ) {
                                        case 0: {
                                            x_cursor = tm_goleft ? 0 : 41;
                                            tiles_copy.addr0 = y_cursor_addr + x_cursor;
                                            colours_copy.addr0 = y_cursor_addr + x_cursor;
                                        }
                                        case 1: {
                                            new_tile = tm_scroll ? 0 : tiles_copy.rdata0;
                                            new_colour = tm_scroll ? 13h1000 : colours_copy.rdata0;
                                            while( tm_goleft ? ( x_cursor != 42 ) : ( x_cursor != 0 ) ) {
                                                FSM3 = 1;
                                                while( FSM3 != 0 ) {
                                                    onehot( FSM3 ) {
                                                        case 0: {
                                                            temp_1 = tm_goleft ? y_cursor_addr + x_cursor + 1 : y_cursor_addr + x_cursor - 1;
                                                            tiles_copy.addr0 = temp_1;
                                                            colours_copy.addr0 = temp_1;
                                                        }
                                                        case 1: {
                                                            temp_1 = x_cursor + y_cursor_addr;
                                                            tiles.addr1 = temp_1;
                                                            tiles.wdata1 = tiles_copy.rdata0;
                                                            tiles_copy.addr1 = temp_1;
                                                            tiles_copy.wdata1 = tiles_copy.rdata0;
                                                            colours.addr1 = temp_1;
                                                            colours.wdata1 = colours_copy.rdata0;
                                                            colours_copy.addr1 = temp_1;
                                                            colours_copy.wdata1 = colours_copy.rdata0;
                                                            x_cursor = tm_goleft ? x_cursor + 1 : x_cursor - 1;
                                                        }
                                                    }
                                                    FSM3 = { FSM3[0,1], 1b0 };
                                                }
                                            }
                                        }
                                        case 2: {
                                            temp_1 = y_cursor_addr + ( tm_goleft ? 41 : 0 );
                                            tiles.addr1 = temp_1;
                                            tiles.wdata1 = new_tile;
                                            tiles_copy.addr1 = temp_1;
                                            tiles_copy.wdata1 = new_tile;
                                            colours.addr1 = temp_1;
                                            colours.wdata1 = new_colour;
                                            colours_copy.addr1 = temp_1;
                                            colours_copy.wdata1 = new_colour;
                                        }
                                        case 3: { y_cursor_addr = y_cursor_addr + 42; }
                                    }
                                    FSM2 = { FSM2[0,3], 1b0 };
                                }
                            }
                        }
                    }
                    FSM = { FSM[0,1], 1b0 };
                }
                tm_offset_x = 0;
                tm_active = 0;
            }

            // SCROLL/WRAP UP/DOWN
            case 2: {
                FSM = 1;
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: { x_cursor = 0; }
                        case 1: {
                            while( x_cursor != 42 ) {
                                FSM2 = 1;
                                while( FSM2 != 0 ) {
                                    onehot( FSM2 ) {
                                        case 0: {
                                            y_cursor_addr = tm_goup ? 0 : 1302;
                                            tiles_copy.addr0 = x_cursor + y_cursor_addr;
                                            colours_copy.addr0 = x_cursor + y_cursor_addr;
                                        }
                                        case 1: {
                                            new_tile = tm_scroll ? 0 : tiles_copy.rdata0;
                                            new_colour = tm_scroll ? 13h1000 : colours_copy.rdata0;
                                            while( tm_goup ? ( y_cursor_addr != 1302 ) : ( y_cursor_addr != 0 ) ) {
                                                FSM3 = 1;
                                                while( FSM3 != 0 ) {
                                                    onehot( FSM3 ) {
                                                        case 0: {
                                                            temp_1 = tm_goup ? x_cursor + y_cursor_addr + 42 : x_cursor + y_cursor_addr - 42;
                                                            tiles_copy.addr0 = temp_1;
                                                            colours_copy.addr0 = temp_1;
                                                        }
                                                        case 1: {
                                                            temp_1 = x_cursor + y_cursor_addr;
                                                            tiles.addr1 = temp_1;
                                                            tiles.wdata1 = tiles_copy.rdata0;
                                                            tiles_copy.addr1 = temp_1;
                                                            tiles_copy.wdata1 = tiles_copy.rdata0;
                                                            colours.addr1 = temp_1;
                                                            colours.wdata1 = colours_copy.rdata0;
                                                            colours_copy.addr1 = temp_1;
                                                            colours_copy.wdata1 = colours_copy.rdata0;
                                                            y_cursor_addr = tm_goup ? y_cursor_addr + 42 : y_cursor_addr - 42;
                                                        }
                                                    }
                                                    FSM3 = { FSM3[0,1], 1b0 };
                                                }
                                            }
                                        }
                                        case 2: {
                                            temp_1 = x_cursor + ( tm_goup ? 1302 : 0 );
                                            tiles.addr1 = temp_1;
                                            tiles.wdata1 = new_tile;
                                            tiles_copy.addr1 = temp_1;
                                            tiles_copy.wdata1 = new_tile;
                                            colours.addr1 = temp_1;
                                            colours.wdata1 = new_colour;
                                            colours_copy.addr1 = temp_1;
                                            colours_copy.wdata1 = new_colour;
                                        }
                                        case 3: { x_cursor = x_cursor + 1; }
                                    }
                                    FSM2 = { FSM2[0,3], 1b0 };
                                }
                            }
                        }
                    }
                    FSM = { FSM[0,1], 1b0 };
                }
                tm_offset_y = 0;
                tm_active = 0;
            }

            // CLEAR
            case 3: {
                while( tmcsaddr != 1344 ) {
                    tiles.addr1 = tmcsaddr;
                    tiles.wdata1 = 0;
                    tiles_copy.addr1 = tmcsaddr;
                    tiles_copy.wdata1 = 0;
                    colours.addr1 = tmcsaddr;
                    colours.wdata1 = 13h1000;
                    colours_copy.addr1 = tmcsaddr;
                    colours_copy.wdata1 = 13h1000;
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
