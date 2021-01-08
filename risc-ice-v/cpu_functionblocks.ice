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

    simple_dualbram_port0   registers_1,
    simple_dualbram_port0   registers_2
) <autorun> {
    registers_1.addr0 := rs1 + ( floatingpoint ? 32 : 0 );
    registers_2.addr0 := rs2 + ( floatingpoint ? 32 : 0 );

    sourceReg1 := registers_1.rdata0;
    sourceReg2 := registers_2.rdata0;

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

    output  int32   immediateValue,
    output  uint5   IshiftCount
) <autorun> {
    opCode := Utype(instruction).opCode;
    function3 := Rtype(instruction).function3;
    function7 := Rtype(instruction).function7;

    rs1 := Rtype(instruction).sourceReg1;
    rs2 := Rtype(instruction).sourceReg2;
    rd := Rtype(instruction).destReg;

    immediateValue := { {20{instruction[31,1]}}, Itype(instruction).immediate };
    IshiftCount := ItypeSHIFT( instruction ).shiftCount;

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
    int32   immediateValue := { {20{instruction[31,1]}}, Itype(instruction).immediate };

    pcPLUS2 := pc + 2;
    nextPC := pc + ( compressed ? 2 : 4 );

    branchAddress := { {20{Btype(instruction).immediate_bits_12}}, Btype(instruction).immediate_bits_11, Btype(instruction).immediate_bits_10_5, Btype(instruction).immediate_bits_4_1, 1b0 } + pc;

    jumpAddress := { {12{Jtype(instruction).immediate_bits_20}}, Jtype(instruction).immediate_bits_19_12, Jtype(instruction).immediate_bits_11, Jtype(instruction).immediate_bits_10_1, 1b0 } + pc;

    AUIPCLUI := { Utype(instruction).immediate_bits_31_12, 12b0 } + ( opCode[5,1] ? 0 : pc );

    storeAddress := { {20{instruction[31,1]}}, Stype(instruction).immediate_bits_11_5, Stype(instruction).immediate_bits_4_0 } + sourceReg1;
    storeAddressPLUS2 := { {20{instruction[31,1]}}, Stype(instruction).immediate_bits_11_5, Stype(instruction).immediate_bits_4_0 } + sourceReg1 + 2;

    loadAddress := immediateValue + sourceReg1;
    loadAddressPLUS2 := immediateValue + sourceReg1 + 2;

    while(1) {
    }
}

// BRANCH COMPARISIONS
algorithm branchcomparison (
    input   uint7   opCode,
    input   uint3   function3,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    output! uint1   takeBranch
) <autorun> {
    while(1) {
        // ONLY TRIGGER IF A BRANCH INSTRUCTION
        if( opCode == 7b1100011 ) {
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
}

// RISC-V ALU BASE IMMEDIATE
algorithm aluI (
    input   uint7   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   int32   immediateValue,
    input   uint5   IshiftCount,
    input   int32   sourceReg1,

    output  int32   result,
) <autorun> {
    while(1) {
        // BASE ALU - ONLY TRIGGER IF ALU OPERATION
        if( opCode == 7b0010011 ) {
            switch( function3 ) {
                case 3b000: { result = sourceReg1 + immediateValue; }
                case 3b001: { result = __unsigned(sourceReg1) << IshiftCount; }
                case 3b010: { result = __signed( sourceReg1 ) < __signed(immediateValue) ? 32b1 : 32b0; }
                case 3b011: { result = ( immediateValue == 1 ) ? ( ( sourceReg1 == 0 ) ? 32b1 : 32b0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ) ? 32b1 : 32b0 ); }
                case 3b100: { result = sourceReg1 ^ immediateValue; }
                case 3b101: { result = function7[5,1] ? (__signed(sourceReg1) >>> IshiftCount) : (__unsigned(sourceReg1) >> IshiftCount); }
                case 3b110: { result = sourceReg1 | immediateValue; }
                case 3b111: { result = sourceReg1 & immediateValue; }
            }
        }
    }
}

// RISC-V ALU BASE REGISTER
algorithm aluR (
    input   uint7   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   int32   sourceReg1,
    input   int32   sourceReg2,

    output  int32   result,
) <autorun> {

    while(1) {
        // BASE ALU - ONLY TRIGGER IF ALU OPERATION
        if( opCode == 7b0110011 ) {
            switch( function3 ) {
                case 3b000: { result = sourceReg1 + ( function7[5,1] ? -( sourceReg2 ) : sourceReg2 ); }
                case 3b001: { result = __unsigned(sourceReg1) << sourceReg2[0,5]; }
                case 3b010: { result = __signed( sourceReg1 ) < __signed(sourceReg2) ? 32b1 : 32b0; }
                case 3b011: { result = ( rs1 == 0 ) ? ( ( sourceReg2 != 0 ) ? 32b1 : 32b0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ) ? 32b1 : 32b0 ); }
                case 3b100: { result = sourceReg1 ^ sourceReg2; }
                case 3b101: { result = function7[5,1] ? ( __signed(sourceReg1) >>> sourceReg2[0,5]) : (__unsigned(sourceReg1) >> sourceReg2[0,5]); }
                case 3b110: { result = sourceReg1 | sourceReg2; }
                case 3b111: { result = sourceReg1 & sourceReg2; }
            }
        }
    }
}

// RISC-V ALU M EXTENSION
algorithm aluM (
    input   uint3   function3,
    input   int32   sourceReg1,
    input   int32   sourceReg2,

    input   uint1   start,
    output  uint1   busy,

    output  int32  result
) <autorun> {
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

    uint1   active = 0;
    busy := start ? 1 : active;

    // MULTIPLICATION and DIVISION Start Flags
    dividerunit.start := 0;
    multiplicationuint.start := 0;

    while(1) {
        if( start ) {
            switch( function3[2,1] ) {
                case 1b0: {
                    // MULTIPLICATION
                    active = 1;
                    multiplicationuint.start = 1;
                    while( multiplicationuint.active ) {}
                    result = multiplicationuint.result;
                    active = 0;
                }
                case 1b1: {
                    // DIVISION / REMAINDER
                    active = 1;
                    dividerunit.start = 1;
                    while( dividerunit.active ) {}
                    result = dividerunit.result;
                    active = 0;
                }
            }
        }
    }
}

// EXPAND RISC-V 16 BIT COMPRESSED INSTRUCTIONS TO THEIR 32 BIT EQUIVALENT
algorithm compressedexpansion (
    input!  uint16  i16,
    output! uint32  i32,
    output! uint1   compressed
) <autorun> {
    while(1) {
        switch( i16[0,2] ) {
            case 2b00: {
                compressed = 1;

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

            case 2b01: {
                compressed = 1;

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

            case 2b10: {
                compressed = 1;

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

            case 2b11: {
                compressed = 0;
                i32 = { 16h0000, i16 };
            }
        }
    }
}

algorithm CSRblock (
    input   uint32  instruction,
    input   uint1   incCSRinstret,
    output  uint32  result
) <autorun> {
    // RDCYCLE[H] and RDTIME[H] are equivalent on PAWSCPU
    uint64  CSRcycletime = 0;
    uint64  CSRinstret = 0;

    CSRcycletime := CSRcycletime + 1;
    CSRinstret := CSRinstret + ( incCSRinstret ? 1 : 0 );

    while(1) {
        if( ( CSR(instruction).rs1 == 0 ) && ( CSR(instruction).function3 == 3b010 ) ) {
            switch( CSR(instruction).csr ) {
                case 12hc00: {
                    result = CSRcycletime[0,32];
                }
                case 12hc80: {
                    result = CSRcycletime[32,32];
                }
                case 12hc01: {
                    result = CSRcycletime[0,32];
                }
                case 12hc81: {
                    result = CSRcycletime[32,32];
                }
                case 12hc02: {
                    result = CSRinstret[0,32];
                }
                case 12hc82: {
                    result = CSRinstret[32,32];
                }
                default: {
                    result = 0;
                }
            }
        } else {
            result = 0;
        }
    }
}
