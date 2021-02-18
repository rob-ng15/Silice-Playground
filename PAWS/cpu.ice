// RISC-ICE-V
// inspired by https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice
//
// A simple Risc-V RV32IMC processor ( with partial B extension implementation )

// RISC-V - MAIN CPU LOOP
//          ALU FUNCTIONALITY LISTED IN mathematics.ice

algorithm PAWSCPU (
    input   uint1   clock_cpualu,
    input   uint1   clock_cpufunc,

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
    compressed00 COMPRESSED00(
        i16 <: readdata
    );
    compressed01 COMPRESSED01(
        i16 <: readdata
    );
    compressed10 COMPRESSED10(
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
    decoder DECODER(
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

    // ALU BLOCKS
    uint1   ALUIorR := ( opCode == 7b0010011 ) ? 1 : 0;

    // SHIFTERS
    uint32  LSHIFToutput = uninitialized;
    uint32  RSHIFToutput = uninitialized;
    uint32  ROTATEoutput = uninitialized;
    uint32  SBSCIoutput = uninitialized;
    uint5   shiftcount := ALUIorR ? IshiftCount : sourceReg2[0,5];
    BSHIFTleft LEFTSHIFT <@clock_cpualu> (
        sourceReg1 <: sourceReg1,
        shiftcount <: shiftcount,
        function7 <: function7,
        result :> LSHIFToutput
    );
    BSHIFTright RIGHTSHIFT <@clock_cpualu> (
        sourceReg1 <: sourceReg1,
        shiftcount <: shiftcount,
        function7 <: function7,
        result :> RSHIFToutput
    );
    BROTATE ROTATE <@clock_cpualu> (
        sourceReg1 <: sourceReg1,
        shiftcount <: shiftcount,
        function3 <: function3,
        result :> ROTATEoutput
    );
    singlebitops SBSCI <@clock_cpualu> (
        sourceReg1 <: sourceReg1,
        function7 <: function7,
        shiftcount <: shiftcount,
        result :> SBSCIoutput
    );

    // SHARED MULTICYCLE BIT MANIPULATION OPERATIONS
    uint32  SHFLUNSHFLoutput = uninitialized;
    uint1   SHFLUNSHFLbusy = uninitialized;
    shflunshfl SHFLUNSHFL <@clock_cpualu> (
        sourceReg1 <: sourceReg1,
        shiftcount <: shiftcount,
        function3 <: function3,
        busy :> SHFLUNSHFLbusy,
        result :> SHFLUNSHFLoutput
    );
    uint32  GREVGORCoutput = uninitialized;
    uint1   GREVGORCbusy = uninitialized;
    grevgorc GREVGORC <@clock_cpualu> (
        sourceReg1 <: sourceReg1,
        shiftcount <: shiftcount,
        function7 <: function7,
        busy :> GREVGORCbusy,
        result :> GREVGORCoutput
    );

    // ATOMIC MEMORY OPERATIONS
    aluA ALUA(
        function7 <: function7,
        memoryinput <: memoryinput,
        sourceReg2 <: sourceReg2
    );

    // BASE REGISTER + IMMEDIATE ALU OPERATIONS + B EXTENSION OPERATIONS
    aluI ALUI <@clock_cpualu> (
        function3 <: function3,
        function7 <: function7,
        IshiftCount <: IshiftCount,
        sourceReg1 <: sourceReg1,
        immediateValue <: immediateValue,

        LSHIFToutput <: LSHIFToutput,
        RSHIFToutput <: RSHIFToutput,
        ROTATEoutput <: ROTATEoutput,
        SBSCIoutput <: SBSCIoutput,

        SHFLUNSHFLoutput <: SHFLUNSHFLoutput,
        SHFLUNSHFLbusy <: SHFLUNSHFLbusy,
        GREVGORCoutput <: GREVGORCoutput,
        GREVGORCbusy <: GREVGORCbusy
    );

    // BASE REGISTER & REGISTER ALU OPERATIONS + B EXTENSION OPERATIONS
    aluR ALUR <@clock_cpualu> (
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,

        LSHIFToutput <: LSHIFToutput,
        RSHIFToutput <: RSHIFToutput,
        ROTATEoutput <: ROTATEoutput,
        SBSCIoutput <: SBSCIoutput,

        SHFLUNSHFLoutput <: SHFLUNSHFLoutput,
        SHFLUNSHFLbusy <: SHFLUNSHFLbusy,
        GREVGORCoutput <: GREVGORCoutput,
        GREVGORCbusy <: GREVGORCbusy
    );

    // MANDATORY RISC-V CSR REGISTERS + HARTID == 0 MAIN THREAD == 1 SMT THREAD
    CSRblock CSR(
        instruction <: instruction,
        SMT <: SMT
    );

    // On CPU instruction cache
    instructioncache Icache(
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
    ALUA.start := 0;
    ALUI.start := 0;
    ALUR.start := 0;
    CSR.start := 0;
    CSR.incCSRinstret := 0;
    LEFTSHIFT.start := 0;
    RIGHTSHIFT.start := 0;
    ROTATE.start := 0;
    SBSCI.start := 0;
    SHFLUNSHFL.start := 0;
    GREVGORC.start := 0;

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

                // START SHIFTERS
                LEFTSHIFT.start = 1;
                RIGHTSHIFT.start = 1;
                ROTATE.start = 1;
                SBSCI.start = 1;

                // START SHARED MULTICYCLE BLOCKS - SHFL UNSHFL GORC GREV
                SHFLUNSHFL.start = ( ( ( function3 == 3b001 ) || ( function3 == 3b101 ) ) && ( function7 == 7b0000100 ) ) ? 1 : 0;
                GREVGORC.start = ( ( function3 == 3b101 ) && ( ( function7 == 7b0110100 ) || ( function7 == 7b0010100 ) ) ) ? 1 : 0;

                // START ALUI or ALUR
                ALUI.start = ALUIorR;
                ALUR.start = ~ALUIorR;
                while( ALUI.busy || ALUR.busy ) {}
                result = ALUIorR ? ALUI.result : ALUR.result;
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
    input   uint32  PC,
    input   uint1   SMT,
    output  uint1   incache,

    input   uint1   updatecache,
    input   uint32  newinstruction,
    input   uint1   newcompressed,

    output  uint32  instruction,
    output  uint1   compressed
) <autorun> {
    // LAST INSTRUCTION CACHE FOR MAIN AND SMT THREAD
    uint32  lastpccache[64] = { 32hffffffff, pad(32hffffffff) };
    uint32  lastinstructioncache[64] = uninitialized;
    uint1   lastcompressedcache[64] = uninitialized;
    uint5   lastcachepointer = 0;
    uint5   lastcachepointerSMT = 0;

    uint6   pointer := SMT ? { 1b1, lastcachepointerSMT } : { 1b0, lastcachepointer };

    // CHECK IF PC IS IN LAST INSTRUCTION CACHE
    incache :=
        $$for i = 0, 30 do
            ( PC == ( lastpccache[ { SMT, 5d$i$ } ] ) ) ||
        $$end
        ( PC == ( lastpccache[ { SMT, 5b11111 } ] ) );

    // RETRIEVE FROM LAST INSTRUCTION CACHE
    instruction := ( PC == ( lastpccache[ { SMT, 5b00000 } ] ) ) ? ( lastinstructioncache[ { SMT, 5b00000 } ] ) :
                    $$for i = 1, 30 do
                        ( PC == ( lastpccache[ { SMT, 5d$i$ } ] ) ) ? ( lastinstructioncache[ { SMT, 5d$i$ } ] ) :
                    $$end
                    ( lastinstructioncache[ { SMT, 5b11111 } ] );

    compressed := ( PC == ( lastpccache[ { SMT, 5b00000 } ] ) ) ? ( lastcompressedcache[ { SMT, 5b00000 } ] ) :
                    $$for i = 1, 30 do
                        ( PC == ( lastpccache[ { SMT, 5d$i$ } ] ) ) ? ( lastcompressedcache[ { SMT, 5d$i$ }  ] ) :
                    $$end
                    ( lastcompressedcache[ { SMT, 5b11111 } ] );

    while(1) {
        if( updatecache ) {
            lastpccache[ pointer ] = PC;
            lastinstructioncache[  pointer ] = newinstruction;
            lastcompressedcache[  pointer ] = newcompressed;

            if( SMT ) {
                lastcachepointerSMT = lastcachepointerSMT + 1;
            } else {
                lastcachepointer = lastcachepointer + 1;
            }
        }
    }
}
