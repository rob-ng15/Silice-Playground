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
bitfield    R4type {
    uint5   sourceReg3,
    uint2   function2,
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

// CSR Risc-V Access Instruction
bitfield    CSR {
    uint12  csr,
    uint5   rs1,
    uint3   function3,
    uint5   rd,
    uint7   opcode
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

// COMPRESSED INSTRUCTION EXPANSION
unit compressed00(
    input   uint16  i16,
    output  uint30  i32
) <reginputs> {
    always_after {
        if( |i16[13,3] ) {
            if( i16[15,1] ) {
                // SW -> sw rs2', offset[6:2](rs1') { 110 uimm[5:3] rs1' uimm[2][6] rs2' 00 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100011 }
                // FSW -> fsw rs2', offset[6:2](rs1') { 110 uimm[5:3] rs1' uimm[2][6] rs2' 00 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100111 }
                // FSD -> fsd rs2', offset[7:3](rs1') { 101 uimm[5:3] rs1' uimm[7:6] rs2' 00 } -> { imm[11:5] rs2 rs1 011 imm[4:0] 0100111 }
                if( i16[14,1] ) {
                    i32 = { 5b0, CS(i16).ib_6, CS(i16).ib_5, {2b01,CS(i16).rs2_alt}, {2b01,CS(i16).rs1_alt}, 3b010, CS(i16).ib_4_3, CS(i16).ib_2, 2b0, { 4b0100, i16[13,1] } };
                } else {
                    i32 = { 4b0, i16[5,2], i16[12,1], {2b01,CS(i16).rs2_alt}, {2b01,CS(i16).rs1_alt}, 3b011, i16[10,2], 3b0, 5b01001 };
                }
            } else {
                // LW -> lw rd', offset[6:2](rs1') { 010 uimm[5:3] rs1' uimm[2][6] rd' 00 } -> { imm[11:0] rs1 010 rd 0000011 }
                // FLW -> flw rd', offset[6:2](rs1') { 010 uimm[5:3] rs1' uimm[2][6] rd' 00 } -> { imm[11:0] rs1 010 rd 0000111 }
                // FLD -> flw rd', offset[7:3](rs1') { 001 uimm[5:3] rs1' uimm[7:6] rd' 00 } -> { imm[11:0] rs1 011 rd 0000111 }
                if( i16[14,1] ) {
                    i32 = { 5b0, CL(i16).ib_6, CL(i16).ib_5_3, CL(i16).ib_2, 2b00, {2b01,CL(i16).rs1_alt}, 3b010, {2b01,CL(i16).rd_alt}, { 4b0000, i16[13,1] } };
                } else {
                    i32 = { 4b0, i16[5,2], i16[10,3], 3b000, {2b01,CL(i16).rs1_alt}, 3b011, {2b01,CL(i16).rd_alt}, 5b00001 };
                }
            }
        } else {
            // ADDI4SPN -> addi rd', x2, nzuimm[9:2] { 000, nzuimm[5:4|9:6|2|3] rd' 00 } -> { imm[11:0] rs1 000 rd 0010011 }
            i32 = { 2b0, CIu94(i16).ib_9_6, CIu94(i16).ib_5_4, CIu94(i16).ib_3, CIu94(i16).ib_2, 2b00, 5h2, 3b000, {2b01,CIu94(i16).rd_alt}, 5b00100 };
        }
    }
}
unit compressed01(
    input   uint16  i16,
    output  uint30  i32
) <reginputs> {
    always_after {
        switch( i16[13,3] ) {
            case 3b000: {
                // ADDI -> addi rd, rd, nzimm[5:0] { 000 nzimm[5] rs1/rd!=0 nzimm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                // NOP if rd == 0 and nzimm == 5b000000
                i32 = { {7{CI50(i16).ib_5}}, CI50(i16).ib_4_0, CI50(i16).rd, 3b000, CI50(i16).rd, 5b00100 };
            }
            case 3b010: {
                // LI -> addi rd, x0, imm[5:0] { 010 imm[5] rd!=0 imm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                i32 = { {7{CI50(i16).ib_5}}, CI50(i16).ib_4_0, 5h0, 3b000, CI(i16).rd, 5b00100 };
            }
            case 3b011: {
                if( CI(i16).rd == 2 ) {
                    // ADDI16SP -> addi x2, x2, nzimm[9:4] { 011 nzimm[9] 00010 nzimm[4|6|8:7|5] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                    i32 = { {3{CI94(i16).ib_9}}, CI94(i16).ib_8_7, CI94(i16).ib_6, CI94(i16).ib_5, CI94(i16).ib_4, 4b0000, 5h2, 3b000, 5h2, 5b00100 };
                } else {
                    // LUI -> lui rd, nzuimm[17:12] { 011 nzimm[17] rd!={0,2} nzimm[16:12] 01 } -> { imm[31:12] rd 0110111 }
                    i32 = { {15{CIlui(i16).ib_17}}, CIlui(i16).ib_16_12, CIlui(i16).rd, 5b01101 };
                }
            }
            case 3b100: {
                // MISC-ALU
                if( CBalu(i16).function2[1,1] ) {
                    if( CBalu(i16).function2[0,1] ) {
                        // CBalu(i16).logical2 -> SUB XOR OR AND
                        // 2b00 -> SUB -> sub rd', rd', rs2' { 100 0 11 rs1'/rd' 00 rs2' 01 } -> { 0100000 rs2 rs1 000 rd 0110011 }
                        // 2b01 -> XOR -> xor rd', rd', rs2' { 100 0 11 rs1'/rd' 01 rs2' 01 } -> { 0000000 rs2 rs1 100 rd 0110011 }
                        // 2b10 -> OR  -> or  rd', rd', rd2' { 100 0 11 rs1'/rd' 10 rs2' 01 } -> { 0000000 rs2 rs1 110 rd 0110011 }
                        // 2b11 -> AND -> and rd', rd', rs2' { 100 0 11 rs1'/rd' 11 rs2' 01 } -> { 0000000 rs2 rs1 111 rd 0110011 }
                        i32 = { { 1b0, ~|CBalu(i16).logical2, 5b00000 }, { 2b01, CBalu(i16).rs2_alt }, { 2b01, CBalu(i16).rd_alt },
                                ( ^CBalu(i16).logical2 ) ? { 1b1, CBalu(i16).logical2[1,1], 1b0 } : {3{CBalu(i16).logical2[0,1]}}, { 2b01, CBalu(i16).rd_alt }, 5b01100 };
                    } else {
                        // ANDI -> andi rd', rd', imm[5:0] { 100 imm[5], 10 rs1'/rd' imm[4:0] 01 } -> { imm[11:0] rs1 111 rd 0010011 }
                        i32 = { {7{CBalu50(i16).ib_5}}, CBalu50(i16).ib_4_0, { 2b01, CBalu50(i16).rd_alt }, 3b111, { 2b01, CBalu50(i16).rd_alt }, 5b00100 };
                    }
                } else {
                    // i16[10,1] -> SRLI SRAI
                    // 1b0 -> SRLI -> srli rd', rd', shamt[5:0] { 100 nzuimm[5] 00 rs1'/rd' nzuimm[4:0] 01 } -> { 0000000 shamt rs1 101 rd 0010011 }
                    // 1b1 -> SRAI -> srai rd', rd', shamt[5:0] { 100 nzuimm[5] 01 rs1'/rd' nzuimm[4:0] 01 } -> { 0100000 shamt rs1 101 rd 0010011 }
                    i32 = { { 1b0, i16[10,1], 5b00000 }, CBalu50(i16).ib_4_0, { 2b01, CBalu50(i16).rd_alt }, 3b101, { 2b01, CBalu50(i16).rd_alt }, 5b00100 };
                }
            }
            default: {
                if( i16[14,1] ) {
                    // 3b110 -> BEQZ -> beq rs1', x0, offset[8:1] { 110, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 000 imm[4:1|11] 1100011 }
                    // 3b111 -> BNEZ -> bne rs1', x0, offset[8:1] { 111, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 001 imm[4:1|11] 1100011 }
                    i32 = { {4{CB(i16).offset_8}}, CB(i16).offset_7_6, CB(i16).offset_5, 5h0, {2b01,CB(i16).rs1_alt}, { 2b00, i16[13,1] }, CB(i16).offset_4_3, CB(i16).offset_2_1, CB(i16).offset_8, 5b11000 };
                } else {
                    // 3b001 -> JAL -> jal x1, offset[11:1] { 001, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
                    // 3b101 -> J -> jal, x0, offset[11:1] { 101, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
                    i32 = { CJ(i16).ib_11, CJ(i16).ib_10, CJ(i16).ib_9_8, CJ(i16).ib_7, CJ(i16).ib_6, CJ(i16).ib_5, CJ(i16).ib_4, CJ(i16).ib_3_1, {9{CJ(i16).ib_11}}, 4h0, ~i16[15,1], 5b11011 };
                }
            }
        }
    }
}
unit compressed10(
    input   uint16  i16,
    output  uint30  i32
) <reginputs> {
    always_after {
        switch( i16[13,3] ) {
            case 3b000: {
                // SLLI -> slli rd, rd, shamt[5:0] { 000, nzuimm[5], rs1/rd!=0 nzuimm[4:0] 10 } -> { 0000000 shamt rs1 001 rd 0010011 }
                i32 = { 7b0000000, CI50(i16).ib_4_0, CI50(i16).rd, 3b001, CI50(i16).rd, 5b00100 };
            }
            case 3b100: {
                // J[AL]R / MV / ADD
                if( ~|CR(i16).rs2 ) {
                    // JR   -> jalr x0, rs1, 0 { 100 0 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                    // JALR -> jalr x1, rs1, 0 { 100 1 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                    i32 = { 12b0, CR(i16).rs1, 3b000, { 4b0000, i16[12,1]}, 5b11001 };
                } else {
                    // MV  -> add rd, x0, rs2 { 100 0 rd!=0 rs2!=0 10 }     -> { 0000000 rs2 rs1 000 rd 0110011 }
                    // ADD -> add rd, rd, rs2 { 100 1 rs1/rd!=0 rs2!=0 10 } -> { 0000000 rs2 rs1 000 rd 0110011 }
                    i32 = { 7b0000000, CR(i16).rs2, i16[12,1] ? CR(i16).rs1 : 5h0, 3b000, CR(i16).rs1, 5b01100 };
                }
            }
            default: {
                if( i16[15,1] ) {
                    // SWSP -> sw rs2, offset[7:2](x2) { 110 uimm[5][4:2][7:6] rs2 10 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100011 }
                    // FSWSP -> fsw rs2, offset[7:2](x2) { 110 uimm[5][4:2][7:6] rs2 10 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100111 }
                    // FSDSP -> fsd rs2, offset[8:3](x2) { 101 uimm[5:3][8:6] rs2 10 } -> { imm[11:5] rs2 rs1 011 imm[4:0] 0100111 }
                    if( i16[14,1] ) {
                        i32 = { 4b0, CSS(i16).ib_7_6, CSS(i16).ib_5, CSS(i16).rs2, 5h2, 3b010, CSS(i16).ib_4_2, 2b00, { 4b0100, i16[13,1] } };
                    } else {
                        i32 = { 3b0, i16[7,3], i16[12,1], CSS(i16).rs2, 5h2, 3b011, i16[10,2], 3b000, 5b01001 };
                    }
                } else {
                    // LWSP -> lw rd, offset[7:2](x2) { 011 uimm[5] rd uimm[4:2|7:6] 10 } -> { imm[11:0] rs1 010 rd 0000011 }
                    // FLWSP -> flw rd, offset[7:2](x2) { 011 uimm[5] rd uimm[4:2|7:6] 10 } -> { imm[11:0] rs1 010 rd 0000111 }
                    // FLDSP -> fld rd, offset[8:3](x2) { 011 uimm[5] rd uimm[4:3|8:6] 10 } -> { imm[11:0] rs1 011 rd 0000111 }
                    if( i16[14,1] ) {
                        i32 = { 4b0, CI(i16).ib_7_6, CI(i16).ib_5, CI(i16).ib_4_2, 2b0, 5h2 ,3b010, CI(i16).rd, { 4b0000, i16[13,1] } };
                    } else {
                        i32 = { 3b0, i16[2,3], i16[12,1], i16[5,2], 3b0, 5h2, 3b011, CI(i16).rd, 5b00001 };
                    }
                }
            }
        }
    }
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}

// RISC-V FPU CONTROLLER

algorithm main(output int8 leds) {
    // CYCLE COUNTER
    uint32  startcycle = uninitialised;
    pulse PULSE();

    uint16  i16 = 3;
    uint32  i32 = 32h2c813c27;

    compressed00 C00( i16 <: i16 ); compressed01 C01( i16 <: i16 ); compressed10 C10( i16 <: i16 );

    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++: ++: ++:
    startcycle = PULSE.cycles;

    __display("i16 = %x { %b %b }",i16,i16[2,14],i16[0,2]);

    switch( i16[0,2] ) {
        case 2b00: { i32 = { C00.i32, 2b11 }; }
        case 2b01: { i32 = { C01.i32, 2b11 }; }
        case 2b10: { i32 = { C10.i32, 2b11 }; }
        case 2b11: {}
    }

    __display("i32 = %x { %b %b }",i32,i32[2,30],i32[0,2]);

    switch( i32[2,5] ) {
        case 5b00001: {
            if( Itype(i32).function3 == 3b010 ) { __write("FLW "); } else { __write("FLD "); }
            __display("x%0d,%0d(x%0d)",Itype(i32).destReg,Itype(i32).immediate,Itype(i32).sourceReg1);
        }
        case 5b01001: {
            if( Stype(i32).function3 == 3b010 ) { __write("FSW "); } else { __write("FSD "); }
            __display("x%0d,%0d(x%0d)",Stype(i32).sourceReg2,{Stype(i32).immediate_bits_11_5,Stype(i32).immediate_bits_4_0},Stype(i32).sourceReg1);
        }
        default: { __display("UNKNOWN"); }
    }
}
