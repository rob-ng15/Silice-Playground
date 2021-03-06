algorithm main(
    // LEDS (8 of)
    output  uint8   leds,
    input   uint$NUM_BTNS$ btns,

    // HDMI OUTPUT
    output  uint4   gpdi_dp,

    // UART
    output! uint1   uart_tx,
    input   uint1   uart_rx,

    // GPIO
    input   uint28  gn,
    output  uint28  gp,

    // USB PS/2
    input   uint1   us2_bd_dp,
    input   uint1   us2_bd_dn,

    // AUDIO
    output! uint4   audio_l,
    output! uint4   audio_r,

    // SDCARD
    output! uint1   sd_clk,
    output! uint1   sd_mosi,
    output! uint1   sd_csn,
    input   uint1   sd_miso,

    // SDRAM
    output! uint1  sdram_cle,
    output! uint2  sdram_dqm,
    output! uint1  sdram_cs,
    output! uint1  sdram_we,
    output! uint1  sdram_cas,
    output! uint1  sdram_ras,
    output! uint2  sdram_ba,
    output! uint13 sdram_a,
    output! uint1  sdram_clk,  // sdram chip clock != internal sdram_clock
    inout   uint16 sdram_dq
) <@clock_memory> {
    // CLOCK/RESET GENERATION

    // CPU + MEMORY
    uint1   pll_lock_CPU = uninitialized;
    uint1   cpu_clock = uninitialized;
    uint1   clock_memory = uninitialized;
    uint1   clock_cpualu = uninitialized;
    uint1   clock_cpufunc = uninitialized;
    ulx3s_clk_risc_ice_v_CPU clk_gen_CPU (
        clkin    <: clock,
        clkCPU :> cpu_clock,
        clkMEMORY  :> clock_memory,
        clkALUblock :> clock_cpualu,
        clkCPUfunc :> clock_cpufunc,
        locked   :> pll_lock_CPU
    );

    // VIDEO + CLOCKS
    uint1   pll_lock_VIDEO = uninitialized;
    uint1   video_clock = uninitialized;
    uint1   gpu_clock = uninitialized;
    ulx3s_clk_risc_ice_v_VIDEO clk_gen_VIDEO (
        clkin    <: clock,
        clkGPU :> gpu_clock,
        clkVIDEO :> video_clock,
        locked   :> pll_lock_VIDEO
    );
    // Video Reset
    uint1   video_reset = uninitialized;
    clean_reset video_rstcond<@video_clock,!reset> (
        out :> video_reset
    );

    // SDRAM  CLOCKS + ON CPU CACHE + USB DOMAIN CLOCKS
    uint1   sdram_clock = uninitialized;
    uint1   clock_cpucache = uninitialized;
    uint1   clock_cpufpu = uninitialized;
    uint1   pll_lock_AUX = uninitialized;
    ulx3s_clk_risc_ice_v_AUX clk_gen_AUX (
        clkin   <: clock,
        clkSDRAM :> sdram_clock,
        clkSDRAMcontrol :> sdram_clk,
        clkCPUcache :> clock_cpucache,
        clkFPUblock :> clock_cpufpu,
        locked :> pll_lock_AUX
    );
    // SDRAM Reset
    uint1   sdram_reset = uninitialized;
    clean_reset sdram_rstcond<@sdram_clock,!reset> (
        out :> sdram_reset
    );

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
        sdram_dq  <:> sdram_dq
    );

    // SDRAM and BRAM (for BIOS)
    // FUNCTION3 controls byte read/writes
    sdramcontroller sdram <@clock_memory> (
        sio <:> sio_halfrate,
        function3 <: function3,
        address <: address,
        writedata <: writedata,
    );
    bramcontroller ram <@clock_memory> (
        function3 <: function3,
        address <: address,
        writedata <: writedata,
    );

    // MEMORY MAPPED I/O + SMT CONTROLS
    uint1   SMTRUNNING = uninitialized;
    uint32  SMTSTARTPC = uninitialized;
    memmap_io IO_Map <@clock_memory> (
        gn <: gn,
        gp :> gp,
        leds :> leds,
        btns <: btns,
        uart_tx :> uart_tx,
        uart_rx <: uart_rx,
        us2_bd_dp <: us2_bd_dp,
        us2_bd_dn <: us2_bd_dn,
        audio_l :> audio_l,
        audio_r :> audio_r,
        sd_clk :> sd_clk,
        sd_mosi :> sd_mosi,
        sd_csn :> sd_csn,
        sd_miso <: sd_miso,
        gpdi_dp :> gpdi_dp,

        clock_25mhz <: clock,
        video_clock <: video_clock,
        video_reset <: video_reset,
        gpu_clock <: gpu_clock,

        memoryAddress <: address,
        writeData <: writedata,

        SMTRUNNING :> SMTRUNNING,
        SMTSTARTPC :> SMTSTARTPC
    );

    uint3   function3 = uninitialized;
    uint32  address = uninitialized;
    uint16  writedata = uninitialized;
    PAWSCPU CPU <@cpu_clock> (
        clock_cpualu <: clock_cpualu,
        clock_cpufpu <: clock_cpufpu,
        clock_cpufunc <: clock_cpufunc,
        clock_cpucache <: clock_cpucache,

        accesssize :> function3,
        address :> address,
        writedata :> writedata,

        SMTRUNNING <: SMTRUNNING,
        SMTSTARTPC <: SMTSTARTPC
    );

    // SDRAM -> CPU BUSY STATE
    CPU.memorybusy := sdram.busy || ( CPU.readmemory && ~address[28,1] && ~address[15,1] );

    // I/O and RAM read/write flags
    sdram.writeflag := CPU.writememory && address[28,1];
    sdram.readflag := CPU.readmemory && address[28,1];
    ram.writeflag := CPU.writememory && ~address[28,1] && ~address[15,1];
    ram.readflag := CPU.readmemory && ~address[28,1] && ~address[15,1];
    IO_Map.memoryWrite := CPU.writememory && ~address[28,1] && address[15,1];
    IO_Map.memoryRead := CPU.readmemory && ~address[28,1] && address[15,1];

    CPU.readdata := address[28,1] ? sdram.readdata : ( address[15,1] ? IO_Map.readData : ram.readdata );

    while(1) {
    }
}

// RAM - BRAM controller
// MEMORY IS 16 BIT, 8 bit WRITES ARE READ MODIFY WRITE

// WRITE TO BRAM
circuitry BRAMwrite(
    inout   ram,
    input   function3,
    input   address,
    input   writedata
) {
    ram.addr = address[1,15];
    if( function3[0,2] == 0 ) {
        ++:
    }
    ram.wdata = ( function3[0,2] == 0 ) ? ( address[0,1] ? { writedata[0,8], ram.rdata[0,8] } : { ram.rdata[8,8], writedata[0,8] } ) : writedata;
    ram.wenable = 1;
}

algorithm bramcontroller(
    input   uint32  address,
    input   uint3   function3,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    output  uint16  readdata
) <autorun> {
    // RISC-V RAM and BIOS
    bram uint16 ram <input!> [16384] = {
        $include('ROM/BIOS.inc')
        , pad(uninitialized)
    };

    // FLAGS FOR BRAM ACCESS
    ram.wenable := 0;
    ram.addr := address[1,15];

    // 16 bit READ
    readdata := ram.rdata;

    while(1) {
        if( writeflag ) {
            ( ram ) = BRAMwrite( ram, function3, address, writedata );
        }
    }
}

// RAM - SDRAM CONTROLLER
// MEMORY IS 16 BIT, 8 bit WRITES ARE READ MODIFY WRITE
// CACHE

// READ FROM SDRAM
circuitry SDRAMread( inout sd, inout cachebram, input addr ) {
    uint32  physicaladdress = uninitialized;
    uint4   count = uninitialized;

    physicaladdress = addr;
    count = 0;

    while( count < 8 ) {
        sd.addr = { physicaladdress[1,25], 1b0 };
        sd.rw = 0;
        sd.in_valid = 1;
        while( !sd.done ) {}

        cachebram.addr1 = physicaladdress[1,14];
        cachebram.wdata1 = { 1b1, physicaladdress[15,15], sd.data_out[0,16] };
        physicaladdress = physicaladdress + 2;
        count = count + 1;
    }
}

// WRITE TO SDRAM
circuitry SDRAMwrite( inout sd, input addr, input writevalue ) {
    sd.addr = { addr[1,25], 1b0 };
    sd.data_in = writevalue;
    sd.rw = 1;
    sd.in_valid = 1;
    while( !sd.done ) {}
}

// UPDATE CACHE
circuitry CACHEupdate( inout cachebram, input addr, input cachevalue ) {
    cachebram.addr1 = addr[1,14];
    cachebram.wdata1 = { 1b1, addr[15,15], cachevalue };
}

algorithm sdramcontroller(
    sdram_user      sio,

    input   uint32  address,
    input   uint3   function3,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    output  uint16  readdata,

    output  uint1   busy
) <autorun> {
    // CACHE for SDRAM 32k
    // CACHE LINE IS LOWER 15 bits ( 0 - 32767 ) of address, dropping the BYTE address bit
    // CACHE TAG IS REMAINING 15 bits of the 26 bit address + 1 bit for valid flag
    simple_dualport_bram uint32 cache <input!> [16384] = uninitialized;

    // CACHE TAG match flag
    uint1   cachetagmatch := ( cache.rdata0[16,16] == { 1b1, address[15,15] } ) ? 1 : 0;

    // SDRAM OUTPUT
    uint16  sioREAD := sio.data_out[0,16];

    // VALUE TO WRITE THROUGH CACHE TO SDRAM
    uint16  writethrough := ( function3[0,2] == 0 ) ? ( address[0,1] ? { writedata[0,8], cache.rdata0[0,8] } : { cache.rdata0[8,8], writedata[0,8] } ) : writedata;

    // MEMORY ACCESS FLAGS
    uint1   doread = uninitialized;
    uint1   dowrite = uninitialized;
    sio.in_valid := 0;

    // FLAGS FOR CACHE ACCESS
    cache.wenable1 := 1; cache.addr0 := address[1,14];

    // 16 bit READ NO SIGN EXTENSION - INSTRUCTION / PART 32 BIT ACCESS
    readdata := cache.rdata0[0,16];

    while(1) {
        doread = readflag;
        dowrite = writeflag;

        if( doread || dowrite ) {
            busy = 1;

            if( doread || ( dowrite && ( function3[0,2] == 0 ) ) ) {
                // SDRAM - 1 cycle for CACHE TAG ACCESS
                ++:

                if( cachetagmatch ) {
                    // CACHE HIT
                } else {
                    // CACHE MISS
                    // READ FROM SDRAM
                    ( sio, cache ) = SDRAMread( sio, cache, address );
                }
            }

            if( dowrite ) {
                // WRITE RESULT TO CACHE
                ( cache ) = CACHEupdate( cache, address, writethrough );
                // COMPLETE WRITE TO SDRAM
                ( sio ) = SDRAMwrite( sio, address, writethrough );
            }

            busy = 0;
        }
    }
}
