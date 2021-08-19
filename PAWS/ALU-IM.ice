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

algorithm aluR(
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  LSHIFToutput,
    input   uint32  RSHIFToutput,
    output  uint32  result
) <autorun> {
    always {
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

    // BASE REGISTER + REGISTER ALU OPERATIONS
    int32   ALURresult = uninitialized;
    aluR ALUR(
        function3 <: function3,
        function7 <: function7,
        rs1 <: rs1,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        LSHIFToutput <: LSHIFToutput,
        RSHIFToutput <: RSHIFToutput,
        result :> ALURresult
    );

    // M EXTENSION ALU OPERATIONS
    int32   ALUMresult = uninitialized;
    uint1   ALUMstart = uninitialized;
    uint1   ALUMbusy = uninitialized;
    aluM ALUM(
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        start <: ALUMstart,
        busy :> ALUMbusy,
        result :> ALUMresult
    );
    ALUMstart := 0;

    while(1) {
        if( start ) {
            // SELECT ALUI or ALUR
            busy = 1;
            if( opCode[5,1] ) {
                if( function7[0,1] ) {
                    ALUMstart = 1; while(  ALUMbusy ) {} result = ALUMresult;
                } else {
                    result = ALURresult;
                }
            } else {
                result = ALUIresult;
            }
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
