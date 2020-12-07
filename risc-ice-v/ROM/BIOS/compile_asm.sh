#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH=$PATH:$DIR/../../tools/fpga-binutils/mingw32/bin/

  ARCH="riscv64"

  echo "using $ARCH"

# Following based on FemtoRV compile scripts https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV

$ARCH-elf-as -march=rv32i -mabi=ilp32 -o build/code.o $1

$ARCH-elf-ld -m elf32lriscv -b elf32-littleriscv -Tconfig_asm.ld --no-relax -o build/code.elf build/code.o

$ARCH-elf-objcopy -O verilog build/code.elf build/code.hex

$ARCH-elf-objcopy -O binary build/code.elf build/code.bin
$ARCH-elf-objdump -D -b binary -m riscv build/code.bin
