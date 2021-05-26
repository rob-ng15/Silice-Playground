#!/bin/bash

echo "COMPILING FOR INCLUSION IN THE BIOS"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH=$PATH:$DIR/../../tools/fpga-binutils/mingw32/bin/

  ARCH="riscv64"

echo "using $ARCH"

# Following based on FemtoRV compile scripts https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV
CFLAGS="--target=riscv32 -ffunction-sections -fdata-sections -Os -fno-builtin -fno-pic -fno-unroll-loops -march=rv32imac -mabi=ilp32"
LFLAGS="--as-needed --gc-sections -m elf32lriscv -b elf -Tconfig_LLD.ld --no-relax"
clang $CFLAGS -c -o build/code.o c/BIOS.c
clang $CFLAGS -c -o build/crt0.o crt0.c
ld.lld $LFLAGS -o build/code.elf build/crt0.o build/code.o
$ARCH-elf-objcopy -O binary build/code.elf build/BIOS.bin

