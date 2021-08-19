#include "PAWS.h"

typedef unsigned int size_t;

// BACKGROUND PATTERN GENERATOR
#define BKG_SOLID 0

// COLOURS
#define TRANSPARENT 0x40
#define BLACK 0x00
#define BLUE 0x03
#define DKBLUE 0x02
#define GREEN 0x0c
#define DKGREEN 0x08
// #define CYAN 0x0f
#define RED 0x30
#define DKRED 0x20
#define MAGENTA 0x33
#define PURPLE 0x13
#define YELLOW 0x3c
#define WHITE 0x3f
#define GREY1 0x15
#define GREY2 0x2a
#define ORANGE 0x38

// PAWS LOGO BLITTER TILE
unsigned short PAWSLOGO[] = {
    0b0000000001000000,
    0b0000100011100000,
    0b0001110011100000,
    0b0001110011100000,
    0b0001111011100100,
    0b0000111001001110,
    0b0010010000001110,
    0b0111000000001110,
    0b0111000111001100,
    0b0111001111110000,
    0b0011011111111000,
    0b0000011111111000,
    0b0000011111111100,
    0b0000111111111100,
    0b0000111100001000,
    0b0000010000000000
};

// SDCARD BLITTER TILES
unsigned short sdcardtiles[] = {
    // CARD
    0x0000, 0x0000, 0x0ec0, 0x08a0, 0xea0, 0x02a0, 0x0ec0, 0x0000,
    0x0a60, 0x0a80, 0x0e80, 0xa80, 0x0a60, 0x0000, 0x0000, 0x0000,
    // SDHC
    0x3ff0, 0x3ff8, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ff8, 0x1ffc, 0x1ffc,
    0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc,
    // LED INDICATOR
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0018, 0x0018, 0x0000
};

// PACMAN GHOST GRAPHICS - 3 LAYERS - BODY - EYE WHITES - PUPILS
// BODY 2 EACH FOR RIGHT, DOWN, LEFT, UP
unsigned short body_bitmap[] = {
    0b0000001111000000,
    0b0000111111110000,
    0b0001111111111000,
    0b0011111111111100,
    0b0011111111111100,
    0b0011111111111100,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0110111001110110,
    0b0100011001100010,
    0,

    0b0000001111000000,
    0b0000111111110000,
    0b0001111111111000,
    0b0011111111111100,
    0b0011111111111100,
    0b0011111111111100,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111101111011110,
    0b0011000110001100,
    0,

    0b0000001111000000,
    0b0000111111110000,
    0b0001111111111000,
    0b0011111111111100,
    0b0011111111111100,
    0b0011111111111100,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0110111001110110,
    0b0100011001100010,
    0,

    0b0000001111000000,
    0b0000111111110000,
    0b0001111111111000,
    0b0011111111111100,
    0b0011111111111100,
    0b0011111111111100,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111101111011110,
    0b0011000110001100,
    0,

    0b0000001111000000,
    0b0000111111110000,
    0b0001111111111000,
    0b0011111111111100,
    0b0011111111111100,
    0b0011111111111100,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0110111001110110,
    0b0100011001100010,
    0,

    0b0000001111000000,
    0b0000111111110000,
    0b0001111111111000,
    0b0011111111111100,
    0b0011111111111100,
    0b0011111111111100,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111101111011110,
    0b0011000110001100,
    0,

    0b0000001111000000,
    0b0000111111110000,
    0b0001111111111000,
    0b0011111111111100,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0110111001110110,
    0b0100011001100010,
    0,

    0b0000001111000000,
    0b0000111111110000,
    0b0001111111111000,
    0b0011111111111100,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111101111011110,
    0b0011000110001100,
    0
};

// EYE WHITES 1 EACH FOR RIGHT, DOWN, LEFT, UP PLUS 1 EACH FOR POWER UP STATUS (mouth)
unsigned short eyewhites_bitmap[] = {
    0,0,0,0,
    0b0000011000011000,
    0b0000111100111100,
    0b0000111100111100,
    0b0000111100111100,
    0b0000011000011000,
    0,0,0,0,0,0,0,

    0,0,0,0,
    0b0000110000110000,
    0b0001111001111000,
    0b0001111001111000,
    0b0001111001111000,
    0b0000110000110000,
    0,0,0,0,0,0,0,

    0,0,0,0,
    0b0001100001100000,
    0b0011110011110000,
    0b0011110011110000,
    0b0011110011110000,
    0b0001100001100000,
    0,0,0,0,0,0,0,

    0,
    0b0000110000110000,
    0b0001111001111000,
    0b0001111001111000,
    0b0001111001111000,
    0b0000110000110000,
    0,0,0,0,0,0,0,0,0,0,

    0,0,0,0,0,0,0,0,0,0,0,
    0b0001100110011000,
    0b0010011001100100,
    0,0,0,

    0,0,0,0,0,0,0,0,0,0,0,
    0b0001100110011000,
    0b0010011001100100,
    0,0,0,

    0,0,0,0,0,0,0,0,0,0,0,
    0b0001100110011000,
    0b0010011001100100,
    0,0,0,

    0,0,0,0,0,0,0,0,0,0,0,
    0b0001100110011000,
    0b0010011001100100,
    0,0,0
};

// PUPILS 1 EACH FOR RIGHT, DOWN, LEFT, UP PLUS 1 EACH FOR POWER UP STATUS (PUPILS)
unsigned short pupils_bitmap[] = {
    0,0,0,0,0,0,
    0b0000001100001100,
    0b0000001100001100,
    0,0,0,0,0,0,0,0,

    0,0,0,0,0,0,0,
    0b0000110000110000,
    0b0000110000110000,
    0,0,0,0,0,0,0,

    0,0,0,0,0,0,
    0b0011000011000000,
    0b0011000011000000,
    0,0,0,0,0,0,0,0,

    0,
    0b0000110000110000,
    0b0000110000110000,
    0,0,0,0,0,0,0,0,0,0,0,0,0,

    0,0,0,0,0,
    0b0000011001100000,
    0b0000011001100000,
    0,0,0,0,0,0,0,0,0,

    0,0,0,0,0,
    0b0000011001100000,
    0b0000011001100000,
    0,0,0,0,0,0,0,0,0,

    0,0,0,0,0,
    0b0000011001100000,
    0b0000011001100000,
    0,0,0,0,0,0,0,0,0,

    0,0,0,0,0,
    0b0000011001100000,
    0b0000011001100000,
    0,0,0,0,0,0,0,0,0
};

// PACMAN - 4 FOR UP/DOWN 4 FOR RIGHT/LEFT, USE REFLECTION OF UP FOR DOWN AND RIGHT FOR LEFT
unsigned short pacman_bitmap[] = {
    0,
    0b0000010000100000,
    0b0001110000111000,
    0b0011111001111100,
    0b0011111001111100,
    0b0111111001111110,
    0b0111111001111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0011111111111100,
    0b0011111111111100,
    0b0001111111111000,
    0b0000011111100000,
    0,

    0,
    0,
    0b0001000000001000,
    0b0011100000011100,
    0b0011110000111100,
    0b0111110000111110,
    0b0111111001111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0011111111111100,
    0b0011111111111100,
    0b0001111111111000,
    0b0000011111100000,
    0,

    0,
    0,
    0,
    0b0010000000000100,
    0b0011000000001100,
    0b0111100000011110,
    0b0111110000111110,
    0b0111111001111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0011111111111100,
    0b0011111111111100,
    0b0001111111111000,
    0b0000011111100000,
    0,

    0,
    0,
    0b0001000000001000,
    0b0011100000011100,
    0b0011110000111100,
    0b0111110000111110,
    0b0111111001111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0111111111111110,
    0b0011111111111100,
    0b0011111111111100,
    0b0001111111111000,
    0b0000011111100000,
    0,

    0,
    0b0000011111100000,
    0b0001111111111000,
    0b0011111111111100,
    0b0011111111111100,
    0b0111111111111110,
    0b0111111111111000,
    0b0111111110000000,
    0b0111111110000000,
    0b0111111111111000,
    0b0111111111111110,
    0b0011111111111100,
    0b0011111111111100,
    0b0001111111111000,
    0b0000011111100000,
    0,

    0,
    0b0000011111100000,
    0b0001111111111000,
    0b0011111111111100,
    0b0011111111111000,
    0b0111111111110000,
    0b0111111111000000,
    0b0111111110000000,
    0b0111111110000000,
    0b0111111111000000,
    0b0111111111110000,
    0b0011111111111000,
    0b0011111111111100,
    0b0001111111111000,
    0b0000011111100000,
    0,

    0,
    0b0000011111100000,
    0b0001111111111000,
    0b0011111111110000,
    0b0011111111100000,
    0b0111111111000000,
    0b0111111110000000,
    0b0111111100000000,
    0b0111111100000000,
    0b0111111110000000,
    0b0111111111000000,
    0b0011111111100000,
    0b0011111111110000,
    0b0001111111111000,
    0b0000011111100000,
    0,

    0,
    0b0000011111100000,
    0b0001111111111000,
    0b0011111111111100,
    0b0011111111111000,
    0b0111111111110000,
    0b0111111111000000,
    0b0111111110000000,
    0b0111111110000000,
    0b0111111111000000,
    0b0111111111110000,
    0b0011111111111000,
    0b0011111111111100,
    0b0001111111111000,
    0b0000011111100000,
    0
};

// RISC-V CSR FUNCTIONS
unsigned int CSRisa() {
   unsigned int isa;
   asm volatile ("csrr %0, 0x301" : "=r"(isa));
   return isa;
}
// STANDARD C FUNCTIONS ( from @sylefeb mylibc )
void * memset(void *dest, int val, size_t len) {
  unsigned char *ptr = dest;
  while (len-- > 0)
    *ptr++ = val;
  return dest;
}

short strlen( char *s ) {
    short i = 0;
    while( *s ) {
        s++;
        i++;
    }
    return(i);
}

// TIMER AND PSEUDO RANDOM NUMBER GENERATOR
// SLEEP FOR counter milliseconds
void sleep( unsigned short counter ) {
    *SLEEPTIMER0 = counter;
    while( *SLEEPTIMER0 );
}

// WAIT FOR VBLANK TO START
void await_vblank( void ) {
    while( !*VBLANK );
}

// BACKGROUND GENERATOR
void set_background( unsigned char colour, unsigned char altcolour, unsigned char backgroundmode ) {
    *BACKGROUND_COPPER_STARTSTOP = 0;
    *BACKGROUND_COLOUR = colour;
    *BACKGROUND_ALTCOLOUR = altcolour;
    *BACKGROUND_MODE = backgroundmode;
}

// GPU AND BITMAP
// The bitmap is 640 x 480 pixels (0,0) is ALWAYS top left even if the bitmap has been offset
// The bitmap can be moved 1 pixel at a time LEFT, RIGHT, UP, DOWN for scrolling
// The GPU can draw pixels, filled rectangles, lines, (filled) circles, filled triangles and has a 16 x 16 pixel blitter from user definable tiles

// INTERNAL FUNCTION - WAIT FOR THE GPU TO FINISH THE LAST COMMAND
inline void wait_gpu( void )  __attribute__((always_inline));
void wait_gpu( void ) {
    while( *GPU_STATUS );
}

// SET THE PIXEL at (x,y) to colour
void gpu_pixel( unsigned char colour, short x, short y ) {
    *GPU_COLOUR = colour;
    *GPU_X = x;
    *GPU_Y = y;
    wait_gpu();
    *GPU_WRITE = 1;
}

// DRAW A FILLED RECTANGLE from (x1,y1) to (x2,y2) in colour
void gpu_rectangle( unsigned char colour, short x1, short y1, short x2, short y2 ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;

    wait_gpu();
    *GPU_WRITE = 3;
}

// CLEAR THE BITMAP by drawing a transparent rectangle from (0,0) to (639,479) and resetting the bitamp scroll position
void gpu_cs( void ) {
    wait_gpu();
    *BITMAP_SCROLLWRAP = 5;
    gpu_rectangle( 64, 0, 0, 319, 239 );
}

// DRAW A (optional filled) CIRCLE at centre (x1,y1) of radius ( FILLED CIRCLES HAVE A MINIMUM RADIUS OF 4 )
void gpu_circle( unsigned char colour, short x1, short y1, short radius, unsigned char filled ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = radius;
    *GPU_PARAM1 = 255;

    wait_gpu();
    *GPU_WRITE = filled ? 5 : 4;
}

// BLIT A 16 x 16 ( blit_size == 1 doubled to 32 x 32 ) TILE ( from tile 0 to 31 ) to (x1,y1) in colour
void gpu_blit( unsigned char colour, short x1, short y1, short tile, unsigned char blit_size ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = tile;
    *GPU_PARAM1 = blit_size;
    *GPU_PARAM2 = 0; // NO REFLECTION

    wait_gpu();
    *GPU_WRITE = 7;
}

// BLIT AN 8 x8  ( blit_size == 1 doubled to 16 x 16, blit_size == 1 doubled to 32 x 32 ) CHARACTER ( from tile 0 to 255 ) to (x1,y1) in colour
void gpu_character_blit( unsigned char colour, short x1, short y1, unsigned char tile, unsigned char blit_size ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = tile;
    *GPU_PARAM1 = blit_size;
    *GPU_PARAM2 = 0; // NO REFLECTION

    wait_gpu();
    *GPU_WRITE = 8;
}

// OUTPUT A STRING TO THE GPU
void gpu_outputstring( unsigned char colour, short x, short y, char *s, unsigned char size ) {
    while( *s ) {
        gpu_character_blit( colour, x, y, *s++, size );
        x = x + ( 8 << size );
    }
}
void gpu_outputstringcentre( unsigned char colour, short y, char *s, unsigned char size ) {
    gpu_rectangle( TRANSPARENT, 0, y, 319, y + ( 8 << size ) - 1 );
    gpu_outputstring( colour, 160 - ( ( ( 8 << size ) * strlen(s) ) >> 1) , y, s, 0 );
}
// SET THE BLITTER TILE to the 16 x 16 pixel bitmap
void set_blitter_bitmap( unsigned char tile, unsigned short *bitmap ) {
    *BLIT_WRITER_TILE = tile;

    for( short i = 0; i < 16; i ++ ) {
        *BLIT_WRITER_LINE = i;
        *BLIT_WRITER_BITMAP = bitmap[i];
    }
}

// DRAW A FILLED TRIANGLE with vertices (x1,y1) (x2,y2) (x3,y3) in colour
// VERTICES SHOULD BE PRESENTED CLOCKWISE FROM THE TOP ( minimal adjustments made to the vertices to comply )
void gpu_triangle( unsigned char colour, short x1, short y1, short x2, short y2, short x3, short y3 ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;
    *GPU_PARAM2 = x3;
    *GPU_PARAM3 = y3;

    wait_gpu();
    *GPU_WRITE = 6;
}

// CHARACTER MAP FUNCTIONS
// The character map is an 80 x 30 character window with a 256 character 8 x 16 pixel character generator ROM )
// NO SCROLLING, CURSOR WRAPS TO THE TOP OF THE SCREEN

// CLEAR THE CHARACTER MAP
void tpu_cs( void ) {
    while( *TPU_COMMIT );
    *TPU_COMMIT = 3;
}

// SET THE TILEMAP TILE at (x,y) to tile with colours background and foreground
void set_tilemap_tile( unsigned char tm_layer, unsigned char x, unsigned char y, unsigned char tile, unsigned char background, unsigned char foreground) {
    switch( tm_layer ) {
        case 0:
            while( *LOWER_TM_STATUS );
            *LOWER_TM_X = x;
            *LOWER_TM_Y = y;
            *LOWER_TM_TILE = tile;
            *LOWER_TM_BACKGROUND = background;
            *LOWER_TM_FOREGROUND = foreground;
            *LOWER_TM_COMMIT = 1;
            break;
        case 1:
            while( *UPPER_TM_STATUS );
            *UPPER_TM_X = x;
            *UPPER_TM_Y = y;
            *UPPER_TM_TILE = tile;
            *UPPER_TM_BACKGROUND = background;
            *UPPER_TM_FOREGROUND = foreground;
            *UPPER_TM_COMMIT = 1;
            break;
    }
}

// SCROLL WRAP or CLEAR the TILEMAP
//  action == 1 to 4 move the tilemap 1 pixel LEFT, UP, RIGHT, DOWN and SCROLL at limit
//  action == 5 to 8 move the tilemap 1 pixel LEFT, UP, RIGHT, DOWN and WRAP at limit
//  action == 9 clear the tilemap
//  RETURNS 0 if no action taken other than pixel shift, action if SCROLL WRAP or CLEAR was actioned
unsigned char tilemap_scrollwrapclear( unsigned char tm_layer, unsigned char action ) {
    switch( tm_layer ) {
        case 0:
            while( *LOWER_TM_STATUS );
            *LOWER_TM_SCROLLWRAPCLEAR = action;
            break;
        case 1:
            while( *UPPER_TM_STATUS );
            *UPPER_TM_SCROLLWRAPCLEAR = action;
            break;
    }
    return( tm_layer ? *UPPER_TM_SCROLLWRAPCLEAR : *LOWER_TM_SCROLLWRAPCLEAR );
}

// SET THE BITMAPS FOR sprite_number in sprite_layer to the 8 x 16 x 16 pixel bitmaps ( 128 16 bit bitmap lines )
void set_sprite_bitmaps( unsigned char sprite_layer, unsigned char sprite_number, unsigned short *sprite_bitmaps ) {
    switch( sprite_layer ) {
        case 0:
            *LOWER_SPRITE_WRITER_NUMBER = sprite_number;
            break;
        case 1:
            *UPPER_SPRITE_WRITER_NUMBER = sprite_number;
            break;
    }
    for( int i = 0; i < 128; i ++ ) {
        switch( sprite_layer ) {
            case 0:
                *LOWER_SPRITE_WRITER_LINE = i;
                *LOWER_SPRITE_WRITER_BITMAP = sprite_bitmaps[i];
                break;
            case 1:
                *UPPER_SPRITE_WRITER_LINE = i;
                *UPPER_SPRITE_WRITER_BITMAP = sprite_bitmaps[i];
                break;
        }
    }
}
// SET SPRITE sprite_number in sprite_layer to active status, in colour to (x,y) with bitmap number tile ( 0 - 7 ) in sprite_attributes bit 0 size == 0 16 x 16 == 1 32 x 32 pixel size, bit 1 x-mirror bit 2 y-mirror
void set_sprite( unsigned char sprite_layer, unsigned char sprite_number, unsigned char active, unsigned char colour, short x, short y, unsigned char tile, unsigned char sprite_attributes ) {
    switch( sprite_layer ) {
        case 0:
            LOWER_SPRITE_ACTIVE[sprite_number] = active;
            LOWER_SPRITE_TILE[sprite_number] = tile;
            LOWER_SPRITE_COLOUR[sprite_number] = colour;
            LOWER_SPRITE_X[sprite_number] = x;
            LOWER_SPRITE_Y[sprite_number] = y;
            LOWER_SPRITE_DOUBLE[sprite_number] = sprite_attributes;
            break;

        case 1:
            UPPER_SPRITE_ACTIVE[sprite_number] = active;
            UPPER_SPRITE_TILE[sprite_number] = tile;
            UPPER_SPRITE_COLOUR[sprite_number] = colour;
            UPPER_SPRITE_X[sprite_number] = x;
            UPPER_SPRITE_Y[sprite_number] = y;
            UPPER_SPRITE_DOUBLE[sprite_number] = sprite_attributes;
            break;
    }
}

// SET or GET ATTRIBUTES for sprite_number in sprite_layer
//  attribute == 0 active status ( 0 == inactive, 1 == active )
//  attribute == 1 tile number ( 0 to 7 )
//  attribute == 2 colour
//  attribute == 3 x coordinate
//  attribute == 4 y coordinate
//  attribute == 5 attributes bit 0 = size == 0 16x16 == 1 32x32. bit 1 = x-mirror bit 2 = y-mirror
void set_sprite_attribute( unsigned char sprite_layer, unsigned char sprite_number, unsigned char attribute, short value ) {
    if( sprite_layer == 0 ) {
        switch( attribute ) {
            case 0:
                LOWER_SPRITE_ACTIVE[sprite_number] = ( unsigned char) value;
                break;
            case 1:
                LOWER_SPRITE_TILE[sprite_number] = ( unsigned char) value;
                break;
            case 2:
                LOWER_SPRITE_COLOUR[sprite_number] = ( unsigned char) value;
                break;
            case 3:
                LOWER_SPRITE_X[sprite_number] = value;
                break;
            case 4:
                LOWER_SPRITE_Y[sprite_number] = value;
                break;
            case 5:
                LOWER_SPRITE_DOUBLE[sprite_number] = ( unsigned char) value;
                break;
        }
    } else {
        switch( attribute ) {
            case 0:
                UPPER_SPRITE_ACTIVE[sprite_number] = ( unsigned char) value;
                break;
            case 1:
                UPPER_SPRITE_TILE[sprite_number] = ( unsigned char) value;
                break;
            case 2:
                UPPER_SPRITE_COLOUR[sprite_number] = ( unsigned char) value;
                break;
            case 3:
                UPPER_SPRITE_X[sprite_number] = value;
                break;
            case 4:
                UPPER_SPRITE_Y[sprite_number] = value;
                break;
            case 5:
                UPPER_SPRITE_DOUBLE[sprite_number] = ( unsigned char) value;
                break;
        }
    }
}

// UPDATE A SPITE moving by x and y deltas, with optional wrap/kill and optional changing of the tile
//  update_flag = { y action, x action, tile action, 5 bit y delta, 5 bit x delta }
//  x and y action ( 0 == wrap, 1 == kill when moves offscreen )
//  x and y deltas a 2s complement -15 to 15 range
//  tile action, increase the tile number ( provides limited animation effects )
void update_sprite( unsigned char sprite_layer, unsigned char sprite_number, unsigned short update_flag ) {
    switch( sprite_layer ) {
        case 0:
            LOWER_SPRITE_UPDATE[sprite_number] = update_flag;
            break;
        case 1:
            UPPER_SPRITE_UPDATE[sprite_number] = update_flag;
            break;
    }
}

void draw_paws_logo( void ) {
    set_blitter_bitmap( 3, &PAWSLOGO[0] );
    gpu_blit( BLUE, 2, 2, 3, 2 );
}

void set_sdcard_bitmap( void ) {
    set_blitter_bitmap( 0, &sdcardtiles[0] );
    set_blitter_bitmap( 1, &sdcardtiles[16] );
    set_blitter_bitmap( 2, &sdcardtiles[32] );
}

void draw_sdcard( void  ) {
    set_sdcard_bitmap();
    gpu_blit( BLUE, 256, 2, 1, 2 );
    gpu_blit( WHITE, 256, 2, 0, 2 );
}

void reset_display( void ) {
    *GPU_DITHERMODE = 0;
    *FRAMEBUFFER_DRAW = 1; gpu_cs(); while( !*GPU_FINISHED );
    *FRAMEBUFFER_DRAW = 0; gpu_cs(); while( !*GPU_FINISHED );
    *FRAMEBUFFER_DISPLAY = 0;
    *SCREENMODE = 0;
    tpu_cs();
    *LOWER_TM_SCROLLWRAPCLEAR = 9;
    *UPPER_TM_SCROLLWRAPCLEAR = 9;
    for( unsigned short i = 0; i < 16; i++ ) {
        LOWER_SPRITE_ACTIVE[i] = 0;
        UPPER_SPRITE_ACTIVE[i] = 0;
    }
}

// SMT START STOP
void SMTSTOP( void ) {
    *SMTSTATUS = 0;
}
void SMTSTART( unsigned int code ) {
    *SMTPCH = ( code & 0xffff0000 ) >> 16;
    *SMTPCL = ( code & 0x0000ffff );
    *SMTSTATUS = 1;
}

void smtmandel( void ) {
    const int graphwidth = 320, graphheight = 100;
    float kt = 63, m = 4.0;
    float xmin = -2.1, xmax = 0.6, ymin = -1.35, ymax = 1.35;
    float dx = (xmax - xmin) / graphwidth, dy = (ymax - ymin) / graphheight;
    float jx, jy, tx, ty, wx, wy, r;
    int k;

    for( int x = 0; x < graphwidth; x++ ) {
        jx = xmin + x * dx;
        for( int y = 0; y < graphheight; y++ ) {
            //tpu_printf_centre( 0, TRANSPARENT, WHITE, "( %3d, %3d )", x, y );
            jy = ymin + y * dy;
            k = 0; wx = 0.0; wy = 0.0;
            do {
                tx = wx * wx - wy * wy + jx;
                ty = 2.0 * wx * wy + jy;
                wx = tx;
                wy = ty;
                r = wx * wx + wy * wy;
                k = k + 1;
            } while( ( r < m ) && ( k < kt ) );

            gpu_pixel( ( k > kt ) ? BLACK : k + 1, x, y + 122 );
        }
    }
}

void smtthread( void ) {
    // SETUP STACKPOINTER FOR THE SMT THREAD
    asm volatile ("li sp ,0x4000");
    smtmandel();
    SMTSTOP();
}

extern int _bss_start, _bss_end;
void main( void ) {
    unsigned int isa;
    unsigned short i,j = 0;

    // STOP SMT
    *SMTSTATUS = 0;

    // CLEAR MEMORY
    memset( &_bss_start, 0, &_bss_end - &_bss_end );

    // RESET THE DISPLAY
    reset_display();
    set_background( DKBLUE - 1, BLACK, BKG_SOLID );

    // SETUP INITIAL WELCOME MESSAGE
    draw_paws_logo();
    draw_sdcard();
    gpu_outputstring( WHITE, 66, 2, "PAWS", 2 );
    gpu_outputstring( WHITE, 66, 34, "Risc-V RV32IMAFC CPU", 0 );

    for( i = 0; i < 42; i++ ) {
        set_tilemap_tile( 0, i, 15, 0, i, 0 );
        set_tilemap_tile( 1, i, 29, 0, 63 - i, 0 );
    }

    gpu_outputstringcentre( GREEN, 72, "VERILATOR - SMT + FPU TEST", 0 );
    gpu_outputstringcentre( GREEN, 80, "THREAD 0 - PACMAN SPRITES", 0 );
    gpu_outputstringcentre( GREEN, 88, "THREAD 1 - FPU MANDELBROT", 0 );

    SMTSTART( (unsigned int )smtthread );

    set_sprite_bitmaps( 1, 0, &pacman_bitmap[0] );
    set_sprite_bitmaps( 1, 1, &body_bitmap[0] );
    set_sprite_bitmaps( 1, 2, &eyewhites_bitmap[0] );
    set_sprite_bitmaps( 1, 3, &pupils_bitmap[0] );

    set_sprite( 1, 0, 1, YELLOW, 0, 440, 4, 1 );
    set_sprite( 1, 1, 1, RED, 64, 440, 0, 1 );
    set_sprite( 1, 2, 1, WHITE, 64, 440, 0, 1 );
    set_sprite( 1, 3, 1, BLUE, 64, 440, 0, 1 );

    while(1) {
        await_vblank();
        tilemap_scrollwrapclear( 0, 7 );
        tilemap_scrollwrapclear( 1, 5 );
        for( i = 0; i < 4; i++ ) update_sprite( 1, i, 1 );
        set_sprite_attribute( 1, 1, 1, ( j & 128 ) >> 7 );
        set_sprite_attribute( 1, 0, 1, 4 + ( ( j & 192 ) >> 6 ) );
        j++;
    }
}
