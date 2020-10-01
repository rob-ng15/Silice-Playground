`define DE10NANO 1
$$DE10NANO=1
$$VGA=1
$$HARDWARE=1
$$color_depth=6
$$color_max  =63
$$SDRAM=1
$$OLED=0
$$if YOSYS then
$$config['bram_wenable_width'] = 'data'
$$config['dualport_bram_wenable0_width'] = 'data'
$$config['dualport_bram_wenable1_width'] = 'data'
$$end

module SdramVga(
    input clk,
    output reg[7:0] led,

    // SDRAM
    output reg SDRAM_CLK,
    output reg SDRAM_CKE,
    output reg SDRAM_DQML,
    output reg SDRAM_DQMH,
    output reg SDRAM_nCS,
    output reg SDRAM_nWE,
    output reg SDRAM_nCAS,
    output reg SDRAM_nRAS,
    output reg [1:0] SDRAM_BA,
    output reg [12:0] SDRAM_A,
    // inout [15:0] SDRAM_DQ,
    inout [7:0] SDRAM_DQ,

    // VGA
    output reg vga_hs,
    output reg vga_vs,
    output reg [5:0] vga_r,
    output reg [5:0] vga_g,
    output reg [5:0] vga_b,

    // uart via GPIO pins
    output tx,
    input rx,
    
    // user button and switches
    input   BUTTON0,
    input   BUTTON1,
    input   SWITCH0,
    input   SWITCH1,
    input   SWITCH2,
    input   SWITCH3    
);

wire [7:0]  __main_out_led;

wire        __main_out_sdram_clk;
wire        __main_out_sdram_cle;
wire        __main_out_sdram_dqm;
wire        __main_out_sdram_cs;
wire        __main_out_sdram_we;
wire        __main_out_sdram_cas;
wire        __main_out_sdram_ras;
wire [1:0]  __main_out_sdram_ba;
wire [12:0] __main_out_sdram_a;
  
wire        __main_out_vga_hs;
wire        __main_out_vga_vs;
wire [5:0]  __main_out_vga_r;
wire [5:0]  __main_out_vga_g;
wire [5:0]  __main_out_vga_b;

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

// UART from https://github.com/jamieiles/uart
uart uart0(
    .din( uart_tx_data ),
    .wr_en( uart_tx_valid ),
    .clk_50m( clk ),
    .tx( tx ),
    .tx_busy( uart_tx_busy ),
    .rx( rx ),
    .rdy( uart_rx_valid ),
    .rdy_clr( uart_rx_ready ),
    .dout( uart_rx_data )
);

// UART from https://github.com/cyrozap/osdvu
//uart uart0(
//    .clk(clk), // The master clock for this module
//    .rst(reset_main), // Synchronous reset
//    .rx(rx), // Incoming serial line
//    .tx(tx), // Outgoing serial line
//    .transmit(uart_tx_valid), // Signal to transmit
//    .tx_byte(uart_tx_data), // Byte to transmit
//    .received(uart_rx_valid), // Indicated that a byte has been received
//    .rx_byte(uart_rx_data), // Byte received
//    .is_receiving(), // Low when receive line is idle
//    .is_transmitting(uart_tx_busy),// Low when transmit line is idle
//    .recv_error() // Indicates error in receiving packet.
//);

M_main __main(
  // CLK and RESET
  .clock(clk),
  .reset(reset_main),
  .in_run(run_main),
  
  // LEDS
  .out_led(__main_out_led),

  // BUTTONS and SWITCHES (combined)
  .in_buttons( {2'b0, SWITCH3, SWITCH2, SWITCH1, SWITCH0, BUTTON1, BUTTON0} ),
  
  .inout_sdram_dq(SDRAM_DQ[7:0]),
  .out_sdram_clk(__main_out_sdram_clk),
  .out_sdram_cle(__main_out_sdram_cle),
  .out_sdram_dqm(__main_out_sdram_dqm),
  .out_sdram_cs(__main_out_sdram_cs),
  .out_sdram_we(__main_out_sdram_we),
  .out_sdram_cas(__main_out_sdram_cas),
  .out_sdram_ras(__main_out_sdram_ras),
  .out_sdram_ba(__main_out_sdram_ba),
  .out_sdram_a(__main_out_sdram_a),
  .out_video_hs(__main_out_vga_hs),
  .out_video_vs(__main_out_vga_vs),
  .out_video_r(__main_out_vga_r),
  .out_video_g(__main_out_vga_g),
  .out_video_b(__main_out_vga_b),

  // UART
  .out_uart_tx_data( uart_tx_data ),
  .out_uart_tx_valid( uart_tx_valid ),
  .in_uart_tx_busy( uart_tx_busy ),
  .in_uart_tx_done( uart_tx_done ),

  .in_uart_rx_data( uart_rx_data ),
  .in_uart_rx_valid( uart_rx_valid ),
  .out_uart_rx_ready( uart_rx_ready ),  
  .in_timer1hz ( counter1hz )
);

always @* begin

  led          = __main_out_led;

  SDRAM_CLK    = __main_out_sdram_clk;
  SDRAM_CKE    = __main_out_sdram_cle;
  SDRAM_DQML   = __main_out_sdram_dqm;
  SDRAM_DQMH   = 0;
  SDRAM_nCS    = __main_out_sdram_cs;
  SDRAM_nWE    = __main_out_sdram_we;
  SDRAM_nCAS   = __main_out_sdram_cas;
  SDRAM_nRAS   = __main_out_sdram_ras;
  SDRAM_BA     = __main_out_sdram_ba;
  SDRAM_A      = __main_out_sdram_a;
  vga_hs       = __main_out_vga_hs;
  vga_vs       = __main_out_vga_vs;
  vga_r        = __main_out_vga_r;
  vga_g        = __main_out_vga_g;
  vga_b        = __main_out_vga_b;

end

endmodule
