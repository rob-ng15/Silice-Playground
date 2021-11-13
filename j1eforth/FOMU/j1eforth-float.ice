// INCLUDE FLOATING POINT CO-PROCESSOR - USING 16 bit FLOATS TO FIT WITHIN WORD SIZE
$include('float16.ice')

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

// UART BUFFER CONTROLLER
// 256 entry FIFO queue
algorithm fifo(
    output  uint1   available,
    output  uint1   full,
    input   uint1   read,
    input   uint1   write,
    output  uint8   first,
    input   uint8   last
) <autorun,reginputs> {
    simple_dualport_bram uint8 queue[256] = uninitialized;
    uint1   update = uninitialized;
    uint8   top = 0;
    uint8   next = 0;

    available := ( top != next ); full := ( top + 1 == next );
    queue.addr0 := next; first := queue.rdata0;
    queue.wenable1 := 1;

    always {
        if( write ) {
            queue.addr1 = top; queue.wdata1 = last;
            update = 1;
        } else {
            if( update ) {
                top = top + 1;
                update = 0;
            }
        }
        next = next + read;
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
    // 16bit ROM with included compiled j1eForth from https://github.com/samawati/j1eforth
    brom uint16 rom[] = {
        $include('j1eforthROM.inc')
    };

    // INIT to determine if copying rom to ram or executing
    // INIT 0 SPRAM, INIT 1 ROM to SPRAM, INIT 3 J1 CPU
    uint2   INIT = 0;

    // Address for 0 to SPRAM, copying ROM
    uint16  copyaddress = uninitialized;
    uint16  nextcopyaddress <:: copyaddress + 1;

    // J1 CPU
    uint16  instruction = uninitialized;
    uint1   is_lit = uninitialized;
    uint1   is_alu = uninitialized;
    uint1   is_call = uninitialized;
    uint1   is_n2memt = uninitialized;
    uint1   is_memtr = uninitialized;
    uint2   is_callbranchalu = uninitialized;
    uint1   dstackWrite = uninitialized;
    uint1   rstackWrite = uninitialized;
    uint8   ddelta = uninitialized;
    uint8   rdelta = uninitialized;
    decode DECODE(
        instruction <: instruction,
        is_lit :> is_lit,
        is_call :> is_call,
        is_alu :> is_alu,
        is_n2memt :> is_n2memt,
        is_memtr :> is_memtr,
        dstackWrite :> dstackWrite,
        rstackWrite :> rstackWrite,
        ddelta :> ddelta,
        rdelta :> rdelta
    );

    // program counter
    uint13  pc = uninitialized;
    uint13  pcPlusOne <:: pc + 1;
    uint13  newPC = 0;

    // dstack 257x16bit (as 3256 array + stackTop) and pointer, next pointer, write line, delta
    uint16  stackTop = uninitialized;
    uint16  stackNext = uninitialized;
    uint8   dsp = uninitialized;
    uint8   newDSP = 0;
    uint16  newStackTop = 0;
    stack DSTACK( stackWData <: stackTop, sp <: dsp, newSP <: newDSP, stackTop :> stackNext );
    deltasp DELTADSP( sp <: dsp, delta <: ddelta );

    // rstack 256x16bit and pointer, next pointer, write line
    uint16  rStackTop = uninitialized;
    uint8   rsp = uninitialized;
    uint8   newRSP = 0;
    uint16  rstackWData = uninitialized;
    stack RSTACK( stackWData <: rstackWData, sp <: rsp, newSP <: newRSP, stackTop :> rStackTop );
    deltasp DELTARSP( sp <: rsp, delta <: rdelta );

    uint16  memoryinput = uninitialized;
    alu ALU(
        instruction <: instruction,
        memoryRead <: memoryinput,
        stackTop <: stackTop,
        stackNext <: stackNext,
        rStackTop <: rStackTop,
        dsp <: dsp,
        rsp <: rsp
    );

    j1eforthcallbranch CALLBRANCH(
        instruction <: instruction,
        stackTop <: stackTop,
        stackNext <: stackNext,
        pc <: pc,
        pcPlusOne <: pcPlusOne,
        dsp <: dsp,
        rsp <: rsp
    );

    float16 FPU();

    uart UART(
        uart_in_data :> uart_in_data,
        uart_in_valid :> uart_in_valid,
        uart_in_ready <: uart_in_ready,
        uart_out_data <: uart_out_data,
        uart_out_valid <: uart_out_valid,
        uart_out_ready :> uart_out_ready,
        outchar <: bytes(stackNext).byte0
    );

    sram_data_write := ( ~|INIT ) ? 0 : ( ^INIT ) ? rom.rdata : stackNext;
    sram_readwrite := 0;

    FPU.start := 0;

    // UART
    UART.read := 0; UART.write := 0;

    // INIT is 0 ZERO SPRAM
    copyaddress = 0;
    while( ~copyaddress[15,1] ) {
        sram_address = copyaddress;
        sram_readwrite = 1;
        ++:
        copyaddress = nextcopyaddress;
    }
    INIT = 1;

    // INIT is 1 COPY ROM TO SPRAM
    copyaddress = 0;
    while( ~copyaddress[12,1] ) {
        rom.addr = copyaddress;
        ++:
        sram_address = copyaddress;
        sram_readwrite = 1;
        ++:
        copyaddress = nextcopyaddress;
        ++:
    }
    INIT = 3;

    // INIT is 3 EXECUTE J1 CPU
    while( 1 ) {
        // Update dsp, rsp, pc, stackTop
        dsp = newDSP;
        pc = newPC;
        stackTop = newStackTop;
        rsp = newRSP;

        // start READ instruction = [pc] result ready in 2 cycles
        sram_address = pc;
        ++:
        ++:
        ++:
        // wait then read the instruction from SPRAM and DECODE
        instruction = sram_data_read;
        ++:

        // start READ memoryInput = [stackTop]
        if( is_memtr & ~stackTop[15,1] ) {
            sram_address = stackTop >> 1;
            ++:
            ++:
            ++:
            // wait then read the data from SPRAM
            memoryinput = sram_data_read;
            ++:
        } else {}

        // J1 CPU Instruction Execute
        if( is_lit ) {
            // LITERAL
            newStackTop = literal(instruction).literalvalue;
            newPC = pcPlusOne;
            newDSP = dsp + 1;

            // Commit to dstack and rstack
            DSTACK.stackWrite = dstackWrite;
        } else {
            if( is_alu ) {
                if( is_memtr & stackTop[15,1] ) {
                    switch( stackTop[0,4] ) {
                        case 4h0: { newStackTop = { 8b0, UART.inchar }; UART.read = 1; }
                        case 4h1: { newStackTop = { 14b0, UART.full, UART.available }; }
                        case 4h2: { newStackTop = rgbLED; }
                        case 4h3: { newStackTop = { 12b0, buttons }; }
                        case 4h4: { newStackTop = timer1hz; }
                        case 4h7: { newStackTop = FPU.busy; }
                        case 4h8: { newStackTop = FPU.itof; }
                        case 4h9: { newStackTop = FPU.ftoi; }
                        case 4ha: { newStackTop = FPU.fadd; }
                        case 4hb: { newStackTop = FPU.fmul; }
                        case 4hc: { newStackTop = FPU.fdiv; }
                        case 4hd: { newStackTop = FPU.fsqrt; }
                        case 4he: { newStackTop = FPU.less; }
                        case 4hf: { newStackTop = FPU.equal; }
                        default: {}
                    }
                } else {
                    newStackTop = ALU.newStackTop;
                    rstackWData = stackTop;
                }

                // UPDATE newDSP newRSP
                newDSP = DELTADSP.newSP;
                newRSP = DELTARSP.newSP;

                // Update PC for next instruction, return from call or next instruction
                newPC = ( aluop(instruction).is_r2pc ) ? {1b0, rStackTop[1,15] } : pcPlusOne;

                // n2memt mem[t] = n
                if( is_n2memt ) {
                    if( stackTop[15,1] ) {
                        switch( stackTop[0,3] ) {
                            case 3h0: { UART.write = 1; }
                            case 3h2: { rgbLED = stackNext;  }
                            case 3h5: { FPU.a = stackNext; }
                            case 3h6: { FPU.b = stackNext; }
                            case 3h7: { FPU.start = stackNext; }
                            default: {}
                        }
                    } else {
                        // WRITE to SPRAM
                        sram_address = stackTop >> 1;
                        sram_readwrite = 1;
                        ++:
                    }
                }

            } else {
                // CALL BRANCH 0BRANCH
                newStackTop = CALLBRANCH.newStackTop;
                newPC = CALLBRANCH.newPC;
                newDSP = CALLBRANCH.newDSP;
                newRSP = CALLBRANCH.newRSP;
                rstackWData = { pcPlusOne, 1b0 };
            }
            // Commit to dstack and rstack
            DSTACK.stackWrite = dstackWrite;
            RSTACK.stackWrite = rstackWrite;
        } // J1 CPU Instruction Execute
    } // (INIT==3 execute J1 CPU)}
}

algorithm add16(
    input   uint16  a,
    input   uint16  b,
    output  uint16  c
) <autorun,reginputs> {
    always {
        c = a + b;
    }
}
algorithm logic16(
    input   uint16  a,
    input   uint16  b,
    output  uint16  AND,
    output  uint16  OR,
    output  uint16  XOR
) <autorun,reginputs> {
    always {
        AND = a & b;
        OR = a | b;
        XOR = a ^ b;
    }
}
algorithm shift16(
    input   uint16  a,
    input   uint4   count,
    output  uint16  SLL,
    output  uint16  SRA
) <autorun,reginputs> {
    always {
        SLL = a << count;
        SRA = __signed(a) >>> count;
    }
}
algorithm alu(
    input   uint16  instruction,
    input   uint16  stackTop,
    input   uint16  stackNext,
    input   uint16  rStackTop,
    input   uint8   dsp,
    input   uint8   rsp,
    input   uint16  memoryRead,
    output  uint16  newStackTop
) <autorun,reginputs> {
    int16   negTop <:: -stackTop;
    compare COMPARE( stackTop <: stackTop, stackNext <: stackNext );
    add16 ADD( a <: stackTop, b <: stackNext );
    add16 SUB( a <: stackNext, b <: negTop );
    add16 INC( a <: stackTop );
    add16 DEC( a <: stackTop );
    logic16 LOGIC( a <: stackTop, b <: stackNext );
    shift16 SHIFT( a <: stackNext, count <: nibbles(stackTop).nibble0 );

    always {
        if( aluop(instruction).is_j1j1plus ) {
            switch( aluop(instruction).operation ) {
                case 4b0000: { newStackTop = {16{ COMPARE.equal0 }}; }
                case 4b0001: { newStackTop = {16{ ~COMPARE.equal0 }}; }
                case 4b0010: { newStackTop = {16{ ~COMPARE.equal }}; }
                case 4b0011: { newStackTop = INC.c; }
                case 4b0100: { newStackTop = { stackTop[0,15], 1b0 }; }
                case 4b0101: { newStackTop = { stackTop[15,1], stackTop[1,15]}; }
                case 4b0110: { newStackTop = {16{~COMPARE.less & ~COMPARE.equal}}; }
                case 4b0111: { newStackTop = {16{~COMPARE.lessu & ~COMPARE.equal}}; }
                case 4b1000: { newStackTop = {16{stackTop[15,1]}}; }
                case 4b1001: { newStackTop = {16{~stackTop[15,1]}}; }
                case 4b1010: { newStackTop = stackTop[15,1] ? negTop : stackTop; }
                case 4b1011: { newStackTop = COMPARE.less ? stackTop : stackNext; }
                case 4b1100: { newStackTop = COMPARE.less ? stackNext : stackTop; }
                case 4b1101: { newStackTop = negTop; }
                case 4b1110: { newStackTop = SUB.c; }
                case 4b1111: { newStackTop = {16{~COMPARE.less}}; }
            }
        } else {
            switch( aluop(instruction).operation ) {
                case 4b0000: { newStackTop = stackTop; }
                case 4b0001: { newStackTop = stackNext; }
                case 4b0010: { newStackTop = ADD.c; }
                case 4b0011: { newStackTop = LOGIC.AND; }
                case 4b0100: { newStackTop = LOGIC.OR; }
                case 4b0101: { newStackTop = LOGIC.XOR; }
                case 4b0110: { newStackTop = ~stackTop; }
                case 4b0111: { newStackTop = {16{COMPARE.equal}}; }
                case 4b1000: { newStackTop = {16{COMPARE.less}}; }
                case 4b1001: { newStackTop = SHIFT.SRA; }
                case 4b1010: { newStackTop = DEC.c; }
                case 4b1011: { newStackTop = rStackTop; }
                case 4b1100: { newStackTop = memoryRead; }
                case 4b1101: { newStackTop = SHIFT.SLL; }
                case 4b1110: { newStackTop = {rsp, dsp}; }
                case 4b1111: { newStackTop = {16{COMPARE.lessu}}; }
            }
        }
    }

    INC.b = 1; DEC.b = -1;
}

algorithm compare(
    input   uint16  stackTop,
    input   uint16  stackNext,
    output  uint1   equal,
    output  uint1   lessu,
    output  uint1   less,
    output  uint1   equal0,
) <autorun,reginputs> {
    always {
        equal = stackNext == stackTop;
        lessu = __unsigned(stackNext) < __unsigned(stackTop);
        less = __signed(stackNext) < __signed(stackTop);
        equal0 = ~|stackTop;
    }
}

algorithm j1eforthcallbranch(
    input   uint16  instruction,
    input   uint16  stackTop,
    input   uint16  stackNext,
    input   uint13  pc,
    input   uint13  pcPlusOne,
    input   uint8   dsp,
    input   uint8   rsp,

    output  uint16  newStackTop,
    output  uint13  newPC,
    output  uint8   newDSP,
    output  uint8   newRSP,
) <autorun,reginputs> {
    always {
        newStackTop = callbranch(instruction).is_callbranchalu[0,1] ? stackNext : stackTop;
        newDSP = dsp - callbranch(instruction).is_callbranchalu[0,1];
        newRSP = rsp + callbranch(instruction).is_callbranchalu[1,1];
        newPC = callbranch(instruction).is_callbranchalu[0,1] & ( |stackTop ) ? pcPlusOne : callbranch(instruction).address;
    }
}

algorithm decode(
    input   uint16  instruction,
    output  uint1   is_lit,
    output  uint1   is_call,
    output  uint1   is_alu,
    output  uint1   is_n2memt,
    output  uint1   is_memtr,
    output  uint1   dstackWrite,
    output  uint1   rstackWrite,
    output  uint8   ddelta,
    output  uint8   rdelta
) <autorun,reginputs> {
    always {
        is_lit = literal(instruction).is_literal;
        is_call = ~is_lit & ( callbranch(instruction).is_callbranchalu == 2b10 );
        is_alu = ~is_lit & ( &callbranch(instruction).is_callbranchalu );
        is_n2memt = is_alu & aluop(instruction).is_n2memt;
        is_memtr = is_alu & ~aluop(instruction).is_j1j1plus & ( aluop(instruction).operation == 4b1100 );
        dstackWrite = ( is_lit | ( is_alu & aluop(instruction).is_t2n ) );
        rstackWrite = ( is_call | ( is_alu & aluop(instruction).is_t2r ) );
        ddelta = { {7{aluop(instruction).ddelta1}}, aluop(instruction).ddelta0 };
        rdelta = { {7{aluop(instruction).rdelta1}}, aluop(instruction).rdelta0 };
    }
}

algorithm stack(
    input   uint16  stackWData,
    input   uint1   stackWrite,
    input   uint8   sp,
    input   uint8   newSP,
    output  uint16  stackTop
) <autorun,reginputs> {
    simple_dualport_bram uint16 stack[256] = uninitialized; // bram (code from @sylefeb)
    stack.addr0 := sp;
    stack.wenable1 := 1;
    stackTop := stack.rdata0;

    always {
        if( stackWrite ) { stack.addr1 = newSP; stack.wdata1 = stackWData; }
    }
}

algorithm deltasp(
    input   uint8   sp,
    input   uint8   delta,
    output  uint8   newSP
) <autorun,reginputs> {
    always {
        newSP = sp + delta;
    }
}

algorithm float16(
    input   uint16  a,
    input   uint16  b,
    output  uint16  itof,
    output  int16   ftoi,
    output  uint16  fadd,
    output  uint16  fmul,
    output  uint16  fdiv,
    output  uint16  fsqrt,
    output  uint1   less,
    output  uint1   equal,
    input   uint3   start,
    output  uint1   busy(0)
) <autorun,reginputs> {
    inttofloat ITOF( a <: a, result :> itof );
    floattoint FTOI( a <: a, result :> ftoi );
    floataddsub FADD( a <: a, b <: b, result :> fadd );
    floatmultiply FMUL( a <: a, b <: b, result :> fmul );
    floatdivide FDIV( a <: a, b <: b, result :> fdiv );
    floatsqrt FSQRT( a <: a, result :> fsqrt );
    floatcompare FCOMPARE( a <: a, b <: b, less :> less, equal :> equal );

    busy := FADD.busy | FMUL.busy | FDIV.busy | FSQRT.busy;
    FADD.start := 0; FMUL.start := 0; FDIV.start := 0; FSQRT.start := 0;

    always {
        switch( start ) {
            default: {}
            case 3: { FADD.addsub = 0; FADD.start = 1; }
            case 4: { FADD.addsub = 1; FADD.start = 1; }
            case 5: { FMUL.start = 1; }
            case 6: { FDIV.start = 1; }
            case 7: { FSQRT.start = 1; }
        }
    }
    ITOF.dounsigned = 0;
}

algorithm uart(
    // UART Interface
    output  uint8  uart_in_data,
    output  uint1  uart_in_valid,
    input   uint1  uart_in_ready,
    input   uint8  uart_out_data,
    input   uint1  uart_out_valid,
    output  uint1  uart_out_ready,

    output  uint1   full,
    output  uint1   available,

    output  uint8   inchar,
    input   uint1   read,

    input   uint8   outchar,
    input   uint1   write
) <autorun> {
    uint9   OUTtop1 <:: uartOutBufferTop + 1;
    uint9   OUTnext1 <:: uartOutBufferNext + 1;
    uint9   INtop1 <:: uartInBufferTop + 1;
    uint9   INnext1 <:: uartInBufferNext + 1;

    // UART input FIFO (512 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartInBuffer[512] = uninitialized;
    uint9 uartInBufferNext = 0;
    uint9 uartInBufferTop = 0;

    // UART output FIFO (512 character) as dualport bram (code from @sylefeb)
    simple_dualport_bram uint8 uartOutBuffer[512] = uninitialized;
    uint9 uartOutBufferNext = 0;
    uint9 uartOutBufferTop = 0;
    uint9 newuartOutBufferTop = 0;

    // UART input and output buffering
    uartInBuffer.wenable1  := 1;  // always write on port 1
    uartInBuffer.addr0     := uartInBufferNext; // FIFO reads on next
    uartInBuffer.addr1     := uartInBufferTop;  // FIFO writes on top
    uartOutBuffer.wenable1 := 1; // always write on port 1
    uartOutBuffer.addr0    := uartOutBufferNext; // FIFO reads on next
    uartOutBuffer.addr1    := uartOutBufferTop;  // FIFO writes on top
    uartInBuffer.wdata1  := uart_out_data;

    full := ( OUTtop1 == uartOutBufferNext );
    available := ( uartInBufferNext != uartInBufferTop );
    inchar := uartInBuffer.rdata0;

    always {
        if( read ) { uartInBufferNext = INnext1; }
        if( uart_out_valid ) { uartInBufferTop = INtop1; uart_out_ready = 1; }
        if( uart_in_ready & uart_in_valid ) { uart_in_valid = 0; }
    }

    while( 1 ) {
        // WRITE to UART if characters in buffer and UART is ready
        if( write ) {
            uartOutBuffer.wdata1 = outchar;
            uartOutBufferTop = OUTtop1;
        } else {
            if( ( uartOutBufferNext != uartOutBufferTop ) & ~uart_in_valid ) {
                // reads at uartOutBufferNext (code from @sylefeb)
                uart_in_data      = uartOutBuffer.rdata0;
                uart_in_valid     = 1;
                uartOutBufferNext = OUTnext1;
            }
        }
    }
}
