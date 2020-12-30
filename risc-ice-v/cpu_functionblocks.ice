// RISC-ICE-V
// inspired by https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice
//
// A simple Risc-V RV32I processor

// RISC-V BASE INSTRUCTION BITFIELDS
bitfield    Btype {
    uint1   immediate_bits_12,
    uint6   immediate_bits_10_5,
    uint5   sourceReg2,
    uint5   sourceReg1,
    uint3   function3,
    uint4   immediate_bits_4_1,
    uint1   immediate_bits_11,
    uint7   opcode
}

bitfield    Itype {
    uint12  immediate,
    uint5   sourceReg1,
    uint3   function3,
    uint5   destReg,
    uint7   opcode
}

bitfield    ItypeSHIFT {
    uint7   function7,
    uint5   shiftCount,
    uint5   sourceReg1,
    uint3   function3,
    uint5   destReg,
    uint7   opcode
}

bitfield    Jtype {
    uint1   immediate_bits_20,
    uint10  immediate_bits_10_1,
    uint1   immediate_bits_11,
    uint8   immediate_bits_19_12,
    uint5   destReg,
    uint7   opcode
}

bitfield    Rtype {
    uint7   function7,
    uint5   sourceReg2,
    uint5   sourceReg1,
    uint3   function3,
    uint5   destReg,
    uint7   opCode
}

bitfield Stype {
    uint7   immediate_bits_11_5,
    uint5   sourceReg2,
    uint5   sourceReg1,
    uint3   function3,
    uint5   immediate_bits_4_0,
    uint7   opcode
}

bitfield Utype {
    uint20  immediate_bits_31_12,
    uint5   destReg,
    uint7   opCode
}

// COMPRESSED Risc-V Instruction Bitfields
bitfield    CBalu {
    uint3   function3,
    uint1   ib_5,
    uint2   function2,
    uint3   rd_alt,
    uint2   logical2,
    uint3   rs2_alt,
    uint2   opcode
}
bitfield    CBalu50 {
    uint3   function3,
    uint1   ib_5,
    uint2   function2,
    uint3   rd_alt,
    uint5   ib_4_0,
    uint2   opcode
}
bitfield    CB {
    uint3   function3,
    uint1   offset_8,
    uint2   offset_4_3,
    uint3   rs1_alt,
    uint2   offset_7_6,
    uint2   offset_2_1,
    uint1   offset_5,
    uint2   opcode
}

bitfield    CI {
    uint3   function3,
    uint1   ib_5,
    uint5   rd,
    uint3   ib_4_2,
    uint2   ib_7_6,
    uint2   opcode
}
bitfield    CI50 {
    uint3   function3,
    uint1   ib_5,
    uint5   rd,
    uint5   ib_4_0,
    uint2   opcode
}
bitfield    CI94 {
    uint3   function3,
    uint1   ib_9,
    uint5   rd,
    uint1   ib_4,
    uint1   ib_6,
    uint2   ib_8_7,
    uint1   ib_5,
    uint2   opcode
}
bitfield    CIu94 {
    uint3   function3,
    uint2   ib_5_4,
    uint4   ib_9_6,
    uint1   ib_2,
    uint1   ib_3,
    uint3   rd_alt,
    uint2   opcode
}
bitfield    CIlui {
    uint3   function3,
    uint1   ib_17,
    uint5   rd,
    uint5   ib_16_12,
    uint2   opcode
}

bitfield    CJ {
    uint3   function3,
    uint1   ib_11,
    uint1   ib_4,
    uint2   ib_9_8,
    uint1   ib_10,
    uint1   ib_6,
    uint1   ib_7,
    uint3   ib_3_1,
    uint1   ib_5,
    uint2   opcode
}

bitfield    CL {
    uint3   function3,
    uint3   ib_5_3,
    uint3   rs1_alt,
    uint1   ib_2,
    uint1   ib_6,
    uint3   rd_alt,
    uint2   opcode
}

bitfield    CR {
    uint4   function4,
    uint5   rs1,
    uint5   rs2,
    uint2   opcode
}

bitfield    CS {
    uint3   function3,
    uint1   ib_5,
    uint2   ib_4_3,
    uint3   rs1_alt,
    uint1   ib_2,
    uint1   ib_6,
    uint3   rs2_alt,
    uint2   opcode
}

bitfield    CSS {
    uint3   function3,
    uint1   ib_5,
    uint3   ib_4_2,
    uint2   ib_7_6,
    uint5   rs2,
    uint2   opcode
}

algorithm PAWSCPU (
    output  uint3   function3,
    output  uint32  address,
    output  uint16  writedata,
    output  uint1   writememory,
    input   uint16  readdata,
    input   int32   readdata8,
    input   int32   readdata16,
    output  uint1   readmemory,
    output  uint1   Icacheflag,

    input   uint1   memorybusy,

    input   uint1   clock_cpuunit,
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
    uint16  sourceReg2LOW = uninitialized;
    uint16  sourceReg2HIGH = uninitialized;
    registersREAD registersR(
        rs1 <: rs1,
        rs2 <: rs2,
        floatingpoint <: floatingpoint,
        sourceReg1 :> sourceReg1,
        sourceReg2 :> sourceReg2,
        sourceReg2LOW :> sourceReg2LOW,
        sourceReg2HIGH :> sourceReg2HIGH,
        registers_1 <:> registers_1,
        registers_2 <:> registers_2
    );

    // COMPRESSED INSTRUCTION EXPANDER
    uint32  instruction = uninitialized;
    uint32  instruction32 = uninitialized;
    uint1   IScompressed = uninitialized;
    // <@clock_cpuunit>
    compressedexpansion compressedunit(
        compressed :> IScompressed,
        instruction16 <: readdata,
        instruction32 :> instruction32,
    );

    // RISC-V 32 BIT INSTRUCTION DECODER
    int32   immediateValue = uninitialized;
    uint7   opCode = uninitialized;
    uint7   function7 = uninitialized;
    uint5   rs1 = uninitialized;
    uint5   rs2 = uninitialized;
    uint5   rd = uninitialized;
    // <@clock_cpuunit>
    decoder DECODE(
        instruction <: instruction,
        opCode :> opCode,
        function3 :> function3,
        function7 :> function7,
        rs1 :> rs1,
        rs2 :> rs2,
        rd :> rd,
        immediateValue :> immediateValue
    );

    // RISC-V ADDRESS GENERATOR
    uint32  branchAddress = uninitialized;
    uint32  jumpAddress = uninitialized;
    uint32  loadAddress = uninitialized;
    uint32  loadAddressPLUS2 = uninitialized;
    uint32  storeAddress = uninitialized;
    uint32  storeAddressPLUS2 = uninitialized;
    uint32  AUIPCLUI = uninitialized;
    // <@clock_cpuunit>
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

    // RISC-V BASE ALU
    alu ALU <@clock_copro> (
        instruction <: instruction,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
    );

    // BRANCH COMPARISON UNIT
    uint1   BRANCHtakeBranch = uninitialized;
    // <@clock_cpuunit>
    branchcomparison branchcomparisonunit(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        takeBranch :> BRANCHtakeBranch
    );

    // COMBINE TWO 16 BIT HALF WORDS TO ONE 32 BIT WORD
    uint16  LOW = uninitialized;
    uint16  HIGH = uninitialized;
    uint32  HIGHLOW = uninitialized;
    // <@clock_cpuunit>
    halfhalfword combiner161632unit(
        LOW <: LOW,
        HIGH <: HIGH,
        HIGHLOW :> HIGHLOW
    );

    // MEMORY ACCESS FLAGS
    readmemory := 0;
    writememory := 0;

    // REGISTER Read/Write Flags
    registersW.writeRegister := 0;

    // ALU Start Flag
    ALU.start := 0;

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
                        result = ( ( function3 & 3 ) == 0 ) ? readdata8 : readdata16;
                    }
                }
            }
            case 5b01000: {
                // STORE
                // WRITE 8, 16 and LOWER 16 of 32 bits
                address = storeAddress;
                writedata = sourceReg2LOW;
                writememory = 1;
                while( memorybusy ) {}
                if(  ( function3 & 3 ) == 2b10 ) {
                    // WRITE UPPER 16 of 32 bits
                    address = storeAddressPLUS2;
                    writedata = sourceReg2HIGH;
                    writememory = 1;
                    while( memorybusy ) {}
                }
            }
            case 5b00100: {
                // ALUI
                writeRegister = 1;
                result = ALU.result;
            }
            case 5b01100: {
                // ALUR
                writeRegister = 1;
                if( function7[0,1] ) {
                    ALU.start = 1;
                    while( ALU.busy ) {}
                }
                result = function7[0,1] ? ALU.Mresult : ALU.result;
            }
        }

        // WRITE TO REGISTERS
        registersW.writeRegister = writeRegister;

        // UPDATE PC
        pc = ( incPC ) ? ( takeBranch ? branchAddress : nextPC ) : ( opCode[3,1] ? jumpAddress : loadAddress );
    } // RISC-V
}

// RISC-V REGISTER WRITE
algorithm registersWRITE (
    input   uint5   rd,
    input   uint1   writeRegister,
    input   uint1   floatingpoint,
    input   int32   result,

    simple_dualbram_port1   registers_1,
    simple_dualbram_port1   registers_2
) <autorun> {
    registers_1.wenable1 := 1;
    registers_2.wenable1 := 1;

    while(1) {
        // WRITE TO REGISTERS
        // NEVER write to registers[0]
        if( writeRegister && ( rd != 0 ) ) {
            registers_1.addr1 = rd + ( floatingpoint ? 32 : 0 );
            registers_1.wdata1 = result;
            registers_2.addr1 = rd + ( floatingpoint ? 32 : 0 );
            registers_2.wdata1 = result;
        }
    }
}

// RISC-V REGISTER READ
algorithm registersREAD (
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint1   floatingpoint,

    output! int32   sourceReg1,
    output! int32   sourceReg2,
    output! uint16  sourceReg2LOW,
    output! uint16  sourceReg2HIGH,

    simple_dualbram_port0   registers_1,
    simple_dualbram_port0   registers_2
) <autorun> {
    registers_1.addr0 := rs1 + ( floatingpoint ? 32 : 0 );
    registers_2.addr0 := rs2 + ( floatingpoint ? 32 : 0 );

    sourceReg1 := registers_1.rdata0;
    sourceReg2 := registers_2.rdata0;
    sourceReg2LOW := registers_2.rdata0[0,16];
    sourceReg2HIGH := registers_2.rdata0[16,16];

    while(1) {
    }
}

// RISC-V INSTRUCTION DECODER
algorithm decoder (
    input   uint32  instruction,

    output  uint7   opCode,
    output  uint3   function3,
    output  uint7   function7,

    output  uint5   rs1,
    output  uint5   rs2,
    output  uint5   rd,

    output  int32   immediateValue
) <autorun> {
    opCode := Utype(instruction).opCode;
    function3 := Rtype(instruction).function3;
    function7 := Rtype(instruction).function7;

    rs1 := Rtype(instruction).sourceReg1;
    rs2 := Rtype(instruction).sourceReg2;
    rd := Rtype(instruction).destReg;

    immediateValue := { instruction[31,1] ? 20b11111111111111111111 : 20b00000000000000000000, Itype(instruction).immediate };

    while(1) {
    }
}

// RISC-V ADDRESS BASE/OFFSET GENERATOR
algorithm addressgenerator (
    input   uint32  instruction,
    input   uint32  pc,
    input   uint1   compressed,
    input!  int32   sourceReg1,

    output  uint32  pcPLUS2,
    output  uint32  nextPC,
    output  uint32  branchAddress,
    output  uint32  jumpAddress,
    output  uint32  AUIPCLUI,
    output! uint32  storeAddress,
    output! uint32  storeAddressPLUS2,
    output! uint32  loadAddress,
    output! uint32  loadAddressPLUS2
) <autorun> {
    uint7   opCode := Utype(instruction).opCode;
    int32   immediateValue := { instruction[31,1] ? 20b11111111111111111111 : 20b00000000000000000000, Itype(instruction).immediate };

    pcPLUS2 := pc + 2;
    nextPC := pc + ( compressed ? 2 : 4 );

    branchAddress := { Btype(instruction).immediate_bits_12 ? 20b11111111111111111111 : 20b00000000000000000000, Btype(instruction).immediate_bits_11, Btype(instruction).immediate_bits_10_5, Btype(instruction).immediate_bits_4_1, 1b0 } + pc;

    jumpAddress := { Jtype(instruction).immediate_bits_20 ? 12b111111111111 : 12b000000000000, Jtype(instruction).immediate_bits_19_12, Jtype(instruction).immediate_bits_11, Jtype(instruction).immediate_bits_10_1, 1b0 } + pc;

    AUIPCLUI := { Utype(instruction).immediate_bits_31_12, 12b0 } + ( opCode[5,1] ? 0 : pc );

    storeAddress := { instruction[31,1] ? 20b11111111111111111111 : 20b00000000000000000000, Stype(instruction).immediate_bits_11_5, Stype(instruction).immediate_bits_4_0 } + sourceReg1;
    storeAddressPLUS2 := { instruction[31,1] ? 20b11111111111111111111 : 20b00000000000000000000, Stype(instruction).immediate_bits_11_5, Stype(instruction).immediate_bits_4_0 } + sourceReg1 + 2;

    loadAddress := immediateValue + sourceReg1;
    loadAddressPLUS2 := immediateValue + sourceReg1 + 2;

    while(1) {
    }
}

// RISC-V ALU BASE + M EXTENSION
algorithm alu (
    input   uint32  instruction,
    input   int32   sourceReg1,
    input   int32   sourceReg2,

    input   uint1   start,
    output  uint1   busy,

    output  int32   result,
    output  int32   Mresult
) <autorun> {
    uint7   opCode := Utype(instruction).opCode;
    uint3   function3 := Rtype(instruction).function3;
    uint7   function7 := Rtype(instruction).function7;
    int32   immediateValue := { instruction[31,1] ? 20b11111111111111111111 : 20b00000000000000000000, Itype(instruction).immediate };

    int32   shiftRIGHTA := __signed(sourceReg1) >>> ( opCode[5,1] ? sourceReg2[0,5] : ItypeSHIFT( instruction ).shiftCount );
    int32   shiftRIGHTL := __unsigned(sourceReg1) >> ( opCode[5,1] ? sourceReg2[0,5] : ItypeSHIFT( instruction ).shiftCount );

    uint1   SLT := __signed( sourceReg1 ) < __signed(sourceReg2) ? 1 : 0;
    uint1   SLTI := __signed( sourceReg1 ) < __signed(immediateValue) ? 1 : 0;
    uint1   SLTU := ( Rtype(instruction).sourceReg1 == 0 ) ? ( ( sourceReg2 != 0 ) ? 1 : 0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ) ? 1 : 0 );
    uint1   SLTUI := ( immediateValue == 1 ) ? ( ( sourceReg1 == 0 ) ? 1 : 0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ) ? 1 : 0 );

    uint1   active = 0;

    // MULTIPLICATION and DIVISION units
    divideremainder dividerunit (
        function3 <: function3,
        dividend <: sourceReg1,
        divisor <: sourceReg2
    );
    multiplicationDSP multiplicationuint (
        function3 <: function3,
        factor_1 <: sourceReg1,
        factor_2 <: sourceReg2
    );

    // MULTIPLICATION and DIVISION Start Flags
    dividerunit.start := 0;
    multiplicationuint.start := 0;
    busy := start ? 1 : active;

    while(1) {
        if( start ) {
            // M EXTENSION
            switch( function3[2,1] ) {
                case 1b0: {
                    // MULTIPLICATION
                    active = 1;
                    multiplicationuint.start = 1;
                    while( multiplicationuint.active ) {}
                    Mresult = multiplicationuint.result;
                    active = 0;
                }
                case 1b1: {
                    // DIVISION / REMAINDER
                    active = 1;
                    dividerunit.start = 1;
                    while( dividerunit.active ) {}
                    Mresult = dividerunit.result;
                    active = 0;
                }
            }
        } else {
            // BASE
            switch( function3 ) {
                case 3b000: { result = sourceReg1 + ( opCode[5,1] ? ( function7[5,1] ? -( sourceReg2 ) : sourceReg2 ) : immediateValue ); }
                case 3b001: { result = __unsigned(sourceReg1) << ( opCode[5,1] ? sourceReg2[0,5] : ItypeSHIFT( instruction ).shiftCount ); }
                case 3b010: { result = ( opCode[5,1] ? SLT : SLTI ) ? 32b1 : 32b0; }
                case 3b011: { result = ( opCode[5,1] ? SLTU : SLTUI ) ? 32b1 : 32b0; }
                case 3b100: { result = sourceReg1 ^ ( opCode[5,1] ? sourceReg2 : immediateValue ); }
                case 3b101: { result = function7[5,1] ? shiftRIGHTA : shiftRIGHTL; }
                case 3b110: { result = sourceReg1 | ( opCode[5,1] ? sourceReg2 : immediateValue ); }
                case 3b111: { result = sourceReg1 & ( opCode[5,1] ? sourceReg2 : immediateValue ); }
            }
        }
    }
}

// BRANCH COMPARISIONS
algorithm branchcomparison (
    input   uint3   function3,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    output! uint1   takeBranch
) <autorun> {
    while(1) {
        switch( function3 ) {
            case 3b000: { takeBranch = ( sourceReg1 == sourceReg2 ) ? 1 : 0; }
            case 3b001: { takeBranch = ( sourceReg1 != sourceReg2 ) ? 1 : 0; }
            case 3b100: { takeBranch = ( __signed(sourceReg1) < __signed(sourceReg2) ) ? 1 : 0; }
            case 3b101: { takeBranch = ( __signed(sourceReg1) >= __signed(sourceReg2) )  ? 1 : 0; }
            case 3b110: { takeBranch = ( __unsigned(sourceReg1) < __unsigned(sourceReg2) ) ? 1 : 0; }
            case 3b111: { takeBranch = ( __unsigned(sourceReg1) >= __unsigned(sourceReg2) ) ? 1 : 0; }
            default: { takeBranch = 0; }
        }
    }
}

// EXPAND RISC-V 16 BIT COMPRESSED INSTRUCTIONS TO THEIR 32 BIT EQUIVALENT
algorithm compressedexpansion (
    input!  uint16  instruction16,
    output! uint32  instruction32,
    output! uint1   compressed
) <autorun> {
    while(1) {
        switch( instruction16[0,2] ) {
            case 2b00: {
                compressed = 1;

                switch( instruction16[13,3] ) {
                    case 3b000: {
                        // ADDI4SPN -> addi rd', x2, nzuimm[9:2]
                        // { 000, nzuimm[5:4|9:6|2|3] rd' 00 } -> { imm[11:0] rs1 000 rd 0010011 }
                        instruction32 = { 2b0, CIu94(instruction16).ib_9_6, CIu94(instruction16).ib_5_4, CIu94(instruction16).ib_3, CIu94(instruction16).ib_2, 2b00, 5h2, 3b000, {2b01,CIu94(instruction16).rd_alt}, 7b0010011 };
                    }
                    case 3b001: {
                        // FLD
                    }
                    case 3b010: {
                        // LW -> lw rd', offset[6:2](rs1')
                        // { 010 uimm[5:3] rs1' uimm[2][6] rd' 00 } -> { imm[11:0] rs1 010 rd 0000011 }
                        instruction32 = { 5b0, CL(instruction16).ib_6, CL(instruction16).ib_5_3, CL(instruction16).ib_2, 2b00, {2b01,CL(instruction16).rs1_alt}, 3b010, {2b01,CL(instruction16).rd_alt}, 7b0000011};
                    }
                    case 3b011: {
                        // FLW
                    }
                    case 3b100: {
                        // reserved
                    }
                    case 3b101: {
                        // FSD
                    }
                    case 3b110: {
                        // SW -> sw rs2', offset[6:2](rs1')
                        // { 110 uimm[5:3] rs1' uimm[2][6] rs2' 00 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100011 }
                        instruction32 = { 5b0, CS(instruction16).ib_6, CS(instruction16).ib_5, {2b01,CS(instruction16).rs2_alt}, {2b01,CS(instruction16).rs1_alt}, 3b010, CS(instruction16).ib_4_3, CS(instruction16).ib_2, 2b0, 7b0100011 };
                    }
                    case 3b111: {
                        // FSW
                    }
                }
            }

            case 2b01: {
                compressed = 1;

                switch( instruction16[13,3] ) {
                    case 3b000: {
                        // ADDI -> addi rd, rd, nzimm[5:0]
                        // { 000 nzimm[5] rs1/rd!=0 nzimm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                        instruction32 = { CI50(instruction16).ib_5 ? 7b1111111 : 7b0000000, CI50(instruction16).ib_4_0, CI50(instruction16).rd, 3b000, CI50(instruction16).rd, 7b0010011 };
                    }
                    case 3b001: {
                        // JAL -> jal x1, offset[11:1]
                        // { 001, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
                        instruction32 = { CJ(instruction16).ib_11, CJ(instruction16).ib_10, CJ(instruction16).ib_9_8, CJ(instruction16).ib_7, CJ(instruction16).ib_6, CJ(instruction16).ib_5, CJ(instruction16).ib_4, CJ(instruction16).ib_3_1, CJ(instruction16).ib_11 ? 9b111111111 : 9b000000000, 5h1, 7b1101111 };
                    }
                    case 3b010: {
                        // LI -> addi rd, x0, imm[5:0]
                        // { 010 imm[5] rd!=0 imm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                        instruction32 = { CI50(instruction16).ib_5 ? 7b1111111 : 7b0000000, CI50(instruction16).ib_4_0, 5h0, 3b000, CI(instruction16).rd, 7b0010011 };
                    }
                    case 3b011: {
                        // LUI / ADDI16SP
                        if( ( CI(instruction16).rd != 0 ) && ( CI(instruction16).rd != 2 ) ) {
                            // LUI -> lui rd, nzuimm[17:12]
                            // { 011 nzimm[17] rd!={0,2} nzimm[16:12] 01 } -> { imm[31:12] rd 0110111 }
                            instruction32 = { CIlui(instruction16).ib_17 ? 15b111111111111111 : 15b000000000000000, CIlui(instruction16).ib_16_12, CIlui(instruction16).rd, 7b0110111 };
                        } else {
                            // ADDI16SP -> addi x2, x2, nzimm[9:4]
                            // { 011 nzimm[9] 00010 nzimm[4|6|8:7|5] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                            instruction32 = { CI94(instruction16).ib_9 ? 3b111 : 3b000, CI94(instruction16).ib_8_7, CI94(instruction16).ib_6, CI94(instruction16).ib_5, CI94(instruction16).ib_4, 4b0000, 5h2, 3b000, 5h2, 7b0010011 };
                        }
                    }
                    case 3b100: {
                        // MISC-ALU
                        switch( CBalu(instruction16).function2 ) {
                            case 2b00: {
                                // SRLI -> srli rd', rd', shamt[5:0]
                                // { 100 nzuimm[5] 00 rs1'/rd' nzuimm[4:0] 01 } -> { 0000000 shamt rs1 101 rd 0010011 }
                                instruction32 = { 7b0000000, CBalu50(instruction16).ib_4_0, { 2b01, CBalu50(instruction16).rd_alt }, 3b101, { 2b01, CBalu50(instruction16).rd_alt }, 7b0010011 };
                            }
                            case 2b01: {
                                // SRAI -> srai rd', rd', shamt[5:0]
                                // { 100 nzuimm[5] 01 rs1'/rd' nzuimm[4:0] 01 } -> { 0100000 shamt rs1 101 rd 0010011 }
                                instruction32 = { 7b0100000, CBalu50(instruction16).ib_4_0, { 2b01, CBalu50(instruction16).rd_alt }, 3b101, { 2b01, CBalu50(instruction16).rd_alt }, 7b0010011 };
                            }
                            case 2b10: {
                                // ANDI -> andi rd', rd', imm[5:0]
                                // { 100 imm[5], 10 rs1'/rd' imm[4:0] 01 } -> { imm[11:0] rs1 111 rd 0010011 }
                                instruction32 = { CBalu50(instruction16).ib_5 ? 7b1111111 : 7b0000000, CBalu50(instruction16).ib_4_0, { 2b01, CBalu50(instruction16).rd_alt }, 3b111, { 2b01, CBalu50(instruction16).rd_alt }, 7b0010011 };
                            }
                            case 2b11: {
                                // SUB XOR OR AND
                                switch( CBalu(instruction16).logical2 ) {
                                    case 2b00: {
                                        //SUB -> sub rd', rd', rs2'
                                        // { 100 0 11 rs1'/rd' 00 rs2' 01 } -> { 0100000 rs2 rs1 000 rd 0110011 }
                                        instruction32 = { 7b0100000, { 2b01, CBalu(instruction16).rs2_alt }, { 2b01, CBalu(instruction16).rd_alt }, 3b000, { 2b01, CBalu(instruction16).rd_alt }, 7b0110011 };
                                    }
                                    case 2b01: {
                                        // XOR -> xor rd', rd', rs2'
                                        // { 100 0 11 rs1'/rd' 01 rs2' 01 } -> { 0000000 rs2 rs1 100 rd 0110011 }
                                        instruction32 = { 7b0000000, { 2b01, CBalu(instruction16).rs2_alt }, { 2b01, CBalu(instruction16).rd_alt }, 3b100, { 2b01, CBalu(instruction16).rd_alt }, 7b0110011 };
                                    }
                                    case 2b10: {
                                        // OR -> or rd', rd', rd2'
                                        // { 100 0 11 rs1'/rd' 10 rs2' 01 } -> { 0000000 rs2 rs1 110 rd 0110011 }
                                        instruction32 = { 7b0000000, { 2b01, CBalu(instruction16).rs2_alt }, { 2b01, CBalu(instruction16).rd_alt }, 3b110, { 2b01, CBalu(instruction16).rd_alt }, 7b0110011 };
                                    }
                                    case 2b11: {
                                        // AND -> and rd', rd', rs2'
                                        // { 100 0 11 rs1'/rd' 11 rs2' 01 } -> { 0000000 rs2 rs1 111 rd 0110011 }
                                        instruction32 = { 7b0000000, { 2b01, CBalu(instruction16).rs2_alt }, { 2b01, CBalu(instruction16).rd_alt }, 3b111, { 2b01, CBalu(instruction16).rd_alt }, 7b0110011 };
                                    }
                                }
                            }
                        }
                    }
                    case 3b101: {
                        // J -> jal, x0, offset[11:1]
                        // { 101, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
                        instruction32 = { CJ(instruction16).ib_11, CJ(instruction16).ib_10, CJ(instruction16).ib_9_8, CJ(instruction16).ib_7, CJ(instruction16).ib_6, CJ(instruction16).ib_5, CJ(instruction16).ib_4, CJ(instruction16).ib_3_1, CJ(instruction16).ib_11 ? 9b111111111 : 9b000000000, 5h0, 7b1101111 };
                    }
                    case 3b110: {
                        // BEQZ -> beq rs1', x0, offset[8:1]
                        // { 110, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 000 imm[4:1|11] 1100011 }
                        instruction32 = { CB(instruction16).offset_8 ? 4b1111 : 4b0000, CB(instruction16).offset_7_6, CB(instruction16).offset_5, 5h0, {2b01,CB(instruction16).rs1_alt}, 3b000, CB(instruction16).offset_4_3, CB(instruction16).offset_2_1, CB(instruction16).offset_8, 7b1100011 };
                    }
                    case 3b111: {
                        // BNEZ -> bne rs1', x0, offset[8:1]
                        // { 111, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 001 imm[4:1|11] 1100011 }
                        instruction32 = { CB(instruction16).offset_8 ? 4b1111 : 4b0000, CB(instruction16).offset_7_6, CB(instruction16).offset_5, 5h0, {2b01,CB(instruction16).rs1_alt}, 3b001, CB(instruction16).offset_4_3, CB(instruction16).offset_2_1, CB(instruction16).offset_8, 7b1100011 };
                    }
                }
            }

            case 2b10: {
                compressed = 1;

                switch( instruction16[13,3] ) {
                    case 3b000: {
                        // SLLI -> slli rd, rd, shamt[5:0]
                        // { 000, nzuimm[5], rs1/rd!=0 nzuimm[4:0] 10 } -> { 0000000 shamt rs1 001 rd 0010011 }
                        instruction32 = { 7b0000000, CI50(instruction16).ib_4_0, CI50(instruction16).rd, 3b001, CI50(instruction16).rd, 7b0010011 };
                    }
                    case 3b001: {
                        // FLDSP
                    }
                    case 3b010: {
                        // LWSP -> lw rd, offset[7:2](x2)
                        // { 011 uimm[5] rd uimm[4:2|7:6] 10 } -> { imm[11:0] rs1 010 rd 0000011 }
                        instruction32 = { 4b0, CI(instruction16).ib_7_6, CI(instruction16).ib_5, CI(instruction16).ib_4_2, 2b0, 5h2 ,3b010, CI(instruction16).rd, 7b0000011 };
                    }
                    case 3b011: {
                        // FLWSP
                    }
                    case 3b100: {
                        // J[AL]R / MV / ADD
                        switch( instruction16[12,1] ) {
                            case 1b0: {
                                // JR / MV
                                if( CR(instruction16).rs2 == 0 ) {
                                    // JR -> jalr x0, rs1, 0
                                    // { 100 0 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                                    instruction32 = { 12b0, CR(instruction16).rs1, 3b000, 5h0, 7b1100111 };
                                } else {
                                    // MV -> add rd, x0, rs2
                                    // { 100 0 rd!=0 rs2!=0 10 } -> { 0000000 rs2 rs1 000 rd 0110011 }
                                    instruction32 = { 7b0000000, CR(instruction16).rs2, 5h0, 3b000, CR(instruction16).rs1, 7b0110011 };
                                }
                            }
                            case 1b1: {
                                // JALR / ADD
                                if( CR(instruction16).rs2 == 0 ) {
                                    // JALR -> jalr x1, rs1, 0
                                    // { 100 1 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                                    instruction32 = { 12b0, CR(instruction16).rs1, 3b000, 5h1, 7b1100111 };
                                } else {
                                    // ADD -> add rd, rd, rs2
                                    // { 100 1 rs1/rd!=0 rs2!=0 10 } -> { 0000000 rs2 rs1 000 rd 0110011 }
                                    instruction32 = { 7b0000000, CR(instruction16).rs2, CR(instruction16).rs1, 3b000, CR(instruction16).rs1, 7b0110011 };
                                }
                            }
                        }
                    }
                    case 3b101: {
                        // FSDSP
                    }
                    case 3b110: {
                        // SWSP -> sw rs2, offset[7:2](x2)
                        // { 110 uimm[5][4:2][7:6] rs2 10 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100011 }
                        instruction32 = { 4b0, CSS(instruction16).ib_7_6, CSS(instruction16).ib_5, CSS(instruction16).rs2, 5h2, 3b010, CSS(instruction16).ib_4_2, 2b00, 7b0100011 };
                    }
                    case 3b111: {
                        // FSWSP
                    }
                }
            }

            case 2b11: {
                compressed = 0;
                instruction32 = { 16h0000, instruction16 };
            }
        }
    }
}
