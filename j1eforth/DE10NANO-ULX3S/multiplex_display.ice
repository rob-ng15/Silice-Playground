algorithm multiplex_display(
    input   uint10 pix_x,
    input   uint10 pix_y,
    input   uint1  pix_active,
    input   uint1  pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,

    // BACKGROUND
    input uint$color_depth$ background_r,
    input uint$color_depth$ background_g,
    input uint$color_depth$ background_b,

    // LOWER SPRITES
    input uint$color_depth$ lower_sprites_r,
    input uint$color_depth$ lower_sprites_g,
    input uint$color_depth$ lower_sprites_b,
    input uint1   lower_sprites_display,

    // BITMAP
    input uint$color_depth$ bitmap_r,
    input uint$color_depth$ bitmap_g,
    input uint$color_depth$ bitmap_b,
    input uint1   bitmap_display,

    // UPPER SPRITES
    input uint$color_depth$ upper_sprites_r,
    input uint$color_depth$ upper_sprites_g,
    input uint$color_depth$ upper_sprites_b,
    input uint1   upper_sprites_display,

    // CHARACTER MAP
    input uint$color_depth$ character_map_r,
    input uint$color_depth$ character_map_g,
    input uint$color_depth$ character_map_b,
    input uint1   character_map_display,
    
    // TERMINAL
    input uint$color_depth$ terminal_r,
    input uint$color_depth$ terminal_g,
    input uint$color_depth$ terminal_b,
    input uint1   terminal_display
) <autorun> {
    // RGB is { 0, 0, 0 } by default
    pix_red   := 0;
    pix_green := 0;
    pix_blue  := 0;
        
    // Draw the screen
    while (1) {        
        if( pix_active ) {
            // wait until pix_active THEN BACKGROUND -> LOWER SPRITES -> BITMAP -> UPPER SPRITES -> CHARACTER MAP -> TERMINAL
            pix_red = ( terminal_display ) ? terminal_r : ( character_map_display ) ? character_map_r : ( upper_sprites_display ) ? upper_sprites_r : ( bitmap_display ) ? bitmap_r : ( lower_sprites_display ) ? lower_sprites_r : background_r;
            pix_green = ( terminal_display ) ? terminal_g : ( character_map_display ) ? character_map_g : ( upper_sprites_display ) ? upper_sprites_g : ( bitmap_display ) ? bitmap_g : ( lower_sprites_display ) ? lower_sprites_g : background_g;
            pix_blue = ( terminal_display ) ? terminal_b : ( character_map_display ) ? character_map_b : ( upper_sprites_display ) ? upper_sprites_b : ( bitmap_display ) ? bitmap_b : ( lower_sprites_display ) ? lower_sprites_b : background_b;
        } // pix_active
    }
}
