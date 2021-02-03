// SIMPLE CURSES LIBRARY
#include <stdarg.h>

char            __curses_character[80][30], __curses_background[80][30], __curses_foreground[80][30];
unsigned char   __curses_backgroundcolours[16], __curses_foregroundcolours[16];

unsigned short  __curses_x = 0, __curses_y = 0, __curses_fore = WHITE, __curses_back = BLACK;

#define COLORS 64
#define COLOR_PAIRS 16
#define COLOR_PAIR(a) a

// COLOURS
#define COLOR_BLACK 0x00
#define COLOR_BLUE 0x03
#define COLOR_GREEN 0x0c
#define COLOR_CYAN 0x0f
#define COLOR_RED 0x30
#define COLOR_MAGENTA 0x33
#define COLOR_YELLOW 0x3c
#define COLOR_WHITE 0x3f
#define ORANGE 0x38

#define COLS 80
#define LINES 30


void initscr( void ) {
    for( unsigned x = 0; x < 80; x++ ) {
        for( unsigned y = 0; y < 30; y++ ) {
            __curses_character[x][y] = 0;
            __curses_background[x][y] = TRANSPARENT;
            __curses_foreground[x][y] = BLACK;
        }
    }
}

int endwin( void ) {
    return( true );
}

int refresh( void ) {
    for( unsigned char y = 0; y < 30; y ++ ) {
        for( unsigned char x = 0; x < 80; x++ ) {
            tpu_set( x, y, __curses_background[x][y], __curses_foreground[x][y] );
            tpu_output_character( __curses_character[x][y] );
        }
    }

    return( true );
}

int clear( void ) {
    initscr();
    return( true );
}

void cbreak( void ) {
}

void echo( void ) {
}

void noecho( void ) {
}

void curs_set( int visibility ) {
}

int start_color( void ) {
    for( unsigned short i = 0; i < 15; i++ ) {
        __curses_foregroundcolours[i] = BLACK;
        __curses_backgroundcolours[i] = BLACK;
    }
    __curses_foregroundcolours[0] = BLACK;
    __curses_foregroundcolours[1] = RED;
    __curses_foregroundcolours[2] = GREEN;
    __curses_foregroundcolours[3] = YELLOW;
    __curses_foregroundcolours[4] = BLUE;
    __curses_foregroundcolours[5] = MAGENTA;
    __curses_foregroundcolours[6] = CYAN;
    __curses_foregroundcolours[7] = WHITE;
}

bool has_colors( void ) {
    return( true );
}

bool can_change_color( void ) {
    return( true );
}

int init_pair( short pair, short f, short b ) {
    __curses_foregroundcolours[ pair ] = f;
    __curses_backgroundcolours[ pair ] = b;

    return( true );
}

int move( int y, int x ) {
    __curses_x = ( unsigned short ) ( x < 0 ) ? 0 : ( x > 79 ) ? 79 : x;
    __curses_y = ( unsigned short ) ( y < 0 ) ? 0 : ( y > 29 ) ? 29 : y;

    return( true );
}

int addch( unsigned char ch ) {
    __curses_character[ __curses_x ][ __curses_y ] = ch;
    __curses_background[ __curses_x ][ __curses_y ] = __curses_back;
    __curses_foreground[ __curses_x ][ __curses_y ] = __curses_fore;
    if( __curses_x == 79 ) {
        __curses_x = 0;
        __curses_y = ( __curses_y == 29 ) ? 0 : __curses_y + 1;
    } {
        __curses_x++;
    }

    return( true );
}

int mvaddch( int y, int x, unsigned char ch ) {
    (void)move( y, x );
    return( addch( ch ) );
}

// printw and mvprintw uses printf code from https://github.com/sylefeb/Silice/tree/wip/projects/ram-ice-v/tests/mylibc

void __curses_print_string(const char* s) {
   for(const char* p = s; *p; ++p) {
      addch(*p);
   }
}

void __curses_print_dec(int val) {
   char buffer[255];
   char *p = buffer;
   if(val < 0) {
      addch('-');
      __curses_print_dec(-val);
      return;
   }
   while (val || p == buffer) {
      *(p++) = val % 10;
      val = val / 10;
   }
   while (p != buffer) {
      addch('0' + *(--p));
   }
}

void __curses_print_hex_digits(unsigned int val, int nbdigits) {
   for (int i = (4*nbdigits)-4; i >= 0; i -= 4) {
      addch("0123456789ABCDEF"[(val >> i) % 16]);
   }
}

void __curses_print_hex(unsigned int val) {
   __curses_print_hex_digits(val, 8);
}

int printw( const char *fmt,... ) {
    va_list ap;
    for( va_start( ap, fmt ); *fmt; fmt++ ) {
        if( *fmt == '%' ) {
            fmt++;
        if( *fmt=='s' )
            __curses_print_string( va_arg( ap, char * ) );
        else if( *fmt == 'x' )
            __curses_print_hex( va_arg( ap, int ) );
        else if( *fmt == 'd' )
            __curses_print_dec(va_arg(ap,int) );
        else if( *fmt == 'c' )
            addch( va_arg( ap, int ) );
        else
            addch( *fmt );
        } else {
            addch( *fmt );
        }
    }
    va_end(ap);

    return( true );
}

int mvprintw( int y, int x, const char *fmt,... ) {
    move( y, x );

    va_list ap;
    for( va_start( ap, fmt ); *fmt; fmt++ ) {
        if( *fmt == '%' ) {
            fmt++;
        if( *fmt=='s' )
            __curses_print_string( va_arg( ap, char * ) );
        else if( *fmt == 'x' )
            __curses_print_hex( va_arg( ap, int ) );
        else if( *fmt == 'd' )
            __curses_print_dec(va_arg(ap,int) );
        else if( *fmt == 'c' )
            addch( va_arg( ap, int ) );
        else
            addch( *fmt );
        } else {
            addch( *fmt );
        }
    }
    va_end(ap);

    return( true );
}

int attron( int attrs ) {
    __curses_fore = __curses_foregroundcolours[ attrs ];
    __curses_back = __curses_backgroundcolours[ attrs ];
    return( true );
}

int deleteln( void ) {
    if( __curses_y == 29 ) {
        // BLANK LAST LINE
        for( unsigned char x = 0; x < 80; x++ ) {
            __curses_character[x][29] = 0;
            __curses_background[x][29] = __curses_back;
            __curses_foreground[x][29] = __curses_fore;
        }
    } else {
        // MOVE LINES UP
        for( unsigned char y = __curses_y; y < 29; y++ ) {
            for( unsigned char x = 0; x < 80; x++ ) {
                __curses_character[x][y] = __curses_character[x][y+1];
                __curses_background[x][y] = __curses_background[x][y+1];
                __curses_foreground[x][y] = __curses_foreground[x][y+1];
            }
        }

        // BLANK LAST LINE
        for( unsigned char x = 0; x < 80; x++ ) {
            __curses_character[x][29] = 0;
            __curses_background[x][29] = __curses_back;
            __curses_foreground[x][29] = __curses_fore;
        }
    }

    return( true );
}

int clrtoeol( void ) {
    for( int x = __curses_x; x < 80; x++ ) {
            __curses_character[x][__curses_y] = 0;
            __curses_background[x][__curses_y] = __curses_back;
            __curses_foreground[x][__curses_y] = __curses_fore;
    }
    return( true );
}

