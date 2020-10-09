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
    input   uint6   sprite_set_tile,
    
    // For setting sprite tile bitmaps
    input   uint6   sprite_writer_tile,
    input   uint4   sprite_writer_line,
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
    uint1 sprite_active[8] = uninitialised;
    int11 sprite_x[8] = uninitialised;
    int11 sprite_y[8] = uninitialised;
    uint6 sprite_colour[8] = { 6h0, 6h3, 6hc, 6hf, 6h30, 6h33, 6h3c, 6h3f };
    uint6 sprite_tile_number[8] = uninitialised;
    uint16 sprite_tiles[] = { 16h5555, 16ha0a0, 16h5555, 16ha0a0, 16h5555, 16ha0a0, 16h5555, 16ha0a0, 16h5555, 16ha0a0, 16h5555, 16ha0a0, 16h5555, 16ha0a0, 16h5555, 16ha0a0, 
                                    16h701c, 16h1830, 16h820, 16h820, 16hff8, 16h3938, 16h3938, 16hfffe, 16hdff6, 16hdff6, 16h9c72, 16hd836, 16hc60, 16hc60, 16hee0, 16h0,
                                    16hffff, 16hffff, 16hffff, 16hffff, 16hffff, 16hffff, 16hffff, 16hffff, 16hffff, 16hffff, 16hffff, 16hffff, 16hffff, 16hffff, 16hffff, 16hffff };
    
    uint3 sprite_fade = 0;

$$for i=0,7 do
    // Calculate if each sprite is visible
    uint1 sprite_$i$_visible := sprite_active[$i$] & ( pix_x >= sprite_x[$i$] ) & ( pix_x < sprite_x[$i$] + 16 ) & ( pix_y >= sprite_y[$i$] ) & ( pix_y < sprite_y[$i$] + 16 ) & ( sprite_tiles[ sprite_tile_number[$i$] * 16 + (pix_y - sprite_y[$i$] ) ] >> ( 15 - ( pix_x - sprite_x[$i$] ) ) & 1 );
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
                sprite_tiles[ sprite_writer_tile * 16 + sprite_writer_line ] = sprite_writer_bitmap;
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
            if( sprite_7_visible ) {
                pix_red = colourexpand2to$color_depth$[ sprite_colour[7] >> 4 ] >> sprite_fade;
                pix_green = colourexpand2to$color_depth$[ sprite_colour[7] >> 2 ] >> sprite_fade;
                pix_blue = colourexpand2to$color_depth$[ sprite_colour[7] ] >> sprite_fade;
                sprite_layer_display = 1;
            } else {
                if( sprite_6_visible ) {
                    pix_red = colourexpand2to$color_depth$[ sprite_colour[6] >> 4 ] >> sprite_fade;
                    pix_green = colourexpand2to$color_depth$[ sprite_colour[6] >> 2 ] >> sprite_fade;
                    pix_blue = colourexpand2to$color_depth$[ sprite_colour[6] ]  >> sprite_fade;
                    sprite_layer_display = 1;
                } else {
                    if( sprite_5_visible ) {
                        pix_red = colourexpand2to$color_depth$[ sprite_colour[5] >> 4 ] >> sprite_fade;
                        pix_green = colourexpand2to$color_depth$[ sprite_colour[5] >> 2 ] >> sprite_fade;
                        pix_blue = colourexpand2to$color_depth$[ sprite_colour[5] ] >> sprite_fade;
                        sprite_layer_display = 1;
                    } else {
                        if( sprite_4_visible ) {
                            pix_red = colourexpand2to$color_depth$[ sprite_colour[4] >> 4 ] >> sprite_fade;
                            pix_green = colourexpand2to$color_depth$[ sprite_colour[4] >> 2 ] >> sprite_fade;
                            pix_blue = colourexpand2to$color_depth$[ sprite_colour[4] ] >> sprite_fade;
                            sprite_layer_display = 1;
                        } else {
                            if( sprite_3_visible ) {
                                pix_red = colourexpand2to$color_depth$[ sprite_colour[3] >> 4 ] >> sprite_fade;
                                pix_green = colourexpand2to$color_depth$[ sprite_colour[3] >> 2 ] >> sprite_fade;
                                pix_blue = colourexpand2to$color_depth$[ sprite_colour[3] ] >> sprite_fade;
                                sprite_layer_display = 1;
                            } else {
                                if( sprite_2_visible ) {
                                    pix_red = colourexpand2to$color_depth$[ sprite_colour[2] >> 4 ] >> sprite_fade;
                                    pix_green = colourexpand2to$color_depth$[ sprite_colour[2] >> 2 ] >> sprite_fade;
                                    pix_blue = colourexpand2to$color_depth$[ sprite_colour[2] ] >> sprite_fade;
                                    sprite_layer_display = 1;
                                } else {
                                    if( sprite_1_visible ) {
                                        pix_red = colourexpand2to$color_depth$[ sprite_colour[1] >> 4 ] >> sprite_fade;
                                        pix_green = colourexpand2to$color_depth$[ sprite_colour[1] >> 2 ] >> sprite_fade;
                                        pix_blue = colourexpand2to$color_depth$[ sprite_colour[1] ] >> sprite_fade;
                                        sprite_layer_display = 1;
                                    } else {
                                        if( sprite_0_visible ) {
                                            pix_red = colourexpand2to$color_depth$[ sprite_colour[0] >> 4 ] >> sprite_fade;
                                            pix_green = colourexpand2to$color_depth$[ sprite_colour[0] >> 2 ] >> sprite_fade;
                                            pix_blue = colourexpand2to$color_depth$[ sprite_colour[0] ] >> sprite_fade;
                                            sprite_layer_display = 1;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
