algorithm sprite_layer(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   sprite_layer_display,

    // For reading sprite characteristics
    $$for i=0,15 do
        input   uint1   sprite_read_active_$i$,
        input   uint3   sprite_read_double_$i$,
        input   uint6   sprite_read_colour_$i$,
        input   int11   sprite_read_x_$i$,
        input   int11   sprite_read_y_$i$,
        input   uint3   sprite_read_tile_$i$,
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

    $$for i=0,15 do
        simple_dualport_bram_port0 tiles_$i$,
    $$end
) <autorun> {
    uint1   output_collisions = 0;

    $$for i=0,15 do
        uint1 pix_visible_$i$ = uninitialised;
        // Set sprite generator parameters
        sprite_generator SPRITE_$i$(
            pix_x <: pix_x,
            pix_y <: pix_y,
            pix_visible :> pix_visible_$i$,
            sprite_active <: sprite_read_active_$i$,
            sprite_double <: sprite_read_double_$i$,
            sprite_x <: sprite_read_x_$i$,
            sprite_y <: sprite_read_y_$i$,
            sprite_tile_number <: sprite_read_tile_$i$,
            tiles <:> tiles_$i$
        );
        // Collision detection flag
        uint16      detect_collision_$i$ = uninitialised;
        uint4       detect_layer_$i$ = uninitialised;
    $$end

    // Default to transparent
    sprite_layer_display := pix_active & ( pix_visible_15 | pix_visible_14 | pix_visible_13 | pix_visible_12 | pix_visible_11 | pix_visible_10 | pix_visible_9 | pix_visible_8 | pix_visible_7
                                        | pix_visible_6 | pix_visible_5 |pix_visible_4 | pix_visible_3 | pix_visible_2 | pix_visible_1 | pix_visible_0 );

    always {
        // RENDER + COLLISION DETECTION
        switch( pix_vblank ) {
            case 1: {
                switch( output_collisions ) {
                    case 0: {
                        // RESET collision detection
                        $$for i=0,15 do
                            detect_collision_$i$ = 0;
                            detect_layer_$i$ = 0;
                        $$end
                    }
                    case 1: {
                        $$for i=0,15 do
                            // Output collisions
                            collision_$i$ = detect_collision_$i$;
                            layer_collision_$i$ = detect_layer_$i$;
                        $$end
                        output_collisions = 0;
                    }
                }
            }
            case 0: {
                switch( pix_active ) {
                    case 1: {
                        pixel = pix_visible_15 ? sprite_read_colour_15 :
                                    pix_visible_14 ? sprite_read_colour_14 :
                                    pix_visible_13 ? sprite_read_colour_13 :
                                    pix_visible_12 ? sprite_read_colour_12 :
                                    pix_visible_11 ? sprite_read_colour_11 :
                                    pix_visible_10 ? sprite_read_colour_10 :
                                    pix_visible_9 ? sprite_read_colour_9 :
                                    pix_visible_8 ? sprite_read_colour_8 :
                                    pix_visible_7 ? sprite_read_colour_7 :
                                    pix_visible_6 ? sprite_read_colour_6 :
                                    pix_visible_5 ? sprite_read_colour_5 :
                                    pix_visible_4 ? sprite_read_colour_4 :
                                    pix_visible_3 ? sprite_read_colour_3 :
                                    pix_visible_2 ? sprite_read_colour_2 :
                                    pix_visible_1 ? sprite_read_colour_1 :
                                    sprite_read_colour_0;

                        sprite_layer_display = pix_visible_15 | pix_visible_14 | pix_visible_13 | pix_visible_12 | pix_visible_11 | pix_visible_10 | pix_visible_9 | pix_visible_8 | pix_visible_7
                                                | pix_visible_6 | pix_visible_5 |pix_visible_4 | pix_visible_3 | pix_visible_2 | pix_visible_1 | pix_visible_0;

                        $$for i=0,15 do
                            // UPDATE COLLISION DETECTION FLAGS
                            if( pix_visible_$i$ ) {
                                detect_layer_$i$ = detect_layer_$i$ | { collision_layer_1, collision_layer_2, collision_layer_3, collision_layer_4 };
                                detect_collision_$i$ = detect_collision_$i$ | {
                                                    pix_visible_15, pix_visible_14, pix_visible_13, pix_visible_12, pix_visible_11,
                                                    pix_visible_10, pix_visible_9, pix_visible_8, pix_visible_7,
                                                    pix_visible_6, pix_visible_5, pix_visible_4, pix_visible_3,
                                                    pix_visible_2, pix_visible_1, pix_visible_0
                                                };

                                // UPDATE CPU READABLE FLAGS DURING THE FRAME
                                collision_$i$ = collision_$i$ | detect_collision_$i$;
                                layer_collision_$i$ = layer_collision_$i$ | detect_layer_$i$;
                            }
                        $$end

                        // Output collision detection
                        output_collisions = ( pix_x == 639 ) & ( pix_y == 479 );
                    }
                    case 0: {}
                }
            }
        }
    }
}

algorithm sprite_layer_writer(
    // For setting sprite characteristics
    input   uint4   sprite_set_number,
    input   uint1   sprite_set_active,
    input   uint3   sprite_set_double,
    input   uint6   sprite_set_colour,
    input   int11   sprite_set_x,
    input   int11   sprite_set_y,
    input   uint3   sprite_set_tile,
    input   uint3   sprite_layer_write,
    input   uint13  sprite_update,

    // For reading sprite characteristics
    $$for i=0,15 do
        output  uint1   sprite_read_active_$i$,
        output  uint3   sprite_read_double_$i$,
        output  uint6   sprite_read_colour_$i$,
        output  int11   sprite_read_x_$i$,
        output  int11   sprite_read_y_$i$,
        output  uint3   sprite_read_tile_$i$,
    $$end
) <autorun> {
    // Storage for the sprites
    // Stored as registers as needed instantly
    uint1   sprite_active[16] = uninitialised;
    uint3   sprite_double[16] = uninitialised;
    uint6   sprite_colour[16] = uninitialised;
    int11   sprite_x[16] = uninitialised;
    int11   sprite_y[16] = uninitialised;
    uint3   sprite_tile_number[16] = uninitialised;
    uint1   output_collisions = 0;

    int11   sprite_offscreen_negative = uninitialised;
    int11   sprite_to_negative = uninitialised;
    uint1   sprite_offscreen_x = uninitialised;
    uint1   sprite_offscreen_y = uninitialised;

    $$for i=0,15 do
        // For setting sprite read paramers
        sprite_read_active_$i$ := sprite_active[$i$];
        sprite_read_double_$i$ := sprite_double[$i$];
        sprite_read_colour_$i$ := sprite_colour[$i$];
        sprite_read_x_$i$ := sprite_x[$i$];
        sprite_read_y_$i$ := sprite_y[$i$];
        sprite_read_tile_$i$ := sprite_tile_number[$i$];
    $$end

    always {
        // SET ATTRIBUTES + PERFORM UPDATE
        switch( sprite_layer_write ) {
            default: {}
            case 1: { sprite_active[ sprite_set_number ] = sprite_set_active; }
            case 2: { sprite_double[ sprite_set_number ] = sprite_set_double; }
            case 3: { sprite_colour[ sprite_set_number ] = sprite_set_colour; }
            case 4: { sprite_x[ sprite_set_number ] = sprite_set_x; }
            case 5: { sprite_y[ sprite_set_number ] = sprite_set_y; }
            case 6: { sprite_tile_number[ sprite_set_number ] = sprite_set_tile; }
            case 7: {
                // Sprite update helpers
                sprite_offscreen_negative = sprite_double[ sprite_set_number ][0,1] ? -32 : -16;
                sprite_to_negative = sprite_double[ sprite_set_number ][0,1] ? -31 : -15;
                sprite_offscreen_x = ( __signed( sprite_x[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) ) | ( __signed( sprite_x[ sprite_set_number  ] ) > __signed(640) );
                sprite_offscreen_y = ( __signed( sprite_y[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) ) | ( __signed( sprite_y[ sprite_set_number ] ) > __signed(480) );

                // Perform sprite update
                sprite_active[ sprite_set_number ] = ( ( sprite_update[12,1] & sprite_offscreen_y ) || ( sprite_update[11,1] & sprite_offscreen_x  ) ) ? 0 : sprite_active[ sprite_set_number ];
                sprite_tile_number[ sprite_set_number ] = sprite_tile_number[ sprite_set_number ] + sprite_update[10,1];
                sprite_x[ sprite_set_number ] = sprite_offscreen_x ? ( ( __signed( sprite_x[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) ) ?__signed(640) : sprite_to_negative ) :
                                                sprite_x[ sprite_set_number ] + { {7{spriteupdate( sprite_update ).dxsign}}, spriteupdate( sprite_update ).dx };
                sprite_y[ sprite_set_number ] = sprite_offscreen_y ? ( ( __signed( sprite_y[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) ) ? __signed(480) : sprite_to_negative ) :
                                                sprite_y[ sprite_set_number ] + { {7{spriteupdate( sprite_update ).dysign}}, spriteupdate( sprite_update ).dy };
            }
        }
    }
}

algorithm sprite_generator(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   sprite_active,
    input   uint3   sprite_double,
    input   int11   sprite_x,
    input   int11   sprite_y,
    input   uint3   sprite_tile_number,
    simple_dualport_bram_port0 tiles,
    output! uint1   pix_visible
) <autorun> {
    int11   x <: { 1b0, pix_x };
    int11   y <: { 1b0, pix_y };
    // Calculate position in sprite
    uint6 spritesize <: sprite_double[0,1] ? 32 : 16;
    uint1 xinrange <: ( x >= __signed(sprite_x) ) & ( x < __signed( sprite_x + spritesize ) );
    uint1 yinrange <: ( y >= __signed(sprite_y) ) & ( y < __signed( sprite_y + spritesize) );
    uint4 yinsprite <: sprite_double[2,1] ? 15 - ( ( y - sprite_y ) >>> sprite_double[0,1] ) : ( y - sprite_y ) >>> sprite_double[0,1];
    uint4 xinsprite <: sprite_double[1,1] ? (( ( x - sprite_x ) >>> sprite_double[0,1] ) ) : ( 15  - ( ( x - sprite_x ) >>> sprite_double[0,1] ) );

    // READ ADDRESS FOR SPRITE
    tiles.addr0 := { sprite_tile_number, yinsprite };

    // Determine if pixel is visible
    pix_visible := sprite_active & xinrange & yinrange & ( tiles.rdata0[ xinsprite, 1 ] );
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

    always {
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

