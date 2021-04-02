#!/bin/bash

echo "COMPILING FOR SDCARD LOADING"
ARCH="riscv64"
echo "using $ARCH"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH=$PATH:$DIR/../../tools/fpga-binutils/mingw32/bin/

AR="riscv64-elf-ar"
NM="riscv64-elf-nm"
RANLIB="riscv64-elf-ranlib"

CFLAGS="-march=rv32imac -mabi=ilp32 -ffunction-sections -fdata-sections -O2 -fno-pic -fno-unroll-loops"
LFLAGS=" --as-needed --gc-sections -m elf32lriscv -b elf32-littleriscv --no-relax"
LCONFIG="-Tconfig_c_SDRAM.ld"
INCLUDE="-I/usr/riscv32-elf/include/"
LIBRARY="/usr/riscv64-elf/lib/rv32imac/ilp32/libc.a /usr/riscv64-elf/lib/rv32imac/ilp32/libm.a /usr/lib/gcc/riscv64-elf/10.2.0/rv32imac/ilp32/libgcc.a"

# Following based on FemtoRV compile scripts https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV
$ARCH-elf-gcc $CFLAGS -c -o build/crt0.o crt0.c
$ARCH-elf-gcc $INCLUDE $CFLAGS -c -o build/libPAWS.o c/PAWSlibrary.c
#$AR -cvq build/libPAWS.a build/libPAWS.o
$ARCH-elf-gcc $INCLUDE $CFLAGS -c -o build/code.o $1
$ARCH-elf-ld $LFLAGS $LCONFIG -o build/code.elf build/code.o build/libPAWS.o $LIBRARY
$ARCH-elf-objcopy -O binary build/code.elf $2
