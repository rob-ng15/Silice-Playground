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
    uint1   clock_io = uninitialized;
    uint1   clock_cpu = uninitialized;
    uint1   clock_decode = uninitialized;
$$if VERILATOR then
    $$clock_25mhz = 'video_clock'
    // --- PLL
    pll clockgen<@clock,!reset>(
      video_clock   :> video_clock,
      sdram_clock   :> sdram_clock,
      clock_decode   :> clock_decode,
      compute_clock :> clock_system,
      compute_clock :> clock_io,
      compute_clock :> clock_cpu
    );
$$else
    $$clock_25mhz = 'clock'
    // CLOCK/RESET GENERATION
    // CPU + MEMORY
    uint1   sdram_clock = uninitialized;
    uint1   pll_lock_SYSTEM = uninitialized;
    ulx3s_clk_risc_ice_v_SYSTEM clk_gen_SYSTEM (
        clkin    <: $clock_25mhz$,
        clkSYSTEM  :> clock_system,
        clkIO :> clock_io,
        clkSDRAM :> sdram_clock,
        clkSDRAMcontrol :> sdram_clk,
        locked   :> pll_lock_SYSTEM
    );
    uint1   pll_lock_CPU = uninitialized;
    ulx3s_clk_risc_ice_v_CPU clk_gen_CPU (
        clkin    <: $clock_25mhz$,
        clkCPU  :> clock_cpu,
        clkDECODE  :> clock_decode,
        locked   :> pll_lock_CPU
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
    uint16  ramreaddata = uninitialized;
    bramcontroller ram <@clock_system,!reset> (
        address <: address,
        writedata <: writedata,
        writeflag <: ramwriteflag,
        readflag <: ramreadflag,
        readdata :> ramreaddata
    );

    // MEMORY MAPPED I/O + SMT CONTROLS
    uint16  IOreadData = uninitialized;
    io_memmap IO_Map <@clock_io,!reset> (
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
        memoryWrite <: IOmemoryWrite,
        writeData <: writedata,
        memoryRead <: IOmemoryRead,
        readData :> IOreadData
    );
$$if SIMULATION then
    uint4 audio_l(0);
    uint4 audio_r(0);
$$end

    uint16  COreadData = uninitialized;
    copro_memmap COPRO_Map <@clock_io,!reset> (
        memoryAddress <: address,
        memoryWrite <: COmemoryWrite,
        writeData <: writedata,
        memoryRead <: COmemoryRead,
        readData :> COreadData
    );

    uint16  ATreadData = uninitialized;
    audiotimers_memmap AUDIOTIMERS_Map <@clock_io,!reset> (
        clock_25mhz <: $clock_25mhz$,
        memoryAddress <: address,
        memoryWrite <: ATmemoryWrite,
        writeData <: writedata,
        memoryRead <: ATmemoryRead,
        readData :> ATreadData,
        audio_l :> audio_l,
        audio_r :> audio_r
    );

    uint16  VreadData = uninitialized;
    video_memmap VIDEO_Map <@clock_io,!reset> (
        clock_25mhz <: $clock_25mhz$,
       memoryAddress <: address,
        memoryWrite <: VmemoryWrite,
        writeData <: writedata,
        memoryRead <: VmemoryRead,
        readData :> VreadData,
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
    J1CPU CPU <@clock_cpu,!reset> (
        clock100 <: clock_decode,
        address :> address,
        writedata :> writedata,
        memorybusy <: memorybusy,
        readdata <: readdata
    );

    // IDENTIDY ADDRESS BLOCK
    uint1   BRAM <: ~&address[14,2];
    uint1   VIDEO <: ~BRAM & ( ~|address[12,2] );
    uint1   COPRO <: ~BRAM & ( address[12,2] == 2b01 );
    uint1   AUDIOTIMERS <: ~BRAM & ( address[12,2] == 2b10 );
    uint1   IO <: ~BRAM & ( &address[12,2] );

    // CPU BUSY STATE
    uint1   memorybusy <:: CPU.readmemory & BRAM;

    uint16  readdata <: BRAM ? ramreaddata :
                    VIDEO ? VreadData :
                    COPRO ? COreadData :
                    AUDIOTIMERS ? ATreadData :
                    IO ? IOreadData : 0;

    // READ / WRITE FROM SDRAM / BRAM
    uint1   ramwriteflag <:: BRAM & CPU.writememory;
    uint1   ramreadflag <: BRAM & CPU.readmemory;


    // READ / WRITE FROM I/O
    uint1   VmemoryWrite <:: VIDEO & CPU.writememory;
    uint1   VmemoryRead <: VIDEO & CPU.readmemory;
    uint1   COmemoryWrite <:: COPRO & CPU.writememory;
    uint1   COmemoryRead <: COPRO & CPU.readmemory;
    uint1   ATmemoryWrite <:: AUDIOTIMERS & CPU.writememory;
    uint1   ATmemoryRead <: AUDIOTIMERS & CPU.readmemory;
    uint1   IOmemoryWrite <:: IO & CPU.writememory;
    uint1   IOmemoryRead <: IO & CPU.readmemory;
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
    bram uint16 ram[24576] = {
        $include('ROM/j1eforthROM.inc')
        , pad(uninitialized)
    };

    // FLAGS FOR BRAM ACCESS
    ram.wdata := writedata;
    ram.wenable := writeflag;
    ram.addr := address;

    // 16 bit READ
    readdata := ram.rdata;
}
