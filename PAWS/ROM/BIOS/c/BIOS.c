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
void *memset(void *dest, int val, size_t len) {
  unsigned char *ptr = dest;
  while (len-- > 0)
    *ptr++ = val;
  return dest;
}

void *memcpy( void *dest, void *src, size_t len ) {
  unsigned char *ptr = dest, *ptr2 = src;
  while (len-- > 0)
    *ptr++ = *ptr2++;
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
    gpu_rectangle( 64, 0, 0, 319, 239 );
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
void gpu_character_blit( unsigned char colour, short x1, short y1, unsigned short tile, unsigned char blit_size ) {
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
void gpu_outputstring( unsigned char colour, short x, short y, char bold, char *s, unsigned char size ) {
    while( *s ) {
        gpu_character_blit( colour, x, y, ( bold ? 256 : 0 ) + *s++, size );
        x = x + ( 8 << size );
    }
}
void gpu_outputstringcentre( unsigned char colour, short y, char bold, char *s, unsigned char size ) {
    gpu_rectangle( TRANSPARENT, 0, y, 319, y + ( 8 << size ) - 1 );
    gpu_outputstring( colour, 160 - ( ( ( 8 << size ) * strlen(s) ) >> 1) , y, bold, s, size );
}

// SET THE BLITTER TILE to the 16 x 16 pixel bitmap
void set_blitter_bitmap( unsigned char tile, unsigned short *bitmap ) {
    *BLIT_WRITER_TILE = tile;

    for( short i = 0; i < 16; i ++ ) {
        *BLIT_WRITER_LINE = i;
        *BLIT_WRITER_BITMAP = bitmap[i];
    }
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
    *SCREENMODE = 0; *COLOUR = 1;
    *TPU_CURSOR = 0; tpu_cs();
    *TERMINAL_SHOW = 0; *TERMINAL_RESET = 1;
    *LOWER_TM_SCROLLWRAPCLEAR = 9;
    *UPPER_TM_SCROLLWRAPCLEAR = 9;
    for( unsigned short i = 0; i < 16; i++ ) {
        LOWER_SPRITE_ACTIVE[i] = 0;
        UPPER_SPRITE_ACTIVE[i] = 0;
    }
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

// DISPLAY FILENAME, ADD AN ARROW IN FRONT OF DIRECTORIES
void displayfilename( unsigned char *filename, unsigned char type ) {
    unsigned char displayname[10], i, j;
    gpu_outputstringcentre( WHITE, 144, 0, "Current PAW File:", 0 );
    for( i = 0; i < 10; i++ ) {
        displayname[i] = 0;
    }
    j = type - 1;
    if( j == 1 ) {
        displayname[0] = 16;
    }
    for( i = 0; i < 8; i++ ) {
        if( filename[i] != ' ' ) {
            displayname[j++] = filename[i];
        }
    }
    gpu_outputstringcentre( type == 1 ? WHITE : GREY2, 176, 0, displayname, 2 );
}

// FAT32 FILE BROWSER FOR DIRECTORIES AND .PAW FILES
unsigned char *BOOTRECORD = (unsigned char *) 0x8000000 - 0x200;
PartitionTable *PARTITIONS;

Fat32VolumeID *VOLUMEID = (Fat32VolumeID *)0x8000000 - 0x400;
unsigned int *FAT32table = (unsigned int *)0x8000000 - 0x600;
DirectoryEntry *directorynames = (DirectoryEntry *) ( 0x8000000 - 0x600 - ( sizeof( DirectoryEntry) * 256 ) );

FAT32DirectoryEntry *directorycluster;
unsigned int FAT32startsector, FAT32clustersize, FAT32clusters;

// SDCARD FUNCTIONS
// INTERNAL FUNCTION - WAIT FOR THE SDCARD TO BE READY
inline void sdcard_wait( void )  __attribute__((always_inline));
void sdcard_wait( void ) {
    while( !*SDCARD_READY );
}

// READ A SECTOR FROM THE SDCARD AND COPY TO MEMORY
void sdcard_readsector( unsigned int sectorAddress, unsigned char *copyAddress ) {
    gpu_blit( RED, 256, 2, 2, 2 );
    sdcard_wait();
    *SDCARD_SECTOR_HIGH = ( sectorAddress & 0xffff0000 ) >> 16;
    *SDCARD_SECTOR_LOW = ( sectorAddress & 0x0000ffff );
    *SDCARD_START = 1;
    sdcard_wait();

    for( unsigned short i = 0; i < 512; i++ ) {
        *SDCARD_ADDRESS = i;
        copyAddress[ i ] = *SDCARD_DATA;
    }
    gpu_blit( GREEN, 256, 2, 2, 2 );
}

void sdcard_readcluster( unsigned int cluster, unsigned char *buffer ) {
     for( unsigned char i = 0; i < FAT32clustersize; i++ ) {
        sdcard_readsector( FAT32clusters + ( cluster - 2 ) * FAT32clustersize + i, buffer + i * 512 );
    }
}

// READ A SECTION OF THE FILE ALLOCATION TABLE INTO MEMORY
unsigned int __basecluster = 0xffffff8;
unsigned int getnextcluster( unsigned int thiscluster ) {
    unsigned int readsector = thiscluster/128;
    if( ( __basecluster == 0xffffff8 ) || ( thiscluster < __basecluster ) || ( thiscluster > __basecluster + 127 ) ) {
        sdcard_readsector( FAT32startsector + readsector, (unsigned char *)FAT32table );
        __basecluster = readsector * 128;
    }
    return( FAT32table[ thiscluster - __basecluster ] );
}

// READ A FILE CLUSTER BY CLUSTER INTO MEMORY
void sdcard_readfile( unsigned int starting_cluster, unsigned char * copyAddress ) {
    unsigned int nextCluster = starting_cluster;
    unsigned char *CLUSTERBUFFER = (unsigned char *)directorycluster;
    int i;

    do {
        sdcard_readcluster( nextCluster, CLUSTERBUFFER );
        for( i = 0; i < FAT32clustersize * 512; i++ ) {
            *copyAddress = CLUSTERBUFFER[i];
            copyAddress++;
        }
        nextCluster = getnextcluster( nextCluster);
    } while( nextCluster < 0xffffff8 );
}

// SORT DIRECTORY ENTRIES BY TYPE AND FIRST CHARACTER
void swapentries( short i, short j ) {
    // SIMPLE BUBBLE SORT, PUT DIRECTORIES FIRST, THEN FILES, IN ALPHABETICAL ORDER
    DirectoryEntry temporary;

    memcpy( &temporary, &directorynames[i], sizeof( DirectoryEntry ) );
    memcpy( &directorynames[i], &directorynames[j], sizeof( DirectoryEntry ) );
    memcpy( &directorynames[j], &temporary, sizeof( DirectoryEntry ) );
}
void sortdirectoryentries( unsigned short entries ) {
    if( !entries )
        return;

    short changes;
    do {
        changes = 0;

        for( int i = 0; i < entries; i++ ) {
            if( directorynames[i].type < directorynames[i+1].type ) {
                swapentries(i,i+1);
                changes++;
            }
            if( ( directorynames[i].type == directorynames[i+1].type ) && ( directorynames[i].filename[0] > directorynames[i+1].filename[0] ) ) {
                swapentries(i,i+1);
                changes++;
            }
        }
    } while( changes );
}

// WAIT FOR USER TO SELECT A VALID PAW FILE, BROWSING SUBDIRECTORIES
unsigned int filebrowser( int startdirectorycluster, int rootdirectorycluster ) {
    unsigned int thisdirectorycluster = startdirectorycluster;
    FAT32DirectoryEntry *fileentry;

    unsigned char rereaddirectory = 1;
    unsigned short entries, present_entry;

    directorycluster = ( FAT32DirectoryEntry * )directorynames - FAT32clustersize * 512;

    while( 1 ) {
        if( rereaddirectory ) {
            entries = 0xffff; present_entry = 0;
            fileentry = (FAT32DirectoryEntry *) directorycluster;
            memset( &directorynames[0], 0, sizeof( DirectoryEntry ) * 256 );
        }

        while( rereaddirectory ) {
            sdcard_readcluster( thisdirectorycluster, (unsigned char *)directorycluster );

            for( int i = 0; i < 16 * FAT32clustersize; i++ ) {
                if( ( fileentry[i].filename[0] != 0x00 ) && ( fileentry[i].filename[0] != 0xe5 ) ) {
                    // LOG ITEM INTO directorynames
                    if( fileentry[i].attributes &  0x10 ) {
                        // DIRECTORY, IGNORING "." and ".."
                        if( fileentry[i].filename[0] != '.' ) {
                            entries++;
                            memcpy( &directorynames[entries], &fileentry[i].filename[0], 11 );
                            directorynames[entries].type = 2;
                            directorynames[entries].starting_cluster = ( fileentry[i].starting_cluster_high << 16 )+ fileentry[i].starting_cluster_low;
                        }
                    } else {
                        if( fileentry[i].attributes & 0x08 ) {
                            // VOLUMEID
                        } else {
                            if( fileentry[i].attributes != 0x0f ) {
                                // SHORT FILE NAME ENTRY
                                if( ( ( fileentry[i].ext[0] == 'P' ) || ( fileentry[i].ext[0] == 'p' ) ) ||
                                    ( ( fileentry[i].ext[0] == 'A' ) || ( fileentry[i].ext[0] == 'a' ) ) ||
                                    ( ( fileentry[i].ext[0] == 'W' ) || ( fileentry[i].ext[0] == 'w' ) ) ) {
                                        entries++;
                                        memcpy( &directorynames[entries], &fileentry[i].filename[0], 11 );
                                        directorynames[entries].type = 1;
                                        directorynames[entries].starting_cluster = ( fileentry[i].starting_cluster_high << 16 )+ fileentry[i].starting_cluster_low;
                                }
                            }
                        }
                    }
                }
            }

            // MOVE TO THE NEXT CLUSTER OF THE DIRECTORY
            if( getnextcluster( thisdirectorycluster ) >= 0xffffff8 ) {
                rereaddirectory = 0;
            } else {
                thisdirectorycluster = getnextcluster( thisdirectorycluster );
            }
        }

        if( entries == 0xffff ) {
            // NO ENTRIES FOUND
            return(0);
        }

        sortdirectoryentries( entries );

        while( !rereaddirectory ) {
            displayfilename( directorynames[present_entry].filename, directorynames[present_entry].type );

            // WAIT FOR BUTTON, AND WAIT FOR RELEASE TO STOP ACCIDENTAL DOUBLE PRESSES
            unsigned short buttons = get_buttons();
            while( buttons == 1 ) { buttons = get_buttons(); }
            while( get_buttons() != 1 ) {} sleep( 100 );
            if( buttons & 64 ) {
                // MOVE RIGHT
                if( present_entry == entries ) { present_entry = 0; } else { present_entry++; }
            }
            if( buttons & 32 ) {
                // MOVE LEFT
                if( present_entry == 0 ) { present_entry = entries; } else { present_entry--; }
           }
            if( buttons & 8 ) {
                // MOVE UP
                if( startdirectorycluster != rootdirectorycluster ) { return(0); }
           }
            if( buttons & 2 ) {
                // SELECTED
                switch( directorynames[present_entry].type ) {
                    case 1:
                        return( directorynames[present_entry].starting_cluster );
                        break;
                    case 2:
                        int temp = filebrowser( directorynames[present_entry].starting_cluster, rootdirectorycluster );
                        if( temp ) {
                            return( temp );
                        } else {
                            rereaddirectory = 1;
                        }
                }
            }
        }
    }
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

    gpu_outputstring( WHITE, 66, 2, 1, "PAWS", 2 );
    gpu_outputstring( WHITE, 66, 34, 0, "Risc-V RV32IMAFC CPU", 0 );
    gpu_outputstringcentre( GREY2, 224, 0, "PAWS for ULX3S by Rob S in Silice", 0);

    // CLEAR UART AND PS/2 BUFFERS
    while( *UART_STATUS & 1 ) { char temp = *UART_DATA; }
    while( *PS2_AVAILABLE ) { short temp = *PS2_DATA; }

    gpu_outputstringcentre( RED, 72, 0, "Waiting for SDCARD", 0 );
    gpu_outputstringcentre( RED, 80, 0, "Press RESET if not detected", 0 );
    sleep( 1000 );
    sdcard_readsector( 0, BOOTRECORD );
    PARTITIONS = (PartitionTable *) &BOOTRECORD[ 0x1BE ];

    gpu_outputstringcentre( GREEN, 72, 0, "SDCARD Ready", 0 );
    gpu_outputstringcentre( RED, 80, 0, "", 0 );

    // NO FAT16 PARTITION FOUND
    if( ( PARTITIONS[0].partition_type != 0x0b ) && ( PARTITIONS[0].partition_type != 0x0c ) ) {
        gpu_outputstringcentre( RED, 72, 1, "ERROR", 2 );
        gpu_outputstringcentre( RED, 120, 1, "Please Insert AN SDCARD", 0 );
        gpu_outputstringcentre( RED, 128, 1, "WITH A FAT32 PARTITION", 0 );
        gpu_outputstringcentre( RED, 136, 1, "Press RESET", 0 );
        while(1) {}
    }

    // READ VOLUMEID FOR PARTITION 0
    sdcard_readsector( PARTITIONS[0].start_sector, (unsigned char *)VOLUMEID );
    FAT32startsector = PARTITIONS[0].start_sector + VOLUMEID -> reserved_sectors;
    FAT32clusters = PARTITIONS[0].start_sector + VOLUMEID -> reserved_sectors + ( VOLUMEID -> number_of_fats * VOLUMEID -> fat32_size_sectors );
    FAT32clustersize = VOLUMEID -> sectors_per_cluster;

    // FILE SELECTOR
    gpu_outputstringcentre( WHITE, 72, 1, "Select PAW File", 0 );
    gpu_outputstringcentre( WHITE, 88, 0, "SELECT USING FIRE 1", 0 );
    gpu_outputstringcentre( WHITE, 96, 0, "SCROLL USING LEFT & RIGHT", 0 );
    gpu_outputstringcentre( WHITE, 104, 0, "RETURN FROM SUBDIRECTORY USING UP", 0 );
    gpu_outputstringcentre( RED, 144, 1, "No PAW Files Found", 0 );

    // CALL FILEBROWSER
    unsigned int starting_cluster = filebrowser( VOLUMEID -> startof_root, VOLUMEID -> startof_root );
    if( !starting_cluster ) {
        while(1) {}
    }

    gpu_outputstringcentre( WHITE, 72, 1, "PAW File", 0 );
    gpu_outputstringcentre( WHITE, 80, 1, "SELECTED", 0 );
    gpu_outputstringcentre( WHITE, 88, 0, "", 0 );
    gpu_outputstringcentre( WHITE, 96, 0, "", 0 );
    gpu_outputstringcentre( WHITE, 104, 0, "", 0 );
    sleep( 500 );
    gpu_outputstringcentre( WHITE, 80, 1, "LOADING", 0 );
    sdcard_readfile( starting_cluster, (unsigned char *)0x4000000 );
    gpu_outputstringcentre( WHITE, 72, 1, "LOADED", 0 );
    gpu_outputstringcentre( WHITE, 80, 1, "LAUNCHING", 0 );
    sleep(500);

    // STOP SMT
    SMTSTOP();

    // RESET THE DISPLAY
    reset_display();
    set_background( BLACK, BLACK, BKG_SOLID );

    // CALL SDRAM LOADED PROGRAM
    ((void(*)(void))0x4000000)();
    // RETURN TO BIOS IF PROGRAM EXITS
    ((void(*)(void))0x0)();
}
