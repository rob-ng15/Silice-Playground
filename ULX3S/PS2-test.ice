$include('../common/hdmi.ice')
$include('terminal.ice')
import('common/ulx3s_clk_50_25.v')
import('common/reset_conditioner.v')
import('common/ps2.v')


algorithm multiplex_display(
    input   uint10 pix_x,
    input   uint10 pix_y,
    input   uint1  pix_active,
    input   uint1  pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,

    // TERMINAL
    input uint$color_depth$ terminal_r,
    input uint$color_depth$ terminal_g,
    input uint$color_depth$ terminal_b,
    input uint1   terminal_display
) <autorun> {
    // RGB is { 0, 0, 0 } by default
    pix_red   := 0;
    pix_green := 0;
    pix_blue  := 0;
        
    // Draw the screen
    while (1) {
        // wait until pix_active THEN BACKGROUND -> LOWER SPRITES -> BITMAP -> UPPER SPRITES -> CHARACTER MAP -> TERMINAL
        if( pix_active ) {
            // TERMINAL
            if( terminal_display ) {
                pix_red = terminal_r;
                pix_green = terminal_g;
                pix_blue = terminal_b;
            }        
        } // pix_active
    }
}

// Create 1hz (1 second counter)
algorithm pulse1hz(
    output uint16 counter1hz
) <autorun>
{
  uint32 counter50mhz = 0;
  counter1hz = 0;
  while (1) {
        if ( counter50mhz == 50000000 ) {
            counter1hz   = counter1hz + 1;
            counter50mhz = 0;
        } else {
            counter50mhz = counter50mhz + 1;
        }
    }
}

algorithm main(
    // LEDS (8 of)
    output  uint8   leds,
    
    // BUTTONS
    input   uint8   btns,
    
    output  uint4   gpdi_dp,
    output  uint4   gpdi_dn,

    // UART
    output! uint1   uart_tx,
    input   uint1   uart_rx,

    // US2 USB Port
    input   uint27   gp,
    input   uint27   gn,
    
    // VGA/HDMI
    output! uint$color_depth$ video_r,
    output! uint$color_depth$ video_g,
    output! uint$color_depth$ video_b,
    output! uint1   video_hs,
    output! uint1   video_vs
) <@clock_50mhz> {
    // CYCLE counter
    uint3 CYCLE = 0;
 
    // Setup the 1hz timer
    uint16 timer1hz = 0;
    pulse1hz p1hz( counter1hz :> timer1hz );

    // PS/2 Keyboard for the ULX3S
    uint1 ps2_clock := gp[1,1];
    uint1 ps2_data := gp[3,1];
    uint8 ps2_key = 0;
    uint1 ps2_strobe = 0;
    ps2kbd keyboard(
        clk <: clock,
        ps2_clk  <: ps2_clock,
        ps2_data <: ps2_data,
        ps2_code :> ps2_key,
        strobe   :> ps2_strobe
    );

    // VGA/HDMI Display
    uint1 video_reset = 0;
    uint1 video_clock = 0;
    uint1 pll_lock = 0;
    
    uint1 clock_50mhz = 0;
    ulx3s_clk_50_25 clk_gen(
        clkin    <: clock,
        clkout0  :> clock_50mhz,
        clkout1  :> video_clock,
        locked   :> pll_lock
    ); 

    // Video Reset
    reset_conditioner vga_rstcond (
        rcclk <: video_clock ,
        in  <: reset,
        out :> video_reset
    );

    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1  active = 0;
    uint1  vblank = 0;
    uint10 pix_x  = 0;
    uint10 pix_y  = 0;

    // VGA or HDMI driver
    uint8 video_r8 := video_r << 2;
    uint8 video_g8 := video_g << 2;
    uint8 video_b8 := video_b << 2;

    hdmi video<@clock,!reset>(
        x       :> pix_x,
        y       :> pix_y,
        active  :> active,
        vblank  :> vblank,
        gpdi_dp :> gpdi_dp,
        gpdi_dn :> gpdi_dn,
        red     <: video_r8,
        green   <: video_g8,
        blue    <: video_b8
    );
    
    // Terminal window at the bottom of the screen
    uint$color_depth$   terminal_r = 0;
    uint$color_depth$   terminal_g = 0;
    uint$color_depth$   terminal_b = 0;
    uint1               terminal_display = 0;
    
    terminal terminal_window <@video_clock,!video_reset>
    (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> terminal_r,
        pix_green  :> terminal_g,
        pix_blue   :> terminal_b,
        terminal_display :> terminal_display,
        timer1hz   <: timer1hz
    );
    
    multiplex_display display <@video_clock,!video_reset>
    (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> video_r,
        pix_green  :> video_g,
        pix_blue   :> video_b,

        terminal_r <: terminal_r,
        terminal_g <: terminal_g,
        terminal_b <: terminal_b,
        terminal_display <: terminal_display
    );
    
    // PS/2 input FIFO (16 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 ps2InBuffer[16] = uninitialized;
    uint4 ps2InBufferNext = 0;
    uint4 ps2InBufferTop = 0;
        ps2InBuffer.wenable0  := 0;  // always read  on port 0
        ps2InBuffer.wenable1  := 1;  // always write on port 1
        ps2InBuffer.addr0     := ps2InBufferNext; // FIFO reads on next
        ps2InBuffer.addr1     := ps2InBufferTop;  // FIFO writes on top

    // UART input and output buffering
    always {
        // READ from PS/2 if character available and store
        if( ps2_strobe ) {
            // writes at ps2InBufferTop (code from @sylefeb)
            ps2InBuffer.wdata1  = ps2_key;            
            ps2InBufferTop      = ps2InBufferTop + 1;
        }
    }
    
    // Setup the terminal
    terminal_window.showterminal = 1;
    terminal_window.showcursor = 1;

    // Echo PS/2 Input to terminal
    while( 1 ) {        
        switch( CYCLE ) {
            case 0: {
                if( ~( ps2InBufferNext == ps2InBufferTop ) ) {
                    terminal_window.terminal_character = ps2InBuffer.rdata0;
                    terminal_window.terminal_write = 1;
                }
            }
            
            case 2: {
                terminal_window.terminal_write = 0;
            }
            
            default: {}
        } // switch(CYCLE)
            
        CYCLE = ( CYCLE == 2 ) ? 0 : CYCLE + 1;
    }
}
