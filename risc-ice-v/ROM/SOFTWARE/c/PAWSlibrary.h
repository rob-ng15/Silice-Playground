// STDDEF.H DEFINITIONS
// FUNCTION DEFINITIONS

// UART AND TERMINAL INPUT / OUTPUT
extern void outputcharacter(char);
extern void outputstring(char *);
extern void outputstringnonl(char *);
extern void outputnumber_char( unsigned char );
extern void outputnumber_short( unsigned short );
extern void outputnumber_int( unsigned int );
extern char inputcharacter( void );
unsigned char inputcharacter_available( void );

// BASIC I/O
extern void set_leds( unsigned char );
extern unsigned char get_buttons( void );

// TIMERS AND PSEUDO RANDOM NUMBER GENERATOR
extern unsigned short rng( unsigned short );
extern void sleep( unsigned short );
extern void set_timer1khz( unsigned short );
extern unsigned short get_timer1khz( void );
extern void wait_timer1khz( void );
extern unsigned short get_timer1hz( void );
extern void reset_timer1hz( void );

// AUDIO
extern void beep( unsigned char, unsigned char, unsigned char, unsigned short );

// SDCARD
extern void sdcard_readsector( unsigned int, unsigned char * );

// DISPLAY
extern void await_vblank( void );

// BACKGROUND GENERATOR
extern void set_background( unsigned char, unsigned char, unsigned char );

// TERMINAL WINDOW
extern void terminal_showhide( unsigned char );

// TILEMAP
extern void set_tilemap_tile( unsigned char, unsigned char, unsigned char, unsigned char, unsigned char );
extern void set_tilemap_bitmap( unsigned char, unsigned short * );
extern unsigned char tilemap_scrollwrapclear( unsigned char );

// GPU AND BITMAP
extern void gpu_pixel( unsigned char, short, short );
extern void gpu_rectangle( unsigned char, short, short, short, short );
extern void gpu_cs( void );
extern void gpu_line( unsigned char, short, short, short, short );
extern void gpu_circle( unsigned char, short, short, short, unsigned char );
void gpu_blit( unsigned char, short, short, short, unsigned char );
extern void gpu_triangle( unsigned char, short, short, short, short, short, short );
extern void draw_vector_block( unsigned char, unsigned char, short, short );
extern void set_vector_vertex( unsigned char, unsigned char , unsigned char, char, char );
extern void bitmap_scrollwrap( unsigned char );
void set_blitter_bitmap( unsigned char, unsigned short * );

// SPRITES
extern void set_sprite( unsigned char, unsigned char, unsigned char, unsigned char, short, short, unsigned char, unsigned char );
extern unsigned short get_sprite_collision( unsigned char, unsigned char );
extern short get_sprite_attribute( unsigned char, unsigned char , unsigned char );
extern void set_sprite_attribute( unsigned char, unsigned char, unsigned char, short );
extern void update_sprite( unsigned char, unsigned char, unsigned short );
extern void set_sprite_bitmaps( unsigned char, unsigned char, unsigned short * );

// CHARACTER MAP
extern void tpu_cs( void );
extern void tpu_set(  unsigned char, unsigned char, unsigned char, unsigned char );
extern void tpu_output_character( char );
extern void tpu_outputstring( char * );
extern void tpu_outputnumber_char( unsigned char );
extern void tpu_outputnumber_short( unsigned short );
extern void tpu_outputnumber_int( unsigned int );
