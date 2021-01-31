// STDDEF.H DEFINITIONS
#define max(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a > _b ? _a : _b; })

#define min(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a < _b ? _a : _b; })

#define abs(a) (((a) < 0 )? -(a) : (a))

typedef unsigned int size_t;

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

// MASTER BOOT RECORD AND PARTITION TABLE
extern unsigned char *MBR;
extern Fat16BootSector *BOOTSECTOR;
extern PartitionTable *PARTITION;
extern Fat16Entry *ROOTDIRECTORY;
extern unsigned short *FAT;
extern unsigned char *CLUSTERBUFFER;
extern unsigned int CLUSTERSIZE;
extern unsigned int DATASTARTSECTOR;

// MEMORY
extern unsigned char *MEMORYTOP;
extern void INITIALISEMEMORY( void );
extern unsigned char *memoryspace( unsigned int );
unsigned char *filememoryspace( unsigned int );

// SIMPLE FILE SYSTEM
extern unsigned short sdcard_findfilenumber( unsigned char *, unsigned char * );
extern unsigned int sdcard_findfilesize( unsigned short );
extern void sdcard_readfile( unsigned short, unsigned char * );

// RISC-V CSR FUNCTIONS
extern long CSRcycles( void );
extern long CSRinstructions( void );
extern long CSRtime( void );

// STANDARD FUNCTION DEFINITIONS
extern void* memcpy( void *dest, const void *src, size_t n );
extern void *memset( void *s, int c, size_t n );
extern int strcmp( const char *p1, const char *p2 );
extern int strlen( char *s );

// UART AND TERMINAL INPUT / OUTPUT
extern void outputcharacter(char);
extern void outputstring(char *);
extern void outputstringnonl(char *);
extern void outputnumber_char( unsigned char );
extern void outputnumber_short( unsigned short );
extern void outputnumber_int( unsigned int );
extern char inputcharacter( void );
unsigned char inputcharacter_available( void );

// BASIC I/O
extern void set_leds( unsigned char );
extern unsigned char get_buttons( void );

// TIMERS AND PSEUDO RANDOM NUMBER GENERATOR
extern unsigned short rng( unsigned short );
extern void sleep( unsigned short );
extern void set_timer1khz( unsigned short );
extern unsigned short get_timer1khz( void );
extern void wait_timer1khz( void );
extern unsigned short get_timer1hz( void );
extern void reset_timer1hz( void );

// AUDIO
extern void beep( unsigned char, unsigned char, unsigned char, unsigned short );

// SDCARD
extern void sdcard_readsector( unsigned int, unsigned char * );

// DISPLAY
extern void await_vblank( void );
extern void screen_mode( unsigned char );

// BACKGROUND GENERATOR
extern void set_background( unsigned char, unsigned char, unsigned char );

// TERMINAL WINDOW
extern void terminal_showhide( unsigned char );
extern void terminal_reset( void );

// TILEMAP
extern void set_tilemap_tile( unsigned char, unsigned char, unsigned char, unsigned char, unsigned char );
extern void set_tilemap_bitmap( unsigned char, unsigned short * );
extern unsigned char tilemap_scrollwrapclear( unsigned char );

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
extern void gpu_triangle( unsigned char, short, short, short, short, short, short );
extern void gpu_quadrilateral( unsigned char, short, short, short, short, short, short, short, short );
extern void gpu_outputstring( unsigned char, short, short, char *, unsigned char );
extern void gpu_outputstringcentre( unsigned char, short, short, char *, unsigned char );
extern void draw_vector_block( unsigned char, unsigned char, short, short );
extern void set_vector_vertex( unsigned char, unsigned char , unsigned char, char, char );
extern void bitmap_scrollwrap( unsigned char );
extern void set_blitter_bitmap( unsigned char, unsigned short * );

// SPRITES
extern void set_sprite( unsigned char, unsigned char, unsigned char, unsigned char, short, short, unsigned char, unsigned char );
extern unsigned short get_sprite_collision( unsigned char, unsigned char );
extern short get_sprite_attribute( unsigned char, unsigned char , unsigned char );
extern void set_sprite_attribute( unsigned char, unsigned char, unsigned char, short );
extern void update_sprite( unsigned char, unsigned char, unsigned short );
extern void set_sprite_bitmaps( unsigned char, unsigned char, unsigned short * );

// CHARACTER MAP
extern void tpu_cs( void );
extern void tpu_clearline( unsigned char );
extern void tpu_set(  unsigned char, unsigned char, unsigned char, unsigned char );
extern void tpu_output_character( char );
extern void tpu_outputstring( char * );
extern void tpu_outputstringcentre( unsigned char, unsigned char, unsigned char, char * );
extern void tpu_outputnumber_char( unsigned char );
extern void tpu_outputnumber_short( unsigned short );
extern void tpu_outputnumber_int( unsigned int );

// IMAGE DECODERS
extern void netppm_display( unsigned char *, unsigned char );
extern void netppm_decoder( unsigned char *, unsigned char * );
extern void bitmapblit( unsigned char *, unsigned short , unsigned short , short, short, unsigned char  );

// SMT START AND STOP
extern void SMTSTOP( void );
extern void SMTSTART( unsigned int );

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

#define DITHEROFF 0, BLACK
#define DITHERON 1
