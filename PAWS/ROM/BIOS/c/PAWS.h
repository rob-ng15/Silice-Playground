// I/O MEMORY MAPPED REGISTER DEFINITIONS
unsigned char volatile * UART_DATA = (unsigned char volatile *) 0xf100;
unsigned char volatile * UART_STATUS = (unsigned char volatile *) 0xf102;
unsigned char volatile * BUTTONS = (unsigned char volatile *) 0xf120;
unsigned char volatile * LEDS = (unsigned char volatile *) 0xf130;

// PS/2 KEYBOARD
unsigned char volatile * PS2_DATA = (unsigned char volatile *) 0xf110;
unsigned char volatile * PS2_AVAILABLE = (unsigned char volatile *) 0xf112;

// SDCARD
unsigned char volatile * SDCARD_READY = (unsigned char volatile *) 0xf140;
unsigned char volatile * SDCARD_START = (unsigned char volatile *) 0xf140;
unsigned short volatile * SDCARD_SECTOR_LOW = ( unsigned short *) 0xf144;
unsigned short volatile * SDCARD_SECTOR_HIGH = ( unsigned short *) 0xf142;
unsigned short volatile * SDCARD_ADDRESS = (unsigned short volatile *) 0xf150;
unsigned char volatile * SDCARD_DATA = (unsigned char volatile *) 0xf150;

// DISPLAY UNITS

// BACKGROUND AND COPPER - BASE 0x8000
unsigned char volatile * BACKGROUND_COLOUR = (unsigned char volatile *) 0x8000;
unsigned char volatile * BACKGROUND_ALTCOLOUR = (unsigned char volatile *) 0x8002;
unsigned char volatile * BACKGROUND_MODE = (unsigned char volatile *) 0x8004;
unsigned char volatile * BACKGROUND_COPPER_PROGRAM = (unsigned char volatile *) 0x8010;
unsigned char volatile * BACKGROUND_COPPER_STARTSTOP = (unsigned char volatile *) 0x8012;
unsigned char volatile * BACKGROUND_COPPER_ADDRESS = (unsigned char volatile *) 0x8020;
unsigned char volatile * BACKGROUND_COPPER_COMMAND = (unsigned char volatile *) 0x8022;
unsigned char volatile * BACKGROUND_COPPER_CONDITION = (unsigned char volatile *) 0x8024;
unsigned short volatile * BACKGROUND_COPPER_COORDINATE = (unsigned short volatile *) 0x8026;
unsigned char volatile * BACKGROUND_COPPER_MODE = (unsigned char volatile *) 0x8028;
unsigned char volatile * BACKGROUND_COPPER_ALT = (unsigned char volatile *) 0x802a;
unsigned char volatile * BACKGROUND_COPPER_COLOUR = (unsigned char volatile *) 0x802c;

unsigned char volatile * LOWER_TM_X = (unsigned char volatile *) 0x8100;
unsigned char volatile * LOWER_TM_Y = (unsigned char volatile *) 0x8102;
unsigned char volatile * LOWER_TM_TILE = (unsigned char volatile *) 0x8104;
unsigned char volatile * LOWER_TM_BACKGROUND = (unsigned char volatile *) 0x8106;
unsigned char volatile * LOWER_TM_FOREGROUND = (unsigned char volatile *) 0x8108;
unsigned char volatile * LOWER_TM_COMMIT = (unsigned char volatile *) 0x810a;
unsigned char volatile * LOWER_TM_WRITER_TILE_NUMBER = (unsigned char volatile *) 0x8110;
unsigned char volatile * LOWER_TM_WRITER_LINE_NUMBER = (unsigned char volatile *) 0x8112;
unsigned short volatile * LOWER_TM_WRITER_BITMAP = (unsigned short volatile *) 0x8114;
unsigned char volatile * LOWER_TM_SCROLLWRAPCLEAR = (unsigned char volatile *) 0x8120;
unsigned char volatile * LOWER_TM_STATUS = (unsigned char volatile *) 0x8122;

unsigned char volatile * UPPER_TM_X = (unsigned char volatile *) 0x8200;
unsigned char volatile * UPPER_TM_Y = (unsigned char volatile *) 0x8202;
unsigned char volatile * UPPER_TM_TILE = (unsigned char volatile *) 0x8204;
unsigned char volatile * UPPER_TM_BACKGROUND = (unsigned char volatile *) 0x8206;
unsigned char volatile * UPPER_TM_FOREGROUND = (unsigned char volatile *) 0x8208;
unsigned char volatile * UPPER_TM_COMMIT = (unsigned char volatile *) 0x820a;
unsigned char volatile * UPPER_TM_WRITER_TILE_NUMBER = (unsigned char volatile *) 0x8210;
unsigned char volatile * UPPER_TM_WRITER_LINE_NUMBER = (unsigned char volatile *) 0x8212;
unsigned short volatile * UPPER_TM_WRITER_BITMAP = (unsigned short volatile *) 0x8214;
unsigned char volatile * UPPER_TM_SCROLLWRAPCLEAR = (unsigned char volatile *) 0x8220;
unsigned char volatile * UPPER_TM_STATUS = (unsigned char volatile *) 0x8222;

short volatile * GPU_X = (short volatile *) 0x8600;
short volatile * GPU_Y = (short volatile *) 0x8602;
unsigned char volatile * GPU_COLOUR = (unsigned char volatile *) 0x8604;
unsigned char volatile * GPU_COLOUR_ALT = (unsigned char volatile *) 0x8606;
unsigned char volatile * GPU_DITHERMODE = (unsigned char volatile *) 0x8608;
short volatile * GPU_PARAM0 = (short volatile *) 0x860a;
short volatile * GPU_PARAM1 = (short volatile *) 0x860c;
short volatile * GPU_PARAM2 = (short volatile *) 0x860e;
short volatile * GPU_PARAM3 = (short volatile *) 0x8610;
unsigned char volatile * GPU_WRITE = (unsigned char volatile *) 0x8612;
unsigned char volatile * GPU_STATUS = (unsigned char volatile *) 0x8612;
unsigned char volatile * VECTOR_DRAW_BLOCK = (unsigned char volatile *) 0x8620;
unsigned char volatile * VECTOR_DRAW_COLOUR = (unsigned char volatile *) 0x8622;
short volatile * VECTOR_DRAW_XC = (short volatile *) 0x8624;
short volatile * VECTOR_DRAW_YC = (short volatile *) 0x8626;
unsigned char volatile * VECTOR_DRAW_SCALE = (unsigned char volatile *) 0x8628;
unsigned char volatile * VECTOR_DRAW_START = (unsigned char volatile *) 0x862a;
unsigned char volatile * VECTOR_DRAW_STATUS = (unsigned char volatile *) 0x862a;
unsigned char volatile * VECTOR_WRITER_BLOCK = (unsigned char volatile *) 0x8630;
unsigned char volatile * VECTOR_WRITER_VERTEX = (unsigned char volatile *) 0x8632;
char volatile * VECTOR_WRITER_DELTAX = (char volatile *) 0x8634;
char volatile * VECTOR_WRITER_DELTAY = (char volatile *) 0x8636;
unsigned char volatile * VECTOR_WRITER_ACTIVE = (unsigned char volatile *) 0x8638;
unsigned char volatile * BLIT_WRITER_TILE = (unsigned char volatile *) 0x8640;
unsigned char volatile * BLIT_WRITER_LINE = (unsigned char volatile *) 0x8642;
unsigned short volatile * BLIT_WRITER_BITMAP = (unsigned short volatile *) 0x8644;
unsigned char volatile * BLIT_CHWRITER_TILE = (unsigned char volatile *) 0x8650;
unsigned char volatile * BLIT_CHWRITER_LINE = (unsigned char volatile *) 0x8652;
unsigned char volatile * BLIT_CHWRITER_BITMAP = (unsigned char volatile *) 0x8654;
unsigned char volatile * COLOURBLIT_WRITER_TILE = (unsigned char volatile *) 0x8660;
unsigned char volatile * COLOURBLIT_WRITER_LINE = (unsigned char volatile *) 0x8662;
unsigned char volatile * COLOURBLIT_WRITER_PIXEL = (unsigned char volatile *) 0x8664;
unsigned char volatile * COLOURBLIT_WRITER_COLOUR = (unsigned char volatile *) 0x8666;
unsigned char volatile * BITMAP_X_READ = (unsigned char volatile *) 0x8670;
unsigned short volatile * BITMAP_Y_READ = (unsigned short volatile *) 0x8672;
unsigned short volatile * BITMAP_PIXEL_READ = (unsigned short volatile *) 0x8674;
unsigned char volatile * BITMAP_SCROLLWRAP = (unsigned char volatile *) 0x8680;
unsigned char volatile * FRAMEBUFFER_DISPLAY = ( unsigned char volatile * ) 0x8690;
unsigned char volatile * FRAMEBUFFER_DRAW = ( unsigned char volatile * ) 0x8692;

unsigned char volatile * LOWER_SPRITE_NUMBER = ( unsigned char volatile * ) 0x8300;
unsigned char volatile * LOWER_SPRITE_ACTIVE = ( unsigned char volatile * ) 0x8302;
unsigned char volatile * LOWER_SPRITE_TILE = ( unsigned char volatile * ) 0x8304;
unsigned char volatile * LOWER_SPRITE_COLOUR = ( unsigned char volatile * ) 0x8306;
short volatile * LOWER_SPRITE_X = ( short volatile * ) 0x8308;
short volatile * LOWER_SPRITE_Y = ( short volatile * ) 0x830a;
unsigned char volatile * LOWER_SPRITE_DOUBLE = ( unsigned char volatile * ) 0x830c;
unsigned short volatile * LOWER_SPRITE_UPDATE = ( unsigned short volatile * ) 0x830e;
unsigned char volatile * LOWER_SPRITE_NUMBER_SMT = ( unsigned char volatile * ) 0x8310;
unsigned char volatile * LOWER_SPRITE_ACTIVE_SMT = ( unsigned char volatile * ) 0x8312;
unsigned char volatile * LOWER_SPRITE_TILE_SMT = ( unsigned char volatile * ) 0x8314;
unsigned char volatile * LOWER_SPRITE_COLOUR_SMT = ( unsigned char volatile * ) 0x8316;
short volatile * LOWER_SPRITE_X_SMT = ( short volatile * ) 0x8318;
short volatile * LOWER_SPRITE_Y_SMT = ( short volatile * ) 0x831a;
unsigned char volatile * LOWER_SPRITE_DOUBLE_SMT = ( unsigned char volatile * ) 0x831c;
unsigned short volatile * LOWER_SPRITE_UPDATE_SMT = ( unsigned short volatile * ) 0x831e;
unsigned char volatile * LOWER_SPRITE_WRITER_NUMBER = ( unsigned char volatile * ) 0x8320;
unsigned char volatile * LOWER_SPRITE_WRITER_LINE = ( unsigned char volatile * ) 0x8322;
unsigned short volatile * LOWER_SPRITE_WRITER_BITMAP = ( unsigned short volatile * ) 0x8324;
unsigned short volatile * LOWER_SPRITE_COLLISION_BASE = ( unsigned short volatile * ) 0x8330;
unsigned short volatile * LOWER_SPRITE_LAYER_COLLISION_BASE = ( unsigned short volatile * ) 0x8350;

unsigned char volatile * UPPER_SPRITE_NUMBER = ( unsigned char volatile * ) 0x8400;
unsigned char volatile * UPPER_SPRITE_ACTIVE = ( unsigned char volatile * ) 0x8402;
unsigned char volatile * UPPER_SPRITE_TILE = ( unsigned char volatile * ) 0x8404;
unsigned char volatile * UPPER_SPRITE_COLOUR = ( unsigned char volatile * ) 0x8406;
short volatile * UPPER_SPRITE_X = ( short volatile * ) 0x8408;
short volatile * UPPER_SPRITE_Y = ( short volatile * ) 0x840a;
unsigned char volatile * UPPER_SPRITE_DOUBLE = ( unsigned char volatile * ) 0x840c;
unsigned short volatile * UPPER_SPRITE_UPDATE = ( unsigned short volatile * ) 0x840e;
unsigned char volatile * UPPER_SPRITE_NUMBER_SMT = ( unsigned char volatile * ) 0x8410;
unsigned char volatile * UPPER_SPRITE_ACTIVE_SMT = ( unsigned char volatile * ) 0x8412;
unsigned char volatile * UPPER_SPRITE_TILE_SMT = ( unsigned char volatile * ) 0x8414;
unsigned char volatile * UPPER_SPRITE_COLOUR_SMT = ( unsigned char volatile * ) 0x8416;
short volatile * UPPER_SPRITE_X_SMT = ( short volatile * ) 0x8418;
short volatile * UPPER_SPRITE_Y_SMT = ( short volatile * ) 0x841a;
unsigned char volatile * UPPER_SPRITE_DOUBLE_SMT = ( unsigned char volatile * ) 0x841c;
unsigned short volatile * UPPER_SPRITE_UPDATE_SMT = ( unsigned short volatile * ) 0x841e;
unsigned char volatile * UPPER_SPRITE_WRITER_NUMBER = ( unsigned char volatile * ) 0x8420;
unsigned char volatile * UPPER_SPRITE_WRITER_LINE = ( unsigned char volatile * ) 0x8422;
unsigned short volatile * UPPER_SPRITE_WRITER_BITMAP = ( unsigned short volatile * ) 0x8424;
unsigned short volatile * UPPER_SPRITE_COLLISION_BASE = ( unsigned short volatile * ) 0x8430;
unsigned short volatile * UPPER_SPRITE_LAYER_COLLISION_BASE = ( unsigned short volatile * ) 0x8450;

unsigned char volatile * TPU_X = ( unsigned char volatile * ) 0x8500;
unsigned char volatile * TPU_Y = ( unsigned char volatile * ) 0x8502;
unsigned char volatile * TPU_CHARACTER = ( unsigned char volatile * ) 0x8504;
unsigned char volatile * TPU_BACKGROUND = ( unsigned char volatile * ) 0x8506;
unsigned char volatile * TPU_FOREGROUND = ( unsigned char volatile * ) 0x8508;
unsigned char volatile * TPU_COMMIT = ( unsigned char volatile * ) 0x850a;

unsigned char volatile * AUDIO_L_WAVEFORM = ( unsigned char volatile * ) 0xf200;
unsigned char volatile * AUDIO_L_NOTE = ( unsigned char volatile * ) 0xf202;
unsigned short volatile * AUDIO_L_DURATION = ( unsigned short volatile * ) 0xf204;
unsigned char volatile * AUDIO_L_START = ( unsigned char volatile * ) 0xf206;
unsigned char volatile * AUDIO_R_WAVEFORM = ( unsigned char volatile * ) 0xf210;
unsigned char volatile * AUDIO_R_NOTE = ( unsigned char volatile * ) 0xf212;
unsigned short volatile * AUDIO_R_DURATION = ( unsigned short volatile * ) 0xf214;
unsigned char volatile * AUDIO_R_START = ( unsigned char volatile * ) 0xf216;

unsigned short volatile * RNG = ( unsigned short volatile * ) 0xf000;
unsigned short volatile * ALT_RNG = ( unsigned short volatile * ) 0xf002;
unsigned short volatile * TIMER1HZ0 = ( unsigned short volatile * ) 0xf010;
unsigned short volatile * TIMER1HZ1 = ( unsigned short volatile * ) 0xf012;
unsigned short volatile * TIMER1KHZ0 = ( unsigned short volatile * ) 0xf020;
unsigned short volatile * TIMER1KHZ1 = ( unsigned short volatile * ) 0xf022;
unsigned short volatile * SLEEPTIMER0 = ( unsigned short volatile * ) 0xf030;
unsigned short volatile * SLEEPTIMER1 = ( unsigned short volatile * ) 0xf032;
unsigned short volatile * SYSTEMCLOCK = (unsigned short volatile *) 0xf040;

unsigned char volatile * VBLANK = ( unsigned char volatile * ) 0xf800;
unsigned char volatile * SCREENMODE = ( unsigned char volatile * ) 0xf800;

// HANDLE SMT - RUNNING STATUS AND POINTER TO CODE TO RUN
unsigned char volatile * SMTSTATUS = ( unsigned char volatile *) 0xfffe;
unsigned int volatile * SMTPCH = ( unsigned int volatile * ) 0xfff0;
unsigned int volatile * SMTPCL = ( unsigned int volatile * ) 0xfff2;

// TYPES AND STRUCTURES

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

