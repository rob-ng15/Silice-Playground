// BITFIELDS to help with bit/field access

// Instruction is 3 bits 1xx = literal value, 000 = branch, 001 = 0branch, 010 = call, 011 = alu, followed by 13 bits of instruction specific data
bitfield instruction {
    uint3   is_litcallbranchalu,
    uint13   padding
}

// A literal instruction is 1 followed by a 15 bit UNSIGNED literal value
bitfield literal {
    uint1   is_literal,
    uint15  literalvalue
}

// A branch, 0branch or call instruction is 0 followed by 00 = branch, 01 = 0branch, 10 = call followed by 13bit target address
bitfield callbranch {
    uint1   is_literal,
    uint2   is_callbranchalu,
    uint13  address
}
// An alu instruction is 0 (not literal) followed by 11 = alu
bitfield aluop {
    uint1   is_literal,
    uint2   is_callbranchalu,
    uint1   is_r2pc,                // return from subroutine
    uint4   operation,              // arithmetic / memory read/write operation to perform
    uint1   is_t2n,                 // top to next in stack
    uint1   is_t2r,                 // top to return stack
    uint1   is_n2memt,              // write to memory
    uint1   is_j1j1plus,            // Original J1 or extra J1+ alu operations
    uint1   rdelta1,                // two's complement adjustment for rsp
    uint1   rdelta0,
    uint1   ddelta1,                // two's complement adjustment for dsp
    uint1   ddelta0
}

// CPU FETCH 16 bit WORD FROM MEMORY
circuitry fetch( input location, input memorybusy, input readdata, output address, output readmemory, output memoryinput ) {
    address = location; readmemory = 1; while( memorybusy ) {} memoryinput = readdata;
}
circuitry load( input location, input memorybusy, input readdata, output address, output readmemory ) {
    address = ( location[12,4] > 4hb ) ? location : { 1b0, location[1,15] }; readmemory = 1; while( memorybusy ) {}
}
// CPU STORE TO MEMORY
circuitry store( input location, input memorybusy, output address, output writememory ) {
    address = ( location[12,4] > 4hb ) ? location : { 1b0, location[1,15] }; writememory = 1;
}

algorithm J1CPU(
    input   uint1   clock100,
    output  uint32  address,
    output  uint16  writedata,
    output  uint1   writememory,
    input   uint16  readdata,
    output  uint1   readmemory,

    input   uint1   memorybusy
) <autorun> {
    // J1+ CPU
    uint3   FSM = 3b001;

    // instruction being executed, plus decoding, including 5bit deltas for dsp and rsp expanded from 2bit encoded in the alu instruction
    uint16  instruction = uninitialized;
    uint1   is_alu = uninitialized;
    uint1   is_n2memt = uninitialized;
    uint1   is_memtr = uninitialized;
    uint2   is_callbranchalu = uninitialized;
    uint1   dstackWrite = uninitialized;
    uint1   rstackWrite = uninitialized;
    uint8   ddelta = uninitialized;
    uint8   rdelta = uninitialized;
    decode DECODE <@clock100> (
        instruction <: instruction,
        is_alu :> is_alu,
        is_n2memt :> is_n2memt,
        is_memtr :> is_memtr,
        dstackWrite :> dstackWrite,
        rstackWrite :> rstackWrite,
        ddelta :> ddelta,
        rdelta :> rdelta
    );

    // program counter
    uint13  pc = uninitialized;
    uint13  pcPlusOne <:: pc + 1;
    uint13  newPC = 0;

    // dstack 257x16bit (as 3256 array + stackTop) and pointer, next pointer, write line, delta
    stack DSTACK( stackWData <: stackTop, sp <: dsp, newSP <: newDSP, stackTop :> stackNext, stackTop :> writedata, stackWrite <: DSTACKstackWrite );
    uint8   DELTADSPnewSP = uninitialized;
    deltasp DELTADSP( sp <: dsp, delta <: ddelta, newSP :> DELTADSPnewSP );
    uint16  stackTop = uninitialized;
    uint16  stackNext = uninitialized;
    uint8   dsp = uninitialized;
    uint8   newDSP = 0;
    uint16  newStackTop = 0;
    uint1   DSTACKstackWrite = uninitialized;

    // rstack 256x16bit and pointer, next pointer, write line
    stack RSTACK( stackWData <: rstackWData, sp <: rsp, newSP <: newRSP, stackTop :> rStackTop, stackWrite <: RSTACKstackWrite );
    uint8   DELTARSPnewSP = uninitialized;
    deltasp DELTARSP( sp <: rsp, delta <: rdelta, newSP :> DELTARSPnewSP );
    uint16  rStackTop = uninitialized;
    uint8   rsp = uninitialized;
    uint8   newRSP = 0;
    uint16  rstackWData = uninitialized;
    uint1   RSTACKstackWrite = uninitialized;

    uint16  ALUnewStackTop = uninitialized;
    alu ALU(
        instruction <: instruction,
        memoryRead <: readdata,
        stackTop <: stackTop,
        stackNext <: stackNext,
        rStackTop <: rStackTop,
        dsp <: dsp,
        rsp <: rsp,
        newStackTop :> ALUnewStackTop
    );

    uint16  CALLBRANCHnewStackTop = uninitialized;
    uint13  CALLBRANCHnewPC = uninitialized;
    uint8   CALLBRANCHnewDSP = uninitialized;
    uint8   CALLBRANCHnewRSP = uninitialized;
    j1eforthcallbranch CALLBRANCH(
        instruction <: instruction,
        stackTop <: stackTop,
        stackNext <: stackNext,
        pc <: pc,
        pcPlusOne <: pcPlusOne,
        dsp <: dsp,
        rsp <: rsp,
        newStackTop :> CALLBRANCHnewStackTop,
        newPC :> CALLBRANCHnewPC,
        newDSP :> CALLBRANCHnewDSP,
        newRSP :> CALLBRANCHnewRSP
    );

    // STACK WRITE CONTROLLERS
    DSTACKstackWrite := 0; RSTACKstackWrite := 0;

    // MEMORY ACCESS FLAGS
    readmemory := 0; writememory := 0;

    // EXECUTE J1 CPU
    while( 1 ) {
        onehot( FSM ) {
            case 0: {
                // Update dsp, rsp, pc, stackTop
                dsp = newDSP;
                pc = newPC;
                stackTop = newStackTop;
                rsp = newRSP;

                // START FETCH INSTRUCTION
                ( address, readmemory, instruction ) = fetch( pc, memorybusy, readdata );

                FSM = is_alu & ~is_memtr ? 3b100 : 3b010;
            }
            case 1: {
                if( literal(instruction).is_literal ) {
                    // LITERAL
                    newStackTop = literal(instruction).literalvalue;
                    newPC = pcPlusOne;
                    newDSP = dsp + 1;

                    // Commit to dstack
                    DSTACKstackWrite = dstackWrite;

                    FSM = 3b001;
                } else {
                    if( is_alu ) {
                        ( address, readmemory ) = load( stackTop, memorybusy, readdata );
                        FSM = 3b100;
                    } else {
                        // CALL BRANCH 0BRANCH
                        newStackTop = CALLBRANCHnewStackTop;
                        newPC = CALLBRANCHnewPC;
                        newDSP = CALLBRANCHnewDSP;
                        newRSP = CALLBRANCHnewRSP;
                        rstackWData = { pcPlusOne, 1b0 };

                        // Commit to dstack and rstack
                        DSTACKstackWrite = dstackWrite;
                        RSTACKstackWrite = rstackWrite;

                        FSM = 3b001;
                    }
                }
            }
            case 2: {
                // ALU WITH MEMORY READ
                newStackTop = ALUnewStackTop;
                rstackWData = stackTop;

                // UPDATE newDSP newRSP
                newDSP = DELTADSPnewSP;
                newRSP = DELTARSPnewSP;

                // Update PC for next instruction, return from call or next instruction
                newPC = ( aluop(instruction).is_r2pc ) ? {1b0, rStackTop[1,15] } : pcPlusOne;

                // n2memt mem[t] = n
                if( is_n2memt ) {
                    ( address, writememory ) = store( stackTop, memorybusy );
                } else {}

                // Commit to dstack and rstack
                DSTACKstackWrite = dstackWrite;
                RSTACKstackWrite = rstackWrite;

                FSM = 3b001;
            }
        }
    }
}

algorithm add16(
    input   uint16  a,
    input   uint16  b,
    output  uint16  c
) <autorun,reginputs> {
    always {
        c = a + b;
    }
}
algorithm logic16(
    input   uint16  a,
    input   uint16  b,
    output  uint16  AND,
    output  uint16  OR,
    output  uint16  XOR
) <autorun,reginputs> {
    always {
        AND = a & b;
        OR = a | b;
        XOR = a ^ b;
    }
}
algorithm compare(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint1   equal,
    output  uint1   lessu,
    output  uint1   less,
    output  uint1   equal0,
) <autorun,reginputs> {
    always {
        equal = stackNext == stackTop;
        lessu = __unsigned(stackNext) < __unsigned(stackTop);
        less = __signed(stackNext) < __signed(stackTop);
        equal0 = ~|stackTop;
    }
}
algorithm shift16(
    input   uint16  a,
    input   uint4   count,
    output  uint16  SLL,
    output  uint16  SRA
) <autorun,reginputs> {
    always {
        SLL = a << count;
        SRA = __signed(a) >> count;
    }
}
algorithm alu(
    input   uint16  instruction,
    input   uint16  stackTop,
    input   uint16  stackNext,
    input   uint16  rStackTop,
    input   uint8   dsp,
    input   uint8   rsp,
    input   uint16  memoryRead,
    output  uint16  newStackTop
) <autorun,reginputs> {
    int16   product <:: stackTop * stackNext;
    int16   negStackTop <:: -stackTop;
    compare COMPARE( stackTop <: stackTop, stackNext <: stackNext );
    add16 ADD( a <: stackTop, b <: stackNext );
    add16 SUB( a <: stackNext, b <: negStackTop );
    add16 INC( a <: stackTop );
    add16 DEC( a <: stackTop );
    logic16 LOGIC( a <: stackTop, b <: stackNext );
    shift16 SHIFT( a <: stackNext, count <: nibbles(stackTop).nibble0 );
    always {
        switch( { aluop(instruction).is_j1j1plus, aluop(instruction).operation } ) {
            case 5b00000: { newStackTop = stackTop; }
            case 5b00001: { newStackTop = stackNext; }
            case 5b00010: { newStackTop = ADD.c; }
            case 5b00011: { newStackTop = LOGIC.AND; }
            case 5b00100: { newStackTop = LOGIC.OR; }
            case 5b00101: { newStackTop = LOGIC.XOR; }
            case 5b00110: { newStackTop = ~stackTop; }
            case 5b00111: { newStackTop = {16{COMPARE.equal}}; }
            case 5b01000: { newStackTop = {16{COMPARE.less}}; }
            case 5b01001: { newStackTop = SHIFT.SRA; }
            case 5b01010: { newStackTop = DEC.c; }
            case 5b01011: { newStackTop = rStackTop; }
            case 5b01100: { newStackTop = memoryRead; }
            case 5b01101: { newStackTop = SHIFT.SLL; }
            case 5b01110: { newStackTop = {rsp, dsp}; }
            case 5b01111: { newStackTop = {16{COMPARE.lessu}}; }
            case 5b10000: { newStackTop = {16{ COMPARE.equal0 }}; }
            case 5b10001: { newStackTop = {16{ ~COMPARE.equal0 }}; }
            case 5b10010: { newStackTop = {16{ ~COMPARE.equal }}; }
            case 5b10011: { newStackTop = INC.c; }
            case 5b10100: { newStackTop = product; }
            case 5b10101: { newStackTop = { stackTop[0,15], 1b0 }; }
            case 5b10110: { newStackTop = negStackTop; }
            case 5b10111: { newStackTop = { stackTop[15,1], stackTop[1,15] }; }
            case 5b11000: { newStackTop = SUB.c;}
            case 5b11001: { newStackTop = {16{ stackTop[15,1] }}; }
            case 5b11010: { newStackTop = {16{ ~stackTop[15,1] }}; }
            case 5b11011: { newStackTop = {16{ ~COMPARE.less & ~COMPARE.equal }}; }
            case 5b11100: { newStackTop = {16{ ~COMPARE.less }}; }
            case 5b11101: { newStackTop = stackTop[15,1] ? negStackTop : stackTop; }
            case 5b11110: { newStackTop = COMPARE.less ? stackTop : stackNext; }
            case 5b11111: { newStackTop = COMPARE.less ? stackNext : stackTop; }
        }
    }
    INC.b = 1; DEC.b = -1;
}
algorithm j1eforthcallbranch(
    input   uint16  instruction,
    input   uint16  stackTop,
    input   uint16  stackNext,
    input   uint13  pc,
    input   uint13  pcPlusOne,
    input   uint8   dsp,
    input   uint8   rsp,

    output  uint16  newStackTop,
    output  uint13  newPC,
    output  uint8   newDSP,
    output  uint8   newRSP,
) <autorun,reginputs> {
    always {
        newStackTop = callbranch(instruction).is_callbranchalu[0,1] ? stackNext : stackTop;
        newDSP = dsp - callbranch(instruction).is_callbranchalu[0,1];
        newRSP = rsp + callbranch(instruction).is_callbranchalu[1,1];
        newPC = callbranch(instruction).is_callbranchalu[0,1] & ( |stackTop ) ? pcPlusOne : callbranch(instruction).address;
    }
}

algorithm decode(
    input   uint16  instruction,
    output  uint1   is_alu,
    output  uint1   is_n2memt,
    output  uint1   is_memtr,
    output  uint1   dstackWrite,
    output  uint1   rstackWrite,
    output  uint8   ddelta,
    output  uint8   rdelta
) <autorun,reginputs> {
    uint1   is_lit <:: literal(instruction).is_literal;
    uint1   is_call <:: ~is_lit & ( callbranch(instruction).is_callbranchalu == 2b10 );
    always {
        is_alu = ~is_lit & ( &callbranch(instruction).is_callbranchalu );
        is_n2memt = is_alu & aluop(instruction).is_n2memt;
        is_memtr = is_alu & ~aluop(instruction).is_j1j1plus & ( aluop(instruction).operation == 4b1100 );
        dstackWrite = ( is_lit | ( is_alu & aluop(instruction).is_t2n ) );
        rstackWrite = ( is_call | ( is_alu & aluop(instruction).is_t2r ) );
        ddelta = { {7{aluop(instruction).ddelta1}}, aluop(instruction).ddelta0 };
        rdelta = { {7{aluop(instruction).rdelta1}}, aluop(instruction).rdelta0 };
    }
}

algorithm stack(
    input   uint16  stackWData,
    input   uint1   stackWrite,
    input   uint8   sp,
    input   uint8   newSP,
    output  uint16  stackTop
) <autorun,reginputs> {
    simple_dualport_bram uint16 stack[256] = uninitialized; // bram (code from @sylefeb)
    stack.addr0 := sp;
    stack.wenable1 := 1;
    stackTop := stack.rdata0;
    always {
        if( stackWrite ) { stack.addr1 = newSP; stack.wdata1 = stackWData; }
    }
}

algorithm deltasp(
    input   uint8   sp,
    input   uint8   delta,
    output  uint8   newSP
) <autorun,reginputs> {
    always {
        newSP = sp + delta;
    }
}
