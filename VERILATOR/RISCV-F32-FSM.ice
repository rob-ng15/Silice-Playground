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
   uint$w_h$           lhs        <: in[$w_h$,$w_h$];
   uint$w_h$           rhs        <: in[    0,$w_h$];
   uint$w_h$           select     <: left_empty ? rhs : lhs;
   uint1               left_empty <: ~|lhs;
   (half_count) = $name$_$w_h$(select);
   out          = {left_empty,half_count};
$$ end
}
$$end

// Produce a circuit for 32 bits numbers ( and 16, 8, 4, 2 )
$$generate_clz('clz_silice',32)

// FMIN.S FMAX.S FSGNJ.S FSGNJN.S FSGNJX.S FEQ.S FLT.S FLE.S FCLASS.S FMV.X.W
unit fpufast(
    input   uint2   function3,
    input   uint5   function7,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint4   classA,
    input   uint4   classB,

    output  uint32  result,
    output  uint1   frd,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags
) <reginputs> {
    floatcompare FPUlteq( a <: sourceReg1F, b <: sourceReg2F, classA <: classA, classB <: classB );
    floatminmax FPUminmax( sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, classA <: classA, classB <: classB, less <: FPUlteq.less, function3 <: function3[0,1] );
    floatcomparison FPUcompare( sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, classA <: classA, classB <: classB, less <: FPUlteq.less, equal <: FPUlteq.equal, function3 <: function3[0,2], );
    floatclassify FPUclass( sourceReg1F <: sourceReg1F, classA <: classA );
    floatsign FPUsign( function3 <: function3[0,2], sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );

    always_after {
        switch( function7[3,2] ) {
            case 2b00: {
                // FMIN.S FMAX.S FSGNJ.S FSGNJN.S FSGNJX.S
                result = function7[0,1] ? FPUminmax.result : FPUsign.result; FPUnewflags = FPUflags | ( function7[0,1] ? FPUminmax.flags : 0 );
            }
            case 2b10: {
                // FEQ.S FLT.S FLE.S
                result = FPUcompare.result; FPUnewflags = FPUflags | FPUcompare.flags;
            }
            default: {
                // FCLASS.S FMV.X.W
                result = function7[1,1] ? sourceReg1 : function3[0,1] ? FPUclass.classification : sourceReg1F; FPUnewflags = FPUflags;
            }
        }

        // SET WRITE TO FLOATING POINT REGISTER FLAG - FOR FMIN.S FMAX.S FSGNJ.S FSGNJN.S FSGNJX.S AND FMV.W.X
        frd = function7[3,1] ? function7[1,1] : ~|function7[3,2];
    }
}

// FCVT.W.S FCVT.WU.S FCVT.S.W FCVT.S.WU
unit floatconvert(
    input   uint5   function7,
    input   uint1   rs2,
    input   uint32  sourceReg1,
    input   uint32  abssourceReg1,
    input   uint32  sourceReg1F,
    input   uint4   classA,

    output  uint32  result,
    output  uint1   frd,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags
) <reginputs> {
    inttofloat FPUfloat( a <: sourceReg1, absa <: abssourceReg1, dounsigned <: rs2 );
    floattoint FPUint( a <: sourceReg1F, classA <: classA, dounsigned <: rs2 );

    always_after {
        frd = function7[1,1];
        result = function7[1,1] ? FPUfloat.result : FPUint.result;
        FPUnewflags = FPUflags | ( function7[1,1] ?  FPUfloat.flags : FPUint.flags );
    }
}

// FPU CALCULATION BLOCKS FUSED ADD SUB MUL DIV SQRT
unit floatcalc(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint5   opCode,
    input   uint5   function7,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,
    input   uint4   classA,
    input   uint4   classB,
    input   uint4   classC,
    input   uint5   FPUflags,
    output  uint5   FPUnewflags,
    output  uint32  result
) <reginputs> {
    uint1   is_fused(0);
    uint3   stage(0);
    uint1   result_ready = uninitialised;
    uint4   operation = uninitialised;
    uint1   exception = uninitialised;

    classifyF classD( a <: result );

    floatadd ADD();
    floatadd_X ADD_X();
    floatmultiply MUL( a <: sourceReg1F, b <: sourceReg2F );
    floatmultiply_X MUL_X( sign <: MUL.sign, classA <: classA, classB <: classB );
    floatdivide DIV( a <: sourceReg1F, b <: sourceReg2F );
    floatdivide_X DIV_X( sign <: DIV.sign, classA <: classA, classB <: classB );
    floatsqrt SQRT( a <: sourceReg1F );
    floatsqrt_X SQRT_X( a <: sourceReg1F, classA <: classA );

    // NORMALISE THE RESULT, COMBINE TO FINAL FLOAT 32
    normalise48to24 TONORMAL();

    DIV.start := 0; SQRT.start := 0; result_ready := 0; TONORMAL.adjustexp := operation[0,1];

    algorithm <autorun> {
        while(1) {
            switch( stage ) {
                default: {
                    // STAGE 0  CHECK FOR START / FUSED MULTIPLY FINISHED
                    //          ASSIGN THE INPUTS FOR THE CALCULATION (SWITCH SIGNS FOR ADD/SUB AND FUSED)
                    //          SIGNAL STAGE 1 TO START
                    if( start | is_fused ) {
                        if( start ) {
                            // ASSIGN INPUTS FOR SINGLE CALCULATION OR FIRST PART OF FUSED CALCULATION
                            if( opCode[2,1] ) {
                                // SINGLE CALCULATION
                                ADD.a = sourceReg1F; ADD_X.classA = classA; ADD_X.a = ADD.a;
                                ADD_X.classB = classB;
                                switch( function7[0,2] ) {
                                    case 2b00: {
                                        operation = 4b0001;
                                        ADD.b = sourceReg2F; ADD_X.b = ADD.b;
                                    }                                                                                                               // ADD
                                    case 2b01: {
                                        operation = 4b0001;
                                        ADD.b = { ~sourceReg2F[31,1], sourceReg2F[0,31] }; ADD_X.b = ADD.b;
                                    }                                                                                                               // SUB
                                    case 2b10: { operation = 4b0010; }                                                                              // MUL
                                    case 2b11: { operation = { function7[3,1], ~function7[3,1], 2b00 }; }                                           // SQRT & DIV
                                }
                            } else {
                                operation = 4b0010; is_fused = 1;                                                                                   // FUSED CALCULATION MULTIPLICATION
                            }
                        } else {
                            operation = 4b0001; is_fused = 0;                                                                                       // FUSED CALCULATION ADD/SUB
                            ADD.a = { opCode[1,1] ^ result[31,1], result[0,31] }; ADD_X.a = ADD.a; ADD_X.classA = classD.class;                           // PASS RESULT FROM MULTIPLY SWITCH SIGN IF -x
                            ADD.b = { opCode[0,1] ^ sourceReg3F[31,1], sourceReg3F[0,31] }; ADD_X.b = ADD.b; ADD_X.classB = classC;                       // PASS sourceReg3F SWITCH SIGN IF SUB
                        }
                        stage = 1;
                    }
                }
                case 1: {
                    // STAGE 1  CHECK INPUTS FOR SPECIAL CASES ( INF, NAN or ZEROs + NEG FOR SQRT
                    //          SIGNAL STAGE 2 TO START AND START UNITS IF NO EXCEPTION, ELSE JUMP TO STAGE 5
                    onehot( operation ) {
                        case 0: { exception = ADD_X.X; }
                        case 1: { exception = MUL_X.X; }
                        case 2: { exception = DIV_X.X; DIV.start = ~DIV_X.X; }
                        case 3: { exception = SQRT_X.X; SQRT.start = ~SQRT_X.X; }
                    }
                    stage = exception ? 4 : 2;
                }
                case 2: {
                    // STAGE 2  WAIT FOR UNITS TO FINISH
                    //          SIGNAL STAGE 3 TO START ONCE UNITS FINISH
                    stage = ( DIV.busy | SQRT.busy ) ? 2 : 3;
                }
                case 3: {
                    // STAGE 3  NORMALISE THE RESULT FROM CALCULATION
                    //          PASS EXPONENT AND RESULT SIGN TO ALLOW COMBINE TO FLOAT 32 RESULT
                    onehot( operation ) {
                        case 0: { TONORMAL.bitstream = ADD.bitstream; TONORMAL.exp = ADD.exp; TONORMAL.sign = ADD.sign; }
                        case 1: { TONORMAL.bitstream = MUL.bitstream; TONORMAL.exp = MUL.exp; TONORMAL.sign = MUL.sign; }
                        case 2: { TONORMAL.bitstream = DIV.bitstream; TONORMAL.exp = DIV.exp; TONORMAL.sign = DIV.sign; }
                        case 3: { TONORMAL.bitstream = SQRT.bitstream; TONORMAL.exp = SQRT.exp; TONORMAL.sign = 0; }
                    }
                    stage = 4;
                }
                case 4: {
                    // STAGE 4  FORM RESULT FROM CALCULATION / EXCEPTION
                    //          CHECKING FOR 0 AS RESULT OF ADD/SUB
                    //          RETURN TO STAGE 0, STAY BUSY IF STILL NEED ADD/SUB FOR FUSED
                    if( exception ) {
                        onehot( operation ) {
                            case 0: { result = ADD_X.result; }
                            case 1: { result = MUL_X.result; }
                            case 2: { result = DIV_X.result; }
                            case 3: { result = SQRT_X.result; }
                        }
                    } else {
                        result = ~operation[0,1] | ( operation[0,1] & |ADD.bitstream ) ? TONORMAL.f32 : 0;
                    }
                    result_ready = 1; stage = 0; busy = is_fused;
                }
            }
        }
    }

    always_after {
        if( start ) {
            FPUnewflags = FPUflags; busy = 1;
        } else {
            if( result_ready ) {
                if( is_fused ) {
                    if( exception ) {
                        FPUnewflags = FPUnewflags | ( MUL_X.flags & 5b10000 );
                    } else {
                        FPUnewflags = FPUnewflags | TONORMAL.flags;
                    }
                } else {
                    if( exception ) {
                        onehot( operation ) {
                            case 2: { FPUnewflags = FPUnewflags | ( DIV_X.flags & 5b01000 ); }
                            default: {}
                        }
                    } else {
                        FPUnewflags = FPUnewflags | TONORMAL.flags;
                    }
                    busy = 0;
                }
            }
        }
    }
}

// CLASSIFICATION 10 bits { qNAN, sNAN, +INF, +ve normal, +ve subnormal, +0, -0, -ve subnormal, -ve normal, -INF }
unit floatclassify(
    input   uint32  sourceReg1F,
    input   uint4   classA,
    output  uint10  classification
) <reginputs> {
    always_after{
        if( |classA ) {
            // INFINITY, NAN OR ZERO
            onehot( classA ) {
                case 0: { classification = ~|sourceReg1F[0,23] ? fp32( sourceReg1F ).sign ? 8 : 16 : fp32( sourceReg1F ).sign ? 4 : 32; }       // +/- 0 or subnormal
                case 1: { classification = 512; }                                                                                               // qNAN
                case 2: { classification = 256; }                                                                                               // sNAN
                case 3: { classification = fp32( sourceReg1F ).sign ? 1 : 128; }                                                                // +/- INF
            }
        } else {
            // NUMBER
            classification = fp32( sourceReg1F ).sign ? 2 : 64;                                                                                 // +/- normal
        }
    }
}

// MIN / MAX
unit floatminmax(
    input   uint1   less,
    input   uint1   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint4   classA,
    input   uint4   classB,
    output  uint5   flags,
    output  uint32  result
) <reginputs> {
    uint1   NAN <:: ( classA[2,1] | classB[2,1] ) | ( classA[1,1] & classB[1,1] );

    always_after {
        flags = { NAN, 4b0000 }; result = NAN ? 32h7fc00000 : classA[1,1] ? ( classB[1,1] ? 32h7fc00000 : sourceReg2F ) : classB[1,1] | ( function3 ^ less ) ? sourceReg1F : sourceReg2F;
    }
}

// COMPARISONS
unit floatcomparison(
    input   uint1   less,
    input   uint1   equal,
    input   uint2   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint4   classA,
    input   uint4   classB,
    output  uint5   flags,
    output  uint1   result
) <reginputs> {
    uint1   NAN <:: ( classA[1,1] | classA[2,1] | classB[1,1] | classB[2,1] );
    uint4   comparison <:: { 1b0, equal, less, less | equal };

    always_after {
        flags = { function3[1,1] ? ( classA[2,1] | classB[2,1] ) : NAN, 4b0000 }; result = ~NAN & comparison[ function3, 1 ];
    }
}

unit floatsign(
    input   uint2   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint32  result,
) <reginputs> {
    always_after {
        result = { function3[1,1] ? sourceReg1F[31,1] ^ sourceReg2F[31,1] : function3[0,1] ^ sourceReg2F[31,1], sourceReg1F[0,31] };
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

// BITFIELD FOR FLOATING POINT NUMBER - IEEE-754 32 bit format
bitfield fp32{
    uint1   sign,
    uint8   exponent,
    uint23  fraction
}
// REFERENCE, NOT USED IN THIS MODULE
bitfield floatingpointflags{
    uint1   IF,     // infinity as an argument
    uint1   NN,     // NaN as an argument
    uint1   NV,     // Result is not valid,
    uint1   DZ,     // Divide by zero
    uint1   OF,     // Result overflowed
    uint1   UF,     // Result underflowed
    uint1   NX      // Not exact ( integer to float conversion caused bits to be dropped )
}

// IDENTIFY infinity, signalling NAN, quiet NAN, ZERO
unit classifyF(
    input   uint32  a,
    output  uint4   class
) <reginputs> {
    // CHECK FOR 8hff ( signals INF/NAN )
    uint1   expFF <:: &fp32(a).exponent;            uint1   NAN <:: expFF & a[22,1];

    always_after {
        class = { expFF & ~a[22,1], NAN & a[21,1], NAN & ~a[21,1], ~|( fp32(a).exponent ) };
    }
}

// NORMALISE A 48 BIT MANTISSA SO THAT THE MSB IS ONE, FOR ADDSUB ALSO DECREMENT THE EXPONENT FOR EACH SHIFT LEFT
// EXTRACT THE 24 BITS FOLLOWING THE MSB (1.xxxx) FOR ROUNDING
unit clz48(
    input   uint48  bitstream,
    output! uint6   count
) <reginputs> {
    uint16  bitstreamh <:: bitstream[32,16];        uint32  bitstreaml <:: bitstream[0,32];               uint6   clz = uninitialised;

    always_after {
        if( |bitstreamh ) { ( count ) = clz_silice_16( bitstreamh ); } else { ( clz ) = clz_silice_32( bitstreaml ); count = 16 + clz; }
    }
}

// NORMALISE RESULT
// ROUND 23 BIT FRACTION FROM NORMALISED FRACTION USING NEXT TRAILING BIT
// ADD BIAS TO EXPONENT AND ADJUST EXPONENT IF ROUNDING FORCES
// COMBINE COMPONENTS INTO FLOATING POINT NUMBER - USED BY CALCULATIONS
// UNDERFLOW return 0, OVERFLOW return infinity
unit normalise48to24(
    input   uint1   sign,
    input   int10   exp,
    input   uint48  bitstream,
    input   uint1   adjustexp,
    output  uint3   flags,
    output  uint32  f32
) <reginputs> {
    // COUNT LEADING ZEROS
    clz48 CLZ48( bitstream <: bitstream );          uint48  temporary <:: ( bitstream << CLZ48.count );
    uint23  roundfraction <:: temporary[24,23] + temporary[23,1];
    int10   newexponent <:: ( ( ~|roundfraction & temporary[23,1] ) ? 128 : 127 ) + ( adjustexp ? exp - CLZ48.count : exp );
    uint1   OF <:: ( newexponent > 254 );
    uint1   UF <:: newexponent[9,1];

     always_after {
        f32 = UF ? 0 : { sign, OF ? 31h7f800000 : { newexponent[0,8], roundfraction } };
        flags = { OF, UF, 1b0 };
     }
}

// CONVERT SIGNED/UNSIGNED INTEGERS TO FLOAT
// dounsigned == 1 for signed conversion (31 bit plus sign), == 0 for dounsigned conversion (32 bit)
unit clz32(
    input   uint32  number,
    output! uint5   zeros
) <reginputs> {
    always_after {
        ( zeros ) = clz_silice_32( number );
    }
}
unit inttofloat(
    input   uint32  a,
    input   uint32  absa,
    input   uint1   dounsigned,
    output  uint7   flags,
    output  uint32  result
) <reginputs> {
    // COUNT LEADING ZEROS - RETURNS NX IF NUMBER IS TOO LARGE, LESS THAN 8 LEADING ZEROS
    clz32 CLZ( number <: number );

    uint32  number <:: sign ? absa : a;
    uint1   sign <:: ~dounsigned & a[31,1];        uint1   NX <:: ( ~|CLZ.zeros[3,2] );
    int10   exponent <:: 158 - CLZ.zeros;          int23  fraction <:: NX ? number >> ( 8 - CLZ.zeros ) : number << ( CLZ.zeros - 8 );

    always_after {
        flags = { 6b0, NX }; result = ( |a ) ? { sign, exponent[0,8], fraction } : 0;
    }
}

// CONVERT FLOAT TO SIGNED/UNSIGNED INTEGERS
unit floattoint(
    input   uint32  a,
    input   uint1   dounsigned,
    input   uint4   classA,
    output  uint7   flags,
    output  uint32  result
) <reginputs> {
    uint1   NN <:: classA[2,1] | classA[1,1];       uint1   NV <:: ( exp > ( dounsigned ? 31 : 30 ) ) | ( dounsigned & fp32( a ).sign ) | classA[3,1] | NN;

    uint33  sig <:: ( exp < 24 ) ? { 9b1, fp32( a ).fraction, 1b0 } >> ( 23 - exp ) : { 9b1, fp32( a ).fraction, 1b0 } << ( exp - 24);
    int10   exp <:: fp32( a ).exponent - 127;
    uint32  unsignedfraction <:: ( sig[1,32] + sig[0,1] );

    always_after {
        if( classA[0,1] ) {
            result = 0;
        } else {
            if( dounsigned ) {
                if( classA[3,1] | NN ) {
                    result = NN ? 32hffffffff : { {32{~fp32( a ).sign}} };
                } else {
                    result = ( fp32( a ).sign ) ? 0 : NV ? 32hffffffff : unsignedfraction;
                }
            } else {
                if( classA[3,1] | NN ) {
                    result = { ~NN & fp32( a ).sign, {31{~fp32( a ).sign}} };
                } else {
                    result = { fp32( a ).sign, NV ? {31{~fp32( a ).sign}} : fp32( a ).sign ? -unsignedfraction : unsignedfraction };
                }
            }
        }
        flags = { classA[3,1], NN, NV, 4b0000 };
    }
}

// ADDITION
unit equaliseexpaddsub(
    input   uint32  a,
    input   uint32  b,
    output  uint48  newsigA,
    output  uint48  newsigB,
    output  int10   resultexp,
) <reginputs> {
    // BREAK DOWN INITIAL float32 INPUTS - SWITCH SIGN OF B IF SUBTRACTION
    int10   expA <:: fp32(a).exponent;              uint48  sigA <:: { 2b01, fp32(a).fraction, 23b0 };
    int10   expB <:: fp32(b).exponent;              uint48  sigB <:: { 2b01, fp32(b).fraction, 23b0 };
    uint1   AvB <:: ( expA < expB );                uint48  aligned <:: ( AvB ? sigA : sigB ) >> ( ( AvB ? expB : expA ) - ( AvB ? expA : expB ) );

    always_after {
        newsigA = AvB ? aligned : sigA; newsigB = AvB ? sigB : aligned; resultexp = ( AvB ? expB : expA ) - 126;
    }
}
unit dofloataddsub(
    input   uint1   signA,
    input   uint48  sigA,
    input   uint1   signB,
    input   uint48  sigB,
    output  uint1   resultsign,
    output  uint48  resultfraction
) <reginputs> {
    uint48  minus <:: ( signA ^ resultsign ? sigB : sigA ) - ( signA ^ resultsign ? sigA : sigB );
    uint48  plus <:: sigA + sigB;
    uint1   AvB <:: ( sigA > sigB );

    always_after {
        // PERFORM ADDITION HANDLING SIGNS
        if( ^{ signA, signB } ) { resultsign = signA ? AvB : ~AvB; resultfraction = minus; } else { resultsign = signA; resultfraction = plus; }
    }
}
unit floatadd(
    input   uint32  a,
    input   uint32  b,
    output  uint1   sign,
    output  int10   exp,
    output  uint48  bitstream
) <reginputs> {
    equaliseexpaddsub EQUALISEEXP( a <: a, b <: b, resultexp :> exp );
    dofloataddsub ADDSUB(
        signA <: fp32( a ).sign, sigA <: EQUALISEEXP.newsigA,
        signB <: fp32( b).sign, sigB <: EQUALISEEXP.newsigB,
        resultsign :> sign, resultfraction :> bitstream
    );
}
unit floatadd_X(
    input   uint32  a,
    input   uint32  b,
    input   uint4   classA,
    input   uint4   classB,
    output  uint1   X,
    output  uint32  result
) <reginputs> {
    uint1   ZERO <:: (classA[0,1] | classB[0,1] );
    uint1   IF <:: ( classA[3,1] | classB[3,1] );
    uint1   NN <:: ( classA[1,2] | classB[1,2] );
    uint1   NV <:: ( classA[3,1] & classB[3,1]) & ( fp32( a ).sign ^ fp32( b).sign );

    always_after {
        X = |{ IF | NN, ZERO };
        switch( { IF | NN, ZERO } ) {
            case 2b00: {}
            case 2b01: { result = (classA[0,1] & classB[0,1] ) ? 0 : ( classB[0,1] ) ? a : b; }
            default: {
                switch( { IF, NN } ) {
                    case 2b10: { result = NV ? 32hffc00000 : classA[3,1] ? a : b; }
                    default: { result = 32hffc00000; }
                }
            }
        }
    }
}

// MULTIPLICATION
unit floatmultiply(
    input   uint32  a,
    input   uint32  b,
    output  uint1   sign,
    output  int10   exp,
    output  uint48  bitstream
) <reginputs> {
    always_after {
        bitstream = { 1b1, fp32( a ).fraction } * { 1b1, fp32( b ).fraction };
        sign = fp32( a ).sign ^ fp32( b ).sign;
        exp = fp32( a ).exponent + fp32( b ).exponent - ( bitstream[47,1] ? 253 : 254 );
    }
}
unit floatmultiply_X(
    input   uint1   sign,
    input   uint4   classA,
    input   uint4   classB,
    output  uint1   X,
    output  uint32  result,
    output  uint7   flags
) <reginputs> {
    uint1   ZERO <:: (classA[0,1] | classB[0,1] );
    uint1   IF <:: ( classA[3,1] | classB[3,1] );
    uint1   NN <:: ( classA[2,1] | classA[1,1] | classB[2,1] | classB[1,1] );
    uint1   NV <:: IF & ZERO;

    always_after {
        X = |{ IF | NN, ZERO };
        switch( { IF | NN, ZERO } ) {
            case 2b00: {}
            case 2b01: { result = { sign, 31b0 }; }
            default: {
                switch( { IF, ZERO } ) {
                    case 2b11: { result = 32hffc00000; }
                    case 2b10: { result = NN ? 32hffc00000 : { sign, 31h7f800000 }; }
                    default: { result = 32hffc00000; }
                }
            }
        }
        flags = { IF, 6b0 };
    }
}

// DIVIDE
unit dofloatdivide(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint50  sigA,
    input   uint50  sigB,
    output  uint50  quotient(0)
) <reginputs> {
    uint6   bit(63);
    uint50  remainder = uninitialised;
    uint50  temporary <:: { remainder[0,49], sigA[bit,1] };
    uint1   bitresult <:: __unsigned(temporary) >= __unsigned(sigB);
    uint2   normalshift <:: quotient[49,1] ? 2 : quotient[48,1];

    busy := start | ( ~&bit ) | ( |quotient[48,2] );

    always_after {
        // FIND QUOTIENT AND ENSURE 48 BIT FRACTION ( ie BITS 48 and 49 clear )
        if( &bit ) {
            if( start ) { bit = 49; quotient = 0; remainder = 0; } else { quotient = quotient[ normalshift, 48 ]; }
        } else {
            remainder = __unsigned(temporary) - ( bitresult ? __unsigned(sigB) : 0 );
            quotient[bit,1] = bitresult;
            bit = bit - 1;
        }
    }
}
unit prepdivide(
    input   uint32  a,
    input   uint32  b,
    output  uint1   quotientsign,
    output  int10   quotientexp,
    output  uint50  sigA,
    output  uint50  sigB
) <reginputs> {
    // BREAK DOWN INITIAL float32 INPUTS AND FIND SIGN OF RESULT AND EXPONENT OF QUOTIENT ( -1 IF DIVISOR > DIVIDEND )
    // ALIGN DIVIDEND TO THE LEFT, DIVISOR TO THE RIGHT
    always_after {
        quotientsign = fp32( a ).sign ^ fp32( b ).sign;
        quotientexp = fp32( a ).exponent - fp32( b ).exponent - ( fp32(b).fraction > fp32(a).fraction );
        sigA = { 1b1, fp32(a).fraction, 26b0 };
        sigB = { 27b1, fp32(b).fraction };
    }
}
unit floatdivide(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint32  a,
    input   uint32  b,
    output  uint1   sign,
    output  int10   exp,
    output  uint48  bitstream
) <reginputs> {
    prepdivide PREP( a <: a, b <: b, quotientsign :> sign, quotientexp :> exp );
    dofloatdivide DODIVIDE( sigA <: PREP.sigA, sigB <: PREP.sigB, quotient :> bitstream );
    DODIVIDE.start := start; busy := start | DODIVIDE.busy;
}
unit floatdivide_X(
    input   uint1   sign,
    input   uint4   classA,
    input   uint4   classB,
    output  uint1   X,
    output  uint32  result,
    output  uint7   flags
) <reginputs> {
    uint1   ZERO <:: (classA[0,1] | classB[0,1] );
    uint1   IF <:: ( classA[3,1] | classB[3,1] );
    uint1   NN <:: ( classA[2,1] | classA[1,1] | classB[2,1] | classB[1,1] );
    uint1   NV <:: IF & ZERO;

    always_after {
        X = |{ IF | NN, ZERO };
        switch( { IF | NN, ZERO } ) {
            case 2b00: {}
                case 2b01: { result = (classA[0,1] & classB[0,1] ) ? 32hffc00000 : { sign, classB[0,1] ? 31h7f800000 : 31h0 }; }
                default: { result = ( classA[3,1] & classB[3,1] ) | NN | classB[0,1] ? 32hffc00000 : { sign, (classA[0,1] | classB[3,1] ) ? 31b0 : 31h7f800000 }; }
       }
        flags = { 3b0, classB[0,1], 3b0};
    }
}

// SQUARE ROOT
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

unit floatsqrt(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint32  a,
    output  int10   exp,
    output  uint48  bitstream
) <reginputs> {
}

unit dofloatsqrt(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint50  start_ac,
    input   uint48  start_x,
    output  uint48  squareroot
) <reginputs> {
    uint6   i(47);
    uint50  test_res <:: ac - { squareroot, 2b01 }; uint50  ac = uninitialised;
    uint48  x = uninitialised;

    busy := start | ( i != 47 );

    always_after {
        if( i == 47) {
            if( start ) { i = 0; squareroot = 0; ac = start_ac; x = start_x; }
        } else {
            ac = { test_res[49,1] ? ac[0,47] : test_res[0,47], x[46,2] };
            squareroot = { squareroot[0,47], ~test_res[49,1] };
            x = { x[0,46], 2b00 };
            i = i + 1;
        }
    }
}
unit prepsqrt(
    input   uint32  a,
    output  uint50  start_ac,
    output  uint48  start_x,
    output  int10   squarerootexp
) <reginputs> {
    // EXPONENT OF INPUT ( used to determine if 1x.xxxxx or 01.xxxxx for fixed point fraction to sqrt )
    // SQUARE ROOT EXPONENT IS HALF OF INPUT EXPONENT
    int10   exp  <:: fp32( a ).exponent - 127;

    always_after {
        start_ac = exp[0,1] ? { 48b0, 1b1, a[22,1] } : 1;
        start_x = exp[0,1] ? { a[0,22], 26b0 } : { fp32( a ).fraction, 25b0 };
        squarerootexp = ( exp >>> 1 );
    }
}
unit floatsqrt(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint32  a,
    output  int10   exp,
    output  uint48  bitstream
) <reginputs> {
    prepsqrt PREP( a <: a, squarerootexp :> exp );
    dofloatsqrt DOSQRT( start_ac <: PREP.start_ac, start_x <: PREP.start_x, squareroot :> bitstream );
    DOSQRT.start := start; busy := start | DOSQRT.busy;
}
unit floatsqrt_X(
    input   uint32  a,
    input   uint4   classA,
    output  uint1   X,
    output  uint32  result
) <reginputs> {
    uint1   ZERO <:: classA[0,1];
    uint1   IF <:: classA[3,1];
    uint1   NN <:: classA[2,1] | classA[1,1];
    uint1   NV <:: IF | NN | fp32( a ).sign;

    always_after {
        X = |{ IF | NN, ZERO | fp32( a ).sign };
        if( |{ IF | NN, ZERO | fp32( a ).sign } ) { result = fp32( a ).sign ? 32hffc00000 : a; }
    }
}

// FLOATING POINT COMPARISONS - ADAPTED FROM SOFT-FLOAT

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
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=============================================================================*/

unit floatcompare(
    input   uint32  a,
    input   uint32  b,
    input   uint4   classA,
    input   uint4   classB,
    output  uint7   flags,
    output  uint1   less,
    output  uint1   equal
) <reginputs> {
    uint1   NAN <:: classA[2,1] | classB[2,1] | classA[1,1] | classB[1,1];
    uint1   aequalb <:: ( a == b );                 uint1   aorbleft1equal0 <:: ~|( ( a | b ) << 1 );

    // IDENTIFY NaN, RETURN 0 IF NAN, OTHERWISE RESULT OF COMPARISONS
    always_after {
        flags = { classA[3,1] | classB[3,1], {2{NAN}}, 4b0000 };
        less = ~NAN & ( ( fp32( a ).sign ^ fp32( b ).sign ) ? fp32( a ).sign & ~aorbleft1equal0 : ~aequalb & ( fp32( a ).sign ^ ( a < b ) ) );
        equal = ~NAN & ( aequalb | aorbleft1equal0 );
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

    uint7   function7 = 7b0001000; // OPERATION SWITCH
    // ADD = 7b0000000 SUB = 7b0000100 MUL = 7b0001000 DIV = 7b0001100 SQRT = 7b0101100
    // FSGNJ[N][X] = 7b0010000 function3 == 000 FSGNJ == 001 FSGNJN == 010 FSGNJX
    // MIN MAX = 7b0010100 function3 == 000 MIN == 001 MAX
    // FCVT.W[U].S floatto[u]int = 7b1100000 rs2 == 00000 FCVT.W.S == 00001 FCVT.WU.S
    // FCVT.S.W[U] [u]inttofloat = 7b1101000 rs2 == 00000 FCVT.S.W == 00001 FCVT.S.WU

    uint3   function3 = 3b000; // ROUNDING MODE OR SWITCH
    uint5   rs1 = 5b00000; // SOURCEREG1 number
    uint5   rs2 = 5b00000; // SOURCEREG2 number OR SWITCH

    uint32  sourceReg1 = 1000000000; // INTEGER SOURCEREG1

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
    uint32  sourceReg1F = 32h3F800000;
    uint32  sourceReg2F = 32h40000000;
    uint32  sourceReg3F = 32h42480000;

    uint32  result = uninitialised;
    uint1   frd = uninitialised;

    uint5   FPUflags = 5b00000;
    uint5   FPUnewflags = uninitialised;

    uint32  calculatorresult = uninitialised;
    uint5   calculatorflags = uninitialised;
    floatcalc FPUcalculator( opCode <: opCode[2,5], function7 <: function7[2,5], sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, sourceReg3F <: sourceReg3F, result :> calculatorresult, FPUnewflags :> calculatorflags );

    uint32  signresult = uninitialised;
    floatsign FPUsign( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, result :> signresult );

    uint32  minmaxresult = uninitialised;
    uint5   minmaxflags = uninitialised;
    floatminmax FPUminmax( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, result :> minmaxresult, flags :> minmaxflags );

    uint32  compareresult = uninitialised;
    uint5   compareflags = uninitialised;
    floatcomparison FPUcompare( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, result :> compareresult, flags :> compareflags );

    uint32  convertresult = uninitialised;
    uint5   convertflags = uninitialised;
    floatconvert FPUconvert( function7 <: function7, rs2 <: rs2, sourceReg1 <: sourceReg1, sourceReg1F <: sourceReg1F, result :> convertresult, FPUnewflags :> convertflags );

    uint10  classification = uninitialised;
    floatclassify FPUclass( sourceReg1F <: sourceReg1F, classification :> classification );

    FPUcalculator.start := 0;

    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++:
    startcycle = PULSE.cycles;
    __display("");
    __display("RISC-V FPU SIMULATION");
    __display("");
    __display("I1 = %x -> { %b %b %b }",sourceReg1,sourceReg1[31,1],sourceReg1[23,8],sourceReg1[0,23]);
    __display("F1 = %x -> { %b %b %b }",sourceReg1F,sourceReg1F[31,1],sourceReg1F[23,8],sourceReg1F[0,23]);
    __display("F2 = %x -> { %b %b %b }",sourceReg2F,sourceReg2F[31,1],sourceReg2F[23,8],sourceReg2F[0,23]);
    __display("F3 = %x -> { %b %b %b }",sourceReg2F,sourceReg3F[31,1],sourceReg3F[23,8],sourceReg3F[0,23]);
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
                    FPUcalculator.start = 1; while( FPUcalculator.busy ) {} result = calculatorresult; FPUnewflags = FPUflags | calculatorflags;
                }
                case 5b10100: {
                    switch( function7[2,5] ) {
                        default: {
                            // FADD.S FSUB.S FMUL.S FDIV.S FSQRT.S
                            __display("ADD SUB MUL DIV SQRT");
                            FPUcalculator.start = 1; while( FPUcalculator.busy ) {} result = calculatorresult; FPUnewflags = FPUflags | calculatorflags;
                        }
                        case 5b00100: {
                            // FSGNJ.S FSGNJN.S FSGNJX.S
                            __display("SIGN MANIPULATION");
                            result = signresult;
                        }
                        case 5b00101: {
                            // FMIN.S FMAX.S
                            __display("MIN MAX");
                            result = minmaxresult; FPUnewflags = FPUflags | minmaxflags;
                        }
                        case 5b10100: {
                            // FEQ.S FLT.S FLE.S
                            __display("COMPARISON");
                            frd = 0; result = compareresult; FPUnewflags = FPUflags | compareflags;
                        }
                        case 5b11000: {
                            // FCVT.W.S FCVT.WU.S
                            __display("CONVERSION FLOAT TO INT");
                            frd = 0; result = convertresult; FPUnewflags = FPUflags | convertflags;
                        }
                        case 5b11010: {
                            // FCVT.S.W FCVT.S.WU
                            __display("CONVERSION INT TO FLOAT");
                            result = convertresult; FPUnewflags = FPUflags | convertflags;
                        }
                        case 5b11100: {
                            // FCLASS.S FMV.X.W
                            __display("CLASSIFY or MOVE BITMAP FROM FLOAT TO INT");
                            frd = 0;
                            switch( function3[0,1] ) {
                                case 1: { result = classification; }
                                case 0: { result = sourceReg1F; }
                            }
                        }
                        case 5b11110: {
                            // FMV.W.X
                            __display("MOVE BITMAP FROM INT TO FLOAT");
                            result = sourceReg1;
                        }
                    }
                }
            }
            __display("");
            __display("FRD = %b RESULT = %x -> { %b %b %b }",frd,result,result[31,1],result[23,8],result[0,23]);
            __display("FLAGS = { %b }",FPUnewflags);
            __display("");
            __display("TOTAL OF %0d CLOCK CYCLES",PULSE.cycles - startcycle);
            __display("");
            //busy = 0;
        //}
    //}
}
