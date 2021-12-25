// HDMI for FPGA, VGA for SIMULATION
$$if HDMI then
$include('../common/hdmi.ice')
$$end

$$if VGA then
$include('vga.ice')
$$end

$$if ICARUS or VERILATOR then
// PLL for simulation
algorithm pll(
  output  uint1 video_clock,
  output! uint1 sdram_clock,
  output! uint1 clock_decode,
  output  uint1 compute_clock
) <autorun> {
  uint3 counter = 0;
  uint8 trigger = 8b11111111;
  sdram_clock   := clock;
  clock_decode   := clock;
  compute_clock := ~counter[0,1]; // x2 slower
  video_clock   := counter[1,1]; // x4 slower
  while (1) {
        counter = counter + 1;
        trigger = trigger >> 1;
  }
}
$$end

$include('../common/clean_reset.ice')

algorithm passthrough(input uint1 i,output! uint1 o)
{
  always { o=i; }
}

algorithm main(
    // LEDS (8 of)
    output  uint8   leds,

$$if HDMI then
    // HDMI OUTPUT
    output! uint4   gpdi_dp,
$$end
$$if VGA then
    // VGA OUTPUT
    output! uint$color_depth$ video_r,
    output! uint$color_depth$ video_g,
    output! uint$color_depth$ video_b,
    output  uint1 video_hs,
    output  uint1 video_vs,
$$end
$$if VERILATOR then
    output  uint1 video_clock
$$end
) {
$$if VERILATOR then
    $$clock_25mhz = 'video_clock'
    // --- PLL
    pll clockgen<@clock,!reset>(
      video_clock   :> video_clock
    );
$$end
    // Video Reset
    uint1   video_reset = uninitialised; clean_reset video_rstcond<@clock,!reset> ( out :> video_reset );

    // HDMI driver
    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1   vblank = uninitialized;
    uint1   pix_active = uninitialized;
    uint10  pix_x  = uninitialized;
    uint10  pix_y  = uninitialized;
$$if VGA then
  vga vga_driver<@video_clock,!reset>(
    vga_hs :> video_hs,
    vga_vs :> video_vs,
    vga_x  :> pix_x,
    vga_y  :> pix_y,
    vblank :> vblank,
    active :> pix_active,
  );
$$end
$$if HDMI then
    uint1   video_clock <: clock;
    uint8   video_r = uninitialized;
    uint8   video_g = uninitialized;
    uint8   video_b = uninitialized;
    hdmi video<@video_clock,!reset> (
        vblank  :> vblank,
        active  :> pix_active,
        x       :> pix_x,
        y       :> pix_y,
        gpdi_dp :> gpdi_dp,
        red     <: video_r,
        green   <: video_g,
        blue    <: video_b
    );
$$end

    testcard TEST <@video_clock,!video_reset> (
        pix_x <: pix_x,
        pix_y <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank
    );
    sprite_controller SPRITE <@video_clock,!video_reset> (
        video_clock <: video_clock,
        video_reset <: video_reset,
        pix_x <: pix_x,
        pix_y <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank
    );

    while(1) {
        if( SPRITE.pixel_display ) {
            video_r = {4{SPRITE.pixel[4,2]}};
            video_g = {4{SPRITE.pixel[2,2]}};
            video_b = {4{SPRITE.pixel[0,2]}};
        } else {
            if( TEST.pixel_display ) {
                video_r = {4{TEST.pixel[4,2]}};
                video_g = {4{TEST.pixel[2,2]}};
                video_b = {4{TEST.pixel[0,2]}};
            } else {
                video_r = 255;
                video_g = 255;
                video_b = 255;
            }
        }
    }
}

algorithm testcard(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   pixel_display,
) <autorun> {
    pixel_display := pix_active;

    while(1) {
        if( pix_vblank ) {
            pixel = 0;
        } else {
            if( pix_active ) {
                pixel = pixel + 1;
            }
        }
    }
}


// FRAMEWORK FOR BUILDING COLOUR SPRITE LAYER TESTS

// Sprite update flag
bitfield spriteupdate {
    uint1   y_act,              // 1 - kill when off screen, 0 - wrap
    uint1   x_act,              // 1 - kill when off screen, 0 - wrap
    uint1   tile_act,           // 1 - increase the tile number
    uint1   dysign,             // dy - 2's complement update for the y coordinate
    uint4   dy,
    uint1   dxsign,             // dx - 2's complement update for the x coordinate
    uint4   dx
}

// EQUIVALENT TO THE ENTRY FOR SPRITES IN VIDEO_MEMMAP
algorithm sprite_controller(
    // Clocks
    input   uint1   video_clock,
    input   uint1   video_reset,

    // Pixels
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   pixel_display,

    input   uint1   collision_layer_1,
    input   uint1   collision_layer_2,
    input   uint1   collision_layer_3,
    input   uint1   collision_layer_4,

    // For reading sprite characteristics
    $$for i=0,15 do
        output  uint1   sprite_read_active_$i$,
        output  uint3   sprite_read_double_$i$,
        output  uint6   sprite_read_colour_$i$,
        output  int11   sprite_read_x_$i$,
        output  int10   sprite_read_y_$i$,
        output  uint3   sprite_read_tile_$i$,
        output uint16   collision_$i$,
        output uint4    layer_collision_$i$,
    $$end
) <autorun,reginputs> {
    $$for i=0,15 do
        // Sprite Tiles
        simple_dualport_bram uint16 tiles_$i$ <@video_clock,@video_clock> [128] = {
            16hfffe, 16hfffe, 16hc006, 16hc006, 16hc006, 16hc006, 16hc006, 16hc006,
            16hc006, 16hc006, 16hc006, 16hc006, 16hc006, 16hfffe, 16hfffe, 16h0000,
            16h0180, 16h0180, 16h0180, 16h0180, 16h0180, 16h0180, 16h0180, 16h0180,
            16h0180, 16h0180, 16h0180, 16h0180, 16h0180, 16h0180, 16h0180, 16h0180,
            16hfffe, 16hfffe, 16h0006, 16h0006, 16h0006, 16h0006, 16hfffe, 16hfffe,
            16hc000, 16hc000, 16hc000, 16hc000, 16hc000, 16hfffe, 16hfffe, 16h0000,
            16hfffe, 16hfffe, 16h0006, 16h0006, 16h0006, 16h0006, 16h3ffe, 16h3ffe,
            16h0006, 16h0006, 16h0006, 16h0006, 16h0006, 16hfffe, 16hfffe, 16h0000,
            16hc006, 16hc006, 16hc006, 16hc006, 16hc006, 16hc006, 16hfffe, 16hfffe,
            16h0006, 16h0006, 16h0006, 16h0006, 16h0006, 16h0006, 16h0006, 16h0000,
            16hfffe, 16hfffe, 16hc000, 16hc000, 16hc000, 16hc000, 16hfffe, 16hfffe,
            16h0006, 16h0006, 16h0006, 16h0006, 16h0006, 16hfffe, 16hfffe, 16h0000,
            16hc000, 16hc000, 16hc000, 16hc000, 16hc000, 16hc000, 16hfffe, 16hfffe,
            16hc006, 16hc006, 16hc006, 16hc006, 16hc006, 16hfffe, 16hfffe, 16h0000,
            16hfffe, 16hfffe, 16h0006, 16h0006, 16h0006, 16h0006, 16h0006, 16h0006,
            16h0006, 16h0006, 16h0006, 16h0006, 16h0006, 16h0006, 16h0006, 16h0000
        };
    $$end

    uint16  updateflags[16] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
    uint8   count = uninitialised;

    sprite_display sprites <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        sprite_layer_display :> pixel_display,
        collision_layer_1 <: collision_layer_1,
        collision_layer_2 <: collision_layer_2,
        collision_layer_3 <: collision_layer_3,
        collision_layer_4 <: collision_layer_4,
        $$for i=0,15 do
            sprite_read_active_$i$ <: sprite_read_active_$i$,
            sprite_read_double_$i$ <: sprite_read_double_$i$,
            sprite_read_colour_$i$ <: sprite_read_colour_$i$,
            sprite_read_x_$i$ <: sprite_read_x_$i$,
            sprite_read_y_$i$ <: sprite_read_y_$i$,
            sprite_read_tile_$i$ <: sprite_read_tile_$i$,
            collision_$i$ :> collision_$i$,
            layer_collision_$i$ :> layer_collision_$i$,
        $$end
        $$for i=0,15 do
            tiles_$i$ <:> tiles_$i$,
        $$end
    );
    sprite_writer SLW <@video_clock,!video_reset> (
        $$for i=0,15 do
            sprite_read_active_$i$ :> sprite_read_active_$i$,
            sprite_read_double_$i$ :> sprite_read_double_$i$,
            sprite_read_colour_$i$ :> sprite_read_colour_$i$,
            sprite_read_x_$i$ :> sprite_read_x_$i$,
            sprite_read_y_$i$ :> sprite_read_y_$i$,
            sprite_read_tile_$i$ :> sprite_read_tile_$i$,
        $$end
    );

    // UPDATE THE SPRITE TILE BITMAPS
    spritebitmapwriter SBMW <@video_clock,!video_reset> (
        $$for i=0,15 do
            tiles_$i$ <:> tiles_$i$,
        $$end
    );

    SLW.sprite_layer_write := 0;

    // SETUP THE SPRITE DISPLAY
    count = 0;
    while( count != 16 ) {
        SLW.sprite_set_number = count;

        ++: SLW.sprite_layer_write = 1; SLW.sprite_write_value = 1;
        ++: SLW.sprite_layer_write = 2; SLW.sprite_write_value = count[0,3];
        ++: SLW.sprite_layer_write = 3; SLW.sprite_write_value = count;
        ++: SLW.sprite_layer_write = 4; SLW.sprite_write_value = 10 * count;
        ++: SLW.sprite_layer_write = 5;
        ++: SLW.sprite_layer_write = 6; SLW.sprite_write_value = count[0,3];

        count = count + 1;
    }

    while(1) {
        if( ( pix_x == 639 ) && ( pix_y == 479 ) ) {
            count = 0;
            while( count != 16 ) {
                SLW.sprite_set_number = count;
                SLW.sprite_write_value = updateflags[ count ];
                SLW.sprite_layer_write = 7;
                count = count + 1;
            }
        }
    }
}

algorithm sprite_display(
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
    uint4 yinsprite <: sprite_double[2,1] ? 15 - yspriteshift : yspriteshift;
    uint4 xinsprite <: sprite_double[1,1] ? xspriteshift : 15  - xspriteshift;

    // READ ADDRESS FOR SPRITE
    tiles.addr0 := { sprite_tile_number, yinsprite };

    // Determine if pixel is visible
    pix_visible := sprite_active & xinrange & yinrange & ( tiles.rdata0[ xinsprite, 1 ] );
}

algorithm sprite_writer(
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


