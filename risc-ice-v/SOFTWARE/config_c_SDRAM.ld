MEMORY
{
   ram (rwx) : ORIGIN = 0x10000000, LENGTH = 0x02000000
}

ENTRY(_start)

SECTIONS {
  .text 0x10000000 : {
        build/crt0.o (.text)
        *(.text)
        *(.sdata)
        *(.srodata)
        *(.rodata)
        *(.rodata.str1.4)
        *(.data)
  } >ram
}
