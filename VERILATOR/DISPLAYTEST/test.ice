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

    int32   counter = 0;
    uint8   grey = uninitialised;

    uint8   R[] = { 153, 255, 034, 070, 138, 255, 135, 229 };
    uint8   G[] = { 076, 215, 139, 130, 043, 192, 206, 255 };
    uint8   B[] = { 000, 000, 034, 180, 226, 203, 235, 204 };
    video_r := 0; video_g := 0; video_b := 0;

    while(1) {
        if( TEST.pixel_display ) {
            switch( counter[25,2] ) {
                case 2b00: {                                                                // PAWSv2 PALETTE, V1 + GRADIENTS
                    if( TEST.pixel[6,1] ) {
                        grey = ( TEST.pixel[0,3] + 1 ) * 25;                                // ROUGHLY 10%, 20%, 30%, 40%, 50%, 60%, 70%, 80%
                        switch( TEST.pixel[3,3] ) {
                            case 0: { video_r = grey; video_g = grey; video_b = grey; }     // GREYS
                            case 1: { video_r = grey; }                                     // REDS
                            case 2: { video_g = grey; }                                     // GREENS
                            case 3: { video_b = grey; }                                     // BLUES
                            case 4: { video_r = grey; video_g = grey; }                     // YELLOWS
                            case 5: { video_r = grey; video_b = grey; }                     // MAGENTAS
                            case 6: { video_g = grey; video_b = grey; }                     // CYANS
                            case 7: {                                                       // 8 SPECIAL COLOURS
                                video_r = R[ TEST.pixel[0,3] ];
                                video_g = G[ TEST.pixel[0,3] ];
                                video_b = B[ TEST.pixel[0,3] ];
                            }
                        }
                    } else {
                        video_r = {4{TEST.pixel[4,2]}};
                        video_g = {4{TEST.pixel[2,2]}};
                        video_b = {4{TEST.pixel[0,2]}};
                     }
                }
                case 2b01: {                                                                // PAWSv2 RRGGGBB
                    video_r = {4{TEST.pixel[4,2]}};
                    video_g = { TEST.pixel[6,1] ? { |TEST.pixel[2,2], 1b1 } : 2b00, {3{TEST.pixel[2,2]}} };
                    video_b = {4{TEST.pixel[0,2]}};
                }
                case 2b10: {                                                                // PAWSv1 + 64 GREY
                    if( TEST.pixel[6,1] ) {
                        grey = { TEST.pixel[0,6], TEST.pixel[0,2] };
                        video_r = grey; video_g = grey; video_b = grey;
                    } else {
                        video_r = {4{TEST.pixel[4,2]}};
                        video_g = {4{TEST.pixel[2,2]}};
                        video_b = {4{TEST.pixel[0,2]}};
                    }
                }
                case 2b11: {                                                                // PAWSv2 GREYSCALE
                    grey = { TEST.pixel[0,7], TEST.pixel[0,1] };
                    video_r = grey; video_g = grey; video_b = grey;
                }
            }
        } else {
            video_r = 0; video_g = 0; video_b = 0;
        }
        counter = counter + 1;
   }
}

algorithm testcard(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint7   pixel(0),
    output! uint1   pixel_display,
) <autorun> {
    pixel_display := pix_active & ( pix_x < 512 ) & ( pix_y < 256 ) & ( pixel != 64 );
    pixel := { pix_y[4,4], pix_x[6,3] };
}

