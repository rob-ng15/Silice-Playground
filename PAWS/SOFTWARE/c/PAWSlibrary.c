#include "PAWS.h"
#include "PAWSdefinitions.h"
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

typedef unsigned int size_t;

// MASTER BOOT RECORD AND PARTITION TABLE
unsigned char *MBR;
Fat16BootSector *BOOTSECTOR;
PartitionTable *PARTITION;
Fat16Entry *ROOTDIRECTORY;
unsigned short *FAT;
unsigned char *CLUSTERBUFFER;
unsigned int CLUSTERSIZE;
unsigned int DATASTARTSECTOR;

// MEMORY
unsigned char *MEMORYTOP;

// RISC-V CSR FUNCTIONS
unsigned int CSRisa() {
   unsigned int isa;
   asm volatile ("csrr %0, 0x301" : "=r"(isa));
   return isa;
}

unsigned long CSRcycles() {
   unsigned long cycles;
   asm volatile ("rdcycle %0" : "=r"(cycles));
   return cycles;
}

unsigned long CSRinstructions() {
   unsigned long insns;
   asm volatile ("rdinstret %0" : "=r"(insns));
   return insns;
}

unsigned long CSRtime() {
  unsigned long time;
  asm volatile ("rdtime %0" : "=r"(time));
  return time;
}

// OUTPUT TO UART
// OUTPUT INDIVIDUAL CHARACTER TO THE UART
void outputcharacter(char c) {
	while( *UART_STATUS & 2 ) {}
    *UART_DATA = c;
    if( c == '\n' )
        outputcharacter('\r');
}
// INPUT FROM UART
// RETURN 1 IF UART CHARACTER AVAILABLE, OTHERWISE 0
unsigned char character_available( void ) {
    return( *UART_STATUS & 1 );
}
// RETURN CHARACTER FROM UART
char inputcharacter( void ) {
	while( !character_available() ) {}
    return *UART_DATA;
}

// INPUT FROM PS2
// RETURN IF A CHARACTER IS AVAILABLE
char ps2_character_available( void ) {
    return *PS2_AVAILABLE;
}
// RETURN A DECODED ASCII CHARACTER
// 0x0xx is an ascii character from the keyboard
// 0x1xx is an escaped character from the keyboard
// F1 to F12 map to 0x101 to 0x10c, SHIFT F1 to F12 map to 0x111 to 0x11c
// CURSOR KEYS UP = 0x141, RIGHT = 0x143, DOWN = 0x142, LEFT = 0x144
// INSERT = 0x132 HOME = 0x131 PGUP = 0x135 DELETE = 0x133 END = 0x134 PGDN = 0x136
unsigned short ps2_inputcharacter( void ) {
    while( !*PS2_AVAILABLE ) {}
    return *PS2_DATA;
}
// SET KEYBOARD MODE TO == 0 JOYSTICK == 1 KEYBOARD
void ps2_keyboardmode( unsigned char mode ) {
    *PS2_MODE = mode;
}

// TIMER AND PSEUDO RANDOM NUMBER GENERATOR

// PSEUDO RANDOM NUMBER GENERATOR
// RETURN PSEUDO RANDOM NUMBER 0 <= RNG < RANGE ( effectively 0 to range - 1 )
unsigned short rng( unsigned short range ) {
    unsigned short trial, mask;

    switch( range ) {
        case 0:
            trial = 0;
            break;

        case 1:
        case 2:
            trial = *ALT_RNG & 1;
            break;
        case 4:
            trial = *ALT_RNG & 3;
            break;
        case 8:
            trial = *ALT_RNG & 7;
            break;
        case 16:
            trial = *ALT_RNG & 15;
            break;
        case 32:
            trial = *ALT_RNG & 31;
            break;
        case 64:
            trial = *ALT_RNG & 63;
            break;

        default:
            if( range < 256 ) { mask = 255; }
            else if( range < 512 ) { mask = 511; }
            else if( range < 1024 ) { mask = 1023; }
            else { mask = 65535; }
            do {
                trial = *RNG & mask;
            } while ( trial >= range );
    }

    return( trial );
}

// SLEEP FOR counter milliseconds
void sleep( unsigned short counter, unsigned char timer ) {
    switch( timer ) {
        case 0:
            *SLEEPTIMER0 = counter;
            while( *SLEEPTIMER0 );
            break;
        case 1:
            *SLEEPTIMER1 = counter;
            while( *SLEEPTIMER1 );
            break;
    }
}

// SET THE 1khz COUNTDOWN TIMER
void set_timer1khz( unsigned short counter, unsigned char timer ) {
    switch( timer ) {
        case 0:
            *TIMER1KHZ0 = counter;
            break;
        case 1:
            *TIMER1KHZ1 = counter;
            break;
    }
}

// READ THE 1khz COUNTDOWN TIMER
unsigned short get_timer1khz( unsigned char timer  ) {
    return( timer ? *TIMER1KHZ1 : *TIMER1KHZ0 );
}

// WAIT FOR THE 1khz COUNTDOWN TIMER
void wait_timer1khz( unsigned char timer  ) {
    while( timer ? *TIMER1KHZ1 : *TIMER1KHZ0 );
}

// READ THE 1hz TIMER
unsigned short get_timer1hz( unsigned char timer  ) {
    return( timer ? *TIMER1HZ1 : *TIMER1HZ0 );
}

// RESET THE 1hz TIMER
void reset_timer1hz( unsigned char timer  ) {
    switch( timer ) {
        case 0:
            *TIMER1HZ0 = 1;
            break;
        case 1:
            *TIMER1HZ1 = 1;
            break;
    }
}

// RETURN SYSTEM CLOCK - 1 second pulses from startup
unsigned short systemclock( void ) {
    return( *SYSTEMCLOCK );
}

// AUDIO OUTPUT
// START A note (1 == DEEP C, 25 == MIDDLE C )
// OF duration MILLISECONDS TO THE LEFT ( channel_number == 1 ) RIGHT ( channel_number == 2 ) or BOTH ( channel_number == 3 ) AUDIO CHANNEL
// IN waveform 0 == SQUARE, 1 == SAWTOOTH, 2 == TRIANGLE, 3 == SINE, 4 == WHITE NOISE
void beep( unsigned char channel_number, unsigned char waveform, unsigned char note, unsigned short duration ) {
    *AUDIO_WAVEFORM = waveform;
    *AUDIO_NOTE = note;
    *AUDIO_DURATION = duration;
    *AUDIO_START = channel_number;
}

void await_beep( unsigned char channel_number ) {
    while( ( ( channel_number & 1) && *AUDIO_L_ACTIVE ) | ( ( channel_number & 2) && *AUDIO_R_ACTIVE ) ) {}
}

unsigned short get_beep_active( unsigned char channel_number ) {
    return( ( ( channel_number & 1) && *AUDIO_L_ACTIVE ) | ( ( channel_number & 2) && *AUDIO_R_ACTIVE ) );
}

// SDCARD FUNCTIONS
// INTERNAL FUNCTION - WAIT FOR THE SDCARD TO BE READY
void sdcard_wait( void ) {
    while( *SDCARD_READY == 0 ) {}
}

// READ A SECTOR FROM THE SDCARD AND COPY TO MEMORY
void sdcard_readsector( unsigned int sectorAddress, unsigned char *copyAddress ) {
    unsigned short i;

    sdcard_wait();
    *SDCARD_SECTOR_HIGH = ( sectorAddress & 0xffff0000 ) >> 16;
    *SDCARD_SECTOR_LOW = ( sectorAddress & 0x0000ffff );
    *SDCARD_START = 1;
    sdcard_wait();

    for( i = 0; i < 512; i++ ) {
        *SDCARD_ADDRESS = i;
        copyAddress[ i ] = *SDCARD_DATA;
    }
}

// I/O FUNCTIONS
// SET THE LEDS
void set_leds( unsigned char value ) {
    *LEDS = value;
}

// READ THE ULX3S JOYSTICK BUTTONS OR KEYBOARD AS JOYSTICK
unsigned short get_buttons( void ) {
    return( *BUTTONS );
}

// DISPLAY FUNCTIONS
// FUNCTIONS ARE IN LAYER ORDER: BACKGROUND, TILEMAP, SPRITES (for LOWER ), BITMAP & GPU, ( UPPER SPRITES ), CHARACTERMAP & TPU
// colour is in the form { Arrggbb } { ALPHA - show layer below, RED, GREEN, BLUE } or { rrggbb } { RED, GREEN, BLUE } giving 64 colours + transparent
// INTERNAL FUNCTION - WAIT FOR THE GPU TO FINISH THE LAST COMMAND
void wait_gpu( void ) {
    while( *GPU_STATUS );
}

// WAIT FOR VBLANK TO START
void await_vblank( void ) {
    while( !*VBLANK );
}

// SET THE LAYER ORDER FOR THE DISPLAY
void screen_mode( unsigned char screenmode ) {
    *SCREENMODE = screenmode;
}

// SET THE FRAMEBUFFER TO DISPLAY / DRAW
void bitmap_display( unsigned char framebuffer ) {
    await_vblank();
    *FRAMEBUFFER_DISPLAY = framebuffer;
}

void bitmap_draw( unsigned char framebuffer ) {
    while( !*GPU_FINISHED );
    *FRAMEBUFFER_DRAW = framebuffer;
}

// BACKGROUND GENERATOR
// backgroundmode ==
//  0 SOLID in colour
//  1, 2, 3, 4 checkerboard in colour/altcolour in increasing sizes of squares
//  5 rainbow
//  6 static
//  7 @sylefeb's snow/starfield with colour stars and altcolour background
//  8 split vertical
//  9 split horizontal
//  10 quarters
void set_background( unsigned char colour, unsigned char altcolour, unsigned char backgroundmode ) {
    *BACKGROUND_COPPER_STARTSTOP = 0;
    *BACKGROUND_COLOUR = colour;
    *BACKGROUND_ALTCOLOUR = altcolour;
    *BACKGROUND_MODE = backgroundmode;
}

// BACKGROUND COPPER
void copper_startstop( unsigned char status ) {
    await_vblank();
    *BACKGROUND_COPPER_STARTSTOP = status;
}

struct copper_command {
    unsigned int command:3;
    unsigned int condition:3;
    unsigned int coordinate:11;
    unsigned int mode:4;
    unsigned int altcolour:6;
    unsigned int colour:6;
};

void copper_program( unsigned char address, unsigned char command, unsigned char condition, unsigned short coordinate, unsigned char mode, unsigned char altcolour, unsigned char colour ) {
    *BACKGROUND_COPPER_ADDRESS = address;
    *BACKGROUND_COPPER_COMMAND = command;
    *BACKGROUND_COPPER_CONDITION = condition;
    *BACKGROUND_COPPER_COORDINATE = coordinate;
    *BACKGROUND_COPPER_MODE = mode;
    *BACKGROUND_COPPER_ALT = altcolour;
    *BACKGROUND_COPPER_COLOUR = colour;
    *BACKGROUND_COPPER_PROGRAM = 1;
}

void set_copper_cpuinput( unsigned short value ) {
    *BACKGROUND_COPPER_CPUINPUT = value;
}

// SCROLLABLE TILEMAP
// The tilemap is 42 x 32, with 40 x 30 displayed, with an x and y offset in the range -15 to 15 to scroll the tilemap
// The tilemap can scroll or wrap once x or y is at -15 or 15

// SET THE TILEMAP TILE at (x,y) to tile with colours background and foreground
void set_tilemap_tile( unsigned char tm_layer, unsigned char x, unsigned char y, unsigned char tile, unsigned char background, unsigned char foreground, unsigned char reflection) {
    switch( tm_layer ) {
        case 0:
            while( *LOWER_TM_STATUS );
            *LOWER_TM_X = x;
            *LOWER_TM_Y = y;
            *LOWER_TM_TILE = tile;
            *LOWER_TM_BACKGROUND = background;
            *LOWER_TM_FOREGROUND = foreground;
            *LOWER_TM_REFLECTION = reflection;
            *LOWER_TM_COMMIT = 1;
            break;
        case 1:
            while( *UPPER_TM_STATUS );
            *UPPER_TM_X = x;
            *UPPER_TM_Y = y;
            *UPPER_TM_TILE = tile;
            *UPPER_TM_BACKGROUND = background;
            *UPPER_TM_FOREGROUND = foreground;
            *UPPER_TM_REFLECTION = reflection;
            *UPPER_TM_COMMIT = 1;
            break;
    }
}

// SET THE TILE BITMAP for tile to the 16 x 16 pixel bitmap
void set_tilemap_bitmap( unsigned char tm_layer, unsigned char tile, unsigned short *bitmap ) {
    switch( tm_layer ) {
        case 0:
            *LOWER_TM_WRITER_TILE_NUMBER = tile;
            for( int i = 0; i < 16; i ++ ) {
                *LOWER_TM_WRITER_LINE_NUMBER = i;
                *LOWER_TM_WRITER_BITMAP = bitmap[i];
            }
            break;
        case 1:
            *UPPER_TM_WRITER_TILE_NUMBER = tile;
            for( int i = 0; i < 16; i ++ ) {
                *UPPER_TM_WRITER_LINE_NUMBER = i;
                *UPPER_TM_WRITER_BITMAP = bitmap[i];
            }
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

// GPU AND BITMAP
// The bitmap is 640 x 480 pixels (0,0) is ALWAYS top left even if the bitmap has been offset
// The bitmap can be moved 1 pixel at a time LEFT, RIGHT, UP, DOWN for scrolling
// The GPU can draw pixels, filled rectangles, lines, (filled) circles, filled triangles and has a 16 x 16 pixel blitter from user definable tiles

// SCROLL THE BITMAP by 1 pixel
//  action == 1 LEFT, == 2 UP, == 3 RIGHT, == 4 DOWN, == 5 RESET
void bitmap_scrollwrap( unsigned char action ) {
    wait_gpu();
    *BITMAP_SCROLLWRAP = action;
}

// SET GPU DITHER MODE AND ALTERNATIVE COLOUR
void gpu_dither( unsigned char mode, unsigned char colour ) {
    *GPU_COLOUR_ALT = colour;
    *GPU_DITHERMODE = mode;
}

// SET GPU CROPPING RECTANGLE
void gpu_crop( unsigned short left, unsigned short top, unsigned short right, unsigned short bottom ) {
    wait_gpu();
    *CROP_LEFT = left;
    *CROP_RIGHT = right;
    *CROP_TOP = top;
    *CROP_BOTTOM = bottom;
}

// SET THE PIXEL at (x,y) to colour
void gpu_pixel( unsigned char colour, short x, short y ) {
    *GPU_COLOUR = colour;
    *GPU_X = x;
    *GPU_Y = y;
    wait_gpu();
    *GPU_WRITE = 1;
}

// DRAW A LINE FROM (x1,y1) to (x2,y2) in colour - uses Bresenham's Line Drawing Algorithm - single pixel width
void gpu_line( unsigned char colour, short x1, short y1, short x2, short y2 ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;
    *GPU_PARAM2 = 1;
    wait_gpu();
    *GPU_WRITE = 2;
}

// DRAW A LINE FROM (x1,y1) to (x2,y2) in colour - uses Bresenham's Line Drawing Algorithm - pixel width
void gpu_wideline( unsigned char colour, short x1, short y1, short x2, short y2, unsigned short width ) {
    if( width != 0 ) {
        *GPU_COLOUR = colour;
        *GPU_X = x1;
        *GPU_Y = y1;
        *GPU_PARAM0 = x2;
        *GPU_PARAM1 = y2;
        *GPU_PARAM2 = width;
        wait_gpu();
        *GPU_WRITE = 2;
    }
}

// DRAW AN OUTLINE RECTANGLE from (x1,y1) to (x2,y2) in colour
void gpu_box( unsigned char colour, short x1, short y1, short x2, short y2, unsigned short width ) {
    gpu_wideline( colour, x1, y1, x2, y1, width );
    gpu_wideline( colour, x2, y1, x2, y2, width );
    gpu_wideline( colour, x2, y2, x1, y2, width );
    gpu_wideline( colour, x1, y2, x1, y1, width );
}

// DRAW AN OUTLINE BOX from (x1,y1) to (x2,y2) in colour
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
    bitmap_scrollwrap( 5 ); gpu_dither( 0, 64 ); gpu_rectangle( 64, 0, 0, 319, 239 );
}


// DRAW A (optional filled) CIRCLE at centre (x1,y1) of radius
void gpu_circle( unsigned char colour, short x1, short y1, short radius, unsigned char drawsectors, unsigned char filled ) {
    if( radius != 0 ) {
        *GPU_COLOUR = colour;
        *GPU_X = x1;
        *GPU_Y = y1;
        *GPU_PARAM0 = radius;
        *GPU_PARAM1 = drawsectors;
        wait_gpu();
        *GPU_WRITE = filled ? 5 : 4;
    }
}

// BLIT A 16 x 16 ( blit_size == 1 doubled to 32 x 32 ) TILE ( from tile 0 to 31 ) to (x1,y1) in colour
// REFLECT { y, x }
void gpu_blit( unsigned char colour, short x1, short y1, short tile, unsigned char blit_size, unsigned char action ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = tile;
    *GPU_PARAM1 = blit_size;
    *GPU_PARAM2 = action;
    wait_gpu();
    *GPU_WRITE = 7;
}

// BLIT AN 8 x8  ( blit_size == 1 doubled to 16 x 16, blit_size == 1 doubled to 32 x 32 ) CHARACTER ( from tile 0 to 255 ) to (x1,y1) in colour
// REFLECT { y, x }
void gpu_character_blit( unsigned char colour, short x1, short y1, unsigned char tile, unsigned char blit_size, unsigned char action ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = tile;
    *GPU_PARAM1 = blit_size;
    *GPU_PARAM2 = action;
    wait_gpu();
    *GPU_WRITE = 8;
}

// COLOURBLIT A 16 x 16 ( blit_size == 1 doubled to 32 x 32 ) TILE ( from tile 0 to 31 ) to (x1,y1)
// { rotate/reflect, ACTION } ROTATION == 4 0 == 5 90 == 6 180 == 7 270
// == 1 REFLECT X, == 2 REFLECT Y
void gpu_colourblit( short x1, short y1, short tile, unsigned char blit_size, unsigned char action ) {
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = tile;
    *GPU_PARAM1 = blit_size;
    *GPU_PARAM2 = action;
    wait_gpu();
    *GPU_WRITE = 9;
}

// SET THE BLITTER TILE to the 16 x 16 pixel bitmap
void set_blitter_bitmap( unsigned char tile, unsigned short *bitmap ) {
    *BLIT_WRITER_TILE = tile;

    for( int i = 0; i < 16; i ++ ) {
        *BLIT_WRITER_LINE = i;
        *BLIT_WRITER_BITMAP = bitmap[i];
    }
}

// SET THE BLITTER CHARACTER TILE to the 8 x 8 pixel bitmap
void set_blitter_chbitmap( unsigned char tile, unsigned char *bitmap ) {
    *BLIT_CHWRITER_TILE = tile;

    for( int i = 0; i < 8; i ++ ) {
        *BLIT_CHWRITER_LINE = i;
        *BLIT_CHWRITER_BITMAP = bitmap[i];
    }
}

// SET THE COLOURBLITTER TILE to the 16 x 16 pixel bitmap
void set_colourblitter_bitmap( unsigned char tile, unsigned char *bitmap ) {
    *COLOURBLIT_WRITER_TILE = tile;

    for( int i = 0; i < 16; i ++ ) {
        *COLOURBLIT_WRITER_LINE = i;
        for( int j = 0; j < 16; j ++ ) {
            *COLOURBLIT_WRITER_PIXEL = j;
            *COLOURBLIT_WRITER_COLOUR = bitmap[ i * 16 + j ];
        }
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

// DRAW A FILLED QUADRILATERAL with vertices (x1,y1) (x2,y2) (x3,y3) (x4,y4) in colour BY DRAWING TWO FILLED TRIANGLES
// VERTICES SHOULD BE PRESENTED CLOCKWISE FROM THE TOP ( minimal adjustments made to the vertices to comply )
void gpu_quadrilateral( unsigned char colour, short x1, short y1, short x2, short y2, short x3, short y3, short x4, short y4 ) {
     *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;
    *GPU_PARAM2 = x3;
    *GPU_PARAM3 = y3;
    *GPU_PARAM4 = x4;
    *GPU_PARAM5 = y4;
    wait_gpu();
    *GPU_WRITE = 11;
}

// OUTPUT A STRING TO THE GPU
void gpu_printf( unsigned char colour, short x, short y, unsigned char size, unsigned char action, const char *fmt,... ) {
    char *buffer = (char *)0x1000;
    va_list args;
    va_start (args, fmt);
    vsnprintf( buffer, 80, fmt, args);
    va_end(args);

    char *s = buffer;
    while( *s ) {
        gpu_character_blit( colour, x, y, *s++, size, action );
        x = x + ( 8 << size );
    }
}
void gpu_printf_vertical( unsigned char colour, short x, short y, unsigned char size, unsigned char action, const char *fmt,... ) {
    char *buffer = (char *)0x1000;
    va_list args;
    va_start (args, fmt);
    vsnprintf( buffer, 80, fmt, args);
    va_end(args);

    char *s = buffer;
    while( *s ) {
        gpu_character_blit( colour, x, y, *s++, size, action );
        y = y - ( 8 << size );
    }
}

// OUTPUT A STRING TO THE GPU - CENTRED AT ( x, y )
void gpu_printf_centre( unsigned char colour, short x, short y, unsigned char size, unsigned char action, const char *fmt,... ) {
    char *buffer = (char *)0x1000;
    va_list args;
    va_start (args, fmt);
    vsnprintf( buffer, 80, fmt, args);
    va_end(args);

    char *s = buffer;
    x = x - ( ( strlen( s ) * ( 8 << size ) ) /2 );
    while( *s ) {
        gpu_character_blit( colour, x, y, *s++, size, action );
        x = x + ( 8 << size );
    }
}void gpu_printf_centre_vertical( unsigned char colour, short x, short y, unsigned char size, unsigned char action, const char *fmt,... ) {
    char *buffer = (char *)0x1000;
    va_list args;
    va_start (args, fmt);
    vsnprintf( buffer, 80, fmt, args);
    va_end(args);

    char *s = buffer;
    y = y + ( ( strlen( s ) * ( 8 << size ) ) /2 );
    while( *s ) {
        gpu_character_blit( colour, x, y, *s++, size, action );
        y = y - ( 8 << size );
    }
}

// COPY A ARRGGBB BITMAP STORED IN MEMORY TO THE BITMAP USING THE PIXEL BLOCK
void gpu_pixelblock7( short x,  short y, unsigned short w, unsigned short h, unsigned char transparent, unsigned char *buffer ) {
    unsigned char *maxbufferpos = buffer + ( w * h );

    *GPU_X = x;
    *GPU_Y = y;
    *GPU_PARAM0 = w;
    *GPU_PARAM1 = transparent;
    wait_gpu();
    *GPU_WRITE = 10;

    while( buffer < maxbufferpos ) {
        *PB_COLOUR7 = *buffer++;
    }
    *PB_STOP = 3;
}

// COPY A { RRRRRRRR GGGGGGGG BBBBBBBB } BITMAP STORED IN MEMORY TO THE BITMAP USING THE PIXEL BLOCK
void gpu_pixelblock24( short x, short y, unsigned short w, unsigned short h, unsigned char *buffer  ) {
    unsigned char *maxbufferpos = buffer + 3 * ( w * h );

    *GPU_X = x;
    *GPU_Y = y;
    *GPU_PARAM0 = w;
    wait_gpu();
    *GPU_WRITE = 10;

    while( buffer < maxbufferpos ) {
        *PB_COLOUR8R = *buffer++;
        *PB_COLOUR8G= *buffer++;
        *PB_COLOUR8B = *buffer++;
    }
    *PB_STOP = 3;
}

// SET GPU TO RECEIVE A PIXEL BLOCK, SEND INDIVIDUAL PIXELS, STOP
void gpu_pixelblock_start( short x,  short y, unsigned short w, unsigned short h ) {
    *GPU_X = x;
    *GPU_Y = y;
    *GPU_PARAM0 = w;
    *GPU_PARAM1 = TRANSPARENT;
    wait_gpu();
    *GPU_WRITE = 10;
}

void gpu_pixelblock_pixel7( unsigned char pixel ) {
    *PB_COLOUR7 = pixel;
}

void gpu_pixelblock_pixel24( unsigned char red, unsigned char green, unsigned char blue ) {
    *PB_COLOUR8R = red;
    *PB_COLOUR8G= green;
    *PB_COLOUR8B = blue;
}

void gpu_pixelblock_stop( void ) {
    *PB_STOP = 3;
}

// GPU VECTOR BLOCK
// 32 VECTOR BLOCKS EACH OF 16 VERTICES ( offsets in the range -15 to 15 from the centre )
// WHEN ACTIVATED draws lines from a vector block (x0,y0) to (x1,y1), (x1,y1) to (x2,y2), (x2,y2) to (x3,y3) until (x15,y15) or an inactive vertex is encountered

// START DRAWING A VECTOR BLOCK centred at (xc,yc) in colour
// { rotate/reflect, ACTION } ROTATION == 4 0 == 5 90 == 6 180 == 7 270
// == 1 REFLECT X, == 2 REFLECT Y
void draw_vector_block( unsigned char block, unsigned char colour, short xc, short yc, unsigned char scale, unsigned char action ) {
    while( *VECTOR_DRAW_STATUS );
    *VECTOR_DRAW_BLOCK = block;
    *VECTOR_DRAW_COLOUR = colour;
    *VECTOR_DRAW_XC = xc;
    *VECTOR_DRAW_YC = yc;
    *VECTOR_DRAW_SCALE = scale;
    *VECTOR_DRAW_ACTION = action;
    *VECTOR_DRAW_START = 1;
}

// SET A VERTEX IN A VECTOR BLOCK - SET AN INACTIVE VERTEX IF NOT ALL 16 VERTICES ARE TO BE USED
void set_vector_vertex( unsigned char block, unsigned char vertex, unsigned char active, char deltax, char deltay ) {
    *VECTOR_WRITER_BLOCK = block;
    *VECTOR_WRITER_VERTEX = vertex;
    *VECTOR_WRITER_ACTIVE = active;
    *VECTOR_WRITER_DELTAX = deltax;
    *VECTOR_WRITER_DELTAY = deltay;
}

// SOFTWARE VECTORS AND DRAWLISTS

// SCALE A POINT AND MOVE TO CENTRE POINT
struct Point2D Scale2D( struct Point2D point, short xc, short yc, float scale ) {
    struct Point2D newpoint;
    newpoint.dx = point.dx * scale + xc;
    newpoint.dy = point.dy * scale + yc;
    return( newpoint );
}
struct Point2D Rotate2D( struct Point2D point, short xc, short yc, short angle, float scale ) {
    struct Point2D newpoint;
    float radians = angle*0.01745329252;

    newpoint.dx = ( (point.dx * scale)*cosf(radians)-(point.dy * scale)*sinf(radians) ) + xc;
    newpoint.dy = ( (point.dx * scale)*sinf(radians)+(point.dy * scale)*cosf(radians) ) + yc;

    return( newpoint );
}

struct Point2D MakePoint2D( short x, short y ) {
    struct Point2D newpoint;
    newpoint.dx = x; newpoint.dy = y;
    return( newpoint );
}

// PROCESS A SOFTWARE VECTOR BLOCK AFTER SCALING AND ROTATION
void DrawVectorShape2D( unsigned char colour, struct Point2D *points, short numpoints, short xc, short yc, short angle, float scale ) {
    struct Point2D *NewShape  = (struct Point2D *)0x1400;
    for( short vertex = 0; vertex < numpoints; vertex++ ) {
        NewShape[ vertex ] = Rotate2D( points[vertex], xc, yc, angle, scale );
    }
    for( short vertex = 0; vertex < numpoints; vertex++ ) {
        gpu_line( colour, NewShape[ vertex ].dx, NewShape[ vertex ].dy, NewShape[ ( vertex == ( numpoints - 1 ) ) ? 0 : vertex + 1 ].dx, NewShape[ vertex == ( numpoints - 1 ) ? 0 : vertex + 1 ].dy );
    }
}

// PROCESS A DRAWLIST DRAWING SHAPES AFTER SCALING, ROTATING AND MOVING TO CENTRE POINT
void DoDrawList2D( struct DrawList2D *list, short numentries, short xc, short yc, short angle, float scale ) {
    struct Point2D XY1, XY2, XY3, XY4;
    for( int i = 0; i < numentries; i++ ) {
        gpu_dither( list[i].dithermode, list[i].alt_colour );
        switch( list[i].shape ) {
            case DLLINE:
                XY1 = Rotate2D( list[i].xy1, xc, yc, angle, scale );
                XY2 = Rotate2D( list[i].xy2, xc, yc, angle, scale );
                gpu_wideline( list[i].colour, XY1.dx, XY1.dy, XY2.dx, XY2.dy, list[i].xy3.dx * scale );
                break;
            case DLRECT:
                XY1 = Rotate2D( list[i].xy1, xc, yc, angle, scale );
                XY2 = Rotate2D( list[i].xy2, xc, yc, angle, scale );
                gpu_rectangle( list[i].colour, XY1.dx, XY1.dy, XY2.dx, XY2.dy );
                break;
            case DLCIRC:
                // NO SECTOR MASK, FULL CIRCLE ONLY
                XY1 = Rotate2D( list[i].xy1, xc, yc, angle, scale );
                gpu_circle( list[i].colour, XY1.dx, XY1.dy, list[i].xy2.dx * scale, 0xff, 1 );
                break;
            case DLARC:
                // NO SECTOR MASK, CIRCLE OUTLINE ONLY
                XY1 = Rotate2D( list[i].xy1, xc, yc, angle, scale );
                gpu_circle( list[i].colour, XY1.dx, XY1.dy, list[i].xy2.dx * scale, 0xff, 0 );
                break;
            case DLTRI:
                XY1 = Rotate2D( list[i].xy1, xc, yc, angle, scale );
                XY2 = Rotate2D( list[i].xy2, xc, yc, angle, scale );
                XY3 = Rotate2D( list[i].xy3, xc, yc, angle, scale );
                gpu_triangle( list[i].colour, XY1.dx, XY1.dy, XY2.dx, XY2.dy, XY3.dx, XY3.dy );
                break;
            case DLQUAD:
                XY1 = Rotate2D( list[i].xy1, xc, yc, angle, scale );
                XY2 = Rotate2D( list[i].xy2, xc, yc, angle, scale );
                XY3 = Rotate2D( list[i].xy3, xc, yc, angle, scale );
                XY4 = Rotate2D( list[i].xy3, xc, yc, angle, scale );
                gpu_quadrilateral( list[i].colour, XY1.dx, XY1.dy, XY2.dx, XY2.dy, XY3.dx, XY3.dy, XY4.dx, XY4.dy );
                break;
        }
    }
}

// PROCESS A DRAWLIST DRAWING SHAPES AFTER SCALING AND MOVING TO CENTRE POINT
void DoDrawList2Dscale( struct DrawList2D *list, short numentries, short xc, short yc, float scale ) {
    struct Point2D XY1, XY2, XY3, XY4;
    for( int i = 0; i < numentries; i++ ) {
        gpu_dither( list[i].dithermode, list[i].alt_colour );
        switch( list[i].shape ) {
            case DLLINE:
                XY1 = Scale2D( list[i].xy1, xc, yc, scale );
                XY2 = Scale2D( list[i].xy2, xc, yc, scale );
                gpu_wideline( list[i].colour, XY1.dx, XY1.dy, XY2.dx, XY2.dy, list[i].xy3.dx * scale );
                break;
            case DLRECT:
                // CONVERT TO QUADRILATERAL
                XY1 = Scale2D( list[i].xy1, xc, yc, scale );
                XY2 = Scale2D( MakePoint2D( list[i].xy2.dx, list[i].xy1.dy ), xc, yc, scale );
                XY3 = Scale2D( list[i].xy2, xc, yc, scale );
                XY4 = Scale2D( MakePoint2D( list[i].xy1.dx, list[i].xy2.dy ), xc, yc, scale );
                gpu_quadrilateral( list[i].colour, XY1.dx, XY1.dy, XY2.dx, XY2.dy, XY3.dx, XY3.dy, XY4.dx, XY4.dy );
                break;
            case DLCIRC:
                XY1 = Scale2D( list[i].xy1, xc, yc, scale );
                gpu_circle( list[i].colour, XY1.dx, XY1.dy, list[i].xy2.dx * scale, list[i].xy2.dy, 1 );
                break;
            case DLARC:
                XY1 = Scale2D( list[i].xy1, xc, yc, scale );
                gpu_circle( list[i].colour, XY1.dx, XY1.dy, list[i].xy2.dx * scale, list[i].xy2.dy, 0 );
                break;
            case DLTRI:
                XY1 = Scale2D( list[i].xy1, xc, yc, scale );
                XY2 = Scale2D( list[i].xy2, xc, yc, scale );
                XY3 = Scale2D( list[i].xy3, xc, yc, scale );
                gpu_triangle( list[i].colour, XY1.dx, XY1.dy, XY2.dx, XY2.dy, XY3.dx, XY3.dy );
                break;
            case DLQUAD:
                XY1 = Scale2D( list[i].xy1, xc, yc, scale );
                XY2 = Scale2D( list[i].xy2, xc, yc, scale );
                XY3 = Scale2D( list[i].xy3, xc, yc, scale );
                XY4 = Scale2D( list[i].xy4, xc, yc, scale );
                gpu_quadrilateral( list[i].colour, XY1.dx, XY1.dy, XY2.dx, XY2.dy, XY3.dx, XY3.dy, XY4.dx, XY4.dy );
                break;
        }
    }
}

// SPRITE LAYERS - MAIN ACCESS
// TWO SPRITE LAYERS ( 0 == lower above background and tilemap, below bitmap, 1 == upper above bitmap, below character map )
// WITH 13 SPRITES ( 0 to 12 ) each with 8 16 x 16 pixel bitmaps

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

short get_sprite_attribute( unsigned char sprite_layer, unsigned char sprite_number, unsigned char attribute ) {
    if( sprite_layer == 0 ) {
        switch( attribute ) {
            case 0:
                return( (short)LOWER_SPRITE_ACTIVE[sprite_number] );
            case 1:
                return( (short)LOWER_SPRITE_TILE[sprite_number] );
            case 2:
                return( (short)LOWER_SPRITE_COLOUR[sprite_number] );
            case 3:
                return( LOWER_SPRITE_X[sprite_number] );
            case 4:
                return( LOWER_SPRITE_Y[sprite_number] );
            case 5:
                return( (short)LOWER_SPRITE_DOUBLE[sprite_number] );
            default:
                return( 0 );
        }
    } else {
        switch( attribute ) {
            case 0:
                return( (short)UPPER_SPRITE_ACTIVE[sprite_number] );
            case 1:
                return( (short)UPPER_SPRITE_TILE[sprite_number] );
            case 2:
                return( (short)UPPER_SPRITE_COLOUR[sprite_number] );
            case 3:
                return( UPPER_SPRITE_X[sprite_number] );
            case 4:
                return( UPPER_SPRITE_Y[sprite_number] );
            case 5:
                return( (short)UPPER_SPRITE_DOUBLE[sprite_number] );
            default:
                return( 0 );
        }
    }
}

// RETURN THE COLLISION STATUS for sprite_number in sprite_layer to other in layer sprites
//  bit is 1 if sprite is in collision with { in layer sprite 15, in layer sprite 14 .. in layer sprite 0 }
unsigned short get_sprite_collision( unsigned char sprite_layer, unsigned char sprite_number ) {
    return( ( sprite_layer == 0 ) ? LOWER_SPRITE_COLLISION_BASE[sprite_number] : UPPER_SPRITE_COLLISION_BASE[sprite_number] );
}
// RETURN THE COLLISION STATUS for sprite number in sprite layer to other layers
// bit is 1 if sprite is in collision with { bitmap, tilemap L, tilemap U, other sprite layer }
unsigned short get_sprite_layer_collision( unsigned char sprite_layer, unsigned char sprite_number ) {
    return( ( sprite_layer == 0 ) ? LOWER_SPRITE_LAYER_COLLISION_BASE[sprite_number] : UPPER_SPRITE_LAYER_COLLISION_BASE[sprite_number] );
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

// CHARACTER MAP FUNCTIONS
// The character map is an 80 x 30 character window with a 256 character 8 x 16 pixel character generator ROM )
// NO SCROLLING, CURSOR WRAPS TO THE TOP OF THE SCREEN

// CLEAR THE CHARACTER MAP
void tpu_cs( void ) {
    while( *TPU_COMMIT );
    *TPU_COMMIT = 3;
}

// CLEAR A LINE
void tpu_clearline( unsigned char y ) {
    while( *TPU_COMMIT );
    *TPU_Y = y;
    *TPU_COMMIT = 4;
}

// POSITION THE CURSOR to (x,y) and set background and foreground colours
void tpu_set(  unsigned char x, unsigned char y, unsigned char background, unsigned char foreground ) {
    while( *TPU_COMMIT );
    *TPU_X = x; *TPU_Y = y; *TPU_BACKGROUND = background; *TPU_FOREGROUND = foreground; *TPU_COMMIT = 1;
}

// OUTPUT CHARACTER, STRING, and PRINTF EQUIVALENT FOR THE TPU
void tpu_output_character( short c ) {
    while( *TPU_COMMIT );
    *TPU_CHARACTER = c; *TPU_COMMIT = 2;
}
void tpu_outputstring( char attribute, char *s ) {
    while( *s ) {
        while( *TPU_COMMIT );
        *TPU_CHARACTER = ( attribute ? 256 : 0 ) + *s; *TPU_COMMIT = 2;
        s++;
    }
}
void tpu_printf( char attribute, const char *fmt,... ) {
    char *buffer = (char *)0x1000;
    va_list args;
    va_start (args, fmt);
    vsnprintf( buffer, 1023, fmt, args);
    va_end(args);

    tpu_outputstring( attribute, buffer );
}
void tpu_printf_centre( unsigned char y, unsigned char background, unsigned char foreground,  char attribute, const char *fmt,...  ) {
    char *buffer = (char *)0x1000;
    va_list args;
    va_start (args, fmt);
    vsnprintf( buffer, 80, fmt, args);
    va_end(args);

    tpu_clearline( y );
    tpu_set( 40 - ( strlen(buffer) >> 1 ), y, background, foreground );
    tpu_outputstring( attribute, buffer );
}

// SIMPLE FILE SYSTEM
// FILES ARE REFERENCED BY FILENUMBER, 0xffff INDICATES FILE NOT FOUND
// FILE SIZE CAN BE RETRIEVE
// FILE CAN BE LOADED INTO MEMORY
unsigned short sdcard_findfilenumber( unsigned char *filename, unsigned char *ext ) {
    unsigned short filenumber = 0xffff;
    unsigned short filenamematch;

    for( unsigned short i = 0; ( i < BOOTSECTOR -> root_dir_entries ) && ( filenumber == 0xffff ); i++ ) {
        switch( ROOTDIRECTORY[i].filename[0] ) {
            // NOT TRUE FILES ( deleted, directory pointer )
            case 0x00:
            case 0xe5:
            case 0x05:
            case 0x2e:
                break;

            default:
                filenamematch = 1;
                for( unsigned short c = 0; ( c < 8 ) || ( filename[c] == 0 ); c++ ) {
                    if( ( filename[c] != ROOTDIRECTORY[i].filename[c] ) && ( ROOTDIRECTORY[i].filename[c] != ' ' ) ) {
                        filenamematch = 0;
                    }
                }
                for( unsigned short c = 0; ( c < 3 ) || ( ext[c] == 0 ); c++ ) {
                    if( ( ext[c] != ROOTDIRECTORY[i].ext[c] ) && ( ROOTDIRECTORY[i].ext[c] != ' ' ) ) {
                        filenamematch = 0;
                    }
                }
                if( filenamematch )
                    filenumber = i;
                break;
        }
    }
    return( filenumber );
}

unsigned int sdcard_findfilesize( unsigned short filenumber ) {
    return( ROOTDIRECTORY[filenumber].file_size );
}

void sdcard_readcluster( unsigned short cluster ) {
    for( unsigned short i = 0; i < BOOTSECTOR -> sectors_per_cluster; i++ ) {
        sdcard_readsector( DATASTARTSECTOR + ( cluster - 2 ) * BOOTSECTOR -> sectors_per_cluster + i, CLUSTERBUFFER + i * 512 );
    }
}

void sdcard_readfile( unsigned short filenumber, unsigned char * copyAddress ) {
    unsigned short nextCluster = ROOTDIRECTORY[ filenumber ].starting_cluster;
    int i;

    do {
        sdcard_readcluster( nextCluster );
        for( i = 0; i < BOOTSECTOR -> sectors_per_cluster * 512; i++ ) {
            *copyAddress = CLUSTERBUFFER[i];
            copyAddress++;
        }
        nextCluster = FAT[ nextCluster ];
    } while( nextCluster != 0xffff );
}

// NETPBM DECODER
unsigned int skipcomment( unsigned char *netppmimagefile, unsigned int location ) {
    while( netppmimagefile[ location ] != 0x0a )
        location++;
    location++;
    return( location );
}

void netppm_display( unsigned char *netppmimagefile, unsigned char transparent ) {
    unsigned int location = 3;
    unsigned short width = 0, height = 0, depth = 0;
    unsigned char colour;

    // CHECK HEADER
    if( ( netppmimagefile[0] == 0x50 ) && ( netppmimagefile[1] == 0x36 ) && ( netppmimagefile[2] == 0x0a ) ) {
        // VALID HEADER

        // SKIP COMMENT
        while( netppmimagefile[ location ] == 0x23 ) {
            location = skipcomment( netppmimagefile, location );
        }

        // READ WIDTH
        while( netppmimagefile[ location ] != 0x20 ) {
            width = width * 10 + netppmimagefile[ location ] - 0x30;
            location++;
        }
        location++;

        // READ HEIGHT
        while( netppmimagefile[ location ] != 0x0a ) {
            height = height * 10 + netppmimagefile[ location ] - 0x30;
            location++;
        }
        location++;

        // READ DEPTH
        while( netppmimagefile[ location ] != 0x0a ) {
            depth = depth * 10 + netppmimagefile[ location ] - 0x30;
            location++;
        }
        location++;

        // 24 bit image
        if( depth == 255 ) {
            for( unsigned short y = 0; y < height; y++ ) {
                for( unsigned short x = 0; x < width; x++ ) {
                    colour = ( netppmimagefile[ location++ ] & 0xc0 ) >> 2;
                    colour = colour + ( ( netppmimagefile[ location++ ] & 0xc0 ) >> 4 );
                    colour = colour + ( ( netppmimagefile[ location++ ] & 0xc0 ) >> 6 );
                    if( colour != transparent )
                        gpu_pixel( colour, x, y );
                }
            }
        }
    }
}

// DECODE NETPPM FILE TO ARRAY
void netppm_decoder( unsigned char *netppmimagefile, unsigned char *buffer ) {
    unsigned int location = 3, bufferpos = 0;
    unsigned short width = 0, height = 0, depth = 0;
    unsigned char colour;

    // CHECK HEADER
    if( ( netppmimagefile[0] == 0x50 ) && ( netppmimagefile[1] == 0x36 ) && ( netppmimagefile[2] == 0x0a ) ) {
        // VALID HEADER

        // SKIP COMMENT
        while( netppmimagefile[ location ] == 0x23 ) {
            location = skipcomment( netppmimagefile, location );
        }

        // READ WIDTH
        while( netppmimagefile[ location ] != 0x20 ) {
            width = width * 10 + netppmimagefile[ location ] - 0x30;
            location++;
        }
        location++;

        // READ HEIGHT
        while( netppmimagefile[ location ] != 0x0a ) {
            height = height * 10 + netppmimagefile[ location ] - 0x30;
            location++;
        }
        location++;

        // READ DEPTH
        while( netppmimagefile[ location ] != 0x0a ) {
            depth = depth * 10 + netppmimagefile[ location ] - 0x30;
            location++;
        }
        location++;

        // 24 bit image
        if( depth == 255 ) {
            for( unsigned short y = 0; y < height; y++ ) {
                for( unsigned short x = 0; x < width; x++ ) {
                    colour = ( netppmimagefile[ location++ ] & 0xc0 ) >> 2;
                    colour = colour + ( ( netppmimagefile[ location++ ] & 0xc0 ) >> 4 );
                    colour = colour + ( ( netppmimagefile[ location++ ] & 0xc0 ) >> 6 );
                    buffer[ bufferpos++ ] = colour;
                }
            }
        }
    }
}

// SMT START STOP AND STATUS
void SMTSTOP( void ) {
    *SMTSTATUS = 0;
}

void SMTSTART( unsigned int code ) {
    *SMTPCH = ( code & 0xffff0000 ) >> 16;
    *SMTPCL = ( code & 0x0000ffff );
    *SMTSTATUS = 1;
}

unsigned char SMTSTATE( void ) {
    return( *SMTSTATUS );
}

// SIMPLE CURSES LIBRARY
// USES THE CURSES BUFFER IN THE CHARACTER MAP

unsigned char   __curses_backgroundcolours[COLOR_PAIRS], __curses_foregroundcolours[COLOR_PAIRS],
                __curses_scroll = 1, __curses_echo = 0, __curses_bold = 0, __curses_reverse = 0;
unsigned short  __curses_x = 0, __curses_y = 0, __curses_fore = WHITE, __curses_back = BLACK;

typedef union curses_cell {
    unsigned int bitfield;
    struct {
        unsigned int pad : 10;
        unsigned int character : 9;
        unsigned int background : 7;
        unsigned int foreground : 6;
    } cell;
} __curses_cell;

void __position_curses( unsigned short x, unsigned short y ) {
    while( *TPU_COMMIT );
    *TPU_X = x; *TPU_Y = y; *TPU_COMMIT = 1;
}

void __update_tpu( void ) {
    while( *TPU_COMMIT );
    *TPU_X = __curses_x; *TPU_Y = __curses_y; *TPU_COMMIT = 1;
    *TPU_BACKGROUND = __curses_back; *TPU_FOREGROUND = __curses_fore;
}

__curses_cell __read_curses_cell( unsigned short x, unsigned short y ) {
    __curses_cell storage;
    __position_curses( x, y );
    storage.cell.character = *TPU_CHARACTER;
    storage.cell.background = *TPU_BACKGROUND;
    storage.cell.foreground = *TPU_FOREGROUND;
    return( storage );
}

void __write_curses_cell( unsigned short x, unsigned short y, __curses_cell writecell ) {
    while( *TPU_COMMIT );
    __position_curses( x, y );
    *TPU_CHARACTER = writecell.cell.character;
    *TPU_BACKGROUND = writecell.cell.background;
    *TPU_FOREGROUND = writecell.cell.foreground;
    *TPU_COMMIT = 5;
}

void initscr( void ) {
    while( *TPU_COMMIT );
    *TPU_COMMIT = 6;
    __curses_x = 0; __curses_y = 0; __curses_fore = WHITE; __curses_back = BLACK; *TPU_CURSOR = 1; __curses_scroll = 1; __curses_bold = 0; __update_tpu();
}

int endwin( void ) {
    return( true );
}

int refresh( void ) {
    while( *TPU_COMMIT );
    *TPU_COMMIT = 7;
    return( true );
}

int clear( void ) {
    while( *TPU_COMMIT );
    *TPU_COMMIT = 6;
    __curses_x = 0; __curses_y = 0; __curses_fore = WHITE; __curses_back = BLACK; __curses_bold = 0; __update_tpu();
    return( true );
}

void cbreak( void ) {
}

void echo( void ) {
}

void noecho( void ) {
}

void scroll( void ) {
    __curses_scroll = 1;
}

void noscroll( void ) {
    __curses_scroll = 0;
}

void curs_set( int visibility ) {
    *TPU_CURSOR = visibility;
}

int start_color( void ) {
    for( unsigned short i = 0; i < 15; i++ ) {
        __curses_foregroundcolours[i] = BLACK;
        __curses_backgroundcolours[i] = BLACK;
    }
    __curses_foregroundcolours[0] = BLACK;
    __curses_foregroundcolours[1] = RED;
    __curses_foregroundcolours[2] = GREEN;
    __curses_foregroundcolours[3] = YELLOW;
    __curses_foregroundcolours[4] = BLUE;
    __curses_foregroundcolours[5] = MAGENTA;
    __curses_foregroundcolours[6] = CYAN;
    __curses_foregroundcolours[7] = WHITE;

    return( true );
}

bool has_colors( void ) {
    return( true );
}

bool can_change_color( void ) {
    return( true );
}

int init_pair( short pair, short f, short b ) {
    __curses_foregroundcolours[ pair ] = f;
    __curses_backgroundcolours[ pair ] = b;
    return( true );
}

int move( int y, int x ) {
    __curses_x = ( unsigned short ) ( x < 0 ) ? 0 : ( x > COLS-1 ) ? COLS-1 : x;
    __curses_y = ( unsigned short ) ( y < 0 ) ? 0 : ( y > LINES-1 ) ? LINES-1 : y;
    __position_curses( __curses_x, __curses_y );
    return( true );
}

int getyx( int *y, int *x ) {
    *y = (int)__curses_y;
    *x = (int)__curses_x;
    return( true );
}

void __scroll( void ) {
    __curses_cell temp;
    for( unsigned short y = 0; y < LINES-1; y++ ) {
        for( unsigned short x = 0; x < COLS; x++ ) {
            temp = __read_curses_cell( x, y + 1 );
            __write_curses_cell( x, y, temp );
        }
    }
    // BLANK THE LAST LINE
    temp.cell.character = 0;
    temp.cell.background = __curses_back;
    temp.cell.foreground = __curses_fore;
    for( unsigned short x = 0; x < COLS; x++ ) {
        __write_curses_cell( x, LINES - 1, temp );
    }
}

int addch( unsigned char ch ) {
    __curses_cell temp;

    switch( ch ) {
        case '\b': {
            // BACKSPACE
            if( __curses_x ) {
                __curses_x--;
            } else {
                if( __curses_y ) {
                    __curses_y--;
                    __curses_x = COLS-1;
                }
            }
            break;
        }
        case '\n': {
            // LINE FEED
            __curses_x = 0;
            if( __curses_y == 29 ) {
                if( __curses_scroll ) {
                    __scroll();
                } else {
                    __curses_y = 0;
                }
            } else {
                __curses_y++;
            }
            break;
        }
        case '\r': {
            // CARRIAGE RETURN
            __curses_x = 0;
            break;
        }
        default: {
            temp.cell.character = ( __curses_bold ? 256 : 0 ) + ch;
            temp.cell.background = __curses_back;
            temp.cell.foreground = __curses_fore;
            __write_curses_cell( __curses_x, __curses_y, temp );
            if( __curses_x == COLS-1 ) {
                __curses_x = 0;
                if( __curses_y == LINES-1 ) {
                    if( __curses_scroll ) {
                        __scroll();
                    } else {
                        __curses_y = 0;
                    }
                } else {
                    __curses_y++;
                }
            } else {
                __curses_x++;
            }
        }
    }
    __position_curses( __curses_x, __curses_y );
    return( true );
}

int mvaddch( int y, int x, unsigned char ch ) {
    (void)move( y, x );
    return( addch( ch ) );
}

void __curses_print_string(const char* s) {
   for(const char* p = s; *p; ++p) {
      addch(*p);
   }
}

int printw( const char *fmt,... ) {
    char *buffer = (char *)0x1000;
    va_list args;
    va_start (args, fmt);
    vsnprintf( buffer, 1023, fmt, args);
    va_end(args);

    __curses_print_string( buffer );
    return( true );
}

int mvprintw( int y, int x, const char *fmt,... ) {
    char *buffer = (char *)0x1000;
    va_list args;
    va_start (args, fmt);
    vsnprintf( buffer, 1023, fmt, args);
    va_end(args);

    move( y, x );
    __curses_print_string( buffer );

    return( true );
}

int attron( int attrs ) {
    printf("attrs = 0x%x\n",attrs);
    if( attrs & COLORS ) {
        __curses_fore = __curses_foregroundcolours[ attrs & 0x3f ];
        __curses_back = __curses_backgroundcolours[ attrs & 0x3f ];
        __update_tpu();
    }
    if( attrs & A_NORMAL ) {
        __curses_bold = 0;
        __curses_reverse = 0;
    }

    if( attrs & A_BOLD ) {
        __curses_bold = 1;
    }

    if( attrs & A_REVERSE )
        __curses_reverse = 1;

    return( true );
}

int deleteln( void ) {
    __curses_cell temp;

    if( __curses_y == LINES-1 ) {
        // BLANK LAST LINE
        temp.cell.character = 0;
        temp.cell.background = __curses_back;
        temp.cell.foreground = __curses_fore;

        for( unsigned char x = 0; x < COLS; x++ ) {
            __write_curses_cell( x, LINES-1, temp );
         }
    } else {
        // MOVE LINES UP
        for( unsigned char y = __curses_y; y < LINES-1; y++ ) {
            for( unsigned char x = 0; x < COLS; x++ ) {
                temp = __read_curses_cell( x, y + 1 );
                __write_curses_cell( x, y, temp );
            }
        }

        // BLANK LAST LINE
        temp.cell.character = 0;
        temp.cell.background = __curses_back;
        temp.cell.foreground = __curses_fore;
        for( unsigned char x = 0; x < COLS; x++ ) {
            __write_curses_cell( x, LINES-1, temp );
        }
    }

    return( true );
}

int clrtoeol( void ) {
    __curses_cell temp;
    temp.cell.character = 0;
    temp.cell.background = __curses_back;
    temp.cell.foreground = __curses_fore;
    for( int x = __curses_x; x < COLS; x++ ) {
        __write_curses_cell( x, __curses_y, temp );
    }
    return( true );
}

// newlib support routines
#ifndef MALLOC_MEMORY
#define MALLOC_MEMORY ( 16384 * 1024 )
#endif

unsigned char *_heap;
unsigned char *_sbrk( int incr ) {
  unsigned char *prev_heap;

  if (_heap == NULL) {
    _heap = (unsigned char *)MEMORYTOP - MALLOC_MEMORY - 32;
  }
  prev_heap = _heap;

  if( incr < 0 ) {
      _heap = _heap;
  } else {
    _heap += incr;
  }

  return prev_heap;
}

long _write( int fd, const void *buf, size_t cnt ) {
    unsigned char *buffer = (unsigned char *)buf;
    while( cnt-- ) {
        switch( fd ) {
            case 0:
            case 1:
            case 2:
                outputcharacter( *buffer++ );
                break;
        }
    }
    return(0);
}
long _read( int fd, const void *buf, size_t cnt ) {
    unsigned char *buffer = (unsigned char *)buf;
    while( cnt-- ) {
        switch( fd ) {
            case 0:
            case 1:
            case 2:
                *buffer++ = inputcharacter();
                break;
        }
    }
    return(0);
}
int _open( const char *file, int flags, int mode ) {
    return( -1 );
}
int _close( int fd ) {
    return( -1 );
}
int _fstat( int fd ) {
    return( 0 );
}
int _isatty( int fd ) {
    return( 0 );
}
int _lseek( int fd, int pos, int whence ) {
    return( 0 );
}
int _getpid() {
    return( 0 );
}
int _kill() {
    return( -1 );
}
void  __attribute__ ((noreturn)) _exit( int status ){
    ((void(*)(void))0x00000000)();
    while(1);
}

// ALLOCATE MEMORY FOR FILES, IN UNITS OF CLUSTERSIZE ( allows extra for reading in files )
unsigned char *filemalloc( unsigned int size ) {
    unsigned int numberofclusters = size / CLUSTERSIZE;

    if( size % CLUSTERSIZE != 0 )
        numberofclusters++;

    return( malloc( numberofclusters * CLUSTERSIZE ) );
}

// SETUP MEMORY POINTERS FOR THE SDCARD - ALREADY PRE-LOADED BY THE BIOS
extern int _bss_start, _bss_end;
void INITIALISEMEMORY( void ) {
    // SDCARD FILE SYSTEM
    MBR = (unsigned char *) 0x12000000 - 0x200;
    BOOTSECTOR = (Fat16BootSector *)0x12000000 - 0x400;
    PARTITION = (PartitionTable *) &MBR[ 0x1BE ];
    ROOTDIRECTORY = (Fat16Entry *)( 0x12000000 - 0x400 - BOOTSECTOR -> root_dir_entries * sizeof( Fat16Entry ) );
    FAT = (unsigned short * ) ROOTDIRECTORY - BOOTSECTOR -> fat_size_sectors * 512;
    CLUSTERBUFFER = (unsigned char * )FAT - BOOTSECTOR -> sectors_per_cluster * 512;
    CLUSTERSIZE = BOOTSECTOR -> sectors_per_cluster * 512;
    DATASTARTSECTOR = PARTITION[0].start_sector + BOOTSECTOR -> reserved_sectors + BOOTSECTOR -> fat_size_sectors * BOOTSECTOR -> number_of_fats + ( BOOTSECTOR -> root_dir_entries * sizeof( Fat16Entry ) ) / 512;;

    // CLEAR BSS
    memset( &_bss_start, 0, &_bss_end - &_bss_end );

    // MEMORY
    MEMORYTOP = CLUSTERBUFFER;
    _heap = NULL;
}


#include "nanojpeg.c"
