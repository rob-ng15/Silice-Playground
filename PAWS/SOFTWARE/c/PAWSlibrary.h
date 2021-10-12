#include "PAWSdefinitions.h"

// MEMORY
extern unsigned char *MEMORYTOP;

// RISC-V CSR FUNCTIONS
extern unsigned int CSRisa( void );
extern unsigned long CSRcycles( void );
extern unsigned long CSRinstructions( void );
extern unsigned long CSRtime( void );

// UART AND TERMINAL INPUT / OUTPUT
extern void outputcharacter(char);
extern char inputcharacter( void );
extern unsigned char character_available( void );

// PS/2
extern char ps2_character_available( void );
extern short ps2_inputcharacter( void );
extern void ps2_keyboardmode( unsigned char );

// BASIC I/O
extern void set_leds( unsigned char );
extern unsigned char get_buttons( void );

// TIMERS AND PSEUDO RANDOM NUMBER GENERATOR
extern unsigned short systemclock( void );
extern unsigned short secondssincestart( int );
extern unsigned short rng( unsigned short );
extern void sleep( unsigned short, unsigned char );
extern void set_timer1khz( unsigned short, unsigned char );
extern unsigned short get_timer1khz( unsigned char );
extern void wait_timer1khz( unsigned char );
extern unsigned short get_timer1hz( unsigned char );
extern void reset_timer1hz( unsigned char );

// AUDIO
extern void beep( unsigned char, unsigned char, unsigned char, unsigned short );
extern void await_beep( unsigned char );
extern unsigned short get_beep_active( unsigned char );

// SDCARD
extern unsigned char * sdcard_selectfile( char *, char *, unsigned int *, char * );

// DISPLAY
extern void await_vblank( void );
extern void screen_mode( unsigned char, unsigned char );
extern void bitmap_display( unsigned char );
extern void bitmap_draw( unsigned char );

// BACKGROUND GENERATOR
extern void set_background( unsigned char, unsigned char, unsigned char );
extern void copper_startstop( unsigned char ) ;
extern void copper_program( unsigned char, unsigned char, unsigned char, unsigned short, unsigned char, unsigned char, unsigned char );
extern void set_copper_cpuinput( unsigned short );

// TILEMAP
extern void set_tilemap_tile( unsigned char, unsigned char, unsigned char, unsigned char, unsigned char, unsigned char, unsigned char );
extern void set_tilemap_bitmap( unsigned char, unsigned char, unsigned short * );
extern unsigned char tilemap_scrollwrapclear( unsigned char, unsigned char );

// GPU AND BITMAP
extern void gpu_dither( unsigned char , unsigned char );
extern void gpu_crop( unsigned short, unsigned short, unsigned short, unsigned short );
extern void gpu_pixel( unsigned char, short, short );
extern void gpu_rectangle( unsigned char, short, short, short, short );
extern void gpu_box( unsigned char, short, short, short, short, unsigned short );
extern void gpu_cs( void );
extern void gpu_line( unsigned char, short, short, short, short );
extern void gpu_wideline( unsigned char, short, short, short, short, unsigned short );
extern void gpu_circle( unsigned char, short, short, short, unsigned char, unsigned char );
extern void gpu_blit( unsigned char, short, short, short, unsigned char, unsigned char );
extern void gpu_character_blit( unsigned char, short, short, unsigned short, unsigned char, unsigned char );
extern void gpu_character_blit_shadow( unsigned char, unsigned char, short, short, unsigned char, unsigned char, unsigned char );
extern void gpu_colourblit( short, short, short, unsigned char, unsigned char );
extern void gpu_triangle( unsigned char, short, short, short, short, short, short );
extern void gpu_quadrilateral( unsigned char, short, short, short, short, short, short, short, short );
extern void draw_vector_block( unsigned char, unsigned char, short, short, unsigned char, unsigned char );
extern void set_vector_vertex( unsigned char, unsigned char , unsigned char, char, char );
extern void bitmap_scrollwrap( unsigned char );
extern void set_blitter_bitmap( unsigned char, unsigned short * );
extern void set_blitter_chbitmap( unsigned char, unsigned char * );
extern void set_colourblitter_bitmap( unsigned char, unsigned char * );
extern void gpu_pixelblock7( short , short , unsigned short, unsigned short, unsigned char, unsigned char * );
extern void gpu_pixelblock24( short , short , unsigned short, unsigned short, unsigned char * );
extern void gpu_pixelblock24bw( short , short , unsigned short, unsigned short, unsigned char * );
extern void gpu_pixelblock_start( short , short , unsigned short );
extern void gpu_pixelblock_pixel7( unsigned char );
extern void gpu_pixelblock_pixel24( unsigned char, unsigned char, unsigned char );
extern void gpu_pixelblock_pixel24bw( unsigned char, unsigned char, unsigned char );
extern void gpu_pixelblock_stop( void );

extern void gpu_printf( unsigned char, short, short, unsigned char, unsigned char, unsigned char, const char *,...  );
extern void gpu_printf_centre( unsigned char, short, short, unsigned char, unsigned char, unsigned char, const char *,...  );
extern void gpu_printf_vertical( unsigned char, short, short, unsigned char, unsigned char, unsigned char, const char *,...  );
extern void gpu_printf_centre_vertical( unsigned char, short, short, unsigned char, unsigned char, unsigned char, const char *,...  );
extern void gpu_print( unsigned char, short, short, unsigned char, unsigned char, unsigned char, char * );
extern void gpu_print_centre( unsigned char, short, short, unsigned char, unsigned char, unsigned char, char * );
extern void gpu_print_vertical( unsigned char, short, short, unsigned char, unsigned char, unsigned char, char * );
extern void gpu_print_centre_vertical( unsigned char, short, short, unsigned char, unsigned char, unsigned char, char * );

// SOFTWARE VECTOR SHAPES
extern void DrawVectorShape2D( unsigned char, struct Point2D *, short, short, short, short, float );

// SOFTWARE DRAW LISTS
extern void DoDrawList2D( struct DrawList2D *, short, short, short, short, float );
extern void DoDrawList2Dscale( struct DrawList2D *, short, short, short, float );

// SPRITES - MAIN ACCESS
extern void set_sprite( unsigned char, unsigned char, unsigned char, unsigned char, short, short, unsigned char, unsigned char );
extern short get_sprite_attribute( unsigned char, unsigned char , unsigned char );
extern void set_sprite_attribute( unsigned char, unsigned char, unsigned char, short );
extern void update_sprite( unsigned char, unsigned char, unsigned short );
extern unsigned short get_sprite_collision( unsigned char, unsigned char );
extern unsigned short get_sprite_layer_collision( unsigned char, unsigned char );
extern void set_sprite_bitmaps( unsigned char, unsigned char, unsigned short * );

// CHARACTER MAP
extern void tpu_cs( void );
extern void tpu_clearline( unsigned char );
extern void tpu_set(  unsigned char, unsigned char, unsigned char, unsigned char );
extern void tpu_output_character( short );
extern void tpu_printf( char, const char *,... );
extern void tpu_printf_centre( unsigned char, unsigned char, unsigned char, char, const char *,... );
extern void tpu_print( char, char * );
extern void tpu_print_centre( unsigned char, unsigned char, unsigned char, char, char * );

// TERMINAL WINDOW
extern void terminal_cs( void );
extern void terminal_showhide( unsigned char );
extern void terminal_output_character( char );
extern void terminal_print( char * );
extern void terminal_printf( const char *,... );

// IMAGE DECODERS
extern void netppm_display( unsigned char *, unsigned char );
extern void netppm_decoder( unsigned char *, unsigned char * );

// nanojpeg.c from https://keyj.emphy.de/nanojpeg/
typedef enum _nj_result {
    NJ_OK = 0,        // no error, decoding successful
    NJ_NO_JPEG,       // not a JPEG file
    NJ_UNSUPPORTED,   // unsupported format
    NJ_OUT_OF_MEM,    // out of memory
    NJ_INTERNAL_ERR,  // internal error
    NJ_SYNTAX_ERROR,  // syntax error
    __NJ_FINISHED,    // used internally, will never be reported
} nj_result_t;
extern void njInit(void);
extern nj_result_t njDecode(const void* jpeg, const int size);
extern int njGetWidth(void);
extern int njGetHeight(void);
extern int njIsColor(void);
extern unsigned char* njGetImage(void);
extern int njGetImageSize(void);
extern void njDone(void);

// SMT START AND STOP
extern void SMTSTOP( void );
extern void SMTSTART( unsigned int );
extern unsigned char SMTSTATE( void );
extern void INITIALISEMEMORY( void );

// SIMPLE CURSES
extern void initscr( void );
extern int endwin( void );
extern int refresh( void );
extern int clear( void );
extern void cbreak( void );
extern void echo( void );
extern void noecho( void );
extern void scroll( void );
extern void noscroll( void );
extern void curs_set( int );
extern void autorefresh( int );
extern int start_color( void );
extern bool has_colors( void );
extern bool can_change_color( void );
extern int init_pair( short pair, short f, short b );
extern int move( int y, int x );
extern void getyx( int *y, int *x );
extern int addch( unsigned char ch );
extern int mvaddch( int y, int x, unsigned char ch );
extern int printw( const char *fmt,... );
extern int mvprintw( int y, int x, const char *fmt,... );
extern int attron( int attrs );
extern int deleteln( void );
extern int clrtoeol( void );
