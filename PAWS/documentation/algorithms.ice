algorithm branchcomparison (
    input   uint7   opCode,
    input   uint3   function3,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    output  uint1   takeBranch
) <autorun> {
    while(1) {
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

// RISC-V REGISTERS
algorithm registers(
    input   uint1   SMT,
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint5   rd,
    input   uint1   write,
    input   int32   result,
    output! int32   sourceReg1,
    output! int32   sourceReg2
) <autorun> {
    // RISC-V REGISTERS
    simple_dualport_bram int32 registers_1 <input!> [64] = { 0, pad(0) };
    simple_dualport_bram int32 registers_2 <input!> [64] = { 0, pad(0) };

    // REGISTER Read/Write Flags
    sourceReg1 := registers_1.rdata0;
    sourceReg2 := registers_2.rdata0;
    registers_1.wenable1 := 1;
    registers_2.wenable1 := 1;

    while(1) {
        // READ FROM REGISTERS
        registers_1.addr0 = rs1 + ( SMT ? 32 : 0 );
        registers_2.addr0 = rs2 + ( SMT ? 32 : 0 );

        // WRITE TO REGISTERS
        // NEVER write to registers[0]
        if( write && ( rd != 0 ) ) {
            registers_1.addr1 = rd + ( SMT ? 32 : 0 );
            registers_1.wdata1 = result;
            registers_2.addr1 = rd + ( SMT ? 32 : 0 );
            registers_2.wdata1 = result;
        }
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
    outputzgh  uint5   IshiftCount
) <autorun> {
    while(1) {
        opCode = Utype(instruction).opCode;
        function3 = Rtype(instruction).function3;
        function7 = Rtype(instruction).function7;

        rs1 = Rtype(instruction).sourceReg1;
        rs2 = Rtype(instruction).sourceReg2;
        rd = Rtype(instruction).destReg;

        immediateValue = { {20{instruction[31,1]}}, Itype(instruction).immediate };
        IshiftCount = ItypeSHIFT( instruction ).shiftCount;
    }
}

// RISC-V ADDRESS BASE/OFFSET GENERATOR
algorithm addressgenerator (
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
    while(1) {
        nextPC = pc + ( compressed ? 2 : 4 );
        branchAddress = { {20{Btype(instruction).immediate_bits_12}}, Btype(instruction).immediate_bits_11, Btype(instruction).immediate_bits_10_5, Btype(instruction).immediate_bits_4_1, 1b0 } + pc;
        jumpAddress = { {12{Jtype(instruction).immediate_bits_20}}, Jtype(instruction).immediate_bits_19_12, Jtype(instruction).immediate_bits_11, Jtype(instruction).immediate_bits_10_1, 1b0 } + pc;
        AUIPCLUI = { Utype(instruction).immediate_bits_31_12, 12b0 } + ( instruction[5,1] ? 0 : pc );
        storeAddress = { {20{instruction[31,1]}}, Stype(instruction).immediate_bits_11_5, Stype(instruction).immediate_bits_4_0 } + sourceReg1;
        loadAddress = immediateValue + sourceReg1;
    }
}
