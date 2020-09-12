bitfield instruction {
    uint3 is_litcallbranchalu,
    uint13 pad
}

bitfield literal {
    uint1  is_literal,
    uint15 value
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

bitfield bits {
    uint1   bit15,
    uint1   bit14,
    uint1   bit13,
    uint1   bit12,
    uint1   bit11,
    uint1   bit10,
    uint1   bit9,
    uint1   bit8,
    uint1   bit7,
    uint1   bit6,
    uint1   bit5,
    uint1   bit4,
    uint1   bit3,
    uint1   bit2,
    uint1   bit1,
    uint1   bit0
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
    uint16  insn = 0;
    uint4   st0sel = 0;
    uint16  immediate = 0;
    uint1   is_alu = 0;
    uint1   is_lit = 0;
    
    uint5   dsp = 0;
    uint5   udsp = 0;
    uint16  st0 = 0;        // top of stack unsigned
    uint16  ust0 = 0;
    uint1   udstkW = 0;
    
    uint16  pc = 0;
    uint16  pc_plus_1 = 0;
    uint16  upc = 0;
    uint5   rsp = 0;
    uint5   ursp = 0;
    uint1   urstkW = 0;
    uint16  urstkD = 0;

    uint16  st1 = 0;        // second in stack unsigned
    uint16  rst0 = 0;
    uint16  mem_din = 0;

    // dstack 32x16bit and pointer, next pointer, write line, delta
    // rstack 32x16bit and pointer, next pointer, write line, delta
    uint16 dstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    uint16 rstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    
    // 16bit ROM with included compiled j1eForth from https://github.com/samawati/j1eforth
    bram uint16 rom[] = {
        $include('j1test.inc')
    };
    
    // cycle to control each stage, init to determine if copying rom to ram or executing
    uint15 cycle = 0;
    // INIT 0 SPRAM, INIT 1 ROM to SPRAM, INIT 2 UART TEST, INIT 3 J1 CPU
    uint2 init = 0;
    // BLUE heartbeat
    uint1 BLUE = 0;
    // GREEN whilst 0 to SPRAM and alu heartbeat
    uint1 GREEN = 0;
    // RED whilst copying ROM to SRAM
    uint1 RED = 0;      
    // Address for 0 to SPRAM, copying ROM, plus storage
    uint16 copyaddress = 0;
    uint16 memory_read = 0;

    // DEBUG charout
    uint8 charout = 0;
    
    // Start of main loop
    while(1) {
    
    rgbB = BLUE;
    rgbG = GREEN;
    rgbR = RED;
        
    switch(init) {
        // ZERO SPRAM
        case 0: {
            GREEN = ~GREEN;
            switch(cycle) {
                case 0: {
                    // Setup WRITE to SPRAM
                    sram_addr = copyaddress;
                    sram_data_in = 0;
                    sram_wren = 1;
                }
                case 30: {
                    sram_wren = 0;
                    copyaddress = copyaddress + 1;
                }
                case 31: {
                    if(copyaddress == 16384) {
                        init = 1;
                        GREEN = 0;
                        copyaddress = 0;
                    }
                }
            }
        }
        
        // COPY ROM TO SPRAM
        case 1: {
            RED = ~RED;
            switch(cycle) {
                case 0: {
                    // Setup READ from ROM
                    rom.addr = copyaddress;
                    rom.wenable = 0;
                }
                case 8: {
                    // READ from ROM
                    memory_read = rom.rdata;
                }
                case 15: {
                    // WRITE to SPRAM
                    sram_addr = copyaddress;
                    sram_data_in = memory_read;
                    sram_wren = 1;
                }
                case 30: {
                    copyaddress = copyaddress + 1;
                    sram_wren = 0;
                }
                case 31: {
                    if(copyaddress == 3336) {
                        init = 3;
                        copyaddress = 0;
                        RED = 0;
                    }
                }
                default: {
                }
            }
        }

        // UART TEST
        case 2: {
            BLUE = ~BLUE;
            switch(cycle) {
                case 0: {
                    // READ from SPRAM
                    sram_addr = copyaddress>>1;
                    sram_wren = 0;
                }
                case 8: {
                    if(bits(copyaddress).bit0) {
                        if((bytes(sram_data_out).byte0>31) & (bytes(sram_data_out).byte0<127)) {
                            uart_in_data = bytes(sram_data_out).byte0;
                        } else {
                            uart_in_data = 32;
                        }
                    } else {
                        if((bytes(sram_data_out).byte1>31) & (bytes(sram_data_out).byte1<127)) {
                            uart_in_data = bytes(sram_data_out).byte1;
                        } else {
                            uart_in_data = 32;
                        }
                    }
                    uart_in_valid = 1;
                }
                case 30: {
                    copyaddress = copyaddress + 1;
                }
                case 31: {
                    if(copyaddress == 6672) {
                        copyaddress = 0;
                    }
                }
                default: {
                }
            }
        }

        // EXECUTE J1 CPU
        case 3: {
            switch(cycle) {
                // Read st0, st1, rst0
                case 0: {
                    st1 = dstack[dsp];
                    rst0 = rstack[rsp];
                }
                
                // READ mem_din = [ust0]
                case 3: {
                    sram_addr = ust0 >> 1;
                    sram_wren = 0;
                }
                case 10: {
                    mem_din = sram_data_out;
                }
                
                
                // READ insn = [pc]
                case 11: {
                    sram_addr = pc;
                    sram_wren = 0;
                }
                case 19: {
                    insn = sram_data_out;
                }

                // DECODE insn
                case 20: {
                    is_lit = literal(insn).is_literal;
                    is_alu = ( instruction(insn).is_litcallbranchalu == 3b011 );
                    immediate = ( literal(insn).value );
                    pc_plus_1 = pc + 1;
                }
                case 21: {
                    udstkW = ( is_lit | (is_alu & aluop(insn).is_t2n) );
                }
                
                // J1 CPU Instruction Execute
                case 22: {
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

                    if(is_lit) { // LITERAL
                        // Push value onto stack
                        ust0 = immediate;
                        upc = pc_plus_1;
                        udsp = dsp + 1;
                        ursp = rsp;
                        urstkW = 0;
                        urstkD = rst0;
                        charout = 76; // DEBUG L
                    } else {
                        switch( callbranch(insn).is_callbranchalu ) { // BRANCH 0BRANCH CALL ALU
                            case 2b00: { // BRANCH
                                ust0 = st0;
                                upc = callbranch(insn).address;
                                udsp = dsp;
                                ursp = rsp;
                                urstkW = 0;
                                urstkD = rst0;
                                charout = 66; // DEBUG B
                            }
                            case 2b01: { // 0BRANCH
                                ust0 = st1;
                                if( st0 == 0 ) {
                                    upc = callbranch(insn).address;
                                    charout = 48; // DEBUG 0
                                } else {
                                    upc = pc_plus_1;
                                    charout = 49; // DEBUG 1
                                }
                                udsp = dsp - 1;
                                ursp = rsp;
                                urstkW = 0;
                                urstkD = rst0;
                            }
                            case 2b10: { // CALL
                                ust0 = st0;
                                upc = callbranch(insn).address;
                                udsp = dsp;
                                ursp = rsp;
                                urstkW = 1;
                                urstkD = pc_plus_1 << 1;
                                charout = 67; // DEBUG L
                            }
                            case 2b11: { // ALU
                                switch( aluop(insn).operation ) { // ALU Operation
                                    case 4b0000: {ust0 = st0;
                                        charout = 84; // DEBUG T
                                    }
                                    
                                    case 4b0001: {ust0 = st1;
                                        charout = 78; // DEBUG N
                                    }
                                    
                                    case 4b0010: {ust0 = st0 + st1;
                                        charout = 43; // DEBUG +
                                    }
                                    
                                    case 4b0011: {ust0 = st0 & st1;
                                        charout = 38; // DEBUG &
                                    }
                                    
                                    case 4b0100: {ust0 = st0 | st1;
                                        charout = 124; // DEBUG |
                                    }

                                    case 4b0101: {ust0 = st0 ^ st1;
                                        charout = 94; // DEBUG ^
                                    }

                                    case 4b0110: {ust0 = ~st0;
                                        charout = 126; // DEBUG ~
                                    }

                                    case 4b0111: {ust0 = {16{(st1 == st0)}};
                                        charout = 61; // DEBUG =
                                    }

                                    case 4b1000: {ust0 = {16{(__signed(st1) < __signed(st0))}};
                                        charout = 60; // DEBUG <
                                    }
                                    
                                    case 4b1001: {ust0 = st1 >> nibbles(st0).nibble0;
                                        charout = 125; // DEBUG right brace
                                    }

                                    case 4b1010: {ust0 = st0 - 1;
                                        charout = 45; // DEBUG -
                                    }

                                    case 4b1011: {ust0 = rst0;
                                        charout = 82; // DEBUG R
                                    }

                                    case 4b1100: {
                                        // UART or mem_din
                                        if(st0 > 16383) { // UART
                                            if( st0 == 16hf000 ) {
                                                charout = 117; // DEBUG u                                                
                                                if( uart_out_valid ) {
                                                    ust0 = uart_out_data;
                                                } else {
                                                    ust0 = 0;
                                                }
                                                uart_out_ready = 1;
                                            } else {
                                                charout = 115; // DEBUG s
                                                ust0 = {14b0, 1b0, uart_out_valid};
                                            }
                                        } else { // MEM
                                            charout = 109; // DEBUG m
                                            ust0 = mem_din;
                                        }
                                    }
                                    
                                    case 4b1101: {ust0 = st1 << nibbles(st0).nibble0;
                                        charout = 123; // DEBUG left brace
                                    }

                                    case 4b1110: {ust0 = {rsp, 3b000, dsp};
                                        charout = 68; // DEBUG D
                                    }

                                    case 4b1111: {ust0 = {16{(__unsigned(st1) < __unsigned(st0))}};
                                        charout = 91; // DEBUG left square
                                    }
                                } // ALU Operation
                                
                                // UPDATE udsp ursp
                                switch( aluop(insn).ddelta ) {
                                    case 2b00: { udsp = dsp; }
                                    case 2b01: { udsp = dsp + 1; }
                                    case 2b10: { udsp = dsp - 2; }
                                    case 2b11: { udsp = dsp - 1; }
                                }
                                switch( aluop(insn).rdelta ) {
                                    case 2b00: { ursp = rsp; }
                                    case 2b01: { ursp = rsp + 1; }
                                    case 2b10: { ursp = rsp - 2; }
                                    case 2b11: { ursp = rsp - 1; }
                                }
                                urstkW = aluop(insn).is_t2r;
                                urstkD = st0;

                            } // ALU
                        }
                    }
                } // J1 CPU Instruction Execute

                     
                // update pc and perform mem[t] = n
                case 23: {
                    if( is_alu ) {
                        // r2pc
                        if( aluop(insn).is_r2pc ) {
                            upc = rst0 >> 1;
                        } else {
                            upc = pc_plus_1;
                        }
                        
                        // n2memt mem[t] = n
                        if( aluop(insn).is_n2memt ) {
                            if( ust0 < 16384 ) {
                                charout = 119; // DEBUG w
                                sram_addr = ust0 >> 1;
                                sram_data_in = st1;
                                sram_wren = 1;
                            } else {
                                charout = 111; // DEBUG o
                                uart_in_data = bytes(st1).byte0;
                                uart_in_valid = 1;
                                BLUE = ~BLUE;
                            }
                        }
                    }
                }
                
                // DEBUG after execute
                case 24: {
                    // DEBUG
                    //uart_in_data = charout;
                    //uart_in_valid = 1;
                }

                // Write to dstack and rstack
                case 29: {
                    if( udstkW ) {
                        dstack[udsp] = st0;
                        RED = ~RED;
                    }
                    if( urstkW ) {
                        rstack[ursp] = urstkD;
                        GREEN = ~GREEN;
                    }
                }
               
                // Update dsp, rsp, pc, st0
                case 30: {
                    dsp = udsp;
                    pc = upc;
                    st0 = ust0;
                    rsp = ursp;
                }
                
                // reset sram_wren
                case 31: {
                    sram_wren = 0;
                }
                
                default: {}
                
            } // switch(cycle)
        } // case(init=2)
        
    } // switch(init)   

    // Reset UART
    if(uart_in_ready & uart_in_valid) {
        uart_in_valid = 0;
    }
   
    cycle = cycle + 1;
    } // while(1)
}
