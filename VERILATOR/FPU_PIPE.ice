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

// TOP FPU MODULES
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
    uint1   stage_1 = uninitialised;
    uint1   hold_2 = uninitialised;
    uint1   stage_2 = uninitialised;
    uint1   stage_3 = uninitialised;
    uint1   stage_4 = uninitialised;
    uint1   stage_5 = uninitialised;
    uint1   result_ready = uninitialised;
    uint4   operation = uninitialised;
    uint1   exception = uninitialised;

    uint32  in1 = uninitialised;
    uint4   cl1 = uninitialised;
    uint32  in2 = uninitialised;
    uint4   cl2 = uninitialised;

    classifyF classD( a <: result );    // CLASSIFY THE RESULT, USED FOR FUSED OPERATIONS

    floatadd ADD( a <: in1, b <: in2 );             floatadd_X ADD_X( a <: in1, b <: in2, classA <: cl1, classB <: cl2 );
    floatmultiply MUL( a <: in1, b <: in2 );        floatmultiply_X MUL_X( sign_a <: in1[31,1], sign_b <: in2[31,1], classA <: cl1, classB <: cl2 );
    floatdivide DIV( a <: in1, b <: in2 );          floatdivide_X DIV_X( sign_a <: in1[31,1], sign_b <: in2[31,1], classA <: cl1, classB <: cl2 );
    floatsqrt SQRT( a <: in1 );                     floatsqrt_X SQRT_X( a <: in1, classA <: cl1 );

    // NORMALISE THE RESULT, COMBINE TO FINAL FLOAT 32
    normalise48to24 TONORMAL();
    doroundcombine COMBINE( normal <: TONORMAL.normal );

    stage_1 := 0; stage_2 := 0; stage_3 := 0; stage_4 := 0; stage_5 := 0;
    busy := start ? 1 : result_ready ? ( is_fused ? 1 : 0 ) : busy;
    DIV.start := 0; SQRT.start := 0;

    always {

        {
            // STAGE 0  CHECK FOR START / FUSED MULTIPLY FINISHED
            //          ASSIGN THE INPUTS FOR THE CALCULATION (SWITCH SIGNS FOR ADD/SUB AND FUSED)
            //          SIGNAL STAGE 1 TO START
            if( start | ( is_fused & result_ready ) ) {
                __display("START = %b, FUSED & RESULT_READY %b",start,is_fused & result_ready);
                if( start ) {
                    // ASSIGN INPUTS FOR SINGLE CALCULATION OR FIRST PART OF FUSED CALCULATION
                    if( opCode[2,1] ) {
                        // SINGLE CALCULATION
                        in1 v= sourceReg1F; cl1 v= classA; in2 v= sourceReg2F; cl2 v= classB;
                        switch( function7[0,4] ) {
                            default:{
                                // ADD
                                operation v= 4b0001;
                            }
                            case 4b0001: {
                                // SUB (do as ADD with second input sign swapped)
                                in2 v= { ~sourceReg2F[31,1], sourceReg2F[0,31] }; cl2 v= classB;
                                operation v= 4b0001;
                            }
                            case 4b0010: {
                                // MUL
                                operation v= 4b0010;
                            }
                            case 4b0011: {
                                // DIV
                                operation v= 4b0100;
                            }
                            case 4b1011: {
                                // SQRT
                                in2 v= 0; cl2 v= 0;
                                operation v= 4b1000;
                            }
                        }
                        __display("SEND SINGLE OPERATION");
                    } else {
                        // FUSED CALCULATION MULTIPLICATION
                        operation v= 4b0010; is_fused = 1;
                        in1 v= { opCode[1,1] ^ sourceReg1F[31,1], sourceReg1F[0,31] }; cl1 v= classA;
                        in2 v= sourceReg2F; cl2 v= classB;
                        __display("SEND FUSED MUL");
                    }
                    stage_1 = 1;
                } else {
                    // ASSIGN INPUTS FOR SECOND PART OF FUSED CALCULATION
                    operation v= 4b0001; is_fused = 0;
                    in1 v= result; cl1 v= classD.class;
                    in2 v= { opCode[0,1] ^ sourceReg3F[31,1], sourceReg3F[0,31] }; cl2 v= classC;
                    stage_1 = 1;
                    __display("SEND FUSED ADD/SUB");
                }
            }
        } -> {
            // STAGE 1  CHECK INPUTS FOR SPECIAL CASES
            //          SIGNAL STAGE 2 TO START
            if( stage_1 ) {
                onehot( operation ) {
                    case 0: { exception v= ADD_X.X; }
                    case 1: { exception v= MUL_X.X; }
                    case 2: { exception v= DIV_X.X; }
                    case 3: { exception v= SQRT_X.X; }
                }
                __display("STAGE 1 : A = %x (%b), B = %x (%b), X = %b, OP = %b",in1,cl1,in2,cl2,exception,operation);
                stage_2 = 1;
            }
        } -> {
            // STAGE 2  START UNITS IF NO EXECEPTION
            //          SIGNAL STAGE 3 TO START ONCE UNITS FINISH
            if( stage_2 ) {
                if( exception ) {
                    stage_3 = 1;
                } else {
                    // START DIV SQRT UNIT OR SKIP TO NEXT STAGE
                    DIV.start = operation[2,1]; SQRT.start = operation[3,1];
                    hold_2 = |operation[2,2]; stage_3 = ~|operation[2,2];
                }
            } else {
                if( hold_2 ) {
                    hold_2 = DIV.busy | SQRT.busy;
                    stage_3 = ~( DIV.busy | SQRT.busy );
                }
            }
        } -> {
            // STAGE 3  NORMALISE THE RESULT FROM CALCULATION OR SKIP IF EXCEPTION
            if( stage_3 ) {
                if( exception ) {
                } else {
                    // PASS APPROPRIATE BITSTREAM TO NORMALISE
                    onehot( operation ) {
                        case 0: { TONORMAL.exp v= ADD.exp; TONORMAL.bitstream v= ADD.bitstream; }
                        case 1: { TONORMAL.bitstream v= MUL.bitstream; }
                        case 2: { TONORMAL.bitstream v= DIV.bitstream; }
                        case 3: { TONORMAL.bitstream v= SQRT.bitstream; }
                    }
                }
                stage_4 = 1;
            }
        } -> {
            // STAGE 4  MAKE RESULT FROM SIGN, EXP, NORMALE FRACTION OR SKIP IF EXCEPTION
            if( stage_4 ) {
                if( exception ) {
                } else {
                    onehot( operation ) {
                        case 0: { COMBINE.sign v= ADD.sign; COMBINE.exponent v= TONORMAL.newexponent; }
                        case 1: { COMBINE.sign v= MUL.sign; COMBINE.exponent v= MUL.exp; }
                        case 2: { COMBINE.sign v= DIV.sign; COMBINE.exponent v= DIV.exp; }
                        case 3: { COMBINE.sign v= 0; COMBINE.exponent v= SQRT.exp; }
                    }
                }
                stage_5 = 1;
            }
        } -> {
            // STAGE 5  FORM RESULT FROM CALCULATION / EXCEPTION
            if( stage_5 ) {
                if( exception ) {
                    onehot( operation ) {
                        case 0: { result v= ADD_X.result; }
                        case 1: { result v= MUL_X.result; }
                        case 2: { result v= DIV_X.result; }
                        case 3: { result v= SQRT_X.result; }
                    }
                } else {
                    onehot( operation ) {
                        case 0: { result v= |ADD.bitstream ? COMBINE.f32 : 0; }
                        default: { result v= COMBINE.f32; }
                    }
                }
                result_ready v= 1;
            } else {
                result_ready v= 0;
            }
        }

        __display("START %b, BUSY %b, FUSE %b, S1 %b, S2 %b H2 %b, S3 %b, S4 %b, S5 %b, X %b, RES %b",
                  start,busy,is_fused,stage_1,stage_2,hold_2,stage_3,stage_4,stage_5,exception,result_ready);
    }
}

unit fpu_convert(
    input   uint32  sourceReg1,
    input   uint32  abssourceReg1,
    input   uint32  sourceReg1F,
    input   uint4   classA,
    input   uint32  instruction,
    output  uint32  result
) <reginputs> {
    always {
    }
}

unit fpu_compare(
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint4   classA,
    input   uint4   classB,
    input   uint32  instruction,
    output  uint32  result
) <reginputs> {
    always {
    }
}

unit fpu_class(
    input   uint32  sourceReg1F,
    input   uint4   classA,
    input   uint32  instruction,
    output  uint32  result
) <reginputs> {
    always {
    }
}

unit fpu_sign(
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  instruction,
    output  uint32  result
) <reginputs> {
    always {
    }
}

// FPU COMPONENT MODULES

// IDENTIFY { infinity, signalling NAN, quiet NAN, ZERO }
unit classifyF(
    input!  uint32  a,
    output! uint4   class
) <reginputs> {
    // CHECK FOR 8hff ( signals INF/NAN )
    uint1   expFF <:: &fp32(a).exponent;
    uint1   NAN <:: expFF & a[22,1];

    always_after {
        class = { expFF & ~a[22,1], NAN & a[21,1], NAN & ~a[21,1], ~|( fp32(a).exponent ) };
    }
}

// NORMALISE 48 bit BITSTREAM TO 24 bit NORMAL FRACTION
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
$$generate_clz('clz_silice',32)

unit clz48(
    input   uint48  bitstream,
    output! uint6   count
) <reginputs> {
    uint16  bitstreamh <:: bitstream[32,16];        uint32  bitstreaml <:: bitstream[0,32];               uint6   clz = uninitialised;

    always_after {
        if( |bitstreamh ) { ( count ) = clz_silice_16( bitstreamh ); } else { ( clz ) = clz_silice_32( bitstreaml ); count = 16 + clz; }
    }
}
unit normalise48to24(
    input   int10   exp,
    input   uint48  bitstream,
    output  int10   newexponent,
    output  uint24  normal
) <reginputs> {
    // COUNT LEADING ZEROS
    clz48 CLZ48( bitstream <: bitstream );          uint48  temporary <:: ( bitstream << CLZ48.count );

    always_after {
        normal = temporary[23,24]; newexponent = exp - CLZ48.count;
    }
}

// ROUND 23 BIT FRACTION FROM NORMALISED FRACTION USING NEXT TRAILING BIT
// ADD BIAS TO EXPONENT AND ADJUST EXPONENT IF ROUNDING FORCES
// COMBINE COMPONENTS INTO FLOATING POINT NUMBER - USED BY CALCULATIONS
// UNDERFLOW return 0, OVERFLOW return infinity
unit doroundcombine(
    input   uint1   sign,
    input   uint24  normal,
    input   int10   exponent,
    output  uint1   OF,
    output  uint1   UF,
    output  uint32  f32
) <reginputs> {
    uint23  roundfraction <:: normal[1,23] + normal[0,1];
    int10   newexponent <:: ( ( ~|roundfraction & normal[0,1] ) ? 128 : 127 ) + exponent;

    always_after {
        OF = ( newexponent > 254 ); UF = newexponent[9,1]; f32 = UF ? 0 : { sign, OF ? 31h7f800000 : { newexponent[0,8], roundfraction } };
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
    output  uint32  result,
    output  uint7   flags
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
        flags = { IF, NN, NV, 4b0 };
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
    always {
        bitstream = { 1b1, fp32( a ).fraction } * { 1b1, fp32( b ).fraction };
        sign = fp32( a ).sign ^ fp32( b ).sign;
        exp = fp32( a ).exponent + fp32( b ).exponent - ( bitstream[47,1] ? 253 : 254 );
    }
}
unit floatmultiply_X(
    input   uint1   sign_a,
    input   uint1   sign_b,
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
    uint1   sign <:: sign_a ^ sign_b;

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
        flags = { IF, NN, NV, 4b0 };
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

    busy := start | ( ~&bit ) | ( quotient[48,2] != 0 );

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
    input   uint1   sign_a,
    input   uint1   sign_b,
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
    uint1   sign <:: sign_a ^ sign_b;

    always_after {
        X = |{ IF | NN, ZERO };
        switch( { IF | NN, ZERO } ) {
            case 2b00: {}
                case 2b01: { result = (classA[0,1] & classB[0,1] ) ? 32hffc00000 : { sign, classB[0,1] ? 31h7f800000 : 31h0 }; }
                default: { result = ( classA[3,1] & classB[3,1] ) | NN | classB[0,1] ? 32hffc00000 : { sign, (classA[0,1] | classB[3,1] ) ? 31b0 : 31h7f800000 }; }
       }
        flags = { IF, NN, 1b0, classB[0,1], 3b0};
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
    output  uint32  result,
    output  uint7   flags
) <reginputs> {
    uint1   ZERO <:: classA[0,1];
    uint1   IF <:: classA[3,1];
    uint1   NN <:: classA[2,1] | classA[1,1];
    uint1   NV <:: IF | NN | fp32( a ).sign;

    always_after {
        X = |{ IF | NN, ZERO | fp32( a ).sign };
        if( |{ IF | NN, ZERO | fp32( a ).sign } ) { result = fp32( a ).sign ? 32hffc00000 : a; }
        flags = { IF, NN, NV, 4b0 };
    }
}

algorithm main(
    output  uint8   leds
) {
    uint32  sourceReg1F = 32h40800000;  // 4
    uint32  sourceReg2F = 32h40400000;  // 3
    uint32  sourceReg3F = 32h40000000;  // 2

    uint5   opCode = 5b10100;
    uint7   function7 = 7b0101100;

    classifyF classA( a <: sourceReg1F ); classifyF classB( a <: sourceReg2F ); classifyF classC( a <: sourceReg3F );

    floatcalc FPU_CALC(
        opCode <: opCode, function7 <: function7[2,5],
        sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, sourceReg3F <: sourceReg3F,
        classA <: classA.class, classB <: classB.class, classC <: classC.class
    );

    FPU_CALC.start := 0;

    ++: ++: ++: ++:

    FPU_CALC.start = 1; while( FPU_CALC.busy ) {}

    __display("FPU_CALC result = %x (%b)",FPU_CALC.result,FPU_CALC.result);
}
