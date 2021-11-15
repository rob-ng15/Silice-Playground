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
    uint1   clock_decode = uninitialized;
$$if VERILATOR then
    $$clock_25mhz = 'video_clock'
    // --- PLL
    pll clockgen<@clock,!reset>(
      video_clock   :> video_clock,
      sdram_clock   :> sdram_clock,
      clock_decode   :> clock_decode,
      compute_clock :> clock_system
    );
$$else
    $$clock_25mhz = 'clock'
    // CLOCK/RESET GENERATION
    // CPU + MEMORY
    uint1   sdram_clock = uninitialized;
    uint1   pll_lock_CPU = uninitialized;
    ulx3s_clk_risc_ice_v_CPU clk_gen_CPU (
        clkin    <: $clock_25mhz$,
        clkSYSTEM  :> clock_system,
        clkDECODE  :> clock_decode,
        clkSDRAM :> sdram_clock,
        clkSDRAMcontrol :> sdram_clk,
        locked   :> pll_lock_CPU
    );
$$end

    // SDRAM Reset
    uint1   sdram_reset = uninitialized; clean_reset sdram_rstcond<@sdram_clock,!reset> ( out :> sdram_reset );

    // SDRAM chip controller by @sylefeb
    sdram_r16w16_io sio_fullrate; sdram_r16w16_io sio_halfrate;
    sdram_half_speed_access sdaccess <@sdram_clock,!sdram_reset> ( sd <:> sio_fullrate, sdh <:> sio_halfrate );
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

    // SDRAM ( via CACHE ) and BRAM (for BIOS AND FAST BRAM )
    // byteaccess controls byte read/writes
    uint1   byteaccess <:: ( ~|CPU.accesssize[0,2] );
    cachecontroller DRAM <@clock_system,!reset> (
        sio <:> sio_halfrate,
        byteaccess <: byteaccess,
        address <: CPU.address[0,26],
        writedata <: CPU.writedata,
        writeflag <: sdramwriteflag,
        readflag <: sdramreadflag
    );
    bramcontroller RAM <@clock_system,!reset> (
        byteaccess <: byteaccess,
        address <: CPU.address[0,15],
        writedata <: CPU.writedata,
        writeflag <: ramwriteflag,
        readflag <: ramreadflag
    );

    // MEMORY MAPPED I/O + SMT CONTROLS
    io_memmap IO_Map <@clock_system,!reset> (
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

        memoryAddress <: CPU.address[0,12],
        memoryWrite <: IOmemoryWrite,
        writeData <: CPU.writedata,
        memoryRead <: IOmemoryRead
    );

$$if SIMULATION then
    uint4 audio_l(0);
    uint4 audio_r(0);
$$end
    timers_memmap TIMERS_Map <@clock_system,!reset> (
        clock_25mhz <: $clock_25mhz$,
        memoryAddress <: CPU.address[0,5],
        memoryWrite <: TmemoryWrite,
        writeData <: CPU.writedata,
        memoryRead <: TmemoryRead
    );

    audio_memmap AUDIO_Map <@clock_system,!reset> (
        clock_25mhz <: $clock_25mhz$,
        memoryAddress <: CPU.address[0,3],
        memoryWrite <: AmemoryWrite,
        writeData <: CPU.writedata,
        memoryRead <: AmemoryRead,
        audio_l :> audio_l,
        audio_r :> audio_r,
        static4bit <: TIMERS_Map.static16bit[0,4]
    );

    video_memmap VIDEO_Map <@clock_system,!reset> (
        clock_25mhz <: $clock_25mhz$,
        memoryAddress <: CPU.address[0,12],
        memoryWrite <: VmemoryWrite,
        writeData <: CPU.writedata,
        memoryRead <: VmemoryRead,
$$if HDMI then
        gpdi_dp :> gpdi_dp,
$$end
$$if VGA then
        video_r  :> video_r,
        video_g  :> video_g,
        video_b  :> video_b,
        video_hs :> video_hs,
        video_vs :> video_vs,
$$end
        static6bit <: TIMERS_Map.static16bit[0,6]
    );

    PAWSCPU CPU <@clock_system,!reset> (
        clock_CPUdecoder <: clock_decode,
        SMTRUNNING <: IO_Map.SMTRUNNING,
        SMTSTARTPC <: IO_Map.SMTSTARTPC[0,27],
        memorybusy <: memorybusy,
        readdata <: readdata
    );

    // IDENTIFY ADDRESS BLOCK
    uint1   SDRAM <: CPU.address[26,1];
    uint1   BRAM <: ~SDRAM & ~CPU.address[15,1];
    uint1   IOmem <: ~SDRAM & ~BRAM;
    uint1   TIMERS <: IOmem & ( ~|CPU.address[12,2] );
    uint1   VIDEO <: IOmem & ( CPU.address[12,2] == 2h1 );
    uint1   AUDIO <: IOmem & ( CPU.address[12,2] == 2h2 );
    uint1   IO <: IOmem & ( &CPU.address[12,2] );

    // SDRAM -> CPU BUSY STATE
    uint1   memorybusy <:: DRAM.busy | ( ( CPU.readmemory | CPU.writememory ) & ( BRAM | SDRAM ) );

    // WRITE TO SDRAM / BRAM / IO REGISTERS
    uint1   sdramwriteflag <:: SDRAM & CPU.writememory;
    uint1   ramwriteflag <:: BRAM & CPU.writememory;
    uint1   TmemoryWrite <:: TIMERS & CPU.writememory;
    uint1   VmemoryWrite <:: VIDEO & CPU.writememory;
    uint1   AmemoryWrite <:: AUDIO & CPU.writememory;
    uint1   IOmemoryWrite <:: IO & CPU.writememory;

    // READ FROM SDRAM / BRAM / IO REGISTERS
    uint1   sdramreadflag <: SDRAM & CPU.readmemory;
    uint1   ramreadflag <: BRAM & CPU.readmemory;
    uint1   TmemoryRead <: TIMERS & CPU.readmemory;
    uint1   VmemoryRead <: VIDEO & CPU.readmemory;
    uint1   AmemoryRead <: AUDIO & CPU.readmemory;
    uint1   IOmemoryRead <: IO & CPU.readmemory;
    uint16  readdata <: SDRAM ? DRAM.readdata :
                BRAM ? RAM.readdata :
                TIMERS ? TIMERS_Map.readData :
                VIDEO ? VIDEO_Map.readData :
                AUDIO ? AUDIO_Map.readData :
                IO? IO_Map.readData : 0;
}

// RAM - BRAM controller
// MEMORY IS 16 BIT, 8 bit WRITES ARE READ MODIFY WRITE
algorithm bramcontroller(
    input   uint15  address,
    input   uint1   byteaccess,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    output  uint16  readdata
) <autorun> {
$$if not SIMULATION then
    // RISC-V FAST BRAM and BIOS
    bram uint16 ram[16384] = {
        $include('ROM/BIOS.inc')
        , pad(uninitialized)
    };
$$else
    // RISC-V FAST BRAM and BIOS FOR VERILATOR - TEST FOR SMT AND FPU
    bram uint16 ram[16384] = {
        $include('ROM/VBIOS.inc')
        , pad(uninitialized)
    };
$$end

    // FLAGS FOR BRAM ACCESS
    ram.wenable := 0; ram.addr := address[1,14]; readdata := ram.rdata;
    ram.wdata := byteaccess ? ( address[0,1] ? { writedata[0,8], ram.rdata[0,8] } : { ram.rdata[8,8], writedata[0,8] } ) : writedata;

    while(1) {
        if( writeflag ) {
            if( byteaccess ) {
                ++:
            }
            ram.wenable = 1;
        }
    }
}

// RAM - SDRAM CONTROLLER VIA EVICTION CACHE - MEMORY IS 16 BIT
// EVICTION CACHE CONTROLLER - DIRECTLY MAPPED CACHE - WRITE TO SDRAM ONLY IF EVICTING FROM THE CACHE
bitfield cachetag{
    uint1   needswrite,
    uint1   valid,
    uint12  partaddress
}
algorithm cachecontroller(
    sdram_user      sio,
    input   uint26  address,
    input   uint1   byteaccess,
    input   uint1   writeflag,
    input   uint16  writedata,
    input   uint1   readflag,
    output  uint16  readdata,
    output  uint1   busy(0)
) <autorun> {
    // CACHE for SDRAM 16k
    // CACHE ADDRESS IS LOWER 14 bits ( 0 - 8191 ) of address, dropping the BYTE address bit
    // CACHE TAG IS REMAINING 12 bits of the 26 bit address + 1 bit for valid flag + 1 bit for needwritetosdram flag
    simple_dualport_bram uint16 cache[8192] = uninitialized;
    simple_dualport_bram uint14 tags[8192] = uninitialized;

    // CACHE WRITER
    cachewriter CW( cache <:> cache, tags <:> tags, address <: address);

    // SDRAM CONTROLLER
    uint1   sdramwrite = uninitialized;
    uint1   sdramread = uninitialized;
    uint26  sdramaddress = uninitialized;
    sdramcontroller SDRAM(
        sio <:> sio,
        address <: sdramaddress,
        writedata <: cache.rdata0,
        writeflag <: sdramwrite,
        readflag <: sdramread,
    );

    // CACHE TAG match flag
    uint1   cachetagmatch <:: ( { cachetag(tags.rdata0).valid, cachetag(tags.rdata0).partaddress } == { 1b1, address[14,12] } );

    // VALUE TO WRITE TO CACHE ( deals with correctly mapping 8 bit writes and 16 bit writes, using sdram or cache as base )
    uint16  writethrough <:: ( byteaccess ) ? ( address[0,1] ? { writedata[0,8], cachetagmatch ? cache.rdata0[0,8] : SDRAM.readdata[0,8] } :
                                                                        { cachetagmatch ? cache.rdata0[8,8] : SDRAM.readdata[8,8], writedata[0,8] } ) : writedata;

    // MEMORY ACCESS FLAGS
    uint1   doread = uninitialized;
    uint1   dowrite = uninitialized;

    // SDRAM ACCESS
    sdramread := 0; sdramwrite := 0;

    // FLAGS FOR CACHE ACCESS
    cache.addr0 := address[1,13]; tags.addr0 := address[1,13]; CW.update := 0;

    // 16 bit READ
    readdata := cachetagmatch ? cache.rdata0 : SDRAM.readdata;

    while(1) {
        doread = readflag; dowrite = writeflag;
        if( doread | dowrite ) {
            busy = 1;
            ++: // WAIT FOR CACHE
            if( cachetagmatch ) {
                CW.needwritetosdram = 1; CW.writedata = writethrough; CW.update = dowrite;
            } else {
                if( tags.rdata0[13,1] ) { while( SDRAM.busy ) {} sdramaddress = { tags.rdata0[0,12], address[1,13], 1b0 }; sdramwrite = 1; } else {}   // EVICT FROM CACHE TO SDRAM

                // READ FROM SDRAM FOR READ AND 8 BIT WRITES (AND MODIFY) AND WRITE TO CACHE, OR WRITE DIRECTLY TO CACHE IF 16 BIT WRITE
                if( doread | ( dowrite & byteaccess ) ) {
                    while( SDRAM.busy ) {} sdramaddress = address; sdramread = 1; while( SDRAM.busy ) {}
                    CW.needwritetosdram = dowrite; CW.writedata = dowrite ? writethrough : SDRAM.readdata; CW.update = 1;
                } else {
                    CW.needwritetosdram = 1; CW.writedata = writethrough; CW.update = dowrite;
                }
            }
            busy = 0;
        }
    }
}

algorithm cachewriter(
    input   uint26  address,
    input   uint1   needwritetosdram,
    input   uint16  writedata,
    input   uint1   update,
    simple_dualport_bram_port1 cache,
    simple_dualport_bram_port1 tags
) <autorun,reginputs> {
    cache.wenable1 := update; tags.wenable1 := update;
    cache.addr1 := address[1,13]; cache.wdata1 := writedata;
    tags.addr1 := address[1,13]; tags.wdata1 := { needwritetosdram, 1b1, address[14,12] };
}

algorithm sdramcontroller(
    sdram_user      sio,
    input   uint26  address,
    input   uint1   writeflag,
    input   uint16  writedata,
    input   uint1   readflag,
    output  uint16  readdata,
    output  uint1   busy(0)
) <autorun> {
    // MEMORY ACCESS FLAGS
    sio.addr := { address[1,25], 1b0 }; sio.in_valid := ( readflag | writeflag );
    sio.data_in := writedata; sio.rw := writeflag;
    readdata := sio.data_out;

    always {
        if( readflag | writeflag ) { busy = 1; }
        if( sio.done ) { busy = 0; }
    }
}
