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
    uint1   pad,                    // spare
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
    output uint1    rgbB,
    output uint1    rgbG,
    output uint1    rgbR,

    // SPRAM Interface
    output uint16   sram_addr,
    output uint16   sram_data_in,
    input  uint16   sram_data_out,
    output uint1    sram_wren,

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
    uint16 dstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    uint16  stackTop = 0;
    uint5   dsp = 0;
    uint5   newDSP = uninitialized;
    uint16  newStackTop = uninitialized;

    // rstack 32x16bit and pointer, next pointer, write line
    uint16 rstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
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
    
    // FOMU LEDS
    uint1 BLUE = 0; uint1 GREEN = 0; uint1 RED = 0;
    
    // Address for 0 to SPRAM, copying ROM, plus storage
    uint16 copyaddress = 0;
    uint16 bramREAD = 0;

    // UART buffer FIFO
    uint8 uartBuffer[16] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    uint4 uartBufferNext = 0;
    uint4 uartBufferTop = 0;
    
    // Start of main loop
    while(1) {
    
    rgbB = BLUE;
    rgbG = GREEN;
    rgbR = RED;

    switch(INIT) {
        // INIT is 0 ZERO SPRAM
        case 0: {
            GREEN = ~GREEN;
            switch(CYCLE) {
                case 0: {
                    // Setup WRITE to SPRAM
                    sram_addr = copyaddress;
                    sram_data_in = 0;
                    sram_wren = 1;
                }
                case 3: {
                    sram_wren = 0;
                    copyaddress = copyaddress + 1;
                }
                case 15: {
                    if(copyaddress == 16384) {
                        INIT = 1;
                        GREEN = 0;
                        copyaddress = 0;
                    }
                }
            }
        }
        
        // INIT is 1 COPY ROM TO SPRAM
        case 1: {
            RED = ~RED;
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
                    sram_addr = copyaddress;
                    sram_data_in = bramREAD;
                    sram_wren = 1;
                }
                case 14: {
                    copyaddress = copyaddress + 1;
                    sram_wren = 0;
                }
                case 15: {
                    if(copyaddress == 3336) {
                        INIT = 2;
                        copyaddress = 0;
                        RED = 0;
                    }
                }
                default: {
                }
            }
        }

        // INIT is 2 EXECUTE J1 CPU
        case 2: {
            // READ from UART if character available and store
            if(uart_out_valid) {
                uartBuffer[uartBufferNext] = uart_out_data;
                uartBufferTop = uartBufferTop + 1;
                uart_out_ready = 1;
            }
            
            switch(CYCLE) {
                // Read stackNext, rStackTop
                case 0: {
                    stackNext = dstack[dsp];
                    rStackTop = rstack[rsp];
                
                    // start READ memoryInput = [stackTop] result ready in 2 cycles
                    sram_addr = stackTop >> 1;
                    sram_wren = 0;
                }
                case 3: {
                    // wait 2 CYCLES then read the data from SPRAM
                    memoryInput = sram_data_out;
                }
                
                 // start READ instruction = [pc] result ready in 2 cycles
                case 4: {
                    sram_addr = pc;
                    sram_wren = 0;
                }
                case 8: {
                    // wait 2 CYCLES then read the instruction from SPRAM
                    instruction = sram_data_out;
                }

                // J1 CPU Instruction Execute
                case 9: {
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
                    // | 0 | 1 | 1 |R2P| ALU OPERATION |T2N|T2R|N2A|   | RSTACK| DSTACK|
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
                                switch( aluop(instruction).operation ) { // ALU Operation
                                    case 4b0000: {newStackTop = stackTop;
                                    }
                                    
                                    case 4b0001: {newStackTop = stackNext;
                                    }
                                    
                                    case 4b0010: {newStackTop = stackTop + stackNext;
                                    }
                                    
                                    case 4b0011: {newStackTop = stackTop & stackNext;
                                    }
                                    
                                    case 4b0100: {newStackTop = stackTop | stackNext;
                                    }

                                    case 4b0101: {newStackTop = stackTop ^ stackNext;
                                    }

                                    case 4b0110: {newStackTop = ~stackTop;
                                    }

                                    case 4b0111: {newStackTop = {16{(stackNext == stackTop)}};
                                    }

                                    case 4b1000: {newStackTop = {16{(__signed(stackNext) < __signed(stackTop))}};
                                    }
                                    
                                    case 4b1001: {newStackTop = stackNext >> nibbles(stackTop).nibble0;
                                    }

                                    case 4b1010: {newStackTop = stackTop - 1;
                                    }

                                    case 4b1011: {newStackTop = rStackTop;
                                    }

                                    case 4b1100: {
                                        // UART or memoryInput
                                        if(stackTop > 16383) {
                                            // UART
                                            if( stackTop == 16hf000 ) {
                                                // INPUT from UART
                                                newStackTop = { 8b0, uartBuffer[uartBufferNext] };
                                                uartBufferNext = uartBufferNext + 1;
                                                RED = ~RED;
                                            } else {
                                                // STATUS from UART
                                                // as 14b0 then txBusy rxAvailable
                                                if( uartBufferNext == uartBufferTop ) {
                                                    newStackTop = {14b0, uart_in_valid, 1b0};
                                                } else {
                                                    newStackTop = {14b0, uart_in_valid, 1b1};
                                                }
                                                BLUE = ~BLUE;
                                            }
                                        } else {
                                            // memoryInput
                                            newStackTop = memoryInput;
                                        }
                                    }
                                    
                                    case 4b1101: {newStackTop = stackNext << nibbles(stackTop).nibble0;
                                    }

                                    case 4b1110: {newStackTop = {rsp, 3b000, dsp};
                                    }

                                    case 4b1111: {newStackTop = {16{(__unsigned(stackNext) < __unsigned(stackTop))}};
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
                case 10: {
                    if( is_alu ) {
                        // r2pc
                        if( aluop(instruction).is_r2pc ) {
                            newPC = rStackTop >> 1;
                        } else {
                            newPC = pcPlusOne;
                        }
                        
                        // n2memt mem[t] = n
                        if( aluop(instruction).is_n2memt ) {
                            if( stackTop < 16384 ) {
                                // WRITE to SPRAM
                                sram_addr = stackTop >> 1;
                                sram_data_in = stackNext;
                                sram_wren = 1;
                            } else {
                                // OUTPUT to UART
                                uart_in_data = bytes(stackNext).byte0;
                                uart_in_valid = 1;
                                GREEN = ~GREEN;
                            }
                        }
                    }
                }
                
                // Write to dstack and rstack
                case 11: {
                    if( dstackWrite ) {
                        dstack[newDSP] = stackTop;
                    }
                    if( rstackWrite ) {
                        rstack[newRSP] = rstackWData;
                    }
                }
               
                // Update dsp, rsp, pc, stackTop
                case 12: {
                    dsp = newDSP;
                    pc = newPC;
                    stackTop = newStackTop;
                    rsp = newRSP;
                }
                
                // reset sram_wren
                case 15: {
                    sram_wren = 0;
                }
                
                default: {}
                
            } // switch(CYCLE)
        } // case(INIT=2 execute J1 CPU)
        
    } // switch(INIT)   

    // Reset UART
    if(uart_in_ready & uart_in_valid) {
        uart_in_valid = 0;
    }
   
    CYCLE = CYCLE + 1;
    } // while(1)
}
