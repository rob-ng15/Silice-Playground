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
    tilemap_scrollwrapclear( 9 );
    set_background( BLACK, BLACK, BKG_SOLID );
}

// DISPLAY COLOUR CHART
void colourtable( void ) {
    displayreset();
    tpu_outputstringcentre( 29, TRANSPARENT, WHITE, "Colour Test" );

    uint8 colour = 0;
    for( uint16 y = 0; y < 8; y++ ) {
        for( uint16 x = 0; x < 8; x++ ) {
            gpu_rectangle( colour++, x * 80, y * 60, 79 + x * 80, 59 + y * 60 );
        }
    }
    sleep( 1000, 0 );
}

// DISPLAY THE BACKGROUNDS
void backgrounddemo( void ) {
    displayreset();
    tpu_outputstringcentre( 29, TRANSPARENT, WHITE, "Background Generator Test" );

    for( uint8 bkg = 0; bkg < 16; bkg++ ) {
        set_background( PURPLE, ORANGE, bkg );
        sleep( 1000, 0 );
    }
}

// PUT SOME OBJECTS ON THE TILEMAP AND WRAP UP AND LEFT
void tilemapdemo( void ) {
    displayreset();
    set_background( WHITE, DKBLUE, BKG_SNOW );
    tpu_outputstringcentre( 29, TRANSPARENT, WHITE, "Tilemap Scroll With Wrap Test" );

    unsigned char x, y, colour;
    (void)tilemap_scrollwrapclear( 9 );

    for( unsigned char tile_number = 0; tile_number < 8; tile_number++ ) {
        set_tilemap_bitmap( tile_number + 1, &tilemap_bitmap[ tile_number * 16 ] );
    }

    // RANDOMLY PLACE 4 PLANETS and 4 ROCKET SHIPS
    for( unsigned char i = 0; i < 4; i++ ) {
        x = rng( 18 ) + ( x&1 ? 1 : 21 );
        y = rng( 7 ) + i*7 + 1;
        colour = rng( 63 ) + 1;
        set_tilemap_tile( x, y, 1, TRANSPARENT, colour ); set_tilemap_tile( x, y+1, 2, TRANSPARENT, colour ); set_tilemap_tile( x+1, y, 3, TRANSPARENT, colour ); set_tilemap_tile( x+1, y+1, 4, TRANSPARENT, colour );
    }
    for( unsigned char i = 0; i < 4; i++ ) {
        x = rng( 18 ) + ( x&1 ? 21 : 1 );
        y = rng( 7 ) + i*7 + 1;
        colour = rng( 63 ) + 1;
        set_tilemap_tile( x, y, 5, TRANSPARENT, colour ); set_tilemap_tile( x, y+1, 6, TRANSPARENT, colour ); set_tilemap_tile( x+1, y, 7, TRANSPARENT, colour ); set_tilemap_tile( x+1, y+1, 8, TRANSPARENT, colour );
    }

    for( unsigned short i = 0; i < 128; i++ ) {
        await_vblank();
        (void)tilemap_scrollwrapclear( 5 );
        (void)tilemap_scrollwrapclear( 6 );
        sleep( 20, 0 );
    }
}

// WORK THROUGH THE VARIOUS GPU FUNCTIONS
void gpudemo( void ) {
    unsigned short i;
    short x1, y1, x2, y2, x3, y3;

    displayreset();

    // POINTS
    gpu_cs();
    tpu_outputstringcentre( 29, TRANSPARENT, WHITE, "GPU Plot Pixels Test" );
    for( i = 0; i < 2048; i++ ) {
        gpu_pixel( rng( 64 ), rng( 640 ), rng( 480 ) );
    }
    sleep( 1000, 0 );

    // LINES
    gpu_cs();
    tpu_outputstringcentre( 29, TRANSPARENT, WHITE, "GPU Line Drawing Test" );
    for( i = 0; i < 1024; i++ ) {
        gpu_line( rng( 64 ), rng( 640 ), rng( 480 ), rng( 640 ), rng( 480 ) );
    }
    sleep( 1000, 0 );

    // RECTANGLES
    gpu_cs();
    tpu_outputstringcentre( 29, TRANSPARENT, WHITE, "GPU Rectangle Drawing Test - Solid & Dither" );
    for( i = 0; i < 1024; i++ ) {
        gpu_dither( rng(16), rng( 64 ) );
        gpu_rectangle( rng( 64 ), rng( 640 ), rng( 480 ), rng( 640 ), rng( 480 ) );
    }
    gpu_dither( DITHEROFF );
    sleep( 1000, 0 );

    // CIRCLES
    gpu_cs();
    tpu_outputstringcentre( 29, TRANSPARENT, WHITE, "GPU Circle Drawing Test - Solid & Dither" );
    for( i = 0; i < 1024; i++ ) {
        gpu_dither( rng(16), rng( 64 ) );
        gpu_circle( rng( 64 ), rng( 640 ), rng( 480 ), rng( 32 ), rng( 1 ) );
    }
    gpu_dither( DITHEROFF );
    sleep( 1000, 0 );

    // TRIANGLES
    gpu_cs();
    tpu_outputstringcentre( 29, TRANSPARENT, WHITE, "GPU Triangle Drawing Test - Solid & Dither" );
    for( i = 0; i < 1024; i++ ) {
        x1 = rng( 640 ); y1 = rng( 480 );
        x2 = x1 + rng( 100 ); y2 = y1 + rng( 100 );
        x3 = x2 - rng( 100 ); y3 = y1 + rng( 100 );
        gpu_dither( rng(16), rng( 64 ) );
        gpu_triangle( rng( 64 ), x1, y1, x2, y2, x3, y3 );
    }
    gpu_dither( DITHEROFF );
    sleep( 1000, 0 );

    // BLITTER

    // CHARACTER BLITTER
    gpu_cs();
    tpu_outputstringcentre( 29, TRANSPARENT, WHITE, "GPU Character Blitter Test" );
    for( i = 0; i < 1024; i++ ) {
        gpu_character_blit( rng( 64 ), rng( 640 ), rng( 480 ), rng( 256 ), rng( 4 ) );
    }
    sleep( 1000, 0 );

}

void ditherdemo( void ) {
    unsigned char dithermode = 0;
    unsigned short x, y;

    gpu_cs();
    tpu_outputstringcentre( 29, TRANSPARENT, WHITE, "GPU Dither Modes" );

    for( y = 0; y < 4; y++ ) {
        for( x = 0; x < 4; x++ ) {
            gpu_dither( dithermode++, PURPLE );
            gpu_rectangle( ORANGE, x * 160, y * 120, x * 160 + 159, y * 120 + 119 );
        }
    }
    gpu_dither( DITHEROFF );
    sleep( 2000, 0 );
}

void main( void ) {
    INITIALISEMEMORY();
	while(1) {
        colourtable();

        backgrounddemo();

        tilemapdemo();

        gpudemo();

        ditherdemo();
    }
}
