algorithm updatepc(
    input   uint7   opCode,
    input   uint1   incPC,
    input   uint32  nextPC,
    input   uint1   takeBranch,
    input   uint32  branchAddress,
    input   uint32  jumpAddress,
    input   uint32  loadAddress,
    output  uint32  pc
) <autorun> {
    pc := ( incPC ) ? ( takeBranch ? branchAddress : nextPC ) : ( opCode[3,1] ? jumpAddress : loadAddress );
}

// RISC-V REGISTERS - usable for base and float
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
    simple_dualport_bram int32 registers_1 <input!> [64] = { 0, pad(uninitialized) };
    simple_dualport_bram int32 registers_2 <input!> [64] = { 0, pad(uninitialized) };
    simple_dualport_bram int32 registers_3 <input!> [64] = { 0, pad(uninitialized) };

    // READ FROM REGISTERS
    registers_1.addr0 := { SMT, rs1 }; sourceReg1 := registers_1.rdata0;
    registers_2.addr0 := { SMT, rs2 }; sourceReg2 := registers_2.rdata0;
    registers_3.addr0 := { SMT, rs3 }; sourceReg3 := registers_3.rdata0;

    // REGISTERS WRITE FLAG
    registers_1.wenable1 := 1; registers_2.wenable1 := 1; registers_3.wenable1 := 1;

    always {
        // WRITE TO REGISTERS
        if( write ) {
            registers_1.addr1 = { SMT, rd }; registers_1.wdata1 = result;
            registers_2.addr1 = { SMT, rd }; registers_2.wdata1 = result;
            registers_3.addr1 = { SMT, rd }; registers_3.wdata1 = result;
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
) <autorun> {
    opCode := Utype(instruction).opCode;
    function3 := Rtype(instruction).function3;
    function7 := Rtype(instruction).function7;
    rs1 := Rtype(instruction).sourceReg1;
    rs2 := Rtype(instruction).sourceReg2;
    rs3 := R4type(instruction).sourceReg3;
    rd := Rtype(instruction).destReg;
    immediateValue := { {20{instruction[31,1]}}, Itype(instruction).immediate };
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

// BRANCH COMPARISIONS
algorithm branchcomparison(
    input   uint7   opCode,
    input   uint3   function3,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    output  uint1   takeBranch
) <autorun> {
    always {
        switch( function3 ) {
            case 3b000: { takeBranch = ( sourceReg1 == sourceReg2 ); }
            case 3b001: { takeBranch = ( sourceReg1 != sourceReg2 ); }
            case 3b100: { takeBranch = ( __signed(sourceReg1) < __signed(sourceReg2) ); }
            case 3b101: { takeBranch = ( __signed(sourceReg1) >= __signed(sourceReg2) ); }
            case 3b110: { takeBranch = ( __unsigned(sourceReg1) < __unsigned(sourceReg2) ); }
            case 3b111: { takeBranch = ( __unsigned(sourceReg1) >= __unsigned(sourceReg2) ); }
            default: { takeBranch = 0; }
        }
    }
}

// COMPRESSED INSTRUCTION EXPANSION
algorithm compressed(
    input   uint16  i16,
    output  uint32  i32
) <autorun> {
    uint3   opbits = uninitialized;
    always {
        switch( i16[0,2] ) {
            case 2b00: {
                switch( i16[13,3] ) {
                    case 3b000: {
                        // ADDI4SPN -> addi rd', x2, nzuimm[9:2] { 000, nzuimm[5:4|9:6|2|3] rd' 00 } -> { imm[11:0] rs1 000 rd 0010011 }
                        i32 = { 2b0, CIu94(i16).ib_9_6, CIu94(i16).ib_5_4, CIu94(i16).ib_3, CIu94(i16).ib_2, 2b00, 5h2, 3b000, {2b01,CIu94(i16).rd_alt}, 7b0010011 };
                    }
                    default: {
                        switch( i16[15,1] ) {
                            case 0: {
                                // LW -> lw rd', offset[6:2](rs1') { 010 uimm[5:3] rs1' uimm[2][6] rd' 00 } -> { imm[11:0] rs1 010 rd 0000011 }
                                // FLW -> flw rd', offset[6:2](rs1') { 010 uimm[5:3] rs1' uimm[2][6] rd' 00 } -> { imm[11:0] rs1 010 rd 0000111 }
                                i32 = { 5b0, CL(i16).ib_6, CL(i16).ib_5_3, CL(i16).ib_2, 2b00, {2b01,CL(i16).rs1_alt}, 3b010, {2b01,CL(i16).rd_alt}, { 4b0000, i16[13,1],2b11 } };
                            }
                            case 1: {
                                // SW -> sw rs2', offset[6:2](rs1') { 110 uimm[5:3] rs1' uimm[2][6] rs2' 00 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100011 }
                                // FSW -> fsw rs2', offset[6:2](rs1') { 110 uimm[5:3] rs1' uimm[2][6] rs2' 00 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100111 }
                                i32 = { 5b0, CS(i16).ib_6, CS(i16).ib_5, {2b01,CS(i16).rs2_alt}, {2b01,CS(i16).rs1_alt}, 3b010, CS(i16).ib_4_3, CS(i16).ib_2, 2b0, { 4b0100, i16[13,1],2b11 } };
                            }
                        }
                    }
                }
            }
            case 2b01: {
                switch( i16[13,3] ) {
                    case 3b000: {
                        // ADDI -> addi rd, rd, nzimm[5:0] { 000 nzimm[5] rs1/rd!=0 nzimm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                        // NOP if rd == 0 and nzimm == 5b000000
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
                                // LUI -> lui rd, nzuimm[17:12] { 011 nzimm[17] rd!={0,2} nzimm[16:12] 01 } -> { imm[31:12] rd 0110111 }
                                i32 = { {15{CIlui(i16).ib_17}}, CIlui(i16).ib_16_12, CIlui(i16).rd, 7b0110111 };
                            }
                        }
                    }
                    case 3b100: {
                        // MISC-ALU
                        switch( CBalu(i16).function2 ) {
                            default: {
                                // i16[10,1] -> SRLI SRAI
                                // 1b0 -> SRLI -> srli rd', rd', shamt[5:0] { 100 nzuimm[5] 00 rs1'/rd' nzuimm[4:0] 01 } -> { 0000000 shamt rs1 101 rd 0010011 }
                                // 1b1 -> SRAI -> srai rd', rd', shamt[5:0] { 100 nzuimm[5] 01 rs1'/rd' nzuimm[4:0] 01 } -> { 0100000 shamt rs1 101 rd 0010011 }
                                i32 = { { 1b0, i16[10,1], 5b00000 }, CBalu50(i16).ib_4_0, { 2b01, CBalu50(i16).rd_alt }, 3b101, { 2b01, CBalu50(i16).rd_alt }, 7b0010011 };
                            }
                            case 2b10: {
                                // ANDI -> andi rd', rd', imm[5:0] { 100 imm[5], 10 rs1'/rd' imm[4:0] 01 } -> { imm[11:0] rs1 111 rd 0010011 }
                                i32 = { {7{CBalu50(i16).ib_5}}, CBalu50(i16).ib_4_0, { 2b01, CBalu50(i16).rd_alt }, 3b111, { 2b01, CBalu50(i16).rd_alt }, 7b0010011 };
                            }
                            case 2b11: {
                                // CBalu(i16).logical2 -> SUB XOR OR AND
                                //        // 2b00 -> SUB -> sub rd', rd', rs2' { 100 0 11 rs1'/rd' 00 rs2' 01 } -> { 0100000 rs2 rs1 000 rd 0110011 }
                                //        // 2b01 -> XOR -> xor rd', rd', rs2' { 100 0 11 rs1'/rd' 01 rs2' 01 } -> { 0000000 rs2 rs1 100 rd 0110011 }
                                //        // 2b10 -> OR  -> or  rd', rd', rd2' { 100 0 11 rs1'/rd' 10 rs2' 01 } -> { 0000000 rs2 rs1 110 rd 0110011 }
                                //        // 2b11 -> AND -> and rd', rd', rs2' { 100 0 11 rs1'/rd' 11 rs2' 01 } -> { 0000000 rs2 rs1 111 rd 0110011 }
                                switch( CBalu(i16).logical2 ) { case 2b00: { opbits = 3b000; } case 2b01: { opbits = 3b100; } case 2b10: { opbits = 3b110; } case 2b11: { opbits = 3b111; } }
                                i32 = { { 1b0, CBalu(i16).logical2 == 2b00 ? 1b1 : 1b0, 5b00000 }, { 2b01, CBalu(i16).rs2_alt }, { 2b01, CBalu(i16).rd_alt }, opbits, { 2b01, CBalu(i16).rd_alt }, 7b0110011 };
                            }
                        }
                    }
                    case 3b101: {
                        // J -> jal, x0, offset[11:1] { 101, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
                        i32 = { CJ(i16).ib_11, CJ(i16).ib_10, CJ(i16).ib_9_8, CJ(i16).ib_7, CJ(i16).ib_6, CJ(i16).ib_5, CJ(i16).ib_4, CJ(i16).ib_3_1, {9{CJ(i16).ib_11}}, 5h0, 7b1101111 };
                    }
                    default: {
                        // 3b110 -> BEQZ -> beq rs1', x0, offset[8:1] { 110, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 000 imm[4:1|11] 1100011 }
                        // 3b111 -> BNEZ -> bne rs1', x0, offset[8:1] { 111, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 001 imm[4:1|11] 1100011 }
                        opbits = { 2b00, i16[13,1] };
                        i32 = { {4{CB(i16).offset_8}}, CB(i16).offset_7_6, CB(i16).offset_5, 5h0, {2b01,CB(i16).rs1_alt}, opbits, CB(i16).offset_4_3, CB(i16).offset_2_1, CB(i16).offset_8, 7b1100011 };
                    }
                }
            }
            case 2b10: {
                switch( i16[13,3] ) {
                    case 3b000: {
                        // SLLI -> slli rd, rd, shamt[5:0] { 000, nzuimm[5], rs1/rd!=0 nzuimm[4:0] 10 } -> { 0000000 shamt rs1 001 rd 0010011 }
                        i32 = { 7b0000000, CI50(i16).ib_4_0, CI50(i16).rd, 3b001, CI50(i16).rd, 7b0010011 };
                    }
                    case 3b100: {
                        // J[AL]R / MV / ADD
                        switch( CR(i16).rs2 ) {
                            case 0: {
                                // JR   -> jalr x0, rs1, 0 { 100 0 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                                // JALR -> jalr x1, rs1, 0 { 100 1 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                                i32 = { 12b0, CR(i16).rs1, 3b000, { 4b0000, i16[12,1]}, 7b1100111 };
                            }
                            default: {
                                // MV  -> add rd, x0, rs2 { 100 0 rd!=0 rs2!=0 10 }     -> { 0000000 rs2 rs1 000 rd 0110011 }
                                // ADD -> add rd, rd, rs2 { 100 1 rs1/rd!=0 rs2!=0 10 } -> { 0000000 rs2 rs1 000 rd 0110011 }
                                i32 = { 7b0000000, CR(i16).rs2, i16[12,1] ? CR(i16).rs1: 5h0, 3b000, CR(i16).rs1, 7b0110011 };
                            }
                        }
                    }
                    default: {
                        switch( i16[15,1] ) {
                            case 0: {
                                // LWSP -> lw rd, offset[7:2](x2) { 011 uimm[5] rd uimm[4:2|7:6] 10 } -> { imm[11:0] rs1 010 rd 0000011 }
                                // FLWSP -> flw rd, offset[7:2](x2) { 011 uimm[5] rd uimm[4:2|7:6] 10 } -> { imm[11:0] rs1 010 rd 0000111 }
                                i32 = { 4b0, CI(i16).ib_7_6, CI(i16).ib_5, CI(i16).ib_4_2, 2b0, 5h2 ,3b010, CI(i16).rd,  { 4b0000, i16[13,1],2b11 } };
                            }
                            case 1: {
                                // SWSP -> sw rs2, offset[7:2](x2) { 110 uimm[5][4:2][7:6] rs2 10 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100011 }
                                // FSWSP -> fsw rs2, offset[7:2](x2) { 110 uimm[5][4:2][7:6] rs2 10 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100111 }
                                i32 = { 4b0, CSS(i16).ib_7_6, CSS(i16).ib_5, CSS(i16).rs2, 5h2, 3b010, CSS(i16).ib_4_2, 2b00, { 4b0100, i16[13,1],2b11 } };
                            }
                        }
                    }
                }
            }
            default: { i32 = i16; }
        }
    }
}

// RISC-V MANDATORY CSR REGISTERS
algorithm CSRblock(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint1   SMT,
    input   uint32  instruction,
    input   uint3   function3,
    input   uint5   rs1,
    input   uint32  sourceReg1,
    input   uint1   incCSRinstret,
    input   uint1   updateFPUflags,
    input   uint5   FPUnewflags,
    output  uint5   FPUflags,
    output  uint32  result
) <autorun> {
    uint64  CSRtimer = 0;
    uint64  CSRcycletime = 0;
    uint64  CSRcycletimeSMT = 0;
    uint64  CSRinstret = 0;
    uint64  CSRinstretSMT = 0;
    uint8   CSRf = 0;
    uint8   CSRfSMT = 0;
    uint32  writevalue <: function3[2,1] ? rs1 : sourceReg1;

    CSRtimer := CSRtimer + 1;
    CSRcycletime := CSRcycletime + ( SMT ? 0 : 1);
    CSRinstret := CSRinstret + ( ( incCSRinstret & (~SMT) ) ? 1 : 0 );
    CSRcycletimeSMT := CSRcycletimeSMT + ( SMT ? 1 : 0);
    CSRinstretSMT := CSRinstretSMT + ( ( incCSRinstret & SMT ) ? 1 : 0);

    FPUflags := SMT ? CSRfSMT[0,5] : CSRf[0,5];

    always {
        switch( updateFPUflags ) {
            case 1: { switch( SMT ) { case 1: { CSRfSMT[0,5] = FPUnewflags; } case 0: { CSRf[0,5] = FPUnewflags; } }  }
            case 0: {
                switch( start ) {
                    case 1: {
                        busy = 1;
                        switch( CSR(instruction).csr ) {
                            case 12h001: { result = SMT ? CSRfSMT[0,5] : CSRf[0,5]; }   // frflags
                            case 12h002: { result = SMT ? CSRfSMT[5,3] : CSRf[5,3]; }   // frrm
                            case 12h003: { result = SMT ? CSRfSMT : CSRf; }             // frcsr
                            case 12h301: { result = $CPUISA$; }
                            case 12hc00: { result = SMT ? CSRcycletimeSMT[0,32] : CSRcycletime[0,32]; }
                            case 12hc80: { result = SMT ? CSRcycletimeSMT[32,32] :  CSRcycletime[32,32]; }
                            case 12hc01: { result = CSRtimer[0,32]; }
                            case 12hc81: { result = CSRtimer[32,32]; }
                            case 12hc02: { result = SMT ? CSRinstretSMT[0,32] : CSRinstret[0,32]; }
                            case 12hc82: { result = SMT ? CSRinstretSMT[32,32] : CSRinstret[32,32]; }
                            case 12hf14: { result = SMT; }
                            default: { result = 0; }
                        }
                        switch( function3[0,2] ) {
                            default: {}
                            case 2b01: {
                                // CSRRW / CSRRWI
                                switch( { rs1 == 0, function3[2,1] } ) {
                                    case 2b10: {}
                                    default: {
                                        switch( CSR(instruction).csr ) {
                                            case 12h001: { switch( SMT ) { case 1: { CSRfSMT[0,5] = writevalue[0,5]; } case 0: { CSRf[0,5] = writevalue[0,5]; } } }
                                            case 12h002: { switch( SMT ) { case 1: { CSRfSMT[5,3] = writevalue[0,3]; } case 0: { CSRf[5,3] = writevalue[0,3]; } } }
                                            case 12h003: { switch( SMT ) { case 1: { CSRfSMT = writevalue[0,8]; } case 0: { CSRf = writevalue[0,8]; } } }
                                            default: {}
                                        }
                                    }
                                }
                            }
                            case 2b10: {
                                // CSRRS / CSRRSI
                                switch( rs1 ) {
                                    case 0: {}
                                    default: {
                                        switch( CSR(instruction).csr ) {
                                            case 12h001: { switch( SMT ) { case 1: { CSRfSMT[0,5] = CSRfSMT[0,5] | writevalue[0,5]; } case 0: { CSRf[0,5] = CSRf[0,5] | writevalue[0,5]; } } }
                                            case 12h002: { switch( SMT ) { case 1: { CSRfSMT[5,3] = CSRfSMT[5,3] | writevalue[0,3]; } case 0: { CSRf[5,3] = CSRf[5,3] | writevalue[0,3]; } } }
                                            case 12h003: { switch( SMT ) { case 1: { CSRfSMT = CSRfSMT | writevalue[0,8]; } case 0: { CSRf = CSRf | writevalue[0,8]; } } }
                                            default: {}
                                        }
                                    }
                                }
                            }
                            case 2b11: {
                                // CSRRC / CSRRCI
                                switch( rs1 ) {
                                    case 0: {}
                                    default: {
                                        switch( CSR(instruction).csr ) {
                                            case 12h001: { switch( SMT ) { case 1: { CSRfSMT[0,5] = CSRfSMT[0,5] & ~writevalue[0,5]; } case 0: { CSRf[0,5] = CSRf[0,5] & ~writevalue[0,5]; } } }
                                            case 12h002: { switch( SMT ) { case 1: { CSRfSMT[5,3] = CSRfSMT[5,3] & ~writevalue[0,3]; } case 0: { CSRf[5,3] = CSRf[5,3] & ~writevalue[0,3]; } } }
                                            case 12h003: { switch( SMT ) { case 1: { CSRfSMT = CSRfSMT & ~writevalue[0,8]; } case 0: { CSRf = CSRf & ~writevalue[0,8]; } } }
                                            default: {}
                                        }
                                    }
                                }
                            }
                        }
                        busy = 0;
                    }
                }
            }
        }
    }
}

// ATOMIC A EXTENSION ALU
algorithm aluA (
    input   uint7   function7,
    input   uint32  memoryinput,
    input   uint32  sourceReg2,

    output  uint32  result
) <autorun> {
    always {
        switch( function7[2,5] ) {
            default: { result = memoryinput + sourceReg2; }                 // AMOADD
            case 5b00001: { result = sourceReg2; }                          // AMOSWAP
            case 5b00100: { result = memoryinput ^ sourceReg2; }            // AMOXOR
            case 5b01000: { result = memoryinput | sourceReg2; }            // AMOOR
            case 5b01100: { result = memoryinput & sourceReg2; }            // AMOAND
            case 5b10000: { ( result ) = min( memoryinput, sourceReg2); }   // AMOMIN
            case 5b10100: { ( result ) = max( memoryinput, sourceReg2); }   // AMOMAX
            case 5b11000: { ( result ) = minu( memoryinput, sourceReg2); }  // AMOMINU
            case 5b11100: { ( result ) = maxu( memoryinput, sourceReg2); }  // AMOMAXU
        }
    }
}

