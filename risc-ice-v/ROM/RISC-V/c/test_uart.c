short volatile * UART_STATUS = (short volatile *) 0x8004;
unsigned char * UART_DATA = (unsigned char *) 0x8000;
short volatile * BUTTONS = (short volatile *) 0x8008;
short volatile * LEDS = (short volatile *) 0x800c;

unsigned char * TERMINAL_OUTPUT = (unsigned char *) 0x8700;
short volatile * TERMINAL_SHOWHIDE = (short volatile *) 0x8704;
short volatile * TERMINAL_STATUS = (short volatile *) 0x8700;

short volatile * BACKGROUND_COLOUR = (short volatile *) 0x8100;
short volatile * BACKGROUND_ALTCOLOUR = (short volatile *) 0x8104;
short volatile * BACKGROUND_MODE = (short volatile *) 0x8108;

short volatile * GPU_X = (short volatile *) 0x8400;
short volatile * GPU_Y = (short volatile *) 0x8404;
short volatile * GPU_COLOUR = (short volatile *) 0x8408;
short volatile * GPU_PARAM0 = (short volatile *) 0x840C;
short volatile * GPU_PARAM1 = (short volatile *) 0x8410;
short volatile * GPU_PARAM2 = (short volatile *) 0x8414;
short volatile * GPU_PARAM3 = (short volatile *) 0x8418;
short volatile * GPU_WRITE = (short volatile *) 0x841C;
short volatile * GPU_STATUS = (short volatile *) 0x841C;

void outputcharacter(char c)
{
	while( (*UART_STATUS & 2) != 0 );
    *UART_DATA = c;
    *TERMINAL_OUTPUT = c;
	if (c == '\n')
		outputcharacter(10);
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

char inputcharacter(void)
{
	while( !(*UART_STATUS & 1) );
    return *UART_DATA;
}

void gpu_rectangle( short colour, short x1, short y1, short x2, short y2 )
{
    while( *GPU_STATUS );

    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;
    *GPU_WRITE = 2;
}

void gpu_fillcircle( short colour, short x1, short y1, short radius )
{
    while( *GPU_STATUS );

    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = radius;
    *GPU_WRITE = 6;
}

void gpu_triangle( short colour, short x1, short y1, short x2, short y2, short x3, short y3 )
{
    while( *GPU_STATUS );

    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;
    *GPU_PARAM2 = x3;
    *GPU_PARAM3 = y3;
    *GPU_WRITE = 7;
}

void main()
{
    unsigned char uartData = 0;

    //char i = 0;
    //outputstring("Welcome to RISC-ICE-V a RISC-V RV32I CPU");
    //outputstringnonl("> ");

    //for( i = 32; i < 128; i++ )
    //    outputcharacter( i );

    // BITMAP CS + LOGO
    gpu_rectangle( 64, 0, 0, 639, 479 );
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

    while(1) {
        uartData = inputcharacter();
        outputcharacter( uartData );
        *LEDS = uartData;
    }
}
