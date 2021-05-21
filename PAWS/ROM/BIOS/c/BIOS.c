#include "PAWS.h"

// STDDEF.H DEFINITIONS
 #define max(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a > _b ? _a : _b; })

#define min(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a < _b ? _a : _b; })

typedef unsigned int size_t;

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
#define RED 0x30
#define DKRED 0x20
#define MAGENTA 0x33
#define PURPLE 0x13
#define YELLOW 0x3c
#define WHITE 0x3f
#define GREY1 0x15
#define GREY2 0x2a
#define ORANGE 0x38

// STANDARD C FUNCTIONS ( from @sylefeb mylibc )
void*  memcpy(void *dest, const void *src, size_t n) {
  const void *end = src + n;
  const unsigned char *bsrc = (const unsigned char *)src;
  while (bsrc != end) {
    *(unsigned char*)dest = *(++bsrc);
  }
  return dest;
}
void *memset(void *s, int c,  unsigned int n) {
    unsigned char* p = s;
    while( n-- )
        *p++ = (unsigned char)c;
    return(0);
}

int strlen( char *s ) {
    int i = 0;
    while( *s ) {
        s++;
        i++;
    }
    return(i);
}

int strcmp(const char *p1, const char *p2) {
  while (*p1 && (*p1 == *p2)) {
    p1++; p2++;
  }
  return *(const unsigned char*)p1 - *(const unsigned char*)p2;
}

// RISC-V CSR FUNCTIONS
long CSRcycles() {
   int cycles;
   asm volatile ("rdcycle %0" : "=r"(cycles));
   return cycles;
}

long CSRinstructions() {
   int insns;
   asm volatile ("rdinstret %0" : "=r"(insns));
   return insns;
}

long CSRtime() {
  int time;
  asm volatile ("rdtime %0" : "=r"(time));
  return time;
}

// TIMER AND PSEUDO RANDOM NUMBER GENERATOR
// SLEEP FOR counter milliseconds
void sleep( unsigned short counter ) {
    *SLEEPTIMER0 = counter;
    while( *SLEEPTIMER0 );
}

// SDCARD FUNCTIONS
// INTERNAL FUNCTION - WAIT FOR THE SDCARD TO BE READY
void sdcard_wait( void ) {
    while( *SDCARD_READY == 0 ) {}
}

// READ A SECTOR FROM THE SDCARD AND COPY TO MEMORY
void sdcard_readsector( unsigned int sectorAddress, unsigned char *copyAddress ) {
    unsigned short i;

    sdcard_wait();
    *SDCARD_SECTOR_HIGH = ( sectorAddress & 0xffff0000 ) >> 16;
    *SDCARD_SECTOR_LOW = ( sectorAddress & 0x0000ffff );
    *SDCARD_START = 1;
    sdcard_wait();

    for( i = 0; i < 512; i++ ) {
        *SDCARD_ADDRESS = i;
        copyAddress[ i ] = *SDCARD_DATA;
    }
}

// I/O FUNCTIONS
// SET THE LEDS
void set_leds( unsigned char value ) {
    *LEDS = value;
}

// READ THE ULX3S JOYSTICK BUTTONS
unsigned char get_buttons( void ) {
    return( *BUTTONS );
}

// SET THE LAYER ORDER FOR THE DISPLAY
void screen_mode( unsigned char screenmode ) {
    *SCREENMODE = screenmode;
}

// BACKGROUND GENERATOR
void set_background( unsigned char colour, unsigned char altcolour, unsigned char backgroundmode ) {
    *BACKGROUND_COPPER_STARTSTOP = 0;
    *BACKGROUND_COLOUR = colour;
    *BACKGROUND_ALTCOLOUR = altcolour;
    *BACKGROUND_MODE = backgroundmode;
}

// SCROLL WRAP or CLEAR the TILEMAP
//  action == 1 to 4 move the tilemap 1 pixel LEFT, UP, RIGHT, DOWN and SCROLL at limit
//  action == 5 to 8 move the tilemap 1 pixel LEFT, UP, RIGHT, DOWN and WRAP at limit
//  action == 9 clear the tilemap
//  RETURNS 0 if no action taken other than pixel shift, action if SCROLL WRAP or CLEAR was actioned
unsigned char tilemap_scrollwrapclear( unsigned char tm_layer, unsigned char action ) {
    switch( tm_layer ) {
        case 0:
            while( *LOWER_TM_STATUS != 0 );
            *LOWER_TM_SCROLLWRAPCLEAR = action;
            return( *LOWER_TM_SCROLLWRAPCLEAR );
            break;
        case 1:
            while( *UPPER_TM_STATUS != 0 );
            *UPPER_TM_SCROLLWRAPCLEAR = action;
            return( *UPPER_TM_SCROLLWRAPCLEAR );
            break;
    }
}

// GPU AND BITMAP
// The bitmap is 640 x 480 pixels (0,0) is ALWAYS top left even if the bitmap has been offset
// The bitmap can be moved 1 pixel at a time LEFT, RIGHT, UP, DOWN for scrolling
// The GPU can draw pixels, filled rectangles, lines, (filled) circles, filled triangles and has a 16 x 16 pixel blitter from user definable tiles

// INTERNAL FUNCTION - WAIT FOR THE GPU TO FINISH THE LAST COMMAND
void wait_gpu( void ) {
    while( *GPU_STATUS != 0 );
}

// SCROLL THE BITMAP by 1 pixel
//  action == 1 LEFT, == 2 UP, == 3 RIGHT, == 4 DOWN, == 5 RESET
void bitmap_scrollwrap( unsigned char action ) {
    wait_gpu();
    *BITMAP_SCROLLWRAP = action;
}

// DRAW A FILLED RECTANGLE from (x1,y1) to (x2,y2) in colour
void gpu_rectangle( unsigned char colour, short x1, short y1, short x2, short y2 ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;

    wait_gpu();
    *GPU_WRITE = 3;
}

// CLEAR THE BITMAP by drawing a transparent rectangle from (0,0) to (639,479) and resetting the bitamp scroll position
void gpu_cs( void ) {
    bitmap_scrollwrap( 5 );
    gpu_rectangle( 64, 0, 0, 319, 239 );
}

// DRAW A LINE FROM (x1,y1) to (x2,y2) in colour - uses Bresenham's Line Drawing Algorithm
void gpu_line( unsigned char colour, short x1, short y1, short x2, short y2 ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;

    wait_gpu();
    *GPU_WRITE = 2;
}

// DRAW A (optional filled) CIRCLE at centre (x1,y1) of radius ( FILLED CIRCLES HAVE A MINIMUM RADIUS OF 4 )
void gpu_circle( unsigned char colour, short x1, short y1, short radius, unsigned char filled ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = radius;

    wait_gpu();
    *GPU_WRITE = filled ? 5 : 4;
}

// BLIT A 16 x 16 ( blit_size == 1 doubled to 32 x 32 ) TILE ( from tile 0 to 31 ) to (x1,y1) in colour
void gpu_blit( unsigned char colour, short x1, short y1, short tile, unsigned char blit_size ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = tile;
    *GPU_PARAM1 = blit_size;

    wait_gpu();
    *GPU_WRITE = 7;
}

// BLIT AN 8 x8  ( blit_size == 1 doubled to 16 x 16, blit_size == 1 doubled to 32 x 32 ) CHARACTER ( from tile 0 to 255 ) to (x1,y1) in colour
void gpu_character_blit( unsigned char colour, short x1, short y1, unsigned char tile, unsigned char blit_size ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = tile;
    *GPU_PARAM1 = blit_size;

    wait_gpu();
    *GPU_WRITE = 8;
}

// OUTPUT A STRING TO THE GPU
void gpu_outputstring( unsigned char colour, short x, short y, char *s, unsigned char size ) {
    while( *s ) {
        gpu_character_blit( colour, x, y, *s++, size );
        x = x + ( 8 << size );
    }
}
// SET THE BLITTER TILE to the 16 x 16 pixel bitmap
void set_blitter_bitmap( unsigned char tile, unsigned short *bitmap ) {
    *BLIT_WRITER_TILE = tile;

    for( int i = 0; i < 16; i ++ ) {
        *BLIT_WRITER_LINE = i;
        *BLIT_WRITER_BITMAP = bitmap[i];
    }
}

// DRAW A FILLED TRIANGLE with vertices (x1,y1) (x2,y2) (x3,y3) in colour
// VERTICES SHOULD BE PRESENTED CLOCKWISE FROM THE TOP ( minimal adjustments made to the vertices to comply )
void gpu_triangle( unsigned char colour, short x1, short y1, short x2, short y2, short x3, short y3 ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = x2;
    *GPU_PARAM1 = y2;
    *GPU_PARAM2 = x3;
    *GPU_PARAM3 = y3;

    wait_gpu();
    *GPU_WRITE = 6;
}

// SET SPRITE sprite_number in sprite_layer to active status, in colour to (x,y) with bitmap number tile ( 0 - 7 ) in sprite_size == 0 16 x 16 == 1 32 x 32 pixel size
void set_sprite( unsigned char sprite_layer, unsigned char sprite_number, unsigned char active, unsigned char colour, short x, short y, unsigned char tile, unsigned char sprite_size) {
    switch( sprite_layer ) {
        case 0:
            LOWER_SPRITE_ACTIVE[sprite_number] = active;
            LOWER_SPRITE_TILE[sprite_number] = tile;
            LOWER_SPRITE_COLOUR[sprite_number] = colour;
            LOWER_SPRITE_X[sprite_number] = x;
            LOWER_SPRITE_Y[sprite_number] = y;
            LOWER_SPRITE_DOUBLE[sprite_number] = sprite_size;
            break;

        case 1:
            UPPER_SPRITE_ACTIVE[sprite_number] = active;
            UPPER_SPRITE_TILE[sprite_number] = tile;
            UPPER_SPRITE_COLOUR[sprite_number] = colour;
            UPPER_SPRITE_X[sprite_number] = x;
            UPPER_SPRITE_Y[sprite_number] = y;
            UPPER_SPRITE_DOUBLE[sprite_number] = sprite_size;
            break;
    }
}

// CHARACTER MAP FUNCTIONS
// The character map is an 80 x 30 character window with a 256 character 8 x 16 pixel character generator ROM )
// NO SCROLLING, CURSOR WRAPS TO THE TOP OF THE SCREEN

// CLEAR THE CHARACTER MAP
void tpu_cs( void ) {
    while( *TPU_COMMIT );
    *TPU_COMMIT = 3;
}

// CLEAR A LINE
void tpu_clearline( unsigned char y ) {
    while( *TPU_COMMIT );
    *TPU_Y = y;
    *TPU_COMMIT = 4;
}

// POSITION THE CURSOR to (x,y) and set background and foreground colours
void tpu_set(  unsigned char x, unsigned char y, unsigned char background, unsigned char foreground ) {
    while( *TPU_COMMIT );
    *TPU_X = x; *TPU_Y = y; *TPU_BACKGROUND = background; *TPU_FOREGROUND = foreground; *TPU_COMMIT = 1;
}

// OUTPUT A CHARACTER TO THE CHARACTER MAP
void tpu_output_character( char c ) {
    while( *TPU_COMMIT );
    *TPU_CHARACTER = c; *TPU_COMMIT = 2;
}

// OUTPUT A NULL TERMINATED STRING TO THE CHARACTER MAP
void tpu_outputstring( char *s ) {
    while( *s ) {
        while( *TPU_COMMIT );
        *TPU_CHARACTER = *s; *TPU_COMMIT = 2;
        s++;
    }
}

void tpu_outputstringcentre( unsigned char y, unsigned char background, unsigned char foreground, char *s ) {
    tpu_clearline( y );
    tpu_set( 40 - ( strlen(s) >> 1 ), y, background, foreground );
    tpu_outputstring( s );
}

typedef unsigned int size_t;

// SDCARD BLITTER TILES
unsigned short sdcardtiles[] = {
    // CARD
    0x0000, 0x0000, 0x0ec0, 0x08a0, 0xea0, 0x02a0, 0x0ec0, 0x0000,
    0x0a60, 0x0a80, 0x0e80, 0xa80, 0x0a60, 0x0000, 0x0000, 0x0000,
    // SDHC
    0x3ff0, 0x3ff8, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ff8, 0x1ffc, 0x1ffc,
    0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc,
    // LED INDICATOR
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0018, 0x0018, 0x0000
};

// MASTER BOOT RECORD AND PARTITION TABLE, STORED FROM TOP OF MEMORY
unsigned char *MBR = (unsigned char *) 0x12000000 - 0x200;
Fat16BootSector *BOOTSECTOR = (Fat16BootSector *)0x12000000 - 0x400;
PartitionTable *PARTITION;
Fat16Entry *ROOTDIRECTORY;
unsigned short *FAT;
unsigned char *CLUSTERBUFFER;
unsigned int DATASTARTSECTOR;

// SELECTED FILE ( 0xffff indicates no file selected )
unsigned short SELECTEDFILE = 0xffff;

// READ SECTOR, FLASHING INDICATOR
void sd_readSector( unsigned int sectorAddress, unsigned char *copyAddress ) {
    unsigned short i;

    gpu_blit( RED, 256, 2, 2, 2 );
    sdcard_readsector( sectorAddress, copyAddress );
    gpu_blit( GREEN, 256, 2, 2, 2 );
}

// READ SECTOR 0, THE MASTER BOOT RECORD
void sd_readMBR( void ) {
    // FOR COPYING DATA
    unsigned short i;
    unsigned char *copyaddress;

    sd_readSector( 0, MBR );
}

void sd_readSectors( unsigned int start_sector, unsigned int number_of_sectors, unsigned char *copyaddress ) {
    for( unsigned int i = 0; i < number_of_sectors; i++ )
        sd_readSector( start_sector + i, copyaddress + 512 * i );
}

// READ FILE ALLOCATION TABLE
void sd_readFAT( void ) {
    unsigned short i;

    // READ ALL OF THE SECTORS OF THE FAT
    sd_readSectors( PARTITION[0].start_sector + BOOTSECTOR -> reserved_sectors + BOOTSECTOR -> fat_size_sectors, BOOTSECTOR -> fat_size_sectors, (unsigned char *)FAT );
}

// READ ROOT DIRECTORY
void sd_readRootDirectory ( void ) {
    unsigned short i;

    // READ ALL OF THE SECTORS OF THE ROOTDIRECTORY
    sd_readSectors( PARTITION[0].start_sector + BOOTSECTOR -> reserved_sectors + BOOTSECTOR -> fat_size_sectors * BOOTSECTOR -> number_of_fats, ( BOOTSECTOR -> root_dir_entries * sizeof( Fat16Entry ) ) / 512, (unsigned char *)ROOTDIRECTORY );
}

// READ A FILE CLUSTER ( the minimum size of a file in FAT16 )
void sd_readCluster( unsigned short cluster ) {
    sd_readSectors( DATASTARTSECTOR + ( cluster - 2 ) * BOOTSECTOR -> sectors_per_cluster, BOOTSECTOR -> sectors_per_cluster, CLUSTERBUFFER );
}

unsigned short checkextension( unsigned short i ) {
    return( ROOTDIRECTORY[i].ext[0]=='P' && ROOTDIRECTORY[i].ext[1]=='A' && ROOTDIRECTORY[i].ext[2]=='W' );
}

// SEARCH FOR THE NEXT PAW FILE, WILL LOCK IF NO FILE FOUND
void sd_findFile( unsigned short direction ) {
    unsigned short i = ( SELECTEDFILE == 0xffff ) ? 0 : ( direction ? SELECTEDFILE + 1 : SELECTEDFILE - 1 );
    unsigned short filefound = 0;

    while( !filefound ) {
        switch( ROOTDIRECTORY[i].filename[0] ) {
            // NOT TRUE FILES ( deleted, directory pointer )
            case 0x00:
            case 0xe5:
            case 0x05:
            case 0x2e:
                if( direction ) {
                    i = ( i < BOOTSECTOR -> root_dir_entries ) ? i + 1 : 0;
                } else {
                    i = ( i == 0 ) ? BOOTSECTOR -> root_dir_entries - 1 : i - 1;
                }
                break;

            default:
                if( checkextension( i ) ) {
                    SELECTEDFILE = i;
                    filefound = 1;
                } else {
                    if( direction ) {
                        i = ( i < BOOTSECTOR -> root_dir_entries ) ? i + 1 : 0;
                    } else {
                        i = ( i == 0 ) ? BOOTSECTOR -> root_dir_entries - 1 : i - 1;
                    }
                }
                break;
        }
    }
}

unsigned int sdcard_findfilesize( unsigned short filenumber ) {
    return( ROOTDIRECTORY[filenumber].file_size );
}

// READ A FILE CLUSTER BY CLUSTER INTO MEMORY
void sd_readFile( unsigned short filenumber, unsigned char * copyAddress ) {
    unsigned short nextCluster = ROOTDIRECTORY[ filenumber ].starting_cluster;
    int i;

    do {
        sd_readCluster( nextCluster );
        for( i = 0; i < BOOTSECTOR -> sectors_per_cluster * 512; i++ ) {
            *copyAddress = CLUSTERBUFFER[i];
            copyAddress++;
        }
        nextCluster = FAT[ nextCluster ];
    } while( nextCluster != 0xffff );
}

void draw_riscv_logo( void ) {
    gpu_rectangle( ORANGE, 0, 0, 100, 100 );
    gpu_triangle( WHITE, 100, 33, 100, 100, 50, 100 );
    gpu_triangle( DKBLUE, 100, 50, 100, 100, 66, 100 );
    gpu_rectangle( DKBLUE, 0, 0, 33, 50 );
    gpu_circle( WHITE, 25, 25, 26, 1 );
    gpu_rectangle( WHITE, 0, 0, 25, 12 );
    gpu_circle( DKBLUE, 25, 25, 12, 1 );
    gpu_triangle( WHITE, 0, 33, 67, 100, 0, 100 );
    gpu_triangle( DKBLUE, 0, 50, 50, 100, 0, 100 );
    gpu_rectangle( DKBLUE, 0, 12, 25, 37 );
    gpu_rectangle( DKBLUE, 0, 37, 8, 100 );
}

void set_sdcard_bitmap( void ) {
    set_blitter_bitmap( 0, &sdcardtiles[0] );
    set_blitter_bitmap( 1, &sdcardtiles[16] );
    set_blitter_bitmap( 2, &sdcardtiles[32] );
}

void draw_sdcard( void  ) {
    gpu_blit( BLUE, 256, 2, 1, 2 );
    gpu_blit( WHITE, 256, 2, 0, 2 );
}

void reset_display( void ) {
    *GPU_DITHERMODE = 0;
    *FRAMEBUFFER_DRAW = 1; gpu_cs();
    *FRAMEBUFFER_DRAW = 0; gpu_cs();
    *FRAMEBUFFER_DISPLAY = 0;
    tpu_cs();
    screen_mode( 0 );
    tilemap_scrollwrapclear( 0, 9 );
    tilemap_scrollwrapclear( 1, 9 );
    for( unsigned short i = 0; i < 16; i++ ) {
        set_sprite( 0, i, 0, 0, 0, 0, 0, 0 );
        set_sprite( 1, i, 0, 0, 0, 0, 0, 0 );
    }
}

void displayfilename( void ) {
    tpu_outputstringcentre( 18, TRANSPARENT, WHITE, "Current PAW File:" );
    for( unsigned short i = 0; i < 8; i++ ) {
        // DISPLAY FILENAME
        gpu_rectangle( TRANSPARENT, 0, 192, 319, 224 );
        for( i = 0; i < 8; i++ ) {
            gpu_character_blit( WHITE, 32 + i * 32, 192, ROOTDIRECTORY[SELECTEDFILE].filename[i], 2);
        }
    }
}

void waitbuttonrelease( void ) {
    while( get_buttons() != 1 );
}

void main( void ) {
    unsigned short i,j;
    unsigned char uartData = 0;
    unsigned short selectedfile = 0;
    //unsigned int *sdramaddress;

    // STOP SMT
    *SMTSTATUS = 0;

    // RESET THE DISPLAY
    reset_display();
    set_background( DKBLUE - 1, BLACK, BKG_SOLID );

    // SETUP INITIAL WELCOME MESSAGE
    draw_riscv_logo();
    set_sdcard_bitmap();
    draw_sdcard();
    gpu_outputstring( WHITE, 104, 4, "PAWS", 2 );
    tpu_set( 26, 4, TRANSPARENT, WHITE ); tpu_outputstring( "RISC-V RV32IMCB CPU" );

    for( unsigned short i = 0; i < 64; i++ ) {
        gpu_rectangle( i, i * 5, 184, 4 + i * 5, 188 );
        gpu_rectangle( i, i * 5, 227, 4 + i * 5, 231 );
    }

    tpu_outputstringcentre( 15, TRANSPARENT, RED, "Waiting for SDCARD" );
    sleep(2000);
    sd_readSector( 0, MBR );
    tpu_outputstringcentre( 15, TRANSPARENT, GREEN, "SDCARD Ready" );

    PARTITION = (PartitionTable *) &MBR[ 0x1BE ];

    // CHECK FOR VALID PARTITION
    switch( PARTITION[0].partition_type ) {
        case 4:
        case 6:
        case 14:
            break;
        default:
            // UNKNOWN PARTITION TYPE
            tpu_outputstringcentre( 15, TRANSPARENT, RED, "Please Insert A FAT16 SDCARD and Press RESET" );
            while(1) {}
            break;
    }

    // READ BOOTSECTOR FOR PARTITION 0
    sd_readSector( PARTITION[0].start_sector, (unsigned char *)BOOTSECTOR );

    // PARSE BOOTSECTOR AND ALLOCASTE MEMORY FOR ROOTDIRECTORY, FAT, CLUSTERBUFFER
    ROOTDIRECTORY = (Fat16Entry *)( 0x12000000 - 0x400 - BOOTSECTOR -> root_dir_entries * sizeof( Fat16Entry ) );
    FAT = (unsigned short * ) ROOTDIRECTORY - BOOTSECTOR -> fat_size_sectors * 512;
    CLUSTERBUFFER = (unsigned char * )FAT - BOOTSECTOR -> sectors_per_cluster * 512;
    DATASTARTSECTOR = PARTITION[0].start_sector + BOOTSECTOR -> reserved_sectors + BOOTSECTOR -> fat_size_sectors * BOOTSECTOR -> number_of_fats + ( BOOTSECTOR -> root_dir_entries * sizeof( Fat16Entry ) ) / 512;

    // READ ROOT DIRECTORY AND FAT INTO MEMORY
    sd_readRootDirectory();
    sd_readFAT();

    // FILE SELECTOR
    tpu_outputstringcentre( 15, TRANSPARENT, WHITE, "Select PAW File" );
    tpu_outputstringcentre( 16, TRANSPARENT, WHITE, "SELECT USING FIRE 1 - SCROLL USING LEFT & RIGHT" );
    tpu_outputstringcentre( 18, TRANSPARENT, RED, "No PAW Files Found" );
    SELECTEDFILE = 0xffff;

    // FILE SELECTOR, LOOP UNTIL FILE SELECTED (FIRE 1 PRESSED WITH A VALID FILE)
    while( !selectedfile ) {
        // RIGHT - SEARCH FOR NEXT FILE
        if( ( get_buttons() & 64 ) || ( SELECTEDFILE == 0xffff ) ) {
            waitbuttonrelease();
            sd_findFile(1);
            displayfilename();
        }
        // LEFT - SEARCH FOR PREVIOUS FILE
        if( ( get_buttons() & 32 ) || ( SELECTEDFILE == 0xffff ) ) {
            waitbuttonrelease();
            sd_findFile(0);
            displayfilename();
        }
        // FIRE 1 - SELECT FILE
        if( ( get_buttons() & 2 ) && ( SELECTEDFILE != 0xffff ) ) {
            waitbuttonrelease();
            selectedfile = 1;
        }
    }

    tpu_outputstringcentre( 15, TRANSPARENT, WHITE, "PAW File" );
    tpu_outputstringcentre( 16, TRANSPARENT, WHITE, "SELECTED" );
    sleep( 500 );
    tpu_outputstringcentre( 16, TRANSPARENT, WHITE, "LOADING" );
    sd_readFile( SELECTEDFILE, (unsigned char *)0x10000000 );
    tpu_outputstringcentre( 15, TRANSPARENT, WHITE, "LOADED" );
    tpu_outputstringcentre( 16, TRANSPARENT, WHITE, "LAUNCHING" );
    sleep(500);

    // RESET THE DISPLAY
    reset_display();
    set_background( BLACK, BLACK, BKG_SOLID );

    // CALL SDRAM LOADED PROGRAM
    ((void(*)(void))0x10000000)();
}
