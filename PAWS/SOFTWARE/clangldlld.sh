#!/bin/bash

echo "COMPILING FOR SDCARD LOADING"
ARCH="riscv64"
echo "using $ARCH"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH=$PATH:$DIR/../../tools/fpga-binutils/mingw32/bin/

AR="riscv64-elf-ar"
NM="riscv64-elf-nm"
RANLIB="riscv64-elf-ranlib"

CFLAGS="--target=riscv32 -Ofast -fno-pic -fno-unroll-loops -menable-experimental-extensions -march=rv32imacb0p92 -mabi=ilp32 -mno-relax"
INCLUDES="-I/usr/riscv32-elf/include/"
LFLAGS="--as-needed -m elf32lriscv -b elf -Tconfig_c_SDRAM.ld --no-relax"
LIBRARY="/usr/riscv64-elf/lib/rv32imac/ilp32/libc.a /usr/riscv64-elf/lib/rv32imac/ilp32/libm.a /usr/lib/gcc/riscv64-elf/10.2.0/rv32imac/ilp32/libgcc.a"

# Following based on FemtoRV compile scripts https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV
clang $CFLAGS -c -o build/crt0.o crt0.c
clang $CFLAGS $INCLUDES -c -o build/libPAWS.o c/PAWSlibrary.c
$AR -cvq build/libPAWS.a build/libPAWS.o
clang $CFLAGS $INCLUDES -c -o build/code.o $1
ld.lld $LFLAGS -o build/code.elf build/code.o build/libPAWS.o $LIBRARY
$ARCH-elf-objcopy -O binary build/code.elf $2
