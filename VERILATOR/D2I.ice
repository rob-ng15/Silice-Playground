// BITFIELD FOR FLOATING POINT NUMBER - IEEE-754 32 bit format
bitfield fp32{
    uint1   sign,
    uint8   exponent,
    uint23  fraction
}
// BITFIELD FOR FLOATING POINT NUMBER - IEEE-754 64 bit format
bitfield fp64{
    uint1   sign,
    uint11  exponent,
    uint52  fraction
}

// IDENTIFY { infinity, signalling NAN, quiet NAN, ZERO }
// CHECKS FOR NAN-BOXING OF FLOAT
unit typeF(
    input   uint1   df,
    input   uint64  a,
    output  uint4   type
) <reginputs> {
    uint1   expFF <:: df ? &fp64(a).exponent : &fp32(a).exponent;                                                               // CHECK FOR EXP = ALL 1s ( signals INF/NAN )
    uint1   zeroFRACTION <:: df ? ~|fp64(a).fraction : ~|fp32(a).fraction;                                                      // FRACTION == 0, INF, == 100... qNAN, == 0xxx... ( xxx... != 0 ) sNAN
    uint1   boxed <:: &a[32,32];                                                                                                // NAN-boxing, upper 32 bits all 1s

    always_after {
        type = df ? { expFF & zeroFRACTION,                                                                                     // INF
                      expFF & ~fp32(a).fraction[51,1] & ~zeroFRACTION,                                                          // sNAN
                      expFF & fp32(a).fraction[51,1],                                                                           // qNAN
                      ~|( fp64(a).exponent ) } :                                                                                  // ZERO / SUBNORMAL
               boxed ?
                    { expFF & zeroFRACTION,                                                                                     // INF
                      expFF & ~fp32(a).fraction[22,1] & ~zeroFRACTION,                                                          // sNAN
                      expFF & fp32(a).fraction[22,1],                                                                           // qNAN
                      ~|( fp32(a).exponent ) } :                                                                                // ZERO / SUBNORMAL
                    4b0010;                                                                                                     // FLOAT NOT BOXED, ISSUE qNAN

    }
}

unit double2int(
    input   uint1   rs2,
    input   uint64  sourceReg1F,
    input   uint4   typeAF,

    output  uint32  result,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags
) <reginputs> {
    int13   exp <:: fp64( sourceReg1F ).exponent - 1023;
    uint1   NN <:: typeAF[2,1] | typeAF[1,1];
    uint1   NV <:: ( __unsigned(exp) > ( rs2 ? 31 : 30 ) ) | ( rs2 & fp64( sourceReg1F ).sign ) | typeAF[3,1] | NN;
    uint33  fraction <:: { 1b1, sourceReg1F[20,32] };
    uint33  sig <:: ( __unsigned(exp) < 24 ) ? fraction >> ( 23 - exp ) : fraction << ( exp - 24);
    uint32  unsignedfraction <:: ( sig[1,32] + sig[0,1] );

    always_after {
        {
            if( typeAF[0,1] ) {
                result = 0;
            } else {
                if( rs2 ) {
                    if( typeAF[3,1] | NN ) {
                        result = NN ? 32hffffffff : fp64( sourceReg1F ).sign ? 0 :  32hffffffff;
                    } else {
                        result = ( fp64( sourceReg1F ).sign ) ? 0 : NV ? 32hffffffff : unsignedfraction;
                    }
                } else {
                    if( typeAF[3,1] | NN ) {
                        result = NN ? 32h7fffffff : fp64( sourceReg1F ).sign ? 32h80000000 : 32h7fffffff;
                    } else {
                        result = NV ? { {32{~fp64( sourceReg1F ).sign}} } : fp64( sourceReg1F ).sign ? -unsignedfraction : unsignedfraction;
                    }
                }
            }
        }
        { FPUnewflags = FPUflags | { NV, 4b0000 }; }                                            // FLAGS
    }
}


algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}

// RISC-V FPU CONTROLLER

algorithm main(output int8 leds) {
    // CYCLE COUNTER
    uint32  startcycle = uninitialised;
    pulse PULSE();

     uint7   opCode = 7b1010011; // ALL OTHER FPU OPERATIONS
    // uint7   opCode = 7b1000011; // FMADD
    // uint7   opCode = 7b1000111; // FMSUB
    // uint7   opCode = 7b1001011; // FNMSUB
    // uint7   opCode = 7b1001111; // FNMADD

    uint7   function7 = 7b0001100; // OPERATION SWITCH - LSB = DF
    // ADD = 7b000000x SUB = 7b000010x MUL = 7b000100x DIV = 7b000110x SQRT = 7b010110x
    // FSGNJ[N][X] = 7b001000x function3 == 000 FSGNJ == 001 FSGNJN == 010 FSGNJX
    // MIN MAX = 7b001010x function3 == 000 MIN == 001 MAX
    // LE LT EQ = 7b101000x function3 == 000 LE == 001 LT == 010 EQ
    // FCVT.W[U].S floatto[u]int = 7b110000x rs2 == 00000 FCVT.W.S == 00001 FCVT.WU.S
    // FCVT.S.W[U] [u]inttofloat = 7b110100x rs2 == 00000 FCVT.S.W == 00001 FCVT.S.WU

    uint3   function3 = 3b000; // ROUNDING MODE OR SWITCH
    uint5   rs1 = 5b00000; // SOURCEREG1 number
    uint5   rs2 = 5b00000; // SOURCEREG2 number OR SWITCH

    uint32  sourceReg1 = 1000000000; // INTEGER SOURCEREG1
    uint32  abssourceReg1 <:: sourceReg1[31,1] ? -sourceReg1 : sourceReg1;

    // -5 = 32hC0A00000
    // -0 = 32h80000000
    // 0 = 0
    // 0.85471 = 32h3F5ACE46
    // 1/3 = 32h3eaaaaab
    // 1 = 32h3F800000
    // 2 = 32h40000000
    // 3 = 32h40400000
    // 10 = 32h41200000
    // 50 = 32h42480000
    // 99 = 32h42C60000
    // 100 = 32h42C80000
    // 2.658456E38 = 32h7F480000
    // NaN = 32hffffffff
    // qNaN = 32hffc00000
    // INF = 32h7F800000
    // -INF = 32hFF800000
    uint64  sourceReg1F = 64hffffffff40000000;
    uint64  sourceReg2F = 64hffffffff3eaaaaab;
    uint64  sourceReg3F = 64hffffffff40400000;
    //uint64  sourceReg1F = 64h4000000000000000;
    //uint64  sourceReg2F = 64h4008000000000000;
    //uint64  sourceReg3F = 64h4008000000000000;

    uint1   TRUE = 1;
    uint1   FALSE = 0;

    uint64  result = uninitialised;
    uint1   frd = uninitialised;

    uint5   FPUflags = 5b00000;
    uint5   FPUnewflags = uninitialised;

    typeF typeAF( df <: function7[0,1], a <: sourceReg1F );

    double2int FPUDINT( FPUflags <: FPUflags, rs2 <: rs2[0,1], sourceReg1F <: sourceReg1F, typeAF <: typeAF.type );

    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++: ++: ++:

    __display("DOUBLE 2 INT = %x { %b } { %b }",FPUDINT.result,FPUDINT.result,FPUDINT.FPUnewflags);
}
