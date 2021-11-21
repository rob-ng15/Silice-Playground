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
    uint2   rdelta,                 // two's complement adjustment for rsp
    uint2   ddelta,                 // two's complement adjustment for dsp
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
) <autorun,reginputs> {
    // J1+ CPU FINITE STATE MACHINE
    uint3   FSM = 3b001;

    // instruction being executed, plus decoding
    uint16  instruction = uninitialized;
    uint1   is_alu = uninitialized;
    uint1   is_n2memt = uninitialized;
    uint1   is_memtr = uninitialized;
    uint2   is_callbranchalu = uninitialized;
    uint1   dstackWrite = uninitialized;
    uint1   rstackWrite = uninitialized;
    decode DECODE <@clock100> ( instruction <: instruction, is_alu :> is_alu, is_n2memt :> is_n2memt, is_memtr :> is_memtr, dstackWrite :> dstackWrite, rstackWrite :> rstackWrite );

    // program counter
    uint13  pc = uninitialized;
    uint13  pcPlusOne <:: pc + 1;
    uint13  newPC = 0;

    // dstack 257x16bit (as 256 array + stackTop) and pointer, next pointer
    uint16  stackTop = 0;
    uint16  stackNext = uninitialized;
    uint8   dsp = uninitialized;
    uint8   newDSP = 0;
    uint16  newStackTop = 0;
    stack DSTACK( stackWData <: stackTop, sp <: dsp, newSP <: newDSP, stackTop :> stackNext, stackTop :> writedata );
    deltasp DELTADSP( sp <: dsp, delta <: DECODE.ddelta );

    // rstack 256x16bit and pointer, next pointer
    uint16  rStackTop = uninitialized;
    uint8   rsp = uninitialized;
    uint8   newRSP = 0;
    uint16  rstackWData = uninitialized;
    stack RSTACK( stackWData <: rstackWData, sp <: rsp, newSP <: newRSP, stackTop :> rStackTop );
    deltasp DELTARSP( sp <: rsp, delta <: DECODE.rdelta );

    // J1+ CPU EXECUTION BLOCKS
    alu ALU( instruction <: instruction, memoryRead <: readdata, stackTop <: stackTop, stackNext <: stackNext, rStackTop <: rStackTop, dsp <: dsp, rsp <: rsp );
    j1eforthcallbranch CALLBRANCH( instruction <: instruction, stackTop <: stackTop, stackNext <: stackNext, pc <: pc, pcPlusOne <: pcPlusOne, dsp <: dsp, rsp <: rsp );

    // STACK WRITE CONTROLLERS AND MEMORY ACCESS FLAGS
    DSTACK.stackWrite := 0; RSTACK.stackWrite := 0; readmemory := 0; writememory := 0;

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

                // DETECT IF ALU WITH MEMORY READ FOR FAST ALU
                FSM = is_alu & ~is_memtr ? 3b100 : 3b010;
            }
            case 1: {
                if( literal(instruction).is_literal ) {
                    // LITERAL
                    newStackTop = literal(instruction).literalvalue;
                    newPC = pcPlusOne;
                    newDSP = dsp + 1;
                    FSM = 3b001;
                } else {
                    if( is_alu ) {
                        ( address, readmemory ) = load( stackTop, memorybusy, readdata );
                        FSM = 3b100;
                    } else {
                        // CALL BRANCH 0BRANCH
                        newStackTop = CALLBRANCH.newStackTop;
                        newPC = CALLBRANCH.newPC;
                        newDSP = CALLBRANCH.newDSP;
                        newRSP = CALLBRANCH.newRSP;
                        rstackWData = { pcPlusOne, 1b0 };
                        FSM = 3b001;
                    }
                }
                // Commit to dstack and rstack
                DSTACK.stackWrite = dstackWrite;
                RSTACK.stackWrite = rstackWrite;

            }
            case 2: {
                // ALU WITHOUT MEMORY READ (FAST) OR WITH MEMORY READ (SLOW, AS LOADED IN PREVIOUS FSM STATE)
                newStackTop = ALU.newStackTop;
                rstackWData = stackTop;

                // UPDATE newDSP newRSP
                newDSP = DELTADSP.newSP;
                newRSP = DELTARSP.newSP;

                // Update PC for next instruction, return from call or next instruction
                newPC = ( aluop(instruction).is_r2pc ) ? {1b0, rStackTop[1,15] } : pcPlusOne;

                // n2memt mem[t] = n
                if( is_n2memt ) { ( address, writememory ) = store( stackTop, memorybusy ); } else {}

                // Commit to dstack and rstack
                DSTACK.stackWrite = dstackWrite;
                RSTACK.stackWrite = rstackWrite;

                FSM = 3b001;
            }
        }
    }
}

algorithm add16(
    input   uint16  a,
    input   uint16  b,
    output  uint16  c
) <autorun> {
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
) <autorun> {
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
) <autorun> {
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
) <autorun> {
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
        if( aluop(instruction).is_j1j1plus ) {
            switch( aluop(instruction).operation ) {
                case 4b0000: { newStackTop = {16{ COMPARE.equal0 }}; }
                case 4b0001: { newStackTop = {16{ ~COMPARE.equal0 }}; }
                case 4b0010: { newStackTop = {16{ ~COMPARE.equal }}; }
                case 4b0011: { newStackTop = INC.c; }
                case 4b0100: { newStackTop = product; }
                case 4b0101: { newStackTop = { stackTop[0,15], 1b0 }; }
                case 4b0110: { newStackTop = negStackTop; }
                case 4b0111: { newStackTop = { stackTop[15,1], stackTop[1,15] }; }
                case 4b1000: { newStackTop = SUB.c;}
                case 4b1001: { newStackTop = {16{ stackTop[15,1] }}; }
                case 4b1010: { newStackTop = {16{ ~stackTop[15,1] }}; }
                case 4b1011: { newStackTop = {16{ ~COMPARE.less & ~COMPARE.equal }}; }
                case 4b1100: { newStackTop = {16{ ~COMPARE.less }}; }
                case 4b1101: { newStackTop = stackTop[15,1] ? negStackTop : stackTop; }
                case 4b1110: { newStackTop = COMPARE.less ? stackTop : stackNext; }
                case 4b1111: { newStackTop = COMPARE.less ? stackNext : stackTop; }
            }
        } else {
            switch( aluop(instruction).operation ) {
                case 4b0000: { newStackTop = stackTop; }
                case 4b0001: { newStackTop = stackNext; }
                case 4b0010: { newStackTop = ADD.c; }
                case 4b0011: { newStackTop = LOGIC.AND; }
                case 4b0100: { newStackTop = LOGIC.OR; }
                case 4b0101: { newStackTop = LOGIC.XOR; }
                case 4b0110: { newStackTop = ~stackTop; }
                case 4b0111: { newStackTop = {16{COMPARE.equal}}; }
                case 4b1000: { newStackTop = {16{COMPARE.less}}; }
                case 4b1001: { newStackTop = SHIFT.SRA; }
                case 4b1010: { newStackTop = DEC.c; }
                case 4b1011: { newStackTop = rStackTop; }
                case 4b1100: { newStackTop = memoryRead; }
                case 4b1101: { newStackTop = SHIFT.SLL; }
                case 4b1110: { newStackTop = {rsp, dsp}; }
                case 4b1111: { newStackTop = {16{COMPARE.lessu}}; }
            }
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
    output  uint2   ddelta,
    output  uint2   rdelta
) <autorun,reginputs> {
    uint1   is_lit <:: literal(instruction).is_literal;
    uint1   is_call <:: ~is_lit & ( callbranch(instruction).is_callbranchalu == 2b10 );
    always {
        is_alu = ~is_lit & ( &callbranch(instruction).is_callbranchalu );
        is_n2memt = is_alu & aluop(instruction).is_n2memt;
        is_memtr = is_alu & ~aluop(instruction).is_j1j1plus & ( aluop(instruction).operation == 4b1100 );
        dstackWrite = ( is_lit | ( is_alu & aluop(instruction).is_t2n ) );
        rstackWrite = ( is_call | ( is_alu & aluop(instruction).is_t2r ) );
        ddelta = aluop(instruction).ddelta;
        rdelta = aluop(instruction).rdelta;
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
    stack.addr0 := sp; stackTop := stack.rdata0;
    stack.wenable1 := 1;

    always {
        if( stackWrite ) { stack.addr1 = newSP; stack.wdata1 = stackWData; }
    }
}

algorithm deltasp(
    input   uint8   sp,
    input   uint2   delta,
    output  uint8   newSP
) <autorun,reginputs> {
    uint8   delta8 <:: { {7{delta[1,1]}}, delta[0,1] };
    always {
        newSP = sp + delta8;
    }
}
