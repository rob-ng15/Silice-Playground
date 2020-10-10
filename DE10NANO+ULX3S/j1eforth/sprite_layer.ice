// Set maximum number of sprites per layer
$$if not MAXSPRITES then
$$MAXSPRITES = 8
$$end


algorithm sprite_layer(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,
    output! uint1   sprite_layer_display,
    
    // For setting sprite characteristics
    input   uint3   sprite_set_number,
    input   uint1   sprite_set_active,
    input   uint6   sprite_set_colour,
    input   int11   sprite_set_x,
    input   int11   sprite_set_y,
    input   uint2   sprite_set_tile,
    
    // For setting sprite tile bitmaps
    input   uint3   sprite_writer_sprite,
    input   uint6   sprite_writer_line,
    input   uint16  sprite_writer_bitmap,
    
    // Flag to start the above
    input   uint4   sprite_layer_write,
    
    // SPRITE LAYER fade level
    input uint3 sprite_layer_fade
) <autorun> {
    // Expansion map for { rr } to { rrrrrr }, { gg } to { gggggg }, { bb } to { bbbbbb }
    // or { rr } tp { rrrrrrrr }, { gg } to { gggggggg }, { bb } to { bbbbbbbb }
    uint6 colourexpand2to6[4] = {  0, 21, 42, 63 };
    uint8 colourexpand2to8[4] = {  0, 85, 170, 255 };

    // Storage for the sprites
    // Stored as registers as needed instantly
    uint1 sprite_active[$MAXSPRITES$] = uninitialised;
    int11 sprite_x[$MAXSPRITES$] = uninitialised;
    int11 sprite_y[$MAXSPRITES$] = uninitialised;
    uint6 sprite_colour[$MAXSPRITES$] = uninitialised;
    uint2 sprite_tile_number[$MAXSPRITES$] = uninitialised;

    // One bram for each sprite
$$for i=0,7 do
    dualport_bram uint16 sprite_$i$_tiles[64] = uninitialised;
$$end

    uint3 sprite_fade = 0;

        // Calculate if each sprite is visible
$$for i=0,7 do
    uint1 sprite_$i$_visible := sprite_active[$i$] & ( pix_x >= sprite_x[$i$] ) & ( pix_x < sprite_x[$i$] + 16 ) & ( pix_y >= sprite_y[$i$] ) & ( pix_y < sprite_y[$i$] + 16 ) & ( sprite_$i$_tiles.rdata0 >> ( 15 - ( pix_x - sprite_x[$i$] ) ) & 1 );
$$end


        // Set read and write address for the sprite tiles
$$for i=0,7 do
    sprite_$i$_tiles.addr0 := sprite_tile_number[$i$] * 16 + ( pix_y - sprite_y[$i$] );
    sprite_$i$_tiles.wenable0 := 0;
    sprite_$i$_tiles.addr1 := sprite_writer_line;
    sprite_$i$_tiles.wdata1 := sprite_writer_bitmap;
    sprite_$i$_tiles.wenable1 := 0;
$$end


    // Default to transparent
    sprite_layer_display := 0;
    
    // Write to the sprite_layer
    // Set tile bitmaps, x coordinate, y coordinate, colour, tile number and visibility
    always {
        switch( sprite_layer_write ) {
            case 1: {
                sprite_active[ sprite_set_number ] = sprite_set_active;
            }
            case 2: {
                sprite_tile_number[ sprite_set_number ] = sprite_set_tile;
            }
            case 3: {
                sprite_colour[ sprite_set_number ] = sprite_set_colour;
            }
            case 4: {
                sprite_x[ sprite_set_number ] = sprite_set_x;
            }
            case 5: {
                sprite_y[ sprite_set_number ] = sprite_set_y;
            }
            case 8: { 
                switch( sprite_writer_sprite ) {
$$for i=0,7 do
                    case $i$: {
                        sprite_$i$_tiles.wenable1 = 1;
                    }
$$end
                    default: {}
                }
            }
            case 9: {
                sprite_fade = sprite_layer_fade;
            }
            default: {}
        }
    }
    
    // Render the sprite layer
    while(1) {
        if( pix_active ) {
$$for i=0,7 do
            if( sprite_$i$_visible ) {
                pix_red = colourexpand2to$color_depth$[ sprite_colour[$i$] >> 4 ] >> sprite_fade;
                pix_green = colourexpand2to$color_depth$[ sprite_colour[$i$] >> 2 ] >> sprite_fade;
                pix_blue = colourexpand2to$color_depth$[ sprite_colour[$i$] ] >> sprite_fade;
                sprite_layer_display = 1;
            }
$$end
        }
    }
}
