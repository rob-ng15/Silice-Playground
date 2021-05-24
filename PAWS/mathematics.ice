// ALU - BASE - M EXTENSION - B EXTENSION

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
                                    FSM2 = __unsigned(temporary) >= __unsigned(divisor_copy) ? 1 : 0;
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
                FSM = FSM << 1;
            }
            busy = 0;
        }
    }
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
algorithm aluMmultiply(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   dosign,
    input   uint32  factor_1,
    input   uint32  factor_2,

    output  uint32  result
) <autorun> {
    uint4   FSM = uninitialized;

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

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        dosigned = dosign[1,1] ? ( dosign[0,1] ? 0 : 2 ) : 1;
                        productsign = ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] ^ factor_2[31,1] ) : factor_1[31,1] );
                        factor_1_copy = ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
                        factor_2_copy = ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );
                    }
                    case 1: {
                        A = { 2b0, factor_1_copy[16,16] };
                        B = { 2b0, factor_1_copy[0,16] };
                        C = { 2b0, factor_2_copy[16,16] };
                        D = { 2b0, factor_2_copy[0,16] };
                    }
                    case 2: { product = productsign ? -( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } ) : ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } ); }
                    case 3: { result = ( dosign == 0 ) ? product[0,32] : product[32,32]; }
                }
                FSM = FSM << 1;
            }
            busy = 0;
        }
    }
}

// BASE IMMEDIATE WITH B EXTENSIONS
algorithm aluIb001(
    input   uint1   start,
    output  uint1   busy,

    input   uint7   function7,
    input   uint5   IshiftCount,
    input   uint32  sourceReg1,

    input   uint32  LSHIFToutput,
    input   uint32  SBSCIoutput,

    input   uint32  SHFLUNSHFLoutput,
    input   uint1   SHFLUNSHFLbusy,

    output  uint32  result
) <autorun> {
    // COUNT LEADINGS 0s, TRAILING 0s, POPULATION
    clz CLZ(
        sourceReg1 <: sourceReg1
    );
    ctz CTZ(
        sourceReg1 <: sourceReg1
    );
    cpop CPOP(
        sourceReg1 <: sourceReg1
    );

    // CRC32 and CRC32C for byte, half-word and word
    crc32 CRC32(
       sourceReg1 <: sourceReg1,
       IshiftCount <: IshiftCount
    );

    // START FLAGS FOR ALU SUB BLOCKS
    CLZ.start := 0;
    CTZ.start := 0;
    CPOP.start := 0;
    CRC32.start := 0;
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            switch( function7 ) {
                case 7b0110000: {
                    switch( IshiftCount ) {
                        case 5b00000: {
                            // CLZ
                            CLZ.start = 1;
                            while( CLZ.busy ) {}
                            result = CLZ.result;
                        }
                        case 5b00001: {
                            // CTZ
                            CTZ.start = 1;
                            while( CTZ.busy ) {}
                            result = CTZ.result;
                        }
                        case 5b00010: {
                            // CPOP
                            CPOP.start = 1;
                            while( CPOP.busy ) {}
                            result = CPOP.result;
                        }
                        case 5b00100: { result = { {24{sourceReg1[7,1]}}, sourceReg1[0, 8] }; }     // SEXT.B
                        case 5b00101: { result = { {16{sourceReg1[15,1]}}, sourceReg1[0, 16] }; }   // SEXT.H
                        default: {
                            // CRC32 / CRC32C
                            CRC32.start = 1;
                            while( CRC32.busy ) {}
                            result = CRC32.result;
                        }
                    }
                }
                case 7b0000100: {
                    while( SHFLUNSHFLbusy ) {}
                    result = SHFLUNSHFLoutput;
                }
                default: {
                    switch( function7[2,1] ) {
                        case 0: { result = LSHIFToutput; }
                        case 1: { result = SBSCIoutput; }
                    }
                }
            }
            busy = 0;
        }
    }
}
algorithm aluIb101(
    input   uint1   start,
    output  uint1   busy,

    input   uint7   function7,
    input   uint3   function3,
    input   uint5   IshiftCount,
    input   uint32  sourceReg1,

    input   uint32  RSHIFToutput,

    input   uint32  FUNNELoutput,
    input   uint1   FUNNELbusy,
    input   uint32  SHFLUNSHFLoutput,
    input   uint1   SHFLUNSHFLbusy,
    input   uint32  GREVGORCoutput,
    input   uint1   GREVGORCbusy,
    output  uint32  result
) <autorun> {
    // START FLAGS FOR ALU SUB BLOCKS
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            if( ( function7 == 7b0010100 ) || ( function7 == 7b0110100 ) ) {
                while( GREVGORCbusy ) {}
                result = GREVGORCoutput;
            } else {
                switch( function7 ) {
                    case 7b0000100: {
                        while( SHFLUNSHFLbusy ) {}
                        result = SHFLUNSHFLoutput;
                    }
                    case 7b0100100: { result = ( sourceReg1[ IshiftCount, 1 ] == 1 ) ? 1 : 0; }
                    default: {
                        if( function7[1,1] ) {
                            while( FUNNELbusy ) {}
                            result = FUNNELoutput;
                        } else {
                            result = RSHIFToutput;
                        }
                    }
                }
            }
            busy = 0;
        }
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
    input   uint32  SBSCIoutput,

    input   uint32  FUNNELoutput,
    input   uint1   FUNNELbusy,
    input   uint32  SHFLUNSHFLoutput,
    input   uint1   SHFLUNSHFLbusy,
    input   uint32  GREVGORCoutput,
    input   uint1   GREVGORCbusy,

    output  uint32   result
) <autorun> {
    // FUNCTION3 == 001 block
    aluIb001 ALUIb001(
        function7 <: function7,
        IshiftCount <: IshiftCount,
        sourceReg1 <: sourceReg1,
        LSHIFToutput <: LSHIFToutput,
        SBSCIoutput <: SBSCIoutput,
        SHFLUNSHFLoutput <: SHFLUNSHFLoutput,
        SHFLUNSHFLbusy <: SHFLUNSHFLbusy
    );
    aluIb101 ALUIb101(
        function7 <: function7,
        function3 <: function3,
        IshiftCount <: IshiftCount,
        sourceReg1 <: sourceReg1,
        RSHIFToutput <: RSHIFToutput,
        FUNNELoutput <: FUNNELoutput,
        FUNNELbusy <: FUNNELbusy,
        SHFLUNSHFLoutput <: SHFLUNSHFLoutput,
        SHFLUNSHFLbusy <: SHFLUNSHFLbusy,
        GREVGORCoutput <: GREVGORCoutput,
        GREVGORCbusy <: GREVGORCbusy,
    );

    // START FLAGS FOR ALU SUB BLOCKS
    ALUIb001.start := 0;
    ALUIb101.start := 0;
    busy = 0;

    while(1) {
        if( start) {
            busy = 1;
            switch( function3 ) {
                case 3b000: { result = sourceReg1 + immediateValue; }
                case 3b001: {
                    ALUIb001.start = 1;
                    while( ALUIb001.busy ) {}
                    result = ALUIb001.result;
                }
                case 3b010: { result = __signed( sourceReg1 ) < __signed(immediateValue) ? 32b1 : 32b0; }
                case 3b011: { result = ( immediateValue == 1 ) ? ( ( sourceReg1 == 0 ) ? 32b1 : 32b0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ) ? 32b1 : 32b0 ); }
                case 3b100: { result = sourceReg1 ^ immediateValue; }
                case 3b101: {
                    ALUIb101.start = 1;
                    while( ALUIb101.busy ) {}
                    result = ALUIb101.result;
                }
                case 3b110: { result = sourceReg1 | immediateValue; }
                case 3b111: { result = sourceReg1 & immediateValue; }
            }
            busy = 0;
        }
    }
}

// BASE REGISTER + B extensions
// B EXTENSION GORC XPERM + SBSET
algorithm aluR7b0010100 (
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  SBSCIoutput,

    input   uint32  GREVGORCoutput,
    input   uint1   GREVGORCbusy,

    output  uint32  result
) <autorun> {
    // XPERM
    xperm XPERM(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2
    );

    // START FLAGS FOR ALU SUB BLOCKS
    XPERM.start := 0;
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            switch( function3 ) {
                case 3b001: { result = SBSCIoutput; }
                case 3b101: {
                    while( GREVGORCbusy ) {}
                    result = GREVGORCoutput;
                }
                default: {
                    XPERM.start = 1;
                    while( XPERM.busy ) {}
                    result = XPERM.result;
                }
            }
            busy = 0;
        }
    }
}
// B EXTENSION CLMUL + MIN[U] MAX[U]
algorithm aluR7b0000101 (
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,

    output  uint32  result
) <autorun> {
    // CLMUL
    clmul CLMUL(
        function3 <: function3,

        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2
    );

    // START FLAGS FOR ALU SUB BLOCKS
    CLMUL.start := 0;
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            switch( function3 ) {
                // 0.92 ENCODINGS
                //case 3b100: { ( result ) = min( sourceReg1, sourceReg2 ); }
                //case 3b101: { ( result ) = max( sourceReg1, sourceReg2 ); }
                //case 3b110: { ( result ) = minu( sourceReg1, sourceReg2 ); }
                //case 3b111: { ( result ) = maxu( sourceReg1, sourceReg2 ); }
                // 0.93+ ENCODINGS
                case 3b100: { ( result ) = min( sourceReg1, sourceReg2 ); }
                case 3b101: { ( result ) = minu( sourceReg1, sourceReg2 ); }
                case 3b110: { ( result ) = max( sourceReg1, sourceReg2 ); }
                case 3b111: { ( result ) = maxu( sourceReg1, sourceReg2 ); }
                default: {
                    CLMUL.start = 1;
                    while( CLMUL.busy ) {}
                    result = CLMUL.result;
                }
            }
            busy = 0;
        }
    }
}
// B EXTENSION SHFL UNSHFL BEXT + PACK PACKH
algorithm aluR7b0000100 (
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,

    input   uint32  SHFLUNSHFLoutput,
    input   uint1   SHFLUNSHFLbusy,
    input   uint32  BEXTBDEPoutput,
    input   uint1   BEXTBDEPbusy,

    output  uint32  result
) <autorun> {
    // START FLAGS FOR ALU SUB BLOCKS
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            switch( function3 ) {
                case 3b110: {
                    while( BEXTBDEPbusy ) {}
                    result = BEXTBDEPoutput;
                }
                case 3b100: { result = { sourceReg2[0,16], sourceReg1[0,16] }; }
                case 3b111: { result = { 16b0, sourceReg2[0,8], sourceReg1[0,8] }; }
                default: {
                    while( SHFLUNSHFLbusy ) {}
                    result = SHFLUNSHFLoutput;
                }
            }
            busy = 0;
        }
    }
}
// B EXTENSION GREV + SBINV
algorithm aluR7b0110100 (
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  SBSCIoutput,

    input   uint32  GREVGORCoutput,
    input   uint1   GREVGORCbusy,

    output  uint32  result
) <autorun> {
    // START FLAGS FOR ALU SUB BLOCKS
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            switch( function3 ) {
                case 3b001: { result = SBSCIoutput; }
                default: {
                    while( GREVGORCbusy ) {}
                    result = GREVGORCoutput;
                }
            }
            busy = 0;
        }
    }
}
// B EXTENSION BDEP BFP + PACKU SBCLR SBEXT
algorithm aluR7b0100100 (
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  SBSCIoutput,
    input   uint32  BEXTBDEPoutput,
    input   uint1   BEXTBDEPbusy,

    output  uint32  result
) <autorun> {
    uint5   RshiftCount := sourceReg2[0,5];

    // BFP
    bfp BFP(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2
    );

    // START FLAGS FOR ALU SUB BLOCKS
    BFP.start := 0;
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            switch( function3 ) {
                case 3b001: { result = SBSCIoutput; }
                case 3b100: { result = { sourceReg2[16,16], sourceReg1[16,16] }; }
                case 3b101: { result = ( sourceReg1[ RshiftCount, 1 ] == 1 ) ? 1 : 0; }
                case 3b110: {
                    while( BEXTBDEPbusy ) {}
                    result = BEXTBDEPoutput;
                }
                case 3b111: {
                    BFP.start = 1;
                    while( BFP.busy ) {}
                    result = BFP.result;
                }
            }
            busy = 0;
        }
    }
}
// BASE ADD SUB SLL SLT SLTU XOR SRL SRA OR AND + B EXTENSION ROL SLO SH1/2/3ADD XNOR ROR SRO ORN ANDN + CMOV CMIX + (not yet implemented FSL FSR space)
algorithm aluR000(
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint7   function7,
    output  int32   result
) <autorun> {
    result := sourceReg1 + ( function7[5,1] ? -( sourceReg2 ) : sourceReg2 );
}
algorithm aluR001(
    output  uint1   busy,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   int32   sourceReg3,
    input   uint1   FUNNELbusy,
    input   int32   FUNNELoutput,
    input   int32   LSHIFToutput,
    input   uint2   function2,
    output  int32   result
) <autorun> {
    busy = 0;
    while(1) {
        switch( function2 ) {
            case 2b11: {
                // CMIX
                result = ( sourceReg1 & sourceReg2 ) | ( sourceReg3 & ~sourceReg2 );
            }
            case 2b10: {
                // FSL
                busy = 1;
                while( FUNNELbusy ) {}
                result = FUNNELoutput;
                busy = 0;
            }
            default: {
                // ROL SLL SLO
                result = LSHIFToutput;
            }
        }
    }
}
algorithm aluR010(
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint7   function7,
    output  int32   result
) <autorun> {
    while(1) {
        switch( function7 ) {
            case 7b0000000: { result = __signed( sourceReg1 ) < __signed(sourceReg2) ? 32b1 : 32b0; }
            case 7b0010000: { result = ( sourceReg1 << 1 ) + sourceReg2; }
        }
    }
}
algorithm aluR011(
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint5   rs1,
    output  int32   result
) <autorun> {
    while(1) {
        result = ( rs1 == 0 ) ? ( ( sourceReg2 != 0 ) ? 32b1 : 32b0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ) ? 32b1 : 32b0 );
    }
}
algorithm aluR100(
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint7   function7,
    output  int32   result
) <autorun> {
    while(1) {
        switch( function7 ) {
            case 7b0010000: { result = ( sourceReg1 <<2 ) + sourceReg2; }
            default: { result = sourceReg1 ^ ( ( function7[5,1] == 1 ) ? ~sourceReg2 : sourceReg2 ); }
        }
    }
}
algorithm aluR101(
    output  uint1   busy,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   int32   sourceReg3,
    input   uint1   FUNNELbusy,
    input   int32   FUNNELoutput,
    input   int32   RSHIFToutput,
    input   uint2   function2,
    output  int32   result
) <autorun> {
    busy = 0;
    while(1) {
        switch( function2 ) {
            case 2b11: {
                // CMOV
                result = ( sourceReg2 != 0 ) ? sourceReg1 : sourceReg3;
            }
            case 2b10: {
                // FSR
                busy = 1;
                while( FUNNELbusy ) {}
                result = FUNNELoutput;
                busy = 0;
            }
            default: {
                // ROR SRL SRA SRO
                result = RSHIFToutput;
            }
        }
    }
}
algorithm aluR110(
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint7   function7,
    output  int32   result
) <autorun> {
    while(1) {
        switch( function7 ) {
            case 7b0010000: { result = ( sourceReg1 << 3 ) + sourceReg2; }
            default: { result = sourceReg1 | ( ( function7[5,1] == 1 ) ? ~sourceReg2 : sourceReg2 ); }
        }
    }
}
algorithm aluR111(
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint7   function7,
    output  int32   result
) <autorun> {
    result := sourceReg1 & ( ( function7[5,1] == 1 ) ? ~sourceReg2 : sourceReg2 );
}

algorithm aluR (
    input   uint1   start,
    output  uint1   busy,

    input   uint2   function2,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  sourceReg3,

    input   uint32  LSHIFToutput,
    input   uint32  RSHIFToutput,
    input   uint32  SBSCIoutput,

    input   uint32  FUNNELoutput,
    input   uint1   FUNNELbusy,
    input   uint32  SHFLUNSHFLoutput,
    input   uint1   SHFLUNSHFLbusy,
    input   uint32  GREVGORCoutput,
    input   uint1   GREVGORCbusy,

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

    uint5   RshiftCount := sourceReg2[0,5];

    // BEXT BDEP UNIT
    uint32  BEXTBDEPoutput = uninitialized;
    uint1   BEXTBDEPbusy = uninitialized;
    bextbdep BEXTBDEP(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        function7 <: function7,

        result :> BEXTBDEPoutput,
        busy :> BEXTBDEPbusy
    );

    // B EXTENSION GORC XPERM + SBET ( sbset is single cycle but shares same function7 coding as GORC XPERM )
    aluR7b0010100 ALUR7b0010100(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        SBSCIoutput <: SBSCIoutput,
        GREVGORCoutput <: GREVGORCoutput,
        GREVGORCbusy <: GREVGORCbusy
    );
    // B EXTENSION CLMUL + MIN[U] MAX[U] ( min and max are single cycle but share same function7 coding as CLMUL operations )
    aluR7b0000101 ALUR7b0000101(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2
    );
    // B EXTENSION SHFL UNSHFL BEXT + PACK PACKH ( pack and packh are single cycle but share same function7 coding as SHFL UNSHFL )
    aluR7b0000100 ALUR7b0000100(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        SHFLUNSHFLoutput <: SHFLUNSHFLoutput,
        SHFLUNSHFLbusy <: SHFLUNSHFLbusy,
        BEXTBDEPoutput <: BEXTBDEPoutput,
        BEXTBDEPbusy <: BEXTBDEPbusy
    );
    // B EXTENSION GREV + SBINV ( sbinv is single cycle but shares same function7 coding as GREV )
    aluR7b0110100 ALUR7b0110100(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        SBSCIoutput <: SBSCIoutput,
        GREVGORCoutput <: GREVGORCoutput,
        GREVGORCbusy <: GREVGORCbusy
    );
    // B EXTENSION BDEP BFP + PACKU SBCLR SBEXT ( packu, sbclr and sbext are single cycle share share same function7 coding as BDEP BFP )
    aluR7b0100100 ALUR7b0100100(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        SBSCIoutput <: SBSCIoutput,
        BEXTBDEPoutput <: BEXTBDEPoutput,
        BEXTBDEPbusy <: BEXTBDEPbusy
    );

    // BASE ADD/SUB
    aluR000 ALUR000(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        function7 <: function7
    );
    aluR001 ALUR001(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        sourceReg3 <: sourceReg3,
        FUNNELbusy <: FUNNELbusy,
        FUNNELoutput <: FUNNELoutput,
        LSHIFToutput <: LSHIFToutput,
        function2 <: function2
    );
    aluR010 ALUR010(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        function7 <: function7
    );
    aluR011 ALUR011(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        rs1 <: rs1
    );
    aluR100 ALUR100(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        function7 <: function7
    );
    aluR101 ALUR101(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        sourceReg3 <: sourceReg3,
        FUNNELbusy <: FUNNELbusy,
        FUNNELoutput <: FUNNELoutput,
        RSHIFToutput <: RSHIFToutput,
        function2 <: function2
    );
    aluR110 ALUR110(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        function7 <: function7
    );
    aluR111 ALUR111(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        function7 <: function7
    );

    // START FLAGS FOR ALU SUB BLOCKS
    ALUMD.start := 0;
    ALUMM.start := 0;
    ALUR7b0010100.start := 0;
    ALUR7b0000101.start := 0;
    ALUR7b0000100.start := 0;
    ALUR7b0110100.start := 0;
    ALUR7b0100100.start := 0;
    BEXTBDEP.start := 0;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            switch( function7 ) {
                // M EXTENSION MULTIPLICATION AND DIVISION
                case 7b0000001: {
                    switch( function3[2,1] ) {
                        case 1b0: {
                            ALUMM.start = 1;
                            while( ALUMM.busy ) {}
                            result = ALUMM.result;
                        }
                        case 1b1: {
                            ALUMD.start = 1;
                            while( ALUMD.busy ) {}
                            result = ALUMD.result;
                        }
                    }
                }
                // B EXTENSION BLOCKS
                case 7b0010100: {
                    ALUR7b0010100.start = 1;
                    while( ALUR7b0010100.busy ) {}
                    result = ALUR7b0010100.result;
                }
                case 7b0000101: {
                    ALUR7b0000101.start = 1;
                    while( ALUR7b0000101.busy ) {}
                    result = ALUR7b0000101.result;
                }
                case 7b0000100: {
                    BEXTBDEP.start = ( function3 == 3b110 ) ? 1 : 0;
                    ALUR7b0000100.start = 1;
                    while( ALUR7b0000100.busy ) {}
                    result = ALUR7b0000100.result;
                }
                case 7b0110100: {
                    ALUR7b0110100.start = 1;
                    while( ALUR7b0110100.busy ) {}
                    result = ALUR7b0110100.result;
                }
                case 7b0100100: {
                    BEXTBDEP.start = ( function3 == 3b110 ) ? 1 : 0;
                    ALUR7b0100100.start = 1;
                    while( ALUR7b0100100.busy ) {}
                    result = ALUR7b0100100.result;
                }
                // BASE + REMAINING B EXTENSION
                default: {
                    switch( function3 ) {
                        case 3b000: { result = ALUR000.result; }
                        case 3b001: {
                            while( ALUR001.busy ) {}
                            result = ALUR001.result;
                        }
                        case 3b010: { result = ALUR010.result; }
                        case 3b011: { result = ALUR011.result; }
                        case 3b100: { result = ALUR100.result; }
                        case 3b101: {
                            while( ALUR101.busy ) {}
                            result = ALUR101.result;
                        }
                        case 3b110: { result = ALUR110.result; }
                        case 3b111: { result = ALUR111.result; }
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
    input   uint2   function2,
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
    uint5   shiftcount := opCode[5,1] ? sourceReg2[0,5] : IshiftCount;
    uint6   Fshiftcount := opCode[5,1] ? sourceReg2[0,6] : { function7[0,1], IshiftCount };

    // SHIFTERS
    uint32  LSHIFToutput = uninitialized;
    uint32  RSHIFToutput = uninitialized;
    uint32  SBSCIoutput = uninitialized;
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
    singlebitops SBSCI(
        sourceReg1 <: sourceReg1,
        function7 <: function7,
        shiftcount <: shiftcount,
        result :> SBSCIoutput
    );
    uint32  FUNNELoutput = uninitialized;
    uint1   FUNNELbusy = uninitialized;
    funnelshift FUNNEL(
        sourceReg1 <: sourceReg1,
        sourceReg3 <: sourceReg3,
        shiftcount <: Fshiftcount,
        function3 <: function3,
        busy :> FUNNELbusy,
        result :> FUNNELoutput
    );

    // SHARED MULTICYCLE BIT MANIPULATION OPERATIONS
    uint32  SHFLUNSHFLoutput = uninitialized;
    uint1   SHFLUNSHFLbusy = uninitialized;
    shflunshfl SHFLUNSHFL(
        sourceReg1 <: sourceReg1,
        shiftcount <: shiftcount,
        function3 <: function3,
        busy :> SHFLUNSHFLbusy,
        result :> SHFLUNSHFLoutput
    );
    uint32  GREVGORCoutput = uninitialized;
    uint1   GREVGORCbusy = uninitialized;
    grevgorc GREVGORC(
        sourceReg1 <: sourceReg1,
        shiftcount <: shiftcount,
        function7 <: function7,
        busy :> GREVGORCbusy,
        result :> GREVGORCoutput
    );

    // BASE REGISTER + IMMEDIATE ALU OPERATIONS + B EXTENSION OPERATIONS
    aluI ALUI(
       function3 <: function3,
        function7 <: function7,
        IshiftCount <: IshiftCount,
        sourceReg1 <: sourceReg1,
        immediateValue <: immediateValue,

        LSHIFToutput <: LSHIFToutput,
        RSHIFToutput <: RSHIFToutput,
        SBSCIoutput <: SBSCIoutput,

        FUNNELoutput <: FUNNELoutput,
        FUNNELbusy <: FUNNELbusy,
        SHFLUNSHFLoutput <: SHFLUNSHFLoutput,
        SHFLUNSHFLbusy <: SHFLUNSHFLbusy,
        GREVGORCoutput <: GREVGORCoutput,
        GREVGORCbusy <: GREVGORCbusy
    );

    // BASE REGISTER & REGISTER ALU OPERATIONS + B EXTENSION OPERATIONS
    aluR ALUR(
        function2 <: function2,
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        sourceReg3 <: sourceReg3,

        LSHIFToutput <: LSHIFToutput,
        RSHIFToutput <: RSHIFToutput,
        SBSCIoutput <: SBSCIoutput,

        FUNNELoutput <: FUNNELoutput,
        FUNNELbusy <: FUNNELbusy,
        SHFLUNSHFLoutput <: SHFLUNSHFLoutput,
        SHFLUNSHFLbusy <: SHFLUNSHFLbusy,
        GREVGORCoutput <: GREVGORCoutput,
        GREVGORCbusy <: GREVGORCbusy
    );

    // ALU START FLAGS
    ALUI.start := 0;
    ALUR.start := 0;
    FUNNEL.start := 0;
    SHFLUNSHFL.start := 0;
    GREVGORC.start := 0;

    busy = 0;

    while(1) {
        if( start ) {
            // START SHARED MULTICYCLE BLOCKS - SHFL UNSHFL GORC GREV FUNNEL ( need to correctly specify start of funnel shifts )
            FUNNEL.start = ( ( function3 == 3b001 ) || ( function3 == 3b101 ) ) && ( function2 == 2b10 ) ? 1 : 0;
            SHFLUNSHFL.start = ( ( ( function3 == 3b001 ) || ( function3 == 3b101 ) ) && ( function7 == 7b0000100 ) ) ? 1 : 0;
            GREVGORC.start = ( ( function3 == 3b101 ) && ( ( function7 == 7b0110100 ) || ( function7 == 7b0010100 ) ) ) ? 1 : 0;

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

// RISC-V MANDATORY CSR REGISTERS
algorithm CSRblock(
    input   uint32  instruction,
    input   uint1   incCSRinstret,
    input   uint1   SMT,
    output  uint32  result
) <autorun> {
    // RDCYCLE[H] and RDTIME[H] are equivalent on PAWSCPU
    uint64  CSRtimer = 0;
    uint64  CSRcycletime = 0;
    uint64  CSRcycletimeSMT = 0;
    uint64  CSRinstret = 0;
    uint64  CSRinstretSMT = 0;

    CSRtimer := CSRtimer + 1;
    CSRcycletime := CSRcycletime + ( SMT ? 0 : 1);
    CSRinstret := CSRinstret + ( ( incCSRinstret & (~SMT) ) ? 1 : 0 );
    CSRcycletimeSMT := CSRcycletimeSMT + ( SMT ? 1 : 0);
    CSRinstretSMT := CSRinstretSMT + ( ( incCSRinstret & SMT ) ? 1 : 0);

    while(1) {
        switch( CSR(instruction).csr ) {
            case 12hc00: { result = SMT ? CSRcycletimeSMT[0,32] : CSRcycletime[0,32]; }
            case 12hc80: { result = SMT ? CSRcycletimeSMT[32,32] :  CSRcycletime[32,32]; }
            case 12hc01: { result = CSRtimer[0,32]; }
            case 12hc81: { result = CSRtimer[32,32]; }
            case 12hc02: { result = SMT ? CSRinstretSMT[0,32] : CSRinstret[0,32]; }
            case 12hc82: { result = SMT ? CSRinstretSMT[32,32] : CSRinstret[32,32]; }
            case 12hf14: { result = SMT; }
            default: { result = 0; }
        }
    }
}

// ATOMIC A EXTENSION ALU
algorithm aluA (
    input   uint7   function7,
    input   uint32  memoryinput,
    input   uint32  sourceReg2,

    output  uint32  result
) <autorun> {
    while(1) {
        switch( function7[2,5] ) {
            case 5b00000: { result = memoryinput + sourceReg2; }            // AMOADD
            case 5b00001: { result = sourceReg2; }                          // AMOSWAP
            case 5b00100: { result = memoryinput ^ sourceReg2; }            // AMOXOR
            case 5b01000: { result = memoryinput | sourceReg2; }            // AMOOR
            case 5b01100: { result = memoryinput & sourceReg2; }            // AMOAND
            case 5b10000: { ( result ) = min( memoryinput, sourceReg2); }   // AMOMIN
            case 5b10100: { ( result ) = max( memoryinput, sourceReg2); }   // AMOMAX
            case 5b11000: { ( result ) = minu( memoryinput, sourceReg2); }  // AMOMINU
            case 5b11100: { ( result ) = maxu( memoryinput, sourceReg2); }  // AMOMAXU
        }
    }
}

// BIT MANIPULATION CIRCUITS
// BARREL SHIFTERS / ROTATORS
algorithm BSHIFTleft(
    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint7   function7,
    output  uint32  result
) <autorun> {
    while(1) {
        switch( function7[4,2] ) {
            case 2b00: { result = sourceReg1 << shiftcount; }
            case 2b01: { result = ~( ~sourceReg1 << shiftcount ); }
            case 2b11: { result = ( sourceReg1 << shiftcount ) | ( sourceReg1 >> ( 32 - shiftcount ) ); }
        }
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
            case 2b01: { result = ~( ~sourceReg1 >> shiftcount ); }
            case 2b10: { result = __signed(sourceReg1) >>> shiftcount; }
            case 2b11: { result = ( sourceReg1 >> shiftcount ) | ( sourceReg1 << ( 32 - shiftcount ) ); }
        }
    }
}

// SINGLE BIT OPERATIONS SET CLEAR INVERT
algorithm singlebitops(
    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint7   function7,
    output  uint32  result
) <autorun> {
    while(1) {
        switch( function7[4,2] ) {
            case 2b01: { result = sourceReg1 | ( 1 << shiftcount ); }
            case 2b10: { result = sourceReg1 & ~( 1 << shiftcount ); }
            case 2b11: { result = sourceReg1 ^ ( 1 << shiftcount ); }
        }
    }
}
// FUNNEL SHIFT LEFT AND RIGHT
algorithm funnelshift(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  sourceReg1,
    input   uint32  sourceReg3,
    input   uint6   shiftcount,
    input   uint7   function3,
    output  uint32  result
) <autorun> {
    uint32  A <: ( shiftcount >= 32 ) ? sourceReg3 : sourceReg1;
    uint32  B <: ( shiftcount >= 32 ) ? sourceReg1 : sourceReg3;
    uint32  fshiftcount <: ( shiftcount >= 32 ) ? shiftcount - 32 : shiftcount;

    while(1) {
        if( start ) {
            busy = 1;
            switch( function3 ) {
                case 3b001: { result = ( fshiftcount != 0 ) ? ( ( A << fshiftcount ) | ( B >> ( 32 - fshiftcount ) ) ) : A; } // FSL
                case 3b101: { result = ( fshiftcount != 0 ) ? ( ( A >> fshiftcount ) | ( B << ( 32 - fshiftcount ) ) ) : A; } // FSR
            }
            busy = 0;
        }
    }
}

// GENERAL REVERSE / GENERAL OR CONDITIONAL
algorithm grevgorc(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint7   function7,
    output  uint32  result
) <autorun> {
    uint6   FSM = uninitialised;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: { result = sourceReg1; }
                    case 1: { if( shiftcount[0,1] ) { result = ( ( function7 == 7b0110100 ) ? result : 0 ) | ( ( result & 32h55555555 ) << 1 ) | ( ( result & 32haaaaaaaa ) >> 1 ); } }
                    case 2: { if( shiftcount[1,1] ) { result = ( ( function7 == 7b0110100 ) ? result : 0 ) | ( ( result & 32h33333333 ) << 2 ) | ( ( result & 32hcccccccc ) >> 2 ); } }
                    case 3: { if( shiftcount[2,1] ) { result = ( ( function7 == 7b0110100 ) ? result : 0 ) | ( ( result & 32h0f0f0f0f ) << 4 ) | ( ( result & 32hf0f0f0f0 ) >> 4 ); } }
                    case 4: { if( shiftcount[3,1] ) { result = ( ( function7 == 7b0110100 ) ? result : 0 ) | ( ( result & 32h00ff00ff ) << 8 ) | ( ( result & 32hff00ff00 ) >> 8 ); } }
                    case 5: { if( shiftcount[4,1] ) { result = ( ( function7 == 7b0110100 ) ? result : 0 ) | ( ( result & 32h0000ffff ) << 16 ) | ( ( result & 32hffff0000 ) >> 16 ); } }
                }
                FSM = FSM << 1;
            }
            busy = 0;
        }
    }
}

// SHUFFLE / UNSHUFFLE
circuitry shuffle32_stage(
    input   src,
    input   maskL,
    input   maskR,
    input   N,
    output  x
) {
    uint32  A = uninitialised;
    uint32  B = uninitialised;

    x = src & ~( maskL | maskR );
    switch( N ) {
        case 1: { A = { src[0,31] , 1b0 }; B = { 1b0, src[1,31] }; }
        case 2: { A = { src[0,30] , 2b0 }; B = { 2b0, src[2,30] }; }
        case 4: { A = { src[0,28] , 4b0 }; B = { 4b0, src[4,28] }; }
        case 8: { A = { src[0,24] , 8b0 }; B = { 8b0, src[8,24] }; }
    }
    ++:
    x = x | ( A & maskL ) | ( B & maskR );
}
algorithm shflunshfl(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint3   function3,
    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialised;
    uint3   count = uninitialized;
    uint2   i = uninitialized;

    uint4   N8 = 8; uint32 N8A = 32h00ff0000; uint32 N8B = 32h0000ff00;
    uint4   N4 = 4; uint32 N4A = 32h0f000f00; uint32 N4B = 32h00f000f0;
    uint4   N2 = 2; uint32 N2A = 32h30303030; uint32 N2B = 32h0c0c0c0c;
    uint4   N1 = 1; uint32 N1A = 32h44444444; uint32 N1B = 32h22222222;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        result = sourceReg1;
                        count = 0;
                        i = ( function3 == 3b101) ? 0 : 3;
                    }
                    case 1: {
                        while( count < 4 ) {
                            switch( i ) {
                                case 0: { if( shiftcount[0,1] ) { ( result ) = shuffle32_stage( result, N1A, N1B, N1 ); } }
                                case 1: { if( shiftcount[1,1] ) { ( result ) = shuffle32_stage( result, N2A, N2B, N2 ); } }
                                case 2: { if( shiftcount[2,1] ) { ( result ) = shuffle32_stage( result, N4A, N4B, N4 ); } }
                                case 3: { if( shiftcount[3,1] ) { ( result ) = shuffle32_stage( result, N8A, N8B, N8 ); } }
                            }
                            i = ( function3 == 3b101) ? i + 1 : i - 1;
                            count = count + 1;
                        }
                    }
                }
                FSM = FSM << 1;
            }
            busy = 0;
        }
    }
}

// CARRYLESS MULTIPLY
algorithm clmul(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialised;

    uint6   i = uninitialised;
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        i = ( function3 == 3b011 ) ? 1 : 0;
                        result = 0;
                    }
                    case 1: {
                        while( i < 32 ) {
                            if( sourceReg2[i,1] ) {
                                result = result ^ ( sourceReg1 << ( function3 == 3b001 ) ? i : ( ( function3 == 3b001 ) ? ( 32 - i ) : ( 31 - i ) ) );
                            }
                            i = i + 1;
                        }
                    }
                }
                FSM = FSM << 1;
            }
            busy = 0;
        }
    }
}

// BITS EXTRACT / DEPOSIT / PLACE
algorithm bextbdep(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint7   function7,
    output  uint32  result
) <autorun> {
    uint2 FSM = uninitialised;

    uint6   i = uninitialised;
    uint6   j = uninitialised;
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        i = 0;
                        j = 0;
                        result = 0;
                    }
                    case 1: {
                        while( i < 32 ) {
                            if( sourceReg2[i,1] ) {
                                if( sourceReg1[ ( ( function7 == 7b0100100 ) ? j : i ), 1] ) {
                                    result[ j, 1 ] = 1b1;
                                }
                                j = j + 1;
                            }
                            i = i + 1;
                        }
                    }
                }
                FSM = FSM << 1;
            }
            busy = 0;
        }
    }
}
algorithm bfp(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  result
) <autorun> {
    uint3   FSM = uninitialised;
    uint5   length = uninitialised;
    uint6   offset = uninitialised;
    uint32  mask = uninitialised;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        length = ( sourceReg2[24,4] == 0 ) ? 16 : sourceReg2[24,4];
                        offset = sourceReg2[16,5];
                        mask = 0;
                    }
                    case 1: { mask = ~(~mask << length) << offset; }
                    case 2: { result = ( ( sourceReg2 << offset ) & mask ) | ( sourceReg1 & ~mask ); }
                }
                FSM = FSM << 1;
            }
            busy = 0;
        }
    }
}

// COUNT LEADING 0s, TRAILING 0s, POPULATION OF 1s
algorithm clz(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  sourceReg1,

    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialised;
    uint32  bitcount = uninitialized;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        bitcount = sourceReg1;
                        result = 0;
                    }
                    case 1: {
                        while( ~bitcount[31,1] ) {
                            bitcount = { bitcount[0,31], 1b0 };
                            result = result + 1;
                        }
                    }
                }
                FSM = FSM << 1;
            }
            busy = 0;
        }
    }
}
algorithm ctz(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  sourceReg1,

    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialised;
    uint32  bitcount = uninitialized;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        bitcount = sourceReg1;
                        result = 0;
                    }
                    case 1: {
                        while( ~bitcount[31,1] ) {
                            result = result + 1;
                            bitcount = { bitcount[0,31], 1b0 };
                        }
                    }
                }
                FSM = FSM << 1;
            }
            busy = 0;
        }
    }
}
algorithm cpop(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  sourceReg1,

    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialised;
    uint32  bitcount = uninitialized;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        bitcount = sourceReg1;
                        result = 0;
                    }
                    case 1: {
                        while( bitcount != 0 ) {
                            result = result + ( bitcount[0,1] ? 1 : 0 );
                            bitcount = { 1b0, bitcount[1,31] };
                        }
                    }
                }
                FSM = FSM << 1;
            }
            busy = 0;
        }
    }
}

// CRC32 and CRC32C for byte, half-word and word
algorithm crc32(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  sourceReg1,
    input   uint5   IshiftCount,

    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialised;
    uint6   nbits = uninitialised;
    uint6   i = uninitialised;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        result = sourceReg1;
                        i = 0;
                        switch( IshiftCount[0,2] ) {
                            case 2b00: { nbits = 8; }
                            case 2b01: { nbits = 16; }
                            case 2b10: { nbits = 32; }
                        }
                    }
                    case 1: {
                        while( i < nbits ) {
                            switch( IshiftCount[3,1] ) {
                                case 1b0: { result = ( result >> 1 ) ^ ( 32hedb88320 & ~( ( result & 1 ) - 1 ) ); }
                                case 1b1: { result = ( result >> 1 ) ^ ( 32h82f63b78 & ~( ( result & 1 ) - 1 ) ); }
                            }
                            i = i + 1;
                        }
                    }
                }
                FSM = FSM << 1;
            }
            busy = 0;
        }
    }
}

// XPERM for nibble, byte and half-word
algorithm xperm(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialised;
    uint2   FSM2 = uninitialised;

    uint3   sz_log2 = uninitialised;
    uint6   sz = uninitialised;
    uint32  mask = uninitialised;
    uint32  pos = uninitialised;
    uint6   i = uninitialised;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        switch( function3 ) {
                            case 3b010: { sz_log2 = 2; sz = 6b000100; mask = 32h0000000f; }
                            case 3b100: { sz_log2 = 3; sz = 6b001000; mask = 32h000000ff; }
                            case 3b110: { sz_log2 = 4; sz = 6b010000; mask = 32h0000ffff; }
                        }
                        result = 0;
                        i = 0;
                    }
                    case 1: {
                        while( i < 32 ) {
                            FSM2 = 1;
                            while( FSM2 != 0 ) {
                                onehot( FSM2 ) {
                                    case 0: { pos = ( ( sourceReg2 >> i ) & mask ) << sz_log2; }
                                    case 1: {
                                        if( pos < 32 ) {
                                            result = result | (( sourceReg1 >> pos ) & mask ) << i;
                                        }
                                        i = i + sz;
                                    }
                                }
                                FSM2 = FSM2 << 1;
                            }
                        }
                    }
                }
                FSM = FSM << 1;
            }
            busy = 0;
        }
    }
}

