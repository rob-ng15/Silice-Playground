int volatile * UARTSTATUS = (int volatile *)0x8004;
char * UARTDATA = (char *) 0x8000;
int volatile * BUTTONS = (int volatile *) 0x8008;
int volatile * LEDS = (int volatile *) 0x800c;

char * TERMINALOUTPUT = (char *) 0x8100;

void outputcharacter(char c)
{
	while( *UARTSTATUS & 2 );
    *UARTDATA = c;
    *TERMINALOUTPUT = c;
	if (c == '\n')
		outputcharacter('\r');
}
void outputstring(char *s)
{
	while(*s) {
		outputcharacter(*s);
		s++;
	}
	outputcharacter('\n');
}
void outputstringnonl(char *s)
{
	while(*s) {
		outputcharacter(*s);
		s++;
	}
}

char inputcharacter(void)
{
	while( !(*UARTSTATUS & 1) );
    return *UARTDATA;
}

void main()
{
    unsigned char uartData = 0;

    outputstring("Welcome to RISC-ICE-V a RISC-V RV32I CPU");
    outputstringnonl("> ");

    while(1) {
        uartData = inputcharacter();
        outputcharacter( uartData );
        *LEDS = uartData;
    }
}

