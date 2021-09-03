// BITFIELDS to help with bit/field access
// Instruction is 3 bits 1xx = literal value, 000 = branch, 001 = 0branch, 010 = call, 011 = alu, followed by 13 bits of instruction specific data
bitfield instruction {
    uint3 is_litcallbranchalu,
    uint13 padding
}

// A literal instruction is 1 followed by a 15 bit UNSIGNED literal value
bitfield literal {
    uint1  is_literal,
    uint15 literalvalue
}

// A branch, 0branch or call instruction is 0 followed by 00 = branch, 01 = 0branch, 10 = call followed by 13bit target address
bitfield callbranch {
    uint1  is_literal,
    uint2  is_callbranchalu,
    uint13 address
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

// Simplify access to high/low byte
bitfield bytes {
    uint8   byte1,
    uint8   byte0
}

// Simplify access to 4bit nibbles (used to extract shift left/right amount)
bitfield nibbles {
    uint4   nibble3,
    uint4   nibble2,
    uint4   nibble1,
    uint4   nibble0
}

algorithm main(
    // RGB LED
    output  uint3   rgbLED,

    // USER buttons
   input   uint4   buttons,

    // SPRAM Interface
    output uint16   sram_address,
    output uint16   sram_data_write,
    input  uint16   sram_data_read,
    output uint1    sram_readwrite,

    // UART Interface
    output   uint8  uart_in_data,
    output   uint1  uart_in_valid,
    input    uint1  uart_in_ready,
    input    uint8  uart_out_data,
    input    uint1  uart_out_valid,
    output   uint1  uart_out_ready,

    // 1hz timer
    input   uint16 timer1hz
) {
    uint16  FSM = 1;

    // 16bit ROM with included compiled j1eForth from https://github.com/samawati/j1eforth
    brom uint16 rom <input!> [] = {
        $include('j1eforthROM.inc')
    };

    // INIT to determine if copying rom to ram or executing
    // INIT 0 SPRAM, INIT 1 ROM to SPRAM, INIT 2 J1 CPU
    uint2   INIT = 0;

    // Address for 0 to SPRAM, copying ROM
    uint16  copyaddress = uninitialized;

    // J1 CPU
    uint16  instruction = uninitialized;
    uint1   is_lit = uninitialized;
    uint1   is_alu = uninitialized;
    uint1   is_call = uninitialized;
    uint1   is_n2memt = uninitialized;
    uint1   is_memtr = uninitialized;
    uint2   is_callbranchalu = uninitialized;
    uint1   dstackWrite = uninitialized;
    uint1   rstackWrite = uninitialized;
    uint8   ddelta = uninitialized;
    uint8   rdelta = uninitialized;
    decode DECODE(
        instruction <: instruction,
        is_lit :> is_lit,
        is_call :> is_call,
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
    uint13  pcPlusOne = uninitialized;
    uint13  newPC = 0;

    // dstack 257x16bit (as 3256 array + stackTop) and pointer, next pointer, write line, delta
    stack DSTACK( stackWData <: stackTop, sp <: dsp, newSP <: newDSP, stackTop :> stackNext, stackWrite <: DSTACKstackWrite );
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
    uint16  memoryinput = uninitialized;
    alu ALU(
        instruction <: instruction,
        memoryRead <: memoryinput,
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

    // UART input FIFO (32 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartInBuffer <input!> [512] = uninitialized;
    uint9 uartInBufferNext = 0;
    uint9 uartInBufferTop = 0;

    // UART output FIFO (32 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartOutBuffer <input!> [512] = uninitialized;
    uint9 uartOutBufferNext = 0;
    uint9 uartOutBufferTop = 0;
    uint9 newuartOutBufferTop = 0;

    // STACK WRITE CONTROLLERS
    DSTACKstackWrite := 0; RSTACKstackWrite := 0;

    // UART input and output buffering
    uartInBuffer.wenable1  := 1;  // always write on port 1
    uartInBuffer.addr0     := uartInBufferNext; // FIFO reads on next
    uartInBuffer.addr1     := uartInBufferTop;  // FIFO writes on top
    uartOutBuffer.wenable1 := 1; // always write on port 1
    uartOutBuffer.addr0    := uartOutBufferNext; // FIFO reads on next
    uartOutBuffer.addr1    := uartOutBufferTop;  // FIFO writes on top
    uartInBuffer.wdata1  := uart_out_data;
    uartInBufferTop      := ( uart_out_valid ) ? uartInBufferTop + 1 : uartInBufferTop;
    uart_out_ready := uart_out_valid ? 1 : uart_out_ready;
    uart_in_valid := (uart_in_ready && uart_in_valid) ? 0 : uart_in_valid;

    sram_data_write := ( INIT == 0 ) ? 0 : ( INIT == 1 ) ? rom.rdata : stackNext;

    // INIT is 0 ZERO SPRAM
    while( INIT == 0 ) {
        copyaddress = 0;
        while( copyaddress < 32768 ) {
            sram_address = copyaddress;
            sram_readwrite = 1;
            ++:
            sram_readwrite = 0;
            copyaddress = copyaddress + 1;
        }
        INIT = 1;
    }

    // INIT is 1 COPY ROM TO SPRAM
    while( INIT == 1) {
        copyaddress = 0;
        while( copyaddress < 4096 ) {
            rom.addr = copyaddress;
            ++:
            sram_address = copyaddress;
            sram_readwrite = 1;
            ++:
            sram_readwrite = 0;
            copyaddress = copyaddress + 1;
            ++:
        }
        INIT = 3;
    }

    // INIT is 3 EXECUTE J1 CPU
    while( INIT == 3 ) {
        // WRITE to UART if characters in buffer and UART is ready
        if( ~(uartOutBufferNext == uartOutBufferTop) && ~( uart_in_valid ) ) {
            // reads at uartOutBufferNext (code from @sylefeb)
            uart_in_data      = uartOutBuffer.rdata0;
            uart_in_valid     = 1;
            uartOutBufferNext = uartOutBufferNext + 1;
        }

        // Update dsp, rsp, pc, stackTop
        dsp = newDSP;
        pc = newPC;
        stackTop = newStackTop;
        rsp = newRSP;
        pcPlusOne = pc + 1;

        // start READ instruction = [pc] result ready in 2 cycles
        sram_address = pc;
        sram_readwrite = 0;
        ++:
        ++:
        ++:
        // wait then read the instruction from SPRAM and DECODE
        instruction = sram_data_read;
        ++:

        // start READ memoryInput = [stackTop]
        if( is_memtr && ~stackTop[15,1] ) {
            sram_address = stackTop >> 1;
            sram_readwrite = 0;
            ++:
            ++:
            ++:
            // wait then read the data from SPRAM
            memoryinput = sram_data_read;
            ++:
        }
        // J1 CPU Instruction Execute
        if( is_lit ) {
            // LITERAL
            newStackTop = literal(instruction).literalvalue;
            newPC = pcPlusOne;
            newDSP = dsp + 1;

            // Commit to dstack and rstack
            DSTACKstackWrite = dstackWrite;
        } else {
            if( is_alu ) {
                if( ( { aluop(instruction).is_j1j1plus, aluop(instruction).operation } == 5b01100 ) && stackTop[15,1] ) {
                    switch( stackTop ) {
                        case 16hf000: { newStackTop = { 8b0, uartInBuffer.rdata0 }; uartInBufferNext = uartInBufferNext + 1; }
                        case 16hf001: { newStackTop = { 14b0, ( uartOutBufferTop + 1 == uartOutBufferNext ), (uartInBufferNext != uartInBufferTop) }; }
                        case 16hf002: { newStackTop = rgbLED; }
                        case 16hf003: { newStackTop = { 12b0, buttons }; }
                        case 16hf004: { newStackTop = timer1hz; }
                        default: {newStackTop = 0;}
                    }
                } else {
                    newStackTop = ALUnewStackTop;
                    rstackWData = stackTop;
                }

                // UPDATE newDSP newRSP
                newDSP = DELTADSPnewSP;
                newRSP = DELTARSPnewSP;

                // Update PC for next instruction, return from call or next instruction
                newPC = ( aluop(instruction).is_r2pc ) ? {1b0, rStackTop[1,15] } : pcPlusOne;

                // n2memt mem[t] = n
                if( is_n2memt ) {
                    switch( stackTop ) {
                        default: {
                            // WRITE to SPRAM
                            sram_address = stackTop >> 1;
                            sram_readwrite = 1;
                            ++:
                            sram_readwrite = 0;
                        }
                        case 16hf000: {
                            // OUTPUT to UART (dualport blockram code from @sylefeb)
                            uartOutBuffer.wdata1 = bytes(stackNext).byte0;
                            uartOutBufferTop = uartOutBufferTop + 1;
                        }
                        case 16hf002: {
                            // OUTPUT to rgbLED
                            rgbLED = stackNext;
                        }
                    }
                }

                // Commit to dstack and rstack
                DSTACKstackWrite = dstackWrite;
                RSTACKstackWrite = rstackWrite;
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
            }
        } // J1 CPU Instruction Execute
    } // (INIT==3 execute J1 CPU)}
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
            case 5b10100: { newStackTop = { stackTop[0,15], 1b0 }; }
            case 5b10101: { newStackTop = { stackTop[15,1], stackTop[1,15]}; }
            case 5b10110: { newStackTop = {16{~less & ~equal}}; }
            case 5b10111: { newStackTop = {16{~lessu & ~equal}}; }
            case 5b11000: { newStackTop = {16{stackTop[15,1]}}; }
            case 5b11001: { newStackTop = {16{~stackTop[15,1]}}; }
            case 5b11010: { newStackTop = stackTop[15,1] ?  -stackTop : stackTop; }
            case 5b11011: { newStackTop = ~less ? stackNext : stackTop; }
            case 5b11100: { newStackTop = less ? stackNext : stackTop; }
            case 5b11101: { newStackTop = -stackTop; }
            case 5b11110: { newStackTop = stackNext - stackTop; }
            case 5b11111: { newStackTop = {16{~less}}; }
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
    always {
        equal = stackNext == stackTop;
        lessu = __unsigned(stackNext) < __unsigned(stackTop);
        less = __signed(stackNext) < __signed(stackTop);
        equal0 = __signed( stackTop ) == __signed( 0 );
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
    uint2   is_callbranchalu <:: callbranch(instruction).is_callbranchalu;
    always {
        newStackTop = is_callbranchalu[0,1] ? stackNext : stackTop;
        newDSP = dsp - is_callbranchalu[0,1];
        newRSP = rsp + is_callbranchalu[1,1];
        newPC = is_callbranchalu[0,1] ? ( stackTop == 0 ) ? callbranch(instruction).address : pcPlusOne : callbranch(instruction).address;
    }
}

algorithm decode(
    input   uint16  instruction,
    output  uint1   is_lit,
    output  uint1   is_call,
    output  uint1   is_alu,
    output  uint1   is_n2memt,
    output  uint1   is_memtr,
    output  uint1   dstackWrite,
    output  uint1   rstackWrite,
    output  uint8   ddelta,
    output  uint8   rdelta
) <autorun> {
    always {
        is_lit = literal(instruction).is_literal;
        is_call = ( instruction(instruction).is_litcallbranchalu == 3b010 );
        is_alu = ( instruction(instruction).is_litcallbranchalu == 3b011 );
        is_n2memt = is_alu & aluop(instruction).is_n2memt;
        is_memtr = { is_alu, aluop(instruction).operation, aluop(instruction).is_j1j1plus } == 6b111000;
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
    always {
        newSP = sp + delta;
    }
}
