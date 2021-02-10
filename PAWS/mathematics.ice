// ALU S- BASE - M EXTENSION - B EXTENSION

// UNSIGNED / SIGNED 32 by 32 bit division giving 32 bit remainder and quotient
algorithm aluMdivideremain(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  dividend,
    input   uint32  divisor,

    output! uint32  result
) <autorun> {
    uint32  quotient = uninitialized;
    uint32  remainder = uninitialized;
    uint32  dividend_copy = uninitialized;
    uint32  divisor_copy = uninitialized;
    uint1   resultsign = uninitialized;
    uint6   bit = uninitialized;

    uint1   active = 0;
    busy := start ? 1 : active;

    while(1) {
        if( start ) {
            active = 1;
            dividend_copy = ~function3[0,1] ? ( dividend[31,1] ? -dividend : dividend ) : dividend;
            divisor_copy = ~function3[0,1] ? ( divisor[31,1] ? -divisor : divisor ) : divisor;
            resultsign = ~function3[0,1] ? dividend[31,1] != divisor[31,1] : 0;
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
                result = function3[1,1] ? remainder : ( resultsign ? -quotient : quotient );
            } else {
                result = function3[1,1] ? dividend : 32hffffffff;
            }

            active = 0;
        }
    }
}

// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
algorithm aluMmultiply(
    input   uint1   start,
    output  uint1   busy,

    input   uint3   function3,
    input   uint32  factor_1,
    input   uint32  factor_2,

    output! uint32  result
) <autorun> {
    // FULLY SIGNED / PARTIALLY SIGNED / UNSIGNED and RESULT SIGNED FLAGS
    uint2   dosigned = uninitialized;
    uint1   resultsign = uninitialized;
    uint32  factor_1_copy = uninitialized;
    uint32  factor_2_copy = uninitialized;
    uint64  product = uninitialized;

    // Calculation is split into 4 18 x 18 multiplications for DSP
    uint18  A = uninitialized;
    uint18  B = uninitialized;
    uint18  C = uninitialized;
    uint18  D = uninitialized;

    uint1   active = 0;
    busy := start ? 1 : active;

    while(1) {
        if( start ) {
            active = 1;

            dosigned = function3[1,1] ? ( function3[0,1] ? 0 : 2 ) : 1;
            resultsign = ( dosigned == 0 ) ? 0 : ( ( dosigned == 1 ) ? ( factor_1[31,1] != factor_2[31,1] ) : factor_1[31,1] );
            factor_1_copy = ( dosigned == 0 ) ? factor_1 : ( ( factor_1[31,1] ) ? -factor_1 : factor_1 );
            factor_2_copy = ( dosigned != 1 ) ? factor_2 : ( ( factor_2[31,1] ) ? -factor_2 : factor_2 );
            ++:
            A = { 2b0, factor_1_copy[16,16] };
            B = { 2b0, factor_1_copy[0,16] };
            C = { 2b0, factor_2_copy[16,16] };
            D = { 2b0, factor_2_copy[0,16] };
            ++:
            product = resultsign ? -( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } ) : ( D*B + { D*A, 16b0 } + { C*B, 16b0 } + { C*A, 32b0 } );
            ++:
            result = ( function3 == 0 ) ? product[0,32] : product[32,32];

            active = 0;
        }

    }
}

// BASE IMMEDIATE + B extensions
algorithm aluIb001(
    input   uint1   start,
    output! uint1   busy,

    input   uint7   function7,
    input   uint5   IshiftCount,
    input   uint32  sourceReg1,

    output! uint32  result
) <autorun> {
    // SBSET SBCLR SBINV + BARREL SHIFTER
    singlebitops SBSCI(
        start <: start,
        sourceReg1 <: sourceReg1,
        function7 <: function7,
        shiftcount <: IshiftCount,
    );
    BSHIFTleft barrelLEFT(
        start <: start,
        sourceReg1 <: sourceReg1,
        function7 <: function7,
        shiftcount <: IshiftCount,
    );

    uint32  bitcount = uninitialized;
    busy = 0;

    while(1) {
        if( start ) {
            switch( function7 ) {
                case 7b0110000: {
                    switch( IshiftCount ) {
                        case 5b00000: {
                            // CLZ
                            if( sourceReg1 == 0 ) {
                                result = 32;
                            } else {
                                busy = 1;
                                bitcount = sourceReg1;
                                result = 0;
                                ++:
                                while( ~bitcount[31,1] ) {
                                    result = result + 1;
                                    bitcount = { bitcount[0,31], 1b0 };
                                }
                                busy = 0;
                            }
                        }
                        case 5b00001: {
                            // CTZ
                            if( sourceReg1 == 0 ) {
                                result = 32;
                            } else {
                                busy = 1;
                                bitcount = sourceReg1;
                                result = 0;
                                ++:
                                while( ~bitcount[0,1] ) {
                                    result = result + 1;
                                    bitcount = { 1b0, bitcount[1,31] };
                                }
                                busy = 0;
                            }
                        }
                        case 5b00010: {
                            // PCNT
                            if( sourceReg1 == 0 ) {
                                result = 0;
                            } else {
                                busy = 1;
                                bitcount = sourceReg1;
                                result = 0;
                                ++:
                                while( bitcount != 0 ) {
                                    result = result + bitcount[0,1];
                                    bitcount = { 1b0, bitcount[1,31] };
                                }
                                busy = 0;
                            }
                        }
                        case 5b00100: { result = { {24{sourceReg1[7,1]}}, sourceReg1[0, 8] }; }     // SEXT.B
                        case 5b00101: { result = { {16{sourceReg1[15,1]}}, sourceReg1[0, 16] }; }   // SEXT.H
                    }
                }
                case 7b0000100: {
                    busy = 1;
                    ( result ) = SHFL( sourceReg1, IshiftCount );
                    busy = 0;
                }
                default: {
                    switch( function7[2,1] ) {
                        case 0: { result = barrelLEFT.result; }
                        case 1: { result = SBSCI.result; }
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

    output! uint32  result
) <autorun> {
    // BARREL SHIFTERS / ROTATORS
    BSHIFTright barrelRIGHT(
        start <: start,
        sourceReg1 <: sourceReg1,
        function7 <: function7,
        shiftcount <: IshiftCount,
    );
    BROTATE barrelROTATE(
        start <: start,
        sourceReg1 <: sourceReg1,
        function3 <: function3,
        shiftcount <: IshiftCount,
    );

    busy = 0;

    while(1) {
        if( start ) {
            switch( function7 ) {
                case 7b0000100: {
                    busy = 1;
                    ( result ) = UNSHFL( sourceReg1, IshiftCount );
                    busy = 0;
                }
                case 7b0010100: {
                    busy = 1;
                    ( result ) = GORC( sourceReg1, IshiftCount );
                    busy = 0;
                }
                case 7b0100100: { result = sourceReg1[ IshiftCount, 1 ]; }
                case 7b0110000: { result = barrelROTATE.result;  }
                case 7b0110100: {
                    busy = 1;
                    ( result ) = GREV( sourceReg1, IshiftCount );
                    busy = 0;
                }
                default: {  result = barrelRIGHT.result; }
            }
        }
    }
}
algorithm aluI (
    input   uint1   start,
    output! uint1   busy,

    input   uint3   function3,
    input   uint7   function7,
    input   uint5   IshiftCount,
    input   uint32  sourceReg1,
    input   uint32  immediateValue,

    output! uint32   result
) <autorun> {
    // FUNCTION3 == 001 block
    aluIb001 ALUIb001(
        function7 <: function7,
        IshiftCount <: IshiftCount,
        sourceReg1 <: sourceReg1
    );
    aluIb101 ALUIb101(
        function7 <: function7,
        function3 <: function3,
        IshiftCount <: IshiftCount,
        sourceReg1 <: sourceReg1
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
                    while( ALUIb001.busy ) {}
                    result = ALUIb001.result;
                    busy = 0;
                }
                case 3b101: {
                    busy = 1;
                    ALUIb101.start = 1;
                    while( ALUIb101.busy ) {}
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

    output! uint32  result
) <autorun> {
    uint5   RshiftCount := sourceReg2[0,5];
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;

            switch( function3 ) {
                case 3b001: { result = SBSCIoutput; }
                case 3b101: { ( result ) = GORC( sourceReg1, RshiftCount ); }
                default: { ( result ) = XPERM( sourceReg1, sourceReg2, function3 ); }
            }

            busy = 0;
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
    busy = 0;

    while(1) {
        if( start ) {
            switch( function3 ) {
                case 3b100: { result = ( __signed( sourceReg1 ) < __signed( sourceReg2 ) ) ? sourceReg1 : sourceReg2; }
                case 3b101: { result = ( __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ) ? sourceReg1 : sourceReg2; }
                case 3b110: { result = ( __signed( sourceReg1 ) > __signed( sourceReg2 ) ) ? sourceReg1 : sourceReg2; }
                case 3b111: { result = ( __unsigned( sourceReg1 ) > __unsigned( sourceReg2 ) ) ? sourceReg1 : sourceReg2; }
                default: {
                    busy = 1;
                    ( result ) = CLMUL( sourceReg1, sourceReg2, function3 );
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

    output! uint32  result
) <autorun> {
    uint5   RshiftCount := sourceReg2[0,5];
    busy = 0;

    while(1) {
        if( start ) {
            switch( function3 ) {
                case 3b001: {
                    busy = 1;
                    ( result ) = SHFL( sourceReg1, RshiftCount );
                    busy = 0;
                }
                case 3b101: {
                    busy = 1;
                    ( result ) = UNSHFL( sourceReg1, RshiftCount );
                    busy = 0;
                }
                case 3b110: {
                    busy = 1;
                    ( result ) = BEXT( sourceReg1, sourceReg2 );
                    busy = 0;
                }
                case 3b100: { result = { sourceReg2[0,16], sourceReg1[0,16] }; }
                case 3b111: { result = { 16b0, sourceReg2[0,8], sourceReg1[0,8] }; }
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

    output! uint32  result
) <autorun> {
    uint5   RshiftCount := sourceReg2[0,5];
    busy = 0;

    while(1) {
        if( start ) {
            switch( function3 ) {
                case 3b001: { result = SBSCIoutput; }
                default: {
                    busy = 1;
                    ( result ) = GREV( sourceReg1, RshiftCount );
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

    output! uint32  result
) <autorun> {
    uint5   RshiftCount := sourceReg2[0,5];
    busy = 0;

    while(1) {
        if( start ) {
            switch( function3 ) {
                case 3b001: { result = SBSCIoutput; }
                case 3b100: { result = { sourceReg2[16,16], sourceReg1[16,16] }; }
                case 3b101: { result = sourceReg1[ RshiftCount, 1 ]; }
                case 3b110: {
                    busy = 1;
                    ( result ) = BDEP( sourceReg1, sourceReg2 );
                    busy = 0;
                }
                case 3b111: {
                    busy = 1;
                    ( result ) = BFP( sourceReg1, sourceReg2 );
                    busy = 0;
                }
            }
        }
    }
}
// BASE ADD SUB SLL SLT SLTU XOR SRL SRA OR AND + B EXTENSION ROL SLO SH1/2/3ADD XNOR ROR SRO ORN ANDN
algorithm aluR (
    input   uint1   start,
    output! uint1   busy,

    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,

    output! uint32  result
) <autorun> {
    uint5   RshiftCount := sourceReg2[0,5];

    // M EXTENSION DIVIDER
    aluMdivideremain ALUMD(
        function3 <: function3,
        dividend <: sourceReg1,
        divisor <: sourceReg2
    );

    // M EXTENSION BLOCK MULTIPLIER
    aluMmultiply ALUMM(
        function3 <: function3,
        factor_1 <: sourceReg1,
        factor_2 <: sourceReg2
    );

    // SBSET SBCLR SBINV + BARREL SHIFTERS / ROTATORS
    uint32  SBSCIoutput = uninitialized;
    singlebitops SBSCI(
        start <: start,
        sourceReg1 <: sourceReg1,
        function7 <: function7,
        shiftcount <: RshiftCount,
        result :> SBSCIoutput
    );
    BSHIFTleft barrelLEFT(
        start <: start,
        sourceReg1 <: sourceReg1,
        function7 <: function7,
        shiftcount <: RshiftCount,
    );
    BSHIFTright barrelRIGHT(
        start <: start,
        sourceReg1 <: sourceReg1,
        function7 <: function7,
        shiftcount <: RshiftCount,
    );
    BROTATE barrelROTATE(
        start <: start,
        sourceReg1 <: sourceReg1,
        function3 <: function3,
        shiftcount <: RshiftCount,
    );

    // B EXTENSION GORC XPERM + SBET ( sbset is single cycle but shares same function7 coding as GORC XPERM )
    aluR7b0010100 ALUR7b0010100(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        SBSCIoutput <: SBSCIoutput
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
        sourceReg2 <: sourceReg2
    );
    // B EXTENSION GREV + SBINV ( sbinv is single cycle but shares same function7 coding as GREV )
    aluR7b0110100 ALUR7b0110100(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        SBSCIoutput <: SBSCIoutput

    );
    // B EXTENSION BDEP BFP + PACKU SBCLR SBEXT ( packu, sbclr and sbext are single cycle share share same function7 coding as BDEP BFP )
    aluR7b0100100 ALUR7b0100100(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        SBSCIoutput <: SBSCIoutput

    );

    // START FLAGS FOR ALU SUB BLOCKS
    ALUMD.start := 0;
    ALUMM.start := 0;
    ALUR7b0010100.start := 0;
    ALUR7b0000101.start := 0;
    ALUR7b0000100.start := 0;
    ALUR7b0110100.start := 0;
    ALUR7b0100100.start := 0;
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
                            // ROL SLL SLO
                            switch( function7 ) {
                                case 7b0110000: { result = barrelROTATE.result; }
                                default: { result = barrelLEFT.result; }
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
                                default: { result = sourceReg1 ^ ( function7[5,1] ? ~sourceReg2 : sourceReg2 ); }
                            }
                        }
                        case 3b101: {
                            // ROR SRL SRA SRO
                            switch( function7 ) {
                                case 7b0110000: { result = barrelROTATE.result; }
                                default:  { result = barrelRIGHT.result; }
                            }
                        }
                        case 3b110: {
                            // SH3ADD OR ORN
                            switch( function7 ) {
                                case 7b0010000: { result = { sourceReg1[3,29], 3b000 } + sourceReg2; }
                                default: { result = sourceReg1 | ( function7[5,1] ? ~sourceReg2 : sourceReg2 ); }
                            }
                        }
                        case 3b111: {
                            // AND ANDN
                            result = sourceReg1 & ( function7[5,1] ? ~sourceReg2 : sourceReg2 );
                        }
                    }
                }
            }
        }
    }
}


// RISC-V MANDATORY CSR REGISTERS
algorithm CSRblock(
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
    CSRcycletime := CSRcycletime + ~SMT;
    CSRinstret := CSRinstret + ( incCSRinstret & (~SMT) );
    CSRcycletimeSMT := CSRcycletime + SMT;
    CSRinstretSMT := CSRinstret + ( incCSRinstret & (SMT) );

    while(1) {
        if( ( CSR(instruction).opcode == 7b1110011 ) && ( CSR(instruction).rs1 == 0 ) && ( CSR(instruction).function3 == 3b010 ) ) {
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
    input   uint7   opCode,
    input   uint7   function7,
    input   uint32  memoryinput,
    input   uint32  sourceReg2,

    output! uint32  result
) <autorun> {
    while(1) {
        if( opCode == 7b0101111 ) {
            switch( function7[2,5] ) {
                case 5b00000: { result = memoryinput + sourceReg2; }                                                        // AMOADD
                case 5b00001: { result = sourceReg2; }                                                                      // AMOSWAP
                case 5b00100: { result = memoryinput ^ sourceReg2; }                                                        // AMOXOR
                case 5b01000: { result = memoryinput | sourceReg2; }                                                        // AMOOR
                case 5b01100: { result = memoryinput & sourceReg2; }                                                        // AMOAND
                case 5b10000: { result = __signed( memoryinput ) < __signed( sourceReg2 ) ? memoryinput : sourceReg2; }     // AMOMIN
                case 5b10100: { result = __signed( memoryinput ) > __signed( sourceReg2 ) ? memoryinput : sourceReg2; }     // AMOMAX
                case 5b11000: { result = __unsigned( memoryinput ) < __unsigned( sourceReg2 ) ? memoryinput : sourceReg2; } // AMOMINU
                case 5b11100: { result = __unsigned( memoryinput ) > __unsigned( sourceReg2 ) ? memoryinput : sourceReg2; } // AMOMAXU
            }
        }
    }
}
