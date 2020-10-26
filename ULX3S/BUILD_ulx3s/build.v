`define HDMI 1
`define UART 1
`define GPIO 1
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
  output [27:0] gn,
`endif  
`ifdef VGA
  // vga
  output [27:0] gp,
  output [27:0] gn,
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

  output [3:0] audio_l,
  output [3:0] audio_r,

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
  
`ifdef GPIO
wire [2:0]  __main_out_gp;
wire [2:0]  __main_out_gn;
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
  .out_gp       (__main_out_gp),
  .out_gn       (__main_out_gn),
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

`ifdef GPIO
assign gp[0+:3]      = __main_out_gp;
assign gn[0+:3]      = __main_out_gn;
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


// diamond 3.7 accepts this PLL
// diamond 3.8-3.9 is untested
// diamond 3.10 or higher is likely to abort with error about unable to use feedback signal
// cause of this could be from wrong CPHASE/FPHASE parameters
module ulx3s_clk_50_25
(
    input clkin, // 25 MHz, 0 deg
    output clkout0, // 50 MHz, 0 deg
    output clkout1, // 25 MHz, 0 deg
    output locked
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
        .FEEDBK_PATH("CLKOP"),
        .CLKFB_DIV(2)
    ) pll_i (
        .RST(1'b0),
        .STDBY(1'b0),
        .CLKI(clkin),
        .CLKOP(clkout0),
        .CLKOS(clkout1),
        .CLKFB(clkout0),
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


module reset_conditioner (
    input rcclk,
    input in,
    output reg out
  );  
  reg [7:0] counter_d,counter_q;
  always @* begin
    counter_d = counter_q;
    if (counter_q == 0) begin
      out = 0;
    end else begin
      out = 1;
      counter_d = counter_q + 1;
    end
  end  
  always @(posedge rcclk) begin
    if (in == 1'b1) begin
      counter_q <= 1;
    end else begin
      counter_q <= counter_d;
    end
  end 
endmodule


// PS/2 Keyboard from https://github.com/emard/ulx3s-misc/blob/master/examples/ps2/kbd/hdl/ps2kbd.v
// AUTHOR=Paul Ruiz
// LICENSE=BSD
// PS/2 KBD interface (input only)
// Algorithm based on a VHDL routine by Grant Searle
//
module ps2kbd(
  input clk,
  
  input ps2_clk,
  input ps2_data,
  
  output [7:0] ps2_code,
  output strobe,
  output err
);

  // sync ps2_data
  //
  reg serin;
  always @(posedge clk) serin <= ps2_data;
  
  // sync & 'debounce' ps2_clock
  //
  parameter LEN = 8;
  reg bitclk = 0;
  reg [LEN:0] stable = 0;

  always @(posedge clk)
  begin
    stable = { stable[LEN-1:0], ps2_clk };
    if ( &stable) bitclk <= 1;
    if (~|stable) bitclk <= 0;
  end
  
  wire bitedge = bitclk && (~|stable[LEN-1:0]);
  
  // clock in KBD bits (start - 8 data - odd parity - stop)
  //
  reg [8:0] shift = 0;
  reg [3:0] bitcnt = 0;
  reg parity = 0;

  always @(posedge clk)
  begin
    strobe <= 0; err <= 0;
    if (bitedge) begin
      // wait for start bit
      if (bitcnt==0) begin
        parity <= 0;
        if (!serin) bitcnt <= bitcnt + 1;
        end
      // shift in 9 bits (8 data + parity)
      else if (bitcnt<10) begin
        shift  <= { serin, shift[8:1] };
        parity <= parity ^ serin;
        bitcnt <= bitcnt + 1;
        end
      // check stop bit, parity
      else begin
        bitcnt <= 0;
        if (parity && serin) begin
          ps2_code <= shift[7:0];
          strobe <= 1;
          end
        else
          err <= 1;
      end
    end
  end

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
out_outbits,
reset,
out_clock,
clock
);
input  [9:0] in_data_r;
input  [9:0] in_data_g;
input  [9:0] in_data_b;
output  [7:0] out_outbits;
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
reg  [7:0] _d_outbits,_q_outbits;
assign out_outbits = _q_outbits;

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
_q_outbits <= _d_outbits;
  end
end




always @* begin
_d_mod5 = _q_mod5;
_d_shift_r = _q_shift_r;
_d_shift_g = _q_shift_g;
_d_shift_b = _q_shift_b;
_d_outbits = _q_outbits;
_t_clkbits = 0;
// _always_pre
_d_shift_r = (_q_mod5==0)?in_data_r:_q_shift_r[2+:8];
_d_shift_g = (_q_mod5==0)?in_data_g:_q_shift_g[2+:8];
_d_shift_b = (_q_mod5==0)?in_data_b:_q_shift_b[2+:8];
_t_clkbits = (_q_mod5[0+:2]<2)?2'b11:((_q_mod5>2)?2'b00:2'b01);
_d_outbits = {_t_clkbits,_d_shift_b[0+:2],_d_shift_g[0+:2],_d_shift_r[0+:2]};
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
wire  [7:0] _w_shift_outbits;
wire  [1:0] _c_null_ctrl;
assign _c_null_ctrl = 0;
reg  [0:0] _t_hsync;
reg  [0:0] _t_vsync;
wire  [7:0] _w_crgb_neg;

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
.pos(_w_shift_outbits),
.neg(_w_crgb_neg),
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
.out_outbits(_w_shift_outbits),
.reset(reset),
.clock(_w_pll_half_hdmi_clk)
);


assign _w_crgb_neg = ~_w_shift_outbits;

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
_d_x = _q_cntx;
_d_y = _q_cnty;
_d_cnty = (_q_cntx==799)?(_q_cnty==524?0:(_q_cnty+1)):_q_cnty;
_d_cntx = (_q_cntx==799)?0:(_q_cntx+1);
_d_latch_red = in_red;
_d_latch_green = in_green;
_d_latch_blue = in_blue;
end
endmodule


module M_terminal_mem_terminal(
input      [0:0]             in_terminal_wenable0,
input       [7:0]     in_terminal_wdata0,
input      [9:0]                in_terminal_addr0,
input      [0:0]             in_terminal_wenable1,
input      [7:0]                 in_terminal_wdata1,
input      [9:0]                in_terminal_addr1,
output reg  [7:0]     out_terminal_rdata0,
output reg  [7:0]     out_terminal_rdata1,
input      clock0,
input      clock1
);
reg  [7:0] buffer[639:0];
always @(posedge clock0) begin
  if (in_terminal_wenable0) begin
    buffer[in_terminal_addr0] <= in_terminal_wdata0;
  end else begin
    out_terminal_rdata0 <= buffer[in_terminal_addr0];
  end
end
always @(posedge clock1) begin
  if (in_terminal_wenable1) begin
    buffer[in_terminal_addr1] <= in_terminal_wdata1;
  end else begin
    out_terminal_rdata1 <= buffer[in_terminal_addr1];
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
output  [5:0] out_pix_red;
output  [5:0] out_pix_green;
output  [5:0] out_pix_blue;
output  [0:0] out_terminal_display;
output  [2:0] out_terminal_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [7:0] _w_mem_terminal_rdata0;
wire  [7:0] _w_mem_terminal_rdata1;
wire  [7:0] _c_characterGenerator8x8[2047:0];
assign _c_characterGenerator8x8[0] = 8'h00;
assign _c_characterGenerator8x8[1] = 8'h00;
assign _c_characterGenerator8x8[2] = 8'h00;
assign _c_characterGenerator8x8[3] = 8'h00;
assign _c_characterGenerator8x8[4] = 8'h00;
assign _c_characterGenerator8x8[5] = 8'h00;
assign _c_characterGenerator8x8[6] = 8'h00;
assign _c_characterGenerator8x8[7] = 8'h00;
assign _c_characterGenerator8x8[8] = 8'h7e;
assign _c_characterGenerator8x8[9] = 8'h81;
assign _c_characterGenerator8x8[10] = 8'ha5;
assign _c_characterGenerator8x8[11] = 8'h81;
assign _c_characterGenerator8x8[12] = 8'hbd;
assign _c_characterGenerator8x8[13] = 8'h99;
assign _c_characterGenerator8x8[14] = 8'h81;
assign _c_characterGenerator8x8[15] = 8'h7e;
assign _c_characterGenerator8x8[16] = 8'h7e;
assign _c_characterGenerator8x8[17] = 8'hff;
assign _c_characterGenerator8x8[18] = 8'hdb;
assign _c_characterGenerator8x8[19] = 8'hff;
assign _c_characterGenerator8x8[20] = 8'hc3;
assign _c_characterGenerator8x8[21] = 8'he7;
assign _c_characterGenerator8x8[22] = 8'hff;
assign _c_characterGenerator8x8[23] = 8'h7e;
assign _c_characterGenerator8x8[24] = 8'h6c;
assign _c_characterGenerator8x8[25] = 8'hfe;
assign _c_characterGenerator8x8[26] = 8'hfe;
assign _c_characterGenerator8x8[27] = 8'hfe;
assign _c_characterGenerator8x8[28] = 8'h7c;
assign _c_characterGenerator8x8[29] = 8'h38;
assign _c_characterGenerator8x8[30] = 8'h10;
assign _c_characterGenerator8x8[31] = 8'h00;
assign _c_characterGenerator8x8[32] = 8'h10;
assign _c_characterGenerator8x8[33] = 8'h38;
assign _c_characterGenerator8x8[34] = 8'h7c;
assign _c_characterGenerator8x8[35] = 8'hfe;
assign _c_characterGenerator8x8[36] = 8'h7c;
assign _c_characterGenerator8x8[37] = 8'h38;
assign _c_characterGenerator8x8[38] = 8'h10;
assign _c_characterGenerator8x8[39] = 8'h00;
assign _c_characterGenerator8x8[40] = 8'h38;
assign _c_characterGenerator8x8[41] = 8'h7c;
assign _c_characterGenerator8x8[42] = 8'h38;
assign _c_characterGenerator8x8[43] = 8'hfe;
assign _c_characterGenerator8x8[44] = 8'hfe;
assign _c_characterGenerator8x8[45] = 8'h7c;
assign _c_characterGenerator8x8[46] = 8'h38;
assign _c_characterGenerator8x8[47] = 8'h7c;
assign _c_characterGenerator8x8[48] = 8'h10;
assign _c_characterGenerator8x8[49] = 8'h10;
assign _c_characterGenerator8x8[50] = 8'h38;
assign _c_characterGenerator8x8[51] = 8'h7c;
assign _c_characterGenerator8x8[52] = 8'hfe;
assign _c_characterGenerator8x8[53] = 8'h7c;
assign _c_characterGenerator8x8[54] = 8'h38;
assign _c_characterGenerator8x8[55] = 8'h7c;
assign _c_characterGenerator8x8[56] = 8'h00;
assign _c_characterGenerator8x8[57] = 8'h00;
assign _c_characterGenerator8x8[58] = 8'h18;
assign _c_characterGenerator8x8[59] = 8'h3c;
assign _c_characterGenerator8x8[60] = 8'h3c;
assign _c_characterGenerator8x8[61] = 8'h18;
assign _c_characterGenerator8x8[62] = 8'h00;
assign _c_characterGenerator8x8[63] = 8'h00;
assign _c_characterGenerator8x8[64] = 8'hff;
assign _c_characterGenerator8x8[65] = 8'hff;
assign _c_characterGenerator8x8[66] = 8'he7;
assign _c_characterGenerator8x8[67] = 8'hc3;
assign _c_characterGenerator8x8[68] = 8'hc3;
assign _c_characterGenerator8x8[69] = 8'he7;
assign _c_characterGenerator8x8[70] = 8'hff;
assign _c_characterGenerator8x8[71] = 8'hff;
assign _c_characterGenerator8x8[72] = 8'h00;
assign _c_characterGenerator8x8[73] = 8'h3c;
assign _c_characterGenerator8x8[74] = 8'h66;
assign _c_characterGenerator8x8[75] = 8'h42;
assign _c_characterGenerator8x8[76] = 8'h42;
assign _c_characterGenerator8x8[77] = 8'h66;
assign _c_characterGenerator8x8[78] = 8'h3c;
assign _c_characterGenerator8x8[79] = 8'h00;
assign _c_characterGenerator8x8[80] = 8'hff;
assign _c_characterGenerator8x8[81] = 8'hc3;
assign _c_characterGenerator8x8[82] = 8'h99;
assign _c_characterGenerator8x8[83] = 8'hbd;
assign _c_characterGenerator8x8[84] = 8'hbd;
assign _c_characterGenerator8x8[85] = 8'h99;
assign _c_characterGenerator8x8[86] = 8'hc3;
assign _c_characterGenerator8x8[87] = 8'hff;
assign _c_characterGenerator8x8[88] = 8'h0f;
assign _c_characterGenerator8x8[89] = 8'h07;
assign _c_characterGenerator8x8[90] = 8'h0f;
assign _c_characterGenerator8x8[91] = 8'h7d;
assign _c_characterGenerator8x8[92] = 8'hcc;
assign _c_characterGenerator8x8[93] = 8'hcc;
assign _c_characterGenerator8x8[94] = 8'hcc;
assign _c_characterGenerator8x8[95] = 8'h78;
assign _c_characterGenerator8x8[96] = 8'h3c;
assign _c_characterGenerator8x8[97] = 8'h66;
assign _c_characterGenerator8x8[98] = 8'h66;
assign _c_characterGenerator8x8[99] = 8'h66;
assign _c_characterGenerator8x8[100] = 8'h3c;
assign _c_characterGenerator8x8[101] = 8'h18;
assign _c_characterGenerator8x8[102] = 8'h7e;
assign _c_characterGenerator8x8[103] = 8'h18;
assign _c_characterGenerator8x8[104] = 8'h3f;
assign _c_characterGenerator8x8[105] = 8'h33;
assign _c_characterGenerator8x8[106] = 8'h3f;
assign _c_characterGenerator8x8[107] = 8'h30;
assign _c_characterGenerator8x8[108] = 8'h30;
assign _c_characterGenerator8x8[109] = 8'h70;
assign _c_characterGenerator8x8[110] = 8'hf0;
assign _c_characterGenerator8x8[111] = 8'he0;
assign _c_characterGenerator8x8[112] = 8'h7f;
assign _c_characterGenerator8x8[113] = 8'h63;
assign _c_characterGenerator8x8[114] = 8'h7f;
assign _c_characterGenerator8x8[115] = 8'h63;
assign _c_characterGenerator8x8[116] = 8'h63;
assign _c_characterGenerator8x8[117] = 8'h67;
assign _c_characterGenerator8x8[118] = 8'he6;
assign _c_characterGenerator8x8[119] = 8'hc0;
assign _c_characterGenerator8x8[120] = 8'h99;
assign _c_characterGenerator8x8[121] = 8'h5a;
assign _c_characterGenerator8x8[122] = 8'h3c;
assign _c_characterGenerator8x8[123] = 8'he7;
assign _c_characterGenerator8x8[124] = 8'he7;
assign _c_characterGenerator8x8[125] = 8'h3c;
assign _c_characterGenerator8x8[126] = 8'h5a;
assign _c_characterGenerator8x8[127] = 8'h99;
assign _c_characterGenerator8x8[128] = 8'h80;
assign _c_characterGenerator8x8[129] = 8'he0;
assign _c_characterGenerator8x8[130] = 8'hf8;
assign _c_characterGenerator8x8[131] = 8'hfe;
assign _c_characterGenerator8x8[132] = 8'hf8;
assign _c_characterGenerator8x8[133] = 8'he0;
assign _c_characterGenerator8x8[134] = 8'h80;
assign _c_characterGenerator8x8[135] = 8'h00;
assign _c_characterGenerator8x8[136] = 8'h02;
assign _c_characterGenerator8x8[137] = 8'h0e;
assign _c_characterGenerator8x8[138] = 8'h3e;
assign _c_characterGenerator8x8[139] = 8'hfe;
assign _c_characterGenerator8x8[140] = 8'h3e;
assign _c_characterGenerator8x8[141] = 8'h0e;
assign _c_characterGenerator8x8[142] = 8'h02;
assign _c_characterGenerator8x8[143] = 8'h00;
assign _c_characterGenerator8x8[144] = 8'h18;
assign _c_characterGenerator8x8[145] = 8'h3c;
assign _c_characterGenerator8x8[146] = 8'h7e;
assign _c_characterGenerator8x8[147] = 8'h18;
assign _c_characterGenerator8x8[148] = 8'h18;
assign _c_characterGenerator8x8[149] = 8'h7e;
assign _c_characterGenerator8x8[150] = 8'h3c;
assign _c_characterGenerator8x8[151] = 8'h18;
assign _c_characterGenerator8x8[152] = 8'h66;
assign _c_characterGenerator8x8[153] = 8'h66;
assign _c_characterGenerator8x8[154] = 8'h66;
assign _c_characterGenerator8x8[155] = 8'h66;
assign _c_characterGenerator8x8[156] = 8'h66;
assign _c_characterGenerator8x8[157] = 8'h00;
assign _c_characterGenerator8x8[158] = 8'h66;
assign _c_characterGenerator8x8[159] = 8'h00;
assign _c_characterGenerator8x8[160] = 8'h7f;
assign _c_characterGenerator8x8[161] = 8'hdb;
assign _c_characterGenerator8x8[162] = 8'hdb;
assign _c_characterGenerator8x8[163] = 8'h7b;
assign _c_characterGenerator8x8[164] = 8'h1b;
assign _c_characterGenerator8x8[165] = 8'h1b;
assign _c_characterGenerator8x8[166] = 8'h1b;
assign _c_characterGenerator8x8[167] = 8'h00;
assign _c_characterGenerator8x8[168] = 8'h3e;
assign _c_characterGenerator8x8[169] = 8'h63;
assign _c_characterGenerator8x8[170] = 8'h38;
assign _c_characterGenerator8x8[171] = 8'h6c;
assign _c_characterGenerator8x8[172] = 8'h6c;
assign _c_characterGenerator8x8[173] = 8'h38;
assign _c_characterGenerator8x8[174] = 8'hcc;
assign _c_characterGenerator8x8[175] = 8'h78;
assign _c_characterGenerator8x8[176] = 8'h00;
assign _c_characterGenerator8x8[177] = 8'h00;
assign _c_characterGenerator8x8[178] = 8'h00;
assign _c_characterGenerator8x8[179] = 8'h00;
assign _c_characterGenerator8x8[180] = 8'h7e;
assign _c_characterGenerator8x8[181] = 8'h7e;
assign _c_characterGenerator8x8[182] = 8'h7e;
assign _c_characterGenerator8x8[183] = 8'h00;
assign _c_characterGenerator8x8[184] = 8'h18;
assign _c_characterGenerator8x8[185] = 8'h3c;
assign _c_characterGenerator8x8[186] = 8'h7e;
assign _c_characterGenerator8x8[187] = 8'h18;
assign _c_characterGenerator8x8[188] = 8'h7e;
assign _c_characterGenerator8x8[189] = 8'h3c;
assign _c_characterGenerator8x8[190] = 8'h18;
assign _c_characterGenerator8x8[191] = 8'hff;
assign _c_characterGenerator8x8[192] = 8'h18;
assign _c_characterGenerator8x8[193] = 8'h3c;
assign _c_characterGenerator8x8[194] = 8'h7e;
assign _c_characterGenerator8x8[195] = 8'h18;
assign _c_characterGenerator8x8[196] = 8'h18;
assign _c_characterGenerator8x8[197] = 8'h18;
assign _c_characterGenerator8x8[198] = 8'h18;
assign _c_characterGenerator8x8[199] = 8'h00;
assign _c_characterGenerator8x8[200] = 8'h18;
assign _c_characterGenerator8x8[201] = 8'h18;
assign _c_characterGenerator8x8[202] = 8'h18;
assign _c_characterGenerator8x8[203] = 8'h18;
assign _c_characterGenerator8x8[204] = 8'h7e;
assign _c_characterGenerator8x8[205] = 8'h3c;
assign _c_characterGenerator8x8[206] = 8'h18;
assign _c_characterGenerator8x8[207] = 8'h00;
assign _c_characterGenerator8x8[208] = 8'h00;
assign _c_characterGenerator8x8[209] = 8'h18;
assign _c_characterGenerator8x8[210] = 8'h0c;
assign _c_characterGenerator8x8[211] = 8'hfe;
assign _c_characterGenerator8x8[212] = 8'h0c;
assign _c_characterGenerator8x8[213] = 8'h18;
assign _c_characterGenerator8x8[214] = 8'h00;
assign _c_characterGenerator8x8[215] = 8'h00;
assign _c_characterGenerator8x8[216] = 8'h00;
assign _c_characterGenerator8x8[217] = 8'h30;
assign _c_characterGenerator8x8[218] = 8'h60;
assign _c_characterGenerator8x8[219] = 8'hfe;
assign _c_characterGenerator8x8[220] = 8'h60;
assign _c_characterGenerator8x8[221] = 8'h30;
assign _c_characterGenerator8x8[222] = 8'h00;
assign _c_characterGenerator8x8[223] = 8'h00;
assign _c_characterGenerator8x8[224] = 8'h00;
assign _c_characterGenerator8x8[225] = 8'h00;
assign _c_characterGenerator8x8[226] = 8'hc0;
assign _c_characterGenerator8x8[227] = 8'hc0;
assign _c_characterGenerator8x8[228] = 8'hc0;
assign _c_characterGenerator8x8[229] = 8'hfe;
assign _c_characterGenerator8x8[230] = 8'h00;
assign _c_characterGenerator8x8[231] = 8'h00;
assign _c_characterGenerator8x8[232] = 8'h00;
assign _c_characterGenerator8x8[233] = 8'h24;
assign _c_characterGenerator8x8[234] = 8'h66;
assign _c_characterGenerator8x8[235] = 8'hff;
assign _c_characterGenerator8x8[236] = 8'h66;
assign _c_characterGenerator8x8[237] = 8'h24;
assign _c_characterGenerator8x8[238] = 8'h00;
assign _c_characterGenerator8x8[239] = 8'h00;
assign _c_characterGenerator8x8[240] = 8'h00;
assign _c_characterGenerator8x8[241] = 8'h18;
assign _c_characterGenerator8x8[242] = 8'h3c;
assign _c_characterGenerator8x8[243] = 8'h7e;
assign _c_characterGenerator8x8[244] = 8'hff;
assign _c_characterGenerator8x8[245] = 8'hff;
assign _c_characterGenerator8x8[246] = 8'h00;
assign _c_characterGenerator8x8[247] = 8'h00;
assign _c_characterGenerator8x8[248] = 8'h00;
assign _c_characterGenerator8x8[249] = 8'hff;
assign _c_characterGenerator8x8[250] = 8'hff;
assign _c_characterGenerator8x8[251] = 8'h7e;
assign _c_characterGenerator8x8[252] = 8'h3c;
assign _c_characterGenerator8x8[253] = 8'h18;
assign _c_characterGenerator8x8[254] = 8'h00;
assign _c_characterGenerator8x8[255] = 8'h00;
assign _c_characterGenerator8x8[256] = 8'h00;
assign _c_characterGenerator8x8[257] = 8'h00;
assign _c_characterGenerator8x8[258] = 8'h00;
assign _c_characterGenerator8x8[259] = 8'h00;
assign _c_characterGenerator8x8[260] = 8'h00;
assign _c_characterGenerator8x8[261] = 8'h00;
assign _c_characterGenerator8x8[262] = 8'h00;
assign _c_characterGenerator8x8[263] = 8'h00;
assign _c_characterGenerator8x8[264] = 8'h30;
assign _c_characterGenerator8x8[265] = 8'h78;
assign _c_characterGenerator8x8[266] = 8'h78;
assign _c_characterGenerator8x8[267] = 8'h30;
assign _c_characterGenerator8x8[268] = 8'h30;
assign _c_characterGenerator8x8[269] = 8'h00;
assign _c_characterGenerator8x8[270] = 8'h30;
assign _c_characterGenerator8x8[271] = 8'h00;
assign _c_characterGenerator8x8[272] = 8'h6c;
assign _c_characterGenerator8x8[273] = 8'h6c;
assign _c_characterGenerator8x8[274] = 8'h6c;
assign _c_characterGenerator8x8[275] = 8'h00;
assign _c_characterGenerator8x8[276] = 8'h00;
assign _c_characterGenerator8x8[277] = 8'h00;
assign _c_characterGenerator8x8[278] = 8'h00;
assign _c_characterGenerator8x8[279] = 8'h00;
assign _c_characterGenerator8x8[280] = 8'h6c;
assign _c_characterGenerator8x8[281] = 8'h6c;
assign _c_characterGenerator8x8[282] = 8'hfe;
assign _c_characterGenerator8x8[283] = 8'h6c;
assign _c_characterGenerator8x8[284] = 8'hfe;
assign _c_characterGenerator8x8[285] = 8'h6c;
assign _c_characterGenerator8x8[286] = 8'h6c;
assign _c_characterGenerator8x8[287] = 8'h00;
assign _c_characterGenerator8x8[288] = 8'h30;
assign _c_characterGenerator8x8[289] = 8'h7c;
assign _c_characterGenerator8x8[290] = 8'hc0;
assign _c_characterGenerator8x8[291] = 8'h78;
assign _c_characterGenerator8x8[292] = 8'h0c;
assign _c_characterGenerator8x8[293] = 8'hf8;
assign _c_characterGenerator8x8[294] = 8'h30;
assign _c_characterGenerator8x8[295] = 8'h00;
assign _c_characterGenerator8x8[296] = 8'h00;
assign _c_characterGenerator8x8[297] = 8'hc6;
assign _c_characterGenerator8x8[298] = 8'hcc;
assign _c_characterGenerator8x8[299] = 8'h18;
assign _c_characterGenerator8x8[300] = 8'h30;
assign _c_characterGenerator8x8[301] = 8'h66;
assign _c_characterGenerator8x8[302] = 8'hc6;
assign _c_characterGenerator8x8[303] = 8'h00;
assign _c_characterGenerator8x8[304] = 8'h38;
assign _c_characterGenerator8x8[305] = 8'h6c;
assign _c_characterGenerator8x8[306] = 8'h38;
assign _c_characterGenerator8x8[307] = 8'h76;
assign _c_characterGenerator8x8[308] = 8'hdc;
assign _c_characterGenerator8x8[309] = 8'hcc;
assign _c_characterGenerator8x8[310] = 8'h76;
assign _c_characterGenerator8x8[311] = 8'h00;
assign _c_characterGenerator8x8[312] = 8'h60;
assign _c_characterGenerator8x8[313] = 8'h60;
assign _c_characterGenerator8x8[314] = 8'hc0;
assign _c_characterGenerator8x8[315] = 8'h00;
assign _c_characterGenerator8x8[316] = 8'h00;
assign _c_characterGenerator8x8[317] = 8'h00;
assign _c_characterGenerator8x8[318] = 8'h00;
assign _c_characterGenerator8x8[319] = 8'h00;
assign _c_characterGenerator8x8[320] = 8'h18;
assign _c_characterGenerator8x8[321] = 8'h30;
assign _c_characterGenerator8x8[322] = 8'h60;
assign _c_characterGenerator8x8[323] = 8'h60;
assign _c_characterGenerator8x8[324] = 8'h60;
assign _c_characterGenerator8x8[325] = 8'h30;
assign _c_characterGenerator8x8[326] = 8'h18;
assign _c_characterGenerator8x8[327] = 8'h00;
assign _c_characterGenerator8x8[328] = 8'h60;
assign _c_characterGenerator8x8[329] = 8'h30;
assign _c_characterGenerator8x8[330] = 8'h18;
assign _c_characterGenerator8x8[331] = 8'h18;
assign _c_characterGenerator8x8[332] = 8'h18;
assign _c_characterGenerator8x8[333] = 8'h30;
assign _c_characterGenerator8x8[334] = 8'h60;
assign _c_characterGenerator8x8[335] = 8'h00;
assign _c_characterGenerator8x8[336] = 8'h00;
assign _c_characterGenerator8x8[337] = 8'h66;
assign _c_characterGenerator8x8[338] = 8'h3c;
assign _c_characterGenerator8x8[339] = 8'hff;
assign _c_characterGenerator8x8[340] = 8'h3c;
assign _c_characterGenerator8x8[341] = 8'h66;
assign _c_characterGenerator8x8[342] = 8'h00;
assign _c_characterGenerator8x8[343] = 8'h00;
assign _c_characterGenerator8x8[344] = 8'h00;
assign _c_characterGenerator8x8[345] = 8'h30;
assign _c_characterGenerator8x8[346] = 8'h30;
assign _c_characterGenerator8x8[347] = 8'hfc;
assign _c_characterGenerator8x8[348] = 8'h30;
assign _c_characterGenerator8x8[349] = 8'h30;
assign _c_characterGenerator8x8[350] = 8'h00;
assign _c_characterGenerator8x8[351] = 8'h00;
assign _c_characterGenerator8x8[352] = 8'h00;
assign _c_characterGenerator8x8[353] = 8'h00;
assign _c_characterGenerator8x8[354] = 8'h00;
assign _c_characterGenerator8x8[355] = 8'h00;
assign _c_characterGenerator8x8[356] = 8'h00;
assign _c_characterGenerator8x8[357] = 8'h30;
assign _c_characterGenerator8x8[358] = 8'h30;
assign _c_characterGenerator8x8[359] = 8'h60;
assign _c_characterGenerator8x8[360] = 8'h00;
assign _c_characterGenerator8x8[361] = 8'h00;
assign _c_characterGenerator8x8[362] = 8'h00;
assign _c_characterGenerator8x8[363] = 8'hfc;
assign _c_characterGenerator8x8[364] = 8'h00;
assign _c_characterGenerator8x8[365] = 8'h00;
assign _c_characterGenerator8x8[366] = 8'h00;
assign _c_characterGenerator8x8[367] = 8'h00;
assign _c_characterGenerator8x8[368] = 8'h00;
assign _c_characterGenerator8x8[369] = 8'h00;
assign _c_characterGenerator8x8[370] = 8'h00;
assign _c_characterGenerator8x8[371] = 8'h00;
assign _c_characterGenerator8x8[372] = 8'h00;
assign _c_characterGenerator8x8[373] = 8'h30;
assign _c_characterGenerator8x8[374] = 8'h30;
assign _c_characterGenerator8x8[375] = 8'h00;
assign _c_characterGenerator8x8[376] = 8'h06;
assign _c_characterGenerator8x8[377] = 8'h0c;
assign _c_characterGenerator8x8[378] = 8'h18;
assign _c_characterGenerator8x8[379] = 8'h30;
assign _c_characterGenerator8x8[380] = 8'h60;
assign _c_characterGenerator8x8[381] = 8'hc0;
assign _c_characterGenerator8x8[382] = 8'h80;
assign _c_characterGenerator8x8[383] = 8'h00;
assign _c_characterGenerator8x8[384] = 8'h7c;
assign _c_characterGenerator8x8[385] = 8'hc6;
assign _c_characterGenerator8x8[386] = 8'hce;
assign _c_characterGenerator8x8[387] = 8'hde;
assign _c_characterGenerator8x8[388] = 8'hf6;
assign _c_characterGenerator8x8[389] = 8'he6;
assign _c_characterGenerator8x8[390] = 8'h7c;
assign _c_characterGenerator8x8[391] = 8'h00;
assign _c_characterGenerator8x8[392] = 8'h30;
assign _c_characterGenerator8x8[393] = 8'h70;
assign _c_characterGenerator8x8[394] = 8'h30;
assign _c_characterGenerator8x8[395] = 8'h30;
assign _c_characterGenerator8x8[396] = 8'h30;
assign _c_characterGenerator8x8[397] = 8'h30;
assign _c_characterGenerator8x8[398] = 8'hfc;
assign _c_characterGenerator8x8[399] = 8'h00;
assign _c_characterGenerator8x8[400] = 8'h78;
assign _c_characterGenerator8x8[401] = 8'hcc;
assign _c_characterGenerator8x8[402] = 8'h0c;
assign _c_characterGenerator8x8[403] = 8'h38;
assign _c_characterGenerator8x8[404] = 8'h60;
assign _c_characterGenerator8x8[405] = 8'hcc;
assign _c_characterGenerator8x8[406] = 8'hfc;
assign _c_characterGenerator8x8[407] = 8'h00;
assign _c_characterGenerator8x8[408] = 8'h78;
assign _c_characterGenerator8x8[409] = 8'hcc;
assign _c_characterGenerator8x8[410] = 8'h0c;
assign _c_characterGenerator8x8[411] = 8'h38;
assign _c_characterGenerator8x8[412] = 8'h0c;
assign _c_characterGenerator8x8[413] = 8'hcc;
assign _c_characterGenerator8x8[414] = 8'h78;
assign _c_characterGenerator8x8[415] = 8'h00;
assign _c_characterGenerator8x8[416] = 8'h1c;
assign _c_characterGenerator8x8[417] = 8'h3c;
assign _c_characterGenerator8x8[418] = 8'h6c;
assign _c_characterGenerator8x8[419] = 8'hcc;
assign _c_characterGenerator8x8[420] = 8'hfe;
assign _c_characterGenerator8x8[421] = 8'h0c;
assign _c_characterGenerator8x8[422] = 8'h1e;
assign _c_characterGenerator8x8[423] = 8'h00;
assign _c_characterGenerator8x8[424] = 8'hfc;
assign _c_characterGenerator8x8[425] = 8'hc0;
assign _c_characterGenerator8x8[426] = 8'hf8;
assign _c_characterGenerator8x8[427] = 8'h0c;
assign _c_characterGenerator8x8[428] = 8'h0c;
assign _c_characterGenerator8x8[429] = 8'hcc;
assign _c_characterGenerator8x8[430] = 8'h78;
assign _c_characterGenerator8x8[431] = 8'h00;
assign _c_characterGenerator8x8[432] = 8'h38;
assign _c_characterGenerator8x8[433] = 8'h60;
assign _c_characterGenerator8x8[434] = 8'hc0;
assign _c_characterGenerator8x8[435] = 8'hf8;
assign _c_characterGenerator8x8[436] = 8'hcc;
assign _c_characterGenerator8x8[437] = 8'hcc;
assign _c_characterGenerator8x8[438] = 8'h78;
assign _c_characterGenerator8x8[439] = 8'h00;
assign _c_characterGenerator8x8[440] = 8'hfc;
assign _c_characterGenerator8x8[441] = 8'hcc;
assign _c_characterGenerator8x8[442] = 8'h0c;
assign _c_characterGenerator8x8[443] = 8'h18;
assign _c_characterGenerator8x8[444] = 8'h30;
assign _c_characterGenerator8x8[445] = 8'h30;
assign _c_characterGenerator8x8[446] = 8'h30;
assign _c_characterGenerator8x8[447] = 8'h00;
assign _c_characterGenerator8x8[448] = 8'h78;
assign _c_characterGenerator8x8[449] = 8'hcc;
assign _c_characterGenerator8x8[450] = 8'hcc;
assign _c_characterGenerator8x8[451] = 8'h78;
assign _c_characterGenerator8x8[452] = 8'hcc;
assign _c_characterGenerator8x8[453] = 8'hcc;
assign _c_characterGenerator8x8[454] = 8'h78;
assign _c_characterGenerator8x8[455] = 8'h00;
assign _c_characterGenerator8x8[456] = 8'h78;
assign _c_characterGenerator8x8[457] = 8'hcc;
assign _c_characterGenerator8x8[458] = 8'hcc;
assign _c_characterGenerator8x8[459] = 8'h7c;
assign _c_characterGenerator8x8[460] = 8'h0c;
assign _c_characterGenerator8x8[461] = 8'h18;
assign _c_characterGenerator8x8[462] = 8'h70;
assign _c_characterGenerator8x8[463] = 8'h00;
assign _c_characterGenerator8x8[464] = 8'h00;
assign _c_characterGenerator8x8[465] = 8'h30;
assign _c_characterGenerator8x8[466] = 8'h30;
assign _c_characterGenerator8x8[467] = 8'h00;
assign _c_characterGenerator8x8[468] = 8'h00;
assign _c_characterGenerator8x8[469] = 8'h30;
assign _c_characterGenerator8x8[470] = 8'h30;
assign _c_characterGenerator8x8[471] = 8'h00;
assign _c_characterGenerator8x8[472] = 8'h00;
assign _c_characterGenerator8x8[473] = 8'h30;
assign _c_characterGenerator8x8[474] = 8'h30;
assign _c_characterGenerator8x8[475] = 8'h00;
assign _c_characterGenerator8x8[476] = 8'h00;
assign _c_characterGenerator8x8[477] = 8'h30;
assign _c_characterGenerator8x8[478] = 8'h30;
assign _c_characterGenerator8x8[479] = 8'h60;
assign _c_characterGenerator8x8[480] = 8'h18;
assign _c_characterGenerator8x8[481] = 8'h30;
assign _c_characterGenerator8x8[482] = 8'h60;
assign _c_characterGenerator8x8[483] = 8'hc0;
assign _c_characterGenerator8x8[484] = 8'h60;
assign _c_characterGenerator8x8[485] = 8'h30;
assign _c_characterGenerator8x8[486] = 8'h18;
assign _c_characterGenerator8x8[487] = 8'h00;
assign _c_characterGenerator8x8[488] = 8'h00;
assign _c_characterGenerator8x8[489] = 8'h00;
assign _c_characterGenerator8x8[490] = 8'hfc;
assign _c_characterGenerator8x8[491] = 8'h00;
assign _c_characterGenerator8x8[492] = 8'h00;
assign _c_characterGenerator8x8[493] = 8'hfc;
assign _c_characterGenerator8x8[494] = 8'h00;
assign _c_characterGenerator8x8[495] = 8'h00;
assign _c_characterGenerator8x8[496] = 8'h60;
assign _c_characterGenerator8x8[497] = 8'h30;
assign _c_characterGenerator8x8[498] = 8'h18;
assign _c_characterGenerator8x8[499] = 8'h0c;
assign _c_characterGenerator8x8[500] = 8'h18;
assign _c_characterGenerator8x8[501] = 8'h30;
assign _c_characterGenerator8x8[502] = 8'h60;
assign _c_characterGenerator8x8[503] = 8'h00;
assign _c_characterGenerator8x8[504] = 8'h78;
assign _c_characterGenerator8x8[505] = 8'hcc;
assign _c_characterGenerator8x8[506] = 8'h0c;
assign _c_characterGenerator8x8[507] = 8'h18;
assign _c_characterGenerator8x8[508] = 8'h30;
assign _c_characterGenerator8x8[509] = 8'h00;
assign _c_characterGenerator8x8[510] = 8'h30;
assign _c_characterGenerator8x8[511] = 8'h00;
assign _c_characterGenerator8x8[512] = 8'h7c;
assign _c_characterGenerator8x8[513] = 8'hc6;
assign _c_characterGenerator8x8[514] = 8'hde;
assign _c_characterGenerator8x8[515] = 8'hde;
assign _c_characterGenerator8x8[516] = 8'hde;
assign _c_characterGenerator8x8[517] = 8'hc0;
assign _c_characterGenerator8x8[518] = 8'h78;
assign _c_characterGenerator8x8[519] = 8'h00;
assign _c_characterGenerator8x8[520] = 8'h30;
assign _c_characterGenerator8x8[521] = 8'h78;
assign _c_characterGenerator8x8[522] = 8'hcc;
assign _c_characterGenerator8x8[523] = 8'hcc;
assign _c_characterGenerator8x8[524] = 8'hfc;
assign _c_characterGenerator8x8[525] = 8'hcc;
assign _c_characterGenerator8x8[526] = 8'hcc;
assign _c_characterGenerator8x8[527] = 8'h00;
assign _c_characterGenerator8x8[528] = 8'hfc;
assign _c_characterGenerator8x8[529] = 8'h66;
assign _c_characterGenerator8x8[530] = 8'h66;
assign _c_characterGenerator8x8[531] = 8'h7c;
assign _c_characterGenerator8x8[532] = 8'h66;
assign _c_characterGenerator8x8[533] = 8'h66;
assign _c_characterGenerator8x8[534] = 8'hfc;
assign _c_characterGenerator8x8[535] = 8'h00;
assign _c_characterGenerator8x8[536] = 8'h3c;
assign _c_characterGenerator8x8[537] = 8'h66;
assign _c_characterGenerator8x8[538] = 8'hc0;
assign _c_characterGenerator8x8[539] = 8'hc0;
assign _c_characterGenerator8x8[540] = 8'hc0;
assign _c_characterGenerator8x8[541] = 8'h66;
assign _c_characterGenerator8x8[542] = 8'h3c;
assign _c_characterGenerator8x8[543] = 8'h00;
assign _c_characterGenerator8x8[544] = 8'hf8;
assign _c_characterGenerator8x8[545] = 8'h6c;
assign _c_characterGenerator8x8[546] = 8'h66;
assign _c_characterGenerator8x8[547] = 8'h66;
assign _c_characterGenerator8x8[548] = 8'h66;
assign _c_characterGenerator8x8[549] = 8'h6c;
assign _c_characterGenerator8x8[550] = 8'hf8;
assign _c_characterGenerator8x8[551] = 8'h00;
assign _c_characterGenerator8x8[552] = 8'hfe;
assign _c_characterGenerator8x8[553] = 8'h62;
assign _c_characterGenerator8x8[554] = 8'h68;
assign _c_characterGenerator8x8[555] = 8'h78;
assign _c_characterGenerator8x8[556] = 8'h68;
assign _c_characterGenerator8x8[557] = 8'h62;
assign _c_characterGenerator8x8[558] = 8'hfe;
assign _c_characterGenerator8x8[559] = 8'h00;
assign _c_characterGenerator8x8[560] = 8'hfe;
assign _c_characterGenerator8x8[561] = 8'h62;
assign _c_characterGenerator8x8[562] = 8'h68;
assign _c_characterGenerator8x8[563] = 8'h78;
assign _c_characterGenerator8x8[564] = 8'h68;
assign _c_characterGenerator8x8[565] = 8'h60;
assign _c_characterGenerator8x8[566] = 8'hf0;
assign _c_characterGenerator8x8[567] = 8'h00;
assign _c_characterGenerator8x8[568] = 8'h3c;
assign _c_characterGenerator8x8[569] = 8'h66;
assign _c_characterGenerator8x8[570] = 8'hc0;
assign _c_characterGenerator8x8[571] = 8'hc0;
assign _c_characterGenerator8x8[572] = 8'hce;
assign _c_characterGenerator8x8[573] = 8'h66;
assign _c_characterGenerator8x8[574] = 8'h3e;
assign _c_characterGenerator8x8[575] = 8'h00;
assign _c_characterGenerator8x8[576] = 8'hcc;
assign _c_characterGenerator8x8[577] = 8'hcc;
assign _c_characterGenerator8x8[578] = 8'hcc;
assign _c_characterGenerator8x8[579] = 8'hfc;
assign _c_characterGenerator8x8[580] = 8'hcc;
assign _c_characterGenerator8x8[581] = 8'hcc;
assign _c_characterGenerator8x8[582] = 8'hcc;
assign _c_characterGenerator8x8[583] = 8'h00;
assign _c_characterGenerator8x8[584] = 8'h78;
assign _c_characterGenerator8x8[585] = 8'h30;
assign _c_characterGenerator8x8[586] = 8'h30;
assign _c_characterGenerator8x8[587] = 8'h30;
assign _c_characterGenerator8x8[588] = 8'h30;
assign _c_characterGenerator8x8[589] = 8'h30;
assign _c_characterGenerator8x8[590] = 8'h78;
assign _c_characterGenerator8x8[591] = 8'h00;
assign _c_characterGenerator8x8[592] = 8'h1e;
assign _c_characterGenerator8x8[593] = 8'h0c;
assign _c_characterGenerator8x8[594] = 8'h0c;
assign _c_characterGenerator8x8[595] = 8'h0c;
assign _c_characterGenerator8x8[596] = 8'hcc;
assign _c_characterGenerator8x8[597] = 8'hcc;
assign _c_characterGenerator8x8[598] = 8'h78;
assign _c_characterGenerator8x8[599] = 8'h00;
assign _c_characterGenerator8x8[600] = 8'he6;
assign _c_characterGenerator8x8[601] = 8'h66;
assign _c_characterGenerator8x8[602] = 8'h6c;
assign _c_characterGenerator8x8[603] = 8'h78;
assign _c_characterGenerator8x8[604] = 8'h6c;
assign _c_characterGenerator8x8[605] = 8'h66;
assign _c_characterGenerator8x8[606] = 8'he6;
assign _c_characterGenerator8x8[607] = 8'h00;
assign _c_characterGenerator8x8[608] = 8'hf0;
assign _c_characterGenerator8x8[609] = 8'h60;
assign _c_characterGenerator8x8[610] = 8'h60;
assign _c_characterGenerator8x8[611] = 8'h60;
assign _c_characterGenerator8x8[612] = 8'h62;
assign _c_characterGenerator8x8[613] = 8'h66;
assign _c_characterGenerator8x8[614] = 8'hfe;
assign _c_characterGenerator8x8[615] = 8'h00;
assign _c_characterGenerator8x8[616] = 8'hc6;
assign _c_characterGenerator8x8[617] = 8'hee;
assign _c_characterGenerator8x8[618] = 8'hfe;
assign _c_characterGenerator8x8[619] = 8'hfe;
assign _c_characterGenerator8x8[620] = 8'hd6;
assign _c_characterGenerator8x8[621] = 8'hc6;
assign _c_characterGenerator8x8[622] = 8'hc6;
assign _c_characterGenerator8x8[623] = 8'h00;
assign _c_characterGenerator8x8[624] = 8'hc6;
assign _c_characterGenerator8x8[625] = 8'he6;
assign _c_characterGenerator8x8[626] = 8'hf6;
assign _c_characterGenerator8x8[627] = 8'hde;
assign _c_characterGenerator8x8[628] = 8'hce;
assign _c_characterGenerator8x8[629] = 8'hc6;
assign _c_characterGenerator8x8[630] = 8'hc6;
assign _c_characterGenerator8x8[631] = 8'h00;
assign _c_characterGenerator8x8[632] = 8'h38;
assign _c_characterGenerator8x8[633] = 8'h6c;
assign _c_characterGenerator8x8[634] = 8'hc6;
assign _c_characterGenerator8x8[635] = 8'hc6;
assign _c_characterGenerator8x8[636] = 8'hc6;
assign _c_characterGenerator8x8[637] = 8'h6c;
assign _c_characterGenerator8x8[638] = 8'h38;
assign _c_characterGenerator8x8[639] = 8'h00;
assign _c_characterGenerator8x8[640] = 8'hfc;
assign _c_characterGenerator8x8[641] = 8'h66;
assign _c_characterGenerator8x8[642] = 8'h66;
assign _c_characterGenerator8x8[643] = 8'h7c;
assign _c_characterGenerator8x8[644] = 8'h60;
assign _c_characterGenerator8x8[645] = 8'h60;
assign _c_characterGenerator8x8[646] = 8'hf0;
assign _c_characterGenerator8x8[647] = 8'h00;
assign _c_characterGenerator8x8[648] = 8'h78;
assign _c_characterGenerator8x8[649] = 8'hcc;
assign _c_characterGenerator8x8[650] = 8'hcc;
assign _c_characterGenerator8x8[651] = 8'hcc;
assign _c_characterGenerator8x8[652] = 8'hdc;
assign _c_characterGenerator8x8[653] = 8'h78;
assign _c_characterGenerator8x8[654] = 8'h1c;
assign _c_characterGenerator8x8[655] = 8'h00;
assign _c_characterGenerator8x8[656] = 8'hfc;
assign _c_characterGenerator8x8[657] = 8'h66;
assign _c_characterGenerator8x8[658] = 8'h66;
assign _c_characterGenerator8x8[659] = 8'h7c;
assign _c_characterGenerator8x8[660] = 8'h6c;
assign _c_characterGenerator8x8[661] = 8'h66;
assign _c_characterGenerator8x8[662] = 8'he6;
assign _c_characterGenerator8x8[663] = 8'h00;
assign _c_characterGenerator8x8[664] = 8'h78;
assign _c_characterGenerator8x8[665] = 8'hcc;
assign _c_characterGenerator8x8[666] = 8'he0;
assign _c_characterGenerator8x8[667] = 8'h70;
assign _c_characterGenerator8x8[668] = 8'h1c;
assign _c_characterGenerator8x8[669] = 8'hcc;
assign _c_characterGenerator8x8[670] = 8'h78;
assign _c_characterGenerator8x8[671] = 8'h00;
assign _c_characterGenerator8x8[672] = 8'hfc;
assign _c_characterGenerator8x8[673] = 8'hb4;
assign _c_characterGenerator8x8[674] = 8'h30;
assign _c_characterGenerator8x8[675] = 8'h30;
assign _c_characterGenerator8x8[676] = 8'h30;
assign _c_characterGenerator8x8[677] = 8'h30;
assign _c_characterGenerator8x8[678] = 8'h78;
assign _c_characterGenerator8x8[679] = 8'h00;
assign _c_characterGenerator8x8[680] = 8'hcc;
assign _c_characterGenerator8x8[681] = 8'hcc;
assign _c_characterGenerator8x8[682] = 8'hcc;
assign _c_characterGenerator8x8[683] = 8'hcc;
assign _c_characterGenerator8x8[684] = 8'hcc;
assign _c_characterGenerator8x8[685] = 8'hcc;
assign _c_characterGenerator8x8[686] = 8'hfc;
assign _c_characterGenerator8x8[687] = 8'h00;
assign _c_characterGenerator8x8[688] = 8'hcc;
assign _c_characterGenerator8x8[689] = 8'hcc;
assign _c_characterGenerator8x8[690] = 8'hcc;
assign _c_characterGenerator8x8[691] = 8'hcc;
assign _c_characterGenerator8x8[692] = 8'hcc;
assign _c_characterGenerator8x8[693] = 8'h78;
assign _c_characterGenerator8x8[694] = 8'h30;
assign _c_characterGenerator8x8[695] = 8'h00;
assign _c_characterGenerator8x8[696] = 8'hc6;
assign _c_characterGenerator8x8[697] = 8'hc6;
assign _c_characterGenerator8x8[698] = 8'hc6;
assign _c_characterGenerator8x8[699] = 8'hd6;
assign _c_characterGenerator8x8[700] = 8'hfe;
assign _c_characterGenerator8x8[701] = 8'hee;
assign _c_characterGenerator8x8[702] = 8'hc6;
assign _c_characterGenerator8x8[703] = 8'h00;
assign _c_characterGenerator8x8[704] = 8'hc6;
assign _c_characterGenerator8x8[705] = 8'hc6;
assign _c_characterGenerator8x8[706] = 8'h6c;
assign _c_characterGenerator8x8[707] = 8'h38;
assign _c_characterGenerator8x8[708] = 8'h38;
assign _c_characterGenerator8x8[709] = 8'h6c;
assign _c_characterGenerator8x8[710] = 8'hc6;
assign _c_characterGenerator8x8[711] = 8'h00;
assign _c_characterGenerator8x8[712] = 8'hcc;
assign _c_characterGenerator8x8[713] = 8'hcc;
assign _c_characterGenerator8x8[714] = 8'hcc;
assign _c_characterGenerator8x8[715] = 8'h78;
assign _c_characterGenerator8x8[716] = 8'h30;
assign _c_characterGenerator8x8[717] = 8'h30;
assign _c_characterGenerator8x8[718] = 8'h78;
assign _c_characterGenerator8x8[719] = 8'h00;
assign _c_characterGenerator8x8[720] = 8'hfe;
assign _c_characterGenerator8x8[721] = 8'hc6;
assign _c_characterGenerator8x8[722] = 8'h8c;
assign _c_characterGenerator8x8[723] = 8'h18;
assign _c_characterGenerator8x8[724] = 8'h32;
assign _c_characterGenerator8x8[725] = 8'h66;
assign _c_characterGenerator8x8[726] = 8'hfe;
assign _c_characterGenerator8x8[727] = 8'h00;
assign _c_characterGenerator8x8[728] = 8'h78;
assign _c_characterGenerator8x8[729] = 8'h60;
assign _c_characterGenerator8x8[730] = 8'h60;
assign _c_characterGenerator8x8[731] = 8'h60;
assign _c_characterGenerator8x8[732] = 8'h60;
assign _c_characterGenerator8x8[733] = 8'h60;
assign _c_characterGenerator8x8[734] = 8'h78;
assign _c_characterGenerator8x8[735] = 8'h00;
assign _c_characterGenerator8x8[736] = 8'hc0;
assign _c_characterGenerator8x8[737] = 8'h60;
assign _c_characterGenerator8x8[738] = 8'h30;
assign _c_characterGenerator8x8[739] = 8'h18;
assign _c_characterGenerator8x8[740] = 8'h0c;
assign _c_characterGenerator8x8[741] = 8'h06;
assign _c_characterGenerator8x8[742] = 8'h02;
assign _c_characterGenerator8x8[743] = 8'h00;
assign _c_characterGenerator8x8[744] = 8'h78;
assign _c_characterGenerator8x8[745] = 8'h18;
assign _c_characterGenerator8x8[746] = 8'h18;
assign _c_characterGenerator8x8[747] = 8'h18;
assign _c_characterGenerator8x8[748] = 8'h18;
assign _c_characterGenerator8x8[749] = 8'h18;
assign _c_characterGenerator8x8[750] = 8'h78;
assign _c_characterGenerator8x8[751] = 8'h00;
assign _c_characterGenerator8x8[752] = 8'h10;
assign _c_characterGenerator8x8[753] = 8'h38;
assign _c_characterGenerator8x8[754] = 8'h6c;
assign _c_characterGenerator8x8[755] = 8'hc6;
assign _c_characterGenerator8x8[756] = 8'h00;
assign _c_characterGenerator8x8[757] = 8'h00;
assign _c_characterGenerator8x8[758] = 8'h00;
assign _c_characterGenerator8x8[759] = 8'h00;
assign _c_characterGenerator8x8[760] = 8'h00;
assign _c_characterGenerator8x8[761] = 8'h00;
assign _c_characterGenerator8x8[762] = 8'h00;
assign _c_characterGenerator8x8[763] = 8'h00;
assign _c_characterGenerator8x8[764] = 8'h00;
assign _c_characterGenerator8x8[765] = 8'h00;
assign _c_characterGenerator8x8[766] = 8'h00;
assign _c_characterGenerator8x8[767] = 8'hff;
assign _c_characterGenerator8x8[768] = 8'h30;
assign _c_characterGenerator8x8[769] = 8'h30;
assign _c_characterGenerator8x8[770] = 8'h18;
assign _c_characterGenerator8x8[771] = 8'h00;
assign _c_characterGenerator8x8[772] = 8'h00;
assign _c_characterGenerator8x8[773] = 8'h00;
assign _c_characterGenerator8x8[774] = 8'h00;
assign _c_characterGenerator8x8[775] = 8'h00;
assign _c_characterGenerator8x8[776] = 8'h00;
assign _c_characterGenerator8x8[777] = 8'h00;
assign _c_characterGenerator8x8[778] = 8'h78;
assign _c_characterGenerator8x8[779] = 8'h0c;
assign _c_characterGenerator8x8[780] = 8'h7c;
assign _c_characterGenerator8x8[781] = 8'hcc;
assign _c_characterGenerator8x8[782] = 8'h76;
assign _c_characterGenerator8x8[783] = 8'h00;
assign _c_characterGenerator8x8[784] = 8'he0;
assign _c_characterGenerator8x8[785] = 8'h60;
assign _c_characterGenerator8x8[786] = 8'h60;
assign _c_characterGenerator8x8[787] = 8'h7c;
assign _c_characterGenerator8x8[788] = 8'h66;
assign _c_characterGenerator8x8[789] = 8'h66;
assign _c_characterGenerator8x8[790] = 8'hdc;
assign _c_characterGenerator8x8[791] = 8'h00;
assign _c_characterGenerator8x8[792] = 8'h00;
assign _c_characterGenerator8x8[793] = 8'h00;
assign _c_characterGenerator8x8[794] = 8'h78;
assign _c_characterGenerator8x8[795] = 8'hcc;
assign _c_characterGenerator8x8[796] = 8'hc0;
assign _c_characterGenerator8x8[797] = 8'hcc;
assign _c_characterGenerator8x8[798] = 8'h78;
assign _c_characterGenerator8x8[799] = 8'h00;
assign _c_characterGenerator8x8[800] = 8'h1c;
assign _c_characterGenerator8x8[801] = 8'h0c;
assign _c_characterGenerator8x8[802] = 8'h0c;
assign _c_characterGenerator8x8[803] = 8'h7c;
assign _c_characterGenerator8x8[804] = 8'hcc;
assign _c_characterGenerator8x8[805] = 8'hcc;
assign _c_characterGenerator8x8[806] = 8'h76;
assign _c_characterGenerator8x8[807] = 8'h00;
assign _c_characterGenerator8x8[808] = 8'h00;
assign _c_characterGenerator8x8[809] = 8'h00;
assign _c_characterGenerator8x8[810] = 8'h78;
assign _c_characterGenerator8x8[811] = 8'hcc;
assign _c_characterGenerator8x8[812] = 8'hfc;
assign _c_characterGenerator8x8[813] = 8'hc0;
assign _c_characterGenerator8x8[814] = 8'h78;
assign _c_characterGenerator8x8[815] = 8'h00;
assign _c_characterGenerator8x8[816] = 8'h38;
assign _c_characterGenerator8x8[817] = 8'h6c;
assign _c_characterGenerator8x8[818] = 8'h60;
assign _c_characterGenerator8x8[819] = 8'hf0;
assign _c_characterGenerator8x8[820] = 8'h60;
assign _c_characterGenerator8x8[821] = 8'h60;
assign _c_characterGenerator8x8[822] = 8'hf0;
assign _c_characterGenerator8x8[823] = 8'h00;
assign _c_characterGenerator8x8[824] = 8'h00;
assign _c_characterGenerator8x8[825] = 8'h00;
assign _c_characterGenerator8x8[826] = 8'h76;
assign _c_characterGenerator8x8[827] = 8'hcc;
assign _c_characterGenerator8x8[828] = 8'hcc;
assign _c_characterGenerator8x8[829] = 8'h7c;
assign _c_characterGenerator8x8[830] = 8'h0c;
assign _c_characterGenerator8x8[831] = 8'hf8;
assign _c_characterGenerator8x8[832] = 8'he0;
assign _c_characterGenerator8x8[833] = 8'h60;
assign _c_characterGenerator8x8[834] = 8'h6c;
assign _c_characterGenerator8x8[835] = 8'h76;
assign _c_characterGenerator8x8[836] = 8'h66;
assign _c_characterGenerator8x8[837] = 8'h66;
assign _c_characterGenerator8x8[838] = 8'he6;
assign _c_characterGenerator8x8[839] = 8'h00;
assign _c_characterGenerator8x8[840] = 8'h30;
assign _c_characterGenerator8x8[841] = 8'h00;
assign _c_characterGenerator8x8[842] = 8'h70;
assign _c_characterGenerator8x8[843] = 8'h30;
assign _c_characterGenerator8x8[844] = 8'h30;
assign _c_characterGenerator8x8[845] = 8'h30;
assign _c_characterGenerator8x8[846] = 8'h78;
assign _c_characterGenerator8x8[847] = 8'h00;
assign _c_characterGenerator8x8[848] = 8'h0c;
assign _c_characterGenerator8x8[849] = 8'h00;
assign _c_characterGenerator8x8[850] = 8'h0c;
assign _c_characterGenerator8x8[851] = 8'h0c;
assign _c_characterGenerator8x8[852] = 8'h0c;
assign _c_characterGenerator8x8[853] = 8'hcc;
assign _c_characterGenerator8x8[854] = 8'hcc;
assign _c_characterGenerator8x8[855] = 8'h78;
assign _c_characterGenerator8x8[856] = 8'he0;
assign _c_characterGenerator8x8[857] = 8'h60;
assign _c_characterGenerator8x8[858] = 8'h66;
assign _c_characterGenerator8x8[859] = 8'h6c;
assign _c_characterGenerator8x8[860] = 8'h78;
assign _c_characterGenerator8x8[861] = 8'h6c;
assign _c_characterGenerator8x8[862] = 8'he6;
assign _c_characterGenerator8x8[863] = 8'h00;
assign _c_characterGenerator8x8[864] = 8'h70;
assign _c_characterGenerator8x8[865] = 8'h30;
assign _c_characterGenerator8x8[866] = 8'h30;
assign _c_characterGenerator8x8[867] = 8'h30;
assign _c_characterGenerator8x8[868] = 8'h30;
assign _c_characterGenerator8x8[869] = 8'h30;
assign _c_characterGenerator8x8[870] = 8'h78;
assign _c_characterGenerator8x8[871] = 8'h00;
assign _c_characterGenerator8x8[872] = 8'h00;
assign _c_characterGenerator8x8[873] = 8'h00;
assign _c_characterGenerator8x8[874] = 8'hcc;
assign _c_characterGenerator8x8[875] = 8'hfe;
assign _c_characterGenerator8x8[876] = 8'hfe;
assign _c_characterGenerator8x8[877] = 8'hd6;
assign _c_characterGenerator8x8[878] = 8'hc6;
assign _c_characterGenerator8x8[879] = 8'h00;
assign _c_characterGenerator8x8[880] = 8'h00;
assign _c_characterGenerator8x8[881] = 8'h00;
assign _c_characterGenerator8x8[882] = 8'hf8;
assign _c_characterGenerator8x8[883] = 8'hcc;
assign _c_characterGenerator8x8[884] = 8'hcc;
assign _c_characterGenerator8x8[885] = 8'hcc;
assign _c_characterGenerator8x8[886] = 8'hcc;
assign _c_characterGenerator8x8[887] = 8'h00;
assign _c_characterGenerator8x8[888] = 8'h00;
assign _c_characterGenerator8x8[889] = 8'h00;
assign _c_characterGenerator8x8[890] = 8'h78;
assign _c_characterGenerator8x8[891] = 8'hcc;
assign _c_characterGenerator8x8[892] = 8'hcc;
assign _c_characterGenerator8x8[893] = 8'hcc;
assign _c_characterGenerator8x8[894] = 8'h78;
assign _c_characterGenerator8x8[895] = 8'h00;
assign _c_characterGenerator8x8[896] = 8'h00;
assign _c_characterGenerator8x8[897] = 8'h00;
assign _c_characterGenerator8x8[898] = 8'hdc;
assign _c_characterGenerator8x8[899] = 8'h66;
assign _c_characterGenerator8x8[900] = 8'h66;
assign _c_characterGenerator8x8[901] = 8'h7c;
assign _c_characterGenerator8x8[902] = 8'h60;
assign _c_characterGenerator8x8[903] = 8'hf0;
assign _c_characterGenerator8x8[904] = 8'h00;
assign _c_characterGenerator8x8[905] = 8'h00;
assign _c_characterGenerator8x8[906] = 8'h76;
assign _c_characterGenerator8x8[907] = 8'hcc;
assign _c_characterGenerator8x8[908] = 8'hcc;
assign _c_characterGenerator8x8[909] = 8'h7c;
assign _c_characterGenerator8x8[910] = 8'h0c;
assign _c_characterGenerator8x8[911] = 8'h1e;
assign _c_characterGenerator8x8[912] = 8'h00;
assign _c_characterGenerator8x8[913] = 8'h00;
assign _c_characterGenerator8x8[914] = 8'hdc;
assign _c_characterGenerator8x8[915] = 8'h76;
assign _c_characterGenerator8x8[916] = 8'h66;
assign _c_characterGenerator8x8[917] = 8'h60;
assign _c_characterGenerator8x8[918] = 8'hf0;
assign _c_characterGenerator8x8[919] = 8'h00;
assign _c_characterGenerator8x8[920] = 8'h00;
assign _c_characterGenerator8x8[921] = 8'h00;
assign _c_characterGenerator8x8[922] = 8'h7c;
assign _c_characterGenerator8x8[923] = 8'hc0;
assign _c_characterGenerator8x8[924] = 8'h78;
assign _c_characterGenerator8x8[925] = 8'h0c;
assign _c_characterGenerator8x8[926] = 8'hf8;
assign _c_characterGenerator8x8[927] = 8'h00;
assign _c_characterGenerator8x8[928] = 8'h10;
assign _c_characterGenerator8x8[929] = 8'h30;
assign _c_characterGenerator8x8[930] = 8'h7c;
assign _c_characterGenerator8x8[931] = 8'h30;
assign _c_characterGenerator8x8[932] = 8'h30;
assign _c_characterGenerator8x8[933] = 8'h34;
assign _c_characterGenerator8x8[934] = 8'h18;
assign _c_characterGenerator8x8[935] = 8'h00;
assign _c_characterGenerator8x8[936] = 8'h00;
assign _c_characterGenerator8x8[937] = 8'h00;
assign _c_characterGenerator8x8[938] = 8'hcc;
assign _c_characterGenerator8x8[939] = 8'hcc;
assign _c_characterGenerator8x8[940] = 8'hcc;
assign _c_characterGenerator8x8[941] = 8'hcc;
assign _c_characterGenerator8x8[942] = 8'h76;
assign _c_characterGenerator8x8[943] = 8'h00;
assign _c_characterGenerator8x8[944] = 8'h00;
assign _c_characterGenerator8x8[945] = 8'h00;
assign _c_characterGenerator8x8[946] = 8'hcc;
assign _c_characterGenerator8x8[947] = 8'hcc;
assign _c_characterGenerator8x8[948] = 8'hcc;
assign _c_characterGenerator8x8[949] = 8'h78;
assign _c_characterGenerator8x8[950] = 8'h30;
assign _c_characterGenerator8x8[951] = 8'h00;
assign _c_characterGenerator8x8[952] = 8'h00;
assign _c_characterGenerator8x8[953] = 8'h00;
assign _c_characterGenerator8x8[954] = 8'hc6;
assign _c_characterGenerator8x8[955] = 8'hd6;
assign _c_characterGenerator8x8[956] = 8'hfe;
assign _c_characterGenerator8x8[957] = 8'hfe;
assign _c_characterGenerator8x8[958] = 8'h6c;
assign _c_characterGenerator8x8[959] = 8'h00;
assign _c_characterGenerator8x8[960] = 8'h00;
assign _c_characterGenerator8x8[961] = 8'h00;
assign _c_characterGenerator8x8[962] = 8'hc6;
assign _c_characterGenerator8x8[963] = 8'h6c;
assign _c_characterGenerator8x8[964] = 8'h38;
assign _c_characterGenerator8x8[965] = 8'h6c;
assign _c_characterGenerator8x8[966] = 8'hc6;
assign _c_characterGenerator8x8[967] = 8'h00;
assign _c_characterGenerator8x8[968] = 8'h00;
assign _c_characterGenerator8x8[969] = 8'h00;
assign _c_characterGenerator8x8[970] = 8'hcc;
assign _c_characterGenerator8x8[971] = 8'hcc;
assign _c_characterGenerator8x8[972] = 8'hcc;
assign _c_characterGenerator8x8[973] = 8'h7c;
assign _c_characterGenerator8x8[974] = 8'h0c;
assign _c_characterGenerator8x8[975] = 8'hf8;
assign _c_characterGenerator8x8[976] = 8'h00;
assign _c_characterGenerator8x8[977] = 8'h00;
assign _c_characterGenerator8x8[978] = 8'hfc;
assign _c_characterGenerator8x8[979] = 8'h98;
assign _c_characterGenerator8x8[980] = 8'h30;
assign _c_characterGenerator8x8[981] = 8'h64;
assign _c_characterGenerator8x8[982] = 8'hfc;
assign _c_characterGenerator8x8[983] = 8'h00;
assign _c_characterGenerator8x8[984] = 8'h1c;
assign _c_characterGenerator8x8[985] = 8'h30;
assign _c_characterGenerator8x8[986] = 8'h30;
assign _c_characterGenerator8x8[987] = 8'he0;
assign _c_characterGenerator8x8[988] = 8'h30;
assign _c_characterGenerator8x8[989] = 8'h30;
assign _c_characterGenerator8x8[990] = 8'h1c;
assign _c_characterGenerator8x8[991] = 8'h00;
assign _c_characterGenerator8x8[992] = 8'h18;
assign _c_characterGenerator8x8[993] = 8'h18;
assign _c_characterGenerator8x8[994] = 8'h18;
assign _c_characterGenerator8x8[995] = 8'h00;
assign _c_characterGenerator8x8[996] = 8'h18;
assign _c_characterGenerator8x8[997] = 8'h18;
assign _c_characterGenerator8x8[998] = 8'h18;
assign _c_characterGenerator8x8[999] = 8'h00;
assign _c_characterGenerator8x8[1000] = 8'he0;
assign _c_characterGenerator8x8[1001] = 8'h30;
assign _c_characterGenerator8x8[1002] = 8'h30;
assign _c_characterGenerator8x8[1003] = 8'h1c;
assign _c_characterGenerator8x8[1004] = 8'h30;
assign _c_characterGenerator8x8[1005] = 8'h30;
assign _c_characterGenerator8x8[1006] = 8'he0;
assign _c_characterGenerator8x8[1007] = 8'h00;
assign _c_characterGenerator8x8[1008] = 8'h76;
assign _c_characterGenerator8x8[1009] = 8'hdc;
assign _c_characterGenerator8x8[1010] = 8'h00;
assign _c_characterGenerator8x8[1011] = 8'h00;
assign _c_characterGenerator8x8[1012] = 8'h00;
assign _c_characterGenerator8x8[1013] = 8'h00;
assign _c_characterGenerator8x8[1014] = 8'h00;
assign _c_characterGenerator8x8[1015] = 8'h00;
assign _c_characterGenerator8x8[1016] = 8'h00;
assign _c_characterGenerator8x8[1017] = 8'h10;
assign _c_characterGenerator8x8[1018] = 8'h38;
assign _c_characterGenerator8x8[1019] = 8'h6c;
assign _c_characterGenerator8x8[1020] = 8'hc6;
assign _c_characterGenerator8x8[1021] = 8'hc6;
assign _c_characterGenerator8x8[1022] = 8'hfe;
assign _c_characterGenerator8x8[1023] = 8'h00;
assign _c_characterGenerator8x8[1024] = 8'h78;
assign _c_characterGenerator8x8[1025] = 8'hcc;
assign _c_characterGenerator8x8[1026] = 8'hc0;
assign _c_characterGenerator8x8[1027] = 8'hcc;
assign _c_characterGenerator8x8[1028] = 8'h78;
assign _c_characterGenerator8x8[1029] = 8'h18;
assign _c_characterGenerator8x8[1030] = 8'h0c;
assign _c_characterGenerator8x8[1031] = 8'h78;
assign _c_characterGenerator8x8[1032] = 8'h00;
assign _c_characterGenerator8x8[1033] = 8'hcc;
assign _c_characterGenerator8x8[1034] = 8'h00;
assign _c_characterGenerator8x8[1035] = 8'hcc;
assign _c_characterGenerator8x8[1036] = 8'hcc;
assign _c_characterGenerator8x8[1037] = 8'hcc;
assign _c_characterGenerator8x8[1038] = 8'h7e;
assign _c_characterGenerator8x8[1039] = 8'h00;
assign _c_characterGenerator8x8[1040] = 8'h1c;
assign _c_characterGenerator8x8[1041] = 8'h00;
assign _c_characterGenerator8x8[1042] = 8'h78;
assign _c_characterGenerator8x8[1043] = 8'hcc;
assign _c_characterGenerator8x8[1044] = 8'hfc;
assign _c_characterGenerator8x8[1045] = 8'hc0;
assign _c_characterGenerator8x8[1046] = 8'h78;
assign _c_characterGenerator8x8[1047] = 8'h00;
assign _c_characterGenerator8x8[1048] = 8'h7e;
assign _c_characterGenerator8x8[1049] = 8'hc3;
assign _c_characterGenerator8x8[1050] = 8'h3c;
assign _c_characterGenerator8x8[1051] = 8'h06;
assign _c_characterGenerator8x8[1052] = 8'h3e;
assign _c_characterGenerator8x8[1053] = 8'h66;
assign _c_characterGenerator8x8[1054] = 8'h3f;
assign _c_characterGenerator8x8[1055] = 8'h00;
assign _c_characterGenerator8x8[1056] = 8'hcc;
assign _c_characterGenerator8x8[1057] = 8'h00;
assign _c_characterGenerator8x8[1058] = 8'h78;
assign _c_characterGenerator8x8[1059] = 8'h0c;
assign _c_characterGenerator8x8[1060] = 8'h7c;
assign _c_characterGenerator8x8[1061] = 8'hcc;
assign _c_characterGenerator8x8[1062] = 8'h7e;
assign _c_characterGenerator8x8[1063] = 8'h00;
assign _c_characterGenerator8x8[1064] = 8'he0;
assign _c_characterGenerator8x8[1065] = 8'h00;
assign _c_characterGenerator8x8[1066] = 8'h78;
assign _c_characterGenerator8x8[1067] = 8'h0c;
assign _c_characterGenerator8x8[1068] = 8'h7c;
assign _c_characterGenerator8x8[1069] = 8'hcc;
assign _c_characterGenerator8x8[1070] = 8'h7e;
assign _c_characterGenerator8x8[1071] = 8'h00;
assign _c_characterGenerator8x8[1072] = 8'h30;
assign _c_characterGenerator8x8[1073] = 8'h30;
assign _c_characterGenerator8x8[1074] = 8'h78;
assign _c_characterGenerator8x8[1075] = 8'h0c;
assign _c_characterGenerator8x8[1076] = 8'h7c;
assign _c_characterGenerator8x8[1077] = 8'hcc;
assign _c_characterGenerator8x8[1078] = 8'h7e;
assign _c_characterGenerator8x8[1079] = 8'h00;
assign _c_characterGenerator8x8[1080] = 8'h00;
assign _c_characterGenerator8x8[1081] = 8'h00;
assign _c_characterGenerator8x8[1082] = 8'h78;
assign _c_characterGenerator8x8[1083] = 8'hc0;
assign _c_characterGenerator8x8[1084] = 8'hc0;
assign _c_characterGenerator8x8[1085] = 8'h78;
assign _c_characterGenerator8x8[1086] = 8'h0c;
assign _c_characterGenerator8x8[1087] = 8'h38;
assign _c_characterGenerator8x8[1088] = 8'h7e;
assign _c_characterGenerator8x8[1089] = 8'hc3;
assign _c_characterGenerator8x8[1090] = 8'h3c;
assign _c_characterGenerator8x8[1091] = 8'h66;
assign _c_characterGenerator8x8[1092] = 8'h7e;
assign _c_characterGenerator8x8[1093] = 8'h60;
assign _c_characterGenerator8x8[1094] = 8'h3c;
assign _c_characterGenerator8x8[1095] = 8'h00;
assign _c_characterGenerator8x8[1096] = 8'hcc;
assign _c_characterGenerator8x8[1097] = 8'h00;
assign _c_characterGenerator8x8[1098] = 8'h78;
assign _c_characterGenerator8x8[1099] = 8'hcc;
assign _c_characterGenerator8x8[1100] = 8'hfc;
assign _c_characterGenerator8x8[1101] = 8'hc0;
assign _c_characterGenerator8x8[1102] = 8'h78;
assign _c_characterGenerator8x8[1103] = 8'h00;
assign _c_characterGenerator8x8[1104] = 8'he0;
assign _c_characterGenerator8x8[1105] = 8'h00;
assign _c_characterGenerator8x8[1106] = 8'h78;
assign _c_characterGenerator8x8[1107] = 8'hcc;
assign _c_characterGenerator8x8[1108] = 8'hfc;
assign _c_characterGenerator8x8[1109] = 8'hc0;
assign _c_characterGenerator8x8[1110] = 8'h78;
assign _c_characterGenerator8x8[1111] = 8'h00;
assign _c_characterGenerator8x8[1112] = 8'hcc;
assign _c_characterGenerator8x8[1113] = 8'h00;
assign _c_characterGenerator8x8[1114] = 8'h70;
assign _c_characterGenerator8x8[1115] = 8'h30;
assign _c_characterGenerator8x8[1116] = 8'h30;
assign _c_characterGenerator8x8[1117] = 8'h30;
assign _c_characterGenerator8x8[1118] = 8'h78;
assign _c_characterGenerator8x8[1119] = 8'h00;
assign _c_characterGenerator8x8[1120] = 8'h7c;
assign _c_characterGenerator8x8[1121] = 8'hc6;
assign _c_characterGenerator8x8[1122] = 8'h38;
assign _c_characterGenerator8x8[1123] = 8'h18;
assign _c_characterGenerator8x8[1124] = 8'h18;
assign _c_characterGenerator8x8[1125] = 8'h18;
assign _c_characterGenerator8x8[1126] = 8'h3c;
assign _c_characterGenerator8x8[1127] = 8'h00;
assign _c_characterGenerator8x8[1128] = 8'he0;
assign _c_characterGenerator8x8[1129] = 8'h00;
assign _c_characterGenerator8x8[1130] = 8'h70;
assign _c_characterGenerator8x8[1131] = 8'h30;
assign _c_characterGenerator8x8[1132] = 8'h30;
assign _c_characterGenerator8x8[1133] = 8'h30;
assign _c_characterGenerator8x8[1134] = 8'h78;
assign _c_characterGenerator8x8[1135] = 8'h00;
assign _c_characterGenerator8x8[1136] = 8'hc6;
assign _c_characterGenerator8x8[1137] = 8'h38;
assign _c_characterGenerator8x8[1138] = 8'h6c;
assign _c_characterGenerator8x8[1139] = 8'hc6;
assign _c_characterGenerator8x8[1140] = 8'hfe;
assign _c_characterGenerator8x8[1141] = 8'hc6;
assign _c_characterGenerator8x8[1142] = 8'hc6;
assign _c_characterGenerator8x8[1143] = 8'h00;
assign _c_characterGenerator8x8[1144] = 8'h30;
assign _c_characterGenerator8x8[1145] = 8'h30;
assign _c_characterGenerator8x8[1146] = 8'h00;
assign _c_characterGenerator8x8[1147] = 8'h78;
assign _c_characterGenerator8x8[1148] = 8'hcc;
assign _c_characterGenerator8x8[1149] = 8'hfc;
assign _c_characterGenerator8x8[1150] = 8'hcc;
assign _c_characterGenerator8x8[1151] = 8'h00;
assign _c_characterGenerator8x8[1152] = 8'h1c;
assign _c_characterGenerator8x8[1153] = 8'h00;
assign _c_characterGenerator8x8[1154] = 8'hfc;
assign _c_characterGenerator8x8[1155] = 8'h60;
assign _c_characterGenerator8x8[1156] = 8'h78;
assign _c_characterGenerator8x8[1157] = 8'h60;
assign _c_characterGenerator8x8[1158] = 8'hfc;
assign _c_characterGenerator8x8[1159] = 8'h00;
assign _c_characterGenerator8x8[1160] = 8'h00;
assign _c_characterGenerator8x8[1161] = 8'h00;
assign _c_characterGenerator8x8[1162] = 8'h7f;
assign _c_characterGenerator8x8[1163] = 8'h0c;
assign _c_characterGenerator8x8[1164] = 8'h7f;
assign _c_characterGenerator8x8[1165] = 8'hcc;
assign _c_characterGenerator8x8[1166] = 8'h7f;
assign _c_characterGenerator8x8[1167] = 8'h00;
assign _c_characterGenerator8x8[1168] = 8'h3e;
assign _c_characterGenerator8x8[1169] = 8'h6c;
assign _c_characterGenerator8x8[1170] = 8'hcc;
assign _c_characterGenerator8x8[1171] = 8'hfe;
assign _c_characterGenerator8x8[1172] = 8'hcc;
assign _c_characterGenerator8x8[1173] = 8'hcc;
assign _c_characterGenerator8x8[1174] = 8'hce;
assign _c_characterGenerator8x8[1175] = 8'h00;
assign _c_characterGenerator8x8[1176] = 8'h78;
assign _c_characterGenerator8x8[1177] = 8'hcc;
assign _c_characterGenerator8x8[1178] = 8'h00;
assign _c_characterGenerator8x8[1179] = 8'h78;
assign _c_characterGenerator8x8[1180] = 8'hcc;
assign _c_characterGenerator8x8[1181] = 8'hcc;
assign _c_characterGenerator8x8[1182] = 8'h78;
assign _c_characterGenerator8x8[1183] = 8'h00;
assign _c_characterGenerator8x8[1184] = 8'h00;
assign _c_characterGenerator8x8[1185] = 8'hcc;
assign _c_characterGenerator8x8[1186] = 8'h00;
assign _c_characterGenerator8x8[1187] = 8'h78;
assign _c_characterGenerator8x8[1188] = 8'hcc;
assign _c_characterGenerator8x8[1189] = 8'hcc;
assign _c_characterGenerator8x8[1190] = 8'h78;
assign _c_characterGenerator8x8[1191] = 8'h00;
assign _c_characterGenerator8x8[1192] = 8'h00;
assign _c_characterGenerator8x8[1193] = 8'he0;
assign _c_characterGenerator8x8[1194] = 8'h00;
assign _c_characterGenerator8x8[1195] = 8'h78;
assign _c_characterGenerator8x8[1196] = 8'hcc;
assign _c_characterGenerator8x8[1197] = 8'hcc;
assign _c_characterGenerator8x8[1198] = 8'h78;
assign _c_characterGenerator8x8[1199] = 8'h00;
assign _c_characterGenerator8x8[1200] = 8'h78;
assign _c_characterGenerator8x8[1201] = 8'hcc;
assign _c_characterGenerator8x8[1202] = 8'h00;
assign _c_characterGenerator8x8[1203] = 8'hcc;
assign _c_characterGenerator8x8[1204] = 8'hcc;
assign _c_characterGenerator8x8[1205] = 8'hcc;
assign _c_characterGenerator8x8[1206] = 8'h7e;
assign _c_characterGenerator8x8[1207] = 8'h00;
assign _c_characterGenerator8x8[1208] = 8'h00;
assign _c_characterGenerator8x8[1209] = 8'he0;
assign _c_characterGenerator8x8[1210] = 8'h00;
assign _c_characterGenerator8x8[1211] = 8'hcc;
assign _c_characterGenerator8x8[1212] = 8'hcc;
assign _c_characterGenerator8x8[1213] = 8'hcc;
assign _c_characterGenerator8x8[1214] = 8'h7e;
assign _c_characterGenerator8x8[1215] = 8'h00;
assign _c_characterGenerator8x8[1216] = 8'h00;
assign _c_characterGenerator8x8[1217] = 8'hcc;
assign _c_characterGenerator8x8[1218] = 8'h00;
assign _c_characterGenerator8x8[1219] = 8'hcc;
assign _c_characterGenerator8x8[1220] = 8'hcc;
assign _c_characterGenerator8x8[1221] = 8'h7c;
assign _c_characterGenerator8x8[1222] = 8'h0c;
assign _c_characterGenerator8x8[1223] = 8'hf8;
assign _c_characterGenerator8x8[1224] = 8'hc3;
assign _c_characterGenerator8x8[1225] = 8'h18;
assign _c_characterGenerator8x8[1226] = 8'h3c;
assign _c_characterGenerator8x8[1227] = 8'h66;
assign _c_characterGenerator8x8[1228] = 8'h66;
assign _c_characterGenerator8x8[1229] = 8'h3c;
assign _c_characterGenerator8x8[1230] = 8'h18;
assign _c_characterGenerator8x8[1231] = 8'h00;
assign _c_characterGenerator8x8[1232] = 8'hcc;
assign _c_characterGenerator8x8[1233] = 8'h00;
assign _c_characterGenerator8x8[1234] = 8'hcc;
assign _c_characterGenerator8x8[1235] = 8'hcc;
assign _c_characterGenerator8x8[1236] = 8'hcc;
assign _c_characterGenerator8x8[1237] = 8'hcc;
assign _c_characterGenerator8x8[1238] = 8'h78;
assign _c_characterGenerator8x8[1239] = 8'h00;
assign _c_characterGenerator8x8[1240] = 8'h18;
assign _c_characterGenerator8x8[1241] = 8'h18;
assign _c_characterGenerator8x8[1242] = 8'h7e;
assign _c_characterGenerator8x8[1243] = 8'hc0;
assign _c_characterGenerator8x8[1244] = 8'hc0;
assign _c_characterGenerator8x8[1245] = 8'h7e;
assign _c_characterGenerator8x8[1246] = 8'h18;
assign _c_characterGenerator8x8[1247] = 8'h18;
assign _c_characterGenerator8x8[1248] = 8'h38;
assign _c_characterGenerator8x8[1249] = 8'h6c;
assign _c_characterGenerator8x8[1250] = 8'h64;
assign _c_characterGenerator8x8[1251] = 8'hf0;
assign _c_characterGenerator8x8[1252] = 8'h60;
assign _c_characterGenerator8x8[1253] = 8'he6;
assign _c_characterGenerator8x8[1254] = 8'hfc;
assign _c_characterGenerator8x8[1255] = 8'h00;
assign _c_characterGenerator8x8[1256] = 8'hcc;
assign _c_characterGenerator8x8[1257] = 8'hcc;
assign _c_characterGenerator8x8[1258] = 8'h78;
assign _c_characterGenerator8x8[1259] = 8'hfc;
assign _c_characterGenerator8x8[1260] = 8'h30;
assign _c_characterGenerator8x8[1261] = 8'hfc;
assign _c_characterGenerator8x8[1262] = 8'h30;
assign _c_characterGenerator8x8[1263] = 8'h30;
assign _c_characterGenerator8x8[1264] = 8'hf8;
assign _c_characterGenerator8x8[1265] = 8'hcc;
assign _c_characterGenerator8x8[1266] = 8'hcc;
assign _c_characterGenerator8x8[1267] = 8'hfa;
assign _c_characterGenerator8x8[1268] = 8'hc6;
assign _c_characterGenerator8x8[1269] = 8'hcf;
assign _c_characterGenerator8x8[1270] = 8'hc6;
assign _c_characterGenerator8x8[1271] = 8'hc7;
assign _c_characterGenerator8x8[1272] = 8'h0e;
assign _c_characterGenerator8x8[1273] = 8'h1b;
assign _c_characterGenerator8x8[1274] = 8'h18;
assign _c_characterGenerator8x8[1275] = 8'h3c;
assign _c_characterGenerator8x8[1276] = 8'h18;
assign _c_characterGenerator8x8[1277] = 8'h18;
assign _c_characterGenerator8x8[1278] = 8'hd8;
assign _c_characterGenerator8x8[1279] = 8'h70;
assign _c_characterGenerator8x8[1280] = 8'h1c;
assign _c_characterGenerator8x8[1281] = 8'h00;
assign _c_characterGenerator8x8[1282] = 8'h78;
assign _c_characterGenerator8x8[1283] = 8'h0c;
assign _c_characterGenerator8x8[1284] = 8'h7c;
assign _c_characterGenerator8x8[1285] = 8'hcc;
assign _c_characterGenerator8x8[1286] = 8'h7e;
assign _c_characterGenerator8x8[1287] = 8'h00;
assign _c_characterGenerator8x8[1288] = 8'h38;
assign _c_characterGenerator8x8[1289] = 8'h00;
assign _c_characterGenerator8x8[1290] = 8'h70;
assign _c_characterGenerator8x8[1291] = 8'h30;
assign _c_characterGenerator8x8[1292] = 8'h30;
assign _c_characterGenerator8x8[1293] = 8'h30;
assign _c_characterGenerator8x8[1294] = 8'h78;
assign _c_characterGenerator8x8[1295] = 8'h00;
assign _c_characterGenerator8x8[1296] = 8'h00;
assign _c_characterGenerator8x8[1297] = 8'h1c;
assign _c_characterGenerator8x8[1298] = 8'h00;
assign _c_characterGenerator8x8[1299] = 8'h78;
assign _c_characterGenerator8x8[1300] = 8'hcc;
assign _c_characterGenerator8x8[1301] = 8'hcc;
assign _c_characterGenerator8x8[1302] = 8'h78;
assign _c_characterGenerator8x8[1303] = 8'h00;
assign _c_characterGenerator8x8[1304] = 8'h00;
assign _c_characterGenerator8x8[1305] = 8'h1c;
assign _c_characterGenerator8x8[1306] = 8'h00;
assign _c_characterGenerator8x8[1307] = 8'hcc;
assign _c_characterGenerator8x8[1308] = 8'hcc;
assign _c_characterGenerator8x8[1309] = 8'hcc;
assign _c_characterGenerator8x8[1310] = 8'h7e;
assign _c_characterGenerator8x8[1311] = 8'h00;
assign _c_characterGenerator8x8[1312] = 8'h00;
assign _c_characterGenerator8x8[1313] = 8'hf8;
assign _c_characterGenerator8x8[1314] = 8'h00;
assign _c_characterGenerator8x8[1315] = 8'hf8;
assign _c_characterGenerator8x8[1316] = 8'hcc;
assign _c_characterGenerator8x8[1317] = 8'hcc;
assign _c_characterGenerator8x8[1318] = 8'hcc;
assign _c_characterGenerator8x8[1319] = 8'h00;
assign _c_characterGenerator8x8[1320] = 8'hfc;
assign _c_characterGenerator8x8[1321] = 8'h00;
assign _c_characterGenerator8x8[1322] = 8'hcc;
assign _c_characterGenerator8x8[1323] = 8'hec;
assign _c_characterGenerator8x8[1324] = 8'hfc;
assign _c_characterGenerator8x8[1325] = 8'hdc;
assign _c_characterGenerator8x8[1326] = 8'hcc;
assign _c_characterGenerator8x8[1327] = 8'h00;
assign _c_characterGenerator8x8[1328] = 8'h3c;
assign _c_characterGenerator8x8[1329] = 8'h6c;
assign _c_characterGenerator8x8[1330] = 8'h6c;
assign _c_characterGenerator8x8[1331] = 8'h3e;
assign _c_characterGenerator8x8[1332] = 8'h00;
assign _c_characterGenerator8x8[1333] = 8'h7e;
assign _c_characterGenerator8x8[1334] = 8'h00;
assign _c_characterGenerator8x8[1335] = 8'h00;
assign _c_characterGenerator8x8[1336] = 8'h38;
assign _c_characterGenerator8x8[1337] = 8'h6c;
assign _c_characterGenerator8x8[1338] = 8'h6c;
assign _c_characterGenerator8x8[1339] = 8'h38;
assign _c_characterGenerator8x8[1340] = 8'h00;
assign _c_characterGenerator8x8[1341] = 8'h7c;
assign _c_characterGenerator8x8[1342] = 8'h00;
assign _c_characterGenerator8x8[1343] = 8'h00;
assign _c_characterGenerator8x8[1344] = 8'h30;
assign _c_characterGenerator8x8[1345] = 8'h00;
assign _c_characterGenerator8x8[1346] = 8'h30;
assign _c_characterGenerator8x8[1347] = 8'h60;
assign _c_characterGenerator8x8[1348] = 8'hc0;
assign _c_characterGenerator8x8[1349] = 8'hcc;
assign _c_characterGenerator8x8[1350] = 8'h78;
assign _c_characterGenerator8x8[1351] = 8'h00;
assign _c_characterGenerator8x8[1352] = 8'h00;
assign _c_characterGenerator8x8[1353] = 8'h00;
assign _c_characterGenerator8x8[1354] = 8'h00;
assign _c_characterGenerator8x8[1355] = 8'hfc;
assign _c_characterGenerator8x8[1356] = 8'hc0;
assign _c_characterGenerator8x8[1357] = 8'hc0;
assign _c_characterGenerator8x8[1358] = 8'h00;
assign _c_characterGenerator8x8[1359] = 8'h00;
assign _c_characterGenerator8x8[1360] = 8'h00;
assign _c_characterGenerator8x8[1361] = 8'h00;
assign _c_characterGenerator8x8[1362] = 8'h00;
assign _c_characterGenerator8x8[1363] = 8'hfc;
assign _c_characterGenerator8x8[1364] = 8'h0c;
assign _c_characterGenerator8x8[1365] = 8'h0c;
assign _c_characterGenerator8x8[1366] = 8'h00;
assign _c_characterGenerator8x8[1367] = 8'h00;
assign _c_characterGenerator8x8[1368] = 8'hc3;
assign _c_characterGenerator8x8[1369] = 8'hc6;
assign _c_characterGenerator8x8[1370] = 8'hcc;
assign _c_characterGenerator8x8[1371] = 8'hde;
assign _c_characterGenerator8x8[1372] = 8'h33;
assign _c_characterGenerator8x8[1373] = 8'h66;
assign _c_characterGenerator8x8[1374] = 8'hcc;
assign _c_characterGenerator8x8[1375] = 8'h0f;
assign _c_characterGenerator8x8[1376] = 8'hc3;
assign _c_characterGenerator8x8[1377] = 8'hc6;
assign _c_characterGenerator8x8[1378] = 8'hcc;
assign _c_characterGenerator8x8[1379] = 8'hdb;
assign _c_characterGenerator8x8[1380] = 8'h37;
assign _c_characterGenerator8x8[1381] = 8'h6f;
assign _c_characterGenerator8x8[1382] = 8'hcf;
assign _c_characterGenerator8x8[1383] = 8'h03;
assign _c_characterGenerator8x8[1384] = 8'h18;
assign _c_characterGenerator8x8[1385] = 8'h18;
assign _c_characterGenerator8x8[1386] = 8'h00;
assign _c_characterGenerator8x8[1387] = 8'h18;
assign _c_characterGenerator8x8[1388] = 8'h18;
assign _c_characterGenerator8x8[1389] = 8'h18;
assign _c_characterGenerator8x8[1390] = 8'h18;
assign _c_characterGenerator8x8[1391] = 8'h00;
assign _c_characterGenerator8x8[1392] = 8'h00;
assign _c_characterGenerator8x8[1393] = 8'h33;
assign _c_characterGenerator8x8[1394] = 8'h66;
assign _c_characterGenerator8x8[1395] = 8'hcc;
assign _c_characterGenerator8x8[1396] = 8'h66;
assign _c_characterGenerator8x8[1397] = 8'h33;
assign _c_characterGenerator8x8[1398] = 8'h00;
assign _c_characterGenerator8x8[1399] = 8'h00;
assign _c_characterGenerator8x8[1400] = 8'h00;
assign _c_characterGenerator8x8[1401] = 8'hcc;
assign _c_characterGenerator8x8[1402] = 8'h66;
assign _c_characterGenerator8x8[1403] = 8'h33;
assign _c_characterGenerator8x8[1404] = 8'h66;
assign _c_characterGenerator8x8[1405] = 8'hcc;
assign _c_characterGenerator8x8[1406] = 8'h00;
assign _c_characterGenerator8x8[1407] = 8'h00;
assign _c_characterGenerator8x8[1408] = 8'h22;
assign _c_characterGenerator8x8[1409] = 8'h88;
assign _c_characterGenerator8x8[1410] = 8'h22;
assign _c_characterGenerator8x8[1411] = 8'h88;
assign _c_characterGenerator8x8[1412] = 8'h22;
assign _c_characterGenerator8x8[1413] = 8'h88;
assign _c_characterGenerator8x8[1414] = 8'h22;
assign _c_characterGenerator8x8[1415] = 8'h88;
assign _c_characterGenerator8x8[1416] = 8'h55;
assign _c_characterGenerator8x8[1417] = 8'haa;
assign _c_characterGenerator8x8[1418] = 8'h55;
assign _c_characterGenerator8x8[1419] = 8'haa;
assign _c_characterGenerator8x8[1420] = 8'h55;
assign _c_characterGenerator8x8[1421] = 8'haa;
assign _c_characterGenerator8x8[1422] = 8'h55;
assign _c_characterGenerator8x8[1423] = 8'haa;
assign _c_characterGenerator8x8[1424] = 8'hdb;
assign _c_characterGenerator8x8[1425] = 8'h77;
assign _c_characterGenerator8x8[1426] = 8'hdb;
assign _c_characterGenerator8x8[1427] = 8'hee;
assign _c_characterGenerator8x8[1428] = 8'hdb;
assign _c_characterGenerator8x8[1429] = 8'h77;
assign _c_characterGenerator8x8[1430] = 8'hdb;
assign _c_characterGenerator8x8[1431] = 8'hee;
assign _c_characterGenerator8x8[1432] = 8'h18;
assign _c_characterGenerator8x8[1433] = 8'h18;
assign _c_characterGenerator8x8[1434] = 8'h18;
assign _c_characterGenerator8x8[1435] = 8'h18;
assign _c_characterGenerator8x8[1436] = 8'h18;
assign _c_characterGenerator8x8[1437] = 8'h18;
assign _c_characterGenerator8x8[1438] = 8'h18;
assign _c_characterGenerator8x8[1439] = 8'h18;
assign _c_characterGenerator8x8[1440] = 8'h18;
assign _c_characterGenerator8x8[1441] = 8'h18;
assign _c_characterGenerator8x8[1442] = 8'h18;
assign _c_characterGenerator8x8[1443] = 8'h18;
assign _c_characterGenerator8x8[1444] = 8'hf8;
assign _c_characterGenerator8x8[1445] = 8'h18;
assign _c_characterGenerator8x8[1446] = 8'h18;
assign _c_characterGenerator8x8[1447] = 8'h18;
assign _c_characterGenerator8x8[1448] = 8'h18;
assign _c_characterGenerator8x8[1449] = 8'h18;
assign _c_characterGenerator8x8[1450] = 8'hf8;
assign _c_characterGenerator8x8[1451] = 8'h18;
assign _c_characterGenerator8x8[1452] = 8'hf8;
assign _c_characterGenerator8x8[1453] = 8'h18;
assign _c_characterGenerator8x8[1454] = 8'h18;
assign _c_characterGenerator8x8[1455] = 8'h18;
assign _c_characterGenerator8x8[1456] = 8'h36;
assign _c_characterGenerator8x8[1457] = 8'h36;
assign _c_characterGenerator8x8[1458] = 8'h36;
assign _c_characterGenerator8x8[1459] = 8'h36;
assign _c_characterGenerator8x8[1460] = 8'hf6;
assign _c_characterGenerator8x8[1461] = 8'h36;
assign _c_characterGenerator8x8[1462] = 8'h36;
assign _c_characterGenerator8x8[1463] = 8'h36;
assign _c_characterGenerator8x8[1464] = 8'h00;
assign _c_characterGenerator8x8[1465] = 8'h00;
assign _c_characterGenerator8x8[1466] = 8'h00;
assign _c_characterGenerator8x8[1467] = 8'h00;
assign _c_characterGenerator8x8[1468] = 8'hfe;
assign _c_characterGenerator8x8[1469] = 8'h36;
assign _c_characterGenerator8x8[1470] = 8'h36;
assign _c_characterGenerator8x8[1471] = 8'h36;
assign _c_characterGenerator8x8[1472] = 8'h00;
assign _c_characterGenerator8x8[1473] = 8'h00;
assign _c_characterGenerator8x8[1474] = 8'hf8;
assign _c_characterGenerator8x8[1475] = 8'h18;
assign _c_characterGenerator8x8[1476] = 8'hf8;
assign _c_characterGenerator8x8[1477] = 8'h18;
assign _c_characterGenerator8x8[1478] = 8'h18;
assign _c_characterGenerator8x8[1479] = 8'h18;
assign _c_characterGenerator8x8[1480] = 8'h36;
assign _c_characterGenerator8x8[1481] = 8'h36;
assign _c_characterGenerator8x8[1482] = 8'hf6;
assign _c_characterGenerator8x8[1483] = 8'h06;
assign _c_characterGenerator8x8[1484] = 8'hf6;
assign _c_characterGenerator8x8[1485] = 8'h36;
assign _c_characterGenerator8x8[1486] = 8'h36;
assign _c_characterGenerator8x8[1487] = 8'h36;
assign _c_characterGenerator8x8[1488] = 8'h36;
assign _c_characterGenerator8x8[1489] = 8'h36;
assign _c_characterGenerator8x8[1490] = 8'h36;
assign _c_characterGenerator8x8[1491] = 8'h36;
assign _c_characterGenerator8x8[1492] = 8'h36;
assign _c_characterGenerator8x8[1493] = 8'h36;
assign _c_characterGenerator8x8[1494] = 8'h36;
assign _c_characterGenerator8x8[1495] = 8'h36;
assign _c_characterGenerator8x8[1496] = 8'h00;
assign _c_characterGenerator8x8[1497] = 8'h00;
assign _c_characterGenerator8x8[1498] = 8'hfe;
assign _c_characterGenerator8x8[1499] = 8'h06;
assign _c_characterGenerator8x8[1500] = 8'hf6;
assign _c_characterGenerator8x8[1501] = 8'h36;
assign _c_characterGenerator8x8[1502] = 8'h36;
assign _c_characterGenerator8x8[1503] = 8'h36;
assign _c_characterGenerator8x8[1504] = 8'h36;
assign _c_characterGenerator8x8[1505] = 8'h36;
assign _c_characterGenerator8x8[1506] = 8'hf6;
assign _c_characterGenerator8x8[1507] = 8'h06;
assign _c_characterGenerator8x8[1508] = 8'hfe;
assign _c_characterGenerator8x8[1509] = 8'h00;
assign _c_characterGenerator8x8[1510] = 8'h00;
assign _c_characterGenerator8x8[1511] = 8'h00;
assign _c_characterGenerator8x8[1512] = 8'h36;
assign _c_characterGenerator8x8[1513] = 8'h36;
assign _c_characterGenerator8x8[1514] = 8'h36;
assign _c_characterGenerator8x8[1515] = 8'h36;
assign _c_characterGenerator8x8[1516] = 8'hfe;
assign _c_characterGenerator8x8[1517] = 8'h00;
assign _c_characterGenerator8x8[1518] = 8'h00;
assign _c_characterGenerator8x8[1519] = 8'h00;
assign _c_characterGenerator8x8[1520] = 8'h18;
assign _c_characterGenerator8x8[1521] = 8'h18;
assign _c_characterGenerator8x8[1522] = 8'hf8;
assign _c_characterGenerator8x8[1523] = 8'h18;
assign _c_characterGenerator8x8[1524] = 8'hf8;
assign _c_characterGenerator8x8[1525] = 8'h00;
assign _c_characterGenerator8x8[1526] = 8'h00;
assign _c_characterGenerator8x8[1527] = 8'h00;
assign _c_characterGenerator8x8[1528] = 8'h00;
assign _c_characterGenerator8x8[1529] = 8'h00;
assign _c_characterGenerator8x8[1530] = 8'h00;
assign _c_characterGenerator8x8[1531] = 8'h00;
assign _c_characterGenerator8x8[1532] = 8'hf8;
assign _c_characterGenerator8x8[1533] = 8'h18;
assign _c_characterGenerator8x8[1534] = 8'h18;
assign _c_characterGenerator8x8[1535] = 8'h18;
assign _c_characterGenerator8x8[1536] = 8'h18;
assign _c_characterGenerator8x8[1537] = 8'h18;
assign _c_characterGenerator8x8[1538] = 8'h18;
assign _c_characterGenerator8x8[1539] = 8'h18;
assign _c_characterGenerator8x8[1540] = 8'h1f;
assign _c_characterGenerator8x8[1541] = 8'h00;
assign _c_characterGenerator8x8[1542] = 8'h00;
assign _c_characterGenerator8x8[1543] = 8'h00;
assign _c_characterGenerator8x8[1544] = 8'h18;
assign _c_characterGenerator8x8[1545] = 8'h18;
assign _c_characterGenerator8x8[1546] = 8'h18;
assign _c_characterGenerator8x8[1547] = 8'h18;
assign _c_characterGenerator8x8[1548] = 8'hff;
assign _c_characterGenerator8x8[1549] = 8'h00;
assign _c_characterGenerator8x8[1550] = 8'h00;
assign _c_characterGenerator8x8[1551] = 8'h00;
assign _c_characterGenerator8x8[1552] = 8'h00;
assign _c_characterGenerator8x8[1553] = 8'h00;
assign _c_characterGenerator8x8[1554] = 8'h00;
assign _c_characterGenerator8x8[1555] = 8'h00;
assign _c_characterGenerator8x8[1556] = 8'hff;
assign _c_characterGenerator8x8[1557] = 8'h18;
assign _c_characterGenerator8x8[1558] = 8'h18;
assign _c_characterGenerator8x8[1559] = 8'h18;
assign _c_characterGenerator8x8[1560] = 8'h18;
assign _c_characterGenerator8x8[1561] = 8'h18;
assign _c_characterGenerator8x8[1562] = 8'h18;
assign _c_characterGenerator8x8[1563] = 8'h18;
assign _c_characterGenerator8x8[1564] = 8'h1f;
assign _c_characterGenerator8x8[1565] = 8'h18;
assign _c_characterGenerator8x8[1566] = 8'h18;
assign _c_characterGenerator8x8[1567] = 8'h18;
assign _c_characterGenerator8x8[1568] = 8'h00;
assign _c_characterGenerator8x8[1569] = 8'h00;
assign _c_characterGenerator8x8[1570] = 8'h00;
assign _c_characterGenerator8x8[1571] = 8'h00;
assign _c_characterGenerator8x8[1572] = 8'hff;
assign _c_characterGenerator8x8[1573] = 8'h00;
assign _c_characterGenerator8x8[1574] = 8'h00;
assign _c_characterGenerator8x8[1575] = 8'h00;
assign _c_characterGenerator8x8[1576] = 8'h18;
assign _c_characterGenerator8x8[1577] = 8'h18;
assign _c_characterGenerator8x8[1578] = 8'h18;
assign _c_characterGenerator8x8[1579] = 8'h18;
assign _c_characterGenerator8x8[1580] = 8'hff;
assign _c_characterGenerator8x8[1581] = 8'h18;
assign _c_characterGenerator8x8[1582] = 8'h18;
assign _c_characterGenerator8x8[1583] = 8'h18;
assign _c_characterGenerator8x8[1584] = 8'h18;
assign _c_characterGenerator8x8[1585] = 8'h18;
assign _c_characterGenerator8x8[1586] = 8'h1f;
assign _c_characterGenerator8x8[1587] = 8'h18;
assign _c_characterGenerator8x8[1588] = 8'h1f;
assign _c_characterGenerator8x8[1589] = 8'h18;
assign _c_characterGenerator8x8[1590] = 8'h18;
assign _c_characterGenerator8x8[1591] = 8'h18;
assign _c_characterGenerator8x8[1592] = 8'h36;
assign _c_characterGenerator8x8[1593] = 8'h36;
assign _c_characterGenerator8x8[1594] = 8'h36;
assign _c_characterGenerator8x8[1595] = 8'h36;
assign _c_characterGenerator8x8[1596] = 8'h37;
assign _c_characterGenerator8x8[1597] = 8'h36;
assign _c_characterGenerator8x8[1598] = 8'h36;
assign _c_characterGenerator8x8[1599] = 8'h36;
assign _c_characterGenerator8x8[1600] = 8'h36;
assign _c_characterGenerator8x8[1601] = 8'h36;
assign _c_characterGenerator8x8[1602] = 8'h37;
assign _c_characterGenerator8x8[1603] = 8'h30;
assign _c_characterGenerator8x8[1604] = 8'h3f;
assign _c_characterGenerator8x8[1605] = 8'h00;
assign _c_characterGenerator8x8[1606] = 8'h00;
assign _c_characterGenerator8x8[1607] = 8'h00;
assign _c_characterGenerator8x8[1608] = 8'h00;
assign _c_characterGenerator8x8[1609] = 8'h00;
assign _c_characterGenerator8x8[1610] = 8'h3f;
assign _c_characterGenerator8x8[1611] = 8'h30;
assign _c_characterGenerator8x8[1612] = 8'h37;
assign _c_characterGenerator8x8[1613] = 8'h36;
assign _c_characterGenerator8x8[1614] = 8'h36;
assign _c_characterGenerator8x8[1615] = 8'h36;
assign _c_characterGenerator8x8[1616] = 8'h36;
assign _c_characterGenerator8x8[1617] = 8'h36;
assign _c_characterGenerator8x8[1618] = 8'hf7;
assign _c_characterGenerator8x8[1619] = 8'h00;
assign _c_characterGenerator8x8[1620] = 8'hff;
assign _c_characterGenerator8x8[1621] = 8'h00;
assign _c_characterGenerator8x8[1622] = 8'h00;
assign _c_characterGenerator8x8[1623] = 8'h00;
assign _c_characterGenerator8x8[1624] = 8'h00;
assign _c_characterGenerator8x8[1625] = 8'h00;
assign _c_characterGenerator8x8[1626] = 8'hff;
assign _c_characterGenerator8x8[1627] = 8'h00;
assign _c_characterGenerator8x8[1628] = 8'hf7;
assign _c_characterGenerator8x8[1629] = 8'h36;
assign _c_characterGenerator8x8[1630] = 8'h36;
assign _c_characterGenerator8x8[1631] = 8'h36;
assign _c_characterGenerator8x8[1632] = 8'h36;
assign _c_characterGenerator8x8[1633] = 8'h36;
assign _c_characterGenerator8x8[1634] = 8'h37;
assign _c_characterGenerator8x8[1635] = 8'h30;
assign _c_characterGenerator8x8[1636] = 8'h37;
assign _c_characterGenerator8x8[1637] = 8'h36;
assign _c_characterGenerator8x8[1638] = 8'h36;
assign _c_characterGenerator8x8[1639] = 8'h36;
assign _c_characterGenerator8x8[1640] = 8'h00;
assign _c_characterGenerator8x8[1641] = 8'h00;
assign _c_characterGenerator8x8[1642] = 8'hff;
assign _c_characterGenerator8x8[1643] = 8'h00;
assign _c_characterGenerator8x8[1644] = 8'hff;
assign _c_characterGenerator8x8[1645] = 8'h00;
assign _c_characterGenerator8x8[1646] = 8'h00;
assign _c_characterGenerator8x8[1647] = 8'h00;
assign _c_characterGenerator8x8[1648] = 8'h36;
assign _c_characterGenerator8x8[1649] = 8'h36;
assign _c_characterGenerator8x8[1650] = 8'hf7;
assign _c_characterGenerator8x8[1651] = 8'h00;
assign _c_characterGenerator8x8[1652] = 8'hf7;
assign _c_characterGenerator8x8[1653] = 8'h36;
assign _c_characterGenerator8x8[1654] = 8'h36;
assign _c_characterGenerator8x8[1655] = 8'h36;
assign _c_characterGenerator8x8[1656] = 8'h18;
assign _c_characterGenerator8x8[1657] = 8'h18;
assign _c_characterGenerator8x8[1658] = 8'hff;
assign _c_characterGenerator8x8[1659] = 8'h00;
assign _c_characterGenerator8x8[1660] = 8'hff;
assign _c_characterGenerator8x8[1661] = 8'h00;
assign _c_characterGenerator8x8[1662] = 8'h00;
assign _c_characterGenerator8x8[1663] = 8'h00;
assign _c_characterGenerator8x8[1664] = 8'h36;
assign _c_characterGenerator8x8[1665] = 8'h36;
assign _c_characterGenerator8x8[1666] = 8'h36;
assign _c_characterGenerator8x8[1667] = 8'h36;
assign _c_characterGenerator8x8[1668] = 8'hff;
assign _c_characterGenerator8x8[1669] = 8'h00;
assign _c_characterGenerator8x8[1670] = 8'h00;
assign _c_characterGenerator8x8[1671] = 8'h00;
assign _c_characterGenerator8x8[1672] = 8'h00;
assign _c_characterGenerator8x8[1673] = 8'h00;
assign _c_characterGenerator8x8[1674] = 8'hff;
assign _c_characterGenerator8x8[1675] = 8'h00;
assign _c_characterGenerator8x8[1676] = 8'hff;
assign _c_characterGenerator8x8[1677] = 8'h18;
assign _c_characterGenerator8x8[1678] = 8'h18;
assign _c_characterGenerator8x8[1679] = 8'h18;
assign _c_characterGenerator8x8[1680] = 8'h00;
assign _c_characterGenerator8x8[1681] = 8'h00;
assign _c_characterGenerator8x8[1682] = 8'h00;
assign _c_characterGenerator8x8[1683] = 8'h00;
assign _c_characterGenerator8x8[1684] = 8'hff;
assign _c_characterGenerator8x8[1685] = 8'h36;
assign _c_characterGenerator8x8[1686] = 8'h36;
assign _c_characterGenerator8x8[1687] = 8'h36;
assign _c_characterGenerator8x8[1688] = 8'h36;
assign _c_characterGenerator8x8[1689] = 8'h36;
assign _c_characterGenerator8x8[1690] = 8'h36;
assign _c_characterGenerator8x8[1691] = 8'h36;
assign _c_characterGenerator8x8[1692] = 8'h3f;
assign _c_characterGenerator8x8[1693] = 8'h00;
assign _c_characterGenerator8x8[1694] = 8'h00;
assign _c_characterGenerator8x8[1695] = 8'h00;
assign _c_characterGenerator8x8[1696] = 8'h18;
assign _c_characterGenerator8x8[1697] = 8'h18;
assign _c_characterGenerator8x8[1698] = 8'h1f;
assign _c_characterGenerator8x8[1699] = 8'h18;
assign _c_characterGenerator8x8[1700] = 8'h1f;
assign _c_characterGenerator8x8[1701] = 8'h00;
assign _c_characterGenerator8x8[1702] = 8'h00;
assign _c_characterGenerator8x8[1703] = 8'h00;
assign _c_characterGenerator8x8[1704] = 8'h00;
assign _c_characterGenerator8x8[1705] = 8'h00;
assign _c_characterGenerator8x8[1706] = 8'h1f;
assign _c_characterGenerator8x8[1707] = 8'h18;
assign _c_characterGenerator8x8[1708] = 8'h1f;
assign _c_characterGenerator8x8[1709] = 8'h18;
assign _c_characterGenerator8x8[1710] = 8'h18;
assign _c_characterGenerator8x8[1711] = 8'h18;
assign _c_characterGenerator8x8[1712] = 8'h00;
assign _c_characterGenerator8x8[1713] = 8'h00;
assign _c_characterGenerator8x8[1714] = 8'h00;
assign _c_characterGenerator8x8[1715] = 8'h00;
assign _c_characterGenerator8x8[1716] = 8'h3f;
assign _c_characterGenerator8x8[1717] = 8'h36;
assign _c_characterGenerator8x8[1718] = 8'h36;
assign _c_characterGenerator8x8[1719] = 8'h36;
assign _c_characterGenerator8x8[1720] = 8'h36;
assign _c_characterGenerator8x8[1721] = 8'h36;
assign _c_characterGenerator8x8[1722] = 8'h36;
assign _c_characterGenerator8x8[1723] = 8'h36;
assign _c_characterGenerator8x8[1724] = 8'hff;
assign _c_characterGenerator8x8[1725] = 8'h36;
assign _c_characterGenerator8x8[1726] = 8'h36;
assign _c_characterGenerator8x8[1727] = 8'h36;
assign _c_characterGenerator8x8[1728] = 8'h18;
assign _c_characterGenerator8x8[1729] = 8'h18;
assign _c_characterGenerator8x8[1730] = 8'hff;
assign _c_characterGenerator8x8[1731] = 8'h18;
assign _c_characterGenerator8x8[1732] = 8'hff;
assign _c_characterGenerator8x8[1733] = 8'h18;
assign _c_characterGenerator8x8[1734] = 8'h18;
assign _c_characterGenerator8x8[1735] = 8'h18;
assign _c_characterGenerator8x8[1736] = 8'h18;
assign _c_characterGenerator8x8[1737] = 8'h18;
assign _c_characterGenerator8x8[1738] = 8'h18;
assign _c_characterGenerator8x8[1739] = 8'h18;
assign _c_characterGenerator8x8[1740] = 8'hf8;
assign _c_characterGenerator8x8[1741] = 8'h00;
assign _c_characterGenerator8x8[1742] = 8'h00;
assign _c_characterGenerator8x8[1743] = 8'h00;
assign _c_characterGenerator8x8[1744] = 8'h00;
assign _c_characterGenerator8x8[1745] = 8'h00;
assign _c_characterGenerator8x8[1746] = 8'h00;
assign _c_characterGenerator8x8[1747] = 8'h00;
assign _c_characterGenerator8x8[1748] = 8'h1f;
assign _c_characterGenerator8x8[1749] = 8'h18;
assign _c_characterGenerator8x8[1750] = 8'h18;
assign _c_characterGenerator8x8[1751] = 8'h18;
assign _c_characterGenerator8x8[1752] = 8'hff;
assign _c_characterGenerator8x8[1753] = 8'hff;
assign _c_characterGenerator8x8[1754] = 8'hff;
assign _c_characterGenerator8x8[1755] = 8'hff;
assign _c_characterGenerator8x8[1756] = 8'hff;
assign _c_characterGenerator8x8[1757] = 8'hff;
assign _c_characterGenerator8x8[1758] = 8'hff;
assign _c_characterGenerator8x8[1759] = 8'hff;
assign _c_characterGenerator8x8[1760] = 8'h00;
assign _c_characterGenerator8x8[1761] = 8'h00;
assign _c_characterGenerator8x8[1762] = 8'h00;
assign _c_characterGenerator8x8[1763] = 8'h00;
assign _c_characterGenerator8x8[1764] = 8'hff;
assign _c_characterGenerator8x8[1765] = 8'hff;
assign _c_characterGenerator8x8[1766] = 8'hff;
assign _c_characterGenerator8x8[1767] = 8'hff;
assign _c_characterGenerator8x8[1768] = 8'hf0;
assign _c_characterGenerator8x8[1769] = 8'hf0;
assign _c_characterGenerator8x8[1770] = 8'hf0;
assign _c_characterGenerator8x8[1771] = 8'hf0;
assign _c_characterGenerator8x8[1772] = 8'hf0;
assign _c_characterGenerator8x8[1773] = 8'hf0;
assign _c_characterGenerator8x8[1774] = 8'hf0;
assign _c_characterGenerator8x8[1775] = 8'hf0;
assign _c_characterGenerator8x8[1776] = 8'h0f;
assign _c_characterGenerator8x8[1777] = 8'h0f;
assign _c_characterGenerator8x8[1778] = 8'h0f;
assign _c_characterGenerator8x8[1779] = 8'h0f;
assign _c_characterGenerator8x8[1780] = 8'h0f;
assign _c_characterGenerator8x8[1781] = 8'h0f;
assign _c_characterGenerator8x8[1782] = 8'h0f;
assign _c_characterGenerator8x8[1783] = 8'h0f;
assign _c_characterGenerator8x8[1784] = 8'hff;
assign _c_characterGenerator8x8[1785] = 8'hff;
assign _c_characterGenerator8x8[1786] = 8'hff;
assign _c_characterGenerator8x8[1787] = 8'hff;
assign _c_characterGenerator8x8[1788] = 8'h00;
assign _c_characterGenerator8x8[1789] = 8'h00;
assign _c_characterGenerator8x8[1790] = 8'h00;
assign _c_characterGenerator8x8[1791] = 8'h00;
assign _c_characterGenerator8x8[1792] = 8'h00;
assign _c_characterGenerator8x8[1793] = 8'h00;
assign _c_characterGenerator8x8[1794] = 8'h76;
assign _c_characterGenerator8x8[1795] = 8'hdc;
assign _c_characterGenerator8x8[1796] = 8'hc8;
assign _c_characterGenerator8x8[1797] = 8'hdc;
assign _c_characterGenerator8x8[1798] = 8'h76;
assign _c_characterGenerator8x8[1799] = 8'h00;
assign _c_characterGenerator8x8[1800] = 8'h00;
assign _c_characterGenerator8x8[1801] = 8'h78;
assign _c_characterGenerator8x8[1802] = 8'hcc;
assign _c_characterGenerator8x8[1803] = 8'hf8;
assign _c_characterGenerator8x8[1804] = 8'hcc;
assign _c_characterGenerator8x8[1805] = 8'hf8;
assign _c_characterGenerator8x8[1806] = 8'hc0;
assign _c_characterGenerator8x8[1807] = 8'hc0;
assign _c_characterGenerator8x8[1808] = 8'h00;
assign _c_characterGenerator8x8[1809] = 8'hfc;
assign _c_characterGenerator8x8[1810] = 8'hcc;
assign _c_characterGenerator8x8[1811] = 8'hc0;
assign _c_characterGenerator8x8[1812] = 8'hc0;
assign _c_characterGenerator8x8[1813] = 8'hc0;
assign _c_characterGenerator8x8[1814] = 8'hc0;
assign _c_characterGenerator8x8[1815] = 8'h00;
assign _c_characterGenerator8x8[1816] = 8'h00;
assign _c_characterGenerator8x8[1817] = 8'hfe;
assign _c_characterGenerator8x8[1818] = 8'h6c;
assign _c_characterGenerator8x8[1819] = 8'h6c;
assign _c_characterGenerator8x8[1820] = 8'h6c;
assign _c_characterGenerator8x8[1821] = 8'h6c;
assign _c_characterGenerator8x8[1822] = 8'h6c;
assign _c_characterGenerator8x8[1823] = 8'h00;
assign _c_characterGenerator8x8[1824] = 8'hfc;
assign _c_characterGenerator8x8[1825] = 8'hcc;
assign _c_characterGenerator8x8[1826] = 8'h60;
assign _c_characterGenerator8x8[1827] = 8'h30;
assign _c_characterGenerator8x8[1828] = 8'h60;
assign _c_characterGenerator8x8[1829] = 8'hcc;
assign _c_characterGenerator8x8[1830] = 8'hfc;
assign _c_characterGenerator8x8[1831] = 8'h00;
assign _c_characterGenerator8x8[1832] = 8'h00;
assign _c_characterGenerator8x8[1833] = 8'h00;
assign _c_characterGenerator8x8[1834] = 8'h7e;
assign _c_characterGenerator8x8[1835] = 8'hd8;
assign _c_characterGenerator8x8[1836] = 8'hd8;
assign _c_characterGenerator8x8[1837] = 8'hd8;
assign _c_characterGenerator8x8[1838] = 8'h70;
assign _c_characterGenerator8x8[1839] = 8'h00;
assign _c_characterGenerator8x8[1840] = 8'h00;
assign _c_characterGenerator8x8[1841] = 8'h66;
assign _c_characterGenerator8x8[1842] = 8'h66;
assign _c_characterGenerator8x8[1843] = 8'h66;
assign _c_characterGenerator8x8[1844] = 8'h66;
assign _c_characterGenerator8x8[1845] = 8'h7c;
assign _c_characterGenerator8x8[1846] = 8'h60;
assign _c_characterGenerator8x8[1847] = 8'hc0;
assign _c_characterGenerator8x8[1848] = 8'h00;
assign _c_characterGenerator8x8[1849] = 8'h76;
assign _c_characterGenerator8x8[1850] = 8'hdc;
assign _c_characterGenerator8x8[1851] = 8'h18;
assign _c_characterGenerator8x8[1852] = 8'h18;
assign _c_characterGenerator8x8[1853] = 8'h18;
assign _c_characterGenerator8x8[1854] = 8'h18;
assign _c_characterGenerator8x8[1855] = 8'h00;
assign _c_characterGenerator8x8[1856] = 8'hfc;
assign _c_characterGenerator8x8[1857] = 8'h30;
assign _c_characterGenerator8x8[1858] = 8'h78;
assign _c_characterGenerator8x8[1859] = 8'hcc;
assign _c_characterGenerator8x8[1860] = 8'hcc;
assign _c_characterGenerator8x8[1861] = 8'h78;
assign _c_characterGenerator8x8[1862] = 8'h30;
assign _c_characterGenerator8x8[1863] = 8'hfc;
assign _c_characterGenerator8x8[1864] = 8'h38;
assign _c_characterGenerator8x8[1865] = 8'h6c;
assign _c_characterGenerator8x8[1866] = 8'hc6;
assign _c_characterGenerator8x8[1867] = 8'hfe;
assign _c_characterGenerator8x8[1868] = 8'hc6;
assign _c_characterGenerator8x8[1869] = 8'h6c;
assign _c_characterGenerator8x8[1870] = 8'h38;
assign _c_characterGenerator8x8[1871] = 8'h00;
assign _c_characterGenerator8x8[1872] = 8'h38;
assign _c_characterGenerator8x8[1873] = 8'h6c;
assign _c_characterGenerator8x8[1874] = 8'hc6;
assign _c_characterGenerator8x8[1875] = 8'hc6;
assign _c_characterGenerator8x8[1876] = 8'h6c;
assign _c_characterGenerator8x8[1877] = 8'h6c;
assign _c_characterGenerator8x8[1878] = 8'hee;
assign _c_characterGenerator8x8[1879] = 8'h00;
assign _c_characterGenerator8x8[1880] = 8'h1c;
assign _c_characterGenerator8x8[1881] = 8'h30;
assign _c_characterGenerator8x8[1882] = 8'h18;
assign _c_characterGenerator8x8[1883] = 8'h7c;
assign _c_characterGenerator8x8[1884] = 8'hcc;
assign _c_characterGenerator8x8[1885] = 8'hcc;
assign _c_characterGenerator8x8[1886] = 8'h78;
assign _c_characterGenerator8x8[1887] = 8'h00;
assign _c_characterGenerator8x8[1888] = 8'h00;
assign _c_characterGenerator8x8[1889] = 8'h00;
assign _c_characterGenerator8x8[1890] = 8'h7e;
assign _c_characterGenerator8x8[1891] = 8'hdb;
assign _c_characterGenerator8x8[1892] = 8'hdb;
assign _c_characterGenerator8x8[1893] = 8'h7e;
assign _c_characterGenerator8x8[1894] = 8'h00;
assign _c_characterGenerator8x8[1895] = 8'h00;
assign _c_characterGenerator8x8[1896] = 8'h06;
assign _c_characterGenerator8x8[1897] = 8'h0c;
assign _c_characterGenerator8x8[1898] = 8'h7e;
assign _c_characterGenerator8x8[1899] = 8'hdb;
assign _c_characterGenerator8x8[1900] = 8'hdb;
assign _c_characterGenerator8x8[1901] = 8'h7e;
assign _c_characterGenerator8x8[1902] = 8'h60;
assign _c_characterGenerator8x8[1903] = 8'hc0;
assign _c_characterGenerator8x8[1904] = 8'h38;
assign _c_characterGenerator8x8[1905] = 8'h60;
assign _c_characterGenerator8x8[1906] = 8'hc0;
assign _c_characterGenerator8x8[1907] = 8'hf8;
assign _c_characterGenerator8x8[1908] = 8'hc0;
assign _c_characterGenerator8x8[1909] = 8'h60;
assign _c_characterGenerator8x8[1910] = 8'h38;
assign _c_characterGenerator8x8[1911] = 8'h00;
assign _c_characterGenerator8x8[1912] = 8'h78;
assign _c_characterGenerator8x8[1913] = 8'hcc;
assign _c_characterGenerator8x8[1914] = 8'hcc;
assign _c_characterGenerator8x8[1915] = 8'hcc;
assign _c_characterGenerator8x8[1916] = 8'hcc;
assign _c_characterGenerator8x8[1917] = 8'hcc;
assign _c_characterGenerator8x8[1918] = 8'hcc;
assign _c_characterGenerator8x8[1919] = 8'h00;
assign _c_characterGenerator8x8[1920] = 8'h00;
assign _c_characterGenerator8x8[1921] = 8'hfc;
assign _c_characterGenerator8x8[1922] = 8'h00;
assign _c_characterGenerator8x8[1923] = 8'hfc;
assign _c_characterGenerator8x8[1924] = 8'h00;
assign _c_characterGenerator8x8[1925] = 8'hfc;
assign _c_characterGenerator8x8[1926] = 8'h00;
assign _c_characterGenerator8x8[1927] = 8'h00;
assign _c_characterGenerator8x8[1928] = 8'h30;
assign _c_characterGenerator8x8[1929] = 8'h30;
assign _c_characterGenerator8x8[1930] = 8'hfc;
assign _c_characterGenerator8x8[1931] = 8'h30;
assign _c_characterGenerator8x8[1932] = 8'h30;
assign _c_characterGenerator8x8[1933] = 8'h00;
assign _c_characterGenerator8x8[1934] = 8'hfc;
assign _c_characterGenerator8x8[1935] = 8'h00;
assign _c_characterGenerator8x8[1936] = 8'h60;
assign _c_characterGenerator8x8[1937] = 8'h30;
assign _c_characterGenerator8x8[1938] = 8'h18;
assign _c_characterGenerator8x8[1939] = 8'h30;
assign _c_characterGenerator8x8[1940] = 8'h60;
assign _c_characterGenerator8x8[1941] = 8'h00;
assign _c_characterGenerator8x8[1942] = 8'hfc;
assign _c_characterGenerator8x8[1943] = 8'h00;
assign _c_characterGenerator8x8[1944] = 8'h18;
assign _c_characterGenerator8x8[1945] = 8'h30;
assign _c_characterGenerator8x8[1946] = 8'h60;
assign _c_characterGenerator8x8[1947] = 8'h30;
assign _c_characterGenerator8x8[1948] = 8'h18;
assign _c_characterGenerator8x8[1949] = 8'h00;
assign _c_characterGenerator8x8[1950] = 8'hfc;
assign _c_characterGenerator8x8[1951] = 8'h00;
assign _c_characterGenerator8x8[1952] = 8'h0e;
assign _c_characterGenerator8x8[1953] = 8'h1b;
assign _c_characterGenerator8x8[1954] = 8'h1b;
assign _c_characterGenerator8x8[1955] = 8'h18;
assign _c_characterGenerator8x8[1956] = 8'h18;
assign _c_characterGenerator8x8[1957] = 8'h18;
assign _c_characterGenerator8x8[1958] = 8'h18;
assign _c_characterGenerator8x8[1959] = 8'h18;
assign _c_characterGenerator8x8[1960] = 8'h18;
assign _c_characterGenerator8x8[1961] = 8'h18;
assign _c_characterGenerator8x8[1962] = 8'h18;
assign _c_characterGenerator8x8[1963] = 8'h18;
assign _c_characterGenerator8x8[1964] = 8'h18;
assign _c_characterGenerator8x8[1965] = 8'hd8;
assign _c_characterGenerator8x8[1966] = 8'hd8;
assign _c_characterGenerator8x8[1967] = 8'h70;
assign _c_characterGenerator8x8[1968] = 8'h30;
assign _c_characterGenerator8x8[1969] = 8'h30;
assign _c_characterGenerator8x8[1970] = 8'h00;
assign _c_characterGenerator8x8[1971] = 8'hfc;
assign _c_characterGenerator8x8[1972] = 8'h00;
assign _c_characterGenerator8x8[1973] = 8'h30;
assign _c_characterGenerator8x8[1974] = 8'h30;
assign _c_characterGenerator8x8[1975] = 8'h00;
assign _c_characterGenerator8x8[1976] = 8'h00;
assign _c_characterGenerator8x8[1977] = 8'h76;
assign _c_characterGenerator8x8[1978] = 8'hdc;
assign _c_characterGenerator8x8[1979] = 8'h00;
assign _c_characterGenerator8x8[1980] = 8'h76;
assign _c_characterGenerator8x8[1981] = 8'hdc;
assign _c_characterGenerator8x8[1982] = 8'h00;
assign _c_characterGenerator8x8[1983] = 8'h00;
assign _c_characterGenerator8x8[1984] = 8'h38;
assign _c_characterGenerator8x8[1985] = 8'h6c;
assign _c_characterGenerator8x8[1986] = 8'h6c;
assign _c_characterGenerator8x8[1987] = 8'h38;
assign _c_characterGenerator8x8[1988] = 8'h00;
assign _c_characterGenerator8x8[1989] = 8'h00;
assign _c_characterGenerator8x8[1990] = 8'h00;
assign _c_characterGenerator8x8[1991] = 8'h00;
assign _c_characterGenerator8x8[1992] = 8'h00;
assign _c_characterGenerator8x8[1993] = 8'h00;
assign _c_characterGenerator8x8[1994] = 8'h00;
assign _c_characterGenerator8x8[1995] = 8'h18;
assign _c_characterGenerator8x8[1996] = 8'h18;
assign _c_characterGenerator8x8[1997] = 8'h00;
assign _c_characterGenerator8x8[1998] = 8'h00;
assign _c_characterGenerator8x8[1999] = 8'h00;
assign _c_characterGenerator8x8[2000] = 8'h00;
assign _c_characterGenerator8x8[2001] = 8'h00;
assign _c_characterGenerator8x8[2002] = 8'h00;
assign _c_characterGenerator8x8[2003] = 8'h00;
assign _c_characterGenerator8x8[2004] = 8'h18;
assign _c_characterGenerator8x8[2005] = 8'h00;
assign _c_characterGenerator8x8[2006] = 8'h00;
assign _c_characterGenerator8x8[2007] = 8'h00;
assign _c_characterGenerator8x8[2008] = 8'h0f;
assign _c_characterGenerator8x8[2009] = 8'h0c;
assign _c_characterGenerator8x8[2010] = 8'h0c;
assign _c_characterGenerator8x8[2011] = 8'h0c;
assign _c_characterGenerator8x8[2012] = 8'hec;
assign _c_characterGenerator8x8[2013] = 8'h6c;
assign _c_characterGenerator8x8[2014] = 8'h3c;
assign _c_characterGenerator8x8[2015] = 8'h1c;
assign _c_characterGenerator8x8[2016] = 8'h78;
assign _c_characterGenerator8x8[2017] = 8'h6c;
assign _c_characterGenerator8x8[2018] = 8'h6c;
assign _c_characterGenerator8x8[2019] = 8'h6c;
assign _c_characterGenerator8x8[2020] = 8'h6c;
assign _c_characterGenerator8x8[2021] = 8'h00;
assign _c_characterGenerator8x8[2022] = 8'h00;
assign _c_characterGenerator8x8[2023] = 8'h00;
assign _c_characterGenerator8x8[2024] = 8'h70;
assign _c_characterGenerator8x8[2025] = 8'h18;
assign _c_characterGenerator8x8[2026] = 8'h30;
assign _c_characterGenerator8x8[2027] = 8'h60;
assign _c_characterGenerator8x8[2028] = 8'h78;
assign _c_characterGenerator8x8[2029] = 8'h00;
assign _c_characterGenerator8x8[2030] = 8'h00;
assign _c_characterGenerator8x8[2031] = 8'h00;
assign _c_characterGenerator8x8[2032] = 8'h00;
assign _c_characterGenerator8x8[2033] = 8'h00;
assign _c_characterGenerator8x8[2034] = 8'h3c;
assign _c_characterGenerator8x8[2035] = 8'h3c;
assign _c_characterGenerator8x8[2036] = 8'h3c;
assign _c_characterGenerator8x8[2037] = 8'h3c;
assign _c_characterGenerator8x8[2038] = 8'h00;
assign _c_characterGenerator8x8[2039] = 8'h00;
assign _c_characterGenerator8x8[2040] = 8'h00;
assign _c_characterGenerator8x8[2041] = 8'h00;
assign _c_characterGenerator8x8[2042] = 8'h00;
assign _c_characterGenerator8x8[2043] = 8'h00;
assign _c_characterGenerator8x8[2044] = 8'h00;
assign _c_characterGenerator8x8[2045] = 8'h00;
assign _c_characterGenerator8x8[2046] = 8'h00;
assign _c_characterGenerator8x8[2047] = 8'h00;
wire  [7:0] _c_terminal_wdata0;
assign _c_terminal_wdata0 = 0;
wire  [2:0] _c_terminal_y;
assign _c_terminal_y = 7;
wire  [6:0] _w_xterminalpos;
wire  [9:0] _w_yterminalpos;
wire  [0:0] _w_is_cursor;
wire  [2:0] _w_xinterminal;
wire  [2:0] _w_yinterminal;
wire  [0:0] _w_terminalpixel;

reg  [0:0] _d_terminal_wenable0;
reg  [0:0] _q_terminal_wenable0;
reg  [9:0] _d_terminal_addr0;
reg  [9:0] _q_terminal_addr0;
reg  [0:0] _d_terminal_wenable1;
reg  [0:0] _q_terminal_wenable1;
reg  [7:0] _d_terminal_wdata1;
reg  [7:0] _q_terminal_wdata1;
reg  [9:0] _d_terminal_addr1;
reg  [9:0] _q_terminal_addr1;
reg  [6:0] _d_terminal_x;
reg  [6:0] _q_terminal_x;
reg  [9:0] _d_terminal_scroll;
reg  [9:0] _q_terminal_scroll;
reg  [9:0] _d_terminal_scroll_next;
reg  [9:0] _q_terminal_scroll_next;
reg  [5:0] _d_pix_red,_q_pix_red;
reg  [5:0] _d_pix_green,_q_pix_green;
reg  [5:0] _d_pix_blue,_q_pix_blue;
reg  [0:0] _d_terminal_display,_q_terminal_display;
reg  [2:0] _d_terminal_active,_q_terminal_active;
reg  [1:0] _d_index,_q_index;
assign out_pix_red = _d_pix_red;
assign out_pix_green = _d_pix_green;
assign out_pix_blue = _d_pix_blue;
assign out_terminal_display = _d_terminal_display;
assign out_terminal_active = _q_terminal_active;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_terminal_wenable0 <= 0;
_q_terminal_addr0 <= 0;
_q_terminal_wenable1 <= 0;
_q_terminal_wdata1 <= 0;
_q_terminal_addr1 <= 0;
_q_terminal_x <= 0;
_q_terminal_scroll <= 0;
_q_terminal_scroll_next <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_terminal_wenable0 <= _d_terminal_wenable0;
_q_terminal_addr0 <= _d_terminal_addr0;
_q_terminal_wenable1 <= _d_terminal_wenable1;
_q_terminal_wdata1 <= _d_terminal_wdata1;
_q_terminal_addr1 <= _d_terminal_addr1;
_q_terminal_x <= _d_terminal_x;
_q_terminal_scroll <= _d_terminal_scroll;
_q_terminal_scroll_next <= _d_terminal_scroll_next;
_q_pix_red <= _d_pix_red;
_q_pix_green <= _d_pix_green;
_q_pix_blue <= _d_pix_blue;
_q_terminal_display <= _d_terminal_display;
_q_terminal_active <= _d_terminal_active;
_q_index <= _d_index;
  end
end


M_terminal_mem_terminal __mem__terminal(
.clock0(clock),
.clock1(clock),
.in_terminal_wenable0(_d_terminal_wenable0),
.in_terminal_wdata0(_c_terminal_wdata0),
.in_terminal_addr0(_d_terminal_addr0),
.in_terminal_wenable1(_d_terminal_wenable1),
.in_terminal_wdata1(_d_terminal_wdata1),
.in_terminal_addr1(_d_terminal_addr1),
.out_terminal_rdata0(_w_mem_terminal_rdata0),
.out_terminal_rdata1(_w_mem_terminal_rdata1)
);

assign _w_terminalpixel = ((_c_characterGenerator8x8[_w_mem_terminal_rdata0*8+_w_yinterminal]<<_w_xinterminal)>>7)&1;
assign _w_yinterminal = (in_pix_y)&7;
assign _w_xinterminal = (in_pix_x)&7;
assign _w_is_cursor = (_w_xterminalpos==_d_terminal_x)&(((in_pix_y-416)>>3)==_c_terminal_y);
assign _w_yterminalpos = ((in_pix_vblank?0:in_pix_y-416)>>3)*80;
assign _w_xterminalpos = (in_pix_active?in_pix_x+1:0)>>3;

always @* begin
_d_terminal_wenable0 = _q_terminal_wenable0;
_d_terminal_addr0 = _q_terminal_addr0;
_d_terminal_wenable1 = _q_terminal_wenable1;
_d_terminal_wdata1 = _q_terminal_wdata1;
_d_terminal_addr1 = _q_terminal_addr1;
_d_terminal_x = _q_terminal_x;
_d_terminal_scroll = _q_terminal_scroll;
_d_terminal_scroll_next = _q_terminal_scroll_next;
_d_pix_red = _q_pix_red;
_d_pix_green = _q_pix_green;
_d_pix_blue = _q_pix_blue;
_d_terminal_display = _q_terminal_display;
_d_terminal_active = _q_terminal_active;
_d_index = _q_index;
// _always_pre
_d_terminal_addr0 = _w_xterminalpos+_w_yterminalpos;
_d_terminal_wenable0 = 0;
_d_terminal_wenable1 = 0;
_d_terminal_display = 0;
  case (_q_terminal_active)
  0: begin
// __block_2_case
// __block_3
  case (in_terminal_write)
  1: begin
// __block_5_case
// __block_6
  case (in_terminal_character)
  8: begin
// __block_8_case
// __block_9
if (_q_terminal_x>0) begin
// __block_10
// __block_12
_d_terminal_x = _q_terminal_x-1;
_d_terminal_addr1 = _d_terminal_x-1+_c_terminal_y*80;
_d_terminal_wdata1 = 0;
_d_terminal_wenable1 = 1;
// __block_13
end else begin
// __block_11
end
// __block_14
// __block_15
  end
  10: begin
// __block_16_case
// __block_17
_d_terminal_scroll = 0;
_d_terminal_active = 1;
// __block_18
  end
  13: begin
// __block_19_case
// __block_20
_d_terminal_x = 0;
// __block_21
  end
  default: begin
// __block_22_case
// __block_23
_d_terminal_addr1 = _q_terminal_x+_c_terminal_y*80;
_d_terminal_wdata1 = in_terminal_character;
_d_terminal_wenable1 = 1;
if (_q_terminal_x==79) begin
// __block_24
// __block_26
_d_terminal_x = 0;
_d_terminal_scroll = 0;
_d_terminal_active = 1;
// __block_27
end else begin
// __block_25
// __block_28
_d_terminal_x = _q_terminal_x+1;
// __block_29
end
// __block_30
// __block_31
  end
endcase
// __block_7
// __block_32
  end
  default: begin
// __block_33_case
// __block_34
// __block_35
  end
endcase
// __block_4
// __block_36
  end
  1: begin
// __block_37_case
// __block_38
if (_q_terminal_scroll==560) begin
// __block_39
// __block_41
_d_terminal_active = 4;
// __block_42
end else begin
// __block_40
// __block_43
_d_terminal_addr1 = _q_terminal_scroll+80;
_d_terminal_active = 2;
// __block_44
end
// __block_45
// __block_46
  end
  2: begin
// __block_47_case
// __block_48
_d_terminal_scroll_next = _w_mem_terminal_rdata1;
_d_terminal_active = 3;
// __block_49
  end
  3: begin
// __block_50_case
// __block_51
_d_terminal_addr1 = _q_terminal_scroll;
_d_terminal_wdata1 = _q_terminal_scroll_next;
_d_terminal_wenable1 = 1;
_d_terminal_scroll = _q_terminal_scroll+1;
_d_terminal_active = 1;
// __block_52
  end
  4: begin
// __block_53_case
// __block_54
_d_terminal_addr1 = _q_terminal_scroll;
_d_terminal_wdata1 = 0;
_d_terminal_wenable1 = 1;
if (_q_terminal_scroll==640) begin
// __block_55
// __block_57
_d_terminal_active = 0;
// __block_58
end else begin
// __block_56
// __block_59
_d_terminal_scroll = _q_terminal_scroll+1;
// __block_60
end
// __block_61
// __block_62
  end
  default: begin
// __block_63_case
// __block_64
_d_terminal_active = 0;
// __block_65
  end
endcase
// __block_1
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
_d_terminal_wenable0 = 0;
_d_terminal_addr0 = 0;
_d_terminal_wenable1 = 0;
_d_terminal_wdata1 = 0;
_d_terminal_addr1 = 0;
_d_terminal_x = 0;
_d_terminal_scroll = 0;
_d_terminal_scroll_next = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_66
if (1) begin
// __block_67
// __block_69
if (in_pix_active&in_showterminal&(in_pix_y>415)) begin
// __block_70
// __block_72
  case (_w_terminalpixel)
  0: begin
// __block_74_case
// __block_75
if (_w_is_cursor&in_timer1hz) begin
// __block_76
// __block_78
_d_pix_red = 6==6?63:255;
_d_pix_green = 6==6?63:255;
_d_pix_blue = 6==6?63:255;
// __block_79
end else begin
// __block_77
// __block_80
_d_pix_red = 0;
_d_pix_green = 0;
_d_pix_blue = 6==6?63:255;
// __block_81
end
// __block_82
// __block_83
  end
  1: begin
// __block_84_case
// __block_85
if (_w_is_cursor&in_timer1hz) begin
// __block_86
// __block_88
_d_pix_red = 0;
_d_pix_green = 0;
_d_pix_blue = 6==6?63:255;
// __block_89
end else begin
// __block_87
// __block_90
_d_pix_red = 6==6?63:255;
_d_pix_green = 6==6?63:255;
_d_pix_blue = 6==6?63:255;
// __block_91
end
// __block_92
// __block_93
  end
endcase
// __block_73
_d_terminal_display = 1;
// __block_94
end else begin
// __block_71
// __block_95
_d_terminal_display = 0;
// __block_96
end
// __block_97
// __block_98
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_68
_d_index = 3;
end
3: begin // end of terminal
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_multiplex_display (
in_pix_x,
in_pix_y,
in_pix_active,
in_pix_vblank,
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
input  [5:0] in_terminal_r;
input  [5:0] in_terminal_g;
input  [5:0] in_terminal_b;
input  [0:0] in_terminal_display;
output  [5:0] out_pix_red;
output  [5:0] out_pix_green;
output  [5:0] out_pix_blue;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [5:0] _d_pix_red,_q_pix_red;
reg  [5:0] _d_pix_green,_q_pix_green;
reg  [5:0] _d_pix_blue,_q_pix_blue;
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
if (in_terminal_display) begin
// __block_8
// __block_10
_d_pix_red = in_terminal_r;
_d_pix_green = in_terminal_g;
_d_pix_blue = in_terminal_b;
// __block_11
end else begin
// __block_9
end
// __block_12
// __block_13
end else begin
// __block_6
end
// __block_14
// __block_15
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
out_counter1hz,
in_run,
out_done,
reset,
out_clock,
clock
);
output  [15:0] out_counter1hz;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [31:0] _d_counter50mhz;
reg  [31:0] _q_counter50mhz;
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
if (_q_counter50mhz==50000000) begin
// __block_5
// __block_7
_d_counter1hz = _q_counter1hz+1;
_d_counter50mhz = 0;
// __block_8
end else begin
// __block_6
// __block_9
_d_counter50mhz = _q_counter50mhz+1;
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


module M_main_mem_ps2InBuffer(
input      [0:0]             in_ps2InBuffer_wenable0,
input       [7:0]     in_ps2InBuffer_wdata0,
input      [3:0]                in_ps2InBuffer_addr0,
input      [0:0]             in_ps2InBuffer_wenable1,
input      [7:0]                 in_ps2InBuffer_wdata1,
input      [3:0]                in_ps2InBuffer_addr1,
output reg  [7:0]     out_ps2InBuffer_rdata0,
output reg  [7:0]     out_ps2InBuffer_rdata1,
input      clock0,
input      clock1
);
reg  [7:0] buffer[15:0];
always @(posedge clock0) begin
  if (in_ps2InBuffer_wenable0) begin
    buffer[in_ps2InBuffer_addr0] <= in_ps2InBuffer_wdata0;
  end else begin
    out_ps2InBuffer_rdata0 <= buffer[in_ps2InBuffer_addr0];
  end
end
always @(posedge clock1) begin
  if (in_ps2InBuffer_wenable1) begin
    buffer[in_ps2InBuffer_addr1] <= in_ps2InBuffer_wdata1;
  end else begin
    out_ps2InBuffer_rdata1 <= buffer[in_ps2InBuffer_addr1];
  end
end

endmodule

module M_main (
in_btns,
in_uart_rx,
in_gp,
in_gn,
out_leds,
out_gpdi_dp,
out_gpdi_dn,
out_uart_tx,
out_video_r,
out_video_g,
out_video_b,
out_video_hs,
out_video_vs,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [7:0] in_btns;
input  [0:0] in_uart_rx;
input  [26:0] in_gp;
input  [26:0] in_gn;
output  [7:0] out_leds;
output  [3:0] out_gpdi_dp;
output  [3:0] out_gpdi_dn;
output  [0:0] out_uart_tx;
output  [5:0] out_video_r;
output  [5:0] out_video_g;
output  [5:0] out_video_b;
output  [0:0] out_video_hs;
output  [0:0] out_video_vs;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = _w_clk_gen_clkout0;
wire _w_vga_rstcond_out;
wire _w_clk_gen_clkout0;
wire _w_clk_gen_clkout1;
wire _w_clk_gen_locked;
wire[7:0] _w_keyboard_ps2_code;
wire _w_keyboard_strobe;
wire  [15:0] _w_p1hz_counter1hz;
wire _w_p1hz_done;
wire  [9:0] _w_video_x;
wire  [9:0] _w_video_y;
wire  [0:0] _w_video_active;
wire  [0:0] _w_video_vblank;
wire  [3:0] _w_video_gpdi_dp;
wire  [3:0] _w_video_gpdi_dn;
wire  [5:0] _w_terminal_window_pix_red;
wire  [5:0] _w_terminal_window_pix_green;
wire  [5:0] _w_terminal_window_pix_blue;
wire  [0:0] _w_terminal_window_terminal_display;
wire  [2:0] _w_terminal_window_terminal_active;
wire _w_terminal_window_done;
wire  [5:0] _w_display_pix_red;
wire  [5:0] _w_display_pix_green;
wire  [5:0] _w_display_pix_blue;
wire _w_display_done;
wire  [7:0] _w_mem_ps2InBuffer_rdata0;
wire  [7:0] _w_mem_ps2InBuffer_rdata1;
wire  [7:0] _c_ps2InBuffer_wdata0;
assign _c_ps2InBuffer_wdata0 = 0;
wire  [3:0] _c_ps2InBufferNext;
assign _c_ps2InBufferNext = 0;
wire  [0:0] _w_ps2_clock;
wire  [0:0] _w_ps2_data;
wire  [7:0] _w_video_r8;
wire  [7:0] _w_video_g8;
wire  [7:0] _w_video_b8;

reg  [2:0] _d_CYCLE;
reg  [2:0] _q_CYCLE;
reg  [0:0] _d_ps2InBuffer_wenable0;
reg  [0:0] _q_ps2InBuffer_wenable0;
reg  [3:0] _d_ps2InBuffer_addr0;
reg  [3:0] _q_ps2InBuffer_addr0;
reg  [0:0] _d_ps2InBuffer_wenable1;
reg  [0:0] _q_ps2InBuffer_wenable1;
reg  [7:0] _d_ps2InBuffer_wdata1;
reg  [7:0] _q_ps2InBuffer_wdata1;
reg  [3:0] _d_ps2InBuffer_addr1;
reg  [3:0] _q_ps2InBuffer_addr1;
reg  [3:0] _d_ps2InBufferTop;
reg  [3:0] _q_ps2InBufferTop;
reg  [7:0] _d_leds,_q_leds;
reg  [0:0] _d_uart_tx,_q_uart_tx;
reg  [0:0] _d_video_hs,_q_video_hs;
reg  [0:0] _d_video_vs,_q_video_vs;
reg  [7:0] _d_terminal_window_terminal_character,_q_terminal_window_terminal_character;
reg  [0:0] _d_terminal_window_terminal_write,_q_terminal_window_terminal_write;
reg  [0:0] _d_terminal_window_showterminal,_q_terminal_window_showterminal;
reg  [0:0] _d_terminal_window_showcursor,_q_terminal_window_showcursor;
reg  [1:0] _d_index,_q_index;
reg  _p1hz_run;
reg  _terminal_window_run;
reg  _display_run;
assign out_leds = _q_leds;
assign out_gpdi_dp = _w_video_gpdi_dp;
assign out_gpdi_dn = _w_video_gpdi_dn;
assign out_uart_tx = _d_uart_tx;
assign out_video_r = _w_display_pix_red;
assign out_video_g = _w_display_pix_green;
assign out_video_b = _w_display_pix_blue;
assign out_video_hs = _d_video_hs;
assign out_video_vs = _d_video_vs;
assign out_done = (_q_index == 3);

always @(posedge _w_clk_gen_clkout0) begin
  if (reset || !in_run) begin
_q_CYCLE <= 0;
_q_ps2InBuffer_wenable0 <= 0;
_q_ps2InBuffer_addr0 <= 0;
_q_ps2InBuffer_wenable1 <= 0;
_q_ps2InBuffer_wdata1 <= 0;
_q_ps2InBuffer_addr1 <= 0;
_q_ps2InBufferTop <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_CYCLE <= _d_CYCLE;
_q_ps2InBuffer_wenable0 <= _d_ps2InBuffer_wenable0;
_q_ps2InBuffer_addr0 <= _d_ps2InBuffer_addr0;
_q_ps2InBuffer_wenable1 <= _d_ps2InBuffer_wenable1;
_q_ps2InBuffer_wdata1 <= _d_ps2InBuffer_wdata1;
_q_ps2InBuffer_addr1 <= _d_ps2InBuffer_addr1;
_q_ps2InBufferTop <= _d_ps2InBufferTop;
_q_leds <= _d_leds;
_q_uart_tx <= _d_uart_tx;
_q_video_hs <= _d_video_hs;
_q_video_vs <= _d_video_vs;
_q_index <= _d_index;
  end
_q_terminal_window_terminal_character <= _d_terminal_window_terminal_character;
_q_terminal_window_terminal_write <= _d_terminal_window_terminal_write;
_q_terminal_window_showterminal <= _d_terminal_window_showterminal;
_q_terminal_window_showcursor <= _d_terminal_window_showcursor;
end


reset_conditioner _vga_rstcond (
.rcclk(_w_clk_gen_clkout1),
.in(reset),
.out(_w_vga_rstcond_out)
);

ulx3s_clk_50_25 _clk_gen (
.clkin(clock),
.clkout0(_w_clk_gen_clkout0),
.clkout1(_w_clk_gen_clkout1),
.locked(_w_clk_gen_locked)
);

ps2kbd _keyboard (
.clk(clock),
.ps2_clk(_w_ps2_clock),
.ps2_data(_w_ps2_data),
.ps2_code(_w_keyboard_ps2_code),
.strobe(_w_keyboard_strobe)
);
M_pulse1hz p1hz (
.out_counter1hz(_w_p1hz_counter1hz),
.out_done(_w_p1hz_done),
.in_run(_p1hz_run),
.reset(reset),
.clock(_w_clk_gen_clkout0)
);
M_hdmi video (
.in_red(_w_video_r8),
.in_green(_w_video_g8),
.in_blue(_w_video_b8),
.out_x(_w_video_x),
.out_y(_w_video_y),
.out_active(_w_video_active),
.out_vblank(_w_video_vblank),
.out_gpdi_dp(_w_video_gpdi_dp),
.out_gpdi_dn(_w_video_gpdi_dn),
.reset(reset),
.clock(clock)
);
M_terminal terminal_window (
.in_pix_x(_w_video_x),
.in_pix_y(_w_video_y),
.in_pix_active(_w_video_active),
.in_pix_vblank(_w_video_vblank),
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
.reset(_w_vga_rstcond_out),
.clock(_w_clk_gen_clkout1)
);
M_multiplex_display display (
.in_pix_x(_w_video_x),
.in_pix_y(_w_video_y),
.in_pix_active(_w_video_active),
.in_pix_vblank(_w_video_vblank),
.in_terminal_r(_w_terminal_window_pix_red),
.in_terminal_g(_w_terminal_window_pix_green),
.in_terminal_b(_w_terminal_window_pix_blue),
.in_terminal_display(_w_terminal_window_terminal_display),
.out_pix_red(_w_display_pix_red),
.out_pix_green(_w_display_pix_green),
.out_pix_blue(_w_display_pix_blue),
.out_done(_w_display_done),
.in_run(_display_run),
.reset(_w_vga_rstcond_out),
.clock(_w_clk_gen_clkout1)
);

M_main_mem_ps2InBuffer __mem__ps2InBuffer(
.clock0(_w_clk_gen_clkout0),
.clock1(_w_clk_gen_clkout0),
.in_ps2InBuffer_wenable0(_d_ps2InBuffer_wenable0),
.in_ps2InBuffer_wdata0(_c_ps2InBuffer_wdata0),
.in_ps2InBuffer_addr0(_d_ps2InBuffer_addr0),
.in_ps2InBuffer_wenable1(_d_ps2InBuffer_wenable1),
.in_ps2InBuffer_wdata1(_d_ps2InBuffer_wdata1),
.in_ps2InBuffer_addr1(_d_ps2InBuffer_addr1),
.out_ps2InBuffer_rdata0(_w_mem_ps2InBuffer_rdata0),
.out_ps2InBuffer_rdata1(_w_mem_ps2InBuffer_rdata1)
);

assign _w_video_b8 = _w_display_pix_blue<<2;
assign _w_video_g8 = _w_display_pix_green<<2;
assign _w_video_r8 = _w_display_pix_red<<2;
assign _w_ps2_data = in_gp[3+:1];
assign _w_ps2_clock = in_gp[1+:1];

always @* begin
_d_CYCLE = _q_CYCLE;
_d_ps2InBuffer_wenable0 = _q_ps2InBuffer_wenable0;
_d_ps2InBuffer_addr0 = _q_ps2InBuffer_addr0;
_d_ps2InBuffer_wenable1 = _q_ps2InBuffer_wenable1;
_d_ps2InBuffer_wdata1 = _q_ps2InBuffer_wdata1;
_d_ps2InBuffer_addr1 = _q_ps2InBuffer_addr1;
_d_ps2InBufferTop = _q_ps2InBufferTop;
_d_leds = _q_leds;
_d_uart_tx = _q_uart_tx;
_d_video_hs = _q_video_hs;
_d_video_vs = _q_video_vs;
_d_terminal_window_terminal_character = _q_terminal_window_terminal_character;
_d_terminal_window_terminal_write = _q_terminal_window_terminal_write;
_d_terminal_window_showterminal = _q_terminal_window_showterminal;
_d_terminal_window_showcursor = _q_terminal_window_showcursor;
_d_index = _q_index;
_p1hz_run = 1;
_terminal_window_run = 1;
_display_run = 1;
// _always_pre
_d_ps2InBuffer_wenable0 = 0;
_d_ps2InBuffer_wenable1 = 1;
_d_ps2InBuffer_addr0 = _c_ps2InBufferNext;
_d_ps2InBuffer_addr1 = _q_ps2InBufferTop;
if (_w_keyboard_strobe) begin
// __block_1
// __block_3
_d_ps2InBuffer_wdata1 = _w_keyboard_ps2_code;
_d_ps2InBufferTop = _q_ps2InBufferTop+1;
// __block_4
end else begin
// __block_2
end
// __block_5
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
_d_CYCLE = 0;
_d_ps2InBuffer_wenable0 = 0;
_d_ps2InBuffer_addr0 = 0;
_d_ps2InBuffer_wenable1 = 0;
_d_ps2InBuffer_wdata1 = 0;
_d_ps2InBuffer_addr1 = 0;
_d_ps2InBufferTop = 0;
// --
_d_terminal_window_showterminal = 1;
_d_terminal_window_showcursor = 1;
_d_index = 1;
end
1: begin
// __while__block_6
if (1) begin
// __block_7
// __block_9
  case (_q_CYCLE)
  0: begin
// __block_11_case
// __block_12
if (~(_c_ps2InBufferNext==_d_ps2InBufferTop)) begin
// __block_13
// __block_15
_d_terminal_window_terminal_character = _w_mem_ps2InBuffer_rdata0;
_d_terminal_window_terminal_write = 1;
// __block_16
end else begin
// __block_14
end
// __block_17
// __block_18
  end
  2: begin
// __block_19_case
// __block_20
_d_terminal_window_terminal_write = 0;
// __block_21
  end
  default: begin
// __block_22_case
// __block_23
// __block_24
  end
endcase
// __block_10
_d_CYCLE = (_q_CYCLE==2)?0:_q_CYCLE+1;
// __block_25
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_8
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

