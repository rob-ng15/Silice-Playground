algorithm main(
    // RGB LED
    output uint1 rgbB,
    output uint1 rgbG,
    output uint1 rgbR,
    // UART Interface
    output   uint8 uart_in_data,
    output   uint1 uart_in_valid,
    input    uint1 uart_in_ready,
    input    uint8 uart_out_data,
    input    uint1 uart_out_valid,
    output   uint1 uart_out_ready
) {
    // Storage for value to return
    uint8 character = uninitialized;

    // Turn off the lights
    rgbR = 0; rgbG = 0; rgbB = 0;
    
    while (1) {
        // when uart data available
        if(uart_out_valid) {
            switch(uart_out_data)
            {
                // RED from R
                case 82: {
                    rgbR = 1;
                    character = 82;
                }
                // // GREEN from G
                case 71: {
                    rgbG = 1;
                    character = 71;
                }
                // BLUE from B
                case 66: {
                    rgbR = 1;
                    character = 66;
                }
                // OFF from X
                case 88: {
                    rgbR = 0; rgbG = 0; rgbB = 0;
                    character = 88;
                }
                // default return ?
                default: {
                    character = 63;
                }
            }
           // Output the return character
           uart_in_data = character;
           uart_in_valid = 1;
           uart_out_ready = 1;
        }
        // reset to allow new uart data
        if(uart_in_ready & uart_in_valid) {
            uart_in_valid = 0;
        }
    }
}
