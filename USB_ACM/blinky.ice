algorithm main(
    // RGB LED
    output uint3 led,
    // UART Interface
    output   uint8 uart_in_data,
    output   uint1 uart_in_valid,
    input    uint1 uart_in_ready,
    input    uint8 uart_out_data,
    input    uint1 uart_out_valid,
    output   uint1 uart_out_ready
) {
   while (1) {
        // when uart data available
        if(uart_out_valid) {
            // set LED to lower 3 bits
            led = uart_out_data[5,7];
            // echo input to uart
            uart_in_data = uart_out_data;
            uart_in_valid = 1;
            uart_out_ready = 1;
        }
        // reset to allow new uart data
        if(uart_in_ready & uart_in_valid) {
            uart_in_valid = 0;
        }
   }
}
