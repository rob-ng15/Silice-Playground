algorithm main(
    // LEDS (8 of)
    output  uint8   leds,
    input   uint$NUM_BTNS$ btns,

    // HDMI OUTPUT
    output  uint4   gpdi_dp,
    output  uint4   gpdi_dn,

    // UART
    output! uint1   uart_tx,
    input   uint1   uart_rx,

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

    // CPU DOMAIN CLOCKS
    uint1   pll_lock_CPU = uninitialized;
    uint1   cpu_clock = uninitialized;
    uint1   clock_copro = uninitialized;
    uint1   clock_memory = uninitialized;
    // Generate 50MHz clocks for CPU units
    // 50MHz clock for the BRAM and CACHE controller
    ulx3s_clk_risc_ice_v_CPU clk_gen_CPU (
        clkin    <: clock,
        clkCPU :> cpu_clock,
        clkCOPRO :> clock_copro,
        clkMEMORY  :> clock_memory,
        locked   :> pll_lock_CPU
    );

    // SDRAM + I/O DOMAIN CLOCKS
    uint1   clock_IO = uninitialized;
    uint1   sdram_clock = uninitialized;
    uint1   sdram_reset = uninitialized;
    uint1   video_reset = uninitialized;
    uint1   video_clock = uninitialized;
    uint1   pll_lock_AUX = uninitialized;
    ulx3s_clk_risc_ice_v_AUX clk_gen_AUX (
        clkin   <: clock,
        clkIO :> clock_IO,
        clkVIDEO :> video_clock,
        clkSDRAM :> sdram_clock,
        clkSDRAMcontrol :> sdram_clk,
        locked :> pll_lock_AUX
    );

    // Video Reset
    clean_reset video_rstcond<@video_clock,!reset> (
        out :> video_reset
    );

    // SDRAM Reset
    clean_reset sdram_rstcond<@sdram_clock,!reset> (
        out :> sdram_reset
    );

    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1   vblank = uninitialized;
    uint1   pix_active = uninitialized;
    uint10  pix_x  = uninitialized;
    uint10  pix_y  = uninitialized;

    // VGA or HDMI driver
    uint8   video_r = uninitialized;
    uint8   video_g = uninitialized;
    uint8   video_b = uninitialized;

    hdmi video<@clock,!reset> (
        vblank  :> vblank,
        active  :> pix_active,
        x       :> pix_x,
        y       :> pix_y,
        gpdi_dp :> gpdi_dp,
        gpdi_dn :> gpdi_dn,
        red     <: video_r,
        green   <: video_g,
        blue    <: video_b
    );

    // RAM - BRAM and SDRAM
    // SDRAM chip controller
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
        function3 <: function3,
        sio <:> sio_halfrate,
        Icache <: Icacheflag,
        address <: address,
        writedata <: writedata,
    );
    bramcontroller ram <@clock_memory> (
        function3 <: function3,
        address <: address,
        writedata <: writedata,
    );

    // MEMORY MAPPED I/O
    memmap_io IO_Map <@clock_IO> (
        leds :> leds,
        btns <: btns,
        uart_tx :> uart_tx,
        uart_rx <: uart_rx,
        audio_l :> audio_l,
        audio_r :> audio_r,
        sd_clk :> sd_clk,
        sd_mosi :> sd_mosi,
        sd_csn :> sd_csn,
        sd_miso <: sd_miso,
        video_r :> video_r,
        video_g :> video_g,
        video_b :> video_b,
        vblank <: vblank,
        pix_active <: pix_active,
        pix_x <: pix_x,
        pix_y <: pix_y,

        video_clock <: video_clock,
        video_reset <: video_reset,

        memoryAddress <: address,
        writeData <: writedata
    );

    uint3   function3 = uninitialized;
    uint32  address = uninitialized;
    uint16  writedata = uninitialized;
    uint1   Icacheflag = uninitialized;
    PAWSCPU CPU <@cpu_clock> (
        function3 :> function3,

        address :> address,
        writedata :> writedata,
        Icacheflag :> Icacheflag,

        clock_copro <: clock_copro
    );

    CPU.memorybusy := sdram.busy;

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
// 8 and 16 bit READS ARE SIGN EXTENDED
algorithm bramcontroller (
    input   uint32  address,
    input   uint3   function3,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    output  uint16  readdata,
) <autorun> {
    // RISC-V RAM and BIOS
    bram uint16 ram <input!> [12288] = {
        $include('ROM/BIOS.inc')
        , pad(uninitialized)
    };

    // FLAGS FOR BRAM ACCESS
    ram.wenable := 0;
    ram.addr := address[1,15];

    // RETURN RESULTS FROM BRAM OR CACHE
    // 16 bit READ NO SIGN EXTENSION - INSTRUCTION / PART 32 BIT ACCESS
    readdata := ram.rdata;

    while(1) {
        if( writeflag ) {
            if( ( function3 & 3 ) == 0 ) {
                // BYTE WRITE - ENSURE ADDRESS IS READY
                ++:
            }
            ram.wdata = ( ( function3 & 3 ) == 0 ) ? ( address[0,1] ? { writedata[0,8], ram.rdata[0,8] } : { ram.rdata[8,8], writedata[0,8] } ) : writedata;
            ram.wenable = 1;
        }
    }
}

// RAM - SDRAM CONTROLLER
// MEMORY IS 16 BIT, 8 bit WRITES ARE READ MODIFY WRITE
// 8 and 16 bit READS ARE SIGN EXTENDED
algorithm sdramcontroller (
    sdram_user      sio,

    input   uint32  address,
    input   uint3   function3,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    input   uint1   Icache,
    output  uint16  readdata,

    output  uint1   busy
) <autorun> {
    // INSTRUCTION & DATA CACHES for SDRAM (32mb)
    // CACHE LINE IS LOWER 11 bits ( 0 - 2047 ) of address, dropping the BYTE address bit
    // CACHE TAG IS REMAINING 14 bits of the 26 bit address + 1 bit for valid flag
    bram uint16 Dcachedata <input!> [2048] = uninitialized;
    bram uint15 Dcachetag <input!> [2048] = uninitialized;
    bram uint16 Icachedata <input!> [2048] = uninitialized;
    bram uint15 Icachetag <input!> [2048] = uninitialized;

    // CACHE TAG match flags
    uint1   Icachetagmatch := ( Icachetag.rdata == { 1b1, address[12,14] } );
    uint1   Dcachetagmatch := ( Dcachetag.rdata == { 1b1, address[12,14] } );

    // MEMORY ACCESS FLAGS
    uint1   active = 0;
    busy := ( readflag || writeflag ) ? 1 : active;
    sio.addr := { address[1,25], 1b0 };
    sio.in_valid := 0;

    // FLAGS FOR CACHE ACCESS
    Dcachedata.wenable := 0; Dcachedata.addr := address[1,11];
    Dcachetag.wenable := 0; Dcachetag.addr := address[1,11]; Dcachetag.wdata := { 1b1, address[12,14] };
    Icachedata.wenable := 0; Icachedata.addr := address[1,11];
    Icachetag.wenable := 0; Icachetag.addr := address[1,11]; Icachetag.wdata := { 1b1, address[12,14] };

    // 16 bit READ NO SIGN EXTENSION - INSTRUCTION / PART 32 BIT ACCESS
    readdata := ( Icache && Icachetagmatch ) ? Icachedata.rdata : ( ( ~Icache && Dcachetagmatch ) ? Dcachedata.rdata : sio.data_out );

    while(1) {
        if( readflag ) {
            // SDRAM - 1 cycle for CACHE TAG ACCESS
            active = 1;
            ++:
            if( ( Icache && Icachetagmatch ) || ( ~Icache && Dcachetagmatch ) ) {
                // CACHE HIT
            } else {
                // CACHE MISS
                // READ FROM SDRAM
                sio.rw = 0;
                sio.in_valid = 1;
                while( !sio.done ) {}

                // WRITE RESULT TO ICACHE or DCACHE
                Dcachedata.wdata = sio.data_out;
                Dcachedata.wenable = ~Icache;
                Dcachetag.wenable = ~Icache;
                Icachedata.wdata = sio.data_out;
                Icachedata.wenable = Icache;
                Icachetag.wenable = Icache;
            }

            active = 0;
        }

        if( writeflag ) {
            // SDRAM writethrough to CACHE
            active = 1;

            if( ( function3 & 3 ) == 0 ) {
                // 8 BIT WRITES
                // SDRAM - 1 cycle for CACHE TAG ACCESS
                ++:
                if( ~Dcachetagmatch ) {
                    // CACHE MISS, READ FROM SDRAM, MODIFY AND WRITE TO CACHE AND SDRAM
                    sio.rw = 0;
                    sio.in_valid = 1;
                    while( !sio.done ) {}
                }
            }

            // SETUP WRITE TO CACHE AND SDRAM
            Dcachedata.wdata = ( ( function3 & 3 ) == 0 ) ? ( address[0,1] ? { writedata[0,8], Dcachetagmatch ? Dcachedata.rdata[0,8] : sio.data_out[0,8] } :
                                                                            { Dcachetagmatch ? Dcachedata.rdata[8,8] : sio.data_out[8,8], writedata[0,8] } ) : writedata;
            Icachedata.wdata = ( ( function3 & 3 ) == 0 ) ? ( address[0,1] ? { writedata[0,8], Dcachetagmatch ? Dcachedata.rdata[0,8] : sio.data_out[0,8] } :
                                                                            { Dcachetagmatch ? Dcachedata.rdata[8,8] : sio.data_out[8,8], writedata[0,8] } ) : writedata;
            sio.data_in = ( ( function3 & 3 ) == 0 ) ? ( address[0,1] ? { writedata[0,8], Dcachetagmatch ? Dcachedata.rdata[0,8] : sio.data_out[0,8] } :
                                                                            { Dcachetagmatch ? Dcachedata.rdata[8,8] : sio.data_out[8,8], writedata[0,8] } ) : writedata;

            // COMPLETE WRITE TO CACHE
            Dcachedata.wenable = 1;
            Dcachetag.wenable = 1;
            Icachedata.wenable = Icachetagmatch;

            // COMPLETE WRITE TO SDRAM
            sio.rw = 1;
            sio.in_valid = 1;
            while( !sio.done ) {}

            active = 0;
        }
    }
}
