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

unsigned char BOOTRECORD[512];
PartitionTable *PARTITIONS = (PartitionTable *)&BOOTRECORD[446];
Fat32VolumeID VolumeID;
FAT32DirectoryEntry *directorycluster;
unsigned int FAT32startsector, FAT32clustersize, FAT32clusters, *FAT32table;

void readcluster( unsigned int cluster, unsigned char *buffer ) {
     for( unsigned char i = 0; i < FAT32clustersize; i++ ) {
        sdcard_readsector( FAT32clusters + ( cluster - 2 ) * FAT32clustersize + i, buffer + i * 512 );
    }
    printw("\n");
}

void gpu_outputstring( unsigned char colour, short x, short y, char *s, unsigned char size ) {
    while( *s ) {
        gpu_character_blit( colour, x, y, *s++, size, 0 );
        x = x + ( 8 << size );
    }
}
void gpu_outputstringcentre( unsigned char colour, short y, char *s, unsigned char size ) {
    gpu_rectangle( TRANSPARENT, 0, y, 319, y + ( 8 << size ) - 1 );
    gpu_outputstring( colour, 160 - ( ( ( 8 << size ) * strlen(s) ) >> 1) , y, s, size );
}

void displayfilename( unsigned char *filename, unsigned char type ) {
    unsigned char displayname[10], i, j;
    gpu_outputstringcentre( WHITE, 144, "Current PAW File:", 0 );
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
    gpu_outputstringcentre( type == 1 ? WHITE : GREY2, 176, displayname, 2 );
}

unsigned int __basecluster = 0xffffff8;
unsigned int getnextcluster( unsigned int thiscluster ) {
    unsigned int readsector = thiscluster/128;
    if( ( __basecluster == 0xffffff8 ) || ( thiscluster < __basecluster ) || ( thiscluster > __basecluster + 127 ) ) {
        sdcard_readsector( FAT32startsector + readsector, (unsigned char *)FAT32table );
        __basecluster = readsector * 128;
    }
    return( FAT32table[ thiscluster - __basecluster ] );
}

unsigned int filebrowser( int startdirectorycluster, int rootdirectorycluster ) {
    unsigned int thisdirectorycluster = startdirectorycluster;
    FAT32DirectoryEntry *fileentry;

    unsigned char rereaddirectory = 1;
    unsigned short entries, present_entry;

    while( 1 ) {
        if( rereaddirectory ) {
            entries = 0xffff; present_entry = 0;
            fileentry = (FAT32DirectoryEntry *) directorycluster;
            memset( &directorynames[0], 0, sizeof( DirectoryEntry ) * 256 );
        }

        while( rereaddirectory ) {
            readcluster( thisdirectorycluster, (unsigned char *)directorycluster );

            for( int i = 0; i < 16 * FAT32clustersize; i++ ) {
                if( ( fileentry[i].filename[0] != 0x00 ) && ( fileentry[i].filename[0] != 0xe5 ) ) {
                    // LOG ITEM INTO directorynames, if appropriate
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

        while( !rereaddirectory ) {
            displayfilename( directorynames[present_entry].filename, directorynames[present_entry].type );

            unsigned short buttons = get_buttons();
            while( buttons == 1 ) { buttons = get_buttons(); }
            while( get_buttons() != 1 ) {}
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

int main( void ) {
    INITIALISEMEMORY();
    // set up curses library
    initscr();
    start_color();
    attron( COLOR_PAIR(7) );
    autorefresh( 1 );

    sdcard_readsector( 0, BOOTRECORD );
    if( ( PARTITIONS[1].partition_type == 0x0b ) || ( PARTITIONS[1].partition_type == 0x0c ) ) {
        sdcard_readsector( PARTITIONS[1].start_sector, (unsigned char *)&VolumeID );

        // READ THE FILE ALLOCATION TABLE
        FAT32startsector = PARTITIONS[1].start_sector + VolumeID.reserved_sectors;
        FAT32table = malloc(512 );

        FAT32clusters = PARTITIONS[1].start_sector + VolumeID.reserved_sectors + ( VolumeID.number_of_fats * VolumeID.fat32_size_sectors );
        FAT32clustersize = VolumeID.sectors_per_cluster;

        directorycluster = malloc( FAT32clustersize * 512 );

        unsigned int starting_cluster = filebrowser( VolumeID.startof_root, VolumeID.startof_root );
        if( starting_cluster ) {
            printw("LOAD CLUSTERS: ");
            while( starting_cluster < 0xffffff8 ) {
                printw("[%d] ", starting_cluster);
                starting_cluster = getnextcluster( starting_cluster );
            }
        } else {
            printw("NOT A VALID FILE\n");
        }
    } else {
        printw("\nPARTITION[1] != FAT32 == %d\n\n", PARTITIONS[0].partition_type );
    }

    sleep( 8000, 0 );
}
// EXIT WILL RETURN TO BIOS
