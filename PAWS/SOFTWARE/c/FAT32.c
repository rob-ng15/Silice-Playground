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
    unsigned char reserved[10];
    unsigned short modify_time;
    unsigned short modify_date;
    unsigned short starting_cluster;
    unsigned int file_size;
} __attribute((packed)) FAT32DirectoryEntry;

unsigned char bootsector[512];
PartitionTable *partitions = (PartitionTable *)&bootsector[446];
Fat32VolumeID VolumeID;
unsigned int FAT32, FAT32clusters, FAT32clustersize, FAT32directory;

void readcluster( unsigned short cluster, unsigned char *buffer ) {
    printw("READING CLUSTER %d ",cluster);
    for( unsigned char i = 0; i < FAT32clustersize; i++ ) {
        printw("[%d] ",FAT32clusters + ( cluster - 2 ) * FAT32clustersize + i);
        sdcard_readsector( FAT32clusters + ( cluster - 2 ) * FAT32clustersize + i, buffer + i * 512 );
    }
    printw("\n");
}

void printfilename(unsigned char *filename, unsigned char attribute) {
    printw("  [%2x] ", attribute);
    for( int i = 0; i < 11; i++ ) {
        printw("%c",filename[i]);
    }
    printw("\n");
}

void readdirectory( void ) {
    unsigned char *directorycluster = malloc( FAT32clustersize * 512 );
    FAT32DirectoryEntry *fileentry;

    printw(" READING DIRECTORY\n");
    readcluster( FAT32directory, directorycluster );
    fileentry = (FAT32DirectoryEntry *) directorycluster;
    for( int cluster = 0; cluster < FAT32clustersize; cluster++ ) {
        for( int entry = 0; entry < 16; entry++ ) {
            unsigned char attribute = fileentry[ cluster * 16 + entry ].attributes;
            unsigned char firstchar = fileentry[ cluster * 16 + entry ].filename[0];
            switch( firstchar ) {
                case 0xe5:
                    break;
                default:
                    printfilename(&fileentry[ cluster * 16 + entry ].filename[0],attribute);
            }
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
        FAT32 = partitions[1].start_sector + VolumeID.reserved_sectors;
        FAT32clusters = partitions[1].start_sector + VolumeID.reserved_sectors + ( VolumeID.number_of_fats * VolumeID.fat32_size_sectors );
        FAT32clustersize = VolumeID.sectors_per_cluster;
        FAT32directory = VolumeID.startof_root;
        printw("  FAT32 @ %d, CLUSTERS @ %d, CLUSTERSIZE = %d, ROOTDIRECTORY @ CLUSTER %d\n",FAT32,FAT32clusters,FAT32clustersize,FAT32directory);
        printw("  CHECKS sizeof(Fat32VolumeID) == %d, SIGNATURE = %x\n\n",sizeof(Fat32VolumeID),VolumeID.boot_sector_signature);
        readdirectory();
    } else {
        printw("\nPARTITION[1] != FAT32 == %d\n\n", partitions[0].partition_type );
    }

    sleep( 8000, 0 );
}
// EXIT WILL RETURN TO BIOS
