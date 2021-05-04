#include "PAWSlibrary.h"

// FOR TILEMAP DEMO
unsigned short tilemap_bitmap[] = {
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
    0x001f, 0x003f, 0x00ff, 0x01ff, 0x03ff, 0x03ff, 0x07ff, 0x07fc,
    0x1ff1, 0x37c7, 0x279c, 0x33f1, 0x1fc7, 0x011f, 0x00ff, 0x003f,
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
    0xc000, 0xf000, 0xf800, 0xff00, 0xf900, 0xe700, 0x0c00, 0x7400,
    0xc400, 0x1c00, 0x7c00, 0xf800, 0xf800, 0xf000, 0xe000, 0x8000,
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0001, 0x0003,
    0x007e, 0x00c4, 0x0088, 0x0190, 0x0110, 0x0320, 0x03f1, 0x0003,
    0x0006, 0x0005, 0x0022, 0x0008, 0x0480, 0x0024, 0x0020, 0x0090,
    0x0000, 0x0040, 0x0000, 0x0010, 0x0000, 0x0000, 0x0000, 0x0000,
    0x0000, 0x007e, 0x07e2, 0x1e02, 0x7006, 0xe604, 0x8f0c, 0x198c,
    0x1998, 0x0f18, 0x0630, 0x0060, 0x6060, 0xd0c0, 0xa180, 0x4300,
    0x8600, 0x0a00, 0x3200, 0xc200, 0x8200, 0x9c00, 0xf000, 0xc000,
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
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

    unsigned char x, y, colour;
    (void)tilemap_scrollwrapclear( LOWER_LAYER, 9 );
    (void)tilemap_scrollwrapclear( UPPER_LAYER, 9 );

    for( unsigned char tile_number = 0; tile_number < 4; tile_number++ ) {
        set_tilemap_bitmap( LOWER_LAYER, tile_number + 1, &tilemap_bitmap[ tile_number * 16 ] );
        set_tilemap_bitmap( UPPER_LAYER, tile_number + 1, &tilemap_bitmap[ 64 + tile_number * 16 ] );
    }

    // RANDOMLY PLACE 4 PLANETS and 4 ROCKET SHIPS
    for( unsigned char i = 0; i < 4; i++ ) {
        x = rng( 18 ) + ( x&1 ? 1 : 21 );
        y = rng( 7 ) + i*7 + 1;
        colour = rng( 63 ) + 1;
        set_tilemap_tile( LOWER_LAYER, x, y, 1, TRANSPARENT, colour ); set_tilemap_tile( LOWER_LAYER, x, y+1, 2, TRANSPARENT, colour ); set_tilemap_tile( LOWER_LAYER, x+1, y, 3, TRANSPARENT, colour ); set_tilemap_tile( LOWER_LAYER, x+1, y+1, 4, TRANSPARENT, colour );
    }
    for( unsigned char i = 0; i < 4; i++ ) {
        x = rng( 18 ) + ( x&1 ? 21 : 1 );
        y = rng( 7 ) + i*7 + 1;
        colour = rng( 63 ) + 1;
        set_tilemap_tile( UPPER_LAYER, x, y, 1, TRANSPARENT, colour ); set_tilemap_tile( UPPER_LAYER, x, y+1, 2, TRANSPARENT, colour ); set_tilemap_tile( UPPER_LAYER, x+1, y, 3, TRANSPARENT, colour ); set_tilemap_tile( UPPER_LAYER, x+1, y+1, 4, TRANSPARENT, colour );
    }

    for( unsigned short i = 0; i < 128; i++ ) {
        await_vblank();
        // LOWER LEFT AND UP
        (void)tilemap_scrollwrapclear( LOWER_LAYER, 5 );
        //(void)tilemap_scrollwrapclear( LOWER_LAYER, 6 );
        // UPPER RIGHT AND DOWN
        (void)tilemap_scrollwrapclear( UPPER_LAYER, 7 );
        //(void)tilemap_scrollwrapclear( UPPER_LAYER, 8 );
        sleep( 20, 0 );
    }
}

int main( void ) {
    INITIALISEMEMORY();

    while(1) {
        tilemapdemo();
    }
}
