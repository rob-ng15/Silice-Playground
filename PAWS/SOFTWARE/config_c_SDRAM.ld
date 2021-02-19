MEMORY
{
   ram (rwx) : ORIGIN = 0x10000000, LENGTH = 0x800000
}

ENTRY(_start)

SECTIONS {
  .text 0x10000000 : {
        build/crt0.o (.text)
        *(.text)
        *(.sdata)
        *(.data)
        *(.srodata)
        *(.rodata)
        *(.rodata.str1.4)
        . = ALIGN(8);
        _bss_start = ABSOLUTE(.) ;
        *(.bss)
        _bss_end = ABSOLUTE(.) ;
  } >ram
  . = ALIGN(8);
PROVIDE( _end = .);
}
