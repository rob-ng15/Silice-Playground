#include "PAWSlibrary.h"

void main( void ) {
    INITIALISEMEMORY();

    unsigned char *galaxyfilebuffer;
    unsigned short filenumber;
	while(1) {
        terminal_showhide( 1 );
        outputstring( "Press a key to test\n" );
        (void)inputcharacter();

        outputstringnonl( "MBR = " ); outputnumber_int( (int)MBR ); outputcharacter( '\n' );
        outputstringnonl( "BOOTSECTOR = " ); outputnumber_int( (int)BOOTSECTOR ); outputcharacter( '\n' );
        outputstringnonl( "PARTITION = " ); outputnumber_int( (int)PARTITION ); outputcharacter( '\n' );
        outputstringnonl( "ROOTDIRECTORY = " ); outputnumber_int( (int)ROOTDIRECTORY ); outputcharacter( '\n' );
        outputstringnonl( "CLUSTERBUFFER = " ); outputnumber_int( (int)CLUSTERBUFFER ); outputcharacter( '\n' );
        outputstringnonl( "CLUSTERSIZE = " ); outputnumber_int( (int)CLUSTERSIZE ); outputcharacter( '\n' );
        outputcharacter( '\n' );
        outputstringnonl( "MEMORYTOP = " ); outputnumber_int( (int)MEMORYTOP ); outputcharacter( '\n' );
        outputcharacter( '\n' );

        outputstring( "Press a key to load GALAXY.JPG\n" );
        (void)inputcharacter();

        outputstring( "Finding File GALAXY.JPG");
        filenumber = findfilenumber( "GALAXY", "JPG" );
        if( filenumber == 0xffff ) {
            outputstring( "FILE NOT FOUND" );
        } else {
            outputstringnonl( "FILESIZE = " ); outputnumber_int( findfilesize( filenumber ) ); outputcharacter( '\n' );
            galaxyfilebuffer = filememoryspace( findfilesize( filenumber ) );
            outputstringnonl( "MEMORYTOP = " ); outputnumber_int( (int)MEMORYTOP ); outputcharacter( '\n' );
        }

        (void)inputcharacter();
    }
}
