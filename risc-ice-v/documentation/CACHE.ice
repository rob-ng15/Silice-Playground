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

    // INSTRUCTION & DATA CACHES for SDRAM (32mb)
    // CACHE LINE IS LOWER 11 bits ( 0 - 2047 ) of address, dropping the BYTE address bit
    // CACHE TAG IS REMAINING 13 bits of the 25 bit address + 1 bit for valid flag
    bram uint16 Dcachedata<input!>[2048] = uninitialized;
    bram uint14 Dcachetag<input!>[2048] = uninitialized;
    bram uint16 Icachedata<input!>[2048] = uninitialized;
    bram uint14 Icachetag<input!>[2048] = uninitialized;

    // ACTIVE FLAG
    uint1   active = 0;

    // CACHE TAG match flags
    uint1   Icachetagmatch := Icachetag.rdata == { 1b1, address[12,13] };
    uint1   Dcachetagmatch := Dcachetag.rdata == { 1b1, address[12,13] };

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

    // FLAGS FOR CACHE ACCESS
    Dcachedata.wenable := 0; Dcachedata.addr := address[1,11];
    Dcachetag.wenable := 0; Dcachetag.addr := address[1,11]; Dcachetag.wdata := { 1b1, address[12,13] };
    Icachedata.wenable := 0; Icachedata.addr := address[1,11];
    Icachetag.wenable := 0; Icachetag.addr := address[1,11]; Icachetag.wdata := { 1b1, address[12,13] };

    // FLAGS FOR BRAM ACCESS
    ram.wenable := 0;
    ram.addr := address[1,15];

    // RETURN RESULTS FROM BRAM OR CACHE
    // 16 bit READ NO SIGN EXTENSION - INSTRUCTION / PART 32 BIT ACCESS
    readdata := address[28,1] ? ( Icache ? Icachedata.rdata : Dcachedata.rdata ) : ram.rdata;

    // 8/16 bit READ WITH OPTIONAL SIGN EXTENSION
    SE8nosign := address[28,1] ? ( Dcachedata.rdata[address[0,1] ? 8 : 0, 8] ) : ( ram.rdata[address[0,1] ? 8 : 0, 8] );
    SE16nosign := address[28,1] ? Dcachedata.rdata : ram.rdata;
    readdata8 := SE8sign;
    readdata16 := SE16sign;

    while(1) {
        if( readflag && address[28,1] ) {
            // SDRAM
            if( ( Icache && Icachetagmatch ) || Dcachetagmatch ) {
                // CACHE HIT
                active = 0;
            } else {
                // CACHE MISS
                active = 1;

                // READ FROM SDRAM
                //sio.addr = address;
                //sio.rw = 0;
                //sio.in_valid = 1;
                //while( !sio.done ) {}

                // WRITE RESULT TO ICACHE or DCACHE
                Icachetag.wenable = Icache;
                Dcachetag.wenable = ~Icache;
                //Icachedata.wdata = sio.data_out;
                //Icachedata.wenable = Icache;
                //Dcachedata.wdata = sio.data_out;
                //Dcachedata.wenable = ~Icache;

                active = 0;
            }
        }

        if( writeflag ) {
            if( address[28,1] ) {
                // SDRAM
                active = 1;

                // WRITE INTO CACHE
                if( ( function3 & 3 ) == 0 && ~Dcachetagmatch ) {
                    // LOAD INTO CACHE FOR BYTE WRITE
                    // READ FROM SDRAM
                    //sio.addr = address;
                    //sio.rw = 0;
                    //sio.in_valid = 1;
                    //while( !sio.done ) {}

                    // WRITE RESULT TO DCACHE
                    Dcachetag.wenable = 1;
                    //Dcachedata.wdata = sio.data_out;
                    //Dcachedata.wenable = 1;
                    ++:
                }
                Dcachedata.wdata = ( ( function3 & 3 ) == 0 ) ? ( address[0,1] ? { writedata[0,8], Dcachedata.rdata[0,8] } : { Dcachedata.rdata[8,8], writedata[0,8] } ) : writedata;
                Icachedata.wdata = ( ( function3 & 3 ) == 0 ) ? ( address[0,1] ? { writedata[0,8], Dcachedata.rdata[0,8] } : { Dcachedata.rdata[8,8], writedata[0,8] } ) : writedata;
                Dcachedata.wenable = 1;
                Dcachetag.wenable = 1;
                // CHECK IF ENTRY IS IN ICACHE AND UPDATE
                Icachedata.wenable = Icachetagmatch;

                // WRITE TO SDRAM
                //sio.addr = address;
                //sio.data_in = Dcachedata.wdata;
                //sio.rw = 1;
                //sio.in_valid = 1;
                //while( !sio.done ) {}

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
