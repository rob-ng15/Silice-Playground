#include "PAWSlibrary.h"

// SDCARD BLITTER TILES
unsigned short sdcardtiles[] = {
    0x0000, 0x0000, 0x0ec0, 0x08a0, 0xea0, 0x02a0, 0x0ec0, 0x0000,
    0x0a60, 0x0a80, 0x0e80, 0xa80, 0x0a60, 0x0000, 0x0000, 0x0000,

    0x3ff0, 0x3ff8, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ff8, 0x1ffc, 0x1ffc,
    0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc, 0x3ffc,

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

// MASTER BOOT RECORD AND PARTITION TABLE
unsigned char MBR[512];
Fat16BootSector BOOTSECTOR;
PartitionTable *PARTITION;
Fat16Entry *ROOTDIRECTORY;

void sd_readSector( unsigned int sectorAddress, unsigned char *copyAddress )
{
    unsigned short i;

    tpu_set( 48, 0, TRANSPARENT, RED ); tpu_outputstring("Reading Sector: "); tpu_outputnumber_int( (unsigned short)sectorAddress );
    set_leds(255); gpu_blit( RED, 608, 0, 2, 1 );
    sdcard_readsector( sectorAddress, copyAddress );

    tpu_set( 48, 0, TRANSPARENT, GREEN ); tpu_outputstring("Sector Read   : "); tpu_outputnumber_int( (unsigned short)sectorAddress );
    set_leds(0); gpu_blit( GREEN, 608, 0, 2, 1 );
}

void sd_readMBR( void ) {
    // FOR COPYING DATA
    unsigned short i;
    unsigned char *copyaddress;

    sd_readSector( 0, MBR );
}

void sd_readRootDirectory ( void ) {
    unsigned short i;

    // READ ALL OF THE SECTORS OF THE ROOTDIRECTORY
    for( i = 0; i < ( BOOTSECTOR.root_dir_entries * sizeof( Fat16Entry ) ) / 512; i++ ) {
        sd_readSector( i + PARTITION[0].start_sector + BOOTSECTOR.reserved_sectors + BOOTSECTOR.fat_size_sectors * BOOTSECTOR.number_of_fats, ( (unsigned char *)ROOTDIRECTORY ) + 512 * i );
    }
}

void draw_riscv_logo( void )
{
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

void set_sdcard_bitmap( void )
{
    set_blitter_bitmap( 0, &sdcardtiles[0] );
    set_blitter_bitmap( 1, &sdcardtiles[16] );
    set_blitter_bitmap( 2, &sdcardtiles[32] );
}

void draw_sdcard( void  )
{
    gpu_blit( BLUE, 608, 0, 1, 1 );
    gpu_blit( WHITE, 608, 0, 0, 1 );
}

void main()
{
    unsigned short i,j;
    unsigned char uartData = 0;

    gpu_cs();
    tpu_cs();

    draw_riscv_logo();
    set_sdcard_bitmap();
    draw_sdcard();

    tpu_set( 16, 5, TRANSPARENT, WHITE ); tpu_outputstring( "Welcome to PAWS a RISC-V RV32IMC CPU" );

    tpu_set( 0, 7, TRANSPARENT, RED ); tpu_outputstring( "Waiting for SDCARD" );
    tpu_set( 0, 9, TRANSPARENT, RED ); tpu_outputstring( "Reading Master Boot Record" );
    sleep( 4000 );

    sd_readSector( 0, MBR );

    tpu_set( 0, 7, TRANSPARENT, GREEN ); tpu_outputstring( "SCARD Detected    ");
    tpu_set( 0, 9, TRANSPARENT, GREEN ); tpu_outputstring( "Read Master Boot Record   ");

    PARTITION = (PartitionTable *) &MBR[ 0x1BE ];

    for( i = 0; i < 4; i++ ) {
        tpu_set( 2, 10 + i, TRANSPARENT, 0x3f ); tpu_outputstring( "Partition : " ); tpu_outputnumber_short( i ); tpu_outputstring( ", Type : " ); tpu_outputnumber_char( PARTITION[i].partition_type );
        switch( PARTITION[i].partition_type ) {
            case 0: tpu_outputstring( " No Entry" );
                break;
            case 4: tpu_outputstring( " FAT16 <32MB" );
                break;
            case 6: tpu_outputstring( " FAT16 >32MB" );
                break;
            case 14: tpu_outputstring( " FAT16 LBA" );
                break;
            default: tpu_outputstring( " Not FAT16" );
                break;
        }
    }

    // CHECK FOR VALID PARTITION
    switch( PARTITION[0].partition_type ) {
        case 4:
        case 6:
        case 14:
            break;
        default:
            // UNKNOWN PARTITION TYPE
            tpu_set( 0, 15, TRANSPARENT, RED ); tpu_outputstring( "ERROR: PLEASE INSERT A VALID FAT16 FORMATTED SDCARD AND PRESS RESET");
            while(1) {}
            break;
    }

    tpu_set( 0, 15, TRANSPARENT, RED ); tpu_outputstring( "Reading Partition 0 Boot Sector");
    sd_readSector( PARTITION[0].start_sector, (unsigned char *)&BOOTSECTOR );
    tpu_set( 0, 15, TRANSPARENT, GREEN ); tpu_outputstring( "Read Partition 0 Boot Sector   ");

    tpu_output_character( '[' );
    for( i = 0; i < 8; i++ ) {
        tpu_output_character( BOOTSECTOR.oem[i] );
    }
    tpu_output_character( ']' ); tpu_output_character( '[' );
    for( i = 0; i < 11; i++ ) {
        tpu_output_character( BOOTSECTOR.volume_label[i] );
    }
    tpu_output_character( ']' ); tpu_output_character( '[' );
    for( i = 0; i < 8; i++ ) {
        tpu_output_character( BOOTSECTOR.fs_type[i] );
    }
    tpu_output_character( ']' );

    // OUTPUT PARTITION DETAILS
    tpu_set( 2, 16, TRANSPARENT, WHITE );
    tpu_outputstring( "Sector Size: " ); tpu_outputnumber_short( BOOTSECTOR.sector_size );
    tpu_outputstring( " Cluster Size: " ); tpu_outputnumber_char( BOOTSECTOR.sectors_per_cluster );
    tpu_outputstring( " FATs: " ); tpu_outputnumber_char( BOOTSECTOR.number_of_fats );
    tpu_outputstring( " Directory Entries: " ); tpu_outputnumber_short( BOOTSECTOR.root_dir_entries );
    tpu_set( 2, 17, TRANSPARENT, WHITE );
    tpu_outputstring( "Total Sectors: " ); tpu_outputnumber_int( BOOTSECTOR.total_sectors_long );

    // READ ROOT DIRECTORY INTO MEMORY
    tpu_set( 0, 19, TRANSPARENT, RED ); tpu_outputstring( "Reading Root Directory");
    // SET STORAGE FOR THE RROT DIRECTORY FROM THE TOP OF THE MAIN MEMORY
    ROOTDIRECTORY = (Fat16Entry *)( 0x12000000 - BOOTSECTOR.root_dir_entries * sizeof( Fat16Entry ) );
    tpu_set( 0, 19, TRANSPARENT, RED ); tpu_outputstring( "Reading Root Directory");
    sd_readRootDirectory();
    tpu_set( 0, 19, TRANSPARENT, GREEN ); tpu_outputstring( "Read Root Directory   ");

    // OUTPUT RESULT OF ls *.PAW TO TERMINAL
    outputstring("\n\n\n\n\n\n\n\nRISC-ICE-V BIOS" );
    outputstring("> ls *.PAW");
    for( i = 0; i < BOOTSECTOR.root_dir_entries; i++ ) {
        if( ROOTDIRECTORY[i].ext[0]=='P' && ROOTDIRECTORY[i].ext[1]=='A' && ROOTDIRECTORY[i].ext[2]=='W' ) {
            switch( ROOTDIRECTORY[i].filename[0] ) {
                case 0x00:
                case 0xe5:
                case 0x2e:
                    break;
                default: outputcharacter('[');
                    for( j = 0; j < 8; j++ )
                        outputcharacter( ROOTDIRECTORY[i].filename[j] );
                    outputcharacter('.');
                    for( j = 0; j < 3; j++ )
                        outputcharacter( ROOTDIRECTORY[i].ext[j] );
                    outputcharacter(']');
                    break;
            }
        }
    }

    // CLEAR the UART buffer
    while( inputcharacter_available() )
        uartData = inputcharacter();

    outputstring("\nTerminal Echo Starting");

    while(1) {
        uartData = inputcharacter();
        outputstringnonl("You pressed : ");
        outputcharacter( uartData );
        outputstring(" <-");
        set_leds(uartData);
    }

    // CALL SDRAM LOADED PROGRAM
    ((void(*)(void))0x10000000)();
}
