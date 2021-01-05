#include "PAWS.h"

typedef unsigned int size_t;

// STANDARD C FUNCTIONS ( from @sylefeb mylibc )
void*  memcpy(void *dest, const void *src, size_t n) {
  const void *end = src + n;
  const unsigned char *bsrc = (const unsigned char *)src;
  while (bsrc != end) {
    *(unsigned char*)dest = *(++bsrc);
  }
  return dest;
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

// RISC-V CSR FUNCTIONS
long CSRcycles() {
   int cycles;
   asm volatile ("rdcycle %0" : "=r"(cycles));
   return cycles;
}

long CSRinstructions() {
   int insns;
   asm volatile ("rdinstret %0" : "=r"(insns));
   return insns;
}

long CSRtime() {
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

// OUTPUT TO TERMINAL & UART
// OUTPUT INDIVIDUAL CHARACTER TO THE UART/TERMINAL
void outputcharacter(char c) {
	while( *UART_STATUS & 2 );
    *UART_DATA = c;

    while( *TERMINAL_STATUS );
    *TERMINAL_OUTPUT = c;

    if( c == '\n' )
        outputcharacter('\r');
}
// OUTPUT NULL TERMINATED STRING TO UART/TERMINAL WITH NEWLINE
void outputstring(char *s) {
	while(*s) {
		outputcharacter(*s);
		s++;
	}
	outputcharacter('\n');
}
// OUTPUT NULL TERMINATED STRING TO UART/TERMINAL WITH NO NEWLINE
void outputstringnonl(char *s) {
	while(*s) {
		outputcharacter(*s);
		s++;
	}
}
// OUTPUT UNSIGNED INTEGERS TO UART/TERMINAL ( CHAR, SHORT and INT VERSIONS )
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
unsigned char inputcharacter_available( void ) {
    return( *UART_STATUS & 1 );
}
// RETURN CHARACTER FROM UART
char inputcharacter( void ) {
	while( !inputcharacter_available() );
    return *UART_DATA;
}

// TIMER AND PSEUDO RANDOM NUMBER GENERATOR

// SLEEP FOR counter milliseconds
void sleep( unsigned short counter ) {
    *SLEEPTIMER = counter;
    while( *SLEEPTIMER );
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

// BACKGROUND GENERATOR
void set_background( unsigned char colour, unsigned char altcolour, unsigned char backgroundmode ) {
    *BACKGROUND_COLOUR = colour;
    *BACKGROUND_ALTCOLOUR = altcolour;
    *BACKGROUND_MODE = backgroundmode;
}

// GPU AND BITMAP
// The bitmap is 640 x 480 pixels (0,0) is ALWAYS top left even if the bitmap has been offset
// The bitmap can be moved 1 pixel at a time LEFT, RIGHT, UP, DOWN for scrolling
// The GPU can draw pixels, filled rectangles, lines, (filled) circles, filled triangles and has a 16 x 16 pixel blitter from user definable tiles

// INTERNAL FUNCTION - WAIT FOR THE GPU TO FINISH THE LAST COMMAND
void wait_gpu( void ) {
    while( *GPU_STATUS != 0 );
}

// SCROLL THE BITMAP by 1 pixel
//  action == 1 LEFT, == 2 UP, == 3 RIGHT, == 4 DOWN, == 5 RESET
void bitmap_scrollwrap( unsigned char action ) {
    wait_gpu();
    *BITMAP_SCROLLWRAP = action;
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
    bitmap_scrollwrap( 5 );
    gpu_rectangle( 64, 0, 0, 639, 479 );
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

// OUTPUT UNSIGNED INTEGERS TO UART/TERMINAL ( CHAR, SHORT and INT VERSIONS )
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

// TERMINAL (NON-OUTPUT)

// TERMINAL is an 80 x 8 character window ( white text, blue background ) with a 256 character 8 x 8 pixel character generator ROM )
// DISPLAYS AT THE BOTTOM OF THE SCREEN

// status == 1 SHOW THE TERMINAL WINDOW, status == 0 HIDE THE TERMINAL WINDOW
void terminal_showhide( unsigned char status ) {
    *TERMINAL_SHOWHIDE = status;
}


