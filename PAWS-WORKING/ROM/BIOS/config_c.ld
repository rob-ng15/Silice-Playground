MEMORY
{
   ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0x00004000
}

ENTRY(_start)

SECTIONS {
    .text 0x00000000 : {
        build/crt0.o (.text)
        *(.text*)
    } > ram
    .sdata :
    {
        *(.sdata*)
    } > ram
    .data :
    {
        *(.data*)
    } > ram
    .srodata :
    {
        *(.srodata*)
    } > ram
    .rodata :
    {
        *(.rodata*)
    } > ram
    .bss (NOLOAD) :
    {
       _bss_start = . ;
       *(.bss*)
       *(COMMON)
       _bss_end = . ;
    } > ram
}
