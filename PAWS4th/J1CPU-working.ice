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
circuitry store( input location, input value, input memorybusy, output address, output writedata, output writememory ) {
    address = ( location[12,4] > 4hb ) ? location : { 1b0, location[1,15] }; writedata = value; writememory = 1;
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
    uint1   is_call = uninitialized;
    uint1   is_n2memt = uninitialized;
    uint2   is_callbranchalu = uninitialized;
    uint1   dstackWrite = uninitialized;
    uint1   rstackWrite = uninitialized;
    uint8   ddelta = uninitialized;
    uint8   rdelta = uninitialized;
    decode DECODE <@clock100> (
        instruction <: instruction,
        is_alu :> is_alu,
        is_n2memt :> is_n2memt,
        dstackWrite :> dstackWrite,
        rstackWrite :> rstackWrite,
        ddelta :> ddelta,
        rdelta :> rdelta
    );

    // program counter
    uint13  pc = 0;
    uint13  pcPlusOne = uninitialized;
    uint13  newPC = 0;

    // dstack 257x16bit (as 3256 array + stackTop) and pointer, next pointer, write line, delta
    stack DSTACK( stackWData <: stackTop, sp <: dsp, newSP <: newDSP, stackTop :> stackNext );
    deltasp DELTADSP( sp <: dsp, delta <: ddelta );
    uint16  stackTop = 0;
    uint16  stackNext = uninitialized;
    uint8   dsp = 0;
    uint8   newDSP = 0;
    uint16  newStackTop = 0;

    // rstack 256x16bit and pointer, next pointer, write line
    stack RSTACK( stackWData <: rstackWData, sp <: rsp, newSP <: newRSP, stackTop :> rStackTop );
    deltasp DELTARSP( sp <: rsp, delta <: rdelta );
    uint16  rStackTop = uninitialized;
    uint8   rsp = 0;
    uint8   newRSP = 0;
    uint16  rstackWData = uninitialized;

    alu0 ALU0(
        instruction <: instruction,
        memoryRead <: readdata,
        stackTop <: stackTop,
        stackNext <: stackNext,
        rStackTop <: rStackTop,
        dsp <: dsp,
        rsp <: rsp,
    );
    alu1 ALU1(
        instruction <: instruction,
        stackTop <: stackTop,
        stackNext <: stackNext,
    );

    j1eforthcallbranch CALLBRANCH <@clock100> (
        instruction <: instruction,
        stackTop <: stackTop,
        stackNext <: stackNext,
        pc <: pc,
        pcPlusOne <: pcPlusOne,
        dsp <: dsp,
        rsp <: rsp
    );

    // STACK WRITE CONTROLLERS
    DSTACK.stackWrite := 0;
    RSTACK.stackWrite := 0;

    // MEMORY ACCESS FLAGS
    readmemory := 0;
    writememory := 0;

    // EXECUTE J1 CPU
    while( 1 ) {
        onehot( FSM ) {
            case 0: {
                // Update dsp, rsp, pc, stackTop
                dsp = newDSP;
                pc = newPC;
                stackTop = newStackTop;
                rsp = newRSP;
                pcPlusOne = pc + 1;

                // START FETCH INSTRUCTION
                ( address, readmemory, instruction ) = fetch( pc, memorybusy, readdata );
                FSM = 3b010;
            }
            case 1: {
                switch( ~aluop(instruction).is_j1j1plus & is_alu & ( aluop(instruction).operation == 4b1100 ) ) {
                    case 1: {
                        // ALU LOAD FROM MEMORY
                        ( address, readmemory ) = load( stackTop, memorybusy, readdata );
                        FSM = 3b100;
                    }
                    case 0: {
                        switch( literal(instruction).is_literal ) {
                            case 1: {
                                // LITERAL
                                newStackTop = literal(instruction).literalvalue;
                                newPC = pcPlusOne;
                                newDSP = dsp + 1;

                                // Commit to dstack and rstack
                                DSTACK.stackWrite = dstackWrite;

                                FSM = 3b001;
                            }
                            case 0: {
                                switch( is_alu ) {
                                    case 1: {
                                        // ALU + NO MEMORYREAD
                                        newStackTop = aluop(instruction).is_j1j1plus ? ALU1.newStackTop : ALU0.newStackTop;
                                        rstackWData = stackTop;

                                        // UPDATE newDSP newRSP
                                        newDSP = DELTADSP.newSP;
                                        newRSP = DELTARSP.newSP;

                                        // Update PC for next instruction, return from call or next instruction
                                        newPC = ( aluop(instruction).is_r2pc ) ? {1b0, rStackTop[1,15] } : pcPlusOne;

                                        // n2memt mem[t] = n
                                        switch( is_n2memt ) {
                                            case 1: { ( address, writedata, writememory ) = store( stackTop, stackNext, memorybusy ); }
                                            default: {}
                                        }

                                        // Commit to dstack and rstack
                                        DSTACK.stackWrite = dstackWrite;
                                        RSTACK.stackWrite = rstackWrite;

                                        FSM =  3b001;
                                    }
                                    case 0: {
                                        // CALL BRANCH 0BRANCH
                                        newStackTop = CALLBRANCH.newStackTop;
                                        newPC = CALLBRANCH.newPC;
                                        newDSP = CALLBRANCH.newDSP;
                                        newRSP = CALLBRANCH.newRSP;
                                        rstackWData = { pcPlusOne, 1b0 };

                                        // Commit to dstack and rstack
                                        DSTACK.stackWrite = dstackWrite;
                                        RSTACK.stackWrite = rstackWrite;

                                        FSM = 3b001;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            case 2: {
                // ALU + MEMORYREAD
                newStackTop = aluop(instruction).is_j1j1plus ? ALU1.newStackTop : ALU0.newStackTop;
                rstackWData = stackTop;

                // UPDATE newDSP newRSP
                newDSP = DELTADSP.newSP;
                newRSP = DELTARSP.newSP;

                // Update PC for next instruction, return from call or next instruction
                newPC = ( aluop(instruction).is_r2pc ) ? {1b0, rStackTop[1,15] } : pcPlusOne;

                // n2memt mem[t] = n
                switch( is_n2memt ) {
                    case 1: { ( address, writedata, writememory ) = store( stackTop, stackNext, memorybusy ); }
                    default: {}
                }

                // Commit to dstack and rstack
                DSTACK.stackWrite = dstackWrite;
                RSTACK.stackWrite = rstackWrite;

                FSM =  3b001;
            }
        }
    }
}

algorithm add(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint16  newStackTop
) <autorun> {
    newStackTop := stackTop + stackNext;
}
algorithm and(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint16  newStackTop
) <autorun> {
    newStackTop := stackTop & stackNext;
}
algorithm or(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint16  newStackTop
) <autorun> {
    newStackTop := stackTop | stackNext;
}
algorithm xor(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint16  newStackTop
) <autorun> {
    newStackTop := stackTop ^ stackNext;
}
algorithm inv(
    input   uint16  stackTop,
    output  uint16  newStackTop
) <autorun> {
    newStackTop := ~stackTop;
}
algorithm dec(
    input   uint16  stackTop,
    output  uint16  newStackTop
) <autorun> {
    newStackTop := stackTop - 1;
}
algorithm lshift(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint16  newStackTop
) <autorun> {
    newStackTop := stackNext << nibbles(stackTop).nibble0;
}
algorithm rshift(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint16  newStackTop
) <autorun> {
    newStackTop := __signed(stackNext) >>> nibbles(stackTop).nibble0;
}
algorithm compare(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint1   equal,
    output  uint1   lessu,
    output  uint1   less,
) <autorun> {
    equal := stackNext == stackTop;
    lessu := __unsigned(stackNext) < __unsigned(stackTop);
    less := __signed(stackNext) < __signed(stackTop);
}

algorithm alu0(
    input   uint16  instruction,
    input   uint16  stackTop,
    input   uint16  stackNext,
    input   uint16  rStackTop,
    input   uint8   dsp,
    input   uint8   rsp,
    input   uint16  memoryRead,
    output  uint16  newStackTop
) <autorun> {
    add ADD( stackTop <: stackTop, stackNext <: stackNext );
    and AND( stackTop <: stackTop, stackNext <: stackNext );
    or OR( stackTop <: stackTop, stackNext <: stackNext );
    xor XOR( stackTop <: stackTop, stackNext <: stackNext );
    inv INV( stackTop <: stackTop );
    dec DEC( stackTop <: stackTop );
    lshift LSHIFT( stackTop <: stackTop, stackNext <: stackNext );
    rshift RSHIFT( stackTop <: stackTop, stackNext <: stackNext );
    compare COMPARE( stackTop <: stackTop, stackNext <: stackNext );

    while(1) {
        switch( aluop(instruction).operation ) {
            case 4b0000: {newStackTop = stackTop;}
            case 4b0001: {newStackTop = stackNext;}
            case 4b0010: {newStackTop = ADD.newStackTop;}
            case 4b0011: {newStackTop = AND.newStackTop;}
            case 4b0100: {newStackTop = OR.newStackTop;}
            case 4b0101: {newStackTop = XOR.newStackTop;}
            case 4b0110: {newStackTop = INV.newStackTop;}
            case 4b0111: {newStackTop = {16{COMPARE.equal}};}
            case 4b1000: {newStackTop = {16{COMPARE.less}};}
            case 4b1001: {newStackTop = RSHIFT.newStackTop;}
            case 4b1010: {newStackTop = DEC.newStackTop;}
            case 4b1011: {newStackTop = rStackTop;}
            case 4b1100: {newStackTop = memoryRead;}
            case 4b1101: {newStackTop = LSHIFT.newStackTop;}
            case 4b1110: {newStackTop = {rsp, dsp};}
            case 4b1111: {newStackTop = {16{COMPARE.lessu}};}
        }
    }
}

algorithm compare1(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint1   equal,
    output  uint1   less,
    output  uint1   equal0,
) <autorun> {
    equal := __signed( stackNext ) == __signed( stackTop );
    less := __signed( stackNext ) < __signed( stackTop );
    equal0 := __signed( stackTop ) == __signed( 0 );
}
algorithm sub(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint16  newStackTop
) <autorun> {
    newStackTop := stackNext - stackTop;
}
algorithm mul(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint16  newStackTop
) <autorun> {
    newStackTop := stackTop * stackNext;
}
algorithm neg(
    input   uint16  stackTop,
    output  uint16  newStackTop
) <autorun> {
    newStackTop := -stackTop;
}
algorithm inc(
    input   uint16  stackTop,
    output  uint16  newStackTop
) <autorun> {
    newStackTop := stackTop + 1;
}
algorithm alu1(
    input   uint16  instruction,
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint16  newStackTop
) <autorun> {
    uint1   equal = uninitialized;
    uint1   less = uninitialized;
    uint1   equal0 = uninitialized;
    compare1 COMPARE( stackTop <: stackTop, stackNext <: stackNext, equal :> equal, less :> less, equal0 :> equal0 );

    sub SUB( stackTop <: stackTop, stackNext <: stackNext );
    mul MUL( stackTop <: stackTop, stackNext <: stackNext );
    neg NEG( stackTop <: stackTop );
    inc INC( stackTop <: stackTop );

    while(1) {
        switch( aluop(instruction).operation ) {
            case 4b0000: { newStackTop = {16{ equal0 }}; }
            case 4b0001: { newStackTop = {16{ ~equal0 }}; }
            case 4b0010: { newStackTop = {16{ ~equal }}; }
            case 4b0011: { newStackTop = INC.newStackTop; }
            case 4b0100: { newStackTop = MUL.newStackTop; }
            case 4b0101: { newStackTop = { stackTop[0,15], 1b0 }; }
            case 4b0110: { newStackTop = NEG.newStackTop; }
            case 4b0111: { newStackTop = { stackTop[15,1], stackTop[1,15] }; }
            case 4b1000: { newStackTop = SUB.newStackTop;}
            case 4b1001: { newStackTop = {16{ stackTop[15,1] }}; }
            case 4b1010: { newStackTop = {16{ ~stackTop[15,1] }}; }
            case 4b1011: { newStackTop = {16{ ~less & ~equal }}; }
            case 4b1100: { newStackTop = {16{ ~less }}; }
            case 4b1101: { newStackTop = stackTop[15,1] ? -stackTop : stackTop; }
            case 4b1110: { newStackTop = ~less ? stackNext : stackTop; }
            case 4b1111: { newStackTop = less ? stackNext : stackTop; }
        }
    }
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
) <autorun> {
    uint2   is_callbranchalu <: callbranch(instruction).is_callbranchalu;

    newStackTop := is_callbranchalu[0,1] ? stackNext : stackTop;
    newDSP := dsp - is_callbranchalu[0,1];
    newRSP := rsp + is_callbranchalu[1,1];
    newPC := is_callbranchalu[0,1] ? ( stackTop == 0 ) ? callbranch(instruction).address : pcPlusOne : callbranch(instruction).address;
}

algorithm decode(
    input   uint16  instruction,
    output  uint1   is_alu,
    output  uint1   is_n2memt,
    output  uint1   dstackWrite,
    output  uint1   rstackWrite,
    output  uint8   ddelta,
    output  uint8   rdelta
) <autorun> {
    uint1   is_lit <: literal(instruction).is_literal;
    uint1   is_call <: ( instruction(instruction).is_litcallbranchalu == 3b010 );

    is_alu := ( instruction(instruction).is_litcallbranchalu == 3b011 );
    is_n2memt := is_alu && aluop(instruction).is_n2memt;
    dstackWrite := ( is_lit | (is_alu & aluop(instruction).is_t2n) );
    rstackWrite := ( is_call | (is_alu & aluop(instruction).is_t2r) );
    ddelta := { {7{aluop(instruction).ddelta1}}, aluop(instruction).ddelta0 };
    rdelta := { {7{aluop(instruction).rdelta1}}, aluop(instruction).rdelta0 };
}

algorithm stack(
    input   uint16  stackWData,
    input   uint1   stackWrite,
    input   uint8   sp,
    input   uint8   newSP,
    output  uint16  stackTop
) <autorun> {
    simple_dualport_bram uint16 stack[256] = uninitialized; // bram (code from @sylefeb)
    stack.addr0 := sp;
    stack.wenable1 := 1;
    stackTop := stack.rdata0;

    while(1) {
        switch( stackWrite ) {
            case 1: { stack.addr1 = newSP; stack.wdata1 = stackWData; }
            default: {}
        }
    }
}

algorithm deltasp(
    input   uint8   sp,
    input   uint8   delta,
    output  uint8   newSP
) <autorun> {
    newSP := sp + delta;
}

algorithm cpucache(
    input   uint13  pc,
    output  uint1   incache,
    output  uint16  instruction,
    input   uint1   update,
    input   uint16  newinstruction
) <autorun> {
    uint14  pccache[16] = uninitialised;
    uint16  inscache[16] = uninitialised;
    uint4   cachepointer = 0;

    incache := ( {1b1, pc} == pccache[0] ) |
                ( {1b1, pc} == pccache[1] ) |
                ( {1b1, pc} == pccache[2] ) |
                ( {1b1, pc} == pccache[3] ) |
                ( {1b1, pc} == pccache[4] ) |
                ( {1b1, pc} == pccache[5] ) |
                ( {1b1, pc} == pccache[6] ) |
                ( {1b1, pc} == pccache[7] ) |
                ( {1b1, pc} == pccache[8] ) |
                ( {1b1, pc} == pccache[9] ) |
                ( {1b1, pc} == pccache[10] ) |
                ( {1b1, pc} == pccache[11] ) |
                ( {1b1, pc} == pccache[12] ) |
                ( {1b1, pc} == pccache[13] ) |
                ( {1b1, pc} == pccache[14] ) |
                ( {1b1, pc} == pccache[15] );

    instruction := ( {1b1, pc} == pccache[0] ) ? inscache[0] :
                    ( {1b1, pc} == pccache[1] ) ? inscache[1] :
                    ( {1b1, pc} == pccache[2] ) ? inscache[2] :
                    ( {1b1, pc} == pccache[3] ) ? inscache[3] :
                    ( {1b1, pc} == pccache[4] ) ? inscache[4] :
                    ( {1b1, pc} == pccache[5] ) ? inscache[5] :
                    ( {1b1, pc} == pccache[6] ) ? inscache[6] :
                    ( {1b1, pc} == pccache[7] ) ? inscache[7] :
                    ( {1b1, pc} == pccache[8] ) ? inscache[8] :
                    ( {1b1, pc} == pccache[9] ) ? inscache[9] :
                    ( {1b1, pc} == pccache[10] ) ? inscache[10] :
                    ( {1b1, pc} == pccache[11] ) ? inscache[11] :
                    ( {1b1, pc} == pccache[12] ) ? inscache[12] :
                    ( {1b1, pc} == pccache[13] ) ? inscache[13] :
                    ( {1b1, pc} == pccache[14] ) ? inscache[14] :
                    ( {1b1, pc} == pccache[15] ) ? inscache[15] : 0;

    while(1) {
        __display("  pc = %x incache = %b",pc,incache);
        switch( update ) {
            case 1: {
                pccache[ cachepointer ] = { 1b1, pc };
                inscache[ cachepointer ] = newinstruction;
                cachepointer = cachepointer + 1;
            }
            default: {}
        }
    }
}
