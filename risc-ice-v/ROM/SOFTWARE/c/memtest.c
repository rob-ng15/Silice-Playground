#include "BIOSlibrary.h"

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

void memorydump( unsigned char *address, unsigned short length ) {
    outputstring( "Memory Dump 8 bit" );
    unsigned char value;
    for( unsigned short y = 0; y < ( length >> 4 ); y++ ) {
        outputnumber_int( (unsigned int) address );
        outputcharacter( ':');
        outputcharacter( ' ');
        for( unsigned short x = 0; x < 16; x++ ) {
            value = *address;
            outputnumber_char( value );
            outputcharacter( ' ' );
            address++;
        }
        outputcharacter('\n');
        sleep( 500 );
    }
}

void memorydump16( unsigned short *address, unsigned short length ) {
    outputstring( "Memory Dump 16 bit" );
    unsigned short value;
    for( unsigned short y = 0; y < ( length >> 4 ); y++ ) {
        outputnumber_int( (unsigned int) address );
        outputcharacter( ':');
        outputcharacter( ' ');
        for( unsigned short x = 0; x < 16; x++ ) {
            value = *address;
            outputnumber_short( value );
            outputcharacter( ' ' );
            address++;
        }
        outputcharacter('\n');
        sleep( 500 );
    }
}

void main( void ) {
    unsigned short i,j;
    unsigned char uartData = 0;

    gpu_cs();
    tpu_cs();
    set_background( DKBLUE - 1, BLACK, BKG_SOLID );

    draw_riscv_logo();
    tpu_set( 16, 5, TRANSPARENT, WHITE ); tpu_outputstring( "Welcome to PAWS a RISC-V RV32IMC CPU" );

    sleep( 4000 );

    // WRITE TO SDRAM / CACHE
    unsigned char *MEMTEST = (unsigned char *) 0x10000000;
    for( unsigned char i = 0; i < 255; i++ ) {
        MEMTEST[i] = i;
    }
    unsigned short *MEMTEST2 = (unsigned short *) 0x10000100;
    for( unsigned short i = 0; i < 256; i++ ) {
        MEMTEST2[i] = i;
    }

    outputstring( "\nMEMORY DUMP FROM 0x10000000 CACHE" );
    memorydump( MEMTEST, 256 );
    outputstring( "\n\nMEMORY DUMP 16 FROM 0x10000100 CACHE" );
    memorydump16( MEMTEST2, 256 );

    // OVERWHELM THE CACHE
    for( unsigned short i = 0; i < 4096; i++ ) {
        MEMTEST2[i] = i;
    }

    // REPEAT MEMORY DUMPS
    outputstring( "\nREPEAT MEMORY DUMPS\n");
    outputstring( "\nMEMORY DUMP FROM 0x10000000 SDRAM via CACHE" );
    memorydump( MEMTEST, 256 );
    outputstring( "\n\nMEMORY DUMP 16 FROM 0x10000100 SDRAM via CACHE" );
    memorydump16( MEMTEST2, 256 );

    // DIAGNOSTICS
    int cycles, instructions;
    cycles = (int)CSRcycles();
    instructions = (int)CSRinstructions();
    outputstringnonl( "\nCLOCK CYCLES: " ); outputnumber_int( cycles ); outputstringnonl( " INSTRUCTIONS: " ); outputnumber_int( instructions );

    // TERMINAL ECHO LOOP
    while( inputcharacter_available() )
        uartData = inputcharacter();
    outputstring("\n\nTerminal Echo Starting");
    while(1) {
        uartData = inputcharacter();
        outputstringnonl("You pressed : ");
        outputcharacter( uartData );
        outputstring(" <-");
        set_leds(uartData);
    }
}
