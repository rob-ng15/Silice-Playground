// RISC-ICE-V
// inspired by https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice
//
// A simple Risc-V RV32IMC processor ( with partial B extension implementation )

// RISC-V - MAIN CPU LOOP
//          ALU FUNCTIONALITY LISTED IN mathematics.ice

algorithm PAWSCPU (
    output  uint3   function3,
    output  uint32  address,
    output  uint16  writedata,
    output  uint1   writememory,
    input   uint16  readdata,
    output  uint1   readmemory,
    output  uint1   Icacheflag,

    input   uint1   memorybusy,

    input   uint1   SMTRUNNING,
    input   uint32  SMTSTARTPC
) <autorun> {
    // RISC-V REGISTERS
    simple_dualport_bram int32 registers_1 <input!> [64] = { 0, pad(0) };
    simple_dualport_bram int32 registers_2 <input!> [64] = { 0, pad(0) };
    simple_dualport_bram int32 registers_3 <input!> [64] = { 0, pad(0) };

    // SMT FLAG
    // RUNNING ON HART 0 OR HART 1
    // DUPLICATES PROGRAM COUNTER, REGISTER FILE AND LAST INSTRUCTION CACHE
    uint1   SMT = 0;

    // RISC-V PROGRAM COUNTERS AND STATUS
    uint32  pc = 0;
    uint32  pcSMT = 0;
    uint32  PC := SMT ? pcSMT : pc;
    uint32  nextPC = uninitialized;
    uint1   compressed = uninitialized;
    uint1   takeBranch = uninitialized;
    uint1   incPC = uninitialized;
    uint32  instruction = uninitialized;

    // TEMPORARY STORAGE FOR 16 BIT lowWordER PART OF 32 BIT WORD
    uint16  lowWord = uninitialized;

    // RISC-V REGISTER WRITER
    int32   result = uninitialized;
    int32   Aresult = uninitialized;
    uint1   writeRegister = uninitialized;

    // RISC-V REGISTER READER
    int32   sourceReg1 = uninitialized;
    int32   sourceReg2 = uninitialized;
    int32   sourceReg3 = uninitialized;

    // RISC-V 32 BIT INSTRUCTION DECODER
    int32   immediateValue = uninitialized;
    uint7   opCode = uninitialized;
    uint7   function7 = uninitialized;
    uint5   IshiftCount = uninitialized;
    uint5   rs1 = uninitialized;
    uint5   rs2 = uninitialized;
    uint5   rs3 = uninitialized;
    uint5   rd = uninitialized;

    // RISC-V ADDRESS GENERATOR
    uint32  branchAddress = uninitialized;
    uint32  jumpAddress = uninitialized;
    uint32  loadAddress = uninitialized;
    uint32  storeAddress = uninitialized;
    uint32  AUIPCLUI = uninitialized;

    // CSR REGISTERS
    CSRblock CSR(
        instruction <: instruction,
        SMT <: SMT
    );

    // LAST INSTRUCTION CACHE FOR MAIN AND SMT THREAD
    uint32  lastpccache[32] = { 32hffffffff, pad(32hffffffff) };
    uint32  lastinstructioncache[32] = uninitialized;
    uint1   lastcompressedcache[32] = uninitialized;
    uint5   lastcachepointer = 0;

    uint32  lastpccacheSMT[32] = { 32hffffffff, pad(32hffffffff) };
    uint32  lastinstructioncacheSMT[32] = uninitialized;
    uint1   lastcompressedcacheSMT[32] = uninitialized;
    uint5   lastcachepointerSMT = 0;

    // MEMORY ACCESS FLAGS
    readmemory := 0;
    writememory := 0;

    // REGISTER Read/Write Flags
    registers_1.wenable1 := 1;
    registers_2.wenable1 := 1;
    registers_3.wenable1 := 1;

    // CSR instructions retired increment flag
    CSR.incCSRinstret := 0;

    while(1) {
        // RISC-V
        writeRegister = 0;
        takeBranch = 0;
        incPC = 1;

        // CHECK IF PC IS IN LAST INSTRUCTION CACHE
        if(
            $$for i = 0, 30 do
                ( PC == ( SMT ? lastpccacheSMT[ $i$ ] : lastpccache[ $i$ ] ) ) ||
            $$end
            ( PC == ( SMT ? lastpccacheSMT[ 31 ] : lastpccache[ 31 ] ) ) ) {
                // RETRIEVE FROM LAST INSTRUCTION CACHE
                instruction = ( PC == ( SMT ? lastpccacheSMT[ 0 ] : lastpccache[ 0 ] ) ) ? ( SMT ? lastinstructioncacheSMT[ 0 ] : lastinstructioncache[ 0 ] ) :
                                $$for i = 1, 30 do
                                    ( PC == ( SMT ? lastpccacheSMT[ $i$ ] : lastpccache[ $i$ ] ) ) ? ( SMT ? lastinstructioncacheSMT[ $i$ ] : lastinstructioncache[ $i$ ] ) :
                                $$end
                                ( SMT ? lastinstructioncacheSMT[ 31 ] : lastinstructioncache[ 31 ] );

                compressed = ( PC == ( SMT ? lastpccacheSMT[ 0 ] : lastpccache[ 0 ] ) ) ? ( SMT ? lastcompressedcacheSMT[ 0 ] : lastcompressedcache[ 0 ] ) :
                                $$for i = 1, 30 do
                                    ( PC == ( SMT ? lastpccacheSMT[ $i$ ] : lastpccache[ $i$ ] ) ) ? ( SMT ? lastcompressedcacheSMT[ $i$ ] : lastcompressedcache[ $i$ ] ) :
                                $$end
                                ( SMT ? lastcompressedcacheSMT[ 31 ] : lastcompressedcache[ 31 ] );
        } else {
            // FETCH + EXPAND COMPRESSED INSTRUCTIONS
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
            if( SMT ) {
                lastpccacheSMT[ lastcachepointerSMT ] = pcSMT;
                lastinstructioncacheSMT[ lastcachepointerSMT ] = instruction;
                lastcompressedcacheSMT[ lastcachepointerSMT ] = compressed;
                lastcachepointerSMT = lastcachepointerSMT + 1;
            } else {
                lastpccache[ lastcachepointer ] = pc;
                lastinstructioncache[ lastcachepointer ] = instruction;
                lastcompressedcache[ lastcachepointer ] = compressed;
                lastcachepointer = lastcachepointer + 1;
            }
        }

        // DECODE + REGISTER FETCH
        // HAPPENS AUTOMATICALLY in DECODE AND REGISTER UNITS
        ( opCode, function3, function7, rs1, rs2, rs3, rd, immediateValue, IshiftCount ) = decoder( instruction );
        ( registers_1, registers_2, registers_3, sourceReg1, sourceReg2, sourceReg3 ) = registersREAD( registers_1, registers_2, registers_3, rs1, rs2, rs3, SMT );
        ( nextPC, branchAddress, jumpAddress, AUIPCLUI, storeAddress, loadAddress ) = addressgenerator( opCode, PC, compressed, sourceReg1, immediateValue );

        // EXECUTE
        switch( opCode[2,5] ) {
            case 5b01101: {
                // LUI
                writeRegister = 1;
                result = AUIPCLUI;
            }
            case 5b00101: {
                // AUIPC
                writeRegister = 1;
                result = AUIPCLUI;
            }
            case 5b11011: {
                // JAL
                writeRegister = 1;
                incPC = 0;
                result = nextPC;
            }
            case 5b11001: {
                // JALR
                writeRegister = 1;
                incPC = 0;
                result = nextPC;
            }
            case 5b11000: {
                // BRANCH
                ( takeBranch ) = branchcomparison( opCode, function3, sourceReg1, sourceReg2 );
            }
            case 5b00000: {
                // LOAD
                writeRegister = 1;
                address = loadAddress;
                Icacheflag = 0;
                readmemory = 1;
                while( memorybusy ) {}
                switch( function3 & 3 ) {
                    case 2b00: { ( result ) = signextender8( function3, loadAddress, readdata ); }
                    case 2b01: { ( result ) = signextender16( function3, readdata ); }
                    case 2b10: {
                        // 32 bit READ as 2 x 16 bit
                        lowWord = readdata;
                        address = loadAddress + 2;
                        readmemory = 1;
                        while( memorybusy ) {}
                        ( result ) = halfhalfword( readdata, lowWord );
                    }
                }
            }
            case 5b01000: {
                // STORE
                // WRITE 8, 16 and LOWER 16 of 32 bits
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
            }
            case 5b00100: {
                // ALUI ( BASE + SOME B EXTENSION )
                writeRegister = 1;
                ( result ) = aluI( opCode, function3, function7, immediateValue, IshiftCount, sourceReg1, sourceReg3 );
            }
            case 5b01100: {
                // ALUR ( BASE + M EXTENSION + SOME B EXTENSION )
                writeRegister = 1;
                switch( function7 ) {
                    case 7b0000001: {
                        switch( function3[2,1] ) {
                            case 1b0: { ( result ) = multiplication( function3, sourceReg1, sourceReg2 ); }
                            case 1b1: { ( result ) = divideremainder( function3, sourceReg1, sourceReg2 ); }
                        }
                    }
                    default: { ( result ) = aluR( opCode, function3, function7, rs1, sourceReg1, sourceReg2, sourceReg3 ); }
                }
            }
            case 5b11100: {
                // CSR
                writeRegister = 1;
                result = CSR.result;
            }
            case 5b01011: {
                // ATOMIC OPERATIONS
                switch( function7[2,5] ) {
                    case 5b00010: {
                        // LR.W
                        writeRegister = 1;
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
                        ( result ) = halfhalfword( readdata, lowWord );

                        ( Aresult ) = aluA( function7, result, sourceReg2 );

                        // STORE 32 bit
                        address = sourceReg1;
                        writedata = Aresult[0,16];
                        writememory = 1;
                        while( memorybusy ) {}
                        address = sourceReg1 + 2;
                        writedata = Aresult[16,16];
                        writememory = 1;
                        while( memorybusy ) {}
                    }
                }
            }
        }

        // DISPATCH INSTRUCTION
        ( registers_1, registers_2, registers_3 ) = registersWRITE( registers_1, registers_2, registers_3, rd, writeRegister, SMT, result );
        if( SMT ) {
            ( pcSMT ) = newPC( opCode, incPC, nextPC, takeBranch, branchAddress, jumpAddress, loadAddress );
        } else {
            ( pc ) = newPC( opCode, incPC, nextPC, takeBranch, branchAddress, jumpAddress, loadAddress );
        }

        // Update CSRinstret
        CSR.incCSRinstret = 1;

        // UPDATE MAIN OR SMT
        if( SMTRUNNING ) {
            SMT = ~SMT;
        } else {
            // RESET PC COUNTER FOR SMT
            SMT = 0;
            pcSMT = SMTSTARTPC;
        }
    } // RISC-V
}
