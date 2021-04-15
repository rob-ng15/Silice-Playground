// RISC-ICE-V
// inspired by https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice
//
// A simple Risc-V RV32IMC processor ( with partial B extension implementation )

// RISC-V - MAIN CPU LOOP
//          ALU FUNCTIONALITY LISTED IN mathematics.ice

// CPU FETCH 16 bit WORD FROM MEMORY FOR INSTRUCTION BUILDING
circuitry fetch( input location, input memorybusy, output address, output readmemory ) {
    address = location;
    readmemory = 1;
    while( memorybusy ) {}
}
// CPU LOAD FROM MEMORY
circuitry load( input accesssize, input location, input memorybusy, input readdata, output address, output readmemory, output memoryinput ) {
    address = location;
    readmemory = 1;
    while( memorybusy ) {}
    switch( accesssize[0,2] ) {
        case 2b00: { ( memoryinput ) = signextender8( accesssize, location, readdata ); }
        case 2b01: { ( memoryinput ) = signextender16( accesssize, readdata ); }
        case 2b10: {
            // 32 bit READ as 2 x 16 bit
            memoryinput[0,16] = readdata;
            address = location + 2;
            readmemory = 1;
            while( memorybusy ) {}
            memoryinput[16,16] = readdata;
        }
    }
}
// CPU STORE TO MEMORY
circuitry store( input accesssize, input location, input value, input memorybusy, output address, output writedata,  output writememory ) {
    address = location;
    writedata = value[0,16];
    writememory = 1;
    while( memorybusy ) {}
    if( accesssize[0,2] == 2b10 ) {
        address = location + 2;
        writedata = value[16,16];
        writememory = 1;
        while( memorybusy ) {}
    }
}

algorithm PAWSCPU(
    input   uint1   clock_CPUdecoder,
    input   uint1   clock_CPUcache,

    output  uint3   accesssize,
    output  uint32  address,
    output  uint16  writedata,
    output  uint1   writememory,
    input   uint16  readdata,
    output  uint1   readmemory,

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
    uint32  PCplus2 := PC + 2;
    uint1   incPC = uninitialized;

    // COMPRESSED INSTRUCTION EXPANDER
    uint32  instruction = uninitialized;
    uint1   compressed = uninitialized;
    compressed COMPRESSED <@clock_CPUdecoder> (
        i16 <: readdata
    );

    // RISC-V REGISTER WRITER
    int32   result = uninitialized;
    uint1   writeRegister = uninitialized;
    uint32  memoryinput = uninitialized;
    uint32  memoryoutput = uninitialized;
    uint1   memoryload := ( ( opCode == 7b0000011 ) || ( opCode == 7b0000111 ) || ( ( opCode == 7b0101111 ) && ( function7[2,5] != 5b00011 ) ) ) ? 1 : 0;
    uint1   memorystore := ( ( opCode == 7b0100011 ) || ( opCode == 7b0100111 ) || ( ( opCode == 7b0101111 ) && ( function7[2,5] != 5b00010 ) ) ) ? 1 : 0;

    // RISC-V 32 BIT INSTRUCTION DECODER
    int32   immediateValue = uninitialized;
    uint7   opCode = uninitialized;
    uint2   function2 = uninitialized;
    uint3   function3 = uninitialized;
    uint7   function7 = uninitialized;
    uint5   IshiftCount = uninitialized;
    uint5   rs1 = uninitialized;
    uint5   rs2 = uninitialized;
    uint5   rs3 = uninitialized;
    uint5   rd = uninitialized;
    decoder DECODER <@clock_CPUdecoder> (
        instruction <: instruction,
        opCode :> opCode,
        function2 :> function2,
        function3 :> function3,
        function7 :> function7,
        rs1 :> rs1,
        rs2 :> rs2,
        rs3 :> rs3,
        rd :> rd,
        immediateValue :> immediateValue,
        IshiftCount :> IshiftCount
    );

    // RISC-V REGISTERS
    int32   sourceReg1 = uninitialized;
    int32   sourceReg2 = uninitialized;
    int32   sourceReg3 = uninitialized;
    registers REGISTERS(
        SMT <:: SMT,
        rs1 <: rs1,
        rs2 <: rs2,
        rs3 <: rs3,
        rd <: rd,
        result <: result,
        sourceReg1 :> sourceReg1,
        sourceReg2 :> sourceReg2,
        sourceReg3 :> sourceReg3
    );
    // RISC-V FLOATING POINT REGISTERS
    uint32  sourceReg1F = uninitialized;
    uint32  sourceReg2F = uninitialized;
    uint32  sourceReg3F = uninitialized;
    uint1   frd = uninitialized;
    registers REGISTERSF(
        SMT <:: SMT,
        rs1 <: rs1,
        rs2 <: rs2,
        rs3 <: rs3,
        rd <: rd,
        result <: result,
        sourceReg1 :> sourceReg1F,
        sourceReg2 :> sourceReg2F,
        sourceReg3 :> sourceReg3F
    );

    // RISC-V ADDRESS GENERATOR
    uint32  nextPC = uninitialized;
    uint32  branchAddress = uninitialized;
    uint32  jumpAddress = uninitialized;
    uint32  loadAddress = uninitialized;
    uint32  loadAddressplus2 := loadAddress + 2;
    uint32  storeAddress = uninitialized;
    uint32  storeAddressplus2 := storeAddress + 2;
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
    alu ALU(
        opCode <: opCode,
        function2 <: function2,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        sourceReg3 <: sourceReg3,
        IshiftCount <: IshiftCount,
        immediateValue <: immediateValue
    );

    // ATOMIC MEMORY OPERATIONS
    aluA ALUA(
        function7 <: function7,
        memoryinput <: memoryinput,
        sourceReg2 <: sourceReg2
    );

    // FLOATING POINT OPERATIONS
    fpu FPU(
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        rs2 <: rs2,
        sourceReg1 <: sourceReg1,
        sourceReg1F <: sourceReg1F,
        sourceReg2F <: sourceReg2F,
        sourceReg3F <: sourceReg3F,
    );

    // MANDATORY RISC-V CSR REGISTERS + HARTID == 0 MAIN THREAD == 1 SMT THREAD
    CSRblock CSR(
        instruction <: instruction,
        SMT <: SMT
    );

    // On CPU instruction cache - MAIN AND SMT THREADS
    instructioncache Icache <@clock_CPUcache> (
        PC <: pc,
        newinstruction <: instruction,
        newcompressed <: compressed
    );
    instructioncache IcacheSMT <@clock_CPUcache> (
        PC <: pcSMT,
        newinstruction <: instruction,
        newcompressed <: compressed
    );
    Icache.updatecache := 0;
    IcacheSMT.updatecache := 0;

    // MEMORY ACCESS FLAGS
    accesssize := ( ( opCode == 7b0101111 ) || ( opCode == 7b0000111 ) || ( opCode == 7b0100111 ) ) ? 3b010 : function3;
    readmemory := 0;
    writememory := 0;

    // REGISTERS Write FLAG
    REGISTERS.write := 0;

    // ALU START FLAGS
    ALU.start := 0;
    FPU.start := 0;
    CSR.incCSRinstret := 0;

    while(1) {
        // RISC-V - RESET FLAGS
        writeRegister = 1;
        incPC = 1;
        frd = 0;

        // CHECK IF PC IS IN LAST INSTRUCTION CACHE
        if( SMT ? IcacheSMT.incache : Icache.incache ) {
            instruction = SMT ? IcacheSMT.instruction : Icache.instruction;
            compressed = SMT ? IcacheSMT.compressed : Icache.compressed;
        } else {
            // FETCH + EXPAND COMPRESSED INSTRUCTIONS
            ( address, readmemory ) = fetch( PC, memorybusy );
            compressed = ( readdata[0,2] != 2b11 );
            switch( readdata[0,2] ) {
                default: { instruction = COMPRESSED.i32; }
                case 2b11: {
                    // 32 BIT INSTRUCTION
                    instruction[0,16] = readdata;
                    ( address, readmemory ) = fetch( PCplus2, memorybusy );
                    instruction[16,16] = readdata;
                }
            }

            // UPDATE LASTCACHE
            Icache.updatecache = SMT ? 0 : 1;
            IcacheSMT.updatecache = SMT ? 1 : 0;
        }

        // TIME TO ALLOW DECODE + REGISTER FETCH + ADDRESS GENERATION
        ++:
        ++:
        ++:

        // LOAD FROM MEMORY
        if( memoryload ) {
            ( address, readmemory, memoryinput ) = load( accesssize, loadAddress, memorybusy, readdata );
        }

        // EXECUTE
        switch( opCode[2,5] ) {
            case 5b01101: {
                // LUI
                result = AUIPCLUI;
            }
            case 5b00101: {
                // AUIPC
                result = AUIPCLUI;
            }
            case 5b11011: {
                // JAL
                incPC = 0;
                result = nextPC;
            }
            case 5b11001: {
                // JALR
                incPC = 0;
                result = nextPC;
            }
            case 5b11000: {
                // BRANCH - HAPPENS IN BRANCH COMPARISON UNIT
                writeRegister = 0;
            }
            case 5b00000: {
                // LOAD
                result = memoryinput;
            }
            case 5b01000: {
                // STORE
                writeRegister = 0;
                memoryoutput = sourceReg2;
            }
            case 5b00001: {
                // FLOATING POINT LOAD
                frd = 1;
                result = memoryinput;
            }
            case 5b01001: {
                // FLOATING POINT STORE
                writeRegister = 0;
                memoryoutput = sourceReg2F;
            }
            case 5b11100: {
                // CSR
                result = CSR.result;
            }
            case 5b01011: {
                // ATOMIC OPERATIONS
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
                        memoryoutput = ALUA.result;
                    }
                }
            }

            // FPU, ALUI or ALUR
            default: {
                // START ALU/FPU
                switch( opCode[6,1] ) {
                    case 0: {
                        ALU.start = 1;
                        while( ALU.busy ) {}
                        result = ALU.result;
                    }
                    case 1: {
                        FPU.start = 1;
                        while( FPU.busy ) {}
                        frd = FPU.frd;
                        result = FPU.result;
                    }
                }
            }
        }

        // REGISTERS WRITE
        REGISTERS.write = ( writeRegister  && ( rd != 0 ) ) ? ~frd : 0;
        REGISTERSF.write = ( writeRegister  && ( rd != 0 ) ) ? frd : 0;

        // Update CSRinstret
        CSR.incCSRinstret = 1;

        // UPDATE PC + SWITCH THREADS IF SMT ENABLED
        if( SMT ) {
            ( pcSMT ) = newPC( opCode, incPC, nextPC, takeBranch, branchAddress, jumpAddress, loadAddress );
            SMT = 0;
        } else {
            ( pc ) = newPC( opCode, incPC, nextPC, takeBranch, branchAddress, jumpAddress, loadAddress );
            SMT = SMTRUNNING;
            pcSMT = SMTRUNNING ? pcSMT : SMTSTARTPC;
        }

         // STORE TO MEMORY
        if( memorystore ) {
            ( address, writedata, writememory ) = store( accesssize, storeAddress, memoryoutput, memorybusy );
        }
   } // RISC-V
}

// ON CPU SMALL INSTRUCTION CACHE
algorithm instructioncache(
    input   uint32  PC,

    output  uint1   incache,

    input   uint1   updatecache,
    input   uint32  newinstruction,
    input   uint1   newcompressed,

    output  uint32  instruction,
    output  uint1   compressed
) <autorun> {
    // LAST INSTRUCTION CACHE
    uint3   location = uninitialized;
    uint2   lastcachepointer = 0;
    uint1   LATCHupdate = 0;

    p P(
        location :> location,
        incache :> incache,
        PC <: PC,
        pointer <: lastcachepointer
    );
    i I(
        location <: location,
        newinstruction <: newinstruction,
        pointer <: lastcachepointer,
        instruction :> instruction
    );
    c C(
        location <: location,
        newcompressed <: newcompressed,
        pointer <: lastcachepointer,
        compressed :> compressed
    );

    P.update := updatecache && ~LATCHupdate;
    I.update := updatecache && ~LATCHupdate;
    C.update := updatecache && ~LATCHupdate;

    while(1) {
        if( ~updatecache && LATCHupdate ) {
            lastcachepointer = lastcachepointer + 1;
        }
        LATCHupdate = updatecache;
    }
}

algorithm p(
    output  uint3   location,
    output  uint1   incache,
    input   uint32  PC,
    input   uint1   update,
    input   uint2   pointer
) <autorun> {
    uint32  lastpccache[4] = { 32hffffffff, pad(32hffffffff) };

    // CHECK IF PC IS IN LAST INSTRUCTION CACHE
    location :=
        $$for i = 0, 2 do
            ( PC == ( lastpccache[ $i$ ] ) ) ? $i$ :
        $$end
        ( PC == ( lastpccache[ 3 ] ) ) ? 3: 3h7;
    //incache := ( location == 3h7 ) ? 0 : 1;
    incache := 0; // DISABLE FOR TESTING
    lastpccache[ pointer ] := update ? PC : lastpccache[ pointer ];

    while(1) {}
}

algorithm i(
    input   uint3   location,
    output  uint32  instruction,
    input   uint1   update,
    input   uint32  newinstruction,
    input   uint2   pointer
) <autorun> {
    uint32  lastinstructioncache[4] = uninitialized;
    instruction := lastinstructioncache[ ( location == 3h7 ) ? 0 : location ];
    lastinstructioncache[ pointer ] := update ? newinstruction : lastinstructioncache[ pointer ];

    while(1) {}
}

algorithm c(
    input   uint3   location,
    output  uint1   compressed,
    input   uint1   update,
    input   uint1   newcompressed,
    input   uint2   pointer
) <autorun> {
    uint4   lastcompressedcache = 0;
    // RETRIEVE FROM LAST INSTRUCTION CACHE
    compressed := lastcompressedcache[ ( location == 3h7 ) ? 0 : location, 1 ];
    lastcompressedcache[ pointer, 1 ] := update ? newcompressed : lastcompressedcache[ pointer, 1 ];

    while(1) {}
}
