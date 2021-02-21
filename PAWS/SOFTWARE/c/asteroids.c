#include "PAWSlibrary.h"
#include <stdlib.h>

// INCLUDE GALAXY BACKDROP
#include "GALAXY_BMP.h"

// MACROS
// Convert asteroid number to sprite layer and number
#define ASN(a) ( a > 9) ? 1 : 0, ( a > 9) ? a - 10 : a
#define MAXASTEROIDS 20

    // GLOBAL VARIABLES
    unsigned short lives = 0, score = 0, level = 0;
    unsigned short shield, fuel;
    int counter = 0;

    // SHIP and BULLET
    short shipx = 312, shipy = 232, shipdirection = 0, resetship = 0, bulletdirection = 0;

    // ASTEROIDS and UFO
    unsigned char asteroid_active[MAXASTEROIDS], asteroid_direction[MAXASTEROIDS], ufo_sprite_number = 0xff, ufo_leftright = 0, ufo_bullet_direction = 0;

    // BEEP / BOOP TIMER
    short last_timer = 0;

    // GLOBAL SPRITE UPDATE VALUES
    unsigned short bullet_directions[] = {
        0x1f40, 0x1f65, 0x1c06, 0x1ca5, 0x1cc0, 0x1cbb, 0x1c1a, 0x1f7b
    };

    unsigned short asteroid_directions[] = {
        0x3e1, 0x21, 0x3f, 0x3ff, 0x3c1, 0x3e2, 0x22, 0x41, 0x5f, 0x3e, 0x3fe, 0x3df
    };

    unsigned short ufo_directions[] = {
        0x1c02, 0x1c1e, 0x1c03, 0x1c1d
    };

    // GLOBAL GRAPHICS
    unsigned short asteroid_bitmap[] = {
        0x07f0, 0x0ff8, 0x1ffe, 0x1fff, 0x3fff, 0xffff, 0xfffe, 0xfffc,
        0xffff, 0x7fff, 0x7fff, 0x7ffe, 0x3ffc, 0x3ffc, 0x0ff8, 0x00f0,
        0x1008, 0x3c1c, 0x7f1e, 0xffff, 0x7ffe, 0x7ffe, 0x3ff8, 0x3ff0,
        0x1ff8, 0x0ff8, 0x1ffc, 0x7ffe, 0xffff, 0x7ffe, 0x3dfc, 0x1878,
        0x0787, 0x1f8e, 0x0fde, 0x67fc, 0xfffc, 0xfffe, 0xffff, 0x7fff,
        0x7ffc, 0x3ff8, 0x3ffc, 0x7ffe, 0xffff, 0xfffe, 0x3ffc, 0x73f8,
        0x1800, 0x3f98, 0x3ffc, 0x1ffe, 0x1ffe, 0x1ffe, 0x7ffe, 0xffff,
        0xffff, 0xffff, 0xfffe, 0xfffe, 0x3ffc, 0x1ff0, 0x07c0, 0x0180,
        0x0ff0, 0x1ffc, 0x1ffe, 0x3ffe, 0x3fff, 0x7fff, 0x7fff, 0xffff,
        0xffff, 0xfffe, 0xfffc, 0x7ffc, 0x3ffc, 0x3ff0, 0x3ff0, 0x07e0,
        0x0000, 0x0000, 0x0000, 0x0180, 0x03c0, 0x03e0, 0x07f8, 0x07fc,
        0x0ffc, 0x1ffc, 0x1ff8, 0x0ff8, 0x01f0, 0x0000, 0x0000, 0x0000,
        0x0600, 0x0fe0, 0x1ff8, 0x3ffc, 0x7ffe, 0xfffe, 0x0fff, 0x1fff,
        0x1fff, 0x3fff, 0x7fff, 0x7ffe, 0x3e7c, 0x3c38, 0x3800, 0x3000,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018
    };
    unsigned short ufo_bitmap[] = {
        0x0000, 0x0000, 0x03c0, 0x03c0, 0x07a0, 0x0ff0, 0x3ffc, 0x7ffe,
        0xfff3, 0x3ffc, 0x1ff8, 0x0ff0, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x03c0, 0x03c0, 0x0760, 0x0ff0, 0x3ffc, 0x7ffe,
        0xffcf, 0x3ffc, 0x1ff8, 0x0ff0, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x03c0, 0x03c0, 0x06e0, 0x0ff0, 0x3ffc, 0x7ffe,
        0xff3f, 0x3ffc, 0x1ff8, 0x0ff0, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x03c0, 0x03c0, 0x05f0, 0x0ff0, 0x3ffc, 0x7ffe,
        0xfcff, 0x3ffc, 0x1ff8, 0x0ff0, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x03c0, 0x03c0, 0x07a0, 0x0ff0, 0x3ffc, 0x7ffe,
        0xf3ff, 0x3ffc, 0x1ff8, 0x0ff0, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x03c0, 0x03c0, 0x0760, 0x0ff0, 0x3ffc, 0x7ffe,
        0xcfff, 0x3ffc, 0x1ff8, 0x0ff0, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x03c0, 0x03c0, 0x06e0, 0x0ff0, 0x3ffc, 0x7ffe,
        0xffff, 0x3ffc, 0x1ff8, 0x0ff0, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x03c0, 0x03c0, 0x05f0, 0x0ff0, 0x3ffc, 0x7ffe,
        0xffff, 0x3ffc, 0x1ff8, 0x0ff0, 0x0000, 0x0000, 0x0000, 0x0000,
    };
    unsigned short ufo_bullet_bitmap[] = {
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0080,
        0x0100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0100,
        0x0080, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0080,
        0x0100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0100,
        0x0080, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0080,
        0x0100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0100,
        0x0080, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0080,
        0x0100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0100,
        0x0080, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
    };

    unsigned short ship_bitmap_upper[] = {
        0x0100, 0x0100, 0x0280, 0x0440, 0x0440, 0x0820, 0x0820, 0x0820,
        0x1010, 0x1010, 0x1010, 0x2008, 0x2108, 0x46c4, 0x783c, 0x0000,
        0x0001, 0x001e, 0x0062, 0x0782, 0x1802, 0xe004, 0x4004, 0x2008,
        0x1808, 0x0608, 0x0208, 0x0110, 0x0110, 0x00a0, 0x0060, 0x0020,
        0x0000, 0x6000, 0x5800, 0x4700, 0x40e0, 0x2018, 0x2004, 0x1003,
        0x2004, 0x2018, 0x40e0, 0x4700, 0x5800, 0x6000, 0x0000, 0x0000,
        0x0020, 0x0060, 0x00a0, 0x0110, 0x0110, 0x0208, 0x0608, 0x1808,
        0x2008, 0x4004, 0xe004, 0x1802, 0x0782, 0x0062, 0x001e, 0x0001,
        0x0000, 0x3c1e, 0x2362, 0x1084, 0x1004, 0x0808, 0x0808, 0x0808,
        0x0410, 0x0410, 0x0410, 0x0220, 0x0220, 0x0140, 0x0080, 0x0080,
        0x0400, 0x0600, 0x0500, 0x0880, 0x0880, 0x1040, 0x1060, 0x1018,
        0x1004, 0x2002, 0x2007, 0x4018, 0x41e0, 0x4600, 0x7800, 0x8000,
        0x0000, 0x0000, 0x0006, 0x001a, 0x00e2, 0x0702, 0x1804, 0x2004,
        0xc008, 0x2004, 0x1804, 0x0702, 0x00e2, 0x001a, 0x0006, 0x0000,
        0x8000, 0x7800, 0x4600, 0x41e0, 0x4018, 0x2007, 0x2002, 0x1004,
        0x1018, 0x1060, 0x1040, 0x0880, 0x0880, 0x0500, 0x0600, 0x0400,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010
    };

    unsigned short ship_bitmap_lower[] = {
        0x0100, 0x0100, 0x0380, 0x07c0, 0x07c0, 0x0fe0, 0x0fe0, 0x0fe0,
        0x1ff0, 0x1ff0, 0x1ff0, 0x3ff8, 0x3ff8, 0x7efc, 0x783c, 0x0000,
        0x0001, 0x001e, 0x007e, 0x07fe, 0x1ffe, 0xfffc, 0x7ffc, 0x3ff8,
        0x1ff8, 0x07f8, 0x03f8, 0x01f0, 0x01f0, 0x00e0, 0x0060, 0x0020,
        0x0000, 0x6000, 0x7800, 0x7f00, 0x7ff0, 0x7ff8, 0x3ff8, 0x1fff,
        0x3ff8, 0x3ff8, 0x7ff0, 0x7ff0, 0x7800, 0x6000, 0x0000, 0x0000,
        0x0020, 0x0060, 0x00e0, 0x01f0, 0x01f0, 0x03f8, 0x07f8, 0x1ff8,
        0x3ff8, 0x7ffc, 0xfffc, 0x1ffe, 0x07fe, 0x007e, 0x001e, 0x0001,
        0x0000, 0x3c1e, 0x3f7e, 0x1ffc, 0x1ffc, 0x0ff8, 0x0ff8, 0x0ff8,
        0x07f0, 0x07f0, 0x07f0, 0x03e0, 0x03e0, 0x01c0, 0x0080, 0x0080,
        0x0400, 0x0600, 0x0700, 0x0f80, 0x0f80, 0x1fc0, 0x1fe0, 0x1ff8,
        0x1ffc, 0x3ffe, 0x3fff, 0x7ff8, 0x7fe0, 0x7e00, 0x7800, 0x8000,
        0x0000, 0x0000, 0x0006, 0x001e, 0x00fe, 0x07fe, 0x1ffc, 0x3ffc,
        0xfff8, 0x3ffc, 0x1ffc, 0x07fe, 0x00fe, 0x001e, 0x0006, 0x0000,
        0x8000, 0x7800, 0x7e00, 0x7fe0, 0x7ff8, 0x3fff, 0x3ffe, 0x1ffc,
        0x1ff8, 0x1fe0, 0x1fc0, 0x0f80, 0x0f80, 0x0700, 0x0600, 0x0400,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0000, 0x0300, 0x0302, 0x6010, 0x6000, 0x0000, 0x0419, 0x8018,
        0x0020, 0x4206, 0x0006, 0x1820, 0x1800, 0x0081, 0x0400, 0x4010
    };
    unsigned short bullet_bitmap[] = {
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0100, 0x0100, 0x07c0,
        0x0100, 0x0100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0440, 0x0280, 0x0100,
        0x0280, 0x0440, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0100, 0x0380, 0x07c0,
        0x0380, 0x0100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0540, 0x0380, 0x07c0,
        0x0380, 0x0540, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0100, 0x0100, 0x07c0,
        0x0100, 0x0100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0440, 0x0280, 0x0100,
        0x0280, 0x0440, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0100, 0x0380, 0x07c0,
        0x0380, 0x0100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0540, 0x0380, 0x07c0,
        0x0380, 0x0540, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
    };

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

// GENERATE A RANDOM COLOUR WITH AT LEAST ONE OF RED, GREEN, BLUE BEING INTENSITY 2
unsigned char random_colour( void )
{
    unsigned char red, green, blue;

    do {
        red = rng( 4 );
        green = rng( 4 );
        blue = rng( 4 );
    } while( ( red < 2 ) && ( green < 2 ) && ( blue < 2 ) );

    return( red * 16 + green * 4 + blue );
}

// GENERATE A RANDOM COLOUR WITH AT LEAST ONE OF RED, GREEN, BLUE BEING INTENSITY 1
unsigned char random_colour_alt( void )
{
    unsigned char red, green, blue;

    do {
        red = rng( 1 );
        green = rng( 1 );
        blue = rng( 1 );
    } while( ( red + green + blue ) == 0 );

    return( red * 16 + green * 4 + blue );
}

void set_asteroid_sprites( void )
{
    for( unsigned char asteroid_number = 0; asteroid_number < MAXASTEROIDS; asteroid_number++ ) {
        set_sprite_bitmaps( ASN(asteroid_number), &asteroid_bitmap[0] );
    }
}

void set_ship_sprites( unsigned char exploding )
{
    set_sprite_bitmaps( 0, 11, &ship_bitmap_lower[ exploding ? 128 : 0 ] );
    set_sprite_bitmaps( 1, 11, &ship_bitmap_upper[ exploding ? 128 : 0 ] );
}

void set_ship_vector( void )
{
    set_vector_vertex( 0, 0, 1, 0, 0 );
    set_vector_vertex( 0, 1, 1, 5, 10 );
    set_vector_vertex( 0, 2, 1, 0, 6 );
    set_vector_vertex( 0, 3, 1, -5, 10 );
    set_vector_vertex( 0, 4, 1, 0, 0 );
    set_vector_vertex( 0, 5, 0, 0, 0 );
}

void set_bullet_sprites( void )
{
        set_sprite_bitmaps( 0, 12, &bullet_bitmap[0] );
        set_sprite_bitmaps( 1, 12, &bullet_bitmap[0] );
}

void set_ufo_sprite( unsigned char ufo_asteroid )
{
    set_sprite_bitmaps( ASN( ufo_sprite_number ), ufo_asteroid ? &ufo_bitmap[0] : &asteroid_bitmap[0] );
}

void set_ufo_bullet_sprites( void ) {
    set_sprite_bitmaps( 0, 10, &ufo_bullet_bitmap[0] );
    set_sprite_bitmaps( 1, 10, &ufo_bullet_bitmap[0] );
}

void set_tilemap( void )
{
    unsigned char x, y, colour;

    (void)tilemap_scrollwrapclear( 9 );

    for( unsigned char tile_number = 0; tile_number < 8; tile_number++ ) {
        set_tilemap_bitmap( tile_number + 1, &tilemap_bitmap[ tile_number * 16 ] );
    }

    // RANDOMLY PLACE 4 PLANETS and 4 ROCKET SHIPS
    for( unsigned char i = 0; i < 4; i++ ) {
        x = rng( 18 ) + ( x&1 ? 1 : 21 );
        y = rng( 7 ) + i*7 + 1;
        colour = random_colour_alt();

        set_tilemap_tile( x, y, 1, TRANSPARENT, colour ); set_tilemap_tile( x, y+1, 2, TRANSPARENT, colour ); set_tilemap_tile( x+1, y, 3, TRANSPARENT, colour ); set_tilemap_tile( x+1, y+1, 4, TRANSPARENT, colour );
    }

    for( unsigned char i = 0; i < 4; i++ ) {
        x = rng( 18 ) + ( x&1 ? 21 : 1 );
        y = rng( 7 ) + i*7 + 1;
        colour = random_colour_alt();

        set_tilemap_tile( x, y, 5, TRANSPARENT, colour ); set_tilemap_tile( x, y+1, 6, TRANSPARENT, colour ); set_tilemap_tile( x+1, y, 7, TRANSPARENT, colour ); set_tilemap_tile( x+1, y+1, 8, TRANSPARENT, colour );
    }
}

// DRAW GAME OVER IN LARGE MULTICOLOURED LETTERS
void game_over( void )
{
    gpu_character_blit( random_colour(), 176, 224, 'G', 2 );
    gpu_character_blit( random_colour(), 208, 232, 'A', 2 );
    gpu_character_blit( random_colour(), 240, 224, 'M', 2 );
    gpu_character_blit( random_colour(), 272, 232, 'E', 2 );
    gpu_character_blit( random_colour(), 336, 224, 'O', 2 );
    gpu_character_blit( random_colour(), 368, 232, 'V', 2 );
    gpu_character_blit( random_colour(), 400, 224, 'E', 2 );
    gpu_character_blit( random_colour(), 432, 232, 'R', 2 );
}

// DRAW A RISC-V LOGO AT THE TOP LEFT OF THE SCREEN
void risc_ice_v_logo( void )
{
    // DISPLAY GALAXY BITMAP
    bitmapblit( galaxybitmap, 640, 480, 0, 0, BLACK );

    gpu_rectangle( ORANGE, 0, 0, 100, 100 );
    gpu_triangle( WHITE, 100, 33, 100, 100, 50, 100 );
    gpu_triangle( DKBLUE, 100, 50, 100, 100, 66, 100 );
    gpu_rectangle( DKBLUE, 0, 0, 33, 50 );
    gpu_circle( WHITE, 25, 25, 26, 1 );
    gpu_rectangle( WHITE, 0, 0, 25, 12 );
    gpu_circle( DKBLUE, 25, 25, 12, 1 );
    gpu_triangle( WHITE, 0, 33, 67, 100, 0, 100 );
    gpu_triangle( DKBLUE, 0, 50, 50, 100, 0, 100 );
    gpu_rectangle( DKBLUE, 0, 12, 25, 37 );
    gpu_rectangle( DKBLUE, 0, 37, 8, 100 );

}

// DRAW FULL OR ERASE END OF FUEL AND SHIELD BARS
void drawfuel( unsigned char fullbar )
{
    if( fullbar ) {
        gpu_rectangle( RED, 70, 456, 328, 463 );
        gpu_printf( RED, 30, 456, 0, "FUEL:" );
    }
    gpu_character_blit( RED, 71 + ( fuel >> 2 ), 456, 219, 0 );
    gpu_character_blit( WHITE, 70 + ( fuel >> 2 ), 456, 30, 0 );
}
void drawshield( unsigned char fullbar )
{
    if( fullbar ) {
        gpu_rectangle( BLUE, 70, 464, 328, 471 );
        gpu_printf( BLUE, 14, 464, 0, "SHIELD:" );
    }
    gpu_character_blit( BLUE, 71 + shield, 464, 219, 0 );
    gpu_character_blit( WHITE, 70 + shield, 464, 30, 0 );
}

void setup_game()
{
    // CLEAR ALL SPRITES
    for( unsigned char sprite_number = 0; sprite_number < 26; sprite_number++ ) {
        if( sprite_number < MAXASTEROIDS ) {
            asteroid_active[sprite_number] = 0; asteroid_direction[sprite_number] = 0;
        }
        set_sprite( ( sprite_number > 12 ) ? 1 : 0, ( sprite_number > 12 ) ? sprite_number - 13 : sprite_number, 0, 0, 0, 0, 0, 0 );
    }

    // DROP THE BITMAP TO JUST ABOVE THE BACKGROUND
    screen_mode( 2 );

    // CLEAR and SET THE BACKGROUND
    gpu_cs();
    set_background( GREY2, DKBLUE - 1, BKG_SNOW );
    risc_ice_v_logo();
    set_tilemap();

    tpu_cs();
    set_asteroid_sprites();
    set_ship_sprites( 0 );
    set_ship_vector();
    set_bullet_sprites();
    set_ufo_bullet_sprites();

    lives = 0; score = 0;
    fuel = 1000; shield = 250;
    drawfuel(1); drawshield(1);

    shipx = 312; shipy = 232; shipdirection = 0; resetship = 0; bulletdirection = 0;

    counter = 0;
}

unsigned char find_asteroid_space( void ) {
    unsigned char asteroid_space = 0xff, spaces_free = 0;

    for( unsigned char asteroid_number = 0; asteroid_number < MAXASTEROIDS; asteroid_number++ ) {
        asteroid_space = ( asteroid_active[asteroid_number] == 0 ) ? asteroid_number : asteroid_space;
        spaces_free += ( asteroid_active[asteroid_number] == 0 ) ? 1 : 0;
    }

    return( ( spaces_free == 1 ) ? 0xff : asteroid_space );
}

void move_asteroids( void ) {
    // SETUP STACKPOINTER FOR THE SMT THREAD
    asm volatile ("li sp ,0x2000");

    while(1) {
        await_vblank();
        set_timer1khz( 4, 1 );

        for( unsigned char asteroid_number = 0; asteroid_number < MAXASTEROIDS; asteroid_number++ ) {
            if( ( asteroid_active[asteroid_number] != 0 ) && ( asteroid_active[asteroid_number] < 3 ) ) {
                update_sprite_SMT( ASN( asteroid_number ), asteroid_directions[ asteroid_direction[asteroid_number] ] );
            }

            // UFO
            if(  asteroid_active[asteroid_number] == 3 ) {
                update_sprite_SMT( ASN( asteroid_number ), ufo_directions[ufo_leftright + ( level > 2 ? 2 : 0 )] );
                if( get_sprite_attribute_SMT( ASN( asteroid_number), 0 ) == 0 ) {
                    // UFO OFF SCREEN
                    set_ufo_sprite( 0 );
                    asteroid_active[asteroid_number] = 0;
                    ufo_sprite_number = 0xff;
                }
            }

            // EXPLOSION - STATIC and countdown
            if( asteroid_active[asteroid_number] > 5 )
                asteroid_active[asteroid_number]--;

            if( asteroid_active[asteroid_number] == 5 ) {
                asteroid_active[asteroid_number] = 0;
                set_sprite_SMT( ASN( asteroid_number ), 0, 0, 0, 0, 0, 0 );
            }
        }
    wait_timer1khz( 1 );
    }
}

unsigned short count_asteroids( void )
{
    short number_of_asteroids = 0;

    for( unsigned char asteroid_number = 0; asteroid_number < MAXASTEROIDS; asteroid_number++ ) {
        if( ( asteroid_active[asteroid_number] == 1 ) || ( asteroid_active[asteroid_number] == 2 ) ) {
            number_of_asteroids++;
        }
    }

    return( number_of_asteroids );
}

void draw_ship( unsigned char colour )
{
    set_sprite( 0, 11, 1, ORANGE, shipx, shipy, shipdirection, 0);
    set_sprite( 1, 11, 1, colour, shipx, shipy, shipdirection, 0);
}

void move_ship()
{
    switch( shipdirection ) {
        case 0:
            shipy = ( shipy > 0 ) ? shipy - 1 : 464;
            break;
        case 1:
            shipx = ( shipx < 624 ) ? shipx + 1 : 0;
            shipy = ( shipy > 0 ) ? shipy - 1 : 464;
            break;
        case 2:
            shipx = ( shipx < 624 ) ? shipx + 1 : 0;
            break;
        case 3:
            shipx = ( shipx < 624 ) ? shipx + 1 : 0;
            shipy = ( shipy < 464 ) ? shipy + 1 : 0;
            break;
        case 4:
            shipy = ( shipy < 464 ) ? shipy + 1 : 0;
            break;
        case 5:
            shipx = ( shipx > 0 ) ? shipx - 1 : 624;
            shipy = ( shipy < 464 ) ? shipy + 1 : 0;
            break;
        case 6:
            shipx = ( shipx > 0 ) ? shipx - 1 : 624;
            break;
        case 7:
            shipx = ( shipx > 0 ) ? shipx - 1 : 624;
            shipy = ( shipy > 0 ) ? shipy - 1 : 464;
            break;
    }
}

void draw_score( void )
{
    tpu_set( 34, 1, TRANSPARENT, ( lives > 0 ) ? WHITE : GREY1 ); tpu_printf( "Score %5d", score );
}

void draw_lives( void )
{
    switch( lives ) {
        case 3:
            draw_vector_block( 0, WHITE, 608, 464 );

        case 2:
            draw_vector_block( 0, WHITE, 576, 464 );

        case 1:
            draw_vector_block( 0, WHITE, 544, 464 );
            break;
    }
}

void fire_bullet( void )
{
    short bulletx, bullety;

    bulletdirection = shipdirection;
    switch( bulletdirection ) {
        case 0:
            bulletx = shipx; bullety = shipy - 10;
            break;
        case 1:
            bulletx = shipx + 8; bullety = shipy - 10;
            break;
        case 2:
            bulletx = shipx + 10; bullety = shipy;
            break;
        case 3:
            bulletx = shipx + 10; bullety = shipy + 10;
            break;
        case 4:
            bulletx = shipx; bullety = shipy + 10;
            break;
        case 5:
            bulletx = shipx - 10; bullety = shipy + 10;
            break;
        case 6:
            bulletx = shipx - 10; bullety = shipy;
            break;
        case 7:
            bulletx = shipx - 10; bullety = shipy - 10;
            break;
    }
    set_sprite( 0, 12, 1, YELLOW, bulletx, bullety, 2, 0);
    set_sprite( 1, 12, 1, RED, bulletx, bullety, 0, 0);

    beep( 2, 4, 61, 128 );
}

void update_bullet( void )
{
    // PLAYER BULLET
    update_sprite( 0, 12, bullet_directions[ bulletdirection ] );
    update_sprite( 1, 12, bullet_directions[ bulletdirection ] );

    // UFO BULLET
    update_sprite( 0, 10, bullet_directions[ ufo_bullet_direction ] );
    update_sprite( 1, 10, bullet_directions[ ufo_bullet_direction ] );
}

void beepboop( void )
{
    if( last_timer != get_timer1hz( 0 ) ) {
        draw_score();

        last_timer = get_timer1hz( 0 );

        (void)tilemap_scrollwrapclear( 5 );

        switch( last_timer & 3 ) {
            case 0:
                if( lives == 0 ) {
                    tpu_printf_centre( 26, TRANSPARENT, BLUE, "Welcome to Risc-ICE-V Asteroids" );
                    tpu_printf_centre( 3, TRANSPARENT, DKBLUE, "Controls: Fire 1 - FIRE" );
                    game_over();
                } else {
                    if( ufo_sprite_number != 0xff ) {
                        beep( 1, 3, 63, 32 );
                    } else {
                        beep( 1, 0, 1, 500 );
                    }
                }
                break;

            case 1:
                if( lives == 0 ) {
                    tpu_printf_centre( 26, TRANSPARENT, CYAN, "By @robng15 (Twitter) from Whitebridge, Scotland" );
                    tpu_printf_centre( 3, TRANSPARENT, PURPLE, "Controls: Fire 2 - SHIELD" );
                    game_over();
                } else {
                    if( ufo_sprite_number != 0xff ) {
                        beep( 1, 3, 63, 32 );
                    }
                }
                break;

            case 2:
                if( lives == 0 ) {
                    tpu_printf_centre( 26, TRANSPARENT, YELLOW, "Press UP to start" );
                    tpu_printf_centre( 3, TRANSPARENT, ORANGE, "Controls: Left / Right - TURN" );
                    game_over();
                } else {
                    if( ufo_sprite_number != 0xff ) {
                        beep( 1, 3, 63, 32 );
                    } else {
                        beep( 1, 0, 2, 500 );
                    }
                }
                break;

            case 3:
                // MOVE TILEMAP UP
                if( lives == 0 ) {
                    tpu_printf_centre( 26, TRANSPARENT, RED, "Written in Silice by @sylefeb" );
                    tpu_printf_centre( 3, TRANSPARENT, DKRED, "Controls: UP - MOVE" );
                    game_over();
                } else {
                    if( ufo_sprite_number != 0xff ) {
                        beep( 1, 3, 63, 32 );
                    }
                }
                (void)tilemap_scrollwrapclear( 6 );
                break;
        }
    }
}

void spawn_asteroid( unsigned char asteroid_type, short xc, short yc )
{
    unsigned char potentialnumber;

    potentialnumber = find_asteroid_space();
    if( potentialnumber != 0xff ) {
        asteroid_active[ potentialnumber ] = asteroid_type;
        asteroid_direction[ potentialnumber ] = rng( ( asteroid_type == 2 ) ? 4 : 8 );

        set_sprite( ASN( potentialnumber ), 1, random_colour(), xc + rng(16) - 8, yc + rng(16) - 8, rng( 7 ), ( asteroid_type == 2 ) ? 1 : 0 );
    }
}

void check_ufo_bullet_hit( void )
{
    unsigned char asteroid_hit = 0xff, spawnextra;
    short x, y;

    if( ( ( get_sprite_collision( 0, 10 ) & 0x3ff ) != 0 ) || ( ( get_sprite_collision( 1, 10 ) & 0x3ff ) != 0 ) ) {
        beep( 2, 4, 8, 500 );
        for( unsigned char asteroid_number = 0; asteroid_number < MAXASTEROIDS; asteroid_number++ ) {
            if( get_sprite_collision( ASN( asteroid_number ) ) & 0x400 ) {
                asteroid_hit = asteroid_number;
            }
        }

        if( ( asteroid_hit != 0xff ) && ( asteroid_active[asteroid_hit] < 3 ) ) {
            // DELETE BULLET
            set_sprite_attribute( 0, 10, 0, 0 );
            set_sprite_attribute( 1, 10, 0, 0 );

            x = get_sprite_attribute( ASN( asteroid_hit ), 3 );
            y = get_sprite_attribute( ASN( asteroid_hit ), 4 );

            // SPAWN NEW ASTEROIDS
            if( asteroid_active[asteroid_hit] == 2 ) {
                spawnextra = 1 + ( ( level < 2 ) ? level : 2 ) + ( ( level > 2 ) ? rng( 2 ) : 0 );
                for( int i=0; i < spawnextra; i++ ) {
                    spawn_asteroid( 1, x, y );
                }
            }

            // SET EXPLOSION TILE
            set_sprite_attribute( ASN( asteroid_hit ), 1, 7 );
            asteroid_active[asteroid_hit] = 32;
        }
    }
}

void check_hit( void )
{
    unsigned char asteroid_hit = 0xff, colour, spritesize, spawnextra;
    short x, y;

    if( ( ( get_sprite_collision( 0, 12 ) & 0x3ff ) != 0 ) || ( ( get_sprite_collision( 1, 12 ) & 0x3ff ) != 0 ) ) {
        beep( 2, 4, 8, 500 );
        for( unsigned char asteroid_number = 0; asteroid_number < MAXASTEROIDS; asteroid_number++ ) {
            if( get_sprite_collision( ASN( asteroid_number ) ) & 0x1000 ) {
                asteroid_hit = asteroid_number;
            }
        }

        if( ( asteroid_hit != 0xff ) && ( asteroid_active[asteroid_hit] < 3 ) ) {
            // DELETE BULLET
            set_sprite_attribute( 0, 12, 0, 0 );
            set_sprite_attribute( 1, 12, 0, 0 );

            score += ( 3 - asteroid_active[asteroid_hit] );

            x = get_sprite_attribute( ASN( asteroid_hit ), 3 );
            y = get_sprite_attribute( ASN( asteroid_hit ), 4 );
            spritesize = get_sprite_attribute( ASN( asteroid_hit ), 5 );

            // SPAWN NEW ASTEROIDS
            if( asteroid_active[asteroid_hit] == 2 ) {
                spawnextra = 1 + ( ( level < 2 ) ? level : 2 ) + ( ( level > 2 ) ? rng( 2 ) : 0 );
                for( int i=0; i < spawnextra; i++ ) {
                    spawn_asteroid( 1, x, y );
                }
            }

            set_sprite( ASN( asteroid_hit ), 1, RED, x, y, 7, spritesize );
            asteroid_active[asteroid_hit] = 32;
        } else {
            switch( asteroid_active[asteroid_hit] ) {
                case 3:
                    // UFO
                    score += ( level < 2 ) ? 10 : 20;
                    // DELETE BULLET
                    set_sprite_attribute( 0, 12, 0, 0 );
                    set_sprite_attribute( 1, 12, 0, 0 );

                    x = get_sprite_attribute( ASN( asteroid_hit ), 3 );
                    y = get_sprite_attribute( ASN( asteroid_hit ), 4 );
                    set_sprite_attribute( ASN( asteroid_hit ), 1, 7 );
                    set_sprite_attribute( ASN( asteroid_hit ), 2, RED );
                    set_ufo_sprite( 0 );
                    ufo_sprite_number = 0xff;
                    asteroid_active[asteroid_hit] = 32;
                    // AVOID BONUS FUEL AND SHIELD
                    fuel += 10 + rng( ( level < 2 ) ? 10 : 40 );
                    fuel = ( fuel > 1000 ) ? 1000 : fuel;
                    shield += 5 + rng( ( level < 2 ) ? 5 : 10 );
                    shield = ( shield > 250 ) ? 250 : shield;
                    drawfuel(1);
                    drawshield(1);
                    break;

                default:
                    // EXPLOSION
                    break;
            }
        }
    }
}

void check_crash( void )
{
    if( ( ( get_sprite_collision( 0, 11 ) & 0x7ff ) != 0 ) || ( ( get_sprite_collision( 1, 11 ) & 0x7ff ) != 0 ) ) {
        if( ( ( get_sprite_collision( 0, 10 ) &  0x800 ) != 0 ) || ( ( get_sprite_collision( 1, 10 ) & 0x800 ) != 0 ) ) {
            // DELETE UFO BULLET
            set_sprite_attribute( 0, 10, 0, 0 );
            set_sprite_attribute( 1, 10, 0, 0 );
        }
        beep( 2, 4, 1, 1000 );
        set_ship_sprites( 1 );
        set_sprite_attribute( 0, 10, 1, 0 );
        set_sprite_attribute( 1, 10, 1, 1 );
        resetship = 75;
    }
}

// MAIN GAME LOOP STARTS HERE
int main( void ) {
    INITIALISEMEMORY();

    unsigned char uartData = 0, potentialnumber = 0;
    short ufo_x = 0, ufo_y = 0, potentialx = 0, potentialy = 0;
    unsigned short placeAsteroids = 4, asteroid_number = 0;

    // INITIALISE ALL VARIABLES AND START THE ASTEROID MOVING THREAD
    setup_game();
    SMTSTART( (unsigned int )move_asteroids );

    while(1) {
        counter++;

        // PLACE NEW LARGE ASTEROIDS
        if( ( placeAsteroids > 0 ) && ( ( counter & 63 ) == 0 ) ) {
            potentialnumber = find_asteroid_space();
            if( potentialnumber != 0xff ) {
                switch( rng(4) ) {
                    case 0:
                        potentialx = -31;
                        potentialy = rng(480);
                        break;
                    case 1:
                        potentialx = -639;
                        potentialy = rng(480);
                        break;
                    case 2:
                        potentialx = rng(640);
                        potentialy = -31;
                        break;
                    case 3:
                        potentialx = rng(640);
                        potentialy = 479;
                        break;
                }
                asteroid_active[ potentialnumber ] = 2;
                asteroid_direction[ potentialnumber ] = rng( 4 );
                set_sprite( ASN( potentialnumber), 1, random_colour(), potentialx, potentialy, rng( 7 ), 1 );
            }
            placeAsteroids--;
        }

        // NEW LEVEL NEEDED
        if( ( count_asteroids() == 0 ) && ( placeAsteroids == 0 ) ) {
            level++;
            placeAsteroids = 4 + ( ( level < 4 ) ? level : 4 );
        }

        // AWAIT VBLANK and SET DELAY
        await_vblank();
        set_timer1khz( 4, 0 );

        // BEEP / BOOP
        beepboop();

        if( ( rng( 512 ) == 1 ) && ( ufo_sprite_number == 0xff ) && ( get_sprite_attribute( 0, 10, 0 ) == 0 ) ) {
            // START UFO
            ufo_sprite_number = find_asteroid_space();

            if( ufo_sprite_number != 0xff ) {
                // ROOM for UFO
                do {
                    ufo_y = 32 + rng(  384 );
                } while( ( ufo_y >= shipy - 64 ) && ( ufo_y <= shipy + 64 ) );

                ufo_leftright = rng( 2 );
                set_ufo_sprite( 1 );
                set_sprite( ASN( ufo_sprite_number ), 1, PURPLE, ( ufo_leftright == 1 ) ? 639 : ( level < 2 ) ? -31 : -15, ufo_y, 0, ( level < 2 ) ? 1 : 0 );
                asteroid_active[ ufo_sprite_number ] = 3;
            }
        }

        if( ( rng( ( level > 3 ) ? 64 : 128 ) == 1 ) && ( get_sprite_attribute( 0, 10, 0 ) == 0 ) && ( ufo_sprite_number != 0xff ) && ( ( level != 0 ) || ( lives == 0 ) ) ) {
            // START UFO BULLET
            beep( 2, 4, 63, 32 );

            ufo_x = get_sprite_attribute( ASN( ufo_sprite_number ), 3 ) + ( ( level < 2 ) ? 16 : 8 );
            ufo_y = get_sprite_attribute( ASN( ufo_sprite_number ), 4 );
            if( ufo_y > shipy ) {
                ufo_y -= 10;
            } else {
                ufo_y += ( ( level < 2 ) ? 20 : 10 );
            }
            ufo_bullet_direction = ( ufo_x > shipx ) ? 6 : 2;

            switch( ufo_bullet_direction ) {
                case 2:
                    ufo_bullet_direction += ( ufo_y > shipy ) ? -1 : 1;
                    break;

                case 6:
                    ufo_bullet_direction += ( ufo_y > shipy ) ? 1 : -1;
                    break;

                default:
                    break;
            }
            set_sprite( 0, 10, 1, RED, ufo_x, ufo_y, 0, 0 );
            set_sprite( 1, 10, 1, YELLOW, ufo_x, ufo_y, 1, 0 );
        }

        if( ( lives > 0 ) && ( resetship == 0) ) {
            // GAME IN ACTION

            // EVERY 4th CYCLE
            if( ( counter & 3 ) == 0 ) {
                // TURN LEFT
                if( ( get_buttons() & 32 ) != 0 )
                    shipdirection = ( shipdirection == 0 ) ? 7 : shipdirection - 1;
                // TURN RIGHT
                if( ( get_buttons() & 64 ) != 0 )
                    shipdirection = ( shipdirection == 7 ) ? 0 : shipdirection + 1;
            }

            // EVERY CYCLE
            // FIRE?
            if( ( get_sprite_attribute( 0, 12, 0 ) == 0 ) && ( get_buttons() & 2 ) != 0 )
                fire_bullet();

            // MOVE SHIP, IF FUEL LEFT
            if( ( ( get_buttons() & 8 ) != 0 ) && ( fuel > 0 ) ) {
                move_ship();
                fuel--;
                drawfuel(0);
            }

            // CHECK IF CRASHED ASTEROID -> SHIP, IF SHIELD BUTTON NOT HELD DOWN
            if( ( ( get_buttons() & 4 ) != 0 ) && ( shield > 0 ) ) {
                draw_ship( BLUE );
                shield--;
                drawshield(0);
            } else {
                draw_ship( WHITE );
                check_crash();
            }
        } else {
            // GAME OVER OR EXPLODING SHIP
            // SEE IF NEW GAME
            if( ( lives == 0 ) && ( ( get_buttons() & 8 ) != 0 ) ) {
                // CLEAR ASTEROIDS
                for( asteroid_number = 0; asteroid_number < MAXASTEROIDS; asteroid_number++ ) {
                    asteroid_active[asteroid_number] = 0; asteroid_direction[asteroid_number] = 0;
                    set_sprite_attribute( ASN(asteroid_number), 0, 0 );
                }

                // CLEAR BULLETS
                set_sprite_attribute( 0, 10, 0, 0 );
                set_sprite_attribute( 1, 10, 0, 0 );
                set_sprite_attribute( 0, 12, 0, 0 );
                set_sprite_attribute( 1, 12, 0, 0 );

                // CLEAR SCREEN, RESET TILEMAP
                gpu_cs(); tpu_cs();
                set_tilemap();

                counter = 0;

                lives = 4; score = 0; level = 0;

                shield = 250; fuel = 1000;
                drawfuel(1); drawshield(1);

                shipx = 312; shipy = 232; shipdirection = 0; resetship = 16; bulletdirection = 0;
                placeAsteroids = 4;
                ufo_sprite_number = 0xff; ufo_leftright = 0;
                draw_lives();
                set_asteroid_sprites();
                set_ship_sprites(0);
                set_bullet_sprites();
                set_ufo_bullet_sprites();
            }

            if( ( ( resetship >= 1 ) && ( resetship <= 16 ) ) || ( lives == 0 ) ) {
                // DRAW GREY SHIP
                draw_ship( GREY1 );
                if( ( resetship >= 1 ) && ( resetship <= 16 ) ) {
                    if( ( ( get_sprite_collision( 0, 11 ) & 0x7ff ) == 0 ) && ( ( get_sprite_collision( 1, 11 ) & 0x7ff ) == 0 ) ) {
                        resetship--;
                        if( resetship == 0 ) {
                            gpu_cs();
                            lives--;
                            draw_lives();
                            fuel = 1000;
                            drawfuel(1); drawshield(1);
                        }

                        if( lives == 0 )
                            risc_ice_v_logo();
                    }
                }
            }

            if( resetship > 16 ) {
                // EXPLODING SHIP
                update_sprite( 0, 11, 0x400 );
                update_sprite( 1, 11, 0x400 );
                set_sprite_attribute( 0, 11, 2, ( counter & 1 ) ? RED : YELLOW );
                set_sprite_attribute( 1, 11, 2, ( counter & 1 ) ? YELLOW : RED );

                resetship--;
                if( resetship == 16 )
                    set_ship_sprites( 0 );
                    shipx = 312; shipy = 232; shipdirection = 0;
            }
        }

        // UPDATE BULLET
        update_bullet();

        // CHECK IF HIT BULLET -> ASTEROID
        check_hit();
        check_ufo_bullet_hit();

        wait_timer1khz( 0 );
    }
}
