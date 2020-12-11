MEMORY
{
   ram (rwx) : ORIGIN = 0x10000000, LENGTH = 0x02000000
}

ENTRY(_start)

SECTIONS {
  .text 0x00000000 : {
        *(.text)
  } >ram
}
