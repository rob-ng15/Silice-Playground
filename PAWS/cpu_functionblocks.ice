// RISC-V REGISTER WRITE
circuitry registersWRITE (
    inout   registers_1,
    inout   registers_2,
    input   rd,
    input   writeRegister,
    input   SMT,
    input   result,
) {
    // WRITE TO REGISTERS
    // NEVER write to registers[0]
    if( writeRegister && ( rd != 0 ) ) {
        registers_1.addr1 = rd + ( SMT ? 32 : 0 );
        registers_1.wdata1 = result;
        registers_2.addr1 = rd + ( SMT ? 32 : 0 );
        registers_2.wdata1 = result;
    }
}

// RISC-V REGISTER READ
circuitry registersREAD(
    inout   registers_1,
    inout   registers_2,
    input   rs1,
    input   rs2,
    input   SMT,
    output  sourceReg1,
    output  sourceReg2,
) {
    registers_1.addr0 = rs1 + ( SMT ? 32 : 0 );
    registers_2.addr0 = rs2 + ( SMT ? 32 : 0 );
    ++:
    sourceReg1 = registers_1.rdata0;
    sourceReg2 = registers_2.rdata0;
}

// RISC-V INSTRUCTION DECODER
circuitry decoder (
    input   instruction,

    output  opCode,
    output  function3,
    output  function7,

    output  rs1,
    output  rs2,
    output  rd,

    output  immediateValue,
    output  IshiftCount
) {
    opCode = Utype(instruction).opCode;
    function3 = Rtype(instruction).function3;
    function7 = Rtype(instruction).function7;

    rs1 = Rtype(instruction).sourceReg1;
    rs2 = Rtype(instruction).sourceReg2;
    rd = Rtype(instruction).destReg;

    immediateValue = { {20{instruction[31,1]}}, Itype(instruction).immediate };
    IshiftCount = ItypeSHIFT( instruction ).shiftCount;
}

// RISC-V ADDRESS BASE/OFFSET GENERATOR
circuitry addressgenerator (
    input   opCode,
    input   pc,
    input   compressed,
    input   sourceReg1,
    input   immediateValue,

    output  nextPC,
    output  branchAddress,
    output  jumpAddress,
    output  AUIPCLUI,
    output  storeAddress,
    output  loadAddress,
) {
    nextPC = pc + ( compressed ? 2 : 4 );

    branchAddress = { {20{Btype(instruction).immediate_bits_12}}, Btype(instruction).immediate_bits_11, Btype(instruction).immediate_bits_10_5, Btype(instruction).immediate_bits_4_1, 1b0 } + pc;

    jumpAddress = { {12{Jtype(instruction).immediate_bits_20}}, Jtype(instruction).immediate_bits_19_12, Jtype(instruction).immediate_bits_11, Jtype(instruction).immediate_bits_10_1, 1b0 } + pc;

    AUIPCLUI = { Utype(instruction).immediate_bits_31_12, 12b0 } + ( opCode[5,1] ? 0 : pc );

    storeAddress = { {20{instruction[31,1]}}, Stype(instruction).immediate_bits_11_5, Stype(instruction).immediate_bits_4_0 } + sourceReg1;

    loadAddress = immediateValue + sourceReg1;
}

// UPDATE PC
circuitry newPC(
    input   opCode,
    input   incPC,
    input   nextPC,
    input   takeBranch,
    input   branchAddress,
    input   jumpAddress,
    input   loadAddress,
    output  pc
) {
    pc = ( incPC ) ? ( takeBranch ? branchAddress : nextPC ) : ( opCode[3,1] ? jumpAddress : loadAddress );
}

// BRANCH COMPARISIONS
circuitry branchcomparison (
    input   opCode,
    input   function3,
    input   sourceReg1,
    input   sourceReg2,
    output  takeBranch
) {
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

// COMPRESSED INSTRUCTION EXPANSION
circuitry compressed00(
    input   i16,
    output  i32
) {
    switch( i16[13,3] ) {
        case 3b000: {
            // ADDI4SPN -> addi rd', x2, nzuimm[9:2]
            // { 000, nzuimm[5:4|9:6|2|3] rd' 00 } -> { imm[11:0] rs1 000 rd 0010011 }
            i32 = { 2b0, CIu94(i16).ib_9_6, CIu94(i16).ib_5_4, CIu94(i16).ib_3, CIu94(i16).ib_2, 2b00, 5h2, 3b000, {2b01,CIu94(i16).rd_alt}, 7b0010011 };
        }
        case 3b001: {
            // FLD
        }
        case 3b010: {
            // LW -> lw rd', offset[6:2](rs1')
            // { 010 uimm[5:3] rs1' uimm[2][6] rd' 00 } -> { imm[11:0] rs1 010 rd 0000011 }
            i32 = { 5b0, CL(i16).ib_6, CL(i16).ib_5_3, CL(i16).ib_2, 2b00, {2b01,CL(i16).rs1_alt}, 3b010, {2b01,CL(i16).rd_alt}, 7b0000011};
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
            i32 = { 5b0, CS(i16).ib_6, CS(i16).ib_5, {2b01,CS(i16).rs2_alt}, {2b01,CS(i16).rs1_alt}, 3b010, CS(i16).ib_4_3, CS(i16).ib_2, 2b0, 7b0100011 };
        }
        case 3b111: {
            // FSW
        }
    }
}

circuitry compressed01(
    input   i16,
    output  i32
) {
    switch( i16[13,3] ) {
        case 3b000: {
            // ADDI -> addi rd, rd, nzimm[5:0]
            // { 000 nzimm[5] rs1/rd!=0 nzimm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
            i32 = { {7{CI50(i16).ib_5}}, CI50(i16).ib_4_0, CI50(i16).rd, 3b000, CI50(i16).rd, 7b0010011 };
        }
        case 3b001: {
            // JAL -> jal x1, offset[11:1]
            // { 001, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
            i32 = { CJ(i16).ib_11, CJ(i16).ib_10, CJ(i16).ib_9_8, CJ(i16).ib_7, CJ(i16).ib_6, CJ(i16).ib_5, CJ(i16).ib_4, CJ(i16).ib_3_1, {8{CJ(i16).ib_11}}, 5h1, 7b1101111 };
        }
        case 3b010: {
            // LI -> addi rd, x0, imm[5:0]
            // { 010 imm[5] rd!=0 imm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
            i32 = { {7{CI50(i16).ib_5}}, CI50(i16).ib_4_0, 5h0, 3b000, CI(i16).rd, 7b0010011 };
        }
        case 3b011: {
            // LUI / ADDI16SP
            if( ( CI(i16).rd != 0 ) && ( CI(i16).rd != 2 ) ) {
                // LUI -> lui rd, nzuimm[17:12]
                // { 011 nzimm[17] rd!={0,2} nzimm[16:12] 01 } -> { imm[31:12] rd 0110111 }
                i32 = { {15{CIlui(i16).ib_17}}, CIlui(i16).ib_16_12, CIlui(i16).rd, 7b0110111 };
            } else {
                // ADDI16SP -> addi x2, x2, nzimm[9:4]
                // { 011 nzimm[9] 00010 nzimm[4|6|8:7|5] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                i32 = { {3{CI94(i16).ib_9}}, CI94(i16).ib_8_7, CI94(i16).ib_6, CI94(i16).ib_5, CI94(i16).ib_4, 4b0000, 5h2, 3b000, 5h2, 7b0010011 };
            }
        }
        case 3b100: {
            // MISC-ALU
            switch( CBalu(i16).function2 ) {
                case 2b00: {
                    // SRLI -> srli rd', rd', shamt[5:0]
                    // { 100 nzuimm[5] 00 rs1'/rd' nzuimm[4:0] 01 } -> { 0000000 shamt rs1 101 rd 0010011 }
                    i32 = { 7b0000000, CBalu50(i16).ib_4_0, { 2b01, CBalu50(i16).rd_alt }, 3b101, { 2b01, CBalu50(i16).rd_alt }, 7b0010011 };
                }
                case 2b01: {
                    // SRAI -> srai rd', rd', shamt[5:0]
                    // { 100 nzuimm[5] 01 rs1'/rd' nzuimm[4:0] 01 } -> { 0100000 shamt rs1 101 rd 0010011 }
                    i32 = { 7b0100000, CBalu50(i16).ib_4_0, { 2b01, CBalu50(i16).rd_alt }, 3b101, { 2b01, CBalu50(i16).rd_alt }, 7b0010011 };
                }
                case 2b10: {
                    // ANDI -> andi rd', rd', imm[5:0]
                    // { 100 imm[5], 10 rs1'/rd' imm[4:0] 01 } -> { imm[11:0] rs1 111 rd 0010011 }
                    i32 = { {7{CBalu50(i16).ib_5}}, CBalu50(i16).ib_4_0, { 2b01, CBalu50(i16).rd_alt }, 3b111, { 2b01, CBalu50(i16).rd_alt }, 7b0010011 };
                }
                case 2b11: {
                    // SUB XOR OR AND
                    switch( CBalu(i16).logical2 ) {
                        case 2b00: {
                            //SUB -> sub rd', rd', rs2'
                            // { 100 0 11 rs1'/rd' 00 rs2' 01 } -> { 0100000 rs2 rs1 000 rd 0110011 }
                            i32 = { 7b0100000, { 2b01, CBalu(i16).rs2_alt }, { 2b01, CBalu(i16).rd_alt }, 3b000, { 2b01, CBalu(i16).rd_alt }, 7b0110011 };
                        }
                        case 2b01: {
                            // XOR -> xor rd', rd', rs2'
                            // { 100 0 11 rs1'/rd' 01 rs2' 01 } -> { 0000000 rs2 rs1 100 rd 0110011 }
                            i32 = { 7b0000000, { 2b01, CBalu(i16).rs2_alt }, { 2b01, CBalu(i16).rd_alt }, 3b100, { 2b01, CBalu(i16).rd_alt }, 7b0110011 };
                        }
                        case 2b10: {
                            // OR -> or rd', rd', rd2'
                            // { 100 0 11 rs1'/rd' 10 rs2' 01 } -> { 0000000 rs2 rs1 110 rd 0110011 }
                            i32 = { 7b0000000, { 2b01, CBalu(i16).rs2_alt }, { 2b01, CBalu(i16).rd_alt }, 3b110, { 2b01, CBalu(i16).rd_alt }, 7b0110011 };
                        }
                        case 2b11: {
                            // AND -> and rd', rd', rs2'
                            // { 100 0 11 rs1'/rd' 11 rs2' 01 } -> { 0000000 rs2 rs1 111 rd 0110011 }
                            i32 = { 7b0000000, { 2b01, CBalu(i16).rs2_alt }, { 2b01, CBalu(i16).rd_alt }, 3b111, { 2b01, CBalu(i16).rd_alt }, 7b0110011 };
                        }
                    }
                }
            }
        }
        case 3b101: {
            // J -> jal, x0, offset[11:1]
            // { 101, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
            i32 = { CJ(i16).ib_11, CJ(i16).ib_10, CJ(i16).ib_9_8, CJ(i16).ib_7, CJ(i16).ib_6, CJ(i16).ib_5, CJ(i16).ib_4, CJ(i16).ib_3_1, {9{CJ(i16).ib_11}}, 5h0, 7b1101111 };
        }
        case 3b110: {
            // BEQZ -> beq rs1', x0, offset[8:1]
            // { 110, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 000 imm[4:1|11] 1100011 }
            i32 = { {4{CB(i16).offset_8}}, CB(i16).offset_7_6, CB(i16).offset_5, 5h0, {2b01,CB(i16).rs1_alt}, 3b000, CB(i16).offset_4_3, CB(i16).offset_2_1, CB(i16).offset_8, 7b1100011 };
        }
        case 3b111: {
            // BNEZ -> bne rs1', x0, offset[8:1]
            // { 111, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 001 imm[4:1|11] 1100011 }
            i32 = { {4{CB(i16).offset_8}}, CB(i16).offset_7_6, CB(i16).offset_5, 5h0, {2b01,CB(i16).rs1_alt}, 3b001, CB(i16).offset_4_3, CB(i16).offset_2_1, CB(i16).offset_8, 7b1100011 };
        }
    }
}

circuitry compressed10(
    input   i16,
    output  i32
) {
    switch( i16[13,3] ) {
        case 3b000: {
            // SLLI -> slli rd, rd, shamt[5:0]
            // { 000, nzuimm[5], rs1/rd!=0 nzuimm[4:0] 10 } -> { 0000000 shamt rs1 001 rd 0010011 }
            i32 = { 7b0000000, CI50(i16).ib_4_0, CI50(i16).rd, 3b001, CI50(i16).rd, 7b0010011 };
        }
        case 3b001: {
            // FLDSP
        }
        case 3b010: {
            // LWSP -> lw rd, offset[7:2](x2)
            // { 011 uimm[5] rd uimm[4:2|7:6] 10 } -> { imm[11:0] rs1 010 rd 0000011 }
            i32 = { 4b0, CI(i16).ib_7_6, CI(i16).ib_5, CI(i16).ib_4_2, 2b0, 5h2 ,3b010, CI(i16).rd, 7b0000011 };
        }
        case 3b011: {
            // FLWSP
        }
        case 3b100: {
            // J[AL]R / MV / ADD
            switch( i16[12,1] ) {
                case 1b0: {
                    // JR / MV
                    if( CR(i16).rs2 == 0 ) {
                        // JR -> jalr x0, rs1, 0
                        // { 100 0 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                        i32 = { 12b0, CR(i16).rs1, 3b000, 5h0, 7b1100111 };
                    } else {
                        // MV -> add rd, x0, rs2
                        // { 100 0 rd!=0 rs2!=0 10 } -> { 0000000 rs2 rs1 000 rd 0110011 }
                        i32 = { 7b0000000, CR(i16).rs2, 5h0, 3b000, CR(i16).rs1, 7b0110011 };
                    }
                }
                case 1b1: {
                    // JALR / ADD
                    if( CR(i16).rs2 == 0 ) {
                        // JALR -> jalr x1, rs1, 0
                        // { 100 1 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                        i32 = { 12b0, CR(i16).rs1, 3b000, 5h1, 7b1100111 };
                    } else {
                        // ADD -> add rd, rd, rs2
                        // { 100 1 rs1/rd!=0 rs2!=0 10 } -> { 0000000 rs2 rs1 000 rd 0110011 }
                        i32 = { 7b0000000, CR(i16).rs2, CR(i16).rs1, 3b000, CR(i16).rs1, 7b0110011 };
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
            i32 = { 4b0, CSS(i16).ib_7_6, CSS(i16).ib_5, CSS(i16).rs2, 5h2, 3b010, CSS(i16).ib_4_2, 2b00, 7b0100011 };
        }
        case 3b111: {
            // FSWSP
        }
    }
}

// PERFORM OPTIONAL SIGN EXTENSION FOR 8 BIT AND 16 BIT READS
circuitry signextender8 (
    input   function3,
    input   address,
    input   nosign,
    output  withsign
) {
    withsign = ~function3[2,1] ? { {24{nosign[address[0,1] ? 15 : 7, 1]}}, nosign[address[0,1] ? 8 : 0, 8] } : nosign[address[0,1] ? 8 : 0, 8];
}
circuitry signextender16 (
    input   function3,
    input   nosign,
    output  withsign
) {
    withsign = ~function3[2,1] ? { {16{nosign[15,1]}}, nosign[0,16] } : nosign[0,16];
}

// COMBINE TWO 16 BIT HALF WORDS TO 32 BIT WORD
circuitry halfhalfword (
    input   HIGH,
    input   LOW,
    output  HIGHLOW,
) {
    HIGHLOW = { HIGH, LOW };
}

// BIT MANIPULATION CIRCUITS
// BARREL SHIFTERS / ROTATORS
algorithm BSHIFTleft(
    input   uint1   start,

    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint7   function7,
    output! uint32  result
) <autorun> {
    while(1) {
        if( start ) {
            switch( shiftcount ) {
                case 0: { result = sourceReg1; }
                $$for i = 1, 31 do
                    $$ remain = 32 - i
                    case $i$: { result = { sourceReg1[ 0, $remain$ ], {$i${ function7[4,1] }} }; }
                $$end
            }
        }
    }
}
algorithm BSHIFTright(
    input   uint1   start,

    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint7   function7,
    output! uint32  result
) <autorun> {
    uint1   bit = uninitialised;

    while(1) {
        switch( function7[4,2] ) {
            case 2b00: { bit = 0; }
            case 2b01: { bit = 1; }
            case 2b10: { bit = sourceReg1[31,1]; }
        }
        if( start ) {
            switch( shiftcount ) {
                case 0: { result = sourceReg1; }
                $$for i = 1, 31 do
                    $$ remain = 32 - i
                    case $i$: { result = { {$i${bit}}, sourceReg1[ $i$, $remain$ ] }; }
                $$end
            }
        }
    }
}
algorithm BROTATE(
    input   uint1   start,

    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint3   function3,
    output! uint32  result
) <autorun> {
    uint5   rotatecount = uninitialised;

    while(1) {
        switch( function3 ) {
            default: { rotatecount = shiftcount; }
            case 3b001: { rotatecount = 32 - shiftcount; }
        }
        if( start ) {
            switch( rotatecount ) {
                case 0: { result = sourceReg1; }
                $$for i = 1, 31 do
                    $$ remain = 32 - i
                    case $i$: { result = { sourceReg1[ $remain$, $i$ ], sourceReg1[ $i$, $remain$ ] }; }
                $$end
            }
        }
    }
}

// SINGLE BIT OPERATIONS SET CLEAR INVERT
algorithm singlebitops(
    input   uint1   start,

    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint7   function7,
    output! uint32  result
) <autorun> {
    uint1   bit := ( function7[4,2] == 2b11 ) ? ~sourceReg1[shiftcount,1] : function7[4,1];

    while(1) {
        if( start ) {
            switch( shiftcount ) {
                case 0: { result = { sourceReg1[ 1, 31 ], bit }; }
                $$for i = 1, 30 do
                $$j = i + 1
                $$remain = 31 - i;
                    case $i$: { result = { sourceReg1[ $j$, $remain$ ], bit, sourceReg1[ 0, $i$ ] }; }
                $$end
                case 31: { result = { bit, sourceReg1[0, 31 ] }; }
            }
        }
    }
}

// GENERAL REVERSE / GENERAL OR CONDITIONAL
circuitry GREV(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = sourceReg1;
    ++:
    if( shiftcount[0,1] ) { result = ( ( result & 32h55555555 ) << 1 ) | ( ( result & 32haaaaaaaa ) >> 1 ); ++: }
    if( shiftcount[1,1] ) { result = ( ( result & 32h33333333 ) << 2 ) | ( ( result & 32hcccccccc ) >> 2 ); ++: }
    if( shiftcount[2,1] ) { result = ( ( result & 32h0f0f0f0f ) << 4 ) | ( ( result & 32hf0f0f0f0 ) >> 4 ); ++: }
    if( shiftcount[3,1] ) { result = ( ( result & 32h00ff00ff ) << 8 ) | ( ( result & 32hff00ff00 ) >> 8 ); ++: }
    if( shiftcount[4,1] ) { result = ( ( result & 32h0000ffff ) << 16 ) | ( ( result & 32hffff0000 ) >> 16 ); }
}
circuitry GORC(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    result = sourceReg1;
    ++:
    if( shiftcount[0,1] ) { result = result | ( ( result & 32h55555555 ) << 1 ) | ( ( result & 32haaaaaaaa ) >> 1 ); ++: }
    if( shiftcount[1,1] ) { result = result | ( ( result & 32h33333333 ) << 2 ) | ( ( result & 32hcccccccc ) >> 2 ); ++: }
    if( shiftcount[2,1] ) { result = result | ( ( result & 32h0f0f0f0f ) << 4 ) | ( ( result & 32hf0f0f0f0 ) >> 4 ); ++: }
    if( shiftcount[3,1] ) { result = result | ( ( result & 32h00ff00ff ) << 8 ) | ( ( result & 32hff00ff00 ) >> 8 ); ++: }
    if( shiftcount[4,1] ) { result = result | ( ( result & 32h0000ffff ) << 16 ) | ( ( result & 32hffff0000 ) >> 16 ); }
}

// SHUFFLE / UNSHUFFLE
circuitry shuffle32_stage(
    input   src,
    input   maskL,
    input   maskR,
    input   N,
    output  x
) {
    uint32  A = uninitialised;
    uint32  B = uninitialised;

    x = src & ~( maskL | maskR );
    A = src << N;
    B = src >> N;
    ++:
    x = x | ( A & maskL ) | ( B & maskR );
}
circuitry SHFL(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    uint4   N8 = 8; uint32 N8A = 32h00ff0000; uint32 N8B = 32h0000ff00;
    uint4   N4 = 4; uint32 N4A = 32h0f000f00; uint32 N4B = 32h00f000f0;
    uint4   N2 = 2; uint32 N2A = 32h30303030; uint32 N2B = 32h0c0c0c0c;
    uint4   N1 = 1; uint32 N1A = 32h44444444; uint32 N1B = 32h22222222;

    result = sourceReg1;
    ++:
    if( shiftcount[3,1] ) { ( result ) = shuffle32_stage( result, N8A, N8B, N8 ); }
    if( shiftcount[2,1] ) { ( result ) = shuffle32_stage( result, N4A, N4B, N4 ); }
    if( shiftcount[1,1] ) { ( result ) = shuffle32_stage( result, N2A, N2B, N2 ); }
    if( shiftcount[0,1] ) { ( result ) = shuffle32_stage( result, N1A, N1B, N1 ); }
}
circuitry UNSHFL(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    uint4   N8 = 8; uint32 N8A = 32h00ff0000; uint32 N8B = 32h0000ff00;
    uint4   N4 = 4; uint32 N4A = 32h0f000f00; uint32 N4B = 32h00f000f0;
    uint4   N2 = 2; uint32 N2A = 32h30303030; uint32 N2B = 32h0c0c0c0c;
    uint4   N1 = 1; uint32 N1A = 32h44444444; uint32 N1B = 32h22222222;

    result = sourceReg1;
    ++:
    if( shiftcount[0,1] ) { ( result ) = shuffle32_stage( result, N1A, N1B, N1 ); }
    if( shiftcount[1,1] ) { ( result ) = shuffle32_stage( result, N2A, N2B, N2 ); }
    if( shiftcount[2,1] ) { ( result ) = shuffle32_stage( result, N4A, N4B, N4 ); }
    if( shiftcount[3,1] ) { ( result ) = shuffle32_stage( result, N8A, N8B, N8 ); }
}

// CARRYLESS MULTIPLY
circuitry CLMUL(
    input   sourceReg1,
    input   sourceReg2,
    input   function3,
    output  result
) {
    uint6   i = uninitialised;
    i = ( function3 == 3b011 ) ? 1 : 0;
    result = 0;
    ++:
    while( i < 32 ) {
        if( sourceReg2[i,1] ) {
            switch( function3 ) {
                case 3b001: { result = result ^ ( sourceReg1 << i ); }
                case 3b010: { result = result ^ ( sourceReg1 << ( 32 - i ) ); }
                case 3b011: { result = result ^ ( sourceReg1 << ( 31 - i ) ); }
            }
        }
        i = i + 1;
    }
}

// BITS EXTRACT / DEPOSIT
circuitry BEXT(
    input   sourceReg1,
    input   sourceReg2,
    output  result
) {
    uint6   i = 0;
    uint6   j = 0;
    result = 0;
    ++:
    while( i < 32 ) {
        if( sourceReg2[i,1] ) {
            if( sourceReg1[ i, 1] ) {
                result[ j, 1 ] = 1b1;
            }
            j = j + 1;
        }
        i = i + 1;
    }
}
circuitry BDEP(
    input   sourceReg1,
    input   sourceReg2,
    output  result
) {
    uint6   i = 0;
    uint6   j = 0;
    result = 0;
    ++:
    while( i < 32 ) {
        if( sourceReg2[i,1] ) {
            if( sourceReg1[ j, 1] ) {
                result[ j, 1 ] = 1b1;
            }
            j = j + 1;
        }
        i = i + 1;
    }
}
circuitry BFP(
    input   sourceReg1,
    input   sourceReg2,
    output  result
) {
    uint5   length = uninitialised;
    uint6   offset = uninitialised;
    uint32  mask = 0;

    length = ( sourceReg2[24,4] == 0 ) ? 16 : sourceReg2[24,4];
    offset = sourceReg2[16,5];
    ++:
    mask = ~(~mask << offset);
    ++:
    result = ( ( sourceReg2 << offset ) & mask ) | ( sourceReg1 & ~mask );
}

// XPERM for nibble, byte and half-word
// CALCULATE result = result | ( ( sourceReg1 >> pos ) & mask ) << i
circuitry xperm(
    input   sourceReg1,
    input   sourceReg2,
    input   sz_log2,
    output  result
) {
    uint6   sz = uninitialised;
    uint32  mask = uninitialised;
    uint32  pos = uninitialised;
    uint6   i = uninitialised;

    sz = 1 << sz_log2;
    mask = ( 1 << ( 1 << sz_log2 ) ) - 1;
    result = 0;
    i = 0;
    ++:
    while( i < 32 ) {
        pos = ( ( sourceReg2 >> i ) & mask ) << sz_log2;
        ++:
        if( pos < 32 ) {
            result = result | (( sourceReg1 >> pos ) & mask ) << i;
        }
        i = i + sz;
    }
}
circuitry XPERM(
    input   sourceReg1,
    input   sourceReg2,
    input   function3,
    output  result
) {
    uint3   sz_log2 = uninitialised;
    switch( function3 ) {
        case 3b010: { sz_log2 = 2; }
        case 3b100: { sz_log2 = 3; }
        case 3b110: { sz_log2 = 4; }
    }
    ( result ) = xperm( sourceReg1, sourceReg2, sz_log2 );
}
