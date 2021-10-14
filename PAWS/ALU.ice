// ALU - ALU for immediate-register operations and register-register operations
algorithm iaddsub(
    input   uint32  sourceReg1,
    input   uint32  operand2,
    input   uint1   addsub,
    output  uint32  result
) <autorun> {
    always {
        result = addsub ? ( sourceReg1 - operand2 ) : ( sourceReg1 + operand2 );
    }
}
algorithm sll(
    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    output  uint32  result
) <autorun> {
    always {
        result = sourceReg1 << shiftcount;
    }
}
algorithm srl(
    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    output  uint32  result
) <autorun> {
    always {
        result = sourceReg1 >> shiftcount;
    }
}
algorithm sra(
    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    output  uint32  result
) <autorun> {
    always {
        result = __signed(sourceReg1) >>> shiftcount;
    }
}

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
) <autorun> {
    uint1   regimm <:: opCode[3,1];
    uint1   function75 <:: function7[5,1];
    uint1   addsub <:: regimm & function75;
    uint5   shiftcount <:: regimm ? sourceReg2[0,5] : rs2;
    uint32  operand2 <:: regimm ? sourceReg2 : immediateValue;
    uint1   unsignedcompare <:: __unsigned( sourceReg1 ) < __unsigned( operand2 );
    uint1   signedcompare <:: __signed( sourceReg1 ) < __signed(operand2);

    uint32  AS = uninitialised; iaddsub ALUaddsub( sourceReg1 <: sourceReg1, operand2 <: operand2, addsub <: addsub, result :> AS );
    uint32  SLL = uninitialised; sll ALUsll( sourceReg1 <: sourceReg1, shiftcount <: shiftcount, result :> SLL );
    uint32  SRL = uninitialised; srl ALUsrl( sourceReg1 <: sourceReg1, shiftcount <: shiftcount, result :> SRL );
    uint32  SRA = uninitialised; sra ALUsra( sourceReg1 <: sourceReg1, shiftcount <: shiftcount, result :> SRA );
    uint1   SLTU <:: regimm ? ( rs1 == 0 ) ? ( operand2 != 0 ) : unsignedcompare : ( operand2 == 1 ) ? ( sourceReg1 == 0 ) : unsignedcompare;

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
algorithm prepsign(
    input   uint32  number,
    input   uint1   dosign,
    output  uint32  number_unsigned
) <autorun> {
    always {
        number_unsigned = dosign ? number : ( number[31,1] ? -number : number );
    }
}

// ALU FOR DIVISION
// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient
algorithm douintdivide(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint32  dividend,
    input   uint32  divisor,
    output  uint32  quotient,
    output  uint32  remainder
) <autorun> {
    uint32  temporary <:: { remainder[0,31], dividend[bit,1] };
    uint1   bitresult <:: __unsigned(temporary) >= __unsigned(divisor);
    uint6   bit(63);

    busy := start | ( bit != 63 );
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
    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  result
) <autorun> {
    uint1   quotientremaindersign <:: function3[0,1] ? 0 : sourceReg1[31,1] ^ sourceReg2[31,1];
    uint32  result_quotient = uninitialised;
    uint32  result_remainder = uninitialised;
    uint32  sourceReg1_unsigned = uninitialised;
    prepsign PREPTOP(
        number <: sourceReg1,
        dosign <: function3,
        number_unsigned :> sourceReg1_unsigned
    );
    uint32  sourceReg2_unsigned = uninitialised;
    prepsign PREPBOTTOM(
        number <: sourceReg2,
        dosign <: function3,
        number_unsigned :> sourceReg2_unsigned
    );

    uint1   DODIVIDEstart = uninitialised;
    uint1   DODIVIDEbusy = uninitialised;
    douintdivide DODIVIDE(
        dividend <: sourceReg1_unsigned,
        divisor <: sourceReg2_unsigned,
        quotient :> result_quotient,
        remainder :> result_remainder,
        start <: DODIVIDEstart,
        busy :> DODIVIDEbusy
    );
    DODIVIDEstart := 0;

    while(1) {
        if( start ) {
            busy = 1;
            if( sourceReg2 == 0 ) {
                result = function3[1,1] ? sourceReg1 : 32hffffffff;
            } else {
                DODIVIDEstart = 1; while( DODIVIDEbusy ) {}
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
) <autorun> {
    uint64  product <:: factor_1 * factor_2;
    always {
        product64 = productsign ? -product : product;
    }
}

algorithm aluMM(
    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  result
) <autorun> {
    uint2   dosigned <:: { ~function3[0,1], ~function3[1,1] };
    uint1   dosigned0 <:: ( dosigned == 0 );
    uint1   dosigned1 <:: ( dosigned != 1 );
    uint1   productsign <:: dosigned0 ? 0 : ( dosigned1 ? sourceReg1[31,1] : ( sourceReg1[31,1] ^ sourceReg2[31,1] ) );
    uint32  sourceReg1_unsigned = uninitialised;
    prepsign PREPLEFT(
        number <: sourceReg1,
        dosign <: dosigned0,
        number_unsigned :> sourceReg1_unsigned
    );
    uint32  sourceReg2_unsigned = uninitialised;
    prepsign PREPRIGHT(
        number <: sourceReg2,
        dosign <: dosigned1,
        number_unsigned :> sourceReg2_unsigned
    );
    uint64  product = uninitialised;
    douintmul UINTMUL(
        factor_1 <: sourceReg1_unsigned,
        factor_2 <: sourceReg2_unsigned,
        productsign <: productsign,
        product64 :> product
    );

    always {
        result = product[ ( function3 == 0 ) ? 0 : 32, 32 ];
    }
}
