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
) <@clock_IO> {
    // CLOCK/RESET GENERATION

    // CPU DOMAIN CLOCKS
    uint1   pll_lock_CPU = uninitialized;
    uint1   clock_copro = uninitialized;
    uint1   clock_cpuunit = uninitialized;
    uint1   clock_memory = uninitialized;
    // Generate 50MHz clocks for CPU units
    // 50MHz clock for the BRAM and CACHE controller
    ulx3s_clk_risc_ice_v_CPU clk_gen_CPU (
        clkin    <: clock,
        clkCOPRO :> clock_copro,
        clkMEMORY  :> clock_memory,
        clkCPUUNIT :> clock_cpuunit,
        locked   :> pll_lock_CPU
    );

    // SDRAM + I/O DOMAIN CLOCKS
    uint1   clock_IO = uninitialized;
    uint1   clock_sdram = uninitialized;
    uint1   video_reset = uninitialized;
    uint1   video_clock = uninitialized;
    uint1   pll_lock_AUX = uninitialized;
    ulx3s_clk_risc_ice_v_AUX clk_gen_AUX (
        clkin   <: clock,
        clkIO :> clock_IO,
        clkVIDEO :> video_clock,
        clkSDRAM :> clock_sdram,
        clkSDRAMcontrol :> sdram_clk,
        locked :> pll_lock_AUX
    );

    // Video Reset
    reset_conditioner vga_rstcond (
        rcclk <: video_clock ,
        in  <: reset,
        out :> video_reset
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
    sdram_r16w16_io sio;
    // algorithm
    sdram_controller_autoprecharge_r16_w16 sdram <@clock_sdram> (
        sd        <:> sio,
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

    // <@clock_memory>
    uint1   memorybusy = uninitialized;
    ramcontroller ram <@clock_memory> (
        function3 <: function3,
        sio <:> sio,
        Icache <: Icacheflag,
        address <: address,
        writedata <: writedata,
        busy :> memorybusy
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

        function3 <: function3,
        memoryAddress <: address,
        writeData <: writedata
    );

    uint3   function3 = uninitialized;
    uint32  address = uninitialized;
    uint16  writedata = uninitialized;
    uint1   Icacheflag = uninitialized;
    PAWSCPU CPU <@clock> (
        function3 :> function3,

        address :> address,
        writedata :> writedata,
        Icacheflag :> Icacheflag,

        memorybusy <: memorybusy,

        clock_cpuunit <: clock_cpuunit,
        clock_copro <: clock_copro
    );

    // I/O and RAM read/write flags
    ram.writeflag := CPU.writememory && ~( ~address[28,1] && address[15,1] );
    ram.readflag := CPU.readmemory && ~( ~address[28,1] && address[15,1] );
    IO_Map.memoryWrite := CPU.writememory && ~address[28,1] && address[15,1];
    IO_Map.memoryRead := CPU.readmemory && ~address[28,1] && address[15,1];

    CPU.readdata := ( ~address[28,1] && address[15,1] ) ? IO_Map.readData : ram.readdata;
    CPU.readdata8 := ( ~address[28,1] && address[15,1] ) ? IO_Map.readData8 : ram.readdata8;
    CPU.readdata16 := ( ~address[28,1] && address[15,1] ) ? IO_Map.readData16 : ram.readdata16;

    while(1) {
    }
}

// RAM - BRAM controller and SDRAM controller ( with simple write-through cache )
// MEMORY IS 16 BIT, 8 bit WRITES ARE READ MODIFY WRITE
// 8 and 16 bit READS ARE SIGN EXTENDED

algorithm ramcontroller (
    sdram_user      sio,

    input   uint32  address,
    input   uint3   function3,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    input   uint1   Icache,
    output  uint16  readdata,
    output  int32   readdata8,
    output  int32   readdata16,

    output  uint1   busy
) <autorun> {
    // RISC-V RAM and BIOS
    bram uint16 ram <input!> [12288] = {
        $include('ROM/BIOS.inc')
        , pad(uninitialized)
    };

    // ACTIVE FLAG
    uint1   active = 0;

    // SIGN EXTENDER UNIT
    uint8   SE8nosign = uninitialized;
    int32   SE8sign = uninitialized;
    signextender8 signextender8unit (
        function3 <: function3,
        nosign <: SE8nosign,
        withsign :> SE8sign
    );
    uint16  SE16nosign = uninitialized;
    int32   SE16sign = uninitialized;
    signextender16 signextender16unit (
        function3 <: function3,
        nosign <: SE16nosign,
        withsign :> SE16sign
    );

    busy := ( readflag || writeflag ) ? 1 : active;
    sio.in_valid := 0;

    // FLAGS FOR BRAM ACCESS
    ram.wenable := 0;
    ram.addr := address[1,15];

    // RETURN RESULTS FROM BRAM OR CACHE
    // 16 bit READ NO SIGN EXTENSION - INSTRUCTION / PART 32 BIT ACCESS
    readdata := address[28,1] ? sio.data_out : ram.rdata;

    // 8/16 bit READ WITH OPTIONAL SIGN EXTENSION
    SE8nosign := address[28,1] ? ( sio.data_out[address[0,1] ? 8 : 0, 8] ) : ( ram.rdata[address[0,1] ? 8 : 0, 8] );
    SE16nosign := address[28,1] ? sio.data_out : ram.rdata;
    readdata8 := SE8sign;
    readdata16 := SE16sign;

    while(1) {
        if( readflag && address[28,1] ) {
            // SDRAM
            active = 1;

            // READ FROM SDRAM
            sio.addr = address;
            sio.rw = 0;
            sio.in_valid = 1;
            while( !sio.done ) {}

            active = 0;
        }

        if( writeflag ) {
            if( address[28,1] ) {
                // SDRAM
                active = 1;

                if( ( function3 & 3 ) == 0 ) {
                    // READ FROM SDRAM for 8 bit writes
                    sio.addr = address;
                    sio.rw = 0;
                    sio.in_valid = 1;
                    while( !sio.done ) {}
                }
                // WRITE TO SDRAM
                sio.addr = address;
                sio.data_in = ( ( function3 & 3 ) == 0 ) ? ( address[0,1] ? { writedata[0,8], sio.data_out[0,8] } : { sio.data_out[8,8], writedata[0,8] } ) : writedata;
                sio.rw = 1;
                sio.in_valid = 1;
                while( !sio.done ) {}

                active = 0;
            } else {
                // BRAM
                if( ( function3 & 3 ) == 0 ) {
                    // BYTE WRITE - ENSURE ADDRESS IS READY
                    ++:
                }
                ram.wdata = ( ( function3 & 3 ) == 0 ) ? ( address[0,1] ? { writedata[0,8], ram.rdata[0,8] } : { ram.rdata[8,8], writedata[0,8] } ) : writedata;
                ram.wenable = 1;
                active = 0;
            }
        }
    }
}
