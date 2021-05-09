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

// BLITTER BITMAPS - ALIENS FROM SPACE INVADERS
unsigned short blitter_bitmaps[] = {
    0b0000011000000000,
    0b0000111110000000,
    0b0001111111000000,
    0b0011011011000000,
    0b0011111111000000,
    0b0001011010000000,
    0b0010000001000000,
    0b0001000010000000,
    0,0,0,0,0,0,0,0,

    0b0000011000000000,
    0b0000111110000000,
    0b0001111111000000,
    0b0011011011000000,
    0b0011111111000000,
    0b0000100100000000,
    0b0001011010000000,
    0b0010100101000000,
    0,0,0,0,0,0,0,0,

    0b0010000010000000,
    0b0001000100000000,
    0b0011111110000000,
    0b0110111011000000,
    0b1111111111100000,
    0b1011111110100000,
    0b1010000010100000,
    0b0001101100000000,
    0,0,0,0,0,0,0,0,

    0b0010000010000000,
    0b1001000100100000,
    0b1011111110100000,
    0b1110111011100000,
    0b1111111111100000,
    0b0111111111000000,
    0b0010000010000000,
    0b0100000001000000,
    0,0,0,0,0,0,0,0,

    0b0000111100000000,
    0b0111111111100000,
    0b1111111111110000,
    0b1110011001110000,
    0b1111111111110000,
    0b0011100111000000,
    0b0110011001100000,
    0b0011000011000000,
    0,0,0,0,0,0,0,0,

    0b0000111100000000,
    0b0111111111100000,
    0b1111111111110000,
    0b1110011001110000,
    0b1111111111110000,
    0b0001100110000000,
    0b0011011011000000,
    0b1100000000110000,
    0,0,0,0,0,0,0,0
};

// STORAGE FOR COLOUR BLITTER
unsigned char colour_blitter_bitmap[ 256 * 8 ];

char *backgroundnames[] = {
    "BKG_SOLID",
    "BKG_5050_V",
    "BKG_5050_H",
    "BKG_CHKBRD_5",
    "BKG_RAINBOW",
    "BKG_SNOW",
    "BKG_STATIC",
    "BKG_CHKBRD_1",
    "BKG_CHKBRD_2",
    "BKG_CHKBRD_3",
    "BKG_CHKBRD_4",
    "BKG_HATCH",
    "BKG_LSLOPE",
    "BKG_RSLOPE",
    "BKG_VSTRIPE",
    "BKG_HSTRIPE"
};

char *dithernames[] = {
    "DITHEROFF",
    "DITHERCHECK1",
    "DITHERCHECK2",
    "DITHERCHECK3",
    "DITHERVSTRIPE",
    "DITHERHSTRIPE",
    "DITHERHATCH",
    "DITHERLSLOPE",
    "DITHERRSLOPE",
    "DITHERLTRIANGLE",
    "DITHERRTRIANGLE",
    "DITHERENCLOSED",
    "DITHEROCTAGON",
    "DITHERBRICK",
    "DITHER64COLSTATIC",
    "DITHER2COLSTATIC"
};

char *colournames[] = {
    "BLACK",
    "0x01",
    "DKBLUE",
    "BLUE",
    "0x04",
    "0x05",
    "0x06",
    "LTBLUE",
    "DKGREEN",
    "0x09",
    "0x0a",
    "DKCYAN",
    "GREEN",
    "0x0d",
    "0x0e",
    "CYAN",
    "0x10",
    "DKPURPLE",
    "0x12",
    "PURPLE",
    "0x14",
    "GREY1",
    "0x16",
    "LTPURPLE",
    "0x18",
    "0x19",
    "0x1a",
    "0x1b",
    "0x1c",
    "LTGREEN",
    "0x1e",
    "LTCYAN",
    "DKRED",
    "0x21",
    "DKMAGENTA",
    "0x23",
    "BROWN",
    "0x25",
    "0x26",
    "0x27",
    "DKYELLOW",
    "0x29",
    "GREY2",
    "0x2b",
    "0x2c",
    "0x2d",
    "0x2e",
    "0x2f",
    "RED",
    "0x31",
    "0x32",
    "MAGENTA",
    "DKORANGE",
    "LTRED",
    "0x36",
    "LTMAGENTA",
    "ORANGE",
    "LTORANGE",
    "PEACH",
    "PINK",
    "YELLOW",
    "LTYELLOW",
    "0x3e",
    "WHITE"
};

void displayreset( void ) {
    // RESET THE DISPLAY
    gpu_cs();
    tpu_cs();
    tilemap_scrollwrapclear( LOWER_LAYER, 9 );
    tilemap_scrollwrapclear( UPPER_LAYER, 9 );
    set_background( BLACK, BLACK, BKG_SOLID );
}

// DISPLAY COLOUR CHART
void colourtable( void ) {
    displayreset();
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "Colour Test" );

    uint8 colour = 0;
    for( uint16 y = 0; y < 8; y++ ) {
        for( uint16 x = 0; x < 8; x++ ) {
            gpu_rectangle( colour, x * 40, y * 30, 39 + x * 40, 29 + y * 30 );
            gpu_printf_centre( 63 - colour, x * 40 + 20, y * 30 + 15, 0, colournames[colour] );
            colour++;
        }
    }
    sleep( 1000, 0 );
}

// DISPLAY THE BACKGROUNDS
void backgrounddemo( void ) {
    displayreset();
    tpu_printf_centre( 28, TRANSPARENT, WHITE, "Background Generator Test" );

    for( uint8 bkg = 0; bkg < 16; bkg++ ) {
        set_background( PURPLE, ORANGE, bkg );
        tpu_printf_centre( 29, TRANSPARENT, WHITE, backgroundnames[bkg] );
        sleep( 1000, 0 );
    }
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
        (void)tilemap_scrollwrapclear( LOWER_LAYER, 5 ); (void)tilemap_scrollwrapclear( LOWER_LAYER, 6 );
        (void)tilemap_scrollwrapclear( UPPER_LAYER, 7 ); (void)tilemap_scrollwrapclear( UPPER_LAYER, 8 );
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
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "GPU Plot Pixels Test" );
    for( i = 0; i < 2048; i++ ) {
        gpu_pixel( rng( 64 ), rng( 320 ), rng( 240 ) );
    }
    sleep( 1000, 0 );

    // LINES
    gpu_cs();
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "GPU Line Drawing Test" );
    for( i = 0; i < 1024; i++ ) {
        gpu_line( rng( 64 ), rng( 320 ), rng( 240 ), rng( 320 ), rng( 240 ) );
    }
    sleep( 1000, 0 );

    // RECTANGLES
    gpu_cs();
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "GPU Rectangle Drawing Test - Solid & Dither" );
    for( i = 0; i < 1024; i++ ) {
        gpu_dither( rng(16), rng( 64 ) );
        gpu_rectangle( rng( 64 ), rng( 320 ), rng( 240 ), rng( 320 ), rng( 240 ) );
    }
    gpu_dither( DITHEROFF );
    sleep( 1000, 0 );

    // CIRCLES
    gpu_cs();
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "GPU Circle Drawing Test - Solid & Dither" );
    for( i = 0; i < 1024; i++ ) {
        gpu_dither( rng(16), rng( 64 ) );
        gpu_circle( rng( 64 ), rng( 320 ), rng( 240 ), rng( 32 ), rng( 1 ) );
    }
    gpu_dither( DITHEROFF );
    sleep( 1000, 0 );

    // TRIANGLES
    gpu_cs();
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "GPU Triangle Drawing Test - Solid & Dither" );
    for( i = 0; i < 1024; i++ ) {
        x1 = rng( 320 ); y1 = rng( 240 );
        x2 = x1 + rng( 100 ); y2 = y1 + rng( 100 );
        x3 = x2 - rng( 100 ); y3 = y1 + rng( 100 );
        gpu_dither( rng(16), rng( 64 ) );
        gpu_triangle( rng( 64 ), x1, y1, x2, y2, x3, y3 );
    }
    gpu_dither( DITHEROFF );
    sleep( 1000, 0 );

    // BLITTER
    // SET BLITTER OBJECTS - ALIENS
    for( short i = 0; i < 6; i++ ) {
        set_blitter_bitmap( i, &blitter_bitmaps[ 16 * i ] );
    }
    gpu_cs();
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "GPU Blitter Test" );
    for( i = 0; i < 1024; i++ ) {
        gpu_blit( rng( 64 ), rng( 320 ), rng( 240 ), rng( 6 ), rng( 4 ) );
    }
    sleep( 1000, 0 );

    // CHARACTER BLITTER
    gpu_cs();
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "GPU Character Blitter Test" );
    for( i = 0; i < 1024; i++ ) {
        gpu_character_blit( rng( 64 ), rng( 320 ), rng( 240 ), rng( 256 ), rng( 4 ) );
    }
    sleep( 1000, 0 );

    // COLOUR BLITTER
    // SET COLOUR BLITTER BITMAPS TO RANDOM
    for( i = 0; i < 256 * 8; i++ )
        colour_blitter_bitmap[i] = rng(65);
    for( i = 0; i < 8; i++ )
        set_colourblitter_bitmap( i, &colour_blitter_bitmap[ 256 * i ] );
    gpu_cs();
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "GPU Colour Blitter Test" );
    for( i = 0; i < 1024; i++ ) {
        gpu_colourblit( rng( 320 ), rng( 240 ), rng( 8 ), rng( 4 ) );
    }
    sleep( 1000, 0 );

    // VECTOR TEST
    gpu_cs();
    tpu_printf_centre( 29, TRANSPARENT, WHITE, "GPU Vector Draw Test" );
    set_vector_vertex( 0, 0, 1, 0, 0 );
    set_vector_vertex( 0, 1, 1, 5, 10 );
    set_vector_vertex( 0, 2, 1, 0, 6 );
    set_vector_vertex( 0, 3, 1, -5, 10 );
    set_vector_vertex( 0, 4, 1, 0, 0 );
    set_vector_vertex( 0, 5, 0, 0, 0 );
    for( i = 0; i < 1024; i++ ) {
        draw_vector_block( 0, rng( 64 ), rng( 320 ), rng( 240 ), rng(8) );
    }
    sleep( 1000, 0 );

}

void ditherdemo( void ) {
    unsigned char dithermode = 0;
    unsigned short x, y;

    gpu_cs();
    tpu_printf_centre( 28, TRANSPARENT, WHITE, "GPU Dither Modes" );

    for( y = 0; y < 4; y++ ) {
        for( x = 0; x < 4; x++ ) {
            gpu_dither( dithermode, PURPLE );
            gpu_rectangle( ORANGE, x * 80, y * 60, x * 80 + 79, y * 60 + 59 );
            gpu_printf_centre( BLACK, x * 80 + 40, y * 60 + 4, 0, dithernames[dithermode++] );
        }
    }
    gpu_dither( DITHEROFF );
    sleep( 2000, 0 );
}

int main( void ) {
    INITIALISEMEMORY();
	while(1) {
        colourtable();

        backgrounddemo();

        tilemapdemo();

        gpudemo();

        ditherdemo();
    }
}
