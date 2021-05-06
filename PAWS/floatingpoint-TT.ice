// ROUNDING MODES
$$ RNE = 0
$$ RTZ = 1
$$ RDN = 2
$$ RUP = 3
$$ RMM = 4

// EXCEPTIONS FLAGS
$$ NX = 1
$$ UF = 2
$$ OF = 4
$$ DZ = 8
$$ NV = 16

// BITFIELD FOR FLOATING POINT CSR REGISTER
bitfield floatingpointcsr{
    uint24  reserved,
    uint3   frm,
    uint5   fflags
}

algorithm fpu(
    input   uint1   clock_FPU,

    input   uint1   start,
    output  uint1   busy,

    input   uint7   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint5   rs2,
    input   uint32  sourceReg1,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,

    output uint32  result,
    output uint1   frd
) <autorun> {

    inttofloat FPUfloat( a <: sourceReg1, rs2 <: rs2 );
    floataddsub FPUaddsub( a <: sourceReg1F, b <: sourceReg2F );
    floatmultiply FPUmultiply( a <: sourceReg1F, b <: sourceReg2F );
    floatdivide FPUdivide( a <: sourceReg1F, b <: sourceReg2F );
    floatfused FPUfused( function7 <: function7, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F, sourceReg3F <: sourceReg3F );
    floatsqrt FPUsqrt( sourceReg1F <: sourceReg1F );
    floatcomparison FPUcomparison( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );
    floatsign FPUsign( function3 <: function3, sourceReg1F <: sourceReg1F, sourceReg2F <: sourceReg2F );

    FPUfloat.start := 0;
    FPUaddsub.start := 0;
    FPUmultiply.start := 0;
    FPUdivide.start := 0;
    FPUfused.start := 0;

    while(1) {
        if( start ) {
            busy = 1;

            switch( opCode[2,5] ) {
                case 5b10100: {
                    // NON 3 REGISTER FPU OPERATIONS
                    switch( function7[2,5] ) {
                        case 5b00000: {
                            // FADD.S
                            frd = 1;
                            FPUaddsub.addsub = 0;
                            FPUaddsub.start = 1;
                            while( FPUaddsub.busy ) {}
                            result = FPUaddsub.result;
                        }
                        case 5b00001: {
                            // FSUB.S
                            frd = 1;
                            FPUaddsub.addsub = 1;
                            FPUaddsub.start = 1;
                            while( FPUaddsub.busy ) {}
                            result = FPUaddsub.result;
                        }
                        case 5b00010: {
                            // FMUL.S
                            frd = 1;
                            FPUmultiply.start = 1;
                            while( FPUmultiply.busy ) {}
                            result = FPUmultiply.result;
                        }
                        case 5b00011: {
                            // FDIV.S
                            frd = 1;
                            FPUdivide.start = 1;
                            while( FPUdivide.busy ) {}
                            result = FPUdivide.result;
                        }
                        case 5b010011: {
                            // FSQRT.S
                            frd = 1;
                            // FIRST APPROXIMATIONS IS 1
                            FPUsqrt.start = 1;
                            while( FPUsqrt.busy ) {}
                            result = FPUsqrt.result;
                        }
                        case 5b00100: {
                            // FSGNJ.S FNGNJN.S FSGNJX.S
                            frd = 1;
                            result = FPUsign.result;
                        }
                        case 5b00101: {
                            // FMIN.S FMAX.S
                            frd = 1;
                            switch( function3[0,1] ) {
                                case 0: { result = FPUcomparison.comparison ? sourceReg1F : sourceReg2F; }
                                case 1: { result = FPUcomparison.comparison ? sourceReg2F : sourceReg1F; }
                            }
                        }
                        case 5b11000: {
                            // FCVT.W.S FCVT.WU.S
                            frd = 0;
                            result = sourceReg1F;
                        }
                        case 5b11100: {
                            // FMV.X.W
                            frd = 0;
                            result = sourceReg1F;
                        }
                        case 5b10100: {
                            // FEQ.S FLT.S FLE.S
                            frd = 0;
                            result = { 31b0, FPUcomparison.comparison };
                        }
                        case 5b11100: {
                            // FCLASS.S
                            frd = 0;
                            result = { 23b0, 9b000100000 };
                        }
                        case 5b11010: {
                            // FCVT.S.W FCVT.S.WU
                            frd = 1;
                            FPUfloat.start = 1;
                            while( FPUfloat.busy ) {}
                            result = FPUfloat.result;
                        }
                        case 5b11110: {
                            // FMV.W.X
                            frd = 1;
                            result = sourceReg1;
                        }
                        default: {
                            // FMADD.S FMSUB.S FNMSUB.S FNMADD.S
                            frd = 1;
                            FPUfused.start = 1;
                            while( FPUfused.busy ) {}
                            result = FPUfused.result;
                        }
                    }
                }
            }

            busy = 0;
        }
    }
}

// ALIGN TO THE RIGHT ( remove trailing 0s )
circuitry alignright( input number, output alignedright ) {
    alignedright = number;
    ++:
    while( ~alignedright[0,1] && ( alignedright != 0 ) ) {
        alignedright = alignedright >> 1;
    }
}

// COUNT LEADING 0s
circuitry countleadingzeros( input a, output count ) {
    uint32  bitstream = uninitialised;
    bitstream = a;
    count = 0;
    ++:
    if( bitstream == 0 ) {
        count = 32;
    } else {
        while( ~bitstream[31,1] ) {
            bitstream = bitstream << 1;
            count = count + 1;
        }
    }
}

// NORMALISE A 32BT MANTISSA with or without adjusting exponent
circuitry normalise( input sign, input exp, input number, output F32 ) {
    uint8  zeros = uninitialised;
    int16  expA = uninitialised;
    uint32  bitstream = uninitialised;

    if( number == 0 ) {
        F32 = { sign, 31b0 };
    } else {
        ( zeros ) = countleadingzeros( number );
        bitstream = ( zeros < 8 ) ? number >> ( 8 - zeros ) : ( zeros > 8 ) ? number << ( zeros - 8 ) : number;
        expA = exp + 127;
        F32 = { sign, expA[0,8], bitstream[0,23] };
    }
}
circuitry normaliseexp( input sign, input exp, input number, output F32 ) {
    uint8  zeros = uninitialised;
    int16  expA = uninitialised;
    uint32  bitstream = uninitialised;

    if( number == 0 ) {
        F32 = { sign, 31b0 };
    } else {
        ( zeros ) = countleadingzeros( number );
        bitstream = ( zeros < 8 ) ? number >> ( 8 - zeros ) : ( zeros > 8 ) ? number << ( zeros - 8 ) : number;
        expA = ( zeros == 8 ) ? exp + 127 : exp + 135 - zeros;
        F32 = { sign, expA[0,8], bitstream[0,23] };
    }
}

// CONVERT SIGNED/UNSIGNED INTEGERS TO FLOAT
algorithm inttofloat(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  a,
    input   uint5   rs2,

    output  uint32  result
) <autorun> {
    uint1   sign = uninitialised;
    uint8   exp = uninitialised;
    uint8   zeros = uninitialised;
    uint32  number = uninitialised;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;

            // SIGNED / UNSIGNED
            sign = rs2[0,1] ? 0 : a[31,1];
            number = rs2[0,1] ? a : ( a[31,1] ? -a : a );
            ++:
            if( number == 0 ) {
                result = { sign, 31b0 };
            } else {
                ( zeros ) = countleadingzeros( number );
                number = ( zeros < 8 ) ? number >> ( 8 - zeros ) : ( zeros > 8 ) ? number << ( zeros - 8 ) : number;
                exp = 158 - zeros;
                result = { sign, exp[0,8], number[0,23] };
            }

            busy = 0;
        }
    }
}

algorithm floataddsub(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  a,
    input   uint32  b,
    input   uint1   addsub,

    output  uint32  result
) <autorun> {
    uint1   sign = uninitialised;
    int16   expA = uninitialised;
    int16   expB = uninitialised;
    uint32  sigA = uninitialised;
    uint32  sigB = uninitialised;
    uint32  totaldifference = uninitialised;
    uint6   bitcount = uninitialised;

    // == 0 ADD == 1 SUB
    uint1   operation = uninitialised;
    uint32  value1 = uninitialised;
    uint32  value2 = uninitialised;
    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;

            operation = ( a[31,1] == b[31,1] ) ? addsub : ~addsub;
            bitcount = 31;

            switch( addsub ) {
                case 0: {
                    switch( { a[31,1], b[31,1] } ) {
                        case 2b01: {
                            value1 = a;
                            value2 = { ~b[31,1], b[0,31] };
                        }
                        case 2b10: {
                            value1 = b;
                            value2 = { ~a[31,1], a[0,31] };
                         }
                        default: {
                            value1 = a;
                            value2 = b;
                        }
                    }
                }
                case 1: {
                    switch( { a[31,1], b[31,1] } ) {
                        case 2b00: {
                            value1 = a;
                            value2 = b;
                        }
                        case 2b11: {
                            value1 = { ~b[31,1], b[0,31] };
                            value2 = { ~a[31,1], a[0,31] };
                        }
                        default: {
                            value1 = a;
                            value2 = ( { a[31,1], b[31,1] } == 2b10 ) ? b : { ~b[31,1], b[0,31] };
                        }
                    }
                }
            }

            expA = floatingpointnumber( value1 ).exponent;
            expB = floatingpointnumber( value2 ).exponent;
            sigA = { 9b1, value1[0,23] };
            sigB = { 9b1, value2[0,23] };
            sign = value1[31,1];
            ++:
            if( ( expA | expB ) == 0 ) {
                result = ( expB == 0 ) ? value1 : ( operation == 0 ) ? value2 : { ~value2[31,1], value2[0,31] };
            } else {
                // ADJUST TO EQUAL EXPONENTS
                if( expA < expB ) {
                    sigA = sigA >> ( expB - expA );
                    expA = expB;
                    ++:
                } else {
                    if( expB < expA ) {
                        sigB = sigB >> ( expA - expB );
                        expB = expA;
                        ++:
                    }
                }
                expA = expA - 127;
                switch( operation ) {
                    case 0: { totaldifference = sigA + sigB; }
                    case 1: {
                        if( ~sign && ( sigB > sigA ) ) {
                            sign = ~sign;
                            totaldifference = sigB - sigA;
                        } else {
                            totaldifference = sigA - sigB;
                        }
                    }
                }
                if( totaldifference == 0 ) {
                    result = { sign, 31b0 };
                } else {
                    ( result ) = normaliseexp( sign, expA, totaldifference );
                }
            }

            busy = 0;
        }
    }
}

algorithm floatfused(
    input   uint1   start,
    output  uint1   busy,

    input   uint7   function7,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    input   uint32  sourceReg3F,
    output  uint32  result,
) <autorun> {
    uint32  workingresult = uninitialised;
    floatmultiply FPUmultiply( b <: sourceReg2F, result :> workingresult );
    floataddsub FPUaddsub( a <: workingresult, b <: sourceReg3F, result :> result );

    FPUmultiply.a := function7[3,1] ? { ~sourceReg1F[31,1], sourceReg1F[0,31] } : sourceReg1F;
    FPUaddsub.addsub := ( function7[2,1] == function7[3,1] ) ? 0 : 1;

    FPUmultiply.start := 0;
    FPUaddsub.start := 0;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;

            FPUmultiply.start = 1;
            while( FPUmultiply.busy ) {}
            FPUaddsub.start = 1;
            while( FPUaddsub.busy ) {}

            busy = 0;
        }
    }
}

algorithm floatsqrt(
    input   uint1   start,
    output  uint1   busy,

    input   uint32  sourceReg1F,
    output  uint32  result,
) <autorun> {
    uint32  workingresult = uninitialised;
    floatdivide FPUdivide( );
    floataddsub FPUaddsub( );

    FPUdivide.start := 0;
    FPUaddsub.start := 0;

    busy = 0;

    while(1) {
        if( start ) {
            busy = 1;

            if( ( floatingpointnumber( sourceReg1F ).exponent == 0 ) || ( sourceReg1F[31,1] ) ) {
                if( sourceReg1F[31,1] ) {
                    // NEGATIVE
                    result = { sourceReg1F[31,1], 8b11111111, 23b0 };
                } else {
                    // ZERO
                    result = 0;
                }
            } else {
                // FIRST APPROXIMATIONS IS 1
                result = 32h3f800000;
                workingresult = sourceReg1F;
                ++:
                // LOOP UNTIL MANTISSAS ACROSS ITERATIONS ARE APPROXIMATELY EQUAL
                while( result[1,31] != workingresult[1,31] ) {
                    // x(i+1 ) = ( x(i) + n / x(i) ) / 2;
                    // DO n/x(i)
                    FPUdivide.a = sourceReg1F;
                    FPUdivide.b = result;
                    FPUdivide.start = 1;
                    while( FPUdivide.busy ) {}
                    workingresult = FPUdivide.result;

                    // DO x(i) + n/x(i)
                    FPUaddsub.addsub = 0;
                    FPUaddsub.a = result;
                    FPUaddsub.b = workingresult;
                    FPUaddsub.start = 1;
                    while( FPUaddsub.busy ) {}
                    result = FPUaddsub.result;

                    // DO (x(i) + n/x(i))/2
                    FPUdivide.a = workingresult;
                    FPUdivide.b = 32h40000000;
                    FPUdivide.start = 1;
                    while( FPUdivide.busy ) {}
                    result = FPUdivide.result;
                }
            }

            busy = 0;
        }
    }
}

algorithm floatcomparison(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint1   comparison,
) <autorun> {
    while(1) {
        switch( function3 ) {
            case 3b000: {
                // LESS THAN EQUAL OMPARISON OF 2 FLOATING POINT NUMBERS
                comparison = ( sourceReg1F[31,1] != sourceReg2F[31,1] ) ? sourceReg1F[31,1] || ((( sourceReg1F | sourceReg2F ) << 1) == 0 ) : ( sourceReg1F == sourceReg2F ) || ( sourceReg1F[31,1] ^ ( sourceReg1F < sourceReg2F ));
            }
            case 3b001: {
                // LESS THAN COMPARISON OF 2 FLOATING POINT NUMBERS
                comparison = ( sourceReg1F[31,1] != sourceReg2F[31,1] ) ? sourceReg1F[31,1] && ((( sourceReg1F | sourceReg2F ) << 1) != 0 ) : ( sourceReg1F != sourceReg2F ) && ( sourceReg1F[31,1] ^ ( sourceReg1F < sourceReg2F));
            }
            case 3b010: {
                // EQUAL COMPARISON OF 2 FLOATING POINT NUMBERS
                comparison = ( sourceReg1F == sourceReg2F ) || ((( sourceReg1F | sourceReg2F ) << 1) == 0 );
            }
        }
    }
}

algorithm floatsign(
    input   uint3   function3,
    input   uint32  sourceReg1F,
    input   uint32  sourceReg2F,
    output  uint32  result,
) <autorun> {
    while(1) {
        switch( function3 ) {
            case 3b000: {
                // FSGNJ.S
                result = { sourceReg2F[31,1] ? 1b1 : 1b0, sourceReg1F[0,31] };
            }
            case 3b001: {
                // FSGNJN.S
                result = { sourceReg2F[31,1] ? 1b0 : 1b1, sourceReg1F[0,31] };
            }
            case 3b010: {
                // FSGNJX.S
                result = { sourceReg1F[31,1] ^ sourceReg2F[31,1], sourceReg1F[0,31] };
            }
        }
    }
}

// FROM https://github.com/ThibaultTricard/Silice-float
// MIT License
//
// Copyright (c) 2021 ThibaultTricard
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

$$exponant_size = 8
$$mantissa_size = 23
$$float_size = 32
$$int_size = 32
$$uint_size = 32

bitfield float{
    uint1 sign,
    uint$exponant_size$ exponant,
    uint$mantissa_size$ fraction,
}

// BITFIELD FOR FLOATING POINT NUMBER
bitfield floatingpointnumber{
    uint1   sign,
    uint8   exponent,
    uint23  fraction
}

algorithm float_inf(input uint$float_size$ f1, input uint$float_size$ f2, output uint1 inf){
    inf = 0;
    if(f1[$float_size-1$, 1] & ~f2[$float_size-1$, 1]){
        inf = 1;
    }else{
        if(f1[$mantissa_size$, $exponant_size$] < f2[$mantissa_size$, $exponant_size$]){
            inf = 1;
        }
    }
}

algorithm float_sup(input uint$float_size$ f1, input uint$float_size$ f2, output uint1 inf){
    inf = 0;
    if(~f1[$float_size-1$, 1] & f2[$float_size-1$, 1]){
        inf = 1;
    }else{
        if(f1[$mantissa_size$, $exponant_size$] > f2[$mantissa_size$, $exponant_size$]){
            inf = 1;
        }
    }
}

// Based upon https://github.com/ThibaultTricard/Silice-float/blob/main/src/float_div.ice
// Modified to perform special cases checks and to use start and busy flags
algorithm floatdivide(input  uint$float_size$ a,
                    input  uint$float_size$ b,
                    output uint$float_size$ result,
                    output uint1 busy,
                    input  uint1 start)
<autorun>{
    uint1 f3_s(0);
    int$exponant_size+1$ a_e(0); //<: a[$mantissa_size$, $exponant_size$];
    int$exponant_size+1$ b_e(0);
    int$exponant_size+1$ f3_e(0);
    uint$exponant_size$ r_e(0);

    uint$mantissa_size*2 + 2$ a_m(0);
    uint$mantissa_size*2 + 2$ f3_m(0);
    uint$mantissa_size*2 + 2$ remain(0);

// +1 to fix loss of one bit of precision in the mantissa
$$for i=0,mantissa_size+1 do
    uint$mantissa_size*2 + 2$ b_m$i$ = uninitialized;
$$end

    uint$exponant_size$ bias        <: ~{1b1, $exponant_size-1$b0};
    while(1){
        if(start){
            busy = 1;
            //sign
            f3_s = (a[$float_size-1$,1] == b[$float_size-1$,1]) ? 0 : 1; //sign of the result

            //exponent
            a_e= a[$mantissa_size$, $exponant_size$] -bias;
            b_e= b[$mantissa_size$, $exponant_size$] -bias;

            f3_e = (a_e - b_e) + bias;
            r_e = f3_e[0, $exponant_size$];

            //mantissa
            a_m = {1b1, a[0, $mantissa_size$], $mantissa_size+1$b0};

            // +1 to fix loss of one bit of precision in the mantissa
            $$for i=0,mantissa_size+1 do
                b_m$i$ = {1b1, b[0, $mantissa_size$]} << $i$;
            $$end

            remain = a_m;
            $$for i=mantissa_size+1,0,-1 do
                ++:
                if(remain >= b_m$i$){
                    remain = remain - b_m$i$;
                    f3_m = f3_m + (1 << $i$);
                }
            $$end

            result = {f3_s,
            f3_m[$mantissa_size+1$,1] ? r_e : r_e - 1b1,
            f3_m[$mantissa_size+1$,1] ? f3_m[1,$mantissa_size$] : f3_m[0,$mantissa_size$]};

            busy = 0;
        }
    }
}

// Based upon https://github.com/ThibaultTricard/Silice-float/blob/main/src/float_mul.ice
// Modified to perform special cases checks and to use start and busy flags
algorithm floatmultiply(
    input uint$float_size$ a,
    input uint$float_size$ b,
    output uint$float_size$ result,
    output uint1 busy,
    input  uint1 start)
<autorun>{
    int$exponant_size+1$ e1         <: a[$mantissa_size$, $exponant_size$];
    int$exponant_size+1$ e2         <: b[$mantissa_size$, $exponant_size$];
    uint$mantissa_size +1$ m1       <: {1b1, a[0, $mantissa_size$]};
    uint$mantissa_size +1$ m2       <: {1b1, b[0, $mantissa_size$]};
    uint$exponant_size$ one_inv     <: {1b1, $exponant_size-1$b0};
    uint$exponant_size$ bias        <: ~{1b1, $exponant_size-1$b0};
    uint1 r_s                       <: a[$float_size-1$,1] == b[$float_size-1$,1] ? b[$float_size-1$,1] : 1b1;
    uint$mantissa_size$ r_m(0);
    uint$exponant_size$ r_e(0);

    //mantissa multiplication
    uint$(mantissa_size +1)*2$ tmp(0);
    uint$(mantissa_size +1)*2$ r_0 <: m2[0,1] ? {$mantissa_size +1$b0,m1} : $(mantissa_size +1)*2$b0;
$$for i=1,mantissa_size do
    uint$(mantissa_size +1)*2$ r_$i$ <: m2[$i$,1] ? {$mantissa_size +1-i$b0,m1,$i$b0} : $(mantissa_size +1)*2$b0;
$$end
    uint$float_size$  tmp_res  = 0;
    always{
        if(start){
            busy = 1;
            tmp =
        $$for i=0,mantissa_size-1 do
            r_$i$+
        $$end
            r_$mantissa_size$;

            r_m = tmp[$mantissa_size*2 +1$,1] ? tmp[$mantissa_size+1$, $mantissa_size$] : tmp[$mantissa_size$, $mantissa_size$];
            r_e = (e1-bias) + (e2-bias) + bias + tmp[$mantissa_size*2 +1$,1];

            tmp_res = {r_s,r_e,r_m};
            busy = 0;
        }
        result =  tmp_res;
    }
}


algorithm uint_to_float(input uint$uint_size$ u, output uint$float_size$ f){
    uint1 s <: 0;
    uint$exponant_size$ exponant = 0;
    uint$mantissa_size$ mantissa = 0;
    $$for i=uint_size-1,1,-1 do
        if(u[$i$,1]){
            exponant = {1b1, $exponant_size-1$d$i$} -1;
            $$ending=i
            $$size=math.min(ending,mantissa_size)
            $$start=(ending-size)
            $$padding=math.max(mantissa_size-size,0)
            $$if padding==0 then
            mantissa = u[$start$,$size$];
            $$else
            mantissa = {u[$start$,$size$], $mantissa_size-i$d0};
            $$end
        } else {
    $$end
        if(u[0,1]){
            exponant = {1b1, $exponant_size-1$d$0$} -1;
            mantissa = 0;
        }
    $$for i=0,uint_size-2 do
        }
    $$end
    f = {s, exponant, mantissa};
}


//equivalent to a ceil
algorithm float_to_uint(input uint$float_size$ f, output uint$uint_size$ u){
    uint$exponant_size$ one_exponent <: {1b1,$exponant_size-1$b0};
    uint$exponant_size$ exponant <: f[$mantissa_size$, $exponant_size$] + 1;
    u = 0;

    if(f[$float_size-1$, 1] ){
        u = 0;
    }
    else{
        if(exponant[$exponant_size-1$, 1]){
            if(exponant == one_exponent){
                u =1;
            }else{
                $$for i=uint_size-1,1,-1 do
                if($i$ == exponant[0,$exponant_size-1$]){
                    $$if i == 0 then
                    u = (1 << $i$);
                    $$else
                    $$start = math.max(mantissa_size-i,0)
                    $$size = math.min(i, mantissa_size)
                    u = (1 << $i$) +  f[$start$, $size$];
                    $$end
                }else{
                $$end
                $$for i=uint_size-1,1,-1 do
                }
                $$end
            }
        }
    }
}

algorithm int_to_float(input int$int_size$ i,
                       output uint$float_size$ res,
                       output uint1 ready,
                       input  uint1 wr)
<autorun>{
    uint$int_size$ u <: i[$int_size-1$,1] ? ((~i)+1) : i;
    uint1 s <: i[$int_size-1$,1];
    uint$exponant_size$ exponant = 0;
    uint$mantissa_size$ mantissa = 0;
    uint$float_size$  tmp_res  = 0;
    always{
        if(wr){
            $$for i=int_size-1,1,-1 do
                if(u[$i$,1]){
                    exponant = {1b1, $exponant_size-1$d$i$} -1;
                    $$ending=i
                    $$size=math.min(ending,mantissa_size)
                    $$start=(ending-size)
                    $$padding=math.max(mantissa_size-size,0)
                    $$if padding==0 then
                    mantissa = u[$start$,$size$];
                    $$else
                    mantissa = {u[$start$,$size$], $mantissa_size-i$d0};
                    $$end
                } else {
            $$end
                if(u[0,1]){
                    exponant = {1b1, $exponant_size-1$d$0$} -1;
                    mantissa = 0;
                }
            $$for i=0,uint_size-2 do
                }
            $$end
            tmp_res = {s, exponant, mantissa};
            ready = 1;
        }
        res = tmp_res;
    }
}

algorithm float_to_int(
    input  uint$float_size$ f,
    output int$int_size$ res,
    output uint1 ready,
    input  uint1 wr)
 <autorun>{
    uint$exponant_size$ one_exponent <: {1b1,$exponant_size-1$b0};
    uint$exponant_size$ exponant <: f[$mantissa_size$, $exponant_size$] + 1;
    uint$int_size$  u = 0;
    uint$int_size$  tmp_res  = 0;
    always{
        if(wr){
            if(f[$float_size-1$, 1] ){
                u = 0;
            }
            else{
                if(exponant[$exponant_size-1$, 1]){
                    if(exponant == one_exponent){
                        u =1;
                    }else{
                        $$for i=uint_size-1,1,-1 do
                        if($i$ == exponant[0,$exponant_size-1$]){
                            $$if i == 0 then
                            u = (1 << $i$);
                            $$else
                            $$start = math.max(mantissa_size-i,0)
                            $$size = math.min(i, mantissa_size)
                            u = (1 << $i$) +  f[$start$, $size$];
                            $$end
                        }else{
                        $$end
                        $$for i=uint_size-1,1,-1 do
                        }
                        $$end
                    }
                }
            }
            tmp_res = f[$float_size-1$,1] ? (~u)+1 : u;
            ready = 1;
        }
        res = tmp_res;
    }

}
