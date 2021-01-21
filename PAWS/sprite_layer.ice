// UPDATE COLLISION DETECTION FLAGS
circuitry updatecollision(
    output  newcollisionflag,
    input   oldcollisionflag,
    input   mypixel,

    input   collision_layer_1,
    input   collision_layer_2,
    input   collision_layer_3,
    input   pix_visible_12,
    input   pix_visible_11,
    input   pix_visible_10,
    input   pix_visible_9,
    input   pix_visible_8,
    input   pix_visible_7,
    input   pix_visible_6,
    input   pix_visible_5,
    input   pix_visible_4,
    input   pix_visible_3,
    input   pix_visible_2,
    input   pix_visible_1,
    input   pix_visible_0
) {
        newcollisionflag = mypixel ? oldcollisionflag | {
                            collision_layer_1, collision_layer_2, collision_layer_3, pix_visible_12, pix_visible_11,
                            pix_visible_10, pix_visible_9, pix_visible_8, pix_visible_7,
                            pix_visible_6, pix_visible_5, pix_visible_4, pix_visible_3,
                            pix_visible_2, pix_visible_1, pix_visible_0
                        } : oldcollisionflag;
}

algorithm sprite_layer(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint2   pix_red,
    output! uint2   pix_green,
    output! uint2   pix_blue,
    output! uint1   sprite_layer_display,

    // For setting sprite characteristics
    input   uint4   sprite_set_number,
    input   uint1   sprite_set_active,
    input   uint1   sprite_set_double,
    input   uint6   sprite_set_colour,
    input   int11   sprite_set_x,
    input   int11   sprite_set_y,
    input   uint3   sprite_set_tile,
    // Flag to set the above
    input   uint4   sprite_layer_write,

    // For reading sprite characteristics for sprite_set_number
    output uint1   sprite_read_active,
    output uint1   sprite_read_double,
    output uint6   sprite_read_colour,
    output int11   sprite_read_x,
    output int11   sprite_read_y,
    output uint3   sprite_read_tile,

    input   uint16  sprite_update,

    // FULL collision detection
    // (1) Bitmap, (2) Tile Map, (3) Other Sprite Layer
    input   uint1   collision_layer_1,
    input   uint1   collision_layer_2,
    input   uint1   collision_layer_3,
    $$for i=0,12 do
        output uint16 collision_$i$,
    $$end

    // For setting sprite tile bitmaps
    input   uint4   sprite_writer_sprite,
    input   uint7   sprite_writer_line,
    input   uint16  sprite_writer_bitmap,
    input   uint1   sprite_writer_active

) <autorun> {
    // Storage for the sprites
    // Stored as registers as needed instantly
    uint1   sprite_active[13] = uninitialised;
    uint1   sprite_double[13] = uninitialised;
    int11   sprite_x[13] = uninitialised;
    int11   sprite_y[13] = uninitialised;
    uint6   sprite_colour[13] = uninitialised;
    uint3   sprite_tile_number[13] = uninitialised;

    uint1   output_collisions = 0;

    $$for i=0,12 do
        // Sprite Tiles
        simple_dualport_bram uint16 tiles_$i$ <input!> [128] = uninitialised;

        // Calculate if sprite is visible
        uint6 spritesize_$i$ := sprite_double[$i$] ? 32 : 16;
        uint1 xinrange_$i$ := ( __signed({1b0, pix_x}) >= __signed(sprite_x[$i$]) ) && ( __signed({1b0, pix_x}) < __signed( sprite_x[$i$] + spritesize_$i$ ) );
        uint1 yinrange_$i$ := ( __signed({1b0, pix_y}) >= __signed(sprite_y[$i$]) ) && ( __signed({1b0, pix_y}) < __signed( sprite_y[$i$] + spritesize_$i$ ) );
        uint1 pix_visible_$i$ := sprite_active[$i$] && xinrange_$i$ && yinrange_$i$ && ( tiles_$i$.rdata0[ ( 15  - ( ( __signed({1b0, pix_x}) - sprite_x[$i$] ) >>> sprite_double[$i$] ) ), 1 ] );

        // Collision detection flag
        uint16      detect_collision_$i$ = uninitialised;
    $$end

    // UPDATE THE SPRITE TILE BITMAPS
    spritebitmapwriter SBMW(
        sprite_writer_sprite <: sprite_writer_sprite,
        sprite_writer_line <: sprite_writer_line,
        sprite_writer_bitmap <: sprite_writer_bitmap,
        sprite_writer_active <: sprite_writer_active,
        $$for i=0,12 do
            tiles_$i$ <:> tiles_$i$,
        $$end
    );

    // Expand Sprite Update Deltas
    int11   deltax := { {7{spriteupdate( sprite_update ).dxsign}}, spriteupdate( sprite_update ).dx };
    int11   deltay := { {7{spriteupdate( sprite_update ).dysign}}, spriteupdate( sprite_update ).dy };

    // Sprite update helpers
    int11   sprite_offscreen_negative ::= sprite_double[ sprite_set_number ] ? -32 : -16;
    int11   sprite_to_negative ::= sprite_double[ sprite_set_number ] ? -31 : -15;
    uint1   sprite_offscreen_x ::= ( __signed( sprite_x[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) ) || ( __signed( sprite_x[ sprite_set_number ] ) > __signed(640) );
    uint1   sprite_offscreen_y ::= ( __signed( sprite_y[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) ) || ( __signed( sprite_y[ sprite_set_number ] ) > __signed(480) );

    $$for i=0,12 do
        // Set read addresses for the bitmaps and output collisions
        tiles_$i$.addr0 := sprite_tile_number[$i$] * 16 + ( ( __signed({1b0, pix_y}) - sprite_y[$i$] ) >>> sprite_double[$i$] );
        collision_$i$ := ( output_collisions ) ? detect_collision_$i$ : collision_$i$;
    $$end

    // Default to transparent
    sprite_layer_display := 0;

    // Sprite details reader
    sprite_read_active := sprite_active[ sprite_set_number ];
    sprite_read_double := sprite_double[ sprite_set_number ];
    sprite_read_colour := sprite_colour[ sprite_set_number ];
    sprite_read_x := sprite_x[ sprite_set_number ];
    sprite_read_y := sprite_y[ sprite_set_number ];
    sprite_read_tile := sprite_tile_number[ sprite_set_number ];

    while(1) {
        // RENDER + COLLISION DETECTION
        if( pix_vblank ) {
            if( ~output_collisions ) {
                // RESET collision detection
                $$for i=0,12 do
                    detect_collision_$i$ = 0;
                $$end
            } else {
                output_collisions = 0;
            }
        } else {
            if( pix_active ) {
                pix_red = pix_visible_12 ? sprite_colour[12][4,2] :
                            pix_visible_11 ? sprite_colour[11][4,2] :
                            pix_visible_10 ? sprite_colour[10][4,2] :
                            pix_visible_9 ? sprite_colour[9][4,2] :
                            pix_visible_8 ? sprite_colour[8][4,2] :
                            pix_visible_7 ? sprite_colour[7][4,2] :
                            pix_visible_6 ? sprite_colour[6][4,2] :
                            pix_visible_5 ? sprite_colour[5][4,2] :
                            pix_visible_4 ? sprite_colour[4][4,2] :
                            pix_visible_3 ? sprite_colour[3][4,2] :
                            pix_visible_2 ? sprite_colour[2][4,2] :
                            pix_visible_1 ? sprite_colour[1][4,2] :
                            pix_visible_0 ? sprite_colour[0][4,2] : 0;

                pix_green= pix_visible_12 ? sprite_colour[12][2,2] :
                            pix_visible_11 ? sprite_colour[11][2,2] :
                            pix_visible_10 ? sprite_colour[10][2,2] :
                            pix_visible_9 ? sprite_colour[9][2,2] :
                            pix_visible_8 ? sprite_colour[8][2,2] :
                            pix_visible_7 ? sprite_colour[7][2,2] :
                            pix_visible_6 ? sprite_colour[6][2,2] :
                            pix_visible_5 ? sprite_colour[5][2,2] :
                            pix_visible_4 ? sprite_colour[4][2,2] :
                            pix_visible_3 ? sprite_colour[3][2,2] :
                            pix_visible_2 ? sprite_colour[2][2,2] :
                            pix_visible_1 ? sprite_colour[1][2,2] :
                            pix_visible_0 ? sprite_colour[0][2,2] : 0;

                pix_blue = pix_visible_12 ? sprite_colour[12][0,2] :
                            pix_visible_11 ? sprite_colour[11][0,2] :
                            pix_visible_10 ? sprite_colour[10][0,2] :
                            pix_visible_9 ? sprite_colour[9][0,2] :
                            pix_visible_8 ? sprite_colour[8][0,2] :
                            pix_visible_7 ? sprite_colour[7][0,2] :
                            pix_visible_6 ? sprite_colour[6][0,2] :
                            pix_visible_5 ? sprite_colour[5][0,2] :
                            pix_visible_4 ? sprite_colour[4][0,2] :
                            pix_visible_3 ? sprite_colour[3][0,2] :
                            pix_visible_2 ? sprite_colour[2][0,2] :
                            pix_visible_1 ? sprite_colour[1][0,2] :
                            pix_visible_0 ? sprite_colour[0][0,2] : 0;

                sprite_layer_display = pix_visible_12 | pix_visible_11 | pix_visible_10 | pix_visible_9 | pix_visible_8 | pix_visible_7 | pix_visible_6 | pix_visible_5 |
                    pix_visible_4 | pix_visible_3 | pix_visible_2 | pix_visible_1 | pix_visible_0;

                $$for i=0,12 do
                    // UPDATE COLLISION DETECTION FLAGS
                    ( detect_collision_$i$ ) = updatecollision( detect_collision_$i$, pix_visible_$i$,
                                                                collision_layer_1, collision_layer_2, collision_layer_3, pix_visible_12, pix_visible_11,
                                                                pix_visible_10, pix_visible_9, pix_visible_8, pix_visible_7,
                                                                pix_visible_6, pix_visible_5, pix_visible_4, pix_visible_3,
                                                                pix_visible_2, pix_visible_1, pix_visible_0 );
                $$end

                // Output collision detection
                output_collisions = ( pix_x == 639 ) && ( pix_y == 479 );
            }
        }

        // SET ATTRIBUTES + PERFORM UPDATE
        switch( sprite_layer_write ) {
            case 1: { sprite_active[ sprite_set_number ] = sprite_set_active; }
            case 2: { sprite_tile_number[ sprite_set_number ] = sprite_set_tile; }
            case 3: { sprite_colour[ sprite_set_number ] = sprite_set_colour; }
            case 4: { sprite_x[ sprite_set_number ] = sprite_set_x; }
            case 5: { sprite_y[ sprite_set_number ] = sprite_set_y; }
            case 6: { sprite_double[ sprite_set_number ] = sprite_set_double; }
            case 10: {
                // Perform sprite update
                if( spriteupdate( sprite_update ).tile_act ) {
                    sprite_tile_number[ sprite_set_number ] = sprite_tile_number[ sprite_set_number ] + 1;
                }

                if( spriteupdate( sprite_update ).x_act || spriteupdate( sprite_update ).y_act) {
                    sprite_active[ sprite_set_number ] = ( sprite_offscreen_x || sprite_offscreen_y ) ? 0 : sprite_active[ sprite_set_number ];
                }

                sprite_x[ sprite_set_number ] = sprite_offscreen_x ? ( ( __signed( sprite_x[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) ) ?__signed(640) : sprite_to_negative ) :
                                                sprite_x[ sprite_set_number ] + deltax;

                sprite_y[ sprite_set_number ] = sprite_offscreen_y ? ( ( __signed( sprite_y[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) ) ? __signed(480) : sprite_to_negative ) :
                                                sprite_y[ sprite_set_number ] + deltay;
            }
        }
    }
}

algorithm spritebitmapwriter(
    input   uint4   sprite_writer_sprite,
    input   uint7   sprite_writer_line,
    input   uint16  sprite_writer_bitmap,
    input   uint1   sprite_writer_active,

    $$for i=0,12 do
        simple_dualbram_port1 tiles_$i$,
    $$end
) <autorun> {
    $$for i=0,12 do
        tiles_$i$.wenable1 := 1;
    $$end

    while(1) {
        // WRITE BITMAP TO SPRITE TILE
        if( sprite_writer_active ) {
            switch( sprite_writer_sprite ) {
                $$for i=0,12 do
                    case $i$: {
                        tiles_$i$.addr1 = sprite_writer_line;
                        tiles_$i$.wdata1 = sprite_writer_bitmap;
                    }
                $$end
            }
        }
    }
}
