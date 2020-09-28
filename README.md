# Silice-Playground
My Silice (https://github.com/sylefeb/Silice) Coding Experimental Area

Examples to play with FOMU, DE10NANO with MiSTer SDRAM, USB HUB and I/O BOARD, ULX3S (awaiting!) via Silice.

Attempting to port the j1eforth from FOMU to DE10NANO, whilst the design compiles, and debugging shows that _something_ is happening, there is no UART communication.

```
Warning (13024): Output pins are stuck at VCC or GND
	Warning (13410): Pin "tx" is stuck at VCC
```

Is the error message that seems to be the problem, and at present I can see no way around it!
