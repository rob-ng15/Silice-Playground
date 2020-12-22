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

    output!  int32   sourceReg1,
    output!  int32   sourceReg2,

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

    input   uint1   clock_copro,

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
