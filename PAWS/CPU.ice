// RISC-ICE-V
// inspired by https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice
//
// A simple Risc-V RV32IMAFC processor

// RISC-V - MAIN CPU LOOP
//          ALU FUNCTIONALITY LISTED IN ALU-

algorithm PAWSCPU(
    input   uint1   clock_CPUdecoder,
    output  uint2   accesssize,
    output  uint27  address,
    output  uint16  writedata,
    output  uint1   writememory,
    input   uint16  readdata,
    output  uint1   readmemory,
    input   uint1   memorybusy,
    input   uint1   SMTRUNNING,
    input   uint27  SMTSTARTPC
) <autorun,reginputs> {
    uint1   COMMIT = uninitialized;

    // COMPRESSED INSTRUCTION EXPANDER
    uint32  instruction = uninitialized;
    uint1   compressed = uninitialized;
    compressed00 COMPRESSED00 <@clock_CPUdecoder> ( i16 <: readdata ); compressed01 COMPRESSED01 <@clock_CPUdecoder> ( i16 <: readdata ); compressed10 COMPRESSED10 <@clock_CPUdecoder> ( i16 <: readdata );

    // RISC-V 32 BIT INSTRUCTION DECODER
    uint5   opCode = uninitialized;
    uint3   function3 = uninitialized;
    uint7   function7 = uninitialized;
    uint5   rs1 = uninitialized;
    uint5   rs2 = uninitialized;
    uint5   rs3 = uninitialized;
    uint5   rd = uninitialized;
    decode RV32DECODER <@clock_CPUdecoder> (
        instruction <: instruction,
        opCode :> opCode,
        function3 :> function3,
        function7 :> function7,
        rs1 :> rs1,
        rs2 :> rs2,
        rs3 :> rs3,
        rd :> rd,
        accesssize :> accesssize
    );

    // RISC-V PROGRAM COUNTERS AND STATUS
    // SMT - RUNNING ON HART 1 WITH DUPLICATE PROGRAM COUNTER AND REGISTER FILE
    uint1   SMT = uninitialized;
    uint27  pc = uninitialized; uint27  pc_next <:: SMT ? pc :  NEWPC.newPC;
    uint27  pcSMT = uninitialized; uint27  pcSMT_next <:: SMT ? NEWPC.newPC : SMTRUNNING ? pcSMT : SMTSTARTPC;
    uint27  PC <:: SMT ? pcSMT : pc;

    // RISC-V ADDRESS GENERATOR
    addressgenerator AGU <@clock_CPUdecoder> (
        instruction <: instruction,
        immediateValue <: RV32DECODER.immediateValue,
        PC <: PC,
        sourceReg1 <: sourceReg1,
        AMO <: RV32DECODER.AMO
    );

    // SELECT NEXT PC
    newpc NEWPC <@clock_CPUdecoder> (
        opCode <: opCode,
        PC <: PC,
        compressed <: compressed,
        incPC <: IFASTSLOW.incPC,
        takeBranch <: takeBranch,
        branchAddress <: AGU.branchAddress,
        jumpAddress <: AGU.jumpAddress,
        loadAddress <: AGU.loadAddress
    );


    // GENERATE PLUS 2 ADDRESSES FOR 32 BIT MEMORY OPERATIONS
    addrplus2 PC2 <@clock_CPUdecoder> ( address <: PC ); addrplus2 LA2 <@clock_CPUdecoder> ( address <: AGU.loadAddress ); addrplus2 SA2 <@clock_CPUdecoder> ( address <: AGU.storeAddress );

    // SIGN EXTENDER FOR 8 AND 16 BIT LOADS
    signextend SIGNEXTEND <@clock_CPUdecoder> ( readdata <: readdata, is16or8 <: accesssize[0,1], byteaccess <: AGU.loadAddress[0,1], dounsigned <: function3[2,1] );

    // RISC-V REGISTERS
    uint1   frd <:: IFASTSLOW.FASTPATH ? IFASTSLOW.frd : EXECUTESLOW.frd;
    int32   sourceReg1 = uninitialized;
    int32   sourceReg2 = uninitialized;
    uint1   REGISTERSwrite <:: COMMIT & IFASTSLOW.writeRegister & ~frd & ( |rd );
    registersI REGISTERS <@clock_CPUdecoder> (
        SMT <:: SMT,
        rs1 <: rs1,
        rs2 <: rs2,
        result <: result,
        rd <: rd,
        write <: REGISTERSwrite,
        sourceReg1 :> sourceReg1,
        sourceReg2 :> sourceReg2
    );
    // EXTRACT ABSOLUTE VALUE FOR MULTIPLICATION AND DIVISION
    absolute ARS1 <@clock_CPUdecoder> ( number <: sourceReg1 ); absolute ARS2 <@clock_CPUdecoder> ( number <: sourceReg2 );

    // RISC-V FLOATING POINT REGISTERS
    uint32  sourceReg1F = uninitialized;
    uint32  sourceReg2F = uninitialized;
    uint32  sourceReg3F = uninitialized;
    uint1   REGISTERSFwrite <:: COMMIT & IFASTSLOW.writeRegister & frd;
    registersF REGISTERSF <@clock_CPUdecoder> (
        SMT <:: SMT,
        rs1 <: rs1,
        rs2 <: rs2,
        rs3 <: rs3,
        result <: result,
        rd <: rd,
        write <: REGISTERSFwrite,
        sourceReg1 :> sourceReg1F,
        sourceReg2 :> sourceReg2F,
        sourceReg3 :> sourceReg3F
    );

    // CPU EXECUTE BLOCK
    uint32  memoryinput = uninitialized;
    uint32  result <:: IFASTSLOW.FASTPATH ? EXECUTEFAST.result : EXECUTESLOW.result;
    uint16  storeLOW <:: IFASTSLOW.FASTPATH ? EXECUTEFAST.memoryoutput[0,16] : EXECUTESLOW.memoryoutput[0,16];
    uint16  storeHIGH <:: IFASTSLOW.FASTPATH ? EXECUTEFAST.memoryoutput[16,16] : EXECUTESLOW.memoryoutput[16,16];

    // CLASSIFY THE INSTRUCTION TO FAST/SLOW
    Iclass IFASTSLOW <@clock_CPUdecoder> (
        opCode <: opCode,
        function3 <: function3,
        isALUM <: function7[0,1]
    );

    cpuexecuteSLOWPATH EXECUTESLOW(
        SMT <: SMT,
        instruction <: instruction,
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        rs2 <: rs2,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        absRS1 <: ARS1.value,
        absRS2 <: ARS2.value,
        sourceReg1F <: sourceReg1F,
        sourceReg2F <: sourceReg2F,
        sourceReg3F <: sourceReg3F,
        memoryinput <: memoryinput,
        incCSRinstret <: COMMIT
    );

    uint1   takeBranch <:: IFASTSLOW.FASTPATH & EXECUTEFAST.takeBranch;
    cpuexecuteFASTPATH EXECUTEFAST(
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        rs2 <: rs2,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        absRS1 <: ARS1.value,
        absRS2 <: ARS2.value,
        sourceReg2F <: sourceReg2F,
        immediateValue <: RV32DECODER.immediateValue,
        memoryinput <: memoryinput,
        AUIPCLUI <: AGU.AUIPCLUI,
        nextPC <: NEWPC.nextPC
    );

    readmemory := 0; writememory := 0; EXECUTESLOW.start := 0; COMMIT := 0;

    if( ~reset ) { SMT = 0; pc = 0; }

    while(1) {
        address = PC; readmemory = 1; while( memorybusy ) {}                                                                                        // FETCH POTENTIAL COMPRESSED OR 1ST 16 BITS
        compressed = ( ~&readdata[0,2] );
        if( compressed ) {
            switch( readdata[0,2] ) {                                                                                                               // EXPAND COMPRESSED INSTRUCTION
                case 2b00: { instruction = { COMPRESSED00.i32, 2b11 }; }
                case 2b01: { instruction = { COMPRESSED01.i32, 2b11 }; }
                case 2b10: { instruction = { COMPRESSED10.i32, 2b11 }; }
                default: {}
            }
        } else {
            instruction[0,16] = readdata; address = PC2.addressplus2; readmemory = 1; while( memorybusy ) {} instruction[16,16] = readdata;         // 32 BIT INSTRUCTION FETCH 2ND 16 BITS
        }
        ++: ++:                                                                                                                                     // DECODE, REGISTER FETCH, ADDRESS GENERATION

        if( RV32DECODER.memoryload ) {
            address = AGU.loadAddress; readmemory = 1; while( memorybusy ) {}                                                                       // READ 1ST 8 or 16 BITS
            if( accesssize[1,1] ) {
                memoryinput[0,16] = readdata; address = LA2.addressplus2; readmemory = 1; while( memorybusy ) {} memoryinput[16,16] = readdata;     // READ 2ND 16 BITS
            } else {
                memoryinput = SIGNEXTEND.memory168;                                                                                                 // 8 or 16 BIT SIGN EXTENDED
            }
        } else {}

        if( ~IFASTSLOW.FASTPATH ) { EXECUTESLOW.start = 1; while( EXECUTESLOW.busy ) {} }                                                           // FPU ALU AND CSR OPERATIONS, FASTPATH HANDLED AUTOMATICALLY
        COMMIT = 1;                                                                                                                                 // COMMIT REGISTERS

        if( RV32DECODER.memorystore ) {
            address = AGU.storeAddress; writedata = storeLOW; writememory = 1; while( memorybusy ) {}                                               // STORE 8 OR 16 BIT
            if( accesssize[1,1] ) {
                address = SA2.addressplus2; writedata = storeHIGH; writememory = 1;  while( memorybusy ) {}                                         // 32 BIT WRITE 2ND 16 BITS
            } else {}
        } else {}

        pc = pc_next; pcSMT = pcSMT_next; SMT = ~SMT & SMTRUNNING;                                                                                  // UPDATE PC AND SMT
    } // RISC-V
}

algorithm cpuexecuteSLOWPATH(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint1   SMT,
    input   uint32  instruction,
    input   uint5   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  absRS1,
    input   uint32  absRS2,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,
    input   uint32  memoryinput,
    output  uint1   frd,
    output  uint32  memoryoutput,
    output  uint32  result,
    input   uint1   incCSRinstret
) <autorun,reginputs> {
    // M EXTENSION - DIVISION
    aluMD ALUMD(
        function3 <: function3[0,2],
        sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2,
        absRS1 <: absRS1, absRS2 <: absRS2
    );

    // ATOMIC MEMORY OPERATIONS
    aluA ALUA( function7 <: function7, memoryinput <: memoryinput, sourceReg2 <: sourceReg2 );

    // FLOATING POINT CLASSIFICATION
    Fclass FCLASS( is2FPU <: opCode[2,1], isFPUFAST <: function7[4,1] );

    // FLOATING POINT SLOW OPERATIONS - CALCULATIONS AND CONVERSIONS
    fpuslow FPUSLOW(
        FPUflags <: CSR.FPUflags,
        opCode <: opCode, function7 <: function7[2,5],
        rs2 <: rs2[0,1],
        sourceReg1 <: sourceReg1, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, sourceReg3F <: sourceReg3F
    );

    // FLOATING POINT FAST OPERATIONS
    fpufast FPUFAST(
        FPUflags <: CSR.FPUflags,
        function3 <: function3[0,2], function7 <: function7[2,5],
        sourceReg1 <: sourceReg1, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F
    );

    // MANDATORY RISC-V CSR REGISTERS + HARTID == 0 MAIN THREAD == 1 SMT THREAD
    uint5   FPUnewflags <:: FCLASS.FASTPATHFPU ? FPUFAST.FPUnewflags : FPUSLOW.FPUnewflags;
    CSRblock CSR(
        SMT <: SMT,
        instruction <: instruction,
        function3 <: function3,
        rs1 <: rs1,
        sourceReg1 <: sourceReg1,
        FPUnewflags <: FPUnewflags,
        incCSRinstret <: incCSRinstret
    );

    // START FLAGS
    ALUMD.start := 0; FPUSLOW.start := 0; CSR.start := 0; CSR.updateFPUflags := 0;

    while(1) {
        if( start ) {
            busy = 1;
            frd = 0;
            switch( opCode ) {
                case 5b11100: {                                                             // CSR
                    if( |function3 ) {
                        CSR.start = 1; ++: result = CSR.result;
                    } else {
                        result = 0;
                    }
                }
                case 5b01011: {                                                             // ATOMIC OPERATIONS
                    if( function7[3,1] ) {
                        result = memoryinput; memoryoutput = ALUA.result;                   // ATOMIC LOAD - MODIFY - STORE
                    } else {
                        result = function7[2,1] ? 0 : memoryinput;                          // LR.W SC.W
                        memoryoutput = sourceReg2;
                    }
                }
                default: {                                                                  // FPU AND INTEGER DIVISION
                    if( opCode[4,1] & FCLASS.FASTPATHFPU ) {
                        // COMPARISONS, MIN/MAX, SIGN MANIPULATION, CLASSIFICTIONS AND MOVE F-> and I->F
                        frd = FPUFAST.frd; result = FPUFAST.result;
                    } else {
                        FPUSLOW.start = opCode[4,1]; ALUMD.start = ~opCode[4,1];
                        while( FPUSLOW.busy | ALUMD.busy ) {}
                        frd = opCode[4,1] & FPUSLOW.frd;
                        result = opCode[4,1] ? FPUSLOW.result : ALUMD.result;
                    }
                    CSR.updateFPUflags = opCode[4,1];
                }
            }
            busy = 0;
        }
    }
}
algorithm cpuexecuteFASTPATH(
    input   uint5   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  absRS1,
    input   uint32  absRS2,
    input   uint32  sourceReg2F,
    input   uint32  immediateValue,
    input   uint32  memoryinput,
    input   uint32  AUIPCLUI,
    input   uint32  nextPC,
    output  uint1   takeBranch,
    output  uint32  memoryoutput,
    output  uint32  result
) <autorun,reginputs> {
    // BRANCH COMPARISON UNIT
    branchcomparison BRANCHUNIT( function3 <: function3, sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2 );

    // ALU
    alu ALU(
        opCode <: opCode, function3 <: function3, function7 <: function7,
        rs1 <: rs1, rs2 <: rs2,
        sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2,
        immediateValue <: immediateValue
    );

    // M EXTENSION - MULTIPLICATION
    aluMM ALUMM(
        function3 <: function3[0,2],
        sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2,
        absRS1 <: absRS1, absRS2 <: absRS2
    );

    // CLASSIFY THE TYPE FOR INSTRUCTIONS THAT WRITE TO REGISTER
    uint1   isALUMM <:: ( opCode[3,1] & function7[0,1] );
    uint1   isAUIPCLUI <:: ( opCode[0,3] == 3b101 );
    uint1   isJAL <:: ( opCode[2,3] == 3b110 ) & opCode[0,1];
    uint1   isLOAD <:: ~|opCode[1,4];

    takeBranch := 0;

    always {
        switch( opCode ) {
            case 5b11000: { takeBranch = BRANCHUNIT.takeBranch; }       // BRANCH
            case 5b01000: { memoryoutput = sourceReg2; }                // STORE
            case 5b01001: { memoryoutput = sourceReg2F; }               // FLOAT STORE
            case 5b00011: {}                                            // FENCE[I]
            default: { result = isAUIPCLUI ? AUIPCLUI :                 // LUI AUIPC
                                isJAL ? nextPC :                        // JAL[R]
                                isLOAD ? memoryinput :                  // [FLOAT]LOAD
                                isALUMM ? ALUMM.result : ALU.result; }  // INTEGER ALU AND MULTIPLICATION
        }
    }
}
