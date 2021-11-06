// I/O MEMORY MAPPED REGISTER DEFINITIONS
unsigned char volatile * UART_DATA = (unsigned char volatile *) 0xf100;
unsigned char volatile * UART_STATUS = (unsigned char volatile *) 0xf102;
unsigned short volatile * BUTTONS = (unsigned short volatile *) 0xf120;
unsigned char volatile * LEDS = (unsigned char volatile *) 0xf130;

// PS/2 KEYBOARD
unsigned char volatile * PS2_AVAILABLE = (unsigned char volatile *) 0xf110;
unsigned char volatile * PS2_MODE = (unsigned char volatile * ) 0xf110;
unsigned short volatile * PS2_DATA = (unsigned short volatile *) 0xf112;

// SDCARD
unsigned char volatile * SDCARD_READY = (unsigned char volatile *) 0xf140;
unsigned char volatile * SDCARD_START = (unsigned char volatile *) 0xf140;
unsigned short volatile * SDCARD_SECTOR_LOW = ( unsigned short *) 0xf144;
unsigned short volatile * SDCARD_SECTOR_HIGH = ( unsigned short *) 0xf142;
unsigned short volatile * SDCARD_ADDRESS = (unsigned short volatile *) 0xf150;
unsigned char volatile * SDCARD_DATA = (unsigned char volatile *) 0xf150;

// DISPLAY UNITS
unsigned char volatile * VBLANK = ( unsigned char volatile * ) 0xdf00;
unsigned char volatile * SCREENMODE = ( unsigned char volatile * ) 0xdf00;
unsigned char volatile * COLOUR = ( unsigned char volatile * ) 0xdf01;

// BACKGROUND AND COPPER - BASE 0xd000
unsigned char volatile * BACKGROUND_COLOUR = (unsigned char volatile *) 0xd000;
unsigned char volatile * BACKGROUND_ALTCOLOUR = (unsigned char volatile *) 0xd002;
unsigned char volatile * BACKGROUND_MODE = (unsigned char volatile *) 0xd004;
unsigned char volatile * BACKGROUND_COPPER_PROGRAM = (unsigned char volatile *) 0xd010;
unsigned char volatile * BACKGROUND_COPPER_STARTSTOP = (unsigned char volatile *) 0xd012;
unsigned char volatile * BACKGROUND_COPPER_ADDRESS = (unsigned char volatile *) 0xd020;
unsigned char volatile * BACKGROUND_COPPER_COMMAND = (unsigned char volatile *) 0xd022;
unsigned char volatile * BACKGROUND_COPPER_CONDITION = (unsigned char volatile *) 0xd024;
unsigned short volatile * BACKGROUND_COPPER_COORDINATE = (unsigned short volatile *) 0xd026;
unsigned short volatile * BACKGROUND_COPPER_CPUINPUT = (unsigned short volatile *) 0xd028;
unsigned char volatile * BACKGROUND_COPPER_MODE = (unsigned char volatile *) 0xd02a;
unsigned char volatile * BACKGROUND_COPPER_ALT = (unsigned char volatile *) 0xd02c;
unsigned char volatile * BACKGROUND_COPPER_COLOUR = (unsigned char volatile *) 0xd02e;

unsigned char volatile * LOWER_TM_X = (unsigned char volatile *) 0xd100;
unsigned char volatile * LOWER_TM_Y = (unsigned char volatile *) 0xd102;
unsigned char volatile * LOWER_TM_TILE = (unsigned char volatile *) 0xd104;
unsigned char volatile * LOWER_TM_BACKGROUND = (unsigned char volatile *) 0xd106;
unsigned char volatile * LOWER_TM_FOREGROUND = (unsigned char volatile *) 0xd108;
unsigned char volatile * LOWER_TM_REFLECTION = (unsigned char volatile *) 0xd10a;
unsigned char volatile * LOWER_TM_COMMIT = (unsigned char volatile *) 0xd10c;
unsigned char volatile * LOWER_TM_WRITER_TILE_NUMBER = (unsigned char volatile *) 0xd110;
unsigned char volatile * LOWER_TM_WRITER_LINE_NUMBER = (unsigned char volatile *) 0xd112;
unsigned short volatile * LOWER_TM_WRITER_BITMAP = (unsigned short volatile *) 0xd114;
unsigned char volatile * LOWER_TM_SCROLLWRAPCLEAR = (unsigned char volatile *) 0xd120;
unsigned char volatile * LOWER_TM_STATUS = (unsigned char volatile *) 0xd122;

unsigned char volatile * UPPER_TM_X = (unsigned char volatile *) 0xd200;
unsigned char volatile * UPPER_TM_Y = (unsigned char volatile *) 0xd202;
unsigned char volatile * UPPER_TM_TILE = (unsigned char volatile *) 0xd204;
unsigned char volatile * UPPER_TM_BACKGROUND = (unsigned char volatile *) 0xd206;
unsigned char volatile * UPPER_TM_FOREGROUND = (unsigned char volatile *) 0xd208;
unsigned char volatile * UPPER_TM_REFLECTION = (unsigned char volatile *) 0xd20a;
unsigned char volatile * UPPER_TM_COMMIT = (unsigned char volatile *) 0xd20c;
unsigned char volatile * UPPER_TM_WRITER_TILE_NUMBER = (unsigned char volatile *) 0xd210;
unsigned char volatile * UPPER_TM_WRITER_LINE_NUMBER = (unsigned char volatile *) 0xd212;
unsigned short volatile * UPPER_TM_WRITER_BITMAP = (unsigned short volatile *) 0xd214;
unsigned char volatile * UPPER_TM_SCROLLWRAPCLEAR = (unsigned char volatile *) 0xd220;
unsigned char volatile * UPPER_TM_STATUS = (unsigned char volatile *) 0xd222;

short volatile * GPU_X = (short volatile *) 0xd600;
short volatile * GPU_Y = (short volatile *) 0xd602;
unsigned char volatile * GPU_COLOUR = (unsigned char volatile *) 0xd604;
unsigned char volatile * GPU_COLOUR_ALT = (unsigned char volatile *) 0xd606;
unsigned char volatile * GPU_DITHERMODE = (unsigned char volatile *) 0xd608;
short volatile * GPU_PARAM0 = (short volatile *) 0xd60a;
short volatile * GPU_PARAM1 = (short volatile *) 0xd60c;
short volatile * GPU_PARAM2 = (short volatile *) 0xd60e;
short volatile * GPU_PARAM3 = (short volatile *) 0xd610;
short volatile * GPU_PARAM4 = (short volatile *) 0xd612;
short volatile * GPU_PARAM5 = (short volatile *) 0xd614;
unsigned char volatile * GPU_WRITE = (unsigned char volatile *) 0xd616;
unsigned char volatile * GPU_STATUS = (unsigned char volatile *) 0xd616;
unsigned char volatile * GPU_FINISHED = (unsigned char volatile *) 0xd618;
unsigned char volatile * VECTOR_DRAW_BLOCK = (unsigned char volatile *) 0xd620;
unsigned char volatile * VECTOR_DRAW_COLOUR = (unsigned char volatile *) 0xd622;
short volatile * VECTOR_DRAW_XC = (short volatile *) 0xd624;
short volatile * VECTOR_DRAW_YC = (short volatile *) 0xd626;
unsigned char volatile * VECTOR_DRAW_SCALE = (unsigned char volatile *) 0xd628;
unsigned char volatile * VECTOR_DRAW_ACTION = (unsigned char volatile *) 0xd62a;
unsigned char volatile * VECTOR_DRAW_START = (unsigned char volatile *) 0xd62c;
unsigned char volatile * VECTOR_DRAW_STATUS = (unsigned char volatile *) 0xd62a;
unsigned char volatile * VECTOR_WRITER_BLOCK = (unsigned char volatile *) 0xd630;
unsigned char volatile * VECTOR_WRITER_VERTEX = (unsigned char volatile *) 0xd632;
char volatile * VECTOR_WRITER_DELTAX = (char volatile *) 0xd634;
char volatile * VECTOR_WRITER_DELTAY = (char volatile *) 0xd636;
unsigned char volatile * VECTOR_WRITER_ACTIVE = (unsigned char volatile *) 0xd638;
unsigned char volatile * BLIT_WRITER_TILE = (unsigned char volatile *) 0xd640;
unsigned char volatile * BLIT_WRITER_LINE = (unsigned char volatile *) 0xd642;
unsigned short volatile * BLIT_WRITER_BITMAP = (unsigned short volatile *) 0xd644;
unsigned char volatile * BLIT_CHWRITER_TILE = (unsigned char volatile *) 0xd650;
unsigned char volatile * BLIT_CHWRITER_LINE = (unsigned char volatile *) 0xd652;
unsigned char volatile * BLIT_CHWRITER_BITMAP = (unsigned char volatile *) 0xd654;
unsigned char volatile * COLOURBLIT_WRITER_TILE = (unsigned char volatile *) 0xd660;
unsigned char volatile * COLOURBLIT_WRITER_LINE = (unsigned char volatile *) 0xd662;
unsigned char volatile * COLOURBLIT_WRITER_PIXEL = (unsigned char volatile *) 0xd664;
unsigned char volatile * COLOURBLIT_WRITER_COLOUR = (unsigned char volatile *) 0xd666;
unsigned char volatile * PB_COLOUR7 = (unsigned char volatile *) 0xd670;
unsigned char volatile * PB_COLOUR8R = (unsigned char volatile *) 0xd672;
unsigned char volatile * PB_COLOUR8G = (unsigned char volatile *) 0xd674;
unsigned char volatile * PB_COLOUR8B = (unsigned char volatile *) 0xd676;
unsigned char volatile * PB_STOP = (unsigned char volatile *) 0xd678;

unsigned char volatile * BITMAP_X_READ = (unsigned char volatile *) 0xd6d0;
unsigned short volatile * BITMAP_Y_READ = (unsigned short volatile *) 0xd6d2;
unsigned short volatile * BITMAP_PIXEL_READ = (unsigned short volatile *) 0xd6d4;
unsigned short volatile * CROP_LEFT = (unsigned short volatile *) 0xd6e2;
unsigned short volatile * CROP_RIGHT = (unsigned short volatile *) 0xd6e4;
unsigned short volatile * CROP_TOP = (unsigned short volatile *) 0xd6e6;
unsigned short volatile * CROP_BOTTOM = (unsigned short volatile *) 0xd6e8;
unsigned char volatile * FRAMEBUFFER_DISPLAY = ( unsigned char volatile * ) 0xd6f0;
unsigned char volatile * FRAMEBUFFER_DRAW = ( unsigned char volatile * ) 0xd6f2;

unsigned short volatile * LOWER_SPRITE_ACTIVE = ( unsigned short volatile * ) 0xd300;
unsigned short volatile * LOWER_SPRITE_DOUBLE = ( unsigned short volatile * ) 0xd320;
unsigned short volatile * LOWER_SPRITE_COLOUR = ( unsigned short volatile * ) 0xd340;
short volatile * LOWER_SPRITE_X = ( short volatile * ) 0xd360;
short volatile * LOWER_SPRITE_Y = ( short volatile * ) 0xd380;
unsigned short volatile * LOWER_SPRITE_TILE = ( unsigned short volatile * ) 0xd3a0;
unsigned short volatile * LOWER_SPRITE_UPDATE = ( unsigned short volatile * ) 0xd3c0;
unsigned short volatile * LOWER_SPRITE_COLLISION_BASE = ( unsigned short volatile * ) 0xd3c0;
unsigned short volatile * LOWER_SPRITE_LAYER_COLLISION_BASE = ( unsigned short volatile * ) 0xd3e0;
unsigned char volatile * LOWER_SPRITE_WRITER_NUMBER = ( unsigned char volatile * ) 0xd800;
unsigned char volatile * LOWER_SPRITE_WRITER_LINE = ( unsigned char volatile * ) 0xd802;
unsigned short volatile * LOWER_SPRITE_WRITER_BITMAP = ( unsigned short volatile * ) 0xd804;

unsigned short volatile * UPPER_SPRITE_ACTIVE = ( unsigned short volatile * ) 0xd400;
unsigned short volatile * UPPER_SPRITE_DOUBLE = ( unsigned short volatile * ) 0xd420;
unsigned short volatile * UPPER_SPRITE_COLOUR = ( unsigned short volatile * ) 0xd440;
short volatile * UPPER_SPRITE_X = ( short volatile * ) 0xd460;
short volatile * UPPER_SPRITE_Y = ( short volatile * ) 0xd480;
unsigned short volatile * UPPER_SPRITE_TILE = ( unsigned short volatile * ) 0xd4a0;
unsigned short volatile * UPPER_SPRITE_UPDATE = ( unsigned short volatile * ) 0xd4c0;
unsigned short volatile * UPPER_SPRITE_COLLISION_BASE = ( unsigned short volatile * ) 0xd4c0;
unsigned short volatile * UPPER_SPRITE_LAYER_COLLISION_BASE = ( unsigned short volatile * ) 0xd4e0;
unsigned char volatile * UPPER_SPRITE_WRITER_NUMBER = ( unsigned char volatile * ) 0xd900;
unsigned char volatile * UPPER_SPRITE_WRITER_LINE = ( unsigned char volatile * ) 0xd902;
unsigned short volatile * UPPER_SPRITE_WRITER_BITMAP = ( unsigned short volatile * ) 0xd904;

unsigned char volatile * TPU_X = ( unsigned char volatile * ) 0xd500;
unsigned char volatile * TPU_Y = ( unsigned char volatile * ) 0xd502;
unsigned char volatile * TPU_CHARACTER = ( unsigned char volatile * ) 0xd504;
unsigned char volatile * TPU_BACKGROUND = ( unsigned char volatile * ) 0xd506;
unsigned char volatile * TPU_FOREGROUND = ( unsigned char volatile * ) 0xd508;
unsigned char volatile * TPU_COMMIT = ( unsigned char volatile * ) 0xd50a;
unsigned char volatile * TPU_CURSOR = ( unsigned char volatile * ) 0xd50c;

unsigned char volatile * TERMINAL_COMMIT = ( unsigned char volatile * ) 0xd700;
unsigned char volatile * TERMINAL_STATUS = ( unsigned char volatile * ) 0xd700;
unsigned char volatile * TERMINAL_SHOW = ( unsigned char volatile * ) 0xd702;
unsigned char volatile * TERMINAL_RESET = ( unsigned char volatile * ) 0xd704;

unsigned char volatile * AUDIO_WAVEFORM = ( unsigned char volatile * ) 0xe000;
unsigned short volatile * AUDIO_FREQUENCY = ( unsigned short volatile * ) 0xe002;
unsigned short volatile * AUDIO_DURATION = ( unsigned short volatile * ) 0xe004;
unsigned char volatile * AUDIO_START = ( unsigned char volatile * ) 0xe006;
unsigned char volatile * AUDIO_L_ACTIVE = ( unsigned char volatile * ) 0xe010;
unsigned char volatile * AUDIO_R_ACTIVE = ( unsigned char volatile * ) 0xe012;

unsigned short volatile * RNG = ( unsigned short volatile * ) 0xc000;
unsigned short volatile * ALT_RNG = ( unsigned short volatile * ) 0xc002;
float volatile * FRNG = ( floatvolatile * ) 0xc004;
unsigned short volatile * TIMER1HZ0 = ( unsigned short volatile * ) 0xc010;
unsigned short volatile * TIMER1HZ1 = ( unsigned short volatile * ) 0xc012;
unsigned short volatile * TIMER1KHZ0 = ( unsigned short volatile * ) 0xc014;
unsigned short volatile * TIMER1KHZ1 = ( unsigned short volatile * ) 0xc016;
unsigned short volatile * SLEEPTIMER0 = ( unsigned short volatile * ) 0xc018;
unsigned short volatile * SLEEPTIMER1 = ( unsigned short volatile * ) 0xc01a;
unsigned short volatile * SYSTEMCLOCK = (unsigned short volatile *) 0xc01c;

// HANDLE SMT - RUNNING STATUS AND POINTER TO CODE TO RUN
unsigned char volatile * SMTSTATUS = ( unsigned char volatile *) 0xfffe;
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

// FAT32 FILE SYSTEM
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
    unsigned short fat16_size_sectors;
    unsigned short sectors_per_track;
    unsigned short number_of_heads;
    unsigned int hidden_sectors;
    unsigned int total_sectors_long;
    unsigned int fat32_size_sectors;
    unsigned short flags;
    unsigned short version;
    unsigned int startof_root;
    unsigned short filesystem_information;
    unsigned short backupboot_sector;
    unsigned char reserved[12];
    unsigned char logical_drive_number;
    unsigned char unused;
    unsigned char extended_signature;
    unsigned int volume_id;
    char volume_label[11];
    char fs_type[8];
    char boot_code[420];
    unsigned short boot_sector_signature;
} __attribute((packed)) Fat32VolumeID;

typedef struct {
    unsigned char filename[8];
    unsigned char ext[3];
    unsigned char attributes;
    unsigned char reserved[8];
    unsigned short starting_cluster_high;
    unsigned short modify_time;
    unsigned short modify_date;
    unsigned short starting_cluster_low;
    unsigned int file_size;
} __attribute((packed)) FAT32DirectoryEntry;

typedef struct {
    unsigned char filename[8];
    unsigned char ext[3];
    unsigned char type;
    unsigned long starting_cluster;
} __attribute((packed)) DirectoryEntry;

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

// LOWER AND UPPER SPRITES/TILEMAPS
#define LOWER 0
#define UPPER 1
