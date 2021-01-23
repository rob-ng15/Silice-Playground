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
// CIRCUITRY FOR PUSHING LITERAL VALUE TO THE STACK
circuitry j1eforthliteral(
    input   immediate,
    input   pcPlusOne,
    input   dsp,
    input   rsp,

    output  newStackTop,
    output  newPC,
    output  newDSP,
    output  newRSP
) {
    newStackTop = immediate;
    newPC = pcPlusOne;
    newDSP = dsp + 1;
    newRSP = rsp;
}

// CIRCUITRY FOR HANDLING CALL BRANCH 0BRANCH INSTRUCTIONS
circuitry j1eforthcallbranch(
    input   is_callbranchalu,
    input   stackTop,
    input   stackNext,
    input   callBranchAddress,
    input   pcPlusOne,
    input   dsp,
    input   rsp,

    output  newStackTop,
    output  newPC,
    output  newDSP,
    output  newRSP
) {
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
            newPC = ( stackTop == 0 ) ? callBranchAddress : pcPlusOne;
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
    }
}

// BARREL SHIFTERS
circuitry SLL(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    switch( shiftcount[0,3] ) {
        case 0: { result = sourceReg1; }
        $$for i = 1, 15 do
            $$ remain = 16 - i
            case $i$: { result = { sourceReg1[ 0, $remain$ ], {$i${ 1b0 }} }; }
        $$end
    }
}
circuitry SRL(
    input   sourceReg1,
    input   shiftcount,
    output  result
) {
    switch( shiftcount[0,3] ) {
        case 0: { result = sourceReg1; }
        $$for i = 1, 15 do
            $$ remain = 16 - i
            case $i$: { result = { {$i${ 1b0 }}, sourceReg1[ $i$, $remain$ ] }; }
        $$end
    }
}

// J1 / J1+ CPU ALU OPERATIONS
circuitry j1eforthALU(
    input   instruction,
    input   dsp,
    input   rsp,
    input   stackTop,
    input   stackNext,
    input   rStackTop,
    input   RAMmemoryRead,

    output  newStackTop
) {
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
        case 4b1001: {( newStackTop ) = SRL( stackNext, stackTop );}
        case 4b1010: {newStackTop = stackTop - 1;}
        case 4b1011: {newStackTop = rStackTop;}
        case 4b1100: {newStackTop = RAMmemoryRead;}
        case 4b1101: {( newStackTop ) = SLL( stackNext, stackTop );}
        case 4b1110: {newStackTop = {rsp, dsp};}
        case 4b1111: {newStackTop = {16{(__unsigned(stackNext) < __unsigned(stackTop))}};}
    }
}

circuitry j1eforthplusALU(
    input   instruction,
    input   stackTop,
    input   stackNext,
    output  newStackTop
) {
    switch( aluop(instruction).operation ) {
        case 4b0000: {newStackTop = {16{(stackTop == 0)}};}
        case 4b0001: {newStackTop = ~{16{(stackTop == 0)}};}
        case 4b0010: {newStackTop = ~{16{(stackNext == stackTop)}};}
        case 4b0011: {newStackTop = stackTop + 1;}
        case 4b0100: {newStackTop = { stackTop[0,15], 1b0 };}
        case 4b0101: {newStackTop = { 1b0, stackTop[1,15]};}
        case 4b0110: {newStackTop = {16{(__signed(stackNext) > __signed(stackTop))}};}
        case 4b0111: {newStackTop = {16{(__unsigned(stackNext) > __unsigned(stackTop))}};}
        case 4b1000: {newStackTop = {16{(__signed(stackTop) < __signed(0))}};}
        case 4b1001: {newStackTop = {16{(__signed(stackTop) > __signed(0))}};}
        case 4b1010: {newStackTop = ( __signed(stackTop) < __signed(0) ) ?  -stackTop : stackTop;}
        case 4b1011: {newStackTop = ( __signed(stackNext) > __signed(stackTop) ) ? stackNext : stackTop;}
        case 4b1100: {newStackTop = ( __signed(stackNext) < __signed(stackTop) ) ? stackNext : stackTop;}
        case 4b1101: {newStackTop = -stackTop;}
        case 4b1110: {newStackTop = stackNext - stackTop;}
        case 4b1111: {newStackTop = {16{(__signed(stackNext) >= __signed(stackTop))}};}
    }
}

// CIRCUITRY FOR WRITING TO THE STACKS
circuitry commitDSTACK(
    inout   dstack,
    input   dstackWrite,
    input   newDSP,
    input   stackTop
) {
    if( dstackWrite ) {
        dstack.addr1 = newDSP;
        dstack.wdata1 = stackTop;
    }
}

circuitry commitRSTACK(
    inout   rstack,
    input   rstackWrite,
    input   newRSP,
    input   rstackWData
) {
    if( rstackWrite ) {
        rstack.addr1 = newRSP;
        rstack.wdata1 = rstackWData;
    }
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
    // instruction being executed, plus decoding, including 5bit deltas for dsp and rsp expanded from 2bit encoded in the alu instruction
    uint16  instruction = uninitialized;
    uint16  immediate := ( literal(instruction).literalvalue );
    uint1   is_alu := ( instruction(instruction).is_litcallbranchalu == 3b011 );
    uint1   is_call := ( instruction(instruction).is_litcallbranchalu == 3b010 );
    uint1   is_lit := literal(instruction).is_literal;
    uint1   is_n2memt := is_alu && aluop(instruction).is_n2memt;
    uint2   is_callbranchalu := callbranch(instruction).is_callbranchalu;
    uint1   dstackWrite := ( is_lit | (is_alu & aluop(instruction).is_t2n) );
    uint1   rstackWrite := ( is_call | (is_alu & aluop(instruction).is_t2r) );
    uint8   ddelta := { {7{aluop(instruction).ddelta1}}, aluop(instruction).ddelta0 };
    uint8   rdelta := { {7{aluop(instruction).rdelta1}}, aluop(instruction).rdelta0 };

    // program counter
    uint13  pc = 0;
    uint13  pcPlusOne := pc + 1;
    uint13  newPC = uninitialized;
    uint13  callBranchAddress := callbranch(instruction).address;

    // dstack 257x16bit (as 3256 array + stackTop) and pointer, next pointer, write line, delta
    simple_dualport_bram uint16 dstack[256] = uninitialized; // bram (code from @sylefeb)
    uint16  stackTop = 0;
    uint8   dsp = 0;
    uint8   newDSP = 0;
    uint16  newStackTop = uninitialized;

    // rstack 256x16bit and pointer, next pointer, write line
    simple_dualport_bram uint16 rstack[256] = uninitialized; // bram (code from @sylefeb)
    uint8   rsp = 0;
    uint8   newRSP = 0;
    uint16  rstackWData = uninitialized;

    uint16  stackNext = uninitialized;
    uint16  rStackTop = uninitialized;
    uint16  memoryInput = uninitialized;

    // 16bit ROM with included compiled j1eForth from https://github.com/samawati/j1eforth
    brom uint16 rom[] = {
        $include('j1eforthROM.inc')
    };

    // INIT to determine if copying rom to ram or executing
    // INIT 0 SPRAM, INIT 1 ROM to SPRAM, INIT 2 J1 CPU
    uint2 INIT = 0;

    // Address for 0 to SPRAM, copying ROM
    uint16 copyaddress = 0;

    // UART input FIFO (32 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartInBuffer[512] = uninitialized;
    uint9 uartInBufferNext = 0;
    uint9 uartInBufferTop = 0;

    // UART output FIFO (32 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartOutBuffer[512] = uninitialized;
    uint9 uartOutBufferNext = 0;
    uint9 uartOutBufferTop = 0;
    uint9 newuartOutBufferTop = 0;

    // bram for dstack and rstack write enable, maintained low, pulsed high (code from @sylefeb)
    // Setup addresses for the dstack and rstack
    // Read via port 0, write via port 1
    dstack.addr0 := dsp;
    dstack.wenable1 := 1;
    rstack.addr0 := rsp;
    rstack.wenable1 := 1;

    // dual port bram for dtsack and strack
    uartInBuffer.wenable1  := 1;  // always write on port 1
    uartInBuffer.addr0     := uartInBufferNext; // FIFO reads on next
    uartInBuffer.addr1     := uartInBufferTop;  // FIFO writes on top

    uartOutBuffer.wenable1 := 1; // always write on port 1
    uartOutBuffer.addr0    := uartOutBufferNext; // FIFO reads on next
    uartOutBuffer.addr1    := uartOutBufferTop;  // FIFO writes on top

    // UART input and output buffering
    uartInBuffer.wdata1  := uart_out_data;
    uartInBufferTop      := ( uart_out_valid ) ? uartInBufferTop + 1 : uartInBufferTop;
    uart_out_ready := uart_out_valid ? 1 : uart_out_ready;
    //always {
    //    // READ from UART if character available and store
    //    if( uart_out_valid ) {
    //        // writes at uartInBufferTop (code from @sylefeb)
    //        uartInBuffer.wdata1  = uart_out_data;
    //        uart_out_ready       = 1;
    //        uartInBufferTop      = uartInBufferTop + 1;
    //    }
    //}

    // INIT is 0 ZERO SPRAM
    while( INIT == 0 ) {
        copyaddress = 0;
        ++:
        while( copyaddress < 32768 ) {
            sram_address = copyaddress;
            sram_data_write = 0;
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
        ++:
        while( copyaddress < 4096 ) {
                rom.addr = copyaddress;
                ++:
                sram_address = copyaddress;
                sram_data_write = rom.rdata;
                sram_readwrite = 1;
                ++:
                copyaddress = copyaddress + 1;
                sram_readwrite = 0;
        }
        INIT = 3;
    }

    // INIT is 3 EXECUTE J1 CPU
    while( INIT == 3 ) {
        // WRITE to UART if characters in buffer and UART is ready
        if( ~(uartOutBufferNext == uartOutBufferTop) & ~( uart_in_valid ) ) {
            // reads at uartOutBufferNext (code from @sylefeb)
            uart_in_data      = uartOutBuffer.rdata0;
            uart_in_valid     = 1;
            uartOutBufferNext = uartOutBufferNext + 1;
        }
        uartOutBufferTop = newuartOutBufferTop;

               // read dtsack and rstack brams (code from @sylefeb)
                stackNext = dstack.rdata0;
                rStackTop = rstack.rdata0;

                // start READ memoryInput = [stackTop] result ready in 2 cycles
                sram_address = stackTop >> 1;
                sram_readwrite = 0;
                ++:
                ++:
                // wait then read the data from SPRAM
                memoryInput = sram_data_read;
                ++:
                // start READ instruction = [pc] result ready in 2 cycles
                sram_address = pc;
                sram_readwrite = 0;
                ++:
                ++:
                ++:
                // wait then read the instruction from SPRAM
                instruction = sram_data_read;
                ++:

                // J1 CPU Instruction Execute
                if( is_lit ) {
                    // LITERAL Push value onto stack
                    ( newStackTop, newPC, newDSP, newRSP ) = j1eforthliteral( immediate, pcPlusOne, dsp, rsp );
                } else {
                    switch( is_callbranchalu ) { // BRANCH 0BRANCH CALL ALU
                        default: {
                            // CALL BRANCH 0BRANCH INSTRUCTIONS
                            ( newStackTop, newPC, newDSP, newRSP ) = j1eforthcallbranch( is_callbranchalu, stackTop, stackNext, callBranchAddress, pcPlusOne, dsp, rsp );
                            rstackWData = pcPlusOne << 1;
                        }
                        case 2b11: {
                            // ALU
                            switch( aluop(instruction).is_j1j1plus ) {
                                case 1b0: {
                                    if( ( aluop(instruction).operation == 4b1100 ) && stackTop[15,1] ) {
                                        switch( stackTop ) {
                                            case 16hf000: { newStackTop = { 8b0, uartInBuffer.rdata0 }; uartInBufferNext = uartInBufferNext + 1; }
                                            case 16hf001: { newStackTop = { 14b0, ( uartOutBufferTop + 1 == uartOutBufferNext ), (uartInBufferNext != uartInBufferTop) }; }
                                            case 16hf002: { newStackTop = rgbLED; }
                                            case 16hf003: { newStackTop = { 12b0, buttons }; }
                                            case 16hf004: { newStackTop = timer1hz; }
                                            default: {newStackTop = 0;}
                                        }
                                    } else {
                                        ( newStackTop ) = j1eforthALU( instruction, dsp, rsp, stackTop, stackNext, rStackTop, memoryInput );
                                    }
                                }
                                case 1b1: {
                                    ( newStackTop ) = j1eforthplusALU( instruction, stackTop, stackNext );
                                }
                            } // ALU Operation

                            // UPDATE newDSP newRSP
                            newDSP = dsp + ddelta;
                            newRSP = rsp + rdelta;
                            rstackWData = stackTop;

                            // Update PC for next instruction, return from call or next instruction
                            newPC = ( aluop(instruction).is_r2pc ) ? rStackTop >> 1 : pcPlusOne;

                            // n2memt mem[t] = n
                            if( is_n2memt ) {
                                switch( stackTop ) {
                                    default: {
                                        // WRITE to SPRAM
                                        sram_address = stackTop >> 1;
                                        sram_data_write = stackNext;
                                        sram_readwrite = 1;
                                    }
                                    case 16hf000: {
                                        // OUTPUT to UART (dualport blockram code from @sylefeb)
                                        uartOutBuffer.wdata1 = bytes(stackNext).byte0;
                                        newuartOutBufferTop = uartOutBufferTop + 1;
                                    }
                                    case 16hf002: {
                                        // OUTPUT to rgbLED
                                        rgbLED = stackNext;
                                    }
                                }
                            }
                        } // ALU
                    }
                } // J1 CPU Instruction Execute

                ++:
                // Write to dstack and rstack
                // Commit to dstack and rstack
                ( dstack ) = commitDSTACK( dstack, dstackWrite, newDSP, stackTop );
                ( rstack ) = commitRSTACK( rstack, rstackWrite, newRSP, rstackWData );

                ++:
                // Update dsp, rsp, pc, stackTop
                dsp = newDSP;
                pc = newPC;
                stackTop = newStackTop;
                rsp = newRSP;

                ++:
                // reset sram_readwrite
                sram_readwrite = 0;

        // Reset UART
        if(uart_in_ready & uart_in_valid) {
            uart_in_valid = 0;
        }

    } // (INIT==3 execute J1 CPU)
}
