algorithm fetchloadstore(
    // FROM MEMORY UNITS
    output  uint3   size,
    output  uint32  address,
    output  uint16  writedata,
    output  uint1   writememory,
    input   uint16  readdata,
    output  uint1   readmemory,
    output  uint1   Icacheflag,
    input   uint1   memorybusy,

    // TO/FROM CPU
    input   uint32  PC,
    input   uint1   SMT,
    input   uint3   function3,
    input   uint32  loadAddress,
    input   uint32  storeAddress,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,

    output  uint32  result,
    output  uint32  instruction,
    output  uint1   compressed,

    input   uint1   fetch,
    input   uint1   load,
    input   uint1   AMOload,
    input   uint1   store,
    input   uint1   AMOstore,
    output  uint1   busy
) <autorun> {
    // On CPU instruction cache
    instructioncache Icache(
        PC <: PC,
        SMT <: SMT,
        newinstruction <: instruction,
        newcompressed <: compressed
    );

    // TEMPORARY STORAGE FOR 16 BIT lower PART OF 32 BIT WORD
    uint16  lowWord = uninitialized;

    // MEMORY ACCESS FLAGS
    readmemory := 0;
    writememory := 0;

    // INSTRUCTION CACHE UPDATE FLAG
    Icache.updatecache := 0;

    while(1) {
        if( fetch ) {
            // CHECK IF PC IS IN LAST INSTRUCTION CACHE
            if( Icache.incache ) {
                instruction = Icache.instruction;
                compressed = Icache.compressed;
            } else {
                // FETCH + EXPAND COMPRESSED INSTRUCTIONS
                busy = 1;

                address = PC;
                Icacheflag = 1;
                readmemory = 1;
                while( memorybusy ) {}

                compressed = ( readdata[0,2] != 2b11 );

                switch( readdata[0,2] ) {
                    case 2b00: { ( instruction ) = compressed00( readdata ); }
                    case 2b01: { ( instruction ) = compressed01( readdata ); }
                    case 2b10: { ( instruction ) = compressed10( readdata ); }
                    case 2b11: {
                        // 32 BIT INSTRUCTION
                        lowWord = readdata;
                        address = PC + 2;
                        readmemory = 1;
                        while( memorybusy ) {}
                        ( instruction ) = halfhalfword( readdata, lowWord );
                    }
                }

                // UPDATE LASTCACHE
                Icache.updatecache = 1;

                busy = 0;
            }
        }

        if( AMOload || load ) {
            // LOAD
            busy = 1;

            address = AMOload ? sourceReg1 : loadAddress;
            size = AMOload ? 3b010 : function3;

            Icacheflag = 0;
            readmemory = 1;
            while( memorybusy ) {}
            switch( function3 & 3 ) {
                case 2b00: { ( result ) = signextender8( function3, loadAddress, readdata ); }
                case 2b01: { ( result ) = signextender16( function3, readdata ); }
                case 2b10: {
                    // 32 bit READ as 2 x 16 bit
                    lowWord = readdata;
                    address = address + 2;
                    readmemory = 1;
                    while( memorybusy ) {}
                    ( result ) = halfhalfword( readdata, lowWord );
                }
            }

            busy = 0;
        }

        if( AMOstore || store ) {
            // STORE
            busy = 1;

            // WRITE 8, 16 and LOWER 16 of 32 bits
            address = AMOstore ? sourceReg1 : storeAddress;
            size = AMOstore ? 3b010 : function3;

            Icacheflag = 0;
            writedata = sourceReg2[0,16];
            writememory = 1;
            while( memorybusy ) {}
            if(  ( function3 & 3 ) == 2b10 ) {
                // WRITE UPPER 16 of 32 bits
                address = address + 2;
                writedata = sourceReg2[16,16];
                writememory = 1;
                while( memorybusy ) {}
            }

            busy = 0;
        }
    }
}

            case 5b01011: {
                // ATOMIC OPERATIONS
                switch( function7[2,5] ) {
                    case 5b00010: {
                        // LR.W
                        writeRegister = 1;
                        Icacheflag = 0;

                        // LOAD 32 bit
                        address = sourceReg1;
                        readmemory = 1;
                        while( memorybusy ) {}
                        lowWord = readdata;
                        address = sourceReg1 + 2;
                        readmemory = 1;
                        while( memorybusy ) {}
                        ( result ) = halfhalfword( readdata, lowWord );
                    }
                    case 5b00011: {
                        // SC.W
                        writeRegister = 1;
                        Icacheflag = 0;
                        result = 0;

                        address = sourceReg1;
                        writedata = sourceReg2[0,16];
                        writememory = 1;
                        while( memorybusy ) {}
                        address = sourceReg1 + 2;
                        writedata = sourceReg2[16,16];
                        writememory = 1;
                        while( memorybusy ) {}
                    }
                    default: {
                        // ATOMIC LOAD - MODIFY - STORE
                        writeRegister = 1;
                        Icacheflag = 0;

                        // LOAD 32 bit
                        address = sourceReg1;
                        readmemory = 1;
                        while( memorybusy ) {}
                        lowWord = readdata;
                        address = sourceReg1 + 2;
                        readmemory = 1;
                        while( memorybusy ) {}
                        ( AMOmemory ) = halfhalfword( readdata, lowWord );

                        ALUA.start = 1;

                        // STORE 32 bit
                        address = sourceReg1;
                        writedata = ALUA.result[0,16];
                        writememory = 1;
                        while( memorybusy ) {}
                        address = sourceReg1 + 2;
                        writedata = ALUA.result[16,16];
                        writememory = 1;
                        while( memorybusy ) {}
                    }
                }
            }

            case 5b01011: {
                // ATOMIC OPERATIONS
                switch( function7[2,5] ) {
                    case 5b00010: {
                        // LR.W
                        writeRegister = 1;
                        FLS.AMOload = 1;
                        while( FLS.busy ) {}
                        result = FLS.result;
                    }
                    case 5b00011: {
                        // SC.W
                        writeRegister = 1;
                        result = 0;
                        FLS.AMOstore = 1;
                        while( FLS.busy ) {}
                    }
                    default: {
                        // ATOMIC LOAD - MODIFY - STORE
                        writeRegister = 1;

                        FLS.AMOload = 1;
                        while( FLS.busy ) {}
                        AMOmemory = FLS.result;

                        ALUA.start = 1;

                        // Need a mechanism to pass the result to FLS
                        FLS.AMOstore = 1;
                        while( FLS.busy ) {}
                    }
                }
            }
