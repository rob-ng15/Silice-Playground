// RISC-ICE-V
// inspired by https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice
//
// A simple Risc-V RV32IMC processor ( with partial B extension implementation )

// RISC-V - MAIN CPU LOOP
//          ALU FUNCTIONALITY LISTED IN mathematics.ice

algorithm PAWSCPU (
    output  uint3   function3,
    output  uint32  address,
    output  uint16  writedata,
    output  uint1   writememory,
    input   uint16  readdata,
    output  uint1   readmemory,
    output  uint1   Icacheflag,

    input   uint1   memorybusy
) <autorun> {
    // RISC-V REGISTERS
    simple_dualport_bram int32 registers_1 <input!> [64] = { 0, pad(0) };
    simple_dualport_bram int32 registers_2 <input!> [64] = { 0, pad(0) };
    simple_dualport_bram int32 registers_3 <input!> [64] = { 0, pad(0) };

    // RISC-V PROGRAM COUNTER AND STATUS
    uint32  pc = 0;
    uint32  pcPLUS2 = uninitialized;
    uint32  nextPC = uninitialized;
    uint1   compressed = uninitialized;
    uint4   floatingpoint = uninitialized;
    uint1   takeBranch = uninitialized;
    uint1   incPC = uninitialized;
    uint32  instruction = uninitialized;

    // TEMPORARY STORAGE FOR 16 BIT lowWordER PART OF 32 BIT WORD
    uint16  lowWord = uninitialized;

    // RISC-V REGISTER WRITER
    int32   result = uninitialized;
    int32   Aresult = uninitialized;
    uint1   writeRegister = uninitialized;

    // RISC-V REGISTER READER
    int32   sourceReg1 = uninitialized;
    int32   sourceReg2 = uninitialized;
    int32   sourceReg3 = uninitialized;

    // RISC-V 32 BIT INSTRUCTION DECODER
    int32   immediateValue = uninitialized;
    uint7   opCode = uninitialized;
    uint7   function7 = uninitialized;
    uint5   IshiftCount = uninitialized;
    uint5   rs1 = uninitialized;
    uint5   rs2 = uninitialized;
    uint5   rs3 = uninitialized;
    uint5   rd = uninitialized;

    // RISC-V ADDRESS GENERATOR
    uint32  branchAddress = uninitialized;
    uint32  jumpAddress = uninitialized;
    uint32  loadAddress = uninitialized;
    uint32  storeAddress = uninitialized;
    uint32  AUIPCLUI = uninitialized;

    // CSR REGISTERS
    CSRblock CSR(
        instruction <: instruction
    );

    // MEMORY ACCESS FLAGS
    readmemory := 0;
    writememory := 0;

    // REGISTER Read/Write Flags
    registers_1.wenable1 := 1;
    registers_2.wenable1 := 1;
    registers_3.wenable1 := 1;

    // CSR instructions retired increment flag
    CSR.incCSRinstret := 0;

    while(1) {
        // RISC-V
        writeRegister = 0;
        takeBranch = 0;
        incPC = 1;

        // FLOATING POINT REGISTER FLAG
        // { rs1 is float, rs2 is float, rs3 is float, rd is float }
        floatingpoint = 4b0000;

        // FETCH + EXPAND COMPRESSED INSTRUCTIONS
        address = pc;
        Icacheflag = 1;
        readmemory = 1;
        while( memorybusy ) {}

        compressed = ( readdata[0,2] != 2b11 );

        switch( readdata[0,2] ) {
            case 2b00: { ( instruction ) = compressed00( readdata ); }
            case 2b01: { ( instruction ) = compressed01( readdata ); }
            case 2b10: { ( instruction ) = compressed10( readdata ); }
            case 2b11: {
                // 32 BIT INSTRUCTION
                lowWord = readdata;
                address = pc + 2;
                readmemory = 1;
                while( memorybusy ) {}
                ( instruction ) = halfhalfword( readdata, lowWord );
            }
        }

        // DECODE + REGISTER FETCH
        // HAPPENS AUTOMATICALLY in DECODE AND REGISTER UNITS
        ( opCode, function3, function7, rs1, rs2, rs3, rd, immediateValue, IshiftCount ) = decoder( instruction );
        ( registers_1, registers_2, registers_3, sourceReg1, sourceReg2, sourceReg3 ) = registersREAD( registers_1, registers_2, registers_3, rs1, rs2, rs3, floatingpoint );
        ( nextPC, branchAddress, jumpAddress, AUIPCLUI, storeAddress, loadAddress ) = addressgenerator( opCode, pc, compressed, sourceReg1, immediateValue );

        // EXECUTE
        switch( opCode[2,5] ) {
            case 5b01101: {
                // LUI
                writeRegister = 1;
                result = AUIPCLUI;
            }
            case 5b00101: {
                // AUIPC
                writeRegister = 1;
                result = AUIPCLUI;
            }
            case 5b11011: {
                // JAL
                writeRegister = 1;
                incPC = 0;
                result = nextPC;
            }
            case 5b11001: {
                // JALR
                writeRegister = 1;
                incPC = 0;
                result = nextPC;
            }
            case 5b11000: {
                // BRANCH
                ( takeBranch ) = branchcomparison( opCode, function3, sourceReg1, sourceReg2 );
            }
            case 5b00000: {
                // LOAD
                writeRegister = 1;
                address = loadAddress;
                Icacheflag = 0;
                readmemory = 1;
                while( memorybusy ) {}
                switch( function3 & 3 ) {
                    case 2b00: { ( result ) = signextender8( function3, loadAddress, readdata ); }
                    case 2b01: { ( result ) = signextender16( function3, readdata ); }
                    case 2b10: {
                        // 32 bit READ as 2 x 16 bit
                        lowWord = readdata;
                        address = loadAddress + 2;
                        readmemory = 1;
                        while( memorybusy ) {}
                        ( result ) = halfhalfword( readdata, lowWord );
                    }
                }
            }
            case 5b01000: {
                // STORE
                // WRITE 8, 16 and LOWER 16 of 32 bits
                address = storeAddress;
                Icacheflag = 0;
                writedata = sourceReg2[0,16];
                writememory = 1;
                while( memorybusy ) {}
                if(  ( function3 & 3 ) == 2b10 ) {
                    // WRITE UPPER 16 of 32 bits
                    address = storeAddress + 2;
                    writedata = sourceReg2[16,16];
                    writememory = 1;
                    while( memorybusy ) {}
                }
            }
            case 5b00100: {
                // ALUI ( BASE + SOME B EXTENSION )
                writeRegister = 1;
                ( result ) = aluI( opCode, function3, function7, immediateValue, IshiftCount, sourceReg1, sourceReg3 );
            }
            case 5b01100: {
                // ALUR ( BASE + M EXTENSION + SOME B EXTENSION )
                writeRegister = 1;
                switch( function7 ) {
                    case 7b0000001: {
                        switch( function3[2,1] ) {
                            case 1b0: { ( result ) = multiplication( function3, sourceReg1, sourceReg2 ); }
                            case 1b1: { ( result ) = divideremainder( function3, sourceReg1, sourceReg2 ); }
                        }
                    }
                    default: { ( result ) = aluR( opCode, function3, function7, rs1, sourceReg1, sourceReg2, sourceReg3 ); }
                }
            }
            case 5b11100: {
                // CSR
                writeRegister = 1;
                result = CSR.result;
            }
            case 5b01011: {
                // ATOMIC OPERATIONS
                switch( function7[2,5] ) {
                    case 5b00010: {
                        // LR.W
                        writeRegister = 1;
                        address = sourceReg1;
                        readmemory = 1;
                        while( memorybusy ) {}
                        lowWord = readdata;
                        address = sourceReg1 + 2;
                        readmemory = 1;
                        while( memorybusy ) {}
                        ( result ) = halfhalfword( readdata, lowWord );
                    }
                    case 5b00011: {
                        // SC.W
                        writeRegister = 1;
                        result = 0;

                        address = sourceReg1;
                        writedata = sourceReg2[0,16];
                        writememory = 1;
                        while( memorybusy ) {}
                        address = sourceReg1 + 2;
                        writedata = sourceReg2[16,16];
                        writememory = 1;
                        while( memorybusy ) {}
                    }
                    default: {
                        // ATOMIC LOAD - MODIFY - STORE
                        writeRegister = 1;
                        Icacheflag = 0;

                        // LOAD 32 bit
                        address = sourceReg1;
                        readmemory = 1;
                        while( memorybusy ) {}
                        lowWord = readdata;
                        address = sourceReg1 + 2;
                        readmemory = 1;
                        while( memorybusy ) {}
                        ( result ) = halfhalfword( readdata, lowWord );

                        ( Aresult ) = aluA( function7, result, sourceReg2 );

                        // STORE 32 bit
                        address = sourceReg1;
                        writedata = Aresult[0,16];
                        writememory = 1;
                        while( memorybusy ) {}
                        address = sourceReg1 + 2;
                        writedata = Aresult[16,16];
                        writememory = 1;
                        while( memorybusy ) {}
                    }
                }
            }

            // SINGLE PRECISION FLOATING POINT INSTRUCTIONS
            case 5b00001: {
                // FLW
            }
            case 5b01001: {
                // FSW
            }
            case 5b10100: {
                // SINGLE PRECISION FLOATING POINT ALU OPERATIONS
            }
            default: {
                // SINGLE PRECISION FMADD FMSUB FNMSUB FNMADD
            }
        }

        // DISPATCH INSTRUCTION
        ( registers_1, registers_2, registers_3 ) = registersWRITE( registers_1, registers_2, registers_3, rd, writeRegister, floatingpoint, result );
        ( pc ) = newPC( opCode, incPC, nextPC, takeBranch, branchAddress, jumpAddress, loadAddress );

        // Update CSRinstret
        CSR.incCSRinstret = 1;
    } // RISC-V
}
