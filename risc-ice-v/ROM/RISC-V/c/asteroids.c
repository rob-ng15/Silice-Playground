unsigned char volatile * UART_STATUS = (unsigned char volatile *) 0x8004;
unsigned char * UART_DATA = (unsigned char *) 0x8000;
unsigned char volatile * BUTTONS = (unsigned char volatile *) 0x8008;
unsigned char volatile * LEDS = (unsigned char volatile *) 0x800c;

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

unsigned char volatile * VECTOR_WRITER_BLOCK = (unsigned char volatile *) 0x8434;
unsigned char volatile * VECTOR_WRITER_VERTEX = (unsigned char volatile *) 0x8438;
unsigned char volatile * VECTOR_WRITER_ACTIVE = (unsigned char volatile *) 0x8444;
char volatile * VECTOR_WRITER_DELTAX = (char volatile *) 0x843c;
char volatile * VECTOR_WRITER_DELTAY = (char volatile *) 0x8440;
unsigned char volatile * VECTOR_WRITER_COMMIT = (unsigned char volatile *) 0x8448;

unsigned char volatile * LOWER_SPRITE_NUMBER = ( unsigned char volatile * ) 0x8300;
unsigned char volatile * LOWER_SPRITE_ACTIVE = ( unsigned char volatile * ) 0x8304;
unsigned char volatile * LOWER_SPRITE_TILE = ( unsigned char volatile * ) 0x8308;
unsigned char volatile * LOWER_SPRITE_COLOUR = ( unsigned char volatile * ) 0x830c;
short volatile * LOWER_SPRITE_X = ( short volatile * ) 0x8310;
short volatile * LOWER_SPRITE_Y = ( short volatile * ) 0x8314;
unsigned char volatile * LOWER_SPRITE_DOUBLE = ( unsigned char volatile * ) 0x8318;
unsigned char volatile * LOWER_SPRITE_UPDATE = ( unsigned char volatile * ) 0x831c;
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
unsigned char volatile * UPPER_SPRITE_UPDATE = ( unsigned char volatile * ) 0x851c;
unsigned char volatile * UPPER_SPRITE_WRITER_NUMBER = ( unsigned char volatile * ) 0x8520;
unsigned char volatile * UPPER_SPRITE_WRITER_LINE = ( unsigned char volatile * ) 0x8524;
unsigned short volatile * UPPER_SPRITE_WRITER_BITMAP = ( unsigned short volatile * ) 0x8528;
unsigned short volatile * UPPER_SPRITE_COLLISION_BASE = ( unsigned short volatile * ) 0x8530;

unsigned char volatile * AUDIO_L_WAVEFORM = ( unsigned char volatile * ) 0x8800;
unsigned char volatile * AUDIO_L_NOTE = ( unsigned char volatile * ) 0x8804;
unsigned short volatile * AUDIO_L_DURATION = ( unsigned short volatile * ) 0x8808;
unsigned char volatile * AUDIO_L_START = ( unsigned char volatile * ) 0x880c;
unsigned char volatile * AUDIO_R_WAVEFORM = ( unsigned char volatile * ) 0x8810;
unsigned char volatile * AUDIO_R_NOTE = ( unsigned char volatile * ) 0x8814;
unsigned short volatile * AUDIO_R_DURATION = ( unsigned short volatile * ) 0x8818;
unsigned char volatile * AUDIO_R_START = ( unsigned char volatile * ) 0x881c;

short volatile * RNG = ( short volatile * ) 0x8900;
short volatile * TIMER1HZ = ( short volatile * ) 0x8910;
short volatile * TIMER1KHZ = ( short volatile * ) 0x8920;
short volatile * SLEEPTIMER = ( short volatile * ) 0x8930;

unsigned char volatile * VBLANK = ( unsigned char volatile * ) 0x8ff0;

char inputcharacter(void)
{
	while( !(*UART_STATUS & 1) );
    return *UART_DATA;
}

short rng( short range )
{
    return( *RNG % range );
}

void set_timer1khz( short counter )
{
    *TIMER1KHZ = counter;
}

void wait_timer1khz( void )
{
    while( *TIMER1KHZ != 0 );
}

void beep( unsigned char channel_number, unsigned char channel_note, unsigned char waveform, unsigned char note, unsigned short duration )
{
    if( ( channel_number & 1 ) != 0 ) {
        *AUDIO_L_WAVEFORM = waveform;
        *AUDIO_L_NOTE = note;
        *AUDIO_L_DURATION = duration;
        *AUDIO_L_START = channel_note;
    }
    if( ( channel_number & 2 ) != 0 ) {
        *AUDIO_R_WAVEFORM = waveform;
        *AUDIO_R_NOTE = note;
        *AUDIO_R_DURATION = duration;
        *AUDIO_R_START = channel_note;
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
    *TM_X = x;
    *TM_Y = y;
    *TM_TILE = tile;
    *TM_BACKGROUND = background;
    *TM_FOREGROUND = foreground;
    *TM_COMMIT = 1;
}

void set_tilemap_line( unsigned char tile_number, unsigned char tile_line_number, unsigned short tile_line_bitmap)
{
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
    while( *VECTOR_DRAW_START != 0);

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
    *VECTOR_WRITER_COMMIT = 1;
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

unsigned short get_sprite_attribute( unsigned char sprite_layer, unsigned char sprite_number, unsigned char attribute )
{
    if( sprite_layer == 0 ) {
        *LOWER_SPRITE_NUMBER = sprite_number;
        switch( attribute ) {
            case 0:
                return( (unsigned short)*LOWER_SPRITE_ACTIVE );
                break;
            case 1:
                return( (unsigned short)*LOWER_SPRITE_TILE );
                break;
            case 2:
                return( (unsigned short)*LOWER_SPRITE_COLOUR );
                break;
            case 3:
                return( *LOWER_SPRITE_X );
                break;
            case 4:
                return( *LOWER_SPRITE_Y );
                break;
            case 5:
                return( (unsigned short)*LOWER_SPRITE_DOUBLE );
                break;
        }
    } else {
        *UPPER_SPRITE_NUMBER = sprite_number;
        switch( attribute ) {
            case 0:
                return( (unsigned short)*UPPER_SPRITE_ACTIVE );
                break;
            case 1:
                return( (unsigned short)*UPPER_SPRITE_TILE );
                break;
            case 2:
                return( (unsigned short)*UPPER_SPRITE_COLOUR );
                break;
            case 3:
                return( *UPPER_SPRITE_X );
                break;
            case 4:
                return( *UPPER_SPRITE_Y );
                break;
            case 5:
                return( (unsigned short)*UPPER_SPRITE_DOUBLE );
                break;
        }
    }
}

void update_sprite( unsigned char sprite_layer, unsigned char sprite_number, short update_flag )
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

    // GLOBAL VARIABLES
    int lives = 0, score = 0;
    int counter = 0;

    // SHIP and BULLET
    short shipx = 312, shipy = 232, shipdirection = 0, resetship = 0, bulletdirection = 0;

    // ASTEROIDS
    unsigned char asteroid_active[22], asteroid_direction[22];

    // BEEP / BOOP TIMER
    short last_timer = 0;

    // GLOBAL SPRITE UPDATE VALUES
    unsigned short bullet_directions[] = {
        0x1a0, 0x1b2, 0x183, 0x192, 0x198, 0x196, 0x184, 0x1b6
    };

    unsigned short asteroid_directions[] = {
        0x39, 0x9, 0xf, 0x3f, 0x31, 0x3a, 0xa, 0x11, 0x17, 0xe, 0x3e, 0x37
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
    for( short asteroid_number = 0; asteroid_number < 12; asteroid_number++ ) {
        for( unsigned char line_number = 0; line_number < 128; line_number++ ) {
            set_sprite_line( 0, asteroid_number, line_number, asteroid_bitmap[line_number] );
            set_sprite_line( 1, asteroid_number, line_number, asteroid_bitmap[line_number] );
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
        if( sprite_number < 22 ) {
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

    //tpu_cs();
    set_asteroid_sprites();
    set_ship_sprites( 0 );
    set_ship_vector();
    set_bullet_sprites();

    lives = 0; score = 0;
    shipx = 312; shipy = 232; shipdirection = 0; resetship = 0; bulletdirection = 0;

    counter = 0;
}

unsigned char find_asteroid_space( void ) {
    unsigned char asteroid_space = 0xff;

    for( unsigned char asteroid_number = 0; asteroid_number < 22; asteroid_number++ ) {
        asteroid_space = ( asteroid_active[asteroid_number] == 0 ) ? asteroid_number : asteroid_space;
    }

    return( asteroid_space );
}

void new_asteroid( unsigned char asteroid_type )
{
    unsigned char potentialnumber, potentialx, potentialy;

    potentialnumber = find_asteroid_space();
    if( potentialnumber != 0xff ) {
        do {
            potentialx = rng( 640 );
            potentialy = rng( 480 );
        } while( ( potentialx >= shipx - 64 ) && ( potentialx <= shipx + 64 ) && ( potentialy >= shipy - 64 ) && ( potentialy <= shipy + 64) );

        asteroid_active[ potentialnumber ] = asteroid_type;
        asteroid_direction[ potentialnumber ] = rng( ( asteroid_type == 2 ) ? 4 : 8 );

        set_sprite( ( potentialnumber > 10 ) ? 1 : 0, ( potentialnumber > 10 ) ? potentialnumber - 11 : potentialnumber, 1, rng( 32 ) + 32, potentialx, potentialy, rng( 7 ), ( asteroid_type == 2 ) ? 1 : 0 );
    }
}

void new_level( void )
{
    unsigned char number_of_asteroids;
    unsigned char asteroid_number;

    // CLEAR ASTEROIDS
    for( asteroid_number = 0; asteroid_number < 22; asteroid_number++ ) {
        asteroid_active[asteroid_number] = 0; asteroid_direction[asteroid_number] = 0;
        set_sprite( 0, asteroid_number, 0, 0, 0, 0, 0, 0);
        set_sprite( 1, asteroid_number, 0, 0, 0, 0, 0, 0);
    }

    // PLACE NEW LARGE ASTEROIDS
    number_of_asteroids = rng( 4 ) + 4;
    for( asteroid_number = 0; asteroid_number < number_of_asteroids; asteroid_number++ ) {
        new_asteroid( 2 );
    }
}

void move_asteroids( void )
{
    for( unsigned char asteroid_number = 0; asteroid_number < 22; asteroid_number++ ) {
        if( asteroid_active[asteroid_number] != 0 ) {
            update_sprite( ( asteroid_number > 10) ? 1 : 0, ( asteroid_number > 10) ? asteroid_number - 11 : asteroid_number, asteroid_directions[ asteroid_direction[asteroid_number] ] );
        }
    }
}

unsigned short count_asteroids( void )
{
    short number_of_asteroids = 0;

    for( unsigned char asteroid_number = 0; asteroid_number < 22; asteroid_number++ ) {
        if( asteroid_active[asteroid_number] != 0 ) {
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

    beep( 3, 2, 4, 61, 128 );
}

void update_bullet( void )
{
    update_sprite( 0, 12, bullet_directions[ bulletdirection ] );
    update_sprite( 1, 12, bullet_directions[ bulletdirection ] );
}

void beepboop( void )
{
    if( last_timer != *TIMER1HZ ) {
        last_timer = *TIMER1HZ;

        tilemap_scrollwrapclear( 5 );

        switch( *TIMER1HZ & 3 ) {
            case 0:
                if( lives > 0 )
                    beep( 1, 1, 0, 1, 500 );
                break;

            case 1:
                break;

            case 2:
                if( lives > 0 )
                    beep( 2, 1, 0, 2, 500 );
                break;

            case 3:
                // MOVE TILEMAP UP
                tilemap_scrollwrapclear( 6 );
                break;
        }
    }
}

void check_crash( void )
{
    if( ( ( get_sprite_collision( 0, 11 ) & 0x7ff ) != 0 ) || ( ( get_sprite_collision( 1, 11 ) & 0x7ff ) != 0 ) ) {
        set_ship_sprites( 1 );
        resetship = 32;
    }
}

void main()
{
    unsigned char uartData = 0;

    // CLEAR the UART buffer
    while( *UART_STATUS & 1 )
        uartData = inputcharacter();

    setup_game();

    while(1) {
        counter++;
        *LEDS = *BUTTONS;

        // NEW LEVEL NEEDED
        if( count_asteroids() == 0 ) {
            new_level();
        }

        // AWAIT VBLANK and SET DELAY
        await_vblank();
        set_timer1khz( 4 );

        // BEEP / BOOP
        beepboop();

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
            if( ( *BUTTONS & 8 ) != 0 )
                move_ship();

            // DRAW WHITE SHIP
            draw_ship( 63 );

            // UPDATE BULLET
            update_bullet();

            // CHECK IF HIT BULLET -> ASTEROID
            // CHECK IF CRASHED ASTEROID -> SHIP
        } else {
            // GAME OVER OR EXPLODING SHIP
            // SEE IF NEW GAME
            if( ( lives == 0 ) && ( ( *BUTTONS & 4 ) != 0 ) ) {
                gpu_cs();
                counter = 0;
                lives = 3; score = 0;
                shipx = 312; shipy = 232; shipdirection = 0; resetship = 0; bulletdirection = 0;
                draw_lives();
                new_level();
            }

            if( ( ( resetship > 1 ) && ( resetship <= 16 ) ) || ( lives == 0 ) ) {
                // DRAW GREY SHIP
                draw_ship( 21 );
                if( ( resetship > 1 ) && ( resetship <= 16 ) ) {
                    if( ( ( get_sprite_collision( 0, 11 ) & 0x7ff ) == 0 ) && ( ( get_sprite_collision( 1, 11 ) & 0x7ff ) == 0 ) ) {
                        lives--;
                        resetship--;

                        gpu_cs();
                        if( lives == 0 )
                            risc_ice_v_logo();

                        draw_lives();
                    }
                }
            }

            if( resetship > 16 ) {
                // EXPLODING SHIP
                update_sprite( 0, 11, 0xe000 );
                update_sprite( 1, 11, 0xf840 );

                resetship--;
                if( resetship == 16 )
                    set_ship_sprites( 0 );
            }

            // DELETE BULLET
            set_sprite( 0, 12, 0, 0, 0, 0, 0, 0);
            set_sprite( 1, 12, 0, 0, 0, 0, 0, 0);
        }

        // UPDATE ASTEROIDS
        move_asteroids();

        wait_timer1khz();
    }
}
