algorithm main(
    // LEDS (8 of)
    output  uint8   leds,
    input   uint$NUM_BTNS$ btns,

    // HDMI OUTPUT
    output  uint4   gpdi_dp,

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
) <@clock_system> {
    // CLOCK/RESET GENERATION

    // CPU + MEMORY
    uint1   pll_lock_CPU = uninitialized;
    uint1   clock_system = uninitialized;
    uint1   clock_100_1 = uninitialized;
    uint1   clock_100_2 = uninitialized;
    uint1   clock_100_3 = uninitialized;
    ulx3s_clk_risc_ice_v_CPU clk_gen_CPU (
        clkin    <: clock,
        clkSYSTEM  :> clock_system,
        clk100_1  :> clock_100_1,
        clk100_2  :> clock_100_2,
        clk100_3  :> clock_100_3,
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
    uint1   pll_lock_AUX = uninitialized;
    ulx3s_clk_risc_ice_v_AUX clk_gen_AUX (
        clkin   <: clock,
        clkSDRAM :> sdram_clock,
        clkSDRAMcontrol :> sdram_clk,
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
    sdramcontroller sdram <@clock_system> (
        sio <:> sio_halfrate,
        function3 <: function3,
        address <: address,
        writedata <: writedata,
    );
    bramcontroller ram <@clock_system> (
        function3 <: function3,
        address <: address,
        writedata <: writedata,
    );

    // MEMORY MAPPED I/O + SMT CONTROLS
    uint1   SMTRUNNING = uninitialized;
    uint32  SMTSTARTPC = uninitialized;
    memmap_io IO_Map <@clock_system> (
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
    PAWSCPU CPU <@clock_system> (
        clock_CPUdecoder <: clock_100_1,
        accesssize :> function3,
        address :> address,
        writedata :> writedata,

        SMTRUNNING <: SMTRUNNING,
        SMTSTARTPC <: SMTSTARTPC
    );

    // SDRAM -> CPU BUSY STATE
    CPU.memorybusy := sdram.busy || CPU.readmemory || CPU.writememory;

    // I/O and RAM read/write flags - address[28,1] == 0 BRAM or I/O == 1 SDRAM, address[15,1] == 0 BRAM == 1 I/O
    sdram.writeflag := CPU.writememory && address[28,1];
    sdram.readflag := CPU.readmemory && address[28,1];
    ram.writeflag := CPU.writememory && ~address[28,1] && ~address[15,1];
    ram.readflag := CPU.readmemory && ~address[28,1] && ~address[15,1];
    IO_Map.memoryWrite := CPU.writememory && ~address[28,1] && address[15,1];
    IO_Map.memoryRead := CPU.readmemory && ~address[28,1] && address[15,1];

    CPU.readdata := address[28,1] ? sdram.readdata : ( address[15,1] ? IO_Map.readData : ram.readdata );

    while(1) {}
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
            if( function3[0,2] == 0 ) {
                ++:
            }
            ram.wdata = ( function3[0,2] == 0 ) ? ( address[0,1] ? { writedata[0,8], ram.rdata[0,8] } : { ram.rdata[8,8], writedata[0,8] } ) : writedata;
            ram.wenable = 1;
        }
    }
}

// RAM - SDRAM CONTROLLER
// MEMORY IS 16 BIT, 8 bit WRITES ARE READ MODIFY WRITE
// CACHE
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
    // CACHE TAG IS REMAINING 11 bits of the 26 bit address + 1 bit for valid flag
    simple_dualport_bram uint28 cache <input!> [16384] = uninitialized;

    cachewriter CW(
        address <: address,
        cache <:> cache
    );

    // CACHE TAG match flag
    uint1   cachetagmatch <: ( cache.rdata0[16,12] == { 1b1, address[15,11] } ) ? 1 : 0;

    // VALUE TO WRITE THROUGH CACHE TO SDRAM
    uint16  writethrough <: ( function3[0,2] == 0 ) ? ( address[0,1] ? { writedata[0,8], cachetagmatch ? cache.rdata0[0,8] : sio.data_out[0,8] } :
                                                                        { cachetagmatch ? cache.rdata0[8,8] : sio.data_out[8,8], writedata[0,8] } ) : writedata;

    // MEMORY ACCESS FLAGS
    uint1   doread = uninitialized;
    uint1   dowrite = uninitialized;
    sio.addr := { address[1,25], 1b0 };
    sio.in_valid := 0;

    // FLAGS FOR CACHE ACCESS
    cache.addr0 := address[1,14];
    CW.update := 0;

    // 16 bit READ NO SIGN EXTENSION - INSTRUCTION / PART 32 BIT ACCESS
    readdata := cachetagmatch ? cache.rdata0[0,16] : sio.data_out[0,16];

    while(1) {
        doread = readflag;
        dowrite = writeflag;

        if( doread || dowrite ) {
            busy = 1;

            if( doread || ( dowrite && ( function3[0,2] == 0 ) ) ) {
                // SDRAM - 1 cycle for CACHE TAG ACCESS
                ++:

                if( ~cachetagmatch ) {
                    // CACHE MISS
                    // READ FROM SDRAM
                    sio.rw = 0;
                    sio.in_valid = 1;
                    while( !sio.done ) {}
                    // WRITE RESULT TO CACHE
                    CW.writedata = sio.data_out;
                    CW.update = 1;
                }
            }

            if( dowrite ) {
                // WRITE RESULT TO CACHE
                CW.writedata = writethrough;
                CW.update = 1;
                // COMPLETE WRITE TO SDRAM
                sio.data_in = writethrough;
                sio.rw = 1;
                sio.in_valid = 1;
                while( !sio.done ) {}
            }

            busy = 0;
        }
    }
}

algorithm cachewriter(
    input   uint32  address,
    input   uint16  writedata,
    input   uint1   update,
    simple_dualport_bram_port1 cache
) <autorun> {
    cache.wenable1 := 1;

    while(1) {
        if( update ) {
            cache.addr1 = address[1,14];
            cache.wdata1 = { 1b1, address[15,11], writedata[0,16] };
        }
    }
}
