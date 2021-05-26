// RISC-V REGISTERS
algorithm registers(
    input   uint1   SMT,
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint5   rs3,
    input   uint5   rd,
    input   uint1   write,
    input   int32   result,
    output  int32   sourceReg1,
    output  int32   sourceReg2,
    output  int32   sourceReg3
) <autorun> {
    // RISC-V REGISTERS
    simple_dualport_bram int32 registers_1 <input!> [64] = { 0, pad(0) };
    simple_dualport_bram int32 registers_2 <input!> [64] = { 0, pad(0) };
    simple_dualport_bram int32 registers_3 <input!> [64] = { 0, pad(0) };

    // READ FROM REGISTERS
    registers_1.addr0 := { SMT, rs1 };
    registers_2.addr0 := { SMT, rs2 };
    registers_3.addr0 := { SMT, rs3 };
    sourceReg1 := registers_1.rdata0;
    sourceReg2 := registers_2.rdata0;
    sourceReg3 := registers_3.rdata0;

    // REGISTERS WRITE FLAG
    registers_1.wenable1 := 1;
    registers_2.wenable1 := 1;
    registers_3.wenable1 := 1;

    // SET REGISTER 0 to 0
    registers_1.addr1 = 0;
    registers_1.wdata1 = 0;
    registers_2.addr1 = 0;
    registers_2.wdata1 = 0;
    registers_3.addr1 = 0;
    registers_3.wdata1 = 0;

    while(1) {
        // WRITE TO REGISTERS
        if( write && ( rd != 0 ) ) {
            registers_1.addr1 = { SMT, rd };
            registers_1.wdata1 = result;
            registers_2.addr1 = { SMT, rd };
            registers_2.wdata1 = result;
            registers_3.addr1 = { SMT, rd };
            registers_3.wdata1 = result;
        }
    }
}

// RISC-V INSTRUCTION DECODER
algorithm decoder(
    input   uint32  instruction,

    output  uint7   opCode,
    output  uint3   function3,
    output  uint7   function7,

    output  uint5   rs1,
    output  uint5   rs2,
    output  uint5   rs3,
    output  uint5   rd,

    output  int32   immediateValue,
    //output  uint5   IshiftCount
) <autorun> {
    opCode := Utype(instruction).opCode;
    function3 := Rtype(instruction).function3;
    function7 := Rtype(instruction).function7;
    rs1 := Rtype(instruction).sourceReg1;
    rs2 := Rtype(instruction).sourceReg2;
    rs3 := R4type(instruction).sourceReg3;
    rd := Rtype(instruction).destReg;
    immediateValue := { {20{instruction[31,1]}}, Itype(instruction).immediate };
    //IshiftCount := ItypeSHIFT( instruction ).shiftCount;
}

// RISC-V ADDRESS BASE/OFFSET GENERATOR
algorithm addressgenerator(
    input   uint32  instruction,
    input   uint32  pc,
    input   uint1   compressed,
    input   int32   sourceReg1,
    input   int32   immediateValue,

    output  uint32  nextPC,
    output  uint32  branchAddress,
    output  uint32  jumpAddress,
    output  uint32  AUIPCLUI,
    output  uint32  storeAddress,
    output  uint32  loadAddress,
) <autorun> {
    nextPC := pc + ( compressed ? 2 : 4 );
    branchAddress := { {20{Btype(instruction).immediate_bits_12}}, Btype(instruction).immediate_bits_11, Btype(instruction).immediate_bits_10_5, Btype(instruction).immediate_bits_4_1, 1b0 } + pc;
    jumpAddress := { {12{Jtype(instruction).immediate_bits_20}}, Jtype(instruction).immediate_bits_19_12, Jtype(instruction).immediate_bits_11, Jtype(instruction).immediate_bits_10_1, 1b0 } + pc;
    AUIPCLUI := { Utype(instruction).immediate_bits_31_12, 12b0 } + ( instruction[5,1] ? 0 : pc );
    storeAddress := ( ( instruction[0,7] == 7b0101111 ) ? 0 : { {20{instruction[31,1]}}, Stype(instruction).immediate_bits_11_5, Stype(instruction).immediate_bits_4_0 } ) + sourceReg1;
    loadAddress := ( ( instruction[0,7] == 7b0101111 ) ? 0 : immediateValue ) + sourceReg1;
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
algorithm branchcomparison(
    input   uint7   opCode,
    input   uint3   function3,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    output  uint1   takeBranch
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

// COMPRESSED INSTRUCTION EXPANSION
algorithm compressed(
    input   uint16  i16,
    output  uint32  i32
) <autorun> {
    while(1) {
        switch( i16[0,2] ) {
            case 2b00: {
                switch( i16[13,3] ) {
                    case 3b000: {
                        // ADDI4SPN -> addi rd', x2, nzuimm[9:2] { 000, nzuimm[5:4|9:6|2|3] rd' 00 } -> { imm[11:0] rs1 000 rd 0010011 }
                        i32 = { 2b0, CIu94(i16).ib_9_6, CIu94(i16).ib_5_4, CIu94(i16).ib_3, CIu94(i16).ib_2, 2b00, 5h2, 3b000, {2b01,CIu94(i16).rd_alt}, 7b0010011 };
                    }
                    case 3b010: {
                        // LW -> lw rd', offset[6:2](rs1') { 010 uimm[5:3] rs1' uimm[2][6] rd' 00 } -> { imm[11:0] rs1 010 rd 0000011 }
                        i32 = { 5b0, CL(i16).ib_6, CL(i16).ib_5_3, CL(i16).ib_2, 2b00, {2b01,CL(i16).rs1_alt}, 3b010, {2b01,CL(i16).rd_alt}, 7b0000011};
                    }
                    case 3b011: {
                        // FLW -> flw rd', offset[6:2](rs1') { 010 uimm[5:3] rs1' uimm[2][6] rd' 00 } -> { imm[11:0] rs1 010 rd 0000111 }
                        i32 = { 5b0, CL(i16).ib_6, CL(i16).ib_5_3, CL(i16).ib_2, 2b00, {2b01,CL(i16).rs1_alt}, 3b010, {2b01,CL(i16).rd_alt}, 7b0000111};
                    }
                    case 3b110: {
                        // SW -> sw rs2', offset[6:2](rs1') { 110 uimm[5:3] rs1' uimm[2][6] rs2' 00 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100011 }
                        i32 = { 5b0, CS(i16).ib_6, CS(i16).ib_5, {2b01,CS(i16).rs2_alt}, {2b01,CS(i16).rs1_alt}, 3b010, CS(i16).ib_4_3, CS(i16).ib_2, 2b0, 7b0100011 };
                    }
                    case 3b111: {
                        // FSW -> fsw rs2', offset[6:2](rs1') { 110 uimm[5:3] rs1' uimm[2][6] rs2' 00 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100111 }
                        i32 = { 5b0, CS(i16).ib_6, CS(i16).ib_5, {2b01,CS(i16).rs2_alt}, {2b01,CS(i16).rs1_alt}, 3b010, CS(i16).ib_4_3, CS(i16).ib_2, 2b0, 7b0100111 };
                    }
                    default: { i32 = { 25b0, 7b0010011 }; }
                }
            }
            case 2b01: {
                switch( i16[13,3] ) {
                    case 3b000: {
                        // ADDI -> addi rd, rd, nzimm[5:0] { 000 nzimm[5] rs1/rd!=0 nzimm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                        i32 = { {7{CI50(i16).ib_5}}, CI50(i16).ib_4_0, CI50(i16).rd, 3b000, CI50(i16).rd, 7b0010011 };
                    }
                    case 3b001: {
                        // JAL -> jal x1, offset[11:1] { 001, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
                        i32 = { CJ(i16).ib_11, CJ(i16).ib_10, CJ(i16).ib_9_8, CJ(i16).ib_7, CJ(i16).ib_6, CJ(i16).ib_5, CJ(i16).ib_4, CJ(i16).ib_3_1, {8{CJ(i16).ib_11}}, 5h1, 7b1101111 };
                    }
                    case 3b010: {
                        // LI -> addi rd, x0, imm[5:0] { 010 imm[5] rd!=0 imm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                        i32 = { {7{CI50(i16).ib_5}}, CI50(i16).ib_4_0, 5h0, 3b000, CI(i16).rd, 7b0010011 };
                    }
                    case 3b011: {
                        switch( CI(i16).rd ) {
                            case 2: {
                                // ADDI16SP -> addi x2, x2, nzimm[9:4] { 011 nzimm[9] 00010 nzimm[4|6|8:7|5] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                                i32 = { {3{CI94(i16).ib_9}}, CI94(i16).ib_8_7, CI94(i16).ib_6, CI94(i16).ib_5, CI94(i16).ib_4, 4b0000, 5h2, 3b000, 5h2, 7b0010011 };
                            }
                            default: {
                                if( CI(i16).rd != 0 ) {
                                    // LUI -> lui rd, nzuimm[17:12] { 011 nzimm[17] rd!={0,2} nzimm[16:12] 01 } -> { imm[31:12] rd 0110111 }
                                    i32 = { {15{CIlui(i16).ib_17}}, CIlui(i16).ib_16_12, CIlui(i16).rd, 7b0110111 };
                                } else {
                                    switch( i16[10,2] ) {
                                        case 2b00: {
                                            // C.NOT -> xori rd, rs, -1 { 011 0 00 rs1'/rd' 00000 01 } -> { 111111111111 rs1 100 rd 0010011 }
                                            i32 = { 12b111111111111, { 2b01, CBalu50(i16).rd_alt }, 3b100, { 2b01, CBalu50(i16).rd_alt }, 7b0010011 };
                                        }
                                        case 2b01: {
                                            // C.NEG -> sub rd, x0, rs { 011 0 01 rs1'/rd' 00000 01 } -> { 0100000 rs2 rs1 000 rd 0010011 }
                                            i32 = { 7b0100000, { 2b01, CBalu50(i16).rd_alt }, 5b00000, 3b000, { 2b01, CBalu50(i16).rd_alt }, 7b0110011 };
                                        }
                                        default: { i32 = { 25b0, 7b0010011 }; }
                                    }
                                }
                            }
                        }
                    }
                    case 3b100: {
                        // MISC-ALU
                        switch( CBalu(i16).function2 ) {
                            case 2b00: {
                                // SRLI -> srli rd', rd', shamt[5:0] { 100 nzuimm[5] 00 rs1'/rd' nzuimm[4:0] 01 } -> { 0000000 shamt rs1 101 rd 0010011 }
                                i32 = { 7b0000000, CBalu50(i16).ib_4_0, { 2b01, CBalu50(i16).rd_alt }, 3b101, { 2b01, CBalu50(i16).rd_alt }, 7b0010011 };
                            }
                            case 2b01: {
                                // SRAI -> srai rd', rd', shamt[5:0] { 100 nzuimm[5] 01 rs1'/rd' nzuimm[4:0] 01 } -> { 0100000 shamt rs1 101 rd 0010011 }
                                i32 = { 7b0100000, CBalu50(i16).ib_4_0, { 2b01, CBalu50(i16).rd_alt }, 3b101, { 2b01, CBalu50(i16).rd_alt }, 7b0010011 };
                            }
                            case 2b10: {
                                // ANDI -> andi rd', rd', imm[5:0] { 100 imm[5], 10 rs1'/rd' imm[4:0] 01 } -> { imm[11:0] rs1 111 rd 0010011 }
                                i32 = { {7{CBalu50(i16).ib_5}}, CBalu50(i16).ib_4_0, { 2b01, CBalu50(i16).rd_alt }, 3b111, { 2b01, CBalu50(i16).rd_alt }, 7b0010011 };
                            }
                            case 2b11: {
                                // SUB XOR OR AND
                                switch( CBalu(i16).logical2 ) {
                                    case 2b00: {
                                        //SUB -> sub rd', rd', rs2' { 100 0 11 rs1'/rd' 00 rs2' 01 } -> { 0100000 rs2 rs1 000 rd 0110011 }
                                        i32 = { 7b0100000, { 2b01, CBalu(i16).rs2_alt }, { 2b01, CBalu(i16).rd_alt }, 3b000, { 2b01, CBalu(i16).rd_alt }, 7b0110011 };
                                    }
                                    case 2b01: {
                                        // XOR -> xor rd', rd', rs2' { 100 0 11 rs1'/rd' 01 rs2' 01 } -> { 0000000 rs2 rs1 100 rd 0110011 }
                                        i32 = { 7b0000000, { 2b01, CBalu(i16).rs2_alt }, { 2b01, CBalu(i16).rd_alt }, 3b100, { 2b01, CBalu(i16).rd_alt }, 7b0110011 };
                                    }
                                    case 2b10: {
                                        // OR -> or rd', rd', rd2' { 100 0 11 rs1'/rd' 10 rs2' 01 } -> { 0000000 rs2 rs1 110 rd 0110011 }
                                        i32 = { 7b0000000, { 2b01, CBalu(i16).rs2_alt }, { 2b01, CBalu(i16).rd_alt }, 3b110, { 2b01, CBalu(i16).rd_alt }, 7b0110011 };
                                    }
                                    case 2b11: {
                                        // AND -> and rd', rd', rs2' { 100 0 11 rs1'/rd' 11 rs2' 01 } -> { 0000000 rs2 rs1 111 rd 0110011 }
                                        i32 = { 7b0000000, { 2b01, CBalu(i16).rs2_alt }, { 2b01, CBalu(i16).rd_alt }, 3b111, { 2b01, CBalu(i16).rd_alt }, 7b0110011 };
                                    }
                                }
                            }
                        }
                    }
                    case 3b101: {
                        // J -> jal, x0, offset[11:1] { 101, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
                        i32 = { CJ(i16).ib_11, CJ(i16).ib_10, CJ(i16).ib_9_8, CJ(i16).ib_7, CJ(i16).ib_6, CJ(i16).ib_5, CJ(i16).ib_4, CJ(i16).ib_3_1, {9{CJ(i16).ib_11}}, 5h0, 7b1101111 };
                    }
                    case 3b110: {
                        // BEQZ -> beq rs1', x0, offset[8:1] { 110, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 000 imm[4:1|11] 1100011 }
                        i32 = { {4{CB(i16).offset_8}}, CB(i16).offset_7_6, CB(i16).offset_5, 5h0, {2b01,CB(i16).rs1_alt}, 3b000, CB(i16).offset_4_3, CB(i16).offset_2_1, CB(i16).offset_8, 7b1100011 };
                    }
                    case 3b111: {
                        // BNEZ -> bne rs1', x0, offset[8:1] { 111, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 001 imm[4:1|11] 1100011 }
                        i32 = { {4{CB(i16).offset_8}}, CB(i16).offset_7_6, CB(i16).offset_5, 5h0, {2b01,CB(i16).rs1_alt}, 3b001, CB(i16).offset_4_3, CB(i16).offset_2_1, CB(i16).offset_8, 7b1100011 };
                    }
                    default: { i32 = { 25b0, 7b0010011 }; }
                }
            }
            case 2b10: {
                switch( i16[13,3] ) {
                    case 3b000: {
                        // SLLI -> slli rd, rd, shamt[5:0] { 000, nzuimm[5], rs1/rd!=0 nzuimm[4:0] 10 } -> { 0000000 shamt rs1 001 rd 0010011 }
                        i32 = { 7b0000000, CI50(i16).ib_4_0, CI50(i16).rd, 3b001, CI50(i16).rd, 7b0010011 };
                    }
                    case 3b010: {
                        // LWSP -> lw rd, offset[7:2](x2) { 011 uimm[5] rd uimm[4:2|7:6] 10 } -> { imm[11:0] rs1 010 rd 0000011 }
                        i32 = { 4b0, CI(i16).ib_7_6, CI(i16).ib_5, CI(i16).ib_4_2, 2b0, 5h2 ,3b010, CI(i16).rd, 7b0000011 };
                    }
                    case 3b011: {
                        // FLWSP -> flw rd, offset[7:2](x2) { 011 uimm[5] rd uimm[4:2|7:6] 10 } -> { imm[11:0] rs1 010 rd 0000111 }
                        i32 = { 4b0, CI(i16).ib_7_6, CI(i16).ib_5, CI(i16).ib_4_2, 2b0, 5h2 ,3b010, CI(i16).rd, 7b0000111 };
                    }
                    case 3b100: {
                        // J[AL]R / MV / ADD
                        switch( i16[12,1] ) {
                            case 1b0: {
                                // JR / MV
                                if( CR(i16).rs2 == 0 ) {
                                    // JR -> jalr x0, rs1, 0 { 100 0 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                                    i32 = { 12b0, CR(i16).rs1, 3b000, 5h0, 7b1100111 };
                                } else {
                                    // MV -> add rd, x0, rs2 { 100 0 rd!=0 rs2!=0 10 } -> { 0000000 rs2 rs1 000 rd 0110011 }
                                    i32 = { 7b0000000, CR(i16).rs2, 5h0, 3b000, CR(i16).rs1, 7b0110011 };
                                }
                            }
                            case 1b1: {
                                // JALR / ADD
                                if( CR(i16).rs2 == 0 ) {
                                    // JALR -> jalr x1, rs1, 0 { 100 1 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                                    i32 = { 12b0, CR(i16).rs1, 3b000, 5h1, 7b1100111 };
                                } else {
                                    // ADD -> add rd, rd, rs2 { 100 1 rs1/rd!=0 rs2!=0 10 } -> { 0000000 rs2 rs1 000 rd 0110011 }
                                    i32 = { 7b0000000, CR(i16).rs2, CR(i16).rs1, 3b000, CR(i16).rs1, 7b0110011 };
                                }
                            }
                        }
                    }
                    case 3b110: {
                        // SWSP -> sw rs2, offset[7:2](x2) { 110 uimm[5][4:2][7:6] rs2 10 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100011 }
                        i32 = { 4b0, CSS(i16).ib_7_6, CSS(i16).ib_5, CSS(i16).rs2, 5h2, 3b010, CSS(i16).ib_4_2, 2b00, 7b0100011 };
                    }
                    case 3b111: {
                        // FSWSP -> fsw rs2, offset[7:2](x2) { 110 uimm[5][4:2][7:6] rs2 10 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100111 }
                        i32 = { 4b0, CSS(i16).ib_7_6, CSS(i16).ib_5, CSS(i16).rs2, 5h2, 3b010, CSS(i16).ib_4_2, 2b00, 7b0100111 };
                    }
                    default: { i32 = { 25b0, 7b0010011 }; }
                }
            }
        }
    }
}

// PERFORM OPTIONAL SIGN EXTENSION FOR 8 BIT AND 16 BIT READS
circuitry signextender8(
    input   function3,
    input   address,
    input   nosign,
    output  withsign
) {
    withsign = ~function3[2,1] ? { {24{nosign[address[0,1] ? 15 : 7, 1]}}, nosign[address[0,1] ? 8 : 0, 8] } : nosign[address[0,1] ? 8 : 0, 8];
}
circuitry signextender16(
    input   function3,
    input   nosign,
    output  withsign
) {
    withsign = ~function3[2,1] ? { {16{nosign[15,1]}}, nosign[0,16] } : nosign[0,16];
}

// COMBINE TWO 16 BIT HALF WORDS TO 32 BIT WORD
circuitry halfhalfword(
    input   HIGH,
    input   LOW,
    output  HIGHLOW,
) {
    HIGHLOW = { HIGH, LOW };
}
