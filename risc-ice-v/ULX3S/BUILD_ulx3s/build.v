`define AUDIO 1
`define BUTTONS 1
`define HDMI 1
`define SDCARD 1
`define SDRAM 1
`define UART 1
`define ULX3S 1
`default_nettype none

module top(
  // basic
  output [7:0] leds,
  // buttons
  input  [6:0] btns,
`ifdef SDRAM
  // sdram
  output sdram_clk,
  output sdram_cke,
  output [1:0]  sdram_dqm,
  output sdram_csn,
  output sdram_wen,
  output sdram_casn,
  output sdram_rasn,
  output [1:0]  sdram_ba,
  output [12:0] sdram_a,
  inout  [15:0] sdram_d,
`endif  
`ifdef AUDIO
  output [3:0] audio_l,
  output [3:0] audio_r,
`endif  
`ifdef OLED  
  // oled
  output  oled_clk,
  output  oled_mosi,
  output  oled_dc,
  output  oled_resn,
  output  oled_csn,
`endif  
`ifdef SDCARD
  // sdcard
  output  sd_clk,
  output  sd_csn,
  output  sd_mosi,
  input   sd_miso,
`endif  
`ifdef GPIO
  // gpio
  output [27:0] gp,
  input  [27:0] gn,
`endif  
`ifdef VGA
  // vga
  output [27:0] gp,
  input  [27:0] gn,
`endif  
`ifdef HDMI
  // hdmi
  output [3:0]  gpdi_dp, // {clock,R,G,B}
  output [3:0]  gpdi_dn,
`endif  
`ifdef UART
  // uart
  output  ftdi_rxd,
  input   ftdi_txd,
`endif
`ifdef UART2
  // uart2
`endif
  input  clk_25mhz
  );

wire [7:0]  __main_out_leds;

`ifdef OLED
wire        __main_oled_clk;
wire        __main_oled_mosi;
wire        __main_oled_dc;
wire        __main_oled_resn;
wire        __main_oled_csn;
`endif

`ifdef SDRAM
wire        __main_out_sdram_clk;
wire        __main_out_sdram_cle;
wire [1:0]  __main_out_sdram_dqm;
wire        __main_out_sdram_cs;
wire        __main_out_sdram_we;
wire        __main_out_sdram_cas;
wire        __main_out_sdram_ras;
wire [1:0]  __main_out_sdram_ba;
wire [12:0] __main_out_sdram_a;
`endif

`ifdef UART2
`ifndef GPIO
`error_UART2_needs_GPIO
`endif
`endif

`ifdef UART
wire        __main_out_uart_tx;
`endif

`ifdef VGA
wire        __main_out_vga_hs;
wire        __main_out_vga_vs;
wire [5:0]  __main_out_vga_r;
wire [5:0]  __main_out_vga_g;
wire [5:0]  __main_out_vga_b;
`endif

`ifdef SDCARD
wire        __main_sd_clk;
wire        __main_sd_csn;
wire        __main_sd_mosi;
`endif

`ifdef HDMI
wire [3:0]  __main_out_gpdi_dp;
wire [3:0]  __main_out_gpdi_dn;
`endif

`ifdef AUDIO
wire [3:0]  __main_out_audio_l;
wire [3:0]  __main_out_audio_r;
`endif

wire ready = btns[0];

reg [31:0] RST_d;
reg [31:0] RST_q;

always @* begin
  RST_d = RST_q >> 1;
end

always @(posedge clk_25mhz) begin
  if (ready) begin
    RST_q <= RST_d;
  end else begin
    RST_q <= 32'b111111111111111111111111111111;
  end
end

wire run_main;
assign run_main = 1'b1;

M_main __main(
  .reset         (RST_q[0]),
  .in_run        (run_main),
  .out_leds      (__main_out_leds),
`ifdef BUTTONS  
  .in_btns       (btns),
`endif
`ifdef SDRAM
  .inout_sdram_dq(sdram_d),
  .out_sdram_clk (__main_out_sdram_clk),
  .out_sdram_cle (__main_out_sdram_cle),
  .out_sdram_dqm (__main_out_sdram_dqm),
  .out_sdram_cs  (__main_out_sdram_cs),
  .out_sdram_we  (__main_out_sdram_we),
  .out_sdram_cas (__main_out_sdram_cas),
  .out_sdram_ras (__main_out_sdram_ras),
  .out_sdram_ba  (__main_out_sdram_ba),
  .out_sdram_a   (__main_out_sdram_a),
`endif  
`ifdef SDCARD
  .out_sd_csn    (__main_sd_csn),
  .out_sd_clk    (__main_sd_clk),
  .out_sd_mosi   (__main_sd_mosi),
  .in_sd_miso    (sd_miso),
`endif  
`ifdef AUDIO
  .out_audio_l  (__main_out_audio_l),
  .out_audio_r  (__main_out_audio_r),
`endif  
`ifdef OLED
  .out_oled_clk (__main_oled_clk),
  .out_oled_mosi(__main_oled_mosi),
  .out_oled_dc  (__main_oled_dc),
  .out_oled_resn(__main_oled_resn),
  .out_oled_csn (__main_oled_csn),
`endif 
`ifdef GPIO
`ifdef UART2
  .out_gp       (gp[27:1]),
  .in_gn        (gn[27:1]),
  .out_uart2_tx (gp[0]),
  .in_uart2_rx  (gn[0]),
`else
  .out_gp       (gp),
  .in_gn        (gn),
`endif  
`endif  
`ifdef UART
  .out_uart_tx  (__main_out_uart_tx),
  .in_uart_rx   (ftdi_txd),
`endif  
`ifdef VGA
  .out_video_hs (__main_out_vga_hs),
  .out_video_vs (__main_out_vga_vs),
  .out_video_r  (__main_out_vga_r),
  .out_video_g  (__main_out_vga_g),
  .out_video_b  (__main_out_vga_b),  
`endif  
`ifdef HDMI
  .out_gpdi_dp  (__main_out_gpdi_dp),
  .out_gpdi_dn  (__main_out_gpdi_dn),
`endif
  .clock         (clk_25mhz)
);

assign leds          = __main_out_leds;

`ifdef SDRAM
assign sdram_clk     = __main_out_sdram_clk;
assign sdram_cke     = __main_out_sdram_cle;
assign sdram_dqm     = __main_out_sdram_dqm;
assign sdram_csn     = __main_out_sdram_cs;
assign sdram_wen     = __main_out_sdram_we;
assign sdram_casn    = __main_out_sdram_cas;
assign sdram_rasn    = __main_out_sdram_ras;
assign sdram_ba      = __main_out_sdram_ba;
assign sdram_a       = __main_out_sdram_a;
`endif

`ifdef AUDIO
assign audio_l       = __main_out_audio_l;
assign audio_r       = __main_out_audio_r;
`endif  

`ifdef VGA
assign gp[0]         = __main_out_vga_vs;
assign gp[1]         = __main_out_vga_hs;
assign gp[2]         = __main_out_vga_r[5];
assign gp[3]         = __main_out_vga_r[4];
assign gp[4]         = __main_out_vga_r[3];
assign gp[5]         = __main_out_vga_r[2];
assign gp[6]         = __main_out_vga_r[1];
assign gp[7]         = __main_out_vga_r[0];
assign gp[8]         = __main_out_vga_g[5];
assign gp[9]         = __main_out_vga_g[4];
assign gp[10]        = __main_out_vga_g[3];
assign gp[11]        = __main_out_vga_g[2];
assign gp[12]        = __main_out_vga_g[1];
assign gp[13]        = __main_out_vga_g[0];
assign gp[14]        = __main_out_vga_b[0];
assign gp[15]        = __main_out_vga_b[1];
assign gp[16]        = __main_out_vga_b[2];
assign gp[17]        = __main_out_vga_b[3];
assign gp[18]        = __main_out_vga_b[4];
assign gp[19]        = __main_out_vga_b[5];
`endif

`ifdef SDCARD
assign sd_clk        = __main_sd_clk;
assign sd_csn        = __main_sd_csn;
assign sd_mosi       = __main_sd_mosi;
`endif

`ifdef OLED
assign oled_clk      = __main_oled_clk;
assign oled_mosi     = __main_oled_mosi;
assign oled_dc       = __main_oled_dc;
assign oled_resn     = __main_oled_resn;
assign oled_csn      = __main_oled_csn;
`endif

`ifdef UART
assign ftdi_rxd      = __main_out_uart_tx;
`endif  

`ifdef HDMI
assign gpdi_dp       = __main_out_gpdi_dp;
assign gpdi_dn       = __main_out_gpdi_dn;
`endif

endmodule

module hdmi_clock (
        input  clk,           //  25 MHz
        output half_hdmi_clk  // 125 MHz
    );

`ifdef MOJO

`else

`ifdef DE10NANO

`else

`ifdef ULX3S

wire clkfb;
wire clkos;
wire clkout0;
wire clkout2;
wire locked;

(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .CLKOP_FPHASE(0),
        .CLKOP_CPHASE(0),
        .OUTDIVIDER_MUXA("DIVA"),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(2),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS_DIV(4),
        .CLKOS_CPHASE(0),
        .CLKOS_FPHASE(0),
        .CLKOS2_ENABLE("ENABLED"),
        .CLKOS2_DIV(20),
        .CLKOS2_CPHASE(0),
        .CLKOS2_FPHASE(0),
        .CLKFB_DIV(10),
        .CLKI_DIV(1),
        .FEEDBK_PATH("INT_OP")
    ) pll_i (
        .CLKI(clk),
        .CLKFB(clkfb),
        .CLKINTFB(clkfb),
        .CLKOP(clkout0), // 250
        .CLKOS(half_hdmi_clk),  // 125
        .CLKOS2(clkout2), // 25
        .RST(1'b0),
        .STDBY(1'b0),
        .PHASESEL0(1'b0),
        .PHASESEL1(1'b0),
        .PHASEDIR(1'b0),
        .PHASESTEP(1'b0),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK(locked)
	);

`else

`ifdef ICARUS

reg genclk;

initial begin
  genclk = 1'b0;
  forever #4 genclk = ~genclk;   // generates a 125 MHz clock
end

assign half_hdmi_clk = genclk;

`endif
    
`endif
`endif
`endif
    
endmodule


// @sylefeb differential pair for HDMI, outputting dual rate
//
// see also https://github.com/lawrie/ulx3s_examples/blob/master/hdmi/fake_differential.v

module differential_pair(
        input   clock,
        input   [1:0] pos,
        input   [1:0] neg,
        output  out_pin_pos,
        output  out_pin_neg
    );

`ifdef ULX3S

ODDRX1F ddr_pos
      (
        .D0(pos[0]),
        .D1(pos[1]),
        .Q(out_pin_pos),
        .SCLK(clock),
        .RST(0)
      );

ODDRX1F ddr_neg
      (
        .D0(neg[0]),
        .D1(neg[1]),
        .Q(out_pin_neg),
        .SCLK(clock),
        .RST(0)
      );

`else

`ifdef ICARUS

assign out_pin_pos = pos[0];
assign out_pin_neg = neg[0];

`endif

`endif

endmodule


module hdmi_differential_pairs(
        input   clock,
        input   [7:0] pos,
        input   [7:0] neg,
        output  [3:0] out_pos,
        output  [3:0] out_neg
    );

  differential_pair rp(
    .clock(clock),
    .pos(pos[0+:2]),
    .neg(neg[0+:2]),
    .out_pin_pos(out_pos[2+:1]),
    .out_pin_neg(out_neg[2+:1])
  );

  differential_pair gp(
    .clock(clock),
    .pos(pos[2+:2]),
    .neg(neg[2+:2]),
    .out_pin_pos(out_pos[1+:1]),
    .out_pin_neg(out_neg[1+:1])
  );

  differential_pair bp(
    .clock(clock),
    .pos(pos[4+:2]),
    .neg(neg[4+:2]),
    .out_pin_pos(out_pos[0+:1]),
    .out_pin_neg(out_neg[0+:1])
  );

  differential_pair cp(
    .clock(clock),
    .pos(pos[6+:2]),
    .neg(neg[6+:2]),
    .out_pin_pos(out_pos[3+:1]),
    .out_pin_neg(out_neg[3+:1])
  );

endmodule


module inout16_set(     
  inout  [15:0] io_pin,
  input  [15:0] io_write,
  output [15:0] io_read,
  input         io_write_enable
);

`ifdef DE10NANO

  altiobuf_bidir #(
     .number_of_channels(16),
     .enable_bus_hold("FALSE")
   ) iobuf(.datain(io_write), .dataout(io_read), .dataio(io_pin), .oe({16{io_write_enable}}));

`else

  assign io_pin  = io_write_enable ? io_write : 16'hZZ;
  assign io_read = io_pin; 
  
`endif

endmodule


module inout16_ff_ulx3s(     
  inout  [15:0] io_pin,
  input  [15:0] io_write,
  output [15:0] io_read,
  input         io_write_enable,
  input         clock
);

  wire [15:0] btw;
  BB       db_buf[15:0] (.I(io_write), .O(btw), .B(io_pin),  .T({16{~io_write_enable}}));
  IFS1P3BX dbi_ff[15:0] (.D(btw), .Q(io_read), .SCLK(clock), .PD({16{io_write_enable}}));

endmodule


// TODO allow parameteric modules from Silice

module out1_ff_ulx3s(
  input   clock,
  output  pin,
  input   d
);

  OFS1P3BX out_ff(.D(d), .Q(pin), .SCLK(clock), .PD(1'b0), .SP(1'b0));

endmodule


// TODO allow parameteric modules from Silice

module out2_ff_ulx3s(
  input        clock,
  output [1:0] pin,
  input  [1:0] d
);

  OFS1P3BX out_ff[1:0] (.D(d), .Q(pin), .SCLK(clock), .PD(1'b0), .SP(1'b0));

endmodule


// TODO allow parameteric modules from Silice

module out13_ff_ulx3s(
  input        clock,
  output [12:0] pin,
  input  [12:0] d
);

  OFS1P3BX out_ff[12:0] (.D(d), .Q(pin), .SCLK(clock), .PD(1'b0), .SP(1'b0));

endmodule


// diamond 3.7 accepts this PLL
// diamond 3.8-3.9 is untested
// diamond 3.10 or higher is likely to abort with error about unable to use feedback signal
// cause of this could be from wrong CPHASE/FPHASE parameters
module ulx3s_clk_risc_ice_v_CPU
(
    input clkin,         // 25 MHz, 0 deg
    output  clkCPU,      // 25 MHz              // CPU
    output  clkCOPRO,    // 50 MHz, 0 deg       // ALU + MULT/DIV CO-PROCESSOR
    output  clkCPUUNIT,  // 50 MHz, 0 deg       // FUNCTION BLOCKS FOR THE CPU
    output  clkMEMORY,   // 50 MHz, 0 deg       // MEMORY CONTROLLER - BRAM
    output  locked
);
(* FREQUENCY_PIN_CLKI="25" *)
(* FREQUENCY_PIN_CLKOP="50" *)
(* FREQUENCY_PIN_CLKOS="50" *)
(* FREQUENCY_PIN_CLKOS2="50" *)
(* FREQUENCY_PIN_CLKOS3="25" *)
(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .OUTDIVIDER_MUXA("DIVA"),
        .OUTDIVIDER_MUXB("DIVB"),
        .OUTDIVIDER_MUXC("DIVC"),
        .OUTDIVIDER_MUXD("DIVD"),
        .CLKI_DIV(1),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(12),
        .CLKOP_CPHASE(5),
        .CLKOP_FPHASE(0),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS_DIV(12),
        .CLKOS_CPHASE(5),
        .CLKOS_FPHASE(0),
        .CLKOS2_ENABLE("ENABLED"),
        .CLKOS2_DIV(12),
        .CLKOS2_CPHASE(5),
        .CLKOS2_FPHASE(0),
        .CLKOS3_ENABLE("ENABLED"),
        .CLKOS3_DIV(24),
        .CLKOS3_CPHASE(5),
        .CLKOS3_FPHASE(0),
        .FEEDBK_PATH("CLKOP"),
        .CLKFB_DIV(2)
    ) pll_i (
        .RST(1'b0),
        .STDBY(1'b0),
        .CLKI(clkin),
        .CLKOP(clkCOPRO),
        .CLKOS(clkMEMORY),
        .CLKOS2(clkCPUUNIT),
        .CLKOS3(clkCPU),
        .CLKFB(clkCOPRO),
        .CLKINTFB(),
        .PHASESEL0(1'b0),
        .PHASESEL1(1'b0),
        .PHASEDIR(1'b1),
        .PHASESTEP(1'b1),
        .PHASELOADREG(1'b1),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK(locked)
	);
endmodule


module ulx3s_clk_risc_ice_v_AUX
(
    input   clkin,              // 25 MHz, 0 deg
    output  clkIO,              // 50 MHz, 0 deg        // I/O controller, UART, SDCARD
    output  clkVIDEO,           // 25 MHz, 0 deg        // VIDEO
    output  clkSDRAM,           // 100 MHz, 0 deg       // SDRAM
    output  clkSDRAMcontrol,    // 100 MHz, 180 deg     // SDRAM controller
    output  locked
);
(* FREQUENCY_PIN_CLKI="25" *)
(* FREQUENCY_PIN_CLKOP="50" *)
(* FREQUENCY_PIN_CLKOS="25" *)
(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .OUTDIVIDER_MUXA("DIVA"),
        .OUTDIVIDER_MUXB("DIVB"),
        .OUTDIVIDER_MUXC("DIVC"),
        .OUTDIVIDER_MUXD("DIVD"),
        .CLKI_DIV(1),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(12),
        .CLKOP_CPHASE(5),
        .CLKOP_FPHASE(0),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS_DIV(24),
        .CLKOS_CPHASE(5),
        .CLKOS_FPHASE(0),
        .CLKOS2_ENABLE("ENABLED"),
        .CLKOS2_DIV(6),
        .CLKOS2_CPHASE(5),
        .CLKOS2_FPHASE(0),
        .CLKOS3_ENABLE("ENABLED"),
        .CLKOS3_DIV(6),
        .CLKOS3_CPHASE(8),
        .CLKOS3_FPHASE(0),
        .FEEDBK_PATH("CLKOP"),
        .CLKFB_DIV(2)
    ) pll_i (
        .RST(1'b0),
        .STDBY(1'b0),
        .CLKI(clkin),
        .CLKOP(clkIO),
        .CLKOS(clkVIDEO),
        .CLKOS2(clkSDRAM),
        .CLKOS3(clkSDRAMcontrol),
        .CLKFB(clkIO),
        .CLKINTFB(),
        .PHASESEL0(1'b0),
        .PHASESEL1(1'b0),
        .PHASEDIR(1'b1),
        .PHASESTEP(1'b1),
        .PHASELOADREG(1'b1),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK(locked)
	);
endmodule


module M_tmds_encoder (
in_data,
in_ctrl,
in_data_or_ctrl,
out_tmds,
reset,
out_clock,
clock
);
input  [7:0] in_data;
input  [1:0] in_ctrl;
input  [0:0] in_data_or_ctrl;
output  [9:0] out_tmds;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [3:0] _w_num_ones;
wire signed [4:0] _w_diff_ones_zeros;
wire signed [0:0] _w_xored1;
wire signed [0:0] _w_xored2;
wire signed [0:0] _w_xored3;
wire signed [0:0] _w_xored4;
wire signed [0:0] _w_xored5;
wire signed [0:0] _w_xored6;
wire signed [0:0] _w_xored7;
wire signed [0:0] _w_xnored1;
wire signed [0:0] _w_xnored2;
wire signed [0:0] _w_xnored3;
wire signed [0:0] _w_xnored4;
wire signed [0:0] _w_xnored5;
wire signed [0:0] _w_xnored6;
wire signed [0:0] _w_xnored7;

reg  [8:0] _d_q_m;
reg  [8:0] _q_q_m;
reg signed [4:0] _d_dc_bias;
reg signed [4:0] _q_dc_bias;
reg  [9:0] _d_tmds,_q_tmds;
assign out_tmds = _q_tmds;

always @(posedge clock) begin
  if (reset) begin
_q_q_m <= 0;
_q_dc_bias <= 0;
  end else begin
_q_q_m <= _d_q_m;
_q_dc_bias <= _d_dc_bias;
_q_tmds <= _d_tmds;
  end
end



assign _w_xnored7 = ~(in_data[7+:1]^_w_xnored6);
assign _w_xnored5 = ~(in_data[5+:1]^_w_xnored4);
assign _w_xnored1 = ~(in_data[1+:1]^in_data[0+:1]);
assign _w_xored1 = in_data[1+:1]^in_data[0+:1];
assign _w_xored2 = in_data[2+:1]^_w_xored1;
assign _w_xored3 = in_data[3+:1]^_w_xored2;
assign _w_xored4 = in_data[4+:1]^_w_xored3;
assign _w_xnored6 = ~(in_data[6+:1]^_w_xnored5);
assign _w_xored5 = in_data[5+:1]^_w_xored4;
assign _w_xored6 = in_data[6+:1]^_w_xored5;
assign _w_xored7 = in_data[7+:1]^_w_xored6;
assign _w_xnored2 = ~(in_data[2+:1]^_w_xnored1);
assign _w_diff_ones_zeros = _d_q_m[0+:1]+_d_q_m[1+:1]+_d_q_m[2+:1]+_d_q_m[3+:1]+_d_q_m[4+:1]+_d_q_m[5+:1]+_d_q_m[6+:1]+_d_q_m[7+:1]-6'd4;
assign _w_xnored3 = ~(in_data[3+:1]^_w_xnored2);
assign _w_num_ones = in_data[0+:1]+in_data[1+:1]+in_data[2+:1]+in_data[3+:1]+in_data[4+:1]+in_data[5+:1]+in_data[6+:1]+in_data[7+:1];
assign _w_xnored4 = ~(in_data[4+:1]^_w_xnored3);

always @* begin
_d_q_m = _q_q_m;
_d_dc_bias = _q_dc_bias;
_d_tmds = _q_tmds;
// _always_pre
if ((_w_num_ones>4)||(_w_num_ones==4&&in_data[0+:1]==0)) begin
// __block_1
// __block_3
_d_q_m = {1'b0,{_w_xnored7,_w_xnored6,_w_xnored5,_w_xnored4,_w_xnored3,_w_xnored2,_w_xnored1},in_data[0+:1]};
// __block_4
end else begin
// __block_2
// __block_5
_d_q_m = {1'b1,{_w_xored7,_w_xored6,_w_xored5,_w_xored4,_w_xored3,_w_xored2,_w_xored1},in_data[0+:1]};
// __block_6
end
// __block_7
if (in_data_or_ctrl) begin
// __block_8
// __block_10
if (_q_dc_bias==0||_w_diff_ones_zeros==0) begin
// __block_11
// __block_13
_d_tmds = {~_d_q_m[8+:1],_d_q_m[8+:1],(_d_q_m[8+:1]?_d_q_m[0+:8]:~_d_q_m[0+:8])};
if (_d_q_m[8+:1]==0) begin
// __block_14
// __block_16
_d_dc_bias = _q_dc_bias-_w_diff_ones_zeros;
// __block_17
end else begin
// __block_15
// __block_18
_d_dc_bias = _q_dc_bias+_w_diff_ones_zeros;
// __block_19
end
// __block_20
// __block_21
end else begin
// __block_12
// __block_22
if ((_q_dc_bias>0&&_w_diff_ones_zeros>0)||(_q_dc_bias<0&&_w_diff_ones_zeros<0)) begin
// __block_23
// __block_25
_d_tmds = {1'b1,_d_q_m[8+:1],~_d_q_m[0+:8]};
_d_dc_bias = _q_dc_bias+_d_q_m[8+:1]-_w_diff_ones_zeros;
// __block_26
end else begin
// __block_24
// __block_27
_d_tmds = {1'b0,_d_q_m};
_d_dc_bias = _q_dc_bias-(~_d_q_m[8+:1])+_w_diff_ones_zeros;
// __block_28
end
// __block_29
// __block_30
end
// __block_31
// __block_32
end else begin
// __block_9
// __block_33
  case (in_ctrl)
  2'b00: begin
// __block_35_case
// __block_36
_d_tmds = 10'b1101010100;
// __block_37
  end
  2'b01: begin
// __block_38_case
// __block_39
_d_tmds = 10'b0010101011;
// __block_40
  end
  2'b10: begin
// __block_41_case
// __block_42
_d_tmds = 10'b0101010100;
// __block_43
  end
  2'b11: begin
// __block_44_case
// __block_45
_d_tmds = 10'b1010101011;
// __block_46
  end
endcase
// __block_34
_d_dc_bias = 0;
// __block_47
end
// __block_48
end
endmodule


module M_hdmi_ddr_shifter (
in_data_r,
in_data_g,
in_data_b,
out_p_outbits,
out_n_outbits,
reset,
out_clock,
clock
);
input  [9:0] in_data_r;
input  [9:0] in_data_g;
input  [9:0] in_data_b;
output  [7:0] out_p_outbits;
output  [7:0] out_n_outbits;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
reg  [1:0] _t_clkbits;

reg  [2:0] _d_mod5;
reg  [2:0] _q_mod5;
reg  [9:0] _d_shift_r;
reg  [9:0] _q_shift_r;
reg  [9:0] _d_shift_g;
reg  [9:0] _q_shift_g;
reg  [9:0] _d_shift_b;
reg  [9:0] _q_shift_b;
reg  [7:0] _d_p_outbits,_q_p_outbits;
reg  [7:0] _d_n_outbits,_q_n_outbits;
assign out_p_outbits = _q_p_outbits;
assign out_n_outbits = _q_n_outbits;

always @(posedge clock) begin
  if (reset) begin
_q_mod5 <= 0;
_q_shift_r <= 0;
_q_shift_g <= 0;
_q_shift_b <= 0;
  end else begin
_q_mod5 <= _d_mod5;
_q_shift_r <= _d_shift_r;
_q_shift_g <= _d_shift_g;
_q_shift_b <= _d_shift_b;
_q_p_outbits <= _d_p_outbits;
_q_n_outbits <= _d_n_outbits;
  end
end




always @* begin
_d_mod5 = _q_mod5;
_d_shift_r = _q_shift_r;
_d_shift_g = _q_shift_g;
_d_shift_b = _q_shift_b;
_d_p_outbits = _q_p_outbits;
_d_n_outbits = _q_n_outbits;
_t_clkbits = 0;
// _always_pre
_d_shift_r = (_q_mod5==0)?in_data_r:_q_shift_r[2+:8];
_d_shift_g = (_q_mod5==0)?in_data_g:_q_shift_g[2+:8];
_d_shift_b = (_q_mod5==0)?in_data_b:_q_shift_b[2+:8];
_t_clkbits = (_q_mod5[0+:2]<2)?2'b11:((_q_mod5>2)?2'b00:2'b01);
_d_p_outbits = {_t_clkbits,_d_shift_b[0+:2],_d_shift_g[0+:2],_d_shift_r[0+:2]};
_d_n_outbits = {~_t_clkbits,~_d_shift_b[0+:2],~_d_shift_g[0+:2],~_d_shift_r[0+:2]};
_d_mod5 = (_q_mod5==4)?0:(_q_mod5+1);
end
endmodule


module M_hdmi (
in_red,
in_green,
in_blue,
out_x,
out_y,
out_active,
out_vblank,
out_gpdi_dp,
out_gpdi_dn,
reset,
out_clock,
clock
);
input  [7:0] in_red;
input  [7:0] in_green;
input  [7:0] in_blue;
output  [9:0] out_x;
output  [9:0] out_y;
output  [0:0] out_active;
output  [0:0] out_vblank;
output  [3:0] out_gpdi_dp;
output  [3:0] out_gpdi_dn;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire[3:0] _w_hdmi_out_out_pos;
wire[3:0] _w_hdmi_out_out_neg;
wire _w_pll_half_hdmi_clk;
wire  [9:0] _w_tmdsR_tmds;
wire  [9:0] _w_tmdsG_tmds;
wire  [9:0] _w_tmdsB_tmds;
wire  [7:0] _w_shift_p_outbits;
wire  [7:0] _w_shift_n_outbits;
wire  [1:0] _c_null_ctrl;
assign _c_null_ctrl = 0;
reg  [0:0] _t_hsync;
reg  [0:0] _t_vsync;

reg  [9:0] _d_cntx;
reg  [9:0] _q_cntx;
reg  [9:0] _d_cnty;
reg  [9:0] _q_cnty;
reg  [1:0] _d_sync_ctrl;
reg  [1:0] _q_sync_ctrl;
reg  [7:0] _d_latch_red;
reg  [7:0] _q_latch_red;
reg  [7:0] _d_latch_green;
reg  [7:0] _q_latch_green;
reg  [7:0] _d_latch_blue;
reg  [7:0] _q_latch_blue;
reg  [1:0] _d_prev_sync_ctrl;
reg  [1:0] _q_prev_sync_ctrl;
reg  [0:0] _d_prev_active;
reg  [0:0] _q_prev_active;
reg  [9:0] _d_x,_q_x;
reg  [9:0] _d_y,_q_y;
reg  [0:0] _d_active,_q_active;
reg  [0:0] _d_vblank,_q_vblank;
assign out_x = _q_x;
assign out_y = _q_y;
assign out_active = _q_active;
assign out_vblank = _q_vblank;
assign out_gpdi_dp = _w_hdmi_out_out_pos;
assign out_gpdi_dn = _w_hdmi_out_out_neg;

always @(posedge clock) begin
  if (reset) begin
_q_cntx <= 0;
_q_cnty <= 0;
_q_sync_ctrl <= 0;
_q_latch_red <= 0;
_q_latch_green <= 0;
_q_latch_blue <= 0;
_q_prev_sync_ctrl <= 0;
_q_prev_active <= 0;
  end else begin
_q_cntx <= _d_cntx;
_q_cnty <= _d_cnty;
_q_sync_ctrl <= _d_sync_ctrl;
_q_latch_red <= _d_latch_red;
_q_latch_green <= _d_latch_green;
_q_latch_blue <= _d_latch_blue;
_q_prev_sync_ctrl <= _d_prev_sync_ctrl;
_q_prev_active <= _d_prev_active;
_q_x <= _d_x;
_q_y <= _d_y;
_q_active <= _d_active;
_q_vblank <= _d_vblank;
  end
end


hdmi_differential_pairs _hdmi_out (
.clock(_w_pll_half_hdmi_clk),
.pos(_w_shift_p_outbits),
.neg(_w_shift_n_outbits),
.out_pos(_w_hdmi_out_out_pos),
.out_neg(_w_hdmi_out_out_neg)
);

hdmi_clock _pll (
.clk(clock),
.half_hdmi_clk(_w_pll_half_hdmi_clk)
);
M_tmds_encoder tmdsR (
.in_data(_q_latch_red),
.in_ctrl(_c_null_ctrl),
.in_data_or_ctrl(_q_prev_active),
.out_tmds(_w_tmdsR_tmds),
.reset(reset),
.clock(clock)
);
M_tmds_encoder tmdsG (
.in_data(_q_latch_green),
.in_ctrl(_c_null_ctrl),
.in_data_or_ctrl(_q_prev_active),
.out_tmds(_w_tmdsG_tmds),
.reset(reset),
.clock(clock)
);
M_tmds_encoder tmdsB (
.in_data(_q_latch_blue),
.in_ctrl(_q_prev_sync_ctrl),
.in_data_or_ctrl(_q_prev_active),
.out_tmds(_w_tmdsB_tmds),
.reset(reset),
.clock(clock)
);
M_hdmi_ddr_shifter shift (
.in_data_r(_w_tmdsR_tmds),
.in_data_g(_w_tmdsG_tmds),
.in_data_b(_w_tmdsB_tmds),
.out_p_outbits(_w_shift_p_outbits),
.out_n_outbits(_w_shift_n_outbits),
.reset(reset),
.clock(_w_pll_half_hdmi_clk)
);



always @* begin
_d_cntx = _q_cntx;
_d_cnty = _q_cnty;
_d_sync_ctrl = _q_sync_ctrl;
_d_latch_red = _q_latch_red;
_d_latch_green = _q_latch_green;
_d_latch_blue = _q_latch_blue;
_d_prev_sync_ctrl = _q_prev_sync_ctrl;
_d_prev_active = _q_prev_active;
_d_x = _q_x;
_d_y = _q_y;
_d_active = _q_active;
_d_vblank = _q_vblank;
_t_hsync = 0;
_t_vsync = 0;
// _always_pre
_d_prev_sync_ctrl = _q_sync_ctrl;
_d_prev_active = _q_active;
_t_hsync = (_q_cntx>655)&&(_q_cntx<752);
_t_vsync = (_q_cnty>489)&&(_q_cnty<492);
_d_sync_ctrl = {_t_vsync,_t_hsync};
_d_active = (_q_cntx<640)&&(_q_cnty<480);
_d_vblank = (_q_cnty>=480);
_d_x = (_q_cntx<640)?_q_cntx:0;
_d_y = (_q_cnty>=480)?0:_q_cnty;
_d_cnty = (_q_cntx==799)?(_q_cnty==524?0:(_q_cnty+1)):_q_cnty;
_d_cntx = (_q_cntx==799)?0:(_q_cntx+1);
_d_latch_red = in_red;
_d_latch_green = in_green;
_d_latch_blue = in_blue;
end
endmodule


module M_uart_sender #(
parameter IO_DATA_IN_WIDTH=1,parameter IO_DATA_IN_SIGNED=0,parameter IO_DATA_IN_INIT=0,
parameter IO_DATA_IN_READY_WIDTH=1,parameter IO_DATA_IN_READY_SIGNED=0,parameter IO_DATA_IN_READY_INIT=0,
parameter IO_BUSY_WIDTH=1,parameter IO_BUSY_SIGNED=0,parameter IO_BUSY_INIT=0
) (
in_io_data_in,
in_io_data_in_ready,
out_io_busy,
out_uart_tx,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [IO_DATA_IN_WIDTH-1:0] in_io_data_in;
input  [IO_DATA_IN_READY_WIDTH-1:0] in_io_data_in_ready;
output  [IO_BUSY_WIDTH-1:0] out_io_busy;
output  [0:0] out_uart_tx;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [9:0] _c_interval;
assign _c_interval = 434;

reg  [9:0] _d_counter;
reg  [9:0] _q_counter;
reg  [10:0] _d_transmit;
reg  [10:0] _q_transmit;
reg  [IO_BUSY_WIDTH-1:0] _d_io_busy,_q_io_busy;
reg  [0:0] _d_uart_tx,_q_uart_tx;
reg  [0:0] _d_index,_q_index;
assign out_io_busy = _q_io_busy;
assign out_uart_tx = _q_uart_tx;
assign out_done = (_q_index == 1);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_counter <= 0;
_q_transmit <= 0;
_q_io_busy <= IO_BUSY_INIT;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_counter <= _d_counter;
_q_transmit <= _d_transmit;
_q_io_busy <= _d_io_busy;
_q_uart_tx <= _d_uart_tx;
_q_index <= _d_index;
  end
end




always @* begin
_d_counter = _q_counter;
_d_transmit = _q_transmit;
_d_io_busy = _q_io_busy;
_d_uart_tx = _q_uart_tx;
_d_index = _q_index;
// _always_pre
if (_q_transmit>1) begin
// __block_1
// __block_3
if (_q_counter==0) begin
// __block_4
// __block_6
_d_uart_tx = _q_transmit[0+:1];
_d_transmit = {1'b0,_q_transmit[1+:10]};
// __block_7
end else begin
// __block_5
end
// __block_8
_d_counter = (_q_counter==_c_interval)?0:(_q_counter+1);
// __block_9
end else begin
// __block_2
// __block_10
_d_uart_tx = 1;
_d_io_busy = 0;
if (in_io_data_in_ready) begin
// __block_11
// __block_13
_d_io_busy = 1;
_d_transmit = {1'b1,1'b0,in_io_data_in,1'b0};
// __block_14
end else begin
// __block_12
end
// __block_15
// __block_16
end
// __block_17
_d_index = 1;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_counter = 0;
_d_transmit = 0;
// --
_d_uart_tx = 1;
_d_index = 1;
end
1: begin // end of uart_sender
end
default: begin 
_d_index = 1;
 end
endcase
end
endmodule


module M_uart_receiver #(
parameter IO_DATA_OUT_WIDTH=1,parameter IO_DATA_OUT_SIGNED=0,parameter IO_DATA_OUT_INIT=0,
parameter IO_DATA_OUT_READY_WIDTH=1,parameter IO_DATA_OUT_READY_SIGNED=0,parameter IO_DATA_OUT_READY_INIT=0
) (
in_uart_rx,
out_io_data_out,
out_io_data_out_ready,
reset,
out_clock,
clock
);
input  [0:0] in_uart_rx;
output  [IO_DATA_OUT_WIDTH-1:0] out_io_data_out;
output  [IO_DATA_OUT_READY_WIDTH-1:0] out_io_data_out_ready;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [9:0] _c_interval;
assign _c_interval = 434;
wire  [9:0] _c_half_interval;
assign _c_half_interval = 217;

reg  [9:0] _d_counter;
reg  [9:0] _q_counter;
reg  [3:0] _d_receiving;
reg  [3:0] _q_receiving;
reg  [9:0] _d_received;
reg  [9:0] _q_received;
reg  [0:0] _d_latched_rx;
reg  [0:0] _q_latched_rx;
reg  [IO_DATA_OUT_WIDTH-1:0] _d_io_data_out,_q_io_data_out;
reg  [IO_DATA_OUT_READY_WIDTH-1:0] _d_io_data_out_ready,_q_io_data_out_ready;
assign out_io_data_out = _q_io_data_out;
assign out_io_data_out_ready = _q_io_data_out_ready;

always @(posedge clock) begin
  if (reset) begin
_q_counter <= 0;
_q_receiving <= 0;
_q_received <= 0;
_q_latched_rx <= 0;
_q_io_data_out <= IO_DATA_OUT_INIT;
_q_io_data_out_ready <= IO_DATA_OUT_READY_INIT;
  end else begin
_q_counter <= _d_counter;
_q_receiving <= _d_receiving;
_q_received <= _d_received;
_q_latched_rx <= _d_latched_rx;
_q_io_data_out <= _d_io_data_out;
_q_io_data_out_ready <= _d_io_data_out_ready;
  end
end




always @* begin
_d_counter = _q_counter;
_d_receiving = _q_receiving;
_d_received = _q_received;
_d_latched_rx = _q_latched_rx;
_d_io_data_out = _q_io_data_out;
_d_io_data_out_ready = _q_io_data_out_ready;
// _always_pre
_d_io_data_out_ready = 0;
if (_q_receiving==0) begin
// __block_1
// __block_3
if (_q_latched_rx==0) begin
// __block_4
// __block_6
_d_receiving = 10;
_d_received = 0;
_d_counter = _c_half_interval;
// __block_7
end else begin
// __block_5
end
// __block_8
// __block_9
end else begin
// __block_2
// __block_10
if (_q_counter==0) begin
// __block_11
// __block_13
_d_received = {_q_latched_rx,_q_received[1+:9]};
_d_receiving = _q_receiving-1;
_d_counter = _c_interval;
if (_d_receiving==0) begin
// __block_14
// __block_16
_d_io_data_out = _d_received[1+:8];
_d_io_data_out_ready = 1;
// __block_17
end else begin
// __block_15
end
// __block_18
// __block_19
end else begin
// __block_12
// __block_20
_d_counter = _q_counter-1;
// __block_21
end
// __block_22
// __block_23
end
// __block_24
_d_latched_rx = in_uart_rx;
end
endmodule


module M_sdcard #(
parameter IO_ADDR_SECTOR_WIDTH=1,parameter IO_ADDR_SECTOR_SIGNED=0,parameter IO_ADDR_SECTOR_INIT=0,
parameter IO_READ_SECTOR_WIDTH=1,parameter IO_READ_SECTOR_SIGNED=0,parameter IO_READ_SECTOR_INIT=0,
parameter IO_READY_WIDTH=1,parameter IO_READY_SIGNED=0,parameter IO_READY_INIT=0,
parameter STORE_ADDR1_WIDTH=1,parameter STORE_ADDR1_SIGNED=0,parameter STORE_ADDR1_INIT=0,
parameter STORE_WENABLE1_WIDTH=1,parameter STORE_WENABLE1_SIGNED=0,parameter STORE_WENABLE1_INIT=0,
parameter STORE_WDATA1_WIDTH=1,parameter STORE_WDATA1_SIGNED=0,parameter STORE_WDATA1_INIT=0
) (
in_sd_miso,
in_io_addr_sector,
in_io_read_sector,
out_sd_clk,
out_sd_mosi,
out_sd_csn,
out_io_ready,
out_store_addr1,
out_store_wenable1,
out_store_wdata1,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [0:0] in_sd_miso;
input  [IO_ADDR_SECTOR_WIDTH-1:0] in_io_addr_sector;
input  [IO_READ_SECTOR_WIDTH-1:0] in_io_read_sector;
output  [0:0] out_sd_clk;
output  [0:0] out_sd_mosi;
output  [0:0] out_sd_csn;
output  [IO_READY_WIDTH-1:0] out_io_ready;
output  [STORE_ADDR1_WIDTH-1:0] out_store_addr1;
output  [STORE_WENABLE1_WIDTH-1:0] out_store_wenable1;
output  [STORE_WDATA1_WIDTH-1:0] out_store_wdata1;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [47:0] _c_cmd0;
assign _c_cmd0 = 48'b010000000000000000000000000000000000000010010101;
wire  [47:0] _c_cmd8;
assign _c_cmd8 = 48'b010010000000000000000000000000011010101010000111;
wire  [47:0] _c_cmd55;
assign _c_cmd55 = 48'b011101110000000000000000000000000000000000000001;
wire  [47:0] _c_acmd41;
assign _c_acmd41 = 48'b011010010100000000000000000000000000000000000001;
wire  [47:0] _c_cmd16;
assign _c_cmd16 = 48'b010100000000000000000000000000100000000000010101;
wire  [47:0] _c_cmd17;
assign _c_cmd17 = 48'b010100010000000000000000000000000000000001010101;
reg  [39:0] _t_status;

reg  [23:0] _d_count;
reg  [23:0] _q_count;
reg  [0:0] _d_do_read_sector;
reg  [0:0] _q_do_read_sector;
reg  [31:0] _d_do_addr_sector;
reg  [31:0] _q_do_addr_sector;
reg  [15:0] _d___sub_send_v_send_count;
reg  [15:0] _q___sub_send_v_send_count;
reg  [47:0] _d___sub_send_v_send_shift;
reg  [47:0] _q___sub_send_v_send_shift;
reg  [47:0] _d_i_send_cmd;
reg  [47:0] _q_i_send_cmd;
reg  [15:0] _d___sub_read_v_read_count;
reg  [15:0] _q___sub_read_v_read_count;
reg  [5:0] _d___sub_read_v_read_n;
reg  [5:0] _q___sub_read_v_read_n;
reg  [5:0] _d_i_read_len;
reg  [5:0] _q_i_read_len;
reg  [0:0] _d_i_read_wait;
reg  [0:0] _q_i_read_wait;
reg  [39:0] _d_o_read_answer;
reg  [39:0] _q_o_read_answer;
reg  [7:0] _d_i_read_rate;
reg  [7:0] _q_i_read_rate;
reg  [0:0] _d_sd_clk,_q_sd_clk;
reg  [0:0] _d_sd_mosi,_q_sd_mosi;
reg  [0:0] _d_sd_csn,_q_sd_csn;
reg  [IO_READY_WIDTH-1:0] _d_io_ready,_q_io_ready;
reg  [STORE_ADDR1_WIDTH-1:0] _d_store_addr1,_q_store_addr1;
reg  [STORE_WENABLE1_WIDTH-1:0] _d_store_wenable1,_q_store_wenable1;
reg  [STORE_WDATA1_WIDTH-1:0] _d_store_wdata1,_q_store_wdata1;
reg  [5:0] _d_index,_q_index;
reg  [3:0] _d_caller,_q_caller;
assign out_sd_clk = _q_sd_clk;
assign out_sd_mosi = _q_sd_mosi;
assign out_sd_csn = _q_sd_csn;
assign out_io_ready = _q_io_ready;
assign out_store_addr1 = _d_store_addr1;
assign out_store_wenable1 = _d_store_wenable1;
assign out_store_wdata1 = _d_store_wdata1;
assign out_done = (_q_index == 33);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_count <= 0;
_q_do_read_sector <= 0;
_q_do_addr_sector <= 0;
_q___sub_send_v_send_count <= 0;
_q_i_send_cmd <= 0;
_q___sub_read_v_read_count <= 0;
_q___sub_read_v_read_n <= 0;
_q_i_read_len <= 0;
_q_i_read_wait <= 0;
_q_o_read_answer <= 0;
_q_i_read_rate <= 0;
_q_io_ready <= IO_READY_INIT;
_q_store_addr1 <= STORE_ADDR1_INIT;
_q_store_wenable1 <= STORE_WENABLE1_INIT;
_q_store_wdata1 <= STORE_WDATA1_INIT;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_count <= _d_count;
_q_do_read_sector <= _d_do_read_sector;
_q_do_addr_sector <= _d_do_addr_sector;
_q___sub_send_v_send_count <= _d___sub_send_v_send_count;
_q___sub_send_v_send_shift <= _d___sub_send_v_send_shift;
_q_i_send_cmd <= _d_i_send_cmd;
_q___sub_read_v_read_count <= _d___sub_read_v_read_count;
_q___sub_read_v_read_n <= _d___sub_read_v_read_n;
_q_i_read_len <= _d_i_read_len;
_q_i_read_wait <= _d_i_read_wait;
_q_o_read_answer <= _d_o_read_answer;
_q_i_read_rate <= _d_i_read_rate;
_q_sd_clk <= _d_sd_clk;
_q_sd_mosi <= _d_sd_mosi;
_q_sd_csn <= _d_sd_csn;
_q_io_ready <= _d_io_ready;
_q_store_addr1 <= _d_store_addr1;
_q_store_wenable1 <= _d_store_wenable1;
_q_store_wdata1 <= _d_store_wdata1;
_q_index <= _d_index;
_q_caller <= _d_caller;
  end
end




always @* begin
_d_count = _q_count;
_d_do_read_sector = _q_do_read_sector;
_d_do_addr_sector = _q_do_addr_sector;
_d___sub_send_v_send_count = _q___sub_send_v_send_count;
_d___sub_send_v_send_shift = _q___sub_send_v_send_shift;
_d_i_send_cmd = _q_i_send_cmd;
_d___sub_read_v_read_count = _q___sub_read_v_read_count;
_d___sub_read_v_read_n = _q___sub_read_v_read_n;
_d_i_read_len = _q_i_read_len;
_d_i_read_wait = _q_i_read_wait;
_d_o_read_answer = _q_o_read_answer;
_d_i_read_rate = _q_i_read_rate;
_d_sd_clk = _q_sd_clk;
_d_sd_mosi = _q_sd_mosi;
_d_sd_csn = _q_sd_csn;
_d_io_ready = _q_io_ready;
_d_store_addr1 = _q_store_addr1;
_d_store_wenable1 = _q_store_wenable1;
_d_store_wdata1 = _q_store_wdata1;
_d_index = _q_index;
_d_caller = _q_caller;
_t_status = 0;
// _always_pre
_d_store_wenable1 = 1;
if (in_io_read_sector) begin
// __block_31
// __block_33
_d_do_read_sector = 1;
_d_do_addr_sector = in_io_addr_sector;
_d_io_ready = 0;
// __block_34
end else begin
// __block_32
end
// __block_35
_d_index = 33;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_count = 0;
_t_status = 0;
_d_do_read_sector = 0;
_d_do_addr_sector = 0;
// --
_d_sd_mosi = 1;
_d_sd_csn = 1;
_d_sd_clk = 0;
_d_count = 0;
_d_index = 1;
end
1: begin
// __while__block_36
if (_q_count<100000) begin
// __block_37
// __block_39
_d_count = _q_count+1;
// __block_40
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_38
_d_count = 0;
_d_index = 3;
end
3: begin
// __while__block_41
if (_q_count<40960) begin
// __block_42
// __block_44
if ((_q_count&255)==255) begin
// __block_45
// __block_47
_d_sd_clk = ~_q_sd_clk;
// __block_48
end else begin
// __block_46
end
// __block_49
_d_count = _q_count+1;
// __block_50
_d_index = 3;
end else begin
_d_index = 4;
end
end
4: begin
// __block_43
_d_sd_csn = 0;
_d_store_addr1 = 0;
_d_i_send_cmd = _c_cmd0;
_d_index = 5;
_d_caller = 0;
end
5: begin
// __sub_send (send)
// var inits
_d___sub_send_v_send_count = 0;
// --
_d___sub_send_v_send_shift = _q_i_send_cmd;
_d_index = 6;
end
8: begin
// __block_51
_d_i_read_len = 8;
_d_i_read_wait = 1;
_d_i_read_rate = 255;
_d_index = 14;
_d_caller = 1;
end
6: begin
// __while__block_1 (send)
if (_q___sub_send_v_send_count<24576) begin
// __block_2 (send)
// __block_4 (send)
if ((_q___sub_send_v_send_count&255)==255) begin
// __block_5 (send)
// __block_7 (send)
_d_sd_clk = ~_q_sd_clk;
if (!_d_sd_clk) begin
// __block_8 (send)
// __block_10 (send)
_d_sd_mosi = _q___sub_send_v_send_shift[47+:1];
_d___sub_send_v_send_shift = {_q___sub_send_v_send_shift[0+:47],1'b0};
// __block_11 (send)
end else begin
// __block_9 (send)
end
// __block_12 (send)
// __block_13 (send)
end else begin
// __block_6 (send)
end
// __block_14 (send)
_d___sub_send_v_send_count = _q___sub_send_v_send_count+1;
// __block_15 (send)
_d_index = 6;
end else begin
_d_index = 7;
end
end
14: begin
// __sub_read (read)
// var inits
_d___sub_read_v_read_count = 0;
_d___sub_read_v_read_n = 0;
// --
_d_o_read_answer = 40'hffffffffff;
_d_index = 15;
end
17: begin
// __block_52
_t_status = _q_o_read_answer;
_d_i_send_cmd = _c_cmd8;
_d_index = 5;
_d_caller = 2;
end
7: begin
// __block_3 (send)
_d_sd_mosi = 1;
case (_q_caller) 
4'd0: begin
  _d_index = 6'd8;
end
4'd2: begin
  _d_index = 6'd9;
end
4'd4: begin
  _d_index = 6'd10;
end
4'd5: begin
  _d_index = 6'd11;
end
4'd7: begin
  _d_index = 6'd12;
end
4'd10: begin
  _d_index = 6'd13;
end
default: begin _d_index = 6'd33; end
endcase
end
15: begin
// __while__block_16 (read)
if ((_q_i_read_wait&&_q_o_read_answer[_q_i_read_len-1+:1])||((!_q_i_read_wait)&&_q___sub_read_v_read_n<_q_i_read_len)) begin
// __block_17 (read)
// __block_19 (read)
if ((_q___sub_read_v_read_count&_q_i_read_rate)==_q_i_read_rate) begin
// __block_20 (read)
// __block_22 (read)
_d_sd_clk = ~_q_sd_clk;
if (!_d_sd_clk) begin
// __block_23 (read)
// __block_25 (read)
_d___sub_read_v_read_n = _q___sub_read_v_read_n+1;
_d_o_read_answer = {_q_o_read_answer[0+:39],in_sd_miso};
// __block_26 (read)
end else begin
// __block_24 (read)
end
// __block_27 (read)
// __block_28 (read)
end else begin
// __block_21 (read)
end
// __block_29 (read)
_d___sub_read_v_read_count = _q___sub_read_v_read_count+1;
// __block_30 (read)
_d_index = 15;
end else begin
_d_index = 16;
end
end
9: begin
// __block_53
_d_i_read_len = 40;
_d_i_read_wait = 1;
_d_i_read_rate = 255;
_d_index = 14;
_d_caller = 3;
end
16: begin
// __block_18 (read)
case (_q_caller) 
4'd1: begin
  _d_index = 6'd17;
end
4'd3: begin
  _d_index = 6'd18;
end
4'd6: begin
  _d_index = 6'd19;
end
4'd8: begin
  _d_index = 6'd20;
end
4'd9: begin
  _d_index = 6'd21;
end
4'd11: begin
  _d_index = 6'd22;
end
4'd12: begin
  _d_index = 6'd23;
end
4'd13: begin
  _d_index = 6'd24;
end
4'd14: begin
  _d_index = 6'd25;
end
4'd15: begin
  _d_index = 6'd26;
end
default: begin _d_index = 6'd33; end
endcase
end
18: begin
// __block_54
_t_status = _q_o_read_answer;
_d_index = 27;
end
27: begin
// __while__block_55
if (1) begin
// __block_56
// __block_58
_d_i_send_cmd = _c_cmd55;
_d_index = 5;
_d_caller = 5;
end else begin
_d_index = 30;
end
end
11: begin
// __block_59
_d_i_read_len = 8;
_d_i_read_wait = 1;
_d_i_read_rate = 255;
_d_index = 14;
_d_caller = 6;
end
30: begin
// __block_57
_d_i_send_cmd = _c_cmd16;
_d_index = 5;
_d_caller = 4;
end
19: begin
// __block_60
_t_status = _q_o_read_answer;
_d_i_send_cmd = _c_acmd41;
_d_index = 5;
_d_caller = 7;
end
10: begin
// __block_70
_d_i_read_len = 8;
_d_i_read_wait = 1;
_d_i_read_rate = 255;
_d_index = 14;
_d_caller = 9;
end
12: begin
// __block_61
_d_i_read_len = 8;
_d_i_read_wait = 1;
_d_i_read_rate = 255;
_d_index = 14;
_d_caller = 8;
end
21: begin
// __block_71
_t_status = _q_o_read_answer;
_d_io_ready = 1;
_d_index = 28;
end
20: begin
// __block_62
_t_status = _q_o_read_answer;
if (_t_status[0+:8]==0) begin
// __block_63
// __block_65
_d_index = 30;
end else begin
// __block_64
_d_index = 27;
end
end
28: begin
// __while__block_72
if (1) begin
// __block_73
// __block_75
if (_d_do_read_sector) begin
// __block_76
// __block_78
_d_do_read_sector = 0;
_d_i_send_cmd = {_c_cmd17[40+:8],_d_do_addr_sector,_c_cmd17[0+:8]};
_d_index = 5;
_d_caller = 10;
end else begin
// __block_77
_d_index = 28;
end
end else begin
_d_index = 31;
end
end
13: begin
// __block_79
_d_i_read_len = 8;
_d_i_read_wait = 1;
_d_i_read_rate = 3;
_d_index = 14;
_d_caller = 11;
end
31: begin
// __block_74
_d_index = 33;
end
22: begin
// __block_80
_t_status = _q_o_read_answer;
if (_t_status[0+:8]==8'h00) begin
// __block_81
// __block_83
_d_i_read_len = 1;
_d_i_read_wait = 1;
_d_i_read_rate = 3;
_d_index = 14;
_d_caller = 12;
end else begin
// __block_82
// __block_94
_d_io_ready = 1;
// __block_95
_d_index = 28;
end
end
23: begin
// __block_84
_t_status = _q_o_read_answer;
_d_store_addr1 = 0;
_d_i_read_len = 8;
_d_i_read_wait = 0;
_d_i_read_rate = 3;
_d_index = 14;
_d_caller = 13;
end
24: begin
// __block_85
_d_store_wdata1 = _q_o_read_answer;
_d_index = 29;
end
29: begin
// __while__block_86
if (_q_store_addr1<511) begin
// __block_87
// __block_89
_d_i_read_len = 8;
_d_i_read_wait = 0;
_d_i_read_rate = 3;
_d_index = 14;
_d_caller = 15;
end else begin
_d_index = 32;
end
end
26: begin
// __block_90
_d_store_wdata1 = _q_o_read_answer;
_d_store_addr1 = _q_store_addr1+1;
// __block_91
_d_index = 29;
end
32: begin
// __block_88
_d_i_read_len = 16;
_d_i_read_wait = 1;
_d_i_read_rate = 3;
_d_index = 14;
_d_caller = 14;
end
25: begin
// __block_92
_t_status = _q_o_read_answer;
_d_io_ready = 1;
// __block_93
_d_index = 28;
end
33: begin // end of sdcard
end
default: begin 
_d_index = 33;
 end
endcase
end
endmodule


module M_sdram_controller_autoprecharge_r16_w16 #(
parameter SD_ADDR_WIDTH=1,parameter SD_ADDR_SIGNED=0,parameter SD_ADDR_INIT=0,
parameter SD_RW_WIDTH=1,parameter SD_RW_SIGNED=0,parameter SD_RW_INIT=0,
parameter SD_DATA_IN_WIDTH=1,parameter SD_DATA_IN_SIGNED=0,parameter SD_DATA_IN_INIT=0,
parameter SD_IN_VALID_WIDTH=1,parameter SD_IN_VALID_SIGNED=0,parameter SD_IN_VALID_INIT=0,
parameter SD_DATA_OUT_WIDTH=1,parameter SD_DATA_OUT_SIGNED=0,parameter SD_DATA_OUT_INIT=0,
parameter SD_DONE_WIDTH=1,parameter SD_DONE_SIGNED=0,parameter SD_DONE_INIT=0
) (
in_sd_addr,
in_sd_rw,
in_sd_data_in,
in_sd_in_valid,
out_sdram_cle,
out_sdram_cs,
out_sdram_cas,
out_sdram_ras,
out_sdram_we,
out_sdram_dqm,
out_sdram_ba,
out_sdram_a,
out_sd_data_out,
out_sd_done,
inout_sdram_dq,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [SD_ADDR_WIDTH-1:0] in_sd_addr;
input  [SD_RW_WIDTH-1:0] in_sd_rw;
input  [SD_DATA_IN_WIDTH-1:0] in_sd_data_in;
input  [SD_IN_VALID_WIDTH-1:0] in_sd_in_valid;
output  [0:0] out_sdram_cle;
output  [0:0] out_sdram_cs;
output  [0:0] out_sdram_cas;
output  [0:0] out_sdram_ras;
output  [0:0] out_sdram_we;
output  [1:0] out_sdram_dqm;
output  [1:0] out_sdram_ba;
output  [12:0] out_sdram_a;
output  [SD_DATA_OUT_WIDTH-1:0] out_sd_data_out;
output  [SD_DONE_WIDTH-1:0] out_sd_done;
inout  [15:0] inout_sdram_dq;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire[1:0] _w_off_sdram_ba_pin;
wire _w_off_sdram_we_pin;
wire _w_off_sdram_ras_pin;
wire _w_off_sdram_cas_pin;
wire[12:0] _w_off_sdram_a_pin;
wire _w_off_sdram_cs_pin;
wire _w_off_sdram_cle_pin;
wire[15:0] _w_ioset_io_read;
wire  [3:0] _c_CMD_NOP;
assign _c_CMD_NOP = 4'b0111;
wire  [3:0] _c_CMD_ACTIVE;
assign _c_CMD_ACTIVE = 4'b0011;
wire  [3:0] _c_CMD_READ;
assign _c_CMD_READ = 4'b0101;
wire  [3:0] _c_CMD_WRITE;
assign _c_CMD_WRITE = 4'b0100;
wire  [3:0] _c_CMD_PRECHARGE;
assign _c_CMD_PRECHARGE = 4'b0010;
wire  [3:0] _c_CMD_REFRESH;
assign _c_CMD_REFRESH = 4'b0001;
wire  [3:0] _c_CMD_LOAD_MODE_REG;
assign _c_CMD_LOAD_MODE_REG = 4'b0000;
reg  [3:0] _t_cmd;

reg  [0:0] _d_reg_sdram_cle;
reg  [0:0] _q_reg_sdram_cle;
reg  [0:0] _d_reg_sdram_cs;
reg  [0:0] _q_reg_sdram_cs;
reg  [0:0] _d_reg_sdram_cas;
reg  [0:0] _q_reg_sdram_cas;
reg  [0:0] _d_reg_sdram_ras;
reg  [0:0] _q_reg_sdram_ras;
reg  [0:0] _d_reg_sdram_we;
reg  [0:0] _q_reg_sdram_we;
reg  [1:0] _d_reg_sdram_ba;
reg  [1:0] _q_reg_sdram_ba;
reg  [12:0] _d_reg_sdram_a;
reg  [12:0] _q_reg_sdram_a;
reg  [15:0] _d_reg_dq_o;
reg  [15:0] _q_reg_dq_o;
reg  [0:0] _d_reg_dq_en;
reg  [0:0] _q_reg_dq_en;
reg  [0:0] _d_work_todo;
reg  [0:0] _q_work_todo;
reg  [12:0] _d_row;
reg  [12:0] _q_row;
reg  [1:0] _d_bank;
reg  [1:0] _q_bank;
reg  [9:0] _d_col;
reg  [9:0] _q_col;
reg  [15:0] _d_data;
reg  [15:0] _q_data;
reg  [0:0] _d_do_rw;
reg  [0:0] _q_do_rw;
reg  [9:0] _d_refresh_count;
reg  [9:0] _q_refresh_count;
reg  [15:0] _d___sub_wait_v_wait_count;
reg  [15:0] _q___sub_wait_v_wait_count;
reg  [15:0] _d_i_wait_incount;
reg  [15:0] _q_i_wait_incount;
reg  [1:0] _d_sdram_dqm,_q_sdram_dqm;
reg  [SD_DATA_OUT_WIDTH-1:0] _d_sd_data_out,_q_sd_data_out;
reg  [SD_DONE_WIDTH-1:0] _d_sd_done,_q_sd_done;
reg  [4:0] _d_index,_q_index;
reg  [2:0] _d_caller,_q_caller;
assign out_sdram_cle = _w_off_sdram_cle_pin;
assign out_sdram_cs = _w_off_sdram_cs_pin;
assign out_sdram_cas = _w_off_sdram_cas_pin;
assign out_sdram_ras = _w_off_sdram_ras_pin;
assign out_sdram_we = _w_off_sdram_we_pin;
assign out_sdram_dqm = _d_sdram_dqm;
assign out_sdram_ba = _w_off_sdram_ba_pin;
assign out_sdram_a = _w_off_sdram_a_pin;
assign out_sd_data_out = _q_sd_data_out;
assign out_sd_done = _q_sd_done;
assign out_done = (_q_index == 25);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_reg_dq_o <= 0;
_q_reg_dq_en <= 0;
_q_work_todo <= 0;
_q_row <= 0;
_q_bank <= 0;
_q_col <= 0;
_q_data <= 0;
_q_do_rw <= 0;
_q_refresh_count <= 750;
_q_i_wait_incount <= 0;
_q_sd_data_out <= SD_DATA_OUT_INIT;
_q_sd_done <= SD_DONE_INIT;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_reg_sdram_cle <= _d_reg_sdram_cle;
_q_reg_sdram_cs <= _d_reg_sdram_cs;
_q_reg_sdram_cas <= _d_reg_sdram_cas;
_q_reg_sdram_ras <= _d_reg_sdram_ras;
_q_reg_sdram_we <= _d_reg_sdram_we;
_q_reg_sdram_ba <= _d_reg_sdram_ba;
_q_reg_sdram_a <= _d_reg_sdram_a;
_q_reg_dq_o <= _d_reg_dq_o;
_q_reg_dq_en <= _d_reg_dq_en;
_q_work_todo <= _d_work_todo;
_q_row <= _d_row;
_q_bank <= _d_bank;
_q_col <= _d_col;
_q_data <= _d_data;
_q_do_rw <= _d_do_rw;
_q_refresh_count <= _d_refresh_count;
_q___sub_wait_v_wait_count <= _d___sub_wait_v_wait_count;
_q_i_wait_incount <= _d_i_wait_incount;
_q_sdram_dqm <= _d_sdram_dqm;
_q_sd_data_out <= _d_sd_data_out;
_q_sd_done <= _d_sd_done;
_q_index <= _d_index;
_q_caller <= _d_caller;
  end
end


out2_ff_ulx3s _off_sdram_ba (
.clock(clock),
.pin(_w_off_sdram_ba_pin),
.d(_q_reg_sdram_ba)
);

out1_ff_ulx3s _off_sdram_we (
.clock(clock),
.pin(_w_off_sdram_we_pin),
.d(_q_reg_sdram_we)
);

out1_ff_ulx3s _off_sdram_ras (
.clock(clock),
.pin(_w_off_sdram_ras_pin),
.d(_q_reg_sdram_ras)
);

out1_ff_ulx3s _off_sdram_cas (
.clock(clock),
.pin(_w_off_sdram_cas_pin),
.d(_q_reg_sdram_cas)
);

out13_ff_ulx3s _off_sdram_a (
.clock(clock),
.pin(_w_off_sdram_a_pin),
.d(_q_reg_sdram_a)
);

out1_ff_ulx3s _off_sdram_cs (
.clock(clock),
.pin(_w_off_sdram_cs_pin),
.d(_q_reg_sdram_cs)
);

out1_ff_ulx3s _off_sdram_cle (
.clock(clock),
.pin(_w_off_sdram_cle_pin),
.d(_q_reg_sdram_cle)
);

inout16_ff_ulx3s _ioset (
.clock(clock),
.io_pin(inout_sdram_dq),
.io_write(_q_reg_dq_o),
.io_read(_w_ioset_io_read),
.io_write_enable(_q_reg_dq_en)
);



always @* begin
_d_reg_sdram_cle = _q_reg_sdram_cle;
_d_reg_sdram_cs = _q_reg_sdram_cs;
_d_reg_sdram_cas = _q_reg_sdram_cas;
_d_reg_sdram_ras = _q_reg_sdram_ras;
_d_reg_sdram_we = _q_reg_sdram_we;
_d_reg_sdram_ba = _q_reg_sdram_ba;
_d_reg_sdram_a = _q_reg_sdram_a;
_d_reg_dq_o = _q_reg_dq_o;
_d_reg_dq_en = _q_reg_dq_en;
_d_work_todo = _q_work_todo;
_d_row = _q_row;
_d_bank = _q_bank;
_d_col = _q_col;
_d_data = _q_data;
_d_do_rw = _q_do_rw;
_d_refresh_count = _q_refresh_count;
_d___sub_wait_v_wait_count = _q___sub_wait_v_wait_count;
_d_i_wait_incount = _q_i_wait_incount;
_d_sdram_dqm = _q_sdram_dqm;
_d_sd_data_out = _q_sd_data_out;
_d_sd_done = _q_sd_done;
_d_index = _q_index;
_d_caller = _q_caller;
_t_cmd = 0;
// _always_pre
_d_sd_done = 0;
_t_cmd = _c_CMD_NOP;
// __block_6_command
// __block_7
_d_reg_sdram_cs = _t_cmd[3+:1];
_d_reg_sdram_ras = _t_cmd[2+:1];
_d_reg_sdram_cas = _t_cmd[1+:1];
_d_reg_sdram_we = _t_cmd[0+:1];
// __block_8
// __block_9
if (in_sd_in_valid) begin
// __block_10
// __block_12
_d_bank = in_sd_addr[24+:2];
_d_row = in_sd_addr[10+:13];
_d_col = in_sd_addr[1+:9];
_d_data = in_sd_data_in;
_d_do_rw = in_sd_rw;
_d_work_todo = 1;
// __block_13
end else begin
// __block_11
end
// __block_14
_d_index = 25;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_reg_dq_o = 0;
_d_reg_dq_en = 0;
_t_cmd = 7;
_d_work_todo = 0;
_d_row = 0;
_d_bank = 0;
_d_col = 0;
_d_data = 0;
_d_do_rw = 0;
_d_refresh_count = 750;
// --
_d_reg_sdram_cle = 0;
_d_i_wait_incount = 10100;
_d_index = 1;
_d_caller = 0;
end
1: begin
// __sub_wait (wait)
// var inits
// --
_d___sub_wait_v_wait_count = _q_i_wait_incount;
_d_index = 2;
end
4: begin
// __block_15
_d_reg_sdram_cle = 1;
_d_reg_sdram_a = 0;
_d_reg_sdram_ba = 0;
_d_reg_dq_en = 0;
_d_i_wait_incount = 10100;
_d_index = 1;
_d_caller = 1;
end
2: begin
// __while__block_1 (wait)
if (_q___sub_wait_v_wait_count>0) begin
// __block_2 (wait)
// __block_4 (wait)
_d___sub_wait_v_wait_count = _q___sub_wait_v_wait_count-1;
// __block_5 (wait)
_d_index = 2;
end else begin
_d_index = 3;
end
end
5: begin
// __block_16
_t_cmd = _c_CMD_PRECHARGE;
// __block_17_command
// __block_18
_d_reg_sdram_cs = _t_cmd[3+:1];
_d_reg_sdram_ras = _t_cmd[2+:1];
_d_reg_sdram_cas = _t_cmd[1+:1];
_d_reg_sdram_we = _t_cmd[0+:1];
// __block_19
// __block_20
_d_reg_sdram_a = {2'b0,1'b1,10'b0};
_d_i_wait_incount = 0;
_d_index = 1;
_d_caller = 2;
end
3: begin
// __block_3 (wait)
case (_q_caller) 
3'd0: begin
  _d_index = 5'd4;
end
3'd1: begin
  _d_index = 5'd5;
end
3'd2: begin
  _d_index = 5'd6;
end
3'd3: begin
  _d_index = 5'd7;
end
3'd4: begin
  _d_index = 5'd8;
end
3'd5: begin
  _d_index = 5'd9;
end
3'd6: begin
  _d_index = 5'd10;
end
default: begin _d_index = 5'd25; end
endcase
end
6: begin
// __block_21
_t_cmd = _c_CMD_REFRESH;
// __block_22_command
// __block_23
_d_reg_sdram_cs = _t_cmd[3+:1];
_d_reg_sdram_ras = _t_cmd[2+:1];
_d_reg_sdram_cas = _t_cmd[1+:1];
_d_reg_sdram_we = _t_cmd[0+:1];
// __block_24
// __block_25
_d_i_wait_incount = 4;
_d_index = 1;
_d_caller = 3;
end
7: begin
// __block_26
_t_cmd = _c_CMD_REFRESH;
// __block_27_command
// __block_28
_d_reg_sdram_cs = _t_cmd[3+:1];
_d_reg_sdram_ras = _t_cmd[2+:1];
_d_reg_sdram_cas = _t_cmd[1+:1];
_d_reg_sdram_we = _t_cmd[0+:1];
// __block_29
// __block_30
_d_i_wait_incount = 4;
_d_index = 1;
_d_caller = 4;
end
8: begin
// __block_31
_t_cmd = _c_CMD_LOAD_MODE_REG;
// __block_32_command
// __block_33
_d_reg_sdram_cs = _t_cmd[3+:1];
_d_reg_sdram_ras = _t_cmd[2+:1];
_d_reg_sdram_cas = _t_cmd[1+:1];
_d_reg_sdram_we = _t_cmd[0+:1];
// __block_34
// __block_35
_d_reg_sdram_ba = 0;
_d_reg_sdram_a = {3'b000,1'b1,2'b00,3'b011,1'b0,3'b000};
_d_i_wait_incount = 0;
_d_index = 1;
_d_caller = 5;
end
9: begin
// __block_36
_d_reg_sdram_ba = 0;
_d_reg_sdram_a = 0;
_t_cmd = _c_CMD_NOP;
// __block_37_command
// __block_38
_d_reg_sdram_cs = _t_cmd[3+:1];
_d_reg_sdram_ras = _t_cmd[2+:1];
_d_reg_sdram_cas = _t_cmd[1+:1];
_d_reg_sdram_we = _t_cmd[0+:1];
// __block_39
// __block_40
_d_refresh_count = 750;
_d_index = 11;
end
11: begin
// __while__block_41
if (1) begin
// __block_42
// __block_44
if (_q_refresh_count==0) begin
// __block_45
// __block_47
_t_cmd = _c_CMD_REFRESH;
// __block_48_command
// __block_49
_d_reg_sdram_cs = _t_cmd[3+:1];
_d_reg_sdram_ras = _t_cmd[2+:1];
_d_reg_sdram_cas = _t_cmd[1+:1];
_d_reg_sdram_we = _t_cmd[0+:1];
// __block_50
// __block_51
_d_i_wait_incount = 4;
_d_index = 1;
_d_caller = 6;
end else begin
// __block_46
// __block_54
_d_refresh_count = _q_refresh_count-1;
if (_d_work_todo) begin
// __block_55
// __block_57
_d_work_todo = 0;
_d_reg_sdram_ba = _d_bank;
_d_reg_sdram_a = _d_row;
_t_cmd = _c_CMD_ACTIVE;
// __block_58_command
// __block_59
_d_reg_sdram_cs = _t_cmd[3+:1];
_d_reg_sdram_ras = _t_cmd[2+:1];
_d_reg_sdram_cas = _t_cmd[1+:1];
_d_reg_sdram_we = _t_cmd[0+:1];
// __block_60
// __block_61
_d_index = 13;
end else begin
// __block_56
_d_index = 11;
end
end
end else begin
_d_index = 12;
end
end
10: begin
// __block_52
_d_refresh_count = 750;
// __block_53
_d_index = 11;
end
13: begin
// __block_62
_d_index = 14;
end
12: begin
// __block_43
_d_index = 25;
end
14: begin
// __block_63
if (_d_do_rw) begin
// __block_64
// __block_66
_t_cmd = _c_CMD_WRITE;
// __block_67_command
// __block_68
_d_reg_sdram_cs = _t_cmd[3+:1];
_d_reg_sdram_ras = _t_cmd[2+:1];
_d_reg_sdram_cas = _t_cmd[1+:1];
_d_reg_sdram_we = _t_cmd[0+:1];
// __block_69
// __block_70
_d_reg_dq_en = 1;
_d_reg_sdram_a = {2'b0,1'b1,_d_col};
_d_reg_dq_o = _d_data;
_d_sd_done = 1;
_d_index = 18;
end else begin
// __block_65
// __block_73
_t_cmd = _c_CMD_READ;
// __block_74_command
// __block_75
_d_reg_sdram_cs = _t_cmd[3+:1];
_d_reg_sdram_ras = _t_cmd[2+:1];
_d_reg_sdram_cas = _t_cmd[1+:1];
_d_reg_sdram_we = _t_cmd[0+:1];
// __block_76
// __block_77
_d_reg_dq_en = 0;
_d_reg_sdram_a = {2'b0,1'b1,_d_col};
_d_index = 19;
end
end
18: begin
// __block_71
// __block_72
_d_index = 15;
end
19: begin
// __block_78
_d_index = 20;
end
15: begin
// __block_86
_d_index = 16;
end
20: begin
// __block_79
_d_index = 21;
end
16: begin
// __block_87
_d_index = 17;
end
21: begin
// __block_80
_d_index = 22;
end
17: begin
// __block_88
// __block_89
_d_index = 11;
end
22: begin
// __block_81
_d_index = 23;
end
23: begin
// __block_82
_d_index = 24;
end
24: begin
// __block_83
_d_sd_data_out = _w_ioset_io_read;
_d_sd_done = 1;
// __block_84
_d_index = 15;
end
25: begin // end of sdram_controller_autoprecharge_r16_w16
end
default: begin 
_d_index = 25;
 end
endcase
end
endmodule


module M_sdram_half_speed_access #(
parameter SDH_ADDR_WIDTH=1,parameter SDH_ADDR_SIGNED=0,parameter SDH_ADDR_INIT=0,
parameter SDH_RW_WIDTH=1,parameter SDH_RW_SIGNED=0,parameter SDH_RW_INIT=0,
parameter SDH_DATA_IN_WIDTH=1,parameter SDH_DATA_IN_SIGNED=0,parameter SDH_DATA_IN_INIT=0,
parameter SDH_IN_VALID_WIDTH=1,parameter SDH_IN_VALID_SIGNED=0,parameter SDH_IN_VALID_INIT=0,
parameter SDH_DATA_OUT_WIDTH=1,parameter SDH_DATA_OUT_SIGNED=0,parameter SDH_DATA_OUT_INIT=0,
parameter SDH_DONE_WIDTH=1,parameter SDH_DONE_SIGNED=0,parameter SDH_DONE_INIT=0,
parameter SD_ADDR_WIDTH=1,parameter SD_ADDR_SIGNED=0,parameter SD_ADDR_INIT=0,
parameter SD_RW_WIDTH=1,parameter SD_RW_SIGNED=0,parameter SD_RW_INIT=0,
parameter SD_DATA_IN_WIDTH=1,parameter SD_DATA_IN_SIGNED=0,parameter SD_DATA_IN_INIT=0,
parameter SD_IN_VALID_WIDTH=1,parameter SD_IN_VALID_SIGNED=0,parameter SD_IN_VALID_INIT=0,
parameter SD_DATA_OUT_WIDTH=1,parameter SD_DATA_OUT_SIGNED=0,parameter SD_DATA_OUT_INIT=0,
parameter SD_DONE_WIDTH=1,parameter SD_DONE_SIGNED=0,parameter SD_DONE_INIT=0
) (
in_sdh_addr,
in_sdh_rw,
in_sdh_data_in,
in_sdh_in_valid,
in_sd_data_out,
in_sd_done,
out_sdh_data_out,
out_sdh_done,
out_sd_addr,
out_sd_rw,
out_sd_data_in,
out_sd_in_valid,
reset,
out_clock,
clock
);
input  [SDH_ADDR_WIDTH-1:0] in_sdh_addr;
input  [SDH_RW_WIDTH-1:0] in_sdh_rw;
input  [SDH_DATA_IN_WIDTH-1:0] in_sdh_data_in;
input  [SDH_IN_VALID_WIDTH-1:0] in_sdh_in_valid;
input  [SD_DATA_OUT_WIDTH-1:0] in_sd_data_out;
input  [SD_DONE_WIDTH-1:0] in_sd_done;
output  [SDH_DATA_OUT_WIDTH-1:0] out_sdh_data_out;
output  [SDH_DONE_WIDTH-1:0] out_sdh_done;
output  [SD_ADDR_WIDTH-1:0] out_sd_addr;
output  [SD_RW_WIDTH-1:0] out_sd_rw;
output  [SD_DATA_IN_WIDTH-1:0] out_sd_data_in;
output  [SD_IN_VALID_WIDTH-1:0] out_sd_in_valid;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [0:0] _d_half_clock;
reg  [0:0] _q_half_clock;
reg  [1:0] _d_done;
reg  [1:0] _q_done;
reg  [SDH_DATA_OUT_WIDTH-1:0] _d_sdh_data_out,_q_sdh_data_out;
reg  [SDH_DONE_WIDTH-1:0] _d_sdh_done,_q_sdh_done;
reg  [SD_ADDR_WIDTH-1:0] _d_sd_addr,_q_sd_addr;
reg  [SD_RW_WIDTH-1:0] _d_sd_rw,_q_sd_rw;
reg  [SD_DATA_IN_WIDTH-1:0] _d_sd_data_in,_q_sd_data_in;
reg  [SD_IN_VALID_WIDTH-1:0] _d_sd_in_valid,_q_sd_in_valid;
assign out_sdh_data_out = _q_sdh_data_out;
assign out_sdh_done = _q_sdh_done;
assign out_sd_addr = _q_sd_addr;
assign out_sd_rw = _q_sd_rw;
assign out_sd_data_in = _q_sd_data_in;
assign out_sd_in_valid = _q_sd_in_valid;

always @(posedge clock) begin
  if (reset) begin
_q_half_clock <= 0;
_q_done <= 0;
_q_sdh_data_out <= SDH_DATA_OUT_INIT;
_q_sdh_done <= SDH_DONE_INIT;
_q_sd_addr <= SD_ADDR_INIT;
_q_sd_rw <= SD_RW_INIT;
_q_sd_data_in <= SD_DATA_IN_INIT;
_q_sd_in_valid <= SD_IN_VALID_INIT;
  end else begin
_q_half_clock <= _d_half_clock;
_q_done <= _d_done;
_q_sdh_data_out <= _d_sdh_data_out;
_q_sdh_done <= _d_sdh_done;
_q_sd_addr <= _d_sd_addr;
_q_sd_rw <= _d_sd_rw;
_q_sd_data_in <= _d_sd_data_in;
_q_sd_in_valid <= _d_sd_in_valid;
  end
end




always @* begin
_d_half_clock = _q_half_clock;
_d_done = _q_done;
_d_sdh_data_out = _q_sdh_data_out;
_d_sdh_done = _q_sdh_done;
_d_sd_addr = _q_sd_addr;
_d_sd_rw = _q_sd_rw;
_d_sd_data_in = _q_sd_data_in;
_d_sd_in_valid = _q_sd_in_valid;
// _always_pre
_d_sdh_done = 0;
_d_sd_in_valid = 0;
if (_q_half_clock) begin
// __block_1
// __block_3
if (in_sdh_in_valid==1) begin
// __block_4
// __block_6
_d_sd_addr = in_sdh_addr;
_d_sd_rw = in_sdh_rw;
_d_sd_data_in = in_sdh_data_in;
_d_sd_in_valid = 1;
// __block_7
end else begin
// __block_5
end
// __block_8
// __block_9
end else begin
// __block_2
end
// __block_10
_d_done = _q_done>>1;
if (in_sd_done==1) begin
// __block_11
// __block_13
_d_sdh_data_out = _d_sd_rw?_q_sdh_data_out:in_sd_data_out;
_d_done = 2'b11;
// __block_14
end else begin
// __block_12
end
// __block_15
_d_sdh_done = _d_done[0+:1];
_d_half_clock = ~_q_half_clock;
end
endmodule


module M_sdram_byte_readcache #(
parameter SDB_ADDR_WIDTH=1,parameter SDB_ADDR_SIGNED=0,parameter SDB_ADDR_INIT=0,
parameter SDB_RW_WIDTH=1,parameter SDB_RW_SIGNED=0,parameter SDB_RW_INIT=0,
parameter SDB_DATA_IN_WIDTH=1,parameter SDB_DATA_IN_SIGNED=0,parameter SDB_DATA_IN_INIT=0,
parameter SDB_IN_VALID_WIDTH=1,parameter SDB_IN_VALID_SIGNED=0,parameter SDB_IN_VALID_INIT=0,
parameter SDB_DATA_OUT_WIDTH=1,parameter SDB_DATA_OUT_SIGNED=0,parameter SDB_DATA_OUT_INIT=0,
parameter SDB_DONE_WIDTH=1,parameter SDB_DONE_SIGNED=0,parameter SDB_DONE_INIT=0,
parameter SDR_ADDR_WIDTH=1,parameter SDR_ADDR_SIGNED=0,parameter SDR_ADDR_INIT=0,
parameter SDR_RW_WIDTH=1,parameter SDR_RW_SIGNED=0,parameter SDR_RW_INIT=0,
parameter SDR_DATA_IN_WIDTH=1,parameter SDR_DATA_IN_SIGNED=0,parameter SDR_DATA_IN_INIT=0,
parameter SDR_IN_VALID_WIDTH=1,parameter SDR_IN_VALID_SIGNED=0,parameter SDR_IN_VALID_INIT=0,
parameter SDR_DATA_OUT_WIDTH=1,parameter SDR_DATA_OUT_SIGNED=0,parameter SDR_DATA_OUT_INIT=0,
parameter SDR_DONE_WIDTH=1,parameter SDR_DONE_SIGNED=0,parameter SDR_DONE_INIT=0
) (
in_sdb_addr,
in_sdb_rw,
in_sdb_data_in,
in_sdb_in_valid,
in_sdr_data_out,
in_sdr_done,
out_sdb_data_out,
out_sdb_done,
out_sdr_addr,
out_sdr_rw,
out_sdr_data_in,
out_sdr_in_valid,
reset,
out_clock,
clock
);
input  [SDB_ADDR_WIDTH-1:0] in_sdb_addr;
input  [SDB_RW_WIDTH-1:0] in_sdb_rw;
input  [SDB_DATA_IN_WIDTH-1:0] in_sdb_data_in;
input  [SDB_IN_VALID_WIDTH-1:0] in_sdb_in_valid;
input  [SDR_DATA_OUT_WIDTH-1:0] in_sdr_data_out;
input  [SDR_DONE_WIDTH-1:0] in_sdr_done;
output  [SDB_DATA_OUT_WIDTH-1:0] out_sdb_data_out;
output  [SDB_DONE_WIDTH-1:0] out_sdb_done;
output  [SDR_ADDR_WIDTH-1:0] out_sdr_addr;
output  [SDR_RW_WIDTH-1:0] out_sdr_rw;
output  [SDR_DATA_IN_WIDTH-1:0] out_sdr_data_in;
output  [SDR_IN_VALID_WIDTH-1:0] out_sdr_in_valid;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [SDR_DATA_OUT_WIDTH-1:0] _d_cached;
reg  [SDR_DATA_OUT_WIDTH-1:0] _q_cached;
reg  [25:0] _d_cached_addr;
reg  [25:0] _q_cached_addr;
reg  [SDB_DATA_OUT_WIDTH-1:0] _d_sdb_data_out,_q_sdb_data_out;
reg  [SDB_DONE_WIDTH-1:0] _d_sdb_done,_q_sdb_done;
reg  [SDR_ADDR_WIDTH-1:0] _d_sdr_addr,_q_sdr_addr;
reg  [SDR_RW_WIDTH-1:0] _d_sdr_rw,_q_sdr_rw;
reg  [SDR_DATA_IN_WIDTH-1:0] _d_sdr_data_in,_q_sdr_data_in;
reg  [SDR_IN_VALID_WIDTH-1:0] _d_sdr_in_valid,_q_sdr_in_valid;
assign out_sdb_data_out = _q_sdb_data_out;
assign out_sdb_done = _q_sdb_done;
assign out_sdr_addr = _q_sdr_addr;
assign out_sdr_rw = _q_sdr_rw;
assign out_sdr_data_in = _q_sdr_data_in;
assign out_sdr_in_valid = _q_sdr_in_valid;

always @(posedge clock) begin
  if (reset) begin
_q_cached_addr <= 26'h3FFFFFF;
_q_sdb_data_out <= SDB_DATA_OUT_INIT;
_q_sdb_done <= SDB_DONE_INIT;
_q_sdr_addr <= SDR_ADDR_INIT;
_q_sdr_rw <= SDR_RW_INIT;
_q_sdr_data_in <= SDR_DATA_IN_INIT;
_q_sdr_in_valid <= SDR_IN_VALID_INIT;
  end else begin
_q_cached <= _d_cached;
_q_cached_addr <= _d_cached_addr;
_q_sdb_data_out <= _d_sdb_data_out;
_q_sdb_done <= _d_sdb_done;
_q_sdr_addr <= _d_sdr_addr;
_q_sdr_rw <= _d_sdr_rw;
_q_sdr_data_in <= _d_sdr_data_in;
_q_sdr_in_valid <= _d_sdr_in_valid;
  end
end




always @* begin
_d_cached = _q_cached;
_d_cached_addr = _q_cached_addr;
_d_sdb_data_out = _q_sdb_data_out;
_d_sdb_done = _q_sdb_done;
_d_sdr_addr = _q_sdr_addr;
_d_sdr_rw = _q_sdr_rw;
_d_sdr_data_in = _q_sdr_data_in;
_d_sdr_in_valid = _q_sdr_in_valid;
// _always_pre
if (in_sdb_in_valid) begin
// __block_1
// __block_3
if (in_sdb_rw==0) begin
// __block_4
// __block_6
if (in_sdb_addr[4+:22]==_q_cached_addr[4+:22]) begin
// __block_7
// __block_9
_d_sdb_data_out = _q_cached>>{in_sdb_addr[0+:4],3'b000};
_d_sdr_in_valid = 0;
_d_sdb_done = 1;
// __block_10
end else begin
// __block_8
// __block_11
_d_cached_addr = in_sdb_addr;
_d_sdr_rw = 0;
_d_sdr_addr = {_d_cached_addr[4+:22],4'b0000};
_d_sdr_in_valid = 1;
_d_sdb_done = 0;
// __block_12
end
// __block_13
// __block_14
end else begin
// __block_5
// __block_15
_d_sdr_rw = 1;
_d_sdr_addr = in_sdb_addr;
_d_sdr_data_in = in_sdb_data_in;
_d_sdr_in_valid = 1;
_d_sdb_done = 0;
if (in_sdb_addr[4+:22]==_q_cached_addr[4+:22]) begin
// __block_16
// __block_18
_d_cached_addr = 26'h3FFFFFF;
// __block_19
end else begin
// __block_17
end
// __block_20
// __block_21
end
// __block_22
// __block_23
end else begin
// __block_2
// __block_24
if (in_sdr_done) begin
// __block_25
// __block_27
if (_q_sdr_rw==0) begin
// __block_28
// __block_30
_d_cached = in_sdr_data_out;
_d_sdb_data_out = _d_cached>>{_q_cached_addr[0+:4],3'b000};
// __block_31
end else begin
// __block_29
end
// __block_32
_d_sdr_in_valid = 0;
_d_sdb_done = 1;
// __block_33
end else begin
// __block_26
// __block_34
_d_sdr_in_valid = 0;
_d_sdb_done = 0;
// __block_35
end
// __block_36
// __block_37
end
// __block_38
end
endmodule


module M_clean_reset (
out_out,
reset,
out_clock,
clock
);
output  [0:0] out_out;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [0:0] _w_done;
wire  [7:0] _w_counter_next;

reg  [7:0] _d_counter;
reg  [7:0] _q_counter;
reg  [0:0] _d_out,_q_out;
assign out_out = _q_out;

always @(posedge clock) begin
  if (reset) begin
_q_counter <= 1;
  end else begin
_q_counter <= _d_counter;
_q_out <= _d_out;
  end
end



assign _w_counter_next = _w_done?0:_q_counter+1;
assign _w_done = (_q_counter==0);

always @* begin
_d_counter = _q_counter;
_d_out = _q_out;
// _always_pre
_d_counter = _w_counter_next;
_d_out = ~_w_done;
end
endmodule


module M_multiplex_display (
in_pix_x,
in_pix_y,
in_pix_active,
in_pix_vblank,
in_background_r,
in_background_g,
in_background_b,
in_tilemap_r,
in_tilemap_g,
in_tilemap_b,
in_tilemap_display,
in_lower_sprites_r,
in_lower_sprites_g,
in_lower_sprites_b,
in_lower_sprites_display,
in_bitmap_r,
in_bitmap_g,
in_bitmap_b,
in_bitmap_display,
in_upper_sprites_r,
in_upper_sprites_g,
in_upper_sprites_b,
in_upper_sprites_display,
in_character_map_r,
in_character_map_g,
in_character_map_b,
in_character_map_display,
in_terminal_r,
in_terminal_g,
in_terminal_b,
in_terminal_display,
out_pix_red,
out_pix_green,
out_pix_blue,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [9:0] in_pix_x;
input  [9:0] in_pix_y;
input  [0:0] in_pix_active;
input  [0:0] in_pix_vblank;
input  [1:0] in_background_r;
input  [1:0] in_background_g;
input  [1:0] in_background_b;
input  [1:0] in_tilemap_r;
input  [1:0] in_tilemap_g;
input  [1:0] in_tilemap_b;
input  [0:0] in_tilemap_display;
input  [1:0] in_lower_sprites_r;
input  [1:0] in_lower_sprites_g;
input  [1:0] in_lower_sprites_b;
input  [0:0] in_lower_sprites_display;
input  [1:0] in_bitmap_r;
input  [1:0] in_bitmap_g;
input  [1:0] in_bitmap_b;
input  [0:0] in_bitmap_display;
input  [1:0] in_upper_sprites_r;
input  [1:0] in_upper_sprites_g;
input  [1:0] in_upper_sprites_b;
input  [0:0] in_upper_sprites_display;
input  [1:0] in_character_map_r;
input  [1:0] in_character_map_g;
input  [1:0] in_character_map_b;
input  [0:0] in_character_map_display;
input  [1:0] in_terminal_r;
input  [1:0] in_terminal_g;
input  [1:0] in_terminal_b;
input  [0:0] in_terminal_display;
output  [7:0] out_pix_red;
output  [7:0] out_pix_green;
output  [7:0] out_pix_blue;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [7:0] _d_pix_red,_q_pix_red;
reg  [7:0] _d_pix_green,_q_pix_green;
reg  [7:0] _d_pix_blue,_q_pix_blue;
reg  [1:0] _d_index,_q_index;
assign out_pix_red = _d_pix_red;
assign out_pix_green = _d_pix_green;
assign out_pix_blue = _d_pix_blue;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_pix_red <= _d_pix_red;
_q_pix_green <= _d_pix_green;
_q_pix_blue <= _d_pix_blue;
_q_index <= _d_index;
  end
end




always @* begin
_d_pix_red = _q_pix_red;
_d_pix_green = _q_pix_green;
_d_pix_blue = _q_pix_blue;
_d_index = _q_index;
// _always_pre
_d_pix_red = 0;
_d_pix_green = 0;
_d_pix_blue = 0;
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_pix_active) begin
// __block_5
// __block_7
_d_pix_red = (in_terminal_display)?{{4{in_terminal_r}}}:(in_character_map_display)?{{4{in_character_map_r}}}:(in_upper_sprites_display)?{{4{in_upper_sprites_r}}}:(in_bitmap_display)?{{4{in_bitmap_r}}}:(in_lower_sprites_display)?{{4{in_lower_sprites_r}}}:(in_tilemap_display)?{{4{in_tilemap_r}}}:{{4{in_background_r}}};
_d_pix_green = (in_terminal_display)?{{4{in_terminal_g}}}:(in_character_map_display)?{{4{in_character_map_g}}}:(in_upper_sprites_display)?{{4{in_upper_sprites_g}}}:(in_bitmap_display)?{{4{in_bitmap_g}}}:(in_lower_sprites_display)?{{4{in_lower_sprites_g}}}:(in_tilemap_display)?{{4{in_tilemap_g}}}:{{4{in_background_g}}};
_d_pix_blue = (in_terminal_display)?{{4{in_terminal_b}}}:(in_character_map_display)?{{4{in_character_map_b}}}:(in_upper_sprites_display)?{{4{in_upper_sprites_b}}}:(in_bitmap_display)?{{4{in_bitmap_b}}}:(in_lower_sprites_display)?{{4{in_lower_sprites_b}}}:(in_tilemap_display)?{{4{in_tilemap_b}}}:{{4{in_background_b}}};
// __block_8
end else begin
// __block_6
end
// __block_9
// __block_10
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of multiplex_display
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_pulse1hz (
in_resetCounter,
out_counter1hz,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [0:0] in_resetCounter;
output  [15:0] out_counter1hz;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [25:0] _d_counter50mhz;
reg  [25:0] _q_counter50mhz;
reg  [15:0] _d_counter1hz,_q_counter1hz;
reg  [1:0] _d_index,_q_index;
assign out_counter1hz = _q_counter1hz;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_counter50mhz <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_counter50mhz <= _d_counter50mhz;
_q_counter1hz <= _d_counter1hz;
_q_index <= _d_index;
  end
end




always @* begin
_d_counter50mhz = _q_counter50mhz;
_d_counter1hz = _q_counter1hz;
_d_index = _q_index;
// _always_pre
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_counter50mhz = 0;
// --
_d_counter1hz = 0;
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_resetCounter==1) begin
// __block_5
// __block_7
_d_counter1hz = 0;
_d_counter50mhz = 0;
// __block_8
end else begin
// __block_6
// __block_9
_d_counter1hz = (_q_counter50mhz==50000000)?_q_counter1hz+1:_q_counter1hz;
_d_counter50mhz = (_q_counter50mhz==50000000)?0:_q_counter50mhz+1;
// __block_10
end
// __block_11
// __block_12
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of pulse1hz
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_pulse1khz (
in_resetCount,
in_resetCounter,
out_counter1khz,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [15:0] in_resetCount;
input  [0:0] in_resetCounter;
output  [15:0] out_counter1khz;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [15:0] _d_counter50mhz;
reg  [15:0] _q_counter50mhz;
reg  [15:0] _d_counter1khz,_q_counter1khz;
reg  [1:0] _d_index,_q_index;
assign out_counter1khz = _q_counter1khz;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_counter50mhz <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_counter50mhz <= _d_counter50mhz;
_q_counter1khz <= _d_counter1khz;
_q_index <= _d_index;
  end
end




always @* begin
_d_counter50mhz = _q_counter50mhz;
_d_counter1khz = _q_counter1khz;
_d_index = _q_index;
// _always_pre
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_counter50mhz = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_resetCounter==1) begin
// __block_5
// __block_7
_d_counter1khz = in_resetCount;
_d_counter50mhz = 0;
// __block_8
end else begin
// __block_6
// __block_9
_d_counter1khz = (_q_counter1khz==0)?0:(_q_counter50mhz==50000)?_q_counter1khz-1:_q_counter1khz;
_d_counter50mhz = (_q_counter50mhz==50000)?0:_q_counter50mhz+1;
// __block_10
end
// __block_11
// __block_12
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of pulse1khz
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_random (
in_resetRandom,
out_g_noise_out,
out_u_noise_out,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [0:0] in_resetRandom;
output  [15:0] out_g_noise_out;
output  [15:0] out_u_noise_out;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
reg  [15:0] _t_temp_u_noise3;
reg  [15:0] _t_temp_u_noise2;
reg  [15:0] _t_temp_u_noise1;
reg  [15:0] _t_temp_u_noise0;

reg  [15:0] _d_rand_out;
reg  [15:0] _q_rand_out;
reg  [15:0] _d_rand_ff;
reg  [15:0] _q_rand_ff;
reg  [17:0] _d_rand_en_ff;
reg  [17:0] _q_rand_en_ff;
reg  [15:0] _d_temp_g_noise_nxt;
reg  [15:0] _q_temp_g_noise_nxt;
reg  [15:0] _d_g_noise_out,_q_g_noise_out;
reg  [15:0] _d_u_noise_out,_q_u_noise_out;
reg  [1:0] _d_index,_q_index;
assign out_g_noise_out = _q_g_noise_out;
assign out_u_noise_out = _q_u_noise_out;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_rand_out <= 0;
_q_rand_ff <= 24'b011000110111011010011101;
_q_rand_en_ff <= 24'b001100010011011101100101;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_rand_out <= _d_rand_out;
_q_rand_ff <= _d_rand_ff;
_q_rand_en_ff <= _d_rand_en_ff;
_q_temp_g_noise_nxt <= _d_temp_g_noise_nxt;
_q_g_noise_out <= _d_g_noise_out;
_q_u_noise_out <= _d_u_noise_out;
_q_index <= _d_index;
  end
end




always @* begin
_d_rand_out = _q_rand_out;
_d_rand_ff = _q_rand_ff;
_d_rand_en_ff = _q_rand_en_ff;
_d_temp_g_noise_nxt = _q_temp_g_noise_nxt;
_d_g_noise_out = _q_g_noise_out;
_d_u_noise_out = _q_u_noise_out;
_d_index = _q_index;
_t_temp_u_noise3 = 0;
_t_temp_u_noise2 = 0;
_t_temp_u_noise1 = 0;
_t_temp_u_noise0 = 0;
// _always_pre
_d_g_noise_out = (_q_rand_en_ff[17+:1])?_q_temp_g_noise_nxt:(_q_rand_en_ff[10+:1])?_q_rand_out:_q_g_noise_out;
_d_u_noise_out = (_q_rand_en_ff[17+:1])?_q_rand_out:_q_u_noise_out;
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_rand_out = 0;
_d_rand_ff = 24'b011000110111011010011101;
_d_rand_en_ff = 24'b001100010011011101100101;
_t_temp_u_noise3 = 0;
_t_temp_u_noise2 = 0;
_t_temp_u_noise1 = 0;
_t_temp_u_noise0 = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_resetRandom) begin
// __block_5
// __block_7
_d_rand_en_ff = 24'b001100010011011101100101;
_d_rand_ff = 24'b011000110111011010011101;
_d_rand_out = 0;
_t_temp_u_noise3 = 0;
_t_temp_u_noise2 = 0;
_t_temp_u_noise1 = 0;
_t_temp_u_noise0 = 0;
_d_g_noise_out = 0;
_d_u_noise_out = 0;
// __block_8
end else begin
// __block_6
// __block_9
_d_rand_en_ff = {(_q_rand_en_ff[7+:1]^_q_rand_en_ff[0+:1]),_q_rand_en_ff[1+:17]};
_d_rand_ff = {(_q_rand_ff[5+:1]^_q_rand_ff[3+:1]^_q_rand_ff[2+:1]^_q_rand_ff[0+:1]),_q_rand_ff[1+:15]};
_d_rand_out = _d_rand_ff;
_t_temp_u_noise3 = {_d_rand_out[15+:1],_d_rand_out[15+:1],_d_rand_out[2+:13]};
_t_temp_u_noise2 = _t_temp_u_noise3;
_t_temp_u_noise1 = _t_temp_u_noise2;
_t_temp_u_noise0 = _t_temp_u_noise1;
_d_temp_g_noise_nxt = (_d_rand_en_ff[9+:1])?$signed(_t_temp_u_noise3)+$signed(_t_temp_u_noise2)+$signed(_t_temp_u_noise1)+$signed(_t_temp_u_noise0)+$signed(_d_g_noise_out):$signed(_t_temp_u_noise3)+$signed(_t_temp_u_noise2)+$signed(_t_temp_u_noise1)+$signed(_t_temp_u_noise0);
// __block_10
end
// __block_11
// __block_12
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of random
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_terminal_mem_characterGenerator8x8(
input                  [10:0] in_characterGenerator8x8_addr,
output reg  [7:0] out_characterGenerator8x8_rdata,
input                                   clock
);
reg  [7:0] buffer[2047:0];
always @(posedge clock) begin
   out_characterGenerator8x8_rdata <= buffer[in_characterGenerator8x8_addr];
end
initial begin
 buffer[0] = 8'h00;
 buffer[1] = 8'h00;
 buffer[2] = 8'h00;
 buffer[3] = 8'h00;
 buffer[4] = 8'h00;
 buffer[5] = 8'h00;
 buffer[6] = 8'h00;
 buffer[7] = 8'h00;
 buffer[8] = 8'h7e;
 buffer[9] = 8'h81;
 buffer[10] = 8'ha5;
 buffer[11] = 8'h81;
 buffer[12] = 8'hbd;
 buffer[13] = 8'h99;
 buffer[14] = 8'h81;
 buffer[15] = 8'h7e;
 buffer[16] = 8'h7e;
 buffer[17] = 8'hff;
 buffer[18] = 8'hdb;
 buffer[19] = 8'hff;
 buffer[20] = 8'hc3;
 buffer[21] = 8'he7;
 buffer[22] = 8'hff;
 buffer[23] = 8'h7e;
 buffer[24] = 8'h6c;
 buffer[25] = 8'hfe;
 buffer[26] = 8'hfe;
 buffer[27] = 8'hfe;
 buffer[28] = 8'h7c;
 buffer[29] = 8'h38;
 buffer[30] = 8'h10;
 buffer[31] = 8'h00;
 buffer[32] = 8'h10;
 buffer[33] = 8'h38;
 buffer[34] = 8'h7c;
 buffer[35] = 8'hfe;
 buffer[36] = 8'h7c;
 buffer[37] = 8'h38;
 buffer[38] = 8'h10;
 buffer[39] = 8'h00;
 buffer[40] = 8'h38;
 buffer[41] = 8'h7c;
 buffer[42] = 8'h38;
 buffer[43] = 8'hfe;
 buffer[44] = 8'hfe;
 buffer[45] = 8'h7c;
 buffer[46] = 8'h38;
 buffer[47] = 8'h7c;
 buffer[48] = 8'h10;
 buffer[49] = 8'h10;
 buffer[50] = 8'h38;
 buffer[51] = 8'h7c;
 buffer[52] = 8'hfe;
 buffer[53] = 8'h7c;
 buffer[54] = 8'h38;
 buffer[55] = 8'h7c;
 buffer[56] = 8'h00;
 buffer[57] = 8'h00;
 buffer[58] = 8'h18;
 buffer[59] = 8'h3c;
 buffer[60] = 8'h3c;
 buffer[61] = 8'h18;
 buffer[62] = 8'h00;
 buffer[63] = 8'h00;
 buffer[64] = 8'hff;
 buffer[65] = 8'hff;
 buffer[66] = 8'he7;
 buffer[67] = 8'hc3;
 buffer[68] = 8'hc3;
 buffer[69] = 8'he7;
 buffer[70] = 8'hff;
 buffer[71] = 8'hff;
 buffer[72] = 8'h00;
 buffer[73] = 8'h3c;
 buffer[74] = 8'h66;
 buffer[75] = 8'h42;
 buffer[76] = 8'h42;
 buffer[77] = 8'h66;
 buffer[78] = 8'h3c;
 buffer[79] = 8'h00;
 buffer[80] = 8'hff;
 buffer[81] = 8'hc3;
 buffer[82] = 8'h99;
 buffer[83] = 8'hbd;
 buffer[84] = 8'hbd;
 buffer[85] = 8'h99;
 buffer[86] = 8'hc3;
 buffer[87] = 8'hff;
 buffer[88] = 8'h0f;
 buffer[89] = 8'h07;
 buffer[90] = 8'h0f;
 buffer[91] = 8'h7d;
 buffer[92] = 8'hcc;
 buffer[93] = 8'hcc;
 buffer[94] = 8'hcc;
 buffer[95] = 8'h78;
 buffer[96] = 8'h3c;
 buffer[97] = 8'h66;
 buffer[98] = 8'h66;
 buffer[99] = 8'h66;
 buffer[100] = 8'h3c;
 buffer[101] = 8'h18;
 buffer[102] = 8'h7e;
 buffer[103] = 8'h18;
 buffer[104] = 8'h3f;
 buffer[105] = 8'h33;
 buffer[106] = 8'h3f;
 buffer[107] = 8'h30;
 buffer[108] = 8'h30;
 buffer[109] = 8'h70;
 buffer[110] = 8'hf0;
 buffer[111] = 8'he0;
 buffer[112] = 8'h7f;
 buffer[113] = 8'h63;
 buffer[114] = 8'h7f;
 buffer[115] = 8'h63;
 buffer[116] = 8'h63;
 buffer[117] = 8'h67;
 buffer[118] = 8'he6;
 buffer[119] = 8'hc0;
 buffer[120] = 8'h99;
 buffer[121] = 8'h5a;
 buffer[122] = 8'h3c;
 buffer[123] = 8'he7;
 buffer[124] = 8'he7;
 buffer[125] = 8'h3c;
 buffer[126] = 8'h5a;
 buffer[127] = 8'h99;
 buffer[128] = 8'h80;
 buffer[129] = 8'he0;
 buffer[130] = 8'hf8;
 buffer[131] = 8'hfe;
 buffer[132] = 8'hf8;
 buffer[133] = 8'he0;
 buffer[134] = 8'h80;
 buffer[135] = 8'h00;
 buffer[136] = 8'h02;
 buffer[137] = 8'h0e;
 buffer[138] = 8'h3e;
 buffer[139] = 8'hfe;
 buffer[140] = 8'h3e;
 buffer[141] = 8'h0e;
 buffer[142] = 8'h02;
 buffer[143] = 8'h00;
 buffer[144] = 8'h18;
 buffer[145] = 8'h3c;
 buffer[146] = 8'h7e;
 buffer[147] = 8'h18;
 buffer[148] = 8'h18;
 buffer[149] = 8'h7e;
 buffer[150] = 8'h3c;
 buffer[151] = 8'h18;
 buffer[152] = 8'h66;
 buffer[153] = 8'h66;
 buffer[154] = 8'h66;
 buffer[155] = 8'h66;
 buffer[156] = 8'h66;
 buffer[157] = 8'h00;
 buffer[158] = 8'h66;
 buffer[159] = 8'h00;
 buffer[160] = 8'h7f;
 buffer[161] = 8'hdb;
 buffer[162] = 8'hdb;
 buffer[163] = 8'h7b;
 buffer[164] = 8'h1b;
 buffer[165] = 8'h1b;
 buffer[166] = 8'h1b;
 buffer[167] = 8'h00;
 buffer[168] = 8'h3e;
 buffer[169] = 8'h63;
 buffer[170] = 8'h38;
 buffer[171] = 8'h6c;
 buffer[172] = 8'h6c;
 buffer[173] = 8'h38;
 buffer[174] = 8'hcc;
 buffer[175] = 8'h78;
 buffer[176] = 8'h00;
 buffer[177] = 8'h00;
 buffer[178] = 8'h00;
 buffer[179] = 8'h00;
 buffer[180] = 8'h7e;
 buffer[181] = 8'h7e;
 buffer[182] = 8'h7e;
 buffer[183] = 8'h00;
 buffer[184] = 8'h18;
 buffer[185] = 8'h3c;
 buffer[186] = 8'h7e;
 buffer[187] = 8'h18;
 buffer[188] = 8'h7e;
 buffer[189] = 8'h3c;
 buffer[190] = 8'h18;
 buffer[191] = 8'hff;
 buffer[192] = 8'h18;
 buffer[193] = 8'h3c;
 buffer[194] = 8'h7e;
 buffer[195] = 8'h18;
 buffer[196] = 8'h18;
 buffer[197] = 8'h18;
 buffer[198] = 8'h18;
 buffer[199] = 8'h00;
 buffer[200] = 8'h18;
 buffer[201] = 8'h18;
 buffer[202] = 8'h18;
 buffer[203] = 8'h18;
 buffer[204] = 8'h7e;
 buffer[205] = 8'h3c;
 buffer[206] = 8'h18;
 buffer[207] = 8'h00;
 buffer[208] = 8'h00;
 buffer[209] = 8'h18;
 buffer[210] = 8'h0c;
 buffer[211] = 8'hfe;
 buffer[212] = 8'h0c;
 buffer[213] = 8'h18;
 buffer[214] = 8'h00;
 buffer[215] = 8'h00;
 buffer[216] = 8'h00;
 buffer[217] = 8'h30;
 buffer[218] = 8'h60;
 buffer[219] = 8'hfe;
 buffer[220] = 8'h60;
 buffer[221] = 8'h30;
 buffer[222] = 8'h00;
 buffer[223] = 8'h00;
 buffer[224] = 8'h00;
 buffer[225] = 8'h00;
 buffer[226] = 8'hc0;
 buffer[227] = 8'hc0;
 buffer[228] = 8'hc0;
 buffer[229] = 8'hfe;
 buffer[230] = 8'h00;
 buffer[231] = 8'h00;
 buffer[232] = 8'h00;
 buffer[233] = 8'h24;
 buffer[234] = 8'h66;
 buffer[235] = 8'hff;
 buffer[236] = 8'h66;
 buffer[237] = 8'h24;
 buffer[238] = 8'h00;
 buffer[239] = 8'h00;
 buffer[240] = 8'h00;
 buffer[241] = 8'h18;
 buffer[242] = 8'h3c;
 buffer[243] = 8'h7e;
 buffer[244] = 8'hff;
 buffer[245] = 8'hff;
 buffer[246] = 8'h00;
 buffer[247] = 8'h00;
 buffer[248] = 8'h00;
 buffer[249] = 8'hff;
 buffer[250] = 8'hff;
 buffer[251] = 8'h7e;
 buffer[252] = 8'h3c;
 buffer[253] = 8'h18;
 buffer[254] = 8'h00;
 buffer[255] = 8'h00;
 buffer[256] = 8'h00;
 buffer[257] = 8'h00;
 buffer[258] = 8'h00;
 buffer[259] = 8'h00;
 buffer[260] = 8'h00;
 buffer[261] = 8'h00;
 buffer[262] = 8'h00;
 buffer[263] = 8'h00;
 buffer[264] = 8'h30;
 buffer[265] = 8'h78;
 buffer[266] = 8'h78;
 buffer[267] = 8'h30;
 buffer[268] = 8'h30;
 buffer[269] = 8'h00;
 buffer[270] = 8'h30;
 buffer[271] = 8'h00;
 buffer[272] = 8'h6c;
 buffer[273] = 8'h6c;
 buffer[274] = 8'h6c;
 buffer[275] = 8'h00;
 buffer[276] = 8'h00;
 buffer[277] = 8'h00;
 buffer[278] = 8'h00;
 buffer[279] = 8'h00;
 buffer[280] = 8'h6c;
 buffer[281] = 8'h6c;
 buffer[282] = 8'hfe;
 buffer[283] = 8'h6c;
 buffer[284] = 8'hfe;
 buffer[285] = 8'h6c;
 buffer[286] = 8'h6c;
 buffer[287] = 8'h00;
 buffer[288] = 8'h30;
 buffer[289] = 8'h7c;
 buffer[290] = 8'hc0;
 buffer[291] = 8'h78;
 buffer[292] = 8'h0c;
 buffer[293] = 8'hf8;
 buffer[294] = 8'h30;
 buffer[295] = 8'h00;
 buffer[296] = 8'h00;
 buffer[297] = 8'hc6;
 buffer[298] = 8'hcc;
 buffer[299] = 8'h18;
 buffer[300] = 8'h30;
 buffer[301] = 8'h66;
 buffer[302] = 8'hc6;
 buffer[303] = 8'h00;
 buffer[304] = 8'h38;
 buffer[305] = 8'h6c;
 buffer[306] = 8'h38;
 buffer[307] = 8'h76;
 buffer[308] = 8'hdc;
 buffer[309] = 8'hcc;
 buffer[310] = 8'h76;
 buffer[311] = 8'h00;
 buffer[312] = 8'h60;
 buffer[313] = 8'h60;
 buffer[314] = 8'hc0;
 buffer[315] = 8'h00;
 buffer[316] = 8'h00;
 buffer[317] = 8'h00;
 buffer[318] = 8'h00;
 buffer[319] = 8'h00;
 buffer[320] = 8'h18;
 buffer[321] = 8'h30;
 buffer[322] = 8'h60;
 buffer[323] = 8'h60;
 buffer[324] = 8'h60;
 buffer[325] = 8'h30;
 buffer[326] = 8'h18;
 buffer[327] = 8'h00;
 buffer[328] = 8'h60;
 buffer[329] = 8'h30;
 buffer[330] = 8'h18;
 buffer[331] = 8'h18;
 buffer[332] = 8'h18;
 buffer[333] = 8'h30;
 buffer[334] = 8'h60;
 buffer[335] = 8'h00;
 buffer[336] = 8'h00;
 buffer[337] = 8'h66;
 buffer[338] = 8'h3c;
 buffer[339] = 8'hff;
 buffer[340] = 8'h3c;
 buffer[341] = 8'h66;
 buffer[342] = 8'h00;
 buffer[343] = 8'h00;
 buffer[344] = 8'h00;
 buffer[345] = 8'h30;
 buffer[346] = 8'h30;
 buffer[347] = 8'hfc;
 buffer[348] = 8'h30;
 buffer[349] = 8'h30;
 buffer[350] = 8'h00;
 buffer[351] = 8'h00;
 buffer[352] = 8'h00;
 buffer[353] = 8'h00;
 buffer[354] = 8'h00;
 buffer[355] = 8'h00;
 buffer[356] = 8'h00;
 buffer[357] = 8'h30;
 buffer[358] = 8'h30;
 buffer[359] = 8'h60;
 buffer[360] = 8'h00;
 buffer[361] = 8'h00;
 buffer[362] = 8'h00;
 buffer[363] = 8'hfc;
 buffer[364] = 8'h00;
 buffer[365] = 8'h00;
 buffer[366] = 8'h00;
 buffer[367] = 8'h00;
 buffer[368] = 8'h00;
 buffer[369] = 8'h00;
 buffer[370] = 8'h00;
 buffer[371] = 8'h00;
 buffer[372] = 8'h00;
 buffer[373] = 8'h30;
 buffer[374] = 8'h30;
 buffer[375] = 8'h00;
 buffer[376] = 8'h06;
 buffer[377] = 8'h0c;
 buffer[378] = 8'h18;
 buffer[379] = 8'h30;
 buffer[380] = 8'h60;
 buffer[381] = 8'hc0;
 buffer[382] = 8'h80;
 buffer[383] = 8'h00;
 buffer[384] = 8'h7c;
 buffer[385] = 8'hc6;
 buffer[386] = 8'hce;
 buffer[387] = 8'hde;
 buffer[388] = 8'hf6;
 buffer[389] = 8'he6;
 buffer[390] = 8'h7c;
 buffer[391] = 8'h00;
 buffer[392] = 8'h30;
 buffer[393] = 8'h70;
 buffer[394] = 8'h30;
 buffer[395] = 8'h30;
 buffer[396] = 8'h30;
 buffer[397] = 8'h30;
 buffer[398] = 8'hfc;
 buffer[399] = 8'h00;
 buffer[400] = 8'h78;
 buffer[401] = 8'hcc;
 buffer[402] = 8'h0c;
 buffer[403] = 8'h38;
 buffer[404] = 8'h60;
 buffer[405] = 8'hcc;
 buffer[406] = 8'hfc;
 buffer[407] = 8'h00;
 buffer[408] = 8'h78;
 buffer[409] = 8'hcc;
 buffer[410] = 8'h0c;
 buffer[411] = 8'h38;
 buffer[412] = 8'h0c;
 buffer[413] = 8'hcc;
 buffer[414] = 8'h78;
 buffer[415] = 8'h00;
 buffer[416] = 8'h1c;
 buffer[417] = 8'h3c;
 buffer[418] = 8'h6c;
 buffer[419] = 8'hcc;
 buffer[420] = 8'hfe;
 buffer[421] = 8'h0c;
 buffer[422] = 8'h1e;
 buffer[423] = 8'h00;
 buffer[424] = 8'hfc;
 buffer[425] = 8'hc0;
 buffer[426] = 8'hf8;
 buffer[427] = 8'h0c;
 buffer[428] = 8'h0c;
 buffer[429] = 8'hcc;
 buffer[430] = 8'h78;
 buffer[431] = 8'h00;
 buffer[432] = 8'h38;
 buffer[433] = 8'h60;
 buffer[434] = 8'hc0;
 buffer[435] = 8'hf8;
 buffer[436] = 8'hcc;
 buffer[437] = 8'hcc;
 buffer[438] = 8'h78;
 buffer[439] = 8'h00;
 buffer[440] = 8'hfc;
 buffer[441] = 8'hcc;
 buffer[442] = 8'h0c;
 buffer[443] = 8'h18;
 buffer[444] = 8'h30;
 buffer[445] = 8'h30;
 buffer[446] = 8'h30;
 buffer[447] = 8'h00;
 buffer[448] = 8'h78;
 buffer[449] = 8'hcc;
 buffer[450] = 8'hcc;
 buffer[451] = 8'h78;
 buffer[452] = 8'hcc;
 buffer[453] = 8'hcc;
 buffer[454] = 8'h78;
 buffer[455] = 8'h00;
 buffer[456] = 8'h78;
 buffer[457] = 8'hcc;
 buffer[458] = 8'hcc;
 buffer[459] = 8'h7c;
 buffer[460] = 8'h0c;
 buffer[461] = 8'h18;
 buffer[462] = 8'h70;
 buffer[463] = 8'h00;
 buffer[464] = 8'h00;
 buffer[465] = 8'h30;
 buffer[466] = 8'h30;
 buffer[467] = 8'h00;
 buffer[468] = 8'h00;
 buffer[469] = 8'h30;
 buffer[470] = 8'h30;
 buffer[471] = 8'h00;
 buffer[472] = 8'h00;
 buffer[473] = 8'h30;
 buffer[474] = 8'h30;
 buffer[475] = 8'h00;
 buffer[476] = 8'h00;
 buffer[477] = 8'h30;
 buffer[478] = 8'h30;
 buffer[479] = 8'h60;
 buffer[480] = 8'h18;
 buffer[481] = 8'h30;
 buffer[482] = 8'h60;
 buffer[483] = 8'hc0;
 buffer[484] = 8'h60;
 buffer[485] = 8'h30;
 buffer[486] = 8'h18;
 buffer[487] = 8'h00;
 buffer[488] = 8'h00;
 buffer[489] = 8'h00;
 buffer[490] = 8'hfc;
 buffer[491] = 8'h00;
 buffer[492] = 8'h00;
 buffer[493] = 8'hfc;
 buffer[494] = 8'h00;
 buffer[495] = 8'h00;
 buffer[496] = 8'h60;
 buffer[497] = 8'h30;
 buffer[498] = 8'h18;
 buffer[499] = 8'h0c;
 buffer[500] = 8'h18;
 buffer[501] = 8'h30;
 buffer[502] = 8'h60;
 buffer[503] = 8'h00;
 buffer[504] = 8'h78;
 buffer[505] = 8'hcc;
 buffer[506] = 8'h0c;
 buffer[507] = 8'h18;
 buffer[508] = 8'h30;
 buffer[509] = 8'h00;
 buffer[510] = 8'h30;
 buffer[511] = 8'h00;
 buffer[512] = 8'h7c;
 buffer[513] = 8'hc6;
 buffer[514] = 8'hde;
 buffer[515] = 8'hde;
 buffer[516] = 8'hde;
 buffer[517] = 8'hc0;
 buffer[518] = 8'h78;
 buffer[519] = 8'h00;
 buffer[520] = 8'h30;
 buffer[521] = 8'h78;
 buffer[522] = 8'hcc;
 buffer[523] = 8'hcc;
 buffer[524] = 8'hfc;
 buffer[525] = 8'hcc;
 buffer[526] = 8'hcc;
 buffer[527] = 8'h00;
 buffer[528] = 8'hfc;
 buffer[529] = 8'h66;
 buffer[530] = 8'h66;
 buffer[531] = 8'h7c;
 buffer[532] = 8'h66;
 buffer[533] = 8'h66;
 buffer[534] = 8'hfc;
 buffer[535] = 8'h00;
 buffer[536] = 8'h3c;
 buffer[537] = 8'h66;
 buffer[538] = 8'hc0;
 buffer[539] = 8'hc0;
 buffer[540] = 8'hc0;
 buffer[541] = 8'h66;
 buffer[542] = 8'h3c;
 buffer[543] = 8'h00;
 buffer[544] = 8'hf8;
 buffer[545] = 8'h6c;
 buffer[546] = 8'h66;
 buffer[547] = 8'h66;
 buffer[548] = 8'h66;
 buffer[549] = 8'h6c;
 buffer[550] = 8'hf8;
 buffer[551] = 8'h00;
 buffer[552] = 8'hfe;
 buffer[553] = 8'h62;
 buffer[554] = 8'h68;
 buffer[555] = 8'h78;
 buffer[556] = 8'h68;
 buffer[557] = 8'h62;
 buffer[558] = 8'hfe;
 buffer[559] = 8'h00;
 buffer[560] = 8'hfe;
 buffer[561] = 8'h62;
 buffer[562] = 8'h68;
 buffer[563] = 8'h78;
 buffer[564] = 8'h68;
 buffer[565] = 8'h60;
 buffer[566] = 8'hf0;
 buffer[567] = 8'h00;
 buffer[568] = 8'h3c;
 buffer[569] = 8'h66;
 buffer[570] = 8'hc0;
 buffer[571] = 8'hc0;
 buffer[572] = 8'hce;
 buffer[573] = 8'h66;
 buffer[574] = 8'h3e;
 buffer[575] = 8'h00;
 buffer[576] = 8'hcc;
 buffer[577] = 8'hcc;
 buffer[578] = 8'hcc;
 buffer[579] = 8'hfc;
 buffer[580] = 8'hcc;
 buffer[581] = 8'hcc;
 buffer[582] = 8'hcc;
 buffer[583] = 8'h00;
 buffer[584] = 8'h78;
 buffer[585] = 8'h30;
 buffer[586] = 8'h30;
 buffer[587] = 8'h30;
 buffer[588] = 8'h30;
 buffer[589] = 8'h30;
 buffer[590] = 8'h78;
 buffer[591] = 8'h00;
 buffer[592] = 8'h1e;
 buffer[593] = 8'h0c;
 buffer[594] = 8'h0c;
 buffer[595] = 8'h0c;
 buffer[596] = 8'hcc;
 buffer[597] = 8'hcc;
 buffer[598] = 8'h78;
 buffer[599] = 8'h00;
 buffer[600] = 8'he6;
 buffer[601] = 8'h66;
 buffer[602] = 8'h6c;
 buffer[603] = 8'h78;
 buffer[604] = 8'h6c;
 buffer[605] = 8'h66;
 buffer[606] = 8'he6;
 buffer[607] = 8'h00;
 buffer[608] = 8'hf0;
 buffer[609] = 8'h60;
 buffer[610] = 8'h60;
 buffer[611] = 8'h60;
 buffer[612] = 8'h62;
 buffer[613] = 8'h66;
 buffer[614] = 8'hfe;
 buffer[615] = 8'h00;
 buffer[616] = 8'hc6;
 buffer[617] = 8'hee;
 buffer[618] = 8'hfe;
 buffer[619] = 8'hfe;
 buffer[620] = 8'hd6;
 buffer[621] = 8'hc6;
 buffer[622] = 8'hc6;
 buffer[623] = 8'h00;
 buffer[624] = 8'hc6;
 buffer[625] = 8'he6;
 buffer[626] = 8'hf6;
 buffer[627] = 8'hde;
 buffer[628] = 8'hce;
 buffer[629] = 8'hc6;
 buffer[630] = 8'hc6;
 buffer[631] = 8'h00;
 buffer[632] = 8'h38;
 buffer[633] = 8'h6c;
 buffer[634] = 8'hc6;
 buffer[635] = 8'hc6;
 buffer[636] = 8'hc6;
 buffer[637] = 8'h6c;
 buffer[638] = 8'h38;
 buffer[639] = 8'h00;
 buffer[640] = 8'hfc;
 buffer[641] = 8'h66;
 buffer[642] = 8'h66;
 buffer[643] = 8'h7c;
 buffer[644] = 8'h60;
 buffer[645] = 8'h60;
 buffer[646] = 8'hf0;
 buffer[647] = 8'h00;
 buffer[648] = 8'h78;
 buffer[649] = 8'hcc;
 buffer[650] = 8'hcc;
 buffer[651] = 8'hcc;
 buffer[652] = 8'hdc;
 buffer[653] = 8'h78;
 buffer[654] = 8'h1c;
 buffer[655] = 8'h00;
 buffer[656] = 8'hfc;
 buffer[657] = 8'h66;
 buffer[658] = 8'h66;
 buffer[659] = 8'h7c;
 buffer[660] = 8'h6c;
 buffer[661] = 8'h66;
 buffer[662] = 8'he6;
 buffer[663] = 8'h00;
 buffer[664] = 8'h78;
 buffer[665] = 8'hcc;
 buffer[666] = 8'he0;
 buffer[667] = 8'h70;
 buffer[668] = 8'h1c;
 buffer[669] = 8'hcc;
 buffer[670] = 8'h78;
 buffer[671] = 8'h00;
 buffer[672] = 8'hfc;
 buffer[673] = 8'hb4;
 buffer[674] = 8'h30;
 buffer[675] = 8'h30;
 buffer[676] = 8'h30;
 buffer[677] = 8'h30;
 buffer[678] = 8'h78;
 buffer[679] = 8'h00;
 buffer[680] = 8'hcc;
 buffer[681] = 8'hcc;
 buffer[682] = 8'hcc;
 buffer[683] = 8'hcc;
 buffer[684] = 8'hcc;
 buffer[685] = 8'hcc;
 buffer[686] = 8'hfc;
 buffer[687] = 8'h00;
 buffer[688] = 8'hcc;
 buffer[689] = 8'hcc;
 buffer[690] = 8'hcc;
 buffer[691] = 8'hcc;
 buffer[692] = 8'hcc;
 buffer[693] = 8'h78;
 buffer[694] = 8'h30;
 buffer[695] = 8'h00;
 buffer[696] = 8'hc6;
 buffer[697] = 8'hc6;
 buffer[698] = 8'hc6;
 buffer[699] = 8'hd6;
 buffer[700] = 8'hfe;
 buffer[701] = 8'hee;
 buffer[702] = 8'hc6;
 buffer[703] = 8'h00;
 buffer[704] = 8'hc6;
 buffer[705] = 8'hc6;
 buffer[706] = 8'h6c;
 buffer[707] = 8'h38;
 buffer[708] = 8'h38;
 buffer[709] = 8'h6c;
 buffer[710] = 8'hc6;
 buffer[711] = 8'h00;
 buffer[712] = 8'hcc;
 buffer[713] = 8'hcc;
 buffer[714] = 8'hcc;
 buffer[715] = 8'h78;
 buffer[716] = 8'h30;
 buffer[717] = 8'h30;
 buffer[718] = 8'h78;
 buffer[719] = 8'h00;
 buffer[720] = 8'hfe;
 buffer[721] = 8'hc6;
 buffer[722] = 8'h8c;
 buffer[723] = 8'h18;
 buffer[724] = 8'h32;
 buffer[725] = 8'h66;
 buffer[726] = 8'hfe;
 buffer[727] = 8'h00;
 buffer[728] = 8'h78;
 buffer[729] = 8'h60;
 buffer[730] = 8'h60;
 buffer[731] = 8'h60;
 buffer[732] = 8'h60;
 buffer[733] = 8'h60;
 buffer[734] = 8'h78;
 buffer[735] = 8'h00;
 buffer[736] = 8'hc0;
 buffer[737] = 8'h60;
 buffer[738] = 8'h30;
 buffer[739] = 8'h18;
 buffer[740] = 8'h0c;
 buffer[741] = 8'h06;
 buffer[742] = 8'h02;
 buffer[743] = 8'h00;
 buffer[744] = 8'h78;
 buffer[745] = 8'h18;
 buffer[746] = 8'h18;
 buffer[747] = 8'h18;
 buffer[748] = 8'h18;
 buffer[749] = 8'h18;
 buffer[750] = 8'h78;
 buffer[751] = 8'h00;
 buffer[752] = 8'h10;
 buffer[753] = 8'h38;
 buffer[754] = 8'h6c;
 buffer[755] = 8'hc6;
 buffer[756] = 8'h00;
 buffer[757] = 8'h00;
 buffer[758] = 8'h00;
 buffer[759] = 8'h00;
 buffer[760] = 8'h00;
 buffer[761] = 8'h00;
 buffer[762] = 8'h00;
 buffer[763] = 8'h00;
 buffer[764] = 8'h00;
 buffer[765] = 8'h00;
 buffer[766] = 8'h00;
 buffer[767] = 8'hff;
 buffer[768] = 8'h30;
 buffer[769] = 8'h30;
 buffer[770] = 8'h18;
 buffer[771] = 8'h00;
 buffer[772] = 8'h00;
 buffer[773] = 8'h00;
 buffer[774] = 8'h00;
 buffer[775] = 8'h00;
 buffer[776] = 8'h00;
 buffer[777] = 8'h00;
 buffer[778] = 8'h78;
 buffer[779] = 8'h0c;
 buffer[780] = 8'h7c;
 buffer[781] = 8'hcc;
 buffer[782] = 8'h76;
 buffer[783] = 8'h00;
 buffer[784] = 8'he0;
 buffer[785] = 8'h60;
 buffer[786] = 8'h60;
 buffer[787] = 8'h7c;
 buffer[788] = 8'h66;
 buffer[789] = 8'h66;
 buffer[790] = 8'hdc;
 buffer[791] = 8'h00;
 buffer[792] = 8'h00;
 buffer[793] = 8'h00;
 buffer[794] = 8'h78;
 buffer[795] = 8'hcc;
 buffer[796] = 8'hc0;
 buffer[797] = 8'hcc;
 buffer[798] = 8'h78;
 buffer[799] = 8'h00;
 buffer[800] = 8'h1c;
 buffer[801] = 8'h0c;
 buffer[802] = 8'h0c;
 buffer[803] = 8'h7c;
 buffer[804] = 8'hcc;
 buffer[805] = 8'hcc;
 buffer[806] = 8'h76;
 buffer[807] = 8'h00;
 buffer[808] = 8'h00;
 buffer[809] = 8'h00;
 buffer[810] = 8'h78;
 buffer[811] = 8'hcc;
 buffer[812] = 8'hfc;
 buffer[813] = 8'hc0;
 buffer[814] = 8'h78;
 buffer[815] = 8'h00;
 buffer[816] = 8'h38;
 buffer[817] = 8'h6c;
 buffer[818] = 8'h60;
 buffer[819] = 8'hf0;
 buffer[820] = 8'h60;
 buffer[821] = 8'h60;
 buffer[822] = 8'hf0;
 buffer[823] = 8'h00;
 buffer[824] = 8'h00;
 buffer[825] = 8'h00;
 buffer[826] = 8'h76;
 buffer[827] = 8'hcc;
 buffer[828] = 8'hcc;
 buffer[829] = 8'h7c;
 buffer[830] = 8'h0c;
 buffer[831] = 8'hf8;
 buffer[832] = 8'he0;
 buffer[833] = 8'h60;
 buffer[834] = 8'h6c;
 buffer[835] = 8'h76;
 buffer[836] = 8'h66;
 buffer[837] = 8'h66;
 buffer[838] = 8'he6;
 buffer[839] = 8'h00;
 buffer[840] = 8'h30;
 buffer[841] = 8'h00;
 buffer[842] = 8'h70;
 buffer[843] = 8'h30;
 buffer[844] = 8'h30;
 buffer[845] = 8'h30;
 buffer[846] = 8'h78;
 buffer[847] = 8'h00;
 buffer[848] = 8'h0c;
 buffer[849] = 8'h00;
 buffer[850] = 8'h0c;
 buffer[851] = 8'h0c;
 buffer[852] = 8'h0c;
 buffer[853] = 8'hcc;
 buffer[854] = 8'hcc;
 buffer[855] = 8'h78;
 buffer[856] = 8'he0;
 buffer[857] = 8'h60;
 buffer[858] = 8'h66;
 buffer[859] = 8'h6c;
 buffer[860] = 8'h78;
 buffer[861] = 8'h6c;
 buffer[862] = 8'he6;
 buffer[863] = 8'h00;
 buffer[864] = 8'h70;
 buffer[865] = 8'h30;
 buffer[866] = 8'h30;
 buffer[867] = 8'h30;
 buffer[868] = 8'h30;
 buffer[869] = 8'h30;
 buffer[870] = 8'h78;
 buffer[871] = 8'h00;
 buffer[872] = 8'h00;
 buffer[873] = 8'h00;
 buffer[874] = 8'hcc;
 buffer[875] = 8'hfe;
 buffer[876] = 8'hfe;
 buffer[877] = 8'hd6;
 buffer[878] = 8'hc6;
 buffer[879] = 8'h00;
 buffer[880] = 8'h00;
 buffer[881] = 8'h00;
 buffer[882] = 8'hf8;
 buffer[883] = 8'hcc;
 buffer[884] = 8'hcc;
 buffer[885] = 8'hcc;
 buffer[886] = 8'hcc;
 buffer[887] = 8'h00;
 buffer[888] = 8'h00;
 buffer[889] = 8'h00;
 buffer[890] = 8'h78;
 buffer[891] = 8'hcc;
 buffer[892] = 8'hcc;
 buffer[893] = 8'hcc;
 buffer[894] = 8'h78;
 buffer[895] = 8'h00;
 buffer[896] = 8'h00;
 buffer[897] = 8'h00;
 buffer[898] = 8'hdc;
 buffer[899] = 8'h66;
 buffer[900] = 8'h66;
 buffer[901] = 8'h7c;
 buffer[902] = 8'h60;
 buffer[903] = 8'hf0;
 buffer[904] = 8'h00;
 buffer[905] = 8'h00;
 buffer[906] = 8'h76;
 buffer[907] = 8'hcc;
 buffer[908] = 8'hcc;
 buffer[909] = 8'h7c;
 buffer[910] = 8'h0c;
 buffer[911] = 8'h1e;
 buffer[912] = 8'h00;
 buffer[913] = 8'h00;
 buffer[914] = 8'hdc;
 buffer[915] = 8'h76;
 buffer[916] = 8'h66;
 buffer[917] = 8'h60;
 buffer[918] = 8'hf0;
 buffer[919] = 8'h00;
 buffer[920] = 8'h00;
 buffer[921] = 8'h00;
 buffer[922] = 8'h7c;
 buffer[923] = 8'hc0;
 buffer[924] = 8'h78;
 buffer[925] = 8'h0c;
 buffer[926] = 8'hf8;
 buffer[927] = 8'h00;
 buffer[928] = 8'h10;
 buffer[929] = 8'h30;
 buffer[930] = 8'h7c;
 buffer[931] = 8'h30;
 buffer[932] = 8'h30;
 buffer[933] = 8'h34;
 buffer[934] = 8'h18;
 buffer[935] = 8'h00;
 buffer[936] = 8'h00;
 buffer[937] = 8'h00;
 buffer[938] = 8'hcc;
 buffer[939] = 8'hcc;
 buffer[940] = 8'hcc;
 buffer[941] = 8'hcc;
 buffer[942] = 8'h76;
 buffer[943] = 8'h00;
 buffer[944] = 8'h00;
 buffer[945] = 8'h00;
 buffer[946] = 8'hcc;
 buffer[947] = 8'hcc;
 buffer[948] = 8'hcc;
 buffer[949] = 8'h78;
 buffer[950] = 8'h30;
 buffer[951] = 8'h00;
 buffer[952] = 8'h00;
 buffer[953] = 8'h00;
 buffer[954] = 8'hc6;
 buffer[955] = 8'hd6;
 buffer[956] = 8'hfe;
 buffer[957] = 8'hfe;
 buffer[958] = 8'h6c;
 buffer[959] = 8'h00;
 buffer[960] = 8'h00;
 buffer[961] = 8'h00;
 buffer[962] = 8'hc6;
 buffer[963] = 8'h6c;
 buffer[964] = 8'h38;
 buffer[965] = 8'h6c;
 buffer[966] = 8'hc6;
 buffer[967] = 8'h00;
 buffer[968] = 8'h00;
 buffer[969] = 8'h00;
 buffer[970] = 8'hcc;
 buffer[971] = 8'hcc;
 buffer[972] = 8'hcc;
 buffer[973] = 8'h7c;
 buffer[974] = 8'h0c;
 buffer[975] = 8'hf8;
 buffer[976] = 8'h00;
 buffer[977] = 8'h00;
 buffer[978] = 8'hfc;
 buffer[979] = 8'h98;
 buffer[980] = 8'h30;
 buffer[981] = 8'h64;
 buffer[982] = 8'hfc;
 buffer[983] = 8'h00;
 buffer[984] = 8'h1c;
 buffer[985] = 8'h30;
 buffer[986] = 8'h30;
 buffer[987] = 8'he0;
 buffer[988] = 8'h30;
 buffer[989] = 8'h30;
 buffer[990] = 8'h1c;
 buffer[991] = 8'h00;
 buffer[992] = 8'h18;
 buffer[993] = 8'h18;
 buffer[994] = 8'h18;
 buffer[995] = 8'h00;
 buffer[996] = 8'h18;
 buffer[997] = 8'h18;
 buffer[998] = 8'h18;
 buffer[999] = 8'h00;
 buffer[1000] = 8'he0;
 buffer[1001] = 8'h30;
 buffer[1002] = 8'h30;
 buffer[1003] = 8'h1c;
 buffer[1004] = 8'h30;
 buffer[1005] = 8'h30;
 buffer[1006] = 8'he0;
 buffer[1007] = 8'h00;
 buffer[1008] = 8'h76;
 buffer[1009] = 8'hdc;
 buffer[1010] = 8'h00;
 buffer[1011] = 8'h00;
 buffer[1012] = 8'h00;
 buffer[1013] = 8'h00;
 buffer[1014] = 8'h00;
 buffer[1015] = 8'h00;
 buffer[1016] = 8'h00;
 buffer[1017] = 8'h10;
 buffer[1018] = 8'h38;
 buffer[1019] = 8'h6c;
 buffer[1020] = 8'hc6;
 buffer[1021] = 8'hc6;
 buffer[1022] = 8'hfe;
 buffer[1023] = 8'h00;
 buffer[1024] = 8'h78;
 buffer[1025] = 8'hcc;
 buffer[1026] = 8'hc0;
 buffer[1027] = 8'hcc;
 buffer[1028] = 8'h78;
 buffer[1029] = 8'h18;
 buffer[1030] = 8'h0c;
 buffer[1031] = 8'h78;
 buffer[1032] = 8'h00;
 buffer[1033] = 8'hcc;
 buffer[1034] = 8'h00;
 buffer[1035] = 8'hcc;
 buffer[1036] = 8'hcc;
 buffer[1037] = 8'hcc;
 buffer[1038] = 8'h7e;
 buffer[1039] = 8'h00;
 buffer[1040] = 8'h1c;
 buffer[1041] = 8'h00;
 buffer[1042] = 8'h78;
 buffer[1043] = 8'hcc;
 buffer[1044] = 8'hfc;
 buffer[1045] = 8'hc0;
 buffer[1046] = 8'h78;
 buffer[1047] = 8'h00;
 buffer[1048] = 8'h7e;
 buffer[1049] = 8'hc3;
 buffer[1050] = 8'h3c;
 buffer[1051] = 8'h06;
 buffer[1052] = 8'h3e;
 buffer[1053] = 8'h66;
 buffer[1054] = 8'h3f;
 buffer[1055] = 8'h00;
 buffer[1056] = 8'hcc;
 buffer[1057] = 8'h00;
 buffer[1058] = 8'h78;
 buffer[1059] = 8'h0c;
 buffer[1060] = 8'h7c;
 buffer[1061] = 8'hcc;
 buffer[1062] = 8'h7e;
 buffer[1063] = 8'h00;
 buffer[1064] = 8'he0;
 buffer[1065] = 8'h00;
 buffer[1066] = 8'h78;
 buffer[1067] = 8'h0c;
 buffer[1068] = 8'h7c;
 buffer[1069] = 8'hcc;
 buffer[1070] = 8'h7e;
 buffer[1071] = 8'h00;
 buffer[1072] = 8'h30;
 buffer[1073] = 8'h30;
 buffer[1074] = 8'h78;
 buffer[1075] = 8'h0c;
 buffer[1076] = 8'h7c;
 buffer[1077] = 8'hcc;
 buffer[1078] = 8'h7e;
 buffer[1079] = 8'h00;
 buffer[1080] = 8'h00;
 buffer[1081] = 8'h00;
 buffer[1082] = 8'h78;
 buffer[1083] = 8'hc0;
 buffer[1084] = 8'hc0;
 buffer[1085] = 8'h78;
 buffer[1086] = 8'h0c;
 buffer[1087] = 8'h38;
 buffer[1088] = 8'h7e;
 buffer[1089] = 8'hc3;
 buffer[1090] = 8'h3c;
 buffer[1091] = 8'h66;
 buffer[1092] = 8'h7e;
 buffer[1093] = 8'h60;
 buffer[1094] = 8'h3c;
 buffer[1095] = 8'h00;
 buffer[1096] = 8'hcc;
 buffer[1097] = 8'h00;
 buffer[1098] = 8'h78;
 buffer[1099] = 8'hcc;
 buffer[1100] = 8'hfc;
 buffer[1101] = 8'hc0;
 buffer[1102] = 8'h78;
 buffer[1103] = 8'h00;
 buffer[1104] = 8'he0;
 buffer[1105] = 8'h00;
 buffer[1106] = 8'h78;
 buffer[1107] = 8'hcc;
 buffer[1108] = 8'hfc;
 buffer[1109] = 8'hc0;
 buffer[1110] = 8'h78;
 buffer[1111] = 8'h00;
 buffer[1112] = 8'hcc;
 buffer[1113] = 8'h00;
 buffer[1114] = 8'h70;
 buffer[1115] = 8'h30;
 buffer[1116] = 8'h30;
 buffer[1117] = 8'h30;
 buffer[1118] = 8'h78;
 buffer[1119] = 8'h00;
 buffer[1120] = 8'h7c;
 buffer[1121] = 8'hc6;
 buffer[1122] = 8'h38;
 buffer[1123] = 8'h18;
 buffer[1124] = 8'h18;
 buffer[1125] = 8'h18;
 buffer[1126] = 8'h3c;
 buffer[1127] = 8'h00;
 buffer[1128] = 8'he0;
 buffer[1129] = 8'h00;
 buffer[1130] = 8'h70;
 buffer[1131] = 8'h30;
 buffer[1132] = 8'h30;
 buffer[1133] = 8'h30;
 buffer[1134] = 8'h78;
 buffer[1135] = 8'h00;
 buffer[1136] = 8'hc6;
 buffer[1137] = 8'h38;
 buffer[1138] = 8'h6c;
 buffer[1139] = 8'hc6;
 buffer[1140] = 8'hfe;
 buffer[1141] = 8'hc6;
 buffer[1142] = 8'hc6;
 buffer[1143] = 8'h00;
 buffer[1144] = 8'h30;
 buffer[1145] = 8'h30;
 buffer[1146] = 8'h00;
 buffer[1147] = 8'h78;
 buffer[1148] = 8'hcc;
 buffer[1149] = 8'hfc;
 buffer[1150] = 8'hcc;
 buffer[1151] = 8'h00;
 buffer[1152] = 8'h1c;
 buffer[1153] = 8'h00;
 buffer[1154] = 8'hfc;
 buffer[1155] = 8'h60;
 buffer[1156] = 8'h78;
 buffer[1157] = 8'h60;
 buffer[1158] = 8'hfc;
 buffer[1159] = 8'h00;
 buffer[1160] = 8'h00;
 buffer[1161] = 8'h00;
 buffer[1162] = 8'h7f;
 buffer[1163] = 8'h0c;
 buffer[1164] = 8'h7f;
 buffer[1165] = 8'hcc;
 buffer[1166] = 8'h7f;
 buffer[1167] = 8'h00;
 buffer[1168] = 8'h3e;
 buffer[1169] = 8'h6c;
 buffer[1170] = 8'hcc;
 buffer[1171] = 8'hfe;
 buffer[1172] = 8'hcc;
 buffer[1173] = 8'hcc;
 buffer[1174] = 8'hce;
 buffer[1175] = 8'h00;
 buffer[1176] = 8'h78;
 buffer[1177] = 8'hcc;
 buffer[1178] = 8'h00;
 buffer[1179] = 8'h78;
 buffer[1180] = 8'hcc;
 buffer[1181] = 8'hcc;
 buffer[1182] = 8'h78;
 buffer[1183] = 8'h00;
 buffer[1184] = 8'h00;
 buffer[1185] = 8'hcc;
 buffer[1186] = 8'h00;
 buffer[1187] = 8'h78;
 buffer[1188] = 8'hcc;
 buffer[1189] = 8'hcc;
 buffer[1190] = 8'h78;
 buffer[1191] = 8'h00;
 buffer[1192] = 8'h00;
 buffer[1193] = 8'he0;
 buffer[1194] = 8'h00;
 buffer[1195] = 8'h78;
 buffer[1196] = 8'hcc;
 buffer[1197] = 8'hcc;
 buffer[1198] = 8'h78;
 buffer[1199] = 8'h00;
 buffer[1200] = 8'h78;
 buffer[1201] = 8'hcc;
 buffer[1202] = 8'h00;
 buffer[1203] = 8'hcc;
 buffer[1204] = 8'hcc;
 buffer[1205] = 8'hcc;
 buffer[1206] = 8'h7e;
 buffer[1207] = 8'h00;
 buffer[1208] = 8'h00;
 buffer[1209] = 8'he0;
 buffer[1210] = 8'h00;
 buffer[1211] = 8'hcc;
 buffer[1212] = 8'hcc;
 buffer[1213] = 8'hcc;
 buffer[1214] = 8'h7e;
 buffer[1215] = 8'h00;
 buffer[1216] = 8'h00;
 buffer[1217] = 8'hcc;
 buffer[1218] = 8'h00;
 buffer[1219] = 8'hcc;
 buffer[1220] = 8'hcc;
 buffer[1221] = 8'h7c;
 buffer[1222] = 8'h0c;
 buffer[1223] = 8'hf8;
 buffer[1224] = 8'hc3;
 buffer[1225] = 8'h18;
 buffer[1226] = 8'h3c;
 buffer[1227] = 8'h66;
 buffer[1228] = 8'h66;
 buffer[1229] = 8'h3c;
 buffer[1230] = 8'h18;
 buffer[1231] = 8'h00;
 buffer[1232] = 8'hcc;
 buffer[1233] = 8'h00;
 buffer[1234] = 8'hcc;
 buffer[1235] = 8'hcc;
 buffer[1236] = 8'hcc;
 buffer[1237] = 8'hcc;
 buffer[1238] = 8'h78;
 buffer[1239] = 8'h00;
 buffer[1240] = 8'h18;
 buffer[1241] = 8'h18;
 buffer[1242] = 8'h7e;
 buffer[1243] = 8'hc0;
 buffer[1244] = 8'hc0;
 buffer[1245] = 8'h7e;
 buffer[1246] = 8'h18;
 buffer[1247] = 8'h18;
 buffer[1248] = 8'h38;
 buffer[1249] = 8'h6c;
 buffer[1250] = 8'h64;
 buffer[1251] = 8'hf0;
 buffer[1252] = 8'h60;
 buffer[1253] = 8'he6;
 buffer[1254] = 8'hfc;
 buffer[1255] = 8'h00;
 buffer[1256] = 8'hcc;
 buffer[1257] = 8'hcc;
 buffer[1258] = 8'h78;
 buffer[1259] = 8'hfc;
 buffer[1260] = 8'h30;
 buffer[1261] = 8'hfc;
 buffer[1262] = 8'h30;
 buffer[1263] = 8'h30;
 buffer[1264] = 8'hf8;
 buffer[1265] = 8'hcc;
 buffer[1266] = 8'hcc;
 buffer[1267] = 8'hfa;
 buffer[1268] = 8'hc6;
 buffer[1269] = 8'hcf;
 buffer[1270] = 8'hc6;
 buffer[1271] = 8'hc7;
 buffer[1272] = 8'h0e;
 buffer[1273] = 8'h1b;
 buffer[1274] = 8'h18;
 buffer[1275] = 8'h3c;
 buffer[1276] = 8'h18;
 buffer[1277] = 8'h18;
 buffer[1278] = 8'hd8;
 buffer[1279] = 8'h70;
 buffer[1280] = 8'h1c;
 buffer[1281] = 8'h00;
 buffer[1282] = 8'h78;
 buffer[1283] = 8'h0c;
 buffer[1284] = 8'h7c;
 buffer[1285] = 8'hcc;
 buffer[1286] = 8'h7e;
 buffer[1287] = 8'h00;
 buffer[1288] = 8'h38;
 buffer[1289] = 8'h00;
 buffer[1290] = 8'h70;
 buffer[1291] = 8'h30;
 buffer[1292] = 8'h30;
 buffer[1293] = 8'h30;
 buffer[1294] = 8'h78;
 buffer[1295] = 8'h00;
 buffer[1296] = 8'h00;
 buffer[1297] = 8'h1c;
 buffer[1298] = 8'h00;
 buffer[1299] = 8'h78;
 buffer[1300] = 8'hcc;
 buffer[1301] = 8'hcc;
 buffer[1302] = 8'h78;
 buffer[1303] = 8'h00;
 buffer[1304] = 8'h00;
 buffer[1305] = 8'h1c;
 buffer[1306] = 8'h00;
 buffer[1307] = 8'hcc;
 buffer[1308] = 8'hcc;
 buffer[1309] = 8'hcc;
 buffer[1310] = 8'h7e;
 buffer[1311] = 8'h00;
 buffer[1312] = 8'h00;
 buffer[1313] = 8'hf8;
 buffer[1314] = 8'h00;
 buffer[1315] = 8'hf8;
 buffer[1316] = 8'hcc;
 buffer[1317] = 8'hcc;
 buffer[1318] = 8'hcc;
 buffer[1319] = 8'h00;
 buffer[1320] = 8'hfc;
 buffer[1321] = 8'h00;
 buffer[1322] = 8'hcc;
 buffer[1323] = 8'hec;
 buffer[1324] = 8'hfc;
 buffer[1325] = 8'hdc;
 buffer[1326] = 8'hcc;
 buffer[1327] = 8'h00;
 buffer[1328] = 8'h3c;
 buffer[1329] = 8'h6c;
 buffer[1330] = 8'h6c;
 buffer[1331] = 8'h3e;
 buffer[1332] = 8'h00;
 buffer[1333] = 8'h7e;
 buffer[1334] = 8'h00;
 buffer[1335] = 8'h00;
 buffer[1336] = 8'h38;
 buffer[1337] = 8'h6c;
 buffer[1338] = 8'h6c;
 buffer[1339] = 8'h38;
 buffer[1340] = 8'h00;
 buffer[1341] = 8'h7c;
 buffer[1342] = 8'h00;
 buffer[1343] = 8'h00;
 buffer[1344] = 8'h30;
 buffer[1345] = 8'h00;
 buffer[1346] = 8'h30;
 buffer[1347] = 8'h60;
 buffer[1348] = 8'hc0;
 buffer[1349] = 8'hcc;
 buffer[1350] = 8'h78;
 buffer[1351] = 8'h00;
 buffer[1352] = 8'h00;
 buffer[1353] = 8'h00;
 buffer[1354] = 8'h00;
 buffer[1355] = 8'hfc;
 buffer[1356] = 8'hc0;
 buffer[1357] = 8'hc0;
 buffer[1358] = 8'h00;
 buffer[1359] = 8'h00;
 buffer[1360] = 8'h00;
 buffer[1361] = 8'h00;
 buffer[1362] = 8'h00;
 buffer[1363] = 8'hfc;
 buffer[1364] = 8'h0c;
 buffer[1365] = 8'h0c;
 buffer[1366] = 8'h00;
 buffer[1367] = 8'h00;
 buffer[1368] = 8'hc3;
 buffer[1369] = 8'hc6;
 buffer[1370] = 8'hcc;
 buffer[1371] = 8'hde;
 buffer[1372] = 8'h33;
 buffer[1373] = 8'h66;
 buffer[1374] = 8'hcc;
 buffer[1375] = 8'h0f;
 buffer[1376] = 8'hc3;
 buffer[1377] = 8'hc6;
 buffer[1378] = 8'hcc;
 buffer[1379] = 8'hdb;
 buffer[1380] = 8'h37;
 buffer[1381] = 8'h6f;
 buffer[1382] = 8'hcf;
 buffer[1383] = 8'h03;
 buffer[1384] = 8'h18;
 buffer[1385] = 8'h18;
 buffer[1386] = 8'h00;
 buffer[1387] = 8'h18;
 buffer[1388] = 8'h18;
 buffer[1389] = 8'h18;
 buffer[1390] = 8'h18;
 buffer[1391] = 8'h00;
 buffer[1392] = 8'h00;
 buffer[1393] = 8'h33;
 buffer[1394] = 8'h66;
 buffer[1395] = 8'hcc;
 buffer[1396] = 8'h66;
 buffer[1397] = 8'h33;
 buffer[1398] = 8'h00;
 buffer[1399] = 8'h00;
 buffer[1400] = 8'h00;
 buffer[1401] = 8'hcc;
 buffer[1402] = 8'h66;
 buffer[1403] = 8'h33;
 buffer[1404] = 8'h66;
 buffer[1405] = 8'hcc;
 buffer[1406] = 8'h00;
 buffer[1407] = 8'h00;
 buffer[1408] = 8'h22;
 buffer[1409] = 8'h88;
 buffer[1410] = 8'h22;
 buffer[1411] = 8'h88;
 buffer[1412] = 8'h22;
 buffer[1413] = 8'h88;
 buffer[1414] = 8'h22;
 buffer[1415] = 8'h88;
 buffer[1416] = 8'h55;
 buffer[1417] = 8'haa;
 buffer[1418] = 8'h55;
 buffer[1419] = 8'haa;
 buffer[1420] = 8'h55;
 buffer[1421] = 8'haa;
 buffer[1422] = 8'h55;
 buffer[1423] = 8'haa;
 buffer[1424] = 8'hdb;
 buffer[1425] = 8'h77;
 buffer[1426] = 8'hdb;
 buffer[1427] = 8'hee;
 buffer[1428] = 8'hdb;
 buffer[1429] = 8'h77;
 buffer[1430] = 8'hdb;
 buffer[1431] = 8'hee;
 buffer[1432] = 8'h18;
 buffer[1433] = 8'h18;
 buffer[1434] = 8'h18;
 buffer[1435] = 8'h18;
 buffer[1436] = 8'h18;
 buffer[1437] = 8'h18;
 buffer[1438] = 8'h18;
 buffer[1439] = 8'h18;
 buffer[1440] = 8'h18;
 buffer[1441] = 8'h18;
 buffer[1442] = 8'h18;
 buffer[1443] = 8'h18;
 buffer[1444] = 8'hf8;
 buffer[1445] = 8'h18;
 buffer[1446] = 8'h18;
 buffer[1447] = 8'h18;
 buffer[1448] = 8'h18;
 buffer[1449] = 8'h18;
 buffer[1450] = 8'hf8;
 buffer[1451] = 8'h18;
 buffer[1452] = 8'hf8;
 buffer[1453] = 8'h18;
 buffer[1454] = 8'h18;
 buffer[1455] = 8'h18;
 buffer[1456] = 8'h36;
 buffer[1457] = 8'h36;
 buffer[1458] = 8'h36;
 buffer[1459] = 8'h36;
 buffer[1460] = 8'hf6;
 buffer[1461] = 8'h36;
 buffer[1462] = 8'h36;
 buffer[1463] = 8'h36;
 buffer[1464] = 8'h00;
 buffer[1465] = 8'h00;
 buffer[1466] = 8'h00;
 buffer[1467] = 8'h00;
 buffer[1468] = 8'hfe;
 buffer[1469] = 8'h36;
 buffer[1470] = 8'h36;
 buffer[1471] = 8'h36;
 buffer[1472] = 8'h00;
 buffer[1473] = 8'h00;
 buffer[1474] = 8'hf8;
 buffer[1475] = 8'h18;
 buffer[1476] = 8'hf8;
 buffer[1477] = 8'h18;
 buffer[1478] = 8'h18;
 buffer[1479] = 8'h18;
 buffer[1480] = 8'h36;
 buffer[1481] = 8'h36;
 buffer[1482] = 8'hf6;
 buffer[1483] = 8'h06;
 buffer[1484] = 8'hf6;
 buffer[1485] = 8'h36;
 buffer[1486] = 8'h36;
 buffer[1487] = 8'h36;
 buffer[1488] = 8'h36;
 buffer[1489] = 8'h36;
 buffer[1490] = 8'h36;
 buffer[1491] = 8'h36;
 buffer[1492] = 8'h36;
 buffer[1493] = 8'h36;
 buffer[1494] = 8'h36;
 buffer[1495] = 8'h36;
 buffer[1496] = 8'h00;
 buffer[1497] = 8'h00;
 buffer[1498] = 8'hfe;
 buffer[1499] = 8'h06;
 buffer[1500] = 8'hf6;
 buffer[1501] = 8'h36;
 buffer[1502] = 8'h36;
 buffer[1503] = 8'h36;
 buffer[1504] = 8'h36;
 buffer[1505] = 8'h36;
 buffer[1506] = 8'hf6;
 buffer[1507] = 8'h06;
 buffer[1508] = 8'hfe;
 buffer[1509] = 8'h00;
 buffer[1510] = 8'h00;
 buffer[1511] = 8'h00;
 buffer[1512] = 8'h36;
 buffer[1513] = 8'h36;
 buffer[1514] = 8'h36;
 buffer[1515] = 8'h36;
 buffer[1516] = 8'hfe;
 buffer[1517] = 8'h00;
 buffer[1518] = 8'h00;
 buffer[1519] = 8'h00;
 buffer[1520] = 8'h18;
 buffer[1521] = 8'h18;
 buffer[1522] = 8'hf8;
 buffer[1523] = 8'h18;
 buffer[1524] = 8'hf8;
 buffer[1525] = 8'h00;
 buffer[1526] = 8'h00;
 buffer[1527] = 8'h00;
 buffer[1528] = 8'h00;
 buffer[1529] = 8'h00;
 buffer[1530] = 8'h00;
 buffer[1531] = 8'h00;
 buffer[1532] = 8'hf8;
 buffer[1533] = 8'h18;
 buffer[1534] = 8'h18;
 buffer[1535] = 8'h18;
 buffer[1536] = 8'h18;
 buffer[1537] = 8'h18;
 buffer[1538] = 8'h18;
 buffer[1539] = 8'h18;
 buffer[1540] = 8'h1f;
 buffer[1541] = 8'h00;
 buffer[1542] = 8'h00;
 buffer[1543] = 8'h00;
 buffer[1544] = 8'h18;
 buffer[1545] = 8'h18;
 buffer[1546] = 8'h18;
 buffer[1547] = 8'h18;
 buffer[1548] = 8'hff;
 buffer[1549] = 8'h00;
 buffer[1550] = 8'h00;
 buffer[1551] = 8'h00;
 buffer[1552] = 8'h00;
 buffer[1553] = 8'h00;
 buffer[1554] = 8'h00;
 buffer[1555] = 8'h00;
 buffer[1556] = 8'hff;
 buffer[1557] = 8'h18;
 buffer[1558] = 8'h18;
 buffer[1559] = 8'h18;
 buffer[1560] = 8'h18;
 buffer[1561] = 8'h18;
 buffer[1562] = 8'h18;
 buffer[1563] = 8'h18;
 buffer[1564] = 8'h1f;
 buffer[1565] = 8'h18;
 buffer[1566] = 8'h18;
 buffer[1567] = 8'h18;
 buffer[1568] = 8'h00;
 buffer[1569] = 8'h00;
 buffer[1570] = 8'h00;
 buffer[1571] = 8'h00;
 buffer[1572] = 8'hff;
 buffer[1573] = 8'h00;
 buffer[1574] = 8'h00;
 buffer[1575] = 8'h00;
 buffer[1576] = 8'h18;
 buffer[1577] = 8'h18;
 buffer[1578] = 8'h18;
 buffer[1579] = 8'h18;
 buffer[1580] = 8'hff;
 buffer[1581] = 8'h18;
 buffer[1582] = 8'h18;
 buffer[1583] = 8'h18;
 buffer[1584] = 8'h18;
 buffer[1585] = 8'h18;
 buffer[1586] = 8'h1f;
 buffer[1587] = 8'h18;
 buffer[1588] = 8'h1f;
 buffer[1589] = 8'h18;
 buffer[1590] = 8'h18;
 buffer[1591] = 8'h18;
 buffer[1592] = 8'h36;
 buffer[1593] = 8'h36;
 buffer[1594] = 8'h36;
 buffer[1595] = 8'h36;
 buffer[1596] = 8'h37;
 buffer[1597] = 8'h36;
 buffer[1598] = 8'h36;
 buffer[1599] = 8'h36;
 buffer[1600] = 8'h36;
 buffer[1601] = 8'h36;
 buffer[1602] = 8'h37;
 buffer[1603] = 8'h30;
 buffer[1604] = 8'h3f;
 buffer[1605] = 8'h00;
 buffer[1606] = 8'h00;
 buffer[1607] = 8'h00;
 buffer[1608] = 8'h00;
 buffer[1609] = 8'h00;
 buffer[1610] = 8'h3f;
 buffer[1611] = 8'h30;
 buffer[1612] = 8'h37;
 buffer[1613] = 8'h36;
 buffer[1614] = 8'h36;
 buffer[1615] = 8'h36;
 buffer[1616] = 8'h36;
 buffer[1617] = 8'h36;
 buffer[1618] = 8'hf7;
 buffer[1619] = 8'h00;
 buffer[1620] = 8'hff;
 buffer[1621] = 8'h00;
 buffer[1622] = 8'h00;
 buffer[1623] = 8'h00;
 buffer[1624] = 8'h00;
 buffer[1625] = 8'h00;
 buffer[1626] = 8'hff;
 buffer[1627] = 8'h00;
 buffer[1628] = 8'hf7;
 buffer[1629] = 8'h36;
 buffer[1630] = 8'h36;
 buffer[1631] = 8'h36;
 buffer[1632] = 8'h36;
 buffer[1633] = 8'h36;
 buffer[1634] = 8'h37;
 buffer[1635] = 8'h30;
 buffer[1636] = 8'h37;
 buffer[1637] = 8'h36;
 buffer[1638] = 8'h36;
 buffer[1639] = 8'h36;
 buffer[1640] = 8'h00;
 buffer[1641] = 8'h00;
 buffer[1642] = 8'hff;
 buffer[1643] = 8'h00;
 buffer[1644] = 8'hff;
 buffer[1645] = 8'h00;
 buffer[1646] = 8'h00;
 buffer[1647] = 8'h00;
 buffer[1648] = 8'h36;
 buffer[1649] = 8'h36;
 buffer[1650] = 8'hf7;
 buffer[1651] = 8'h00;
 buffer[1652] = 8'hf7;
 buffer[1653] = 8'h36;
 buffer[1654] = 8'h36;
 buffer[1655] = 8'h36;
 buffer[1656] = 8'h18;
 buffer[1657] = 8'h18;
 buffer[1658] = 8'hff;
 buffer[1659] = 8'h00;
 buffer[1660] = 8'hff;
 buffer[1661] = 8'h00;
 buffer[1662] = 8'h00;
 buffer[1663] = 8'h00;
 buffer[1664] = 8'h36;
 buffer[1665] = 8'h36;
 buffer[1666] = 8'h36;
 buffer[1667] = 8'h36;
 buffer[1668] = 8'hff;
 buffer[1669] = 8'h00;
 buffer[1670] = 8'h00;
 buffer[1671] = 8'h00;
 buffer[1672] = 8'h00;
 buffer[1673] = 8'h00;
 buffer[1674] = 8'hff;
 buffer[1675] = 8'h00;
 buffer[1676] = 8'hff;
 buffer[1677] = 8'h18;
 buffer[1678] = 8'h18;
 buffer[1679] = 8'h18;
 buffer[1680] = 8'h00;
 buffer[1681] = 8'h00;
 buffer[1682] = 8'h00;
 buffer[1683] = 8'h00;
 buffer[1684] = 8'hff;
 buffer[1685] = 8'h36;
 buffer[1686] = 8'h36;
 buffer[1687] = 8'h36;
 buffer[1688] = 8'h36;
 buffer[1689] = 8'h36;
 buffer[1690] = 8'h36;
 buffer[1691] = 8'h36;
 buffer[1692] = 8'h3f;
 buffer[1693] = 8'h00;
 buffer[1694] = 8'h00;
 buffer[1695] = 8'h00;
 buffer[1696] = 8'h18;
 buffer[1697] = 8'h18;
 buffer[1698] = 8'h1f;
 buffer[1699] = 8'h18;
 buffer[1700] = 8'h1f;
 buffer[1701] = 8'h00;
 buffer[1702] = 8'h00;
 buffer[1703] = 8'h00;
 buffer[1704] = 8'h00;
 buffer[1705] = 8'h00;
 buffer[1706] = 8'h1f;
 buffer[1707] = 8'h18;
 buffer[1708] = 8'h1f;
 buffer[1709] = 8'h18;
 buffer[1710] = 8'h18;
 buffer[1711] = 8'h18;
 buffer[1712] = 8'h00;
 buffer[1713] = 8'h00;
 buffer[1714] = 8'h00;
 buffer[1715] = 8'h00;
 buffer[1716] = 8'h3f;
 buffer[1717] = 8'h36;
 buffer[1718] = 8'h36;
 buffer[1719] = 8'h36;
 buffer[1720] = 8'h36;
 buffer[1721] = 8'h36;
 buffer[1722] = 8'h36;
 buffer[1723] = 8'h36;
 buffer[1724] = 8'hff;
 buffer[1725] = 8'h36;
 buffer[1726] = 8'h36;
 buffer[1727] = 8'h36;
 buffer[1728] = 8'h18;
 buffer[1729] = 8'h18;
 buffer[1730] = 8'hff;
 buffer[1731] = 8'h18;
 buffer[1732] = 8'hff;
 buffer[1733] = 8'h18;
 buffer[1734] = 8'h18;
 buffer[1735] = 8'h18;
 buffer[1736] = 8'h18;
 buffer[1737] = 8'h18;
 buffer[1738] = 8'h18;
 buffer[1739] = 8'h18;
 buffer[1740] = 8'hf8;
 buffer[1741] = 8'h00;
 buffer[1742] = 8'h00;
 buffer[1743] = 8'h00;
 buffer[1744] = 8'h00;
 buffer[1745] = 8'h00;
 buffer[1746] = 8'h00;
 buffer[1747] = 8'h00;
 buffer[1748] = 8'h1f;
 buffer[1749] = 8'h18;
 buffer[1750] = 8'h18;
 buffer[1751] = 8'h18;
 buffer[1752] = 8'hff;
 buffer[1753] = 8'hff;
 buffer[1754] = 8'hff;
 buffer[1755] = 8'hff;
 buffer[1756] = 8'hff;
 buffer[1757] = 8'hff;
 buffer[1758] = 8'hff;
 buffer[1759] = 8'hff;
 buffer[1760] = 8'h00;
 buffer[1761] = 8'h00;
 buffer[1762] = 8'h00;
 buffer[1763] = 8'h00;
 buffer[1764] = 8'hff;
 buffer[1765] = 8'hff;
 buffer[1766] = 8'hff;
 buffer[1767] = 8'hff;
 buffer[1768] = 8'hf0;
 buffer[1769] = 8'hf0;
 buffer[1770] = 8'hf0;
 buffer[1771] = 8'hf0;
 buffer[1772] = 8'hf0;
 buffer[1773] = 8'hf0;
 buffer[1774] = 8'hf0;
 buffer[1775] = 8'hf0;
 buffer[1776] = 8'h0f;
 buffer[1777] = 8'h0f;
 buffer[1778] = 8'h0f;
 buffer[1779] = 8'h0f;
 buffer[1780] = 8'h0f;
 buffer[1781] = 8'h0f;
 buffer[1782] = 8'h0f;
 buffer[1783] = 8'h0f;
 buffer[1784] = 8'hff;
 buffer[1785] = 8'hff;
 buffer[1786] = 8'hff;
 buffer[1787] = 8'hff;
 buffer[1788] = 8'h00;
 buffer[1789] = 8'h00;
 buffer[1790] = 8'h00;
 buffer[1791] = 8'h00;
 buffer[1792] = 8'h00;
 buffer[1793] = 8'h00;
 buffer[1794] = 8'h76;
 buffer[1795] = 8'hdc;
 buffer[1796] = 8'hc8;
 buffer[1797] = 8'hdc;
 buffer[1798] = 8'h76;
 buffer[1799] = 8'h00;
 buffer[1800] = 8'h00;
 buffer[1801] = 8'h78;
 buffer[1802] = 8'hcc;
 buffer[1803] = 8'hf8;
 buffer[1804] = 8'hcc;
 buffer[1805] = 8'hf8;
 buffer[1806] = 8'hc0;
 buffer[1807] = 8'hc0;
 buffer[1808] = 8'h00;
 buffer[1809] = 8'hfc;
 buffer[1810] = 8'hcc;
 buffer[1811] = 8'hc0;
 buffer[1812] = 8'hc0;
 buffer[1813] = 8'hc0;
 buffer[1814] = 8'hc0;
 buffer[1815] = 8'h00;
 buffer[1816] = 8'h00;
 buffer[1817] = 8'hfe;
 buffer[1818] = 8'h6c;
 buffer[1819] = 8'h6c;
 buffer[1820] = 8'h6c;
 buffer[1821] = 8'h6c;
 buffer[1822] = 8'h6c;
 buffer[1823] = 8'h00;
 buffer[1824] = 8'hfc;
 buffer[1825] = 8'hcc;
 buffer[1826] = 8'h60;
 buffer[1827] = 8'h30;
 buffer[1828] = 8'h60;
 buffer[1829] = 8'hcc;
 buffer[1830] = 8'hfc;
 buffer[1831] = 8'h00;
 buffer[1832] = 8'h00;
 buffer[1833] = 8'h00;
 buffer[1834] = 8'h7e;
 buffer[1835] = 8'hd8;
 buffer[1836] = 8'hd8;
 buffer[1837] = 8'hd8;
 buffer[1838] = 8'h70;
 buffer[1839] = 8'h00;
 buffer[1840] = 8'h00;
 buffer[1841] = 8'h66;
 buffer[1842] = 8'h66;
 buffer[1843] = 8'h66;
 buffer[1844] = 8'h66;
 buffer[1845] = 8'h7c;
 buffer[1846] = 8'h60;
 buffer[1847] = 8'hc0;
 buffer[1848] = 8'h00;
 buffer[1849] = 8'h76;
 buffer[1850] = 8'hdc;
 buffer[1851] = 8'h18;
 buffer[1852] = 8'h18;
 buffer[1853] = 8'h18;
 buffer[1854] = 8'h18;
 buffer[1855] = 8'h00;
 buffer[1856] = 8'hfc;
 buffer[1857] = 8'h30;
 buffer[1858] = 8'h78;
 buffer[1859] = 8'hcc;
 buffer[1860] = 8'hcc;
 buffer[1861] = 8'h78;
 buffer[1862] = 8'h30;
 buffer[1863] = 8'hfc;
 buffer[1864] = 8'h38;
 buffer[1865] = 8'h6c;
 buffer[1866] = 8'hc6;
 buffer[1867] = 8'hfe;
 buffer[1868] = 8'hc6;
 buffer[1869] = 8'h6c;
 buffer[1870] = 8'h38;
 buffer[1871] = 8'h00;
 buffer[1872] = 8'h38;
 buffer[1873] = 8'h6c;
 buffer[1874] = 8'hc6;
 buffer[1875] = 8'hc6;
 buffer[1876] = 8'h6c;
 buffer[1877] = 8'h6c;
 buffer[1878] = 8'hee;
 buffer[1879] = 8'h00;
 buffer[1880] = 8'h1c;
 buffer[1881] = 8'h30;
 buffer[1882] = 8'h18;
 buffer[1883] = 8'h7c;
 buffer[1884] = 8'hcc;
 buffer[1885] = 8'hcc;
 buffer[1886] = 8'h78;
 buffer[1887] = 8'h00;
 buffer[1888] = 8'h00;
 buffer[1889] = 8'h00;
 buffer[1890] = 8'h7e;
 buffer[1891] = 8'hdb;
 buffer[1892] = 8'hdb;
 buffer[1893] = 8'h7e;
 buffer[1894] = 8'h00;
 buffer[1895] = 8'h00;
 buffer[1896] = 8'h06;
 buffer[1897] = 8'h0c;
 buffer[1898] = 8'h7e;
 buffer[1899] = 8'hdb;
 buffer[1900] = 8'hdb;
 buffer[1901] = 8'h7e;
 buffer[1902] = 8'h60;
 buffer[1903] = 8'hc0;
 buffer[1904] = 8'h38;
 buffer[1905] = 8'h60;
 buffer[1906] = 8'hc0;
 buffer[1907] = 8'hf8;
 buffer[1908] = 8'hc0;
 buffer[1909] = 8'h60;
 buffer[1910] = 8'h38;
 buffer[1911] = 8'h00;
 buffer[1912] = 8'h78;
 buffer[1913] = 8'hcc;
 buffer[1914] = 8'hcc;
 buffer[1915] = 8'hcc;
 buffer[1916] = 8'hcc;
 buffer[1917] = 8'hcc;
 buffer[1918] = 8'hcc;
 buffer[1919] = 8'h00;
 buffer[1920] = 8'h00;
 buffer[1921] = 8'hfc;
 buffer[1922] = 8'h00;
 buffer[1923] = 8'hfc;
 buffer[1924] = 8'h00;
 buffer[1925] = 8'hfc;
 buffer[1926] = 8'h00;
 buffer[1927] = 8'h00;
 buffer[1928] = 8'h30;
 buffer[1929] = 8'h30;
 buffer[1930] = 8'hfc;
 buffer[1931] = 8'h30;
 buffer[1932] = 8'h30;
 buffer[1933] = 8'h00;
 buffer[1934] = 8'hfc;
 buffer[1935] = 8'h00;
 buffer[1936] = 8'h60;
 buffer[1937] = 8'h30;
 buffer[1938] = 8'h18;
 buffer[1939] = 8'h30;
 buffer[1940] = 8'h60;
 buffer[1941] = 8'h00;
 buffer[1942] = 8'hfc;
 buffer[1943] = 8'h00;
 buffer[1944] = 8'h18;
 buffer[1945] = 8'h30;
 buffer[1946] = 8'h60;
 buffer[1947] = 8'h30;
 buffer[1948] = 8'h18;
 buffer[1949] = 8'h00;
 buffer[1950] = 8'hfc;
 buffer[1951] = 8'h00;
 buffer[1952] = 8'h0e;
 buffer[1953] = 8'h1b;
 buffer[1954] = 8'h1b;
 buffer[1955] = 8'h18;
 buffer[1956] = 8'h18;
 buffer[1957] = 8'h18;
 buffer[1958] = 8'h18;
 buffer[1959] = 8'h18;
 buffer[1960] = 8'h18;
 buffer[1961] = 8'h18;
 buffer[1962] = 8'h18;
 buffer[1963] = 8'h18;
 buffer[1964] = 8'h18;
 buffer[1965] = 8'hd8;
 buffer[1966] = 8'hd8;
 buffer[1967] = 8'h70;
 buffer[1968] = 8'h30;
 buffer[1969] = 8'h30;
 buffer[1970] = 8'h00;
 buffer[1971] = 8'hfc;
 buffer[1972] = 8'h00;
 buffer[1973] = 8'h30;
 buffer[1974] = 8'h30;
 buffer[1975] = 8'h00;
 buffer[1976] = 8'h00;
 buffer[1977] = 8'h76;
 buffer[1978] = 8'hdc;
 buffer[1979] = 8'h00;
 buffer[1980] = 8'h76;
 buffer[1981] = 8'hdc;
 buffer[1982] = 8'h00;
 buffer[1983] = 8'h00;
 buffer[1984] = 8'h38;
 buffer[1985] = 8'h6c;
 buffer[1986] = 8'h6c;
 buffer[1987] = 8'h38;
 buffer[1988] = 8'h00;
 buffer[1989] = 8'h00;
 buffer[1990] = 8'h00;
 buffer[1991] = 8'h00;
 buffer[1992] = 8'h00;
 buffer[1993] = 8'h00;
 buffer[1994] = 8'h00;
 buffer[1995] = 8'h18;
 buffer[1996] = 8'h18;
 buffer[1997] = 8'h00;
 buffer[1998] = 8'h00;
 buffer[1999] = 8'h00;
 buffer[2000] = 8'h00;
 buffer[2001] = 8'h00;
 buffer[2002] = 8'h00;
 buffer[2003] = 8'h00;
 buffer[2004] = 8'h18;
 buffer[2005] = 8'h00;
 buffer[2006] = 8'h00;
 buffer[2007] = 8'h00;
 buffer[2008] = 8'h0f;
 buffer[2009] = 8'h0c;
 buffer[2010] = 8'h0c;
 buffer[2011] = 8'h0c;
 buffer[2012] = 8'hec;
 buffer[2013] = 8'h6c;
 buffer[2014] = 8'h3c;
 buffer[2015] = 8'h1c;
 buffer[2016] = 8'h78;
 buffer[2017] = 8'h6c;
 buffer[2018] = 8'h6c;
 buffer[2019] = 8'h6c;
 buffer[2020] = 8'h6c;
 buffer[2021] = 8'h00;
 buffer[2022] = 8'h00;
 buffer[2023] = 8'h00;
 buffer[2024] = 8'h70;
 buffer[2025] = 8'h18;
 buffer[2026] = 8'h30;
 buffer[2027] = 8'h60;
 buffer[2028] = 8'h78;
 buffer[2029] = 8'h00;
 buffer[2030] = 8'h00;
 buffer[2031] = 8'h00;
 buffer[2032] = 8'h00;
 buffer[2033] = 8'h00;
 buffer[2034] = 8'h3c;
 buffer[2035] = 8'h3c;
 buffer[2036] = 8'h3c;
 buffer[2037] = 8'h3c;
 buffer[2038] = 8'h00;
 buffer[2039] = 8'h00;
 buffer[2040] = 8'h00;
 buffer[2041] = 8'h00;
 buffer[2042] = 8'h00;
 buffer[2043] = 8'h00;
 buffer[2044] = 8'h00;
 buffer[2045] = 8'h00;
 buffer[2046] = 8'h00;
 buffer[2047] = 8'h00;
end

endmodule

module M_terminal_mem_terminal(
input      [9:0]                in_terminal_addr0,
output reg  [7:0]     out_terminal_rdata0,
output reg  [7:0]     out_terminal_rdata1,
input      [0:0]             in_terminal_wenable1,
input      [7:0]                 in_terminal_wdata1,
input      [9:0]                in_terminal_addr1,
input      clock0,
input      clock1
);
reg  [7:0] buffer[639:0];
always @(posedge clock0) begin
  out_terminal_rdata0 <= buffer[in_terminal_addr0];
end
always @(posedge clock1) begin
  if (in_terminal_wenable1) begin
    buffer[in_terminal_addr1] <= in_terminal_wdata1;
  end
end

endmodule

module M_terminal_mem_terminal_copy(
input      [9:0]                in_terminal_copy_addr0,
output reg  [7:0]     out_terminal_copy_rdata0,
output reg  [7:0]     out_terminal_copy_rdata1,
input      [0:0]             in_terminal_copy_wenable1,
input      [7:0]                 in_terminal_copy_wdata1,
input      [9:0]                in_terminal_copy_addr1,
input      clock0,
input      clock1
);
reg  [7:0] buffer[639:0];
always @(posedge clock0) begin
  out_terminal_copy_rdata0 <= buffer[in_terminal_copy_addr0];
end
always @(posedge clock1) begin
  if (in_terminal_copy_wenable1) begin
    buffer[in_terminal_copy_addr1] <= in_terminal_copy_wdata1;
  end
end

endmodule

module M_terminal (
in_pix_x,
in_pix_y,
in_pix_active,
in_pix_vblank,
in_terminal_character,
in_terminal_write,
in_showterminal,
in_showcursor,
in_timer1hz,
out_pix_red,
out_pix_green,
out_pix_blue,
out_terminal_display,
out_terminal_active,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [9:0] in_pix_x;
input  [9:0] in_pix_y;
input  [0:0] in_pix_active;
input  [0:0] in_pix_vblank;
input  [7:0] in_terminal_character;
input  [0:0] in_terminal_write;
input  [0:0] in_showterminal;
input  [0:0] in_showcursor;
input  [0:0] in_timer1hz;
output  [1:0] out_pix_red;
output  [1:0] out_pix_green;
output  [1:0] out_pix_blue;
output  [0:0] out_terminal_display;
output  [0:0] out_terminal_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [7:0] _w_mem_characterGenerator8x8_rdata;
wire  [7:0] _w_mem_terminal_rdata0;
wire  [7:0] _w_mem_terminal_copy_rdata0;
wire  [2:0] _c_terminal_y;
assign _c_terminal_y = 7;
wire  [6:0] _w_xterminalpos;
wire  [9:0] _w_yterminalpos;
wire  [0:0] _w_is_cursor;
wire  [2:0] _w_xinterminal;
wire  [2:0] _w_yinterminal;
wire  [0:0] _w_terminalpixel;

reg  [10:0] _d_characterGenerator8x8_addr;
reg  [10:0] _q_characterGenerator8x8_addr;
reg  [9:0] _d_terminal_addr0;
reg  [9:0] _q_terminal_addr0;
reg  [0:0] _d_terminal_wenable1;
reg  [0:0] _q_terminal_wenable1;
reg  [7:0] _d_terminal_wdata1;
reg  [7:0] _q_terminal_wdata1;
reg  [9:0] _d_terminal_addr1;
reg  [9:0] _q_terminal_addr1;
reg  [9:0] _d_terminal_copy_addr0;
reg  [9:0] _q_terminal_copy_addr0;
reg  [0:0] _d_terminal_copy_wenable1;
reg  [0:0] _q_terminal_copy_wenable1;
reg  [7:0] _d_terminal_copy_wdata1;
reg  [7:0] _q_terminal_copy_wdata1;
reg  [9:0] _d_terminal_copy_addr1;
reg  [9:0] _q_terminal_copy_addr1;
reg  [6:0] _d_terminal_x;
reg  [6:0] _q_terminal_x;
reg  [9:0] _d_terminal_scroll;
reg  [9:0] _q_terminal_scroll;
reg  [9:0] _d_terminal_scroll_character;
reg  [9:0] _q_terminal_scroll_character;
reg  [1:0] _d_pix_red,_q_pix_red;
reg  [1:0] _d_pix_green,_q_pix_green;
reg  [1:0] _d_pix_blue,_q_pix_blue;
reg  [0:0] _d_terminal_display,_q_terminal_display;
reg  [0:0] _d_terminal_active,_q_terminal_active;
reg  [3:0] _d_index,_q_index;
assign out_pix_red = _d_pix_red;
assign out_pix_green = _d_pix_green;
assign out_pix_blue = _d_pix_blue;
assign out_terminal_display = _d_terminal_display;
assign out_terminal_active = _q_terminal_active;
assign out_done = (_q_index == 9);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_characterGenerator8x8_addr <= 0;
_q_terminal_addr0 <= 0;
_q_terminal_wenable1 <= 0;
_q_terminal_wdata1 <= 0;
_q_terminal_addr1 <= 0;
_q_terminal_copy_addr0 <= 0;
_q_terminal_copy_wenable1 <= 0;
_q_terminal_copy_wdata1 <= 0;
_q_terminal_copy_addr1 <= 0;
_q_terminal_x <= 0;
_q_terminal_scroll <= 0;
_q_terminal_scroll_character <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_characterGenerator8x8_addr <= _d_characterGenerator8x8_addr;
_q_terminal_addr0 <= _d_terminal_addr0;
_q_terminal_wenable1 <= _d_terminal_wenable1;
_q_terminal_wdata1 <= _d_terminal_wdata1;
_q_terminal_addr1 <= _d_terminal_addr1;
_q_terminal_copy_addr0 <= _d_terminal_copy_addr0;
_q_terminal_copy_wenable1 <= _d_terminal_copy_wenable1;
_q_terminal_copy_wdata1 <= _d_terminal_copy_wdata1;
_q_terminal_copy_addr1 <= _d_terminal_copy_addr1;
_q_terminal_x <= _d_terminal_x;
_q_terminal_scroll <= _d_terminal_scroll;
_q_terminal_scroll_character <= _d_terminal_scroll_character;
_q_pix_red <= _d_pix_red;
_q_pix_green <= _d_pix_green;
_q_pix_blue <= _d_pix_blue;
_q_terminal_display <= _d_terminal_display;
_q_terminal_active <= _d_terminal_active;
_q_index <= _d_index;
  end
end


M_terminal_mem_characterGenerator8x8 __mem__characterGenerator8x8(
.clock(clock),
.in_characterGenerator8x8_addr(_d_characterGenerator8x8_addr),
.out_characterGenerator8x8_rdata(_w_mem_characterGenerator8x8_rdata)
);
M_terminal_mem_terminal __mem__terminal(
.clock0(clock),
.clock1(clock),
.in_terminal_addr0(_d_terminal_addr0),
.in_terminal_wenable1(_d_terminal_wenable1),
.in_terminal_wdata1(_d_terminal_wdata1),
.in_terminal_addr1(_d_terminal_addr1),
.out_terminal_rdata0(_w_mem_terminal_rdata0)
);
M_terminal_mem_terminal_copy __mem__terminal_copy(
.clock0(clock),
.clock1(clock),
.in_terminal_copy_addr0(_d_terminal_copy_addr0),
.in_terminal_copy_wenable1(_d_terminal_copy_wenable1),
.in_terminal_copy_wdata1(_d_terminal_copy_wdata1),
.in_terminal_copy_addr1(_d_terminal_copy_addr1),
.out_terminal_copy_rdata0(_w_mem_terminal_copy_rdata0)
);

assign _w_terminalpixel = _w_mem_characterGenerator8x8_rdata[7-_w_xinterminal+:1];
assign _w_yinterminal = (in_pix_y)&7;
assign _w_xinterminal = (in_pix_x)&7;
assign _w_is_cursor = (_w_xterminalpos==_d_terminal_x)&&(((in_pix_y-416)>>3)==_c_terminal_y);
assign _w_yterminalpos = ((in_pix_vblank?0:in_pix_y-416)>>3)*80;
assign _w_xterminalpos = (in_pix_active?in_pix_x+2:0)>>3;

always @* begin
_d_characterGenerator8x8_addr = _q_characterGenerator8x8_addr;
_d_terminal_addr0 = _q_terminal_addr0;
_d_terminal_wenable1 = _q_terminal_wenable1;
_d_terminal_wdata1 = _q_terminal_wdata1;
_d_terminal_addr1 = _q_terminal_addr1;
_d_terminal_copy_addr0 = _q_terminal_copy_addr0;
_d_terminal_copy_wenable1 = _q_terminal_copy_wenable1;
_d_terminal_copy_wdata1 = _q_terminal_copy_wdata1;
_d_terminal_copy_addr1 = _q_terminal_copy_addr1;
_d_terminal_x = _q_terminal_x;
_d_terminal_scroll = _q_terminal_scroll;
_d_terminal_scroll_character = _q_terminal_scroll_character;
_d_pix_red = _q_pix_red;
_d_pix_green = _q_pix_green;
_d_pix_blue = _q_pix_blue;
_d_terminal_display = _q_terminal_display;
_d_terminal_active = _q_terminal_active;
_d_index = _q_index;
// _always_pre
_d_terminal_addr0 = _w_xterminalpos+_w_yterminalpos;
_d_terminal_wenable1 = 1;
_d_terminal_copy_wenable1 = 1;
_d_characterGenerator8x8_addr = _w_mem_terminal_rdata0*8+_w_yinterminal;
_d_terminal_display = in_pix_active&&in_showterminal&&(in_pix_y>415);
_d_pix_red = (_w_terminalpixel)?((_w_is_cursor&&in_timer1hz)?0:3):((_w_is_cursor&&in_timer1hz)?3:0);
_d_pix_green = (_w_terminalpixel)?((_w_is_cursor&&in_timer1hz)?0:3):((_w_is_cursor&&in_timer1hz)?3:0);
_d_pix_blue = 3;
_d_index = 9;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_characterGenerator8x8_addr = 0;
_d_terminal_addr0 = 0;
_d_terminal_wenable1 = 0;
_d_terminal_wdata1 = 0;
_d_terminal_addr1 = 0;
_d_terminal_copy_addr0 = 0;
_d_terminal_copy_wenable1 = 0;
_d_terminal_copy_wdata1 = 0;
_d_terminal_copy_addr1 = 0;
_d_terminal_x = 0;
_d_terminal_scroll = 0;
_d_terminal_scroll_character = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_terminal_write) begin
// __block_5
// __block_7
  case (in_terminal_character)
  8: begin
// __block_9_case
// __block_10
if (_q_terminal_x!=0) begin
// __block_11
// __block_13
_d_terminal_x = _q_terminal_x-1;
_d_terminal_addr1 = _d_terminal_x+_c_terminal_y*80;
_d_terminal_wdata1 = 0;
_d_terminal_copy_addr1 = _d_terminal_x+_c_terminal_y*80;
_d_terminal_copy_wdata1 = 0;
// __block_14
end else begin
// __block_12
end
// __block_15
// __block_16
  end
  10: begin
// __block_17_case
// __block_18
_d_terminal_active = 1;
// __block_19
  end
  13: begin
// __block_20_case
// __block_21
_d_terminal_x = 0;
// __block_22
  end
  default: begin
// __block_23_case
// __block_24
_d_terminal_addr1 = _q_terminal_x+_c_terminal_y*80;
_d_terminal_wdata1 = in_terminal_character;
_d_terminal_copy_addr1 = _q_terminal_x+_c_terminal_y*80;
_d_terminal_copy_wdata1 = in_terminal_character;
_d_terminal_active = (_q_terminal_x==79)?1:0;
_d_terminal_x = (_q_terminal_x==79)?0:_q_terminal_x+1;
// __block_25
  end
endcase
// __block_8
// __block_26
_d_index = 1;
end else begin
// __block_6
// __block_27
if (_q_terminal_active) begin
// __block_28
// __block_30
_d_terminal_scroll = 0;
_d_index = 3;
end else begin
// __block_29
_d_index = 1;
end
end
end else begin
_d_index = 2;
end
end
3: begin
// __block_31
_d_index = 4;
end
2: begin
// __block_3
_d_index = 9;
end
4: begin
// __while__block_32
if (_q_terminal_scroll<560) begin
// __block_33
// __block_35
_d_terminal_copy_addr0 = _q_terminal_scroll+80;
_d_index = 7;
end else begin
_d_index = 5;
end
end
7: begin
// __block_36
_d_terminal_scroll_character = _w_mem_terminal_copy_rdata0;
_d_index = 8;
end
5: begin
// __while__block_39
if (_q_terminal_scroll<640) begin
// __block_40
// __block_42
_d_terminal_addr1 = _q_terminal_scroll;
_d_terminal_wdata1 = 0;
_d_terminal_copy_addr1 = _q_terminal_scroll;
_d_terminal_copy_wdata1 = 0;
_d_terminal_scroll = _q_terminal_scroll+1;
// __block_43
_d_index = 5;
end else begin
_d_index = 6;
end
end
8: begin
// __block_37
_d_terminal_addr1 = _q_terminal_scroll;
_d_terminal_wdata1 = _q_terminal_scroll_character;
_d_terminal_copy_addr1 = _q_terminal_scroll;
_d_terminal_copy_wdata1 = _q_terminal_scroll_character;
_d_terminal_scroll = _q_terminal_scroll+1;
// __block_38
_d_index = 4;
end
6: begin
// __block_41
_d_terminal_active = 0;
// __block_44
_d_index = 1;
end
9: begin // end of terminal
end
default: begin 
_d_index = 9;
 end
endcase
end
endmodule


module M_character_map_mem_characterGenerator8x16(
input                  [11:0] in_characterGenerator8x16_addr,
output reg  [7:0] out_characterGenerator8x16_rdata,
input                                   clock
);
reg  [7:0] buffer[4095:0];
always @(posedge clock) begin
   out_characterGenerator8x16_rdata <= buffer[in_characterGenerator8x16_addr];
end
initial begin
 buffer[0] = 8'h00;
 buffer[1] = 8'h00;
 buffer[2] = 8'h00;
 buffer[3] = 8'h00;
 buffer[4] = 8'h00;
 buffer[5] = 8'h00;
 buffer[6] = 8'h00;
 buffer[7] = 8'h00;
 buffer[8] = 8'h00;
 buffer[9] = 8'h00;
 buffer[10] = 8'h00;
 buffer[11] = 8'h00;
 buffer[12] = 8'h00;
 buffer[13] = 8'h00;
 buffer[14] = 8'h00;
 buffer[15] = 8'h00;
 buffer[16] = 8'h00;
 buffer[17] = 8'h00;
 buffer[18] = 8'h7e;
 buffer[19] = 8'h81;
 buffer[20] = 8'ha5;
 buffer[21] = 8'h81;
 buffer[22] = 8'h81;
 buffer[23] = 8'hbd;
 buffer[24] = 8'h99;
 buffer[25] = 8'h81;
 buffer[26] = 8'h81;
 buffer[27] = 8'h7e;
 buffer[28] = 8'h00;
 buffer[29] = 8'h00;
 buffer[30] = 8'h00;
 buffer[31] = 8'h00;
 buffer[32] = 8'h00;
 buffer[33] = 8'h00;
 buffer[34] = 8'h7e;
 buffer[35] = 8'hff;
 buffer[36] = 8'hdb;
 buffer[37] = 8'hff;
 buffer[38] = 8'hff;
 buffer[39] = 8'hc3;
 buffer[40] = 8'he7;
 buffer[41] = 8'hff;
 buffer[42] = 8'hff;
 buffer[43] = 8'h7e;
 buffer[44] = 8'h00;
 buffer[45] = 8'h00;
 buffer[46] = 8'h00;
 buffer[47] = 8'h00;
 buffer[48] = 8'h00;
 buffer[49] = 8'h00;
 buffer[50] = 8'h00;
 buffer[51] = 8'h00;
 buffer[52] = 8'h6c;
 buffer[53] = 8'hfe;
 buffer[54] = 8'hfe;
 buffer[55] = 8'hfe;
 buffer[56] = 8'hfe;
 buffer[57] = 8'h7c;
 buffer[58] = 8'h38;
 buffer[59] = 8'h10;
 buffer[60] = 8'h00;
 buffer[61] = 8'h00;
 buffer[62] = 8'h00;
 buffer[63] = 8'h00;
 buffer[64] = 8'h00;
 buffer[65] = 8'h00;
 buffer[66] = 8'h00;
 buffer[67] = 8'h00;
 buffer[68] = 8'h10;
 buffer[69] = 8'h38;
 buffer[70] = 8'h7c;
 buffer[71] = 8'hfe;
 buffer[72] = 8'h7c;
 buffer[73] = 8'h38;
 buffer[74] = 8'h10;
 buffer[75] = 8'h00;
 buffer[76] = 8'h00;
 buffer[77] = 8'h00;
 buffer[78] = 8'h00;
 buffer[79] = 8'h00;
 buffer[80] = 8'h00;
 buffer[81] = 8'h00;
 buffer[82] = 8'h00;
 buffer[83] = 8'h18;
 buffer[84] = 8'h3c;
 buffer[85] = 8'h3c;
 buffer[86] = 8'he7;
 buffer[87] = 8'he7;
 buffer[88] = 8'he7;
 buffer[89] = 8'h18;
 buffer[90] = 8'h18;
 buffer[91] = 8'h3c;
 buffer[92] = 8'h00;
 buffer[93] = 8'h00;
 buffer[94] = 8'h00;
 buffer[95] = 8'h00;
 buffer[96] = 8'h00;
 buffer[97] = 8'h00;
 buffer[98] = 8'h00;
 buffer[99] = 8'h18;
 buffer[100] = 8'h3c;
 buffer[101] = 8'h7e;
 buffer[102] = 8'hff;
 buffer[103] = 8'hff;
 buffer[104] = 8'h7e;
 buffer[105] = 8'h18;
 buffer[106] = 8'h18;
 buffer[107] = 8'h3c;
 buffer[108] = 8'h00;
 buffer[109] = 8'h00;
 buffer[110] = 8'h00;
 buffer[111] = 8'h00;
 buffer[112] = 8'h00;
 buffer[113] = 8'h00;
 buffer[114] = 8'h00;
 buffer[115] = 8'h00;
 buffer[116] = 8'h00;
 buffer[117] = 8'h00;
 buffer[118] = 8'h18;
 buffer[119] = 8'h3c;
 buffer[120] = 8'h3c;
 buffer[121] = 8'h18;
 buffer[122] = 8'h00;
 buffer[123] = 8'h00;
 buffer[124] = 8'h00;
 buffer[125] = 8'h00;
 buffer[126] = 8'h00;
 buffer[127] = 8'h00;
 buffer[128] = 8'hff;
 buffer[129] = 8'hff;
 buffer[130] = 8'hff;
 buffer[131] = 8'hff;
 buffer[132] = 8'hff;
 buffer[133] = 8'hff;
 buffer[134] = 8'he7;
 buffer[135] = 8'hc3;
 buffer[136] = 8'hc3;
 buffer[137] = 8'he7;
 buffer[138] = 8'hff;
 buffer[139] = 8'hff;
 buffer[140] = 8'hff;
 buffer[141] = 8'hff;
 buffer[142] = 8'hff;
 buffer[143] = 8'hff;
 buffer[144] = 8'h00;
 buffer[145] = 8'h00;
 buffer[146] = 8'h00;
 buffer[147] = 8'h00;
 buffer[148] = 8'h00;
 buffer[149] = 8'h3c;
 buffer[150] = 8'h66;
 buffer[151] = 8'h42;
 buffer[152] = 8'h42;
 buffer[153] = 8'h66;
 buffer[154] = 8'h3c;
 buffer[155] = 8'h00;
 buffer[156] = 8'h00;
 buffer[157] = 8'h00;
 buffer[158] = 8'h00;
 buffer[159] = 8'h00;
 buffer[160] = 8'hff;
 buffer[161] = 8'hff;
 buffer[162] = 8'hff;
 buffer[163] = 8'hff;
 buffer[164] = 8'hff;
 buffer[165] = 8'hc3;
 buffer[166] = 8'h99;
 buffer[167] = 8'hbd;
 buffer[168] = 8'hbd;
 buffer[169] = 8'h99;
 buffer[170] = 8'hc3;
 buffer[171] = 8'hff;
 buffer[172] = 8'hff;
 buffer[173] = 8'hff;
 buffer[174] = 8'hff;
 buffer[175] = 8'hff;
 buffer[176] = 8'h00;
 buffer[177] = 8'h00;
 buffer[178] = 8'h1e;
 buffer[179] = 8'h0e;
 buffer[180] = 8'h1a;
 buffer[181] = 8'h32;
 buffer[182] = 8'h78;
 buffer[183] = 8'hcc;
 buffer[184] = 8'hcc;
 buffer[185] = 8'hcc;
 buffer[186] = 8'hcc;
 buffer[187] = 8'h78;
 buffer[188] = 8'h00;
 buffer[189] = 8'h00;
 buffer[190] = 8'h00;
 buffer[191] = 8'h00;
 buffer[192] = 8'h00;
 buffer[193] = 8'h00;
 buffer[194] = 8'h3c;
 buffer[195] = 8'h66;
 buffer[196] = 8'h66;
 buffer[197] = 8'h66;
 buffer[198] = 8'h66;
 buffer[199] = 8'h3c;
 buffer[200] = 8'h18;
 buffer[201] = 8'h7e;
 buffer[202] = 8'h18;
 buffer[203] = 8'h18;
 buffer[204] = 8'h00;
 buffer[205] = 8'h00;
 buffer[206] = 8'h00;
 buffer[207] = 8'h00;
 buffer[208] = 8'h00;
 buffer[209] = 8'h00;
 buffer[210] = 8'h3f;
 buffer[211] = 8'h33;
 buffer[212] = 8'h3f;
 buffer[213] = 8'h30;
 buffer[214] = 8'h30;
 buffer[215] = 8'h30;
 buffer[216] = 8'h30;
 buffer[217] = 8'h70;
 buffer[218] = 8'hf0;
 buffer[219] = 8'he0;
 buffer[220] = 8'h00;
 buffer[221] = 8'h00;
 buffer[222] = 8'h00;
 buffer[223] = 8'h00;
 buffer[224] = 8'h00;
 buffer[225] = 8'h00;
 buffer[226] = 8'h7f;
 buffer[227] = 8'h63;
 buffer[228] = 8'h7f;
 buffer[229] = 8'h63;
 buffer[230] = 8'h63;
 buffer[231] = 8'h63;
 buffer[232] = 8'h63;
 buffer[233] = 8'h67;
 buffer[234] = 8'he7;
 buffer[235] = 8'he6;
 buffer[236] = 8'hc0;
 buffer[237] = 8'h00;
 buffer[238] = 8'h00;
 buffer[239] = 8'h00;
 buffer[240] = 8'h00;
 buffer[241] = 8'h00;
 buffer[242] = 8'h00;
 buffer[243] = 8'h18;
 buffer[244] = 8'h18;
 buffer[245] = 8'hdb;
 buffer[246] = 8'h3c;
 buffer[247] = 8'he7;
 buffer[248] = 8'h3c;
 buffer[249] = 8'hdb;
 buffer[250] = 8'h18;
 buffer[251] = 8'h18;
 buffer[252] = 8'h00;
 buffer[253] = 8'h00;
 buffer[254] = 8'h00;
 buffer[255] = 8'h00;
 buffer[256] = 8'h00;
 buffer[257] = 8'h80;
 buffer[258] = 8'hc0;
 buffer[259] = 8'he0;
 buffer[260] = 8'hf0;
 buffer[261] = 8'hf8;
 buffer[262] = 8'hfe;
 buffer[263] = 8'hf8;
 buffer[264] = 8'hf0;
 buffer[265] = 8'he0;
 buffer[266] = 8'hc0;
 buffer[267] = 8'h80;
 buffer[268] = 8'h00;
 buffer[269] = 8'h00;
 buffer[270] = 8'h00;
 buffer[271] = 8'h00;
 buffer[272] = 8'h00;
 buffer[273] = 8'h02;
 buffer[274] = 8'h06;
 buffer[275] = 8'h0e;
 buffer[276] = 8'h1e;
 buffer[277] = 8'h3e;
 buffer[278] = 8'hfe;
 buffer[279] = 8'h3e;
 buffer[280] = 8'h1e;
 buffer[281] = 8'h0e;
 buffer[282] = 8'h06;
 buffer[283] = 8'h02;
 buffer[284] = 8'h00;
 buffer[285] = 8'h00;
 buffer[286] = 8'h00;
 buffer[287] = 8'h00;
 buffer[288] = 8'h00;
 buffer[289] = 8'h00;
 buffer[290] = 8'h18;
 buffer[291] = 8'h3c;
 buffer[292] = 8'h7e;
 buffer[293] = 8'h18;
 buffer[294] = 8'h18;
 buffer[295] = 8'h18;
 buffer[296] = 8'h7e;
 buffer[297] = 8'h3c;
 buffer[298] = 8'h18;
 buffer[299] = 8'h00;
 buffer[300] = 8'h00;
 buffer[301] = 8'h00;
 buffer[302] = 8'h00;
 buffer[303] = 8'h00;
 buffer[304] = 8'h00;
 buffer[305] = 8'h00;
 buffer[306] = 8'h66;
 buffer[307] = 8'h66;
 buffer[308] = 8'h66;
 buffer[309] = 8'h66;
 buffer[310] = 8'h66;
 buffer[311] = 8'h66;
 buffer[312] = 8'h66;
 buffer[313] = 8'h00;
 buffer[314] = 8'h66;
 buffer[315] = 8'h66;
 buffer[316] = 8'h00;
 buffer[317] = 8'h00;
 buffer[318] = 8'h00;
 buffer[319] = 8'h00;
 buffer[320] = 8'h00;
 buffer[321] = 8'h00;
 buffer[322] = 8'h7f;
 buffer[323] = 8'hdb;
 buffer[324] = 8'hdb;
 buffer[325] = 8'hdb;
 buffer[326] = 8'h7b;
 buffer[327] = 8'h1b;
 buffer[328] = 8'h1b;
 buffer[329] = 8'h1b;
 buffer[330] = 8'h1b;
 buffer[331] = 8'h1b;
 buffer[332] = 8'h00;
 buffer[333] = 8'h00;
 buffer[334] = 8'h00;
 buffer[335] = 8'h00;
 buffer[336] = 8'h00;
 buffer[337] = 8'h7c;
 buffer[338] = 8'hc6;
 buffer[339] = 8'h60;
 buffer[340] = 8'h38;
 buffer[341] = 8'h6c;
 buffer[342] = 8'hc6;
 buffer[343] = 8'hc6;
 buffer[344] = 8'h6c;
 buffer[345] = 8'h38;
 buffer[346] = 8'h0c;
 buffer[347] = 8'hc6;
 buffer[348] = 8'h7c;
 buffer[349] = 8'h00;
 buffer[350] = 8'h00;
 buffer[351] = 8'h00;
 buffer[352] = 8'h00;
 buffer[353] = 8'h00;
 buffer[354] = 8'h00;
 buffer[355] = 8'h00;
 buffer[356] = 8'h00;
 buffer[357] = 8'h00;
 buffer[358] = 8'h00;
 buffer[359] = 8'h00;
 buffer[360] = 8'hfe;
 buffer[361] = 8'hfe;
 buffer[362] = 8'hfe;
 buffer[363] = 8'hfe;
 buffer[364] = 8'h00;
 buffer[365] = 8'h00;
 buffer[366] = 8'h00;
 buffer[367] = 8'h00;
 buffer[368] = 8'h00;
 buffer[369] = 8'h00;
 buffer[370] = 8'h18;
 buffer[371] = 8'h3c;
 buffer[372] = 8'h7e;
 buffer[373] = 8'h18;
 buffer[374] = 8'h18;
 buffer[375] = 8'h18;
 buffer[376] = 8'h7e;
 buffer[377] = 8'h3c;
 buffer[378] = 8'h18;
 buffer[379] = 8'h7e;
 buffer[380] = 8'h00;
 buffer[381] = 8'h00;
 buffer[382] = 8'h00;
 buffer[383] = 8'h00;
 buffer[384] = 8'h00;
 buffer[385] = 8'h00;
 buffer[386] = 8'h18;
 buffer[387] = 8'h3c;
 buffer[388] = 8'h7e;
 buffer[389] = 8'h18;
 buffer[390] = 8'h18;
 buffer[391] = 8'h18;
 buffer[392] = 8'h18;
 buffer[393] = 8'h18;
 buffer[394] = 8'h18;
 buffer[395] = 8'h18;
 buffer[396] = 8'h00;
 buffer[397] = 8'h00;
 buffer[398] = 8'h00;
 buffer[399] = 8'h00;
 buffer[400] = 8'h00;
 buffer[401] = 8'h00;
 buffer[402] = 8'h18;
 buffer[403] = 8'h18;
 buffer[404] = 8'h18;
 buffer[405] = 8'h18;
 buffer[406] = 8'h18;
 buffer[407] = 8'h18;
 buffer[408] = 8'h18;
 buffer[409] = 8'h7e;
 buffer[410] = 8'h3c;
 buffer[411] = 8'h18;
 buffer[412] = 8'h00;
 buffer[413] = 8'h00;
 buffer[414] = 8'h00;
 buffer[415] = 8'h00;
 buffer[416] = 8'h00;
 buffer[417] = 8'h00;
 buffer[418] = 8'h00;
 buffer[419] = 8'h00;
 buffer[420] = 8'h00;
 buffer[421] = 8'h18;
 buffer[422] = 8'h0c;
 buffer[423] = 8'hfe;
 buffer[424] = 8'h0c;
 buffer[425] = 8'h18;
 buffer[426] = 8'h00;
 buffer[427] = 8'h00;
 buffer[428] = 8'h00;
 buffer[429] = 8'h00;
 buffer[430] = 8'h00;
 buffer[431] = 8'h00;
 buffer[432] = 8'h00;
 buffer[433] = 8'h00;
 buffer[434] = 8'h00;
 buffer[435] = 8'h00;
 buffer[436] = 8'h00;
 buffer[437] = 8'h30;
 buffer[438] = 8'h60;
 buffer[439] = 8'hfe;
 buffer[440] = 8'h60;
 buffer[441] = 8'h30;
 buffer[442] = 8'h00;
 buffer[443] = 8'h00;
 buffer[444] = 8'h00;
 buffer[445] = 8'h00;
 buffer[446] = 8'h00;
 buffer[447] = 8'h00;
 buffer[448] = 8'h00;
 buffer[449] = 8'h00;
 buffer[450] = 8'h00;
 buffer[451] = 8'h00;
 buffer[452] = 8'h00;
 buffer[453] = 8'h00;
 buffer[454] = 8'hc0;
 buffer[455] = 8'hc0;
 buffer[456] = 8'hc0;
 buffer[457] = 8'hfe;
 buffer[458] = 8'h00;
 buffer[459] = 8'h00;
 buffer[460] = 8'h00;
 buffer[461] = 8'h00;
 buffer[462] = 8'h00;
 buffer[463] = 8'h00;
 buffer[464] = 8'h00;
 buffer[465] = 8'h00;
 buffer[466] = 8'h00;
 buffer[467] = 8'h00;
 buffer[468] = 8'h00;
 buffer[469] = 8'h28;
 buffer[470] = 8'h6c;
 buffer[471] = 8'hfe;
 buffer[472] = 8'h6c;
 buffer[473] = 8'h28;
 buffer[474] = 8'h00;
 buffer[475] = 8'h00;
 buffer[476] = 8'h00;
 buffer[477] = 8'h00;
 buffer[478] = 8'h00;
 buffer[479] = 8'h00;
 buffer[480] = 8'h00;
 buffer[481] = 8'h00;
 buffer[482] = 8'h00;
 buffer[483] = 8'h00;
 buffer[484] = 8'h10;
 buffer[485] = 8'h38;
 buffer[486] = 8'h38;
 buffer[487] = 8'h7c;
 buffer[488] = 8'h7c;
 buffer[489] = 8'hfe;
 buffer[490] = 8'hfe;
 buffer[491] = 8'h00;
 buffer[492] = 8'h00;
 buffer[493] = 8'h00;
 buffer[494] = 8'h00;
 buffer[495] = 8'h00;
 buffer[496] = 8'h00;
 buffer[497] = 8'h00;
 buffer[498] = 8'h00;
 buffer[499] = 8'h00;
 buffer[500] = 8'hfe;
 buffer[501] = 8'hfe;
 buffer[502] = 8'h7c;
 buffer[503] = 8'h7c;
 buffer[504] = 8'h38;
 buffer[505] = 8'h38;
 buffer[506] = 8'h10;
 buffer[507] = 8'h00;
 buffer[508] = 8'h00;
 buffer[509] = 8'h00;
 buffer[510] = 8'h00;
 buffer[511] = 8'h00;
 buffer[512] = 8'h00;
 buffer[513] = 8'h00;
 buffer[514] = 8'h00;
 buffer[515] = 8'h00;
 buffer[516] = 8'h00;
 buffer[517] = 8'h00;
 buffer[518] = 8'h00;
 buffer[519] = 8'h00;
 buffer[520] = 8'h00;
 buffer[521] = 8'h00;
 buffer[522] = 8'h00;
 buffer[523] = 8'h00;
 buffer[524] = 8'h00;
 buffer[525] = 8'h00;
 buffer[526] = 8'h00;
 buffer[527] = 8'h00;
 buffer[528] = 8'h00;
 buffer[529] = 8'h00;
 buffer[530] = 8'h18;
 buffer[531] = 8'h3c;
 buffer[532] = 8'h3c;
 buffer[533] = 8'h3c;
 buffer[534] = 8'h18;
 buffer[535] = 8'h18;
 buffer[536] = 8'h18;
 buffer[537] = 8'h00;
 buffer[538] = 8'h18;
 buffer[539] = 8'h18;
 buffer[540] = 8'h00;
 buffer[541] = 8'h00;
 buffer[542] = 8'h00;
 buffer[543] = 8'h00;
 buffer[544] = 8'h00;
 buffer[545] = 8'h66;
 buffer[546] = 8'h66;
 buffer[547] = 8'h66;
 buffer[548] = 8'h24;
 buffer[549] = 8'h00;
 buffer[550] = 8'h00;
 buffer[551] = 8'h00;
 buffer[552] = 8'h00;
 buffer[553] = 8'h00;
 buffer[554] = 8'h00;
 buffer[555] = 8'h00;
 buffer[556] = 8'h00;
 buffer[557] = 8'h00;
 buffer[558] = 8'h00;
 buffer[559] = 8'h00;
 buffer[560] = 8'h00;
 buffer[561] = 8'h00;
 buffer[562] = 8'h00;
 buffer[563] = 8'h6c;
 buffer[564] = 8'h6c;
 buffer[565] = 8'hfe;
 buffer[566] = 8'h6c;
 buffer[567] = 8'h6c;
 buffer[568] = 8'h6c;
 buffer[569] = 8'hfe;
 buffer[570] = 8'h6c;
 buffer[571] = 8'h6c;
 buffer[572] = 8'h00;
 buffer[573] = 8'h00;
 buffer[574] = 8'h00;
 buffer[575] = 8'h00;
 buffer[576] = 8'h18;
 buffer[577] = 8'h18;
 buffer[578] = 8'h7c;
 buffer[579] = 8'hc6;
 buffer[580] = 8'hc2;
 buffer[581] = 8'hc0;
 buffer[582] = 8'h7c;
 buffer[583] = 8'h06;
 buffer[584] = 8'h06;
 buffer[585] = 8'h86;
 buffer[586] = 8'hc6;
 buffer[587] = 8'h7c;
 buffer[588] = 8'h18;
 buffer[589] = 8'h18;
 buffer[590] = 8'h00;
 buffer[591] = 8'h00;
 buffer[592] = 8'h00;
 buffer[593] = 8'h00;
 buffer[594] = 8'h00;
 buffer[595] = 8'h00;
 buffer[596] = 8'hc2;
 buffer[597] = 8'hc6;
 buffer[598] = 8'h0c;
 buffer[599] = 8'h18;
 buffer[600] = 8'h30;
 buffer[601] = 8'h60;
 buffer[602] = 8'hc6;
 buffer[603] = 8'h86;
 buffer[604] = 8'h00;
 buffer[605] = 8'h00;
 buffer[606] = 8'h00;
 buffer[607] = 8'h00;
 buffer[608] = 8'h00;
 buffer[609] = 8'h00;
 buffer[610] = 8'h38;
 buffer[611] = 8'h6c;
 buffer[612] = 8'h6c;
 buffer[613] = 8'h38;
 buffer[614] = 8'h76;
 buffer[615] = 8'hdc;
 buffer[616] = 8'hcc;
 buffer[617] = 8'hcc;
 buffer[618] = 8'hcc;
 buffer[619] = 8'h76;
 buffer[620] = 8'h00;
 buffer[621] = 8'h00;
 buffer[622] = 8'h00;
 buffer[623] = 8'h00;
 buffer[624] = 8'h00;
 buffer[625] = 8'h30;
 buffer[626] = 8'h30;
 buffer[627] = 8'h30;
 buffer[628] = 8'h60;
 buffer[629] = 8'h00;
 buffer[630] = 8'h00;
 buffer[631] = 8'h00;
 buffer[632] = 8'h00;
 buffer[633] = 8'h00;
 buffer[634] = 8'h00;
 buffer[635] = 8'h00;
 buffer[636] = 8'h00;
 buffer[637] = 8'h00;
 buffer[638] = 8'h00;
 buffer[639] = 8'h00;
 buffer[640] = 8'h00;
 buffer[641] = 8'h00;
 buffer[642] = 8'h0c;
 buffer[643] = 8'h18;
 buffer[644] = 8'h30;
 buffer[645] = 8'h30;
 buffer[646] = 8'h30;
 buffer[647] = 8'h30;
 buffer[648] = 8'h30;
 buffer[649] = 8'h30;
 buffer[650] = 8'h18;
 buffer[651] = 8'h0c;
 buffer[652] = 8'h00;
 buffer[653] = 8'h00;
 buffer[654] = 8'h00;
 buffer[655] = 8'h00;
 buffer[656] = 8'h00;
 buffer[657] = 8'h00;
 buffer[658] = 8'h30;
 buffer[659] = 8'h18;
 buffer[660] = 8'h0c;
 buffer[661] = 8'h0c;
 buffer[662] = 8'h0c;
 buffer[663] = 8'h0c;
 buffer[664] = 8'h0c;
 buffer[665] = 8'h0c;
 buffer[666] = 8'h18;
 buffer[667] = 8'h30;
 buffer[668] = 8'h00;
 buffer[669] = 8'h00;
 buffer[670] = 8'h00;
 buffer[671] = 8'h00;
 buffer[672] = 8'h00;
 buffer[673] = 8'h00;
 buffer[674] = 8'h00;
 buffer[675] = 8'h00;
 buffer[676] = 8'h00;
 buffer[677] = 8'h66;
 buffer[678] = 8'h3c;
 buffer[679] = 8'hff;
 buffer[680] = 8'h3c;
 buffer[681] = 8'h66;
 buffer[682] = 8'h00;
 buffer[683] = 8'h00;
 buffer[684] = 8'h00;
 buffer[685] = 8'h00;
 buffer[686] = 8'h00;
 buffer[687] = 8'h00;
 buffer[688] = 8'h00;
 buffer[689] = 8'h00;
 buffer[690] = 8'h00;
 buffer[691] = 8'h00;
 buffer[692] = 8'h00;
 buffer[693] = 8'h18;
 buffer[694] = 8'h18;
 buffer[695] = 8'h7e;
 buffer[696] = 8'h18;
 buffer[697] = 8'h18;
 buffer[698] = 8'h00;
 buffer[699] = 8'h00;
 buffer[700] = 8'h00;
 buffer[701] = 8'h00;
 buffer[702] = 8'h00;
 buffer[703] = 8'h00;
 buffer[704] = 8'h00;
 buffer[705] = 8'h00;
 buffer[706] = 8'h00;
 buffer[707] = 8'h00;
 buffer[708] = 8'h00;
 buffer[709] = 8'h00;
 buffer[710] = 8'h00;
 buffer[711] = 8'h00;
 buffer[712] = 8'h00;
 buffer[713] = 8'h18;
 buffer[714] = 8'h18;
 buffer[715] = 8'h18;
 buffer[716] = 8'h30;
 buffer[717] = 8'h00;
 buffer[718] = 8'h00;
 buffer[719] = 8'h00;
 buffer[720] = 8'h00;
 buffer[721] = 8'h00;
 buffer[722] = 8'h00;
 buffer[723] = 8'h00;
 buffer[724] = 8'h00;
 buffer[725] = 8'h00;
 buffer[726] = 8'h00;
 buffer[727] = 8'hfe;
 buffer[728] = 8'h00;
 buffer[729] = 8'h00;
 buffer[730] = 8'h00;
 buffer[731] = 8'h00;
 buffer[732] = 8'h00;
 buffer[733] = 8'h00;
 buffer[734] = 8'h00;
 buffer[735] = 8'h00;
 buffer[736] = 8'h00;
 buffer[737] = 8'h00;
 buffer[738] = 8'h00;
 buffer[739] = 8'h00;
 buffer[740] = 8'h00;
 buffer[741] = 8'h00;
 buffer[742] = 8'h00;
 buffer[743] = 8'h00;
 buffer[744] = 8'h00;
 buffer[745] = 8'h00;
 buffer[746] = 8'h18;
 buffer[747] = 8'h18;
 buffer[748] = 8'h00;
 buffer[749] = 8'h00;
 buffer[750] = 8'h00;
 buffer[751] = 8'h00;
 buffer[752] = 8'h00;
 buffer[753] = 8'h00;
 buffer[754] = 8'h00;
 buffer[755] = 8'h00;
 buffer[756] = 8'h02;
 buffer[757] = 8'h06;
 buffer[758] = 8'h0c;
 buffer[759] = 8'h18;
 buffer[760] = 8'h30;
 buffer[761] = 8'h60;
 buffer[762] = 8'hc0;
 buffer[763] = 8'h80;
 buffer[764] = 8'h00;
 buffer[765] = 8'h00;
 buffer[766] = 8'h00;
 buffer[767] = 8'h00;
 buffer[768] = 8'h00;
 buffer[769] = 8'h00;
 buffer[770] = 8'h38;
 buffer[771] = 8'h6c;
 buffer[772] = 8'hc6;
 buffer[773] = 8'hc6;
 buffer[774] = 8'hd6;
 buffer[775] = 8'hd6;
 buffer[776] = 8'hc6;
 buffer[777] = 8'hc6;
 buffer[778] = 8'h6c;
 buffer[779] = 8'h38;
 buffer[780] = 8'h00;
 buffer[781] = 8'h00;
 buffer[782] = 8'h00;
 buffer[783] = 8'h00;
 buffer[784] = 8'h00;
 buffer[785] = 8'h00;
 buffer[786] = 8'h18;
 buffer[787] = 8'h38;
 buffer[788] = 8'h78;
 buffer[789] = 8'h18;
 buffer[790] = 8'h18;
 buffer[791] = 8'h18;
 buffer[792] = 8'h18;
 buffer[793] = 8'h18;
 buffer[794] = 8'h18;
 buffer[795] = 8'h7e;
 buffer[796] = 8'h00;
 buffer[797] = 8'h00;
 buffer[798] = 8'h00;
 buffer[799] = 8'h00;
 buffer[800] = 8'h00;
 buffer[801] = 8'h00;
 buffer[802] = 8'h7c;
 buffer[803] = 8'hc6;
 buffer[804] = 8'h06;
 buffer[805] = 8'h0c;
 buffer[806] = 8'h18;
 buffer[807] = 8'h30;
 buffer[808] = 8'h60;
 buffer[809] = 8'hc0;
 buffer[810] = 8'hc6;
 buffer[811] = 8'hfe;
 buffer[812] = 8'h00;
 buffer[813] = 8'h00;
 buffer[814] = 8'h00;
 buffer[815] = 8'h00;
 buffer[816] = 8'h00;
 buffer[817] = 8'h00;
 buffer[818] = 8'h7c;
 buffer[819] = 8'hc6;
 buffer[820] = 8'h06;
 buffer[821] = 8'h06;
 buffer[822] = 8'h3c;
 buffer[823] = 8'h06;
 buffer[824] = 8'h06;
 buffer[825] = 8'h06;
 buffer[826] = 8'hc6;
 buffer[827] = 8'h7c;
 buffer[828] = 8'h00;
 buffer[829] = 8'h00;
 buffer[830] = 8'h00;
 buffer[831] = 8'h00;
 buffer[832] = 8'h00;
 buffer[833] = 8'h00;
 buffer[834] = 8'h0c;
 buffer[835] = 8'h1c;
 buffer[836] = 8'h3c;
 buffer[837] = 8'h6c;
 buffer[838] = 8'hcc;
 buffer[839] = 8'hfe;
 buffer[840] = 8'h0c;
 buffer[841] = 8'h0c;
 buffer[842] = 8'h0c;
 buffer[843] = 8'h1e;
 buffer[844] = 8'h00;
 buffer[845] = 8'h00;
 buffer[846] = 8'h00;
 buffer[847] = 8'h00;
 buffer[848] = 8'h00;
 buffer[849] = 8'h00;
 buffer[850] = 8'hfe;
 buffer[851] = 8'hc0;
 buffer[852] = 8'hc0;
 buffer[853] = 8'hc0;
 buffer[854] = 8'hfc;
 buffer[855] = 8'h06;
 buffer[856] = 8'h06;
 buffer[857] = 8'h06;
 buffer[858] = 8'hc6;
 buffer[859] = 8'h7c;
 buffer[860] = 8'h00;
 buffer[861] = 8'h00;
 buffer[862] = 8'h00;
 buffer[863] = 8'h00;
 buffer[864] = 8'h00;
 buffer[865] = 8'h00;
 buffer[866] = 8'h38;
 buffer[867] = 8'h60;
 buffer[868] = 8'hc0;
 buffer[869] = 8'hc0;
 buffer[870] = 8'hfc;
 buffer[871] = 8'hc6;
 buffer[872] = 8'hc6;
 buffer[873] = 8'hc6;
 buffer[874] = 8'hc6;
 buffer[875] = 8'h7c;
 buffer[876] = 8'h00;
 buffer[877] = 8'h00;
 buffer[878] = 8'h00;
 buffer[879] = 8'h00;
 buffer[880] = 8'h00;
 buffer[881] = 8'h00;
 buffer[882] = 8'hfe;
 buffer[883] = 8'hc6;
 buffer[884] = 8'h06;
 buffer[885] = 8'h06;
 buffer[886] = 8'h0c;
 buffer[887] = 8'h18;
 buffer[888] = 8'h30;
 buffer[889] = 8'h30;
 buffer[890] = 8'h30;
 buffer[891] = 8'h30;
 buffer[892] = 8'h00;
 buffer[893] = 8'h00;
 buffer[894] = 8'h00;
 buffer[895] = 8'h00;
 buffer[896] = 8'h00;
 buffer[897] = 8'h00;
 buffer[898] = 8'h7c;
 buffer[899] = 8'hc6;
 buffer[900] = 8'hc6;
 buffer[901] = 8'hc6;
 buffer[902] = 8'h7c;
 buffer[903] = 8'hc6;
 buffer[904] = 8'hc6;
 buffer[905] = 8'hc6;
 buffer[906] = 8'hc6;
 buffer[907] = 8'h7c;
 buffer[908] = 8'h00;
 buffer[909] = 8'h00;
 buffer[910] = 8'h00;
 buffer[911] = 8'h00;
 buffer[912] = 8'h00;
 buffer[913] = 8'h00;
 buffer[914] = 8'h7c;
 buffer[915] = 8'hc6;
 buffer[916] = 8'hc6;
 buffer[917] = 8'hc6;
 buffer[918] = 8'h7e;
 buffer[919] = 8'h06;
 buffer[920] = 8'h06;
 buffer[921] = 8'h06;
 buffer[922] = 8'h0c;
 buffer[923] = 8'h78;
 buffer[924] = 8'h00;
 buffer[925] = 8'h00;
 buffer[926] = 8'h00;
 buffer[927] = 8'h00;
 buffer[928] = 8'h00;
 buffer[929] = 8'h00;
 buffer[930] = 8'h00;
 buffer[931] = 8'h00;
 buffer[932] = 8'h18;
 buffer[933] = 8'h18;
 buffer[934] = 8'h00;
 buffer[935] = 8'h00;
 buffer[936] = 8'h00;
 buffer[937] = 8'h18;
 buffer[938] = 8'h18;
 buffer[939] = 8'h00;
 buffer[940] = 8'h00;
 buffer[941] = 8'h00;
 buffer[942] = 8'h00;
 buffer[943] = 8'h00;
 buffer[944] = 8'h00;
 buffer[945] = 8'h00;
 buffer[946] = 8'h00;
 buffer[947] = 8'h00;
 buffer[948] = 8'h18;
 buffer[949] = 8'h18;
 buffer[950] = 8'h00;
 buffer[951] = 8'h00;
 buffer[952] = 8'h00;
 buffer[953] = 8'h18;
 buffer[954] = 8'h18;
 buffer[955] = 8'h30;
 buffer[956] = 8'h00;
 buffer[957] = 8'h00;
 buffer[958] = 8'h00;
 buffer[959] = 8'h00;
 buffer[960] = 8'h00;
 buffer[961] = 8'h00;
 buffer[962] = 8'h00;
 buffer[963] = 8'h06;
 buffer[964] = 8'h0c;
 buffer[965] = 8'h18;
 buffer[966] = 8'h30;
 buffer[967] = 8'h60;
 buffer[968] = 8'h30;
 buffer[969] = 8'h18;
 buffer[970] = 8'h0c;
 buffer[971] = 8'h06;
 buffer[972] = 8'h00;
 buffer[973] = 8'h00;
 buffer[974] = 8'h00;
 buffer[975] = 8'h00;
 buffer[976] = 8'h00;
 buffer[977] = 8'h00;
 buffer[978] = 8'h00;
 buffer[979] = 8'h00;
 buffer[980] = 8'h00;
 buffer[981] = 8'h7e;
 buffer[982] = 8'h00;
 buffer[983] = 8'h00;
 buffer[984] = 8'h7e;
 buffer[985] = 8'h00;
 buffer[986] = 8'h00;
 buffer[987] = 8'h00;
 buffer[988] = 8'h00;
 buffer[989] = 8'h00;
 buffer[990] = 8'h00;
 buffer[991] = 8'h00;
 buffer[992] = 8'h00;
 buffer[993] = 8'h00;
 buffer[994] = 8'h00;
 buffer[995] = 8'h60;
 buffer[996] = 8'h30;
 buffer[997] = 8'h18;
 buffer[998] = 8'h0c;
 buffer[999] = 8'h06;
 buffer[1000] = 8'h0c;
 buffer[1001] = 8'h18;
 buffer[1002] = 8'h30;
 buffer[1003] = 8'h60;
 buffer[1004] = 8'h00;
 buffer[1005] = 8'h00;
 buffer[1006] = 8'h00;
 buffer[1007] = 8'h00;
 buffer[1008] = 8'h00;
 buffer[1009] = 8'h00;
 buffer[1010] = 8'h7c;
 buffer[1011] = 8'hc6;
 buffer[1012] = 8'hc6;
 buffer[1013] = 8'h0c;
 buffer[1014] = 8'h18;
 buffer[1015] = 8'h18;
 buffer[1016] = 8'h18;
 buffer[1017] = 8'h00;
 buffer[1018] = 8'h18;
 buffer[1019] = 8'h18;
 buffer[1020] = 8'h00;
 buffer[1021] = 8'h00;
 buffer[1022] = 8'h00;
 buffer[1023] = 8'h00;
 buffer[1024] = 8'h00;
 buffer[1025] = 8'h00;
 buffer[1026] = 8'h00;
 buffer[1027] = 8'h7c;
 buffer[1028] = 8'hc6;
 buffer[1029] = 8'hc6;
 buffer[1030] = 8'hde;
 buffer[1031] = 8'hde;
 buffer[1032] = 8'hde;
 buffer[1033] = 8'hdc;
 buffer[1034] = 8'hc0;
 buffer[1035] = 8'h7c;
 buffer[1036] = 8'h00;
 buffer[1037] = 8'h00;
 buffer[1038] = 8'h00;
 buffer[1039] = 8'h00;
 buffer[1040] = 8'h00;
 buffer[1041] = 8'h00;
 buffer[1042] = 8'h10;
 buffer[1043] = 8'h38;
 buffer[1044] = 8'h6c;
 buffer[1045] = 8'hc6;
 buffer[1046] = 8'hc6;
 buffer[1047] = 8'hfe;
 buffer[1048] = 8'hc6;
 buffer[1049] = 8'hc6;
 buffer[1050] = 8'hc6;
 buffer[1051] = 8'hc6;
 buffer[1052] = 8'h00;
 buffer[1053] = 8'h00;
 buffer[1054] = 8'h00;
 buffer[1055] = 8'h00;
 buffer[1056] = 8'h00;
 buffer[1057] = 8'h00;
 buffer[1058] = 8'hfc;
 buffer[1059] = 8'h66;
 buffer[1060] = 8'h66;
 buffer[1061] = 8'h66;
 buffer[1062] = 8'h7c;
 buffer[1063] = 8'h66;
 buffer[1064] = 8'h66;
 buffer[1065] = 8'h66;
 buffer[1066] = 8'h66;
 buffer[1067] = 8'hfc;
 buffer[1068] = 8'h00;
 buffer[1069] = 8'h00;
 buffer[1070] = 8'h00;
 buffer[1071] = 8'h00;
 buffer[1072] = 8'h00;
 buffer[1073] = 8'h00;
 buffer[1074] = 8'h3c;
 buffer[1075] = 8'h66;
 buffer[1076] = 8'hc2;
 buffer[1077] = 8'hc0;
 buffer[1078] = 8'hc0;
 buffer[1079] = 8'hc0;
 buffer[1080] = 8'hc0;
 buffer[1081] = 8'hc2;
 buffer[1082] = 8'h66;
 buffer[1083] = 8'h3c;
 buffer[1084] = 8'h00;
 buffer[1085] = 8'h00;
 buffer[1086] = 8'h00;
 buffer[1087] = 8'h00;
 buffer[1088] = 8'h00;
 buffer[1089] = 8'h00;
 buffer[1090] = 8'hf8;
 buffer[1091] = 8'h6c;
 buffer[1092] = 8'h66;
 buffer[1093] = 8'h66;
 buffer[1094] = 8'h66;
 buffer[1095] = 8'h66;
 buffer[1096] = 8'h66;
 buffer[1097] = 8'h66;
 buffer[1098] = 8'h6c;
 buffer[1099] = 8'hf8;
 buffer[1100] = 8'h00;
 buffer[1101] = 8'h00;
 buffer[1102] = 8'h00;
 buffer[1103] = 8'h00;
 buffer[1104] = 8'h00;
 buffer[1105] = 8'h00;
 buffer[1106] = 8'hfe;
 buffer[1107] = 8'h66;
 buffer[1108] = 8'h62;
 buffer[1109] = 8'h68;
 buffer[1110] = 8'h78;
 buffer[1111] = 8'h68;
 buffer[1112] = 8'h60;
 buffer[1113] = 8'h62;
 buffer[1114] = 8'h66;
 buffer[1115] = 8'hfe;
 buffer[1116] = 8'h00;
 buffer[1117] = 8'h00;
 buffer[1118] = 8'h00;
 buffer[1119] = 8'h00;
 buffer[1120] = 8'h00;
 buffer[1121] = 8'h00;
 buffer[1122] = 8'hfe;
 buffer[1123] = 8'h66;
 buffer[1124] = 8'h62;
 buffer[1125] = 8'h68;
 buffer[1126] = 8'h78;
 buffer[1127] = 8'h68;
 buffer[1128] = 8'h60;
 buffer[1129] = 8'h60;
 buffer[1130] = 8'h60;
 buffer[1131] = 8'hf0;
 buffer[1132] = 8'h00;
 buffer[1133] = 8'h00;
 buffer[1134] = 8'h00;
 buffer[1135] = 8'h00;
 buffer[1136] = 8'h00;
 buffer[1137] = 8'h00;
 buffer[1138] = 8'h3c;
 buffer[1139] = 8'h66;
 buffer[1140] = 8'hc2;
 buffer[1141] = 8'hc0;
 buffer[1142] = 8'hc0;
 buffer[1143] = 8'hde;
 buffer[1144] = 8'hc6;
 buffer[1145] = 8'hc6;
 buffer[1146] = 8'h66;
 buffer[1147] = 8'h3a;
 buffer[1148] = 8'h00;
 buffer[1149] = 8'h00;
 buffer[1150] = 8'h00;
 buffer[1151] = 8'h00;
 buffer[1152] = 8'h00;
 buffer[1153] = 8'h00;
 buffer[1154] = 8'hc6;
 buffer[1155] = 8'hc6;
 buffer[1156] = 8'hc6;
 buffer[1157] = 8'hc6;
 buffer[1158] = 8'hfe;
 buffer[1159] = 8'hc6;
 buffer[1160] = 8'hc6;
 buffer[1161] = 8'hc6;
 buffer[1162] = 8'hc6;
 buffer[1163] = 8'hc6;
 buffer[1164] = 8'h00;
 buffer[1165] = 8'h00;
 buffer[1166] = 8'h00;
 buffer[1167] = 8'h00;
 buffer[1168] = 8'h00;
 buffer[1169] = 8'h00;
 buffer[1170] = 8'h3c;
 buffer[1171] = 8'h18;
 buffer[1172] = 8'h18;
 buffer[1173] = 8'h18;
 buffer[1174] = 8'h18;
 buffer[1175] = 8'h18;
 buffer[1176] = 8'h18;
 buffer[1177] = 8'h18;
 buffer[1178] = 8'h18;
 buffer[1179] = 8'h3c;
 buffer[1180] = 8'h00;
 buffer[1181] = 8'h00;
 buffer[1182] = 8'h00;
 buffer[1183] = 8'h00;
 buffer[1184] = 8'h00;
 buffer[1185] = 8'h00;
 buffer[1186] = 8'h1e;
 buffer[1187] = 8'h0c;
 buffer[1188] = 8'h0c;
 buffer[1189] = 8'h0c;
 buffer[1190] = 8'h0c;
 buffer[1191] = 8'h0c;
 buffer[1192] = 8'hcc;
 buffer[1193] = 8'hcc;
 buffer[1194] = 8'hcc;
 buffer[1195] = 8'h78;
 buffer[1196] = 8'h00;
 buffer[1197] = 8'h00;
 buffer[1198] = 8'h00;
 buffer[1199] = 8'h00;
 buffer[1200] = 8'h00;
 buffer[1201] = 8'h00;
 buffer[1202] = 8'he6;
 buffer[1203] = 8'h66;
 buffer[1204] = 8'h66;
 buffer[1205] = 8'h6c;
 buffer[1206] = 8'h78;
 buffer[1207] = 8'h78;
 buffer[1208] = 8'h6c;
 buffer[1209] = 8'h66;
 buffer[1210] = 8'h66;
 buffer[1211] = 8'he6;
 buffer[1212] = 8'h00;
 buffer[1213] = 8'h00;
 buffer[1214] = 8'h00;
 buffer[1215] = 8'h00;
 buffer[1216] = 8'h00;
 buffer[1217] = 8'h00;
 buffer[1218] = 8'hf0;
 buffer[1219] = 8'h60;
 buffer[1220] = 8'h60;
 buffer[1221] = 8'h60;
 buffer[1222] = 8'h60;
 buffer[1223] = 8'h60;
 buffer[1224] = 8'h60;
 buffer[1225] = 8'h62;
 buffer[1226] = 8'h66;
 buffer[1227] = 8'hfe;
 buffer[1228] = 8'h00;
 buffer[1229] = 8'h00;
 buffer[1230] = 8'h00;
 buffer[1231] = 8'h00;
 buffer[1232] = 8'h00;
 buffer[1233] = 8'h00;
 buffer[1234] = 8'hc6;
 buffer[1235] = 8'hee;
 buffer[1236] = 8'hfe;
 buffer[1237] = 8'hfe;
 buffer[1238] = 8'hd6;
 buffer[1239] = 8'hc6;
 buffer[1240] = 8'hc6;
 buffer[1241] = 8'hc6;
 buffer[1242] = 8'hc6;
 buffer[1243] = 8'hc6;
 buffer[1244] = 8'h00;
 buffer[1245] = 8'h00;
 buffer[1246] = 8'h00;
 buffer[1247] = 8'h00;
 buffer[1248] = 8'h00;
 buffer[1249] = 8'h00;
 buffer[1250] = 8'hc6;
 buffer[1251] = 8'he6;
 buffer[1252] = 8'hf6;
 buffer[1253] = 8'hfe;
 buffer[1254] = 8'hde;
 buffer[1255] = 8'hce;
 buffer[1256] = 8'hc6;
 buffer[1257] = 8'hc6;
 buffer[1258] = 8'hc6;
 buffer[1259] = 8'hc6;
 buffer[1260] = 8'h00;
 buffer[1261] = 8'h00;
 buffer[1262] = 8'h00;
 buffer[1263] = 8'h00;
 buffer[1264] = 8'h00;
 buffer[1265] = 8'h00;
 buffer[1266] = 8'h7c;
 buffer[1267] = 8'hc6;
 buffer[1268] = 8'hc6;
 buffer[1269] = 8'hc6;
 buffer[1270] = 8'hc6;
 buffer[1271] = 8'hc6;
 buffer[1272] = 8'hc6;
 buffer[1273] = 8'hc6;
 buffer[1274] = 8'hc6;
 buffer[1275] = 8'h7c;
 buffer[1276] = 8'h00;
 buffer[1277] = 8'h00;
 buffer[1278] = 8'h00;
 buffer[1279] = 8'h00;
 buffer[1280] = 8'h00;
 buffer[1281] = 8'h00;
 buffer[1282] = 8'hfc;
 buffer[1283] = 8'h66;
 buffer[1284] = 8'h66;
 buffer[1285] = 8'h66;
 buffer[1286] = 8'h7c;
 buffer[1287] = 8'h60;
 buffer[1288] = 8'h60;
 buffer[1289] = 8'h60;
 buffer[1290] = 8'h60;
 buffer[1291] = 8'hf0;
 buffer[1292] = 8'h00;
 buffer[1293] = 8'h00;
 buffer[1294] = 8'h00;
 buffer[1295] = 8'h00;
 buffer[1296] = 8'h00;
 buffer[1297] = 8'h00;
 buffer[1298] = 8'h7c;
 buffer[1299] = 8'hc6;
 buffer[1300] = 8'hc6;
 buffer[1301] = 8'hc6;
 buffer[1302] = 8'hc6;
 buffer[1303] = 8'hc6;
 buffer[1304] = 8'hc6;
 buffer[1305] = 8'hd6;
 buffer[1306] = 8'hde;
 buffer[1307] = 8'h7c;
 buffer[1308] = 8'h0c;
 buffer[1309] = 8'h0e;
 buffer[1310] = 8'h00;
 buffer[1311] = 8'h00;
 buffer[1312] = 8'h00;
 buffer[1313] = 8'h00;
 buffer[1314] = 8'hfc;
 buffer[1315] = 8'h66;
 buffer[1316] = 8'h66;
 buffer[1317] = 8'h66;
 buffer[1318] = 8'h7c;
 buffer[1319] = 8'h6c;
 buffer[1320] = 8'h66;
 buffer[1321] = 8'h66;
 buffer[1322] = 8'h66;
 buffer[1323] = 8'he6;
 buffer[1324] = 8'h00;
 buffer[1325] = 8'h00;
 buffer[1326] = 8'h00;
 buffer[1327] = 8'h00;
 buffer[1328] = 8'h00;
 buffer[1329] = 8'h00;
 buffer[1330] = 8'h7c;
 buffer[1331] = 8'hc6;
 buffer[1332] = 8'hc6;
 buffer[1333] = 8'h60;
 buffer[1334] = 8'h38;
 buffer[1335] = 8'h0c;
 buffer[1336] = 8'h06;
 buffer[1337] = 8'hc6;
 buffer[1338] = 8'hc6;
 buffer[1339] = 8'h7c;
 buffer[1340] = 8'h00;
 buffer[1341] = 8'h00;
 buffer[1342] = 8'h00;
 buffer[1343] = 8'h00;
 buffer[1344] = 8'h00;
 buffer[1345] = 8'h00;
 buffer[1346] = 8'h7e;
 buffer[1347] = 8'h7e;
 buffer[1348] = 8'h5a;
 buffer[1349] = 8'h18;
 buffer[1350] = 8'h18;
 buffer[1351] = 8'h18;
 buffer[1352] = 8'h18;
 buffer[1353] = 8'h18;
 buffer[1354] = 8'h18;
 buffer[1355] = 8'h3c;
 buffer[1356] = 8'h00;
 buffer[1357] = 8'h00;
 buffer[1358] = 8'h00;
 buffer[1359] = 8'h00;
 buffer[1360] = 8'h00;
 buffer[1361] = 8'h00;
 buffer[1362] = 8'hc6;
 buffer[1363] = 8'hc6;
 buffer[1364] = 8'hc6;
 buffer[1365] = 8'hc6;
 buffer[1366] = 8'hc6;
 buffer[1367] = 8'hc6;
 buffer[1368] = 8'hc6;
 buffer[1369] = 8'hc6;
 buffer[1370] = 8'hc6;
 buffer[1371] = 8'h7c;
 buffer[1372] = 8'h00;
 buffer[1373] = 8'h00;
 buffer[1374] = 8'h00;
 buffer[1375] = 8'h00;
 buffer[1376] = 8'h00;
 buffer[1377] = 8'h00;
 buffer[1378] = 8'hc6;
 buffer[1379] = 8'hc6;
 buffer[1380] = 8'hc6;
 buffer[1381] = 8'hc6;
 buffer[1382] = 8'hc6;
 buffer[1383] = 8'hc6;
 buffer[1384] = 8'hc6;
 buffer[1385] = 8'h6c;
 buffer[1386] = 8'h38;
 buffer[1387] = 8'h10;
 buffer[1388] = 8'h00;
 buffer[1389] = 8'h00;
 buffer[1390] = 8'h00;
 buffer[1391] = 8'h00;
 buffer[1392] = 8'h00;
 buffer[1393] = 8'h00;
 buffer[1394] = 8'hc6;
 buffer[1395] = 8'hc6;
 buffer[1396] = 8'hc6;
 buffer[1397] = 8'hc6;
 buffer[1398] = 8'hd6;
 buffer[1399] = 8'hd6;
 buffer[1400] = 8'hd6;
 buffer[1401] = 8'hfe;
 buffer[1402] = 8'hee;
 buffer[1403] = 8'h6c;
 buffer[1404] = 8'h00;
 buffer[1405] = 8'h00;
 buffer[1406] = 8'h00;
 buffer[1407] = 8'h00;
 buffer[1408] = 8'h00;
 buffer[1409] = 8'h00;
 buffer[1410] = 8'hc6;
 buffer[1411] = 8'hc6;
 buffer[1412] = 8'h6c;
 buffer[1413] = 8'h7c;
 buffer[1414] = 8'h38;
 buffer[1415] = 8'h38;
 buffer[1416] = 8'h7c;
 buffer[1417] = 8'h6c;
 buffer[1418] = 8'hc6;
 buffer[1419] = 8'hc6;
 buffer[1420] = 8'h00;
 buffer[1421] = 8'h00;
 buffer[1422] = 8'h00;
 buffer[1423] = 8'h00;
 buffer[1424] = 8'h00;
 buffer[1425] = 8'h00;
 buffer[1426] = 8'h66;
 buffer[1427] = 8'h66;
 buffer[1428] = 8'h66;
 buffer[1429] = 8'h66;
 buffer[1430] = 8'h3c;
 buffer[1431] = 8'h18;
 buffer[1432] = 8'h18;
 buffer[1433] = 8'h18;
 buffer[1434] = 8'h18;
 buffer[1435] = 8'h3c;
 buffer[1436] = 8'h00;
 buffer[1437] = 8'h00;
 buffer[1438] = 8'h00;
 buffer[1439] = 8'h00;
 buffer[1440] = 8'h00;
 buffer[1441] = 8'h00;
 buffer[1442] = 8'hfe;
 buffer[1443] = 8'hc6;
 buffer[1444] = 8'h86;
 buffer[1445] = 8'h0c;
 buffer[1446] = 8'h18;
 buffer[1447] = 8'h30;
 buffer[1448] = 8'h60;
 buffer[1449] = 8'hc2;
 buffer[1450] = 8'hc6;
 buffer[1451] = 8'hfe;
 buffer[1452] = 8'h00;
 buffer[1453] = 8'h00;
 buffer[1454] = 8'h00;
 buffer[1455] = 8'h00;
 buffer[1456] = 8'h00;
 buffer[1457] = 8'h00;
 buffer[1458] = 8'h3c;
 buffer[1459] = 8'h30;
 buffer[1460] = 8'h30;
 buffer[1461] = 8'h30;
 buffer[1462] = 8'h30;
 buffer[1463] = 8'h30;
 buffer[1464] = 8'h30;
 buffer[1465] = 8'h30;
 buffer[1466] = 8'h30;
 buffer[1467] = 8'h3c;
 buffer[1468] = 8'h00;
 buffer[1469] = 8'h00;
 buffer[1470] = 8'h00;
 buffer[1471] = 8'h00;
 buffer[1472] = 8'h00;
 buffer[1473] = 8'h00;
 buffer[1474] = 8'h00;
 buffer[1475] = 8'h80;
 buffer[1476] = 8'hc0;
 buffer[1477] = 8'he0;
 buffer[1478] = 8'h70;
 buffer[1479] = 8'h38;
 buffer[1480] = 8'h1c;
 buffer[1481] = 8'h0e;
 buffer[1482] = 8'h06;
 buffer[1483] = 8'h02;
 buffer[1484] = 8'h00;
 buffer[1485] = 8'h00;
 buffer[1486] = 8'h00;
 buffer[1487] = 8'h00;
 buffer[1488] = 8'h00;
 buffer[1489] = 8'h00;
 buffer[1490] = 8'h3c;
 buffer[1491] = 8'h0c;
 buffer[1492] = 8'h0c;
 buffer[1493] = 8'h0c;
 buffer[1494] = 8'h0c;
 buffer[1495] = 8'h0c;
 buffer[1496] = 8'h0c;
 buffer[1497] = 8'h0c;
 buffer[1498] = 8'h0c;
 buffer[1499] = 8'h3c;
 buffer[1500] = 8'h00;
 buffer[1501] = 8'h00;
 buffer[1502] = 8'h00;
 buffer[1503] = 8'h00;
 buffer[1504] = 8'h10;
 buffer[1505] = 8'h38;
 buffer[1506] = 8'h6c;
 buffer[1507] = 8'hc6;
 buffer[1508] = 8'h00;
 buffer[1509] = 8'h00;
 buffer[1510] = 8'h00;
 buffer[1511] = 8'h00;
 buffer[1512] = 8'h00;
 buffer[1513] = 8'h00;
 buffer[1514] = 8'h00;
 buffer[1515] = 8'h00;
 buffer[1516] = 8'h00;
 buffer[1517] = 8'h00;
 buffer[1518] = 8'h00;
 buffer[1519] = 8'h00;
 buffer[1520] = 8'h00;
 buffer[1521] = 8'h00;
 buffer[1522] = 8'h00;
 buffer[1523] = 8'h00;
 buffer[1524] = 8'h00;
 buffer[1525] = 8'h00;
 buffer[1526] = 8'h00;
 buffer[1527] = 8'h00;
 buffer[1528] = 8'h00;
 buffer[1529] = 8'h00;
 buffer[1530] = 8'h00;
 buffer[1531] = 8'h00;
 buffer[1532] = 8'h00;
 buffer[1533] = 8'hff;
 buffer[1534] = 8'h00;
 buffer[1535] = 8'h00;
 buffer[1536] = 8'h30;
 buffer[1537] = 8'h30;
 buffer[1538] = 8'h18;
 buffer[1539] = 8'h00;
 buffer[1540] = 8'h00;
 buffer[1541] = 8'h00;
 buffer[1542] = 8'h00;
 buffer[1543] = 8'h00;
 buffer[1544] = 8'h00;
 buffer[1545] = 8'h00;
 buffer[1546] = 8'h00;
 buffer[1547] = 8'h00;
 buffer[1548] = 8'h00;
 buffer[1549] = 8'h00;
 buffer[1550] = 8'h00;
 buffer[1551] = 8'h00;
 buffer[1552] = 8'h00;
 buffer[1553] = 8'h00;
 buffer[1554] = 8'h00;
 buffer[1555] = 8'h00;
 buffer[1556] = 8'h00;
 buffer[1557] = 8'h78;
 buffer[1558] = 8'h0c;
 buffer[1559] = 8'h7c;
 buffer[1560] = 8'hcc;
 buffer[1561] = 8'hcc;
 buffer[1562] = 8'hcc;
 buffer[1563] = 8'h76;
 buffer[1564] = 8'h00;
 buffer[1565] = 8'h00;
 buffer[1566] = 8'h00;
 buffer[1567] = 8'h00;
 buffer[1568] = 8'h00;
 buffer[1569] = 8'h00;
 buffer[1570] = 8'he0;
 buffer[1571] = 8'h60;
 buffer[1572] = 8'h60;
 buffer[1573] = 8'h78;
 buffer[1574] = 8'h6c;
 buffer[1575] = 8'h66;
 buffer[1576] = 8'h66;
 buffer[1577] = 8'h66;
 buffer[1578] = 8'h66;
 buffer[1579] = 8'h7c;
 buffer[1580] = 8'h00;
 buffer[1581] = 8'h00;
 buffer[1582] = 8'h00;
 buffer[1583] = 8'h00;
 buffer[1584] = 8'h00;
 buffer[1585] = 8'h00;
 buffer[1586] = 8'h00;
 buffer[1587] = 8'h00;
 buffer[1588] = 8'h00;
 buffer[1589] = 8'h7c;
 buffer[1590] = 8'hc6;
 buffer[1591] = 8'hc0;
 buffer[1592] = 8'hc0;
 buffer[1593] = 8'hc0;
 buffer[1594] = 8'hc6;
 buffer[1595] = 8'h7c;
 buffer[1596] = 8'h00;
 buffer[1597] = 8'h00;
 buffer[1598] = 8'h00;
 buffer[1599] = 8'h00;
 buffer[1600] = 8'h00;
 buffer[1601] = 8'h00;
 buffer[1602] = 8'h1c;
 buffer[1603] = 8'h0c;
 buffer[1604] = 8'h0c;
 buffer[1605] = 8'h3c;
 buffer[1606] = 8'h6c;
 buffer[1607] = 8'hcc;
 buffer[1608] = 8'hcc;
 buffer[1609] = 8'hcc;
 buffer[1610] = 8'hcc;
 buffer[1611] = 8'h76;
 buffer[1612] = 8'h00;
 buffer[1613] = 8'h00;
 buffer[1614] = 8'h00;
 buffer[1615] = 8'h00;
 buffer[1616] = 8'h00;
 buffer[1617] = 8'h00;
 buffer[1618] = 8'h00;
 buffer[1619] = 8'h00;
 buffer[1620] = 8'h00;
 buffer[1621] = 8'h7c;
 buffer[1622] = 8'hc6;
 buffer[1623] = 8'hfe;
 buffer[1624] = 8'hc0;
 buffer[1625] = 8'hc0;
 buffer[1626] = 8'hc6;
 buffer[1627] = 8'h7c;
 buffer[1628] = 8'h00;
 buffer[1629] = 8'h00;
 buffer[1630] = 8'h00;
 buffer[1631] = 8'h00;
 buffer[1632] = 8'h00;
 buffer[1633] = 8'h00;
 buffer[1634] = 8'h38;
 buffer[1635] = 8'h6c;
 buffer[1636] = 8'h64;
 buffer[1637] = 8'h60;
 buffer[1638] = 8'hf0;
 buffer[1639] = 8'h60;
 buffer[1640] = 8'h60;
 buffer[1641] = 8'h60;
 buffer[1642] = 8'h60;
 buffer[1643] = 8'hf0;
 buffer[1644] = 8'h00;
 buffer[1645] = 8'h00;
 buffer[1646] = 8'h00;
 buffer[1647] = 8'h00;
 buffer[1648] = 8'h00;
 buffer[1649] = 8'h00;
 buffer[1650] = 8'h00;
 buffer[1651] = 8'h00;
 buffer[1652] = 8'h00;
 buffer[1653] = 8'h76;
 buffer[1654] = 8'hcc;
 buffer[1655] = 8'hcc;
 buffer[1656] = 8'hcc;
 buffer[1657] = 8'hcc;
 buffer[1658] = 8'hcc;
 buffer[1659] = 8'h7c;
 buffer[1660] = 8'h0c;
 buffer[1661] = 8'hcc;
 buffer[1662] = 8'h78;
 buffer[1663] = 8'h00;
 buffer[1664] = 8'h00;
 buffer[1665] = 8'h00;
 buffer[1666] = 8'he0;
 buffer[1667] = 8'h60;
 buffer[1668] = 8'h60;
 buffer[1669] = 8'h6c;
 buffer[1670] = 8'h76;
 buffer[1671] = 8'h66;
 buffer[1672] = 8'h66;
 buffer[1673] = 8'h66;
 buffer[1674] = 8'h66;
 buffer[1675] = 8'he6;
 buffer[1676] = 8'h00;
 buffer[1677] = 8'h00;
 buffer[1678] = 8'h00;
 buffer[1679] = 8'h00;
 buffer[1680] = 8'h00;
 buffer[1681] = 8'h00;
 buffer[1682] = 8'h18;
 buffer[1683] = 8'h18;
 buffer[1684] = 8'h00;
 buffer[1685] = 8'h38;
 buffer[1686] = 8'h18;
 buffer[1687] = 8'h18;
 buffer[1688] = 8'h18;
 buffer[1689] = 8'h18;
 buffer[1690] = 8'h18;
 buffer[1691] = 8'h3c;
 buffer[1692] = 8'h00;
 buffer[1693] = 8'h00;
 buffer[1694] = 8'h00;
 buffer[1695] = 8'h00;
 buffer[1696] = 8'h00;
 buffer[1697] = 8'h00;
 buffer[1698] = 8'h06;
 buffer[1699] = 8'h06;
 buffer[1700] = 8'h00;
 buffer[1701] = 8'h0e;
 buffer[1702] = 8'h06;
 buffer[1703] = 8'h06;
 buffer[1704] = 8'h06;
 buffer[1705] = 8'h06;
 buffer[1706] = 8'h06;
 buffer[1707] = 8'h06;
 buffer[1708] = 8'h66;
 buffer[1709] = 8'h66;
 buffer[1710] = 8'h3c;
 buffer[1711] = 8'h00;
 buffer[1712] = 8'h00;
 buffer[1713] = 8'h00;
 buffer[1714] = 8'he0;
 buffer[1715] = 8'h60;
 buffer[1716] = 8'h60;
 buffer[1717] = 8'h66;
 buffer[1718] = 8'h6c;
 buffer[1719] = 8'h78;
 buffer[1720] = 8'h78;
 buffer[1721] = 8'h6c;
 buffer[1722] = 8'h66;
 buffer[1723] = 8'he6;
 buffer[1724] = 8'h00;
 buffer[1725] = 8'h00;
 buffer[1726] = 8'h00;
 buffer[1727] = 8'h00;
 buffer[1728] = 8'h00;
 buffer[1729] = 8'h00;
 buffer[1730] = 8'h38;
 buffer[1731] = 8'h18;
 buffer[1732] = 8'h18;
 buffer[1733] = 8'h18;
 buffer[1734] = 8'h18;
 buffer[1735] = 8'h18;
 buffer[1736] = 8'h18;
 buffer[1737] = 8'h18;
 buffer[1738] = 8'h18;
 buffer[1739] = 8'h3c;
 buffer[1740] = 8'h00;
 buffer[1741] = 8'h00;
 buffer[1742] = 8'h00;
 buffer[1743] = 8'h00;
 buffer[1744] = 8'h00;
 buffer[1745] = 8'h00;
 buffer[1746] = 8'h00;
 buffer[1747] = 8'h00;
 buffer[1748] = 8'h00;
 buffer[1749] = 8'hec;
 buffer[1750] = 8'hfe;
 buffer[1751] = 8'hd6;
 buffer[1752] = 8'hd6;
 buffer[1753] = 8'hd6;
 buffer[1754] = 8'hd6;
 buffer[1755] = 8'hc6;
 buffer[1756] = 8'h00;
 buffer[1757] = 8'h00;
 buffer[1758] = 8'h00;
 buffer[1759] = 8'h00;
 buffer[1760] = 8'h00;
 buffer[1761] = 8'h00;
 buffer[1762] = 8'h00;
 buffer[1763] = 8'h00;
 buffer[1764] = 8'h00;
 buffer[1765] = 8'hdc;
 buffer[1766] = 8'h66;
 buffer[1767] = 8'h66;
 buffer[1768] = 8'h66;
 buffer[1769] = 8'h66;
 buffer[1770] = 8'h66;
 buffer[1771] = 8'h66;
 buffer[1772] = 8'h00;
 buffer[1773] = 8'h00;
 buffer[1774] = 8'h00;
 buffer[1775] = 8'h00;
 buffer[1776] = 8'h00;
 buffer[1777] = 8'h00;
 buffer[1778] = 8'h00;
 buffer[1779] = 8'h00;
 buffer[1780] = 8'h00;
 buffer[1781] = 8'h7c;
 buffer[1782] = 8'hc6;
 buffer[1783] = 8'hc6;
 buffer[1784] = 8'hc6;
 buffer[1785] = 8'hc6;
 buffer[1786] = 8'hc6;
 buffer[1787] = 8'h7c;
 buffer[1788] = 8'h00;
 buffer[1789] = 8'h00;
 buffer[1790] = 8'h00;
 buffer[1791] = 8'h00;
 buffer[1792] = 8'h00;
 buffer[1793] = 8'h00;
 buffer[1794] = 8'h00;
 buffer[1795] = 8'h00;
 buffer[1796] = 8'h00;
 buffer[1797] = 8'hdc;
 buffer[1798] = 8'h66;
 buffer[1799] = 8'h66;
 buffer[1800] = 8'h66;
 buffer[1801] = 8'h66;
 buffer[1802] = 8'h66;
 buffer[1803] = 8'h7c;
 buffer[1804] = 8'h60;
 buffer[1805] = 8'h60;
 buffer[1806] = 8'hf0;
 buffer[1807] = 8'h00;
 buffer[1808] = 8'h00;
 buffer[1809] = 8'h00;
 buffer[1810] = 8'h00;
 buffer[1811] = 8'h00;
 buffer[1812] = 8'h00;
 buffer[1813] = 8'h76;
 buffer[1814] = 8'hcc;
 buffer[1815] = 8'hcc;
 buffer[1816] = 8'hcc;
 buffer[1817] = 8'hcc;
 buffer[1818] = 8'hcc;
 buffer[1819] = 8'h7c;
 buffer[1820] = 8'h0c;
 buffer[1821] = 8'h0c;
 buffer[1822] = 8'h1e;
 buffer[1823] = 8'h00;
 buffer[1824] = 8'h00;
 buffer[1825] = 8'h00;
 buffer[1826] = 8'h00;
 buffer[1827] = 8'h00;
 buffer[1828] = 8'h00;
 buffer[1829] = 8'hdc;
 buffer[1830] = 8'h76;
 buffer[1831] = 8'h66;
 buffer[1832] = 8'h60;
 buffer[1833] = 8'h60;
 buffer[1834] = 8'h60;
 buffer[1835] = 8'hf0;
 buffer[1836] = 8'h00;
 buffer[1837] = 8'h00;
 buffer[1838] = 8'h00;
 buffer[1839] = 8'h00;
 buffer[1840] = 8'h00;
 buffer[1841] = 8'h00;
 buffer[1842] = 8'h00;
 buffer[1843] = 8'h00;
 buffer[1844] = 8'h00;
 buffer[1845] = 8'h7c;
 buffer[1846] = 8'hc6;
 buffer[1847] = 8'h60;
 buffer[1848] = 8'h38;
 buffer[1849] = 8'h0c;
 buffer[1850] = 8'hc6;
 buffer[1851] = 8'h7c;
 buffer[1852] = 8'h00;
 buffer[1853] = 8'h00;
 buffer[1854] = 8'h00;
 buffer[1855] = 8'h00;
 buffer[1856] = 8'h00;
 buffer[1857] = 8'h00;
 buffer[1858] = 8'h10;
 buffer[1859] = 8'h30;
 buffer[1860] = 8'h30;
 buffer[1861] = 8'hfc;
 buffer[1862] = 8'h30;
 buffer[1863] = 8'h30;
 buffer[1864] = 8'h30;
 buffer[1865] = 8'h30;
 buffer[1866] = 8'h36;
 buffer[1867] = 8'h1c;
 buffer[1868] = 8'h00;
 buffer[1869] = 8'h00;
 buffer[1870] = 8'h00;
 buffer[1871] = 8'h00;
 buffer[1872] = 8'h00;
 buffer[1873] = 8'h00;
 buffer[1874] = 8'h00;
 buffer[1875] = 8'h00;
 buffer[1876] = 8'h00;
 buffer[1877] = 8'hcc;
 buffer[1878] = 8'hcc;
 buffer[1879] = 8'hcc;
 buffer[1880] = 8'hcc;
 buffer[1881] = 8'hcc;
 buffer[1882] = 8'hcc;
 buffer[1883] = 8'h76;
 buffer[1884] = 8'h00;
 buffer[1885] = 8'h00;
 buffer[1886] = 8'h00;
 buffer[1887] = 8'h00;
 buffer[1888] = 8'h00;
 buffer[1889] = 8'h00;
 buffer[1890] = 8'h00;
 buffer[1891] = 8'h00;
 buffer[1892] = 8'h00;
 buffer[1893] = 8'h66;
 buffer[1894] = 8'h66;
 buffer[1895] = 8'h66;
 buffer[1896] = 8'h66;
 buffer[1897] = 8'h66;
 buffer[1898] = 8'h3c;
 buffer[1899] = 8'h18;
 buffer[1900] = 8'h00;
 buffer[1901] = 8'h00;
 buffer[1902] = 8'h00;
 buffer[1903] = 8'h00;
 buffer[1904] = 8'h00;
 buffer[1905] = 8'h00;
 buffer[1906] = 8'h00;
 buffer[1907] = 8'h00;
 buffer[1908] = 8'h00;
 buffer[1909] = 8'hc6;
 buffer[1910] = 8'hc6;
 buffer[1911] = 8'hd6;
 buffer[1912] = 8'hd6;
 buffer[1913] = 8'hd6;
 buffer[1914] = 8'hfe;
 buffer[1915] = 8'h6c;
 buffer[1916] = 8'h00;
 buffer[1917] = 8'h00;
 buffer[1918] = 8'h00;
 buffer[1919] = 8'h00;
 buffer[1920] = 8'h00;
 buffer[1921] = 8'h00;
 buffer[1922] = 8'h00;
 buffer[1923] = 8'h00;
 buffer[1924] = 8'h00;
 buffer[1925] = 8'hc6;
 buffer[1926] = 8'h6c;
 buffer[1927] = 8'h38;
 buffer[1928] = 8'h38;
 buffer[1929] = 8'h38;
 buffer[1930] = 8'h6c;
 buffer[1931] = 8'hc6;
 buffer[1932] = 8'h00;
 buffer[1933] = 8'h00;
 buffer[1934] = 8'h00;
 buffer[1935] = 8'h00;
 buffer[1936] = 8'h00;
 buffer[1937] = 8'h00;
 buffer[1938] = 8'h00;
 buffer[1939] = 8'h00;
 buffer[1940] = 8'h00;
 buffer[1941] = 8'hc6;
 buffer[1942] = 8'hc6;
 buffer[1943] = 8'hc6;
 buffer[1944] = 8'hc6;
 buffer[1945] = 8'hc6;
 buffer[1946] = 8'hc6;
 buffer[1947] = 8'h7e;
 buffer[1948] = 8'h06;
 buffer[1949] = 8'h0c;
 buffer[1950] = 8'hf8;
 buffer[1951] = 8'h00;
 buffer[1952] = 8'h00;
 buffer[1953] = 8'h00;
 buffer[1954] = 8'h00;
 buffer[1955] = 8'h00;
 buffer[1956] = 8'h00;
 buffer[1957] = 8'hfe;
 buffer[1958] = 8'hcc;
 buffer[1959] = 8'h18;
 buffer[1960] = 8'h30;
 buffer[1961] = 8'h60;
 buffer[1962] = 8'hc6;
 buffer[1963] = 8'hfe;
 buffer[1964] = 8'h00;
 buffer[1965] = 8'h00;
 buffer[1966] = 8'h00;
 buffer[1967] = 8'h00;
 buffer[1968] = 8'h00;
 buffer[1969] = 8'h00;
 buffer[1970] = 8'h0e;
 buffer[1971] = 8'h18;
 buffer[1972] = 8'h18;
 buffer[1973] = 8'h18;
 buffer[1974] = 8'h70;
 buffer[1975] = 8'h18;
 buffer[1976] = 8'h18;
 buffer[1977] = 8'h18;
 buffer[1978] = 8'h18;
 buffer[1979] = 8'h0e;
 buffer[1980] = 8'h00;
 buffer[1981] = 8'h00;
 buffer[1982] = 8'h00;
 buffer[1983] = 8'h00;
 buffer[1984] = 8'h00;
 buffer[1985] = 8'h00;
 buffer[1986] = 8'h18;
 buffer[1987] = 8'h18;
 buffer[1988] = 8'h18;
 buffer[1989] = 8'h18;
 buffer[1990] = 8'h00;
 buffer[1991] = 8'h18;
 buffer[1992] = 8'h18;
 buffer[1993] = 8'h18;
 buffer[1994] = 8'h18;
 buffer[1995] = 8'h18;
 buffer[1996] = 8'h00;
 buffer[1997] = 8'h00;
 buffer[1998] = 8'h00;
 buffer[1999] = 8'h00;
 buffer[2000] = 8'h00;
 buffer[2001] = 8'h00;
 buffer[2002] = 8'h70;
 buffer[2003] = 8'h18;
 buffer[2004] = 8'h18;
 buffer[2005] = 8'h18;
 buffer[2006] = 8'h0e;
 buffer[2007] = 8'h18;
 buffer[2008] = 8'h18;
 buffer[2009] = 8'h18;
 buffer[2010] = 8'h18;
 buffer[2011] = 8'h70;
 buffer[2012] = 8'h00;
 buffer[2013] = 8'h00;
 buffer[2014] = 8'h00;
 buffer[2015] = 8'h00;
 buffer[2016] = 8'h00;
 buffer[2017] = 8'h00;
 buffer[2018] = 8'h76;
 buffer[2019] = 8'hdc;
 buffer[2020] = 8'h00;
 buffer[2021] = 8'h00;
 buffer[2022] = 8'h00;
 buffer[2023] = 8'h00;
 buffer[2024] = 8'h00;
 buffer[2025] = 8'h00;
 buffer[2026] = 8'h00;
 buffer[2027] = 8'h00;
 buffer[2028] = 8'h00;
 buffer[2029] = 8'h00;
 buffer[2030] = 8'h00;
 buffer[2031] = 8'h00;
 buffer[2032] = 8'h00;
 buffer[2033] = 8'h00;
 buffer[2034] = 8'h00;
 buffer[2035] = 8'h00;
 buffer[2036] = 8'h10;
 buffer[2037] = 8'h38;
 buffer[2038] = 8'h6c;
 buffer[2039] = 8'hc6;
 buffer[2040] = 8'hc6;
 buffer[2041] = 8'hc6;
 buffer[2042] = 8'hfe;
 buffer[2043] = 8'h00;
 buffer[2044] = 8'h00;
 buffer[2045] = 8'h00;
 buffer[2046] = 8'h00;
 buffer[2047] = 8'h00;
 buffer[2048] = 8'h00;
 buffer[2049] = 8'h00;
 buffer[2050] = 8'h3c;
 buffer[2051] = 8'h66;
 buffer[2052] = 8'hc2;
 buffer[2053] = 8'hc0;
 buffer[2054] = 8'hc0;
 buffer[2055] = 8'hc0;
 buffer[2056] = 8'hc2;
 buffer[2057] = 8'h66;
 buffer[2058] = 8'h3c;
 buffer[2059] = 8'h0c;
 buffer[2060] = 8'h06;
 buffer[2061] = 8'h7c;
 buffer[2062] = 8'h00;
 buffer[2063] = 8'h00;
 buffer[2064] = 8'h00;
 buffer[2065] = 8'h00;
 buffer[2066] = 8'hcc;
 buffer[2067] = 8'h00;
 buffer[2068] = 8'h00;
 buffer[2069] = 8'hcc;
 buffer[2070] = 8'hcc;
 buffer[2071] = 8'hcc;
 buffer[2072] = 8'hcc;
 buffer[2073] = 8'hcc;
 buffer[2074] = 8'hcc;
 buffer[2075] = 8'h76;
 buffer[2076] = 8'h00;
 buffer[2077] = 8'h00;
 buffer[2078] = 8'h00;
 buffer[2079] = 8'h00;
 buffer[2080] = 8'h00;
 buffer[2081] = 8'h0c;
 buffer[2082] = 8'h18;
 buffer[2083] = 8'h30;
 buffer[2084] = 8'h00;
 buffer[2085] = 8'h7c;
 buffer[2086] = 8'hc6;
 buffer[2087] = 8'hfe;
 buffer[2088] = 8'hc0;
 buffer[2089] = 8'hc0;
 buffer[2090] = 8'hc6;
 buffer[2091] = 8'h7c;
 buffer[2092] = 8'h00;
 buffer[2093] = 8'h00;
 buffer[2094] = 8'h00;
 buffer[2095] = 8'h00;
 buffer[2096] = 8'h00;
 buffer[2097] = 8'h10;
 buffer[2098] = 8'h38;
 buffer[2099] = 8'h6c;
 buffer[2100] = 8'h00;
 buffer[2101] = 8'h78;
 buffer[2102] = 8'h0c;
 buffer[2103] = 8'h7c;
 buffer[2104] = 8'hcc;
 buffer[2105] = 8'hcc;
 buffer[2106] = 8'hcc;
 buffer[2107] = 8'h76;
 buffer[2108] = 8'h00;
 buffer[2109] = 8'h00;
 buffer[2110] = 8'h00;
 buffer[2111] = 8'h00;
 buffer[2112] = 8'h00;
 buffer[2113] = 8'h00;
 buffer[2114] = 8'hcc;
 buffer[2115] = 8'h00;
 buffer[2116] = 8'h00;
 buffer[2117] = 8'h78;
 buffer[2118] = 8'h0c;
 buffer[2119] = 8'h7c;
 buffer[2120] = 8'hcc;
 buffer[2121] = 8'hcc;
 buffer[2122] = 8'hcc;
 buffer[2123] = 8'h76;
 buffer[2124] = 8'h00;
 buffer[2125] = 8'h00;
 buffer[2126] = 8'h00;
 buffer[2127] = 8'h00;
 buffer[2128] = 8'h00;
 buffer[2129] = 8'h60;
 buffer[2130] = 8'h30;
 buffer[2131] = 8'h18;
 buffer[2132] = 8'h00;
 buffer[2133] = 8'h78;
 buffer[2134] = 8'h0c;
 buffer[2135] = 8'h7c;
 buffer[2136] = 8'hcc;
 buffer[2137] = 8'hcc;
 buffer[2138] = 8'hcc;
 buffer[2139] = 8'h76;
 buffer[2140] = 8'h00;
 buffer[2141] = 8'h00;
 buffer[2142] = 8'h00;
 buffer[2143] = 8'h00;
 buffer[2144] = 8'h00;
 buffer[2145] = 8'h38;
 buffer[2146] = 8'h6c;
 buffer[2147] = 8'h38;
 buffer[2148] = 8'h00;
 buffer[2149] = 8'h78;
 buffer[2150] = 8'h0c;
 buffer[2151] = 8'h7c;
 buffer[2152] = 8'hcc;
 buffer[2153] = 8'hcc;
 buffer[2154] = 8'hcc;
 buffer[2155] = 8'h76;
 buffer[2156] = 8'h00;
 buffer[2157] = 8'h00;
 buffer[2158] = 8'h00;
 buffer[2159] = 8'h00;
 buffer[2160] = 8'h00;
 buffer[2161] = 8'h00;
 buffer[2162] = 8'h00;
 buffer[2163] = 8'h00;
 buffer[2164] = 8'h3c;
 buffer[2165] = 8'h66;
 buffer[2166] = 8'h60;
 buffer[2167] = 8'h60;
 buffer[2168] = 8'h66;
 buffer[2169] = 8'h3c;
 buffer[2170] = 8'h0c;
 buffer[2171] = 8'h06;
 buffer[2172] = 8'h3c;
 buffer[2173] = 8'h00;
 buffer[2174] = 8'h00;
 buffer[2175] = 8'h00;
 buffer[2176] = 8'h00;
 buffer[2177] = 8'h10;
 buffer[2178] = 8'h38;
 buffer[2179] = 8'h6c;
 buffer[2180] = 8'h00;
 buffer[2181] = 8'h7c;
 buffer[2182] = 8'hc6;
 buffer[2183] = 8'hfe;
 buffer[2184] = 8'hc0;
 buffer[2185] = 8'hc0;
 buffer[2186] = 8'hc6;
 buffer[2187] = 8'h7c;
 buffer[2188] = 8'h00;
 buffer[2189] = 8'h00;
 buffer[2190] = 8'h00;
 buffer[2191] = 8'h00;
 buffer[2192] = 8'h00;
 buffer[2193] = 8'h00;
 buffer[2194] = 8'hc6;
 buffer[2195] = 8'h00;
 buffer[2196] = 8'h00;
 buffer[2197] = 8'h7c;
 buffer[2198] = 8'hc6;
 buffer[2199] = 8'hfe;
 buffer[2200] = 8'hc0;
 buffer[2201] = 8'hc0;
 buffer[2202] = 8'hc6;
 buffer[2203] = 8'h7c;
 buffer[2204] = 8'h00;
 buffer[2205] = 8'h00;
 buffer[2206] = 8'h00;
 buffer[2207] = 8'h00;
 buffer[2208] = 8'h00;
 buffer[2209] = 8'h60;
 buffer[2210] = 8'h30;
 buffer[2211] = 8'h18;
 buffer[2212] = 8'h00;
 buffer[2213] = 8'h7c;
 buffer[2214] = 8'hc6;
 buffer[2215] = 8'hfe;
 buffer[2216] = 8'hc0;
 buffer[2217] = 8'hc0;
 buffer[2218] = 8'hc6;
 buffer[2219] = 8'h7c;
 buffer[2220] = 8'h00;
 buffer[2221] = 8'h00;
 buffer[2222] = 8'h00;
 buffer[2223] = 8'h00;
 buffer[2224] = 8'h00;
 buffer[2225] = 8'h00;
 buffer[2226] = 8'h66;
 buffer[2227] = 8'h00;
 buffer[2228] = 8'h00;
 buffer[2229] = 8'h38;
 buffer[2230] = 8'h18;
 buffer[2231] = 8'h18;
 buffer[2232] = 8'h18;
 buffer[2233] = 8'h18;
 buffer[2234] = 8'h18;
 buffer[2235] = 8'h3c;
 buffer[2236] = 8'h00;
 buffer[2237] = 8'h00;
 buffer[2238] = 8'h00;
 buffer[2239] = 8'h00;
 buffer[2240] = 8'h00;
 buffer[2241] = 8'h18;
 buffer[2242] = 8'h3c;
 buffer[2243] = 8'h66;
 buffer[2244] = 8'h00;
 buffer[2245] = 8'h38;
 buffer[2246] = 8'h18;
 buffer[2247] = 8'h18;
 buffer[2248] = 8'h18;
 buffer[2249] = 8'h18;
 buffer[2250] = 8'h18;
 buffer[2251] = 8'h3c;
 buffer[2252] = 8'h00;
 buffer[2253] = 8'h00;
 buffer[2254] = 8'h00;
 buffer[2255] = 8'h00;
 buffer[2256] = 8'h00;
 buffer[2257] = 8'h60;
 buffer[2258] = 8'h30;
 buffer[2259] = 8'h18;
 buffer[2260] = 8'h00;
 buffer[2261] = 8'h38;
 buffer[2262] = 8'h18;
 buffer[2263] = 8'h18;
 buffer[2264] = 8'h18;
 buffer[2265] = 8'h18;
 buffer[2266] = 8'h18;
 buffer[2267] = 8'h3c;
 buffer[2268] = 8'h00;
 buffer[2269] = 8'h00;
 buffer[2270] = 8'h00;
 buffer[2271] = 8'h00;
 buffer[2272] = 8'h00;
 buffer[2273] = 8'hc6;
 buffer[2274] = 8'h00;
 buffer[2275] = 8'h10;
 buffer[2276] = 8'h38;
 buffer[2277] = 8'h6c;
 buffer[2278] = 8'hc6;
 buffer[2279] = 8'hc6;
 buffer[2280] = 8'hfe;
 buffer[2281] = 8'hc6;
 buffer[2282] = 8'hc6;
 buffer[2283] = 8'hc6;
 buffer[2284] = 8'h00;
 buffer[2285] = 8'h00;
 buffer[2286] = 8'h00;
 buffer[2287] = 8'h00;
 buffer[2288] = 8'h38;
 buffer[2289] = 8'h6c;
 buffer[2290] = 8'h38;
 buffer[2291] = 8'h00;
 buffer[2292] = 8'h38;
 buffer[2293] = 8'h6c;
 buffer[2294] = 8'hc6;
 buffer[2295] = 8'hc6;
 buffer[2296] = 8'hfe;
 buffer[2297] = 8'hc6;
 buffer[2298] = 8'hc6;
 buffer[2299] = 8'hc6;
 buffer[2300] = 8'h00;
 buffer[2301] = 8'h00;
 buffer[2302] = 8'h00;
 buffer[2303] = 8'h00;
 buffer[2304] = 8'h18;
 buffer[2305] = 8'h30;
 buffer[2306] = 8'h60;
 buffer[2307] = 8'h00;
 buffer[2308] = 8'hfe;
 buffer[2309] = 8'h66;
 buffer[2310] = 8'h60;
 buffer[2311] = 8'h7c;
 buffer[2312] = 8'h60;
 buffer[2313] = 8'h60;
 buffer[2314] = 8'h66;
 buffer[2315] = 8'hfe;
 buffer[2316] = 8'h00;
 buffer[2317] = 8'h00;
 buffer[2318] = 8'h00;
 buffer[2319] = 8'h00;
 buffer[2320] = 8'h00;
 buffer[2321] = 8'h00;
 buffer[2322] = 8'h00;
 buffer[2323] = 8'h00;
 buffer[2324] = 8'h00;
 buffer[2325] = 8'hcc;
 buffer[2326] = 8'h76;
 buffer[2327] = 8'h36;
 buffer[2328] = 8'h7e;
 buffer[2329] = 8'hd8;
 buffer[2330] = 8'hd8;
 buffer[2331] = 8'h6e;
 buffer[2332] = 8'h00;
 buffer[2333] = 8'h00;
 buffer[2334] = 8'h00;
 buffer[2335] = 8'h00;
 buffer[2336] = 8'h00;
 buffer[2337] = 8'h00;
 buffer[2338] = 8'h3e;
 buffer[2339] = 8'h6c;
 buffer[2340] = 8'hcc;
 buffer[2341] = 8'hcc;
 buffer[2342] = 8'hfe;
 buffer[2343] = 8'hcc;
 buffer[2344] = 8'hcc;
 buffer[2345] = 8'hcc;
 buffer[2346] = 8'hcc;
 buffer[2347] = 8'hce;
 buffer[2348] = 8'h00;
 buffer[2349] = 8'h00;
 buffer[2350] = 8'h00;
 buffer[2351] = 8'h00;
 buffer[2352] = 8'h00;
 buffer[2353] = 8'h10;
 buffer[2354] = 8'h38;
 buffer[2355] = 8'h6c;
 buffer[2356] = 8'h00;
 buffer[2357] = 8'h7c;
 buffer[2358] = 8'hc6;
 buffer[2359] = 8'hc6;
 buffer[2360] = 8'hc6;
 buffer[2361] = 8'hc6;
 buffer[2362] = 8'hc6;
 buffer[2363] = 8'h7c;
 buffer[2364] = 8'h00;
 buffer[2365] = 8'h00;
 buffer[2366] = 8'h00;
 buffer[2367] = 8'h00;
 buffer[2368] = 8'h00;
 buffer[2369] = 8'h00;
 buffer[2370] = 8'hc6;
 buffer[2371] = 8'h00;
 buffer[2372] = 8'h00;
 buffer[2373] = 8'h7c;
 buffer[2374] = 8'hc6;
 buffer[2375] = 8'hc6;
 buffer[2376] = 8'hc6;
 buffer[2377] = 8'hc6;
 buffer[2378] = 8'hc6;
 buffer[2379] = 8'h7c;
 buffer[2380] = 8'h00;
 buffer[2381] = 8'h00;
 buffer[2382] = 8'h00;
 buffer[2383] = 8'h00;
 buffer[2384] = 8'h00;
 buffer[2385] = 8'h60;
 buffer[2386] = 8'h30;
 buffer[2387] = 8'h18;
 buffer[2388] = 8'h00;
 buffer[2389] = 8'h7c;
 buffer[2390] = 8'hc6;
 buffer[2391] = 8'hc6;
 buffer[2392] = 8'hc6;
 buffer[2393] = 8'hc6;
 buffer[2394] = 8'hc6;
 buffer[2395] = 8'h7c;
 buffer[2396] = 8'h00;
 buffer[2397] = 8'h00;
 buffer[2398] = 8'h00;
 buffer[2399] = 8'h00;
 buffer[2400] = 8'h00;
 buffer[2401] = 8'h30;
 buffer[2402] = 8'h78;
 buffer[2403] = 8'hcc;
 buffer[2404] = 8'h00;
 buffer[2405] = 8'hcc;
 buffer[2406] = 8'hcc;
 buffer[2407] = 8'hcc;
 buffer[2408] = 8'hcc;
 buffer[2409] = 8'hcc;
 buffer[2410] = 8'hcc;
 buffer[2411] = 8'h76;
 buffer[2412] = 8'h00;
 buffer[2413] = 8'h00;
 buffer[2414] = 8'h00;
 buffer[2415] = 8'h00;
 buffer[2416] = 8'h00;
 buffer[2417] = 8'h60;
 buffer[2418] = 8'h30;
 buffer[2419] = 8'h18;
 buffer[2420] = 8'h00;
 buffer[2421] = 8'hcc;
 buffer[2422] = 8'hcc;
 buffer[2423] = 8'hcc;
 buffer[2424] = 8'hcc;
 buffer[2425] = 8'hcc;
 buffer[2426] = 8'hcc;
 buffer[2427] = 8'h76;
 buffer[2428] = 8'h00;
 buffer[2429] = 8'h00;
 buffer[2430] = 8'h00;
 buffer[2431] = 8'h00;
 buffer[2432] = 8'h00;
 buffer[2433] = 8'h00;
 buffer[2434] = 8'hc6;
 buffer[2435] = 8'h00;
 buffer[2436] = 8'h00;
 buffer[2437] = 8'hc6;
 buffer[2438] = 8'hc6;
 buffer[2439] = 8'hc6;
 buffer[2440] = 8'hc6;
 buffer[2441] = 8'hc6;
 buffer[2442] = 8'hc6;
 buffer[2443] = 8'h7e;
 buffer[2444] = 8'h06;
 buffer[2445] = 8'h0c;
 buffer[2446] = 8'h78;
 buffer[2447] = 8'h00;
 buffer[2448] = 8'h00;
 buffer[2449] = 8'hc6;
 buffer[2450] = 8'h00;
 buffer[2451] = 8'h7c;
 buffer[2452] = 8'hc6;
 buffer[2453] = 8'hc6;
 buffer[2454] = 8'hc6;
 buffer[2455] = 8'hc6;
 buffer[2456] = 8'hc6;
 buffer[2457] = 8'hc6;
 buffer[2458] = 8'hc6;
 buffer[2459] = 8'h7c;
 buffer[2460] = 8'h00;
 buffer[2461] = 8'h00;
 buffer[2462] = 8'h00;
 buffer[2463] = 8'h00;
 buffer[2464] = 8'h00;
 buffer[2465] = 8'hc6;
 buffer[2466] = 8'h00;
 buffer[2467] = 8'hc6;
 buffer[2468] = 8'hc6;
 buffer[2469] = 8'hc6;
 buffer[2470] = 8'hc6;
 buffer[2471] = 8'hc6;
 buffer[2472] = 8'hc6;
 buffer[2473] = 8'hc6;
 buffer[2474] = 8'hc6;
 buffer[2475] = 8'h7c;
 buffer[2476] = 8'h00;
 buffer[2477] = 8'h00;
 buffer[2478] = 8'h00;
 buffer[2479] = 8'h00;
 buffer[2480] = 8'h00;
 buffer[2481] = 8'h18;
 buffer[2482] = 8'h18;
 buffer[2483] = 8'h3c;
 buffer[2484] = 8'h66;
 buffer[2485] = 8'h60;
 buffer[2486] = 8'h60;
 buffer[2487] = 8'h60;
 buffer[2488] = 8'h66;
 buffer[2489] = 8'h3c;
 buffer[2490] = 8'h18;
 buffer[2491] = 8'h18;
 buffer[2492] = 8'h00;
 buffer[2493] = 8'h00;
 buffer[2494] = 8'h00;
 buffer[2495] = 8'h00;
 buffer[2496] = 8'h00;
 buffer[2497] = 8'h38;
 buffer[2498] = 8'h6c;
 buffer[2499] = 8'h64;
 buffer[2500] = 8'h60;
 buffer[2501] = 8'hf0;
 buffer[2502] = 8'h60;
 buffer[2503] = 8'h60;
 buffer[2504] = 8'h60;
 buffer[2505] = 8'h60;
 buffer[2506] = 8'he6;
 buffer[2507] = 8'hfc;
 buffer[2508] = 8'h00;
 buffer[2509] = 8'h00;
 buffer[2510] = 8'h00;
 buffer[2511] = 8'h00;
 buffer[2512] = 8'h00;
 buffer[2513] = 8'h00;
 buffer[2514] = 8'h66;
 buffer[2515] = 8'h66;
 buffer[2516] = 8'h3c;
 buffer[2517] = 8'h18;
 buffer[2518] = 8'h7e;
 buffer[2519] = 8'h18;
 buffer[2520] = 8'h7e;
 buffer[2521] = 8'h18;
 buffer[2522] = 8'h18;
 buffer[2523] = 8'h18;
 buffer[2524] = 8'h00;
 buffer[2525] = 8'h00;
 buffer[2526] = 8'h00;
 buffer[2527] = 8'h00;
 buffer[2528] = 8'h00;
 buffer[2529] = 8'hf8;
 buffer[2530] = 8'hcc;
 buffer[2531] = 8'hcc;
 buffer[2532] = 8'hf8;
 buffer[2533] = 8'hc4;
 buffer[2534] = 8'hcc;
 buffer[2535] = 8'hde;
 buffer[2536] = 8'hcc;
 buffer[2537] = 8'hcc;
 buffer[2538] = 8'hcc;
 buffer[2539] = 8'hc6;
 buffer[2540] = 8'h00;
 buffer[2541] = 8'h00;
 buffer[2542] = 8'h00;
 buffer[2543] = 8'h00;
 buffer[2544] = 8'h00;
 buffer[2545] = 8'h0e;
 buffer[2546] = 8'h1b;
 buffer[2547] = 8'h18;
 buffer[2548] = 8'h18;
 buffer[2549] = 8'h18;
 buffer[2550] = 8'h7e;
 buffer[2551] = 8'h18;
 buffer[2552] = 8'h18;
 buffer[2553] = 8'h18;
 buffer[2554] = 8'h18;
 buffer[2555] = 8'h18;
 buffer[2556] = 8'hd8;
 buffer[2557] = 8'h70;
 buffer[2558] = 8'h00;
 buffer[2559] = 8'h00;
 buffer[2560] = 8'h00;
 buffer[2561] = 8'h18;
 buffer[2562] = 8'h30;
 buffer[2563] = 8'h60;
 buffer[2564] = 8'h00;
 buffer[2565] = 8'h78;
 buffer[2566] = 8'h0c;
 buffer[2567] = 8'h7c;
 buffer[2568] = 8'hcc;
 buffer[2569] = 8'hcc;
 buffer[2570] = 8'hcc;
 buffer[2571] = 8'h76;
 buffer[2572] = 8'h00;
 buffer[2573] = 8'h00;
 buffer[2574] = 8'h00;
 buffer[2575] = 8'h00;
 buffer[2576] = 8'h00;
 buffer[2577] = 8'h0c;
 buffer[2578] = 8'h18;
 buffer[2579] = 8'h30;
 buffer[2580] = 8'h00;
 buffer[2581] = 8'h38;
 buffer[2582] = 8'h18;
 buffer[2583] = 8'h18;
 buffer[2584] = 8'h18;
 buffer[2585] = 8'h18;
 buffer[2586] = 8'h18;
 buffer[2587] = 8'h3c;
 buffer[2588] = 8'h00;
 buffer[2589] = 8'h00;
 buffer[2590] = 8'h00;
 buffer[2591] = 8'h00;
 buffer[2592] = 8'h00;
 buffer[2593] = 8'h18;
 buffer[2594] = 8'h30;
 buffer[2595] = 8'h60;
 buffer[2596] = 8'h00;
 buffer[2597] = 8'h7c;
 buffer[2598] = 8'hc6;
 buffer[2599] = 8'hc6;
 buffer[2600] = 8'hc6;
 buffer[2601] = 8'hc6;
 buffer[2602] = 8'hc6;
 buffer[2603] = 8'h7c;
 buffer[2604] = 8'h00;
 buffer[2605] = 8'h00;
 buffer[2606] = 8'h00;
 buffer[2607] = 8'h00;
 buffer[2608] = 8'h00;
 buffer[2609] = 8'h18;
 buffer[2610] = 8'h30;
 buffer[2611] = 8'h60;
 buffer[2612] = 8'h00;
 buffer[2613] = 8'hcc;
 buffer[2614] = 8'hcc;
 buffer[2615] = 8'hcc;
 buffer[2616] = 8'hcc;
 buffer[2617] = 8'hcc;
 buffer[2618] = 8'hcc;
 buffer[2619] = 8'h76;
 buffer[2620] = 8'h00;
 buffer[2621] = 8'h00;
 buffer[2622] = 8'h00;
 buffer[2623] = 8'h00;
 buffer[2624] = 8'h00;
 buffer[2625] = 8'h00;
 buffer[2626] = 8'h76;
 buffer[2627] = 8'hdc;
 buffer[2628] = 8'h00;
 buffer[2629] = 8'hdc;
 buffer[2630] = 8'h66;
 buffer[2631] = 8'h66;
 buffer[2632] = 8'h66;
 buffer[2633] = 8'h66;
 buffer[2634] = 8'h66;
 buffer[2635] = 8'h66;
 buffer[2636] = 8'h00;
 buffer[2637] = 8'h00;
 buffer[2638] = 8'h00;
 buffer[2639] = 8'h00;
 buffer[2640] = 8'h76;
 buffer[2641] = 8'hdc;
 buffer[2642] = 8'h00;
 buffer[2643] = 8'hc6;
 buffer[2644] = 8'he6;
 buffer[2645] = 8'hf6;
 buffer[2646] = 8'hfe;
 buffer[2647] = 8'hde;
 buffer[2648] = 8'hce;
 buffer[2649] = 8'hc6;
 buffer[2650] = 8'hc6;
 buffer[2651] = 8'hc6;
 buffer[2652] = 8'h00;
 buffer[2653] = 8'h00;
 buffer[2654] = 8'h00;
 buffer[2655] = 8'h00;
 buffer[2656] = 8'h00;
 buffer[2657] = 8'h3c;
 buffer[2658] = 8'h6c;
 buffer[2659] = 8'h6c;
 buffer[2660] = 8'h3e;
 buffer[2661] = 8'h00;
 buffer[2662] = 8'h7e;
 buffer[2663] = 8'h00;
 buffer[2664] = 8'h00;
 buffer[2665] = 8'h00;
 buffer[2666] = 8'h00;
 buffer[2667] = 8'h00;
 buffer[2668] = 8'h00;
 buffer[2669] = 8'h00;
 buffer[2670] = 8'h00;
 buffer[2671] = 8'h00;
 buffer[2672] = 8'h00;
 buffer[2673] = 8'h38;
 buffer[2674] = 8'h6c;
 buffer[2675] = 8'h6c;
 buffer[2676] = 8'h38;
 buffer[2677] = 8'h00;
 buffer[2678] = 8'h7c;
 buffer[2679] = 8'h00;
 buffer[2680] = 8'h00;
 buffer[2681] = 8'h00;
 buffer[2682] = 8'h00;
 buffer[2683] = 8'h00;
 buffer[2684] = 8'h00;
 buffer[2685] = 8'h00;
 buffer[2686] = 8'h00;
 buffer[2687] = 8'h00;
 buffer[2688] = 8'h00;
 buffer[2689] = 8'h00;
 buffer[2690] = 8'h30;
 buffer[2691] = 8'h30;
 buffer[2692] = 8'h00;
 buffer[2693] = 8'h30;
 buffer[2694] = 8'h30;
 buffer[2695] = 8'h60;
 buffer[2696] = 8'hc0;
 buffer[2697] = 8'hc6;
 buffer[2698] = 8'hc6;
 buffer[2699] = 8'h7c;
 buffer[2700] = 8'h00;
 buffer[2701] = 8'h00;
 buffer[2702] = 8'h00;
 buffer[2703] = 8'h00;
 buffer[2704] = 8'h00;
 buffer[2705] = 8'h00;
 buffer[2706] = 8'h00;
 buffer[2707] = 8'h00;
 buffer[2708] = 8'h00;
 buffer[2709] = 8'h00;
 buffer[2710] = 8'hfe;
 buffer[2711] = 8'hc0;
 buffer[2712] = 8'hc0;
 buffer[2713] = 8'hc0;
 buffer[2714] = 8'hc0;
 buffer[2715] = 8'h00;
 buffer[2716] = 8'h00;
 buffer[2717] = 8'h00;
 buffer[2718] = 8'h00;
 buffer[2719] = 8'h00;
 buffer[2720] = 8'h00;
 buffer[2721] = 8'h00;
 buffer[2722] = 8'h00;
 buffer[2723] = 8'h00;
 buffer[2724] = 8'h00;
 buffer[2725] = 8'h00;
 buffer[2726] = 8'hfe;
 buffer[2727] = 8'h06;
 buffer[2728] = 8'h06;
 buffer[2729] = 8'h06;
 buffer[2730] = 8'h06;
 buffer[2731] = 8'h00;
 buffer[2732] = 8'h00;
 buffer[2733] = 8'h00;
 buffer[2734] = 8'h00;
 buffer[2735] = 8'h00;
 buffer[2736] = 8'h00;
 buffer[2737] = 8'hc0;
 buffer[2738] = 8'hc0;
 buffer[2739] = 8'hc2;
 buffer[2740] = 8'hc6;
 buffer[2741] = 8'hcc;
 buffer[2742] = 8'h18;
 buffer[2743] = 8'h30;
 buffer[2744] = 8'h60;
 buffer[2745] = 8'hdc;
 buffer[2746] = 8'h86;
 buffer[2747] = 8'h0c;
 buffer[2748] = 8'h18;
 buffer[2749] = 8'h3e;
 buffer[2750] = 8'h00;
 buffer[2751] = 8'h00;
 buffer[2752] = 8'h00;
 buffer[2753] = 8'hc0;
 buffer[2754] = 8'hc0;
 buffer[2755] = 8'hc2;
 buffer[2756] = 8'hc6;
 buffer[2757] = 8'hcc;
 buffer[2758] = 8'h18;
 buffer[2759] = 8'h30;
 buffer[2760] = 8'h66;
 buffer[2761] = 8'hce;
 buffer[2762] = 8'h9e;
 buffer[2763] = 8'h3e;
 buffer[2764] = 8'h06;
 buffer[2765] = 8'h06;
 buffer[2766] = 8'h00;
 buffer[2767] = 8'h00;
 buffer[2768] = 8'h00;
 buffer[2769] = 8'h00;
 buffer[2770] = 8'h18;
 buffer[2771] = 8'h18;
 buffer[2772] = 8'h00;
 buffer[2773] = 8'h18;
 buffer[2774] = 8'h18;
 buffer[2775] = 8'h18;
 buffer[2776] = 8'h3c;
 buffer[2777] = 8'h3c;
 buffer[2778] = 8'h3c;
 buffer[2779] = 8'h18;
 buffer[2780] = 8'h00;
 buffer[2781] = 8'h00;
 buffer[2782] = 8'h00;
 buffer[2783] = 8'h00;
 buffer[2784] = 8'h00;
 buffer[2785] = 8'h00;
 buffer[2786] = 8'h00;
 buffer[2787] = 8'h00;
 buffer[2788] = 8'h00;
 buffer[2789] = 8'h36;
 buffer[2790] = 8'h6c;
 buffer[2791] = 8'hd8;
 buffer[2792] = 8'h6c;
 buffer[2793] = 8'h36;
 buffer[2794] = 8'h00;
 buffer[2795] = 8'h00;
 buffer[2796] = 8'h00;
 buffer[2797] = 8'h00;
 buffer[2798] = 8'h00;
 buffer[2799] = 8'h00;
 buffer[2800] = 8'h00;
 buffer[2801] = 8'h00;
 buffer[2802] = 8'h00;
 buffer[2803] = 8'h00;
 buffer[2804] = 8'h00;
 buffer[2805] = 8'hd8;
 buffer[2806] = 8'h6c;
 buffer[2807] = 8'h36;
 buffer[2808] = 8'h6c;
 buffer[2809] = 8'hd8;
 buffer[2810] = 8'h00;
 buffer[2811] = 8'h00;
 buffer[2812] = 8'h00;
 buffer[2813] = 8'h00;
 buffer[2814] = 8'h00;
 buffer[2815] = 8'h00;
 buffer[2816] = 8'h11;
 buffer[2817] = 8'h44;
 buffer[2818] = 8'h11;
 buffer[2819] = 8'h44;
 buffer[2820] = 8'h11;
 buffer[2821] = 8'h44;
 buffer[2822] = 8'h11;
 buffer[2823] = 8'h44;
 buffer[2824] = 8'h11;
 buffer[2825] = 8'h44;
 buffer[2826] = 8'h11;
 buffer[2827] = 8'h44;
 buffer[2828] = 8'h11;
 buffer[2829] = 8'h44;
 buffer[2830] = 8'h11;
 buffer[2831] = 8'h44;
 buffer[2832] = 8'h55;
 buffer[2833] = 8'haa;
 buffer[2834] = 8'h55;
 buffer[2835] = 8'haa;
 buffer[2836] = 8'h55;
 buffer[2837] = 8'haa;
 buffer[2838] = 8'h55;
 buffer[2839] = 8'haa;
 buffer[2840] = 8'h55;
 buffer[2841] = 8'haa;
 buffer[2842] = 8'h55;
 buffer[2843] = 8'haa;
 buffer[2844] = 8'h55;
 buffer[2845] = 8'haa;
 buffer[2846] = 8'h55;
 buffer[2847] = 8'haa;
 buffer[2848] = 8'hdd;
 buffer[2849] = 8'h77;
 buffer[2850] = 8'hdd;
 buffer[2851] = 8'h77;
 buffer[2852] = 8'hdd;
 buffer[2853] = 8'h77;
 buffer[2854] = 8'hdd;
 buffer[2855] = 8'h77;
 buffer[2856] = 8'hdd;
 buffer[2857] = 8'h77;
 buffer[2858] = 8'hdd;
 buffer[2859] = 8'h77;
 buffer[2860] = 8'hdd;
 buffer[2861] = 8'h77;
 buffer[2862] = 8'hdd;
 buffer[2863] = 8'h77;
 buffer[2864] = 8'h18;
 buffer[2865] = 8'h18;
 buffer[2866] = 8'h18;
 buffer[2867] = 8'h18;
 buffer[2868] = 8'h18;
 buffer[2869] = 8'h18;
 buffer[2870] = 8'h18;
 buffer[2871] = 8'h18;
 buffer[2872] = 8'h18;
 buffer[2873] = 8'h18;
 buffer[2874] = 8'h18;
 buffer[2875] = 8'h18;
 buffer[2876] = 8'h18;
 buffer[2877] = 8'h18;
 buffer[2878] = 8'h18;
 buffer[2879] = 8'h18;
 buffer[2880] = 8'h18;
 buffer[2881] = 8'h18;
 buffer[2882] = 8'h18;
 buffer[2883] = 8'h18;
 buffer[2884] = 8'h18;
 buffer[2885] = 8'h18;
 buffer[2886] = 8'h18;
 buffer[2887] = 8'hf8;
 buffer[2888] = 8'h18;
 buffer[2889] = 8'h18;
 buffer[2890] = 8'h18;
 buffer[2891] = 8'h18;
 buffer[2892] = 8'h18;
 buffer[2893] = 8'h18;
 buffer[2894] = 8'h18;
 buffer[2895] = 8'h18;
 buffer[2896] = 8'h18;
 buffer[2897] = 8'h18;
 buffer[2898] = 8'h18;
 buffer[2899] = 8'h18;
 buffer[2900] = 8'h18;
 buffer[2901] = 8'hf8;
 buffer[2902] = 8'h18;
 buffer[2903] = 8'hf8;
 buffer[2904] = 8'h18;
 buffer[2905] = 8'h18;
 buffer[2906] = 8'h18;
 buffer[2907] = 8'h18;
 buffer[2908] = 8'h18;
 buffer[2909] = 8'h18;
 buffer[2910] = 8'h18;
 buffer[2911] = 8'h18;
 buffer[2912] = 8'h36;
 buffer[2913] = 8'h36;
 buffer[2914] = 8'h36;
 buffer[2915] = 8'h36;
 buffer[2916] = 8'h36;
 buffer[2917] = 8'h36;
 buffer[2918] = 8'h36;
 buffer[2919] = 8'hf6;
 buffer[2920] = 8'h36;
 buffer[2921] = 8'h36;
 buffer[2922] = 8'h36;
 buffer[2923] = 8'h36;
 buffer[2924] = 8'h36;
 buffer[2925] = 8'h36;
 buffer[2926] = 8'h36;
 buffer[2927] = 8'h36;
 buffer[2928] = 8'h00;
 buffer[2929] = 8'h00;
 buffer[2930] = 8'h00;
 buffer[2931] = 8'h00;
 buffer[2932] = 8'h00;
 buffer[2933] = 8'h00;
 buffer[2934] = 8'h00;
 buffer[2935] = 8'hfe;
 buffer[2936] = 8'h36;
 buffer[2937] = 8'h36;
 buffer[2938] = 8'h36;
 buffer[2939] = 8'h36;
 buffer[2940] = 8'h36;
 buffer[2941] = 8'h36;
 buffer[2942] = 8'h36;
 buffer[2943] = 8'h36;
 buffer[2944] = 8'h00;
 buffer[2945] = 8'h00;
 buffer[2946] = 8'h00;
 buffer[2947] = 8'h00;
 buffer[2948] = 8'h00;
 buffer[2949] = 8'hf8;
 buffer[2950] = 8'h18;
 buffer[2951] = 8'hf8;
 buffer[2952] = 8'h18;
 buffer[2953] = 8'h18;
 buffer[2954] = 8'h18;
 buffer[2955] = 8'h18;
 buffer[2956] = 8'h18;
 buffer[2957] = 8'h18;
 buffer[2958] = 8'h18;
 buffer[2959] = 8'h18;
 buffer[2960] = 8'h36;
 buffer[2961] = 8'h36;
 buffer[2962] = 8'h36;
 buffer[2963] = 8'h36;
 buffer[2964] = 8'h36;
 buffer[2965] = 8'hf6;
 buffer[2966] = 8'h06;
 buffer[2967] = 8'hf6;
 buffer[2968] = 8'h36;
 buffer[2969] = 8'h36;
 buffer[2970] = 8'h36;
 buffer[2971] = 8'h36;
 buffer[2972] = 8'h36;
 buffer[2973] = 8'h36;
 buffer[2974] = 8'h36;
 buffer[2975] = 8'h36;
 buffer[2976] = 8'h36;
 buffer[2977] = 8'h36;
 buffer[2978] = 8'h36;
 buffer[2979] = 8'h36;
 buffer[2980] = 8'h36;
 buffer[2981] = 8'h36;
 buffer[2982] = 8'h36;
 buffer[2983] = 8'h36;
 buffer[2984] = 8'h36;
 buffer[2985] = 8'h36;
 buffer[2986] = 8'h36;
 buffer[2987] = 8'h36;
 buffer[2988] = 8'h36;
 buffer[2989] = 8'h36;
 buffer[2990] = 8'h36;
 buffer[2991] = 8'h36;
 buffer[2992] = 8'h00;
 buffer[2993] = 8'h00;
 buffer[2994] = 8'h00;
 buffer[2995] = 8'h00;
 buffer[2996] = 8'h00;
 buffer[2997] = 8'hfe;
 buffer[2998] = 8'h06;
 buffer[2999] = 8'hf6;
 buffer[3000] = 8'h36;
 buffer[3001] = 8'h36;
 buffer[3002] = 8'h36;
 buffer[3003] = 8'h36;
 buffer[3004] = 8'h36;
 buffer[3005] = 8'h36;
 buffer[3006] = 8'h36;
 buffer[3007] = 8'h36;
 buffer[3008] = 8'h36;
 buffer[3009] = 8'h36;
 buffer[3010] = 8'h36;
 buffer[3011] = 8'h36;
 buffer[3012] = 8'h36;
 buffer[3013] = 8'hf6;
 buffer[3014] = 8'h06;
 buffer[3015] = 8'hfe;
 buffer[3016] = 8'h00;
 buffer[3017] = 8'h00;
 buffer[3018] = 8'h00;
 buffer[3019] = 8'h00;
 buffer[3020] = 8'h00;
 buffer[3021] = 8'h00;
 buffer[3022] = 8'h00;
 buffer[3023] = 8'h00;
 buffer[3024] = 8'h36;
 buffer[3025] = 8'h36;
 buffer[3026] = 8'h36;
 buffer[3027] = 8'h36;
 buffer[3028] = 8'h36;
 buffer[3029] = 8'h36;
 buffer[3030] = 8'h36;
 buffer[3031] = 8'hfe;
 buffer[3032] = 8'h00;
 buffer[3033] = 8'h00;
 buffer[3034] = 8'h00;
 buffer[3035] = 8'h00;
 buffer[3036] = 8'h00;
 buffer[3037] = 8'h00;
 buffer[3038] = 8'h00;
 buffer[3039] = 8'h00;
 buffer[3040] = 8'h18;
 buffer[3041] = 8'h18;
 buffer[3042] = 8'h18;
 buffer[3043] = 8'h18;
 buffer[3044] = 8'h18;
 buffer[3045] = 8'hf8;
 buffer[3046] = 8'h18;
 buffer[3047] = 8'hf8;
 buffer[3048] = 8'h00;
 buffer[3049] = 8'h00;
 buffer[3050] = 8'h00;
 buffer[3051] = 8'h00;
 buffer[3052] = 8'h00;
 buffer[3053] = 8'h00;
 buffer[3054] = 8'h00;
 buffer[3055] = 8'h00;
 buffer[3056] = 8'h00;
 buffer[3057] = 8'h00;
 buffer[3058] = 8'h00;
 buffer[3059] = 8'h00;
 buffer[3060] = 8'h00;
 buffer[3061] = 8'h00;
 buffer[3062] = 8'h00;
 buffer[3063] = 8'hf8;
 buffer[3064] = 8'h18;
 buffer[3065] = 8'h18;
 buffer[3066] = 8'h18;
 buffer[3067] = 8'h18;
 buffer[3068] = 8'h18;
 buffer[3069] = 8'h18;
 buffer[3070] = 8'h18;
 buffer[3071] = 8'h18;
 buffer[3072] = 8'h18;
 buffer[3073] = 8'h18;
 buffer[3074] = 8'h18;
 buffer[3075] = 8'h18;
 buffer[3076] = 8'h18;
 buffer[3077] = 8'h18;
 buffer[3078] = 8'h18;
 buffer[3079] = 8'h1f;
 buffer[3080] = 8'h00;
 buffer[3081] = 8'h00;
 buffer[3082] = 8'h00;
 buffer[3083] = 8'h00;
 buffer[3084] = 8'h00;
 buffer[3085] = 8'h00;
 buffer[3086] = 8'h00;
 buffer[3087] = 8'h00;
 buffer[3088] = 8'h18;
 buffer[3089] = 8'h18;
 buffer[3090] = 8'h18;
 buffer[3091] = 8'h18;
 buffer[3092] = 8'h18;
 buffer[3093] = 8'h18;
 buffer[3094] = 8'h18;
 buffer[3095] = 8'hff;
 buffer[3096] = 8'h00;
 buffer[3097] = 8'h00;
 buffer[3098] = 8'h00;
 buffer[3099] = 8'h00;
 buffer[3100] = 8'h00;
 buffer[3101] = 8'h00;
 buffer[3102] = 8'h00;
 buffer[3103] = 8'h00;
 buffer[3104] = 8'h00;
 buffer[3105] = 8'h00;
 buffer[3106] = 8'h00;
 buffer[3107] = 8'h00;
 buffer[3108] = 8'h00;
 buffer[3109] = 8'h00;
 buffer[3110] = 8'h00;
 buffer[3111] = 8'hff;
 buffer[3112] = 8'h18;
 buffer[3113] = 8'h18;
 buffer[3114] = 8'h18;
 buffer[3115] = 8'h18;
 buffer[3116] = 8'h18;
 buffer[3117] = 8'h18;
 buffer[3118] = 8'h18;
 buffer[3119] = 8'h18;
 buffer[3120] = 8'h18;
 buffer[3121] = 8'h18;
 buffer[3122] = 8'h18;
 buffer[3123] = 8'h18;
 buffer[3124] = 8'h18;
 buffer[3125] = 8'h18;
 buffer[3126] = 8'h18;
 buffer[3127] = 8'h1f;
 buffer[3128] = 8'h18;
 buffer[3129] = 8'h18;
 buffer[3130] = 8'h18;
 buffer[3131] = 8'h18;
 buffer[3132] = 8'h18;
 buffer[3133] = 8'h18;
 buffer[3134] = 8'h18;
 buffer[3135] = 8'h18;
 buffer[3136] = 8'h00;
 buffer[3137] = 8'h00;
 buffer[3138] = 8'h00;
 buffer[3139] = 8'h00;
 buffer[3140] = 8'h00;
 buffer[3141] = 8'h00;
 buffer[3142] = 8'h00;
 buffer[3143] = 8'hff;
 buffer[3144] = 8'h00;
 buffer[3145] = 8'h00;
 buffer[3146] = 8'h00;
 buffer[3147] = 8'h00;
 buffer[3148] = 8'h00;
 buffer[3149] = 8'h00;
 buffer[3150] = 8'h00;
 buffer[3151] = 8'h00;
 buffer[3152] = 8'h18;
 buffer[3153] = 8'h18;
 buffer[3154] = 8'h18;
 buffer[3155] = 8'h18;
 buffer[3156] = 8'h18;
 buffer[3157] = 8'h18;
 buffer[3158] = 8'h18;
 buffer[3159] = 8'hff;
 buffer[3160] = 8'h18;
 buffer[3161] = 8'h18;
 buffer[3162] = 8'h18;
 buffer[3163] = 8'h18;
 buffer[3164] = 8'h18;
 buffer[3165] = 8'h18;
 buffer[3166] = 8'h18;
 buffer[3167] = 8'h18;
 buffer[3168] = 8'h18;
 buffer[3169] = 8'h18;
 buffer[3170] = 8'h18;
 buffer[3171] = 8'h18;
 buffer[3172] = 8'h18;
 buffer[3173] = 8'h1f;
 buffer[3174] = 8'h18;
 buffer[3175] = 8'h1f;
 buffer[3176] = 8'h18;
 buffer[3177] = 8'h18;
 buffer[3178] = 8'h18;
 buffer[3179] = 8'h18;
 buffer[3180] = 8'h18;
 buffer[3181] = 8'h18;
 buffer[3182] = 8'h18;
 buffer[3183] = 8'h18;
 buffer[3184] = 8'h36;
 buffer[3185] = 8'h36;
 buffer[3186] = 8'h36;
 buffer[3187] = 8'h36;
 buffer[3188] = 8'h36;
 buffer[3189] = 8'h36;
 buffer[3190] = 8'h36;
 buffer[3191] = 8'h37;
 buffer[3192] = 8'h36;
 buffer[3193] = 8'h36;
 buffer[3194] = 8'h36;
 buffer[3195] = 8'h36;
 buffer[3196] = 8'h36;
 buffer[3197] = 8'h36;
 buffer[3198] = 8'h36;
 buffer[3199] = 8'h36;
 buffer[3200] = 8'h36;
 buffer[3201] = 8'h36;
 buffer[3202] = 8'h36;
 buffer[3203] = 8'h36;
 buffer[3204] = 8'h36;
 buffer[3205] = 8'h37;
 buffer[3206] = 8'h30;
 buffer[3207] = 8'h3f;
 buffer[3208] = 8'h00;
 buffer[3209] = 8'h00;
 buffer[3210] = 8'h00;
 buffer[3211] = 8'h00;
 buffer[3212] = 8'h00;
 buffer[3213] = 8'h00;
 buffer[3214] = 8'h00;
 buffer[3215] = 8'h00;
 buffer[3216] = 8'h00;
 buffer[3217] = 8'h00;
 buffer[3218] = 8'h00;
 buffer[3219] = 8'h00;
 buffer[3220] = 8'h00;
 buffer[3221] = 8'h3f;
 buffer[3222] = 8'h30;
 buffer[3223] = 8'h37;
 buffer[3224] = 8'h36;
 buffer[3225] = 8'h36;
 buffer[3226] = 8'h36;
 buffer[3227] = 8'h36;
 buffer[3228] = 8'h36;
 buffer[3229] = 8'h36;
 buffer[3230] = 8'h36;
 buffer[3231] = 8'h36;
 buffer[3232] = 8'h36;
 buffer[3233] = 8'h36;
 buffer[3234] = 8'h36;
 buffer[3235] = 8'h36;
 buffer[3236] = 8'h36;
 buffer[3237] = 8'hf7;
 buffer[3238] = 8'h00;
 buffer[3239] = 8'hff;
 buffer[3240] = 8'h00;
 buffer[3241] = 8'h00;
 buffer[3242] = 8'h00;
 buffer[3243] = 8'h00;
 buffer[3244] = 8'h00;
 buffer[3245] = 8'h00;
 buffer[3246] = 8'h00;
 buffer[3247] = 8'h00;
 buffer[3248] = 8'h00;
 buffer[3249] = 8'h00;
 buffer[3250] = 8'h00;
 buffer[3251] = 8'h00;
 buffer[3252] = 8'h00;
 buffer[3253] = 8'hff;
 buffer[3254] = 8'h00;
 buffer[3255] = 8'hf7;
 buffer[3256] = 8'h36;
 buffer[3257] = 8'h36;
 buffer[3258] = 8'h36;
 buffer[3259] = 8'h36;
 buffer[3260] = 8'h36;
 buffer[3261] = 8'h36;
 buffer[3262] = 8'h36;
 buffer[3263] = 8'h36;
 buffer[3264] = 8'h36;
 buffer[3265] = 8'h36;
 buffer[3266] = 8'h36;
 buffer[3267] = 8'h36;
 buffer[3268] = 8'h36;
 buffer[3269] = 8'h37;
 buffer[3270] = 8'h30;
 buffer[3271] = 8'h37;
 buffer[3272] = 8'h36;
 buffer[3273] = 8'h36;
 buffer[3274] = 8'h36;
 buffer[3275] = 8'h36;
 buffer[3276] = 8'h36;
 buffer[3277] = 8'h36;
 buffer[3278] = 8'h36;
 buffer[3279] = 8'h36;
 buffer[3280] = 8'h00;
 buffer[3281] = 8'h00;
 buffer[3282] = 8'h00;
 buffer[3283] = 8'h00;
 buffer[3284] = 8'h00;
 buffer[3285] = 8'hff;
 buffer[3286] = 8'h00;
 buffer[3287] = 8'hff;
 buffer[3288] = 8'h00;
 buffer[3289] = 8'h00;
 buffer[3290] = 8'h00;
 buffer[3291] = 8'h00;
 buffer[3292] = 8'h00;
 buffer[3293] = 8'h00;
 buffer[3294] = 8'h00;
 buffer[3295] = 8'h00;
 buffer[3296] = 8'h36;
 buffer[3297] = 8'h36;
 buffer[3298] = 8'h36;
 buffer[3299] = 8'h36;
 buffer[3300] = 8'h36;
 buffer[3301] = 8'hf7;
 buffer[3302] = 8'h00;
 buffer[3303] = 8'hf7;
 buffer[3304] = 8'h36;
 buffer[3305] = 8'h36;
 buffer[3306] = 8'h36;
 buffer[3307] = 8'h36;
 buffer[3308] = 8'h36;
 buffer[3309] = 8'h36;
 buffer[3310] = 8'h36;
 buffer[3311] = 8'h36;
 buffer[3312] = 8'h18;
 buffer[3313] = 8'h18;
 buffer[3314] = 8'h18;
 buffer[3315] = 8'h18;
 buffer[3316] = 8'h18;
 buffer[3317] = 8'hff;
 buffer[3318] = 8'h00;
 buffer[3319] = 8'hff;
 buffer[3320] = 8'h00;
 buffer[3321] = 8'h00;
 buffer[3322] = 8'h00;
 buffer[3323] = 8'h00;
 buffer[3324] = 8'h00;
 buffer[3325] = 8'h00;
 buffer[3326] = 8'h00;
 buffer[3327] = 8'h00;
 buffer[3328] = 8'h36;
 buffer[3329] = 8'h36;
 buffer[3330] = 8'h36;
 buffer[3331] = 8'h36;
 buffer[3332] = 8'h36;
 buffer[3333] = 8'h36;
 buffer[3334] = 8'h36;
 buffer[3335] = 8'hff;
 buffer[3336] = 8'h00;
 buffer[3337] = 8'h00;
 buffer[3338] = 8'h00;
 buffer[3339] = 8'h00;
 buffer[3340] = 8'h00;
 buffer[3341] = 8'h00;
 buffer[3342] = 8'h00;
 buffer[3343] = 8'h00;
 buffer[3344] = 8'h00;
 buffer[3345] = 8'h00;
 buffer[3346] = 8'h00;
 buffer[3347] = 8'h00;
 buffer[3348] = 8'h00;
 buffer[3349] = 8'hff;
 buffer[3350] = 8'h00;
 buffer[3351] = 8'hff;
 buffer[3352] = 8'h18;
 buffer[3353] = 8'h18;
 buffer[3354] = 8'h18;
 buffer[3355] = 8'h18;
 buffer[3356] = 8'h18;
 buffer[3357] = 8'h18;
 buffer[3358] = 8'h18;
 buffer[3359] = 8'h18;
 buffer[3360] = 8'h00;
 buffer[3361] = 8'h00;
 buffer[3362] = 8'h00;
 buffer[3363] = 8'h00;
 buffer[3364] = 8'h00;
 buffer[3365] = 8'h00;
 buffer[3366] = 8'h00;
 buffer[3367] = 8'hff;
 buffer[3368] = 8'h36;
 buffer[3369] = 8'h36;
 buffer[3370] = 8'h36;
 buffer[3371] = 8'h36;
 buffer[3372] = 8'h36;
 buffer[3373] = 8'h36;
 buffer[3374] = 8'h36;
 buffer[3375] = 8'h36;
 buffer[3376] = 8'h36;
 buffer[3377] = 8'h36;
 buffer[3378] = 8'h36;
 buffer[3379] = 8'h36;
 buffer[3380] = 8'h36;
 buffer[3381] = 8'h36;
 buffer[3382] = 8'h36;
 buffer[3383] = 8'h3f;
 buffer[3384] = 8'h00;
 buffer[3385] = 8'h00;
 buffer[3386] = 8'h00;
 buffer[3387] = 8'h00;
 buffer[3388] = 8'h00;
 buffer[3389] = 8'h00;
 buffer[3390] = 8'h00;
 buffer[3391] = 8'h00;
 buffer[3392] = 8'h18;
 buffer[3393] = 8'h18;
 buffer[3394] = 8'h18;
 buffer[3395] = 8'h18;
 buffer[3396] = 8'h18;
 buffer[3397] = 8'h1f;
 buffer[3398] = 8'h18;
 buffer[3399] = 8'h1f;
 buffer[3400] = 8'h00;
 buffer[3401] = 8'h00;
 buffer[3402] = 8'h00;
 buffer[3403] = 8'h00;
 buffer[3404] = 8'h00;
 buffer[3405] = 8'h00;
 buffer[3406] = 8'h00;
 buffer[3407] = 8'h00;
 buffer[3408] = 8'h00;
 buffer[3409] = 8'h00;
 buffer[3410] = 8'h00;
 buffer[3411] = 8'h00;
 buffer[3412] = 8'h00;
 buffer[3413] = 8'h1f;
 buffer[3414] = 8'h18;
 buffer[3415] = 8'h1f;
 buffer[3416] = 8'h18;
 buffer[3417] = 8'h18;
 buffer[3418] = 8'h18;
 buffer[3419] = 8'h18;
 buffer[3420] = 8'h18;
 buffer[3421] = 8'h18;
 buffer[3422] = 8'h18;
 buffer[3423] = 8'h18;
 buffer[3424] = 8'h00;
 buffer[3425] = 8'h00;
 buffer[3426] = 8'h00;
 buffer[3427] = 8'h00;
 buffer[3428] = 8'h00;
 buffer[3429] = 8'h00;
 buffer[3430] = 8'h00;
 buffer[3431] = 8'h3f;
 buffer[3432] = 8'h36;
 buffer[3433] = 8'h36;
 buffer[3434] = 8'h36;
 buffer[3435] = 8'h36;
 buffer[3436] = 8'h36;
 buffer[3437] = 8'h36;
 buffer[3438] = 8'h36;
 buffer[3439] = 8'h36;
 buffer[3440] = 8'h36;
 buffer[3441] = 8'h36;
 buffer[3442] = 8'h36;
 buffer[3443] = 8'h36;
 buffer[3444] = 8'h36;
 buffer[3445] = 8'h36;
 buffer[3446] = 8'h36;
 buffer[3447] = 8'hff;
 buffer[3448] = 8'h36;
 buffer[3449] = 8'h36;
 buffer[3450] = 8'h36;
 buffer[3451] = 8'h36;
 buffer[3452] = 8'h36;
 buffer[3453] = 8'h36;
 buffer[3454] = 8'h36;
 buffer[3455] = 8'h36;
 buffer[3456] = 8'h18;
 buffer[3457] = 8'h18;
 buffer[3458] = 8'h18;
 buffer[3459] = 8'h18;
 buffer[3460] = 8'h18;
 buffer[3461] = 8'hff;
 buffer[3462] = 8'h18;
 buffer[3463] = 8'hff;
 buffer[3464] = 8'h18;
 buffer[3465] = 8'h18;
 buffer[3466] = 8'h18;
 buffer[3467] = 8'h18;
 buffer[3468] = 8'h18;
 buffer[3469] = 8'h18;
 buffer[3470] = 8'h18;
 buffer[3471] = 8'h18;
 buffer[3472] = 8'h18;
 buffer[3473] = 8'h18;
 buffer[3474] = 8'h18;
 buffer[3475] = 8'h18;
 buffer[3476] = 8'h18;
 buffer[3477] = 8'h18;
 buffer[3478] = 8'h18;
 buffer[3479] = 8'hf8;
 buffer[3480] = 8'h00;
 buffer[3481] = 8'h00;
 buffer[3482] = 8'h00;
 buffer[3483] = 8'h00;
 buffer[3484] = 8'h00;
 buffer[3485] = 8'h00;
 buffer[3486] = 8'h00;
 buffer[3487] = 8'h00;
 buffer[3488] = 8'h00;
 buffer[3489] = 8'h00;
 buffer[3490] = 8'h00;
 buffer[3491] = 8'h00;
 buffer[3492] = 8'h00;
 buffer[3493] = 8'h00;
 buffer[3494] = 8'h00;
 buffer[3495] = 8'h1f;
 buffer[3496] = 8'h18;
 buffer[3497] = 8'h18;
 buffer[3498] = 8'h18;
 buffer[3499] = 8'h18;
 buffer[3500] = 8'h18;
 buffer[3501] = 8'h18;
 buffer[3502] = 8'h18;
 buffer[3503] = 8'h18;
 buffer[3504] = 8'hff;
 buffer[3505] = 8'hff;
 buffer[3506] = 8'hff;
 buffer[3507] = 8'hff;
 buffer[3508] = 8'hff;
 buffer[3509] = 8'hff;
 buffer[3510] = 8'hff;
 buffer[3511] = 8'hff;
 buffer[3512] = 8'hff;
 buffer[3513] = 8'hff;
 buffer[3514] = 8'hff;
 buffer[3515] = 8'hff;
 buffer[3516] = 8'hff;
 buffer[3517] = 8'hff;
 buffer[3518] = 8'hff;
 buffer[3519] = 8'hff;
 buffer[3520] = 8'h00;
 buffer[3521] = 8'h00;
 buffer[3522] = 8'h00;
 buffer[3523] = 8'h00;
 buffer[3524] = 8'h00;
 buffer[3525] = 8'h00;
 buffer[3526] = 8'h00;
 buffer[3527] = 8'hff;
 buffer[3528] = 8'hff;
 buffer[3529] = 8'hff;
 buffer[3530] = 8'hff;
 buffer[3531] = 8'hff;
 buffer[3532] = 8'hff;
 buffer[3533] = 8'hff;
 buffer[3534] = 8'hff;
 buffer[3535] = 8'hff;
 buffer[3536] = 8'hf0;
 buffer[3537] = 8'hf0;
 buffer[3538] = 8'hf0;
 buffer[3539] = 8'hf0;
 buffer[3540] = 8'hf0;
 buffer[3541] = 8'hf0;
 buffer[3542] = 8'hf0;
 buffer[3543] = 8'hf0;
 buffer[3544] = 8'hf0;
 buffer[3545] = 8'hf0;
 buffer[3546] = 8'hf0;
 buffer[3547] = 8'hf0;
 buffer[3548] = 8'hf0;
 buffer[3549] = 8'hf0;
 buffer[3550] = 8'hf0;
 buffer[3551] = 8'hf0;
 buffer[3552] = 8'h0f;
 buffer[3553] = 8'h0f;
 buffer[3554] = 8'h0f;
 buffer[3555] = 8'h0f;
 buffer[3556] = 8'h0f;
 buffer[3557] = 8'h0f;
 buffer[3558] = 8'h0f;
 buffer[3559] = 8'h0f;
 buffer[3560] = 8'h0f;
 buffer[3561] = 8'h0f;
 buffer[3562] = 8'h0f;
 buffer[3563] = 8'h0f;
 buffer[3564] = 8'h0f;
 buffer[3565] = 8'h0f;
 buffer[3566] = 8'h0f;
 buffer[3567] = 8'h0f;
 buffer[3568] = 8'hff;
 buffer[3569] = 8'hff;
 buffer[3570] = 8'hff;
 buffer[3571] = 8'hff;
 buffer[3572] = 8'hff;
 buffer[3573] = 8'hff;
 buffer[3574] = 8'hff;
 buffer[3575] = 8'h00;
 buffer[3576] = 8'h00;
 buffer[3577] = 8'h00;
 buffer[3578] = 8'h00;
 buffer[3579] = 8'h00;
 buffer[3580] = 8'h00;
 buffer[3581] = 8'h00;
 buffer[3582] = 8'h00;
 buffer[3583] = 8'h00;
 buffer[3584] = 8'h00;
 buffer[3585] = 8'h00;
 buffer[3586] = 8'h00;
 buffer[3587] = 8'h00;
 buffer[3588] = 8'h00;
 buffer[3589] = 8'h76;
 buffer[3590] = 8'hdc;
 buffer[3591] = 8'hd8;
 buffer[3592] = 8'hd8;
 buffer[3593] = 8'hd8;
 buffer[3594] = 8'hdc;
 buffer[3595] = 8'h76;
 buffer[3596] = 8'h00;
 buffer[3597] = 8'h00;
 buffer[3598] = 8'h00;
 buffer[3599] = 8'h00;
 buffer[3600] = 8'h00;
 buffer[3601] = 8'h00;
 buffer[3602] = 8'h78;
 buffer[3603] = 8'hcc;
 buffer[3604] = 8'hcc;
 buffer[3605] = 8'hcc;
 buffer[3606] = 8'hd8;
 buffer[3607] = 8'hcc;
 buffer[3608] = 8'hc6;
 buffer[3609] = 8'hc6;
 buffer[3610] = 8'hc6;
 buffer[3611] = 8'hcc;
 buffer[3612] = 8'h00;
 buffer[3613] = 8'h00;
 buffer[3614] = 8'h00;
 buffer[3615] = 8'h00;
 buffer[3616] = 8'h00;
 buffer[3617] = 8'h00;
 buffer[3618] = 8'hfe;
 buffer[3619] = 8'hc6;
 buffer[3620] = 8'hc6;
 buffer[3621] = 8'hc0;
 buffer[3622] = 8'hc0;
 buffer[3623] = 8'hc0;
 buffer[3624] = 8'hc0;
 buffer[3625] = 8'hc0;
 buffer[3626] = 8'hc0;
 buffer[3627] = 8'hc0;
 buffer[3628] = 8'h00;
 buffer[3629] = 8'h00;
 buffer[3630] = 8'h00;
 buffer[3631] = 8'h00;
 buffer[3632] = 8'h00;
 buffer[3633] = 8'h00;
 buffer[3634] = 8'h00;
 buffer[3635] = 8'h00;
 buffer[3636] = 8'hfe;
 buffer[3637] = 8'h6c;
 buffer[3638] = 8'h6c;
 buffer[3639] = 8'h6c;
 buffer[3640] = 8'h6c;
 buffer[3641] = 8'h6c;
 buffer[3642] = 8'h6c;
 buffer[3643] = 8'h6c;
 buffer[3644] = 8'h00;
 buffer[3645] = 8'h00;
 buffer[3646] = 8'h00;
 buffer[3647] = 8'h00;
 buffer[3648] = 8'h00;
 buffer[3649] = 8'h00;
 buffer[3650] = 8'h00;
 buffer[3651] = 8'hfe;
 buffer[3652] = 8'hc6;
 buffer[3653] = 8'h60;
 buffer[3654] = 8'h30;
 buffer[3655] = 8'h18;
 buffer[3656] = 8'h30;
 buffer[3657] = 8'h60;
 buffer[3658] = 8'hc6;
 buffer[3659] = 8'hfe;
 buffer[3660] = 8'h00;
 buffer[3661] = 8'h00;
 buffer[3662] = 8'h00;
 buffer[3663] = 8'h00;
 buffer[3664] = 8'h00;
 buffer[3665] = 8'h00;
 buffer[3666] = 8'h00;
 buffer[3667] = 8'h00;
 buffer[3668] = 8'h00;
 buffer[3669] = 8'h7e;
 buffer[3670] = 8'hd8;
 buffer[3671] = 8'hd8;
 buffer[3672] = 8'hd8;
 buffer[3673] = 8'hd8;
 buffer[3674] = 8'hd8;
 buffer[3675] = 8'h70;
 buffer[3676] = 8'h00;
 buffer[3677] = 8'h00;
 buffer[3678] = 8'h00;
 buffer[3679] = 8'h00;
 buffer[3680] = 8'h00;
 buffer[3681] = 8'h00;
 buffer[3682] = 8'h00;
 buffer[3683] = 8'h00;
 buffer[3684] = 8'h66;
 buffer[3685] = 8'h66;
 buffer[3686] = 8'h66;
 buffer[3687] = 8'h66;
 buffer[3688] = 8'h66;
 buffer[3689] = 8'h7c;
 buffer[3690] = 8'h60;
 buffer[3691] = 8'h60;
 buffer[3692] = 8'hc0;
 buffer[3693] = 8'h00;
 buffer[3694] = 8'h00;
 buffer[3695] = 8'h00;
 buffer[3696] = 8'h00;
 buffer[3697] = 8'h00;
 buffer[3698] = 8'h00;
 buffer[3699] = 8'h00;
 buffer[3700] = 8'h76;
 buffer[3701] = 8'hdc;
 buffer[3702] = 8'h18;
 buffer[3703] = 8'h18;
 buffer[3704] = 8'h18;
 buffer[3705] = 8'h18;
 buffer[3706] = 8'h18;
 buffer[3707] = 8'h18;
 buffer[3708] = 8'h00;
 buffer[3709] = 8'h00;
 buffer[3710] = 8'h00;
 buffer[3711] = 8'h00;
 buffer[3712] = 8'h00;
 buffer[3713] = 8'h00;
 buffer[3714] = 8'h00;
 buffer[3715] = 8'h7e;
 buffer[3716] = 8'h18;
 buffer[3717] = 8'h3c;
 buffer[3718] = 8'h66;
 buffer[3719] = 8'h66;
 buffer[3720] = 8'h66;
 buffer[3721] = 8'h3c;
 buffer[3722] = 8'h18;
 buffer[3723] = 8'h7e;
 buffer[3724] = 8'h00;
 buffer[3725] = 8'h00;
 buffer[3726] = 8'h00;
 buffer[3727] = 8'h00;
 buffer[3728] = 8'h00;
 buffer[3729] = 8'h00;
 buffer[3730] = 8'h00;
 buffer[3731] = 8'h38;
 buffer[3732] = 8'h6c;
 buffer[3733] = 8'hc6;
 buffer[3734] = 8'hc6;
 buffer[3735] = 8'hfe;
 buffer[3736] = 8'hc6;
 buffer[3737] = 8'hc6;
 buffer[3738] = 8'h6c;
 buffer[3739] = 8'h38;
 buffer[3740] = 8'h00;
 buffer[3741] = 8'h00;
 buffer[3742] = 8'h00;
 buffer[3743] = 8'h00;
 buffer[3744] = 8'h00;
 buffer[3745] = 8'h00;
 buffer[3746] = 8'h38;
 buffer[3747] = 8'h6c;
 buffer[3748] = 8'hc6;
 buffer[3749] = 8'hc6;
 buffer[3750] = 8'hc6;
 buffer[3751] = 8'h6c;
 buffer[3752] = 8'h6c;
 buffer[3753] = 8'h6c;
 buffer[3754] = 8'h6c;
 buffer[3755] = 8'hee;
 buffer[3756] = 8'h00;
 buffer[3757] = 8'h00;
 buffer[3758] = 8'h00;
 buffer[3759] = 8'h00;
 buffer[3760] = 8'h00;
 buffer[3761] = 8'h00;
 buffer[3762] = 8'h1e;
 buffer[3763] = 8'h30;
 buffer[3764] = 8'h18;
 buffer[3765] = 8'h0c;
 buffer[3766] = 8'h3e;
 buffer[3767] = 8'h66;
 buffer[3768] = 8'h66;
 buffer[3769] = 8'h66;
 buffer[3770] = 8'h66;
 buffer[3771] = 8'h3c;
 buffer[3772] = 8'h00;
 buffer[3773] = 8'h00;
 buffer[3774] = 8'h00;
 buffer[3775] = 8'h00;
 buffer[3776] = 8'h00;
 buffer[3777] = 8'h00;
 buffer[3778] = 8'h00;
 buffer[3779] = 8'h00;
 buffer[3780] = 8'h00;
 buffer[3781] = 8'h7e;
 buffer[3782] = 8'hdb;
 buffer[3783] = 8'hdb;
 buffer[3784] = 8'hdb;
 buffer[3785] = 8'h7e;
 buffer[3786] = 8'h00;
 buffer[3787] = 8'h00;
 buffer[3788] = 8'h00;
 buffer[3789] = 8'h00;
 buffer[3790] = 8'h00;
 buffer[3791] = 8'h00;
 buffer[3792] = 8'h00;
 buffer[3793] = 8'h00;
 buffer[3794] = 8'h00;
 buffer[3795] = 8'h03;
 buffer[3796] = 8'h06;
 buffer[3797] = 8'h7e;
 buffer[3798] = 8'hdb;
 buffer[3799] = 8'hdb;
 buffer[3800] = 8'hf3;
 buffer[3801] = 8'h7e;
 buffer[3802] = 8'h60;
 buffer[3803] = 8'hc0;
 buffer[3804] = 8'h00;
 buffer[3805] = 8'h00;
 buffer[3806] = 8'h00;
 buffer[3807] = 8'h00;
 buffer[3808] = 8'h00;
 buffer[3809] = 8'h00;
 buffer[3810] = 8'h1c;
 buffer[3811] = 8'h30;
 buffer[3812] = 8'h60;
 buffer[3813] = 8'h60;
 buffer[3814] = 8'h7c;
 buffer[3815] = 8'h60;
 buffer[3816] = 8'h60;
 buffer[3817] = 8'h60;
 buffer[3818] = 8'h30;
 buffer[3819] = 8'h1c;
 buffer[3820] = 8'h00;
 buffer[3821] = 8'h00;
 buffer[3822] = 8'h00;
 buffer[3823] = 8'h00;
 buffer[3824] = 8'h00;
 buffer[3825] = 8'h00;
 buffer[3826] = 8'h00;
 buffer[3827] = 8'h7c;
 buffer[3828] = 8'hc6;
 buffer[3829] = 8'hc6;
 buffer[3830] = 8'hc6;
 buffer[3831] = 8'hc6;
 buffer[3832] = 8'hc6;
 buffer[3833] = 8'hc6;
 buffer[3834] = 8'hc6;
 buffer[3835] = 8'hc6;
 buffer[3836] = 8'h00;
 buffer[3837] = 8'h00;
 buffer[3838] = 8'h00;
 buffer[3839] = 8'h00;
 buffer[3840] = 8'h00;
 buffer[3841] = 8'h00;
 buffer[3842] = 8'h00;
 buffer[3843] = 8'h00;
 buffer[3844] = 8'hfe;
 buffer[3845] = 8'h00;
 buffer[3846] = 8'h00;
 buffer[3847] = 8'hfe;
 buffer[3848] = 8'h00;
 buffer[3849] = 8'h00;
 buffer[3850] = 8'hfe;
 buffer[3851] = 8'h00;
 buffer[3852] = 8'h00;
 buffer[3853] = 8'h00;
 buffer[3854] = 8'h00;
 buffer[3855] = 8'h00;
 buffer[3856] = 8'h00;
 buffer[3857] = 8'h00;
 buffer[3858] = 8'h00;
 buffer[3859] = 8'h00;
 buffer[3860] = 8'h18;
 buffer[3861] = 8'h18;
 buffer[3862] = 8'h7e;
 buffer[3863] = 8'h18;
 buffer[3864] = 8'h18;
 buffer[3865] = 8'h00;
 buffer[3866] = 8'h00;
 buffer[3867] = 8'hff;
 buffer[3868] = 8'h00;
 buffer[3869] = 8'h00;
 buffer[3870] = 8'h00;
 buffer[3871] = 8'h00;
 buffer[3872] = 8'h00;
 buffer[3873] = 8'h00;
 buffer[3874] = 8'h00;
 buffer[3875] = 8'h30;
 buffer[3876] = 8'h18;
 buffer[3877] = 8'h0c;
 buffer[3878] = 8'h06;
 buffer[3879] = 8'h0c;
 buffer[3880] = 8'h18;
 buffer[3881] = 8'h30;
 buffer[3882] = 8'h00;
 buffer[3883] = 8'h7e;
 buffer[3884] = 8'h00;
 buffer[3885] = 8'h00;
 buffer[3886] = 8'h00;
 buffer[3887] = 8'h00;
 buffer[3888] = 8'h00;
 buffer[3889] = 8'h00;
 buffer[3890] = 8'h00;
 buffer[3891] = 8'h0c;
 buffer[3892] = 8'h18;
 buffer[3893] = 8'h30;
 buffer[3894] = 8'h60;
 buffer[3895] = 8'h30;
 buffer[3896] = 8'h18;
 buffer[3897] = 8'h0c;
 buffer[3898] = 8'h00;
 buffer[3899] = 8'h7e;
 buffer[3900] = 8'h00;
 buffer[3901] = 8'h00;
 buffer[3902] = 8'h00;
 buffer[3903] = 8'h00;
 buffer[3904] = 8'h00;
 buffer[3905] = 8'h00;
 buffer[3906] = 8'h0e;
 buffer[3907] = 8'h1b;
 buffer[3908] = 8'h1b;
 buffer[3909] = 8'h18;
 buffer[3910] = 8'h18;
 buffer[3911] = 8'h18;
 buffer[3912] = 8'h18;
 buffer[3913] = 8'h18;
 buffer[3914] = 8'h18;
 buffer[3915] = 8'h18;
 buffer[3916] = 8'h18;
 buffer[3917] = 8'h18;
 buffer[3918] = 8'h18;
 buffer[3919] = 8'h18;
 buffer[3920] = 8'h18;
 buffer[3921] = 8'h18;
 buffer[3922] = 8'h18;
 buffer[3923] = 8'h18;
 buffer[3924] = 8'h18;
 buffer[3925] = 8'h18;
 buffer[3926] = 8'h18;
 buffer[3927] = 8'h18;
 buffer[3928] = 8'hd8;
 buffer[3929] = 8'hd8;
 buffer[3930] = 8'hd8;
 buffer[3931] = 8'h70;
 buffer[3932] = 8'h00;
 buffer[3933] = 8'h00;
 buffer[3934] = 8'h00;
 buffer[3935] = 8'h00;
 buffer[3936] = 8'h00;
 buffer[3937] = 8'h00;
 buffer[3938] = 8'h00;
 buffer[3939] = 8'h00;
 buffer[3940] = 8'h18;
 buffer[3941] = 8'h18;
 buffer[3942] = 8'h00;
 buffer[3943] = 8'h7e;
 buffer[3944] = 8'h00;
 buffer[3945] = 8'h18;
 buffer[3946] = 8'h18;
 buffer[3947] = 8'h00;
 buffer[3948] = 8'h00;
 buffer[3949] = 8'h00;
 buffer[3950] = 8'h00;
 buffer[3951] = 8'h00;
 buffer[3952] = 8'h00;
 buffer[3953] = 8'h00;
 buffer[3954] = 8'h00;
 buffer[3955] = 8'h00;
 buffer[3956] = 8'h00;
 buffer[3957] = 8'h76;
 buffer[3958] = 8'hdc;
 buffer[3959] = 8'h00;
 buffer[3960] = 8'h76;
 buffer[3961] = 8'hdc;
 buffer[3962] = 8'h00;
 buffer[3963] = 8'h00;
 buffer[3964] = 8'h00;
 buffer[3965] = 8'h00;
 buffer[3966] = 8'h00;
 buffer[3967] = 8'h00;
 buffer[3968] = 8'h00;
 buffer[3969] = 8'h38;
 buffer[3970] = 8'h6c;
 buffer[3971] = 8'h6c;
 buffer[3972] = 8'h38;
 buffer[3973] = 8'h00;
 buffer[3974] = 8'h00;
 buffer[3975] = 8'h00;
 buffer[3976] = 8'h00;
 buffer[3977] = 8'h00;
 buffer[3978] = 8'h00;
 buffer[3979] = 8'h00;
 buffer[3980] = 8'h00;
 buffer[3981] = 8'h00;
 buffer[3982] = 8'h00;
 buffer[3983] = 8'h00;
 buffer[3984] = 8'h00;
 buffer[3985] = 8'h00;
 buffer[3986] = 8'h00;
 buffer[3987] = 8'h00;
 buffer[3988] = 8'h00;
 buffer[3989] = 8'h00;
 buffer[3990] = 8'h00;
 buffer[3991] = 8'h18;
 buffer[3992] = 8'h18;
 buffer[3993] = 8'h00;
 buffer[3994] = 8'h00;
 buffer[3995] = 8'h00;
 buffer[3996] = 8'h00;
 buffer[3997] = 8'h00;
 buffer[3998] = 8'h00;
 buffer[3999] = 8'h00;
 buffer[4000] = 8'h00;
 buffer[4001] = 8'h00;
 buffer[4002] = 8'h00;
 buffer[4003] = 8'h00;
 buffer[4004] = 8'h00;
 buffer[4005] = 8'h00;
 buffer[4006] = 8'h00;
 buffer[4007] = 8'h00;
 buffer[4008] = 8'h18;
 buffer[4009] = 8'h00;
 buffer[4010] = 8'h00;
 buffer[4011] = 8'h00;
 buffer[4012] = 8'h00;
 buffer[4013] = 8'h00;
 buffer[4014] = 8'h00;
 buffer[4015] = 8'h00;
 buffer[4016] = 8'h00;
 buffer[4017] = 8'h0f;
 buffer[4018] = 8'h0c;
 buffer[4019] = 8'h0c;
 buffer[4020] = 8'h0c;
 buffer[4021] = 8'h0c;
 buffer[4022] = 8'h0c;
 buffer[4023] = 8'hec;
 buffer[4024] = 8'h6c;
 buffer[4025] = 8'h6c;
 buffer[4026] = 8'h3c;
 buffer[4027] = 8'h1c;
 buffer[4028] = 8'h00;
 buffer[4029] = 8'h00;
 buffer[4030] = 8'h00;
 buffer[4031] = 8'h00;
 buffer[4032] = 8'h00;
 buffer[4033] = 8'hd8;
 buffer[4034] = 8'h6c;
 buffer[4035] = 8'h6c;
 buffer[4036] = 8'h6c;
 buffer[4037] = 8'h6c;
 buffer[4038] = 8'h6c;
 buffer[4039] = 8'h00;
 buffer[4040] = 8'h00;
 buffer[4041] = 8'h00;
 buffer[4042] = 8'h00;
 buffer[4043] = 8'h00;
 buffer[4044] = 8'h00;
 buffer[4045] = 8'h00;
 buffer[4046] = 8'h00;
 buffer[4047] = 8'h00;
 buffer[4048] = 8'h00;
 buffer[4049] = 8'h70;
 buffer[4050] = 8'hd8;
 buffer[4051] = 8'h30;
 buffer[4052] = 8'h60;
 buffer[4053] = 8'hc8;
 buffer[4054] = 8'hf8;
 buffer[4055] = 8'h00;
 buffer[4056] = 8'h00;
 buffer[4057] = 8'h00;
 buffer[4058] = 8'h00;
 buffer[4059] = 8'h00;
 buffer[4060] = 8'h00;
 buffer[4061] = 8'h00;
 buffer[4062] = 8'h00;
 buffer[4063] = 8'h00;
 buffer[4064] = 8'h00;
 buffer[4065] = 8'h00;
 buffer[4066] = 8'h00;
 buffer[4067] = 8'h00;
 buffer[4068] = 8'h7c;
 buffer[4069] = 8'h7c;
 buffer[4070] = 8'h7c;
 buffer[4071] = 8'h7c;
 buffer[4072] = 8'h7c;
 buffer[4073] = 8'h7c;
 buffer[4074] = 8'h7c;
 buffer[4075] = 8'h00;
 buffer[4076] = 8'h00;
 buffer[4077] = 8'h00;
 buffer[4078] = 8'h00;
 buffer[4079] = 8'h00;
 buffer[4080] = 8'h00;
 buffer[4081] = 8'h00;
 buffer[4082] = 8'h00;
 buffer[4083] = 8'h00;
 buffer[4084] = 8'h00;
 buffer[4085] = 8'h00;
 buffer[4086] = 8'h00;
 buffer[4087] = 8'h00;
 buffer[4088] = 8'h00;
 buffer[4089] = 8'h00;
 buffer[4090] = 8'h00;
 buffer[4091] = 8'h00;
 buffer[4092] = 8'h00;
 buffer[4093] = 8'h00;
 buffer[4094] = 8'h00;
 buffer[4095] = 8'h00;
end

endmodule

module M_character_map_mem_charactermap(
input      [11:0]                in_charactermap_addr0,
output reg  [20:0]     out_charactermap_rdata0,
output reg  [20:0]     out_charactermap_rdata1,
input      [0:0]             in_charactermap_wenable1,
input      [20:0]                 in_charactermap_wdata1,
input      [11:0]                in_charactermap_addr1,
input      clock0,
input      clock1
);
reg  [20:0] buffer[2399:0];
always @(posedge clock0) begin
  out_charactermap_rdata0 <= buffer[in_charactermap_addr0];
end
always @(posedge clock1) begin
  if (in_charactermap_wenable1) begin
    buffer[in_charactermap_addr1] <= in_charactermap_wdata1;
  end
end
initial begin
 buffer[0] = 21'b100000000000000000000;
 buffer[1] = 21'b100000000000000000000;
 buffer[2] = 21'b100000000000000000000;
 buffer[3] = 21'b100000000000000000000;
 buffer[4] = 21'b100000000000000000000;
 buffer[5] = 21'b100000000000000000000;
 buffer[6] = 21'b100000000000000000000;
 buffer[7] = 21'b100000000000000000000;
 buffer[8] = 21'b100000000000000000000;
 buffer[9] = 21'b100000000000000000000;
 buffer[10] = 21'b100000000000000000000;
 buffer[11] = 21'b100000000000000000000;
 buffer[12] = 21'b100000000000000000000;
 buffer[13] = 21'b100000000000000000000;
 buffer[14] = 21'b100000000000000000000;
 buffer[15] = 21'b100000000000000000000;
 buffer[16] = 21'b100000000000000000000;
 buffer[17] = 21'b100000000000000000000;
 buffer[18] = 21'b100000000000000000000;
 buffer[19] = 21'b100000000000000000000;
 buffer[20] = 21'b100000000000000000000;
 buffer[21] = 21'b100000000000000000000;
 buffer[22] = 21'b100000000000000000000;
 buffer[23] = 21'b100000000000000000000;
 buffer[24] = 21'b100000000000000000000;
 buffer[25] = 21'b100000000000000000000;
 buffer[26] = 21'b100000000000000000000;
 buffer[27] = 21'b100000000000000000000;
 buffer[28] = 21'b100000000000000000000;
 buffer[29] = 21'b100000000000000000000;
 buffer[30] = 21'b100000000000000000000;
 buffer[31] = 21'b100000000000000000000;
 buffer[32] = 21'b100000000000000000000;
 buffer[33] = 21'b100000000000000000000;
 buffer[34] = 21'b100000000000000000000;
 buffer[35] = 21'b100000000000000000000;
 buffer[36] = 21'b100000000000000000000;
 buffer[37] = 21'b100000000000000000000;
 buffer[38] = 21'b100000000000000000000;
 buffer[39] = 21'b100000000000000000000;
 buffer[40] = 21'b100000000000000000000;
 buffer[41] = 21'b100000000000000000000;
 buffer[42] = 21'b100000000000000000000;
 buffer[43] = 21'b100000000000000000000;
 buffer[44] = 21'b100000000000000000000;
 buffer[45] = 21'b100000000000000000000;
 buffer[46] = 21'b100000000000000000000;
 buffer[47] = 21'b100000000000000000000;
 buffer[48] = 21'b100000000000000000000;
 buffer[49] = 21'b100000000000000000000;
 buffer[50] = 21'b100000000000000000000;
 buffer[51] = 21'b100000000000000000000;
 buffer[52] = 21'b100000000000000000000;
 buffer[53] = 21'b100000000000000000000;
 buffer[54] = 21'b100000000000000000000;
 buffer[55] = 21'b100000000000000000000;
 buffer[56] = 21'b100000000000000000000;
 buffer[57] = 21'b100000000000000000000;
 buffer[58] = 21'b100000000000000000000;
 buffer[59] = 21'b100000000000000000000;
 buffer[60] = 21'b100000000000000000000;
 buffer[61] = 21'b100000000000000000000;
 buffer[62] = 21'b100000000000000000000;
 buffer[63] = 21'b100000000000000000000;
 buffer[64] = 21'b100000000000000000000;
 buffer[65] = 21'b100000000000000000000;
 buffer[66] = 21'b100000000000000000000;
 buffer[67] = 21'b100000000000000000000;
 buffer[68] = 21'b100000000000000000000;
 buffer[69] = 21'b100000000000000000000;
 buffer[70] = 21'b100000000000000000000;
 buffer[71] = 21'b100000000000000000000;
 buffer[72] = 21'b100000000000000000000;
 buffer[73] = 21'b100000000000000000000;
 buffer[74] = 21'b100000000000000000000;
 buffer[75] = 21'b100000000000000000000;
 buffer[76] = 21'b100000000000000000000;
 buffer[77] = 21'b100000000000000000000;
 buffer[78] = 21'b100000000000000000000;
 buffer[79] = 21'b100000000000000000000;
 buffer[80] = 21'b100000000000000000000;
 buffer[81] = 21'b100000000000000000000;
 buffer[82] = 21'b100000000000000000000;
 buffer[83] = 21'b100000000000000000000;
 buffer[84] = 21'b100000000000000000000;
 buffer[85] = 21'b100000000000000000000;
 buffer[86] = 21'b100000000000000000000;
 buffer[87] = 21'b100000000000000000000;
 buffer[88] = 21'b100000000000000000000;
 buffer[89] = 21'b100000000000000000000;
 buffer[90] = 21'b100000000000000000000;
 buffer[91] = 21'b100000000000000000000;
 buffer[92] = 21'b100000000000000000000;
 buffer[93] = 21'b100000000000000000000;
 buffer[94] = 21'b100000000000000000000;
 buffer[95] = 21'b100000000000000000000;
 buffer[96] = 21'b100000000000000000000;
 buffer[97] = 21'b100000000000000000000;
 buffer[98] = 21'b100000000000000000000;
 buffer[99] = 21'b100000000000000000000;
 buffer[100] = 21'b100000000000000000000;
 buffer[101] = 21'b100000000000000000000;
 buffer[102] = 21'b100000000000000000000;
 buffer[103] = 21'b100000000000000000000;
 buffer[104] = 21'b100000000000000000000;
 buffer[105] = 21'b100000000000000000000;
 buffer[106] = 21'b100000000000000000000;
 buffer[107] = 21'b100000000000000000000;
 buffer[108] = 21'b100000000000000000000;
 buffer[109] = 21'b100000000000000000000;
 buffer[110] = 21'b100000000000000000000;
 buffer[111] = 21'b100000000000000000000;
 buffer[112] = 21'b100000000000000000000;
 buffer[113] = 21'b100000000000000000000;
 buffer[114] = 21'b100000000000000000000;
 buffer[115] = 21'b100000000000000000000;
 buffer[116] = 21'b100000000000000000000;
 buffer[117] = 21'b100000000000000000000;
 buffer[118] = 21'b100000000000000000000;
 buffer[119] = 21'b100000000000000000000;
 buffer[120] = 21'b100000000000000000000;
 buffer[121] = 21'b100000000000000000000;
 buffer[122] = 21'b100000000000000000000;
 buffer[123] = 21'b100000000000000000000;
 buffer[124] = 21'b100000000000000000000;
 buffer[125] = 21'b100000000000000000000;
 buffer[126] = 21'b100000000000000000000;
 buffer[127] = 21'b100000000000000000000;
 buffer[128] = 21'b100000000000000000000;
 buffer[129] = 21'b100000000000000000000;
 buffer[130] = 21'b100000000000000000000;
 buffer[131] = 21'b100000000000000000000;
 buffer[132] = 21'b100000000000000000000;
 buffer[133] = 21'b100000000000000000000;
 buffer[134] = 21'b100000000000000000000;
 buffer[135] = 21'b100000000000000000000;
 buffer[136] = 21'b100000000000000000000;
 buffer[137] = 21'b100000000000000000000;
 buffer[138] = 21'b100000000000000000000;
 buffer[139] = 21'b100000000000000000000;
 buffer[140] = 21'b100000000000000000000;
 buffer[141] = 21'b100000000000000000000;
 buffer[142] = 21'b100000000000000000000;
 buffer[143] = 21'b100000000000000000000;
 buffer[144] = 21'b100000000000000000000;
 buffer[145] = 21'b100000000000000000000;
 buffer[146] = 21'b100000000000000000000;
 buffer[147] = 21'b100000000000000000000;
 buffer[148] = 21'b100000000000000000000;
 buffer[149] = 21'b100000000000000000000;
 buffer[150] = 21'b100000000000000000000;
 buffer[151] = 21'b100000000000000000000;
 buffer[152] = 21'b100000000000000000000;
 buffer[153] = 21'b100000000000000000000;
 buffer[154] = 21'b100000000000000000000;
 buffer[155] = 21'b100000000000000000000;
 buffer[156] = 21'b100000000000000000000;
 buffer[157] = 21'b100000000000000000000;
 buffer[158] = 21'b100000000000000000000;
 buffer[159] = 21'b100000000000000000000;
 buffer[160] = 21'b100000000000000000000;
 buffer[161] = 21'b100000000000000000000;
 buffer[162] = 21'b100000000000000000000;
 buffer[163] = 21'b100000000000000000000;
 buffer[164] = 21'b100000000000000000000;
 buffer[165] = 21'b100000000000000000000;
 buffer[166] = 21'b100000000000000000000;
 buffer[167] = 21'b100000000000000000000;
 buffer[168] = 21'b100000000000000000000;
 buffer[169] = 21'b100000000000000000000;
 buffer[170] = 21'b100000000000000000000;
 buffer[171] = 21'b100000000000000000000;
 buffer[172] = 21'b100000000000000000000;
 buffer[173] = 21'b100000000000000000000;
 buffer[174] = 21'b100000000000000000000;
 buffer[175] = 21'b100000000000000000000;
 buffer[176] = 21'b100000000000000000000;
 buffer[177] = 21'b100000000000000000000;
 buffer[178] = 21'b100000000000000000000;
 buffer[179] = 21'b100000000000000000000;
 buffer[180] = 21'b100000000000000000000;
 buffer[181] = 21'b100000000000000000000;
 buffer[182] = 21'b100000000000000000000;
 buffer[183] = 21'b100000000000000000000;
 buffer[184] = 21'b100000000000000000000;
 buffer[185] = 21'b100000000000000000000;
 buffer[186] = 21'b100000000000000000000;
 buffer[187] = 21'b100000000000000000000;
 buffer[188] = 21'b100000000000000000000;
 buffer[189] = 21'b100000000000000000000;
 buffer[190] = 21'b100000000000000000000;
 buffer[191] = 21'b100000000000000000000;
 buffer[192] = 21'b100000000000000000000;
 buffer[193] = 21'b100000000000000000000;
 buffer[194] = 21'b100000000000000000000;
 buffer[195] = 21'b100000000000000000000;
 buffer[196] = 21'b100000000000000000000;
 buffer[197] = 21'b100000000000000000000;
 buffer[198] = 21'b100000000000000000000;
 buffer[199] = 21'b100000000000000000000;
 buffer[200] = 21'b100000000000000000000;
 buffer[201] = 21'b100000000000000000000;
 buffer[202] = 21'b100000000000000000000;
 buffer[203] = 21'b100000000000000000000;
 buffer[204] = 21'b100000000000000000000;
 buffer[205] = 21'b100000000000000000000;
 buffer[206] = 21'b100000000000000000000;
 buffer[207] = 21'b100000000000000000000;
 buffer[208] = 21'b100000000000000000000;
 buffer[209] = 21'b100000000000000000000;
 buffer[210] = 21'b100000000000000000000;
 buffer[211] = 21'b100000000000000000000;
 buffer[212] = 21'b100000000000000000000;
 buffer[213] = 21'b100000000000000000000;
 buffer[214] = 21'b100000000000000000000;
 buffer[215] = 21'b100000000000000000000;
 buffer[216] = 21'b100000000000000000000;
 buffer[217] = 21'b100000000000000000000;
 buffer[218] = 21'b100000000000000000000;
 buffer[219] = 21'b100000000000000000000;
 buffer[220] = 21'b100000000000000000000;
 buffer[221] = 21'b100000000000000000000;
 buffer[222] = 21'b100000000000000000000;
 buffer[223] = 21'b100000000000000000000;
 buffer[224] = 21'b100000000000000000000;
 buffer[225] = 21'b100000000000000000000;
 buffer[226] = 21'b100000000000000000000;
 buffer[227] = 21'b100000000000000000000;
 buffer[228] = 21'b100000000000000000000;
 buffer[229] = 21'b100000000000000000000;
 buffer[230] = 21'b100000000000000000000;
 buffer[231] = 21'b100000000000000000000;
 buffer[232] = 21'b100000000000000000000;
 buffer[233] = 21'b100000000000000000000;
 buffer[234] = 21'b100000000000000000000;
 buffer[235] = 21'b100000000000000000000;
 buffer[236] = 21'b100000000000000000000;
 buffer[237] = 21'b100000000000000000000;
 buffer[238] = 21'b100000000000000000000;
 buffer[239] = 21'b100000000000000000000;
 buffer[240] = 21'b100000000000000000000;
 buffer[241] = 21'b100000000000000000000;
 buffer[242] = 21'b100000000000000000000;
 buffer[243] = 21'b100000000000000000000;
 buffer[244] = 21'b100000000000000000000;
 buffer[245] = 21'b100000000000000000000;
 buffer[246] = 21'b100000000000000000000;
 buffer[247] = 21'b100000000000000000000;
 buffer[248] = 21'b100000000000000000000;
 buffer[249] = 21'b100000000000000000000;
 buffer[250] = 21'b100000000000000000000;
 buffer[251] = 21'b100000000000000000000;
 buffer[252] = 21'b100000000000000000000;
 buffer[253] = 21'b100000000000000000000;
 buffer[254] = 21'b100000000000000000000;
 buffer[255] = 21'b100000000000000000000;
 buffer[256] = 21'b100000000000000000000;
 buffer[257] = 21'b100000000000000000000;
 buffer[258] = 21'b100000000000000000000;
 buffer[259] = 21'b100000000000000000000;
 buffer[260] = 21'b100000000000000000000;
 buffer[261] = 21'b100000000000000000000;
 buffer[262] = 21'b100000000000000000000;
 buffer[263] = 21'b100000000000000000000;
 buffer[264] = 21'b100000000000000000000;
 buffer[265] = 21'b100000000000000000000;
 buffer[266] = 21'b100000000000000000000;
 buffer[267] = 21'b100000000000000000000;
 buffer[268] = 21'b100000000000000000000;
 buffer[269] = 21'b100000000000000000000;
 buffer[270] = 21'b100000000000000000000;
 buffer[271] = 21'b100000000000000000000;
 buffer[272] = 21'b100000000000000000000;
 buffer[273] = 21'b100000000000000000000;
 buffer[274] = 21'b100000000000000000000;
 buffer[275] = 21'b100000000000000000000;
 buffer[276] = 21'b100000000000000000000;
 buffer[277] = 21'b100000000000000000000;
 buffer[278] = 21'b100000000000000000000;
 buffer[279] = 21'b100000000000000000000;
 buffer[280] = 21'b100000000000000000000;
 buffer[281] = 21'b100000000000000000000;
 buffer[282] = 21'b100000000000000000000;
 buffer[283] = 21'b100000000000000000000;
 buffer[284] = 21'b100000000000000000000;
 buffer[285] = 21'b100000000000000000000;
 buffer[286] = 21'b100000000000000000000;
 buffer[287] = 21'b100000000000000000000;
 buffer[288] = 21'b100000000000000000000;
 buffer[289] = 21'b100000000000000000000;
 buffer[290] = 21'b100000000000000000000;
 buffer[291] = 21'b100000000000000000000;
 buffer[292] = 21'b100000000000000000000;
 buffer[293] = 21'b100000000000000000000;
 buffer[294] = 21'b100000000000000000000;
 buffer[295] = 21'b100000000000000000000;
 buffer[296] = 21'b100000000000000000000;
 buffer[297] = 21'b100000000000000000000;
 buffer[298] = 21'b100000000000000000000;
 buffer[299] = 21'b100000000000000000000;
 buffer[300] = 21'b100000000000000000000;
 buffer[301] = 21'b100000000000000000000;
 buffer[302] = 21'b100000000000000000000;
 buffer[303] = 21'b100000000000000000000;
 buffer[304] = 21'b100000000000000000000;
 buffer[305] = 21'b100000000000000000000;
 buffer[306] = 21'b100000000000000000000;
 buffer[307] = 21'b100000000000000000000;
 buffer[308] = 21'b100000000000000000000;
 buffer[309] = 21'b100000000000000000000;
 buffer[310] = 21'b100000000000000000000;
 buffer[311] = 21'b100000000000000000000;
 buffer[312] = 21'b100000000000000000000;
 buffer[313] = 21'b100000000000000000000;
 buffer[314] = 21'b100000000000000000000;
 buffer[315] = 21'b100000000000000000000;
 buffer[316] = 21'b100000000000000000000;
 buffer[317] = 21'b100000000000000000000;
 buffer[318] = 21'b100000000000000000000;
 buffer[319] = 21'b100000000000000000000;
 buffer[320] = 21'b100000000000000000000;
 buffer[321] = 21'b100000000000000000000;
 buffer[322] = 21'b100000000000000000000;
 buffer[323] = 21'b100000000000000000000;
 buffer[324] = 21'b100000000000000000000;
 buffer[325] = 21'b100000000000000000000;
 buffer[326] = 21'b100000000000000000000;
 buffer[327] = 21'b100000000000000000000;
 buffer[328] = 21'b100000000000000000000;
 buffer[329] = 21'b100000000000000000000;
 buffer[330] = 21'b100000000000000000000;
 buffer[331] = 21'b100000000000000000000;
 buffer[332] = 21'b100000000000000000000;
 buffer[333] = 21'b100000000000000000000;
 buffer[334] = 21'b100000000000000000000;
 buffer[335] = 21'b100000000000000000000;
 buffer[336] = 21'b100000000000000000000;
 buffer[337] = 21'b100000000000000000000;
 buffer[338] = 21'b100000000000000000000;
 buffer[339] = 21'b100000000000000000000;
 buffer[340] = 21'b100000000000000000000;
 buffer[341] = 21'b100000000000000000000;
 buffer[342] = 21'b100000000000000000000;
 buffer[343] = 21'b100000000000000000000;
 buffer[344] = 21'b100000000000000000000;
 buffer[345] = 21'b100000000000000000000;
 buffer[346] = 21'b100000000000000000000;
 buffer[347] = 21'b100000000000000000000;
 buffer[348] = 21'b100000000000000000000;
 buffer[349] = 21'b100000000000000000000;
 buffer[350] = 21'b100000000000000000000;
 buffer[351] = 21'b100000000000000000000;
 buffer[352] = 21'b100000000000000000000;
 buffer[353] = 21'b100000000000000000000;
 buffer[354] = 21'b100000000000000000000;
 buffer[355] = 21'b100000000000000000000;
 buffer[356] = 21'b100000000000000000000;
 buffer[357] = 21'b100000000000000000000;
 buffer[358] = 21'b100000000000000000000;
 buffer[359] = 21'b100000000000000000000;
 buffer[360] = 21'b100000000000000000000;
 buffer[361] = 21'b100000000000000000000;
 buffer[362] = 21'b100000000000000000000;
 buffer[363] = 21'b100000000000000000000;
 buffer[364] = 21'b100000000000000000000;
 buffer[365] = 21'b100000000000000000000;
 buffer[366] = 21'b100000000000000000000;
 buffer[367] = 21'b100000000000000000000;
 buffer[368] = 21'b100000000000000000000;
 buffer[369] = 21'b100000000000000000000;
 buffer[370] = 21'b100000000000000000000;
 buffer[371] = 21'b100000000000000000000;
 buffer[372] = 21'b100000000000000000000;
 buffer[373] = 21'b100000000000000000000;
 buffer[374] = 21'b100000000000000000000;
 buffer[375] = 21'b100000000000000000000;
 buffer[376] = 21'b100000000000000000000;
 buffer[377] = 21'b100000000000000000000;
 buffer[378] = 21'b100000000000000000000;
 buffer[379] = 21'b100000000000000000000;
 buffer[380] = 21'b100000000000000000000;
 buffer[381] = 21'b100000000000000000000;
 buffer[382] = 21'b100000000000000000000;
 buffer[383] = 21'b100000000000000000000;
 buffer[384] = 21'b100000000000000000000;
 buffer[385] = 21'b100000000000000000000;
 buffer[386] = 21'b100000000000000000000;
 buffer[387] = 21'b100000000000000000000;
 buffer[388] = 21'b100000000000000000000;
 buffer[389] = 21'b100000000000000000000;
 buffer[390] = 21'b100000000000000000000;
 buffer[391] = 21'b100000000000000000000;
 buffer[392] = 21'b100000000000000000000;
 buffer[393] = 21'b100000000000000000000;
 buffer[394] = 21'b100000000000000000000;
 buffer[395] = 21'b100000000000000000000;
 buffer[396] = 21'b100000000000000000000;
 buffer[397] = 21'b100000000000000000000;
 buffer[398] = 21'b100000000000000000000;
 buffer[399] = 21'b100000000000000000000;
 buffer[400] = 21'b100000000000000000000;
 buffer[401] = 21'b100000000000000000000;
 buffer[402] = 21'b100000000000000000000;
 buffer[403] = 21'b100000000000000000000;
 buffer[404] = 21'b100000000000000000000;
 buffer[405] = 21'b100000000000000000000;
 buffer[406] = 21'b100000000000000000000;
 buffer[407] = 21'b100000000000000000000;
 buffer[408] = 21'b100000000000000000000;
 buffer[409] = 21'b100000000000000000000;
 buffer[410] = 21'b100000000000000000000;
 buffer[411] = 21'b100000000000000000000;
 buffer[412] = 21'b100000000000000000000;
 buffer[413] = 21'b100000000000000000000;
 buffer[414] = 21'b100000000000000000000;
 buffer[415] = 21'b100000000000000000000;
 buffer[416] = 21'b100000000000000000000;
 buffer[417] = 21'b100000000000000000000;
 buffer[418] = 21'b100000000000000000000;
 buffer[419] = 21'b100000000000000000000;
 buffer[420] = 21'b100000000000000000000;
 buffer[421] = 21'b100000000000000000000;
 buffer[422] = 21'b100000000000000000000;
 buffer[423] = 21'b100000000000000000000;
 buffer[424] = 21'b100000000000000000000;
 buffer[425] = 21'b100000000000000000000;
 buffer[426] = 21'b100000000000000000000;
 buffer[427] = 21'b100000000000000000000;
 buffer[428] = 21'b100000000000000000000;
 buffer[429] = 21'b100000000000000000000;
 buffer[430] = 21'b100000000000000000000;
 buffer[431] = 21'b100000000000000000000;
 buffer[432] = 21'b100000000000000000000;
 buffer[433] = 21'b100000000000000000000;
 buffer[434] = 21'b100000000000000000000;
 buffer[435] = 21'b100000000000000000000;
 buffer[436] = 21'b100000000000000000000;
 buffer[437] = 21'b100000000000000000000;
 buffer[438] = 21'b100000000000000000000;
 buffer[439] = 21'b100000000000000000000;
 buffer[440] = 21'b100000000000000000000;
 buffer[441] = 21'b100000000000000000000;
 buffer[442] = 21'b100000000000000000000;
 buffer[443] = 21'b100000000000000000000;
 buffer[444] = 21'b100000000000000000000;
 buffer[445] = 21'b100000000000000000000;
 buffer[446] = 21'b100000000000000000000;
 buffer[447] = 21'b100000000000000000000;
 buffer[448] = 21'b100000000000000000000;
 buffer[449] = 21'b100000000000000000000;
 buffer[450] = 21'b100000000000000000000;
 buffer[451] = 21'b100000000000000000000;
 buffer[452] = 21'b100000000000000000000;
 buffer[453] = 21'b100000000000000000000;
 buffer[454] = 21'b100000000000000000000;
 buffer[455] = 21'b100000000000000000000;
 buffer[456] = 21'b100000000000000000000;
 buffer[457] = 21'b100000000000000000000;
 buffer[458] = 21'b100000000000000000000;
 buffer[459] = 21'b100000000000000000000;
 buffer[460] = 21'b100000000000000000000;
 buffer[461] = 21'b100000000000000000000;
 buffer[462] = 21'b100000000000000000000;
 buffer[463] = 21'b100000000000000000000;
 buffer[464] = 21'b100000000000000000000;
 buffer[465] = 21'b100000000000000000000;
 buffer[466] = 21'b100000000000000000000;
 buffer[467] = 21'b100000000000000000000;
 buffer[468] = 21'b100000000000000000000;
 buffer[469] = 21'b100000000000000000000;
 buffer[470] = 21'b100000000000000000000;
 buffer[471] = 21'b100000000000000000000;
 buffer[472] = 21'b100000000000000000000;
 buffer[473] = 21'b100000000000000000000;
 buffer[474] = 21'b100000000000000000000;
 buffer[475] = 21'b100000000000000000000;
 buffer[476] = 21'b100000000000000000000;
 buffer[477] = 21'b100000000000000000000;
 buffer[478] = 21'b100000000000000000000;
 buffer[479] = 21'b100000000000000000000;
 buffer[480] = 21'b100000000000000000000;
 buffer[481] = 21'b100000000000000000000;
 buffer[482] = 21'b100000000000000000000;
 buffer[483] = 21'b100000000000000000000;
 buffer[484] = 21'b100000000000000000000;
 buffer[485] = 21'b100000000000000000000;
 buffer[486] = 21'b100000000000000000000;
 buffer[487] = 21'b100000000000000000000;
 buffer[488] = 21'b100000000000000000000;
 buffer[489] = 21'b100000000000000000000;
 buffer[490] = 21'b100000000000000000000;
 buffer[491] = 21'b100000000000000000000;
 buffer[492] = 21'b100000000000000000000;
 buffer[493] = 21'b100000000000000000000;
 buffer[494] = 21'b100000000000000000000;
 buffer[495] = 21'b100000000000000000000;
 buffer[496] = 21'b100000000000000000000;
 buffer[497] = 21'b100000000000000000000;
 buffer[498] = 21'b100000000000000000000;
 buffer[499] = 21'b100000000000000000000;
 buffer[500] = 21'b100000000000000000000;
 buffer[501] = 21'b100000000000000000000;
 buffer[502] = 21'b100000000000000000000;
 buffer[503] = 21'b100000000000000000000;
 buffer[504] = 21'b100000000000000000000;
 buffer[505] = 21'b100000000000000000000;
 buffer[506] = 21'b100000000000000000000;
 buffer[507] = 21'b100000000000000000000;
 buffer[508] = 21'b100000000000000000000;
 buffer[509] = 21'b100000000000000000000;
 buffer[510] = 21'b100000000000000000000;
 buffer[511] = 21'b100000000000000000000;
 buffer[512] = 21'b100000000000000000000;
 buffer[513] = 21'b100000000000000000000;
 buffer[514] = 21'b100000000000000000000;
 buffer[515] = 21'b100000000000000000000;
 buffer[516] = 21'b100000000000000000000;
 buffer[517] = 21'b100000000000000000000;
 buffer[518] = 21'b100000000000000000000;
 buffer[519] = 21'b100000000000000000000;
 buffer[520] = 21'b100000000000000000000;
 buffer[521] = 21'b100000000000000000000;
 buffer[522] = 21'b100000000000000000000;
 buffer[523] = 21'b100000000000000000000;
 buffer[524] = 21'b100000000000000000000;
 buffer[525] = 21'b100000000000000000000;
 buffer[526] = 21'b100000000000000000000;
 buffer[527] = 21'b100000000000000000000;
 buffer[528] = 21'b100000000000000000000;
 buffer[529] = 21'b100000000000000000000;
 buffer[530] = 21'b100000000000000000000;
 buffer[531] = 21'b100000000000000000000;
 buffer[532] = 21'b100000000000000000000;
 buffer[533] = 21'b100000000000000000000;
 buffer[534] = 21'b100000000000000000000;
 buffer[535] = 21'b100000000000000000000;
 buffer[536] = 21'b100000000000000000000;
 buffer[537] = 21'b100000000000000000000;
 buffer[538] = 21'b100000000000000000000;
 buffer[539] = 21'b100000000000000000000;
 buffer[540] = 21'b100000000000000000000;
 buffer[541] = 21'b100000000000000000000;
 buffer[542] = 21'b100000000000000000000;
 buffer[543] = 21'b100000000000000000000;
 buffer[544] = 21'b100000000000000000000;
 buffer[545] = 21'b100000000000000000000;
 buffer[546] = 21'b100000000000000000000;
 buffer[547] = 21'b100000000000000000000;
 buffer[548] = 21'b100000000000000000000;
 buffer[549] = 21'b100000000000000000000;
 buffer[550] = 21'b100000000000000000000;
 buffer[551] = 21'b100000000000000000000;
 buffer[552] = 21'b100000000000000000000;
 buffer[553] = 21'b100000000000000000000;
 buffer[554] = 21'b100000000000000000000;
 buffer[555] = 21'b100000000000000000000;
 buffer[556] = 21'b100000000000000000000;
 buffer[557] = 21'b100000000000000000000;
 buffer[558] = 21'b100000000000000000000;
 buffer[559] = 21'b100000000000000000000;
 buffer[560] = 21'b100000000000000000000;
 buffer[561] = 21'b100000000000000000000;
 buffer[562] = 21'b100000000000000000000;
 buffer[563] = 21'b100000000000000000000;
 buffer[564] = 21'b100000000000000000000;
 buffer[565] = 21'b100000000000000000000;
 buffer[566] = 21'b100000000000000000000;
 buffer[567] = 21'b100000000000000000000;
 buffer[568] = 21'b100000000000000000000;
 buffer[569] = 21'b100000000000000000000;
 buffer[570] = 21'b100000000000000000000;
 buffer[571] = 21'b100000000000000000000;
 buffer[572] = 21'b100000000000000000000;
 buffer[573] = 21'b100000000000000000000;
 buffer[574] = 21'b100000000000000000000;
 buffer[575] = 21'b100000000000000000000;
 buffer[576] = 21'b100000000000000000000;
 buffer[577] = 21'b100000000000000000000;
 buffer[578] = 21'b100000000000000000000;
 buffer[579] = 21'b100000000000000000000;
 buffer[580] = 21'b100000000000000000000;
 buffer[581] = 21'b100000000000000000000;
 buffer[582] = 21'b100000000000000000000;
 buffer[583] = 21'b100000000000000000000;
 buffer[584] = 21'b100000000000000000000;
 buffer[585] = 21'b100000000000000000000;
 buffer[586] = 21'b100000000000000000000;
 buffer[587] = 21'b100000000000000000000;
 buffer[588] = 21'b100000000000000000000;
 buffer[589] = 21'b100000000000000000000;
 buffer[590] = 21'b100000000000000000000;
 buffer[591] = 21'b100000000000000000000;
 buffer[592] = 21'b100000000000000000000;
 buffer[593] = 21'b100000000000000000000;
 buffer[594] = 21'b100000000000000000000;
 buffer[595] = 21'b100000000000000000000;
 buffer[596] = 21'b100000000000000000000;
 buffer[597] = 21'b100000000000000000000;
 buffer[598] = 21'b100000000000000000000;
 buffer[599] = 21'b100000000000000000000;
 buffer[600] = 21'b100000000000000000000;
 buffer[601] = 21'b100000000000000000000;
 buffer[602] = 21'b100000000000000000000;
 buffer[603] = 21'b100000000000000000000;
 buffer[604] = 21'b100000000000000000000;
 buffer[605] = 21'b100000000000000000000;
 buffer[606] = 21'b100000000000000000000;
 buffer[607] = 21'b100000000000000000000;
 buffer[608] = 21'b100000000000000000000;
 buffer[609] = 21'b100000000000000000000;
 buffer[610] = 21'b100000000000000000000;
 buffer[611] = 21'b100000000000000000000;
 buffer[612] = 21'b100000000000000000000;
 buffer[613] = 21'b100000000000000000000;
 buffer[614] = 21'b100000000000000000000;
 buffer[615] = 21'b100000000000000000000;
 buffer[616] = 21'b100000000000000000000;
 buffer[617] = 21'b100000000000000000000;
 buffer[618] = 21'b100000000000000000000;
 buffer[619] = 21'b100000000000000000000;
 buffer[620] = 21'b100000000000000000000;
 buffer[621] = 21'b100000000000000000000;
 buffer[622] = 21'b100000000000000000000;
 buffer[623] = 21'b100000000000000000000;
 buffer[624] = 21'b100000000000000000000;
 buffer[625] = 21'b100000000000000000000;
 buffer[626] = 21'b100000000000000000000;
 buffer[627] = 21'b100000000000000000000;
 buffer[628] = 21'b100000000000000000000;
 buffer[629] = 21'b100000000000000000000;
 buffer[630] = 21'b100000000000000000000;
 buffer[631] = 21'b100000000000000000000;
 buffer[632] = 21'b100000000000000000000;
 buffer[633] = 21'b100000000000000000000;
 buffer[634] = 21'b100000000000000000000;
 buffer[635] = 21'b100000000000000000000;
 buffer[636] = 21'b100000000000000000000;
 buffer[637] = 21'b100000000000000000000;
 buffer[638] = 21'b100000000000000000000;
 buffer[639] = 21'b100000000000000000000;
 buffer[640] = 21'b100000000000000000000;
 buffer[641] = 21'b100000000000000000000;
 buffer[642] = 21'b100000000000000000000;
 buffer[643] = 21'b100000000000000000000;
 buffer[644] = 21'b100000000000000000000;
 buffer[645] = 21'b100000000000000000000;
 buffer[646] = 21'b100000000000000000000;
 buffer[647] = 21'b100000000000000000000;
 buffer[648] = 21'b100000000000000000000;
 buffer[649] = 21'b100000000000000000000;
 buffer[650] = 21'b100000000000000000000;
 buffer[651] = 21'b100000000000000000000;
 buffer[652] = 21'b100000000000000000000;
 buffer[653] = 21'b100000000000000000000;
 buffer[654] = 21'b100000000000000000000;
 buffer[655] = 21'b100000000000000000000;
 buffer[656] = 21'b100000000000000000000;
 buffer[657] = 21'b100000000000000000000;
 buffer[658] = 21'b100000000000000000000;
 buffer[659] = 21'b100000000000000000000;
 buffer[660] = 21'b100000000000000000000;
 buffer[661] = 21'b100000000000000000000;
 buffer[662] = 21'b100000000000000000000;
 buffer[663] = 21'b100000000000000000000;
 buffer[664] = 21'b100000000000000000000;
 buffer[665] = 21'b100000000000000000000;
 buffer[666] = 21'b100000000000000000000;
 buffer[667] = 21'b100000000000000000000;
 buffer[668] = 21'b100000000000000000000;
 buffer[669] = 21'b100000000000000000000;
 buffer[670] = 21'b100000000000000000000;
 buffer[671] = 21'b100000000000000000000;
 buffer[672] = 21'b100000000000000000000;
 buffer[673] = 21'b100000000000000000000;
 buffer[674] = 21'b100000000000000000000;
 buffer[675] = 21'b100000000000000000000;
 buffer[676] = 21'b100000000000000000000;
 buffer[677] = 21'b100000000000000000000;
 buffer[678] = 21'b100000000000000000000;
 buffer[679] = 21'b100000000000000000000;
 buffer[680] = 21'b100000000000000000000;
 buffer[681] = 21'b100000000000000000000;
 buffer[682] = 21'b100000000000000000000;
 buffer[683] = 21'b100000000000000000000;
 buffer[684] = 21'b100000000000000000000;
 buffer[685] = 21'b100000000000000000000;
 buffer[686] = 21'b100000000000000000000;
 buffer[687] = 21'b100000000000000000000;
 buffer[688] = 21'b100000000000000000000;
 buffer[689] = 21'b100000000000000000000;
 buffer[690] = 21'b100000000000000000000;
 buffer[691] = 21'b100000000000000000000;
 buffer[692] = 21'b100000000000000000000;
 buffer[693] = 21'b100000000000000000000;
 buffer[694] = 21'b100000000000000000000;
 buffer[695] = 21'b100000000000000000000;
 buffer[696] = 21'b100000000000000000000;
 buffer[697] = 21'b100000000000000000000;
 buffer[698] = 21'b100000000000000000000;
 buffer[699] = 21'b100000000000000000000;
 buffer[700] = 21'b100000000000000000000;
 buffer[701] = 21'b100000000000000000000;
 buffer[702] = 21'b100000000000000000000;
 buffer[703] = 21'b100000000000000000000;
 buffer[704] = 21'b100000000000000000000;
 buffer[705] = 21'b100000000000000000000;
 buffer[706] = 21'b100000000000000000000;
 buffer[707] = 21'b100000000000000000000;
 buffer[708] = 21'b100000000000000000000;
 buffer[709] = 21'b100000000000000000000;
 buffer[710] = 21'b100000000000000000000;
 buffer[711] = 21'b100000000000000000000;
 buffer[712] = 21'b100000000000000000000;
 buffer[713] = 21'b100000000000000000000;
 buffer[714] = 21'b100000000000000000000;
 buffer[715] = 21'b100000000000000000000;
 buffer[716] = 21'b100000000000000000000;
 buffer[717] = 21'b100000000000000000000;
 buffer[718] = 21'b100000000000000000000;
 buffer[719] = 21'b100000000000000000000;
 buffer[720] = 21'b100000000000000000000;
 buffer[721] = 21'b100000000000000000000;
 buffer[722] = 21'b100000000000000000000;
 buffer[723] = 21'b100000000000000000000;
 buffer[724] = 21'b100000000000000000000;
 buffer[725] = 21'b100000000000000000000;
 buffer[726] = 21'b100000000000000000000;
 buffer[727] = 21'b100000000000000000000;
 buffer[728] = 21'b100000000000000000000;
 buffer[729] = 21'b100000000000000000000;
 buffer[730] = 21'b100000000000000000000;
 buffer[731] = 21'b100000000000000000000;
 buffer[732] = 21'b100000000000000000000;
 buffer[733] = 21'b100000000000000000000;
 buffer[734] = 21'b100000000000000000000;
 buffer[735] = 21'b100000000000000000000;
 buffer[736] = 21'b100000000000000000000;
 buffer[737] = 21'b100000000000000000000;
 buffer[738] = 21'b100000000000000000000;
 buffer[739] = 21'b100000000000000000000;
 buffer[740] = 21'b100000000000000000000;
 buffer[741] = 21'b100000000000000000000;
 buffer[742] = 21'b100000000000000000000;
 buffer[743] = 21'b100000000000000000000;
 buffer[744] = 21'b100000000000000000000;
 buffer[745] = 21'b100000000000000000000;
 buffer[746] = 21'b100000000000000000000;
 buffer[747] = 21'b100000000000000000000;
 buffer[748] = 21'b100000000000000000000;
 buffer[749] = 21'b100000000000000000000;
 buffer[750] = 21'b100000000000000000000;
 buffer[751] = 21'b100000000000000000000;
 buffer[752] = 21'b100000000000000000000;
 buffer[753] = 21'b100000000000000000000;
 buffer[754] = 21'b100000000000000000000;
 buffer[755] = 21'b100000000000000000000;
 buffer[756] = 21'b100000000000000000000;
 buffer[757] = 21'b100000000000000000000;
 buffer[758] = 21'b100000000000000000000;
 buffer[759] = 21'b100000000000000000000;
 buffer[760] = 21'b100000000000000000000;
 buffer[761] = 21'b100000000000000000000;
 buffer[762] = 21'b100000000000000000000;
 buffer[763] = 21'b100000000000000000000;
 buffer[764] = 21'b100000000000000000000;
 buffer[765] = 21'b100000000000000000000;
 buffer[766] = 21'b100000000000000000000;
 buffer[767] = 21'b100000000000000000000;
 buffer[768] = 21'b100000000000000000000;
 buffer[769] = 21'b100000000000000000000;
 buffer[770] = 21'b100000000000000000000;
 buffer[771] = 21'b100000000000000000000;
 buffer[772] = 21'b100000000000000000000;
 buffer[773] = 21'b100000000000000000000;
 buffer[774] = 21'b100000000000000000000;
 buffer[775] = 21'b100000000000000000000;
 buffer[776] = 21'b100000000000000000000;
 buffer[777] = 21'b100000000000000000000;
 buffer[778] = 21'b100000000000000000000;
 buffer[779] = 21'b100000000000000000000;
 buffer[780] = 21'b100000000000000000000;
 buffer[781] = 21'b100000000000000000000;
 buffer[782] = 21'b100000000000000000000;
 buffer[783] = 21'b100000000000000000000;
 buffer[784] = 21'b100000000000000000000;
 buffer[785] = 21'b100000000000000000000;
 buffer[786] = 21'b100000000000000000000;
 buffer[787] = 21'b100000000000000000000;
 buffer[788] = 21'b100000000000000000000;
 buffer[789] = 21'b100000000000000000000;
 buffer[790] = 21'b100000000000000000000;
 buffer[791] = 21'b100000000000000000000;
 buffer[792] = 21'b100000000000000000000;
 buffer[793] = 21'b100000000000000000000;
 buffer[794] = 21'b100000000000000000000;
 buffer[795] = 21'b100000000000000000000;
 buffer[796] = 21'b100000000000000000000;
 buffer[797] = 21'b100000000000000000000;
 buffer[798] = 21'b100000000000000000000;
 buffer[799] = 21'b100000000000000000000;
 buffer[800] = 21'b100000000000000000000;
 buffer[801] = 21'b100000000000000000000;
 buffer[802] = 21'b100000000000000000000;
 buffer[803] = 21'b100000000000000000000;
 buffer[804] = 21'b100000000000000000000;
 buffer[805] = 21'b100000000000000000000;
 buffer[806] = 21'b100000000000000000000;
 buffer[807] = 21'b100000000000000000000;
 buffer[808] = 21'b100000000000000000000;
 buffer[809] = 21'b100000000000000000000;
 buffer[810] = 21'b100000000000000000000;
 buffer[811] = 21'b100000000000000000000;
 buffer[812] = 21'b100000000000000000000;
 buffer[813] = 21'b100000000000000000000;
 buffer[814] = 21'b100000000000000000000;
 buffer[815] = 21'b100000000000000000000;
 buffer[816] = 21'b100000000000000000000;
 buffer[817] = 21'b100000000000000000000;
 buffer[818] = 21'b100000000000000000000;
 buffer[819] = 21'b100000000000000000000;
 buffer[820] = 21'b100000000000000000000;
 buffer[821] = 21'b100000000000000000000;
 buffer[822] = 21'b100000000000000000000;
 buffer[823] = 21'b100000000000000000000;
 buffer[824] = 21'b100000000000000000000;
 buffer[825] = 21'b100000000000000000000;
 buffer[826] = 21'b100000000000000000000;
 buffer[827] = 21'b100000000000000000000;
 buffer[828] = 21'b100000000000000000000;
 buffer[829] = 21'b100000000000000000000;
 buffer[830] = 21'b100000000000000000000;
 buffer[831] = 21'b100000000000000000000;
 buffer[832] = 21'b100000000000000000000;
 buffer[833] = 21'b100000000000000000000;
 buffer[834] = 21'b100000000000000000000;
 buffer[835] = 21'b100000000000000000000;
 buffer[836] = 21'b100000000000000000000;
 buffer[837] = 21'b100000000000000000000;
 buffer[838] = 21'b100000000000000000000;
 buffer[839] = 21'b100000000000000000000;
 buffer[840] = 21'b100000000000000000000;
 buffer[841] = 21'b100000000000000000000;
 buffer[842] = 21'b100000000000000000000;
 buffer[843] = 21'b100000000000000000000;
 buffer[844] = 21'b100000000000000000000;
 buffer[845] = 21'b100000000000000000000;
 buffer[846] = 21'b100000000000000000000;
 buffer[847] = 21'b100000000000000000000;
 buffer[848] = 21'b100000000000000000000;
 buffer[849] = 21'b100000000000000000000;
 buffer[850] = 21'b100000000000000000000;
 buffer[851] = 21'b100000000000000000000;
 buffer[852] = 21'b100000000000000000000;
 buffer[853] = 21'b100000000000000000000;
 buffer[854] = 21'b100000000000000000000;
 buffer[855] = 21'b100000000000000000000;
 buffer[856] = 21'b100000000000000000000;
 buffer[857] = 21'b100000000000000000000;
 buffer[858] = 21'b100000000000000000000;
 buffer[859] = 21'b100000000000000000000;
 buffer[860] = 21'b100000000000000000000;
 buffer[861] = 21'b100000000000000000000;
 buffer[862] = 21'b100000000000000000000;
 buffer[863] = 21'b100000000000000000000;
 buffer[864] = 21'b100000000000000000000;
 buffer[865] = 21'b100000000000000000000;
 buffer[866] = 21'b100000000000000000000;
 buffer[867] = 21'b100000000000000000000;
 buffer[868] = 21'b100000000000000000000;
 buffer[869] = 21'b100000000000000000000;
 buffer[870] = 21'b100000000000000000000;
 buffer[871] = 21'b100000000000000000000;
 buffer[872] = 21'b100000000000000000000;
 buffer[873] = 21'b100000000000000000000;
 buffer[874] = 21'b100000000000000000000;
 buffer[875] = 21'b100000000000000000000;
 buffer[876] = 21'b100000000000000000000;
 buffer[877] = 21'b100000000000000000000;
 buffer[878] = 21'b100000000000000000000;
 buffer[879] = 21'b100000000000000000000;
 buffer[880] = 21'b100000000000000000000;
 buffer[881] = 21'b100000000000000000000;
 buffer[882] = 21'b100000000000000000000;
 buffer[883] = 21'b100000000000000000000;
 buffer[884] = 21'b100000000000000000000;
 buffer[885] = 21'b100000000000000000000;
 buffer[886] = 21'b100000000000000000000;
 buffer[887] = 21'b100000000000000000000;
 buffer[888] = 21'b100000000000000000000;
 buffer[889] = 21'b100000000000000000000;
 buffer[890] = 21'b100000000000000000000;
 buffer[891] = 21'b100000000000000000000;
 buffer[892] = 21'b100000000000000000000;
 buffer[893] = 21'b100000000000000000000;
 buffer[894] = 21'b100000000000000000000;
 buffer[895] = 21'b100000000000000000000;
 buffer[896] = 21'b100000000000000000000;
 buffer[897] = 21'b100000000000000000000;
 buffer[898] = 21'b100000000000000000000;
 buffer[899] = 21'b100000000000000000000;
 buffer[900] = 21'b100000000000000000000;
 buffer[901] = 21'b100000000000000000000;
 buffer[902] = 21'b100000000000000000000;
 buffer[903] = 21'b100000000000000000000;
 buffer[904] = 21'b100000000000000000000;
 buffer[905] = 21'b100000000000000000000;
 buffer[906] = 21'b100000000000000000000;
 buffer[907] = 21'b100000000000000000000;
 buffer[908] = 21'b100000000000000000000;
 buffer[909] = 21'b100000000000000000000;
 buffer[910] = 21'b100000000000000000000;
 buffer[911] = 21'b100000000000000000000;
 buffer[912] = 21'b100000000000000000000;
 buffer[913] = 21'b100000000000000000000;
 buffer[914] = 21'b100000000000000000000;
 buffer[915] = 21'b100000000000000000000;
 buffer[916] = 21'b100000000000000000000;
 buffer[917] = 21'b100000000000000000000;
 buffer[918] = 21'b100000000000000000000;
 buffer[919] = 21'b100000000000000000000;
 buffer[920] = 21'b100000000000000000000;
 buffer[921] = 21'b100000000000000000000;
 buffer[922] = 21'b100000000000000000000;
 buffer[923] = 21'b100000000000000000000;
 buffer[924] = 21'b100000000000000000000;
 buffer[925] = 21'b100000000000000000000;
 buffer[926] = 21'b100000000000000000000;
 buffer[927] = 21'b100000000000000000000;
 buffer[928] = 21'b100000000000000000000;
 buffer[929] = 21'b100000000000000000000;
 buffer[930] = 21'b100000000000000000000;
 buffer[931] = 21'b100000000000000000000;
 buffer[932] = 21'b100000000000000000000;
 buffer[933] = 21'b100000000000000000000;
 buffer[934] = 21'b100000000000000000000;
 buffer[935] = 21'b100000000000000000000;
 buffer[936] = 21'b100000000000000000000;
 buffer[937] = 21'b100000000000000000000;
 buffer[938] = 21'b100000000000000000000;
 buffer[939] = 21'b100000000000000000000;
 buffer[940] = 21'b100000000000000000000;
 buffer[941] = 21'b100000000000000000000;
 buffer[942] = 21'b100000000000000000000;
 buffer[943] = 21'b100000000000000000000;
 buffer[944] = 21'b100000000000000000000;
 buffer[945] = 21'b100000000000000000000;
 buffer[946] = 21'b100000000000000000000;
 buffer[947] = 21'b100000000000000000000;
 buffer[948] = 21'b100000000000000000000;
 buffer[949] = 21'b100000000000000000000;
 buffer[950] = 21'b100000000000000000000;
 buffer[951] = 21'b100000000000000000000;
 buffer[952] = 21'b100000000000000000000;
 buffer[953] = 21'b100000000000000000000;
 buffer[954] = 21'b100000000000000000000;
 buffer[955] = 21'b100000000000000000000;
 buffer[956] = 21'b100000000000000000000;
 buffer[957] = 21'b100000000000000000000;
 buffer[958] = 21'b100000000000000000000;
 buffer[959] = 21'b100000000000000000000;
 buffer[960] = 21'b100000000000000000000;
 buffer[961] = 21'b100000000000000000000;
 buffer[962] = 21'b100000000000000000000;
 buffer[963] = 21'b100000000000000000000;
 buffer[964] = 21'b100000000000000000000;
 buffer[965] = 21'b100000000000000000000;
 buffer[966] = 21'b100000000000000000000;
 buffer[967] = 21'b100000000000000000000;
 buffer[968] = 21'b100000000000000000000;
 buffer[969] = 21'b100000000000000000000;
 buffer[970] = 21'b100000000000000000000;
 buffer[971] = 21'b100000000000000000000;
 buffer[972] = 21'b100000000000000000000;
 buffer[973] = 21'b100000000000000000000;
 buffer[974] = 21'b100000000000000000000;
 buffer[975] = 21'b100000000000000000000;
 buffer[976] = 21'b100000000000000000000;
 buffer[977] = 21'b100000000000000000000;
 buffer[978] = 21'b100000000000000000000;
 buffer[979] = 21'b100000000000000000000;
 buffer[980] = 21'b100000000000000000000;
 buffer[981] = 21'b100000000000000000000;
 buffer[982] = 21'b100000000000000000000;
 buffer[983] = 21'b100000000000000000000;
 buffer[984] = 21'b100000000000000000000;
 buffer[985] = 21'b100000000000000000000;
 buffer[986] = 21'b100000000000000000000;
 buffer[987] = 21'b100000000000000000000;
 buffer[988] = 21'b100000000000000000000;
 buffer[989] = 21'b100000000000000000000;
 buffer[990] = 21'b100000000000000000000;
 buffer[991] = 21'b100000000000000000000;
 buffer[992] = 21'b100000000000000000000;
 buffer[993] = 21'b100000000000000000000;
 buffer[994] = 21'b100000000000000000000;
 buffer[995] = 21'b100000000000000000000;
 buffer[996] = 21'b100000000000000000000;
 buffer[997] = 21'b100000000000000000000;
 buffer[998] = 21'b100000000000000000000;
 buffer[999] = 21'b100000000000000000000;
 buffer[1000] = 21'b100000000000000000000;
 buffer[1001] = 21'b100000000000000000000;
 buffer[1002] = 21'b100000000000000000000;
 buffer[1003] = 21'b100000000000000000000;
 buffer[1004] = 21'b100000000000000000000;
 buffer[1005] = 21'b100000000000000000000;
 buffer[1006] = 21'b100000000000000000000;
 buffer[1007] = 21'b100000000000000000000;
 buffer[1008] = 21'b100000000000000000000;
 buffer[1009] = 21'b100000000000000000000;
 buffer[1010] = 21'b100000000000000000000;
 buffer[1011] = 21'b100000000000000000000;
 buffer[1012] = 21'b100000000000000000000;
 buffer[1013] = 21'b100000000000000000000;
 buffer[1014] = 21'b100000000000000000000;
 buffer[1015] = 21'b100000000000000000000;
 buffer[1016] = 21'b100000000000000000000;
 buffer[1017] = 21'b100000000000000000000;
 buffer[1018] = 21'b100000000000000000000;
 buffer[1019] = 21'b100000000000000000000;
 buffer[1020] = 21'b100000000000000000000;
 buffer[1021] = 21'b100000000000000000000;
 buffer[1022] = 21'b100000000000000000000;
 buffer[1023] = 21'b100000000000000000000;
 buffer[1024] = 21'b100000000000000000000;
 buffer[1025] = 21'b100000000000000000000;
 buffer[1026] = 21'b100000000000000000000;
 buffer[1027] = 21'b100000000000000000000;
 buffer[1028] = 21'b100000000000000000000;
 buffer[1029] = 21'b100000000000000000000;
 buffer[1030] = 21'b100000000000000000000;
 buffer[1031] = 21'b100000000000000000000;
 buffer[1032] = 21'b100000000000000000000;
 buffer[1033] = 21'b100000000000000000000;
 buffer[1034] = 21'b100000000000000000000;
 buffer[1035] = 21'b100000000000000000000;
 buffer[1036] = 21'b100000000000000000000;
 buffer[1037] = 21'b100000000000000000000;
 buffer[1038] = 21'b100000000000000000000;
 buffer[1039] = 21'b100000000000000000000;
 buffer[1040] = 21'b100000000000000000000;
 buffer[1041] = 21'b100000000000000000000;
 buffer[1042] = 21'b100000000000000000000;
 buffer[1043] = 21'b100000000000000000000;
 buffer[1044] = 21'b100000000000000000000;
 buffer[1045] = 21'b100000000000000000000;
 buffer[1046] = 21'b100000000000000000000;
 buffer[1047] = 21'b100000000000000000000;
 buffer[1048] = 21'b100000000000000000000;
 buffer[1049] = 21'b100000000000000000000;
 buffer[1050] = 21'b100000000000000000000;
 buffer[1051] = 21'b100000000000000000000;
 buffer[1052] = 21'b100000000000000000000;
 buffer[1053] = 21'b100000000000000000000;
 buffer[1054] = 21'b100000000000000000000;
 buffer[1055] = 21'b100000000000000000000;
 buffer[1056] = 21'b100000000000000000000;
 buffer[1057] = 21'b100000000000000000000;
 buffer[1058] = 21'b100000000000000000000;
 buffer[1059] = 21'b100000000000000000000;
 buffer[1060] = 21'b100000000000000000000;
 buffer[1061] = 21'b100000000000000000000;
 buffer[1062] = 21'b100000000000000000000;
 buffer[1063] = 21'b100000000000000000000;
 buffer[1064] = 21'b100000000000000000000;
 buffer[1065] = 21'b100000000000000000000;
 buffer[1066] = 21'b100000000000000000000;
 buffer[1067] = 21'b100000000000000000000;
 buffer[1068] = 21'b100000000000000000000;
 buffer[1069] = 21'b100000000000000000000;
 buffer[1070] = 21'b100000000000000000000;
 buffer[1071] = 21'b100000000000000000000;
 buffer[1072] = 21'b100000000000000000000;
 buffer[1073] = 21'b100000000000000000000;
 buffer[1074] = 21'b100000000000000000000;
 buffer[1075] = 21'b100000000000000000000;
 buffer[1076] = 21'b100000000000000000000;
 buffer[1077] = 21'b100000000000000000000;
 buffer[1078] = 21'b100000000000000000000;
 buffer[1079] = 21'b100000000000000000000;
 buffer[1080] = 21'b100000000000000000000;
 buffer[1081] = 21'b100000000000000000000;
 buffer[1082] = 21'b100000000000000000000;
 buffer[1083] = 21'b100000000000000000000;
 buffer[1084] = 21'b100000000000000000000;
 buffer[1085] = 21'b100000000000000000000;
 buffer[1086] = 21'b100000000000000000000;
 buffer[1087] = 21'b100000000000000000000;
 buffer[1088] = 21'b100000000000000000000;
 buffer[1089] = 21'b100000000000000000000;
 buffer[1090] = 21'b100000000000000000000;
 buffer[1091] = 21'b100000000000000000000;
 buffer[1092] = 21'b100000000000000000000;
 buffer[1093] = 21'b100000000000000000000;
 buffer[1094] = 21'b100000000000000000000;
 buffer[1095] = 21'b100000000000000000000;
 buffer[1096] = 21'b100000000000000000000;
 buffer[1097] = 21'b100000000000000000000;
 buffer[1098] = 21'b100000000000000000000;
 buffer[1099] = 21'b100000000000000000000;
 buffer[1100] = 21'b100000000000000000000;
 buffer[1101] = 21'b100000000000000000000;
 buffer[1102] = 21'b100000000000000000000;
 buffer[1103] = 21'b100000000000000000000;
 buffer[1104] = 21'b100000000000000000000;
 buffer[1105] = 21'b100000000000000000000;
 buffer[1106] = 21'b100000000000000000000;
 buffer[1107] = 21'b100000000000000000000;
 buffer[1108] = 21'b100000000000000000000;
 buffer[1109] = 21'b100000000000000000000;
 buffer[1110] = 21'b100000000000000000000;
 buffer[1111] = 21'b100000000000000000000;
 buffer[1112] = 21'b100000000000000000000;
 buffer[1113] = 21'b100000000000000000000;
 buffer[1114] = 21'b100000000000000000000;
 buffer[1115] = 21'b100000000000000000000;
 buffer[1116] = 21'b100000000000000000000;
 buffer[1117] = 21'b100000000000000000000;
 buffer[1118] = 21'b100000000000000000000;
 buffer[1119] = 21'b100000000000000000000;
 buffer[1120] = 21'b100000000000000000000;
 buffer[1121] = 21'b100000000000000000000;
 buffer[1122] = 21'b100000000000000000000;
 buffer[1123] = 21'b100000000000000000000;
 buffer[1124] = 21'b100000000000000000000;
 buffer[1125] = 21'b100000000000000000000;
 buffer[1126] = 21'b100000000000000000000;
 buffer[1127] = 21'b100000000000000000000;
 buffer[1128] = 21'b100000000000000000000;
 buffer[1129] = 21'b100000000000000000000;
 buffer[1130] = 21'b100000000000000000000;
 buffer[1131] = 21'b100000000000000000000;
 buffer[1132] = 21'b100000000000000000000;
 buffer[1133] = 21'b100000000000000000000;
 buffer[1134] = 21'b100000000000000000000;
 buffer[1135] = 21'b100000000000000000000;
 buffer[1136] = 21'b100000000000000000000;
 buffer[1137] = 21'b100000000000000000000;
 buffer[1138] = 21'b100000000000000000000;
 buffer[1139] = 21'b100000000000000000000;
 buffer[1140] = 21'b100000000000000000000;
 buffer[1141] = 21'b100000000000000000000;
 buffer[1142] = 21'b100000000000000000000;
 buffer[1143] = 21'b100000000000000000000;
 buffer[1144] = 21'b100000000000000000000;
 buffer[1145] = 21'b100000000000000000000;
 buffer[1146] = 21'b100000000000000000000;
 buffer[1147] = 21'b100000000000000000000;
 buffer[1148] = 21'b100000000000000000000;
 buffer[1149] = 21'b100000000000000000000;
 buffer[1150] = 21'b100000000000000000000;
 buffer[1151] = 21'b100000000000000000000;
 buffer[1152] = 21'b100000000000000000000;
 buffer[1153] = 21'b100000000000000000000;
 buffer[1154] = 21'b100000000000000000000;
 buffer[1155] = 21'b100000000000000000000;
 buffer[1156] = 21'b100000000000000000000;
 buffer[1157] = 21'b100000000000000000000;
 buffer[1158] = 21'b100000000000000000000;
 buffer[1159] = 21'b100000000000000000000;
 buffer[1160] = 21'b100000000000000000000;
 buffer[1161] = 21'b100000000000000000000;
 buffer[1162] = 21'b100000000000000000000;
 buffer[1163] = 21'b100000000000000000000;
 buffer[1164] = 21'b100000000000000000000;
 buffer[1165] = 21'b100000000000000000000;
 buffer[1166] = 21'b100000000000000000000;
 buffer[1167] = 21'b100000000000000000000;
 buffer[1168] = 21'b100000000000000000000;
 buffer[1169] = 21'b100000000000000000000;
 buffer[1170] = 21'b100000000000000000000;
 buffer[1171] = 21'b100000000000000000000;
 buffer[1172] = 21'b100000000000000000000;
 buffer[1173] = 21'b100000000000000000000;
 buffer[1174] = 21'b100000000000000000000;
 buffer[1175] = 21'b100000000000000000000;
 buffer[1176] = 21'b100000000000000000000;
 buffer[1177] = 21'b100000000000000000000;
 buffer[1178] = 21'b100000000000000000000;
 buffer[1179] = 21'b100000000000000000000;
 buffer[1180] = 21'b100000000000000000000;
 buffer[1181] = 21'b100000000000000000000;
 buffer[1182] = 21'b100000000000000000000;
 buffer[1183] = 21'b100000000000000000000;
 buffer[1184] = 21'b100000000000000000000;
 buffer[1185] = 21'b100000000000000000000;
 buffer[1186] = 21'b100000000000000000000;
 buffer[1187] = 21'b100000000000000000000;
 buffer[1188] = 21'b100000000000000000000;
 buffer[1189] = 21'b100000000000000000000;
 buffer[1190] = 21'b100000000000000000000;
 buffer[1191] = 21'b100000000000000000000;
 buffer[1192] = 21'b100000000000000000000;
 buffer[1193] = 21'b100000000000000000000;
 buffer[1194] = 21'b100000000000000000000;
 buffer[1195] = 21'b100000000000000000000;
 buffer[1196] = 21'b100000000000000000000;
 buffer[1197] = 21'b100000000000000000000;
 buffer[1198] = 21'b100000000000000000000;
 buffer[1199] = 21'b100000000000000000000;
 buffer[1200] = 21'b100000000000000000000;
 buffer[1201] = 21'b100000000000000000000;
 buffer[1202] = 21'b100000000000000000000;
 buffer[1203] = 21'b100000000000000000000;
 buffer[1204] = 21'b100000000000000000000;
 buffer[1205] = 21'b100000000000000000000;
 buffer[1206] = 21'b100000000000000000000;
 buffer[1207] = 21'b100000000000000000000;
 buffer[1208] = 21'b100000000000000000000;
 buffer[1209] = 21'b100000000000000000000;
 buffer[1210] = 21'b100000000000000000000;
 buffer[1211] = 21'b100000000000000000000;
 buffer[1212] = 21'b100000000000000000000;
 buffer[1213] = 21'b100000000000000000000;
 buffer[1214] = 21'b100000000000000000000;
 buffer[1215] = 21'b100000000000000000000;
 buffer[1216] = 21'b100000000000000000000;
 buffer[1217] = 21'b100000000000000000000;
 buffer[1218] = 21'b100000000000000000000;
 buffer[1219] = 21'b100000000000000000000;
 buffer[1220] = 21'b100000000000000000000;
 buffer[1221] = 21'b100000000000000000000;
 buffer[1222] = 21'b100000000000000000000;
 buffer[1223] = 21'b100000000000000000000;
 buffer[1224] = 21'b100000000000000000000;
 buffer[1225] = 21'b100000000000000000000;
 buffer[1226] = 21'b100000000000000000000;
 buffer[1227] = 21'b100000000000000000000;
 buffer[1228] = 21'b100000000000000000000;
 buffer[1229] = 21'b100000000000000000000;
 buffer[1230] = 21'b100000000000000000000;
 buffer[1231] = 21'b100000000000000000000;
 buffer[1232] = 21'b100000000000000000000;
 buffer[1233] = 21'b100000000000000000000;
 buffer[1234] = 21'b100000000000000000000;
 buffer[1235] = 21'b100000000000000000000;
 buffer[1236] = 21'b100000000000000000000;
 buffer[1237] = 21'b100000000000000000000;
 buffer[1238] = 21'b100000000000000000000;
 buffer[1239] = 21'b100000000000000000000;
 buffer[1240] = 21'b100000000000000000000;
 buffer[1241] = 21'b100000000000000000000;
 buffer[1242] = 21'b100000000000000000000;
 buffer[1243] = 21'b100000000000000000000;
 buffer[1244] = 21'b100000000000000000000;
 buffer[1245] = 21'b100000000000000000000;
 buffer[1246] = 21'b100000000000000000000;
 buffer[1247] = 21'b100000000000000000000;
 buffer[1248] = 21'b100000000000000000000;
 buffer[1249] = 21'b100000000000000000000;
 buffer[1250] = 21'b100000000000000000000;
 buffer[1251] = 21'b100000000000000000000;
 buffer[1252] = 21'b100000000000000000000;
 buffer[1253] = 21'b100000000000000000000;
 buffer[1254] = 21'b100000000000000000000;
 buffer[1255] = 21'b100000000000000000000;
 buffer[1256] = 21'b100000000000000000000;
 buffer[1257] = 21'b100000000000000000000;
 buffer[1258] = 21'b100000000000000000000;
 buffer[1259] = 21'b100000000000000000000;
 buffer[1260] = 21'b100000000000000000000;
 buffer[1261] = 21'b100000000000000000000;
 buffer[1262] = 21'b100000000000000000000;
 buffer[1263] = 21'b100000000000000000000;
 buffer[1264] = 21'b100000000000000000000;
 buffer[1265] = 21'b100000000000000000000;
 buffer[1266] = 21'b100000000000000000000;
 buffer[1267] = 21'b100000000000000000000;
 buffer[1268] = 21'b100000000000000000000;
 buffer[1269] = 21'b100000000000000000000;
 buffer[1270] = 21'b100000000000000000000;
 buffer[1271] = 21'b100000000000000000000;
 buffer[1272] = 21'b100000000000000000000;
 buffer[1273] = 21'b100000000000000000000;
 buffer[1274] = 21'b100000000000000000000;
 buffer[1275] = 21'b100000000000000000000;
 buffer[1276] = 21'b100000000000000000000;
 buffer[1277] = 21'b100000000000000000000;
 buffer[1278] = 21'b100000000000000000000;
 buffer[1279] = 21'b100000000000000000000;
 buffer[1280] = 21'b100000000000000000000;
 buffer[1281] = 21'b100000000000000000000;
 buffer[1282] = 21'b100000000000000000000;
 buffer[1283] = 21'b100000000000000000000;
 buffer[1284] = 21'b100000000000000000000;
 buffer[1285] = 21'b100000000000000000000;
 buffer[1286] = 21'b100000000000000000000;
 buffer[1287] = 21'b100000000000000000000;
 buffer[1288] = 21'b100000000000000000000;
 buffer[1289] = 21'b100000000000000000000;
 buffer[1290] = 21'b100000000000000000000;
 buffer[1291] = 21'b100000000000000000000;
 buffer[1292] = 21'b100000000000000000000;
 buffer[1293] = 21'b100000000000000000000;
 buffer[1294] = 21'b100000000000000000000;
 buffer[1295] = 21'b100000000000000000000;
 buffer[1296] = 21'b100000000000000000000;
 buffer[1297] = 21'b100000000000000000000;
 buffer[1298] = 21'b100000000000000000000;
 buffer[1299] = 21'b100000000000000000000;
 buffer[1300] = 21'b100000000000000000000;
 buffer[1301] = 21'b100000000000000000000;
 buffer[1302] = 21'b100000000000000000000;
 buffer[1303] = 21'b100000000000000000000;
 buffer[1304] = 21'b100000000000000000000;
 buffer[1305] = 21'b100000000000000000000;
 buffer[1306] = 21'b100000000000000000000;
 buffer[1307] = 21'b100000000000000000000;
 buffer[1308] = 21'b100000000000000000000;
 buffer[1309] = 21'b100000000000000000000;
 buffer[1310] = 21'b100000000000000000000;
 buffer[1311] = 21'b100000000000000000000;
 buffer[1312] = 21'b100000000000000000000;
 buffer[1313] = 21'b100000000000000000000;
 buffer[1314] = 21'b100000000000000000000;
 buffer[1315] = 21'b100000000000000000000;
 buffer[1316] = 21'b100000000000000000000;
 buffer[1317] = 21'b100000000000000000000;
 buffer[1318] = 21'b100000000000000000000;
 buffer[1319] = 21'b100000000000000000000;
 buffer[1320] = 21'b100000000000000000000;
 buffer[1321] = 21'b100000000000000000000;
 buffer[1322] = 21'b100000000000000000000;
 buffer[1323] = 21'b100000000000000000000;
 buffer[1324] = 21'b100000000000000000000;
 buffer[1325] = 21'b100000000000000000000;
 buffer[1326] = 21'b100000000000000000000;
 buffer[1327] = 21'b100000000000000000000;
 buffer[1328] = 21'b100000000000000000000;
 buffer[1329] = 21'b100000000000000000000;
 buffer[1330] = 21'b100000000000000000000;
 buffer[1331] = 21'b100000000000000000000;
 buffer[1332] = 21'b100000000000000000000;
 buffer[1333] = 21'b100000000000000000000;
 buffer[1334] = 21'b100000000000000000000;
 buffer[1335] = 21'b100000000000000000000;
 buffer[1336] = 21'b100000000000000000000;
 buffer[1337] = 21'b100000000000000000000;
 buffer[1338] = 21'b100000000000000000000;
 buffer[1339] = 21'b100000000000000000000;
 buffer[1340] = 21'b100000000000000000000;
 buffer[1341] = 21'b100000000000000000000;
 buffer[1342] = 21'b100000000000000000000;
 buffer[1343] = 21'b100000000000000000000;
 buffer[1344] = 21'b100000000000000000000;
 buffer[1345] = 21'b100000000000000000000;
 buffer[1346] = 21'b100000000000000000000;
 buffer[1347] = 21'b100000000000000000000;
 buffer[1348] = 21'b100000000000000000000;
 buffer[1349] = 21'b100000000000000000000;
 buffer[1350] = 21'b100000000000000000000;
 buffer[1351] = 21'b100000000000000000000;
 buffer[1352] = 21'b100000000000000000000;
 buffer[1353] = 21'b100000000000000000000;
 buffer[1354] = 21'b100000000000000000000;
 buffer[1355] = 21'b100000000000000000000;
 buffer[1356] = 21'b100000000000000000000;
 buffer[1357] = 21'b100000000000000000000;
 buffer[1358] = 21'b100000000000000000000;
 buffer[1359] = 21'b100000000000000000000;
 buffer[1360] = 21'b100000000000000000000;
 buffer[1361] = 21'b100000000000000000000;
 buffer[1362] = 21'b100000000000000000000;
 buffer[1363] = 21'b100000000000000000000;
 buffer[1364] = 21'b100000000000000000000;
 buffer[1365] = 21'b100000000000000000000;
 buffer[1366] = 21'b100000000000000000000;
 buffer[1367] = 21'b100000000000000000000;
 buffer[1368] = 21'b100000000000000000000;
 buffer[1369] = 21'b100000000000000000000;
 buffer[1370] = 21'b100000000000000000000;
 buffer[1371] = 21'b100000000000000000000;
 buffer[1372] = 21'b100000000000000000000;
 buffer[1373] = 21'b100000000000000000000;
 buffer[1374] = 21'b100000000000000000000;
 buffer[1375] = 21'b100000000000000000000;
 buffer[1376] = 21'b100000000000000000000;
 buffer[1377] = 21'b100000000000000000000;
 buffer[1378] = 21'b100000000000000000000;
 buffer[1379] = 21'b100000000000000000000;
 buffer[1380] = 21'b100000000000000000000;
 buffer[1381] = 21'b100000000000000000000;
 buffer[1382] = 21'b100000000000000000000;
 buffer[1383] = 21'b100000000000000000000;
 buffer[1384] = 21'b100000000000000000000;
 buffer[1385] = 21'b100000000000000000000;
 buffer[1386] = 21'b100000000000000000000;
 buffer[1387] = 21'b100000000000000000000;
 buffer[1388] = 21'b100000000000000000000;
 buffer[1389] = 21'b100000000000000000000;
 buffer[1390] = 21'b100000000000000000000;
 buffer[1391] = 21'b100000000000000000000;
 buffer[1392] = 21'b100000000000000000000;
 buffer[1393] = 21'b100000000000000000000;
 buffer[1394] = 21'b100000000000000000000;
 buffer[1395] = 21'b100000000000000000000;
 buffer[1396] = 21'b100000000000000000000;
 buffer[1397] = 21'b100000000000000000000;
 buffer[1398] = 21'b100000000000000000000;
 buffer[1399] = 21'b100000000000000000000;
 buffer[1400] = 21'b100000000000000000000;
 buffer[1401] = 21'b100000000000000000000;
 buffer[1402] = 21'b100000000000000000000;
 buffer[1403] = 21'b100000000000000000000;
 buffer[1404] = 21'b100000000000000000000;
 buffer[1405] = 21'b100000000000000000000;
 buffer[1406] = 21'b100000000000000000000;
 buffer[1407] = 21'b100000000000000000000;
 buffer[1408] = 21'b100000000000000000000;
 buffer[1409] = 21'b100000000000000000000;
 buffer[1410] = 21'b100000000000000000000;
 buffer[1411] = 21'b100000000000000000000;
 buffer[1412] = 21'b100000000000000000000;
 buffer[1413] = 21'b100000000000000000000;
 buffer[1414] = 21'b100000000000000000000;
 buffer[1415] = 21'b100000000000000000000;
 buffer[1416] = 21'b100000000000000000000;
 buffer[1417] = 21'b100000000000000000000;
 buffer[1418] = 21'b100000000000000000000;
 buffer[1419] = 21'b100000000000000000000;
 buffer[1420] = 21'b100000000000000000000;
 buffer[1421] = 21'b100000000000000000000;
 buffer[1422] = 21'b100000000000000000000;
 buffer[1423] = 21'b100000000000000000000;
 buffer[1424] = 21'b100000000000000000000;
 buffer[1425] = 21'b100000000000000000000;
 buffer[1426] = 21'b100000000000000000000;
 buffer[1427] = 21'b100000000000000000000;
 buffer[1428] = 21'b100000000000000000000;
 buffer[1429] = 21'b100000000000000000000;
 buffer[1430] = 21'b100000000000000000000;
 buffer[1431] = 21'b100000000000000000000;
 buffer[1432] = 21'b100000000000000000000;
 buffer[1433] = 21'b100000000000000000000;
 buffer[1434] = 21'b100000000000000000000;
 buffer[1435] = 21'b100000000000000000000;
 buffer[1436] = 21'b100000000000000000000;
 buffer[1437] = 21'b100000000000000000000;
 buffer[1438] = 21'b100000000000000000000;
 buffer[1439] = 21'b100000000000000000000;
 buffer[1440] = 21'b100000000000000000000;
 buffer[1441] = 21'b100000000000000000000;
 buffer[1442] = 21'b100000000000000000000;
 buffer[1443] = 21'b100000000000000000000;
 buffer[1444] = 21'b100000000000000000000;
 buffer[1445] = 21'b100000000000000000000;
 buffer[1446] = 21'b100000000000000000000;
 buffer[1447] = 21'b100000000000000000000;
 buffer[1448] = 21'b100000000000000000000;
 buffer[1449] = 21'b100000000000000000000;
 buffer[1450] = 21'b100000000000000000000;
 buffer[1451] = 21'b100000000000000000000;
 buffer[1452] = 21'b100000000000000000000;
 buffer[1453] = 21'b100000000000000000000;
 buffer[1454] = 21'b100000000000000000000;
 buffer[1455] = 21'b100000000000000000000;
 buffer[1456] = 21'b100000000000000000000;
 buffer[1457] = 21'b100000000000000000000;
 buffer[1458] = 21'b100000000000000000000;
 buffer[1459] = 21'b100000000000000000000;
 buffer[1460] = 21'b100000000000000000000;
 buffer[1461] = 21'b100000000000000000000;
 buffer[1462] = 21'b100000000000000000000;
 buffer[1463] = 21'b100000000000000000000;
 buffer[1464] = 21'b100000000000000000000;
 buffer[1465] = 21'b100000000000000000000;
 buffer[1466] = 21'b100000000000000000000;
 buffer[1467] = 21'b100000000000000000000;
 buffer[1468] = 21'b100000000000000000000;
 buffer[1469] = 21'b100000000000000000000;
 buffer[1470] = 21'b100000000000000000000;
 buffer[1471] = 21'b100000000000000000000;
 buffer[1472] = 21'b100000000000000000000;
 buffer[1473] = 21'b100000000000000000000;
 buffer[1474] = 21'b100000000000000000000;
 buffer[1475] = 21'b100000000000000000000;
 buffer[1476] = 21'b100000000000000000000;
 buffer[1477] = 21'b100000000000000000000;
 buffer[1478] = 21'b100000000000000000000;
 buffer[1479] = 21'b100000000000000000000;
 buffer[1480] = 21'b100000000000000000000;
 buffer[1481] = 21'b100000000000000000000;
 buffer[1482] = 21'b100000000000000000000;
 buffer[1483] = 21'b100000000000000000000;
 buffer[1484] = 21'b100000000000000000000;
 buffer[1485] = 21'b100000000000000000000;
 buffer[1486] = 21'b100000000000000000000;
 buffer[1487] = 21'b100000000000000000000;
 buffer[1488] = 21'b100000000000000000000;
 buffer[1489] = 21'b100000000000000000000;
 buffer[1490] = 21'b100000000000000000000;
 buffer[1491] = 21'b100000000000000000000;
 buffer[1492] = 21'b100000000000000000000;
 buffer[1493] = 21'b100000000000000000000;
 buffer[1494] = 21'b100000000000000000000;
 buffer[1495] = 21'b100000000000000000000;
 buffer[1496] = 21'b100000000000000000000;
 buffer[1497] = 21'b100000000000000000000;
 buffer[1498] = 21'b100000000000000000000;
 buffer[1499] = 21'b100000000000000000000;
 buffer[1500] = 21'b100000000000000000000;
 buffer[1501] = 21'b100000000000000000000;
 buffer[1502] = 21'b100000000000000000000;
 buffer[1503] = 21'b100000000000000000000;
 buffer[1504] = 21'b100000000000000000000;
 buffer[1505] = 21'b100000000000000000000;
 buffer[1506] = 21'b100000000000000000000;
 buffer[1507] = 21'b100000000000000000000;
 buffer[1508] = 21'b100000000000000000000;
 buffer[1509] = 21'b100000000000000000000;
 buffer[1510] = 21'b100000000000000000000;
 buffer[1511] = 21'b100000000000000000000;
 buffer[1512] = 21'b100000000000000000000;
 buffer[1513] = 21'b100000000000000000000;
 buffer[1514] = 21'b100000000000000000000;
 buffer[1515] = 21'b100000000000000000000;
 buffer[1516] = 21'b100000000000000000000;
 buffer[1517] = 21'b100000000000000000000;
 buffer[1518] = 21'b100000000000000000000;
 buffer[1519] = 21'b100000000000000000000;
 buffer[1520] = 21'b100000000000000000000;
 buffer[1521] = 21'b100000000000000000000;
 buffer[1522] = 21'b100000000000000000000;
 buffer[1523] = 21'b100000000000000000000;
 buffer[1524] = 21'b100000000000000000000;
 buffer[1525] = 21'b100000000000000000000;
 buffer[1526] = 21'b100000000000000000000;
 buffer[1527] = 21'b100000000000000000000;
 buffer[1528] = 21'b100000000000000000000;
 buffer[1529] = 21'b100000000000000000000;
 buffer[1530] = 21'b100000000000000000000;
 buffer[1531] = 21'b100000000000000000000;
 buffer[1532] = 21'b100000000000000000000;
 buffer[1533] = 21'b100000000000000000000;
 buffer[1534] = 21'b100000000000000000000;
 buffer[1535] = 21'b100000000000000000000;
 buffer[1536] = 21'b100000000000000000000;
 buffer[1537] = 21'b100000000000000000000;
 buffer[1538] = 21'b100000000000000000000;
 buffer[1539] = 21'b100000000000000000000;
 buffer[1540] = 21'b100000000000000000000;
 buffer[1541] = 21'b100000000000000000000;
 buffer[1542] = 21'b100000000000000000000;
 buffer[1543] = 21'b100000000000000000000;
 buffer[1544] = 21'b100000000000000000000;
 buffer[1545] = 21'b100000000000000000000;
 buffer[1546] = 21'b100000000000000000000;
 buffer[1547] = 21'b100000000000000000000;
 buffer[1548] = 21'b100000000000000000000;
 buffer[1549] = 21'b100000000000000000000;
 buffer[1550] = 21'b100000000000000000000;
 buffer[1551] = 21'b100000000000000000000;
 buffer[1552] = 21'b100000000000000000000;
 buffer[1553] = 21'b100000000000000000000;
 buffer[1554] = 21'b100000000000000000000;
 buffer[1555] = 21'b100000000000000000000;
 buffer[1556] = 21'b100000000000000000000;
 buffer[1557] = 21'b100000000000000000000;
 buffer[1558] = 21'b100000000000000000000;
 buffer[1559] = 21'b100000000000000000000;
 buffer[1560] = 21'b100000000000000000000;
 buffer[1561] = 21'b100000000000000000000;
 buffer[1562] = 21'b100000000000000000000;
 buffer[1563] = 21'b100000000000000000000;
 buffer[1564] = 21'b100000000000000000000;
 buffer[1565] = 21'b100000000000000000000;
 buffer[1566] = 21'b100000000000000000000;
 buffer[1567] = 21'b100000000000000000000;
 buffer[1568] = 21'b100000000000000000000;
 buffer[1569] = 21'b100000000000000000000;
 buffer[1570] = 21'b100000000000000000000;
 buffer[1571] = 21'b100000000000000000000;
 buffer[1572] = 21'b100000000000000000000;
 buffer[1573] = 21'b100000000000000000000;
 buffer[1574] = 21'b100000000000000000000;
 buffer[1575] = 21'b100000000000000000000;
 buffer[1576] = 21'b100000000000000000000;
 buffer[1577] = 21'b100000000000000000000;
 buffer[1578] = 21'b100000000000000000000;
 buffer[1579] = 21'b100000000000000000000;
 buffer[1580] = 21'b100000000000000000000;
 buffer[1581] = 21'b100000000000000000000;
 buffer[1582] = 21'b100000000000000000000;
 buffer[1583] = 21'b100000000000000000000;
 buffer[1584] = 21'b100000000000000000000;
 buffer[1585] = 21'b100000000000000000000;
 buffer[1586] = 21'b100000000000000000000;
 buffer[1587] = 21'b100000000000000000000;
 buffer[1588] = 21'b100000000000000000000;
 buffer[1589] = 21'b100000000000000000000;
 buffer[1590] = 21'b100000000000000000000;
 buffer[1591] = 21'b100000000000000000000;
 buffer[1592] = 21'b100000000000000000000;
 buffer[1593] = 21'b100000000000000000000;
 buffer[1594] = 21'b100000000000000000000;
 buffer[1595] = 21'b100000000000000000000;
 buffer[1596] = 21'b100000000000000000000;
 buffer[1597] = 21'b100000000000000000000;
 buffer[1598] = 21'b100000000000000000000;
 buffer[1599] = 21'b100000000000000000000;
 buffer[1600] = 21'b100000000000000000000;
 buffer[1601] = 21'b100000000000000000000;
 buffer[1602] = 21'b100000000000000000000;
 buffer[1603] = 21'b100000000000000000000;
 buffer[1604] = 21'b100000000000000000000;
 buffer[1605] = 21'b100000000000000000000;
 buffer[1606] = 21'b100000000000000000000;
 buffer[1607] = 21'b100000000000000000000;
 buffer[1608] = 21'b100000000000000000000;
 buffer[1609] = 21'b100000000000000000000;
 buffer[1610] = 21'b100000000000000000000;
 buffer[1611] = 21'b100000000000000000000;
 buffer[1612] = 21'b100000000000000000000;
 buffer[1613] = 21'b100000000000000000000;
 buffer[1614] = 21'b100000000000000000000;
 buffer[1615] = 21'b100000000000000000000;
 buffer[1616] = 21'b100000000000000000000;
 buffer[1617] = 21'b100000000000000000000;
 buffer[1618] = 21'b100000000000000000000;
 buffer[1619] = 21'b100000000000000000000;
 buffer[1620] = 21'b100000000000000000000;
 buffer[1621] = 21'b100000000000000000000;
 buffer[1622] = 21'b100000000000000000000;
 buffer[1623] = 21'b100000000000000000000;
 buffer[1624] = 21'b100000000000000000000;
 buffer[1625] = 21'b100000000000000000000;
 buffer[1626] = 21'b100000000000000000000;
 buffer[1627] = 21'b100000000000000000000;
 buffer[1628] = 21'b100000000000000000000;
 buffer[1629] = 21'b100000000000000000000;
 buffer[1630] = 21'b100000000000000000000;
 buffer[1631] = 21'b100000000000000000000;
 buffer[1632] = 21'b100000000000000000000;
 buffer[1633] = 21'b100000000000000000000;
 buffer[1634] = 21'b100000000000000000000;
 buffer[1635] = 21'b100000000000000000000;
 buffer[1636] = 21'b100000000000000000000;
 buffer[1637] = 21'b100000000000000000000;
 buffer[1638] = 21'b100000000000000000000;
 buffer[1639] = 21'b100000000000000000000;
 buffer[1640] = 21'b100000000000000000000;
 buffer[1641] = 21'b100000000000000000000;
 buffer[1642] = 21'b100000000000000000000;
 buffer[1643] = 21'b100000000000000000000;
 buffer[1644] = 21'b100000000000000000000;
 buffer[1645] = 21'b100000000000000000000;
 buffer[1646] = 21'b100000000000000000000;
 buffer[1647] = 21'b100000000000000000000;
 buffer[1648] = 21'b100000000000000000000;
 buffer[1649] = 21'b100000000000000000000;
 buffer[1650] = 21'b100000000000000000000;
 buffer[1651] = 21'b100000000000000000000;
 buffer[1652] = 21'b100000000000000000000;
 buffer[1653] = 21'b100000000000000000000;
 buffer[1654] = 21'b100000000000000000000;
 buffer[1655] = 21'b100000000000000000000;
 buffer[1656] = 21'b100000000000000000000;
 buffer[1657] = 21'b100000000000000000000;
 buffer[1658] = 21'b100000000000000000000;
 buffer[1659] = 21'b100000000000000000000;
 buffer[1660] = 21'b100000000000000000000;
 buffer[1661] = 21'b100000000000000000000;
 buffer[1662] = 21'b100000000000000000000;
 buffer[1663] = 21'b100000000000000000000;
 buffer[1664] = 21'b100000000000000000000;
 buffer[1665] = 21'b100000000000000000000;
 buffer[1666] = 21'b100000000000000000000;
 buffer[1667] = 21'b100000000000000000000;
 buffer[1668] = 21'b100000000000000000000;
 buffer[1669] = 21'b100000000000000000000;
 buffer[1670] = 21'b100000000000000000000;
 buffer[1671] = 21'b100000000000000000000;
 buffer[1672] = 21'b100000000000000000000;
 buffer[1673] = 21'b100000000000000000000;
 buffer[1674] = 21'b100000000000000000000;
 buffer[1675] = 21'b100000000000000000000;
 buffer[1676] = 21'b100000000000000000000;
 buffer[1677] = 21'b100000000000000000000;
 buffer[1678] = 21'b100000000000000000000;
 buffer[1679] = 21'b100000000000000000000;
 buffer[1680] = 21'b100000000000000000000;
 buffer[1681] = 21'b100000000000000000000;
 buffer[1682] = 21'b100000000000000000000;
 buffer[1683] = 21'b100000000000000000000;
 buffer[1684] = 21'b100000000000000000000;
 buffer[1685] = 21'b100000000000000000000;
 buffer[1686] = 21'b100000000000000000000;
 buffer[1687] = 21'b100000000000000000000;
 buffer[1688] = 21'b100000000000000000000;
 buffer[1689] = 21'b100000000000000000000;
 buffer[1690] = 21'b100000000000000000000;
 buffer[1691] = 21'b100000000000000000000;
 buffer[1692] = 21'b100000000000000000000;
 buffer[1693] = 21'b100000000000000000000;
 buffer[1694] = 21'b100000000000000000000;
 buffer[1695] = 21'b100000000000000000000;
 buffer[1696] = 21'b100000000000000000000;
 buffer[1697] = 21'b100000000000000000000;
 buffer[1698] = 21'b100000000000000000000;
 buffer[1699] = 21'b100000000000000000000;
 buffer[1700] = 21'b100000000000000000000;
 buffer[1701] = 21'b100000000000000000000;
 buffer[1702] = 21'b100000000000000000000;
 buffer[1703] = 21'b100000000000000000000;
 buffer[1704] = 21'b100000000000000000000;
 buffer[1705] = 21'b100000000000000000000;
 buffer[1706] = 21'b100000000000000000000;
 buffer[1707] = 21'b100000000000000000000;
 buffer[1708] = 21'b100000000000000000000;
 buffer[1709] = 21'b100000000000000000000;
 buffer[1710] = 21'b100000000000000000000;
 buffer[1711] = 21'b100000000000000000000;
 buffer[1712] = 21'b100000000000000000000;
 buffer[1713] = 21'b100000000000000000000;
 buffer[1714] = 21'b100000000000000000000;
 buffer[1715] = 21'b100000000000000000000;
 buffer[1716] = 21'b100000000000000000000;
 buffer[1717] = 21'b100000000000000000000;
 buffer[1718] = 21'b100000000000000000000;
 buffer[1719] = 21'b100000000000000000000;
 buffer[1720] = 21'b100000000000000000000;
 buffer[1721] = 21'b100000000000000000000;
 buffer[1722] = 21'b100000000000000000000;
 buffer[1723] = 21'b100000000000000000000;
 buffer[1724] = 21'b100000000000000000000;
 buffer[1725] = 21'b100000000000000000000;
 buffer[1726] = 21'b100000000000000000000;
 buffer[1727] = 21'b100000000000000000000;
 buffer[1728] = 21'b100000000000000000000;
 buffer[1729] = 21'b100000000000000000000;
 buffer[1730] = 21'b100000000000000000000;
 buffer[1731] = 21'b100000000000000000000;
 buffer[1732] = 21'b100000000000000000000;
 buffer[1733] = 21'b100000000000000000000;
 buffer[1734] = 21'b100000000000000000000;
 buffer[1735] = 21'b100000000000000000000;
 buffer[1736] = 21'b100000000000000000000;
 buffer[1737] = 21'b100000000000000000000;
 buffer[1738] = 21'b100000000000000000000;
 buffer[1739] = 21'b100000000000000000000;
 buffer[1740] = 21'b100000000000000000000;
 buffer[1741] = 21'b100000000000000000000;
 buffer[1742] = 21'b100000000000000000000;
 buffer[1743] = 21'b100000000000000000000;
 buffer[1744] = 21'b100000000000000000000;
 buffer[1745] = 21'b100000000000000000000;
 buffer[1746] = 21'b100000000000000000000;
 buffer[1747] = 21'b100000000000000000000;
 buffer[1748] = 21'b100000000000000000000;
 buffer[1749] = 21'b100000000000000000000;
 buffer[1750] = 21'b100000000000000000000;
 buffer[1751] = 21'b100000000000000000000;
 buffer[1752] = 21'b100000000000000000000;
 buffer[1753] = 21'b100000000000000000000;
 buffer[1754] = 21'b100000000000000000000;
 buffer[1755] = 21'b100000000000000000000;
 buffer[1756] = 21'b100000000000000000000;
 buffer[1757] = 21'b100000000000000000000;
 buffer[1758] = 21'b100000000000000000000;
 buffer[1759] = 21'b100000000000000000000;
 buffer[1760] = 21'b100000000000000000000;
 buffer[1761] = 21'b100000000000000000000;
 buffer[1762] = 21'b100000000000000000000;
 buffer[1763] = 21'b100000000000000000000;
 buffer[1764] = 21'b100000000000000000000;
 buffer[1765] = 21'b100000000000000000000;
 buffer[1766] = 21'b100000000000000000000;
 buffer[1767] = 21'b100000000000000000000;
 buffer[1768] = 21'b100000000000000000000;
 buffer[1769] = 21'b100000000000000000000;
 buffer[1770] = 21'b100000000000000000000;
 buffer[1771] = 21'b100000000000000000000;
 buffer[1772] = 21'b100000000000000000000;
 buffer[1773] = 21'b100000000000000000000;
 buffer[1774] = 21'b100000000000000000000;
 buffer[1775] = 21'b100000000000000000000;
 buffer[1776] = 21'b100000000000000000000;
 buffer[1777] = 21'b100000000000000000000;
 buffer[1778] = 21'b100000000000000000000;
 buffer[1779] = 21'b100000000000000000000;
 buffer[1780] = 21'b100000000000000000000;
 buffer[1781] = 21'b100000000000000000000;
 buffer[1782] = 21'b100000000000000000000;
 buffer[1783] = 21'b100000000000000000000;
 buffer[1784] = 21'b100000000000000000000;
 buffer[1785] = 21'b100000000000000000000;
 buffer[1786] = 21'b100000000000000000000;
 buffer[1787] = 21'b100000000000000000000;
 buffer[1788] = 21'b100000000000000000000;
 buffer[1789] = 21'b100000000000000000000;
 buffer[1790] = 21'b100000000000000000000;
 buffer[1791] = 21'b100000000000000000000;
 buffer[1792] = 21'b100000000000000000000;
 buffer[1793] = 21'b100000000000000000000;
 buffer[1794] = 21'b100000000000000000000;
 buffer[1795] = 21'b100000000000000000000;
 buffer[1796] = 21'b100000000000000000000;
 buffer[1797] = 21'b100000000000000000000;
 buffer[1798] = 21'b100000000000000000000;
 buffer[1799] = 21'b100000000000000000000;
 buffer[1800] = 21'b100000000000000000000;
 buffer[1801] = 21'b100000000000000000000;
 buffer[1802] = 21'b100000000000000000000;
 buffer[1803] = 21'b100000000000000000000;
 buffer[1804] = 21'b100000000000000000000;
 buffer[1805] = 21'b100000000000000000000;
 buffer[1806] = 21'b100000000000000000000;
 buffer[1807] = 21'b100000000000000000000;
 buffer[1808] = 21'b100000000000000000000;
 buffer[1809] = 21'b100000000000000000000;
 buffer[1810] = 21'b100000000000000000000;
 buffer[1811] = 21'b100000000000000000000;
 buffer[1812] = 21'b100000000000000000000;
 buffer[1813] = 21'b100000000000000000000;
 buffer[1814] = 21'b100000000000000000000;
 buffer[1815] = 21'b100000000000000000000;
 buffer[1816] = 21'b100000000000000000000;
 buffer[1817] = 21'b100000000000000000000;
 buffer[1818] = 21'b100000000000000000000;
 buffer[1819] = 21'b100000000000000000000;
 buffer[1820] = 21'b100000000000000000000;
 buffer[1821] = 21'b100000000000000000000;
 buffer[1822] = 21'b100000000000000000000;
 buffer[1823] = 21'b100000000000000000000;
 buffer[1824] = 21'b100000000000000000000;
 buffer[1825] = 21'b100000000000000000000;
 buffer[1826] = 21'b100000000000000000000;
 buffer[1827] = 21'b100000000000000000000;
 buffer[1828] = 21'b100000000000000000000;
 buffer[1829] = 21'b100000000000000000000;
 buffer[1830] = 21'b100000000000000000000;
 buffer[1831] = 21'b100000000000000000000;
 buffer[1832] = 21'b100000000000000000000;
 buffer[1833] = 21'b100000000000000000000;
 buffer[1834] = 21'b100000000000000000000;
 buffer[1835] = 21'b100000000000000000000;
 buffer[1836] = 21'b100000000000000000000;
 buffer[1837] = 21'b100000000000000000000;
 buffer[1838] = 21'b100000000000000000000;
 buffer[1839] = 21'b100000000000000000000;
 buffer[1840] = 21'b100000000000000000000;
 buffer[1841] = 21'b100000000000000000000;
 buffer[1842] = 21'b100000000000000000000;
 buffer[1843] = 21'b100000000000000000000;
 buffer[1844] = 21'b100000000000000000000;
 buffer[1845] = 21'b100000000000000000000;
 buffer[1846] = 21'b100000000000000000000;
 buffer[1847] = 21'b100000000000000000000;
 buffer[1848] = 21'b100000000000000000000;
 buffer[1849] = 21'b100000000000000000000;
 buffer[1850] = 21'b100000000000000000000;
 buffer[1851] = 21'b100000000000000000000;
 buffer[1852] = 21'b100000000000000000000;
 buffer[1853] = 21'b100000000000000000000;
 buffer[1854] = 21'b100000000000000000000;
 buffer[1855] = 21'b100000000000000000000;
 buffer[1856] = 21'b100000000000000000000;
 buffer[1857] = 21'b100000000000000000000;
 buffer[1858] = 21'b100000000000000000000;
 buffer[1859] = 21'b100000000000000000000;
 buffer[1860] = 21'b100000000000000000000;
 buffer[1861] = 21'b100000000000000000000;
 buffer[1862] = 21'b100000000000000000000;
 buffer[1863] = 21'b100000000000000000000;
 buffer[1864] = 21'b100000000000000000000;
 buffer[1865] = 21'b100000000000000000000;
 buffer[1866] = 21'b100000000000000000000;
 buffer[1867] = 21'b100000000000000000000;
 buffer[1868] = 21'b100000000000000000000;
 buffer[1869] = 21'b100000000000000000000;
 buffer[1870] = 21'b100000000000000000000;
 buffer[1871] = 21'b100000000000000000000;
 buffer[1872] = 21'b100000000000000000000;
 buffer[1873] = 21'b100000000000000000000;
 buffer[1874] = 21'b100000000000000000000;
 buffer[1875] = 21'b100000000000000000000;
 buffer[1876] = 21'b100000000000000000000;
 buffer[1877] = 21'b100000000000000000000;
 buffer[1878] = 21'b100000000000000000000;
 buffer[1879] = 21'b100000000000000000000;
 buffer[1880] = 21'b100000000000000000000;
 buffer[1881] = 21'b100000000000000000000;
 buffer[1882] = 21'b100000000000000000000;
 buffer[1883] = 21'b100000000000000000000;
 buffer[1884] = 21'b100000000000000000000;
 buffer[1885] = 21'b100000000000000000000;
 buffer[1886] = 21'b100000000000000000000;
 buffer[1887] = 21'b100000000000000000000;
 buffer[1888] = 21'b100000000000000000000;
 buffer[1889] = 21'b100000000000000000000;
 buffer[1890] = 21'b100000000000000000000;
 buffer[1891] = 21'b100000000000000000000;
 buffer[1892] = 21'b100000000000000000000;
 buffer[1893] = 21'b100000000000000000000;
 buffer[1894] = 21'b100000000000000000000;
 buffer[1895] = 21'b100000000000000000000;
 buffer[1896] = 21'b100000000000000000000;
 buffer[1897] = 21'b100000000000000000000;
 buffer[1898] = 21'b100000000000000000000;
 buffer[1899] = 21'b100000000000000000000;
 buffer[1900] = 21'b100000000000000000000;
 buffer[1901] = 21'b100000000000000000000;
 buffer[1902] = 21'b100000000000000000000;
 buffer[1903] = 21'b100000000000000000000;
 buffer[1904] = 21'b100000000000000000000;
 buffer[1905] = 21'b100000000000000000000;
 buffer[1906] = 21'b100000000000000000000;
 buffer[1907] = 21'b100000000000000000000;
 buffer[1908] = 21'b100000000000000000000;
 buffer[1909] = 21'b100000000000000000000;
 buffer[1910] = 21'b100000000000000000000;
 buffer[1911] = 21'b100000000000000000000;
 buffer[1912] = 21'b100000000000000000000;
 buffer[1913] = 21'b100000000000000000000;
 buffer[1914] = 21'b100000000000000000000;
 buffer[1915] = 21'b100000000000000000000;
 buffer[1916] = 21'b100000000000000000000;
 buffer[1917] = 21'b100000000000000000000;
 buffer[1918] = 21'b100000000000000000000;
 buffer[1919] = 21'b100000000000000000000;
 buffer[1920] = 21'b100000000000000000000;
 buffer[1921] = 21'b100000000000000000000;
 buffer[1922] = 21'b100000000000000000000;
 buffer[1923] = 21'b100000000000000000000;
 buffer[1924] = 21'b100000000000000000000;
 buffer[1925] = 21'b100000000000000000000;
 buffer[1926] = 21'b100000000000000000000;
 buffer[1927] = 21'b100000000000000000000;
 buffer[1928] = 21'b100000000000000000000;
 buffer[1929] = 21'b100000000000000000000;
 buffer[1930] = 21'b100000000000000000000;
 buffer[1931] = 21'b100000000000000000000;
 buffer[1932] = 21'b100000000000000000000;
 buffer[1933] = 21'b100000000000000000000;
 buffer[1934] = 21'b100000000000000000000;
 buffer[1935] = 21'b100000000000000000000;
 buffer[1936] = 21'b100000000000000000000;
 buffer[1937] = 21'b100000000000000000000;
 buffer[1938] = 21'b100000000000000000000;
 buffer[1939] = 21'b100000000000000000000;
 buffer[1940] = 21'b100000000000000000000;
 buffer[1941] = 21'b100000000000000000000;
 buffer[1942] = 21'b100000000000000000000;
 buffer[1943] = 21'b100000000000000000000;
 buffer[1944] = 21'b100000000000000000000;
 buffer[1945] = 21'b100000000000000000000;
 buffer[1946] = 21'b100000000000000000000;
 buffer[1947] = 21'b100000000000000000000;
 buffer[1948] = 21'b100000000000000000000;
 buffer[1949] = 21'b100000000000000000000;
 buffer[1950] = 21'b100000000000000000000;
 buffer[1951] = 21'b100000000000000000000;
 buffer[1952] = 21'b100000000000000000000;
 buffer[1953] = 21'b100000000000000000000;
 buffer[1954] = 21'b100000000000000000000;
 buffer[1955] = 21'b100000000000000000000;
 buffer[1956] = 21'b100000000000000000000;
 buffer[1957] = 21'b100000000000000000000;
 buffer[1958] = 21'b100000000000000000000;
 buffer[1959] = 21'b100000000000000000000;
 buffer[1960] = 21'b100000000000000000000;
 buffer[1961] = 21'b100000000000000000000;
 buffer[1962] = 21'b100000000000000000000;
 buffer[1963] = 21'b100000000000000000000;
 buffer[1964] = 21'b100000000000000000000;
 buffer[1965] = 21'b100000000000000000000;
 buffer[1966] = 21'b100000000000000000000;
 buffer[1967] = 21'b100000000000000000000;
 buffer[1968] = 21'b100000000000000000000;
 buffer[1969] = 21'b100000000000000000000;
 buffer[1970] = 21'b100000000000000000000;
 buffer[1971] = 21'b100000000000000000000;
 buffer[1972] = 21'b100000000000000000000;
 buffer[1973] = 21'b100000000000000000000;
 buffer[1974] = 21'b100000000000000000000;
 buffer[1975] = 21'b100000000000000000000;
 buffer[1976] = 21'b100000000000000000000;
 buffer[1977] = 21'b100000000000000000000;
 buffer[1978] = 21'b100000000000000000000;
 buffer[1979] = 21'b100000000000000000000;
 buffer[1980] = 21'b100000000000000000000;
 buffer[1981] = 21'b100000000000000000000;
 buffer[1982] = 21'b100000000000000000000;
 buffer[1983] = 21'b100000000000000000000;
 buffer[1984] = 21'b100000000000000000000;
 buffer[1985] = 21'b100000000000000000000;
 buffer[1986] = 21'b100000000000000000000;
 buffer[1987] = 21'b100000000000000000000;
 buffer[1988] = 21'b100000000000000000000;
 buffer[1989] = 21'b100000000000000000000;
 buffer[1990] = 21'b100000000000000000000;
 buffer[1991] = 21'b100000000000000000000;
 buffer[1992] = 21'b100000000000000000000;
 buffer[1993] = 21'b100000000000000000000;
 buffer[1994] = 21'b100000000000000000000;
 buffer[1995] = 21'b100000000000000000000;
 buffer[1996] = 21'b100000000000000000000;
 buffer[1997] = 21'b100000000000000000000;
 buffer[1998] = 21'b100000000000000000000;
 buffer[1999] = 21'b100000000000000000000;
 buffer[2000] = 21'b100000000000000000000;
 buffer[2001] = 21'b100000000000000000000;
 buffer[2002] = 21'b100000000000000000000;
 buffer[2003] = 21'b100000000000000000000;
 buffer[2004] = 21'b100000000000000000000;
 buffer[2005] = 21'b100000000000000000000;
 buffer[2006] = 21'b100000000000000000000;
 buffer[2007] = 21'b100000000000000000000;
 buffer[2008] = 21'b100000000000000000000;
 buffer[2009] = 21'b100000000000000000000;
 buffer[2010] = 21'b100000000000000000000;
 buffer[2011] = 21'b100000000000000000000;
 buffer[2012] = 21'b100000000000000000000;
 buffer[2013] = 21'b100000000000000000000;
 buffer[2014] = 21'b100000000000000000000;
 buffer[2015] = 21'b100000000000000000000;
 buffer[2016] = 21'b100000000000000000000;
 buffer[2017] = 21'b100000000000000000000;
 buffer[2018] = 21'b100000000000000000000;
 buffer[2019] = 21'b100000000000000000000;
 buffer[2020] = 21'b100000000000000000000;
 buffer[2021] = 21'b100000000000000000000;
 buffer[2022] = 21'b100000000000000000000;
 buffer[2023] = 21'b100000000000000000000;
 buffer[2024] = 21'b100000000000000000000;
 buffer[2025] = 21'b100000000000000000000;
 buffer[2026] = 21'b100000000000000000000;
 buffer[2027] = 21'b100000000000000000000;
 buffer[2028] = 21'b100000000000000000000;
 buffer[2029] = 21'b100000000000000000000;
 buffer[2030] = 21'b100000000000000000000;
 buffer[2031] = 21'b100000000000000000000;
 buffer[2032] = 21'b100000000000000000000;
 buffer[2033] = 21'b100000000000000000000;
 buffer[2034] = 21'b100000000000000000000;
 buffer[2035] = 21'b100000000000000000000;
 buffer[2036] = 21'b100000000000000000000;
 buffer[2037] = 21'b100000000000000000000;
 buffer[2038] = 21'b100000000000000000000;
 buffer[2039] = 21'b100000000000000000000;
 buffer[2040] = 21'b100000000000000000000;
 buffer[2041] = 21'b100000000000000000000;
 buffer[2042] = 21'b100000000000000000000;
 buffer[2043] = 21'b100000000000000000000;
 buffer[2044] = 21'b100000000000000000000;
 buffer[2045] = 21'b100000000000000000000;
 buffer[2046] = 21'b100000000000000000000;
 buffer[2047] = 21'b100000000000000000000;
 buffer[2048] = 21'b100000000000000000000;
 buffer[2049] = 21'b100000000000000000000;
 buffer[2050] = 21'b100000000000000000000;
 buffer[2051] = 21'b100000000000000000000;
 buffer[2052] = 21'b100000000000000000000;
 buffer[2053] = 21'b100000000000000000000;
 buffer[2054] = 21'b100000000000000000000;
 buffer[2055] = 21'b100000000000000000000;
 buffer[2056] = 21'b100000000000000000000;
 buffer[2057] = 21'b100000000000000000000;
 buffer[2058] = 21'b100000000000000000000;
 buffer[2059] = 21'b100000000000000000000;
 buffer[2060] = 21'b100000000000000000000;
 buffer[2061] = 21'b100000000000000000000;
 buffer[2062] = 21'b100000000000000000000;
 buffer[2063] = 21'b100000000000000000000;
 buffer[2064] = 21'b100000000000000000000;
 buffer[2065] = 21'b100000000000000000000;
 buffer[2066] = 21'b100000000000000000000;
 buffer[2067] = 21'b100000000000000000000;
 buffer[2068] = 21'b100000000000000000000;
 buffer[2069] = 21'b100000000000000000000;
 buffer[2070] = 21'b100000000000000000000;
 buffer[2071] = 21'b100000000000000000000;
 buffer[2072] = 21'b100000000000000000000;
 buffer[2073] = 21'b100000000000000000000;
 buffer[2074] = 21'b100000000000000000000;
 buffer[2075] = 21'b100000000000000000000;
 buffer[2076] = 21'b100000000000000000000;
 buffer[2077] = 21'b100000000000000000000;
 buffer[2078] = 21'b100000000000000000000;
 buffer[2079] = 21'b100000000000000000000;
 buffer[2080] = 21'b100000000000000000000;
 buffer[2081] = 21'b100000000000000000000;
 buffer[2082] = 21'b100000000000000000000;
 buffer[2083] = 21'b100000000000000000000;
 buffer[2084] = 21'b100000000000000000000;
 buffer[2085] = 21'b100000000000000000000;
 buffer[2086] = 21'b100000000000000000000;
 buffer[2087] = 21'b100000000000000000000;
 buffer[2088] = 21'b100000000000000000000;
 buffer[2089] = 21'b100000000000000000000;
 buffer[2090] = 21'b100000000000000000000;
 buffer[2091] = 21'b100000000000000000000;
 buffer[2092] = 21'b100000000000000000000;
 buffer[2093] = 21'b100000000000000000000;
 buffer[2094] = 21'b100000000000000000000;
 buffer[2095] = 21'b100000000000000000000;
 buffer[2096] = 21'b100000000000000000000;
 buffer[2097] = 21'b100000000000000000000;
 buffer[2098] = 21'b100000000000000000000;
 buffer[2099] = 21'b100000000000000000000;
 buffer[2100] = 21'b100000000000000000000;
 buffer[2101] = 21'b100000000000000000000;
 buffer[2102] = 21'b100000000000000000000;
 buffer[2103] = 21'b100000000000000000000;
 buffer[2104] = 21'b100000000000000000000;
 buffer[2105] = 21'b100000000000000000000;
 buffer[2106] = 21'b100000000000000000000;
 buffer[2107] = 21'b100000000000000000000;
 buffer[2108] = 21'b100000000000000000000;
 buffer[2109] = 21'b100000000000000000000;
 buffer[2110] = 21'b100000000000000000000;
 buffer[2111] = 21'b100000000000000000000;
 buffer[2112] = 21'b100000000000000000000;
 buffer[2113] = 21'b100000000000000000000;
 buffer[2114] = 21'b100000000000000000000;
 buffer[2115] = 21'b100000000000000000000;
 buffer[2116] = 21'b100000000000000000000;
 buffer[2117] = 21'b100000000000000000000;
 buffer[2118] = 21'b100000000000000000000;
 buffer[2119] = 21'b100000000000000000000;
 buffer[2120] = 21'b100000000000000000000;
 buffer[2121] = 21'b100000000000000000000;
 buffer[2122] = 21'b100000000000000000000;
 buffer[2123] = 21'b100000000000000000000;
 buffer[2124] = 21'b100000000000000000000;
 buffer[2125] = 21'b100000000000000000000;
 buffer[2126] = 21'b100000000000000000000;
 buffer[2127] = 21'b100000000000000000000;
 buffer[2128] = 21'b100000000000000000000;
 buffer[2129] = 21'b100000000000000000000;
 buffer[2130] = 21'b100000000000000000000;
 buffer[2131] = 21'b100000000000000000000;
 buffer[2132] = 21'b100000000000000000000;
 buffer[2133] = 21'b100000000000000000000;
 buffer[2134] = 21'b100000000000000000000;
 buffer[2135] = 21'b100000000000000000000;
 buffer[2136] = 21'b100000000000000000000;
 buffer[2137] = 21'b100000000000000000000;
 buffer[2138] = 21'b100000000000000000000;
 buffer[2139] = 21'b100000000000000000000;
 buffer[2140] = 21'b100000000000000000000;
 buffer[2141] = 21'b100000000000000000000;
 buffer[2142] = 21'b100000000000000000000;
 buffer[2143] = 21'b100000000000000000000;
 buffer[2144] = 21'b100000000000000000000;
 buffer[2145] = 21'b100000000000000000000;
 buffer[2146] = 21'b100000000000000000000;
 buffer[2147] = 21'b100000000000000000000;
 buffer[2148] = 21'b100000000000000000000;
 buffer[2149] = 21'b100000000000000000000;
 buffer[2150] = 21'b100000000000000000000;
 buffer[2151] = 21'b100000000000000000000;
 buffer[2152] = 21'b100000000000000000000;
 buffer[2153] = 21'b100000000000000000000;
 buffer[2154] = 21'b100000000000000000000;
 buffer[2155] = 21'b100000000000000000000;
 buffer[2156] = 21'b100000000000000000000;
 buffer[2157] = 21'b100000000000000000000;
 buffer[2158] = 21'b100000000000000000000;
 buffer[2159] = 21'b100000000000000000000;
 buffer[2160] = 21'b100000000000000000000;
 buffer[2161] = 21'b100000000000000000000;
 buffer[2162] = 21'b100000000000000000000;
 buffer[2163] = 21'b100000000000000000000;
 buffer[2164] = 21'b100000000000000000000;
 buffer[2165] = 21'b100000000000000000000;
 buffer[2166] = 21'b100000000000000000000;
 buffer[2167] = 21'b100000000000000000000;
 buffer[2168] = 21'b100000000000000000000;
 buffer[2169] = 21'b100000000000000000000;
 buffer[2170] = 21'b100000000000000000000;
 buffer[2171] = 21'b100000000000000000000;
 buffer[2172] = 21'b100000000000000000000;
 buffer[2173] = 21'b100000000000000000000;
 buffer[2174] = 21'b100000000000000000000;
 buffer[2175] = 21'b100000000000000000000;
 buffer[2176] = 21'b100000000000000000000;
 buffer[2177] = 21'b100000000000000000000;
 buffer[2178] = 21'b100000000000000000000;
 buffer[2179] = 21'b100000000000000000000;
 buffer[2180] = 21'b100000000000000000000;
 buffer[2181] = 21'b100000000000000000000;
 buffer[2182] = 21'b100000000000000000000;
 buffer[2183] = 21'b100000000000000000000;
 buffer[2184] = 21'b100000000000000000000;
 buffer[2185] = 21'b100000000000000000000;
 buffer[2186] = 21'b100000000000000000000;
 buffer[2187] = 21'b100000000000000000000;
 buffer[2188] = 21'b100000000000000000000;
 buffer[2189] = 21'b100000000000000000000;
 buffer[2190] = 21'b100000000000000000000;
 buffer[2191] = 21'b100000000000000000000;
 buffer[2192] = 21'b100000000000000000000;
 buffer[2193] = 21'b100000000000000000000;
 buffer[2194] = 21'b100000000000000000000;
 buffer[2195] = 21'b100000000000000000000;
 buffer[2196] = 21'b100000000000000000000;
 buffer[2197] = 21'b100000000000000000000;
 buffer[2198] = 21'b100000000000000000000;
 buffer[2199] = 21'b100000000000000000000;
 buffer[2200] = 21'b100000000000000000000;
 buffer[2201] = 21'b100000000000000000000;
 buffer[2202] = 21'b100000000000000000000;
 buffer[2203] = 21'b100000000000000000000;
 buffer[2204] = 21'b100000000000000000000;
 buffer[2205] = 21'b100000000000000000000;
 buffer[2206] = 21'b100000000000000000000;
 buffer[2207] = 21'b100000000000000000000;
 buffer[2208] = 21'b100000000000000000000;
 buffer[2209] = 21'b100000000000000000000;
 buffer[2210] = 21'b100000000000000000000;
 buffer[2211] = 21'b100000000000000000000;
 buffer[2212] = 21'b100000000000000000000;
 buffer[2213] = 21'b100000000000000000000;
 buffer[2214] = 21'b100000000000000000000;
 buffer[2215] = 21'b100000000000000000000;
 buffer[2216] = 21'b100000000000000000000;
 buffer[2217] = 21'b100000000000000000000;
 buffer[2218] = 21'b100000000000000000000;
 buffer[2219] = 21'b100000000000000000000;
 buffer[2220] = 21'b100000000000000000000;
 buffer[2221] = 21'b100000000000000000000;
 buffer[2222] = 21'b100000000000000000000;
 buffer[2223] = 21'b100000000000000000000;
 buffer[2224] = 21'b100000000000000000000;
 buffer[2225] = 21'b100000000000000000000;
 buffer[2226] = 21'b100000000000000000000;
 buffer[2227] = 21'b100000000000000000000;
 buffer[2228] = 21'b100000000000000000000;
 buffer[2229] = 21'b100000000000000000000;
 buffer[2230] = 21'b100000000000000000000;
 buffer[2231] = 21'b100000000000000000000;
 buffer[2232] = 21'b100000000000000000000;
 buffer[2233] = 21'b100000000000000000000;
 buffer[2234] = 21'b100000000000000000000;
 buffer[2235] = 21'b100000000000000000000;
 buffer[2236] = 21'b100000000000000000000;
 buffer[2237] = 21'b100000000000000000000;
 buffer[2238] = 21'b100000000000000000000;
 buffer[2239] = 21'b100000000000000000000;
 buffer[2240] = 21'b100000000000000000000;
 buffer[2241] = 21'b100000000000000000000;
 buffer[2242] = 21'b100000000000000000000;
 buffer[2243] = 21'b100000000000000000000;
 buffer[2244] = 21'b100000000000000000000;
 buffer[2245] = 21'b100000000000000000000;
 buffer[2246] = 21'b100000000000000000000;
 buffer[2247] = 21'b100000000000000000000;
 buffer[2248] = 21'b100000000000000000000;
 buffer[2249] = 21'b100000000000000000000;
 buffer[2250] = 21'b100000000000000000000;
 buffer[2251] = 21'b100000000000000000000;
 buffer[2252] = 21'b100000000000000000000;
 buffer[2253] = 21'b100000000000000000000;
 buffer[2254] = 21'b100000000000000000000;
 buffer[2255] = 21'b100000000000000000000;
 buffer[2256] = 21'b100000000000000000000;
 buffer[2257] = 21'b100000000000000000000;
 buffer[2258] = 21'b100000000000000000000;
 buffer[2259] = 21'b100000000000000000000;
 buffer[2260] = 21'b100000000000000000000;
 buffer[2261] = 21'b100000000000000000000;
 buffer[2262] = 21'b100000000000000000000;
 buffer[2263] = 21'b100000000000000000000;
 buffer[2264] = 21'b100000000000000000000;
 buffer[2265] = 21'b100000000000000000000;
 buffer[2266] = 21'b100000000000000000000;
 buffer[2267] = 21'b100000000000000000000;
 buffer[2268] = 21'b100000000000000000000;
 buffer[2269] = 21'b100000000000000000000;
 buffer[2270] = 21'b100000000000000000000;
 buffer[2271] = 21'b100000000000000000000;
 buffer[2272] = 21'b100000000000000000000;
 buffer[2273] = 21'b100000000000000000000;
 buffer[2274] = 21'b100000000000000000000;
 buffer[2275] = 21'b100000000000000000000;
 buffer[2276] = 21'b100000000000000000000;
 buffer[2277] = 21'b100000000000000000000;
 buffer[2278] = 21'b100000000000000000000;
 buffer[2279] = 21'b100000000000000000000;
 buffer[2280] = 21'b100000000000000000000;
 buffer[2281] = 21'b100000000000000000000;
 buffer[2282] = 21'b100000000000000000000;
 buffer[2283] = 21'b100000000000000000000;
 buffer[2284] = 21'b100000000000000000000;
 buffer[2285] = 21'b100000000000000000000;
 buffer[2286] = 21'b100000000000000000000;
 buffer[2287] = 21'b100000000000000000000;
 buffer[2288] = 21'b100000000000000000000;
 buffer[2289] = 21'b100000000000000000000;
 buffer[2290] = 21'b100000000000000000000;
 buffer[2291] = 21'b100000000000000000000;
 buffer[2292] = 21'b100000000000000000000;
 buffer[2293] = 21'b100000000000000000000;
 buffer[2294] = 21'b100000000000000000000;
 buffer[2295] = 21'b100000000000000000000;
 buffer[2296] = 21'b100000000000000000000;
 buffer[2297] = 21'b100000000000000000000;
 buffer[2298] = 21'b100000000000000000000;
 buffer[2299] = 21'b100000000000000000000;
 buffer[2300] = 21'b100000000000000000000;
 buffer[2301] = 21'b100000000000000000000;
 buffer[2302] = 21'b100000000000000000000;
 buffer[2303] = 21'b100000000000000000000;
 buffer[2304] = 21'b100000000000000000000;
 buffer[2305] = 21'b100000000000000000000;
 buffer[2306] = 21'b100000000000000000000;
 buffer[2307] = 21'b100000000000000000000;
 buffer[2308] = 21'b100000000000000000000;
 buffer[2309] = 21'b100000000000000000000;
 buffer[2310] = 21'b100000000000000000000;
 buffer[2311] = 21'b100000000000000000000;
 buffer[2312] = 21'b100000000000000000000;
 buffer[2313] = 21'b100000000000000000000;
 buffer[2314] = 21'b100000000000000000000;
 buffer[2315] = 21'b100000000000000000000;
 buffer[2316] = 21'b100000000000000000000;
 buffer[2317] = 21'b100000000000000000000;
 buffer[2318] = 21'b100000000000000000000;
 buffer[2319] = 21'b100000000000000000000;
 buffer[2320] = 21'b100000000000000000000;
 buffer[2321] = 21'b100000000000000000000;
 buffer[2322] = 21'b100000000000000000000;
 buffer[2323] = 21'b100000000000000000000;
 buffer[2324] = 21'b100000000000000000000;
 buffer[2325] = 21'b100000000000000000000;
 buffer[2326] = 21'b100000000000000000000;
 buffer[2327] = 21'b100000000000000000000;
 buffer[2328] = 21'b100000000000000000000;
 buffer[2329] = 21'b100000000000000000000;
 buffer[2330] = 21'b100000000000000000000;
 buffer[2331] = 21'b100000000000000000000;
 buffer[2332] = 21'b100000000000000000000;
 buffer[2333] = 21'b100000000000000000000;
 buffer[2334] = 21'b100000000000000000000;
 buffer[2335] = 21'b100000000000000000000;
 buffer[2336] = 21'b100000000000000000000;
 buffer[2337] = 21'b100000000000000000000;
 buffer[2338] = 21'b100000000000000000000;
 buffer[2339] = 21'b100000000000000000000;
 buffer[2340] = 21'b100000000000000000000;
 buffer[2341] = 21'b100000000000000000000;
 buffer[2342] = 21'b100000000000000000000;
 buffer[2343] = 21'b100000000000000000000;
 buffer[2344] = 21'b100000000000000000000;
 buffer[2345] = 21'b100000000000000000000;
 buffer[2346] = 21'b100000000000000000000;
 buffer[2347] = 21'b100000000000000000000;
 buffer[2348] = 21'b100000000000000000000;
 buffer[2349] = 21'b100000000000000000000;
 buffer[2350] = 21'b100000000000000000000;
 buffer[2351] = 21'b100000000000000000000;
 buffer[2352] = 21'b100000000000000000000;
 buffer[2353] = 21'b100000000000000000000;
 buffer[2354] = 21'b100000000000000000000;
 buffer[2355] = 21'b100000000000000000000;
 buffer[2356] = 21'b100000000000000000000;
 buffer[2357] = 21'b100000000000000000000;
 buffer[2358] = 21'b100000000000000000000;
 buffer[2359] = 21'b100000000000000000000;
 buffer[2360] = 21'b100000000000000000000;
 buffer[2361] = 21'b100000000000000000000;
 buffer[2362] = 21'b100000000000000000000;
 buffer[2363] = 21'b100000000000000000000;
 buffer[2364] = 21'b100000000000000000000;
 buffer[2365] = 21'b100000000000000000000;
 buffer[2366] = 21'b100000000000000000000;
 buffer[2367] = 21'b100000000000000000000;
 buffer[2368] = 21'b100000000000000000000;
 buffer[2369] = 21'b100000000000000000000;
 buffer[2370] = 21'b100000000000000000000;
 buffer[2371] = 21'b100000000000000000000;
 buffer[2372] = 21'b100000000000000000000;
 buffer[2373] = 21'b100000000000000000000;
 buffer[2374] = 21'b100000000000000000000;
 buffer[2375] = 21'b100000000000000000000;
 buffer[2376] = 21'b100000000000000000000;
 buffer[2377] = 21'b100000000000000000000;
 buffer[2378] = 21'b100000000000000000000;
 buffer[2379] = 21'b100000000000000000000;
 buffer[2380] = 21'b100000000000000000000;
 buffer[2381] = 21'b100000000000000000000;
 buffer[2382] = 21'b100000000000000000000;
 buffer[2383] = 21'b100000000000000000000;
 buffer[2384] = 21'b100000000000000000000;
 buffer[2385] = 21'b100000000000000000000;
 buffer[2386] = 21'b100000000000000000000;
 buffer[2387] = 21'b100000000000000000000;
 buffer[2388] = 21'b100000000000000000000;
 buffer[2389] = 21'b100000000000000000000;
 buffer[2390] = 21'b100000000000000000000;
 buffer[2391] = 21'b100000000000000000000;
 buffer[2392] = 21'b100000000000000000000;
 buffer[2393] = 21'b100000000000000000000;
 buffer[2394] = 21'b100000000000000000000;
 buffer[2395] = 21'b100000000000000000000;
 buffer[2396] = 21'b100000000000000000000;
 buffer[2397] = 21'b100000000000000000000;
 buffer[2398] = 21'b100000000000000000000;
 buffer[2399] = 21'b100000000000000000000;
end

endmodule

module M_character_map (
in_pix_x,
in_pix_y,
in_pix_active,
in_pix_vblank,
in_tpu_x,
in_tpu_y,
in_tpu_character,
in_tpu_foreground,
in_tpu_background,
in_tpu_write,
out_pix_red,
out_pix_green,
out_pix_blue,
out_character_map_display,
out_tpu_active,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [9:0] in_pix_x;
input  [9:0] in_pix_y;
input  [0:0] in_pix_active;
input  [0:0] in_pix_vblank;
input  [6:0] in_tpu_x;
input  [4:0] in_tpu_y;
input  [7:0] in_tpu_character;
input  [5:0] in_tpu_foreground;
input  [6:0] in_tpu_background;
input  [2:0] in_tpu_write;
output  [1:0] out_pix_red;
output  [1:0] out_pix_green;
output  [1:0] out_pix_blue;
output  [0:0] out_character_map_display;
output  [0:0] out_tpu_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [7:0] _w_mem_characterGenerator8x16_rdata;
wire  [20:0] _w_mem_charactermap_rdata0;
wire  [7:0] _w_xcharacterpos;
wire  [11:0] _w_ycharacterpos;
wire  [2:0] _w_xincharacter;
wire  [3:0] _w_yincharacter;
wire  [0:0] _w_characterpixel;

reg  [11:0] _d_characterGenerator8x16_addr;
reg  [11:0] _q_characterGenerator8x16_addr;
reg  [11:0] _d_charactermap_addr0;
reg  [11:0] _q_charactermap_addr0;
reg  [0:0] _d_charactermap_wenable1;
reg  [0:0] _q_charactermap_wenable1;
reg  [20:0] _d_charactermap_wdata1;
reg  [20:0] _q_charactermap_wdata1;
reg  [11:0] _d_charactermap_addr1;
reg  [11:0] _q_charactermap_addr1;
reg  [6:0] _d_tpu_active_x;
reg  [6:0] _q_tpu_active_x;
reg  [4:0] _d_tpu_active_y;
reg  [4:0] _q_tpu_active_y;
reg  [11:0] _d_tpu_cs_addr;
reg  [11:0] _q_tpu_cs_addr;
reg  [11:0] _d_tpu_max_count;
reg  [11:0] _q_tpu_max_count;
reg  [1:0] _d_pix_red,_q_pix_red;
reg  [1:0] _d_pix_green,_q_pix_green;
reg  [1:0] _d_pix_blue,_q_pix_blue;
reg  [0:0] _d_character_map_display,_q_character_map_display;
reg  [0:0] _d_tpu_active,_q_tpu_active;
reg  [2:0] _d_index,_q_index;
assign out_pix_red = _d_pix_red;
assign out_pix_green = _d_pix_green;
assign out_pix_blue = _d_pix_blue;
assign out_character_map_display = _d_character_map_display;
assign out_tpu_active = _q_tpu_active;
assign out_done = (_q_index == 5);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_characterGenerator8x16_addr <= 0;
_q_charactermap_addr0 <= 0;
_q_charactermap_wenable1 <= 0;
_q_charactermap_wdata1 <= 0;
_q_charactermap_addr1 <= 0;
_q_tpu_active_x <= 0;
_q_tpu_active_y <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_characterGenerator8x16_addr <= _d_characterGenerator8x16_addr;
_q_charactermap_addr0 <= _d_charactermap_addr0;
_q_charactermap_wenable1 <= _d_charactermap_wenable1;
_q_charactermap_wdata1 <= _d_charactermap_wdata1;
_q_charactermap_addr1 <= _d_charactermap_addr1;
_q_tpu_active_x <= _d_tpu_active_x;
_q_tpu_active_y <= _d_tpu_active_y;
_q_tpu_cs_addr <= _d_tpu_cs_addr;
_q_tpu_max_count <= _d_tpu_max_count;
_q_pix_red <= _d_pix_red;
_q_pix_green <= _d_pix_green;
_q_pix_blue <= _d_pix_blue;
_q_character_map_display <= _d_character_map_display;
_q_tpu_active <= _d_tpu_active;
_q_index <= _d_index;
  end
end


M_character_map_mem_characterGenerator8x16 __mem__characterGenerator8x16(
.clock(clock),
.in_characterGenerator8x16_addr(_d_characterGenerator8x16_addr),
.out_characterGenerator8x16_rdata(_w_mem_characterGenerator8x16_rdata)
);
M_character_map_mem_charactermap __mem__charactermap(
.clock0(clock),
.clock1(clock),
.in_charactermap_addr0(_d_charactermap_addr0),
.in_charactermap_wenable1(_d_charactermap_wenable1),
.in_charactermap_wdata1(_d_charactermap_wdata1),
.in_charactermap_addr1(_d_charactermap_addr1),
.out_charactermap_rdata0(_w_mem_charactermap_rdata0)
);

assign _w_characterpixel = _w_mem_characterGenerator8x16_rdata[7-_w_xincharacter+:1];
assign _w_yincharacter = (in_pix_y)&15;
assign _w_ycharacterpos = ((in_pix_vblank?0:in_pix_y)>>4)*80;
assign _w_xincharacter = (in_pix_x)&7;
assign _w_xcharacterpos = (in_pix_active?in_pix_x+2:0)>>3;

always @* begin
_d_characterGenerator8x16_addr = _q_characterGenerator8x16_addr;
_d_charactermap_addr0 = _q_charactermap_addr0;
_d_charactermap_wenable1 = _q_charactermap_wenable1;
_d_charactermap_wdata1 = _q_charactermap_wdata1;
_d_charactermap_addr1 = _q_charactermap_addr1;
_d_tpu_active_x = _q_tpu_active_x;
_d_tpu_active_y = _q_tpu_active_y;
_d_tpu_cs_addr = _q_tpu_cs_addr;
_d_tpu_max_count = _q_tpu_max_count;
_d_pix_red = _q_pix_red;
_d_pix_green = _q_pix_green;
_d_pix_blue = _q_pix_blue;
_d_character_map_display = _q_character_map_display;
_d_tpu_active = _q_tpu_active;
_d_index = _q_index;
// _always_pre
_d_charactermap_addr0 = _w_xcharacterpos+_w_ycharacterpos;
_d_charactermap_wenable1 = 1;
_d_characterGenerator8x16_addr = _w_mem_charactermap_rdata0[0+:8]*16+_w_yincharacter;
_d_character_map_display = in_pix_active&&((_w_characterpixel)||(~_w_mem_charactermap_rdata0[20+:1]));
_d_pix_red = _w_characterpixel?_w_mem_charactermap_rdata0[12+:2]:_w_mem_charactermap_rdata0[18+:2];
_d_pix_green = _w_characterpixel?_w_mem_charactermap_rdata0[10+:2]:_w_mem_charactermap_rdata0[16+:2];
_d_pix_blue = _w_characterpixel?_w_mem_charactermap_rdata0[8+:2]:_w_mem_charactermap_rdata0[14+:2];
_d_index = 5;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_characterGenerator8x16_addr = 0;
_d_charactermap_addr0 = 0;
_d_charactermap_wenable1 = 0;
_d_charactermap_wdata1 = 0;
_d_charactermap_addr1 = 0;
_d_tpu_active_x = 0;
_d_tpu_active_y = 0;
// --
_d_charactermap_addr1 = 0;
_d_charactermap_wdata1 = {1'b1,6'b0,6'b0,8'b0};
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
  case (_q_tpu_active)
  0: begin
// __block_6_case
// __block_7
  case (in_tpu_write)
  1: begin
// __block_9_case
// __block_10
// __block_11_copycoordinates
// __block_12
_d_tpu_active_x = in_tpu_x;
_d_tpu_active_y = in_tpu_y;
// __block_13
// __block_14
// __block_15
  end
  2: begin
// __block_16_case
// __block_17
_d_charactermap_addr1 = _q_tpu_active_x+_q_tpu_active_y*80;
_d_charactermap_wdata1 = {in_tpu_background,in_tpu_foreground,in_tpu_character};
_d_tpu_active_y = (_q_tpu_active_x==79)?(_q_tpu_active_y==29)?0:_q_tpu_active_y+1:_q_tpu_active_y;
_d_tpu_active_x = (_q_tpu_active_x==79)?0:_q_tpu_active_x+1;
// __block_18
  end
  3: begin
// __block_19_case
// __block_20
_d_tpu_active_x = 0;
_d_tpu_active_y = 0;
_d_tpu_active = 1;
_d_tpu_cs_addr = 0;
_d_tpu_max_count = 2400;
// __block_21
  end
  4: begin
// __block_22_case
// __block_23
_d_tpu_active_x = 0;
_d_tpu_active_y = in_tpu_y;
_d_tpu_active = 1;
_d_tpu_cs_addr = in_tpu_y*80;
_d_tpu_max_count = in_tpu_y*80+80;
// __block_24
  end
endcase
// __block_8
// __block_25
_d_index = 1;
  end
  1: begin
// __block_26_case
// __block_27
_d_index = 3;
  end
endcase
end else begin
_d_index = 2;
end
end
3: begin
// __while__block_28
if (_q_tpu_cs_addr<_q_tpu_max_count) begin
// __block_29
// __block_31
_d_charactermap_addr1 = _q_tpu_cs_addr;
_d_tpu_cs_addr = _q_tpu_cs_addr+1;
_d_charactermap_wdata1 = {1'b1,6'b0,6'b0,8'b0};
// __block_32
_d_index = 3;
end else begin
_d_index = 4;
end
end
2: begin
// __block_3
_d_index = 5;
end
4: begin
// __block_30
_d_tpu_active = 0;
// __block_33
_d_index = 1;
end
5: begin // end of character_map
end
default: begin 
_d_index = 5;
 end
endcase
end
endmodule


module M_bitmap #(
parameter BITMAP_ADDR0_WIDTH=1,parameter BITMAP_ADDR0_SIGNED=0,parameter BITMAP_ADDR0_INIT=0,
parameter BITMAP_RDATA0_WIDTH=1,parameter BITMAP_RDATA0_SIGNED=0,parameter BITMAP_RDATA0_INIT=0
) (
in_pix_x,
in_pix_y,
in_pix_active,
in_pix_vblank,
in_bitmap_write_offset,
in_bitmap_x_read,
in_bitmap_y_read,
in_bitmap_rdata0,
out_pix_red,
out_pix_green,
out_pix_blue,
out_bitmap_display,
out_x_offset,
out_y_offset,
out_bitmap_colour_read,
out_bitmap_addr0,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [9:0] in_pix_x;
input  [9:0] in_pix_y;
input  [0:0] in_pix_active;
input  [0:0] in_pix_vblank;
input  [2:0] in_bitmap_write_offset;
input signed [15:0] in_bitmap_x_read;
input signed [15:0] in_bitmap_y_read;
input  [BITMAP_RDATA0_WIDTH-1:0] in_bitmap_rdata0;
output  [1:0] out_pix_red;
output  [1:0] out_pix_green;
output  [1:0] out_pix_blue;
output  [0:0] out_bitmap_display;
output  [9:0] out_x_offset;
output  [9:0] out_y_offset;
output  [6:0] out_bitmap_colour_read;
output  [BITMAP_ADDR0_WIDTH-1:0] out_bitmap_addr0;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [9:0] _w_x_plus_one;
wire  [9:0] _w_y_line;
wire  [9:0] _w_x_pixel;

reg  [1:0] _d_pix_red,_q_pix_red;
reg  [1:0] _d_pix_green,_q_pix_green;
reg  [1:0] _d_pix_blue,_q_pix_blue;
reg  [0:0] _d_bitmap_display,_q_bitmap_display;
reg  [9:0] _d_x_offset,_q_x_offset;
reg  [9:0] _d_y_offset,_q_y_offset;
reg  [6:0] _d_bitmap_colour_read,_q_bitmap_colour_read;
reg  [BITMAP_ADDR0_WIDTH-1:0] _d_bitmap_addr0,_q_bitmap_addr0;
reg  [1:0] _d_index,_q_index;
assign out_pix_red = _d_pix_red;
assign out_pix_green = _d_pix_green;
assign out_pix_blue = _d_pix_blue;
assign out_bitmap_display = _d_bitmap_display;
assign out_x_offset = _q_x_offset;
assign out_y_offset = _q_y_offset;
assign out_bitmap_colour_read = _q_bitmap_colour_read;
assign out_bitmap_addr0 = _d_bitmap_addr0;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_bitmap_addr0 <= BITMAP_ADDR0_INIT;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_pix_red <= _d_pix_red;
_q_pix_green <= _d_pix_green;
_q_pix_blue <= _d_pix_blue;
_q_bitmap_display <= _d_bitmap_display;
_q_x_offset <= _d_x_offset;
_q_y_offset <= _d_y_offset;
_q_bitmap_colour_read <= _d_bitmap_colour_read;
_q_bitmap_addr0 <= _d_bitmap_addr0;
_q_index <= _d_index;
  end
end



assign _w_x_pixel = in_pix_active?_w_x_plus_one:_d_x_offset;
assign _w_y_line = in_pix_vblank?_d_y_offset:((in_pix_y+_d_y_offset)>479?(in_pix_y+_d_y_offset)-479:(in_pix_y+_d_y_offset));
assign _w_x_plus_one = (in_pix_x+_d_x_offset+1)>639?(in_pix_x+_d_x_offset+1)-639:(in_pix_x+_d_x_offset+1);

always @* begin
_d_pix_red = _q_pix_red;
_d_pix_green = _q_pix_green;
_d_pix_blue = _q_pix_blue;
_d_bitmap_display = _q_bitmap_display;
_d_x_offset = _q_x_offset;
_d_y_offset = _q_y_offset;
_d_bitmap_colour_read = _q_bitmap_colour_read;
_d_bitmap_addr0 = _q_bitmap_addr0;
_d_index = _q_index;
// _always_pre
_d_bitmap_colour_read = (in_pix_x==in_bitmap_x_read)&&(in_pix_y==in_bitmap_y_read)?in_bitmap_rdata0:_q_bitmap_colour_read;
_d_bitmap_addr0 = _w_x_pixel+(_w_y_line*640);
_d_bitmap_display = in_pix_active&&~in_bitmap_rdata0[6+:1];
_d_pix_red = in_bitmap_rdata0[4+:2];
_d_pix_green = in_bitmap_rdata0[2+:2];
_d_pix_blue = in_bitmap_rdata0[0+:2];
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
  case (in_bitmap_write_offset)
  1: begin
// __block_6_case
// __block_7
_d_x_offset = (_q_x_offset==639)?0:_q_x_offset+1;
// __block_8
  end
  2: begin
// __block_9_case
// __block_10
_d_y_offset = (_q_y_offset==479)?0:_q_y_offset+1;
// __block_11
  end
  3: begin
// __block_12_case
// __block_13
_d_x_offset = (_q_x_offset==0)?639:_q_x_offset-1;
// __block_14
  end
  4: begin
// __block_15_case
// __block_16
_d_y_offset = (_q_y_offset==0)?479:_q_y_offset-1;
// __block_17
  end
  5: begin
// __block_18_case
// __block_19
_d_x_offset = 0;
_d_y_offset = 0;
// __block_20
  end
endcase
// __block_5
// __block_21
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of bitmap
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_bitmapwriter #(
parameter BITMAP_ADDR1_WIDTH=1,parameter BITMAP_ADDR1_SIGNED=0,parameter BITMAP_ADDR1_INIT=0,
parameter BITMAP_WENABLE1_WIDTH=1,parameter BITMAP_WENABLE1_SIGNED=0,parameter BITMAP_WENABLE1_INIT=0,
parameter BITMAP_WDATA1_WIDTH=1,parameter BITMAP_WDATA1_SIGNED=0,parameter BITMAP_WDATA1_INIT=0
) (
in_bitmap_x_write,
in_bitmap_y_write,
in_bitmap_colour_write,
in_bitmap_write,
in_x_offset,
in_y_offset,
out_bitmap_addr1,
out_bitmap_wenable1,
out_bitmap_wdata1,
in_run,
out_done,
reset,
out_clock,
clock
);
input signed [10:0] in_bitmap_x_write;
input signed [10:0] in_bitmap_y_write;
input  [6:0] in_bitmap_colour_write;
input  [0:0] in_bitmap_write;
input  [9:0] in_x_offset;
input  [9:0] in_y_offset;
output  [BITMAP_ADDR1_WIDTH-1:0] out_bitmap_addr1;
output  [BITMAP_WENABLE1_WIDTH-1:0] out_bitmap_wenable1;
output  [BITMAP_WDATA1_WIDTH-1:0] out_bitmap_wdata1;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [9:0] _w_x_write_pixel;
wire  [9:0] _w_y_write_pixel;
wire  [0:0] _w_write_pixel;

reg  [BITMAP_ADDR1_WIDTH-1:0] _d_bitmap_addr1,_q_bitmap_addr1;
reg  [BITMAP_WENABLE1_WIDTH-1:0] _d_bitmap_wenable1,_q_bitmap_wenable1;
reg  [BITMAP_WDATA1_WIDTH-1:0] _d_bitmap_wdata1,_q_bitmap_wdata1;
reg  [1:0] _d_index,_q_index;
assign out_bitmap_addr1 = _d_bitmap_addr1;
assign out_bitmap_wenable1 = _d_bitmap_wenable1;
assign out_bitmap_wdata1 = _d_bitmap_wdata1;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_bitmap_addr1 <= BITMAP_ADDR1_INIT;
_q_bitmap_wenable1 <= BITMAP_WENABLE1_INIT;
_q_bitmap_wdata1 <= BITMAP_WDATA1_INIT;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_bitmap_addr1 <= _d_bitmap_addr1;
_q_bitmap_wenable1 <= _d_bitmap_wenable1;
_q_bitmap_wdata1 <= _d_bitmap_wdata1;
_q_index <= _d_index;
  end
end



assign _w_write_pixel = (in_bitmap_x_write>=0)&&(in_bitmap_x_write<640)&&(in_bitmap_y_write>=0)&&(in_bitmap_y_write<=479)&&in_bitmap_write;
assign _w_y_write_pixel = (in_bitmap_y_write+in_y_offset)>479?(in_bitmap_y_write+in_y_offset)-479:(in_bitmap_y_write+in_y_offset);
assign _w_x_write_pixel = (in_bitmap_x_write+in_x_offset)>639?(in_bitmap_x_write+in_x_offset)-639:(in_bitmap_x_write+in_x_offset);

always @* begin
_d_bitmap_addr1 = _q_bitmap_addr1;
_d_bitmap_wenable1 = _q_bitmap_wenable1;
_d_bitmap_wdata1 = _q_bitmap_wdata1;
_d_index = _q_index;
// _always_pre
_d_bitmap_wenable1 = 1;
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (_w_write_pixel==1) begin
// __block_5
// __block_7
_d_bitmap_addr1 = _w_x_write_pixel+_w_y_write_pixel*640;
_d_bitmap_wdata1 = in_bitmap_colour_write;
// __block_8
end else begin
// __block_6
end
// __block_9
// __block_10
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of bitmapwriter
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_gpu_mem_blit1tilemap(
input      [8:0]                in_blit1tilemap_addr0,
output reg  [15:0]     out_blit1tilemap_rdata0,
output reg  [15:0]     out_blit1tilemap_rdata1,
input      [0:0]             in_blit1tilemap_wenable1,
input      [15:0]                 in_blit1tilemap_wdata1,
input      [8:0]                in_blit1tilemap_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[511:0];
always @(posedge clock0) begin
  out_blit1tilemap_rdata0 <= buffer[in_blit1tilemap_addr0];
end
always @(posedge clock1) begin
  if (in_blit1tilemap_wenable1) begin
    buffer[in_blit1tilemap_addr1] <= in_blit1tilemap_wdata1;
  end
end

endmodule

module M_gpu_mem_characterGenerator8x8(
input      [10:0]                in_characterGenerator8x8_addr0,
output reg  [7:0]     out_characterGenerator8x8_rdata0,
output reg  [7:0]     out_characterGenerator8x8_rdata1,
input      [0:0]             in_characterGenerator8x8_wenable1,
input      [7:0]                 in_characterGenerator8x8_wdata1,
input      [10:0]                in_characterGenerator8x8_addr1,
input      clock0,
input      clock1
);
reg  [7:0] buffer[2047:0];
always @(posedge clock0) begin
  out_characterGenerator8x8_rdata0 <= buffer[in_characterGenerator8x8_addr0];
end
always @(posedge clock1) begin
  if (in_characterGenerator8x8_wenable1) begin
    buffer[in_characterGenerator8x8_addr1] <= in_characterGenerator8x8_wdata1;
  end
end
initial begin
 buffer[0] = 8'h00;
 buffer[1] = 8'h00;
 buffer[2] = 8'h00;
 buffer[3] = 8'h00;
 buffer[4] = 8'h00;
 buffer[5] = 8'h00;
 buffer[6] = 8'h00;
 buffer[7] = 8'h00;
 buffer[8] = 8'h7e;
 buffer[9] = 8'h81;
 buffer[10] = 8'ha5;
 buffer[11] = 8'h81;
 buffer[12] = 8'hbd;
 buffer[13] = 8'h99;
 buffer[14] = 8'h81;
 buffer[15] = 8'h7e;
 buffer[16] = 8'h7e;
 buffer[17] = 8'hff;
 buffer[18] = 8'hdb;
 buffer[19] = 8'hff;
 buffer[20] = 8'hc3;
 buffer[21] = 8'he7;
 buffer[22] = 8'hff;
 buffer[23] = 8'h7e;
 buffer[24] = 8'h6c;
 buffer[25] = 8'hfe;
 buffer[26] = 8'hfe;
 buffer[27] = 8'hfe;
 buffer[28] = 8'h7c;
 buffer[29] = 8'h38;
 buffer[30] = 8'h10;
 buffer[31] = 8'h00;
 buffer[32] = 8'h10;
 buffer[33] = 8'h38;
 buffer[34] = 8'h7c;
 buffer[35] = 8'hfe;
 buffer[36] = 8'h7c;
 buffer[37] = 8'h38;
 buffer[38] = 8'h10;
 buffer[39] = 8'h00;
 buffer[40] = 8'h38;
 buffer[41] = 8'h7c;
 buffer[42] = 8'h38;
 buffer[43] = 8'hfe;
 buffer[44] = 8'hfe;
 buffer[45] = 8'h7c;
 buffer[46] = 8'h38;
 buffer[47] = 8'h7c;
 buffer[48] = 8'h10;
 buffer[49] = 8'h10;
 buffer[50] = 8'h38;
 buffer[51] = 8'h7c;
 buffer[52] = 8'hfe;
 buffer[53] = 8'h7c;
 buffer[54] = 8'h38;
 buffer[55] = 8'h7c;
 buffer[56] = 8'h00;
 buffer[57] = 8'h00;
 buffer[58] = 8'h18;
 buffer[59] = 8'h3c;
 buffer[60] = 8'h3c;
 buffer[61] = 8'h18;
 buffer[62] = 8'h00;
 buffer[63] = 8'h00;
 buffer[64] = 8'hff;
 buffer[65] = 8'hff;
 buffer[66] = 8'he7;
 buffer[67] = 8'hc3;
 buffer[68] = 8'hc3;
 buffer[69] = 8'he7;
 buffer[70] = 8'hff;
 buffer[71] = 8'hff;
 buffer[72] = 8'h00;
 buffer[73] = 8'h3c;
 buffer[74] = 8'h66;
 buffer[75] = 8'h42;
 buffer[76] = 8'h42;
 buffer[77] = 8'h66;
 buffer[78] = 8'h3c;
 buffer[79] = 8'h00;
 buffer[80] = 8'hff;
 buffer[81] = 8'hc3;
 buffer[82] = 8'h99;
 buffer[83] = 8'hbd;
 buffer[84] = 8'hbd;
 buffer[85] = 8'h99;
 buffer[86] = 8'hc3;
 buffer[87] = 8'hff;
 buffer[88] = 8'h0f;
 buffer[89] = 8'h07;
 buffer[90] = 8'h0f;
 buffer[91] = 8'h7d;
 buffer[92] = 8'hcc;
 buffer[93] = 8'hcc;
 buffer[94] = 8'hcc;
 buffer[95] = 8'h78;
 buffer[96] = 8'h3c;
 buffer[97] = 8'h66;
 buffer[98] = 8'h66;
 buffer[99] = 8'h66;
 buffer[100] = 8'h3c;
 buffer[101] = 8'h18;
 buffer[102] = 8'h7e;
 buffer[103] = 8'h18;
 buffer[104] = 8'h3f;
 buffer[105] = 8'h33;
 buffer[106] = 8'h3f;
 buffer[107] = 8'h30;
 buffer[108] = 8'h30;
 buffer[109] = 8'h70;
 buffer[110] = 8'hf0;
 buffer[111] = 8'he0;
 buffer[112] = 8'h7f;
 buffer[113] = 8'h63;
 buffer[114] = 8'h7f;
 buffer[115] = 8'h63;
 buffer[116] = 8'h63;
 buffer[117] = 8'h67;
 buffer[118] = 8'he6;
 buffer[119] = 8'hc0;
 buffer[120] = 8'h99;
 buffer[121] = 8'h5a;
 buffer[122] = 8'h3c;
 buffer[123] = 8'he7;
 buffer[124] = 8'he7;
 buffer[125] = 8'h3c;
 buffer[126] = 8'h5a;
 buffer[127] = 8'h99;
 buffer[128] = 8'h80;
 buffer[129] = 8'he0;
 buffer[130] = 8'hf8;
 buffer[131] = 8'hfe;
 buffer[132] = 8'hf8;
 buffer[133] = 8'he0;
 buffer[134] = 8'h80;
 buffer[135] = 8'h00;
 buffer[136] = 8'h02;
 buffer[137] = 8'h0e;
 buffer[138] = 8'h3e;
 buffer[139] = 8'hfe;
 buffer[140] = 8'h3e;
 buffer[141] = 8'h0e;
 buffer[142] = 8'h02;
 buffer[143] = 8'h00;
 buffer[144] = 8'h18;
 buffer[145] = 8'h3c;
 buffer[146] = 8'h7e;
 buffer[147] = 8'h18;
 buffer[148] = 8'h18;
 buffer[149] = 8'h7e;
 buffer[150] = 8'h3c;
 buffer[151] = 8'h18;
 buffer[152] = 8'h66;
 buffer[153] = 8'h66;
 buffer[154] = 8'h66;
 buffer[155] = 8'h66;
 buffer[156] = 8'h66;
 buffer[157] = 8'h00;
 buffer[158] = 8'h66;
 buffer[159] = 8'h00;
 buffer[160] = 8'h7f;
 buffer[161] = 8'hdb;
 buffer[162] = 8'hdb;
 buffer[163] = 8'h7b;
 buffer[164] = 8'h1b;
 buffer[165] = 8'h1b;
 buffer[166] = 8'h1b;
 buffer[167] = 8'h00;
 buffer[168] = 8'h3e;
 buffer[169] = 8'h63;
 buffer[170] = 8'h38;
 buffer[171] = 8'h6c;
 buffer[172] = 8'h6c;
 buffer[173] = 8'h38;
 buffer[174] = 8'hcc;
 buffer[175] = 8'h78;
 buffer[176] = 8'h00;
 buffer[177] = 8'h00;
 buffer[178] = 8'h00;
 buffer[179] = 8'h00;
 buffer[180] = 8'h7e;
 buffer[181] = 8'h7e;
 buffer[182] = 8'h7e;
 buffer[183] = 8'h00;
 buffer[184] = 8'h18;
 buffer[185] = 8'h3c;
 buffer[186] = 8'h7e;
 buffer[187] = 8'h18;
 buffer[188] = 8'h7e;
 buffer[189] = 8'h3c;
 buffer[190] = 8'h18;
 buffer[191] = 8'hff;
 buffer[192] = 8'h18;
 buffer[193] = 8'h3c;
 buffer[194] = 8'h7e;
 buffer[195] = 8'h18;
 buffer[196] = 8'h18;
 buffer[197] = 8'h18;
 buffer[198] = 8'h18;
 buffer[199] = 8'h00;
 buffer[200] = 8'h18;
 buffer[201] = 8'h18;
 buffer[202] = 8'h18;
 buffer[203] = 8'h18;
 buffer[204] = 8'h7e;
 buffer[205] = 8'h3c;
 buffer[206] = 8'h18;
 buffer[207] = 8'h00;
 buffer[208] = 8'h00;
 buffer[209] = 8'h18;
 buffer[210] = 8'h0c;
 buffer[211] = 8'hfe;
 buffer[212] = 8'h0c;
 buffer[213] = 8'h18;
 buffer[214] = 8'h00;
 buffer[215] = 8'h00;
 buffer[216] = 8'h00;
 buffer[217] = 8'h30;
 buffer[218] = 8'h60;
 buffer[219] = 8'hfe;
 buffer[220] = 8'h60;
 buffer[221] = 8'h30;
 buffer[222] = 8'h00;
 buffer[223] = 8'h00;
 buffer[224] = 8'h00;
 buffer[225] = 8'h00;
 buffer[226] = 8'hc0;
 buffer[227] = 8'hc0;
 buffer[228] = 8'hc0;
 buffer[229] = 8'hfe;
 buffer[230] = 8'h00;
 buffer[231] = 8'h00;
 buffer[232] = 8'h00;
 buffer[233] = 8'h24;
 buffer[234] = 8'h66;
 buffer[235] = 8'hff;
 buffer[236] = 8'h66;
 buffer[237] = 8'h24;
 buffer[238] = 8'h00;
 buffer[239] = 8'h00;
 buffer[240] = 8'h00;
 buffer[241] = 8'h18;
 buffer[242] = 8'h3c;
 buffer[243] = 8'h7e;
 buffer[244] = 8'hff;
 buffer[245] = 8'hff;
 buffer[246] = 8'h00;
 buffer[247] = 8'h00;
 buffer[248] = 8'h00;
 buffer[249] = 8'hff;
 buffer[250] = 8'hff;
 buffer[251] = 8'h7e;
 buffer[252] = 8'h3c;
 buffer[253] = 8'h18;
 buffer[254] = 8'h00;
 buffer[255] = 8'h00;
 buffer[256] = 8'h00;
 buffer[257] = 8'h00;
 buffer[258] = 8'h00;
 buffer[259] = 8'h00;
 buffer[260] = 8'h00;
 buffer[261] = 8'h00;
 buffer[262] = 8'h00;
 buffer[263] = 8'h00;
 buffer[264] = 8'h30;
 buffer[265] = 8'h78;
 buffer[266] = 8'h78;
 buffer[267] = 8'h30;
 buffer[268] = 8'h30;
 buffer[269] = 8'h00;
 buffer[270] = 8'h30;
 buffer[271] = 8'h00;
 buffer[272] = 8'h6c;
 buffer[273] = 8'h6c;
 buffer[274] = 8'h6c;
 buffer[275] = 8'h00;
 buffer[276] = 8'h00;
 buffer[277] = 8'h00;
 buffer[278] = 8'h00;
 buffer[279] = 8'h00;
 buffer[280] = 8'h6c;
 buffer[281] = 8'h6c;
 buffer[282] = 8'hfe;
 buffer[283] = 8'h6c;
 buffer[284] = 8'hfe;
 buffer[285] = 8'h6c;
 buffer[286] = 8'h6c;
 buffer[287] = 8'h00;
 buffer[288] = 8'h30;
 buffer[289] = 8'h7c;
 buffer[290] = 8'hc0;
 buffer[291] = 8'h78;
 buffer[292] = 8'h0c;
 buffer[293] = 8'hf8;
 buffer[294] = 8'h30;
 buffer[295] = 8'h00;
 buffer[296] = 8'h00;
 buffer[297] = 8'hc6;
 buffer[298] = 8'hcc;
 buffer[299] = 8'h18;
 buffer[300] = 8'h30;
 buffer[301] = 8'h66;
 buffer[302] = 8'hc6;
 buffer[303] = 8'h00;
 buffer[304] = 8'h38;
 buffer[305] = 8'h6c;
 buffer[306] = 8'h38;
 buffer[307] = 8'h76;
 buffer[308] = 8'hdc;
 buffer[309] = 8'hcc;
 buffer[310] = 8'h76;
 buffer[311] = 8'h00;
 buffer[312] = 8'h60;
 buffer[313] = 8'h60;
 buffer[314] = 8'hc0;
 buffer[315] = 8'h00;
 buffer[316] = 8'h00;
 buffer[317] = 8'h00;
 buffer[318] = 8'h00;
 buffer[319] = 8'h00;
 buffer[320] = 8'h18;
 buffer[321] = 8'h30;
 buffer[322] = 8'h60;
 buffer[323] = 8'h60;
 buffer[324] = 8'h60;
 buffer[325] = 8'h30;
 buffer[326] = 8'h18;
 buffer[327] = 8'h00;
 buffer[328] = 8'h60;
 buffer[329] = 8'h30;
 buffer[330] = 8'h18;
 buffer[331] = 8'h18;
 buffer[332] = 8'h18;
 buffer[333] = 8'h30;
 buffer[334] = 8'h60;
 buffer[335] = 8'h00;
 buffer[336] = 8'h00;
 buffer[337] = 8'h66;
 buffer[338] = 8'h3c;
 buffer[339] = 8'hff;
 buffer[340] = 8'h3c;
 buffer[341] = 8'h66;
 buffer[342] = 8'h00;
 buffer[343] = 8'h00;
 buffer[344] = 8'h00;
 buffer[345] = 8'h30;
 buffer[346] = 8'h30;
 buffer[347] = 8'hfc;
 buffer[348] = 8'h30;
 buffer[349] = 8'h30;
 buffer[350] = 8'h00;
 buffer[351] = 8'h00;
 buffer[352] = 8'h00;
 buffer[353] = 8'h00;
 buffer[354] = 8'h00;
 buffer[355] = 8'h00;
 buffer[356] = 8'h00;
 buffer[357] = 8'h30;
 buffer[358] = 8'h30;
 buffer[359] = 8'h60;
 buffer[360] = 8'h00;
 buffer[361] = 8'h00;
 buffer[362] = 8'h00;
 buffer[363] = 8'hfc;
 buffer[364] = 8'h00;
 buffer[365] = 8'h00;
 buffer[366] = 8'h00;
 buffer[367] = 8'h00;
 buffer[368] = 8'h00;
 buffer[369] = 8'h00;
 buffer[370] = 8'h00;
 buffer[371] = 8'h00;
 buffer[372] = 8'h00;
 buffer[373] = 8'h30;
 buffer[374] = 8'h30;
 buffer[375] = 8'h00;
 buffer[376] = 8'h06;
 buffer[377] = 8'h0c;
 buffer[378] = 8'h18;
 buffer[379] = 8'h30;
 buffer[380] = 8'h60;
 buffer[381] = 8'hc0;
 buffer[382] = 8'h80;
 buffer[383] = 8'h00;
 buffer[384] = 8'h7c;
 buffer[385] = 8'hc6;
 buffer[386] = 8'hce;
 buffer[387] = 8'hde;
 buffer[388] = 8'hf6;
 buffer[389] = 8'he6;
 buffer[390] = 8'h7c;
 buffer[391] = 8'h00;
 buffer[392] = 8'h30;
 buffer[393] = 8'h70;
 buffer[394] = 8'h30;
 buffer[395] = 8'h30;
 buffer[396] = 8'h30;
 buffer[397] = 8'h30;
 buffer[398] = 8'hfc;
 buffer[399] = 8'h00;
 buffer[400] = 8'h78;
 buffer[401] = 8'hcc;
 buffer[402] = 8'h0c;
 buffer[403] = 8'h38;
 buffer[404] = 8'h60;
 buffer[405] = 8'hcc;
 buffer[406] = 8'hfc;
 buffer[407] = 8'h00;
 buffer[408] = 8'h78;
 buffer[409] = 8'hcc;
 buffer[410] = 8'h0c;
 buffer[411] = 8'h38;
 buffer[412] = 8'h0c;
 buffer[413] = 8'hcc;
 buffer[414] = 8'h78;
 buffer[415] = 8'h00;
 buffer[416] = 8'h1c;
 buffer[417] = 8'h3c;
 buffer[418] = 8'h6c;
 buffer[419] = 8'hcc;
 buffer[420] = 8'hfe;
 buffer[421] = 8'h0c;
 buffer[422] = 8'h1e;
 buffer[423] = 8'h00;
 buffer[424] = 8'hfc;
 buffer[425] = 8'hc0;
 buffer[426] = 8'hf8;
 buffer[427] = 8'h0c;
 buffer[428] = 8'h0c;
 buffer[429] = 8'hcc;
 buffer[430] = 8'h78;
 buffer[431] = 8'h00;
 buffer[432] = 8'h38;
 buffer[433] = 8'h60;
 buffer[434] = 8'hc0;
 buffer[435] = 8'hf8;
 buffer[436] = 8'hcc;
 buffer[437] = 8'hcc;
 buffer[438] = 8'h78;
 buffer[439] = 8'h00;
 buffer[440] = 8'hfc;
 buffer[441] = 8'hcc;
 buffer[442] = 8'h0c;
 buffer[443] = 8'h18;
 buffer[444] = 8'h30;
 buffer[445] = 8'h30;
 buffer[446] = 8'h30;
 buffer[447] = 8'h00;
 buffer[448] = 8'h78;
 buffer[449] = 8'hcc;
 buffer[450] = 8'hcc;
 buffer[451] = 8'h78;
 buffer[452] = 8'hcc;
 buffer[453] = 8'hcc;
 buffer[454] = 8'h78;
 buffer[455] = 8'h00;
 buffer[456] = 8'h78;
 buffer[457] = 8'hcc;
 buffer[458] = 8'hcc;
 buffer[459] = 8'h7c;
 buffer[460] = 8'h0c;
 buffer[461] = 8'h18;
 buffer[462] = 8'h70;
 buffer[463] = 8'h00;
 buffer[464] = 8'h00;
 buffer[465] = 8'h30;
 buffer[466] = 8'h30;
 buffer[467] = 8'h00;
 buffer[468] = 8'h00;
 buffer[469] = 8'h30;
 buffer[470] = 8'h30;
 buffer[471] = 8'h00;
 buffer[472] = 8'h00;
 buffer[473] = 8'h30;
 buffer[474] = 8'h30;
 buffer[475] = 8'h00;
 buffer[476] = 8'h00;
 buffer[477] = 8'h30;
 buffer[478] = 8'h30;
 buffer[479] = 8'h60;
 buffer[480] = 8'h18;
 buffer[481] = 8'h30;
 buffer[482] = 8'h60;
 buffer[483] = 8'hc0;
 buffer[484] = 8'h60;
 buffer[485] = 8'h30;
 buffer[486] = 8'h18;
 buffer[487] = 8'h00;
 buffer[488] = 8'h00;
 buffer[489] = 8'h00;
 buffer[490] = 8'hfc;
 buffer[491] = 8'h00;
 buffer[492] = 8'h00;
 buffer[493] = 8'hfc;
 buffer[494] = 8'h00;
 buffer[495] = 8'h00;
 buffer[496] = 8'h60;
 buffer[497] = 8'h30;
 buffer[498] = 8'h18;
 buffer[499] = 8'h0c;
 buffer[500] = 8'h18;
 buffer[501] = 8'h30;
 buffer[502] = 8'h60;
 buffer[503] = 8'h00;
 buffer[504] = 8'h78;
 buffer[505] = 8'hcc;
 buffer[506] = 8'h0c;
 buffer[507] = 8'h18;
 buffer[508] = 8'h30;
 buffer[509] = 8'h00;
 buffer[510] = 8'h30;
 buffer[511] = 8'h00;
 buffer[512] = 8'h7c;
 buffer[513] = 8'hc6;
 buffer[514] = 8'hde;
 buffer[515] = 8'hde;
 buffer[516] = 8'hde;
 buffer[517] = 8'hc0;
 buffer[518] = 8'h78;
 buffer[519] = 8'h00;
 buffer[520] = 8'h30;
 buffer[521] = 8'h78;
 buffer[522] = 8'hcc;
 buffer[523] = 8'hcc;
 buffer[524] = 8'hfc;
 buffer[525] = 8'hcc;
 buffer[526] = 8'hcc;
 buffer[527] = 8'h00;
 buffer[528] = 8'hfc;
 buffer[529] = 8'h66;
 buffer[530] = 8'h66;
 buffer[531] = 8'h7c;
 buffer[532] = 8'h66;
 buffer[533] = 8'h66;
 buffer[534] = 8'hfc;
 buffer[535] = 8'h00;
 buffer[536] = 8'h3c;
 buffer[537] = 8'h66;
 buffer[538] = 8'hc0;
 buffer[539] = 8'hc0;
 buffer[540] = 8'hc0;
 buffer[541] = 8'h66;
 buffer[542] = 8'h3c;
 buffer[543] = 8'h00;
 buffer[544] = 8'hf8;
 buffer[545] = 8'h6c;
 buffer[546] = 8'h66;
 buffer[547] = 8'h66;
 buffer[548] = 8'h66;
 buffer[549] = 8'h6c;
 buffer[550] = 8'hf8;
 buffer[551] = 8'h00;
 buffer[552] = 8'hfe;
 buffer[553] = 8'h62;
 buffer[554] = 8'h68;
 buffer[555] = 8'h78;
 buffer[556] = 8'h68;
 buffer[557] = 8'h62;
 buffer[558] = 8'hfe;
 buffer[559] = 8'h00;
 buffer[560] = 8'hfe;
 buffer[561] = 8'h62;
 buffer[562] = 8'h68;
 buffer[563] = 8'h78;
 buffer[564] = 8'h68;
 buffer[565] = 8'h60;
 buffer[566] = 8'hf0;
 buffer[567] = 8'h00;
 buffer[568] = 8'h3c;
 buffer[569] = 8'h66;
 buffer[570] = 8'hc0;
 buffer[571] = 8'hc0;
 buffer[572] = 8'hce;
 buffer[573] = 8'h66;
 buffer[574] = 8'h3e;
 buffer[575] = 8'h00;
 buffer[576] = 8'hcc;
 buffer[577] = 8'hcc;
 buffer[578] = 8'hcc;
 buffer[579] = 8'hfc;
 buffer[580] = 8'hcc;
 buffer[581] = 8'hcc;
 buffer[582] = 8'hcc;
 buffer[583] = 8'h00;
 buffer[584] = 8'h78;
 buffer[585] = 8'h30;
 buffer[586] = 8'h30;
 buffer[587] = 8'h30;
 buffer[588] = 8'h30;
 buffer[589] = 8'h30;
 buffer[590] = 8'h78;
 buffer[591] = 8'h00;
 buffer[592] = 8'h1e;
 buffer[593] = 8'h0c;
 buffer[594] = 8'h0c;
 buffer[595] = 8'h0c;
 buffer[596] = 8'hcc;
 buffer[597] = 8'hcc;
 buffer[598] = 8'h78;
 buffer[599] = 8'h00;
 buffer[600] = 8'he6;
 buffer[601] = 8'h66;
 buffer[602] = 8'h6c;
 buffer[603] = 8'h78;
 buffer[604] = 8'h6c;
 buffer[605] = 8'h66;
 buffer[606] = 8'he6;
 buffer[607] = 8'h00;
 buffer[608] = 8'hf0;
 buffer[609] = 8'h60;
 buffer[610] = 8'h60;
 buffer[611] = 8'h60;
 buffer[612] = 8'h62;
 buffer[613] = 8'h66;
 buffer[614] = 8'hfe;
 buffer[615] = 8'h00;
 buffer[616] = 8'hc6;
 buffer[617] = 8'hee;
 buffer[618] = 8'hfe;
 buffer[619] = 8'hfe;
 buffer[620] = 8'hd6;
 buffer[621] = 8'hc6;
 buffer[622] = 8'hc6;
 buffer[623] = 8'h00;
 buffer[624] = 8'hc6;
 buffer[625] = 8'he6;
 buffer[626] = 8'hf6;
 buffer[627] = 8'hde;
 buffer[628] = 8'hce;
 buffer[629] = 8'hc6;
 buffer[630] = 8'hc6;
 buffer[631] = 8'h00;
 buffer[632] = 8'h38;
 buffer[633] = 8'h6c;
 buffer[634] = 8'hc6;
 buffer[635] = 8'hc6;
 buffer[636] = 8'hc6;
 buffer[637] = 8'h6c;
 buffer[638] = 8'h38;
 buffer[639] = 8'h00;
 buffer[640] = 8'hfc;
 buffer[641] = 8'h66;
 buffer[642] = 8'h66;
 buffer[643] = 8'h7c;
 buffer[644] = 8'h60;
 buffer[645] = 8'h60;
 buffer[646] = 8'hf0;
 buffer[647] = 8'h00;
 buffer[648] = 8'h78;
 buffer[649] = 8'hcc;
 buffer[650] = 8'hcc;
 buffer[651] = 8'hcc;
 buffer[652] = 8'hdc;
 buffer[653] = 8'h78;
 buffer[654] = 8'h1c;
 buffer[655] = 8'h00;
 buffer[656] = 8'hfc;
 buffer[657] = 8'h66;
 buffer[658] = 8'h66;
 buffer[659] = 8'h7c;
 buffer[660] = 8'h6c;
 buffer[661] = 8'h66;
 buffer[662] = 8'he6;
 buffer[663] = 8'h00;
 buffer[664] = 8'h78;
 buffer[665] = 8'hcc;
 buffer[666] = 8'he0;
 buffer[667] = 8'h70;
 buffer[668] = 8'h1c;
 buffer[669] = 8'hcc;
 buffer[670] = 8'h78;
 buffer[671] = 8'h00;
 buffer[672] = 8'hfc;
 buffer[673] = 8'hb4;
 buffer[674] = 8'h30;
 buffer[675] = 8'h30;
 buffer[676] = 8'h30;
 buffer[677] = 8'h30;
 buffer[678] = 8'h78;
 buffer[679] = 8'h00;
 buffer[680] = 8'hcc;
 buffer[681] = 8'hcc;
 buffer[682] = 8'hcc;
 buffer[683] = 8'hcc;
 buffer[684] = 8'hcc;
 buffer[685] = 8'hcc;
 buffer[686] = 8'hfc;
 buffer[687] = 8'h00;
 buffer[688] = 8'hcc;
 buffer[689] = 8'hcc;
 buffer[690] = 8'hcc;
 buffer[691] = 8'hcc;
 buffer[692] = 8'hcc;
 buffer[693] = 8'h78;
 buffer[694] = 8'h30;
 buffer[695] = 8'h00;
 buffer[696] = 8'hc6;
 buffer[697] = 8'hc6;
 buffer[698] = 8'hc6;
 buffer[699] = 8'hd6;
 buffer[700] = 8'hfe;
 buffer[701] = 8'hee;
 buffer[702] = 8'hc6;
 buffer[703] = 8'h00;
 buffer[704] = 8'hc6;
 buffer[705] = 8'hc6;
 buffer[706] = 8'h6c;
 buffer[707] = 8'h38;
 buffer[708] = 8'h38;
 buffer[709] = 8'h6c;
 buffer[710] = 8'hc6;
 buffer[711] = 8'h00;
 buffer[712] = 8'hcc;
 buffer[713] = 8'hcc;
 buffer[714] = 8'hcc;
 buffer[715] = 8'h78;
 buffer[716] = 8'h30;
 buffer[717] = 8'h30;
 buffer[718] = 8'h78;
 buffer[719] = 8'h00;
 buffer[720] = 8'hfe;
 buffer[721] = 8'hc6;
 buffer[722] = 8'h8c;
 buffer[723] = 8'h18;
 buffer[724] = 8'h32;
 buffer[725] = 8'h66;
 buffer[726] = 8'hfe;
 buffer[727] = 8'h00;
 buffer[728] = 8'h78;
 buffer[729] = 8'h60;
 buffer[730] = 8'h60;
 buffer[731] = 8'h60;
 buffer[732] = 8'h60;
 buffer[733] = 8'h60;
 buffer[734] = 8'h78;
 buffer[735] = 8'h00;
 buffer[736] = 8'hc0;
 buffer[737] = 8'h60;
 buffer[738] = 8'h30;
 buffer[739] = 8'h18;
 buffer[740] = 8'h0c;
 buffer[741] = 8'h06;
 buffer[742] = 8'h02;
 buffer[743] = 8'h00;
 buffer[744] = 8'h78;
 buffer[745] = 8'h18;
 buffer[746] = 8'h18;
 buffer[747] = 8'h18;
 buffer[748] = 8'h18;
 buffer[749] = 8'h18;
 buffer[750] = 8'h78;
 buffer[751] = 8'h00;
 buffer[752] = 8'h10;
 buffer[753] = 8'h38;
 buffer[754] = 8'h6c;
 buffer[755] = 8'hc6;
 buffer[756] = 8'h00;
 buffer[757] = 8'h00;
 buffer[758] = 8'h00;
 buffer[759] = 8'h00;
 buffer[760] = 8'h00;
 buffer[761] = 8'h00;
 buffer[762] = 8'h00;
 buffer[763] = 8'h00;
 buffer[764] = 8'h00;
 buffer[765] = 8'h00;
 buffer[766] = 8'h00;
 buffer[767] = 8'hff;
 buffer[768] = 8'h30;
 buffer[769] = 8'h30;
 buffer[770] = 8'h18;
 buffer[771] = 8'h00;
 buffer[772] = 8'h00;
 buffer[773] = 8'h00;
 buffer[774] = 8'h00;
 buffer[775] = 8'h00;
 buffer[776] = 8'h00;
 buffer[777] = 8'h00;
 buffer[778] = 8'h78;
 buffer[779] = 8'h0c;
 buffer[780] = 8'h7c;
 buffer[781] = 8'hcc;
 buffer[782] = 8'h76;
 buffer[783] = 8'h00;
 buffer[784] = 8'he0;
 buffer[785] = 8'h60;
 buffer[786] = 8'h60;
 buffer[787] = 8'h7c;
 buffer[788] = 8'h66;
 buffer[789] = 8'h66;
 buffer[790] = 8'hdc;
 buffer[791] = 8'h00;
 buffer[792] = 8'h00;
 buffer[793] = 8'h00;
 buffer[794] = 8'h78;
 buffer[795] = 8'hcc;
 buffer[796] = 8'hc0;
 buffer[797] = 8'hcc;
 buffer[798] = 8'h78;
 buffer[799] = 8'h00;
 buffer[800] = 8'h1c;
 buffer[801] = 8'h0c;
 buffer[802] = 8'h0c;
 buffer[803] = 8'h7c;
 buffer[804] = 8'hcc;
 buffer[805] = 8'hcc;
 buffer[806] = 8'h76;
 buffer[807] = 8'h00;
 buffer[808] = 8'h00;
 buffer[809] = 8'h00;
 buffer[810] = 8'h78;
 buffer[811] = 8'hcc;
 buffer[812] = 8'hfc;
 buffer[813] = 8'hc0;
 buffer[814] = 8'h78;
 buffer[815] = 8'h00;
 buffer[816] = 8'h38;
 buffer[817] = 8'h6c;
 buffer[818] = 8'h60;
 buffer[819] = 8'hf0;
 buffer[820] = 8'h60;
 buffer[821] = 8'h60;
 buffer[822] = 8'hf0;
 buffer[823] = 8'h00;
 buffer[824] = 8'h00;
 buffer[825] = 8'h00;
 buffer[826] = 8'h76;
 buffer[827] = 8'hcc;
 buffer[828] = 8'hcc;
 buffer[829] = 8'h7c;
 buffer[830] = 8'h0c;
 buffer[831] = 8'hf8;
 buffer[832] = 8'he0;
 buffer[833] = 8'h60;
 buffer[834] = 8'h6c;
 buffer[835] = 8'h76;
 buffer[836] = 8'h66;
 buffer[837] = 8'h66;
 buffer[838] = 8'he6;
 buffer[839] = 8'h00;
 buffer[840] = 8'h30;
 buffer[841] = 8'h00;
 buffer[842] = 8'h70;
 buffer[843] = 8'h30;
 buffer[844] = 8'h30;
 buffer[845] = 8'h30;
 buffer[846] = 8'h78;
 buffer[847] = 8'h00;
 buffer[848] = 8'h0c;
 buffer[849] = 8'h00;
 buffer[850] = 8'h0c;
 buffer[851] = 8'h0c;
 buffer[852] = 8'h0c;
 buffer[853] = 8'hcc;
 buffer[854] = 8'hcc;
 buffer[855] = 8'h78;
 buffer[856] = 8'he0;
 buffer[857] = 8'h60;
 buffer[858] = 8'h66;
 buffer[859] = 8'h6c;
 buffer[860] = 8'h78;
 buffer[861] = 8'h6c;
 buffer[862] = 8'he6;
 buffer[863] = 8'h00;
 buffer[864] = 8'h70;
 buffer[865] = 8'h30;
 buffer[866] = 8'h30;
 buffer[867] = 8'h30;
 buffer[868] = 8'h30;
 buffer[869] = 8'h30;
 buffer[870] = 8'h78;
 buffer[871] = 8'h00;
 buffer[872] = 8'h00;
 buffer[873] = 8'h00;
 buffer[874] = 8'hcc;
 buffer[875] = 8'hfe;
 buffer[876] = 8'hfe;
 buffer[877] = 8'hd6;
 buffer[878] = 8'hc6;
 buffer[879] = 8'h00;
 buffer[880] = 8'h00;
 buffer[881] = 8'h00;
 buffer[882] = 8'hf8;
 buffer[883] = 8'hcc;
 buffer[884] = 8'hcc;
 buffer[885] = 8'hcc;
 buffer[886] = 8'hcc;
 buffer[887] = 8'h00;
 buffer[888] = 8'h00;
 buffer[889] = 8'h00;
 buffer[890] = 8'h78;
 buffer[891] = 8'hcc;
 buffer[892] = 8'hcc;
 buffer[893] = 8'hcc;
 buffer[894] = 8'h78;
 buffer[895] = 8'h00;
 buffer[896] = 8'h00;
 buffer[897] = 8'h00;
 buffer[898] = 8'hdc;
 buffer[899] = 8'h66;
 buffer[900] = 8'h66;
 buffer[901] = 8'h7c;
 buffer[902] = 8'h60;
 buffer[903] = 8'hf0;
 buffer[904] = 8'h00;
 buffer[905] = 8'h00;
 buffer[906] = 8'h76;
 buffer[907] = 8'hcc;
 buffer[908] = 8'hcc;
 buffer[909] = 8'h7c;
 buffer[910] = 8'h0c;
 buffer[911] = 8'h1e;
 buffer[912] = 8'h00;
 buffer[913] = 8'h00;
 buffer[914] = 8'hdc;
 buffer[915] = 8'h76;
 buffer[916] = 8'h66;
 buffer[917] = 8'h60;
 buffer[918] = 8'hf0;
 buffer[919] = 8'h00;
 buffer[920] = 8'h00;
 buffer[921] = 8'h00;
 buffer[922] = 8'h7c;
 buffer[923] = 8'hc0;
 buffer[924] = 8'h78;
 buffer[925] = 8'h0c;
 buffer[926] = 8'hf8;
 buffer[927] = 8'h00;
 buffer[928] = 8'h10;
 buffer[929] = 8'h30;
 buffer[930] = 8'h7c;
 buffer[931] = 8'h30;
 buffer[932] = 8'h30;
 buffer[933] = 8'h34;
 buffer[934] = 8'h18;
 buffer[935] = 8'h00;
 buffer[936] = 8'h00;
 buffer[937] = 8'h00;
 buffer[938] = 8'hcc;
 buffer[939] = 8'hcc;
 buffer[940] = 8'hcc;
 buffer[941] = 8'hcc;
 buffer[942] = 8'h76;
 buffer[943] = 8'h00;
 buffer[944] = 8'h00;
 buffer[945] = 8'h00;
 buffer[946] = 8'hcc;
 buffer[947] = 8'hcc;
 buffer[948] = 8'hcc;
 buffer[949] = 8'h78;
 buffer[950] = 8'h30;
 buffer[951] = 8'h00;
 buffer[952] = 8'h00;
 buffer[953] = 8'h00;
 buffer[954] = 8'hc6;
 buffer[955] = 8'hd6;
 buffer[956] = 8'hfe;
 buffer[957] = 8'hfe;
 buffer[958] = 8'h6c;
 buffer[959] = 8'h00;
 buffer[960] = 8'h00;
 buffer[961] = 8'h00;
 buffer[962] = 8'hc6;
 buffer[963] = 8'h6c;
 buffer[964] = 8'h38;
 buffer[965] = 8'h6c;
 buffer[966] = 8'hc6;
 buffer[967] = 8'h00;
 buffer[968] = 8'h00;
 buffer[969] = 8'h00;
 buffer[970] = 8'hcc;
 buffer[971] = 8'hcc;
 buffer[972] = 8'hcc;
 buffer[973] = 8'h7c;
 buffer[974] = 8'h0c;
 buffer[975] = 8'hf8;
 buffer[976] = 8'h00;
 buffer[977] = 8'h00;
 buffer[978] = 8'hfc;
 buffer[979] = 8'h98;
 buffer[980] = 8'h30;
 buffer[981] = 8'h64;
 buffer[982] = 8'hfc;
 buffer[983] = 8'h00;
 buffer[984] = 8'h1c;
 buffer[985] = 8'h30;
 buffer[986] = 8'h30;
 buffer[987] = 8'he0;
 buffer[988] = 8'h30;
 buffer[989] = 8'h30;
 buffer[990] = 8'h1c;
 buffer[991] = 8'h00;
 buffer[992] = 8'h18;
 buffer[993] = 8'h18;
 buffer[994] = 8'h18;
 buffer[995] = 8'h00;
 buffer[996] = 8'h18;
 buffer[997] = 8'h18;
 buffer[998] = 8'h18;
 buffer[999] = 8'h00;
 buffer[1000] = 8'he0;
 buffer[1001] = 8'h30;
 buffer[1002] = 8'h30;
 buffer[1003] = 8'h1c;
 buffer[1004] = 8'h30;
 buffer[1005] = 8'h30;
 buffer[1006] = 8'he0;
 buffer[1007] = 8'h00;
 buffer[1008] = 8'h76;
 buffer[1009] = 8'hdc;
 buffer[1010] = 8'h00;
 buffer[1011] = 8'h00;
 buffer[1012] = 8'h00;
 buffer[1013] = 8'h00;
 buffer[1014] = 8'h00;
 buffer[1015] = 8'h00;
 buffer[1016] = 8'h00;
 buffer[1017] = 8'h10;
 buffer[1018] = 8'h38;
 buffer[1019] = 8'h6c;
 buffer[1020] = 8'hc6;
 buffer[1021] = 8'hc6;
 buffer[1022] = 8'hfe;
 buffer[1023] = 8'h00;
 buffer[1024] = 8'h78;
 buffer[1025] = 8'hcc;
 buffer[1026] = 8'hc0;
 buffer[1027] = 8'hcc;
 buffer[1028] = 8'h78;
 buffer[1029] = 8'h18;
 buffer[1030] = 8'h0c;
 buffer[1031] = 8'h78;
 buffer[1032] = 8'h00;
 buffer[1033] = 8'hcc;
 buffer[1034] = 8'h00;
 buffer[1035] = 8'hcc;
 buffer[1036] = 8'hcc;
 buffer[1037] = 8'hcc;
 buffer[1038] = 8'h7e;
 buffer[1039] = 8'h00;
 buffer[1040] = 8'h1c;
 buffer[1041] = 8'h00;
 buffer[1042] = 8'h78;
 buffer[1043] = 8'hcc;
 buffer[1044] = 8'hfc;
 buffer[1045] = 8'hc0;
 buffer[1046] = 8'h78;
 buffer[1047] = 8'h00;
 buffer[1048] = 8'h7e;
 buffer[1049] = 8'hc3;
 buffer[1050] = 8'h3c;
 buffer[1051] = 8'h06;
 buffer[1052] = 8'h3e;
 buffer[1053] = 8'h66;
 buffer[1054] = 8'h3f;
 buffer[1055] = 8'h00;
 buffer[1056] = 8'hcc;
 buffer[1057] = 8'h00;
 buffer[1058] = 8'h78;
 buffer[1059] = 8'h0c;
 buffer[1060] = 8'h7c;
 buffer[1061] = 8'hcc;
 buffer[1062] = 8'h7e;
 buffer[1063] = 8'h00;
 buffer[1064] = 8'he0;
 buffer[1065] = 8'h00;
 buffer[1066] = 8'h78;
 buffer[1067] = 8'h0c;
 buffer[1068] = 8'h7c;
 buffer[1069] = 8'hcc;
 buffer[1070] = 8'h7e;
 buffer[1071] = 8'h00;
 buffer[1072] = 8'h30;
 buffer[1073] = 8'h30;
 buffer[1074] = 8'h78;
 buffer[1075] = 8'h0c;
 buffer[1076] = 8'h7c;
 buffer[1077] = 8'hcc;
 buffer[1078] = 8'h7e;
 buffer[1079] = 8'h00;
 buffer[1080] = 8'h00;
 buffer[1081] = 8'h00;
 buffer[1082] = 8'h78;
 buffer[1083] = 8'hc0;
 buffer[1084] = 8'hc0;
 buffer[1085] = 8'h78;
 buffer[1086] = 8'h0c;
 buffer[1087] = 8'h38;
 buffer[1088] = 8'h7e;
 buffer[1089] = 8'hc3;
 buffer[1090] = 8'h3c;
 buffer[1091] = 8'h66;
 buffer[1092] = 8'h7e;
 buffer[1093] = 8'h60;
 buffer[1094] = 8'h3c;
 buffer[1095] = 8'h00;
 buffer[1096] = 8'hcc;
 buffer[1097] = 8'h00;
 buffer[1098] = 8'h78;
 buffer[1099] = 8'hcc;
 buffer[1100] = 8'hfc;
 buffer[1101] = 8'hc0;
 buffer[1102] = 8'h78;
 buffer[1103] = 8'h00;
 buffer[1104] = 8'he0;
 buffer[1105] = 8'h00;
 buffer[1106] = 8'h78;
 buffer[1107] = 8'hcc;
 buffer[1108] = 8'hfc;
 buffer[1109] = 8'hc0;
 buffer[1110] = 8'h78;
 buffer[1111] = 8'h00;
 buffer[1112] = 8'hcc;
 buffer[1113] = 8'h00;
 buffer[1114] = 8'h70;
 buffer[1115] = 8'h30;
 buffer[1116] = 8'h30;
 buffer[1117] = 8'h30;
 buffer[1118] = 8'h78;
 buffer[1119] = 8'h00;
 buffer[1120] = 8'h7c;
 buffer[1121] = 8'hc6;
 buffer[1122] = 8'h38;
 buffer[1123] = 8'h18;
 buffer[1124] = 8'h18;
 buffer[1125] = 8'h18;
 buffer[1126] = 8'h3c;
 buffer[1127] = 8'h00;
 buffer[1128] = 8'he0;
 buffer[1129] = 8'h00;
 buffer[1130] = 8'h70;
 buffer[1131] = 8'h30;
 buffer[1132] = 8'h30;
 buffer[1133] = 8'h30;
 buffer[1134] = 8'h78;
 buffer[1135] = 8'h00;
 buffer[1136] = 8'hc6;
 buffer[1137] = 8'h38;
 buffer[1138] = 8'h6c;
 buffer[1139] = 8'hc6;
 buffer[1140] = 8'hfe;
 buffer[1141] = 8'hc6;
 buffer[1142] = 8'hc6;
 buffer[1143] = 8'h00;
 buffer[1144] = 8'h30;
 buffer[1145] = 8'h30;
 buffer[1146] = 8'h00;
 buffer[1147] = 8'h78;
 buffer[1148] = 8'hcc;
 buffer[1149] = 8'hfc;
 buffer[1150] = 8'hcc;
 buffer[1151] = 8'h00;
 buffer[1152] = 8'h1c;
 buffer[1153] = 8'h00;
 buffer[1154] = 8'hfc;
 buffer[1155] = 8'h60;
 buffer[1156] = 8'h78;
 buffer[1157] = 8'h60;
 buffer[1158] = 8'hfc;
 buffer[1159] = 8'h00;
 buffer[1160] = 8'h00;
 buffer[1161] = 8'h00;
 buffer[1162] = 8'h7f;
 buffer[1163] = 8'h0c;
 buffer[1164] = 8'h7f;
 buffer[1165] = 8'hcc;
 buffer[1166] = 8'h7f;
 buffer[1167] = 8'h00;
 buffer[1168] = 8'h3e;
 buffer[1169] = 8'h6c;
 buffer[1170] = 8'hcc;
 buffer[1171] = 8'hfe;
 buffer[1172] = 8'hcc;
 buffer[1173] = 8'hcc;
 buffer[1174] = 8'hce;
 buffer[1175] = 8'h00;
 buffer[1176] = 8'h78;
 buffer[1177] = 8'hcc;
 buffer[1178] = 8'h00;
 buffer[1179] = 8'h78;
 buffer[1180] = 8'hcc;
 buffer[1181] = 8'hcc;
 buffer[1182] = 8'h78;
 buffer[1183] = 8'h00;
 buffer[1184] = 8'h00;
 buffer[1185] = 8'hcc;
 buffer[1186] = 8'h00;
 buffer[1187] = 8'h78;
 buffer[1188] = 8'hcc;
 buffer[1189] = 8'hcc;
 buffer[1190] = 8'h78;
 buffer[1191] = 8'h00;
 buffer[1192] = 8'h00;
 buffer[1193] = 8'he0;
 buffer[1194] = 8'h00;
 buffer[1195] = 8'h78;
 buffer[1196] = 8'hcc;
 buffer[1197] = 8'hcc;
 buffer[1198] = 8'h78;
 buffer[1199] = 8'h00;
 buffer[1200] = 8'h78;
 buffer[1201] = 8'hcc;
 buffer[1202] = 8'h00;
 buffer[1203] = 8'hcc;
 buffer[1204] = 8'hcc;
 buffer[1205] = 8'hcc;
 buffer[1206] = 8'h7e;
 buffer[1207] = 8'h00;
 buffer[1208] = 8'h00;
 buffer[1209] = 8'he0;
 buffer[1210] = 8'h00;
 buffer[1211] = 8'hcc;
 buffer[1212] = 8'hcc;
 buffer[1213] = 8'hcc;
 buffer[1214] = 8'h7e;
 buffer[1215] = 8'h00;
 buffer[1216] = 8'h00;
 buffer[1217] = 8'hcc;
 buffer[1218] = 8'h00;
 buffer[1219] = 8'hcc;
 buffer[1220] = 8'hcc;
 buffer[1221] = 8'h7c;
 buffer[1222] = 8'h0c;
 buffer[1223] = 8'hf8;
 buffer[1224] = 8'hc3;
 buffer[1225] = 8'h18;
 buffer[1226] = 8'h3c;
 buffer[1227] = 8'h66;
 buffer[1228] = 8'h66;
 buffer[1229] = 8'h3c;
 buffer[1230] = 8'h18;
 buffer[1231] = 8'h00;
 buffer[1232] = 8'hcc;
 buffer[1233] = 8'h00;
 buffer[1234] = 8'hcc;
 buffer[1235] = 8'hcc;
 buffer[1236] = 8'hcc;
 buffer[1237] = 8'hcc;
 buffer[1238] = 8'h78;
 buffer[1239] = 8'h00;
 buffer[1240] = 8'h18;
 buffer[1241] = 8'h18;
 buffer[1242] = 8'h7e;
 buffer[1243] = 8'hc0;
 buffer[1244] = 8'hc0;
 buffer[1245] = 8'h7e;
 buffer[1246] = 8'h18;
 buffer[1247] = 8'h18;
 buffer[1248] = 8'h38;
 buffer[1249] = 8'h6c;
 buffer[1250] = 8'h64;
 buffer[1251] = 8'hf0;
 buffer[1252] = 8'h60;
 buffer[1253] = 8'he6;
 buffer[1254] = 8'hfc;
 buffer[1255] = 8'h00;
 buffer[1256] = 8'hcc;
 buffer[1257] = 8'hcc;
 buffer[1258] = 8'h78;
 buffer[1259] = 8'hfc;
 buffer[1260] = 8'h30;
 buffer[1261] = 8'hfc;
 buffer[1262] = 8'h30;
 buffer[1263] = 8'h30;
 buffer[1264] = 8'hf8;
 buffer[1265] = 8'hcc;
 buffer[1266] = 8'hcc;
 buffer[1267] = 8'hfa;
 buffer[1268] = 8'hc6;
 buffer[1269] = 8'hcf;
 buffer[1270] = 8'hc6;
 buffer[1271] = 8'hc7;
 buffer[1272] = 8'h0e;
 buffer[1273] = 8'h1b;
 buffer[1274] = 8'h18;
 buffer[1275] = 8'h3c;
 buffer[1276] = 8'h18;
 buffer[1277] = 8'h18;
 buffer[1278] = 8'hd8;
 buffer[1279] = 8'h70;
 buffer[1280] = 8'h1c;
 buffer[1281] = 8'h00;
 buffer[1282] = 8'h78;
 buffer[1283] = 8'h0c;
 buffer[1284] = 8'h7c;
 buffer[1285] = 8'hcc;
 buffer[1286] = 8'h7e;
 buffer[1287] = 8'h00;
 buffer[1288] = 8'h38;
 buffer[1289] = 8'h00;
 buffer[1290] = 8'h70;
 buffer[1291] = 8'h30;
 buffer[1292] = 8'h30;
 buffer[1293] = 8'h30;
 buffer[1294] = 8'h78;
 buffer[1295] = 8'h00;
 buffer[1296] = 8'h00;
 buffer[1297] = 8'h1c;
 buffer[1298] = 8'h00;
 buffer[1299] = 8'h78;
 buffer[1300] = 8'hcc;
 buffer[1301] = 8'hcc;
 buffer[1302] = 8'h78;
 buffer[1303] = 8'h00;
 buffer[1304] = 8'h00;
 buffer[1305] = 8'h1c;
 buffer[1306] = 8'h00;
 buffer[1307] = 8'hcc;
 buffer[1308] = 8'hcc;
 buffer[1309] = 8'hcc;
 buffer[1310] = 8'h7e;
 buffer[1311] = 8'h00;
 buffer[1312] = 8'h00;
 buffer[1313] = 8'hf8;
 buffer[1314] = 8'h00;
 buffer[1315] = 8'hf8;
 buffer[1316] = 8'hcc;
 buffer[1317] = 8'hcc;
 buffer[1318] = 8'hcc;
 buffer[1319] = 8'h00;
 buffer[1320] = 8'hfc;
 buffer[1321] = 8'h00;
 buffer[1322] = 8'hcc;
 buffer[1323] = 8'hec;
 buffer[1324] = 8'hfc;
 buffer[1325] = 8'hdc;
 buffer[1326] = 8'hcc;
 buffer[1327] = 8'h00;
 buffer[1328] = 8'h3c;
 buffer[1329] = 8'h6c;
 buffer[1330] = 8'h6c;
 buffer[1331] = 8'h3e;
 buffer[1332] = 8'h00;
 buffer[1333] = 8'h7e;
 buffer[1334] = 8'h00;
 buffer[1335] = 8'h00;
 buffer[1336] = 8'h38;
 buffer[1337] = 8'h6c;
 buffer[1338] = 8'h6c;
 buffer[1339] = 8'h38;
 buffer[1340] = 8'h00;
 buffer[1341] = 8'h7c;
 buffer[1342] = 8'h00;
 buffer[1343] = 8'h00;
 buffer[1344] = 8'h30;
 buffer[1345] = 8'h00;
 buffer[1346] = 8'h30;
 buffer[1347] = 8'h60;
 buffer[1348] = 8'hc0;
 buffer[1349] = 8'hcc;
 buffer[1350] = 8'h78;
 buffer[1351] = 8'h00;
 buffer[1352] = 8'h00;
 buffer[1353] = 8'h00;
 buffer[1354] = 8'h00;
 buffer[1355] = 8'hfc;
 buffer[1356] = 8'hc0;
 buffer[1357] = 8'hc0;
 buffer[1358] = 8'h00;
 buffer[1359] = 8'h00;
 buffer[1360] = 8'h00;
 buffer[1361] = 8'h00;
 buffer[1362] = 8'h00;
 buffer[1363] = 8'hfc;
 buffer[1364] = 8'h0c;
 buffer[1365] = 8'h0c;
 buffer[1366] = 8'h00;
 buffer[1367] = 8'h00;
 buffer[1368] = 8'hc3;
 buffer[1369] = 8'hc6;
 buffer[1370] = 8'hcc;
 buffer[1371] = 8'hde;
 buffer[1372] = 8'h33;
 buffer[1373] = 8'h66;
 buffer[1374] = 8'hcc;
 buffer[1375] = 8'h0f;
 buffer[1376] = 8'hc3;
 buffer[1377] = 8'hc6;
 buffer[1378] = 8'hcc;
 buffer[1379] = 8'hdb;
 buffer[1380] = 8'h37;
 buffer[1381] = 8'h6f;
 buffer[1382] = 8'hcf;
 buffer[1383] = 8'h03;
 buffer[1384] = 8'h18;
 buffer[1385] = 8'h18;
 buffer[1386] = 8'h00;
 buffer[1387] = 8'h18;
 buffer[1388] = 8'h18;
 buffer[1389] = 8'h18;
 buffer[1390] = 8'h18;
 buffer[1391] = 8'h00;
 buffer[1392] = 8'h00;
 buffer[1393] = 8'h33;
 buffer[1394] = 8'h66;
 buffer[1395] = 8'hcc;
 buffer[1396] = 8'h66;
 buffer[1397] = 8'h33;
 buffer[1398] = 8'h00;
 buffer[1399] = 8'h00;
 buffer[1400] = 8'h00;
 buffer[1401] = 8'hcc;
 buffer[1402] = 8'h66;
 buffer[1403] = 8'h33;
 buffer[1404] = 8'h66;
 buffer[1405] = 8'hcc;
 buffer[1406] = 8'h00;
 buffer[1407] = 8'h00;
 buffer[1408] = 8'h22;
 buffer[1409] = 8'h88;
 buffer[1410] = 8'h22;
 buffer[1411] = 8'h88;
 buffer[1412] = 8'h22;
 buffer[1413] = 8'h88;
 buffer[1414] = 8'h22;
 buffer[1415] = 8'h88;
 buffer[1416] = 8'h55;
 buffer[1417] = 8'haa;
 buffer[1418] = 8'h55;
 buffer[1419] = 8'haa;
 buffer[1420] = 8'h55;
 buffer[1421] = 8'haa;
 buffer[1422] = 8'h55;
 buffer[1423] = 8'haa;
 buffer[1424] = 8'hdb;
 buffer[1425] = 8'h77;
 buffer[1426] = 8'hdb;
 buffer[1427] = 8'hee;
 buffer[1428] = 8'hdb;
 buffer[1429] = 8'h77;
 buffer[1430] = 8'hdb;
 buffer[1431] = 8'hee;
 buffer[1432] = 8'h18;
 buffer[1433] = 8'h18;
 buffer[1434] = 8'h18;
 buffer[1435] = 8'h18;
 buffer[1436] = 8'h18;
 buffer[1437] = 8'h18;
 buffer[1438] = 8'h18;
 buffer[1439] = 8'h18;
 buffer[1440] = 8'h18;
 buffer[1441] = 8'h18;
 buffer[1442] = 8'h18;
 buffer[1443] = 8'h18;
 buffer[1444] = 8'hf8;
 buffer[1445] = 8'h18;
 buffer[1446] = 8'h18;
 buffer[1447] = 8'h18;
 buffer[1448] = 8'h18;
 buffer[1449] = 8'h18;
 buffer[1450] = 8'hf8;
 buffer[1451] = 8'h18;
 buffer[1452] = 8'hf8;
 buffer[1453] = 8'h18;
 buffer[1454] = 8'h18;
 buffer[1455] = 8'h18;
 buffer[1456] = 8'h36;
 buffer[1457] = 8'h36;
 buffer[1458] = 8'h36;
 buffer[1459] = 8'h36;
 buffer[1460] = 8'hf6;
 buffer[1461] = 8'h36;
 buffer[1462] = 8'h36;
 buffer[1463] = 8'h36;
 buffer[1464] = 8'h00;
 buffer[1465] = 8'h00;
 buffer[1466] = 8'h00;
 buffer[1467] = 8'h00;
 buffer[1468] = 8'hfe;
 buffer[1469] = 8'h36;
 buffer[1470] = 8'h36;
 buffer[1471] = 8'h36;
 buffer[1472] = 8'h00;
 buffer[1473] = 8'h00;
 buffer[1474] = 8'hf8;
 buffer[1475] = 8'h18;
 buffer[1476] = 8'hf8;
 buffer[1477] = 8'h18;
 buffer[1478] = 8'h18;
 buffer[1479] = 8'h18;
 buffer[1480] = 8'h36;
 buffer[1481] = 8'h36;
 buffer[1482] = 8'hf6;
 buffer[1483] = 8'h06;
 buffer[1484] = 8'hf6;
 buffer[1485] = 8'h36;
 buffer[1486] = 8'h36;
 buffer[1487] = 8'h36;
 buffer[1488] = 8'h36;
 buffer[1489] = 8'h36;
 buffer[1490] = 8'h36;
 buffer[1491] = 8'h36;
 buffer[1492] = 8'h36;
 buffer[1493] = 8'h36;
 buffer[1494] = 8'h36;
 buffer[1495] = 8'h36;
 buffer[1496] = 8'h00;
 buffer[1497] = 8'h00;
 buffer[1498] = 8'hfe;
 buffer[1499] = 8'h06;
 buffer[1500] = 8'hf6;
 buffer[1501] = 8'h36;
 buffer[1502] = 8'h36;
 buffer[1503] = 8'h36;
 buffer[1504] = 8'h36;
 buffer[1505] = 8'h36;
 buffer[1506] = 8'hf6;
 buffer[1507] = 8'h06;
 buffer[1508] = 8'hfe;
 buffer[1509] = 8'h00;
 buffer[1510] = 8'h00;
 buffer[1511] = 8'h00;
 buffer[1512] = 8'h36;
 buffer[1513] = 8'h36;
 buffer[1514] = 8'h36;
 buffer[1515] = 8'h36;
 buffer[1516] = 8'hfe;
 buffer[1517] = 8'h00;
 buffer[1518] = 8'h00;
 buffer[1519] = 8'h00;
 buffer[1520] = 8'h18;
 buffer[1521] = 8'h18;
 buffer[1522] = 8'hf8;
 buffer[1523] = 8'h18;
 buffer[1524] = 8'hf8;
 buffer[1525] = 8'h00;
 buffer[1526] = 8'h00;
 buffer[1527] = 8'h00;
 buffer[1528] = 8'h00;
 buffer[1529] = 8'h00;
 buffer[1530] = 8'h00;
 buffer[1531] = 8'h00;
 buffer[1532] = 8'hf8;
 buffer[1533] = 8'h18;
 buffer[1534] = 8'h18;
 buffer[1535] = 8'h18;
 buffer[1536] = 8'h18;
 buffer[1537] = 8'h18;
 buffer[1538] = 8'h18;
 buffer[1539] = 8'h18;
 buffer[1540] = 8'h1f;
 buffer[1541] = 8'h00;
 buffer[1542] = 8'h00;
 buffer[1543] = 8'h00;
 buffer[1544] = 8'h18;
 buffer[1545] = 8'h18;
 buffer[1546] = 8'h18;
 buffer[1547] = 8'h18;
 buffer[1548] = 8'hff;
 buffer[1549] = 8'h00;
 buffer[1550] = 8'h00;
 buffer[1551] = 8'h00;
 buffer[1552] = 8'h00;
 buffer[1553] = 8'h00;
 buffer[1554] = 8'h00;
 buffer[1555] = 8'h00;
 buffer[1556] = 8'hff;
 buffer[1557] = 8'h18;
 buffer[1558] = 8'h18;
 buffer[1559] = 8'h18;
 buffer[1560] = 8'h18;
 buffer[1561] = 8'h18;
 buffer[1562] = 8'h18;
 buffer[1563] = 8'h18;
 buffer[1564] = 8'h1f;
 buffer[1565] = 8'h18;
 buffer[1566] = 8'h18;
 buffer[1567] = 8'h18;
 buffer[1568] = 8'h00;
 buffer[1569] = 8'h00;
 buffer[1570] = 8'h00;
 buffer[1571] = 8'h00;
 buffer[1572] = 8'hff;
 buffer[1573] = 8'h00;
 buffer[1574] = 8'h00;
 buffer[1575] = 8'h00;
 buffer[1576] = 8'h18;
 buffer[1577] = 8'h18;
 buffer[1578] = 8'h18;
 buffer[1579] = 8'h18;
 buffer[1580] = 8'hff;
 buffer[1581] = 8'h18;
 buffer[1582] = 8'h18;
 buffer[1583] = 8'h18;
 buffer[1584] = 8'h18;
 buffer[1585] = 8'h18;
 buffer[1586] = 8'h1f;
 buffer[1587] = 8'h18;
 buffer[1588] = 8'h1f;
 buffer[1589] = 8'h18;
 buffer[1590] = 8'h18;
 buffer[1591] = 8'h18;
 buffer[1592] = 8'h36;
 buffer[1593] = 8'h36;
 buffer[1594] = 8'h36;
 buffer[1595] = 8'h36;
 buffer[1596] = 8'h37;
 buffer[1597] = 8'h36;
 buffer[1598] = 8'h36;
 buffer[1599] = 8'h36;
 buffer[1600] = 8'h36;
 buffer[1601] = 8'h36;
 buffer[1602] = 8'h37;
 buffer[1603] = 8'h30;
 buffer[1604] = 8'h3f;
 buffer[1605] = 8'h00;
 buffer[1606] = 8'h00;
 buffer[1607] = 8'h00;
 buffer[1608] = 8'h00;
 buffer[1609] = 8'h00;
 buffer[1610] = 8'h3f;
 buffer[1611] = 8'h30;
 buffer[1612] = 8'h37;
 buffer[1613] = 8'h36;
 buffer[1614] = 8'h36;
 buffer[1615] = 8'h36;
 buffer[1616] = 8'h36;
 buffer[1617] = 8'h36;
 buffer[1618] = 8'hf7;
 buffer[1619] = 8'h00;
 buffer[1620] = 8'hff;
 buffer[1621] = 8'h00;
 buffer[1622] = 8'h00;
 buffer[1623] = 8'h00;
 buffer[1624] = 8'h00;
 buffer[1625] = 8'h00;
 buffer[1626] = 8'hff;
 buffer[1627] = 8'h00;
 buffer[1628] = 8'hf7;
 buffer[1629] = 8'h36;
 buffer[1630] = 8'h36;
 buffer[1631] = 8'h36;
 buffer[1632] = 8'h36;
 buffer[1633] = 8'h36;
 buffer[1634] = 8'h37;
 buffer[1635] = 8'h30;
 buffer[1636] = 8'h37;
 buffer[1637] = 8'h36;
 buffer[1638] = 8'h36;
 buffer[1639] = 8'h36;
 buffer[1640] = 8'h00;
 buffer[1641] = 8'h00;
 buffer[1642] = 8'hff;
 buffer[1643] = 8'h00;
 buffer[1644] = 8'hff;
 buffer[1645] = 8'h00;
 buffer[1646] = 8'h00;
 buffer[1647] = 8'h00;
 buffer[1648] = 8'h36;
 buffer[1649] = 8'h36;
 buffer[1650] = 8'hf7;
 buffer[1651] = 8'h00;
 buffer[1652] = 8'hf7;
 buffer[1653] = 8'h36;
 buffer[1654] = 8'h36;
 buffer[1655] = 8'h36;
 buffer[1656] = 8'h18;
 buffer[1657] = 8'h18;
 buffer[1658] = 8'hff;
 buffer[1659] = 8'h00;
 buffer[1660] = 8'hff;
 buffer[1661] = 8'h00;
 buffer[1662] = 8'h00;
 buffer[1663] = 8'h00;
 buffer[1664] = 8'h36;
 buffer[1665] = 8'h36;
 buffer[1666] = 8'h36;
 buffer[1667] = 8'h36;
 buffer[1668] = 8'hff;
 buffer[1669] = 8'h00;
 buffer[1670] = 8'h00;
 buffer[1671] = 8'h00;
 buffer[1672] = 8'h00;
 buffer[1673] = 8'h00;
 buffer[1674] = 8'hff;
 buffer[1675] = 8'h00;
 buffer[1676] = 8'hff;
 buffer[1677] = 8'h18;
 buffer[1678] = 8'h18;
 buffer[1679] = 8'h18;
 buffer[1680] = 8'h00;
 buffer[1681] = 8'h00;
 buffer[1682] = 8'h00;
 buffer[1683] = 8'h00;
 buffer[1684] = 8'hff;
 buffer[1685] = 8'h36;
 buffer[1686] = 8'h36;
 buffer[1687] = 8'h36;
 buffer[1688] = 8'h36;
 buffer[1689] = 8'h36;
 buffer[1690] = 8'h36;
 buffer[1691] = 8'h36;
 buffer[1692] = 8'h3f;
 buffer[1693] = 8'h00;
 buffer[1694] = 8'h00;
 buffer[1695] = 8'h00;
 buffer[1696] = 8'h18;
 buffer[1697] = 8'h18;
 buffer[1698] = 8'h1f;
 buffer[1699] = 8'h18;
 buffer[1700] = 8'h1f;
 buffer[1701] = 8'h00;
 buffer[1702] = 8'h00;
 buffer[1703] = 8'h00;
 buffer[1704] = 8'h00;
 buffer[1705] = 8'h00;
 buffer[1706] = 8'h1f;
 buffer[1707] = 8'h18;
 buffer[1708] = 8'h1f;
 buffer[1709] = 8'h18;
 buffer[1710] = 8'h18;
 buffer[1711] = 8'h18;
 buffer[1712] = 8'h00;
 buffer[1713] = 8'h00;
 buffer[1714] = 8'h00;
 buffer[1715] = 8'h00;
 buffer[1716] = 8'h3f;
 buffer[1717] = 8'h36;
 buffer[1718] = 8'h36;
 buffer[1719] = 8'h36;
 buffer[1720] = 8'h36;
 buffer[1721] = 8'h36;
 buffer[1722] = 8'h36;
 buffer[1723] = 8'h36;
 buffer[1724] = 8'hff;
 buffer[1725] = 8'h36;
 buffer[1726] = 8'h36;
 buffer[1727] = 8'h36;
 buffer[1728] = 8'h18;
 buffer[1729] = 8'h18;
 buffer[1730] = 8'hff;
 buffer[1731] = 8'h18;
 buffer[1732] = 8'hff;
 buffer[1733] = 8'h18;
 buffer[1734] = 8'h18;
 buffer[1735] = 8'h18;
 buffer[1736] = 8'h18;
 buffer[1737] = 8'h18;
 buffer[1738] = 8'h18;
 buffer[1739] = 8'h18;
 buffer[1740] = 8'hf8;
 buffer[1741] = 8'h00;
 buffer[1742] = 8'h00;
 buffer[1743] = 8'h00;
 buffer[1744] = 8'h00;
 buffer[1745] = 8'h00;
 buffer[1746] = 8'h00;
 buffer[1747] = 8'h00;
 buffer[1748] = 8'h1f;
 buffer[1749] = 8'h18;
 buffer[1750] = 8'h18;
 buffer[1751] = 8'h18;
 buffer[1752] = 8'hff;
 buffer[1753] = 8'hff;
 buffer[1754] = 8'hff;
 buffer[1755] = 8'hff;
 buffer[1756] = 8'hff;
 buffer[1757] = 8'hff;
 buffer[1758] = 8'hff;
 buffer[1759] = 8'hff;
 buffer[1760] = 8'h00;
 buffer[1761] = 8'h00;
 buffer[1762] = 8'h00;
 buffer[1763] = 8'h00;
 buffer[1764] = 8'hff;
 buffer[1765] = 8'hff;
 buffer[1766] = 8'hff;
 buffer[1767] = 8'hff;
 buffer[1768] = 8'hf0;
 buffer[1769] = 8'hf0;
 buffer[1770] = 8'hf0;
 buffer[1771] = 8'hf0;
 buffer[1772] = 8'hf0;
 buffer[1773] = 8'hf0;
 buffer[1774] = 8'hf0;
 buffer[1775] = 8'hf0;
 buffer[1776] = 8'h0f;
 buffer[1777] = 8'h0f;
 buffer[1778] = 8'h0f;
 buffer[1779] = 8'h0f;
 buffer[1780] = 8'h0f;
 buffer[1781] = 8'h0f;
 buffer[1782] = 8'h0f;
 buffer[1783] = 8'h0f;
 buffer[1784] = 8'hff;
 buffer[1785] = 8'hff;
 buffer[1786] = 8'hff;
 buffer[1787] = 8'hff;
 buffer[1788] = 8'h00;
 buffer[1789] = 8'h00;
 buffer[1790] = 8'h00;
 buffer[1791] = 8'h00;
 buffer[1792] = 8'h00;
 buffer[1793] = 8'h00;
 buffer[1794] = 8'h76;
 buffer[1795] = 8'hdc;
 buffer[1796] = 8'hc8;
 buffer[1797] = 8'hdc;
 buffer[1798] = 8'h76;
 buffer[1799] = 8'h00;
 buffer[1800] = 8'h00;
 buffer[1801] = 8'h78;
 buffer[1802] = 8'hcc;
 buffer[1803] = 8'hf8;
 buffer[1804] = 8'hcc;
 buffer[1805] = 8'hf8;
 buffer[1806] = 8'hc0;
 buffer[1807] = 8'hc0;
 buffer[1808] = 8'h00;
 buffer[1809] = 8'hfc;
 buffer[1810] = 8'hcc;
 buffer[1811] = 8'hc0;
 buffer[1812] = 8'hc0;
 buffer[1813] = 8'hc0;
 buffer[1814] = 8'hc0;
 buffer[1815] = 8'h00;
 buffer[1816] = 8'h00;
 buffer[1817] = 8'hfe;
 buffer[1818] = 8'h6c;
 buffer[1819] = 8'h6c;
 buffer[1820] = 8'h6c;
 buffer[1821] = 8'h6c;
 buffer[1822] = 8'h6c;
 buffer[1823] = 8'h00;
 buffer[1824] = 8'hfc;
 buffer[1825] = 8'hcc;
 buffer[1826] = 8'h60;
 buffer[1827] = 8'h30;
 buffer[1828] = 8'h60;
 buffer[1829] = 8'hcc;
 buffer[1830] = 8'hfc;
 buffer[1831] = 8'h00;
 buffer[1832] = 8'h00;
 buffer[1833] = 8'h00;
 buffer[1834] = 8'h7e;
 buffer[1835] = 8'hd8;
 buffer[1836] = 8'hd8;
 buffer[1837] = 8'hd8;
 buffer[1838] = 8'h70;
 buffer[1839] = 8'h00;
 buffer[1840] = 8'h00;
 buffer[1841] = 8'h66;
 buffer[1842] = 8'h66;
 buffer[1843] = 8'h66;
 buffer[1844] = 8'h66;
 buffer[1845] = 8'h7c;
 buffer[1846] = 8'h60;
 buffer[1847] = 8'hc0;
 buffer[1848] = 8'h00;
 buffer[1849] = 8'h76;
 buffer[1850] = 8'hdc;
 buffer[1851] = 8'h18;
 buffer[1852] = 8'h18;
 buffer[1853] = 8'h18;
 buffer[1854] = 8'h18;
 buffer[1855] = 8'h00;
 buffer[1856] = 8'hfc;
 buffer[1857] = 8'h30;
 buffer[1858] = 8'h78;
 buffer[1859] = 8'hcc;
 buffer[1860] = 8'hcc;
 buffer[1861] = 8'h78;
 buffer[1862] = 8'h30;
 buffer[1863] = 8'hfc;
 buffer[1864] = 8'h38;
 buffer[1865] = 8'h6c;
 buffer[1866] = 8'hc6;
 buffer[1867] = 8'hfe;
 buffer[1868] = 8'hc6;
 buffer[1869] = 8'h6c;
 buffer[1870] = 8'h38;
 buffer[1871] = 8'h00;
 buffer[1872] = 8'h38;
 buffer[1873] = 8'h6c;
 buffer[1874] = 8'hc6;
 buffer[1875] = 8'hc6;
 buffer[1876] = 8'h6c;
 buffer[1877] = 8'h6c;
 buffer[1878] = 8'hee;
 buffer[1879] = 8'h00;
 buffer[1880] = 8'h1c;
 buffer[1881] = 8'h30;
 buffer[1882] = 8'h18;
 buffer[1883] = 8'h7c;
 buffer[1884] = 8'hcc;
 buffer[1885] = 8'hcc;
 buffer[1886] = 8'h78;
 buffer[1887] = 8'h00;
 buffer[1888] = 8'h00;
 buffer[1889] = 8'h00;
 buffer[1890] = 8'h7e;
 buffer[1891] = 8'hdb;
 buffer[1892] = 8'hdb;
 buffer[1893] = 8'h7e;
 buffer[1894] = 8'h00;
 buffer[1895] = 8'h00;
 buffer[1896] = 8'h06;
 buffer[1897] = 8'h0c;
 buffer[1898] = 8'h7e;
 buffer[1899] = 8'hdb;
 buffer[1900] = 8'hdb;
 buffer[1901] = 8'h7e;
 buffer[1902] = 8'h60;
 buffer[1903] = 8'hc0;
 buffer[1904] = 8'h38;
 buffer[1905] = 8'h60;
 buffer[1906] = 8'hc0;
 buffer[1907] = 8'hf8;
 buffer[1908] = 8'hc0;
 buffer[1909] = 8'h60;
 buffer[1910] = 8'h38;
 buffer[1911] = 8'h00;
 buffer[1912] = 8'h78;
 buffer[1913] = 8'hcc;
 buffer[1914] = 8'hcc;
 buffer[1915] = 8'hcc;
 buffer[1916] = 8'hcc;
 buffer[1917] = 8'hcc;
 buffer[1918] = 8'hcc;
 buffer[1919] = 8'h00;
 buffer[1920] = 8'h00;
 buffer[1921] = 8'hfc;
 buffer[1922] = 8'h00;
 buffer[1923] = 8'hfc;
 buffer[1924] = 8'h00;
 buffer[1925] = 8'hfc;
 buffer[1926] = 8'h00;
 buffer[1927] = 8'h00;
 buffer[1928] = 8'h30;
 buffer[1929] = 8'h30;
 buffer[1930] = 8'hfc;
 buffer[1931] = 8'h30;
 buffer[1932] = 8'h30;
 buffer[1933] = 8'h00;
 buffer[1934] = 8'hfc;
 buffer[1935] = 8'h00;
 buffer[1936] = 8'h60;
 buffer[1937] = 8'h30;
 buffer[1938] = 8'h18;
 buffer[1939] = 8'h30;
 buffer[1940] = 8'h60;
 buffer[1941] = 8'h00;
 buffer[1942] = 8'hfc;
 buffer[1943] = 8'h00;
 buffer[1944] = 8'h18;
 buffer[1945] = 8'h30;
 buffer[1946] = 8'h60;
 buffer[1947] = 8'h30;
 buffer[1948] = 8'h18;
 buffer[1949] = 8'h00;
 buffer[1950] = 8'hfc;
 buffer[1951] = 8'h00;
 buffer[1952] = 8'h0e;
 buffer[1953] = 8'h1b;
 buffer[1954] = 8'h1b;
 buffer[1955] = 8'h18;
 buffer[1956] = 8'h18;
 buffer[1957] = 8'h18;
 buffer[1958] = 8'h18;
 buffer[1959] = 8'h18;
 buffer[1960] = 8'h18;
 buffer[1961] = 8'h18;
 buffer[1962] = 8'h18;
 buffer[1963] = 8'h18;
 buffer[1964] = 8'h18;
 buffer[1965] = 8'hd8;
 buffer[1966] = 8'hd8;
 buffer[1967] = 8'h70;
 buffer[1968] = 8'h30;
 buffer[1969] = 8'h30;
 buffer[1970] = 8'h00;
 buffer[1971] = 8'hfc;
 buffer[1972] = 8'h00;
 buffer[1973] = 8'h30;
 buffer[1974] = 8'h30;
 buffer[1975] = 8'h00;
 buffer[1976] = 8'h00;
 buffer[1977] = 8'h76;
 buffer[1978] = 8'hdc;
 buffer[1979] = 8'h00;
 buffer[1980] = 8'h76;
 buffer[1981] = 8'hdc;
 buffer[1982] = 8'h00;
 buffer[1983] = 8'h00;
 buffer[1984] = 8'h38;
 buffer[1985] = 8'h6c;
 buffer[1986] = 8'h6c;
 buffer[1987] = 8'h38;
 buffer[1988] = 8'h00;
 buffer[1989] = 8'h00;
 buffer[1990] = 8'h00;
 buffer[1991] = 8'h00;
 buffer[1992] = 8'h00;
 buffer[1993] = 8'h00;
 buffer[1994] = 8'h00;
 buffer[1995] = 8'h18;
 buffer[1996] = 8'h18;
 buffer[1997] = 8'h00;
 buffer[1998] = 8'h00;
 buffer[1999] = 8'h00;
 buffer[2000] = 8'h00;
 buffer[2001] = 8'h00;
 buffer[2002] = 8'h00;
 buffer[2003] = 8'h00;
 buffer[2004] = 8'h18;
 buffer[2005] = 8'h00;
 buffer[2006] = 8'h00;
 buffer[2007] = 8'h00;
 buffer[2008] = 8'h0f;
 buffer[2009] = 8'h0c;
 buffer[2010] = 8'h0c;
 buffer[2011] = 8'h0c;
 buffer[2012] = 8'hec;
 buffer[2013] = 8'h6c;
 buffer[2014] = 8'h3c;
 buffer[2015] = 8'h1c;
 buffer[2016] = 8'h78;
 buffer[2017] = 8'h6c;
 buffer[2018] = 8'h6c;
 buffer[2019] = 8'h6c;
 buffer[2020] = 8'h6c;
 buffer[2021] = 8'h00;
 buffer[2022] = 8'h00;
 buffer[2023] = 8'h00;
 buffer[2024] = 8'h70;
 buffer[2025] = 8'h18;
 buffer[2026] = 8'h30;
 buffer[2027] = 8'h60;
 buffer[2028] = 8'h78;
 buffer[2029] = 8'h00;
 buffer[2030] = 8'h00;
 buffer[2031] = 8'h00;
 buffer[2032] = 8'h00;
 buffer[2033] = 8'h00;
 buffer[2034] = 8'h3c;
 buffer[2035] = 8'h3c;
 buffer[2036] = 8'h3c;
 buffer[2037] = 8'h3c;
 buffer[2038] = 8'h00;
 buffer[2039] = 8'h00;
 buffer[2040] = 8'h00;
 buffer[2041] = 8'h00;
 buffer[2042] = 8'h00;
 buffer[2043] = 8'h00;
 buffer[2044] = 8'h00;
 buffer[2045] = 8'h00;
 buffer[2046] = 8'h00;
 buffer[2047] = 8'h00;
end

endmodule

module M_gpu (
in_gpu_x,
in_gpu_y,
in_gpu_colour,
in_gpu_param0,
in_gpu_param1,
in_gpu_param2,
in_gpu_param3,
in_gpu_write,
in_blit1_writer_tile,
in_blit1_writer_line,
in_blit1_writer_bitmap,
in_vector_block_number,
in_vector_block_colour,
in_vector_block_xc,
in_vector_block_yc,
in_draw_vector,
in_vertices_writer_block,
in_vertices_writer_vertex,
in_vertices_writer_xdelta,
in_vertices_writer_ydelta,
in_vertices_writer_active,
out_bitmap_x_write,
out_bitmap_y_write,
out_bitmap_colour_write,
out_bitmap_write,
out_gpu_active,
out_vector_block_active,
in_run,
out_done,
reset,
out_clock,
clock
);
input signed [10:0] in_gpu_x;
input signed [10:0] in_gpu_y;
input  [7:0] in_gpu_colour;
input signed [10:0] in_gpu_param0;
input signed [10:0] in_gpu_param1;
input signed [10:0] in_gpu_param2;
input signed [10:0] in_gpu_param3;
input  [3:0] in_gpu_write;
input  [4:0] in_blit1_writer_tile;
input  [3:0] in_blit1_writer_line;
input  [15:0] in_blit1_writer_bitmap;
input  [4:0] in_vector_block_number;
input  [6:0] in_vector_block_colour;
input signed [10:0] in_vector_block_xc;
input signed [10:0] in_vector_block_yc;
input  [0:0] in_draw_vector;
input  [4:0] in_vertices_writer_block;
input  [5:0] in_vertices_writer_vertex;
input signed [5:0] in_vertices_writer_xdelta;
input signed [5:0] in_vertices_writer_ydelta;
input  [0:0] in_vertices_writer_active;
output signed [10:0] out_bitmap_x_write;
output signed [10:0] out_bitmap_y_write;
output  [6:0] out_bitmap_colour_write;
output  [0:0] out_bitmap_write;
output  [0:0] out_gpu_active;
output  [0:0] out_vector_block_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [0:0] _w_vector_drawer_vector_block_active;
wire signed [10:0] _w_vector_drawer_gpu_x;
wire signed [10:0] _w_vector_drawer_gpu_y;
wire signed [10:0] _w_vector_drawer_gpu_param0;
wire signed [10:0] _w_vector_drawer_gpu_param1;
wire  [0:0] _w_vector_drawer_gpu_write;
wire _w_vector_drawer_done;
wire  [10:0] _w_GPUrectangle_bitmap_x_write;
wire  [10:0] _w_GPUrectangle_bitmap_y_write;
wire  [0:0] _w_GPUrectangle_bitmap_write;
wire  [0:0] _w_GPUrectangle_busy;
wire _w_GPUrectangle_done;
wire  [10:0] _w_GPUline_bitmap_x_write;
wire  [10:0] _w_GPUline_bitmap_y_write;
wire  [0:0] _w_GPUline_bitmap_write;
wire  [0:0] _w_GPUline_busy;
wire _w_GPUline_done;
wire  [10:0] _w_GPUcircle_bitmap_x_write;
wire  [10:0] _w_GPUcircle_bitmap_y_write;
wire  [0:0] _w_GPUcircle_bitmap_write;
wire  [0:0] _w_GPUcircle_busy;
wire _w_GPUcircle_done;
wire  [10:0] _w_GPUdisc_bitmap_x_write;
wire  [10:0] _w_GPUdisc_bitmap_y_write;
wire  [0:0] _w_GPUdisc_bitmap_write;
wire  [0:0] _w_GPUdisc_busy;
wire _w_GPUdisc_done;
wire  [10:0] _w_GPUtriangle_bitmap_x_write;
wire  [10:0] _w_GPUtriangle_bitmap_y_write;
wire  [0:0] _w_GPUtriangle_bitmap_write;
wire  [0:0] _w_GPUtriangle_busy;
wire _w_GPUtriangle_done;
wire  [10:0] _w_GPUblit_bitmap_x_write;
wire  [10:0] _w_GPUblit_bitmap_y_write;
wire  [0:0] _w_GPUblit_bitmap_write;
wire  [0:0] _w_GPUblit_busy;
wire  [8:0] _w_GPUblit_blit1tilemap_addr0;
wire  [10:0] _w_GPUblit_characterGenerator8x8_addr0;
wire _w_GPUblit_done;
wire  [10:0] _w_VECTORline_bitmap_x_write;
wire  [10:0] _w_VECTORline_bitmap_y_write;
wire  [0:0] _w_VECTORline_bitmap_write;
wire  [0:0] _w_VECTORline_busy;
wire _w_VECTORline_done;
wire  [15:0] _w_mem_blit1tilemap_rdata0;
wire  [7:0] _w_mem_characterGenerator8x8_rdata0;

reg  [0:0] _d_blit1tilemap_wenable1;
reg  [0:0] _q_blit1tilemap_wenable1;
reg  [15:0] _d_blit1tilemap_wdata1;
reg  [15:0] _q_blit1tilemap_wdata1;
reg  [8:0] _d_blit1tilemap_addr1;
reg  [8:0] _q_blit1tilemap_addr1;
reg  [0:0] _d_characterGenerator8x8_wenable1;
reg  [0:0] _q_characterGenerator8x8_wenable1;
reg  [7:0] _d_characterGenerator8x8_wdata1;
reg  [7:0] _q_characterGenerator8x8_wdata1;
reg  [10:0] _d_characterGenerator8x8_addr1;
reg  [10:0] _q_characterGenerator8x8_addr1;
reg  [6:0] _d_gpu_active_colour;
reg  [6:0] _q_gpu_active_colour;
reg signed [10:0] _d_bitmap_x_write,_q_bitmap_x_write;
reg signed [10:0] _d_bitmap_y_write,_q_bitmap_y_write;
reg  [6:0] _d_bitmap_colour_write,_q_bitmap_colour_write;
reg  [0:0] _d_bitmap_write,_q_bitmap_write;
reg  [0:0] _d_gpu_active,_q_gpu_active;
reg  [0:0] _d_GPUrectangle_start,_q_GPUrectangle_start;
reg  [0:0] _d_GPUline_start,_q_GPUline_start;
reg  [0:0] _d_GPUcircle_start,_q_GPUcircle_start;
reg  [0:0] _d_GPUdisc_start,_q_GPUdisc_start;
reg  [0:0] _d_GPUtriangle_start,_q_GPUtriangle_start;
reg  [0:0] _d_GPUblit_start,_q_GPUblit_start;
reg  [0:0] _d_GPUblit_tilecharacter,_q_GPUblit_tilecharacter;
reg  [0:0] _d_VECTORline_start,_q_VECTORline_start;
reg  [4:0] _d_index,_q_index;
reg  _vector_drawer_run;
reg  _GPUrectangle_run;
reg  _GPUline_run;
reg  _GPUcircle_run;
reg  _GPUdisc_run;
reg  _GPUtriangle_run;
reg  _GPUblit_run;
reg  _VECTORline_run;
assign out_bitmap_x_write = _d_bitmap_x_write;
assign out_bitmap_y_write = _d_bitmap_y_write;
assign out_bitmap_colour_write = _d_bitmap_colour_write;
assign out_bitmap_write = _d_bitmap_write;
assign out_gpu_active = _q_gpu_active;
assign out_vector_block_active = _w_vector_drawer_vector_block_active;
assign out_done = (_q_index == 19);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_blit1tilemap_wenable1 <= 0;
_q_blit1tilemap_wdata1 <= 0;
_q_blit1tilemap_addr1 <= 0;
_q_characterGenerator8x8_wenable1 <= 0;
_q_characterGenerator8x8_wdata1 <= 0;
_q_characterGenerator8x8_addr1 <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_blit1tilemap_wenable1 <= _d_blit1tilemap_wenable1;
_q_blit1tilemap_wdata1 <= _d_blit1tilemap_wdata1;
_q_blit1tilemap_addr1 <= _d_blit1tilemap_addr1;
_q_characterGenerator8x8_wenable1 <= _d_characterGenerator8x8_wenable1;
_q_characterGenerator8x8_wdata1 <= _d_characterGenerator8x8_wdata1;
_q_characterGenerator8x8_addr1 <= _d_characterGenerator8x8_addr1;
_q_gpu_active_colour <= _d_gpu_active_colour;
_q_bitmap_x_write <= _d_bitmap_x_write;
_q_bitmap_y_write <= _d_bitmap_y_write;
_q_bitmap_colour_write <= _d_bitmap_colour_write;
_q_bitmap_write <= _d_bitmap_write;
_q_gpu_active <= _d_gpu_active;
_q_index <= _d_index;
  end
_q_GPUrectangle_start <= _d_GPUrectangle_start;
_q_GPUline_start <= _d_GPUline_start;
_q_GPUcircle_start <= _d_GPUcircle_start;
_q_GPUdisc_start <= _d_GPUdisc_start;
_q_GPUtriangle_start <= _d_GPUtriangle_start;
_q_GPUblit_start <= _d_GPUblit_start;
_q_GPUblit_tilecharacter <= _d_GPUblit_tilecharacter;
_q_VECTORline_start <= _d_VECTORline_start;
end

M_vectors vector_drawer (
.in_vector_block_number(in_vector_block_number),
.in_vector_block_xc(in_vector_block_xc),
.in_vector_block_yc(in_vector_block_yc),
.in_draw_vector(in_draw_vector),
.in_vertices_writer_block(in_vertices_writer_block),
.in_vertices_writer_vertex(in_vertices_writer_vertex),
.in_vertices_writer_xdelta(in_vertices_writer_xdelta),
.in_vertices_writer_ydelta(in_vertices_writer_ydelta),
.in_vertices_writer_active(in_vertices_writer_active),
.in_gpu_active(_d_gpu_active),
.out_vector_block_active(_w_vector_drawer_vector_block_active),
.out_gpu_x(_w_vector_drawer_gpu_x),
.out_gpu_y(_w_vector_drawer_gpu_y),
.out_gpu_param0(_w_vector_drawer_gpu_param0),
.out_gpu_param1(_w_vector_drawer_gpu_param1),
.out_gpu_write(_w_vector_drawer_gpu_write),
.out_done(_w_vector_drawer_done),
.in_run(_vector_drawer_run),
.reset(reset),
.clock(clock)
);
M_rectangle GPUrectangle (
.in_x(in_gpu_x),
.in_y(in_gpu_y),
.in_param0(in_gpu_param0),
.in_param1(in_gpu_param1),
.in_start(_d_GPUrectangle_start),
.out_bitmap_x_write(_w_GPUrectangle_bitmap_x_write),
.out_bitmap_y_write(_w_GPUrectangle_bitmap_y_write),
.out_bitmap_write(_w_GPUrectangle_bitmap_write),
.out_busy(_w_GPUrectangle_busy),
.out_done(_w_GPUrectangle_done),
.in_run(_GPUrectangle_run),
.reset(reset),
.clock(clock)
);
M_line GPUline (
.in_x(in_gpu_x),
.in_y(in_gpu_y),
.in_param0(in_gpu_param0),
.in_param1(in_gpu_param1),
.in_start(_d_GPUline_start),
.out_bitmap_x_write(_w_GPUline_bitmap_x_write),
.out_bitmap_y_write(_w_GPUline_bitmap_y_write),
.out_bitmap_write(_w_GPUline_bitmap_write),
.out_busy(_w_GPUline_busy),
.out_done(_w_GPUline_done),
.in_run(_GPUline_run),
.reset(reset),
.clock(clock)
);
M_circle GPUcircle (
.in_x(in_gpu_x),
.in_y(in_gpu_y),
.in_param0(in_gpu_param0),
.in_start(_d_GPUcircle_start),
.out_bitmap_x_write(_w_GPUcircle_bitmap_x_write),
.out_bitmap_y_write(_w_GPUcircle_bitmap_y_write),
.out_bitmap_write(_w_GPUcircle_bitmap_write),
.out_busy(_w_GPUcircle_busy),
.out_done(_w_GPUcircle_done),
.in_run(_GPUcircle_run),
.reset(reset),
.clock(clock)
);
M_disc GPUdisc (
.in_x(in_gpu_x),
.in_y(in_gpu_y),
.in_param0(in_gpu_param0),
.in_start(_d_GPUdisc_start),
.out_bitmap_x_write(_w_GPUdisc_bitmap_x_write),
.out_bitmap_y_write(_w_GPUdisc_bitmap_y_write),
.out_bitmap_write(_w_GPUdisc_bitmap_write),
.out_busy(_w_GPUdisc_busy),
.out_done(_w_GPUdisc_done),
.in_run(_GPUdisc_run),
.reset(reset),
.clock(clock)
);
M_triangle GPUtriangle (
.in_x(in_gpu_x),
.in_y(in_gpu_y),
.in_param0(in_gpu_param0),
.in_param1(in_gpu_param1),
.in_param2(in_gpu_param2),
.in_param3(in_gpu_param3),
.in_start(_d_GPUtriangle_start),
.out_bitmap_x_write(_w_GPUtriangle_bitmap_x_write),
.out_bitmap_y_write(_w_GPUtriangle_bitmap_y_write),
.out_bitmap_write(_w_GPUtriangle_bitmap_write),
.out_busy(_w_GPUtriangle_busy),
.out_done(_w_GPUtriangle_done),
.in_run(_GPUtriangle_run),
.reset(reset),
.clock(clock)
);
M_blit #(
.BLIT1TILEMAP_ADDR0_WIDTH(9),
.BLIT1TILEMAP_ADDR0_INIT(0),
.BLIT1TILEMAP_ADDR0_SIGNED(0),
.BLIT1TILEMAP_RDATA0_WIDTH(16),
.BLIT1TILEMAP_RDATA0_INIT(0),
.BLIT1TILEMAP_RDATA0_SIGNED(0),
.CHARACTERGENERATOR8X8_ADDR0_WIDTH(11),
.CHARACTERGENERATOR8X8_ADDR0_INIT(0),
.CHARACTERGENERATOR8X8_ADDR0_SIGNED(0),
.CHARACTERGENERATOR8X8_RDATA0_WIDTH(8),
.CHARACTERGENERATOR8X8_RDATA0_INIT(0),
.CHARACTERGENERATOR8X8_RDATA0_SIGNED(0)
) GPUblit (
.in_x(in_gpu_x),
.in_y(in_gpu_y),
.in_param0(in_gpu_param0),
.in_param1(in_gpu_param1),
.in_start(_d_GPUblit_start),
.in_tilecharacter(_d_GPUblit_tilecharacter),
.in_blit1tilemap_rdata0(_w_mem_blit1tilemap_rdata0),
.in_characterGenerator8x8_rdata0(_w_mem_characterGenerator8x8_rdata0),
.out_bitmap_x_write(_w_GPUblit_bitmap_x_write),
.out_bitmap_y_write(_w_GPUblit_bitmap_y_write),
.out_bitmap_write(_w_GPUblit_bitmap_write),
.out_busy(_w_GPUblit_busy),
.out_blit1tilemap_addr0(_w_GPUblit_blit1tilemap_addr0),
.out_characterGenerator8x8_addr0(_w_GPUblit_characterGenerator8x8_addr0),
.out_done(_w_GPUblit_done),
.in_run(_GPUblit_run),
.reset(reset),
.clock(clock)
);
M_line VECTORline (
.in_x(_w_vector_drawer_gpu_x),
.in_y(_w_vector_drawer_gpu_y),
.in_param0(_w_vector_drawer_gpu_param0),
.in_param1(_w_vector_drawer_gpu_param1),
.in_start(_d_VECTORline_start),
.out_bitmap_x_write(_w_VECTORline_bitmap_x_write),
.out_bitmap_y_write(_w_VECTORline_bitmap_y_write),
.out_bitmap_write(_w_VECTORline_bitmap_write),
.out_busy(_w_VECTORline_busy),
.out_done(_w_VECTORline_done),
.in_run(_VECTORline_run),
.reset(reset),
.clock(clock)
);

M_gpu_mem_blit1tilemap __mem__blit1tilemap(
.clock0(clock),
.clock1(clock),
.in_blit1tilemap_addr0(_w_GPUblit_blit1tilemap_addr0),
.in_blit1tilemap_wenable1(_d_blit1tilemap_wenable1),
.in_blit1tilemap_wdata1(_d_blit1tilemap_wdata1),
.in_blit1tilemap_addr1(_d_blit1tilemap_addr1),
.out_blit1tilemap_rdata0(_w_mem_blit1tilemap_rdata0)
);
M_gpu_mem_characterGenerator8x8 __mem__characterGenerator8x8(
.clock0(clock),
.clock1(clock),
.in_characterGenerator8x8_addr0(_w_GPUblit_characterGenerator8x8_addr0),
.in_characterGenerator8x8_wenable1(_d_characterGenerator8x8_wenable1),
.in_characterGenerator8x8_wdata1(_d_characterGenerator8x8_wdata1),
.in_characterGenerator8x8_addr1(_d_characterGenerator8x8_addr1),
.out_characterGenerator8x8_rdata0(_w_mem_characterGenerator8x8_rdata0)
);


always @* begin
_d_blit1tilemap_wenable1 = _q_blit1tilemap_wenable1;
_d_blit1tilemap_wdata1 = _q_blit1tilemap_wdata1;
_d_blit1tilemap_addr1 = _q_blit1tilemap_addr1;
_d_characterGenerator8x8_wenable1 = _q_characterGenerator8x8_wenable1;
_d_characterGenerator8x8_wdata1 = _q_characterGenerator8x8_wdata1;
_d_characterGenerator8x8_addr1 = _q_characterGenerator8x8_addr1;
_d_gpu_active_colour = _q_gpu_active_colour;
_d_bitmap_x_write = _q_bitmap_x_write;
_d_bitmap_y_write = _q_bitmap_y_write;
_d_bitmap_colour_write = _q_bitmap_colour_write;
_d_bitmap_write = _q_bitmap_write;
_d_gpu_active = _q_gpu_active;
_d_GPUrectangle_start = _q_GPUrectangle_start;
_d_GPUline_start = _q_GPUline_start;
_d_GPUcircle_start = _q_GPUcircle_start;
_d_GPUdisc_start = _q_GPUdisc_start;
_d_GPUtriangle_start = _q_GPUtriangle_start;
_d_GPUblit_start = _q_GPUblit_start;
_d_GPUblit_tilecharacter = _q_GPUblit_tilecharacter;
_d_VECTORline_start = _q_VECTORline_start;
_d_index = _q_index;
_vector_drawer_run = 1;
_GPUrectangle_run = 1;
_GPUline_run = 1;
_GPUcircle_run = 1;
_GPUdisc_run = 1;
_GPUtriangle_run = 1;
_GPUblit_run = 1;
_VECTORline_run = 1;
// _always_pre
_d_blit1tilemap_addr1 = in_blit1_writer_tile*16+in_blit1_writer_line;
_d_blit1tilemap_wdata1 = in_blit1_writer_bitmap;
_d_blit1tilemap_wenable1 = 1;
_d_bitmap_write = 0;
_d_bitmap_colour_write = _q_gpu_active_colour;
_d_GPUrectangle_start = 0;
_d_GPUline_start = 0;
_d_GPUcircle_start = 0;
_d_GPUdisc_start = 0;
_d_GPUtriangle_start = 0;
_d_GPUblit_start = 0;
_d_VECTORline_start = 0;
_d_index = 19;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_blit1tilemap_wenable1 = 0;
_d_blit1tilemap_wdata1 = 0;
_d_blit1tilemap_addr1 = 0;
_d_characterGenerator8x8_wenable1 = 0;
_d_characterGenerator8x8_wdata1 = 0;
_d_characterGenerator8x8_addr1 = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (_w_vector_drawer_gpu_write) begin
// __block_5
// __block_7
_d_gpu_active_colour = in_vector_block_colour;
_d_gpu_active = 1;
_d_VECTORline_start = 1;
_d_index = 3;
end else begin
// __block_6
// __block_14
_d_gpu_active_colour = in_gpu_colour;
  case (in_gpu_write)
  1: begin
// __block_16_case
// __block_17
_d_bitmap_x_write = in_gpu_x;
_d_bitmap_y_write = in_gpu_y;
_d_bitmap_write = 1;
// __block_18
_d_index = 1;
  end
  2: begin
// __block_19_case
// __block_20
_d_gpu_active = 1;
_d_GPUline_start = 1;
_d_index = 5;
  end
  3: begin
// __block_27_case
// __block_28
_d_gpu_active = 1;
_d_GPUrectangle_start = 1;
_d_index = 6;
  end
  4: begin
// __block_35_case
// __block_36
_d_gpu_active = 1;
_d_GPUcircle_start = 1;
_d_index = 7;
  end
  5: begin
// __block_43_case
// __block_44
_d_gpu_active = 1;
_d_GPUdisc_start = 1;
_d_index = 8;
  end
  6: begin
// __block_51_case
// __block_52
_d_gpu_active = 1;
_d_GPUtriangle_start = 1;
_d_index = 9;
  end
  7: begin
// __block_59_case
// __block_60
_d_gpu_active = 1;
_d_GPUblit_tilecharacter = 1;
_d_GPUblit_start = 1;
_d_index = 10;
  end
  8: begin
// __block_67_case
// __block_68
_d_gpu_active = 1;
_d_GPUblit_tilecharacter = 0;
_d_GPUblit_start = 1;
_d_index = 11;
  end
  default: begin
// __block_75_case
// __block_76
_d_gpu_active = 0;
// __block_77
_d_index = 1;
  end
endcase
end
end else begin
_d_index = 2;
end
end
3: begin
// __while__block_8
if (_w_VECTORline_busy) begin
// __block_9
// __block_11
_d_bitmap_x_write = _w_VECTORline_bitmap_x_write;
_d_bitmap_y_write = _w_VECTORline_bitmap_y_write;
_d_bitmap_write = _w_VECTORline_bitmap_write;
// __block_12
_d_index = 3;
end else begin
_d_index = 4;
end
end
5: begin
// __while__block_21
if (_w_GPUline_busy) begin
// __block_22
// __block_24
_d_bitmap_x_write = _w_GPUline_bitmap_x_write;
_d_bitmap_y_write = _w_GPUline_bitmap_y_write;
_d_bitmap_write = _w_GPUline_bitmap_write;
// __block_25
_d_index = 5;
end else begin
_d_index = 12;
end
end
6: begin
// __while__block_29
if (_w_GPUrectangle_busy) begin
// __block_30
// __block_32
_d_bitmap_x_write = _w_GPUrectangle_bitmap_x_write;
_d_bitmap_y_write = _w_GPUrectangle_bitmap_y_write;
_d_bitmap_write = _w_GPUrectangle_bitmap_write;
// __block_33
_d_index = 6;
end else begin
_d_index = 13;
end
end
7: begin
// __while__block_37
if (_w_GPUcircle_busy) begin
// __block_38
// __block_40
_d_bitmap_x_write = _w_GPUcircle_bitmap_x_write;
_d_bitmap_y_write = _w_GPUcircle_bitmap_y_write;
_d_bitmap_write = _w_GPUcircle_bitmap_write;
// __block_41
_d_index = 7;
end else begin
_d_index = 14;
end
end
8: begin
// __while__block_45
if (_w_GPUdisc_busy) begin
// __block_46
// __block_48
_d_bitmap_x_write = _w_GPUdisc_bitmap_x_write;
_d_bitmap_y_write = _w_GPUdisc_bitmap_y_write;
_d_bitmap_write = _w_GPUdisc_bitmap_write;
// __block_49
_d_index = 8;
end else begin
_d_index = 15;
end
end
9: begin
// __while__block_53
if (_w_GPUtriangle_busy) begin
// __block_54
// __block_56
_d_bitmap_x_write = _w_GPUtriangle_bitmap_x_write;
_d_bitmap_y_write = _w_GPUtriangle_bitmap_y_write;
_d_bitmap_write = _w_GPUtriangle_bitmap_write;
// __block_57
_d_index = 9;
end else begin
_d_index = 16;
end
end
10: begin
// __while__block_61
if (_w_GPUblit_busy) begin
// __block_62
// __block_64
_d_bitmap_x_write = _w_GPUblit_bitmap_x_write;
_d_bitmap_y_write = _w_GPUblit_bitmap_y_write;
_d_bitmap_write = _w_GPUblit_bitmap_write;
// __block_65
_d_index = 10;
end else begin
_d_index = 17;
end
end
11: begin
// __while__block_69
if (_w_GPUblit_busy) begin
// __block_70
// __block_72
_d_bitmap_x_write = _w_GPUblit_bitmap_x_write;
_d_bitmap_y_write = _w_GPUblit_bitmap_y_write;
_d_bitmap_write = _w_GPUblit_bitmap_write;
// __block_73
_d_index = 11;
end else begin
_d_index = 18;
end
end
2: begin
// __block_3
_d_index = 19;
end
4: begin
// __block_10
_d_gpu_active = 0;
// __block_13
_d_index = 1;
end
12: begin
// __block_23
_d_gpu_active = 0;
// __block_26
_d_index = 1;
end
13: begin
// __block_31
_d_gpu_active = 0;
// __block_34
_d_index = 1;
end
14: begin
// __block_39
_d_gpu_active = 0;
// __block_42
_d_index = 1;
end
15: begin
// __block_47
_d_gpu_active = 0;
// __block_50
_d_index = 1;
end
16: begin
// __block_55
_d_gpu_active = 0;
// __block_58
_d_index = 1;
end
17: begin
// __block_63
_d_gpu_active = 0;
// __block_66
_d_index = 1;
end
18: begin
// __block_71
_d_gpu_active = 0;
// __block_74
_d_index = 1;
end
19: begin // end of gpu
end
default: begin 
_d_index = 19;
 end
endcase
end
endmodule


module M_rectangle (
in_x,
in_y,
in_param0,
in_param1,
in_start,
out_bitmap_x_write,
out_bitmap_y_write,
out_bitmap_write,
out_busy,
in_run,
out_done,
reset,
out_clock,
clock
);
input signed [10:0] in_x;
input signed [10:0] in_y;
input signed [10:0] in_param0;
input signed [10:0] in_param1;
input  [0:0] in_start;
output  [10:0] out_bitmap_x_write;
output  [10:0] out_bitmap_y_write;
output  [0:0] out_bitmap_write;
output  [0:0] out_busy;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg signed [10:0] _d_gpu_active_x;
reg signed [10:0] _q_gpu_active_x;
reg signed [10:0] _d_gpu_active_y;
reg signed [10:0] _q_gpu_active_y;
reg signed [10:0] _d_gpu_x1;
reg signed [10:0] _q_gpu_x1;
reg signed [10:0] _d_gpu_max_x;
reg signed [10:0] _q_gpu_max_x;
reg signed [10:0] _d_gpu_max_y;
reg signed [10:0] _q_gpu_max_y;
reg  [0:0] _d_active;
reg  [0:0] _q_active;
reg  [10:0] _d_bitmap_x_write,_q_bitmap_x_write;
reg  [10:0] _d_bitmap_y_write,_q_bitmap_y_write;
reg  [0:0] _d_bitmap_write,_q_bitmap_write;
reg  [0:0] _d_busy,_q_busy;
reg  [3:0] _d_index,_q_index;
assign out_bitmap_x_write = _d_bitmap_x_write;
assign out_bitmap_y_write = _d_bitmap_y_write;
assign out_bitmap_write = _d_bitmap_write;
assign out_busy = _q_busy;
assign out_done = (_q_index == 9);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_active <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_gpu_active_x <= _d_gpu_active_x;
_q_gpu_active_y <= _d_gpu_active_y;
_q_gpu_x1 <= _d_gpu_x1;
_q_gpu_max_x <= _d_gpu_max_x;
_q_gpu_max_y <= _d_gpu_max_y;
_q_active <= _d_active;
_q_bitmap_x_write <= _d_bitmap_x_write;
_q_bitmap_y_write <= _d_bitmap_y_write;
_q_bitmap_write <= _d_bitmap_write;
_q_busy <= _d_busy;
_q_index <= _d_index;
  end
end




always @* begin
_d_gpu_active_x = _q_gpu_active_x;
_d_gpu_active_y = _q_gpu_active_y;
_d_gpu_x1 = _q_gpu_x1;
_d_gpu_max_x = _q_gpu_max_x;
_d_gpu_max_y = _q_gpu_max_y;
_d_active = _q_active;
_d_bitmap_x_write = _q_bitmap_x_write;
_d_bitmap_y_write = _q_bitmap_y_write;
_d_bitmap_write = _q_bitmap_write;
_d_busy = _q_busy;
_d_index = _q_index;
// _always_pre
_d_busy = in_start?1:_q_active;
_d_bitmap_x_write = _q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_active_y;
_d_bitmap_write = 0;
_d_index = 9;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_active = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_start) begin
// __block_5
// __block_7
_d_active = 1;
// __block_8_min
// __block_9
_d_gpu_active_x = (in_x<in_param0)?in_x:in_param0;
// __block_10
// __block_11
// __block_12_min
// __block_13
_d_gpu_active_y = (in_y<in_param1)?in_y:in_param1;
// __block_14
// __block_15
// __block_16_max
// __block_17
_d_gpu_max_x = (in_x>in_param0)?in_x:in_param0;
// __block_18
// __block_19
// __block_20_max
// __block_21
_d_gpu_max_y = (in_y>in_param1)?in_y:in_param1;
// __block_22
// __block_23
_d_index = 3;
end else begin
// __block_6
_d_index = 1;
end
end else begin
_d_index = 2;
end
end
3: begin
// __block_24
// __block_25_cropleft
// __block_26
_d_gpu_active_x = (_q_gpu_active_x<0)?0:_q_gpu_active_x;
// __block_27
// __block_28
// __block_29_cropleft
// __block_30
_d_gpu_x1 = (_d_gpu_active_x<0)?0:_d_gpu_active_x;
// __block_31
// __block_32
// __block_33_croptop
// __block_34
_d_gpu_active_y = (_q_gpu_active_y<0)?0:_q_gpu_active_y;
// __block_35
// __block_36
// __block_37_cropright
// __block_38
_d_gpu_max_x = (_q_gpu_max_x>639)?639:_q_gpu_max_x;
// __block_39
// __block_40
// __block_41_cropbottom
// __block_42
_d_gpu_max_y = (_q_gpu_max_y>479)?479:_q_gpu_max_y;
// __block_43
// __block_44
_d_index = 4;
end
2: begin
// __block_3
_d_index = 9;
end
4: begin
// __block_45
_d_index = 5;
end
5: begin
// __while__block_46
if (_q_gpu_active_y<=_q_gpu_max_y) begin
// __block_47
// __block_49
_d_index = 7;
end else begin
_d_index = 6;
end
end
7: begin
// __while__block_50
if (_q_gpu_active_x<=_q_gpu_max_x) begin
// __block_51
// __block_53
_d_bitmap_write = 1;
_d_gpu_active_x = _q_gpu_active_x+1;
// __block_54
_d_index = 7;
end else begin
_d_index = 8;
end
end
6: begin
// __block_48
_d_active = 0;
// __block_56
_d_index = 1;
end
8: begin
// __block_52
_d_gpu_active_x = _q_gpu_x1;
_d_gpu_active_y = _q_gpu_active_y+1;
// __block_55
_d_index = 5;
end
9: begin // end of rectangle
end
default: begin 
_d_index = 9;
 end
endcase
end
endmodule


module M_line (
in_x,
in_y,
in_param0,
in_param1,
in_start,
out_bitmap_x_write,
out_bitmap_y_write,
out_bitmap_write,
out_busy,
in_run,
out_done,
reset,
out_clock,
clock
);
input signed [10:0] in_x;
input signed [10:0] in_y;
input signed [10:0] in_param0;
input signed [10:0] in_param1;
input  [0:0] in_start;
output  [10:0] out_bitmap_x_write;
output  [10:0] out_bitmap_y_write;
output  [0:0] out_bitmap_write;
output  [0:0] out_busy;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg signed [10:0] _d_gpu_active_x;
reg signed [10:0] _q_gpu_active_x;
reg signed [10:0] _d_gpu_active_y;
reg signed [10:0] _q_gpu_active_y;
reg signed [10:0] _d_gpu_dx;
reg signed [10:0] _q_gpu_dx;
reg signed [10:0] _d_gpu_dy;
reg signed [10:0] _q_gpu_dy;
reg signed [10:0] _d_gpu_sy;
reg signed [10:0] _q_gpu_sy;
reg signed [10:0] _d_gpu_numerator;
reg signed [10:0] _q_gpu_numerator;
reg signed [10:0] _d_gpu_numerator2;
reg signed [10:0] _q_gpu_numerator2;
reg signed [10:0] _d_gpu_count;
reg signed [10:0] _q_gpu_count;
reg signed [10:0] _d_gpu_max_count;
reg signed [10:0] _q_gpu_max_count;
reg  [0:0] _d_active;
reg  [0:0] _q_active;
reg  [10:0] _d_bitmap_x_write,_q_bitmap_x_write;
reg  [10:0] _d_bitmap_y_write,_q_bitmap_y_write;
reg  [0:0] _d_bitmap_write,_q_bitmap_write;
reg  [0:0] _d_busy,_q_busy;
reg  [3:0] _d_index,_q_index;
assign out_bitmap_x_write = _d_bitmap_x_write;
assign out_bitmap_y_write = _d_bitmap_y_write;
assign out_bitmap_write = _d_bitmap_write;
assign out_busy = _q_busy;
assign out_done = (_q_index == 9);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_active <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_gpu_active_x <= _d_gpu_active_x;
_q_gpu_active_y <= _d_gpu_active_y;
_q_gpu_dx <= _d_gpu_dx;
_q_gpu_dy <= _d_gpu_dy;
_q_gpu_sy <= _d_gpu_sy;
_q_gpu_numerator <= _d_gpu_numerator;
_q_gpu_numerator2 <= _d_gpu_numerator2;
_q_gpu_count <= _d_gpu_count;
_q_gpu_max_count <= _d_gpu_max_count;
_q_active <= _d_active;
_q_bitmap_x_write <= _d_bitmap_x_write;
_q_bitmap_y_write <= _d_bitmap_y_write;
_q_bitmap_write <= _d_bitmap_write;
_q_busy <= _d_busy;
_q_index <= _d_index;
  end
end




always @* begin
_d_gpu_active_x = _q_gpu_active_x;
_d_gpu_active_y = _q_gpu_active_y;
_d_gpu_dx = _q_gpu_dx;
_d_gpu_dy = _q_gpu_dy;
_d_gpu_sy = _q_gpu_sy;
_d_gpu_numerator = _q_gpu_numerator;
_d_gpu_numerator2 = _q_gpu_numerator2;
_d_gpu_count = _q_gpu_count;
_d_gpu_max_count = _q_gpu_max_count;
_d_active = _q_active;
_d_bitmap_x_write = _q_bitmap_x_write;
_d_bitmap_y_write = _q_bitmap_y_write;
_d_bitmap_write = _q_bitmap_write;
_d_busy = _q_busy;
_d_index = _q_index;
// _always_pre
_d_busy = in_start?1:_q_active;
_d_bitmap_x_write = _q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_active_y;
_d_bitmap_write = 0;
_d_index = 9;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_active = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_start) begin
// __block_5
// __block_7
_d_active = 1;
// __block_8_min
// __block_9
_d_gpu_active_x = (in_x<in_param0)?in_x:in_param0;
// __block_10
// __block_11
_d_gpu_active_y = (in_x<in_param0)?in_y:in_param1;
_d_gpu_sy = (in_x<in_param0)?((in_y<in_param1)?1:-1):((in_y<in_param1)?-1:1);
// __block_12_absdelta
// __block_13
_d_gpu_dx = (in_x<in_param0)?in_param0-in_x:in_x-in_param0;
// __block_14
// __block_15
// __block_16_absdelta
// __block_17
_d_gpu_dy = (in_y<in_param1)?in_param1-in_y:in_y-in_param1;
// __block_18
// __block_19
_d_index = 3;
end else begin
// __block_6
_d_index = 1;
end
end else begin
_d_index = 2;
end
end
3: begin
// __block_20
_d_gpu_count = 0;
_d_gpu_numerator = (_q_gpu_dx>_q_gpu_dy)?(_q_gpu_dx>>1):-(_q_gpu_dy>>1);
// __block_21_max
// __block_22
_d_gpu_max_count = (_q_gpu_dx>_q_gpu_dy)?_q_gpu_dx:_q_gpu_dy;
// __block_23
// __block_24
_d_index = 4;
end
2: begin
// __block_3
_d_index = 9;
end
4: begin
// __block_25
_d_index = 5;
end
5: begin
// __while__block_26
if (_q_gpu_count<=_q_gpu_max_count) begin
// __block_27
// __block_29
_d_bitmap_write = 1;
_d_gpu_numerator2 = _q_gpu_numerator;
_d_index = 7;
end else begin
_d_index = 6;
end
end
7: begin
// __block_30
if (_q_gpu_numerator2>(-_q_gpu_dx)) begin
// __block_31
// __block_33
_d_gpu_numerator = _q_gpu_numerator-_q_gpu_dy;
_d_gpu_active_x = _q_gpu_active_x+1;
// __block_34
end else begin
// __block_32
end
// __block_35
_d_index = 8;
end
6: begin
// __block_28
_d_active = 0;
// __block_43
_d_index = 1;
end
8: begin
// __block_36
if (_q_gpu_numerator2<_q_gpu_dy) begin
// __block_37
// __block_39
_d_gpu_numerator = _q_gpu_numerator+_q_gpu_dx;
_d_gpu_active_y = _q_gpu_active_y+_q_gpu_sy;
// __block_40
end else begin
// __block_38
end
// __block_41
_d_gpu_count = _q_gpu_count+1;
// __block_42
_d_index = 5;
end
9: begin // end of line
end
default: begin 
_d_index = 9;
 end
endcase
end
endmodule


module M_circle (
in_x,
in_y,
in_param0,
in_start,
out_bitmap_x_write,
out_bitmap_y_write,
out_bitmap_write,
out_busy,
in_run,
out_done,
reset,
out_clock,
clock
);
input signed [10:0] in_x;
input signed [10:0] in_y;
input signed [10:0] in_param0;
input  [0:0] in_start;
output  [10:0] out_bitmap_x_write;
output  [10:0] out_bitmap_y_write;
output  [0:0] out_bitmap_write;
output  [0:0] out_busy;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg signed [10:0] _d_gpu_active_x;
reg signed [10:0] _q_gpu_active_x;
reg signed [10:0] _d_gpu_active_y;
reg signed [10:0] _q_gpu_active_y;
reg signed [10:0] _d_gpu_xc;
reg signed [10:0] _q_gpu_xc;
reg signed [10:0] _d_gpu_yc;
reg signed [10:0] _q_gpu_yc;
reg signed [10:0] _d_gpu_numerator;
reg signed [10:0] _q_gpu_numerator;
reg  [0:0] _d_active;
reg  [0:0] _q_active;
reg  [10:0] _d_bitmap_x_write,_q_bitmap_x_write;
reg  [10:0] _d_bitmap_y_write,_q_bitmap_y_write;
reg  [0:0] _d_bitmap_write,_q_bitmap_write;
reg  [0:0] _d_busy,_q_busy;
reg  [3:0] _d_index,_q_index;
assign out_bitmap_x_write = _q_bitmap_x_write;
assign out_bitmap_y_write = _q_bitmap_y_write;
assign out_bitmap_write = _q_bitmap_write;
assign out_busy = _q_busy;
assign out_done = (_q_index == 14);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_active <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_gpu_active_x <= _d_gpu_active_x;
_q_gpu_active_y <= _d_gpu_active_y;
_q_gpu_xc <= _d_gpu_xc;
_q_gpu_yc <= _d_gpu_yc;
_q_gpu_numerator <= _d_gpu_numerator;
_q_active <= _d_active;
_q_bitmap_x_write <= _d_bitmap_x_write;
_q_bitmap_y_write <= _d_bitmap_y_write;
_q_bitmap_write <= _d_bitmap_write;
_q_busy <= _d_busy;
_q_index <= _d_index;
  end
end




always @* begin
_d_gpu_active_x = _q_gpu_active_x;
_d_gpu_active_y = _q_gpu_active_y;
_d_gpu_xc = _q_gpu_xc;
_d_gpu_yc = _q_gpu_yc;
_d_gpu_numerator = _q_gpu_numerator;
_d_active = _q_active;
_d_bitmap_x_write = _q_bitmap_x_write;
_d_bitmap_y_write = _q_bitmap_y_write;
_d_bitmap_write = _q_bitmap_write;
_d_busy = _q_busy;
_d_index = _q_index;
// _always_pre
_d_busy = in_start?1:_q_active;
_d_bitmap_write = 0;
_d_index = 14;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_active = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_start) begin
// __block_5
// __block_7
_d_active = 1;
_d_gpu_active_x = 0;
// __block_8_abs
// __block_9
_d_gpu_active_y = (in_param0<0)?-in_param0:in_param0;
// __block_10
// __block_11
// __block_12_copycoordinates
// __block_13
_d_gpu_xc = in_x;
_d_gpu_yc = in_y;
// __block_14
// __block_15
_d_index = 3;
end else begin
// __block_6
_d_index = 1;
end
end else begin
_d_index = 2;
end
end
3: begin
// __block_16
_d_gpu_numerator = 3-(2*_q_gpu_active_y);
_d_index = 4;
end
2: begin
// __block_3
_d_index = 14;
end
4: begin
// __block_17
_d_index = 5;
end
5: begin
// __while__block_18
if (_q_gpu_active_y>=_q_gpu_active_x) begin
// __block_19
// __block_21
_d_bitmap_x_write = _q_gpu_xc+_q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_active_y;
_d_bitmap_write = 1;
_d_index = 7;
end else begin
_d_index = 6;
end
end
7: begin
// __block_22
_d_bitmap_y_write = _q_gpu_yc-_q_gpu_active_y;
_d_bitmap_write = 1;
_d_index = 8;
end
6: begin
// __block_20
_d_active = 0;
// __block_37
_d_index = 1;
end
8: begin
// __block_23
_d_bitmap_x_write = _q_gpu_xc-_q_gpu_active_x;
_d_bitmap_write = 1;
_d_index = 9;
end
9: begin
// __block_24
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_active_y;
_d_bitmap_write = 1;
_d_index = 10;
end
10: begin
// __block_25
_d_bitmap_x_write = _q_gpu_xc+_q_gpu_active_y;
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_active_x;
_d_bitmap_write = 1;
_d_index = 11;
end
11: begin
// __block_26
_d_bitmap_y_write = _q_gpu_yc-_q_gpu_active_x;
_d_bitmap_write = 1;
_d_index = 12;
end
12: begin
// __block_27
_d_bitmap_x_write = _q_gpu_xc-_q_gpu_active_y;
_d_bitmap_write = 1;
_d_index = 13;
end
13: begin
// __block_28
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_active_x;
_d_bitmap_write = 1;
_d_gpu_active_x = _q_gpu_active_x+1;
if (_q_gpu_numerator>0) begin
// __block_29
// __block_31
_d_gpu_numerator = _q_gpu_numerator+4*(_d_gpu_active_x-_q_gpu_active_y)+10;
_d_gpu_active_y = _q_gpu_active_y-1;
// __block_32
end else begin
// __block_30
// __block_33
_d_gpu_numerator = _q_gpu_numerator+4*_d_gpu_active_x+6;
// __block_34
end
// __block_35
// __block_36
_d_index = 5;
end
14: begin // end of circle
end
default: begin 
_d_index = 14;
 end
endcase
end
endmodule


module M_disc (
in_x,
in_y,
in_param0,
in_start,
out_bitmap_x_write,
out_bitmap_y_write,
out_bitmap_write,
out_busy,
in_run,
out_done,
reset,
out_clock,
clock
);
input signed [10:0] in_x;
input signed [10:0] in_y;
input signed [10:0] in_param0;
input  [0:0] in_start;
output  [10:0] out_bitmap_x_write;
output  [10:0] out_bitmap_y_write;
output  [0:0] out_bitmap_write;
output  [0:0] out_busy;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg signed [10:0] _d_gpu_active_x;
reg signed [10:0] _q_gpu_active_x;
reg signed [10:0] _d_gpu_active_y;
reg signed [10:0] _q_gpu_active_y;
reg signed [10:0] _d_gpu_xc;
reg signed [10:0] _q_gpu_xc;
reg signed [10:0] _d_gpu_yc;
reg signed [10:0] _q_gpu_yc;
reg signed [10:0] _d_gpu_numerator;
reg signed [10:0] _q_gpu_numerator;
reg signed [10:0] _d_gpu_count;
reg signed [10:0] _q_gpu_count;
reg  [0:0] _d_active;
reg  [0:0] _q_active;
reg  [10:0] _d_bitmap_x_write,_q_bitmap_x_write;
reg  [10:0] _d_bitmap_y_write,_q_bitmap_y_write;
reg  [0:0] _d_bitmap_write,_q_bitmap_write;
reg  [0:0] _d_busy,_q_busy;
reg  [4:0] _d_index,_q_index;
assign out_bitmap_x_write = _q_bitmap_x_write;
assign out_bitmap_y_write = _q_bitmap_y_write;
assign out_bitmap_write = _q_bitmap_write;
assign out_busy = _q_busy;
assign out_done = (_q_index == 17);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_active <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_gpu_active_x <= _d_gpu_active_x;
_q_gpu_active_y <= _d_gpu_active_y;
_q_gpu_xc <= _d_gpu_xc;
_q_gpu_yc <= _d_gpu_yc;
_q_gpu_numerator <= _d_gpu_numerator;
_q_gpu_count <= _d_gpu_count;
_q_active <= _d_active;
_q_bitmap_x_write <= _d_bitmap_x_write;
_q_bitmap_y_write <= _d_bitmap_y_write;
_q_bitmap_write <= _d_bitmap_write;
_q_busy <= _d_busy;
_q_index <= _d_index;
  end
end




always @* begin
_d_gpu_active_x = _q_gpu_active_x;
_d_gpu_active_y = _q_gpu_active_y;
_d_gpu_xc = _q_gpu_xc;
_d_gpu_yc = _q_gpu_yc;
_d_gpu_numerator = _q_gpu_numerator;
_d_gpu_count = _q_gpu_count;
_d_active = _q_active;
_d_bitmap_x_write = _q_bitmap_x_write;
_d_bitmap_y_write = _q_bitmap_y_write;
_d_bitmap_write = _q_bitmap_write;
_d_busy = _q_busy;
_d_index = _q_index;
// _always_pre
_d_busy = in_start?1:_q_active;
_d_bitmap_write = 0;
_d_index = 17;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_active = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_start) begin
// __block_5
// __block_7
_d_active = 1;
_d_gpu_active_x = 0;
// __block_8_abs
// __block_9
_d_gpu_active_y = (in_param0<0)?-in_param0:in_param0;
// __block_10
// __block_11
// __block_12_copycoordinates
// __block_13
_d_gpu_xc = in_x;
_d_gpu_yc = in_y;
// __block_14
// __block_15
_d_index = 3;
end else begin
// __block_6
_d_index = 1;
end
end else begin
_d_index = 2;
end
end
3: begin
// __block_16
_d_gpu_active_y = (_q_gpu_active_y<4)?4:_q_gpu_active_y;
_d_index = 4;
end
2: begin
// __block_3
_d_index = 17;
end
4: begin
// __block_17
_d_gpu_count = _q_gpu_active_y;
_d_gpu_numerator = 3-(2*_q_gpu_active_y);
_d_index = 5;
end
5: begin
// __block_18
_d_index = 6;
end
6: begin
// __while__block_19
if (_q_gpu_active_y>=_q_gpu_active_x) begin
// __block_20
// __block_22
_d_index = 8;
end else begin
_d_index = 7;
end
end
8: begin
// __while__block_23
if (_q_gpu_count!=0) begin
// __block_24
// __block_26
_d_bitmap_x_write = _q_gpu_xc+_q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_count;
_d_bitmap_write = 1;
_d_index = 10;
end else begin
_d_index = 9;
end
end
7: begin
// __block_21
_d_bitmap_x_write = _q_gpu_xc;
_d_bitmap_y_write = _q_gpu_yc;
_d_bitmap_write = 1;
_d_active = 0;
// __block_43
_d_index = 1;
end
10: begin
// __block_27
_d_bitmap_y_write = _q_gpu_yc-_q_gpu_count;
_d_bitmap_write = 1;
_d_index = 11;
end
9: begin
// __block_25
_d_gpu_active_x = _q_gpu_active_x+1;
if (_q_gpu_numerator>0) begin
// __block_35
// __block_37
_d_gpu_numerator = _q_gpu_numerator+4*(_d_gpu_active_x-_q_gpu_active_y)+10;
_d_gpu_active_y = _q_gpu_active_y-1;
_d_gpu_count = _d_gpu_active_y-1;
// __block_38
end else begin
// __block_36
// __block_39
_d_gpu_numerator = _q_gpu_numerator+4*_d_gpu_active_x+6;
_d_gpu_count = _q_gpu_active_y;
// __block_40
end
// __block_41
// __block_42
_d_index = 6;
end
11: begin
// __block_28
_d_bitmap_x_write = _q_gpu_xc-_q_gpu_active_x;
_d_bitmap_write = 1;
_d_index = 12;
end
12: begin
// __block_29
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_count;
_d_bitmap_write = 1;
_d_index = 13;
end
13: begin
// __block_30
_d_bitmap_x_write = _q_gpu_xc+_q_gpu_count;
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_active_x;
_d_bitmap_write = 1;
_d_index = 14;
end
14: begin
// __block_31
_d_bitmap_y_write = _q_gpu_yc-_q_gpu_active_x;
_d_bitmap_write = 1;
_d_index = 15;
end
15: begin
// __block_32
_d_bitmap_x_write = _q_gpu_xc-_q_gpu_count;
_d_bitmap_write = 1;
_d_index = 16;
end
16: begin
// __block_33
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_active_x;
_d_bitmap_write = 1;
_d_gpu_count = _q_gpu_count-1;
// __block_34
_d_index = 8;
end
17: begin // end of disc
end
default: begin 
_d_index = 17;
 end
endcase
end
endmodule


module M_triangle (
in_x,
in_y,
in_param0,
in_param1,
in_param2,
in_param3,
in_start,
out_bitmap_x_write,
out_bitmap_y_write,
out_bitmap_write,
out_busy,
in_run,
out_done,
reset,
out_clock,
clock
);
input signed [10:0] in_x;
input signed [10:0] in_y;
input signed [10:0] in_param0;
input signed [10:0] in_param1;
input signed [10:0] in_param2;
input signed [10:0] in_param3;
input  [0:0] in_start;
output  [10:0] out_bitmap_x_write;
output  [10:0] out_bitmap_y_write;
output  [0:0] out_bitmap_write;
output  [0:0] out_busy;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [0:0] _w_inTriangle;

reg signed [10:0] _d_gpu_active_x;
reg signed [10:0] _q_gpu_active_x;
reg signed [10:0] _d_gpu_active_y;
reg signed [10:0] _q_gpu_active_y;
reg signed [10:0] _d_gpu_x1;
reg signed [10:0] _q_gpu_x1;
reg signed [10:0] _d_gpu_y1;
reg signed [10:0] _q_gpu_y1;
reg signed [10:0] _d_gpu_x2;
reg signed [10:0] _q_gpu_x2;
reg signed [10:0] _d_gpu_y2;
reg signed [10:0] _q_gpu_y2;
reg signed [10:0] _d_gpu_min_x;
reg signed [10:0] _q_gpu_min_x;
reg signed [10:0] _d_gpu_max_x;
reg signed [10:0] _q_gpu_max_x;
reg signed [10:0] _d_gpu_min_y;
reg signed [10:0] _q_gpu_min_y;
reg signed [10:0] _d_gpu_max_y;
reg signed [10:0] _q_gpu_max_y;
reg signed [10:0] _d_gpu_sx;
reg signed [10:0] _q_gpu_sx;
reg signed [10:0] _d_gpu_sy;
reg signed [10:0] _q_gpu_sy;
reg  [0:0] _d_gpu_dx;
reg  [0:0] _q_gpu_dx;
reg  [0:0] _d_w0;
reg  [0:0] _q_w0;
reg  [0:0] _d_w1;
reg  [0:0] _q_w1;
reg  [0:0] _d_w2;
reg  [0:0] _q_w2;
reg  [0:0] _d_beenInTriangle;
reg  [0:0] _q_beenInTriangle;
reg  [0:0] _d_active;
reg  [0:0] _q_active;
reg  [10:0] _d_bitmap_x_write,_q_bitmap_x_write;
reg  [10:0] _d_bitmap_y_write,_q_bitmap_y_write;
reg  [0:0] _d_bitmap_write,_q_bitmap_write;
reg  [0:0] _d_busy,_q_busy;
reg  [3:0] _d_index,_q_index;
assign out_bitmap_x_write = _q_bitmap_x_write;
assign out_bitmap_y_write = _q_bitmap_y_write;
assign out_bitmap_write = _q_bitmap_write;
assign out_busy = _q_busy;
assign out_done = (_q_index == 14);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_active <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_gpu_active_x <= _d_gpu_active_x;
_q_gpu_active_y <= _d_gpu_active_y;
_q_gpu_x1 <= _d_gpu_x1;
_q_gpu_y1 <= _d_gpu_y1;
_q_gpu_x2 <= _d_gpu_x2;
_q_gpu_y2 <= _d_gpu_y2;
_q_gpu_min_x <= _d_gpu_min_x;
_q_gpu_max_x <= _d_gpu_max_x;
_q_gpu_min_y <= _d_gpu_min_y;
_q_gpu_max_y <= _d_gpu_max_y;
_q_gpu_sx <= _d_gpu_sx;
_q_gpu_sy <= _d_gpu_sy;
_q_gpu_dx <= _d_gpu_dx;
_q_w0 <= _d_w0;
_q_w1 <= _d_w1;
_q_w2 <= _d_w2;
_q_beenInTriangle <= _d_beenInTriangle;
_q_active <= _d_active;
_q_bitmap_x_write <= _d_bitmap_x_write;
_q_bitmap_y_write <= _d_bitmap_y_write;
_q_bitmap_write <= _d_bitmap_write;
_q_busy <= _d_busy;
_q_index <= _d_index;
  end
end



assign _w_inTriangle = _d_w0&&_d_w1&&_d_w2;

always @* begin
_d_gpu_active_x = _q_gpu_active_x;
_d_gpu_active_y = _q_gpu_active_y;
_d_gpu_x1 = _q_gpu_x1;
_d_gpu_y1 = _q_gpu_y1;
_d_gpu_x2 = _q_gpu_x2;
_d_gpu_y2 = _q_gpu_y2;
_d_gpu_min_x = _q_gpu_min_x;
_d_gpu_max_x = _q_gpu_max_x;
_d_gpu_min_y = _q_gpu_min_y;
_d_gpu_max_y = _q_gpu_max_y;
_d_gpu_sx = _q_gpu_sx;
_d_gpu_sy = _q_gpu_sy;
_d_gpu_dx = _q_gpu_dx;
_d_w0 = _q_w0;
_d_w1 = _q_w1;
_d_w2 = _q_w2;
_d_beenInTriangle = _q_beenInTriangle;
_d_active = _q_active;
_d_bitmap_x_write = _q_bitmap_x_write;
_d_bitmap_y_write = _q_bitmap_y_write;
_d_bitmap_write = _q_bitmap_write;
_d_busy = _q_busy;
_d_index = _q_index;
// _always_pre
_d_busy = in_start?1:_q_active;
_d_bitmap_x_write = _q_gpu_sx;
_d_bitmap_y_write = _q_gpu_sy;
_d_bitmap_write = 0;
_d_index = 14;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_active = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_start) begin
// __block_5
// __block_7
_d_active = 1;
// __block_8_copycoordinates
// __block_9
_d_gpu_active_x = in_x;
_d_gpu_active_y = in_y;
// __block_10
// __block_11
// __block_12_copycoordinates
// __block_13
_d_gpu_x1 = in_param0;
_d_gpu_y1 = in_param1;
// __block_14
// __block_15
// __block_16_copycoordinates
// __block_17
_d_gpu_x2 = in_param2;
_d_gpu_y2 = in_param3;
// __block_18
// __block_19
_d_index = 3;
end else begin
// __block_6
_d_index = 1;
end
end else begin
_d_index = 2;
end
end
3: begin
// __block_20
// __block_21_min3
// __block_22
_d_gpu_min_x = (_q_gpu_active_x<_q_gpu_x1)?(_q_gpu_active_x<_q_gpu_x2?_q_gpu_active_x:_q_gpu_x2):(_q_gpu_x1<_q_gpu_x2?_q_gpu_x1:_q_gpu_x2);
// __block_23
// __block_24
// __block_25_min3
// __block_26
_d_gpu_min_y = (_q_gpu_active_y<_q_gpu_y1)?(_q_gpu_active_y<_q_gpu_y2?_q_gpu_active_y:_q_gpu_y2):(_q_gpu_y1<_q_gpu_y2?_q_gpu_y1:_q_gpu_y2);
// __block_27
// __block_28
// __block_29_max3
// __block_30
_d_gpu_max_x = (_q_gpu_active_x>_q_gpu_x1)?(_q_gpu_active_x>_q_gpu_x2?_q_gpu_active_x:_q_gpu_x2):(_q_gpu_x1>_q_gpu_x2?_q_gpu_x1:_q_gpu_x2);
// __block_31
// __block_32
// __block_33_max3
// __block_34
_d_gpu_max_y = (_q_gpu_active_y>_q_gpu_y1)?(_q_gpu_active_y>_q_gpu_y2?_q_gpu_active_y:_q_gpu_y2):(_q_gpu_y1>_q_gpu_y2?_q_gpu_y1:_q_gpu_y2);
// __block_35
// __block_36
_d_index = 4;
end
2: begin
// __block_3
_d_index = 14;
end
4: begin
// __block_37
// __block_38_cropleft
// __block_39
_d_gpu_min_x = (_q_gpu_min_x<0)?0:_q_gpu_min_x;
// __block_40
// __block_41
// __block_42_cropright
// __block_43
_d_gpu_max_x = (_q_gpu_max_x>639)?639:_q_gpu_max_x;
// __block_44
// __block_45
// __block_46_croptop
// __block_47
_d_gpu_min_y = (_q_gpu_min_y<0)?0:_q_gpu_min_y;
// __block_48
// __block_49
// __block_50_cropbottom
// __block_51
_d_gpu_max_y = (_q_gpu_max_y>479)?479:_q_gpu_max_y;
// __block_52
// __block_53
_d_index = 5;
end
5: begin
// __block_54
if (_q_gpu_y1<_q_gpu_active_y) begin
// __block_55
// __block_57
// __block_58_swapcoordinates
// __block_59
_d_gpu_active_x = _q_gpu_x1;
_d_gpu_active_y = _q_gpu_y1;
_d_gpu_x1 = _d_gpu_active_x;
_d_gpu_y1 = _d_gpu_active_y;
// __block_60
// __block_61
// __block_62
end else begin
// __block_56
end
// __block_63
_d_index = 6;
end
6: begin
// __block_64
if (_q_gpu_y2<_q_gpu_active_y) begin
// __block_65
// __block_67
// __block_68_swapcoordinates
// __block_69
_d_gpu_active_x = _q_gpu_x2;
_d_gpu_active_y = _q_gpu_y2;
_d_gpu_x2 = _d_gpu_active_x;
_d_gpu_y2 = _d_gpu_active_y;
// __block_70
// __block_71
// __block_72
end else begin
// __block_66
end
// __block_73
_d_index = 7;
end
7: begin
// __block_74
if (_q_gpu_x1<_q_gpu_x2) begin
// __block_75
// __block_77
// __block_78_swapcoordinates
// __block_79
_d_gpu_x1 = _q_gpu_x2;
_d_gpu_y1 = _q_gpu_y2;
_d_gpu_x2 = _d_gpu_x1;
_d_gpu_y2 = _d_gpu_y1;
// __block_80
// __block_81
// __block_82
end else begin
// __block_76
end
// __block_83
_d_index = 8;
end
8: begin
// __block_84
// __block_85_copycoordinates
// __block_86
_d_gpu_sx = _q_gpu_min_x;
_d_gpu_sy = _q_gpu_min_y;
// __block_87
// __block_88
_d_gpu_dx = 1;
_d_beenInTriangle = 0;
_d_index = 9;
end
9: begin
// __block_89
_d_index = 10;
end
10: begin
// __while__block_90
if (_q_gpu_sy<=_q_gpu_max_y) begin
// __block_91
// __block_93
_d_w0 = ((_q_gpu_x2-_q_gpu_x1)*(_q_gpu_sy-_q_gpu_y1)-(_q_gpu_y2-_q_gpu_y1)*(_q_gpu_sx-_q_gpu_x1))>=0;
_d_w1 = ((_q_gpu_active_x-_q_gpu_x2)*(_q_gpu_sy-_q_gpu_y2)-(_q_gpu_active_y-_q_gpu_y2)*(_q_gpu_sx-_q_gpu_x2))>=0;
_d_w2 = ((_q_gpu_x1-_q_gpu_active_x)*(_q_gpu_sy-_q_gpu_active_y)-(_q_gpu_y1-_q_gpu_active_y)*(_q_gpu_sx-_q_gpu_active_x))>=0;
_d_index = 12;
end else begin
_d_index = 11;
end
end
12: begin
// __block_94
_d_bitmap_write = _w_inTriangle;
_d_beenInTriangle = _w_inTriangle?1:_q_beenInTriangle;
_d_index = 13;
end
11: begin
// __block_92
_d_active = 0;
// __block_132
_d_index = 1;
end
13: begin
// __block_95
if (_q_beenInTriangle&&~_w_inTriangle) begin
// __block_96
// __block_98
_d_beenInTriangle = 0;
_d_gpu_sy = _q_gpu_sy+1;
if ((_q_gpu_max_x-_q_gpu_sx)<(_q_gpu_sx-_q_gpu_min_x)) begin
// __block_99
// __block_101
_d_gpu_sx = _q_gpu_max_x;
_d_gpu_dx = 0;
// __block_102
end else begin
// __block_100
// __block_103
_d_gpu_sx = _q_gpu_min_x;
_d_gpu_dx = 1;
// __block_104
end
// __block_105
// __block_106
end else begin
// __block_97
// __block_107
  case (_q_gpu_dx)
  0: begin
// __block_109_case
// __block_110
if (_q_gpu_sx>=_q_gpu_min_x) begin
// __block_111
// __block_113
_d_gpu_sx = _q_gpu_sx-1;
// __block_114
end else begin
// __block_112
// __block_115
_d_gpu_dx = 1;
_d_beenInTriangle = 0;
_d_gpu_sy = _q_gpu_sy+1;
// __block_116
end
// __block_117
// __block_118
  end
  1: begin
// __block_119_case
// __block_120
if (_q_gpu_sx<=_q_gpu_max_x) begin
// __block_121
// __block_123
_d_gpu_sx = _q_gpu_sx+1;
// __block_124
end else begin
// __block_122
// __block_125
_d_gpu_dx = 0;
_d_beenInTriangle = 0;
_d_gpu_sy = _q_gpu_sy+1;
// __block_126
end
// __block_127
// __block_128
  end
endcase
// __block_108
// __block_129
end
// __block_130
// __block_131
_d_index = 10;
end
14: begin // end of triangle
end
default: begin 
_d_index = 14;
 end
endcase
end
endmodule


module M_blit #(
parameter BLIT1TILEMAP_ADDR0_WIDTH=1,parameter BLIT1TILEMAP_ADDR0_SIGNED=0,parameter BLIT1TILEMAP_ADDR0_INIT=0,
parameter BLIT1TILEMAP_RDATA0_WIDTH=1,parameter BLIT1TILEMAP_RDATA0_SIGNED=0,parameter BLIT1TILEMAP_RDATA0_INIT=0,
parameter CHARACTERGENERATOR8X8_ADDR0_WIDTH=1,parameter CHARACTERGENERATOR8X8_ADDR0_SIGNED=0,parameter CHARACTERGENERATOR8X8_ADDR0_INIT=0,
parameter CHARACTERGENERATOR8X8_RDATA0_WIDTH=1,parameter CHARACTERGENERATOR8X8_RDATA0_SIGNED=0,parameter CHARACTERGENERATOR8X8_RDATA0_INIT=0
) (
in_x,
in_y,
in_param0,
in_param1,
in_start,
in_tilecharacter,
in_blit1tilemap_rdata0,
in_characterGenerator8x8_rdata0,
out_bitmap_x_write,
out_bitmap_y_write,
out_bitmap_write,
out_busy,
out_blit1tilemap_addr0,
out_characterGenerator8x8_addr0,
in_run,
out_done,
reset,
out_clock,
clock
);
input signed [10:0] in_x;
input signed [10:0] in_y;
input signed [10:0] in_param0;
input  [1:0] in_param1;
input  [0:0] in_start;
input  [0:0] in_tilecharacter;
input  [BLIT1TILEMAP_RDATA0_WIDTH-1:0] in_blit1tilemap_rdata0;
input  [CHARACTERGENERATOR8X8_RDATA0_WIDTH-1:0] in_characterGenerator8x8_rdata0;
output  [10:0] out_bitmap_x_write;
output  [10:0] out_bitmap_y_write;
output  [0:0] out_bitmap_write;
output  [0:0] out_busy;
output  [BLIT1TILEMAP_ADDR0_WIDTH-1:0] out_blit1tilemap_addr0;
output  [CHARACTERGENERATOR8X8_ADDR0_WIDTH-1:0] out_characterGenerator8x8_addr0;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [7:0] _d_gpu_active_x;
reg  [7:0] _q_gpu_active_x;
reg  [7:0] _d_gpu_active_y;
reg  [7:0] _q_gpu_active_y;
reg signed [10:0] _d_gpu_x1;
reg signed [10:0] _q_gpu_x1;
reg signed [10:0] _d_gpu_y1;
reg signed [10:0] _q_gpu_y1;
reg  [4:0] _d_gpu_y2;
reg  [4:0] _q_gpu_y2;
reg  [1:0] _d_gpu_param1;
reg  [1:0] _q_gpu_param1;
reg  [7:0] _d_gpu_max_x;
reg  [7:0] _q_gpu_max_x;
reg  [7:0] _d_gpu_max_y;
reg  [7:0] _q_gpu_max_y;
reg  [7:0] _d_gpu_tile;
reg  [7:0] _q_gpu_tile;
reg  [0:0] _d_active;
reg  [0:0] _q_active;
reg  [10:0] _d_bitmap_x_write,_q_bitmap_x_write;
reg  [10:0] _d_bitmap_y_write,_q_bitmap_y_write;
reg  [0:0] _d_bitmap_write,_q_bitmap_write;
reg  [0:0] _d_busy,_q_busy;
reg  [BLIT1TILEMAP_ADDR0_WIDTH-1:0] _d_blit1tilemap_addr0,_q_blit1tilemap_addr0;
reg  [CHARACTERGENERATOR8X8_ADDR0_WIDTH-1:0] _d_characterGenerator8x8_addr0,_q_characterGenerator8x8_addr0;
reg  [3:0] _d_index,_q_index;
assign out_bitmap_x_write = _q_bitmap_x_write;
assign out_bitmap_y_write = _q_bitmap_y_write;
assign out_bitmap_write = _q_bitmap_write;
assign out_busy = _q_busy;
assign out_blit1tilemap_addr0 = _d_blit1tilemap_addr0;
assign out_characterGenerator8x8_addr0 = _d_characterGenerator8x8_addr0;
assign out_done = (_q_index == 10);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_active <= 0;
_q_blit1tilemap_addr0 <= BLIT1TILEMAP_ADDR0_INIT;
_q_characterGenerator8x8_addr0 <= CHARACTERGENERATOR8X8_ADDR0_INIT;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_gpu_active_x <= _d_gpu_active_x;
_q_gpu_active_y <= _d_gpu_active_y;
_q_gpu_x1 <= _d_gpu_x1;
_q_gpu_y1 <= _d_gpu_y1;
_q_gpu_y2 <= _d_gpu_y2;
_q_gpu_param1 <= _d_gpu_param1;
_q_gpu_max_x <= _d_gpu_max_x;
_q_gpu_max_y <= _d_gpu_max_y;
_q_gpu_tile <= _d_gpu_tile;
_q_active <= _d_active;
_q_bitmap_x_write <= _d_bitmap_x_write;
_q_bitmap_y_write <= _d_bitmap_y_write;
_q_bitmap_write <= _d_bitmap_write;
_q_busy <= _d_busy;
_q_blit1tilemap_addr0 <= _d_blit1tilemap_addr0;
_q_characterGenerator8x8_addr0 <= _d_characterGenerator8x8_addr0;
_q_index <= _d_index;
  end
end




always @* begin
_d_gpu_active_x = _q_gpu_active_x;
_d_gpu_active_y = _q_gpu_active_y;
_d_gpu_x1 = _q_gpu_x1;
_d_gpu_y1 = _q_gpu_y1;
_d_gpu_y2 = _q_gpu_y2;
_d_gpu_param1 = _q_gpu_param1;
_d_gpu_max_x = _q_gpu_max_x;
_d_gpu_max_y = _q_gpu_max_y;
_d_gpu_tile = _q_gpu_tile;
_d_active = _q_active;
_d_bitmap_x_write = _q_bitmap_x_write;
_d_bitmap_y_write = _q_bitmap_y_write;
_d_bitmap_write = _q_bitmap_write;
_d_busy = _q_busy;
_d_blit1tilemap_addr0 = _q_blit1tilemap_addr0;
_d_characterGenerator8x8_addr0 = _q_characterGenerator8x8_addr0;
_d_index = _q_index;
// _always_pre
_d_busy = in_start?1:_q_active;
_d_blit1tilemap_addr0 = _q_gpu_tile*16+_q_gpu_active_y;
_d_characterGenerator8x8_addr0 = _q_gpu_tile*8+_q_gpu_active_y;
_d_bitmap_x_write = _q_gpu_x1+_q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_y1+(_q_gpu_active_y<<_q_gpu_param1)+_q_gpu_y2;
_d_bitmap_write = 0;
_d_index = 10;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_active = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_start) begin
// __block_5
// __block_7
_d_active = 1;
_d_gpu_active_x = 0;
_d_gpu_active_y = 0;
// __block_8_copycoordinates
// __block_9
_d_gpu_x1 = in_x;
_d_gpu_y1 = in_y;
// __block_10
// __block_11
_d_gpu_param1 = in_param1;
_d_gpu_max_x = (in_tilecharacter?16:8)<<(in_param1&3);
_d_gpu_max_y = in_tilecharacter?16:8;
_d_gpu_tile = in_param0;
_d_index = 3;
end else begin
// __block_6
_d_index = 1;
end
end else begin
_d_index = 2;
end
end
3: begin
// __block_12
_d_index = 4;
end
2: begin
// __block_3
_d_index = 10;
end
4: begin
// __while__block_13
if (_q_gpu_active_y<_q_gpu_max_y) begin
// __block_14
// __block_16
_d_index = 6;
end else begin
_d_index = 5;
end
end
6: begin
// __while__block_17
if (_q_gpu_active_x<_q_gpu_max_x) begin
// __block_18
// __block_20
_d_index = 8;
end else begin
_d_index = 7;
end
end
5: begin
// __block_15
_d_active = 0;
// __block_28
_d_index = 1;
end
8: begin
// __while__block_21
if (_q_gpu_y2<(1<<_q_gpu_param1)) begin
// __block_22
// __block_24
_d_bitmap_write = in_tilecharacter?in_blit1tilemap_rdata0[15-(_q_gpu_active_x>>_q_gpu_param1)+:1]:in_characterGenerator8x8_rdata0[7-(_q_gpu_active_x>>_q_gpu_param1)+:1];
_d_gpu_y2 = _q_gpu_y2+1;
// __block_25
_d_index = 8;
end else begin
_d_index = 9;
end
end
7: begin
// __block_19
_d_gpu_active_x = 0;
_d_gpu_active_y = _q_gpu_active_y+1;
// __block_27
_d_index = 4;
end
9: begin
// __block_23
_d_gpu_active_x = _q_gpu_active_x+1;
_d_gpu_y2 = 0;
// __block_26
_d_index = 6;
end
10: begin // end of blit
end
default: begin 
_d_index = 10;
 end
endcase
end
endmodule


module M_vectors_mem_vertex(
input      [8:0]                in_vertex_addr0,
output reg  [12:0]     out_vertex_rdata0,
output reg  [12:0]     out_vertex_rdata1,
input      [0:0]             in_vertex_wenable1,
input      [12:0]                 in_vertex_wdata1,
input      [8:0]                in_vertex_addr1,
input      clock0,
input      clock1
);
reg  [12:0] buffer[511:0];
always @(posedge clock0) begin
  out_vertex_rdata0 <= buffer[in_vertex_addr0];
end
always @(posedge clock1) begin
  if (in_vertex_wenable1) begin
    buffer[in_vertex_addr1] <= in_vertex_wdata1;
  end
end

endmodule

module M_vectors (
in_vector_block_number,
in_vector_block_xc,
in_vector_block_yc,
in_draw_vector,
in_vertices_writer_block,
in_vertices_writer_vertex,
in_vertices_writer_xdelta,
in_vertices_writer_ydelta,
in_vertices_writer_active,
in_gpu_active,
out_vector_block_active,
out_gpu_x,
out_gpu_y,
out_gpu_param0,
out_gpu_param1,
out_gpu_write,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [4:0] in_vector_block_number;
input signed [10:0] in_vector_block_xc;
input signed [10:0] in_vector_block_yc;
input  [0:0] in_draw_vector;
input  [4:0] in_vertices_writer_block;
input  [5:0] in_vertices_writer_vertex;
input signed [5:0] in_vertices_writer_xdelta;
input signed [5:0] in_vertices_writer_ydelta;
input  [0:0] in_vertices_writer_active;
input  [0:0] in_gpu_active;
output  [0:0] out_vector_block_active;
output signed [10:0] out_gpu_x;
output signed [10:0] out_gpu_y;
output signed [10:0] out_gpu_param0;
output signed [10:0] out_gpu_param1;
output  [0:0] out_gpu_write;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [12:0] _w_mem_vertex_rdata0;
wire signed [10:0] _w_deltax;
wire signed [10:0] _w_deltay;

reg  [8:0] _d_vertex_addr0;
reg  [8:0] _q_vertex_addr0;
reg  [0:0] _d_vertex_wenable1;
reg  [0:0] _q_vertex_wenable1;
reg  [12:0] _d_vertex_wdata1;
reg  [12:0] _q_vertex_wdata1;
reg  [8:0] _d_vertex_addr1;
reg  [8:0] _q_vertex_addr1;
reg  [4:0] _d_block_number;
reg  [4:0] _q_block_number;
reg  [4:0] _d_vertices_number;
reg  [4:0] _q_vertices_number;
reg signed [10:0] _d_start_x;
reg signed [10:0] _q_start_x;
reg signed [10:0] _d_start_y;
reg signed [10:0] _q_start_y;
reg  [0:0] _d_vector_block_active,_q_vector_block_active;
reg signed [10:0] _d_gpu_x,_q_gpu_x;
reg signed [10:0] _d_gpu_y,_q_gpu_y;
reg signed [10:0] _d_gpu_param0,_q_gpu_param0;
reg signed [10:0] _d_gpu_param1,_q_gpu_param1;
reg  [0:0] _d_gpu_write,_q_gpu_write;
reg  [3:0] _d_index,_q_index;
assign out_vector_block_active = _q_vector_block_active;
assign out_gpu_x = _q_gpu_x;
assign out_gpu_y = _q_gpu_y;
assign out_gpu_param0 = _q_gpu_param0;
assign out_gpu_param1 = _q_gpu_param1;
assign out_gpu_write = _q_gpu_write;
assign out_done = (_q_index == 10);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_vertex_addr0 <= 0;
_q_vertex_wenable1 <= 0;
_q_vertex_wdata1 <= 0;
_q_vertex_addr1 <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_vertex_addr0 <= _d_vertex_addr0;
_q_vertex_wenable1 <= _d_vertex_wenable1;
_q_vertex_wdata1 <= _d_vertex_wdata1;
_q_vertex_addr1 <= _d_vertex_addr1;
_q_block_number <= _d_block_number;
_q_vertices_number <= _d_vertices_number;
_q_start_x <= _d_start_x;
_q_start_y <= _d_start_y;
_q_vector_block_active <= _d_vector_block_active;
_q_gpu_x <= _d_gpu_x;
_q_gpu_y <= _d_gpu_y;
_q_gpu_param0 <= _d_gpu_param0;
_q_gpu_param1 <= _d_gpu_param1;
_q_gpu_write <= _d_gpu_write;
_q_index <= _d_index;
  end
end


M_vectors_mem_vertex __mem__vertex(
.clock0(clock),
.clock1(clock),
.in_vertex_addr0(_d_vertex_addr0),
.in_vertex_wenable1(_d_vertex_wenable1),
.in_vertex_wdata1(_d_vertex_wdata1),
.in_vertex_addr1(_d_vertex_addr1),
.out_vertex_rdata0(_w_mem_vertex_rdata0)
);

assign _w_deltay = {{6{_w_mem_vertex_rdata0[5+:1]}},_w_mem_vertex_rdata0[0+:5]};
assign _w_deltax = {{6{_w_mem_vertex_rdata0[11+:1]}},_w_mem_vertex_rdata0[6+:5]};

always @* begin
_d_vertex_addr0 = _q_vertex_addr0;
_d_vertex_wenable1 = _q_vertex_wenable1;
_d_vertex_wdata1 = _q_vertex_wdata1;
_d_vertex_addr1 = _q_vertex_addr1;
_d_block_number = _q_block_number;
_d_vertices_number = _q_vertices_number;
_d_start_x = _q_start_x;
_d_start_y = _q_start_y;
_d_vector_block_active = _q_vector_block_active;
_d_gpu_x = _q_gpu_x;
_d_gpu_y = _q_gpu_y;
_d_gpu_param0 = _q_gpu_param0;
_d_gpu_param1 = _q_gpu_param1;
_d_gpu_write = _q_gpu_write;
_d_index = _q_index;
// _always_pre
_d_vertex_addr0 = _q_block_number*16+_q_vertices_number;
_d_vertex_addr1 = in_vertices_writer_block*16+in_vertices_writer_vertex;
_d_vertex_wdata1 = {in_vertices_writer_active,$unsigned(in_vertices_writer_xdelta),$unsigned(in_vertices_writer_ydelta)};
_d_vertex_wenable1 = 1;
_d_gpu_write = 0;
_d_index = 10;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_vertex_addr0 = 0;
_d_vertex_wenable1 = 0;
_d_vertex_wdata1 = 0;
_d_vertex_addr1 = 0;
// --
_d_vector_block_active = 0;
_d_vertices_number = 0;
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_draw_vector) begin
// __block_5
// __block_7
_d_block_number = in_vector_block_number;
_d_vertices_number = 0;
_d_vector_block_active = 1;
_d_index = 3;
end else begin
// __block_6
_d_index = 1;
end
end else begin
_d_index = 2;
end
end
3: begin
// __block_8
// __block_9_deltacoordinates
// __block_10
_d_start_x = in_vector_block_xc+_w_deltax;
_d_start_y = in_vector_block_yc+_w_deltay;
// __block_11
// __block_12
_d_vertices_number = 1;
_d_index = 4;
end
2: begin
// __block_3
_d_index = 10;
end
4: begin
// __block_13
_d_index = 5;
end
5: begin
// __while__block_14
if (_w_mem_vertex_rdata0[12+:1]&&(_q_vertices_number<16)) begin
// __block_15
// __block_17
// __block_18_copycoordinates
// __block_19
_d_gpu_x = _q_start_x;
_d_gpu_y = _q_start_y;
// __block_20
// __block_21
// __block_22_deltacoordinates
// __block_23
_d_gpu_param0 = in_vector_block_xc+_w_deltax;
_d_gpu_param1 = in_vector_block_yc+_w_deltay;
// __block_24
// __block_25
_d_index = 7;
end else begin
_d_index = 6;
end
end
7: begin
// __while__block_26
if (in_gpu_active) begin
// __block_27
// __block_29
// __block_30
_d_index = 7;
end else begin
_d_index = 8;
end
end
6: begin
// __block_16
_d_vector_block_active = 0;
// __block_37
_d_index = 1;
end
8: begin
// __block_28
_d_gpu_write = 1;
// __block_31_deltacoordinates
// __block_32
_d_start_x = in_vector_block_xc+_w_deltax;
_d_start_y = in_vector_block_yc+_w_deltay;
// __block_33
// __block_34
_d_vertices_number = _q_vertices_number+1;
_d_index = 9;
end
9: begin
// __block_35
// __block_36
_d_index = 5;
end
10: begin // end of vectors
end
default: begin 
_d_index = 10;
 end
endcase
end
endmodule


module M_background (
in_pix_x,
in_pix_y,
in_pix_active,
in_pix_vblank,
in_staticGenerator,
in_backgroundcolour,
in_backgroundcolour_alt,
in_backgroundcolour_mode,
out_pix_red,
out_pix_green,
out_pix_blue,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [9:0] in_pix_x;
input  [9:0] in_pix_y;
input  [0:0] in_pix_active;
input  [0:0] in_pix_vblank;
input  [15:0] in_staticGenerator;
input  [5:0] in_backgroundcolour;
input  [5:0] in_backgroundcolour_alt;
input  [3:0] in_backgroundcolour_mode;
output  [1:0] out_pix_red;
output  [1:0] out_pix_green;
output  [1:0] out_pix_blue;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
reg signed [9:0] _t_dotpos;
reg signed [1:0] _t_speed;

reg signed [11:0] _d_rand_x;
reg signed [11:0] _q_rand_x;
reg signed [31:0] _d_frame;
reg signed [31:0] _q_frame;
reg  [1:0] _d_pix_red,_q_pix_red;
reg  [1:0] _d_pix_green,_q_pix_green;
reg  [1:0] _d_pix_blue,_q_pix_blue;
reg  [1:0] _d_index,_q_index;
assign out_pix_red = _d_pix_red;
assign out_pix_green = _d_pix_green;
assign out_pix_blue = _d_pix_blue;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_rand_x <= 0;
_q_frame <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_rand_x <= _d_rand_x;
_q_frame <= _d_frame;
_q_pix_red <= _d_pix_red;
_q_pix_green <= _d_pix_green;
_q_pix_blue <= _d_pix_blue;
_q_index <= _d_index;
  end
end




always @* begin
_d_rand_x = _q_rand_x;
_d_frame = _q_frame;
_d_pix_red = _q_pix_red;
_d_pix_green = _q_pix_green;
_d_pix_blue = _q_pix_blue;
_d_index = _q_index;
_t_dotpos = 0;
_t_speed = 0;
// _always_pre
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_t_dotpos = 0;
_t_speed = 0;
_d_rand_x = 0;
_d_frame = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
_d_frame = ((in_pix_x==639)&&(in_pix_y==470))?_q_frame+1:_q_frame;
if (in_pix_active) begin
// __block_5
// __block_7
  case (in_backgroundcolour_mode)
  0: begin
// __block_9_case
// __block_10
_d_pix_red = in_backgroundcolour[4+:2];
_d_pix_green = in_backgroundcolour[2+:2];
_d_pix_blue = in_backgroundcolour[0+:2];
// __block_11
  end
  1: begin
// __block_12_case
// __block_13
_d_pix_red = (in_pix_y<240)?in_backgroundcolour[4+:2]:in_backgroundcolour_alt[4+:2];
_d_pix_green = (in_pix_y<240)?in_backgroundcolour[2+:2]:in_backgroundcolour_alt[2+:2];
_d_pix_blue = (in_pix_y<240)?in_backgroundcolour[0+:2]:in_backgroundcolour_alt[0+:2];
// __block_14
  end
  2: begin
// __block_15_case
// __block_16
_d_pix_red = (in_pix_x<320)?in_backgroundcolour[4+:2]:in_backgroundcolour_alt[4+:2];
_d_pix_green = (in_pix_x<320)?in_backgroundcolour[2+:2]:in_backgroundcolour_alt[2+:2];
_d_pix_blue = (in_pix_x<320)?in_backgroundcolour[0+:2]:in_backgroundcolour_alt[0+:2];
// __block_17
  end
  3: begin
// __block_18_case
// __block_19
if (in_pix_x<320) begin
// __block_20
// __block_22
_d_pix_red = (in_pix_y<240)?in_backgroundcolour[4+:2]:in_backgroundcolour_alt[4+:2];
_d_pix_green = (in_pix_y<240)?in_backgroundcolour[2+:2]:in_backgroundcolour_alt[2+:2];
_d_pix_blue = (in_pix_y<240)?in_backgroundcolour[0+:2]:in_backgroundcolour_alt[0+:2];
// __block_23
end else begin
// __block_21
// __block_24
_d_pix_red = (in_pix_y>=240)?in_backgroundcolour[4+:2]:in_backgroundcolour_alt[4+:2];
_d_pix_green = (in_pix_y>=240)?in_backgroundcolour[2+:2]:in_backgroundcolour_alt[2+:2];
_d_pix_blue = (in_pix_y>=240)?in_backgroundcolour[0+:2]:in_backgroundcolour_alt[0+:2];
// __block_25
end
// __block_26
// __block_27
  end
  4: begin
// __block_28_case
// __block_29
  case (in_pix_y[6+:3])
  3'b000: begin
// __block_31_case
// __block_32
_d_pix_red = 2;
_d_pix_green = 0;
_d_pix_blue = 0;
// __block_33
  end
  3'b001: begin
// __block_34_case
// __block_35
_d_pix_red = 3;
_d_pix_green = 0;
_d_pix_blue = 0;
// __block_36
  end
  3'b010: begin
// __block_37_case
// __block_38
_d_pix_red = 3;
_d_pix_green = 2;
_d_pix_blue = 0;
// __block_39
  end
  3'b011: begin
// __block_40_case
// __block_41
_d_pix_red = 3;
_d_pix_green = 3;
_d_pix_blue = 0;
// __block_42
  end
  3'b100: begin
// __block_43_case
// __block_44
_d_pix_red = 0;
_d_pix_green = 3;
_d_pix_blue = 0;
// __block_45
  end
  3'b101: begin
// __block_46_case
// __block_47
_d_pix_red = 0;
_d_pix_green = 0;
_d_pix_blue = 3;
// __block_48
  end
  3'b110: begin
// __block_49_case
// __block_50
_d_pix_red = 1;
_d_pix_green = 0;
_d_pix_blue = 2;
// __block_51
  end
  3'b111: begin
// __block_52_case
// __block_53
_d_pix_red = 1;
_d_pix_green = 2;
_d_pix_blue = 3;
// __block_54
  end
endcase
// __block_30
// __block_55
  end
  5: begin
// __block_56_case
// __block_57
_d_rand_x = (in_pix_x==0)?1:_q_rand_x*31421+6927;
_t_speed = _d_rand_x[10+:2];
_t_dotpos = (_d_frame>>_t_speed)+_d_rand_x;
_d_pix_red = (in_pix_y==_t_dotpos)?in_backgroundcolour[4+:2]:in_backgroundcolour_alt[4+:2];
_d_pix_green = (in_pix_y==_t_dotpos)?in_backgroundcolour[2+:2]:in_backgroundcolour_alt[2+:2];
_d_pix_blue = (in_pix_y==_t_dotpos)?in_backgroundcolour[0+:2]:in_backgroundcolour_alt[0+:2];
// __block_58
  end
  6: begin
// __block_59_case
// __block_60
_d_pix_red = in_staticGenerator;
_d_pix_green = in_staticGenerator;
_d_pix_blue = in_staticGenerator;
// __block_61
  end
  default: begin
// __block_62_case
// __block_63
  case ({in_pix_x[in_backgroundcolour_mode-7+:1],in_pix_y[in_backgroundcolour_mode-7+:1]})
  2'b00: begin
// __block_65_case
// __block_66
_d_pix_red = in_backgroundcolour[4+:2];
_d_pix_green = in_backgroundcolour[2+:2];
_d_pix_blue = in_backgroundcolour[0+:2];
// __block_67
  end
  2'b01: begin
// __block_68_case
// __block_69
_d_pix_red = in_backgroundcolour_alt[4+:2];
_d_pix_green = in_backgroundcolour_alt[2+:2];
_d_pix_blue = in_backgroundcolour_alt[0+:2];
// __block_70
  end
  2'b10: begin
// __block_71_case
// __block_72
_d_pix_red = in_backgroundcolour_alt[4+:2];
_d_pix_green = in_backgroundcolour_alt[2+:2];
_d_pix_blue = in_backgroundcolour_alt[0+:2];
// __block_73
  end
  2'b11: begin
// __block_74_case
// __block_75
_d_pix_red = in_backgroundcolour[4+:2];
_d_pix_green = in_backgroundcolour[2+:2];
_d_pix_blue = in_backgroundcolour[0+:2];
// __block_76
  end
endcase
// __block_64
// __block_77
  end
endcase
// __block_8
// __block_78
end else begin
// __block_6
end
// __block_79
// __block_80
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of background
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_sprite_layer_mem_tiles_0(
input      [6:0]                in_tiles_0_addr0,
output reg  [15:0]     out_tiles_0_rdata0,
output reg  [15:0]     out_tiles_0_rdata1,
input      [0:0]             in_tiles_0_wenable1,
input      [15:0]                 in_tiles_0_wdata1,
input      [6:0]                in_tiles_0_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_0_rdata0 <= buffer[in_tiles_0_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_0_wenable1) begin
    buffer[in_tiles_0_addr1] <= in_tiles_0_wdata1;
  end
end

endmodule

module M_sprite_layer_mem_tiles_1(
input      [6:0]                in_tiles_1_addr0,
output reg  [15:0]     out_tiles_1_rdata0,
output reg  [15:0]     out_tiles_1_rdata1,
input      [0:0]             in_tiles_1_wenable1,
input      [15:0]                 in_tiles_1_wdata1,
input      [6:0]                in_tiles_1_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_1_rdata0 <= buffer[in_tiles_1_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_1_wenable1) begin
    buffer[in_tiles_1_addr1] <= in_tiles_1_wdata1;
  end
end

endmodule

module M_sprite_layer_mem_tiles_2(
input      [6:0]                in_tiles_2_addr0,
output reg  [15:0]     out_tiles_2_rdata0,
output reg  [15:0]     out_tiles_2_rdata1,
input      [0:0]             in_tiles_2_wenable1,
input      [15:0]                 in_tiles_2_wdata1,
input      [6:0]                in_tiles_2_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_2_rdata0 <= buffer[in_tiles_2_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_2_wenable1) begin
    buffer[in_tiles_2_addr1] <= in_tiles_2_wdata1;
  end
end

endmodule

module M_sprite_layer_mem_tiles_3(
input      [6:0]                in_tiles_3_addr0,
output reg  [15:0]     out_tiles_3_rdata0,
output reg  [15:0]     out_tiles_3_rdata1,
input      [0:0]             in_tiles_3_wenable1,
input      [15:0]                 in_tiles_3_wdata1,
input      [6:0]                in_tiles_3_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_3_rdata0 <= buffer[in_tiles_3_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_3_wenable1) begin
    buffer[in_tiles_3_addr1] <= in_tiles_3_wdata1;
  end
end

endmodule

module M_sprite_layer_mem_tiles_4(
input      [6:0]                in_tiles_4_addr0,
output reg  [15:0]     out_tiles_4_rdata0,
output reg  [15:0]     out_tiles_4_rdata1,
input      [0:0]             in_tiles_4_wenable1,
input      [15:0]                 in_tiles_4_wdata1,
input      [6:0]                in_tiles_4_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_4_rdata0 <= buffer[in_tiles_4_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_4_wenable1) begin
    buffer[in_tiles_4_addr1] <= in_tiles_4_wdata1;
  end
end

endmodule

module M_sprite_layer_mem_tiles_5(
input      [6:0]                in_tiles_5_addr0,
output reg  [15:0]     out_tiles_5_rdata0,
output reg  [15:0]     out_tiles_5_rdata1,
input      [0:0]             in_tiles_5_wenable1,
input      [15:0]                 in_tiles_5_wdata1,
input      [6:0]                in_tiles_5_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_5_rdata0 <= buffer[in_tiles_5_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_5_wenable1) begin
    buffer[in_tiles_5_addr1] <= in_tiles_5_wdata1;
  end
end

endmodule

module M_sprite_layer_mem_tiles_6(
input      [6:0]                in_tiles_6_addr0,
output reg  [15:0]     out_tiles_6_rdata0,
output reg  [15:0]     out_tiles_6_rdata1,
input      [0:0]             in_tiles_6_wenable1,
input      [15:0]                 in_tiles_6_wdata1,
input      [6:0]                in_tiles_6_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_6_rdata0 <= buffer[in_tiles_6_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_6_wenable1) begin
    buffer[in_tiles_6_addr1] <= in_tiles_6_wdata1;
  end
end

endmodule

module M_sprite_layer_mem_tiles_7(
input      [6:0]                in_tiles_7_addr0,
output reg  [15:0]     out_tiles_7_rdata0,
output reg  [15:0]     out_tiles_7_rdata1,
input      [0:0]             in_tiles_7_wenable1,
input      [15:0]                 in_tiles_7_wdata1,
input      [6:0]                in_tiles_7_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_7_rdata0 <= buffer[in_tiles_7_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_7_wenable1) begin
    buffer[in_tiles_7_addr1] <= in_tiles_7_wdata1;
  end
end

endmodule

module M_sprite_layer_mem_tiles_8(
input      [6:0]                in_tiles_8_addr0,
output reg  [15:0]     out_tiles_8_rdata0,
output reg  [15:0]     out_tiles_8_rdata1,
input      [0:0]             in_tiles_8_wenable1,
input      [15:0]                 in_tiles_8_wdata1,
input      [6:0]                in_tiles_8_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_8_rdata0 <= buffer[in_tiles_8_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_8_wenable1) begin
    buffer[in_tiles_8_addr1] <= in_tiles_8_wdata1;
  end
end

endmodule

module M_sprite_layer_mem_tiles_9(
input      [6:0]                in_tiles_9_addr0,
output reg  [15:0]     out_tiles_9_rdata0,
output reg  [15:0]     out_tiles_9_rdata1,
input      [0:0]             in_tiles_9_wenable1,
input      [15:0]                 in_tiles_9_wdata1,
input      [6:0]                in_tiles_9_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_9_rdata0 <= buffer[in_tiles_9_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_9_wenable1) begin
    buffer[in_tiles_9_addr1] <= in_tiles_9_wdata1;
  end
end

endmodule

module M_sprite_layer_mem_tiles_10(
input      [6:0]                in_tiles_10_addr0,
output reg  [15:0]     out_tiles_10_rdata0,
output reg  [15:0]     out_tiles_10_rdata1,
input      [0:0]             in_tiles_10_wenable1,
input      [15:0]                 in_tiles_10_wdata1,
input      [6:0]                in_tiles_10_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_10_rdata0 <= buffer[in_tiles_10_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_10_wenable1) begin
    buffer[in_tiles_10_addr1] <= in_tiles_10_wdata1;
  end
end

endmodule

module M_sprite_layer_mem_tiles_11(
input      [6:0]                in_tiles_11_addr0,
output reg  [15:0]     out_tiles_11_rdata0,
output reg  [15:0]     out_tiles_11_rdata1,
input      [0:0]             in_tiles_11_wenable1,
input      [15:0]                 in_tiles_11_wdata1,
input      [6:0]                in_tiles_11_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_11_rdata0 <= buffer[in_tiles_11_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_11_wenable1) begin
    buffer[in_tiles_11_addr1] <= in_tiles_11_wdata1;
  end
end

endmodule

module M_sprite_layer_mem_tiles_12(
input      [6:0]                in_tiles_12_addr0,
output reg  [15:0]     out_tiles_12_rdata0,
output reg  [15:0]     out_tiles_12_rdata1,
input      [0:0]             in_tiles_12_wenable1,
input      [15:0]                 in_tiles_12_wdata1,
input      [6:0]                in_tiles_12_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  out_tiles_12_rdata0 <= buffer[in_tiles_12_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_12_wenable1) begin
    buffer[in_tiles_12_addr1] <= in_tiles_12_wdata1;
  end
end

endmodule

module M_sprite_layer (
in_pix_x,
in_pix_y,
in_pix_active,
in_pix_vblank,
in_sprite_set_number,
in_sprite_set_active,
in_sprite_set_double,
in_sprite_set_colour,
in_sprite_set_x,
in_sprite_set_y,
in_sprite_set_tile,
in_sprite_layer_write,
in_sprite_update,
in_collision_layer_1,
in_collision_layer_2,
in_collision_layer_3,
in_sprite_writer_sprite,
in_sprite_writer_line,
in_sprite_writer_bitmap,
in_sprite_writer_active,
out_pix_red,
out_pix_green,
out_pix_blue,
out_sprite_layer_display,
out_sprite_read_active,
out_sprite_read_double,
out_sprite_read_colour,
out_sprite_read_x,
out_sprite_read_y,
out_sprite_read_tile,
out_collision_0,
out_collision_1,
out_collision_2,
out_collision_3,
out_collision_4,
out_collision_5,
out_collision_6,
out_collision_7,
out_collision_8,
out_collision_9,
out_collision_10,
out_collision_11,
out_collision_12,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [9:0] in_pix_x;
input  [9:0] in_pix_y;
input  [0:0] in_pix_active;
input  [0:0] in_pix_vblank;
input  [3:0] in_sprite_set_number;
input  [0:0] in_sprite_set_active;
input  [0:0] in_sprite_set_double;
input  [5:0] in_sprite_set_colour;
input signed [10:0] in_sprite_set_x;
input signed [10:0] in_sprite_set_y;
input  [2:0] in_sprite_set_tile;
input  [3:0] in_sprite_layer_write;
input  [15:0] in_sprite_update;
input  [0:0] in_collision_layer_1;
input  [0:0] in_collision_layer_2;
input  [0:0] in_collision_layer_3;
input  [3:0] in_sprite_writer_sprite;
input  [6:0] in_sprite_writer_line;
input  [15:0] in_sprite_writer_bitmap;
input  [0:0] in_sprite_writer_active;
output  [1:0] out_pix_red;
output  [1:0] out_pix_green;
output  [1:0] out_pix_blue;
output  [0:0] out_sprite_layer_display;
output  [0:0] out_sprite_read_active;
output  [0:0] out_sprite_read_double;
output  [5:0] out_sprite_read_colour;
output signed [10:0] out_sprite_read_x;
output signed [10:0] out_sprite_read_y;
output  [2:0] out_sprite_read_tile;
output  [15:0] out_collision_0;
output  [15:0] out_collision_1;
output  [15:0] out_collision_2;
output  [15:0] out_collision_3;
output  [15:0] out_collision_4;
output  [15:0] out_collision_5;
output  [15:0] out_collision_6;
output  [15:0] out_collision_7;
output  [15:0] out_collision_8;
output  [15:0] out_collision_9;
output  [15:0] out_collision_10;
output  [15:0] out_collision_11;
output  [15:0] out_collision_12;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [15:0] _w_mem_tiles_0_rdata0;
wire  [15:0] _w_mem_tiles_1_rdata0;
wire  [15:0] _w_mem_tiles_2_rdata0;
wire  [15:0] _w_mem_tiles_3_rdata0;
wire  [15:0] _w_mem_tiles_4_rdata0;
wire  [15:0] _w_mem_tiles_5_rdata0;
wire  [15:0] _w_mem_tiles_6_rdata0;
wire  [15:0] _w_mem_tiles_7_rdata0;
wire  [15:0] _w_mem_tiles_8_rdata0;
wire  [15:0] _w_mem_tiles_9_rdata0;
wire  [15:0] _w_mem_tiles_10_rdata0;
wire  [15:0] _w_mem_tiles_11_rdata0;
wire  [15:0] _w_mem_tiles_12_rdata0;
wire  [5:0] _w_spritesize_0;
wire  [0:0] _w_xinrange_0;
wire  [0:0] _w_yinrange_0;
wire  [0:0] _w_pix_visible_0;
wire  [5:0] _w_spritesize_1;
wire  [0:0] _w_xinrange_1;
wire  [0:0] _w_yinrange_1;
wire  [0:0] _w_pix_visible_1;
wire  [5:0] _w_spritesize_2;
wire  [0:0] _w_xinrange_2;
wire  [0:0] _w_yinrange_2;
wire  [0:0] _w_pix_visible_2;
wire  [5:0] _w_spritesize_3;
wire  [0:0] _w_xinrange_3;
wire  [0:0] _w_yinrange_3;
wire  [0:0] _w_pix_visible_3;
wire  [5:0] _w_spritesize_4;
wire  [0:0] _w_xinrange_4;
wire  [0:0] _w_yinrange_4;
wire  [0:0] _w_pix_visible_4;
wire  [5:0] _w_spritesize_5;
wire  [0:0] _w_xinrange_5;
wire  [0:0] _w_yinrange_5;
wire  [0:0] _w_pix_visible_5;
wire  [5:0] _w_spritesize_6;
wire  [0:0] _w_xinrange_6;
wire  [0:0] _w_yinrange_6;
wire  [0:0] _w_pix_visible_6;
wire  [5:0] _w_spritesize_7;
wire  [0:0] _w_xinrange_7;
wire  [0:0] _w_yinrange_7;
wire  [0:0] _w_pix_visible_7;
wire  [5:0] _w_spritesize_8;
wire  [0:0] _w_xinrange_8;
wire  [0:0] _w_yinrange_8;
wire  [0:0] _w_pix_visible_8;
wire  [5:0] _w_spritesize_9;
wire  [0:0] _w_xinrange_9;
wire  [0:0] _w_yinrange_9;
wire  [0:0] _w_pix_visible_9;
wire  [5:0] _w_spritesize_10;
wire  [0:0] _w_xinrange_10;
wire  [0:0] _w_yinrange_10;
wire  [0:0] _w_pix_visible_10;
wire  [5:0] _w_spritesize_11;
wire  [0:0] _w_xinrange_11;
wire  [0:0] _w_yinrange_11;
wire  [0:0] _w_pix_visible_11;
wire  [5:0] _w_spritesize_12;
wire  [0:0] _w_xinrange_12;
wire  [0:0] _w_yinrange_12;
wire  [0:0] _w_pix_visible_12;
wire signed [10:0] _w_deltax;
wire signed [10:0] _w_deltay;
wire signed [10:0] _w_sprite_offscreen_negative;
wire signed [10:0] _w_sprite_to_negative;
wire  [0:0] _w_sprite_offscreen_x;
wire  [0:0] _w_sprite_offscreen_y;

reg  [0:0] _d_sprite_active[12:0];
reg  [0:0] _q_sprite_active[12:0];
reg  [0:0] _d_sprite_double[12:0];
reg  [0:0] _q_sprite_double[12:0];
reg signed [10:0] _d_sprite_x[12:0];
reg signed [10:0] _q_sprite_x[12:0];
reg signed [10:0] _d_sprite_y[12:0];
reg signed [10:0] _q_sprite_y[12:0];
reg  [5:0] _d_sprite_colour[12:0];
reg  [5:0] _q_sprite_colour[12:0];
reg  [2:0] _d_sprite_tile_number[12:0];
reg  [2:0] _q_sprite_tile_number[12:0];
reg  [0:0] _d_output_collisions;
reg  [0:0] _q_output_collisions;
reg  [6:0] _d_tiles_0_addr0;
reg  [6:0] _q_tiles_0_addr0;
reg  [0:0] _d_tiles_0_wenable1;
reg  [0:0] _q_tiles_0_wenable1;
reg  [15:0] _d_tiles_0_wdata1;
reg  [15:0] _q_tiles_0_wdata1;
reg  [6:0] _d_tiles_0_addr1;
reg  [6:0] _q_tiles_0_addr1;
reg  [15:0] _d_detect_collision_0;
reg  [15:0] _q_detect_collision_0;
reg  [6:0] _d_tiles_1_addr0;
reg  [6:0] _q_tiles_1_addr0;
reg  [0:0] _d_tiles_1_wenable1;
reg  [0:0] _q_tiles_1_wenable1;
reg  [15:0] _d_tiles_1_wdata1;
reg  [15:0] _q_tiles_1_wdata1;
reg  [6:0] _d_tiles_1_addr1;
reg  [6:0] _q_tiles_1_addr1;
reg  [15:0] _d_detect_collision_1;
reg  [15:0] _q_detect_collision_1;
reg  [6:0] _d_tiles_2_addr0;
reg  [6:0] _q_tiles_2_addr0;
reg  [0:0] _d_tiles_2_wenable1;
reg  [0:0] _q_tiles_2_wenable1;
reg  [15:0] _d_tiles_2_wdata1;
reg  [15:0] _q_tiles_2_wdata1;
reg  [6:0] _d_tiles_2_addr1;
reg  [6:0] _q_tiles_2_addr1;
reg  [15:0] _d_detect_collision_2;
reg  [15:0] _q_detect_collision_2;
reg  [6:0] _d_tiles_3_addr0;
reg  [6:0] _q_tiles_3_addr0;
reg  [0:0] _d_tiles_3_wenable1;
reg  [0:0] _q_tiles_3_wenable1;
reg  [15:0] _d_tiles_3_wdata1;
reg  [15:0] _q_tiles_3_wdata1;
reg  [6:0] _d_tiles_3_addr1;
reg  [6:0] _q_tiles_3_addr1;
reg  [15:0] _d_detect_collision_3;
reg  [15:0] _q_detect_collision_3;
reg  [6:0] _d_tiles_4_addr0;
reg  [6:0] _q_tiles_4_addr0;
reg  [0:0] _d_tiles_4_wenable1;
reg  [0:0] _q_tiles_4_wenable1;
reg  [15:0] _d_tiles_4_wdata1;
reg  [15:0] _q_tiles_4_wdata1;
reg  [6:0] _d_tiles_4_addr1;
reg  [6:0] _q_tiles_4_addr1;
reg  [15:0] _d_detect_collision_4;
reg  [15:0] _q_detect_collision_4;
reg  [6:0] _d_tiles_5_addr0;
reg  [6:0] _q_tiles_5_addr0;
reg  [0:0] _d_tiles_5_wenable1;
reg  [0:0] _q_tiles_5_wenable1;
reg  [15:0] _d_tiles_5_wdata1;
reg  [15:0] _q_tiles_5_wdata1;
reg  [6:0] _d_tiles_5_addr1;
reg  [6:0] _q_tiles_5_addr1;
reg  [15:0] _d_detect_collision_5;
reg  [15:0] _q_detect_collision_5;
reg  [6:0] _d_tiles_6_addr0;
reg  [6:0] _q_tiles_6_addr0;
reg  [0:0] _d_tiles_6_wenable1;
reg  [0:0] _q_tiles_6_wenable1;
reg  [15:0] _d_tiles_6_wdata1;
reg  [15:0] _q_tiles_6_wdata1;
reg  [6:0] _d_tiles_6_addr1;
reg  [6:0] _q_tiles_6_addr1;
reg  [15:0] _d_detect_collision_6;
reg  [15:0] _q_detect_collision_6;
reg  [6:0] _d_tiles_7_addr0;
reg  [6:0] _q_tiles_7_addr0;
reg  [0:0] _d_tiles_7_wenable1;
reg  [0:0] _q_tiles_7_wenable1;
reg  [15:0] _d_tiles_7_wdata1;
reg  [15:0] _q_tiles_7_wdata1;
reg  [6:0] _d_tiles_7_addr1;
reg  [6:0] _q_tiles_7_addr1;
reg  [15:0] _d_detect_collision_7;
reg  [15:0] _q_detect_collision_7;
reg  [6:0] _d_tiles_8_addr0;
reg  [6:0] _q_tiles_8_addr0;
reg  [0:0] _d_tiles_8_wenable1;
reg  [0:0] _q_tiles_8_wenable1;
reg  [15:0] _d_tiles_8_wdata1;
reg  [15:0] _q_tiles_8_wdata1;
reg  [6:0] _d_tiles_8_addr1;
reg  [6:0] _q_tiles_8_addr1;
reg  [15:0] _d_detect_collision_8;
reg  [15:0] _q_detect_collision_8;
reg  [6:0] _d_tiles_9_addr0;
reg  [6:0] _q_tiles_9_addr0;
reg  [0:0] _d_tiles_9_wenable1;
reg  [0:0] _q_tiles_9_wenable1;
reg  [15:0] _d_tiles_9_wdata1;
reg  [15:0] _q_tiles_9_wdata1;
reg  [6:0] _d_tiles_9_addr1;
reg  [6:0] _q_tiles_9_addr1;
reg  [15:0] _d_detect_collision_9;
reg  [15:0] _q_detect_collision_9;
reg  [6:0] _d_tiles_10_addr0;
reg  [6:0] _q_tiles_10_addr0;
reg  [0:0] _d_tiles_10_wenable1;
reg  [0:0] _q_tiles_10_wenable1;
reg  [15:0] _d_tiles_10_wdata1;
reg  [15:0] _q_tiles_10_wdata1;
reg  [6:0] _d_tiles_10_addr1;
reg  [6:0] _q_tiles_10_addr1;
reg  [15:0] _d_detect_collision_10;
reg  [15:0] _q_detect_collision_10;
reg  [6:0] _d_tiles_11_addr0;
reg  [6:0] _q_tiles_11_addr0;
reg  [0:0] _d_tiles_11_wenable1;
reg  [0:0] _q_tiles_11_wenable1;
reg  [15:0] _d_tiles_11_wdata1;
reg  [15:0] _q_tiles_11_wdata1;
reg  [6:0] _d_tiles_11_addr1;
reg  [6:0] _q_tiles_11_addr1;
reg  [15:0] _d_detect_collision_11;
reg  [15:0] _q_detect_collision_11;
reg  [6:0] _d_tiles_12_addr0;
reg  [6:0] _q_tiles_12_addr0;
reg  [0:0] _d_tiles_12_wenable1;
reg  [0:0] _q_tiles_12_wenable1;
reg  [15:0] _d_tiles_12_wdata1;
reg  [15:0] _q_tiles_12_wdata1;
reg  [6:0] _d_tiles_12_addr1;
reg  [6:0] _q_tiles_12_addr1;
reg  [15:0] _d_detect_collision_12;
reg  [15:0] _q_detect_collision_12;
reg  [1:0] _d_pix_red,_q_pix_red;
reg  [1:0] _d_pix_green,_q_pix_green;
reg  [1:0] _d_pix_blue,_q_pix_blue;
reg  [0:0] _d_sprite_layer_display,_q_sprite_layer_display;
reg  [0:0] _d_sprite_read_active,_q_sprite_read_active;
reg  [0:0] _d_sprite_read_double,_q_sprite_read_double;
reg  [5:0] _d_sprite_read_colour,_q_sprite_read_colour;
reg signed [10:0] _d_sprite_read_x,_q_sprite_read_x;
reg signed [10:0] _d_sprite_read_y,_q_sprite_read_y;
reg  [2:0] _d_sprite_read_tile,_q_sprite_read_tile;
reg  [15:0] _d_collision_0,_q_collision_0;
reg  [15:0] _d_collision_1,_q_collision_1;
reg  [15:0] _d_collision_2,_q_collision_2;
reg  [15:0] _d_collision_3,_q_collision_3;
reg  [15:0] _d_collision_4,_q_collision_4;
reg  [15:0] _d_collision_5,_q_collision_5;
reg  [15:0] _d_collision_6,_q_collision_6;
reg  [15:0] _d_collision_7,_q_collision_7;
reg  [15:0] _d_collision_8,_q_collision_8;
reg  [15:0] _d_collision_9,_q_collision_9;
reg  [15:0] _d_collision_10,_q_collision_10;
reg  [15:0] _d_collision_11,_q_collision_11;
reg  [15:0] _d_collision_12,_q_collision_12;
reg  [1:0] _d_index,_q_index;
assign out_pix_red = _d_pix_red;
assign out_pix_green = _d_pix_green;
assign out_pix_blue = _d_pix_blue;
assign out_sprite_layer_display = _d_sprite_layer_display;
assign out_sprite_read_active = _q_sprite_read_active;
assign out_sprite_read_double = _q_sprite_read_double;
assign out_sprite_read_colour = _q_sprite_read_colour;
assign out_sprite_read_x = _q_sprite_read_x;
assign out_sprite_read_y = _q_sprite_read_y;
assign out_sprite_read_tile = _q_sprite_read_tile;
assign out_collision_0 = _q_collision_0;
assign out_collision_1 = _q_collision_1;
assign out_collision_2 = _q_collision_2;
assign out_collision_3 = _q_collision_3;
assign out_collision_4 = _q_collision_4;
assign out_collision_5 = _q_collision_5;
assign out_collision_6 = _q_collision_6;
assign out_collision_7 = _q_collision_7;
assign out_collision_8 = _q_collision_8;
assign out_collision_9 = _q_collision_9;
assign out_collision_10 = _q_collision_10;
assign out_collision_11 = _q_collision_11;
assign out_collision_12 = _q_collision_12;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_output_collisions <= 0;
_q_tiles_0_addr0 <= 0;
_q_tiles_0_wenable1 <= 0;
_q_tiles_0_wdata1 <= 0;
_q_tiles_0_addr1 <= 0;
_q_tiles_1_addr0 <= 0;
_q_tiles_1_wenable1 <= 0;
_q_tiles_1_wdata1 <= 0;
_q_tiles_1_addr1 <= 0;
_q_tiles_2_addr0 <= 0;
_q_tiles_2_wenable1 <= 0;
_q_tiles_2_wdata1 <= 0;
_q_tiles_2_addr1 <= 0;
_q_tiles_3_addr0 <= 0;
_q_tiles_3_wenable1 <= 0;
_q_tiles_3_wdata1 <= 0;
_q_tiles_3_addr1 <= 0;
_q_tiles_4_addr0 <= 0;
_q_tiles_4_wenable1 <= 0;
_q_tiles_4_wdata1 <= 0;
_q_tiles_4_addr1 <= 0;
_q_tiles_5_addr0 <= 0;
_q_tiles_5_wenable1 <= 0;
_q_tiles_5_wdata1 <= 0;
_q_tiles_5_addr1 <= 0;
_q_tiles_6_addr0 <= 0;
_q_tiles_6_wenable1 <= 0;
_q_tiles_6_wdata1 <= 0;
_q_tiles_6_addr1 <= 0;
_q_tiles_7_addr0 <= 0;
_q_tiles_7_wenable1 <= 0;
_q_tiles_7_wdata1 <= 0;
_q_tiles_7_addr1 <= 0;
_q_tiles_8_addr0 <= 0;
_q_tiles_8_wenable1 <= 0;
_q_tiles_8_wdata1 <= 0;
_q_tiles_8_addr1 <= 0;
_q_tiles_9_addr0 <= 0;
_q_tiles_9_wenable1 <= 0;
_q_tiles_9_wdata1 <= 0;
_q_tiles_9_addr1 <= 0;
_q_tiles_10_addr0 <= 0;
_q_tiles_10_wenable1 <= 0;
_q_tiles_10_wdata1 <= 0;
_q_tiles_10_addr1 <= 0;
_q_tiles_11_addr0 <= 0;
_q_tiles_11_wenable1 <= 0;
_q_tiles_11_wdata1 <= 0;
_q_tiles_11_addr1 <= 0;
_q_tiles_12_addr0 <= 0;
_q_tiles_12_wenable1 <= 0;
_q_tiles_12_wdata1 <= 0;
_q_tiles_12_addr1 <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_sprite_active[0] <= _d_sprite_active[0];
_q_sprite_active[1] <= _d_sprite_active[1];
_q_sprite_active[2] <= _d_sprite_active[2];
_q_sprite_active[3] <= _d_sprite_active[3];
_q_sprite_active[4] <= _d_sprite_active[4];
_q_sprite_active[5] <= _d_sprite_active[5];
_q_sprite_active[6] <= _d_sprite_active[6];
_q_sprite_active[7] <= _d_sprite_active[7];
_q_sprite_active[8] <= _d_sprite_active[8];
_q_sprite_active[9] <= _d_sprite_active[9];
_q_sprite_active[10] <= _d_sprite_active[10];
_q_sprite_active[11] <= _d_sprite_active[11];
_q_sprite_active[12] <= _d_sprite_active[12];
_q_sprite_double[0] <= _d_sprite_double[0];
_q_sprite_double[1] <= _d_sprite_double[1];
_q_sprite_double[2] <= _d_sprite_double[2];
_q_sprite_double[3] <= _d_sprite_double[3];
_q_sprite_double[4] <= _d_sprite_double[4];
_q_sprite_double[5] <= _d_sprite_double[5];
_q_sprite_double[6] <= _d_sprite_double[6];
_q_sprite_double[7] <= _d_sprite_double[7];
_q_sprite_double[8] <= _d_sprite_double[8];
_q_sprite_double[9] <= _d_sprite_double[9];
_q_sprite_double[10] <= _d_sprite_double[10];
_q_sprite_double[11] <= _d_sprite_double[11];
_q_sprite_double[12] <= _d_sprite_double[12];
_q_sprite_x[0] <= _d_sprite_x[0];
_q_sprite_x[1] <= _d_sprite_x[1];
_q_sprite_x[2] <= _d_sprite_x[2];
_q_sprite_x[3] <= _d_sprite_x[3];
_q_sprite_x[4] <= _d_sprite_x[4];
_q_sprite_x[5] <= _d_sprite_x[5];
_q_sprite_x[6] <= _d_sprite_x[6];
_q_sprite_x[7] <= _d_sprite_x[7];
_q_sprite_x[8] <= _d_sprite_x[8];
_q_sprite_x[9] <= _d_sprite_x[9];
_q_sprite_x[10] <= _d_sprite_x[10];
_q_sprite_x[11] <= _d_sprite_x[11];
_q_sprite_x[12] <= _d_sprite_x[12];
_q_sprite_y[0] <= _d_sprite_y[0];
_q_sprite_y[1] <= _d_sprite_y[1];
_q_sprite_y[2] <= _d_sprite_y[2];
_q_sprite_y[3] <= _d_sprite_y[3];
_q_sprite_y[4] <= _d_sprite_y[4];
_q_sprite_y[5] <= _d_sprite_y[5];
_q_sprite_y[6] <= _d_sprite_y[6];
_q_sprite_y[7] <= _d_sprite_y[7];
_q_sprite_y[8] <= _d_sprite_y[8];
_q_sprite_y[9] <= _d_sprite_y[9];
_q_sprite_y[10] <= _d_sprite_y[10];
_q_sprite_y[11] <= _d_sprite_y[11];
_q_sprite_y[12] <= _d_sprite_y[12];
_q_sprite_colour[0] <= _d_sprite_colour[0];
_q_sprite_colour[1] <= _d_sprite_colour[1];
_q_sprite_colour[2] <= _d_sprite_colour[2];
_q_sprite_colour[3] <= _d_sprite_colour[3];
_q_sprite_colour[4] <= _d_sprite_colour[4];
_q_sprite_colour[5] <= _d_sprite_colour[5];
_q_sprite_colour[6] <= _d_sprite_colour[6];
_q_sprite_colour[7] <= _d_sprite_colour[7];
_q_sprite_colour[8] <= _d_sprite_colour[8];
_q_sprite_colour[9] <= _d_sprite_colour[9];
_q_sprite_colour[10] <= _d_sprite_colour[10];
_q_sprite_colour[11] <= _d_sprite_colour[11];
_q_sprite_colour[12] <= _d_sprite_colour[12];
_q_sprite_tile_number[0] <= _d_sprite_tile_number[0];
_q_sprite_tile_number[1] <= _d_sprite_tile_number[1];
_q_sprite_tile_number[2] <= _d_sprite_tile_number[2];
_q_sprite_tile_number[3] <= _d_sprite_tile_number[3];
_q_sprite_tile_number[4] <= _d_sprite_tile_number[4];
_q_sprite_tile_number[5] <= _d_sprite_tile_number[5];
_q_sprite_tile_number[6] <= _d_sprite_tile_number[6];
_q_sprite_tile_number[7] <= _d_sprite_tile_number[7];
_q_sprite_tile_number[8] <= _d_sprite_tile_number[8];
_q_sprite_tile_number[9] <= _d_sprite_tile_number[9];
_q_sprite_tile_number[10] <= _d_sprite_tile_number[10];
_q_sprite_tile_number[11] <= _d_sprite_tile_number[11];
_q_sprite_tile_number[12] <= _d_sprite_tile_number[12];
_q_output_collisions <= _d_output_collisions;
_q_tiles_0_addr0 <= _d_tiles_0_addr0;
_q_tiles_0_wenable1 <= _d_tiles_0_wenable1;
_q_tiles_0_wdata1 <= _d_tiles_0_wdata1;
_q_tiles_0_addr1 <= _d_tiles_0_addr1;
_q_detect_collision_0 <= _d_detect_collision_0;
_q_tiles_1_addr0 <= _d_tiles_1_addr0;
_q_tiles_1_wenable1 <= _d_tiles_1_wenable1;
_q_tiles_1_wdata1 <= _d_tiles_1_wdata1;
_q_tiles_1_addr1 <= _d_tiles_1_addr1;
_q_detect_collision_1 <= _d_detect_collision_1;
_q_tiles_2_addr0 <= _d_tiles_2_addr0;
_q_tiles_2_wenable1 <= _d_tiles_2_wenable1;
_q_tiles_2_wdata1 <= _d_tiles_2_wdata1;
_q_tiles_2_addr1 <= _d_tiles_2_addr1;
_q_detect_collision_2 <= _d_detect_collision_2;
_q_tiles_3_addr0 <= _d_tiles_3_addr0;
_q_tiles_3_wenable1 <= _d_tiles_3_wenable1;
_q_tiles_3_wdata1 <= _d_tiles_3_wdata1;
_q_tiles_3_addr1 <= _d_tiles_3_addr1;
_q_detect_collision_3 <= _d_detect_collision_3;
_q_tiles_4_addr0 <= _d_tiles_4_addr0;
_q_tiles_4_wenable1 <= _d_tiles_4_wenable1;
_q_tiles_4_wdata1 <= _d_tiles_4_wdata1;
_q_tiles_4_addr1 <= _d_tiles_4_addr1;
_q_detect_collision_4 <= _d_detect_collision_4;
_q_tiles_5_addr0 <= _d_tiles_5_addr0;
_q_tiles_5_wenable1 <= _d_tiles_5_wenable1;
_q_tiles_5_wdata1 <= _d_tiles_5_wdata1;
_q_tiles_5_addr1 <= _d_tiles_5_addr1;
_q_detect_collision_5 <= _d_detect_collision_5;
_q_tiles_6_addr0 <= _d_tiles_6_addr0;
_q_tiles_6_wenable1 <= _d_tiles_6_wenable1;
_q_tiles_6_wdata1 <= _d_tiles_6_wdata1;
_q_tiles_6_addr1 <= _d_tiles_6_addr1;
_q_detect_collision_6 <= _d_detect_collision_6;
_q_tiles_7_addr0 <= _d_tiles_7_addr0;
_q_tiles_7_wenable1 <= _d_tiles_7_wenable1;
_q_tiles_7_wdata1 <= _d_tiles_7_wdata1;
_q_tiles_7_addr1 <= _d_tiles_7_addr1;
_q_detect_collision_7 <= _d_detect_collision_7;
_q_tiles_8_addr0 <= _d_tiles_8_addr0;
_q_tiles_8_wenable1 <= _d_tiles_8_wenable1;
_q_tiles_8_wdata1 <= _d_tiles_8_wdata1;
_q_tiles_8_addr1 <= _d_tiles_8_addr1;
_q_detect_collision_8 <= _d_detect_collision_8;
_q_tiles_9_addr0 <= _d_tiles_9_addr0;
_q_tiles_9_wenable1 <= _d_tiles_9_wenable1;
_q_tiles_9_wdata1 <= _d_tiles_9_wdata1;
_q_tiles_9_addr1 <= _d_tiles_9_addr1;
_q_detect_collision_9 <= _d_detect_collision_9;
_q_tiles_10_addr0 <= _d_tiles_10_addr0;
_q_tiles_10_wenable1 <= _d_tiles_10_wenable1;
_q_tiles_10_wdata1 <= _d_tiles_10_wdata1;
_q_tiles_10_addr1 <= _d_tiles_10_addr1;
_q_detect_collision_10 <= _d_detect_collision_10;
_q_tiles_11_addr0 <= _d_tiles_11_addr0;
_q_tiles_11_wenable1 <= _d_tiles_11_wenable1;
_q_tiles_11_wdata1 <= _d_tiles_11_wdata1;
_q_tiles_11_addr1 <= _d_tiles_11_addr1;
_q_detect_collision_11 <= _d_detect_collision_11;
_q_tiles_12_addr0 <= _d_tiles_12_addr0;
_q_tiles_12_wenable1 <= _d_tiles_12_wenable1;
_q_tiles_12_wdata1 <= _d_tiles_12_wdata1;
_q_tiles_12_addr1 <= _d_tiles_12_addr1;
_q_detect_collision_12 <= _d_detect_collision_12;
_q_pix_red <= _d_pix_red;
_q_pix_green <= _d_pix_green;
_q_pix_blue <= _d_pix_blue;
_q_sprite_layer_display <= _d_sprite_layer_display;
_q_sprite_read_active <= _d_sprite_read_active;
_q_sprite_read_double <= _d_sprite_read_double;
_q_sprite_read_colour <= _d_sprite_read_colour;
_q_sprite_read_x <= _d_sprite_read_x;
_q_sprite_read_y <= _d_sprite_read_y;
_q_sprite_read_tile <= _d_sprite_read_tile;
_q_collision_0 <= _d_collision_0;
_q_collision_1 <= _d_collision_1;
_q_collision_2 <= _d_collision_2;
_q_collision_3 <= _d_collision_3;
_q_collision_4 <= _d_collision_4;
_q_collision_5 <= _d_collision_5;
_q_collision_6 <= _d_collision_6;
_q_collision_7 <= _d_collision_7;
_q_collision_8 <= _d_collision_8;
_q_collision_9 <= _d_collision_9;
_q_collision_10 <= _d_collision_10;
_q_collision_11 <= _d_collision_11;
_q_collision_12 <= _d_collision_12;
_q_index <= _d_index;
  end
end


M_sprite_layer_mem_tiles_0 __mem__tiles_0(
.clock0(clock),
.clock1(clock),
.in_tiles_0_addr0(_d_tiles_0_addr0),
.in_tiles_0_wenable1(_d_tiles_0_wenable1),
.in_tiles_0_wdata1(_d_tiles_0_wdata1),
.in_tiles_0_addr1(_d_tiles_0_addr1),
.out_tiles_0_rdata0(_w_mem_tiles_0_rdata0)
);
M_sprite_layer_mem_tiles_1 __mem__tiles_1(
.clock0(clock),
.clock1(clock),
.in_tiles_1_addr0(_d_tiles_1_addr0),
.in_tiles_1_wenable1(_d_tiles_1_wenable1),
.in_tiles_1_wdata1(_d_tiles_1_wdata1),
.in_tiles_1_addr1(_d_tiles_1_addr1),
.out_tiles_1_rdata0(_w_mem_tiles_1_rdata0)
);
M_sprite_layer_mem_tiles_2 __mem__tiles_2(
.clock0(clock),
.clock1(clock),
.in_tiles_2_addr0(_d_tiles_2_addr0),
.in_tiles_2_wenable1(_d_tiles_2_wenable1),
.in_tiles_2_wdata1(_d_tiles_2_wdata1),
.in_tiles_2_addr1(_d_tiles_2_addr1),
.out_tiles_2_rdata0(_w_mem_tiles_2_rdata0)
);
M_sprite_layer_mem_tiles_3 __mem__tiles_3(
.clock0(clock),
.clock1(clock),
.in_tiles_3_addr0(_d_tiles_3_addr0),
.in_tiles_3_wenable1(_d_tiles_3_wenable1),
.in_tiles_3_wdata1(_d_tiles_3_wdata1),
.in_tiles_3_addr1(_d_tiles_3_addr1),
.out_tiles_3_rdata0(_w_mem_tiles_3_rdata0)
);
M_sprite_layer_mem_tiles_4 __mem__tiles_4(
.clock0(clock),
.clock1(clock),
.in_tiles_4_addr0(_d_tiles_4_addr0),
.in_tiles_4_wenable1(_d_tiles_4_wenable1),
.in_tiles_4_wdata1(_d_tiles_4_wdata1),
.in_tiles_4_addr1(_d_tiles_4_addr1),
.out_tiles_4_rdata0(_w_mem_tiles_4_rdata0)
);
M_sprite_layer_mem_tiles_5 __mem__tiles_5(
.clock0(clock),
.clock1(clock),
.in_tiles_5_addr0(_d_tiles_5_addr0),
.in_tiles_5_wenable1(_d_tiles_5_wenable1),
.in_tiles_5_wdata1(_d_tiles_5_wdata1),
.in_tiles_5_addr1(_d_tiles_5_addr1),
.out_tiles_5_rdata0(_w_mem_tiles_5_rdata0)
);
M_sprite_layer_mem_tiles_6 __mem__tiles_6(
.clock0(clock),
.clock1(clock),
.in_tiles_6_addr0(_d_tiles_6_addr0),
.in_tiles_6_wenable1(_d_tiles_6_wenable1),
.in_tiles_6_wdata1(_d_tiles_6_wdata1),
.in_tiles_6_addr1(_d_tiles_6_addr1),
.out_tiles_6_rdata0(_w_mem_tiles_6_rdata0)
);
M_sprite_layer_mem_tiles_7 __mem__tiles_7(
.clock0(clock),
.clock1(clock),
.in_tiles_7_addr0(_d_tiles_7_addr0),
.in_tiles_7_wenable1(_d_tiles_7_wenable1),
.in_tiles_7_wdata1(_d_tiles_7_wdata1),
.in_tiles_7_addr1(_d_tiles_7_addr1),
.out_tiles_7_rdata0(_w_mem_tiles_7_rdata0)
);
M_sprite_layer_mem_tiles_8 __mem__tiles_8(
.clock0(clock),
.clock1(clock),
.in_tiles_8_addr0(_d_tiles_8_addr0),
.in_tiles_8_wenable1(_d_tiles_8_wenable1),
.in_tiles_8_wdata1(_d_tiles_8_wdata1),
.in_tiles_8_addr1(_d_tiles_8_addr1),
.out_tiles_8_rdata0(_w_mem_tiles_8_rdata0)
);
M_sprite_layer_mem_tiles_9 __mem__tiles_9(
.clock0(clock),
.clock1(clock),
.in_tiles_9_addr0(_d_tiles_9_addr0),
.in_tiles_9_wenable1(_d_tiles_9_wenable1),
.in_tiles_9_wdata1(_d_tiles_9_wdata1),
.in_tiles_9_addr1(_d_tiles_9_addr1),
.out_tiles_9_rdata0(_w_mem_tiles_9_rdata0)
);
M_sprite_layer_mem_tiles_10 __mem__tiles_10(
.clock0(clock),
.clock1(clock),
.in_tiles_10_addr0(_d_tiles_10_addr0),
.in_tiles_10_wenable1(_d_tiles_10_wenable1),
.in_tiles_10_wdata1(_d_tiles_10_wdata1),
.in_tiles_10_addr1(_d_tiles_10_addr1),
.out_tiles_10_rdata0(_w_mem_tiles_10_rdata0)
);
M_sprite_layer_mem_tiles_11 __mem__tiles_11(
.clock0(clock),
.clock1(clock),
.in_tiles_11_addr0(_d_tiles_11_addr0),
.in_tiles_11_wenable1(_d_tiles_11_wenable1),
.in_tiles_11_wdata1(_d_tiles_11_wdata1),
.in_tiles_11_addr1(_d_tiles_11_addr1),
.out_tiles_11_rdata0(_w_mem_tiles_11_rdata0)
);
M_sprite_layer_mem_tiles_12 __mem__tiles_12(
.clock0(clock),
.clock1(clock),
.in_tiles_12_addr0(_d_tiles_12_addr0),
.in_tiles_12_wenable1(_d_tiles_12_wenable1),
.in_tiles_12_wdata1(_d_tiles_12_wdata1),
.in_tiles_12_addr1(_d_tiles_12_addr1),
.out_tiles_12_rdata0(_w_mem_tiles_12_rdata0)
);

assign _w_sprite_to_negative = _q_sprite_double[in_sprite_set_number]?-31:-15;
assign _w_deltax = {(in_sprite_update[4+:1]?7'b1111111:7'b0000000),in_sprite_update[0+:4]};
assign _w_pix_visible_11 = _d_sprite_active[11]&&_w_xinrange_11&&_w_yinrange_11&&(_w_mem_tiles_11_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[11])>>>_q_sprite_double[11]))+:1]);
assign _w_yinrange_11 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[11]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[11]+_w_spritesize_11));
assign _w_xinrange_11 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[11]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[11]+_w_spritesize_11));
assign _w_pix_visible_10 = _d_sprite_active[10]&&_w_xinrange_10&&_w_yinrange_10&&(_w_mem_tiles_10_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[10])>>>_q_sprite_double[10]))+:1]);
assign _w_yinrange_10 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[10]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[10]+_w_spritesize_10));
assign _w_xinrange_10 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[10]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[10]+_w_spritesize_10));
assign _w_spritesize_9 = _d_sprite_double[9]?32:16;
assign _w_yinrange_12 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[12]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[12]+_w_spritesize_12));
assign _w_yinrange_8 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[8]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[8]+_w_spritesize_8));
assign _w_spritesize_8 = _d_sprite_double[8]?32:16;
assign _w_pix_visible_7 = _d_sprite_active[7]&&_w_xinrange_7&&_w_yinrange_7&&(_w_mem_tiles_7_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[7])>>>_q_sprite_double[7]))+:1]);
assign _w_xinrange_7 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[7]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[7]+_w_spritesize_7));
assign _w_spritesize_3 = _d_sprite_double[3]?32:16;
assign _w_xinrange_9 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[9]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[9]+_w_spritesize_9));
assign _w_yinrange_3 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[3]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[3]+_w_spritesize_3));
assign _w_spritesize_12 = _d_sprite_double[12]?32:16;
assign _w_yinrange_2 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[2]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[2]+_w_spritesize_2));
assign _w_yinrange_6 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[6]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[6]+_w_spritesize_6));
assign _w_pix_visible_2 = _d_sprite_active[2]&&_w_xinrange_2&&_w_yinrange_2&&(_w_mem_tiles_2_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[2])>>>_q_sprite_double[2]))+:1]);
assign _w_sprite_offscreen_x = ($signed(_q_sprite_x[in_sprite_set_number])<$signed(_w_sprite_offscreen_negative))||($signed(_q_sprite_x[in_sprite_set_number])>$signed(640));
assign _w_pix_visible_9 = _d_sprite_active[9]&&_w_xinrange_9&&_w_yinrange_9&&(_w_mem_tiles_9_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[9])>>>_q_sprite_double[9]))+:1]);
assign _w_spritesize_4 = _d_sprite_double[4]?32:16;
assign _w_xinrange_5 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[5]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[5]+_w_spritesize_5));
assign _w_spritesize_5 = _d_sprite_double[5]?32:16;
assign _w_pix_visible_3 = _d_sprite_active[3]&&_w_xinrange_3&&_w_yinrange_3&&(_w_mem_tiles_3_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[3])>>>_q_sprite_double[3]))+:1]);
assign _w_pix_visible_1 = _d_sprite_active[1]&&_w_xinrange_1&&_w_yinrange_1&&(_w_mem_tiles_1_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[1])>>>_q_sprite_double[1]))+:1]);
assign _w_xinrange_2 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[2]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[2]+_w_spritesize_2));
assign _w_sprite_offscreen_negative = _q_sprite_double[in_sprite_set_number]?-32:-16;
assign _w_spritesize_2 = _d_sprite_double[2]?32:16;
assign _w_pix_visible_8 = _d_sprite_active[8]&&_w_xinrange_8&&_w_yinrange_8&&(_w_mem_tiles_8_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[8])>>>_q_sprite_double[8]))+:1]);
assign _w_spritesize_1 = _d_sprite_double[1]?32:16;
assign _w_xinrange_1 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[1]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[1]+_w_spritesize_1));
assign _w_xinrange_8 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[8]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[8]+_w_spritesize_8));
assign _w_pix_visible_0 = _d_sprite_active[0]&&_w_xinrange_0&&_w_yinrange_0&&(_w_mem_tiles_0_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[0])>>>_q_sprite_double[0]))+:1]);
assign _w_spritesize_0 = _d_sprite_double[0]?32:16;
assign _w_pix_visible_12 = _d_sprite_active[12]&&_w_xinrange_12&&_w_yinrange_12&&(_w_mem_tiles_12_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[12])>>>_q_sprite_double[12]))+:1]);
assign _w_xinrange_0 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[0]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[0]+_w_spritesize_0));
assign _w_xinrange_4 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[4]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[4]+_w_spritesize_4));
assign _w_yinrange_1 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[1]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[1]+_w_spritesize_1));
assign _w_yinrange_0 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[0]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[0]+_w_spritesize_0));
assign _w_yinrange_9 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[9]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[9]+_w_spritesize_9));
assign _w_xinrange_3 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[3]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[3]+_w_spritesize_3));
assign _w_sprite_offscreen_y = ($signed(_q_sprite_y[in_sprite_set_number])<$signed(_w_sprite_offscreen_negative))||($signed(_q_sprite_y[in_sprite_set_number])>$signed(480));
assign _w_yinrange_4 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[4]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[4]+_w_spritesize_4));
assign _w_pix_visible_4 = _d_sprite_active[4]&&_w_xinrange_4&&_w_yinrange_4&&(_w_mem_tiles_4_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[4])>>>_q_sprite_double[4]))+:1]);
assign _w_xinrange_12 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[12]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[12]+_w_spritesize_12));
assign _w_spritesize_10 = _d_sprite_double[10]?32:16;
assign _w_yinrange_7 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[7]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[7]+_w_spritesize_7));
assign _w_xinrange_6 = ($signed({1'b0,in_pix_x})>=$signed(_d_sprite_x[6]))&&($signed({1'b0,in_pix_x})<$signed(_d_sprite_x[6]+_w_spritesize_6));
assign _w_yinrange_5 = ($signed({1'b0,in_pix_y})>=$signed(_d_sprite_y[5]))&&($signed({1'b0,in_pix_y})<$signed(_d_sprite_y[5]+_w_spritesize_5));
assign _w_spritesize_11 = _d_sprite_double[11]?32:16;
assign _w_pix_visible_5 = _d_sprite_active[5]&&_w_xinrange_5&&_w_yinrange_5&&(_w_mem_tiles_5_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[5])>>>_q_sprite_double[5]))+:1]);
assign _w_spritesize_6 = _d_sprite_double[6]?32:16;
assign _w_pix_visible_6 = _d_sprite_active[6]&&_w_xinrange_6&&_w_yinrange_6&&(_w_mem_tiles_6_rdata0[(15-(($signed({1'b0,in_pix_x})-_q_sprite_x[6])>>>_q_sprite_double[6]))+:1]);
assign _w_deltay = {(in_sprite_update[9+:1]?7'b1111111:7'b0000000),in_sprite_update[5+:4]};
assign _w_spritesize_7 = _d_sprite_double[7]?32:16;

always @* begin
_d_sprite_active[0] = _q_sprite_active[0];
_d_sprite_active[1] = _q_sprite_active[1];
_d_sprite_active[2] = _q_sprite_active[2];
_d_sprite_active[3] = _q_sprite_active[3];
_d_sprite_active[4] = _q_sprite_active[4];
_d_sprite_active[5] = _q_sprite_active[5];
_d_sprite_active[6] = _q_sprite_active[6];
_d_sprite_active[7] = _q_sprite_active[7];
_d_sprite_active[8] = _q_sprite_active[8];
_d_sprite_active[9] = _q_sprite_active[9];
_d_sprite_active[10] = _q_sprite_active[10];
_d_sprite_active[11] = _q_sprite_active[11];
_d_sprite_active[12] = _q_sprite_active[12];
_d_sprite_double[0] = _q_sprite_double[0];
_d_sprite_double[1] = _q_sprite_double[1];
_d_sprite_double[2] = _q_sprite_double[2];
_d_sprite_double[3] = _q_sprite_double[3];
_d_sprite_double[4] = _q_sprite_double[4];
_d_sprite_double[5] = _q_sprite_double[5];
_d_sprite_double[6] = _q_sprite_double[6];
_d_sprite_double[7] = _q_sprite_double[7];
_d_sprite_double[8] = _q_sprite_double[8];
_d_sprite_double[9] = _q_sprite_double[9];
_d_sprite_double[10] = _q_sprite_double[10];
_d_sprite_double[11] = _q_sprite_double[11];
_d_sprite_double[12] = _q_sprite_double[12];
_d_sprite_x[0] = _q_sprite_x[0];
_d_sprite_x[1] = _q_sprite_x[1];
_d_sprite_x[2] = _q_sprite_x[2];
_d_sprite_x[3] = _q_sprite_x[3];
_d_sprite_x[4] = _q_sprite_x[4];
_d_sprite_x[5] = _q_sprite_x[5];
_d_sprite_x[6] = _q_sprite_x[6];
_d_sprite_x[7] = _q_sprite_x[7];
_d_sprite_x[8] = _q_sprite_x[8];
_d_sprite_x[9] = _q_sprite_x[9];
_d_sprite_x[10] = _q_sprite_x[10];
_d_sprite_x[11] = _q_sprite_x[11];
_d_sprite_x[12] = _q_sprite_x[12];
_d_sprite_y[0] = _q_sprite_y[0];
_d_sprite_y[1] = _q_sprite_y[1];
_d_sprite_y[2] = _q_sprite_y[2];
_d_sprite_y[3] = _q_sprite_y[3];
_d_sprite_y[4] = _q_sprite_y[4];
_d_sprite_y[5] = _q_sprite_y[5];
_d_sprite_y[6] = _q_sprite_y[6];
_d_sprite_y[7] = _q_sprite_y[7];
_d_sprite_y[8] = _q_sprite_y[8];
_d_sprite_y[9] = _q_sprite_y[9];
_d_sprite_y[10] = _q_sprite_y[10];
_d_sprite_y[11] = _q_sprite_y[11];
_d_sprite_y[12] = _q_sprite_y[12];
_d_sprite_colour[0] = _q_sprite_colour[0];
_d_sprite_colour[1] = _q_sprite_colour[1];
_d_sprite_colour[2] = _q_sprite_colour[2];
_d_sprite_colour[3] = _q_sprite_colour[3];
_d_sprite_colour[4] = _q_sprite_colour[4];
_d_sprite_colour[5] = _q_sprite_colour[5];
_d_sprite_colour[6] = _q_sprite_colour[6];
_d_sprite_colour[7] = _q_sprite_colour[7];
_d_sprite_colour[8] = _q_sprite_colour[8];
_d_sprite_colour[9] = _q_sprite_colour[9];
_d_sprite_colour[10] = _q_sprite_colour[10];
_d_sprite_colour[11] = _q_sprite_colour[11];
_d_sprite_colour[12] = _q_sprite_colour[12];
_d_sprite_tile_number[0] = _q_sprite_tile_number[0];
_d_sprite_tile_number[1] = _q_sprite_tile_number[1];
_d_sprite_tile_number[2] = _q_sprite_tile_number[2];
_d_sprite_tile_number[3] = _q_sprite_tile_number[3];
_d_sprite_tile_number[4] = _q_sprite_tile_number[4];
_d_sprite_tile_number[5] = _q_sprite_tile_number[5];
_d_sprite_tile_number[6] = _q_sprite_tile_number[6];
_d_sprite_tile_number[7] = _q_sprite_tile_number[7];
_d_sprite_tile_number[8] = _q_sprite_tile_number[8];
_d_sprite_tile_number[9] = _q_sprite_tile_number[9];
_d_sprite_tile_number[10] = _q_sprite_tile_number[10];
_d_sprite_tile_number[11] = _q_sprite_tile_number[11];
_d_sprite_tile_number[12] = _q_sprite_tile_number[12];
_d_output_collisions = _q_output_collisions;
_d_tiles_0_addr0 = _q_tiles_0_addr0;
_d_tiles_0_wenable1 = _q_tiles_0_wenable1;
_d_tiles_0_wdata1 = _q_tiles_0_wdata1;
_d_tiles_0_addr1 = _q_tiles_0_addr1;
_d_detect_collision_0 = _q_detect_collision_0;
_d_tiles_1_addr0 = _q_tiles_1_addr0;
_d_tiles_1_wenable1 = _q_tiles_1_wenable1;
_d_tiles_1_wdata1 = _q_tiles_1_wdata1;
_d_tiles_1_addr1 = _q_tiles_1_addr1;
_d_detect_collision_1 = _q_detect_collision_1;
_d_tiles_2_addr0 = _q_tiles_2_addr0;
_d_tiles_2_wenable1 = _q_tiles_2_wenable1;
_d_tiles_2_wdata1 = _q_tiles_2_wdata1;
_d_tiles_2_addr1 = _q_tiles_2_addr1;
_d_detect_collision_2 = _q_detect_collision_2;
_d_tiles_3_addr0 = _q_tiles_3_addr0;
_d_tiles_3_wenable1 = _q_tiles_3_wenable1;
_d_tiles_3_wdata1 = _q_tiles_3_wdata1;
_d_tiles_3_addr1 = _q_tiles_3_addr1;
_d_detect_collision_3 = _q_detect_collision_3;
_d_tiles_4_addr0 = _q_tiles_4_addr0;
_d_tiles_4_wenable1 = _q_tiles_4_wenable1;
_d_tiles_4_wdata1 = _q_tiles_4_wdata1;
_d_tiles_4_addr1 = _q_tiles_4_addr1;
_d_detect_collision_4 = _q_detect_collision_4;
_d_tiles_5_addr0 = _q_tiles_5_addr0;
_d_tiles_5_wenable1 = _q_tiles_5_wenable1;
_d_tiles_5_wdata1 = _q_tiles_5_wdata1;
_d_tiles_5_addr1 = _q_tiles_5_addr1;
_d_detect_collision_5 = _q_detect_collision_5;
_d_tiles_6_addr0 = _q_tiles_6_addr0;
_d_tiles_6_wenable1 = _q_tiles_6_wenable1;
_d_tiles_6_wdata1 = _q_tiles_6_wdata1;
_d_tiles_6_addr1 = _q_tiles_6_addr1;
_d_detect_collision_6 = _q_detect_collision_6;
_d_tiles_7_addr0 = _q_tiles_7_addr0;
_d_tiles_7_wenable1 = _q_tiles_7_wenable1;
_d_tiles_7_wdata1 = _q_tiles_7_wdata1;
_d_tiles_7_addr1 = _q_tiles_7_addr1;
_d_detect_collision_7 = _q_detect_collision_7;
_d_tiles_8_addr0 = _q_tiles_8_addr0;
_d_tiles_8_wenable1 = _q_tiles_8_wenable1;
_d_tiles_8_wdata1 = _q_tiles_8_wdata1;
_d_tiles_8_addr1 = _q_tiles_8_addr1;
_d_detect_collision_8 = _q_detect_collision_8;
_d_tiles_9_addr0 = _q_tiles_9_addr0;
_d_tiles_9_wenable1 = _q_tiles_9_wenable1;
_d_tiles_9_wdata1 = _q_tiles_9_wdata1;
_d_tiles_9_addr1 = _q_tiles_9_addr1;
_d_detect_collision_9 = _q_detect_collision_9;
_d_tiles_10_addr0 = _q_tiles_10_addr0;
_d_tiles_10_wenable1 = _q_tiles_10_wenable1;
_d_tiles_10_wdata1 = _q_tiles_10_wdata1;
_d_tiles_10_addr1 = _q_tiles_10_addr1;
_d_detect_collision_10 = _q_detect_collision_10;
_d_tiles_11_addr0 = _q_tiles_11_addr0;
_d_tiles_11_wenable1 = _q_tiles_11_wenable1;
_d_tiles_11_wdata1 = _q_tiles_11_wdata1;
_d_tiles_11_addr1 = _q_tiles_11_addr1;
_d_detect_collision_11 = _q_detect_collision_11;
_d_tiles_12_addr0 = _q_tiles_12_addr0;
_d_tiles_12_wenable1 = _q_tiles_12_wenable1;
_d_tiles_12_wdata1 = _q_tiles_12_wdata1;
_d_tiles_12_addr1 = _q_tiles_12_addr1;
_d_detect_collision_12 = _q_detect_collision_12;
_d_pix_red = _q_pix_red;
_d_pix_green = _q_pix_green;
_d_pix_blue = _q_pix_blue;
_d_sprite_layer_display = _q_sprite_layer_display;
_d_sprite_read_active = _q_sprite_read_active;
_d_sprite_read_double = _q_sprite_read_double;
_d_sprite_read_colour = _q_sprite_read_colour;
_d_sprite_read_x = _q_sprite_read_x;
_d_sprite_read_y = _q_sprite_read_y;
_d_sprite_read_tile = _q_sprite_read_tile;
_d_collision_0 = _q_collision_0;
_d_collision_1 = _q_collision_1;
_d_collision_2 = _q_collision_2;
_d_collision_3 = _q_collision_3;
_d_collision_4 = _q_collision_4;
_d_collision_5 = _q_collision_5;
_d_collision_6 = _q_collision_6;
_d_collision_7 = _q_collision_7;
_d_collision_8 = _q_collision_8;
_d_collision_9 = _q_collision_9;
_d_collision_10 = _q_collision_10;
_d_collision_11 = _q_collision_11;
_d_collision_12 = _q_collision_12;
_d_index = _q_index;
// _always_pre
_d_tiles_0_addr0 = _q_sprite_tile_number[0]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[0])>>>_q_sprite_double[0]);
_d_tiles_0_wenable1 = 1;
_d_collision_0 = (_q_output_collisions)?_q_detect_collision_0:_q_collision_0;
_d_tiles_1_addr0 = _q_sprite_tile_number[1]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[1])>>>_q_sprite_double[1]);
_d_tiles_1_wenable1 = 1;
_d_collision_1 = (_q_output_collisions)?_q_detect_collision_1:_q_collision_1;
_d_tiles_2_addr0 = _q_sprite_tile_number[2]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[2])>>>_q_sprite_double[2]);
_d_tiles_2_wenable1 = 1;
_d_collision_2 = (_q_output_collisions)?_q_detect_collision_2:_q_collision_2;
_d_tiles_3_addr0 = _q_sprite_tile_number[3]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[3])>>>_q_sprite_double[3]);
_d_tiles_3_wenable1 = 1;
_d_collision_3 = (_q_output_collisions)?_q_detect_collision_3:_q_collision_3;
_d_tiles_4_addr0 = _q_sprite_tile_number[4]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[4])>>>_q_sprite_double[4]);
_d_tiles_4_wenable1 = 1;
_d_collision_4 = (_q_output_collisions)?_q_detect_collision_4:_q_collision_4;
_d_tiles_5_addr0 = _q_sprite_tile_number[5]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[5])>>>_q_sprite_double[5]);
_d_tiles_5_wenable1 = 1;
_d_collision_5 = (_q_output_collisions)?_q_detect_collision_5:_q_collision_5;
_d_tiles_6_addr0 = _q_sprite_tile_number[6]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[6])>>>_q_sprite_double[6]);
_d_tiles_6_wenable1 = 1;
_d_collision_6 = (_q_output_collisions)?_q_detect_collision_6:_q_collision_6;
_d_tiles_7_addr0 = _q_sprite_tile_number[7]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[7])>>>_q_sprite_double[7]);
_d_tiles_7_wenable1 = 1;
_d_collision_7 = (_q_output_collisions)?_q_detect_collision_7:_q_collision_7;
_d_tiles_8_addr0 = _q_sprite_tile_number[8]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[8])>>>_q_sprite_double[8]);
_d_tiles_8_wenable1 = 1;
_d_collision_8 = (_q_output_collisions)?_q_detect_collision_8:_q_collision_8;
_d_tiles_9_addr0 = _q_sprite_tile_number[9]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[9])>>>_q_sprite_double[9]);
_d_tiles_9_wenable1 = 1;
_d_collision_9 = (_q_output_collisions)?_q_detect_collision_9:_q_collision_9;
_d_tiles_10_addr0 = _q_sprite_tile_number[10]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[10])>>>_q_sprite_double[10]);
_d_tiles_10_wenable1 = 1;
_d_collision_10 = (_q_output_collisions)?_q_detect_collision_10:_q_collision_10;
_d_tiles_11_addr0 = _q_sprite_tile_number[11]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[11])>>>_q_sprite_double[11]);
_d_tiles_11_wenable1 = 1;
_d_collision_11 = (_q_output_collisions)?_q_detect_collision_11:_q_collision_11;
_d_tiles_12_addr0 = _q_sprite_tile_number[12]*16+(($signed({1'b0,in_pix_y})-_q_sprite_y[12])>>>_q_sprite_double[12]);
_d_tiles_12_wenable1 = 1;
_d_collision_12 = (_q_output_collisions)?_q_detect_collision_12:_q_collision_12;
_d_sprite_layer_display = 0;
_d_sprite_read_active = _q_sprite_active[in_sprite_set_number];
_d_sprite_read_double = _q_sprite_double[in_sprite_set_number];
_d_sprite_read_colour = _q_sprite_colour[in_sprite_set_number];
_d_sprite_read_x = _q_sprite_x[in_sprite_set_number];
_d_sprite_read_y = _q_sprite_y[in_sprite_set_number];
_d_sprite_read_tile = _q_sprite_tile_number[in_sprite_set_number];
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_output_collisions = 0;
_d_tiles_0_addr0 = 0;
_d_tiles_0_wenable1 = 0;
_d_tiles_0_wdata1 = 0;
_d_tiles_0_addr1 = 0;
_d_tiles_1_addr0 = 0;
_d_tiles_1_wenable1 = 0;
_d_tiles_1_wdata1 = 0;
_d_tiles_1_addr1 = 0;
_d_tiles_2_addr0 = 0;
_d_tiles_2_wenable1 = 0;
_d_tiles_2_wdata1 = 0;
_d_tiles_2_addr1 = 0;
_d_tiles_3_addr0 = 0;
_d_tiles_3_wenable1 = 0;
_d_tiles_3_wdata1 = 0;
_d_tiles_3_addr1 = 0;
_d_tiles_4_addr0 = 0;
_d_tiles_4_wenable1 = 0;
_d_tiles_4_wdata1 = 0;
_d_tiles_4_addr1 = 0;
_d_tiles_5_addr0 = 0;
_d_tiles_5_wenable1 = 0;
_d_tiles_5_wdata1 = 0;
_d_tiles_5_addr1 = 0;
_d_tiles_6_addr0 = 0;
_d_tiles_6_wenable1 = 0;
_d_tiles_6_wdata1 = 0;
_d_tiles_6_addr1 = 0;
_d_tiles_7_addr0 = 0;
_d_tiles_7_wenable1 = 0;
_d_tiles_7_wdata1 = 0;
_d_tiles_7_addr1 = 0;
_d_tiles_8_addr0 = 0;
_d_tiles_8_wenable1 = 0;
_d_tiles_8_wdata1 = 0;
_d_tiles_8_addr1 = 0;
_d_tiles_9_addr0 = 0;
_d_tiles_9_wenable1 = 0;
_d_tiles_9_wdata1 = 0;
_d_tiles_9_addr1 = 0;
_d_tiles_10_addr0 = 0;
_d_tiles_10_wenable1 = 0;
_d_tiles_10_wdata1 = 0;
_d_tiles_10_addr1 = 0;
_d_tiles_11_addr0 = 0;
_d_tiles_11_wenable1 = 0;
_d_tiles_11_wdata1 = 0;
_d_tiles_11_addr1 = 0;
_d_tiles_12_addr0 = 0;
_d_tiles_12_wenable1 = 0;
_d_tiles_12_wdata1 = 0;
_d_tiles_12_addr1 = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_pix_vblank) begin
// __block_5
// __block_7
if (~_q_output_collisions) begin
// __block_8
// __block_10
_d_detect_collision_0 = 0;
_d_detect_collision_1 = 0;
_d_detect_collision_2 = 0;
_d_detect_collision_3 = 0;
_d_detect_collision_4 = 0;
_d_detect_collision_5 = 0;
_d_detect_collision_6 = 0;
_d_detect_collision_7 = 0;
_d_detect_collision_8 = 0;
_d_detect_collision_9 = 0;
_d_detect_collision_10 = 0;
_d_detect_collision_11 = 0;
_d_detect_collision_12 = 0;
// __block_11
end else begin
// __block_9
// __block_12
_d_output_collisions = 0;
// __block_13
end
// __block_14
// __block_15
end else begin
// __block_6
// __block_16
if (in_pix_active) begin
// __block_17
// __block_19
if ((_w_pix_visible_0)) begin
// __block_20
// __block_22
_d_pix_red = _q_sprite_colour[0][4+:2];
_d_pix_green = _q_sprite_colour[0][2+:2];
_d_pix_blue = _q_sprite_colour[0][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_0 = _q_detect_collision_0|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_23
end else begin
// __block_21
end
// __block_24
if ((_w_pix_visible_1)) begin
// __block_25
// __block_27
_d_pix_red = _q_sprite_colour[1][4+:2];
_d_pix_green = _q_sprite_colour[1][2+:2];
_d_pix_blue = _q_sprite_colour[1][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_1 = _q_detect_collision_1|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_28
end else begin
// __block_26
end
// __block_29
if ((_w_pix_visible_2)) begin
// __block_30
// __block_32
_d_pix_red = _q_sprite_colour[2][4+:2];
_d_pix_green = _q_sprite_colour[2][2+:2];
_d_pix_blue = _q_sprite_colour[2][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_2 = _q_detect_collision_2|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_33
end else begin
// __block_31
end
// __block_34
if ((_w_pix_visible_3)) begin
// __block_35
// __block_37
_d_pix_red = _q_sprite_colour[3][4+:2];
_d_pix_green = _q_sprite_colour[3][2+:2];
_d_pix_blue = _q_sprite_colour[3][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_3 = _q_detect_collision_3|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_38
end else begin
// __block_36
end
// __block_39
if ((_w_pix_visible_4)) begin
// __block_40
// __block_42
_d_pix_red = _q_sprite_colour[4][4+:2];
_d_pix_green = _q_sprite_colour[4][2+:2];
_d_pix_blue = _q_sprite_colour[4][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_4 = _q_detect_collision_4|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_43
end else begin
// __block_41
end
// __block_44
if ((_w_pix_visible_5)) begin
// __block_45
// __block_47
_d_pix_red = _q_sprite_colour[5][4+:2];
_d_pix_green = _q_sprite_colour[5][2+:2];
_d_pix_blue = _q_sprite_colour[5][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_5 = _q_detect_collision_5|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_48
end else begin
// __block_46
end
// __block_49
if ((_w_pix_visible_6)) begin
// __block_50
// __block_52
_d_pix_red = _q_sprite_colour[6][4+:2];
_d_pix_green = _q_sprite_colour[6][2+:2];
_d_pix_blue = _q_sprite_colour[6][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_6 = _q_detect_collision_6|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_53
end else begin
// __block_51
end
// __block_54
if ((_w_pix_visible_7)) begin
// __block_55
// __block_57
_d_pix_red = _q_sprite_colour[7][4+:2];
_d_pix_green = _q_sprite_colour[7][2+:2];
_d_pix_blue = _q_sprite_colour[7][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_7 = _q_detect_collision_7|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_58
end else begin
// __block_56
end
// __block_59
if ((_w_pix_visible_8)) begin
// __block_60
// __block_62
_d_pix_red = _q_sprite_colour[8][4+:2];
_d_pix_green = _q_sprite_colour[8][2+:2];
_d_pix_blue = _q_sprite_colour[8][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_8 = _q_detect_collision_8|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_63
end else begin
// __block_61
end
// __block_64
if ((_w_pix_visible_9)) begin
// __block_65
// __block_67
_d_pix_red = _q_sprite_colour[9][4+:2];
_d_pix_green = _q_sprite_colour[9][2+:2];
_d_pix_blue = _q_sprite_colour[9][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_9 = _q_detect_collision_9|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_68
end else begin
// __block_66
end
// __block_69
if ((_w_pix_visible_10)) begin
// __block_70
// __block_72
_d_pix_red = _q_sprite_colour[10][4+:2];
_d_pix_green = _q_sprite_colour[10][2+:2];
_d_pix_blue = _q_sprite_colour[10][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_10 = _q_detect_collision_10|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_73
end else begin
// __block_71
end
// __block_74
if ((_w_pix_visible_11)) begin
// __block_75
// __block_77
_d_pix_red = _q_sprite_colour[11][4+:2];
_d_pix_green = _q_sprite_colour[11][2+:2];
_d_pix_blue = _q_sprite_colour[11][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_11 = _q_detect_collision_11|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_78
end else begin
// __block_76
end
// __block_79
if ((_w_pix_visible_12)) begin
// __block_80
// __block_82
_d_pix_red = _q_sprite_colour[12][4+:2];
_d_pix_green = _q_sprite_colour[12][2+:2];
_d_pix_blue = _q_sprite_colour[12][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_12 = _q_detect_collision_12|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_83
end else begin
// __block_81
end
// __block_84
_d_output_collisions = (in_pix_x==639)&&(in_pix_y==479);
// __block_85
end else begin
// __block_18
end
// __block_86
// __block_87
end
// __block_88
if (in_sprite_writer_active) begin
// __block_89
// __block_91
  case (in_sprite_writer_sprite)
  0: begin
// __block_93_case
// __block_94
_d_tiles_0_addr1 = in_sprite_writer_line;
_d_tiles_0_wdata1 = in_sprite_writer_bitmap;
// __block_95
  end
  1: begin
// __block_96_case
// __block_97
_d_tiles_1_addr1 = in_sprite_writer_line;
_d_tiles_1_wdata1 = in_sprite_writer_bitmap;
// __block_98
  end
  2: begin
// __block_99_case
// __block_100
_d_tiles_2_addr1 = in_sprite_writer_line;
_d_tiles_2_wdata1 = in_sprite_writer_bitmap;
// __block_101
  end
  3: begin
// __block_102_case
// __block_103
_d_tiles_3_addr1 = in_sprite_writer_line;
_d_tiles_3_wdata1 = in_sprite_writer_bitmap;
// __block_104
  end
  4: begin
// __block_105_case
// __block_106
_d_tiles_4_addr1 = in_sprite_writer_line;
_d_tiles_4_wdata1 = in_sprite_writer_bitmap;
// __block_107
  end
  5: begin
// __block_108_case
// __block_109
_d_tiles_5_addr1 = in_sprite_writer_line;
_d_tiles_5_wdata1 = in_sprite_writer_bitmap;
// __block_110
  end
  6: begin
// __block_111_case
// __block_112
_d_tiles_6_addr1 = in_sprite_writer_line;
_d_tiles_6_wdata1 = in_sprite_writer_bitmap;
// __block_113
  end
  7: begin
// __block_114_case
// __block_115
_d_tiles_7_addr1 = in_sprite_writer_line;
_d_tiles_7_wdata1 = in_sprite_writer_bitmap;
// __block_116
  end
  8: begin
// __block_117_case
// __block_118
_d_tiles_8_addr1 = in_sprite_writer_line;
_d_tiles_8_wdata1 = in_sprite_writer_bitmap;
// __block_119
  end
  9: begin
// __block_120_case
// __block_121
_d_tiles_9_addr1 = in_sprite_writer_line;
_d_tiles_9_wdata1 = in_sprite_writer_bitmap;
// __block_122
  end
  10: begin
// __block_123_case
// __block_124
_d_tiles_10_addr1 = in_sprite_writer_line;
_d_tiles_10_wdata1 = in_sprite_writer_bitmap;
// __block_125
  end
  11: begin
// __block_126_case
// __block_127
_d_tiles_11_addr1 = in_sprite_writer_line;
_d_tiles_11_wdata1 = in_sprite_writer_bitmap;
// __block_128
  end
  12: begin
// __block_129_case
// __block_130
_d_tiles_12_addr1 = in_sprite_writer_line;
_d_tiles_12_wdata1 = in_sprite_writer_bitmap;
// __block_131
  end
endcase
// __block_92
// __block_132
end else begin
// __block_90
end
// __block_133
  case (in_sprite_layer_write)
  1: begin
// __block_135_case
// __block_136
_d_sprite_active[in_sprite_set_number] = in_sprite_set_active;
// __block_137
  end
  2: begin
// __block_138_case
// __block_139
_d_sprite_tile_number[in_sprite_set_number] = in_sprite_set_tile;
// __block_140
  end
  3: begin
// __block_141_case
// __block_142
_d_sprite_colour[in_sprite_set_number] = in_sprite_set_colour;
// __block_143
  end
  4: begin
// __block_144_case
// __block_145
_d_sprite_x[in_sprite_set_number] = in_sprite_set_x;
// __block_146
  end
  5: begin
// __block_147_case
// __block_148
_d_sprite_y[in_sprite_set_number] = in_sprite_set_y;
// __block_149
  end
  6: begin
// __block_150_case
// __block_151
_d_sprite_double[in_sprite_set_number] = in_sprite_set_double;
// __block_152
  end
  10: begin
// __block_153_case
// __block_154
if (in_sprite_update[10+:1]) begin
// __block_155
// __block_157
_d_sprite_tile_number[in_sprite_set_number] = _q_sprite_tile_number[in_sprite_set_number]+1;
// __block_158
end else begin
// __block_156
end
// __block_159
if (in_sprite_update[11+:1]||in_sprite_update[12+:1]) begin
// __block_160
// __block_162
_d_sprite_active[in_sprite_set_number] = (_w_sprite_offscreen_x||_w_sprite_offscreen_y)?0:_q_sprite_active[in_sprite_set_number];
// __block_163
end else begin
// __block_161
end
// __block_164
_d_sprite_x[in_sprite_set_number] = _w_sprite_offscreen_x?(($signed(_q_sprite_x[in_sprite_set_number])<$signed(_w_sprite_offscreen_negative))?$signed(640):_w_sprite_to_negative):_q_sprite_x[in_sprite_set_number]+_w_deltax;
_d_sprite_y[in_sprite_set_number] = _w_sprite_offscreen_y?(($signed(_q_sprite_y[in_sprite_set_number])<$signed(_w_sprite_offscreen_negative))?$signed(480):_w_sprite_to_negative):_q_sprite_y[in_sprite_set_number]+_w_deltay;
// __block_165
  end
endcase
// __block_134
// __block_166
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of sprite_layer
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_tilemap_mem_tiles16x16(
input      [8:0]                in_tiles16x16_addr0,
output reg  [15:0]     out_tiles16x16_rdata0,
output reg  [15:0]     out_tiles16x16_rdata1,
input      [0:0]             in_tiles16x16_wenable1,
input      [15:0]                 in_tiles16x16_wdata1,
input      [8:0]                in_tiles16x16_addr1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[511:0];
always @(posedge clock0) begin
  out_tiles16x16_rdata0 <= buffer[in_tiles16x16_addr0];
end
always @(posedge clock1) begin
  if (in_tiles16x16_wenable1) begin
    buffer[in_tiles16x16_addr1] <= in_tiles16x16_wdata1;
  end
end
initial begin
 buffer[0] = 0;
 buffer[1] = 0;
 buffer[2] = 0;
 buffer[3] = 0;
 buffer[4] = 0;
 buffer[5] = 0;
 buffer[6] = 0;
 buffer[7] = 0;
 buffer[8] = 0;
 buffer[9] = 0;
 buffer[10] = 0;
 buffer[11] = 0;
 buffer[12] = 0;
 buffer[13] = 0;
 buffer[14] = 0;
 buffer[15] = 0;
 buffer[16] = 0;
 buffer[17] = 0;
 buffer[18] = 0;
 buffer[19] = 0;
 buffer[20] = 0;
 buffer[21] = 0;
 buffer[22] = 0;
 buffer[23] = 0;
 buffer[24] = 0;
 buffer[25] = 0;
 buffer[26] = 0;
 buffer[27] = 0;
 buffer[28] = 0;
 buffer[29] = 0;
 buffer[30] = 0;
 buffer[31] = 0;
 buffer[32] = 0;
 buffer[33] = 0;
 buffer[34] = 0;
 buffer[35] = 0;
 buffer[36] = 0;
 buffer[37] = 0;
 buffer[38] = 0;
 buffer[39] = 0;
 buffer[40] = 0;
 buffer[41] = 0;
 buffer[42] = 0;
 buffer[43] = 0;
 buffer[44] = 0;
 buffer[45] = 0;
 buffer[46] = 0;
 buffer[47] = 0;
 buffer[48] = 0;
 buffer[49] = 0;
 buffer[50] = 0;
 buffer[51] = 0;
 buffer[52] = 0;
 buffer[53] = 0;
 buffer[54] = 0;
 buffer[55] = 0;
 buffer[56] = 0;
 buffer[57] = 0;
 buffer[58] = 0;
 buffer[59] = 0;
 buffer[60] = 0;
 buffer[61] = 0;
 buffer[62] = 0;
 buffer[63] = 0;
 buffer[64] = 0;
 buffer[65] = 0;
 buffer[66] = 0;
 buffer[67] = 0;
 buffer[68] = 0;
 buffer[69] = 0;
 buffer[70] = 0;
 buffer[71] = 0;
 buffer[72] = 0;
 buffer[73] = 0;
 buffer[74] = 0;
 buffer[75] = 0;
 buffer[76] = 0;
 buffer[77] = 0;
 buffer[78] = 0;
 buffer[79] = 0;
 buffer[80] = 0;
 buffer[81] = 0;
 buffer[82] = 0;
 buffer[83] = 0;
 buffer[84] = 0;
 buffer[85] = 0;
 buffer[86] = 0;
 buffer[87] = 0;
 buffer[88] = 0;
 buffer[89] = 0;
 buffer[90] = 0;
 buffer[91] = 0;
 buffer[92] = 0;
 buffer[93] = 0;
 buffer[94] = 0;
 buffer[95] = 0;
 buffer[96] = 0;
 buffer[97] = 0;
 buffer[98] = 0;
 buffer[99] = 0;
 buffer[100] = 0;
 buffer[101] = 0;
 buffer[102] = 0;
 buffer[103] = 0;
 buffer[104] = 0;
 buffer[105] = 0;
 buffer[106] = 0;
 buffer[107] = 0;
 buffer[108] = 0;
 buffer[109] = 0;
 buffer[110] = 0;
 buffer[111] = 0;
 buffer[112] = 0;
 buffer[113] = 0;
 buffer[114] = 0;
 buffer[115] = 0;
 buffer[116] = 0;
 buffer[117] = 0;
 buffer[118] = 0;
 buffer[119] = 0;
 buffer[120] = 0;
 buffer[121] = 0;
 buffer[122] = 0;
 buffer[123] = 0;
 buffer[124] = 0;
 buffer[125] = 0;
 buffer[126] = 0;
 buffer[127] = 0;
 buffer[128] = 0;
 buffer[129] = 0;
 buffer[130] = 0;
 buffer[131] = 0;
 buffer[132] = 0;
 buffer[133] = 0;
 buffer[134] = 0;
 buffer[135] = 0;
 buffer[136] = 0;
 buffer[137] = 0;
 buffer[138] = 0;
 buffer[139] = 0;
 buffer[140] = 0;
 buffer[141] = 0;
 buffer[142] = 0;
 buffer[143] = 0;
 buffer[144] = 0;
 buffer[145] = 0;
 buffer[146] = 0;
 buffer[147] = 0;
 buffer[148] = 0;
 buffer[149] = 0;
 buffer[150] = 0;
 buffer[151] = 0;
 buffer[152] = 0;
 buffer[153] = 0;
 buffer[154] = 0;
 buffer[155] = 0;
 buffer[156] = 0;
 buffer[157] = 0;
 buffer[158] = 0;
 buffer[159] = 0;
 buffer[160] = 0;
 buffer[161] = 0;
 buffer[162] = 0;
 buffer[163] = 0;
 buffer[164] = 0;
 buffer[165] = 0;
 buffer[166] = 0;
 buffer[167] = 0;
 buffer[168] = 0;
 buffer[169] = 0;
 buffer[170] = 0;
 buffer[171] = 0;
 buffer[172] = 0;
 buffer[173] = 0;
 buffer[174] = 0;
 buffer[175] = 0;
 buffer[176] = 0;
 buffer[177] = 0;
 buffer[178] = 0;
 buffer[179] = 0;
 buffer[180] = 0;
 buffer[181] = 0;
 buffer[182] = 0;
 buffer[183] = 0;
 buffer[184] = 0;
 buffer[185] = 0;
 buffer[186] = 0;
 buffer[187] = 0;
 buffer[188] = 0;
 buffer[189] = 0;
 buffer[190] = 0;
 buffer[191] = 0;
 buffer[192] = 0;
 buffer[193] = 0;
 buffer[194] = 0;
 buffer[195] = 0;
 buffer[196] = 0;
 buffer[197] = 0;
 buffer[198] = 0;
 buffer[199] = 0;
 buffer[200] = 0;
 buffer[201] = 0;
 buffer[202] = 0;
 buffer[203] = 0;
 buffer[204] = 0;
 buffer[205] = 0;
 buffer[206] = 0;
 buffer[207] = 0;
 buffer[208] = 0;
 buffer[209] = 0;
 buffer[210] = 0;
 buffer[211] = 0;
 buffer[212] = 0;
 buffer[213] = 0;
 buffer[214] = 0;
 buffer[215] = 0;
 buffer[216] = 0;
 buffer[217] = 0;
 buffer[218] = 0;
 buffer[219] = 0;
 buffer[220] = 0;
 buffer[221] = 0;
 buffer[222] = 0;
 buffer[223] = 0;
 buffer[224] = 0;
 buffer[225] = 0;
 buffer[226] = 0;
 buffer[227] = 0;
 buffer[228] = 0;
 buffer[229] = 0;
 buffer[230] = 0;
 buffer[231] = 0;
 buffer[232] = 0;
 buffer[233] = 0;
 buffer[234] = 0;
 buffer[235] = 0;
 buffer[236] = 0;
 buffer[237] = 0;
 buffer[238] = 0;
 buffer[239] = 0;
 buffer[240] = 0;
 buffer[241] = 0;
 buffer[242] = 0;
 buffer[243] = 0;
 buffer[244] = 0;
 buffer[245] = 0;
 buffer[246] = 0;
 buffer[247] = 0;
 buffer[248] = 0;
 buffer[249] = 0;
 buffer[250] = 0;
 buffer[251] = 0;
 buffer[252] = 0;
 buffer[253] = 0;
 buffer[254] = 0;
 buffer[255] = 0;
 buffer[256] = 0;
 buffer[257] = 0;
 buffer[258] = 0;
 buffer[259] = 0;
 buffer[260] = 0;
 buffer[261] = 0;
 buffer[262] = 0;
 buffer[263] = 0;
 buffer[264] = 0;
 buffer[265] = 0;
 buffer[266] = 0;
 buffer[267] = 0;
 buffer[268] = 0;
 buffer[269] = 0;
 buffer[270] = 0;
 buffer[271] = 0;
 buffer[272] = 0;
 buffer[273] = 0;
 buffer[274] = 0;
 buffer[275] = 0;
 buffer[276] = 0;
 buffer[277] = 0;
 buffer[278] = 0;
 buffer[279] = 0;
 buffer[280] = 0;
 buffer[281] = 0;
 buffer[282] = 0;
 buffer[283] = 0;
 buffer[284] = 0;
 buffer[285] = 0;
 buffer[286] = 0;
 buffer[287] = 0;
 buffer[288] = 0;
 buffer[289] = 0;
 buffer[290] = 0;
 buffer[291] = 0;
 buffer[292] = 0;
 buffer[293] = 0;
 buffer[294] = 0;
 buffer[295] = 0;
 buffer[296] = 0;
 buffer[297] = 0;
 buffer[298] = 0;
 buffer[299] = 0;
 buffer[300] = 0;
 buffer[301] = 0;
 buffer[302] = 0;
 buffer[303] = 0;
 buffer[304] = 0;
 buffer[305] = 0;
 buffer[306] = 0;
 buffer[307] = 0;
 buffer[308] = 0;
 buffer[309] = 0;
 buffer[310] = 0;
 buffer[311] = 0;
 buffer[312] = 0;
 buffer[313] = 0;
 buffer[314] = 0;
 buffer[315] = 0;
 buffer[316] = 0;
 buffer[317] = 0;
 buffer[318] = 0;
 buffer[319] = 0;
 buffer[320] = 0;
 buffer[321] = 0;
 buffer[322] = 0;
 buffer[323] = 0;
 buffer[324] = 0;
 buffer[325] = 0;
 buffer[326] = 0;
 buffer[327] = 0;
 buffer[328] = 0;
 buffer[329] = 0;
 buffer[330] = 0;
 buffer[331] = 0;
 buffer[332] = 0;
 buffer[333] = 0;
 buffer[334] = 0;
 buffer[335] = 0;
 buffer[336] = 0;
 buffer[337] = 0;
 buffer[338] = 0;
 buffer[339] = 0;
 buffer[340] = 0;
 buffer[341] = 0;
 buffer[342] = 0;
 buffer[343] = 0;
 buffer[344] = 0;
 buffer[345] = 0;
 buffer[346] = 0;
 buffer[347] = 0;
 buffer[348] = 0;
 buffer[349] = 0;
 buffer[350] = 0;
 buffer[351] = 0;
 buffer[352] = 0;
 buffer[353] = 0;
 buffer[354] = 0;
 buffer[355] = 0;
 buffer[356] = 0;
 buffer[357] = 0;
 buffer[358] = 0;
 buffer[359] = 0;
 buffer[360] = 0;
 buffer[361] = 0;
 buffer[362] = 0;
 buffer[363] = 0;
 buffer[364] = 0;
 buffer[365] = 0;
 buffer[366] = 0;
 buffer[367] = 0;
 buffer[368] = 0;
 buffer[369] = 0;
 buffer[370] = 0;
 buffer[371] = 0;
 buffer[372] = 0;
 buffer[373] = 0;
 buffer[374] = 0;
 buffer[375] = 0;
 buffer[376] = 0;
 buffer[377] = 0;
 buffer[378] = 0;
 buffer[379] = 0;
 buffer[380] = 0;
 buffer[381] = 0;
 buffer[382] = 0;
 buffer[383] = 0;
 buffer[384] = 0;
 buffer[385] = 0;
 buffer[386] = 0;
 buffer[387] = 0;
 buffer[388] = 0;
 buffer[389] = 0;
 buffer[390] = 0;
 buffer[391] = 0;
 buffer[392] = 0;
 buffer[393] = 0;
 buffer[394] = 0;
 buffer[395] = 0;
 buffer[396] = 0;
 buffer[397] = 0;
 buffer[398] = 0;
 buffer[399] = 0;
 buffer[400] = 0;
 buffer[401] = 0;
 buffer[402] = 0;
 buffer[403] = 0;
 buffer[404] = 0;
 buffer[405] = 0;
 buffer[406] = 0;
 buffer[407] = 0;
 buffer[408] = 0;
 buffer[409] = 0;
 buffer[410] = 0;
 buffer[411] = 0;
 buffer[412] = 0;
 buffer[413] = 0;
 buffer[414] = 0;
 buffer[415] = 0;
 buffer[416] = 0;
 buffer[417] = 0;
 buffer[418] = 0;
 buffer[419] = 0;
 buffer[420] = 0;
 buffer[421] = 0;
 buffer[422] = 0;
 buffer[423] = 0;
 buffer[424] = 0;
 buffer[425] = 0;
 buffer[426] = 0;
 buffer[427] = 0;
 buffer[428] = 0;
 buffer[429] = 0;
 buffer[430] = 0;
 buffer[431] = 0;
 buffer[432] = 0;
 buffer[433] = 0;
 buffer[434] = 0;
 buffer[435] = 0;
 buffer[436] = 0;
 buffer[437] = 0;
 buffer[438] = 0;
 buffer[439] = 0;
 buffer[440] = 0;
 buffer[441] = 0;
 buffer[442] = 0;
 buffer[443] = 0;
 buffer[444] = 0;
 buffer[445] = 0;
 buffer[446] = 0;
 buffer[447] = 0;
 buffer[448] = 0;
 buffer[449] = 0;
 buffer[450] = 0;
 buffer[451] = 0;
 buffer[452] = 0;
 buffer[453] = 0;
 buffer[454] = 0;
 buffer[455] = 0;
 buffer[456] = 0;
 buffer[457] = 0;
 buffer[458] = 0;
 buffer[459] = 0;
 buffer[460] = 0;
 buffer[461] = 0;
 buffer[462] = 0;
 buffer[463] = 0;
 buffer[464] = 0;
 buffer[465] = 0;
 buffer[466] = 0;
 buffer[467] = 0;
 buffer[468] = 0;
 buffer[469] = 0;
 buffer[470] = 0;
 buffer[471] = 0;
 buffer[472] = 0;
 buffer[473] = 0;
 buffer[474] = 0;
 buffer[475] = 0;
 buffer[476] = 0;
 buffer[477] = 0;
 buffer[478] = 0;
 buffer[479] = 0;
 buffer[480] = 0;
 buffer[481] = 0;
 buffer[482] = 0;
 buffer[483] = 0;
 buffer[484] = 0;
 buffer[485] = 0;
 buffer[486] = 0;
 buffer[487] = 0;
 buffer[488] = 0;
 buffer[489] = 0;
 buffer[490] = 0;
 buffer[491] = 0;
 buffer[492] = 0;
 buffer[493] = 0;
 buffer[494] = 0;
 buffer[495] = 0;
 buffer[496] = 0;
 buffer[497] = 0;
 buffer[498] = 0;
 buffer[499] = 0;
 buffer[500] = 0;
 buffer[501] = 0;
 buffer[502] = 0;
 buffer[503] = 0;
 buffer[504] = 0;
 buffer[505] = 0;
 buffer[506] = 0;
 buffer[507] = 0;
 buffer[508] = 0;
 buffer[509] = 0;
 buffer[510] = 0;
 buffer[511] = 0;
end

endmodule

module M_tilemap_mem_tiles(
input      [10:0]                in_tiles_addr0,
output reg  [17:0]     out_tiles_rdata0,
output reg  [17:0]     out_tiles_rdata1,
input      [0:0]             in_tiles_wenable1,
input      [17:0]                 in_tiles_wdata1,
input      [10:0]                in_tiles_addr1,
input      clock0,
input      clock1
);
reg  [17:0] buffer[1343:0];
always @(posedge clock0) begin
  out_tiles_rdata0 <= buffer[in_tiles_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_wenable1) begin
    buffer[in_tiles_addr1] <= in_tiles_wdata1;
  end
end
initial begin
 buffer[0] = 18'b100000000000000000;
 buffer[1] = 18'b100000000000000000;
 buffer[2] = 18'b100000000000000000;
 buffer[3] = 18'b100000000000000000;
 buffer[4] = 18'b100000000000000000;
 buffer[5] = 18'b100000000000000000;
 buffer[6] = 18'b100000000000000000;
 buffer[7] = 18'b100000000000000000;
 buffer[8] = 18'b100000000000000000;
 buffer[9] = 18'b100000000000000000;
 buffer[10] = 18'b100000000000000000;
 buffer[11] = 18'b100000000000000000;
 buffer[12] = 18'b100000000000000000;
 buffer[13] = 18'b100000000000000000;
 buffer[14] = 18'b100000000000000000;
 buffer[15] = 18'b100000000000000000;
 buffer[16] = 18'b100000000000000000;
 buffer[17] = 18'b100000000000000000;
 buffer[18] = 18'b100000000000000000;
 buffer[19] = 18'b100000000000000000;
 buffer[20] = 18'b100000000000000000;
 buffer[21] = 18'b100000000000000000;
 buffer[22] = 18'b100000000000000000;
 buffer[23] = 18'b100000000000000000;
 buffer[24] = 18'b100000000000000000;
 buffer[25] = 18'b100000000000000000;
 buffer[26] = 18'b100000000000000000;
 buffer[27] = 18'b100000000000000000;
 buffer[28] = 18'b100000000000000000;
 buffer[29] = 18'b100000000000000000;
 buffer[30] = 18'b100000000000000000;
 buffer[31] = 18'b100000000000000000;
 buffer[32] = 18'b100000000000000000;
 buffer[33] = 18'b100000000000000000;
 buffer[34] = 18'b100000000000000000;
 buffer[35] = 18'b100000000000000000;
 buffer[36] = 18'b100000000000000000;
 buffer[37] = 18'b100000000000000000;
 buffer[38] = 18'b100000000000000000;
 buffer[39] = 18'b100000000000000000;
 buffer[40] = 18'b100000000000000000;
 buffer[41] = 18'b100000000000000000;
 buffer[42] = 18'b100000000000000000;
 buffer[43] = 18'b100000000000000000;
 buffer[44] = 18'b100000000000000000;
 buffer[45] = 18'b100000000000000000;
 buffer[46] = 18'b100000000000000000;
 buffer[47] = 18'b100000000000000000;
 buffer[48] = 18'b100000000000000000;
 buffer[49] = 18'b100000000000000000;
 buffer[50] = 18'b100000000000000000;
 buffer[51] = 18'b100000000000000000;
 buffer[52] = 18'b100000000000000000;
 buffer[53] = 18'b100000000000000000;
 buffer[54] = 18'b100000000000000000;
 buffer[55] = 18'b100000000000000000;
 buffer[56] = 18'b100000000000000000;
 buffer[57] = 18'b100000000000000000;
 buffer[58] = 18'b100000000000000000;
 buffer[59] = 18'b100000000000000000;
 buffer[60] = 18'b100000000000000000;
 buffer[61] = 18'b100000000000000000;
 buffer[62] = 18'b100000000000000000;
 buffer[63] = 18'b100000000000000000;
 buffer[64] = 18'b100000000000000000;
 buffer[65] = 18'b100000000000000000;
 buffer[66] = 18'b100000000000000000;
 buffer[67] = 18'b100000000000000000;
 buffer[68] = 18'b100000000000000000;
 buffer[69] = 18'b100000000000000000;
 buffer[70] = 18'b100000000000000000;
 buffer[71] = 18'b100000000000000000;
 buffer[72] = 18'b100000000000000000;
 buffer[73] = 18'b100000000000000000;
 buffer[74] = 18'b100000000000000000;
 buffer[75] = 18'b100000000000000000;
 buffer[76] = 18'b100000000000000000;
 buffer[77] = 18'b100000000000000000;
 buffer[78] = 18'b100000000000000000;
 buffer[79] = 18'b100000000000000000;
 buffer[80] = 18'b100000000000000000;
 buffer[81] = 18'b100000000000000000;
 buffer[82] = 18'b100000000000000000;
 buffer[83] = 18'b100000000000000000;
 buffer[84] = 18'b100000000000000000;
 buffer[85] = 18'b100000000000000000;
 buffer[86] = 18'b100000000000000000;
 buffer[87] = 18'b100000000000000000;
 buffer[88] = 18'b100000000000000000;
 buffer[89] = 18'b100000000000000000;
 buffer[90] = 18'b100000000000000000;
 buffer[91] = 18'b100000000000000000;
 buffer[92] = 18'b100000000000000000;
 buffer[93] = 18'b100000000000000000;
 buffer[94] = 18'b100000000000000000;
 buffer[95] = 18'b100000000000000000;
 buffer[96] = 18'b100000000000000000;
 buffer[97] = 18'b100000000000000000;
 buffer[98] = 18'b100000000000000000;
 buffer[99] = 18'b100000000000000000;
 buffer[100] = 18'b100000000000000000;
 buffer[101] = 18'b100000000000000000;
 buffer[102] = 18'b100000000000000000;
 buffer[103] = 18'b100000000000000000;
 buffer[104] = 18'b100000000000000000;
 buffer[105] = 18'b100000000000000000;
 buffer[106] = 18'b100000000000000000;
 buffer[107] = 18'b100000000000000000;
 buffer[108] = 18'b100000000000000000;
 buffer[109] = 18'b100000000000000000;
 buffer[110] = 18'b100000000000000000;
 buffer[111] = 18'b100000000000000000;
 buffer[112] = 18'b100000000000000000;
 buffer[113] = 18'b100000000000000000;
 buffer[114] = 18'b100000000000000000;
 buffer[115] = 18'b100000000000000000;
 buffer[116] = 18'b100000000000000000;
 buffer[117] = 18'b100000000000000000;
 buffer[118] = 18'b100000000000000000;
 buffer[119] = 18'b100000000000000000;
 buffer[120] = 18'b100000000000000000;
 buffer[121] = 18'b100000000000000000;
 buffer[122] = 18'b100000000000000000;
 buffer[123] = 18'b100000000000000000;
 buffer[124] = 18'b100000000000000000;
 buffer[125] = 18'b100000000000000000;
 buffer[126] = 18'b100000000000000000;
 buffer[127] = 18'b100000000000000000;
 buffer[128] = 18'b100000000000000000;
 buffer[129] = 18'b100000000000000000;
 buffer[130] = 18'b100000000000000000;
 buffer[131] = 18'b100000000000000000;
 buffer[132] = 18'b100000000000000000;
 buffer[133] = 18'b100000000000000000;
 buffer[134] = 18'b100000000000000000;
 buffer[135] = 18'b100000000000000000;
 buffer[136] = 18'b100000000000000000;
 buffer[137] = 18'b100000000000000000;
 buffer[138] = 18'b100000000000000000;
 buffer[139] = 18'b100000000000000000;
 buffer[140] = 18'b100000000000000000;
 buffer[141] = 18'b100000000000000000;
 buffer[142] = 18'b100000000000000000;
 buffer[143] = 18'b100000000000000000;
 buffer[144] = 18'b100000000000000000;
 buffer[145] = 18'b100000000000000000;
 buffer[146] = 18'b100000000000000000;
 buffer[147] = 18'b100000000000000000;
 buffer[148] = 18'b100000000000000000;
 buffer[149] = 18'b100000000000000000;
 buffer[150] = 18'b100000000000000000;
 buffer[151] = 18'b100000000000000000;
 buffer[152] = 18'b100000000000000000;
 buffer[153] = 18'b100000000000000000;
 buffer[154] = 18'b100000000000000000;
 buffer[155] = 18'b100000000000000000;
 buffer[156] = 18'b100000000000000000;
 buffer[157] = 18'b100000000000000000;
 buffer[158] = 18'b100000000000000000;
 buffer[159] = 18'b100000000000000000;
 buffer[160] = 18'b100000000000000000;
 buffer[161] = 18'b100000000000000000;
 buffer[162] = 18'b100000000000000000;
 buffer[163] = 18'b100000000000000000;
 buffer[164] = 18'b100000000000000000;
 buffer[165] = 18'b100000000000000000;
 buffer[166] = 18'b100000000000000000;
 buffer[167] = 18'b100000000000000000;
 buffer[168] = 18'b100000000000000000;
 buffer[169] = 18'b100000000000000000;
 buffer[170] = 18'b100000000000000000;
 buffer[171] = 18'b100000000000000000;
 buffer[172] = 18'b100000000000000000;
 buffer[173] = 18'b100000000000000000;
 buffer[174] = 18'b100000000000000000;
 buffer[175] = 18'b100000000000000000;
 buffer[176] = 18'b100000000000000000;
 buffer[177] = 18'b100000000000000000;
 buffer[178] = 18'b100000000000000000;
 buffer[179] = 18'b100000000000000000;
 buffer[180] = 18'b100000000000000000;
 buffer[181] = 18'b100000000000000000;
 buffer[182] = 18'b100000000000000000;
 buffer[183] = 18'b100000000000000000;
 buffer[184] = 18'b100000000000000000;
 buffer[185] = 18'b100000000000000000;
 buffer[186] = 18'b100000000000000000;
 buffer[187] = 18'b100000000000000000;
 buffer[188] = 18'b100000000000000000;
 buffer[189] = 18'b100000000000000000;
 buffer[190] = 18'b100000000000000000;
 buffer[191] = 18'b100000000000000000;
 buffer[192] = 18'b100000000000000000;
 buffer[193] = 18'b100000000000000000;
 buffer[194] = 18'b100000000000000000;
 buffer[195] = 18'b100000000000000000;
 buffer[196] = 18'b100000000000000000;
 buffer[197] = 18'b100000000000000000;
 buffer[198] = 18'b100000000000000000;
 buffer[199] = 18'b100000000000000000;
 buffer[200] = 18'b100000000000000000;
 buffer[201] = 18'b100000000000000000;
 buffer[202] = 18'b100000000000000000;
 buffer[203] = 18'b100000000000000000;
 buffer[204] = 18'b100000000000000000;
 buffer[205] = 18'b100000000000000000;
 buffer[206] = 18'b100000000000000000;
 buffer[207] = 18'b100000000000000000;
 buffer[208] = 18'b100000000000000000;
 buffer[209] = 18'b100000000000000000;
 buffer[210] = 18'b100000000000000000;
 buffer[211] = 18'b100000000000000000;
 buffer[212] = 18'b100000000000000000;
 buffer[213] = 18'b100000000000000000;
 buffer[214] = 18'b100000000000000000;
 buffer[215] = 18'b100000000000000000;
 buffer[216] = 18'b100000000000000000;
 buffer[217] = 18'b100000000000000000;
 buffer[218] = 18'b100000000000000000;
 buffer[219] = 18'b100000000000000000;
 buffer[220] = 18'b100000000000000000;
 buffer[221] = 18'b100000000000000000;
 buffer[222] = 18'b100000000000000000;
 buffer[223] = 18'b100000000000000000;
 buffer[224] = 18'b100000000000000000;
 buffer[225] = 18'b100000000000000000;
 buffer[226] = 18'b100000000000000000;
 buffer[227] = 18'b100000000000000000;
 buffer[228] = 18'b100000000000000000;
 buffer[229] = 18'b100000000000000000;
 buffer[230] = 18'b100000000000000000;
 buffer[231] = 18'b100000000000000000;
 buffer[232] = 18'b100000000000000000;
 buffer[233] = 18'b100000000000000000;
 buffer[234] = 18'b100000000000000000;
 buffer[235] = 18'b100000000000000000;
 buffer[236] = 18'b100000000000000000;
 buffer[237] = 18'b100000000000000000;
 buffer[238] = 18'b100000000000000000;
 buffer[239] = 18'b100000000000000000;
 buffer[240] = 18'b100000000000000000;
 buffer[241] = 18'b100000000000000000;
 buffer[242] = 18'b100000000000000000;
 buffer[243] = 18'b100000000000000000;
 buffer[244] = 18'b100000000000000000;
 buffer[245] = 18'b100000000000000000;
 buffer[246] = 18'b100000000000000000;
 buffer[247] = 18'b100000000000000000;
 buffer[248] = 18'b100000000000000000;
 buffer[249] = 18'b100000000000000000;
 buffer[250] = 18'b100000000000000000;
 buffer[251] = 18'b100000000000000000;
 buffer[252] = 18'b100000000000000000;
 buffer[253] = 18'b100000000000000000;
 buffer[254] = 18'b100000000000000000;
 buffer[255] = 18'b100000000000000000;
 buffer[256] = 18'b100000000000000000;
 buffer[257] = 18'b100000000000000000;
 buffer[258] = 18'b100000000000000000;
 buffer[259] = 18'b100000000000000000;
 buffer[260] = 18'b100000000000000000;
 buffer[261] = 18'b100000000000000000;
 buffer[262] = 18'b100000000000000000;
 buffer[263] = 18'b100000000000000000;
 buffer[264] = 18'b100000000000000000;
 buffer[265] = 18'b100000000000000000;
 buffer[266] = 18'b100000000000000000;
 buffer[267] = 18'b100000000000000000;
 buffer[268] = 18'b100000000000000000;
 buffer[269] = 18'b100000000000000000;
 buffer[270] = 18'b100000000000000000;
 buffer[271] = 18'b100000000000000000;
 buffer[272] = 18'b100000000000000000;
 buffer[273] = 18'b100000000000000000;
 buffer[274] = 18'b100000000000000000;
 buffer[275] = 18'b100000000000000000;
 buffer[276] = 18'b100000000000000000;
 buffer[277] = 18'b100000000000000000;
 buffer[278] = 18'b100000000000000000;
 buffer[279] = 18'b100000000000000000;
 buffer[280] = 18'b100000000000000000;
 buffer[281] = 18'b100000000000000000;
 buffer[282] = 18'b100000000000000000;
 buffer[283] = 18'b100000000000000000;
 buffer[284] = 18'b100000000000000000;
 buffer[285] = 18'b100000000000000000;
 buffer[286] = 18'b100000000000000000;
 buffer[287] = 18'b100000000000000000;
 buffer[288] = 18'b100000000000000000;
 buffer[289] = 18'b100000000000000000;
 buffer[290] = 18'b100000000000000000;
 buffer[291] = 18'b100000000000000000;
 buffer[292] = 18'b100000000000000000;
 buffer[293] = 18'b100000000000000000;
 buffer[294] = 18'b100000000000000000;
 buffer[295] = 18'b100000000000000000;
 buffer[296] = 18'b100000000000000000;
 buffer[297] = 18'b100000000000000000;
 buffer[298] = 18'b100000000000000000;
 buffer[299] = 18'b100000000000000000;
 buffer[300] = 18'b100000000000000000;
 buffer[301] = 18'b100000000000000000;
 buffer[302] = 18'b100000000000000000;
 buffer[303] = 18'b100000000000000000;
 buffer[304] = 18'b100000000000000000;
 buffer[305] = 18'b100000000000000000;
 buffer[306] = 18'b100000000000000000;
 buffer[307] = 18'b100000000000000000;
 buffer[308] = 18'b100000000000000000;
 buffer[309] = 18'b100000000000000000;
 buffer[310] = 18'b100000000000000000;
 buffer[311] = 18'b100000000000000000;
 buffer[312] = 18'b100000000000000000;
 buffer[313] = 18'b100000000000000000;
 buffer[314] = 18'b100000000000000000;
 buffer[315] = 18'b100000000000000000;
 buffer[316] = 18'b100000000000000000;
 buffer[317] = 18'b100000000000000000;
 buffer[318] = 18'b100000000000000000;
 buffer[319] = 18'b100000000000000000;
 buffer[320] = 18'b100000000000000000;
 buffer[321] = 18'b100000000000000000;
 buffer[322] = 18'b100000000000000000;
 buffer[323] = 18'b100000000000000000;
 buffer[324] = 18'b100000000000000000;
 buffer[325] = 18'b100000000000000000;
 buffer[326] = 18'b100000000000000000;
 buffer[327] = 18'b100000000000000000;
 buffer[328] = 18'b100000000000000000;
 buffer[329] = 18'b100000000000000000;
 buffer[330] = 18'b100000000000000000;
 buffer[331] = 18'b100000000000000000;
 buffer[332] = 18'b100000000000000000;
 buffer[333] = 18'b100000000000000000;
 buffer[334] = 18'b100000000000000000;
 buffer[335] = 18'b100000000000000000;
 buffer[336] = 18'b100000000000000000;
 buffer[337] = 18'b100000000000000000;
 buffer[338] = 18'b100000000000000000;
 buffer[339] = 18'b100000000000000000;
 buffer[340] = 18'b100000000000000000;
 buffer[341] = 18'b100000000000000000;
 buffer[342] = 18'b100000000000000000;
 buffer[343] = 18'b100000000000000000;
 buffer[344] = 18'b100000000000000000;
 buffer[345] = 18'b100000000000000000;
 buffer[346] = 18'b100000000000000000;
 buffer[347] = 18'b100000000000000000;
 buffer[348] = 18'b100000000000000000;
 buffer[349] = 18'b100000000000000000;
 buffer[350] = 18'b100000000000000000;
 buffer[351] = 18'b100000000000000000;
 buffer[352] = 18'b100000000000000000;
 buffer[353] = 18'b100000000000000000;
 buffer[354] = 18'b100000000000000000;
 buffer[355] = 18'b100000000000000000;
 buffer[356] = 18'b100000000000000000;
 buffer[357] = 18'b100000000000000000;
 buffer[358] = 18'b100000000000000000;
 buffer[359] = 18'b100000000000000000;
 buffer[360] = 18'b100000000000000000;
 buffer[361] = 18'b100000000000000000;
 buffer[362] = 18'b100000000000000000;
 buffer[363] = 18'b100000000000000000;
 buffer[364] = 18'b100000000000000000;
 buffer[365] = 18'b100000000000000000;
 buffer[366] = 18'b100000000000000000;
 buffer[367] = 18'b100000000000000000;
 buffer[368] = 18'b100000000000000000;
 buffer[369] = 18'b100000000000000000;
 buffer[370] = 18'b100000000000000000;
 buffer[371] = 18'b100000000000000000;
 buffer[372] = 18'b100000000000000000;
 buffer[373] = 18'b100000000000000000;
 buffer[374] = 18'b100000000000000000;
 buffer[375] = 18'b100000000000000000;
 buffer[376] = 18'b100000000000000000;
 buffer[377] = 18'b100000000000000000;
 buffer[378] = 18'b100000000000000000;
 buffer[379] = 18'b100000000000000000;
 buffer[380] = 18'b100000000000000000;
 buffer[381] = 18'b100000000000000000;
 buffer[382] = 18'b100000000000000000;
 buffer[383] = 18'b100000000000000000;
 buffer[384] = 18'b100000000000000000;
 buffer[385] = 18'b100000000000000000;
 buffer[386] = 18'b100000000000000000;
 buffer[387] = 18'b100000000000000000;
 buffer[388] = 18'b100000000000000000;
 buffer[389] = 18'b100000000000000000;
 buffer[390] = 18'b100000000000000000;
 buffer[391] = 18'b100000000000000000;
 buffer[392] = 18'b100000000000000000;
 buffer[393] = 18'b100000000000000000;
 buffer[394] = 18'b100000000000000000;
 buffer[395] = 18'b100000000000000000;
 buffer[396] = 18'b100000000000000000;
 buffer[397] = 18'b100000000000000000;
 buffer[398] = 18'b100000000000000000;
 buffer[399] = 18'b100000000000000000;
 buffer[400] = 18'b100000000000000000;
 buffer[401] = 18'b100000000000000000;
 buffer[402] = 18'b100000000000000000;
 buffer[403] = 18'b100000000000000000;
 buffer[404] = 18'b100000000000000000;
 buffer[405] = 18'b100000000000000000;
 buffer[406] = 18'b100000000000000000;
 buffer[407] = 18'b100000000000000000;
 buffer[408] = 18'b100000000000000000;
 buffer[409] = 18'b100000000000000000;
 buffer[410] = 18'b100000000000000000;
 buffer[411] = 18'b100000000000000000;
 buffer[412] = 18'b100000000000000000;
 buffer[413] = 18'b100000000000000000;
 buffer[414] = 18'b100000000000000000;
 buffer[415] = 18'b100000000000000000;
 buffer[416] = 18'b100000000000000000;
 buffer[417] = 18'b100000000000000000;
 buffer[418] = 18'b100000000000000000;
 buffer[419] = 18'b100000000000000000;
 buffer[420] = 18'b100000000000000000;
 buffer[421] = 18'b100000000000000000;
 buffer[422] = 18'b100000000000000000;
 buffer[423] = 18'b100000000000000000;
 buffer[424] = 18'b100000000000000000;
 buffer[425] = 18'b100000000000000000;
 buffer[426] = 18'b100000000000000000;
 buffer[427] = 18'b100000000000000000;
 buffer[428] = 18'b100000000000000000;
 buffer[429] = 18'b100000000000000000;
 buffer[430] = 18'b100000000000000000;
 buffer[431] = 18'b100000000000000000;
 buffer[432] = 18'b100000000000000000;
 buffer[433] = 18'b100000000000000000;
 buffer[434] = 18'b100000000000000000;
 buffer[435] = 18'b100000000000000000;
 buffer[436] = 18'b100000000000000000;
 buffer[437] = 18'b100000000000000000;
 buffer[438] = 18'b100000000000000000;
 buffer[439] = 18'b100000000000000000;
 buffer[440] = 18'b100000000000000000;
 buffer[441] = 18'b100000000000000000;
 buffer[442] = 18'b100000000000000000;
 buffer[443] = 18'b100000000000000000;
 buffer[444] = 18'b100000000000000000;
 buffer[445] = 18'b100000000000000000;
 buffer[446] = 18'b100000000000000000;
 buffer[447] = 18'b100000000000000000;
 buffer[448] = 18'b100000000000000000;
 buffer[449] = 18'b100000000000000000;
 buffer[450] = 18'b100000000000000000;
 buffer[451] = 18'b100000000000000000;
 buffer[452] = 18'b100000000000000000;
 buffer[453] = 18'b100000000000000000;
 buffer[454] = 18'b100000000000000000;
 buffer[455] = 18'b100000000000000000;
 buffer[456] = 18'b100000000000000000;
 buffer[457] = 18'b100000000000000000;
 buffer[458] = 18'b100000000000000000;
 buffer[459] = 18'b100000000000000000;
 buffer[460] = 18'b100000000000000000;
 buffer[461] = 18'b100000000000000000;
 buffer[462] = 18'b100000000000000000;
 buffer[463] = 18'b100000000000000000;
 buffer[464] = 18'b100000000000000000;
 buffer[465] = 18'b100000000000000000;
 buffer[466] = 18'b100000000000000000;
 buffer[467] = 18'b100000000000000000;
 buffer[468] = 18'b100000000000000000;
 buffer[469] = 18'b100000000000000000;
 buffer[470] = 18'b100000000000000000;
 buffer[471] = 18'b100000000000000000;
 buffer[472] = 18'b100000000000000000;
 buffer[473] = 18'b100000000000000000;
 buffer[474] = 18'b100000000000000000;
 buffer[475] = 18'b100000000000000000;
 buffer[476] = 18'b100000000000000000;
 buffer[477] = 18'b100000000000000000;
 buffer[478] = 18'b100000000000000000;
 buffer[479] = 18'b100000000000000000;
 buffer[480] = 18'b100000000000000000;
 buffer[481] = 18'b100000000000000000;
 buffer[482] = 18'b100000000000000000;
 buffer[483] = 18'b100000000000000000;
 buffer[484] = 18'b100000000000000000;
 buffer[485] = 18'b100000000000000000;
 buffer[486] = 18'b100000000000000000;
 buffer[487] = 18'b100000000000000000;
 buffer[488] = 18'b100000000000000000;
 buffer[489] = 18'b100000000000000000;
 buffer[490] = 18'b100000000000000000;
 buffer[491] = 18'b100000000000000000;
 buffer[492] = 18'b100000000000000000;
 buffer[493] = 18'b100000000000000000;
 buffer[494] = 18'b100000000000000000;
 buffer[495] = 18'b100000000000000000;
 buffer[496] = 18'b100000000000000000;
 buffer[497] = 18'b100000000000000000;
 buffer[498] = 18'b100000000000000000;
 buffer[499] = 18'b100000000000000000;
 buffer[500] = 18'b100000000000000000;
 buffer[501] = 18'b100000000000000000;
 buffer[502] = 18'b100000000000000000;
 buffer[503] = 18'b100000000000000000;
 buffer[504] = 18'b100000000000000000;
 buffer[505] = 18'b100000000000000000;
 buffer[506] = 18'b100000000000000000;
 buffer[507] = 18'b100000000000000000;
 buffer[508] = 18'b100000000000000000;
 buffer[509] = 18'b100000000000000000;
 buffer[510] = 18'b100000000000000000;
 buffer[511] = 18'b100000000000000000;
 buffer[512] = 18'b100000000000000000;
 buffer[513] = 18'b100000000000000000;
 buffer[514] = 18'b100000000000000000;
 buffer[515] = 18'b100000000000000000;
 buffer[516] = 18'b100000000000000000;
 buffer[517] = 18'b100000000000000000;
 buffer[518] = 18'b100000000000000000;
 buffer[519] = 18'b100000000000000000;
 buffer[520] = 18'b100000000000000000;
 buffer[521] = 18'b100000000000000000;
 buffer[522] = 18'b100000000000000000;
 buffer[523] = 18'b100000000000000000;
 buffer[524] = 18'b100000000000000000;
 buffer[525] = 18'b100000000000000000;
 buffer[526] = 18'b100000000000000000;
 buffer[527] = 18'b100000000000000000;
 buffer[528] = 18'b100000000000000000;
 buffer[529] = 18'b100000000000000000;
 buffer[530] = 18'b100000000000000000;
 buffer[531] = 18'b100000000000000000;
 buffer[532] = 18'b100000000000000000;
 buffer[533] = 18'b100000000000000000;
 buffer[534] = 18'b100000000000000000;
 buffer[535] = 18'b100000000000000000;
 buffer[536] = 18'b100000000000000000;
 buffer[537] = 18'b100000000000000000;
 buffer[538] = 18'b100000000000000000;
 buffer[539] = 18'b100000000000000000;
 buffer[540] = 18'b100000000000000000;
 buffer[541] = 18'b100000000000000000;
 buffer[542] = 18'b100000000000000000;
 buffer[543] = 18'b100000000000000000;
 buffer[544] = 18'b100000000000000000;
 buffer[545] = 18'b100000000000000000;
 buffer[546] = 18'b100000000000000000;
 buffer[547] = 18'b100000000000000000;
 buffer[548] = 18'b100000000000000000;
 buffer[549] = 18'b100000000000000000;
 buffer[550] = 18'b100000000000000000;
 buffer[551] = 18'b100000000000000000;
 buffer[552] = 18'b100000000000000000;
 buffer[553] = 18'b100000000000000000;
 buffer[554] = 18'b100000000000000000;
 buffer[555] = 18'b100000000000000000;
 buffer[556] = 18'b100000000000000000;
 buffer[557] = 18'b100000000000000000;
 buffer[558] = 18'b100000000000000000;
 buffer[559] = 18'b100000000000000000;
 buffer[560] = 18'b100000000000000000;
 buffer[561] = 18'b100000000000000000;
 buffer[562] = 18'b100000000000000000;
 buffer[563] = 18'b100000000000000000;
 buffer[564] = 18'b100000000000000000;
 buffer[565] = 18'b100000000000000000;
 buffer[566] = 18'b100000000000000000;
 buffer[567] = 18'b100000000000000000;
 buffer[568] = 18'b100000000000000000;
 buffer[569] = 18'b100000000000000000;
 buffer[570] = 18'b100000000000000000;
 buffer[571] = 18'b100000000000000000;
 buffer[572] = 18'b100000000000000000;
 buffer[573] = 18'b100000000000000000;
 buffer[574] = 18'b100000000000000000;
 buffer[575] = 18'b100000000000000000;
 buffer[576] = 18'b100000000000000000;
 buffer[577] = 18'b100000000000000000;
 buffer[578] = 18'b100000000000000000;
 buffer[579] = 18'b100000000000000000;
 buffer[580] = 18'b100000000000000000;
 buffer[581] = 18'b100000000000000000;
 buffer[582] = 18'b100000000000000000;
 buffer[583] = 18'b100000000000000000;
 buffer[584] = 18'b100000000000000000;
 buffer[585] = 18'b100000000000000000;
 buffer[586] = 18'b100000000000000000;
 buffer[587] = 18'b100000000000000000;
 buffer[588] = 18'b100000000000000000;
 buffer[589] = 18'b100000000000000000;
 buffer[590] = 18'b100000000000000000;
 buffer[591] = 18'b100000000000000000;
 buffer[592] = 18'b100000000000000000;
 buffer[593] = 18'b100000000000000000;
 buffer[594] = 18'b100000000000000000;
 buffer[595] = 18'b100000000000000000;
 buffer[596] = 18'b100000000000000000;
 buffer[597] = 18'b100000000000000000;
 buffer[598] = 18'b100000000000000000;
 buffer[599] = 18'b100000000000000000;
 buffer[600] = 18'b100000000000000000;
 buffer[601] = 18'b100000000000000000;
 buffer[602] = 18'b100000000000000000;
 buffer[603] = 18'b100000000000000000;
 buffer[604] = 18'b100000000000000000;
 buffer[605] = 18'b100000000000000000;
 buffer[606] = 18'b100000000000000000;
 buffer[607] = 18'b100000000000000000;
 buffer[608] = 18'b100000000000000000;
 buffer[609] = 18'b100000000000000000;
 buffer[610] = 18'b100000000000000000;
 buffer[611] = 18'b100000000000000000;
 buffer[612] = 18'b100000000000000000;
 buffer[613] = 18'b100000000000000000;
 buffer[614] = 18'b100000000000000000;
 buffer[615] = 18'b100000000000000000;
 buffer[616] = 18'b100000000000000000;
 buffer[617] = 18'b100000000000000000;
 buffer[618] = 18'b100000000000000000;
 buffer[619] = 18'b100000000000000000;
 buffer[620] = 18'b100000000000000000;
 buffer[621] = 18'b100000000000000000;
 buffer[622] = 18'b100000000000000000;
 buffer[623] = 18'b100000000000000000;
 buffer[624] = 18'b100000000000000000;
 buffer[625] = 18'b100000000000000000;
 buffer[626] = 18'b100000000000000000;
 buffer[627] = 18'b100000000000000000;
 buffer[628] = 18'b100000000000000000;
 buffer[629] = 18'b100000000000000000;
 buffer[630] = 18'b100000000000000000;
 buffer[631] = 18'b100000000000000000;
 buffer[632] = 18'b100000000000000000;
 buffer[633] = 18'b100000000000000000;
 buffer[634] = 18'b100000000000000000;
 buffer[635] = 18'b100000000000000000;
 buffer[636] = 18'b100000000000000000;
 buffer[637] = 18'b100000000000000000;
 buffer[638] = 18'b100000000000000000;
 buffer[639] = 18'b100000000000000000;
 buffer[640] = 18'b100000000000000000;
 buffer[641] = 18'b100000000000000000;
 buffer[642] = 18'b100000000000000000;
 buffer[643] = 18'b100000000000000000;
 buffer[644] = 18'b100000000000000000;
 buffer[645] = 18'b100000000000000000;
 buffer[646] = 18'b100000000000000000;
 buffer[647] = 18'b100000000000000000;
 buffer[648] = 18'b100000000000000000;
 buffer[649] = 18'b100000000000000000;
 buffer[650] = 18'b100000000000000000;
 buffer[651] = 18'b100000000000000000;
 buffer[652] = 18'b100000000000000000;
 buffer[653] = 18'b100000000000000000;
 buffer[654] = 18'b100000000000000000;
 buffer[655] = 18'b100000000000000000;
 buffer[656] = 18'b100000000000000000;
 buffer[657] = 18'b100000000000000000;
 buffer[658] = 18'b100000000000000000;
 buffer[659] = 18'b100000000000000000;
 buffer[660] = 18'b100000000000000000;
 buffer[661] = 18'b100000000000000000;
 buffer[662] = 18'b100000000000000000;
 buffer[663] = 18'b100000000000000000;
 buffer[664] = 18'b100000000000000000;
 buffer[665] = 18'b100000000000000000;
 buffer[666] = 18'b100000000000000000;
 buffer[667] = 18'b100000000000000000;
 buffer[668] = 18'b100000000000000000;
 buffer[669] = 18'b100000000000000000;
 buffer[670] = 18'b100000000000000000;
 buffer[671] = 18'b100000000000000000;
 buffer[672] = 18'b100000000000000000;
 buffer[673] = 18'b100000000000000000;
 buffer[674] = 18'b100000000000000000;
 buffer[675] = 18'b100000000000000000;
 buffer[676] = 18'b100000000000000000;
 buffer[677] = 18'b100000000000000000;
 buffer[678] = 18'b100000000000000000;
 buffer[679] = 18'b100000000000000000;
 buffer[680] = 18'b100000000000000000;
 buffer[681] = 18'b100000000000000000;
 buffer[682] = 18'b100000000000000000;
 buffer[683] = 18'b100000000000000000;
 buffer[684] = 18'b100000000000000000;
 buffer[685] = 18'b100000000000000000;
 buffer[686] = 18'b100000000000000000;
 buffer[687] = 18'b100000000000000000;
 buffer[688] = 18'b100000000000000000;
 buffer[689] = 18'b100000000000000000;
 buffer[690] = 18'b100000000000000000;
 buffer[691] = 18'b100000000000000000;
 buffer[692] = 18'b100000000000000000;
 buffer[693] = 18'b100000000000000000;
 buffer[694] = 18'b100000000000000000;
 buffer[695] = 18'b100000000000000000;
 buffer[696] = 18'b100000000000000000;
 buffer[697] = 18'b100000000000000000;
 buffer[698] = 18'b100000000000000000;
 buffer[699] = 18'b100000000000000000;
 buffer[700] = 18'b100000000000000000;
 buffer[701] = 18'b100000000000000000;
 buffer[702] = 18'b100000000000000000;
 buffer[703] = 18'b100000000000000000;
 buffer[704] = 18'b100000000000000000;
 buffer[705] = 18'b100000000000000000;
 buffer[706] = 18'b100000000000000000;
 buffer[707] = 18'b100000000000000000;
 buffer[708] = 18'b100000000000000000;
 buffer[709] = 18'b100000000000000000;
 buffer[710] = 18'b100000000000000000;
 buffer[711] = 18'b100000000000000000;
 buffer[712] = 18'b100000000000000000;
 buffer[713] = 18'b100000000000000000;
 buffer[714] = 18'b100000000000000000;
 buffer[715] = 18'b100000000000000000;
 buffer[716] = 18'b100000000000000000;
 buffer[717] = 18'b100000000000000000;
 buffer[718] = 18'b100000000000000000;
 buffer[719] = 18'b100000000000000000;
 buffer[720] = 18'b100000000000000000;
 buffer[721] = 18'b100000000000000000;
 buffer[722] = 18'b100000000000000000;
 buffer[723] = 18'b100000000000000000;
 buffer[724] = 18'b100000000000000000;
 buffer[725] = 18'b100000000000000000;
 buffer[726] = 18'b100000000000000000;
 buffer[727] = 18'b100000000000000000;
 buffer[728] = 18'b100000000000000000;
 buffer[729] = 18'b100000000000000000;
 buffer[730] = 18'b100000000000000000;
 buffer[731] = 18'b100000000000000000;
 buffer[732] = 18'b100000000000000000;
 buffer[733] = 18'b100000000000000000;
 buffer[734] = 18'b100000000000000000;
 buffer[735] = 18'b100000000000000000;
 buffer[736] = 18'b100000000000000000;
 buffer[737] = 18'b100000000000000000;
 buffer[738] = 18'b100000000000000000;
 buffer[739] = 18'b100000000000000000;
 buffer[740] = 18'b100000000000000000;
 buffer[741] = 18'b100000000000000000;
 buffer[742] = 18'b100000000000000000;
 buffer[743] = 18'b100000000000000000;
 buffer[744] = 18'b100000000000000000;
 buffer[745] = 18'b100000000000000000;
 buffer[746] = 18'b100000000000000000;
 buffer[747] = 18'b100000000000000000;
 buffer[748] = 18'b100000000000000000;
 buffer[749] = 18'b100000000000000000;
 buffer[750] = 18'b100000000000000000;
 buffer[751] = 18'b100000000000000000;
 buffer[752] = 18'b100000000000000000;
 buffer[753] = 18'b100000000000000000;
 buffer[754] = 18'b100000000000000000;
 buffer[755] = 18'b100000000000000000;
 buffer[756] = 18'b100000000000000000;
 buffer[757] = 18'b100000000000000000;
 buffer[758] = 18'b100000000000000000;
 buffer[759] = 18'b100000000000000000;
 buffer[760] = 18'b100000000000000000;
 buffer[761] = 18'b100000000000000000;
 buffer[762] = 18'b100000000000000000;
 buffer[763] = 18'b100000000000000000;
 buffer[764] = 18'b100000000000000000;
 buffer[765] = 18'b100000000000000000;
 buffer[766] = 18'b100000000000000000;
 buffer[767] = 18'b100000000000000000;
 buffer[768] = 18'b100000000000000000;
 buffer[769] = 18'b100000000000000000;
 buffer[770] = 18'b100000000000000000;
 buffer[771] = 18'b100000000000000000;
 buffer[772] = 18'b100000000000000000;
 buffer[773] = 18'b100000000000000000;
 buffer[774] = 18'b100000000000000000;
 buffer[775] = 18'b100000000000000000;
 buffer[776] = 18'b100000000000000000;
 buffer[777] = 18'b100000000000000000;
 buffer[778] = 18'b100000000000000000;
 buffer[779] = 18'b100000000000000000;
 buffer[780] = 18'b100000000000000000;
 buffer[781] = 18'b100000000000000000;
 buffer[782] = 18'b100000000000000000;
 buffer[783] = 18'b100000000000000000;
 buffer[784] = 18'b100000000000000000;
 buffer[785] = 18'b100000000000000000;
 buffer[786] = 18'b100000000000000000;
 buffer[787] = 18'b100000000000000000;
 buffer[788] = 18'b100000000000000000;
 buffer[789] = 18'b100000000000000000;
 buffer[790] = 18'b100000000000000000;
 buffer[791] = 18'b100000000000000000;
 buffer[792] = 18'b100000000000000000;
 buffer[793] = 18'b100000000000000000;
 buffer[794] = 18'b100000000000000000;
 buffer[795] = 18'b100000000000000000;
 buffer[796] = 18'b100000000000000000;
 buffer[797] = 18'b100000000000000000;
 buffer[798] = 18'b100000000000000000;
 buffer[799] = 18'b100000000000000000;
 buffer[800] = 18'b100000000000000000;
 buffer[801] = 18'b100000000000000000;
 buffer[802] = 18'b100000000000000000;
 buffer[803] = 18'b100000000000000000;
 buffer[804] = 18'b100000000000000000;
 buffer[805] = 18'b100000000000000000;
 buffer[806] = 18'b100000000000000000;
 buffer[807] = 18'b100000000000000000;
 buffer[808] = 18'b100000000000000000;
 buffer[809] = 18'b100000000000000000;
 buffer[810] = 18'b100000000000000000;
 buffer[811] = 18'b100000000000000000;
 buffer[812] = 18'b100000000000000000;
 buffer[813] = 18'b100000000000000000;
 buffer[814] = 18'b100000000000000000;
 buffer[815] = 18'b100000000000000000;
 buffer[816] = 18'b100000000000000000;
 buffer[817] = 18'b100000000000000000;
 buffer[818] = 18'b100000000000000000;
 buffer[819] = 18'b100000000000000000;
 buffer[820] = 18'b100000000000000000;
 buffer[821] = 18'b100000000000000000;
 buffer[822] = 18'b100000000000000000;
 buffer[823] = 18'b100000000000000000;
 buffer[824] = 18'b100000000000000000;
 buffer[825] = 18'b100000000000000000;
 buffer[826] = 18'b100000000000000000;
 buffer[827] = 18'b100000000000000000;
 buffer[828] = 18'b100000000000000000;
 buffer[829] = 18'b100000000000000000;
 buffer[830] = 18'b100000000000000000;
 buffer[831] = 18'b100000000000000000;
 buffer[832] = 18'b100000000000000000;
 buffer[833] = 18'b100000000000000000;
 buffer[834] = 18'b100000000000000000;
 buffer[835] = 18'b100000000000000000;
 buffer[836] = 18'b100000000000000000;
 buffer[837] = 18'b100000000000000000;
 buffer[838] = 18'b100000000000000000;
 buffer[839] = 18'b100000000000000000;
 buffer[840] = 18'b100000000000000000;
 buffer[841] = 18'b100000000000000000;
 buffer[842] = 18'b100000000000000000;
 buffer[843] = 18'b100000000000000000;
 buffer[844] = 18'b100000000000000000;
 buffer[845] = 18'b100000000000000000;
 buffer[846] = 18'b100000000000000000;
 buffer[847] = 18'b100000000000000000;
 buffer[848] = 18'b100000000000000000;
 buffer[849] = 18'b100000000000000000;
 buffer[850] = 18'b100000000000000000;
 buffer[851] = 18'b100000000000000000;
 buffer[852] = 18'b100000000000000000;
 buffer[853] = 18'b100000000000000000;
 buffer[854] = 18'b100000000000000000;
 buffer[855] = 18'b100000000000000000;
 buffer[856] = 18'b100000000000000000;
 buffer[857] = 18'b100000000000000000;
 buffer[858] = 18'b100000000000000000;
 buffer[859] = 18'b100000000000000000;
 buffer[860] = 18'b100000000000000000;
 buffer[861] = 18'b100000000000000000;
 buffer[862] = 18'b100000000000000000;
 buffer[863] = 18'b100000000000000000;
 buffer[864] = 18'b100000000000000000;
 buffer[865] = 18'b100000000000000000;
 buffer[866] = 18'b100000000000000000;
 buffer[867] = 18'b100000000000000000;
 buffer[868] = 18'b100000000000000000;
 buffer[869] = 18'b100000000000000000;
 buffer[870] = 18'b100000000000000000;
 buffer[871] = 18'b100000000000000000;
 buffer[872] = 18'b100000000000000000;
 buffer[873] = 18'b100000000000000000;
 buffer[874] = 18'b100000000000000000;
 buffer[875] = 18'b100000000000000000;
 buffer[876] = 18'b100000000000000000;
 buffer[877] = 18'b100000000000000000;
 buffer[878] = 18'b100000000000000000;
 buffer[879] = 18'b100000000000000000;
 buffer[880] = 18'b100000000000000000;
 buffer[881] = 18'b100000000000000000;
 buffer[882] = 18'b100000000000000000;
 buffer[883] = 18'b100000000000000000;
 buffer[884] = 18'b100000000000000000;
 buffer[885] = 18'b100000000000000000;
 buffer[886] = 18'b100000000000000000;
 buffer[887] = 18'b100000000000000000;
 buffer[888] = 18'b100000000000000000;
 buffer[889] = 18'b100000000000000000;
 buffer[890] = 18'b100000000000000000;
 buffer[891] = 18'b100000000000000000;
 buffer[892] = 18'b100000000000000000;
 buffer[893] = 18'b100000000000000000;
 buffer[894] = 18'b100000000000000000;
 buffer[895] = 18'b100000000000000000;
 buffer[896] = 18'b100000000000000000;
 buffer[897] = 18'b100000000000000000;
 buffer[898] = 18'b100000000000000000;
 buffer[899] = 18'b100000000000000000;
 buffer[900] = 18'b100000000000000000;
 buffer[901] = 18'b100000000000000000;
 buffer[902] = 18'b100000000000000000;
 buffer[903] = 18'b100000000000000000;
 buffer[904] = 18'b100000000000000000;
 buffer[905] = 18'b100000000000000000;
 buffer[906] = 18'b100000000000000000;
 buffer[907] = 18'b100000000000000000;
 buffer[908] = 18'b100000000000000000;
 buffer[909] = 18'b100000000000000000;
 buffer[910] = 18'b100000000000000000;
 buffer[911] = 18'b100000000000000000;
 buffer[912] = 18'b100000000000000000;
 buffer[913] = 18'b100000000000000000;
 buffer[914] = 18'b100000000000000000;
 buffer[915] = 18'b100000000000000000;
 buffer[916] = 18'b100000000000000000;
 buffer[917] = 18'b100000000000000000;
 buffer[918] = 18'b100000000000000000;
 buffer[919] = 18'b100000000000000000;
 buffer[920] = 18'b100000000000000000;
 buffer[921] = 18'b100000000000000000;
 buffer[922] = 18'b100000000000000000;
 buffer[923] = 18'b100000000000000000;
 buffer[924] = 18'b100000000000000000;
 buffer[925] = 18'b100000000000000000;
 buffer[926] = 18'b100000000000000000;
 buffer[927] = 18'b100000000000000000;
 buffer[928] = 18'b100000000000000000;
 buffer[929] = 18'b100000000000000000;
 buffer[930] = 18'b100000000000000000;
 buffer[931] = 18'b100000000000000000;
 buffer[932] = 18'b100000000000000000;
 buffer[933] = 18'b100000000000000000;
 buffer[934] = 18'b100000000000000000;
 buffer[935] = 18'b100000000000000000;
 buffer[936] = 18'b100000000000000000;
 buffer[937] = 18'b100000000000000000;
 buffer[938] = 18'b100000000000000000;
 buffer[939] = 18'b100000000000000000;
 buffer[940] = 18'b100000000000000000;
 buffer[941] = 18'b100000000000000000;
 buffer[942] = 18'b100000000000000000;
 buffer[943] = 18'b100000000000000000;
 buffer[944] = 18'b100000000000000000;
 buffer[945] = 18'b100000000000000000;
 buffer[946] = 18'b100000000000000000;
 buffer[947] = 18'b100000000000000000;
 buffer[948] = 18'b100000000000000000;
 buffer[949] = 18'b100000000000000000;
 buffer[950] = 18'b100000000000000000;
 buffer[951] = 18'b100000000000000000;
 buffer[952] = 18'b100000000000000000;
 buffer[953] = 18'b100000000000000000;
 buffer[954] = 18'b100000000000000000;
 buffer[955] = 18'b100000000000000000;
 buffer[956] = 18'b100000000000000000;
 buffer[957] = 18'b100000000000000000;
 buffer[958] = 18'b100000000000000000;
 buffer[959] = 18'b100000000000000000;
 buffer[960] = 18'b100000000000000000;
 buffer[961] = 18'b100000000000000000;
 buffer[962] = 18'b100000000000000000;
 buffer[963] = 18'b100000000000000000;
 buffer[964] = 18'b100000000000000000;
 buffer[965] = 18'b100000000000000000;
 buffer[966] = 18'b100000000000000000;
 buffer[967] = 18'b100000000000000000;
 buffer[968] = 18'b100000000000000000;
 buffer[969] = 18'b100000000000000000;
 buffer[970] = 18'b100000000000000000;
 buffer[971] = 18'b100000000000000000;
 buffer[972] = 18'b100000000000000000;
 buffer[973] = 18'b100000000000000000;
 buffer[974] = 18'b100000000000000000;
 buffer[975] = 18'b100000000000000000;
 buffer[976] = 18'b100000000000000000;
 buffer[977] = 18'b100000000000000000;
 buffer[978] = 18'b100000000000000000;
 buffer[979] = 18'b100000000000000000;
 buffer[980] = 18'b100000000000000000;
 buffer[981] = 18'b100000000000000000;
 buffer[982] = 18'b100000000000000000;
 buffer[983] = 18'b100000000000000000;
 buffer[984] = 18'b100000000000000000;
 buffer[985] = 18'b100000000000000000;
 buffer[986] = 18'b100000000000000000;
 buffer[987] = 18'b100000000000000000;
 buffer[988] = 18'b100000000000000000;
 buffer[989] = 18'b100000000000000000;
 buffer[990] = 18'b100000000000000000;
 buffer[991] = 18'b100000000000000000;
 buffer[992] = 18'b100000000000000000;
 buffer[993] = 18'b100000000000000000;
 buffer[994] = 18'b100000000000000000;
 buffer[995] = 18'b100000000000000000;
 buffer[996] = 18'b100000000000000000;
 buffer[997] = 18'b100000000000000000;
 buffer[998] = 18'b100000000000000000;
 buffer[999] = 18'b100000000000000000;
 buffer[1000] = 18'b100000000000000000;
 buffer[1001] = 18'b100000000000000000;
 buffer[1002] = 18'b100000000000000000;
 buffer[1003] = 18'b100000000000000000;
 buffer[1004] = 18'b100000000000000000;
 buffer[1005] = 18'b100000000000000000;
 buffer[1006] = 18'b100000000000000000;
 buffer[1007] = 18'b100000000000000000;
 buffer[1008] = 18'b100000000000000000;
 buffer[1009] = 18'b100000000000000000;
 buffer[1010] = 18'b100000000000000000;
 buffer[1011] = 18'b100000000000000000;
 buffer[1012] = 18'b100000000000000000;
 buffer[1013] = 18'b100000000000000000;
 buffer[1014] = 18'b100000000000000000;
 buffer[1015] = 18'b100000000000000000;
 buffer[1016] = 18'b100000000000000000;
 buffer[1017] = 18'b100000000000000000;
 buffer[1018] = 18'b100000000000000000;
 buffer[1019] = 18'b100000000000000000;
 buffer[1020] = 18'b100000000000000000;
 buffer[1021] = 18'b100000000000000000;
 buffer[1022] = 18'b100000000000000000;
 buffer[1023] = 18'b100000000000000000;
 buffer[1024] = 18'b100000000000000000;
 buffer[1025] = 18'b100000000000000000;
 buffer[1026] = 18'b100000000000000000;
 buffer[1027] = 18'b100000000000000000;
 buffer[1028] = 18'b100000000000000000;
 buffer[1029] = 18'b100000000000000000;
 buffer[1030] = 18'b100000000000000000;
 buffer[1031] = 18'b100000000000000000;
 buffer[1032] = 18'b100000000000000000;
 buffer[1033] = 18'b100000000000000000;
 buffer[1034] = 18'b100000000000000000;
 buffer[1035] = 18'b100000000000000000;
 buffer[1036] = 18'b100000000000000000;
 buffer[1037] = 18'b100000000000000000;
 buffer[1038] = 18'b100000000000000000;
 buffer[1039] = 18'b100000000000000000;
 buffer[1040] = 18'b100000000000000000;
 buffer[1041] = 18'b100000000000000000;
 buffer[1042] = 18'b100000000000000000;
 buffer[1043] = 18'b100000000000000000;
 buffer[1044] = 18'b100000000000000000;
 buffer[1045] = 18'b100000000000000000;
 buffer[1046] = 18'b100000000000000000;
 buffer[1047] = 18'b100000000000000000;
 buffer[1048] = 18'b100000000000000000;
 buffer[1049] = 18'b100000000000000000;
 buffer[1050] = 18'b100000000000000000;
 buffer[1051] = 18'b100000000000000000;
 buffer[1052] = 18'b100000000000000000;
 buffer[1053] = 18'b100000000000000000;
 buffer[1054] = 18'b100000000000000000;
 buffer[1055] = 18'b100000000000000000;
 buffer[1056] = 18'b100000000000000000;
 buffer[1057] = 18'b100000000000000000;
 buffer[1058] = 18'b100000000000000000;
 buffer[1059] = 18'b100000000000000000;
 buffer[1060] = 18'b100000000000000000;
 buffer[1061] = 18'b100000000000000000;
 buffer[1062] = 18'b100000000000000000;
 buffer[1063] = 18'b100000000000000000;
 buffer[1064] = 18'b100000000000000000;
 buffer[1065] = 18'b100000000000000000;
 buffer[1066] = 18'b100000000000000000;
 buffer[1067] = 18'b100000000000000000;
 buffer[1068] = 18'b100000000000000000;
 buffer[1069] = 18'b100000000000000000;
 buffer[1070] = 18'b100000000000000000;
 buffer[1071] = 18'b100000000000000000;
 buffer[1072] = 18'b100000000000000000;
 buffer[1073] = 18'b100000000000000000;
 buffer[1074] = 18'b100000000000000000;
 buffer[1075] = 18'b100000000000000000;
 buffer[1076] = 18'b100000000000000000;
 buffer[1077] = 18'b100000000000000000;
 buffer[1078] = 18'b100000000000000000;
 buffer[1079] = 18'b100000000000000000;
 buffer[1080] = 18'b100000000000000000;
 buffer[1081] = 18'b100000000000000000;
 buffer[1082] = 18'b100000000000000000;
 buffer[1083] = 18'b100000000000000000;
 buffer[1084] = 18'b100000000000000000;
 buffer[1085] = 18'b100000000000000000;
 buffer[1086] = 18'b100000000000000000;
 buffer[1087] = 18'b100000000000000000;
 buffer[1088] = 18'b100000000000000000;
 buffer[1089] = 18'b100000000000000000;
 buffer[1090] = 18'b100000000000000000;
 buffer[1091] = 18'b100000000000000000;
 buffer[1092] = 18'b100000000000000000;
 buffer[1093] = 18'b100000000000000000;
 buffer[1094] = 18'b100000000000000000;
 buffer[1095] = 18'b100000000000000000;
 buffer[1096] = 18'b100000000000000000;
 buffer[1097] = 18'b100000000000000000;
 buffer[1098] = 18'b100000000000000000;
 buffer[1099] = 18'b100000000000000000;
 buffer[1100] = 18'b100000000000000000;
 buffer[1101] = 18'b100000000000000000;
 buffer[1102] = 18'b100000000000000000;
 buffer[1103] = 18'b100000000000000000;
 buffer[1104] = 18'b100000000000000000;
 buffer[1105] = 18'b100000000000000000;
 buffer[1106] = 18'b100000000000000000;
 buffer[1107] = 18'b100000000000000000;
 buffer[1108] = 18'b100000000000000000;
 buffer[1109] = 18'b100000000000000000;
 buffer[1110] = 18'b100000000000000000;
 buffer[1111] = 18'b100000000000000000;
 buffer[1112] = 18'b100000000000000000;
 buffer[1113] = 18'b100000000000000000;
 buffer[1114] = 18'b100000000000000000;
 buffer[1115] = 18'b100000000000000000;
 buffer[1116] = 18'b100000000000000000;
 buffer[1117] = 18'b100000000000000000;
 buffer[1118] = 18'b100000000000000000;
 buffer[1119] = 18'b100000000000000000;
 buffer[1120] = 18'b100000000000000000;
 buffer[1121] = 18'b100000000000000000;
 buffer[1122] = 18'b100000000000000000;
 buffer[1123] = 18'b100000000000000000;
 buffer[1124] = 18'b100000000000000000;
 buffer[1125] = 18'b100000000000000000;
 buffer[1126] = 18'b100000000000000000;
 buffer[1127] = 18'b100000000000000000;
 buffer[1128] = 18'b100000000000000000;
 buffer[1129] = 18'b100000000000000000;
 buffer[1130] = 18'b100000000000000000;
 buffer[1131] = 18'b100000000000000000;
 buffer[1132] = 18'b100000000000000000;
 buffer[1133] = 18'b100000000000000000;
 buffer[1134] = 18'b100000000000000000;
 buffer[1135] = 18'b100000000000000000;
 buffer[1136] = 18'b100000000000000000;
 buffer[1137] = 18'b100000000000000000;
 buffer[1138] = 18'b100000000000000000;
 buffer[1139] = 18'b100000000000000000;
 buffer[1140] = 18'b100000000000000000;
 buffer[1141] = 18'b100000000000000000;
 buffer[1142] = 18'b100000000000000000;
 buffer[1143] = 18'b100000000000000000;
 buffer[1144] = 18'b100000000000000000;
 buffer[1145] = 18'b100000000000000000;
 buffer[1146] = 18'b100000000000000000;
 buffer[1147] = 18'b100000000000000000;
 buffer[1148] = 18'b100000000000000000;
 buffer[1149] = 18'b100000000000000000;
 buffer[1150] = 18'b100000000000000000;
 buffer[1151] = 18'b100000000000000000;
 buffer[1152] = 18'b100000000000000000;
 buffer[1153] = 18'b100000000000000000;
 buffer[1154] = 18'b100000000000000000;
 buffer[1155] = 18'b100000000000000000;
 buffer[1156] = 18'b100000000000000000;
 buffer[1157] = 18'b100000000000000000;
 buffer[1158] = 18'b100000000000000000;
 buffer[1159] = 18'b100000000000000000;
 buffer[1160] = 18'b100000000000000000;
 buffer[1161] = 18'b100000000000000000;
 buffer[1162] = 18'b100000000000000000;
 buffer[1163] = 18'b100000000000000000;
 buffer[1164] = 18'b100000000000000000;
 buffer[1165] = 18'b100000000000000000;
 buffer[1166] = 18'b100000000000000000;
 buffer[1167] = 18'b100000000000000000;
 buffer[1168] = 18'b100000000000000000;
 buffer[1169] = 18'b100000000000000000;
 buffer[1170] = 18'b100000000000000000;
 buffer[1171] = 18'b100000000000000000;
 buffer[1172] = 18'b100000000000000000;
 buffer[1173] = 18'b100000000000000000;
 buffer[1174] = 18'b100000000000000000;
 buffer[1175] = 18'b100000000000000000;
 buffer[1176] = 18'b100000000000000000;
 buffer[1177] = 18'b100000000000000000;
 buffer[1178] = 18'b100000000000000000;
 buffer[1179] = 18'b100000000000000000;
 buffer[1180] = 18'b100000000000000000;
 buffer[1181] = 18'b100000000000000000;
 buffer[1182] = 18'b100000000000000000;
 buffer[1183] = 18'b100000000000000000;
 buffer[1184] = 18'b100000000000000000;
 buffer[1185] = 18'b100000000000000000;
 buffer[1186] = 18'b100000000000000000;
 buffer[1187] = 18'b100000000000000000;
 buffer[1188] = 18'b100000000000000000;
 buffer[1189] = 18'b100000000000000000;
 buffer[1190] = 18'b100000000000000000;
 buffer[1191] = 18'b100000000000000000;
 buffer[1192] = 18'b100000000000000000;
 buffer[1193] = 18'b100000000000000000;
 buffer[1194] = 18'b100000000000000000;
 buffer[1195] = 18'b100000000000000000;
 buffer[1196] = 18'b100000000000000000;
 buffer[1197] = 18'b100000000000000000;
 buffer[1198] = 18'b100000000000000000;
 buffer[1199] = 18'b100000000000000000;
 buffer[1200] = 18'b100000000000000000;
 buffer[1201] = 18'b100000000000000000;
 buffer[1202] = 18'b100000000000000000;
 buffer[1203] = 18'b100000000000000000;
 buffer[1204] = 18'b100000000000000000;
 buffer[1205] = 18'b100000000000000000;
 buffer[1206] = 18'b100000000000000000;
 buffer[1207] = 18'b100000000000000000;
 buffer[1208] = 18'b100000000000000000;
 buffer[1209] = 18'b100000000000000000;
 buffer[1210] = 18'b100000000000000000;
 buffer[1211] = 18'b100000000000000000;
 buffer[1212] = 18'b100000000000000000;
 buffer[1213] = 18'b100000000000000000;
 buffer[1214] = 18'b100000000000000000;
 buffer[1215] = 18'b100000000000000000;
 buffer[1216] = 18'b100000000000000000;
 buffer[1217] = 18'b100000000000000000;
 buffer[1218] = 18'b100000000000000000;
 buffer[1219] = 18'b100000000000000000;
 buffer[1220] = 18'b100000000000000000;
 buffer[1221] = 18'b100000000000000000;
 buffer[1222] = 18'b100000000000000000;
 buffer[1223] = 18'b100000000000000000;
 buffer[1224] = 18'b100000000000000000;
 buffer[1225] = 18'b100000000000000000;
 buffer[1226] = 18'b100000000000000000;
 buffer[1227] = 18'b100000000000000000;
 buffer[1228] = 18'b100000000000000000;
 buffer[1229] = 18'b100000000000000000;
 buffer[1230] = 18'b100000000000000000;
 buffer[1231] = 18'b100000000000000000;
 buffer[1232] = 18'b100000000000000000;
 buffer[1233] = 18'b100000000000000000;
 buffer[1234] = 18'b100000000000000000;
 buffer[1235] = 18'b100000000000000000;
 buffer[1236] = 18'b100000000000000000;
 buffer[1237] = 18'b100000000000000000;
 buffer[1238] = 18'b100000000000000000;
 buffer[1239] = 18'b100000000000000000;
 buffer[1240] = 18'b100000000000000000;
 buffer[1241] = 18'b100000000000000000;
 buffer[1242] = 18'b100000000000000000;
 buffer[1243] = 18'b100000000000000000;
 buffer[1244] = 18'b100000000000000000;
 buffer[1245] = 18'b100000000000000000;
 buffer[1246] = 18'b100000000000000000;
 buffer[1247] = 18'b100000000000000000;
 buffer[1248] = 18'b100000000000000000;
 buffer[1249] = 18'b100000000000000000;
 buffer[1250] = 18'b100000000000000000;
 buffer[1251] = 18'b100000000000000000;
 buffer[1252] = 18'b100000000000000000;
 buffer[1253] = 18'b100000000000000000;
 buffer[1254] = 18'b100000000000000000;
 buffer[1255] = 18'b100000000000000000;
 buffer[1256] = 18'b100000000000000000;
 buffer[1257] = 18'b100000000000000000;
 buffer[1258] = 18'b100000000000000000;
 buffer[1259] = 18'b100000000000000000;
 buffer[1260] = 18'b100000000000000000;
 buffer[1261] = 18'b100000000000000000;
 buffer[1262] = 18'b100000000000000000;
 buffer[1263] = 18'b100000000000000000;
 buffer[1264] = 18'b100000000000000000;
 buffer[1265] = 18'b100000000000000000;
 buffer[1266] = 18'b100000000000000000;
 buffer[1267] = 18'b100000000000000000;
 buffer[1268] = 18'b100000000000000000;
 buffer[1269] = 18'b100000000000000000;
 buffer[1270] = 18'b100000000000000000;
 buffer[1271] = 18'b100000000000000000;
 buffer[1272] = 18'b100000000000000000;
 buffer[1273] = 18'b100000000000000000;
 buffer[1274] = 18'b100000000000000000;
 buffer[1275] = 18'b100000000000000000;
 buffer[1276] = 18'b100000000000000000;
 buffer[1277] = 18'b100000000000000000;
 buffer[1278] = 18'b100000000000000000;
 buffer[1279] = 18'b100000000000000000;
 buffer[1280] = 18'b100000000000000000;
 buffer[1281] = 18'b100000000000000000;
 buffer[1282] = 18'b100000000000000000;
 buffer[1283] = 18'b100000000000000000;
 buffer[1284] = 18'b100000000000000000;
 buffer[1285] = 18'b100000000000000000;
 buffer[1286] = 18'b100000000000000000;
 buffer[1287] = 18'b100000000000000000;
 buffer[1288] = 18'b100000000000000000;
 buffer[1289] = 18'b100000000000000000;
 buffer[1290] = 18'b100000000000000000;
 buffer[1291] = 18'b100000000000000000;
 buffer[1292] = 18'b100000000000000000;
 buffer[1293] = 18'b100000000000000000;
 buffer[1294] = 18'b100000000000000000;
 buffer[1295] = 18'b100000000000000000;
 buffer[1296] = 18'b100000000000000000;
 buffer[1297] = 18'b100000000000000000;
 buffer[1298] = 18'b100000000000000000;
 buffer[1299] = 18'b100000000000000000;
 buffer[1300] = 18'b100000000000000000;
 buffer[1301] = 18'b100000000000000000;
 buffer[1302] = 18'b100000000000000000;
 buffer[1303] = 18'b100000000000000000;
 buffer[1304] = 18'b100000000000000000;
 buffer[1305] = 18'b100000000000000000;
 buffer[1306] = 18'b100000000000000000;
 buffer[1307] = 18'b100000000000000000;
 buffer[1308] = 18'b100000000000000000;
 buffer[1309] = 18'b100000000000000000;
 buffer[1310] = 18'b100000000000000000;
 buffer[1311] = 18'b100000000000000000;
 buffer[1312] = 18'b100000000000000000;
 buffer[1313] = 18'b100000000000000000;
 buffer[1314] = 18'b100000000000000000;
 buffer[1315] = 18'b100000000000000000;
 buffer[1316] = 18'b100000000000000000;
 buffer[1317] = 18'b100000000000000000;
 buffer[1318] = 18'b100000000000000000;
 buffer[1319] = 18'b100000000000000000;
 buffer[1320] = 18'b100000000000000000;
 buffer[1321] = 18'b100000000000000000;
 buffer[1322] = 18'b100000000000000000;
 buffer[1323] = 18'b100000000000000000;
 buffer[1324] = 18'b100000000000000000;
 buffer[1325] = 18'b100000000000000000;
 buffer[1326] = 18'b100000000000000000;
 buffer[1327] = 18'b100000000000000000;
 buffer[1328] = 18'b100000000000000000;
 buffer[1329] = 18'b100000000000000000;
 buffer[1330] = 18'b100000000000000000;
 buffer[1331] = 18'b100000000000000000;
 buffer[1332] = 18'b100000000000000000;
 buffer[1333] = 18'b100000000000000000;
 buffer[1334] = 18'b100000000000000000;
 buffer[1335] = 18'b100000000000000000;
 buffer[1336] = 18'b100000000000000000;
 buffer[1337] = 18'b100000000000000000;
 buffer[1338] = 18'b100000000000000000;
 buffer[1339] = 18'b100000000000000000;
 buffer[1340] = 18'b100000000000000000;
 buffer[1341] = 18'b100000000000000000;
 buffer[1342] = 18'b100000000000000000;
 buffer[1343] = 18'b100000000000000000;
end

endmodule

module M_tilemap_mem_tiles_copy(
input      [10:0]                in_tiles_copy_addr0,
output reg  [17:0]     out_tiles_copy_rdata0,
output reg  [17:0]     out_tiles_copy_rdata1,
input      [0:0]             in_tiles_copy_wenable1,
input      [17:0]                 in_tiles_copy_wdata1,
input      [10:0]                in_tiles_copy_addr1,
input      clock0,
input      clock1
);
reg  [17:0] buffer[1343:0];
always @(posedge clock0) begin
  out_tiles_copy_rdata0 <= buffer[in_tiles_copy_addr0];
end
always @(posedge clock1) begin
  if (in_tiles_copy_wenable1) begin
    buffer[in_tiles_copy_addr1] <= in_tiles_copy_wdata1;
  end
end
initial begin
 buffer[0] = 18'b100000000000000000;
 buffer[1] = 18'b100000000000000000;
 buffer[2] = 18'b100000000000000000;
 buffer[3] = 18'b100000000000000000;
 buffer[4] = 18'b100000000000000000;
 buffer[5] = 18'b100000000000000000;
 buffer[6] = 18'b100000000000000000;
 buffer[7] = 18'b100000000000000000;
 buffer[8] = 18'b100000000000000000;
 buffer[9] = 18'b100000000000000000;
 buffer[10] = 18'b100000000000000000;
 buffer[11] = 18'b100000000000000000;
 buffer[12] = 18'b100000000000000000;
 buffer[13] = 18'b100000000000000000;
 buffer[14] = 18'b100000000000000000;
 buffer[15] = 18'b100000000000000000;
 buffer[16] = 18'b100000000000000000;
 buffer[17] = 18'b100000000000000000;
 buffer[18] = 18'b100000000000000000;
 buffer[19] = 18'b100000000000000000;
 buffer[20] = 18'b100000000000000000;
 buffer[21] = 18'b100000000000000000;
 buffer[22] = 18'b100000000000000000;
 buffer[23] = 18'b100000000000000000;
 buffer[24] = 18'b100000000000000000;
 buffer[25] = 18'b100000000000000000;
 buffer[26] = 18'b100000000000000000;
 buffer[27] = 18'b100000000000000000;
 buffer[28] = 18'b100000000000000000;
 buffer[29] = 18'b100000000000000000;
 buffer[30] = 18'b100000000000000000;
 buffer[31] = 18'b100000000000000000;
 buffer[32] = 18'b100000000000000000;
 buffer[33] = 18'b100000000000000000;
 buffer[34] = 18'b100000000000000000;
 buffer[35] = 18'b100000000000000000;
 buffer[36] = 18'b100000000000000000;
 buffer[37] = 18'b100000000000000000;
 buffer[38] = 18'b100000000000000000;
 buffer[39] = 18'b100000000000000000;
 buffer[40] = 18'b100000000000000000;
 buffer[41] = 18'b100000000000000000;
 buffer[42] = 18'b100000000000000000;
 buffer[43] = 18'b100000000000000000;
 buffer[44] = 18'b100000000000000000;
 buffer[45] = 18'b100000000000000000;
 buffer[46] = 18'b100000000000000000;
 buffer[47] = 18'b100000000000000000;
 buffer[48] = 18'b100000000000000000;
 buffer[49] = 18'b100000000000000000;
 buffer[50] = 18'b100000000000000000;
 buffer[51] = 18'b100000000000000000;
 buffer[52] = 18'b100000000000000000;
 buffer[53] = 18'b100000000000000000;
 buffer[54] = 18'b100000000000000000;
 buffer[55] = 18'b100000000000000000;
 buffer[56] = 18'b100000000000000000;
 buffer[57] = 18'b100000000000000000;
 buffer[58] = 18'b100000000000000000;
 buffer[59] = 18'b100000000000000000;
 buffer[60] = 18'b100000000000000000;
 buffer[61] = 18'b100000000000000000;
 buffer[62] = 18'b100000000000000000;
 buffer[63] = 18'b100000000000000000;
 buffer[64] = 18'b100000000000000000;
 buffer[65] = 18'b100000000000000000;
 buffer[66] = 18'b100000000000000000;
 buffer[67] = 18'b100000000000000000;
 buffer[68] = 18'b100000000000000000;
 buffer[69] = 18'b100000000000000000;
 buffer[70] = 18'b100000000000000000;
 buffer[71] = 18'b100000000000000000;
 buffer[72] = 18'b100000000000000000;
 buffer[73] = 18'b100000000000000000;
 buffer[74] = 18'b100000000000000000;
 buffer[75] = 18'b100000000000000000;
 buffer[76] = 18'b100000000000000000;
 buffer[77] = 18'b100000000000000000;
 buffer[78] = 18'b100000000000000000;
 buffer[79] = 18'b100000000000000000;
 buffer[80] = 18'b100000000000000000;
 buffer[81] = 18'b100000000000000000;
 buffer[82] = 18'b100000000000000000;
 buffer[83] = 18'b100000000000000000;
 buffer[84] = 18'b100000000000000000;
 buffer[85] = 18'b100000000000000000;
 buffer[86] = 18'b100000000000000000;
 buffer[87] = 18'b100000000000000000;
 buffer[88] = 18'b100000000000000000;
 buffer[89] = 18'b100000000000000000;
 buffer[90] = 18'b100000000000000000;
 buffer[91] = 18'b100000000000000000;
 buffer[92] = 18'b100000000000000000;
 buffer[93] = 18'b100000000000000000;
 buffer[94] = 18'b100000000000000000;
 buffer[95] = 18'b100000000000000000;
 buffer[96] = 18'b100000000000000000;
 buffer[97] = 18'b100000000000000000;
 buffer[98] = 18'b100000000000000000;
 buffer[99] = 18'b100000000000000000;
 buffer[100] = 18'b100000000000000000;
 buffer[101] = 18'b100000000000000000;
 buffer[102] = 18'b100000000000000000;
 buffer[103] = 18'b100000000000000000;
 buffer[104] = 18'b100000000000000000;
 buffer[105] = 18'b100000000000000000;
 buffer[106] = 18'b100000000000000000;
 buffer[107] = 18'b100000000000000000;
 buffer[108] = 18'b100000000000000000;
 buffer[109] = 18'b100000000000000000;
 buffer[110] = 18'b100000000000000000;
 buffer[111] = 18'b100000000000000000;
 buffer[112] = 18'b100000000000000000;
 buffer[113] = 18'b100000000000000000;
 buffer[114] = 18'b100000000000000000;
 buffer[115] = 18'b100000000000000000;
 buffer[116] = 18'b100000000000000000;
 buffer[117] = 18'b100000000000000000;
 buffer[118] = 18'b100000000000000000;
 buffer[119] = 18'b100000000000000000;
 buffer[120] = 18'b100000000000000000;
 buffer[121] = 18'b100000000000000000;
 buffer[122] = 18'b100000000000000000;
 buffer[123] = 18'b100000000000000000;
 buffer[124] = 18'b100000000000000000;
 buffer[125] = 18'b100000000000000000;
 buffer[126] = 18'b100000000000000000;
 buffer[127] = 18'b100000000000000000;
 buffer[128] = 18'b100000000000000000;
 buffer[129] = 18'b100000000000000000;
 buffer[130] = 18'b100000000000000000;
 buffer[131] = 18'b100000000000000000;
 buffer[132] = 18'b100000000000000000;
 buffer[133] = 18'b100000000000000000;
 buffer[134] = 18'b100000000000000000;
 buffer[135] = 18'b100000000000000000;
 buffer[136] = 18'b100000000000000000;
 buffer[137] = 18'b100000000000000000;
 buffer[138] = 18'b100000000000000000;
 buffer[139] = 18'b100000000000000000;
 buffer[140] = 18'b100000000000000000;
 buffer[141] = 18'b100000000000000000;
 buffer[142] = 18'b100000000000000000;
 buffer[143] = 18'b100000000000000000;
 buffer[144] = 18'b100000000000000000;
 buffer[145] = 18'b100000000000000000;
 buffer[146] = 18'b100000000000000000;
 buffer[147] = 18'b100000000000000000;
 buffer[148] = 18'b100000000000000000;
 buffer[149] = 18'b100000000000000000;
 buffer[150] = 18'b100000000000000000;
 buffer[151] = 18'b100000000000000000;
 buffer[152] = 18'b100000000000000000;
 buffer[153] = 18'b100000000000000000;
 buffer[154] = 18'b100000000000000000;
 buffer[155] = 18'b100000000000000000;
 buffer[156] = 18'b100000000000000000;
 buffer[157] = 18'b100000000000000000;
 buffer[158] = 18'b100000000000000000;
 buffer[159] = 18'b100000000000000000;
 buffer[160] = 18'b100000000000000000;
 buffer[161] = 18'b100000000000000000;
 buffer[162] = 18'b100000000000000000;
 buffer[163] = 18'b100000000000000000;
 buffer[164] = 18'b100000000000000000;
 buffer[165] = 18'b100000000000000000;
 buffer[166] = 18'b100000000000000000;
 buffer[167] = 18'b100000000000000000;
 buffer[168] = 18'b100000000000000000;
 buffer[169] = 18'b100000000000000000;
 buffer[170] = 18'b100000000000000000;
 buffer[171] = 18'b100000000000000000;
 buffer[172] = 18'b100000000000000000;
 buffer[173] = 18'b100000000000000000;
 buffer[174] = 18'b100000000000000000;
 buffer[175] = 18'b100000000000000000;
 buffer[176] = 18'b100000000000000000;
 buffer[177] = 18'b100000000000000000;
 buffer[178] = 18'b100000000000000000;
 buffer[179] = 18'b100000000000000000;
 buffer[180] = 18'b100000000000000000;
 buffer[181] = 18'b100000000000000000;
 buffer[182] = 18'b100000000000000000;
 buffer[183] = 18'b100000000000000000;
 buffer[184] = 18'b100000000000000000;
 buffer[185] = 18'b100000000000000000;
 buffer[186] = 18'b100000000000000000;
 buffer[187] = 18'b100000000000000000;
 buffer[188] = 18'b100000000000000000;
 buffer[189] = 18'b100000000000000000;
 buffer[190] = 18'b100000000000000000;
 buffer[191] = 18'b100000000000000000;
 buffer[192] = 18'b100000000000000000;
 buffer[193] = 18'b100000000000000000;
 buffer[194] = 18'b100000000000000000;
 buffer[195] = 18'b100000000000000000;
 buffer[196] = 18'b100000000000000000;
 buffer[197] = 18'b100000000000000000;
 buffer[198] = 18'b100000000000000000;
 buffer[199] = 18'b100000000000000000;
 buffer[200] = 18'b100000000000000000;
 buffer[201] = 18'b100000000000000000;
 buffer[202] = 18'b100000000000000000;
 buffer[203] = 18'b100000000000000000;
 buffer[204] = 18'b100000000000000000;
 buffer[205] = 18'b100000000000000000;
 buffer[206] = 18'b100000000000000000;
 buffer[207] = 18'b100000000000000000;
 buffer[208] = 18'b100000000000000000;
 buffer[209] = 18'b100000000000000000;
 buffer[210] = 18'b100000000000000000;
 buffer[211] = 18'b100000000000000000;
 buffer[212] = 18'b100000000000000000;
 buffer[213] = 18'b100000000000000000;
 buffer[214] = 18'b100000000000000000;
 buffer[215] = 18'b100000000000000000;
 buffer[216] = 18'b100000000000000000;
 buffer[217] = 18'b100000000000000000;
 buffer[218] = 18'b100000000000000000;
 buffer[219] = 18'b100000000000000000;
 buffer[220] = 18'b100000000000000000;
 buffer[221] = 18'b100000000000000000;
 buffer[222] = 18'b100000000000000000;
 buffer[223] = 18'b100000000000000000;
 buffer[224] = 18'b100000000000000000;
 buffer[225] = 18'b100000000000000000;
 buffer[226] = 18'b100000000000000000;
 buffer[227] = 18'b100000000000000000;
 buffer[228] = 18'b100000000000000000;
 buffer[229] = 18'b100000000000000000;
 buffer[230] = 18'b100000000000000000;
 buffer[231] = 18'b100000000000000000;
 buffer[232] = 18'b100000000000000000;
 buffer[233] = 18'b100000000000000000;
 buffer[234] = 18'b100000000000000000;
 buffer[235] = 18'b100000000000000000;
 buffer[236] = 18'b100000000000000000;
 buffer[237] = 18'b100000000000000000;
 buffer[238] = 18'b100000000000000000;
 buffer[239] = 18'b100000000000000000;
 buffer[240] = 18'b100000000000000000;
 buffer[241] = 18'b100000000000000000;
 buffer[242] = 18'b100000000000000000;
 buffer[243] = 18'b100000000000000000;
 buffer[244] = 18'b100000000000000000;
 buffer[245] = 18'b100000000000000000;
 buffer[246] = 18'b100000000000000000;
 buffer[247] = 18'b100000000000000000;
 buffer[248] = 18'b100000000000000000;
 buffer[249] = 18'b100000000000000000;
 buffer[250] = 18'b100000000000000000;
 buffer[251] = 18'b100000000000000000;
 buffer[252] = 18'b100000000000000000;
 buffer[253] = 18'b100000000000000000;
 buffer[254] = 18'b100000000000000000;
 buffer[255] = 18'b100000000000000000;
 buffer[256] = 18'b100000000000000000;
 buffer[257] = 18'b100000000000000000;
 buffer[258] = 18'b100000000000000000;
 buffer[259] = 18'b100000000000000000;
 buffer[260] = 18'b100000000000000000;
 buffer[261] = 18'b100000000000000000;
 buffer[262] = 18'b100000000000000000;
 buffer[263] = 18'b100000000000000000;
 buffer[264] = 18'b100000000000000000;
 buffer[265] = 18'b100000000000000000;
 buffer[266] = 18'b100000000000000000;
 buffer[267] = 18'b100000000000000000;
 buffer[268] = 18'b100000000000000000;
 buffer[269] = 18'b100000000000000000;
 buffer[270] = 18'b100000000000000000;
 buffer[271] = 18'b100000000000000000;
 buffer[272] = 18'b100000000000000000;
 buffer[273] = 18'b100000000000000000;
 buffer[274] = 18'b100000000000000000;
 buffer[275] = 18'b100000000000000000;
 buffer[276] = 18'b100000000000000000;
 buffer[277] = 18'b100000000000000000;
 buffer[278] = 18'b100000000000000000;
 buffer[279] = 18'b100000000000000000;
 buffer[280] = 18'b100000000000000000;
 buffer[281] = 18'b100000000000000000;
 buffer[282] = 18'b100000000000000000;
 buffer[283] = 18'b100000000000000000;
 buffer[284] = 18'b100000000000000000;
 buffer[285] = 18'b100000000000000000;
 buffer[286] = 18'b100000000000000000;
 buffer[287] = 18'b100000000000000000;
 buffer[288] = 18'b100000000000000000;
 buffer[289] = 18'b100000000000000000;
 buffer[290] = 18'b100000000000000000;
 buffer[291] = 18'b100000000000000000;
 buffer[292] = 18'b100000000000000000;
 buffer[293] = 18'b100000000000000000;
 buffer[294] = 18'b100000000000000000;
 buffer[295] = 18'b100000000000000000;
 buffer[296] = 18'b100000000000000000;
 buffer[297] = 18'b100000000000000000;
 buffer[298] = 18'b100000000000000000;
 buffer[299] = 18'b100000000000000000;
 buffer[300] = 18'b100000000000000000;
 buffer[301] = 18'b100000000000000000;
 buffer[302] = 18'b100000000000000000;
 buffer[303] = 18'b100000000000000000;
 buffer[304] = 18'b100000000000000000;
 buffer[305] = 18'b100000000000000000;
 buffer[306] = 18'b100000000000000000;
 buffer[307] = 18'b100000000000000000;
 buffer[308] = 18'b100000000000000000;
 buffer[309] = 18'b100000000000000000;
 buffer[310] = 18'b100000000000000000;
 buffer[311] = 18'b100000000000000000;
 buffer[312] = 18'b100000000000000000;
 buffer[313] = 18'b100000000000000000;
 buffer[314] = 18'b100000000000000000;
 buffer[315] = 18'b100000000000000000;
 buffer[316] = 18'b100000000000000000;
 buffer[317] = 18'b100000000000000000;
 buffer[318] = 18'b100000000000000000;
 buffer[319] = 18'b100000000000000000;
 buffer[320] = 18'b100000000000000000;
 buffer[321] = 18'b100000000000000000;
 buffer[322] = 18'b100000000000000000;
 buffer[323] = 18'b100000000000000000;
 buffer[324] = 18'b100000000000000000;
 buffer[325] = 18'b100000000000000000;
 buffer[326] = 18'b100000000000000000;
 buffer[327] = 18'b100000000000000000;
 buffer[328] = 18'b100000000000000000;
 buffer[329] = 18'b100000000000000000;
 buffer[330] = 18'b100000000000000000;
 buffer[331] = 18'b100000000000000000;
 buffer[332] = 18'b100000000000000000;
 buffer[333] = 18'b100000000000000000;
 buffer[334] = 18'b100000000000000000;
 buffer[335] = 18'b100000000000000000;
 buffer[336] = 18'b100000000000000000;
 buffer[337] = 18'b100000000000000000;
 buffer[338] = 18'b100000000000000000;
 buffer[339] = 18'b100000000000000000;
 buffer[340] = 18'b100000000000000000;
 buffer[341] = 18'b100000000000000000;
 buffer[342] = 18'b100000000000000000;
 buffer[343] = 18'b100000000000000000;
 buffer[344] = 18'b100000000000000000;
 buffer[345] = 18'b100000000000000000;
 buffer[346] = 18'b100000000000000000;
 buffer[347] = 18'b100000000000000000;
 buffer[348] = 18'b100000000000000000;
 buffer[349] = 18'b100000000000000000;
 buffer[350] = 18'b100000000000000000;
 buffer[351] = 18'b100000000000000000;
 buffer[352] = 18'b100000000000000000;
 buffer[353] = 18'b100000000000000000;
 buffer[354] = 18'b100000000000000000;
 buffer[355] = 18'b100000000000000000;
 buffer[356] = 18'b100000000000000000;
 buffer[357] = 18'b100000000000000000;
 buffer[358] = 18'b100000000000000000;
 buffer[359] = 18'b100000000000000000;
 buffer[360] = 18'b100000000000000000;
 buffer[361] = 18'b100000000000000000;
 buffer[362] = 18'b100000000000000000;
 buffer[363] = 18'b100000000000000000;
 buffer[364] = 18'b100000000000000000;
 buffer[365] = 18'b100000000000000000;
 buffer[366] = 18'b100000000000000000;
 buffer[367] = 18'b100000000000000000;
 buffer[368] = 18'b100000000000000000;
 buffer[369] = 18'b100000000000000000;
 buffer[370] = 18'b100000000000000000;
 buffer[371] = 18'b100000000000000000;
 buffer[372] = 18'b100000000000000000;
 buffer[373] = 18'b100000000000000000;
 buffer[374] = 18'b100000000000000000;
 buffer[375] = 18'b100000000000000000;
 buffer[376] = 18'b100000000000000000;
 buffer[377] = 18'b100000000000000000;
 buffer[378] = 18'b100000000000000000;
 buffer[379] = 18'b100000000000000000;
 buffer[380] = 18'b100000000000000000;
 buffer[381] = 18'b100000000000000000;
 buffer[382] = 18'b100000000000000000;
 buffer[383] = 18'b100000000000000000;
 buffer[384] = 18'b100000000000000000;
 buffer[385] = 18'b100000000000000000;
 buffer[386] = 18'b100000000000000000;
 buffer[387] = 18'b100000000000000000;
 buffer[388] = 18'b100000000000000000;
 buffer[389] = 18'b100000000000000000;
 buffer[390] = 18'b100000000000000000;
 buffer[391] = 18'b100000000000000000;
 buffer[392] = 18'b100000000000000000;
 buffer[393] = 18'b100000000000000000;
 buffer[394] = 18'b100000000000000000;
 buffer[395] = 18'b100000000000000000;
 buffer[396] = 18'b100000000000000000;
 buffer[397] = 18'b100000000000000000;
 buffer[398] = 18'b100000000000000000;
 buffer[399] = 18'b100000000000000000;
 buffer[400] = 18'b100000000000000000;
 buffer[401] = 18'b100000000000000000;
 buffer[402] = 18'b100000000000000000;
 buffer[403] = 18'b100000000000000000;
 buffer[404] = 18'b100000000000000000;
 buffer[405] = 18'b100000000000000000;
 buffer[406] = 18'b100000000000000000;
 buffer[407] = 18'b100000000000000000;
 buffer[408] = 18'b100000000000000000;
 buffer[409] = 18'b100000000000000000;
 buffer[410] = 18'b100000000000000000;
 buffer[411] = 18'b100000000000000000;
 buffer[412] = 18'b100000000000000000;
 buffer[413] = 18'b100000000000000000;
 buffer[414] = 18'b100000000000000000;
 buffer[415] = 18'b100000000000000000;
 buffer[416] = 18'b100000000000000000;
 buffer[417] = 18'b100000000000000000;
 buffer[418] = 18'b100000000000000000;
 buffer[419] = 18'b100000000000000000;
 buffer[420] = 18'b100000000000000000;
 buffer[421] = 18'b100000000000000000;
 buffer[422] = 18'b100000000000000000;
 buffer[423] = 18'b100000000000000000;
 buffer[424] = 18'b100000000000000000;
 buffer[425] = 18'b100000000000000000;
 buffer[426] = 18'b100000000000000000;
 buffer[427] = 18'b100000000000000000;
 buffer[428] = 18'b100000000000000000;
 buffer[429] = 18'b100000000000000000;
 buffer[430] = 18'b100000000000000000;
 buffer[431] = 18'b100000000000000000;
 buffer[432] = 18'b100000000000000000;
 buffer[433] = 18'b100000000000000000;
 buffer[434] = 18'b100000000000000000;
 buffer[435] = 18'b100000000000000000;
 buffer[436] = 18'b100000000000000000;
 buffer[437] = 18'b100000000000000000;
 buffer[438] = 18'b100000000000000000;
 buffer[439] = 18'b100000000000000000;
 buffer[440] = 18'b100000000000000000;
 buffer[441] = 18'b100000000000000000;
 buffer[442] = 18'b100000000000000000;
 buffer[443] = 18'b100000000000000000;
 buffer[444] = 18'b100000000000000000;
 buffer[445] = 18'b100000000000000000;
 buffer[446] = 18'b100000000000000000;
 buffer[447] = 18'b100000000000000000;
 buffer[448] = 18'b100000000000000000;
 buffer[449] = 18'b100000000000000000;
 buffer[450] = 18'b100000000000000000;
 buffer[451] = 18'b100000000000000000;
 buffer[452] = 18'b100000000000000000;
 buffer[453] = 18'b100000000000000000;
 buffer[454] = 18'b100000000000000000;
 buffer[455] = 18'b100000000000000000;
 buffer[456] = 18'b100000000000000000;
 buffer[457] = 18'b100000000000000000;
 buffer[458] = 18'b100000000000000000;
 buffer[459] = 18'b100000000000000000;
 buffer[460] = 18'b100000000000000000;
 buffer[461] = 18'b100000000000000000;
 buffer[462] = 18'b100000000000000000;
 buffer[463] = 18'b100000000000000000;
 buffer[464] = 18'b100000000000000000;
 buffer[465] = 18'b100000000000000000;
 buffer[466] = 18'b100000000000000000;
 buffer[467] = 18'b100000000000000000;
 buffer[468] = 18'b100000000000000000;
 buffer[469] = 18'b100000000000000000;
 buffer[470] = 18'b100000000000000000;
 buffer[471] = 18'b100000000000000000;
 buffer[472] = 18'b100000000000000000;
 buffer[473] = 18'b100000000000000000;
 buffer[474] = 18'b100000000000000000;
 buffer[475] = 18'b100000000000000000;
 buffer[476] = 18'b100000000000000000;
 buffer[477] = 18'b100000000000000000;
 buffer[478] = 18'b100000000000000000;
 buffer[479] = 18'b100000000000000000;
 buffer[480] = 18'b100000000000000000;
 buffer[481] = 18'b100000000000000000;
 buffer[482] = 18'b100000000000000000;
 buffer[483] = 18'b100000000000000000;
 buffer[484] = 18'b100000000000000000;
 buffer[485] = 18'b100000000000000000;
 buffer[486] = 18'b100000000000000000;
 buffer[487] = 18'b100000000000000000;
 buffer[488] = 18'b100000000000000000;
 buffer[489] = 18'b100000000000000000;
 buffer[490] = 18'b100000000000000000;
 buffer[491] = 18'b100000000000000000;
 buffer[492] = 18'b100000000000000000;
 buffer[493] = 18'b100000000000000000;
 buffer[494] = 18'b100000000000000000;
 buffer[495] = 18'b100000000000000000;
 buffer[496] = 18'b100000000000000000;
 buffer[497] = 18'b100000000000000000;
 buffer[498] = 18'b100000000000000000;
 buffer[499] = 18'b100000000000000000;
 buffer[500] = 18'b100000000000000000;
 buffer[501] = 18'b100000000000000000;
 buffer[502] = 18'b100000000000000000;
 buffer[503] = 18'b100000000000000000;
 buffer[504] = 18'b100000000000000000;
 buffer[505] = 18'b100000000000000000;
 buffer[506] = 18'b100000000000000000;
 buffer[507] = 18'b100000000000000000;
 buffer[508] = 18'b100000000000000000;
 buffer[509] = 18'b100000000000000000;
 buffer[510] = 18'b100000000000000000;
 buffer[511] = 18'b100000000000000000;
 buffer[512] = 18'b100000000000000000;
 buffer[513] = 18'b100000000000000000;
 buffer[514] = 18'b100000000000000000;
 buffer[515] = 18'b100000000000000000;
 buffer[516] = 18'b100000000000000000;
 buffer[517] = 18'b100000000000000000;
 buffer[518] = 18'b100000000000000000;
 buffer[519] = 18'b100000000000000000;
 buffer[520] = 18'b100000000000000000;
 buffer[521] = 18'b100000000000000000;
 buffer[522] = 18'b100000000000000000;
 buffer[523] = 18'b100000000000000000;
 buffer[524] = 18'b100000000000000000;
 buffer[525] = 18'b100000000000000000;
 buffer[526] = 18'b100000000000000000;
 buffer[527] = 18'b100000000000000000;
 buffer[528] = 18'b100000000000000000;
 buffer[529] = 18'b100000000000000000;
 buffer[530] = 18'b100000000000000000;
 buffer[531] = 18'b100000000000000000;
 buffer[532] = 18'b100000000000000000;
 buffer[533] = 18'b100000000000000000;
 buffer[534] = 18'b100000000000000000;
 buffer[535] = 18'b100000000000000000;
 buffer[536] = 18'b100000000000000000;
 buffer[537] = 18'b100000000000000000;
 buffer[538] = 18'b100000000000000000;
 buffer[539] = 18'b100000000000000000;
 buffer[540] = 18'b100000000000000000;
 buffer[541] = 18'b100000000000000000;
 buffer[542] = 18'b100000000000000000;
 buffer[543] = 18'b100000000000000000;
 buffer[544] = 18'b100000000000000000;
 buffer[545] = 18'b100000000000000000;
 buffer[546] = 18'b100000000000000000;
 buffer[547] = 18'b100000000000000000;
 buffer[548] = 18'b100000000000000000;
 buffer[549] = 18'b100000000000000000;
 buffer[550] = 18'b100000000000000000;
 buffer[551] = 18'b100000000000000000;
 buffer[552] = 18'b100000000000000000;
 buffer[553] = 18'b100000000000000000;
 buffer[554] = 18'b100000000000000000;
 buffer[555] = 18'b100000000000000000;
 buffer[556] = 18'b100000000000000000;
 buffer[557] = 18'b100000000000000000;
 buffer[558] = 18'b100000000000000000;
 buffer[559] = 18'b100000000000000000;
 buffer[560] = 18'b100000000000000000;
 buffer[561] = 18'b100000000000000000;
 buffer[562] = 18'b100000000000000000;
 buffer[563] = 18'b100000000000000000;
 buffer[564] = 18'b100000000000000000;
 buffer[565] = 18'b100000000000000000;
 buffer[566] = 18'b100000000000000000;
 buffer[567] = 18'b100000000000000000;
 buffer[568] = 18'b100000000000000000;
 buffer[569] = 18'b100000000000000000;
 buffer[570] = 18'b100000000000000000;
 buffer[571] = 18'b100000000000000000;
 buffer[572] = 18'b100000000000000000;
 buffer[573] = 18'b100000000000000000;
 buffer[574] = 18'b100000000000000000;
 buffer[575] = 18'b100000000000000000;
 buffer[576] = 18'b100000000000000000;
 buffer[577] = 18'b100000000000000000;
 buffer[578] = 18'b100000000000000000;
 buffer[579] = 18'b100000000000000000;
 buffer[580] = 18'b100000000000000000;
 buffer[581] = 18'b100000000000000000;
 buffer[582] = 18'b100000000000000000;
 buffer[583] = 18'b100000000000000000;
 buffer[584] = 18'b100000000000000000;
 buffer[585] = 18'b100000000000000000;
 buffer[586] = 18'b100000000000000000;
 buffer[587] = 18'b100000000000000000;
 buffer[588] = 18'b100000000000000000;
 buffer[589] = 18'b100000000000000000;
 buffer[590] = 18'b100000000000000000;
 buffer[591] = 18'b100000000000000000;
 buffer[592] = 18'b100000000000000000;
 buffer[593] = 18'b100000000000000000;
 buffer[594] = 18'b100000000000000000;
 buffer[595] = 18'b100000000000000000;
 buffer[596] = 18'b100000000000000000;
 buffer[597] = 18'b100000000000000000;
 buffer[598] = 18'b100000000000000000;
 buffer[599] = 18'b100000000000000000;
 buffer[600] = 18'b100000000000000000;
 buffer[601] = 18'b100000000000000000;
 buffer[602] = 18'b100000000000000000;
 buffer[603] = 18'b100000000000000000;
 buffer[604] = 18'b100000000000000000;
 buffer[605] = 18'b100000000000000000;
 buffer[606] = 18'b100000000000000000;
 buffer[607] = 18'b100000000000000000;
 buffer[608] = 18'b100000000000000000;
 buffer[609] = 18'b100000000000000000;
 buffer[610] = 18'b100000000000000000;
 buffer[611] = 18'b100000000000000000;
 buffer[612] = 18'b100000000000000000;
 buffer[613] = 18'b100000000000000000;
 buffer[614] = 18'b100000000000000000;
 buffer[615] = 18'b100000000000000000;
 buffer[616] = 18'b100000000000000000;
 buffer[617] = 18'b100000000000000000;
 buffer[618] = 18'b100000000000000000;
 buffer[619] = 18'b100000000000000000;
 buffer[620] = 18'b100000000000000000;
 buffer[621] = 18'b100000000000000000;
 buffer[622] = 18'b100000000000000000;
 buffer[623] = 18'b100000000000000000;
 buffer[624] = 18'b100000000000000000;
 buffer[625] = 18'b100000000000000000;
 buffer[626] = 18'b100000000000000000;
 buffer[627] = 18'b100000000000000000;
 buffer[628] = 18'b100000000000000000;
 buffer[629] = 18'b100000000000000000;
 buffer[630] = 18'b100000000000000000;
 buffer[631] = 18'b100000000000000000;
 buffer[632] = 18'b100000000000000000;
 buffer[633] = 18'b100000000000000000;
 buffer[634] = 18'b100000000000000000;
 buffer[635] = 18'b100000000000000000;
 buffer[636] = 18'b100000000000000000;
 buffer[637] = 18'b100000000000000000;
 buffer[638] = 18'b100000000000000000;
 buffer[639] = 18'b100000000000000000;
 buffer[640] = 18'b100000000000000000;
 buffer[641] = 18'b100000000000000000;
 buffer[642] = 18'b100000000000000000;
 buffer[643] = 18'b100000000000000000;
 buffer[644] = 18'b100000000000000000;
 buffer[645] = 18'b100000000000000000;
 buffer[646] = 18'b100000000000000000;
 buffer[647] = 18'b100000000000000000;
 buffer[648] = 18'b100000000000000000;
 buffer[649] = 18'b100000000000000000;
 buffer[650] = 18'b100000000000000000;
 buffer[651] = 18'b100000000000000000;
 buffer[652] = 18'b100000000000000000;
 buffer[653] = 18'b100000000000000000;
 buffer[654] = 18'b100000000000000000;
 buffer[655] = 18'b100000000000000000;
 buffer[656] = 18'b100000000000000000;
 buffer[657] = 18'b100000000000000000;
 buffer[658] = 18'b100000000000000000;
 buffer[659] = 18'b100000000000000000;
 buffer[660] = 18'b100000000000000000;
 buffer[661] = 18'b100000000000000000;
 buffer[662] = 18'b100000000000000000;
 buffer[663] = 18'b100000000000000000;
 buffer[664] = 18'b100000000000000000;
 buffer[665] = 18'b100000000000000000;
 buffer[666] = 18'b100000000000000000;
 buffer[667] = 18'b100000000000000000;
 buffer[668] = 18'b100000000000000000;
 buffer[669] = 18'b100000000000000000;
 buffer[670] = 18'b100000000000000000;
 buffer[671] = 18'b100000000000000000;
 buffer[672] = 18'b100000000000000000;
 buffer[673] = 18'b100000000000000000;
 buffer[674] = 18'b100000000000000000;
 buffer[675] = 18'b100000000000000000;
 buffer[676] = 18'b100000000000000000;
 buffer[677] = 18'b100000000000000000;
 buffer[678] = 18'b100000000000000000;
 buffer[679] = 18'b100000000000000000;
 buffer[680] = 18'b100000000000000000;
 buffer[681] = 18'b100000000000000000;
 buffer[682] = 18'b100000000000000000;
 buffer[683] = 18'b100000000000000000;
 buffer[684] = 18'b100000000000000000;
 buffer[685] = 18'b100000000000000000;
 buffer[686] = 18'b100000000000000000;
 buffer[687] = 18'b100000000000000000;
 buffer[688] = 18'b100000000000000000;
 buffer[689] = 18'b100000000000000000;
 buffer[690] = 18'b100000000000000000;
 buffer[691] = 18'b100000000000000000;
 buffer[692] = 18'b100000000000000000;
 buffer[693] = 18'b100000000000000000;
 buffer[694] = 18'b100000000000000000;
 buffer[695] = 18'b100000000000000000;
 buffer[696] = 18'b100000000000000000;
 buffer[697] = 18'b100000000000000000;
 buffer[698] = 18'b100000000000000000;
 buffer[699] = 18'b100000000000000000;
 buffer[700] = 18'b100000000000000000;
 buffer[701] = 18'b100000000000000000;
 buffer[702] = 18'b100000000000000000;
 buffer[703] = 18'b100000000000000000;
 buffer[704] = 18'b100000000000000000;
 buffer[705] = 18'b100000000000000000;
 buffer[706] = 18'b100000000000000000;
 buffer[707] = 18'b100000000000000000;
 buffer[708] = 18'b100000000000000000;
 buffer[709] = 18'b100000000000000000;
 buffer[710] = 18'b100000000000000000;
 buffer[711] = 18'b100000000000000000;
 buffer[712] = 18'b100000000000000000;
 buffer[713] = 18'b100000000000000000;
 buffer[714] = 18'b100000000000000000;
 buffer[715] = 18'b100000000000000000;
 buffer[716] = 18'b100000000000000000;
 buffer[717] = 18'b100000000000000000;
 buffer[718] = 18'b100000000000000000;
 buffer[719] = 18'b100000000000000000;
 buffer[720] = 18'b100000000000000000;
 buffer[721] = 18'b100000000000000000;
 buffer[722] = 18'b100000000000000000;
 buffer[723] = 18'b100000000000000000;
 buffer[724] = 18'b100000000000000000;
 buffer[725] = 18'b100000000000000000;
 buffer[726] = 18'b100000000000000000;
 buffer[727] = 18'b100000000000000000;
 buffer[728] = 18'b100000000000000000;
 buffer[729] = 18'b100000000000000000;
 buffer[730] = 18'b100000000000000000;
 buffer[731] = 18'b100000000000000000;
 buffer[732] = 18'b100000000000000000;
 buffer[733] = 18'b100000000000000000;
 buffer[734] = 18'b100000000000000000;
 buffer[735] = 18'b100000000000000000;
 buffer[736] = 18'b100000000000000000;
 buffer[737] = 18'b100000000000000000;
 buffer[738] = 18'b100000000000000000;
 buffer[739] = 18'b100000000000000000;
 buffer[740] = 18'b100000000000000000;
 buffer[741] = 18'b100000000000000000;
 buffer[742] = 18'b100000000000000000;
 buffer[743] = 18'b100000000000000000;
 buffer[744] = 18'b100000000000000000;
 buffer[745] = 18'b100000000000000000;
 buffer[746] = 18'b100000000000000000;
 buffer[747] = 18'b100000000000000000;
 buffer[748] = 18'b100000000000000000;
 buffer[749] = 18'b100000000000000000;
 buffer[750] = 18'b100000000000000000;
 buffer[751] = 18'b100000000000000000;
 buffer[752] = 18'b100000000000000000;
 buffer[753] = 18'b100000000000000000;
 buffer[754] = 18'b100000000000000000;
 buffer[755] = 18'b100000000000000000;
 buffer[756] = 18'b100000000000000000;
 buffer[757] = 18'b100000000000000000;
 buffer[758] = 18'b100000000000000000;
 buffer[759] = 18'b100000000000000000;
 buffer[760] = 18'b100000000000000000;
 buffer[761] = 18'b100000000000000000;
 buffer[762] = 18'b100000000000000000;
 buffer[763] = 18'b100000000000000000;
 buffer[764] = 18'b100000000000000000;
 buffer[765] = 18'b100000000000000000;
 buffer[766] = 18'b100000000000000000;
 buffer[767] = 18'b100000000000000000;
 buffer[768] = 18'b100000000000000000;
 buffer[769] = 18'b100000000000000000;
 buffer[770] = 18'b100000000000000000;
 buffer[771] = 18'b100000000000000000;
 buffer[772] = 18'b100000000000000000;
 buffer[773] = 18'b100000000000000000;
 buffer[774] = 18'b100000000000000000;
 buffer[775] = 18'b100000000000000000;
 buffer[776] = 18'b100000000000000000;
 buffer[777] = 18'b100000000000000000;
 buffer[778] = 18'b100000000000000000;
 buffer[779] = 18'b100000000000000000;
 buffer[780] = 18'b100000000000000000;
 buffer[781] = 18'b100000000000000000;
 buffer[782] = 18'b100000000000000000;
 buffer[783] = 18'b100000000000000000;
 buffer[784] = 18'b100000000000000000;
 buffer[785] = 18'b100000000000000000;
 buffer[786] = 18'b100000000000000000;
 buffer[787] = 18'b100000000000000000;
 buffer[788] = 18'b100000000000000000;
 buffer[789] = 18'b100000000000000000;
 buffer[790] = 18'b100000000000000000;
 buffer[791] = 18'b100000000000000000;
 buffer[792] = 18'b100000000000000000;
 buffer[793] = 18'b100000000000000000;
 buffer[794] = 18'b100000000000000000;
 buffer[795] = 18'b100000000000000000;
 buffer[796] = 18'b100000000000000000;
 buffer[797] = 18'b100000000000000000;
 buffer[798] = 18'b100000000000000000;
 buffer[799] = 18'b100000000000000000;
 buffer[800] = 18'b100000000000000000;
 buffer[801] = 18'b100000000000000000;
 buffer[802] = 18'b100000000000000000;
 buffer[803] = 18'b100000000000000000;
 buffer[804] = 18'b100000000000000000;
 buffer[805] = 18'b100000000000000000;
 buffer[806] = 18'b100000000000000000;
 buffer[807] = 18'b100000000000000000;
 buffer[808] = 18'b100000000000000000;
 buffer[809] = 18'b100000000000000000;
 buffer[810] = 18'b100000000000000000;
 buffer[811] = 18'b100000000000000000;
 buffer[812] = 18'b100000000000000000;
 buffer[813] = 18'b100000000000000000;
 buffer[814] = 18'b100000000000000000;
 buffer[815] = 18'b100000000000000000;
 buffer[816] = 18'b100000000000000000;
 buffer[817] = 18'b100000000000000000;
 buffer[818] = 18'b100000000000000000;
 buffer[819] = 18'b100000000000000000;
 buffer[820] = 18'b100000000000000000;
 buffer[821] = 18'b100000000000000000;
 buffer[822] = 18'b100000000000000000;
 buffer[823] = 18'b100000000000000000;
 buffer[824] = 18'b100000000000000000;
 buffer[825] = 18'b100000000000000000;
 buffer[826] = 18'b100000000000000000;
 buffer[827] = 18'b100000000000000000;
 buffer[828] = 18'b100000000000000000;
 buffer[829] = 18'b100000000000000000;
 buffer[830] = 18'b100000000000000000;
 buffer[831] = 18'b100000000000000000;
 buffer[832] = 18'b100000000000000000;
 buffer[833] = 18'b100000000000000000;
 buffer[834] = 18'b100000000000000000;
 buffer[835] = 18'b100000000000000000;
 buffer[836] = 18'b100000000000000000;
 buffer[837] = 18'b100000000000000000;
 buffer[838] = 18'b100000000000000000;
 buffer[839] = 18'b100000000000000000;
 buffer[840] = 18'b100000000000000000;
 buffer[841] = 18'b100000000000000000;
 buffer[842] = 18'b100000000000000000;
 buffer[843] = 18'b100000000000000000;
 buffer[844] = 18'b100000000000000000;
 buffer[845] = 18'b100000000000000000;
 buffer[846] = 18'b100000000000000000;
 buffer[847] = 18'b100000000000000000;
 buffer[848] = 18'b100000000000000000;
 buffer[849] = 18'b100000000000000000;
 buffer[850] = 18'b100000000000000000;
 buffer[851] = 18'b100000000000000000;
 buffer[852] = 18'b100000000000000000;
 buffer[853] = 18'b100000000000000000;
 buffer[854] = 18'b100000000000000000;
 buffer[855] = 18'b100000000000000000;
 buffer[856] = 18'b100000000000000000;
 buffer[857] = 18'b100000000000000000;
 buffer[858] = 18'b100000000000000000;
 buffer[859] = 18'b100000000000000000;
 buffer[860] = 18'b100000000000000000;
 buffer[861] = 18'b100000000000000000;
 buffer[862] = 18'b100000000000000000;
 buffer[863] = 18'b100000000000000000;
 buffer[864] = 18'b100000000000000000;
 buffer[865] = 18'b100000000000000000;
 buffer[866] = 18'b100000000000000000;
 buffer[867] = 18'b100000000000000000;
 buffer[868] = 18'b100000000000000000;
 buffer[869] = 18'b100000000000000000;
 buffer[870] = 18'b100000000000000000;
 buffer[871] = 18'b100000000000000000;
 buffer[872] = 18'b100000000000000000;
 buffer[873] = 18'b100000000000000000;
 buffer[874] = 18'b100000000000000000;
 buffer[875] = 18'b100000000000000000;
 buffer[876] = 18'b100000000000000000;
 buffer[877] = 18'b100000000000000000;
 buffer[878] = 18'b100000000000000000;
 buffer[879] = 18'b100000000000000000;
 buffer[880] = 18'b100000000000000000;
 buffer[881] = 18'b100000000000000000;
 buffer[882] = 18'b100000000000000000;
 buffer[883] = 18'b100000000000000000;
 buffer[884] = 18'b100000000000000000;
 buffer[885] = 18'b100000000000000000;
 buffer[886] = 18'b100000000000000000;
 buffer[887] = 18'b100000000000000000;
 buffer[888] = 18'b100000000000000000;
 buffer[889] = 18'b100000000000000000;
 buffer[890] = 18'b100000000000000000;
 buffer[891] = 18'b100000000000000000;
 buffer[892] = 18'b100000000000000000;
 buffer[893] = 18'b100000000000000000;
 buffer[894] = 18'b100000000000000000;
 buffer[895] = 18'b100000000000000000;
 buffer[896] = 18'b100000000000000000;
 buffer[897] = 18'b100000000000000000;
 buffer[898] = 18'b100000000000000000;
 buffer[899] = 18'b100000000000000000;
 buffer[900] = 18'b100000000000000000;
 buffer[901] = 18'b100000000000000000;
 buffer[902] = 18'b100000000000000000;
 buffer[903] = 18'b100000000000000000;
 buffer[904] = 18'b100000000000000000;
 buffer[905] = 18'b100000000000000000;
 buffer[906] = 18'b100000000000000000;
 buffer[907] = 18'b100000000000000000;
 buffer[908] = 18'b100000000000000000;
 buffer[909] = 18'b100000000000000000;
 buffer[910] = 18'b100000000000000000;
 buffer[911] = 18'b100000000000000000;
 buffer[912] = 18'b100000000000000000;
 buffer[913] = 18'b100000000000000000;
 buffer[914] = 18'b100000000000000000;
 buffer[915] = 18'b100000000000000000;
 buffer[916] = 18'b100000000000000000;
 buffer[917] = 18'b100000000000000000;
 buffer[918] = 18'b100000000000000000;
 buffer[919] = 18'b100000000000000000;
 buffer[920] = 18'b100000000000000000;
 buffer[921] = 18'b100000000000000000;
 buffer[922] = 18'b100000000000000000;
 buffer[923] = 18'b100000000000000000;
 buffer[924] = 18'b100000000000000000;
 buffer[925] = 18'b100000000000000000;
 buffer[926] = 18'b100000000000000000;
 buffer[927] = 18'b100000000000000000;
 buffer[928] = 18'b100000000000000000;
 buffer[929] = 18'b100000000000000000;
 buffer[930] = 18'b100000000000000000;
 buffer[931] = 18'b100000000000000000;
 buffer[932] = 18'b100000000000000000;
 buffer[933] = 18'b100000000000000000;
 buffer[934] = 18'b100000000000000000;
 buffer[935] = 18'b100000000000000000;
 buffer[936] = 18'b100000000000000000;
 buffer[937] = 18'b100000000000000000;
 buffer[938] = 18'b100000000000000000;
 buffer[939] = 18'b100000000000000000;
 buffer[940] = 18'b100000000000000000;
 buffer[941] = 18'b100000000000000000;
 buffer[942] = 18'b100000000000000000;
 buffer[943] = 18'b100000000000000000;
 buffer[944] = 18'b100000000000000000;
 buffer[945] = 18'b100000000000000000;
 buffer[946] = 18'b100000000000000000;
 buffer[947] = 18'b100000000000000000;
 buffer[948] = 18'b100000000000000000;
 buffer[949] = 18'b100000000000000000;
 buffer[950] = 18'b100000000000000000;
 buffer[951] = 18'b100000000000000000;
 buffer[952] = 18'b100000000000000000;
 buffer[953] = 18'b100000000000000000;
 buffer[954] = 18'b100000000000000000;
 buffer[955] = 18'b100000000000000000;
 buffer[956] = 18'b100000000000000000;
 buffer[957] = 18'b100000000000000000;
 buffer[958] = 18'b100000000000000000;
 buffer[959] = 18'b100000000000000000;
 buffer[960] = 18'b100000000000000000;
 buffer[961] = 18'b100000000000000000;
 buffer[962] = 18'b100000000000000000;
 buffer[963] = 18'b100000000000000000;
 buffer[964] = 18'b100000000000000000;
 buffer[965] = 18'b100000000000000000;
 buffer[966] = 18'b100000000000000000;
 buffer[967] = 18'b100000000000000000;
 buffer[968] = 18'b100000000000000000;
 buffer[969] = 18'b100000000000000000;
 buffer[970] = 18'b100000000000000000;
 buffer[971] = 18'b100000000000000000;
 buffer[972] = 18'b100000000000000000;
 buffer[973] = 18'b100000000000000000;
 buffer[974] = 18'b100000000000000000;
 buffer[975] = 18'b100000000000000000;
 buffer[976] = 18'b100000000000000000;
 buffer[977] = 18'b100000000000000000;
 buffer[978] = 18'b100000000000000000;
 buffer[979] = 18'b100000000000000000;
 buffer[980] = 18'b100000000000000000;
 buffer[981] = 18'b100000000000000000;
 buffer[982] = 18'b100000000000000000;
 buffer[983] = 18'b100000000000000000;
 buffer[984] = 18'b100000000000000000;
 buffer[985] = 18'b100000000000000000;
 buffer[986] = 18'b100000000000000000;
 buffer[987] = 18'b100000000000000000;
 buffer[988] = 18'b100000000000000000;
 buffer[989] = 18'b100000000000000000;
 buffer[990] = 18'b100000000000000000;
 buffer[991] = 18'b100000000000000000;
 buffer[992] = 18'b100000000000000000;
 buffer[993] = 18'b100000000000000000;
 buffer[994] = 18'b100000000000000000;
 buffer[995] = 18'b100000000000000000;
 buffer[996] = 18'b100000000000000000;
 buffer[997] = 18'b100000000000000000;
 buffer[998] = 18'b100000000000000000;
 buffer[999] = 18'b100000000000000000;
 buffer[1000] = 18'b100000000000000000;
 buffer[1001] = 18'b100000000000000000;
 buffer[1002] = 18'b100000000000000000;
 buffer[1003] = 18'b100000000000000000;
 buffer[1004] = 18'b100000000000000000;
 buffer[1005] = 18'b100000000000000000;
 buffer[1006] = 18'b100000000000000000;
 buffer[1007] = 18'b100000000000000000;
 buffer[1008] = 18'b100000000000000000;
 buffer[1009] = 18'b100000000000000000;
 buffer[1010] = 18'b100000000000000000;
 buffer[1011] = 18'b100000000000000000;
 buffer[1012] = 18'b100000000000000000;
 buffer[1013] = 18'b100000000000000000;
 buffer[1014] = 18'b100000000000000000;
 buffer[1015] = 18'b100000000000000000;
 buffer[1016] = 18'b100000000000000000;
 buffer[1017] = 18'b100000000000000000;
 buffer[1018] = 18'b100000000000000000;
 buffer[1019] = 18'b100000000000000000;
 buffer[1020] = 18'b100000000000000000;
 buffer[1021] = 18'b100000000000000000;
 buffer[1022] = 18'b100000000000000000;
 buffer[1023] = 18'b100000000000000000;
 buffer[1024] = 18'b100000000000000000;
 buffer[1025] = 18'b100000000000000000;
 buffer[1026] = 18'b100000000000000000;
 buffer[1027] = 18'b100000000000000000;
 buffer[1028] = 18'b100000000000000000;
 buffer[1029] = 18'b100000000000000000;
 buffer[1030] = 18'b100000000000000000;
 buffer[1031] = 18'b100000000000000000;
 buffer[1032] = 18'b100000000000000000;
 buffer[1033] = 18'b100000000000000000;
 buffer[1034] = 18'b100000000000000000;
 buffer[1035] = 18'b100000000000000000;
 buffer[1036] = 18'b100000000000000000;
 buffer[1037] = 18'b100000000000000000;
 buffer[1038] = 18'b100000000000000000;
 buffer[1039] = 18'b100000000000000000;
 buffer[1040] = 18'b100000000000000000;
 buffer[1041] = 18'b100000000000000000;
 buffer[1042] = 18'b100000000000000000;
 buffer[1043] = 18'b100000000000000000;
 buffer[1044] = 18'b100000000000000000;
 buffer[1045] = 18'b100000000000000000;
 buffer[1046] = 18'b100000000000000000;
 buffer[1047] = 18'b100000000000000000;
 buffer[1048] = 18'b100000000000000000;
 buffer[1049] = 18'b100000000000000000;
 buffer[1050] = 18'b100000000000000000;
 buffer[1051] = 18'b100000000000000000;
 buffer[1052] = 18'b100000000000000000;
 buffer[1053] = 18'b100000000000000000;
 buffer[1054] = 18'b100000000000000000;
 buffer[1055] = 18'b100000000000000000;
 buffer[1056] = 18'b100000000000000000;
 buffer[1057] = 18'b100000000000000000;
 buffer[1058] = 18'b100000000000000000;
 buffer[1059] = 18'b100000000000000000;
 buffer[1060] = 18'b100000000000000000;
 buffer[1061] = 18'b100000000000000000;
 buffer[1062] = 18'b100000000000000000;
 buffer[1063] = 18'b100000000000000000;
 buffer[1064] = 18'b100000000000000000;
 buffer[1065] = 18'b100000000000000000;
 buffer[1066] = 18'b100000000000000000;
 buffer[1067] = 18'b100000000000000000;
 buffer[1068] = 18'b100000000000000000;
 buffer[1069] = 18'b100000000000000000;
 buffer[1070] = 18'b100000000000000000;
 buffer[1071] = 18'b100000000000000000;
 buffer[1072] = 18'b100000000000000000;
 buffer[1073] = 18'b100000000000000000;
 buffer[1074] = 18'b100000000000000000;
 buffer[1075] = 18'b100000000000000000;
 buffer[1076] = 18'b100000000000000000;
 buffer[1077] = 18'b100000000000000000;
 buffer[1078] = 18'b100000000000000000;
 buffer[1079] = 18'b100000000000000000;
 buffer[1080] = 18'b100000000000000000;
 buffer[1081] = 18'b100000000000000000;
 buffer[1082] = 18'b100000000000000000;
 buffer[1083] = 18'b100000000000000000;
 buffer[1084] = 18'b100000000000000000;
 buffer[1085] = 18'b100000000000000000;
 buffer[1086] = 18'b100000000000000000;
 buffer[1087] = 18'b100000000000000000;
 buffer[1088] = 18'b100000000000000000;
 buffer[1089] = 18'b100000000000000000;
 buffer[1090] = 18'b100000000000000000;
 buffer[1091] = 18'b100000000000000000;
 buffer[1092] = 18'b100000000000000000;
 buffer[1093] = 18'b100000000000000000;
 buffer[1094] = 18'b100000000000000000;
 buffer[1095] = 18'b100000000000000000;
 buffer[1096] = 18'b100000000000000000;
 buffer[1097] = 18'b100000000000000000;
 buffer[1098] = 18'b100000000000000000;
 buffer[1099] = 18'b100000000000000000;
 buffer[1100] = 18'b100000000000000000;
 buffer[1101] = 18'b100000000000000000;
 buffer[1102] = 18'b100000000000000000;
 buffer[1103] = 18'b100000000000000000;
 buffer[1104] = 18'b100000000000000000;
 buffer[1105] = 18'b100000000000000000;
 buffer[1106] = 18'b100000000000000000;
 buffer[1107] = 18'b100000000000000000;
 buffer[1108] = 18'b100000000000000000;
 buffer[1109] = 18'b100000000000000000;
 buffer[1110] = 18'b100000000000000000;
 buffer[1111] = 18'b100000000000000000;
 buffer[1112] = 18'b100000000000000000;
 buffer[1113] = 18'b100000000000000000;
 buffer[1114] = 18'b100000000000000000;
 buffer[1115] = 18'b100000000000000000;
 buffer[1116] = 18'b100000000000000000;
 buffer[1117] = 18'b100000000000000000;
 buffer[1118] = 18'b100000000000000000;
 buffer[1119] = 18'b100000000000000000;
 buffer[1120] = 18'b100000000000000000;
 buffer[1121] = 18'b100000000000000000;
 buffer[1122] = 18'b100000000000000000;
 buffer[1123] = 18'b100000000000000000;
 buffer[1124] = 18'b100000000000000000;
 buffer[1125] = 18'b100000000000000000;
 buffer[1126] = 18'b100000000000000000;
 buffer[1127] = 18'b100000000000000000;
 buffer[1128] = 18'b100000000000000000;
 buffer[1129] = 18'b100000000000000000;
 buffer[1130] = 18'b100000000000000000;
 buffer[1131] = 18'b100000000000000000;
 buffer[1132] = 18'b100000000000000000;
 buffer[1133] = 18'b100000000000000000;
 buffer[1134] = 18'b100000000000000000;
 buffer[1135] = 18'b100000000000000000;
 buffer[1136] = 18'b100000000000000000;
 buffer[1137] = 18'b100000000000000000;
 buffer[1138] = 18'b100000000000000000;
 buffer[1139] = 18'b100000000000000000;
 buffer[1140] = 18'b100000000000000000;
 buffer[1141] = 18'b100000000000000000;
 buffer[1142] = 18'b100000000000000000;
 buffer[1143] = 18'b100000000000000000;
 buffer[1144] = 18'b100000000000000000;
 buffer[1145] = 18'b100000000000000000;
 buffer[1146] = 18'b100000000000000000;
 buffer[1147] = 18'b100000000000000000;
 buffer[1148] = 18'b100000000000000000;
 buffer[1149] = 18'b100000000000000000;
 buffer[1150] = 18'b100000000000000000;
 buffer[1151] = 18'b100000000000000000;
 buffer[1152] = 18'b100000000000000000;
 buffer[1153] = 18'b100000000000000000;
 buffer[1154] = 18'b100000000000000000;
 buffer[1155] = 18'b100000000000000000;
 buffer[1156] = 18'b100000000000000000;
 buffer[1157] = 18'b100000000000000000;
 buffer[1158] = 18'b100000000000000000;
 buffer[1159] = 18'b100000000000000000;
 buffer[1160] = 18'b100000000000000000;
 buffer[1161] = 18'b100000000000000000;
 buffer[1162] = 18'b100000000000000000;
 buffer[1163] = 18'b100000000000000000;
 buffer[1164] = 18'b100000000000000000;
 buffer[1165] = 18'b100000000000000000;
 buffer[1166] = 18'b100000000000000000;
 buffer[1167] = 18'b100000000000000000;
 buffer[1168] = 18'b100000000000000000;
 buffer[1169] = 18'b100000000000000000;
 buffer[1170] = 18'b100000000000000000;
 buffer[1171] = 18'b100000000000000000;
 buffer[1172] = 18'b100000000000000000;
 buffer[1173] = 18'b100000000000000000;
 buffer[1174] = 18'b100000000000000000;
 buffer[1175] = 18'b100000000000000000;
 buffer[1176] = 18'b100000000000000000;
 buffer[1177] = 18'b100000000000000000;
 buffer[1178] = 18'b100000000000000000;
 buffer[1179] = 18'b100000000000000000;
 buffer[1180] = 18'b100000000000000000;
 buffer[1181] = 18'b100000000000000000;
 buffer[1182] = 18'b100000000000000000;
 buffer[1183] = 18'b100000000000000000;
 buffer[1184] = 18'b100000000000000000;
 buffer[1185] = 18'b100000000000000000;
 buffer[1186] = 18'b100000000000000000;
 buffer[1187] = 18'b100000000000000000;
 buffer[1188] = 18'b100000000000000000;
 buffer[1189] = 18'b100000000000000000;
 buffer[1190] = 18'b100000000000000000;
 buffer[1191] = 18'b100000000000000000;
 buffer[1192] = 18'b100000000000000000;
 buffer[1193] = 18'b100000000000000000;
 buffer[1194] = 18'b100000000000000000;
 buffer[1195] = 18'b100000000000000000;
 buffer[1196] = 18'b100000000000000000;
 buffer[1197] = 18'b100000000000000000;
 buffer[1198] = 18'b100000000000000000;
 buffer[1199] = 18'b100000000000000000;
 buffer[1200] = 18'b100000000000000000;
 buffer[1201] = 18'b100000000000000000;
 buffer[1202] = 18'b100000000000000000;
 buffer[1203] = 18'b100000000000000000;
 buffer[1204] = 18'b100000000000000000;
 buffer[1205] = 18'b100000000000000000;
 buffer[1206] = 18'b100000000000000000;
 buffer[1207] = 18'b100000000000000000;
 buffer[1208] = 18'b100000000000000000;
 buffer[1209] = 18'b100000000000000000;
 buffer[1210] = 18'b100000000000000000;
 buffer[1211] = 18'b100000000000000000;
 buffer[1212] = 18'b100000000000000000;
 buffer[1213] = 18'b100000000000000000;
 buffer[1214] = 18'b100000000000000000;
 buffer[1215] = 18'b100000000000000000;
 buffer[1216] = 18'b100000000000000000;
 buffer[1217] = 18'b100000000000000000;
 buffer[1218] = 18'b100000000000000000;
 buffer[1219] = 18'b100000000000000000;
 buffer[1220] = 18'b100000000000000000;
 buffer[1221] = 18'b100000000000000000;
 buffer[1222] = 18'b100000000000000000;
 buffer[1223] = 18'b100000000000000000;
 buffer[1224] = 18'b100000000000000000;
 buffer[1225] = 18'b100000000000000000;
 buffer[1226] = 18'b100000000000000000;
 buffer[1227] = 18'b100000000000000000;
 buffer[1228] = 18'b100000000000000000;
 buffer[1229] = 18'b100000000000000000;
 buffer[1230] = 18'b100000000000000000;
 buffer[1231] = 18'b100000000000000000;
 buffer[1232] = 18'b100000000000000000;
 buffer[1233] = 18'b100000000000000000;
 buffer[1234] = 18'b100000000000000000;
 buffer[1235] = 18'b100000000000000000;
 buffer[1236] = 18'b100000000000000000;
 buffer[1237] = 18'b100000000000000000;
 buffer[1238] = 18'b100000000000000000;
 buffer[1239] = 18'b100000000000000000;
 buffer[1240] = 18'b100000000000000000;
 buffer[1241] = 18'b100000000000000000;
 buffer[1242] = 18'b100000000000000000;
 buffer[1243] = 18'b100000000000000000;
 buffer[1244] = 18'b100000000000000000;
 buffer[1245] = 18'b100000000000000000;
 buffer[1246] = 18'b100000000000000000;
 buffer[1247] = 18'b100000000000000000;
 buffer[1248] = 18'b100000000000000000;
 buffer[1249] = 18'b100000000000000000;
 buffer[1250] = 18'b100000000000000000;
 buffer[1251] = 18'b100000000000000000;
 buffer[1252] = 18'b100000000000000000;
 buffer[1253] = 18'b100000000000000000;
 buffer[1254] = 18'b100000000000000000;
 buffer[1255] = 18'b100000000000000000;
 buffer[1256] = 18'b100000000000000000;
 buffer[1257] = 18'b100000000000000000;
 buffer[1258] = 18'b100000000000000000;
 buffer[1259] = 18'b100000000000000000;
 buffer[1260] = 18'b100000000000000000;
 buffer[1261] = 18'b100000000000000000;
 buffer[1262] = 18'b100000000000000000;
 buffer[1263] = 18'b100000000000000000;
 buffer[1264] = 18'b100000000000000000;
 buffer[1265] = 18'b100000000000000000;
 buffer[1266] = 18'b100000000000000000;
 buffer[1267] = 18'b100000000000000000;
 buffer[1268] = 18'b100000000000000000;
 buffer[1269] = 18'b100000000000000000;
 buffer[1270] = 18'b100000000000000000;
 buffer[1271] = 18'b100000000000000000;
 buffer[1272] = 18'b100000000000000000;
 buffer[1273] = 18'b100000000000000000;
 buffer[1274] = 18'b100000000000000000;
 buffer[1275] = 18'b100000000000000000;
 buffer[1276] = 18'b100000000000000000;
 buffer[1277] = 18'b100000000000000000;
 buffer[1278] = 18'b100000000000000000;
 buffer[1279] = 18'b100000000000000000;
 buffer[1280] = 18'b100000000000000000;
 buffer[1281] = 18'b100000000000000000;
 buffer[1282] = 18'b100000000000000000;
 buffer[1283] = 18'b100000000000000000;
 buffer[1284] = 18'b100000000000000000;
 buffer[1285] = 18'b100000000000000000;
 buffer[1286] = 18'b100000000000000000;
 buffer[1287] = 18'b100000000000000000;
 buffer[1288] = 18'b100000000000000000;
 buffer[1289] = 18'b100000000000000000;
 buffer[1290] = 18'b100000000000000000;
 buffer[1291] = 18'b100000000000000000;
 buffer[1292] = 18'b100000000000000000;
 buffer[1293] = 18'b100000000000000000;
 buffer[1294] = 18'b100000000000000000;
 buffer[1295] = 18'b100000000000000000;
 buffer[1296] = 18'b100000000000000000;
 buffer[1297] = 18'b100000000000000000;
 buffer[1298] = 18'b100000000000000000;
 buffer[1299] = 18'b100000000000000000;
 buffer[1300] = 18'b100000000000000000;
 buffer[1301] = 18'b100000000000000000;
 buffer[1302] = 18'b100000000000000000;
 buffer[1303] = 18'b100000000000000000;
 buffer[1304] = 18'b100000000000000000;
 buffer[1305] = 18'b100000000000000000;
 buffer[1306] = 18'b100000000000000000;
 buffer[1307] = 18'b100000000000000000;
 buffer[1308] = 18'b100000000000000000;
 buffer[1309] = 18'b100000000000000000;
 buffer[1310] = 18'b100000000000000000;
 buffer[1311] = 18'b100000000000000000;
 buffer[1312] = 18'b100000000000000000;
 buffer[1313] = 18'b100000000000000000;
 buffer[1314] = 18'b100000000000000000;
 buffer[1315] = 18'b100000000000000000;
 buffer[1316] = 18'b100000000000000000;
 buffer[1317] = 18'b100000000000000000;
 buffer[1318] = 18'b100000000000000000;
 buffer[1319] = 18'b100000000000000000;
 buffer[1320] = 18'b100000000000000000;
 buffer[1321] = 18'b100000000000000000;
 buffer[1322] = 18'b100000000000000000;
 buffer[1323] = 18'b100000000000000000;
 buffer[1324] = 18'b100000000000000000;
 buffer[1325] = 18'b100000000000000000;
 buffer[1326] = 18'b100000000000000000;
 buffer[1327] = 18'b100000000000000000;
 buffer[1328] = 18'b100000000000000000;
 buffer[1329] = 18'b100000000000000000;
 buffer[1330] = 18'b100000000000000000;
 buffer[1331] = 18'b100000000000000000;
 buffer[1332] = 18'b100000000000000000;
 buffer[1333] = 18'b100000000000000000;
 buffer[1334] = 18'b100000000000000000;
 buffer[1335] = 18'b100000000000000000;
 buffer[1336] = 18'b100000000000000000;
 buffer[1337] = 18'b100000000000000000;
 buffer[1338] = 18'b100000000000000000;
 buffer[1339] = 18'b100000000000000000;
 buffer[1340] = 18'b100000000000000000;
 buffer[1341] = 18'b100000000000000000;
 buffer[1342] = 18'b100000000000000000;
 buffer[1343] = 18'b100000000000000000;
end

endmodule

module M_tilemap (
in_pix_x,
in_pix_y,
in_pix_active,
in_pix_vblank,
in_tm_x,
in_tm_y,
in_tm_character,
in_tm_foreground,
in_tm_background,
in_tm_write,
in_tile_writer_tile,
in_tile_writer_line,
in_tile_writer_bitmap,
in_tm_scrollwrap,
out_pix_red,
out_pix_green,
out_pix_blue,
out_tilemap_display,
out_tm_lastaction,
out_tm_active,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [9:0] in_pix_x;
input  [9:0] in_pix_y;
input  [0:0] in_pix_active;
input  [0:0] in_pix_vblank;
input  [5:0] in_tm_x;
input  [5:0] in_tm_y;
input  [4:0] in_tm_character;
input  [5:0] in_tm_foreground;
input  [6:0] in_tm_background;
input  [0:0] in_tm_write;
input  [4:0] in_tile_writer_tile;
input  [3:0] in_tile_writer_line;
input  [15:0] in_tile_writer_bitmap;
input  [3:0] in_tm_scrollwrap;
output  [1:0] out_pix_red;
output  [1:0] out_pix_green;
output  [1:0] out_pix_blue;
output  [0:0] out_tilemap_display;
output  [3:0] out_tm_lastaction;
output  [2:0] out_tm_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [15:0] _w_mem_tiles16x16_rdata0;
wire  [17:0] _w_mem_tiles_rdata0;
wire  [17:0] _w_mem_tiles_copy_rdata0;
wire  [10:0] _w_xtmpos;
wire  [10:0] _w_ytmpos;
wire  [3:0] _w_xintm;
wire  [3:0] _w_yintm;
wire  [0:0] _w_tmpixel;

reg  [8:0] _d_tiles16x16_addr0;
reg  [8:0] _q_tiles16x16_addr0;
reg  [0:0] _d_tiles16x16_wenable1;
reg  [0:0] _q_tiles16x16_wenable1;
reg  [15:0] _d_tiles16x16_wdata1;
reg  [15:0] _q_tiles16x16_wdata1;
reg  [8:0] _d_tiles16x16_addr1;
reg  [8:0] _q_tiles16x16_addr1;
reg  [10:0] _d_tiles_addr0;
reg  [10:0] _q_tiles_addr0;
reg  [0:0] _d_tiles_wenable1;
reg  [0:0] _q_tiles_wenable1;
reg  [17:0] _d_tiles_wdata1;
reg  [17:0] _q_tiles_wdata1;
reg  [10:0] _d_tiles_addr1;
reg  [10:0] _q_tiles_addr1;
reg  [10:0] _d_tiles_copy_addr0;
reg  [10:0] _q_tiles_copy_addr0;
reg  [0:0] _d_tiles_copy_wenable1;
reg  [0:0] _q_tiles_copy_wenable1;
reg  [17:0] _d_tiles_copy_wdata1;
reg  [17:0] _q_tiles_copy_wdata1;
reg  [10:0] _d_tiles_copy_addr1;
reg  [10:0] _q_tiles_copy_addr1;
reg signed [4:0] _d_tm_offset_x;
reg signed [4:0] _q_tm_offset_x;
reg signed [4:0] _d_tm_offset_y;
reg signed [4:0] _q_tm_offset_y;
reg  [0:0] _d_tm_scroll;
reg  [0:0] _q_tm_scroll;
reg  [5:0] _d_x_cursor;
reg  [5:0] _q_x_cursor;
reg  [5:0] _d_y_cursor;
reg  [5:0] _q_y_cursor;
reg  [10:0] _d_y_cursor_addr;
reg  [10:0] _q_y_cursor_addr;
reg  [17:0] _d_new_tile;
reg  [17:0] _q_new_tile;
reg  [17:0] _d_scroll_tile;
reg  [17:0] _q_scroll_tile;
reg  [10:0] _d_tmcsaddr;
reg  [10:0] _q_tmcsaddr;
reg  [1:0] _d_pix_red,_q_pix_red;
reg  [1:0] _d_pix_green,_q_pix_green;
reg  [1:0] _d_pix_blue,_q_pix_blue;
reg  [0:0] _d_tilemap_display,_q_tilemap_display;
reg  [3:0] _d_tm_lastaction,_q_tm_lastaction;
reg  [2:0] _d_tm_active,_q_tm_active;
reg  [5:0] _d_index,_q_index;
assign out_pix_red = _d_pix_red;
assign out_pix_green = _d_pix_green;
assign out_pix_blue = _d_pix_blue;
assign out_tilemap_display = _d_tilemap_display;
assign out_tm_lastaction = _q_tm_lastaction;
assign out_tm_active = _q_tm_active;
assign out_done = (_q_index == 42);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_tiles16x16_addr0 <= 0;
_q_tiles16x16_wenable1 <= 0;
_q_tiles16x16_wdata1 <= 0;
_q_tiles16x16_addr1 <= 0;
_q_tiles_addr0 <= 0;
_q_tiles_wenable1 <= 0;
_q_tiles_wdata1 <= 0;
_q_tiles_addr1 <= 0;
_q_tiles_copy_addr0 <= 0;
_q_tiles_copy_wenable1 <= 0;
_q_tiles_copy_wdata1 <= 0;
_q_tiles_copy_addr1 <= 0;
_q_tm_offset_x <= 0;
_q_tm_offset_y <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_tiles16x16_addr0 <= _d_tiles16x16_addr0;
_q_tiles16x16_wenable1 <= _d_tiles16x16_wenable1;
_q_tiles16x16_wdata1 <= _d_tiles16x16_wdata1;
_q_tiles16x16_addr1 <= _d_tiles16x16_addr1;
_q_tiles_addr0 <= _d_tiles_addr0;
_q_tiles_wenable1 <= _d_tiles_wenable1;
_q_tiles_wdata1 <= _d_tiles_wdata1;
_q_tiles_addr1 <= _d_tiles_addr1;
_q_tiles_copy_addr0 <= _d_tiles_copy_addr0;
_q_tiles_copy_wenable1 <= _d_tiles_copy_wenable1;
_q_tiles_copy_wdata1 <= _d_tiles_copy_wdata1;
_q_tiles_copy_addr1 <= _d_tiles_copy_addr1;
_q_tm_offset_x <= _d_tm_offset_x;
_q_tm_offset_y <= _d_tm_offset_y;
_q_tm_scroll <= _d_tm_scroll;
_q_x_cursor <= _d_x_cursor;
_q_y_cursor <= _d_y_cursor;
_q_y_cursor_addr <= _d_y_cursor_addr;
_q_new_tile <= _d_new_tile;
_q_scroll_tile <= _d_scroll_tile;
_q_tmcsaddr <= _d_tmcsaddr;
_q_pix_red <= _d_pix_red;
_q_pix_green <= _d_pix_green;
_q_pix_blue <= _d_pix_blue;
_q_tilemap_display <= _d_tilemap_display;
_q_tm_lastaction <= _d_tm_lastaction;
_q_tm_active <= _d_tm_active;
_q_index <= _d_index;
  end
end


M_tilemap_mem_tiles16x16 __mem__tiles16x16(
.clock0(clock),
.clock1(clock),
.in_tiles16x16_addr0(_d_tiles16x16_addr0),
.in_tiles16x16_wenable1(_d_tiles16x16_wenable1),
.in_tiles16x16_wdata1(_d_tiles16x16_wdata1),
.in_tiles16x16_addr1(_d_tiles16x16_addr1),
.out_tiles16x16_rdata0(_w_mem_tiles16x16_rdata0)
);
M_tilemap_mem_tiles __mem__tiles(
.clock0(clock),
.clock1(clock),
.in_tiles_addr0(_d_tiles_addr0),
.in_tiles_wenable1(_d_tiles_wenable1),
.in_tiles_wdata1(_d_tiles_wdata1),
.in_tiles_addr1(_d_tiles_addr1),
.out_tiles_rdata0(_w_mem_tiles_rdata0)
);
M_tilemap_mem_tiles_copy __mem__tiles_copy(
.clock0(clock),
.clock1(clock),
.in_tiles_copy_addr0(_d_tiles_copy_addr0),
.in_tiles_copy_wenable1(_d_tiles_copy_wenable1),
.in_tiles_copy_wdata1(_d_tiles_copy_wdata1),
.in_tiles_copy_addr1(_d_tiles_copy_addr1),
.out_tiles_copy_rdata0(_w_mem_tiles_copy_rdata0)
);

assign _w_tmpixel = _w_mem_tiles16x16_rdata0[15-_w_xintm+:1];
assign _w_yintm = {1'b0,(in_pix_y)&15}+_d_tm_offset_y;
assign _w_xintm = {1'b0,(in_pix_x)&15}+_d_tm_offset_x;
assign _w_ytmpos = ((in_pix_vblank?(11'd16+{{6{_d_tm_offset_y[4+:1]}},_d_tm_offset_y}):in_pix_y+(11'd16+{{6{_d_tm_offset_y[4+:1]}},_d_tm_offset_y}))>>4)*42;
assign _w_xtmpos = (in_pix_active?in_pix_x+(11'd18+{{6{_d_tm_offset_x[4+:1]}},_d_tm_offset_x}):(11'd16+{{6{_d_tm_offset_x[4+:1]}},_d_tm_offset_x}))>>4;

always @* begin
_d_tiles16x16_addr0 = _q_tiles16x16_addr0;
_d_tiles16x16_wenable1 = _q_tiles16x16_wenable1;
_d_tiles16x16_wdata1 = _q_tiles16x16_wdata1;
_d_tiles16x16_addr1 = _q_tiles16x16_addr1;
_d_tiles_addr0 = _q_tiles_addr0;
_d_tiles_wenable1 = _q_tiles_wenable1;
_d_tiles_wdata1 = _q_tiles_wdata1;
_d_tiles_addr1 = _q_tiles_addr1;
_d_tiles_copy_addr0 = _q_tiles_copy_addr0;
_d_tiles_copy_wenable1 = _q_tiles_copy_wenable1;
_d_tiles_copy_wdata1 = _q_tiles_copy_wdata1;
_d_tiles_copy_addr1 = _q_tiles_copy_addr1;
_d_tm_offset_x = _q_tm_offset_x;
_d_tm_offset_y = _q_tm_offset_y;
_d_tm_scroll = _q_tm_scroll;
_d_x_cursor = _q_x_cursor;
_d_y_cursor = _q_y_cursor;
_d_y_cursor_addr = _q_y_cursor_addr;
_d_new_tile = _q_new_tile;
_d_scroll_tile = _q_scroll_tile;
_d_tmcsaddr = _q_tmcsaddr;
_d_pix_red = _q_pix_red;
_d_pix_green = _q_pix_green;
_d_pix_blue = _q_pix_blue;
_d_tilemap_display = _q_tilemap_display;
_d_tm_lastaction = _q_tm_lastaction;
_d_tm_active = _q_tm_active;
_d_index = _q_index;
// _always_pre
_d_tiles_addr0 = _w_xtmpos+_w_ytmpos;
_d_tiles_wenable1 = 1;
_d_tiles_copy_wenable1 = 1;
_d_tiles16x16_addr0 = _w_mem_tiles_rdata0[0+:5]*16+_w_yintm;
_d_tiles16x16_addr1 = in_tile_writer_tile*16+in_tile_writer_line;
_d_tiles16x16_wdata1 = in_tile_writer_bitmap;
_d_tiles16x16_wenable1 = 1;
_d_tilemap_display = in_pix_active&&((_w_tmpixel)||(~_w_mem_tiles_rdata0[17+:1]));
_d_pix_red = _w_tmpixel?_w_mem_tiles_rdata0[9+:2]:_w_mem_tiles_rdata0[15+:2];
_d_pix_green = _w_tmpixel?_w_mem_tiles_rdata0[7+:2]:_w_mem_tiles_rdata0[13+:2];
_d_pix_blue = _w_tmpixel?_w_mem_tiles_rdata0[5+:2]:_w_mem_tiles_rdata0[11+:2];
_d_index = 42;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_tiles16x16_addr0 = 0;
_d_tiles16x16_wenable1 = 0;
_d_tiles16x16_wdata1 = 0;
_d_tiles16x16_addr1 = 0;
_d_tiles_addr0 = 0;
_d_tiles_wenable1 = 0;
_d_tiles_wdata1 = 0;
_d_tiles_addr1 = 0;
_d_tiles_copy_addr0 = 0;
_d_tiles_copy_wenable1 = 0;
_d_tiles_copy_wdata1 = 0;
_d_tiles_copy_addr1 = 0;
_d_tm_offset_x = 0;
_d_tm_offset_y = 0;
// --
_d_tiles_addr1 = 0;
_d_tiles_wdata1 = {1'b1,6'b0,6'b0,5'b0};
_d_tiles_copy_addr1 = 0;
_d_tiles_copy_wdata1 = {1'b1,6'b0,6'b0,5'b0};
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_tm_write==1) begin
// __block_5
// __block_7
_d_tiles_addr1 = in_tm_x+in_tm_y*42;
_d_tiles_wdata1 = {in_tm_background,in_tm_foreground,in_tm_character};
_d_tiles_copy_addr1 = in_tm_x+in_tm_y*42;
_d_tiles_copy_wdata1 = {in_tm_background,in_tm_foreground,in_tm_character};
// __block_8
end else begin
// __block_6
end
// __block_9
  case (_q_tm_active)
  0: begin
// __block_11_case
// __block_12
  case (in_tm_scrollwrap)
  1: begin
// __block_14_case
// __block_15
if (_q_tm_offset_x==15) begin
// __block_16
// __block_18
_d_tm_scroll = 1;
_d_tm_lastaction = in_tm_scrollwrap;
_d_tm_active = 1;
// __block_19
end else begin
// __block_17
// __block_20
_d_tm_offset_x = _q_tm_offset_x+1;
_d_tm_lastaction = 0;
// __block_21
end
// __block_22
// __block_23
  end
  2: begin
// __block_24_case
// __block_25
if (_q_tm_offset_y==15) begin
// __block_26
// __block_28
_d_tm_scroll = 1;
_d_tm_lastaction = in_tm_scrollwrap;
_d_tm_active = 3;
// __block_29
end else begin
// __block_27
// __block_30
_d_tm_offset_y = _q_tm_offset_y+1;
_d_tm_lastaction = 0;
// __block_31
end
// __block_32
// __block_33
  end
  3: begin
// __block_34_case
// __block_35
if (_q_tm_offset_x==-15) begin
// __block_36
// __block_38
_d_tm_scroll = 1;
_d_tm_lastaction = in_tm_scrollwrap;
_d_tm_active = 2;
// __block_39
end else begin
// __block_37
// __block_40
_d_tm_offset_x = _q_tm_offset_x-1;
_d_tm_lastaction = 0;
// __block_41
end
// __block_42
// __block_43
  end
  4: begin
// __block_44_case
// __block_45
if (_q_tm_offset_y==-15) begin
// __block_46
// __block_48
_d_tm_scroll = 1;
_d_tm_lastaction = in_tm_scrollwrap;
_d_tm_active = 4;
// __block_49
end else begin
// __block_47
// __block_50
_d_tm_offset_y = _q_tm_offset_y-1;
_d_tm_lastaction = 0;
// __block_51
end
// __block_52
// __block_53
  end
  5: begin
// __block_54_case
// __block_55
if (_q_tm_offset_x==15) begin
// __block_56
// __block_58
_d_tm_scroll = 0;
_d_tm_lastaction = in_tm_scrollwrap;
_d_tm_active = 1;
// __block_59
end else begin
// __block_57
// __block_60
_d_tm_offset_x = _q_tm_offset_x+1;
_d_tm_lastaction = 0;
// __block_61
end
// __block_62
// __block_63
  end
  6: begin
// __block_64_case
// __block_65
if (_q_tm_offset_y==15) begin
// __block_66
// __block_68
_d_tm_scroll = 0;
_d_tm_lastaction = in_tm_scrollwrap;
_d_tm_active = 3;
// __block_69
end else begin
// __block_67
// __block_70
_d_tm_offset_y = _q_tm_offset_y+1;
_d_tm_lastaction = 0;
// __block_71
end
// __block_72
// __block_73
  end
  7: begin
// __block_74_case
// __block_75
if (_q_tm_offset_x==-15) begin
// __block_76
// __block_78
_d_tm_scroll = 0;
_d_tm_lastaction = in_tm_scrollwrap;
_d_tm_active = 2;
// __block_79
end else begin
// __block_77
// __block_80
_d_tm_offset_x = _q_tm_offset_x-1;
_d_tm_lastaction = 0;
// __block_81
end
// __block_82
// __block_83
  end
  8: begin
// __block_84_case
// __block_85
if (_q_tm_offset_y==-15) begin
// __block_86
// __block_88
_d_tm_scroll = 0;
_d_tm_lastaction = in_tm_scrollwrap;
_d_tm_active = 4;
// __block_89
end else begin
// __block_87
// __block_90
_d_tm_offset_y = _q_tm_offset_y-1;
_d_tm_lastaction = 0;
// __block_91
end
// __block_92
// __block_93
  end
  9: begin
// __block_94_case
// __block_95
_d_tm_active = 5;
_d_tm_lastaction = 9;
// __block_96
  end
endcase
// __block_13
// __block_97
_d_index = 1;
  end
  1: begin
// __block_98_case
// __block_99
_d_y_cursor = 0;
_d_y_cursor_addr = 0;
_d_index = 3;
  end
  2: begin
// __block_118_case
// __block_119
_d_y_cursor = 0;
_d_y_cursor_addr = 0;
_d_index = 4;
  end
  3: begin
// __block_138_case
// __block_139
_d_x_cursor = 0;
_d_index = 5;
  end
  4: begin
// __block_157_case
// __block_158
_d_x_cursor = 0;
_d_index = 6;
  end
  5: begin
// __block_176_case
// __block_177
_d_tmcsaddr = 0;
_d_tiles_wdata1 = {1'b1,6'b0,6'b0,5'b0};
_d_tiles_copy_wdata1 = {1'b1,6'b0,6'b0,5'b0};
_d_index = 7;
  end
endcase
end else begin
_d_index = 2;
end
end
3: begin
// __block_100
_d_index = 8;
end
4: begin
// __block_120
_d_index = 9;
end
5: begin
// __block_140
_d_index = 10;
end
6: begin
// __block_159
_d_index = 11;
end
7: begin
// __block_178
_d_index = 12;
end
2: begin
// __block_3
_d_index = 42;
end
8: begin
// __while__block_101
if (_q_y_cursor<32) begin
// __block_102
// __block_104
_d_x_cursor = 0;
_d_tiles_copy_addr0 = _q_y_cursor_addr;
_d_index = 18;
end else begin
_d_index = 13;
end
end
9: begin
// __while__block_121
if (_q_y_cursor<32) begin
// __block_122
// __block_124
_d_x_cursor = 41;
_d_tiles_copy_addr0 = 41+_q_y_cursor_addr;
_d_index = 19;
end else begin
_d_index = 14;
end
end
10: begin
// __while__block_141
if (_q_x_cursor<42) begin
// __block_142
// __block_144
_d_y_cursor = 0;
_d_y_cursor_addr = 0;
_d_tiles_copy_addr0 = _q_x_cursor;
_d_index = 20;
end else begin
_d_index = 15;
end
end
11: begin
// __while__block_160
if (_q_x_cursor<42) begin
// __block_161
// __block_163
_d_y_cursor = 0;
_d_y_cursor_addr = 1302;
_d_tiles_copy_addr0 = _q_x_cursor;
_d_index = 21;
end else begin
_d_index = 16;
end
end
12: begin
// __while__block_179
if (_q_tmcsaddr<1344) begin
// __block_180
// __block_182
_d_tiles_addr1 = _q_tmcsaddr;
_d_tiles_copy_addr1 = _q_tmcsaddr;
_d_tmcsaddr = _q_tmcsaddr+1;
// __block_183
_d_index = 12;
end else begin
_d_index = 17;
end
end
18: begin
// __block_105
_d_new_tile = (_q_tm_scroll==1)?{1'b1,6'b0,6'b0,5'b0}:_w_mem_tiles_copy_rdata0;
_d_index = 22;
end
13: begin
// __block_116
_d_tm_offset_x = 0;
_d_tm_active = 0;
// __block_117
_d_index = 1;
end
19: begin
// __block_125
_d_new_tile = (_q_tm_scroll==1)?{1'b1,6'b0,6'b0,5'b0}:_w_mem_tiles_copy_rdata0;
_d_index = 23;
end
14: begin
// __block_136
_d_tm_offset_x = 0;
_d_tm_active = 0;
// __block_137
_d_index = 1;
end
20: begin
// __block_145
_d_new_tile = (_q_tm_scroll==1)?{1'b1,6'b0,6'b0,5'b0}:_w_mem_tiles_copy_rdata0;
_d_index = 24;
end
15: begin
// __block_155
_d_tm_offset_y = 0;
_d_tm_active = 0;
// __block_156
_d_index = 1;
end
21: begin
// __block_164
_d_new_tile = (_q_tm_scroll==1)?{1'b1,6'b0,6'b0,5'b0}:_w_mem_tiles_copy_rdata0;
_d_index = 25;
end
16: begin
// __block_174
_d_tm_offset_y = 0;
_d_tm_active = 0;
// __block_175
_d_index = 1;
end
17: begin
// __block_184
_d_tm_offset_x = 0;
_d_tm_offset_y = 0;
_d_tm_active = 0;
// __block_185
_d_index = 1;
end
22: begin
// __block_106
_d_index = 26;
end
23: begin
// __block_126
_d_index = 27;
end
24: begin
// __block_146
_d_index = 28;
end
25: begin
// __block_165
_d_index = 29;
end
26: begin
// __while__block_107
if (_q_x_cursor<42) begin
// __block_108
// __block_110
_d_tiles_copy_addr0 = (_q_x_cursor+1)+_q_y_cursor_addr;
_d_index = 34;
end else begin
_d_index = 30;
end
end
27: begin
// __while__block_127
if (_q_x_cursor>0) begin
// __block_128
// __block_130
_d_tiles_copy_addr0 = (_q_x_cursor-1)+_q_y_cursor_addr;
_d_index = 35;
end else begin
_d_index = 31;
end
end
28: begin
// __while__block_147
if (_q_y_cursor<31) begin
// __block_148
// __block_150
_d_tiles_copy_addr0 = _q_x_cursor+_q_y_cursor_addr+42;
_d_index = 36;
end else begin
_d_index = 32;
end
end
29: begin
// __while__block_166
if (_q_y_cursor>0) begin
// __block_167
// __block_169
_d_tiles_copy_addr0 = _q_x_cursor+_q_y_cursor_addr-42;
_d_index = 37;
end else begin
_d_index = 33;
end
end
34: begin
// __block_111
_d_scroll_tile = _w_mem_tiles_copy_rdata0;
_d_index = 38;
end
30: begin
// __block_114
_d_tiles_addr1 = (41)+_q_y_cursor_addr;
_d_tiles_wdata1 = _q_new_tile;
_d_tiles_copy_addr1 = (41)+_q_y_cursor_addr;
_d_tiles_copy_wdata1 = _q_new_tile;
_d_y_cursor = _q_y_cursor+1;
_d_y_cursor_addr = _q_y_cursor_addr+42;
// __block_115
_d_index = 8;
end
35: begin
// __block_131
_d_scroll_tile = _w_mem_tiles_copy_rdata0;
_d_index = 39;
end
31: begin
// __block_134
_d_tiles_addr1 = _q_y_cursor_addr;
_d_tiles_wdata1 = _q_new_tile;
_d_tiles_copy_addr1 = _q_y_cursor_addr;
_d_tiles_copy_wdata1 = _q_new_tile;
_d_y_cursor = _q_y_cursor+1;
_d_y_cursor_addr = _q_y_cursor_addr+42;
// __block_135
_d_index = 9;
end
36: begin
// __block_151
_d_scroll_tile = _w_mem_tiles_copy_rdata0;
_d_index = 40;
end
32: begin
// __block_149
_d_tiles_addr1 = _q_x_cursor+1302;
_d_tiles_wdata1 = _q_new_tile;
_d_tiles_copy_addr1 = _q_x_cursor+1302;
_d_tiles_copy_wdata1 = _q_new_tile;
_d_x_cursor = _q_x_cursor+1;
// __block_154
_d_index = 10;
end
37: begin
// __block_170
_d_scroll_tile = _w_mem_tiles_copy_rdata0;
_d_index = 41;
end
33: begin
// __block_168
_d_tiles_addr1 = _q_x_cursor;
_d_tiles_wdata1 = _q_new_tile;
_d_tiles_copy_addr1 = _q_x_cursor;
_d_tiles_copy_wdata1 = _q_new_tile;
_d_x_cursor = _q_x_cursor+1;
// __block_173
_d_index = 11;
end
38: begin
// __block_112
_d_tiles_addr1 = (_q_x_cursor)+_q_y_cursor_addr;
_d_tiles_wdata1 = _q_scroll_tile;
_d_tiles_copy_addr1 = (_q_x_cursor)+_q_y_cursor_addr;
_d_tiles_copy_wdata1 = _q_scroll_tile;
_d_x_cursor = _q_x_cursor+1;
// __block_113
_d_index = 26;
end
39: begin
// __block_132
_d_tiles_addr1 = (_q_x_cursor)+_q_y_cursor_addr;
_d_tiles_wdata1 = _q_scroll_tile;
_d_tiles_copy_addr1 = (_q_x_cursor)+_q_y_cursor_addr;
_d_tiles_copy_wdata1 = _q_scroll_tile;
_d_x_cursor = _q_x_cursor-1;
// __block_133
_d_index = 27;
end
40: begin
// __block_152
_d_tiles_addr1 = (_q_x_cursor)+_q_y_cursor_addr;
_d_tiles_wdata1 = _q_scroll_tile;
_d_tiles_copy_addr1 = (_q_x_cursor)+_q_y_cursor_addr;
_d_tiles_copy_wdata1 = _q_scroll_tile;
_d_y_cursor = _q_y_cursor+1;
_d_y_cursor_addr = _q_y_cursor_addr+42;
// __block_153
_d_index = 28;
end
41: begin
// __block_171
_d_tiles_addr1 = (_q_x_cursor)+_q_y_cursor_addr;
_d_tiles_wdata1 = _q_scroll_tile;
_d_tiles_copy_addr1 = (_q_x_cursor)+_q_y_cursor_addr;
_d_tiles_copy_wdata1 = _q_scroll_tile;
_d_y_cursor = _q_y_cursor-1;
_d_y_cursor_addr = _q_y_cursor_addr-42;
// __block_172
_d_index = 29;
end
42: begin // end of tilemap
end
default: begin 
_d_index = 42;
 end
endcase
end
endmodule


module M_apu_mem_waveformtable(
input                  [8:0] in_waveformtable_addr,
output reg  [3:0] out_waveformtable_rdata,
input                                   clock
);
reg  [3:0] buffer[511:0];
always @(posedge clock) begin
   out_waveformtable_rdata <= buffer[in_waveformtable_addr];
end
initial begin
 buffer[0] = 15;
 buffer[1] = 15;
 buffer[2] = 15;
 buffer[3] = 15;
 buffer[4] = 15;
 buffer[5] = 15;
 buffer[6] = 15;
 buffer[7] = 15;
 buffer[8] = 15;
 buffer[9] = 15;
 buffer[10] = 15;
 buffer[11] = 15;
 buffer[12] = 15;
 buffer[13] = 15;
 buffer[14] = 15;
 buffer[15] = 15;
 buffer[16] = 0;
 buffer[17] = 0;
 buffer[18] = 0;
 buffer[19] = 0;
 buffer[20] = 0;
 buffer[21] = 0;
 buffer[22] = 0;
 buffer[23] = 0;
 buffer[24] = 0;
 buffer[25] = 0;
 buffer[26] = 0;
 buffer[27] = 0;
 buffer[28] = 0;
 buffer[29] = 0;
 buffer[30] = 0;
 buffer[31] = 0;
 buffer[32] = 0;
 buffer[33] = 0;
 buffer[34] = 1;
 buffer[35] = 1;
 buffer[36] = 2;
 buffer[37] = 2;
 buffer[38] = 3;
 buffer[39] = 3;
 buffer[40] = 4;
 buffer[41] = 4;
 buffer[42] = 5;
 buffer[43] = 5;
 buffer[44] = 6;
 buffer[45] = 6;
 buffer[46] = 7;
 buffer[47] = 7;
 buffer[48] = 8;
 buffer[49] = 8;
 buffer[50] = 9;
 buffer[51] = 9;
 buffer[52] = 10;
 buffer[53] = 10;
 buffer[54] = 11;
 buffer[55] = 11;
 buffer[56] = 12;
 buffer[57] = 12;
 buffer[58] = 13;
 buffer[59] = 13;
 buffer[60] = 14;
 buffer[61] = 14;
 buffer[62] = 15;
 buffer[63] = 15;
 buffer[64] = 0;
 buffer[65] = 1;
 buffer[66] = 2;
 buffer[67] = 3;
 buffer[68] = 4;
 buffer[69] = 5;
 buffer[70] = 6;
 buffer[71] = 7;
 buffer[72] = 8;
 buffer[73] = 9;
 buffer[74] = 10;
 buffer[75] = 11;
 buffer[76] = 12;
 buffer[77] = 13;
 buffer[78] = 14;
 buffer[79] = 15;
 buffer[80] = 15;
 buffer[81] = 14;
 buffer[82] = 13;
 buffer[83] = 12;
 buffer[84] = 11;
 buffer[85] = 10;
 buffer[86] = 9;
 buffer[87] = 8;
 buffer[88] = 7;
 buffer[89] = 6;
 buffer[90] = 5;
 buffer[91] = 4;
 buffer[92] = 3;
 buffer[93] = 2;
 buffer[94] = 1;
 buffer[95] = 0;
 buffer[96] = 7;
 buffer[97] = 8;
 buffer[98] = 10;
 buffer[99] = 11;
 buffer[100] = 12;
 buffer[101] = 13;
 buffer[102] = 13;
 buffer[103] = 14;
 buffer[104] = 15;
 buffer[105] = 14;
 buffer[106] = 13;
 buffer[107] = 13;
 buffer[108] = 12;
 buffer[109] = 11;
 buffer[110] = 10;
 buffer[111] = 8;
 buffer[112] = 7;
 buffer[113] = 6;
 buffer[114] = 4;
 buffer[115] = 3;
 buffer[116] = 2;
 buffer[117] = 1;
 buffer[118] = 1;
 buffer[119] = 0;
 buffer[120] = 0;
 buffer[121] = 0;
 buffer[122] = 1;
 buffer[123] = 1;
 buffer[124] = 2;
 buffer[125] = 3;
 buffer[126] = 4;
 buffer[127] = 6;
 buffer[128] = 1;
 buffer[129] = 1;
 buffer[130] = 1;
 buffer[131] = 1;
 buffer[132] = 1;
 buffer[133] = 1;
 buffer[134] = 1;
 buffer[135] = 1;
 buffer[136] = 1;
 buffer[137] = 1;
 buffer[138] = 1;
 buffer[139] = 1;
 buffer[140] = 1;
 buffer[141] = 1;
 buffer[142] = 1;
 buffer[143] = 1;
 buffer[144] = 1;
 buffer[145] = 1;
 buffer[146] = 1;
 buffer[147] = 1;
 buffer[148] = 1;
 buffer[149] = 1;
 buffer[150] = 1;
 buffer[151] = 1;
 buffer[152] = 1;
 buffer[153] = 1;
 buffer[154] = 1;
 buffer[155] = 1;
 buffer[156] = 1;
 buffer[157] = 1;
 buffer[158] = 1;
 buffer[159] = 1;
 buffer[160] = 1;
 buffer[161] = 1;
 buffer[162] = 1;
 buffer[163] = 1;
 buffer[164] = 1;
 buffer[165] = 1;
 buffer[166] = 1;
 buffer[167] = 1;
 buffer[168] = 1;
 buffer[169] = 1;
 buffer[170] = 1;
 buffer[171] = 1;
 buffer[172] = 1;
 buffer[173] = 1;
 buffer[174] = 1;
 buffer[175] = 1;
 buffer[176] = 1;
 buffer[177] = 1;
 buffer[178] = 1;
 buffer[179] = 1;
 buffer[180] = 1;
 buffer[181] = 1;
 buffer[182] = 1;
 buffer[183] = 1;
 buffer[184] = 1;
 buffer[185] = 1;
 buffer[186] = 1;
 buffer[187] = 1;
 buffer[188] = 1;
 buffer[189] = 1;
 buffer[190] = 1;
 buffer[191] = 1;
 buffer[192] = 1;
 buffer[193] = 1;
 buffer[194] = 1;
 buffer[195] = 1;
 buffer[196] = 1;
 buffer[197] = 1;
 buffer[198] = 1;
 buffer[199] = 1;
 buffer[200] = 1;
 buffer[201] = 1;
 buffer[202] = 1;
 buffer[203] = 1;
 buffer[204] = 1;
 buffer[205] = 1;
 buffer[206] = 1;
 buffer[207] = 1;
 buffer[208] = 1;
 buffer[209] = 1;
 buffer[210] = 1;
 buffer[211] = 1;
 buffer[212] = 1;
 buffer[213] = 1;
 buffer[214] = 1;
 buffer[215] = 1;
 buffer[216] = 1;
 buffer[217] = 1;
 buffer[218] = 1;
 buffer[219] = 1;
 buffer[220] = 1;
 buffer[221] = 1;
 buffer[222] = 1;
 buffer[223] = 1;
 buffer[224] = 1;
 buffer[225] = 1;
 buffer[226] = 1;
 buffer[227] = 1;
 buffer[228] = 1;
 buffer[229] = 1;
 buffer[230] = 1;
 buffer[231] = 1;
 buffer[232] = 1;
 buffer[233] = 1;
 buffer[234] = 1;
 buffer[235] = 1;
 buffer[236] = 1;
 buffer[237] = 1;
 buffer[238] = 1;
 buffer[239] = 1;
 buffer[240] = 1;
 buffer[241] = 1;
 buffer[242] = 1;
 buffer[243] = 1;
 buffer[244] = 1;
 buffer[245] = 1;
 buffer[246] = 1;
 buffer[247] = 1;
 buffer[248] = 1;
 buffer[249] = 1;
 buffer[250] = 1;
 buffer[251] = 1;
 buffer[252] = 1;
 buffer[253] = 1;
 buffer[254] = 1;
 buffer[255] = 1;
 buffer[256] = 1;
 buffer[257] = 1;
 buffer[258] = 1;
 buffer[259] = 1;
 buffer[260] = 1;
 buffer[261] = 1;
 buffer[262] = 1;
 buffer[263] = 1;
 buffer[264] = 1;
 buffer[265] = 1;
 buffer[266] = 1;
 buffer[267] = 1;
 buffer[268] = 1;
 buffer[269] = 1;
 buffer[270] = 1;
 buffer[271] = 1;
 buffer[272] = 1;
 buffer[273] = 1;
 buffer[274] = 1;
 buffer[275] = 1;
 buffer[276] = 1;
 buffer[277] = 1;
 buffer[278] = 1;
 buffer[279] = 1;
 buffer[280] = 1;
 buffer[281] = 1;
 buffer[282] = 1;
 buffer[283] = 1;
 buffer[284] = 1;
 buffer[285] = 1;
 buffer[286] = 1;
 buffer[287] = 1;
 buffer[288] = 1;
 buffer[289] = 1;
 buffer[290] = 1;
 buffer[291] = 1;
 buffer[292] = 1;
 buffer[293] = 1;
 buffer[294] = 1;
 buffer[295] = 1;
 buffer[296] = 1;
 buffer[297] = 1;
 buffer[298] = 1;
 buffer[299] = 1;
 buffer[300] = 1;
 buffer[301] = 1;
 buffer[302] = 1;
 buffer[303] = 1;
 buffer[304] = 1;
 buffer[305] = 1;
 buffer[306] = 1;
 buffer[307] = 1;
 buffer[308] = 1;
 buffer[309] = 1;
 buffer[310] = 1;
 buffer[311] = 1;
 buffer[312] = 1;
 buffer[313] = 1;
 buffer[314] = 1;
 buffer[315] = 1;
 buffer[316] = 1;
 buffer[317] = 1;
 buffer[318] = 1;
 buffer[319] = 1;
 buffer[320] = 1;
 buffer[321] = 1;
 buffer[322] = 1;
 buffer[323] = 1;
 buffer[324] = 1;
 buffer[325] = 1;
 buffer[326] = 1;
 buffer[327] = 1;
 buffer[328] = 1;
 buffer[329] = 1;
 buffer[330] = 1;
 buffer[331] = 1;
 buffer[332] = 1;
 buffer[333] = 1;
 buffer[334] = 1;
 buffer[335] = 1;
 buffer[336] = 1;
 buffer[337] = 1;
 buffer[338] = 1;
 buffer[339] = 1;
 buffer[340] = 1;
 buffer[341] = 1;
 buffer[342] = 1;
 buffer[343] = 1;
 buffer[344] = 1;
 buffer[345] = 1;
 buffer[346] = 1;
 buffer[347] = 1;
 buffer[348] = 1;
 buffer[349] = 1;
 buffer[350] = 1;
 buffer[351] = 1;
 buffer[352] = 1;
 buffer[353] = 1;
 buffer[354] = 1;
 buffer[355] = 1;
 buffer[356] = 1;
 buffer[357] = 1;
 buffer[358] = 1;
 buffer[359] = 1;
 buffer[360] = 1;
 buffer[361] = 1;
 buffer[362] = 1;
 buffer[363] = 1;
 buffer[364] = 1;
 buffer[365] = 1;
 buffer[366] = 1;
 buffer[367] = 1;
 buffer[368] = 1;
 buffer[369] = 1;
 buffer[370] = 1;
 buffer[371] = 1;
 buffer[372] = 1;
 buffer[373] = 1;
 buffer[374] = 1;
 buffer[375] = 1;
 buffer[376] = 1;
 buffer[377] = 1;
 buffer[378] = 1;
 buffer[379] = 1;
 buffer[380] = 1;
 buffer[381] = 1;
 buffer[382] = 1;
 buffer[383] = 1;
 buffer[384] = 1;
 buffer[385] = 1;
 buffer[386] = 1;
 buffer[387] = 1;
 buffer[388] = 1;
 buffer[389] = 1;
 buffer[390] = 1;
 buffer[391] = 1;
 buffer[392] = 1;
 buffer[393] = 1;
 buffer[394] = 1;
 buffer[395] = 1;
 buffer[396] = 1;
 buffer[397] = 1;
 buffer[398] = 1;
 buffer[399] = 1;
 buffer[400] = 1;
 buffer[401] = 1;
 buffer[402] = 1;
 buffer[403] = 1;
 buffer[404] = 1;
 buffer[405] = 1;
 buffer[406] = 1;
 buffer[407] = 1;
 buffer[408] = 1;
 buffer[409] = 1;
 buffer[410] = 1;
 buffer[411] = 1;
 buffer[412] = 1;
 buffer[413] = 1;
 buffer[414] = 1;
 buffer[415] = 1;
 buffer[416] = 1;
 buffer[417] = 1;
 buffer[418] = 1;
 buffer[419] = 1;
 buffer[420] = 1;
 buffer[421] = 1;
 buffer[422] = 1;
 buffer[423] = 1;
 buffer[424] = 1;
 buffer[425] = 1;
 buffer[426] = 1;
 buffer[427] = 1;
 buffer[428] = 1;
 buffer[429] = 1;
 buffer[430] = 1;
 buffer[431] = 1;
 buffer[432] = 1;
 buffer[433] = 1;
 buffer[434] = 1;
 buffer[435] = 1;
 buffer[436] = 1;
 buffer[437] = 1;
 buffer[438] = 1;
 buffer[439] = 1;
 buffer[440] = 1;
 buffer[441] = 1;
 buffer[442] = 1;
 buffer[443] = 1;
 buffer[444] = 1;
 buffer[445] = 1;
 buffer[446] = 1;
 buffer[447] = 1;
 buffer[448] = 1;
 buffer[449] = 1;
 buffer[450] = 1;
 buffer[451] = 1;
 buffer[452] = 1;
 buffer[453] = 1;
 buffer[454] = 1;
 buffer[455] = 1;
 buffer[456] = 1;
 buffer[457] = 1;
 buffer[458] = 1;
 buffer[459] = 1;
 buffer[460] = 1;
 buffer[461] = 1;
 buffer[462] = 1;
 buffer[463] = 1;
 buffer[464] = 1;
 buffer[465] = 1;
 buffer[466] = 1;
 buffer[467] = 1;
 buffer[468] = 1;
 buffer[469] = 1;
 buffer[470] = 1;
 buffer[471] = 1;
 buffer[472] = 1;
 buffer[473] = 1;
 buffer[474] = 1;
 buffer[475] = 1;
 buffer[476] = 1;
 buffer[477] = 1;
 buffer[478] = 1;
 buffer[479] = 1;
 buffer[480] = 1;
 buffer[481] = 1;
 buffer[482] = 1;
 buffer[483] = 1;
 buffer[484] = 1;
 buffer[485] = 1;
 buffer[486] = 1;
 buffer[487] = 1;
 buffer[488] = 1;
 buffer[489] = 1;
 buffer[490] = 1;
 buffer[491] = 1;
 buffer[492] = 1;
 buffer[493] = 1;
 buffer[494] = 1;
 buffer[495] = 1;
 buffer[496] = 1;
 buffer[497] = 1;
 buffer[498] = 1;
 buffer[499] = 1;
 buffer[500] = 1;
 buffer[501] = 1;
 buffer[502] = 1;
 buffer[503] = 1;
 buffer[504] = 1;
 buffer[505] = 1;
 buffer[506] = 1;
 buffer[507] = 1;
 buffer[508] = 1;
 buffer[509] = 1;
 buffer[510] = 1;
 buffer[511] = 1;
end

endmodule

module M_apu_mem_frequencytable(
input                  [6:0] in_frequencytable_addr,
output reg  [15:0] out_frequencytable_rdata,
input                                   clock
);
reg  [15:0] buffer[127:0];
always @(posedge clock) begin
   out_frequencytable_rdata <= buffer[in_frequencytable_addr];
end
initial begin
 buffer[0] = 0;
 buffer[1] = 47778;
 buffer[2] = 45097;
 buffer[3] = 42566;
 buffer[4] = 40177;
 buffer[5] = 37922;
 buffer[6] = 35793;
 buffer[7] = 33784;
 buffer[8] = 31888;
 buffer[9] = 30098;
 buffer[10] = 28409;
 buffer[11] = 26815;
 buffer[12] = 25310;
 buffer[13] = 23889;
 buffer[14] = 22548;
 buffer[15] = 21283;
 buffer[16] = 20088;
 buffer[17] = 18961;
 buffer[18] = 17897;
 buffer[19] = 16892;
 buffer[20] = 15944;
 buffer[21] = 15049;
 buffer[22] = 14205;
 buffer[23] = 13407;
 buffer[24] = 12655;
 buffer[25] = 11945;
 buffer[26] = 11274;
 buffer[27] = 10641;
 buffer[28] = 10044;
 buffer[29] = 9480;
 buffer[30] = 8948;
 buffer[31] = 8446;
 buffer[32] = 7972;
 buffer[33] = 7525;
 buffer[34] = 7102;
 buffer[35] = 6704;
 buffer[36] = 6327;
 buffer[37] = 5972;
 buffer[38] = 5637;
 buffer[39] = 5321;
 buffer[40] = 5022;
 buffer[41] = 4740;
 buffer[42] = 4474;
 buffer[43] = 4223;
 buffer[44] = 3986;
 buffer[45] = 3762;
 buffer[46] = 3551;
 buffer[47] = 3352;
 buffer[48] = 3164;
 buffer[49] = 2896;
 buffer[50] = 2819;
 buffer[51] = 2660;
 buffer[52] = 2511;
 buffer[53] = 2370;
 buffer[54] = 2237;
 buffer[55] = 2112;
 buffer[56] = 1993;
 buffer[57] = 1881;
 buffer[58] = 1776;
 buffer[59] = 1676;
 buffer[60] = 1582;
 buffer[61] = 1493;
 buffer[62] = 1409;
 buffer[63] = 1330;
 buffer[64] = 1024;
 buffer[65] = 1024;
 buffer[66] = 1024;
 buffer[67] = 1024;
 buffer[68] = 1024;
 buffer[69] = 1024;
 buffer[70] = 1024;
 buffer[71] = 1024;
 buffer[72] = 1024;
 buffer[73] = 1024;
 buffer[74] = 1024;
 buffer[75] = 1024;
 buffer[76] = 1024;
 buffer[77] = 1024;
 buffer[78] = 1024;
 buffer[79] = 1024;
 buffer[80] = 1024;
 buffer[81] = 1024;
 buffer[82] = 1024;
 buffer[83] = 1024;
 buffer[84] = 1024;
 buffer[85] = 1024;
 buffer[86] = 1024;
 buffer[87] = 1024;
 buffer[88] = 1024;
 buffer[89] = 1024;
 buffer[90] = 1024;
 buffer[91] = 1024;
 buffer[92] = 1024;
 buffer[93] = 1024;
 buffer[94] = 1024;
 buffer[95] = 1024;
 buffer[96] = 1024;
 buffer[97] = 1024;
 buffer[98] = 1024;
 buffer[99] = 1024;
 buffer[100] = 1024;
 buffer[101] = 1024;
 buffer[102] = 1024;
 buffer[103] = 1024;
 buffer[104] = 1024;
 buffer[105] = 1024;
 buffer[106] = 1024;
 buffer[107] = 1024;
 buffer[108] = 1024;
 buffer[109] = 1024;
 buffer[110] = 1024;
 buffer[111] = 1024;
 buffer[112] = 1024;
 buffer[113] = 1024;
 buffer[114] = 1024;
 buffer[115] = 1024;
 buffer[116] = 1024;
 buffer[117] = 1024;
 buffer[118] = 1024;
 buffer[119] = 1024;
 buffer[120] = 1024;
 buffer[121] = 1024;
 buffer[122] = 1024;
 buffer[123] = 1024;
 buffer[124] = 1024;
 buffer[125] = 1024;
 buffer[126] = 1024;
 buffer[127] = 1024;
end

endmodule

module M_apu (
in_waveform,
in_note,
in_duration,
in_apu_write,
in_staticGenerator,
out_audio_active,
out_audio_output,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [3:0] in_waveform;
input  [6:0] in_note;
input  [15:0] in_duration;
input  [0:0] in_apu_write;
input  [15:0] in_staticGenerator;
output  [0:0] out_audio_active;
output  [3:0] out_audio_output;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [3:0] _w_mem_waveformtable_rdata;
wire  [15:0] _w_mem_frequencytable_rdata;

reg  [8:0] _d_waveformtable_addr;
reg  [8:0] _q_waveformtable_addr;
reg  [6:0] _d_frequencytable_addr;
reg  [6:0] _q_frequencytable_addr;
reg  [3:0] _d_selected_waveform;
reg  [3:0] _q_selected_waveform;
reg  [6:0] _d_selected_note;
reg  [6:0] _q_selected_note;
reg  [15:0] _d_selected_duration;
reg  [15:0] _q_selected_duration;
reg  [4:0] _d_point;
reg  [4:0] _q_point;
reg  [15:0] _d_counter50mhz;
reg  [15:0] _q_counter50mhz;
reg  [15:0] _d_counter1khz;
reg  [15:0] _q_counter1khz;
reg  [0:0] _d_audio_active,_q_audio_active;
reg  [3:0] _d_audio_output,_q_audio_output;
reg  [1:0] _d_index,_q_index;
assign out_audio_active = _d_audio_active;
assign out_audio_output = _d_audio_output;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_waveformtable_addr <= 0;
_q_frequencytable_addr <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_waveformtable_addr <= _d_waveformtable_addr;
_q_frequencytable_addr <= _d_frequencytable_addr;
_q_selected_waveform <= _d_selected_waveform;
_q_selected_note <= _d_selected_note;
_q_selected_duration <= _d_selected_duration;
_q_point <= _d_point;
_q_counter50mhz <= _d_counter50mhz;
_q_counter1khz <= _d_counter1khz;
_q_audio_active <= _d_audio_active;
_q_audio_output <= _d_audio_output;
_q_index <= _d_index;
  end
end


M_apu_mem_waveformtable __mem__waveformtable(
.clock(clock),
.in_waveformtable_addr(_d_waveformtable_addr),
.out_waveformtable_rdata(_w_mem_waveformtable_rdata)
);
M_apu_mem_frequencytable __mem__frequencytable(
.clock(clock),
.in_frequencytable_addr(_d_frequencytable_addr),
.out_frequencytable_rdata(_w_mem_frequencytable_rdata)
);


always @* begin
_d_waveformtable_addr = _q_waveformtable_addr;
_d_frequencytable_addr = _q_frequencytable_addr;
_d_selected_waveform = _q_selected_waveform;
_d_selected_note = _q_selected_note;
_d_selected_duration = _q_selected_duration;
_d_point = _q_point;
_d_counter50mhz = _q_counter50mhz;
_d_counter1khz = _q_counter1khz;
_d_audio_active = _q_audio_active;
_d_audio_output = _q_audio_output;
_d_index = _q_index;
// _always_pre
_d_waveformtable_addr = _q_selected_waveform*32+_q_point;
_d_frequencytable_addr = _q_selected_note;
_d_audio_active = (_q_selected_duration>0);
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_waveformtable_addr = 0;
_d_frequencytable_addr = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_apu_write) begin
// __block_5
// __block_7
_d_selected_waveform = in_waveform;
_d_selected_note = in_note;
_d_selected_duration = in_duration;
_d_point = 0;
_d_counter50mhz = 0;
_d_counter1khz = 50000;
// __block_8
end else begin
// __block_6
// __block_9
if (_q_selected_duration!=0) begin
// __block_10
// __block_12
if (_q_counter50mhz==0) begin
// __block_13
// __block_15
_d_audio_output = (_q_selected_waveform==4)?in_staticGenerator:_w_mem_waveformtable_rdata;
// __block_16
end else begin
// __block_14
end
// __block_17
_d_counter50mhz = (_q_counter50mhz!=0)?_q_counter50mhz-1:_w_mem_frequencytable_rdata;
_d_point = (_d_counter50mhz!=0)?_q_point:_q_point+1;
_d_counter1khz = (_q_counter1khz!=0)?_q_counter1khz-1:50000;
_d_selected_duration = (_d_counter1khz!=0)?_q_selected_duration:_q_selected_duration-1;
// __block_18
end else begin
// __block_11
end
// __block_19
// __block_20
end
// __block_21
// __block_22
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of apu
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_memmap_io_mem_bitmap(
input      [18:0]                in_bitmap_addr0,
output reg  [6:0]     out_bitmap_rdata0,
output reg  [6:0]     out_bitmap_rdata1,
input      [0:0]             in_bitmap_wenable1,
input      [6:0]                 in_bitmap_wdata1,
input      [18:0]                in_bitmap_addr1,
input      clock0,
input      clock1
);
reg  [6:0] buffer[307199:0];
always @(posedge clock0) begin
  out_bitmap_rdata0 <= buffer[in_bitmap_addr0];
end
always @(posedge clock1) begin
  if (in_bitmap_wenable1) begin
    buffer[in_bitmap_addr1] <= in_bitmap_wdata1;
  end
end

endmodule

module M_memmap_io_mem_sdbuffer(
input      [8:0]                in_sdbuffer_addr0,
output reg  [7:0]     out_sdbuffer_rdata0,
output reg  [7:0]     out_sdbuffer_rdata1,
input      [0:0]             in_sdbuffer_wenable1,
input      [7:0]                 in_sdbuffer_wdata1,
input      [8:0]                in_sdbuffer_addr1,
input      clock0,
input      clock1
);
reg  [7:0] buffer[511:0];
always @(posedge clock0) begin
  out_sdbuffer_rdata0 <= buffer[in_sdbuffer_addr0];
end
always @(posedge clock1) begin
  if (in_sdbuffer_wenable1) begin
    buffer[in_sdbuffer_addr1] <= in_sdbuffer_wdata1;
  end
end

endmodule

module M_memmap_io_mem_uartInBuffer(
input      [11:0]                in_uartInBuffer_addr0,
output reg  [7:0]     out_uartInBuffer_rdata0,
output reg  [7:0]     out_uartInBuffer_rdata1,
input      [0:0]             in_uartInBuffer_wenable1,
input      [7:0]                 in_uartInBuffer_wdata1,
input      [11:0]                in_uartInBuffer_addr1,
input      clock0,
input      clock1
);
reg  [7:0] buffer[4095:0];
always @(posedge clock0) begin
  out_uartInBuffer_rdata0 <= buffer[in_uartInBuffer_addr0];
end
always @(posedge clock1) begin
  if (in_uartInBuffer_wenable1) begin
    buffer[in_uartInBuffer_addr1] <= in_uartInBuffer_wdata1;
  end
end

endmodule

module M_memmap_io_mem_uartOutBuffer(
input      [7:0]                in_uartOutBuffer_addr0,
output reg  [7:0]     out_uartOutBuffer_rdata0,
output reg  [7:0]     out_uartOutBuffer_rdata1,
input      [0:0]             in_uartOutBuffer_wenable1,
input      [7:0]                 in_uartOutBuffer_wdata1,
input      [7:0]                in_uartOutBuffer_addr1,
input      clock0,
input      clock1
);
reg  [7:0] buffer[255:0];
always @(posedge clock0) begin
  out_uartOutBuffer_rdata0 <= buffer[in_uartOutBuffer_addr0];
end
always @(posedge clock1) begin
  if (in_uartOutBuffer_wenable1) begin
    buffer[in_uartOutBuffer_addr1] <= in_uartOutBuffer_wdata1;
  end
end

endmodule

module M_memmap_io (
in_btns,
in_uart_rx,
in_sd_miso,
in_vblank,
in_pix_active,
in_pix_x,
in_pix_y,
in_video_clock,
in_video_reset,
in_memoryAddress,
in_memoryWrite,
in_memoryRead,
in_writeData,
out_leds,
out_uart_tx,
out_audio_l,
out_audio_r,
out_sd_clk,
out_sd_mosi,
out_sd_csn,
out_video_r,
out_video_g,
out_video_b,
out_readData,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [6:0] in_btns;
input  [0:0] in_uart_rx;
input  [0:0] in_sd_miso;
input  [0:0] in_vblank;
input  [0:0] in_pix_active;
input  [9:0] in_pix_x;
input  [9:0] in_pix_y;
input  [0:0] in_video_clock;
input  [0:0] in_video_reset;
input  [15:0] in_memoryAddress;
input  [0:0] in_memoryWrite;
input  [0:0] in_memoryRead;
input  [15:0] in_writeData;
output  [7:0] out_leds;
output  [0:0] out_uart_tx;
output  [3:0] out_audio_l;
output  [3:0] out_audio_r;
output  [0:0] out_sd_clk;
output  [0:0] out_sd_mosi;
output  [0:0] out_sd_csn;
output  [7:0] out_video_r;
output  [7:0] out_video_g;
output  [7:0] out_video_b;
output  [31:0] out_readData;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [15:0] _w_p1hz_counter1hz;
wire _w_p1hz_done;
wire  [15:0] _w_timer1hz_counter1hz;
wire _w_timer1hz_done;
wire  [15:0] _w_sleepTimer_counter1khz;
wire _w_sleepTimer_done;
wire  [15:0] _w_timer1khz_counter1khz;
wire _w_timer1khz_done;
wire  [15:0] _w_rng_g_noise_out;
wire  [15:0] _w_rng_u_noise_out;
wire _w_rng_done;
wire  [0:0] _w_usend_io_busy;
wire  [0:0] _w_usend_uart_tx;
wire _w_usend_done;
wire  [7:0] _w_urecv_io_data_out;
wire  [0:0] _w_urecv_io_data_out_ready;
wire  [1:0] _w_background_generator_pix_red;
wire  [1:0] _w_background_generator_pix_green;
wire  [1:0] _w_background_generator_pix_blue;
wire _w_background_generator_done;
wire  [1:0] _w_tile_map_pix_red;
wire  [1:0] _w_tile_map_pix_green;
wire  [1:0] _w_tile_map_pix_blue;
wire  [0:0] _w_tile_map_tilemap_display;
wire  [3:0] _w_tile_map_tm_lastaction;
wire  [2:0] _w_tile_map_tm_active;
wire _w_tile_map_done;
wire  [1:0] _w_bitmap_window_pix_red;
wire  [1:0] _w_bitmap_window_pix_green;
wire  [1:0] _w_bitmap_window_pix_blue;
wire  [0:0] _w_bitmap_window_bitmap_display;
wire  [9:0] _w_bitmap_window_x_offset;
wire  [9:0] _w_bitmap_window_y_offset;
wire  [6:0] _w_bitmap_window_bitmap_colour_read;
wire  [18:0] _w_bitmap_window_bitmap_addr0;
wire _w_bitmap_window_done;
wire  [18:0] _w_pixel_writer_bitmap_addr1;
wire  [0:0] _w_pixel_writer_bitmap_wenable1;
wire  [6:0] _w_pixel_writer_bitmap_wdata1;
wire _w_pixel_writer_done;
wire  [1:0] _w_lower_sprites_pix_red;
wire  [1:0] _w_lower_sprites_pix_green;
wire  [1:0] _w_lower_sprites_pix_blue;
wire  [0:0] _w_lower_sprites_sprite_layer_display;
wire  [0:0] _w_lower_sprites_sprite_read_active;
wire  [0:0] _w_lower_sprites_sprite_read_double;
wire  [5:0] _w_lower_sprites_sprite_read_colour;
wire signed [10:0] _w_lower_sprites_sprite_read_x;
wire signed [10:0] _w_lower_sprites_sprite_read_y;
wire  [2:0] _w_lower_sprites_sprite_read_tile;
wire  [15:0] _w_lower_sprites_collision_0;
wire  [15:0] _w_lower_sprites_collision_1;
wire  [15:0] _w_lower_sprites_collision_2;
wire  [15:0] _w_lower_sprites_collision_3;
wire  [15:0] _w_lower_sprites_collision_4;
wire  [15:0] _w_lower_sprites_collision_5;
wire  [15:0] _w_lower_sprites_collision_6;
wire  [15:0] _w_lower_sprites_collision_7;
wire  [15:0] _w_lower_sprites_collision_8;
wire  [15:0] _w_lower_sprites_collision_9;
wire  [15:0] _w_lower_sprites_collision_10;
wire  [15:0] _w_lower_sprites_collision_11;
wire  [15:0] _w_lower_sprites_collision_12;
wire _w_lower_sprites_done;
wire  [1:0] _w_upper_sprites_pix_red;
wire  [1:0] _w_upper_sprites_pix_green;
wire  [1:0] _w_upper_sprites_pix_blue;
wire  [0:0] _w_upper_sprites_sprite_layer_display;
wire  [0:0] _w_upper_sprites_sprite_read_active;
wire  [0:0] _w_upper_sprites_sprite_read_double;
wire  [5:0] _w_upper_sprites_sprite_read_colour;
wire signed [10:0] _w_upper_sprites_sprite_read_x;
wire signed [10:0] _w_upper_sprites_sprite_read_y;
wire  [2:0] _w_upper_sprites_sprite_read_tile;
wire  [15:0] _w_upper_sprites_collision_0;
wire  [15:0] _w_upper_sprites_collision_1;
wire  [15:0] _w_upper_sprites_collision_2;
wire  [15:0] _w_upper_sprites_collision_3;
wire  [15:0] _w_upper_sprites_collision_4;
wire  [15:0] _w_upper_sprites_collision_5;
wire  [15:0] _w_upper_sprites_collision_6;
wire  [15:0] _w_upper_sprites_collision_7;
wire  [15:0] _w_upper_sprites_collision_8;
wire  [15:0] _w_upper_sprites_collision_9;
wire  [15:0] _w_upper_sprites_collision_10;
wire  [15:0] _w_upper_sprites_collision_11;
wire  [15:0] _w_upper_sprites_collision_12;
wire _w_upper_sprites_done;
wire  [1:0] _w_character_map_window_pix_red;
wire  [1:0] _w_character_map_window_pix_green;
wire  [1:0] _w_character_map_window_pix_blue;
wire  [0:0] _w_character_map_window_character_map_display;
wire  [0:0] _w_character_map_window_tpu_active;
wire _w_character_map_window_done;
wire  [1:0] _w_terminal_window_pix_red;
wire  [1:0] _w_terminal_window_pix_green;
wire  [1:0] _w_terminal_window_pix_blue;
wire  [0:0] _w_terminal_window_terminal_display;
wire  [0:0] _w_terminal_window_terminal_active;
wire _w_terminal_window_done;
wire  [7:0] _w_display_pix_red;
wire  [7:0] _w_display_pix_green;
wire  [7:0] _w_display_pix_blue;
wire _w_display_done;
wire  [0:0] _w_apu_processor_L_audio_active;
wire  [3:0] _w_apu_processor_L_audio_output;
wire _w_apu_processor_L_done;
wire  [0:0] _w_apu_processor_R_audio_active;
wire  [3:0] _w_apu_processor_R_audio_output;
wire _w_apu_processor_R_done;
wire signed [10:0] _w_gpu_processor_bitmap_x_write;
wire signed [10:0] _w_gpu_processor_bitmap_y_write;
wire  [6:0] _w_gpu_processor_bitmap_colour_write;
wire  [0:0] _w_gpu_processor_bitmap_write;
wire  [0:0] _w_gpu_processor_gpu_active;
wire  [0:0] _w_gpu_processor_vector_block_active;
wire _w_gpu_processor_done;
wire  [0:0] _w_sd_sd_clk;
wire  [0:0] _w_sd_sd_mosi;
wire  [0:0] _w_sd_sd_csn;
wire  [0:0] _w_sd_io_ready;
wire  [8:0] _w_sd_store_addr1;
wire  [0:0] _w_sd_store_wenable1;
wire  [7:0] _w_sd_store_wdata1;
wire _w_sd_done;
wire  [6:0] _w_mem_bitmap_rdata0;
wire  [7:0] _w_mem_sdbuffer_rdata0;
wire  [7:0] _w_mem_uartInBuffer_rdata0;
wire  [7:0] _w_mem_uartOutBuffer_rdata0;
reg  [6:0] _t_reg_btns;

reg  [7:0] _d_uo_data_in;
reg  [7:0] _q_uo_data_in;
reg  [0:0] _d_uo_data_in_ready;
reg  [0:0] _q_uo_data_in_ready;
reg  [8:0] _d_sdbuffer_addr0;
reg  [8:0] _q_sdbuffer_addr0;
reg  [31:0] _d_sdcio_addr_sector;
reg  [31:0] _q_sdcio_addr_sector;
reg  [0:0] _d_sdcio_read_sector;
reg  [0:0] _q_sdcio_read_sector;
reg  [11:0] _d_uartInBuffer_addr0;
reg  [11:0] _q_uartInBuffer_addr0;
reg  [0:0] _d_uartInBuffer_wenable1;
reg  [0:0] _q_uartInBuffer_wenable1;
reg  [7:0] _d_uartInBuffer_wdata1;
reg  [7:0] _q_uartInBuffer_wdata1;
reg  [11:0] _d_uartInBuffer_addr1;
reg  [11:0] _q_uartInBuffer_addr1;
reg  [12:0] _d_uartInBufferNext;
reg  [12:0] _q_uartInBufferNext;
reg  [12:0] _d_uartInBufferTop;
reg  [12:0] _q_uartInBufferTop;
reg  [7:0] _d_uartOutBuffer_addr0;
reg  [7:0] _q_uartOutBuffer_addr0;
reg  [0:0] _d_uartOutBuffer_wenable1;
reg  [0:0] _q_uartOutBuffer_wenable1;
reg  [7:0] _d_uartOutBuffer_wdata1;
reg  [7:0] _q_uartOutBuffer_wdata1;
reg  [7:0] _d_uartOutBuffer_addr1;
reg  [7:0] _q_uartOutBuffer_addr1;
reg  [7:0] _d_uartOutBufferNext;
reg  [7:0] _q_uartOutBufferNext;
reg  [7:0] _d_uartOutBufferTop;
reg  [7:0] _q_uartOutBufferTop;
reg  [7:0] _d_newuartOutBufferTop;
reg  [7:0] _q_newuartOutBufferTop;
reg  [0:0] _d_LATCHmemoryRead;
reg  [0:0] _q_LATCHmemoryRead;
reg  [0:0] _d_LATCHmemoryWrite;
reg  [0:0] _q_LATCHmemoryWrite;
reg  [6:0] _d_delayed_5104_4;
reg  [6:0] _q_delayed_5104_4;
reg  [7:0] _d_leds,_q_leds;
reg  [31:0] _d_readData,_q_readData;
reg  [0:0] _d_p1hz_resetCounter,_q_p1hz_resetCounter;
reg  [0:0] _d_timer1hz_resetCounter,_q_timer1hz_resetCounter;
reg  [15:0] _d_sleepTimer_resetCount,_q_sleepTimer_resetCount;
reg  [0:0] _d_sleepTimer_resetCounter,_q_sleepTimer_resetCounter;
reg  [15:0] _d_timer1khz_resetCount,_q_timer1khz_resetCount;
reg  [0:0] _d_timer1khz_resetCounter,_q_timer1khz_resetCounter;
reg  [0:0] _d_rng_resetRandom,_q_rng_resetRandom;
reg  [5:0] _d_background_generator_backgroundcolour,_q_background_generator_backgroundcolour;
reg  [5:0] _d_background_generator_backgroundcolour_alt,_q_background_generator_backgroundcolour_alt;
reg  [3:0] _d_background_generator_backgroundcolour_mode,_q_background_generator_backgroundcolour_mode;
reg  [5:0] _d_tile_map_tm_x,_q_tile_map_tm_x;
reg  [5:0] _d_tile_map_tm_y,_q_tile_map_tm_y;
reg  [4:0] _d_tile_map_tm_character,_q_tile_map_tm_character;
reg  [5:0] _d_tile_map_tm_foreground,_q_tile_map_tm_foreground;
reg  [6:0] _d_tile_map_tm_background,_q_tile_map_tm_background;
reg  [0:0] _d_tile_map_tm_write,_q_tile_map_tm_write;
reg  [4:0] _d_tile_map_tile_writer_tile,_q_tile_map_tile_writer_tile;
reg  [3:0] _d_tile_map_tile_writer_line,_q_tile_map_tile_writer_line;
reg  [15:0] _d_tile_map_tile_writer_bitmap,_q_tile_map_tile_writer_bitmap;
reg  [3:0] _d_tile_map_tm_scrollwrap,_q_tile_map_tm_scrollwrap;
reg  [2:0] _d_bitmap_window_bitmap_write_offset,_q_bitmap_window_bitmap_write_offset;
reg signed [15:0] _d_bitmap_window_bitmap_x_read,_q_bitmap_window_bitmap_x_read;
reg signed [15:0] _d_bitmap_window_bitmap_y_read,_q_bitmap_window_bitmap_y_read;
reg  [3:0] _d_lower_sprites_sprite_set_number,_q_lower_sprites_sprite_set_number;
reg  [0:0] _d_lower_sprites_sprite_set_active,_q_lower_sprites_sprite_set_active;
reg  [0:0] _d_lower_sprites_sprite_set_double,_q_lower_sprites_sprite_set_double;
reg  [5:0] _d_lower_sprites_sprite_set_colour,_q_lower_sprites_sprite_set_colour;
reg signed [10:0] _d_lower_sprites_sprite_set_x,_q_lower_sprites_sprite_set_x;
reg signed [10:0] _d_lower_sprites_sprite_set_y,_q_lower_sprites_sprite_set_y;
reg  [2:0] _d_lower_sprites_sprite_set_tile,_q_lower_sprites_sprite_set_tile;
reg  [3:0] _d_lower_sprites_sprite_layer_write,_q_lower_sprites_sprite_layer_write;
reg  [15:0] _d_lower_sprites_sprite_update,_q_lower_sprites_sprite_update;
reg  [3:0] _d_lower_sprites_sprite_writer_sprite,_q_lower_sprites_sprite_writer_sprite;
reg  [6:0] _d_lower_sprites_sprite_writer_line,_q_lower_sprites_sprite_writer_line;
reg  [15:0] _d_lower_sprites_sprite_writer_bitmap,_q_lower_sprites_sprite_writer_bitmap;
reg  [0:0] _d_lower_sprites_sprite_writer_active,_q_lower_sprites_sprite_writer_active;
reg  [3:0] _d_upper_sprites_sprite_set_number,_q_upper_sprites_sprite_set_number;
reg  [0:0] _d_upper_sprites_sprite_set_active,_q_upper_sprites_sprite_set_active;
reg  [0:0] _d_upper_sprites_sprite_set_double,_q_upper_sprites_sprite_set_double;
reg  [5:0] _d_upper_sprites_sprite_set_colour,_q_upper_sprites_sprite_set_colour;
reg signed [10:0] _d_upper_sprites_sprite_set_x,_q_upper_sprites_sprite_set_x;
reg signed [10:0] _d_upper_sprites_sprite_set_y,_q_upper_sprites_sprite_set_y;
reg  [2:0] _d_upper_sprites_sprite_set_tile,_q_upper_sprites_sprite_set_tile;
reg  [3:0] _d_upper_sprites_sprite_layer_write,_q_upper_sprites_sprite_layer_write;
reg  [15:0] _d_upper_sprites_sprite_update,_q_upper_sprites_sprite_update;
reg  [3:0] _d_upper_sprites_sprite_writer_sprite,_q_upper_sprites_sprite_writer_sprite;
reg  [6:0] _d_upper_sprites_sprite_writer_line,_q_upper_sprites_sprite_writer_line;
reg  [15:0] _d_upper_sprites_sprite_writer_bitmap,_q_upper_sprites_sprite_writer_bitmap;
reg  [0:0] _d_upper_sprites_sprite_writer_active,_q_upper_sprites_sprite_writer_active;
reg  [6:0] _d_character_map_window_tpu_x,_q_character_map_window_tpu_x;
reg  [4:0] _d_character_map_window_tpu_y,_q_character_map_window_tpu_y;
reg  [7:0] _d_character_map_window_tpu_character,_q_character_map_window_tpu_character;
reg  [5:0] _d_character_map_window_tpu_foreground,_q_character_map_window_tpu_foreground;
reg  [6:0] _d_character_map_window_tpu_background,_q_character_map_window_tpu_background;
reg  [2:0] _d_character_map_window_tpu_write,_q_character_map_window_tpu_write;
reg  [7:0] _d_terminal_window_terminal_character,_q_terminal_window_terminal_character;
reg  [0:0] _d_terminal_window_terminal_write,_q_terminal_window_terminal_write;
reg  [0:0] _d_terminal_window_showterminal,_q_terminal_window_showterminal;
reg  [0:0] _d_terminal_window_showcursor,_q_terminal_window_showcursor;
reg  [3:0] _d_apu_processor_L_waveform,_q_apu_processor_L_waveform;
reg  [6:0] _d_apu_processor_L_note,_q_apu_processor_L_note;
reg  [15:0] _d_apu_processor_L_duration,_q_apu_processor_L_duration;
reg  [0:0] _d_apu_processor_L_apu_write,_q_apu_processor_L_apu_write;
reg  [3:0] _d_apu_processor_R_waveform,_q_apu_processor_R_waveform;
reg  [6:0] _d_apu_processor_R_note,_q_apu_processor_R_note;
reg  [15:0] _d_apu_processor_R_duration,_q_apu_processor_R_duration;
reg  [0:0] _d_apu_processor_R_apu_write,_q_apu_processor_R_apu_write;
reg signed [10:0] _d_gpu_processor_gpu_x,_q_gpu_processor_gpu_x;
reg signed [10:0] _d_gpu_processor_gpu_y,_q_gpu_processor_gpu_y;
reg  [7:0] _d_gpu_processor_gpu_colour,_q_gpu_processor_gpu_colour;
reg signed [10:0] _d_gpu_processor_gpu_param0,_q_gpu_processor_gpu_param0;
reg signed [10:0] _d_gpu_processor_gpu_param1,_q_gpu_processor_gpu_param1;
reg signed [10:0] _d_gpu_processor_gpu_param2,_q_gpu_processor_gpu_param2;
reg signed [10:0] _d_gpu_processor_gpu_param3,_q_gpu_processor_gpu_param3;
reg  [3:0] _d_gpu_processor_gpu_write,_q_gpu_processor_gpu_write;
reg  [4:0] _d_gpu_processor_blit1_writer_tile,_q_gpu_processor_blit1_writer_tile;
reg  [3:0] _d_gpu_processor_blit1_writer_line,_q_gpu_processor_blit1_writer_line;
reg  [15:0] _d_gpu_processor_blit1_writer_bitmap,_q_gpu_processor_blit1_writer_bitmap;
reg  [4:0] _d_gpu_processor_vector_block_number,_q_gpu_processor_vector_block_number;
reg  [6:0] _d_gpu_processor_vector_block_colour,_q_gpu_processor_vector_block_colour;
reg signed [10:0] _d_gpu_processor_vector_block_xc,_q_gpu_processor_vector_block_xc;
reg signed [10:0] _d_gpu_processor_vector_block_yc,_q_gpu_processor_vector_block_yc;
reg  [0:0] _d_gpu_processor_draw_vector,_q_gpu_processor_draw_vector;
reg  [4:0] _d_gpu_processor_vertices_writer_block,_q_gpu_processor_vertices_writer_block;
reg  [5:0] _d_gpu_processor_vertices_writer_vertex,_q_gpu_processor_vertices_writer_vertex;
reg signed [5:0] _d_gpu_processor_vertices_writer_xdelta,_q_gpu_processor_vertices_writer_xdelta;
reg signed [5:0] _d_gpu_processor_vertices_writer_ydelta,_q_gpu_processor_vertices_writer_ydelta;
reg  [0:0] _d_gpu_processor_vertices_writer_active,_q_gpu_processor_vertices_writer_active;
reg  [1:0] _d_index,_q_index;
reg  _p1hz_run;
reg  _timer1hz_run;
reg  _sleepTimer_run;
reg  _timer1khz_run;
reg  _rng_run;
reg  _usend_run;
reg  _background_generator_run;
reg  _tile_map_run;
reg  _bitmap_window_run;
reg  _pixel_writer_run;
reg  _lower_sprites_run;
reg  _upper_sprites_run;
reg  _character_map_window_run;
reg  _terminal_window_run;
reg  _display_run;
reg  _apu_processor_L_run;
reg  _apu_processor_R_run;
reg  _gpu_processor_run;
reg  _sd_run;
assign out_leds = _q_leds;
assign out_uart_tx = _w_usend_uart_tx;
assign out_audio_l = _w_apu_processor_L_audio_output;
assign out_audio_r = _w_apu_processor_R_audio_output;
assign out_sd_clk = _w_sd_sd_clk;
assign out_sd_mosi = _w_sd_sd_mosi;
assign out_sd_csn = _w_sd_sd_csn;
assign out_video_r = _w_display_pix_red;
assign out_video_g = _w_display_pix_green;
assign out_video_b = _w_display_pix_blue;
assign out_readData = _d_readData;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_uo_data_in <= 0;
_q_uo_data_in_ready <= 0;
_q_sdbuffer_addr0 <= 0;
_q_sdcio_addr_sector <= 0;
_q_sdcio_read_sector <= 0;
_q_uartInBuffer_addr0 <= 0;
_q_uartInBuffer_wenable1 <= 0;
_q_uartInBuffer_wdata1 <= 0;
_q_uartInBuffer_addr1 <= 0;
_q_uartInBufferNext <= 0;
_q_uartInBufferTop <= 0;
_q_uartOutBuffer_addr0 <= 0;
_q_uartOutBuffer_wenable1 <= 0;
_q_uartOutBuffer_wdata1 <= 0;
_q_uartOutBuffer_addr1 <= 0;
_q_uartOutBufferNext <= 0;
_q_uartOutBufferTop <= 0;
_q_newuartOutBufferTop <= 0;
_q_delayed_5104_4 <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_uo_data_in <= _d_uo_data_in;
_q_uo_data_in_ready <= _d_uo_data_in_ready;
_q_sdbuffer_addr0 <= _d_sdbuffer_addr0;
_q_sdcio_addr_sector <= _d_sdcio_addr_sector;
_q_sdcio_read_sector <= _d_sdcio_read_sector;
_q_uartInBuffer_addr0 <= _d_uartInBuffer_addr0;
_q_uartInBuffer_wenable1 <= _d_uartInBuffer_wenable1;
_q_uartInBuffer_wdata1 <= _d_uartInBuffer_wdata1;
_q_uartInBuffer_addr1 <= _d_uartInBuffer_addr1;
_q_uartInBufferNext <= _d_uartInBufferNext;
_q_uartInBufferTop <= _d_uartInBufferTop;
_q_uartOutBuffer_addr0 <= _d_uartOutBuffer_addr0;
_q_uartOutBuffer_wenable1 <= _d_uartOutBuffer_wenable1;
_q_uartOutBuffer_wdata1 <= _d_uartOutBuffer_wdata1;
_q_uartOutBuffer_addr1 <= _d_uartOutBuffer_addr1;
_q_uartOutBufferNext <= _d_uartOutBufferNext;
_q_uartOutBufferTop <= _d_uartOutBufferTop;
_q_newuartOutBufferTop <= _d_newuartOutBufferTop;
_q_LATCHmemoryRead <= _d_LATCHmemoryRead;
_q_LATCHmemoryWrite <= _d_LATCHmemoryWrite;
_q_delayed_5104_4 <= _d_delayed_5104_4;
_q_leds <= _d_leds;
_q_readData <= _d_readData;
_q_index <= _d_index;
  end
_q_p1hz_resetCounter <= _d_p1hz_resetCounter;
_q_timer1hz_resetCounter <= _d_timer1hz_resetCounter;
_q_sleepTimer_resetCount <= _d_sleepTimer_resetCount;
_q_sleepTimer_resetCounter <= _d_sleepTimer_resetCounter;
_q_timer1khz_resetCount <= _d_timer1khz_resetCount;
_q_timer1khz_resetCounter <= _d_timer1khz_resetCounter;
_q_rng_resetRandom <= _d_rng_resetRandom;
_q_background_generator_backgroundcolour <= _d_background_generator_backgroundcolour;
_q_background_generator_backgroundcolour_alt <= _d_background_generator_backgroundcolour_alt;
_q_background_generator_backgroundcolour_mode <= _d_background_generator_backgroundcolour_mode;
_q_tile_map_tm_x <= _d_tile_map_tm_x;
_q_tile_map_tm_y <= _d_tile_map_tm_y;
_q_tile_map_tm_character <= _d_tile_map_tm_character;
_q_tile_map_tm_foreground <= _d_tile_map_tm_foreground;
_q_tile_map_tm_background <= _d_tile_map_tm_background;
_q_tile_map_tm_write <= _d_tile_map_tm_write;
_q_tile_map_tile_writer_tile <= _d_tile_map_tile_writer_tile;
_q_tile_map_tile_writer_line <= _d_tile_map_tile_writer_line;
_q_tile_map_tile_writer_bitmap <= _d_tile_map_tile_writer_bitmap;
_q_tile_map_tm_scrollwrap <= _d_tile_map_tm_scrollwrap;
_q_bitmap_window_bitmap_write_offset <= _d_bitmap_window_bitmap_write_offset;
_q_bitmap_window_bitmap_x_read <= _d_bitmap_window_bitmap_x_read;
_q_bitmap_window_bitmap_y_read <= _d_bitmap_window_bitmap_y_read;
_q_lower_sprites_sprite_set_number <= _d_lower_sprites_sprite_set_number;
_q_lower_sprites_sprite_set_active <= _d_lower_sprites_sprite_set_active;
_q_lower_sprites_sprite_set_double <= _d_lower_sprites_sprite_set_double;
_q_lower_sprites_sprite_set_colour <= _d_lower_sprites_sprite_set_colour;
_q_lower_sprites_sprite_set_x <= _d_lower_sprites_sprite_set_x;
_q_lower_sprites_sprite_set_y <= _d_lower_sprites_sprite_set_y;
_q_lower_sprites_sprite_set_tile <= _d_lower_sprites_sprite_set_tile;
_q_lower_sprites_sprite_layer_write <= _d_lower_sprites_sprite_layer_write;
_q_lower_sprites_sprite_update <= _d_lower_sprites_sprite_update;
_q_lower_sprites_sprite_writer_sprite <= _d_lower_sprites_sprite_writer_sprite;
_q_lower_sprites_sprite_writer_line <= _d_lower_sprites_sprite_writer_line;
_q_lower_sprites_sprite_writer_bitmap <= _d_lower_sprites_sprite_writer_bitmap;
_q_lower_sprites_sprite_writer_active <= _d_lower_sprites_sprite_writer_active;
_q_upper_sprites_sprite_set_number <= _d_upper_sprites_sprite_set_number;
_q_upper_sprites_sprite_set_active <= _d_upper_sprites_sprite_set_active;
_q_upper_sprites_sprite_set_double <= _d_upper_sprites_sprite_set_double;
_q_upper_sprites_sprite_set_colour <= _d_upper_sprites_sprite_set_colour;
_q_upper_sprites_sprite_set_x <= _d_upper_sprites_sprite_set_x;
_q_upper_sprites_sprite_set_y <= _d_upper_sprites_sprite_set_y;
_q_upper_sprites_sprite_set_tile <= _d_upper_sprites_sprite_set_tile;
_q_upper_sprites_sprite_layer_write <= _d_upper_sprites_sprite_layer_write;
_q_upper_sprites_sprite_update <= _d_upper_sprites_sprite_update;
_q_upper_sprites_sprite_writer_sprite <= _d_upper_sprites_sprite_writer_sprite;
_q_upper_sprites_sprite_writer_line <= _d_upper_sprites_sprite_writer_line;
_q_upper_sprites_sprite_writer_bitmap <= _d_upper_sprites_sprite_writer_bitmap;
_q_upper_sprites_sprite_writer_active <= _d_upper_sprites_sprite_writer_active;
_q_character_map_window_tpu_x <= _d_character_map_window_tpu_x;
_q_character_map_window_tpu_y <= _d_character_map_window_tpu_y;
_q_character_map_window_tpu_character <= _d_character_map_window_tpu_character;
_q_character_map_window_tpu_foreground <= _d_character_map_window_tpu_foreground;
_q_character_map_window_tpu_background <= _d_character_map_window_tpu_background;
_q_character_map_window_tpu_write <= _d_character_map_window_tpu_write;
_q_terminal_window_terminal_character <= _d_terminal_window_terminal_character;
_q_terminal_window_terminal_write <= _d_terminal_window_terminal_write;
_q_terminal_window_showterminal <= _d_terminal_window_showterminal;
_q_terminal_window_showcursor <= _d_terminal_window_showcursor;
_q_apu_processor_L_waveform <= _d_apu_processor_L_waveform;
_q_apu_processor_L_note <= _d_apu_processor_L_note;
_q_apu_processor_L_duration <= _d_apu_processor_L_duration;
_q_apu_processor_L_apu_write <= _d_apu_processor_L_apu_write;
_q_apu_processor_R_waveform <= _d_apu_processor_R_waveform;
_q_apu_processor_R_note <= _d_apu_processor_R_note;
_q_apu_processor_R_duration <= _d_apu_processor_R_duration;
_q_apu_processor_R_apu_write <= _d_apu_processor_R_apu_write;
_q_gpu_processor_gpu_x <= _d_gpu_processor_gpu_x;
_q_gpu_processor_gpu_y <= _d_gpu_processor_gpu_y;
_q_gpu_processor_gpu_colour <= _d_gpu_processor_gpu_colour;
_q_gpu_processor_gpu_param0 <= _d_gpu_processor_gpu_param0;
_q_gpu_processor_gpu_param1 <= _d_gpu_processor_gpu_param1;
_q_gpu_processor_gpu_param2 <= _d_gpu_processor_gpu_param2;
_q_gpu_processor_gpu_param3 <= _d_gpu_processor_gpu_param3;
_q_gpu_processor_gpu_write <= _d_gpu_processor_gpu_write;
_q_gpu_processor_blit1_writer_tile <= _d_gpu_processor_blit1_writer_tile;
_q_gpu_processor_blit1_writer_line <= _d_gpu_processor_blit1_writer_line;
_q_gpu_processor_blit1_writer_bitmap <= _d_gpu_processor_blit1_writer_bitmap;
_q_gpu_processor_vector_block_number <= _d_gpu_processor_vector_block_number;
_q_gpu_processor_vector_block_colour <= _d_gpu_processor_vector_block_colour;
_q_gpu_processor_vector_block_xc <= _d_gpu_processor_vector_block_xc;
_q_gpu_processor_vector_block_yc <= _d_gpu_processor_vector_block_yc;
_q_gpu_processor_draw_vector <= _d_gpu_processor_draw_vector;
_q_gpu_processor_vertices_writer_block <= _d_gpu_processor_vertices_writer_block;
_q_gpu_processor_vertices_writer_vertex <= _d_gpu_processor_vertices_writer_vertex;
_q_gpu_processor_vertices_writer_xdelta <= _d_gpu_processor_vertices_writer_xdelta;
_q_gpu_processor_vertices_writer_ydelta <= _d_gpu_processor_vertices_writer_ydelta;
_q_gpu_processor_vertices_writer_active <= _d_gpu_processor_vertices_writer_active;
end

M_pulse1hz p1hz (
.in_resetCounter(_d_p1hz_resetCounter),
.out_counter1hz(_w_p1hz_counter1hz),
.out_done(_w_p1hz_done),
.in_run(_p1hz_run),
.reset(reset),
.clock(clock)
);
M_pulse1hz timer1hz (
.in_resetCounter(_d_timer1hz_resetCounter),
.out_counter1hz(_w_timer1hz_counter1hz),
.out_done(_w_timer1hz_done),
.in_run(_timer1hz_run),
.reset(reset),
.clock(clock)
);
M_pulse1khz sleepTimer (
.in_resetCount(_d_sleepTimer_resetCount),
.in_resetCounter(_d_sleepTimer_resetCounter),
.out_counter1khz(_w_sleepTimer_counter1khz),
.out_done(_w_sleepTimer_done),
.in_run(_sleepTimer_run),
.reset(reset),
.clock(clock)
);
M_pulse1khz timer1khz (
.in_resetCount(_d_timer1khz_resetCount),
.in_resetCounter(_d_timer1khz_resetCounter),
.out_counter1khz(_w_timer1khz_counter1khz),
.out_done(_w_timer1khz_done),
.in_run(_timer1khz_run),
.reset(reset),
.clock(clock)
);
M_random rng (
.in_resetRandom(_d_rng_resetRandom),
.out_g_noise_out(_w_rng_g_noise_out),
.out_u_noise_out(_w_rng_u_noise_out),
.out_done(_w_rng_done),
.in_run(_rng_run),
.reset(reset),
.clock(clock)
);
M_uart_sender #(
.IO_DATA_IN_WIDTH(8),
.IO_DATA_IN_INIT(0),
.IO_DATA_IN_SIGNED(0),
.IO_DATA_IN_READY_WIDTH(1),
.IO_DATA_IN_READY_INIT(0),
.IO_DATA_IN_READY_SIGNED(0),
.IO_BUSY_WIDTH(1),
.IO_BUSY_INIT(0),
.IO_BUSY_SIGNED(0)
) usend (
.in_io_data_in(_d_uo_data_in),
.in_io_data_in_ready(_d_uo_data_in_ready),
.out_io_busy(_w_usend_io_busy),
.out_uart_tx(_w_usend_uart_tx),
.out_done(_w_usend_done),
.in_run(_usend_run),
.reset(reset),
.clock(clock)
);
M_uart_receiver #(
.IO_DATA_OUT_WIDTH(8),
.IO_DATA_OUT_INIT(0),
.IO_DATA_OUT_SIGNED(0),
.IO_DATA_OUT_READY_WIDTH(1),
.IO_DATA_OUT_READY_INIT(0),
.IO_DATA_OUT_READY_SIGNED(0)
) urecv (
.in_uart_rx(in_uart_rx),
.out_io_data_out(_w_urecv_io_data_out),
.out_io_data_out_ready(_w_urecv_io_data_out_ready),
.reset(reset),
.clock(clock)
);
M_background background_generator (
.in_pix_x(in_pix_x),
.in_pix_y(in_pix_y),
.in_pix_active(in_pix_active),
.in_pix_vblank(in_vblank),
.in_staticGenerator(_w_rng_g_noise_out),
.in_backgroundcolour(_d_background_generator_backgroundcolour),
.in_backgroundcolour_alt(_d_background_generator_backgroundcolour_alt),
.in_backgroundcolour_mode(_d_background_generator_backgroundcolour_mode),
.out_pix_red(_w_background_generator_pix_red),
.out_pix_green(_w_background_generator_pix_green),
.out_pix_blue(_w_background_generator_pix_blue),
.out_done(_w_background_generator_done),
.in_run(_background_generator_run),
.reset(in_video_reset),
.clock(in_video_clock)
);
M_tilemap tile_map (
.in_pix_x(in_pix_x),
.in_pix_y(in_pix_y),
.in_pix_active(in_pix_active),
.in_pix_vblank(in_vblank),
.in_tm_x(_d_tile_map_tm_x),
.in_tm_y(_d_tile_map_tm_y),
.in_tm_character(_d_tile_map_tm_character),
.in_tm_foreground(_d_tile_map_tm_foreground),
.in_tm_background(_d_tile_map_tm_background),
.in_tm_write(_d_tile_map_tm_write),
.in_tile_writer_tile(_d_tile_map_tile_writer_tile),
.in_tile_writer_line(_d_tile_map_tile_writer_line),
.in_tile_writer_bitmap(_d_tile_map_tile_writer_bitmap),
.in_tm_scrollwrap(_d_tile_map_tm_scrollwrap),
.out_pix_red(_w_tile_map_pix_red),
.out_pix_green(_w_tile_map_pix_green),
.out_pix_blue(_w_tile_map_pix_blue),
.out_tilemap_display(_w_tile_map_tilemap_display),
.out_tm_lastaction(_w_tile_map_tm_lastaction),
.out_tm_active(_w_tile_map_tm_active),
.out_done(_w_tile_map_done),
.in_run(_tile_map_run),
.reset(in_video_reset),
.clock(in_video_clock)
);
M_bitmap #(
.BITMAP_ADDR0_WIDTH(19),
.BITMAP_ADDR0_INIT(0),
.BITMAP_ADDR0_SIGNED(0),
.BITMAP_RDATA0_WIDTH(7),
.BITMAP_RDATA0_INIT(0),
.BITMAP_RDATA0_SIGNED(0)
) bitmap_window (
.in_pix_x(in_pix_x),
.in_pix_y(in_pix_y),
.in_pix_active(in_pix_active),
.in_pix_vblank(in_vblank),
.in_bitmap_write_offset(_d_bitmap_window_bitmap_write_offset),
.in_bitmap_x_read(_d_bitmap_window_bitmap_x_read),
.in_bitmap_y_read(_d_bitmap_window_bitmap_y_read),
.in_bitmap_rdata0(_w_mem_bitmap_rdata0),
.out_pix_red(_w_bitmap_window_pix_red),
.out_pix_green(_w_bitmap_window_pix_green),
.out_pix_blue(_w_bitmap_window_pix_blue),
.out_bitmap_display(_w_bitmap_window_bitmap_display),
.out_x_offset(_w_bitmap_window_x_offset),
.out_y_offset(_w_bitmap_window_y_offset),
.out_bitmap_colour_read(_w_bitmap_window_bitmap_colour_read),
.out_bitmap_addr0(_w_bitmap_window_bitmap_addr0),
.out_done(_w_bitmap_window_done),
.in_run(_bitmap_window_run),
.reset(in_video_reset),
.clock(in_video_clock)
);
M_bitmapwriter #(
.BITMAP_ADDR1_WIDTH(19),
.BITMAP_ADDR1_INIT(0),
.BITMAP_ADDR1_SIGNED(0),
.BITMAP_WENABLE1_WIDTH(1),
.BITMAP_WENABLE1_INIT(0),
.BITMAP_WENABLE1_SIGNED(0),
.BITMAP_WDATA1_WIDTH(7),
.BITMAP_WDATA1_INIT(0),
.BITMAP_WDATA1_SIGNED(0)
) pixel_writer (
.in_bitmap_x_write(_w_gpu_processor_bitmap_x_write),
.in_bitmap_y_write(_w_gpu_processor_bitmap_y_write),
.in_bitmap_colour_write(_w_gpu_processor_bitmap_colour_write),
.in_bitmap_write(_w_gpu_processor_bitmap_write),
.in_x_offset(_w_bitmap_window_x_offset),
.in_y_offset(_w_bitmap_window_y_offset),
.out_bitmap_addr1(_w_pixel_writer_bitmap_addr1),
.out_bitmap_wenable1(_w_pixel_writer_bitmap_wenable1),
.out_bitmap_wdata1(_w_pixel_writer_bitmap_wdata1),
.out_done(_w_pixel_writer_done),
.in_run(_pixel_writer_run),
.reset(reset),
.clock(in_video_clock)
);
M_sprite_layer lower_sprites (
.in_pix_x(in_pix_x),
.in_pix_y(in_pix_y),
.in_pix_active(in_pix_active),
.in_pix_vblank(in_vblank),
.in_sprite_set_number(_d_lower_sprites_sprite_set_number),
.in_sprite_set_active(_d_lower_sprites_sprite_set_active),
.in_sprite_set_double(_d_lower_sprites_sprite_set_double),
.in_sprite_set_colour(_d_lower_sprites_sprite_set_colour),
.in_sprite_set_x(_d_lower_sprites_sprite_set_x),
.in_sprite_set_y(_d_lower_sprites_sprite_set_y),
.in_sprite_set_tile(_d_lower_sprites_sprite_set_tile),
.in_sprite_layer_write(_d_lower_sprites_sprite_layer_write),
.in_sprite_update(_d_lower_sprites_sprite_update),
.in_collision_layer_1(_w_bitmap_window_bitmap_display),
.in_collision_layer_2(_w_tile_map_tilemap_display),
.in_collision_layer_3(_w_upper_sprites_sprite_layer_display),
.in_sprite_writer_sprite(_d_lower_sprites_sprite_writer_sprite),
.in_sprite_writer_line(_d_lower_sprites_sprite_writer_line),
.in_sprite_writer_bitmap(_d_lower_sprites_sprite_writer_bitmap),
.in_sprite_writer_active(_d_lower_sprites_sprite_writer_active),
.out_pix_red(_w_lower_sprites_pix_red),
.out_pix_green(_w_lower_sprites_pix_green),
.out_pix_blue(_w_lower_sprites_pix_blue),
.out_sprite_layer_display(_w_lower_sprites_sprite_layer_display),
.out_sprite_read_active(_w_lower_sprites_sprite_read_active),
.out_sprite_read_double(_w_lower_sprites_sprite_read_double),
.out_sprite_read_colour(_w_lower_sprites_sprite_read_colour),
.out_sprite_read_x(_w_lower_sprites_sprite_read_x),
.out_sprite_read_y(_w_lower_sprites_sprite_read_y),
.out_sprite_read_tile(_w_lower_sprites_sprite_read_tile),
.out_collision_0(_w_lower_sprites_collision_0),
.out_collision_1(_w_lower_sprites_collision_1),
.out_collision_2(_w_lower_sprites_collision_2),
.out_collision_3(_w_lower_sprites_collision_3),
.out_collision_4(_w_lower_sprites_collision_4),
.out_collision_5(_w_lower_sprites_collision_5),
.out_collision_6(_w_lower_sprites_collision_6),
.out_collision_7(_w_lower_sprites_collision_7),
.out_collision_8(_w_lower_sprites_collision_8),
.out_collision_9(_w_lower_sprites_collision_9),
.out_collision_10(_w_lower_sprites_collision_10),
.out_collision_11(_w_lower_sprites_collision_11),
.out_collision_12(_w_lower_sprites_collision_12),
.out_done(_w_lower_sprites_done),
.in_run(_lower_sprites_run),
.reset(in_video_reset),
.clock(in_video_clock)
);
M_sprite_layer upper_sprites (
.in_pix_x(in_pix_x),
.in_pix_y(in_pix_y),
.in_pix_active(in_pix_active),
.in_pix_vblank(in_vblank),
.in_sprite_set_number(_d_upper_sprites_sprite_set_number),
.in_sprite_set_active(_d_upper_sprites_sprite_set_active),
.in_sprite_set_double(_d_upper_sprites_sprite_set_double),
.in_sprite_set_colour(_d_upper_sprites_sprite_set_colour),
.in_sprite_set_x(_d_upper_sprites_sprite_set_x),
.in_sprite_set_y(_d_upper_sprites_sprite_set_y),
.in_sprite_set_tile(_d_upper_sprites_sprite_set_tile),
.in_sprite_layer_write(_d_upper_sprites_sprite_layer_write),
.in_sprite_update(_d_upper_sprites_sprite_update),
.in_collision_layer_1(_w_bitmap_window_bitmap_display),
.in_collision_layer_2(_w_tile_map_tilemap_display),
.in_collision_layer_3(_w_lower_sprites_sprite_layer_display),
.in_sprite_writer_sprite(_d_upper_sprites_sprite_writer_sprite),
.in_sprite_writer_line(_d_upper_sprites_sprite_writer_line),
.in_sprite_writer_bitmap(_d_upper_sprites_sprite_writer_bitmap),
.in_sprite_writer_active(_d_upper_sprites_sprite_writer_active),
.out_pix_red(_w_upper_sprites_pix_red),
.out_pix_green(_w_upper_sprites_pix_green),
.out_pix_blue(_w_upper_sprites_pix_blue),
.out_sprite_layer_display(_w_upper_sprites_sprite_layer_display),
.out_sprite_read_active(_w_upper_sprites_sprite_read_active),
.out_sprite_read_double(_w_upper_sprites_sprite_read_double),
.out_sprite_read_colour(_w_upper_sprites_sprite_read_colour),
.out_sprite_read_x(_w_upper_sprites_sprite_read_x),
.out_sprite_read_y(_w_upper_sprites_sprite_read_y),
.out_sprite_read_tile(_w_upper_sprites_sprite_read_tile),
.out_collision_0(_w_upper_sprites_collision_0),
.out_collision_1(_w_upper_sprites_collision_1),
.out_collision_2(_w_upper_sprites_collision_2),
.out_collision_3(_w_upper_sprites_collision_3),
.out_collision_4(_w_upper_sprites_collision_4),
.out_collision_5(_w_upper_sprites_collision_5),
.out_collision_6(_w_upper_sprites_collision_6),
.out_collision_7(_w_upper_sprites_collision_7),
.out_collision_8(_w_upper_sprites_collision_8),
.out_collision_9(_w_upper_sprites_collision_9),
.out_collision_10(_w_upper_sprites_collision_10),
.out_collision_11(_w_upper_sprites_collision_11),
.out_collision_12(_w_upper_sprites_collision_12),
.out_done(_w_upper_sprites_done),
.in_run(_upper_sprites_run),
.reset(in_video_reset),
.clock(in_video_clock)
);
M_character_map character_map_window (
.in_pix_x(in_pix_x),
.in_pix_y(in_pix_y),
.in_pix_active(in_pix_active),
.in_pix_vblank(in_vblank),
.in_tpu_x(_d_character_map_window_tpu_x),
.in_tpu_y(_d_character_map_window_tpu_y),
.in_tpu_character(_d_character_map_window_tpu_character),
.in_tpu_foreground(_d_character_map_window_tpu_foreground),
.in_tpu_background(_d_character_map_window_tpu_background),
.in_tpu_write(_d_character_map_window_tpu_write),
.out_pix_red(_w_character_map_window_pix_red),
.out_pix_green(_w_character_map_window_pix_green),
.out_pix_blue(_w_character_map_window_pix_blue),
.out_character_map_display(_w_character_map_window_character_map_display),
.out_tpu_active(_w_character_map_window_tpu_active),
.out_done(_w_character_map_window_done),
.in_run(_character_map_window_run),
.reset(in_video_reset),
.clock(in_video_clock)
);
M_terminal terminal_window (
.in_pix_x(in_pix_x),
.in_pix_y(in_pix_y),
.in_pix_active(in_pix_active),
.in_pix_vblank(in_vblank),
.in_terminal_character(_d_terminal_window_terminal_character),
.in_terminal_write(_d_terminal_window_terminal_write),
.in_showterminal(_d_terminal_window_showterminal),
.in_showcursor(_d_terminal_window_showcursor),
.in_timer1hz(_w_p1hz_counter1hz),
.out_pix_red(_w_terminal_window_pix_red),
.out_pix_green(_w_terminal_window_pix_green),
.out_pix_blue(_w_terminal_window_pix_blue),
.out_terminal_display(_w_terminal_window_terminal_display),
.out_terminal_active(_w_terminal_window_terminal_active),
.out_done(_w_terminal_window_done),
.in_run(_terminal_window_run),
.reset(in_video_reset),
.clock(in_video_clock)
);
M_multiplex_display display (
.in_pix_x(in_pix_x),
.in_pix_y(in_pix_y),
.in_pix_active(in_pix_active),
.in_pix_vblank(in_vblank),
.in_background_r(_w_background_generator_pix_red),
.in_background_g(_w_background_generator_pix_green),
.in_background_b(_w_background_generator_pix_blue),
.in_tilemap_r(_w_tile_map_pix_red),
.in_tilemap_g(_w_tile_map_pix_green),
.in_tilemap_b(_w_tile_map_pix_blue),
.in_tilemap_display(_w_tile_map_tilemap_display),
.in_lower_sprites_r(_w_lower_sprites_pix_red),
.in_lower_sprites_g(_w_lower_sprites_pix_green),
.in_lower_sprites_b(_w_lower_sprites_pix_blue),
.in_lower_sprites_display(_w_lower_sprites_sprite_layer_display),
.in_bitmap_r(_w_bitmap_window_pix_red),
.in_bitmap_g(_w_bitmap_window_pix_green),
.in_bitmap_b(_w_bitmap_window_pix_blue),
.in_bitmap_display(_w_bitmap_window_bitmap_display),
.in_upper_sprites_r(_w_upper_sprites_pix_red),
.in_upper_sprites_g(_w_upper_sprites_pix_green),
.in_upper_sprites_b(_w_upper_sprites_pix_blue),
.in_upper_sprites_display(_w_upper_sprites_sprite_layer_display),
.in_character_map_r(_w_character_map_window_pix_red),
.in_character_map_g(_w_character_map_window_pix_green),
.in_character_map_b(_w_character_map_window_pix_blue),
.in_character_map_display(_w_character_map_window_character_map_display),
.in_terminal_r(_w_terminal_window_pix_red),
.in_terminal_g(_w_terminal_window_pix_green),
.in_terminal_b(_w_terminal_window_pix_blue),
.in_terminal_display(_w_terminal_window_terminal_display),
.out_pix_red(_w_display_pix_red),
.out_pix_green(_w_display_pix_green),
.out_pix_blue(_w_display_pix_blue),
.out_done(_w_display_done),
.in_run(_display_run),
.reset(in_video_reset),
.clock(in_video_clock)
);
M_apu apu_processor_L (
.in_waveform(_d_apu_processor_L_waveform),
.in_note(_d_apu_processor_L_note),
.in_duration(_d_apu_processor_L_duration),
.in_apu_write(_d_apu_processor_L_apu_write),
.in_staticGenerator(_w_rng_g_noise_out),
.out_audio_active(_w_apu_processor_L_audio_active),
.out_audio_output(_w_apu_processor_L_audio_output),
.out_done(_w_apu_processor_L_done),
.in_run(_apu_processor_L_run),
.reset(reset),
.clock(clock)
);
M_apu apu_processor_R (
.in_waveform(_d_apu_processor_R_waveform),
.in_note(_d_apu_processor_R_note),
.in_duration(_d_apu_processor_R_duration),
.in_apu_write(_d_apu_processor_R_apu_write),
.in_staticGenerator(_w_rng_g_noise_out),
.out_audio_active(_w_apu_processor_R_audio_active),
.out_audio_output(_w_apu_processor_R_audio_output),
.out_done(_w_apu_processor_R_done),
.in_run(_apu_processor_R_run),
.reset(reset),
.clock(clock)
);
M_gpu gpu_processor (
.in_gpu_x(_d_gpu_processor_gpu_x),
.in_gpu_y(_d_gpu_processor_gpu_y),
.in_gpu_colour(_d_gpu_processor_gpu_colour),
.in_gpu_param0(_d_gpu_processor_gpu_param0),
.in_gpu_param1(_d_gpu_processor_gpu_param1),
.in_gpu_param2(_d_gpu_processor_gpu_param2),
.in_gpu_param3(_d_gpu_processor_gpu_param3),
.in_gpu_write(_d_gpu_processor_gpu_write),
.in_blit1_writer_tile(_d_gpu_processor_blit1_writer_tile),
.in_blit1_writer_line(_d_gpu_processor_blit1_writer_line),
.in_blit1_writer_bitmap(_d_gpu_processor_blit1_writer_bitmap),
.in_vector_block_number(_d_gpu_processor_vector_block_number),
.in_vector_block_colour(_d_gpu_processor_vector_block_colour),
.in_vector_block_xc(_d_gpu_processor_vector_block_xc),
.in_vector_block_yc(_d_gpu_processor_vector_block_yc),
.in_draw_vector(_d_gpu_processor_draw_vector),
.in_vertices_writer_block(_d_gpu_processor_vertices_writer_block),
.in_vertices_writer_vertex(_d_gpu_processor_vertices_writer_vertex),
.in_vertices_writer_xdelta(_d_gpu_processor_vertices_writer_xdelta),
.in_vertices_writer_ydelta(_d_gpu_processor_vertices_writer_ydelta),
.in_vertices_writer_active(_d_gpu_processor_vertices_writer_active),
.out_bitmap_x_write(_w_gpu_processor_bitmap_x_write),
.out_bitmap_y_write(_w_gpu_processor_bitmap_y_write),
.out_bitmap_colour_write(_w_gpu_processor_bitmap_colour_write),
.out_bitmap_write(_w_gpu_processor_bitmap_write),
.out_gpu_active(_w_gpu_processor_gpu_active),
.out_vector_block_active(_w_gpu_processor_vector_block_active),
.out_done(_w_gpu_processor_done),
.in_run(_gpu_processor_run),
.reset(reset),
.clock(in_video_clock)
);
M_sdcard #(
.IO_ADDR_SECTOR_WIDTH(32),
.IO_ADDR_SECTOR_INIT(0),
.IO_ADDR_SECTOR_SIGNED(0),
.IO_READ_SECTOR_WIDTH(1),
.IO_READ_SECTOR_INIT(0),
.IO_READ_SECTOR_SIGNED(0),
.IO_READY_WIDTH(1),
.IO_READY_INIT(0),
.IO_READY_SIGNED(0),
.STORE_ADDR1_WIDTH(9),
.STORE_ADDR1_INIT(0),
.STORE_ADDR1_SIGNED(0),
.STORE_WENABLE1_WIDTH(1),
.STORE_WENABLE1_INIT(0),
.STORE_WENABLE1_SIGNED(0),
.STORE_WDATA1_WIDTH(8),
.STORE_WDATA1_INIT(0),
.STORE_WDATA1_SIGNED(0)
) sd (
.in_sd_miso(in_sd_miso),
.in_io_addr_sector(_d_sdcio_addr_sector),
.in_io_read_sector(_d_sdcio_read_sector),
.out_sd_clk(_w_sd_sd_clk),
.out_sd_mosi(_w_sd_sd_mosi),
.out_sd_csn(_w_sd_sd_csn),
.out_io_ready(_w_sd_io_ready),
.out_store_addr1(_w_sd_store_addr1),
.out_store_wenable1(_w_sd_store_wenable1),
.out_store_wdata1(_w_sd_store_wdata1),
.out_done(_w_sd_done),
.in_run(_sd_run),
.reset(reset),
.clock(clock)
);

M_memmap_io_mem_bitmap __mem__bitmap(
.clock0(in_video_clock),
.clock1(in_video_clock),
.in_bitmap_addr0(_w_bitmap_window_bitmap_addr0),
.in_bitmap_wenable1(_w_pixel_writer_bitmap_wenable1),
.in_bitmap_wdata1(_w_pixel_writer_bitmap_wdata1),
.in_bitmap_addr1(_w_pixel_writer_bitmap_addr1),
.out_bitmap_rdata0(_w_mem_bitmap_rdata0)
);
M_memmap_io_mem_sdbuffer __mem__sdbuffer(
.clock0(clock),
.clock1(clock),
.in_sdbuffer_addr0(_d_sdbuffer_addr0),
.in_sdbuffer_wenable1(_w_sd_store_wenable1),
.in_sdbuffer_wdata1(_w_sd_store_wdata1),
.in_sdbuffer_addr1(_w_sd_store_addr1),
.out_sdbuffer_rdata0(_w_mem_sdbuffer_rdata0)
);
M_memmap_io_mem_uartInBuffer __mem__uartInBuffer(
.clock0(clock),
.clock1(clock),
.in_uartInBuffer_addr0(_d_uartInBuffer_addr0),
.in_uartInBuffer_wenable1(_d_uartInBuffer_wenable1),
.in_uartInBuffer_wdata1(_d_uartInBuffer_wdata1),
.in_uartInBuffer_addr1(_d_uartInBuffer_addr1),
.out_uartInBuffer_rdata0(_w_mem_uartInBuffer_rdata0)
);
M_memmap_io_mem_uartOutBuffer __mem__uartOutBuffer(
.clock0(clock),
.clock1(clock),
.in_uartOutBuffer_addr0(_d_uartOutBuffer_addr0),
.in_uartOutBuffer_wenable1(_d_uartOutBuffer_wenable1),
.in_uartOutBuffer_wdata1(_d_uartOutBuffer_wdata1),
.in_uartOutBuffer_addr1(_d_uartOutBuffer_addr1),
.out_uartOutBuffer_rdata0(_w_mem_uartOutBuffer_rdata0)
);


always @* begin
_d_uo_data_in = _q_uo_data_in;
_d_uo_data_in_ready = _q_uo_data_in_ready;
_d_sdbuffer_addr0 = _q_sdbuffer_addr0;
_d_sdcio_addr_sector = _q_sdcio_addr_sector;
_d_sdcio_read_sector = _q_sdcio_read_sector;
_d_uartInBuffer_addr0 = _q_uartInBuffer_addr0;
_d_uartInBuffer_wenable1 = _q_uartInBuffer_wenable1;
_d_uartInBuffer_wdata1 = _q_uartInBuffer_wdata1;
_d_uartInBuffer_addr1 = _q_uartInBuffer_addr1;
_d_uartInBufferNext = _q_uartInBufferNext;
_d_uartInBufferTop = _q_uartInBufferTop;
_d_uartOutBuffer_addr0 = _q_uartOutBuffer_addr0;
_d_uartOutBuffer_wenable1 = _q_uartOutBuffer_wenable1;
_d_uartOutBuffer_wdata1 = _q_uartOutBuffer_wdata1;
_d_uartOutBuffer_addr1 = _q_uartOutBuffer_addr1;
_d_uartOutBufferNext = _q_uartOutBufferNext;
_d_uartOutBufferTop = _q_uartOutBufferTop;
_d_newuartOutBufferTop = _q_newuartOutBufferTop;
_d_LATCHmemoryRead = _q_LATCHmemoryRead;
_d_LATCHmemoryWrite = _q_LATCHmemoryWrite;
_d_delayed_5104_4 = _q_delayed_5104_4;
_d_leds = _q_leds;
_d_readData = _q_readData;
_d_p1hz_resetCounter = _q_p1hz_resetCounter;
_d_timer1hz_resetCounter = _q_timer1hz_resetCounter;
_d_sleepTimer_resetCount = _q_sleepTimer_resetCount;
_d_sleepTimer_resetCounter = _q_sleepTimer_resetCounter;
_d_timer1khz_resetCount = _q_timer1khz_resetCount;
_d_timer1khz_resetCounter = _q_timer1khz_resetCounter;
_d_rng_resetRandom = _q_rng_resetRandom;
_d_background_generator_backgroundcolour = _q_background_generator_backgroundcolour;
_d_background_generator_backgroundcolour_alt = _q_background_generator_backgroundcolour_alt;
_d_background_generator_backgroundcolour_mode = _q_background_generator_backgroundcolour_mode;
_d_tile_map_tm_x = _q_tile_map_tm_x;
_d_tile_map_tm_y = _q_tile_map_tm_y;
_d_tile_map_tm_character = _q_tile_map_tm_character;
_d_tile_map_tm_foreground = _q_tile_map_tm_foreground;
_d_tile_map_tm_background = _q_tile_map_tm_background;
_d_tile_map_tm_write = _q_tile_map_tm_write;
_d_tile_map_tile_writer_tile = _q_tile_map_tile_writer_tile;
_d_tile_map_tile_writer_line = _q_tile_map_tile_writer_line;
_d_tile_map_tile_writer_bitmap = _q_tile_map_tile_writer_bitmap;
_d_tile_map_tm_scrollwrap = _q_tile_map_tm_scrollwrap;
_d_bitmap_window_bitmap_write_offset = _q_bitmap_window_bitmap_write_offset;
_d_bitmap_window_bitmap_x_read = _q_bitmap_window_bitmap_x_read;
_d_bitmap_window_bitmap_y_read = _q_bitmap_window_bitmap_y_read;
_d_lower_sprites_sprite_set_number = _q_lower_sprites_sprite_set_number;
_d_lower_sprites_sprite_set_active = _q_lower_sprites_sprite_set_active;
_d_lower_sprites_sprite_set_double = _q_lower_sprites_sprite_set_double;
_d_lower_sprites_sprite_set_colour = _q_lower_sprites_sprite_set_colour;
_d_lower_sprites_sprite_set_x = _q_lower_sprites_sprite_set_x;
_d_lower_sprites_sprite_set_y = _q_lower_sprites_sprite_set_y;
_d_lower_sprites_sprite_set_tile = _q_lower_sprites_sprite_set_tile;
_d_lower_sprites_sprite_layer_write = _q_lower_sprites_sprite_layer_write;
_d_lower_sprites_sprite_update = _q_lower_sprites_sprite_update;
_d_lower_sprites_sprite_writer_sprite = _q_lower_sprites_sprite_writer_sprite;
_d_lower_sprites_sprite_writer_line = _q_lower_sprites_sprite_writer_line;
_d_lower_sprites_sprite_writer_bitmap = _q_lower_sprites_sprite_writer_bitmap;
_d_lower_sprites_sprite_writer_active = _q_lower_sprites_sprite_writer_active;
_d_upper_sprites_sprite_set_number = _q_upper_sprites_sprite_set_number;
_d_upper_sprites_sprite_set_active = _q_upper_sprites_sprite_set_active;
_d_upper_sprites_sprite_set_double = _q_upper_sprites_sprite_set_double;
_d_upper_sprites_sprite_set_colour = _q_upper_sprites_sprite_set_colour;
_d_upper_sprites_sprite_set_x = _q_upper_sprites_sprite_set_x;
_d_upper_sprites_sprite_set_y = _q_upper_sprites_sprite_set_y;
_d_upper_sprites_sprite_set_tile = _q_upper_sprites_sprite_set_tile;
_d_upper_sprites_sprite_layer_write = _q_upper_sprites_sprite_layer_write;
_d_upper_sprites_sprite_update = _q_upper_sprites_sprite_update;
_d_upper_sprites_sprite_writer_sprite = _q_upper_sprites_sprite_writer_sprite;
_d_upper_sprites_sprite_writer_line = _q_upper_sprites_sprite_writer_line;
_d_upper_sprites_sprite_writer_bitmap = _q_upper_sprites_sprite_writer_bitmap;
_d_upper_sprites_sprite_writer_active = _q_upper_sprites_sprite_writer_active;
_d_character_map_window_tpu_x = _q_character_map_window_tpu_x;
_d_character_map_window_tpu_y = _q_character_map_window_tpu_y;
_d_character_map_window_tpu_character = _q_character_map_window_tpu_character;
_d_character_map_window_tpu_foreground = _q_character_map_window_tpu_foreground;
_d_character_map_window_tpu_background = _q_character_map_window_tpu_background;
_d_character_map_window_tpu_write = _q_character_map_window_tpu_write;
_d_terminal_window_terminal_character = _q_terminal_window_terminal_character;
_d_terminal_window_terminal_write = _q_terminal_window_terminal_write;
_d_terminal_window_showterminal = _q_terminal_window_showterminal;
_d_terminal_window_showcursor = _q_terminal_window_showcursor;
_d_apu_processor_L_waveform = _q_apu_processor_L_waveform;
_d_apu_processor_L_note = _q_apu_processor_L_note;
_d_apu_processor_L_duration = _q_apu_processor_L_duration;
_d_apu_processor_L_apu_write = _q_apu_processor_L_apu_write;
_d_apu_processor_R_waveform = _q_apu_processor_R_waveform;
_d_apu_processor_R_note = _q_apu_processor_R_note;
_d_apu_processor_R_duration = _q_apu_processor_R_duration;
_d_apu_processor_R_apu_write = _q_apu_processor_R_apu_write;
_d_gpu_processor_gpu_x = _q_gpu_processor_gpu_x;
_d_gpu_processor_gpu_y = _q_gpu_processor_gpu_y;
_d_gpu_processor_gpu_colour = _q_gpu_processor_gpu_colour;
_d_gpu_processor_gpu_param0 = _q_gpu_processor_gpu_param0;
_d_gpu_processor_gpu_param1 = _q_gpu_processor_gpu_param1;
_d_gpu_processor_gpu_param2 = _q_gpu_processor_gpu_param2;
_d_gpu_processor_gpu_param3 = _q_gpu_processor_gpu_param3;
_d_gpu_processor_gpu_write = _q_gpu_processor_gpu_write;
_d_gpu_processor_blit1_writer_tile = _q_gpu_processor_blit1_writer_tile;
_d_gpu_processor_blit1_writer_line = _q_gpu_processor_blit1_writer_line;
_d_gpu_processor_blit1_writer_bitmap = _q_gpu_processor_blit1_writer_bitmap;
_d_gpu_processor_vector_block_number = _q_gpu_processor_vector_block_number;
_d_gpu_processor_vector_block_colour = _q_gpu_processor_vector_block_colour;
_d_gpu_processor_vector_block_xc = _q_gpu_processor_vector_block_xc;
_d_gpu_processor_vector_block_yc = _q_gpu_processor_vector_block_yc;
_d_gpu_processor_draw_vector = _q_gpu_processor_draw_vector;
_d_gpu_processor_vertices_writer_block = _q_gpu_processor_vertices_writer_block;
_d_gpu_processor_vertices_writer_vertex = _q_gpu_processor_vertices_writer_vertex;
_d_gpu_processor_vertices_writer_xdelta = _q_gpu_processor_vertices_writer_xdelta;
_d_gpu_processor_vertices_writer_ydelta = _q_gpu_processor_vertices_writer_ydelta;
_d_gpu_processor_vertices_writer_active = _q_gpu_processor_vertices_writer_active;
_d_index = _q_index;
_p1hz_run = 1;
_timer1hz_run = 1;
_sleepTimer_run = 1;
_timer1khz_run = 1;
_rng_run = 1;
_usend_run = 1;
_background_generator_run = 1;
_tile_map_run = 1;
_bitmap_window_run = 1;
_pixel_writer_run = 1;
_lower_sprites_run = 1;
_upper_sprites_run = 1;
_character_map_window_run = 1;
_terminal_window_run = 1;
_display_run = 1;
_apu_processor_L_run = 1;
_apu_processor_R_run = 1;
_gpu_processor_run = 1;
_sd_run = 1;
_t_reg_btns = 0;
// _always_pre
_t_reg_btns = _d_delayed_5104_4;
_d_delayed_5104_4 =  in_btns;
_d_uartInBuffer_wenable1 = 1;
_d_uartInBuffer_addr0 = _q_uartInBufferNext;
_d_uartInBuffer_addr1 = _q_uartInBufferTop;
_d_uartOutBuffer_wenable1 = 1;
_d_uartOutBuffer_addr0 = _q_uartOutBufferNext;
_d_uartOutBuffer_addr1 = _q_uartOutBufferTop;
_d_uartInBuffer_wdata1 = _w_urecv_io_data_out;
_d_uartInBufferTop = (_w_urecv_io_data_out_ready)?_q_uartInBufferTop+1:_q_uartInBufferTop;
_d_uo_data_in = _w_mem_uartOutBuffer_rdata0;
_d_uo_data_in_ready = (_q_uartOutBufferNext!=_q_uartOutBufferTop)&&(!_w_usend_io_busy);
_d_uartOutBufferNext = ((_q_uartOutBufferNext!=_q_uartOutBufferTop)&&(!_w_usend_io_busy))?_q_uartOutBufferNext+1:_q_uartOutBufferNext;
_d_sdcio_read_sector = 0;
_d_p1hz_resetCounter = 0;
_d_sleepTimer_resetCounter = 0;
_d_timer1hz_resetCounter = 0;
_d_timer1khz_resetCounter = 0;
_d_rng_resetRandom = 0;
_d_apu_processor_L_apu_write = 0;
_d_apu_processor_R_apu_write = 0;
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_uo_data_in = 0;
_d_uo_data_in_ready = 0;
_d_sdbuffer_addr0 = 0;
_d_sdcio_addr_sector = 0;
_d_sdcio_read_sector = 0;
_d_uartInBuffer_addr0 = 0;
_d_uartInBuffer_wenable1 = 0;
_d_uartInBuffer_wdata1 = 0;
_d_uartInBuffer_addr1 = 0;
_d_uartInBufferNext = 0;
_d_uartInBufferTop = 0;
_d_uartOutBuffer_addr0 = 0;
_d_uartOutBuffer_wenable1 = 0;
_d_uartOutBuffer_wdata1 = 0;
_d_uartOutBuffer_addr1 = 0;
_d_uartOutBufferNext = 0;
_d_uartOutBufferTop = 0;
_d_newuartOutBufferTop = 0;
_t_reg_btns = 0;
// --
_d_terminal_window_showterminal = 1;
_d_terminal_window_showcursor = 1;
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
_d_uartOutBufferTop = _q_newuartOutBufferTop;
if (in_memoryRead&&~_q_LATCHmemoryRead) begin
// __block_5
// __block_7
  case (in_memoryAddress)
  16'h8000: begin
// __block_9_case
// __block_10
_d_readData = {8'b0,_w_mem_uartInBuffer_rdata0};
_d_uartInBufferNext = _q_uartInBufferNext+1;
// __block_11
  end
  16'h8004: begin
// __block_12_case
// __block_13
_d_readData = {14'b0,(_d_uartOutBufferTop+1==_d_uartOutBufferNext),(_q_uartInBufferNext!=_d_uartInBufferTop)};
// __block_14
  end
  16'h8008: begin
// __block_15_case
// __block_16
_d_readData = {9'b0,_t_reg_btns[0+:7]};
// __block_17
  end
  16'h800c: begin
// __block_18_case
// __block_19
_d_readData = _q_leds;
// __block_20
  end
  16'h8010: begin
// __block_21_case
// __block_22
_d_readData = _w_p1hz_counter1hz;
// __block_23
  end
  16'h8230: begin
// __block_24_case
// __block_25
_d_readData = _w_tile_map_tm_lastaction;
// __block_26
  end
  16'h8234: begin
// __block_27_case
// __block_28
_d_readData = _w_tile_map_tm_active;
// __block_29
  end
  16'h8304: begin
// __block_30_case
// __block_31
_d_readData = _w_lower_sprites_sprite_read_active;
// __block_32
  end
  16'h8308: begin
// __block_33_case
// __block_34
_d_readData = _w_lower_sprites_sprite_read_tile;
// __block_35
  end
  16'h830c: begin
// __block_36_case
// __block_37
_d_readData = _w_lower_sprites_sprite_read_colour;
// __block_38
  end
  16'h8310: begin
// __block_39_case
// __block_40
_d_readData = _w_lower_sprites_sprite_read_x[10+:1]?16'hf800:16'h0000|_w_lower_sprites_sprite_read_x;
// __block_41
  end
  16'h8314: begin
// __block_42_case
// __block_43
_d_readData = _w_lower_sprites_sprite_read_y[10+:1]?16'hf800:16'h0000|_w_lower_sprites_sprite_read_y;
// __block_44
  end
  16'h8318: begin
// __block_45_case
// __block_46
_d_readData = _w_lower_sprites_sprite_read_double;
// __block_47
  end
  16'h8330: begin
// __block_48_case
// __block_49
_d_readData = _w_lower_sprites_collision_0;
// __block_50
  end
  16'h8332: begin
// __block_51_case
// __block_52
_d_readData = _w_lower_sprites_collision_1;
// __block_53
  end
  16'h8334: begin
// __block_54_case
// __block_55
_d_readData = _w_lower_sprites_collision_2;
// __block_56
  end
  16'h8336: begin
// __block_57_case
// __block_58
_d_readData = _w_lower_sprites_collision_3;
// __block_59
  end
  16'h8338: begin
// __block_60_case
// __block_61
_d_readData = _w_lower_sprites_collision_4;
// __block_62
  end
  16'h833a: begin
// __block_63_case
// __block_64
_d_readData = _w_lower_sprites_collision_5;
// __block_65
  end
  16'h833c: begin
// __block_66_case
// __block_67
_d_readData = _w_lower_sprites_collision_6;
// __block_68
  end
  16'h833e: begin
// __block_69_case
// __block_70
_d_readData = _w_lower_sprites_collision_7;
// __block_71
  end
  16'h8340: begin
// __block_72_case
// __block_73
_d_readData = _w_lower_sprites_collision_8;
// __block_74
  end
  16'h8342: begin
// __block_75_case
// __block_76
_d_readData = _w_lower_sprites_collision_9;
// __block_77
  end
  16'h8344: begin
// __block_78_case
// __block_79
_d_readData = _w_lower_sprites_collision_10;
// __block_80
  end
  16'h8346: begin
// __block_81_case
// __block_82
_d_readData = _w_lower_sprites_collision_11;
// __block_83
  end
  16'h8348: begin
// __block_84_case
// __block_85
_d_readData = _w_lower_sprites_collision_12;
// __block_86
  end
  16'h841c: begin
// __block_87_case
// __block_88
_d_readData = _w_gpu_processor_gpu_active;
// __block_89
  end
  16'h8448: begin
// __block_90_case
// __block_91
_d_readData = _w_gpu_processor_vector_block_active;
// __block_92
  end
  16'h8470: begin
// __block_93_case
// __block_94
_d_readData = _w_bitmap_window_bitmap_colour_read;
// __block_95
  end
  16'h8504: begin
// __block_96_case
// __block_97
_d_readData = _w_upper_sprites_sprite_read_active;
// __block_98
  end
  16'h8508: begin
// __block_99_case
// __block_100
_d_readData = _w_upper_sprites_sprite_read_tile;
// __block_101
  end
  16'h850c: begin
// __block_102_case
// __block_103
_d_readData = _w_upper_sprites_sprite_read_colour;
// __block_104
  end
  16'h8510: begin
// __block_105_case
// __block_106
_d_readData = _w_upper_sprites_sprite_read_x[10+:1]?16'hf800:16'h0000|_w_upper_sprites_sprite_read_x;
// __block_107
  end
  16'h8514: begin
// __block_108_case
// __block_109
_d_readData = _w_upper_sprites_sprite_read_y[10+:1]?16'hf800:16'h0000|_w_upper_sprites_sprite_read_y;
// __block_110
  end
  16'h8518: begin
// __block_111_case
// __block_112
_d_readData = _w_upper_sprites_sprite_read_double;
// __block_113
  end
  16'h8530: begin
// __block_114_case
// __block_115
_d_readData = _w_upper_sprites_collision_0;
// __block_116
  end
  16'h8532: begin
// __block_117_case
// __block_118
_d_readData = _w_upper_sprites_collision_1;
// __block_119
  end
  16'h8534: begin
// __block_120_case
// __block_121
_d_readData = _w_upper_sprites_collision_2;
// __block_122
  end
  16'h8536: begin
// __block_123_case
// __block_124
_d_readData = _w_upper_sprites_collision_3;
// __block_125
  end
  16'h8538: begin
// __block_126_case
// __block_127
_d_readData = _w_upper_sprites_collision_4;
// __block_128
  end
  16'h853a: begin
// __block_129_case
// __block_130
_d_readData = _w_upper_sprites_collision_5;
// __block_131
  end
  16'h853c: begin
// __block_132_case
// __block_133
_d_readData = _w_upper_sprites_collision_6;
// __block_134
  end
  16'h853e: begin
// __block_135_case
// __block_136
_d_readData = _w_upper_sprites_collision_7;
// __block_137
  end
  16'h8540: begin
// __block_138_case
// __block_139
_d_readData = _w_upper_sprites_collision_8;
// __block_140
  end
  16'h8542: begin
// __block_141_case
// __block_142
_d_readData = _w_upper_sprites_collision_9;
// __block_143
  end
  16'h8544: begin
// __block_144_case
// __block_145
_d_readData = _w_upper_sprites_collision_10;
// __block_146
  end
  16'h8546: begin
// __block_147_case
// __block_148
_d_readData = _w_upper_sprites_collision_11;
// __block_149
  end
  16'h8548: begin
// __block_150_case
// __block_151
_d_readData = _w_upper_sprites_collision_12;
// __block_152
  end
  16'h8614: begin
// __block_153_case
// __block_154
_d_readData = _w_character_map_window_tpu_active;
// __block_155
  end
  16'h8700: begin
// __block_156_case
// __block_157
_d_readData = _w_terminal_window_terminal_active;
// __block_158
  end
  16'h8808: begin
// __block_159_case
// __block_160
_d_readData = _w_apu_processor_L_audio_active;
// __block_161
  end
  16'h8818: begin
// __block_162_case
// __block_163
_d_readData = _w_apu_processor_R_audio_active;
// __block_164
  end
  16'h8900: begin
// __block_165_case
// __block_166
_d_readData = _w_rng_g_noise_out;
// __block_167
  end
  16'h8904: begin
// __block_168_case
// __block_169
_d_readData = _w_rng_u_noise_out;
// __block_170
  end
  16'h8910: begin
// __block_171_case
// __block_172
_d_readData = _w_timer1hz_counter1hz;
// __block_173
  end
  16'h8920: begin
// __block_174_case
// __block_175
_d_readData = _w_timer1khz_counter1khz;
// __block_176
  end
  16'h8930: begin
// __block_177_case
// __block_178
_d_readData = _w_sleepTimer_counter1khz;
// __block_179
  end
  16'h8f00: begin
// __block_180_case
// __block_181
_d_readData = _w_sd_io_ready;
// __block_182
  end
  16'h8f10: begin
// __block_183_case
// __block_184
_d_readData = _w_mem_sdbuffer_rdata0;
// __block_185
  end
  16'h8ff0: begin
// __block_186_case
// __block_187
_d_readData = in_vblank;
// __block_188
  end
endcase
// __block_8
// __block_189
end else begin
// __block_6
end
// __block_190
if (in_memoryWrite&&~_q_LATCHmemoryWrite) begin
// __block_191
// __block_193
  case (in_memoryAddress)
  16'h8000: begin
// __block_195_case
// __block_196
_d_uartOutBuffer_wdata1 = in_writeData[0+:8];
_d_newuartOutBufferTop = _d_uartOutBufferTop+1;
// __block_197
  end
  16'h800c: begin
// __block_198_case
// __block_199
_d_leds = in_writeData;
// __block_200
  end
  16'h8100: begin
// __block_201_case
// __block_202
_d_background_generator_backgroundcolour = in_writeData;
// __block_203
  end
  16'h8104: begin
// __block_204_case
// __block_205
_d_background_generator_backgroundcolour_alt = in_writeData;
// __block_206
  end
  16'h8108: begin
// __block_207_case
// __block_208
_d_background_generator_backgroundcolour_mode = in_writeData;
// __block_209
  end
  16'h8200: begin
// __block_210_case
// __block_211
_d_tile_map_tm_x = in_writeData;
// __block_212
  end
  16'h8204: begin
// __block_213_case
// __block_214
_d_tile_map_tm_y = in_writeData;
// __block_215
  end
  16'h8208: begin
// __block_216_case
// __block_217
_d_tile_map_tm_character = in_writeData;
// __block_218
  end
  16'h820c: begin
// __block_219_case
// __block_220
_d_tile_map_tm_background = in_writeData;
// __block_221
  end
  16'h8210: begin
// __block_222_case
// __block_223
_d_tile_map_tm_foreground = in_writeData;
// __block_224
  end
  16'h8214: begin
// __block_225_case
// __block_226
_d_tile_map_tm_write = 1;
// __block_227
  end
  16'h8220: begin
// __block_228_case
// __block_229
_d_tile_map_tile_writer_tile = in_writeData;
// __block_230
  end
  16'h8224: begin
// __block_231_case
// __block_232
_d_tile_map_tile_writer_line = in_writeData;
// __block_233
  end
  16'h8228: begin
// __block_234_case
// __block_235
_d_tile_map_tile_writer_bitmap = in_writeData;
// __block_236
  end
  16'h8230: begin
// __block_237_case
// __block_238
_d_tile_map_tm_scrollwrap = in_writeData;
// __block_239
  end
  16'h8300: begin
// __block_240_case
// __block_241
_d_lower_sprites_sprite_set_number = in_writeData;
// __block_242
  end
  16'h8304: begin
// __block_243_case
// __block_244
_d_lower_sprites_sprite_set_active = in_writeData;
_d_lower_sprites_sprite_layer_write = 1;
// __block_245
  end
  16'h8308: begin
// __block_246_case
// __block_247
_d_lower_sprites_sprite_set_tile = in_writeData;
_d_lower_sprites_sprite_layer_write = 2;
// __block_248
  end
  16'h830c: begin
// __block_249_case
// __block_250
_d_lower_sprites_sprite_set_colour = in_writeData;
_d_lower_sprites_sprite_layer_write = 3;
// __block_251
  end
  16'h8310: begin
// __block_252_case
// __block_253
_d_lower_sprites_sprite_set_x = in_writeData;
_d_lower_sprites_sprite_layer_write = 4;
// __block_254
  end
  16'h8314: begin
// __block_255_case
// __block_256
_d_lower_sprites_sprite_set_y = in_writeData;
_d_lower_sprites_sprite_layer_write = 5;
// __block_257
  end
  16'h8318: begin
// __block_258_case
// __block_259
_d_lower_sprites_sprite_set_double = in_writeData;
_d_lower_sprites_sprite_layer_write = 6;
// __block_260
  end
  16'h831c: begin
// __block_261_case
// __block_262
_d_lower_sprites_sprite_update = in_writeData;
_d_lower_sprites_sprite_layer_write = 10;
// __block_263
  end
  16'h8320: begin
// __block_264_case
// __block_265
_d_lower_sprites_sprite_writer_sprite = in_writeData;
// __block_266
  end
  16'h8324: begin
// __block_267_case
// __block_268
_d_lower_sprites_sprite_writer_line = in_writeData;
// __block_269
  end
  16'h8328: begin
// __block_270_case
// __block_271
_d_lower_sprites_sprite_writer_bitmap = in_writeData;
_d_lower_sprites_sprite_writer_active = 1;
// __block_272
  end
  16'h8400: begin
// __block_273_case
// __block_274
_d_gpu_processor_gpu_x = in_writeData;
// __block_275
  end
  16'h8404: begin
// __block_276_case
// __block_277
_d_gpu_processor_gpu_y = in_writeData;
// __block_278
  end
  16'h8408: begin
// __block_279_case
// __block_280
_d_gpu_processor_gpu_colour = in_writeData;
// __block_281
  end
  16'h840c: begin
// __block_282_case
// __block_283
_d_gpu_processor_gpu_param0 = in_writeData;
// __block_284
  end
  16'h8410: begin
// __block_285_case
// __block_286
_d_gpu_processor_gpu_param1 = in_writeData;
// __block_287
  end
  16'h8414: begin
// __block_288_case
// __block_289
_d_gpu_processor_gpu_param2 = in_writeData;
// __block_290
  end
  16'h8418: begin
// __block_291_case
// __block_292
_d_gpu_processor_gpu_param3 = in_writeData;
// __block_293
  end
  16'h841c: begin
// __block_294_case
// __block_295
_d_gpu_processor_gpu_write = in_writeData;
// __block_296
  end
  16'h8420: begin
// __block_297_case
// __block_298
_d_gpu_processor_vector_block_number = in_writeData;
// __block_299
  end
  16'h8424: begin
// __block_300_case
// __block_301
_d_gpu_processor_vector_block_colour = in_writeData;
// __block_302
  end
  16'h8428: begin
// __block_303_case
// __block_304
_d_gpu_processor_vector_block_xc = in_writeData;
// __block_305
  end
  16'h842c: begin
// __block_306_case
// __block_307
_d_gpu_processor_vector_block_yc = in_writeData;
// __block_308
  end
  16'h8430: begin
// __block_309_case
// __block_310
_d_gpu_processor_draw_vector = 1;
// __block_311
  end
  16'h8434: begin
// __block_312_case
// __block_313
_d_gpu_processor_vertices_writer_block = in_writeData;
// __block_314
  end
  16'h8438: begin
// __block_315_case
// __block_316
_d_gpu_processor_vertices_writer_vertex = in_writeData;
// __block_317
  end
  16'h843c: begin
// __block_318_case
// __block_319
_d_gpu_processor_vertices_writer_xdelta = in_writeData;
// __block_320
  end
  16'h8440: begin
// __block_321_case
// __block_322
_d_gpu_processor_vertices_writer_ydelta = in_writeData;
// __block_323
  end
  16'h8444: begin
// __block_324_case
// __block_325
_d_gpu_processor_vertices_writer_active = in_writeData;
// __block_326
  end
  16'h8450: begin
// __block_327_case
// __block_328
_d_gpu_processor_blit1_writer_tile = in_writeData;
// __block_329
  end
  16'h8454: begin
// __block_330_case
// __block_331
_d_gpu_processor_blit1_writer_line = in_writeData;
// __block_332
  end
  16'h8458: begin
// __block_333_case
// __block_334
_d_gpu_processor_blit1_writer_bitmap = in_writeData;
// __block_335
  end
  16'h8460: begin
// __block_336_case
// __block_337
_d_bitmap_window_bitmap_write_offset = in_writeData;
// __block_338
  end
  16'h8470: begin
// __block_339_case
// __block_340
_d_bitmap_window_bitmap_x_read = in_writeData;
// __block_341
  end
  16'h8474: begin
// __block_342_case
// __block_343
_d_bitmap_window_bitmap_y_read = in_writeData;
// __block_344
  end
  16'h8500: begin
// __block_345_case
// __block_346
_d_upper_sprites_sprite_set_number = in_writeData;
// __block_347
  end
  16'h8504: begin
// __block_348_case
// __block_349
_d_upper_sprites_sprite_set_active = in_writeData;
_d_upper_sprites_sprite_layer_write = 1;
// __block_350
  end
  16'h8508: begin
// __block_351_case
// __block_352
_d_upper_sprites_sprite_set_tile = in_writeData;
_d_upper_sprites_sprite_layer_write = 2;
// __block_353
  end
  16'h850c: begin
// __block_354_case
// __block_355
_d_upper_sprites_sprite_set_colour = in_writeData;
_d_upper_sprites_sprite_layer_write = 3;
// __block_356
  end
  16'h8510: begin
// __block_357_case
// __block_358
_d_upper_sprites_sprite_set_x = in_writeData;
_d_upper_sprites_sprite_layer_write = 4;
// __block_359
  end
  16'h8514: begin
// __block_360_case
// __block_361
_d_upper_sprites_sprite_set_y = in_writeData;
_d_upper_sprites_sprite_layer_write = 5;
// __block_362
  end
  16'h8518: begin
// __block_363_case
// __block_364
_d_upper_sprites_sprite_set_double = in_writeData;
_d_upper_sprites_sprite_layer_write = 6;
// __block_365
  end
  16'h851c: begin
// __block_366_case
// __block_367
_d_upper_sprites_sprite_update = in_writeData;
_d_upper_sprites_sprite_layer_write = 10;
// __block_368
  end
  16'h8520: begin
// __block_369_case
// __block_370
_d_upper_sprites_sprite_writer_sprite = in_writeData;
// __block_371
  end
  16'h8524: begin
// __block_372_case
// __block_373
_d_upper_sprites_sprite_writer_line = in_writeData;
// __block_374
  end
  16'h8528: begin
// __block_375_case
// __block_376
_d_upper_sprites_sprite_writer_bitmap = in_writeData;
_d_upper_sprites_sprite_writer_active = 1;
// __block_377
  end
  16'h8600: begin
// __block_378_case
// __block_379
_d_character_map_window_tpu_x = in_writeData;
// __block_380
  end
  16'h8604: begin
// __block_381_case
// __block_382
_d_character_map_window_tpu_y = in_writeData;
// __block_383
  end
  16'h8608: begin
// __block_384_case
// __block_385
_d_character_map_window_tpu_character = in_writeData;
// __block_386
  end
  16'h860c: begin
// __block_387_case
// __block_388
_d_character_map_window_tpu_background = in_writeData;
// __block_389
  end
  16'h8610: begin
// __block_390_case
// __block_391
_d_character_map_window_tpu_foreground = in_writeData;
// __block_392
  end
  16'h8614: begin
// __block_393_case
// __block_394
_d_character_map_window_tpu_write = in_writeData;
// __block_395
  end
  16'h8700: begin
// __block_396_case
// __block_397
_d_terminal_window_terminal_character = in_writeData;
_d_terminal_window_terminal_write = 1;
// __block_398
  end
  16'h8704: begin
// __block_399_case
// __block_400
_d_terminal_window_showterminal = in_writeData;
// __block_401
  end
  16'h8800: begin
// __block_402_case
// __block_403
_d_apu_processor_L_waveform = in_writeData;
// __block_404
  end
  16'h8804: begin
// __block_405_case
// __block_406
_d_apu_processor_L_note = in_writeData;
// __block_407
  end
  16'h8808: begin
// __block_408_case
// __block_409
_d_apu_processor_L_duration = in_writeData;
// __block_410
  end
  16'h880c: begin
// __block_411_case
// __block_412
_d_apu_processor_L_apu_write = in_writeData;
// __block_413
  end
  16'h8810: begin
// __block_414_case
// __block_415
_d_apu_processor_R_waveform = in_writeData;
// __block_416
  end
  16'h8814: begin
// __block_417_case
// __block_418
_d_apu_processor_R_note = in_writeData;
// __block_419
  end
  16'h8818: begin
// __block_420_case
// __block_421
_d_apu_processor_R_duration = in_writeData;
// __block_422
  end
  16'h881c: begin
// __block_423_case
// __block_424
_d_apu_processor_R_apu_write = in_writeData;
// __block_425
  end
  16'h8900: begin
// __block_426_case
// __block_427
_d_rng_resetRandom = 1;
// __block_428
  end
  16'h8910: begin
// __block_429_case
// __block_430
_d_timer1hz_resetCounter = 1;
// __block_431
  end
  16'h8920: begin
// __block_432_case
// __block_433
_d_timer1khz_resetCount = in_writeData;
_d_timer1khz_resetCounter = 1;
// __block_434
  end
  16'h8930: begin
// __block_435_case
// __block_436
_d_sleepTimer_resetCount = in_writeData;
_d_sleepTimer_resetCounter = 1;
// __block_437
  end
  16'h8f00: begin
// __block_438_case
// __block_439
_d_sdcio_read_sector = 1;
// __block_440
  end
  16'h8f04: begin
// __block_441_case
// __block_442
_d_sdcio_addr_sector[16+:16] = in_writeData;
// __block_443
  end
  16'h8f08: begin
// __block_444_case
// __block_445
_d_sdcio_addr_sector[0+:16] = in_writeData;
// __block_446
  end
  16'h8f10: begin
// __block_447_case
// __block_448
_d_sdbuffer_addr0 = in_writeData;
// __block_449
  end
endcase
// __block_194
// __block_450
end else begin
// __block_192
end
// __block_451
if (~in_memoryWrite&&~_q_LATCHmemoryWrite) begin
// __block_452
// __block_454
_d_tile_map_tm_write = 0;
_d_tile_map_tm_scrollwrap = 0;
_d_lower_sprites_sprite_layer_write = 0;
_d_lower_sprites_sprite_writer_active = 0;
_d_bitmap_window_bitmap_write_offset = 0;
_d_gpu_processor_gpu_write = 0;
_d_gpu_processor_draw_vector = 0;
_d_upper_sprites_sprite_layer_write = 0;
_d_upper_sprites_sprite_writer_active = 0;
_d_character_map_window_tpu_write = 0;
_d_terminal_window_terminal_write = 0;
// __block_455
end else begin
// __block_453
end
// __block_456
_d_LATCHmemoryRead = in_memoryRead;
_d_LATCHmemoryWrite = in_memoryWrite;
// __block_457
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of memmap_io
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_PAWSCPU_mem_registers_1(
input      [5:0]                in_registers_1_addr0,
output reg signed [31:0]     out_registers_1_rdata0,
output reg signed [31:0]     out_registers_1_rdata1,
input      [0:0]             in_registers_1_wenable1,
input      [31:0]                 in_registers_1_wdata1,
input      [5:0]                in_registers_1_addr1,
input      clock0,
input      clock1
);
reg signed [31:0] buffer[63:0];
always @(posedge clock0) begin
  out_registers_1_rdata0 <= buffer[in_registers_1_addr0];
end
always @(posedge clock1) begin
  if (in_registers_1_wenable1) begin
    buffer[in_registers_1_addr1] <= in_registers_1_wdata1;
  end
end
initial begin
 buffer[0] = 0;
 buffer[1] = 0;
 buffer[2] = 0;
 buffer[3] = 0;
 buffer[4] = 0;
 buffer[5] = 0;
 buffer[6] = 0;
 buffer[7] = 0;
 buffer[8] = 0;
 buffer[9] = 0;
 buffer[10] = 0;
 buffer[11] = 0;
 buffer[12] = 0;
 buffer[13] = 0;
 buffer[14] = 0;
 buffer[15] = 0;
 buffer[16] = 0;
 buffer[17] = 0;
 buffer[18] = 0;
 buffer[19] = 0;
 buffer[20] = 0;
 buffer[21] = 0;
 buffer[22] = 0;
 buffer[23] = 0;
 buffer[24] = 0;
 buffer[25] = 0;
 buffer[26] = 0;
 buffer[27] = 0;
 buffer[28] = 0;
 buffer[29] = 0;
 buffer[30] = 0;
 buffer[31] = 0;
 buffer[32] = 0;
 buffer[33] = 0;
 buffer[34] = 0;
 buffer[35] = 0;
 buffer[36] = 0;
 buffer[37] = 0;
 buffer[38] = 0;
 buffer[39] = 0;
 buffer[40] = 0;
 buffer[41] = 0;
 buffer[42] = 0;
 buffer[43] = 0;
 buffer[44] = 0;
 buffer[45] = 0;
 buffer[46] = 0;
 buffer[47] = 0;
 buffer[48] = 0;
 buffer[49] = 0;
 buffer[50] = 0;
 buffer[51] = 0;
 buffer[52] = 0;
 buffer[53] = 0;
 buffer[54] = 0;
 buffer[55] = 0;
 buffer[56] = 0;
 buffer[57] = 0;
 buffer[58] = 0;
 buffer[59] = 0;
 buffer[60] = 0;
 buffer[61] = 0;
 buffer[62] = 0;
 buffer[63] = 0;
end

endmodule

module M_PAWSCPU_mem_registers_2(
input      [5:0]                in_registers_2_addr0,
output reg signed [31:0]     out_registers_2_rdata0,
output reg signed [31:0]     out_registers_2_rdata1,
input      [0:0]             in_registers_2_wenable1,
input      [31:0]                 in_registers_2_wdata1,
input      [5:0]                in_registers_2_addr1,
input      clock0,
input      clock1
);
reg signed [31:0] buffer[63:0];
always @(posedge clock0) begin
  out_registers_2_rdata0 <= buffer[in_registers_2_addr0];
end
always @(posedge clock1) begin
  if (in_registers_2_wenable1) begin
    buffer[in_registers_2_addr1] <= in_registers_2_wdata1;
  end
end
initial begin
 buffer[0] = 0;
 buffer[1] = 0;
 buffer[2] = 0;
 buffer[3] = 0;
 buffer[4] = 0;
 buffer[5] = 0;
 buffer[6] = 0;
 buffer[7] = 0;
 buffer[8] = 0;
 buffer[9] = 0;
 buffer[10] = 0;
 buffer[11] = 0;
 buffer[12] = 0;
 buffer[13] = 0;
 buffer[14] = 0;
 buffer[15] = 0;
 buffer[16] = 0;
 buffer[17] = 0;
 buffer[18] = 0;
 buffer[19] = 0;
 buffer[20] = 0;
 buffer[21] = 0;
 buffer[22] = 0;
 buffer[23] = 0;
 buffer[24] = 0;
 buffer[25] = 0;
 buffer[26] = 0;
 buffer[27] = 0;
 buffer[28] = 0;
 buffer[29] = 0;
 buffer[30] = 0;
 buffer[31] = 0;
 buffer[32] = 0;
 buffer[33] = 0;
 buffer[34] = 0;
 buffer[35] = 0;
 buffer[36] = 0;
 buffer[37] = 0;
 buffer[38] = 0;
 buffer[39] = 0;
 buffer[40] = 0;
 buffer[41] = 0;
 buffer[42] = 0;
 buffer[43] = 0;
 buffer[44] = 0;
 buffer[45] = 0;
 buffer[46] = 0;
 buffer[47] = 0;
 buffer[48] = 0;
 buffer[49] = 0;
 buffer[50] = 0;
 buffer[51] = 0;
 buffer[52] = 0;
 buffer[53] = 0;
 buffer[54] = 0;
 buffer[55] = 0;
 buffer[56] = 0;
 buffer[57] = 0;
 buffer[58] = 0;
 buffer[59] = 0;
 buffer[60] = 0;
 buffer[61] = 0;
 buffer[62] = 0;
 buffer[63] = 0;
end

endmodule

module M_PAWSCPU (
in_readdata,
in_memorybusy,
in_clock_copro,
out_function3,
out_address,
out_writedata,
out_writememory,
out_readmemory,
out_Icacheflag,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [15:0] in_readdata;
input  [0:0] in_memorybusy;
input  [0:0] in_clock_copro;
output  [2:0] out_function3;
output  [31:0] out_address;
output  [15:0] out_writedata;
output  [0:0] out_writememory;
output  [0:0] out_readmemory;
output  [0:0] out_Icacheflag;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [5:0] _w_registersW_registers_1_addr1;
wire  [0:0] _w_registersW_registers_1_wenable1;
wire signed [31:0] _w_registersW_registers_1_wdata1;
wire  [5:0] _w_registersW_registers_2_addr1;
wire  [0:0] _w_registersW_registers_2_wenable1;
wire signed [31:0] _w_registersW_registers_2_wdata1;
wire _w_registersW_done;
wire signed [31:0] _w_registersR_sourceReg1;
wire signed [31:0] _w_registersR_sourceReg2;
wire  [15:0] _w_registersR_sourceReg2LOW;
wire  [15:0] _w_registersR_sourceReg2HIGH;
wire  [5:0] _w_registersR_registers_1_addr0;
wire  [5:0] _w_registersR_registers_2_addr0;
wire _w_registersR_done;
wire  [31:0] _w_compressedunit_instruction32;
wire  [0:0] _w_compressedunit_compressed;
wire _w_compressedunit_done;
wire  [6:0] _w_DECODE_opCode;
wire  [2:0] _w_DECODE_function3;
wire  [6:0] _w_DECODE_function7;
wire  [4:0] _w_DECODE_rs1;
wire  [4:0] _w_DECODE_rs2;
wire  [4:0] _w_DECODE_rd;
wire signed [31:0] _w_DECODE_immediateValue;
wire _w_DECODE_done;
wire  [31:0] _w_AGU_pcPLUS2;
wire  [31:0] _w_AGU_nextPC;
wire  [31:0] _w_AGU_branchAddress;
wire  [31:0] _w_AGU_jumpAddress;
wire  [31:0] _w_AGU_AUIPCLUI;
wire  [31:0] _w_AGU_storeAddress;
wire  [31:0] _w_AGU_storeAddressPLUS2;
wire  [31:0] _w_AGU_loadAddress;
wire  [31:0] _w_AGU_loadAddressPLUS2;
wire _w_AGU_done;
wire  [0:0] _w_ALUI_busy;
wire signed [31:0] _w_ALUI_result;
wire _w_ALUI_done;
wire  [0:0] _w_ALUM_busy;
wire signed [31:0] _w_ALUM_result;
wire _w_ALUM_done;
wire  [0:0] _w_branchcomparisonunit_takeBranch;
wire _w_branchcomparisonunit_done;
wire signed [31:0] _w_combiner161632unit_HIGHLOW;
wire signed [31:0] _w_combiner161632unit_ZEROLOW;
wire _w_combiner161632unit_done;
wire  [31:0] _w_signextender8unit_withsign;
wire _w_signextender8unit_done;
wire  [31:0] _w_signextender16unit_withsign;
wire _w_signextender16unit_done;
wire  [31:0] _w_CSR_result;
wire _w_CSR_done;
wire signed [31:0] _w_mem_registers_1_rdata0;
wire signed [31:0] _w_mem_registers_2_rdata0;
reg  [7:0] _t_SE8nosign;
reg  [15:0] _t_SE16nosign;

reg  [31:0] _d_pc;
reg  [31:0] _q_pc;
reg  [0:0] _d_compressed;
reg  [0:0] _q_compressed;
reg  [0:0] _d_floatingpoint;
reg  [0:0] _q_floatingpoint;
reg  [0:0] _d_takeBranch;
reg  [0:0] _q_takeBranch;
reg  [0:0] _d_incPC;
reg  [0:0] _q_incPC;
reg signed [31:0] _d_result;
reg signed [31:0] _q_result;
reg  [0:0] _d_writeRegister;
reg  [0:0] _q_writeRegister;
reg  [31:0] _d_instruction;
reg  [31:0] _q_instruction;
reg  [15:0] _d_LOW;
reg  [15:0] _q_LOW;
reg  [15:0] _d_HIGH;
reg  [15:0] _q_HIGH;
reg  [31:0] _d_address,_q_address;
reg  [15:0] _d_writedata,_q_writedata;
reg  [0:0] _d_writememory,_q_writememory;
reg  [0:0] _d_readmemory,_q_readmemory;
reg  [0:0] _d_Icacheflag,_q_Icacheflag;
reg  [0:0] _d_registersW_writeRegister,_q_registersW_writeRegister;
reg  [0:0] _d_ALUI_start,_q_ALUI_start;
reg  [0:0] _d_ALUM_start,_q_ALUM_start;
reg  [0:0] _d_CSR_incCSRinstret,_q_CSR_incCSRinstret;
reg  [4:0] _d_index,_q_index;
reg  _registersW_run;
reg  _registersR_run;
reg  _compressedunit_run;
reg  _DECODE_run;
reg  _AGU_run;
reg  _ALUI_run;
reg  _ALUM_run;
reg  _branchcomparisonunit_run;
reg  _combiner161632unit_run;
reg  _signextender8unit_run;
reg  _signextender16unit_run;
reg  _CSR_run;
assign out_function3 = _w_DECODE_function3;
assign out_address = _q_address;
assign out_writedata = _q_writedata;
assign out_writememory = _q_writememory;
assign out_readmemory = _q_readmemory;
assign out_Icacheflag = _q_Icacheflag;
assign out_done = (_q_index == 19);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_pc <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_pc <= _d_pc;
_q_compressed <= _d_compressed;
_q_floatingpoint <= _d_floatingpoint;
_q_takeBranch <= _d_takeBranch;
_q_incPC <= _d_incPC;
_q_result <= _d_result;
_q_writeRegister <= _d_writeRegister;
_q_instruction <= _d_instruction;
_q_LOW <= _d_LOW;
_q_HIGH <= _d_HIGH;
_q_address <= _d_address;
_q_writedata <= _d_writedata;
_q_writememory <= _d_writememory;
_q_readmemory <= _d_readmemory;
_q_Icacheflag <= _d_Icacheflag;
_q_index <= _d_index;
  end
_q_registersW_writeRegister <= _d_registersW_writeRegister;
_q_ALUI_start <= _d_ALUI_start;
_q_ALUM_start <= _d_ALUM_start;
_q_CSR_incCSRinstret <= _d_CSR_incCSRinstret;
end

M_registersWRITE #(
.REGISTERS_1_ADDR1_WIDTH(6),
.REGISTERS_1_ADDR1_INIT(0),
.REGISTERS_1_ADDR1_SIGNED(0),
.REGISTERS_1_WENABLE1_WIDTH(1),
.REGISTERS_1_WENABLE1_INIT(0),
.REGISTERS_1_WENABLE1_SIGNED(0),
.REGISTERS_1_WDATA1_WIDTH(32),
.REGISTERS_1_WDATA1_INIT(0),
.REGISTERS_1_WDATA1_SIGNED(1),
.REGISTERS_2_ADDR1_WIDTH(6),
.REGISTERS_2_ADDR1_INIT(0),
.REGISTERS_2_ADDR1_SIGNED(0),
.REGISTERS_2_WENABLE1_WIDTH(1),
.REGISTERS_2_WENABLE1_INIT(0),
.REGISTERS_2_WENABLE1_SIGNED(0),
.REGISTERS_2_WDATA1_WIDTH(32),
.REGISTERS_2_WDATA1_INIT(0),
.REGISTERS_2_WDATA1_SIGNED(1)
) registersW (
.in_rd(_w_DECODE_rd),
.in_writeRegister(_d_registersW_writeRegister),
.in_floatingpoint(_d_floatingpoint),
.in_result(_d_result),
.out_registers_1_addr1(_w_registersW_registers_1_addr1),
.out_registers_1_wenable1(_w_registersW_registers_1_wenable1),
.out_registers_1_wdata1(_w_registersW_registers_1_wdata1),
.out_registers_2_addr1(_w_registersW_registers_2_addr1),
.out_registers_2_wenable1(_w_registersW_registers_2_wenable1),
.out_registers_2_wdata1(_w_registersW_registers_2_wdata1),
.out_done(_w_registersW_done),
.in_run(_registersW_run),
.reset(reset),
.clock(clock)
);
M_registersREAD #(
.REGISTERS_1_ADDR0_WIDTH(6),
.REGISTERS_1_ADDR0_INIT(0),
.REGISTERS_1_ADDR0_SIGNED(0),
.REGISTERS_1_RDATA0_WIDTH(32),
.REGISTERS_1_RDATA0_INIT(0),
.REGISTERS_1_RDATA0_SIGNED(1),
.REGISTERS_2_ADDR0_WIDTH(6),
.REGISTERS_2_ADDR0_INIT(0),
.REGISTERS_2_ADDR0_SIGNED(0),
.REGISTERS_2_RDATA0_WIDTH(32),
.REGISTERS_2_RDATA0_INIT(0),
.REGISTERS_2_RDATA0_SIGNED(1)
) registersR (
.in_rs1(_w_DECODE_rs1),
.in_rs2(_w_DECODE_rs2),
.in_floatingpoint(_d_floatingpoint),
.in_registers_1_rdata0(_w_mem_registers_1_rdata0),
.in_registers_2_rdata0(_w_mem_registers_2_rdata0),
.out_sourceReg1(_w_registersR_sourceReg1),
.out_sourceReg2(_w_registersR_sourceReg2),
.out_sourceReg2LOW(_w_registersR_sourceReg2LOW),
.out_sourceReg2HIGH(_w_registersR_sourceReg2HIGH),
.out_registers_1_addr0(_w_registersR_registers_1_addr0),
.out_registers_2_addr0(_w_registersR_registers_2_addr0),
.out_done(_w_registersR_done),
.in_run(_registersR_run),
.reset(reset),
.clock(clock)
);
M_compressedexpansion compressedunit (
.in_instruction16(in_readdata),
.out_instruction32(_w_compressedunit_instruction32),
.out_compressed(_w_compressedunit_compressed),
.out_done(_w_compressedunit_done),
.in_run(_compressedunit_run),
.reset(reset),
.clock(clock)
);
M_decoder DECODE (
.in_instruction(_d_instruction),
.out_opCode(_w_DECODE_opCode),
.out_function3(_w_DECODE_function3),
.out_function7(_w_DECODE_function7),
.out_rs1(_w_DECODE_rs1),
.out_rs2(_w_DECODE_rs2),
.out_rd(_w_DECODE_rd),
.out_immediateValue(_w_DECODE_immediateValue),
.out_done(_w_DECODE_done),
.in_run(_DECODE_run),
.reset(reset),
.clock(clock)
);
M_addressgenerator AGU (
.in_instruction(_d_instruction),
.in_pc(_q_pc),
.in_compressed(_d_compressed),
.in_sourceReg1(_w_registersR_sourceReg1),
.out_pcPLUS2(_w_AGU_pcPLUS2),
.out_nextPC(_w_AGU_nextPC),
.out_branchAddress(_w_AGU_branchAddress),
.out_jumpAddress(_w_AGU_jumpAddress),
.out_AUIPCLUI(_w_AGU_AUIPCLUI),
.out_storeAddress(_w_AGU_storeAddress),
.out_storeAddressPLUS2(_w_AGU_storeAddressPLUS2),
.out_loadAddress(_w_AGU_loadAddress),
.out_loadAddressPLUS2(_w_AGU_loadAddressPLUS2),
.out_done(_w_AGU_done),
.in_run(_AGU_run),
.reset(reset),
.clock(clock)
);
M_aluI ALUI (
.in_instruction(_d_instruction),
.in_sourceReg1(_w_registersR_sourceReg1),
.in_sourceReg2(_w_registersR_sourceReg2),
.in_start(_d_ALUI_start),
.out_busy(_w_ALUI_busy),
.out_result(_w_ALUI_result),
.out_done(_w_ALUI_done),
.in_run(_ALUI_run),
.reset(reset),
.clock(in_clock_copro)
);
M_aluM ALUM (
.in_function3(_w_DECODE_function3),
.in_sourceReg1(_w_registersR_sourceReg1),
.in_sourceReg2(_w_registersR_sourceReg2),
.in_start(_d_ALUM_start),
.out_busy(_w_ALUM_busy),
.out_result(_w_ALUM_result),
.out_done(_w_ALUM_done),
.in_run(_ALUM_run),
.reset(reset),
.clock(in_clock_copro)
);
M_branchcomparison branchcomparisonunit (
.in_opCode(_w_DECODE_opCode),
.in_function3(_w_DECODE_function3),
.in_sourceReg1(_w_registersR_sourceReg1),
.in_sourceReg2(_w_registersR_sourceReg2),
.out_takeBranch(_w_branchcomparisonunit_takeBranch),
.out_done(_w_branchcomparisonunit_done),
.in_run(_branchcomparisonunit_run),
.reset(reset),
.clock(clock)
);
M_halfhalfword combiner161632unit (
.in_HIGH(_d_HIGH),
.in_LOW(_d_LOW),
.out_HIGHLOW(_w_combiner161632unit_HIGHLOW),
.out_ZEROLOW(_w_combiner161632unit_ZEROLOW),
.out_done(_w_combiner161632unit_done),
.in_run(_combiner161632unit_run),
.reset(reset),
.clock(clock)
);
M_signextender8 signextender8unit (
.in_function3(_w_DECODE_function3),
.in_nosign(_t_SE8nosign),
.out_withsign(_w_signextender8unit_withsign),
.out_done(_w_signextender8unit_done),
.in_run(_signextender8unit_run),
.reset(reset),
.clock(clock)
);
M_signextender16 signextender16unit (
.in_function3(_w_DECODE_function3),
.in_nosign(_t_SE16nosign),
.out_withsign(_w_signextender16unit_withsign),
.out_done(_w_signextender16unit_done),
.in_run(_signextender16unit_run),
.reset(reset),
.clock(clock)
);
M_CSRblock CSR (
.in_instruction(_d_instruction),
.in_incCSRinstret(_d_CSR_incCSRinstret),
.out_result(_w_CSR_result),
.out_done(_w_CSR_done),
.in_run(_CSR_run),
.reset(reset),
.clock(clock)
);

M_PAWSCPU_mem_registers_1 __mem__registers_1(
.clock0(clock),
.clock1(clock),
.in_registers_1_addr0(_w_registersR_registers_1_addr0),
.in_registers_1_wenable1(_w_registersW_registers_1_wenable1),
.in_registers_1_wdata1(_w_registersW_registers_1_wdata1),
.in_registers_1_addr1(_w_registersW_registers_1_addr1),
.out_registers_1_rdata0(_w_mem_registers_1_rdata0)
);
M_PAWSCPU_mem_registers_2 __mem__registers_2(
.clock0(clock),
.clock1(clock),
.in_registers_2_addr0(_w_registersR_registers_2_addr0),
.in_registers_2_wenable1(_w_registersW_registers_2_wenable1),
.in_registers_2_wdata1(_w_registersW_registers_2_wdata1),
.in_registers_2_addr1(_w_registersW_registers_2_addr1),
.out_registers_2_rdata0(_w_mem_registers_2_rdata0)
);


always @* begin
_d_pc = _q_pc;
_d_compressed = _q_compressed;
_d_floatingpoint = _q_floatingpoint;
_d_takeBranch = _q_takeBranch;
_d_incPC = _q_incPC;
_d_result = _q_result;
_d_writeRegister = _q_writeRegister;
_d_instruction = _q_instruction;
_d_LOW = _q_LOW;
_d_HIGH = _q_HIGH;
_d_address = _q_address;
_d_writedata = _q_writedata;
_d_writememory = _q_writememory;
_d_readmemory = _q_readmemory;
_d_Icacheflag = _q_Icacheflag;
_d_registersW_writeRegister = _q_registersW_writeRegister;
_d_ALUI_start = _q_ALUI_start;
_d_ALUM_start = _q_ALUM_start;
_d_CSR_incCSRinstret = _q_CSR_incCSRinstret;
_d_index = _q_index;
_registersW_run = 1;
_registersR_run = 1;
_compressedunit_run = 1;
_DECODE_run = 1;
_AGU_run = 1;
_ALUI_run = 1;
_ALUM_run = 1;
_branchcomparisonunit_run = 1;
_combiner161632unit_run = 1;
_signextender8unit_run = 1;
_signextender16unit_run = 1;
_CSR_run = 1;
_t_SE8nosign = 0;
_t_SE16nosign = 0;
// _always_pre
_t_SE8nosign = in_readdata[_q_address[0+:1]?8:0+:8];
_t_SE16nosign = in_readdata;
_d_readmemory = 0;
_d_writememory = 0;
_d_registersW_writeRegister = 0;
_d_ALUM_start = 0;
_d_CSR_incCSRinstret = 0;
_d_index = 19;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_pc = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
_d_writeRegister = 0;
_d_takeBranch = 0;
_d_incPC = 1;
_d_floatingpoint = 0;
_d_address = _q_pc;
_d_Icacheflag = 1;
_d_readmemory = 1;
_d_index = 3;
end else begin
_d_index = 2;
end
end
3: begin
// __while__block_5
if (in_memorybusy) begin
// __block_6
// __block_8
// __block_9
_d_index = 3;
end else begin
_d_index = 4;
end
end
2: begin
// __block_3
_d_index = 19;
end
4: begin
// __block_7
_d_compressed = _w_compressedunit_compressed;
  case (_w_compressedunit_compressed)
  1'b0: begin
// __block_11_case
// __block_12
_d_LOW = _w_compressedunit_instruction32;
_d_address = _w_AGU_pcPLUS2;
_d_readmemory = 1;
_d_index = 7;
  end
  1'b1: begin
// __block_19_case
// __block_20
_d_instruction = _w_compressedunit_instruction32;
// __block_21
_d_index = 5;
  end
endcase
end
7: begin
// __while__block_13
if (in_memorybusy) begin
// __block_14
// __block_16
// __block_17
_d_index = 7;
end else begin
_d_index = 9;
end
end
5: begin
// __block_22
_d_index = 6;
end
9: begin
// __block_15
_d_HIGH = in_readdata;
_d_instruction = _w_combiner161632unit_HIGHLOW;
// __block_18
_d_index = 5;
end
6: begin
// __block_23
  case (_w_DECODE_opCode[2+:5])
  5'b01101: begin
// __block_25_case
// __block_26
_d_writeRegister = 1;
_d_result = _w_AGU_AUIPCLUI;
// __block_27
_d_index = 8;
  end
  5'b00101: begin
// __block_28_case
// __block_29
_d_writeRegister = 1;
_d_result = _w_AGU_AUIPCLUI;
// __block_30
_d_index = 8;
  end
  5'b11011: begin
// __block_31_case
// __block_32
_d_writeRegister = 1;
_d_incPC = 0;
_d_result = _w_AGU_nextPC;
// __block_33
_d_index = 8;
  end
  5'b11001: begin
// __block_34_case
// __block_35
_d_writeRegister = 1;
_d_incPC = 0;
_d_result = _w_AGU_nextPC;
// __block_36
_d_index = 8;
  end
  5'b11000: begin
// __block_37_case
// __block_38
_d_takeBranch = _w_branchcomparisonunit_takeBranch;
// __block_39
_d_index = 8;
  end
  5'b00000: begin
// __block_40_case
// __block_41
_d_writeRegister = 1;
_d_address = _w_AGU_loadAddress;
_d_Icacheflag = 0;
_d_readmemory = 1;
_d_index = 10;
  end
  5'b01000: begin
// __block_60_case
// __block_61
_d_address = _w_AGU_storeAddress;
_d_Icacheflag = 0;
_d_writedata = _w_registersR_sourceReg2LOW;
_d_writememory = 1;
_d_index = 11;
  end
  5'b00100: begin
// __block_78_case
// __block_79
_d_writeRegister = 1;
_d_result = _w_ALUI_result;
// __block_80
_d_index = 8;
  end
  5'b01100: begin
// __block_81_case
// __block_82
_d_writeRegister = 1;
if (_w_DECODE_function7[0+:1]) begin
// __block_83
// __block_85
_d_ALUM_start = 1;
_d_index = 15;
end else begin
// __block_84
_d_index = 12;
end
  end
  5'b11100: begin
// __block_94_case
// __block_95
_d_writeRegister = 1;
_d_result = _w_CSR_result;
// __block_96
_d_index = 8;
  end
endcase
end
8: begin
// __block_24
_d_registersW_writeRegister = _q_writeRegister;
_d_pc = (_q_incPC)?(_q_takeBranch?_w_AGU_branchAddress:_w_AGU_nextPC):(_w_DECODE_opCode[3+:1]?_w_AGU_jumpAddress:_w_AGU_loadAddress);
_d_CSR_incCSRinstret = 1;
// __block_97
_d_index = 1;
end
10: begin
// __while__block_42
if (in_memorybusy) begin
// __block_43
// __block_45
// __block_46
_d_index = 10;
end else begin
_d_index = 13;
end
end
11: begin
// __while__block_62
if (in_memorybusy) begin
// __block_63
// __block_65
// __block_66
_d_index = 11;
end else begin
_d_index = 14;
end
end
15: begin
// __while__block_86
if (_w_ALUM_busy) begin
// __block_87
// __block_89
// __block_90
_d_index = 15;
end else begin
_d_index = 12;
end
end
12: begin
// __block_92
_d_result = _w_DECODE_function7[0+:1]?_w_ALUM_result:_w_ALUI_result;
// __block_93
_d_index = 8;
end
13: begin
// __block_44
  case (_w_DECODE_function3&3)
  2'b10: begin
// __block_48_case
// __block_49
_d_LOW = in_readdata;
_d_address = _w_AGU_loadAddressPLUS2;
_d_readmemory = 1;
_d_index = 16;
  end
  default: begin
// __block_56_case
// __block_57
_d_result = ((_w_DECODE_function3&3)==0)?_w_signextender8unit_withsign:_w_signextender16unit_withsign;
// __block_58
_d_index = 8;
  end
endcase
end
14: begin
// __block_64
if ((_w_DECODE_function3&3)==2'b10) begin
// __block_67
// __block_69
_d_address = _w_AGU_storeAddressPLUS2;
_d_writedata = _w_registersR_sourceReg2HIGH;
_d_writememory = 1;
_d_index = 17;
end else begin
// __block_68
_d_index = 8;
end
end
16: begin
// __while__block_50
if (in_memorybusy) begin
// __block_51
// __block_53
// __block_54
_d_index = 16;
end else begin
_d_index = 18;
end
end
17: begin
// __while__block_70
if (in_memorybusy) begin
// __block_71
// __block_73
// __block_74
_d_index = 17;
end else begin
_d_index = 8;
end
end
18: begin
// __block_52
_d_HIGH = in_readdata;
_d_result = _w_combiner161632unit_HIGHLOW;
// __block_55
_d_index = 8;
end
19: begin // end of PAWSCPU
end
default: begin 
_d_index = 19;
 end
endcase
end
endmodule


module M_registersWRITE #(
parameter REGISTERS_1_ADDR1_WIDTH=1,parameter REGISTERS_1_ADDR1_SIGNED=0,parameter REGISTERS_1_ADDR1_INIT=0,
parameter REGISTERS_1_WENABLE1_WIDTH=1,parameter REGISTERS_1_WENABLE1_SIGNED=0,parameter REGISTERS_1_WENABLE1_INIT=0,
parameter REGISTERS_1_WDATA1_WIDTH=1,parameter REGISTERS_1_WDATA1_SIGNED=0,parameter REGISTERS_1_WDATA1_INIT=0,
parameter REGISTERS_2_ADDR1_WIDTH=1,parameter REGISTERS_2_ADDR1_SIGNED=0,parameter REGISTERS_2_ADDR1_INIT=0,
parameter REGISTERS_2_WENABLE1_WIDTH=1,parameter REGISTERS_2_WENABLE1_SIGNED=0,parameter REGISTERS_2_WENABLE1_INIT=0,
parameter REGISTERS_2_WDATA1_WIDTH=1,parameter REGISTERS_2_WDATA1_SIGNED=0,parameter REGISTERS_2_WDATA1_INIT=0
) (
in_rd,
in_writeRegister,
in_floatingpoint,
in_result,
out_registers_1_addr1,
out_registers_1_wenable1,
out_registers_1_wdata1,
out_registers_2_addr1,
out_registers_2_wenable1,
out_registers_2_wdata1,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [4:0] in_rd;
input  [0:0] in_writeRegister;
input  [0:0] in_floatingpoint;
input signed [31:0] in_result;
output  [REGISTERS_1_ADDR1_WIDTH-1:0] out_registers_1_addr1;
output  [REGISTERS_1_WENABLE1_WIDTH-1:0] out_registers_1_wenable1;
output  [REGISTERS_1_WDATA1_WIDTH-1:0] out_registers_1_wdata1;
output  [REGISTERS_2_ADDR1_WIDTH-1:0] out_registers_2_addr1;
output  [REGISTERS_2_WENABLE1_WIDTH-1:0] out_registers_2_wenable1;
output  [REGISTERS_2_WDATA1_WIDTH-1:0] out_registers_2_wdata1;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [REGISTERS_1_ADDR1_WIDTH-1:0] _d_registers_1_addr1,_q_registers_1_addr1;
reg  [REGISTERS_1_WENABLE1_WIDTH-1:0] _d_registers_1_wenable1,_q_registers_1_wenable1;
reg  [REGISTERS_1_WDATA1_WIDTH-1:0] _d_registers_1_wdata1,_q_registers_1_wdata1;
reg  [REGISTERS_2_ADDR1_WIDTH-1:0] _d_registers_2_addr1,_q_registers_2_addr1;
reg  [REGISTERS_2_WENABLE1_WIDTH-1:0] _d_registers_2_wenable1,_q_registers_2_wenable1;
reg  [REGISTERS_2_WDATA1_WIDTH-1:0] _d_registers_2_wdata1,_q_registers_2_wdata1;
reg  [1:0] _d_index,_q_index;
assign out_registers_1_addr1 = _d_registers_1_addr1;
assign out_registers_1_wenable1 = _d_registers_1_wenable1;
assign out_registers_1_wdata1 = _d_registers_1_wdata1;
assign out_registers_2_addr1 = _d_registers_2_addr1;
assign out_registers_2_wenable1 = _d_registers_2_wenable1;
assign out_registers_2_wdata1 = _d_registers_2_wdata1;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_registers_1_addr1 <= REGISTERS_1_ADDR1_INIT;
_q_registers_1_wenable1 <= REGISTERS_1_WENABLE1_INIT;
_q_registers_1_wdata1 <= REGISTERS_1_WDATA1_INIT;
_q_registers_2_addr1 <= REGISTERS_2_ADDR1_INIT;
_q_registers_2_wenable1 <= REGISTERS_2_WENABLE1_INIT;
_q_registers_2_wdata1 <= REGISTERS_2_WDATA1_INIT;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_registers_1_addr1 <= _d_registers_1_addr1;
_q_registers_1_wenable1 <= _d_registers_1_wenable1;
_q_registers_1_wdata1 <= _d_registers_1_wdata1;
_q_registers_2_addr1 <= _d_registers_2_addr1;
_q_registers_2_wenable1 <= _d_registers_2_wenable1;
_q_registers_2_wdata1 <= _d_registers_2_wdata1;
_q_index <= _d_index;
  end
end




always @* begin
_d_registers_1_addr1 = _q_registers_1_addr1;
_d_registers_1_wenable1 = _q_registers_1_wenable1;
_d_registers_1_wdata1 = _q_registers_1_wdata1;
_d_registers_2_addr1 = _q_registers_2_addr1;
_d_registers_2_wenable1 = _q_registers_2_wenable1;
_d_registers_2_wdata1 = _q_registers_2_wdata1;
_d_index = _q_index;
// _always_pre
_d_registers_1_wenable1 = 1;
_d_registers_2_wenable1 = 1;
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_writeRegister&&(in_rd!=0)) begin
// __block_5
// __block_7
_d_registers_1_addr1 = in_rd+(in_floatingpoint?32:0);
_d_registers_1_wdata1 = in_result;
_d_registers_2_addr1 = in_rd+(in_floatingpoint?32:0);
_d_registers_2_wdata1 = in_result;
// __block_8
end else begin
// __block_6
end
// __block_9
// __block_10
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of registersWRITE
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_registersREAD #(
parameter REGISTERS_1_ADDR0_WIDTH=1,parameter REGISTERS_1_ADDR0_SIGNED=0,parameter REGISTERS_1_ADDR0_INIT=0,
parameter REGISTERS_1_RDATA0_WIDTH=1,parameter REGISTERS_1_RDATA0_SIGNED=0,parameter REGISTERS_1_RDATA0_INIT=0,
parameter REGISTERS_2_ADDR0_WIDTH=1,parameter REGISTERS_2_ADDR0_SIGNED=0,parameter REGISTERS_2_ADDR0_INIT=0,
parameter REGISTERS_2_RDATA0_WIDTH=1,parameter REGISTERS_2_RDATA0_SIGNED=0,parameter REGISTERS_2_RDATA0_INIT=0
) (
in_rs1,
in_rs2,
in_floatingpoint,
in_registers_1_rdata0,
in_registers_2_rdata0,
out_sourceReg1,
out_sourceReg2,
out_sourceReg2LOW,
out_sourceReg2HIGH,
out_registers_1_addr0,
out_registers_2_addr0,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [4:0] in_rs1;
input  [4:0] in_rs2;
input  [0:0] in_floatingpoint;
input  [REGISTERS_1_RDATA0_WIDTH-1:0] in_registers_1_rdata0;
input  [REGISTERS_2_RDATA0_WIDTH-1:0] in_registers_2_rdata0;
output signed [31:0] out_sourceReg1;
output signed [31:0] out_sourceReg2;
output  [15:0] out_sourceReg2LOW;
output  [15:0] out_sourceReg2HIGH;
output  [REGISTERS_1_ADDR0_WIDTH-1:0] out_registers_1_addr0;
output  [REGISTERS_2_ADDR0_WIDTH-1:0] out_registers_2_addr0;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg signed [31:0] _d_sourceReg1,_q_sourceReg1;
reg signed [31:0] _d_sourceReg2,_q_sourceReg2;
reg  [15:0] _d_sourceReg2LOW,_q_sourceReg2LOW;
reg  [15:0] _d_sourceReg2HIGH,_q_sourceReg2HIGH;
reg  [REGISTERS_1_ADDR0_WIDTH-1:0] _d_registers_1_addr0,_q_registers_1_addr0;
reg  [REGISTERS_2_ADDR0_WIDTH-1:0] _d_registers_2_addr0,_q_registers_2_addr0;
reg  [1:0] _d_index,_q_index;
assign out_sourceReg1 = _d_sourceReg1;
assign out_sourceReg2 = _d_sourceReg2;
assign out_sourceReg2LOW = _d_sourceReg2LOW;
assign out_sourceReg2HIGH = _d_sourceReg2HIGH;
assign out_registers_1_addr0 = _d_registers_1_addr0;
assign out_registers_2_addr0 = _d_registers_2_addr0;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_registers_1_addr0 <= REGISTERS_1_ADDR0_INIT;
_q_registers_2_addr0 <= REGISTERS_2_ADDR0_INIT;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_sourceReg1 <= _d_sourceReg1;
_q_sourceReg2 <= _d_sourceReg2;
_q_sourceReg2LOW <= _d_sourceReg2LOW;
_q_sourceReg2HIGH <= _d_sourceReg2HIGH;
_q_registers_1_addr0 <= _d_registers_1_addr0;
_q_registers_2_addr0 <= _d_registers_2_addr0;
_q_index <= _d_index;
  end
end




always @* begin
_d_sourceReg1 = _q_sourceReg1;
_d_sourceReg2 = _q_sourceReg2;
_d_sourceReg2LOW = _q_sourceReg2LOW;
_d_sourceReg2HIGH = _q_sourceReg2HIGH;
_d_registers_1_addr0 = _q_registers_1_addr0;
_d_registers_2_addr0 = _q_registers_2_addr0;
_d_index = _q_index;
// _always_pre
_d_registers_1_addr0 = in_rs1+(in_floatingpoint?32:0);
_d_registers_2_addr0 = in_rs2+(in_floatingpoint?32:0);
_d_sourceReg1 = in_registers_1_rdata0;
_d_sourceReg2 = in_registers_2_rdata0;
_d_sourceReg2LOW = in_registers_2_rdata0[0+:16];
_d_sourceReg2HIGH = in_registers_2_rdata0[16+:16];
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
// __block_5
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of registersREAD
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_decoder (
in_instruction,
out_opCode,
out_function3,
out_function7,
out_rs1,
out_rs2,
out_rd,
out_immediateValue,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [31:0] in_instruction;
output  [6:0] out_opCode;
output  [2:0] out_function3;
output  [6:0] out_function7;
output  [4:0] out_rs1;
output  [4:0] out_rs2;
output  [4:0] out_rd;
output signed [31:0] out_immediateValue;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [6:0] _d_opCode,_q_opCode;
reg  [2:0] _d_function3,_q_function3;
reg  [6:0] _d_function7,_q_function7;
reg  [4:0] _d_rs1,_q_rs1;
reg  [4:0] _d_rs2,_q_rs2;
reg  [4:0] _d_rd,_q_rd;
reg signed [31:0] _d_immediateValue,_q_immediateValue;
reg  [1:0] _d_index,_q_index;
assign out_opCode = _q_opCode;
assign out_function3 = _q_function3;
assign out_function7 = _q_function7;
assign out_rs1 = _q_rs1;
assign out_rs2 = _q_rs2;
assign out_rd = _q_rd;
assign out_immediateValue = _q_immediateValue;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_opCode <= _d_opCode;
_q_function3 <= _d_function3;
_q_function7 <= _d_function7;
_q_rs1 <= _d_rs1;
_q_rs2 <= _d_rs2;
_q_rd <= _d_rd;
_q_immediateValue <= _d_immediateValue;
_q_index <= _d_index;
  end
end




always @* begin
_d_opCode = _q_opCode;
_d_function3 = _q_function3;
_d_function7 = _q_function7;
_d_rs1 = _q_rs1;
_d_rs2 = _q_rs2;
_d_rd = _q_rd;
_d_immediateValue = _q_immediateValue;
_d_index = _q_index;
// _always_pre
_d_opCode = in_instruction[0+:7];
_d_function3 = in_instruction[12+:3];
_d_function7 = in_instruction[25+:7];
_d_rs1 = in_instruction[15+:5];
_d_rs2 = in_instruction[20+:5];
_d_rd = in_instruction[7+:5];
_d_immediateValue = {in_instruction[31+:1]?20'b11111111111111111111:20'b00000000000000000000,in_instruction[20+:12]};
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
// __block_5
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of decoder
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_addressgenerator (
in_instruction,
in_pc,
in_compressed,
in_sourceReg1,
out_pcPLUS2,
out_nextPC,
out_branchAddress,
out_jumpAddress,
out_AUIPCLUI,
out_storeAddress,
out_storeAddressPLUS2,
out_loadAddress,
out_loadAddressPLUS2,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [31:0] in_instruction;
input  [31:0] in_pc;
input  [0:0] in_compressed;
input signed [31:0] in_sourceReg1;
output  [31:0] out_pcPLUS2;
output  [31:0] out_nextPC;
output  [31:0] out_branchAddress;
output  [31:0] out_jumpAddress;
output  [31:0] out_AUIPCLUI;
output  [31:0] out_storeAddress;
output  [31:0] out_storeAddressPLUS2;
output  [31:0] out_loadAddress;
output  [31:0] out_loadAddressPLUS2;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [6:0] _w_opCode;
wire signed [31:0] _w_immediateValue;

reg  [31:0] _d_pcPLUS2,_q_pcPLUS2;
reg  [31:0] _d_nextPC,_q_nextPC;
reg  [31:0] _d_branchAddress,_q_branchAddress;
reg  [31:0] _d_jumpAddress,_q_jumpAddress;
reg  [31:0] _d_AUIPCLUI,_q_AUIPCLUI;
reg  [31:0] _d_storeAddress,_q_storeAddress;
reg  [31:0] _d_storeAddressPLUS2,_q_storeAddressPLUS2;
reg  [31:0] _d_loadAddress,_q_loadAddress;
reg  [31:0] _d_loadAddressPLUS2,_q_loadAddressPLUS2;
reg  [1:0] _d_index,_q_index;
assign out_pcPLUS2 = _q_pcPLUS2;
assign out_nextPC = _q_nextPC;
assign out_branchAddress = _q_branchAddress;
assign out_jumpAddress = _q_jumpAddress;
assign out_AUIPCLUI = _q_AUIPCLUI;
assign out_storeAddress = _d_storeAddress;
assign out_storeAddressPLUS2 = _d_storeAddressPLUS2;
assign out_loadAddress = _d_loadAddress;
assign out_loadAddressPLUS2 = _d_loadAddressPLUS2;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_pcPLUS2 <= _d_pcPLUS2;
_q_nextPC <= _d_nextPC;
_q_branchAddress <= _d_branchAddress;
_q_jumpAddress <= _d_jumpAddress;
_q_AUIPCLUI <= _d_AUIPCLUI;
_q_storeAddress <= _d_storeAddress;
_q_storeAddressPLUS2 <= _d_storeAddressPLUS2;
_q_loadAddress <= _d_loadAddress;
_q_loadAddressPLUS2 <= _d_loadAddressPLUS2;
_q_index <= _d_index;
  end
end



assign _w_immediateValue = {in_instruction[31+:1]?20'b11111111111111111111:20'b00000000000000000000,in_instruction[20+:12]};
assign _w_opCode = in_instruction[0+:7];

always @* begin
_d_pcPLUS2 = _q_pcPLUS2;
_d_nextPC = _q_nextPC;
_d_branchAddress = _q_branchAddress;
_d_jumpAddress = _q_jumpAddress;
_d_AUIPCLUI = _q_AUIPCLUI;
_d_storeAddress = _q_storeAddress;
_d_storeAddressPLUS2 = _q_storeAddressPLUS2;
_d_loadAddress = _q_loadAddress;
_d_loadAddressPLUS2 = _q_loadAddressPLUS2;
_d_index = _q_index;
// _always_pre
_d_pcPLUS2 = in_pc+2;
_d_nextPC = in_pc+(in_compressed?2:4);
_d_branchAddress = {in_instruction[31+:1]?20'b11111111111111111111:20'b00000000000000000000,in_instruction[7+:1],in_instruction[25+:6],in_instruction[8+:4],1'b0}+in_pc;
_d_jumpAddress = {in_instruction[31+:1]?12'b111111111111:12'b000000000000,in_instruction[12+:8],in_instruction[20+:1],in_instruction[21+:10],1'b0}+in_pc;
_d_AUIPCLUI = {in_instruction[12+:20],12'b0}+(_w_opCode[5+:1]?0:in_pc);
_d_storeAddress = {in_instruction[31+:1]?20'b11111111111111111111:20'b00000000000000000000,in_instruction[25+:7],in_instruction[7+:5]}+in_sourceReg1;
_d_storeAddressPLUS2 = {in_instruction[31+:1]?20'b11111111111111111111:20'b00000000000000000000,in_instruction[25+:7],in_instruction[7+:5]}+in_sourceReg1+2;
_d_loadAddress = _w_immediateValue+in_sourceReg1;
_d_loadAddressPLUS2 = _w_immediateValue+in_sourceReg1+2;
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
// __block_5
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of addressgenerator
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_branchcomparison (
in_opCode,
in_function3,
in_sourceReg1,
in_sourceReg2,
out_takeBranch,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [6:0] in_opCode;
input  [2:0] in_function3;
input signed [31:0] in_sourceReg1;
input signed [31:0] in_sourceReg2;
output  [0:0] out_takeBranch;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [0:0] _d_takeBranch,_q_takeBranch;
reg  [1:0] _d_index,_q_index;
assign out_takeBranch = _d_takeBranch;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_takeBranch <= _d_takeBranch;
_q_index <= _d_index;
  end
end




always @* begin
_d_takeBranch = _q_takeBranch;
_d_index = _q_index;
// _always_pre
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_opCode==7'b1100011) begin
// __block_5
// __block_7
  case (in_function3)
  3'b000: begin
// __block_9_case
// __block_10
_d_takeBranch = (in_sourceReg1==in_sourceReg2)?1:0;
// __block_11
  end
  3'b001: begin
// __block_12_case
// __block_13
_d_takeBranch = (in_sourceReg1!=in_sourceReg2)?1:0;
// __block_14
  end
  3'b100: begin
// __block_15_case
// __block_16
_d_takeBranch = ($signed(in_sourceReg1)<$signed(in_sourceReg2))?1:0;
// __block_17
  end
  3'b101: begin
// __block_18_case
// __block_19
_d_takeBranch = ($signed(in_sourceReg1)>=$signed(in_sourceReg2))?1:0;
// __block_20
  end
  3'b110: begin
// __block_21_case
// __block_22
_d_takeBranch = ($unsigned(in_sourceReg1)<$unsigned(in_sourceReg2))?1:0;
// __block_23
  end
  3'b111: begin
// __block_24_case
// __block_25
_d_takeBranch = ($unsigned(in_sourceReg1)>=$unsigned(in_sourceReg2))?1:0;
// __block_26
  end
  default: begin
// __block_27_case
// __block_28
_d_takeBranch = 0;
// __block_29
  end
endcase
// __block_8
// __block_30
end else begin
// __block_6
end
// __block_31
// __block_32
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of branchcomparison
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_aluI (
in_instruction,
in_sourceReg1,
in_sourceReg2,
in_start,
out_busy,
out_result,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [31:0] in_instruction;
input signed [31:0] in_sourceReg1;
input signed [31:0] in_sourceReg2;
input  [0:0] in_start;
output  [0:0] out_busy;
output signed [31:0] out_result;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [6:0] _w_opCode;
wire  [2:0] _w_function3;
wire  [6:0] _w_function7;
wire signed [31:0] _w_immediateValue;
wire signed [31:0] _w_shiftRIGHTA;
wire signed [31:0] _w_shiftRIGHTL;
wire  [0:0] _w_SLT;
wire  [0:0] _w_SLTI;
wire  [0:0] _w_SLTU;
wire  [0:0] _w_SLTUI;

reg  [0:0] _d_busy,_q_busy;
reg signed [31:0] _d_result,_q_result;
reg  [1:0] _d_index,_q_index;
assign out_busy = _q_busy;
assign out_result = _q_result;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_busy <= _d_busy;
_q_result <= _d_result;
_q_index <= _d_index;
  end
end



assign _w_SLT = $signed(in_sourceReg1)<$signed(in_sourceReg2)?1:0;
assign _w_shiftRIGHTL = $unsigned(in_sourceReg1)>>(_w_opCode[5+:1]?in_sourceReg2[0+:5]:in_instruction[20+:5]);
assign _w_shiftRIGHTA = $signed(in_sourceReg1)>>>(_w_opCode[5+:1]?in_sourceReg2[0+:5]:in_instruction[20+:5]);
assign _w_SLTUI = (_w_immediateValue==1)?((in_sourceReg1==0)?1:0):(($unsigned(in_sourceReg1)<$unsigned(_w_immediateValue))?1:0);
assign _w_immediateValue = {in_instruction[31+:1]?20'b11111111111111111111:20'b00000000000000000000,in_instruction[20+:12]};
assign _w_SLTU = (in_instruction[15+:5]==0)?((in_sourceReg2!=0)?1:0):(($unsigned(in_sourceReg1)<$unsigned(in_sourceReg2))?1:0);
assign _w_SLTI = $signed(in_sourceReg1)<$signed(_w_immediateValue)?1:0;
assign _w_function7 = in_instruction[25+:7];
assign _w_function3 = in_instruction[12+:3];
assign _w_opCode = in_instruction[0+:7];

always @* begin
_d_busy = _q_busy;
_d_result = _q_result;
_d_index = _q_index;
// _always_pre
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
  case (_w_function3)
  3'b000: begin
// __block_6_case
// __block_7
_d_result = in_sourceReg1+(_w_opCode[5+:1]?(_w_function7[5+:1]?-(in_sourceReg2):in_sourceReg2):_w_immediateValue);
// __block_8
  end
  3'b001: begin
// __block_9_case
// __block_10
_d_result = $unsigned(in_sourceReg1)<<(_w_opCode[5+:1]?in_sourceReg2[0+:5]:in_instruction[20+:5]);
// __block_11
  end
  3'b010: begin
// __block_12_case
// __block_13
_d_result = (_w_opCode[5+:1]?_w_SLT:_w_SLTI)?32'b1:32'b0;
// __block_14
  end
  3'b011: begin
// __block_15_case
// __block_16
_d_result = (_w_opCode[5+:1]?_w_SLTU:_w_SLTUI)?32'b1:32'b0;
// __block_17
  end
  3'b100: begin
// __block_18_case
// __block_19
_d_result = in_sourceReg1^(_w_opCode[5+:1]?in_sourceReg2:_w_immediateValue);
// __block_20
  end
  3'b101: begin
// __block_21_case
// __block_22
_d_result = _w_function7[5+:1]?_w_shiftRIGHTA:_w_shiftRIGHTL;
// __block_23
  end
  3'b110: begin
// __block_24_case
// __block_25
_d_result = in_sourceReg1|(_w_opCode[5+:1]?in_sourceReg2:_w_immediateValue);
// __block_26
  end
  3'b111: begin
// __block_27_case
// __block_28
_d_result = in_sourceReg1&(_w_opCode[5+:1]?in_sourceReg2:_w_immediateValue);
// __block_29
  end
endcase
// __block_5
// __block_30
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of aluI
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_aluM (
in_function3,
in_sourceReg1,
in_sourceReg2,
in_start,
out_busy,
out_result,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [2:0] in_function3;
input signed [31:0] in_sourceReg1;
input signed [31:0] in_sourceReg2;
input  [0:0] in_start;
output  [0:0] out_busy;
output signed [31:0] out_result;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [0:0] _w_dividerunit_active;
wire  [31:0] _w_dividerunit_result;
wire _w_dividerunit_done;
wire  [0:0] _w_multiplicationuint_active;
wire  [31:0] _w_multiplicationuint_result;
wire _w_multiplicationuint_done;

reg  [0:0] _d_active;
reg  [0:0] _q_active;
reg  [0:0] _d_busy,_q_busy;
reg signed [31:0] _d_result,_q_result;
reg  [0:0] _d_dividerunit_start,_q_dividerunit_start;
reg  [0:0] _d_multiplicationuint_start,_q_multiplicationuint_start;
reg  [2:0] _d_index,_q_index;
reg  _dividerunit_run;
reg  _multiplicationuint_run;
assign out_busy = _q_busy;
assign out_result = _q_result;
assign out_done = (_q_index == 7);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_active <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_active <= _d_active;
_q_busy <= _d_busy;
_q_result <= _d_result;
_q_index <= _d_index;
  end
_q_dividerunit_start <= _d_dividerunit_start;
_q_multiplicationuint_start <= _d_multiplicationuint_start;
end

M_divideremainder dividerunit (
.in_function3(in_function3),
.in_dividend(in_sourceReg1),
.in_divisor(in_sourceReg2),
.in_start(_d_dividerunit_start),
.out_active(_w_dividerunit_active),
.out_result(_w_dividerunit_result),
.out_done(_w_dividerunit_done),
.in_run(_dividerunit_run),
.reset(reset),
.clock(clock)
);
M_multiplicationDSP multiplicationuint (
.in_function3(in_function3),
.in_factor_1(in_sourceReg1),
.in_factor_2(in_sourceReg2),
.in_start(_d_multiplicationuint_start),
.out_active(_w_multiplicationuint_active),
.out_result(_w_multiplicationuint_result),
.out_done(_w_multiplicationuint_done),
.in_run(_multiplicationuint_run),
.reset(reset),
.clock(clock)
);



always @* begin
_d_active = _q_active;
_d_busy = _q_busy;
_d_result = _q_result;
_d_dividerunit_start = _q_dividerunit_start;
_d_multiplicationuint_start = _q_multiplicationuint_start;
_d_index = _q_index;
_dividerunit_run = 1;
_multiplicationuint_run = 1;
// _always_pre
_d_busy = in_start?1:_q_active;
_d_dividerunit_start = 0;
_d_multiplicationuint_start = 0;
_d_index = 7;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_active = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_start) begin
// __block_5
// __block_7
  case (in_function3[2+:1])
  1'b0: begin
// __block_9_case
// __block_10
_d_active = 1;
_d_multiplicationuint_start = 1;
_d_index = 3;
  end
  1'b1: begin
// __block_17_case
// __block_18
_d_active = 1;
_d_dividerunit_start = 1;
_d_index = 4;
  end
endcase
end else begin
// __block_6
_d_index = 1;
end
end else begin
_d_index = 2;
end
end
3: begin
// __while__block_11
if (_w_multiplicationuint_active) begin
// __block_12
// __block_14
// __block_15
_d_index = 3;
end else begin
_d_index = 5;
end
end
4: begin
// __while__block_19
if (_w_dividerunit_active) begin
// __block_20
// __block_22
// __block_23
_d_index = 4;
end else begin
_d_index = 6;
end
end
2: begin
// __block_3
_d_index = 7;
end
5: begin
// __block_13
_d_result = _w_multiplicationuint_result;
_d_active = 0;
// __block_16
_d_index = 1;
end
6: begin
// __block_21
_d_result = _w_dividerunit_result;
_d_active = 0;
// __block_24
_d_index = 1;
end
7: begin // end of aluM
end
default: begin 
_d_index = 7;
 end
endcase
end
endmodule


module M_compressedexpansion (
in_instruction16,
out_instruction32,
out_compressed,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [15:0] in_instruction16;
output  [31:0] out_instruction32;
output  [0:0] out_compressed;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [31:0] _d_instruction32,_q_instruction32;
reg  [0:0] _d_compressed,_q_compressed;
reg  [1:0] _d_index,_q_index;
assign out_instruction32 = _d_instruction32;
assign out_compressed = _d_compressed;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_instruction32 <= _d_instruction32;
_q_compressed <= _d_compressed;
_q_index <= _d_index;
  end
end




always @* begin
_d_instruction32 = _q_instruction32;
_d_compressed = _q_compressed;
_d_index = _q_index;
// _always_pre
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
  case (in_instruction16[0+:2])
  2'b00: begin
// __block_6_case
// __block_7
_d_compressed = 1;
  case (in_instruction16[13+:3])
  3'b000: begin
// __block_9_case
// __block_10
_d_instruction32 = {2'b0,in_instruction16[7+:4],in_instruction16[11+:2],in_instruction16[5+:1],in_instruction16[6+:1],2'b00,5'h2,3'b000,{2'b01,in_instruction16[2+:3]},7'b0010011};
// __block_11
  end
  3'b001: begin
// __block_12_case
// __block_13
// __block_14
  end
  3'b010: begin
// __block_15_case
// __block_16
_d_instruction32 = {5'b0,in_instruction16[5+:1],in_instruction16[10+:3],in_instruction16[6+:1],2'b00,{2'b01,in_instruction16[7+:3]},3'b010,{2'b01,in_instruction16[2+:3]},7'b0000011};
// __block_17
  end
  3'b011: begin
// __block_18_case
// __block_19
// __block_20
  end
  3'b100: begin
// __block_21_case
// __block_22
// __block_23
  end
  3'b101: begin
// __block_24_case
// __block_25
// __block_26
  end
  3'b110: begin
// __block_27_case
// __block_28
_d_instruction32 = {5'b0,in_instruction16[5+:1],in_instruction16[12+:1],{2'b01,in_instruction16[2+:3]},{2'b01,in_instruction16[7+:3]},3'b010,in_instruction16[10+:2],in_instruction16[6+:1],2'b0,7'b0100011};
// __block_29
  end
  3'b111: begin
// __block_30_case
// __block_31
// __block_32
  end
endcase
// __block_8
// __block_33
  end
  2'b01: begin
// __block_34_case
// __block_35
_d_compressed = 1;
  case (in_instruction16[13+:3])
  3'b000: begin
// __block_37_case
// __block_38
_d_instruction32 = {in_instruction16[12+:1]?7'b1111111:7'b0000000,in_instruction16[2+:5],in_instruction16[7+:5],3'b000,in_instruction16[7+:5],7'b0010011};
// __block_39
  end
  3'b001: begin
// __block_40_case
// __block_41
_d_instruction32 = {in_instruction16[12+:1],in_instruction16[8+:1],in_instruction16[9+:2],in_instruction16[6+:1],in_instruction16[7+:1],in_instruction16[2+:1],in_instruction16[11+:1],in_instruction16[3+:3],in_instruction16[12+:1]?9'b111111111:9'b000000000,5'h1,7'b1101111};
// __block_42
  end
  3'b010: begin
// __block_43_case
// __block_44
_d_instruction32 = {in_instruction16[12+:1]?7'b1111111:7'b0000000,in_instruction16[2+:5],5'h0,3'b000,in_instruction16[7+:5],7'b0010011};
// __block_45
  end
  3'b011: begin
// __block_46_case
// __block_47
if ((in_instruction16[7+:5]!=0)&&(in_instruction16[7+:5]!=2)) begin
// __block_48
// __block_50
_d_instruction32 = {in_instruction16[12+:1]?15'b111111111111111:15'b000000000000000,in_instruction16[2+:5],in_instruction16[7+:5],7'b0110111};
// __block_51
end else begin
// __block_49
// __block_52
_d_instruction32 = {in_instruction16[12+:1]?3'b111:3'b000,in_instruction16[3+:2],in_instruction16[5+:1],in_instruction16[2+:1],in_instruction16[6+:1],4'b0000,5'h2,3'b000,5'h2,7'b0010011};
// __block_53
end
// __block_54
// __block_55
  end
  3'b100: begin
// __block_56_case
// __block_57
  case (in_instruction16[10+:2])
  2'b00: begin
// __block_59_case
// __block_60
_d_instruction32 = {7'b0000000,in_instruction16[2+:5],{2'b01,in_instruction16[7+:3]},3'b101,{2'b01,in_instruction16[7+:3]},7'b0010011};
// __block_61
  end
  2'b01: begin
// __block_62_case
// __block_63
_d_instruction32 = {7'b0100000,in_instruction16[2+:5],{2'b01,in_instruction16[7+:3]},3'b101,{2'b01,in_instruction16[7+:3]},7'b0010011};
// __block_64
  end
  2'b10: begin
// __block_65_case
// __block_66
_d_instruction32 = {in_instruction16[12+:1]?7'b1111111:7'b0000000,in_instruction16[2+:5],{2'b01,in_instruction16[7+:3]},3'b111,{2'b01,in_instruction16[7+:3]},7'b0010011};
// __block_67
  end
  2'b11: begin
// __block_68_case
// __block_69
  case (in_instruction16[5+:2])
  2'b00: begin
// __block_71_case
// __block_72
_d_instruction32 = {7'b0100000,{2'b01,in_instruction16[2+:3]},{2'b01,in_instruction16[7+:3]},3'b000,{2'b01,in_instruction16[7+:3]},7'b0110011};
// __block_73
  end
  2'b01: begin
// __block_74_case
// __block_75
_d_instruction32 = {7'b0000000,{2'b01,in_instruction16[2+:3]},{2'b01,in_instruction16[7+:3]},3'b100,{2'b01,in_instruction16[7+:3]},7'b0110011};
// __block_76
  end
  2'b10: begin
// __block_77_case
// __block_78
_d_instruction32 = {7'b0000000,{2'b01,in_instruction16[2+:3]},{2'b01,in_instruction16[7+:3]},3'b110,{2'b01,in_instruction16[7+:3]},7'b0110011};
// __block_79
  end
  2'b11: begin
// __block_80_case
// __block_81
_d_instruction32 = {7'b0000000,{2'b01,in_instruction16[2+:3]},{2'b01,in_instruction16[7+:3]},3'b111,{2'b01,in_instruction16[7+:3]},7'b0110011};
// __block_82
  end
endcase
// __block_70
// __block_83
  end
endcase
// __block_58
// __block_84
  end
  3'b101: begin
// __block_85_case
// __block_86
_d_instruction32 = {in_instruction16[12+:1],in_instruction16[8+:1],in_instruction16[9+:2],in_instruction16[6+:1],in_instruction16[7+:1],in_instruction16[2+:1],in_instruction16[11+:1],in_instruction16[3+:3],in_instruction16[12+:1]?9'b111111111:9'b000000000,5'h0,7'b1101111};
// __block_87
  end
  3'b110: begin
// __block_88_case
// __block_89
_d_instruction32 = {in_instruction16[12+:1]?4'b1111:4'b0000,in_instruction16[5+:2],in_instruction16[2+:1],5'h0,{2'b01,in_instruction16[7+:3]},3'b000,in_instruction16[10+:2],in_instruction16[3+:2],in_instruction16[12+:1],7'b1100011};
// __block_90
  end
  3'b111: begin
// __block_91_case
// __block_92
_d_instruction32 = {in_instruction16[12+:1]?4'b1111:4'b0000,in_instruction16[5+:2],in_instruction16[2+:1],5'h0,{2'b01,in_instruction16[7+:3]},3'b001,in_instruction16[10+:2],in_instruction16[3+:2],in_instruction16[12+:1],7'b1100011};
// __block_93
  end
endcase
// __block_36
// __block_94
  end
  2'b10: begin
// __block_95_case
// __block_96
_d_compressed = 1;
  case (in_instruction16[13+:3])
  3'b000: begin
// __block_98_case
// __block_99
_d_instruction32 = {7'b0000000,in_instruction16[2+:5],in_instruction16[7+:5],3'b001,in_instruction16[7+:5],7'b0010011};
// __block_100
  end
  3'b001: begin
// __block_101_case
// __block_102
// __block_103
  end
  3'b010: begin
// __block_104_case
// __block_105
_d_instruction32 = {4'b0,in_instruction16[2+:2],in_instruction16[12+:1],in_instruction16[4+:3],2'b0,5'h2,3'b010,in_instruction16[7+:5],7'b0000011};
// __block_106
  end
  3'b011: begin
// __block_107_case
// __block_108
// __block_109
  end
  3'b100: begin
// __block_110_case
// __block_111
  case (in_instruction16[12+:1])
  1'b0: begin
// __block_113_case
// __block_114
if (in_instruction16[2+:5]==0) begin
// __block_115
// __block_117
_d_instruction32 = {12'b0,in_instruction16[7+:5],3'b000,5'h0,7'b1100111};
// __block_118
end else begin
// __block_116
// __block_119
_d_instruction32 = {7'b0000000,in_instruction16[2+:5],5'h0,3'b000,in_instruction16[7+:5],7'b0110011};
// __block_120
end
// __block_121
// __block_122
  end
  1'b1: begin
// __block_123_case
// __block_124
if (in_instruction16[2+:5]==0) begin
// __block_125
// __block_127
_d_instruction32 = {12'b0,in_instruction16[7+:5],3'b000,5'h1,7'b1100111};
// __block_128
end else begin
// __block_126
// __block_129
_d_instruction32 = {7'b0000000,in_instruction16[2+:5],in_instruction16[7+:5],3'b000,in_instruction16[7+:5],7'b0110011};
// __block_130
end
// __block_131
// __block_132
  end
endcase
// __block_112
// __block_133
  end
  3'b101: begin
// __block_134_case
// __block_135
// __block_136
  end
  3'b110: begin
// __block_137_case
// __block_138
_d_instruction32 = {4'b0,in_instruction16[7+:2],in_instruction16[12+:1],in_instruction16[2+:5],5'h2,3'b010,in_instruction16[9+:3],2'b00,7'b0100011};
// __block_139
  end
  3'b111: begin
// __block_140_case
// __block_141
// __block_142
  end
endcase
// __block_97
// __block_143
  end
  2'b11: begin
// __block_144_case
// __block_145
_d_compressed = 0;
_d_instruction32 = {16'h0000,in_instruction16};
// __block_146
  end
endcase
// __block_5
// __block_147
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of compressedexpansion
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_CSRblock (
in_instruction,
in_incCSRinstret,
out_result,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [31:0] in_instruction;
input  [0:0] in_incCSRinstret;
output  [31:0] out_result;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [63:0] _d_CSRcycletime;
reg  [63:0] _q_CSRcycletime;
reg  [63:0] _d_CSRinstret;
reg  [63:0] _q_CSRinstret;
reg  [31:0] _d_result,_q_result;
reg  [1:0] _d_index,_q_index;
assign out_result = _q_result;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_CSRcycletime <= 0;
_q_CSRinstret <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_CSRcycletime <= _d_CSRcycletime;
_q_CSRinstret <= _d_CSRinstret;
_q_result <= _d_result;
_q_index <= _d_index;
  end
end




always @* begin
_d_CSRcycletime = _q_CSRcycletime;
_d_CSRinstret = _q_CSRinstret;
_d_result = _q_result;
_d_index = _q_index;
// _always_pre
_d_CSRcycletime = _q_CSRcycletime+1;
_d_CSRinstret = _q_CSRinstret+(in_incCSRinstret?1:0);
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_CSRcycletime = 0;
_d_CSRinstret = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if ((in_instruction[15+:5]==0)&&(in_instruction[12+:3]==3'b010)) begin
// __block_5
// __block_7
  case (in_instruction[20+:12])
  12'hc00: begin
// __block_9_case
// __block_10
_d_result = _d_CSRcycletime[0+:32];
// __block_11
  end
  12'hc80: begin
// __block_12_case
// __block_13
_d_result = _d_CSRcycletime[32+:32];
// __block_14
  end
  12'hc01: begin
// __block_15_case
// __block_16
_d_result = _d_CSRcycletime[0+:32];
// __block_17
  end
  12'hc81: begin
// __block_18_case
// __block_19
_d_result = _d_CSRcycletime[32+:32];
// __block_20
  end
  12'hc02: begin
// __block_21_case
// __block_22
_d_result = _d_CSRinstret[0+:32];
// __block_23
  end
  12'hc82: begin
// __block_24_case
// __block_25
_d_result = _d_CSRinstret[32+:32];
// __block_26
  end
  default: begin
// __block_27_case
// __block_28
_d_result = 0;
// __block_29
  end
endcase
// __block_8
// __block_30
end else begin
// __block_6
// __block_31
_d_result = 0;
// __block_32
end
// __block_33
// __block_34
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of CSRblock
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_divideremainder (
in_function3,
in_dividend,
in_divisor,
in_start,
out_active,
out_result,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [2:0] in_function3;
input  [31:0] in_dividend;
input  [31:0] in_divisor;
input  [0:0] in_start;
output  [0:0] out_active;
output  [31:0] out_result;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [31:0] _w_dividend_copy;
wire  [31:0] _w_divisor_copy;
wire  [0:0] _w_resultsign;

reg  [31:0] _d_quotient;
reg  [31:0] _q_quotient;
reg  [31:0] _d_remainder;
reg  [31:0] _q_remainder;
reg  [5:0] _d_bit;
reg  [5:0] _q_bit;
reg  [0:0] _d_busy;
reg  [0:0] _q_busy;
reg  [0:0] _d_active,_q_active;
reg  [31:0] _d_result,_q_result;
reg  [2:0] _d_index,_q_index;
assign out_active = _q_active;
assign out_result = _q_result;
assign out_done = (_q_index == 6);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_busy <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_quotient <= _d_quotient;
_q_remainder <= _d_remainder;
_q_bit <= _d_bit;
_q_busy <= _d_busy;
_q_active <= _d_active;
_q_result <= _d_result;
_q_index <= _d_index;
  end
end



assign _w_resultsign = ~in_function3[0+:1]?in_dividend[31+:1]!=in_divisor[31+:1]:0;
assign _w_divisor_copy = ~in_function3[0+:1]?(in_divisor[31+:1]?-in_divisor:in_divisor):in_divisor;
assign _w_dividend_copy = ~in_function3[0+:1]?(in_dividend[31+:1]?-in_dividend:in_dividend):in_dividend;

always @* begin
_d_quotient = _q_quotient;
_d_remainder = _q_remainder;
_d_bit = _q_bit;
_d_busy = _q_busy;
_d_active = _q_active;
_d_result = _q_result;
_d_index = _q_index;
// _always_pre
_d_active = in_start?1:_q_busy;
_d_result = in_function3[1+:1]?_q_remainder:(_w_resultsign?-_q_quotient:_q_quotient);
_d_index = 6;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_busy = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_start) begin
// __block_5
// __block_7
_d_busy = 1;
_d_bit = 31;
if (in_divisor==0) begin
// __block_8
// __block_10
_d_quotient = 32'hffffffff;
_d_remainder = in_dividend;
_d_busy = 0;
// __block_11
_d_index = 1;
end else begin
// __block_9
// __block_12
_d_quotient = 0;
_d_remainder = 0;
_d_index = 3;
end
end else begin
// __block_6
_d_index = 1;
end
end else begin
_d_index = 2;
end
end
3: begin
// __block_13
_d_index = 4;
end
2: begin
// __block_3
_d_index = 6;
end
4: begin
// __while__block_14
if (_q_bit!=63) begin
// __block_15
// __block_17
if ($unsigned({_q_remainder[0+:31],_w_dividend_copy[_q_bit+:1]})>=$unsigned(_w_divisor_copy)) begin
// __block_18
// __block_20
_d_remainder = $unsigned({_q_remainder[0+:31],_w_dividend_copy[_q_bit+:1]})-$unsigned(_w_divisor_copy);
_d_quotient[_q_bit+:1] = 1;
// __block_21
end else begin
// __block_19
// __block_22
_d_remainder = {_q_remainder[0+:31],_w_dividend_copy[_q_bit+:1]};
// __block_23
end
// __block_24
_d_bit = _q_bit-1;
// __block_25
_d_index = 4;
end else begin
_d_index = 5;
end
end
5: begin
// __block_26
_d_busy = 0;
// __block_27
_d_index = 1;
end
6: begin // end of divideremainder
end
default: begin 
_d_index = 6;
 end
endcase
end
endmodule


module M_multiplicationDSP (
in_function3,
in_factor_1,
in_factor_2,
in_start,
out_active,
out_result,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [2:0] in_function3;
input  [31:0] in_factor_1;
input  [31:0] in_factor_2;
input  [0:0] in_start;
output  [0:0] out_active;
output  [31:0] out_result;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [31:0] _w_factor_1_copy;
wire  [31:0] _w_factor_2_copy;
wire  [17:0] _w_A;
wire  [17:0] _w_B;
wire  [17:0] _w_C;
wire  [17:0] _w_D;
wire  [1:0] _w_dosigned;
wire  [0:0] _w_resultsign;

reg  [63:0] _d_product;
reg  [63:0] _q_product;
reg  [0:0] _d_busy;
reg  [0:0] _q_busy;
reg  [0:0] _d_active,_q_active;
reg  [31:0] _d_result,_q_result;
reg  [2:0] _d_index,_q_index;
assign out_active = _q_active;
assign out_result = _q_result;
assign out_done = (_q_index == 6);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_busy <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_product <= _d_product;
_q_busy <= _d_busy;
_q_active <= _d_active;
_q_result <= _d_result;
_q_index <= _d_index;
  end
end



assign _w_B = {2'b0,_w_factor_1_copy[0+:16]};
assign _w_dosigned = in_function3[1+:1]?(in_function3[0+:1]?0:2):1;
assign _w_D = {2'b0,_w_factor_2_copy[0+:16]};
assign _w_C = {2'b0,_w_factor_2_copy[16+:16]};
assign _w_A = {2'b0,_w_factor_1_copy[16+:16]};
assign _w_resultsign = (_w_dosigned==0)?0:((_w_dosigned==1)?(in_factor_1[31+:1]!=in_factor_2[31+:1]):in_factor_1[31+:1]);
assign _w_factor_2_copy = (_w_dosigned!=1)?in_factor_2:((in_factor_2[31+:1])?-in_factor_2:in_factor_2);
assign _w_factor_1_copy = (_w_dosigned==0)?in_factor_1:((in_factor_1[31+:1])?-in_factor_1:in_factor_1);

always @* begin
_d_product = _q_product;
_d_busy = _q_busy;
_d_active = _q_active;
_d_result = _q_result;
_d_index = _q_index;
// _always_pre
_d_active = in_start?1:_q_busy;
_d_result = (in_function3==0)?_q_product[0+:32]:_q_product[32+:32];
_d_index = 6;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_d_busy = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_start) begin
// __block_5
// __block_7
_d_busy = 1;
_d_index = 3;
end else begin
// __block_6
_d_index = 1;
end
end else begin
_d_index = 2;
end
end
3: begin
// __block_8
_d_product = _w_D*_w_B+{_w_D*_w_A,16'b0}+{_w_C*_w_B,16'b0}+{_w_C*_w_A,32'b0};
_d_index = 4;
end
2: begin
// __block_3
_d_index = 6;
end
4: begin
// __block_9
_d_product = _w_resultsign?-_q_product:_q_product;
_d_index = 5;
end
5: begin
// __block_10
_d_busy = 0;
// __block_11
_d_index = 1;
end
6: begin // end of multiplicationDSP
end
default: begin 
_d_index = 6;
 end
endcase
end
endmodule


module M_signextender8 (
in_function3,
in_nosign,
out_withsign,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [2:0] in_function3;
input  [7:0] in_nosign;
output  [31:0] out_withsign;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [31:0] _d_withsign,_q_withsign;
reg  [1:0] _d_index,_q_index;
assign out_withsign = _d_withsign;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_withsign <= _d_withsign;
_q_index <= _d_index;
  end
end




always @* begin
_d_withsign = _q_withsign;
_d_index = _q_index;
// _always_pre
_d_withsign = {((in_nosign[7+:1]&~in_function3[2+:1])?24'hffffff:24'h000000),in_nosign[0+:8]};
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
// __block_5
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of signextender8
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_signextender16 (
in_function3,
in_nosign,
out_withsign,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [2:0] in_function3;
input  [15:0] in_nosign;
output  [31:0] out_withsign;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [31:0] _d_withsign,_q_withsign;
reg  [1:0] _d_index,_q_index;
assign out_withsign = _d_withsign;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_withsign <= _d_withsign;
_q_index <= _d_index;
  end
end




always @* begin
_d_withsign = _q_withsign;
_d_index = _q_index;
// _always_pre
_d_withsign = {(in_nosign[15+:1]&~in_function3[2+:1])?16'hffff:16'h0000,in_nosign};
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
// __block_5
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of signextender16
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_halfhalfword (
in_HIGH,
in_LOW,
out_HIGHLOW,
out_ZEROLOW,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [15:0] in_HIGH;
input  [15:0] in_LOW;
output signed [31:0] out_HIGHLOW;
output signed [31:0] out_ZEROLOW;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg signed [31:0] _d_HIGHLOW,_q_HIGHLOW;
reg signed [31:0] _d_ZEROLOW,_q_ZEROLOW;
reg  [1:0] _d_index,_q_index;
assign out_HIGHLOW = _d_HIGHLOW;
assign out_ZEROLOW = _d_ZEROLOW;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_HIGHLOW <= _d_HIGHLOW;
_q_ZEROLOW <= _d_ZEROLOW;
_q_index <= _d_index;
  end
end




always @* begin
_d_HIGHLOW = _q_HIGHLOW;
_d_ZEROLOW = _q_ZEROLOW;
_d_index = _q_index;
// _always_pre
_d_HIGHLOW = {in_HIGH,in_LOW};
_d_ZEROLOW = {16'b0,in_LOW};
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
// __block_5
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of halfhalfword
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_main (
in_btns,
in_uart_rx,
in_sd_miso,
out_leds,
out_gpdi_dp,
out_gpdi_dn,
out_uart_tx,
out_audio_l,
out_audio_r,
out_sd_clk,
out_sd_mosi,
out_sd_csn,
out_sdram_cle,
out_sdram_dqm,
out_sdram_cs,
out_sdram_we,
out_sdram_cas,
out_sdram_ras,
out_sdram_ba,
out_sdram_a,
out_sdram_clk,
inout_sdram_dq,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [6:0] in_btns;
input  [0:0] in_uart_rx;
input  [0:0] in_sd_miso;
output  [7:0] out_leds;
output  [3:0] out_gpdi_dp;
output  [3:0] out_gpdi_dn;
output  [0:0] out_uart_tx;
output  [3:0] out_audio_l;
output  [3:0] out_audio_r;
output  [0:0] out_sd_clk;
output  [0:0] out_sd_mosi;
output  [0:0] out_sd_csn;
output  [0:0] out_sdram_cle;
output  [1:0] out_sdram_dqm;
output  [0:0] out_sdram_cs;
output  [0:0] out_sdram_we;
output  [0:0] out_sdram_cas;
output  [0:0] out_sdram_ras;
output  [1:0] out_sdram_ba;
output  [12:0] out_sdram_a;
output  [0:0] out_sdram_clk;
inout  [15:0] inout_sdram_dq;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = _w_clk_gen_CPU_clkMEMORY;
wire _w_clk_gen_AUX_clkIO;
wire _w_clk_gen_AUX_clkVIDEO;
wire _w_clk_gen_AUX_clkSDRAM;
wire _w_clk_gen_AUX_clkSDRAMcontrol;
wire _w_clk_gen_AUX_locked;
wire _w_clk_gen_CPU_clkCPU;
wire _w_clk_gen_CPU_clkCOPRO;
wire _w_clk_gen_CPU_clkMEMORY;
wire _w_clk_gen_CPU_locked;
wire  [0:0] _w_video_rstcond_out;
wire  [0:0] _w_sdram_rstcond_out;
wire  [9:0] _w_video_x;
wire  [9:0] _w_video_y;
wire  [0:0] _w_video_active;
wire  [0:0] _w_video_vblank;
wire  [3:0] _w_video_gpdi_dp;
wire  [3:0] _w_video_gpdi_dn;
wire  [15:0] _w_sdaccess_sdh_data_out;
wire  [0:0] _w_sdaccess_sdh_done;
wire  [25:0] _w_sdaccess_sd_addr;
wire  [0:0] _w_sdaccess_sd_rw;
wire  [15:0] _w_sdaccess_sd_data_in;
wire  [0:0] _w_sdaccess_sd_in_valid;
wire  [0:0] _w_sdram32MB_sdram_cle;
wire  [0:0] _w_sdram32MB_sdram_cs;
wire  [0:0] _w_sdram32MB_sdram_cas;
wire  [0:0] _w_sdram32MB_sdram_ras;
wire  [0:0] _w_sdram32MB_sdram_we;
wire  [1:0] _w_sdram32MB_sdram_dqm;
wire  [1:0] _w_sdram32MB_sdram_ba;
wire  [12:0] _w_sdram32MB_sdram_a;
wire  [15:0] _w_sdram32MB_sd_data_out;
wire  [0:0] _w_sdram32MB_sd_done;
wire _w_sdram32MB_done;
wire  [25:0] _w_sdram_sio_addr;
wire  [0:0] _w_sdram_sio_rw;
wire  [15:0] _w_sdram_sio_data_in;
wire  [0:0] _w_sdram_sio_in_valid;
wire  [15:0] _w_sdram_readdata;
wire  [0:0] _w_sdram_busy;
wire _w_sdram_done;
wire  [15:0] _w_ram_readdata;
wire _w_ram_done;
wire  [7:0] _w_IO_Map_leds;
wire  [0:0] _w_IO_Map_uart_tx;
wire  [3:0] _w_IO_Map_audio_l;
wire  [3:0] _w_IO_Map_audio_r;
wire  [0:0] _w_IO_Map_sd_clk;
wire  [0:0] _w_IO_Map_sd_mosi;
wire  [0:0] _w_IO_Map_sd_csn;
wire  [7:0] _w_IO_Map_video_r;
wire  [7:0] _w_IO_Map_video_g;
wire  [7:0] _w_IO_Map_video_b;
wire  [31:0] _w_IO_Map_readData;
wire _w_IO_Map_done;
wire  [2:0] _w_CPU_function3;
wire  [31:0] _w_CPU_address;
wire  [15:0] _w_CPU_writedata;
wire  [0:0] _w_CPU_writememory;
wire  [0:0] _w_CPU_readmemory;
wire  [0:0] _w_CPU_Icacheflag;
wire _w_CPU_done;

reg  [0:0] _d_sdram_writeflag,_q_sdram_writeflag;
reg  [0:0] _d_sdram_readflag,_q_sdram_readflag;
reg  [0:0] _d_ram_writeflag,_q_ram_writeflag;
reg  [0:0] _d_ram_readflag,_q_ram_readflag;
reg  [0:0] _d_IO_Map_memoryWrite,_q_IO_Map_memoryWrite;
reg  [0:0] _d_IO_Map_memoryRead,_q_IO_Map_memoryRead;
reg  [15:0] _d_CPU_readdata,_q_CPU_readdata;
reg  [0:0] _d_CPU_memorybusy,_q_CPU_memorybusy;
reg  [1:0] _d_index,_q_index;
reg  _sdram32MB_run;
reg  _sdram_run;
reg  _ram_run;
reg  _IO_Map_run;
reg  _CPU_run;
assign out_leds = _w_IO_Map_leds;
assign out_gpdi_dp = _w_video_gpdi_dp;
assign out_gpdi_dn = _w_video_gpdi_dn;
assign out_uart_tx = _w_IO_Map_uart_tx;
assign out_audio_l = _w_IO_Map_audio_l;
assign out_audio_r = _w_IO_Map_audio_r;
assign out_sd_clk = _w_IO_Map_sd_clk;
assign out_sd_mosi = _w_IO_Map_sd_mosi;
assign out_sd_csn = _w_IO_Map_sd_csn;
assign out_sdram_cle = _w_sdram32MB_sdram_cle;
assign out_sdram_dqm = _w_sdram32MB_sdram_dqm;
assign out_sdram_cs = _w_sdram32MB_sdram_cs;
assign out_sdram_we = _w_sdram32MB_sdram_we;
assign out_sdram_cas = _w_sdram32MB_sdram_cas;
assign out_sdram_ras = _w_sdram32MB_sdram_ras;
assign out_sdram_ba = _w_sdram32MB_sdram_ba;
assign out_sdram_a = _w_sdram32MB_sdram_a;
assign out_sdram_clk = _w_clk_gen_AUX_clkSDRAMcontrol;
assign out_done = (_q_index == 3);

always @(posedge _w_clk_gen_CPU_clkMEMORY) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_index <= _d_index;
  end
_q_sdram_writeflag <= _d_sdram_writeflag;
_q_sdram_readflag <= _d_sdram_readflag;
_q_ram_writeflag <= _d_ram_writeflag;
_q_ram_readflag <= _d_ram_readflag;
_q_IO_Map_memoryWrite <= _d_IO_Map_memoryWrite;
_q_IO_Map_memoryRead <= _d_IO_Map_memoryRead;
_q_CPU_readdata <= _d_CPU_readdata;
_q_CPU_memorybusy <= _d_CPU_memorybusy;
end


ulx3s_clk_risc_ice_v_AUX _clk_gen_AUX (
.clkin(clock),
.clkIO(_w_clk_gen_AUX_clkIO),
.clkVIDEO(_w_clk_gen_AUX_clkVIDEO),
.clkSDRAM(_w_clk_gen_AUX_clkSDRAM),
.clkSDRAMcontrol(_w_clk_gen_AUX_clkSDRAMcontrol),
.locked(_w_clk_gen_AUX_locked)
);

ulx3s_clk_risc_ice_v_CPU _clk_gen_CPU (
.clkin(clock),
.clkCPU(_w_clk_gen_CPU_clkCPU),
.clkCOPRO(_w_clk_gen_CPU_clkCOPRO),
.clkMEMORY(_w_clk_gen_CPU_clkMEMORY),
.locked(_w_clk_gen_CPU_locked)
);
M_clean_reset video_rstcond (
.out_out(_w_video_rstcond_out),
.reset(reset),
.clock(_w_clk_gen_AUX_clkVIDEO)
);
M_clean_reset sdram_rstcond (
.out_out(_w_sdram_rstcond_out),
.reset(reset),
.clock(_w_clk_gen_AUX_clkSDRAM)
);
M_hdmi video (
.in_red(_w_IO_Map_video_r),
.in_green(_w_IO_Map_video_g),
.in_blue(_w_IO_Map_video_b),
.out_x(_w_video_x),
.out_y(_w_video_y),
.out_active(_w_video_active),
.out_vblank(_w_video_vblank),
.out_gpdi_dp(_w_video_gpdi_dp),
.out_gpdi_dn(_w_video_gpdi_dn),
.reset(reset),
.clock(clock)
);
M_sdram_half_speed_access #(
.SDH_ADDR_WIDTH(26),
.SDH_ADDR_INIT(0),
.SDH_ADDR_SIGNED(0),
.SDH_RW_WIDTH(1),
.SDH_RW_INIT(0),
.SDH_RW_SIGNED(0),
.SDH_DATA_IN_WIDTH(16),
.SDH_DATA_IN_INIT(0),
.SDH_DATA_IN_SIGNED(0),
.SDH_IN_VALID_WIDTH(1),
.SDH_IN_VALID_INIT(0),
.SDH_IN_VALID_SIGNED(0),
.SDH_DATA_OUT_WIDTH(16),
.SDH_DATA_OUT_INIT(0),
.SDH_DATA_OUT_SIGNED(0),
.SDH_DONE_WIDTH(1),
.SDH_DONE_INIT(0),
.SDH_DONE_SIGNED(0),
.SD_ADDR_WIDTH(26),
.SD_ADDR_INIT(0),
.SD_ADDR_SIGNED(0),
.SD_RW_WIDTH(1),
.SD_RW_INIT(0),
.SD_RW_SIGNED(0),
.SD_DATA_IN_WIDTH(16),
.SD_DATA_IN_INIT(0),
.SD_DATA_IN_SIGNED(0),
.SD_IN_VALID_WIDTH(1),
.SD_IN_VALID_INIT(0),
.SD_IN_VALID_SIGNED(0),
.SD_DATA_OUT_WIDTH(16),
.SD_DATA_OUT_INIT(0),
.SD_DATA_OUT_SIGNED(0),
.SD_DONE_WIDTH(1),
.SD_DONE_INIT(0),
.SD_DONE_SIGNED(0)
) sdaccess (
.in_sdh_addr(_w_sdram_sio_addr),
.in_sdh_rw(_w_sdram_sio_rw),
.in_sdh_data_in(_w_sdram_sio_data_in),
.in_sdh_in_valid(_w_sdram_sio_in_valid),
.in_sd_data_out(_w_sdram32MB_sd_data_out),
.in_sd_done(_w_sdram32MB_sd_done),
.out_sdh_data_out(_w_sdaccess_sdh_data_out),
.out_sdh_done(_w_sdaccess_sdh_done),
.out_sd_addr(_w_sdaccess_sd_addr),
.out_sd_rw(_w_sdaccess_sd_rw),
.out_sd_data_in(_w_sdaccess_sd_data_in),
.out_sd_in_valid(_w_sdaccess_sd_in_valid),
.reset(_w_sdram_rstcond_out),
.clock(_w_clk_gen_AUX_clkSDRAM)
);
M_sdram_controller_autoprecharge_r16_w16 #(
.SD_ADDR_WIDTH(26),
.SD_ADDR_INIT(0),
.SD_ADDR_SIGNED(0),
.SD_RW_WIDTH(1),
.SD_RW_INIT(0),
.SD_RW_SIGNED(0),
.SD_DATA_IN_WIDTH(16),
.SD_DATA_IN_INIT(0),
.SD_DATA_IN_SIGNED(0),
.SD_IN_VALID_WIDTH(1),
.SD_IN_VALID_INIT(0),
.SD_IN_VALID_SIGNED(0),
.SD_DATA_OUT_WIDTH(16),
.SD_DATA_OUT_INIT(0),
.SD_DATA_OUT_SIGNED(0),
.SD_DONE_WIDTH(1),
.SD_DONE_INIT(0),
.SD_DONE_SIGNED(0)
) sdram32MB (
.in_sd_addr(_w_sdaccess_sd_addr),
.in_sd_rw(_w_sdaccess_sd_rw),
.in_sd_data_in(_w_sdaccess_sd_data_in),
.in_sd_in_valid(_w_sdaccess_sd_in_valid),
.out_sdram_cle(_w_sdram32MB_sdram_cle),
.out_sdram_cs(_w_sdram32MB_sdram_cs),
.out_sdram_cas(_w_sdram32MB_sdram_cas),
.out_sdram_ras(_w_sdram32MB_sdram_ras),
.out_sdram_we(_w_sdram32MB_sdram_we),
.out_sdram_dqm(_w_sdram32MB_sdram_dqm),
.out_sdram_ba(_w_sdram32MB_sdram_ba),
.out_sdram_a(_w_sdram32MB_sdram_a),
.out_sd_data_out(_w_sdram32MB_sd_data_out),
.out_sd_done(_w_sdram32MB_sd_done),
.inout_sdram_dq(inout_sdram_dq),
.out_done(_w_sdram32MB_done),
.in_run(_sdram32MB_run),
.reset(_w_sdram_rstcond_out),
.clock(_w_clk_gen_AUX_clkSDRAM)
);
M_sdramcontroller #(
.SIO_ADDR_WIDTH(26),
.SIO_ADDR_INIT(0),
.SIO_ADDR_SIGNED(0),
.SIO_RW_WIDTH(1),
.SIO_RW_INIT(0),
.SIO_RW_SIGNED(0),
.SIO_DATA_IN_WIDTH(16),
.SIO_DATA_IN_INIT(0),
.SIO_DATA_IN_SIGNED(0),
.SIO_IN_VALID_WIDTH(1),
.SIO_IN_VALID_INIT(0),
.SIO_IN_VALID_SIGNED(0),
.SIO_DATA_OUT_WIDTH(16),
.SIO_DATA_OUT_INIT(0),
.SIO_DATA_OUT_SIGNED(0),
.SIO_DONE_WIDTH(1),
.SIO_DONE_INIT(0),
.SIO_DONE_SIGNED(0)
) sdram (
.in_sio_data_out(_w_sdaccess_sdh_data_out),
.in_sio_done(_w_sdaccess_sdh_done),
.in_address(_w_CPU_address),
.in_function3(_w_CPU_function3),
.in_writeflag(_d_sdram_writeflag),
.in_writedata(_w_CPU_writedata),
.in_readflag(_d_sdram_readflag),
.in_Icache(_w_CPU_Icacheflag),
.out_sio_addr(_w_sdram_sio_addr),
.out_sio_rw(_w_sdram_sio_rw),
.out_sio_data_in(_w_sdram_sio_data_in),
.out_sio_in_valid(_w_sdram_sio_in_valid),
.out_readdata(_w_sdram_readdata),
.out_busy(_w_sdram_busy),
.out_done(_w_sdram_done),
.in_run(_sdram_run),
.reset(reset),
.clock(_w_clk_gen_CPU_clkMEMORY)
);
M_bramcontroller ram (
.in_address(_w_CPU_address),
.in_function3(_w_CPU_function3),
.in_writeflag(_d_ram_writeflag),
.in_writedata(_w_CPU_writedata),
.in_readflag(_d_ram_readflag),
.out_readdata(_w_ram_readdata),
.out_done(_w_ram_done),
.in_run(_ram_run),
.reset(reset),
.clock(_w_clk_gen_CPU_clkMEMORY)
);
M_memmap_io IO_Map (
.in_btns(in_btns),
.in_uart_rx(in_uart_rx),
.in_sd_miso(in_sd_miso),
.in_vblank(_w_video_vblank),
.in_pix_active(_w_video_active),
.in_pix_x(_w_video_x),
.in_pix_y(_w_video_y),
.in_video_clock(_w_clk_gen_AUX_clkVIDEO),
.in_video_reset(_w_video_rstcond_out),
.in_memoryAddress(_w_CPU_address),
.in_memoryWrite(_d_IO_Map_memoryWrite),
.in_memoryRead(_d_IO_Map_memoryRead),
.in_writeData(_w_CPU_writedata),
.out_leds(_w_IO_Map_leds),
.out_uart_tx(_w_IO_Map_uart_tx),
.out_audio_l(_w_IO_Map_audio_l),
.out_audio_r(_w_IO_Map_audio_r),
.out_sd_clk(_w_IO_Map_sd_clk),
.out_sd_mosi(_w_IO_Map_sd_mosi),
.out_sd_csn(_w_IO_Map_sd_csn),
.out_video_r(_w_IO_Map_video_r),
.out_video_g(_w_IO_Map_video_g),
.out_video_b(_w_IO_Map_video_b),
.out_readData(_w_IO_Map_readData),
.out_done(_w_IO_Map_done),
.in_run(_IO_Map_run),
.reset(reset),
.clock(_w_clk_gen_AUX_clkIO)
);
M_PAWSCPU CPU (
.in_readdata(_d_CPU_readdata),
.in_memorybusy(_d_CPU_memorybusy),
.in_clock_copro(_w_clk_gen_CPU_clkCOPRO),
.out_function3(_w_CPU_function3),
.out_address(_w_CPU_address),
.out_writedata(_w_CPU_writedata),
.out_writememory(_w_CPU_writememory),
.out_readmemory(_w_CPU_readmemory),
.out_Icacheflag(_w_CPU_Icacheflag),
.out_done(_w_CPU_done),
.in_run(_CPU_run),
.reset(reset),
.clock(_w_clk_gen_CPU_clkCPU)
);



always @* begin
_d_sdram_writeflag = _q_sdram_writeflag;
_d_sdram_readflag = _q_sdram_readflag;
_d_ram_writeflag = _q_ram_writeflag;
_d_ram_readflag = _q_ram_readflag;
_d_IO_Map_memoryWrite = _q_IO_Map_memoryWrite;
_d_IO_Map_memoryRead = _q_IO_Map_memoryRead;
_d_CPU_readdata = _q_CPU_readdata;
_d_CPU_memorybusy = _q_CPU_memorybusy;
_d_index = _q_index;
_sdram32MB_run = 1;
_sdram_run = 1;
_ram_run = 1;
_IO_Map_run = 1;
_CPU_run = 1;
// _always_pre
_d_CPU_memorybusy = _w_sdram_busy;
_d_sdram_writeflag = _w_CPU_writememory&&_w_CPU_address[28+:1];
_d_sdram_readflag = _w_CPU_readmemory&&_w_CPU_address[28+:1];
_d_ram_writeflag = _w_CPU_writememory&&~_w_CPU_address[28+:1]&&~_w_CPU_address[15+:1];
_d_ram_readflag = _w_CPU_readmemory&&~_w_CPU_address[28+:1]&&~_w_CPU_address[15+:1];
_d_IO_Map_memoryWrite = _w_CPU_writememory&&~_w_CPU_address[28+:1]&&_w_CPU_address[15+:1];
_d_IO_Map_memoryRead = _w_CPU_readmemory&&~_w_CPU_address[28+:1]&&_w_CPU_address[15+:1];
_d_CPU_readdata = _w_CPU_address[28+:1]?_w_sdram_readdata:(_w_CPU_address[15+:1]?_w_IO_Map_readData:_w_ram_readdata);
_d_index = 3;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
// __block_5
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of main
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_bramcontroller_mem_ram(
input                  [0:0] in_ram_wenable,
input       [15:0]    in_ram_wdata,
input                  [13:0]    in_ram_addr,
output reg  [15:0]    out_ram_rdata,
input                                      clock
);
reg  [15:0] buffer[12287:0];
always @(posedge clock) begin
  if (in_ram_wenable) begin
    buffer[in_ram_addr] <= in_ram_wdata;
  end
  out_ram_rdata <= buffer[in_ram_addr];
end
initial begin
 buffer[0] = 16'h6137;
 buffer[1] = 16'h0000;
 buffer[2] = 16'h0097;
 buffer[3] = 16'h0000;
 buffer[4] = 16'h80e7;
 buffer[5] = 16'h2760;
 buffer[6] = 16'h0317;
 buffer[7] = 16'h0000;
 buffer[8] = 16'h0067;
 buffer[9] = 16'h0083;
 buffer[10] = 16'h0000;
 buffer[11] = 16'h0000;
 buffer[12] = 16'h8082;
 buffer[13] = 16'h1141;
 buffer[14] = 16'hc606;
 buffer[15] = 16'h0713;
 buffer[16] = 16'h0640;
 buffer[17] = 16'h0693;
 buffer[18] = 16'h0640;
 buffer[19] = 16'h4601;
 buffer[20] = 16'h4581;
 buffer[21] = 16'h0513;
 buffer[22] = 16'h0380;
 buffer[23] = 16'h0097;
 buffer[24] = 16'h0000;
 buffer[25] = 16'h80e7;
 buffer[26] = 16'h7c00;
 buffer[27] = 16'h0813;
 buffer[28] = 16'h0640;
 buffer[29] = 16'h0793;
 buffer[30] = 16'h0320;
 buffer[31] = 16'h0713;
 buffer[32] = 16'h0640;
 buffer[33] = 16'h0693;
 buffer[34] = 16'h0640;
 buffer[35] = 16'h0613;
 buffer[36] = 16'h0210;
 buffer[37] = 16'h0593;
 buffer[38] = 16'h0640;
 buffer[39] = 16'h0513;
 buffer[40] = 16'h03f0;
 buffer[41] = 16'h1097;
 buffer[42] = 16'h0000;
 buffer[43] = 16'h80e7;
 buffer[44] = 16'h9cc0;
 buffer[45] = 16'h0813;
 buffer[46] = 16'h0640;
 buffer[47] = 16'h0793;
 buffer[48] = 16'h0420;
 buffer[49] = 16'h0713;
 buffer[50] = 16'h0640;
 buffer[51] = 16'h0693;
 buffer[52] = 16'h0640;
 buffer[53] = 16'h0613;
 buffer[54] = 16'h0320;
 buffer[55] = 16'h0593;
 buffer[56] = 16'h0640;
 buffer[57] = 16'h4509;
 buffer[58] = 16'h1097;
 buffer[59] = 16'h0000;
 buffer[60] = 16'h80e7;
 buffer[61] = 16'h9aa0;
 buffer[62] = 16'h0713;
 buffer[63] = 16'h0320;
 buffer[64] = 16'h0693;
 buffer[65] = 16'h0210;
 buffer[66] = 16'h4601;
 buffer[67] = 16'h4581;
 buffer[68] = 16'h4509;
 buffer[69] = 16'h0097;
 buffer[70] = 16'h0000;
 buffer[71] = 16'h80e7;
 buffer[72] = 16'h7640;
 buffer[73] = 16'h4705;
 buffer[74] = 16'h46e9;
 buffer[75] = 16'h4665;
 buffer[76] = 16'h45e5;
 buffer[77] = 16'h0513;
 buffer[78] = 16'h03f0;
 buffer[79] = 16'h1097;
 buffer[80] = 16'h0000;
 buffer[81] = 16'h80e7;
 buffer[82] = 16'h8340;
 buffer[83] = 16'h4731;
 buffer[84] = 16'h46e5;
 buffer[85] = 16'h4601;
 buffer[86] = 16'h4581;
 buffer[87] = 16'h0513;
 buffer[88] = 16'h03f0;
 buffer[89] = 16'h0097;
 buffer[90] = 16'h0000;
 buffer[91] = 16'h80e7;
 buffer[92] = 16'h73c0;
 buffer[93] = 16'h4705;
 buffer[94] = 16'h46b1;
 buffer[95] = 16'h4665;
 buffer[96] = 16'h45e5;
 buffer[97] = 16'h4509;
 buffer[98] = 16'h1097;
 buffer[99] = 16'h0000;
 buffer[100] = 16'h80e7;
 buffer[101] = 16'h80e0;
 buffer[102] = 16'h0813;
 buffer[103] = 16'h0640;
 buffer[104] = 16'h4781;
 buffer[105] = 16'h0713;
 buffer[106] = 16'h0640;
 buffer[107] = 16'h0693;
 buffer[108] = 16'h0430;
 buffer[109] = 16'h0613;
 buffer[110] = 16'h0210;
 buffer[111] = 16'h4581;
 buffer[112] = 16'h0513;
 buffer[113] = 16'h03f0;
 buffer[114] = 16'h1097;
 buffer[115] = 16'h0000;
 buffer[116] = 16'h80e7;
 buffer[117] = 16'h93a0;
 buffer[118] = 16'h0813;
 buffer[119] = 16'h0640;
 buffer[120] = 16'h4781;
 buffer[121] = 16'h0713;
 buffer[122] = 16'h0640;
 buffer[123] = 16'h0693;
 buffer[124] = 16'h0320;
 buffer[125] = 16'h0613;
 buffer[126] = 16'h0320;
 buffer[127] = 16'h4581;
 buffer[128] = 16'h4509;
 buffer[129] = 16'h1097;
 buffer[130] = 16'h0000;
 buffer[131] = 16'h80e7;
 buffer[132] = 16'h91c0;
 buffer[133] = 16'h0713;
 buffer[134] = 16'h0250;
 buffer[135] = 16'h46e5;
 buffer[136] = 16'h4631;
 buffer[137] = 16'h4581;
 buffer[138] = 16'h4509;
 buffer[139] = 16'h0097;
 buffer[140] = 16'h0000;
 buffer[141] = 16'h80e7;
 buffer[142] = 16'h6d80;
 buffer[143] = 16'h0713;
 buffer[144] = 16'h0640;
 buffer[145] = 16'h46a1;
 buffer[146] = 16'h0613;
 buffer[147] = 16'h0250;
 buffer[148] = 16'h4581;
 buffer[149] = 16'h4509;
 buffer[150] = 16'h0097;
 buffer[151] = 16'h0000;
 buffer[152] = 16'h80e7;
 buffer[153] = 16'h6c20;
 buffer[154] = 16'h40b2;
 buffer[155] = 16'h0141;
 buffer[156] = 16'h8082;
 buffer[157] = 16'h1101;
 buffer[158] = 16'hce06;
 buffer[159] = 16'hcc22;
 buffer[160] = 16'hca26;
 buffer[161] = 16'hc84a;
 buffer[162] = 16'hc64e;
 buffer[163] = 16'h892a;
 buffer[164] = 16'h842e;
 buffer[165] = 16'h1537;
 buffer[166] = 16'h0000;
 buffer[167] = 16'h0513;
 buffer[168] = 16'he185;
 buffer[169] = 16'h0097;
 buffer[170] = 16'h0000;
 buffer[171] = 16'h80e7;
 buffer[172] = 16'h45e0;
 buffer[173] = 16'h5793;
 buffer[174] = 16'h0044;
 buffer[175] = 16'hc7b5;
 buffer[176] = 16'h0493;
 buffer[177] = 16'h0109;
 buffer[178] = 16'h0792;
 buffer[179] = 16'h09b3;
 buffer[180] = 16'h00f9;
 buffer[181] = 16'h854a;
 buffer[182] = 16'h0097;
 buffer[183] = 16'h0000;
 buffer[184] = 16'h80e7;
 buffer[185] = 16'h4f20;
 buffer[186] = 16'h0513;
 buffer[187] = 16'h03a0;
 buffer[188] = 16'h0097;
 buffer[189] = 16'h0000;
 buffer[190] = 16'h80e7;
 buffer[191] = 16'h3e20;
 buffer[192] = 16'h0513;
 buffer[193] = 16'h0200;
 buffer[194] = 16'h0097;
 buffer[195] = 16'h0000;
 buffer[196] = 16'h80e7;
 buffer[197] = 16'h3d60;
 buffer[198] = 16'h844a;
 buffer[199] = 16'h4503;
 buffer[200] = 16'h0004;
 buffer[201] = 16'h0097;
 buffer[202] = 16'h0000;
 buffer[203] = 16'h80e7;
 buffer[204] = 16'h4740;
 buffer[205] = 16'h0513;
 buffer[206] = 16'h0200;
 buffer[207] = 16'h0097;
 buffer[208] = 16'h0000;
 buffer[209] = 16'h80e7;
 buffer[210] = 16'h3bc0;
 buffer[211] = 16'h0405;
 buffer[212] = 16'h13e3;
 buffer[213] = 16'hfe94;
 buffer[214] = 16'h0941;
 buffer[215] = 16'h4529;
 buffer[216] = 16'h0097;
 buffer[217] = 16'h0000;
 buffer[218] = 16'h80e7;
 buffer[219] = 16'h3aa0;
 buffer[220] = 16'h0513;
 buffer[221] = 16'h1f40;
 buffer[222] = 16'h0097;
 buffer[223] = 16'h0000;
 buffer[224] = 16'h80e7;
 buffer[225] = 16'h5100;
 buffer[226] = 16'h04c1;
 buffer[227] = 16'h92e3;
 buffer[228] = 16'hfb29;
 buffer[229] = 16'h40f2;
 buffer[230] = 16'h4462;
 buffer[231] = 16'h44d2;
 buffer[232] = 16'h4942;
 buffer[233] = 16'h49b2;
 buffer[234] = 16'h6105;
 buffer[235] = 16'h8082;
 buffer[236] = 16'h1101;
 buffer[237] = 16'hce06;
 buffer[238] = 16'hcc22;
 buffer[239] = 16'hca26;
 buffer[240] = 16'hc84a;
 buffer[241] = 16'hc64e;
 buffer[242] = 16'h892a;
 buffer[243] = 16'h842e;
 buffer[244] = 16'h1537;
 buffer[245] = 16'h0000;
 buffer[246] = 16'h0513;
 buffer[247] = 16'he2c5;
 buffer[248] = 16'h0097;
 buffer[249] = 16'h0000;
 buffer[250] = 16'h80e7;
 buffer[251] = 16'h3c00;
 buffer[252] = 16'h5793;
 buffer[253] = 16'h0044;
 buffer[254] = 16'hcba5;
 buffer[255] = 16'h0493;
 buffer[256] = 16'h0209;
 buffer[257] = 16'h0796;
 buffer[258] = 16'h09b3;
 buffer[259] = 16'h00f9;
 buffer[260] = 16'h854a;
 buffer[261] = 16'h0097;
 buffer[262] = 16'h0000;
 buffer[263] = 16'h80e7;
 buffer[264] = 16'h4540;
 buffer[265] = 16'h0513;
 buffer[266] = 16'h03a0;
 buffer[267] = 16'h0097;
 buffer[268] = 16'h0000;
 buffer[269] = 16'h80e7;
 buffer[270] = 16'h3440;
 buffer[271] = 16'h0513;
 buffer[272] = 16'h0200;
 buffer[273] = 16'h0097;
 buffer[274] = 16'h0000;
 buffer[275] = 16'h80e7;
 buffer[276] = 16'h3380;
 buffer[277] = 16'h844a;
 buffer[278] = 16'h5503;
 buffer[279] = 16'h0004;
 buffer[280] = 16'h0097;
 buffer[281] = 16'h0000;
 buffer[282] = 16'h80e7;
 buffer[283] = 16'h3fe0;
 buffer[284] = 16'h0513;
 buffer[285] = 16'h0200;
 buffer[286] = 16'h0097;
 buffer[287] = 16'h0000;
 buffer[288] = 16'h80e7;
 buffer[289] = 16'h31e0;
 buffer[290] = 16'h0409;
 buffer[291] = 16'h13e3;
 buffer[292] = 16'hfe94;
 buffer[293] = 16'h0913;
 buffer[294] = 16'h0209;
 buffer[295] = 16'h4529;
 buffer[296] = 16'h0097;
 buffer[297] = 16'h0000;
 buffer[298] = 16'h80e7;
 buffer[299] = 16'h30a0;
 buffer[300] = 16'h0513;
 buffer[301] = 16'h1f40;
 buffer[302] = 16'h0097;
 buffer[303] = 16'h0000;
 buffer[304] = 16'h80e7;
 buffer[305] = 16'h4700;
 buffer[306] = 16'h8493;
 buffer[307] = 16'h0204;
 buffer[308] = 16'h90e3;
 buffer[309] = 16'hfb29;
 buffer[310] = 16'h40f2;
 buffer[311] = 16'h4462;
 buffer[312] = 16'h44d2;
 buffer[313] = 16'h4942;
 buffer[314] = 16'h49b2;
 buffer[315] = 16'h6105;
 buffer[316] = 16'h8082;
 buffer[317] = 16'h1141;
 buffer[318] = 16'hc606;
 buffer[319] = 16'hc422;
 buffer[320] = 16'hc226;
 buffer[321] = 16'hc04a;
 buffer[322] = 16'h0097;
 buffer[323] = 16'h0000;
 buffer[324] = 16'h80e7;
 buffer[325] = 16'h5c60;
 buffer[326] = 16'h1097;
 buffer[327] = 16'h0000;
 buffer[328] = 16'h80e7;
 buffer[329] = 16'h8060;
 buffer[330] = 16'h4601;
 buffer[331] = 16'h4581;
 buffer[332] = 16'h4505;
 buffer[333] = 16'h0097;
 buffer[334] = 16'h0000;
 buffer[335] = 16'h80e7;
 buffer[336] = 16'h4f60;
 buffer[337] = 16'h0097;
 buffer[338] = 16'h0000;
 buffer[339] = 16'h80e7;
 buffer[340] = 16'hd780;
 buffer[341] = 16'h0693;
 buffer[342] = 16'h03f0;
 buffer[343] = 16'h0613;
 buffer[344] = 16'h0400;
 buffer[345] = 16'h4595;
 buffer[346] = 16'h4541;
 buffer[347] = 16'h1097;
 buffer[348] = 16'h0000;
 buffer[349] = 16'h80e7;
 buffer[350] = 16'h8240;
 buffer[351] = 16'h1537;
 buffer[352] = 16'h0000;
 buffer[353] = 16'h0513;
 buffer[354] = 16'he405;
 buffer[355] = 16'h1097;
 buffer[356] = 16'h0000;
 buffer[357] = 16'h80e7;
 buffer[358] = 16'h8940;
 buffer[359] = 16'h6505;
 buffer[360] = 16'h0513;
 buffer[361] = 16'hfa05;
 buffer[362] = 16'h0097;
 buffer[363] = 16'h0000;
 buffer[364] = 16'h80e7;
 buffer[365] = 16'h3f80;
 buffer[366] = 16'h07b7;
 buffer[367] = 16'h1000;
 buffer[368] = 16'h0737;
 buffer[369] = 16'h1000;
 buffer[370] = 16'h0713;
 buffer[371] = 16'h0ff7;
 buffer[372] = 16'h8023;
 buffer[373] = 16'h00f7;
 buffer[374] = 16'h0785;
 buffer[375] = 16'h9de3;
 buffer[376] = 16'hfee7;
 buffer[377] = 16'h0737;
 buffer[378] = 16'h1000;
 buffer[379] = 16'h0713;
 buffer[380] = 16'h1007;
 buffer[381] = 16'h4781;
 buffer[382] = 16'h0693;
 buffer[383] = 16'h1000;
 buffer[384] = 16'h1023;
 buffer[385] = 16'h00f7;
 buffer[386] = 16'h0785;
 buffer[387] = 16'h07c2;
 buffer[388] = 16'h83c1;
 buffer[389] = 16'h0709;
 buffer[390] = 16'h9ae3;
 buffer[391] = 16'hfed7;
 buffer[392] = 16'h1537;
 buffer[393] = 16'h0000;
 buffer[394] = 16'h0513;
 buffer[395] = 16'he685;
 buffer[396] = 16'h0097;
 buffer[397] = 16'h0000;
 buffer[398] = 16'h80e7;
 buffer[399] = 16'h2980;
 buffer[400] = 16'h0593;
 buffer[401] = 16'h1000;
 buffer[402] = 16'h0537;
 buffer[403] = 16'h1000;
 buffer[404] = 16'h0097;
 buffer[405] = 16'h0000;
 buffer[406] = 16'h80e7;
 buffer[407] = 16'he120;
 buffer[408] = 16'h1537;
 buffer[409] = 16'h0000;
 buffer[410] = 16'h0513;
 buffer[411] = 16'he8c5;
 buffer[412] = 16'h0097;
 buffer[413] = 16'h0000;
 buffer[414] = 16'h80e7;
 buffer[415] = 16'h2780;
 buffer[416] = 16'h0593;
 buffer[417] = 16'h1000;
 buffer[418] = 16'h0437;
 buffer[419] = 16'h1000;
 buffer[420] = 16'h0513;
 buffer[421] = 16'h1004;
 buffer[422] = 16'h0097;
 buffer[423] = 16'h0000;
 buffer[424] = 16'h80e7;
 buffer[425] = 16'he8c0;
 buffer[426] = 16'h0713;
 buffer[427] = 16'h1004;
 buffer[428] = 16'h4781;
 buffer[429] = 16'h6685;
 buffer[430] = 16'h1023;
 buffer[431] = 16'h00f7;
 buffer[432] = 16'h0785;
 buffer[433] = 16'h07c2;
 buffer[434] = 16'h83c1;
 buffer[435] = 16'h0709;
 buffer[436] = 16'h9ae3;
 buffer[437] = 16'hfed7;
 buffer[438] = 16'h1537;
 buffer[439] = 16'h0000;
 buffer[440] = 16'h0513;
 buffer[441] = 16'heb45;
 buffer[442] = 16'h0097;
 buffer[443] = 16'h0000;
 buffer[444] = 16'h80e7;
 buffer[445] = 16'h23c0;
 buffer[446] = 16'h1537;
 buffer[447] = 16'h0000;
 buffer[448] = 16'h0513;
 buffer[449] = 16'hecc5;
 buffer[450] = 16'h0097;
 buffer[451] = 16'h0000;
 buffer[452] = 16'h80e7;
 buffer[453] = 16'h22c0;
 buffer[454] = 16'h0593;
 buffer[455] = 16'h1000;
 buffer[456] = 16'h0537;
 buffer[457] = 16'h1000;
 buffer[458] = 16'h0097;
 buffer[459] = 16'h0000;
 buffer[460] = 16'h80e7;
 buffer[461] = 16'hda60;
 buffer[462] = 16'h1537;
 buffer[463] = 16'h0000;
 buffer[464] = 16'h0513;
 buffer[465] = 16'hefc5;
 buffer[466] = 16'h0097;
 buffer[467] = 16'h0000;
 buffer[468] = 16'h80e7;
 buffer[469] = 16'h20c0;
 buffer[470] = 16'h0593;
 buffer[471] = 16'h1000;
 buffer[472] = 16'h0537;
 buffer[473] = 16'h1000;
 buffer[474] = 16'h0513;
 buffer[475] = 16'h1005;
 buffer[476] = 16'h0097;
 buffer[477] = 16'h0000;
 buffer[478] = 16'h80e7;
 buffer[479] = 16'he200;
 buffer[480] = 16'h0097;
 buffer[481] = 16'h0000;
 buffer[482] = 16'h80e7;
 buffer[483] = 16'h1000;
 buffer[484] = 16'h84aa;
 buffer[485] = 16'h0097;
 buffer[486] = 16'h0000;
 buffer[487] = 16'h80e7;
 buffer[488] = 16'h0fc0;
 buffer[489] = 16'h842a;
 buffer[490] = 16'h1537;
 buffer[491] = 16'h0000;
 buffer[492] = 16'h0513;
 buffer[493] = 16'hf305;
 buffer[494] = 16'h0097;
 buffer[495] = 16'h0000;
 buffer[496] = 16'h80e7;
 buffer[497] = 16'h2040;
 buffer[498] = 16'h8526;
 buffer[499] = 16'h0097;
 buffer[500] = 16'h0000;
 buffer[501] = 16'h80e7;
 buffer[502] = 16'h2780;
 buffer[503] = 16'h1537;
 buffer[504] = 16'h0000;
 buffer[505] = 16'h0513;
 buffer[506] = 16'hf405;
 buffer[507] = 16'h0097;
 buffer[508] = 16'h0000;
 buffer[509] = 16'h80e7;
 buffer[510] = 16'h1ea0;
 buffer[511] = 16'h8522;
 buffer[512] = 16'h0097;
 buffer[513] = 16'h0000;
 buffer[514] = 16'h80e7;
 buffer[515] = 16'h25e0;
 buffer[516] = 16'ha029;
 buffer[517] = 16'h0097;
 buffer[518] = 16'h0000;
 buffer[519] = 16'h80e7;
 buffer[520] = 16'h2a20;
 buffer[521] = 16'h0097;
 buffer[522] = 16'h0000;
 buffer[523] = 16'h80e7;
 buffer[524] = 16'h28a0;
 buffer[525] = 16'hf965;
 buffer[526] = 16'h1537;
 buffer[527] = 16'h0000;
 buffer[528] = 16'h0513;
 buffer[529] = 16'hf505;
 buffer[530] = 16'h0097;
 buffer[531] = 16'h0000;
 buffer[532] = 16'h80e7;
 buffer[533] = 16'h18c0;
 buffer[534] = 16'h1937;
 buffer[535] = 16'h0000;
 buffer[536] = 16'h14b7;
 buffer[537] = 16'h0000;
 buffer[538] = 16'h0097;
 buffer[539] = 16'h0000;
 buffer[540] = 16'h80e7;
 buffer[541] = 16'h2780;
 buffer[542] = 16'h842a;
 buffer[543] = 16'h0513;
 buffer[544] = 16'hf6c9;
 buffer[545] = 16'h0097;
 buffer[546] = 16'h0000;
 buffer[547] = 16'h80e7;
 buffer[548] = 16'h19e0;
 buffer[549] = 16'h8522;
 buffer[550] = 16'h0097;
 buffer[551] = 16'h0000;
 buffer[552] = 16'h80e7;
 buffer[553] = 16'h10e0;
 buffer[554] = 16'h8513;
 buffer[555] = 16'hf7c4;
 buffer[556] = 16'h0097;
 buffer[557] = 16'h0000;
 buffer[558] = 16'h80e7;
 buffer[559] = 16'h1580;
 buffer[560] = 16'h8522;
 buffer[561] = 16'h0097;
 buffer[562] = 16'h0000;
 buffer[563] = 16'h80e7;
 buffer[564] = 16'h3200;
 buffer[565] = 16'hb7e9;
 buffer[566] = 16'h962e;
 buffer[567] = 16'h8963;
 buffer[568] = 16'h00c5;
 buffer[569] = 16'h0585;
 buffer[570] = 16'hc783;
 buffer[571] = 16'h0005;
 buffer[572] = 16'h0023;
 buffer[573] = 16'h00f5;
 buffer[574] = 16'h1be3;
 buffer[575] = 16'hfeb6;
 buffer[576] = 16'h8082;
 buffer[577] = 16'h872a;
 buffer[578] = 16'h4783;
 buffer[579] = 16'h0005;
 buffer[580] = 16'hcb89;
 buffer[581] = 16'h4501;
 buffer[582] = 16'h0505;
 buffer[583] = 16'h07b3;
 buffer[584] = 16'h00a7;
 buffer[585] = 16'hc783;
 buffer[586] = 16'h0007;
 buffer[587] = 16'hfbfd;
 buffer[588] = 16'h8082;
 buffer[589] = 16'h4501;
 buffer[590] = 16'h8082;
 buffer[591] = 16'h4783;
 buffer[592] = 16'h0005;
 buffer[593] = 16'hcb91;
 buffer[594] = 16'hc703;
 buffer[595] = 16'h0005;
 buffer[596] = 16'h1763;
 buffer[597] = 16'h00f7;
 buffer[598] = 16'h0505;
 buffer[599] = 16'h0585;
 buffer[600] = 16'h4783;
 buffer[601] = 16'h0005;
 buffer[602] = 16'hfbe5;
 buffer[603] = 16'hc503;
 buffer[604] = 16'h0005;
 buffer[605] = 16'h8533;
 buffer[606] = 16'h40a7;
 buffer[607] = 16'h8082;
 buffer[608] = 16'h2573;
 buffer[609] = 16'hc000;
 buffer[610] = 16'h8082;
 buffer[611] = 16'h2573;
 buffer[612] = 16'hc020;
 buffer[613] = 16'h8082;
 buffer[614] = 16'h2573;
 buffer[615] = 16'hc010;
 buffer[616] = 16'h8082;
 buffer[617] = 16'hc515;
 buffer[618] = 16'h4781;
 buffer[619] = 16'h4629;
 buffer[620] = 16'h4309;
 buffer[621] = 16'h48a5;
 buffer[622] = 16'h76b3;
 buffer[623] = 16'h02c5;
 buffer[624] = 16'h882a;
 buffer[625] = 16'h5533;
 buffer[626] = 16'h02c5;
 buffer[627] = 16'h0733;
 buffer[628] = 16'h40f3;
 buffer[629] = 16'h972e;
 buffer[630] = 16'h8693;
 buffer[631] = 16'h0306;
 buffer[632] = 16'h0023;
 buffer[633] = 16'h00d7;
 buffer[634] = 16'h0785;
 buffer[635] = 16'hf793;
 buffer[636] = 16'h0ff7;
 buffer[637] = 16'he1e3;
 buffer[638] = 16'hff08;
 buffer[639] = 16'h8082;
 buffer[640] = 16'hc515;
 buffer[641] = 16'h4781;
 buffer[642] = 16'h4629;
 buffer[643] = 16'h4311;
 buffer[644] = 16'h48a5;
 buffer[645] = 16'h76b3;
 buffer[646] = 16'h02c5;
 buffer[647] = 16'h882a;
 buffer[648] = 16'h5533;
 buffer[649] = 16'h02c5;
 buffer[650] = 16'h0733;
 buffer[651] = 16'h40f3;
 buffer[652] = 16'h972e;
 buffer[653] = 16'h8693;
 buffer[654] = 16'h0306;
 buffer[655] = 16'h0023;
 buffer[656] = 16'h00d7;
 buffer[657] = 16'h0785;
 buffer[658] = 16'hf793;
 buffer[659] = 16'h0ff7;
 buffer[660] = 16'he1e3;
 buffer[661] = 16'hff08;
 buffer[662] = 16'h8082;
 buffer[663] = 16'hc50d;
 buffer[664] = 16'h4781;
 buffer[665] = 16'h4829;
 buffer[666] = 16'h4625;
 buffer[667] = 16'h76b3;
 buffer[668] = 16'h0305;
 buffer[669] = 16'h88aa;
 buffer[670] = 16'h5533;
 buffer[671] = 16'h0305;
 buffer[672] = 16'h0733;
 buffer[673] = 16'h40f6;
 buffer[674] = 16'h972e;
 buffer[675] = 16'h8693;
 buffer[676] = 16'h0306;
 buffer[677] = 16'h0023;
 buffer[678] = 16'h00d7;
 buffer[679] = 16'h0785;
 buffer[680] = 16'hf793;
 buffer[681] = 16'h0ff7;
 buffer[682] = 16'h61e3;
 buffer[683] = 16'hff16;
 buffer[684] = 16'h8082;
 buffer[685] = 16'h17b7;
 buffer[686] = 16'h0000;
 buffer[687] = 16'ha703;
 buffer[688] = 16'he147;
 buffer[689] = 16'h4783;
 buffer[690] = 16'h0007;
 buffer[691] = 16'h8b89;
 buffer[692] = 16'hffed;
 buffer[693] = 16'h17b7;
 buffer[694] = 16'h0000;
 buffer[695] = 16'ha783;
 buffer[696] = 16'he107;
 buffer[697] = 16'h8023;
 buffer[698] = 16'h00a7;
 buffer[699] = 16'h17b7;
 buffer[700] = 16'h0000;
 buffer[701] = 16'ha703;
 buffer[702] = 16'hde47;
 buffer[703] = 16'h4783;
 buffer[704] = 16'h0007;
 buffer[705] = 16'hf793;
 buffer[706] = 16'h0ff7;
 buffer[707] = 16'hffe5;
 buffer[708] = 16'h17b7;
 buffer[709] = 16'h0000;
 buffer[710] = 16'ha783;
 buffer[711] = 16'hdec7;
 buffer[712] = 16'h8023;
 buffer[713] = 16'h00a7;
 buffer[714] = 16'h47a9;
 buffer[715] = 16'h0363;
 buffer[716] = 16'h00f5;
 buffer[717] = 16'h8082;
 buffer[718] = 16'h1141;
 buffer[719] = 16'hc606;
 buffer[720] = 16'h4535;
 buffer[721] = 16'h0097;
 buffer[722] = 16'h0000;
 buffer[723] = 16'h80e7;
 buffer[724] = 16'hfb80;
 buffer[725] = 16'h40b2;
 buffer[726] = 16'h0141;
 buffer[727] = 16'h8082;
 buffer[728] = 16'h1141;
 buffer[729] = 16'hc606;
 buffer[730] = 16'hc422;
 buffer[731] = 16'h842a;
 buffer[732] = 16'h4503;
 buffer[733] = 16'h0005;
 buffer[734] = 16'hc909;
 buffer[735] = 16'h0097;
 buffer[736] = 16'h0000;
 buffer[737] = 16'h80e7;
 buffer[738] = 16'hf9c0;
 buffer[739] = 16'h0405;
 buffer[740] = 16'h4503;
 buffer[741] = 16'h0004;
 buffer[742] = 16'hf96d;
 buffer[743] = 16'h4529;
 buffer[744] = 16'h0097;
 buffer[745] = 16'h0000;
 buffer[746] = 16'h80e7;
 buffer[747] = 16'hf8a0;
 buffer[748] = 16'h40b2;
 buffer[749] = 16'h4422;
 buffer[750] = 16'h0141;
 buffer[751] = 16'h8082;
 buffer[752] = 16'h1141;
 buffer[753] = 16'hc606;
 buffer[754] = 16'hc422;
 buffer[755] = 16'h842a;
 buffer[756] = 16'h4503;
 buffer[757] = 16'h0005;
 buffer[758] = 16'hc909;
 buffer[759] = 16'h0097;
 buffer[760] = 16'h0000;
 buffer[761] = 16'h80e7;
 buffer[762] = 16'hf6c0;
 buffer[763] = 16'h0405;
 buffer[764] = 16'h4503;
 buffer[765] = 16'h0004;
 buffer[766] = 16'hf96d;
 buffer[767] = 16'h40b2;
 buffer[768] = 16'h4422;
 buffer[769] = 16'h0141;
 buffer[770] = 16'h8082;
 buffer[771] = 16'h1101;
 buffer[772] = 16'hce06;
 buffer[773] = 16'h27b7;
 buffer[774] = 16'h0030;
 buffer[775] = 16'h8793;
 buffer[776] = 16'h0207;
 buffer[777] = 16'hc63e;
 buffer[778] = 16'h006c;
 buffer[779] = 16'h0097;
 buffer[780] = 16'h0000;
 buffer[781] = 16'h80e7;
 buffer[782] = 16'hebc0;
 buffer[783] = 16'h0068;
 buffer[784] = 16'h0097;
 buffer[785] = 16'h0000;
 buffer[786] = 16'h80e7;
 buffer[787] = 16'hfc00;
 buffer[788] = 16'h40f2;
 buffer[789] = 16'h6105;
 buffer[790] = 16'h8082;
 buffer[791] = 16'h1101;
 buffer[792] = 16'hce06;
 buffer[793] = 16'h27b7;
 buffer[794] = 16'h2020;
 buffer[795] = 16'h8793;
 buffer[796] = 16'h0207;
 buffer[797] = 16'hc43e;
 buffer[798] = 16'h0793;
 buffer[799] = 16'h0300;
 buffer[800] = 16'h1623;
 buffer[801] = 16'h00f1;
 buffer[802] = 16'h002c;
 buffer[803] = 16'h0097;
 buffer[804] = 16'h0000;
 buffer[805] = 16'h80e7;
 buffer[806] = 16'heba0;
 buffer[807] = 16'h0028;
 buffer[808] = 16'h0097;
 buffer[809] = 16'h0000;
 buffer[810] = 16'h80e7;
 buffer[811] = 16'hf900;
 buffer[812] = 16'h40f2;
 buffer[813] = 16'h6105;
 buffer[814] = 16'h8082;
 buffer[815] = 16'h1101;
 buffer[816] = 16'hce06;
 buffer[817] = 16'h17b7;
 buffer[818] = 16'h0000;
 buffer[819] = 16'h8793;
 buffer[820] = 16'hf807;
 buffer[821] = 16'h4394;
 buffer[822] = 16'h43d8;
 buffer[823] = 16'hc236;
 buffer[824] = 16'hc43a;
 buffer[825] = 16'hd703;
 buffer[826] = 16'h0087;
 buffer[827] = 16'h1623;
 buffer[828] = 16'h00e1;
 buffer[829] = 16'hc783;
 buffer[830] = 16'h00a7;
 buffer[831] = 16'h0723;
 buffer[832] = 16'h00f1;
 buffer[833] = 16'h004c;
 buffer[834] = 16'h0097;
 buffer[835] = 16'h0000;
 buffer[836] = 16'h80e7;
 buffer[837] = 16'heaa0;
 buffer[838] = 16'h0048;
 buffer[839] = 16'h0097;
 buffer[840] = 16'h0000;
 buffer[841] = 16'h80e7;
 buffer[842] = 16'hf520;
 buffer[843] = 16'h40f2;
 buffer[844] = 16'h6105;
 buffer[845] = 16'h8082;
 buffer[846] = 16'h17b7;
 buffer[847] = 16'h0000;
 buffer[848] = 16'ha783;
 buffer[849] = 16'he147;
 buffer[850] = 16'hc503;
 buffer[851] = 16'h0007;
 buffer[852] = 16'h8905;
 buffer[853] = 16'h8082;
 buffer[854] = 16'h1141;
 buffer[855] = 16'hc606;
 buffer[856] = 16'h0097;
 buffer[857] = 16'h0000;
 buffer[858] = 16'h80e7;
 buffer[859] = 16'hfec0;
 buffer[860] = 16'hdd65;
 buffer[861] = 16'h17b7;
 buffer[862] = 16'h0000;
 buffer[863] = 16'ha783;
 buffer[864] = 16'he107;
 buffer[865] = 16'hc503;
 buffer[866] = 16'h0007;
 buffer[867] = 16'h40b2;
 buffer[868] = 16'h0141;
 buffer[869] = 16'h8082;
 buffer[870] = 16'h17b7;
 buffer[871] = 16'h0000;
 buffer[872] = 16'ha703;
 buffer[873] = 16'hc947;
 buffer[874] = 16'h1023;
 buffer[875] = 16'h00a7;
 buffer[876] = 16'ha703;
 buffer[877] = 16'hc947;
 buffer[878] = 16'h5783;
 buffer[879] = 16'h0007;
 buffer[880] = 16'h07c2;
 buffer[881] = 16'h83c1;
 buffer[882] = 16'hffe5;
 buffer[883] = 16'h8082;
 buffer[884] = 16'h17b7;
 buffer[885] = 16'h0000;
 buffer[886] = 16'ha703;
 buffer[887] = 16'he047;
 buffer[888] = 16'h4783;
 buffer[889] = 16'h0007;
 buffer[890] = 16'hf793;
 buffer[891] = 16'h0ff7;
 buffer[892] = 16'hdfe5;
 buffer[893] = 16'h8082;
 buffer[894] = 16'h1141;
 buffer[895] = 16'hc606;
 buffer[896] = 16'hc422;
 buffer[897] = 16'hc226;
 buffer[898] = 16'h84aa;
 buffer[899] = 16'h842e;
 buffer[900] = 16'h0097;
 buffer[901] = 16'h0000;
 buffer[902] = 16'h80e7;
 buffer[903] = 16'hfe00;
 buffer[904] = 16'h17b7;
 buffer[905] = 16'h0000;
 buffer[906] = 16'ha783;
 buffer[907] = 16'hdf87;
 buffer[908] = 16'hd713;
 buffer[909] = 16'h0104;
 buffer[910] = 16'h9023;
 buffer[911] = 16'h00e7;
 buffer[912] = 16'h17b7;
 buffer[913] = 16'h0000;
 buffer[914] = 16'ha783;
 buffer[915] = 16'hdfc7;
 buffer[916] = 16'h04c2;
 buffer[917] = 16'h80c1;
 buffer[918] = 16'h9023;
 buffer[919] = 16'h0097;
 buffer[920] = 16'h17b7;
 buffer[921] = 16'h0000;
 buffer[922] = 16'ha783;
 buffer[923] = 16'he007;
 buffer[924] = 16'h4705;
 buffer[925] = 16'h8023;
 buffer[926] = 16'h00e7;
 buffer[927] = 16'h0097;
 buffer[928] = 16'h0000;
 buffer[929] = 16'h80e7;
 buffer[930] = 16'hfaa0;
 buffer[931] = 16'h4781;
 buffer[932] = 16'h1537;
 buffer[933] = 16'h0000;
 buffer[934] = 16'h15b7;
 buffer[935] = 16'h0000;
 buffer[936] = 16'h0613;
 buffer[937] = 16'h2000;
 buffer[938] = 16'h9693;
 buffer[939] = 16'h0107;
 buffer[940] = 16'h82c1;
 buffer[941] = 16'h2703;
 buffer[942] = 16'hdf45;
 buffer[943] = 16'h1023;
 buffer[944] = 16'h00d7;
 buffer[945] = 16'ha703;
 buffer[946] = 16'hdf05;
 buffer[947] = 16'h4683;
 buffer[948] = 16'h0007;
 buffer[949] = 16'h0733;
 buffer[950] = 16'h00f4;
 buffer[951] = 16'h0023;
 buffer[952] = 16'h00d7;
 buffer[953] = 16'h0785;
 buffer[954] = 16'h90e3;
 buffer[955] = 16'hfec7;
 buffer[956] = 16'h40b2;
 buffer[957] = 16'h4422;
 buffer[958] = 16'h4492;
 buffer[959] = 16'h0141;
 buffer[960] = 16'h8082;
 buffer[961] = 16'h17b7;
 buffer[962] = 16'h0000;
 buffer[963] = 16'ha783;
 buffer[964] = 16'he087;
 buffer[965] = 16'h8023;
 buffer[966] = 16'h00a7;
 buffer[967] = 16'h8082;
 buffer[968] = 16'h17b7;
 buffer[969] = 16'h0000;
 buffer[970] = 16'ha783;
 buffer[971] = 16'hde07;
 buffer[972] = 16'h8023;
 buffer[973] = 16'h00a7;
 buffer[974] = 16'h17b7;
 buffer[975] = 16'h0000;
 buffer[976] = 16'ha783;
 buffer[977] = 16'hddc7;
 buffer[978] = 16'h8023;
 buffer[979] = 16'h00b7;
 buffer[980] = 16'h17b7;
 buffer[981] = 16'h0000;
 buffer[982] = 16'ha783;
 buffer[983] = 16'hdd87;
 buffer[984] = 16'h8023;
 buffer[985] = 16'h00c7;
 buffer[986] = 16'h8082;
 buffer[987] = 16'h17b7;
 buffer[988] = 16'h0000;
 buffer[989] = 16'ha703;
 buffer[990] = 16'hd887;
 buffer[991] = 16'h4783;
 buffer[992] = 16'h0007;
 buffer[993] = 16'hf793;
 buffer[994] = 16'h0ff7;
 buffer[995] = 16'hffe5;
 buffer[996] = 16'h8082;
 buffer[997] = 16'h1141;
 buffer[998] = 16'hc606;
 buffer[999] = 16'hc422;
 buffer[1000] = 16'h842a;
 buffer[1001] = 16'h0097;
 buffer[1002] = 16'h0000;
 buffer[1003] = 16'h80e7;
 buffer[1004] = 16'hfe40;
 buffer[1005] = 16'h17b7;
 buffer[1006] = 16'h0000;
 buffer[1007] = 16'ha783;
 buffer[1008] = 16'hd4c7;
 buffer[1009] = 16'h8023;
 buffer[1010] = 16'h0087;
 buffer[1011] = 16'h40b2;
 buffer[1012] = 16'h4422;
 buffer[1013] = 16'h0141;
 buffer[1014] = 16'h8082;
 buffer[1015] = 16'h1141;
 buffer[1016] = 16'hc606;
 buffer[1017] = 16'h17b7;
 buffer[1018] = 16'h0000;
 buffer[1019] = 16'ha783;
 buffer[1020] = 16'hda07;
 buffer[1021] = 16'h8023;
 buffer[1022] = 16'h00a7;
 buffer[1023] = 16'h17b7;
 buffer[1024] = 16'h0000;
 buffer[1025] = 16'ha783;
 buffer[1026] = 16'hda87;
 buffer[1027] = 16'h9023;
 buffer[1028] = 16'h00b7;
 buffer[1029] = 16'h17b7;
 buffer[1030] = 16'h0000;
 buffer[1031] = 16'ha783;
 buffer[1032] = 16'hda47;
 buffer[1033] = 16'h9023;
 buffer[1034] = 16'h00c7;
 buffer[1035] = 16'h17b7;
 buffer[1036] = 16'h0000;
 buffer[1037] = 16'ha783;
 buffer[1038] = 16'hd9c7;
 buffer[1039] = 16'h9023;
 buffer[1040] = 16'h00d7;
 buffer[1041] = 16'h17b7;
 buffer[1042] = 16'h0000;
 buffer[1043] = 16'ha783;
 buffer[1044] = 16'hd987;
 buffer[1045] = 16'h9023;
 buffer[1046] = 16'h00e7;
 buffer[1047] = 16'h0097;
 buffer[1048] = 16'h0000;
 buffer[1049] = 16'h80e7;
 buffer[1050] = 16'hf880;
 buffer[1051] = 16'h17b7;
 buffer[1052] = 16'h0000;
 buffer[1053] = 16'ha783;
 buffer[1054] = 16'hd8c7;
 buffer[1055] = 16'h470d;
 buffer[1056] = 16'h8023;
 buffer[1057] = 16'h00e7;
 buffer[1058] = 16'h40b2;
 buffer[1059] = 16'h0141;
 buffer[1060] = 16'h8082;
 buffer[1061] = 16'h1141;
 buffer[1062] = 16'hc606;
 buffer[1063] = 16'h4515;
 buffer[1064] = 16'h0097;
 buffer[1065] = 16'h0000;
 buffer[1066] = 16'h80e7;
 buffer[1067] = 16'hf7a0;
 buffer[1068] = 16'h0713;
 buffer[1069] = 16'h1df0;
 buffer[1070] = 16'h0693;
 buffer[1071] = 16'h27f0;
 buffer[1072] = 16'h4601;
 buffer[1073] = 16'h4581;
 buffer[1074] = 16'h0513;
 buffer[1075] = 16'h0400;
 buffer[1076] = 16'h0097;
 buffer[1077] = 16'h0000;
 buffer[1078] = 16'h80e7;
 buffer[1079] = 16'hf860;
 buffer[1080] = 16'h40b2;
 buffer[1081] = 16'h0141;
 buffer[1082] = 16'h8082;
 buffer[1083] = 16'h1141;
 buffer[1084] = 16'hc606;
 buffer[1085] = 16'h17b7;
 buffer[1086] = 16'h0000;
 buffer[1087] = 16'ha783;
 buffer[1088] = 16'hda07;
 buffer[1089] = 16'h8023;
 buffer[1090] = 16'h00a7;
 buffer[1091] = 16'h17b7;
 buffer[1092] = 16'h0000;
 buffer[1093] = 16'ha783;
 buffer[1094] = 16'hda87;
 buffer[1095] = 16'h9023;
 buffer[1096] = 16'h00b7;
 buffer[1097] = 16'h17b7;
 buffer[1098] = 16'h0000;
 buffer[1099] = 16'ha783;
 buffer[1100] = 16'hda47;
 buffer[1101] = 16'h9023;
 buffer[1102] = 16'h00c7;
 buffer[1103] = 16'h17b7;
 buffer[1104] = 16'h0000;
 buffer[1105] = 16'ha783;
 buffer[1106] = 16'hd9c7;
 buffer[1107] = 16'h9023;
 buffer[1108] = 16'h00d7;
 buffer[1109] = 16'h17b7;
 buffer[1110] = 16'h0000;
 buffer[1111] = 16'ha783;
 buffer[1112] = 16'hd987;
 buffer[1113] = 16'h9023;
 buffer[1114] = 16'h00e7;
 buffer[1115] = 16'h0097;
 buffer[1116] = 16'h0000;
 buffer[1117] = 16'h80e7;
 buffer[1118] = 16'hf000;
 buffer[1119] = 16'h17b7;
 buffer[1120] = 16'h0000;
 buffer[1121] = 16'ha783;
 buffer[1122] = 16'hd8c7;
 buffer[1123] = 16'h4709;
 buffer[1124] = 16'h8023;
 buffer[1125] = 16'h00e7;
 buffer[1126] = 16'h40b2;
 buffer[1127] = 16'h0141;
 buffer[1128] = 16'h8082;
 buffer[1129] = 16'h1141;
 buffer[1130] = 16'hc606;
 buffer[1131] = 16'hc422;
 buffer[1132] = 16'h843a;
 buffer[1133] = 16'h17b7;
 buffer[1134] = 16'h0000;
 buffer[1135] = 16'ha783;
 buffer[1136] = 16'hda07;
 buffer[1137] = 16'h8023;
 buffer[1138] = 16'h00a7;
 buffer[1139] = 16'h17b7;
 buffer[1140] = 16'h0000;
 buffer[1141] = 16'ha783;
 buffer[1142] = 16'hda87;
 buffer[1143] = 16'h9023;
 buffer[1144] = 16'h00b7;
 buffer[1145] = 16'h17b7;
 buffer[1146] = 16'h0000;
 buffer[1147] = 16'ha783;
 buffer[1148] = 16'hda47;
 buffer[1149] = 16'h9023;
 buffer[1150] = 16'h00c7;
 buffer[1151] = 16'h17b7;
 buffer[1152] = 16'h0000;
 buffer[1153] = 16'ha783;
 buffer[1154] = 16'hd9c7;
 buffer[1155] = 16'h9023;
 buffer[1156] = 16'h00d7;
 buffer[1157] = 16'h0097;
 buffer[1158] = 16'h0000;
 buffer[1159] = 16'h80e7;
 buffer[1160] = 16'heac0;
 buffer[1161] = 16'h3733;
 buffer[1162] = 16'h0080;
 buffer[1163] = 16'h0711;
 buffer[1164] = 16'h17b7;
 buffer[1165] = 16'h0000;
 buffer[1166] = 16'ha783;
 buffer[1167] = 16'hd8c7;
 buffer[1168] = 16'h8023;
 buffer[1169] = 16'h00e7;
 buffer[1170] = 16'h40b2;
 buffer[1171] = 16'h4422;
 buffer[1172] = 16'h0141;
 buffer[1173] = 16'h8082;
 buffer[1174] = 16'h1141;
 buffer[1175] = 16'hc606;
 buffer[1176] = 16'h17b7;
 buffer[1177] = 16'h0000;
 buffer[1178] = 16'ha783;
 buffer[1179] = 16'hda07;
 buffer[1180] = 16'h8023;
 buffer[1181] = 16'h00a7;
 buffer[1182] = 16'h17b7;
 buffer[1183] = 16'h0000;
 buffer[1184] = 16'ha783;
 buffer[1185] = 16'hda87;
 buffer[1186] = 16'h9023;
 buffer[1187] = 16'h00b7;
 buffer[1188] = 16'h17b7;
 buffer[1189] = 16'h0000;
 buffer[1190] = 16'ha783;
 buffer[1191] = 16'hda47;
 buffer[1192] = 16'h9023;
 buffer[1193] = 16'h00c7;
 buffer[1194] = 16'h17b7;
 buffer[1195] = 16'h0000;
 buffer[1196] = 16'ha783;
 buffer[1197] = 16'hd9c7;
 buffer[1198] = 16'h9023;
 buffer[1199] = 16'h00d7;
 buffer[1200] = 16'h17b7;
 buffer[1201] = 16'h0000;
 buffer[1202] = 16'ha783;
 buffer[1203] = 16'hd987;
 buffer[1204] = 16'h9023;
 buffer[1205] = 16'h00e7;
 buffer[1206] = 16'h0097;
 buffer[1207] = 16'h0000;
 buffer[1208] = 16'h80e7;
 buffer[1209] = 16'he4a0;
 buffer[1210] = 16'h17b7;
 buffer[1211] = 16'h0000;
 buffer[1212] = 16'ha783;
 buffer[1213] = 16'hd8c7;
 buffer[1214] = 16'h471d;
 buffer[1215] = 16'h8023;
 buffer[1216] = 16'h00e7;
 buffer[1217] = 16'h40b2;
 buffer[1218] = 16'h0141;
 buffer[1219] = 16'h8082;
 buffer[1220] = 16'h1141;
 buffer[1221] = 16'hc606;
 buffer[1222] = 16'h17b7;
 buffer[1223] = 16'h0000;
 buffer[1224] = 16'ha783;
 buffer[1225] = 16'hda07;
 buffer[1226] = 16'h8023;
 buffer[1227] = 16'h00a7;
 buffer[1228] = 16'h17b7;
 buffer[1229] = 16'h0000;
 buffer[1230] = 16'ha783;
 buffer[1231] = 16'hda87;
 buffer[1232] = 16'h9023;
 buffer[1233] = 16'h00b7;
 buffer[1234] = 16'h17b7;
 buffer[1235] = 16'h0000;
 buffer[1236] = 16'ha783;
 buffer[1237] = 16'hda47;
 buffer[1238] = 16'h9023;
 buffer[1239] = 16'h00c7;
 buffer[1240] = 16'h17b7;
 buffer[1241] = 16'h0000;
 buffer[1242] = 16'ha783;
 buffer[1243] = 16'hd9c7;
 buffer[1244] = 16'h9023;
 buffer[1245] = 16'h00d7;
 buffer[1246] = 16'h17b7;
 buffer[1247] = 16'h0000;
 buffer[1248] = 16'ha783;
 buffer[1249] = 16'hd987;
 buffer[1250] = 16'h9023;
 buffer[1251] = 16'h00e7;
 buffer[1252] = 16'h0097;
 buffer[1253] = 16'h0000;
 buffer[1254] = 16'h80e7;
 buffer[1255] = 16'hdee0;
 buffer[1256] = 16'h17b7;
 buffer[1257] = 16'h0000;
 buffer[1258] = 16'ha783;
 buffer[1259] = 16'hd8c7;
 buffer[1260] = 16'h4721;
 buffer[1261] = 16'h8023;
 buffer[1262] = 16'h00e7;
 buffer[1263] = 16'h40b2;
 buffer[1264] = 16'h0141;
 buffer[1265] = 16'h8082;
 buffer[1266] = 16'h17b7;
 buffer[1267] = 16'h0000;
 buffer[1268] = 16'ha783;
 buffer[1269] = 16'hd847;
 buffer[1270] = 16'h8023;
 buffer[1271] = 16'h00a7;
 buffer[1272] = 16'h4781;
 buffer[1273] = 16'h1837;
 buffer[1274] = 16'h0000;
 buffer[1275] = 16'h1537;
 buffer[1276] = 16'h0000;
 buffer[1277] = 16'h4641;
 buffer[1278] = 16'h2703;
 buffer[1279] = 16'hd808;
 buffer[1280] = 16'hf693;
 buffer[1281] = 16'h0ff7;
 buffer[1282] = 16'h0023;
 buffer[1283] = 16'h00d7;
 buffer[1284] = 16'h2703;
 buffer[1285] = 16'hd7c5;
 buffer[1286] = 16'hd683;
 buffer[1287] = 16'h0005;
 buffer[1288] = 16'h1023;
 buffer[1289] = 16'h00d7;
 buffer[1290] = 16'h0785;
 buffer[1291] = 16'h0589;
 buffer[1292] = 16'h92e3;
 buffer[1293] = 16'hfec7;
 buffer[1294] = 16'h8082;
 buffer[1295] = 16'h1141;
 buffer[1296] = 16'hc606;
 buffer[1297] = 16'h18b7;
 buffer[1298] = 16'h0000;
 buffer[1299] = 16'ha883;
 buffer[1300] = 16'hda08;
 buffer[1301] = 16'h8023;
 buffer[1302] = 16'h00a8;
 buffer[1303] = 16'h1537;
 buffer[1304] = 16'h0000;
 buffer[1305] = 16'h2503;
 buffer[1306] = 16'hda85;
 buffer[1307] = 16'h1023;
 buffer[1308] = 16'h00b5;
 buffer[1309] = 16'h15b7;
 buffer[1310] = 16'h0000;
 buffer[1311] = 16'ha583;
 buffer[1312] = 16'hda45;
 buffer[1313] = 16'h9023;
 buffer[1314] = 16'h00c5;
 buffer[1315] = 16'h1637;
 buffer[1316] = 16'h0000;
 buffer[1317] = 16'h2603;
 buffer[1318] = 16'hd9c6;
 buffer[1319] = 16'h1023;
 buffer[1320] = 16'h00d6;
 buffer[1321] = 16'h16b7;
 buffer[1322] = 16'h0000;
 buffer[1323] = 16'ha683;
 buffer[1324] = 16'hd986;
 buffer[1325] = 16'h9023;
 buffer[1326] = 16'h00e6;
 buffer[1327] = 16'h1737;
 buffer[1328] = 16'h0000;
 buffer[1329] = 16'h2703;
 buffer[1330] = 16'hd947;
 buffer[1331] = 16'h1023;
 buffer[1332] = 16'h00f7;
 buffer[1333] = 16'h17b7;
 buffer[1334] = 16'h0000;
 buffer[1335] = 16'ha783;
 buffer[1336] = 16'hd907;
 buffer[1337] = 16'h9023;
 buffer[1338] = 16'h0107;
 buffer[1339] = 16'h0097;
 buffer[1340] = 16'h0000;
 buffer[1341] = 16'h80e7;
 buffer[1342] = 16'hd400;
 buffer[1343] = 16'h17b7;
 buffer[1344] = 16'h0000;
 buffer[1345] = 16'ha783;
 buffer[1346] = 16'hd8c7;
 buffer[1347] = 16'h4719;
 buffer[1348] = 16'h8023;
 buffer[1349] = 16'h00e7;
 buffer[1350] = 16'h40b2;
 buffer[1351] = 16'h0141;
 buffer[1352] = 16'h8082;
 buffer[1353] = 16'h17b7;
 buffer[1354] = 16'h0000;
 buffer[1355] = 16'ha703;
 buffer[1356] = 16'hcc87;
 buffer[1357] = 16'h4783;
 buffer[1358] = 16'h0007;
 buffer[1359] = 16'hf793;
 buffer[1360] = 16'h0ff7;
 buffer[1361] = 16'hffe5;
 buffer[1362] = 16'h478d;
 buffer[1363] = 16'h0023;
 buffer[1364] = 16'h00f7;
 buffer[1365] = 16'h8082;
 buffer[1366] = 16'h17b7;
 buffer[1367] = 16'h0000;
 buffer[1368] = 16'ha703;
 buffer[1369] = 16'hcc87;
 buffer[1370] = 16'h4783;
 buffer[1371] = 16'h0007;
 buffer[1372] = 16'hf793;
 buffer[1373] = 16'h0ff7;
 buffer[1374] = 16'hffe5;
 buffer[1375] = 16'h17b7;
 buffer[1376] = 16'h0000;
 buffer[1377] = 16'ha783;
 buffer[1378] = 16'hcd87;
 buffer[1379] = 16'h8023;
 buffer[1380] = 16'h00a7;
 buffer[1381] = 16'h17b7;
 buffer[1382] = 16'h0000;
 buffer[1383] = 16'ha783;
 buffer[1384] = 16'hcc87;
 buffer[1385] = 16'h4711;
 buffer[1386] = 16'h8023;
 buffer[1387] = 16'h00e7;
 buffer[1388] = 16'h8082;
 buffer[1389] = 16'h17b7;
 buffer[1390] = 16'h0000;
 buffer[1391] = 16'ha703;
 buffer[1392] = 16'hcc87;
 buffer[1393] = 16'h4783;
 buffer[1394] = 16'h0007;
 buffer[1395] = 16'hf793;
 buffer[1396] = 16'h0ff7;
 buffer[1397] = 16'hffe5;
 buffer[1398] = 16'h17b7;
 buffer[1399] = 16'h0000;
 buffer[1400] = 16'ha783;
 buffer[1401] = 16'hcdc7;
 buffer[1402] = 16'h8023;
 buffer[1403] = 16'h00a7;
 buffer[1404] = 16'h17b7;
 buffer[1405] = 16'h0000;
 buffer[1406] = 16'ha783;
 buffer[1407] = 16'hcd87;
 buffer[1408] = 16'h8023;
 buffer[1409] = 16'h00b7;
 buffer[1410] = 16'h17b7;
 buffer[1411] = 16'h0000;
 buffer[1412] = 16'ha783;
 buffer[1413] = 16'hcd07;
 buffer[1414] = 16'h8023;
 buffer[1415] = 16'h00c7;
 buffer[1416] = 16'h17b7;
 buffer[1417] = 16'h0000;
 buffer[1418] = 16'ha783;
 buffer[1419] = 16'hccc7;
 buffer[1420] = 16'h8023;
 buffer[1421] = 16'h00d7;
 buffer[1422] = 16'h17b7;
 buffer[1423] = 16'h0000;
 buffer[1424] = 16'ha783;
 buffer[1425] = 16'hcc87;
 buffer[1426] = 16'h4705;
 buffer[1427] = 16'h8023;
 buffer[1428] = 16'h00e7;
 buffer[1429] = 16'h8082;
 buffer[1430] = 16'h17b7;
 buffer[1431] = 16'h0000;
 buffer[1432] = 16'ha703;
 buffer[1433] = 16'hcc87;
 buffer[1434] = 16'h4783;
 buffer[1435] = 16'h0007;
 buffer[1436] = 16'hf793;
 buffer[1437] = 16'h0ff7;
 buffer[1438] = 16'hffe5;
 buffer[1439] = 16'h17b7;
 buffer[1440] = 16'h0000;
 buffer[1441] = 16'ha783;
 buffer[1442] = 16'hcd47;
 buffer[1443] = 16'h8023;
 buffer[1444] = 16'h00a7;
 buffer[1445] = 16'h17b7;
 buffer[1446] = 16'h0000;
 buffer[1447] = 16'ha783;
 buffer[1448] = 16'hcc87;
 buffer[1449] = 16'h4709;
 buffer[1450] = 16'h8023;
 buffer[1451] = 16'h00e7;
 buffer[1452] = 16'h8082;
 buffer[1453] = 16'h4683;
 buffer[1454] = 16'h0005;
 buffer[1455] = 16'hca8d;
 buffer[1456] = 16'h1637;
 buffer[1457] = 16'h0000;
 buffer[1458] = 16'h1837;
 buffer[1459] = 16'h0000;
 buffer[1460] = 16'h4589;
 buffer[1461] = 16'h2703;
 buffer[1462] = 16'hcc86;
 buffer[1463] = 16'h4783;
 buffer[1464] = 16'h0007;
 buffer[1465] = 16'hf793;
 buffer[1466] = 16'h0ff7;
 buffer[1467] = 16'hffe5;
 buffer[1468] = 16'h2783;
 buffer[1469] = 16'hcd48;
 buffer[1470] = 16'h8023;
 buffer[1471] = 16'h00d7;
 buffer[1472] = 16'h2783;
 buffer[1473] = 16'hcc86;
 buffer[1474] = 16'h8023;
 buffer[1475] = 16'h00b7;
 buffer[1476] = 16'h0505;
 buffer[1477] = 16'h4683;
 buffer[1478] = 16'h0005;
 buffer[1479] = 16'hfef1;
 buffer[1480] = 16'h8082;
 buffer[1481] = 16'h1101;
 buffer[1482] = 16'hce06;
 buffer[1483] = 16'hcc22;
 buffer[1484] = 16'hca26;
 buffer[1485] = 16'hc84a;
 buffer[1486] = 16'hc64e;
 buffer[1487] = 16'h84aa;
 buffer[1488] = 16'h892e;
 buffer[1489] = 16'h89b2;
 buffer[1490] = 16'h8436;
 buffer[1491] = 16'h0097;
 buffer[1492] = 16'h0000;
 buffer[1493] = 16'h80e7;
 buffer[1494] = 16'hf060;
 buffer[1495] = 16'h8522;
 buffer[1496] = 16'h0097;
 buffer[1497] = 16'h0000;
 buffer[1498] = 16'h80e7;
 buffer[1499] = 16'h8d20;
 buffer[1500] = 16'h8505;
 buffer[1501] = 16'h0793;
 buffer[1502] = 16'h0280;
 buffer[1503] = 16'h8533;
 buffer[1504] = 16'h40a7;
 buffer[1505] = 16'h86ce;
 buffer[1506] = 16'h864a;
 buffer[1507] = 16'h85a6;
 buffer[1508] = 16'h7513;
 buffer[1509] = 16'h0ff5;
 buffer[1510] = 16'h0097;
 buffer[1511] = 16'h0000;
 buffer[1512] = 16'h80e7;
 buffer[1513] = 16'hf0e0;
 buffer[1514] = 16'h8522;
 buffer[1515] = 16'h0097;
 buffer[1516] = 16'h0000;
 buffer[1517] = 16'h80e7;
 buffer[1518] = 16'hf840;
 buffer[1519] = 16'h40f2;
 buffer[1520] = 16'h4462;
 buffer[1521] = 16'h44d2;
 buffer[1522] = 16'h4942;
 buffer[1523] = 16'h49b2;
 buffer[1524] = 16'h6105;
 buffer[1525] = 16'h8082;
 buffer[1526] = 16'h1101;
 buffer[1527] = 16'hce06;
 buffer[1528] = 16'h27b7;
 buffer[1529] = 16'h0030;
 buffer[1530] = 16'h8793;
 buffer[1531] = 16'h0207;
 buffer[1532] = 16'hc63e;
 buffer[1533] = 16'h006c;
 buffer[1534] = 16'h0097;
 buffer[1535] = 16'h0000;
 buffer[1536] = 16'h80e7;
 buffer[1537] = 16'h8d60;
 buffer[1538] = 16'h0068;
 buffer[1539] = 16'h0097;
 buffer[1540] = 16'h0000;
 buffer[1541] = 16'h80e7;
 buffer[1542] = 16'hf540;
 buffer[1543] = 16'h40f2;
 buffer[1544] = 16'h6105;
 buffer[1545] = 16'h8082;
 buffer[1546] = 16'h1101;
 buffer[1547] = 16'hce06;
 buffer[1548] = 16'h27b7;
 buffer[1549] = 16'h2020;
 buffer[1550] = 16'h8793;
 buffer[1551] = 16'h0207;
 buffer[1552] = 16'hc43e;
 buffer[1553] = 16'h0793;
 buffer[1554] = 16'h0300;
 buffer[1555] = 16'h1623;
 buffer[1556] = 16'h00f1;
 buffer[1557] = 16'h002c;
 buffer[1558] = 16'h0097;
 buffer[1559] = 16'h0000;
 buffer[1560] = 16'h80e7;
 buffer[1561] = 16'h8d40;
 buffer[1562] = 16'h0028;
 buffer[1563] = 16'h0097;
 buffer[1564] = 16'h0000;
 buffer[1565] = 16'h80e7;
 buffer[1566] = 16'hf240;
 buffer[1567] = 16'h40f2;
 buffer[1568] = 16'h6105;
 buffer[1569] = 16'h8082;
 buffer[1570] = 16'h1101;
 buffer[1571] = 16'hce06;
 buffer[1572] = 16'h17b7;
 buffer[1573] = 16'h0000;
 buffer[1574] = 16'h8793;
 buffer[1575] = 16'hf807;
 buffer[1576] = 16'h4394;
 buffer[1577] = 16'h43d8;
 buffer[1578] = 16'hc236;
 buffer[1579] = 16'hc43a;
 buffer[1580] = 16'hd703;
 buffer[1581] = 16'h0087;
 buffer[1582] = 16'h1623;
 buffer[1583] = 16'h00e1;
 buffer[1584] = 16'hc783;
 buffer[1585] = 16'h00a7;
 buffer[1586] = 16'h0723;
 buffer[1587] = 16'h00f1;
 buffer[1588] = 16'h004c;
 buffer[1589] = 16'h0097;
 buffer[1590] = 16'h0000;
 buffer[1591] = 16'h80e7;
 buffer[1592] = 16'h8c40;
 buffer[1593] = 16'h0048;
 buffer[1594] = 16'h0097;
 buffer[1595] = 16'h0000;
 buffer[1596] = 16'h80e7;
 buffer[1597] = 16'hee60;
 buffer[1598] = 16'h40f2;
 buffer[1599] = 16'h6105;
 buffer[1600] = 16'h8082;
 buffer[1601] = 16'h17b7;
 buffer[1602] = 16'h0000;
 buffer[1603] = 16'ha783;
 buffer[1604] = 16'hde87;
 buffer[1605] = 16'h8023;
 buffer[1606] = 16'h00a7;
 buffer[1607] = 16'h8082;
 buffer[1608] = 16'h8ff0;
 buffer[1609] = 16'h0000;
 buffer[1610] = 16'h8930;
 buffer[1611] = 16'h0000;
 buffer[1612] = 16'h8920;
 buffer[1613] = 16'h0000;
 buffer[1614] = 16'h8910;
 buffer[1615] = 16'h0000;
 buffer[1616] = 16'h8904;
 buffer[1617] = 16'h0000;
 buffer[1618] = 16'h8900;
 buffer[1619] = 16'h0000;
 buffer[1620] = 16'h881c;
 buffer[1621] = 16'h0000;
 buffer[1622] = 16'h8818;
 buffer[1623] = 16'h0000;
 buffer[1624] = 16'h8814;
 buffer[1625] = 16'h0000;
 buffer[1626] = 16'h8810;
 buffer[1627] = 16'h0000;
 buffer[1628] = 16'h880c;
 buffer[1629] = 16'h0000;
 buffer[1630] = 16'h8808;
 buffer[1631] = 16'h0000;
 buffer[1632] = 16'h8804;
 buffer[1633] = 16'h0000;
 buffer[1634] = 16'h8800;
 buffer[1635] = 16'h0000;
 buffer[1636] = 16'h8614;
 buffer[1637] = 16'h0000;
 buffer[1638] = 16'h8610;
 buffer[1639] = 16'h0000;
 buffer[1640] = 16'h860c;
 buffer[1641] = 16'h0000;
 buffer[1642] = 16'h8608;
 buffer[1643] = 16'h0000;
 buffer[1644] = 16'h8604;
 buffer[1645] = 16'h0000;
 buffer[1646] = 16'h8600;
 buffer[1647] = 16'h0000;
 buffer[1648] = 16'h8530;
 buffer[1649] = 16'h0000;
 buffer[1650] = 16'h8528;
 buffer[1651] = 16'h0000;
 buffer[1652] = 16'h8524;
 buffer[1653] = 16'h0000;
 buffer[1654] = 16'h8520;
 buffer[1655] = 16'h0000;
 buffer[1656] = 16'h851c;
 buffer[1657] = 16'h0000;
 buffer[1658] = 16'h8518;
 buffer[1659] = 16'h0000;
 buffer[1660] = 16'h8514;
 buffer[1661] = 16'h0000;
 buffer[1662] = 16'h8510;
 buffer[1663] = 16'h0000;
 buffer[1664] = 16'h850c;
 buffer[1665] = 16'h0000;
 buffer[1666] = 16'h8508;
 buffer[1667] = 16'h0000;
 buffer[1668] = 16'h8504;
 buffer[1669] = 16'h0000;
 buffer[1670] = 16'h8500;
 buffer[1671] = 16'h0000;
 buffer[1672] = 16'h8330;
 buffer[1673] = 16'h0000;
 buffer[1674] = 16'h8328;
 buffer[1675] = 16'h0000;
 buffer[1676] = 16'h8324;
 buffer[1677] = 16'h0000;
 buffer[1678] = 16'h8320;
 buffer[1679] = 16'h0000;
 buffer[1680] = 16'h831c;
 buffer[1681] = 16'h0000;
 buffer[1682] = 16'h8318;
 buffer[1683] = 16'h0000;
 buffer[1684] = 16'h8314;
 buffer[1685] = 16'h0000;
 buffer[1686] = 16'h8310;
 buffer[1687] = 16'h0000;
 buffer[1688] = 16'h830c;
 buffer[1689] = 16'h0000;
 buffer[1690] = 16'h8308;
 buffer[1691] = 16'h0000;
 buffer[1692] = 16'h8304;
 buffer[1693] = 16'h0000;
 buffer[1694] = 16'h8300;
 buffer[1695] = 16'h0000;
 buffer[1696] = 16'h8474;
 buffer[1697] = 16'h0000;
 buffer[1698] = 16'h8470;
 buffer[1699] = 16'h0000;
 buffer[1700] = 16'h8470;
 buffer[1701] = 16'h0000;
 buffer[1702] = 16'h8460;
 buffer[1703] = 16'h0000;
 buffer[1704] = 16'h8440;
 buffer[1705] = 16'h0000;
 buffer[1706] = 16'h843c;
 buffer[1707] = 16'h0000;
 buffer[1708] = 16'h8444;
 buffer[1709] = 16'h0000;
 buffer[1710] = 16'h8438;
 buffer[1711] = 16'h0000;
 buffer[1712] = 16'h8434;
 buffer[1713] = 16'h0000;
 buffer[1714] = 16'h8448;
 buffer[1715] = 16'h0000;
 buffer[1716] = 16'h8430;
 buffer[1717] = 16'h0000;
 buffer[1718] = 16'h842c;
 buffer[1719] = 16'h0000;
 buffer[1720] = 16'h8428;
 buffer[1721] = 16'h0000;
 buffer[1722] = 16'h8424;
 buffer[1723] = 16'h0000;
 buffer[1724] = 16'h8420;
 buffer[1725] = 16'h0000;
 buffer[1726] = 16'h8458;
 buffer[1727] = 16'h0000;
 buffer[1728] = 16'h8454;
 buffer[1729] = 16'h0000;
 buffer[1730] = 16'h8450;
 buffer[1731] = 16'h0000;
 buffer[1732] = 16'h841c;
 buffer[1733] = 16'h0000;
 buffer[1734] = 16'h841c;
 buffer[1735] = 16'h0000;
 buffer[1736] = 16'h8418;
 buffer[1737] = 16'h0000;
 buffer[1738] = 16'h8414;
 buffer[1739] = 16'h0000;
 buffer[1740] = 16'h8410;
 buffer[1741] = 16'h0000;
 buffer[1742] = 16'h840c;
 buffer[1743] = 16'h0000;
 buffer[1744] = 16'h8408;
 buffer[1745] = 16'h0000;
 buffer[1746] = 16'h8404;
 buffer[1747] = 16'h0000;
 buffer[1748] = 16'h8400;
 buffer[1749] = 16'h0000;
 buffer[1750] = 16'h8234;
 buffer[1751] = 16'h0000;
 buffer[1752] = 16'h8230;
 buffer[1753] = 16'h0000;
 buffer[1754] = 16'h8228;
 buffer[1755] = 16'h0000;
 buffer[1756] = 16'h8224;
 buffer[1757] = 16'h0000;
 buffer[1758] = 16'h8220;
 buffer[1759] = 16'h0000;
 buffer[1760] = 16'h8214;
 buffer[1761] = 16'h0000;
 buffer[1762] = 16'h8210;
 buffer[1763] = 16'h0000;
 buffer[1764] = 16'h820c;
 buffer[1765] = 16'h0000;
 buffer[1766] = 16'h8208;
 buffer[1767] = 16'h0000;
 buffer[1768] = 16'h8204;
 buffer[1769] = 16'h0000;
 buffer[1770] = 16'h8200;
 buffer[1771] = 16'h0000;
 buffer[1772] = 16'h8108;
 buffer[1773] = 16'h0000;
 buffer[1774] = 16'h8104;
 buffer[1775] = 16'h0000;
 buffer[1776] = 16'h8100;
 buffer[1777] = 16'h0000;
 buffer[1778] = 16'h8700;
 buffer[1779] = 16'h0000;
 buffer[1780] = 16'h8704;
 buffer[1781] = 16'h0000;
 buffer[1782] = 16'h8700;
 buffer[1783] = 16'h0000;
 buffer[1784] = 16'h8f10;
 buffer[1785] = 16'h0000;
 buffer[1786] = 16'h8f10;
 buffer[1787] = 16'h0000;
 buffer[1788] = 16'h8f04;
 buffer[1789] = 16'h0000;
 buffer[1790] = 16'h8f08;
 buffer[1791] = 16'h0000;
 buffer[1792] = 16'h8f00;
 buffer[1793] = 16'h0000;
 buffer[1794] = 16'h8f00;
 buffer[1795] = 16'h0000;
 buffer[1796] = 16'h800c;
 buffer[1797] = 16'h0000;
 buffer[1798] = 16'h8008;
 buffer[1799] = 16'h0000;
 buffer[1800] = 16'h8000;
 buffer[1801] = 16'h0000;
 buffer[1802] = 16'h8004;
 buffer[1803] = 16'h0000;
 buffer[1804] = 16'h654d;
 buffer[1805] = 16'h6f6d;
 buffer[1806] = 16'h7972;
 buffer[1807] = 16'h4420;
 buffer[1808] = 16'h6d75;
 buffer[1809] = 16'h2070;
 buffer[1810] = 16'h2038;
 buffer[1811] = 16'h6962;
 buffer[1812] = 16'h0074;
 buffer[1813] = 16'h0000;
 buffer[1814] = 16'h654d;
 buffer[1815] = 16'h6f6d;
 buffer[1816] = 16'h7972;
 buffer[1817] = 16'h4420;
 buffer[1818] = 16'h6d75;
 buffer[1819] = 16'h2070;
 buffer[1820] = 16'h3631;
 buffer[1821] = 16'h6220;
 buffer[1822] = 16'h7469;
 buffer[1823] = 16'h0000;
 buffer[1824] = 16'h6557;
 buffer[1825] = 16'h636c;
 buffer[1826] = 16'h6d6f;
 buffer[1827] = 16'h2065;
 buffer[1828] = 16'h6f74;
 buffer[1829] = 16'h5020;
 buffer[1830] = 16'h5741;
 buffer[1831] = 16'h2053;
 buffer[1832] = 16'h2061;
 buffer[1833] = 16'h4952;
 buffer[1834] = 16'h4353;
 buffer[1835] = 16'h562d;
 buffer[1836] = 16'h5220;
 buffer[1837] = 16'h3356;
 buffer[1838] = 16'h4932;
 buffer[1839] = 16'h434d;
 buffer[1840] = 16'h4320;
 buffer[1841] = 16'h5550;
 buffer[1842] = 16'h0000;
 buffer[1843] = 16'h0000;
 buffer[1844] = 16'h4d0a;
 buffer[1845] = 16'h4d45;
 buffer[1846] = 16'h524f;
 buffer[1847] = 16'h2059;
 buffer[1848] = 16'h5544;
 buffer[1849] = 16'h504d;
 buffer[1850] = 16'h4620;
 buffer[1851] = 16'h4f52;
 buffer[1852] = 16'h204d;
 buffer[1853] = 16'h7830;
 buffer[1854] = 16'h3031;
 buffer[1855] = 16'h3030;
 buffer[1856] = 16'h3030;
 buffer[1857] = 16'h3030;
 buffer[1858] = 16'h4320;
 buffer[1859] = 16'h4341;
 buffer[1860] = 16'h4548;
 buffer[1861] = 16'h0000;
 buffer[1862] = 16'h0a0a;
 buffer[1863] = 16'h454d;
 buffer[1864] = 16'h4f4d;
 buffer[1865] = 16'h5952;
 buffer[1866] = 16'h4420;
 buffer[1867] = 16'h4d55;
 buffer[1868] = 16'h2050;
 buffer[1869] = 16'h3631;
 buffer[1870] = 16'h4620;
 buffer[1871] = 16'h4f52;
 buffer[1872] = 16'h204d;
 buffer[1873] = 16'h7830;
 buffer[1874] = 16'h3031;
 buffer[1875] = 16'h3030;
 buffer[1876] = 16'h3130;
 buffer[1877] = 16'h3030;
 buffer[1878] = 16'h4320;
 buffer[1879] = 16'h4341;
 buffer[1880] = 16'h4548;
 buffer[1881] = 16'h0000;
 buffer[1882] = 16'h520a;
 buffer[1883] = 16'h5045;
 buffer[1884] = 16'h4145;
 buffer[1885] = 16'h2054;
 buffer[1886] = 16'h454d;
 buffer[1887] = 16'h4f4d;
 buffer[1888] = 16'h5952;
 buffer[1889] = 16'h4420;
 buffer[1890] = 16'h4d55;
 buffer[1891] = 16'h5350;
 buffer[1892] = 16'h000a;
 buffer[1893] = 16'h0000;
 buffer[1894] = 16'h4d0a;
 buffer[1895] = 16'h4d45;
 buffer[1896] = 16'h524f;
 buffer[1897] = 16'h2059;
 buffer[1898] = 16'h5544;
 buffer[1899] = 16'h504d;
 buffer[1900] = 16'h4620;
 buffer[1901] = 16'h4f52;
 buffer[1902] = 16'h204d;
 buffer[1903] = 16'h7830;
 buffer[1904] = 16'h3031;
 buffer[1905] = 16'h3030;
 buffer[1906] = 16'h3030;
 buffer[1907] = 16'h3030;
 buffer[1908] = 16'h5320;
 buffer[1909] = 16'h5244;
 buffer[1910] = 16'h4d41;
 buffer[1911] = 16'h7620;
 buffer[1912] = 16'h6169;
 buffer[1913] = 16'h4320;
 buffer[1914] = 16'h4341;
 buffer[1915] = 16'h4548;
 buffer[1916] = 16'h0000;
 buffer[1917] = 16'h0000;
 buffer[1918] = 16'h0a0a;
 buffer[1919] = 16'h454d;
 buffer[1920] = 16'h4f4d;
 buffer[1921] = 16'h5952;
 buffer[1922] = 16'h4420;
 buffer[1923] = 16'h4d55;
 buffer[1924] = 16'h2050;
 buffer[1925] = 16'h3631;
 buffer[1926] = 16'h4620;
 buffer[1927] = 16'h4f52;
 buffer[1928] = 16'h204d;
 buffer[1929] = 16'h7830;
 buffer[1930] = 16'h3031;
 buffer[1931] = 16'h3030;
 buffer[1932] = 16'h3130;
 buffer[1933] = 16'h3030;
 buffer[1934] = 16'h5320;
 buffer[1935] = 16'h5244;
 buffer[1936] = 16'h4d41;
 buffer[1937] = 16'h7620;
 buffer[1938] = 16'h6169;
 buffer[1939] = 16'h4320;
 buffer[1940] = 16'h4341;
 buffer[1941] = 16'h4548;
 buffer[1942] = 16'h0000;
 buffer[1943] = 16'h0000;
 buffer[1944] = 16'h430a;
 buffer[1945] = 16'h4f4c;
 buffer[1946] = 16'h4b43;
 buffer[1947] = 16'h4320;
 buffer[1948] = 16'h4359;
 buffer[1949] = 16'h454c;
 buffer[1950] = 16'h3a53;
 buffer[1951] = 16'h0020;
 buffer[1952] = 16'h4920;
 buffer[1953] = 16'h534e;
 buffer[1954] = 16'h5254;
 buffer[1955] = 16'h4355;
 buffer[1956] = 16'h4954;
 buffer[1957] = 16'h4e4f;
 buffer[1958] = 16'h3a53;
 buffer[1959] = 16'h0020;
 buffer[1960] = 16'h0a0a;
 buffer[1961] = 16'h6554;
 buffer[1962] = 16'h6d72;
 buffer[1963] = 16'h6e69;
 buffer[1964] = 16'h6c61;
 buffer[1965] = 16'h4520;
 buffer[1966] = 16'h6863;
 buffer[1967] = 16'h206f;
 buffer[1968] = 16'h7453;
 buffer[1969] = 16'h7261;
 buffer[1970] = 16'h6974;
 buffer[1971] = 16'h676e;
 buffer[1972] = 16'h0000;
 buffer[1973] = 16'h0000;
 buffer[1974] = 16'h6f59;
 buffer[1975] = 16'h2075;
 buffer[1976] = 16'h7270;
 buffer[1977] = 16'h7365;
 buffer[1978] = 16'h6573;
 buffer[1979] = 16'h2064;
 buffer[1980] = 16'h203a;
 buffer[1981] = 16'h0000;
 buffer[1982] = 16'h3c20;
 buffer[1983] = 16'h002d;
 buffer[1984] = 16'h2020;
 buffer[1985] = 16'h2020;
 buffer[1986] = 16'h2020;
 buffer[1987] = 16'h2020;
 buffer[1988] = 16'h3020;
 buffer[1989] = 16'h0000;
end

endmodule

module M_bramcontroller (
in_address,
in_function3,
in_writeflag,
in_writedata,
in_readflag,
out_readdata,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [31:0] in_address;
input  [2:0] in_function3;
input  [0:0] in_writeflag;
input  [15:0] in_writedata;
input  [0:0] in_readflag;
output  [15:0] out_readdata;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [15:0] _w_mem_ram_rdata;
reg  [0:0] _t_ram_wenable;
reg  [15:0] _t_ram_wdata;
reg  [13:0] _t_ram_addr;

reg  [15:0] _d_readdata,_q_readdata;
reg  [2:0] _d_index,_q_index;
assign out_readdata = _q_readdata;
assign out_done = (_q_index == 5);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_readdata <= _d_readdata;
_q_index <= _d_index;
  end
end


M_bramcontroller_mem_ram __mem__ram(
.clock(clock),
.in_ram_wenable(_t_ram_wenable),
.in_ram_wdata(_t_ram_wdata),
.in_ram_addr(_t_ram_addr),
.out_ram_rdata(_w_mem_ram_rdata)
);


always @* begin
_d_readdata = _q_readdata;
_d_index = _q_index;
_t_ram_wenable = 0;
_t_ram_wdata = 0;
_t_ram_addr = 0;
// _always_pre
_t_ram_wenable = 0;
_t_ram_addr = in_address[1+:15];
_d_readdata = _w_mem_ram_rdata;
_d_index = 5;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_t_ram_wenable = 0;
_t_ram_wdata = 0;
_t_ram_addr = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_writeflag) begin
// __block_5
// __block_7
if ((in_function3&3)==0) begin
// __block_8
// __block_10
_d_index = 4;
end else begin
// __block_9
_d_index = 3;
end
end else begin
// __block_6
_d_index = 1;
end
end else begin
_d_index = 2;
end
end
4: begin
// __block_11
// __block_12
_d_index = 3;
end
3: begin
// __block_13
_t_ram_wdata = ((in_function3&3)==0)?(in_address[0+:1]?{in_writedata[0+:8],_w_mem_ram_rdata[0+:8]}:{_w_mem_ram_rdata[8+:8],in_writedata[0+:8]}):in_writedata;
_t_ram_wenable = 1;
// __block_14
_d_index = 1;
end
2: begin
// __block_3
_d_index = 5;
end
5: begin // end of bramcontroller
end
default: begin 
_d_index = 5;
 end
endcase
end
endmodule


module M_sdramcontroller_mem_Dcachedata(
input                  [0:0] in_Dcachedata_wenable,
input       [15:0]    in_Dcachedata_wdata,
input                  [10:0]    in_Dcachedata_addr,
output reg  [15:0]    out_Dcachedata_rdata,
input                                      clock
);
reg  [15:0] buffer[2047:0];
always @(posedge clock) begin
  if (in_Dcachedata_wenable) begin
    buffer[in_Dcachedata_addr] <= in_Dcachedata_wdata;
  end
  out_Dcachedata_rdata <= buffer[in_Dcachedata_addr];
end

endmodule

module M_sdramcontroller_mem_Dcachetag(
input                  [0:0] in_Dcachetag_wenable,
input       [14:0]    in_Dcachetag_wdata,
input                  [10:0]    in_Dcachetag_addr,
output reg  [14:0]    out_Dcachetag_rdata,
input                                      clock
);
reg  [14:0] buffer[2047:0];
always @(posedge clock) begin
  if (in_Dcachetag_wenable) begin
    buffer[in_Dcachetag_addr] <= in_Dcachetag_wdata;
  end
  out_Dcachetag_rdata <= buffer[in_Dcachetag_addr];
end

endmodule

module M_sdramcontroller_mem_Icachedata(
input                  [0:0] in_Icachedata_wenable,
input       [15:0]    in_Icachedata_wdata,
input                  [10:0]    in_Icachedata_addr,
output reg  [15:0]    out_Icachedata_rdata,
input                                      clock
);
reg  [15:0] buffer[2047:0];
always @(posedge clock) begin
  if (in_Icachedata_wenable) begin
    buffer[in_Icachedata_addr] <= in_Icachedata_wdata;
  end
  out_Icachedata_rdata <= buffer[in_Icachedata_addr];
end

endmodule

module M_sdramcontroller_mem_Icachetag(
input                  [0:0] in_Icachetag_wenable,
input       [14:0]    in_Icachetag_wdata,
input                  [10:0]    in_Icachetag_addr,
output reg  [14:0]    out_Icachetag_rdata,
input                                      clock
);
reg  [14:0] buffer[2047:0];
always @(posedge clock) begin
  if (in_Icachetag_wenable) begin
    buffer[in_Icachetag_addr] <= in_Icachetag_wdata;
  end
  out_Icachetag_rdata <= buffer[in_Icachetag_addr];
end

endmodule

module M_sdramcontroller #(
parameter SIO_ADDR_WIDTH=1,parameter SIO_ADDR_SIGNED=0,parameter SIO_ADDR_INIT=0,
parameter SIO_RW_WIDTH=1,parameter SIO_RW_SIGNED=0,parameter SIO_RW_INIT=0,
parameter SIO_DATA_IN_WIDTH=1,parameter SIO_DATA_IN_SIGNED=0,parameter SIO_DATA_IN_INIT=0,
parameter SIO_IN_VALID_WIDTH=1,parameter SIO_IN_VALID_SIGNED=0,parameter SIO_IN_VALID_INIT=0,
parameter SIO_DATA_OUT_WIDTH=1,parameter SIO_DATA_OUT_SIGNED=0,parameter SIO_DATA_OUT_INIT=0,
parameter SIO_DONE_WIDTH=1,parameter SIO_DONE_SIGNED=0,parameter SIO_DONE_INIT=0
) (
in_sio_data_out,
in_sio_done,
in_address,
in_function3,
in_writeflag,
in_writedata,
in_readflag,
in_Icache,
out_sio_addr,
out_sio_rw,
out_sio_data_in,
out_sio_in_valid,
out_readdata,
out_busy,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [SIO_DATA_OUT_WIDTH-1:0] in_sio_data_out;
input  [SIO_DONE_WIDTH-1:0] in_sio_done;
input  [31:0] in_address;
input  [2:0] in_function3;
input  [0:0] in_writeflag;
input  [15:0] in_writedata;
input  [0:0] in_readflag;
input  [0:0] in_Icache;
output  [SIO_ADDR_WIDTH-1:0] out_sio_addr;
output  [SIO_RW_WIDTH-1:0] out_sio_rw;
output  [SIO_DATA_IN_WIDTH-1:0] out_sio_data_in;
output  [SIO_IN_VALID_WIDTH-1:0] out_sio_in_valid;
output  [15:0] out_readdata;
output  [0:0] out_busy;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [15:0] _w_mem_Dcachedata_rdata;
wire  [14:0] _w_mem_Dcachetag_rdata;
wire  [15:0] _w_mem_Icachedata_rdata;
wire  [14:0] _w_mem_Icachetag_rdata;
reg  [0:0] _t_Dcachedata_wenable;
reg  [15:0] _t_Dcachedata_wdata;
reg  [10:0] _t_Dcachedata_addr;
reg  [0:0] _t_Dcachetag_wenable;
reg  [14:0] _t_Dcachetag_wdata;
reg  [10:0] _t_Dcachetag_addr;
reg  [0:0] _t_Icachedata_wenable;
reg  [15:0] _t_Icachedata_wdata;
reg  [10:0] _t_Icachedata_addr;
reg  [0:0] _t_Icachetag_wenable;
reg  [14:0] _t_Icachetag_wdata;
reg  [10:0] _t_Icachetag_addr;
wire  [0:0] _w_Icachetagmatch;
wire  [0:0] _w_Dcachetagmatch;

reg  [0:0] _d_active;
reg  [0:0] _q_active;
reg  [SIO_ADDR_WIDTH-1:0] _d_sio_addr,_q_sio_addr;
reg  [SIO_RW_WIDTH-1:0] _d_sio_rw,_q_sio_rw;
reg  [SIO_DATA_IN_WIDTH-1:0] _d_sio_data_in,_q_sio_data_in;
reg  [SIO_IN_VALID_WIDTH-1:0] _d_sio_in_valid,_q_sio_in_valid;
reg  [15:0] _d_readdata,_q_readdata;
reg  [0:0] _d_busy,_q_busy;
reg  [3:0] _d_index,_q_index;
assign out_sio_addr = _q_sio_addr;
assign out_sio_rw = _q_sio_rw;
assign out_sio_data_in = _q_sio_data_in;
assign out_sio_in_valid = _q_sio_in_valid;
assign out_readdata = _q_readdata;
assign out_busy = _q_busy;
assign out_done = (_q_index == 13);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_active <= 0;
_q_sio_addr <= SIO_ADDR_INIT;
_q_sio_rw <= SIO_RW_INIT;
_q_sio_data_in <= SIO_DATA_IN_INIT;
_q_sio_in_valid <= SIO_IN_VALID_INIT;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_active <= _d_active;
_q_sio_addr <= _d_sio_addr;
_q_sio_rw <= _d_sio_rw;
_q_sio_data_in <= _d_sio_data_in;
_q_sio_in_valid <= _d_sio_in_valid;
_q_readdata <= _d_readdata;
_q_busy <= _d_busy;
_q_index <= _d_index;
  end
end


M_sdramcontroller_mem_Dcachedata __mem__Dcachedata(
.clock(clock),
.in_Dcachedata_wenable(_t_Dcachedata_wenable),
.in_Dcachedata_wdata(_t_Dcachedata_wdata),
.in_Dcachedata_addr(_t_Dcachedata_addr),
.out_Dcachedata_rdata(_w_mem_Dcachedata_rdata)
);
M_sdramcontroller_mem_Dcachetag __mem__Dcachetag(
.clock(clock),
.in_Dcachetag_wenable(_t_Dcachetag_wenable),
.in_Dcachetag_wdata(_t_Dcachetag_wdata),
.in_Dcachetag_addr(_t_Dcachetag_addr),
.out_Dcachetag_rdata(_w_mem_Dcachetag_rdata)
);
M_sdramcontroller_mem_Icachedata __mem__Icachedata(
.clock(clock),
.in_Icachedata_wenable(_t_Icachedata_wenable),
.in_Icachedata_wdata(_t_Icachedata_wdata),
.in_Icachedata_addr(_t_Icachedata_addr),
.out_Icachedata_rdata(_w_mem_Icachedata_rdata)
);
M_sdramcontroller_mem_Icachetag __mem__Icachetag(
.clock(clock),
.in_Icachetag_wenable(_t_Icachetag_wenable),
.in_Icachetag_wdata(_t_Icachetag_wdata),
.in_Icachetag_addr(_t_Icachetag_addr),
.out_Icachetag_rdata(_w_mem_Icachetag_rdata)
);

assign _w_Dcachetagmatch = (_w_mem_Dcachetag_rdata=={1'b1,in_address[12+:14]});
assign _w_Icachetagmatch = (_w_mem_Icachetag_rdata=={1'b1,in_address[12+:14]});

always @* begin
_d_active = _q_active;
_d_sio_addr = _q_sio_addr;
_d_sio_rw = _q_sio_rw;
_d_sio_data_in = _q_sio_data_in;
_d_sio_in_valid = _q_sio_in_valid;
_d_readdata = _q_readdata;
_d_busy = _q_busy;
_d_index = _q_index;
_t_Dcachedata_wenable = 0;
_t_Dcachedata_wdata = 0;
_t_Dcachedata_addr = 0;
_t_Dcachetag_wenable = 0;
_t_Dcachetag_wdata = 0;
_t_Dcachetag_addr = 0;
_t_Icachedata_wenable = 0;
_t_Icachedata_wdata = 0;
_t_Icachedata_addr = 0;
_t_Icachetag_wenable = 0;
_t_Icachetag_wdata = 0;
_t_Icachetag_addr = 0;
// _always_pre
_d_busy = (in_readflag||in_writeflag)?1:_q_active;
_d_sio_addr = {in_address[1+:25],1'b0};
_d_sio_in_valid = 0;
_t_Dcachedata_wenable = 0;
_t_Dcachedata_addr = in_address[1+:11];
_t_Dcachetag_wenable = 0;
_t_Dcachetag_addr = in_address[1+:11];
_t_Dcachetag_wdata = {1'b1,in_address[12+:14]};
_t_Icachedata_wenable = 0;
_t_Icachedata_addr = in_address[1+:11];
_t_Icachetag_wenable = 0;
_t_Icachetag_addr = in_address[1+:11];
_t_Icachetag_wdata = {1'b1,in_address[12+:14]};
_d_readdata = (in_Icache&&_w_Icachetagmatch)?_w_mem_Icachedata_rdata:((~in_Icache&&_w_Dcachetagmatch)?_w_mem_Dcachedata_rdata:in_sio_data_out);
_d_index = 13;
(* full_case *)
case (_q_index)
0: begin
// _top
// var inits
_t_Dcachedata_wenable = 0;
_t_Dcachedata_wdata = 0;
_t_Dcachedata_addr = 0;
_t_Dcachetag_wenable = 0;
_t_Dcachetag_wdata = 0;
_t_Dcachetag_addr = 0;
_t_Icachedata_wenable = 0;
_t_Icachedata_wdata = 0;
_t_Icachedata_addr = 0;
_t_Icachetag_wenable = 0;
_t_Icachetag_wdata = 0;
_t_Icachetag_addr = 0;
_d_active = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (in_readflag) begin
// __block_5
// __block_7
_d_active = 1;
_d_index = 4;
end else begin
// __block_6
_d_index = 3;
end
end else begin
_d_index = 2;
end
end
4: begin
// __block_8
if ((in_Icache&&_w_Icachetagmatch)||(~in_Icache&&_w_Dcachetagmatch)) begin
// __block_9
// __block_11
// __block_12
_d_index = 5;
end else begin
// __block_10
// __block_13
_d_sio_rw = 0;
_d_sio_in_valid = 1;
_d_index = 8;
end
end
3: begin
// __block_22
if (in_writeflag) begin
// __block_23
// __block_25
_d_active = 1;
if ((in_function3&3)==0) begin
// __block_26
// __block_28
_d_index = 9;
end else begin
// __block_27
_d_index = 6;
end
end else begin
// __block_24
_d_index = 1;
end
end
2: begin
// __block_3
_d_index = 13;
end
5: begin
// __block_20
_d_active = 0;
// __block_21
_d_index = 3;
end
8: begin
// __while__block_14
if (!in_sio_done) begin
// __block_15
// __block_17
// __block_18
_d_index = 8;
end else begin
_d_index = 11;
end
end
9: begin
// __block_29
if (~_w_Dcachetagmatch) begin
// __block_30
// __block_32
_d_sio_rw = 0;
_d_sio_in_valid = 1;
_d_index = 12;
end else begin
// __block_31
_d_index = 6;
end
end
6: begin
// __block_41
_t_Dcachedata_wdata = ((in_function3&3)==0)?(in_address[0+:1]?{in_writedata[0+:8],_w_Dcachetagmatch?_w_mem_Dcachedata_rdata[0+:8]:in_sio_data_out[0+:8]}:{_w_Dcachetagmatch?_w_mem_Dcachedata_rdata[8+:8]:in_sio_data_out[8+:8],in_writedata[0+:8]}):in_writedata;
_t_Icachedata_wdata = ((in_function3&3)==0)?(in_address[0+:1]?{in_writedata[0+:8],_w_Dcachetagmatch?_w_mem_Dcachedata_rdata[0+:8]:in_sio_data_out[0+:8]}:{_w_Dcachetagmatch?_w_mem_Dcachedata_rdata[8+:8]:in_sio_data_out[8+:8],in_writedata[0+:8]}):in_writedata;
_d_sio_data_in = ((in_function3&3)==0)?(in_address[0+:1]?{in_writedata[0+:8],_w_Dcachetagmatch?_w_mem_Dcachedata_rdata[0+:8]:in_sio_data_out[0+:8]}:{_w_Dcachetagmatch?_w_mem_Dcachedata_rdata[8+:8]:in_sio_data_out[8+:8],in_writedata[0+:8]}):in_writedata;
_t_Dcachedata_wenable = 1;
_t_Dcachetag_wenable = 1;
_t_Icachedata_wenable = _w_Icachetagmatch;
_d_sio_rw = 1;
_d_sio_in_valid = 1;
_d_index = 7;
end
11: begin
// __block_16
_t_Dcachedata_wdata = in_sio_data_out;
_t_Dcachedata_wenable = ~in_Icache;
_t_Dcachetag_wenable = ~in_Icache;
_t_Icachedata_wdata = in_sio_data_out;
_t_Icachedata_wenable = in_Icache;
_t_Icachetag_wenable = in_Icache;
// __block_19
_d_index = 5;
end
12: begin
// __while__block_33
if (!in_sio_done) begin
// __block_34
// __block_36
// __block_37
_d_index = 12;
end else begin
_d_index = 6;
end
end
7: begin
// __while__block_42
if (!in_sio_done) begin
// __block_43
// __block_45
// __block_46
_d_index = 7;
end else begin
_d_index = 10;
end
end
10: begin
// __block_44
_d_active = 0;
// __block_47
_d_index = 1;
end
13: begin // end of sdramcontroller
end
default: begin 
_d_index = 13;
 end
endcase
end
endmodule

