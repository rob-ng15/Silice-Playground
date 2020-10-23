algorithm tile_map(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,
    output! uint1   tilemap_display,
    
    // Set TM at x, y, character with foreground and background
    input uint7 tm_x,
    input uint5 tm_y,
    input uint8 tm_character,
    input uint6 tm_foreground,
    input uint7 tm_background,
    input uint1 tm_write,

    // For setting tile bitmaps
    input   uint6   tile_writer_tile,
    input   uint4   tile_writer_line,
    input   uint16  tile_writer_bitmap,  
    input   uint1   tile_writer_write
) <autorun> {
    // Tile Map 64 x 16 x 16
    dualport_bram uint8 tiles16x16[ 1024 ] = uninitialized;
    
    // 42 x 32 tile map, allows for pixel scrolling with border
    // Setting background to 40 (ALPHA) allows the bitmap/background to show through
    dualport_bram uint6 tile[1344] = uninitialized;
    dualport_bram uint6 foreground[1344] = uninitialized;               // { rrggbb }
    dualport_bram uint7 background[1344] = { 7h40, pad(7h40) };         // { Arrggbb }

    // Expansion map for { rr } to { rrrrrr }, { gg } to { gggggg }, { bb } to { bbbbbb }
    // or { rr } tp { rrrrrrrr }, { gg } to { gggggggg }, { bb } to { bbbbbbbb }
    uint6 colourexpand2to6[4] = {  0, 21, 42, 63 };
    uint8 colourexpand2to8[4] = {  0, 85, 170, 255 };

    // Character position on the screen x 0-41, y 0-31 * 42 ( fetch it two pixels ahead of the actual x pixel, so it is always ready )
    uint8 xtmpos := ( pix_active ? (pix_x < 640 ) ? pix_x + 2 : 0 : 0 ) >> 4;
    uint12 ytmpos := (( pix_vblank ? 0 : pix_y ) >> 4) * 42; 
    
    // Derive the x and y coordinate within the current 16x16 tilemap block x 0-7, y 0-15
    uint3 xintm := (pix_x) & 15;
    uint4 yintm := (pix_y) & 15;

    // Derive the actual pixel in the current character
    uint1 tmpixel := tiles16x16.rdata0[15 - xintm,1];

    // Set up reading of tilemap and attribute memory
    // tile.rdata0 is the tile, foreground.rdata0 and background.rdata0 are the attribute being rendered
    tile.addr0 := xtmpos + ytmpos;
    tile.wenable0 := 0;
    foreground.addr0 := xtmpos + ytmpos;
    foreground.wenable0 := 0;
    background.addr0 := xtmpos + ytmpos;
    background.wenable0 := 0;

    // BRAM write access for the tm writer 
    tile.addr1 := tm_x + tm_y * 42;
    tile.wdata1 := tm_character;
    tile.wenable1 := 0;
    background.addr1 := tm_x + tm_y * 42;
    background.wdata1 := tm_background;
    background.wenable1 := 0;
    foreground.addr1 := tm_x + tm_y * 42;
    foreground.wdata1 := tm_foreground;
    foreground.wenable1 := 0;

    // Setup the reading and writing of the tiles16x16
    tiles16x16.addr0 :=  tile.rdata0 * 16 + yintm;
    tiles16x16.addr1 := tile_writer_tile * 16 + tile_writer_line; 
    tiles16x16.wdata1 := tile_writer_bitmap;
    tiles16x16.wenable1 := tile_writer_write;

    // Default to transparent
    tilemap_display := pix_active && (( tmpixel ) || ( ~colour7(background.rdata0).alpha ));
    
    always {
        switch( tm_write ) {
            case 1: {
                tile.wenable1 = 1;
                background.wenable1 = 1;
                foreground.wenable1 = 1;
            }
            default: {}
        }
    }

    // Render the tilemap
    while(1) {
        if( pix_active ) {
            // Determine if background or foreground
            switch( tmpixel ) {
                case 0: {
                    // BACKGROUND
                    if( ~colour7(background.rdata0).alpha ) {
                        pix_red = colourexpand2to$color_depth$[ colour7(background.rdata0).red ];
                        pix_green = colourexpand2to$color_depth$[ colour7(background.rdata0).green ];
                        pix_blue = colourexpand2to$color_depth$[ colour7(background.rdata0).blue ];
                    }
                }
                case 1: {
                    // foreground
                    pix_red = colourexpand2to$color_depth$[ colour6(foreground.rdata0).red ];
                    pix_green = colourexpand2to$color_depth$[ colour6(foreground.rdata0).green ];
                    pix_blue = colourexpand2to$color_depth$[ colour6(foreground.rdata0).blue ];
                }
            }
        } 
    }
}
