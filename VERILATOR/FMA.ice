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

// IDENTIFY infinity, signalling NAN, quiet NAN, ZERO
unit classifyF(
    input   uint32  a,
    output  uint4   class
) <reginputs> {
    uint1   expFF <:: &fp32(a).exponent;                                                                                        // CHECK FOR 8hff ( signals INF/NAN )
    uint1   zeroFRACTION <:: ~|fp32(a).fraction;                                                                                // FRACTION == 0, INF, == 100... qNAN, == 0xxx... ( xxx... != 0 ) sNAN

    always_after {
        class = {   expFF & zeroFRACTION,                                                                                       // INF
                    expFF & ~fp32(a).fraction[22,1] & ~zeroFRACTION,                                                            // sNAN
                    expFF & fp32(a).fraction[22,1],                                                                             // qNAN
                    ~|( fp32(a).exponent )                                                                                      // ZERO / SUBNORMAL
        };
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
   uint$w_h$           lhs        = in[$w_h$,$w_h$];
   uint$w_h$           rhs        = in[    0,$w_h$];
   uint1               left_empty = ~|lhs;
   uint$w_h$           select     = left_empty ? rhs : lhs;
   (half_count) = $name$_$w_h$(select);
   out          = {left_empty,half_count};
$$ end
}
$$end

$$generate_clz('clz_silice',32)

// NORMALISE A 48 BIT MANTISSA SO THAT THE MSB IS ONE, FOR ADDSUB ALSO DECREMENT THE EXPONENT FOR EACH SHIFT LEFT
// EXTRACT THE 24 BITS FOLLOWING THE MSB (1.xxxx) FOR ROUNDING
unit clz48(
    input   uint48  bitstream,
    output! uint6   count
) <reginputs> {
    uint16  bitstreamh <:: bitstream[32,16];        uint32  bitstreaml <:: bitstream[0,32];
    uint6   clz_l = uninitialised;                  uint6   clz_h = uninitialised;

    always_after {
        { ( clz_l ) = clz_silice_32( bitstreaml ); }
        { ( clz_h ) = clz_silice_16( bitstreamh ); }
        { count = |bitstreamh ? clz_h : 16 + clz_l; }                                                                           // COUNT LEADING ZEROS FOR NORMALISATION SHIFT
    }
}
// NORMALISE RESULT FOR ADD SUB DIVIDE
unit normalise24(
    input   int10   exp,
    input   uint48  bitstream,
    output  int10   newexponent,
    output  uint24  normalfraction
) <reginputs> {
    // COUNT LEADING ZEROS
    uint48 temporary <:: ( bitstream << CLZ48.count );
    clz48 CLZ48( bitstream <: bitstream );

    always_after {
        { normalfraction = temporary[23,24]; }                                                                                  // EXTRACT 24 BITS ( 1 extra for rounding )
        { newexponent = exp - CLZ48.count; }                                                                                    // ADDSUB EXPONENT ADJUSTMENT
    }
}

// ROUND 23 BIT FRACTION FROM NORMALISED FRACTION USING NEXT TRAILING BIT
// ADD BIAS TO EXPONENT AND ADJUST EXPONENT IF ROUNDING FORCES
// COMBINE COMPONENTS INTO FLOATING POINT NUMBER - USED BY CALCULATIONS
// UNDERFLOW return 0, OVERFLOW return infinity
unit doroundcombine(
    input   uint1   sign,
    input   uint24  bitstream,
    input   int10   exponent,
    output! uint1   OF,
    output! uint1   UF,
    output! uint32  f32
) <reginputs> {
    uint23  roundfraction <:: bitstream[1,23] + bitstream[0,1];
    int10   newexponent <:: ( ( ~|roundfraction & bitstream[0,1] ) ? 128 : 127 ) + exponent;

   always_after {
        { OF = ( newexponent > 254 );  }
        { UF = newexponent[9,1];  }
        { f32 = UF ? 0 : { sign, OF ? 31h7f800000 : { newexponent[0,8], roundfraction } }; }
    }
}


unit equaliseexpaddsub(
    input   uint32  a,
    input   uint32  b,
    output  uint48  newsigA,
    output  uint48  newsigB,
    output  int10   resultexp,
) <reginputs> {
    // BREAK DOWN INITIAL float32 INPUTS - SWITCH SIGN OF B IF SUBTRACTION
    uint48  sigA <:: { 2b01, fp32(a).fraction, 23b0 };
    uint48  sigB <:: { 2b01, fp32(b).fraction, 23b0 };
    uint1   AvB <:: ( fp32(a).exponent < fp32(b).exponent );
    uint48  aligned <:: ( AvB ? sigA : sigB ) >> ( ( AvB ? fp32(b).exponent : fp32(a).exponent ) - ( AvB ? fp32(a).exponent : fp32(b).exponent ) );

    always_after {
        { newsigA = AvB ? aligned : sigA; }
        { newsigB = AvB ? sigB : aligned;  }
        { resultexp = ( AvB ? fp32(b).exponent : fp32(a).exponent ) - 126; }
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
    uint1   AvB <:: ( sigA > sigB );

    always_after {
        // PERFORM ADDITION/SUBTRACTION ACCOUTING FOR INPUT AND RESULT SIGNS
        { if( signA ^ signB ) { resultsign = signA ? AvB : ~AvB; } else { resultsign = signA; } }
        { if( signA ^ signB ) { resultfraction = ( signA ^ resultsign ? sigB : sigA ) - ( signA ^ resultsign ? sigA : sigB ); } else { resultfraction = sigA + sigB; } }
    }
}
unit floatfma(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint32  a,
    input   uint32  b,
    input   uint32  c,
    input   uint4   classA,
    input   uint4   classB,
    input   uint4   classC,
    output  int10   tonormaliseexp,
    output  uint48  tonormalisebitstream,
    output  uint1   resultsign,
    input   uint1   OF,
    input   uint1   UF,
    input   uint32  f32,
    output  uint7   flags,
    output  uint32  result
) <reginputs> {
    // CLASSIFY THE INPUTS AND FLAG INFINITY, NAN, ZERO AND INVALID ( INF - INF )
    uint1   ZERO <:: ( classA[0,1] | classB[0,1] | classC[0,1] );
    uint1   IF <:: ( classA[3,1] | classB[3,1] | classC[3,1] );
    uint1   NN <:: ( classA[2,1] | classA[1,1] | classB[2,1] | classB[1,1] | classC[2,1] | classC[1,1] );
    uint1   NV <:: 0;
    uint3   ACTION <:: { IF, NN, ZERO };

    uint48  product <:: { 1b1, fp32( a ).fraction } * { 1b1, fp32( b ).fraction };
    uint10  productexp <:: fp32( a ).exponent + fp32( b ).exponent - ( product[47,1] ? 126 : 127 );

    // EQUALISE THE EXPONENTS
    equaliseexpaddsub EQUALISEEXP( b <: c );

    // PERFORM THE ADDITION/SUBTRACION USING THE EQUALISED FRACTIONS, 1 IS ADDED TO THE EXPONENT IN CASE OF OVERFLOW - NORMALISING WILL ADJUST WHEN SHIFTING
    dofloataddsub ADDSUB(
        sigA <: EQUALISEEXP.newsigA,
        signB <: fp32(c).sign,
        sigB <: EQUALISEEXP.newsigB
    );

    EQUALISEEXP.a := { fp32( a ).sign ^ fp32( b ).sign, productexp[0,8], product[ product[47,1] ? 24 : 23, 23 ] };

    resultsign := classC[0,1] ? fp32( a ).sign ^ fp32( b ).sign : ADDSUB.resultsign;
    tonormaliseexp := classC[0,1] ? productexp - 126 : EQUALISEEXP.resultexp;
    tonormalisebitstream := classC[0,1] ? product : ADDSUB.resultfraction;

    algorithm <autorun> {
        while(1) {
            if( start ) {
                busy = 1;
                if( ~|ACTION ) {
                    ++: ++: busy = 0;
                } else { busy = 0; }
            }
        }
    }

    always_after {
        {
            switch( ACTION ) {
                case 3b000: { result = f32; }
                case 3b001: {
                    result = ( classA[0,1] & classB[0,1] & classC[0,1] ) ? 0 :
                               classA[0,1] | classB[0,1] ? c : f32;
                }
                case 3b010: { result = 32h7fc00000; }
                case 3b011: { result = 32h7fc00000; }
                case 3b111: { result = 32h7fc00000; }
                default: { result = 31h7f800000; }
            }
        }
        {  flags = { IF, NN, NV, 1b0, ~|ACTION & OF, ~|ACTION & UF, 1b0 }; }
    }
}


algorithm main(
    output  uint8   leds
) {
    uint32  sourceReg1F = 32h3F800000;  // 1
    //uint32  sourceReg1F = 32h3F800000;  // 1
    uint32  sourceReg2F = 32h40000000;  // 2
    //uint32  sourceReg2F = 32h40000000;  // 2
    uint32  sourceReg3F = 32h40400000;  // 3
    //uint32  sourceReg3F = 0;  // 0

    uint5   opCode = 5b10000;   // FMADD.S
    //uint5   opCode = 5b10001;   // FMSUB.S
    //uint5   opCode = 5b10010;   // FNMSUB.S
    //uint5   opCode = 5b10011;   // FNMADD.S

    classifyF classA( a <: sourceReg1F ); classifyF classB( a <: sourceReg2F ); classifyF classC( a <: sourceReg3F );

    // NORMALISE RESULT OF ADD SUB DIV
    normalise24 DONORMAL( bitstream <: FPUFMA.tonormalisebitstream, exp <: FPUFMA.tonormaliseexp );

    // ROUNDING AND COMBINING OF FINAL RESULTS
    doroundcombine MAKERESULT( sign <: FPUFMA.resultsign, exponent <: DONORMAL.newexponent, bitstream <: DONORMAL.normalfraction );

    floatfma FPUFMA(
        b <: sourceReg2F,
        classA <: classA.class, classB <: classB.class, classC <: classC.class,
        OF <: MAKERESULT.OF, UF <: MAKERESULT.UF, f32 <: MAKERESULT.f32
    );

    FPUFMA.a := { opCode[1,1] ^ sourceReg1F[31,1], sourceReg1F[0,31] };
    FPUFMA.c := { opCode[0,1] ^ sourceReg3F[31,1], sourceReg3F[0,31] };
    FPUFMA.start := 0;

    ++: ++: ++: ++:

    FPUFMA.start = 1; while( FPUFMA.busy ) {}

    __display("FPUFMA result = %x (%b), FLAGS = %b",FPUFMA.result,FPUFMA.result,FPUFMA.flags);
}
