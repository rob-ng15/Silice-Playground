/*
    USB Serial

    Wrapping usb/usb_uart_ice40.v to create a loopback.
*/

`define BLUEPWM  RGB0PWM
`define GREENPWM RGB1PWM
`define REDPWM   RGB2PWM

module nb_fomu_hw (
        input        clki,

        inout        usb_dp, // USB D+ pin
        inout        usb_dn, // USB D- pin
        output       usb_dp_pu,

        output       rgb0, // SB_RGBA_DRV external pins
        output       rgb1,
        output       rgb2,
    );

    // Connect to system clock (with buffering)
    wire clkosc;
    SB_GB clk_gb (
        .USER_SIGNAL_TO_GLOBAL_BUFFER(clki),
        .GLOBAL_BUFFER_OUTPUT(clkosc)
    );

    assign clk_48mhz = clkosc;

    // Generate reset signal
    reg [5:0] reset_cnt = 0;
    wire reset = ~reset_cnt[5];
    always @(posedge clk_48mhz)
        //if ( clk_locked )
            reset_cnt <= reset_cnt + reset;

    // uart pipeline in
    wire [7:0] uart_in_data;
    wire uart_in_valid;
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

    localparam TEXT_LEN = 13;
    reg [103:0] hw = 104'h68656c6c6f20776f726c640a0d;
    reg [3:0] char_count = 0;

    // Send message about every second
    reg [26:0] delay_count = 0;

    reg [127:0] buffer;
    reg [5:0]   buflen = 0;
    reg red=0, green=0, blue=1;

    always @(posedge clk_48mhz) begin
       if (!reset) begin
          if(!buflen) begin // delay
             delay_count <= delay_count + 1;
             red <= 0;
             green <= 1;
             if (&delay_count) begin        // start again
                buffer[127:24] <= hw;
                buflen <= TEXT_LEN;
                delay_count <= 0;
            end
          end else begin
             red <= 1;
             green <= 0;
             if (!uart_in_valid && buflen) begin
                uart_in_data <= buffer[127:120];
                uart_in_valid <= 1;
             end else if(uart_in_ready && uart_in_valid) begin
                uart_in_valid <= 0;
                buffer <= buffer << 8;
                buflen <= buflen - 1;
             end
          end
       end
    end

   SB_RGBA_DRV #(
       .CURRENT_MODE("0b1"),       // half current
       .RGB0_CURRENT("0b000011"),  // 4 mA
       .RGB1_CURRENT("0b000011"),  // 4 mA
       .RGB2_CURRENT("0b000011")   // 4 mA
   ) RGBA_DRIVER (
       .CURREN(1'b1),
       .RGBLEDEN(1'b1),
       .`BLUEPWM(blue),       // Blue
       .`REDPWM(red),         // Red
       .`GREENPWM(green),     // Green
       .RGB0(rgb0),
       .RGB1(rgb1),
       .RGB2(rgb2)
   );

endmodule
