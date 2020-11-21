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

short volatile * GPU_X = (short volatile *) 0x8400;
short volatile * GPU_Y = (short volatile *) 0x8404;
unsigned char volatile * GPU_COLOUR = (unsigned char volatile *) 0x8408;
short volatile * GPU_PARAM0 = (short volatile *) 0x840C;
short volatile * GPU_PARAM1 = (short volatile *) 0x8410;
short volatile * GPU_PARAM2 = (short volatile *) 0x8414;
short volatile * GPU_PARAM3 = (short volatile *) 0x8418;
unsigned char volatile * GPU_WRITE = (unsigned char volatile *) 0x841C;
unsigned char volatile * GPU_STATUS = (unsigned char volatile *) 0x841C;

short volatile * LOWER_SPRITE_WRITER_NUMBER = ( short volatile * ) 0x8320;
short volatile * LOWER_SPRITE_WRITER_LINE = ( short volatile * ) 0x8324;
short volatile * LOWER_SPRITE_WRITER_BITMAP = ( short volatile * ) 0x8328;
short volatile * UPPER_SPRITE_WRITER_NUMBER = ( short volatile * ) 0x8520;
short volatile * UPPER_SPRITE_WRITER_LINE = ( short volatile * ) 0x8524;
short volatile * UPPER_SPRITE_WRITER_BITMAP = ( short volatile * ) 0x8528;

char inputcharacter(void)
{
	while( !(*UART_STATUS & 1) );
    return *UART_DATA;
}

void set_background( unsigned char colour, unsigned char altcolour, unsigned char backgroundmode )
{
    *BACKGROUND_COLOUR = colour;
    *BACKGROUND_ALTCOLOUR = altcolour;
    *BACKGROUND_MODE = backgroundmode;
}

void gpu_rectangle( unsigned char colour, short x1, short y1, short x2, short y2 )
{
    while( *GPU_STATUS != 0 );

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

void gpu_fillcircle( unsigned char colour, short x1, short y1, short radius )
{
    while( *GPU_STATUS != 0 );

    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = radius;
    *GPU_WRITE = 6;
}

void gpu_triangle( unsigned char colour, short x1, short y1, short x2, short y2, short x3, short y3 )
{
    while( *GPU_STATUS != 0 );

    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;
    *GPU_PARAM2 = x3;
    *GPU_PARAM3 = y3;
    *GPU_WRITE = 7;
}

void set_sprite_line( short sprite_layer, short sprite_number, short sprite_line_number, unsigned short sprite_line_bitmap)
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

    short shipx = 312, shipy = 232, shipdirection = 0, resetship = 0, bulletdirection = 0;

    short last_timer = 0;

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
        0x0380, 0x0540, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
    };

void set_asteroid_sprites( void )
{
    for( short asteroid_number = 0; asteroid_number < 12; asteroid_number++ ) {
        for( short line_number = 0; line_number < 128; line_number++ ) {
            set_sprite_line( 0, asteroid_number, line_number, asteroid_bitmap[line_number] );
            set_sprite_line( 1, asteroid_number, line_number, asteroid_bitmap[line_number] );
        }
    }
}

void set_ship_sprites( short exploding )
{
    for( short line_number = 0; line_number < 128; line_number++ ) {
        set_sprite_line( 0, 11, line_number, ship_bitmap[line_number + 128 * exploding] );
        set_sprite_line( 1, 11, line_number, ship_bitmap[line_number + 128 * exploding] );
    }
}

void set_bullet_sprites( void )
{
    for( short line_number = 0; line_number < 64; line_number++ ) {
        set_sprite_line( 0, 12, line_number, bullet_bitmap[line_number] );
        set_sprite_line( 0, 12, line_number, bullet_bitmap[line_number + 64] );
        set_sprite_line( 1, 12, line_number, bullet_bitmap[line_number] );
        set_sprite_line( 1, 12, line_number, bullet_bitmap[line_number + 64] );
    }
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
    // CLEAR and SET THE BACKGROUND
    gpu_cs();
    // tm_cs(); tpu_cs();
    // terminal_showhide(0);
    set_background( 42, 1, 7 );
    set_asteroid_sprites();
    set_ship_sprites( 0 );

    risc_ice_v_logo();
}

void main()
{
    unsigned char uartData = 0;

    // CLEAR the UART buffer
    while( *UART_STATUS & 1 )
        uartData = inputcharacter();

    setup_game();

    while(1) {
        if( ( lives > 0 ) && !resetship ) {
            // BEEP / BOOP
            // DRAW WHITE SHIP
            // UPDATE BULLET
            // CHECK IF HIT BULLET -> ASTEROID
            // CHECK IF CRASHED ASTEROID -> SHIP
        } else {
            // DRAW GREY SHIP
            // DELETE BULLET
        }
        // FIRE?
        // TURN/MOVE SHIP
        // UPDATE ASTEROIDS
    }
}
