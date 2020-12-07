unsigned char volatile * UART_STATUS = (unsigned char volatile *) 0x8004;
unsigned char * UART_DATA = (unsigned char *) 0x8000;
unsigned char volatile * BUTTONS = (unsigned char volatile *) 0x8008;
unsigned char volatile * LEDS = (unsigned char volatile *) 0x800c;

unsigned char volatile * SDCARD_READY = (unsigned char volatile *) 0x8f00;
unsigned char volatile * SDCARD_START = (unsigned char volatile *) 0x8f00;
unsigned short volatile * SDCARD_SECTOR_LOW = ( unsigned short *) 0x8f08;
unsigned short volatile * SDCARD_SECTOR_HIGH = ( unsigned short *) 0x8f04;
unsigned char volatile * SDCARD_ADDRESS = (unsigned char volatile *) 0x8f10;
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

void outputcharacter(char c)
{
	while( (*UART_STATUS & 2) != 0 );
    *UART_DATA = c;

    while( *TERMINAL_STATUS != 0 );
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

char inputcharacter(void)
{
	while( !(*UART_STATUS & 1) );
    return *UART_DATA;
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

void tpu_cs( void )
{
    while( *TPU_COMMIT != 0 );
    *TPU_COMMIT = 3;
}

void tpu_outputstring( unsigned char x, unsigned char y, unsigned char background, unsigned char foreground, char *s )
{
    *TPU_X = x; *TPU_Y = y; *TPU_BACKGROUND = background; *TPU_FOREGROUND = foreground; *TPU_COMMIT = 1;

    while( *s ) {
        while( *TPU_COMMIT != 0 );
        *TPU_CHARACTER = *s; *TPU_COMMIT = 2;
        s++;
    }
}

// FAT16 FILE SYSTEM
// https://codeandlife.com/2012/04/02/simple-fat-and-sd-tutorial-part-1/ USED AS REFERENCE

typedef struct {
    unsigned char first_byte;
    unsigned char start_chs[3];
    unsigned char partition_type;
    unsigned char end_chs[3];
    unsigned long start_sector;
    unsigned long length_sectors;
} __attribute((packed)) PartitionTable;

typedef struct {
    unsigned char jmp[3];
    char oem[8];
    unsigned short sector_size;
    unsigned char sectors_per_cluster;
    unsigned short reserved_sectors;
    unsigned char number_of_fats;
    unsigned short root_dir_entries;
    unsigned short total_sectors_short; // if zero, later field is used
    unsigned char media_descriptor;
    unsigned short fat_size_sectors;
    unsigned short sectors_per_track;
    unsigned short number_of_heads;
    unsigned long hidden_sectors;
    unsigned long total_sectors_long;

    unsigned char drive_number;
    unsigned char current_head;
    unsigned char boot_signature;
    unsigned long volume_id;
    char volume_label[11];
    char fs_type[8];
    char boot_code[448];
    unsigned short boot_sector_signature;
} __attribute((packed)) Fat16BootSector;

typedef struct {
    unsigned char filename[8];
    unsigned char ext[3];
    unsigned char attributes;
    unsigned char reserved[10];
    unsigned short modify_time;
    unsigned short modify_date;
    unsigned short starting_cluster;
    unsigned long file_size;
} __attribute((packed)) Fat16Entry;

void main()
{
    unsigned char uartData = 0;
    // CLEAR the UART buffer
    while( *UART_STATUS & 1 )
        uartData = inputcharacter();

    gpu_cs();
    tpu_cs();

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

    tpu_outputstring(0, 8, 0x40, 0x3f, "Welcome to RISC-ICE-V a RISC-V RV32IMC CPU");

    tpu_outputstring(0, 10, 0x40, 0x30, "Waiting for SDCARD");

    while( *SDCARD_READY == 0 );

    tpu_outputstring(0, 10, 0x40, 0x0c, "SCARD Detected    ");
    tpu_outputstring(0, 11, 0x40, 0x03, "Reading Partition Table");

    while(1) {
        uartData = inputcharacter();
        outputstringnonl("You pressed : ");
        outputcharacter( uartData );
        outputstring(" <-");
        *LEDS = uartData;
    }
}
