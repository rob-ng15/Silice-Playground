algorithm multiplex_display(
    input   uint10 pix_x,
    input   uint10 pix_y,
    input   uint1  pix_active,
    input   uint1  pix_vblank,
    output! uint8 pix_red,
    output! uint8 pix_green,
    output! uint8 pix_blue,

    // DISPLAY ORDER AND COLOUR/BW MODE
    input   uint2   display_order,
    input   uint1   colour,

    // BACKGROUND
    input uint8 background_p,

    // TILEMAPS
    input uint6 lower_tilemap_p,
    input uint1 lower_tilemap_display,
    input uint6 upper_tilemap_p,
    input uint1 upper_tilemap_display,

    // SPRITES
    input uint6 lower_sprites_p,
    input uint1 lower_sprites_display,
    input uint6 upper_sprites_p,
    input uint1 upper_sprites_display,

    // BITMAP
    input uint6 bitmap_p,
    input uint1 bitmap_display,

    // CHARACTER MAP
    input uint6 character_map_p,
    input uint1 character_map_display,

    // TERMINAL
    input uint6 terminal_p,
    input uint1 terminal_display
) <autorun> {
    uint6    pixel = uninitialised;
    selectlayer LAYER(
        display_order <: display_order,
        terminal_display <: terminal_display,
        terminal <: terminal_p,
        character_map_display <: character_map_display,
        character_map <: character_map_p,
        upper_sprites_display <: upper_sprites_display,
        upper_sprites <: upper_sprites_p,
        bitmap_display <: bitmap_display,
        bitmap <: bitmap_p,
        lower_sprites_display <: lower_sprites_display,
        lower_sprites <: lower_sprites_p,
        lower_tilemap_display <: lower_tilemap_display,
        lower_tilemap <: lower_tilemap_p,
        upper_tilemap_display <: upper_tilemap_display,
        upper_tilemap <: upper_tilemap_p,
        background <: background_p,
        pix :> pixel
    );

    // SELECT COLOUR OR BLACK AND WHITE
    always {
        if( colour ) {
            pix_red   = { {4{pixel[4,2]}} };
            pix_green = { {4{pixel[2,2]}} };
            pix_blue  = { {4{pixel[0,2]}} };
        } else {
            pix_red   = { pixel[4,2], pixel[0,6] };
            pix_green = { pixel[4,2], pixel[0,6] };
            pix_blue  = { pixel[4,2], pixel[0,6] };
        }
    }
}

// CHOOSE LAY TO DISPLAY
algorithm selectlayer(
    input   uint2   display_order,
    input   uint1   terminal_display,
    input   uint6   terminal,
    input   uint1   character_map_display,
    input   uint6   character_map,
    input   uint1   upper_sprites_display,
    input   uint6   upper_sprites,
    input   uint1   bitmap_display,
    input   uint6   bitmap,
    input   uint1   lower_sprites_display,
    input   uint6   lower_sprites,
    input   uint1   lower_tilemap_display,
    input   uint6   lower_tilemap,
    input   uint1   upper_tilemap_display,
    input   uint6   upper_tilemap,
    input   uint6   background,

    output! uint6   pix
) <autorun> {
    always {
        switch( display_order ) {
            case 0: { // BACKGROUND -> LOWER TILEMAP -> UPPER TILEMAP -> LOWER_SPRITES -> BITMAP -> UPPER_SPRITES -> CHARACTER_MAP
                pix = ( terminal_display ) ? terminal :
                            ( character_map_display ) ? character_map :
                            ( upper_sprites_display ) ? upper_sprites :
                            ( bitmap_display ) ? bitmap :
                            ( lower_sprites_display ) ? lower_sprites :
                            ( upper_tilemap_display ) ? upper_tilemap :
                            ( lower_tilemap_display ) ? lower_tilemap :
                            background;
            }
            case 1: { // BACKGROUND -> LOWER TILEMAP -> UPPER TILEMAP -> BITMAP -> LOWER_SPRITES -> UPPER_SPRITES -> CHARACTER_MAP
                pix = ( terminal_display ) ? terminal :
                        ( character_map_display ) ? character_map :
                        ( upper_sprites_display ) ? upper_sprites :
                        ( lower_sprites_display ) ? lower_sprites :
                        ( bitmap_display ) ? bitmap :
                        ( upper_tilemap_display ) ? upper_tilemap :
                        ( lower_tilemap_display ) ? lower_tilemap :
                        background;
            }
            case 2: { // BACKGROUND -> BITMAP -> LOWER TILEMAP -> UPPER TILEMAP -> LOWER_SPRITES -> UPPER_SPRITES -> CHARACTER_MAP
                pix = ( terminal_display ) ? terminal :
                        ( character_map_display ) ? character_map :
                        ( upper_sprites_display ) ? upper_sprites :
                        ( lower_sprites_display ) ? lower_sprites :
                        ( upper_tilemap_display ) ? upper_tilemap :
                        ( lower_tilemap_display ) ? lower_tilemap :
                        ( bitmap_display ) ? bitmap :
                        background;
            }
            case 3: { // BACKGROUND -> LOWER TILEMAP -> UPPER TILEMAP -> LOWER_SPRITES -> UPPER_SPRITES -> BITMAP -> CHARACTER_MAP
                pix = ( terminal_display ) ? terminal :
                        ( character_map_display ) ? character_map :
                        ( bitmap_display ) ? bitmap :
                        ( upper_sprites_display ) ? upper_sprites :
                        ( lower_sprites_display ) ? lower_sprites :
                        ( upper_tilemap_display ) ? upper_tilemap :
                        ( lower_tilemap_display ) ? lower_tilemap :
                        background;
            }
        }
    }
}
