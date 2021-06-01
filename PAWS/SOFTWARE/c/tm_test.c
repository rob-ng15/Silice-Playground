#include "PAWSlibrary.h"

// FOR TILEMAP DEMO
unsigned short tilemap_bitmap[] = {
    0xfffe, 0xfffe, 0xc006, 0xc006, 0xc006, 0xc006, 0xc006, 0xc006,
    0xc006, 0xc006, 0xc006, 0xc006, 0xc006, 0xfffe, 0xfffe, 0x0000,
    0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180,
    0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180,
    0xfffe, 0xfffe, 0x0006, 0x0006, 0x0006, 0x0006, 0xfffe, 0xfffe,
    0xc000, 0xc000, 0xc000, 0xc000, 0xc000, 0xfffe, 0xfffe, 0x0000,
    0xfffe, 0xfffe, 0x0006, 0x0006, 0x0006, 0x0006, 0x3ffe, 0x3ffe,
    0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0xfffe, 0xfffe, 0x0000,
    0xc006, 0xc006, 0xc006, 0xc006, 0xc006, 0xc006, 0xfffe, 0xfffe,
    0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0000,
    0xfffe, 0xfffe, 0xc000, 0xc000, 0xc000, 0xc000, 0xfffe, 0xfffe,
    0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0xfffe, 0xfffe, 0x0000,
    0xc000, 0xc000, 0xc000, 0xc000, 0xc000, 0xc000, 0xfffe, 0xfffe,
    0xc006, 0xc006, 0xc006, 0xc006, 0xc006, 0xfffe, 0xfffe, 0x0000,
    0xfffe, 0xfffe, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006,
    0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0000,
    0xfffe, 0xfffe, 0xc006, 0xc006, 0xc006, 0xc006, 0xfffe, 0xfffe,
    0xc006, 0xc006, 0xc006, 0xc006, 0xc006, 0xfffe, 0xfffe, 0x0000,
    0xfffe, 0xfffe, 0xc006, 0xc006, 0xc006, 0xc006, 0xfffe, 0xfffe,
    0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0006, 0x0000
};

void displayreset( void ) {
    // RESET THE DISPLAY
    gpu_cs();
    tpu_cs();
    tilemap_scrollwrapclear( LOWER_LAYER, 9 );
    tilemap_scrollwrapclear( UPPER_LAYER, 9 );
    set_background( BLACK, BLACK, BKG_SOLID );
}

// PUT SOME OBJECTS ON THE TILEMAP AND WRAP LOWER LAYER UP AND LEFT , UPPER LAYER DOWN AND RIGHT
void tilemapdemo( void ) {
    displayreset();
    set_background( WHITE, DKBLUE, BKG_SNOW );
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "Tilemap Scroll With Wrap Test" );

    unsigned char x, y, count, colour;
    (void)tilemap_scrollwrapclear( LOWER_LAYER, 9 );
    (void)tilemap_scrollwrapclear( UPPER_LAYER, 9 );

    for( unsigned char tile_number = 0; tile_number < 10; tile_number++ ) {
        set_tilemap_bitmap( LOWER_LAYER, tile_number + 1, &tilemap_bitmap[ tile_number * 16 ] );
        set_tilemap_bitmap( UPPER_LAYER, tile_number + 1, &tilemap_bitmap[ tile_number * 16 ] );
    }

    // PLACE NUMBERS ALONG THE TOP (LOWER LAYER) AND MIDDLE (UPPER LAYER)
    x = 0; y = 2; count = 0;
    for( unsigned char i = 0; i < 126; i++ ) {
        colour = rng( 63 ) + 1;
        set_tilemap_tile( LOWER_LAYER, x, y, count + 1, 63 - colour, colour );
        set_tilemap_tile( UPPER_LAYER, x, y + 16, count + 1, 63 - colour, colour );

        y = ( x == 41 ) ? y + 1 : y;
        x = ( x == 41 ) ? 0 : x + 1;

        count = ( count == 9 ) ? 0 : count + 1;
    }

    for( unsigned short i = 0; i < 4096; i++ ) {
        await_vblank();
        // LOWER LEFT AND UP
        (void)tilemap_scrollwrapclear( LOWER_LAYER, 5 );
        (void)tilemap_scrollwrapclear( LOWER_LAYER, 6 );
        // UPPER RIGHT AND DOWN
        (void)tilemap_scrollwrapclear( UPPER_LAYER, 7 );
        (void)tilemap_scrollwrapclear( UPPER_LAYER, 8 );
        sleep( 1000, 0 );
    }
}

int main( void ) {
    INITIALISEMEMORY();

    while(1) {
        tilemapdemo();
    }
}
