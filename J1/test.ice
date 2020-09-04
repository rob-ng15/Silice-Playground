bitfield literal {
    uint1  is_literal,
    uint15 literal
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
    output uint1 rgbB,
    output uint1 rgbG,
    output uint1 rgbR,
    // UART Interface
    output   uint8 uart_in_data,
    output   uint1 uart_in_valid,
    input    uint1 uart_in_ready,
    input    uint8 uart_out_data,
    input    uint1 uart_out_valid,
    output   uint1 uart_out_ready
) {
    // Program counter, next program counter, present instruction, extracted immediate
    uint13 pc = 0;
    uint13 pcNextClock = uninitialized;

    uint16 instruction = uninitialized;
    int2 ddelta := aluop(instruction).ddelta;
    int2 rdelta := aluop(instruction).rdelta;

    uint1 is_literal := literal(instruction).is_literal;
    uint1 is_aluop := aluop(instruction).is_callbranchalu == 2b11;
    
    // dstack 33x16bit and pointer, next pointer, write line, delta
    int16 dstack[33] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    int16 dstackTop = uninitialized;
    int16 dstackSec = uninitialized;
    uint5 dsp = 0;
    uint5 dspNextClock = uninitialized;
    uint5 dspPlus1 := dsp + 1;
    uint5 dspMinus1 := dsp - 1;
    int16 dstackOutput = uninitialized;
    uint1 dstackWrite := is_literal | (is_aluop & aluop(instruction).is_t2n);
    
    // rstack 33x16bit and pointer, next pointer, write line, delta
    int16 rstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    int16 rstackTop = uninitialized;
    uint5 rsp = 0;
    uint5 rspNextClock = uninitialized;
    uint5 rspPlus1 := rsp + 1;
    int16 rstackOutput = uninitialized;
    uint1 rstackWrite = 0;
    
    // RAM
    // 16bit ROM with included compiled j1eForth from https://github.com/samawati/j1eforth
    // followed by RAM
    bram uint16 ram[] = {
        $include('j1eforth.inc')
    };

    ++:    
    
    // Start of main loop
    while(1) {
        // Show we are alive
        rgbB = 0;

        dstackTop = dstack[dsp];
        dstackSec = dstack[dspMinus1];
        rstackTop = rstack[rsp];
        
        // Retrieve the next instruction 0-16383 RAM
        if(pc < 16384) {
            rgbR = 1;
            // READ from RAM
            ram.wenable = 0;
            ram.addr = pc;
            ++:
            instruction = ram.rdata;
            rgbR = 0;
        } else {
            // Basically an error! (Go back to 0)
            instruction = 0;
        }

        ++:
        
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
            dstackOutput = {1b0, literal(instruction).literal};
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
                        pcNextClock = pc + 1;
                    } else {
                        pcNextClock = callbranch(instruction).address;
                    }
                    dspNextClock = dspMinus1;
                }
                case 2b10: {
                    // CALL
                    rstackOutput = pc + 1;
                    rstackWrite = 1;
                    rspNextClock = rspPlus1;
                    pcNextClock = callbranch(instruction).address;
                }
                case 2b11: {    // ALU
                    switch(aluop(instruction).operation) {
                        case 4b0000: {dstackOutput = dstackTop;}
                        case 4b0001: {dstackOutput = dstackSec;}
                        case 4b0010: {dstackOutput = dstackTop + dstackSec;}
                        case 4b0011: {dstackOutput = dstackTop & dstackSec;}
                        case 4b0100: {dstackOutput = dstackTop | dstackSec;}
                        case 4b0101: {dstackOutput = dstackTop ^ dstackSec;}
                        case 4b0110: {dstackOutput = ~dstackTop;}
                        case 4b0111: {dstackOutput = (dstackTop == dstackSec);}
                        case 4b1000: {dstackOutput = (__signed(dstackSec) < __signed(dstackTop));}
                        case 4b1001: {dstackOutput = dstackSec >> nibbles(dstackTop).nibble0;}
                        case 4b1010: {dstackOutput = dstackTop -1;}
                        case 4b1011: {dstackOutput = rstackTop;}
                        case 4b1100: {  // Read value from memory/uart
                            rgbG = 1;
                            if(dstackTop<16384) {
                                ram.wenable = 0;
                                ram.addr = dstackTop;
                                ++:
                                dstackOutput = ram.rdata;
                            } else {
                                if(uart_out_valid) {
                                    dstackOutput = {8b0, uart_out_data};
                                    uart_out_ready = 1;
                                } else {
                                    dstackOutput = 0;
                                    uart_out_ready = 1;
                                }
                                ++:
                            }
                            rgbG = 0;
                        }
                        case 4b1101: {dstackOutput = dstackSec << nibbles(dstackTop).nibble0;}
                        case 4b1110: {dstackOutput = {rsp,3b000,dsp};}
                        case 4b1111: {dstackOutput = dstackSec < dstackTop;}
                    }
                    if(aluop(instruction).is_r2pc) {
                        // return stack to PC
                        pcNextClock = rstackTop;
                    } else {
                        // next instruction
                        pcNextClock = pc + 1;
                    }
                    if(aluop(instruction).is_n2memt) {
                        // write dstackSec to ram[dstackTop]
                        rgbG = 1;
                        if(dstackTop<16384) {
                            // write RAM
                            ram.wenable = 1;
                            ram.addr = dstackTop;
                            ++:
                            ram.wdata = dstackSec;
                        } else {
                            // write UART
                            uart_in_data = bytes(dstackSec).byte0;
                            uart_in_valid = 1;
                            // Reset UART
                            //if(uart_in_ready & uart_in_valid) {
                            //    uart_in_valid = 0;
                            //}
                        }
                        rgbG = 0;
                    }
                    // Calculate new dsp and rsp
                    dspNextClock = dsp + {twobits(ddelta).bit1, twobits(ddelta).bit1, twobits(ddelta).bit1, ddelta};
                    rspNextClock = rsp + {twobits(rdelta).bit1, twobits(rdelta).bit1, twobits(rdelta).bit1, rdelta};
                    rstackWrite = aluop(instruction).is_t2r;
                    rstackOutput = dstackTop;
               }
            }
        }
        
        ++:
        
        if(dstackWrite) {
            dstack[dspNextClock] = dstackOutput;
        }
        if(rstackWrite) {
            rstack[rspNextClock] = rstackOutput;
        }
        dsp = dspNextClock;
        rsp = rspNextClock;
        pc = pcNextClock;
        
        rgbB = 0;
    }
}
