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
            switch( divisor ) {
                case 0: { result = dosign[1,1] ? dividend : 32hffffffff; }
                default: {
                    DODIVIDEstart = 1; while( DODIVIDEbusy ) {}
                    result = dosign[1,1] ? result_remainder : ( quotientremaindersign ? -result_quotient : result_quotient );
                }
            }
            busy = 0;
        }
    }
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
algorithm douintmul(
    input   uint32  factor_1,
    input   uint32  factor_2,
    output  uint64  product
) <autorun> {
    always {
        product = factor_1 * factor_2;
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
    uint32  factor_2_unsigned <:: ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );
    uint64  product64 = uninitialised;
    uint64  product <:: productsign ? -product64 : product64;
    douintmul UINTMUL( factor_1 <: factor_1_unsigned, factor_2 <: factor_2_unsigned, product :> product64 );

    always {
        result = product[ ( dosign == 0 ) ? 0 : 32, 32 ];
    }
}

algorithm aluM(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  result
) <autorun> {
    // M EXTENSION MULTIPLICATION AND DIVISION
    int32   ALUMDresult = uninitialized;
    uint1   ALUMDstart = uninitialized;
    uint1   ALUMDbusy = uninitialized;
    aluMdivideremain ALUMD(
        dosign <: function3,
        dividend <: sourceReg1,
        divisor <: sourceReg2,
        result :> ALUMDresult,
        start <: ALUMDstart,
        busy :> ALUMDbusy
    );
    int32   ALUMMresult = uninitialized;
    aluMmultiply ALUMM(
        dosign <: function3,
        factor_1 <: sourceReg1,
        factor_2 <: sourceReg2,
        result :> ALUMMresult
    );

    ALUMDstart := 0;
    while(1) {
        if( start ) {
            busy = 1;
            if( function3[2,1] ) {
                ALUMDstart = 1; while( ALUMDbusy ) {} result = ALUMDresult;
            } else {
                result = ALUMMresult;
            }
            busy = 0;
        }
    }
}
