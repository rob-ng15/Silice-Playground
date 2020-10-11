 # j1eforth for FOMU

## UART Implementation 
 
For communicating via a terminal the tinyfpga_bx_usbserial (https://github.com/stef/nb-fomu-hw) was implemented to provide a 115200 baud UART. A 512 character input and output buffer was added, allowing copy and paste of code into the terminal.

## Using j1eforth on the FOMU

Download the source code from this repository. Ensure that you have the required toolchain installed. Compile (on Linux) with `./fomu_hacker_USB_SPRAM.sh j1eforth.ice` within the source directory.

Or download the precompiled `j1eforth-FOMU-HACKER.dfu` file from this repository.

Upload the compiled bitstream to your FOMU with `dfu-util -D build.dfu`, or the downloaded bitstream with `dfu-util -D j1eforth-FOMU-HACKER.dfu` and connect via your chosen terminal, for minicom `minicom -D /dev/ttyACM0` (ACM0 may need replacing with an appropriate number on your machine).

These are for the __HACKER__ variant of the FOMU. Experimental support (not tested) is provided for the __PVT__ variant of the FOMU.

## Resources on the FOMU

Resource usage has been considerably reduced from my initial attempt at Silice coding, with considerable assistance from @sylefeb who has assisted in using blockrams for the dstack and rstack, and dual ported blockrams for the uart input and output FIFO buffers:

```
Info: Device utilisation:
Info:            ICESTORM_LC:  2849/ 5280    53%
Info:           ICESTORM_RAM:    21/   30    70%
Info:                  SB_IO:    12/   96    12%
Info:                  SB_GB:     8/    8   100%
Info:           ICESTORM_PLL:     0/    1     0%
Info:            SB_WARMBOOT:     0/    1     0%
Info:           ICESTORM_DSP:     0/    8     0%
Info:         ICESTORM_HFOSC:     0/    1     0%
Info:         ICESTORM_LFOSC:     0/    1     0%
Info:                 SB_I2C:     0/    2     0%
Info:                 SB_SPI:     0/    2     0%
Info:                 IO_I3C:     0/    2     0%
Info:            SB_LEDDA_IP:     0/    1     0%
Info:            SB_RGBA_DRV:     1/    1   100%
Info:         ICESTORM_SPRAM:     4/    4   100%
Info:         ICESTORM_SPRAM:     4/    4   100% 

// Timing estimate: 38.77 ns (25.79 MHz) (HACKER)
// Timing estimate: 38.80 ns (25.77 MHz) (PVT)
```

### INIT stages

Due to the size of the block ram on the FOMU (120kbit or 7680 x 16bit) and the J1+ CPU requiring 256kbit (16384 x 16bit) of RAM, the J1+ CPU on the FOMU copies the j1eforth code from an initialised block ram to SPRAM, and uses the SPRAM for the J1+ CPU.

INIT | Action
:-----: | :-----:
0 | 0 the SPRAM. <br> <br> Due to the latency, this is controlled by CYCLE (pipeline).
1 | COPY the j1eforth ROM to SPRAM. <br> <br> Due to latency, this is controoled by CYCLE (pipeline).
2 | SPARE (not used in the J1+ CPU).
3 | Start the J1+ CPU at pc==0 from SPRAM.

### Pipeline / CYCLE logic

Due to blockram and SPRAM latency, there needs to be a pipeline for the J1+ CPU on the FOMU, which is set to 0 to 12 stages. These are used as follows:

CYCLE | Action
:-----: | :-----:
ALL <br> (at entry to INIT==3 loop) | Check for input from the UART, put into buffer. <br> Check if output in the UART buffer and send to UART. <br> __NOTE:__ To stop a race condition, uartOutBufferTop = newuartOutBufferTop is updated after output.
0 | blockram: Read data stackNext and rstackTop, started in CYCLE==9. <br> <br> SPRAM: Start the read of memory position [stackTop] by setting the SPRAM sram_address and sram_readwrite flag. <br> This is done speculatively in case the ALU needs this memory later in the pipeline.
3 | Complete read of memory position [stackTop] from SPRAM by reading sram_data_read.
4 | Start read of the instruction at memory position [pc] by setting sram_address and sram_readwrite flag.
7 | Complete read of the instruction at memory position [pc] by reading sram_data_read. <br> <br> *The instruction is decoded automatically by the continuos assigns := block at the top of the code.*
8 | Instruction Execution <br> <br> Determine if LITERAL, BRANCH, BRANCH, CALL or ALU. <br> <br> In the ALU (J1 CPU block) the UART input buffer, UART status register, RGB LED status, input buttons or memory is selected as appropriate. The UART buffers and the speculative memory read of [stackTop] are used to allow __ALL__ ALU operations to execute in one cycle.<br> <br> At the end of the ALU if a write to memory is required, this is initiated by setting the sram_address, sram_data_write and sram_readwrite flag. This will be completed by CYCLE==12. <br> <br> Output to UART output buffer or the RGB LED is performed here if a write to an I/O address, not memory, is requested.
9 | Start the writing to the block ram for the data and return stacks. This will be completed by CYCLE==10.
10 | Update all of the J1+ CPU pointers for the data and return stacks, the program counter, and stackTop. <br> <br> Start the reading of the data and return stacks. This will be completed by CYCLE==11, but not actually read until the return to CYCLE==0.
12 | Reset the sram_readwrite flag, to complete any memory write started in CYCLE==8 in the ALU.
ALL <br> (at end of INIT==3 loop) | Reset the UART output if any character was transmitted. <br> <br> Move to the next CYCLE.

