extern  int main( void );
void _start( void ) {
    // SETUP STACKPOINTER
    asm volatile ("li sp ,0x7f00");
    main();
}
