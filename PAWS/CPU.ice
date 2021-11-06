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
    input   uint32  SMTSTARTPC
) <autorun,reginputs> {
    uint3   FSM = uninitialized;

    // RISC-V PROGRAM COUNTERS AND STATUS
    // SMT - RUNNING ON HART 1 WITH DUPLICATE PROGRAM COUNTER AND REGISTER FILE
    uint1   SMT = uninitialized;
    uint27  pc = uninitialized;
    uint27  pcSMT = uninitialized;
    uint27  PC <:: SMT ? pcSMT : pc;
    uint27  nextPC = uninitialized;
    uint27  newPC = uninitialized;
    newpc NEWPC <@clock_CPUdecoder> (
        opCode <: opCode,
        PC <: PC,
        compressed <: compressed,
        incPC <: incPC,
        takeBranch <: takeBranch,
        branchAddress <: branchAddress,
        jumpAddress <: jumpAddress,
        loadAddress <: loadAddress,
        nextPC :> nextPC,
        newPC :> newPC
    );

    // COMPRESSED INSTRUCTION EXPANDER
    uint32  instruction = uninitialized;
    uint1   compressed = uninitialized;
    uint30  i3200 = uninitialized; compressed00 COMPRESSED00 <@clock_CPUdecoder> ( i16 <: readdata, i32 :> i3200 );
    uint30  i3201 = uninitialized; compressed01 COMPRESSED01 <@clock_CPUdecoder> ( i16 <: readdata, i32 :> i3201 );
    uint30  i3210 = uninitialized; compressed10 COMPRESSED10 <@clock_CPUdecoder> ( i16 <: readdata, i32 :> i3210 );

    // RISC-V 32 BIT INSTRUCTION DECODER
    uint5   opCode = uninitialized;
    uint3   function3 = uninitialized;
    uint7   function7 = uninitialized;
    uint5   rs1 = uninitialized;
    uint5   rs2 = uninitialized;
    uint5   rs3 = uninitialized;
    uint5   rd = uninitialized;
    int32   immediateValue = uninitialized;
    uint1   memoryload = uninitialized;
    uint1   memorystore = uninitialized;
    decode RV32DECODER <@clock_CPUdecoder> (
        instruction <: instruction,
        opCode :> opCode,
        function3 :> function3,
        function7 :> function7,
        rs1 :> rs1,
        rs2 :> rs2,
        rs3 :> rs3,
        rd :> rd,
        immediateValue :> immediateValue,
        memoryload :> memoryload,
        memorystore :> memorystore,
        accesssize :> accesssize
    );

    // RISC-V ADDRESS GENERATOR
    uint32  AUIPCLUI = uninitialized;
    uint27  branchAddress = uninitialized;
    uint27  jumpAddress = uninitialized;
    uint27  loadAddress = uninitialized;
    uint27  storeAddress = uninitialized;
    addressgenerator AGU <@clock_CPUdecoder> (
        instruction <: instruction,
        PC <: PC,
        sourceReg1 <: sourceReg1,
        AUIPCLUI :> AUIPCLUI,
        branchAddress :> branchAddress,
        jumpAddress :> jumpAddress,
        loadAddress :> loadAddress,
        storeAddress :> storeAddress
    );

    // GENERATE PLUS 2 ADDRESSES FOR 32 BIT MEMORY OPERATIONS
    uint27  PCplus2 = uninitialized; addrplus2 PC2 <@clock_CPUdecoder> ( address <: PC, addressplus2 :> PCplus2 );
    uint27  loadAddressplus2 = uninitialized; addrplus2 LA2 <@clock_CPUdecoder> ( address <: loadAddress, addressplus2 :> loadAddressplus2 );
    uint27  storeAddressplus2 = uninitialized; addrplus2 SA2 <@clock_CPUdecoder> ( address <: storeAddress, addressplus2 :> storeAddressplus2 );

    // RISC-V MEMORY ACCESS FLAGS - SET SIZE 32 BIT FOR FLOAT AND ATOMIC
    uint32  memory16or8bit = uninitialized;
    signextend SIGNEXTEND <@clock_CPUdecoder> (
        readdata <: readdata,
        is16or8 <: accesssize[0,1],
        byteaccess <: loadAddress[0,1],
        dounsigned <: function3[2,1],
        memory168 :> memory16or8bit
    );

    // RISC-V REGISTERS
    uint1   frd <:: FASTPATH ? CLASSfrd : EXECUTESLOWfrd;
    int32   sourceReg1 = uninitialized;
    int32   sourceReg2 = uninitialized;
    uint1   REGISTERSwrite <:: FSM[2,1] & writeRegister & ~frd & ( |rd );
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
    uint32  absRS1 = uninitialized; absolute ARS1 <@clock_CPUdecoder> ( number <: sourceReg1, value :> absRS1 );
    uint32  absRS2 = uninitialized; absolute ARS2 <@clock_CPUdecoder> ( number <: sourceReg2, value :> absRS2 );

    // RISC-V FLOATING POINT REGISTERS
    uint32  sourceReg1F = uninitialized;
    uint32  sourceReg2F = uninitialized;
    uint32  sourceReg3F = uninitialized;
    uint1   REGISTERSFwrite <:: FSM[2,1] & writeRegister & frd;
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
    uint32  result <:: FASTPATH ? EXECUTEFASTresult : EXECUTESLOWresult;
    uint16  storeLOW <:: FASTPATH ? EXECUTEFASTmemoryoutput[0,16] : EXECUTESLOWmemoryoutput[0,16];
    uint16  storeHIGH <:: FASTPATH ? EXECUTEFASTmemoryoutput[16,16] : EXECUTESLOWmemoryoutput[16,16];

    // CLASSIFY THE INSTRUCTION TO FAST/SLOW
    uint1   FASTPATH = uninitialized;
    uint1   incPC = uninitialized;
    uint1   writeRegister = uninitialized;
    uint1   CLASSfrd = uninitialized;
    Iclass IFASTSLOW <@clock_CPUdecoder> (
        opCode <: opCode,
        function3 <: function3,
        isALUM <: function7[0,1],
        frd :> CLASSfrd,
        writeRegister :> writeRegister,
        incPC :> incPC,
        FASTPATH :> FASTPATH
    );

    //uint1   CSRincCSRinstret <:: FSM[2,1];
    uint32  EXECUTESLOWmemoryoutput = uninitialized;
    int32   EXECUTESLOWresult = uninitialized;
    uint1   EXECUTESLOWfrd = uninitialized;
    uint1   EXECUTESLOWstart = uninitialized;
    uint1   EXECUTESLOWbusy = uninitialized;
    cpuexecuteSLOWPATH EXECUTESLOWPATH(
        start <: EXECUTESLOWstart,
        busy :> EXECUTESLOWbusy,
        SMT <: SMT,
        instruction <: instruction,
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        rs2 <: rs2,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        absRS1 <: absRS1,
        absRS2 <: absRS2,
        sourceReg1F <: sourceReg1F,
        sourceReg2F <: sourceReg2F,
        sourceReg3F <: sourceReg3F,
        memoryinput <: memoryinput,
        frd :> EXECUTESLOWfrd,
        memoryoutput :> EXECUTESLOWmemoryoutput,
        result :> EXECUTESLOWresult,
        incCSRinstret <: FSM[2,1]
    );

    uint1   takeBranch <:: FASTPATH & EXECUTEFASTtakebranch;
    uint1   EXECUTEFASTtakebranch = uninitialized;
    uint32  EXECUTEFASTmemoryoutput = uninitialized;
    int32   EXECUTEFASTresult = uninitialized;
    cpuexecuteFASTPATH EXECUTEFASTPATH(
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        rs2 <: rs2,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        absRS1 <: absRS1,
        absRS2 <: absRS2,
        sourceReg2F <: sourceReg2F,
        immediateValue <: immediateValue,
        memoryinput <: memoryinput,
        AUIPCLUI <: AUIPCLUI,
        nextPC <: nextPC,
        takeBranch :> EXECUTEFASTtakebranch,
        memoryoutput :> EXECUTEFASTmemoryoutput,
        result :> EXECUTEFASTresult
    );

    readmemory := 0; writememory := 0; EXECUTESLOWstart := 0;

    // RESET ACTIONS - FSM -> 1, SMT AND PC -> 0
    if( ~reset ) {
        FSM = 1; SMT = 0; pc = 0;
    }

    while(1) {
        address = PC; readmemory = 1; while( memorybusy ) {}                                                                                                    // FETCH POTENTIAL COMPRESSED OR 1ST 16 BITS
        compressed = ( ~&readdata[0,2] );
        if( compressed ) {
            switch( readdata[0,2] ) {                                                                                                                           // EXPAND COMPRESSED INSTRUCTION
                case 2b00: { instruction = { i3200, 2b11 }; }
                case 2b01: { instruction = { i3201, 2b11 }; }
                case 2b10: { instruction = { i3210, 2b11 }; }
                default: {}
            }
        } else {
            // 32 BIT INSTRUCTION FETCH 2ND 16 BITS
            instruction[0,16] = readdata; address = PCplus2; readmemory = 1; while( memorybusy ) {} instruction[16,16] = readdata;
        }
        FSM = 2; ++: ++:                                                                                                                                        // DECODE, REGISTER FETCH, ADDRESS GENERATION

        if( memoryload ) {
            address = loadAddress; readmemory = 1; while( memorybusy ) {}                                                                                       // READ 1ST 8 or 16 BITS
            if( accesssize[1,1] ) {
                memoryinput[0,16] = readdata; address = loadAddressplus2; readmemory = 1; while( memorybusy ) {} memoryinput[16,16] = readdata;                 // READ 2ND 16 BITS
            } else {
                memoryinput = memory16or8bit;                                                                                                                   // 8 or 16 BIT SIGN EXTENDED
            }
        } else {}

        if( ~FASTPATH ) {
            // FPU ALU AND CSR OPERATIONS
            EXECUTESLOWstart = 1; while( EXECUTESLOWbusy ) {}
        } else {}

        if( memorystore ) {
            address = storeAddress; writedata = storeLOW;                                                                                                       // STORE 8 OR 16 BIT
            writememory = 1; while( memorybusy ) {}
            if( accesssize[1,1] ) {
                address = storeAddressplus2; writedata = storeHIGH;                                                                                             // 32 BIT WRITE 2ND 16 BITS
                writememory = 1;  while( memorybusy ) {}
            } else {}
        }  else {}
        FSM = 4; ++:

        // UPDATE PC AND SMT
        if( SMT ) { pcSMT = newPC; SMT = 0; } else { pc = newPC; SMT = SMTRUNNING; pcSMT = SMTRUNNING ? pcSMT : SMTSTARTPC; }
        FSM = 1;
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
                case 5b11100: {
                    switch( function3 ) {
                        default: { CSR.start = 1; ++: result = CSR.result; }                  // CSR
                        case 3b000: { result = 0; }
                    }
                }
                case 5b01011: {                                                             // ATOMIC OPERATIONS
                    switch( function7[2,2] ) {
                        case 2b10: { result = memoryinput; }                                // LR.W
                        case 2b11: { memoryoutput = sourceReg2; result = 0; }               // SC.W
                        default: { result = memoryinput; memoryoutput = ALUA.result; }       // ATOMIC LOAD - MODIFY - STORE
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
