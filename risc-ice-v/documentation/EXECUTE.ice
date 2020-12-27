        switch( opCode[4,1] ) {
            case 1b0: {
                // JAL JALR BRANCH LOAD STORE
                switch( opCode[6,1] ) {
                    case 1b0: {
                        // LOAD STORE
                        switch( opCode[5,1] ) {
                            case 1b0: {
                                // LOAD
                                writeRegister = 1;
                                address = loadAddress;
                                Icacheflag = 0;
                                readmemory = 1;
                                while( memorybusy ) {}
                                switch( function3 & 3 ) {
                                    case 2b10: {
                                        // 32 bit READ as 2 x 16 bit
                                        LOW = readdata;
                                        address = loadAddressPLUS2;
                                        readmemory = 1;
                                        while( memorybusy ) {}
                                        HIGH = readdata;
                                        result = HIGHLOW;
                                    }
                                    default: {
                                        // 8/16 bit with optional sign extension
                                        result = ( ( function3 & 3 ) == 0 ) ? readdata8 : readdata16;
                                    }
                                }
                            }
                            case 1b1: {
                                // STORE
                                // WRITE 8, 16 and LOWER 16 of 32 bits
                                address = storeAddress;
                                writedata = sourceReg2LOW;
                                writememory = 1;
                                while( memorybusy ) {}
                                if(  ( function3 & 3 ) == 2b10 ) {
                                    // WRITE UPPER 16 of 32 bits
                                    address = storeAddressPLUS2;
                                    writedata = sourceReg2HIGH;
                                    writememory = 1;
                                    while( memorybusy ) {}
                                }
                            }
                        }
                    }
                    case 1b1: {
                        // JAL JALR BRANCH
                        switch( opCode[2,1] ) {
                            case 1b0 : {
                                // BRANCH
                                takeBranch = BRANCHtakeBranch;
                            }
                            case 1b1: {
                                // JAL JALR
                                writeRegister = 1;
                                incPC = 0;
                                result = nextPC;
                            }
                        }
                    }
                }
            }
            case 1b1: {
                // LUI AUIPC ALU
                switch( opCode[2,1] ) {
                    case 1b0: {
                        // ALU
                        writeRegister = 1;
                        if( opCode[5,1] && function7[0,1] ) {
                            ALU.start = 1;
                            while( ALU.busy ) {}
                        }
                        result = ( opCode[5,1] && function7[0,1] ) ? ALU.Mresult : ALU.result;
                    }
                    case 1b1: {
                        // AUIPC LUI
                        writeRegister = 1;
                        result = AUIPCLUI;
                    }
                }
            }
        }

