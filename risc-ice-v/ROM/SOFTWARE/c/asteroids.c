unsigned char volatile * UART_STATUS = (unsigned char volatile *) 0x8004;
unsigned char * UART_DATA = (unsigned char *) 0x8000;
unsigned char volatile * BUTTONS = (unsigned char volatile *) 0x8008;
unsigned char volatile * LEDS = (unsigned char volatile *) 0x800c;

unsigned char volatile * SDCARD_READY = (unsigned char volatile *) 0x8f00;
unsigned char volatile * SDCARD_START = (unsigned char volatile *) 0x8f00;
unsigned short volatile * SDCARD_SECTOR_LOW = ( unsigned short *) 0x8f08;
unsigned short volatile * SDCARD_SECTOR_HIGH = ( unsigned short *) 0x8f04;
unsigned short volatile * SDCARD_ADDRESS = (unsigned short volatile *) 0x8f10;
unsigned char volatile * SDCARD_DATA = (unsigned char volatile *) 0x8f10;

unsigned char * TERMINAL_OUTPUT = (unsigned char *) 0x8700;
unsigned char volatile * TERMINAL_SHOWHIDE = (unsigned char volatile *) 0x8704;
unsigned char volatile * TERMINAL_STATUS = (unsigned char volatile *) 0x8700;

unsigned char volatile * BACKGROUND_COLOUR = (unsigned char volatile *) 0x8100;
unsigned char volatile * BACKGROUND_ALTCOLOUR = (unsigned char volatile *) 0x8104;
unsigned char volatile * BACKGROUND_MODE = (unsigned char volatile *) 0x8108;

unsigned char volatile * TM_X = (unsigned char volatile *) 0x8200;
unsigned char volatile * TM_Y = (unsigned char volatile *) 0x8204;
unsigned char volatile * TM_TILE = (unsigned char volatile *) 0x8208;
unsigned char volatile * TM_BACKGROUND = (unsigned char volatile *) 0x820c;
unsigned char volatile * TM_FOREGROUND = (unsigned char volatile *) 0x8210;
unsigned char volatile * TM_COMMIT = (unsigned char volatile *) 0x8214;
unsigned char volatile * TM_WRITER_TILE_NUMBER = (unsigned char volatile *) 0x8220;
unsigned char volatile * TM_WRITER_LINE_NUMBER = (unsigned char volatile *) 0x8224;
unsigned short volatile * TM_WRITER_BITMAP = (unsigned short volatile *) 0x8228;
unsigned char volatile * TM_SCROLLWRAPCLEAR = (unsigned char volatile *) 0x8230;
unsigned char volatile * TM_STATUS = (unsigned char volatile *) 0x8234;

short volatile * GPU_X = (short volatile *) 0x8400;
short volatile * GPU_Y = (short volatile *) 0x8404;
unsigned char volatile * GPU_COLOUR = (unsigned char volatile *) 0x8408;
short volatile * GPU_PARAM0 = (short volatile *) 0x840C;
short volatile * GPU_PARAM1 = (short volatile *) 0x8410;
short volatile * GPU_PARAM2 = (short volatile *) 0x8414;
short volatile * GPU_PARAM3 = (short volatile *) 0x8418;
unsigned char volatile * GPU_WRITE = (unsigned char volatile *) 0x841C;
unsigned char volatile * GPU_STATUS = (unsigned char volatile *) 0x841C;

unsigned char volatile * VECTOR_DRAW_BLOCK = (unsigned char volatile *) 0x8420;
unsigned char volatile * VECTOR_DRAW_COLOUR = (unsigned char volatile *) 0x8424;
short volatile * VECTOR_DRAW_XC = (short volatile *) 0x8428;
short volatile * VECTOR_DRAW_YC = (short volatile *) 0x842c;
unsigned char volatile * VECTOR_DRAW_START = (unsigned char volatile *) 0x8430;
unsigned char volatile * VECTOR_DRAW_STATUS = (unsigned char volatile *) 0x8448;

unsigned char volatile * VECTOR_WRITER_BLOCK = (unsigned char volatile *) 0x8434;
unsigned char volatile * VECTOR_WRITER_VERTEX = (unsigned char volatile *) 0x8438;
unsigned char volatile * VECTOR_WRITER_ACTIVE = (unsigned char volatile *) 0x8444;
char volatile * VECTOR_WRITER_DELTAX = (char volatile *) 0x843c;
char volatile * VECTOR_WRITER_DELTAY = (char volatile *) 0x8440;

unsigned char volatile * BITMAP_SCROLLWRAP = (unsigned char volatile *) 0x8460;

unsigned char volatile * LOWER_SPRITE_NUMBER = ( unsigned char volatile * ) 0x8300;
unsigned char volatile * LOWER_SPRITE_ACTIVE = ( unsigned char volatile * ) 0x8304;
unsigned char volatile * LOWER_SPRITE_TILE = ( unsigned char volatile * ) 0x8308;
unsigned char volatile * LOWER_SPRITE_COLOUR = ( unsigned char volatile * ) 0x830c;
short volatile * LOWER_SPRITE_X = ( short volatile * ) 0x8310;
short volatile * LOWER_SPRITE_Y = ( short volatile * ) 0x8314;
unsigned char volatile * LOWER_SPRITE_DOUBLE = ( unsigned char volatile * ) 0x8318;
unsigned short volatile * LOWER_SPRITE_UPDATE = ( unsigned short volatile * ) 0x831c;
unsigned char volatile * LOWER_SPRITE_WRITER_NUMBER = ( unsigned char volatile * ) 0x8320;
unsigned char volatile * LOWER_SPRITE_WRITER_LINE = ( unsigned char volatile * ) 0x8324;
unsigned short volatile * LOWER_SPRITE_WRITER_BITMAP = ( unsigned short volatile * ) 0x8328;
unsigned short volatile * LOWER_SPRITE_COLLISION_BASE = ( unsigned short volatile * ) 0x8330;

unsigned char volatile * UPPER_SPRITE_NUMBER = ( unsigned char volatile * ) 0x8500;
unsigned char volatile * UPPER_SPRITE_ACTIVE = ( unsigned char volatile * ) 0x8504;
unsigned char volatile * UPPER_SPRITE_TILE = ( unsigned char volatile * ) 0x8508;
unsigned char volatile * UPPER_SPRITE_COLOUR = ( unsigned char volatile * ) 0x850c;
short volatile * UPPER_SPRITE_X = ( short volatile * ) 0x8510;
short volatile * UPPER_SPRITE_Y = ( short volatile * ) 0x8514;
unsigned char volatile * UPPER_SPRITE_DOUBLE = ( unsigned char volatile * ) 0x8518;
unsigned short volatile * UPPER_SPRITE_UPDATE = ( unsigned short volatile * ) 0x851c;
unsigned char volatile * UPPER_SPRITE_WRITER_NUMBER = ( unsigned char volatile * ) 0x8520;
unsigned char volatile * UPPER_SPRITE_WRITER_LINE = ( unsigned char volatile * ) 0x8524;
unsigned short volatile * UPPER_SPRITE_WRITER_BITMAP = ( unsigned short volatile * ) 0x8528;
unsigned short volatile * UPPER_SPRITE_COLLISION_BASE = ( unsigned short volatile * ) 0x8530;

unsigned char volatile * TPU_X = ( unsigned char volatile * ) 0x8600;
unsigned char volatile * TPU_Y = ( unsigned char volatile * ) 0x8604;
unsigned char volatile * TPU_CHARACTER = ( unsigned char volatile * ) 0x8608;
unsigned char volatile * TPU_BACKGROUND = ( unsigned char volatile * ) 0x860c;
unsigned char volatile * TPU_FOREGROUND = ( unsigned char volatile * ) 0x8610;
unsigned char volatile * TPU_COMMIT = ( unsigned char volatile * ) 0x8614;

unsigned char volatile * AUDIO_L_WAVEFORM = ( unsigned char volatile * ) 0x8800;
unsigned char volatile * AUDIO_L_NOTE = ( unsigned char volatile * ) 0x8804;
unsigned short volatile * AUDIO_L_DURATION = ( unsigned short volatile * ) 0x8808;
unsigned char volatile * AUDIO_L_START = ( unsigned char volatile * ) 0x880c;
unsigned char volatile * AUDIO_R_WAVEFORM = ( unsigned char volatile * ) 0x8810;
unsigned char volatile * AUDIO_R_NOTE = ( unsigned char volatile * ) 0x8814;
unsigned short volatile * AUDIO_R_DURATION = ( unsigned short volatile * ) 0x8818;
unsigned char volatile * AUDIO_R_START = ( unsigned char volatile * ) 0x881c;

unsigned short volatile * RNG = ( unsigned short volatile * ) 0x8900;
unsigned short volatile * ALT_RNG = ( unsigned short volatile * ) 0x8904;
unsigned short volatile * TIMER1HZ = ( unsigned short volatile * ) 0x8910;
unsigned short volatile * TIMER1KHZ = ( unsigned short volatile * ) 0x8920;
unsigned short volatile * SLEEPTIMER = ( unsigned short volatile * ) 0x8930;

unsigned char volatile * VBLANK = ( unsigned char volatile * ) 0x8ff0;

void *memcpy( void *destination, void *source, unsigned int length )
{
    unsigned int i;
    unsigned char *d, *s;

    for( i = 0; i < length; i++ ) {
        d[i] = s[i];
    }
}

void outputcharacter(char c)
{
	while( (*UART_STATUS & 2) != 0 );
    *UART_DATA = c;
    *TERMINAL_OUTPUT = c;
    if( c == '\n' )
        outputcharacter('\r');
}
void outputstring(char *s)
{
	while(*s) {
		outputcharacter(*s);
		s++;
	}
	outputcharacter('\n');
}
void outputstringnonl(char *s)
{
	while(*s) {
		outputcharacter(*s);
		s++;
	}
}

char inputcharacter( void )
{
	while( !(*UART_STATUS & 1) );
    return *UART_DATA;
}

unsigned short rng( unsigned short range )
{
    unsigned short trial;

    if( range <2 ) {
        trial = ( range == 0 ) ? 0 : *RNG & 1;
    } else {
        if( range < 256 ) {
            trial = *RNG % range;
        } else {
            do {
                trial = *RNG;
            } while ( trial >= range );
        }
    }

    return( trial );
}

void set_timer1khz( short counter )
{
    *TIMER1KHZ = counter;
}

void wait_timer1khz( void )
{
    while( *TIMER1KHZ != 0 );
}

void beep( unsigned char channel_number, unsigned char waveform, unsigned char note, unsigned short duration )
{
    if( ( channel_number & 1 ) != 0 ) {
        *AUDIO_L_WAVEFORM = waveform;
        *AUDIO_L_NOTE = note;
        *AUDIO_L_DURATION = duration;
        *AUDIO_L_START = 1;
    }
    if( ( channel_number & 2 ) != 0 ) {
        *AUDIO_R_WAVEFORM = waveform;
        *AUDIO_R_NOTE = note;
        *AUDIO_R_DURATION = duration;
        *AUDIO_R_START = 1;
    }
}

void set_background( unsigned char colour, unsigned char altcolour, unsigned char backgroundmode )
{
    *BACKGROUND_COLOUR = colour;
    *BACKGROUND_ALTCOLOUR = altcolour;
    *BACKGROUND_MODE = backgroundmode;
}

void terminal_showhide( unsigned char status )
{
    *TERMINAL_SHOWHIDE = status;
}

void await_vblank( void )
{
    while( !*VBLANK != 0 );
}

void set_tilemap_tile( unsigned char x, unsigned char y, unsigned char tile, unsigned char background, unsigned char foreground)
{
    while( *TM_STATUS != 0 );

    *TM_X = x;
    *TM_Y = y;
    *TM_TILE = tile;
    *TM_BACKGROUND = background;
    *TM_FOREGROUND = foreground;
    *TM_COMMIT = 1;
}

void set_tilemap_line( unsigned char tile_number, unsigned char tile_line_number, unsigned short tile_line_bitmap)
{
    while( *TM_STATUS != 0 );

    *TM_WRITER_TILE_NUMBER = tile_number;
    *TM_WRITER_LINE_NUMBER = tile_line_number;
    *TM_WRITER_BITMAP = tile_line_bitmap;
}

void tilemap_scrollwrapclear( unsigned char action )
{
    while( *TM_STATUS != 0 );

    *TM_SCROLLWRAPCLEAR = action;
}

void wait_gpu( void )
{
    while( *GPU_STATUS != 0 );
}

void gpu_pixel( unsigned char colour, short x, short y )
{
    wait_gpu();

    *GPU_COLOUR = colour;
    *GPU_X = x;
    *GPU_Y = y;
    *GPU_WRITE = 1;
}

void gpu_rectangle( unsigned char colour, short x1, short y1, short x2, short y2 )
{
    wait_gpu();

    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;
    *GPU_WRITE = 2;
}

void gpu_cs( void )
{
    gpu_rectangle( 64, 0, 0, 639, 479 );
}

void gpu_line( unsigned char colour, short x1, short y1, short x2, short y2 )
{
    wait_gpu();

    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;
    *GPU_WRITE = 3;
}

void gpu_circle( unsigned char colour, short x1, short y1, short radius )
{
    wait_gpu();

    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = radius;
    *GPU_WRITE = 4;
}

void gpu_fillcircle( unsigned char colour, short x1, short y1, short radius )
{
    wait_gpu();

    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = radius;
    *GPU_WRITE = 6;
}

void gpu_triangle( unsigned char colour, short x1, short y1, short x2, short y2, short x3, short y3 )
{
    wait_gpu();

    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;
    *GPU_PARAM2 = x3;
    *GPU_PARAM3 = y3;
    *GPU_WRITE = 7;
}

void draw_vector_block( unsigned char block, unsigned char colour, short xc, short yc )
{
    while( *VECTOR_DRAW_STATUS != 0 );

    *VECTOR_DRAW_BLOCK = block;
    *VECTOR_DRAW_COLOUR = colour;
    *VECTOR_DRAW_XC = xc;
    *VECTOR_DRAW_YC = yc;
    *VECTOR_DRAW_START = 1;
}

void set_vector_vertex( unsigned char block, unsigned char vertex, unsigned char active, char deltax, char deltay )
{
    *VECTOR_WRITER_BLOCK = block;
    *VECTOR_WRITER_VERTEX = vertex;
    *VECTOR_WRITER_ACTIVE = active;
    *VECTOR_WRITER_DELTAX = deltax;
    *VECTOR_WRITER_DELTAY = deltay;
}

void bitmap_scrollwrap( unsigned char action )
{
    wait_gpu();
    *BITMAP_SCROLLWRAP = action;
}

void set_sprite( unsigned char sprite_layer, unsigned char sprite_number, unsigned char active, unsigned char colour, short x, short y, unsigned char tile, unsigned char sprite_size)
{
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

unsigned short get_sprite_collision( unsigned char sprite_layer, unsigned char sprite_number )
{
    return( ( sprite_layer == 0 ) ? LOWER_SPRITE_COLLISION_BASE[sprite_number] : UPPER_SPRITE_COLLISION_BASE[sprite_number] );
}

short get_sprite_attribute( unsigned char sprite_layer, unsigned char sprite_number, unsigned char attribute )
{
    if( sprite_layer == 0 ) {
        *LOWER_SPRITE_NUMBER = sprite_number;
        switch( attribute ) {
            case 0:
                return( (short)*LOWER_SPRITE_ACTIVE );
                break;
            case 1:
                return( (short)*LOWER_SPRITE_TILE );
                break;
            case 2:
                return( (short)*LOWER_SPRITE_COLOUR );
                break;
            case 3:
                return( *LOWER_SPRITE_X );
                break;
            case 4:
                return( *LOWER_SPRITE_Y );
                break;
            case 5:
                return( (short)*LOWER_SPRITE_DOUBLE );
                break;
        }
    } else {
        *UPPER_SPRITE_NUMBER = sprite_number;
        switch( attribute ) {
            case 0:
                return( (short)*UPPER_SPRITE_ACTIVE );
                break;
            case 1:
                return( (short)*UPPER_SPRITE_TILE );
                break;
            case 2:
                return( (short)*UPPER_SPRITE_COLOUR );
                break;
            case 3:
                return( *UPPER_SPRITE_X );
                break;
            case 4:
                return( *UPPER_SPRITE_Y );
                break;
            case 5:
                return( (short)*UPPER_SPRITE_DOUBLE );
                break;
        }
    }
}

void set_sprite_attribute( unsigned char sprite_layer, unsigned char sprite_number, unsigned char attribute, short value )
{
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

void update_sprite( unsigned char sprite_layer, unsigned char sprite_number, unsigned short update_flag )
{
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

void set_sprite_line( unsigned char sprite_layer, unsigned char sprite_number, unsigned char sprite_line_number, unsigned short sprite_line_bitmap)
{
    switch( sprite_layer ) {
        case 0:
            *LOWER_SPRITE_WRITER_NUMBER = sprite_number;
            *LOWER_SPRITE_WRITER_LINE = sprite_line_number;
            *LOWER_SPRITE_WRITER_BITMAP = sprite_line_bitmap;
            break;

        case 1:
            *UPPER_SPRITE_WRITER_NUMBER = sprite_number;
            *UPPER_SPRITE_WRITER_LINE = sprite_line_number;
            *UPPER_SPRITE_WRITER_BITMAP = sprite_line_bitmap;
            break;
    }
}

void tpu_cs( void )
{
    while( *TPU_COMMIT != 0 );
    *TPU_COMMIT = 3;
}

void tpu_set(  unsigned char x, unsigned char y, unsigned char background, unsigned char foreground )
{
    *TPU_X = x; *TPU_Y = y; *TPU_BACKGROUND = background; *TPU_FOREGROUND = foreground; *TPU_COMMIT = 1;
}

void tpu_output_character( char c ) {
    while( *TPU_COMMIT != 0 );
    *TPU_CHARACTER = c; *TPU_COMMIT = 2;
}

void tpu_outputstring( char *s )
{
    while( *s ) {
        while( *TPU_COMMIT != 0 );
        *TPU_CHARACTER = *s; *TPU_COMMIT = 2;
        s++;
    }
}

void tpu_outputnumber_char( unsigned char value )
{
    char valuestring[]="000";
    unsigned char valuework = value, remainder;

    for( int i = 0; i < 2; i++ ) {
        remainder = valuework % 10;
        valuework = valuework / 10;

        valuestring[2 - i] = remainder + '0';
    }

    tpu_outputstring( valuestring );
}

void tpu_outputnumber_short( unsigned short value )
{
    char valuestring[]="00000";
    unsigned short valuework = value, remainder;

    for( int i = 0; i < 4; i++ ) {
        remainder = valuework % 10;
        valuework = valuework / 10;

        valuestring[4 - i] = remainder + '0';
    }

    tpu_outputstring( valuestring );
}

void tpu_outputnumber_int( unsigned int value )
{
    char valuestring[]="0000000000";
    unsigned int valuework = value, remainder;

    for( int i = 0; i < 9; i++ ) {
        remainder = valuework % 10;
        valuework = valuework / 10;

        valuestring[9 - i] = remainder + '0';
    }

    tpu_outputstring( valuestring );
}

// MACROS
// Convert asteroid number to sprite layer and number
#define ASN(a) ( a > 9) ? 1 : 0, ( a > 9) ? a - 10 : a
#define MAXASTEROIDS 20

    // GLOBAL VARIABLES
    unsigned short lives = 0, score = 0, level = 0;
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
        0x1c02, 0x1c1e, 0x1c04, 0x1c1c
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
    unsigned short ship_bitmap[] = {
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

void set_asteroid_sprites( void )
{
    for( unsigned char asteroid_number = 0; asteroid_number < MAXASTEROIDS; asteroid_number++ ) {
        for( unsigned char line_number = 0; line_number < 128; line_number++ ) {
            set_sprite_line( ASN(asteroid_number), line_number, asteroid_bitmap[line_number] );
        }
    }
}

void set_ship_sprites( unsigned char exploding )
{
    for( unsigned char line_number = 0; line_number < 128; line_number++ ) {
        set_sprite_line( 0, 11, line_number, ship_bitmap[line_number + ( exploding ? 128 : 0 )] );
        set_sprite_line( 1, 11, line_number, ship_bitmap[line_number + ( exploding ? 128 : 0 )] );
    }
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
    for( unsigned char line_number = 0; line_number < 128; line_number++ ) {
        set_sprite_line( 0, 12, line_number, bullet_bitmap[line_number] );
        set_sprite_line( 1, 12, line_number, bullet_bitmap[line_number] );
    }
}

void set_ufo_sprite( unsigned char ufo_asteroid ) {
    for( unsigned char line_number = 0; line_number < 128; line_number++ ) {
        set_sprite_line( ASN( ufo_sprite_number ), line_number, ufo_asteroid ? ufo_bitmap[line_number] : asteroid_bitmap[line_number] );
    }
}

void set_ufo_bullet_sprites( void ) {
    for( unsigned char line_number = 0; line_number < 128; line_number++ ) {
        set_sprite_line( 0, 10, line_number, ufo_bullet_bitmap[line_number] );
        set_sprite_line( 1, 10, line_number, ufo_bullet_bitmap[line_number] );
    }
}

void set_tilemap( void )
{
    tilemap_scrollwrapclear( 9 );

    for( unsigned char tile_number = 0; tile_number < 8; tile_number++ ) {
        for( unsigned char line_number = 0; line_number < 16; line_number++ ) {
            set_tilemap_line( tile_number + 1, line_number, tilemap_bitmap[ tile_number * 16 + line_number ] );
        }
    }

    set_tilemap_tile( 4, 4, 1, 64, 21 ); set_tilemap_tile( 4, 5, 2, 64, 21 ); set_tilemap_tile( 5, 4, 3, 64, 21 ); set_tilemap_tile( 5, 5, 4, 64, 21 );
    set_tilemap_tile( 18, 14, 1, 64, 20 ); set_tilemap_tile( 18, 15, 2, 64, 20 ); set_tilemap_tile( 19, 14, 3, 64, 20 ); set_tilemap_tile( 19, 15, 4, 64, 20 );
    set_tilemap_tile( 34, 28, 1, 64, 5 ); set_tilemap_tile( 34, 29, 2, 64, 5 ); set_tilemap_tile( 35, 28, 3, 64, 5 ); set_tilemap_tile( 35, 29, 4, 64, 5 );
    set_tilemap_tile( 36, 2, 5, 64, 42 ); set_tilemap_tile( 36, 3, 6, 64, 42 ); set_tilemap_tile( 37, 2, 7, 64, 42 ); set_tilemap_tile( 37, 3, 8, 64, 42 );
    set_tilemap_tile( 6, 26, 5, 64, 16 ); set_tilemap_tile( 6, 27, 6, 64, 16 ); set_tilemap_tile( 7, 26, 7, 64, 16 ); set_tilemap_tile( 7, 27, 8, 64, 16 );
}

void risc_ice_v_logo( void )
{
    // BITMAP CS + LOGO
    gpu_cs( );
    gpu_rectangle( 56, 0, 0, 100, 100 );
    gpu_triangle( 63, 100, 33, 100, 100, 50, 100 );
    gpu_triangle( 2, 100, 50, 100, 100, 66, 100 );
    gpu_rectangle( 2, 0, 0, 33, 50 );
    gpu_fillcircle( 63, 25, 25, 26 );
    gpu_rectangle( 63, 0, 0, 25, 12 );
    gpu_fillcircle( 2, 25, 25, 12 );
    gpu_triangle( 63, 0, 33, 67, 100, 0, 100 );
    gpu_triangle( 2, 0, 50, 50, 100, 0, 100 );
    gpu_rectangle( 2, 0, 12, 25, 37 );
    gpu_rectangle( 2, 0, 37, 8, 100 );
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

    // CLEAR and SET THE BACKGROUND
    gpu_cs();
    terminal_showhide( 0 );
    set_background( 42, 1, 7 );
    risc_ice_v_logo();

    tilemap_scrollwrapclear( 9 ); set_tilemap();

    tpu_cs();
    set_asteroid_sprites();
    set_ship_sprites( 0 );
    set_ship_vector();
    set_bullet_sprites();
    set_ufo_bullet_sprites();

    lives = 0; score = 0;
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

void move_asteroids( void )
{
    for( unsigned char asteroid_number = 0; asteroid_number < MAXASTEROIDS; asteroid_number++ ) {
        if( ( asteroid_active[asteroid_number] != 0 ) && ( asteroid_active[asteroid_number] < 3 ) ) {
            update_sprite( ASN( asteroid_number ), asteroid_directions[ asteroid_direction[asteroid_number] ] );
        }

        // UFO
        if(  asteroid_active[asteroid_number] == 3 ) {
            update_sprite( ASN( asteroid_number ), ufo_directions[ufo_leftright+ ( level > 2 ? 2 : 0 )] );
            if( get_sprite_attribute( ASN( asteroid_number), 0 ) == 0 ) {
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
            set_sprite( ASN( asteroid_number ), 0, 0, 0, 0, 0, 0 );
        }
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
    set_sprite( 0, 11, 1, colour, shipx, shipy, shipdirection, 0);
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
    tpu_set( 34, 1, 64, ( lives > 0 ) ? 63 : 21 ); tpu_outputstring( "Score " );
    tpu_outputnumber_short( score );

    tpu_set( 1, 28, 64, ( lives > 0 ) ? 63 : 21 ); tpu_outputstring( "Level " );
    tpu_outputnumber_short( level );
}

void draw_lives( void )
{
    switch( lives ) {
        case 3:
            draw_vector_block( 0, 63, 608, 464 );

        case 2:
            draw_vector_block( 0, 63, 576, 464 );

        case 1:
            draw_vector_block( 0, 63, 544, 464 );
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
    set_sprite( 0, 12, 1, 60, bulletx, bullety, 2, 0);
    set_sprite( 1, 12, 1, 48, bulletx, bullety, 0, 0);

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
    if( last_timer != *TIMER1HZ ) {
        draw_score();

        last_timer = *TIMER1HZ;

        tilemap_scrollwrapclear( 5 );

        switch( *TIMER1HZ & 3 ) {
            case 0:
                if( lives > 0 ) {
                    beep( 1, 0, 1, 500 );
                } else {
                    tpu_set( 16, 18, 64, 3 );
                    tpu_outputstring( "         Welcome to Risc-ICE-V Asteroids        " );
                }
                break;

            case 1:
                if( lives == 0 ) {
                    tpu_set( 16, 18, 64, 15 );
                    tpu_outputstring( "By @robng15 (Twitter) from Whitebridge, Scotland" );
                }
                break;

            case 2:
                if( lives > 0 ) {
                    beep( 1, 0, 2, 500 );
                } else {
                    tpu_set( 16, 18, 64, 60 );
                    tpu_outputstring( "                 Press UP to start              " );
                }
                break;

            case 3:
                // MOVE TILEMAP UP
                if( lives == 0 ) {
                    tpu_set( 16, 18, 64, 48 );
                    tpu_outputstring( "          Written in Silice by @sylefeb         " );
                }
                tilemap_scrollwrapclear( 6 );
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

        set_sprite( ASN( potentialnumber ), 1, rng( 31 ) + 32, xc + rng(16) - 8, yc + rng(16) - 8, rng( 7 ), ( asteroid_type == 2 ) ? 1 : 0 );
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

            colour = get_sprite_attribute( ASN( asteroid_hit ), 2 );
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

            set_sprite( ASN( asteroid_hit ), 1, colour, x, y, 7, spritesize );
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
                    set_sprite_attribute( ASN( asteroid_hit ), 2, 48 );
                    set_ufo_sprite( 0 );
                    ufo_sprite_number = 0xff;
                    asteroid_active[asteroid_hit] = 32;
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
        if( ( get_sprite_collision( 0, 10 ) & ( 0x800 ) != 0 ) || ( get_sprite_collision( 1, 10 ) & ( 0x800 ) != 0 ) ) {
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

void main()
{
    unsigned char uartData = 0, potentialnumber = 0;
    short ufo_x = 0, ufo_y = 0, potentialx = 0, potentialy = 0;
    unsigned short placeAsteroids = 4, asteroid_number = 0;

    // CLEAR the UART buffer
    while( *UART_STATUS & 1 )
        uartData = inputcharacter();

    setup_game();

    while(1) {
        counter++;

        // FLASH LEDS AND BEEP IF UFO ON SCREEN
        *LEDS = ( ufo_sprite_number != 0xff ) && ( counter & 32 ) ? 0xff : 0;
        if( ( ufo_sprite_number != 0xff ) && ( counter & 64 ) && ( lives != 0 ) ) {
            beep( 2, 3, 63, 32 );
        }

        // PLACE NEW LARGE ASTEROIDS
        if( placeAsteroids > 0 ) {
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
                set_sprite( ASN( potentialnumber), 1, rng( 31 ) + 32, potentialx, potentialy, rng( 7 ), 1 );
            }
            placeAsteroids--;
        }

        // NEW LEVEL NEEDED
        if( count_asteroids() == 0 ) {
            level++;
            placeAsteroids = 4 + ( ( level < 4 ) ? level : 4 );
        }

        // AWAIT VBLANK and SET DELAY
        await_vblank();
        set_timer1khz( 8 );

        // BEEP / BOOP
        beepboop();

        if( ( rng( 512 ) == 1 ) && ( ufo_sprite_number == 0xff ) && ( get_sprite_attribute( 0, 10, 0 ) == 0 ) ) {
            // START UFO
            ufo_sprite_number = find_asteroid_space();

            if( ufo_sprite_number != 0xff ) {
                // ROOM for UFO
                do {
                    ufo_y = 32 + rng(  416 );
                } while( ( ufo_y >= shipy - 64 ) && ( ufo_y <= shipy + 64 ) );

                ufo_leftright = rng( 2 );
                set_ufo_sprite( 1 );
                set_sprite( ASN( ufo_sprite_number ), 1, 19, ( ufo_leftright == 1 ) ? 639 : ( level < 2 ) ? -31 : -15, ufo_y, 0, ( level < 2 ) ? 1 : 0 );
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
            set_sprite( 0, 10, 1, 48, ufo_x, ufo_y, 0, 0 );
            set_sprite( 1, 10, 1, 60, ufo_x, ufo_y, 1, 0 );
        }

        if( ( lives > 0 ) && ( resetship == 0) ) {
            // GAME IN ACTION

            // EVERY 4th CYCLE
            if( ( counter & 3 ) == 0 ) {
                // TURN LEFT
                if( ( *BUTTONS & 32 ) != 0 )
                    shipdirection = ( shipdirection == 0 ) ? 7 : shipdirection - 1;
                // TURN RIGHT
                if( ( *BUTTONS & 64 ) != 0 )
                    shipdirection = ( shipdirection == 7 ) ? 0 : shipdirection + 1;
            }

            // EVERY CYCLE
            // FIRE?
            if( ( get_sprite_attribute( 0, 12, 0 ) == 0 ) && ( *BUTTONS & 2 ) != 0 )
                fire_bullet();

            // MOVE SHIP
            if( ( *BUTTONS & 4 ) != 0 )
                move_ship();

            // DRAW WHITE SHIP
            draw_ship( 63 );

            // CHECK IF CRASHED ASTEROID -> SHIP
            check_crash();
        } else {
            // GAME OVER OR EXPLODING SHIP
            // SEE IF NEW GAME
            if( ( lives == 0 ) && ( ( *BUTTONS & 8 ) != 0 ) ) {
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

                gpu_cs(); tpu_cs();
                counter = 0;
                lives = 3; score = 0; level = 0; placeAsteroids = 4;
                shipx = 312; shipy = 232; shipdirection = 0; resetship = 0; bulletdirection = 0;
                ufo_sprite_number = 0xff; ufo_leftright = 0;
                draw_lives();
                set_asteroid_sprites();
                set_ship_sprites(0);
                set_bullet_sprites();
                set_ufo_bullet_sprites();
            }

            if( ( ( resetship >= 1 ) && ( resetship <= 16 ) ) || ( lives == 0 ) ) {
                // DRAW GREY SHIP
                draw_ship( 21 );
                if( ( resetship >= 1 ) && ( resetship <= 16 ) ) {
                    if( ( ( get_sprite_collision( 0, 11 ) & 0x7ff ) == 0 ) && ( ( get_sprite_collision( 1, 11 ) & 0x7ff ) == 0 ) ) {
                        resetship--;
                        if( resetship == 0 ) {
                            gpu_cs();
                            lives--;
                            draw_lives();
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
                set_sprite_attribute( 0, 11, 2, ( counter & 1 ) ? 48 : 60 );
                set_sprite_attribute( 1, 11, 2, ( counter & 1 ) ? 60 : 48 );

                resetship--;
                if( resetship == 16 )
                    set_ship_sprites( 0 );
                    shipx = 312; shipy = 232; shipdirection = 0;
            }

            if( lives == 0 ) {
                // MOVE RISC-V LOGO
                bitmap_scrollwrap( 3 );
                bitmap_scrollwrap( 4 );
            }
        }

        // UPDATE BULLET
        update_bullet();

        // CHECK IF HIT BULLET -> ASTEROID
        check_hit();
        check_ufo_bullet_hit();

        // UPDATE ASTEROIDS
        move_asteroids();

        wait_timer1khz();
    }
}
