// STANDARD CONSTANTS
#define NULL 0
#define true 1
#define false 0
#define TRUE 1
#define FALSE 0

// DISPLAY LAYERS
#define LOWER_LAYER 0
#define UPPER_LAYER 1

// BACKGROUND PATTERN GENERATOR
#define BKG_SOLID 0
#define BKG_5050_V 1
#define BKG_5050_H 2
#define BKG_CHKBRD_5 3
#define BKG_RAINBOW 4
#define BKG_SNOW 5
#define BKG_STATIC 6
#define BKG_CHKBRD_1 7
#define BKG_CHKBRD_2 8
#define BKG_CHKBRD_3 9
#define BKG_CHKBRD_4 10
#define BKG_HATCH 11
#define BKG_LSLOPE 12
#define BKG_RSLOPE 13
#define BKG_VSTRIPE 14
#define BKG_HSTRIPE 15

// BACKGROUND COPPER COMMANDS
#define COPPER_JUMP 0
#define COPPER_JUMP_ALWAYS 0
#define COPPER_JUMP_IF_NOT_VBLANK 1
#define COPPER_JUMP_IF_NOT_HBLANK 2
#define COPPER_JUMP_IF_Y_LESS 3
#define COPPER_JUMP_IF_X_LESS 4
#define COPPER_JUMP_IF_VARIABLE_LESS 5
#define COPPER_WAIT_VBLANK 1
#define COPPER_WAIT_HBLANK 2
#define COPPER_WAIT_Y 3
#define COPPER_WAIT_X 4
#define COPPER_WAIT_VARIABLE 5
#define COPPER_VARIABLE 6
#define COPPER_SET_VARIABLE 1
#define COPPER_ADD_VARIABLE 2
#define COPPER_SUB_VARIABLE 4
#define COPPER_SET_FROM_VARIABLE 7

// COLOURS
#define TRANSPARENT 0x40
#define BLACK 0x00
#define DKBLUE 0x02
#define BLUE 0x03
#define LTBLUE 0x07
#define DKGREEN 0x08
#define GREEN 0x0c
#define LTGREEN 0x1d
#define DKCYAN 0x0b
#define CYAN 0x0f
#define LTCYAN 0x1f
#define DKRED 0x20
#define RED 0x30
#define LTRED 0x35
#define DKMAGENTA 0x22
#define MAGENTA 0x33
#define LTMAGENTA 0x37
#define DKPURPLE 0x11
#define PURPLE 0x13
#define LTPURPLE 0x17
#define DKYELLOW 0x28
#define YELLOW 0x3c
#define LTYELLOW 0x3d
#define DKORANGE 0x34
#define ORANGE 0x38
#define LTORANGE 0x39
#define BROWN 0x24
#define PEACH 0x3a
#define PINK 0x3b
#define GREY1 0x15
#define GREY2 0x2a
#define WHITE 0x3f

#define DITHEROFF 0, BLACK
#define DITHERCHECK1 1
#define DITHERCHECK2 2
#define DITHERCHECK3 3
#define DITHERVSTRIPE 4
#define DITHERHSTRIPE 5
#define DITHERHATCH 6
#define DITHERLSLOPE 7
#define DITHERRSLOPE 8
#define DITHERLTRIANGLE 9
#define DITHERRTRIANGLE 10
#define DITHERENCLOSED 11
#define DITHEROCTAGON 12
#define DITHERBRICK 13
#define DITHER64COLSTATIC 14
#define DITHER2COLSTATIC 15

#define SPRITE_ACTIVE 0
#define SPRITE_TILE 1
#define SPRITE_COLOUR 2
#define SPRITE_X 3
#define SPRITE_Y 4
#define SPRITE_DOUBLE 5
#define SPRITE_TO_BITMAP 8
#define SPRITE_TO_LOWER_TILEMAP 4
#define SPRITE_TO_UPPER_TILEMAP 2
#define SPRITE_TO_OTHER_SPRITES 1

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

// MEMORY
extern unsigned char *MEMORYTOP;

// MASTER BOOT RECORD AND PARTITION TABLE
extern unsigned char *MBR;
extern Fat16BootSector *BOOTSECTOR;
extern PartitionTable *PARTITION;
extern Fat16Entry *ROOTDIRECTORY;
extern unsigned short *FAT;
extern unsigned char *CLUSTERBUFFER;
extern unsigned int CLUSTERSIZE;
extern unsigned int DATASTARTSECTOR;

// SIMPLE FILE SYSTEM
extern unsigned short sdcard_findfilenumber( unsigned char *, unsigned char * );
extern unsigned int sdcard_findfilesize( unsigned short );
extern void sdcard_readfile( unsigned short, unsigned char * );

// RISC-V CSR FUNCTIONS
extern long CSRcycles( void );
extern long CSRinstructions( void );
extern long CSRtime( void );

// UART AND TERMINAL INPUT / OUTPUT
extern void outputcharacter(char);
extern char inputcharacter( void );
extern unsigned char character_available( void );

// PS/2
extern char ps2_character_available( void );
extern char ps2_inputcharacter( void );

// BASIC I/O
extern void set_leds( unsigned char );
extern unsigned char get_buttons( void );

// TIMERS AND PSEUDO RANDOM NUMBER GENERATOR
extern unsigned short systemclock( void );
extern unsigned short secondssincestart( int );
extern unsigned short rng( unsigned short );
extern void sleep( unsigned short, unsigned char );
extern void set_timer1khz( unsigned short, unsigned char );
extern unsigned short get_timer1khz( unsigned char );
extern void wait_timer1khz( unsigned char );
extern unsigned short get_timer1hz( unsigned char );
extern void reset_timer1hz( unsigned char );

// AUDIO
extern void beep( unsigned char, unsigned char, unsigned char, unsigned short );
extern void await_beep( unsigned char );
extern unsigned short get_beep_active( unsigned char );

// SDCARD
extern void sdcard_readsector( unsigned int, unsigned char * );

// DISPLAY
extern void await_vblank( void );
extern void screen_mode( unsigned char );
extern void bitmap_display( unsigned char );
extern void bitmap_draw( unsigned char );

// BACKGROUND GENERATOR
extern void set_background( unsigned char, unsigned char, unsigned char );
extern void copper_startstop( unsigned char ) ;
extern void copper_program( unsigned char, unsigned char, unsigned char, unsigned short, unsigned char, unsigned char, unsigned char );

// TILEMAP
extern void set_tilemap_tile( unsigned char, unsigned char, unsigned char, unsigned char, unsigned char, unsigned char );
extern void set_tilemap_bitmap( unsigned char, unsigned char, unsigned short * );
extern unsigned char tilemap_scrollwrapclear( unsigned char, unsigned char );

// GPU AND BITMAP
void gpu_dither( unsigned char , unsigned char );
extern void gpu_pixel( unsigned char, short, short );
extern void gpu_rectangle( unsigned char, short, short, short, short );
extern void gpu_box( unsigned char, short, short, short, short );
extern void gpu_cs( void );
extern void gpu_line( unsigned char, short, short, short, short );
extern void gpu_circle( unsigned char, short, short, short, unsigned char );
extern void gpu_blit( unsigned char, short, short, short, unsigned char );
extern void gpu_character_blit( unsigned char, short, short, unsigned char, unsigned char );
extern void gpu_colourblit( short, short, short, unsigned char );
extern void gpu_triangle( unsigned char, short, short, short, short, short, short );
extern void gpu_quadrilateral( unsigned char, short, short, short, short, short, short, short, short );
extern void gpu_printf( unsigned char, short, short, unsigned char, const char *,...  );
extern void gpu_printf_centre( unsigned char, short, short, unsigned char, const char *,...  );
extern void draw_vector_block( unsigned char, unsigned char, short, short, unsigned char );
extern void set_vector_vertex( unsigned char, unsigned char , unsigned char, char, char );
extern void bitmap_scrollwrap( unsigned char );
extern void set_blitter_bitmap( unsigned char, unsigned short * );
extern void set_blitter_chbitmap( unsigned char, unsigned char * );
extern void set_colourblitter_bitmap( unsigned char, unsigned char * );

// SPRITES - MAIN ACCESS
extern void set_sprite( unsigned char, unsigned char, unsigned char, unsigned char, short, short, unsigned char, unsigned char );
extern short get_sprite_attribute( unsigned char, unsigned char , unsigned char );
extern void set_sprite_attribute( unsigned char, unsigned char, unsigned char, short );
extern void update_sprite( unsigned char, unsigned char, unsigned short );
extern unsigned short get_sprite_collision( unsigned char, unsigned char );
extern unsigned short get_sprite_layer_collision( unsigned char, unsigned char );
extern void set_sprite_bitmaps( unsigned char, unsigned char, unsigned short * );

// CHARACTER MAP
extern void tpu_cs( void );
extern void tpu_clearline( unsigned char );
extern void tpu_set(  unsigned char, unsigned char, unsigned char, unsigned char );
extern void tpu_output_character( char );
extern void tpu_outputstring( char * );
extern void tpu_printf( const char *,... );
extern void tpu_printf_centre( unsigned char, unsigned char, unsigned char, const char *,... );

// IMAGE DECODERS
extern void netppm_display( unsigned char *, unsigned char );
extern void netppm_decoder( unsigned char *, unsigned char * );
extern void bitmapblit( unsigned char *, unsigned short , unsigned short , short, short, unsigned char  );

// nanojpeg.c from https://keyj.emphy.de/nanojpeg/
typedef enum _nj_result {
    NJ_OK = 0,        // no error, decoding successful
    NJ_NO_JPEG,       // not a JPEG file
    NJ_UNSUPPORTED,   // unsupported format
    NJ_OUT_OF_MEM,    // out of memory
    NJ_INTERNAL_ERR,  // internal error
    NJ_SYNTAX_ERROR,  // syntax error
    __NJ_FINISHED,    // used internally, will never be reported
} nj_result_t;

extern void njInit(void);
extern nj_result_t njDecode(const void* jpeg, const int size);
extern int njGetWidth(void);
extern int njGetHeight(void);
extern int njIsColor(void);
extern unsigned char* njGetImage(void);
extern int njGetImageSize(void);
extern void njDone(void);

// SMT START AND STOP
extern void SMTSTOP( void );
extern void SMTSTART( unsigned int );
extern unsigned char SMTSTATE( void );
extern void INITIALISEMEMORY( void );

// SIMPLE CURSES
#define COLORS 64
#define COLOR_PAIRS 16
#define COLOR_PAIR(a) a

// COLOURS
#define COLOR_BLACK 0x00
#define COLOR_BLUE 0x03
#define COLOR_GREEN 0x0c
#define COLOR_CYAN 0x0f
#define COLOR_RED 0x30
#define COLOR_MAGENTA 0x33
#define COLOR_YELLOW 0x3c
#define COLOR_WHITE 0x3f
#define ORANGE 0x38

#define COLS 80
#define LINES 30

// SIMPLE CURSES
extern void initscr( void );
extern int endwin( void );
extern int refresh( void );
extern int clear( void );
extern void cbreak( void );
extern void echo( void );
extern void noecho( void );
extern void scroll( void );
extern void noscroll( void );
extern void curs_set( int );
extern int start_color( void );
extern bool has_colors( void );
extern bool can_change_color( void );
extern int init_pair( short pair, short f, short b );
extern int move( int y, int x );
extern int addch( unsigned char ch );
extern int mvaddch( int y, int x, unsigned char ch );
extern int printw( const char *fmt,... );
extern int mvprintw( int y, int x, const char *fmt,... );
extern int attron( int attrs );
extern int deleteln( void );
extern int clrtoeol( void );

// FILEMALLOC TO ALLOCATE SPACE FOR FILES
extern unsigned char *filemalloc( unsigned int );
