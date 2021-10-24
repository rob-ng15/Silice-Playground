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
) <autorun> {
    uint16  resetcount = uninitialized;
    uint3   FSM = uninitialized;

    // RISC-V PROGRAM COUNTERS AND STATUS
    // SMT - RUNNING ON HART 1 WITH DUPLICATE PROGRAM COUNTER AND REGISTER FILE
    uint1   SMT = uninitialized;
    uint27  pc = uninitialized;
    uint27  pcSMT = uninitialized;
    uint27  PC <:: SMT ? pcSMT : pc;
    uint27  nextPC = uninitialized;
    uint27  newPC = uninitialized;
    pcadjust PCADJUST <@clock_CPUdecoder> (
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

    // RISC-V MEMORY ACCESS FLAGS - SET SIZE 32 BIT FOR FLOAT AND ATOMIC
    uint32  memory8bit = uninitialized;
    uint32  memory16bit = uninitialized;
    signextend SIGNEXTEND <@clock_CPUdecoder> (
        readdata <: readdata,
        byteaccess <: loadAddress,
        function3 <: function3,
        memory8bit :> memory8bit,
        memory16bit :> memory16bit
    );

    // RISC-V REGISTERS
    uint1   frd <:: FASTPATH ? CLASSfrd : EXECUTESLOWfrd;
    int32   sourceReg1 = uninitialized;
    int32   sourceReg2 = uninitialized;
    uint1   REGISTERSwrite <:: FSM[2,1] & writeRegister & ~frd & ( rd != 0 );
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
    // EXTRACT SIGN AND ABSOLUTE VALUE FOR MULTIPLICATION AND DIVISION
    uint32  absRS1 <:: sourceReg1[31,1] ? -sourceReg1 : sourceReg1;
    uint32  absRS2 <:: sourceReg2[31,1] ? -sourceReg2 : sourceReg2;

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
    Iclass IFASTSLOW(
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        frd :> CLASSfrd,
        writeRegister :> writeRegister,
        incPC :> incPC,
        FASTPATH :> FASTPATH
    );

    uint1   CSRincCSRinstret <:: FSM[2,1];
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
        CSRincCSRinstret <: CSRincCSRinstret
    );

    uint1   takeBranch = uninitialized;
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

    // GENERATE PLUS 2 ADDRESSES FOR 32 BIT MEMORY OPERATIONS
    //uint27  PCplus2 = uninitialized; addrplus2 PC2 <@clock_CPUdecoder> ( address <: PC, addressplus2 :> PCplus2 );
    //uint27  loadAddressplus2 = uninitialized; addrplus2 LA2 <@clock_CPUdecoder> ( address <: loadAddress, addressplus2 :> loadAddressplus2 );
    //uint27  storeAddressplus2 = uninitialized; addrplus2 SA2 <@clock_CPUdecoder> ( address <: storeAddress, addressplus2 :> storeAddressplus2 );
    uint27  PCplus2 <:: PC + 2;
    uint27  loadAddressplus2 <:: loadAddress + 2;
    uint27  storeAddressplus2 <:: storeAddress + 2;

    readmemory := 0; writememory := 0; EXECUTESLOWstart := 0;

    // RESET ACTIONS - FSM -> 1, SMT AND PC -> 0 AND DELAY BEFORE CONTINUING
    if( ~reset ) {
        FSM = 1; SMT = 0; pc = 0;
        resetcount = 16hffff; while( resetcount != 0 ) { resetcount = resetcount - 1; }
    }

    while(1) {
        address = PC; readmemory = 1; while( memorybusy ) {}                                                                                                    // FETCH POTENTIAL COMPRESSED OR 1ST 16 BITS
        compressed = ( readdata[0,2] != 2b11 );
        switch( readdata[0,2] ) {                                                                                                                               // EXPAND COMPRESSED INSTRUCTION
            case 2b00: { instruction = { i3200, 2b11 }; }
            case 2b01: { instruction = { i3201, 2b11 }; }
            case 2b10: { instruction = { i3210, 2b11 }; }
            default: {instruction[0,16] = readdata; address = PCplus2; readmemory = 1; while( memorybusy ) {} instruction[16,16] = readdata; }                  // 32 BIT INSTRUCTION FETCH 2ND 16 BITS
        }
        FSM = 2; ++: ++:                                                                                                                                        // DECODE, REGISTER FETCH, ADDRESS GENERATION

        if( memoryload ) {
            address = loadAddress; readmemory = 1; while( memorybusy ) {}                                                                                       // READ 1ST 8 or 16 BITS
            switch( accesssize[0,2] ) {
                case 2b00: { memoryinput = memory8bit; }                                                                                                        // 8 BIT SIGN EXTEND
                case 2b01: { memoryinput  = memory16bit; }                                                                                                      // 16 BIT SIGN EXTEND
                default: { memoryinput[0,16] = readdata; address = loadAddressplus2; readmemory = 1; while( memorybusy ) {} memoryinput[16,16] = readdata; }    // 32 BIT READ 2ND 16 BITS
            }
        }

        if( FASTPATH ) {
            // ALL OTHER OPERATIONS
            takeBranch = EXECUTEFASTtakebranch;
        } else {
            // FPU ALU AND CSR OPERATIONS
            EXECUTESLOWstart = 1; while( EXECUTESLOWbusy ) {}
            takeBranch = 0;
        }

        if( memorystore ) {
            address = storeAddress; writedata = storeLOW;                                                                                                       // STORE 8 OR 16 BIT
            writememory = 1; while( memorybusy ) {}
            if( accesssize[1,1] ) {
                address = storeAddressplus2; writedata = storeHIGH;                                                                                             // 32 BIT WRITE 2ND 16 BITS
                writememory = 1;  while( memorybusy ) {}
            }
        }
        FSM = 4; ++:

        // UPDATE PC AND SMT
        if( SMT ) { pcSMT = newPC; SMT = 0; } else { pc = newPC; SMT = SMTRUNNING; pcSMT = SMTRUNNING ? pcSMT : SMTSTARTPC; }
        FSM = 1;
    } // RISC-V
}

// DETERMINE IF FAST OR SLOW INSTRUCTION
// SET CPU CONTROLS DEPENDING UPON INSTRUCTION TYPE
algorithm Iclass(
    input   uint5   opCode,
    input   uint3   function3,
    input   uint7   function7,
    output  uint1   frd,
    output  uint1   writeRegister,
    output  uint1   incPC,
    output  uint1   FASTPATH
) <autorun> {
    uint1   ALUfastslow <:: ~( opCode[4,1] | ( opCode[3,1] & function7[0,1] & function3[2,1]) );
    always {
        frd = 0; writeRegister = 1; incPC = 1; FASTPATH = 1;
        switch( opCode ) {
            case 5b01101: {}                        // LUI
            case 5b00101: {}                        // AUIPC
            case 5b11011: { incPC = 0; }            // JAL
            case 5b11001: { incPC = 0; }            // JALR
            case 5b11000: { writeRegister = 0; }    // BRANCH
            case 5b00000: {}                        // LOAD
            case 5b01000: { writeRegister = 0; }    // STORE
            case 5b00001: { frd = 1; }              // FLOAT LOAD
            case 5b01001: { writeRegister = 0; }    // FLOAT STORE
            case 5b00011: {}                        // FENCE[I]
            case 5b11100: { FASTPATH = 0; }         // CSR
            case 5b01011: { FASTPATH = 0; }         // LR.W SC.WATOMIC LOAD - MODIFY - STORE
            default: { FASTPATH = ALUfastslow; }    // FPU OR INTEGER DIVIDE -> SLOWPATH
        }
    }
}

// DETERMINE IN FAST OR SLOW FPU INSTRUCTION
algorithm Fclass(
    input   uint5   opCode,
    input   uint7   function7,
    output  uint1   FASTPATHFPU
) <autorun> {
    always {
        switch( opCode ) {
            default: { FASTPATHFPU = 0; }               // FUSED MULTIPLY ADD
            case 5b10100: {
                switch( function7[2,5] ) {              // ARITHMETIC AND CONVERSIONS
                    default: { FASTPATHFPU = 0; }
                    case 5b00100: { FASTPATHFPU = 1; }  // FSGNJ[N][X]
                    case 5b00101: { FASTPATHFPU = 1; }  // FMIN FMAX
                    case 5b10100: { FASTPATHFPU = 1; }  // FEQ FLT FLE
                    case 5b11100: { FASTPATHFPU = 1; }  // FCLASS FMV.X.W
                    case 5b11110: { FASTPATHFPU = 1; }  // FMV.W.X
                }
            }
        }
    }
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
    input   uint1   CSRincCSRinstret
) <autorun> {
    // M EXTENSION - DIVISION
    int32   ALUMDresult = uninitialized;
    uint1   ALUMDstart = uninitialized;
    uint1   ALUMDbusy = uninitialized;
    aluMD ALUMD(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        absRS1 <: absRS1,
        absRS2 <: absRS2,
        start <: ALUMDstart,
        busy :> ALUMDbusy,
        result :> ALUMDresult
    );

    // ATOMIC MEMORY OPERATIONS
    int32   ALUAresult = uninitialized;
    aluA ALUA(
        function7 <: function7,
        memoryinput <: memoryinput,
        sourceReg2 <: sourceReg2,
        result :> ALUAresult
    );

    // FLOATING POINT CLASSIFICATION
    uint1   FASTPATHFPU = uninitialized;
    Fclass FCLASS(
        opCode <: opCode,
        function7 <: function7,
        FASTPATHFPU :> FASTPATHFPU
    );

    // FLOATING POINT SLOW OPERATIONS
    uint5   FPUflags = 0;
    uint5   FPUSLOWnewflags = uninitialized;
    uint1   FPUfrd = uninitialized;
    uint32  FPUresult = uninitialized;
    uint1   FPUstart = uninitialized;
    uint1   FPUbusy = uninitialized;
    fpuslow FPUSLOW(
        FPUflags <: FPUflags,
        FPUnewflags :> FPUSLOWnewflags,
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        rs2 <: rs2,
        sourceReg1 <: sourceReg1,
        sourceReg1F <: sourceReg1F,
        sourceReg2F <: sourceReg2F,
        sourceReg3F <: sourceReg3F,
        frd :> FPUfrd,
        result :> FPUresult,
        start <: FPUstart,
        busy :> FPUbusy
    );
    // FLOATING POINT FAST OPERATIONS
    uint5   FPUFASTnewflags = uninitialized;
    uint1   FPUFASTfrd = uninitialized;
    uint32  FPUFASTresult = uninitialized;
    fpufast FPUFAST(
        FPUflags <: FPUflags,
        FPUnewflags :> FPUFASTnewflags,
        function3 <: function3,
        function7 <: function7,
        rs2 <: rs2,
        sourceReg1 <: sourceReg1,
        sourceReg1F <: sourceReg1F,
        sourceReg2F <: sourceReg2F,
        frd :> FPUFASTfrd,
        result :> FPUFASTresult
    );
    uint5   FPUnewflags <:: FASTPATHFPU ? FPUFASTnewflags : FPUSLOWnewflags;

    // MANDATORY RISC-V CSR REGISTERS + HARTID == 0 MAIN THREAD == 1 SMT THREAD
    uint32  CSRresult = uninitialized;
    uint1   CSRstart = uninitialized;
    uint1   CSRupdateFPUflags = uninitialized;
    CSRblock CSR(
        SMT <: SMT,
        instruction <: instruction,
        function3 <: function3,
        rs1 <: rs1,
        sourceReg1 <: sourceReg1,
        FPUflags :> FPUflags,
        FPUnewflags <: FPUnewflags,
        result :> CSRresult,
        start <: CSRstart,
        incCSRinstret <: CSRincCSRinstret,
        updateFPUflags <: CSRupdateFPUflags
    );

    // START FLAGS
    ALUMDstart := 0; FPUstart := 0; CSRstart := 0; CSRupdateFPUflags := 0;

    while(1) {
        if( start ) {
            busy = 1;
            frd = 0;
            switch( opCode ) {
                case 5b11100: {
                    switch( function3 ) {
                        default: { CSRstart = 1; ++: result = CSRresult; }                  // CSR
                        case 3b000: { result = 0; }
                    }
                }
                case 5b01011: {                                                             // ATOMIC OPERATIONS
                    switch( function7[2,5] ) {
                        case 5b00010: { result = memoryinput; }                             // LR.W
                        case 5b00011: { memoryoutput = sourceReg2; result = 0; }            // SC.W
                        default: { result = memoryinput; memoryoutput = ALUAresult; }       // ATOMIC LOAD - MODIFY - STORE
                    }
                }
                default: {                                                                  // FPU AND INTEGER DIVISION
                    if( opCode[4,1] ) {
                        if( FASTPATHFPU ) {
                            // COMPARISONS, MIN/MAX, SIGN MANIPULATION, CLASSIFICTIONS AND MOVE F-> and I->F
                            frd = FPUFASTfrd; result = FPUFASTresult;
                        } else {
                            // CONVERSIONS AND CALCULATIONSD
                            FPUstart = 1; while( FPUbusy ) {} frd = FPUfrd; result = FPUresult;
                        }
                        CSRupdateFPUflags = 1;
                    } else {
                        ALUMDstart = 1; while( ALUMDbusy ) {} result = ALUMDresult;
                    }
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
) <autorun> {
    // BRANCH COMPARISON UNIT
    uint1   BRANCHtakeBranch = uninitialized;
    branchcomparison BRANCHUNIT(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        takeBranch :> BRANCHtakeBranch
    );

    // ALU
    int32   ALUresult = uninitialized;
    alu ALU(
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        rs2 <: rs2,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        immediateValue <: immediateValue,
        result :> ALUresult
    );

    // M EXTENSION - MULTIPLICATION
    int32   ALUMMresult = uninitialized;
    aluMM ALUMM(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        absRS1 <: absRS1,
        absRS2 <: absRS2,
        result :> ALUMMresult
    );
    uint1   isALUMM <:: ( opCode[3,1] & function7[0,1] );

    always {
        takeBranch = 0;
        switch( opCode ) {
            case 5b01101: { result = AUIPCLUI; }                    // LUI
            case 5b00101: { result = AUIPCLUI; }                    // AUIPC
            case 5b11011: { result = nextPC; }                      // JAL
            case 5b11001: { result = nextPC; }                      // JALR
            case 5b11000: { takeBranch = BRANCHtakeBranch; }        // BRANCH
            case 5b00000: { result = memoryinput; }                 // LOAD
            case 5b01000: { memoryoutput = sourceReg2; }            // STORE
            case 5b00001: { result = memoryinput; }                 // FLOAT LOAD
            case 5b01001: { memoryoutput = sourceReg2F; }           // FLOAT STORE
            case 5b00011: {}                                        // FENCE[I]
            default: { result = isALUMM ? ALUMMresult : ALUresult; }// INTEGER ALU AND MULTIPLICATION
        }
    }
}
