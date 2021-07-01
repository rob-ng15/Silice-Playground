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
    address = location;
    readmemory = 1;
    while( memorybusy ) {}
    memoryinput = readdata;
}
circuitry load( input location, input memorybusy, input readdata, output address, output readmemory, output memoryinput ) {
    address = location[15,1] ? location : { 1b0, location[1,15] };
    readmemory = 1;
    while( memorybusy ) {}
    memoryinput = readdata;
}
// CPU STORE TO MEMORY
circuitry store( input location, input value, input memorybusy, output address, output writedata, output writememory ) {
    address = location[15,1] ? location : { 1b0, location[1,15] };
    writedata = value[0,16];
    writememory = 1;
    while( memorybusy ) {}
}

algorithm J1CPU(
    output  uint32  address,
    output  uint16  writedata,
    output  uint1   writememory,
    input   uint16  readdata,
    output  uint1   readmemory,

    input   uint1   memorybusy
) <autorun> {
    // J1+ CPU
    uint5   FSM = 1;
    // instruction being executed, plus decoding, including 5bit deltas for dsp and rsp expanded from 2bit encoded in the alu instruction
    uint16  instruction = uninitialized;
    uint16  immediate = uninitialized;
    uint16  memoryRead = uninitialized;
    uint1   is_alu = uninitialized;
    uint1   is_call = uninitialized;
    uint1   is_lit = uninitialized;
    uint1   is_n2memt = uninitialized;
    uint2   is_callbranchalu = uninitialized;
    uint1   dstackWrite = uninitialized;
    uint1   rstackWrite = uninitialized;
    uint8   ddelta = uninitialized;
    uint8   rdelta = uninitialized;
    decode DECODE(
        instruction <: instruction,
        immediate :> immediate,
        is_alu :> is_alu,
        is_call :> is_call,
        is_lit :> is_lit,
        is_n2memt :> is_n2memt,
        is_callbranchalu :> is_callbranchalu,
        dstackWrite :> dstackWrite,
        rstackWrite :> rstackWrite,
        ddelta :> ddelta,
        rdelta :> rdelta
    );

    // program counter
    uint13  pc = 0;
    uint13  pcPlusOne = uninitialized;
    uint13  newPC = uninitialized;
    uint13  callBranchAddress := callbranch(instruction).address;

    // dstack 257x16bit (as 3256 array + stackTop) and pointer, next pointer, write line, delta
    simple_dualport_bram uint16 dstack[256] = uninitialized; // bram (code from @sylefeb)
    uint16  stackTop = 0;
    uint8   dsp = 0;
    uint8   newDSP = uninitialized;
    uint16  newStackTop = uninitialized;

    // rstack 256x16bit and pointer, next pointer, write line
    simple_dualport_bram uint16 rstack[256] = uninitialized; // bram (code from @sylefeb)
    uint8   rsp = 0;
    uint8   newRSP = uninitialized;
    uint16  rstackWData = uninitialized;

    uint16  stackNext := dstack.rdata0;
    uint16  rStackTop := rstack.rdata0;

    alu ALU(
        instruction <: instruction,
        memoryRead <: memoryRead,
        stackTop <: stackTop,
        stackNext <: stackNext,
        rStackTop <: rStackTop,
        dsp <: dsp,
        rsp <: rsp,
    );

    j1eforthcallbranch CALLBRANCH(
        is_callbranchalu <: is_callbranchalu,
        stackTop <: stackTop,
        stackNext <: stackNext,
        pc <: pc,
        callBranchAddress <: callBranchAddress,
        dsp <: dsp,
        rsp <: rsp,
    );

    // Setup addresses for the dstack and rstack
    // Read via port 0, write via port 1
    dstack.addr0 := dsp;
    dstack.wenable1 := 1;
    rstack.addr0 := rsp;
    rstack.wenable1 := 1;

    // MEMORY ACCESS FLAGS
    readmemory := 0;
    writememory := 0;

    // EXECUTE J1 CPU
    while( 1 ) {
        __display("FSM = %b pc = %x I = %x { %b %b %b %b }",FSM,pc,instruction,is_callbranchalu,is_lit,is_call,is_alu);
        __display("  dsp = %d stackTop = %x stackNext = %x rsp = %d rStackTop = %x",dsp,stackTop,stackNext,rsp,rStackTop);
        onehot( FSM ) {
            case 0: {
                // START FETCH INSTRUCTION
                ( address, readmemory, instruction ) = fetch( pc, memorybusy, readdata );
            }
            case 1: {
                // LOAD FROM MEMORY
                if( ~aluop(instruction).is_j1j1plus && ( callbranch(instruction).is_callbranchalu == 2b11 ) && ( aluop(instruction).operation == 4b1100 ) ) {
                    ( address, readmemory, memoryRead ) = load( stackTop, memorybusy, readdata );
                }
                pcPlusOne = pc + 1;
            }
            case 2: {
                switch( is_lit ) {
                    case 1: {
                        newStackTop = immediate;
                        newPC = pcPlusOne;
                        newDSP = dsp + 1;
                        newRSP = rsp;
                    }
                    case 0: {
                        switch( callbranch(instruction).is_callbranchalu ) { // BRANCH 0BRANCH CALL ALU
                            case 2b11: {
                                newStackTop = ALU.newStackTop;

                                // UPDATE newDSP newRSP
                                newDSP = dsp + ddelta;
                                newRSP = rsp + rdelta;
                                rstackWData = stackTop;

                                // Update PC for next instruction, return from call or next instruction
                                newPC = ( aluop(instruction).is_r2pc ) ? {1b0,rStackTop[1,15]} : pcPlusOne;

                                // n2memt mem[t] = n
                                if( is_n2memt ) {
                                    ( address, writedata, writememory ) = store( stackTop, stackNext, memorybusy );
                                }
                            } // ALU

                            default: {
                                newStackTop = CALLBRANCH.newStackTop;
                                newPC = CALLBRANCH.newPC;
                                newDSP = CALLBRANCH.newDSP;
                                newRSP = CALLBRANCH.newRSP;
                                rstackWData = pcPlusOne << 1;
                            }
                        }
                    }
                }
            }
            case 3: {
                // Commit to dstack and rstack
                switch( dstackWrite ) {
                    case 1: { dstack.addr1 = newDSP; dstack.wdata1 = stackTop; }
                    case 0: {}
                }
                switch( rstackWrite ) {
                    case 1: { rstack.addr1 = newRSP; rstack.wdata1 = rstackWData; }
                    case 0: {}
                }
            }
            case 4: {
                // Update dsp, rsp, pc, stackTop
                dsp = newDSP;
                pc = newPC;
                stackTop = newStackTop;
                rsp = newRSP;
            }
        }
        FSM = { FSM[0,4], FSM[4,1] };
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
) <autorun> {
    while(1) {
        switch( aluop(instruction).is_j1j1plus ) {
            case 0: {
                switch( aluop(instruction).operation ) {
                    case 4b0000: {newStackTop = stackTop;}
                    case 4b0001: {newStackTop = stackNext;}
                    case 4b0010: {newStackTop = stackTop + stackNext;}
                    case 4b0011: {newStackTop = stackTop & stackNext;}
                    case 4b0100: {newStackTop = stackTop | stackNext;}
                    case 4b0101: {newStackTop = stackTop ^ stackNext;}
                    case 4b0110: {newStackTop = ~stackTop;}
                    case 4b0111: {newStackTop = {16{(stackNext == stackTop)}};}
                    case 4b1000: {newStackTop = {16{(__signed(stackNext) < __signed(stackTop))}};}
                    case 4b1001: {newStackTop = __signed(stackNext) >>> nibbles(stackTop).nibble0;}
                    case 4b1010: {newStackTop = stackTop - 1;}
                    case 4b1011: {newStackTop = rStackTop;}
                    case 4b1100: {newStackTop = memoryRead;}
                    case 4b1101: {newStackTop = stackNext << nibbles(stackTop).nibble0;}
                    case 4b1110: {newStackTop = {rsp, dsp};}
                    case 4b1111: {newStackTop = {16{(__unsigned(stackNext) < __unsigned(stackTop))}};}
                }
            }
            case 1: {
                switch( aluop(instruction).operation ) {
                    case 4b0000: {newStackTop = {16{(stackTop == 0)}};}
                    case 4b0001: {newStackTop = {16{(stackTop != 0)}};}
                    case 4b0010: {newStackTop = {16{(stackNext != stackTop)}};}
                    case 4b0011: {newStackTop = stackTop + 1;}
                    case 4b0100: {newStackTop = stackNext * stackTop;}
                    case 4b0101: {newStackTop = {stackTop[0,15], 1b0 };}
                    case 4b0110: {newStackTop = -stackTop;}
                    case 4b0111: {newStackTop = { stackTop[15,1], stackTop[1,15]}; }
                    case 4b1000: {newStackTop = stackNext - stackTop;}
                    case 4b1001: {newStackTop = {16{(__signed(stackTop) < __signed(0))}};}
                    case 4b1010: {newStackTop = {16{(__signed(stackTop) > __signed(0))}};}
                    case 4b1011: {newStackTop = {16{(__signed(stackNext) > __signed(stackTop))}};}
                    case 4b1100: {newStackTop = {16{(__signed(stackNext) >= __signed(stackTop))}};}
                    case 4b1101: {newStackTop = ( __signed(stackTop) < __signed(0) ) ?  -stackTop : stackTop;}
                    case 4b1110: {newStackTop = ( __signed(stackNext) > __signed(stackTop) ) ? stackNext : stackTop;}
                    case 4b1111: {newStackTop = ( __signed(stackNext) < __signed(stackTop) ) ? stackNext : stackTop;}
                }
            }
        }
    }
}

algorithm j1eforthcallbranch(
    input   uint2   is_callbranchalu,
    input   uint16  stackTop,
    input   uint16  stackNext,
    input   uint13  callBranchAddress,
    input   uint13  pc,
    input   uint8   dsp,
    input   uint8   rsp,

    output  uint16  newStackTop,
    output  uint13  newPC,
    output  uint8   newDSP,
    output  uint8   newRSP,
) <autorun> {
    while(1) {
        // ONLY TRIGGER IF CALL BRANCH 0BRANCH
        switch( is_callbranchalu ) {
            case 2b00: {
                // BRANCH
                newStackTop = stackTop;
                newPC = callBranchAddress;
                newDSP = dsp;
                newRSP = rsp;
            }
            case 2b01: {
                // 0BRANCH
                newStackTop = stackNext;
                newPC = ( stackTop == 0 ) ? callBranchAddress : pc + 1;
                newDSP = dsp - 1;
                newRSP = rsp;
            }
            case 2b10: {
                // CALL
                newStackTop = stackTop;
                newPC = callBranchAddress;
                newDSP = dsp;
                newRSP = rsp + 1;
            }
            default: {}
        }
    }
}

algorithm decode(
    input   uint16  instruction,
    output  uint16  immediate,
    output  uint1   is_alu,
    output  uint1   is_call,
    output  uint1   is_lit,
    output  uint1   is_n2memt,
    output  uint2   is_callbranchalu,
    output  uint1   dstackWrite,
    output  uint1   rstackWrite,
    output  uint8   ddelta,
    output  uint8   rdelta
) <autorun> {
    immediate := ( literal(instruction).literalvalue );
    is_alu := ( instruction(instruction).is_litcallbranchalu == 3b011 );
    is_call := ( instruction(instruction).is_litcallbranchalu == 3b010 );
    is_lit := literal(instruction).is_literal;
    is_n2memt := is_alu && aluop(instruction).is_n2memt;
    is_callbranchalu := callbranch(instruction).is_callbranchalu;
    dstackWrite := ( is_lit | (is_alu & aluop(instruction).is_t2n) );
    rstackWrite := ( is_call | (is_alu & aluop(instruction).is_t2r) );
    ddelta := { {7{aluop(instruction).ddelta1}}, aluop(instruction).ddelta0 };
    rdelta := { {7{aluop(instruction).rdelta1}}, aluop(instruction).rdelta0 };
}
