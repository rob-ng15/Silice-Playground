# Multiplex Display

All of the display layers output for each of the pixels on the screen:

* Pixel active in layer
* Pixel colour { rrggbb }

The multiplex display selects the pixel to output by selecting the active pixel from the uppermost layer.

## Memory Map for the Multiplex Display

Hexadecimal<br>Address | Write | Read
----- | ----- | -----
ffff | | VBLANK flag (1) if presently in the vblank

## j1eforth MULTIPLEX DISPLAY words

DISPLAY<br>Word | Usage
----- | -----
vblank? | Example ```vblank``` wait for vblank

## Colour HEX numbers

All layers except the terminal layer use 6 bit { rrggbb } colours, with some layers having an ALPHA channel to make that pixel transparent.

Colour<br>Guide<br>__HEX__ | Colour
----- | -----
40 | Transparent<br>(where used, tilemap layer, bitmap layer, character map layer)
00 | Black
03 | Blue
0c | Green
0f | Cyan
30 | Red
33 | Magenta
3c | Yellow
3f | White

