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

algorithm   calcoffset(
    input   int5    offset,
    output  uint1   MIN,
    output  int5    PREV,
    output  uint1   MAX,
    output  int5    NEXT
) <autorun> {
    always_after {
        MIN = ( offset == -15 );                    PREV = ( offset - 1 );
        MAX = ( offset == 15 );                     NEXT = ( offset + 1 );
    }
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
    output  uint3   tm_active
) <autorun,reginputs> {
    // COPY OF TILEMAP FOR SCROLLING
    simple_dualport_bram uint6 tiles_copy[1344] = uninitialized;
    simple_dualport_bram uint15 colours_copy[1344] = uninitialized;

    // OFFSET CALCULATIONS
    calcoffset TMOX( offset <: tm_offset_x );       calcoffset TMOY( offset <: tm_offset_y );

    // Scroller/Wrapper FLAGS
    uint1   tm_scroll = uninitialized;              uint1   tm_sw <:: ( tm_scrollwrap < 5 );                uint2   tm_action <:: ( tm_scrollwrap - 1 ) & 3;
    uint1   tm_dodir = uninitialized;

    // CURSORS AND ADDRESSES FOR SCROLLING WRAPPING
    uint6   x_cursor = uninitialized;               uint6   xNEXT <:: x_cursor + 1;                         uint6   xPREV <:: x_cursor - 1;
                                                    uint11  xSAVED <:: x_cursor + ( tm_dodir ? 1302 : 0 );
    uint11  y_cursor_addr = uninitialized;          uint11  yNEXT <:: y_cursor_addr + 42;                   uint11  yPREV <:: y_cursor_addr - 42;
                                                    uint11  ySAVED <:: y_cursor_addr + ( tm_dodir ? 41 : 0 );
    uint11  temp_1 = uninitialized;
    uint11  temp_2 <:: x_cursor + y_cursor_addr;    uint11  temp_2NEXT1 <:: temp_2 + 1;                     uint11  temp_2PREV1 <:: temp_2 - 1;
                                                    uint11  temp_2NEXT42 <:: temp_2 + 42;                   uint11  temp_2PREV42 <:: temp_2 - 42;
    uint11  write_address <:: tm_x + tm_y * 42;

    // STORAGE FOR SAVED CHARACTER WHEN WRAPPING
    uint6   new_tile = uninitialized; uint15  new_colour = uninitialized;

    // CLEARSCROLL address
    uint11  tmcsaddr = uninitialized;               uint11  tmcsNEXT <:: tmcsaddr + 1;

    // TILEMAP WRITE FLAGS
    tiles.wenable1 := 1; tiles_copy.wenable1 := 1; colours.wenable1 := 1; colours_copy.wenable1 := 1;

    always_after {
        if( tm_write ) {
            // Write character to the tilemap
            tiles.addr1 = write_address; tiles.wdata1 = tm_character;
            tiles_copy.addr1 =write_address; tiles_copy.wdata1 = tm_character;
            colours.addr1 = write_address; colours.wdata1 = { tm_reflection, tm_background, tm_foreground };
            colours_copy.addr1 = write_address; colours_copy.wdata1 = { tm_reflection, tm_background, tm_foreground };
        }

        switch( tm_scrollwrap ) {                                                                                           // ACT AS PER tm_scrollwrap
            case 0: {}                                                                                                      // NO ACTION
            case 9: { tm_active = 4; tm_lastaction = 9; }                                                                   // CLEAR
            default: {                                                                                                      // SCROLL / WRAP
                tm_scroll = tm_sw;
                switch( tm_action ) {
                    case 0: { if( TMOX.MAX ) { tm_dodir = 1; tm_active = 1; } else { tm_offset_x = TMOX.NEXT; } }           // LEFT
                    case 1: { if( TMOY.MAX ) { tm_dodir = 1; tm_active = 2; } else { tm_offset_y = TMOY.NEXT; } }           // UP
                    case 2: { if( TMOX.MIN ) { tm_dodir = 0; tm_active = 1; } else { tm_offset_x = TMOX.PREV; } }           // RIGHT
                    case 3: { if( TMOY.MIN ) { tm_dodir = 0; tm_active = 2; } else { tm_offset_y = TMOY.PREV; } }           // DOWN
                }
                tm_lastaction = ( |tm_active ) ? tm_scrollwrap : 0;
            }
        }
    }

    while(1) {
        if( |tm_active ) {
            onehot( tm_active ) {
                case 0: {                                                                                                   // SCROLL/WRAP LEFT/RIGHT
                    while( y_cursor_addr != 1344 ) {                                                                            // REPEAT UNTIL AT BOTTOM OF THE SCREEN
                        x_cursor = tm_dodir ? 0 : 41;                                                                           // SAVE CHARACTER AT START/END OF LINE FOR WRAPPING
                        temp_1 = y_cursor_addr + x_cursor;
                        tiles_copy.addr0 = temp_1; colours_copy.addr0 = temp_1;
                        ++:
                        new_tile = tm_scroll ? 0 : tiles_copy.rdata0;
                        new_colour = tm_scroll ? 15h1000 : colours_copy.rdata0;
                        while( tm_dodir ? ( x_cursor != 42 ) : ( |x_cursor ) ) {                                                // START AT THE LEFT/RIGHT OF THE LINE
                            temp_1 = tm_dodir ? temp_2NEXT1 : temp_2PREV1;                                                      // SAVE THE ADJACENT CHARACTER
                            tiles_copy.addr0 = temp_1; colours_copy.addr0 = temp_1;
                            ++:
                            tiles.addr1 = temp_2; tiles.wdata1 = tiles_copy.rdata0;                                             // COPY INTO NEW LOCATION
                            tiles_copy.addr1 = temp_2; tiles_copy.wdata1 = tiles_copy.rdata0;
                            colours.addr1 = temp_2; colours.wdata1 = colours_copy.rdata0;
                            colours_copy.addr1 = temp_2; colours_copy.wdata1 = colours_copy.rdata0;
                            x_cursor = tm_dodir ? xNEXT : xPREV;                                                                // MOVE TO NEXT CHARACTER ON THE LINE
                        }
                        tiles.addr1 = ySAVED; tiles.wdata1 = new_tile;                                                          // WRITE BLANK OR THE WRAPPED CHARACTER
                        tiles_copy.addr1 = ySAVED; tiles_copy.wdata1 = new_tile;
                        colours.addr1 = ySAVED; colours.wdata1 = new_colour;
                        colours_copy.addr1 = ySAVED; colours_copy.wdata1 = new_colour;
                        y_cursor_addr = yNEXT;
                    }
                    tm_offset_x = 0;
                }
                case 1: {                                                                                                   // SCROLL/WRAP UP/DOWN
                    while( x_cursor != 42 ) {                                                                                   // REPEAT UNTIL AT RIGHT OF THE SCREEN
                        y_cursor_addr = tm_dodir ? 0 : 1302;                                                                    // SAVE CHARACTER AT TOP/BOTTOM OF THE SCREEN FOR WRAPPING
                        temp_1 = x_cursor + y_cursor_addr;
                        tiles_copy.addr0 = temp_1; colours_copy.addr0 = temp_1;
                        ++:
                        new_tile = tm_scroll ? 0 : tiles_copy.rdata0;
                        new_colour = tm_scroll ? 15h1000 : colours_copy.rdata0;
                        while( tm_dodir ? ( y_cursor_addr != 1302 ) : ( |y_cursor_addr ) ) {                                    // START AT TOP/BOTTOM OF THE SCREEN
                            temp_1 = tm_dodir ? temp_2NEXT42 : temp_2PREV42;                                                    // SAVE THE ADJACENT CHARACTER
                            tiles_copy.addr0 = temp_1; colours_copy.addr0 = temp_1;
                            ++:
                            tiles.addr1 = temp_2; tiles.wdata1 = tiles_copy.rdata0;                                             // COPY TO NEW LOCATION
                            tiles_copy.addr1 = temp_2; tiles_copy.wdata1 = tiles_copy.rdata0;
                            colours.addr1 = temp_2; colours.wdata1 = colours_copy.rdata0;
                            colours_copy.addr1 = temp_2; colours_copy.wdata1 = colours_copy.rdata0;
                            y_cursor_addr = tm_dodir ? yNEXT : yPREV;                                                           // MOVE TO THE NEXT CHARACTER IN THE COLUMN
                        }
                        tiles.addr1 = xSAVED; tiles.wdata1 = new_tile;                                                          // WRITE BLANK OR WRAPPED CHARACTER
                        tiles_copy.addr1 = xSAVED; tiles_copy.wdata1 = new_tile;
                        colours.addr1 = xSAVED; colours.wdata1 = new_colour;
                        colours_copy.addr1 = xSAVED; colours_copy.wdata1 = new_colour;
                        x_cursor = xNEXT;
                    }
                    tm_offset_y = 0;
                }
                case 2: {                                                                                                   // CLEAR
                    tiles.wdata1 = 0; tiles_copy.wdata1 = 0; colours.wdata1 = 15h1000; colours_copy.wdata1 = 15h1000;
                    while( tmcsaddr != 1344 ) {
                        tiles.addr1 = tmcsaddr; tiles_copy.addr1 = tmcsaddr;
                        colours.addr1 = tmcsaddr; colours_copy.addr1 = tmcsaddr;
                        tmcsaddr = tmcsNEXT;
                    }
                    tm_offset_x = 0;
                    tm_offset_y = 0;
                }
            }
            tm_active = 0;
        } else {
            tmcsaddr = 0; y_cursor_addr = 0; x_cursor = 0;                                                                  // RESET SCROLL/WRAP
        }
    }
}

algorithm tilebitmapwriter(
    input   uint6   tile_writer_tile,
    input   uint4   tile_writer_line,
    input   uint16  tile_writer_bitmap,

    simple_dualport_bram_port1 tiles16x16
) <autorun,reginputs> {
    tiles16x16.wenable1 := 1;
    always_after {
        tiles16x16.addr1 = { tile_writer_tile, tile_writer_line };
        tiles16x16.wdata1 = tile_writer_bitmap;
    }
}

