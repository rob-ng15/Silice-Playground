// RISC-ICE-V
// inspired by https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice
//
// A simple Risc-V RV32IMC processor

algorithm PAWSCPU (
    output  uint3   function3,
    output  uint32  address,
    output  uint16  writedata,
    output  uint1   writememory,
    input   uint16  readdata,
    output  uint1   readmemory,
    output  uint1   Icacheflag,

    input   uint1   memorybusy,

    input   uint1   clock_copro
) <autorun> {
    // RISC-V REGISTERS
    simple_dualport_bram int32 registers_1 <input!> [64] = { 0, pad(0) };
    simple_dualport_bram int32 registers_2 <input!> [64] = { 0, pad(0) };

    // RISC-V PROGRAM COUNTER AND STATUS
    uint32  pc = 0;
    uint32  pcPLUS2 = uninitialized;
    uint32  nextPC = uninitialized;
    uint1   compressed = uninitialized;
    uint1   floatingpoint = uninitialized;
    uint1   takeBranch = uninitialized;
    uint1   incPC = uninitialized;

    // RISC-V REGISTER WRITER
    int32   result = uninitialized;
    uint1   writeRegister = uninitialized;
    registersWRITE registersW(
        rd <: rd,
        floatingpoint <: floatingpoint,
        result <: result,
        registers_1 <:> registers_1,
        registers_2 <:> registers_2
    );

    // RISC-V REGISTER READER
    int32   sourceReg1 = uninitialized;
    int32   sourceReg2 = uninitialized;
    registersREAD registersR(
        rs1 <: rs1,
        rs2 <: rs2,
        floatingpoint <: floatingpoint,
        sourceReg1 :> sourceReg1,
        sourceReg2 :> sourceReg2,
        registers_1 <:> registers_1,
        registers_2 <:> registers_2
    );

    // COMPRESSED INSTRUCTION EXPANDER
    uint32  instruction = uninitialized;
    uint32  instruction32 = uninitialized;
    uint1   IScompressed = uninitialized;
    compressedexpansion compressedunit(
        compressed :> IScompressed,
        i16 <: readdata,
        i32 :> instruction32,
    );

    // RISC-V 32 BIT INSTRUCTION DECODER
    int32   immediateValue = uninitialized;
    uint7   opCode = uninitialized;
    uint7   function7 = uninitialized;
    uint5   IshiftCount = uninitialized;
    uint5   rs1 = uninitialized;
    uint5   rs2 = uninitialized;
    uint5   rd = uninitialized;
    decoder DECODE(
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

    // RISC-V ADDRESS GENERATOR
    uint32  branchAddress = uninitialized;
    uint32  jumpAddress = uninitialized;
    uint32  loadAddress = uninitialized;
    uint32  loadAddressPLUS2 = uninitialized;
    uint32  storeAddress = uninitialized;
    uint32  storeAddressPLUS2 = uninitialized;
    uint32  AUIPCLUI = uninitialized;
    addressgenerator AGU(
        instruction <: instruction,
        pc <:: pc,
        compressed <: compressed,
        sourceReg1 <: sourceReg1,
        pcPLUS2 :> pcPLUS2,
        nextPC :> nextPC,
        branchAddress :> branchAddress,
        jumpAddress :> jumpAddress,
        AUIPCLUI :> AUIPCLUI,
        storeAddress :> storeAddress,
        storeAddressPLUS2 :> storeAddressPLUS2,
        loadAddress :> loadAddress,
        loadAddressPLUS2 :> loadAddressPLUS2
    );

    // RISC-V BASE ALU IMMEDIATE REGISTER + M EXTENSION
    // <@clock_copro>
    aluI ALUI <@clock_copro> (
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        immediateValue <: immediateValue,
        IshiftCount <: IshiftCount,
        sourceReg1 <: sourceReg1
    );
    aluR ALUR <@clock_copro> (
        opCode <: opCode,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
    );
    aluM ALUM <@clock_copro> (
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
    );

    // BRANCH COMPARISON UNIT
    uint1   BRANCHtakeBranch = uninitialized;
    branchcomparison branchcomparisonunit(
        opCode <: opCode,
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        takeBranch :> BRANCHtakeBranch
    );

    // COMBINE TWO 16 BIT HALF WORDS TO ONE 32 BIT WORD
    uint16  LOW = uninitialized;
    uint16  HIGH = uninitialized;
    uint32  HIGHLOW = uninitialized;
    halfhalfword combiner161632unit(
        LOW <: LOW,
        HIGH <: HIGH,
        HIGHLOW :> HIGHLOW
    );

    uint8   SE8nosign = uninitialized;
    int32   SE8sign = uninitialized;
    signextender8 signextender8unit(
        function3 <: function3,
        nosign <: SE8nosign,
        withsign :> SE8sign
    );
    uint16  SE16nosign = uninitialized;
    int32   SE16sign = uninitialized;
    signextender16 signextender16unit(
        function3 <: function3,
        nosign <: SE16nosign,
        withsign :> SE16sign
    );

    // CSR REGISTERS
    CSRblock CSR(
        instruction <: instruction
    );

    // 8/16 bit READ WITH OPTIONAL SIGN EXTENSION
    SE8nosign := readdata[address[0,1] ? 8 : 0, 8];
    SE16nosign := readdata;

    // MEMORY ACCESS FLAGS
    readmemory := 0;
    writememory := 0;

    // REGISTER Read/Write Flags
    registersW.writeRegister := 0;

    // ALU Start Flag
    ALUM.start := 0;

    // CSR instructions retired increment flag
    CSR.incCSRinstret := 0;

    while(1) {
        // RISC-V
        writeRegister = 0;
        takeBranch = 0;
        incPC = 1;
        floatingpoint = 0;

        // FETCH + EXPAND COMPRESSED INSTRUCTIONS
        address = pc;
        Icacheflag = 1;
        readmemory = 1;
        while( memorybusy ) {}
        compressed = IScompressed;
        switch( IScompressed ) {
            case 1b0: {
                // 32 bit instruction
                LOW = instruction32;
                address = pcPLUS2;
                readmemory = 1;
                while( memorybusy ) {}
                HIGH = readdata;
                instruction = HIGHLOW;
            }
            case 1b1: {
                // 16 bit compressed instruction
                instruction = instruction32;
            }
        }

        // DECODE + REGISTER FETCH
        // HAPPENS AUTOMATICALLY in DECODE AND REGISTER UNITS
        ++:
        ++:

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
                takeBranch = BRANCHtakeBranch;
            }
            case 5b00000: {
                // LOAD
                writeRegister = 1;
                address = loadAddress;
                Icacheflag = 0;
                readmemory = 1;
                while( memorybusy ) {}
                switch( function3 & 3 ) {
                    case 2b10: {
                        // 32 bit READ as 2 x 16 bit
                        LOW = readdata;
                        address = loadAddressPLUS2;
                        readmemory = 1;
                        while( memorybusy ) {}
                        HIGH = readdata;
                        result = HIGHLOW;
                    }
                    default: {
                        // 8/16 bit with optional sign extension
                        result = ( ( function3 & 3 ) == 0 ) ? SE8sign : SE16sign;
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
                    address = storeAddressPLUS2;
                    writedata = sourceReg2[16,16];
                    writememory = 1;
                    while( memorybusy ) {}
                }
            }
            case 5b00100: {
                // ALUI
                writeRegister = 1;
                result = ALUI.result;
            }
            case 5b01100: {
                // ALUR ( BASE + M EXTENSION )
                writeRegister = 1;
                if( function7[0,1] ) {
                    ALUM.start = 1;
                    while( ALUM.busy ) {}
                }
                result = function7[0,1] ? ALUM.result : ALUR.result;
            }
            case 5b11100: {
                // CSR
                writeRegister = 1;
                result = CSR.result;
            }
        }

        // WRITE TO REGISTERS
        registersW.writeRegister = writeRegister;

        // UPDATE PC
        pc = ( incPC ) ? ( takeBranch ? branchAddress : nextPC ) : ( opCode[3,1] ? jumpAddress : loadAddress );

        // Update CSRinstret
        CSR.incCSRinstret = 1;
    } // RISC-V
}
