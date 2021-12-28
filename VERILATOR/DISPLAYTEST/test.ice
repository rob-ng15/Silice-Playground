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
    tilemap_controller TILE <@video_clock,!video_reset> (
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
            if( TILE.pixel_display ) {
                video_r = {4{TILE.pixel[4,2]}};
                video_g = {4{TILE.pixel[2,2]}};
                video_b = {4{TILE.pixel[0,2]}};
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
}

algorithm testcard(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel(0),
    output! uint1   pixel_display,
) <autorun> {
    pixel_display := pix_x < 320;
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

// 7 bit colour either ALPHA (background or lower layer) or red, green, blue { Arrggbb }
bitfield colour7 {
    uint1   alpha,
    uint2   red,
    uint2   green,
    uint2   blue
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
        output  uint4   sprite_read_double_$i$,
        output  int11   sprite_read_x_$i$,
        output  int10   sprite_read_y_$i$,
        output  uint3   sprite_read_tile_$i$,
        output uint16   collision_$i$,
        output uint4    layer_collision_$i$,
    $$end
) <autorun,reginputs> {
    $$for i=0,15 do
        // Sprite Tiles - 16 x 16 x 8 in ARRGGBB colour
        simple_dualport_bram uint7 tiles_$i$ <@video_clock,@video_clock> [2048] = {
               42, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$,    63,    63,    63,    63,    63, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$,    63,    63, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$,    63, $i+4$,    63, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$,    63, $i+4$, $i+4$,    63, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$,    63, $i+4$, $i+4$, $i+4$,    63, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$,
            pad( uninitialised )
        };
    $$end

    uint16  updateflags[16] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
    uint8   count = uninitialised;

    sprite_layer sprites <@video_clock,!video_reset> (
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

        ++: SLW.sprite_layer_write = 1; SLW.sprite_write_value = 1;                 // ACTIVE
        ++: SLW.sprite_layer_write = 2; SLW.sprite_write_value = count[0,4];        // DOUBLE / REFLECTION
        ++: SLW.sprite_layer_write = 4; SLW.sprite_write_value = 32 * count;        // X
        ++: SLW.sprite_layer_write = 5; SLW.sprite_write_value = 16 * count;        // Y
        ++: SLW.sprite_layer_write = 6; SLW.sprite_write_value = 0;                 // TILE

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
        input   uint4   sprite_read_double_$i$,
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
            pix_active <: pix_active,
            pix_vblank <: pix_vblank,
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
                SPRITE_$15-i$.pix_visible ? SPRITE_$15-i$.pixel :
        $$end
        SPRITE_0.pixel;

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
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    input   uint1   sprite_active,
    input   uint4   sprite_double,
    input   int11   sprite_x,
    input   int11   sprite_y,
    input   uint3   sprite_tile_number,
    simple_dualport_bram_port0 tiles,
    output! uint1   pix_visible,
    output! uint6   pixel
) <autorun> {
    int11   x <: { 1b0, pix_x };                                                                        int11   xspritex <: ( x - sprite_x ) + pix_active;
    int11   y <: { 1b0, pix_y };                                                                        int11   yspritey <: ( y - sprite_y );
    int11   xspriteshift <: ( xspritex >>> sprite_double[0,1] );                                        int11   yspriteshift <: yspritey >>> sprite_double[0,1];

    uint4   revx <: 15 - xspriteshift;                                                                  uint4   revy <: 15 - yspriteshift;
    uint1   action00 <: ( ~|sprite_double[1,2] );         uint1   action01 <: ( sprite_double[1,2] == 2b01 );         uint1   action10 <: ( sprite_double[1,2] == 2b10 );

    // Calculate position in sprite, handling rotation/reflection and doubling
    uint6 spritesize <: sprite_double[0,1] ? 32 : 16;
    uint1 xinrange <: ( x >= __signed(sprite_x) ) & ( x < __signed( sprite_x + spritesize ) );
    uint1 yinrange <: ( y >= __signed(sprite_y) ) & ( y < __signed( sprite_y + spritesize ) );
    uint4 xinsprite <: sprite_double[3,1] ? action00 ? xspriteshift : action01 ? revy : action10 ? revx : yspriteshift :
                            sprite_double[1,1] ? revx : xspriteshift;
    uint4 yinsprite <: sprite_double[3,1] ? action00 ? yspriteshift : action01 ? xspriteshift : action10 ? revy : revx :
                            sprite_double[2,1] ? revy : yspriteshift;

    // READ ADDRESS FOR SPRITE
    tiles.addr0 := { sprite_tile_number, yinsprite, xinsprite };

    // Determine if pixel is visible
    pix_visible := sprite_active & xinrange & yinrange & ( ~colour7(tiles.rdata0).alpha );
    pixel := tiles.rdata0[ 0, 6 ];
}

algorithm sprite_writer(
    // For setting sprite characteristics
    input   uint4   sprite_set_number,
    input   uint13  sprite_write_value,
    input   uint3   sprite_layer_write,

    // For reading sprite characteristics
    $$for i=0,15 do
        output  uint1   sprite_read_active_$i$,
        output  uint4   sprite_read_double_$i$,
        output  int11   sprite_read_x_$i$,
        output  int10   sprite_read_y_$i$,
        output  uint3   sprite_read_tile_$i$,
    $$end
) <autorun,reginputs> {
    // Storage for the sprites
    // Stored as registers as needed instantly
    uint1   sprite_active[16] = uninitialised;
    uint4   sprite_double[16] = uninitialised;
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
    input   uint4   sprite_writer_pixel,
    input   uint7   sprite_writer_colour,
) <autorun,reginputs> {
    $$for i=0,15 do
        tiles_$i$.wenable1 := 1;
    $$end

    always_after {
        // WRITE BITMAP TO SPRITE TILE
        switch( sprite_writer_sprite ) {
            $$for i=0,15 do
                case $i$: { tiles_$i$.addr1 = { sprite_writer_line, sprite_writer_pixel }; tiles_$i$.wdata1 = sprite_writer_colour; }
            $$end
        }
    }
}

// FRAMEWORK FOR BUILDING COLOUR TILEMAP LAYER TESTS

// EQUIVALENT TO THE ENTRY FOR TILEMAPS IN VIDEO_MEMMAP
algorithm tilemap_controller(
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

    // Memory access
    input   uint6   memoryAddress,
    input   uint1   memoryWrite,
    input   uint16  writeData,
    output  uint4   tm_lastaction,
    output  uint2   tm_active
) <autorun,reginputs> {
    // Tiles 64 x 16 x 16
    simple_dualport_bram uint7 tiles16x16 <@video_clock,@video_clock> [ 16384 ] = {
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
        $$for i=0,15 do
               42, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$,    63,    63,    63,    63,    63, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$,    63,    63, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$,    63, $i+4$,    63, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$,    63, $i+4$, $i+4$,    63, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$,    63, $i+4$, $i+4$, $i+4$,    63, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+4$, $i+8$,
            $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$, $i+8$,
        $$end
        pad(uninitialized)
    };

    // 42 x 32 tile map, allows for pixel scrolling with border { 2 bit reflection, 6 bits tile number }
    simple_dualport_bram uint6 tiles <@video_clock,@video_clock> [1344] = uninitialized;
    simple_dualport_bram uint3 actions <@video_clock,@video_clock> [1344] = uninitialized;

    tilemap tile_map <@video_clock,!video_reset> (
        tiles16x16 <:> tiles16x16,
        tiles <:> tiles,
        actions <:> actions,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: pix_vblank,
        pixel    :> pixel,
        tm_offset_x <: TMW.tm_offset_x,
        tm_offset_y <: TMW.tm_offset_y,
        tilemap_display :> pixel_display
    );

    uint8   x = 0;                                  uint8   y = 0;                                      uint8   count = 1;

    tile_map_writer TMW <@video_clock,!video_reset> ( tiles <:> tiles, actions <:> actions );
    tilebitmapwriter TBMW <@video_clock,!video_reset> ( tiles16x16 <:> tiles16x16 );

    TMW.tm_write := 0; TMW.tm_scrollwrap := 0;

    while( y < 2 ) {
        x = 0;
        while( x < 42 ) {
            TMW.tm_x = x; TMW.tm_y = y + 16; TMW.tm_actions = ( count - 1 ) & 7; TMW.tm_character = count; TMW.tm_write = 1;
            x = x + 1; count = ( count == 16 ) ? 1 : count + 1;
        }
        y = y + 1;
    }

    while( 1 ) {
        if( ( pix_x == 639 ) && ( pix_y == 479 ) ) {
            TMW.tm_scrollwrap = 7; ++:
            TMW.tm_scrollwrap = 8;
        }
    }

}

algorithm tilemap(
    simple_dualport_bram_port0 tiles16x16,
    simple_dualport_bram_port0 tiles,
    simple_dualport_bram_port0 actions,

    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint6   pixel,
    output! uint1   tilemap_display,

    // For scrolling/wrapping
    input   int5    tm_offset_x,
    input   int5    tm_offset_y
) <autorun> {
    // Character position on the screen x 0-41, y 0-31 * 42 ( fetch it two pixels ahead of the actual x pixel, so it is always ready, colours 1 pixel ahead )
    // Adjust for the offsets, effective 0 point margin is ( 1,1 ) to ( 40,30 ) with a 1 tile border
    uint6   xtmpos <: ( {{6{tm_offset_x[4,1]}}, tm_offset_x} + ( pix_active ? ( pix_x + 11d18 ) : 11d16 ) ) >> 4;
    uint6   xtmposactions <: ( {{6{tm_offset_x[4,1]}}, tm_offset_x} + ( pix_active ? ( pix_x + 11d17 ) : 11d16 ) ) >> 4;
    uint11  ytmpos <: ( {{6{tm_offset_y[4,1]}}, tm_offset_y} + ( pix_vblank ? 11d16 : 11d16 + pix_y ) ) >> 4;

    // Derive the x and y coordinate within the current 16x16 tilemap block x 0-15, y 0-15, adjusted for offsets
    uint4   xintm <: { 1b0, pix_x[0,4] } + tm_offset_x;                                                 uint4   revx <: 15 - xintm;
    uint4   yintm <: { 1b0, pix_y[0,4] } + tm_offset_y;                                                 uint4   revy <: 15 - yintm;

    uint1   action00 <:: ( ~|actions.rdata0[0,2] ); uint1   action01 <:: ( actions.rdata0[0,2] == 2b01 );
    uint1   action10 <:: ( actions.rdata0[0,2] == 2b10 );

    // Set up reading of the tilemap
    tiles.addr0 := xtmpos + ytmpos * 42; actions.addr0 := xtmposactions + ytmpos * 42;

    // Setup the reading and writing of the tiles16x16 using rotation/reflection
    tiles16x16.addr0 := { tiles.rdata0,
                            actions.rdata0[2,1] ? action00 ? yintm : action01 ? xintm : action10 ? revy : revx :
                                actions.rdata0[1,1] ? revy : yintm,
                            actions.rdata0[2,1] ? action00 ? xintm : action01 ? revy : action10 ? revx : yintm :
                                actions.rdata0[0,1] ? revx : xintm };

    tilemap_display := pix_active & ~colour7( tiles16x16.rdata0 ).alpha;
    pixel := tiles16x16.rdata0[0,6];
}

algorithm   calcoffset(
    input   int5    offset,
    output  uint1   MIN,
    output  int5    PREV,
    output  uint1   MAX,
    output  int5    NEXT
) <autorun> {
    always_after {
        MIN = ( offset == -15 );                    PREV = ( offset - 1 );
        MAX = ( offset == 15 );                     NEXT = ( offset + 1 );
    }
}

algorithm tile_map_writer(
    simple_dualport_bram_port1 tiles,
    simple_dualport_bram_port1 actions,

    // Set TM at x, y, character with foreground, background and rotation
    input   uint6   tm_x,
    input   uint6   tm_y,
    input   uint6   tm_character,
    input   uint3   tm_actions,
    input   uint1   tm_write,

    // For scrolling/wrapping
    output  int5    tm_offset_x(0),
    output  int5    tm_offset_y(0),

    input   uint4   tm_scrollwrap,
    output  uint4   tm_lastaction,
    output  uint3   tm_active
) <autorun,reginputs> {
    // COPY OF TILEMAP FOR SCROLLING
    simple_dualport_bram uint6 tiles_copy[1344] = uninitialized;
    simple_dualport_bram uint3 actions_copy[1344] = uninitialized;

    // OFFSET CALCULATIONS
    calcoffset TMOX( offset <: tm_offset_x );       calcoffset TMOY( offset <: tm_offset_y );

    // Scroller/Wrapper FLAGS
    uint1   tm_scroll = uninitialized;              uint1   tm_sw <:: ( tm_scrollwrap < 5 );                uint2   tm_action <:: ( tm_scrollwrap - 1 ) & 3;
    uint1   tm_dodir = uninitialized;

    // CURSORS AND ADDRESSES FOR SCROLLING WRAPPING
    uint6   x_cursor = uninitialized;               uint6   xNEXT <:: x_cursor + 1;                         uint6   xPREV <:: x_cursor - 1;
                                                    uint11  xSAVED <:: x_cursor + ( tm_dodir ? 1302 : 0 );
    uint11  y_cursor_addr = uninitialized;          uint11  yNEXT <:: y_cursor_addr + 42;                   uint11  yPREV <:: y_cursor_addr - 42;
                                                    uint11  ySAVED <:: y_cursor_addr + ( tm_dodir ? 41 : 0 );
    uint11  temp_1 = uninitialized;
    uint11  temp_2 <:: x_cursor + y_cursor_addr;    uint11  temp_2NEXT1 <:: temp_2 + 1;                     uint11  temp_2PREV1 <:: temp_2 - 1;
                                                    uint11  temp_2NEXT42 <:: temp_2 + 42;                   uint11  temp_2PREV42 <:: temp_2 - 42;
    uint11  write_address <:: tm_x + tm_y * 42;

    // STORAGE FOR SAVED CHARACTER WHEN WRAPPING
    uint6   new_tile = uninitialized; uint2  new_action = uninitialized;

    // CLEARSCROLL address
    uint11  tmcsaddr = uninitialized;               uint11  tmcsNEXT <:: tmcsaddr + 1;

    // TILEMAP WRITE FLAGS
    tiles.wenable1 := 1; tiles_copy.wenable1 := 1; actions.wenable1 := 1; actions_copy.wenable1 := 1;

    always_after {
        if( tm_write ) {
            // Write character to the tilemap
            tiles.addr1 = write_address; tiles.wdata1 = tm_character;
            tiles_copy.addr1 =write_address; tiles_copy.wdata1 = tm_character;
            actions.addr1 = write_address; actions.wdata1 = tm_actions;
            actions_copy.addr1 = write_address; actions_copy.wdata1 = tm_actions;
        }

        switch( tm_scrollwrap ) {                                                                                           // ACT AS PER tm_scrollwrap
            case 0: {}                                                                                                      // NO ACTION
            case 9: { tm_active = 4; tm_lastaction = 9; }                                                                   // CLEAR
            default: {                                                                                                      // SCROLL / WRAP
                tm_scroll = tm_sw;
                switch( tm_action ) {
                    case 0: { if( TMOX.MAX ) { tm_dodir = 1; tm_active = 1; } else { tm_offset_x = TMOX.NEXT; } }           // LEFT
                    case 1: { if( TMOY.MAX ) { tm_dodir = 1; tm_active = 2; } else { tm_offset_y = TMOY.NEXT; } }           // UP
                    case 2: { if( TMOX.MIN ) { tm_dodir = 0; tm_active = 1; } else { tm_offset_x = TMOX.PREV; } }           // RIGHT
                    case 3: { if( TMOY.MIN ) { tm_dodir = 0; tm_active = 2; } else { tm_offset_y = TMOY.PREV; } }           // DOWN
                }
                tm_lastaction = ( |tm_active ) ? tm_scrollwrap : 0;
            }
        }
    }

    while(1) {
        if( |tm_active ) {
            onehot( tm_active ) {
                case 0: {                                                                                                   // SCROLL/WRAP LEFT/RIGHT
                    while( y_cursor_addr != 1344 ) {                                                                            // REPEAT UNTIL AT BOTTOM OF THE SCREEN
                        x_cursor = tm_dodir ? 0 : 41;                                                                           // SAVE CHARACTER AT START/END OF LINE FOR WRAPPING
                        temp_1 = y_cursor_addr + x_cursor;
                        tiles_copy.addr0 = temp_1; actions_copy.addr0 = temp_1;
                        ++:
                        new_tile = tm_scroll ? 0 : tiles_copy.rdata0;
                        new_action = tm_scroll ? 2h0 : actions_copy.rdata0;
                        while( tm_dodir ? ( x_cursor != 42 ) : ( |x_cursor ) ) {                                                // START AT THE LEFT/RIGHT OF THE LINE
                            temp_1 = tm_dodir ? temp_2NEXT1 : temp_2PREV1;                                                      // SAVE THE ADJACENT CHARACTER
                            tiles_copy.addr0 = temp_1; actions_copy.addr0 = temp_1;
                            ++:
                            tiles.addr1 = temp_2; tiles.wdata1 = tiles_copy.rdata0;                                             // COPY INTO NEW LOCATION
                            tiles_copy.addr1 = temp_2; tiles_copy.wdata1 = tiles_copy.rdata0;
                            actions.addr1 = temp_2; actions.wdata1 = actions_copy.rdata0;
                            actions_copy.addr1 = temp_2; actions_copy.wdata1 = actions_copy.rdata0;
                            x_cursor = tm_dodir ? xNEXT : xPREV;                                                                // MOVE TO NEXT CHARACTER ON THE LINE
                        }
                        tiles.addr1 = ySAVED; tiles.wdata1 = new_tile;                                                          // WRITE BLANK OR THE WRAPPED CHARACTER
                        tiles_copy.addr1 = ySAVED; tiles_copy.wdata1 = new_tile;
                        actions.addr1 = ySAVED; actions.wdata1 = new_action;
                        actions_copy.addr1 = ySAVED; actions_copy.wdata1 = new_action;
                        y_cursor_addr = yNEXT;
                    }
                    tm_offset_x = 0;
                }
                case 1: {                                                                                                   // SCROLL/WRAP UP/DOWN
                    while( x_cursor != 42 ) {                                                                                   // REPEAT UNTIL AT RIGHT OF THE SCREEN
                        y_cursor_addr = tm_dodir ? 0 : 1302;                                                                    // SAVE CHARACTER AT TOP/BOTTOM OF THE SCREEN FOR WRAPPING
                        temp_1 = x_cursor + y_cursor_addr;
                        tiles_copy.addr0 = temp_1; actions_copy.addr0 = temp_1;
                        ++:
                        new_tile = tm_scroll ? 0 : tiles_copy.rdata0;
                        new_action = tm_scroll ? 2h0 : actions_copy.rdata0;
                        while( tm_dodir ? ( y_cursor_addr != 1302 ) : ( |y_cursor_addr ) ) {                                    // START AT TOP/BOTTOM OF THE SCREEN
                            temp_1 = tm_dodir ? temp_2NEXT42 : temp_2PREV42;                                                    // SAVE THE ADJACENT CHARACTER
                            tiles_copy.addr0 = temp_1; actions_copy.addr0 = temp_1;
                            ++:
                            tiles.addr1 = temp_2; tiles.wdata1 = tiles_copy.rdata0;                                             // COPY TO NEW LOCATION
                            tiles_copy.addr1 = temp_2; tiles_copy.wdata1 = tiles_copy.rdata0;
                            actions.addr1 = temp_2; actions.wdata1 = actions_copy.rdata0;
                            actions_copy.addr1 = temp_2; actions_copy.wdata1 = actions_copy.rdata0;
                            y_cursor_addr = tm_dodir ? yNEXT : yPREV;                                                           // MOVE TO THE NEXT CHARACTER IN THE COLUMN
                        }
                        tiles.addr1 = xSAVED; tiles.wdata1 = new_tile;                                                          // WRITE BLANK OR WRAPPED CHARACTER
                        tiles_copy.addr1 = xSAVED; tiles_copy.wdata1 = new_tile;
                        actions.addr1 = xSAVED; actions.wdata1 = new_action;
                        actions_copy.addr1 = xSAVED; actions_copy.wdata1 = new_action;
                        x_cursor = xNEXT;
                    }
                    tm_offset_y = 0;
                }
                case 2: {                                                                                                   // CLEAR
                    tiles.wdata1 = 0; tiles_copy.wdata1 = 0; actions.wdata1 = 2h0; actions_copy.wdata1 = 2h0;
                    while( tmcsaddr != 1344 ) {
                        tiles.addr1 = tmcsaddr; tiles_copy.addr1 = tmcsaddr;
                        actions.addr1 = tmcsaddr; actions_copy.addr1 = tmcsaddr;
                        tmcsaddr = tmcsNEXT;
                    }
                    tm_offset_x = 0;
                    tm_offset_y = 0;
                }
            }
            tm_active = 0;
        } else {
            tmcsaddr = 0; y_cursor_addr = 0; x_cursor = 0;                                                                  // RESET SCROLL/WRAP
        }
    }
}

algorithm tilebitmapwriter(
    input   uint6   tile_writer_tile,
    input   uint4   tile_writer_line,
    input   uint4   tile_writer_pixel,
    input   uint7   tile_writer_colour,

    simple_dualport_bram_port1 tiles16x16
) <autorun,reginputs> {
    tiles16x16.wenable1 := 1;
    always_after {
        tiles16x16.addr1 = { tile_writer_tile, tile_writer_line, tile_writer_pixel };
        tiles16x16.wdata1 = tile_writer_colour;
    }
}

