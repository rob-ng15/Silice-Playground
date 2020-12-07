MEMORY
{
   ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0x00002000
}

ENTRY(_start)

SECTIONS {
  .text 0x00000000 : {
        *(.text)
  } >ram
}
