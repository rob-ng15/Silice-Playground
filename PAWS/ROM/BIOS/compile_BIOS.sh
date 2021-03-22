#!/bin/bash

echo "COMPILING FOR INCLUSION IN THE BIOS"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH=$PATH:$DIR/../../tools/fpga-binutils/mingw32/bin/

  ARCH="riscv64"

echo "using $ARCH"

# Following based on FemtoRV compile scripts https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV

$ARCH-elf-gcc -fwhole-program -ffunction-sections -fdata-sections -fno-unroll-loops -Os -fno-builtin -fno-pic -march=rv32imac -mabi=ilp32 -c -o build/code.o c/BIOS.c
$ARCH-elf-gcc -Os -fno-pic -march=rv32imac -mabi=ilp32 -c -o build/crt0.o crt0.c
$ARCH-elf-ld -m elf32lriscv -b elf32-littleriscv -Tconfig_c.ld --no-relax -o build/code.elf build/code.o
$ARCH-elf-objcopy -O binary build/code.elf build/BIOS.bin

