# PAWS a Risc-V RVIMC CPU

* Written in Silice
    * Based upon ICE-V by [ICE-V](https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice) by @sylefeb

A simple (single thread, no interrupts or exceptions/traps), Risc-V RV32IMC CPU, matched to the display and peripherals from [j1eforth](https://github.com/rob-ng15/Silice-Playground/tree/master/j1eforth/DE10NANO-ULX3S) Inspired by the need for an easier way to program and use the CPU than Forth.

__ULX3S only at present__

## ULX3S Facilities

* CPU
    * 25MHz clock
        * Instructions take varying number of clock cycles for execution
            * 3 Pipeline Stages
                * Fetch ( starts partial decode )
                * Decode and Execute
                * Dispatch
        * RV32IMC instruction set ( selection of )
            * AUIPC
            * LUI
            * JAL and JALR
            * BRANCH
            * LOAD
            * STORE
            * INTEGER OPERATION WITH IMMEDIATE PARAMETER
                * ADDI
                * SLTI[U]
                * ANDI ORI XORI
                * SLI SRLI SRAI
            * INTEGER OPERATION WITH REGISTER PARAMETER
                * ADD SUB
                * SLT[U]
                * AND OR XOR
                * SLL SRL SRA
            * HARDWARE MULTIPLICATION AND DIVISION UNITS
                * MUL MULH[[S]U]
                * DIV[U] REM[U]
            * COMPRESSED ( 16 bit ) INSTRUCTION SUPPORT
                * Expanded to 32 bit instruction
                * 1 cycle faster than 32 bit instructions due to less memory fetching
            * CSR ( Limited )
                * READ of TIMER[H], CYCLE[H] and INSTRET[H]
            * NOP __ALL OTHER INSTRUCTION CODES__

* MEMORY
    * 16K ( 8K x 16 bit) of RAM
        * FAST BRAM - used for BIOS
        * STACK POINTER AT TOP OF BRAM
    * 32K ( 8K x 32 bit ) of I/O Memory with 16 bit read / write
    * 32MB of SDRAM with 4K Instruction and 4K Data Caches

* DISPLAY
    * HDMI 640 x 480 ouput
        * Background
        * Tilemap Layer
        * Lower Sprite Layer
        * Bitmap with GPU
            * Vector block drawer
        * Upper Sprite Layer
        * Character Map with TPU
        * Terminal

* PERIPHERALS
    * UART ( via US1 on the ULX3S )
        * 115200 baud
    * LEDS ( 8 on board leds )
    * BUTTONS ( 6 on board buttons )
    * TIMERS ( 1hz and 1khz )
    * STEREO AUDIO
    * SDCARD via SPI
        * FAT16 on PARTITION 0 only

* BIOS
    * FAT16 on PARTITION 0 of SDCARD read via SPI
    *
## BUILD and USAGE Instructions

Open a terminal in the ULX3S directory and type ```make ulx3s```. Wait. Upload your design your ULX3S with ```fujproj BUILD_ulx3s/build.bit```. Or download from this repository.

## COMPILING C CODE
Open a terminal in the SOFTWARE directory. Create your own C code in the c directory. Compile with ( for example the asteroids game ) ```./compile_SDRAM.sh c/asteroids.c```. This will create a file code.PAW which can be copied the root directory of a FAT16 formatted SDCARD and loaded via the included BIOS.

A small SDK providing helper functions (libPAWS) for the display and various I/O functions is provided and is automatically linked with the above compilation command. See the (WIP) documentation for details of the helper functions, or look at the asteroids.c amd maze.c examples.
