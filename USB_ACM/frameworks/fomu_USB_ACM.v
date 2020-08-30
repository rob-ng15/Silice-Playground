`define FOMU 1
`default_nettype none
// Correctly map pins for the iCE40UP5K SB_RGBA_DRV hard macro.
// The variables EVT, PVT and HACKER are set from the yosys commandline e.g. yosys -D HACKER=1
`ifdef EVT
`define BLUEPWM  RGB0PWM
`define REDPWM   RGB1PWM
`define GREENPWM RGB2PWM
`elsif HACKER
`define BLUEPWM  RGB0PWM
`define GREENPWM RGB1PWM
`define REDPWM   RGB2PWM
`elsif PVT
`define GREENPWM RGB0PWM
`define REDPWM   RGB1PWM
`define BLUEPWM  RGB2PWM
`else
`error_board_not_supported
`endif
$$FOMU=1
$$HARDWARE=1

module top(
  // 48MHz Clock Input
  input   clki,
  // LED outputs
  output rgb0,          // blue
  output rgb1,          // green
  output rgb2,          // red
  // USB Pins
  output usb_dp,
  output usb_dn,
  output usb_dp_pu,
  // SPI
  output spi_mosi,
  input  spi_miso,
  output spi_clk,
  output spi_cs,
  // USER pads
  input user_1,
  input user_2,
  input user_3,
  input user_4
);

    // Connect to system clock (with buffering)
    wire clk, clk_48mhz;
    SB_GB clk_gb (
        .USER_SIGNAL_TO_GLOBAL_BUFFER(clki),
        .GLOBAL_BUFFER_OUTPUT(clk)
    );
    assign clk_48mhz = clk;

    // RGB LED Driver
    wire [2:0] __main_led;
    SB_RGBA_DRV #(
        .CURRENT_MODE("0b1"),       // half current
        .RGB0_CURRENT("0b000011"),  // 4 mA
        .RGB1_CURRENT("0b000011"),  // 4 mA
        .RGB2_CURRENT("0b000011")   // 4 mA
    ) RGBA_DRIVER (
        .CURREN(1'b1),
        .RGBLEDEN(1'b1),
        .`BLUEPWM(__main_led[0]),     // Blue
        .`REDPWM(__main_led[1]),      // Red
        .`GREENPWM(__main_led[2]),    // Green
        .RGB0(rgb0),
        .RGB1(rgb1),
        .RGB2(rgb2)
    );

    // Generate RESET
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

    
    // USB_ACM UART CODE
    // Generate reset signal
    reg [5:0] reset_cnt = 0;
    wire reset = ~reset_cnt[5];
    always @(posedge clk_48mhz)
            reset_cnt <= reset_cnt + reset;

    // uart pipeline in
    reg  [7:0] uart_in_data;
    reg  uart_in_valid;
    wire uart_in_ready;
    wire [7:0] uart_out_data;
    wire uart_out_valid;
    wire uart_out_ready;

    // usb uart - this instanciates the entire USB device.
    usb_uart uart (
        .clk_48mhz  (clk_48mhz),
        .reset      (reset),

        // pins
        .pin_usb_p( usb_dp ),
        .pin_usb_n( usb_dn ),

        // uart pipeline in
        .uart_in_data( uart_in_data ),
        .uart_in_valid( uart_in_valid ),
        .uart_in_ready( uart_in_ready ),

        .uart_out_data( uart_out_data ),
        .uart_out_valid( uart_out_valid ),
        .uart_out_ready( uart_out_ready  )
    );

    // USB Host Detect Pull Up
    assign usb_dp_pu = 1'b1;
    
    
    M_main __main(
    .clock        (clk),
    .reset        (RST_q[0]),
    .out_led      (__main_led),
    .in_run       (run_main),

    
    // uart pipeline in
    .out_uart_in_data( uart_in_data ),
    .out_uart_in_valid( uart_in_valid ),
    .in_uart_in_ready( uart_in_ready ),

    .in_uart_out_data( uart_out_data ),
    .in_uart_out_valid( uart_out_valid ),
    .out_uart_out_ready( uart_out_ready  )
);

endmodule
