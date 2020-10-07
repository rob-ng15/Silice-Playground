algorithm character_map(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,
    output! uint1   character_map_display,
    
    // TPU to SET characters, background, foreground
    input uint7 tpu_x,
    input uint5 tpu_y,
    input uint8 tpu_character,
    input uint9 tpu_foreground,
    input uint10 tpu_background,
    input uint2 tpu_write
) <autorun> {
    // Character ROM 8x16
    //uint8 characterGenerator8x16[] = {
    //};
    brom uint8 characterGenerator8x16[] = {
        $include('characterROM8x16.inc')
    };
    
    // 80 x 30 character buffer
    // Setting background to 200 (ALPHA) allows the bitmap/background to show through
    dualport_bram uint8 character[2400] = uninitialized;
    dualport_bram uint9 foreground[2400] = uninitialized;   // { rrrgggbbb }
    dualport_bram uint10 background[2400] = uninitialized;  // { Arrrgggbbb }

    // Expansion map for { rrr } to { rrrrrr }, { ggg } to { gggggg }, { bbb } to { bbbbbb }
    // or { rrr } tp { rrrrrrrr }, { ggg } to { gggggggg }, { bbb } to { bbbbbbbb }
    uint6 colourexpand3to6[8] = {  0, 9, 18, 27, 36, 45, 54, 255 };
    uint6 colourexpand3to8[8] = {  0, 36, 73, 109, 145, 182, 218, 255 };

    // Character position on the screen x 0-79, y 0-29 * 80 ( fetch it one pixel ahead of the actual x pixel, so it is always ready )
    uint8 xcharacterpos := (pix_x+1) >> 3;
    uint12 ycharacterpos := ((pix_y) >> 4) * 80; // 16 pixel high characters
    
    // Derive the x and y coordinate within the current 8x16 character block x 0-7, y 0-15
    uint3 xincharacter := (pix_x) & 7;
    uint4 yincharacter := (pix_y) & 15;

    // Derive the actual pixel in the current character
    uint1 characterpixel := (characterGenerator8x16.rdata << xincharacter >> 7) & 1; //((characterGenerator8x16[ character.rdata0 * 16 + yincharacter ] << xincharacter) >> 7) & 1;

    // TPU work variable storage
    uint7 tpu_active_x = 0;
    uint5 tpu_active_y = 0;

    // Setup the reading of the character generator memory
    characterGenerator8x16.addr := character.rdata0 * 16 + yincharacter;

    // Set up reading of character and attribute memory
    // character.rdata0 is the character, foreground.rdata0 and background.rdata0 are the attribute being rendered
    character.addr0 := xcharacterpos + ycharacterpos;
    character.wenable0 := 0;
    foreground.addr0 := xcharacterpos + ycharacterpos;
    foreground.wenable0 := 0;
    background.addr0 := xcharacterpos + ycharacterpos;
    background.wenable0 := 0;

    // BRAM write access for the TPU 
    character.addr1 := tpu_active_x + tpu_active_y * 80;
    character.wenable1 := 0;
    background.addr1 := tpu_active_x + tpu_active_y * 80;
    background.wenable1 := 0;
    foreground.addr1 := tpu_active_x + tpu_active_y * 80;
    foreground.wenable1 := 0;

    // TPU
    // tpu_write controls actions
    // 1 = set cursor position
    // 2 = draw character in foreground,background at x,y and mvoe to next position
    always {
        switch( tpu_write ) {
            case 1: {
                // Set cursor position
                tpu_active_x = tpu_x;
                tpu_active_y = tpu_y;
            }
            case 2: {
                // Write character,foreground, background to current cursor position and move onto next character position
                character.wdata1 = tpu_character;
                character.wenable1 = 1;
                background.wdata1 = tpu_background;
                background.wenable1 = 1;
                foreground.wdata1 = tpu_foreground;
                foreground.wenable1 = 1;
                
                if( tpu_active_x == 79 ) {
                    tpu_active_x = 0;
                    if( tpu_active_y == 29 ) {
                        tpu_active_y = 0;
                    } else {
                        tpu_active_y = tpu_active_y + 1;
                    }
                } else {
                    tpu_active_x = tpu_active_x + 1;
                }
            }
            default: {}
        } // TPU
    }

    // Render the character map
    while(1) {
        if( pix_active ) {
            // CHARACTER from characterGenerator8x16
            // Determine if background or foreground
            switch( characterpixel ) {
            case 0: {
                    // BACKGROUND
                    if( ~colour10(background.rdata0).alpha ) {
                        pix_red = colourexpand3to$color_depth$[ colour10(background.rdata0).red ];
                        pix_green = colourexpand3to$color_depth$[ colour10(background.rdata0).green ];
                        pix_blue = colourexpand3to$color_depth$[ colour10(background.rdata0).blue ];
                        character_map_display = 1;
                    } else {
                        character_map_display = 0;
                    }
                }
                case 1: {
                    // foreground
                    pix_red = colourexpand3to$color_depth$[ colour9(foreground.rdata0).red ];
                    pix_green = colourexpand3to$color_depth$[ colour9(foreground.rdata0).green ];
                    pix_blue = colourexpand3to$color_depth$[ colour9(foreground.rdata0).blue ];
                    character_map_display = 1;
                }
            }
        } 
    }
}
