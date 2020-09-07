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

bitfield msb15bits {
    uint15  msb15,
    uint1   lsb
}
bitfield lsb15bits {
    uint1   lsb,
    uint15  lsb15
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
    uint16  immediate := {1b0, literal(insn).value};
    uint1   is_alu := (instruction(insn).is_litcallbranchalu == 3b011);
    uint1   is_lit := (literal(insn).is_literal);
    uint2   dd := aluop(insn).ddelta;
    uint2   rd := aluop(insn).rdelta;
    
    uint5   dsp = 0;
    uint5   udsp = 0;
    uint16  st0 = 0;
    uint16  ust0 = 0;
    uint1   udstkW := is_lit | (is_alu & bits(insn).bit7);
    
    uint16  pc = 0;
    uint16  upc = 0;
    uint5   rsp = 0;
    uint5   ursp = 0;
    uint1   urstkW = 0;
    uint16  urstkD = 0;
    uint1   uramWE := is_alu & bits(insn).bit5;

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
    uint5 cycle = 0;
    // INIT 0 SPRAM, INIT 1 ROM to SPRAM, INIT 2 J1 CPU
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
    
    // Start of main loop
    while(1) {
        rgbB = BLUE;
        rgbG = GREEN;
        rgbR = RED;
        
    switch(init) {
        // ZERO SPRAM
        case 0: {
            GREEN = 1;
            switch(cycle) {
                case 0: {
                    // Setup WRITE to SPRAM
                    sram_addr = copyaddress;
                    sram_data_in = 0;
                    sram_wren = 1;
                }
                case 30: {
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
            RED = 1;
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
                }
                case 31: {
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

            switch(cycle) {
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
                
                // WRITE [ust0] = st1 or to UART
                case 3: {
                    if(uramWE) {
                        if({bits(ust0).bit15, bits(ust0).bit14} == 0) {
                            sram_addr = msb15bits(ust0).msb15;
                            sram_data_in = st1;
                            sram_wren = 1;
                        } else {
                            uart_in_data = bytes(st1).byte0;
                            uart_in_valid = 1;
                        }
                    }
                }

                // READ mem_din = [ust0]
                case 11: {
                    sram_addr = msb15bits(ust0).msb15;
                    sram_wren = 0;
                }
                case 19: {
                    mem_din = sram_data_out;
                }
                
                // READ insn = [upc]
                case 20: {
                    sram_addr = upc;
                    sram_wren = 0;
                }
                case 28: {
                    insn = sram_data_out;
                }

                // DECODE insn
                case 29: {
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
                case 30: {
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
                    
                    if(literal(insn).is_literal) {
                        // Push value onto stack
                        ust0 = immediate;
                    }
                    if(is_alu) {
                        switch (aluop(insn).operation) {
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
                                if(|{bits(st0).bit15, bits(st0).bit14}) {
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
                    // Calculate new values for dsp, rsp and calculate if writes required
                    // Calculate new pc
                    if(is_lit) {
                        udsp = dsp + 1;
                        ursp = rsp;
                        urstkW = 0;
                        urstkD = upc;
                    } else { 
                        if(is_alu) {
                            udsp = dsp + {twobits(dd).bit1, twobits(dd).bit1, twobits(dd).bit1, dd};
                            ursp = rsp + {twobits(rd).bit1, twobits(rd).bit1, twobits(rd).bit1, rd};
                            urstkW = bits(insn).bit6;
                            urstkD = st0;
                        } else {
                            if(instruction(insn).is_litcallbranchalu == 3b001) {
                                udsp = dsp - 1;
                            } else {
                                udsp = dsp;
                            }
                        }
                        if(instruction(insn).is_litcallbranchalu == 3b010) {
                            ursp = rsp + 1;
                            urstkW = 1;
                            urstkD = {lsb15bits(pc_plus_1).lsb15, 1b0};
                        } else {
                            ursp = rsp;
                            urstkW = 0;
                            urstkD = upc;
                        }
                    }
                    if( ((instruction(insn).is_litcallbranchalu == 3b000) | ((instruction(insn).is_litcallbranchalu == 3b001) & (|st0 == 0)) | (instruction(insn).is_litcallbranchalu == 3b010)) ) {
                        upc = {3b000,callbranch(insn).address};
                    } else {
                        if(is_alu & bits(insn).bit12) {
                            upc = msb15bits(rst0).msb15;
                        } else {
                            upc = pc_plus_1;
                        }
                    }
                } // J1 CPU Instruction Execute
                
                // Reset UART
                case 31: {
                    if(uart_in_ready & uart_in_valid) {
                        uart_in_valid = 0;
                    }
                }

                default: {}
                
            } // switch(cycle)
        } // case(init=2)
        
    } // switch(init)   
    
    cycle = cycle + 1;
    } // while(1)
}
