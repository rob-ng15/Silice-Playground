# Background Layer

The initial concept was to provide a solid colour backdrop to the display if all layers above are transparent, i.e. have nothing to display. This was extended to include the limited texture checkerboards, and once the random number generator was included in the j1eforth design, the static generator. The starfield/snow generator from @sylefeb was included to provide a backdrop for the "Big Example", the simple asteroids type game demonstration which has driven the capabilities of this design.

* Background with configurable designs
    * single { rrggbb } colour
    * alternative { rrggbb } colour for some designs
    * selectable designs
        * selectable solid in main background colour (design 0)
        * checkerboard in main and alternative background colours
            * 4 selectable sizes (design 1 = small, design 2 = medium, design 3 = large, design 4 = huge)
        * fixed colour rainbow (design 5)
        * black/grey/white rolling static (design 6)
        * starfield/snow (design 7)
            * with main background colour stars/snow and alternative colour background

## Memory Map for the Background Layer

Hexadecimal<br>Address | Write | Read
---- | ---- | -----
fff0 | Set the main background colour |
fff1 | Set the alternative background colour |
fff2 | Set the background design |

## j1eforth Background Layer Words

BACKGROUND<br>Word | Usage
----- | -----
background! | Example: ```3 2 4 background!``` Sets the background to a HUGE blue/dark blue checkerboard
