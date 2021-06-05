// ALU - BASE - M EXTENSION

// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient
algorithm aluMdivideremain(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   dosign,
    input   uint32  dividend,
    input   uint32  divisor,

    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialized;
    uint1   FSM2 = uninitialized;

    uint32  temporary = uninitialized;
    uint32  quotient = uninitialized;
    uint32  remainder = uninitialized;
    uint32  dividend_copy = uninitialized;
    uint32  divisor_copy = uninitialized;
    uint1   quotientremaindersign = uninitialized;
    uint6   bit = uninitialized;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        dividend_copy = ~dosign[0,1] ? ( dividend[31,1] ? -dividend : dividend ) : dividend;
                        divisor_copy = ~dosign[0,1] ? ( divisor[31,1] ? -divisor : divisor ) : divisor;
                        quotientremaindersign = ~dosign[0,1] ? dividend[31,1] ^ divisor[31,1] : 0;
                        quotient = 0;
                        remainder = 0;
                        bit = 31;
                    }
                    case 1: {
                        switch( divisor ) {
                            case 0: { result = dosign[1,1] ? dividend : 32hffffffff; }
                            default: {
                                while( bit != 63 ) {
                                    temporary = { remainder[0,31], dividend_copy[bit,1] };
                                    FSM2 = __unsigned(temporary) >= __unsigned(divisor_copy);
                                    switch( FSM2 ) {
                                        case 1: { remainder = __unsigned(temporary) - __unsigned(divisor_copy); quotient[bit,1] = 1; }
                                        case 0: { remainder = temporary; }
                                    }
                                   bit = bit - 1;
                                }
                                result = dosign[1,1] ? remainder : ( quotientremaindersign ? -quotient : quotient );
                            }
                        }
                    }
                }
                FSM = { FSM[0,1], 1b0 };
            }
            busy = 0;
        }
    }
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
algorithm aluMmultiply(
    input   uint3   dosign,
    input   uint32  factor_1,
    input   uint32  factor_2,

    output  uint32  result
) <autorun> {
    uint2   dosigned = uninitialized;
    uint1   productsign = uninitialized;
    uint32  factor_1_copy = uninitialized;
    uint32  factor_2_copy = uninitialized;
    uint64  product = uninitialized;

    // Calculation is split into 4 18 x 18 multiplications for DSP
    uint18  A = uninitialized;
    uint18  B = uninitialized;
    uint18  C = uninitialized;
    uint18  D = uninitialized;
    while(1) {
        dosigned = dosign[1,1] ? ( dosign[0,1] ? 0 : 2 ) : 1;
        productsign = ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] ^ factor_2[31,1] ) : factor_1[31,1] );
        factor_1_copy = ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
        factor_2_copy = ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );
        A = { 2b0, factor_1_copy[16,16] };
        B = { 2b0, factor_1_copy[0,16] };
        C = { 2b0, factor_2_copy[16,16] };
        D = { 2b0, factor_2_copy[0,16] };
        product = productsign ? -( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } ) : ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );
        result = ( dosign == 0 ) ? product[0,32] : product[32,32];
    }
}

algorithm aluI(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint7   function7,
    input   uint5   IshiftCount,
    input   uint32  sourceReg1,
    input   uint32  immediateValue,

    input   uint32  LSHIFToutput,
    input   uint32  RSHIFToutput,

    output  uint32   result
) <autorun> {

    busy = 0;

    while(1) {
        if( start) {
            busy = 1;
            switch( function3 ) {
                case 3b000: { result = sourceReg1 + immediateValue; }
                case 3b001: { result = LSHIFToutput; }
                case 3b010: { result = __signed( sourceReg1 ) < __signed(immediateValue); }
                case 3b011: { result = ( immediateValue == 1 ) ? ( sourceReg1 == 0 ) : ( __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ); }
                case 3b100: { result = sourceReg1 ^ immediateValue; }
                case 3b101: { result = RSHIFToutput; }
                case 3b110: { result = sourceReg1 | immediateValue; }
                case 3b111: { result = sourceReg1 & immediateValue; }
            }
            busy = 0;
        }
    }
}

algorithm aluR (
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  sourceReg3,

    input   uint32  LSHIFToutput,
    input   uint32  RSHIFToutput,

    output  uint32  result
) <autorun> {
    // M EXTENSION MULTIPLICATION AND DIVISION
    aluMdivideremain ALUMD(
        dosign <: function3,
        dividend <: sourceReg1,
        divisor <: sourceReg2
    );
    aluMmultiply ALUMM(
        dosign <: function3,
        factor_1 <: sourceReg1,
        factor_2 <: sourceReg2
    );

    // START FLAGS FOR ALU SUB BLOCKS
    ALUMD.start := 0;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            switch( function7 ) {
                // M EXTENSION MULTIPLICATION AND DIVISION
                case 7b0000001: {
                    switch( function3[2,1] ) {
                        case 1b0: { result = ALUMM.result; }
                        case 1b1: { ALUMD.start = 1; while( ALUMD.busy ) {} result = ALUMD.result; }
                    }
                }
                // BASE + REMAINING B EXTENSION
                default: {
                    switch( function3 ) {
                        case 3b000: { result = sourceReg1 + ( function7[5,1] ? -( sourceReg2 ) : sourceReg2 ); }
                        case 3b001: { result = LSHIFToutput; }
                        case 3b010: { result = __signed( sourceReg1 ) < __signed(sourceReg2); }
                        case 3b011: { result = ( rs1 == 0 ) ? ( sourceReg2 != 0 ) : __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ); }
                        case 3b100: { result = sourceReg1 ^ sourceReg2; }
                        case 3b101: { result = RSHIFToutput; }
                        case 3b110: { result = sourceReg1 | sourceReg2; }
                        case 3b111: { result = sourceReg1 & sourceReg2; }
                    }
                }
            }
            busy = 0;
        }
    }
}

// ALU - ALU for immediate-register operations and register-register operations
algorithm alu(
    input   uint1   start,
    output  uint1   busy,

    input   uint7   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  sourceReg3,
    input   uint5   IshiftCount,
    input   uint32  immediateValue,

    output  uint32  result
) <autorun> {
    uint5   shiftcount <: opCode[5,1] ? sourceReg2[0,5] : IshiftCount;

    // SHIFTERS
    uint32  LSHIFToutput = uninitialized;
    uint32  RSHIFToutput = uninitialized;
    BSHIFTleft LEFTSHIFT(
        sourceReg1 <: sourceReg1,
        shiftcount <: shiftcount,
        function7 <: function7,
        result :> LSHIFToutput
    );
    BSHIFTright RIGHTSHIFT(
        sourceReg1 <: sourceReg1,
        shiftcount <: shiftcount,
        function7 <: function7,
        result :> RSHIFToutput
    );

    // BASE REGISTER + IMMEDIATE ALU OPERATIONS + B EXTENSION OPERATIONS
    aluI ALUI(
       function3 <: function3,
        function7 <: function7,
        IshiftCount <: IshiftCount,
        sourceReg1 <: sourceReg1,
        immediateValue <: immediateValue,
        LSHIFToutput <: LSHIFToutput,
        RSHIFToutput <: RSHIFToutput
    );

    // BASE REGISTER & REGISTER ALU OPERATIONS + B EXTENSION OPERATIONS
    aluR ALUR(
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        sourceReg3 <: sourceReg3,

        LSHIFToutput <: LSHIFToutput,
        RSHIFToutput <: RSHIFToutput
    );

    // ALU START FLAGS
    ALUI.start := 0;
    ALUR.start := 0;

    busy = 0;

    while(1) {
        if( start ) {
            // START ALUI or ALUR
            busy = 1;
            ALUI.start = ~opCode[5,1];
            ALUR.start = opCode[5,1];
            while( ALUI.busy || ALUR.busy ) {}
            result = opCode[5,1] ? ALUR.result : ALUI.result;
            busy = 0;
        }
    }
}

// BARREL SHIFTERS
algorithm BSHIFTleft(
    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint7   function7,
    output  uint32  result
) <autorun> {
    while(1) {
        result = sourceReg1 << shiftcount;
    }
}
algorithm BSHIFTright(
    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint7   function7,
    output  uint32  result
) <autorun> {
    while(1) {
        switch( function7[4,2] ) {
            case 2b00: { result = sourceReg1 >> shiftcount; }
            case 2b10: { result = __signed(sourceReg1) >>> shiftcount; }
        }
    }
}
