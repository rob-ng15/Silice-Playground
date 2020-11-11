void main()
{
  int* const UARTSTATUS = (int*)0x1002;
  int* const UARTDATA = (int*) 0x1000;
  int* const TERMINALOUTPUT = (int*) 0x1004;
  int* const LEDS = (int*) 0x1008;

  volatile int leds = 0;
  int uartData = 0;

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

