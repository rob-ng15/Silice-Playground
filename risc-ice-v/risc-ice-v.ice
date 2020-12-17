// RISC-ICE-V
// inspired by https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice
//
// A simple Risc-V RV32I processor

// RISC-V BASE INSTRUCTION BITFIELDS
bitfield    Btype {
    uint1   immediate_bits_12,
    uint6   immediate_bits_10_5,
    uint5   sourceReg2,
    uint5   sourceReg1,
    uint3   function3,
    uint4   immediate_bits_4_1,
    uint1   immediate_bits_11,
    uint7   opcode
}

bitfield    Itype {
    uint12  immediate,
    uint5   sourceReg1,
    uint3   function3,
    uint5   destReg,
    uint7   opcode
}

bitfield    ItypeSHIFT {
    uint7   function7,
    uint5   shiftCount,
    uint5   sourceReg1,
    uint3   function3,
    uint5   destReg,
    uint7   opcode
}

bitfield    Jtype {
    uint1   immediate_bits_20,
    uint10  immediate_bits_10_1,
    uint1   immediate_bits_11,
    uint8   immediate_bits_19_12,
    uint5   destReg,
    uint7   opcode
}

bitfield    Rtype {
    uint7   function7,
    uint5   sourceReg2,
    uint5   sourceReg1,
    uint3   function3,
    uint5   destReg,
    uint7   opCode
}

bitfield Stype {
    uint7   immediate_bits_11_5,
    uint5   sourceReg2,
    uint5   sourceReg1,
    uint3   function3,
    uint5   immediate_bits_4_0,
    uint7   opcode
}

bitfield Utype {
    uint20  immediate_bits_31_12,
    uint5   destReg,
    uint7   opCode
}

// COMPRESSED Risc-V Instruction Bitfields
bitfield    CBalu {
    uint3   function3,
    uint1   ib_5,
    uint2   function2,
    uint3   rd_alt,
    uint2   logical2,
    uint3   rs2_alt,
    uint2   opcode
}
bitfield    CBalu50 {
    uint3   function3,
    uint1   ib_5,
    uint2   function2,
    uint3   rd_alt,
    uint5   ib_4_0,
    uint2   opcode
}
bitfield    CB {
    uint3   function3,
    uint1   offset_8,
    uint2   offset_4_3,
    uint3   rs1_alt,
    uint2   offset_7_6,
    uint2   offset_2_1,
    uint1   offset_5,
    uint2   opcode
}

bitfield    CI {
    uint3   function3,
    uint1   ib_5,
    uint5   rd,
    uint3   ib_4_2,
    uint2   ib_7_6,
    uint2   opcode
}
bitfield    CI50 {
    uint3   function3,
    uint1   ib_5,
    uint5   rd,
    uint5   ib_4_0,
    uint2   opcode
}
bitfield    CI94 {
    uint3   function3,
    uint1   ib_9,
    uint5   rd,
    uint1   ib_4,
    uint1   ib_6,
    uint2   ib_8_7,
    uint1   ib_5,
    uint2   opcode
}
bitfield    CIu94 {
    uint3   function3,
    uint2   ib_5_4,
    uint4   ib_9_6,
    uint1   ib_2,
    uint1   ib_3,
    uint3   rd_alt,
    uint2   opcode
}
bitfield    CIlui {
    uint3   function3,
    uint1   ib_17,
    uint5   rd,
    uint5   ib_16_12,
    uint2   opcode
}

bitfield    CJ {
    uint3   function3,
    uint1   ib_11,
    uint1   ib_4,
    uint2   ib_9_8,
    uint1   ib_10,
    uint1   ib_6,
    uint1   ib_7,
    uint3   ib_3_1,
    uint1   ib_5,
    uint2   opcode
}

bitfield    CL {
    uint3   function3,
    uint3   ib_5_3,
    uint3   rs1_alt,
    uint1   ib_2,
    uint1   ib_6,
    uint3   rd_alt,
    uint2   opcode
}

bitfield    CR {
    uint4   function4,
    uint5   rs1,
    uint5   rs2,
    uint2   opcode
}

bitfield    CS {
    uint3   function3,
    uint1   ib_5,
    uint2   ib_4_3,
    uint3   rs1_alt,
    uint1   ib_2,
    uint1   ib_6,
    uint3   rs2_alt,
    uint2   opcode
}

bitfield    CSS {
    uint3   function3,
    uint1   ib_5,
    uint3   ib_4_2,
    uint2   ib_7_6,
    uint5   rs2,
    uint2   opcode
}

algorithm main(
    // LEDS (8 of)
    output  uint8   leds,
    input   uint$NUM_BTNS$ btns,

    // HDMI OUTPUT
    output  uint4   gpdi_dp,
    output  uint4   gpdi_dn,

    // UART
    output! uint1   uart_tx,
    input   uint1   uart_rx,

    // AUDIO
    output! uint4   audio_l,
    output! uint4   audio_r,

    // SDCARD
    output! uint1   sd_clk,
    output! uint1   sd_mosi,
    output! uint1   sd_csn,
    input   uint1   sd_miso,

    // SDRAM
    output uint1  sdram_cle,
    output uint2  sdram_dqm,
    output uint1  sdram_cs,
    output uint1  sdram_we,
    output uint1  sdram_cas,
    output uint1  sdram_ras,
    output uint2  sdram_ba,
    output uint13 sdram_a,
    output uint1  sdram_clk,  // sdram chip clock != internal sdram_clock
    inout  uint16 sdram_dq
) {
    // CLOCK/RESET GENERATION
    uint1   video_reset = uninitialized;
    uint1   video_clock = uninitialized;
    uint1   pll_lock_CPU = uninitialized;
    uint1   pll_lock_AUX = uninitialized;
    uint1   pll_lock_SDRAM = uninitialized;

    uint1 clock_timers = uninitialized;
    uint1 clock_gpu = uninitialized;
    uint1 clock_copro = uninitialized;
    uint1 clock_memory = uninitialized;
    uint1 clock_cpuunit = uninitialized;
    uint1 clock_sdram = uninitialized;

    // Generate 50MHz clocks for CPU units ( multiplier, divider, shifter, compressed instruction expander, ALU units )
    // 50MHz clock for the BRAM and CACHE controller
    ulx3s_clk_risc_ice_v_CPU clk_gen_CPU (
        clkin    <: clock,
        clkCOPRO :> clock_copro,
        clkCPUUNIT :> clock_cpuunit,
        clkMEMORY  :> clock_memory,
        locked   :> pll_lock_CPU
    );

    // Generate the 25MHz video clock, 50MHz clock for timers/audio/random number generator and 50MHz GPU clock
    ulx3s_clk_risc_ice_v_AUX clk_gen_AUX (
        clkin    <: clock,
        clkTIMER  :> clock_timers,
        clkVIDEO  :> video_clock,
        clkGPU :> clock_gpu,
        locked   :> pll_lock_AUX
    );

    // Generate the 150MHz SDRAM clock
    ulx3s_clk_risc_ice_v_SDRAM clk_gen_SDRAM (
        clkin    <: clock,
        clkSDRAM  :> clock_sdram,
        locked   :> pll_lock_SDRAM
    );

    // Video Reset
    reset_conditioner vga_rstcond (
        rcclk <: video_clock ,
        in  <: reset,
        out :> video_reset
    );

    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1   vblank = uninitialized;
    uint1   pix_active = uninitialized;
    uint10  pix_x  = uninitialized;
    uint10  pix_y  = uninitialized;

    // VGA or HDMI driver
    uint8   video_r = uninitialized;
    uint8   video_g = uninitialized;
    uint8   video_b = uninitialized;

    hdmi video<@clock,!reset> (
        vblank  :> vblank,
        active  :> pix_active,
        x       :> pix_x,
        y       :> pix_y,
        gpdi_dp :> gpdi_dp,
        gpdi_dn :> gpdi_dn,
        red     <: video_r,
        green   <: video_g,
        blue    <: video_b
    );

    // RISC-V REGISTERS
    simple_dualport_bram int32 registers_1<input!>[64] = { 0, pad(0) };
    simple_dualport_bram int32 registers_2<input!>[64] = { 0, pad(0) };

    // RISC-V PROGRAM COUNTER
    uint32  pc = 0;
    uint1   compressed = uninitialized;
    uint1   floatingpoint = uninitialized;
    uint1   takeBranch = uninitialized;
    uint1   incPC = uninitialized;

    // RISC-V INSTRUCTION and DECODE
    uint32  instruction = uninitialized;
    uint32  nop := { 12b000000000000, 5b00000, 3b000, 5b00000, 7b0010011 };
    uint7   opCode = uninitialized;
    uint3   function3 = uninitialized;
    uint7   function7 = uninitialized;

    // RISC-V SOURCE REGISTER VALUES
    uint5   rs1 = uninitialized;
    uint5   rs2 = uninitialized;
    uint5   rd = uninitialized;
    int32   sourceReg1 := registers_1.rdata0;
    int32   sourceReg2 := registers_2.rdata0;

    // IMMEDIATE VALUE
    int32   immediateValue = uninitialized;

    // RISC-V ALU RESULTS
    int32   result = uninitialized;
    uint1   writeRegister = uninitialized;

    // RISC-V ADDRESS CALCULATIONS
    uint32  branchOffset := { Btype(instruction).immediate_bits_12 ? 20b11111111111111111111 : 20b00000000000000000000, Btype(instruction).immediate_bits_11, Btype(instruction).immediate_bits_10_5, Btype(instruction).immediate_bits_4_1, 1b0 };
    uint32  jumpOffset := { Jtype(instruction).immediate_bits_20 ? 12b111111111111 : 12b000000000000, Jtype(instruction).immediate_bits_19_12, Jtype(instruction).immediate_bits_11, Jtype(instruction).immediate_bits_10_1, 1b0 };
    uint32  loadAddress := immediateValue + sourceReg1;
    uint32  storeAddress := { instruction[31,1] ? 20b11111111111111111111 : 20b00000000000000000000, Stype(instruction).immediate_bits_11_5, Stype(instruction).immediate_bits_4_0 } + sourceReg1;

    // Setup Memory Mapped I/O
    memmap_io IO_Map (
        leds :> leds,
        btns <: btns,

        // UART
        uart_tx :> uart_tx,
        uart_rx <: uart_rx,

        // AUDIO
        audio_l :> audio_l,
        audio_r :> audio_r,

        // SDCARD
        sd_clk :> sd_clk,
        sd_mosi :> sd_mosi,
        sd_csn :> sd_csn,
        sd_miso <: sd_miso,

        // HDMI
        video_r :> video_r,
        video_g :> video_g,
        video_b :> video_b,
        vblank <: vblank,
        pix_active <: pix_active,
        pix_x <: pix_x,
        pix_y <: pix_y,

        // CLOCKS
        clock_50mhz <: clock_timers,
        clock_25mhz <: clock,
        video_clock <: video_clock,
        gpu_clock <: clock_gpu,
        video_reset <: video_reset
    );

    // RAM - BRAM and SDRAM
    ramcontroller ram <@clock_memory> ();

    // COMPRESSED INSTRUCTION EXPANDER
    compressedexpansion00 compressedunit00 <@clock_cpuunit> ();
    compressedexpansion01 compressedunit01 <@clock_cpuunit> ();
    compressedexpansion10 compressedunit10 <@clock_cpuunit> ();

    // RISC-V BASE ALU
    alu ALU <@clock_copro> (
        instruction <: instruction,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2
    );

    decoder DECODE <@clock_cpuunit> (
        instruction <: instruction,
        opCode :> opCode,
        function3 :> function3,
        function7 :> function7,
        rs1 :> rs1,
        rs2 :> rs2,
        rd :> rd,
        immediateValue :> immediateValue
    );

    // BRANCH COMPARISON UNIT
    branchcomparison branchcomparisonunit <@clock_copro> (
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2
    );

    // SIGN EXTENDER UNIT
    signextender8 signextender8unit <@clock_copro> (
        function3 <: function3
    );
    signextender16 signextender16unit <@clock_copro> (
        function3 <: function3
    );

    // COMBINER UNIT - TWO 16 BIT HALF WORDS TO 32 BIT WORD
    halfhalfword combiner161632unit <@clock_cpuunit> ();

    // BRANCH DECIDER, MULTIPLICATION and DIVISION units
    divideremainder dividerunit <@clock_copro> (
        dividend <: sourceReg1,
        divisor <: sourceReg2
    );
    multiplicationDSP multiplicationuint <@clock_copro> (
        factor_1 <: sourceReg1,
        factor_2 <: sourceReg2
    );

    // MULTIPLICATION and DIVISION Start Flags
    dividerunit.start := 0;
    multiplicationuint.start := 0;

    // RAM/IO Read/Write Flags
    ram.writeflag := 0;
    ram.readflag := 0;
    IO_Map.memoryWrite := 0;
    IO_Map.memoryRead := 0;

    // REGISTER Read/Write Flags
    registers_1.addr0 := rs1 + ( floatingpoint ? 32 : 0 );
    registers_1.wenable1 := 1;
    registers_2.addr0 := rs2 + ( floatingpoint ? 32 : 0 );
    registers_2.wenable1 := 1;

    while(1) {
        // RISC-V
        writeRegister = 0;
        takeBranch = 0;
        incPC = 1;
        floatingpoint = 0;

        // FETCH + EXPAND COMPRESSED INSTRUCTIONS
        ram.address = pc;
        ram.Icache = 1;
        ram.readflag = 1;
        while( ram.busy ) {}
        switch( ram.readdata[0,2] ) {
            case 2b00: { compressed = 1; compressedunit00.instruction16 = ram.readdata; instruction = compressedunit00.instruction32; }
            case 2b01: { compressed = 1; compressedunit01.instruction16 = ram.readdata; instruction = compressedunit01.instruction32; }
            case 2b10: { compressed = 1; compressedunit10.instruction16 = ram.readdata; instruction = compressedunit10.instruction32; }
            case 2b11: {
                compressed = 0;
                combiner161632unit.LOW = ram.readdata;
                ram.address = pc + 2;
                ram.Icache = 1;
                ram.readflag = 1;
                while( ram.busy ) {}
                combiner161632unit.HIGH = ram.readdata;
                instruction = combiner161632unit.HIGHLOW;
            }
        }
        ++:
        ++:

        // DECODE + EXECUTE
        switch( { opCode[6,1], opCode[4,1] } ) {
            case 2b00: {
                // LOAD STORE
                switch( opCode[5,1] ) {
                    case 1b0: {
                        // LOAD executes even if rd == 0 as may be discarding values in a buffer
                        writeRegister = 1;
                        if( ( loadAddress[28,1] == 0 ) && loadAddress[15,1] ) {
                            // I/O
                            IO_Map.memoryAddress = loadAddress[0,16];
                            IO_Map.memoryRead = 1;
                            switch( function3 & 3 ) {
                                case 2b00: {
                                    signextender8unit.nosign = IO_Map.readData[0,8];
                                    result = signextender8unit.withsign;
                                }
                                case 2b01: {
                                    signextender16unit.nosign = IO_Map.readData;
                                    result = signextender16unit.withsign;
                                }
                                case 2b10: {
                                    combiner161632unit.LOW = IO_Map.readData;
                                    result = combiner161632unit.ZEROLOW;
                                }
                            }
                        } else {
                            // SDRAM or BRAM
                            ram.address = loadAddress;
                            ram.Icache = 0;
                            ram.readflag = 1;
                            while( ram.busy ) {}
                            switch( function3 & 3 ) {
                                case 2b00: {
                                    signextender8unit.nosign = ( ram.readdata[loadAddress[0,1] ? 8 : 0, 8] );
                                    result = signextender8unit.withsign;
                               }
                                case 2b01: {
                                    signextender16unit.nosign = ram.readdata;
                                    result = signextender16unit.withsign;
                                }
                                case 2b10: {
                                    combiner161632unit.LOW = ram.readdata;
                                    ram.address = loadAddress + 2;
                                    ram.readflag = 1;
                                    while( ram.busy ) {}
                                    combiner161632unit.HIGH = ram.readdata;
                                    result = combiner161632unit.HIGHLOW;
                                }
                            }
                        }
                    }
                    case 1b1: {
                        // STORE
                        if( ( storeAddress[28,1] == 0 ) && storeAddress[15,1] ) {
                            // I/O
                            IO_Map.memoryAddress = storeAddress[0,16];
                            IO_Map.writeData = __unsigned( sourceReg2[0,16] );
                            IO_Map.memoryWrite = 1;
                        } else {
                            // SDRAM or BRAM
                            ram.address = storeAddress;
                            ram.Icache = 0;
                            switch( function3 & 3 ) {
                                case 2b00: {
                                    // 8 BIT, READ MODIFY WRITE
                                    ram.readflag = 1;
                                    while( ram.busy ) {}
                                    ram.writedata = storeAddress[0,1] ? { sourceReg2[0,8], ram.readdata[0,8] } : { ram.readdata[8,8], sourceReg2[0,8] };
                                    ram.writeflag = 1;
                                }
                                case 2b01: {
                                    ram.writedata = sourceReg2[0,16];
                                    ram.writeflag = 1;
                                }
                                case 2b10: {
                                    ram.writedata = sourceReg2[0,16];
                                    ram.writeflag = 1;
                                    ++:
                                    ram.address = storeAddress + 2;
                                    ram.writedata = sourceReg2[16,16];
                                    ram.writeflag = 1;
                                }
                            }
                        }
                    }
                }
            }

            // AUIPC LUI ALUI ALUR
            case 2b01: {
                writeRegister = 1;

                switch( opCode[2,1] ) {
                    // ALU BASE & M EXTENSION
                    case 1b0: {
                        if( opCode[5,1] && function7[0,1] ) {
                            // M EXTENSION
                            switch( function3[2,1] ) {
                                case 1b0: {
                                    // MULTIPLICATION
                                    multiplicationuint.dosigned =  function3[1,1] ? ( function3[0,1] ? 0 : 2 ) : 1;
                                    multiplicationuint.start = 1;
                                    while( multiplicationuint.active ) {}
                                    result = ( function3 == 0 ) ? multiplicationuint.product[0,32] : multiplicationuint.product[32,32];
                                }
                                case 1b1: {
                                    // DIVISION / REMAINDER
                                    dividerunit.dosigned = function3[0,1] ? 0 : 1;
                                    dividerunit.start = 1;
                                    while( dividerunit.active ) {}
                                    result = function3[1,1] ? dividerunit.remainder : dividerunit.quotient;
                                }
                            }
                        } else {
                            // BASE I ALU OPERATIONS
                            result = ALU.result;
                        }
                    }
                    // AUIPC LUI
                    case 1b1: { result = { Utype(instruction).immediate_bits_31_12, 12b0 } + ( opCode[5,1] ? 0 : pc ); }
                }
            }

            case 2b10: {
                // JUMP BRANCH
                switch( opCode[2,1] ) {
                    // BRANCH on CONDITION
                    case 1b0: { takeBranch = branchcomparisonunit.takeBranch; }
                    // JUMP AND LINK / JUMP AND LINK REGISTER
                    case 1b1: { writeRegister = 1; incPC = 0; result = pc + ( compressed ? 2 : 4 ); }
                }
            }

            // FORCE registers to BRAM - NO FLOATING POINT AT PRESENT!
            default: { floatingpoint = 1; }
        }

        // WRITE TO REGISTERS
        // NEVER write to registers[0]
        if( writeRegister && ( rd != 0 ) ) {
            registers_1.addr1 = rd + ( floatingpoint ? 32 : 0 );
            registers_1.wdata1 = result;
            registers_2.addr1 = rd + ( floatingpoint ? 32 : 0 );
            registers_2.wdata1 = result;
        }

        // UPDATE PC
        pc = ( incPC ) ? pc + ( ( takeBranch) ? branchOffset : ( compressed ? 2 : 4 ) ) : ( opCode[3,1] ? jumpOffset + pc : loadAddress );
    } // RISC-V
}

// RISC-V INSTRUCTION DECODER
algorithm decoder (
    input   uint32  instruction,

    output  uint7   opCode,
    output  uint3   function3,
    output  uint7   function7,

    output  uint5   rs1,
    output  uint5   rs2,
    output  uint5   rd,

    output  int32   immediateValue
) <autorun> {
    opCode := Utype(instruction).opCode;
    function3 := Rtype(instruction).function3;
    function7 := Rtype(instruction).function7;

    rs1 := Rtype(instruction).sourceReg1;
    rs2 := Rtype(instruction).sourceReg2;
    rd := Rtype(instruction).destReg;

    immediateValue := { instruction[31,1] ? 20b11111111111111111111 : 20b00000000000000000000, Itype(instruction).immediate };

    while(1) {
    }
}

// RISC-V BASE ALU
algorithm alu (
    input   uint32  instruction,
    input   int32   sourceReg1,
    input   int32   sourceReg2,

    output  int32   result
) <autorun> {
    uint7   opCode := Utype(instruction).opCode;
    uint3   function3 := Rtype(instruction).function3;
    uint7   function7 := Rtype(instruction).function7;
    int32   immediateValue := { instruction[31,1] ? 20b11111111111111111111 : 20b00000000000000000000, Itype(instruction).immediate };

    int32   shiftRIGHTA := __signed(sourceReg1) >>> ( opCode[5,1] ? sourceReg2[0,5] : ItypeSHIFT( instruction ).shiftCount );
    int32   shiftRIGHTL := __unsigned(sourceReg1) >> ( opCode[5,1] ? sourceReg2[0,5] : ItypeSHIFT( instruction ).shiftCount );

    uint1   SLT := __signed( sourceReg1 ) < __signed(sourceReg2) ? 1 : 0;
    uint1   SLTI := __signed( sourceReg1 ) < __signed(immediateValue) ? 1 : 0;
    uint1   SLTU := ( Rtype(instruction).sourceReg1 == 0 ) ? ( ( sourceReg2 != 0 ) ? 1 : 0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( sourceReg2 ) ) ? 1 : 0 );
    uint1   SLTUI := ( immediateValue == 1 ) ? ( ( sourceReg1 == 0 ) ? 1 : 0 ) : ( ( __unsigned( sourceReg1 ) < __unsigned( immediateValue ) ) ? 1 : 0 );

    while(1) {
        switch( function3 ) {
            case 3b000: { result = sourceReg1 + ( opCode[5,1] ? ( function7[5,1] ? -( sourceReg2 ) : sourceReg2 ) : immediateValue ); }
            case 3b001: { result = __unsigned(sourceReg1) << ( opCode[5,1] ? sourceReg2[0,5] : ItypeSHIFT( instruction ).shiftCount ); }
            case 3b010: { result = ( opCode[5,1] ? SLT : SLTI ) ? 32b1 : 32b0; }
            case 3b011: { result = ( opCode[5,1] ? SLTU : SLTUI ) ? 32b1 : 32b0; }
            case 3b100: { result = sourceReg1 ^ ( opCode[5,1] ? sourceReg2 : immediateValue ); }
            case 3b101: { result = function7[5,1] ? shiftRIGHTA : shiftRIGHTL; }
            case 3b110: { result = sourceReg1 | ( opCode[5,1] ? sourceReg2 : immediateValue ); }
            case 3b111: { result = sourceReg1 & ( opCode[5,1] ? sourceReg2 : immediateValue ); }
        }
    }
}

// BRANCH COMPARISIONS
algorithm branchcomparison (
    input   uint3   function3,
    input   int32   sourceReg1,
    input   int32   sourceReg2,
    output  uint1   takeBranch
) <autorun> {
    while(1) {
        switch( function3 ) {
            case 3b000: { takeBranch = ( sourceReg1 == sourceReg2 ) ? 1 : 0; }
            case 3b001: { takeBranch = ( sourceReg1 != sourceReg2 ) ? 1 : 0; }
            case 3b100: { takeBranch = ( __signed(sourceReg1) < __signed(sourceReg2) ) ? 1 : 0; }
            case 3b101: { takeBranch = ( __signed(sourceReg1) >= __signed(sourceReg2) )  ? 1 : 0; }
            case 3b110: { takeBranch = ( __unsigned(sourceReg1) < __unsigned(sourceReg2) ) ? 1 : 0; }
            case 3b111: { takeBranch = ( __unsigned(sourceReg1) >= __unsigned(sourceReg2) ) ? 1 : 0; }
            default: { takeBranch = 0; }
        }
    }
}

// EXPAND RISC-V 16 BIT COMPRESSED INSTRUCTIONS TO THEIR 32 BIT EQUIVALENT
algorithm compressedexpansion00 (
    input   uint16  instruction16,
    output  uint32  instruction32
) <autorun> {
    while(1) {
        switch( instruction16[13,3] ) {
            case 3b000: {
                // ADDI4SPN -> addi rd', x2, nzuimm[9:2]
                // { 000, nzuimm[5:4|9:6|2|3] rd' 00 } -> { imm[11:0] rs1 000 rd 0010011 }
                instruction32= { 2b0, CIu94(instruction16).ib_9_6, CIu94(instruction16).ib_5_4, CIu94(instruction16).ib_3, CIu94(instruction16).ib_2, 2b00, 5h2, 3b000, {2b01,CIu94(instruction16).rd_alt}, 7b0010011 };
            }
            case 3b001: {
                // FLD
            }
            case 3b010: {
                // LW -> lw rd', offset[6:2](rs1')
                // { 010 uimm[5:3] rs1' uimm[2][6] rd' 00 } -> { imm[11:0] rs1 010 rd 0000011 }
                instruction32= { 5b0, CL(instruction16).ib_6, CL(instruction16).ib_5_3, CL(instruction16).ib_2, 2b00, {2b01,CL(instruction16).rs1_alt}, 3b010, {2b01,CL(instruction16).rd_alt}, 7b0000011};
            }
            case 3b011: {
                // FLW
            }
            case 3b100: {
                // reserved
            }
            case 3b101: {
                // FSD
            }
            case 3b110: {
                // SW -> sw rs2', offset[6:2](rs1')
                // { 110 uimm[5:3] rs1' uimm[2][6] rs2' 00 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100011 }
                instruction32= { 5b0, CS(instruction16).ib_6, CS(instruction16).ib_5, {2b01,CS(instruction16).rs2_alt}, {2b01,CS(instruction16).rs1_alt}, 3b010, CS(instruction16).ib_4_3, CS(instruction16).ib_2, 2b0, 7b0100011 };
            }
            case 3b111: {
                // FSW
            }
        }
    }
}

algorithm compressedexpansion01 (
    input   uint16  instruction16,
    output  uint32  instruction32
) <autorun> {
    while(1) {
        switch( instruction16[13,3] ) {
            case 3b000: {
                // ADDI -> addi rd, rd, nzimm[5:0]
                // { 000 nzimm[5] rs1/rd!=0 nzimm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                instruction32= { CI50(instruction16).ib_5 ? 7b1111111 : 7b0000000, CI50(instruction16).ib_4_0, CI50(instruction16).rd, 3b000, CI50(instruction16).rd, 7b0010011 };
            }
            case 3b001: {
                // JAL -> jal x1, offset[11:1]
                // { 001, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
                instruction32= { CJ(instruction16).ib_11, CJ(instruction16).ib_10, CJ(instruction16).ib_9_8, CJ(instruction16).ib_7, CJ(instruction16).ib_6, CJ(instruction16).ib_5, CJ(instruction16).ib_4, CJ(instruction16).ib_3_1, CJ(instruction16).ib_11 ? 9b111111111 : 9b000000000, 5h1, 7b1101111 };
            }
            case 3b010: {
                // LI -> addi rd, x0, imm[5:0]
                // { 010 imm[5] rd!=0 imm[4:0] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                instruction32= { CI50(instruction16).ib_5 ? 7b1111111 : 7b0000000, CI50(instruction16).ib_4_0, 5h0, 3b000, CI(instruction16).rd, 7b0010011 };
            }
            case 3b011: {
                // LUI / ADDI16SP
                if( ( CI(instruction16).rd != 0 ) && ( CI(instruction16).rd != 2 ) ) {
                    // LUI -> lui rd, nzuimm[17:12]
                    // { 011 nzimm[17] rd!={0,2} nzimm[16:12] 01 } -> { imm[31:12] rd 0110111 }
                    instruction32= { CIlui(instruction16).ib_17 ? 15b111111111111111 : 15b000000000000000, CIlui(instruction16).ib_16_12, CIlui(instruction16).rd, 7b0110111 };
                } else {
                    // ADDI16SP -> addi x2, x2, nzimm[9:4]
                    // { 011 nzimm[9] 00010 nzimm[4|6|8:7|5] 01 } -> { imm[11:0] rs1 000 rd 0010011 }
                    instruction32= { CI94(instruction16).ib_9 ? 3b111 : 3b000, CI94(instruction16).ib_8_7, CI94(instruction16).ib_6, CI94(instruction16).ib_5, CI94(instruction16).ib_4, 4b0000, 5h2, 3b000, 5h2, 7b0010011 };
                }
            }
            case 3b100: {
                // MISC-ALU
                switch( CBalu(instruction16).function2 ) {
                    case 2b00: {
                        // SRLI -> srli rd', rd', shamt[5:0]
                        // { 100 nzuimm[5] 00 rs1'/rd' nzuimm[4:0] 01 } -> { 0000000 shamt rs1 101 rd 0010011 }
                        instruction32= { 7b0000000, CBalu50(instruction16).ib_4_0, { 2b01, CBalu50(instruction16).rd_alt }, 3b101, { 2b01, CBalu50(instruction16).rd_alt }, 7b0010011 };
                    }
                    case 2b01: {
                        // SRAI -> srai rd', rd', shamt[5:0]
                        // { 100 nzuimm[5] 01 rs1'/rd' nzuimm[4:0] 01 } -> { 0100000 shamt rs1 101 rd 0010011 }
                        instruction32= { 7b0100000, CBalu50(instruction16).ib_4_0, { 2b01, CBalu50(instruction16).rd_alt }, 3b101, { 2b01, CBalu50(instruction16).rd_alt }, 7b0010011 };
                    }
                    case 2b10: {
                        // ANDI -> andi rd', rd', imm[5:0]
                        // { 100 imm[5], 10 rs1'/rd' imm[4:0] 01 } -> { imm[11:0] rs1 111 rd 0010011 }
                        instruction32= { CBalu50(instruction16).ib_5 ? 7b1111111 : 7b0000000, CBalu50(instruction16).ib_4_0, { 2b01, CBalu50(instruction16).rd_alt }, 3b111, { 2b01, CBalu50(instruction16).rd_alt }, 7b0010011 };
                    }
                    case 2b11: {
                        // SUB XOR OR AND
                        switch( CBalu(instruction16).logical2 ) {
                            case 2b00: {
                                //SUB -> sub rd', rd', rs2'
                                // { 100 0 11 rs1'/rd' 00 rs2' 01 } -> { 0100000 rs2 rs1 000 rd 0110011 }
                                instruction32= { 7b0100000, { 2b01, CBalu(instruction16).rs2_alt }, { 2b01, CBalu(instruction16).rd_alt }, 3b000, { 2b01, CBalu(instruction16).rd_alt }, 7b0110011 };
                            }
                            case 2b01: {
                                // XOR -> xor rd', rd', rs2'
                                // { 100 0 11 rs1'/rd' 01 rs2' 01 } -> { 0000000 rs2 rs1 100 rd 0110011 }
                                instruction32= { 7b0000000, { 2b01, CBalu(instruction16).rs2_alt }, { 2b01, CBalu(instruction16).rd_alt }, 3b100, { 2b01, CBalu(instruction16).rd_alt }, 7b0110011 };
                            }
                            case 2b10: {
                                // OR -> or rd', rd', rd2'
                                // { 100 0 11 rs1'/rd' 10 rs2' 01 } -> { 0000000 rs2 rs1 110 rd 0110011 }
                                instruction32= { 7b0000000, { 2b01, CBalu(instruction16).rs2_alt }, { 2b01, CBalu(instruction16).rd_alt }, 3b110, { 2b01, CBalu(instruction16).rd_alt }, 7b0110011 };
                            }
                            case 2b11: {
                                // AND -> and rd', rd', rs2'
                                // { 100 0 11 rs1'/rd' 11 rs2' 01 } -> { 0000000 rs2 rs1 111 rd 0110011 }
                                instruction32= { 7b0000000, { 2b01, CBalu(instruction16).rs2_alt }, { 2b01, CBalu(instruction16).rd_alt }, 3b111, { 2b01, CBalu(instruction16).rd_alt }, 7b0110011 };
                            }
                        }
                    }
                }
            }
            case 3b101: {
                // J -> jal, x0, offset[11:1]
                // { 101, imm[11|4|9:8|10|6|7|3:1|5] 01 } -> { imm[20|10:1|11|19:12] rd 1101111 }
                instruction32= { CJ(instruction16).ib_11, CJ(instruction16).ib_10, CJ(instruction16).ib_9_8, CJ(instruction16).ib_7, CJ(instruction16).ib_6, CJ(instruction16).ib_5, CJ(instruction16).ib_4, CJ(instruction16).ib_3_1, CJ(instruction16).ib_11 ? 9b111111111 : 9b000000000, 5h0, 7b1101111 };
            }
            case 3b110: {
                // BEQZ -> beq rs1', x0, offset[8:1]
                // { 110, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 000 imm[4:1|11] 1100011 }
                instruction32= { CB(instruction16).offset_8 ? 4b1111 : 4b0000, CB(instruction16).offset_7_6, CB(instruction16).offset_5, 5h0, {2b01,CB(instruction16).rs1_alt}, 3b000, CB(instruction16).offset_4_3, CB(instruction16).offset_2_1, CB(instruction16).offset_8, 7b1100011 };
            }
            case 3b111: {
                // BNEZ -> bne rs1', x0, offset[8:1]
                // { 111, imm[8|4:3] rs1' imm[7:6|2:1|5] 01 } -> { imm[12|10:5] rs2 rs1 001 imm[4:1|11] 1100011 }
                instruction32= { CB(instruction16).offset_8 ? 4b1111 : 4b0000, CB(instruction16).offset_7_6, CB(instruction16).offset_5, 5h0, {2b01,CB(instruction16).rs1_alt}, 3b001, CB(instruction16).offset_4_3, CB(instruction16).offset_2_1, CB(instruction16).offset_8, 7b1100011 };
            }
        }
        }
}

algorithm compressedexpansion10 (
    input   uint16  instruction16,
    output  uint32  instruction32
) <autorun> {
    while(1) {
        switch( instruction16[13,3] ) {
            case 3b000: {
                // SLLI -> slli rd, rd, shamt[5:0]
                // { 000, nzuimm[5], rs1/rd!=0 nzuimm[4:0] 10 } -> { 0000000 shamt rs1 001 rd 0010011 }
                instruction32= { 7b0000000, CI50(instruction16).ib_4_0, CI50(instruction16).rd, 3b001, CI50(instruction16).rd, 7b0010011 };
            }
            case 3b001: {
                // FLDSP
            }
            case 3b010: {
                // LWSP -> lw rd, offset[7:2](x2)
                // { 011 uimm[5] rd uimm[4:2|7:6] 10 } -> { imm[11:0] rs1 010 rd 0000011 }
                instruction32= { 4b0, CI(instruction16).ib_7_6, CI(instruction16).ib_5, CI(instruction16).ib_4_2, 2b0, 5h2 ,3b010, CI(instruction16).rd, 7b0000011 };
            }
            case 3b011: {
                // FLWSP
            }
            case 3b100: {
                // J[AL]R / MV / ADD
                switch( instruction16[12,1] ) {
                    case 1b0: {
                        // JR / MV
                        if( CR(instruction16).rs2 == 0 ) {
                            // JR -> jalr x0, rs1, 0
                            // { 100 0 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                            instruction32= { 12b0, CR(instruction16).rs1, 3b000, 5h0, 7b1100111 };
                        } else {
                            // MV -> add rd, x0, rs2
                            // { 100 0 rd!=0 rs2!=0 10 } -> { 0000000 rs2 rs1 000 rd 0110011 }
                            instruction32= { 7b0000000, CR(instruction16).rs2, 5h0, 3b000, CR(instruction16).rs1, 7b0110011 };
                        }
                    }
                    case 1b1: {
                        // JALR / ADD
                        if( CR(instruction16).rs2 == 0 ) {
                            // JALR -> jalr x1, rs1, 0
                            // { 100 1 rs1 00000 10 } -> { imm[11:0] rs1 000 rd 1100111 }
                            instruction32= { 12b0, CR(instruction16).rs1, 3b000, 5h1, 7b1100111 };
                        } else {
                            // ADD -> add rd, rd, rs2
                            // { 100 1 rs1/rd!=0 rs2!=0 10 } -> { 0000000 rs2 rs1 000 rd 0110011 }
                            instruction32= { 7b0000000, CR(instruction16).rs2, CR(instruction16).rs1, 3b000, CR(instruction16).rs1, 7b0110011 };
                        }
                    }
                }
            }
            case 3b101: {
                // FSDSP
            }
            case 3b110: {
                // SWSP -> sw rs2, offset[7:2](x2)
                // { 110 uimm[5][4:2][7:6] rs2 10 } -> { imm[11:5] rs2 rs1 010 imm[4:0] 0100011 }
                instruction32= { 4b0, CSS(instruction16).ib_7_6, CSS(instruction16).ib_5, CSS(instruction16).rs2, 5h2, 3b010, CSS(instruction16).ib_4_2, 2b00, 7b0100011 };
            }
            case 3b111: {
                // FSWSP
            }
        }
    }
}

// PERFORM OPTIONAL SIGN EXTENSION FOR 8 BIT AND 16 BIT READS
algorithm signextender8 (
    input   uint3   function3,
    input   uint8  nosign,
    output  uint32  withsign
) <autorun> {
    withsign := { ( ( nosign[7,1] & ~function3[2,1] ) ? 24hffffff : 24h000000 ), nosign[0,8] };
    while(1) {
    }
}
algorithm signextender16 (
    input   uint3   function3,
    input   uint16  nosign,
    output  uint32  withsign
) <autorun> {
    withsign := { ( nosign[15,1] & ~function3[2,1] ) ? 16hffff : 16h0000, nosign };
    while(1) {
    }
}

// COMBINE TWO 16 BIT HALF WORDS TO 32 BIT WORD
algorithm halfhalfword (
    input   uint16  HIGH,
    input   uint16  LOW,
    output  int32   HIGHLOW,
    output  int32   ZEROLOW
) <autorun> {
    HIGHLOW := { HIGH, LOW };
    ZEROLOW := { 16b0, LOW };

    while(1) {
    }
}

// RAM - BRAM controller and SDRAM controller ( with simple write-through cache )
// MEMORY IS 16 BIT, 8 BIT WRITES HAVE TO BE HANDLED BY THE CPU DOING READ MODIFY WRITE
// NOTES: AT PRESENT NO INTERACTION WITH THE SDRAM, CACHE ACTS AS 4K x 16 bit memory for proof of concept
// LOGIC FOR CACHE HIT AND MISS IN PLACE
// NEEDS A BUSY FLAG FOR WHEN CACHE MISS AND FOR SDRAM WRITES TO TAKE PLACE
algorithm ramcontroller (
    input   uint32  address,
    input   uint16  writedata,
    output  uint16  readdata,
    input   uint1   writeflag,
    input   uint1   readflag,
    input   uint1   Icache,
    output  uint1   busy
) <autorun> {
    // RISC-V RAM and BIOS
    bram uint16 ram<input!>[12288] = {
        $include('ROM/BIOS.inc')
        , pad(uninitialized)
    };

    // INSTRUCTION & DATA CACHES for SDRAM
    // CACHE LINE IS LOWER 11 bits ( 0 - 2047 ) of address, dropping the BYTE address bit
    // CACHE TAG IS REMAINING 13 bits of the 25 bit address + 1 bit for valid flag
    bram uint16 Dcachedata<input!>[2048] = uninitialized;
    bram uint14 Dcachetag<input!>[2048] = uninitialized;
    bram uint16 Icachedata<input!>[2048] = uninitialized;
    bram uint14 Icachetag<input!>[2048] = uninitialized;

    // ACTIVE FLAG
    uint1   active = 0;
    busy := ( readflag || writeflag ) ? 1 : active;

    // FLAGS FOR CACHE ACCESS
    Dcachedata.wenable := 0; Dcachedata.addr := address[1,11];
    Dcachetag.wenable := 0; Dcachetag.addr := address[1,11]; Dcachetag.wdata := { 1b1, address[12,13] };
    Icachedata.wenable := 0; Icachedata.addr := address[1,11];
    Icachetag.wenable := 0; Icachetag.addr := address[1,11]; Icachetag.wdata := { 1b1, address[12,13] };

    // FLAGS FOR BRAM ACCESS
    ram.wenable := 0;
    ram.addr := address[1,15];

    // RETURN RESULTS FROM BRAM OR CACHE
    readdata := address[28,1] ? ( Icache ? Icachedata.rdata : Dcachedata.rdata ) : ram.rdata;

    while(1) {
        if( readflag && address[28,1] ) {
            // SDRAM
            if( ( Icache && ( Icachetag.rdata == { 1b1, address[12,13] } ) ) || ( Dcachetag.rdata == { 1b1, address[12,13] } ) ) {
                // CACHE HIT
                active = 0;
            } else {
                // CACHE MISS
                active = 1;
                // READ FROM SDRAM
                // WRITE RESULT TO ICACHE or DCACHE
                if( Icache ) {
                    // ICACHE WRITE
                    Icachetag.wenable = 1;
                } else {
                    // DCACHE WRITE
                    Dcachetag.wenable = 1;
                }
                active = 0;
            }
        }

        if( writeflag ) {
            if( address[28,1] ) {
                // SDRAM
                active = 1;
                // WRITE INTO CACHE
                Dcachedata.wdata = writedata;
                Dcachedata.wenable = 1; Dcachetag.wenable = 1;

                // CHECK IF ENTRY IS IN ICACHE AND UPDATE
                if( Icachetag.rdata == { 1b1, address[12,13] } ) {
                    Icachedata.wdata = writedata;
                    Icachedata.wenable = 1;
                }

                // WRITE TO SDRAM
                active = 0;
            } else {
                // BRAM
                ram.wdata = writedata;
                ram.wenable = 1;
                active = 0;
            }
        }
    }
}
