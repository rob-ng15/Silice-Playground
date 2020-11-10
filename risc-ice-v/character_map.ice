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

    output  uint3   tpu_active
) <autorun> {
    // Character ROM 8x16
    brom uint8 characterGenerator8x16[] = {
        $include('ROM/characterROM8x16.inc')
    };

    // 80 x 30 character buffer
    // Setting background to 40 (ALPHA) allows the bitmap/background to show through
    dualport_bram uint8 character[2400] = uninitialized;
    dualport_bram uint6 foreground[2400] = uninitialized;
    dualport_bram uint7 background[2400] = { 7h40, pad(7h40) };

    // Expansion map for { rr } to { rrrrrr }, { gg } to { gggggg }, { bb } to { bbbbbb }
    uint6 colourexpand2to6[4] = {  0, 21, 42, 63 };

    // Character position on the screen x 0-79, y 0-29 * 80 ( fetch it two pixels ahead of the actual x pixel, so it is always ready )
    uint8 xcharacterpos := ( pix_active ? (pix_x < 640 ) ? pix_x + 2 : 0 : 0 ) >> 3;
    uint12 ycharacterpos := (( pix_vblank ? 0 : pix_y ) >> 4) * 80;

    // Derive the x and y coordinate within the current 8x16 character block x 0-7, y 0-15
    uint3 xincharacter := (pix_x) & 7;
    uint4 yincharacter := (pix_y) & 15;

    // Derive the actual pixel in the current character
    uint1 characterpixel := characterGenerator8x16.rdata[7 - xincharacter,1];

    // TPU character position
    uint7 tpu_active_x = 0;
    uint5 tpu_active_y = 0;

    // Set up reading of character and attribute memory
    // character.rdata0 is the character, foreground.rdata0 and background.rdata0 are the attribute being rendered
    character.addr0 := xcharacterpos + ycharacterpos;
    character.wenable0 := 0;
    foreground.addr0 := xcharacterpos + ycharacterpos;
    foreground.wenable0 := 0;
    background.addr0 := xcharacterpos + ycharacterpos;
    background.wenable0 := 0;

    // BRAM write access for the TPU
    character.wenable1 := 1;
    background.wenable1 := 1;
    foreground.wenable1 := 1;

    // Setup the reading of the characterGenerator8x16 ROM
    characterGenerator8x16.addr :=  character.rdata0 * 16 + yincharacter;

    // Default to transparent
    character_map_display := pix_active && (( characterpixel ) || ( ~colour7(background.rdata0).alpha ));

    // Default to 0,0 and transparent
    character.addr1 = 0; character.wdata1 = 0;
    background.addr1 = 0; background.wdata1 = 64;
    foreground.addr1 = 0; foreground.wdata1 = 0;

    // Render the character map
    while(1) {
        if( character_map_display ) {
            // CHARACTER from characterGenerator8x16
            // Determine if background or foreground
            pix_red = characterpixel ? colour6(foreground.rdata0).red : colour7(background.rdata0).red;
            pix_green = characterpixel ? colour6(foreground.rdata0).green : colour7(background.rdata0).green;
            pix_blue = characterpixel ? colour6(foreground.rdata0).blue : colour7(background.rdata0).blue;
        }

        switch( tpu_active ) {
            case 1: {
                // Clear the character map - implements tpucs!
                character.wdata1 = 0;
                background.wdata1 = 64;
                foreground.wdata1 = 0;
                tpu_active_x = 0;
                tpu_active_y = 0;
                tpu_active = 2;
            }
            case 2: {
                character.addr1 = tpu_active_x + tpu_active_y * 80;
                background.addr1 = tpu_active_x + tpu_active_y * 80;
                foreground.addr1 = tpu_active_x + tpu_active_y * 80;
                tpu_active_y = ( tpu_active_x == 79 ) ? tpu_active_y + 1 : tpu_active_y;
                tpu_active_x = ( tpu_active_x == 79 ) ? 0 : tpu_active_x + 1;
                tpu_active = ( tpu_active_x == 79 ) && ( tpu_active_y == 29 ) ? 3 : 2;
            }
            case 3: {
                tpu_active_x = 0;
                tpu_active_y = 0;
                tpu_active = 0;
            }

            default: {
                switch( tpu_write ) {
                    case 1: {
                        // Set cursor position
                        tpu_active_x = tpu_x;
                        tpu_active_y = tpu_y;
                    }
                    case 2: {
                        // Write character,foreground, background to current cursor position and move onto next character position
                        character.addr1 = tpu_active_x + tpu_active_y * 80;
                        background.addr1 = tpu_active_x + tpu_active_y * 80;
                        foreground.addr1 = tpu_active_x + tpu_active_y * 80;
                        character.wdata1 = tpu_character;
                        background.wdata1 = tpu_background;
                        foreground.wdata1 = tpu_foreground;

                        tpu_active_y = ( tpu_active_x == 79 ) ? ( tpu_active_y == 29 ) ? 0 : tpu_active_y + 1 : tpu_active_y;
                        tpu_active_x = ( tpu_active_x == 79 ) ? 0 : tpu_active_x + 1;
                    }
                    case 3: {
                        // Start tpucs!
                        tpu_active = 1;
                    }
                }
            }
        } // tpu_active

    }
}
