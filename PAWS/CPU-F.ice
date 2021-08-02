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
        default: {
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
    switch( accesssize[0,2] ) {
        case 2b10: {
            address = location + 2;
            writedata = value[16,16];
            writememory = 1;
            while( memorybusy ) {}
        }
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
    uint7 FSM = 7b0000001;

    // SMT FLAG
    // RUNNING ON HART 0 OR HART 1
    // DUPLICATES PROGRAM COUNTER, REGISTER FILE AND LAST INSTRUCTION CACHE
    uint1   SMT = 0;

    // RISC-V PROGRAM COUNTERS AND STATUS
    uint32  pc = 0;
    uint32  pcSMT = 0;
    uint32  PC <:: SMT ? pcSMT : pc;
    uint32  PCplus2 <: PC + 2;
    uint1   incPC = uninitialized;

    // COMPRESSED INSTRUCTION EXPANDER
    uint32  instruction = uninitialized;
    uint1   compressed = uninitialized;
    compressed COMPRESSED <@clock_CPUdecoder> (
        i16 <: readdata
    );

    // RISC-V REGISTER WRITER
    uint1   memoryload := ( opCode == 7b0000011 ) | ( opCode == 7b0000111 ) | ( ( opCode == 7b0101111 ) & ( function7[2,5] != 5b00011 ) );
    uint1   memorystore := ( opCode == 7b0100011 ) | ( opCode == 7b0100111 ) | ( ( opCode == 7b0101111 ) & ( function7[2,5] != 5b00010 ) );

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
        immediateValue :> immediateValue,
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
        pc <: PC,
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

    // CPU EXECUTE BLOCK
    uint1   takeBranch = uninitialized;
    uint32  memoryinput = uninitialized;
    int32   result = uninitialized;
    uint32  memoryoutput = uninitialized;
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
        AUIPCLUI <: AUIPCLUI,
        nextPC <: nextPC,
        incPC :> incPC,
        takeBranch :> takeBranch,
        memoryoutput :> memoryoutput,
        result :> result
    );

    // MEMORY ACCESS FLAGS
    accesssize := ( opCode == 7b0101111 ) || ( opCode == 7b0000111 ) || ( opCode == 7b0100111 ) ? 3b010 : function3;
    readmemory := 0;
    writememory := 0;

    // REGISTERS Write FLAG
    REGISTERS.write := 0;
    REGISTERSF.write := 0;

    // CPU EXECUTE START FLAGS
    EXECUTE.start := 0;

    while(1) {
        onehot( FSM ) {
            case 0: {                                                                           // FETCH
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
                FSM = 7b0000010;
            }
            case 1: { FSM = 7b0000100;  }                                                       // ALLOW DECODE + REGISTER FETCH
            case 2: { FSM = memoryload ? 7b0001000 : 7b0010000; }                               // ALLOW ADDRESS GENERATION
            case 3: {                                                                           // LOAD FROM MEMORY
                ( address, readmemory, memoryinput ) = load( accesssize, loadAddress, memorybusy, readdata );
                FSM = 7b0010000;
            }
            case 4: {                                                                           // EXECUTE
                EXECUTE.start = 1; while( EXECUTE.busy ) {}
                FSM = memorystore ? 7b0100000 : 7b1000000;
            }
            case 5: {                                                                           // STORE TO MEMORY
                ( address, writedata, writememory ) = store( accesssize, storeAddress, memoryoutput, memorybusy );
                FSM = 7b1000000;
            }
            case 6: {                                                                           // REGISTERS WRITE, PC and SMT
                REGISTERS.write = EXECUTE.writeRegister & ~EXECUTE.frd & ( rd != 0 );           // BASE DO NOT WRITE TO REGISTER 0
                REGISTERSF.write = EXECUTE.writeRegister & EXECUTE.frd;
                switch( SMT ) {
                    case 1b1: {
                        ( pcSMT ) = newPC( opCode, incPC, nextPC, takeBranch, branchAddress, jumpAddress, loadAddress );
                        SMT = 0;
                    }
                    case 1b0: {
                        ( pc ) = newPC( opCode, incPC, nextPC, takeBranch, branchAddress, jumpAddress, loadAddress );
                        SMT = SMTRUNNING;
                        pcSMT = SMTRUNNING ? pcSMT : SMTSTARTPC;
                    }
                }
                FSM = 7b0000001;
            }
        }
    } // RISC-V
}

algorithm cpuexecute(
    input   uint1   start,
    output  uint1   busy,


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
    branchcomparison BRANCHUNIT(
        opCode <: opCode,
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
    );

    // ALU
    alu ALU(
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        IshiftCount <: rs2,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        sourceReg3 <: sourceReg3,
        immediateValue <: immediateValue
    );

    // ATOMIC MEMORY OPERATIONS
    aluA ALUA(
        function7 <: function7,
        memoryinput <: memoryinput,
        sourceReg2 <: sourceReg2
    );

    // FLOATING POINT OPERATIONS
    uint5   FPUflags = 0;
    uint5   FPUnewflags = uninitialized;
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
        sourceReg3F <: sourceReg3F
    );

    // MANDATORY RISC-V CSR REGISTERS + HARTID == 0 MAIN THREAD == 1 SMT THREAD
    CSRblock CSR(
        SMT <: SMT,
        instruction <: instruction,
        function3 <: function3,
        rs1 <: rs1,
        sourceReg1 <: sourceReg1,
        FPUflags :> FPUflags,
        FPUnewflags <: FPUnewflags
    );

    // ALU START FLAGS
    ALU.start := 0; FPU.start := 0;
    CSR.start := 0; CSR.incCSRinstret := 0; CSR.updateFPUflags := 0;

    busy = 0;
    while(1) {
        switch( start ) {
            case 1: {
                busy = 1;
                frd = 0; writeRegister = 1; incPC = 1; takeBranch = 0;
                switch( opCode[2,5] ) {
                    case 5b01101: { result = AUIPCLUI; }                                        // LUI
                    case 5b00101: { result = AUIPCLUI; }                                        // AUIPC
                    case 5b11011: { incPC = 0; result = nextPC; }                               // JAL
                    case 5b11001: { incPC = 0; result = nextPC; }                               // JALR
                    case 5b11000: { writeRegister = 0; takeBranch = BRANCHUNIT.takeBranch; }    // BRANCH
                    case 5b00000: { result = memoryinput; }                                     // LOAD
                    case 5b01000: { writeRegister = 0; memoryoutput = sourceReg2; }             // STORE
                    case 5b00001: { frd = 1; result = memoryinput; }                            // FLOAT LOAD
                    case 5b01001: { writeRegister = 0; memoryoutput = sourceReg2F; }            // FLOAT STORE
                    case 5b11100: {
                        switch( function3 ) {
                            default: { CSR.start = 1; while( CSR.busy ) {} result = CSR.result; }                    // CSR
                            case 3b000: { result = 0; }
                        }
                    }
                    case 5b01011: {                                                             // ATOMIC OPERATIONS
                        switch( function7[2,5] ) {
                            case 5b00010: { result = memoryinput; }                             // LR.W
                            case 5b00011: { memoryoutput = sourceReg2; result = 0; }            // SC.W
                            default: { result = memoryinput; memoryoutput = ALUA.result; }      // ATOMIC LOAD - MODIFY - STORE
                        }
                    }
                    default: {                                                                  // FPU, ALUI or ALUR
                        ALU.start = ~opCode[6,1];
                        FPU.start = opCode[6,1];
                        while( ALU.busy || FPU.busy ) {}
                        frd = opCode[6,1] & FPU.frd;
                        CSR.updateFPUflags = opCode[6,1];
                        result = opCode[6,1] ? FPU.result : ALU.result;
                    }
                }
                busy = 0;
                CSR.incCSRinstret = 1;
            }
            case 0: {}
        }
    }
}
