
// PAWS RISC-V ALU FOR INTEGER OPERATIONS
// ALU - ALU for immediate-register operations and register-register operations

// CLZ CIRCUITS - TRANSLATED BY @sylefeb + CTZ AND CPOP ADAPTED BY ROB S
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

$$function generate_ctz(name,w_in,recurse)
$$ local w_out = clog2(w_in)
$$ local w_h   = w_in//2
$$ if w_in > 2 then generate_ctz(name,w_in//2,1) end
circuitry $name$_$w_in$ (input in,output out)
{
$$ if w_in == 2 then
   out = !in[0,1];
$$ else
   uint$clog2(w_in)-1$ half_count  = uninitialized;
   uint$w_h$           lhs         = in[$w_h$,$w_h$];
   uint$w_h$           rhs         = in[    0,$w_h$];
   uint1               right_empty = ~|rhs;
   uint$w_h$           select      = right_empty ? lhs : rhs;
   (half_count) = $name$_$w_h$(select);
   out          = {right_empty,half_count};
$$ end
}
$$end

$$function generate_cpop(name,w_in,recurse)
$$ local w_out = clog2(w_in)
$$ local w_h   = w_in//2
$$ if w_in > 2 then generate_cpop(name,w_in//2,1) end
circuitry $name$_$w_in$ (input in,output out)
{
$$ if w_in == 2 then
   out = in[0,1] + in[1,1];
$$ else
   uint$clog2(w_in)$   left_count  = uninitialized;
   uint$clog2(w_in)$   right_count = uninitialized;
   uint$w_h$           lhs         = in[$w_h$,$w_h$];
   uint$w_h$           rhs         = in[    0,$w_h$];
   (left_count)  = $name$_$w_h$(lhs);
   (right_count) = $name$_$w_h$(rhs);
   out           = left_count + right_count;
$$ end
}
$$end

// Produce circuits for 64 bits numbers
$$generate_clz('clz_silice',64)
$$generate_ctz('ctz_silice',64)
$$generate_cpop('cpop_silice',64)

// ALU - ALU for immediate-register operations and register-register operations

// CALCULATES ADD ADDI SUB
unit aluaddsub(
    input   uint1   size32,
    input   uint1   doadduw,
    input   uint1   dosub,
    input   int64   sourceReg1,
    input   int64   operand2,
    output  int64   addsub
) <reginputs> {
    always_after {
        addsub = dosub ? ( ( size32 ? sourceReg1[0,32] : sourceReg1 ) - ( size32 ? operand2[0,32] : operand2 ) ) :
                         ( ( size32 ? sourceReg1[0,32] : sourceReg1 ) + ( size32 & ~doadduw ? operand2[0,32] : operand2 ) );
    }
}
// CALCULATES BCLR BCLRI BEXT BEXTI BIN BINI BSET BSETI
unit alubits(
    input   uint64  sourceReg1,
    input   uint6   shiftcount,
    output  uint64  CLR,
    output  uint64  INV,
    output  uint64  SET,
    output  uint1   EXT
) <reginputs> {
    uint64  mask <:: ( 1 << shiftcount );

    always_after {
        { CLR = sourceReg1 & ~mask; }               { INV = sourceReg1 ^ mask; }
        { SET = sourceReg1 | mask; }                { EXT = sourceReg1[ shiftcount, 1 ]; }
    }
}
// CALCULATES BREV8
unit alubrev(
    input   uint64  sourceReg1,
    output  uint64  BREV8
) <reginputs> {
    always_after {
        BREV8 = {
                $$for i=0,7 do
                    sourceReg1[$56+i$,1],
                $$end
                $$for i=0,7 do
                    sourceReg1[$48+i$,1],
                $$end
                $$for i=0,7 do
                    sourceReg1[$40+i$,1],
                $$end
                $$for i=0,7 do
                    sourceReg1[$32+i$,1],
                $$end
                $$for i=0,7 do
                    sourceReg1[$24+i$,1],
                $$end
                $$for i=0,7 do
                    sourceReg1[$16+i$,1],
                $$end
                $$for i=0,7 do
                    sourceReg1[$8+i$,1],
                $$end
                $$for i=0,6 do
                    sourceReg1[$i$,1],
                $$end
                sourceReg1[7,1]
        };
    }
}
// CALCULATES CLZ CTZ CPOP
unit alucount(
    input   uint1   size32,
    input   uint2   counttype,
    input   uint64  sourceReg1,
    output  uint7   result
) <reginputs> {
    always_after {
        if( ~|sourceReg1 ) {
            result = size32 ? { ~counttype[1,1], 5b00000 } : { ~counttype[1,1], 6b000000 };
        } else {
            switch( counttype ) {
                case 2b00: { if( size32 ) { ( result ) = clz_silice_32( sourceReg1[0,32] ); } else { ( result ) = clz_silice_64( sourceReg1 ); } }
                case 2b01: { if( size32 ) { ( result ) = ctz_silice_32( sourceReg1[0,32] ); } else { ( result ) = ctz_silice_64( sourceReg1 ); } }
                default: { ( result ) = cpop_silice_64( size32 ? sourceReg1[0,32] : sourceReg1 ); }
            }
        }
    }
}
// CALCULATES SEXT.B SEXT.H
unit aluextendsign(
    input   uint1   halfbyte,
    input   uint16  sourceReg1,
    output  uint64  result
)  <reginputs> {
    always_after {
        result = halfbyte ? { {48{sourceReg1[15,1]}}, sourceReg1[0,16] } : { {56{sourceReg1[7,1]}}, sourceReg1[0,8] };
    }
}
// CALCULATES AND/ANDN OR/ORN XOR/XNOR
unit alulogic(
    input   uint1   doinv,
    input   uint64  sourceReg1,
    input   uint64  operand2,
    output  uint64  AND,
    output  uint64  OR,
    output  uint64  XOR
) <reginputs> {
    uint64  operand <:: doinv ? ~operand2 : operand2;

    always_after {
        { AND = sourceReg1 & operand; }             { OR = sourceReg1 | operand; }
        { XOR = sourceReg1 ^ operand; }
    }
}
// CALCULATES MAX MAXU MIN MINU
unit aluminmax(
    input   uint2   function3,
    input   uint1   signedcompare,
    input   uint1   unsignedcompare,
    input   uint64  sourceReg1,
    input   uint64  sourceReg2,
    output  uint64  result
) <reginputs> {
    always_after {
        result = function3[1,1] ^ ( function3[0,1] ? unsignedcompare : signedcompare ) ? sourceReg1 : sourceReg2;
    }
}
// UNSIGNED / SIGNED 65 by 65 bit multiplication giving 130 bit product using DSP blocks
unit alumultiply(
    input   uint1   size32,
    input   uint2   function3,
    input   int64   sourceReg1,
    input   int64   sourceReg2,
    output  int64   mult
) <reginputs> {
    // SIGN EXTEND IF SIGNED MULTIPLY
    uint2   dosigned <:: function3[1,1] ? function3[0,1] ? 2b00 : 2b01 : 2b11;
    int65   factor_1 <:: size32 ? sourceReg1[0,32] : { dosigned[0,1] & sourceReg1[ 63, 1 ], sourceReg1 }; // SIGN EXTEND IF SIGNED MULTIPLY
    int65   factor_2 <:: size32 ? sourceReg2[0,32] : { dosigned[1,1] & sourceReg2[ 63, 1 ], sourceReg2 }; // SIGN EXTEND IF SIGNED MULTIPLY
    int130   product <:: factor_1 * factor_2;

    always_after {
        mult = size32 ? product[ 0, 32 ] : product[ { |function3, 6b0 }, 64 ];
    }
}
// CALCULATES ORC.B
unit aluorc(
    input   uint64  sourceReg1,
    output  uint64  ORC
) <reginputs> {
    always_after {
        ORC = {
            {8{ |sourceReg1[56,8] }}, {8{ |sourceReg1[48,8] }}, {8{ |sourceReg1[40,8] }}, {8{ |sourceReg1[32,8] }},
            {8{ |sourceReg1[24,8] }}, {8{ |sourceReg1[16,8] }}, {8{ |sourceReg1[8,8] }}, {8{ |sourceReg1[0,8] }}
        };
    }
}
// CALCULATES PACK PACKH PACKW ( ZEXT.H when rs2 == 0 )
unit alupack(
    input   uint1   size32,
    input   uint64  sourceReg1,
    input   uint64  sourceReg2,
    output  uint64  pack,
    output  uint64  packh,
) <reginputs> {
    always_after {
        { pack = size32 ? { 32h0, sourceReg2[0,16], sourceReg1[0,16] } : { sourceReg2[0,32], sourceReg1[0,32] }; }
        { packh = { 48b0, sourceReg2[0,8], sourceReg1[0,8] }; }
    }
}
// CALCULATES REV8
unit alurev(
    input   uint64  sourceReg1,
    output  uint64  REV8
) <reginputs> {
    always_after {
        REV8 = { sourceReg1[0,8], sourceReg1[8,8], sourceReg1[16,8], sourceReg1[24,8], sourceReg1[32,8], sourceReg1[40,8], sourceReg1[48,8], sourceReg1[56,8] };
    }
}
// CALCULATES SLL SLLI SRL SRLI SRA SRAI + ROL ROR RORI
unit alushift(
    input   uint1   size32,
    input   uint1   reverse,
    input   uint64  sourceReg1,
    input   uint6   shiftcount,
    output  uint64  SLL,
    output  uint64  SRL,
    output  uint64  SRA,
    output  uint64  ROTATE
) <reginputs> {
    uint7 shiftother <:: ( size32 ? 32 : 64 ) - shiftcount;

    always_after {
        __display("32bit = %b, reverse = %b, shiftcount = %d, shiftother = %d",size32,reverse,shiftcount,shiftother);
        { SLL = ( size32 ? sourceReg1[0,32] : sourceReg1 ) << shiftcount; }
        { SRL = ( size32 ? sourceReg1[0,32] : sourceReg1 ) >> shiftcount; }
        { SRA = __signed( { size32 ? {32{sourceReg1[31,1]}} : sourceReg1[32,32], sourceReg1[0,32] } ) >>> shiftcount; }
        { ROTATE = reverse ? ( ( ( size32 ? sourceReg1[0,32] : sourceReg1 ) << shiftother ) | SRL ) : ( SLL | ( ( size32 ? sourceReg1[0,32] : sourceReg1 ) >> shiftother ) ); }
    }
}
// CALCULATES SH1ADD, SH2ADD, SH3ADD
unit alushxadd(
    input   uint1   size32,
    input   uint2   function3,
    input   uint64  sourceReg1,
    input   uint64  sourceReg2,
    output  uint64  result
) <reginputs> {
    always_after {
        result = sourceReg2 + ( ( size32 ? sourceReg1[0,32] : sourceReg1 ) << function3 );
    }
}

// DECODE ALU INSTRUCTIONS
unit aludecode(
    input   uint1   size32,
    input   uint1   regreg,
    input   uint7   function7,
    input   uint3   function3,
    input   uint5   rs2,

    output  uint1   doadduw,
    output  uint1   doalt,
    output  uint1   dobclrext,
    output  uint1   dobrev,
    output  uint1   docount,
    output  uint1   dobinv,
    output  uint1   dominmax,
    output  uint1   dobset,
    output  uint1   domul,
    output  uint1   doorc,
    output  uint1   dopack,
    output  uint1   dorev,
    output  uint1   dorotate,
    output  uint1   doshxadd,
    output  uint1   dosignx,
    output  uint1   dosra
) <reginputs> {
    uint1   f70000100 <:: ( function7 == 7b0000100 );                               // DETECT ADD.UW ZEXT.H
    uint1   f70100000 <:: ( function7 == 7b0100000 );                               // DETECT SUB ANDN ORN XNOR
    uint1   f70000001 <:: ( function7 == 7b0000001 );                               // DETECT MUL
    uint1   f70010000 <:: ( function7 == 7b0010000 );                               // DETECT SHxADD
    uint1   f70110000 <:: ( function7 == 7b0110000 );                               // DETECT SEXT.B SEXT.H
    uint1   f70010100 <:: ( function7 == 7b0010100 );                               // DETECT ORC,B
    uint1   f70110100 <:: ( function7 == 7b0110100 );                               // DETECT BREV8
    uint1   f70110101 <:: ( function7 == 7b0110101 );                               // DETECT REV8

    always_after {
        { doadduw = size32 & regreg & f70000100; }                                  // ADD.UW
        { doalt = regreg & f70100000; }                                             // ADD/SUB AND/ANDN OR/ORN XOR/XNOR ( register - register only )
        { dobclrext = ( function7[1,6] == 6b010010 ); }                             // BCLR BCLRI BEXT BEXTI
        { dobrev = ~regreg & f70110100; }                                           // BREV8
        { docount = ~regreg & f70110000 & ~rs2[2,1]; }                              // CLZ CPOP CTZ ( immediate only )
        { dobinv = ( function7[1,6] == 6b011010 ); }                                // BINV BINVI
        { dominmax = regreg & ( function7 == 7b0000101 ); }                         // MAX MAXU MIN MINU ( register - register only )
        { dobset = ( function7[1,6] == 6b001010 ); }                                // ( F3 == 001 ) BSET BSETI
        { domul = regreg & f70000001; }                                             // MULTIPLICATION
        { doorc = ~regreg & f70010100; }                                            // ( F3 = 101 ) ORC.B
        { dopack = regreg & f70000100; }                                            // ZEXT.H PACK PACKH PACKW ( ZEXT.H when rs2 == 0 )
        { dorev = ~regreg & f70110101; }                                            // REV8
        { dorotate = ( function7[1,6] == 6b011000 ); }                              // ROL ROR RORI
        { doshxadd = regreg & f70010000; }                                          // SH1ADD SH2ADD SH3ADD ( register - register only )
        { dosignx = ~regreg & f70110000 & rs2[2,1]; }                               // SEXT.B SEXT.H
        { dosra = ( function7[1,6] == 6b010000 ); }                                 // SRA SRAI
    }
}

unit alu(
    input   uint1   size32,
    input   uint5   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint5   rs2,
    input   int64   sourceReg1,
    input   int64   sourceReg2,
    input   int64   immediateValue,
    input   uint1   LT,                                                             // SIGNED COMPARE sourceReg1 < operand2
    input   uint1   LTU,                                                            // UNSIGNED COMPARE sourceReg1 < operand2
    output  int64   result
) <reginputs> {
    uint6   shiftcount <:: opCode[3,1] ? ( size32 ? sourceReg2[0,5] : sourceReg2[0,6] ) : { function7[0,1], rs2 };
    uint64  operand2 <:: opCode[3,1] ? sourceReg2 : immediateValue;

    // DECODE THE ALU OPERATION
    aludecode AD( size32 <: size32, regreg <: opCode[3,1], function7 <: function7, function3 <: function3, rs2 <: rs2 );

    aluaddsub ADDSUB( size32 <: size32, dosub <: AD.doalt, doadduw <: AD.doadduw, sourceReg1 <: sourceReg1, operand2 <: operand2 );
    alubits BITS( sourceReg1 <: sourceReg1, shiftcount <: shiftcount );
    alubrev BREV( sourceReg1 <: sourceReg1 );
    alucount COUNT( size32 <: size32, counttype <: rs2[0,2], sourceReg1 <: sourceReg1 );
    aluextendsign EXTENDS( halfbyte <: rs2[0,1], sourceReg1 <: sourceReg1 );
    alulogic LOGIC( doinv <: AD.doalt, sourceReg1 <: sourceReg1, operand2 <: operand2 );
    aluminmax MINMAX( function3 <: function3[0,2], sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2, signedcompare <: LT, unsignedcompare <: LTU );
    alumultiply MULT( size32 <: size32, function3 <: function3[0,2], sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2 );
    aluorc ORC( sourceReg1 <: sourceReg1 );
    alupack PACK( size32 <: size32, sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2 );
    alurev REV( sourceReg1 <: sourceReg1 );
    alushift SHIFTS( size32 <: size32, reverse <: function3[2,1], sourceReg1 <: sourceReg1, shiftcount <: shiftcount );
    alushxadd SHXADD( size32 <: size32, function3 <: function3[1,2], sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2 );

    always_after {
        switch( function3 ) {
            case 3b000: { result = AD.domul ? MULT.mult : ADDSUB.addsub; }
            case 3b001: { result = AD.domul ? MULT.mult : AD.dosignx ? EXTENDS.result : AD.docount ? COUNT.result : AD.dobclrext ? BITS.CLR : AD.dobinv ? BITS.INV : AD.dobset ? BITS.SET : AD.dorotate ? SHIFTS.ROTATE : SHIFTS.SLL; }
            case 3b010: { result = AD.domul ? MULT.mult : AD.doshxadd ? SHXADD.result : LT; }
            case 3b011: { result = AD.domul ? MULT.mult : opCode[3,1] ? ( ~|rs1 ) ? ( |operand2 ) : LTU : ( operand2 == 1 ) ? ( ~|sourceReg1 ) : LTU; }
            case 3b100: { result = AD.dominmax ? MINMAX.result : AD.doshxadd ? SHXADD.result : AD.dopack ? PACK.pack : LOGIC.XOR; }
            case 3b101: { result = AD.doorc ? ORC.ORC : AD.dorev ? REV.REV8 : AD.dobrev ? BREV.BREV8 : AD.dominmax ? MINMAX.result : AD.dobclrext ? BITS.EXT : AD.dorotate ? SHIFTS.ROTATE : AD.dosra ? SHIFTS.SRA : SHIFTS.SRL; }
            case 3b110: { result = AD.dominmax ? MINMAX.result : AD.doshxadd ? SHXADD.result : LOGIC.OR; }
            case 3b111: { result = AD.dominmax ? MINMAX.result : AD.dopack ? PACK.packh : LOGIC.AND; }
        }
    }
}

// Test it (make verilator)
algorithm main(output uint8 leds)
{
   alu ALU();

   // DEFINE THE INSTRUCTION
   ALU.opCode = 5b00100;
   ALU.function3 = 3b101;
   ALU.function7 = 7b0110001;

   // DEFINE THE ACTUAL REGISTER NUMBER - MATTERS FOR SLT/SLTU - RS2 DEFINES THE SHIFTCOUNT FOR REGISTER SHIFTS
   ALU.rs1 = 0; ALU.rs2 = 60;

   // INPUT VALUES
   ALU.sourceReg1 = 64h2023020507102500;
   ALU.sourceReg2 = 32h00005678;
   ALU.immediateValue = 4;

   ++: ++:

   __display("PAWS INTEGER ALU FOR I AND B except CLMUL");
   __display("");
   __display("    I1 = %x ( %b , %d )",ALU.sourceReg1,ALU.sourceReg1,ALU.sourceReg1);
   __display("    I2 = %x ( %b , %d )",ALU.sourceReg2,ALU.sourceReg2,ALU.sourceReg2);
   __display("RESULT = %x ( %b , %d )",ALU.result,ALU.result,ALU.result);
}

algorithm pulse(
    output  uint32  cycles(0)
) <autorun> {
    cycles := cycles + 1;
}
