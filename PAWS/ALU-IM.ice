// ALU - ALU for immediate-register operations and register-register operations
algorithm op000(
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  operand2,
    input   uint1   addsub,
    output  uint32  result
) <autorun> {
    always {
        result = sourceReg1 + ( addsub ? -( sourceReg2 ) : operand2 );
    }
}
algorithm op001(
    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    output  uint32  result
) <autorun> {
    always {
        result = sourceReg1 << shiftcount;
    }
}
algorithm op010(
    input   uint32  sourceReg1,
    input   uint32  operand2,
    output  uint32  result
) <autorun> {
    always {
        result =  __signed( sourceReg1 ) < __signed(operand2);
    }
}
algorithm op011(
    input   uint32  sourceReg1,
    input   uint32  operand2,
    input   uint5   rs1,
    input   uint1   regimm,
    output  uint32  result
) <autorun> {
    always {
        result = regimm ? ( rs1 == 0 ) ? ( operand2 != 0 ) : __unsigned( sourceReg1 ) < __unsigned( operand2 ) :
                    ( operand2 == 1 ) ? ( sourceReg1 == 0 ) : ( __unsigned( sourceReg1 ) < __unsigned( operand2 ) );
    }
}
algorithm op100(
    input   uint32  sourceReg1,
    input   uint32  operand2,
    output  uint32  result
) <autorun> {
    always {
        result = sourceReg1 ^ operand2;
    }
}
algorithm op101(
    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint1   srlsra,
    output  uint32  result
) <autorun> {
    always {
        if( srlsra ) {
            result = __signed(sourceReg1) >>> shiftcount;
        } else {
            result = sourceReg1 >> shiftcount;
        }
    }
}
algorithm op110(
    input   uint32  sourceReg1,
    input   uint32  operand2,
    output  uint32  result
) <autorun> {
    always {
        result = sourceReg1 | operand2;
    }
}
algorithm op111(
    input   uint32  sourceReg1,
    input   uint32  operand2,
    output  uint32  result
) <autorun> {
    always {
        result = sourceReg1 & operand2;
    }
}

algorithm alu(
    input   uint7   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  immediateValue,

    output  uint32  result
) <autorun> {
    uint1   regimm <:: opCode[5,1];
    uint1   function75 <:: function7[5,1];
    uint1   addsub <:: regimm & function75;
    uint5   shiftcount <:: regimm ? sourceReg2[0,5] : rs2;
    uint32  operand2 <:: regimm ? sourceReg2 : immediateValue;

    uint32  result000 = uninitialised;
    uint32  result001 = uninitialised;
    uint32  result010 = uninitialised;
    uint32  result011 = uninitialised;
    uint32  result100 = uninitialised;
    uint32  result101 = uninitialised;
    uint32  result110 = uninitialised;
    uint32  result111 = uninitialised;
    op000 OP000( sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2, operand2 <: operand2, addsub <: addsub, result :> result000 );
    op001 OP001( sourceReg1 <: sourceReg1, shiftcount <: shiftcount, result :> result001 );
    op010 OP010( sourceReg1 <: sourceReg1, operand2 <: operand2, result :> result010 );
    op011 OP011( sourceReg1 <: sourceReg1, operand2 <: operand2, rs1 <: rs1, regimm <: regimm, result :> result011 );
    op100 OP100( sourceReg1 <: sourceReg1, operand2 <: operand2, result :> result100 );
    op101 OP101( sourceReg1 <: sourceReg1, shiftcount <: shiftcount, srlsra <: function75, result :> result101 );
    op110 OP110( sourceReg1 <: sourceReg1, operand2 <: operand2, result :> result110 );
    op111 OP111( sourceReg1 <: sourceReg1, operand2 <: operand2, result :> result111 );

    always {
        switch( function3 ) {
            case 3b000: { result = result000; }
            case 3b001: { result = result001; }
            case 3b010: { result = result010; }
            case 3b011: { result = result011; }
            case 3b100: { result = result100; }
            case 3b101: { result = result101; }
            case 3b110: { result = result110; }
            case 3b111: { result = result111; }
        }
    }
}

// ALU - M EXTENSION
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
            while( bit != 63 ) {
                quotient[bit,1] = bitresult;
                remainder = __unsigned(temporary) - ( bitresult ? __unsigned(divisor) : 0 );
                bit = bit - 1;
            }
        }
    }
}
algorithm aluMdivideremain(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint3   dosign,
    input   uint32  dividend,
    input   uint32  divisor,
    output  uint32  result
) <autorun> {
    uint1   quotientremaindersign <:: ~dosign[0,1] ? dividend[31,1] ^ divisor[31,1] : 0;
    uint32  dividend_unsigned <:: ~dosign[0,1] ? ( dividend[31,1] ? -dividend : dividend ) : dividend;
    uint32  divisor_unsigned <:: ~dosign[0,1] ? ( divisor[31,1] ? -divisor : divisor ) : divisor;
    uint32  result_quotient = uninitialised;
    uint32  result_remainder = uninitialised;
    uint1   DODIVIDEstart = uninitialised;
    uint1   DODIVIDEbusy = uninitialised;
    douintdivide DODIVIDE(
        dividend <: dividend_unsigned,
        divisor <: divisor_unsigned,
        quotient :> result_quotient,
        remainder :> result_remainder,
        start <: DODIVIDEstart,
        busy :> DODIVIDEbusy
    );
    DODIVIDEstart := 0;

    while(1) {
        if( start ) {
            busy = 1;
            if( divisor == 0 ) {
                result = dosign[1,1] ? dividend : 32hffffffff;
            } else {
                DODIVIDEstart = 1; while( DODIVIDEbusy ) {}
                result = dosign[1,1] ? result_remainder : ( quotientremaindersign ? -result_quotient : result_quotient );
            }
            busy = 0;
        }
    }
}
// ALU FOR DIVISION
algorithm aluMD(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  result
) <autorun> {
    // M EXTENSION MULTIPLICATION AND DIVISION
    uint1   ALUMDstart = uninitialized;
    uint1   ALUMDbusy = uninitialized;
    aluMdivideremain ALUMD(
        dosign <: function3,
        dividend <: sourceReg1,
        divisor <: sourceReg2,
        result :> result,
        start <: ALUMDstart,
        busy :> ALUMDbusy
    );
    ALUMDstart := 0;

    while(1) {
        if( start ) {
            busy = 1;
            ALUMDstart = 1; while( ALUMDbusy ) {}
            busy = 0;
        }
    }
}

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
algorithm aluMmultiply(
    input   uint3   dosign,
    input   uint32  factor_1,
    input   uint32  factor_2,
    output  uint32  result
) <autorun> {
    uint2   dosigned <:: dosign[1,1] ? ( dosign[0,1] ? 0 : 2 ) : 1;
    uint1   productsign <:: ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] ^ factor_2[31,1] ) : factor_1[31,1] );
    uint32  factor_1_unsigned <:: ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
    uint32  factor_2_unsigned <:: ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );    uint64  product = uninitialised;
    douintmul UINTMUL( factor_1 <: factor_1_unsigned, factor_2 <: factor_2_unsigned, productsign <: productsign, product64 :> product);

    always {
        result = product[ ( dosign == 0 ) ? 0 : 32, 32 ];
    }
}

// ALU FOR MULTIPLICATION
algorithm aluMM(
    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  result
) <autorun> {
    aluMmultiply ALUMM(
        dosign <: function3,
        factor_1 <: sourceReg1,
        factor_2 <: sourceReg2,
        result :> result
    );
}
