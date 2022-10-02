// ALU FOR MULTIPLICATION
// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
algorithm douintmul(
    input   int33   factor_1,
    input   int33   factor_2,
    output  int66   product
) <autorun> {
    always_after {
        product = factor_1 * factor_2;
    }
}

algorithm aluMM(
    input   uint2   function3,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    output  int32   result
) <autorun> {
    uint1   doupper <:: |function3;
    uint2   dosigned = uninitialised;

    int33   factor_1 <:: { dosigned[0,1] ? sourceReg1[ 31, 1 ] : 1b0, sourceReg1 }; // SIGN EXTEND IF SIGNED MULTIPLY
    int33   factor_2 <:: { dosigned[1,1] ? sourceReg2[ 31, 1 ] : 1b0, sourceReg2 }; // SIGN EXTEND IF SIGNED MULTIPLY

    douintmul UINTMUL( factor_1 <: factor_1, factor_2 <: factor_2 );

    always_after {
        // SELECT SIGNED/UNSIGNED OF INPUTS
        switch( function3 ) {
            case 2b00: { dosigned = 2b11; } // MUL ( for both signed x signed and unsigned x unsigned )
            case 2b01: { dosigned = 2b11; } // MULH ( upper 32 bits for signed x signed )
            case 2b10: { dosigned = 2b01; } // MULHSU ( upper 32 bits for signed x unsigned )
            case 2b11: { dosigned = 2b00; } // MULHU ( upper 32 bits for unsigned x unsigned )
        }
        // SELECT HIGH OR LOW PART
        result = UINTMUL.product[ { doupper, 5b0 }, 32 ];

        __display("  %d %x { %b } x",factor_1,factor_1,factor_1);
        __display("  %d %x { %b } x",factor_2,factor_2,factor_2);
        __display("= %d %x { %b } x",UINTMUL.product,UINTMUL.product,UINTMUL.product);

    }
}

algorithm main(output uint8 leds)
{
    int32   sourceReg1 = 32hffff8000;
    int32   sourceReg2 = 32h00108000;

    // 2b00 = MUL, 2b01 = MULH, 2b10 = MULHSU, 2b11 = MULHU
    uint2   function3 = 2b01;

    aluMM MUL( function3 <: function3, sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2 );

   ++: ++:
   __display("");
   __display("Risc-V Multiplication Unit Test");
   __display("");
   __display("sourceReg1 = %d { %x }",sourceReg1,sourceReg1);
   __display("sourceReg2 = %d { %x }",sourceReg2,sourceReg2);
   __display("");
   switch( function3 ) {
       case 2b00: { __display("MUL"); }
       case 2b01: { __display("MULH"); }
       case 2b10: { __display("MULHSU"); }
       case 2b11: { __display("MULHU"); }
   }
   __display("");
   __display("Result = %d { %x } { %b }",MUL.result,MUL.result,MUL.result);
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
