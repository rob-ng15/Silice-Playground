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
    uint1   is_call = uninitialized;
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
    uint13  pc = 0;
    uint13  pcPlusOne = uninitialized;
    uint13  newPC = 0;

    // dstack 257x16bit (as 3256 array + stackTop) and pointer, next pointer, write line, delta
    stack DSTACK( stackWData <: stackTop, sp <: dsp, newSP <: newDSP, stackTop :> stackNext, stackTop :> writedata );
    uint8   DELTADSPnewSP = uninitialized;
    deltasp DELTADSP( sp <: dsp, delta <: ddelta, newSP :> DELTADSPnewSP );
    uint16  stackTop = 0;
    uint16  stackNext = uninitialized;
    uint8   dsp = 0;
    uint8   newDSP = 0;
    uint16  newStackTop = 0;

    // rstack 256x16bit and pointer, next pointer, write line
    stack RSTACK( stackWData <: rstackWData, sp <: rsp, newSP <: newRSP, stackTop :> rStackTop );
    uint8   DELTARSPnewSP = uninitialized;
    deltasp DELTARSP( sp <: rsp, delta <: rdelta, newSP :> DELTARSPnewSP );
    uint16  rStackTop = uninitialized;
    uint8   rsp = 0;
    uint8   newRSP = 0;
    uint16  rstackWData = uninitialized;

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
                switch( is_memtr ) {
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
                                        newStackTop = ALUnewStackTop;
                                        rstackWData = stackTop;

                                        // UPDATE newDSP newRSP
                                        newDSP = DELTADSPnewSP;
                                        newRSP = DELTARSPnewSP;

                                        // Update PC for next instruction, return from call or next instruction
                                        newPC = ( aluop(instruction).is_r2pc ) ? {1b0, rStackTop[1,15] } : pcPlusOne;

                                        // n2memt mem[t] = n
                                        switch( is_n2memt ) {
                                            case 1: {
                                                ( address, writememory ) = store( stackTop, memorybusy );
                                            }
                                            default: {}
                                        }

                                        // Commit to dstack and rstack
                                        DSTACK.stackWrite = dstackWrite;
                                        RSTACK.stackWrite = rstackWrite;

                                        FSM =  3b001;
                                    }
                                    case 0: {
                                        // CALL BRANCH 0BRANCH
                                        newStackTop = CALLBRANCHnewStackTop;
                                        newPC = CALLBRANCHnewPC;
                                        newDSP = CALLBRANCHnewDSP;
                                        newRSP = CALLBRANCHnewRSP;
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
                newStackTop = ALUnewStackTop;
                rstackWData = stackTop;

                // UPDATE newDSP newRSP
                newDSP = DELTADSPnewSP;
                newRSP = DELTARSPnewSP;

                // Update PC for next instruction, return from call or next instruction
                newPC = ( aluop(instruction).is_r2pc ) ? {1b0, rStackTop[1,15] } : pcPlusOne;

                // n2memt mem[t] = n
                switch( is_n2memt ) {
                    case 1: {
                        ( address, writememory ) = store( stackTop, memorybusy );
                    }
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

algorithm compare(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint1   equal,
    output  uint1   lessu,
    output  uint1   less,
    output  uint1   equal0,
) <autorun> {
    equal := stackNext == stackTop;
    lessu := __unsigned(stackNext) < __unsigned(stackTop);
    less := __signed(stackNext) < __signed(stackTop);
    equal0 := __signed( stackTop ) == __signed( 0 );
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
) <autorun> {
    uint1   equal = uninitialized;
    uint1   less = uninitialized;
    uint1   lessu = uninitialized;
    uint1   equal0 = uninitialized;
    compare COMPARE( stackTop <: stackTop, stackNext <: stackNext, equal :> equal, less :> less, lessu :> lessu, equal0 :> equal0 );

    always {
        switch( { aluop(instruction).is_j1j1plus, aluop(instruction).operation } ) {
            case 5b00000: {newStackTop = stackTop;}
            case 5b00001: {newStackTop = stackNext;}
            case 5b00010: {newStackTop = stackTop + stackNext;}
            case 5b00011: {newStackTop = stackTop & stackNext;}
            case 5b00100: {newStackTop = stackTop | stackNext;}
            case 5b00101: {newStackTop = stackTop ^ stackNext;}
            case 5b00110: {newStackTop = ~stackTop;}
            case 5b00111: {newStackTop = {16{equal}};}
            case 5b01000: {newStackTop = {16{less}};}
            case 5b01001: {newStackTop = __signed(stackNext) >>> nibbles(stackTop).nibble0;}
            case 5b01010: {newStackTop = stackTop - 1;}
            case 5b01011: {newStackTop = rStackTop;}
            case 5b01100: {newStackTop = memoryRead;}
            case 5b01101: {newStackTop = stackNext << nibbles(stackTop).nibble0;}
            case 5b01110: {newStackTop = {rsp, dsp};}
            case 5b01111: {newStackTop = {16{lessu}};}
            case 5b10000: { newStackTop = {16{ equal0 }}; }
            case 5b10001: { newStackTop = {16{ ~equal0 }}; }
            case 5b10010: { newStackTop = {16{ ~equal }}; }
            case 5b10011: { newStackTop = stackTop + 1; }
            case 5b10100: { newStackTop = stackTop * stackNext; }
            case 5b10101: { newStackTop = { stackTop[0,15], 1b0 }; }
            case 5b10110: { newStackTop = -stackTop; }
            case 5b10111: { newStackTop = { stackTop[15,1], stackTop[1,15] }; }
            case 5b11000: { newStackTop = stackNext - stackTop;}
            case 5b11001: { newStackTop = {16{ stackTop[15,1] }}; }
            case 5b11010: { newStackTop = {16{ ~stackTop[15,1] }}; }
            case 5b11011: { newStackTop = {16{ ~less & ~equal }}; }
            case 5b11100: { newStackTop = {16{ ~less }}; }
            case 5b11101: { newStackTop = stackTop[15,1] ? -stackTop : stackTop; }
            case 5b11110: { newStackTop = ~less ? stackNext : stackTop; }
            case 5b11111: { newStackTop = less ? stackNext : stackTop; }
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
    output  uint1   is_memtr,
    output  uint1   dstackWrite,
    output  uint1   rstackWrite,
    output  uint8   ddelta,
    output  uint8   rdelta
) <autorun> {
    uint1   is_lit <: literal(instruction).is_literal;
    uint1   is_call <: ( instruction(instruction).is_litcallbranchalu == 3b010 );

    is_alu := ( instruction(instruction).is_litcallbranchalu == 3b011 );
    is_n2memt := is_alu & aluop(instruction).is_n2memt;
    is_memtr := { is_alu, aluop(instruction).operation, aluop(instruction).is_j1j1plus } == 6b111000;
    dstackWrite := ( is_lit | ( is_alu & aluop(instruction).is_t2n ) );
    rstackWrite := ( is_call | ( is_alu & aluop(instruction).is_t2r ) );
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
    simple_dualport_bram uint16 stack <input!> [256] = uninitialized; // bram (code from @sylefeb)
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
) <autorun> {
    newSP := sp + delta;
}
