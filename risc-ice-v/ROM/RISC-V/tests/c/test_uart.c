void main()
{
    int volatile * UARTSTATUS = (int volatile *)0x8004;
    int volatile * UARTDATA = (int volatile *) 0x8000;
    int volatile * BUTTONS = (int volatile *) 0x8008;
    int volatile * LEDS = (int volatile *) 0x800c;

    int volatile * TERMINALOUTPUT = (int volatile *) 0x8100;

    int uartData = 0;

    *TERMINALOUTPUT = 66;
    *TERMINALOUTPUT = 105;
    *TERMINALOUTPUT = 111;
    *TERMINALOUTPUT = 115;
    *TERMINALOUTPUT = 10;
    *TERMINALOUTPUT = 13;
    *TERMINALOUTPUT = 62;

    while(1) {
        if( *UARTSTATUS & 1 ) {
            // character received
            uartData = *UARTDATA;
            *UARTDATA = uartData;
            *TERMINALOUTPUT = uartData;
            *LEDS = uartData;
        }
    }
}

