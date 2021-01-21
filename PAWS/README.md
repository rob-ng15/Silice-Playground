# PAWS a Risc-V RVIMCB CPU

* Written in Silice
    * Inspired by ICE-V by [ICE-V](https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice) by @sylefeb

A simple (single thread, no interrupts or exceptions/traps), Risc-V RV32IMCB CPU, matched to the display and peripherals from [j1eforth](https://github.com/rob-ng15/Silice-Playground/tree/master/j1eforth/DE10NANO-ULX3S) I set about creating this project as I wanted an easier way to write programs to test my design. I'm old enough that C was my main programming language, so a CPU that had gcc support was the obvious way forward, and Risc-V is a nice elegant design that wasn't too hard for a beginner at FPGA programming to implement.

## Overview

* CPU
    * 25MHz clock
        * Instructions take varying number of clock cycles for execution
            * 3 Pipeline Stages
                * Fetch ( starts partial decode )
                * Decode and Execute
                * Dispatch
        * RV32I instruction set
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
            * CSR ( Limited )
                * READ of TIMER[H], CYCLE[H] and INSTRET[H]
        * RV32M instruction set
            * HARDWARE MULTIPLICATION AND DIVISION UNITS
                * MUL MULH[[S]U]
                * DIV[U] REM[U]
        * RV32C instruction expansion
            * COMPRESSED ( 16 bit ) INSTRUCTION SUPPORT
                * Expanded to 32 bit instruction
                * Faster than 32 bit instructions due to less memory fetching
        * RV32B instructions ( __NOT TESTED__ )
            * Based on Draft Version from October 26 2020
                * Zba - sh1add sh2add sh3add
                * Zbb - clz ctz pcnt min[u] max[u] sext.[bh] andn orn xnor pack ror[i] orc.b
                * Zbc - clmul[rh]
                * Zbe - bdep bext pack[h]
                * zbf - bfp pack[h]
                * Zbp - andn orn xnor pack[hu] rol ror[i] grev[i] gorc[i] shfl[i] unshfl[i] xperm[nbh]
                * Zbr - ( todo crc32 )
                * Zbs - sbset[i] sbclr[i] sbinv[i] sbext[i]
                * Zbt - cmov cmix fsl fsr[i]
        * NOP __ALL OTHER INSTRUCTION CODES__

* MEMORY
    * 16K ( 8K x 16 bit) of RAM
        * FAST BRAM - used for BIOS
        * STACK POINTER AT TOP OF BRAM
    * 32K ( 8K x 32 bit ) of I/O Registers with 16 bit read / write
    * 32MB of SDRAM
        * 4K Instruction Cache
        * 4K Data Cache

* DISPLAY
    * HDMI 640 x 480 ouput
        * Background
        * Tilemap Layer
        * Lower Sprite Layer
        * Bitmap with GPU
            * Vector block drawer
        * Upper Sprite Layer
        * Character Map with TPU for character output and display/line clearing
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
    * Initialises the screen and CPU
    * Loads compiled PAW files from the SDCARD to SDRAM and executes
        * FAT16 on PARTITION 0 of SDCARD read via SPI

## BUILD and USAGE Instructions

Open a terminal in the ULX3S directory and type ```make ulx3s```. Wait. Upload your design your ULX3S with ```fujproj BUILD_ulx3s/build.bit```. Or download from this repository.

## COMPILING C CODE

Open a terminal in the SOFTWARE directory. Create your own C code in the c directory. Compile with ( for example the asteroids game ) ```./compile_SDRAM.sh c/asteroids.c```. This will create a file code.PAW which can be copied the root directory of a FAT16 formatted SDCARD and loaded via the included BIOS.

A small SDK providing helper functions (libPAWS) for the display and various I/O functions is provided and is automatically linked with the above compilation command. See the (WIP) documentation for details of the helper functions, or look at the asteroids.c amd maze.c examples.
