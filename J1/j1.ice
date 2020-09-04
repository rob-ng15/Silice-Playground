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
    uint16 dstack[33] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    uint5 dsp = uninitialized;
    uint5 dspN = 0;
    uint1 dstackW = 0;
    int16 st1 = uninitialized;
    int2 ddelta = 0;
    
    // rstack 33x16bit and pointer, next pointer, write line, delta
    uint16 rstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    uint5 rsp = uninitialized;
    uint5 rspN = 0;
    uint1 rstackW = 0;
    int16 st0 = 0;
    int16 st0N = 0;
    uint16 rstkD = 0;
    uint16 rst0 = uninitialized;
    int2 rdelta = 0;
    
    // ROM will be addressed from 0 - 8191, RAM will be addressed from 8192-16383
    // 16bit ROM with included compiled j1eForth from https://github.com/samawati/j1eforth
    brom uint16 rom[] = {
        $include('j1.inc')
    };

    // RAM as 8192 x 16bit
    bram uint16 ram[2048] = uninitialized;

    // RAM write enable
    uint1 ramWE = 0;
    int16 io_din = 0;
    int16 mem_din = 0;
    
    // Program counter, next program counter, present instruction, extracted immediate
    uint13 pc = uninitialized;
    uint13 pcN = 0;
    uint16 pcplus1 = uninitialized;
    
    uint16 instruction = uninitialized;
    uint16 immediate = uninitialized;

++:

    // Start of main loop
    while(1) {
        rgbB = 1;
        
        // Update pointers from last run
        dsp = dspN;
        pc = pcN;
        st0 = st0N;
        rsp = rspN;
        pcplus1 = pc + 1;

        ++:
        
        // Write to dstack
        if(dstackW) {
            dstack[dspN] = st0;
        }
        // Write to rstack
        if(rstackW) {
            rstack[rspN] = rstkD;
        }
        
        ++:
        
        st1 = dstack[dsp];
        rst0 = rstack[rsp];
        
        ++:
        
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
        rgbR = 1;
        ++:
        if(pc<8192) {
            instruction = rom.rdata;
        } else {
            instruction = ram.rdata;
        }
        rgbR = 0;
        
        // Write to memory
        if(ramWE & (st0N[15,2] == 0)) {
            ram.wenable = 1;
            ram.addr = st0[15,15] - 8192;
            ram.wdata = st1;
        } else {
            //while (uart_in_ready == 0) {++:}
            uart_in_data = st1[7,8];
            uart_in_valid = 1;
        }
        
        ++:
        
        //if(uart_in_ready & uart_in_valid) {
        //    uart_in_valid = 0;
        //}

        // Start decode of instruction
        // +---------------------------------------------------------------+
        // | F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 |uart_in_valid = 0; 1 | 0 |
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

        immediate = { 1b0, instruction[14,15] };
        
        if(instruction[15,1]) {
            // immediate value to be pushed to the stack
            st0 = immediate;
            dspN = dsp + 1;
            rspN = rsp;
            rstackW = 0;
            rstkD = pcN;
        } else {
            switch (instruction[14,2] ) {
                case 2b00: {   // BRANCH
                    dspN = dsp;
                    rspN = rsp;
                    rstackW = 0;
                    rstkD = pcN;
                    pcN = instruction[12,13];
                }
                case 2b01: {   // CONDITIONAL BRANCH
                    dspN = dsp - 1;
                    rspN = rsp;
                    rstackW = 0;
                    rstkD = pcN;
                    if(|st0 == 0) {
                       pcN = instruction[12,13]; 
                    } else {
                        pcN = pcplus1;
                    }
                }
                case 2b10: {    // CALL
                    dspN = dsp;
                    rspN = rsp + 1;
                    rstackW = 1;
                    rstkD = {pcplus1[14,15], 1b0};
                    pcN = instruction[12,13];
                }
                case 2b11: {    // ALU
                    switch (instruction[11,4]) {
                        case 4b0000: {st0N = st0;}
                        case 4b0001: {st0N = st1;}
                        case 4b0010: {st0N = st0 + st1;}
                        case 4b0011: {st0N = st0 & st1;}
                        case 4b0100: {st0N = st0 | st1;}
                        case 4b0101: {st0N = st0 ^ st1;}
                        case 4b0110: {st0N = -st0;}
                        case 4b0111: {st0N = (st1 == st0);}
                        case 4b1000: {st0N = (st1 < st0 );}
                        case 4b1001: {st0N = st1 >> st0[3,4];}
                        case 4b1010: {st0N = st0 - 1;}
                        case 4b1011: {st0N = rst0;}
                        case 4b1100: { // LOAD from address
                                        if(st0>16383) {
                                            rgbG = 1;
                                            // input from UART
                                            if(uart_out_valid) {
                                                st0N = {8b0, uart_out_data};
                                                uart_out_ready = 1;
                                            } else {
                                                st0N = 0;
                                                uart_out_ready = 1;
                                            }
                                            rgbG = 0;
                                        } else {
                                            if(st0<8192) {
                                                // LOAD from ROM
                                                rom.addr = st0;
                                            } else {
                                                // LOAD from RAM
                                                ram.wenable = 0;
                                                ram.addr = st0 - 8192;
                                            }
                                            
                                            ++:
                                            if(st0<8192) {
                                                st0 = rom.rdata;
                                            } else {
                                                st0 = ram.rdata;
                                            }
                                        }
                                     }
                        case 4b1101: {st0N = st1 << st0[3,4];}
                        case 4b1110: {st0N = {rsp, 3b000, dsp};}
                        case 4b1111: {st0N = st1 < st0;}
                    }
                    ddelta = instruction[1,2];
                    rdelta = instruction[3,2];
                    dspN = dsp + {ddelta[1,1], ddelta[1,1], ddelta[1,1], ddelta};
                    rspN = rsp + {rdelta[1,1], rdelta[1,1], rdelta[1,1], rdelta};
                    rstackW = instruction[6,1];
                    rstkD = st0;
                    if(instruction[12,1]) {
                        pcN = instruction[12,13];
                    } else {
                        pcN = pcplus1;
                    }
                }
            }
        }
        
        ramWE = (instruction[15,3]==3b011) & instruction[5,1];
        dstackW = (instruction[15,1]) | ( (instruction[15,3]==3b011) & (instruction[7,1]) );
    }
    ++:
} 
