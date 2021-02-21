#include "PAWS.h"
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>

#define MAX(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a > _b ? _a : _b; })

#define MIN(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a < _b ? _a : _b; })

#define ABS(a) (((a) < 0 )? -(a) : (a))

typedef unsigned int size_t;

// STANDARD C FUNCTIONS ( from @sylefeb mylibc )

void *memcpy(void *dest, const void *src, size_t n) {
  const unsigned char *bsrc = (const unsigned char *)src;
  while ( n-- ) {
    *(unsigned char*)dest = *(++bsrc);
  }
  return(0);
}

void *memset(void *s, int c,  unsigned int n)
{
    unsigned char* p = s;
    while( n-- )
        *p++ = (unsigned char)c;
    return(0);
}

int strlen( char *s ) {
    int i = 0;
    while( *s ) {
        s++;
        i++;
    }
    return(i);
}

int strcmp(const char *p1, const char *p2) {
  while (*p1 && (*p1 == *p2)) {
    p1++; p2++;
  }
  return *(const unsigned char*)p1 - *(const unsigned char*)p2;
}

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
unsigned char *MEMORYHEAP = (unsigned char *)0x10800000;
unsigned char *MEMORYHEAPTOP = (unsigned char *)0x10800000;
unsigned char *MEMORYTOP;

// RISC-V CSR FUNCTIONS
unsigned int CSRcycles() {
   int cycles;
   asm volatile ("rdcycle %0" : "=r"(cycles));
   return cycles;
}

unsigned int CSRinstructions() {
   int insns;
   asm volatile ("rdinstret %0" : "=r"(insns));
   return insns;
}

unsigned int CSRtime() {
  int time;
  asm volatile ("rdtime %0" : "=r"(time));
  return time;
}

// INTERNAL HELPER FUNCTIONS
// CONVERT UNSIGNED INTEGERS TO STRINGS ( CHAR, SHORT and INT VERSIONS )
void chartostring( unsigned char value, char *s ) {
    unsigned char remainder, i = 0;

    while( value != 0 ) {
        remainder = value % 10;
        value = value / 10;

        s[2 - i] = remainder + '0';
        i++;
    }
}
void shorttostring( unsigned short value, char *s ) {
    unsigned short remainder;
    unsigned char i = 0;

    while( value != 0 ) {
        remainder = value % 10;
        value = value / 10;

        s[4 - i] = remainder + '0';
        i++;
    }
}
void inttostring( unsigned int value, char *s ) {
    unsigned int remainder;
    unsigned char i = 0;

    while( value != 0 ) {
        remainder = value % 10;
        value = value / 10;

        s[9 - i] = remainder + '0';
        i++;
    }
}

// OUTPUT TO UART
// OUTPUT INDIVIDUAL CHARACTER TO THE UART
void outputcharacter(char c) {
	while( *UART_STATUS & 2 ) {}
    *UART_DATA = c;
    if( c == '\n' )
        outputcharacter('\r');
}
// OUTPUT NULL TERMINATED STRING TO UART WITH NEWLINE
void outputstring(char *s) {
	while(*s) {
		outputcharacter(*s);
		s++;
	}
	outputcharacter('\n');
}
// OUTPUT NULL TERMINATED STRING TO UART WITH NO NEWLINE
void outputstringnonl(char *s) {
	while(*s) {
		outputcharacter(*s);
		s++;
	}
}
// OUTPUT UNSIGNED INTEGERS TO UART ( CHAR, SHORT and INT VERSIONS )
void outputnumber_char( unsigned char value ) {
    char valuestring[]="  0";
    chartostring( value, valuestring );
    outputstringnonl( valuestring );
}
void outputnumber_short( unsigned short value ) {
    char valuestring[]="    0";
    shorttostring( value, valuestring );
    outputstringnonl( valuestring );
}
void outputnumber_int( unsigned int value ) {
    char valuestring[]="         0";
    inttostring( value, valuestring );
    outputstringnonl( valuestring );
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


// TIMER AND PSEUDO RANDOM NUMBER GENERATOR

// PSEUDO RANDOM NUMBER GENERATOR
// RETURN PSEUDO RANDOM NUMBER 0 <= RNG < RANGE ( effectively 0 to range - 1 )
unsigned short rng( unsigned short range ) {
    unsigned short trial;

    switch( range ) {
        case 0:
            trial = 0;
            break;

        case 1:
        case 2:
            trial = *ALT_RNG & 1;
            break;

        case 4:
        case 8:
        case 16:
        case 32:
        case 64:
        case 128:
        case 256:
        case 512:
        case 1024:
        case 2048:
        case 4096:
        case 8192:
        case 16384:
        case 32768:
            trial = *ALT_RNG & ( range - 1 );
            break;

        default:
            do {
                trial = (range < 256 ) ? *ALT_RNG & 255 : *RNG;
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
    if( ( channel_number & 1 ) ) {
        *AUDIO_L_WAVEFORM = waveform;
        *AUDIO_L_NOTE = note;
        *AUDIO_L_DURATION = duration;
        *AUDIO_L_START = 1;
    }
    if( ( channel_number & 2 ) ) {
        *AUDIO_R_WAVEFORM = waveform;
        *AUDIO_R_NOTE = note;
        *AUDIO_R_DURATION = duration;
        *AUDIO_R_START = 1;
    }
}

void await_beep( unsigned char channel_number ) {
    if( channel_number & 1 )
        while( *AUDIO_L_DURATION ) {}
    if( channel_number & 2 )
        while( *AUDIO_R_DURATION ) {}
}

unsigned short get_beep_duration( unsigned char channel_number ) {
    return( ( channel_number & 1) ? *AUDIO_L_DURATION : *AUDIO_R_DURATION );
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

// READ THE ULX3S JOYSTICK BUTTONS
unsigned char get_buttons( void ) {
    return( *BUTTONS );
}

// DISPLAY FUNCTIONS
// FUNCTIONS ARE IN LAYER ORDER: BACKGROUND, TILEMAP, SPRITES (for LOWER ), BITMAP & GPU, ( UPPER SPRITES ), CHARACTERMAP & TPU
// colour is in the form { Arrggbb } { ALPHA - show layer below, RED, GREEN, BLUE } or { rrggbb } { RED, GREEN, BLUE } giving 64 colours + transparent

// WAIT FOR VBLANK TO START
void await_vblank( void ) {
    while( !*VBLANK );
}

// SET THE LAYER ORDER FOR THE DISPLAY
void screen_mode( unsigned char screenmode ) {
    *SCREENMODE = screenmode;
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
    *BACKGROUND_COLOUR = colour;
    *BACKGROUND_ALTCOLOUR = altcolour;
    *BACKGROUND_MODE = backgroundmode;
}

// SCROLLABLE TILEMAP
// The tilemap is 42 x 32, with 40 x 30 displayed, with an x and y offset in the range -15 to 15 to scroll the tilemap
// The tilemap can scroll or wrap once x or y is at -15 or 15

// SET THE TILEMAP TILE at (x,y) to tile with colours background and foreground
void set_tilemap_tile( unsigned char x, unsigned char y, unsigned char tile, unsigned char background, unsigned char foreground) {
    while( *TM_STATUS );

    *TM_X = x;
    *TM_Y = y;
    *TM_TILE = tile;
    *TM_BACKGROUND = background;
    *TM_FOREGROUND = foreground;
    *TM_COMMIT = 1;
}

// SET THE TILE BITMAP for tile to the 16 x 16 pixel bitmap
void set_tilemap_bitmap( unsigned char tile, unsigned short *bitmap ) {
    *TM_WRITER_TILE_NUMBER = tile;

    for( int i = 0; i < 16; i ++ ) {
        *TM_WRITER_LINE_NUMBER = i;
        *TM_WRITER_BITMAP = bitmap[i];
    }
}

// SCROLL WRAP or CLEAR the TILEMAP
//  action == 1 to 4 move the tilemap 1 pixel LEFT, UP, RIGHT, DOWN and SCROLL at limit
//  action == 5 to 8 move the tilemap 1 pixel LEFT, UP, RIGHT, DOWN and WRAP at limit
//  action == 9 clear the tilemap
//  RETURNS 0 if no action taken other than pixel shift, action if SCROLL WRAP or CLEAR was actioned
unsigned char tilemap_scrollwrapclear( unsigned char action ) {
    while( *TM_STATUS );
    *TM_SCROLLWRAPCLEAR = action;
    return( *TM_SCROLLWRAPCLEAR );
}

// GPU AND BITMAP
// The bitmap is 640 x 480 pixels (0,0) is ALWAYS top left even if the bitmap has been offset
// The bitmap can be moved 1 pixel at a time LEFT, RIGHT, UP, DOWN for scrolling
// The GPU can draw pixels, filled rectangles, lines, (filled) circles, filled triangles and has a 16 x 16 pixel blitter from user definable tiles


// INTERNAL FUNCTION - WAIT FOR THE GPU TO FINISH THE LAST COMMAND
void wait_gpu( void ) {
    while( *GPU_STATUS );
}

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


// SET THE PIXEL at (x,y) to colour
void gpu_pixel( unsigned char colour, short x, short y ) {
    wait_gpu();
    *GPU_COLOUR = colour;
    *GPU_X = x;
    *GPU_Y = y;
    *GPU_WRITE = 1;
}

// DRAW A LINE FROM (x1,y1) to (x2,y2) in colour - uses Bresenham's Line Drawing Algorithm
void gpu_line( unsigned char colour, short x1, short y1, short x2, short y2 ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;

    wait_gpu();
    *GPU_WRITE = 2;
}

// DRAW AN OUTLINE RECTANGLE from (x1,y1) to (x2,y2) in colour
void gpu_box( unsigned char colour, short x1, short y1, short x2, short y2 ) {
    gpu_line( colour, x1, y1, x2, y1 );
    gpu_line( colour, x2, y1, x2, y2 );
    gpu_line( colour, x2, y2, x1, y2 );
    gpu_line( colour, x1, y2, x1, y1 );
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
    bitmap_scrollwrap( 5 );
    gpu_rectangle( 64, 0, 0, 639, 479 );
}


// DRAW A (optional filled) CIRCLE at centre (x1,y1) of radius ( FILLED CIRCLES HAVE A MINIMUM RADIUS OF 4 )
void gpu_circle( unsigned char colour, short x1, short y1, short radius, unsigned char filled ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = radius;

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

    wait_gpu();
    *GPU_WRITE = 8;
}

// SET THE BLITTER TILE to the 16 x 16 pixel bitmap
void set_blitter_bitmap( unsigned char tile, unsigned short *bitmap ) {
    *BLIT_WRITER_TILE = tile;

    for( int i = 0; i < 16; i ++ ) {
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

// DRAW A FILLED QUADRILATERAL with vertices (x1,y1) (x2,y2) (x3,y3) (x4,y4) in colour BY DRAWING TWO FILLED TRIANGLES
// VERTICES SHOULD BE PRESENTED CLOCKWISE FROM THE TOP ( minimal adjustments made to the vertices to comply )
void gpu_quadrilateral( unsigned char colour, short x1, short y1, short x2, short y2, short x3, short y3, short x4, short y4 ) {
    gpu_triangle( colour, x1, y1, x2, y2, x3, y3 );
    gpu_triangle( colour, x1, y1, x3, y3, x4, y4 );
}

// OUTPUT A STRING TO THE GPU
void gpu_outputstring( unsigned char colour, short x, short y, char *s, unsigned char size ) {
    while( *s ) {
        gpu_character_blit( colour, x, y, *s++, size );
        x = x + ( 8 << size );
    }
}
// OUTPUT A STRING TO THE GPU - CENTRED AT ( x,y )
void gpu_outputstringcentre( unsigned char colour, short x, short y, char *s, unsigned char size ) {
    x = x - ( ( strlen( s ) * ( 8 << size ) ) /2 );
    gpu_outputstring( colour, x, y, s, size );
}

// GPU VECTOR BLOCK
// 32 VECTOR BLOCKS EACH OF 16 VERTICES ( offsets in the range -15 to 15 from the centre )
// WHEN ACTIVATED draws lines from a vector block (x0,y0) to (x1,y1), (x1,y1) to (x2,y2), (x2,y2) to (x3,y3) until (x15,y15) or an inactive vertex is encountered

// INTERNAL FUNCTION - WAIT FOR THE VECTOR BLOCK TO FINISH THE LAST COMMAND
void wait_vector_block( void ) {
    while( *VECTOR_DRAW_STATUS );
}

// START DRAWING A VECTOR BLOCK centred at (xc,yc) in colour
void draw_vector_block( unsigned char block, unsigned char colour, short xc, short yc ) {
    wait_vector_block();

    *VECTOR_DRAW_BLOCK = block;
    *VECTOR_DRAW_COLOUR = colour;
    *VECTOR_DRAW_XC = xc;
    *VECTOR_DRAW_YC = yc;
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

// SET SPRITE sprite_number in sprite_layer to active status, in colour to (x,y) with bitmap number tile ( 0 - 7 ) in sprite_size == 0 16 x 16 == 1 32 x 32 pixel size
void set_sprite( unsigned char sprite_layer, unsigned char sprite_number, unsigned char active, unsigned char colour, short x, short y, unsigned char tile, unsigned char sprite_size) {
    switch( sprite_layer ) {
        case 0:
            *LOWER_SPRITE_NUMBER = sprite_number;
            *LOWER_SPRITE_ACTIVE = active;
            *LOWER_SPRITE_TILE = tile;
            *LOWER_SPRITE_COLOUR = colour;
            *LOWER_SPRITE_X = x;
            *LOWER_SPRITE_Y = y;
            *LOWER_SPRITE_DOUBLE = sprite_size;
            break;

        case 1:
            *UPPER_SPRITE_NUMBER = sprite_number;
            *UPPER_SPRITE_ACTIVE = active;
            *UPPER_SPRITE_TILE = tile;
            *UPPER_SPRITE_COLOUR = colour;
            *UPPER_SPRITE_X = x;
            *UPPER_SPRITE_Y = y;
            *UPPER_SPRITE_DOUBLE = sprite_size;
            break;
    }
}

// SET or GET ATTRIBUTES for sprite_number in sprite_layer
//  attribute == 0 active status ( 0 == inactive, 1 == active )
//  attribute == 1 tile number ( 0 to 7 )
//  attribute == 2 colour
//  attribute == 3 x coordinate
//  attribute == 4 y coordinate
//  attribute == 5 size ( 0 == 16 x 16, 1 == 32 x 32 )
void set_sprite_attribute( unsigned char sprite_layer, unsigned char sprite_number, unsigned char attribute, short value ) {
    if( sprite_layer == 0 ) {
        *LOWER_SPRITE_NUMBER = sprite_number;
        switch( attribute ) {
            case 0:
                *LOWER_SPRITE_ACTIVE = ( unsigned char) value;
                break;
            case 1:
                *LOWER_SPRITE_TILE = ( unsigned char) value;
                break;
            case 2:
                *LOWER_SPRITE_COLOUR = ( unsigned char) value;
                break;
            case 3:
                *LOWER_SPRITE_X = value;
                break;
            case 4:
                *LOWER_SPRITE_Y = value;
                break;
            case 5:
                *LOWER_SPRITE_DOUBLE = ( unsigned char) value;
                break;
        }
    } else {
        *UPPER_SPRITE_NUMBER = sprite_number;
        switch( attribute ) {
            case 0:
                *UPPER_SPRITE_ACTIVE = ( unsigned char) value;
                break;
            case 1:
                *UPPER_SPRITE_TILE = ( unsigned char) value;
                break;
            case 2:
                *UPPER_SPRITE_COLOUR = ( unsigned char) value;
                break;
            case 3:
                *UPPER_SPRITE_X = value;
                break;
            case 4:
                *UPPER_SPRITE_Y = value;
                break;
            case 5:
                *UPPER_SPRITE_DOUBLE = ( unsigned char) value;
                break;
        }
    }
}

short get_sprite_attribute( unsigned char sprite_layer, unsigned char sprite_number, unsigned char attribute ) {
    if( sprite_layer == 0 ) {
        *LOWER_SPRITE_NUMBER = sprite_number;
        switch( attribute ) {
            case 0:
                return( (short)*LOWER_SPRITE_ACTIVE );
            case 1:
                return( (short)*LOWER_SPRITE_TILE );
            case 2:
                return( (short)*LOWER_SPRITE_COLOUR );
            case 3:
                return( *LOWER_SPRITE_X );
            case 4:
                return( *LOWER_SPRITE_Y );
            case 5:
                return( (short)*LOWER_SPRITE_DOUBLE );
            default:
                return( 0 );
        }
    } else {
        *UPPER_SPRITE_NUMBER = sprite_number;
        switch( attribute ) {
            case 0:
                return( (short)*UPPER_SPRITE_ACTIVE );
            case 1:
                return( (short)*UPPER_SPRITE_TILE );
            case 2:
                return( (short)*UPPER_SPRITE_COLOUR );
            case 3:
                return( *UPPER_SPRITE_X );
            case 4:
                return( *UPPER_SPRITE_Y );
            case 5:
                return( (short)*UPPER_SPRITE_DOUBLE );
            default:
                return( 0 );
        }
    }
}

// RETURN THE COLLISION STATUS for sprite_number in sprite_layer
//  bit is 1 if sprite is in collision with { bitmap, tilemap, other sprite layer, in layer sprite 12, in layer sprite 11 .. in layer sprite 0 }
unsigned short get_sprite_collision( unsigned char sprite_layer, unsigned char sprite_number ) {
    return( ( sprite_layer == 0 ) ? LOWER_SPRITE_COLLISION_BASE[sprite_number] : UPPER_SPRITE_COLLISION_BASE[sprite_number] );
}

// UPDATE A SPITE moving by x and y deltas, with optional wrap/kill and optional changing of the tile
//  update_flag = { y action, x action, tile action, 5 bit y delta, 5 bit x delta }
//  x and y action ( 0 == wrap, 1 == kill when moves offscreen )
//  x and y deltas a 2s complement -15 to 15 range
//  tile action, increase the tile number ( provides limited animation effects )
void update_sprite( unsigned char sprite_layer, unsigned char sprite_number, unsigned short update_flag ) {
    switch( sprite_layer ) {
        case 0:
            *LOWER_SPRITE_NUMBER = sprite_number;
            *LOWER_SPRITE_UPDATE = update_flag;
            break;
        case 1:
            *UPPER_SPRITE_NUMBER = sprite_number;
            *UPPER_SPRITE_UPDATE = update_flag;
            break;
    }
}

// SPRITE LAYERS - SMT ACCESS
// DUPLICATE TO ALLOW BOTH THREADS TO USE SPRITES - VIA SMT SPRITE REGISTERS
void set_sprite_SMT( unsigned char sprite_layer, unsigned char sprite_number, unsigned char active, unsigned char colour, short x, short y, unsigned char tile, unsigned char sprite_size) {
    switch( sprite_layer ) {
        case 0:
            *LOWER_SPRITE_NUMBER_SMT = sprite_number;
            *LOWER_SPRITE_ACTIVE_SMT = active;
            *LOWER_SPRITE_TILE_SMT = tile;
            *LOWER_SPRITE_COLOUR_SMT = colour;
            *LOWER_SPRITE_X_SMT = x;
            *LOWER_SPRITE_Y_SMT = y;
            *LOWER_SPRITE_DOUBLE_SMT = sprite_size;
            break;

        case 1:
            *UPPER_SPRITE_NUMBER_SMT = sprite_number;
            *UPPER_SPRITE_ACTIVE_SMT = active;
            *UPPER_SPRITE_TILE_SMT = tile;
            *UPPER_SPRITE_COLOUR_SMT = colour;
            *UPPER_SPRITE_X_SMT = x;
            *UPPER_SPRITE_Y_SMT = y;
            *UPPER_SPRITE_DOUBLE_SMT = sprite_size;
            break;
    }
}

void set_sprite_attribute_SMT( unsigned char sprite_layer, unsigned char sprite_number, unsigned char attribute, short value ) {
    if( sprite_layer == 0 ) {
        *LOWER_SPRITE_NUMBER_SMT = sprite_number;
        switch( attribute ) {
            case 0:
                *LOWER_SPRITE_ACTIVE_SMT = ( unsigned char) value;
                break;
            case 1:
                *LOWER_SPRITE_TILE_SMT = ( unsigned char) value;
                break;
            case 2:
                *LOWER_SPRITE_COLOUR_SMT = ( unsigned char) value;
                break;
            case 3:
                *LOWER_SPRITE_X_SMT = value;
                break;
            case 4:
                *LOWER_SPRITE_Y_SMT = value;
                break;
            case 5:
                *LOWER_SPRITE_DOUBLE_SMT = ( unsigned char) value;
                break;
        }
    } else {
        *UPPER_SPRITE_NUMBER_SMT = sprite_number;
        switch( attribute ) {
            case 0:
                *UPPER_SPRITE_ACTIVE_SMT = ( unsigned char) value;
                break;
            case 1:
                *UPPER_SPRITE_TILE_SMT = ( unsigned char) value;
                break;
            case 2:
                *UPPER_SPRITE_COLOUR_SMT = ( unsigned char) value;
                break;
            case 3:
                *UPPER_SPRITE_X_SMT = value;
                break;
            case 4:
                *UPPER_SPRITE_Y_SMT = value;
                break;
            case 5:
                *UPPER_SPRITE_DOUBLE_SMT = ( unsigned char) value;
                break;
        }
    }
}

short get_sprite_attribute_SMT( unsigned char sprite_layer, unsigned char sprite_number, unsigned char attribute ) {
    if( sprite_layer == 0 ) {
        *LOWER_SPRITE_NUMBER_SMT = sprite_number;
        switch( attribute ) {
            case 0:
                return( (short)*LOWER_SPRITE_ACTIVE_SMT );
            case 1:
                return( (short)*LOWER_SPRITE_TILE_SMT );
            case 2:
                return( (short)*LOWER_SPRITE_COLOUR_SMT );
            case 3:
                return( *LOWER_SPRITE_X_SMT );
            case 4:
                return( *LOWER_SPRITE_Y_SMT );
            case 5:
                return( (short)*LOWER_SPRITE_DOUBLE_SMT );
            default:
                return( 0 );
        }
    } else {
        *UPPER_SPRITE_NUMBER_SMT = sprite_number;
        switch( attribute ) {
            case 0:
                return( (short)*UPPER_SPRITE_ACTIVE_SMT );
            case 1:
                return( (short)*UPPER_SPRITE_TILE_SMT );
            case 2:
                return( (short)*UPPER_SPRITE_COLOUR_SMT );
            case 3:
                return( *UPPER_SPRITE_X_SMT );
            case 4:
                return( *UPPER_SPRITE_Y_SMT );
            case 5:
                return( (short)*UPPER_SPRITE_DOUBLE_SMT );
            default:
                return( 0 );
        }
    }
}

void update_sprite_SMT( unsigned char sprite_layer, unsigned char sprite_number, unsigned short update_flag ) {
    switch( sprite_layer ) {
        case 0:
            *LOWER_SPRITE_NUMBER_SMT = sprite_number;
            *LOWER_SPRITE_UPDATE_SMT = update_flag;
            break;
        case 1:
            *UPPER_SPRITE_NUMBER_SMT = sprite_number;
            *UPPER_SPRITE_UPDATE_SMT = update_flag;
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

// OUTPUT A CHARACTER TO THE CHARACTER MAP
void tpu_output_character( char c ) {
    while( *TPU_COMMIT );
    *TPU_CHARACTER = c; *TPU_COMMIT = 2;
}

// OUTPUT A NULL TERMINATED STRING TO THE CHARACTER MAP
void tpu_outputstring( char *s ) {
    while( *s ) {
        while( *TPU_COMMIT );
        *TPU_CHARACTER = *s; *TPU_COMMIT = 2;
        s++;
    }
}

void tpu_outputstringcentre( unsigned char y, unsigned char background, unsigned char foreground, char *s ) {
    tpu_clearline( y );
    tpu_set( 40 - ( strlen(s) >> 1 ), y, background, foreground );
    tpu_outputstring( s );
}

// OUTPUT UNSIGNED INTEGERS TO TPU ( CHAR, SHORT and INT VERSIONS )
void tpu_outputnumber_char( unsigned char value ) {
    char valuestring[]="  0";
    chartostring( value, valuestring );
    tpu_outputstring( valuestring );
}
void tpu_outputnumber_short( unsigned short value ) {
    char valuestring[]="    0";
    shorttostring( value, valuestring );
    tpu_outputstring( valuestring );
}
void tpu_outputnumber_int( unsigned int value ) {
    char valuestring[]="         0";
    inttostring( value, valuestring );
    tpu_outputstring( valuestring );
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

// COPY A BITMAP STORED IN MEMORY TO THE GPU_COLOUR
// FOR SPEED USES AN OPTIMISED INLINE VERSION OF GPU_PIXEL
void bitmapblit( unsigned char *buffer, unsigned short width, unsigned short height, short xpos, short ypos, unsigned char transparent ) {
    unsigned int bufferpos = 0;
    unsigned short *twocolour = (unsigned short *)buffer;
    unsigned char colour, colour2;

    wait_gpu();
    for( unsigned short y = ypos; y < ypos + height; y++ ) {
        *GPU_Y = y;
        for( unsigned short x = xpos; x < xpos + width; x = x + 2 ) {
            colour = twocolour[ bufferpos ] & 0xff;
            colour2 = twocolour[ bufferpos ] >> 8;
            *GPU_COLOUR = colour; *GPU_X = x; *GPU_WRITE = ( colour != transparent );
            *GPU_COLOUR = colour2; *GPU_X = x + 1; *GPU_WRITE = ( colour2 != transparent );
            bufferpos++;
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
char            __curses_character[80][30], __curses_background[80][30], __curses_foreground[80][30];
unsigned char   __curses_backgroundcolours[16], __curses_foregroundcolours[16], __curses_cursor = 1, __curses_scroll = 1;

unsigned short  __curses_x = 0, __curses_y = 0, __curses_fore = WHITE, __curses_back = BLACK;

void initscr( void ) {
    for( unsigned x = 0; x < 80; x++ ) {
        for( unsigned y = 0; y < 30; y++ ) {
            __curses_character[x][y] = 0;
            __curses_background[x][y] = TRANSPARENT;
            __curses_foreground[x][y] = BLACK;
        }
    }
    __curses_x = 0; __curses_y = 0; __curses_fore = WHITE; __curses_back = BLACK; __curses_cursor = 1; __curses_scroll = 1;
}

int endwin( void ) {
    return( true );
}

int refresh( void ) {
    for( unsigned char y = 0; y < 30; y ++ ) {
        for( unsigned char x = 0; x < 80; x++ ) {
            if( ( x == __curses_x ) && ( y == __curses_y ) && ( __curses_cursor ) && ( systemclock() & 1 ) ) {
                tpu_set( x, y, __curses_fore, __curses_back );
            } else {
                tpu_set( x, y, __curses_background[x][y], __curses_foreground[x][y] );
            }
            tpu_output_character( __curses_character[x][y] );
        }
    }

    return( true );
}

int clear( void ) {
    initscr();
    return( true );
}

void cbreak( void ) {
}

void echo( void ) {
}

void noecho( void ) {
}

void curs_set( int visibility ) {
    __curses_cursor = visibility;
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
    __curses_x = ( unsigned short ) ( x < 0 ) ? 0 : ( x > 79 ) ? 79 : x;
    __curses_y = ( unsigned short ) ( y < 0 ) ? 0 : ( y > 29 ) ? 29 : y;

    return( true );
}

void __scroll( void ) {
    for( unsigned short y = 0; y < 29; y++ ) {
        for( unsigned short x = 0; x < 80; x++ ) {
            __curses_character[ x ][ y ] = __curses_character[ x ][ y + 1 ];
            __curses_background[ x ][ y ] = __curses_background[ x ][ y + 1 ];
            __curses_foreground[ x ][ y ] = __curses_foreground[ x ][ y + 1 ];
        }
    }
}

int addch( unsigned char ch ) {
    switch( ch ) {
        case '\b': {
            // BACKSPACE
            if( __curses_x ) {
                __curses_x--;
            } else {
                if( __curses_y ) {
                    __curses_y--;
                    __curses_x = 79;
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
            __curses_character[ __curses_x ][ __curses_y ] = ch;
            __curses_background[ __curses_x ][ __curses_y ] = __curses_back;
            __curses_foreground[ __curses_x ][ __curses_y ] = __curses_fore;
            if( __curses_x == 79 ) {
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
            } else {
                __curses_x++;
            }
        }
    }

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
    static char buffer[1024];
    va_list args;
    va_start (args, fmt);
    vsnprintf( buffer, 1023, fmt, args);
    va_end(args);

    __curses_print_string( buffer );
    return( true );
}

int mvprintw( int y, int x, const char *fmt,... ) {
    static char buffer[1024];
    va_list args;
    va_start (args, fmt);
    vsnprintf( buffer, 1023, fmt, args);
    va_end(args);

    move( y, x );
    __curses_print_string( buffer );

    return( true );
}

int attron( int attrs ) {
    __curses_fore = __curses_foregroundcolours[ attrs ];
    __curses_back = __curses_backgroundcolours[ attrs ];
    return( true );
}

int deleteln( void ) {
    if( __curses_y == 29 ) {
        // BLANK LAST LINE
        for( unsigned char x = 0; x < 80; x++ ) {
            __curses_character[x][29] = 0;
            __curses_background[x][29] = __curses_back;
            __curses_foreground[x][29] = __curses_fore;
        }
    } else {
        // MOVE LINES UP
        for( unsigned char y = __curses_y; y < 29; y++ ) {
            for( unsigned char x = 0; x < 80; x++ ) {
                __curses_character[x][y] = __curses_character[x][y+1];
                __curses_background[x][y] = __curses_background[x][y+1];
                __curses_foreground[x][y] = __curses_foreground[x][y+1];
            }
        }

        // BLANK LAST LINE
        for( unsigned char x = 0; x < 80; x++ ) {
            __curses_character[x][29] = 0;
            __curses_background[x][29] = __curses_back;
            __curses_foreground[x][29] = __curses_fore;
        }
    }

    return( true );
}

int clrtoeol( void ) {
    for( int x = __curses_x; x < 80; x++ ) {
            __curses_character[x][__curses_y] = 0;
            __curses_background[x][__curses_y] = __curses_back;
            __curses_foreground[x][__curses_y] = __curses_fore;
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

  outputstringnonl( "I am in _sbrk Request :" ); outputnumber_int( incr );

  if (_heap == NULL) {
    outputstringnonl( " (SBRK INIT) " );
    _heap = (unsigned char *)MEMORYTOP - MALLOC_MEMORY - 32;
  }
  prev_heap = _heap;

  _heap += incr;

  outputstringnonl( " New Heap :" ); outputnumber_int( (int)_heap ); outputstring("\n");

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
void _exit() {
    ((void(*)(void))0x00000000)();
}

// ALLOCATE MEMORY FOR FILES, IN UNITS OF CLUSTERSIZE ( allows extra for reading in files )
unsigned char *filemalloc( unsigned int size ) {
    unsigned int numberofclusters = size / CLUSTERSIZE;

    if( size % CLUSTERSIZE != 0 )
        numberofclusters++;

    return( malloc( numberofclusters * CLUSTERSIZE ) );
}

// SETUP MEMORY POINTERS FOR THE SDCARD - ALREADY PRE-LOADED BY THE BIOS
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

    // MEMORY
    MEMORYTOP = CLUSTERBUFFER;
    _heap = NULL;
    outputstringnonl("SBRK(0): "); _sbrk(0);
    outputstringnonl("FREE(MALLOC(32)): "); free(malloc( 32  ) );
}
