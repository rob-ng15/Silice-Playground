#!/bin/bash

echo "LLVM/CLANG compile for SDCARD (B extension + float)  $1 to $2"
ARCH="riscv64"

AR="riscv64-elf-ar"
NM="riscv64-elf-nm"
RANLIB="riscv64-elf-ranlib"

CFLAGS="--target=riscv32 -ffunction-sections -fdata-sections -O2 -fno-builtin -fno-pic -fno-unroll-loops -menable-experimental-extensions -march=rv32imafcb0p93 -mabi=ilp32f"
INCLUDES="-I/usr/riscv32-elf/include/"
LFLAGS="--as-needed --gc-sections -m elf32lriscv -b elf -Tconfig_LLD.ld --no-relax"
LIBRARY="/usr/riscv64-elf/lib/rv32imafc/ilp32f/libc.a /usr/riscv64-elf/lib/rv32imafc/ilp32f/libm.a /usr/lib/gcc/riscv64-elf/11.1.0/rv32imafc/ilp32f/libgcc.a"

# Following based on FemtoRV compile scripts https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV
clang $CFLAGS -c -o build/crt0.o crt0.c
clang $CFLAGS $INCLUDES -c -o build/libPAWS.o c/PAWSlibrary.c
clang $CFLAGS $INCLUDES -S -o build/libPAWS.s c/PAWSlibrary.c
clang $CFLAGS $INCLUDES -c -o build/code.o $1
clang $CFLAGS $INCLUDES -S -o build/code.s $1
ld.lld $LFLAGS -o build/code.elf build/crt0.o build/code.o build/libPAWS.o $LIBRARY
$ARCH-elf-objcopy -O binary build/code.elf $2
