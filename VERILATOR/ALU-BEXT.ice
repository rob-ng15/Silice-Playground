
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
   uint$w_h$           lhs        <: in[$w_h$,$w_h$];
   uint$w_h$           rhs        <: in[    0,$w_h$];
   uint$w_h$           select     <: left_empty ? rhs : lhs;
   uint1               left_empty <: ~|lhs;
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
   uint$clog2(w_in)-1$ half_count = uninitialized;
   uint$w_h$           lhs        <: in[$w_h$,$w_h$];
   uint$w_h$           rhs        <: in[    0,$w_h$];
   uint$w_h$           select     <: right_empty ? lhs : rhs;
   uint1               right_empty <: ~|rhs;
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
   uint$clog2(w_in)$   left_count = uninitialized;
   uint$clog2(w_in)$   right_count = uninitialized;
   uint$w_h$           lhs        <: in[$w_h$,$w_h$];
   uint$w_h$           rhs        <: in[    0,$w_h$];
   (left_count) = $name$_$w_h$(lhs);
   (right_count) = $name$_$w_h$(rhs);
   out          = left_count + right_count;
$$ end
}
$$end

// Produce circuits for 32 bits numbers
$$generate_clz('clz_silice',32)
$$generate_ctz('ctz_silice',32)
$$generate_cpop('cpop_silice',32)

// CALCULATES SLL SLLI SRL SRLI SRA SRAI + ROL ROR RORI
unit alushift(
    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    input   uint1   reverse,
    output  uint32  SLL,
    output  uint32  SRL,
    output  uint32  SRA,
    output  uint32  ROTATE
) <reginputs> {
    uint6   shiftother <:: 32 - shiftcount;

    always_after {
        SLL = sourceReg1 << shiftcount;
        SRL = sourceReg1 >> shiftcount;
        SRA = __signed(sourceReg1) >>> shiftcount;
        ROTATE = reverse ? ( ( sourceReg1 << shiftother ) | SRL ) : ( SLL | ( sourceReg1 >> shiftother ) );
    }
}
// CALCULATES BCLR BCLRI BEXT BEXTI BIN BINI BSET BSETI
unit alubits(
    input   uint32  sourceReg1,
    input   uint5   shiftcount,
    output  uint32  CLR,
    output  uint32  INV,
    output  uint32  SET,
    output  uint1   EXT
) <reginputs> {
    uint32  mask <:: ( 1 << shiftcount );

    always_after {
        CLR = sourceReg1 & ~mask;                      INV = sourceReg1 ^ mask;
        SET = sourceReg1 | mask;                       EXT = sourceReg1[ shiftcount, 1 ];
    }
}
// CALCULATES ADD ADDI SUB
unit aluaddsub(
    input   uint1   dosub,
    input   int32   sourceReg1,
    input   int32   operand2,
    input   int32   negoperand2,
    output  int32   AS
) <reginputs> {
    always_after {
        AS = sourceReg1 + ( dosub ? negoperand2 : operand2 );
    }
}
// CALCULATES AND/ANDN OR/ORN XOR/XNOR
unit alulogic(
    input   uint32  sourceReg1,
    input   uint32  operand2,
    input   uint1   doinv,
    output  uint32  AND,
    output  uint32  OR,
    output  uint32  XOR
) <reginputs> {
    uint32  operand <:: doinv ? ~operand2 : operand2;

    always_after {
        AND = sourceReg1 & operand;                    OR = sourceReg1 | operand;
        XOR = sourceReg1 ^ operand;
    }
}
// CALCULATES SH1ADD, SH2ADD, SH3ADD
unit alushxadd(
    input   uint2   function3,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  result
) <reginputs> {
    always_after {
        result = sourceReg2 + ( sourceReg1 << function3 );
    }
}
// CALCULATES CLZ CTZ CPOP
unit alucount(
    input   uint2   counttype,
    input   uint32  sourceReg1,
    output  uint6   result
) <reginputs> {
    always_after {
        if( ~|sourceReg1 ) {
            result = { ~counttype[1,1], 5b00000 };
        } else {
            switch( counttype ) {
                case 2b00: { ( result ) = clz_silice_32( sourceReg1 ); }
                case 2b01: { ( result ) = ctz_silice_32( sourceReg1 ); }
                default: { ( result ) = cpop_silice_32( sourceReg1 ); }
            }
        }
    }
}
// CALCULATES MAX MAXU MIN MINU
unit aluminmax(
    input   uint2   function3,
    input   uint1   signedcompare,
    input   uint1   unsignedcompare,
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  result
) <reginputs> {
    always_after {
        result = function3[1,1] ^ ( function3[0,1] ? unsignedcompare : signedcompare ) ? sourceReg1 : sourceReg2;
    }
}
// CALCULATES ORC.B REV8 BREV8
unit aluorcrev(
    input   uint32  sourceReg1,
    input   uint1   revtype,
    output  uint32  ORC,
    output  uint32  REV8
) <reginputs> {
    always_after {
        ORC = { {8{ |sourceReg1[24,8] }}, {8{ |sourceReg1[16,8] }}, {8{ |sourceReg1[8,8] }}, {8{ |sourceReg1[0,8] }} };
        REV8 = revtype ? {
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
        } : { sourceReg1[0,8], sourceReg1[8,8], sourceReg1[16,8], sourceReg1[24,8] };
    }
}
// CALCULATES PACK PACKH ( ZEXT.H when rs2 == 0 )
unit alupack(
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  pack,
    output  uint32  packh
) <reginputs> {
    always_after {
        pack = { sourceReg2[0,16], sourceReg1[0,16] };
        packh = { 16b0, sourceReg2[0,8], sourceReg1[0,8] };
    }
}
// CALCULATES SEXT.B SEXT.H
unit aluextend(
    input   uint1   halfbyte,
    input   uint32  sourceReg1,
    output  uint32  result
)  <reginputs> {
    always_after {
        result = halfbyte ? { {16{sourceReg1[15,1]}}, sourceReg1[0,16] } : { {24{sourceReg1[7,1]}}, sourceReg1[0,8] };
    }
}
// CALCULATES ZIP UNZIP
unit aluzip(
    input   uint32  sourceReg1,
    output  uint32  zip,
    output  uint32  unzip
)  <reginputs> {
    always_after {
        zip = {
            $$for i=0,14 do
                sourceReg1[$16+(15-i)$,1],
                sourceReg1[$(15-i)$,1],
            $$end
            sourceReg1[16,1],
            sourceReg1[0,1]
        };
        unzip = {
            $$for i=0,15 do
                sourceReg1[$(15-i)*2+1$,1],
            $$end
            $$for i=0,14 do
                sourceReg1[$(15-i)*2$,1],
            $$end
            sourceReg1[0,1]
        };
    }
}
// CALCULATES XPERM4 XPERM8
unit aluxperm(
    input   uint32  sourceReg1,
    input   uint32  sourceReg2,
    output  uint32  xperm4,
    output  uint32  xperm8
) <reginputs> {
    always_after {
        xperm8 = { { |sourceReg2[26,2] ? 8b00000000 : sourceReg1[ {sourceReg2[24,2], 3b000}, 8 ] },
                   { |sourceReg2[18,2] ? 8b00000000 : sourceReg1[ {sourceReg2[16,2], 3b000}, 8 ] },
                   { |sourceReg2[10,2] ? 8b00000000 : sourceReg1[ {sourceReg2[8,2], 3b000}, 8 ] },
                   { |sourceReg2[2,2] ? 8b00000000 : sourceReg1[ {sourceReg2[0,2], 3b000}, 8 ] } };
        xperm4 = { { sourceReg2[31,1] ? 4b0000 : sourceReg1[ {sourceReg2[28,3], 2b00}, 4 ] },
                   { sourceReg2[27,1] ? 4b0000 : sourceReg1[ {sourceReg2[24,3], 2b00}, 4 ]  },
                   { sourceReg2[23,1] ? 4b0000 : sourceReg1[ {sourceReg2[20,3], 2b00}, 4 ] },
                   { sourceReg2[19,1] ? 4b0000 : sourceReg1[ {sourceReg2[16,3], 2b00}, 4 ] },
                   { sourceReg2[15,1] ? 4b0000 : sourceReg1[ {sourceReg2[12,3], 2b00}, 4 ]  },
                   { sourceReg2[11,1] ? 4b0000 : sourceReg1[ {sourceReg2[8,3], 2b00}, 4 ] },
                   { sourceReg2[7,1] ? 4b0000 : sourceReg1[ {sourceReg2[4,3], 2b00}, 4 ] },
                   { sourceReg2[3,1] ? 4b0000 : sourceReg1[ {sourceReg2[0,3], 2b00}, 4 ] } };
    }
}

// DECODE ALU INSTRUCTIONS
unit aludecode(
    input   uint1   regreg,
    input   uint7   function7,
    input   uint3   function3,
    input   uint5   rs2,

    output  uint1   doalt,
    output  uint1   dosra,
    output  uint1   dorotate,
    output  uint1   dobclrext,
    output  uint1   dobinv,
    output  uint1   dobset,
    output  uint1   doshxadd,
    output  uint1   docount,
    output  uint1   dominmax,
    output  uint1   dosignx,
    output  uint1   dopack,
    output  uint1   doorc,
    output  uint1   doxperm,
    output  uint1   dorev,
    output  uint1   dozip
) <reginputs> {
    uint1   f70100000 <:: ( function7 == 7b0100000 );
    uint1   f70110000 <:: ( function7 == 7b0110000 );
    uint1   f70110100 <:: ( function7 == 7b0110100 );
    uint1   f70010100 <:: ( function7 == 7b0010100 );
    uint1   f70000100 <:: ( function7 == 7b0000100 );

    always_after {
        doalt = regreg & f70100000;                                         // ADD/SUB AND/ANDN OR/ORN XOR/XNOR ( register - register only )
        dosra = f70100000;                                                  // SRA SRAI
        dorotate = f70110000;                                               // ROL ROR RORI
        dobclrext = ( function7 == 7b0100100 );                             // BCLR BCLRI BEXT BEXTI
        dobinv = f70110100;                                                 // BINV BINVI
        dobset = f70010100;                                                 // ( F3 == 001 ) BSET BSETI
        doshxadd = regreg & ( function7 == 7b0010000 );                     // SH1ADD SH2ADD SH3ADD ( register - register only )
        docount = ~regreg & f70110000 & ~rs2[2,1];                          // CLZ CPOP CTZ ( immediate only )
        dominmax = regreg & function3[2,1] & ( function7 == 7b0000101 );    // MAX MAXU MIN MINU ( register - register only )
        dosignx = ~regreg & f70110000 & rs2[2,1];                           // SEXT.B SEXT.H
        dopack = regreg & f70000100;                                        // ZEXT.H PACK PACKH ( ZEXT.H when rs2 == 0 )
        dozip = ~regreg & f70000100;                                        // UNZIP ZIP
        doorc = ~regreg & f70010100;                                   // ( F3 = 101 ) ORC.B
        dorev = ~regreg & f70110100;                                        // REV8
        doxperm = regreg & f70010100;                                   // ( F3 == 010 ) XPERM4 ( F3 = 100 ) XPERM8
    }
}

unit alu(
    input   uint5   opCode,
    input   uint3   function3,
    input   uint7   function7,
    input   uint5   rs1,
    input   uint5   rs2,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    input   int32   negSourceReg2,
    input   int32   immediateValue,
    input   uint1   LT,                                                             // SIGNED COMPARE sourceReg1 < operand2
    input   uint1   LTU,                                                            // UNSIGNED COMPARE sourceReg1 < operand2

    output  int32   result
) <reginputs> {
    aludecode AD( regreg <: opCode[3,1], function7 <: function7, function3 <: function3, rs2 <: rs2 );

    uint5   shiftcount <:: opCode[3,1] ? sourceReg2[0,5] : rs2;
    uint32  operand2 <:: opCode[3,1] ? sourceReg2 : immediateValue;

    aluaddsub ADDSUB( dosub <: AD.doalt, sourceReg1 <: sourceReg1, operand2 <: operand2, negoperand2 <: negSourceReg2 );
    alushift SHIFTS( sourceReg1 <: sourceReg1, shiftcount <: shiftcount, reverse <: function3[2,1] );
    alubits BITS( sourceReg1 <: sourceReg1, shiftcount <: shiftcount );
    alulogic LOGIC( sourceReg1 <: sourceReg1, operand2 <: operand2, doinv <: AD.doalt );
    alushxadd SHXADD( function3 <: function3[1,2], sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2 );
    alucount COUNT( counttype <: rs2[0,2], sourceReg1 <: sourceReg1 );
    aluminmax MINMAX( function3 <: function3[0,2], sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2, signedcompare <: LT, unsignedcompare <: LTU );
    aluextend EXTEND( halfbyte <: rs2[0,1], sourceReg1 <: sourceReg1 );
    aluorcrev ORCREV( sourceReg1 <: sourceReg1, revtype <: rs2[2,1] );
    alupack PACK( sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2 );
    aluxperm XPERM( sourceReg1 <: sourceReg1, sourceReg2 <: sourceReg2 );
    aluzip ZIP( sourceReg1 <: sourceReg1 );

    always_after {
        switch( function3 ) {
            case 3b000: { result = ADDSUB.AS; }
            case 3b001: { result = AD.dosignx ? EXTEND.result : AD.docount ? COUNT.result : AD.dobclrext ? BITS.CLR : AD.dobinv ? BITS.INV : AD.dobset ? BITS.SET : AD.dozip ? ZIP.zip : AD.dorotate ? SHIFTS.ROTATE : SHIFTS.SLL; }
            case 3b010: { result = AD.doshxadd ? SHXADD.result : AD.doxperm ? XPERM.xperm4 : LT; }
            case 3b011: { result = opCode[3,1] ? ( ~|rs1 ) ? ( |operand2 ) : LTU : ( operand2 == 1 ) ? ( ~|sourceReg1 ) : LTU; }
            case 3b100: { result = AD.dominmax ? MINMAX.result : AD.doshxadd ? SHXADD.result : AD.dopack ? PACK.pack : AD.doxperm ? XPERM.xperm8 : LOGIC.XOR; }
            case 3b101: { result = AD.doorc ? ORCREV.ORC : AD.dorev ? ORCREV.REV8 : AD.dominmax ? MINMAX.result : AD.dobclrext ? BITS.EXT : AD.dozip ? ZIP.zip : AD.dorotate ? SHIFTS.ROTATE : AD.dosra ? SHIFTS.SRA : SHIFTS.SRL; }
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
   ALU.opCode = 5b01100;
   ALU.function3 = 3b010;
   ALU.function7 = 7b0010100;

   // DEFINE THE ACTUAL REGISTER NUMBER - MATTERS FOR SLT/SLTU - RS2 DEFINES THE SHIFTCOUNT FOR REGISTER SHIFTS
   ALU.rs1 = 0; ALU.rs2 = 16;

   // INPUT VALUES
   ALU.sourceReg1 = 32h00001234;
   ALU.sourceReg2 = 32h00005678;
   ALU.negSourceReg2 = -ALU.sourceReg2;
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
