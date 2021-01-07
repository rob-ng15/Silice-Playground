algorithm fetchloadstore (
    // TO FROM MEMORY INTERFACE
    output  uint32  address,
    output  uint16  writedata,
    output  uint1   writememory,
    input   uint16  readdata,
    output  uint1   readmemory,
    output  uint1   Icacheflag,
    input   uint1   memorybusy,

    // FROM CPU
    input   uint3   function3,
    input   int32   sourceReg2,
    input   uint32  pc,
    input   uint32  loadAddress,
    input   uint32  storeAddress,

    // TO CPU - FETCH
    output  uint32  instruction,
    output  uint1   compressed,

    // TO CPU - LOAD
    output  int32   result,

    // FLAGS
    input   uint1   fetch,
    input   uint1   load,
    input   uint1   store,
    output  uint1   busy
) <autorun> {
    // COMPRESSED INSTRUCTION EXPANDER
    uint32  instruction32 = uninitialized;
    uint1   IScompressed = uninitialized;
    compressedexpansion compressedunit(
        compressed :> IScompressed,
        instruction16 <: readdata,
        instruction32 :> instruction32,
    );

    // COMBINE TWO 16 BIT HALF WORDS TO ONE 32 BIT WORD
    uint16  LOW = uninitialized;
    uint16  HIGH = uninitialized;
    uint32  HIGHLOW = uninitialized;
    halfhalfword combiner161632unit(
        LOW <: LOW,
        HIGH <: HIGH,
        HIGHLOW :> HIGHLOW
    );

    // RISC-V SIGN EXTENSION FOR 8 AND 16 BIT READS
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

    uint1   active = 0;
    busy := ( fetch || load || store ) ? 1 : active;

    // MEMORY ACCESS FLAGS
    readmemory := 0;
    writememory := 0;

    while(1) {
        // FETCH INSTRUCTION / EXPAND 16 BIT COMPRESSED INSTRUCTION
        if( fetch ) {
            active = 1;

            address = pc;
            Icacheflag = 1;
            readmemory = 1;
            while( memorybusy ) {}
            compressed = IScompressed;
            switch( IScompressed ) {
                case 1b0: {
                    // 32 bit instruction
                    LOW = instruction32;
                    address = pc + 2;
                    readmemory = 1;
                    while( memorybusy ) {}
                    HIGH = readdata;
                    instruction = HIGHLOW;
                }
                case 1b1: {
                    // 16 bit compressed instruction
                    instruction = instruction32;
                }
            }

            active = 0;
        }

        if( load ) {
            active = 1;

            address = loadAddress;
            Icacheflag = 0;
            readmemory = 1;
            while( memorybusy ) {}
            switch( function3 & 3 ) {
                case 2b10: {
                    // 32 bit READ as 2 x 16 bit
                    LOW = readdata;
                    address = loadAddress + 2;
                    readmemory = 1;
                    while( memorybusy ) {}
                    HIGH = readdata;
                    result = HIGHLOW;
                }
                default: {
                    // 8/16 bit with optional sign extension
                    result = ( ( function3 & 3 ) == 0 ) ? SE8sign : SE16sign;
                }
            }

            active = 0;
        }

        if( store ) {
            active = 1;

            address = storeAddress;
            Icacheflag = 0;
            writedata = sourceReg2[0,16];
            writememory = 1;
            while( memorybusy ) {}
            if(  ( function3 & 3 ) == 2b10 ) {
                // WRITE UPPER 16 of 32 bits
                address = storeAddress + 2;
                writedata = sourceReg2[16,16];
                writememory = 1;
                while( memorybusy ) {}
            }

            active = 0;
        }
    }
}
