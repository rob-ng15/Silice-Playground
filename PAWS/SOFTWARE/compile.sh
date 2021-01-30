#!/bin/bash

echo "COMPILING FOR SDCARD LOADING"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH=$PATH:$DIR/../../tools/fpga-binutils/mingw32/bin/

  ARCH="riscv64"

echo "using $ARCH"

# Following based on FemtoRV compile scripts https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV
$ARCH-elf-gcc -fno-unroll-loops -O2 -fno-builtin -fno-pic -march=rv32imac -mabi=ilp32 -S c/PAWSlibrary.c -o build/libPAWS.s
$ARCH-elf-gcc -fno-unroll-loops -O2 -fno-builtin -fno-pic -march=rv32imac -mabi=ilp32 -c -o build/libPAWS.o c/PAWSlibrary.c
$ARCH-elf-ar -cvq build/libPAWS.a build/libPAWS.o

$ARCH-elf-gcc -fno-unroll-loops -O2 -fno-builtin -fno-pic -march=rv32imac -mabi=ilp32 -S $1 -o build/code.s
$ARCH-elf-gcc -fno-unroll-loops -O2 -fno-builtin -fno-pic -march=rv32imac -mabi=ilp32 -c -o build/code.o $1

$ARCH-elf-as -march=rv32imac -mabi=ilp32 -o build/crt0.o crt0.s

$ARCH-elf-ld -m elf32lriscv -b elf32-littleriscv -Tconfig_c_SDRAM.ld --no-relax -o build/code.elf build/code.o build/libPAWS.o

$ARCH-elf-objcopy -O verilog build/code.elf build/code.hex

# uncomment to see the actual code, usefull for debugging
$ARCH-elf-objcopy -O binary build/code.elf $2
#$ARCH-elf-objdump -D -b binary -m riscv build/code.bin

