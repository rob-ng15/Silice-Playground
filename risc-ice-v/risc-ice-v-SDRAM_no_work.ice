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

    // HELPER CIRCUIT - READ INSTRUTION VIA ICACHE
    circuitry ramREADI(
        input   address,
        input   rambusy,
        output  ramaddress,
        output  ramreadflag,
        output  ramIcache
    ) {
        ramaddress = address;
        ramIcache = 1;
        ramreadflag = 1;
        while( rambusy ) {}
    }

    // HELPER CIRCUIT - READ DATA VIA DCACHE
    circuitry ramREADD(
        input   address,
        input   rambusy,
        output  ramaddress,
        output  ramreadflag,
        output  ramIcache
    ) {
        ramaddress = address;
        ramIcache = 0;
        ramreadflag = 1;
        while( rambusy ) {}
    }

    // HELPER CIRCUIT - WRITE DATA
    circuitry ramWRITE (
        input   address,
        input   writedata,
        input   rambusy,
        output  ramaddress,
        output  ramwritedata,
        output  ramwriteflag
    ) {
        ramaddress = address;
        ramwritedata = writedata;
        ramwriteflag = 1;
        while( rambusy ) {}
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

    // CPU DOMAIN CLOCKS
    uint1   pll_lock_CPU = uninitialized;
    uint1   clock_copro = uninitialized;
    uint1   clock_cpuunit = uninitialized;
    uint1   clock_memory = uninitialized;
    uint1   clock_registers = uninitialized;
    // Generate 50MHz clocks for CPU units
    // 50MHz clock for the BRAM and CACHE controller
    ulx3s_clk_risc_ice_v_CPU clk_gen_CPU (
        clkin    <: clock,
        clkCOPRO :> clock_copro,
        clkMEMORY  :> clock_memory,
        clkCPUUNIT :> clock_cpuunit,
        clkREGISTERS :> clock_registers,
        locked   :> pll_lock_CPU
    );

    // SDRAM DOMAIN CLOCKS
    uint1   pll_lock_SDRAM = uninitialized;
    ulx3s_clk_risc_ice_v_SDRAM clk_gen_SDRAM (
        clkin <: clock,
        clkSDRAM :> sdram_clk,
        locked :> pll_lock_SDRAM
    );

    // I/O DOMAIN CLOCKS
    uint1   clock_IO = uninitialized;
    uint1   video_reset = uninitialized;
    uint1   video_clock = uninitialized;
    uint1   pll_lock_AUX = uninitialized;
    ulx3s_clk_risc_ice_v_AUX clk_gen_AUX (
        clkin   <: clock,
        clkIO :> clock_IO,
        clkVIDEO :> video_clock,
        locked :> pll_lock_AUX
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
    simple_dualport_bram int32 registers_1 <input!> [64] = { 0, pad(0) };
    simple_dualport_bram int32 registers_2 <input!> [64] = { 0, pad(0) };

    // RISC-V PROGRAM COUNTER
    uint32  pc = 0;
    uint32  pcPLUS2 = uninitialized;
    uint32  nextPC = uninitialized;
    uint1   compressed = uninitialized;
    uint1   floatingpoint = uninitialized;
    uint1   takeBranch = uninitialized;
    uint1   incPC = uninitialized;

    // RISC-V INSTRUCTION and DECODE
    uint32  instruction = uninitialized;
    uint7   opCode = uninitialized;
    uint3   function3 = uninitialized;
    uint7   function7 = uninitialized;

    // RISC-V SOURCE REGISTER VALUES
    uint5   rs1 = uninitialized;
    uint5   rs2 = uninitialized;
    uint5   rd = uninitialized;
    int32   sourceReg1 = uninitialized;
    int32   sourceReg2 = uninitialized;
    uint16  sourceReg2LOW = uninitialized;
    uint16  sourceReg2HIGH = uninitialized;

    // IMMEDIATE VALUE
    int32   immediateValue = uninitialized;

    // RISC-V ALU RESULTS
    int32   result = uninitialized;
    uint1   writeRegister = uninitialized;


  // SDRAM chip controller
  // interface
  sdram_r16w16_io sdram_io;
  // algorithm
  sdram_controller_autoprecharge_r128_w8 sdram(
    sd        <:> sdram_io,
    sdram_cle :>  sdram_cle,
    sdram_dqm :>  sdram_dqm,
    sdram_cs  :>  sdram_cs,
    sdram_we  :>  sdram_we,
    sdram_cas :>  sdram_cas,
    sdram_ras :>  sdram_ras,
    sdram_ba  :>  sdram_ba,
    sdram_a   :>  sdram_a,
    sdram_dq  <:> sdram_dq
  );

    // RAM - BRAM and SDRAM
    uint16  instruction16 = uninitialized;
    uint32  ramaddress = uninitialized;
    uint16  ramwritedata = uninitialized;
    uint16  ramreaddata = uninitialized;
    int32   ramreaddata8 = uninitialized;
    int32   ramreaddata16 = uninitialized;
    uint1   ramreadflag = uninitialized;
    uint1   ramwriteflag = uninitialized;
    uint1   ramIcache = uninitialized;
    uint1   rambusy = uninitialized;
    ramcontroller ram  <@clock_memory>(
        sdram_io <:> sdram_io,
        address <: ramaddress,
        writedata <: ramwritedata,
        readflag <: ramreadflag,
        writeflag <: ramwriteflag,
        Icache <: ramIcache,

        function3 <: function3,
        readdata :> instruction16,
        readdata :> ramreaddata,
        readdata8 :> ramreaddata8,
        readdata16 :> ramreaddata16,
        busy :> rambusy
    );

    // MEMORY MAPPED I/O
    memmap_io IO_Map <@clock_IO> (
        function3 <: function3,
        leds :> leds,
        btns <: btns,
        uart_tx :> uart_tx,
        uart_rx <: uart_rx,
        audio_l :> audio_l,
        audio_r :> audio_r,
        sd_clk :> sd_clk,
        sd_mosi :> sd_mosi,
        sd_csn :> sd_csn,
        sd_miso <: sd_miso,
        video_r :> video_r,
        video_g :> video_g,
        video_b :> video_b,
        vblank <: vblank,
        pix_active <: pix_active,
        pix_x <: pix_x,
        pix_y <: pix_y,
        video_clock <: video_clock,
        video_reset <: video_reset
    );

    // RISC-V REGISTER WRITER
    registersWRITE registersW (
        rd <: rd,
        floatingpoint <: floatingpoint,
        result <: result,
        registers_1 <:> registers_1,
        registers_2 <:> registers_2
    );

    // RISC-V REGISTER READER
    registersREAD registersR (
        rs1 <: rs1,
        rs2 <: rs2,
        floatingpoint <: floatingpoint,
        sourceReg1 :> sourceReg1,
        sourceReg2 :> sourceReg2,
        sourceReg2LOW :> sourceReg2LOW,
        sourceReg2HIGH :> sourceReg2HIGH,
        registers_1 <:> registers_1,
        registers_2 <:> registers_2
    );

    // COMPRESSED INSTRUCTION EXPANDER
    uint32  instruction32 = uninitialized;
    uint1   IScompressed = uninitialized;
    compressedexpansion compressedunit <@clock_cpuunit> (
        compressed :> IScompressed,
        instruction16 <: instruction16,
        instruction32 :> instruction32,
    );

    // RISC-V 32 BIT INSTRUCTION DECODER
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

    // RISC-V ADDRESSES - calculated by the address generation unit
    uint32  branchAddress = uninitialized;
    uint32  jumpAddress = uninitialized;
    uint32  loadAddress = uninitialized;
    uint32  loadAddressPLUS2 = uninitialized;
    uint32  storeAddress = uninitialized;
    uint32  storeAddressPLUS2 = uninitialized;
    uint32  AUIPCLUI = uninitialized;
    addressgenerator AGU <@clock_cpuunit> (
        instruction <: instruction,
        pc <:: pc,
        compressed <: compressed,
        sourceReg1 <: sourceReg1,
        pcPLUS2 :> pcPLUS2,
        nextPC :> nextPC,
        branchAddress :> branchAddress,
        jumpAddress :> jumpAddress,
        AUIPCLUI :> AUIPCLUI,
        storeAddress :> storeAddress,
        storeAddressPLUS2 :> storeAddressPLUS2,
        loadAddress :> loadAddress,
        loadAddressPLUS2 :> loadAddressPLUS2
    );

    // RISC-V BASE ALU
    alu ALU <@clock_copro> (
        instruction <: instruction,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
    );

    // BRANCH COMPARISON UNIT
    uint1   BRANCHtakeBranch = uninitialized;
    branchcomparison branchcomparisonunit <@clock_cpuunit> (
        function3 <: function3,
        sourceReg1 <: sourceReg1,
        sourceReg2 <: sourceReg2,
        takeBranch :> BRANCHtakeBranch
    );

    // COMBINE TWO 16 BIT HALF WORDS TO ONE 32 BIT WORD
    uint16  LOW = uninitialized;
    uint16  HIGH = uninitialized;
    uint32  HIGHLOW = uninitialized;
    halfhalfword combiner161632unit <@clock_cpuunit> (
        LOW <: LOW,
        HIGH <: HIGH,
        HIGHLOW :> HIGHLOW
    );

    // RAM/IO Read/Write Flags
    ramwriteflag := 0;
    ramreadflag := 0;
    IO_Map.memoryWrite := 0;
    IO_Map.memoryRead := 0;

    // REGISTER Read/Write Flags
    registersW.writeRegister := 0;

    // ALU Start Flag
    ALU.start := 0;

    while(1) {
        // RISC-V
        writeRegister = 0;
        takeBranch = 0;
        incPC = 1;
        floatingpoint = 0;

        // FETCH + EXPAND COMPRESSED INSTRUCTIONS
        ( ramaddress, ramreadflag, ramIcache ) = ramREADI( pc, rambusy );
        compressed = IScompressed;
        switch( IScompressed ) {
            case 1b0: {
                // 32 bit instruction
                LOW = instruction32;
                ( ramaddress, ramreadflag, ramIcache ) = ramREADI( pcPLUS2, rambusy );
                HIGH = ramreaddata;
                instruction = HIGHLOW;
            }
            case 1b1: {
                // 16 bit compressed instruction
                instruction = instruction32;
            }
        }

        // DECODE + REGISTER FETCH
        // HAPPENS AUTOMATICALLY in DECODE AND REGISTER UNITS
        ++:
        ++:

        // EXECUTE
        switch( opCode ) {
            case 7b0110111: {
                // LUI
                writeRegister = 1;
                result = AUIPCLUI;
            }
            case 7b0010111: {
                //AUIPC
                writeRegister = 1;
                result = AUIPCLUI;
            }
            case 7b1101111: {
                // JAL
                writeRegister = 1;
                incPC = 0;
                result = nextPC;
            }
            case 7b1100111: {
                // JALR
                writeRegister = 1;
                incPC = 0;
                result = nextPC;
            }
            case 7b1100011: {
                // BRANCH
                takeBranch = branchcomparisonunit.takeBranch;
            }
            case 7b0000011: {
                // LOAD
                writeRegister = 1;
                if( ~loadAddress[28,1] && loadAddress[15,1] ) {
                    // I/O
                    IO_Map.memoryAddress = loadAddress[0,16];
                    IO_Map.memoryRead = 1;
                    switch( function3 & 3 ) {
                        case 2b10: { result = IO_Map.readData; }
                        default: { result = ( ( function3 & 3 ) == 0 ) ? IO_Map.readData8 : IO_Map.readData16; }
                    }
                } else {
                    // SDRAM or BRAM ( mark as using data cache )
                    ( ramaddress, ramreadflag, ramIcache ) = ramREADD( loadAddress, rambusy );
                    switch( function3 & 3 ) {
                        case 2b10: {
                            // 32 bit READ as 2 x 16 bit
                            LOW = ramreaddata;
                            ( ramaddress, ramreadflag, ramIcache ) = ramREADD( loadAddressPLUS2, rambusy );
                            HIGH = ramreaddata;
                            result = HIGHLOW;
                        }
                        default: {
                            // 8/16 bit with optional sign extension
                            result = ( ( function3 & 3 ) == 0 ) ? ramreaddata8 : ramreaddata16;
                        }
                    }
                }
            }
            case 7b0100011: {
                // STORE
                if( ~storeAddress[28,1] && storeAddress[15,1] ) {
                    // I/O ALWAYS 16 bit WRITES
                    IO_Map.memoryAddress = storeAddress[0,16];
                    IO_Map.writeData = sourceReg2LOW;
                    IO_Map.memoryWrite = 1;
                } else {
                    // SDRAM or BRAM
                    if( ( function3 & 3 ) == 0 ) {
                        // READ 8 BIT INTO CACHE
                        ( ramaddress, ramreadflag, ramIcache ) = ramREADD( storeAddress, rambusy );
                    }
                    // WRITE 8, 16 and LOWER 16 of 32 bits
                    ( ramaddress, ramwritedata, ramwriteflag ) = ramWRITE( storeAddress, sourceReg2LOW, rambusy );
                    if(  ( function3 & 3 ) == 2b10 ) {
                        // WRITE UPPER 16 of 32 bits
                        ( ramaddress, ramwritedata, ramwriteflag ) = ramWRITE( storeAddressPLUS2, sourceReg2HIGH, rambusy );
                    }
                }
            }
            case 7b0010011: {
                // ALUI
                writeRegister = 1;
                result = ALU.result;
            }
            case 7b0110011: {
                // ALUR + M EXTENSION
                writeRegister = 1;
                if( function7[0,1] ) {
                    // START DIVISION / MULTIPLICATION
                    ALU.start = 1;
                    while( ALU.busy ) {}
                }
                result = function7[0,1] ? ALU.Mresult : ALU.result;
            }
            case 7b0001111: {
                // FENCE/FENCE.I
            }
            case 7b1110011: {
                // ECALL/EBREAK/CSR
            }
            case 7b0101111: {
                // A EXTENSION
            }
            case 7b0000111: {
                // F EXTENSION LOAD
            }
            case 7b0100111: {
                // F EXTENSION STORE
            }
            case 7b1000011: {
                // F EXTENSION FMADD.S
            }
            case 7b1000111: {
                // F EXTENSION FMSUB.S
            }
            case 7b1001011: {
                // F EXTENSION FNMSUB.S
            }
            case 7b1001111: {
                // F EXTENSION FNMADD.S
            }
            case 7b1010011: {
                // F EXTENSION main instructions
            }
            default: {
                floatingpoint = 1;
            }
        }

        // WRITE TO REGISTERS
        registersW.writeRegister = writeRegister;

        // UPDATE PC
        pc = ( incPC ) ? ( takeBranch ? branchAddress : nextPC ) : ( opCode[3,1] ? jumpAddress : loadAddress );
    } // RISC-V
}

// RAM - BRAM controller and SDRAM controller ( with simple write-through cache )
// MEMORY IS 16 BIT, 8 BIT WRITES HAVE TO BE HANDLED BY THE CPU DOING READ MODIFY WRITE
// READS 8 and 16 bit READS ARE SIGN EXTENDED
// NOTES: AT PRESENT NO INTERACTION WITH THE SDRAM, CACHE ACTS AS 2K x 16 bit memory for proof of concept

algorithm ramcontroller (
    sdram_user sdram_io,

    input   uint32  address,
    input   uint3   function3,

    input   uint1   writeflag,
    input   uint16  writedata,

    input   uint1   readflag,
    input   uint1   Icache,
    output  uint16  readdata,
    output  int32   readdata8,
    output  int32   readdata16,

    output  uint1   busy
) <autorun> {
    // RISC-V RAM and BIOS
    bram uint16 ram <input!> [12288] = {
        $include('ROM/BIOS.inc')
        , pad(uninitialized)
    };

    // INSTRUCTION & DATA CACHES for SDRAM (32mb)
    // CACHE LINE IS LOWER 11 bits ( 0 - 2047 ) of address, dropping the BYTE address bit
    // CACHE TAG IS REMAINING 13 bits of the 25 bit address + 1 bit for valid flag
    bram uint16 Dcachedata<input!>[2048] = uninitialized;
    bram uint14 Dcachetag<input!>[2048] = uninitialized;
    bram uint16 Icachedata<input!>[2048] = uninitialized;
    bram uint14 Icachetag<input!>[2048] = uninitialized;

    // ACTIVE FLAG
    uint1   active = 0;

    // CACHE TAG match flags
    uint1   Icachetagmatch := Icachetag.rdata == { 1b1, address[12,13] };
    uint1   Dcachetagmatch := Dcachetag.rdata == { 1b1, address[12,13] };

    // SIGN EXTENDER UNIT
    uint8   SE8nosign = uninitialized;
    int32   SE8sign = uninitialized;
    signextender8 signextender8unit (
        function3 <: function3,
        nosign <: SE8nosign,
        withsign :> SE8sign
    );
    uint16  SE16nosign = uninitialized;
    int32   SE16sign = uninitialized;
    signextender16 signextender16unit (
        function3 <: function3,
        nosign <: SE16nosign,
        withsign :> SE16sign
    );

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
    // 16 bit READ NO SIGN EXTENSION - INSTRUCTION / PART 32 BIT ACCESS
    readdata := address[28,1] ? ( Icache ? Icachedata.rdata : Dcachedata.rdata ) : ram.rdata;

    // 8/16 bit READ WITH OPTIONAL SIGN EXTENSION
    SE8nosign := address[28,1] ? ( Dcachedata.rdata[address[0,1] ? 8 : 0, 8] ) : ( ram.rdata[address[0,1] ? 8 : 0, 8] );
    SE16nosign := address[28,1] ? Dcachedata.rdata : ram.rdata;
    readdata8 := SE8sign;
    readdata16 := SE16sign;

    while(1) {
        if( readflag && address[28,1] ) {
            // SDRAM
            if( ( Icache && Icachetagmatch ) || Dcachetagmatch ) {
                // CACHE HIT
                active = 0;
            } else {
                // CACHE MISS
                active = 1;

                // READ FROM SDRAM
                sdram_io.addr = address;
                sdram_io.rw = 0;
                sdram_io.in_valid = 1;
                while( !sdram_io.done ) {}

                // WRITE RESULT TO ICACHE or DCACHE
                Icachetag.wenable = Icache;
                Dcachetag.wenable = ~Icache;
                Icachedata.wdata = sdram_io.data_out;
                Icachedata.wenable = Icache;
                Dcachedata.wdata = sdram_io.data_out;
                Dcachedata.wenable = ~Icache;

                active = 0;
            }
        }

        if( writeflag ) {
            if( address[28,1] ) {
                // SDRAM
                active = 1;

                // WRITE INTO CACHE
                Dcachedata.wdata = ( ( function3 & 3 ) == 0 ) ? ( address[0,1] ? { writedata[0,8], Dcachedata.rdata[0,8] } : { Dcachedata.rdata[8,8], writedata[0,8] } ) : writedata;
                Icachedata.wdata = ( ( function3 & 3 ) == 0 ) ? ( address[0,1] ? { writedata[0,8], Dcachedata.rdata[0,8] } : { Dcachedata.rdata[8,8], writedata[0,8] } ) : writedata;
                Dcachedata.wenable = 1;
                Dcachetag.wenable = 1;
                // CHECK IF ENTRY IS IN ICACHE AND UPDATE
                Icachedata.wenable = Icachetagmatch;

                // WRITE TO SDRAM
                sdram_io.addr = address;
                sdram_io.data_in = Dcachedata.wdata;
                sdram_io.rw = 1;
                sdram_io.in_valid = 1;
                while( !sdram_io.done ) {}

                active = 0;
            } else {
                // BRAM
                ram.wdata = ( ( function3 & 3 ) == 0 ) ? ( address[0,1] ? { writedata[0,8], ram.rdata[0,8] } : { ram.rdata[8,8], writedata[0,8] } ) : writedata;
                ram.wenable = 1;
                active = 0;
            }
        }
    }
}
