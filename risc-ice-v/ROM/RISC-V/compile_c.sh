#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH=$PATH:$DIR/../../tools/fpga-binutils/mingw32/bin/

  ARCH="riscv64"

echo "using $ARCH"

# Following based on FemtoRV compile scripts https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV

$ARCH-elf-gcc -fno-unroll-loops -O1 -fno-pic -march=rv32im -mabi=ilp32 -S $1 -o build/code.s
$ARCH-elf-gcc -fno-unroll-loops -O1 -fno-pic -march=rv32im -mabi=ilp32 -c -o build/code.o $1

$ARCH-elf-as -march=rv32im -mabi=ilp32 -o crt0.o crt0.s

$ARCH-elf-ld -m elf32lriscv -b elf32-littleriscv -Tconfig_c.ld --no-relax -o build/code.elf build/code.o

$ARCH-elf-objcopy -O verilog build/code.elf build/code.hex

# uncomment to see the actual code, usefull for debugging
$ARCH-elf-objcopy -O binary build/code.elf build/code.bin
$ARCH-elf-objdump -D -b binary -m riscv build/code.bin
