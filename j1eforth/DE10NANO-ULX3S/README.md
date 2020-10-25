# j1eforth

## DE10NANO and ULX3S Enhancements

* Display
    * VGA for the DE10NANO
    * HDMI for the ULX3S
* PS/2 Keyboard
    * ULX3S has keyboard input (not yet implemented)
    * PS/2 takes priority over the UART
* J1+ CPU
    * 50MHz operation
    * 5 clock cycles per operation against 13 clock cycles per operation on the FOMU, giving an effective CPU running at 10MHz

For communication with j1eforth there is a UART which provides input and output, output is duplicated on the terminal display. The ULX3S eventually will have PS/2 keyboard input via the us2 connector and a USB OTG and PS/2 to USB converter.

__DE10NANO__ Open a terminal in the DE10NANO directory and type ```make de10nano```. Wait. Upload your design your DE10NANO with ```quartus_pgm -m jtag -o "p;BUILD_de10nano/build.sof@2"```. Or download from this repository.

__ULX3S__ Open a terminal in the ULX3S directory and type ```make ulx3s```. Wait. Upload your design your ULX3S with ```fujproj BUILD_ulx3s/build.bit```. Or download from this repository.

### Resource Usage (DE10NANO)

__*Not necessarily the most recent build, used for indicative purporses and monitoring during coding*__

```
Family : Cyclone V
Device : 5CSEBA6U23I7
Timing Models : Final
Logic utilization (in ALMs) : 6,724 / 41,910 ( 16 % )
Total registers : 4176
Total pins : 36 / 314 ( 11 % )
Total virtual pins : 0
Total block memory bits : 2,668,320 / 5,662,720 ( 47 % )
Total RAM Blocks : 368 / 553 ( 67 % )
Total DSP Blocks : 5 / 112 ( 4 % )
Total HSSI RX PCSs : 0
Total HSSI PMA RX Deserializers : 0
Total HSSI TX PCSs : 0
Total HSSI PMA TX Serializers : 0
Total PLLs : 1 / 6 ( 17 % )
Total DLLs : 0 / 4 ( 0 % )
```

### Resource Usage (ULX3S)

__*Not necessarily the most recent build, used for indicative purporses and monitoring during coding*__

```
Info: Device utilisation:
Info:          TRELLIS_SLICE: 17707/41820    42%
Info:             TRELLIS_IO:    34/  365     9%
Info:                   DCCA:     4/   56     7%
Info:                 DP16KD:   183/  208    87%
Info:             MULT18X18D:     8/  156     5%
Info:                 ALU54B:     0/   78     0%
Info:                EHXPLLL:     2/    4    50%
Info:                EXTREFB:     0/    2     0%
Info:                   DCUA:     0/    2     0%
Info:              PCSCLKDIV:     0/    2     0%
Info:                IOLOGIC:     0/  224     0%
Info:               SIOLOGIC:     8/  141     5%
Info:                    GSR:     0/    1     0%
Info:                  JTAGG:     0/    1     0%
Info:                   OSCG:     0/    1     0%
Info:                  SEDGA:     0/    1     0%
Info:                    DTR:     0/    1     0%
Info:                USRMCLK:     0/    1     0%
Info:                CLKDIVF:     0/    4     0%
Info:              ECLKSYNCB:     0/   10     0%
Info:                DLLDELD:     0/    8     0%
Info:                 DDRDLL:     0/    4     0%
Info:                DQSBUFM:     0/   14     0%
Info:        TRELLIS_ECLKBUF:     0/    8     0%
Info:           ECLKBRIDGECS:     0/    2     0%
```

## VGA/HDMI Multiplexed Display

The VGA DE10NANO/HDMI ULX3S output has the following layers in order:

* Background [Background.md](documentation/Background.md) 
* Tilemap Layer [Tilemap.md](documentation/Tilemap.md) 
* Lower Sprite Layer [Sprites.md](documentation/Sprites.md) 
* Bitmap with GPU [Bitmap and GPU.md](documentation/Bitmap%20and%20GPU.md)
    * Vector block drawer [Vectors.md](documentation/Vectors.md) 
    * Display list drawer [Display List.md](documentation/Display%20List.md) 
* Upper Sprite Layer [Sprites.md](documentation/Sprites.md) 
* Character Map with TPU [Character Map and TPU.md](documentation/Character%20Map%20and%20TPU.md)
* Terminal [Terminal.md](documentation/Terminal.md) 

All of the display layers operate at 25Mhz, the pixel clock for the 640 x 480 display, all synchronised with each other. These display layers then are combined by the multiplex display [Multiplex Display.md](documentation/Multiplex%20Display.md) to form the display.

Due to the address space limitations of the J1+ CPU ( 65536 x 16 bit), the display layer memories cannot be memory mapped. Control of the display layers is done via memory mapped control registers. _Some_ j1eforth words are provided as helpers.

The initial basic bitmap and terminal windows were extended to include as many capabilities as could fit into the design, which at present is limited by the amount of BRAM available on the ULX3S. The aim being to create a functional general computer running j1eforth, focussing on as many features as possible found in the popular home computers of the 1980s.

For note I owned, and programmed (home computers) the following:

* Game consoles:
    * Atari VCS 2600
    * PlayStation 2
    * PlayStation 3
* Home computers
    * Commodore Vic 20
        * 6502 assembly language
    * Commodore 64
        * 6502 assembly language
        * The motivation for providing sprite layers
    * Atari ST original 512 and 512FM
        * 68000 assembly language
    * Commodore Amiga A500 and A1200
        * 68000 / 68030 assembly language and C

All of the non-CPU components are provided as co-processors, so that the J1+ CPU can continue executing Forth code whilst the co-processor continues with the assigned task. The terminal window for example operates as a basic display output alongside the UART, with no further intervention required by the j1eforth environment to output to the terminal, other than to output to the UART.

Simple examples to test some of the features of the display are provided in [Examples.md](documentation/Examples.md)

The sample code provided in [Big Example Part 1.md](documentation/Big%20Example%20Part%201.md) and [Big Example Part 2.md](documentation/Big%20Example%20Part%202.md) is used for driving feature development, features are added if they are required by the simple asteroids type game. 

## Additional Features

* ULX3S has basic stereo sound capabilities [Audio.md](documentation/Audio.md) 
* Timers and a pseudo random number generator are provided [Timers.md](documentation/Timers.md) 

## TODO

### ALL DISPLAY LAYERS

* Reimplement fader level
    * Implement via multiplex display directly

### AUDIO

* Sound for the DE10NANO
* Allow polyphonic sound (may not be achievable)
* Volume control

### GPU

* COLOUR BLITTER
    * 10 bit { Arrggbb } 16 x 16 blitter from a configurable 64 16 x 16 tilemap (16384 * 7 bit, might be too big for the blockram)
        * ALPHA will determine if pixel is placed or missed (mask)

### Character map

* Change characterGenerator8x16 from BROM to BRAM to allow changes to the font
* Implement character generator writer in the same format as the tile map tile, sprite tile, blit1 tile, vector vertex and display list entry writers

## Notes

* UART rx for the de10nano is on PIN_AG11 which maps to Arduino_IO15. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.
* UART tx for the de10nano is on PIN_AH9 which maps to Arduino_IO14. On the MiSTer I/O board this pin is accessible by the USB3-lookalike USER port.

I use a USB3 breakout board in the USER port to easily access the above pins. Changing the uart to uart2 in the DE10NANO makefile will change the output pins.

![USB3 Breakout for UART pins](documentation/images/DE10NANO-USERPORT.jpg)
