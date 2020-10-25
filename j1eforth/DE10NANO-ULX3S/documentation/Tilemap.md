# Tilemap Layer

_Partially coded. No extra j1eforth words added._

* A 42 x 32 (40 x 30 visible with a 1 character border for scrolling ) tilemap between background and bitmap along with configurable 64 16 x 16 tiles
    * Tiles are 1 bit with foreground { rrggbb } and background { Arrggbb } colour per tile
    * Tilemap offset of -15 to 15 in x and y to allow scrolling (not yet implemented)
    * Tilemap scroller to move tilemap up, down, left, right (not yet implemented)
        * scroll and fill with blank or wrap

## Memory Map for the Tilemap Layer

Hexadecimal<br>Address | Write | Read
:-----: | ----- | -----
ff90 | X cursor position 
ff91 | Y cursor position
ff92 | Tile number to write to cursor position
ff93 | Background colour to write to cursor position
ff94 | Foreground colour to write to cursor position
ff95 | Write to cursor position
ff96 | Set the tile writer tile number
ff97 | Set the tile writer line number
ff98 | Bitmap to write to the tile
