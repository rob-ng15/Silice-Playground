#include "PAWSlibrary.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

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
DirectoryEntry directorynames[256];

unsigned char bootsector[512];
PartitionTable *partitions = (PartitionTable *)&bootsector[446];
Fat32VolumeID VolumeID;
unsigned int FAT32startsector, FAT32sectors, FAT32clusters, FAT32clustersize, FAT32directoryclusterstart, FAT32directorycluster;
unsigned int *FAT32table;

void readcluster( unsigned short cluster, unsigned char *buffer ) {
    printw("READING CLUSTER %d\n",cluster);
     for( unsigned char i = 0; i < FAT32clustersize; i++ ) {
        sdcard_readsector( FAT32clusters + ( cluster - 2 ) * FAT32clustersize + i, buffer + i * 512 );
    }
    printw("\n");
}

unsigned int filebrowser( void ) {
    unsigned char *directorycluster = malloc( FAT32clustersize * 512 ), entryincluster = 0xff;
    unsigned short filenumber = 0xffff;
    FAT32DirectoryEntry *fileentry;

    printw(" READING DIRECTORY\n");
    readcluster( FAT32directorycluster, directorycluster );
    fileentry = (FAT32DirectoryEntry *) directorycluster;

    printw(" PROCESSING DIRECTORY\n");
    memset( &directorynames[0], 0, sizeof( DirectoryEntry ) * 256 );

    unsigned char finished = 0; unsigned short entries = 0xffff, present_entry = 0;

    while( 1 ) {
        while( !finished) {
            for( int i = 0; i < 16; i++ ) {
                if( ( fileentry[i].filename[0] != 0x00 ) && ( fileentry[i].filename[0] != 0xe5 ) ) {
                    // LOG ITEM INTO directorynames, if appropriate
                    if( fileentry[i].attributes &  0x10 ) {
                        // DIRECTORY - COPY FILENAME
                        entries++;
                        memcpy( &directorynames[entries], &fileentry[i].filename[0], 11 );
                        directorynames[entries].type = 2;
                        directorynames[entries].starting_cluster = fileentry[i].starting_cluster_high << 16 + fileentry[i].starting_cluster_low;
                    } else {
                        if( fileentry[i].attributes & 0x08 ) {
                            // VOLUMEID
                        } else {
                            if( fileentry[i].attributes != 0x0f ) {
                                // SHORT FILE NAME ENTRY
                                entries++;
                                memcpy( &directorynames[entries], &fileentry[i].filename[0], 11 );
                                directorynames[entries].type = 1;
                                directorynames[entries].starting_cluster = fileentry[i].starting_cluster_high << 16 + fileentry[i].starting_cluster_low;
                            }
                        }
                    }
                }
            }
            // MOVE TO THE NEXT CLUSTER OF THE DIRECTORY
            if( FAT32table[ FAT32directorycluster ] >= 0xfff8 ) {
                finished = 1;
            } else {
                FAT32directorycluster = FAT32table[ FAT32directorycluster ];
                readcluster( FAT32directorycluster, directorycluster );
            }
        }

        printw("FINISHED PROCESSING DIRECTORY\n\n");
        if( entries == 0xffff ) {
            // NO ENTRIES FOUND
            printw("NO ENTRIES FOUND IN DIRECTORY");
            return(0);
        }

        unsigned char new_directory = 0;
        while( !new_directory ) {
            printw("PRESENT FILE = ");
            for( int c = 0; c < 8; c++ ) {
                if(directorynames[present_entry].filename[c] != ' ') printw("%c",directorynames[present_entry].filename[c]);
            }
            printw(".");
            for( int c = 0; c < 3; c++ ) {
                if(directorynames[present_entry].ext[c] != ' ') printw("%c",directorynames[present_entry].ext[c]);
            }
            printw("\n");
            while( get_buttons() == 1 ) {}
            if( get_buttons() & 64 ) {
                // MOVE RIGHT
                if( present_entry == entries ) { present_entry = 0; } else { present_entry++; }
            }
            if( get_buttons() & 64 ) {
                // MOVE LEFT
                if( present_entry == 0 ) { present_entry = entries; } else { present_entry--; }
           }
            if( get_buttons() & 2 ) {
                // SELECTED
                printw("SELECTED\n");
                while( get_buttons() != 1 ) {}
                if(directorynames[present_entry].type == 1) {
                    return( directorynames[present_entry].starting_cluster );
                } else {
                    FAT32directorycluster = FAT32directoryclusterstart = directorynames[present_entry].starting_cluster;
                    readcluster( FAT32directorycluster, directorycluster );
                    new_directory = 1;
                }
            }
            while( get_buttons() != 1 ) {}
        }
    }
}

int main( void ) {
    INITIALISEMEMORY();
    // set up curses library
    initscr();
    start_color();
    attron( COLOR_PAIR(7) );
    autorefresh( 1 );

    printw( "Reading Boot Sector\n\n" ); sdcard_readsector( 0, bootsector );

    for( int i = 0; i < 4; i++ ) {
        printw( "Partition %d, Type = %d, First Sector = %d, Length = %d sectors\n",partitions[i].partition_type,partitions[i].start_sector,partitions[i].length_sectors );
    }

    if( ( partitions[1].partition_type == 0x0b ) || ( partitions[0].partition_type == 0x0c ) ) {
        printw("\nPARTITION[1] == FAT32\n\n");
        sdcard_readsector( partitions[1].start_sector, (unsigned char *)&VolumeID );

        // READ THE FILE ALLOCATION TABLE
        printw("READING FILE ALLOCATION TABLE %d sectors\n",VolumeID.fat32_size_sectors);
        FAT32startsector = partitions[1].start_sector + VolumeID.reserved_sectors;
        FAT32sectors = VolumeID.fat16_size_sectors ? VolumeID.fat16_size_sectors : VolumeID.fat32_size_sectors;
        FAT32table = malloc( FAT32sectors * 512 );
        for( int i = 0; i < FAT32sectors; i++ ) {
            sdcard_readsector( FAT32startsector + i, (unsigned char *)&FAT32table[ i * 128 ] );
        }

        FAT32clusters = partitions[1].start_sector + VolumeID.reserved_sectors + ( VolumeID.number_of_fats * VolumeID.fat32_size_sectors );
        FAT32clustersize = VolumeID.sectors_per_cluster;

        FAT32directorycluster = FAT32directoryclusterstart = VolumeID.startof_root;
        printw("  FAT32 @ %d x (%d,%d), CLUSTERS @ %d, ROOTDIRECTORY @ CLUSTER %d\n",FAT32startsector,VolumeID.fat16_size_sectors,VolumeID.fat32_size_sectors,FAT32clusters,FAT32directoryclusterstart);
        printw("  CHECKS sizeof(Fat32VolumeID) == %d, SIGNATURE = %x\n\n",sizeof(Fat32VolumeID),VolumeID.boot_sector_signature);

        filebrowser();
    } else {
        printw("\nPARTITION[1] != FAT32 == %d\n\n", partitions[0].partition_type );
    }

    sleep( 8000, 0 );
}
// EXIT WILL RETURN TO BIOS
