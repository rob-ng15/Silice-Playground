# Terminal Window

The basic look of the terminal window is designed to mimic a dumb terminal for basic input and output. In the j1eforth design the terminal window is a direct copy of the UART output.

* 80 x 8 2 colour blue/white text display, using IBM 8x8 256 character ROM as input/output terminal
    * Includes a simple terminal output protocol to display characters
    * Includes a flashing cursor
    * Can be shown/hidden to allow the larger character 8x16 map or the bitmap to be fully displayed

The blue/white display for the terminal window was inspired by the TI-99/4A startup screen.
    
## Memory Map for the TERMINAL Window

Hexadecimal<br>Address | Write | Read
:-----: | ----- | -----
ff20 | TERMINAL outputs a character | TERMINAL busy (scrolling)
ff21 | TERMINAL show/hide<br>1 - Show the termnal<br>0 - Hide the terminal

## j1eforth TERMINAL words

TERMINAL<br>Word | Usage
----- | -----
terminalshow! | Example ```terminalshow!``` show the blue terminal window
terminalhide! | Example ```terminalhide!``` hide the blue terminal window
