$$if ICARUS or VERILATOR then
// PLL for simulation
algorithm pll(
  output  uint1 video_clock,
  output! uint1 sdram_clock,
  output! uint1 clock_100_1,
  output! uint1 clock_100_2,
  output! uint1 clock_100_3,
  output  uint1 compute_clock
) <autorun> {
  uint3 counter = 0;
  uint8 trigger = 8b11111111;
  sdram_clock   := clock;
  clock_100_1   := clock;
  clock_100_2   := clock;
  clock_100_3   := clock;
  compute_clock := ~counter[0,1]; // x2 slower
  video_clock   := counter[1,1]; // x4 slower
  while (1) {
    counter = counter + 1;
	  trigger = trigger >> 1;
  }
}
$$end

algorithm main(
    // LEDS (8 of)
    output  uint8   leds,
$$if not SIMULATION then
    input   uint$NUM_BTNS$ btns,

    // UART
    output  uint1   uart_tx,
    input   uint1   uart_rx,

    // GPIO
    input   uint28  gn,
    output  uint28  gp,

    // USB PS/2
    input   uint1   us2_bd_dp,
    input   uint1   us2_bd_dn,

    // AUDIO
    output  uint4   audio_l,
    output  uint4   audio_r,

    // SDCARD
    output  uint1   sd_clk,
    output  uint1   sd_mosi,
    output  uint1   sd_csn,
    input   uint1   sd_miso,
$$end

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
    output  uint1 video_clock,
$$end
    // SDRAM
    output! uint1  sdram_cle,
    output! uint2  sdram_dqm,
    output! uint1  sdram_cs,
    output! uint1  sdram_we,
    output! uint1  sdram_cas,
    output! uint1  sdram_ras,
    output! uint2  sdram_ba,
    output! uint13 sdram_a,
$$if VERILATOR then
    output! uint1  sdram_clock, // sdram controller clock
    input   uint16 sdram_dq_i,
    output! uint16 sdram_dq_o,
    output! uint1  sdram_dq_en,
$$else
    output uint1  sdram_clk,  // sdram chip clock != internal sdram_clock
    inout  uint16 sdram_dq,
$$end
) <@clock_system> {
    uint1   clock_system = uninitialized;
    uint1   clock_100_1 = uninitialized;
    uint1   clock_100_2 = uninitialized;
    uint1   clock_100_3 = uninitialized;
$$if VERILATOR then
    $$clock_25mhz = 'video_clock'
    // --- PLL
    pll clockgen<@clock,!reset>(
      video_clock   :> video_clock,
      sdram_clock   :> sdram_clock,
      clock_100_1   :> clock_100_1,
      clock_100_2   :> clock_100_2,
      clock_100_3   :> clock_100_3,
      compute_clock :> clock_system
    );
$$else
    $$clock_25mhz = 'clock'
    // CLOCK/RESET GENERATION
    // CPU + MEMORY
    uint1   pll_lock_CPU = uninitialized;
    ulx3s_clk_risc_ice_v_CPU clk_gen_CPU (
        clkin    <: $clock_25mhz$,
        clkSYSTEM  :> clock_system,
        clk100_1  :> clock_100_1,
        clk100_2  :> clock_100_2,
        clk100_3  :> clock_100_3,
        locked   :> pll_lock_CPU
    );
    // SDRAM  CLOCKS + ON CPU CACHE + USB DOMAIN CLOCKS
    uint1   sdram_clock = uninitialized;
    uint1   pll_lock_AUX = uninitialized;
    ulx3s_clk_risc_ice_v_AUX clk_gen_AUX (
        clkin   <: $clock_25mhz$,
        clkSDRAM :> sdram_clock,
        clkSDRAMcontrol :> sdram_clk,
        locked :> pll_lock_AUX
    );
$$end

    // SDRAM Reset
    uint1   sdram_reset = uninitialized;
    clean_reset sdram_rstcond<@sdram_clock,!reset> ( out :> sdram_reset );

    // RAM - BRAM and SDRAM
    // SDRAM chip controller by @sylefeb
    // interface
    sdram_r16w16_io sio_fullrate;
    sdram_r16w16_io sio_halfrate;
    sdram_half_speed_access sdaccess <@sdram_clock,!sdram_reset> (
            sd      <:> sio_fullrate,
            sdh     <:> sio_halfrate,
    );
    // algorithm
    sdram_controller_autoprecharge_r16_w16 sdram32MB <@sdram_clock,!sdram_reset> (
        sd        <:> sio_fullrate,
        sdram_cle :>  sdram_cle,
        sdram_dqm :>  sdram_dqm,
        sdram_cs  :>  sdram_cs,
        sdram_we  :>  sdram_we,
        sdram_cas :>  sdram_cas,
        sdram_ras :>  sdram_ras,
        sdram_ba  :>  sdram_ba,
        sdram_a   :>  sdram_a,
  $$if VERILATOR then
        dq_i       <: sdram_dq_i,
        dq_o       :> sdram_dq_o,
        dq_en      :> sdram_dq_en,
  $$else
        sdram_dq  <:> sdram_dq,
  $$end
    );

    // BRAM (for BIOS)
    bramcontroller ram <@clock_system,!reset> (
        address <: address,
        writedata <: writedata,
    );

    // MEMORY MAPPED I/O + SMT CONTROLS
    io_memmap IO_Map <@clock_system,!reset> (
        sio <:> sio_halfrate,
        leds :> leds,
$$if not SIMULATION then
        gn <: gn,
        gp :> gp,
        btns <: btns,
        uart_tx :> uart_tx,
        uart_rx <: uart_rx,
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,
        sd_clk :> sd_clk,
        sd_mosi :> sd_mosi,
        sd_csn :> sd_csn,
        sd_miso <: sd_miso,
$$end
        clock_25mhz <: $clock_25mhz$,

        memoryAddress <: address,
        writeData <: writedata
    );
$$if SIMULATION then
    uint4 audio_l(0);
    uint4 audio_r(0);
$$end

    copro_memmap COPRO_Map <@clock_system,!reset> (
        clock100 <: clock_100_2,
        memoryAddress <: address,
        writeData <: writedata,
    );

    audiotimers_memmap AUDIOTIMERS_Map <@clock_system,!reset> (
        clock_25mhz <: $clock_25mhz$,
        memoryAddress <: address,
        writeData <: writedata,
        audio_l :> audio_l,
        audio_r :> audio_r
    );

    video_memmap VIDEO_Map <@clock_system,!reset> (
        clock_25mhz <: $clock_25mhz$,
        memoryAddress <: address,
        writeData <: writedata,
$$if HDMI then
        gpdi_dp :> gpdi_dp
$$end
$$if VGA then
        video_r  :> video_r,
        video_g  :> video_g,
        video_b  :> video_b,
        video_hs :> video_hs,
        video_vs :> video_vs
$$end
    );

    uint16  address = uninitialized;
    uint16  writedata = uninitialized;
    J1CPU CPU <@clock_system,!reset> (
        clock100 <: clock_100_1,
        address :> address,
        writedata :> writedata
    );

    // IDENTIDY ADDRESS BLOCK
    uint1   BRAM <: address[12,4] < 4hc;
    uint1   VIDEO <: address[12,4] == 4hc;
    uint1   COPRO <: address[12,4] == 4hd;
    uint1   AUDIOTIMERS <: address[12,4] == 4he;
    uint1   IO <: address[12,4] == 4hf ;

    // CPU BUSY STATE
    CPU.memorybusy := ( CPU.readmemory | CPU.writememory ) & BRAM;

    // READ / WRITE FROM SDRAM / BRAM
    ram.writeflag := BRAM & CPU.writememory;
    ram.readflag := BRAM & CPU.readmemory;

    // READ / WRITE FROM I/O
    VIDEO_Map.memoryWrite := VIDEO & CPU.writememory;
    VIDEO_Map.memoryRead := VIDEO & CPU.readmemory;
    COPRO_Map.memoryWrite := COPRO & CPU.writememory;
    COPRO_Map.memoryRead := COPRO & CPU.readmemory;
    AUDIOTIMERS_Map.memoryWrite := AUDIOTIMERS & CPU.writememory;
    AUDIOTIMERS_Map.memoryRead := AUDIOTIMERS & CPU.readmemory;
    IO_Map.memoryWrite := IO & CPU.writememory;
    IO_Map.memoryRead := IO & CPU.readmemory;

    CPU.readdata := BRAM ? ram.readdata :
                    VIDEO ? VIDEO_Map.readData :
                    COPRO ? COPRO_Map.readData :
                    AUDIOTIMERS ? AUDIOTIMERS_Map.readData :
                    IO ? IO_Map.readData : 0;
}

// RAM - BRAM controller
// MEMORY IS 16 BIT, 8 bit WRITES ARE READ MODIFY WRITE

algorithm bramcontroller(
    input   uint16  address,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    output  uint16  readdata
) <autorun> {
    // RISC-V RAM and BIOS
    bram uint16 ram <input!> [24576] = {
        $include('ROM/j1eforthROM.inc')
        , pad(uninitialized)
    };

    // FLAGS FOR BRAM ACCESS
    ram.wenable := 0;
    ram.addr := address;

    // 16 bit READ
    readdata := ram.rdata;

    while(1) {
        switch( writeflag ) {
            case 1: { ram.wdata = writedata; ram.wenable = 1; }
            case 0: {}
       }
    }
}
