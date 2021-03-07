// ALU S- BASE - M EXTENSION - B EXTENSION

// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient
algorithm aluMdivideremain(
    input   uint1   start,
    output! uint1   busy,

    input   uint3   dosign,
    input   uint32  dividend,
    input   uint32  divisor,

    output! uint32  result
) <autorun> {
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

            dividend_copy = ~dosign[0,1] ? ( dividend[31,1] ? -dividend : dividend ) : dividend;
            divisor_copy = ~dosign[0,1] ? ( divisor[31,1] ? -divisor : divisor ) : divisor;
            quotientremaindersign = ~dosign[0,1] ? dividend[31,1] ^ divisor[31,1] : 0;
            quotient = 0;
            remainder = 0;
            bit = 31;
            ++:
            if( divisor != 0 ) {
                while( bit != 63 ) {
                    if( __unsigned({ remainder[0,31], dividend_copy[bit,1] }) >= __unsigned(divisor_copy) ) {
                        remainder = __unsigned({ remainder[0,31], dividend_copy[bit,1] }) - __unsigned(divisor_copy);
                        quotient[bit,1] = 1;
                    } else {
                        remainder = { remainder[0,31], dividend_copy[bit,1] };
                    }
                    bit = bit - 1;
                }
                result = dosign[1,1] ? remainder : ( quotientremaindersign ? -quotient : quotient );
            } else {
                result = dosign[1,1] ? dividend : 32hffffffff;
            }

            busy = 0;
        }
    }
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
algorithm aluMmultiply(
    input   uint1   start,
    output! uint1   busy,

    input   uint3   dosign,
    input   uint32  factor_1,
    input   uint32  factor_2,

    output! uint32  result
) <autorun> {
    uint2   dosigned := dosign[1,1] ? ( dosign[0,1] ? 0 : 2 ) : 1;
    uint1   productsign := ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] ^ factor_2[31,1] ) : factor_1[31,1] );
    uint32  factor_1_copy := ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
    uint32  factor_2_copy := ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );
    uint64  product := productsign ? -( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } ) : ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );

    // Calculation is split into 4 18 x 18 multiplications for DSP
    uint18  A := { 2b0, factor_1_copy[16,16] };
    uint18  B := { 2b0, factor_1_copy[0,16] };
    uint18  C := { 2b0, factor_2_copy[16,16] };
    uint18  D := { 2b0, factor_2_copy[0,16] };

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;

            ++:
            result = ( dosign == 0 ) ? product[0,32] : product[32,32];

            busy = 0;
        }
    }
}

// BASE IMMEDIATE WITH B EXTENSIONS
algorithm aluIb001(
    input   uint1   start,
    output! uint1   busy,

    input   uint7   function7,
    input   uint5   IshiftCount,
    input   uint32  sourceReg1,

    input   uint32  LSHIFToutput,
    input   uint32  SBSCIoutput,

    input   uint32  SHFLUNSHFLoutput,
    input   uint1   SHFLUNSHFLbusy,

    output! uint32  result
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
            switch( function7 ) {
                case 7b0110000: {
                    busy = 1;
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
                    busy = 0;
                }
                case 7b0000100: {
                    busy = 1;
                    while( SHFLUNSHFLbusy ) {}
                    result = SHFLUNSHFLoutput;
                    busy = 0;
                }
                default: {
                    switch( function7[2,1] ) {
                        case 0: { result = LSHIFToutput; }
                        case 1: { result = SBSCIoutput; }
                    }
                }
            }
        }
    }
}
algorithm aluIb101(
    input   uint1   start,
    output! uint1   busy,

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
    output! uint32  result
) <autorun> {
    // START FLAGS FOR ALU SUB BLOCKS
    busy = 0;

    while(1) {
        if( start ) {
            if( ( function7 == 7b0010100 ) || ( function7 == 7b0110100 ) ) {
                busy = 1;
                while( GREVGORCbusy ) {}
                result = GREVGORCoutput;
                busy = 0;
            } else {
                switch( function7 ) {
                    case 7b0000100: {
                        busy = 1;
                        while( SHFLUNSHFLbusy ) {}
                        result = SHFLUNSHFLoutput;
                        busy = 0;
                    }
                    case 7b0100100: { result = sourceReg1[ IshiftCount, 1 ]; }
                    default: {
                        if( function7[1,1] ) {
                            busy = 1;
                            while( FUNNELbusy ) {}
                            result = FUNNELoutput;
                            busy = 0;
                        } else {
                            result = RSHIFToutput;
                        }
                    }
                }
            }
        }
    }
}
algorithm aluI(
    input   uint1   start,
    output! uint1   busy,

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

    output! uint32   result
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
            switch( function3 ) {
                case 3b001: {
                    busy = 1;
                    ALUIb001.start = 1;
                    if( ALUIb001.busy ) {
                        while( ALUIb001.busy ) {}
                    }
                    result = ALUIb001.result;
                    busy = 0;
                }
                case 3b101: {
                    busy = 1;
                    ALUIb101.start = 1;
                    if( ALUIb101.busy ) {
                        while( ALUIb101.busy ) {}
                    }
                    result = ALUIb101.result;
                    busy = 0;
                }
                default: {
                    switch( function3 ) {
                        case 3b000: { result = sourceReg1 + immediateValue; }
                        case 3b010: { result = __signed( sourceReg1 ) < __signed(immediateValue) ? 32b1 : 32b0; }
                        case 3b011: { result = ( immediateValue == 1 ) ? ( ( sourceReg1 == 0 ) ? 32b1 : 32b0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ) ? 32b1 : 32b0 ); }
                        case 3b100: { result = sourceReg1 ^ immediateValue; }
                        case 3b110: { result = sourceReg1 | immediateValue; }
                        case 3b111: { result = sourceReg1 & immediateValue; }
                    }
                }
            }
        }
    }
}

// BASE REGISTER + B extensions
// B EXTENSION GORC XPERM + SBSET
algorithm aluR7b0010100 (
    input   uint1   start,
    output! uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  SBSCIoutput,

    input   uint32  GREVGORCoutput,
    input   uint1   GREVGORCbusy,

    output! uint32  result
) <autorun> {
    uint5   RshiftCount := sourceReg2[0,5];

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
            switch( function3 ) {
                case 3b001: { result = SBSCIoutput; }
                case 3b101: {
                    busy = 1;
                    while( GREVGORCbusy ) {}
                    result = GREVGORCoutput;
                    busy = 0;
                }
                default: {
                    busy = 1;
                    XPERM.start = 1;
                    while( XPERM.busy ) {}
                    result = XPERM.result;
                    busy = 0;
                }
            }
        }
    }
}
// B EXTENSION CLMUL + MIN[U] MAX[U]
algorithm aluR7b0000101 (
    input   uint1   start,
    output! uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,

    output! uint32  result
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
            switch( function3 ) {
                case 3b100: { ( result ) = MIN( sourceReg1, sourceReg2 ); }
                case 3b110: { ( result ) = MINU( sourceReg1, sourceReg2 ); }
                case 3b101: { ( result ) = MAX( sourceReg1, sourceReg2 ); }
                case 3b111: { ( result ) = MAXU( sourceReg1, sourceReg2 ); }
                // 0.93+ ENCODINGS
                //case 3b100: { ( result ) = MIN( sourceReg1, sourceReg2 ); }
                //case 3b101: { ( result ) = MINU( sourceReg1, sourceReg2 ); }
                //case 3b110: { ( result ) = MAX( sourceReg1, sourceReg2 ); }
                //case 3b111: { ( result ) = MAXU( sourceReg1, sourceReg2 ); }
                default: {
                    busy = 1;
                    CLMUL.start = 1;
                    while( CLMUL.busy ) {}
                    result = CLMUL.result;
                    busy = 0;
                }
            }
        }
    }
}
// B EXTENSION SHFL UNSHFL BEXT + PACK PACKH
algorithm aluR7b0000100 (
    input   uint1   start,
    output! uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,

    input   uint32  SHFLUNSHFLoutput,
    input   uint1   SHFLUNSHFLbusy,
    input   uint32  BEXTBDEPoutput,
    input   uint1   BEXTBDEPbusy,

    output! uint32  result
) <autorun> {
    uint5   RshiftCount := sourceReg2[0,5];

    // START FLAGS FOR ALU SUB BLOCKS
    busy = 0;

    while(1) {
        if( start ) {
            switch( function3 ) {
                case 3b110: {
                    busy = 1;
                    while( BEXTBDEPbusy ) {}
                    result = BEXTBDEPoutput;
                    busy = 0;
                }
                case 3b100: { result = { sourceReg2[0,16], sourceReg1[0,16] }; }
                case 3b111: { result = { 16b0, sourceReg2[0,8], sourceReg1[0,8] }; }
                default: {
                    busy = 1;
                    while( SHFLUNSHFLbusy ) {}
                    result = SHFLUNSHFLoutput;
                    busy = 0;
                }
            }
        }
    }
}
// B EXTENSION GREV + SBINV
algorithm aluR7b0110100 (
    input   uint1   start,
    output! uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  SBSCIoutput,

    input   uint32  GREVGORCoutput,
    input   uint1   GREVGORCbusy,

    output! uint32  result
) <autorun> {
    uint5   RshiftCount := sourceReg2[0,5];

    // START FLAGS FOR ALU SUB BLOCKS
    busy = 0;

    while(1) {
        if( start ) {
            switch( function3 ) {
                case 3b001: { result = SBSCIoutput; }
                default: {
                    busy = 1;
                    while( GREVGORCbusy ) {}
                    result = GREVGORCoutput;
                    busy = 0;
                }
            }
        }
    }
}
// B EXTENSION BDEP BFP + PACKU SBCLR SBEXT
algorithm aluR7b0100100 (
    input   uint1   start,
    output! uint1   busy,

    input   uint3   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  SBSCIoutput,
    input   uint32  BEXTBDEPoutput,
    input   uint1   BEXTBDEPbusy,

    output! uint32  result
) <autorun> {
    uint5   RshiftCount := sourceReg2[0,5];

    // BFP
    bfp BFP (
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2
    );

    // START FLAGS FOR ALU SUB BLOCKS
    BFP.start := 0;
    busy = 0;

    while(1) {
        if( start ) {
            switch( function3 ) {
                case 3b001: { result = SBSCIoutput; }
                case 3b100: { result = { sourceReg2[16,16], sourceReg1[16,16] }; }
                case 3b101: { result = sourceReg1[ RshiftCount, 1 ]; }
                case 3b110: {
                    busy = 1;
                    while( BEXTBDEPbusy ) {}
                    result = BEXTBDEPoutput;
                    busy = 0;
                }
                case 3b111: {
                    busy = 1;
                    BFP.start = 1;
                    while( BFP.busy ) {}
                    result = BFP.result;
                    busy = 0;
                }
            }
        }
    }
}
// BASE ADD SUB SLL SLT SLTU XOR SRL SRA OR AND + B EXTENSION ROL SLO SH1/2/3ADD XNOR ROR SRO ORN ANDN + CMOV CMIX + (not yet implemented FSL FSR space)
algorithm aluR (
    input   uint1   start,
    output! uint1   busy,

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

    output! uint32  result
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
            switch( function7 ) {
                // M EXTENSION MULTIPLICATION AND DIVISION
                case 7b0000001: {
                    busy = 1;
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
                    busy = 0;
                }
                // B EXTENSION BLOCKS
                case 7b0010100: {
                    busy = 1;
                    ALUR7b0010100.start = 1;
                    while( ALUR7b0010100.busy ) {}
                    result = ALUR7b0010100.result;
                    busy = 0;
                }
                case 7b0000101: {
                    busy = 1;
                    ALUR7b0000101.start = 1;
                    while( ALUR7b0000101.busy ) {}
                    result = ALUR7b0000101.result;
                    busy = 0;
                }
                case 7b0000100: {
                    busy = 1;
                    BEXTBDEP.start = ( function3 == 3b110 ) ? 1 : 0;
                    ALUR7b0000100.start = 1;
                    while( ALUR7b0000100.busy ) {}
                    result = ALUR7b0000100.result;
                    busy = 0;
                }
                case 7b0110100: {
                    busy = 1;
                    ALUR7b0110100.start = 1;
                    while( ALUR7b0110100.busy ) {}
                    result = ALUR7b0110100.result;
                    busy = 0;
                }
                case 7b0100100: {
                    busy = 1;
                    BEXTBDEP.start = ( function3 == 3b110 ) ? 1 : 0;
                    ALUR7b0100100.start = 1;
                    while( ALUR7b0100100.busy ) {}
                    result = ALUR7b0100100.result;
                    busy = 0;
                }
                // BASE + REMAINING B EXTENSION
                default: {
                    switch( function3 ) {
                        case 3b000: {
                            // ADD SUB
                            result = sourceReg1 + ( function7[5,1] ? -( sourceReg2 ) : sourceReg2 );
                        }
                        case 3b001: {
                            switch( function2 ) {
                                case 2b11: {
                                    // CMIX
                                    result = ( sourceReg1 & sourceReg2 ) | ( sourceReg3 & ~sourceReg2 );
                                }
                                case 2b10: {
                                    // FSL
                                }
                                default: {
                                    // ROL SLL SLO FSL
                                    if( function7[0,2] == 2b10 ) {
                                        busy = 1;
                                        while( FUNNELbusy ) {}
                                        result = FUNNELoutput;
                                        busy = 0;
                                    } else {
                                        result = LSHIFToutput;
                                    }
                                }
                            }
                        }
                        case 3b010: {
                            // SLT SH1ADD
                            switch( function7 ) {
                                case 7b0000000: { result = __signed( sourceReg1 ) < __signed(sourceReg2) ? 32b1 : 32b0; }
                                case 7b0010000: { result = { sourceReg1[1,31], 1b0 } + sourceReg2; }
                            }
                        }
                        case 3b011: {
                            // SLTU
                            result = ( rs1 == 0 ) ? ( ( sourceReg2 != 0 ) ? 32b1 : 32b0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ) ? 32b1 : 32b0 );
                        }
                        case 3b100: {
                            // SH2ADD XOR XNOR
                            switch( function7 ) {
                                case 7b0010000: { result = { sourceReg1[2,30], 2b00 } + sourceReg2; }
                                default: { result = sourceReg1 ^ ( ( function7[5,1] == 1 ) ? ~sourceReg2 : sourceReg2 ); }
                            }
                        }
                        case 3b101: {
                            switch( function2 ) {
                                case 2b11: {
                                    // CMOV
                                    result = ( sourceReg2 != 0 ) ? sourceReg1 : sourceReg3;
                                }
                                case 2b10: {
                                    // FSR
                                }
                                default: {
                                    // ROR SRL SRA SRO FSR
                                    if( function7[0,2] == 2b10 ) {
                                        busy = 1;
                                        while( FUNNELbusy ) {}
                                        result = FUNNELoutput;
                                        busy = 0;
                                    } else {
                                        result = RSHIFToutput;
                                    }
                                }
                            }
                        }
                        case 3b110: {
                            // SH3ADD OR ORN
                            switch( function7 ) {
                                case 7b0010000: { result = { sourceReg1[3,29], 3b000 } + sourceReg2; }
                                default: { result = sourceReg1 | ( ( function7[5,1] == 1 ) ? ~sourceReg2 : sourceReg2 ); }
                            }
                        }
                        case 3b111: {
                            // AND ANDN
                            result = sourceReg1 & ( ( function7[5,1] == 1 ) ? ~sourceReg2 : sourceReg2 );
                        }
                    }
                }
            }
        }
    }
}

// ALU - ALU for immediate-register operations and register-register operations
algorithm alu(
    input   uint1   start,
    output! uint1   busy,

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

    output! uint32  result
) <autorun> {
    uint1   ALUIorR := ( opCode == 7b0010011 ) ? 1 : 0;
    uint5   shiftcount := ALUIorR ? IshiftCount : sourceReg2[0,5];
    uint6   Fshiftcount := ALUIorR ? { function7[0,1], IshiftCount } : sourceReg2[0,6];

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
            // START SHARED MULTICYCLE BLOCKS - SHFL UNSHFL GORC GREV FUNNEL
            FUNNEL.start = ( function3 == 3b001 ) || ( function3 == 3b101 );
            SHFLUNSHFL.start = ( ( ( function3 == 3b001 ) || ( function3 == 3b101 ) ) && ( function7 == 7b0000100 ) ) ? 1 : 0;
            GREVGORC.start = ( ( function3 == 3b101 ) && ( ( function7 == 7b0110100 ) || ( function7 == 7b0010100 ) ) ) ? 1 : 0;

            // START ALUI or ALUR
            busy = 1;
            ALUI.start = ALUIorR;
            ALUR.start = ~ALUIorR;
            if( ALUI.busy || ALUR.busy ) {
                while( ALUI.busy || ALUR.busy ) {}
            }
            result = ALUIorR ? ALUI.result : ALUR.result;
            busy = 0;
        }
    }
}

// RISC-V MANDATORY CSR REGISTERS
algorithm CSRblock(
    input   uint1   start,
    input   uint32  instruction,
    input   uint1   incCSRinstret,
    input   uint1   SMT,
    output! uint32  result
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
        if( start && ( CSR(instruction).rs1 == 0 ) && ( CSR(instruction).function3 == 3b010 ) ) {
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
}

// ATOMIC A EXTENSION ALU
algorithm aluA (
    input   uint1   start,

    input   uint7   function7,
    input   uint32  memoryinput,
    input   uint32  sourceReg2,

    output! uint32  result
) <autorun> {
    while(1) {
        if( start ) {
            switch( function7[2,5] ) {
                case 5b00000: { result = memoryinput + sourceReg2; }            // AMOADD
                case 5b00001: { result = sourceReg2; }                          // AMOSWAP
                case 5b00100: { result = memoryinput ^ sourceReg2; }            // AMOXOR
                case 5b01000: { result = memoryinput | sourceReg2; }            // AMOOR
                case 5b01100: { result = memoryinput & sourceReg2; }            // AMOAND
                case 5b10000: { ( result ) = MIN( memoryinput, sourceReg2); }   // AMOMIN
                case 5b10100: { ( result ) = MAX( memoryinput, sourceReg2); }   // AMOMAX
                case 5b11000: { ( result ) = MINU( memoryinput, sourceReg2); }  // AMOMINU
                case 5b11100: { ( result ) = MAXU( memoryinput, sourceReg2); }  // AMOMAXU
            }
        }
    }
}
