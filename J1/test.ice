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
    uint16  insn = 0;
    uint16  immediate := {1b0, insn[14,15]};
    uint1   is_alu := (insn[15,3] == 3b011);
    uint1   is_lit := (insn[15,1]);
    uint2   dd := aluop(insn).ddelta;
    uint2   rd := aluop(insn).rdelta;
    
    uint5   dsp = 0;
    uint5   udsp = 0;
    uint16  st0 = 0;
    uint16  ust0 = 0;
    uint1   udstkW := is_lit | (is_alu & insn[7,1]);
    
    uint13  pc = 0;
    uint13  upc = 0;
    uint5   rsp = 0;
    uint5   ursp = 0;
    uint1   urstkW = 0;
    uint16  urstkD = 0;
    uint1   uramWE := is_alu & insn[5,1];

    uint16  st1 = 0;
    uint16  rst0 = 0;
    uint16  pc_plus_1 := pc + 1;
    uint16  mem_din = 0;
    
    uint4 st0sel = 0;
    
    // dstack 32x16bit and pointer, next pointer, write line, delta
    // rstack 32x16bit and pointer, next pointer, write line, delta
    uint16 dstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    uint16 rstack[32] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    
    // 16bit ROM with included compiled j1eForth from https://github.com/samawati/j1eforth
    bram uint16 rom[] = {
        $include('j1eforth16msb.inc')
    };
    
    // cycle to control each stage, init to determine if copying rom to ram or executing
    uint24 cycle = 0;
    // INIT 0 SPRAM, INIT 1 ROM to SPRAM, INIT 2 J1 CPU
    uint2 init = 0;
    // BLUE heartbeat
    uint1 BLUE := cycle[23,1];
    // GREEN whilst 0 to SPRAM and alu heartbeat
    uint1 GREEN = 0;
    // RED whilst copying ROM to SRAM
    uint1 RED = 0;      
    // Address for 0 to SPRAM, copying ROM, plus storage
    uint16 copyaddress = 0;
    uint16 memory_read = 0;
    
    // Start of main loop
    while(1) {
        rgbB = BLUE;
        rgbG = GREEN;
        rgbR = RED;
        
    switch(init) {
        // ZERO SPRAM
        case 0: {
            GREEN = 1;
            switch(cycle[3,4]) {
                case 0: {
                    // Setup WRITE to SPRAM
                    sram_addr = copyaddress;
                    sram_data_in = 0;
                    sram_wren = 1;
                }
                case 14: {
                    copyaddress = copyaddress + 1;
                }
                case 15: {
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
            RED = 1;
            switch(cycle[3,4]) {
                case 0: {
                    // Setup READ from ROM
                    rom.addr = copyaddress;
                    rom.wenable = 0;
                }
                case 1: {
                    // READ from ROM
                    memory_read = rom.rdata;
                }
                case 2: {
                    // WRITE to SPRAM
                    sram_addr = copyaddress;
                    sram_data_in = memory_read;
                    sram_wren = 1;
                }
                case 14: {
                    copyaddress = copyaddress + 1;
                }
                case 15: {
                    if(copyaddress == 3336) {
                        init = 2;
                        copyaddress = 0;
                    }
                }
                default: {
                }
            }
        }
    
        // EXECUTE J1 CPU
        case 2: {
            RED = 0;

//            DEBUG ASSISTANT
//            // On UART data available, echo instruction
//            if(uart_out_valid) {
//                uart_in_data = pc[3,4] + 65;
//                uart_in_valid = 1;
//                uart_out_ready = 1;
//            }
//            // reset to allow new uart data
//            if(uart_in_ready & uart_in_valid) {
//                uart_in_valid = 0;
//            }

            switch(cycle[3,4]) {
                // Write to dstack and rstack
                case 0: {
                    if(udstkW) {
                        dstack[udsp] = st0;
                    }
                    if(urstkW) {
                        rstack[ursp] = urstkD;
                    }
                }
                
                // Update dsp, rsp, pc, st0
                case 1: {
                    dsp = udsp;
                    pc = upc;
                    st0 = ust0;
                    rsp = ursp;
                }
                
                // WRITE [ust0] = st1
                case 3: {
                    if(uramWE & (ust0[15,2] == 0)) {
                        sram_addr = {1b0,ust0[15,15]};
                        sram_data_in = st1[15,16];
                        sram_wren = 1;
                    }
                }

                // READ mem_din = [ust0]
                case 6: {
                    sram_addr = {1b0,ust0[15,15]};
                    sram_wren = 0;
                }
                case 8: {
                    mem_din = sram_data_out;
                }
                
                // READ insn = [upc]
                case 9: {
                    sram_addr = {2b00,upc};
                    sram_wren = 0;
                }
                case 11: {
                    insn = sram_data_out;
                }

                // DECODE insn
                case 12: {
                    switch(callbranch(insn).is_callbranchalu) {
                        case 2b00:  {st0sel = 0;}                         // ubranch
                        case 2b10:  {st0sel = 0;}                         // call
                        case 2b01:  {st0sel = 1;}                         // 0branch
                        case 2b11:  {st0sel = aluop(insn).operation;}     // ALU 
                        default:    {st0sel = 4bxxxx;}
                    }
                    st1 = dstack[dsp];
                    rst0 = rstack[rsp];

                }
                // J1 CPU Instruction Execute
                case 13: {
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
                    
                    if(insn[15,1]) {
                        // Push value onto stack
                        ust0 = immediate;
                    } else {
                        switch (st0sel) {
                            case 4b0000: {ust0 = st0;}
                            case 4b0001: {ust0 = st1;}
                            case 4b0010: {ust0 = st0 + st1;}
                            case 4b0011: {ust0 = st0 & st1;}
                            case 4b0100: {ust0 = st0 | st1;}
                            case 4b0101: {ust0 = st0 ^ st1;}
                            case 4b0110: {ust0 = ~st0;}
                            case 4b0111: {ust0 = {16{(st1 == st0)}};}
                            case 4b1000: {ust0 = {16{(__signed(st1) < __signed(st0))}};}
                            case 4b1001: {ust0 = st1 >> nibbles(st0).nibble0;}
                            case 4b1010: {ust0 = st0 - 1;}
                            case 4b1011: {ust0 = rst0;}
                            case 4b1100: {
                                // UART or mem_din
                                if(|st0[15,2]) {
                                    if(uart_out_valid) {
                                        ust0 = {8b0, uart_out_data};
                                        uart_out_ready = 1;
                                    } else {
                                        ust0 = 0;
                                    }
                                } else {
                                    ust0 = mem_din;
                                }
                            }
                            case 4b1101: {ust0 = st1 << nibbles(st0).nibble0;}
                            case 4b1110: {ust0 = {rsp, 3b000, dsp};}
                            case 4b1111: {ust0 = {16{(st1 < st0)}};}
                            default: {ust0 = 16hxxxx;}
                        }
                    }
                } // J1 CPU Instruction Execute
                
                // Calculate new values for dsp, rsp and calculate if writes required
                // Calculate new pc
                case 14: {
                    if(is_lit) {
                        udsp = dsp + 1;
                        ursp = rsp;
                        urstkW = 0;
                        urstkD = upc;
                    } else { 
                        if(is_alu) {
                            udsp = dsp + {twobits(dd).bit1, twobits(dd).bit1, twobits(dd).bit1, dd};
                            ursp = rsp + {twobits(rd).bit1, twobits(rd).bit1, twobits(rd).bit1, rd};
                            urstkW = insn[6,1];
                            urstkD = st0;
                        } else {
                            if(insn[15,3] == 3b001) {
                                udsp = dsp - 1;
                            } else {
                                udsp = dsp;
                            }
                        }
                        if(insn[15,3] == 3b010) {
                            ursp = rsp + 1;
                            urstkW = 1;
                            urstkD = {pc_plus_1[14,15], 1b0};
                        } else {
                            ursp = rsp;
                            urstkW = 0;
                            urstkD = upc;
                        }
                    }
                    if( ((insn[15,3] == 3b000) | ((insn[15,3] == 3b001) & (|st0 == 0)) | (insn[15,3] == 3b010)) ) {
                        upc = insn[12,13];
                    } else {
                        if(is_alu & insn[12,1]) {
                            upc = rst0[15,15];
                        } else {
                            upc = pc + 1;
                        }
                    }
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
        } // case(init=2)
        
    } // switch(init)   
    
    cycle = cycle + 1;
    } // while(1)
}
