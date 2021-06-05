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
    pcnt PCNT(
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
    PCNT.start := 0;
    CRC32.start := 0;
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            switch( function7 ) {
                case 7b0110000: {
                    switch( IshiftCount ) {
                        case 5b00000: { CLZ.start = 1; while( CLZ.busy ) {} result = CLZ.result; }      // CLZ
                        case 5b00001: { CTZ.start = 1; while( CTZ.busy ) {} result = CTZ.result; }      // CTZ
                        case 5b00010: { PCNT.start = 1; while( PCNT.busy ) {} result = PCNT.result; }   // PCNT
                        case 5b00100: { result = { {24{sourceReg1[7,1]}}, sourceReg1[0, 8] }; }         // SEXT.B
                        case 5b00101: { result = { {16{sourceReg1[15,1]}}, sourceReg1[0, 16] }; }       // SEXT.H
                        default: { CRC32.start = 1; while( CRC32.busy ) {} result = CRC32.result; }     // CRC32 / CRC32C
                    }
                }
                case 7b0000100: { while( SHFLUNSHFLbusy ) {} result = SHFLUNSHFLoutput; }               // SHFLI
                default: { result = ( function7[2,1] == 1 ) ? SBSCIoutput : LSHIFToutput; }             // BSETI BCLRI BINVI SLLI SLOI
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
            switch( function7[2,5] ) {
                case 5b00001: { while( SHFLUNSHFLbusy ) {} result = SHFLUNSHFLoutput; }                 // UNSHFLI
                case 5b00101: { while( GREVGORCbusy ) {} result = GREVGORCoutput; }                     // GORCI
                case 5b01101: { while( GREVGORCbusy ) {} result = GREVGORCoutput; }                     // GREVI
                case 5b01001: { result = sourceReg1[ IshiftCount, 1 ]; }                                // BEXTI
                default: { result = function7[1,1] ? FUNNELoutput : RSHIFToutput; }                     // SRLI SRAI RORI FSRI
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
                case 3b001: { ALUIb001.start = 1; while( ALUIb001.busy ) {} result = ALUIb001.result; }
                case 3b010: { result = __signed( sourceReg1 ) < __signed(immediateValue); }
                case 3b011: { result = ( immediateValue == 1 ) ? ( sourceReg1 == 0 ) : ( __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ); }
                case 3b100: { result = sourceReg1 ^ immediateValue; }
                case 3b101: { ALUIb101.start = 1; while( ALUIb101.busy ) {} result = ALUIb101.result; }
                case 3b110: { result = sourceReg1 | immediateValue; }
                case 3b111: { result = sourceReg1 & immediateValue; }
            }
            busy = 0;
        }
    }
}

// BASE REGISTER + B extensions
// BASE ADD SUB SLL SLT SLTU XOR SRL SRA OR AND + B EXTENSION ROL SLO SH1/2/3ADD XNOR ROR SRO ORN ANDN + CMOV CMIX + FSL FSR
algorithm aluR000(
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint7   function7,
    output  int32   result
) <autorun> {
    result := sourceReg1 + ( function7[5,1] ? -( sourceReg2 ) : sourceReg2 );
}
algorithm aluR001(
    input   uint1   start,
    output  uint1   busy,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   int32   sourceReg3,
    input   uint7   function7,
    input   int32   LSHIFToutput,
    input   uint32  SBSCIoutput,
    input   uint32  CLMULoutput,
    input   uint1   CLMULbusy,
    input   uint32  SHFLUNSHFLoutput,
    input   uint1   SHFLUNSHFLbusy,
    input   int32   FUNNELoutput,
    output  int32   result
) <autorun> {
    busy = 0;
    while(1) {
        if( start ) {
            busy = 1;
            switch( function7[0,2] ) {
                case 2b00: {
                    switch( function7 ) {
                        case 7b0000100: { while( SHFLUNSHFLbusy ) {} result = SHFLUNSHFLoutput; }                       // SHFL
                        default: { result = function7[2,1] ? SBSCIoutput : LSHIFToutput; }                              // BSET BCLR BINV SLL SLO ROL
                    }
                }
                case 2b01: { while( CLMULbusy ) {} result = CLMULoutput; }                                                              // CLMUL
                default: { result = function7[0,1] ? ( sourceReg1 & sourceReg2 ) | ( sourceReg3 & ~sourceReg2 ) : FUNNELoutput; }     // FSL / CMIX
            }
            busy = 0;
        }
    }
}
algorithm aluR010(
    input   uint1   start,
    output  uint1   busy,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint7   function7,
    input   uint32  CLMULoutput,
    input   uint1   CLMULbusy,
    input   uint32  XPERMoutput,
    input   uint1   XPERMbusy,
    output  int32   result
) <autorun> {
    busy = 0;
    while(1) {
        if( start ) {
            busy = 1;
            switch( function7[0,5] ) {
                case 5b00000: { result = __signed( sourceReg1 ) < __signed(sourceReg2); }       // SLT
                case 5b00101: { while( CLMULbusy ) {} result = CLMULoutput; }                                 // CLMULR
                case 5b10100: { while( XPERMbusy ) {} result = XPERMoutput; }                                 // XPERM.N
                case 5b10000: { result = ( { sourceReg1[0,31], 1b0 } ) + sourceReg2; }                        // SH1ADD
            }
            busy = 0;
        }
    }
}
algorithm aluR011(
    input   uint1   start,
    output  uint1   busy,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint5   rs1,
    input   uint7   function7,
    input   uint32  CLMULoutput,
    input   uint1   CLMULbusy,
    output  int32   result
) <autorun> {
    busy = 0;
    while(1) {
        if( start ) {
            busy = 1;
            switch( function7[0,1] ) {
                case 1b0: { result = ( rs1 == 0 ) ? ( sourceReg2 != 0 ) : __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ); }  // SLTU
                case 1b1: { while( CLMULbusy ) {} result = CLMULoutput; }                                                                                                 // CLMULH
            }
            busy = 0;
        }
    }
}
algorithm aluR100(
    input   uint1   start,
    output  uint1   busy,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint7   function7,
    input   uint32  XPERMoutput,
    input   uint1   XPERMbusy,
    output  int32   result
) <autorun> {
    busy = 0;
    while(1) {
        if( start ) {
            busy = 1;
            switch( function7 ) {
                case 7b0010000: { result = ( { sourceReg1[0,30], 2b0 } ) + sourceReg2; }                    // SH2ADD
                case 7b0000101: { ( result ) = min( sourceReg1, sourceReg2 ); }                             // MIN
                case 7b0000100: { result = { sourceReg2[0,16], sourceReg1[0,16] }; }                        // PACK
                case 7b0100100: { result = { sourceReg2[16,16], sourceReg1[16,16] }; }                      // PACKU
                case 7b0010100: { while( XPERMbusy ) {} result = XPERMoutput; }                             // XPERM.B
                default: { result = sourceReg1 ^ ( function7[5,1] ? ~sourceReg2 : sourceReg2 ); }  // XOR XNOR
            }
            busy = 0;
        }
    }
}
algorithm aluR101(
    input   uint1   start,
    output  uint1   busy,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   int32   sourceReg3,
    input   uint7   function7,
    input   int32   RSHIFToutput,
    input   int32   FUNNELoutput,
    input   uint32  GREVGORCoutput,
    input   uint1   GREVGORCbusy,
    input   uint32  SHFLUNSHFLoutput,
    input   uint1   SHFLUNSHFLbusy,
    output  int32   result
) <autorun> {
    busy = 0;
    while(1) {
        if( start ) {
            busy = 1;
            switch( function7[0,2] ) {
                case 2b00: {
                    switch( function7[2,5] ) {
                        case 5b00101: { while( GREVGORCbusy ) {} result = GREVGORCoutput; }                           // GORC
                        case 5b01101: { while( GREVGORCbusy ) {} result = GREVGORCoutput; }                           // GREV
                        case 5b00001: { while( SHFLUNSHFLbusy ) {} result = SHFLUNSHFLoutput; }                       // UNSHFL
                        case 5b01001: { result = sourceReg1[ sourceReg2[0,5], 1 ]; }                                    // SBEXT
                        default: { result = RSHIFToutput; }                                                           // SRL SRA SRO ROR
                    }
                }
                case 2b01: { ( result ) = minu( sourceReg1, sourceReg2 ); }                                // MINU
                default: { result = function7[0,1] ? ( sourceReg2 != 0 ) ? sourceReg1 : sourceReg3 : FUNNELoutput; }   // FSR CMOV
            }
            busy = 0;
        }
    }
}
algorithm aluR110(
    input   uint1   start,
    output  uint1   busy,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint7   function7,
    input   uint32  XPERMoutput,
    input   uint1   XPERMbusy,
    output  int32   result
) <autorun> {
    // BEXT BDEP UNIT
    bextbdep BEXTBDEP(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        function7 <: function7,
    );
    BEXTBDEP.start := 0;
    busy = 0;
    while(1) {
        if( start ) {
            busy = 1;
            switch( function7 ) {
                case 7b0010000: { result = ( { sourceReg1[0,29], 3b0 } ) + sourceReg2; }                        // SH3ADD
                case 7b0000101: { ( result ) = max( sourceReg1, sourceReg2 ); }                                 // MAX
                case 7b0100100: { BEXTBDEP.start = 1; while( BEXTBDEP.busy ) {} result = BEXTBDEP.result; }     // BDEP
                case 7b0000100: { BEXTBDEP.start = 1; while( BEXTBDEP.busy ) {} result = BEXTBDEP.result; }     // BEXT
                case 7b0010100: { while( XPERMbusy ) {} result = XPERMoutput; }                                 // XPERM.H
                default: { result = sourceReg1 | ( function7[5,1] ? ~sourceReg2 : sourceReg2 ); }      // OR ORN
            }
            busy = 0;
        }
    }
}
algorithm aluR111(
    input   uint1   start,
    output  uint1   busy,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   uint7   function7,
    output  int32   result
) <autorun> {
    // BFP
    bfp BFP(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
    );
    BFP.start := 0;
    busy = 0;
    while(1) {
        if( start ) {
            busy = 1;
            switch( function7 ) {
                case 7b0000101: { ( result ) = maxu( sourceReg1, sourceReg2 ); }                                // MAXU
                case 7b0100100: { BFP.start = 1; while( BFP.busy ) {} result = BFP.result; }                    // BFP
                case 7b0000100: { result = { 16b0, sourceReg2[0,8], sourceReg1[0,8] }; }                        // PACKH
                default: { result = sourceReg1 & ( function7[5,1] ? ~sourceReg2 : sourceReg2 ); }      // AND ANDN
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
    input   uint32  SBSCIoutput,

    input   uint32  FUNNELoutput,
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

    // CLMUL
    uint32  CLMULoutput = uninitialized;
    uint1   CLMULbusy = uninitialized;
    clmul CLMUL(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        result :> CLMULoutput,
        busy :> CLMULbusy
    );

    // XPERM
    uint32  XPERMoutput = uninitialized;
    uint1   XPERMbusy = uninitialized;
    xperm XPERM(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        result :> XPERMoutput,
        busy :> XPERMbusy
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
        function7 <: function7,
        LSHIFToutput <: LSHIFToutput,
        SBSCIoutput <: SBSCIoutput,
        CLMULoutput <: CLMULoutput,
        CLMULbusy <: CLMULbusy,
        SHFLUNSHFLoutput <: SHFLUNSHFLoutput,
        SHFLUNSHFLbusy <: SHFLUNSHFLbusy,
        FUNNELoutput <: FUNNELoutput
    );
    aluR010 ALUR010(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        function7 <: function7,
        CLMULoutput <: CLMULoutput,
        CLMULbusy <: CLMULbusy,
        XPERMoutput <: XPERMoutput,
        XPERMbusy <: XPERMbusy
    );
    aluR011 ALUR011(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        function7 <: function7,
        rs1 <: rs1,
        CLMULoutput <: CLMULoutput,
        CLMULbusy <: CLMULbusy,
    );
    aluR100 ALUR100(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        function7 <: function7,
        XPERMoutput <: XPERMoutput,
        XPERMbusy <: XPERMbusy
    );
    aluR101 ALUR101(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        sourceReg3 <: sourceReg3,
        function7 <: function7,
        RSHIFToutput <: RSHIFToutput,
        FUNNELoutput <: FUNNELoutput,
        GREVGORCoutput <: GREVGORCoutput,
        GREVGORCbusy <: GREVGORCbusy,
        SHFLUNSHFLoutput <: SHFLUNSHFLoutput,
        SHFLUNSHFLbusy <: SHFLUNSHFLbusy
    );
    aluR110 ALUR110(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        function7 <: function7,
        XPERMoutput <: XPERMoutput,
        XPERMbusy <: XPERMbusy
    );
    aluR111 ALUR111(
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        function7 <: function7
    );

    // START FLAGS FOR ALU SUB BLOCKS
    ALUMD.start := 0;
    ALUR001.start := 0;
    ALUR010.start := 0;
    ALUR011.start := 0;
    ALUR100.start := 0;
    ALUR101.start := 0;
    ALUR110.start := 0;
    ALUR111.start := 0;
    CLMUL.start := 0;
    XPERM.start := 0;

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
                    CLMUL.start = ( function7 == 7b0000101 ) & ~function3[2,1];
                    XPERM.start = ( function7 == 7b0010100 ) & ( ( function3 == 3b010) | ( function3 == 3b100 ) | ( function3 == 3b110 ) );
                    switch( function3 ) {
                        case 3b000: { result = ALUR000.result; }
                        case 3b001: { ALUR001.start = 1; while( ALUR001.busy ) {} result = ALUR001.result; }
                        case 3b010: { ALUR010.start = 1; while( ALUR010.busy ) {} result = ALUR010.result; }
                        case 3b011: { ALUR011.start = 1; while( ALUR011.busy ) {} result = ALUR011.result; }
                        case 3b100: { ALUR100.start = 1; while( ALUR100.busy ) {} result = ALUR100.result; }
                        case 3b101: { ALUR101.start = 1; while( ALUR101.busy ) {} result = ALUR101.result; }
                        case 3b110: { ALUR110.start = 1; while( ALUR110.busy ) {} result = ALUR110.result; }
                        case 3b111: { ALUR111.start = 1; while( ALUR111.busy ) {} result = ALUR111.result; }
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
    uint6   Fshiftcount <: opCode[5,1] ? sourceReg2[0,6] : { function7[0,1], IshiftCount };

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
    funnelshift FUNNEL(
        sourceReg1 <: sourceReg1,
        sourceReg3 <: sourceReg3,
        shiftcount <: Fshiftcount,
        function3 <: function3,
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
        SHFLUNSHFLoutput <: SHFLUNSHFLoutput,
        SHFLUNSHFLbusy <: SHFLUNSHFLbusy,
        GREVGORCoutput <: GREVGORCoutput,
        GREVGORCbusy <: GREVGORCbusy
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
        RSHIFToutput <: RSHIFToutput,
        SBSCIoutput <: SBSCIoutput,
        FUNNELoutput <: FUNNELoutput,
        SHFLUNSHFLoutput <: SHFLUNSHFLoutput,
        SHFLUNSHFLbusy <: SHFLUNSHFLbusy,
        GREVGORCoutput <: GREVGORCoutput,
        GREVGORCbusy <: GREVGORCbusy
    );

    // ALU START FLAGS
    ALUI.start := 0;
    ALUR.start := 0;
    SHFLUNSHFL.start := 0;
    GREVGORC.start := 0;

    busy = 0;

    while(1) {
        if( start ) {
            // START SHARED MULTICYCLE BLOCKS - SHFL UNSHFL GORC GREV FUNNEL ( need to correctly specify start of funnel shifts )
            SHFLUNSHFL.start = ( ( ( function3 == 3b001 ) | ( function3 == 3b101 ) ) & ( function7 == 7b0000100 ) );
            GREVGORC.start = ( ( function3 == 3b101 ) & ( ( function7 == 7b0110100 ) | ( function7 == 7b0010100 ) ) );

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
    input   uint32  sourceReg1,
    input   uint32  sourceReg3,
    input   uint6   shiftcount,
    input   uint7   function3,
    output  uint32  result
) <autorun> {
    uint32  A <: ( shiftcount >= 32 ) ? sourceReg3 : sourceReg1;
    uint32  B <: ( shiftcount >= 32 ) ? sourceReg1 : sourceReg3;
    uint6  fshiftcount <: ( shiftcount >= 32 ) ? shiftcount - 32 : shiftcount;

    while(1) {
        switch( function3 ) {
            case 3b001: { result = ( fshiftcount != 0 ) ? ( ( A << fshiftcount ) | ( B >> ( 32 - fshiftcount ) ) ) : A; } // FSL
            case 3b101: { result = ( fshiftcount != 0 ) ? ( ( A >> fshiftcount ) | ( B << ( 32 - fshiftcount ) ) ) : A; } // FSR
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
                FSM = { FSM[0,5], 1b0 };
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
    switch( N ) {
        case 1: { A = { src[0,31] , 1b0 }; B = { 1b0, src[1,31] }; }
        case 2: { A = { src[0,30] , 2b0 }; B = { 2b0, src[2,30] }; }
        case 4: { A = { src[0,28] , 4b0 }; B = { 4b0, src[4,28] }; }
        case 8: { A = { src[0,24] , 8b0 }; B = { 8b0, src[8,24] }; }
    }
    x = ( src & ~( maskL | maskR ) ) | ( A & maskL ) | ( B & maskR );
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
                FSM = { FSM[0,1], 1b0 };
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
                        i = ( function3 == 3b011 );
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
                FSM = { FSM[0,1], 1b0 };
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
                FSM = { FSM[0,1], 1b0 };
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
                FSM = { FSM[0,2], 1b0 };
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

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        result = 0;
                    }
                    case 1: {
                        while( ~sourceReg1[31-result,1] ) {
                            result = result + 1;
                        }
                    }
                }
                FSM = { FSM[0,1], 1b0 };
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

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        result = 0;
                    }
                    case 1: {
                        while( ~sourceReg1[result,1] ) {
                            result = result + 1;
                        }
                    }
                }
                FSM = { FSM[0,1], 1b0 };
            }
            busy = 0;
        }
    }
}
algorithm pcnt(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  sourceReg1,

    output  uint32  result
) <autorun> {
    uint2   FSM = uninitialised;
    uint6  position = uninitialized;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;
            FSM = 1;
            while( FSM != 0 ) {
                onehot( FSM ) {
                    case 0: {
                        position = 0;
                        result = 0;
                    }
                    case 1: {
                        while( position != 32 ) {
                            result = result + sourceReg1[position,1];
                        }
                    }
                }
                FSM = { FSM[0,1], 1b0 };
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
                FSM = { FSM[0,1], 1b0 };
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
                                FSM2 = { FSM2[0,1], 1b0 };
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

