#!/bin/bash

echo "LLVM/CLANG compile for SDCARD  $1 to $2"
ARCH="riscv64"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH=$PATH:$DIR/../../tools/fpga-binutils/mingw32/bin/

AR="riscv64-elf-ar"
NM="riscv64-elf-nm"
RANLIB="riscv64-elf-ranlib"

CFLAGS="--target=riscv32 -ffunction-sections -fdata-sections -Os -fno-pic -fno-unroll-loops -march=rv32imac -mabi=ilp32"
INCLUDES="-I/usr/riscv32-elf/include/"
#LFLAGS="--as-needed --gc-sections -m elf32lriscv -b elf32-littleriscv -Tconfig_c_SDRAM.ld --no-relax"
LFLAGS="--as-needed --gc-sections -m elf32lriscv -b elf -Tconfig_LLD.ld --no-relax"
LIBRARY="/usr/riscv64-elf/lib/rv32imac/ilp32/libc.a /usr/riscv64-elf/lib/rv32imac/ilp32/libm.a /usr/lib/gcc/riscv64-elf/10.2.0/rv32imac/ilp32/libgcc.a"

# Following based on FemtoRV compile scripts https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV
clang $CFLAGS -c -o build/crt0.o crt0.c
clang $CFLAGS $INCLUDES -c -o build/libPAWS.o c/PAWSlibrary.c
#clang $CFLAGS $INCLUDES -S -o build/code.s $1
clang $CFLAGS $INCLUDES -c -o build/code.o $1
#$ARCH-elf-ld $LFLAGS -o build/code.elf build/code.o build/libPAWS.o $LIBRARY
ld.lld $LFLAGS -o build/code.elf build/crt0.o build/code.o build/libPAWS.o $LIBRARY
$ARCH-elf-objcopy -O binary build/code.elf $2
