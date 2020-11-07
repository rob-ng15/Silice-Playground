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

// Storage and pixel colour generator for each sprite
algorithm sprite(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    output! uint4   pix_colour,
    output! uint1   pix_visible,

    input   uint1   sprite_active,
    input   uint1   sprite_double,
    input   uint2   sprite_colmode,
    input   uint3   sprite_tile,
    input   int11   sprite_x,
    input   int11   sprite_y,

    input   uint7   writer_line,
    input   uint16  writer_bitmap,
    input   uint1   writer_active
) {
    // Sprite Tiles
    dualport_bram uint16 tiles[128] = uninitialised;

    // Calculate if sprite is visible
    uint4 xinsprite := 15  - ( ( pix_x - sprite_x ) >> sprite_double );
    uint1 xinrange := ( pix_x >= sprite_x ) && ( pix_x < ( sprite_x + ( 16 << sprite_double ) ) );
    uint1 yinrange := ( pix_y >= sprite_y ) && ( pix_y < ( sprite_y + ( 16 << sprite_double ) ) );

    // Set read and write address for the tiles
    tiles.addr0 := sprite_tile * 16 + ( ( pix_y - sprite_y ) >> sprite_double );
    tiles.wenable0 := 0;
    tiles.wenable1 := 1;

    pix_visible := 0;

    while(1) {
        if( writer_active ) {
            tiles.addr1 = writer_line;
            tiles.wdata1 = writer_bitmap;
        }

        if( sprite_active && xinrange && yinrange ) {
            pix_colour = tiles.rdata0[ xinsprite, 1 ];
            pix_visible = tiles.rdata0[ xinsprite, 1 ] > 0;
        }
    }
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
    input   uint2   sprite_set_colmode,
    input   uint6   sprite_set_colour,
    input   int11   sprite_set_x,
    input   int11   sprite_set_y,
    input   uint3   sprite_set_tile,
    // Flag to set the above
    input   uint4   sprite_layer_write,

    // For reading sprite characteristics for sprite_set_number
    output  uint1   sprite_read_active,
    output  uint1   sprite_read_double,
    output  uint2   sprite_read_colmode,
    output  uint6   sprite_read_colour,
    output  int11   sprite_read_x,
    output  int11   sprite_read_y,
    output  uint3   sprite_read_tile,
    input   uint16  sprite_update,
    // FULL collision detection
    // Bitmap is set flag
    input   uint1   bitmap_display,
    $$for i=0,12 do
        output uint16 collision_$i$,
    $$end

    // For setting sprite tile bitmaps
    input   uint4   sprite_writer_sprite,
    input   uint7   sprite_writer_line,
    input   uint16  sprite_writer_bitmap,
    input   uint1   sprite_writer_active,

    // For setting 3 or 15 colour sprite palette
    $$for i=1,15 do
        input uint6 sprite_palette_$i$,
    $$end
) <autorun> {
    // Storage for the sprites
    // Stored as registers as needed instantly
    uint1 sprite_active[13] = uninitialised;
    uint1 sprite_double[13] = uninitialised;
    int11 sprite_x[13] = uninitialised;
    int11 sprite_y[13] = uninitialised;
    uint6 sprite_colour[13] = uninitialised;
    uint3 sprite_tile_number[13] = uninitialised;

    // Setup 13 sprites
    $$for i=0,12 do
        uint1 sprite_active_$i$ := sprite_active[$i$];
        uint1 sprite_double_$i$ := sprite_double[$i$];
        uint2 sprite_colmode_$i$ := sprite_colmode[$i$];
        int11 sprite_x_$i$ := sprite_x[$i$];
        int11 sprite_y_$i$ := sprite_y[$i$];
        uint3 sprite_tile_number_$i$ := sprite_tile_number[$i$];
        uint1 sprite_write_active_$i$ := ( sprite_writer_active == 1 ) && ( sprite_writer_sprite == $i$ );

        sprite sprite_$i$(
            pix_x <: pix_x,
            pix_y <: pix_y,
            pix_active <: pix_active,

            sprite_active <: sprite_active_$i$,
            sprite_double <: sprite_double_$i$,
            sprite_tile <: sprite_tile_number_$i$,
            sprite_x <: sprite_x_$i$,
            sprite_y <: sprite_y_$i$,

            writer_line <: sprite_writer_line,
            writer_bitmap <: sprite_writer_bitmap,
            writer_active <: sprite_write_active_$i$
        );
    $$end

    // Palette for 3 or 15 colour sprites - shared
    uint6 palette[16] = uninitialised;

    // Collision detection storage
    $$for i=0,12 do
        uint16      detect_collision_$i$ = uninitialised;
    $$end

    // Expand Sprite Update Deltas
    int11 deltax := { {9{spriteupdate( sprite_update ).dxsign}}, spriteupdate( sprite_update ).dx };
    int11 deltay := { {9{spriteupdate( sprite_update ).dysign}}, spriteupdate( sprite_update ).dy };

    // Set 3 or 15 colour sprite palette
    $$for i=1,15 do
        palette[$i$] := sprite_palette_$i$;
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

    // Write to the sprite_layer
    // Set tile bitmaps, x coordinate, y coordinate, colour, tile number, visibility, double
    always {
        switch( sprite_layer_write ) {
            case 1: { sprite_active[ sprite_set_number ] = sprite_set_active; }
            case 2: { sprite_tile_number[ sprite_set_number ] = sprite_set_tile; }
            case 3: { sprite_colour[ sprite_set_number ] = sprite_set_colour; }
            case 4: { sprite_x[ sprite_set_number ] = sprite_set_x; }
            case 5: { sprite_y[ sprite_set_number ] = sprite_set_y; }
            case 6: { sprite_double[ sprite_set_number ] = sprite_set_double; }
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
            $$for i=0,12 do
                detect_collision_$i$ = 0;
            $$end
        } else {
            if( pix_active ) {
                $$for i=0,12 do
                    if(  ( sprite_$i$.pix_visible ) ) {
                        // Single colour
                        pix_red = sprite_colour[$i$][4,2];
                        pix_green = sprite_colour[$i$][2,2];
                        pix_blue = sprite_colour[$i$][0,2];
                        sprite_layer_display = 1;

                        // Perform collision detection
                        detect_collision_$i$ = detect_collision_$i$ | {
                            bitmap_display, 1b0, 1b0, sprite_12.pix_visible, sprite_11.pix_visible,
                            sprite_10.pix_visible, sprite_9.pix_visible, sprite_8.pix_visible, sprite_7.pix_visible,
                            sprite_6.pix_visible, sprite_5.pix_visible, sprite_4.pix_visible, sprite_3.pix_visible,
                            sprite_2.pix_visible, sprite_1.pix_visible, sprite_0.pix_visible
                        };
                    }
                $$end
            }
        }

        // Output collision detection
        if( ( pix_x == 639 ) && ( pix_y == 479 ) ) {
            $$for i=0,12 do
                collision_$i$ = detect_collision_$i$;
            $$end
        }
    }
}
