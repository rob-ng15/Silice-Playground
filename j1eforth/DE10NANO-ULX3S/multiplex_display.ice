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
    // Output defaults to 0
    pix_red   := 0;
    pix_green := 0;
    pix_blue  := 0;
        
    // Draw the screen
    while (1) {        
        // wait until pix_active THEN BACKGROUND -> TILEMAP -> LOWER SPRITES -> BITMAP -> UPPER SPRITES -> CHARACTER MAP -> TERMINAL
        if( pix_active ) {
            // Select the 2 bit r g or b and expand to 6 bit r g or b
            pix_red = ( terminal_display ) ? { {3{terminal_r}} } :
                        ( character_map_display ) ? { {3{character_map_r}} } :
                        ( upper_sprites_display ) ? { {3{upper_sprites_r}} } :
                        ( bitmap_display ) ? { {3{bitmap_r}} } :
                        ( lower_sprites_display ) ? { {3{lower_sprites_r}} } :
                        ( tilemap_display ) ? { {3{tilemap_r}} } :
                        { {3{background_r}} };
            pix_green = ( terminal_display ) ? { {3{terminal_g}} } :
                        ( character_map_display ) ? { {3{character_map_g}} } :
                        ( upper_sprites_display ) ? { {3{upper_sprites_g}} } :
                        ( bitmap_display ) ? { {3{bitmap_g}} } :
                        ( lower_sprites_display ) ? { {3{lower_sprites_g}} } :
                        ( tilemap_display ) ? { {3{tilemap_g}} } :
                        { {3{background_g}} };
            pix_blue = ( terminal_display ) ? { {3{terminal_b}} } :
                        ( character_map_display ) ? { {3{character_map_b}} } :
                        ( upper_sprites_display ) ? { {3{upper_sprites_b}} } :
                        ( bitmap_display ) ? { {3{bitmap_b}} } :
                        ( lower_sprites_display ) ? { {3{lower_sprites_b}} } :
                        ( tilemap_display ) ? { {3{tilemap_b}} } :
                        { {3{background_b}} };
        } // pix_active
    }
}
