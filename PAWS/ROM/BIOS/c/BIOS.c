#include "BIOSlibrary.h"

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

    gpu_blit( RED, 576, 4, 2, 2 );
    sdcard_readsector( sectorAddress, copyAddress );
    gpu_blit( GREEN, 576, 4, 2, 2 );
}

// READ SECTOR 0, THE MASTER BOOT RECORD
void sd_readMBR( void ) {
    // FOR COPYING DATA
    unsigned short i;
    unsigned char *copyaddress;

    sd_readSector( 0, MBR );
}

// READ FILE ALLOCATION TABLE
void sd_readFAT( void ) {
    unsigned short i;

    // READ ALL OF THE SECTORS OF THE FAT
    for( i = 0; i < BOOTSECTOR -> fat_size_sectors; i++ ) {
        sd_readSector( i + PARTITION[0].start_sector + BOOTSECTOR -> reserved_sectors + BOOTSECTOR -> fat_size_sectors, ( (unsigned char *)FAT ) + 512 * i );
    }
}

// READ ROOT DIRECTORY
void sd_readRootDirectory ( void ) {
    unsigned short i;

    // READ ALL OF THE SECTORS OF THE ROOTDIRECTORY
    for( i = 0; i < ( BOOTSECTOR -> root_dir_entries * sizeof( Fat16Entry ) ) / 512; i++ ) {
        sd_readSector( i + PARTITION[0].start_sector + BOOTSECTOR -> reserved_sectors + BOOTSECTOR -> fat_size_sectors * BOOTSECTOR -> number_of_fats, ( (unsigned char *)ROOTDIRECTORY ) + 512 * i );
    }
}

// READ A FILE CLUSTER ( the minimum size of a file in FAT16 )
void sd_readCluster( unsigned short cluster ) {
    for( unsigned short i = 0; i < BOOTSECTOR -> sectors_per_cluster; i++ ) {
        sd_readSector( DATASTARTSECTOR + ( cluster - 2 ) * BOOTSECTOR -> sectors_per_cluster + i, CLUSTERBUFFER + i * 512 );
    }
}

// SEARCH FOR THE NEXT PAW FILE, WILL LOCK IF NO FILE FOUND
void sd_findNextFile( void ) {
    unsigned short i = ( SELECTEDFILE == 0xffff ) ? 0 : SELECTEDFILE + 1;
    unsigned short filefound = 0;

    while( !filefound ) {
        switch( ROOTDIRECTORY[i].filename[0] ) {
            // NOT TRUE FILES ( deleted, directory pointer )
            case 0x00:
            case 0xe5:
            case 0x05:
            case 0x2e:
                i = ( i < BOOTSECTOR -> root_dir_entries ) ? i + 1 : 0;
                break;

            default:
                if( ROOTDIRECTORY[i].ext[0]=='P' && ROOTDIRECTORY[i].ext[1]=='A' && ROOTDIRECTORY[i].ext[2]=='W' ) {
                    SELECTEDFILE = i;
                    filefound = 1;
                } else {
                    i = ( i < BOOTSECTOR -> root_dir_entries ) ? i + 1 : 0;
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
    gpu_blit( BLUE, 576, 4, 1, 2 );
    gpu_blit( WHITE, 576, 4, 0, 2 );
}

void reset_display( unsigned char terminalvisible ) {
    gpu_cs();
    tpu_cs();
    tilemap_scrollwrapclear( 9 );
    terminal_showhide( terminalvisible );
    for( unsigned short i = 0; i < 13; i++ ) {
        set_sprite( 0, i, 0, 0, 0, 0, 0, 0 );
        set_sprite( 1, i, 0, 0, 0, 0, 0, 0 );
    }
}

void main( void ) {
    unsigned short i,j;
    unsigned char uartData = 0;
    unsigned short selectedfile = 0;
    unsigned int *sdramaddress;

    // CLEAR SDRAM
    // RESET THE DISPLAY
    reset_display( 1 );
    set_background( BLACK, BLACK, BKG_SOLID );
    outputstringnonl( " SDRAM Test: " );
    for( sdramaddress = (unsigned int *)0x10000000; sdramaddress < (unsigned int *)0x12000000; sdramaddress++ ) {
        *sdramaddress  = 0;
        if( ( (int)sdramaddress & 0xfffff ) == 0 )
            outputcharacter( '*' );
    }

    // RESET THE DISPLAY
    reset_display( 0 );
    set_background( DKBLUE - 1, BLACK, BKG_SOLID );

    // SETUP INITIAL WELCOME MESSAGE
    draw_riscv_logo();
    set_sdcard_bitmap();
    draw_sdcard();
    gpu_character_blit( WHITE, 104, 4, 'P', 2);
    gpu_character_blit( WHITE, 136, 4, 'A', 2);
    gpu_character_blit( WHITE, 168, 4, 'W', 2);
    gpu_character_blit( WHITE, 200, 4, 'S', 2);
    tpu_set( 13, 2, TRANSPARENT, WHITE ); tpu_outputstring( "RISC-V RV32IMACB CPU" );

    for( unsigned short i = 0; i < 64; i++ )
        gpu_rectangle( i, i * 10, 447, 9 + i * 10, 463 );

    tpu_outputstringcentre( 7, TRANSPARENT, RED, "Waiting for SDCARD" );
    sd_readSector( 0, MBR );
    tpu_outputstringcentre( 7, TRANSPARENT, GREEN, "SDCARD Ready" );

    PARTITION = (PartitionTable *) &MBR[ 0x1BE ];

    // CHECK FOR VALID PARTITION
    switch( PARTITION[0].partition_type ) {
        case 4:
        case 6:
        case 14:
            break;
        default:
            // UNKNOWN PARTITION TYPE
            tpu_outputstringcentre( 7, TRANSPARENT, RED, "ERROR: Please Insert A FAT16 SDCARD and Press RESET" );
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
    tpu_outputstringcentre( 7, TRANSPARENT, WHITE, "Select PAW File" );
    tpu_outputstringcentre( 8, TRANSPARENT, WHITE, "SELECT USING FIRE 1 - SCROLL USING FIRE 2" );
    tpu_outputstringcentre( 10, TRANSPARENT, RED, "ERROR: No PAW Files Found" );
    SELECTEDFILE = 0xffff;

    // FILE SELECTOR, LOOP UNTIL FILE SELECTED (FIRE 1 PRESSED WITH A VALID FILE)
    while( !selectedfile ) {
        // FIRE 2 - SEARCH FOR NEXT FILE
        if( ( get_buttons() & 4 ) || ( SELECTEDFILE == 0xffff ) ) {
            while( get_buttons() & 4 );
            sd_findNextFile();
            tpu_outputstringcentre( 10, TRANSPARENT, WHITE, "Current PAW File:" );
            for( i = 0; i < 8; i++ ) {
                // DISPLAY FILENAME
                gpu_rectangle( TRANSPARENT, 64, 208, 576, 272 );
                for( i = 0; i < 8; i++ ) {
                    gpu_character_blit( WHITE, 64 + i * 64, 208, ROOTDIRECTORY[SELECTEDFILE].filename[i], 3);
                }
            }
        }
        // FIRE 1 - SELECT FILE
        if( ( get_buttons() & 2 ) && ( SELECTEDFILE != 0xffff ) ) {
            while( get_buttons() & 2 );
            selectedfile = 1;
        }
    }

    tpu_outputstringcentre( 7, TRANSPARENT, WHITE, "PAW File" );
    tpu_outputstringcentre( 8, TRANSPARENT, WHITE, "SELECTED" );
    sleep( 1000 );
    tpu_outputstringcentre( 8, TRANSPARENT, WHITE, "LOADING" );
    sd_readFile( SELECTEDFILE, (unsigned char *)0x10000000 );
    tpu_outputstringcentre( 7, TRANSPARENT, WHITE, "FILE LOADED" );
    tpu_outputstringcentre( 8, TRANSPARENT, WHITE, "LAUNCHING" );
    sleep( 1000 );

    // RESET THE DISPLAY
    terminal_reset();
    reset_display( 0 );
    set_background( BLACK, BLACK, BKG_SOLID );

    // CALL SDRAM LOADED PROGRAM
    ((void(*)(void))0x10000000)();
}
