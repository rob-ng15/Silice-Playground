// ALU - ALU for immediate-register operations and register-register operations
algorithm alu(
    input   uint5   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  immediateValue,

    output  uint32  result
) <autorun,reginputs> {
    uint1   regimm <:: opCode[3,1];
    uint1   function75 <:: function7[5,1];
    uint1   addsub <:: regimm & function75;
    uint5   shiftcount <:: regimm ? sourceReg2[0,5] : rs2;
    uint32  operand2 <:: regimm ? sourceReg2 : immediateValue;
    uint1   unsignedcompare <:: __unsigned( sourceReg1 ) < __unsigned( operand2 );
    uint1   signedcompare <:: __signed( sourceReg1 ) < __signed(operand2);

    uint32  AS <:: addsub ? ( sourceReg1 - operand2 ) : ( sourceReg1 + operand2 );
    uint32  SLL <:: sourceReg1 << shiftcount;
    uint32  SRL <:: sourceReg1 >> shiftcount;
    uint32  SRA <:: __signed(sourceReg1) >>> shiftcount;
    uint1   SLTU <:: regimm ? ( ~|rs1 ) ? ( |operand2 ) : unsignedcompare : ( operand2 == 1 ) ? ( ~|sourceReg1 ) : unsignedcompare;

    always {
        switch( function3 ) {
            case 3b000: { result = AS; }
            case 3b001: { result = SLL; }
            case 3b010: { result = signedcompare; }
            case 3b011: { result = SLTU; }
            case 3b100: { result = sourceReg1 ^ operand2; }
            case 3b101: { result = function75 ? SRA : SRL; }
            case 3b110: { result = sourceReg1 | operand2; }
            case 3b111: { result = sourceReg1 & operand2; }
        }
    }
}

// ALU - M EXTENSION
// ALU FOR DIVISION
// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient
algorithm douintdivide(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint32  dividend,
    input   uint32  divisor,
    output  uint32  quotient,
    output  uint32  remainder
) <autorun,reginputs> {
    uint32  temporary <:: { remainder[0,31], dividend[bit,1] };
    uint1   bitresult <:: __unsigned(temporary) >= __unsigned(divisor);
    uint6   bit(63);

    busy := start | ( ~&bit );
    while(1) {
        if( start ) {
            bit = 31; quotient = 0; remainder = 0;
            while( busy ) {
                quotient[bit,1] = bitresult;
                remainder = __unsigned(temporary) - ( bitresult ? __unsigned(divisor) : 0 );
                bit = bit - 1;
            }
        }
    }
}

algorithm aluMD(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint2   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  absRS1,
    input   uint32  absRS2,
    output  uint32  result
) <autorun,reginputs> {
    uint1   quotientremaindersign <:: function3[0,1] ? 0 : sourceReg1[31,1] ^ sourceReg2[31,1];
    uint32  result_quotient = uninitialised;
    uint32  result_remainder = uninitialised;
    uint32  sourceReg1_unsigned <:: function3[0,1] ? sourceReg1 : absRS1;
    uint32  sourceReg2_unsigned <:: function3[0,1] ? sourceReg2 : absRS2;

    douintdivide DODIVIDE(
        dividend <: sourceReg1_unsigned,
        divisor <: sourceReg2_unsigned,
        quotient :> result_quotient,
        remainder :> result_remainder
    );
    DODIVIDE.start := 0;

    while(1) {
        if( start ) {
            busy = 1;
            if( ~|sourceReg2 ) {
                result = function3[1,1] ? sourceReg1 : 32hffffffff;
            } else {
                DODIVIDE.start = 1; while( DODIVIDE.busy ) {}
                result = function3[1,1] ? result_remainder : ( quotientremaindersign ? -result_quotient : result_quotient );
            }
            busy = 0;
        }
    }
}

// ALU FOR MULTIPLICATION
// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
algorithm douintmul(
    input   uint32  factor_1,
    input   uint32  factor_2,
    input   uint1   productsign,
    output  uint64  product64,
) <autorun,reginputs> {
    uint64  product <:: factor_1 * factor_2;
    always {
        product64 = productsign ? -product : product;
    }
}

algorithm aluMM(
    input   uint2   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  absRS1,
    input   uint32  absRS2,
    output  uint32  result
) <autorun,reginputs> {
    uint2   dosigned <:: ~{ function3[0,1], function3[1,1] };
    uint1   dosigned0 <:: ( ~|dosigned );
    uint1   dosigned1 <:: ( dosigned != 1 );
    uint1   productsign <:: dosigned0 ? 0 : ( dosigned1 ? sourceReg1[31,1] : ( sourceReg1[31,1] ^ sourceReg2[31,1] ) );
    uint32  sourceReg1_unsigned <:: dosigned0 ? sourceReg1 : absRS1;
    uint32  sourceReg2_unsigned <:: dosigned1 ? sourceReg2 : absRS2;

    uint64  product = uninitialised;
    douintmul UINTMUL(
        factor_1 <: sourceReg1_unsigned,
        factor_2 <: sourceReg2_unsigned,
        productsign <: productsign
    );

    always {
        // SELECT HIGH OR LOW PART
        result = UINTMUL.product64[ { |function3, 5b0 }, 32 ];
    }
}
