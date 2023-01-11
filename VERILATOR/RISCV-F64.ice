// Rob Shelton ( @robng15 Twitter, @rob-ng15 GitHub )
// Simple 32bit FPU calculation/conversion routines
// Designed for as small as FPGA usage as possible,
// not for speed.
//
// Copyright (c) 2021 Rob Shelton
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Donated to Silice by @sylefeb
// MIT license, see LICENSE_MIT in Silice repo root
//
// Parameters for calculations: ( 32 bit float { sign, exponent, mantissa } format )
// addsub, multiply and divide a and b ( as floating point numbers ), addsub flag == 0 for add, == 1 for sub
//
// Parameters for conversion:
// intotofloat a as 32 bit integer, dounsigned == 1 dounsigned, == 0 signed conversion
// floattouint and floattoint a as 32 bit float
//
// Control:
// start == 1 to start operation
// busy gives status, == 0 not running or complete, == 1 running
//
// Output:
// result gives result of conversion or calculation
//
// NB: Error states are those required by Risc-V floating point

// CLZ CIRCUITS - TRANSLATED BY @sylefeb
// From recursive Verilog module
// https://electronics.stackexchange.com/questions/196914/verilog-synthesize-high-speed-leading-zero-count

// Create a LUA pre-processor function that recursively writes
// circuitries counting the number of leading zeros in variables
// of decreasing width.
// Note: this could also be made in-place without wrapping in a
// circuitry, directly outputting a hierarchical set of trackers (<:)
$$function generate_clz(name,w_in,recurse)
$$ local w_out = clog2(w_in)
$$ local w_h   = w_in//2
$$ if w_in > 2 then generate_clz(name,w_in//2,1) end
circuitry $name$_$w_in$ (input in,output out)
{
$$ if w_in == 2 then
   out = !in[1,1];
$$ else
   uint$clog2(w_in)-1$ half_count = uninitialized;
   uint$w_h$           lhs        = in[$w_h$,$w_h$];
   uint$w_h$           rhs        = in[    0,$w_h$];
   uint1               left_empty = ~|lhs;
   uint$w_h$           select     = left_empty ? rhs : lhs;
   (half_count) = $name$_$w_h$(select);
   out          = {left_empty,half_count};
$$ end
}
$$end

// Produce a circuit for 32 bits numbers ( and 16, 8, 4, 2 )
$$generate_clz('clz_silice',64)


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
// REFERENCE RISC-V FLOATING POINT FLAGS
bitfield floatingpointflags{
    uint1   NV,     // Result is not valid,
    uint1   DZ,     // Divide by zero
    uint1   OF,     // Result overflowed
    uint1   UF,     // Result underflowed
    uint1   NX      // Not exact ( integer to float conversion caused bits to be dropped )
}

// FMIN.S FMAX.S FSGNJ.S FSGNJN.S FSGNJX.S FEQ.S FLT.S FLE.S FCLASS.S FMV.X.W
unit fpuSINGLECYCLE(
    input   uint1   df,
    input   uint2   function3,
    input   uint5   function7,
    input   uint32  sourceReg1,
    input   uint64  sourceReg1F,
    input   uint64  sourceReg2F,
    input   uint4   typeAF,
    input   uint4   typeBF,

    output  uint64  result,
    output  uint1   frd,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags
) <reginputs> {
    floatcompare FPUlteq( df <: df, a <: sourceReg1F, b <: sourceReg2F, typeAF <: typeAF, typeBF <: typeBF );

    uint1   NAN <:: |( typeAF[1,2] | typeBF[1,2] );
    uint1   TRUEZERO <:: ~|( df ? fp64( sourceReg1F ).fraction : fp32( sourceReg1F ).fraction );
    uint3   LTEQ <:: { FPUlteq.equal, FPUlteq.less, FPUlteq.less | FPUlteq.equal };

    uint1   sign1F <:: df ? fp64( sourceReg1F ).sign : fp32( sourceReg1F ).sign;
    uint1   sign2F <:: df ? fp64( sourceReg2F ).sign : fp32( sourceReg2F ).sign;

    uint64  qNAN <:: df ? 64h7FF8000000000000 : 32h7fc00000;

    uint10  FCLASS <:: {    typeAF[1,1],                                                                          // 512  qNAN
                            typeAF[2,1],                                                                          // 256  sNAN
                            typeAF[3,1] & ~sign1F,                                                                // 128  +INF
                            ~|typeAF & ~sign1F,                                                                   // 64   +NORMAL
                            typeAF[0,1] & ~sign1F & ~TRUEZERO,                                                    // 32   +SUBNORMAL
                            typeAF[0,1] & ~sign1F & TRUEZERO,                                                     // 16   +0
                            typeAF[0,1] & sign1F & TRUEZERO,                                                      // 8    -0
                            typeAF[0,1] & sign1F & ~TRUEZERO,                                                     // 4    -SUBNORMAL
                            ~|typeAF & sign1F,                                                                    // 2    -NORMAL
                            typeAF[3,1] & sign1F                                                                  // 1    -INF
            };
    uint64  MINMAX <:: df ? NAN ? qNAN : typeAF[1,1] ? ( typeBF[1,1] ? qNAN : sourceReg2F ) : typeBF[1,1] | ( function3[0,1] ^ FPUlteq.less ) ? sourceReg1F : sourceReg2F :
                            { 32hffffffff, NAN ? qNAN[0,32] : typeAF[1,1] ? ( typeBF[1,1] ? qNAN[0,32] : sourceReg2F[0,32] ) :
                                                              typeBF[1,1] | ( function3[0,1] ^ FPUlteq.less ) ? sourceReg1F[0,32] : sourceReg2F[0,32] };

    uint5   flagsMINMAX <:: { NAN, 4b0000 };
    uint1   COMPARE <:: ~NAN & LTEQ[ function3, 1 ];
    uint5   flagsCOMPARE <:: { function3[1,1] ? ( typeAF[2,1] | typeBF[2,1] ) : NAN, 4b0000 };
    uint64  SIGN <:: df ? { function3[1,1] ? sign1F ^ sign2F : function3[0,1] ^ sign2F, sourceReg1F[0,63] } :
                          { 32hffffffff, function3[1,1] ? sign1F ^ sign2F: function3[0,1] ^ sign2F, sourceReg1F[0,31] };

    always_after {
        {
            switch( function7[3,2] ) {                                                                                          // RESULT
                case 2b00: { result = function7[0,1] ? MINMAX : SIGN; }                                                         // FMIN FMAX FSGNJ FSGNJN FSGNJX ( NAN BOXED FOR FLOAT )
                case 2b10: { result = COMPARE; }                                                                                // FEQ FLT FLE
                default: { result = function7[1,1] ? { df ? 32h00000000 : 32hffffffff, sourceReg1 } :                           // FCLASS FMV.X.W FMV.W.X
                                    function3[0,1] ? FCLASS : sourceReg1F[0,32]; }
            }
        }
        {
            switch( function7[3,2] ) {                                                                                          // FLAGS
                case 2b00: { FPUnewflags = FPUflags | ( function7[0,1] ? flagsMINMAX : 0 ); }                                   // FMIN.S FMAX.S FSGNJ.S FSGNJN.S FSGNJX.S
                case 2b10: { FPUnewflags = FPUflags | flagsCOMPARE; }                                                           // FEQ.S FLT.S FLE.S
                default: { FPUnewflags = FPUflags; }                                                                            // FCLASS.S FMV.X.W FMV.W,X
            }
        }
        { frd = function7[3,1] ? function7[1,1] : ~|function7[3,2]; }                                                           // FRD for FMIN.S FMAX.S FSGNJ.S FSGNJN.S FSGNJX.S AND FMV.W.X
    }
}

// FCVT.W.S FCVT.WU.S FCVT.S.W FCVT.S.WU
unit clz32(
    input   uint32  number,
    output! uint5   zeros
) <reginputs> {
    always_after {
        ( zeros ) = clz_silice_32( number );
    }
}
unit int2float(
    input   uint1   rs2,
    input   uint32  sourceReg1,
    input   uint32  abssourceReg1,

    output  uint64  result,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags
) <reginputs> {
    // COUNT LEADING ZEROS - RETURNS NX IF NUMBER IS TOO LARGE, LESS THAN 8 LEADING ZEROS
    clz32 CLZ( number <: number );
    uint1   sign <:: ~rs2 & sourceReg1[31,1];
    uint32  number <:: sign ? abssourceReg1 : sourceReg1;
    uint1   NX <:: ( ~|CLZ.zeros[3,2] );
    int10   exponent <:: 158 - CLZ.zeros;
    int23   fraction <:: NX ? number >> ( 8 - CLZ.zeros ) : number << ( CLZ.zeros - 8 );

    always_after {
        { result = ( |sourceReg1 ) ? { 32hffffffff, sign, exponent[0,8], fraction } : 64hffffffff00000000; }                    // RESULT NAN BOXED
        { FPUnewflags = FPUflags | { 4b0, NX }; }                                                                               // FLAGS
    }
}
unit float2int(
    input   uint1   rs2,
    input   uint32  sourceReg1F,
    input   uint4   typeAF,

    output  uint32  result,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags
) <reginputs> {
    int10   exp <:: fp32( sourceReg1F ).exponent - 127;
    uint1   NN <:: typeAF[2,1] | typeAF[1,1];
    uint1   NV <:: ( exp > ( rs2 ? 31 : 30 ) ) | ( rs2 & fp32( sourceReg1F ).sign ) | typeAF[3,1] | NN;
    uint33  fraction <:: { 9b1, fp32( sourceReg1F ).fraction, 1b0 };
    uint33  sig <:: ( exp < 24 ) ? fraction >> ( 23 - exp ) : fraction << ( exp - 24);
    uint32  unsignedfraction <:: ( sig[1,32] + sig[0,1] );

    always_after {
        {
            if( typeAF[0,1] ) {
                result = 0;
            } else {
                if( rs2 ) {
                    if( typeAF[3,1] | NN ) {
                        result = NN ? 32hffffffff : fp32( sourceReg1F ).sign ? 0 :  32hffffffff;
                    } else {
                        result = ( fp32( sourceReg1F ).sign ) ? 0 : NV ? 32hffffffff : unsignedfraction;
                    }
                } else {
                    if( typeAF[3,1] | NN ) {
                        result = NN ? 32h7fffffff : fp32( sourceReg1F ).sign ? 32h80000000 : 32h7fffffff;
                    } else {
                        result = NV ? { {32{~fp32( sourceReg1F ).sign}} } : fp32( sourceReg1F ).sign ? -unsignedfraction : unsignedfraction;
                    }
                }
            }
        }
        { FPUnewflags = FPUflags | { NV, 4b0000 }; }                                            // FLAGS
    }
}
unit int2double(
    input   uint1   rs2,
    input   uint32  sourceReg1,
    input   uint32  abssourceReg1,

    output  uint64  result,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags
) <reginputs> {
    // COUNT LEADING ZEROS - RETURNS NX IF NUMBER IS TOO LARGE, LESS THAN 8 LEADING ZEROS
    clz32 CLZ( number <: number );
    uint1   sign <:: ~rs2 & sourceReg1[31,1];
    uint32  number <:: sign ? abssourceReg1 : sourceReg1;
    int13   exponent <:: 1054 - CLZ.zeros;
    int52   fraction <:: number << ( 21 + CLZ.zeros );

    always_after {
        { result = ( |sourceReg1 ) ? { sign, exponent[0,11], fraction } : 0; }                                    // RESULT
        { FPUnewflags = FPUflags; }                                                                               // FLAGS
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
    uint1   NV <:: ( exp > ( rs2 ? 31 : 30 ) ) | ( rs2 & fp64( sourceReg1F ).sign ) | typeAF[3,1] | NN;
    uint33  fraction <:: { 1b1, sourceReg1F[20,32] };
    uint33  sig <:: ( __unsigned(exp) < 24 ) ? fraction >> ( 32 - exp ) : fraction << ( exp - 33 );
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
unit float2double(
    input   uint64  sourceReg1F,
    input   uint4   typeAF,

    output  uint64  result,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags
) <reginputs> {
    int13   exp <:: fp32( sourceReg1F ).exponent - 127 + 1023;

    always_after {
        {
            switch( typeAF ) {
                default: { result = { fp32( sourceReg1F ).sign, exp[0,11], fp32( sourceReg1F ).fraction, 29b0 }; }
                case 4b1000: { result = 63h7FF0000000000000; }
                case 4b0100: { result = 64h7FF4000000000000; }
                case 4b0010: { result = 64h7FF8000000000000; }
                case 4b0001: { result = { fp32( sourceReg1F ).sign, 63h0 }; }
            }
        }
        { FPUnewflags = FPUflags; }                                            // FLAGS
    }
}
unit double2float(
    input   uint64  sourceReg1F,
    input   uint4   typeAF,

    output  uint64  result,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags
) <reginputs> {
    int13   exp <:: fp64( sourceReg1F ).exponent - 1023 + 127;

    always_after {
        {
            switch( typeAF ) {
                default: {
                    if( exp > 254 ) {
                        result = { 32hffffffff, fp64( sourceReg1F ).sign, 31h7f800000 };
                    } else {
                        if( exp < ( -127 ) ) {
                            result = { 32hffffffff, fp64( sourceReg1F ).sign, 31h0 };
                        } else {
                            result = { 32hffffffff, fp64( sourceReg1F ).sign, exp[0,8], fp64( sourceReg1F ).fraction[29,23] };
                        }
                    }
                }
                case 4b1000: { result = { 32hffffffff, fp64( sourceReg1F ).sign, 31h7f800000 }; }
                case 4b0100: { result = 64hffffffff7fa00000; }
                case 4b0010: { result = 64hffffffff7fc00000; }
                case 4b0001: { result = { 32hffffffff, fp64( sourceReg1F ).sign, 31h0 }; }
            }
        }
        { FPUnewflags = FPUflags; }                                            // FLAGS
    }
}
// FPU CALCULATION BLOCKS FUSED ADD SUB MUL DIV SQRT
unit floatcalc(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint1   df,
    input   uint5   opCode,
    input   uint5   function7,
    input   uint64  sourceReg1F,
    input   uint64  sourceReg2F,
    input   uint64  sourceReg3F,
    input   uint4   typeAF,
    input   uint4   typeBF,
    input   uint4   typeCF,

    input   uint5   FPUflags,
    output  uint5   FPUnewflags,
    output  uint64  result
) <reginputs> {
    // CLASSIFY THE RESULT OF MULTIPLICATION
    typeF typeMF( df <: df, a <: FPUmultiply.result );

    // ADD/SUB/MULT have changeable inputs due to 2 input and 3 input fused operations
    floataddsub FPUaddsub( df <: df, OF <: MAKERESULT.OF, UF <: MAKERESULT.UF, combined <: MAKERESULT.combined );
    floatmultiply FPUmultiply( df <: df, a <: sourceReg1F, b <: sourceReg2F, typeAF <: typeAF, typeBF <: typeBF, OF <: MAKERESULT.OF, UF <: MAKERESULT.UF, combined <: MAKERESULT.combined );
    floatdivide FPUdivide( df <: df, a <: sourceReg1F, b <: sourceReg2F, typeAF <: typeAF, typeBF <: typeBF, OF <: MAKERESULT.OF, UF <: MAKERESULT.UF, combined <: MAKERESULT.combined );
    floatsqrt FPUsqrt( df <: df, a <: sourceReg1F, typeAF <: typeAF, OF <: MAKERESULT.OF, UF <: MAKERESULT.UF, combined <: MAKERESULT.combined );

    // NORMALISE RESULT OF ADD SUB DIV
    donormal DONORMAL( df <: df, exp <: FPUaddsub.tonormaliseexp );

    // ROUNDING AND COMBINING OF FINAL RESULTS
    doroundcombine MAKERESULT( df <: df );

    // UNIT BUSY FLAG
    uint4   unitbusy <:: { FPUsqrt.busy, FPUdivide.busy, FPUmultiply.busy, FPUaddsub.busy };
    uint1   isbusy <:: |unitbusy;

    FPUaddsub.start := 0; FPUmultiply.start := 0; FPUdivide.start := 0; FPUsqrt.start := 0;

    algorithm <autorun> {
        while(1) {
            if( start ) {
                busy = 1;
                if( opCode[2,1] ) {
                    switch( function7[0,2] ) {                                                                          // START 2 REGISTER FPU OPERATIONS
                        default: { FPUaddsub.start = 1; }                                                               // FADD.S FSUB.S
                        case 2b10: { FPUmultiply.start = 1; }                                                           // FMUL.S
                        case 2b11: { FPUsqrt.start = function7[3,1]; FPUdivide.start = ~function7[3,1]; }               // FSQRT.S // FDIV.S
                    }
                    while( isbusy ) {}                                                                                  // WAIT FOR FINISH
                } else {
                    FPUmultiply.start = 1; while( isbusy ) {}                                                           // START 3 REGISTER FUSED FPU OPERATION - MULTIPLY
                    FPUaddsub.start = 1; while( isbusy ) {}                                                             //                                        ADD / SUBTRACT
                }
                busy = 0;
            }
        }
    }

    always_after {
        // UNIT RESULT FLAGS
        uint5   flags = uninitialised;

        // PASS ADDSUB OR DIVIDE BITSTREAM TO NORMALISATION UNIT
        { DONORMAL.bitstream = opCode[2,1] & ( &function7[0,2] ) ? FPUdivide.tonormalisebitstream : FPUaddsub.tonormalisebitstream; }

        // CONTROL INPUTS TO ROUNDING AND COMBINING
        {
            if( isbusy ) {
                onehot( unitbusy ) {
                    case 0: { MAKERESULT.exponent = DONORMAL.newexponent; }
                    case 1: { MAKERESULT.exponent = FPUmultiply.productexp; }
                    case 2: { MAKERESULT.exponent = FPUdivide.quotientexp; }
                    case 3: { MAKERESULT.exponent = FPUsqrt.squarerootexp; }
                }
            }
        }
        {
            if( isbusy ) {
                onehot( unitbusy ) {
                    default: { MAKERESULT.bitstream = DONORMAL.normalfraction; }    // ADDSUB DIVIDE
                    case 1: { MAKERESULT.bitstream = FPUmultiply.normalfraction; }
                    case 3: { MAKERESULT.bitstream = FPUsqrt.normalfraction; }
                }
            }
        }
        { if( isbusy ) { MAKERESULT.sign = |( { 1b0, FPUdivide.quotientsign, FPUmultiply.productsign, FPUaddsub.resultsign } & unitbusy ); } }

        // SET INPUTS TO ADDSUB FOR SINGLE AND FUSED OPERATIONS
        {
            FPUaddsub.a = opCode[2,1] ? sourceReg1F :
                                        df ? { opCode[1,1] ^ FPUmultiply.result[63,1], FPUmultiply.result[0,63] } :
                                             { 32hffffffff, opCode[1,1] ^ FPUmultiply.result[31,1], FPUmultiply.result[0,31] };
        }
        {
            FPUaddsub.b = opCode[2,1] ? df ? { function7[0,1] ^ sourceReg2F[63,1], sourceReg2F[0,63] } : { 32hffffffff, function7[0,1] ^ sourceReg2F[31,1], sourceReg2F[0,31] }:
                                        df ? { opCode[0,1] ^ sourceReg3F[63,1], sourceReg3F[0,63] } : { 32hffffffff, opCode[0,1] ^ sourceReg3F[31,1], sourceReg3F[0,31] };
        }
        { FPUaddsub.typeAF = opCode[2,1] ? typeAF : typeMF.type; }
        { FPUaddsub.typeBF = opCode[2,1] ? typeBF : typeCF; }

        // SELECT RESULT
        {
            if( opCode[2,1] ) {                                                                                         // SINGLE OPERATION
                switch( function7[0,2] ) {
                    default: { result = FPUaddsub.result; }                                                             // FADD.S FSUB.S
                    case 2b10: { result = FPUmultiply.result; }                                                         // FMUL.S
                    case 2b11: { result = function7[3,1] ? FPUsqrt.result : FPUdivide.result; }                         // FSQRT.S FDIV.S
                }
            } else {                                                                                                    // FUSED OPERATIONS
                result = FPUaddsub.result;
            }
        }
        // SELECT FLAGS
        {
            if( opCode[2,1] ) {                                                                                         // SINGLE OPERATION
                switch( function7[0,2] ) {
                    default: { flags = FPUaddsub.flags & 5b00110; }                                                     // FADD.S FSUB.S
                    case 2b10: { flags = FPUmultiply.flags & 5b00110; }                                                 // FMUL.S
                    case 2b11: { flags = function7[3,1] ? FPUsqrt.flags & 5b00110 : FPUdivide.flags & 5b01110; }        // FSQRT.S FDIV.S
                }
            } else {                                                                                                    // FUSED OPERATIONS
                flags = ( FPUmultiply.flags & 5b10110 ) | ( FPUaddsub.flags & 5b00110 );
            }
        }
        { FPUnewflags = FPUflags | flags; }                                                                             // RETURN NEW FLAGS
    }
}

// Rob Shelton ( @robng15 Twitter, @rob-ng15 GitHub )
// Simple 32bit FPU calculation/conversion routines
// Designed for as small as FPGA usage as possible,
// not for speed.
//
// Copyright (c) 2021 Rob Shelton
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Donated to Silice by @sylefeb
// MIT license, see LICENSE_MIT in Silice repo root
//
// Parameters for calculations: ( 32 bit float { sign, exponent, mantissa } format )
// addsub, multiply and divide a and b ( as floating point numbers ), addsub flag == 0 for add, == 1 for sub
//
// Parameters for conversion:
// intotofloat a as 32 bit integer, dounsigned == 1 dounsigned, == 0 signed conversion
// floattouint and floattoint a as 32 bit float
//
// Control:
// start == 1 to start operation
// busy gives status, == 0 not running or complete, == 1 running
//
// Output:
// result gives result of conversion or calculation
//
// NB: Error states are those required by Risc-V floating point

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
                      expFF & ~fp64(a).fraction[51,1] & ~zeroFRACTION,                                                          // sNAN
                      expFF & fp64(a).fraction[51,1],                                                                           // qNAN
                      ~|( fp64(a).exponent ) } :                                                                                  // ZERO / SUBNORMAL
               boxed ?
                    { expFF & zeroFRACTION,                                                                                     // INF
                      expFF & ~fp32(a).fraction[22,1] & ~zeroFRACTION,                                                          // sNAN
                      expFF & fp32(a).fraction[22,1],                                                                           // qNAN
                      ~|( fp32(a).exponent ) } :                                                                                // ZERO / SUBNORMAL
                    4b0010;                                                                                                     // FLOAT NOT BOXED, ISSUE qNAN

    }
}

// NORMALISE A 106 BIT MANTISSA SO THAT THE MSB IS ONE, FOR ADDSUB ALSO DECREMENT THE EXPONENT FOR EACH SHIFT LEFT
// EXTRACT THE 53 (double) 24 (float) BITS FOLLOWING THE MSB (1.xxxx) FOR ROUNDING
unit clz106(
    input   uint106  bitstream,
    output! uint7   count
) <reginputs> {
    uint2   bitstream3 <:: bitstream[104,2];        uint8   bitstream2 <:: bitstream[96,8];
    uint32  bitstream1 <:: bitstream[64,32];        uint64  bitstream0 <:: bitstream[0,64];
    uint7   clz_3 = uninitialised;                  uint7   clz_2 = uninitialised;
    uint7   clz_1 = uninitialised;                  uint7   clz_0 = uninitialised;

    always_after {
        { ( clz_3 ) = clz_silice_2( bitstream3 ); }
        { ( clz_2 ) = clz_silice_8( bitstream2 ); }
        { ( clz_1 ) = clz_silice_32( bitstream1 ); }
        { ( clz_0 ) = clz_silice_64( bitstream0 ); }
        {
            count = |bitstream3 ? clz_3 :                                                                                       // COUNT LEADING ZEROS FOR NORMALISATION SHIFT
                    |bitstream2 ? clz_2 + 2 :
                    |bitstream1 ? clz_1 + 10 :
                                  clz_0 + 42;
        }
     }
}
// NORMALISE RESULT FOR ADD SUB DIVIDE
unit donormal(
    input   uint1   df,
    input   int13   exp,
    input   uint106 bitstream,
    output  int13   newexponent,
    output  uint53  normalfraction
) <reginputs> {
    // COUNT LEADING ZEROS
    uint106 temporary <:: ( bitstream << CLZ106.count );
    clz106 CLZ106( bitstream <: bitstream );

    always_after {
        { normalfraction = df ? temporary[ 52, 53 ] : { temporary[ 81, 25 ], 28b0 }; }                                                // EXTRACT 53 ( double) 24 ( float ) BITS ( 1 extra for rounding )
        { newexponent = exp - CLZ106.count; }                                                                                   // ADDSUB EXPONENT ADJUSTMENT
    }
}

// FAST NORMALISE RESULT FOR MULTIPLICATION AND SQUARE ROOT
unit fastnormal(
    input   uint1   df,
    input   uint106 tonormal,
    output  uint53  normalfraction
) <reginputs> {
    always_after {
        normalfraction = df ? tonormal[ tonormal[105,1] ? 52 : 51, 53 ] : { tonormal[ tonormal[105,1] ? 82 : 81, 24 ], 29b0 };
    }
}

// ROUND 52 ( double ) 23 ( float ) BIT FRACTION FROM NORMALISED FRACTION USING NEXT TRAILING BIT
// ADD BIAS TO EXPONENT AND ADJUST EXPONENT IF ROUNDING FORCES
// COMBINE COMPONENTS TO FLOATING POINT NUMBER - USED BY CALCULATIONS
// UNDERFLOW return 0, OVERFLOW return infinity
unit overflow(
    input   uint1   df,
    input   int13   exponent,
    output! uint1   OF
) <reginputs> {
    always_after { OF = ( exponent > ( df ? 2046 : 254 ) ); }
}
unit newexp(
    input   uint1   df,
    input   uint53  roundfraction,
    input   uint1   lsb,
    input   int13   exponent,
    output  int13   newexponent
) <reginputs> {
    always_after {
        newexponent = df ? ( ( ~|roundfraction[0,52] & lsb ) ? 1024 : 1023 ) + exponent :
                           ( ( ~|roundfraction[0,23] & lsb ) ? 128 : 127 ) + exponent;
    }
}
unit doroundcombine(
    input   uint1   df,
    input   uint1   sign,
    input   uint53  bitstream,
    input   int13   exponent,
    output! uint1   OF,
    output! uint1   UF,
    output! uint64  combined
) <reginputs> {
    uint52  roundfraction <:: df ? ( bitstream[1,52] + bitstream[0,1] ) : ( bitstream[29,23] + bitstream[28,1] );
    newexp EXP( df <: df, roundfraction <: roundfraction, exponent <: exponent );
    overflow OVER( df <: df, exponent <: EXP.newexponent, OF :> OF );

    EXP.lsb := bitstream[ df ? 0 : 28, 1 ];

    always_after {
        { UF = EXP.newexponent[12,1];  }
        { combined = EXP.newexponent[12,1] ? df ? 64h0000000000000000 : 64hffffffff00000000 :
                                             df ? { sign, OVER.OF ? 63h7FF0000000000000 : { EXP.newexponent[0,11], roundfraction } } :
                                                  { 32hffffffff, sign, OVER.OF ? 31h7f800000 : { EXP.newexponent[0,8], roundfraction[0,23] } };

        }
    }
}

// ADDSUB ADD/SUBTRACT TWO FLOATING POresult NUMBERS ( SUBTRACT ACHIEVED BY ALTERING SIGN OF SECOND INPUT )
unit equaliseexpaddsub(
    input   uint1   df,
    input   uint64  a,
    input   uint64  b,
    output  uint106 newsigA,
    output  uint106 newsigB,
    output  int13   resultexp,
) <reginputs> {
    // BREAK DOWN INITIAL float32 INPUTS - SWITCH SIGN OF B IF SUBTRACTION
    uint106 sigA <:: df ? { 2b01, fp64(a).fraction, 52b0 } : { 2b01, fp32(a).fraction, 81b0 };
    uint106 sigB <:: df ? { 2b01, fp64(b).fraction, 52b0 } : { 2b01, fp32(b).fraction, 81b0 };
    uint1   AvB <:: ( df ? fp64(a).exponent : fp32(a).exponent ) < ( df ? fp64(b).exponent : fp32(b).exponent );
    uint106 aligned <:: ( AvB ? sigA : sigB ) >> ( ( AvB ? ( df ? fp64(b).exponent : fp32(b).exponent ) : ( df ? fp64(a).exponent : fp32(a).exponent ) ) -
                                                   ( AvB ? ( df ? fp64(a).exponent : fp32(a).exponent ) : ( df ? fp64(b).exponent : fp32(b).exponent ) ) );

    always_after {
        { newsigA = AvB ? aligned : sigA; }
        { newsigB = AvB ? sigB : aligned;  }
        { resultexp = ( AvB ? ( df ? fp64(b).exponent : fp32(b).exponent ) : ( df ? fp64(a).exponent : fp32(a).exponent ) ) - ( df ? 1022 : 126 ); }
    }
}
unit dofloataddsub(
    input   uint1   df,
    input   uint1   signA,
    input   uint106 sigA,
    input   uint1   signB,
    input   uint106 sigB,
    output  uint1   resultsign,
    output  uint106 resultfraction
) <reginputs> {
    uint1   AvB <:: ( sigA > sigB );
    uint1   sign <:: ( signA ^ signB ) ? ( signA ? AvB : ~AvB ) : signA;

    always_after {
        // PERFORM ADDITION/SUBTRACTION ACCOUTING FOR INPUT AND RESULT SIGNS
        { resultsign = sign; }
        { if( signA ^ signB ) { resultfraction = ( signA ^ sign ? sigB : sigA ) - ( signA ^ sign ? sigA : sigB ); } else { resultfraction = sigA + sigB; } }
    }
}
unit floataddsub(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint1   df,
    input   uint64  a,
    input   uint64  b,
    input   uint4   typeAF,
    input   uint4   typeBF,
    output  int13   tonormaliseexp,
    output  uint106 tonormalisebitstream,
    output  uint1   resultsign,
    input   uint1   OF,
    input   uint1   UF,
    input   uint64  combined,
    output  uint5   flags,
    output  uint64  result
) <reginputs> {
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN, ZERO AND INVALID ( INF - INF )
    uint1   IF <:: ( typeAF[3,1] | typeBF[3,1] );
    uint1   NN <:: ( typeAF[2,1] | typeAF[1,1] | typeBF[2,1] | typeBF[1,1] );
    uint1   NV <:: ( typeAF[3,1] & typeBF[3,1]) & ( df ? ( fp64( a ).sign ^ fp64( b).sign ) : ( fp32( a ).sign ^ fp32( b).sign ) );
    uint2   ACTION <:: { IF | NN, typeAF[0,1] | typeBF[0,1] };

    uint64  qNAN <:: df ? 64h7FF8000000000000 : 64hffffffff7fc00000;
    uint64  ZERO <:: df ? 0 : 64hffffffff00000000;

    // EQUALISE THE EXPONENTS
    equaliseexpaddsub EQUALISEEXP( df <: df, a <: a, b <: b, resultexp :> tonormaliseexp );

    // PERFORM THE ADDITION/SUBTRACION USING THE EQUALISED FRACTIONS, 1 IS ADDED TO THE EXPONENT IN CASE OF OVERFLOW - NORMALISING WILL ADJUST WHEN SHIFTING
    dofloataddsub ADDSUB( df <: df, sigA <: EQUALISEEXP.newsigA, sigB <: EQUALISEEXP.newsigB, resultsign :> resultsign, resultfraction :> tonormalisebitstream );

    ADDSUB.signA := df ? fp64( a ).sign : fp32( a ).sign; ADDSUB.signB := df ? fp64( b ).sign : fp32( b).sign;

    algorithm <autorun> {
        while(1) {
            if( start ) {
                busy = 1;
                if( ~|ACTION & |ADDSUB.resultfraction ) {
                    // VALID RESULT, ALLOW FOR NORMALISATION AND COMBINING OF FINAL RESULT
                    ++: ++: busy = 0;
                } else { busy = 0; }
            }
        }
    }

    always_after {
        {
            switch( ACTION ) {
                case 2b00: { result = |ADDSUB.resultfraction ? combined : ZERO; }
                case 2b01: { result = (typeAF[0,1] & typeBF[0,1] ) ? ZERO : df ? ( typeBF[0,1] ? a : b ) : { 32hffffffff, typeBF[0,1] ? a[0,32] : b[0,32] }; }
                default: {
                    switch( { IF, NN } ) {
                        case 2b10: { result = NV ? qNAN : df ? ( typeAF[3,1] ? a : b ) : { 32hffffffff, typeAF[3,1] ? a[0,32] : b[0,32] }; }
                        default: { result = qNAN; }
                    }
                }
            }
        }
        { flags = { NV, 1b0, ~|ACTION & OF, ~|ACTION & UF, 1b0 }; }
    }
}

// MULTIPLY TWO FLOATING POresult NUMBERS
unit floatmultiply(
    input   uint1   df,
    input   uint1   start,
    output  uint1   busy(0),
    input   uint64  a,
    input   uint64  b,
    input   uint4   typeAF,
    input   uint4   typeBF,
    output  uint1   productsign,
    output  int13   productexp,
    output  uint53  normalfraction,
    input   uint1   OF,
    input   uint1   UF,
    input   uint64  combined,

    output  uint5   flags,
    output  uint64  result
) <reginputs> {
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN, ZERO AND INVALID ( INF x ZERO )
    uint1   ZERO <:: (typeAF[0,1] | typeBF[0,1] );
    uint1   IF <:: ( typeAF[3,1] | typeBF[3,1] );
    uint1   NN <:: ( typeAF[2,1] | typeAF[1,1] | typeBF[2,1] | typeBF[1,1] );
    uint1   NV <:: IF & ZERO;
    uint2   ACTION <:: { IF | NN, ZERO };

    uint64  qNAN <:: df ? 64h7FF8000000000000 : 64hffffffff7fc00000;
    uint64  xINF <:: df ? { productsign, 63h7FF0000000000000 } : { 32hffffffff, productsign, 31h7f800000 };

    uint106  product <:: df ? { 1b1, fp64( a ).fraction } * { 1b1, fp64( b ).fraction } :
                              { 1b1, fp32( a ).fraction, 29b0 } * { 1b1, fp32( b ).fraction, 29b0 };

    // NORMALISE THE RESULTING PRODUCT AND EXTRACT THE 24 BITS AFTER THE LEADING 1.xxxx
    fastnormal NORMAL( df <: df, tonormal <: product, normalfraction :> normalfraction );

    algorithm <autorun> {
        while(1) {
            if( start ) {
                busy = 1;
                if( ~|ACTION ) {
                    // STEPS: SETUP -> DOMUL -> NORMALISE -> ROUND -> ADJUSTEXP -> COMBINE
                    // ALLOW 2 CYCLES TO PERFORM THE MULTIPLICATION, NORMALISATION AND ROUNDING
                    ++: ++: busy = 0;
                } else { busy = 0; }
            }
        }
    }

    always_after {
        // BREAK DOWN INITIAL float32 INPUTS, PERFORM THE MULTIPLICATION, AND FIND SIGN OF RESULT AND EXPONENT OF PRODUCT ( + 1 IF PRODUCT OVERFLOWS, MSB == 1 )
        { productsign = ( df ? fp64( a ).sign : fp32( a ).sign ) ^ ( df ? fp64( b ).sign : fp32( b ).sign ); }
        { productexp = ( df ? fp64( a ).exponent : fp32( a ).exponent ) + ( df ? fp64( b ).exponent : fp32( b ).exponent )
                       - ( df ? ( product[105,1] ? 2045 : 2046 ) : ( product[105,1] ? 253 : 254 ) ); }

        {
            switch( ACTION ) {
                case 2b00: { result = combined; }
                case 2b01: { result = df ? { productsign, 63b0 } : { 32hffffffff, productsign, 31b0 }; }
                default: {
                    switch( { IF, ZERO } ) {
                        case 2b11: { result = qNAN; }
                        case 2b10: { result = NN ? qNAN : xINF; }
                        default: { result = qNAN; }
                    }
                }
            }
        }
        {  flags = { NV, 1b0, ~|ACTION & OF, ~|ACTION & UF, 1b0 }; }
    }
}

// DIVIDE TWO FLOATING POresult NUMBERS
unit dofloatdivide(
    input   uint1   df,
    input   uint1   start,
    output  uint1   busy(0),
    input   uint108 sigA,
    input   uint108 sigB,
    output  uint108 quotient(0)
) <reginputs> {
    uint7   bit(127);
    uint108 remainder = uninitialised;
    uint108 temporary <:: df ? { remainder[0,107], sigA[bit,1] } : { remainder[0,49], sigA[bit,1] };
    uint1   bitresult <:: __unsigned(temporary) >= __unsigned(sigB);
    uint108 remainderNEXT <:: __unsigned(temporary) - ( bitresult ? __unsigned(sigB) : 0 );
    uint2   normalshift <:: quotient[ df ? 107 : 49, 1 ] ? 2 : quotient[ df ? 106 : 48, 1 ];

    always_after {
        // FIND QUOTIENT AND ENSURE 48 BIT FRACTION ( ie BITS 48 and 49 clear )
        if( &bit ) {
            if( start ) { busy = 1; bit = df ? 107 : 49; quotient = 0; remainder = 0; } else { quotient = quotient[ normalshift, 106 ]; busy = 0; }
        } else {
            remainder = remainderNEXT;
            quotient[bit,1] = bitresult;
            bit = bit - 1;
        }
    }
}
unit floatdivide(
    input   uint1   df,
    input   uint1   start,
    output  uint1   busy(0),
    input   uint64  a,
    input   uint64  b,
    input   uint4   typeAF,
    input   uint4   typeBF,
    output  uint1   quotientsign,
    output  int13   quotientexp,
    output  uint106 tonormalisebitstream,
    input   uint1   OF,
    input   uint1   UF,
    input   uint64  combined,
    output  uint5   flags,
    output  uint64  result
) <reginputs> {
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN, ZERO AND DIVIDE ZERO
    uint1   IF <:: ( typeAF[3,1] | typeBF[3,1] );
    uint1   NN <:: ( typeAF[2,1] | typeAF[1,1] | typeBF[2,1] | typeBF[1,1] );
    uint2   ACTION <:: { IF | NN, typeAF[0,1] | typeBF[0,1] };

    uint64  qNAN <:: df ? 64h7FF8000000000000 : 64hffffffff7fc00000;
    uint64  xINF <:: df ? { quotientsign, 63h7FF0000000000000 } : { 32hffffffff, quotientsign, 31h7f800000 };
    uint64  xZERO <:: df ? { quotientsign, 63h0 } : { 32hffffffff, quotientsign, 63h0 };

    // PREPARE THE DIVISION, DO THE DIVISION, NORMALISE THE RESULT
    dofloatdivide DODIVIDE( df <: df, quotient :> tonormalisebitstream );

    DODIVIDE.start := start & ~|ACTION; busy := start | DODIVIDE.busy;

    always_after {
        // BREAK DOWN INITIAL float32 INPUTS AND FIND SIGN OF RESULT AND EXPONENT OF QUOTIENT ( -1 IF DIVISOR > DIVIDEND )
        // ALIGN DIVIDEND TO THE LEFT, DIVISOR TO THE RIGHT
        { quotientsign = ( df ? fp64( a ).sign : fp32( a ).sign ) ^ ( df ? fp64( b ).sign : fp32( b ).sign ); }
        {
            quotientexp = ( df ? fp64( a ).exponent : fp32( a ).exponent ) - ( df ? fp64( b ).exponent : fp32( b ).exponent )
                          - ( ( df ? fp64(b).fraction : fp32(b).fraction ) > ( df ? fp64(a).fraction : fp32(a).fraction ) ); }
        { DODIVIDE.sigA = df ? { 1b1, fp64(a).fraction, 55b0 } : { 1b1, fp32(a).fraction, 26b0 }; }
        { DODIVIDE.sigB = df ? { 56b1, fp64(b).fraction } : { 27b1, fp32(b).fraction }; }

        {
            switch( ACTION ) {
                case 2b00: { result = combined; }
                case 2b01: { result = (typeAF[0,1] & typeBF[0,1] ) ? qNAN : typeBF[0,1] ? xINF : xZERO; }
                default: { result = ( typeAF[3,1] & typeBF[3,1] ) | NN | typeBF[0,1] ? qNAN : (typeAF[0,1] | typeBF[3,1] ) ? xZERO : xINF; }
            }
        }
        { flags = { 1b0, typeBF[0,1], ~|ACTION & OF, ~|ACTION & UF, 1b0}; }
    }
}

// ADAPTED FROM https://projectf.io/posts/square-root-in-verilog/
//
// MIT License
//
// Copyright (c) 2021 Will Green, Project F
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
unit dofloatsqrt(
    input   uint1   df,
    input   uint1   start,
    output  uint1   busy(0),
    input   uint108 start_ac,
    input   uint106 start_x,
    output  uint106 squareroot
) <reginputs> {
    uint108 test_res <:: ac - { squareroot, 2b01 }; uint108 ac = uninitialised;
    uint106 x = uninitialised;
    uint7   i(105);

    busy := start | ( i != 105 );

    always_after {
        if( i == 105 ) {
            if( start ) { i = df ? 0 : 58; squareroot = 0; ac = start_ac; x = start_x; }
        } else {
            ac = { test_res[107,1] ? ac[0,105] : test_res[0,105], x[104,2] };
            squareroot = { squareroot[0,105], ~test_res[107,1] };
            x = { x[0,104], 2b00 };
            i = i + 1;
        }
    }
}
unit floatsqrt(
    input   uint1   df,
    input   uint1   start,
    output  uint1   busy(0),
    input   uint64  a,
    input   uint4   typeAF,
    output  int13   squarerootexp,
    output  uint106 normalfraction,
    input   uint1   OF,
    input   uint1   UF,
    input   uint64  combined,
    output  uint5   flags,
    output  uint64  result
) <reginputs> {
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN, ZERO AND NOT VALID
    uint1   NN <:: typeAF[2,1] | typeAF[1,1];
    uint1   NV <:: typeAF[3,1] | NN | fp32( a ).sign;
    uint1   ACTION <:: ~|{ typeAF[3,1] | NN, typeAF[0,1] | ( df ? fp64( a ).sign : fp32( a ).sign ) };

    uint64  qNAN <:: df ? 64h7FF8000000000000 : 64hffffffff7fc00000;

    // EXPONENT OF INPUT ( used to determine if 1x.xxxxx or 01.xxxxx for fixed point fraction to sqrt )
    // SQUARE ROOT EXPONENT IS HALF OF INPUT EXPONENT
    int13   expA  <:: ( df ? fp64( a ).exponent : fp32( a ).exponent ) - ( df ? 1023 : 127 );

    // PERFORM THE SQUAREROOT, FAST NORMALISE THE RESULT
    dofloatsqrt DOSQRT( df <: df );
    fastnormal NORMAL( df <: df, normalfraction :> normalfraction );

    DOSQRT.start := start & ACTION; busy := start | DOSQRT.busy;

    always_after {
        { DOSQRT.start_ac = expA[0,1] ? { 106b0, 1b1, a[ df ? 51 : 22, 1 ] } : 1; }
        { DOSQRT.start_x = expA[0,1] ? df ? { a[0,51], 55b0 } : { a[0,22], 84b0 } : df ? { fp64( a ).fraction, 54b0 } : { fp32( a ).fraction, 83b0 }; }
        { NORMAL.tonormal = df ? DOSQRT.squareroot : ( DOSQRT.squareroot << 59 ); }
        {
            if( ACTION ) {
                // STEPS: SETUP -> DOSQRT -> NORMALISE -> ROUND -> ADJUSTEXP -> COMBINE
                result = combined;
            } else {
                // DETECT sNAN, qNAN, -INF, -x -> qNAN AND  INF -> INF, 0 -> 0
                result = ( df ? fp64( a ).sign : fp32( a ).sign ) ? qNAN : a;
            }
        }
        { flags = { NV, 1b0, ACTION & OF, ACTION & UF, 1b0 }; }
    }
}

// FLOATING POresult COMPARISONS - ADAPTED FROM SOFT-FLOAT

/*============================================================================

License for Berkeley SoftFloat Release 3e

John R. Hauser
2018 January 20

The following applies to the whole of SoftFloat Release 3e as well as to
each source file individually.

Copyright 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018 The Regents of the
University of California.  All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
    this list of conditions, and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions, and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

 3. Neither the name of the University nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS "AS IS", AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, ARE
DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS resultERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=============================================================================*/

unit floatcompare(
    input   uint1   df,
    input   uint64  a,
    input   uint64  b,
    input   uint4   typeAF,
    input   uint4   typeBF,
    output  uint1   less,
    output  uint1   equal
) <reginputs> {
    uint1   NAN <:: typeAF[2,1] | typeBF[2,1] | typeAF[1,1] | typeBF[1,1];
    uint1   aequalb <:: a == b;
    uint1   aorbleft1equal0 <:: ~|( ( df ? a[0,63] : a[0,31] ) | ( df ? b[0,63] : b[0,31] ) );

    uint1   signA <:: df ? fp64( a ).sign : fp32( a ).sign;
    uint1   signB <:: df ? fp64( b ).sign : fp32( b ).sign;

    // IDENTIFY NaN, RETURN 0 IF NAN, OTHERWISE RESULT OF COMPARISONS
    always_after {
        { less = ~NAN & ( ( signA ^ signB ) ? signA & ~aorbleft1equal0 : ~aequalb & ( signA ^ ( ( df ? a : a[0,32] ) < ( df ? b : b[0,32] ) ) ) ); }
        { equal = ~NAN & ( aequalb | aorbleft1equal0 ); }
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

     uint7   opCode = 7b1010010; // ALL OTHER FPU OPERATIONS
    // uint7   opCode = 7b1000011; // FMADD
    // uint7   opCode = 7b1000111; // FMSUB
    // uint7   opCode = 7b1001011; // FNMSUB
    // uint7   opCode = 7b1001111; // FNMADD

    uint7   function7 = 7b0001101; // OPERATION SWITCH - LSB = DF
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
    // 1/3 = 32h3eaaaaab        64h3FD5555555555555
    // 1 = 32h3F800000
    // 2 = 32h40000000          64h4000000000000000
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
    //uint64  sourceReg1F = 64hffffffff40000000;
    //uint64  sourceReg2F = 64hffffffff3eaaaaab;
    //uint64  sourceReg3F = 64hffffffff40400000;
    uint64  sourceReg1F = 64h4000000000000000;
    uint64  sourceReg2F = 64h3FD5555555555555;
    uint64  sourceReg3F = 64h4008000000000000;

    uint1   TRUE = 1;
    uint1   FALSE = 0;

    uint64  result = uninitialised;
    uint1   frd = uninitialised;

    uint5   FPUflags = 5b00000;
    uint5   FPUnewflags = uninitialised;

    typeF typeAF( df <: function7[0,1], a <: sourceReg1F );
    typeF typeBF( df <: function7[0,1], a <: sourceReg2F );
    typeF typeCF( df <: function7[0,1], a <: sourceReg3F );
    typeF typeAS( df <: FALSE, a <: sourceReg1F );
    typeF typeAD( df <: TRUE, a <: sourceReg1F );

    floatcalc FPUcalc(
        df <: function7[0,1],
        opCode <: opCode[2,5],
        function7 <: function7[2,5],
        sourceReg1F <: sourceReg1F,
        sourceReg2F <: sourceReg2F,
        sourceReg3F <: sourceReg3F,
        typeAF <: typeAF.type,
        typeBF <: typeBF.type,
        typeCF <: typeCF.type,
        FPUflags <: FPUflags
    );
    fpuSINGLECYCLE FPUfast(
        df <: function7[0,1],
        function3 <: function3[0,2],
        function7 <: function7[2,5],
        sourceReg1 <: sourceReg1,
        sourceReg1F <: sourceReg1F,
        sourceReg2F <: sourceReg2F,
        typeAF <: typeAF.type,
        typeBF <: typeBF.type,
        FPUflags <: FPUflags
    );

    int2float FPUFLOAT( FPUflags <: FPUflags, rs2 <: rs2[0,1], sourceReg1 <: sourceReg1, abssourceReg1 <: abssourceReg1 );
    float2int FPUSINT( FPUflags <: FPUflags, rs2 <: rs2[0,1], sourceReg1F <: sourceReg1F, typeAF <: typeAF.type );
    int2double FPUDOUBLE( FPUflags <: FPUflags, rs2 <: rs2[0,1], sourceReg1 <: sourceReg1, abssourceReg1 <: abssourceReg1 );
    double2int FPUDINT( FPUflags <: FPUflags, rs2 <: rs2[0,1], sourceReg1F <: sourceReg1F, typeAF <: typeAF.type );
    float2double FPUFDOUBLE( FPUflags <: FPUflags, sourceReg1F <: sourceReg1F, typeAF <: typeAS.type );
    double2float FPUDFLOAT( FPUflags <: FPUflags, sourceReg1F <: sourceReg1F, typeAF <: typeAD.type );

    FPUcalc.start := 0;

    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++: ++: ++:
    startcycle = PULSE.cycles;
    __display("");
    __display("RISC-V DOUBLE/FLOAT FPU SIMULATION");
    __display("");
    __display("I1 = %x -> { %b %b %b }",sourceReg1,sourceReg1[31,1],sourceReg1[23,8],sourceReg1[0,23]);
    __display("F1 = %x -> { %b } as { %b }",sourceReg1F,sourceReg1F,typeAF.type);
    __display("F2 = %x -> { %b } as { %b }",sourceReg2F,sourceReg2F,typeBF.type);
    __display("F3 = %x -> { %b } as { %b }",sourceReg3F,sourceReg3F,typeAF.type);
    __display("OPCODE = %b FUNCTION7 = %b FUNCTION3 = %b RS1 = %b RS2 = %b",opCode, function7, function3, rs1, rs2);
    __display("");

    //while(1) {
        //if( start ) {
            //busy = 1;
            frd = 1;
            FPUnewflags = FPUflags;

            switch( opCode[2,5] ) {
                default: {
                    // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
                    __display("FUSED OPERATION");
                    FPUcalc.start = 1; while( FPUcalc.busy ) {} frd = 1; result = FPUcalc.result;
                }
                case 5b10100: {
                    switch( function7[2,5] ) {
                        default: {
                            // FADD.S FSUB.S FMUL.S FDIV.S FSQRT.S
                            __display("ADD SUB MUL DIV SQRT");
                            FPUcalc.start = 1; while( FPUcalc.busy ) {} frd = 1; result = FPUcalc.result;
                        }
                        case 5b00100: {
                            // FSGNJ.S FSGNJN.S FSGNJX.S
                            __display("SIGN MANIPULATION");
                            frd = FPUfast.frd; result = FPUfast.result;
                        }
                        case 5b00101: {
                            // FMIN.S FMAX.S
                            __display("MIN MAX");
                            frd = FPUfast.frd; result = FPUfast.result;
                        }
                        case 5b10100: {
                            // FEQ.S FLT.S FLE.S
                            __display("COMPARISON");
                            frd = FPUfast.frd; result = FPUfast.result;
                        }
                        case 5b11000: {
                            // FCVT.W.S FCVT.WU.S
                            __display("CONVERSION FLOAT TO INT");
                        }
                        case 5b11010: {
                            // FCVT.S.W FCVT.S.WU
                            __display("CONVERSION INT TO FLOAT");
                        }
                        case 5b11100: {
                            // FCLASS.S FMV.X.W
                            __display("CLASSIFY or MOVE BITMAP FROM FLOAT TO INT");
                            frd = FPUfast.frd; result = FPUfast.result;
                        }
                        case 5b11110: {
                            // FMV.W.X
                            __display("MOVE BITMAP FROM INT TO FLOAT");
                            frd = FPUfast.frd; result = FPUfast.result;
                        }
                    }
                }
            }
            __display("");
            __display("FRD = %b RESULT = %x -> { %b }",frd,result,result);
            __display("FLAGS = { %b }",FPUnewflags);

            __display("");
            __display("CONVERSIONS DOUNSIGNED = %b, TYPE = %b",rs2[0,1],typeAF.type);
            __display("INT 2 FLOAT    = %x { %b } { %b }",FPUFLOAT.result,FPUFLOAT.result,FPUFLOAT.FPUnewflags);
            __display("INT 2 DOUBLE   = %x { %b } { %b }",FPUDOUBLE.result,FPUDOUBLE.result,FPUDOUBLE.FPUnewflags);
            __display("FLOAT 2 INT    = %x { %b } { %b }",FPUSINT.result,FPUSINT.result,FPUSINT.FPUnewflags);
            __display("DOUBLE 2 INT   = %x { %b } { %b }",FPUDINT.result,FPUDINT.result,FPUDINT.FPUnewflags);
            __display("FLOAT 2 DOUBLE = %x { %b } { %b }",FPUFDOUBLE.result,FPUFDOUBLE.result,FPUFDOUBLE.FPUnewflags);
            __display("DOUBLE 2 FLOAT = %x { %b } { %b }",FPUDFLOAT.result,FPUDFLOAT.result,FPUDFLOAT.FPUnewflags);

            __display("");
            __display("TOTAL OF %0d CLOCK CYCLES",PULSE.cycles - startcycle);
            __display("");
            //busy = 0;
        //}
    //}
}
