#include "PAWS.h"

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

// PAWS LOGO BLITTER TILE
unsigned short PAWSLOGO[] = {
    0b0000000001000000,
    0b0000100011100000,
    0b0001110011100000,
    0b0001110011100000,
    0b0001111011100100,
    0b0000111001001110,
    0b0010010000001110,
    0b0111000000001110,
    0b0111000111001100,
    0b0111001111110000,
    0b0011011111111000,
    0b0000011111111000,
    0b0000011111111100,
    0b0000111111111100,
    0b0000111100001000,
    0b0000010000000000
};

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

// RISC-V CSR FUNCTIONS
unsigned int CSRisa() {
   unsigned int isa;
   asm volatile ("csrr %0, 0x301" : "=r"(isa));
   return isa;
}
// STANDARD C FUNCTIONS ( from @sylefeb mylibc )
void * memset(void *dest, int val, size_t len) {
  unsigned char *ptr = dest;
  while (len-- > 0)
    *ptr++ = val;
  return dest;
}

short strlen( char *s ) {
    short i = 0;
    while( *s ) {
        s++;
        i++;
    }
    return(i);
}

// TIMER AND PSEUDO RANDOM NUMBER GENERATOR
// SLEEP FOR counter milliseconds
void sleep( unsigned short counter ) {
    *SLEEPTIMER0 = counter;
    while( *SLEEPTIMER0 );
}

// SDCARD FUNCTIONS
// INTERNAL FUNCTION - WAIT FOR THE SDCARD TO BE READY
inline void sdcard_wait( void )  __attribute__((always_inline));
void sdcard_wait( void ) {
    while( !*SDCARD_READY );
}

// READ A SECTOR FROM THE SDCARD AND COPY TO MEMORY
void sdcard_readsector( unsigned int sectorAddress, unsigned char *copyAddress ) {
    sdcard_wait();
    *SDCARD_SECTOR_HIGH = ( sectorAddress & 0xffff0000 ) >> 16;
    *SDCARD_SECTOR_LOW = ( sectorAddress & 0x0000ffff );
    *SDCARD_START = 1;
    sdcard_wait();

    for( unsigned short i = 0; i < 512; i++ ) {
        *SDCARD_ADDRESS = i;
        copyAddress[ i ] = *SDCARD_DATA;
    }
}

// I/O FUNCTIONS
// READ THE ULX3S JOYSTICK BUTTONS
inline unsigned short get_buttons( void )  __attribute__((always_inline));
unsigned short get_buttons( void ) {
    return( *BUTTONS );
}

// WAIT FOR VBLANK TO START
void await_vblank( void ) {
    while( !*VBLANK );
}

// BACKGROUND GENERATOR
void set_background( unsigned char colour, unsigned char altcolour, unsigned char backgroundmode ) {
    *BACKGROUND_COPPER_STARTSTOP = 0;
    *BACKGROUND_COLOUR = colour;
    *BACKGROUND_ALTCOLOUR = altcolour;
    *BACKGROUND_MODE = backgroundmode;
}

// GPU AND BITMAP
// The bitmap is 640 x 480 pixels (0,0) is ALWAYS top left even if the bitmap has been offset
// The bitmap can be moved 1 pixel at a time LEFT, RIGHT, UP, DOWN for scrolling
// The GPU can draw pixels, filled rectangles, lines, (filled) circles, filled triangles and has a 16 x 16 pixel blitter from user definable tiles

// INTERNAL FUNCTION - WAIT FOR THE GPU TO FINISH THE LAST COMMAND
inline void wait_gpu( void )  __attribute__((always_inline));
void wait_gpu( void ) {
    while( *GPU_STATUS );
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
    wait_gpu();
    *BITMAP_SCROLLWRAP = 5;
    gpu_rectangle( 64, 0, 0, 319, 239 );
}

// DRAW A (optional filled) CIRCLE at centre (x1,y1) of radius ( FILLED CIRCLES HAVE A MINIMUM RADIUS OF 4 )
void gpu_circle( unsigned char colour, short x1, short y1, short radius, unsigned char filled ) {
    *GPU_COLOUR = colour;
    *GPU_X = x1;
    *GPU_Y = y1;
    *GPU_PARAM0 = radius;
    *GPU_PARAM1 = 255;

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
    *GPU_PARAM2 = 0; // NO REFLECTION

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
    *GPU_PARAM2 = 0; // NO REFLECTION

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
void gpu_outputstringcentre( unsigned char colour, short y, char *s, unsigned char size ) {
    gpu_rectangle( TRANSPARENT, 0, y, 319, y + ( 8 << size ) - 1 );
    gpu_outputstring( colour, 160 - ( ( ( 8 << size ) * strlen(s) ) >> 1) , y, s, size );
}

// SET THE BLITTER TILE to the 16 x 16 pixel bitmap
void set_blitter_bitmap( unsigned char tile, unsigned short *bitmap ) {
    *BLIT_WRITER_TILE = tile;

    for( short i = 0; i < 16; i ++ ) {
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

// STOP PIXEL BLOCK - SENT DURING RESET TO ENSURE GPU RESETS
void gpu_pixelblock_stop( void ) {
    *PB_STOP = 3;
}

// CLEAR THE CHARACTER MAP
void tpu_cs( void ) {
    while( *TPU_COMMIT );
    *TPU_COMMIT = 3;
}

// SET THE TILEMAP TILE at (x,y) to tile with colours background and foreground
void set_tilemap_tile( unsigned char tm_layer, unsigned char x, unsigned char y, unsigned char tile, unsigned char background, unsigned char foreground) {
    switch( tm_layer ) {
        case 0:
            while( *LOWER_TM_STATUS );
            *LOWER_TM_X = x;
            *LOWER_TM_Y = y;
            *LOWER_TM_TILE = tile;
            *LOWER_TM_BACKGROUND = background;
            *LOWER_TM_FOREGROUND = foreground;
            *LOWER_TM_COMMIT = 1;
            break;
        case 1:
            while( *UPPER_TM_STATUS );
            *UPPER_TM_X = x;
            *UPPER_TM_Y = y;
            *UPPER_TM_TILE = tile;
            *UPPER_TM_BACKGROUND = background;
            *UPPER_TM_FOREGROUND = foreground;
            *UPPER_TM_COMMIT = 1;
            break;
    }
}

// SCROLL WRAP or CLEAR the TILEMAP
//  action == 1 to 4 move the tilemap 1 pixel LEFT, UP, RIGHT, DOWN and SCROLL at limit
//  action == 5 to 8 move the tilemap 1 pixel LEFT, UP, RIGHT, DOWN and WRAP at limit
//  action == 9 clear the tilemap
//  RETURNS 0 if no action taken other than pixel shift, action if SCROLL WRAP or CLEAR was actioned
unsigned char tilemap_scrollwrapclear( unsigned char tm_layer, unsigned char action ) {
    switch( tm_layer ) {
        case 0:
            while( *LOWER_TM_STATUS );
            *LOWER_TM_SCROLLWRAPCLEAR = action;
            break;
        case 1:
            while( *UPPER_TM_STATUS );
            *UPPER_TM_SCROLLWRAPCLEAR = action;
            break;
    }
    return( tm_layer ? *UPPER_TM_SCROLLWRAPCLEAR : *LOWER_TM_SCROLLWRAPCLEAR );
}

// SMT START STOP
void SMTSTOP( void ) {
    *SMTSTATUS = 0;
}
void SMTSTART( unsigned int code ) {
    *SMTPCH = ( code & 0xffff0000 ) >> 16;
    *SMTPCL = ( code & 0x0000ffff );
    *SMTSTATUS = 1;
}

// MASTER BOOT RECORD AND PARTITION TABLE, STORED FROM TOP OF MEMORY
unsigned char *MBR = (unsigned char *) 0x12000000 - 0x200;
Fat16BootSector *BOOTSECTOR = (Fat16BootSector *)0x12000000 - 0x400;
PartitionTable *PARTITION;
Fat16Entry *ROOTDIRECTORY;
unsigned short *FAT;
unsigned char *CLUSTERBUFFER;
unsigned int DATASTARTSECTOR;

// SELECTED PARITION ( 0xff indicates no FAT16 partition found ) SELECTED FILE ( 0xffff indicates no file selected )
unsigned short SELECTEDFILE = 0xffff;
unsigned char PARTITIONNUMBER = 0xff;

// READ SECTOR, FLASHING INDICATOR
void sd_readSector( unsigned int sectorAddress, unsigned char *copyAddress ) {
    gpu_blit( RED, 256, 2, 2, 2 );
    sdcard_readsector( sectorAddress, copyAddress );
    gpu_blit( GREEN, 256, 2, 2, 2 );
}

void sd_readSectors( unsigned int start_sector, unsigned int number_of_sectors, unsigned char *copyaddress ) {
    for( unsigned int i = 0; i < number_of_sectors; i++ )
        sd_readSector( start_sector + i, copyaddress + 512 * i );
}

// READ FILE ALLOCATION TABLE
void sd_readFAT( void ) {
    unsigned short i;

    // READ ALL OF THE SECTORS OF THE FAT
    sd_readSectors( PARTITION[PARTITIONNUMBER].start_sector + BOOTSECTOR -> reserved_sectors + BOOTSECTOR -> fat_size_sectors, BOOTSECTOR -> fat_size_sectors, (unsigned char *)FAT );
}

// READ ROOT DIRECTORY
void sd_readRootDirectory ( void ) {
    unsigned short i;

    // READ ALL OF THE SECTORS OF THE ROOTDIRECTORY
    sd_readSectors( PARTITION[PARTITIONNUMBER].start_sector + BOOTSECTOR -> reserved_sectors + BOOTSECTOR -> fat_size_sectors * BOOTSECTOR -> number_of_fats, ( BOOTSECTOR -> root_dir_entries * sizeof( Fat16Entry ) ) / 512, (unsigned char *)ROOTDIRECTORY );
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

void draw_paws_logo( void ) {
    set_blitter_bitmap( 3, &PAWSLOGO[0] );
    gpu_blit( BLUE, 2, 2, 3, 2 );
}

void draw_sdcard( void  ) {
    set_blitter_bitmap( 0, &sdcardtiles[0] );
    set_blitter_bitmap( 1, &sdcardtiles[16] );
    set_blitter_bitmap( 2, &sdcardtiles[32] );
    gpu_blit( BLUE, 256, 2, 1, 2 );
    gpu_blit( WHITE, 256, 2, 0, 2 );
}

void reset_display( void ) {
    gpu_pixelblock_stop();
    *GPU_DITHERMODE = 0;
    *CROP_LEFT = 0; *CROP_RIGHT = 319; *CROP_TOP = 0; *CROP_BOTTOM = 239;
    *FRAMEBUFFER_DRAW = 1; gpu_cs(); while( !*GPU_FINISHED );
    *FRAMEBUFFER_DRAW = 0; gpu_cs(); while( !*GPU_FINISHED );
    *FRAMEBUFFER_DISPLAY = 0;
    *SCREENMODE = 0;
    *TPU_CURSOR = 0; tpu_cs();
    *LOWER_TM_SCROLLWRAPCLEAR = 9;
    *UPPER_TM_SCROLLWRAPCLEAR = 9;
    for( unsigned short i = 0; i < 16; i++ ) {
        LOWER_SPRITE_ACTIVE[i] = 0;
        UPPER_SPRITE_ACTIVE[i] = 0;
    }
}

void displayfilename( void ) {
    unsigned char displayname[9], i, j;
    gpu_outputstringcentre( WHITE, 144, "Current PAW File:", 0 );
    for( i = 0; i < 9; i++ ) {
        displayname[i] = 0;
    }
    j = 0;
    for( i = 0; i < 8; i++ ) {
        if( ROOTDIRECTORY[SELECTEDFILE].filename[i] != ' ' ) {
            displayname[j++] = ROOTDIRECTORY[SELECTEDFILE].filename[i];
        }
    }
    gpu_outputstringcentre( WHITE, 176, displayname, 2 );
}

void waitbuttonrelease( void ) {
    while( get_buttons() != 1 );
}

void scrollbars( void ) {
    short count = 0;
    while(1) {
        await_vblank();count++;
        if( count == 32 ) {
            tilemap_scrollwrapclear( 0, 7 );
            tilemap_scrollwrapclear( 1, 5 );
            count = 0;
        }
    }
}

void smtthread( void ) {
    // SETUP STACKPOINTER FOR THE SMT THREAD
    asm volatile ("li sp ,0x4000");
    scrollbars();
    SMTSTOP();
}

extern int _bss_start, _bss_end;
void main( void ) {
    unsigned int isa;
    unsigned short i, j;
    unsigned short selectedfile = 0;

    // STOP SMT
    SMTSTOP();

    // CLEAR MEMORY
    memset( &_bss_start, 0, &_bss_end - &_bss_end );

    // RESET THE DISPLAY
    reset_display();
    set_background( DKBLUE - 1, BLACK, BKG_SOLID );

    // KEYBOARD INTO JOYSTICK MODE
    *PS2_MODE = 0;

    // DRAW LOGO AND SDCARD
    // COLOUR BARS ON THE TILEMAP - SCROLL WITH SMT THREAD
    draw_paws_logo();
    draw_sdcard();
    for( i = 0; i < 42; i++ ) {
        set_tilemap_tile( 0, i, 21, 0, i, 0 );
        set_tilemap_tile( 1, i, 27, 0, 63 - i, 0 );
    }
    SMTSTART( (unsigned int )smtthread );

    gpu_outputstring( WHITE, 66, 2, "PAWS", 2 );
    gpu_outputstring( WHITE, 66, 34, "Risc-V RV32IMAFC CPU", 0 );
    gpu_outputstringcentre( GREY2, 224, "PAWS for ULX3S by Rob S in Silice", 0);

    // CLEAR UART AND PS/2 BUFFERS
    while( *UART_STATUS & 1 ) { char temp = *UART_DATA; }
    while( *PS2_AVAILABLE ) { short temp = *PS2_DATA; }

    gpu_outputstringcentre( RED, 72, "Waiting for SDCARD", 0 );
    sleep( 1000 );
    sd_readSector( 0, MBR );
    gpu_outputstringcentre( GREEN, 72, "SDCARD Ready", 0 );

    PARTITION = (PartitionTable *) &MBR[ 0x1BE ];

    // CHECK FOR VALID PARTITION - USE FIRST FAT16 PARTITION FOUND
    for( i = 0; i < 4; i++ && ( PARTITIONNUMBER != 0xff ) ) {
        switch( PARTITION[i].partition_type ) {
            case 4:
            case 6:
            case 14: PARTITIONNUMBER = i;
                break;
            default:
                break;
        }
    }

    // NO FAT16 PARTITION FOUND
    if( PARTITIONNUMBER == 0xff ) {
        gpu_outputstringcentre( RED, 72, "ERROR", 2 );
        gpu_outputstringcentre( RED, 120, "Please Insert AN SDCARD", 0 );
        gpu_outputstringcentre( RED, 128, "WITH A FAT16 PARTITION", 0 );
        gpu_outputstringcentre( RED, 136, "Press RESET", 0 );
        while(1) {}
    }

    // READ BOOTSECTOR FOR PARTITION 0
    sd_readSector( PARTITION[PARTITIONNUMBER].start_sector, (unsigned char *)BOOTSECTOR );

    // PARSE BOOTSECTOR AND ALLOCASTE MEMORY FOR ROOTDIRECTORY, FAT, CLUSTERBUFFER
    ROOTDIRECTORY = (Fat16Entry *)( 0x12000000 - 0x400 - BOOTSECTOR -> root_dir_entries * sizeof( Fat16Entry ) );
    FAT = (unsigned short * ) ROOTDIRECTORY - BOOTSECTOR -> fat_size_sectors * 512;
    CLUSTERBUFFER = (unsigned char * )FAT - BOOTSECTOR -> sectors_per_cluster * 512;
    DATASTARTSECTOR = PARTITION[PARTITIONNUMBER].start_sector + BOOTSECTOR -> reserved_sectors + BOOTSECTOR -> fat_size_sectors * BOOTSECTOR -> number_of_fats + ( BOOTSECTOR -> root_dir_entries * sizeof( Fat16Entry ) ) / 512;

    // READ ROOT DIRECTORY AND FAT INTO MEMORY
    sd_readRootDirectory();
    sd_readFAT();

    // FILE SELECTOR
    gpu_outputstringcentre( WHITE, 72, "Select PAW File", 0 );
    gpu_outputstringcentre( WHITE, 88, "SELECT USING FIRE 1", 0 );
    gpu_outputstringcentre( WHITE, 96, "SCROLL USING LEFT & RIGHT", 0 );
    gpu_outputstringcentre( RED, 144, "No PAW Files Found", 0 );
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

    gpu_outputstringcentre( WHITE, 72, "PAW File", 0 );
    gpu_outputstringcentre( WHITE, 80, "SELECTED", 0 );
    gpu_outputstringcentre( WHITE, 88, "", 0 );
    gpu_outputstringcentre( WHITE, 96, "", 0 );
    sleep( 500 );
    gpu_outputstringcentre( WHITE, 80, "LOADING", 0 );
    sd_readFile( SELECTEDFILE, (unsigned char *)0x10000000 );
    gpu_outputstringcentre( WHITE, 72, "LOADED", 0 );
    gpu_outputstringcentre( WHITE, 80, "LAUNCHING", 0 );
    sleep(500);

    // STOP SMT
    SMTSTOP();

    // RESET THE DISPLAY
    reset_display();
    set_background( BLACK, BLACK, BKG_SOLID );

    // CALL SDRAM LOADED PROGRAM
    ((void(*)(void))0x10000000)();
    // RETURN TO BIOS IF PROGRAM EXITS
    ((void(*)(void))0x00000000)();
}
