algorithm ramcontrollerSDRAM (
    output!  uint1   sdram_cle,
    output!  uint2   sdram_dqm,
    output!  uint1   sdram_cs,
    output!  uint1   sdram_we,
    output!  uint1   sdram_cas,
    output!  uint1   sdram_ras,
    output!  uint2   sdram_ba,
    output!  uint13  sdram_a,
    //output  uint1   sdram_clk,  // sdram chip clock != internal sdram_clock
    inout   uint16  sdram_dq,

    input   uint32  address,

    input   uint3   function3,

    input   uint16  writedata,
    output  uint16  readdata,
    output  uint32  readdata8,
    output  uint32  readdata16,

    input   uint1   writeflag,
    input   uint1   readflag,

    input   uint1   Icache,

    output  uint1   busy
) <autorun> {
    // SDRAM chip controller
    // interface
    sdram_raw_io sdram_io;
    // algorithm
    sdram_controller sdram(
        sd        <:> sdram_io,
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

    // INSTRUCTION & DATA CACHES for SDRAM
    // CACHE LINE IS LOWER 12 bits ( 0 - 4095 ) of address, dropping the BYTE address bit
    // CACHE TAG IS REMAINING 12 bits of the 25 bit address
    bram uint16 Dcachedata<input!>[4096] = uninitialized;
    bram uint12 Dcachetag<input!>[4096] = uninitialized;
    bram uint16 Icachedata<input!>[4096] = uninitialized;
    bram uint12 Icachetag<input!>[4096] = uninitialized;

    // FLAGS FOR CACHE ACCESS
    Dcachedata.wenable := 0; Dcachedata.addr := address[1,12];
    Dcachetag.wenable := 0; Dcachetag.addr := address[1,12]; Dcachetag.wdata := address[13,12];
    Icachedata.wenable := 0; Icachedata.addr := address[1,12];
    Icachetag.wenable := 0; Icachetag.addr := address[1,12]; Icachetag.wdata := address[13,12];

    // RETURN RESULTS FROM CACHES
    // NON-SIGN EXTENDED 16 bit read - for instructions and 32 bit reads
    readdata := Icache ? Icachedata.rdata : Dcachedata.rdata;
    // OPTIONAL SIGN EXTENDED 8 bit and 16 bit reads, expanded to 32 bit as per Risc-V Specification
    readdata8 := { ( ( ( address[0,1] ? Dcachedata.rdata[15,1] : Dcachedata.rdata[7,1] ) & ~function3[2,1] ) ? 24hffffff : 24h000000 ), ( address[0,1] ? Dcachedata.rdata[8,8] : Dcachedata.rdata[0,8] ) };
    readdata16 := { ( Dcachedata.rdata[15,1] & ~function3[2,1] ) ? 16hffff : 16h0000, Dcachedata.rdata };

    while(1) {
        if( readflag ) {
            if( ( Icache && ( Icachetag.rdata == address[13,12] ) ) || ( Dcachetag.rdata == address[13,12] ) ) {
                // CACHE HIT
                busy = 0;
            } else {
                // CACHE MISS
                busy = 1;

                // READ FROM SDRAM
                sdram_io.rw = 0;
                while( sdram_io.busy ) {}
                sdram_io.addr = address[1,24];
                sdram_io.in_valid = 1;
                while( sdram_io.out_valid == 0 ) {}

                // WRITE RESULT TO ICACHE or DCACHE
                if( Icache ) {
                    // ICACHE WRITE
                    Icachedata.wdata = sdram_io.data_out;
                    Icachedata.wenable = 1;
                    Icachetag.wenable = 1;
               } else {
                    // DCACHE WRITE
                    Dcachedata.wdata = sdram_io.data_out;
                    Dcachedata.wenable = 1;
                    Dcachetag.wenable = 1;
                }
                busy = 0;
            }
        }

        if( writeflag ) {
            busy = 1;
            if( ( Dcachetag.rdata != address[13,12] ) && ( ( function3 & 3 ) == 0 ) ) {
                // CACHE MISS 8 BIT WRITE
                // READ FROM SDRAM
                sdram_io.rw = 0;
                while( sdram_io.busy ) {}
                sdram_io.addr = address[1,24];
                sdram_io.in_valid = 1;
                while( sdram_io.out_valid == 0 ) {}

                // WRITE RESULT INTO DCACHE
                Dcachedata.wdata = address[0,1] ? { writedata[0,8], sdram_io.data_out[0,8] } : { sdram_io.data_out[8,8], writedata[0,8] };
                Dcachedata.wenable = 1;

                // CHECK IF ENTRY IS IN ICACHE AND UPDATE
                // KEEPS CACHES COHERENT WHEN MEMORY IS MODIFIED
                if( Icachetag.rdata == address[13,12] ) {
                    Icachedata.wdata = Dcachedata.wdata;
                    Icachedata.wenable = 1;
                }

                // WRITE TO SDRAM
                sdram_io.rw = 1;
                while( sdram_io.busy ) {}
                sdram_io.data_in = Dcachedata.wdata;
                sdram_io.addr = address[1,24];
                sdram_io.in_valid = 1;
                busy = 0;
            } else {
                // WRITE INTO CACHE ( 8 BIT WRITE DATA ALREADY IN CACHE )
                switch( function3 & 3 ) {
                    case 2b00: { Dcachedata.wdata = address[0,1] ? { writedata[0,8], Dcachedata.rdata[0,8] } : { Dcachedata.rdata[8,8], writedata[0,8] }; }
                    case 2b01: { Dcachedata.wdata = writedata; }
                    case 2b10: { Dcachedata.wdata = writedata; }
                }
                Dcachedata.wenable = 1; Dcachetag.wenable = 1;

                // CHECK IF ENTRY IS IN ICACHE AND UPDATE
                // KEEPS CACHES COHERENT WHEN MEMORY IS MODIFIED
                if( Icachetag.rdata == address[13,12] ) {
                    Icachedata.wdata = Dcachedata.wdata;
                    Icachedata.wenable = 1;
                }

                // WRITE TO SDRAM
                sdram_io.rw = 1;
                while( sdram_io.busy ) {}
                sdram_io.data_in = Dcachedata.wdata;
                sdram_io.addr = address[1,24];
                sdram_io.in_valid = 1;
                busy = 0;
            }
        }
    }
}
