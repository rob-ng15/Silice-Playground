# RISC-ICE-V

* Written in Silice
    * Based upon ICE-V by [ICE-V](https://github.com/sylefeb/Silice/blob/master/projects/ice-v/ice-v.ice) by @sylefeb

A simple Risc-V RV32IM 25mhz cpu, matched to the display and peripherals from [j1eforth](https://github.com/rob-ng15/Silice-Playground/tree/master/j1eforth/DE10NANO-ULX3S). Inspired by the need for an easier way to program and use the CPU than Forth.

__ULX3S only at present__

## ULX3S Facilities

* CPU
    * 25MHz clock
        * Instructions take varying number of clock cycles for execution
            * 3 Pipeline Stages
                * Fetch ( starts partial decode )
                * Decode and Execute
                * Dispatch
        * RV32IM instruction set ( selection of )
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
                    * 2 x main clock ( 50mhz ) operation
            * NOP __ALL OTHER INSTRUCTION CODES__
* MEMORY
    * 32K ( 16K x 16 bit) of RAM ( with aligned and misaligned 32 bit read / writes )
    * 32K ( 8K x 32 bit ) of I/O Memory with 16 bit read / write
* DISPLAY
    * HDMI 640 x 480 ouput
        * Background [Background.md](documentation/Background.md)
        * Tilemap Layer [Tilemap.md](documentation/Tilemap.md)
        * Lower Sprite Layer [Sprites.md](documentation/Sprites.md)
        * Bitmap with GPU [Bitmap and GPU.md](documentation/Bitmap%20and%20GPU.md)
            * Display list drawer [Display List.md](documentation/Display%20List.md)
            * Vector block drawer [Vectors.md](documentation/Vectors.md)
        * Upper Sprite Layer [Sprites.md](documentation/Sprites.md)
        * Character Map with TPU [Character Map and TPU.md](documentation/Character%20Map%20and%20TPU.md)
        * Terminal [Terminal.md](documentation/Terminal.md)
* PERIPHERALS
    * UART ( via US1 on the ULX3S )
        * 115200 baud
    * LEDS ( 8 on board leds )
    * BUTTONS ( 6 on board buttons )
    * TIMERS ( 1hz and 1khz )
    * STEREO AUDIO ( 2 tone polyphonic per channel )

__Not all documentation is in place yet. I/O memory mapping not yet finalised.__

## BUILD and USAGE Instructions

Open a terminal in the ULX3S directory and type ```make ulx3s```. Wait. Upload your design your ULX3S with ```fujproj BUILD_ulx3s/build.bit```. Or download from this repository.

## COMPILING C CODES

Open a terminal in the ROM/RISC-V directory. Create your own C code in the c directory. Compile with ( for example the asteroids game ) ```./compile_c.sh c/asteroids.c```. Open build/code.bin in okteta. From the menu select File -> Export -> C Array. Use the __unsigned short__ option, save the output as ```code.inc```. Open ```code.inc``` in kwrite or kate, delete the first two and the last lines. Replace ```0x``` with ```16h``` and save as ```BIOS.inc``` in the ROM directory.

Follow the build instructions above and your program will launch once the code has compiled.
