#include "PAWSlibrary.h"
#include <math.h>

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
unsigned char colour_blitter_strings[][16] = {

    "....C.C.........",
    "....C.C.........",
    "C..CCCCC..C.....",
    "CCCCYCYCCCC.....",
    "...CCCCC........",
    ".BBBCCCBBB......",
    "BBB.CCC.BBB.....",
    "BB...C...BB.....",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",

    "....C.C.........",
    "C...C.C...C.....",
    "CCCCCCCCCCC.....",
    "...CYCYC........",
    "BBBCCCCCBBB.....",
    "BB.CCCCC.BB.....",
    "B...CCC...B.....",
    ".....C..........",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",

    "C...C.C...C.....",
    "C..CCCCC..C.....",
    ".CCCYCYCCC......",
    "B..CCCCC..B.....",
    "BBBBCCCBBBB.....",
    ".BB.CCC.BB......",
    ".....C..........",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................"
};
unsigned char colour_blitter_bitmap[ 256 ];

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

// PACMAN - 4 FOR UP, USE ROTATION OF UP FOR RIGHT, DOWN AND LEFT
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

unsigned short pacman_maze_bitmaps[] = { // 3 corner, v line, h line
    0,0,0,0,0,0,0,0,
    0b0000000000111111,
    0b0000000001000000,
    0b0000000001000000,
    0b0000000010000000,
    0b0000000010000000,
    0b0000000010000000,
    0b0000000010000000,
    0b0000000010000000,

    0x0080, 0x0080, 0x0080, 0x0080, 0x0080, 0x0080, 0x0080, 0x0080,
    0x0080, 0x0080, 0x0080, 0x0080, 0x0080, 0x0080, 0x0080, 0x0080,

    0,0,0,0,0,0,0,0,
    0xffff,0,0,0,0,0,0
};
char pacman_maze[][42] = {
    "..........................................",
    "..........................................",
    "..........................................",
    "..........................................",
    "888888888888888888888888888888888888888888",
    "..........................................",
    "..........................................",
    "7777777772..17777772..17777772..1777777777",
    ".........5..6......5..6......5..6.........",
    ".........5..6......5..6......5..6.........",
    ".........5..6......5..6......5..6.........",
    ".........5..6......5..6......5..6.........",
    ".........5..6......5..6......5..6.........",
    ".........5..6......5..6......5..6.........",
    "8888888883..48888883..48888883..4888888888",
    "..........................................",
    "..........................................",
    "7777777772..17777772..17777772..1777777777",
    ".........5..6......5..6......5..6.........",
    ".........5..6......5..6......5..6.........",
    ".........5..6......5..6......5..6.........",
    ".........5..6......5..6......5..6.........",
    ".........5..6......5..6......5..6.........",
    ".........5..6......5..6......5..6.........",
    "8888888883..48888883..48888883..4888888888",
    "..........................................",
    "..........................................",
    "777777777777777777777777777777777777777777",
    "..........................................",
    "..........................................",
    "..........................................",
    ".........................................."
};

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
    for( short i = 0; i < 16; i++ ) {
        set_sprite_attribute( LOWER_LAYER, i, SPRITE_ACTIVE, 0 );
        set_sprite_attribute( UPPER_LAYER, i, SPRITE_ACTIVE, 0 );
    }
}

// DISPLAY COLOUR CHART
void colourtable( void ) {
    displayreset();
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "Colour Test" );

    uint8 colour = 0;
    for( uint16 y = 0; y < 8; y++ ) {
        for( uint16 x = 0; x < 8; x++ ) {
            gpu_rectangle( colour, x * 40, y * 30, 39 + x * 40, 29 + y * 30 );
            gpu_printf_centre( 63 - colour, x * 40 + 20, y * 30 + 15, 0, 0, colournames[colour] );
            colour++;
        }
    }
    sleep( 1000, 0 );
}

// DISPLAY THE BACKGROUNDS
void backgrounddemo( void ) {
    displayreset();
    tpu_print_centre( 58, TRANSPARENT, WHITE, 1, "Background Generator Test" );

    for( uint8 bkg = 0; bkg < 16; bkg++ ) {
        set_background( PURPLE, ORANGE, bkg );
        tpu_print_centre( 59, TRANSPARENT, WHITE, 0, backgroundnames[bkg] );
        sleep( 1000, 0 );
    }

    displayreset();

    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "COPPER Rainbow Stars Test" );
    copper_startstop( 0 );
    copper_program( 0, COPPER_WAIT_VBLANK, 7, 0, BKG_SNOW, BLACK, WHITE );
    copper_program( 1, COPPER_WAIT_X, 7, 0, BKG_SNOW, BLACK, WHITE );
    copper_program( 2, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 64, 0, 0, 1 );
    copper_program( 3, COPPER_WAIT_X, 7, 0, BKG_SNOW, BLACK, RED );
    copper_program( 4, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 128, 0, 0, 3 );
    copper_program( 5, COPPER_WAIT_X, 7, 0, BKG_SNOW, BLACK, ORANGE );
    copper_program( 6, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 160, 0, 0, 5 );
    copper_program( 7, COPPER_WAIT_X, 7, 0, BKG_SNOW, BLACK, YELLOW );
    copper_program( 8, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 192, 0, 0, 7 );
    copper_program( 9, COPPER_WAIT_X, 7, 0, BKG_SNOW, BLACK, GREEN );
    copper_program( 10, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 224, 0, 0, 9 );
    copper_program( 11, COPPER_WAIT_X, 7, 0, BKG_SNOW, BLACK, LTBLUE );
    copper_program( 12, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 256, 0, 0, 11 );
    copper_program( 13, COPPER_WAIT_X, 7, 0, BKG_SNOW, BLACK, PURPLE );
    copper_program( 14, COPPER_JUMP, COPPER_JUMP_IF_Y_LESS, 288, 0, 0, 13 );
    copper_program( 15, COPPER_WAIT_X, 7, 0, BKG_SNOW, BLACK, MAGENTA );
    copper_program( 16, COPPER_JUMP, COPPER_JUMP_ON_VBLANK_EQUAL, 0, 0, 0, 15 );
    copper_program( 17, COPPER_JUMP, COPPER_JUMP_ALWAYS, 0, 0, 0, 1 );
    copper_startstop( 1 );
    sleep( 2000, 0 );

    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "COPPER Rainbow Stars Test 2 - MAY NOT WORK" );
    copper_startstop( 0 );
    copper_program( 0, COPPER_WAIT_VBLANK, 7, 0, BKG_SNOW, BLACK, WHITE );
    copper_program( 1, COPPER_WAIT_X, 7, 0, BKG_SNOW, BLACK, WHITE );
    copper_program( 2, COPPER_VARIABLE, COPPER_SET_VARIABLE, 0, 0, 0, 0 );
    copper_program( 3, COPPER_VARIABLE, COPPER_ADD_VARIABLE, 1, 0, 0, 0 );
    copper_program( 4, COPPER_SET_FROM_VARIABLE, 1, 0, 0, 0, 0 );
    copper_program( 5, COPPER_JUMP, COPPER_JUMP_ON_VBLANK_EQUAL, 0, 0, 0, 4 );
    copper_program( 6, COPPER_JUMP, COPPER_JUMP_IF_VARIABLE_LESS, 64, 0, 0, 3 );
    copper_program( 7, COPPER_JUMP, COPPER_JUMP_ALWAYS, 0, 0, 0, 2 );
    copper_startstop( 1 );
    sleep( 2000, 0 );
}

// PUT SOME OBJECTS ON THE TILEMAP AND WRAP LOWER LAYER UP AND LEFT , UPPER LAYER DOWN AND RIGHT
void tilemapdemo( void ) {
    displayreset();
    set_background( WHITE, DKBLUE, BKG_SNOW );
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "Tilemap Scroll With Wrap Test" );

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
        set_tilemap_tile( LOWER_LAYER, x, y, count + 1, 63 - colour, colour, i & 3 );
        set_tilemap_tile( UPPER_LAYER, x, y + 16, count + 1, 63 - colour, colour, i & 3 );

        y = ( x == 41 ) ? y + 1 : y;
        x = ( x == 41 ) ? 0 : x + 1;

        count = ( count == 9 ) ? 0 : count + 1;
    }

    for( unsigned short i = 0; i < 512; i++ ) {
        await_vblank();
        // LOWER LEFT AND UP
        (void)tilemap_scrollwrapclear( LOWER_LAYER, 5 );
        (void)tilemap_scrollwrapclear( LOWER_LAYER, 6 );
        // UPPER RIGHT AND DOWN
        (void)tilemap_scrollwrapclear( UPPER_LAYER, 7 );
        (void)tilemap_scrollwrapclear( UPPER_LAYER, 8 );
        sleep( 10, 0 );
    }
}

// WORK THROUGH THE VARIOUS GPU FUNCTIONS
void gpudemo( void ) {
    unsigned short i;
    short x1, y1, x2, y2, x3, y3;
    unsigned char colour;

    displayreset();

    // POINTS
    gpu_cs();
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "GPU Plot Pixels Test" );
    for( i = 0; i < 2048; i++ ) {
        gpu_pixel( rng( 64 ), rng( 320 ), rng( 240 ) );
    }
    sleep( 1000, 0 );

    // LINES
    gpu_cs();
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "GPU Line Drawing Test" );
    for( i = 0; i < 1024; i++ ) {
        gpu_line( rng( 64 ), rng( 320 ), rng( 240 ), rng( 320 ), rng( 240 ) );
    }
    sleep( 1000, 0 );

    // WIDE LINES
    gpu_cs();
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "GPU Wide Line Drawing Test" );
    for( i = 0; i < 1024; i++ ) {
        gpu_wideline( rng( 64 ), rng( 320 ), rng( 240 ), rng( 320 ), rng( 240 ), rng(8) + 1 );
    }
    sleep( 1000, 0 );

    // RECTANGLES
    gpu_cs();
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "GPU Rectangle Drawing Test - Solid & Dither" );
    for( i = 0; i < 1024; i++ ) {
        gpu_dither( rng(16), rng( 64 ) );
        gpu_rectangle( rng( 64 ), rng( 352 ) - 16, rng( 256 ) - 8, rng( 352 ) - 16, rng( 256 ) - 8 );
    }
    gpu_dither( DITHEROFF );
    sleep( 1000, 0 );

    // CIRCLES
    gpu_cs();
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "GPU Circle Drawing Test - Solid & Dither" );
    for( i = 0; i < 1024; i++ ) {
        gpu_dither( rng(16), rng( 64 ) );
        gpu_circle( rng( 64 ), rng( 352 ) - 16, rng( 256 ) - 8, rng( 32 ), 255, rng( 1 ) );
    }
    gpu_dither( DITHEROFF );
    sleep( 1000, 0 );

    // TRIANGLES
    gpu_cs();
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "GPU Triangle Drawing Test - Solid & Dither" );
    for( i = 0; i < 1024; i++ ) {
        x1 = rng( 352 ) - 16; y1 = rng( 256 ) - 8;
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
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "GPU Blitter Test - REFLECT & ROTATE" );
    for( i = 0; i < 128; i++ ) {
        gpu_blit( rng( 64 ), rng( 352 ) - 16, rng( 256 ) - 8, rng( 6 ), rng( 4 ), rng(8) );
    }
    sleep( 1000, 0 );

    // CHARACTER BLITTER
    gpu_cs();
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "GPU Character Blitter Test - REFLECT & ROTATE" );
    for( i = 0; i < 128; i++ ) {
        gpu_character_blit( rng( 64 ), rng( 352 ) - 16, rng( 256 ) - 8, rng( 256 ), rng( 4 ), rng(8) );
    }
    sleep( 1000, 0 );

    // COLOUR BLITTER
    // SET COLOUR BLITTER OBJECTS - ALIENS FROM GALAXIAN
    for( short i = 0; i < 3; i++ ) {
        for( short j = 0; j < 3; j++ ) {
            for( short y = 0; y < 16; y++ ) {
                for( short x = 0; x < 16; x++ ) {
                    switch( colour_blitter_strings[ j * 16 + y ][x] ) {
                        case '.':
                            colour = TRANSPARENT;
                            break;
                        case 'B':
                            colour = DKBLUE;
                            break;
                        case 'C':
                            switch( i ) {
                                case 0:
                                    colour = RED;
                                    break;
                                case 1:
                                    colour = DKMAGENTA;
                                    break;
                                case 2:
                                    colour = DKCYAN - 1;
                                    break;
                            }
                            break;
                        case 'Y':
                            colour = YELLOW;
                            break;
                    }
                    colour_blitter_bitmap[ y * 16 + x ] = colour;
                }
            }
            set_colourblitter_bitmap( i * 3 + j, &colour_blitter_bitmap[ 0 ] );
        }
    }
    gpu_cs();
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "GPU Colour Blitter Test - REFLECT & ROTATE" );
    for( i = 0; i < 128; i++ ) {
        gpu_colourblit( rng( 352 ) - 16, rng( 256 ) - 8, rng( 9 ), rng( 4 ), rng(8) );
    }
    sleep( 1000, 0 );

    // VECTOR TEST
    gpu_cs();
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "GPU Vector Draw Test - REFLECT & ROTATE" );
    set_vector_vertex( 0, 0, 1, 0, 0 );
    set_vector_vertex( 0, 1, 1, 5, 10 );
    set_vector_vertex( 0, 2, 1, 0, 6 );
    set_vector_vertex( 0, 3, 1, -5, 10 );
    set_vector_vertex( 0, 4, 1, 0, 0 );
    set_vector_vertex( 0, 5, 0, 0, 0 );
    for( i = 0; i < 128; i++ ) {
        draw_vector_block( 0, rng( 64 ), rng( 352 ) - 16, rng( 256 ) - 8, rng(8), rng(8) );
    }
    sleep( 1000, 0 );

}

void ditherdemo( void ) {
    unsigned char dithermode = 0;
    unsigned short x, y;

    displayreset();
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "GPU Dither Modes" );

    for( y = 0; y < 4; y++ ) {
        for( x = 0; x < 4; x++ ) {
            gpu_dither( dithermode, PURPLE );
            gpu_rectangle( ORANGE, x * 80, y * 60, x * 80 + 79, y * 60 + 59 );
            gpu_printf_centre( BLACK, x * 80 + 40, y * 60 + 4, 0, 0, dithernames[dithermode++] );
        }
    }
    gpu_dither( DITHEROFF );
    sleep( 2000, 0 );
}


unsigned char tune_treble[] = {  36, 48, 43, 40, 48, 42, 41, 37, 49, 44, 41, 49, 44, 41, 0xff };
unsigned short size_treble[] = { 16, 16, 16, 16,  8,  8, 32, 24, 16, 16, 16, 32, 24, 32, 0xff };

void spritedemo( void ) {
    short animation_count = 0, ghost_animation_frame = 0, move_count = 0, do_power = 0, power = 0;
    char ghost_direction[4] = { 0, 1, 2, 3 };
    unsigned short trebleposition = 0, updateflag;

    displayreset();
    tpu_print_centre( 59, TRANSPARENT, WHITE, 1, "SPRITE Demo" );

    for( unsigned char tile_number = 0; tile_number < 3; tile_number++ ) {
        set_tilemap_bitmap( LOWER_LAYER, tile_number + 1, &pacman_maze_bitmaps[ tile_number * 16 ] );
    }

    for( short y = 0; y < 32; y++ ) {
        for( short x = 0; x < 42; x++ ) {
            switch( pacman_maze[y][x] ) {
                case '.':
                    set_tilemap_tile( LOWER_LAYER, x, y, 0, TRANSPARENT, TRANSPARENT, 0 );
                    break;
                case '1':
                    set_tilemap_tile( LOWER_LAYER, x, y, 1, TRANSPARENT, BLUE, 0 );
                    break;
                case '2':
                    set_tilemap_tile( LOWER_LAYER, x, y, 1, TRANSPARENT, BLUE, REFLECT_X );
                    break;
                case '3':
                    set_tilemap_tile( LOWER_LAYER, x, y, 1, TRANSPARENT, BLUE, REFLECT_X | REFLECT_Y );
                    break;
                case '4':
                    set_tilemap_tile( LOWER_LAYER, x, y, 1, TRANSPARENT, BLUE, REFLECT_Y );
                    break;
                case '5':
                    set_tilemap_tile( LOWER_LAYER, x, y, 2, TRANSPARENT, BLUE, 0 );
                    break;
                case '6':
                    set_tilemap_tile( LOWER_LAYER, x, y, 2, TRANSPARENT, BLUE, REFLECT_X );
                    break;
                case '7':
                    set_tilemap_tile( LOWER_LAYER, x, y, 3, TRANSPARENT, BLUE, 0 );
                    break;
                case '8':
                    set_tilemap_tile( LOWER_LAYER, x, y, 3, TRANSPARENT, BLUE, REFLECT_Y );
                    break;
            }
        }
    }

    for( short i = 0; i < 4; i++ ) {
        set_sprite_bitmaps( LOWER_LAYER, i * 3, &body_bitmap[0] );
        set_sprite_bitmaps( LOWER_LAYER, i * 3 + 1, &eyewhites_bitmap[0] );
        set_sprite_bitmaps( LOWER_LAYER, i * 3 + 2, &pupils_bitmap[0] );
    }

    set_sprite( LOWER_LAYER, 0, 1, RED, 144, 64, 0, 1 );
    set_sprite( LOWER_LAYER, 1, 1, WHITE, 144, 64, 0, 1 );
    set_sprite( LOWER_LAYER, 2, 1, BLUE, 144, 64, 0, 1 );

    set_sprite( LOWER_LAYER, 3, 1, PINK, 464, 64, 2, 1 );
    set_sprite( LOWER_LAYER, 4, 1, WHITE, 464, 64, 1, 1 );
    set_sprite( LOWER_LAYER, 5, 1, BLUE, 464, 64, 1, 1 );

    set_sprite( LOWER_LAYER, 6, 1, CYAN, 464, 384, 4, 1 );
    set_sprite( LOWER_LAYER, 7, 1, WHITE, 464, 384, 2, 1 );
    set_sprite( LOWER_LAYER, 8, 1, BLUE, 464, 384, 2, 1 );

    set_sprite( LOWER_LAYER, 9, 1, LTORANGE, 144, 384, 6, 1 );
    set_sprite( LOWER_LAYER, 10, 1, WHITE, 144, 384, 3, 1 );
    set_sprite( LOWER_LAYER, 11, 1, BLUE, 144, 384, 3, 1 );

    set_sprite_bitmaps( UPPER_LAYER, 0, &pacman_bitmap[0] );
    set_sprite( UPPER_LAYER, 0, 1, YELLOW, 304, 415, 0, 1 );

    for( short i = 0; i < 1280; i++ ) {
        await_vblank();
        ghost_animation_frame = ( animation_count & 64 ) ? 1 : 0;

        // PACMAN "TUNE" - SLIGHTLY OUT
        if( tune_treble[ trebleposition ] != 0xff ) {
            if( !get_beep_active( 1 ) ) {
                if( tune_treble[ trebleposition ] != 0xff ) {
                    beep( 1, 0, tune_treble[ trebleposition ], size_treble[ trebleposition ] << 4 );
                    trebleposition++;
                }
            }
        }

        // ANIMATE PACMAN
        set_sprite_attribute( UPPER_LAYER, 0, SPRITE_TILE, ( ghost_direction[0] & 1 ) * 4 + ( ( animation_count & 96 ) >> 5 ) );
        set_sprite_attribute( UPPER_LAYER, 0, SPRITE_DOUBLE, ghost_direction[0] > 1 ? 7 : 1 );

        // ANIMATE THE GHOSTS
        for( short i = 0; i < 4; i++ ) {
            set_sprite_attribute( LOWER_LAYER, i * 3, SPRITE_TILE, ghost_direction[i] * 2 + ghost_animation_frame );
            set_sprite_attribute( LOWER_LAYER, i * 3 + 1, SPRITE_TILE, ghost_direction[i] + power * 4 );
            set_sprite_attribute( LOWER_LAYER, i * 3 + 2, SPRITE_TILE, ghost_direction[i] + power * 4);
            if( power ) {
                if( move_count < 140 ) {
                    for( short i = 0; i < 4; i++ ) {
                        set_sprite_attribute( LOWER_LAYER, i * 3, SPRITE_COLOUR, DKBLUE );
                        set_sprite_attribute( LOWER_LAYER, i * 3 + 1, SPRITE_COLOUR, PEACH );
                        set_sprite_attribute( LOWER_LAYER, i * 3 + 2, SPRITE_COLOUR, PEACH );
                    }
                } else {
                    for( short i = 0; i < 4; i++ ) {
                        set_sprite_attribute( LOWER_LAYER, i * 3, SPRITE_COLOUR, WHITE );
                        set_sprite_attribute( LOWER_LAYER, i * 3 + 1, SPRITE_COLOUR, PEACH );
                        set_sprite_attribute( LOWER_LAYER, i * 3 + 2, SPRITE_COLOUR, PEACH );
                    }
                }
            } else {
                for( short i = 0; i < 4; i++ ) {
                    set_sprite_attribute( LOWER_LAYER, i * 3 + 1, SPRITE_COLOUR, WHITE );
                    set_sprite_attribute( LOWER_LAYER, i * 3 + 2, SPRITE_COLOUR, BLUE );
                }
                set_sprite_attribute( LOWER_LAYER, 0, SPRITE_COLOUR, RED );
                set_sprite_attribute( LOWER_LAYER, 3, SPRITE_COLOUR, PINK );
                set_sprite_attribute( LOWER_LAYER, 6, SPRITE_COLOUR, CYAN );
                set_sprite_attribute( LOWER_LAYER, 9, SPRITE_COLOUR, LTORANGE );
            }
        }

        // MOVE THE GHOSTS
        for( short i = 0; i <4; i++ ) {
            switch( ghost_direction[i] ) {
                case 0:
                    updateflag = 0b0000000000001;
                    break;
                case 1:
                    updateflag = 0b0000000100000;
                    break;
                case 2:
                    updateflag = 0b0000000011111;
                    break;
                case 3:
                    updateflag = 0b0001111100000;
                    break;
            }
            update_sprite( LOWER_LAYER, i * 3, updateflag );
            update_sprite( LOWER_LAYER, i * 3 + 1, updateflag );
            update_sprite( LOWER_LAYER, i * 3 + 2, updateflag );

        }

        // CHECK IF MOVED 160 SPACES
        move_count++;
        if( move_count == 160 ) {
            move_count = 0;
            for( short i = 0; i < 4; i++ ) {
                ghost_direction[i] = ( ghost_direction[i] + 1 ) & 3;
            }
            do_power++;
            if( do_power == 4 ) {
                power = 1- power;
                do_power = 0;
            }
        }

       // LEFT
        if( ( get_buttons() & 32 ) != 0 ) {}
        // RIGHT
        if( ( get_buttons() & 64 ) != 0 ) {}
        // UP
        if( ( get_buttons() & 8 ) != 0 ) {}
        // DOWN
        if( ( get_buttons() & 16 ) != 0 ) {}

        animation_count++;
    }
}

void floatdemo() {
    struct Point2D Square[4] = { { -100, -100 }, { 100, -100 }, { 100, 100 }, { -100, 100 } };
    unsigned char colour = 63;
    float scale = 1;

    displayreset();
    tpu_print_centre( 58, TRANSPARENT, WHITE, 1, "SOFTWARE VECTOR TEST" );
    if( CSRisa() & 0b100000 ) {
        tpu_print_centre( 59, TRANSPARENT, WHITE, 0, "FLOATING POINT UNIT AVAILABLE" );
    } else {
        tpu_print_centre( 59, TRANSPARENT, WHITE, 0, "SOFT FLOAT ONLY" );
    }
    for( short angle = 0; angle < 360; angle += 5 ) {
        DrawVectorShape2D( colour, Square, 4, 160, 120, angle, scale );
        colour = ( colour == 1 ) ? 63 : colour - 1;
        scale = scale - 0.01;
    }
    sleep( 2000, 0 );
}

int main( void ) {
    INITIALISEMEMORY();
	for( int loop = 0; loop < 4; loop++ ) {
        colourtable();

        backgrounddemo();

        tilemapdemo();

        gpudemo();

        ditherdemo();

        spritedemo();

        floatdemo();
    }
}
