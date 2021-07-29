// Rob Shelton ( @robng15 Twitter, @rob-ng15 GitHub )
// Simple 32bit FPU calculation/conversion routines
// Designed for as small as FPGA usage as possible,
// not for speed.
//
// Donated to Silice by @sylefeb
//
// Parameters for calculations: ( 16 bit float { sign, exponent, mantissa } format )
// addsub, multiply and divide a and b ( as floating point numbers ), addsub flag == 0 for add, == 1 for sub
//
// Parameters for conversion (always signed):
// intotofloat a as 16 bit integer
// floattoint a as 16 bit float
//
// Control:
// start == 1 to start operation
// busy gives status, == 0 not running or complete, == 1 running
//
// Output:
// result gives result of conversion or calculation
//

// BITFIELD FOR FLOATING POINT NUMBER - IEEE-754 32 bit format
bitfield floatingpointnumber{
    uint1   sign,
    uint5   exponent,
    uint10  fraction
}

bitfield floatingpointflags{
    uint1   IF,     // infinity as an argument
    uint1   NN,     // NaN as an argument
    uint1   NV,     // Result is not valid,
    uint1   DZ,     // Divide by zero
    uint1   OF,     // Result overflowed
    uint1   UF,     // Result underflowed
    uint1   NX      // Not exact ( integer to float conversion caused bits to be dropped )
}

// COMBINE COMPONENTS INTO FLOATING POINT NUMBER
// NOTE exp from addsub multiply divide is 8 bit biased ( ie, exp + 15 )
// small numbers return 0, bit numbers return max
circuitry combinecomponents( input sign, input exp, input fraction, output f16 , output OF, output UF ) {
    switch( ( exp > 30 ) | ( exp < 0 ) ) {
        case 1: { f16 = ( exp < 0 ) ? 0 : { sign, 5b11111, 10h0 }; OF = ( exp > 30 ); UF = ( exp < 0 ); }
        case 0: { f16 = { sign, exp[0,5], fraction[0,10] }; OF = 0; UF = 0; }
    }
}

// IDENTIFY infinity, signalling NAN, quiet NAN, ZERO
algorithm classify(
    input   uint16  a,
    output  uint1   INF,
    output  uint1   sNAN,
    output  uint1   qNAN,
    output  uint1   ZERO
) <autorun> {
    uint1   expFF <: ( floatingpointnumber(a).exponent == 5b11111 );
    INF := expFF & ~a[9,1];
    sNAN := expFF & a[9,1] & a[8,1];
    qNAN := expFF & a[9,1] & ~a[8,1];
    ZERO := ( floatingpointnumber(a).exponent == 0 );
}

// REALIGN A 22BIT NUMBER SO MSB IS 1
circuitry normalise22( inout bitstream ) {
    while( ~bitstream[21,1] ) { bitstream = bitstream << 1; }
}
// EXTRACT 10 BIT FRACTION FROM LEFT ALIGNED 22 BIT FRACTION WITH ROUNDING
circuitry round22( input bitstream, output roundfraction ) {
    roundfraction = bitstream[11,10] + bitstream[10,1];
}

// ADJUST EXPONENT IF ROUNDING FORCES, using newfraction and truncated bit from oldfraction
circuitry adjustexp22( inout exponent, input nf, input of ) {
    exponent = 15 + exponent + ( ( nf == 0 ) & of[10,1] );
}

// ALIGN FRACTION TO THE RIGHT FOR DIVISION
circuitry alignright22( inout bitstream ) {
     while( ~bitstream[0,1] ) { bitstream = bitstream >> 1; }
}

// CONVERT SIGNED INTEGERS TO FLOAT
algorithm inttofloat(
    input   uint1   start,
    output  uint1   busy,
    input   int16   a,
    input   uint1   dounsigned,
    output  uint5   flags,
    output  uint16  result
) <autorun> {
    uint2   FSM = uninitialised;
    uint2   FSM2 = uninitialised;
    uint1   sign = uninitialised;
    int8    exp = uninitialised;
    uint8   zeros = uninitialised;
    uint16  number = uninitialised;

    uint1 OF = uninitialised; uint1 UF = uninitialised; uint1 NX = uninitialised;
    flags := { 1b0, 1b0, OF, UF, NX };
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                FSM = 1;
                OF = 0; UF = 0; NX = 0;
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: {
                            // SIGNED / UNSIGNED
                            sign = dounsigned ? 0 : a[15,1];
                            number = dounsigned ? a : a[15,1] ? -a : a ;
                        }
                        case 1: {
                            switch( number ) {
                                case 0: { result = 0; }
                                default: {
                                    FSM2 = 1;
                                    while( FSM2 !=0 ) {
                                        onehot( FSM2 ) {
                                            case 0: { zeros = 0; while( ~number[ 15-zeros, 1 ] ) { zeros = zeros + 1; } }
                                            case 1: {
                                                number = ( zeros < 5 ) ? number >> ( 5 - zeros ) : ( zeros > 5 ) ? number << ( zeros - 5 ) : number;
                                                exp = 30 - zeros;
                                                ( result, OF, UF ) = combinecomponents( sign, exp, number );
                                                NX = ( zeros < 5 );
                                            }
                                        }
                                        FSM2 = { FSM2[0,1], 1b0 };
                                    }
                                }
                            }
                        }
                    }
                    FSM = { FSM[0,1], 1b0 };
                }
                busy = 0;
            }
        }
    }
}

// CONVERT FLOAT TO SIGNED INTEGERS
algorithm floattoint(
    input   uint16  a,
    output  uint5   flags,
    output  int16   result,
    output  uint1   busy,
    input   uint1   start
) <autorun> {
    int8    exp = uninitialised;
    int17   sig = uninitialised;

    uint1 NV = uninitialised;
    classify A( a <: a );
    flags := { NV, 4b0000 };
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                NV = 0;
                switch( { A.INF | A.sNAN | A.qNAN, A.ZERO } ) {
                    case 2b00: {
                        exp = floatingpointnumber( a ).exponent - 15;
                        sig = ( exp < 11 ) ? { 5b1, a[0,10], 1b0 } >> ( 10 - exp ) : { 5b1, a[0,10], 1b0 } << ( exp - 11 );
                        result = ( exp > 14 ) ? ( a[15,1] ? 16hffff : 16h7fff ) : a[15,1] ? -( sig[1,16] + sig[0,1] ) : ( sig[1,16] + sig[0,1] );
                        NV = ( exp > 14 );
                    }
                    case 2b01: { result = 0; }
                    default: { NV = 1; result = a[15,1] ? 16hffff : 16h7fff; }
                }
                busy = 0;
            }
        }
    }
}

// CONVERT FLOAT TO UNSIGNED INTEGERS
algorithm floattouint(
    input   uint16  a,
    output  uint5   flags,
    output  int16   result,
    output  uint1   busy,
    input   uint1   start
) <autorun> {
    int8    exp = uninitialised;
    int17   sig = uninitialised;

    uint1 NV = uninitialised;
    classify A( a <: a );
    flags := { NV, 4b0000 };
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                switch( { A.INF | A.sNAN | A.qNAN, A.ZERO } ) {
                    case 2b00: {
                        exp = floatingpointnumber( a ).exponent - 15;
                        sig = ( exp < 11 ) ? { 5b1, a[0,10], 1b0 } >> ( 10 - exp ) : { 5b1, a[0,10], 1b0 } << ( exp - 11 );
                        result = ( exp > 15 ) ? 16hffff : a[15,1] ? 0 : ( sig[1,16] + sig[0,1] );
                        NV = ( exp > 15 );
                    }
                    case 2b01: { result = 0; }
                    default: { NV = 1; result = 16hffff; }
                }
                busy = 0;
            }
        }
    }
}

// ADDSUB
// ADD/SUBTRACT ( addsub == 0 add, == 1 subtract) TWO FLOATING POINT NUMBERS
algorithm floataddsub(
    input   uint1   start,
    output  uint1   busy,

    input   uint16  a,
    input   uint16  b,
    input   uint1   addsub,

    output  uint5   flags,
    output  uint16  result
) <autorun> {
    uint5   FSM = uninitialised;
    uint1   sign = uninitialised;
    uint1   signA = uninitialised;
    uint1   signB = uninitialised;
    int8    expA = uninitialised;
    int8    expB = uninitialised;
    uint22  sigA = uninitialised;
    uint22  sigB = uninitialised;
    uint10  newfraction = uninitialised;

    uint1 NV = uninitialised; uint1 OF = uninitialised; uint1 UF = uninitialised;
    classify A( a <: a ); classify B( a <: b );
    flags := { NV, 1b0, OF, UF, 1b0 };

    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                FSM = 1;
                NV = 0; OF = 0; UF = 0;
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: {
                            // FOR SUBTRACTION CHANGE SIGN OF SECOND VALUE
                            signA = a[15,1]; signB = addsub ? ~b[15,1] : b[15,1];
                        }
                        case 1: {
                            // EXTRACT COMPONENTS - HOLD TO LEFT TO IMPROVE FRACTIONAL ACCURACY
                            expA = floatingpointnumber( a ).exponent - 15;
                            expB = floatingpointnumber( b ).exponent - 15;
                            sigA = { 2b01, floatingpointnumber(a).fraction, 10b0 };
                            sigB = { 2b01, floatingpointnumber(b).fraction, 10b0 };
                        }
                        case 2: {
                            // ADJUST TO EQUAL EXPONENTS
                            switch( { expA < expB, expB < expA } ) {
                                case 2b10: { sigA = sigA >> ( expB - expA ); expA = expB; }
                                case 2b01: { sigB = sigB >> ( expA - expB ); expB = expA; }
                                default: {}
                            }
                        }
                        case 3: {
                            switch( { A.INF | A.sNAN | A.qNAN | B.INF | B.sNAN | B.qNAN, A.ZERO | B.ZERO } ) {
                                case 2b00: {
                                    switch( { signA, signB } ) {
                                        // PERFORM + HANDLING SIGNS
                                        case 2b01: {
                                            switch( sigB > sigA ) {
                                                case 1: { sign = 1; sigA = sigB - sigA; }
                                                case 0: { sign = 0; sigA = sigA - sigB; }
                                            }
                                        }
                                        case 2b10: {
                                            switch(  sigA > sigB ) {
                                                case 1: { sign = 1; sigA = sigA - sigB; }
                                                case 0: { sign = 0; sigA = sigB - sigA; }
                                            }
                                        }
                                        default: { sign = signA; sigA = sigA + sigB; }
                                    }
                                }
                                case 2b01: { result = ( B.ZERO ) ? a : addsub ? { ~b[15,1], b[0,15] } : b; }
                                default: {
                                    switch( { A.INF | B.INF, A.qNAN | A.sNAN | B.qNAN | B.sNAN } ) {
                                        case 2b10: { result = ( signA == signB ) ? { signA, 5b11111, 10b0 } : 16hfe00; }
                                        default: { result = 16hfe00; }
                                    }
                                }
                            }
                        }
                        case 4: {
                            switch( { A.INF | A.sNAN | A.qNAN | B.INF | B.sNAN | B.qNAN, A.ZERO | B.ZERO } ) {
                                case 2b00: {
                                    switch( sigA ) {
                                        case 0: { result = 0; }
                                        default: {
                                            // NORMALISE AND ROUND
                                            switch( sigA[21,1] ) {
                                                case 1: { expA = expA + 1; }
                                                default: {
                                                    while( ~sigA[20,1] ) { sigA = sigA << 1; expA = expA - 1; }
                                                    sigA = sigA << 1;
                                                }
                                            }
                                            ( newfraction ) = round22( sigA );
                                            ( expA ) = adjustexp22( exp, newfraction, sigA );
                                            ( result, OF, UF ) = combinecomponents( sign, expA, newfraction );
                                        }
                                    }
                                }
                                default: {}
                            }
                        }
                    }
                    FSM = FSM << 1;
                }
                busy = 0;
            }
        }
    }
}

// MULTIPLY TWO FLOATING POINT NUMBERS
algorithm floatmultiply(
    input   uint1   start,
    output  uint1   busy,

    input   uint16  a,
    input   uint16  b,

    output  uint5   flags,
    output  uint16  result
) <autorun> {
    uint2   FSM = uninitialised;

    uint1   productsign <: a[15,1] ^ b[15,1];
    uint32  product = uninitialised;
    int8    productexp  = uninitialised;
    uint10  newfraction = uninitialised;

    uint1 NV = uninitialised; uint1 OF = uninitialised; uint1 UF = uninitialised;
    classify A( a <: a ); classify B( a <: b );
    flags := { NV, 1b0, OF, UF, 1b0 };

    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                FSM = 1;
                NV = 0; OF = 0; UF = 0;
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: {
                            product = { 6b1, a[0,10] } * { 6b1, b[0,10] };
                            productexp = (floatingpointnumber( a ).exponent - 15) + (floatingpointnumber( b ).exponent - 15) + product[21,1];
                        }
                        case 1: {
                            switch( { A.INF | A.sNAN | A.qNAN | B.INF | B.sNAN | B.qNAN, A.ZERO | B.ZERO } ) {
                                case 2b00: {
                                    ( product ) = normalise22( product );
                                    ( newfraction ) = round22( product );
                                    ( productexp ) = adjustexp22( productexp, newfraction, product );
                                    ( result, OF, UF ) = combinecomponents( productsign, productexp, newfraction );
                                }
                                case 2b01: { result = { productsign, 15b0 }; }
                                default: {
                                    switch( { A.INF | B.INF, A.ZERO | B.ZERO } ) {
                                        case 2b11: { NV = 1; result = 16hfe00; }
                                        case 2b10: { result = { productsign, 5b11111, 10b0 }; }
                                        default: { result = 16hfe00; }
                                    }
                                }
                            }
                        }
                    }
                    FSM = FSM << 1;
                }
                busy = 0;
            }
        }
    }
}

// DIVIDE TWO FLOATING POINT NUMBERS
$$if not divbit_circuit then
$$divbit_circuit = 1
// PERFORM DIVISION AT SPECIFIC BIT, SHARED BETWEEN INTEGER AND  FLOATING POINT DIVISION
circuitry divbit( inout quo, inout rem, input top, input bottom, input x ) {
    sameas( rem ) temp = uninitialized;
    uint1   quobit = uninitialised;

    temp = ( rem << 1 ) | top[x,1];
    quobit = __unsigned(temp) >= __unsigned(bottom);
    rem = __unsigned(temp) - ( quobit ? __unsigned(bottom) : 0 );
    quo[x,1] = quobit;
}
$$end
algorithm floatdivide(
    input   uint1   start,
    output  uint1   busy,

    input   uint16  a,
    input   uint16  b,

    output  uint5   flags,
    output  uint16  result
) <autorun> {
    uint4   FSM = uninitialised;
    uint1   quotientsign <: a[15,1] ^ b[15,1];
    int8    quotientexp = uninitialised;
    uint24  quotient = uninitialised;
    uint24  remainder = uninitialised;
    uint5   bit = uninitialised;
    uint24  sigA = uninitialised;
    uint24  sigB = uninitialised;
    uint10  newfraction = uninitialised;

    uint1 NV = uninitialised; uint1 DZ = uninitialised; uint1 OF = uninitialised; uint1 UF = uninitialised;
    classify A( a <: a ); classify B( a <: b );
    flags := { NV, DZ, OF, UF, 1b0};
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                FSM = 1;
                NV = 0; DZ = 0; OF = 0; UF = 0;
                while( FSM != 0 ) {
                    onehot( FSM ) {
                        case 0: {
                            sigA = { 1b1, floatingpointnumber(a).fraction, 13b0 };
                            sigB = { 14b1, floatingpointnumber(b).fraction };
                            quotientexp = (floatingpointnumber( a ).exponent - 15) - (floatingpointnumber( b ).exponent - 15);
                            quotient = 0;
                            remainder = 0;
                            bit = 23;
                        }
                        case 1: { while( ~sigB[0,1] ) { sigB = sigB >> 1; } }
                        case 2: {
                            switch( { A.INF | A.sNAN | A.qNAN | B.INF | B.sNAN | B.qNAN, A.ZERO | B.ZERO } ) {
                                case 2b00: {
                                    while( bit != 31 ) {
                                        ( quotient, remainder ) = divbit( quotient, remainder, sigA, sigB, bit );
                                        bit = bit - 1;
                                    }
                                    while( quotient[22,2] != 0 ) { quotient = quotient >> 1; }
                                }
                                case 2b01: { DZ = B.ZERO; result = B.ZERO ? { quotientsign, 5b11111, 10b0 } : { quotientsign, 15b0 }; }
                                default: {
                                    switch( { A.INF, A.sNAN | A.qNAN } ) {
                                        case 2b00: { result = ( B.sNAN | B.qNAN ) ? 16hfe00 : { quotientsign, 15b0 }; }
                                        case 2b10: { NV = B.INF; result = ( B.INF | B.sNAN | B.qNAN ) ? 16hfe00 : { quotientsign, 5b11111, 10b0 }; }
                                        default: { result = 16hfe00; }
                                    }
                                }
                            }
                        }
                        case 3: {
                            switch( { A.INF | A.sNAN | A.qNAN | B.INF | B.sNAN | B.qNAN, A.ZERO | B.ZERO } ) {
                                case 2b00: {
                                    switch( quotient ) {
                                        case 0: { result = { quotientsign, 15b0 }; }
                                        default: {
                                            ( quotient ) = normalise22( quotient );
                                            ( newfraction ) = round22( quotient );
                                            quotientexp = 15 + quotientexp - ( floatingpointnumber(b).fraction > floatingpointnumber(a).fraction ) + ( ( newfraction == 0 ) & quotient[12,1] );
                                            ( result, OF, UF ) = combinecomponents( quotientsign, quotientexp, newfraction );
                                        }
                                    }
                                }
                                default: {}
                            }
                        }
                    }
                    FSM = FSM << 1;
                }
                busy = 0;
            }
        }
    }
}

// ADAPTED FROM https://projectf.io/posts/square-root-in-verilog/
algorithm floatsqrt(
    input   uint1   start,
    output  uint1   busy,

    input   uint16  a,
    output  uint5   flags,
    output  uint16  result
) <autorun> {
    uint4   FSM = uninitialised;

    uint22  x = uninitialised;
    uint22  q = uninitialised;
    uint24  ac = uninitialised;
    uint24  test_res = uninitialised;
    uint5   i = uninitialised;

    uint1   sign <: floatingpointnumber( a ).sign;
    int8    exp  = uninitialised;
    uint10  newfraction = uninitialised;

    uint1 NV = uninitialised; uint1 OF = uninitialised; uint1 UF = uninitialised;
    classify A( a <: a );
    flags := { NV, 1b0, OF, UF, 1b0 };
    busy = 0;

    while(1) {
        switch( start ) {
            case 0: {}
            case 1: {
                busy = 1;
                FSM = 1;
                NV = 0; OF = 0; UF = 0;
                switch( A.sNAN | A.qNAN ) {
                    case 1: { result = 16hfe00; }
                    default: {
                        switch( { A.INF | A.sNAN | A.qNAN, A.ZERO } ) {
                            case 2b00: {
                                switch( sign ) {
                                    case 1: { NV = 1; result = a; }
                                    case 0: {
                                        while( FSM != 0 ) {
                                            onehot( FSM ) {
                                                case 0: {
                                                    i = 0;
                                                    q = 0;
                                                    exp = floatingpointnumber( a ).exponent - 15;
                                                    ac = ~exp[0,1] ? 1 : { 22b0, 1b1, a[9,1] };
                                                    x = ~exp[0,1] ? { a[0,10], 12b0 } : { a[0,9], 13b0 };
                                                }
                                                case 1: {
                                                    while( i != 21 ) {
                                                        test_res = ac - { q, 2b01 };
                                                        ac = { test_res[23,1] ? ac[0,21] : test_res[0,21], x[20,2] };
                                                        q = { q[0,21], ~test_res[23,1] };
                                                        x = { x[0,20], 2b00 };
                                                        i = i + 1;
                                                    }
                                                }
                                                case 2: {
                                                    ( q ) = normalise22( q );
                                                }
                                                case 3: {
                                                    exp = ( exp >>> 1 ) + 15;
                                                    ( newfraction ) = round22( q );
                                                    ( result, OF, UF ) = combinecomponents( sign, exp, newfraction );
                                                }
                                            }
                                            FSM = FSM << 1;
                                        }
                                    }
                                }
                            }
                            case 2b10: {
                                switch( A.sNAN | A.qNAN ) {
                                    case 1: { result = 16hfe00; }
                                    case 0: { NV = sign; result = sign ? 16hfe00 : a; }
                                }
                            }
                            default: { result = a; }
                        }
                    }
                }
                busy = 0;
            }
        }
    }
}

// FLOATING POINT COMPARISONS - ADAPTED FROM SOFT-FLOAT

/*============================================================================

This C source file is part of the SoftFloat IEEE Floating-Point Arithmetic
Package, Release 3e, by John R. Hauser.

Copyright 2011, 2012, 2013, 2014 The Regents of the University of California.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
    this list of conditions, and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions, and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

 3. Neither the name of the University nor the names of its contributors may
    be used to endorse or promote products derived from this software without
    specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS "AS IS", AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, ARE
DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=============================================================================*/

circuitry floatless( input a, input b, output lessthan ) {
    lessthan = ( a[15,1] != b[15,1] ) ? a[15,1] & ((( a | b ) << 1) != 0 ) : ( a != b ) & ( a[15,1] ^ ( a < b));
}
circuitry floatequal( input a, input b, output equalto ) {
    equalto = ( a == b ) | ((( a | b ) << 1) == 0 );
}
circuitry floatlessequal( input a, input b, output lessequalto, ) {
    lessequalto = ( a[15,1] != b[15,1] ) ? a[15,1] | ((( a | b ) << 1) == 0 ) : ( a == b ) | ( a[15,1] ^ ( a < b ));
}

algorithm floatcompare(
    input   uint16  a,
    input   uint16  b,
    output  uint1   less,
    output  uint5   flags,
    output  uint1   equal
) <autorun> {
    classify A( a <: a ); classify B( a <: b );

    // IDENTIFY NaN
    flags := A.sNAN | B.sNAN | A.qNAN | B.qNAN ? { 5b10000} : 0;

    while(1) {
        switch( A.sNAN | A.qNAN | B.sNAN | B.qNAN ) {
            case 1: { less = 0; equal = 0; }
            case 0: {
                ( less ) = floatless( a, b );
                ( equal ) = floatequal( a, b );
            }
        }
    }
}
