// UPDATE COLLISION DETECTION FLAGS
circuitry updatecollision(
    output  newcollisionflag,
    output  newlayerflag,
    input   oldcollisionflag,
    input   oldlayerflag,
    input   mypixel,

    input   collision_layer_1,
    input   collision_layer_2,
    input   collision_layer_3,
    input   collision_layer_4,
    input   pix_visible_15,
    input   pix_visible_14,
    input   pix_visible_13,
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
    newlayerflag = mypixel ? oldlayerflag | { collision_layer_1, collision_layer_2, collision_layer_3, collision_layer_4 } : oldlayerflag;
    newcollisionflag = mypixel ? oldcollisionflag | {
                         pix_visible_15, pix_visible_14, pix_visible_13, pix_visible_12, pix_visible_11,
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

    // For setting sprite characteristics - MAIN ACCESS
    input   uint4   sprite_set_number,
    input   uint1   sprite_set_active,
    input   uint1   sprite_set_double,
    input   uint6   sprite_set_colour,
    input   int11   sprite_set_x,
    input   int11   sprite_set_y,
    input   uint3   sprite_set_tile,
    input   uint3   sprite_layer_write,
    input   uint13  sprite_update,

    // For reading sprite characteristics
    $$for i=0,15 do
        output  uint1   sprite_read_active_$i$,
        output  uint1   sprite_read_double_$i$,
        output  uint6   sprite_read_colour_$i$,
        output  int16   sprite_read_x_$i$,
        output  int16   sprite_read_y_$i$,
        output  uint3   sprite_read_tile_$i$,
    $$end

    // FULL collision detection
    // (1) Bitmap, (2) Tile Map L, (3) Tile Map U, (4) Other Sprite Layer
    input   uint1   collision_layer_1,
    input   uint1   collision_layer_2,
    input   uint1   collision_layer_3,
    input   uint1   collision_layer_4,
    $$for i=0,15 do
        output uint16 collision_$i$,
        output uint4  layer_collision_$i$,
    $$end

    // For setting sprite tile bitmaps
    input   uint4   sprite_writer_sprite,
    input   uint7   sprite_writer_line,
    input   uint16  sprite_writer_bitmap,
    input   uint1   sprite_writer_active

) <autorun> {
    // Storage for the sprites
    // Stored as registers as needed instantly
    uint1   sprite_active[16] = uninitialised;
    uint1   sprite_double[16] = uninitialised;
    int11   sprite_x[16] = uninitialised;
    int11   sprite_y[16] = uninitialised;
    uint6   sprite_colour[16] = uninitialised;
    uint3   sprite_tile_number[16] = uninitialised;

    uint1   output_collisions = 0;

    $$for i=0,15 do
        // Sprite Tiles
        simple_dualport_bram uint16 tiles_$i$ <input!> [128] = uninitialised;
        uint1 pix_visible_$i$ = uninitialised;
        sprite_generator SPRITE_$i$(
            pix_x <: pix_x,
            pix_y <: pix_y,
            pix_visible :> pix_visible_$i$,
            tiles <:> tiles_$i$
        );

        // Collision detection flag
        uint16      detect_collision_$i$ = uninitialised;
        uint4       detect_layer_$i$ = uninitialised;
    $$end

    // UPDATE THE SPRITE TILE BITMAPS
    spritebitmapwriter SBMW(
        sprite_writer_sprite <: sprite_writer_sprite,
        sprite_writer_line <: sprite_writer_line,
        sprite_writer_bitmap <: sprite_writer_bitmap,
        sprite_writer_active <: sprite_writer_active,
        $$for i=0,15 do
            tiles_$i$ <:> tiles_$i$,
        $$end
    );

    int11   sprite_offscreen_negative = uninitialised;
    int11   sprite_to_negative = uninitialised;
    uint1   sprite_offscreen_x = uninitialised;
    uint1   sprite_offscreen_y = uninitialised;

    $$for i=0,15 do
        // Set sprite generator parameters
        SPRITE_$i$.sprite_active := sprite_active[$i$];
        SPRITE_$i$.sprite_double := sprite_double[$i$];
        SPRITE_$i$.sprite_x := sprite_x[$i$];
        SPRITE_$i$.sprite_y := sprite_y[$i$];
        SPRITE_$i$.sprite_tile_number := sprite_tile_number[$i$];

        // For setting sprite read paramers
        sprite_read_active_$i$ := sprite_active[$i$];
        sprite_read_double_$i$ := sprite_double[$i$];
        sprite_read_colour_$i$ := sprite_colour[$i$];
        sprite_read_x_$i$ := sprite_x[$i$];
        sprite_read_y_$i$ := sprite_y[$i$];
        sprite_read_tile_$i$ := sprite_tile_number[$i$];
    $$end

    // Default to transparent
    sprite_layer_display := 0;

    while(1) {
        // SET ATTRIBUTES + PERFORM UPDATE
        switch( sprite_layer_write ) {
            case 1: { sprite_active[ sprite_set_number ] = sprite_set_active; }
            case 2: { sprite_double[ sprite_set_number ] = sprite_set_double; }
            case 3: { sprite_colour[ sprite_set_number ] = sprite_set_colour; }
            case 4: { sprite_x[ sprite_set_number ] = sprite_set_x; }
            case 5: { sprite_y[ sprite_set_number ] = sprite_set_y; }
            case 6: { sprite_tile_number[ sprite_set_number ] = sprite_set_tile; }
            case 7: {
                // Sprite update helpers
                sprite_offscreen_negative = sprite_double[ sprite_set_number ] ? -32 : -16;
                sprite_to_negative = sprite_double[ sprite_set_number ] ? -31 : -15;
                sprite_offscreen_x = ( __signed( sprite_x[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) ) | ( __signed( sprite_x[ sprite_set_number  ] ) > __signed(640) );
                sprite_offscreen_y = ( __signed( sprite_y[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) ) | ( __signed( sprite_y[ sprite_set_number ] ) > __signed(480) );

                // Perform sprite update
                sprite_active[ sprite_set_number ] = ( ( ( sprite_update[12,1] & sprite_offscreen_y ) == 1 ) || ( ( sprite_update[11,1] & sprite_offscreen_x ) == 1 ) ) ? 0 : sprite_active[ sprite_set_number ];
                sprite_tile_number[ sprite_set_number ] = sprite_tile_number[ sprite_set_number ] + sprite_update[10,1];
                sprite_x[ sprite_set_number ] = sprite_offscreen_x ? ( ( __signed( sprite_x[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) ) ?__signed(640) : sprite_to_negative ) :
                                                sprite_x[ sprite_set_number ] + { {7{spriteupdate( sprite_update ).dxsign}}, spriteupdate( sprite_update ).dx };
                sprite_y[ sprite_set_number ] = sprite_offscreen_y ? ( ( __signed( sprite_y[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) ) ? __signed(480) : sprite_to_negative ) :
                                                sprite_y[ sprite_set_number ] + { {7{spriteupdate( sprite_update ).dysign}}, spriteupdate( sprite_update ).dy };
            }
        }

        // RENDER + COLLISION DETECTION
        if( pix_vblank ) {
            if( ~output_collisions ) {
                // RESET collision detection
                $$for i=0,15 do
                    detect_collision_$i$ = 0;
                    detect_layer_$i$ = 0;
                $$end
            } else {
                $$for i=0,15 do
                    // Output collisions
                    collision_$i$ = detect_collision_$i$;
                    layer_collision_$i$ = detect_layer_$i$;
                $$end
                output_collisions = 0;
            }
        } else {
            if( pix_active ) {
                pix_red = pix_visible_15 ? sprite_colour[15][4,2] :
                            pix_visible_14 ? sprite_colour[14][4,2] :
                            pix_visible_13 ? sprite_colour[13][4,2] :
                            pix_visible_12 ? sprite_colour[12][4,2] :
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
                            sprite_colour[0][4,2];

                pix_green = pix_visible_15 ? sprite_colour[15][2,2] :
                            pix_visible_14 ? sprite_colour[14][2,2] :
                            pix_visible_13 ? sprite_colour[13][2,2] :
                            pix_visible_12 ? sprite_colour[12][2,2] :
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
                            sprite_colour[0][2,2];

                pix_blue = pix_visible_15 ? sprite_colour[15][0,2] :
                            pix_visible_14 ? sprite_colour[14][0,2] :
                            pix_visible_13 ? sprite_colour[13][0,2] :
                            pix_visible_12 ? sprite_colour[12][0,2] :
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
                            sprite_colour[0][0,2];

                sprite_layer_display = pix_visible_15 | pix_visible_14 | pix_visible_13 | pix_visible_12 | pix_visible_11 | pix_visible_10 | pix_visible_9 | pix_visible_8 | pix_visible_7
                                        | pix_visible_6 | pix_visible_5 |pix_visible_4 | pix_visible_3 | pix_visible_2 | pix_visible_1 | pix_visible_0;

                $$for i=0,15 do
                    // UPDATE COLLISION DETECTION FLAGS
                    ( detect_collision_$i$, detect_layer_$i$ ) = updatecollision( detect_collision_$i$, detect_layer_$i$, pix_visible_$i$,
                                                                collision_layer_1, collision_layer_2, collision_layer_3, collision_layer_4,
                                                                pix_visible_15, pix_visible_14, pix_visible_13, pix_visible_12, pix_visible_11,
                                                                pix_visible_10, pix_visible_9, pix_visible_8, pix_visible_7,
                                                                pix_visible_6, pix_visible_5, pix_visible_4, pix_visible_3,
                                                                pix_visible_2, pix_visible_1, pix_visible_0 );
                $$end

                // Output collision detection
                output_collisions = ( pix_x == 639 ) & ( pix_y == 479 );
            }
        }
    }
}

algorithm sprite_generator(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   sprite_active,
    input   uint1   sprite_double,
    input   int11   sprite_x,
    input   int11   sprite_y,
    input   uint3   sprite_tile_number,
    simple_dualport_bram_port0 tiles,
    output! uint1   pix_visible
) <autorun> {
    // Calculate position in sprite
    uint6 spritesize <: sprite_double ? 32 : 16;
    uint1 xinrange <: ( __signed({1b0, pix_x}) >= __signed(sprite_x) ) & ( __signed({1b0, pix_x}) < __signed( sprite_x + spritesize ) );
    uint1 yinrange <: ( __signed({1b0, pix_y}) >= __signed(sprite_y) ) & ( __signed({1b0, pix_y}) < __signed( sprite_y + spritesize) );
    uint4 yinsprite <: ( __signed({1b0, pix_y}) - sprite_y ) >>> sprite_double;

    // READ ADDRESS FOR SPRITE
    tiles.addr0 := { sprite_tile_number, yinsprite };

    // Determine if pixel is visible
    pix_visible := sprite_active & xinrange && yinrange & ( tiles.rdata0[ ( 15  - ( ( __signed({1b0, pix_x}) - sprite_x ) >>> sprite_double ) ), 1 ] );
}

algorithm spritebitmapwriter(
    input   uint4   sprite_writer_sprite,
    input   uint7   sprite_writer_line,
    input   uint16  sprite_writer_bitmap,
    input   uint1   sprite_writer_active,

    $$for i=0,15 do
        simple_dualport_bram_port1 tiles_$i$,
    $$end
) <autorun> {
    $$for i=0,15 do
        tiles_$i$.wenable1 := 1;
    $$end

    while(1) {
        // WRITE BITMAP TO SPRITE TILE
        if( sprite_writer_active ) {
            switch( sprite_writer_sprite ) {
                $$for i=0,15 do
                    case $i$: {
                        tiles_$i$.addr1 = sprite_writer_line;
                        tiles_$i$.wdata1 = sprite_writer_bitmap;
                    }
                $$end
            }
        }
    }
}
