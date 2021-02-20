#!/bin/bash

echo "COMPILING FOR SDCARD LOADING"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH=$PATH:$DIR/../../tools/fpga-binutils/mingw32/bin/

  ARCH="riscv64"

echo "using $ARCH"

AR="riscv64-elf-ar"
NM="riscv64-elf-nm"
RANLIB="riscv64-elf-ranlib"

# Following based on FemtoRV compile scripts https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV
$ARCH-elf-gcc -ffunction-sections -fdata-sections -fno-unroll-loops -O2 -fno-builtin -fno-pic -I/usr/riscv32-elf/include/ -march=rv32imac -mabi=ilp32 -c -o build/libPAWS.o c/PAWSlibrary.c
$AR -cvq build/libPAWS.a build/libPAWS.o
$ARCH-elf-gcc -ffunction-sections -fdata-sections -fno-unroll-loops -O2 -fno-builtin -fno-pic  -I/usr/riscv32-elf/include/ -march=rv32imac -mabi=ilp32 -c -o build/code.o $1
$ARCH-elf-as -march=rv32imac -mabi=ilp32 -o build/crt0.o crt0.s
$ARCH-elf-ld --as-needed --gc-sections -m elf32lriscv -b elf32-littleriscv -Tconfig_c_SDRAM.ld --no-relax -o build/code.elf build/code.o build/libPAWS.o /usr/riscv32-elf/lib/rv32imac/ilp32/libc.a /usr/riscv32-elf/lib/rv32imac/ilp32/libm.a /usr/lib/gcc/riscv64-elf/10.2.0/rv32imac/ilp32/libgcc.a

$ARCH-elf-objcopy -O binary build/code.elf $2
