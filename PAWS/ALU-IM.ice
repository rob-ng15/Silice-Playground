algorithm aluI(
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   IshiftCount,
    input   uint32  sourceReg1,
    input   uint32  immediateValue,
    input   uint32  LSHIFToutput,
    input   uint32  RSHIFToutput,
    output  uint32  result
) <autorun> {
    always {
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
    }
}

algorithm aluR (
    input   uint1   start,
    output  uint1   busy(0),
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
    int32   ALUMDresult = uninitialized;
    aluMdivideremain ALUMD(
        dosign <: function3,
        dividend <: sourceReg1,
        divisor <: sourceReg2,
        result :> ALUMDresult
    );
    int32   ALUMMresult = uninitialized;
    aluMmultiply ALUMM(
        dosign <: function3,
        factor_1 <: sourceReg1,
        factor_2 <: sourceReg2,
        result :> ALUMMresult
    );

    ALUMD.start := 0;
    while(1) {
        if( start ) {
            busy = 1;
            switch( function7 ) {
                // M EXTENSION MULTIPLICATION AND DIVISION
                case 7b0000001: {
                    switch( function3[2,1] ) {
                        case 1b0: { result = ALUMMresult; }
                        case 1b1: { ALUMD.start = 1; while( ALUMD.busy ) {} result = ALUMDresult; }
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
    output  uint1   busy(0),

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

    // BASE REGISTER + IMMEDIATE ALU OPERATIONS
    int32   ALUIresult = uninitialized;
    aluI ALUI(
       function3 <: function3,
        function7 <: function7,
        IshiftCount <: IshiftCount,
        sourceReg1 <: sourceReg1,
        immediateValue <: immediateValue,
        LSHIFToutput <: LSHIFToutput,
        RSHIFToutput <: RSHIFToutput,
        result :> ALUIresult
    );

    // BASE REGISTER & REGISTER ALU OPERATIONS
    int32   ALURresult = uninitialized;
    uint1   ALURstart = uninitialized;
    uint1   ALURbusy = uninitialized;
    aluR ALUR(
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        sourceReg3 <: sourceReg3,
        LSHIFToutput <: LSHIFToutput,
        RSHIFToutput <: RSHIFToutput,
        result :> ALURresult,
        start <: ALURstart,
        busy :> ALURbusy
    );

    // ALU START FLAGS
    ALURstart := 0;

    while(1) {
        if( start ) {
            // START ALUI or ALUR
            busy = 1;
            ALURstart = opCode[5,1]; while(  ALURbusy ) {}
            result = opCode[5,1] ? ALURresult : ALUIresult;
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
   always {
        result = sourceReg1 << shiftcount;
    }
}
algorithm BSHIFTright(
    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint7   function7,
    output  uint32  result
) <autorun> {
    always {
        switch( function7[5,1] ) {
            case 1b0: { result = sourceReg1 >> shiftcount; }
            default: { result = __signed(sourceReg1) >>> shiftcount; }
        }
    }
}
