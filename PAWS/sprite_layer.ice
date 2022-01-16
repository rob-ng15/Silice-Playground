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
        input   int10   sprite_read_y_$i$,
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
) <autorun,reginputs> {
    $$for i=0,15 do
        // Set sprite generator parameters
        sprite_generator SPRITE_$i$(
            pix_x <: pix_x,
            pix_y <: pix_y,
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

    // Collisions in frame
    uint4   layer_collision_frame <: { collision_layer_1, collision_layer_2, collision_layer_3, collision_layer_4 };
    uint16  sprite_collision_frame <: { SPRITE_15.pix_visible, SPRITE_14.pix_visible, SPRITE_13.pix_visible, SPRITE_12.pix_visible, SPRITE_11.pix_visible,
                                        SPRITE_10.pix_visible, SPRITE_9.pix_visible, SPRITE_8.pix_visible, SPRITE_7.pix_visible,
                                        SPRITE_6.pix_visible, SPRITE_5.pix_visible, SPRITE_4.pix_visible, SPRITE_3.pix_visible,
                                        SPRITE_2.pix_visible, SPRITE_1.pix_visible, SPRITE_0.pix_visible
                                      };
    uint1   output_collisions <: ( pix_x == 639 ) & ( pix_y == 479 );


    // Default to transparent
    sprite_layer_display := pix_active & ( |sprite_collision_frame );
    pixel :=
        $$for i=0,14 do
                SPRITE_$15-i$.pix_visible ? sprite_read_colour_$15-i$ :
        $$end
        sprite_read_colour_0;

    always_before {
        if( pix_active ) {
            $$for i=0,15 do
                // UPDATE COLLISION DETECTION FLAGS
                if( SPRITE_$i$.pix_visible ) {
                    detect_collision_$i$ = detect_collision_$i$ | sprite_collision_frame;
                    detect_layer_$i$ = detect_layer_$i$ | layer_collision_frame;
                }
            $$end
        }
        if( output_collisions ) {
            $$for i=0,15 do
                // UPDATE CPU READABLE FLAGS DURING THE FRAME
                collision_$i$ = detect_collision_$i$;
                layer_collision_$i$ = detect_layer_$i$;
            $$end
        }
    }
    always_after {
        if( output_collisions ) {
            // RESET collision detection
            $$for i=0,15 do
                detect_collision_$i$ = 0;
                detect_layer_$i$ = 0;
            $$end
        }
    }
}

algorithm sprite_generator(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   sprite_active,
    input   uint3   sprite_double,
    input   int11   sprite_x,
    input   int10   sprite_y,
    input   uint3   sprite_tile_number,
    simple_dualport_bram_port0 tiles,
    output! uint1   pix_visible
) <autorun> {
    int11   x <: { 1b0, pix_x };                    int10   y <: pix_y;
    int11   xspritex <: ( x - sprite_x );           int11   xspriteshift <: xspritex >>> sprite_double[0,1];
    int10   yspritey <: ( y - sprite_y );           int10   yspriteshift <: yspritey >>> sprite_double[0,1];

    // Calculate position in sprite, handling reflection and doubling
    uint6 spritesize <: sprite_double[0,1] ? 32 : 16;
    uint1 xinrange <: ( x >= __signed(sprite_x) ) & ( x < __signed( sprite_x + spritesize ) );
    uint1 yinrange <: ( y >= __signed(sprite_y) ) & ( y < __signed( sprite_y + spritesize ) );
    uint4 yinsprite <: sprite_double[2,1] ? ~yspriteshift : yspriteshift;
    uint4 xinsprite <: sprite_double[1,1] ? xspriteshift : ~xspriteshift;

    // READ ADDRESS FOR SPRITE
    tiles.addr0 := { sprite_tile_number, yinsprite };

    // Determine if pixel is visible
    pix_visible := sprite_active & xinrange & yinrange & ( tiles.rdata0[ xinsprite, 1 ] );
}

algorithm sprite_layer_writer(
    // For setting sprite characteristics
    input   uint4   sprite_set_number,
    input   uint13  sprite_write_value,
    input   uint3   sprite_layer_write,

    // For reading sprite characteristics
    $$for i=0,15 do
        output  uint1   sprite_read_active_$i$,
        output  uint3   sprite_read_double_$i$,
        output  uint6   sprite_read_colour_$i$,
        output  int11   sprite_read_x_$i$,
        output  int10   sprite_read_y_$i$,
        output  uint3   sprite_read_tile_$i$,
    $$end
) <autorun,reginputs> {
    // Storage for the sprites
    // Stored as registers as needed instantly
    uint1   sprite_active[16] = uninitialised;
    uint3   sprite_double[16] = uninitialised;
    uint6   sprite_colour[16] = uninitialised;
    int11   sprite_x[16] = uninitialised;
    int10   sprite_y[16] = uninitialised;
    uint3   sprite_tile_number[16] = uninitialised;

    int11   sprite_offscreen_negative <: sprite_double[ sprite_set_number ][0,1] ? -32 : -16;
    int11   sprite_to_negative <: sprite_double[ sprite_set_number ][0,1] ? -31 : -15;
    uint1   sprite_offscreen_x = uninitialised;
    uint1   sprite_offscreen_y = uninitialised;
    uint1   sprite_off_left = uninitialised;
    uint1   sprite_off_top = uninitialised;
    int11   sprite_update_x <:: { {7{spriteupdate( sprite_write_value ).dxsign}}, spriteupdate( sprite_write_value ).dx };
    int10   sprite_update_y <:: { {6{spriteupdate( sprite_write_value ).dysign}}, spriteupdate( sprite_write_value ).dy };

    $$for i=0,15 do
        // For setting sprite read paramers
        sprite_read_active_$i$ := sprite_active[$i$];
        sprite_read_double_$i$ := sprite_double[$i$];
        sprite_read_colour_$i$ := sprite_colour[$i$];
        sprite_read_x_$i$ := sprite_x[$i$];
        sprite_read_y_$i$ := sprite_y[$i$];
        sprite_read_tile_$i$ := sprite_tile_number[$i$];
    $$end

    always_before {
        // CALCULATE HELPER VALUES FOR SPRITE UPDATE
        sprite_off_left = ( __signed( sprite_x[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) );
        sprite_off_top = ( __signed( sprite_y[ sprite_set_number ] ) < __signed( sprite_offscreen_negative ) );
        sprite_offscreen_x = sprite_off_left | ( __signed( sprite_x[ sprite_set_number  ] ) > __signed(640) );
        sprite_offscreen_y = sprite_off_top | ( __signed( sprite_y[ sprite_set_number ] ) > __signed(480) );
    }
    always_after {
        // SET ATTRIBUTES + PERFORM UPDATE
        switch( sprite_layer_write ) {
            case 0: {}
            case 1: { sprite_active[ sprite_set_number ] = sprite_write_value[0,1]; }
            case 2: { sprite_double[ sprite_set_number ] = sprite_write_value[0,3]; }
            case 3: { sprite_colour[ sprite_set_number ] = sprite_write_value[0,6]; }
            case 4: { sprite_x[ sprite_set_number ] = sprite_write_value[0,11]; }
            case 5: { sprite_y[ sprite_set_number ] = sprite_write_value[0,10]; }
            case 6: { sprite_tile_number[ sprite_set_number ] = sprite_write_value[0,3]; }
            case 7: {
                // PERFORM SPRITE UPDATE
                sprite_active[ sprite_set_number ] = ( ( sprite_write_value[12,1] & sprite_offscreen_y ) | ( sprite_write_value[11,1] & sprite_offscreen_x ) ) ? 0 : sprite_active[ sprite_set_number ];
                sprite_tile_number[ sprite_set_number ] = sprite_tile_number[ sprite_set_number ] + sprite_write_value[10,1];
                sprite_x[ sprite_set_number ] = sprite_offscreen_x ? ( sprite_off_left ?__signed(640) : sprite_to_negative ) :
                                                sprite_x[ sprite_set_number ] + sprite_update_x;
                sprite_y[ sprite_set_number ] = sprite_offscreen_y ? ( sprite_off_top ? __signed(480) : sprite_to_negative ) :
                                                sprite_y[ sprite_set_number ] + sprite_update_y;
            }
        }
    }
}

algorithm spritebitmapwriter(
    $$for i=0,15 do
        simple_dualport_bram_port1 tiles_$i$,
    $$end
    input   uint4   sprite_writer_sprite,
    input   uint7   sprite_writer_line,
    input   uint16  sprite_writer_bitmap,
) <autorun,reginputs> {
    $$for i=0,15 do
        tiles_$i$.wenable1 := 1;
    $$end

    always_after {
        // WRITE BITMAP TO SPRITE TILE
        switch( sprite_writer_sprite ) {
            $$for i=0,15 do
                case $i$: { tiles_$i$.addr1 = sprite_writer_line; tiles_$i$.wdata1 = sprite_writer_bitmap; }
            $$end
        }
    }
}

