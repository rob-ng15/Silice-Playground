algorithm character_map(
    simple_dualport_bram_port0 charactermap,
    simple_dualport_bram_port0 colourmap,

    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   character_map_display,

    input   uint1   blink,
    input   uint7   cursor_x,
    input   uint6   cursor_y,
    input   uint6   tpu_foreground,
    input   uint7   tpu_background,
    input   uint1   tpu_showcursor
) <autorun,reginputs> {
    // Character ROM 8x8
    brom uint8 characterGenerator8x8[] = {
        $include('ROM/characterROM8x8.inc')
    };

    // Character position on the screen x 0-79, y 0-59 * 80 ( fetch it two pixels ahead of the actual x pixel, so it is always ready )
    uint7   xcharacterpos <: ( pix_active ?  pix_x + 2 : 0 ) >> 3;
    uint7   xcolourpos <: ( pix_active ?  pix_x + 1 : 0 ) >> 3;
    uint6   ycharacterpos <: ( ( pix_vblank ? 0 : pix_y ) >> 3 );
    uint13  ycharacteraddress <: 80 * ycharacterpos;
    uint1   is_cursor <: tpu_showcursor & blink & ( cursor_x == ( pix_x >> 3 ) ) & ( cursor_y == ycharacterpos );

    // Derive the x and y coordinate within the current 8x8 character block x 0-7, y 0-7
    uint3 xincharacter <: 7 - pix_x[0,3];
    uint3 yincharacter <: pix_y[0,3];

    // Derive the actual pixel in the current character
    uint1 characterpixel <: characterGenerator8x8.rdata[ xincharacter, 1 ];

    // Set up reading of the charactermap
    charactermap.addr0 := xcharacterpos + ycharacteraddress; colourmap.addr0 := xcolourpos + ycharacteraddress;

    // Setup the reading of the characterGenerator8x16 ROM
    characterGenerator8x8.addr := { charactermap.rdata0, yincharacter };

    // RENDER - Default to transparent
    character_map_display := pix_active & ( characterpixel | ~colour13(colourmap.rdata0).alpha | is_cursor );
    pixel := is_cursor ? characterpixel ? tpu_background : tpu_foreground
                        : characterpixel ? colour13(colourmap.rdata0).foreground : colour13(colourmap.rdata0).background;
}

algorithm cmcursorx(
    input   uint7   tpu_active_x,
    output  uint7   NEXT,
    output  uint1   ATLAST
) <autorun> {
    always_after {
        ATLAST = ( tpu_active_x == 79 );
        NEXT = tpu_active_x + 1;
    }
}
algorithm cmcursory(
    input   uint6   tpu_active_y,
    output  uint6   NEXT,
    output  uint1   ATLAST
) <autorun> {
    always_after {
        ATLAST = ( tpu_active_y == 59 );
        NEXT = tpu_active_y + 1;
    }
}
algorithm cmaddresses(
    input   uint7   tpu_active_x,
    input   uint6   tpu_active_y,
    input   uint7   tpu_x,
    input   uint6   tpu_y,
    output  uint13  WRITEADDR,
    output  uint13  YSTARTADDR,
    output  uint13  YENDADDR
) <autorun> {
    always_after {
        WRITEADDR = tpu_active_x + tpu_active_y * 80;
        YSTARTADDR = tpu_y * 80;
        YENDADDR = YSTARTADDR + 80;
    }
}

algorithm character_map_writer(
    simple_dualport_bram_port1 charactermap,
    simple_dualport_bram_port1 colourmap,

// TPU to SET characters, background, foreground
    input   uint7   tpu_x,
    input   uint6   tpu_y,
    input   uint9   tpu_character,
    input   uint6   tpu_foreground,
    input   uint7   tpu_background,
    input   uint3   tpu_write,

    output  uint3   tpu_active,
    output  uint9   curses_character,
    output  uint7   curses_background,
    output  uint6   curses_foreground,

    output  uint7   cursor_x,
    output  uint6   cursor_y
) <autorun,reginputs> {
    // COPY OF CHARCTER MAP FOR THE CURSES BUFFER
    simple_dualport_bram uint22 charactermap_copy[4800] = uninitialized;

    // Counter for clearscreen
    uint13  tpu_start_cs_addr = uninitialized;      uint13  tpu_cs_addr = uninitialized;                    uint13  tpu_cs_addr_next <:: tpu_cs_addr + 1;
    uint13  tpu_max_count = uninitialized;

    // TPU character position
    uint7   tpu_active_x = 0;                       cmcursorx TPUX( tpu_active_x <: tpu_active_x );
    uint6   tpu_active_y = 0;                       cmcursory TPUY( tpu_active_y <: tpu_active_y );

    // ADDRESS CALCULATIONS AND BRAM write access for the TPU
    cmaddresses TPUA( tpu_active_x <: tpu_active_x, tpu_active_y <: tpu_active_y, tpu_x <: tpu_x, tpu_y <: tpu_y );
    charactermap.wenable1 := 1; colourmap.wenable1 := 1; charactermap_copy.wenable1 := 1;

    // OUTPUT FROM CURSES BUFFER AND CURSOR POSITION
    curses_character := charactermap_copy.rdata0[0,9]; curses_foreground := charactermap_copy.rdata0[9,6]; curses_background := charactermap_copy.rdata0[15,7];
    cursor_x := tpu_active_x; cursor_y := tpu_active_y;

    // CURSES COPY ADDRESS
    charactermap_copy.addr0 := ( tpu_active[2,1] ) ? tpu_cs_addr : TPUA.WRITEADDR;

    always_after {
        switch( tpu_write ) {
            default: {}
            case 1: {                                                                                                                                   // Set cursor position
                ( tpu_active_x, tpu_active_y ) = copycoordinates( tpu_x, tpu_y );
            }
            case 2: {                                                                                                                                   // Write character,foreground, background and move
                charactermap.addr1 = TPUA.WRITEADDR;
                charactermap.wdata1 = tpu_character;
                colourmap.addr1 = TPUA.WRITEADDR;
                colourmap.wdata1 = { tpu_background, tpu_foreground };
                if( TPUX.ATLAST ) {
                    tpu_active_x = 0; tpu_active_y = TPUY.ATLAST ? 0 : TPUY.NEXT;
                } else {
                    tpu_active_x = TPUX.NEXT;
                }
            }
            case 3: { tpu_active_x = 0; tpu_active_y = 0; tpu_active = 1; tpu_start_cs_addr = 0; tpu_max_count = 4800; }                                // Start tpucs
            case 4: { tpu_active_x = 0; tpu_active_y = tpu_y; tpu_active = 1; tpu_start_cs_addr = TPUA.YSTARTADDR; tpu_max_count = TPUA.YENDADDR; }     // Start tpu_clearline
            case 5: {                                                                                                                                   // Write character, foreground, background to curses buffer
                charactermap_copy.addr1 = TPUA.WRITEADDR;
                charactermap_copy.wdata1 = { tpu_background, tpu_foreground, tpu_character };
            }
            case 6: { tpu_active = 2; tpu_start_cs_addr = 0; }                                                                                          // Start curses wipe
            case 7: { tpu_active = 4; tpu_start_cs_addr = 0; }                                                                                          // Start curses copy
        }
    }

    while(1) {
        if( |tpu_active ) {
            tpu_cs_addr = tpu_start_cs_addr;
            onehot( tpu_active ) {
                case 0: {                                                                                                                               // TPU WIPE - WHOLE OR PARTIAL SCREEN (LINE)
                    charactermap.wdata1 = 0; colourmap.wdata1 = 13b1000000000000;
                    while( tpu_cs_addr != tpu_max_count ) {
                        charactermap.addr1 = tpu_cs_addr; colourmap.addr1 = tpu_cs_addr;
                        tpu_cs_addr = tpu_cs_addr_next;
                    }
                }
                case 1: {                                                                                                                               // CURSES WIPE
                    charactermap_copy.wdata1 = 22b1000000000000000000000;
                    while( tpu_cs_addr != 4800 ) {
                        charactermap_copy.addr1 = tpu_cs_addr;
                        tpu_cs_addr = tpu_cs_addr_next;
                    }
                }
                case 2: {                                                                                                                               // CURSES COPY
                    while( tpu_cs_addr != 4800 ) {
                        ++:
                        charactermap.addr1 = tpu_cs_addr; charactermap.wdata1 = charactermap_copy.rdata0[0,9];
                        colourmap.addr1 = tpu_cs_addr; colourmap.wdata1 = { charactermap_copy.rdata0[15,7], charactermap_copy.rdata0[9,6] };
                        tpu_cs_addr = tpu_cs_addr_next;
                    }
                }
            }
            tpu_active = 0;
        }
    }
}
