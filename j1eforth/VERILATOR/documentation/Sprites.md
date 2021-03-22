# Sprite Layer

Each Sprite Layer has the following:

* Sprite Layer
    * 13 (numbered 0 - 12) x 16 x 16 1 bit sprites
        * Double flag to display as double pixel 32 x 32 per sprite
        * 4 user settable tiles per sprite
    * Collision detection, updates at the end of every frame
        * Sprite to sprite collision detection - within the layer
        * Sprite to bitmap collision detection
        * Sprite to tilemap collision detection ( tilemap is not transparent, background or foreground set )
        * Sprite to other sprite layer collision detection ( single bit for the whole sprite layer )

For the j1eforth design there are two sprite layers. The lower sprite layer displays between the background and the bitmap; the upper sprite layers displays between the bitmap and the character map.

Each sprite has the following attributes:

Sprite Tile<br>Map | Active | Double | Tile Number | X | Y | Colour
----- | ----- | ----- | ----- | ----- | ----- | -----
128 lines of 16 pixels<br>8 x 16 x 16 tiles | Hide(0)<br>Display(1) | Single pixel 16 x 16 (0)<br>Double Pixel 32 x 32 (1) | 0 - 7Select tile from the sprite tile map | X coordinate | Y coordinate | { rrggbb } colour for single colour mode

## Memory Map for the Sprite Layers

Hexadecimal<br>Address<br>ff30 - ff3f for lower sprites<br>ff50 - ff57 for collision detection<br>ff40 - ff4f for upper sprites<br>5560-ff67 for collision detection | Write | Read
----- | ----- | -----
ff30 | Set __Active Sprite Number__ referred to as _ASN_ in the following |
ff31 | Set _ASN_ active flag | Read _ASN_ active flag
ff32 | Set _ASN_ tile number | Read _ASN_ tile number
ff33 | Set _ASN_ colour | Read _ASN_ colour
ff34 | Set _ASN_ x coordinate | Read _ASN_ x coordinate
ff35 | Set _ASN_ y coordinate | Read _ASN_ y coordinate
ff36 | Set _ASN_ double flag | Read _ASN_ double flag
ff36 | Set _ASN_ colour mode flag | Read _ASN_ colour mode flag
ff38 | Set sprite number for the tile map writer |
ff39 | Set sprite tile map line ( 0 - 63 ) |
ff3a | Set sprite tile map line bitmap |
ff3e | Update a sprite<br>See notes below |
 | |
ff50 | | Collision detection flag for sprite 0 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }
ff51 | | Collision detection flag for sprite 1 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }
ff52 | | Collision detection flag for sprite 2 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }
ff53 | | Collision detection flag for sprite 3 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }
ff54 | | Collision detection flag for sprite 4 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }
ff55 | | Collision detection flag for sprite 5 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }
ff56 | | Collision detection flag for sprite 6 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }
ff57 | | Collision detection flag for sprite 7 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }
ff58 | | Collision detection flag for sprite 8 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }
ff59 | | Collision detection flag for sprite 9 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }
ff5a | | Collision detection flag for sprite 10 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }
ff5b | | Collision detection flag for sprite 11 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }
ff5c | | Collision detection flag for sprite 12 { bitmap, tilemap, other sprite layer, sprite12, ... sprite 0 }

_For the Upper Sprite Layer add 10 to the address, range ff40 - ff4f, ff60 - ff6f_.

## j1eforth Sprite Layer words

SPRITE LAYER<br>Word | Usage
----- | -----
lslsprite! | Example ```3f 10 20 2 1 0 0 lslsprite!``` set lower sprite layer sprite 0 to 10,20 in colour 3f with tile map number 2, active and 16x16<br>_NOTE: colour x y tile active double number_
uslsprite! | Example ```3f 10 20 2 1 1 0 uslsprite!``` set upper sprite layer sprite 0 to 10,20 in colour 3f with tile map number 2,active and 32x32
lsltile! | Example (put 128 16bit bitmap lines to the stack) ```0 lsltile!``` set lower sprite layer sprite 0 tile map to the 64 bitmap lines
usltile! | Example (put 128 16bit bitmap lines to the stack) ```0 usltile!``` set upper sprite layer sprite 0 tile map to the 64 bitmap lines
lslupdate! | Example ```57 lslupdate!``` Update lower sprite layer sprite 0 according to (binary) { 0 000000 0 0 1 010 111 }<br>No change to colour, x wrap, y wrap, Iicrement tile number, y=y+2, x=x-1
uslupdate! | Example ```86b1 uslupdate!``` Update upper sprite layer sprite 0 according to (binary) { 1 000011 0 1 0 110 001 }<br>Change colour to 3(blue), x wrap, y kill, keep tile number, y=y-2, x=x+1

## Notes about the Sprite Update Flag

Bit(s) | Purpose
----- | -----
15 | Colour action - 0 = leave as is, 1 = change to { rrggbb } as given in bits 14 - 9
14 - 9 | { rrggbb } colour
8 | Y action - 0 = wrap y-axis, 1 = set sprite to inactive if it moves off screen
7 | X action - 0 = wrap x-axis, 1 = set sprite to inactive if it moves off screen
6 | Tile number action - 0 = leave as is, 1 = increment the tile number (simple animation)
5 - 3 | Y delta - amount to move along the y-axis, 2's complement number
2 - 0 | X delta - amount to move along the x-axis, 2's complement number
