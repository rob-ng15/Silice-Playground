// BITFIELDS to help with bit/field access

// Instruction is 3 bits 1xx = literal value, 000 = branch, 001 = 0branch, 010 = call, 011 = alu, followed by 13 bits of instruction specific data
bitfield instruction {
    uint3 is_litcallbranchalu,
    uint13 pad
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
    output   uint1  uart_out_ready
) {
    // instruction being executed, plus decoding, including 5bit deltas for dsp and rsp expanded from 2bit encoded in the alu instruction
    uint16  instruction = uninitialized;
    uint16  immediate := ( literal(instruction).literalvalue );
    uint1   is_alu := ( instruction(instruction).is_litcallbranchalu == 3b011 );
    uint1   is_call := ( instruction(instruction).is_litcallbranchalu == 3b010 );
    uint1   is_lit := literal(instruction).is_literal;
    uint1   dstackWrite := ( is_lit | (is_alu & aluop(instruction).is_t2n) );
    uint1   rstackWrite := ( is_call | (is_alu & aluop(instruction).is_t2r) );
    uint5   ddelta := { aluop(instruction).ddelta1, aluop(instruction).ddelta1, aluop(instruction).ddelta1, aluop(instruction).ddelta1, aluop(instruction).ddelta0 };
    uint5   rdelta := { aluop(instruction).rdelta1, aluop(instruction).rdelta1, aluop(instruction).rdelta1, aluop(instruction).rdelta1, aluop(instruction).rdelta0 };
    
    // program counter
    uint13  pc = 0;
    uint13  pcPlusOne := pc + 1;
    uint13  newPC = uninitialized;

    // dstack 33x16bit (as 32 array + stackTop) and pointer, next pointer, write line, delta
    //uint16 dstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    bram uint16 dstack[32] = uninitialized; // bram (code from @sylefeb)
    uint16  stackTop = 0;
    uint5   dsp = 0;
    uint5   newDSP = uninitialized;
    uint16  newStackTop = uninitialized;

    // rstack 32x16bit and pointer, next pointer, write line
    //uint16 rstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    bram uint16 rstack[32] = uninitialized; // bram (code from @sylefeb)
    uint5   rsp = 0;
    uint5   newRSP = uninitialized;
    uint16  rstackWData = uninitialized;

    uint16  stackNext = uninitialized;
    uint16  rStackTop = uninitialized;
    uint16  memoryInput = uninitialized;

    // 16bit ROM with included compiled j1eForth from https://github.com/samawati/j1eforth
    bram uint16 rom[] = {
        $include('j1eforthROM.inc')
    };
    
    // CYCLE to control each stage
    // CYCLE allows 1 clock cycle for BRAM access and 3 clock cycles for SPRAM access
    // INIT to determine if copying rom to ram or executing
    // INIT 0 SPRAM, INIT 1 ROM to SPRAM, INIT 2 J1 CPU
    uint4 CYCLE = 0;
    uint2 INIT = 0;
    
    // Address for 0 to SPRAM, copying ROM, plus storage
    uint16 copyaddress = 0;
    uint16 bramREAD = 0;

    // UART input FIFO (32 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 uartInBuffer[32] = uninitialized;
    uint5 uartInBufferNext = 0;
    uint5 uartInBufferTop = 0;

    // UART output FIFO (32 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 uartOutBuffer[32] = uninitialized;
    uint5 uartOutBufferNext = 0;
    uint5 uartOutBufferTop = 0;
    uint5 newuartOutBufferTop = 0;
    
    // bram for dstack and rstack write enable, maintained low, pulsed high (code from @sylefeb)
    dstack.wenable         := 0;  
    rstack.wenable         := 0;

    // dual port bram for dtsack and strack
    uartInBuffer.wenable0  := 0;  // always read  on port 0
    uartInBuffer.wenable1  := 1;  // always write on port 1
    uartInBuffer.addr0     := uartInBufferNext; // FIFO reads on next
    uartInBuffer.addr1     := uartInBufferTop;  // FIFO writes on top
    
    uartOutBuffer.wenable0 := 0; // always read  on port 0
    uartOutBuffer.wenable1 := 1; // always write on port 1    
    uartOutBuffer.addr0    := uartOutBufferNext; // FIFO reads on next
    uartOutBuffer.addr1    := uartOutBufferTop;  // FIFO writes on top
    
    // INIT is 0 ZERO SPRAM
    while( INIT==0 ) {
        switch(CYCLE) {
            case 0: {
                // Setup WRITE to SPRAM
                sram_address = copyaddress;
                sram_data_write = 0;
                sram_readwrite = 1;
            }
            case 3: {
                sram_readwrite = 0;
                copyaddress = copyaddress + 1;
            }
            case 15: {
                if(copyaddress == 16384) {
                    INIT = 1;
                    copyaddress = 0;
                }
            }
        }
        CYCLE = CYCLE + 1;
    }
    
    // INIT is 1 COPY ROM TO SPRAM
    while( INIT==1) {
        switch(CYCLE) {
            case 0: {
                // Setup READ from ROM
                rom.addr = copyaddress;
                rom.wenable = 0;
            }
            case 1: {
                // READ from ROM
                bramREAD = rom.rdata;
            }
            case 2: {
                // WRITE to SPRAM
                sram_address = copyaddress;
                sram_data_write = bramREAD;
                sram_readwrite = 1;
            }
            case 14: {
                copyaddress = copyaddress + 1;
                sram_readwrite = 0;
            }
            case 15: {
                if(copyaddress == 3336) {
                    INIT = 3;
                    copyaddress = 0;
                }
            }
            default: {
            }
        }
        CYCLE = CYCLE + 1;
    }

    // INIT is 3 EXECUTE J1 CPU
    while( INIT==3 ) {
        // READ from UART if character available and store
        if(uart_out_valid) {
            // writes at uartInBufferTop (code from @sylefeb)
            uartInBuffer.wdata1  = uart_out_data;            
            uart_out_ready       = 1;
            uartInBufferTop      = uartInBufferTop + 1; 
        }

        // WRITE to UART if characters in buffer and UART is ready
        if( ~(uartOutBufferNext == uartOutBufferTop) & ~( uart_in_valid ) ) {
            // reads at uartOutBufferNext (code from @sylefeb)
            uart_in_data      = uartOutBuffer.rdata0; 
            uart_in_valid     = 1;
            uartOutBufferNext = uartOutBufferNext + 1;
        }
        uartOutBufferTop = newuartOutBufferTop;
        
        switch(CYCLE) {
            // Read stackNext, rStackTop
            case 0: {
               // read dtsack and rstack brams (code from @sylefeb)
                stackNext = dstack.rdata;
                rStackTop = rstack.rdata;
            
                // start READ memoryInput = [stackTop] result ready in 2 cycles
                sram_address = stackTop >> 1;
                sram_readwrite = 0;
            }
            case 4: {
                // wait then read the data from SPRAM
                memoryInput = sram_data_read;
            }
            
            case 5: {
                // start READ instruction = [pc] result ready in 2 cycles
                sram_address = pc;
                sram_readwrite = 0;
            }

            case 9: {
                // wait then read the instruction from SPRAM
                instruction = sram_data_read;
            }

            // J1 CPU Instruction Execute
            case 10: {
                // +---------------------------------------------------------------+
                // | F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
                // +---------------------------------------------------------------+
                // | 1 |                    LITERAL VALUE                          |
                // +---------------------------------------------------------------+
                // | 0 | 0 | 0 |            BRANCH TARGET ADDRESS                  |
                // +---------------------------------------------------------------+
                // | 0 | 0 | 1 |            CONDITIONAL BRANCH TARGET ADDRESS      |
                // +---------------------------------------------------------------+
                // | 0 | 1 | 0 |            CALL TARGET ADDRESS                    |
                // +---------------------------------------------------------------+
                // | 0 | 1 | 1 |R2P| ALU OPERATION |T2N|T2R|N2A|J1P| RSTACK| DSTACK|
                // +---------------------------------------------------------------+
                // | F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
                // +---------------------------------------------------------------+
                // 
                // T   : Top of data stack
                // N   : Next on data stack
                // PC  : Program Counter
                // 
                // LITERAL VALUES : push a value onto the data stack
                // CONDITIONAL    : BRANCHS pop and test the T
                // CALLS          : PC+1 onto the return stack
                // 
                // T2N : Move T to N
                // T2R : Move T to top of return stack
                // N2A : STORE T to memory location addressed by N
                // R2P : Move top of return stack to PC
                // 
                // RSTACK and DSTACK are signed values (twos compliment) that are
                // the stack delta (the amount to increment or decrement the stack
                // by for their respective stacks: return and data)

                if(is_lit) {
                    // LITERAL Push value onto stack
                    newStackTop = immediate;
                    newPC = pcPlusOne;
                    newDSP = dsp + 1;
                    newRSP = rsp;
                } else {
                    switch( callbranch(instruction).is_callbranchalu ) { // BRANCH 0BRANCH CALL ALU
                        case 2b00: {
                            // BRANCH
                            newStackTop = stackTop;
                            newPC = callbranch(instruction).address;
                            newDSP = dsp;
                            newRSP = rsp;
                        }
                        case 2b01: {
                            // 0BRANCH
                            newStackTop = stackNext;
                            if( stackTop == 0 ) {
                                newPC = callbranch(instruction).address;
                            } else {
                                newPC = pcPlusOne;
                            }
                            newDSP = dsp - 1;
                            newRSP = rsp;
                        }
                        case 2b10: {
                            // CALL
                            newStackTop = stackTop;
                            newPC = callbranch(instruction).address;
                            newDSP = dsp;
                            newRSP = rsp + 1;
                            rstackWData = pcPlusOne << 1;
                        }
                        case 2b11: {
                            // ALU
                            switch( aluop(instruction).is_j1j1plus ) {
                                case 1b0: {
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
                                        case 4b1001: {newStackTop = stackNext >> nibbles(stackTop).nibble0;}
                                        case 4b1010: {newStackTop = stackTop - 1;}
                                        case 4b1011: {newStackTop = rStackTop;}
                                        case 4b1100: {
                                        // UART or memoryInput
                                            switch( stackTop ) {
                                                case 16hf000: {
                                                    // INPUT from UART reads at uartInBufferNext (code from @sylefeb)
                                                    newStackTop = { 8b0, uartInBuffer.rdata0 };
                                                    uartInBufferNext = uartInBufferNext + 1;
                                                } 
                                                case 16hf001: {
                                                    //newStackTop = {14b0, ( uartOutBufferTop + 1 == uartOutBufferNext ), ~(uartInBufferNext == uartInBufferTop)};
                                                    newStackTop = {14b0, uart_in_valid, ~(uartInBufferNext == uartInBufferTop)};
                                                }
                                                case 16hf003: {
                                                    // user buttons
                                                    newStackTop = {12b0, buttons};
                                                }
                                                default: {newStackTop = memoryInput;}
                                            }
                                        }
                                        case 4b1101: {newStackTop = stackNext << nibbles(stackTop).nibble0;}
                                        case 4b1110: {newStackTop = {rsp, 3b000, dsp};}
                                        case 4b1111: {newStackTop = {16{(__unsigned(stackNext) < __unsigned(stackTop))}};}
                                    }
                                }
                                
                                case 1b1: {
                                    switch( aluop(instruction).operation ) {
                                        case 4b0000: {newStackTop = {16{(stackTop == 0)}};}
                                        case 4b0001: {newStackTop = ~{16{(stackTop == 0)}};}
                                        case 4b0010: {newStackTop = ~{16{(stackNext == stackTop)}};}
                                        case 4b0011: {newStackTop = stackTop + 1;}
                                    }
                                }
                            } // ALU Operation
                            
                            // UPDATE newDSP newRSP
                            newDSP = dsp + ddelta;
                            newRSP = rsp + rdelta;
                            rstackWData = stackTop;
                        } // ALU
                    }
                }
            } // J1 CPU Instruction Execute

            // update pc and perform mem[t] = n
            case 11: {
                if( is_alu ) {
                    // r2pc
                    if( aluop(instruction).is_r2pc ) {
                        newPC = rStackTop >> 1;
                    } else {
                        newPC = pcPlusOne;
                    }
                    
                    // n2memt mem[t] = n
                    if( aluop(instruction).is_n2memt ) {
                        switch( stackTop ) {
                            default: {
                                // WRITE to SPRAM
                                sram_address = stackTop >> 1;
                                sram_data_write = stackNext;
                                sram_readwrite = 1;
                            }
                            case 16hf000: {
                                // OUTPUT to UART
                                uartOutBuffer.wdata1 = bytes(stackNext).byte0;
                                newuartOutBufferTop = uartOutBufferTop + 1;
                                //uart_in_data = bytes(stackNext).byte0;
                                //uart_in_valid = 1;
                            }
                            case 16hf002: {
                                // OUTPUT to rgbLED
                                rgbLED = stackNext;
                            }
                        }
                    }
                }
                // Write to dstack and rstack
                if( dstackWrite ) {
                    // bram code for dstack (code from @sylefeb)
                    dstack.wenable = 1;
                    dstack.addr    = newDSP;
                    dstack.wdata   = stackTop;
                }
                if( rstackWrite ) {
                    // bram code for rstack (code from @sylefeb)
                    rstack.wenable = 1;
                    rstack.addr    = newRSP;
                    rstack.wdata   = rstackWData;
                }
            }
            
            // Update dsp, rsp, pc, stackTop
            case 13: {
                dsp = newDSP;
                pc = newPC;
                stackTop = newStackTop;
                rsp = newRSP;
                
                // Setup addresses for dstack and rstack brams (code from @sylefeb)
                dstack.addr = newDSP;
                rstack.addr = newRSP;
            }
            
            // reset sram_readwrite
            case 15: {
                sram_readwrite = 0;
            }
            
            default: {}
        } // switch(CYCLE)
        
        // Reset UART
        if(uart_in_ready & uart_in_valid) {
            uart_in_valid = 0;
        }
    
        CYCLE = CYCLE + 1;
    } // (INIT==3 execute J1 CPU)

}
