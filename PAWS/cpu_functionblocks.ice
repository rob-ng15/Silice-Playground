// RISC V INSTRUCTION DECODER
algorithm decode(
    input   uint32  instruction,
    output  uint5   opCode,
    output  uint3   function3,
    output  uint7   function7,
    output  uint5   rs1,
    output  uint5   rs2,
    output  uint5   rs3,
    output  uint5   rd,
    output  int32   immediateValue,
    output  uint1   memoryload,
    output  uint1   memorystore,
    output  uint2   accesssize
) <autorun,reginputs> {
    uint1   AMO <:: ( opCode == 5b01011 );
    uint1   AMOLR <:: ( function7[2,5] == 5b00010 );
    uint1   AMOSC <:: ( function7[2,5] == 5b00011 );
    uint1   ILOAD <:: opCode == 5b00000;
    uint1   ISTORE <:: opCode == 5b01000;
    uint1   FLOAD <:: opCode == 5b00001;
    uint1   FSTORE <:: opCode == 5b01001;

    always {
        opCode = instruction[2,5];
        function3 = Rtype(instruction).function3;
        function7 = Rtype(instruction).function7;
        rs1 = Rtype(instruction).sourceReg1;
        rs2 = Rtype(instruction).sourceReg2;
        rs3 = R4type(instruction).sourceReg3;
        rd = Rtype(instruction).destReg;
        immediateValue = { {20{instruction[31,1]}}, Itype(instruction).immediate };
        memoryload = ILOAD | FLOAD | ( AMO & ~AMOSC );
        memorystore = ISTORE | FSTORE | ( AMO & ~AMOLR );
        accesssize = AMO | FLOAD | FSTORE ? 2b10 : function3[0,2];
    }
}

// DETERMINE IF FAST OR SLOW INSTRUCTION
// SET CPU CONTROLS DEPENDING UPON INSTRUCTION TYPE
algorithm Iclass(
    input   uint5   opCode,
    input   uint3   function3,
    input   uint1   isALUM,
    output  uint1   frd,
    output  uint1   writeRegister,
    output  uint1   incPC,
    output  uint1   FASTPATH
) <autorun,reginputs> {
    // CHECK FOR FLOATING POINT, OR INTEGER DIVIDE
    uint1   ALUfastslow <:: ~( opCode[4,1] | ( opCode[3,1] & isALUM & function3[2,1]) );
    frd := 0; writeRegister := 1; incPC := 1; FASTPATH := 1;
    always {
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
            case 5b01011: { FASTPATH = 0; }         // LR.W SC.W ATOMIC LOAD - MODIFY - STORE
            default: { FASTPATH = ALUfastslow; }    // FPU OR INTEGER DIVIDE -> SLOWPATH ALL ELSE TO FASTPATH
        }
    }
}

// DETERMINE IN FAST OR SLOW FPU INSTRUCTION
algorithm Fclass(
    input   uint1   is2FPU,
    input   uint1   isFPUFAST,
    output  uint1   FASTPATHFPU
) <autorun,reginputs> {
    // FUSED OPERATIONS + CALCULATIONS & CONVERSIONS GO VIA SLOW PATH
    // SIGN MANIPULATION, COMPARISONS + MIN/MAX, MOVE AND CLASSIFICATION GO VIA FAST PATH
    always {
        FASTPATHFPU = is2FPU & isFPUFAST;           // is2FPU DETERMINES IF NORMAL OR FUSED, THEN isFPUFAST DETERMINES IF FAST OR SLOW
    }
}

// PERFORM SIGN EXTENSION FOR 8 AND 16 BIT LOADS
algorithm signextend(
    input   uint16  readdata,
    input   uint1   is16or8,
    input   uint1   byteaccess,
    input   uint1   dounsigned,
    output  uint32  memory168
) <autorun,reginputs> {
    uint4   byteoffset <:: { byteaccess, 3b000 };
    uint4   bytesignoffset <:: { byteaccess, 3b111 };

    always {
        memory168 = is16or8 ? dounsigned ? readdata[0,16] : { {16{readdata[15,1]}}, readdata[0,16] } :
                                dounsigned ? readdata[byteoffset, 8] : { {24{readdata[bytesignoffset, 1]}}, readdata[byteoffset, 8] };
    }
}

// FIND THE ABSOLUTE VALUE FOR A SIGNED 32 BIT NUMBER
algorithm absolute(
    input   int32   number,
    output  uint32  value
) <autorun,reginputs> {
    always {
        value = number[31,1] ? -number : number;
    }
}

// ADD 2 TO AN ADDRESS FOR 32 BIT LOAD/STORES
algorithm addrplus2(
    input   uint27  address,
    output  uint27  addressplus2
) <autorun,reginputs> {
    always {
        addressplus2 = address + 2;
    }
}

// RISC-V ADDRESS GENERATOR
algorithm addressgenerator(
    input   uint32  instruction,
    input   uint27  PC,
    input   int32   sourceReg1,
    output  uint32  AUIPCLUI,
    output  uint27  branchAddress,
    output  uint27  jumpAddress,
    output  uint27  loadAddress,
    output  uint27  storeAddress
) <autorun,reginputs> {
    int32   immediateValue <:: { {20{instruction[31,1]}}, Itype(instruction).immediate };
    uint1   AMO <:: ( instruction[2,5] == 5b01011 );

    always {
        AUIPCLUI = { Utype(instruction).immediate_bits_31_12, 12b0 } + ( instruction[5,1] ? 0 : PC );
        branchAddress = { {20{Btype(instruction).immediate_bits_12}}, Btype(instruction).immediate_bits_11, Btype(instruction).immediate_bits_10_5, Btype(instruction).immediate_bits_4_1, 1b0 } + PC;
        jumpAddress = { {12{Jtype(instruction).immediate_bits_20}}, Jtype(instruction).immediate_bits_19_12, Jtype(instruction).immediate_bits_11, Jtype(instruction).immediate_bits_10_1, 1b0 } + PC;
        loadAddress = ( AMO ? 0 : immediateValue ) + sourceReg1;
        storeAddress = ( AMO ? 0 : { {20{instruction[31,1]}}, Stype(instruction).immediate_bits_11_5, Stype(instruction).immediate_bits_4_0 } ) + sourceReg1;
    }
}

// RISC-V SELECT THE NEXT INSTRUCTION BASED ON CPU STATE FLAGS
algorithm newpc(
    input   uint5   opCode,
    input   uint27  PC,
    input   uint1   compressed,
    input   uint1   incPC,
    input   uint1   takeBranch,
    input   uint27  branchAddress,
    input   uint27  jumpAddress,
    input   uint27  loadAddress,
    output  uint27  nextPC,
    output  uint27  newPC
) <autorun,reginputs> {
    always {
        nextPC = PC + ( compressed ? 2 : 4 );
        newPC = ( incPC ) ? ( takeBranch ? branchAddress : nextPC ) : ( opCode[1,1] ? jumpAddress : loadAddress );
    }
}

// RISC-V REGISTERS
algorithm registers(
    input   uint1   SMT,
    input   uint5   rs,
    input   uint5   rd,
    input   uint1   write,
    input   uint32  result,
    output  uint32  contents
) <autorun,reginputs> {
    simple_dualport_bram int32 registers[64] = { 0, pad(uninitialized) };
    registers.addr0 := { SMT, rs }; contents := registers.rdata0;
    registers.addr1 := { SMT, rd }; registers.wdata1 := result;
    registers.wenable1 := write;
}

// RISC-V REGISTERS - INTEGERS
algorithm registersI(
    input   uint1   SMT,
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint5   rd,
    input   uint1   write,
    input   int32   result,
    output  int32   sourceReg1,
    output  int32   sourceReg2
) <autorun,reginputs> {
    // RISC-V REGISTERS
    registers RS1( SMT <: SMT, rs <: rs1, rd <: rd, write <: write, result <: result, contents :> sourceReg1 );
    registers RS2( SMT <: SMT, rs <: rs2, rd <: rd, write <: write, result <: result, contents :> sourceReg2 );
}
// RISC-V REGISTERS - FLOATING POINT
algorithm registersF(
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
) <autorun,reginputs> {
    // RISC-V REGISTERS
    registers RS1F( SMT <: SMT, rs <: rs1, rd <: rd, write <: write, result <: result, contents :> sourceReg1 );
    registers RS2F( SMT <: SMT, rs <: rs2, rd <: rd, write <: write, result <: result, contents :> sourceReg2 );
    registers RS3F( SMT <: SMT, rs <: rs3, rd <: rd, write <: write, result <: result, contents :> sourceReg3 );
}

// BRANCH COMPARISIONS
algorithm branchcomparison(
    input   uint3   function3,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    output  uint1   takeBranch
) <autorun,reginputs> {
    uint1   isequal <:: sourceReg1 == sourceReg2;
    uint1   unsignedcompare <:: __unsigned(sourceReg1) < __unsigned(sourceReg2);
    uint1   signedcompare <:: __signed(sourceReg1) < __signed(sourceReg2);
    takeBranch := 0;
    always {
        switch( function3[1,2] ) {
            case 2b00: { takeBranch = function3[0,1] ^ isequal; }
            case 2b10: { takeBranch = function3[0,1] ^ signedcompare; }
            case 2b11: { takeBranch = function3[0,1] ^ unsignedcompare; }
            default: {}
        }
    }
}

// COMPRESSED INSTRUCTION EXPANSION
algorithm compressed00(
    input   uint16  i16,
    output  uint30  i32
) <autorun,reginputs> {
    always {
        switch( i16[13,3] ) {
            case 3b000: {
                // ADDI4SPN -> addi rd', x2, nzuimm[9:2] { 000, nzuimm[5:4|9:6|2|3] rd' 00 } -> { imm[11:0] rs1 000 rd 0010011 }
                i32 = { 2b0, CIu94(i16).ib_9_6, CIu94(i16).ib_5_4, CIu94(i16).ib_3, CIu94(i16).ib_2, 2b00, 5h2, 3b000, {2b01,CIu94(i16).rd_alt}, 5b00100 };
            }
            default: {
                if( i16[15,1] ) {
                    // SW -> sw rs2', offset[6:2](rs1') { 110 uimm[5:3] rs1' uimm[2][6] rs2' 00 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100011 }
                    // FSW -> fsw rs2', offset[6:2](rs1') { 110 uimm[5:3] rs1' uimm[2][6] rs2' 00 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100111 }
                    i32 = { 5b0, CS(i16).ib_6, CS(i16).ib_5, {2b01,CS(i16).rs2_alt}, {2b01,CS(i16).rs1_alt}, 3b010, CS(i16).ib_4_3, CS(i16).ib_2, 2b0, { 4b0100, i16[13,1] } };
                } else {
                    // LW -> lw rd', offset[6:2](rs1') { 010 uimm[5:3] rs1' uimm[2][6] rd' 00 } -> { imm[11:0] rs1 010 rd 0000011 }
                    // FLW -> flw rd', offset[6:2](rs1') { 010 uimm[5:3] rs1' uimm[2][6] rd' 00 } -> { imm[11:0] rs1 010 rd 0000111 }
                    i32 = { 5b0, CL(i16).ib_6, CL(i16).ib_5_3, CL(i16).ib_2, 2b00, {2b01,CL(i16).rs1_alt}, 3b010, {2b01,CL(i16).rd_alt}, { 4b0000, i16[13,1] } };
                }
            }
        }
    }
}
algorithm compressed01(
    input   uint16  i16,
    output  uint30  i32
) <autorun,reginputs> {
    uint3   opbits = uninitialized;
    always {
        switch( i16[13,3] ) {
            case 3b000: {
                // ADDI -> addi rd, rd, nzimm[5:0] { 000 nzimm[5] rs1/rd!=0 nzimm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                // NOP if rd == 0 and nzimm == 5b000000
                i32 = { {7{CI50(i16).ib_5}}, CI50(i16).ib_4_0, CI50(i16).rd, 3b000, CI50(i16).rd, 5b00100 };
            }
            case 3b001: {
                // JAL -> jal x1, offset[11:1] { 001, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
                i32 = { CJ(i16).ib_11, CJ(i16).ib_10, CJ(i16).ib_9_8, CJ(i16).ib_7, CJ(i16).ib_6, CJ(i16).ib_5, CJ(i16).ib_4, CJ(i16).ib_3_1, {8{CJ(i16).ib_11}}, 5h1, 5b11011 };
            }
            case 3b010: {
                // LI -> addi rd, x0, imm[5:0] { 010 imm[5] rd!=0 imm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                i32 = { {7{CI50(i16).ib_5}}, CI50(i16).ib_4_0, 5h0, 3b000, CI(i16).rd, 5b00100 };
            }
            case 3b011: {
                switch( CI(i16).rd ) {
                    case 2: {
                        // ADDI16SP -> addi x2, x2, nzimm[9:4] { 011 nzimm[9] 00010 nzimm[4|6|8:7|5] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                        i32 = { {3{CI94(i16).ib_9}}, CI94(i16).ib_8_7, CI94(i16).ib_6, CI94(i16).ib_5, CI94(i16).ib_4, 4b0000, 5h2, 3b000, 5h2, 5b00100 };
                    }
                    default: {
                        // LUI -> lui rd, nzuimm[17:12] { 011 nzimm[17] rd!={0,2} nzimm[16:12] 01 } -> { imm[31:12] rd 0110111 }
                        i32 = { {15{CIlui(i16).ib_17}}, CIlui(i16).ib_16_12, CIlui(i16).rd, 5b01101 };
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
                        i32 = { { 1b0, i16[10,1], 5b00000 }, CBalu50(i16).ib_4_0, { 2b01, CBalu50(i16).rd_alt }, 3b101, { 2b01, CBalu50(i16).rd_alt }, 5b00100 };
                    }
                    case 2b10: {
                        // ANDI -> andi rd', rd', imm[5:0] { 100 imm[5], 10 rs1'/rd' imm[4:0] 01 } -> { imm[11:0] rs1 111 rd 0010011 }
                        i32 = { {7{CBalu50(i16).ib_5}}, CBalu50(i16).ib_4_0, { 2b01, CBalu50(i16).rd_alt }, 3b111, { 2b01, CBalu50(i16).rd_alt }, 5b00100 };
                    }
                    case 2b11: {
                        // CBalu(i16).logical2 -> SUB XOR OR AND
                        switch( CBalu(i16).logical2 ) {
                            case 2b00: { opbits = 3b000; } // 2b00 -> SUB -> sub rd', rd', rs2' { 100 0 11 rs1'/rd' 00 rs2' 01 } -> { 0100000 rs2 rs1 000 rd 0110011 }
                            case 2b01: { opbits = 3b100; } // 2b01 -> XOR -> xor rd', rd', rs2' { 100 0 11 rs1'/rd' 01 rs2' 01 } -> { 0000000 rs2 rs1 100 rd 0110011 }
                            case 2b10: { opbits = 3b110; } // 2b10 -> OR  -> or  rd', rd', rd2' { 100 0 11 rs1'/rd' 10 rs2' 01 } -> { 0000000 rs2 rs1 110 rd 0110011 }
                            case 2b11: { opbits = 3b111; } // 2b11 -> AND -> and rd', rd', rs2' { 100 0 11 rs1'/rd' 11 rs2' 01 } -> { 0000000 rs2 rs1 111 rd 0110011 }
                        }
                        i32 = { { 1b0, CBalu(i16).logical2 == 2b00 ? 1b1 : 1b0, 5b00000 }, { 2b01, CBalu(i16).rs2_alt }, { 2b01, CBalu(i16).rd_alt }, opbits, { 2b01, CBalu(i16).rd_alt }, 5b01100 };
                    }
                }
            }
            case 3b101: {
                // J -> jal, x0, offset[11:1] { 101, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
                i32 = { CJ(i16).ib_11, CJ(i16).ib_10, CJ(i16).ib_9_8, CJ(i16).ib_7, CJ(i16).ib_6, CJ(i16).ib_5, CJ(i16).ib_4, CJ(i16).ib_3_1, {9{CJ(i16).ib_11}}, 5h0, 5b11011 };
            }
            default: {
                // 3b110 -> BEQZ -> beq rs1', x0, offset[8:1] { 110, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 000 imm[4:1|11] 1100011 }
                // 3b111 -> BNEZ -> bne rs1', x0, offset[8:1] { 111, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 001 imm[4:1|11] 1100011 }
                opbits = { 2b00, i16[13,1] };
                i32 = { {4{CB(i16).offset_8}}, CB(i16).offset_7_6, CB(i16).offset_5, 5h0, {2b01,CB(i16).rs1_alt}, opbits, CB(i16).offset_4_3, CB(i16).offset_2_1, CB(i16).offset_8, 5b11000 };
            }
        }
    }
}
algorithm compressed10(
    input   uint16  i16,
    output  uint30  i32
) <autorun,reginputs> {
    always {
        switch( i16[13,3] ) {
            case 3b000: {
                // SLLI -> slli rd, rd, shamt[5:0] { 000, nzuimm[5], rs1/rd!=0 nzuimm[4:0] 10 } -> { 0000000 shamt rs1 001 rd 0010011 }
                i32 = { 7b0000000, CI50(i16).ib_4_0, CI50(i16).rd, 3b001, CI50(i16).rd, 5b00100 };
            }
            case 3b100: {
                // J[AL]R / MV / ADD
                switch( CR(i16).rs2 ) {
                    case 0: {
                        // JR   -> jalr x0, rs1, 0 { 100 0 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                        // JALR -> jalr x1, rs1, 0 { 100 1 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                        i32 = { 12b0, CR(i16).rs1, 3b000, { 4b0000, i16[12,1]}, 5b11001 };
                    }
                    default: {
                        // MV  -> add rd, x0, rs2 { 100 0 rd!=0 rs2!=0 10 }     -> { 0000000 rs2 rs1 000 rd 0110011 }
                        // ADD -> add rd, rd, rs2 { 100 1 rs1/rd!=0 rs2!=0 10 } -> { 0000000 rs2 rs1 000 rd 0110011 }
                        i32 = { 7b0000000, CR(i16).rs2, i16[12,1] ? CR(i16).rs1: 5h0, 3b000, CR(i16).rs1, 5b01100 };
                    }
                }
            }
            default: {
                if( i16[15,1] ) {
                    // SWSP -> sw rs2, offset[7:2](x2) { 110 uimm[5][4:2][7:6] rs2 10 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100011 }
                    // FSWSP -> fsw rs2, offset[7:2](x2) { 110 uimm[5][4:2][7:6] rs2 10 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100111 }
                    i32 = { 4b0, CSS(i16).ib_7_6, CSS(i16).ib_5, CSS(i16).rs2, 5h2, 3b010, CSS(i16).ib_4_2, 2b00, { 4b0100, i16[13,1] } };
                } else {
                    // LWSP -> lw rd, offset[7:2](x2) { 011 uimm[5] rd uimm[4:2|7:6] 10 } -> { imm[11:0] rs1 010 rd 0000011 }
                    // FLWSP -> flw rd, offset[7:2](x2) { 011 uimm[5] rd uimm[4:2|7:6] 10 } -> { imm[11:0] rs1 010 rd 0000111 }
                    i32 = { 4b0, CI(i16).ib_7_6, CI(i16).ib_5, CI(i16).ib_4_2, 2b0, 5h2 ,3b010, CI(i16).rd,  { 4b0000, i16[13,1] } };
                }
            }
        }
    }
}

// RISC-V MANDATORY CSR REGISTERS
algorithm counter40(
    input   uint1   update,
    output  uint40  counter(0)
) <autorun,reginputs> {
    always {
        counter = counter + update;
    }
}
algorithm counter40always(
    output  uint40  counter(0)
) <autorun,reginputs> {
    always {
        counter = counter + 1;
    }
}
algorithm CSRblock(
    input   uint1   start,
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
) <autorun,reginputs> {
    // MAIN SYSTEM TIMER
    uint48  CSRtimer = uninitialized;                                                               counter40always TIMER( counter :> CSRtimer );

    // CPU HART CYCLE TIMERS
    uint48  CSRcycletimer = uninitialized;      uint1   UPDATEcycletimer <:: ~SMT;                  counter40 CYCLE( update <: UPDATEcycletimer, counter :> CSRcycletimer );
    uint48  CSRcycletimerSMT = uninitialized;   uint1   UPDATEcycletimerSMT <:: SMT;                counter40 CYCLESMT( update <: UPDATEcycletimerSMT, counter :> CSRcycletimerSMT);

    // CPU HART INSTRUCTION RETIRED COUNTERS
    uint48  CSRinstret = uninitialized;         uint1   UPDATEinstret <:: incCSRinstret & ~SMT;     counter40 INSTRET( update <: UPDATEinstret, counter :> CSRinstret );
    uint48  CSRinstretSMT = uninitialized;      uint1   UPDATEinstretSMT <:: incCSRinstret & SMT;   counter40 INSTRETSMT( update <: UPDATEinstretSMT, counter :> CSRinstretSMT );

    // FLOATING-POINT CSR FOR BOTH THREADS
    uint8   CSRf[2] = { 0, 0 };

    // SWITCH BETWEEN IMMEDIATE OR REGISTER VALUE TO WRITE TO CSR
    uint32  writevalue <:: function3[2,1] ? rs1 : sourceReg1;

    // PASS PRESENT FPU FLAGS TO THE FPU
    FPUflags ::= CSRf[SMT][0,5];

    always {
        if( updateFPUflags ) {
            CSRf[SMT][0,5] = FPUnewflags;
        } else {
            if( start ) {
                result = 0;
                switch( CSR(instruction).csr[8,4] ) {
                    case 4h0: {
                        switch( CSR(instruction).csr[0,2] ) {
                            case 2h1: { result = CSRf[SMT][0,5]; }   // frflags
                            case 2h2: { result = CSRf[SMT][5,3]; }   // frrm
                            case 2h3: { result = CSRf[SMT]; }        // frcsr
                            default: {}
                        }
                    }
                    case 4h3: { result = $CPUISA$; }
                    case 4hc: {
                        switch( { CSR(instruction).csr[7,1], CSR(instruction).csr[0,2] } ) {
                            case 5h00: { result = SMT ? CSRcycletimerSMT[0,32] : CSRcycletimer[0,32]; }
                            case 5h10: { result = SMT ? CSRcycletimerSMT[32,8] : CSRcycletimer[32,8]; }
                            case 5h01: { result = CSRtimer[0,32]; }
                            case 5h11: { result = CSRtimer[32,8]; }
                            case 5h02: { result = SMT ? CSRinstretSMT[0,32] : CSRinstret[0,32]; }
                            case 5h12: { result = SMT ? CSRinstretSMT[32,8] : CSRinstret[32,8]; }
                            default: {}
                        }
                     }
                    case 4hf: { result = SMT; }                     // HART ID
                    default: { result = 0; }
                }
                if( ~|CSR(instruction).csr[4,8] ) {
                    switch( function3[0,2] ) {
                        case 2b00: {
                            // ECALL / EBBREAK
                        }
                        case 2b01: {
                            // CSRRW / CSRRWI
                            switch( { ~|rs1, function3[2,1] } ) {
                                case 2b10: {}
                                default: {
                                    switch( CSR(instruction).csr[0,4] ) {
                                        case 4h1: { CSRf[SMT][0,5] = writevalue[0,5]; }
                                        case 4h2: { CSRf[SMT][5,3] = writevalue[0,3]; }
                                        case 4h3: { CSRf[SMT] = writevalue[0,8]; }
                                        default: {}
                                    }
                                }
                            }
                        }
                        case 2b10: {
                            // CSRRS / CSRRSI
                            if( |rs1 ) {
                                switch( CSR(instruction).csr[0,4] ) {
                                    case 4h1: { CSRf[SMT][0,5] = CSRf[SMT][0,5] | writevalue[0,5]; }
                                    case 4h2: { CSRf[SMT][5,3] = CSRf[SMT][5,3] | writevalue[0,3]; }
                                    case 4h3: { CSRf[SMT] = CSRf[SMT] | writevalue[0,8]; }
                                    default: {}
                                }
                            }
                        }
                        case 2b11: {
                            // CSRRC / CSRRCI
                            if( |rs1 ) {
                                switch( CSR(instruction).csr[0,4] ) {
                                    case 4h1: { CSRf[SMT][0,5] = CSRf[SMT][0,5] & ~writevalue[0,5]; }
                                    case 4h2: { CSRf[SMT][5,3] = CSRf[SMT][5,3] & ~writevalue[0,3]; }
                                    case 4h3: { CSRf[SMT] = CSRf[SMT] & ~writevalue[0,8]; }
                                    default: {}
                                }
                            }
                        }
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
) <autorun,reginputs> {
    uint1   unsignedcompare <:: ( __unsigned(memoryinput) < __unsigned(sourceReg2) );
    uint1   signedcompare <:: ( __signed(memoryinput) < __signed(sourceReg2) );
    uint1   comparison <:: function7[3,1] ? unsignedcompare : signedcompare;
    uint32  add <:: memoryinput + sourceReg2;

    always {
        if( function7[4,1] ) {
            result = ( function7[2,1] ^ comparison ) ? memoryinput : sourceReg2;    // AMOMAX[U] AMOMIN[U]
        } else {
            switch( function7[0,4] ) {
                default: { result = add; }                                          // AMOADD
                case 4b0001: { result = sourceReg2; }                               // AMOSWAP
                case 4b0100: { result = memoryinput ^ sourceReg2; }                 // AMOXOR
                case 4b1000: { result = memoryinput | sourceReg2; }                 // AMOOR
                case 4b1100: { result = memoryinput & sourceReg2; }                 // AMOAND.
            }
        }
    }
}
