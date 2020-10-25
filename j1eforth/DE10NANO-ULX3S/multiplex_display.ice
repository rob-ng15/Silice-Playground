algorithm multiplex_display(
    input   uint10 pix_x,
    input   uint10 pix_y,
    input   uint1  pix_active,
    input   uint1  pix_vblank,
    output! uint6 pix_red,
    output! uint6 pix_green,
    output! uint6 pix_blue,

    // BACKGROUND
    input uint2 background_r,
    input uint2 background_g,
    input uint2 background_b,

    // TILEMAP
    input uint2 tilemap_r,
    input uint2 tilemap_g,
    input uint2 tilemap_b,
    input uint1 tilemap_display,
    
    // LOWER SPRITES
    input uint2 lower_sprites_r,
    input uint2 lower_sprites_g,
    input uint2 lower_sprites_b,
    input uint1 lower_sprites_display,

    // BITMAP
    input uint2 bitmap_r,
    input uint2 bitmap_g,
    input uint2 bitmap_b,
    input uint1 bitmap_display,

    // UPPER SPRITES
    input uint2 upper_sprites_r,
    input uint2 upper_sprites_g,
    input uint2 upper_sprites_b,
    input uint1 upper_sprites_display,

    // CHARACTER MAP
    input uint2 character_map_r,
    input uint2 character_map_g,
    input uint2 character_map_b,
    input uint1 character_map_display,
    
    // TERMINAL
    input uint2 terminal_r,
    input uint2 terminal_g,
    input uint2 terminal_b,
    input uint1 terminal_display
) <autorun> {
    // RGB is background by default
    pix_red   := { {3{background_r}} };
    pix_green := { {3{background_g}} };
    pix_blue  := { {3{background_b}} };
        
    // Draw the screen
    while (1) {        
        if( pix_active ) {
            // wait until pix_active THEN BACKGROUND -> TILEMAP -> LOWER SPRITES -> BITMAP -> UPPER SPRITES -> CHARACTER MAP -> TERMINAL
            if( terminal_display ) {
                pix_red = { {3{terminal_r}} };
                pix_green = { {3{terminal_g}} };
                pix_blue = { {3{terminal_b}} };
            } else {
                if( character_map_display ) {
                    pix_red = { {3{character_map_r}} };
                    pix_green = { {3{character_map_g}} };
                    pix_blue = { {3{character_map_b}} };
                } else {
                    if( upper_sprites_display ) {
                        pix_red = { {3{upper_sprites_r}} };
                        pix_green = { {3{upper_sprites_g}} };
                        pix_blue = { {3{upper_sprites_b}} };
                    } else {
                        if( bitmap_display ) {
                            pix_red = { {3{bitmap_r}} };
                            pix_green = { {3{bitmap_g}} };
                            pix_blue = { {3{bitmap_b}} };
                        } else {
                            if( lower_sprites_display ) {
                                pix_red = { {3{lower_sprites_r}} };
                                pix_green = { {3{lower_sprites_g}} };
                                pix_blue = { {3{lower_sprites_b}} };
                            } else {
                                if( tilemap_display ) {
                                    pix_red = { {3{tilemap_r}} };
                                    pix_green = { {3{tilemap_g}} };
                                    pix_blue = { {3{tilemap_b}} };
                                }
                            }
                        }
                    }
                }
            }
        } // pix_active
    }
}
