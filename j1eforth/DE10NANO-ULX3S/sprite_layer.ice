bitfield spriteupdate {
    uint1   colour_act,         // 1 change the colour
    uint6   colour,             // { rrggbb }
    uint1   y_act,              // 1 - kill when off screen, 0 - wrap
    uint1   x_act,              // 1 - kill when off screen, 0 - wrap
    uint1   tile_act,           // 1 - increase the tile number
    uint1   dysign,             // dy - 2's complement update for the y coordinate
    uint2   dy,
    uint1   dxsign,             // dx - 2's complement update for the x coordinate
    uint2   dx
}

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
    input   uint4   sprite_set_number,
    input   uint1   sprite_set_active,
    input   uint6   sprite_set_colour,
    input   int11   sprite_set_x,
    input   int11   sprite_set_y,
    input   uint2   sprite_set_tile,

    // For reading sprite characteristics for sprite_set_number
    output  uint1   sprite_read_active,
    output  uint6   sprite_read_colour,
    output  int11   sprite_read_x,
    output  int11   sprite_read_y,
    output  uint2   sprite_read_tile,
    input   uint16  sprite_update,
    // Flag to set the above
    input   uint4   sprite_layer_write,

    // For determing which sprites are showing ata a given pixel
    // Basic collision detection
    input   uint11  sprites_at_x,
    input   uint11  sprites_at_y,
    output  uint16  sprites_at_xy,
    
    // For setting sprite tile bitmaps
    input   uint3   sprite_writer_sprite,
    input   uint6   sprite_writer_line,
    input   uint16  sprite_writer_bitmap,  
    
    // SPRITE LAYER fade level
    input uint3 sprite_layer_fade
) <autorun> {
    // Expansion map for { rr } to { rrrrrr }, { gg } to { gggggg }, { bb } to { bbbbbb }
    // or { rr } tp { rrrrrrrr }, { gg } to { gggggggg }, { bb } to { bbbbbbbb }
    uint6 colourexpand2to6[4] = {  0, 21, 42, 63 };
    uint8 colourexpand2to8[4] = {  0, 85, 170, 255 };

    // Storage for the sprites
    // Stored as registers as needed instantly
    uint1 sprite_active[8] = uninitialised;
    int11 sprite_x[8] = uninitialised;
    int11 sprite_y[8] = uninitialised;
    uint6 sprite_colour[8] = uninitialised;
    uint2 sprite_tile_number[8] = uninitialised;

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
            case 10: {
                // Perform sprite update
                // Change the colour
                if( spriteupdate( sprite_update ).colour_act ) {
                    sprite_colour[ sprite_set_number ] = spriteupdate( sprite_update ).colour;
                }
                if(  (sprite_x[ sprite_set_number ] < (-16)) | (sprite_x[ sprite_set_number ] > 640) ) {
                    if( spriteupdate( sprite_update ).x_act ) {
                        sprite_active[ sprite_set_number ] = 0;
                    } else {
                        sprite_x[ sprite_set_number ] = (sprite_x[ sprite_set_number ] < (-16)) ? 640 : -16;
                    }
                } else {
                    sprite_x[ sprite_set_number ] = sprite_x[ sprite_set_number ] + { {9{spriteupdate( sprite_update ).dxsign}}, spriteupdate( sprite_update ).dx };
                }
                if(  (sprite_y[ sprite_set_number ] < (-16)) | (sprite_y[ sprite_set_number ] > 480) ) {
                    if( spriteupdate( sprite_update ).y_act ) {
                        sprite_active[ sprite_set_number ] = 0;
                    } else {
                        sprite_y[ sprite_set_number ] = (sprite_y[ sprite_set_number ] < (-16)) ? 480 : -16;
                    }
                } else {
                    sprite_y[ sprite_set_number ] = sprite_y[ sprite_set_number ] + { {9{spriteupdate( sprite_update ).dysign}}, spriteupdate( sprite_update ).dy };
                }
            }
            default: {}
        }

        // Output the characteristics of the sprite sprite_set_number
        sprite_read_active = sprite_active[ sprite_set_number ];
        sprite_read_colour = sprite_colour[ sprite_set_number ];
        sprite_read_x = sprite_x[ sprite_set_number ];
        sprite_read_y = sprite_x[ sprite_set_number ];
        sprite_read_tile = sprite_tile_number[ sprite_set_number ];
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
            // Perform BASIC collision detection
            if( ( pix_x == sprites_at_x ) & ( pix_y == sprites_at_y ) ) {
                sprites_at_xy = {
                    8b00000000, sprite_7_visible, sprite_6_visible, sprite_5_visible, sprite_4_visible, sprite_3_visible, sprite_2_visible, sprite_1_visible, sprite_0_visible
                };
            }
        }
    }
}
