algorithm io_memmap(
    // LEDS (8 of)
    output  uint8   leds,

$$if not SIMULATION then
    input   uint$NUM_BTNS$ btns,

    // GPIO
    input   uint28  gn,
    output  uint28  gp,

    // UART
    output  uint1   uart_tx,
    input   uint1   uart_rx,

    // USB for PS/2
    input   uint1   us2_bd_dp,
    input   uint1   us2_bd_dn,

    // SDCARD
    output  uint1   sd_clk,
    output  uint1   sd_mosi,
    output  uint1   sd_csn,
    input   uint1   sd_miso,
$$end

    // CLOCKS
    input   uint1   clock_25mhz,

    // SDRAM ACCESS
    sdram_user      sio,

    // Memory access
    input   uint12  memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun> {
    uint24  sdramaddress = uninitialized;
    uint16  sdramwritedata = uninitialized;
    uint16  sdramreaddata = uninitialized;
    uint1   sdramwriteflag = uninitialized;
    uint1   sdramreadflag = uninitialized;
    // SDRAM and BRAM (for BIOS)
    // FUNCTION3 controls byte read/writes
    sdramcontroller sdram(
        sio <:> sio,
        address <: sdramaddress,
        writedata <: sdramwritedata,
        writeflag <: sdramwriteflag,
        readdata :> sdramreaddata,
        readflag <: sdramreadflag
    );

$$if not SIMULATION then
    // UART CONTROLLER, CONTAINS BUFFERS FOR INPUT/OUTPUT
    uint8   Uinchar = uninitialized;
    uint8   Uoutchar = uninitialized;
    uint1   UARTinavailable = uninitialized;
    uint1   UARTinread = uninitialized;
    uint1   UARToutfull = uninitialized;
    uint1   UARToutwrite = uninitialized;
    uart UART(
        uart_tx :> uart_tx,
        uart_rx <: uart_rx,
        inchar :> Uinchar,
        outchar <: Uoutchar,
        inavailable :> UARTinavailable,
        inread <: UARTinread,
        outfull :> UARToutfull,
        outwrite <: UARToutwrite
    );

    // PS2 CONTROLLER, CONTAINS BUFFERS FOR INPUT/OUTPUT
    uint8   Pinchar = uninitialized;
    uint1   PS2inavailable = uninitialized;
    uint1   PS2inread = uninitialized;
    ps2buffer PS2(
        clock_25mhz <: clock_25mhz,
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,
        inchar :> Pinchar,
        inavailable :> PS2inavailable,
        inread <: PS2inread
    );

    // SDCARD AND BUFFER
    uint16  sectoraddressH = uninitialized;
    uint16  sectoraddressL = uninitialized;
    uint9   bufferaddress = uninitialized;
    uint8   bufferdata = uninitialized;
    uint1   SDCARDready = uninitialized;
    uint1   SDCARDreadsector = uninitialized;
    sdcardbuffer SDCARD(
        sd_clk :> sd_clk,
        sd_mosi :> sd_mosi,
        sd_csn :> sd_csn,
        sd_miso <: sd_miso,
        sectoraddressH <: sectoraddressH,
        sectoraddressL <: sectoraddressL,
        bufferaddress <: bufferaddress,
        bufferdata :> bufferdata,
        readsector <: SDCARDreadsector,
        ready :> SDCARDready
    );

    // I/O FLAGS
    UARTinread := 0; UARToutwrite := 0; PS2inread := 0; SDCARDreadsector := 0;
$$end

    sdramwriteflag := 0; sdramreadflag := 0;

    always {
        // READ IO Memory
        switch( memoryRead ) {
            case 1: {
                switch( memoryAddress ) {
                    // UART, LEDS, BUTTONS and CLOCK
                    case 12h130: { readData = leds; }
                    $$if not SIMULATION then
                    case 12h100: {
                        switch( { PS2inavailable, UARTinavailable } ) {
                            case 2b00: { readData = 0; }
                            case 2b01: { readData = { 8b0, Uinchar }; UARTinread = 1; }
                            default: { readData = { 8b0, Pinchar }; PS2inread = 1; }
                        }
                    }
                    case 12h102: { readData = { 14b0, UARToutfull ? 1b1 : 1b0, ( UARTinavailable || PS2inavailable ) ? 1b1: 1b0 }; }
                    case 12h120: { readData = { $16-NUM_BTNS$b0, btns[0,$NUM_BTNS$] }; }

                    // SDCARD
                    case 12h140: { readData = SDCARDready; }
                    case 12h150: { readData = bufferdata; }
                    $$end
                    // SDRAM
                    case 12hf00: { readData = sdramreaddata; }
                    case 12hf02: { readData = sdram.busy; }

                    // RETURN NULL VALUE
                    default: { readData = 0; }
                }
            }
            default: {}
        }

        // WRITE IO Memory
        switch( memoryWrite ) {
            case 1: {
                switch( memoryAddress ) {
                    // UART, LEDS
                    case 12h130: { leds = writeData; }
                    $$if not SIMULATION then
                    case 12h100: { Uoutchar = writeData[0,8]; UARToutwrite = 1; }

                    // SDCARD
                    case 12h140: { SDCARDreadsector = 1; }
                    case 12h142: { sectoraddressH = writeData; }
                    case 12h144: { sectoraddressL = writeData; }
                    case 12h150: { bufferaddress = writeData; }
                    $$end
                    // SDRAM
                    case 12hf00: { sdramwritedata = writeData; }
                    case 12hf02: {
                        switch( writeData ) {
                            case 1: { sdramreadflag = 1; }
                            case 2: { sdramwriteflag = 1; }
                            default: {}
                        }
                    }
                    case 12hf04: { sdramaddress[16,8] = writeData; }
                    case 12hf05: { sdramaddress[0,16] = writeData; }
                    default: {}
                }
            }
            default: {}
        }
    }
}

algorithm copro_memmap(
    // Memory access
    input   uint12  memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,

    input   uint16  writeData,
    output  uint16  readData
) <autorun> {
    // Mathematics Co-Processors
    divmod32by16 divmod32by16to16qr();
    divmod16by16 divmod16by16to16qr();
    multi16by16to32DSP multiplier16by16to32();

    int32   doperand1 = uninitialized;
    int32   doperand2 = uninitialized;
    int32   dtotal = uninitialized;
    int32   ddifference = uninitialized;
    int32   dincrement = uninitialized;
    int32   ddecrememt = uninitialized;
    int32   dtimes2 = uninitialized;
    int32   ddivide2 = uninitialized;
    int32   dnegation = uninitialized;
    int32   dinvert = uninitialized;
    int32   dxor = uninitialized;
    int32   dand = uninitialized;
    int32   dor = uninitialized;
    int32   dabsolute = uninitialized;
    int32   dmaximum = uninitialized;
    int32   dminimum = uninitialized;
    int16   dzeroequal = uninitialized;
    int16   dzeroless = uninitialized;
    int16   dequal = uninitialized;
    int16   dlessthan = uninitialized;
    doubleops doperations(
        operand1 <: doperand1,
        operand2 <: doperand2,
        total :> dtotal,
        difference :> ddifference,
        increment :> dincrement,
        decrement :> ddecrememt,
        times2 :> dtimes2,
        divide2 :> ddivide2,
        negation :> dnegation,
        binaryinvert :> dinvert,
        binaryxor :> dxor,
        binaryand :> dand,
        binaryor :> dor,
        absolute :> dabsolute,
        maximum :> dmaximum,
        minimum :> dminimum,
        zeroequal :> dzeroequal,
        zeroless :> dzeroless,
        equal :> dequal,
        lessthan :> dlessthan
    );

    uint16  fpua = uninitialized;
    uint16  fpub = uninitialized;
    uint3   fpustart = uninitialized;
    uint1   fpubusy = uninitialized;
    floatops fpu(
        a <: fpua,
        b <: fpub,
        start <: fpustart,
        busy :> fpubusy
    );

    // RESET Mathematics Co-Processor Controls
    divmod32by16to16qr.start := 0;
    divmod16by16to16qr.start := 0;
    multiplier16by16to32.start := 0;
    fpustart := 0;

    always {
        // READ IO Memory
        switch( memoryRead ) {
            case 1: {
                switch( memoryAddress ) {
                    case 12h000: { readData = words(dtotal).hword; }
                    case 12h001: { readData = words(dtotal).lword; }
                    case 12h002: { readData = words(ddifference).hword; }
                    case 12h003: { readData = words(ddifference).lword; }
                    case 12h004: { readData = words(dincrement).hword; }
                    case 12h005: { readData = words(dincrement).lword; }
                    case 12h006: { readData = words(ddecrememt).hword; }
                    case 12h007: { readData = words(ddecrememt).lword; }
                    case 12h008: { readData = words(dtimes2).hword; }
                    case 12h009: { readData = words(dtimes2).lword; }
                    case 12h00a: { readData = words(ddivide2).hword; }
                    case 12h00b: { readData = words(ddivide2).lword; }
                    case 12h00c: { readData = words(dnegation).hword; }
                    case 12h00d: { readData = words(dnegation).lword; }
                    case 12h00e: { readData = words(dinvert).hword; }
                    case 12h00f: { readData = words(dinvert).lword; }
                    case 12h010: { readData = words(dxor).hword; }
                    case 12h011: { readData = words(dxor).lword; }
                    case 12h012: { readData = words(dand).hword; }
                    case 12h013: { readData = words(dand).lword; }
                    case 12h014: { readData = words(dor).hword; }
                    case 12h015: { readData = words(dor).lword; }
                    case 12h016: { readData = words(dabsolute).hword; }
                    case 12h017: { readData = words(dabsolute).lword; }
                    case 12h018: { readData = words(dmaximum).hword; }
                    case 12h019: { readData = words(dmaximum).lword; }
                    case 12h01a: { readData = words(dminimum).hword; }
                    case 12h01b: { readData = words(dminimum).lword; }
                    case 12h01c: { readData = dzeroequal; }
                    case 12h01d: { readData = dzeroless; }
                    case 12h01e: { readData = dequal; }
                    case 12h01f: { readData = dlessthan; }
                    case 12h020: { readData = divmod32by16to16qr.quotient[0,16]; }
                    case 12h021: { readData = divmod32by16to16qr.remainder[0,16]; }
                    case 12h023: { readData = divmod32by16to16qr.active; }
                    case 12h024: { readData = divmod16by16to16qr.quotient; }
                    case 12h025: { readData = divmod16by16to16qr.remainder; }
                    case 12h026: { readData = divmod16by16to16qr.active; }
                    case 12h027: { readData = multiplier16by16to32.product[16,16]; }
                    case 12h028: { readData = multiplier16by16to32.product[0,16]; }

                    case 12h102: { readData = fpubusy; }
                    case 12h110: { readData = fpu.itof; }
                    case 12h111: { readData = fpu.ftoi; }
                    case 12h112: { readData = fpu.fadd; }
                    case 12h113: { readData = fpu.fsub; }
                    case 12h114: { readData = fpu.fmul; }
                    case 12h115: { readData = fpu.fdiv; }
                    case 12h116: { readData = fpu.fsqrt; }
                    case 12h117: { readData = fpu.less; }
                    case 12h118: { readData = fpu.equal; }
                    case 12h119: { readData = fpu.lessequal; }

                    // RETURN NULL VALUE
                    default: { readData = 0; }
                }
            }
            default: {}
        }

        // WRITE IO Memory
        switch( memoryWrite ) {
            case 1: {
                switch( memoryAddress ) {
                    case 12h000: { doperand1[16,16] = writeData; }
                    case 12h001: { doperand1[0,16] = writeData; }
                    case 12h002: { doperand2[16,16] = writeData; }
                    case 12h003: { doperand2[0,16] = writeData; }
                    case 12h020: { divmod32by16to16qr.dividendh = writeData; }
                    case 12h021: { divmod32by16to16qr.dividendl = writeData; }
                    case 12h022: { divmod32by16to16qr.divisor = writeData; }
                    case 12h023: { divmod32by16to16qr.start = writeData; }
                    case 12h024: { divmod16by16to16qr.dividend = writeData; }
                    case 12h025: { divmod16by16to16qr.divisor = writeData; }
                    case 12h026: { divmod16by16to16qr.start = writeData; }
                    case 12h027: { multiplier16by16to32.factor1 = writeData; }
                    case 12h028: { multiplier16by16to32.factor2 = writeData; }
                    case 12h029: { multiplier16by16to32.start = writeData; }

                    case 12h100: { fpua = writeData; }
                    case 12h101: { fpub = writeData; }
                    case 12h102: { fpustart = writeData; }

                    default: {}
                }
            }
            default: {}
        }
    } // while(1)
}

algorithm audiotimers_memmap(
    // CLOCKS
    input   uint1   clock_25mhz,

    // Memory access
    input   uint12  memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,
    input   uint16  writeData,
    output  uint16  readData,

    // AUDIO
    output  uint4   audio_l,
    output  uint4   audio_r
) <autorun> {
    // TIMERS and RNG
    uint16  systemclock = uninitialized;
    uint16  timer1hz0 = uninitialized;
    uint16  timer1hz1 = uninitialized;
    uint16  timer1khz0 = uninitialized;
    uint16  timer1khz1 = uninitialized;
    uint16  sleepTimer0 = uninitialized;
    uint16  sleepTimer1 = uninitialized;
    uint16  u_noise_out = uninitialized;
    uint16  g_noise_out = uninitialized;
    uint4   static4bit <: u_noise_out[0,4];
    uint16  counter = uninitialized;
    uint3   resetcounter = uninitialized;
    timers_rng timers <@clock_25mhz> (
        systemclock :> systemclock,
        timer1hz0 :> timer1hz0,
        timer1hz1 :> timer1hz1,
        timer1khz0 :> timer1khz0,
        timer1khz1 :> timer1khz1,
        sleepTimer0 :> sleepTimer0,
        sleepTimer1 :> sleepTimer1,
        u_noise_out :> u_noise_out,
        g_noise_out :> g_noise_out,
        counter <: counter,
        resetcounter <: resetcounter
    );

    // Left and Right audio channels
    uint1   audio_active_l = uninitialized;
    uint1   audio_active_r = uninitialized;
    uint4   waveform = uninitialized;
    uint7   note = uninitialized;
    uint16  duration = uninitialized;
    uint2   apu_write = uninitialized;
    audio apu_processor <@clock_25mhz> (
        staticGenerator <: static4bit,
        audio_l :> audio_l,
        audio_active_l :> audio_active_l,
        audio_r :> audio_r,
        audio_active_r :> audio_active_r,
        waveform <: waveform,
        note <: note,
        duration <: duration,
        apu_write <: apu_write
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        // READ IO Memory
        switch( memoryRead ) {
            case 1: {
                switch( memoryAddress ) {
                    // TIMERS and RNG
                    case 12h000: { readData = g_noise_out; }
                    case 12h002: { readData = u_noise_out; }
                    case 12h010: { readData = timer1hz0; }
                    case 12h012: { readData = timer1hz1; }
                    case 12h020: { readData = timer1khz0; }
                    case 12h022: { readData = timer1khz1; }
                    case 12h030: { readData = sleepTimer0; }
                    case 12h032: { readData = sleepTimer1; }
                    case 12h040: { readData = systemclock; }

                    // AUDIO
                    case 12h110: { readData = audio_active_l; }
                    case 12h112: { readData = audio_active_r; }

                    // RETURN NULL VALUE
                    default: { readData = 0; }
                }
            }
            default: {}
        }
        // WRITE IO Memory
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress ) {
                // TIMERS and RNG
                    case 12h010: { resetcounter = 1; }
                    case 12h012: { resetcounter = 2; }
                    case 12h020: { counter = writeData; resetcounter = 3; }
                    case 12h022: { counter = writeData; resetcounter = 4; }
                    case 12h030: { counter = writeData; resetcounter = 5; }
                    case 12h032: { counter = writeData; resetcounter = 6; }

                    // AUDIO
                    case 12h100: { waveform = writeData; }
                    case 12h102: { note = writeData; }
                    case 12h104: { duration = writeData; }
                    case 12h106: { apu_write = writeData; }
                    default: {}
                }
            }
            case 2b00: {
                // RESET TIMER and AUDIO Co-Processor Controls
                resetcounter = 0;
                apu_write = 0;
            }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }
}

algorithm passthrough(input uint1 i,output! uint1 o)
{
  always { o=i; }
}

algorithm video_memmap(
    // CLOCKS
    input   uint1   clock_25mhz,

    // Memory access
    input   uint12  memoryAddress,
    input   uint1   memoryWrite,
    input   uint1   memoryRead,
    input   uint16  writeData,
    output  uint16  readData,
$$if HDMI then
    // HDMI OUTPUT
    output! uint4   gpdi_dp
$$end
$$if VGA then
    // VGA OUTPUT
    output! uint$color_depth$ video_r,
    output! uint$color_depth$ video_g,
    output! uint$color_depth$ video_b,
    output  uint1 video_hs,
    output  uint1 video_vs,
$$end
) <autorun> {
    // VIDEO + CLOCKS
    uint1   pll_lock_VIDEO = uninitialized;
    uint1   video_clock = uninitialized;
    uint1   gpu_clock = uninitialized;
$$if not SIMULATION then
    ulx3s_clk_risc_ice_v_VIDEO clk_gen_VIDEO (
        clkin    <: clock_25mhz,
        clkGPU :> gpu_clock,
        clkVIDEO :> video_clock,
        locked   :> pll_lock_VIDEO
    );
$$else
    passthrough p1(i<:clock_25mhz,o:>gpu_clock);
    passthrough p2(i<:clock_25mhz,o:>video_clock);
$$end
    // Video Reset
    uint1   video_reset = uninitialized;
    clean_reset video_rstcond<@video_clock,!reset> ( out :> video_reset );

    // RNG random number generator
    uint1   static1bit <: rng.u_noise_out[0,1];
    uint2   static2bit <: rng.u_noise_out[0,2];
    uint6   static6bit <: rng.u_noise_out[0,6];
    random rng <@clock_25mhz> ();

    // HDMI driver
    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1   vblank = uninitialized;
    uint1   pix_active = uninitialized;
    uint10  pix_x  = uninitialized;
    uint10  pix_y  = uninitialized;
$$if VGA then
  vga vga_driver<@clock_25mhz,!reset>(
    vga_hs :> video_hs,
    vga_vs :> video_vs,
    vga_x  :> pix_x,
    vga_y  :> pix_y,
    vblank :> vblank,
    active :> pix_active,
  );
$$end
$$if HDMI then
    uint8   video_r = uninitialized;
    uint8   video_g = uninitialized;
    uint8   video_b = uninitialized;
    hdmi video<@clock_25mhz,!reset> (
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
    // CREATE DISPLAY LAYERS
    // BACKGROUND
    uint6   background_p = uninitialized;
    background background_generator <@video_clock,!video_reset>  (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> background_p,
        staticGenerator <: static2bit
    );

    // Tilemaps - Lower and Upper
    uint6   lower_tilemap_p = uninitialized;
    uint1   lower_tilemap_display = uninitialized;
    uint6   upper_tilemap_p = uninitialized;
    uint1   upper_tilemap_display = uninitialized;
    tilemap lower_tile_map <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> lower_tilemap_p,
        tilemap_display :> lower_tilemap_display
    );
    tilemap upper_tile_map <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> upper_tilemap_p,
        tilemap_display :> upper_tilemap_display
    );

    // Bitmap Window with GPU
    uint1   bitmap_display = uninitialized;
    uint6   bitmap_p = uninitialized;
    // 640 x 480 x 7 bit { Arrggbb } colour bitmap
    bitmap bitmap_window <@video_clock,!video_reset> (
        gpu_clock <: gpu_clock,
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> bitmap_p,
        bitmap_display :> bitmap_display,
        static1bit <: static1bit,
        static6bit <: static6bit
   );

    // Sprite Layers - Lower and Upper
    uint6   lower_sprites_p = uninitialized;
    uint1   lower_sprites_display = uninitialized;
    uint6   upper_sprites_p = uninitialized;
    uint1   upper_sprites_display = uninitialized;
    sprite_layer lower_sprites <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> lower_sprites_p,
        sprite_layer_display :> lower_sprites_display,
        collision_layer_1 <: bitmap_display,
        collision_layer_2 <: lower_tilemap_display,
        collision_layer_3 <: upper_tilemap_display,
        collision_layer_4 <: upper_sprites_display
    );
    sprite_layer upper_sprites <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> upper_sprites_p,
        sprite_layer_display :> upper_sprites_display,
        collision_layer_1 <: bitmap_display,
        collision_layer_2 <: lower_tilemap_display,
        collision_layer_3 <: upper_tilemap_display,
        collision_layer_4 <: lower_sprites_display
    );

    // Character Map Window
    uint6   character_map_p = uninitialized;
    uint1   character_map_display = uninitialized;
    character_map character_map_window <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> character_map_p,
        character_map_display :> character_map_display
    );

    // Terminal Window
    uint6   terminal_p = uninitialized;
    uint1   terminal_display = uninitialized;
    terminal terminal_window <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pixel    :> terminal_p,
        terminal_display :> terminal_display
    );

    // Combine the display layers for display

    multiplex_display display <@video_clock,!video_reset> (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: pix_active,
        pix_vblank <: vblank,
        pix_red    :> video_r,
        pix_green  :> video_g,
        pix_blue   :> video_b,

        background_p <: background_p,

        lower_tilemap_p <: lower_tilemap_p,
        lower_tilemap_display <: lower_tilemap_display,

        upper_tilemap_p <: upper_tilemap_p,
        upper_tilemap_display <: upper_tilemap_display,

        lower_sprites_p <: lower_sprites_p,
        lower_sprites_display <: lower_sprites_display,

        upper_sprites_p <: upper_sprites_p,
        upper_sprites_display <: upper_sprites_display,

        bitmap_p <: bitmap_p,
        bitmap_display <: bitmap_display,

        character_map_p <: character_map_p,
        character_map_display <: character_map_display,

        terminal_p <: terminal_p,
        terminal_display <: terminal_display
    );

    // LATCH MEMORYWRITE
    uint1   LATCHmemoryWrite = uninitialized;

    always {
        // READ IO Memory
        switch( memoryRead ) {
            case 1: {
                switch( memoryAddress ) {
                    // TILE MAP
                    case 12h120: { readData = lower_tile_map.tm_lastaction; }
                    case 12h122: { readData = lower_tile_map.tm_active; }
                    case 12h220: { readData = upper_tile_map.tm_lastaction; }
                    case 12h222: { readData = upper_tile_map.tm_active; }

                    // LOWER SPRITE LAYER
                    $$for i=0,15 do
                        case $0x300 + i*2$: { readData = lower_sprites.sprite_read_active_$i$; }
                        case $0x320 + i*2$: { readData = lower_sprites.sprite_read_double_$i$; }
                        case $0x340 + i*2$: { readData = lower_sprites.sprite_read_colour_$i$; }
                        case $0x360 + i*2$: { readData = {{5{lower_sprites.sprite_read_x_$i$[10,1]}}, lower_sprites.sprite_read_x_$i$}; }
                        case $0x380 + i*2$: { readData = {{5{lower_sprites.sprite_read_y_$i$[10,1]}}, lower_sprites.sprite_read_y_$i$}; }
                        case $0x3a0 + i*2$: { readData = lower_sprites.sprite_read_tile_$i$; }
                        case $0x3c0 + i*2$: { readData = lower_sprites.collision_$i$; }
                        case $0x3e0 + i*2$: { readData = lower_sprites.layer_collision_$i$; }
                    $$end

                    // UPPER SPRITE LAYER
                    $$for i=0,15 do
                        case $0x400 + i*2$: { readData = upper_sprites.sprite_read_active_$i$; }
                        case $0x420 + i*2$: { readData = upper_sprites.sprite_read_double_$i$; }
                        case $0x440 + i*2$: { readData = upper_sprites.sprite_read_colour_$i$; }
                        case $0x460 + i*2$: { readData = {{5{upper_sprites.sprite_read_x_$i$[10,1]}}, upper_sprites.sprite_read_x_$i$}; }
                        case $0x480 + i*2$: { readData = {{5{upper_sprites.sprite_read_y_$i$[10,1]}}, upper_sprites.sprite_read_y_$i$}; }
                        case $0x4a0 + i*2$: { readData = upper_sprites.sprite_read_tile_$i$; }
                        case $0x4c0 + i*2$: { readData = upper_sprites.collision_$i$; }
                        case $0x4e0 + i*2$: { readData = upper_sprites.layer_collision_$i$; }
                    $$end

                    // CHARACTER MAP
                    case 12h504: { readData = character_map_window.curses_character; }
                    case 12h506: { readData = character_map_window.curses_background; }
                    case 12h508: { readData = character_map_window.curses_foreground; }
                    case 12h50a: { readData = character_map_window.tpu_active; }

                    // GPU and BITMAP
                    case 12h612: { readData = bitmap_window.gpu_queue_full; }
                    case 12h614: { readData = bitmap_window.gpu_queue_complete; }
                    case 12h62a: { readData = bitmap_window.vector_block_active; }
                    case 12h6d4: { readData = bitmap_window.bitmap_colour_read; }

                    // TERMINAL
                    case 12h700: { readData = terminal_window.terminal_active; }

                    // VBLANK
                    case 12hf00: { readData = vblank; }

                    default: { readData = 0; }
                }
            }
            default: {}
        }

        // WRITE IO Memory
        switch( { memoryWrite, LATCHmemoryWrite } ) {
            case 2b10: {
                switch( memoryAddress ) {
                    // BACKGROUND
                    case 12h000: { background_generator.backgroundcolour = writeData; background_generator.background_update = 1; }
                    case 12h002: { background_generator.backgroundcolour_alt = writeData; background_generator.background_update = 2; }
                    case 12h004: { background_generator.backgroundcolour_mode = writeData; background_generator.background_update = 3; }
                    case 12h010: { background_generator.copper_program = writeData; }
                    case 12h012: { background_generator.copper_status = writeData; }
                    case 12h020: { background_generator.copper_address = writeData; }
                    case 12h022: { background_generator.copper_command = writeData; }
                    case 12h024: { background_generator.copper_condition = writeData; }
                    case 12h026: { background_generator.copper_coordinate = writeData; }
                    case 12h028: { background_generator.copper_mode = writeData; }
                    case 12h02a: { background_generator.copper_alt = writeData; }
                    case 12h02c: { background_generator.copper_colour = writeData; }

                    // TILE MAP
                    case 12h100: { lower_tile_map.tm_x = writeData; }
                    case 12h102: { lower_tile_map.tm_y = writeData; }
                    case 12h104: { lower_tile_map.tm_character = writeData; }
                    case 12h106: { lower_tile_map.tm_background = writeData; }
                    case 12h108: { lower_tile_map.tm_foreground = writeData; }
                    case 12h10a: { lower_tile_map.tm_write = 1; }
                    case 12h110: { lower_tile_map.tile_writer_tile = writeData; }
                    case 12h112: { lower_tile_map.tile_writer_line = writeData; }
                    case 12h114: { lower_tile_map.tile_writer_bitmap = writeData; }
                    case 12h120: { lower_tile_map.tm_scrollwrap = writeData; }

                    case 12h200: { upper_tile_map.tm_x = writeData; }
                    case 12h202: { upper_tile_map.tm_y = writeData; }
                    case 12h204: { upper_tile_map.tm_character = writeData; }
                    case 12h206: { upper_tile_map.tm_background = writeData; }
                    case 12h208: { upper_tile_map.tm_foreground = writeData; }
                    case 12h20a: { upper_tile_map.tm_write = 1; }
                    case 12h210: { upper_tile_map.tile_writer_tile = writeData; }
                    case 12h212: { upper_tile_map.tile_writer_line = writeData; }
                    case 12h214: { upper_tile_map.tile_writer_bitmap = writeData; }
                    case 12h220: { upper_tile_map.tm_scrollwrap = writeData; }

                    // LOWER SPRITE LAYER
                    $$for i=0,15 do
                        case $0x300 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_set_active = writeData; lower_sprites.sprite_layer_write = 1; }
                        case $0x320 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_set_double = writeData; lower_sprites.sprite_layer_write = 2; }
                        case $0x340 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_set_colour = writeData; lower_sprites.sprite_layer_write = 3; }
                        case $0x360 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_set_x = writeData; lower_sprites.sprite_layer_write = 4; }
                        case $0x380 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_set_y = writeData; lower_sprites.sprite_layer_write = 5; }
                        case $0x3a0 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_set_tile = writeData; lower_sprites.sprite_layer_write = 6; }
                        case $0x3c0 + i*2$: { lower_sprites.sprite_set_number = $i$; lower_sprites.sprite_update = writeData; lower_sprites.sprite_layer_write = 7; }
                    $$end

                    // UPPER SPRITE LAYER
                    $$for i=0,15 do
                        case $0x400 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_set_active = writeData; upper_sprites.sprite_layer_write = 1; }
                        case $0x420 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_set_double = writeData; upper_sprites.sprite_layer_write = 2; }
                        case $0x440 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_set_colour = writeData; upper_sprites.sprite_layer_write = 3;  }
                        case $0x460 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_set_x = writeData; upper_sprites.sprite_layer_write = 4; }
                        case $0x480 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_set_y = writeData; upper_sprites.sprite_layer_write = 5; }
                        case $0x4a0 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_set_tile = writeData; upper_sprites.sprite_layer_write = 6; }
                        case $0x4c0 + i*2$: { upper_sprites.sprite_set_number = $i$; upper_sprites.sprite_update = writeData; upper_sprites.sprite_layer_write = 7; }
                    $$end

                    // LOWER SPRITE LAYER BITMAP WRITER
                    case 12h800: { lower_sprites.sprite_writer_sprite = writeData; }
                    case 12h802: { lower_sprites.sprite_writer_line = writeData; }
                    case 12h804: { lower_sprites.sprite_writer_bitmap = writeData; lower_sprites.sprite_writer_active = 1; }

                    // UPPER SPRITE LAYER BITMAP WRITER
                    case 12h900: { upper_sprites.sprite_writer_sprite = writeData; }
                    case 12h902: { upper_sprites.sprite_writer_line = writeData; }
                    case 12h904: { upper_sprites.sprite_writer_bitmap = writeData; upper_sprites.sprite_writer_active = 1; }

                    // CHARACTER MAP
                    case 12h500: { character_map_window.tpu_x = writeData; }
                    case 12h502: { character_map_window.tpu_y = writeData; }
                    case 12h504: { character_map_window.tpu_character = writeData; }
                    case 12h506: { character_map_window.tpu_background = writeData; }
                    case 12h508: { character_map_window.tpu_foreground = writeData; }
                    case 12h50a: { character_map_window.tpu_write = writeData; }

                    // GPU and BITMAP
                    case 12h600: { bitmap_window.gpu_x = writeData; }
                    case 12h602: { bitmap_window.gpu_y = writeData; }
                    case 12h604: { bitmap_window.gpu_colour = writeData; }
                    case 12h606: { bitmap_window.gpu_colour_alt = writeData; }
                    case 12h608: { bitmap_window.gpu_dithermode = writeData; }
                    case 12h60a: { bitmap_window.gpu_param0 = writeData; }
                    case 12h60c: { bitmap_window.gpu_param1 = writeData; }
                    case 12h60e: { bitmap_window.gpu_param2 = writeData; }
                    case 12h610: { bitmap_window.gpu_param3 = writeData; }
                    case 12h612: { bitmap_window.gpu_write = writeData; }

                    case 12h620: { bitmap_window.vector_block_number = writeData; }
                    case 12h622: { bitmap_window.vector_block_colour = writeData; }
                    case 12h624: { bitmap_window.vector_block_xc = writeData; }
                    case 12h626: { bitmap_window.vector_block_yc = writeData; }
                    case 12h628: { bitmap_window.vector_block_scale = writeData; }
                    case 12h62a: { bitmap_window.draw_vector = 1; }

                    case 12h630: { bitmap_window.vertices_writer_block = writeData; }
                    case 12h632: { bitmap_window.vertices_writer_vertex = writeData; }
                    case 12h634: { bitmap_window.vertices_writer_xdelta = writeData; }
                    case 12h636: { bitmap_window.vertices_writer_ydelta = writeData; }
                    case 12h638: { bitmap_window.vertices_writer_active = writeData; }

                    case 12h640: { bitmap_window.blit1_writer_tile = writeData; }
                    case 12h642: { bitmap_window.blit1_writer_line = writeData; }
                    case 12h644: { bitmap_window.blit1_writer_bitmap = writeData; }

                    case 12h650: { bitmap_window.character_writer_character = writeData; }
                    case 12h652: { bitmap_window.character_writer_line = writeData; }
                    case 12h654: { bitmap_window.character_writer_bitmap = writeData; }

                    case 12h660: { bitmap_window.colourblit_writer_tile = writeData; }
                    case 12h662: { bitmap_window.colourblit_writer_line = writeData; }
                    case 12h664: { bitmap_window.colourblit_writer_pixel = writeData; }
                    case 12h666: { bitmap_window.colourblit_writer_colour = writeData; }

                    case 12h670: { bitmap_window.pb_colour7 = writeData; bitmap_window.pb_newpixel = 1; }
                    case 12h672: { bitmap_window.pb_colour8r = writeData; }
                    case 12h674: { bitmap_window.pb_colour8g = writeData; }
                    case 12h676: { bitmap_window.pb_colour8b = writeData; bitmap_window.pb_newpixel = 2; }
                    case 12h678: { bitmap_window.pb_newpixel = 3; }

                    case 12h6d0: { bitmap_window.bitmap_x_read = writeData; }
                    case 12h6d2: { bitmap_window.bitmap_y_read = writeData; }

                    case 12h6e0: { bitmap_window.bitmap_write_offset = writeData; }
                    case 12h6f0: { bitmap_window.framebuffer = writeData; }
                    case 12h6f2: { bitmap_window.writer_framebuffer = writeData; }

                    case 12h700: { terminal_window.terminal_character = writeData; terminal_window.terminal_write = 1; }
                    case 12h702: { terminal_window.showterminal = writeData; }

                    // DISPLAY LAYER ORDERING / FRAMEBUFFER SELECTION
                    case 12hf00: { display.display_order = writeData; }

                    default: {}
                }
            }
            case 2b00: {
                // RESET DISPLAY Co-Processor Controls
                background_generator.background_update = 0;
                background_generator.copper_program = 0;
                lower_tile_map.tm_write = 0;
                lower_tile_map.tm_scrollwrap = 0;
                upper_tile_map.tm_write = 0;
                upper_tile_map.tm_scrollwrap = 0;
                lower_sprites.sprite_layer_write = 0;
                lower_sprites.sprite_writer_active = 0;
                upper_sprites.sprite_layer_write = 0;
                upper_sprites.sprite_writer_active = 0;
                bitmap_window.bitmap_write_offset = 0;
                bitmap_window.gpu_write = 0;
                bitmap_window.pb_newpixel = 0;
                bitmap_window.draw_vector = 0;
                character_map_window.tpu_write = 0;
                terminal_window.terminal_write = 0;
            }
            default: {}
        }
        LATCHmemoryWrite = memoryWrite;
    }

    // DISPLAY TERMINAL WINDOW
    terminal_window.showterminal = 1;
}

// TIMERS and RNG Controllers
algorithm timers_rng(
    output  uint16  systemclock,
    output  uint16  timer1hz0,
    output  uint16  timer1hz1,
    output  uint16  timer1khz0,
    output  uint16  timer1khz1,
    output  uint16  sleepTimer0,
    output  uint16  sleepTimer1,
    output  uint16  u_noise_out,
    output  uint16  g_noise_out,
    input   uint16  counter,
    input   uint3   resetcounter
) <autorun> {
    // RNG random number generator
    random rng( u_noise_out :> u_noise_out,  g_noise_out :> g_noise_out );

    // 1hz timers (p1hz used for systemClock, timer1hz for user purposes)
    uint1   P1resetCounter = uninitialized;
    pulse1hz P1( counter1hz :> systemclock, resetCounter <: P1resetCounter );

    uint1   T1hz0resetCounter = uninitialized;
    uint1   T1hz1resetCounter = uninitialized;
    pulse1hz T1hz0( counter1hz :> timer1hz0, resetCounter <: T1hz0resetCounter );
    pulse1hz T1hz1( counter1hz :> timer1hz1, resetCounter <: T1hz1resetCounter );

    // 1khz timers (sleepTimers used for sleep command, timer1khzs for user purposes)
    uint16  T0khz0resetCounter = uninitialized;
    uint16  T1khz1resetCounter = uninitialized;
    uint16  STimer0resetCounter = uninitialized;
    uint16  STimer1resetCounter = uninitialized;
    pulse1khz T0khz0( counter1khz :> timer1khz0, resetCounter <: T0khz0resetCounter );
    pulse1khz T1khz1( counter1khz :> timer1khz1, resetCounter <: T1khz1resetCounter );
    pulse1khz STimer0( counter1khz :> sleepTimer0, resetCounter <: STimer0resetCounter );
    pulse1khz STimer1( counter1khz :> sleepTimer1, resetCounter <: STimer1resetCounter );

    P1resetCounter := 0;
    T1hz0resetCounter := 0;
    T1hz1resetCounter := 0;
    T0khz0resetCounter := 0;
    T1khz1resetCounter := 0;
    STimer0resetCounter := 0;
    STimer1resetCounter := 0;

    always {
        switch( resetcounter ) {
        default: {}
            case 1: { T1hz0resetCounter = 1; }
            case 2: { T1hz1resetCounter = 1; }
            case 3: { T0khz0resetCounter = counter; }
            case 4: { T1khz1resetCounter = counter; }
            case 5: { STimer0resetCounter = counter; }
            case 6: { STimer1resetCounter = counter; }
        }
    }
}

// AUDIO L&R Controller
algorithm audio(
    input   uint4   staticGenerator,
    input   uint4   waveform,
    input   uint7   note,
    input   uint16  duration,
    input   uint2   apu_write,
    output  uint4   audio_l,
    output  uint1   audio_active_l,
    output  uint4   audio_r,
    output  uint1   audio_active_r
) <autorun> {
    // Left and Right audio channels
    uint4   Lwaveform = uninitialized;
    uint7   Lnote = uninitialized;
    uint16  Lduration = uninitialized;
    uint1   Lapu_write = uninitialized;
    apu apu_processor_L(
        staticGenerator <: staticGenerator,
        audio_output :> audio_l,
        audio_active :> audio_active_l,
        waveform <: Lwaveform,
        note <: Lnote,
        duration <: Lduration,
        apu_write <: Lapu_write
    );
    uint4   Rwaveform = uninitialized;
    uint7   Rnote = uninitialized;
    uint16  Rduration = uninitialized;
    uint1   Rapu_write = uninitialized;
    apu apu_processor_R(
        staticGenerator <: staticGenerator,
        audio_output :> audio_r,
        audio_active :> audio_active_r,
        waveform <: Rwaveform,
        note <: Rnote,
        duration <: Rduration,
        apu_write <: Rapu_write
    );

    Lapu_write := 0; Rapu_write := 0;

    always {
        switch( apu_write ) {
            default: {}
            case 1: {
                Lwaveform = waveform;
                Lnote = note;
                Lduration = duration;
                Lapu_write = 1;
            }
            case 2: {
                Rwaveform = waveform;
                Rnote = note;
                Rduration = duration;
                Rapu_write = 1;
            }
            case 3: {
                Lwaveform = waveform;
                Lnote = note;
                Lduration = duration;
                Lapu_write = 1;
                Rwaveform = waveform;
                Rnote = note;
                Rduration = duration;
                Rapu_write = 1;
            }
        }
    }
}

// UART BUFFER CONTROLLER
algorithm uart(
    // UART
    output  uint1   uart_tx,
    input   uint1   uart_rx,

    output  uint1   inavailable,
    output  uint1   outfull,

    output  uint8   inchar,
    input   uint1   inread,
    input   uint8   outchar,
    input   uint1   outwrite
) <autorun> {
    uint1   update = uninitialized;

    // UART tx and rx
    // UART written in Silice by https://github.com/sylefeb/Silice
    uart_out uo;
    uart_sender usend(
        io      <:> uo,
        uart_tx :>  uart_tx
    );
    uart_in ui;
    uart_receiver urecv(
        io      <:> ui,
        uart_rx <:  uart_rx
    );

    // UART input FIFO (4096 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartInBuffer <input!> [4096] = uninitialized;
    uint13  uartInBufferNext = 0;
    uint13  uartInBufferTop = 0;

    // UART output FIFO (4096 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartOutBuffer <input!> [4096] = uninitialized;
    uint13   uartOutBufferNext = 0;
    uint13   uartOutBufferTop = 0;
    uint13   newuartOutBufferTop = 0;

    // FLAGS
    inavailable := ( uartInBufferNext != uartInBufferTop );
    outfull := ( uartOutBufferTop + 1 == uartOutBufferNext );
    inchar := uartInBuffer.rdata0;

    // UART Buffers ( code from @sylefeb )
    uartInBuffer.wenable1 := 1;  // always write on port 1
    uartInBuffer.addr0 := uartInBufferNext; // FIFO reads on next
    uartInBuffer.addr1 := uartInBufferTop;  // FIFO writes on top
    uartOutBuffer.wenable1 := 1; // always write on port 1
    uartOutBuffer.addr0 := uartOutBufferNext; // FIFO reads on next
    uartInBuffer.wdata1 := ui.data_out;
    uartInBufferTop := uartInBufferTop + ui.data_out_ready;
    uo.data_in := uartOutBuffer.rdata0;
    uo.data_in_ready := ( uartOutBufferNext != uartOutBufferTop ) && ( !uo.busy );
    uartOutBufferNext :=  uartOutBufferNext + ( (uartOutBufferNext != uartOutBufferTop) && ( !uo.busy ) );

    always {
        if( outwrite ) {
                uartOutBuffer.addr1 = uartOutBufferTop;
                uartOutBuffer.wdata1 = outchar;
                update = 1;
        } else {
            if( update ) { uartOutBufferTop = uartOutBufferTop + 1; update = 0; }
        }
        uartInBufferNext = uartInBufferNext + inread;
    }
}

// PS2 BUFFER CONTROLLER
algorithm ps2buffer(
    input   uint1   clock_25mhz,

    // USB for PS/2
    input   uint1   us2_bd_dp,
    input   uint1   us2_bd_dn,

    output  uint1   inavailable,
    output  uint8   inchar,
    input   uint1   inread
) <autorun> {
    // PS/2 input FIFO (256 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 ps2Buffer[256] = uninitialized;
    uint8  ps2BufferNext = 0;
    uint7  ps2BufferTop = 0;

    // PS 2 ASCII
    uint1   PS2asciivalid = uninitialized;
    uint8   PS2ascii = uninitialized;
    ps2ascii PS2(
        clock_25mhz <: clock_25mhz,
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,
        asciivalid :> PS2asciivalid,
        ascii :> PS2ascii
    );

    // PS2 Buffers
    uint1   update = uninitialized;
    ps2Buffer.wenable1 := 1;  // always write on port 1
    ps2Buffer.addr0 := ps2BufferNext; // FIFO reads on next

    // FLAGS
    inavailable := ( ps2BufferNext != ps2BufferTop );
    inchar := ps2Buffer.rdata0;

    always {
        if( PS2asciivalid ) {
            ps2Buffer.addr1 = ps2BufferTop;
            ps2Buffer.wdata1 = PS2ascii;
            update = 1;
        } else {
            if( update ) { ps2BufferTop = ps2BufferTop + 1; update = 0; }
        }
        ps2BufferNext = ps2BufferNext + inread;
    }
}

// SDCARD AND BUFFER CONTROLLER
algorithm sdcardbuffer(
    // SDCARD
    output  uint1   sd_clk,
    output  uint1   sd_mosi,
    output  uint1   sd_csn,
    input   uint1   sd_miso,

    input   uint1   readsector,
    input   uint16  sectoraddressH,
    input   uint16  sectoraddressL,
    input   uint9   bufferaddress,
    output  uint1   ready,
    output  uint8   bufferdata
) <autorun> {
    // SDCARD - Code for the SDCARD from @sylefeb
    simple_dualport_bram uint8 sdbuffer <input!> [512] = uninitialized;
    sdcardio sdcio;
    sdcard sd(
        // pins
        sd_clk      :> sd_clk,
        sd_mosi     :> sd_mosi,
        sd_csn      :> sd_csn,
        sd_miso     <: sd_miso,
        // io
        io          <:> sdcio,
        // bram port
        store       <:> sdbuffer
    );

    // SDCARD Commands
    sdcio.read_sector := readsector;
    sdcio.addr_sector := { sectoraddressH, sectoraddressL };
    sdbuffer.addr0 := bufferaddress;
    ready := sdcio.ready;
    bufferdata := sdbuffer.rdata0;
}

algorithm sdramcontroller(
    sdram_user      sio,

    input   uint24  address,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    output  uint16  readdata,

    output  uint1   busy
) <autorun> {
    uint3   FSM = uninitialized;

    // MEMORY ACCESS FLAGS
    sio.addr := { address, 1b0 };
    sio.in_valid := 0;

    // 16 bit READ NO SIGN EXTENSION - INSTRUCTION / PART 32 BIT ACCESS
    readdata := sio.data_out;

    while(1) {
        switch( { readflag, writeflag } ) {
            case 2b10: {
                busy = 1;
                // READ FROM SDRAM
                sio.rw = 0;
                sio.in_valid = 1;
                while( !sio.done ) {}
                busy = 0;
            }
            case 2b01: {
                busy = 1;
                // WRITE TO SDRAM
                sio.data_in = writedata;
                sio.rw = 1;
                sio.in_valid = 1;
                while( !sio.done ) {}
                busy = 0;
            }
            default: {}
        }
    }
}
