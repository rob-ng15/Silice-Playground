// FUNCTION DEFINITIONS
extern void outputcharacter(char);
extern void outputstring(char *);
extern void outputstringnonl(char *);
extern void outputnumber_char( unsigned char );
extern void outputnumber_short( unsigned short );
extern void outputnumber_int( unsigned int );
extern char inputcharacter( void );
extern unsigned short rng( unsigned short );
extern void sleep( unsigned short );
extern void set_timer1khz( unsigned short );
extern void wait_timer1khz( void );
extern void beep( unsigned char, unsigned char, unsigned char, unsigned short );
extern void set_background( unsigned char, unsigned char, unsigned char );
extern void terminal_showhide( unsigned char );
extern void await_vblank( void );
extern void set_tilemap_tile( unsigned char, unsigned char, unsigned char, unsigned char, unsigned char );
extern void set_tilemap_line( unsigned char, unsigned char, unsigned short );
extern void tilemap_scrollwrapclear( unsigned char );
extern void wait_gpu( void );
extern void gpu_pixel( unsigned char, short, short );
extern void gpu_rectangle( unsigned char, short, short, short, short );
extern void gpu_cs( void );
extern void gpu_line( unsigned char, short, short, short, short );
extern void gpu_circle( unsigned char, short, short, short );
void gpu_blit( unsigned char, short, short, short );
extern void gpu_fillcircle( unsigned char, short, short, short );
extern void gpu_triangle( unsigned char, short, short, short, short, short, short );
extern void draw_vector_block( unsigned char, unsigned char, short, short );
extern void set_vector_vertex( unsigned char, unsigned char , unsigned char, char, char );
extern void bitmap_scrollwrap( unsigned char );
void set_blitter_bitmap( unsigned char, unsigned short * );
extern void set_sprite( unsigned char, unsigned char, unsigned char, unsigned char, short, short, unsigned char, unsigned char );
extern unsigned short get_sprite_collision( unsigned char, unsigned char );
extern short get_sprite_attribute( unsigned char, unsigned char , unsigned char );
extern void set_sprite_attribute( unsigned char, unsigned char, unsigned char, short );
extern void update_sprite( unsigned char, unsigned char, unsigned short );
extern void set_sprite_line( unsigned char, unsigned char, unsigned char, unsigned short );
extern void tpu_cs( void );
extern void tpu_set(  unsigned char, unsigned char, unsigned char, unsigned char );
extern void tpu_output_character( char );
extern void tpu_outputstring( char * );
extern void tpu_outputnumber_char( unsigned char );
extern void tpu_outputnumber_short( unsigned short );
extern void tpu_outputnumber_int( unsigned int );

// I/O MEMORY MAPPED REGISTER DEFINITIONS
extern unsigned char volatile * UART_STATUS;
extern unsigned char * UART_DATA;
extern unsigned char volatile * BUTTONS;
extern unsigned char volatile * LEDS;

extern unsigned char volatile * SDCARD_READY;
extern unsigned char volatile * SDCARD_START;
extern unsigned short volatile * SDCARD_SECTOR_LOW;
extern unsigned short volatile * SDCARD_SECTOR_HIGH;
extern unsigned short volatile * SDCARD_ADDRESS;
extern unsigned char volatile * SDCARD_DATA;

extern unsigned char * TERMINAL_OUTPUT;
extern unsigned char volatile * TERMINAL_SHOWHIDE;
extern unsigned char volatile * TERMINAL_STATUS;

extern unsigned char volatile * BACKGROUND_COLOUR;
extern unsigned char volatile * BACKGROUND_ALTCOLOUR;
extern unsigned char volatile * BACKGROUND_MODE;

extern unsigned char volatile * TM_X;
extern unsigned char volatile * TM_Y;
extern unsigned char volatile * TM_TILE;
extern unsigned char volatile * TM_BACKGROUND;
extern unsigned char volatile * TM_FOREGROUND;
extern unsigned char volatile * TM_COMMIT;
extern unsigned char volatile * TM_WRITER_TILE_NUMBER;
extern unsigned char volatile * TM_WRITER_LINE_NUMBER;
extern unsigned short volatile * TM_WRITER_BITMAP;
extern unsigned char volatile * TM_SCROLLWRAPCLEAR;
extern unsigned char volatile * TM_STATUS;

extern short volatile * GPU_X;
extern short volatile * GPU_Y;
extern unsigned char volatile * GPU_COLOUR;
extern short volatile * GPU_PARAM0;
extern short volatile * GPU_PARAM1;
extern short volatile * GPU_PARAM2;
extern short volatile * GPU_PARAM3;
extern unsigned char volatile * GPU_WRITE;
extern unsigned char volatile * GPU_STATUS;

extern unsigned char volatile * BLIT_WRITER_TILE;
extern unsigned char volatile * BLIT_WRITER_LINE;
extern unsigned short volatile * BLIT_WRITER_BITMAP;

extern unsigned char volatile * VECTOR_DRAW_BLOCK;
extern unsigned char volatile * VECTOR_DRAW_COLOUR;
extern short volatile * VECTOR_DRAW_XC;
extern short volatile * VECTOR_DRAW_YC;
extern unsigned char volatile * VECTOR_DRAW_START;
extern unsigned char volatile * VECTOR_DRAW_STATUS;

extern unsigned char volatile * VECTOR_WRITER_BLOCK;
extern unsigned char volatile * VECTOR_WRITER_VERTEX;
extern unsigned char volatile * VECTOR_WRITER_ACTIVE;
extern char volatile * VECTOR_WRITER_DELTAX;
extern char volatile * VECTOR_WRITER_DELTAY;

extern unsigned char volatile * BITMAP_SCROLLWRAP;

extern unsigned char volatile * LOWER_SPRITE_NUMBER;
extern unsigned char volatile * LOWER_SPRITE_ACTIVE;
extern unsigned char volatile * LOWER_SPRITE_TILE;
extern unsigned char volatile * LOWER_SPRITE_COLOUR;
extern short volatile * LOWER_SPRITE_X;
extern short volatile * LOWER_SPRITE_Y;
extern unsigned char volatile * LOWER_SPRITE_DOUBLE;
extern unsigned short volatile * LOWER_SPRITE_UPDATE;
extern unsigned char volatile * LOWER_SPRITE_WRITER_NUMBER;
extern unsigned char volatile * LOWER_SPRITE_WRITER_LINE;
extern unsigned short volatile * LOWER_SPRITE_WRITER_BITMAP;
extern unsigned short volatile * LOWER_SPRITE_COLLISION_BASE;

extern unsigned char volatile * UPPER_SPRITE_NUMBER;
extern unsigned char volatile * UPPER_SPRITE_ACTIVE;
extern unsigned char volatile * UPPER_SPRITE_TILE;
extern unsigned char volatile * UPPER_SPRITE_COLOUR;
extern short volatile * UPPER_SPRITE_X;
extern short volatile * UPPER_SPRITE_Y;
extern unsigned char volatile * UPPER_SPRITE_DOUBLE;
extern unsigned short volatile * UPPER_SPRITE_UPDATE;
extern unsigned char volatile * UPPER_SPRITE_WRITER_NUMBER;
extern unsigned char volatile * UPPER_SPRITE_WRITER_LINE;
extern unsigned short volatile * UPPER_SPRITE_WRITER_BITMAP;
extern unsigned short volatile * UPPER_SPRITE_COLLISION_BASE;

extern unsigned char volatile * TPU_X;
extern unsigned char volatile * TPU_Y;
extern unsigned char volatile * TPU_CHARACTER;
extern unsigned char volatile * TPU_BACKGROUND;
extern unsigned char volatile * TPU_FOREGROUND;
extern unsigned char volatile * TPU_COMMIT;

extern unsigned char volatile * AUDIO_L_WAVEFORM;
extern unsigned char volatile * AUDIO_L_NOTE;
extern unsigned short volatile * AUDIO_L_DURATION8;
extern unsigned char volatile * AUDIO_L_START;
extern unsigned char volatile * AUDIO_R_WAVEFORM;
extern unsigned char volatile * AUDIO_R_NOTE;
extern unsigned short volatile * AUDIO_R_DURATION;
extern unsigned char volatile * AUDIO_R_START;

extern unsigned short volatile * RNG;
extern unsigned short volatile * ALT_RNG;
extern unsigned short volatile * TIMER1HZ;
extern unsigned short volatile * TIMER1KHZ;
extern unsigned short volatile * SLEEPTIMER;

extern unsigned char volatile * VBLANK;
