// RISC-ICE-V
// inspired by https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice
//
// A simple Risc-V RV32IMC processor ( with partial B extension implementation )

// RISC-V - MAIN CPU LOOP
//          ALU FUNCTIONALITY LISTED IN ALU-

// PERFORM OPTIONAL SIGN EXTENSION FOR 8 BIT AND 16 BIT READS
circuitry signextender8( input function3, input address, input nosign, output withsign ) {
    withsign = ~function3[2,1] ? { {24{nosign[address[0,1] ? 15 : 7, 1]}}, nosign[address[0,1] ? 8 : 0, 8] } : nosign[address[0,1] ? 8 : 0, 8];
}
circuitry signextender16( input function3, input nosign, output withsign ) {
    withsign = ~function3[2,1] ? { {16{nosign[15,1]}}, nosign[0,16] } : nosign[0,16];
}

// CPU FETCH 16 bit WORD FROM MEMORY FOR INSTRUCTION BUILDING
circuitry fetch( input location, input memorybusy, output address, output readmemory ) {
    address = location; readmemory = 1; while( memorybusy ) {}
}
// CPU LOAD FROM MEMORY
circuitry load( input accesssize, input location, input memorybusy, input readdata, output address, output readmemory, output memoryinput ) {
    address = location; readmemory = 1; while( memorybusy ) {}                                                                                      // READ 1ST 16 BITS
    switch( accesssize[0,2] ) {
        case 2b00: { ( memoryinput ) = signextender8( accesssize, location, readdata ); }                                                           // 8 BIT SIGN EXTEND
        case 2b01: { ( memoryinput ) = signextender16( accesssize, readdata ); }                                                                    // 16 BIT SIGN EXTEND
        default: { memoryinput[0,16] = readdata; address = location + 2; readmemory = 1; while( memorybusy ) {} memoryinput[16,16] = readdata; }    // 32 BIT READ 2ND 16 BITS
    }
}
// CPU STORE TO MEMORY - DON'T WAIT FOR WRITE TO FINISH IF 16 OR 8 BIT WRITE
circuitry store( input accesssize, input location, input value, input memorybusy, output address, output writedata,  output writememory ) {
    address = location; writedata = value[0,16]; writememory = 1; while( memorybusy ) {}                                                            // STORE 8 OR 16 BIT
    switch( accesssize[0,2] ) {
        case 2b10: { address = location + 2; writedata = value[16,16]; writememory = 1;  while( memorybusy ) {} }                                   // // 32 BIT WRITE 2ND 16 BITS
        default: {}
    }
}

algorithm PAWSCPU(
    input   uint1   clock_CPUdecoder,
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
    uint16  resetcount = 16hffff;
    uint4   FSM = uninitialized;

    // RISC-V PROGRAM COUNTERS AND STATUS
    uint32  pc = uninitialized;
    uint32  PC <:: SMT ? pcSMT : pc;
    uint32  PCplus2 <: PC + 2;
    uint1   incPC = uninitialized;

    // SMT FLAG
    // RUNNING ON HART 0 OR HART 1
    // DUPLICATES PROGRAM COUNTER, REGISTER FILE AND LAST INSTRUCTION CACHE
    uint1   SMT = uninitialized;
    uint32  pcSMT = uninitialized;

    // COMPRESSED INSTRUCTION EXPANDER
    uint32  instruction = uninitialized;
    uint1   compressed = uninitialized;
    uint32  i32 = uninitialized;
    compressed COMPRESSED <@clock_CPUdecoder> (
        i16 <: readdata,
        i32 :> i32
    );

    // RISC-V MEMORY ACCESS FLAGS
    uint1   memoryload := ( opCode[2,5] == 5b00000 ) | ( opCode[2,5] == 5b00001 ) | ( ( opCode[2,5] == 5b01011 ) & ( function7[2,5] != 5b00011 ) );
    uint1   memorystore := ( opCode[2,5] == 5b01000 ) | ( opCode[2,5] == 5b01001 ) | ( ( opCode[2,5] == 5b01011 ) & ( function7[2,5] != 5b00010 ) );

    // RISC-V 32 BIT INSTRUCTION DECODER
    int32   immediateValue = uninitialized;
    uint7   opCode = uninitialized;
    uint3   function3 = uninitialized;
    uint7   function7 = uninitialized;
    uint5   rs1 = uninitialized;
    uint5   rs2 = uninitialized;
    uint5   rs3 = uninitialized;
    uint5   rd = uninitialized;
    decoder DECODER <@clock_CPUdecoder> (
        instruction <: instruction,
        opCode :> opCode,
        function3 :> function3,
        function7 :> function7,
        rs1 :> rs1,
        rs2 :> rs2,
        rs3 :> rs3,
        rd :> rd,
        immediateValue :> immediateValue
    );

    // RISC-V REGISTERS
    int32   sourceReg1 = uninitialized;
    int32   sourceReg2 = uninitialized;
    int32   sourceReg3 = uninitialized;
    registers REGISTERS <@clock_CPUdecoder> (
        SMT <:: SMT,
        rs1 <: rs1,
        rs2 <: rs2,
        rs3 <: rs3,
        result <: EXECUTEresult,
        rd <: rd,
        sourceReg1 :> sourceReg1,
        sourceReg2 :> sourceReg2,
        sourceReg3 :> sourceReg3
    );
    // RISC-V FLOATING POINT REGISTERS
    uint32  sourceReg1F = uninitialized;
    uint32  sourceReg2F = uninitialized;
    uint32  sourceReg3F = uninitialized;
    registers REGISTERSF <@clock_CPUdecoder> (
        SMT <:: SMT,
        rs1 <: rs1,
        rs2 <: rs2,
        rs3 <: rs3,
        result <: EXECUTEresult,
        rd <: rd,
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
    addressgenerator AGU <@clock_CPUdecoder> (
        compressed <: compressed,
        instruction <: instruction,
        pc <: PC,
        immediateValue <: immediateValue,
        sourceReg1 <: sourceReg1,
        nextPC :> nextPC,
        branchAddress :> branchAddress,
        jumpAddress :> jumpAddress,
        storeAddress :> storeAddress,
        loadAddress :> loadAddress,
        AUIPCLUI :> AUIPCLUI
    );

    // CPU EXECUTE BLOCK
    uint1   takeBranch = uninitialized;
    uint32  memoryinput = uninitialized;
    uint32  memoryoutput = uninitialized;
    uint1   EXECUTEstart = uninitialized;
    uint1   EXECUTEbusy = uninitialized;
    int32   EXECUTEresult = uninitialized;
    uint1   EXECUTEfrd = uninitialized;
    uint1   EXECUTEwriteRegister = uninitialized;
    cpuexecute EXECUTE(
        SMT <: SMT,
        instruction <: instruction,
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        rs2 <: rs2,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        sourceReg3 <: sourceReg3,
        sourceReg1F <: sourceReg1F,
        sourceReg2F <: sourceReg2F,
        sourceReg3F <: sourceReg3F,
        immediateValue <: immediateValue,
        memoryinput <: memoryinput,
        nextPC <: nextPC,
        AUIPCLUI <: AUIPCLUI,
        incPC :> incPC,
        takeBranch :> takeBranch,
        memoryoutput :> memoryoutput,
        start <: EXECUTEstart,
        busy :> EXECUTEbusy,
        result :> EXECUTEresult,
        frd :> EXECUTEfrd,
        writeRegister :> EXECUTEwriteRegister
    );

    // PC UPDATE BLOCK
    uint32  newPC = uninitialized;
    updatepc NEWPC(
        opCode <: opCode,
        incPC <: incPC,
        nextPC <: nextPC,
        takeBranch <: takeBranch,
        branchAddress <: branchAddress,
        jumpAddress <: jumpAddress,
        loadAddress <: loadAddress,
        pc :> newPC
    );

    // MEMORY ACCESS FLAGS - 32 bit for FLOAT LOAD/STORE AND ATOMIC OPERATIONS
    accesssize := ( opCode[2,5] == 5b01011 ) || ( opCode[2,5] == 5b00001 ) || ( opCode[2,5] == 5b01001 ) ? 3b010 : function3; readmemory := 0; writememory := 0;

    // REGISTERS Write FLAG AT LAST STAGE OF THE FSM
    REGISTERS.write := FSM[3,1] & EXECUTEwriteRegister & ~EXECUTEfrd & ( rd != 0 ); REGISTERSF.write := FSM[3,1] & EXECUTEwriteRegister & EXECUTEfrd;

    // CPU EXECUTE START FLAGS
    EXECUTEstart := 0;

    // RESET ACTIONS - FSM -> 1, SMT AND PC -> 0 AND DELAY BEFORE CONTINUING
    if( ~reset ) {
        __display("RESET");
        FSM = 1; SMT = 0; pc = 0;
        resetcount = 16hffff; while( resetcount != 0 ) { resetcount = resetcount - 1; }
    }

    while(1) {
        ( address, readmemory ) = fetch( PC, memorybusy );                              // FETCH POTENTIAL COMPRESSED OR 1ST 16 BITS
        compressed = ( readdata[0,2] != 2b11 );
        switch( readdata[0,2] ) {
            default: { instruction = i32; }                                             // EXPAND COMPRESSED INSTRUCTION
            case 2b11: {                                                                // 32 BIT INSTRUCTION FETCH 2ND 16 BITS
                instruction[0,16] = readdata; ( address, readmemory ) = fetch( PCplus2, memorybusy ); instruction[16,16] = readdata;
            }
        }
        FSM = 4b0010;
        ++:
        FSM = 4b0100;
        ++:
        if( memoryload ) { ( address, readmemory, memoryinput ) = load( accesssize, loadAddress, memorybusy, readdata ); }
        EXECUTEstart = 1; while( EXECUTEbusy ) {}
        if( memorystore ) { ( address, writedata, writememory ) = store( accesssize, storeAddress, memoryoutput, memorybusy ); }
        FSM = 4b1000;
        ++:
        // UPDATE PC AND SMT
        if( SMT ) { pcSMT = newPC; SMT = 0; } else { pc = newPC; SMT = SMTRUNNING; pcSMT = SMTRUNNING ? pcSMT : SMTSTARTPC; }
        FSM = 4b0001;
    } // RISC-V
}

algorithm cpuexecute(
    input   uint1   start,
    output  uint1   busy(0),

    input   uint1   SMT,
    input   uint32  instruction,
    input   uint7   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  sourceReg3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,
    input   uint32  immediateValue,
    input   uint32  memoryinput,
    input   uint32  AUIPCLUI,
    input   uint32  nextPC,

    output  uint1   writeRegister,
    output  uint1   frd,
    output  uint1   incPC,
    output  uint1   takeBranch,
    output  uint32  memoryoutput,
    output  uint32  result
) <autorun> {
    // BRANCH COMPARISON UNIT
    uint1   BRANCHtakeBranch = uninitialized;
    branchcomparison BRANCHUNIT(
        opCode <: opCode,
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        takeBranch :> BRANCHtakeBranch
    );

    // ALU
    int32   ALUresult = uninitialized;
    uint1   ALUstart = uninitialized;
    uint1   ALUbusy = uninitialized;
    alu ALU(
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        IshiftCount <: rs2,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        sourceReg3 <: sourceReg3,
        immediateValue <: immediateValue,
        result :> ALUresult,
        start <: ALUstart,
        busy :> ALUbusy
    );

    // ATOMIC MEMORY OPERATIONS
    int32   ALUAresult = uninitialized;
    aluA ALUA(
        function7 <: function7,
        memoryinput <: memoryinput,
        sourceReg2 <: sourceReg2,
        result :> ALUAresult
    );

    // FLOATING POINT OPERATIONS
    uint5   FPUflags = 0;
    uint5   FPUnewflags = uninitialized;
    uint1   FPUfrd = uninitialized;
    uint32  FPUresult = uninitialized;
    uint1   FPUstart = uninitialized;
    uint1   FPUbusy = uninitialized;
    fpu FPU(
        FPUflags <: FPUflags,
        FPUnewflags :> FPUnewflags,
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

    // MANDATORY RISC-V CSR REGISTERS + HARTID == 0 MAIN THREAD == 1 SMT THREAD
    uint32  CSRresult = uninitialized;
    uint1   CSRstart = uninitialized;
    uint1   CSRbusy = uninitialized;
    uint1   CSRincCSRinstret = uninitialized;
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
        busy :> CSRbusy,
        incCSRinstret <: CSRincCSRinstret,
        updateFPUflags <: CSRupdateFPUflags
    );

    // ALU AND CSR START FLAGS
    ALUstart := 0; FPUstart := 0; CSRstart := 0; CSRincCSRinstret := 0; CSRupdateFPUflags := 0;

    while(1) {
        if( start ) {
            busy = 1;
            frd = 0; writeRegister = 1; incPC = 1; takeBranch = 0;
            switch( opCode[2,5] ) {
                case 5b01101: { result = AUIPCLUI; }                                        // LUI
                case 5b00101: { result = AUIPCLUI; }                                        // AUIPC
                case 5b11011: { incPC = 0; result = nextPC; }                               // JAL
                case 5b11001: { incPC = 0; result = nextPC; }                               // JALR
                case 5b11000: { writeRegister = 0; takeBranch = BRANCHtakeBranch; }         // BRANCH
                case 5b00000: { result = memoryinput; }                                     // LOAD
                case 5b01000: { writeRegister = 0; memoryoutput = sourceReg2; }             // STORE
                case 5b00001: { frd = 1; result = memoryinput; }                            // FLOAT LOAD
                case 5b01001: { writeRegister = 0; memoryoutput = sourceReg2F; }            // FLOAT STORE
                case 5b00011: {}                                                            // FENCE[I]
                case 5b11100: {
                    switch( function3 ) {
                        default: { CSRstart = 1; while( CSRbusy ) {} result = CSRresult; }  // CSR
                        case 3b000: { result = 0; }
                    }
                }
                case 5b01011: {                                                             // ATOMIC OPERATIONS
                    switch( function7[2,5] ) {
                        case 5b00010: { result = memoryinput; }                             // LR.W
                        case 5b00011: { memoryoutput = sourceReg2; result = 0; }            // SC.W
                        default: { result = memoryinput; memoryoutput = ALUAresult; }      // ATOMIC LOAD - MODIFY - STORE
                    }
                }
                default: {                                                                  // FPU, ALUI or ALUR
                    if( opCode[6,1] ) {
                        FPUstart = 1; while( FPUbusy ) {} CSRupdateFPUflags = 1; frd = FPUfrd; result = FPUresult;
                    } else {
                        ALUstart = 1; while( ALUbusy ) {} frd = 0; result = ALUresult;
                    }
                }
            }
            busy = 0;
            CSRincCSRinstret = 1;
        }
    }
}
