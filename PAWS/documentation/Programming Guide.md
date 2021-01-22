# PAWS a Risc-V RV32IMCB CPU - Programming Guide

## COMPILING C CODE

Open a terminal in the SOFTWARE directory. Create your own C code in the c directory. Compile with ( for example the asteroids game ) ```./compile_SDRAM.sh c/asteroids.c```. This will create a file code.PAW which can be copied the root directory of a FAT16 formatted SDCARD and loaded via the included BIOS.

A small SDK providing helper functions (libPAWS) for the display and various I/O functions is provided and is automatically linked with the above compilation command.

A small template file is provided. It includes the PAWlibrary headers that define various functions for accessing the hardware. The function ```INITIALISEMEMORY();``` sets up the memory map passed from the BIOS. Code is then placed into the ```while(1)``` loop.

## templace.c file

```
#include "PAWSlibrary.h"

void main( void ) {
    INITIALISEMEMORY();

    while(1) {
    }
}
```

## PAWSlibrary

### MEMORY MAP

Address Range | Type | Usage
:----: | :----: | ----
0x0000 - 0x4000 | FAST BRAM | BIOS ( approximately 4k ).<br>STACK grows down from 0x4000.
0x8000 - 0xffff | I/O Registers | Communication to/from the PAWS hardware.<br>No direct hardware access is required, the PAWSlibrary provides functions for all aspects of the PAWS hardware.
0x10000000 - 0x12000000 | SDRAM | Program and data storage.<br>4k caches for data and instructions.

#### Memory Allocation

Variable | Type | Usage
---- | ---- | ----
MEMORYTOP | ```unsigned char *``` | Points to the top of unallocated memory.

Function | Parameters and Usage
---- | ----
```void INITIALISEMEMORY( void )``` | Sets up the memory map using parameters passed from the BIOS.<br>Allocates memory for SDCARD buffers and structures.
```unsigned char *memoryspace( unsigned int size )``` | Returns pointer to a buffer of at least ```size``` bytes, allocated from the top of the free memory space.
```unsigned char *filememoryspace( unsigned int size )``` | Returns pointer to a buffer of at least ```size``` bytes, allocated from the top of the free memory space for a file to be loaded into from the SDCARD.<br>Use this function for allocating file space, as it allocates enoughh space to allow for the blocks used on the SDCARD for storage.

### MACROS

### STRUCTURES AND TYPES

### SDCARD FILE SYSTEM FUNCTIONS

### STANDARD C FUNCTIONS OR EQUIVALENTS

