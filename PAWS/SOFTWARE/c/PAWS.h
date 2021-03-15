// I/O MEMORY MAPPED REGISTER DEFINITIONS
unsigned char volatile * UART_STATUS = (unsigned char volatile *) 0x8004;
unsigned char volatile * UART_DATA = (unsigned char volatile *) 0x8000;
unsigned char volatile * BUTTONS = (unsigned char volatile *) 0x8008;
unsigned char volatile * LEDS = (unsigned char volatile *) 0x800c;
unsigned short volatile * SYSTEMCLOCK = (unsigned short volatile *) 0x8010;

// PS/2 KEYBOARD
unsigned char volatile * PS2_AVAILABLE = (unsigned char volatile *) 0x8040;
unsigned char volatile * PS2_DATA = (unsigned char volatile *) 0x8044;

// SDCARD
unsigned char volatile * SDCARD_READY = (unsigned char volatile *) 0x8f00;
unsigned char volatile * SDCARD_START = (unsigned char volatile *) 0x8f00;
unsigned short volatile * SDCARD_SECTOR_LOW = ( unsigned short *) 0x8f08;
unsigned short volatile * SDCARD_SECTOR_HIGH = ( unsigned short *) 0x8f04;
unsigned short volatile * SDCARD_ADDRESS = (unsigned short volatile *) 0x8f10;
unsigned char volatile * SDCARD_DATA = (unsigned char volatile *) 0x8f10;

// DISPLAY UNITS

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
unsigned char volatile * GPU_COLOUR_ALT = (unsigned char volatile *) 0x8409;
unsigned char volatile * GPU_DITHERMODE = (unsigned char volatile *) 0x840A;
short volatile * GPU_PARAM0 = (short volatile *) 0x840C;
short volatile * GPU_PARAM1 = (short volatile *) 0x8410;
short volatile * GPU_PARAM2 = (short volatile *) 0x8414;
short volatile * GPU_PARAM3 = (short volatile *) 0x8418;
unsigned char volatile * GPU_WRITE = (unsigned char volatile *) 0x841C;
unsigned char volatile * GPU_STATUS = (unsigned char volatile *) 0x841C;

unsigned char volatile * BLIT_WRITER_TILE = (unsigned char volatile *) 0x8450;
unsigned char volatile * BLIT_WRITER_LINE = (unsigned char volatile *) 0x8454;
unsigned short volatile * BLIT_WRITER_BITMAP = (unsigned short volatile *) 0x8458;

unsigned char volatile * VECTOR_DRAW_BLOCK = (unsigned char volatile *) 0x8420;
unsigned char volatile * VECTOR_DRAW_COLOUR = (unsigned char volatile *) 0x8424;
short volatile * VECTOR_DRAW_XC = (short volatile *) 0x8428;
short volatile * VECTOR_DRAW_YC = (short volatile *) 0x842c;
unsigned char volatile * VECTOR_DRAW_SCALE = (unsigned char volatile *) 0x842e;
unsigned char volatile * VECTOR_DRAW_START = (unsigned char volatile *) 0x8430;
unsigned char volatile * VECTOR_DRAW_STATUS = (unsigned char volatile *) 0x8448;

unsigned char volatile * VECTOR_WRITER_BLOCK = (unsigned char volatile *) 0x8434;
unsigned char volatile * VECTOR_WRITER_VERTEX = (unsigned char volatile *) 0x8438;
unsigned char volatile * VECTOR_WRITER_ACTIVE = (unsigned char volatile *) 0x8444;
char volatile * VECTOR_WRITER_DELTAX = (char volatile *) 0x843c;
char volatile * VECTOR_WRITER_DELTAY = (char volatile *) 0x8440;

unsigned char volatile * BITMAP_SCROLLWRAP = (unsigned char volatile *) 0x8460;
unsigned short volatile * BITMAP_PIXEL_READ = (unsigned short volatile *) 0x8470;
unsigned short volatile * BITMAP_X_READ = (unsigned short volatile *) 0x8470;
unsigned short volatile * BITMAP_Y_READ = (unsigned short volatile *) 0x8474;

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
unsigned char volatile * LOWER_SPRITE_NUMBER_SMT = ( unsigned char volatile * ) 0x9300;
unsigned char volatile * LOWER_SPRITE_ACTIVE_SMT = ( unsigned char volatile * ) 0x9304;
unsigned char volatile * LOWER_SPRITE_TILE_SMT = ( unsigned char volatile * ) 0x9308;
unsigned char volatile * LOWER_SPRITE_COLOUR_SMT = ( unsigned char volatile * ) 0x930c;
short volatile * LOWER_SPRITE_X_SMT = ( short volatile * ) 0x9310;
short volatile * LOWER_SPRITE_Y_SMT = ( short volatile * ) 0x9314;
unsigned char volatile * LOWER_SPRITE_DOUBLE_SMT = ( unsigned char volatile * ) 0x9318;
unsigned short volatile * LOWER_SPRITE_UPDATE_SMT = ( unsigned short volatile * ) 0x931c;

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
unsigned char volatile * UPPER_SPRITE_NUMBER_SMT = ( unsigned char volatile * ) 0x9500;
unsigned char volatile * UPPER_SPRITE_ACTIVE_SMT = ( unsigned char volatile * ) 0x9504;
unsigned char volatile * UPPER_SPRITE_TILE_SMT = ( unsigned char volatile * ) 0x9508;
unsigned char volatile * UPPER_SPRITE_COLOUR_SMT = ( unsigned char volatile * ) 0x950c;
short volatile * UPPER_SPRITE_X_SMT = ( short volatile * ) 0x9510;
short volatile * UPPER_SPRITE_Y_SMT = ( short volatile * ) 0x9514;
unsigned char volatile * UPPER_SPRITE_DOUBLE_SMT = ( unsigned char volatile * ) 0x9518;
unsigned short volatile * UPPER_SPRITE_UPDATE_SMT = ( unsigned short volatile * ) 0x951c;

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
unsigned short volatile * TIMER1HZ0 = ( unsigned short volatile * ) 0x8910;
unsigned short volatile * TIMER1KHZ0 = ( unsigned short volatile * ) 0x8920;
unsigned short volatile * SLEEPTIMER0 = ( unsigned short volatile * ) 0x8930;
unsigned short volatile * TIMER1HZ1 = ( unsigned short volatile * ) 0x8914;
unsigned short volatile * TIMER1KHZ1 = ( unsigned short volatile * ) 0x8924;
unsigned short volatile * SLEEPTIMER1 = ( unsigned short volatile * ) 0x8934;

unsigned char volatile * VBLANK = ( unsigned char volatile * ) 0x8ff0;
unsigned char volatile * SCREENMODE = ( unsigned char volatile * ) 0x8ff0;
unsigned char volatile * FRAMEBUFFER_DISPLAY = ( unsigned char volatile * ) 0x8ff2;
unsigned char volatile * FRAMEBUFFER_DRAW = ( unsigned char volatile * ) 0x8ff4;

// HANDLE SMT - RUNNING STATUS AND POINTER TO CODE TO RUN
unsigned char volatile * SMTSTATUS = ( unsigned char volatile *) 0xffff;
unsigned int volatile * SMTPCH = ( unsigned int volatile * ) 0xfff0;
unsigned int volatile * SMTPCL = ( unsigned int volatile * ) 0xfff2;

// TYPES AND STRUCTURES
typedef unsigned int size_t;
typedef unsigned short bool;

// FOR EASE OF PORTING
typedef unsigned char   uint8;
typedef unsigned short  uint16;
typedef unsigned int    uint32;
typedef signed char     int8;
typedef signed short    int16;
typedef signed int      int32;

// STRUCTURE OF THE SPRITE UPDATE FLAG
struct sprite_update_flag {
    unsigned int padding:3;
    unsigned int y_act:1;
    unsigned int x_act:1;
    unsigned int tile_act:1;
    int dy:5;
    int dx:5;
};

// FAT16 FILE SYSTEM
// https://codeandlife.com/2012/04/02/simple-fat-and-sd-tutorial-part-1/ USED AS REFERENCE

typedef struct {
    unsigned char first_byte;
    unsigned char start_chs[3];
    unsigned char partition_type;
    unsigned char end_chs[3];
    unsigned int start_sector;
    unsigned int length_sectors;
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
    unsigned int hidden_sectors;
    unsigned int total_sectors_long;

    unsigned char drive_number;
    unsigned char current_head;
    unsigned char boot_signature;
    unsigned int volume_id;
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
    unsigned int file_size;
} __attribute((packed)) Fat16Entry;

// COLOURS
#define TRANSPARENT 0x40
#define BLACK 0x00
#define BLUE 0x03
#define DKBLUE 0x02
#define GREEN 0x0c
#define DKGREEN 0x08
#define CYAN 0x0f
#define DKCYAN 0x0b
#define RED 0x30
#define DKRED 0x20
#define MAGENTA 0x33
#define DKMAGENTA 0x22
#define PURPLE 0x13
#define YELLOW 0x3c
#define DKYELLOW 0x28
#define WHITE 0x3f
#define GREY1 0x15
#define GREY2 0x2a
#define ORANGE 0x38

// STANDARD CONSTANTS
#define NULL 0
#define true 1
#define false 0
#define TRUE 1
#define FALSE 0
