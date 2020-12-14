# Background Layer

The display was always envisaged as being in layers, with transparency allowing the layer below to be display. The background being the lowermost layer, shown if all layers above are transparent.

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

## PAWS LIBRARY FUNCTIONS

```void set_background( unsigned char colour, unsigned char altcolour, unsigned char backgroundmode )``` sets the background parameters
