algorithm multiplex_display(
    input   uint10 pix_x,
    input   uint10 pix_y,
    input   uint1  pix_active,
    input   uint1  pix_vblank,
    output! uint8 pix_red,
    output! uint8 pix_green,
    output! uint8 pix_blue,

    // DISPLAY ORDER
    input   uint2   display_order,

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
    uint8   red8 = uninitialised;
    uint8   green8 = uninitialised;
    uint8   blue8 = uninitialised;

    expandcolour RED(
        display_order <: display_order,
        terminal_display <: terminal_display,
        terminal <: terminal_r,
        character_map_display <: character_map_display,
        character_map <: character_map_r,
        upper_sprites_display <: upper_sprites_display,
        upper_sprites <: upper_sprites_r,
        bitmap_display <: bitmap_display,
        bitmap <: bitmap_r,
        lower_sprites_display <: lower_sprites_display,
        lower_sprites <: lower_sprites_r,
        tilemap_display <: tilemap_display,
        tilemap <: tilemap_r,
        background <: background_r,

        pix :> red8
    );
    expandcolour GREEN(
        display_order <: display_order,
        terminal_display <: terminal_display,
        terminal <: terminal_g,
        character_map_display <: character_map_display,
        character_map <: character_map_g,
        upper_sprites_display <: upper_sprites_display,
        upper_sprites <: upper_sprites_g,
        bitmap_display <: bitmap_display,
        bitmap <: bitmap_g,
        lower_sprites_display <: lower_sprites_display,
        lower_sprites <: lower_sprites_g,
        tilemap_display <: tilemap_display,
        tilemap <: tilemap_g,
        background <: background_g,

        pix :> green8
    );
    expandcolour BLUE(
        display_order <: display_order,
        terminal_display <: terminal_display,
        terminal <: terminal_b,
        character_map_display <: character_map_display,
        character_map <: character_map_b,
        upper_sprites_display <: upper_sprites_display,
        upper_sprites <: upper_sprites_b,
        bitmap_display <: bitmap_display,
        bitmap <: bitmap_b,
        lower_sprites_display <: lower_sprites_display,
        lower_sprites <: lower_sprites_b,
        tilemap_display <: tilemap_display,
        tilemap <: tilemap_b,
        background <: background_b,

        pix :> blue8
    );

    pix_red := 0;
    pix_green := 0;
    pix_blue := 0;


    while (1) {
        if( pix_active ) {
            pix_red = red8;
            pix_green = green8;
            pix_blue = blue8;
        }
    }
}

// EXPAND FROM 2 bit to 8 bit colour
algorithm expandcolour(
    input   uint2   display_order,
    input   uint1   terminal_display,
    input   uint2   terminal,
    input   uint1   character_map_display,
    input   uint2   character_map,
    input   uint1   upper_sprites_display,
    input   uint2   upper_sprites,
    input   uint1   bitmap_display,
    input   uint2   bitmap,
    input   uint1   lower_sprites_display,
    input   uint2   lower_sprites,
    input   uint1   tilemap_display,
    input   uint2   tilemap,
    input   uint2   background,

    output! uint8   pix
) <autorun> {

    while(1) {
        switch( display_order ) {
            case 0: {
                // BACKGROUND -> TILEMAP -> LOWER_SPRITES -> BITMAP -> UPPER_SPRITES -> CHARACTER_MAP -> TERMINAL
                pix = ( terminal_display ) ? { {4{terminal}} } :
                                            ( character_map_display ) ? { {4{character_map}} } :
                                            ( upper_sprites_display ) ? { {4{upper_sprites}} } :
                                            ( bitmap_display ) ? { {4{bitmap}} } :
                                            ( lower_sprites_display ) ? { {4{lower_sprites}} } :
                                            ( tilemap_display ) ? { {4{tilemap}} } :
                                            { {4{background}} };
            }
            case 1: {
                // BACKGROUND -> TILEMAP -> BITMAP -> LOWER_SPRITES -> UPPER_SPRITES -> CHARACTER_MAP -> TERMINAL
                pix = ( terminal_display ) ? { {4{terminal}} } :
                                            ( character_map_display ) ? { {4{character_map}} } :
                                            ( upper_sprites_display ) ? { {4{upper_sprites}} } :
                                            ( lower_sprites_display ) ? { {4{lower_sprites}} } :
                                            ( bitmap_display ) ? { {4{bitmap}} } :
                                            ( tilemap_display ) ? { {4{tilemap}} } :
                                            { {4{background}} };
            }
            case 2: {
                // BACKGROUND -> BITMAP -> TILEMAP -> LOWER_SPRITES -> UPPER_SPRITES -> CHARACTER_MAP -> TERMINAL
                pix = ( terminal_display ) ? { {4{terminal}} } :
                                            ( character_map_display ) ? { {4{character_map}} } :
                                            ( upper_sprites_display ) ? { {4{upper_sprites}} } :
                                            ( lower_sprites_display ) ? { {4{lower_sprites}} } :
                                            ( tilemap_display ) ? { {4{tilemap}} } :
                                            ( bitmap_display ) ? { {4{bitmap}} } :
                                            { {4{background}} };
            }
            case 3: {
                // BACKGROUND -> TILEMAP -> LOWER_SPRITES -> UPPER_SPRITES -> BITMAP -> CHARACTER_MAP -> TERMINAL
                pix = ( terminal_display ) ? { {4{terminal}} } :
                                            ( character_map_display ) ? { {4{character_map}} } :
                                            ( bitmap_display ) ? { {4{bitmap}} } :
                                            ( upper_sprites_display ) ? { {4{upper_sprites}} } :
                                            ( lower_sprites_display ) ? { {4{lower_sprites}} } :
                                            ( tilemap_display ) ? { {4{tilemap}} } :
                                            { {4{background}} };
            }
        }
    }
}
