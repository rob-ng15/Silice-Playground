bitfield literal {
    uint1  is_literal,
    uint15 immediate
}

bitfield callbranch {
    uint1  is_literal,
    uint2  is_callbranchalu,
    uint13 address
}

bitfield aluop {
    uint1   is_literal,
    uint2   is_callbranchalu,
    uint1   is_r2pc,
    uint4   operation,
    uint1   is_t2n,
    uint1   is_t2r,
    uint1   is_n2memt,
    uint1   pad,
    uint2   rdelta,
    uint2   ddelta
}

bitfield bytes {
    uint8   byte1,
    uint8   byte0
}

bitfield nibbles {
    uint4   nibble3,
    uint4   nibble2,
    uint4   nibble1,
    uint4   nibble0
}

bitfield twobits {
    uint1   bit1,
    uint1   bit0
}

algorithm main(
    // RGB LED
    output uint1    rgbB,
    output uint1    rgbG,
    output uint1    rgbR,

    // SPRAM
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
    uint13 pc = 0;
    uint13 pcPlus1 = 0;
    uint13 pcNextClock = 0;
    uint16 memory_read = 0;
    uint13 blockram = 0;
    
    uint16 instruction = 0;
    uint2 ddelta := aluop(instruction).ddelta;
    uint2 rdelta := aluop(instruction).rdelta;

    uint1 is_literal := literal(instruction).is_literal;
    uint1 is_aluop := aluop(instruction).is_callbranchalu == 2b11;
    
    // dstack 33x16bit and pointer, next pointer, write line, delta
    uint16 dstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    uint5 dsp = 0;
    uint16 dstackTop = 0;
    uint16 dstackSec = 0;
    uint5 dspNextClock = 0;
    uint16 aluopResult = 0;
    uint1 dstackWrite = 0;
    
    // rstack 33x16bit and pointer, next pointer, write line, delta
    uint16 rstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    uint5 rsp = 0;
    uint16 rstackTop = 0;
    uint5 rspNextClock = 0;
    uint16 rstackOutput = 0;
    uint1 rstackWrite = 0;
    
    // 16bit ROM with included compiled j1eForth from https://github.com/samawati/j1eforth
    bram uint16 rom[] = {
        $include('j1eforth16lsb.inc')
    };
    
    // cycle to control each stage, init to determine if copying rom to ram or executing
    uint16 cycle = 0;
    uint1 init = 0;
    // BLUE heartbeat
    uint1 BLUE = 0;
    // GREEN alu heartbeat
    uint1 GREEN = 0;
    // RED whilst copying ROM to SRAM
    uint1 RED = 1;      

    ++:
    
    // Start of main loop
    while(1) {
        rgbB = BLUE;
        rgbG = GREEN;
        rgbR = RED;
        
    switch(init) {
        // COPY ROM TO SPRAM
        case 0: {
            RED = 1 - RED;
            switch(cycle) {
                case 0: {
                    // Setup READ from ROM
                    rom.addr = blockram;
                    rom.wenable = 0;
                }
                case 3: {
                    // READ from ROM
                    memory_read = rom.rdata;
                }
                case 7: {
                    // WRITE to SPRAM
                    sram_addr = pcNextClock;
                    sram_data_in = memory_read;
                    sram_wren = 1;
                }
                case 8: {
                    pcNextClock = pcNextClock + 1;
                    blockram = blockram + 1;
                }
                case 9: {
                    if(pcNextClock == 3336) {
                        init = 1;
                        BLUE = 1;
                    }
                }
                default: {
                }
            }
        }
    
        // EXECUTE J1 CPU
        case 1: {
            RED = 0;

//            // On UART data available, echo instruction
//            if(uart_out_valid) {
//                uart_in_data = instruction[3,4] + 65;
//                uart_in_valid = 1;
//                uart_out_ready = 1;
//            }
//            // reset to allow new uart data
//            if(uart_in_ready & uart_in_valid) {
//                uart_in_valid = 0;
//            }

            switch(cycle) {
           
                // Write result to memory / UART
                case 0: {
                    if(is_aluop & aluop(instruction).is_n2memt) {
                        if(aluopResult < 16384) {
                            // write RAM
                            sram_addr = {1b0,aluopResult[15,15]};
                            sram_data_in = dstackTop; // check top or sec
                        } else {
                            // write UART
                            uart_in_data = bytes(dstackTop).byte0; // check top or sec
                            uart_in_valid = 1;
                        }
                    }
                }
                case 1: {
                    if(is_aluop & aluop(instruction).is_n2memt) {
                        if(aluopResult < 16384) {
                            sram_wren = 1;
                        }
                    }
                }

                // READ sram[aluopResult]
                case 3: {
                    sram_addr = {1b0,aluopResult[15,15]};
                    sram_wren = 0;
                }
                case 6: {
                    memory_read = sram_data_out;
                }
                
                // READ sram[pc]
                case 7: {
                    sram_addr = {2b00,pc};
                    sram_wren = 0;
                }
                case 10: {
                    instruction = sram_data_out;
                }

                // UPDATE dstackTop, dstackSec, rstackTop
                case 11: {
                    dstackTop = dstack[dsp];
                    dstackSec = dstack[dsp-1];
                    rstackTop = rstack[rsp];
                    pcPlus1 = pc + 1;
                }

                // J1 CPU Instruction Execute
                case 12: {
                    // Start decode of instruction
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
                    // | 0 | 1 | 1 |   ALU OPERATION   |T2N|T2R|N2A|R2P| RSTACK| DSTACK|
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
                    
                    if(is_literal) {
                        // Push value onto stack
                        aluopResult = {1b0, literal(instruction).immediate};
                        dstackWrite = 1;
                        dspNextClock = dsp + 1;
                    } else {
                        switch (callbranch(instruction).is_callbranchalu) {
                            case 2b00: {
                                // BRANCH
                                pcNextClock = callbranch(instruction).address;
                            }
                            case 2b01: {
                                // CONDITIONAL BRANCH (check pcNextClock)
                                if(dstackTop == 0) {
                                    pcNextClock = pcPlus1;
                                } else {
                                    pcNextClock = callbranch(instruction).address;
                                }
                                dspNextClock = dsp - 1;
                            }
                            case 2b10: {
                                // CALL
                                rstackWrite = 1;
                                rstackOutput = {pcPlus1[14,15], 1b0};
                                rspNextClock = rsp + 1;
                                pcNextClock = callbranch(instruction).address;
                            }
                            case 2b11: {    // ALU
                                GREEN = 1 - GREEN;
                                switch(aluop(instruction).operation) {
                                    case 4b0000: {aluopResult = dstackTop;}
                                    case 4b0001: {aluopResult = dstackSec;}
                                    case 4b0010: {aluopResult = dstackTop + dstackSec;}
                                    case 4b0011: {aluopResult = dstackTop & dstackSec;}
                                    case 4b0100: {aluopResult = dstackTop | dstackSec;}
                                    case 4b0101: {aluopResult = dstackTop ^ dstackSec;}
                                    case 4b0110: {aluopResult = ~dstackTop;}
                                    case 4b0111: {aluopResult = (dstackTop == dstackSec);}
                                    case 4b1000: {aluopResult = (__signed(dstackSec) < __signed(dstackTop));}
                                    case 4b1001: {aluopResult = dstackSec >> nibbles(dstackTop).nibble0;}
                                    case 4b1010: {aluopResult = dstackTop - 1;}
                                    case 4b1011: {aluopResult = rstackTop;}
                                    case 4b1100: {  // Read value from memory/uart
                                        if(dstackTop<16384) {
                                            aluopResult = memory_read;
                                        } else {
                                            if(uart_out_valid) {
                                                aluopResult = {8b0, uart_out_data};
                                                uart_out_ready = 1;
                                            } else {
                                                aluopResult = 0;
                                            }
                                        }
                                    }
                                    case 4b1101: {aluopResult = dstackSec << nibbles(dstackTop).nibble0;}
                                    case 4b1110: {aluopResult = {rsp,3b000,dsp};}
                                    case 4b1111: {aluopResult = dstackSec < dstackTop;}
                                }
                                if(aluop(instruction).is_r2pc) {
                                    // return stack to PC
                                    pcNextClock = {1b0, rstackTop[15,15]};
                                } else {
                                    // next instruction
                                    pcNextClock = pc + 1;
                                }
                                // Calculate new dsp and rsp
                                dspNextClock = dsp + {twobits(ddelta).bit1, twobits(ddelta).bit1, twobits(ddelta).bit1, ddelta};
                                rspNextClock = rsp + {twobits(rdelta).bit1, twobits(rdelta).bit1, twobits(rdelta).bit1, rdelta};
                                rstackOutput = dstackTop;
                                dstackWrite = aluop(instruction).is_t2n;
                                rstackWrite = is_aluop & aluop(instruction).is_t2r;
                            }
                        }
                    }
                } // EXECUTE

                // Update dstack, rstack
                case 13: {
                    if(dstackWrite) {
                        dstack[dspNextClock] = aluopResult;
                    }
                    if(rstackWrite) {
                        rstack[rspNextClock] = rstackOutput;
                    }
                }
        
                // Update dsp, rsp, pc
                case 14: {
                    dsp = dspNextClock;
                    rsp = rspNextClock;
                    pc = pcNextClock;
                    dstackWrite = 0;
                    rstackWrite = 0;
                }

                // Reset UART
                case 15: {
                    if(uart_in_ready & uart_in_valid) {
                        uart_in_valid = 0;
                    }
                }

                // SLEEP
                default: {}
                
            } // switch(cycle)
        } // case(init=1)
        
    } // switch(init)   
    
    cycle = cycle + 1;
    } // while(1)
}
