#include "PAWS.h"

void outputcharacter(char c)
{
	while( *UART_STATUS & 2 );
    *UART_DATA = c;

    while( *TERMINAL_STATUS );
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
void outputnumber_char( unsigned char value )
{
    char valuestring[]="  0";
    unsigned char remainder, i = 0;

    while( value != 0 ) {
        remainder = value % 10;
        value = value / 10;

        valuestring[2 - i] = (char )remainder + '0';
        i++;
    }

    outputstringnonl( valuestring );
}
void outputnumber_short( unsigned short value )
{
    char valuestring[]="    0";
    unsigned short remainder, i = 0;

    while( value != 0 ) {
        remainder = value % 10;
        value = value / 10;

        valuestring[4 - i] = (char )remainder + '0';
        i++;
    }

    outputstringnonl( valuestring );
}
void outputnumber_int( unsigned int value )
{
    char valuestring[]="         0";
    unsigned int remainder, i = 0;

    while( value != 0 ) {
        remainder = value % 10;
        value = value / 10;

        valuestring[9 - i] = ( remainder > 9 ) ? '*' : (char )remainder + '0';
        i++;
    }

    outputstringnonl( valuestring );
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

void sleep( unsigned short counter )
{
    *SLEEPTIMER = counter;

    while( *SLEEPTIMER );
}
void set_timer1khz( unsigned short counter )
{
    *TIMER1KHZ = counter;
}

void wait_timer1khz( void )
{
    while( *TIMER1KHZ );
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

void gpu_blit( unsigned char colour, short x1, short y1, short tile )
{
    wait_gpu();

    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = tile;
    *GPU_WRITE = 5;

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

void set_blitter_bitmap( unsigned char tile, unsigned short *bitmap )
{
    *BLIT_WRITER_TILE = tile;

    for( int i = 0; i < 16; i ++ ) {
        *BLIT_WRITER_LINE = i;
        *BLIT_WRITER_BITMAP = bitmap[i];
    }
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
    char valuestring[]="  0";
    unsigned char remainder, i = 0;

    while( value != 0 ) {
        remainder = value % 10;
        value = value / 10;

        valuestring[2 - i] = (char )(remainder + '0');
        i++;
    }

    tpu_outputstring( valuestring );
}

void tpu_outputnumber_short( unsigned short value )
{
    char valuestring[]="    0";
    unsigned short remainder, i = 0;

    while( value != 0 ) {
        remainder = value % 10;
        value = value / 10;

        valuestring[4 - i] = (char )(remainder + '0');
        i++;
    }

    tpu_outputstring( valuestring );
}

void tpu_outputnumber_int( unsigned int value )
{
    char valuestring[]="         0";
    unsigned int remainder, i = 0;

    while( value != 0 ) {
        remainder = value % 10;
        value = value / 10;

        valuestring[9 - i] = ( remainder > 9 ) ? '*' : (char )remainder + '0';
        i++;
    }
    tpu_outputstring( valuestring );
}
