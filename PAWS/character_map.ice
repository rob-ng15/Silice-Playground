algorithm character_map(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,
    output! uint1   character_map_display,

    // TPU to SET characters, background, foreground
    input   uint7   tpu_x,
    input   uint5   tpu_y,
    input   uint8   tpu_character,
    input   uint6   tpu_foreground,
    input   uint7   tpu_background,
    input   uint3   tpu_write,

    output  uint1   tpu_active
) <autorun> {
    // Character ROM 8x16
    brom uint8 characterGenerator8x16[] = {
        $include('ROM/characterROM8x16.inc')
    };

    // 80 x 30 character buffer
    // Setting background to 40 (ALPHA) allows the bitmap/background to show through
    simple_dualport_bram uint8 charactermap[2400] = { 0, pad(0) };
    simple_dualport_bram uint13 colourmap[2400] = { 13b1000000000000, pad(13b1000000000000) };

    // Character position on the screen x 0-79, y 0-29 * 80 ( fetch it two pixels ahead of the actual x pixel, so it is always ready )
    uint8 xcharacterpos <: ( pix_active ?  pix_x + 2 : 0 ) >> 3;
    uint8 xcolourpos <: ( pix_active ?  pix_x + 1 : 0 ) >> 3;
    uint12 ycharacterpos <: (( pix_vblank ? 0 : pix_y ) >> 4) * 80;

    // Derive the x and y coordinate within the current 8x16 character block x 0-7, y 0-15
    uint3 xincharacter <: pix_x[0,3];
    uint4 yincharacter <: pix_y[0,4];

    // Derive the actual pixel in the current character
    uint1 characterpixel <: characterGenerator8x16.rdata[7 - xincharacter,1];

    // CHARACTER MAP WRITER
    character_map_writer CMW(
        charactermap <:> charactermap,
        colourmap <:> colourmap,
        tpu_x <: tpu_x,
        tpu_y <: tpu_y,
        tpu_character <: tpu_character,
        tpu_foreground <: tpu_foreground,
        tpu_background <: tpu_background,
        tpu_write <: tpu_write,
        tpu_active :> tpu_active
    );

    // Set up reading of the charactermap
    charactermap.addr0 := xcharacterpos + ycharacterpos;
    colourmap.addr0 := xcolourpos + ycharacterpos;

    // Setup the reading of the characterGenerator8x16 ROM
    characterGenerator8x16.addr :=  { charactermap.rdata0, yincharacter };

    // RENDER - Default to transparent
    character_map_display := pix_active && (( characterpixel ) || ( ~colour13(colourmap.rdata0).alpha ));
    pix_red := characterpixel ? colour13(colourmap.rdata0).forered : colour13(colourmap.rdata0).backred;
    pix_green := characterpixel ? colour13(colourmap.rdata0).foregreen : colour13(colourmap.rdata0).backgreen;
    pix_blue := characterpixel ? colour13(colourmap.rdata0).foreblue : colour13(colourmap.rdata0).backblue;
}

algorithm character_map_writer(
    simple_dualport_bram_port1 charactermap,
    simple_dualport_bram_port1 colourmap,

// TPU to SET characters, background, foreground
    input   uint7   tpu_x,
    input   uint5   tpu_y,
    input   uint8   tpu_character,
    input   uint6   tpu_foreground,
    input   uint7   tpu_background,
    input   uint3   tpu_write,

    output  uint1   tpu_active
) <autorun> {
    // Counter for clearscreen
    uint12  tpu_write_addr <: tpu_active_x + tpu_active_y * 80;
    uint12  tpu_cs_addr = uninitialized;
    uint12  tpu_count = uninitialized;
    uint12  tpu_max_count = uninitialized;

    // TPU character position
    uint7 tpu_active_x = 0;
    uint5 tpu_active_y = 0;

    // BRAM write access for the TPU
    charactermap.wenable1 := 1;
    colourmap.wenable1 := 1;

    // Default to 0,0 and transparent
    charactermap.addr1 = 0; charactermap.wdata1 = 0;
    colourmap.addr1 = 0; colourmap.wdata1 = { 1b1, 6b0, 6b0 };

    while(1) {
        switch( tpu_active ) {
            case 0: {
                switch( tpu_write ) {
                    case 1: {
                        // Set cursor position
                        ( tpu_active_x, tpu_active_y ) = copycoordinates( tpu_x, tpu_y );
                    }
                    case 2: {
                        // Write character,foreground, background to current cursor position and move onto next character position
                        charactermap.addr1 = tpu_write_addr;
                        charactermap.wdata1 = tpu_character;
                        colourmap.addr1 = tpu_write_addr;
                        colourmap.wdata1 = { tpu_background, tpu_foreground };

                        tpu_active_y = ( tpu_active_x == 79 ) ? ( tpu_active_y == 29 ) ? 0 : tpu_active_y + 1 : tpu_active_y;
                        tpu_active_x = ( tpu_active_x == 79 ) ? 0 : tpu_active_x + 1;
                    }
                    case 3: {
                        // Start tpucs
                        tpu_active_x = 0;
                        tpu_active_y = 0;
                        tpu_active = 1;
                        tpu_cs_addr = 0;
                        tpu_max_count = 2400;
                    }
                    case 4: {
                        // Start tpu_clearline
                        tpu_active_x = 0;
                        tpu_active_y = tpu_y;
                        tpu_active = 1;
                        tpu_cs_addr = tpu_y * 80;
                        tpu_max_count = tpu_y * 80 + 80;
                    }
                }
            }

            // TPU WIPE - WHOLE OR PARTIAL SCREEN
            case 1: {
                while( tpu_cs_addr < tpu_max_count ) {
                    charactermap.addr1 = tpu_cs_addr;
                    charactermap.wdata1 = 0;
                    colourmap.addr1 = tpu_cs_addr;
                    colourmap.wdata1 = { 1b1, 6b0, 6b0 };
                    tpu_cs_addr = tpu_cs_addr + 1;
                }
                tpu_active = 0;
            }
        }
    }
}
