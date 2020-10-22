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
    input   uint1   sprite_set_double,
    input   uint2   sprite_set_colmode,
    input   uint6   sprite_set_colour,
    input   int11   sprite_set_x,
    input   int11   sprite_set_y,
    input   uint2   sprite_set_tile,

    // For reading sprite characteristics for sprite_set_number
    output  uint1   sprite_read_active,
    output  uint1   sprite_read_double,
    output  uint2   sprite_read_colmode,
    output  uint6   sprite_read_colour,
    output  int11   sprite_read_x,
    output  int11   sprite_read_y,
    output  uint2   sprite_read_tile,
    input   uint16  sprite_update,
    // Flag to set the above
    input   uint4   sprite_layer_write,

    // FULL collision detection
    // Bitmap is set flag
    input   uint1   bitmap_display,
    $$for i=0,14 do
        output uint16 collision_$i$,
    $$end
    
    // For setting sprite tile bitmaps
    input   uint4   sprite_writer_sprite,
    input   uint6   sprite_writer_line,
    input   uint16  sprite_writer_bitmap,  
    input   uint1   sprite_writer_active,

    // For setting 3 or 15 colour sprite palette
    $$for i=1,15 do
        input uint6 sprite_palette_$i$,
    $$end

    
    // SPRITE LAYER fade level
    input uint3 sprite_layer_fade,

) <autorun> {
    // Expansion map for { rr } to { rrrrrr }, { gg } to { gggggg }, { bb } to { bbbbbb }
    // or { rr } tp { rrrrrrrr }, { gg } to { gggggggg }, { bb } to { bbbbbbbb }
    uint6 colourexpand2to6[4] = {  0, 21, 42, 63 };
    uint8 colourexpand2to8[4] = {  0, 85, 170, 255 };

    // Storage for the sprites
    // Stored as registers as needed instantly
    uint1 sprite_active[15] = uninitialised;
    uint1 sprite_double[15] = uninitialised;
    uint2 sprite_colmode[15] = uninitialised;
    int11 sprite_x[15] = uninitialised;
    int11 sprite_y[15] = uninitialised;
    uint6 sprite_colour[15] = uninitialised;
    uint2 sprite_tile_number[15] = uninitialised;

    // Palette for 3 or 15 colour sprites - shared
    uint6 palette[16] = uninitialised;
    
    // Collision detection storage
    $$for i=0,14 do
        uint16      detect_collision_$i$ = uninitialised;
    $$end
    
    // One bram for each sprite
    $$for i=0,14 do
        dualport_bram uint16 sprite_$i$_tiles[64] = uninitialised;
    $$end

    uint3 sprite_fade = 0;

    // Calculate if each sprite is visible
    $$for i=0,14 do
        uint4 sprite_$i$_xinsprite := ( 16 >> sprite_colmode[$i$] ) - 1  - ( ( pix_x - sprite_x[$i$] ) >> sprite_double[$i$] );
        uint4 sprite_$i$_spritepixel := ( sprite_colmode[$i$] == 0 ) ? sprite_$i$_tiles.rdata0[ sprite_$i$_xinsprite, 1 ] 
                                        : ( sprite_colmode[$i$] == 1 ) ? sprite_$i$_tiles.rdata0[ sprite_$i$_xinsprite, 2 ]
                                        : ( sprite_colmode[$i$] == 2 ) ? sprite_$i$_tiles.rdata0[ sprite_$i$_xinsprite, 3 ] : 0;
        uint1 sprite_$i$_visiblex := ( pix_x >= sprite_x[$i$] ) && ( pix_x < ( sprite_x[$i$] + ( ( 16 >> sprite_colmode[$i$] ) << sprite_double[$i$] ) ) );
        uint1 sprite_$i$_visibley := ( pix_y >= sprite_y[$i$] ) && ( pix_y < ( sprite_y[$i$] + ( 16 << sprite_double[$i$] ) ) );
        uint1 sprite_$i$_visible := sprite_$i$_visiblex && sprite_$i$_visibley && ( sprite_$i$_spritepixel != 0 )  && sprite_active[$i$];
    $$end

    // Expand Sprite Update Deltas
    int11 deltax := { {9{spriteupdate( sprite_update ).dxsign}}, spriteupdate( sprite_update ).dx };
    int11 deltay := { {9{spriteupdate( sprite_update ).dysign}}, spriteupdate( sprite_update ).dy };
   
    // Set read and write address for the sprite tiles
    $$for i=0,14 do
        sprite_$i$_tiles.addr0 := sprite_tile_number[$i$] * 16 + ( ( pix_y - sprite_y[$i$] ) >> sprite_double[$i$] );
        sprite_$i$_tiles.wenable0 := 0;
        sprite_$i$_tiles.addr1 := sprite_writer_line;
        sprite_$i$_tiles.wdata1 := sprite_writer_bitmap;
        sprite_$i$_tiles.wenable1 := ( sprite_writer_sprite == $i$ ) && sprite_writer_active;
    $$end

    // Set 3 or 15 colour sprite palette
    $$for i=1,15 do
        palette[$i$] := sprite_palette_$i$;
    $$end
    
    // Default to transparent
    sprite_layer_display := 0;

    // Write to the sprite_layer
    // Set tile bitmaps, x coordinate, y coordinate, colour, tile number, visibility, double
    always {
        // Output the characteristics of the sprite sprite_set_number
        sprite_read_active = sprite_active[ sprite_set_number ];
        sprite_read_double = sprite_double[ sprite_set_number ];
        sprite_read_colour = sprite_colour[ sprite_set_number ];
        sprite_read_x = sprite_x[ sprite_set_number ];
        sprite_read_y = sprite_y[ sprite_set_number ];
        sprite_read_tile = sprite_tile_number[ sprite_set_number ];

        switch( sprite_layer_write ) {
            case 1: { sprite_active[ sprite_set_number ] = sprite_set_active; }
            case 2: { sprite_tile_number[ sprite_set_number ] = sprite_set_tile; }
            case 3: { sprite_colour[ sprite_set_number ] = sprite_set_colour; }
            case 4: { sprite_x[ sprite_set_number ] = sprite_set_x; }
            case 5: { sprite_y[ sprite_set_number ] = sprite_set_y; }
            case 6: { sprite_double[ sprite_set_number ] = sprite_set_double; }
            case 7: { sprite_colmode[ sprite_set_number ] = sprite_set_colmode; }
            case 10: {
                // Perform sprite update
                sprite_colour[ sprite_set_number ] = ( spriteupdate( sprite_update ).colour_act ) ? spriteupdate( sprite_update ).colour : sprite_colour[ sprite_set_number ];
                sprite_tile_number[ sprite_set_number ] = ( spriteupdate( sprite_update ).tile_act ) ? sprite_tile_number[ sprite_set_number ] + 1 : sprite_tile_number[ sprite_set_number ];
                switch( { (sprite_y[ sprite_set_number ] < (-16)) || (sprite_y[ sprite_set_number ] > 480), (sprite_x[ sprite_set_number ] < (-16)) || (sprite_x[ sprite_set_number ] > 640) } ) {
                    case 2b00: {
                        sprite_x[ sprite_set_number ] = sprite_x[ sprite_set_number ] + deltax;
                        sprite_y[ sprite_set_number ] = sprite_y[ sprite_set_number ] + deltay;
                    }
                    case 2b01: {
                        sprite_x[ sprite_set_number ] = (sprite_x[ sprite_set_number ] < (-16)) ? 640 : -16;
                        sprite_y[ sprite_set_number ] = sprite_y[ sprite_set_number ] + deltay;
                        sprite_active[ sprite_set_number ] = ( spriteupdate( sprite_update ).x_act ) ? 0 : sprite_active[ sprite_set_number ];
                    }
                    case 2b10: {
                        sprite_x[ sprite_set_number ] = sprite_x[ sprite_set_number ] + deltax;
                        sprite_y[ sprite_set_number ] = (sprite_y[ sprite_set_number ] < (-16)) ? 480 : -16;
                        sprite_active[ sprite_set_number ] = ( spriteupdate( sprite_update ).y_act ) ? 0 : sprite_active[ sprite_set_number ];
                    }
                    case 2b11: {
                        sprite_active[ sprite_set_number ] = ( spriteupdate( sprite_update ).x_act ) || ( spriteupdate( sprite_update ).y_act ) ? 0 : sprite_active[ sprite_set_number ];
                    }
                }
            }
        }
    }
    
    // Render the sprite layer
    while(1) {
        
        if( pix_vblank ) {
            // RESET collision detection
            $$for i=0,14 do
                detect_collision_$i$ = 0;
            $$end
        } else {
            if( pix_active ) {
                $$for i=0,14 do
                    if(  ( sprite_$i$_visible ) ) {
                        switch( sprite_colmode[$i$] ) {
                            case 0: {
                                // Single colour
                                pix_red = colourexpand2to$color_depth$[ sprite_colour[$i$][4,2] ] >> sprite_fade;
                                pix_green = colourexpand2to$color_depth$[ sprite_colour[$i$][2,2] ] >> sprite_fade;
                                pix_blue = colourexpand2to$color_depth$[ sprite_colour[$i$][0,2] ] >> sprite_fade;
                            }
                            default: {
                                // 3 or 15 colour
                                pix_red = colourexpand2to$color_depth$[ palette[ sprite_$i$_spritepixel ][4,2] ] >> sprite_fade;
                                pix_green = colourexpand2to$color_depth$[ palette[ sprite_$i$_spritepixel ][2,2] ] >> sprite_fade;
                                pix_blue = colourexpand2to$color_depth$[ palette[ sprite_$i$_spritepixel ][0,2] ] >> sprite_fade;
                            }
                        }
                        sprite_layer_display = 1;
                        // Perform collision detection
                        detect_collision_$i$ = detect_collision_$i$ | {
                            bitmap_display, sprite_14_visible, sprite_13_visible, sprite_12_visible, sprite_11_visible, sprite_10_visible, sprite_9_visible, sprite_8_visible,  
                            sprite_7_visible, sprite_6_visible, sprite_5_visible, sprite_4_visible, sprite_3_visible, sprite_2_visible, sprite_1_visible, sprite_0_visible
                        };
                    }
                $$end
            }
        }

        // Output collision detection
        if( ( pix_x == 639 ) && ( pix_y == 479 ) ) {
            $$for i=0,14 do
                collision_$i$ = ( ( pix_x == 639 ) && ( pix_y == 479 ) ) ? detect_collision_$i$ : collision_$i$;
            $$end
        }
    }
}
