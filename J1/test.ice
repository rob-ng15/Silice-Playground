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
    // dstack 33x16bit and pointer, next pointer, write line, delta
    int16 dstack[33] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    int16 dstackTop = 0;
    int16 dstackSec = 0;
    uint5 dsp = 0;
    uint5 dspNext = 1;
    int2 ddelta = 0;
    int16 dstackOutput = 0;
    
    // rstack 33x16bit and pointer, next pointer, write line, delta
    int16 rstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    int16 rstackTop = 0;
    uint5 rsp = 0;
    uint5 rspNext = 1;
    int2 rdelta = 0;
    
    // ROM will be addressed from 0 - 8191, RAM will be addressed from 8192-16383
    // 16bit ROM with included compiled j1eForth from https://github.com/samawati/j1eforth
    brom uint16 rom[] = {
        $include('j1.inc')
    };

    // RAM as 8192 x 16bit
    bram uint16 ram[2048] = uninitialized;

    // Program counter, next program counter, present instruction, extracted immediate
    uint13 pc = 0;
    uint13 pcNext = 1;

    uint16 instruction = uninitialized;
    uint16 immediate = uninitialized;
    
    // Start of main loop
    while(1) {
        // Show we are alive
        rgbB = 1;
        
        dstackTop = dstack[dsp];
        dstackSec = dstack[dsp - 1];
        dspNext = dsp + 1;
        rstackTop = rstack[rsp];
        rspNext = rsp + 1;
        pcNext = pc + 1;
        
        // Retrieve the next instruction 0-8191 ROM, 8192-16383 RAM
        if(pc < 8192) {
            // READ from ROM
            rom.addr = pc;
        } else {
            // READ from RAM
            ram.wenable = 0;
            ram.addr = pc - 8192;
            instruction = ram.rdata;
        }
        ++:
        if(pc<8192) {
            instruction = rom.rdata;
        } else {
            instruction = ram.rdata;
        }
        
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
        
        if(instruction[15,1]) {
            // Push value onto stack
            dstack[dspNext] = {1b0, instruction[14,15]};
            dsp = dsp + 1;
        } else {
            switch (instruction[14,2] ) {
                case 2b00: {    // BRANCH
                    pc = instruction[12,13];
                }
                case 2b01: {    // CONDITIONAL BRANCH
                    if(dstackTop == 0) {
                        pc = pcNext;
                    } else {
                        pc = instruction[12,13];
                    }
                    dsp = dsp - 1;
                }
                case 2b10: {    // CALL
                    rstack[rspNext] = pcNext;
                    rsp = rsp + 1;
                    pc = instruction[12,13];
                }
                case 2b11: {    // ALU
                    switch(instruction[11,4]) {
                        case 4b0000: {dstackOutput = dstackTop;}
                        case 4b0001: {dstackOutput = dstackSec;}
                        case 4b0010: {dstackOutput = dstackTop + dstackSec;}
                        case 4b0011: {dstackOutput = dstackTop & dstackSec;}
                        case 4b0100: {dstackOutput = dstackTop | dstackSec;}
                        case 4b0101: {dstackOutput = dstackTop ^ dstackSec;}
                        case 4b0110: {dstackOutput = ~dstackTop;}
                        case 4b0111: {dstackOutput = (dstackTop == dstackSec);}
                        case 4b1000: {dstackOutput = (__signed(dstackSec) < __signed(dstackTop));}
                        case 4b1001: {dstackOutput = dstackSec >> dstackTop[3,4];}
                        case 4b1010: {dstackOutput = dstackTop -1;}
                        case 4b1011: {dstackOutput = rstackTop;}
                        case 4b1100: {  // Read value from memory/uart
                            if(dstackTop<8192) {
                                // read ROM
                                 rom.addr = dstackTop;
                                ++:
                                dstackOutput = rom.rdata;
                            }
                            if( (dstackTop>8191) & (dstackTop<16384) ) {
                                ram.wenable = 0;
                                ram.addr = dstackTop - 8192;
                                ++:
                                dstackOutput = ram.rdata;
                            }
                            if(dstackTop>16384) {
                                rgbG = 1;
                                if(uart_out_valid) {
                                    dstackOutput = {8b0, uart_out_data};
                                    uart_out_ready = 1;
                                } else {
                                    dstackOutput = 0;
                                    uart_out_ready = 1;
                                }
                                ++:
                                rgbG = 0;
                            }
                        }
                        case 4b1101: {dstackOutput = dstackSec << dstackTop[3,4];}
                        case 4b1110: {dstackOutput = {rsp,3b000,dsp};}
                        case 4b1111: {dstackOutput = dstackSec < dstackTop;}
                    }
                    // Calculate new dsp and rsp
                    ddelta = instruction[1,2];
                    rdelta = instruction[3,2];
                    dsp = dsp + {ddelta[1,1], ddelta[1,1], ddelta[1,1], ddelta};
                    rsp = rsp + {rdelta[1,1], rdelta[1,1], rdelta[1,1], rdelta};
                    ++:
                    dstack[dsp] = dstackOutput;
                    if(instruction[6,1]) {
                        // copy top of stack to return stack
                        rstack[rsp] = dstackTop;
                    }
                    if(instruction[5,1]) {
                        rgbR = 1;
                        // write dstackSec to rom/ram[dstackTop]
                        if(dstackTop<8192) {
                            // write ROM
                        }
                        if( (dstackTop>8191) & (pc<16384) ) {
                            // write RAM
                            ram.wenable = 1;
                            ram.addr = dstackTop - 8192;
                            ++:
                            ram.wdata = dstackSec;
                        }
                        if(dstackTop>16384) {
                            // write UART
                            uart_in_data = dstackSec[7,8];
                            uart_in_valid = 1;
                            ++:
                        }
                        rgbR = 0;
                   }
               }
            }
        }
        
        ++:
        // Reset UART
        //if(uart_in_ready & uart_in_valid) {
        //    uart_in_valid = 0;
        //}
        rgbB = 0;
    }
}
