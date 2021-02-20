// RISC-ICE-V
// inspired by https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice
//
// A simple Risc-V RV32IMC processor ( with partial B extension implementation )

// RISC-V - MAIN CPU LOOP
//          ALU FUNCTIONALITY LISTED IN mathematics.ice

algorithm PAWSCPU (
    input   uint1   clock_cpualu,
    input   uint1   clock_cpufunc,
    input   uint1   clock_cpucache,

    output  uint3   accesssize,
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
    // SMT FLAG
    // RUNNING ON HART 0 OR HART 1
    // DUPLICATES PROGRAM COUNTER, REGISTER FILE AND LAST INSTRUCTION CACHE
    uint1   SMT = 0;

    // RISC-V PROGRAM COUNTERS AND STATUS
    uint32  pc = 0;
    uint32  pcSMT = 0;
    uint32  PC := SMT ? pcSMT : pc;
    uint1   incPC = uninitialized;

    // COMPRESSED INSTRUCTION EXPANDER
    uint32  instruction = uninitialized;
    uint1   compressed = uninitialized;
    compressed00 COMPRESSED00 <@clock_cpufunc> (
        i16 <: readdata
    );
    compressed01 COMPRESSED01 <@clock_cpufunc> (
        i16 <: readdata
    );
    compressed10 COMPRESSED10 <@clock_cpufunc> (
        i16 <: readdata
    );

    // TEMPORARY STORAGE FOR 16 BIT LOWER PART OF 32 BIT WORD
    uint16  lowWord = uninitialized;

    // RISC-V REGISTER WRITER
    int32   result = uninitialized;
    uint1   writeRegister = uninitialized;
    uint32  memoryinput = uninitialized;
    uint32  memoryoutput = uninitialized;
    uint1   memoryload := ( ( opCode == 7b0000011 ) || ( ( opCode == 7b0101111 ) && ( function7[2,5] != 5b00011 ) ) ) ? 1 : 0;
    uint1   memorystore := ( ( opCode == 7b0100011 ) || ( ( opCode == 7b0101111 ) && ( function7[2,5] != 5b00010 ) ) ) ? 1 : 0;

    // RISC-V 32 BIT INSTRUCTION DECODER
    int32   immediateValue = uninitialized;
    uint7   opCode = uninitialized;
    uint3   function3 = uninitialized;
    uint7   function7 = uninitialized;
    uint5   IshiftCount = uninitialized;
    uint5   rs1 = uninitialized;
    uint5   rs2 = uninitialized;
    uint5   rd = uninitialized;
    decoder DECODER <@clock_cpufunc> (
        instruction <: instruction,
        opCode :> opCode,
        function3 :> function3,
        function7 :> function7,
        rs1 :> rs1,
        rs2 :> rs2,
        rd :> rd,
        immediateValue :> immediateValue,
        IshiftCount :> IshiftCount
    );

    // RISC-V REGISTERS
    int32   sourceReg1 = uninitialized;
    int32   sourceReg2 = uninitialized;
    registers REGISTERS(
        SMT <:: SMT,
        rs1 <: rs1,
        rs2 <: rs2,
        rd <: rd,
        result <: result,
        sourceReg1 :> sourceReg1,
        sourceReg2 :> sourceReg2
    );

    // RISC-V ADDRESS GENERATOR
    uint32  nextPC = uninitialized;
    uint32  branchAddress = uninitialized;
    uint32  jumpAddress = uninitialized;
    uint32  loadAddress = uninitialized;
    uint32  storeAddress = uninitialized;
    uint32  AUIPCLUI = uninitialized;
    addressgenerator AGU(
        instruction <: instruction,
        pc <:: PC,
        compressed <: compressed,
        sourceReg1 <: sourceReg1,
        immediateValue <: immediateValue,
        nextPC :> nextPC,
        branchAddress :> branchAddress,
        jumpAddress :> jumpAddress,
        AUIPCLUI :> AUIPCLUI,
        storeAddress :> storeAddress,
        loadAddress :> loadAddress
    );

    // BRANCH COMPARISON UNIT
    uint1   takeBranch = uninitialized;
    branchcomparison BRANCHUNIT(
        opCode <: opCode,
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        takeBranch :> takeBranch
    );

    // ALU
    alu ALU <@clock_cpualu> (
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        IshiftCount <: IshiftCount,
        immediateValue <: immediateValue
    );

    // ATOMIC MEMORY OPERATIONS
    aluA ALUA(
        function7 <: function7,
        memoryinput <: memoryinput,
        sourceReg2 <: sourceReg2
    );

    // MANDATORY RISC-V CSR REGISTERS + HARTID == 0 MAIN THREAD == 1 SMT THREAD
    CSRblock CSR(
        instruction <: instruction,
        SMT <: SMT
    );

    // On CPU instruction cache - MAIN AND SMT THREADS
    instructioncache Icache <@clock_cpucache> (
        PC <: PC,
        SMT <: SMT,
        newinstruction <: instruction,
        newcompressed <: compressed
    );
    Icache.updatecache := 0;

    // MEMORY ACCESS FLAGS
    accesssize := ( opCode == 7b0101111 ) ? 3b010 : function3;
    readmemory := 0;
    writememory := 0;

    // REGISTERS Write FLAG
    REGISTERS.write := 0;

    // ALU START FLAGS
    ALU.start := 0;

    while(1) {
        // RISC-V
        writeRegister = 0;
        //takeBranch = 0;
        incPC = 1;

        // CHECK IF PC IS IN LAST INSTRUCTION CACHE
        if( Icache.incache ) {
            instruction = Icache.instruction;
            compressed = Icache.compressed;
        } else {
            // FETCH + EXPAND COMPRESSED INSTRUCTIONS
            address = PC;
            Icacheflag = 1;
            readmemory = 1;
            while( memorybusy ) {}

            compressed = ( readdata[0,2] != 2b11 );

            switch( readdata[0,2] ) {
                case 2b00: { instruction = COMPRESSED00.i32; }
                case 2b01: { instruction = COMPRESSED01.i32; }
                case 2b10: { instruction = COMPRESSED10.i32; }
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
        }

        // TIME TO ALLOW DECODE + REGISTER FETCH + ADDRESS GENERATION
        ++:
        ++:

        // LOAD FROM MEMORY
        if( memoryload ) {
            address = loadAddress;
            Icacheflag = 0;
            readmemory = 1;
            while( memorybusy ) {}
            switch( accesssize & 3 ) {
                case 2b00: { ( memoryinput ) = signextender8( function3, loadAddress, readdata ); }
                case 2b01: { ( memoryinput ) = signextender16( function3, readdata ); }
                case 2b10: {
                    // 32 bit READ as 2 x 16 bit
                    lowWord = readdata;
                    address = loadAddress + 2;
                    readmemory = 1;
                    while( memorybusy ) {}
                    ( memoryinput ) = halfhalfword( readdata, lowWord );
                }
            }
        }

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
                // BRANCH - HAPPENS IN BRANCH COMPARISON UNIT
            }
            case 5b00000: {
                // LOAD
                writeRegister = 1;
                result = memoryinput;
            }
            case 5b01000: {
                // STORE
                memoryoutput = sourceReg2;
            }
            case 5b11100: {
                // CSR
                writeRegister = 1;
                CSR.start = 1;
                result = CSR.result;
            }
            case 5b01011: {
                // ATOMIC OPERATIONS
                writeRegister = 1;

                switch( function7[2,5] ) {
                    case 5b00010: {
                        // LR.W
                        result = memoryinput;
                    }
                    case 5b00011: {
                        // SC.W
                        memoryoutput = sourceReg2;
                        result = 0;
                    }
                    default: {
                        // ATOMIC LOAD - MODIFY - STORE
                        result = memoryinput;
                        ALUA.start = 1;
                        memoryoutput = ALUA.result;
                    }
                }
            }

            // ALUI or ALUR
            default: {
                writeRegister = 1;

                // START ALU
                ALU.start = 1;
                while( ALU.busy ) {}
                result = ALU.result;
            }
        }

        // STORE TO MEMORY
        if( memorystore ) {
            address = storeAddress;
            Icacheflag = 0;
            writedata = memoryoutput[0,16];
            writememory = 1;
            while( memorybusy ) {}
            if(  ( accesssize & 3 ) == 2b10 ) {
                // WRITE UPPER 16 of 32 bits
                address = storeAddress + 2;
                writedata = memoryoutput[16,16];
                writememory = 1;
                while( memorybusy ) {}
            }
        }

        // REGISTERS WRITE
        REGISTERS.write = ( writeRegister  && ( rd != 0 ) ) ? 1 : 0;

        // UPDATE PC
        if( SMT ) {
            ( pcSMT ) = newPC( opCode, incPC, nextPC, takeBranch, branchAddress, jumpAddress, loadAddress );
        } else {
            ( pc ) = newPC( opCode, incPC, nextPC, takeBranch, branchAddress, jumpAddress, loadAddress );
        }

        // Update CSRinstret
        CSR.incCSRinstret = 1;

        // SWITCH THREADS IF SMT IS RUNNING
        if( SMTRUNNING ) {
            SMT = ~SMT;
        } else {
            // RESET PC COUNTER FOR SMT
            SMT = 0;
            pcSMT = SMTSTARTPC;
        }
    } // RISC-V
}

// ON CPU SMALL INSTRUCTION CACHE
algorithm instructioncache(
    input!  uint32  PC,
    input!  uint1   SMT,

    output  uint1   incache,

    input   uint1   updatecache,
    input   uint32  newinstruction,
    input   uint1   newcompressed,

    output  uint32  instruction,
    output  uint1   compressed
) <autorun> {
    // LAST INSTRUCTION CACHE
    uint32  lastpccache[64] = { 32hffffffff, pad(32hffffffff) };
    uint32  lastinstructioncache[64] = uninitialized;
    uint1   lastcompressedcache[64] = uninitialized;
    uint8   location = 8hff;
    uint5   lastcachepointer = 0;
    uint5   lastcachepointerSMT = 0;
    uint1   LATCHupdate = 0;

    // CHECK IF PC IS IN LAST INSTRUCTION CACHE
    location :=
        $$for i = 0, 30 do
            ( PC == ( lastpccache[ { SMT, 5d$i$ } ] ) ) ? $i$ :
        $$end
        ( PC == ( lastpccache[ { SMT, 5d31 } ] ) ) ? 31 : 8hff;

    incache := ( location == 8hff ) ? 0 : 1;

    // RETRIEVE FROM LAST INSTRUCTION CACHE
    instruction := lastinstructioncache[ ( location == 8hff ) ? 0 : { SMT, location[0,5] } ];
    compressed := lastcompressedcache[ ( location == 8hff ) ? 0 : { SMT, location[0,5] } ];

    while(1) {
        if( updatecache && ~LATCHupdate ) {
            lastpccache[ { SMT, SMT ? lastcachepointerSMT : lastcachepointer } ] = PC;
            lastinstructioncache[ { SMT, SMT ? lastcachepointerSMT : lastcachepointer } ] = newinstruction;
            lastcompressedcache[ { SMT, SMT ? lastcachepointerSMT : lastcachepointer } ] = newcompressed;
            lastcachepointer = lastcachepointer + SMT ? 0 : 1;
            lastcachepointerSMT = lastcachepointerSMT + SMT ? 1 : 0;
        }
        LATCHupdate = updatecache;
    }
}
