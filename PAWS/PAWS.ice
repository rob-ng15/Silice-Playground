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

    // SDRAM and BRAM (for BIOS)
    // FUNCTION3 controls byte read/writes
    uint16  sdramreaddata = uninitialized;
    cachecontroller_EVICT sdram <@clock_system,!reset> (
        sio <:> sio_halfrate,
        function3 <: function3,
        address <: address,
        writedata <: writedata,
        writeflag <: sdramwriteflag,
        readflag <: sdramreadflag,
        readdata :> sdramreaddata
    );
    uint16  ramreaddata = uninitialized;
    bramcontroller ram <@clock_system,!reset> (
        function3 <: function3,
        address <: address,
        writedata <: writedata,
        writeflag <: ramwriteflag,
        readflag <: ramreadflag,
        readdata :> ramreaddata
    );

    // MEMORY MAPPED I/O + SMT CONTROLS
    uint1   SMTRUNNING = uninitialized;
    uint32  SMTSTARTPC = uninitialized;
    uint16  IOreadData = uninitialized;
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

        memoryAddress <: address,
        memoryWrite <: IOmemoryWrite,
        writeData <: writedata,
        memoryRead <: IOmemoryRead,
        readData :> IOreadData,

        SMTRUNNING :> SMTRUNNING,
        SMTSTARTPC :> SMTSTARTPC
    );

$$if SIMULATION then
    uint4 audio_l(0);
    uint4 audio_r(0);
$$end
    uint16  ATreadData = uninitialized;
    audiotimers_memmap AUDIOTIMERS_Map <@clock_system,!reset> (
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
    video_memmap VIDEO_Map <@clock_system,!reset> (
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

    uint3   function3 = uninitialized;
    uint32  address = uninitialized;
    uint16  writedata = uninitialized;
    uint1   CPUwritememory = uninitialized;
    uint1   CPUreadmemory = uninitialized;
    PAWSCPU CPU <@clock_system,!reset> (
        clock_CPUdecoder <: clock_100_1,
        accesssize :> function3,
        address :> address,
        writedata :> writedata,
        SMTRUNNING <: SMTRUNNING,
        SMTSTARTPC <: SMTSTARTPC,
        memorybusy <: memorybusy,
        readdata <: readdata,
        writememory :> CPUwritememory,
        readmemory :> CPUreadmemory
    );

    // IDENTIDY ADDRESS BLOCK
    uint1   SDRAM <: address[28,1];
    uint1   BRAM <: ~address[28,1] & ~address[15,1];
    uint1   VIDEO <: ~address[28,1] & address[15,1] & ( address[12,4]==4h8 );
    uint1   AUDIOTIMERS <: ~address[28,1] & address[15,1] & ( address[12,4]==4he );
    uint1   IO <: ~address[28,1] & address[15,1] & ( address[12,4]==4hf );

    // SDRAM -> CPU BUSY STATE
    uint1   memorybusy <: sdram.busy | ( ( CPUreadmemory | CPUwritememory ) & ( BRAM | SDRAM ) );

    uint16  readdata <: SDRAM ? sdramreaddata :
                BRAM ? ramreaddata :
                VIDEO ? VreadData :
                AUDIOTIMERS ? ATreadData :
                IO? IOreadData : 0;

    // READ / WRITE FROM SDRAM / BRAM
    uint1   sdramwriteflag <: SDRAM & CPUwritememory;
    uint1   sdramreadflag <: SDRAM & CPUreadmemory;
    uint1   ramwriteflag <: BRAM & CPUwritememory;
    uint1   ramreadflag <: BRAM & CPUreadmemory;

    // READ / WRITE FROM I/O
    uint1   VmemoryWrite <: VIDEO & CPUwritememory;
    uint1   VmemoryRead <: VIDEO & CPUreadmemory;
    uint1   ATmemoryWrite <: AUDIOTIMERS & CPUwritememory;
    uint1   ATmemoryRead <: AUDIOTIMERS & CPUreadmemory;
    uint1   IOmemoryWrite <: IO & CPUwritememory;
    uint1   IOmemoryRead <: IO & CPUreadmemory;
}

// RAM - BRAM controller
// MEMORY IS 16 BIT, 8 bit WRITES ARE READ MODIFY WRITE
algorithm bramcontroller(
    input   uint32  address,
    input   uint3   function3,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    output  uint16  readdata
) <autorun> {
    uint2   FSM = uninitialized;

$$if not SIMULATION then
    // RISC-V RAM and BIOS
    bram uint16 ram[16384] = {
        $include('ROM/BIOS.inc')
        , pad(uninitialized)
    };
$$else
    // RISC-V RAM and BIOS
    bram uint16 ram[16384] = {
        $include('ROM/VBIOS.inc')
        , pad(uninitialized)
    };
$$end

    // FLAGS FOR BRAM ACCESS
    ram.wenable := 0;
    ram.addr := address[1,15];

    // 16 bit READ
    readdata := ram.rdata;

    while(1) {
        if( writeflag ) {
            FSM = ( function3[0,2] == 0 ) ? 1 : 2;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {}
                    case 1: {
                        ram.wdata = ( function3[0,2] == 0 ) ? ( address[0,1] ? { writedata[0,8], ram.rdata[0,8] } : { ram.rdata[8,8], writedata[0,8] } ) : writedata;
                        ram.wenable = 1;
                    }
                }
                FSM = { FSM[0,1], 1b0 };
            }
        }
    }
}

// RAM - SDRAM CONTROLLER
// MEMORY IS 16 BIT, 8 bit WRITES ARE READ MODIFY WRITE

// WRITETHROUGH CACHE CONTROLLER
// DIRECTLY MAPPED CACHE - IMMEDIATELY WRITE TO SDRAM
// SPEEDS UP READING WHEN IN CACHE
algorithm cachecontroller_WRITETHROUGH(
    sdram_user      sio,

    input   uint26  address,
    input   uint3   function3,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    output  uint16  readdata,

    output  uint1   busy(0)
) <autorun> {
    uint3   FSM = uninitialized;

    // CACHE for SDRAM 32k
    // CACHE LINE IS LOWER 15 bits ( 0 - 32767 ) of address, dropping the BYTE address bit
    // CACHE TAG IS REMAINING 11 bits of the 26 bit address + 1 bit for valid flag +1 bit for needwritetosdram flag
    simple_dualport_bram uint29 cache[16384] = uninitialized;

    // CACHE WRITER
    uint16  cacheupdatedata = uninitialized;
    uint1   cacheupdate = uninitialized;
    uint1   needwritetosdram = uninitialized;
    cachewriter CW(
        address <: address,
        needwritetosdram <: needwritetosdram,
        writedata <: cacheupdatedata,
        update <: cacheupdate,
        cache <:> cache
    );

    // SDRAM CONTROLLER
    uint16  sdramreaddata = uninitialized;
    uint1   sdramwrite = uninitialized;
    uint1   sdramread = uninitialized;
    uint1   sdrambusy = uninitialized;
    sdramcontroller SDRAM(
        sio <:> sio,
        address <: address,
        writedata <: writethrough,
        writeflag <: sdramwrite,
        readdata :> sdramreaddata,
        readflag <: sdramread,
        busy :> sdrambusy
    );

    // CACHE TAG match flag
    uint1   cachetagmatch <: ( cache.rdata0[16,12] == { 1b1, address[15,11] } );

    // VALUE TO WRITE THROUGH CACHE TO SDRAM
    uint16  writethrough <: ( function3[0,2] == 0 ) ? ( address[0,1] ? { writedata[0,8], cachetagmatch ? cache.rdata0[0,8] : sdramreaddata[0,8] } :
                                                                        { cachetagmatch ? cache.rdata0[8,8] : sdramreaddata[8,8], writedata[0,8] } ) : writedata;

    // MEMORY ACCESS FLAGS
    uint1   doread = uninitialized;
    uint1   dowrite = uninitialized;

    // SDRAM ACCESS
    sdramread := 0; sdramwrite := 0;

    // FLAGS FOR CACHE ACCESS
    cache.addr0 := address[1,14]; cacheupdate := 0;

    // 16 bit READ NO SIGN EXTENSION - INSTRUCTION / PART 32 BIT ACCESS
    readdata := cachetagmatch ? cache.rdata0[0,16] : sdramreaddata[0,16];

    while(1) {
        doread = readflag;
        dowrite = writeflag;

        if( doread || dowrite ) {
            busy = 1;
            FSM = ( doread || ( dowrite && ( function3[0,2] == 0 ) ) ) ? 1 : 4;
            while( FSM != 0 ) {
                // WAIT ONE CYCLE FOR THE CACHE
                onehot( FSM ) {
                    case 0: { FSM = 2; }
                    case 1: {
                        switch( cachetagmatch ) {
                            case 0: {
                                // CACHE MISS
                                // READ FROM SDRAM
                                while( sdrambusy ) {} sdramread = 1; while( sdrambusy ) {}
                                // WRITE RESULT TO CACHE
                                needwritetosdram = 0; cacheupdatedata = sdramreaddata; cacheupdate = 1;
                            }
                            case 1: {}
                        }
                        FSM = dowrite ? 4 : 0;
                    }
                    case 2: {
                        // WRITE RESULT TO CACHE
                        needwritetosdram = 1; cacheupdatedata = writethrough; cacheupdate = 1;
                        // START WRITE TO SDRAM
                        while( sdrambusy ) {} sdramwrite = 1;
                        FSM = 0;
                    }
                }
            }
            busy = 0;
        }
    }
}

// EVICTION CACHE CONTROLLER
// DIRECTLY MAPPED CACHE - WRITE TO SDRAM ONLY IF EVICTING FROM THE CACHE
// SPEEDS UP READING WHEN IN CACHE
algorithm cachecontroller_EVICT(
    sdram_user      sio,

    input   uint26  address,
    input   uint3   function3,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    output  uint16  readdata,

    output  uint1   busy(0)
) <autorun> {
    // CACHE for SDRAM 32k
    // CACHE LINE IS LOWER 15 bits ( 0 - 32767 ) of address, dropping the BYTE address bit
    // CACHE TAG IS REMAINING 11 bits of the 26 bit address + 1 bit for valid flag +1 bit for needwritetosdram flag
    simple_dualport_bram uint29 cache[16384] = uninitialized;

    // CACHE WRITER
    uint16  cacheupdatedata = uninitialized;
    uint1   cacheupdate = uninitialized;
    uint1   needwritetosdram = uninitialized;
    cachewriter CW(
        address <: address,
        needwritetosdram <: needwritetosdram,
        writedata <: cacheupdatedata,
        update <: cacheupdate,
        cache <:> cache
    );

    // SDRAM CONTROLLER
    uint16  sdramwritedata <: cache.rdata0[0,16];
    uint16  sdramreaddata = uninitialized;
    uint1   sdramwrite = uninitialized;
    uint1   sdramread = uninitialized;
    uint1   sdrambusy = uninitialized;
    uint32  sdramaddress = uninitialized;
    sdramcontroller SDRAM(
        sio <:> sio,
        address <: sdramaddress,
        writedata <: sdramwritedata,
        writeflag <: sdramwrite,
        readdata :> sdramreaddata,
        readflag <: sdramread,
        busy :> sdrambusy
    );

    // CACHE TAG match flag
    uint1   cachetagmatch <: ( cache.rdata0[16,12] == { 1b1, address[15,11] } );

    // VALUE TO WRITE TO CACHE ( deals with correctly mapping 8 bit writes and 16 bit writes, using sdram or cache as base )
    uint16  writethrough <: ( function3[0,2] == 0 ) ? ( address[0,1] ? { writedata[0,8], cachetagmatch ? cache.rdata0[0,8] : sdramreaddata[0,8] } :
                                                                        { cachetagmatch ? cache.rdata0[8,8] : sdramreaddata[8,8], writedata[0,8] } ) : writedata;

    // MEMORY ACCESS FLAGS
    uint1   doread = uninitialized;
    uint1   dowrite = uninitialized;

    // SDRAM ACCESS
    sdramread := 0; sdramwrite := 0;

    // FLAGS FOR CACHE ACCESS
    cache.addr0 := address[1,14]; cacheupdate := 0;

    // 16 bit READ
    readdata := cachetagmatch ? cache.rdata0[0,16] : sdramreaddata[0,16];

    while(1) {
        doread = readflag;
        dowrite = writeflag;

        if( doread || dowrite ) {
            busy = 1;
            ++:
            switch( cachetagmatch ) {
                case 1: { needwritetosdram = 1; cacheupdatedata = writethrough; cacheupdate = dowrite; }
                case 0: {
                    if( cache.rdata0[28,1] ) {
                        // EVICT FROM CACHE
                        while( sdrambusy ) {} sdramaddress = { cache.rdata0[16,11], address[1,14], 1b0 }; sdramwrite = 1;
                    }
                    if( doread || ( dowrite && ( function3[0,2] == 0 ) ) )  {
                        // READ OR 8 BIT WRITE
                        while( sdrambusy ) {} sdramaddress = address; sdramread = 1; while( sdrambusy ) {}
                        needwritetosdram = dowrite; cacheupdatedata = dowrite ? writethrough : sdramreaddata; cacheupdate = 1;
                    } else {
                        needwritetosdram = 1; cacheupdatedata = writethrough; cacheupdate = dowrite;
                    }
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
    simple_dualport_bram_port1 cache
) <autorun> {
    cache.wenable1 := 1;
    always {
        switch( update ) {
            case 1: {cache.addr1 = address[1,14]; cache.wdata1 = { needwritetosdram, 1b1, address[15,11], writedata[0,16] }; }
            default: {}
        }
    }
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
    sio.addr := { address[1,25], 1b0 }; sio.in_valid := 0;
    readdata := sio.data_out;

    while(1) {
        switch( readflag | writeflag ) {
            case 1: { busy = 1; sio.data_in = writedata; sio.rw = writeflag; sio.in_valid = 1; while( !sio.done ) {} busy = 0; }
            default: {}
        }
    }
}
