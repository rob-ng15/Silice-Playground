# Tilemap Layer

_Partially coded. No extra j1eforth words added._

* A 42 x 32 (40 x 30 visible with a 1 character border for scrolling ) tilemap between background and bitmap along with configurable 32 16 x 16 tiles
    * Tiles are 1 bit with foreground { rrggbb } and background { Arrggbb } colour per tile
    * Tilemap offset of -15 to 15 in x and y to allow scrolling (not yet implemented)
    * Tilemap scroller to move tilemap up, down, left, right (not yet implemented)
        * scroll and fill with blank or wrap

## Memory Map for the Tilemap Layer

Hexadecimal<br>Address | Write | Read
----- | ----- | -----
ff90 | X cursor position 
ff91 | Y cursor position
ff92 | Tile number to write to cursor position
ff93 | Background colour to write to cursor position
ff94 | Foreground colour to write to cursor position
ff95 | Write to cursor position
ff96 | Set the tile writer tile number
ff97 | Set the tile writer line number
ff98 | Bitmap to write to the tile
ff99 | Scroll or wrap the tilemap (Values below) | Last action (0) no scroll/wrap, otherwise the action taken
ff9a | | Tilemap scrolling/wrapping/clearing

Scroll<br>Wrap | Action | Scroll<br>Wrap | Action 
----- | ----- | ----- | -----
1 | Move LEFT and SCROLL if necessary | 5 | Move LEFT and WRAP if necessary
2 | Move UP and SCROLL if necessary | 6 | Move UP and WRAP if necessary
3 | Move RIGHT and SCROLL if necessary | 7 | Move RIGHT and WRAP if necessary
4 | Move DOWN and SCROLL if necessary | 8 | Move DOWN and WRAP if necessary
 | | |
9 | Clear the tilemap ( tmcs! )

Scrolling will fill the new row/column with transparent background and black foreground with tile number 0. Wrapping will move the old row/column to the new row/column.
