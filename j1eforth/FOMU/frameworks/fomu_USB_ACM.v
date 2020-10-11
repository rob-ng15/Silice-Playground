`define FOMU 1
`default_nettype none
`define BLUEPWM  RGB0PWM
`define GREENPWM RGB2PWM
`define REDPWM   RGB1PWM
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
    wire rgbB, rgbG, rgbR;
    SB_RGBA_DRV #(
        .CURRENT_MODE("0b1"),       // half current
        .RGB0_CURRENT("0b000011"),  // 4 mA
        .RGB1_CURRENT("0b000011"),  // 4 mA
        .RGB2_CURRENT("0b000011")   // 4 mA
    ) RGBA_DRIVER (
        .CURREN(1'b1),
        .RGBLEDEN(1'b1),
        .`BLUEPWM(rgbB),     // Blue
        .`REDPWM(rgbG),      // Red
        .`GREENPWM(rgbR),    // Green
        .RGB0(rgb0),
        .RGB1(rgb1),
        .RGB2(rgb2)
    );

    // SPRAM driver
    // https://github.com/damdoy/ice40_ultraplus_examples/blob/master/spram/top.v
    // 65536 x 16bit
    reg [15:0] sram_addr;
    wire [15:0] sram_data_in;
    wire [15:0] sram_data_out;
    wire sram_wren;
    SB_SPRAM256KA spram (
        .ADDRESS(sram_addr),
        .DATAIN(sram_data_in),
        .MASKWREN(4'b1111),
        .WREN(sram_wren),
        .CHIPSELECT(1'b1),
        .CLOCK(clk_48mhz),
        .STANDBY(1'b0),
        .SLEEP(1'b0),
        .POWEROFF(1'b1),
        .DATAOUT(sram_data_out)
    );
    
    // Generate RESET
    reg [31:0] RST_d;
    reg [31:0] RST_q;

    reg ready = 0;

    always @* begin
    RST_d = RST_q >> 1;
    end

    always @(posedge clk_48mhz) begin
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
    .clock          (clk_48mhz),
    .reset          (RST_q[0]),
    .out_rgbB       (rgbB),
    .out_rgbG       (rgbG),
    .out_rgbR       (rgbR),
    .in_run         (run_main),

    // SPRAM
    .out_sram_addr      (sram_addr),
    .out_sram_data_in   (sram_data_in),
    .in_sram_data_out   (sram_data_out),
    .out_sram_wren      (sram_wren),
    
    // UART
    .out_uart_in_data( uart_in_data ),
    .out_uart_in_valid( uart_in_valid ),
    .in_uart_in_ready( uart_in_ready ),

    .in_uart_out_data( uart_out_data ),
    .in_uart_out_valid( uart_out_valid ),
    .out_uart_out_ready( uart_out_ready  )
    );

endmodule
