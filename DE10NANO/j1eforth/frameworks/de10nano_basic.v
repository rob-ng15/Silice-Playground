`define DE10NANO 1
$$DE10NANO=1
$$HARDWARE=1

module Basic(
    // 50MHz clock input
    input clk,
    
    // uart via GPIO pins
    output tx,
    input rx,
    
    // user button and switches
    input   BUTTON0,
    input   BUTTON1,
    input   SWITCH0,
    input   SWITCH1,
    input   SWITCH2,
    input   SWITCH3,
    
    // Outputs to the 8 onboard LEDs
    output reg LED0,
    output reg LED1,
    output reg LED2,
    output reg LED3,
    output reg LED4,
    output reg LED5,
    output reg LED6,
    output reg LED7
    );

wire [7:0] __main_out_led;

reg [31:0] RST_d;
reg [31:0] RST_q;

reg ready = 0;

always @* begin
  RST_d = RST_q >> 1;
end

always @(posedge clk) begin
  if (ready) begin
    RST_q <= RST_d;
  end else begin
    ready <= 1;
    RST_q <= 32'b111111111111111111111111111111;
  end
end

wire reset_main;
assign reset_main = RST_q[0];
wire run_main;
assign run_main = 1'b1;


// Create 1hz (1 second counter)
reg [31:0] counter50mhz;
reg [15:0] counter1hz;
always @(posedge clk) begin
    if( counter50mhz == 50000000 ) begin
        counter1hz <= counter1hz + 1;
        counter50mhz <= 0;
    end else begin
        counter50mhz <= counter50mhz + 1;
    end
end 

// UART tx and rx
wire [7:0] uart_tx_data;
wire uart_tx_valid;
wire uart_tx_busy;
wire uart_tx_done;
wire [7:0] uart_rx_data;
wire uart_rx_valid;
wire uart_rx_ready;
wire uart_serial_tx;

// UART from https://github.com/cyrozap/osdvu
uart uart0(
    .clk(clk), // The master clock for this module
    .rst(reset_main), // Synchronous reset
    .rx(rx), // Incoming serial line
    .tx(tx), // Outgoing serial line
    .transmit(uart_tx_valid), // Signal to transmit
    .tx_byte(uart_tx_data), // Byte to transmit
    .received(uart_rx_valid), // Indicated that a byte has been received
    .rx_byte(uart_rx_data), // Byte received
    .is_receiving(), // Low when receive line is idle
    .is_transmitting(uart_tx_busy),// Low when transmit line is idle
    .recv_error() // Indicates error in receiving packet.
);

M_main __main(
  .clock(clk),
  .reset(reset_main),
  .in_run(run_main),
  
  // LEDS
  .out_led(__main_out_led),

  // BUTTONS and SWITCHES (combined)
  .in_buttons( {2'b0, SWITCH3, SWITCH2, SWITCH1, SWITCH0, BUTTON1, BUTTON0} ),
  
  // UART
  .out_uart_tx_data( uart_tx_data ),
  .out_uart_tx_valid( uart_tx_valid ),
  .in_uart_tx_busy( uart_tx_busy ),

  .in_uart_rx_data( uart_rx_data ),
  .in_uart_rx_valid( uart_rx_valid ),
    
  .in_timer1hz ( counter1hz )
);

always @* begin
  LED0 = __main_out_led[0+:1];
  LED1 = __main_out_led[1+:1];
  LED2 = __main_out_led[2+:1];
  LED3 = __main_out_led[3+:1];
  LED4 = __main_out_led[4+:1];
  LED5 = __main_out_led[5+:1];
  LED6 = __main_out_led[6+:1];
  LED7 = __main_out_led[7+:1];
end

endmodule
