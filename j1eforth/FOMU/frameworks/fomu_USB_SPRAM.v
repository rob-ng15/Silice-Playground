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
`define GREENPWM RGB2PWM
`define REDPWM   RGB1PWM
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
  // 12MHz Clock Input
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
    wire clk;
    SB_GB clk_gb (
        .USER_SIGNAL_TO_GLOBAL_BUFFER(clki),
        .GLOBAL_BUFFER_OUTPUT(clk)
    );

    wire clk_usb, locked;
    pll usbpll( .clock_in( clk ), .clock_usb( clk_usb ), .locked( locked ) );

    // Create 1hz (1 second counter)
    reg [31:0] counter12mhz;
    reg [15:0] counter1hz;
    always @(posedge clk) begin
        if( counter12mhz == 12000000 ) begin
            counter1hz <= counter1hz + 1;
            counter12mhz <= 0;
        end else begin
            counter12mhz <= counter12mhz + 1;
        end
    end

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
    // 4 x 16384 x 16bit
    reg [15:0] sram_addr;               // 16bit 0-65535 address
    reg [15:0] sram_data_read;          // data read from SPRAM after bank switching
    wire [15:0] sram_data_in;           // to SB_SPRAM256KA
    wire [15:0] sram_data_out00;        // from SB_SPRAM256KA bank 00
    wire [15:0] sram_data_out01;        // from SB_SPRAM256KA bank 01
    wire [15:0] sram_data_out10;        // from SB_SPRAM256KA bank 10
    wire [15:0] sram_data_out11;        // from SB_SPRAM256KA bank 11
    wire sram_wren;

    always @(posedge clk) begin
        // SPRAM automatic bank switching for reading data from SB_SPRAM256KA banks
        case( sram_addr[15:14])
            2'b00: sram_data_read = sram_data_out00;
            2'b01: sram_data_read = sram_data_out01;
            2'b10: sram_data_read = sram_data_out10;
            2'b11: sram_data_read = sram_data_out11;
        endcase
    end

    SB_SPRAM256KA spram00 (
        .ADDRESS(sram_addr),
        .DATAIN(sram_data_in),
        .MASKWREN(4'b1111),
        .WREN(sram_wren & (sram_addr[15:14]==2'b00)),
        .CHIPSELECT(sram_addr[15:14]==2'b00),
        .CLOCK(clk),
        .STANDBY(1'b0),
        .SLEEP(1'b0),
        .POWEROFF(1'b1),
        .DATAOUT(sram_data_out00)
    );
    SB_SPRAM256KA spram01 (
        .ADDRESS(sram_addr),
        .DATAIN(sram_data_in),
        .MASKWREN(4'b1111),
        .WREN(sram_wren & (sram_addr[15:14]==2'b01)),
        .CHIPSELECT(sram_addr[15:14]==2'b01),
        .CLOCK(clk),
        .STANDBY(1'b0),
        .SLEEP(1'b0),
        .POWEROFF(1'b1),
        .DATAOUT(sram_data_out01)
    );
    SB_SPRAM256KA spram10 (
        .ADDRESS(sram_addr),
        .DATAIN(sram_data_in),
        .MASKWREN(4'b1111),
        .WREN(sram_wren & (sram_addr[15:14]==2'b10)),
        .CHIPSELECT(sram_addr[15:14]==2'b10),
        .CLOCK(clk),
        .STANDBY(1'b0),
        .SLEEP(1'b0),
        .POWEROFF(1'b1),
        .DATAOUT(sram_data_out10)
    );
    SB_SPRAM256KA spram11 (
        .ADDRESS(sram_addr),
        .DATAIN(sram_data_in),
        .MASKWREN(4'b1111),
        .WREN(sram_wren & (sram_addr[15:14]==2'b11)),
        .CHIPSELECT(sram_addr[15:14]==2'b11),
        .CLOCK(clk),
        .STANDBY(1'b0),
        .SLEEP(1'b0),
        .POWEROFF(1'b1),
        .DATAOUT(sram_data_out11)
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
    always @(posedge clk_usb)
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
        .clk_48mhz  (clk_usb),
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
    .out_rgbLED   ({rgbR, rgbG, rgbB}),
    .in_buttons   ({user_4, user_3, user_2, user_1}),
    .in_run       (run_main),

    // SPRAM
    .out_sram_address    (sram_addr),
    .out_sram_data_write (sram_data_in),
    .in_sram_data_read   (sram_data_read),
    .out_sram_readwrite  (sram_wren),

    // uart pipeline in
    .out_uart_in_data( uart_in_data ),
    .out_uart_in_valid( uart_in_valid ),
    .in_uart_in_ready( uart_in_ready ),

    .in_uart_out_data( uart_out_data ),
    .in_uart_out_valid( uart_out_valid ),
    .out_uart_out_ready( uart_out_ready  ),

    .in_timer1hz ( counter1hz )
);

endmodule
