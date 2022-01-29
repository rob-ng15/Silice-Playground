// From recursive Verilog module
// https://electronics.stackexchange.com/questions/196914/verilog-synthesize-high-speed-leading-zero-count

// ALU FOR MULTIPLICATION
// UNSIGNED / SIGNED 32 by 32 bit multiplication giving 64 bit product using DSP blocks
algorithm douintmul(
    input   uint32  factor_1,
    input   uint32  factor_2,
    input   uint1   productsign,
    output  uint64  product64,
) <autorun> {
    uint64  product <:: factor_1 * factor_2;
    always_after {
        product64 = productsign ? -product : product;
    }
}

algorithm aluMM(
    input   uint2   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    input   uint32  abssourceReg1,
    input   uint32  abssourceReg2,
    output  uint32  result
) <autorun> {
    uint1   doupper <:: |function3;
    uint2   dosigned = uninitialised;

    uint1   productsign <:: &dosigned ? ( sourceReg1[31,1] ^ sourceReg2[31,1] ) : |dosigned ? sourceReg1[31,1] : 0;
    uint32  sourceReg1_unsigned <:: dosigned[0,1] ? abssourceReg1 : sourceReg1;
    uint32  sourceReg2_unsigned <:: dosigned[1,1] ? abssourceReg2 : sourceReg2;

    douintmul UINTMUL( factor_1 <: sourceReg1_unsigned, factor_2 <: sourceReg2_unsigned, productsign <: productsign );

    always_after {
        // SELECT SIGNED/UNSIGNED OF INPUTS
        switch( function3 ) {
            case 2b00: { dosigned = 2b11; }
            case 2b01: { dosigned = 2b11; }
            case 2b10: { dosigned = 2b01; }
            case 2b11: { dosigned = 2b00; }
        }
        // SELECT HIGH OR LOW PART
        result = UINTMUL.product64[ { doupper, 5b0 }, 32 ];
    }
}

algorithm main(output uint8 leds)
{
    int32   sourceReg1 = -100000;
    int32   sourceReg2 = -100000;

    uint32  abssourceReg1 <: sourceReg1[31,1] ? -sourceReg1 : sourceReg1;
    uint32  abssourceReg2 <: sourceReg2[31,1] ? -sourceReg2 : sourceReg2;

    // 2b00 = MUL, 2b01 = MULH, 2b10 = MULHSU, 2b11 = MULHU
    uint2   function3 = 2b11;

    aluMM MUL( function3 <: function3, sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2,
                                        abssourceReg1 <: abssourceReg1, abssourceReg2 <: abssourceReg2 );

   ++: ++: ++: ++: ++: ++: ++: ++:
   __display("");
   __display("Risc-V Multiplication Unit Test");
   __display("");
   __display("sourceReg1 = %d { %x }, abssourceReg1 = %d",sourceReg1,sourceReg1,abssourceReg1);
   __display("sourceReg2 = %d { %x }, abssourceReg2 = %d",sourceReg2,sourceReg2,abssourceReg2);
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
