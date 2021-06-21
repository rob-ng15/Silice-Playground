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

    // TILEMAPS
    input uint2 lower_tilemap_r,
    input uint2 lower_tilemap_g,
    input uint2 lower_tilemap_b,
    input uint1 lower_tilemap_display,
    input uint2 upper_tilemap_r,
    input uint2 upper_tilemap_g,
    input uint2 upper_tilemap_b,
    input uint1 upper_tilemap_display,

    // SPRITES
    input uint2 lower_sprites_r,
    input uint2 lower_sprites_g,
    input uint2 lower_sprites_b,
    input uint1 lower_sprites_display,
    input uint2 upper_sprites_r,
    input uint2 upper_sprites_g,
    input uint2 upper_sprites_b,
    input uint1 upper_sprites_display,

    // BITMAP
    input uint2 bitmap_r,
    input uint2 bitmap_g,
    input uint2 bitmap_b,
    input uint1 bitmap_display,


    // CHARACTER MAP
    input uint2 character_map_r,
    input uint2 character_map_g,
    input uint2 character_map_b,
    input uint1 character_map_display
) <autorun> {
    uint8   red8 = uninitialised;
    uint8   green8 = uninitialised;
    uint8   blue8 = uninitialised;

    expandcolour RED(
        display_order <: display_order,
        character_map_display <: character_map_display,
        character_map <: character_map_r,
        upper_sprites_display <: upper_sprites_display,
        upper_sprites <: upper_sprites_r,
        bitmap_display <: bitmap_display,
        bitmap <: bitmap_r,
        lower_sprites_display <: lower_sprites_display,
        lower_sprites <: lower_sprites_r,
        lower_tilemap_display <: lower_tilemap_display,
        lower_tilemap <: lower_tilemap_r,
        upper_tilemap_display <: upper_tilemap_display,
        upper_tilemap <: upper_tilemap_r,
        background <: background_r,

        pix :> red8
    );
    expandcolour GREEN(
        display_order <: display_order,
        character_map_display <: character_map_display,
        character_map <: character_map_g,
        upper_sprites_display <: upper_sprites_display,
        upper_sprites <: upper_sprites_g,
        bitmap_display <: bitmap_display,
        bitmap <: bitmap_g,
        lower_sprites_display <: lower_sprites_display,
        lower_sprites <: lower_sprites_g,
        lower_tilemap_display <: lower_tilemap_display,
        lower_tilemap <: lower_tilemap_g,
        upper_tilemap_display <: upper_tilemap_display,
        upper_tilemap <: upper_tilemap_g,
        background <: background_g,

        pix :> green8
    );
    expandcolour BLUE(
        display_order <: display_order,
        character_map_display <: character_map_display,
        character_map <: character_map_b,
        upper_sprites_display <: upper_sprites_display,
        upper_sprites <: upper_sprites_b,
        bitmap_display <: bitmap_display,
        bitmap <: bitmap_b,
        lower_sprites_display <: lower_sprites_display,
        lower_sprites <: lower_sprites_b,
        lower_tilemap_display <: lower_tilemap_display,
        lower_tilemap <: lower_tilemap_b,
        upper_tilemap_display <: upper_tilemap_display,
        upper_tilemap <: upper_tilemap_b,
        background <: background_b,

        pix :> blue8
    );

    pix_red   := red8;
    pix_green := green8;
    pix_blue  := blue8;
}

// EXPAND FROM 2 bit to 8 bit colour
algorithm expandcolour(
    input   uint2   display_order,
    input   uint1   character_map_display,
    input   uint2   character_map,
    input   uint1   upper_sprites_display,
    input   uint2   upper_sprites,
    input   uint1   bitmap_display,
    input   uint2   bitmap,
    input   uint1   lower_sprites_display,
    input   uint2   lower_sprites,
    input   uint1   lower_tilemap_display,
    input   uint2   lower_tilemap,
    input   uint1   upper_tilemap_display,
    input   uint2   upper_tilemap,
    input   uint2   background,

    output! uint8   pix
) <autorun> {

    while(1) {
        switch( display_order ) {
            case 0: {
                // BACKGROUND -> LOWER TILEMAP -> UPPER TILEMAP -> LOWER_SPRITES -> BITMAP -> UPPER_SPRITES -> CHARACTER_MAP
                pix = ( character_map_display ) ? { {4{character_map}} } :
                                            ( upper_sprites_display ) ? { {4{upper_sprites}} } :
                                            ( bitmap_display ) ? { {4{bitmap}} } :
                                            ( lower_sprites_display ) ? { {4{lower_sprites}} } :
                                            ( upper_tilemap_display ) ? { {4{upper_tilemap}} } :
                                            ( lower_tilemap_display ) ? { {4{lower_tilemap}} } :
                                            { {4{background}} };
            }
            case 1: {
                // BACKGROUND -> LOWER TILEMAP -> UPPER TILEMAP -> BITMAP -> LOWER_SPRITES -> UPPER_SPRITES -> CHARACTER_MAP
                pix = ( character_map_display ) ? { {4{character_map}} } :
                                            ( upper_sprites_display ) ? { {4{upper_sprites}} } :
                                            ( lower_sprites_display ) ? { {4{lower_sprites}} } :
                                            ( bitmap_display ) ? { {4{bitmap}} } :
                                            ( upper_tilemap_display ) ? { {4{upper_tilemap}} } :
                                            ( lower_tilemap_display ) ? { {4{lower_tilemap}} } :
                                            { {4{background}} };
            }
            case 2: {
                // BACKGROUND -> BITMAP -> LOWER TILEMAP -> UPPER TILEMAP -> LOWER_SPRITES -> UPPER_SPRITES -> CHARACTER_MAP
                pix = ( character_map_display ) ? { {4{character_map}} } :
                                            ( upper_sprites_display ) ? { {4{upper_sprites}} } :
                                            ( lower_sprites_display ) ? { {4{lower_sprites}} } :
                                            ( upper_tilemap_display ) ? { {4{upper_tilemap}} } :
                                            ( lower_tilemap_display ) ? { {4{lower_tilemap}} } :
                                            ( bitmap_display ) ? { {4{bitmap}} } :
                                            { {4{background}} };
            }
            case 3: {
                // BACKGROUND -> LOWER TILEMAP -> UPPER TILEMAP -> LOWER_SPRITES -> UPPER_SPRITES -> BITMAP -> CHARACTER_MAP
                pix = ( character_map_display ) ? { {4{character_map}} } :
                                            ( bitmap_display ) ? { {4{bitmap}} } :
                                            ( upper_sprites_display ) ? { {4{upper_sprites}} } :
                                            ( lower_sprites_display ) ? { {4{lower_sprites}} } :
                                            ( upper_tilemap_display ) ? { {4{upper_tilemap}} } :
                                            ( lower_tilemap_display ) ? { {4{lower_tilemap}} } :
                                            { {4{background}} };
            }
        }
    }
}
