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

unit clz64(
    input   uint64  number,
    output! uint7   zeros
) <reginputs> {
    always_after {
        ( zeros ) = clz_silice_64( number );
    }
}

unit clz106(
    input   uint106  bitstream,
    output! uint7   count
) <reginputs> {
    always_after {
        uint2   bitstream3 = bitstream[104,2];                                                                                  // SPLIT 106 BITS INTO 64, 32, 8 AND 2 ( from low to high )
        uint8   bitstream2 = bitstream[96,8];
        uint32  bitstream1 = bitstream[64,32];
        uint64  bitstream0 = bitstream[0,64];
        uint3   mask = { |bitstream3, |bitstream2, |bitstream1 };                                                               // FLAG CONTENTS OF EACH SECTION CONTAIN A 1

        uint2   clz_3 = uninitialised;
        uint4   clz_2 = uninitialised;
        uint6   clz_1 = uninitialised;
        uint7   clz_0 = uninitialised;

        ( clz_3 ) = clz_silice_2( bitstream3 );
        ( clz_2 ) = clz_silice_8( bitstream2 );
        ( clz_1 ) = clz_silice_32( bitstream1 );
        ( clz_0 ) = clz_silice_64( bitstream0 );

        count = ( mask[2,1] ? clz_3 : mask[1,1] ? clz_2 : mask[0,1] ? clz_1 : clz_0 ) +                                         // COUNT LEADING ZEROS FOR NORMALISATION SHIFT
                ( mask[2,1] ? 0 : mask[1,1] ? 2 : mask[0,1] ? 10 : 42 );                                                        // ADD ON AMOUNT IN PRIOR SECTIONS IF APPLICABLE
     }
}


// BITFIELD FOR FLOATING POINT NUMBER - IEEE-754 16 bit format
bitfield fp16{
    uint1   sign,
    uint5   exponent,
    uint10  fraction
}
$$ BIAS16 = 15
// BITFIELD FOR FLOATING POINT NUMBER - IEEE-754 32 bit format
bitfield fp32{
    uint1   sign,
    uint8   exponent,
    uint23  fraction
}
$$ BIAS32 = 127
// BITFIELD FOR FLOATING POINT NUMBER - IEEE-754 64 bit format
bitfield fp64{
    uint1   sign,
    uint11  exponent,
    uint52  fraction
}
$$ BIAS64 = 1023

// REFERENCE RISC-V FLOATING POINT FLAGS
bitfield floatingpointflags{
    uint1   NV,     // Result is not valid,
    uint1   DZ,     // Divide by zero
    uint1   OF,     // Result overflowed
    uint1   UF,     // Result underflowed
    uint1   NX      // Not exact ( integer to float conversion caused bits to be dropped )
}

// ABSOLUTE VALUES FOR 32 AND 64 BIT REGISTER CONTENTS
unit abs3264(
    input   uint64  sourceReg,
    output  uint32  abs32,
    output  uint64  abs64
) <reginputs> {
    always_after {
        abs32 = sourceReg[31,1] ? -sourceReg[0,32] : sourceReg[0,32];
        abs64 = sourceReg[63,1] ? -sourceReg : sourceReg;
    }
}

// RISC-V CPU FPU INSTRUCTION DISPATCHER, COORDINATES ALL OPERATIONS OF THE FPU INCLUDING CONVERSIONS
unit cpuexecuteFPU(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint5   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs2,
    input   int64   sourceReg1,
    input   uint32  S1_abs32,
    input   uint64  S1_abs64,
    input   uint64  sourceReg1F,
    input   uint64  sourceReg1Fx,
    input   uint64  sourceReg1Fxopp,
    input   uint4   typeAF,
    input   uint4   typeAopp,
    input   uint64  sourceReg2F,
    input   uint64  sourceReg2Fx,
    input   uint4   typeBF,
    input   uint64  sourceReg3Fx,
    input   uint4   typeCF,
    input   uint1   FLT,
    input   uint1   FEQ,
    output  uint1   frd,
    output  int64   result,
    input   uint1   isFASTFPU,
    input   uint8   FPUflags,
    output  uint5   FPUnewflags,
    output  uint1   CSRupdateFPUflags
) <reginputs> {
    uint10  BIAS <:: function7[0,1] ? $BIAS64$ : function7[1,1] ? $BIAS16$ : $BIAS32$;                                          // SELECT BIAS TO PASS WHERE NEEDED ( CALCULATIONS AND DESTINATION FOR CONVERSIONS )
    uint10  SBIAS <:: rs2[0,1] ? $BIAS64$ : rs2[1,1] ? $BIAS16$ : $BIAS32$;                                                     // SELECT BIAS TO PASS WHERE NEEDED ( SOURCE FOR CHANGE PRECISION )

    uint3   converttype <:: {
                                ( function7[2,5] == 5b11000 ),                                                                  // FD2IL
                                ( function7[2,5] == 5b11010 ),                                                                  // IL2FD
                                ( function7[2,5] == 5b01000 )                                                                   // F2D or D2F
                            };
    uint1   fpuconvert <:: ( opCode == 5b10100 ) & |converttype;                                                                // FPU CONVERSION TO/FROM INT OR CHANGE OF PRECISION DETECTION
    uint1   fpufast <:: isFASTFPU | fpuconvert;                                                                                 // SINGLE CYCLE OR CONVERSION DETECTION
    uint1   fpucalc <:: ~fpufast;                                                                                               // CALCULATION DETECTION
    uint3   operation <:: { fpucalc, fpuconvert, fpufast & ~fpuconvert };                                                       // PRESENT INSTRUCTION ROUTE

    fpuSINGLECYCLE FPUFAST(                                                                                                     // FLOATING POINT SINGLE CYCLE OPERATIONS
        dsh <: function7[0,2],
        FPUflags <: FPUflags,
        function3 <: function3[0,2], function7 <: function7[2,5],
        sourceReg1 <: sourceReg1, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F,
        sign1F <: fp64( sourceReg1Fx ).sign, sign2F <: fp64( sourceReg2Fx ).sign,
        typeAF <: typeAF, typeBF <: typeBF,
        FLT <: FLT, FEQ <: FEQ
    );

    uint1   rm <:: ( &FPUflags[5,3] ? function3 : FPUflags[5,3] ) != 3b001;                                                     // SET ROUNDING FLAG ( ONLY RNE AND RTZ SUPPORTED ), FCSR UNLESS 111
    floatcalc FPUCALC(                                                                                                          // FLOATING POINT CALCULATIONS CONTROLLER
        rm <: rm, dsh <: function7[0,2],                                                                                                  // RETURNS RESULT WIDE PACKED IN DOUBLE BITFIELDS
        BIAS <: BIAS,
        FPUflags <: FPUflags,
        opCode <: opCode, function3 <: function3, function7 <: function7[2,5],
        sourceReg1Fx <: sourceReg1Fx, sourceReg2Fx <: sourceReg2Fx, sourceReg3Fx <: sourceReg3Fx,
        typeAF <: typeAF, typeBF <: typeBF, typeCF <: typeCF
    );

    repackage_actual CALCRESULT( dsh <: function7[0,2], a <: FPUCALC.result );                                                  // REPACKAGE CALCULATION RESULT INTO CORRECT BITFIELDS WITH NAN BOXING

    // FLOATING POINT CONVERSIONS
    uint1   convertrm <:: ( function3 != 3b001 );                                                                               // SET ROUNDING FLAG FOR CONVERSIONS ( always uses function3 )
    intlong2float FPUIL2F( rm <: convertrm, dounsigned <: rs2[0,1], il <: rs2[1,1], dsh <: function7[0,2], BIAS <: BIAS, sourceReg1 <: sourceReg1, S1_abs32 <: S1_abs32, S1_abs64 <: S1_abs64 );
    float2intlong FPUF2IL( rm <: convertrm, dounsigned <: rs2[0,1], il <: rs2[1,1], BIAS <: BIAS, sourceReg1Fx <: sourceReg1Fx, typeAF <: typeAF );
    changeprecision FPUF_CP( dest <: function7[0,2], DBIAS <: BIAS, source <: rs2[0,2], SBIAS <: SBIAS, sourceReg1Fx <: sourceReg1Fxopp, typeAF <: typeAopp );

    FPUCALC.start := fpucalc & start; CSRupdateFPUflags := 0;                                                                   // START FLAGS AND UPDATE CSR

    algorithm <autorun> {
        while(1) {
            if( start ) {
                busy = 1;
                if( operation[2,1] ) { while( FPUCALC.busy ) {} }                                                               // WAIT STATE FOR CALCULATIONS
                busy = 0;
                CSRupdateFPUflags = 1;
            }
        }
    }

    always_after {
        uint64  convertresult = converttype[2,1] ? FPUF2IL.result : converttype[1,1] ? FPUIL2F.result : FPUF_CP.result;
        uint5   convertflags = FPUflags | ( converttype[2,1] ? FPUF2IL.FPUflags : converttype[1,1] ? FPUIL2F.FPUflags : FPUF_CP.FPUflags );

        result = operation[0,1] ? FPUFAST.result : operation[1,1] ? convertresult : CALCRESULT.repack;                          // COLLECT THE APPROPRIATE RESULT
        frd = fpuconvert ? ( |converttype[0,2] ) : fpucalc ? 1 : FPUFAST.frd;                                                   // WRITE TO F REGISTERS FOR TO FLOAT CONVERSIONS, CALCULATIONS AND SOME SINGLE CYCLE
        FPUnewflags = fpuconvert ? convertflags : fpucalc ? FPUCALC.FPUnewflags : FPUFAST.FPUnewflags;                          // OUTPUT NEW FPU FLAGS
    }
}

// Rob Shelton ( @robng15 Twitter, @rob-ng15 GitHub )
// Simple 16/32/64 bit FPU calculation/conversion routines
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
// NB: dsh represents the precision of the flaoting-point inputs single == 00, double == 01, half == 10
//     as per the Risc-V function7[0,2] bits
// NB: All calculations and conversions expect to receive repackaged floating-point inputs.
//     Half and Single precision floating-point numbers are expanded to fit into the bitfields
//     of double precision numbers. Repackers are provided to expand/truncate inputs/results
//     with nan-boxing of half and single precision numbers.
// NB: All calculations return their results in the bitfields of double precision numbers.
//     These are repackaged in the CPU floating-point controller to their actual format.
// NB: The floating-point exponent bias is generated in the CPU floating-point controller
//     and passed to those operations which require it.
// NB: rm represents the rounding mode, only RTE (000) and RTZ(001) are supported.
// NB: The typeAF/typeBF/typeCF inputs detect exception inputs for each of the input registers,
//     and are 4 bits each for { infinity, signalling NAN, quiet NAN, ZERO } and will signal a
//     NAN if a half or single precision input is not nan-boxed.
// NB: subnormal inputs are presently detected and treated as zero.
// NB: Error states are those required by Risc-V floating point

// FMIN FMAX FSGNJ FSGNJN FSGNJX FEQ FLT FLE FCLASS FMV
unit floatclass(                                                                                                                // CLASSIFY FLOATING POINT INPUT ( FCLASS.S FCLASS.D )
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF FLAG
    input   uint64  sourceReg1F,                                                                                                // REGISTER INPUT TO CLASSIFY
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO } OF REGISTER INPUT
    input   uint1   sign1F,                                                                                                     // SIGN OF REGISTER INPUT
    output  uint10  FCLASS                                                                                                      // 10 bit INTEGER CLASSIFICATION OF REGISTER INPUT
) <reginputs> {
    uint1   TRUEZERO <:: ~|( dsh[0,1] ? fp64( sourceReg1F ).fraction :                                                          // CHECK FRACTION == 0 ( NOT SUBNORMAL )
                             dsh[1,1] ? fp16( sourceReg1F ).fraction :
                                        fp32( sourceReg1F ).fraction );

    always_after {
        FCLASS = {  typeAF[1,1],                                                                                                // 512  qNAN
                    typeAF[2,1],                                                                                                // 256  sNAN
                    typeAF[3,1] & ~sign1F,                                                                                      // 128  +INF
                    ~|typeAF & ~sign1F,                                                                                         // 64   +NORMAL
                    typeAF[0,1] & ~sign1F & ~TRUEZERO,                                                                          // 32   +SUBNORMAL
                    typeAF[0,1] & ~sign1F & TRUEZERO,                                                                           // 16   +0
                    typeAF[0,1] & sign1F & TRUEZERO,                                                                            // 8    -0
                    typeAF[0,1] & sign1F & ~TRUEZERO,                                                                           // 4    -SUBNORMAL
                    ~|typeAF & sign1F,                                                                                          // 2    -NORMAL
                    typeAF[3,1] & sign1F                                                                                        // 1    -INF
        };
    }
}

unit floateqltle(                                                                                                               // FLOATING POINT COMPARISONS ( uses base comparison less/equal generator )
    input   uint2   function3,                                                                                                  // COMPARISON TYPE SWITCH
    input   uint1   EQUAL,                                                                                                      // IS EQUAL FLAG A == B
    input   uint1   LESS,                                                                                                       // IS LESS FLAG A < B
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO } OF A
    input   uint4   typeBF,                                                                                                     // { INF sNAN qNAN ZERO } OF B
    output  uint1   COMPARE,                                                                                                    // RESULT OF COMPARISON
    output  uint5   flags                                                                                                       // FLOATING POINT FLAGS FOR COMPARISON
) <reginputs> {
    uint1   NAN <:: |( typeAF[1,2] | typeBF[1,2] );                                                                             // DETECT NAN INPUT
    uint3   LTEQ <:: { EQUAL, LESS, LESS | EQUAL };                                                                             // BIT ARRAY FOR COMPARISON FLAGS

    always_after {
        COMPARE = ~NAN & LTEQ[ function3, 1 ];                                                                                  // 0 IF NAN ELSE COMPARISON FLAG
        flags = { function3[1,1] ? ( typeAF[2,1] | typeBF[2,1] ) : NAN, 4b0000 };                                               // RETURN NV FLAG IF FLT OR FLE AND NAN IS AN INPUT
    }
}

unit floatminmax(                                                                                                               // FLOATING POINT MIN / MAX
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF FLAG
    input   uint1   function3,                                                                                                  // MIN == 0, MAX == 1
    input   uint64  sourceReg1F,                                                                                                // REGISTER INPUT A
    input   uint64  sourceReg2F,                                                                                                // REGISTER INPUT B
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO } OF A
    input   uint4   typeBF,                                                                                                     // { INF sNAN qNAN ZERO } OF B
    input   uint1   LESS,                                                                                                       // IS LESS FLAG A < B
    output  uint64  MINMAX,                                                                                                     // RESULT OF MIN/MAX(a,b)
    output  uint5   flags                                                                                                       // FLOATING POINT FLAGS FOR MIN/MAX
) <reginputs> {
    uint1   NAN <:: |( typeAF[1,2] | typeBF[1,2] );                                                                             // DETECT NAN INPUT
    actual_qNAN qNAN( dsh <: dsh );                                                                                             // GENERATE qNAN FOR USE IF ERROR

    always_after {
        MINMAX = NAN ? qNAN.value : ( function3[0,1] ^ LESS ) ? sourceReg1F : sourceReg2F;                                      // EITHER INPUT NAN RETURN qNAN ELSE DO MIN MAX AND SELECT REGISTER
        flags = { NAN, 4b0000 };                                                                                                // FLAGS SIGNALLING NAN INPUT
    }
}

unit floatsign(                                                                                                                 // FLOATING POINT FSGNJ FSGNJN FSGNJX SIGN INJECTION
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF FLAG
    input   uint2   function3,                                                                                                  // SWITCH FSGNJ == 00, FSGNJN == 01, FSGNJX == 10
    input   uint64  sourceReg1F,                                                                                                // REGISTER INPUT 1
    input   uint1   sign1F,                                                                                                     // SIGN OF REGISTER INPUT 1
    input   uint1   sign2F,                                                                                                     // SIGN OF REGISTER INPUT 2
    output  uint64  SIGN                                                                                                        // RESULT OF SIGN INJECTION
) <reginputs> {
    uint1   SIGNBIT <:: function3[1,1] ? sign1F ^ sign2F : function3[0,1] ^ sign2F;                                             // DETERMINE SIGN FOR INJECTION XOR FOR JX OPPOSITE FOR JN COPY FOR J

    always_after {
        SIGN = dsh[0,1] ? { SIGNBIT, sourceReg1F[0,63] } :                                                                      // INJECT SIGN DOUBLE
               dsh[1,1] ? { 48hffffffffffff, SIGNBIT, sourceReg1F[0,15] } :                                                     //             HALF ( NAN boxed )
                          { 32hffffffff, SIGNBIT, sourceReg1F[0,31] };                                                          //             SINGLE ( NAN boxed )
    }
}

unit fpuSINGLECYCLE(
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF FLAG
    input   uint2   function3,                                                                                                  // SWITCH FOR COMPARE MINMAX AND SIGN OPERATIONS
    input   uint5   function7,                                                                                                  // SWITCH TO DETERMINE WHICH OPERATIONS
    input   uint64  sourceReg1,                                                                                                 // INTEGER REGISTER FOR FMV
    input   uint64  sourceReg1F,                                                                                                // INPUT FLOAT REGISTER 1
    input   uint1   sign1F,                                                                                                     // SIGN OF FLOAT REGISTYER 1
    input   uint64  sourceReg2F,                                                                                                // INPUT FLOAT REGISTER 2
    input   uint1   sign2F,                                                                                                     // SIGN OF FLOAT REGISTYER 2
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO } OF INPUT FLOAT REGISTER 1
    input   uint4   typeBF,                                                                                                     // { INF sNAN qNAN ZERO } OF INPUT FLOAT REGISTER 2
    input   uint1   FLT,                                                                                                        // sourceReg1F < sourceReg2F
    input   uint1   FEQ,                                                                                                        // sourceReg1F == sourceReg2F
    input   uint5   FPUflags,                                                                                                   // PRESENT FPU FLAGS
    output  uint5   FPUnewflags,                                                                                                // NEW FPU FLAGS
    output  uint64  result,                                                                                                     // RESULT ( NAN boxed if single/half, sign extended if int )
    output  uint1   frd                                                                                                         // IS RESULT FLOAT/DOUBLE OR INT/LONG
) <reginputs> {
    floatclass FPUclass(                                                                                                        // GENERATE FCLASS
        dsh <: dsh,
        sign1F <: sign1F, sourceReg1F <: sourceReg1F, typeAF <: typeAF
    );
    floateqltle FPUeqltle(                                                                                                      // GENERATE FEQ FLT FLE
        function3 <: function3,
        EQUAL <: FEQ,
        LESS <: FLT,
        typeAF <: typeAF,
        typeBF <: typeBF
    );
    floatminmax FPUminmax(                                                                                                      // GENERATE FMIN FMAX
        dsh <: dsh,
        function3 <: function3[0,1],
        sourceReg1F <: sourceReg1F, typeAF <: typeAF,
        sourceReg2F <: sourceReg2F, typeBF <: typeBF,
        LESS <: FLT
    );
    floatsign FPUsign(                                                                                                          // GENERATE SGNJ FSGNJN FSGNJX
        dsh <: dsh,
        function3 <: function3,
        sign1F <: sign1F, sourceReg1F <: sourceReg1F,
        sign2F <: sign2F
    );

    always_after {
        switch( function7[3,2] ) {                                                                                              // RESULT
            case 2b00: {
                result = function7[0,1] ? FPUminmax.MINMAX : FPUsign.SIGN;                                                      // FMIN FMAX FSGNJ FSGNJN FSGNJX
                FPUnewflags = FPUflags | ( function7[0,1] ? FPUminmax.flags : 0 );
            }
            case 2b10: {
                result = FPUeqltle.COMPARE;                                                                                     // FEQ FLT FLE
                FPUnewflags = FPUflags | FPUeqltle.flags;
            }
            default: {
                result = function7[1,1] ? dsh[0,1] ? sourceReg1 :                                                               // FMV.D.W
                                          dsh[1,1] ? { 48hffffffffffff, sourceReg1[0,16] } :                                    // FMV.H.W
                                                     { 32hffffffff, sourceReg1[0,32] } :                                        // FMV.S.W
                         function3[0,1] ? FPUclass.FCLASS :                                                                     // FCLASS
                                                    dsh[0,1] ? sourceReg1F :                                                    // FMV.W.D
                                                    dsh[1,1] ? { {48{sourceReg1F[15,1]}}, sourceReg1F[0,16] } :                 // FMV.W.H
                                                               { {32{sourceReg1F[31,1]}}, sourceReg1F[0,32] };                  // FMV.W.S
            }
        }
        frd = function7[3,1] ? function7[1,1] : ~|function7[3,2];                                                               // FRD for FMIN FMAX FSGNJ FSGNJN FSGNJX AND FMV.W.X
    }
}

// FPU CALCULATION CONTROLLER FOR FUSED ADD SUB MUL DIV SQRT - ALL CALCULATION UNITS USE AS INPUTS SINGLES, HALVES AND DOUBLES PACKED INTO DOUBLE BITFIELDS
// ALL CALCULATION UNITS RETURN SINGLES, HALVES, DOUBLES PACKED INTO DOUBLE BITFIELDS. CONVERTED TO ACTUAL REGISTER FORMAT BY THE CPU FLOATING POINT CONTROLLER
unit do_float_multiply(
    input   uint10  BIAS,                                                                                                       // FLOATING POINT BIAS
    input   uint64  sourceReg1Fx,                                                                                               // sourceReg1F ( repacked in double bitfields )
    input   uint64  sourceReg2Fx,                                                                                               // sourceReg2F ( repacked in double bitfields )
    output  uint106 productfraction,                                                                                            // PRODUCT sourceReg1F x sourceReg2F
    output  int13   productexp,                                                                                                 // EXPONENT sourceReg1F x sourceReg2F
    output  uint53  productnormal                                                                                               // NORMALISED FRACTION OF sourceReg1F x sourceReg2F
) <reginputs> {
    always_after {
        productnormal = productfraction[ { 3b110, productfraction[105,1], {2{~productfraction[105,1]}} }, 53 ];                 // NORMALISED PRODUCT RESULT FOR 0 ADDITION
        productfraction = { 1b1, fp64( sourceReg1Fx ).fraction } * { 1b1, fp64( sourceReg2Fx ).fraction };                      // CALCULATE THE PRODUCT BY MUTLIPLYING LEFT ALIGNED FRACTIONS
        productexp = ( fp64( sourceReg1Fx ).exponent + fp64( sourceReg2Fx ).exponent ) -                                        // ADD EXPONENTS FOR RESULT EXPONENT, REMOVE BIAS(2*) AND ( +1 if overflow )
                     ( { BIAS, 1b0 } ) + productfraction[105,1];
    }
}
unit floatcalc(
    input   uint1   start,                                                                                                      // START FLAG
    output  uint1   busy(0),                                                                                                    // BUSY FLAG
    input   uint1   rm,                                                                                                         // ROUND UP ALLOWED
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF FLAG ( to determine start bit for diviade and squareroot )
    input   uint10  BIAS,                                                                                                       // FLOATING POINT BIAS
    input   uint5   opCode,                                                                                                     // OPCODE, SINGLE OR FUSED OPERATIONS
    input   uint3   function3,                                                                                                  // ROUNDING MODE FLAG
    input   uint5   function7,                                                                                                  // DETERMINE SINGLE OPERATION
    input   uint64  sourceReg1Fx,                                                                                               // sourceReg1F ( repacked in double bitfields )
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO } OF INPUT sourceReg1F
    input   uint64  sourceReg2Fx,                                                                                               // sourceReg2F ( repacked in double bitfields )
    input   uint4   typeBF,                                                                                                     // { INF sNAN qNAN ZERO } OF INPUT sourceReg2F
    input   uint64  sourceReg3Fx,                                                                                               // sourceReg3F ( repacked in double bitfields )
    input   uint4   typeCF,                                                                                                     // { INF sNAN qNAN ZERO } OF INPUT sourceReg3F
    input   uint8   FPUflags,                                                                                                   // PRESENT FPUFLAGS
    output  uint5   FPUnewflags,                                                                                                // NEW FPUFLAGS
    output  uint64  result                                                                                                      // CALCULATION RESULT
) <reginputs> {
    doroundcombine MAKERESULT( dsh <: dsh, BIAS <: BIAS, rm <: rm );                                                            // DO ROUNDING AND COMBINING ( leave in double bitfields )

    uint64  b <:: { function7[0,1] ^ fp64( sourceReg2Fx ).sign, sourceReg2Fx[0,63] };                                           // SWITCH SIGN OF B FOR SUBTRACTION IF REQUIRED
    floataddsub FPUaddsub(                                                                                                      // FLOAT ADDITION ( SUBTRACTION by sign switch )
        BIAS <: BIAS,                                                                                                           // BIAS
        a <: sourceReg1Fx, typeAF <: typeAF,                                                                                    // A OPERAND FOR A+B
        b <: b, typeBF <: typeBF,                                                                                               // B OPERAND FOR A+B ( sign switched if subtraction )
        OF <: MAKERESULT.OF, UF <: MAKERESULT.UF, combined <: MAKERESULT.combined                                               // ROUNDED AND COMBINED RESULT
    );

    do_float_multiply MULT( BIAS <: BIAS, sourceReg1Fx <: sourceReg1Fx, sourceReg2Fx <: sourceReg2Fx );                         // GENERATE PRODUCT FRACTION AND EXPONENT FOR MULTIPLY AND FUSED
    floatmultiply FPUmultiply(                                                                                                  // FLOAT MULTIPLICATION
        signA <: fp64( sourceReg1Fx ).sign, typeAF <: typeAF,                                                                   // ONLY SIGN NEEDS PASSING FOR MULTIPLICATION
        signB <: fp64( sourceReg2Fx ).sign, typeBF <: typeBF,                                                                   // ONLY SIGN NEEDS PASSING FOR MULTIPLICATION
        OF <: MAKERESULT.OF, UF <: MAKERESULT.UF, combined <: MAKERESULT.combined                                               // ROUNDED AND COMBINED RESULT
    );
    floatfused FPUfused(                                                                                                        // FLOAT FUSED-MULTIPLY-ADD
        dsh <: dsh, BIAS <: BIAS,                                                                                               // BIAS
        rm <: rm, opCode <: opCode[0,2],                                                                                        // ROUNDING MODE AND SIGN SWITCHES
        signA <: fp64( sourceReg1Fx ).sign, typeAF <: typeAF,                                                                   // ONLY SIGN NEEDS PASSING FOR MULTIPLICATION
        signB <: fp64( sourceReg2Fx ).sign, typeBF <: typeBF,                                                                   // ONLY SIGN NEEDS PASSING FOR MULTIPLICATION
        c <: sourceReg3Fx, typeCF <: typeCF,                                                                                    // THIRD OPERAND FOR ADDITION/SIBTRATION
        productfraction <: MULT.productfraction, productexp <: MULT.productexp, productnormal <: MULT.productnormal,            // MULTIPLICATION RESULTS
        OF <: MAKERESULT.OF, UF <: MAKERESULT.UF, combined <: MAKERESULT.combined                                               // ROUNDED AND COMBINED RESULT
    );

    uint7   startbit <:: dsh[0,1] ? 107 : dsh[1,1] ? 23 : 49;                                                                   // DETERMINE STARTING BIT FOR THE LONG DIVISION ( HALVED FOR SQUAREROOT )
    floatdivide FPUdivide(                                                                                                      // FLOAT DIVISION
        dsh <: dsh,                                                                                                             // DOUBLE/SINGLE/HALF FLAG
        a <: sourceReg1Fx, typeAF <: typeAF,                                                                                    // A OPERAND FOR A/B
        b <: sourceReg2Fx, typeBF <: typeBF,                                                                                    // B OPERAND FOR A/B
        startbit <: startbit,                                                                                                   // PASS STARTING BIT
        OF <: MAKERESULT.OF, UF <: MAKERESULT.UF, combined <: MAKERESULT.combined                                               // ROUNDED AND COMBINED RESULT
    );

    floatsqrt FPUsqrt(                                                                                                          // FLOAT SQUARE ROOT https://projectf.io/posts/square-root-in-verilog/
        BIAS <: BIAS,                                                                                                           // BIAS
        a <: sourceReg1Fx, typeAF <: typeAF,                                                                                    // A OPERAND FOR SQRT(A)
        startbit <: startbit[1,6],                                                                                              // PASS STARTING BIT ( HALF OF DIVISION )
        OF <: MAKERESULT.OF, UF <: MAKERESULT.UF, combined <: MAKERESULT.combined                                               // ROUNDED AND COMBINED RESULT
    );

    uint5   unitbusy <:: { FPUfused.busy, FPUsqrt.busy, FPUdivide.busy, FPUmultiply.busy, FPUaddsub.busy };                     // UNIT BUSY FLAGS
    uint1   isbusy <:: |unitbusy;                                                                                               // WAIT FOR CALCULATIONS TO FINISH

    FPUaddsub.start := 0; FPUmultiply.start := 0; FPUdivide.start := 0; FPUsqrt.start := 0; FPUfused.start := 0;
    busy := start | isbusy;

    algorithm <autorun> {
        while(1) {
            if( start ) {
                if( opCode[2,1] ) {
                    switch( function7[0,2] ) {                                                                                  // START 2 REGISTER FPU OPERATIONS
                        default: { FPUaddsub.start = 1; }                                                                       // FADD FSUB
                        case 2b10: { FPUmultiply.start = 1; }                                                                   // FMUL
                        case 2b11: { FPUsqrt.start = function7[3,1]; FPUdivide.start = ~function7[3,1]; }                       // FSQRT / FDIV
                    }
                } else {
                    FPUfused.start = 1;                                                                                         // START 3 REGISTER FUSED FPU OPERATION
                }
            }
        }
    }

    always_after {
        uint5   flags = uninitialised;                                                                                          // UNIT RESULT FLAGS
        FPUnewflags = FPUflags[0,5] | flags;                                                                                    // RETURN NEW FLAGS

        if( isbusy ) {
            MAKERESULT.sign = |( { FPUfused.fusedsign, 1b0, FPUdivide.quotientsign, FPUmultiply.productsign, FPUaddsub.sumsign } & unitbusy );
            onehot( unitbusy ) {                                                                                                // SELECT SIGN, EXPONENT, NORMALISED FRACTION FOR ROUNDING AND COMBINING
                case 0: { MAKERESULT.exponent = FPUaddsub.sumexp; MAKERESULT.bitstream = FPUaddsub.normalfraction; }
                case 1: { MAKERESULT.exponent = MULT.productexp; MAKERESULT.bitstream = MULT.productnormal; }
                case 2: { MAKERESULT.exponent = FPUdivide.quotientexp; MAKERESULT.bitstream = FPUdivide.normalfraction; }
                case 3: { MAKERESULT.exponent = FPUsqrt.squarerootexp; MAKERESULT.bitstream = FPUsqrt.normalfraction; }
                case 4: { MAKERESULT.exponent = FPUfused.fusedexp; MAKERESULT.bitstream = FPUfused.normalfraction; }
            }
        }

        if( opCode[2,1] ) {                                                                                                     // SINGLE OPERATION
                switch( function7[0,2] ) {
                    default: { result = FPUaddsub.result; flags = FPUaddsub.flags & 5b00110; }                                  // FADD FSUB
                    case 2b10: { result = FPUmultiply.result; flags = FPUmultiply.flags & 5b00110; }                            // FMUL
                    case 2b11: {                                                                                                // FSQRT FDIV
                        result = function7[3,1] ? FPUsqrt.result : FPUdivide.result;
                        flags = function7[3,1] ? FPUsqrt.flags & 5b00110 : FPUdivide.flags & 5b01110;
                    }
                }
        } else {                                                                                                                // FUSED OPERATIONS
            result = FPUfused.result; flags = FPUfused.flags & 5b10110;
        }
    }
}

// IDENTIFY { infinity, signalling NAN, quiet NAN, ZERO } CHECKS FOR NAN-BOXING OF FLOAT
unit typeF(
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF
    input   uint64  a,                                                                                                          // REGISTER VALUE TO CHECK
    output  uint4   type                                                                                                        // { INF sNAN qNAN ZERO } OF INPUT REGISTER
) <reginputs> {
    uint1   expFF <:: ( dsh[0,1] ? &fp64(a).exponent : dsh[1,1] ? &fp16(a).exponent : &fp32(a).exponent );                      // CHECK FOR EXP == ALL 1s ( signals INF/NAN )
    uint1   exp00 <:: ~|( dsh[0,1] ? fp64(a).exponent : dsh[1,1] ? fp16(a).exponent : fp32(a).exponent );                       // CHECK FOR EXP == ALL 0s ( signals ZERO/SUBNORMAL )
    uint1   zeroFRACTION <:: ( dsh[0,1] ? ~|fp64(a).fraction : dsh[1,1] ? ~|fp16(a).fraction : ~|fp32(a).fraction );            // FRACTION == 0 INF, == 100... qNAN, == 0xxx... ( xxx... != 0 ) sNAN
    uint1   NANboxed <:: ~dsh[0,1] & ( dsh[1,1] ? &a[16,48] : &a[32,32] );                                                      // CHECK SINGLE/HALF IS NAN BOXED
    uint6   MSB <:: dsh[0,1] ? 51 : dsh[1,1] ? 9 : 22;                                                                          // IDENTIFY MOST SIGNIFICANT BIT TO ALLOW CHECKING BETWEEN sNAN AND qNAN

    always_after {
        type = dsh[0,1] | NANboxed ? {
                                        expFF & zeroFRACTION,                                                                   // INF
                                        expFF & ~fp64(a).fraction[MSB,1] & ~zeroFRACTION,                                       // sNAN
                                        expFF & fp64(a).fraction[MSB,1],                                                        // qNAN
                                        exp00                                                                                   // ZERO / SUBNORMAL
                                    } : 4b0010;                                                                                 // SINGLE/HALF NOT BOXED, ISSUE qNAN
    }
}

// EXECPTION RETURN VALUES signed infinity, signalling NAN, quiet NAN, signed zero
// RETURN VALUES IN _wide repacked format
unit wide_special(
    input   uint1   sign,
    output  uint64  xINF,
    output  uint64  sNAN,
    output  uint64  qNAN,
    output  uint64  xZERO
) <reginputs> {
    always_after {
        xINF = { sign, 63h7FF0000000000000 };
        sNAN = 64h7FF4000000000000;
        qNAN = 64h7FF8000000000000;
        xZERO = { sign, 63h0 };
    }
}
unit wide_xINF(
    input   uint1   sign,
    output  uint64  value
) <reginputs> {
    always_after {
        value = { sign, 63h7FF0000000000000 };
    }
}
unit wide_xZERO(
    input   uint1   sign,
    output  uint64  value
) <reginputs> {
    always_after {
        value = { sign, 63h0 };
    }
}

// EXECPTION RETURN VALUES signed infinity, signalling NAN, quiet NAN, signed zero
// RETURN VALUES IN _actual format
unit actual_special(
    input   uint2   dsh,
    input   uint1   sign,
    output  uint64  xINF,
    output  uint64  sNAN,
    output  uint64  qNAN,
    output  uint64  xZERO
) <reginputs> {
    always_after {
        xINF = dsh[0,1] ? { sign, 63h7FF0000000000000 } : dsh[1,1] ? { 48hffffffffffff, sign, 15h7C00 } : { 32hffffffff, sign, 31h7f800000 };
        sNAN = dsh[0,1] ? 64h7FF4000000000000 : dsh[1,1] ? 64hffffffffffff7d00 : 64hffffffff7fa00000;
        qNAN = dsh[0,1] ? 64h7FF8000000000000 : dsh[1,1] ? 64hffffffffffff7e00 : 64hffffffff7fc00000;
        xZERO = dsh[0,1] ? { sign, 63h0 } : dsh[1,1] ? { 48hffffffffffff, sign, 15b0 } : { 32hffffffff, sign, 31h0 };
    }
}
unit actual_qNAN(
    input   uint2   dsh,
    output  uint64  value
) <reginputs> {
    always_after {
        value = dsh[0,1] ? 64h7FF8000000000000 : dsh[1,1] ? 64hffffffffffff7e00 : 64hffffffff7fc00000;
    }
}
unit actual_xZERO(
    input   uint2   dsh,
    input   uint1   sign,
    output  uint64  value
) <reginputs> {
    always_after {
        value = dsh[0,1] ? { sign, 63h0 } : dsh[1,1] ? { 48hffffffffffff, sign, 15b0 } : { 32hffffffff, sign, 31h0 };
    }
}


// REPACKERS, ALL FLOATING POINT NUMBERS ARE PASSED TO CALCULATIONS IN THE BITFIELD OF A DOUBLE TO ALLOW EASIER EXTRACTION OF THE SIGN, EXPONENT AND FRACTIONS
// _WIDE, copies double to double, single/half to the bitfields of a double
// _ACTUAL, copies double to double, a repacked wide single/half to the bitfields of a single/half
unit repackage_actual(                                                                                                          // REPACKAGE A DOUBLE/SINGLE/HALF FROM THE BITFIELDS OF A DOUBLE
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF FLAG
    input   uint64  a,                                                                                                          // FLOATING POINT SOURCE REGISTER
    output  uint64  repack                                                                                                      // REPACKED FLOATING POINT REGISTER
) <reginputs> {
    always_after {
        repack = dsh[0,1] ? a :                                                                                                 // RETURN DOUBLE UNCHANGED
                 dsh[1,1] ? { 48hffffffffffff, fp64( a ).sign, fp64( a ).exponent[0,5], fp64( a ).fraction[42,10] } :           // RETURN HALF REPACKED ( NANboxed )
                            { 32hffffffff, fp64( a ).sign, fp64( a ).exponent[0,8], fp64( a ).fraction[29,23] };                // RETURN SINGLE REPACKED ( NANboxed )
    }
}
unit repackage_wide(                                                                                                            // REPACKAGE A DOUBLE/SINGLE/HALF INTO THE BITFIELDS OF A DOUBLE
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF FLAG
    input   uint64  a,                                                                                                          // FLOATING POINT SOURCE REGISTER
    output  uint64  repack                                                                                                      // REPACKED FLOATING POINT REGISTER
) <reginputs> {
    always_after {
        repack = dsh[0,1] ? a :                                                                                                 // RETURN DOUBLE UNCHANGED
                 dsh[1,1] ? { fp16( a ).sign, 6b0, fp16( a ).exponent, fp16( a ).fraction, 42b0 } :                             // RETURN HALF REPACKED
                            { fp32( a ).sign, 3b0, fp32( a ).exponent, fp32( a ).fraction, 29b0 };                              // RETURN SINGLE REPACKED
    }
}

// MAKE A DOUBLE FLOATING-POINT NUMBER FROM SIGN, EXPONENT AND FRACTION
unit make_wide(
    input   uint1   sign,                                                                                                       // SIGN
    input   uint11  exp,                                                                                                        // EXPONENT
    input   uint52  fraction,                                                                                                   // FRACTION
    output  uint64  wide                                                                                                        // PACKED INTO DOUBLE BITFIELDS
) <reginputs> {
    always_after {
        wide = { sign, exp, fraction };                                                                                         // PACK SIGN, EXPONENT AND FRACTION INTO DOUBLE BITFIELDS
    }
}

// MAKE ACTUAL DOUBLE/SINGLE/HALF FROM SIGN, EXPONENT AND FRACTION
unit make_actual(                                                                                                               // REPACKAGE A DOUBLE/SINGLE/HALF FROM THE BITFIELDS OF A DOUBLE
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF FLAG
    input   uint1   sign,                                                                                                       // SIGN
    input   uint11  exp,                                                                                                        // EXPONENT
    input   uint52  fraction,                                                                                                   // FRACTION
    output  uint64  repack                                                                                                      // REPACKED FLOATING POINT REGISTER
) <reginputs> {
    always_after {
        repack = dsh[0,1] ? { sign, exp, fraction } :                                                                           // RETURN DOUBLE UNCHANGED
                 dsh[1,1] ? { 48hffffffffffff, sign, exp[0,5], fraction[42,10] } :                                              // RETURN HALF REPACKED ( NANboxed )
                            { 32hffffffff, sign, exp[0,8], fraction[29,23] };                                                   // RETURN SINGLE REPACKED ( NANboxed )
    }
}

// NORMALISE A 106 BIT MANTISSA SO THAT THE MSB IS ONE, FOR ADDSUB ALSO DECREMENT THE EXPONENT FOR EACH SHIFT LEFT
// EXTRACT THE 53 BITS FOLLOWING THE MSB (1.xxxx) FOR ROUNDING
unit donormal(
    input   uint106 bitstream,                                                                                                  // RESULT FROM CALCULATION
    output  uint53  normalfraction                                                                                              // NORMALISED FRACTION 1.xxx
) <reginputs> {
    uint106 temporary <:: ( bitstream << CLZ.count );                                                                           // SHIFT FRACTION LEFT SO 1.xxxx
    clz106 CLZ( bitstream <: bitstream );                                                                                       // COUNT LEADING ZEROS

    always_after {
        normalfraction = temporary[ 52, 53 ];                                                                                   // EXTRACT 53 BITS ( 1 extra for rounding )
    }
}
unit donormalexp(
    input   int13   exp,                                                                                                        // EXPONENT FROM ADDITION / SUBTRACTION
    input   uint106 bitstream,                                                                                                  // RESULT FROM CALCULATION
    output  int13   newexponent,                                                                                                // ADJUSTED EXPONENT FOR ADDITION / SUBTRACTION
    output  uint53  normalfraction                                                                                              // NORMALISED FRACTION 1.xxx
) <reginputs> {
    uint106 temporary <:: ( bitstream << CLZ.count );                                                                           // SHIFT FRACTION LEFT SO 1.xxxx
    clz106 CLZ( bitstream <: bitstream );                                                                                       // COUNT LEADING ZEROS

    always_after {
        normalfraction = temporary[ 52, 53 ];                                                                                   // EXTRACT 53 BITS ( 1 extra for rounding )
        newexponent = exp - CLZ.count;                                                                                          // ADDSUB EXPONENT ADJUSTMENT
    }
}

// ROUND 52 ( double ) 23 ( single ) 11 ( galf ) BIT FRACTION FROM NORMALISED FRACTION USING NEXT TRAILING BIT
// ADD BIAS TO EXPONENT AND ADJUST EXPONENT IF ROUNDING FORCES
// COMBINE COMPONENTS TO FLOATING POINT NUMBER IN DOUBLE BITFIELDS  - USED BY CALCULATIONS
// UNDERFLOW return 0, OVERFLOW return infinity
unit doroundcombine(
    input   uint1   rm,                                                                                                         // ROUNDING MODE ( RNE OR RTZ SUPPORTED )
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF FLAG
    input   uint10  BIAS,                                                                                                       // FLOATING POINT BIAS FOR DESTINATION DOUBLE/SINGLE/HALF
    input   uint1   sign,                                                                                                       // RESULT SIGN
    input   uint53  bitstream,                                                                                                  // NORMALISED BITSTREAM 1.xxxx
    input   int13   exponent,                                                                                                   // EXPONENT ( no bias )
    output  uint1   OF,                                                                                                         // OVERFLOW FLAG
    output  uint1   UF,                                                                                                         // UNDERFLOW FLAG
    output  uint64  combined                                                                                                    // COMBIUNED DOUBLE/SINGLE/HALF ROUNDED AND COMBINED
) <reginputs> {
    uint1   roundbit <:: ( dsh[0,1] ? bitstream[0,1] : dsh[1,1] ? bitstream[42,1] : bitstream[29,1] ) & rm;                     // FIND ROUNDING BITAND SET IF ROUNDING MODE
    uint43  roundmask <:: ( dsh[0,1] ? roundbit : dsh[1,1] ? { roundbit, 42b0 } : { roundbit, 29b0 } );
    uint53  roundedfraction <:: bitstream[1,52] + roundmask;                                                                              // EXTRACT 52 BITS AND ADD ON ROUNDING MASK ( 53 bits to detect overflow )
    int13   newexponent <:: BIAS + exponent + roundedfraction[52,1];                                                            // CREATE EXPONENT BY ADDING BIAS AND OVERFLOW
    make_wide COMBINED( sign <: sign, exp <: newexponent[0,11], fraction <: roundedfraction );                                  // MAKE COMBINED RESULT IN DOUBLE BITFIELDS

    wide_xINF xINF( sign <: sign );                                                                                             // SIGNED INFINITY RETURN VALUE
    wide_xZERO xZERO( sign <: sign );                                                                                           // SIGNED ZERO RETURN VALUE

    always_after {
        OF = __signed(newexponent) > __signed( { 1b0, BIAS, 1b0 } );                                                            // OVERFLOW IF EXPONENT IS GREATER THAN ( 2 * BIAS )
        UF = newexponent[12,1];                                                                                                 // UNDERFLOW IF EXPONENT IS STILL NEGATIVE AFTER BIAS ADDED
        combined = UF ? xZERO.value : OF ? xINF.value : COMBINED.wide;                                                          // UNDERFLOW RETURN SIGNED ZERO, OVERFLOW RETTURN SIGNED INFINITY, ELSE COMBINED
    }
}

// CONVERSIONS TO HANDLE FCVT.dest.source
unit intlong2float(                                                                                                             // 32/64 BIT INTEGER TO 16/32/64 BIT FLOATING POINT
    input   uint1   rm,                                                                                                         // ROUDNING MODE
    input   uint1   dounsigned,                                                                                                 // UNSIGNED CONVERSION FLAG
    input   uint1   il,                                                                                                         // FROM INTEGER == 0 OR LONG == 1
    input   uint2   dsh,                                                                                                        // TO DOUBLE == 01 SINGLE == 00 HALF == 10
    input   uint10  BIAS,                                                                                                       // BIAS FOR DOUBLE/SINGLE/HALF
    input   uint64  sourceReg1,                                                                                                 // REGISTER VALUE TO CONVERT
    input   uint32  S1_abs32,                                                                                                   // 32 bit ABSOLUTE VALUE
    input   uint64  S1_abs64,                                                                                                   // 64 bit ABSOLUTE VALUE
    output  uint64  result,                                                                                                     // RESULTING DOUBLE/SINGLE/HALF
    output  uint1   FPUflags                                                                                                    // FPU FLAGS
) <reginputs> {
    uint1   sign <:: ~dounsigned & sourceReg1[ { il, 5b11111 }, 1 ];                                                            // EXTRACT SIGN IF SIGNED CONVERSION
    uint64  number <:: il ? sign ? S1_abs64 : sourceReg1 : sign ? S1_abs32 : sourceReg1[0,32];                                  // EXTRACT ABSOLUTE VALUE
    clz64 CLZ( number <: number );                                                                                              // COUNT LEADING ZEROS

    uint64  fraction <:: number << CLZ.zeros;                                                                                   // GENERATE FRACTION BY SHIFTING TO THE LEFT
    uint1   roundbit <:: ( dsh[0,1] ? fraction[10,1] : dsh[1,1] ? fraction[52,1] : fraction[39,1] ) & rm;                       // EXTRACT ROUNDING BIT AND SET IF ROUNDING MODE
    uint43  roundmask <:: ( dsh[0,1] ? roundbit : dsh[1,1] ? { roundbit, 42b0 } : { roundbit, 29b0 } );
    uint53  roundedfraction <:: fraction[11,52] + roundmask;                                                                    // GENERATE ROUNDED FRACTION BY EXTRACTING 52 BITS AND ADD ON ROUNDING MASK
    uint11  exponent <:: 63 + BIAS - CLZ.zeros + roundedfraction[52,1];                                                         // GENERATE EXPONENT AND ADD BIAS + 63 - CLZ + OVERFLOW
    make_actual TOFLOAT( dsh <: dsh, sign <: sign, exp <: exponent, fraction <: roundedfraction );                              // PACKAGE COMPONENTS INTO FLOATING-POINT BITFIELDS ( NANboxed for single/half )

    actual_xZERO ZERO ( dsh <: dsh );                                                                                           // ZERO RETURN VALUE FOR DOUBLE/SINGLE/HALF

    uint1   zlt <:: ( CLZ.zeros < ( dsh[0,1] ? 11 : dsh[1,1] ? 53 : 40 ) );                                                     // CHECK IF INEXACT, TOO MANY BITS

    always_after {
        result =  ~|( il ? sourceReg1 : sourceReg1[0,32] ) ? ZERO.value : TOFLOAT.repack;                                       // RETURN ZERO OR FLOATING-POINT CONVERSION
        FPUflags = dsh[0,1] ? ( il ? zlt : 0 ) : zlt;                                                                           // FLAGS NOT EXACT, TOO MANY BITS
    }
}

unit float2intlong(                                                                                                             // 16/32/64 BIT FLOATING POINT TO 32/64 BIT INTEGER
    input   uint1   rm,                                                                                                         // ROUDNING MODE
    input   uint1   dounsigned,                                                                                                 // UNSIGNED CONVERSION FLAG
    input   uint1   il,                                                                                                         // TO INTEGER == 0 OR LONG == 1
    input   uint10  BIAS,                                                                                                       // BIAS FOR DOUBLE/SINGLE/HALF
    input   uint64  sourceReg1Fx,                                                                                               // REGISTER VALUE TO CONVERT ( repacke into double bitfields )
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO } OF INPUT REGISTER
    output  uint64  result,                                                                                                     // RESULTING LONG OR INTEGER
    output  uint5   FPUflags                                                                                                    // FPU FLAGS
) <reginputs> {
    int13   exp <:: fp64( sourceReg1Fx ).exponent - BIAS;                                                                       // EXTRACT EXPONENT AND REMOVE BIAS
    uint65  fraction <:: { 1b1, fp64( sourceReg1Fx ).fraction, 12b0 } >> ( 63 - exp );                                          // EXTRACT FRACTION AND EXTEND TO 65 BITS, SHIFT INTO POSITION
    uint1   roundingbit <:: fraction[0,1] & rm;                                                                                 // EXTRACT ROUNDING BIT
    uint64  unsignedfraction <:: ( il ? fraction[1,64] : fraction[1,32] ) + roundingbit;                                        // GENERATE ROUNDED 32/64 bit ABSOLUTE INTEGER
    uint1   NV <:: ( __signed( exp ) > __signed( ( il ? 62 : 30 ) | dounsigned ) ) | ( dounsigned & fp64( sourceReg1Fx ).sign ) // INVALID IF TOO LARGE, UNSIGNED AND NEGATIVE, INFINITY OR NAN
                   | |typeAF[1,3];

    uint64  min <:: il ? 64h8000000000000000 : 64hffffffff80000000;                                                             // MINIMUM NEGATIVE INTEGER
    uint64  max <:: il ? 64h7fffffffffffffff : 64h000000007fffffff;                                                             // MAXIMUM POSITIVE INTEGER

    always_after {
        if( typeAF[0,1] ) {
            result = 0;                                                                                                         // ZERO INPUT RETURN ZERO
        } else {
            if( dounsigned ) {
                result = NV ? { {64{~fp64( sourceReg1Fx ).sign}} } : unsignedfraction;                                          // 0 IF SIGNED, -1 IF NAN OR +INF ELSE RETURN UNSIGNED FRACTION
            } else {
                result = NV ? fp64( sourceReg1Fx ).sign ? min :                                                                 // MIN FOR SIGNED OUT OF RANGE
                                     max :                                                                                      // MAX FOR UNSIGNED OUT OF RANGE
                         il ? fp64( sourceReg1Fx ).sign ? -unsignedfraction : unsignedfraction :                                // RETURN CORRECTLY SIGNED RESULT
                              fp64( sourceReg1Fx ).sign ? { 32hffffffff, -unsignedfraction[0,32] } :                            // IF SIGN, SIGN EXTEND 32 BIT INTEGER
                                                          { {32{unsignedfraction[31,1]}}, unsignedfraction[0,32] };
            }
        }
        FPUflags = { NV, 4b0000 };
    }
}


unit changeprecision(                                                                                                           // DOUBLE/SINGLE/HALF <-> DOUBLE/SINGLE/HALF ( EXTEND OR TRUNCATE )
    input   uint1   rm,                                                                                                         // ROUDNING MODE
    input   uint2   dest,                                                                                                       // TO DOUBLE(01)/SINGLE(00)/HALF(10)
    input   uint10  DBIAS,                                                                                                      // BIAS FOR DOUBLE/SINGLE/HALF DESTINATION
    input   uint2   source,                                                                                                     // FROM DOUBLE(01)/SINGLE(00)/HALF(10)
    input   uint10  SBIAS,                                                                                                      // BIAS FOR DOUBLE/SINGLE/HALF SOURCE
    input   uint64  sourceReg1Fx,                                                                                               // REGISTER VALUE TO EXTEND / TRUNCATE ( in double bitfields )
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO }
    output  uint64  result,                                                                                                     // EXTENDED OR TRUNCATED RESULT
    output  uint3   FPUflags                                                                                                    // FPU FLAGS
) <reginputs> {
    uint1   roundbit <:: ( dest[0,1] ? 0 :                                                                                      // EXTRACT ROUNDING BIT AND SET IF ROUNDING MODE
                           dest[1,1] ? fp64( sourceReg1Fx ).fraction[41,1] :
                                       fp64( sourceReg1Fx ).fraction[28,1] ) & rm;
    uint43  roundmask <:: ( dest[0,1] ? roundbit : dest[1,1] ? { roundbit, 42b0 } : { roundbit, 29b0 } );
    uint53  roundedfraction <:: fp64( sourceReg1Fx ).fraction + roundmask;                                                      // EXTRACT FRACTION AND ADD ON ROUNDING MASK, 53 BITS TO DETECT OVERFLOW
    int13   exp <:: fp64( sourceReg1Fx ).exponent - SBIAS + DBIAS + roundedfraction[52,1];                                      // SELECT EXPONENT AND SUBTRACT SOURCE BIAS, ADD DESTINATION BIAS AND OVERFLOW
    make_actual REPACK( dsh <: dest, sign <:  fp64( sourceReg1Fx ).sign, exp <: exp[0,11], fraction <: roundedfraction );       // PACKAGE COMPONENTS INTO FLOATING-POINT BITFIELDS WITH NAN-BOXING

    actual_special SPECIAL( dsh <: dest[0,2], sign <: fp64( sourceReg1Fx ).sign );                                              // GENERATE xINF, sNAN, qNAN, xZERO FOR DESTINATION FORMAT

    uint1   truncateOF <:: __signed(exp) > __signed( { 1b0, DBIAS, 1b0 });                                                      // CHECK IF NEW EXPONENT IS TOO LARGE ( > 2*BIAS for single/half)
    uint1   truncateUF <:: exp[12,1];                                                                                           // CHECK IF NEW EXPONENT IS TOO SMALL ( negative for single/half )
    uint1   NX <:: source[0,1] | ( ~|source & dest[1,1] );                                                                      // NOT EXACT IF DOUBLE -> SINGLE/HALF OR SINGLE -> HALF (need to check dropped bits)

    always_after {
        if( |typeAF ) {                                                                                                         // INPUT IS INF, SNAN, QNAN, ZERO
            onehot( typeAF ) {
                case 3: { result = SPECIAL.xINF; }                                                                              // REPACKAGED INFINITY
                case 2: { result = SPECIAL.sNAN; }                                                                              // REPACKAGED sNAN
                case 1: { result = SPECIAL.qNAN; }                                                                              // REPACKAGED qNAN
                case 0: { result = SPECIAL.xZERO; }                                                                             // REPACKAGED ZERO
            }
            FPUflags = 0;                                                                                                       // RETURN FLAGS
        } else {
            result = truncateOF ? SPECIAL.xINF : truncateUF ? SPECIAL.xZERO : REPACK.repack;                                    // OVERFLOW -> INF, UNDERFLOW -> ZERO, REPACKAGED RESULT
            FPUflags = { truncateOF, truncateUF, NX };                                                                          // RETURN FLAGS
        }
    }
}

// ADDSUB ADD/SUBTRACT TWO FLOATING POINT NUMBERS ( SUBTRACT ACHIEVED BY ALTERING SIGN OF SECOND INPUT BY CALCULATION CONTROL UNIT ABOVE )
unit do_addsub_align(                                                                                                           // ALIGN FRACTIONS BASED UPON EXPONENTS
    input   uint10  BIAS,                                                                                                       // BIAS FOR DOUBLE/SINGLE/HALF
    input   uint11  expA,                                                                                                       // EXPONENT OF A INCLUDING BIAS
    input   uint52  fractionA,                                                                                                  // FRACTION OF A ( no leading 1 bit )
    input   uint11  expB,                                                                                                       // EXPONENT OF B INCLUDING BIAS
    input   uint52  fractionB,                                                                                                  // FRACTION OF B ( no leading 1 bit )
    output  uint106 sigA,                                                                                                       // ALIGNED FRACTION OF A ( including leading 1 bit )
    output  uint106 sigB,                                                                                                       // ALIGNED FRACTION OF B ( including leading 1 bit )
    output  int13   resultexp                                                                                                   // PROVISIONAL EXPONENT OF RESULT ( largest input exponent, bias removed )
) <reginputs> {
    uint1   expAvexpB <:: ( expA < expB );                                                                                      // FIND SMALLEST EXPONENT
    uint11  shift <:: ( expAvexpB ? expB : expA ) - ( expAvexpB ? expA :expB );                                                 // FIND THE AMOUNT SMALLER NUMBER NEEDS TO BE SHIFTED FOR ALIGNMENT

    always_after {
        sigA = { 2b01, fractionA, 52b0 } >> ( expAvexpB ? shift : 0 );                                                          // GENERATE A FROM FRACTION, ALIGN IF SMALLER
        sigB = { 2b01, fractionB, 52b0 } >> ( expAvexpB ? 0 : shift );                                                          // GENERATE B FROM FRACTION, ALIGN IF SMALLER
        resultexp = ( expAvexpB ? expB : expA ) - ( { BIAS[1,9], 1b0 } );                                                       // RESULT EXPONENT IS LARGEST EXPONENT, remove ( bias - 1 ) FOR OVERFLOW
    }
}
unit do_float_addsub(
    input   uint1   signA,
    input   uint106 sigA,
    input   uint1   signB,
    input   uint106 sigB,
    output  uint1   resultsign,
    output  uint106 resultfraction
) <reginputs> {
    uint1   AvB <:: ( sigA > sigB );                                                                                            // FIND LARGEST FRACTION ( when exponents are equal )
    uint1   sign <:: ( signA ^ signB ) ? ( signA ? AvB : ~AvB ) : signA;                                                        // DETERMINE RESULT SIGN

    always_after {
        resultsign = sign;                                                                                                      // RETURN RESULT SIGN
        resultfraction = ( signA ^ signB ) ? ( ( signA ^ sign ? sigB : sigA ) - ( signA ^ sign ? sigA : sigB ) ) :              // DIFFERING SIGNS, SUBTRACTION
                                             ( sigA + sigB );                                                                   // SAME SIGNS ADDITION
    }
}
unit floataddsub(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint10  BIAS,                                                                                                       // BIAS FOR DOUBLE/SINGLE/HALF
    input   uint64  a,                                                                                                          // A INPUT FOR A+B OR A-B
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO } FOR A
    input   uint64  b,                                                                                                          // B INPUT FOR A+B OR A-B
    input   uint4   typeBF,                                                                                                     // { INF sNAN qNAN ZERO } FOR B
    output  uint1   sumsign,                                                                                                    // RESULT SIGN
    output  int13   sumexp,                                                                                                     // RESULT EXPONENT
    output  uint53  normalfraction,                                                                                             // NORMALISED RESULT FRACTION
    input   uint1   OF,                                                                                                         // OVERFLOW FLAG
    input   uint1   UF,                                                                                                         // UNDERFLOW FLAG
    input   uint64  combined,                                                                                                   // DOUBLE/SINGLE/HALF RESULT ROUNDED AND COMBINED
    output  uint5   flags,                                                                                                      // OPERATION FLAGS
    output  uint64  result                                                                                                      // RESULT OF CALCULATION
) <reginputs> {
    uint1   IF <:: ( typeAF[3,1] | typeBF[3,1] );                                                                               // DETECT INFINITY
    uint1   NN <:: ( |typeAF[1,2] | |typeBF[1,2] );                                                                             // DETECT NAN
    uint1   NV <:: ( typeAF[3,1] & typeBF[3,1]) & ( fp64( a ).sign ^ fp64( b ).sign );                                          // INVALID IF BOTH INFINITY WITH DIFFERING SIGNS
    uint2   ACTION <:: { IF | NN, typeAF[0,1] | typeBF[0,1] };                                                                  // DO ADDITION IF NOT INFINITY, NAN OR ZERO

    do_addsub_align ALIGN(                                                                                                      // ALIGN THE FRACTIONS
        BIAS <: BIAS,                                                                                                           // MOVE THE FRACTION WITH THE SMALLEST EXPONENT RIGHT
        expA <: fp64( a ).exponent, fractionA <: fp64( a ).fraction,
        expB <: fp64( b ).exponent, fractionB <: fp64( b ).fraction
    );
    do_float_addsub ADDSUB(                                                                                                     // PERFORM THE ADDITION/SUBTRACTION, ACCOUNTING FOR SIGNS
        signA <: fp64( a ).sign, sigA <: ALIGN.sigA,                                                                            // SPECIAL CASE FOR SUBTRACTION WHEN EQUAL EXPONENTS
        signB <: fp64( b ).sign, sigB <: ALIGN.sigB,                                                                            // AND SECOND FRACTION IS LARGER THAN THE FIRST
        resultsign :> sumsign
    );
    donormalexp NORMAL(                                                                                                         // NORMALISE THE RESULT
        exp <: ALIGN.resultexp,                                                                                                 // 1 IS ADDED TO THE EXPONENT IN CASE OF OVERFLOW,
        bitstream <: ADDSUB.resultfraction,                                                                                     // NORMALISING WILL ADJUST
        newexponent :> sumexp,
        normalfraction :> normalfraction
    );

    uint1   wait(0);

    busy := start | wait;
    flags := { NV, 1b0, ~|ACTION & OF, ~|ACTION & UF, 1b0 };

    algorithm <autorun> {
        while(1) {
            if( start ) { wait = 1; } else { wait = 0; }                                                                        // PROVIDE WAIT STATES
        }
    }

    always_after {
        switch( ACTION ) {
            case 2b00: { result = |ADDSUB.resultfraction ? combined : 0; }                                                      // CALCULATION IS VALID, CHECK FOR ZERO RESULT
            case 2b01: {
                result = ( typeAF[0,1] & typeBF[0,1] ) ? 0 : ( typeBF[0,1] ? a : b );                                           // BOTH ZERO, RETURN ZERO.  ONE ZERO, RETURN OTHER
            }
            default: {
                switch( { IF, NN } ) {
                    case 2b10: { result = NV ? 64h7FF8000000000000 : ( typeAF[3,1] ? a : b ); }                                 // INFINITY RETURN NAN IF OPPOSITE SIGNS ELSE RETURN INFINITY
                    default: { result = 64h7FF8000000000000; }                                                                  // NAN RETURN NAN
                }
            }
        }
    }
}

// MULTIPLY TWO FLOATING POINT NUMBERS
unit floatmultiply(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint1   signA,                                                                                                      // SIGN OF A INPUT FOR A*B
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO } FOR A
    input   uint1   signB,                                                                                                      // SIGN OF B INPUT FOR A*B
    input   uint4   typeBF,                                                                                                     // { INF sNAN qNAN ZERO } FOR B
    output  uint1   productsign,                                                                                                // RESULT SIGN
    input   uint1   OF,                                                                                                         // OVERFLOW FLAG
    input   uint1   UF,                                                                                                         // UNDERFLOW FLAG
    input   uint64  combined,                                                                                                   // DOUBLE/SINGLE/HALF RESULT ROUNDED AND COMBINED
    output  uint5   flags,                                                                                                      // OPERATION FLAGS
    output  uint64  result                                                                                                      // RESULT OF CALCULATION
) <reginputs> {
    uint1   ZERO <:: (typeAF[0,1] | typeBF[0,1] );                                                                              // DETECT ZERO
    uint1   IF <:: ( typeAF[3,1] | typeBF[3,1] );                                                                               // DETECT INFINITY
    uint1   NN <:: ( |typeAF[1,2] | |typeBF[1,2] );                                                                             // DETECT NAN
    uint1   NV <:: IF & ZERO;                                                                                                   // INVALID IF INFINITY x ZERO
    uint2   ACTION <:: { IF | NN, ZERO };

    wide_xINF xINF( sign <: productsign );
    wide_xZERO xZERO( sign <: productsign );

    uint1   wait(0);

    busy := start | wait;
    flags := { NV, 1b0, ~|ACTION & OF, ~|ACTION & UF, 1b0 };                                                                    // RETURN FLAGS

    algorithm <autorun> {
        while(1) {
            if( start ) { wait = 1; } else { wait = 0; }                                                                        // PROVIDE WAIT STATES
        }
    }

    always_after {
        productsign = signA ^ signB;                                                                                            // PRODUCT SIGN XOR SIGNS
        switch( ACTION ) {
            case 2b00: { result = combined; }                                                                                   // MULTIPLICATION IS VALID
            case 2b01: { result = xZERO.value; }                                                                                // ZERO INPUT RETURN ZERO
            default: {
                switch( { IF, ZERO } ) {
                    case 2b11: { result = 64h7FF8000000000000; }                                                                // INFINITY x ZERO RETURN qNAN
                    case 2b10: { result = NN ? 64h7FF8000000000000 : xINF.value; }                                              // NAN OR INFITITY RETURN qNAN OR INFINITY
                    default: { result = 64h7FF8000000000000; }                                                                  // NAN OR ZERO RETURN qNAN
                }
            }
        }
    }
}

// FUSED MULTIPLY AND ADD ( A*B+C A*B-C -A*B+C -A*B-C )
unit do_addsub_align_fused(                                                                                                     // ALIGN FRACTIONS BASED UPON EXPONENTS ( exponents passed with no bias )
    input   int13   expA,                                                                                                       // EXPONENT OF MULTIPLICATION RESULT ( may be out of normal range )
    input   uint106 fractionA,                                                                                                  // RESULT OF MULTIPLICATION ( including leading 1 bit )
    input   int13   expB,                                                                                                       // EXPONENT OF INPUT C ( bias removed )
    input   uint52  fractionB,                                                                                                  // FRACTION OF INPUT C ( no leading 1 bit )
    output  uint106 sigA,                                                                                                       // ALIGNED FRACTION OF MULTIPLICATION ( including leading 1 bit )
    output  uint106 sigB,                                                                                                       // ALIGNED FRACTION OF INPUT C ( including leading 1 bit )
    output  int13   fusedexp                                                                                                    // LARGEST EXPONENT OF MULTIPLICATION RESULT AND INPUT C
) <reginputs> {
    uint1   expAvexpB <:: ( __signed(expA) < __signed(expB) );                                                                  // FIND SMALLEST EXPONENT
    int13   shift <:: ( expAvexpB ? expB : expA ) - ( expAvexpB ? expA :expB );                                                 // FIND THE AMOUNT SMALLER NUMBER NEEDS TO BE SHIFTED FOR ALIGNMENT

    always_after {
        sigA = ( fractionA[105,1] ? { 1b0, fractionA[1,105] } : fractionA ) >> ( expAvexpB ? shift : 0 );                       // ALIGN A IF SMALLER
        sigB = { 2b01, fractionB, 52b0 } >> ( expAvexpB ? 0 : shift );                                                          // GENERATE B FROM FRACTION, ALIGN IF SMALLER
        fusedexp = ( expAvexpB ? expB : expA ) + 1;                                                                             // RESULT EXPONENT IS LARGEST EXPONENT ( +1 FOR OVERFLOW ) ( remove bias )
    }
}
unit floatfused(
    input   uint1   start,
    output  uint1   busy,
    input   uint2   opCode,
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF FLAG
    input   uint10  BIAS,                                                                                                       // BIAS FOR DOUBLE/SINGLE/HALF
    input   uint1   rm,
    input   uint1   signA,                                                                                                      // SIGN OF A INPUT FOR A*B+C and - variations
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO } FOR A
    input   uint1   signB,                                                                                                      // SIGN OF B INPUT FOR A*B+C and - variations
    input   uint4   typeBF,                                                                                                     // { INF sNAN qNAN ZERO } FOR B
    input   uint64  c,                                                                                                          // B INPUT FOR A*B+C and - variations
    input   uint4   typeCF,                                                                                                     // { INF sNAN qNAN ZERO } FOR C
    input   uint106 productfraction,                                                                                            // MULTIPLICATION RESULT IN FOR ADD/SUB
    input   int13   productexp,                                                                                                 // MULTIPLICATION EXPONENT FOR ADD/SUB
    input   uint53  productnormal,                                                                                              // NORMALISED MULTIPLICATION RESULT IN CASE OF +/-0
    output  uint1   fusedsign,                                                                                                  // RESULT SIGN
    output  int13   fusedexp,                                                                                                   // RESULT EXPONENT
    output  uint53  normalfraction,                                                                                             // NORMALISED RESULT FRACTION
    input   uint1   OF,                                                                                                         // OVERFLOW FLAG
    input   uint1   UF,                                                                                                         // UNDERFLOW FLAG
    input   uint64  combined,                                                                                                   // DOUBLE OR FLOAT RESULT ROUNDED AND COMBINED
    output  uint5   flags,                                                                                                      // OPERATION FLAGS
    output  uint64  result                                                                                                      // RESULT OF CALCULATION
) <reginputs> {
    uint1   ZERO <:: typeAF[0,1] | typeBF[0,1] | typeCF[0,1];                                                                   // DETECT ZERO
    uint1   IF <:: ( typeAF[3,1] | typeBF[3,1] | typeCF[3,1] );                                                                 // DETECT INFINITY
    uint1   NN <:: |( typeAF[1,2] | typeBF[1,2] | typeCF[1,2] );                                                                // DETECT NAN
    uint1   NV <:: ( ( typeAF[3,1] | typeBF[3,1] ) & ( typeAF[0,1] | typeBF[0,1] ) ) |                                          // INF * 0 INVALID
                   ( ( typeAF[3,1] | typeBF[3,1] ) & ( typeCF[3,1] & ( productsign ^ signC ) ) );                               // x == INF AND +/- INF WITH DIFFERING SIGNS INVALID
    uint2   ACTION <:: { IF | NN, ZERO };                                                                                       // DO FUSED IF NOT INFINITY, NAN OR ZERO

    wide_xINF xINF( sign <: productsign );
    wide_xINF pINF( sign <: signC );

    uint1   signC <:: opCode[0,1] ^ fp64( c ).sign;                                                                             // SWITCH SIGN OF C INPUT IF SUBTRACTION REQUIRED
    int13   expC <:: fp64( c ).exponent - BIAS;                                                                                 // REMOVE BIAS FROM C INPUT
    uint1   productsign <:: opCode[1,1] ^ ( signA ^ signB );                                                                    // PRODUCT SIGN XOR SIGNS AND THEN WITH NEGATE FLAG

    do_addsub_align_fused ALIGN(                                                                                                // ALIGN THE FRACTIONS
        expA <: productexp, fractionA <: productfraction,                                                                       // MOVE THE FRACTION WITH THE SMALLEST EXPONENT RIGHT
        expB <: expC, fractionB <: fp64( c ).fraction
    );
    do_float_addsub ADDSUB(                                                                                                     // PERFORM THE ADDITION/SUBTRACTION, ACCOUNTING FOR SIGNS
        signA <: productsign, sigA <: ALIGN.sigA,                                                                               // SPECIAL CASE FOR SUBTRACTION WHEN EQUAL EXPONENTS
        signB <: signC, sigB <: ALIGN.sigB,                                                                                     // AND SECOND FRACTION IS LARGER THAN THE FIRST
        resultsign :> fusedsign
    );
    donormalexp NORMAL(                                                                                                         // NORMALISE THE RESULT
        exp <: ALIGN.fusedexp,                                                                                                  // 1 IS ADDED TO THE EXPONENT IN CASE OF OVERFLOW
        bitstream <: ADDSUB.resultfraction,                                                                                     // NORMALISING WILL ADJUST
        newexponent :> fusedexp,
        normalfraction :> normalfraction
    );
    doroundcombine MULTRESULT(                                                                                                  // DO ROUNDING AND COMBINING IN CASE OF 0 ADDITION / SUBTRACTION
        dsh <: dsh, BIAS <: BIAS,                                                                                               // REPLACES ARET IN SINGLE ADDITION OPERATION
        rm <: rm,                                                                                                               // TO RETURN MULTIPLCATION RESULT
        sign <: productsign,
        bitstream <: productnormal,
        exponent <: productexp
    );

    make_wide CRET( sign <: signC, exp <: fp64( c ).exponent, fraction <: fp64( c ).fraction );                                 // REPACK C WITH ADJUSTED SIGN IN CASE OF 0 FROM MULTIPLICATION

    uint2   wait(0);

    busy := start | wait[0,1];
    flags := { NV, 1b0, ~|ACTION & OF, ~|ACTION & UF, 1b0 };                                                                    // RETURN FLAGS

    algorithm <autorun> {
        while(1) {
            if( start ) { wait = 3; } else { wait = wait[1,1]; }                                                                // PROVIDE WAIT STATES
        }
    }

    always_after {
        switch( ACTION ) {
            case 2b00: { result = |ADDSUB.resultfraction ? combined : 0; }                                                      // FUSED IS VALID, CHECK 0 FROM ADDSUB
            case 2b01: {                                                                                                        // ZERO INPUT
                result = ( ( typeAF[0,1] | typeBF[0,1] ) & typeCF[0,1] ) ? 0 :                                                  // MULTIPLY RESULT 0 AND C == 0, RETURN 0
                           ( typeAF[0,1] | typeBF[0,1] ) ? CRET.wide :                                                          // MULTIPLICATION INPUTS 0, RETURN C
                           MULTRESULT.combined;                                                                                 // ADDITION/SUBTRACTION INPUT 0, RETURN MULTIPLICATION RESULT
            }
            default: {
                switch( { IF, ZERO } ) {
                    default: { result = 64h7FF8000000000000; }                                                                  // NAN INPUT
                    case 2b10: {                                                                                                // NAN OR INFITITY RETURN qNAN OR INFINITY
                        switch( { typeAF[3,1 ] | typeBF[3,1], typeCF[3,1] } ) {
                            case 2b01: { result = pINF.value; }                                                                 // C INPUT IS INFINITY
                            default: { result = NV ? 64h7FF8000000000000 : xINF.value; }                                        // INVALID MIXED SIGN INFINITY, OR MULTIPLICATION IS INFINITY
                        }
                    }
                    case 2b11: {                                                                                                // INFINITY AND ZERO INPUTS
                        switch( { typeAF[3,1 ] | typeBF[3,1], typeCF[3,1] } ) {
                            case 2b01: { result = pINF.value; }                                                                 // MULTIPLICATION IS 0 AND C INPUT IS INFINITY
                            case 2b10: { result = xINF.value; }                                                                 // MULTIPLICATION IS INFINITY, C INPUT IS 0
                            default: { result = 64h7FF8000000000000; }                                                          // INFINITY x ZERO, INVALID qNAN
                        }

                    }
                }
            }
        }
    }
}

// DIVIDE TWO FLOATING POINT NUMBERS
unit prep_float_divide(
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF FLAG
    input   uint64  a,                                                                                                          // A INPUT FOR A/B
    input   uint64  b,                                                                                                          // B INPUT FOR A/B
    output  uint1   powTWO,
    output  uint1   quotientsign,                                                                                               // RESULT SIGN
    output  int13   quotientexp,                                                                                                // RESULT EXPONENT
    output  uint108 sigA,                                                                                                       // DIVIDEND LEFT ALIGNED
    output  uint106 sigB                                                                                                        // DIVISOR RIGHT ALIGNED
) <reginputs> {
    always_after {
        quotientsign = fp64( a ).sign ^ fp64( b ).sign;                                                                         // GENERATE QUOTIENT SIGN
        quotientexp = ( fp64( a ).exponent - fp64( b ).exponent ) - ( fp64(b).fraction > fp64(a).fraction );                    // SUBTRACT EXPONENTS FOR RESULT ( -1 if b fraction > a fraction )
        sigA = dsh[0,1] ? { 1b1, fp64(a).fraction, 55b0 } :                                                                     // DIVIDEND LEFT ALIGNED
               dsh[1,1] ? { 1b1, fp64(a).fraction[42,10], 13b0 } :
                          { 1b1, fp64(a).fraction[29,23], 26b0 };
        sigB = dsh[0,1] ? { 1b1, fp64(b).fraction } :                                                                           // DIVISOR RIGHT ALIGNED
               dsh[1,1] ? { 1b1, fp64(b).fraction[42,10] } :
                          { 1b1, fp64(b).fraction[29,23] };
        powTWO = ~|fp64(b).fraction;                                                                                            // DETECT FRACTION OF B IS 0 ( B is power of 2, no division required )
    }
}
unit do_float_divide(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint7   startbit,
    input   uint108 sigA,
    input   uint108 sigB,
    input   uint1   powTWO,
    output  uint108 quotient(0)
) <reginputs> {
    uint7   bit(127);
    uint108 remainder = uninitialised;
    uint108 temporary <:: { remainder[0,107], sigA[bit,1] };
    uint1   bitresult <:: __unsigned(temporary) >= __unsigned(sigB);
    uint108 remainderNEXT <:: __unsigned(temporary) - ( bitresult ? __unsigned(sigB) : 0 );

    busy := start | ~&bit;

    always_after {
        if( &bit ) {
            if( start ) {
                if( powTWO ) {                                                                                                  // DETECT DIVISION BY POWER OF 2
                    quotient = sigA;                                                                                            //      RETURN DIVIDEND
                } else {
                    bit = startbit; quotient = 0; remainder = 0;                                                                // ZERO quotient and remainder SELECT STARTING BIT
                }
            }
        } else {
            remainder = remainderNEXT;                                                                                          // PERFORM BIT BY BIT LONG DIVISION
            quotient[ bit, 1 ] = bitresult;                                                                                     // UPDATE THE QUOTIENT
            bit = bit - 1;                                                                                                      // MOVE TO THE NEXT BIT
        }
    }
}
unit floatdivide(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint2   dsh,                                                                                                        // DOUBLE/SINGLE/HALF FLAG
    input   uint64  a,                                                                                                          // A INPUT FOR A/B
    input   uint64  b,                                                                                                          // B INPUT FOR A/B
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO } FOR A
    input   uint4   typeBF,                                                                                                     // { INF sNAN qNAN ZERO } FOR B
    input   uint7   startbit,                                                                                                   // POINT TO START DIVISION AT 107/49/23 FOR DOUBLE/SINGLE?HALF
    output  uint1   quotientsign,                                                                                               // RESULT SIGN
    output  int13   quotientexp,                                                                                                // RESULT EXPONENT
    output  uint53  normalfraction,                                                                                             // NORMALISED RESULT FRACTION
    input   uint1   OF,                                                                                                         // OVERFLOW FLAG
    input   uint1   UF,                                                                                                         // UNDERFLOW FLAG
    input   uint64  combined,                                                                                                   // DOUBLE/SINGLE/HALF RESULT ROUNDED AND COMBINED
    output  uint4   flags,                                                                                                      // OPERATION FLAGS
    output  uint64  result                                                                                                      // RESULT OF CALCULATION
) <reginputs> {
    uint1   IF <:: ( typeAF[3,1] | typeBF[3,1] );                                                                               // DETECT INFINITY
    uint1   NN <:: |typeAF[1,2] | |typeBF[1,2];                                                                                 // DETECT NAN
    uint2   ACTION <:: { IF | NN, typeAF[0,1] | typeBF[0,1] };                                                                  // DO DIVISION IF NOT INFINITY, NAN OR ZERO

    wide_xINF xINF( sign <: PREP.quotientsign );
    wide_xZERO xZERO(  sign <: PREP.quotientsign );

    prep_float_divide PREP(                                                                                                     // PREPARE THE DIVISION INPUTS
        dsh <: dsh,
        a <: a,
        b <: b,
        quotientsign :> quotientsign,
        quotientexp :> quotientexp
    );
    do_float_divide DODIVIDE(                                                                                                   // DO THE DIVISION PASS QUOTIENT FOR NORMALISATION
        startbit <: startbit,
        sigA <: PREP.sigA,
        sigB <: PREP.sigB,
        powTWO <: PREP.powTWO,
    );
    donormal NORMAL(                                                                                                            // NORMALISE THE RESULT
        bitstream <: DODIVIDE.quotient,
        normalfraction :> normalfraction
    );
    DODIVIDE.start := start & ~|ACTION; busy := start | DODIVIDE.busy;                                                          // START AND BUSY FLAGS

    flags := { typeBF[0,1], ~|ACTION & OF, ~|ACTION & UF, 1b0};                                                                 // RETURN FLAGS

    always_after {
        switch( ACTION ) {
            case 2b00: { result = combined; }                                                                                   // DIVISION IS VALID
            case 2b01: { result = ( typeAF[0,1] & typeBF[0,1] ) ? 64h7FF8000000000000 : typeBF[0,1] ? xINF.value : xZERO.value; }              // ZERO INPUT, NAN IF BOTH ZERO, INF IF B ZERO, ZERO IF A ZERO
            default: { result = ( typeAF[3,1] & typeBF[3,1] ) | NN | typeBF[0,1] ? 64h7FF8000000000000 :                                       // qNAN IF INVALID,
                                ( typeAF[0,1] | typeBF[3,1] ) ? xZERO.value : xINF.value; }                                     // ZERO IF A IS ZERO OR B IS INF, INF IF INF / OTHER
        }
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
unit prep_float_sqrt(
    input   uint10  BIAS,                                                                                                       // BIAS FOR DOUBLE/SINGLE/HALF
    input   uint64  a,                                                                                                          // A INPUT FOR SQRT(A)
    output  uint1   powTWO,
    output  uint1   expODD,
    output  int13   squarerootexp,
    output  uint108 start_ac,
    output  uint106 start_x
) <reginputs> {
    int13   expA <:: fp64( a ).exponent - BIAS;                                                                                 // EXTRACT EXPONENT AND REMOVE BIAS

    always_after {
        squarerootexp = expA >>> 1;                                                                                             // RESULT EXPONENT IS HALF OF INPUT EXPONENT
        start_ac = expA[0,1] ? { 106b0, 1b1, a[ 51, 1 ] } : 1;                                                                  // STARTING ACCUMULATOR ( depends if exp is odd / even )
        start_x = expA[0,1] ? { a[0,51], 55b0 } : { fp64( a ).fraction, 54b0 };                                                 // STARTING FRACTION ( depends if exp is odd / even )
        powTWO = ~|fp64(a).fraction;                                                                                            // DETECT FRACTION OF A IS 0 ( A is power of 2, no squareroot required )
        expODD = expA[0,1];                                                                                                     // IS EXP ODD, RETURN SQRT(2) OR 1 FOR POWER OF 2 SQUAREROOTS
    }
}
unit do_float_sqrt(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint6   startbit,
    input   uint1   powTWO,
    input   uint1   expODD,
    input   uint108 start_ac,
    input   uint106 start_x,
    output  uint54  squareroot
) <reginputs> {
    uint108 test_res <:: ac - { squareroot, 2b01 };
    uint108 ac = uninitialised;
    uint106 x = uninitialised;
    uint6   i(63);

    busy := start | ~&i;

    always_after {
        if( &i ) {
            if( start ) {
                if( powTWO ) {
                    squareroot = expODD ? 54h2D413CCCFE7799 : 1;                                                                // DETECT POWER OF 2 SQUARE ROOT, RETURN ROOT 2 / 1 IF EXP ODD / EVEN
                } else {
                    i = startbit; squareroot = 0; ac = start_ac; x = start_x;                                                   // SELECT STARTING BIT ( counter for number of bits to process )
                }
            }
        } else {
            ac = { test_res[107,1] ? ac[0,105] : test_res[0,105], x[104,2] };                                                   // FIND NEW ACCUMULATOR
            squareroot = { squareroot[0,53], ~test_res[107,1] };                                                                // ADD NEXT BIT TO SQUAREROOT ( shift in from right )
            x = { x[0,104], 2b00 };                                                                                             // MOVE 2 PLACES ALONG REMAINING FRACTION
            i = i - 1;                                                                                                          // MOVE TO NEXT BIT
        }
    }
}
unit floatsqrt(
    input   uint1   start,
    output  uint1   busy(0),
    input   uint10  BIAS,                                                                                                       // BIAS FOR DOUBLE/SINGLE/HALF
    input   uint64  a,                                                                                                          // A INPUT FOR SQRT(A)
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO } FOR A
    input   uint6   startbit,                                                                                                   // POINT TO START SQUAREROOT AT 53/24/11 FOR DOUBLE/SINGLE/HALF
    output  int13   squarerootexp,                                                                                              // RESULT EXPONENT
    output  uint53  normalfraction,                                                                                             // NORMALISED RESULT FRACTION
    input   uint1   OF,                                                                                                         // OVERFLOW FLAG
    input   uint1   UF,                                                                                                         // UNDERFLOW FLAG
    input   uint64  combined,                                                                                                   // DOUBLE/SINGLE/HALF RESULT ROUNDED AND COMBINED
    output  uint5   flags,                                                                                                      // OPERATION FLAGS
    output  uint64  result                                                                                                      // RESULT OF CALCULATION
) <reginputs> {
    uint1   NN <:: |typeAF[1,2];                                                                                                // DETECT NAN INPUT
    uint1   NV <:: typeAF[3,1] | NN | fp64( a ).sign;                                                                           // INVALID IF INFINITY, NAN OR NEGATIVE
    uint1   ACTION <:: ~|{ typeAF[3,1] | NN, typeAF[0,1] | fp64( a ).sign };                                                    // CALCULATION VALID IF NORMAL POSITIVE NUMBER ( ZERO IS SPECIAL )

    prep_float_sqrt PREP(                                                                                                       // PREPARE THE SQUAREROOT INPUTS
        BIAS <: BIAS,
        a <: a,
        squarerootexp :> squarerootexp
    );

    do_float_sqrt DOSQRT(                                                                                                       // CALCULATE SQUARE ROOT
        startbit <: startbit,
        powTWO <: PREP.powTWO,
        expODD <: PREP.expODD,
        start_ac <: PREP.start_ac,
        start_x <: PREP.start_x
    );

    donormal NORMAL(                                                                                                            // NORMALISE THE RESULT
        bitstream <: DOSQRT.squareroot,
        normalfraction :> normalfraction
    );

    DOSQRT.start := start & ACTION; busy := start | DOSQRT.busy;                                                                // START AND BUSY FLAGS

    always_after {
        result = ACTION ? combined : fp64( a ).sign ? 64h7FF8000000000000 : a;                                                  // VALID = RESULT, INVALID = qNAN IF NEGATIVE ELSE INPUT ( INF OR ZERO )
        flags = { NV, 1b0, ACTION & OF, ACTION & UF, 1b0 };                                                                     // RETURN FLAGS
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
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS resultERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=============================================================================*/

unit floatcompare(
    input   uint64  a,                                                                                                          // A INPUT FOR A<B OR A==B ( repacked into double bitfields )
    input   uint64  b,                                                                                                          // B INPUT FOR A<B OR A==B ( repacked into double bitfields )
    input   uint4   typeAF,                                                                                                     // { INF sNAN qNAN ZERO } FOR A
    input   uint4   typeBF,                                                                                                     // { INF sNAN qNAN ZERO } FOR B
    output  uint1   less,                                                                                                       // A < B FLAG
    output  uint1   equal                                                                                                       // A == B FLAG
) <reginputs> {
    uint1   NAN <:: |(typeAF[1,2] | typeBF[1,2]);                                                                               // DETECT NAN
    uint1   aequalb <:: ( a == b );                                                                                             // A==B
    uint1   aorbleft1equal0 <:: ~|( a[0,63] | b[0,63] );                                                                        // ( A<<1 ) | ( B<<1 ) == 0 ( DETECTS BOTH 0, SUBNORMALS NOT ZERO )

    always_after {
        less = ~NAN & ( ( fp64( a ).sign ^ fp64( b ).sign ) ? fp64( a ).sign & ~aorbleft1equal0 : ~aequalb & ( fp64( a ).sign ^ ( a < b ) ) );
        equal = ~NAN & ( aequalb | aorbleft1equal0 );
    }
}



//
// TEST TEST TEST FRAMEWORK
//

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
    //uint7   opCode = 7b1000011; // FMADD
    // uint7   opCode = 7b1000111; // FMSUB
    // uint7   opCode = 7b1001011; // FNMSUB
    // uint7   opCode = 7b1001111; // FNMADD

    uint7   function7 = 7b1100000; // OPERATION SWITCH - BITS[0,2] == 10 for HALF, == 01 for DOUBLE, == 00 for SINGLE
    // ADD = 7b00000xx SUB = 7b00001xx MUL = 7b00010xx DIV = 7b00011xx SQRT = 7b01011xx
    // FSGNJ[N][X] = 7b00100xx function3 == 000 FSGNJ == 001 FSGNJN == 010 FSGNJX
    // MIN MAX = 7b00101xx function3 == 000 MIN == 001 MAX
    // LE LT EQ = 7b10100xx function3 == 000 LE == 001 LT == 010 EQ
    // FCVT.W[U].S floatto[u]int = 7b11000xx rs2 == 00000 FCVT.W.S == 00001 FCVT.WU.S
    // FCVT.S.W[U] [u]inttofloat = 7b11010xx rs2 == 00000 FCVT.S.W == 00001 FCVT.S.WU

    uint3   function3 = 3b000; // ROUNDING MODE OR SWITCH
    uint5   rs1 = 5b00000; // SOURCEREG1 number
    uint5   rs2 = 5b00000; // SOURCEREG2 number OR SIGNED/UNSIGNED INF<->FLOAT, OR DOUBLE/SINGLE/HALF FLAG FOR EXTEND/TRUNCATE

    uint1   IS_FASTFPU <:: ( function7[2,5] == 5b10100 ) & function7[4,1] | &function7[5,2];

    uint64  sourceReg1 = 1190041; // INTEGER SOURCEREG1
    abs3264 S1_abs( sourceReg <: sourceReg1 );

    // HALF PRECISION
    //uint64  sourceReg1F = 64hffffffffffff71D5;
    //uint64  sourceReg2F = 64hffffffffffffD1DF;
    //uint64  sourceReg3F = 64hffffffffffffF62F;

    // SINGLE PRECISION
    uint64  sourceReg1F = 64hffffffffC6C5E2DA;
    uint64  sourceReg2F = 64hffffffffC23BEE21;
    uint64  sourceReg3F = 64hffffffffC6C5E2DA;

    // DOUBLE PRECISION
    //uint64  sourceReg1F = 64h40C7528000000000;
    //uint64  sourceReg2F = 64hC0477DC422036007;
    //uint64  sourceReg3F = 64hC0D8BC5B4D0C9E73;

    repackage_wide F1x( dsh <:  function7[0,2], a <: sourceReg1F ); repackage_wide F1xopp( dsh <: rs2[0,2], a <: sourceReg1F );
    repackage_wide F2x( dsh <:  function7[0,2], a <: sourceReg2F );
    repackage_wide F3x( dsh <:  function7[0,2], a <: sourceReg3F );

    typeF typeAF( dsh <:  function7[0,2], a <: sourceReg1F );
    typeF typeBF( dsh <:  function7[0,2], a <: sourceReg2F );
    typeF typeCF( dsh <:  function7[0,2], a <: sourceReg3F );
    typeF typeAFopp( dsh <: rs2[0,2], a <: sourceReg1F );

    floatcompare FPUcompare(                                                                                                    // FLOATING POINT COMPARISONS
        a <: F1x.repack, typeAF <: typeAF.type,
        b <: F2x.repack, typeBF <: typeBF.type
    );

    uint64  result = uninitialised;
    uint1   frd = uninitialised;

    uint5   FPUflags = 5b00000;
    uint5   FPUnewflags = uninitialised;

    // EXECUTE FPU
    cpuexecuteFPU EXECUTEFPU(
        opCode <: opCode[2,5],
        function3 <: function3,
        function7 <: function7,
        rs2 <: rs2,
        sourceReg1 <: sourceReg1, S1_abs32 <: S1_abs.abs32, S1_abs64 <: S1_abs.abs64,
        sourceReg1F <: sourceReg1F, sourceReg1Fx <: F1x.repack, sourceReg1Fxopp <: F1xopp.repack, typeAF <: typeAF.type, typeAopp <: typeAFopp.type,
        sourceReg2F <: sourceReg2F, sourceReg2Fx <: F2x.repack, typeBF <: typeBF.type,
        sourceReg3Fx <: F3x.repack, typeCF <: typeCF.type,
        FLT <: FPUcompare.less,
        FEQ <: FPUcompare.equal,
        isFASTFPU <: IS_FASTFPU,
        FPUflags <: FPUflags,
    );
    EXECUTEFPU.start := 0;

    // CLOCK CYCLES TO ALLOW SIGNALS TO PROPOGATE - REQUIRED FOR VERILATOR
    ++: ++: ++: ++:
    startcycle = PULSE.cycles;
    __display("");
    __display("RISC-V DOUBLE/SINGLE/HALF FPU SIMULATION");
    __display("");
    __display("I1 = %x -> { %b }",sourceReg1,sourceReg1);
    __display("F1 = %x -> { %b } as { %b }",sourceReg1F,sourceReg1F,typeAF.type);
    __display("F2 = %x -> { %b } as { %b }",sourceReg2F,sourceReg2F,typeBF.type);
    __display("F3 = %x -> { %b } as { %b }",sourceReg3F,sourceReg3F,typeAF.type);
    __display("OPCODE = %b FUNCTION7 = %b FUNCTION3 = %b RS1 = %b RS2 = %b",opCode, function7, function3, rs1, rs2);
    __display("");

            switch( opCode[2,5] ) {
                default: {
                    // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
                    __display("FUSED OPERATION");
                }
                case 5b10100: {
                    switch( function7[2,5] ) {
                        default: {
                            // FADD.S FSUB.S FMUL.S FDIV.S FSQRT.S
                            __display("ADD SUB MUL DIV SQRT");
                        }
                        case 5b00100: {
                            // FSGNJ.S FSGNJN.S FSGNJX.S
                            __display("SIGN MANIPULATION");
                        }
                        case 5b00101: {
                            // FMIN.S FMAX.S
                            __display("MIN MAX");
                        }
                        case 5b10100: {
                            // FEQ.S FLT.S FLE.S
                            __display("COMPARISON");
                       }
                        case 5b11000: {
                            // FCVT.W.S FCVT.WU.S
                            __display("CONVERSION float to int/long");
                        }
                        case 5b11010: {
                            // FCVT.S.W FCVT.S.WU
                             __display("CONVERSION int/long to float");
                       }
                        case 5b11100: {
                            // FCLASS.S FMV.X.W
                            __display("CLASSIFY or MOVE BITMAP FROM FLOAT TO INT");
                        }
                        case 5b11110: {
                            // FMV.W.X
                            __display("MOVE BITMAP FROM INT TO FLOAT");
                        }
                    }
                }
            }

            EXECUTEFPU.start = 1; while( EXECUTEFPU.busy ) {}
            result = EXECUTEFPU.result; frd = EXECUTEFPU.frd; FPUnewflags = EXECUTEFPU.FPUnewflags;

            __display("");
            __display("FRD = %b RESULT = %x -> { %b }",frd,result,result);
            __display("FRD = %b RESULT = %x -> { %b  %b %b }",frd,result,function7[0,1] ? fp64( result).sign : fp32( result ).sign, function7[0,1] ? fp64( result ).exponent : fp32( result ).exponent, function7[0,1] ? fp64( result ).fraction : fp32( result ).fraction );

            __display("FLAGS = { %b }",FPUnewflags);

            __display("");
            __display("");
            __display("TOTAL OF %0d CLOCK CYCLES",PULSE.cycles - startcycle);
            __display("");
            //busy = 0;
        //}
    //}
}
