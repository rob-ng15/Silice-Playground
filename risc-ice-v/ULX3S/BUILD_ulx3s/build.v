`define HDMI 1
`define UART 1
`define BUTTONS 1
`define AUDIO 1
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


module M_uart_sender #(
parameter IO_DATA_IN_WIDTH=1,parameter IO_DATA_IN_INIT=0,
parameter IO_DATA_IN_READY_WIDTH=1,parameter IO_DATA_IN_READY_INIT=0,
parameter IO_BUSY_WIDTH=1,parameter IO_BUSY_INIT=0
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
parameter IO_DATA_OUT_WIDTH=1,parameter IO_DATA_OUT_INIT=0,
parameter IO_DATA_OUT_READY_WIDTH=1,parameter IO_DATA_OUT_READY_INIT=0
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
in_run,
out_done,
reset,
out_clock,
clock
);
input  [0:0] in_resetRandom;
output  [15:0] out_g_noise_out;
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
reg  [1:0] _d_index,_q_index;
assign out_g_noise_out = _q_g_noise_out;
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
_q_index <= _d_index;
  end
end




always @* begin
_d_rand_out = _q_rand_out;
_d_rand_ff = _q_rand_ff;
_d_rand_en_ff = _q_rand_en_ff;
_d_temp_g_noise_nxt = _q_temp_g_noise_nxt;
_d_g_noise_out = _q_g_noise_out;
_d_index = _q_index;
_t_temp_u_noise3 = 0;
_t_temp_u_noise2 = 0;
_t_temp_u_noise1 = 0;
_t_temp_u_noise0 = 0;
// _always_pre
_d_rand_en_ff = {(_q_rand_en_ff[7+:1]^_q_rand_en_ff[0+:1]),_q_rand_en_ff[1+:17]};
_d_rand_ff = {(_q_rand_ff[5+:1]^_q_rand_ff[3+:1]^_q_rand_ff[2+:1]^_q_rand_ff[0+:1]),_q_rand_ff[1+:15]};
_d_g_noise_out = (_d_rand_en_ff[17+:1])?_q_temp_g_noise_nxt:(_d_rand_en_ff[10+:1])?_q_rand_out:_q_g_noise_out;
_d_index = 3;
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
// __block_8
end else begin
// __block_6
// __block_9
_d_rand_out = _d_rand_ff;
_t_temp_u_noise3 = {_d_rand_out[15+:1],_d_rand_out[15+:1],_d_rand_out[2+:13]};
_t_temp_u_noise2 = _t_temp_u_noise3;
_t_temp_u_noise1 = _t_temp_u_noise2;
_t_temp_u_noise0 = _t_temp_u_noise1;
_d_temp_g_noise_nxt = (_d_rand_en_ff[9+:1])?_t_temp_u_noise3+_t_temp_u_noise2+_t_temp_u_noise1+_t_temp_u_noise0+_d_g_noise_out:_t_temp_u_noise3+_t_temp_u_noise2+_t_temp_u_noise1+_t_temp_u_noise0;
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
output  [1:0] out_pix_red;
output  [1:0] out_pix_green;
output  [1:0] out_pix_blue;
output  [0:0] out_terminal_display;
output  [2:0] out_terminal_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [7:0] _w_mem_characterGenerator8x8_rdata;
wire  [7:0] _w_mem_terminal_rdata0;
wire  [7:0] _w_mem_terminal_rdata1;
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

reg  [10:0] _d_characterGenerator8x8_addr;
reg  [10:0] _q_characterGenerator8x8_addr;
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
reg  [1:0] _d_pix_red,_q_pix_red;
reg  [1:0] _d_pix_green,_q_pix_green;
reg  [1:0] _d_pix_blue,_q_pix_blue;
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
_q_characterGenerator8x8_addr <= 0;
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
_q_characterGenerator8x8_addr <= _d_characterGenerator8x8_addr;
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


M_terminal_mem_characterGenerator8x8 __mem__characterGenerator8x8(
.clock(clock),
.in_characterGenerator8x8_addr(_d_characterGenerator8x8_addr),
.out_characterGenerator8x8_rdata(_w_mem_characterGenerator8x8_rdata)
);
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

assign _w_terminalpixel = _w_mem_characterGenerator8x8_rdata[7-_w_xinterminal+:1];
assign _w_yinterminal = (in_pix_y)&7;
assign _w_xinterminal = (in_pix_x)&7;
assign _w_is_cursor = (_w_xterminalpos==_d_terminal_x)&&(((in_pix_y-416)>>3)==_c_terminal_y);
assign _w_yterminalpos = ((in_pix_vblank?0:in_pix_y-416)>>3)*80;
assign _w_xterminalpos = (in_pix_active?(in_pix_x<640)?in_pix_x+2:0:0)>>3;

always @* begin
_d_characterGenerator8x8_addr = _q_characterGenerator8x8_addr;
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
_d_characterGenerator8x8_addr = _w_mem_terminal_rdata0*8+_w_yinterminal;
_d_terminal_display = in_pix_active&&in_showterminal&&(in_pix_y>415);
_d_pix_blue = 3;
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
if (_q_terminal_x!=0) begin
// __block_10
// __block_12
_d_terminal_x = _q_terminal_x-1;
_d_terminal_addr1 = _d_terminal_x+_c_terminal_y*80;
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
_d_terminal_active = (_q_terminal_x==79)?1:0;
_d_terminal_x = (_q_terminal_x==79)?0:_q_terminal_x+1;
// __block_24
  end
endcase
// __block_7
// __block_25
  end
  default: begin
// __block_26_case
// __block_27
// __block_28
  end
endcase
// __block_4
// __block_29
  end
  1: begin
// __block_30_case
// __block_31
_d_terminal_active = (_q_terminal_scroll==560)?4:2;
_d_terminal_addr1 = _q_terminal_scroll+80;
// __block_32
  end
  2: begin
// __block_33_case
// __block_34
_d_terminal_scroll_next = _w_mem_terminal_rdata1;
_d_terminal_active = 3;
// __block_35
  end
  3: begin
// __block_36_case
// __block_37
_d_terminal_addr1 = _q_terminal_scroll;
_d_terminal_wdata1 = _q_terminal_scroll_next;
_d_terminal_wenable1 = 1;
_d_terminal_scroll = _q_terminal_scroll+1;
_d_terminal_active = 1;
// __block_38
  end
  4: begin
// __block_39_case
// __block_40
_d_terminal_addr1 = _q_terminal_scroll;
_d_terminal_wdata1 = 0;
_d_terminal_wenable1 = 1;
_d_terminal_active = (_q_terminal_scroll==640)?0:4;
_d_terminal_scroll = _q_terminal_scroll+1;
// __block_41
  end
  default: begin
// __block_42_case
// __block_43
_d_terminal_scroll = 0;
_d_terminal_active = 0;
// __block_44
  end
endcase
// __block_1
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
_d_characterGenerator8x8_addr = 0;
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
// __while__block_45
if (1) begin
// __block_46
// __block_48
if (_d_terminal_display) begin
// __block_49
// __block_51
  case (_w_terminalpixel)
  0: begin
// __block_53_case
// __block_54
_d_pix_red = (_w_is_cursor&&in_timer1hz)?3:0;
_d_pix_green = (_w_is_cursor&&in_timer1hz)?3:0;
// __block_55
  end
  1: begin
// __block_56_case
// __block_57
_d_pix_red = (_w_is_cursor&&in_timer1hz)?0:3;
_d_pix_green = (_w_is_cursor&&in_timer1hz)?0:3;
// __block_58
  end
endcase
// __block_52
// __block_59
end else begin
// __block_50
end
// __block_60
// __block_61
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_47
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

module M_character_map_mem_character(
input      [0:0]             in_character_wenable0,
input       [7:0]     in_character_wdata0,
input      [11:0]                in_character_addr0,
input      [0:0]             in_character_wenable1,
input      [7:0]                 in_character_wdata1,
input      [11:0]                in_character_addr1,
output reg  [7:0]     out_character_rdata0,
output reg  [7:0]     out_character_rdata1,
input      clock0,
input      clock1
);
reg  [7:0] buffer[2399:0];
always @(posedge clock0) begin
  if (in_character_wenable0) begin
    buffer[in_character_addr0] <= in_character_wdata0;
  end else begin
    out_character_rdata0 <= buffer[in_character_addr0];
  end
end
always @(posedge clock1) begin
  if (in_character_wenable1) begin
    buffer[in_character_addr1] <= in_character_wdata1;
  end else begin
    out_character_rdata1 <= buffer[in_character_addr1];
  end
end

endmodule

module M_character_map_mem_foreground(
input      [0:0]             in_foreground_wenable0,
input       [5:0]     in_foreground_wdata0,
input      [11:0]                in_foreground_addr0,
input      [0:0]             in_foreground_wenable1,
input      [5:0]                 in_foreground_wdata1,
input      [11:0]                in_foreground_addr1,
output reg  [5:0]     out_foreground_rdata0,
output reg  [5:0]     out_foreground_rdata1,
input      clock0,
input      clock1
);
reg  [5:0] buffer[2399:0];
always @(posedge clock0) begin
  if (in_foreground_wenable0) begin
    buffer[in_foreground_addr0] <= in_foreground_wdata0;
  end else begin
    out_foreground_rdata0 <= buffer[in_foreground_addr0];
  end
end
always @(posedge clock1) begin
  if (in_foreground_wenable1) begin
    buffer[in_foreground_addr1] <= in_foreground_wdata1;
  end else begin
    out_foreground_rdata1 <= buffer[in_foreground_addr1];
  end
end

endmodule

module M_character_map_mem_background(
input      [0:0]             in_background_wenable0,
input       [6:0]     in_background_wdata0,
input      [11:0]                in_background_addr0,
input      [0:0]             in_background_wenable1,
input      [6:0]                 in_background_wdata1,
input      [11:0]                in_background_addr1,
output reg  [6:0]     out_background_rdata0,
output reg  [6:0]     out_background_rdata1,
input      clock0,
input      clock1
);
reg  [6:0] buffer[2399:0];
always @(posedge clock0) begin
  if (in_background_wenable0) begin
    buffer[in_background_addr0] <= in_background_wdata0;
  end else begin
    out_background_rdata0 <= buffer[in_background_addr0];
  end
end
always @(posedge clock1) begin
  if (in_background_wenable1) begin
    buffer[in_background_addr1] <= in_background_wdata1;
  end else begin
    out_background_rdata1 <= buffer[in_background_addr1];
  end
end
initial begin
 buffer[0] = 7'h40;
 buffer[1] = 7'h40;
 buffer[2] = 7'h40;
 buffer[3] = 7'h40;
 buffer[4] = 7'h40;
 buffer[5] = 7'h40;
 buffer[6] = 7'h40;
 buffer[7] = 7'h40;
 buffer[8] = 7'h40;
 buffer[9] = 7'h40;
 buffer[10] = 7'h40;
 buffer[11] = 7'h40;
 buffer[12] = 7'h40;
 buffer[13] = 7'h40;
 buffer[14] = 7'h40;
 buffer[15] = 7'h40;
 buffer[16] = 7'h40;
 buffer[17] = 7'h40;
 buffer[18] = 7'h40;
 buffer[19] = 7'h40;
 buffer[20] = 7'h40;
 buffer[21] = 7'h40;
 buffer[22] = 7'h40;
 buffer[23] = 7'h40;
 buffer[24] = 7'h40;
 buffer[25] = 7'h40;
 buffer[26] = 7'h40;
 buffer[27] = 7'h40;
 buffer[28] = 7'h40;
 buffer[29] = 7'h40;
 buffer[30] = 7'h40;
 buffer[31] = 7'h40;
 buffer[32] = 7'h40;
 buffer[33] = 7'h40;
 buffer[34] = 7'h40;
 buffer[35] = 7'h40;
 buffer[36] = 7'h40;
 buffer[37] = 7'h40;
 buffer[38] = 7'h40;
 buffer[39] = 7'h40;
 buffer[40] = 7'h40;
 buffer[41] = 7'h40;
 buffer[42] = 7'h40;
 buffer[43] = 7'h40;
 buffer[44] = 7'h40;
 buffer[45] = 7'h40;
 buffer[46] = 7'h40;
 buffer[47] = 7'h40;
 buffer[48] = 7'h40;
 buffer[49] = 7'h40;
 buffer[50] = 7'h40;
 buffer[51] = 7'h40;
 buffer[52] = 7'h40;
 buffer[53] = 7'h40;
 buffer[54] = 7'h40;
 buffer[55] = 7'h40;
 buffer[56] = 7'h40;
 buffer[57] = 7'h40;
 buffer[58] = 7'h40;
 buffer[59] = 7'h40;
 buffer[60] = 7'h40;
 buffer[61] = 7'h40;
 buffer[62] = 7'h40;
 buffer[63] = 7'h40;
 buffer[64] = 7'h40;
 buffer[65] = 7'h40;
 buffer[66] = 7'h40;
 buffer[67] = 7'h40;
 buffer[68] = 7'h40;
 buffer[69] = 7'h40;
 buffer[70] = 7'h40;
 buffer[71] = 7'h40;
 buffer[72] = 7'h40;
 buffer[73] = 7'h40;
 buffer[74] = 7'h40;
 buffer[75] = 7'h40;
 buffer[76] = 7'h40;
 buffer[77] = 7'h40;
 buffer[78] = 7'h40;
 buffer[79] = 7'h40;
 buffer[80] = 7'h40;
 buffer[81] = 7'h40;
 buffer[82] = 7'h40;
 buffer[83] = 7'h40;
 buffer[84] = 7'h40;
 buffer[85] = 7'h40;
 buffer[86] = 7'h40;
 buffer[87] = 7'h40;
 buffer[88] = 7'h40;
 buffer[89] = 7'h40;
 buffer[90] = 7'h40;
 buffer[91] = 7'h40;
 buffer[92] = 7'h40;
 buffer[93] = 7'h40;
 buffer[94] = 7'h40;
 buffer[95] = 7'h40;
 buffer[96] = 7'h40;
 buffer[97] = 7'h40;
 buffer[98] = 7'h40;
 buffer[99] = 7'h40;
 buffer[100] = 7'h40;
 buffer[101] = 7'h40;
 buffer[102] = 7'h40;
 buffer[103] = 7'h40;
 buffer[104] = 7'h40;
 buffer[105] = 7'h40;
 buffer[106] = 7'h40;
 buffer[107] = 7'h40;
 buffer[108] = 7'h40;
 buffer[109] = 7'h40;
 buffer[110] = 7'h40;
 buffer[111] = 7'h40;
 buffer[112] = 7'h40;
 buffer[113] = 7'h40;
 buffer[114] = 7'h40;
 buffer[115] = 7'h40;
 buffer[116] = 7'h40;
 buffer[117] = 7'h40;
 buffer[118] = 7'h40;
 buffer[119] = 7'h40;
 buffer[120] = 7'h40;
 buffer[121] = 7'h40;
 buffer[122] = 7'h40;
 buffer[123] = 7'h40;
 buffer[124] = 7'h40;
 buffer[125] = 7'h40;
 buffer[126] = 7'h40;
 buffer[127] = 7'h40;
 buffer[128] = 7'h40;
 buffer[129] = 7'h40;
 buffer[130] = 7'h40;
 buffer[131] = 7'h40;
 buffer[132] = 7'h40;
 buffer[133] = 7'h40;
 buffer[134] = 7'h40;
 buffer[135] = 7'h40;
 buffer[136] = 7'h40;
 buffer[137] = 7'h40;
 buffer[138] = 7'h40;
 buffer[139] = 7'h40;
 buffer[140] = 7'h40;
 buffer[141] = 7'h40;
 buffer[142] = 7'h40;
 buffer[143] = 7'h40;
 buffer[144] = 7'h40;
 buffer[145] = 7'h40;
 buffer[146] = 7'h40;
 buffer[147] = 7'h40;
 buffer[148] = 7'h40;
 buffer[149] = 7'h40;
 buffer[150] = 7'h40;
 buffer[151] = 7'h40;
 buffer[152] = 7'h40;
 buffer[153] = 7'h40;
 buffer[154] = 7'h40;
 buffer[155] = 7'h40;
 buffer[156] = 7'h40;
 buffer[157] = 7'h40;
 buffer[158] = 7'h40;
 buffer[159] = 7'h40;
 buffer[160] = 7'h40;
 buffer[161] = 7'h40;
 buffer[162] = 7'h40;
 buffer[163] = 7'h40;
 buffer[164] = 7'h40;
 buffer[165] = 7'h40;
 buffer[166] = 7'h40;
 buffer[167] = 7'h40;
 buffer[168] = 7'h40;
 buffer[169] = 7'h40;
 buffer[170] = 7'h40;
 buffer[171] = 7'h40;
 buffer[172] = 7'h40;
 buffer[173] = 7'h40;
 buffer[174] = 7'h40;
 buffer[175] = 7'h40;
 buffer[176] = 7'h40;
 buffer[177] = 7'h40;
 buffer[178] = 7'h40;
 buffer[179] = 7'h40;
 buffer[180] = 7'h40;
 buffer[181] = 7'h40;
 buffer[182] = 7'h40;
 buffer[183] = 7'h40;
 buffer[184] = 7'h40;
 buffer[185] = 7'h40;
 buffer[186] = 7'h40;
 buffer[187] = 7'h40;
 buffer[188] = 7'h40;
 buffer[189] = 7'h40;
 buffer[190] = 7'h40;
 buffer[191] = 7'h40;
 buffer[192] = 7'h40;
 buffer[193] = 7'h40;
 buffer[194] = 7'h40;
 buffer[195] = 7'h40;
 buffer[196] = 7'h40;
 buffer[197] = 7'h40;
 buffer[198] = 7'h40;
 buffer[199] = 7'h40;
 buffer[200] = 7'h40;
 buffer[201] = 7'h40;
 buffer[202] = 7'h40;
 buffer[203] = 7'h40;
 buffer[204] = 7'h40;
 buffer[205] = 7'h40;
 buffer[206] = 7'h40;
 buffer[207] = 7'h40;
 buffer[208] = 7'h40;
 buffer[209] = 7'h40;
 buffer[210] = 7'h40;
 buffer[211] = 7'h40;
 buffer[212] = 7'h40;
 buffer[213] = 7'h40;
 buffer[214] = 7'h40;
 buffer[215] = 7'h40;
 buffer[216] = 7'h40;
 buffer[217] = 7'h40;
 buffer[218] = 7'h40;
 buffer[219] = 7'h40;
 buffer[220] = 7'h40;
 buffer[221] = 7'h40;
 buffer[222] = 7'h40;
 buffer[223] = 7'h40;
 buffer[224] = 7'h40;
 buffer[225] = 7'h40;
 buffer[226] = 7'h40;
 buffer[227] = 7'h40;
 buffer[228] = 7'h40;
 buffer[229] = 7'h40;
 buffer[230] = 7'h40;
 buffer[231] = 7'h40;
 buffer[232] = 7'h40;
 buffer[233] = 7'h40;
 buffer[234] = 7'h40;
 buffer[235] = 7'h40;
 buffer[236] = 7'h40;
 buffer[237] = 7'h40;
 buffer[238] = 7'h40;
 buffer[239] = 7'h40;
 buffer[240] = 7'h40;
 buffer[241] = 7'h40;
 buffer[242] = 7'h40;
 buffer[243] = 7'h40;
 buffer[244] = 7'h40;
 buffer[245] = 7'h40;
 buffer[246] = 7'h40;
 buffer[247] = 7'h40;
 buffer[248] = 7'h40;
 buffer[249] = 7'h40;
 buffer[250] = 7'h40;
 buffer[251] = 7'h40;
 buffer[252] = 7'h40;
 buffer[253] = 7'h40;
 buffer[254] = 7'h40;
 buffer[255] = 7'h40;
 buffer[256] = 7'h40;
 buffer[257] = 7'h40;
 buffer[258] = 7'h40;
 buffer[259] = 7'h40;
 buffer[260] = 7'h40;
 buffer[261] = 7'h40;
 buffer[262] = 7'h40;
 buffer[263] = 7'h40;
 buffer[264] = 7'h40;
 buffer[265] = 7'h40;
 buffer[266] = 7'h40;
 buffer[267] = 7'h40;
 buffer[268] = 7'h40;
 buffer[269] = 7'h40;
 buffer[270] = 7'h40;
 buffer[271] = 7'h40;
 buffer[272] = 7'h40;
 buffer[273] = 7'h40;
 buffer[274] = 7'h40;
 buffer[275] = 7'h40;
 buffer[276] = 7'h40;
 buffer[277] = 7'h40;
 buffer[278] = 7'h40;
 buffer[279] = 7'h40;
 buffer[280] = 7'h40;
 buffer[281] = 7'h40;
 buffer[282] = 7'h40;
 buffer[283] = 7'h40;
 buffer[284] = 7'h40;
 buffer[285] = 7'h40;
 buffer[286] = 7'h40;
 buffer[287] = 7'h40;
 buffer[288] = 7'h40;
 buffer[289] = 7'h40;
 buffer[290] = 7'h40;
 buffer[291] = 7'h40;
 buffer[292] = 7'h40;
 buffer[293] = 7'h40;
 buffer[294] = 7'h40;
 buffer[295] = 7'h40;
 buffer[296] = 7'h40;
 buffer[297] = 7'h40;
 buffer[298] = 7'h40;
 buffer[299] = 7'h40;
 buffer[300] = 7'h40;
 buffer[301] = 7'h40;
 buffer[302] = 7'h40;
 buffer[303] = 7'h40;
 buffer[304] = 7'h40;
 buffer[305] = 7'h40;
 buffer[306] = 7'h40;
 buffer[307] = 7'h40;
 buffer[308] = 7'h40;
 buffer[309] = 7'h40;
 buffer[310] = 7'h40;
 buffer[311] = 7'h40;
 buffer[312] = 7'h40;
 buffer[313] = 7'h40;
 buffer[314] = 7'h40;
 buffer[315] = 7'h40;
 buffer[316] = 7'h40;
 buffer[317] = 7'h40;
 buffer[318] = 7'h40;
 buffer[319] = 7'h40;
 buffer[320] = 7'h40;
 buffer[321] = 7'h40;
 buffer[322] = 7'h40;
 buffer[323] = 7'h40;
 buffer[324] = 7'h40;
 buffer[325] = 7'h40;
 buffer[326] = 7'h40;
 buffer[327] = 7'h40;
 buffer[328] = 7'h40;
 buffer[329] = 7'h40;
 buffer[330] = 7'h40;
 buffer[331] = 7'h40;
 buffer[332] = 7'h40;
 buffer[333] = 7'h40;
 buffer[334] = 7'h40;
 buffer[335] = 7'h40;
 buffer[336] = 7'h40;
 buffer[337] = 7'h40;
 buffer[338] = 7'h40;
 buffer[339] = 7'h40;
 buffer[340] = 7'h40;
 buffer[341] = 7'h40;
 buffer[342] = 7'h40;
 buffer[343] = 7'h40;
 buffer[344] = 7'h40;
 buffer[345] = 7'h40;
 buffer[346] = 7'h40;
 buffer[347] = 7'h40;
 buffer[348] = 7'h40;
 buffer[349] = 7'h40;
 buffer[350] = 7'h40;
 buffer[351] = 7'h40;
 buffer[352] = 7'h40;
 buffer[353] = 7'h40;
 buffer[354] = 7'h40;
 buffer[355] = 7'h40;
 buffer[356] = 7'h40;
 buffer[357] = 7'h40;
 buffer[358] = 7'h40;
 buffer[359] = 7'h40;
 buffer[360] = 7'h40;
 buffer[361] = 7'h40;
 buffer[362] = 7'h40;
 buffer[363] = 7'h40;
 buffer[364] = 7'h40;
 buffer[365] = 7'h40;
 buffer[366] = 7'h40;
 buffer[367] = 7'h40;
 buffer[368] = 7'h40;
 buffer[369] = 7'h40;
 buffer[370] = 7'h40;
 buffer[371] = 7'h40;
 buffer[372] = 7'h40;
 buffer[373] = 7'h40;
 buffer[374] = 7'h40;
 buffer[375] = 7'h40;
 buffer[376] = 7'h40;
 buffer[377] = 7'h40;
 buffer[378] = 7'h40;
 buffer[379] = 7'h40;
 buffer[380] = 7'h40;
 buffer[381] = 7'h40;
 buffer[382] = 7'h40;
 buffer[383] = 7'h40;
 buffer[384] = 7'h40;
 buffer[385] = 7'h40;
 buffer[386] = 7'h40;
 buffer[387] = 7'h40;
 buffer[388] = 7'h40;
 buffer[389] = 7'h40;
 buffer[390] = 7'h40;
 buffer[391] = 7'h40;
 buffer[392] = 7'h40;
 buffer[393] = 7'h40;
 buffer[394] = 7'h40;
 buffer[395] = 7'h40;
 buffer[396] = 7'h40;
 buffer[397] = 7'h40;
 buffer[398] = 7'h40;
 buffer[399] = 7'h40;
 buffer[400] = 7'h40;
 buffer[401] = 7'h40;
 buffer[402] = 7'h40;
 buffer[403] = 7'h40;
 buffer[404] = 7'h40;
 buffer[405] = 7'h40;
 buffer[406] = 7'h40;
 buffer[407] = 7'h40;
 buffer[408] = 7'h40;
 buffer[409] = 7'h40;
 buffer[410] = 7'h40;
 buffer[411] = 7'h40;
 buffer[412] = 7'h40;
 buffer[413] = 7'h40;
 buffer[414] = 7'h40;
 buffer[415] = 7'h40;
 buffer[416] = 7'h40;
 buffer[417] = 7'h40;
 buffer[418] = 7'h40;
 buffer[419] = 7'h40;
 buffer[420] = 7'h40;
 buffer[421] = 7'h40;
 buffer[422] = 7'h40;
 buffer[423] = 7'h40;
 buffer[424] = 7'h40;
 buffer[425] = 7'h40;
 buffer[426] = 7'h40;
 buffer[427] = 7'h40;
 buffer[428] = 7'h40;
 buffer[429] = 7'h40;
 buffer[430] = 7'h40;
 buffer[431] = 7'h40;
 buffer[432] = 7'h40;
 buffer[433] = 7'h40;
 buffer[434] = 7'h40;
 buffer[435] = 7'h40;
 buffer[436] = 7'h40;
 buffer[437] = 7'h40;
 buffer[438] = 7'h40;
 buffer[439] = 7'h40;
 buffer[440] = 7'h40;
 buffer[441] = 7'h40;
 buffer[442] = 7'h40;
 buffer[443] = 7'h40;
 buffer[444] = 7'h40;
 buffer[445] = 7'h40;
 buffer[446] = 7'h40;
 buffer[447] = 7'h40;
 buffer[448] = 7'h40;
 buffer[449] = 7'h40;
 buffer[450] = 7'h40;
 buffer[451] = 7'h40;
 buffer[452] = 7'h40;
 buffer[453] = 7'h40;
 buffer[454] = 7'h40;
 buffer[455] = 7'h40;
 buffer[456] = 7'h40;
 buffer[457] = 7'h40;
 buffer[458] = 7'h40;
 buffer[459] = 7'h40;
 buffer[460] = 7'h40;
 buffer[461] = 7'h40;
 buffer[462] = 7'h40;
 buffer[463] = 7'h40;
 buffer[464] = 7'h40;
 buffer[465] = 7'h40;
 buffer[466] = 7'h40;
 buffer[467] = 7'h40;
 buffer[468] = 7'h40;
 buffer[469] = 7'h40;
 buffer[470] = 7'h40;
 buffer[471] = 7'h40;
 buffer[472] = 7'h40;
 buffer[473] = 7'h40;
 buffer[474] = 7'h40;
 buffer[475] = 7'h40;
 buffer[476] = 7'h40;
 buffer[477] = 7'h40;
 buffer[478] = 7'h40;
 buffer[479] = 7'h40;
 buffer[480] = 7'h40;
 buffer[481] = 7'h40;
 buffer[482] = 7'h40;
 buffer[483] = 7'h40;
 buffer[484] = 7'h40;
 buffer[485] = 7'h40;
 buffer[486] = 7'h40;
 buffer[487] = 7'h40;
 buffer[488] = 7'h40;
 buffer[489] = 7'h40;
 buffer[490] = 7'h40;
 buffer[491] = 7'h40;
 buffer[492] = 7'h40;
 buffer[493] = 7'h40;
 buffer[494] = 7'h40;
 buffer[495] = 7'h40;
 buffer[496] = 7'h40;
 buffer[497] = 7'h40;
 buffer[498] = 7'h40;
 buffer[499] = 7'h40;
 buffer[500] = 7'h40;
 buffer[501] = 7'h40;
 buffer[502] = 7'h40;
 buffer[503] = 7'h40;
 buffer[504] = 7'h40;
 buffer[505] = 7'h40;
 buffer[506] = 7'h40;
 buffer[507] = 7'h40;
 buffer[508] = 7'h40;
 buffer[509] = 7'h40;
 buffer[510] = 7'h40;
 buffer[511] = 7'h40;
 buffer[512] = 7'h40;
 buffer[513] = 7'h40;
 buffer[514] = 7'h40;
 buffer[515] = 7'h40;
 buffer[516] = 7'h40;
 buffer[517] = 7'h40;
 buffer[518] = 7'h40;
 buffer[519] = 7'h40;
 buffer[520] = 7'h40;
 buffer[521] = 7'h40;
 buffer[522] = 7'h40;
 buffer[523] = 7'h40;
 buffer[524] = 7'h40;
 buffer[525] = 7'h40;
 buffer[526] = 7'h40;
 buffer[527] = 7'h40;
 buffer[528] = 7'h40;
 buffer[529] = 7'h40;
 buffer[530] = 7'h40;
 buffer[531] = 7'h40;
 buffer[532] = 7'h40;
 buffer[533] = 7'h40;
 buffer[534] = 7'h40;
 buffer[535] = 7'h40;
 buffer[536] = 7'h40;
 buffer[537] = 7'h40;
 buffer[538] = 7'h40;
 buffer[539] = 7'h40;
 buffer[540] = 7'h40;
 buffer[541] = 7'h40;
 buffer[542] = 7'h40;
 buffer[543] = 7'h40;
 buffer[544] = 7'h40;
 buffer[545] = 7'h40;
 buffer[546] = 7'h40;
 buffer[547] = 7'h40;
 buffer[548] = 7'h40;
 buffer[549] = 7'h40;
 buffer[550] = 7'h40;
 buffer[551] = 7'h40;
 buffer[552] = 7'h40;
 buffer[553] = 7'h40;
 buffer[554] = 7'h40;
 buffer[555] = 7'h40;
 buffer[556] = 7'h40;
 buffer[557] = 7'h40;
 buffer[558] = 7'h40;
 buffer[559] = 7'h40;
 buffer[560] = 7'h40;
 buffer[561] = 7'h40;
 buffer[562] = 7'h40;
 buffer[563] = 7'h40;
 buffer[564] = 7'h40;
 buffer[565] = 7'h40;
 buffer[566] = 7'h40;
 buffer[567] = 7'h40;
 buffer[568] = 7'h40;
 buffer[569] = 7'h40;
 buffer[570] = 7'h40;
 buffer[571] = 7'h40;
 buffer[572] = 7'h40;
 buffer[573] = 7'h40;
 buffer[574] = 7'h40;
 buffer[575] = 7'h40;
 buffer[576] = 7'h40;
 buffer[577] = 7'h40;
 buffer[578] = 7'h40;
 buffer[579] = 7'h40;
 buffer[580] = 7'h40;
 buffer[581] = 7'h40;
 buffer[582] = 7'h40;
 buffer[583] = 7'h40;
 buffer[584] = 7'h40;
 buffer[585] = 7'h40;
 buffer[586] = 7'h40;
 buffer[587] = 7'h40;
 buffer[588] = 7'h40;
 buffer[589] = 7'h40;
 buffer[590] = 7'h40;
 buffer[591] = 7'h40;
 buffer[592] = 7'h40;
 buffer[593] = 7'h40;
 buffer[594] = 7'h40;
 buffer[595] = 7'h40;
 buffer[596] = 7'h40;
 buffer[597] = 7'h40;
 buffer[598] = 7'h40;
 buffer[599] = 7'h40;
 buffer[600] = 7'h40;
 buffer[601] = 7'h40;
 buffer[602] = 7'h40;
 buffer[603] = 7'h40;
 buffer[604] = 7'h40;
 buffer[605] = 7'h40;
 buffer[606] = 7'h40;
 buffer[607] = 7'h40;
 buffer[608] = 7'h40;
 buffer[609] = 7'h40;
 buffer[610] = 7'h40;
 buffer[611] = 7'h40;
 buffer[612] = 7'h40;
 buffer[613] = 7'h40;
 buffer[614] = 7'h40;
 buffer[615] = 7'h40;
 buffer[616] = 7'h40;
 buffer[617] = 7'h40;
 buffer[618] = 7'h40;
 buffer[619] = 7'h40;
 buffer[620] = 7'h40;
 buffer[621] = 7'h40;
 buffer[622] = 7'h40;
 buffer[623] = 7'h40;
 buffer[624] = 7'h40;
 buffer[625] = 7'h40;
 buffer[626] = 7'h40;
 buffer[627] = 7'h40;
 buffer[628] = 7'h40;
 buffer[629] = 7'h40;
 buffer[630] = 7'h40;
 buffer[631] = 7'h40;
 buffer[632] = 7'h40;
 buffer[633] = 7'h40;
 buffer[634] = 7'h40;
 buffer[635] = 7'h40;
 buffer[636] = 7'h40;
 buffer[637] = 7'h40;
 buffer[638] = 7'h40;
 buffer[639] = 7'h40;
 buffer[640] = 7'h40;
 buffer[641] = 7'h40;
 buffer[642] = 7'h40;
 buffer[643] = 7'h40;
 buffer[644] = 7'h40;
 buffer[645] = 7'h40;
 buffer[646] = 7'h40;
 buffer[647] = 7'h40;
 buffer[648] = 7'h40;
 buffer[649] = 7'h40;
 buffer[650] = 7'h40;
 buffer[651] = 7'h40;
 buffer[652] = 7'h40;
 buffer[653] = 7'h40;
 buffer[654] = 7'h40;
 buffer[655] = 7'h40;
 buffer[656] = 7'h40;
 buffer[657] = 7'h40;
 buffer[658] = 7'h40;
 buffer[659] = 7'h40;
 buffer[660] = 7'h40;
 buffer[661] = 7'h40;
 buffer[662] = 7'h40;
 buffer[663] = 7'h40;
 buffer[664] = 7'h40;
 buffer[665] = 7'h40;
 buffer[666] = 7'h40;
 buffer[667] = 7'h40;
 buffer[668] = 7'h40;
 buffer[669] = 7'h40;
 buffer[670] = 7'h40;
 buffer[671] = 7'h40;
 buffer[672] = 7'h40;
 buffer[673] = 7'h40;
 buffer[674] = 7'h40;
 buffer[675] = 7'h40;
 buffer[676] = 7'h40;
 buffer[677] = 7'h40;
 buffer[678] = 7'h40;
 buffer[679] = 7'h40;
 buffer[680] = 7'h40;
 buffer[681] = 7'h40;
 buffer[682] = 7'h40;
 buffer[683] = 7'h40;
 buffer[684] = 7'h40;
 buffer[685] = 7'h40;
 buffer[686] = 7'h40;
 buffer[687] = 7'h40;
 buffer[688] = 7'h40;
 buffer[689] = 7'h40;
 buffer[690] = 7'h40;
 buffer[691] = 7'h40;
 buffer[692] = 7'h40;
 buffer[693] = 7'h40;
 buffer[694] = 7'h40;
 buffer[695] = 7'h40;
 buffer[696] = 7'h40;
 buffer[697] = 7'h40;
 buffer[698] = 7'h40;
 buffer[699] = 7'h40;
 buffer[700] = 7'h40;
 buffer[701] = 7'h40;
 buffer[702] = 7'h40;
 buffer[703] = 7'h40;
 buffer[704] = 7'h40;
 buffer[705] = 7'h40;
 buffer[706] = 7'h40;
 buffer[707] = 7'h40;
 buffer[708] = 7'h40;
 buffer[709] = 7'h40;
 buffer[710] = 7'h40;
 buffer[711] = 7'h40;
 buffer[712] = 7'h40;
 buffer[713] = 7'h40;
 buffer[714] = 7'h40;
 buffer[715] = 7'h40;
 buffer[716] = 7'h40;
 buffer[717] = 7'h40;
 buffer[718] = 7'h40;
 buffer[719] = 7'h40;
 buffer[720] = 7'h40;
 buffer[721] = 7'h40;
 buffer[722] = 7'h40;
 buffer[723] = 7'h40;
 buffer[724] = 7'h40;
 buffer[725] = 7'h40;
 buffer[726] = 7'h40;
 buffer[727] = 7'h40;
 buffer[728] = 7'h40;
 buffer[729] = 7'h40;
 buffer[730] = 7'h40;
 buffer[731] = 7'h40;
 buffer[732] = 7'h40;
 buffer[733] = 7'h40;
 buffer[734] = 7'h40;
 buffer[735] = 7'h40;
 buffer[736] = 7'h40;
 buffer[737] = 7'h40;
 buffer[738] = 7'h40;
 buffer[739] = 7'h40;
 buffer[740] = 7'h40;
 buffer[741] = 7'h40;
 buffer[742] = 7'h40;
 buffer[743] = 7'h40;
 buffer[744] = 7'h40;
 buffer[745] = 7'h40;
 buffer[746] = 7'h40;
 buffer[747] = 7'h40;
 buffer[748] = 7'h40;
 buffer[749] = 7'h40;
 buffer[750] = 7'h40;
 buffer[751] = 7'h40;
 buffer[752] = 7'h40;
 buffer[753] = 7'h40;
 buffer[754] = 7'h40;
 buffer[755] = 7'h40;
 buffer[756] = 7'h40;
 buffer[757] = 7'h40;
 buffer[758] = 7'h40;
 buffer[759] = 7'h40;
 buffer[760] = 7'h40;
 buffer[761] = 7'h40;
 buffer[762] = 7'h40;
 buffer[763] = 7'h40;
 buffer[764] = 7'h40;
 buffer[765] = 7'h40;
 buffer[766] = 7'h40;
 buffer[767] = 7'h40;
 buffer[768] = 7'h40;
 buffer[769] = 7'h40;
 buffer[770] = 7'h40;
 buffer[771] = 7'h40;
 buffer[772] = 7'h40;
 buffer[773] = 7'h40;
 buffer[774] = 7'h40;
 buffer[775] = 7'h40;
 buffer[776] = 7'h40;
 buffer[777] = 7'h40;
 buffer[778] = 7'h40;
 buffer[779] = 7'h40;
 buffer[780] = 7'h40;
 buffer[781] = 7'h40;
 buffer[782] = 7'h40;
 buffer[783] = 7'h40;
 buffer[784] = 7'h40;
 buffer[785] = 7'h40;
 buffer[786] = 7'h40;
 buffer[787] = 7'h40;
 buffer[788] = 7'h40;
 buffer[789] = 7'h40;
 buffer[790] = 7'h40;
 buffer[791] = 7'h40;
 buffer[792] = 7'h40;
 buffer[793] = 7'h40;
 buffer[794] = 7'h40;
 buffer[795] = 7'h40;
 buffer[796] = 7'h40;
 buffer[797] = 7'h40;
 buffer[798] = 7'h40;
 buffer[799] = 7'h40;
 buffer[800] = 7'h40;
 buffer[801] = 7'h40;
 buffer[802] = 7'h40;
 buffer[803] = 7'h40;
 buffer[804] = 7'h40;
 buffer[805] = 7'h40;
 buffer[806] = 7'h40;
 buffer[807] = 7'h40;
 buffer[808] = 7'h40;
 buffer[809] = 7'h40;
 buffer[810] = 7'h40;
 buffer[811] = 7'h40;
 buffer[812] = 7'h40;
 buffer[813] = 7'h40;
 buffer[814] = 7'h40;
 buffer[815] = 7'h40;
 buffer[816] = 7'h40;
 buffer[817] = 7'h40;
 buffer[818] = 7'h40;
 buffer[819] = 7'h40;
 buffer[820] = 7'h40;
 buffer[821] = 7'h40;
 buffer[822] = 7'h40;
 buffer[823] = 7'h40;
 buffer[824] = 7'h40;
 buffer[825] = 7'h40;
 buffer[826] = 7'h40;
 buffer[827] = 7'h40;
 buffer[828] = 7'h40;
 buffer[829] = 7'h40;
 buffer[830] = 7'h40;
 buffer[831] = 7'h40;
 buffer[832] = 7'h40;
 buffer[833] = 7'h40;
 buffer[834] = 7'h40;
 buffer[835] = 7'h40;
 buffer[836] = 7'h40;
 buffer[837] = 7'h40;
 buffer[838] = 7'h40;
 buffer[839] = 7'h40;
 buffer[840] = 7'h40;
 buffer[841] = 7'h40;
 buffer[842] = 7'h40;
 buffer[843] = 7'h40;
 buffer[844] = 7'h40;
 buffer[845] = 7'h40;
 buffer[846] = 7'h40;
 buffer[847] = 7'h40;
 buffer[848] = 7'h40;
 buffer[849] = 7'h40;
 buffer[850] = 7'h40;
 buffer[851] = 7'h40;
 buffer[852] = 7'h40;
 buffer[853] = 7'h40;
 buffer[854] = 7'h40;
 buffer[855] = 7'h40;
 buffer[856] = 7'h40;
 buffer[857] = 7'h40;
 buffer[858] = 7'h40;
 buffer[859] = 7'h40;
 buffer[860] = 7'h40;
 buffer[861] = 7'h40;
 buffer[862] = 7'h40;
 buffer[863] = 7'h40;
 buffer[864] = 7'h40;
 buffer[865] = 7'h40;
 buffer[866] = 7'h40;
 buffer[867] = 7'h40;
 buffer[868] = 7'h40;
 buffer[869] = 7'h40;
 buffer[870] = 7'h40;
 buffer[871] = 7'h40;
 buffer[872] = 7'h40;
 buffer[873] = 7'h40;
 buffer[874] = 7'h40;
 buffer[875] = 7'h40;
 buffer[876] = 7'h40;
 buffer[877] = 7'h40;
 buffer[878] = 7'h40;
 buffer[879] = 7'h40;
 buffer[880] = 7'h40;
 buffer[881] = 7'h40;
 buffer[882] = 7'h40;
 buffer[883] = 7'h40;
 buffer[884] = 7'h40;
 buffer[885] = 7'h40;
 buffer[886] = 7'h40;
 buffer[887] = 7'h40;
 buffer[888] = 7'h40;
 buffer[889] = 7'h40;
 buffer[890] = 7'h40;
 buffer[891] = 7'h40;
 buffer[892] = 7'h40;
 buffer[893] = 7'h40;
 buffer[894] = 7'h40;
 buffer[895] = 7'h40;
 buffer[896] = 7'h40;
 buffer[897] = 7'h40;
 buffer[898] = 7'h40;
 buffer[899] = 7'h40;
 buffer[900] = 7'h40;
 buffer[901] = 7'h40;
 buffer[902] = 7'h40;
 buffer[903] = 7'h40;
 buffer[904] = 7'h40;
 buffer[905] = 7'h40;
 buffer[906] = 7'h40;
 buffer[907] = 7'h40;
 buffer[908] = 7'h40;
 buffer[909] = 7'h40;
 buffer[910] = 7'h40;
 buffer[911] = 7'h40;
 buffer[912] = 7'h40;
 buffer[913] = 7'h40;
 buffer[914] = 7'h40;
 buffer[915] = 7'h40;
 buffer[916] = 7'h40;
 buffer[917] = 7'h40;
 buffer[918] = 7'h40;
 buffer[919] = 7'h40;
 buffer[920] = 7'h40;
 buffer[921] = 7'h40;
 buffer[922] = 7'h40;
 buffer[923] = 7'h40;
 buffer[924] = 7'h40;
 buffer[925] = 7'h40;
 buffer[926] = 7'h40;
 buffer[927] = 7'h40;
 buffer[928] = 7'h40;
 buffer[929] = 7'h40;
 buffer[930] = 7'h40;
 buffer[931] = 7'h40;
 buffer[932] = 7'h40;
 buffer[933] = 7'h40;
 buffer[934] = 7'h40;
 buffer[935] = 7'h40;
 buffer[936] = 7'h40;
 buffer[937] = 7'h40;
 buffer[938] = 7'h40;
 buffer[939] = 7'h40;
 buffer[940] = 7'h40;
 buffer[941] = 7'h40;
 buffer[942] = 7'h40;
 buffer[943] = 7'h40;
 buffer[944] = 7'h40;
 buffer[945] = 7'h40;
 buffer[946] = 7'h40;
 buffer[947] = 7'h40;
 buffer[948] = 7'h40;
 buffer[949] = 7'h40;
 buffer[950] = 7'h40;
 buffer[951] = 7'h40;
 buffer[952] = 7'h40;
 buffer[953] = 7'h40;
 buffer[954] = 7'h40;
 buffer[955] = 7'h40;
 buffer[956] = 7'h40;
 buffer[957] = 7'h40;
 buffer[958] = 7'h40;
 buffer[959] = 7'h40;
 buffer[960] = 7'h40;
 buffer[961] = 7'h40;
 buffer[962] = 7'h40;
 buffer[963] = 7'h40;
 buffer[964] = 7'h40;
 buffer[965] = 7'h40;
 buffer[966] = 7'h40;
 buffer[967] = 7'h40;
 buffer[968] = 7'h40;
 buffer[969] = 7'h40;
 buffer[970] = 7'h40;
 buffer[971] = 7'h40;
 buffer[972] = 7'h40;
 buffer[973] = 7'h40;
 buffer[974] = 7'h40;
 buffer[975] = 7'h40;
 buffer[976] = 7'h40;
 buffer[977] = 7'h40;
 buffer[978] = 7'h40;
 buffer[979] = 7'h40;
 buffer[980] = 7'h40;
 buffer[981] = 7'h40;
 buffer[982] = 7'h40;
 buffer[983] = 7'h40;
 buffer[984] = 7'h40;
 buffer[985] = 7'h40;
 buffer[986] = 7'h40;
 buffer[987] = 7'h40;
 buffer[988] = 7'h40;
 buffer[989] = 7'h40;
 buffer[990] = 7'h40;
 buffer[991] = 7'h40;
 buffer[992] = 7'h40;
 buffer[993] = 7'h40;
 buffer[994] = 7'h40;
 buffer[995] = 7'h40;
 buffer[996] = 7'h40;
 buffer[997] = 7'h40;
 buffer[998] = 7'h40;
 buffer[999] = 7'h40;
 buffer[1000] = 7'h40;
 buffer[1001] = 7'h40;
 buffer[1002] = 7'h40;
 buffer[1003] = 7'h40;
 buffer[1004] = 7'h40;
 buffer[1005] = 7'h40;
 buffer[1006] = 7'h40;
 buffer[1007] = 7'h40;
 buffer[1008] = 7'h40;
 buffer[1009] = 7'h40;
 buffer[1010] = 7'h40;
 buffer[1011] = 7'h40;
 buffer[1012] = 7'h40;
 buffer[1013] = 7'h40;
 buffer[1014] = 7'h40;
 buffer[1015] = 7'h40;
 buffer[1016] = 7'h40;
 buffer[1017] = 7'h40;
 buffer[1018] = 7'h40;
 buffer[1019] = 7'h40;
 buffer[1020] = 7'h40;
 buffer[1021] = 7'h40;
 buffer[1022] = 7'h40;
 buffer[1023] = 7'h40;
 buffer[1024] = 7'h40;
 buffer[1025] = 7'h40;
 buffer[1026] = 7'h40;
 buffer[1027] = 7'h40;
 buffer[1028] = 7'h40;
 buffer[1029] = 7'h40;
 buffer[1030] = 7'h40;
 buffer[1031] = 7'h40;
 buffer[1032] = 7'h40;
 buffer[1033] = 7'h40;
 buffer[1034] = 7'h40;
 buffer[1035] = 7'h40;
 buffer[1036] = 7'h40;
 buffer[1037] = 7'h40;
 buffer[1038] = 7'h40;
 buffer[1039] = 7'h40;
 buffer[1040] = 7'h40;
 buffer[1041] = 7'h40;
 buffer[1042] = 7'h40;
 buffer[1043] = 7'h40;
 buffer[1044] = 7'h40;
 buffer[1045] = 7'h40;
 buffer[1046] = 7'h40;
 buffer[1047] = 7'h40;
 buffer[1048] = 7'h40;
 buffer[1049] = 7'h40;
 buffer[1050] = 7'h40;
 buffer[1051] = 7'h40;
 buffer[1052] = 7'h40;
 buffer[1053] = 7'h40;
 buffer[1054] = 7'h40;
 buffer[1055] = 7'h40;
 buffer[1056] = 7'h40;
 buffer[1057] = 7'h40;
 buffer[1058] = 7'h40;
 buffer[1059] = 7'h40;
 buffer[1060] = 7'h40;
 buffer[1061] = 7'h40;
 buffer[1062] = 7'h40;
 buffer[1063] = 7'h40;
 buffer[1064] = 7'h40;
 buffer[1065] = 7'h40;
 buffer[1066] = 7'h40;
 buffer[1067] = 7'h40;
 buffer[1068] = 7'h40;
 buffer[1069] = 7'h40;
 buffer[1070] = 7'h40;
 buffer[1071] = 7'h40;
 buffer[1072] = 7'h40;
 buffer[1073] = 7'h40;
 buffer[1074] = 7'h40;
 buffer[1075] = 7'h40;
 buffer[1076] = 7'h40;
 buffer[1077] = 7'h40;
 buffer[1078] = 7'h40;
 buffer[1079] = 7'h40;
 buffer[1080] = 7'h40;
 buffer[1081] = 7'h40;
 buffer[1082] = 7'h40;
 buffer[1083] = 7'h40;
 buffer[1084] = 7'h40;
 buffer[1085] = 7'h40;
 buffer[1086] = 7'h40;
 buffer[1087] = 7'h40;
 buffer[1088] = 7'h40;
 buffer[1089] = 7'h40;
 buffer[1090] = 7'h40;
 buffer[1091] = 7'h40;
 buffer[1092] = 7'h40;
 buffer[1093] = 7'h40;
 buffer[1094] = 7'h40;
 buffer[1095] = 7'h40;
 buffer[1096] = 7'h40;
 buffer[1097] = 7'h40;
 buffer[1098] = 7'h40;
 buffer[1099] = 7'h40;
 buffer[1100] = 7'h40;
 buffer[1101] = 7'h40;
 buffer[1102] = 7'h40;
 buffer[1103] = 7'h40;
 buffer[1104] = 7'h40;
 buffer[1105] = 7'h40;
 buffer[1106] = 7'h40;
 buffer[1107] = 7'h40;
 buffer[1108] = 7'h40;
 buffer[1109] = 7'h40;
 buffer[1110] = 7'h40;
 buffer[1111] = 7'h40;
 buffer[1112] = 7'h40;
 buffer[1113] = 7'h40;
 buffer[1114] = 7'h40;
 buffer[1115] = 7'h40;
 buffer[1116] = 7'h40;
 buffer[1117] = 7'h40;
 buffer[1118] = 7'h40;
 buffer[1119] = 7'h40;
 buffer[1120] = 7'h40;
 buffer[1121] = 7'h40;
 buffer[1122] = 7'h40;
 buffer[1123] = 7'h40;
 buffer[1124] = 7'h40;
 buffer[1125] = 7'h40;
 buffer[1126] = 7'h40;
 buffer[1127] = 7'h40;
 buffer[1128] = 7'h40;
 buffer[1129] = 7'h40;
 buffer[1130] = 7'h40;
 buffer[1131] = 7'h40;
 buffer[1132] = 7'h40;
 buffer[1133] = 7'h40;
 buffer[1134] = 7'h40;
 buffer[1135] = 7'h40;
 buffer[1136] = 7'h40;
 buffer[1137] = 7'h40;
 buffer[1138] = 7'h40;
 buffer[1139] = 7'h40;
 buffer[1140] = 7'h40;
 buffer[1141] = 7'h40;
 buffer[1142] = 7'h40;
 buffer[1143] = 7'h40;
 buffer[1144] = 7'h40;
 buffer[1145] = 7'h40;
 buffer[1146] = 7'h40;
 buffer[1147] = 7'h40;
 buffer[1148] = 7'h40;
 buffer[1149] = 7'h40;
 buffer[1150] = 7'h40;
 buffer[1151] = 7'h40;
 buffer[1152] = 7'h40;
 buffer[1153] = 7'h40;
 buffer[1154] = 7'h40;
 buffer[1155] = 7'h40;
 buffer[1156] = 7'h40;
 buffer[1157] = 7'h40;
 buffer[1158] = 7'h40;
 buffer[1159] = 7'h40;
 buffer[1160] = 7'h40;
 buffer[1161] = 7'h40;
 buffer[1162] = 7'h40;
 buffer[1163] = 7'h40;
 buffer[1164] = 7'h40;
 buffer[1165] = 7'h40;
 buffer[1166] = 7'h40;
 buffer[1167] = 7'h40;
 buffer[1168] = 7'h40;
 buffer[1169] = 7'h40;
 buffer[1170] = 7'h40;
 buffer[1171] = 7'h40;
 buffer[1172] = 7'h40;
 buffer[1173] = 7'h40;
 buffer[1174] = 7'h40;
 buffer[1175] = 7'h40;
 buffer[1176] = 7'h40;
 buffer[1177] = 7'h40;
 buffer[1178] = 7'h40;
 buffer[1179] = 7'h40;
 buffer[1180] = 7'h40;
 buffer[1181] = 7'h40;
 buffer[1182] = 7'h40;
 buffer[1183] = 7'h40;
 buffer[1184] = 7'h40;
 buffer[1185] = 7'h40;
 buffer[1186] = 7'h40;
 buffer[1187] = 7'h40;
 buffer[1188] = 7'h40;
 buffer[1189] = 7'h40;
 buffer[1190] = 7'h40;
 buffer[1191] = 7'h40;
 buffer[1192] = 7'h40;
 buffer[1193] = 7'h40;
 buffer[1194] = 7'h40;
 buffer[1195] = 7'h40;
 buffer[1196] = 7'h40;
 buffer[1197] = 7'h40;
 buffer[1198] = 7'h40;
 buffer[1199] = 7'h40;
 buffer[1200] = 7'h40;
 buffer[1201] = 7'h40;
 buffer[1202] = 7'h40;
 buffer[1203] = 7'h40;
 buffer[1204] = 7'h40;
 buffer[1205] = 7'h40;
 buffer[1206] = 7'h40;
 buffer[1207] = 7'h40;
 buffer[1208] = 7'h40;
 buffer[1209] = 7'h40;
 buffer[1210] = 7'h40;
 buffer[1211] = 7'h40;
 buffer[1212] = 7'h40;
 buffer[1213] = 7'h40;
 buffer[1214] = 7'h40;
 buffer[1215] = 7'h40;
 buffer[1216] = 7'h40;
 buffer[1217] = 7'h40;
 buffer[1218] = 7'h40;
 buffer[1219] = 7'h40;
 buffer[1220] = 7'h40;
 buffer[1221] = 7'h40;
 buffer[1222] = 7'h40;
 buffer[1223] = 7'h40;
 buffer[1224] = 7'h40;
 buffer[1225] = 7'h40;
 buffer[1226] = 7'h40;
 buffer[1227] = 7'h40;
 buffer[1228] = 7'h40;
 buffer[1229] = 7'h40;
 buffer[1230] = 7'h40;
 buffer[1231] = 7'h40;
 buffer[1232] = 7'h40;
 buffer[1233] = 7'h40;
 buffer[1234] = 7'h40;
 buffer[1235] = 7'h40;
 buffer[1236] = 7'h40;
 buffer[1237] = 7'h40;
 buffer[1238] = 7'h40;
 buffer[1239] = 7'h40;
 buffer[1240] = 7'h40;
 buffer[1241] = 7'h40;
 buffer[1242] = 7'h40;
 buffer[1243] = 7'h40;
 buffer[1244] = 7'h40;
 buffer[1245] = 7'h40;
 buffer[1246] = 7'h40;
 buffer[1247] = 7'h40;
 buffer[1248] = 7'h40;
 buffer[1249] = 7'h40;
 buffer[1250] = 7'h40;
 buffer[1251] = 7'h40;
 buffer[1252] = 7'h40;
 buffer[1253] = 7'h40;
 buffer[1254] = 7'h40;
 buffer[1255] = 7'h40;
 buffer[1256] = 7'h40;
 buffer[1257] = 7'h40;
 buffer[1258] = 7'h40;
 buffer[1259] = 7'h40;
 buffer[1260] = 7'h40;
 buffer[1261] = 7'h40;
 buffer[1262] = 7'h40;
 buffer[1263] = 7'h40;
 buffer[1264] = 7'h40;
 buffer[1265] = 7'h40;
 buffer[1266] = 7'h40;
 buffer[1267] = 7'h40;
 buffer[1268] = 7'h40;
 buffer[1269] = 7'h40;
 buffer[1270] = 7'h40;
 buffer[1271] = 7'h40;
 buffer[1272] = 7'h40;
 buffer[1273] = 7'h40;
 buffer[1274] = 7'h40;
 buffer[1275] = 7'h40;
 buffer[1276] = 7'h40;
 buffer[1277] = 7'h40;
 buffer[1278] = 7'h40;
 buffer[1279] = 7'h40;
 buffer[1280] = 7'h40;
 buffer[1281] = 7'h40;
 buffer[1282] = 7'h40;
 buffer[1283] = 7'h40;
 buffer[1284] = 7'h40;
 buffer[1285] = 7'h40;
 buffer[1286] = 7'h40;
 buffer[1287] = 7'h40;
 buffer[1288] = 7'h40;
 buffer[1289] = 7'h40;
 buffer[1290] = 7'h40;
 buffer[1291] = 7'h40;
 buffer[1292] = 7'h40;
 buffer[1293] = 7'h40;
 buffer[1294] = 7'h40;
 buffer[1295] = 7'h40;
 buffer[1296] = 7'h40;
 buffer[1297] = 7'h40;
 buffer[1298] = 7'h40;
 buffer[1299] = 7'h40;
 buffer[1300] = 7'h40;
 buffer[1301] = 7'h40;
 buffer[1302] = 7'h40;
 buffer[1303] = 7'h40;
 buffer[1304] = 7'h40;
 buffer[1305] = 7'h40;
 buffer[1306] = 7'h40;
 buffer[1307] = 7'h40;
 buffer[1308] = 7'h40;
 buffer[1309] = 7'h40;
 buffer[1310] = 7'h40;
 buffer[1311] = 7'h40;
 buffer[1312] = 7'h40;
 buffer[1313] = 7'h40;
 buffer[1314] = 7'h40;
 buffer[1315] = 7'h40;
 buffer[1316] = 7'h40;
 buffer[1317] = 7'h40;
 buffer[1318] = 7'h40;
 buffer[1319] = 7'h40;
 buffer[1320] = 7'h40;
 buffer[1321] = 7'h40;
 buffer[1322] = 7'h40;
 buffer[1323] = 7'h40;
 buffer[1324] = 7'h40;
 buffer[1325] = 7'h40;
 buffer[1326] = 7'h40;
 buffer[1327] = 7'h40;
 buffer[1328] = 7'h40;
 buffer[1329] = 7'h40;
 buffer[1330] = 7'h40;
 buffer[1331] = 7'h40;
 buffer[1332] = 7'h40;
 buffer[1333] = 7'h40;
 buffer[1334] = 7'h40;
 buffer[1335] = 7'h40;
 buffer[1336] = 7'h40;
 buffer[1337] = 7'h40;
 buffer[1338] = 7'h40;
 buffer[1339] = 7'h40;
 buffer[1340] = 7'h40;
 buffer[1341] = 7'h40;
 buffer[1342] = 7'h40;
 buffer[1343] = 7'h40;
 buffer[1344] = 7'h40;
 buffer[1345] = 7'h40;
 buffer[1346] = 7'h40;
 buffer[1347] = 7'h40;
 buffer[1348] = 7'h40;
 buffer[1349] = 7'h40;
 buffer[1350] = 7'h40;
 buffer[1351] = 7'h40;
 buffer[1352] = 7'h40;
 buffer[1353] = 7'h40;
 buffer[1354] = 7'h40;
 buffer[1355] = 7'h40;
 buffer[1356] = 7'h40;
 buffer[1357] = 7'h40;
 buffer[1358] = 7'h40;
 buffer[1359] = 7'h40;
 buffer[1360] = 7'h40;
 buffer[1361] = 7'h40;
 buffer[1362] = 7'h40;
 buffer[1363] = 7'h40;
 buffer[1364] = 7'h40;
 buffer[1365] = 7'h40;
 buffer[1366] = 7'h40;
 buffer[1367] = 7'h40;
 buffer[1368] = 7'h40;
 buffer[1369] = 7'h40;
 buffer[1370] = 7'h40;
 buffer[1371] = 7'h40;
 buffer[1372] = 7'h40;
 buffer[1373] = 7'h40;
 buffer[1374] = 7'h40;
 buffer[1375] = 7'h40;
 buffer[1376] = 7'h40;
 buffer[1377] = 7'h40;
 buffer[1378] = 7'h40;
 buffer[1379] = 7'h40;
 buffer[1380] = 7'h40;
 buffer[1381] = 7'h40;
 buffer[1382] = 7'h40;
 buffer[1383] = 7'h40;
 buffer[1384] = 7'h40;
 buffer[1385] = 7'h40;
 buffer[1386] = 7'h40;
 buffer[1387] = 7'h40;
 buffer[1388] = 7'h40;
 buffer[1389] = 7'h40;
 buffer[1390] = 7'h40;
 buffer[1391] = 7'h40;
 buffer[1392] = 7'h40;
 buffer[1393] = 7'h40;
 buffer[1394] = 7'h40;
 buffer[1395] = 7'h40;
 buffer[1396] = 7'h40;
 buffer[1397] = 7'h40;
 buffer[1398] = 7'h40;
 buffer[1399] = 7'h40;
 buffer[1400] = 7'h40;
 buffer[1401] = 7'h40;
 buffer[1402] = 7'h40;
 buffer[1403] = 7'h40;
 buffer[1404] = 7'h40;
 buffer[1405] = 7'h40;
 buffer[1406] = 7'h40;
 buffer[1407] = 7'h40;
 buffer[1408] = 7'h40;
 buffer[1409] = 7'h40;
 buffer[1410] = 7'h40;
 buffer[1411] = 7'h40;
 buffer[1412] = 7'h40;
 buffer[1413] = 7'h40;
 buffer[1414] = 7'h40;
 buffer[1415] = 7'h40;
 buffer[1416] = 7'h40;
 buffer[1417] = 7'h40;
 buffer[1418] = 7'h40;
 buffer[1419] = 7'h40;
 buffer[1420] = 7'h40;
 buffer[1421] = 7'h40;
 buffer[1422] = 7'h40;
 buffer[1423] = 7'h40;
 buffer[1424] = 7'h40;
 buffer[1425] = 7'h40;
 buffer[1426] = 7'h40;
 buffer[1427] = 7'h40;
 buffer[1428] = 7'h40;
 buffer[1429] = 7'h40;
 buffer[1430] = 7'h40;
 buffer[1431] = 7'h40;
 buffer[1432] = 7'h40;
 buffer[1433] = 7'h40;
 buffer[1434] = 7'h40;
 buffer[1435] = 7'h40;
 buffer[1436] = 7'h40;
 buffer[1437] = 7'h40;
 buffer[1438] = 7'h40;
 buffer[1439] = 7'h40;
 buffer[1440] = 7'h40;
 buffer[1441] = 7'h40;
 buffer[1442] = 7'h40;
 buffer[1443] = 7'h40;
 buffer[1444] = 7'h40;
 buffer[1445] = 7'h40;
 buffer[1446] = 7'h40;
 buffer[1447] = 7'h40;
 buffer[1448] = 7'h40;
 buffer[1449] = 7'h40;
 buffer[1450] = 7'h40;
 buffer[1451] = 7'h40;
 buffer[1452] = 7'h40;
 buffer[1453] = 7'h40;
 buffer[1454] = 7'h40;
 buffer[1455] = 7'h40;
 buffer[1456] = 7'h40;
 buffer[1457] = 7'h40;
 buffer[1458] = 7'h40;
 buffer[1459] = 7'h40;
 buffer[1460] = 7'h40;
 buffer[1461] = 7'h40;
 buffer[1462] = 7'h40;
 buffer[1463] = 7'h40;
 buffer[1464] = 7'h40;
 buffer[1465] = 7'h40;
 buffer[1466] = 7'h40;
 buffer[1467] = 7'h40;
 buffer[1468] = 7'h40;
 buffer[1469] = 7'h40;
 buffer[1470] = 7'h40;
 buffer[1471] = 7'h40;
 buffer[1472] = 7'h40;
 buffer[1473] = 7'h40;
 buffer[1474] = 7'h40;
 buffer[1475] = 7'h40;
 buffer[1476] = 7'h40;
 buffer[1477] = 7'h40;
 buffer[1478] = 7'h40;
 buffer[1479] = 7'h40;
 buffer[1480] = 7'h40;
 buffer[1481] = 7'h40;
 buffer[1482] = 7'h40;
 buffer[1483] = 7'h40;
 buffer[1484] = 7'h40;
 buffer[1485] = 7'h40;
 buffer[1486] = 7'h40;
 buffer[1487] = 7'h40;
 buffer[1488] = 7'h40;
 buffer[1489] = 7'h40;
 buffer[1490] = 7'h40;
 buffer[1491] = 7'h40;
 buffer[1492] = 7'h40;
 buffer[1493] = 7'h40;
 buffer[1494] = 7'h40;
 buffer[1495] = 7'h40;
 buffer[1496] = 7'h40;
 buffer[1497] = 7'h40;
 buffer[1498] = 7'h40;
 buffer[1499] = 7'h40;
 buffer[1500] = 7'h40;
 buffer[1501] = 7'h40;
 buffer[1502] = 7'h40;
 buffer[1503] = 7'h40;
 buffer[1504] = 7'h40;
 buffer[1505] = 7'h40;
 buffer[1506] = 7'h40;
 buffer[1507] = 7'h40;
 buffer[1508] = 7'h40;
 buffer[1509] = 7'h40;
 buffer[1510] = 7'h40;
 buffer[1511] = 7'h40;
 buffer[1512] = 7'h40;
 buffer[1513] = 7'h40;
 buffer[1514] = 7'h40;
 buffer[1515] = 7'h40;
 buffer[1516] = 7'h40;
 buffer[1517] = 7'h40;
 buffer[1518] = 7'h40;
 buffer[1519] = 7'h40;
 buffer[1520] = 7'h40;
 buffer[1521] = 7'h40;
 buffer[1522] = 7'h40;
 buffer[1523] = 7'h40;
 buffer[1524] = 7'h40;
 buffer[1525] = 7'h40;
 buffer[1526] = 7'h40;
 buffer[1527] = 7'h40;
 buffer[1528] = 7'h40;
 buffer[1529] = 7'h40;
 buffer[1530] = 7'h40;
 buffer[1531] = 7'h40;
 buffer[1532] = 7'h40;
 buffer[1533] = 7'h40;
 buffer[1534] = 7'h40;
 buffer[1535] = 7'h40;
 buffer[1536] = 7'h40;
 buffer[1537] = 7'h40;
 buffer[1538] = 7'h40;
 buffer[1539] = 7'h40;
 buffer[1540] = 7'h40;
 buffer[1541] = 7'h40;
 buffer[1542] = 7'h40;
 buffer[1543] = 7'h40;
 buffer[1544] = 7'h40;
 buffer[1545] = 7'h40;
 buffer[1546] = 7'h40;
 buffer[1547] = 7'h40;
 buffer[1548] = 7'h40;
 buffer[1549] = 7'h40;
 buffer[1550] = 7'h40;
 buffer[1551] = 7'h40;
 buffer[1552] = 7'h40;
 buffer[1553] = 7'h40;
 buffer[1554] = 7'h40;
 buffer[1555] = 7'h40;
 buffer[1556] = 7'h40;
 buffer[1557] = 7'h40;
 buffer[1558] = 7'h40;
 buffer[1559] = 7'h40;
 buffer[1560] = 7'h40;
 buffer[1561] = 7'h40;
 buffer[1562] = 7'h40;
 buffer[1563] = 7'h40;
 buffer[1564] = 7'h40;
 buffer[1565] = 7'h40;
 buffer[1566] = 7'h40;
 buffer[1567] = 7'h40;
 buffer[1568] = 7'h40;
 buffer[1569] = 7'h40;
 buffer[1570] = 7'h40;
 buffer[1571] = 7'h40;
 buffer[1572] = 7'h40;
 buffer[1573] = 7'h40;
 buffer[1574] = 7'h40;
 buffer[1575] = 7'h40;
 buffer[1576] = 7'h40;
 buffer[1577] = 7'h40;
 buffer[1578] = 7'h40;
 buffer[1579] = 7'h40;
 buffer[1580] = 7'h40;
 buffer[1581] = 7'h40;
 buffer[1582] = 7'h40;
 buffer[1583] = 7'h40;
 buffer[1584] = 7'h40;
 buffer[1585] = 7'h40;
 buffer[1586] = 7'h40;
 buffer[1587] = 7'h40;
 buffer[1588] = 7'h40;
 buffer[1589] = 7'h40;
 buffer[1590] = 7'h40;
 buffer[1591] = 7'h40;
 buffer[1592] = 7'h40;
 buffer[1593] = 7'h40;
 buffer[1594] = 7'h40;
 buffer[1595] = 7'h40;
 buffer[1596] = 7'h40;
 buffer[1597] = 7'h40;
 buffer[1598] = 7'h40;
 buffer[1599] = 7'h40;
 buffer[1600] = 7'h40;
 buffer[1601] = 7'h40;
 buffer[1602] = 7'h40;
 buffer[1603] = 7'h40;
 buffer[1604] = 7'h40;
 buffer[1605] = 7'h40;
 buffer[1606] = 7'h40;
 buffer[1607] = 7'h40;
 buffer[1608] = 7'h40;
 buffer[1609] = 7'h40;
 buffer[1610] = 7'h40;
 buffer[1611] = 7'h40;
 buffer[1612] = 7'h40;
 buffer[1613] = 7'h40;
 buffer[1614] = 7'h40;
 buffer[1615] = 7'h40;
 buffer[1616] = 7'h40;
 buffer[1617] = 7'h40;
 buffer[1618] = 7'h40;
 buffer[1619] = 7'h40;
 buffer[1620] = 7'h40;
 buffer[1621] = 7'h40;
 buffer[1622] = 7'h40;
 buffer[1623] = 7'h40;
 buffer[1624] = 7'h40;
 buffer[1625] = 7'h40;
 buffer[1626] = 7'h40;
 buffer[1627] = 7'h40;
 buffer[1628] = 7'h40;
 buffer[1629] = 7'h40;
 buffer[1630] = 7'h40;
 buffer[1631] = 7'h40;
 buffer[1632] = 7'h40;
 buffer[1633] = 7'h40;
 buffer[1634] = 7'h40;
 buffer[1635] = 7'h40;
 buffer[1636] = 7'h40;
 buffer[1637] = 7'h40;
 buffer[1638] = 7'h40;
 buffer[1639] = 7'h40;
 buffer[1640] = 7'h40;
 buffer[1641] = 7'h40;
 buffer[1642] = 7'h40;
 buffer[1643] = 7'h40;
 buffer[1644] = 7'h40;
 buffer[1645] = 7'h40;
 buffer[1646] = 7'h40;
 buffer[1647] = 7'h40;
 buffer[1648] = 7'h40;
 buffer[1649] = 7'h40;
 buffer[1650] = 7'h40;
 buffer[1651] = 7'h40;
 buffer[1652] = 7'h40;
 buffer[1653] = 7'h40;
 buffer[1654] = 7'h40;
 buffer[1655] = 7'h40;
 buffer[1656] = 7'h40;
 buffer[1657] = 7'h40;
 buffer[1658] = 7'h40;
 buffer[1659] = 7'h40;
 buffer[1660] = 7'h40;
 buffer[1661] = 7'h40;
 buffer[1662] = 7'h40;
 buffer[1663] = 7'h40;
 buffer[1664] = 7'h40;
 buffer[1665] = 7'h40;
 buffer[1666] = 7'h40;
 buffer[1667] = 7'h40;
 buffer[1668] = 7'h40;
 buffer[1669] = 7'h40;
 buffer[1670] = 7'h40;
 buffer[1671] = 7'h40;
 buffer[1672] = 7'h40;
 buffer[1673] = 7'h40;
 buffer[1674] = 7'h40;
 buffer[1675] = 7'h40;
 buffer[1676] = 7'h40;
 buffer[1677] = 7'h40;
 buffer[1678] = 7'h40;
 buffer[1679] = 7'h40;
 buffer[1680] = 7'h40;
 buffer[1681] = 7'h40;
 buffer[1682] = 7'h40;
 buffer[1683] = 7'h40;
 buffer[1684] = 7'h40;
 buffer[1685] = 7'h40;
 buffer[1686] = 7'h40;
 buffer[1687] = 7'h40;
 buffer[1688] = 7'h40;
 buffer[1689] = 7'h40;
 buffer[1690] = 7'h40;
 buffer[1691] = 7'h40;
 buffer[1692] = 7'h40;
 buffer[1693] = 7'h40;
 buffer[1694] = 7'h40;
 buffer[1695] = 7'h40;
 buffer[1696] = 7'h40;
 buffer[1697] = 7'h40;
 buffer[1698] = 7'h40;
 buffer[1699] = 7'h40;
 buffer[1700] = 7'h40;
 buffer[1701] = 7'h40;
 buffer[1702] = 7'h40;
 buffer[1703] = 7'h40;
 buffer[1704] = 7'h40;
 buffer[1705] = 7'h40;
 buffer[1706] = 7'h40;
 buffer[1707] = 7'h40;
 buffer[1708] = 7'h40;
 buffer[1709] = 7'h40;
 buffer[1710] = 7'h40;
 buffer[1711] = 7'h40;
 buffer[1712] = 7'h40;
 buffer[1713] = 7'h40;
 buffer[1714] = 7'h40;
 buffer[1715] = 7'h40;
 buffer[1716] = 7'h40;
 buffer[1717] = 7'h40;
 buffer[1718] = 7'h40;
 buffer[1719] = 7'h40;
 buffer[1720] = 7'h40;
 buffer[1721] = 7'h40;
 buffer[1722] = 7'h40;
 buffer[1723] = 7'h40;
 buffer[1724] = 7'h40;
 buffer[1725] = 7'h40;
 buffer[1726] = 7'h40;
 buffer[1727] = 7'h40;
 buffer[1728] = 7'h40;
 buffer[1729] = 7'h40;
 buffer[1730] = 7'h40;
 buffer[1731] = 7'h40;
 buffer[1732] = 7'h40;
 buffer[1733] = 7'h40;
 buffer[1734] = 7'h40;
 buffer[1735] = 7'h40;
 buffer[1736] = 7'h40;
 buffer[1737] = 7'h40;
 buffer[1738] = 7'h40;
 buffer[1739] = 7'h40;
 buffer[1740] = 7'h40;
 buffer[1741] = 7'h40;
 buffer[1742] = 7'h40;
 buffer[1743] = 7'h40;
 buffer[1744] = 7'h40;
 buffer[1745] = 7'h40;
 buffer[1746] = 7'h40;
 buffer[1747] = 7'h40;
 buffer[1748] = 7'h40;
 buffer[1749] = 7'h40;
 buffer[1750] = 7'h40;
 buffer[1751] = 7'h40;
 buffer[1752] = 7'h40;
 buffer[1753] = 7'h40;
 buffer[1754] = 7'h40;
 buffer[1755] = 7'h40;
 buffer[1756] = 7'h40;
 buffer[1757] = 7'h40;
 buffer[1758] = 7'h40;
 buffer[1759] = 7'h40;
 buffer[1760] = 7'h40;
 buffer[1761] = 7'h40;
 buffer[1762] = 7'h40;
 buffer[1763] = 7'h40;
 buffer[1764] = 7'h40;
 buffer[1765] = 7'h40;
 buffer[1766] = 7'h40;
 buffer[1767] = 7'h40;
 buffer[1768] = 7'h40;
 buffer[1769] = 7'h40;
 buffer[1770] = 7'h40;
 buffer[1771] = 7'h40;
 buffer[1772] = 7'h40;
 buffer[1773] = 7'h40;
 buffer[1774] = 7'h40;
 buffer[1775] = 7'h40;
 buffer[1776] = 7'h40;
 buffer[1777] = 7'h40;
 buffer[1778] = 7'h40;
 buffer[1779] = 7'h40;
 buffer[1780] = 7'h40;
 buffer[1781] = 7'h40;
 buffer[1782] = 7'h40;
 buffer[1783] = 7'h40;
 buffer[1784] = 7'h40;
 buffer[1785] = 7'h40;
 buffer[1786] = 7'h40;
 buffer[1787] = 7'h40;
 buffer[1788] = 7'h40;
 buffer[1789] = 7'h40;
 buffer[1790] = 7'h40;
 buffer[1791] = 7'h40;
 buffer[1792] = 7'h40;
 buffer[1793] = 7'h40;
 buffer[1794] = 7'h40;
 buffer[1795] = 7'h40;
 buffer[1796] = 7'h40;
 buffer[1797] = 7'h40;
 buffer[1798] = 7'h40;
 buffer[1799] = 7'h40;
 buffer[1800] = 7'h40;
 buffer[1801] = 7'h40;
 buffer[1802] = 7'h40;
 buffer[1803] = 7'h40;
 buffer[1804] = 7'h40;
 buffer[1805] = 7'h40;
 buffer[1806] = 7'h40;
 buffer[1807] = 7'h40;
 buffer[1808] = 7'h40;
 buffer[1809] = 7'h40;
 buffer[1810] = 7'h40;
 buffer[1811] = 7'h40;
 buffer[1812] = 7'h40;
 buffer[1813] = 7'h40;
 buffer[1814] = 7'h40;
 buffer[1815] = 7'h40;
 buffer[1816] = 7'h40;
 buffer[1817] = 7'h40;
 buffer[1818] = 7'h40;
 buffer[1819] = 7'h40;
 buffer[1820] = 7'h40;
 buffer[1821] = 7'h40;
 buffer[1822] = 7'h40;
 buffer[1823] = 7'h40;
 buffer[1824] = 7'h40;
 buffer[1825] = 7'h40;
 buffer[1826] = 7'h40;
 buffer[1827] = 7'h40;
 buffer[1828] = 7'h40;
 buffer[1829] = 7'h40;
 buffer[1830] = 7'h40;
 buffer[1831] = 7'h40;
 buffer[1832] = 7'h40;
 buffer[1833] = 7'h40;
 buffer[1834] = 7'h40;
 buffer[1835] = 7'h40;
 buffer[1836] = 7'h40;
 buffer[1837] = 7'h40;
 buffer[1838] = 7'h40;
 buffer[1839] = 7'h40;
 buffer[1840] = 7'h40;
 buffer[1841] = 7'h40;
 buffer[1842] = 7'h40;
 buffer[1843] = 7'h40;
 buffer[1844] = 7'h40;
 buffer[1845] = 7'h40;
 buffer[1846] = 7'h40;
 buffer[1847] = 7'h40;
 buffer[1848] = 7'h40;
 buffer[1849] = 7'h40;
 buffer[1850] = 7'h40;
 buffer[1851] = 7'h40;
 buffer[1852] = 7'h40;
 buffer[1853] = 7'h40;
 buffer[1854] = 7'h40;
 buffer[1855] = 7'h40;
 buffer[1856] = 7'h40;
 buffer[1857] = 7'h40;
 buffer[1858] = 7'h40;
 buffer[1859] = 7'h40;
 buffer[1860] = 7'h40;
 buffer[1861] = 7'h40;
 buffer[1862] = 7'h40;
 buffer[1863] = 7'h40;
 buffer[1864] = 7'h40;
 buffer[1865] = 7'h40;
 buffer[1866] = 7'h40;
 buffer[1867] = 7'h40;
 buffer[1868] = 7'h40;
 buffer[1869] = 7'h40;
 buffer[1870] = 7'h40;
 buffer[1871] = 7'h40;
 buffer[1872] = 7'h40;
 buffer[1873] = 7'h40;
 buffer[1874] = 7'h40;
 buffer[1875] = 7'h40;
 buffer[1876] = 7'h40;
 buffer[1877] = 7'h40;
 buffer[1878] = 7'h40;
 buffer[1879] = 7'h40;
 buffer[1880] = 7'h40;
 buffer[1881] = 7'h40;
 buffer[1882] = 7'h40;
 buffer[1883] = 7'h40;
 buffer[1884] = 7'h40;
 buffer[1885] = 7'h40;
 buffer[1886] = 7'h40;
 buffer[1887] = 7'h40;
 buffer[1888] = 7'h40;
 buffer[1889] = 7'h40;
 buffer[1890] = 7'h40;
 buffer[1891] = 7'h40;
 buffer[1892] = 7'h40;
 buffer[1893] = 7'h40;
 buffer[1894] = 7'h40;
 buffer[1895] = 7'h40;
 buffer[1896] = 7'h40;
 buffer[1897] = 7'h40;
 buffer[1898] = 7'h40;
 buffer[1899] = 7'h40;
 buffer[1900] = 7'h40;
 buffer[1901] = 7'h40;
 buffer[1902] = 7'h40;
 buffer[1903] = 7'h40;
 buffer[1904] = 7'h40;
 buffer[1905] = 7'h40;
 buffer[1906] = 7'h40;
 buffer[1907] = 7'h40;
 buffer[1908] = 7'h40;
 buffer[1909] = 7'h40;
 buffer[1910] = 7'h40;
 buffer[1911] = 7'h40;
 buffer[1912] = 7'h40;
 buffer[1913] = 7'h40;
 buffer[1914] = 7'h40;
 buffer[1915] = 7'h40;
 buffer[1916] = 7'h40;
 buffer[1917] = 7'h40;
 buffer[1918] = 7'h40;
 buffer[1919] = 7'h40;
 buffer[1920] = 7'h40;
 buffer[1921] = 7'h40;
 buffer[1922] = 7'h40;
 buffer[1923] = 7'h40;
 buffer[1924] = 7'h40;
 buffer[1925] = 7'h40;
 buffer[1926] = 7'h40;
 buffer[1927] = 7'h40;
 buffer[1928] = 7'h40;
 buffer[1929] = 7'h40;
 buffer[1930] = 7'h40;
 buffer[1931] = 7'h40;
 buffer[1932] = 7'h40;
 buffer[1933] = 7'h40;
 buffer[1934] = 7'h40;
 buffer[1935] = 7'h40;
 buffer[1936] = 7'h40;
 buffer[1937] = 7'h40;
 buffer[1938] = 7'h40;
 buffer[1939] = 7'h40;
 buffer[1940] = 7'h40;
 buffer[1941] = 7'h40;
 buffer[1942] = 7'h40;
 buffer[1943] = 7'h40;
 buffer[1944] = 7'h40;
 buffer[1945] = 7'h40;
 buffer[1946] = 7'h40;
 buffer[1947] = 7'h40;
 buffer[1948] = 7'h40;
 buffer[1949] = 7'h40;
 buffer[1950] = 7'h40;
 buffer[1951] = 7'h40;
 buffer[1952] = 7'h40;
 buffer[1953] = 7'h40;
 buffer[1954] = 7'h40;
 buffer[1955] = 7'h40;
 buffer[1956] = 7'h40;
 buffer[1957] = 7'h40;
 buffer[1958] = 7'h40;
 buffer[1959] = 7'h40;
 buffer[1960] = 7'h40;
 buffer[1961] = 7'h40;
 buffer[1962] = 7'h40;
 buffer[1963] = 7'h40;
 buffer[1964] = 7'h40;
 buffer[1965] = 7'h40;
 buffer[1966] = 7'h40;
 buffer[1967] = 7'h40;
 buffer[1968] = 7'h40;
 buffer[1969] = 7'h40;
 buffer[1970] = 7'h40;
 buffer[1971] = 7'h40;
 buffer[1972] = 7'h40;
 buffer[1973] = 7'h40;
 buffer[1974] = 7'h40;
 buffer[1975] = 7'h40;
 buffer[1976] = 7'h40;
 buffer[1977] = 7'h40;
 buffer[1978] = 7'h40;
 buffer[1979] = 7'h40;
 buffer[1980] = 7'h40;
 buffer[1981] = 7'h40;
 buffer[1982] = 7'h40;
 buffer[1983] = 7'h40;
 buffer[1984] = 7'h40;
 buffer[1985] = 7'h40;
 buffer[1986] = 7'h40;
 buffer[1987] = 7'h40;
 buffer[1988] = 7'h40;
 buffer[1989] = 7'h40;
 buffer[1990] = 7'h40;
 buffer[1991] = 7'h40;
 buffer[1992] = 7'h40;
 buffer[1993] = 7'h40;
 buffer[1994] = 7'h40;
 buffer[1995] = 7'h40;
 buffer[1996] = 7'h40;
 buffer[1997] = 7'h40;
 buffer[1998] = 7'h40;
 buffer[1999] = 7'h40;
 buffer[2000] = 7'h40;
 buffer[2001] = 7'h40;
 buffer[2002] = 7'h40;
 buffer[2003] = 7'h40;
 buffer[2004] = 7'h40;
 buffer[2005] = 7'h40;
 buffer[2006] = 7'h40;
 buffer[2007] = 7'h40;
 buffer[2008] = 7'h40;
 buffer[2009] = 7'h40;
 buffer[2010] = 7'h40;
 buffer[2011] = 7'h40;
 buffer[2012] = 7'h40;
 buffer[2013] = 7'h40;
 buffer[2014] = 7'h40;
 buffer[2015] = 7'h40;
 buffer[2016] = 7'h40;
 buffer[2017] = 7'h40;
 buffer[2018] = 7'h40;
 buffer[2019] = 7'h40;
 buffer[2020] = 7'h40;
 buffer[2021] = 7'h40;
 buffer[2022] = 7'h40;
 buffer[2023] = 7'h40;
 buffer[2024] = 7'h40;
 buffer[2025] = 7'h40;
 buffer[2026] = 7'h40;
 buffer[2027] = 7'h40;
 buffer[2028] = 7'h40;
 buffer[2029] = 7'h40;
 buffer[2030] = 7'h40;
 buffer[2031] = 7'h40;
 buffer[2032] = 7'h40;
 buffer[2033] = 7'h40;
 buffer[2034] = 7'h40;
 buffer[2035] = 7'h40;
 buffer[2036] = 7'h40;
 buffer[2037] = 7'h40;
 buffer[2038] = 7'h40;
 buffer[2039] = 7'h40;
 buffer[2040] = 7'h40;
 buffer[2041] = 7'h40;
 buffer[2042] = 7'h40;
 buffer[2043] = 7'h40;
 buffer[2044] = 7'h40;
 buffer[2045] = 7'h40;
 buffer[2046] = 7'h40;
 buffer[2047] = 7'h40;
 buffer[2048] = 7'h40;
 buffer[2049] = 7'h40;
 buffer[2050] = 7'h40;
 buffer[2051] = 7'h40;
 buffer[2052] = 7'h40;
 buffer[2053] = 7'h40;
 buffer[2054] = 7'h40;
 buffer[2055] = 7'h40;
 buffer[2056] = 7'h40;
 buffer[2057] = 7'h40;
 buffer[2058] = 7'h40;
 buffer[2059] = 7'h40;
 buffer[2060] = 7'h40;
 buffer[2061] = 7'h40;
 buffer[2062] = 7'h40;
 buffer[2063] = 7'h40;
 buffer[2064] = 7'h40;
 buffer[2065] = 7'h40;
 buffer[2066] = 7'h40;
 buffer[2067] = 7'h40;
 buffer[2068] = 7'h40;
 buffer[2069] = 7'h40;
 buffer[2070] = 7'h40;
 buffer[2071] = 7'h40;
 buffer[2072] = 7'h40;
 buffer[2073] = 7'h40;
 buffer[2074] = 7'h40;
 buffer[2075] = 7'h40;
 buffer[2076] = 7'h40;
 buffer[2077] = 7'h40;
 buffer[2078] = 7'h40;
 buffer[2079] = 7'h40;
 buffer[2080] = 7'h40;
 buffer[2081] = 7'h40;
 buffer[2082] = 7'h40;
 buffer[2083] = 7'h40;
 buffer[2084] = 7'h40;
 buffer[2085] = 7'h40;
 buffer[2086] = 7'h40;
 buffer[2087] = 7'h40;
 buffer[2088] = 7'h40;
 buffer[2089] = 7'h40;
 buffer[2090] = 7'h40;
 buffer[2091] = 7'h40;
 buffer[2092] = 7'h40;
 buffer[2093] = 7'h40;
 buffer[2094] = 7'h40;
 buffer[2095] = 7'h40;
 buffer[2096] = 7'h40;
 buffer[2097] = 7'h40;
 buffer[2098] = 7'h40;
 buffer[2099] = 7'h40;
 buffer[2100] = 7'h40;
 buffer[2101] = 7'h40;
 buffer[2102] = 7'h40;
 buffer[2103] = 7'h40;
 buffer[2104] = 7'h40;
 buffer[2105] = 7'h40;
 buffer[2106] = 7'h40;
 buffer[2107] = 7'h40;
 buffer[2108] = 7'h40;
 buffer[2109] = 7'h40;
 buffer[2110] = 7'h40;
 buffer[2111] = 7'h40;
 buffer[2112] = 7'h40;
 buffer[2113] = 7'h40;
 buffer[2114] = 7'h40;
 buffer[2115] = 7'h40;
 buffer[2116] = 7'h40;
 buffer[2117] = 7'h40;
 buffer[2118] = 7'h40;
 buffer[2119] = 7'h40;
 buffer[2120] = 7'h40;
 buffer[2121] = 7'h40;
 buffer[2122] = 7'h40;
 buffer[2123] = 7'h40;
 buffer[2124] = 7'h40;
 buffer[2125] = 7'h40;
 buffer[2126] = 7'h40;
 buffer[2127] = 7'h40;
 buffer[2128] = 7'h40;
 buffer[2129] = 7'h40;
 buffer[2130] = 7'h40;
 buffer[2131] = 7'h40;
 buffer[2132] = 7'h40;
 buffer[2133] = 7'h40;
 buffer[2134] = 7'h40;
 buffer[2135] = 7'h40;
 buffer[2136] = 7'h40;
 buffer[2137] = 7'h40;
 buffer[2138] = 7'h40;
 buffer[2139] = 7'h40;
 buffer[2140] = 7'h40;
 buffer[2141] = 7'h40;
 buffer[2142] = 7'h40;
 buffer[2143] = 7'h40;
 buffer[2144] = 7'h40;
 buffer[2145] = 7'h40;
 buffer[2146] = 7'h40;
 buffer[2147] = 7'h40;
 buffer[2148] = 7'h40;
 buffer[2149] = 7'h40;
 buffer[2150] = 7'h40;
 buffer[2151] = 7'h40;
 buffer[2152] = 7'h40;
 buffer[2153] = 7'h40;
 buffer[2154] = 7'h40;
 buffer[2155] = 7'h40;
 buffer[2156] = 7'h40;
 buffer[2157] = 7'h40;
 buffer[2158] = 7'h40;
 buffer[2159] = 7'h40;
 buffer[2160] = 7'h40;
 buffer[2161] = 7'h40;
 buffer[2162] = 7'h40;
 buffer[2163] = 7'h40;
 buffer[2164] = 7'h40;
 buffer[2165] = 7'h40;
 buffer[2166] = 7'h40;
 buffer[2167] = 7'h40;
 buffer[2168] = 7'h40;
 buffer[2169] = 7'h40;
 buffer[2170] = 7'h40;
 buffer[2171] = 7'h40;
 buffer[2172] = 7'h40;
 buffer[2173] = 7'h40;
 buffer[2174] = 7'h40;
 buffer[2175] = 7'h40;
 buffer[2176] = 7'h40;
 buffer[2177] = 7'h40;
 buffer[2178] = 7'h40;
 buffer[2179] = 7'h40;
 buffer[2180] = 7'h40;
 buffer[2181] = 7'h40;
 buffer[2182] = 7'h40;
 buffer[2183] = 7'h40;
 buffer[2184] = 7'h40;
 buffer[2185] = 7'h40;
 buffer[2186] = 7'h40;
 buffer[2187] = 7'h40;
 buffer[2188] = 7'h40;
 buffer[2189] = 7'h40;
 buffer[2190] = 7'h40;
 buffer[2191] = 7'h40;
 buffer[2192] = 7'h40;
 buffer[2193] = 7'h40;
 buffer[2194] = 7'h40;
 buffer[2195] = 7'h40;
 buffer[2196] = 7'h40;
 buffer[2197] = 7'h40;
 buffer[2198] = 7'h40;
 buffer[2199] = 7'h40;
 buffer[2200] = 7'h40;
 buffer[2201] = 7'h40;
 buffer[2202] = 7'h40;
 buffer[2203] = 7'h40;
 buffer[2204] = 7'h40;
 buffer[2205] = 7'h40;
 buffer[2206] = 7'h40;
 buffer[2207] = 7'h40;
 buffer[2208] = 7'h40;
 buffer[2209] = 7'h40;
 buffer[2210] = 7'h40;
 buffer[2211] = 7'h40;
 buffer[2212] = 7'h40;
 buffer[2213] = 7'h40;
 buffer[2214] = 7'h40;
 buffer[2215] = 7'h40;
 buffer[2216] = 7'h40;
 buffer[2217] = 7'h40;
 buffer[2218] = 7'h40;
 buffer[2219] = 7'h40;
 buffer[2220] = 7'h40;
 buffer[2221] = 7'h40;
 buffer[2222] = 7'h40;
 buffer[2223] = 7'h40;
 buffer[2224] = 7'h40;
 buffer[2225] = 7'h40;
 buffer[2226] = 7'h40;
 buffer[2227] = 7'h40;
 buffer[2228] = 7'h40;
 buffer[2229] = 7'h40;
 buffer[2230] = 7'h40;
 buffer[2231] = 7'h40;
 buffer[2232] = 7'h40;
 buffer[2233] = 7'h40;
 buffer[2234] = 7'h40;
 buffer[2235] = 7'h40;
 buffer[2236] = 7'h40;
 buffer[2237] = 7'h40;
 buffer[2238] = 7'h40;
 buffer[2239] = 7'h40;
 buffer[2240] = 7'h40;
 buffer[2241] = 7'h40;
 buffer[2242] = 7'h40;
 buffer[2243] = 7'h40;
 buffer[2244] = 7'h40;
 buffer[2245] = 7'h40;
 buffer[2246] = 7'h40;
 buffer[2247] = 7'h40;
 buffer[2248] = 7'h40;
 buffer[2249] = 7'h40;
 buffer[2250] = 7'h40;
 buffer[2251] = 7'h40;
 buffer[2252] = 7'h40;
 buffer[2253] = 7'h40;
 buffer[2254] = 7'h40;
 buffer[2255] = 7'h40;
 buffer[2256] = 7'h40;
 buffer[2257] = 7'h40;
 buffer[2258] = 7'h40;
 buffer[2259] = 7'h40;
 buffer[2260] = 7'h40;
 buffer[2261] = 7'h40;
 buffer[2262] = 7'h40;
 buffer[2263] = 7'h40;
 buffer[2264] = 7'h40;
 buffer[2265] = 7'h40;
 buffer[2266] = 7'h40;
 buffer[2267] = 7'h40;
 buffer[2268] = 7'h40;
 buffer[2269] = 7'h40;
 buffer[2270] = 7'h40;
 buffer[2271] = 7'h40;
 buffer[2272] = 7'h40;
 buffer[2273] = 7'h40;
 buffer[2274] = 7'h40;
 buffer[2275] = 7'h40;
 buffer[2276] = 7'h40;
 buffer[2277] = 7'h40;
 buffer[2278] = 7'h40;
 buffer[2279] = 7'h40;
 buffer[2280] = 7'h40;
 buffer[2281] = 7'h40;
 buffer[2282] = 7'h40;
 buffer[2283] = 7'h40;
 buffer[2284] = 7'h40;
 buffer[2285] = 7'h40;
 buffer[2286] = 7'h40;
 buffer[2287] = 7'h40;
 buffer[2288] = 7'h40;
 buffer[2289] = 7'h40;
 buffer[2290] = 7'h40;
 buffer[2291] = 7'h40;
 buffer[2292] = 7'h40;
 buffer[2293] = 7'h40;
 buffer[2294] = 7'h40;
 buffer[2295] = 7'h40;
 buffer[2296] = 7'h40;
 buffer[2297] = 7'h40;
 buffer[2298] = 7'h40;
 buffer[2299] = 7'h40;
 buffer[2300] = 7'h40;
 buffer[2301] = 7'h40;
 buffer[2302] = 7'h40;
 buffer[2303] = 7'h40;
 buffer[2304] = 7'h40;
 buffer[2305] = 7'h40;
 buffer[2306] = 7'h40;
 buffer[2307] = 7'h40;
 buffer[2308] = 7'h40;
 buffer[2309] = 7'h40;
 buffer[2310] = 7'h40;
 buffer[2311] = 7'h40;
 buffer[2312] = 7'h40;
 buffer[2313] = 7'h40;
 buffer[2314] = 7'h40;
 buffer[2315] = 7'h40;
 buffer[2316] = 7'h40;
 buffer[2317] = 7'h40;
 buffer[2318] = 7'h40;
 buffer[2319] = 7'h40;
 buffer[2320] = 7'h40;
 buffer[2321] = 7'h40;
 buffer[2322] = 7'h40;
 buffer[2323] = 7'h40;
 buffer[2324] = 7'h40;
 buffer[2325] = 7'h40;
 buffer[2326] = 7'h40;
 buffer[2327] = 7'h40;
 buffer[2328] = 7'h40;
 buffer[2329] = 7'h40;
 buffer[2330] = 7'h40;
 buffer[2331] = 7'h40;
 buffer[2332] = 7'h40;
 buffer[2333] = 7'h40;
 buffer[2334] = 7'h40;
 buffer[2335] = 7'h40;
 buffer[2336] = 7'h40;
 buffer[2337] = 7'h40;
 buffer[2338] = 7'h40;
 buffer[2339] = 7'h40;
 buffer[2340] = 7'h40;
 buffer[2341] = 7'h40;
 buffer[2342] = 7'h40;
 buffer[2343] = 7'h40;
 buffer[2344] = 7'h40;
 buffer[2345] = 7'h40;
 buffer[2346] = 7'h40;
 buffer[2347] = 7'h40;
 buffer[2348] = 7'h40;
 buffer[2349] = 7'h40;
 buffer[2350] = 7'h40;
 buffer[2351] = 7'h40;
 buffer[2352] = 7'h40;
 buffer[2353] = 7'h40;
 buffer[2354] = 7'h40;
 buffer[2355] = 7'h40;
 buffer[2356] = 7'h40;
 buffer[2357] = 7'h40;
 buffer[2358] = 7'h40;
 buffer[2359] = 7'h40;
 buffer[2360] = 7'h40;
 buffer[2361] = 7'h40;
 buffer[2362] = 7'h40;
 buffer[2363] = 7'h40;
 buffer[2364] = 7'h40;
 buffer[2365] = 7'h40;
 buffer[2366] = 7'h40;
 buffer[2367] = 7'h40;
 buffer[2368] = 7'h40;
 buffer[2369] = 7'h40;
 buffer[2370] = 7'h40;
 buffer[2371] = 7'h40;
 buffer[2372] = 7'h40;
 buffer[2373] = 7'h40;
 buffer[2374] = 7'h40;
 buffer[2375] = 7'h40;
 buffer[2376] = 7'h40;
 buffer[2377] = 7'h40;
 buffer[2378] = 7'h40;
 buffer[2379] = 7'h40;
 buffer[2380] = 7'h40;
 buffer[2381] = 7'h40;
 buffer[2382] = 7'h40;
 buffer[2383] = 7'h40;
 buffer[2384] = 7'h40;
 buffer[2385] = 7'h40;
 buffer[2386] = 7'h40;
 buffer[2387] = 7'h40;
 buffer[2388] = 7'h40;
 buffer[2389] = 7'h40;
 buffer[2390] = 7'h40;
 buffer[2391] = 7'h40;
 buffer[2392] = 7'h40;
 buffer[2393] = 7'h40;
 buffer[2394] = 7'h40;
 buffer[2395] = 7'h40;
 buffer[2396] = 7'h40;
 buffer[2397] = 7'h40;
 buffer[2398] = 7'h40;
 buffer[2399] = 7'h40;
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
output  [2:0] out_tpu_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [7:0] _w_mem_characterGenerator8x16_rdata;
wire  [7:0] _w_mem_character_rdata0;
wire  [7:0] _w_mem_character_rdata1;
wire  [5:0] _w_mem_foreground_rdata0;
wire  [5:0] _w_mem_foreground_rdata1;
wire  [6:0] _w_mem_background_rdata0;
wire  [6:0] _w_mem_background_rdata1;
wire  [7:0] _c_character_wdata0;
assign _c_character_wdata0 = 0;
wire  [5:0] _c_foreground_wdata0;
assign _c_foreground_wdata0 = 0;
wire  [6:0] _c_background_wdata0;
assign _c_background_wdata0 = 0;
wire  [7:0] _w_xcharacterpos;
wire  [11:0] _w_ycharacterpos;
wire  [2:0] _w_xincharacter;
wire  [3:0] _w_yincharacter;
wire  [0:0] _w_characterpixel;

reg  [11:0] _d_characterGenerator8x16_addr;
reg  [11:0] _q_characterGenerator8x16_addr;
reg  [0:0] _d_character_wenable0;
reg  [0:0] _q_character_wenable0;
reg  [11:0] _d_character_addr0;
reg  [11:0] _q_character_addr0;
reg  [0:0] _d_character_wenable1;
reg  [0:0] _q_character_wenable1;
reg  [7:0] _d_character_wdata1;
reg  [7:0] _q_character_wdata1;
reg  [11:0] _d_character_addr1;
reg  [11:0] _q_character_addr1;
reg  [0:0] _d_foreground_wenable0;
reg  [0:0] _q_foreground_wenable0;
reg  [11:0] _d_foreground_addr0;
reg  [11:0] _q_foreground_addr0;
reg  [0:0] _d_foreground_wenable1;
reg  [0:0] _q_foreground_wenable1;
reg  [5:0] _d_foreground_wdata1;
reg  [5:0] _q_foreground_wdata1;
reg  [11:0] _d_foreground_addr1;
reg  [11:0] _q_foreground_addr1;
reg  [0:0] _d_background_wenable0;
reg  [0:0] _q_background_wenable0;
reg  [11:0] _d_background_addr0;
reg  [11:0] _q_background_addr0;
reg  [0:0] _d_background_wenable1;
reg  [0:0] _q_background_wenable1;
reg  [6:0] _d_background_wdata1;
reg  [6:0] _q_background_wdata1;
reg  [11:0] _d_background_addr1;
reg  [11:0] _q_background_addr1;
reg  [6:0] _d_tpu_active_x;
reg  [6:0] _q_tpu_active_x;
reg  [4:0] _d_tpu_active_y;
reg  [4:0] _q_tpu_active_y;
reg  [1:0] _d_pix_red,_q_pix_red;
reg  [1:0] _d_pix_green,_q_pix_green;
reg  [1:0] _d_pix_blue,_q_pix_blue;
reg  [0:0] _d_character_map_display,_q_character_map_display;
reg  [2:0] _d_tpu_active,_q_tpu_active;
reg  [1:0] _d_index,_q_index;
assign out_pix_red = _d_pix_red;
assign out_pix_green = _d_pix_green;
assign out_pix_blue = _d_pix_blue;
assign out_character_map_display = _d_character_map_display;
assign out_tpu_active = _q_tpu_active;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_characterGenerator8x16_addr <= 0;
_q_character_wenable0 <= 0;
_q_character_addr0 <= 0;
_q_character_wenable1 <= 0;
_q_character_wdata1 <= 0;
_q_character_addr1 <= 0;
_q_foreground_wenable0 <= 0;
_q_foreground_addr0 <= 0;
_q_foreground_wenable1 <= 0;
_q_foreground_wdata1 <= 0;
_q_foreground_addr1 <= 0;
_q_background_wenable0 <= 0;
_q_background_addr0 <= 0;
_q_background_wenable1 <= 0;
_q_background_wdata1 <= 0;
_q_background_addr1 <= 0;
_q_tpu_active_x <= 0;
_q_tpu_active_y <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_characterGenerator8x16_addr <= _d_characterGenerator8x16_addr;
_q_character_wenable0 <= _d_character_wenable0;
_q_character_addr0 <= _d_character_addr0;
_q_character_wenable1 <= _d_character_wenable1;
_q_character_wdata1 <= _d_character_wdata1;
_q_character_addr1 <= _d_character_addr1;
_q_foreground_wenable0 <= _d_foreground_wenable0;
_q_foreground_addr0 <= _d_foreground_addr0;
_q_foreground_wenable1 <= _d_foreground_wenable1;
_q_foreground_wdata1 <= _d_foreground_wdata1;
_q_foreground_addr1 <= _d_foreground_addr1;
_q_background_wenable0 <= _d_background_wenable0;
_q_background_addr0 <= _d_background_addr0;
_q_background_wenable1 <= _d_background_wenable1;
_q_background_wdata1 <= _d_background_wdata1;
_q_background_addr1 <= _d_background_addr1;
_q_tpu_active_x <= _d_tpu_active_x;
_q_tpu_active_y <= _d_tpu_active_y;
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
M_character_map_mem_character __mem__character(
.clock0(clock),
.clock1(clock),
.in_character_wenable0(_d_character_wenable0),
.in_character_wdata0(_c_character_wdata0),
.in_character_addr0(_d_character_addr0),
.in_character_wenable1(_d_character_wenable1),
.in_character_wdata1(_d_character_wdata1),
.in_character_addr1(_d_character_addr1),
.out_character_rdata0(_w_mem_character_rdata0),
.out_character_rdata1(_w_mem_character_rdata1)
);
M_character_map_mem_foreground __mem__foreground(
.clock0(clock),
.clock1(clock),
.in_foreground_wenable0(_d_foreground_wenable0),
.in_foreground_wdata0(_c_foreground_wdata0),
.in_foreground_addr0(_d_foreground_addr0),
.in_foreground_wenable1(_d_foreground_wenable1),
.in_foreground_wdata1(_d_foreground_wdata1),
.in_foreground_addr1(_d_foreground_addr1),
.out_foreground_rdata0(_w_mem_foreground_rdata0),
.out_foreground_rdata1(_w_mem_foreground_rdata1)
);
M_character_map_mem_background __mem__background(
.clock0(clock),
.clock1(clock),
.in_background_wenable0(_d_background_wenable0),
.in_background_wdata0(_c_background_wdata0),
.in_background_addr0(_d_background_addr0),
.in_background_wenable1(_d_background_wenable1),
.in_background_wdata1(_d_background_wdata1),
.in_background_addr1(_d_background_addr1),
.out_background_rdata0(_w_mem_background_rdata0),
.out_background_rdata1(_w_mem_background_rdata1)
);

assign _w_characterpixel = _w_mem_characterGenerator8x16_rdata[7-_w_xincharacter+:1];
assign _w_yincharacter = (in_pix_y)&15;
assign _w_ycharacterpos = ((in_pix_vblank?0:in_pix_y)>>4)*80;
assign _w_xincharacter = (in_pix_x)&7;
assign _w_xcharacterpos = (in_pix_active?(in_pix_x<640)?in_pix_x+2:0:0)>>3;

always @* begin
_d_characterGenerator8x16_addr = _q_characterGenerator8x16_addr;
_d_character_wenable0 = _q_character_wenable0;
_d_character_addr0 = _q_character_addr0;
_d_character_wenable1 = _q_character_wenable1;
_d_character_wdata1 = _q_character_wdata1;
_d_character_addr1 = _q_character_addr1;
_d_foreground_wenable0 = _q_foreground_wenable0;
_d_foreground_addr0 = _q_foreground_addr0;
_d_foreground_wenable1 = _q_foreground_wenable1;
_d_foreground_wdata1 = _q_foreground_wdata1;
_d_foreground_addr1 = _q_foreground_addr1;
_d_background_wenable0 = _q_background_wenable0;
_d_background_addr0 = _q_background_addr0;
_d_background_wenable1 = _q_background_wenable1;
_d_background_wdata1 = _q_background_wdata1;
_d_background_addr1 = _q_background_addr1;
_d_tpu_active_x = _q_tpu_active_x;
_d_tpu_active_y = _q_tpu_active_y;
_d_pix_red = _q_pix_red;
_d_pix_green = _q_pix_green;
_d_pix_blue = _q_pix_blue;
_d_character_map_display = _q_character_map_display;
_d_tpu_active = _q_tpu_active;
_d_index = _q_index;
// _always_pre
_d_character_addr0 = _w_xcharacterpos+_w_ycharacterpos;
_d_character_wenable0 = 0;
_d_foreground_addr0 = _w_xcharacterpos+_w_ycharacterpos;
_d_foreground_wenable0 = 0;
_d_background_addr0 = _w_xcharacterpos+_w_ycharacterpos;
_d_background_wenable0 = 0;
_d_character_wenable1 = 1;
_d_background_wenable1 = 1;
_d_foreground_wenable1 = 1;
_d_characterGenerator8x16_addr = _w_mem_character_rdata0*16+_w_yincharacter;
_d_character_map_display = in_pix_active&&((_w_characterpixel)||(~_w_mem_background_rdata0[6+:1]));
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
_d_characterGenerator8x16_addr = 0;
_d_character_wenable0 = 0;
_d_character_addr0 = 0;
_d_character_wenable1 = 0;
_d_character_wdata1 = 0;
_d_character_addr1 = 0;
_d_foreground_wenable0 = 0;
_d_foreground_addr0 = 0;
_d_foreground_wenable1 = 0;
_d_foreground_wdata1 = 0;
_d_foreground_addr1 = 0;
_d_background_wenable0 = 0;
_d_background_addr0 = 0;
_d_background_wenable1 = 0;
_d_background_wdata1 = 0;
_d_background_addr1 = 0;
_d_tpu_active_x = 0;
_d_tpu_active_y = 0;
// --
_d_character_addr1 = 0;
_d_character_wdata1 = 0;
_d_background_addr1 = 0;
_d_background_wdata1 = 64;
_d_foreground_addr1 = 0;
_d_foreground_wdata1 = 0;
_d_index = 1;
end
1: begin
// __while__block_1
if (1) begin
// __block_2
// __block_4
if (_d_character_map_display) begin
// __block_5
// __block_7
_d_pix_red = _w_characterpixel?_w_mem_foreground_rdata0[4+:2]:_w_mem_background_rdata0[4+:2];
_d_pix_green = _w_characterpixel?_w_mem_foreground_rdata0[2+:2]:_w_mem_background_rdata0[2+:2];
_d_pix_blue = _w_characterpixel?_w_mem_foreground_rdata0[0+:2]:_w_mem_background_rdata0[0+:2];
// __block_8
end else begin
// __block_6
end
// __block_9
  case (_q_tpu_active)
  1: begin
// __block_11_case
// __block_12
_d_character_wdata1 = 0;
_d_background_wdata1 = 64;
_d_foreground_wdata1 = 0;
_d_tpu_active_x = 0;
_d_tpu_active_y = 0;
_d_tpu_active = 2;
// __block_13
  end
  2: begin
// __block_14_case
// __block_15
_d_character_addr1 = _q_tpu_active_x+_q_tpu_active_y*80;
_d_background_addr1 = _q_tpu_active_x+_q_tpu_active_y*80;
_d_foreground_addr1 = _q_tpu_active_x+_q_tpu_active_y*80;
_d_tpu_active_y = (_q_tpu_active_x==79)?_q_tpu_active_y+1:_q_tpu_active_y;
_d_tpu_active_x = (_q_tpu_active_x==79)?0:_q_tpu_active_x+1;
_d_tpu_active = (_d_tpu_active_x==79)&&(_d_tpu_active_y==29)?3:2;
// __block_16
  end
  3: begin
// __block_17_case
// __block_18
_d_tpu_active_x = 0;
_d_tpu_active_y = 0;
_d_tpu_active = 0;
// __block_19
  end
  default: begin
// __block_20_case
// __block_21
  case (in_tpu_write)
  1: begin
// __block_23_case
// __block_24
_d_tpu_active_x = in_tpu_x;
_d_tpu_active_y = in_tpu_y;
// __block_25
  end
  2: begin
// __block_26_case
// __block_27
_d_character_addr1 = _q_tpu_active_x+_q_tpu_active_y*80;
_d_background_addr1 = _q_tpu_active_x+_q_tpu_active_y*80;
_d_foreground_addr1 = _q_tpu_active_x+_q_tpu_active_y*80;
_d_character_wdata1 = in_tpu_character;
_d_background_wdata1 = in_tpu_background;
_d_foreground_wdata1 = in_tpu_foreground;
_d_tpu_active_y = (_q_tpu_active_x==79)?(_q_tpu_active_y==29)?0:_q_tpu_active_y+1:_q_tpu_active_y;
_d_tpu_active_x = (_q_tpu_active_x==79)?0:_q_tpu_active_x+1;
// __block_28
  end
  3: begin
// __block_29_case
// __block_30
_d_tpu_active = 1;
// __block_31
  end
endcase
// __block_22
// __block_32
  end
endcase
// __block_10
// __block_33
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of character_map
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_bitmap_mem_bitmap_alpha(
input      [0:0]             in_bitmap_alpha_wenable0,
input       [0:0]     in_bitmap_alpha_wdata0,
input      [18:0]                in_bitmap_alpha_addr0,
input      [0:0]             in_bitmap_alpha_wenable1,
input      [0:0]                 in_bitmap_alpha_wdata1,
input      [18:0]                in_bitmap_alpha_addr1,
output reg  [0:0]     out_bitmap_alpha_rdata0,
output reg  [0:0]     out_bitmap_alpha_rdata1,
input      clock0,
input      clock1
);
reg  [0:0] buffer[307199:0];
always @(posedge clock0) begin
  if (in_bitmap_alpha_wenable0) begin
    buffer[in_bitmap_alpha_addr0] <= in_bitmap_alpha_wdata0;
  end else begin
    out_bitmap_alpha_rdata0 <= buffer[in_bitmap_alpha_addr0];
  end
end
always @(posedge clock1) begin
  if (in_bitmap_alpha_wenable1) begin
    buffer[in_bitmap_alpha_addr1] <= in_bitmap_alpha_wdata1;
  end else begin
    out_bitmap_alpha_rdata1 <= buffer[in_bitmap_alpha_addr1];
  end
end

endmodule

module M_bitmap_mem_bitmap_red(
input      [0:0]             in_bitmap_red_wenable0,
input       [1:0]     in_bitmap_red_wdata0,
input      [18:0]                in_bitmap_red_addr0,
input      [0:0]             in_bitmap_red_wenable1,
input      [1:0]                 in_bitmap_red_wdata1,
input      [18:0]                in_bitmap_red_addr1,
output reg  [1:0]     out_bitmap_red_rdata0,
output reg  [1:0]     out_bitmap_red_rdata1,
input      clock0,
input      clock1
);
reg  [1:0] buffer[307199:0];
always @(posedge clock0) begin
  if (in_bitmap_red_wenable0) begin
    buffer[in_bitmap_red_addr0] <= in_bitmap_red_wdata0;
  end else begin
    out_bitmap_red_rdata0 <= buffer[in_bitmap_red_addr0];
  end
end
always @(posedge clock1) begin
  if (in_bitmap_red_wenable1) begin
    buffer[in_bitmap_red_addr1] <= in_bitmap_red_wdata1;
  end else begin
    out_bitmap_red_rdata1 <= buffer[in_bitmap_red_addr1];
  end
end

endmodule

module M_bitmap_mem_bitmap_green(
input      [0:0]             in_bitmap_green_wenable0,
input       [1:0]     in_bitmap_green_wdata0,
input      [18:0]                in_bitmap_green_addr0,
input      [0:0]             in_bitmap_green_wenable1,
input      [1:0]                 in_bitmap_green_wdata1,
input      [18:0]                in_bitmap_green_addr1,
output reg  [1:0]     out_bitmap_green_rdata0,
output reg  [1:0]     out_bitmap_green_rdata1,
input      clock0,
input      clock1
);
reg  [1:0] buffer[307199:0];
always @(posedge clock0) begin
  if (in_bitmap_green_wenable0) begin
    buffer[in_bitmap_green_addr0] <= in_bitmap_green_wdata0;
  end else begin
    out_bitmap_green_rdata0 <= buffer[in_bitmap_green_addr0];
  end
end
always @(posedge clock1) begin
  if (in_bitmap_green_wenable1) begin
    buffer[in_bitmap_green_addr1] <= in_bitmap_green_wdata1;
  end else begin
    out_bitmap_green_rdata1 <= buffer[in_bitmap_green_addr1];
  end
end

endmodule

module M_bitmap_mem_bitmap_blue(
input      [0:0]             in_bitmap_blue_wenable0,
input       [1:0]     in_bitmap_blue_wdata0,
input      [18:0]                in_bitmap_blue_addr0,
input      [0:0]             in_bitmap_blue_wenable1,
input      [1:0]                 in_bitmap_blue_wdata1,
input      [18:0]                in_bitmap_blue_addr1,
output reg  [1:0]     out_bitmap_blue_rdata0,
output reg  [1:0]     out_bitmap_blue_rdata1,
input      clock0,
input      clock1
);
reg  [1:0] buffer[307199:0];
always @(posedge clock0) begin
  if (in_bitmap_blue_wenable0) begin
    buffer[in_bitmap_blue_addr0] <= in_bitmap_blue_wdata0;
  end else begin
    out_bitmap_blue_rdata0 <= buffer[in_bitmap_blue_addr0];
  end
end
always @(posedge clock1) begin
  if (in_bitmap_blue_wenable1) begin
    buffer[in_bitmap_blue_addr1] <= in_bitmap_blue_wdata1;
  end else begin
    out_bitmap_blue_rdata1 <= buffer[in_bitmap_blue_addr1];
  end
end

endmodule

module M_bitmap (
in_pix_x,
in_pix_y,
in_pix_active,
in_pix_vblank,
in_bitmap_x_write,
in_bitmap_y_write,
in_bitmap_colour_write,
in_bitmap_write,
in_bitmap_x_read,
in_bitmap_y_read,
out_pix_red,
out_pix_green,
out_pix_blue,
out_bitmap_display,
out_bitmap_colour_read,
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
input signed [10:0] in_bitmap_x_write;
input signed [10:0] in_bitmap_y_write;
input  [6:0] in_bitmap_colour_write;
input  [0:0] in_bitmap_write;
input signed [15:0] in_bitmap_x_read;
input signed [15:0] in_bitmap_y_read;
output  [1:0] out_pix_red;
output  [1:0] out_pix_green;
output  [1:0] out_pix_blue;
output  [0:0] out_bitmap_display;
output  [6:0] out_bitmap_colour_read;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [0:0] _w_mem_bitmap_alpha_rdata0;
wire  [0:0] _w_mem_bitmap_alpha_rdata1;
wire  [1:0] _w_mem_bitmap_red_rdata0;
wire  [1:0] _w_mem_bitmap_red_rdata1;
wire  [1:0] _w_mem_bitmap_green_rdata0;
wire  [1:0] _w_mem_bitmap_green_rdata1;
wire  [1:0] _w_mem_bitmap_blue_rdata0;
wire  [1:0] _w_mem_bitmap_blue_rdata1;
wire  [0:0] _c_bitmap_alpha_wdata0;
assign _c_bitmap_alpha_wdata0 = 0;
wire  [1:0] _c_bitmap_red_wdata0;
assign _c_bitmap_red_wdata0 = 0;
wire  [1:0] _c_bitmap_green_wdata0;
assign _c_bitmap_green_wdata0 = 0;
wire  [1:0] _c_bitmap_blue_wdata0;
assign _c_bitmap_blue_wdata0 = 0;
wire  [0:0] _w_write_pixel;

reg  [0:0] _d_bitmap_alpha_wenable0;
reg  [0:0] _q_bitmap_alpha_wenable0;
reg  [18:0] _d_bitmap_alpha_addr0;
reg  [18:0] _q_bitmap_alpha_addr0;
reg  [0:0] _d_bitmap_alpha_wenable1;
reg  [0:0] _q_bitmap_alpha_wenable1;
reg  [0:0] _d_bitmap_alpha_wdata1;
reg  [0:0] _q_bitmap_alpha_wdata1;
reg  [18:0] _d_bitmap_alpha_addr1;
reg  [18:0] _q_bitmap_alpha_addr1;
reg  [0:0] _d_bitmap_red_wenable0;
reg  [0:0] _q_bitmap_red_wenable0;
reg  [18:0] _d_bitmap_red_addr0;
reg  [18:0] _q_bitmap_red_addr0;
reg  [0:0] _d_bitmap_red_wenable1;
reg  [0:0] _q_bitmap_red_wenable1;
reg  [1:0] _d_bitmap_red_wdata1;
reg  [1:0] _q_bitmap_red_wdata1;
reg  [18:0] _d_bitmap_red_addr1;
reg  [18:0] _q_bitmap_red_addr1;
reg  [0:0] _d_bitmap_green_wenable0;
reg  [0:0] _q_bitmap_green_wenable0;
reg  [18:0] _d_bitmap_green_addr0;
reg  [18:0] _q_bitmap_green_addr0;
reg  [0:0] _d_bitmap_green_wenable1;
reg  [0:0] _q_bitmap_green_wenable1;
reg  [1:0] _d_bitmap_green_wdata1;
reg  [1:0] _q_bitmap_green_wdata1;
reg  [18:0] _d_bitmap_green_addr1;
reg  [18:0] _q_bitmap_green_addr1;
reg  [0:0] _d_bitmap_blue_wenable0;
reg  [0:0] _q_bitmap_blue_wenable0;
reg  [18:0] _d_bitmap_blue_addr0;
reg  [18:0] _q_bitmap_blue_addr0;
reg  [0:0] _d_bitmap_blue_wenable1;
reg  [0:0] _q_bitmap_blue_wenable1;
reg  [1:0] _d_bitmap_blue_wdata1;
reg  [1:0] _q_bitmap_blue_wdata1;
reg  [18:0] _d_bitmap_blue_addr1;
reg  [18:0] _q_bitmap_blue_addr1;
reg  [1:0] _d_pix_red,_q_pix_red;
reg  [1:0] _d_pix_green,_q_pix_green;
reg  [1:0] _d_pix_blue,_q_pix_blue;
reg  [0:0] _d_bitmap_display,_q_bitmap_display;
reg  [6:0] _d_bitmap_colour_read,_q_bitmap_colour_read;
reg  [1:0] _d_index,_q_index;
assign out_pix_red = _d_pix_red;
assign out_pix_green = _d_pix_green;
assign out_pix_blue = _d_pix_blue;
assign out_bitmap_display = _d_bitmap_display;
assign out_bitmap_colour_read = _q_bitmap_colour_read;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_bitmap_alpha_wenable0 <= 0;
_q_bitmap_alpha_addr0 <= 0;
_q_bitmap_alpha_wenable1 <= 0;
_q_bitmap_alpha_wdata1 <= 0;
_q_bitmap_alpha_addr1 <= 0;
_q_bitmap_red_wenable0 <= 0;
_q_bitmap_red_addr0 <= 0;
_q_bitmap_red_wenable1 <= 0;
_q_bitmap_red_wdata1 <= 0;
_q_bitmap_red_addr1 <= 0;
_q_bitmap_green_wenable0 <= 0;
_q_bitmap_green_addr0 <= 0;
_q_bitmap_green_wenable1 <= 0;
_q_bitmap_green_wdata1 <= 0;
_q_bitmap_green_addr1 <= 0;
_q_bitmap_blue_wenable0 <= 0;
_q_bitmap_blue_addr0 <= 0;
_q_bitmap_blue_wenable1 <= 0;
_q_bitmap_blue_wdata1 <= 0;
_q_bitmap_blue_addr1 <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_bitmap_alpha_wenable0 <= _d_bitmap_alpha_wenable0;
_q_bitmap_alpha_addr0 <= _d_bitmap_alpha_addr0;
_q_bitmap_alpha_wenable1 <= _d_bitmap_alpha_wenable1;
_q_bitmap_alpha_wdata1 <= _d_bitmap_alpha_wdata1;
_q_bitmap_alpha_addr1 <= _d_bitmap_alpha_addr1;
_q_bitmap_red_wenable0 <= _d_bitmap_red_wenable0;
_q_bitmap_red_addr0 <= _d_bitmap_red_addr0;
_q_bitmap_red_wenable1 <= _d_bitmap_red_wenable1;
_q_bitmap_red_wdata1 <= _d_bitmap_red_wdata1;
_q_bitmap_red_addr1 <= _d_bitmap_red_addr1;
_q_bitmap_green_wenable0 <= _d_bitmap_green_wenable0;
_q_bitmap_green_addr0 <= _d_bitmap_green_addr0;
_q_bitmap_green_wenable1 <= _d_bitmap_green_wenable1;
_q_bitmap_green_wdata1 <= _d_bitmap_green_wdata1;
_q_bitmap_green_addr1 <= _d_bitmap_green_addr1;
_q_bitmap_blue_wenable0 <= _d_bitmap_blue_wenable0;
_q_bitmap_blue_addr0 <= _d_bitmap_blue_addr0;
_q_bitmap_blue_wenable1 <= _d_bitmap_blue_wenable1;
_q_bitmap_blue_wdata1 <= _d_bitmap_blue_wdata1;
_q_bitmap_blue_addr1 <= _d_bitmap_blue_addr1;
_q_pix_red <= _d_pix_red;
_q_pix_green <= _d_pix_green;
_q_pix_blue <= _d_pix_blue;
_q_bitmap_display <= _d_bitmap_display;
_q_bitmap_colour_read <= _d_bitmap_colour_read;
_q_index <= _d_index;
  end
end


M_bitmap_mem_bitmap_alpha __mem__bitmap_alpha(
.clock0(clock),
.clock1(clock),
.in_bitmap_alpha_wenable0(_d_bitmap_alpha_wenable0),
.in_bitmap_alpha_wdata0(_c_bitmap_alpha_wdata0),
.in_bitmap_alpha_addr0(_d_bitmap_alpha_addr0),
.in_bitmap_alpha_wenable1(_d_bitmap_alpha_wenable1),
.in_bitmap_alpha_wdata1(_d_bitmap_alpha_wdata1),
.in_bitmap_alpha_addr1(_d_bitmap_alpha_addr1),
.out_bitmap_alpha_rdata0(_w_mem_bitmap_alpha_rdata0),
.out_bitmap_alpha_rdata1(_w_mem_bitmap_alpha_rdata1)
);
M_bitmap_mem_bitmap_red __mem__bitmap_red(
.clock0(clock),
.clock1(clock),
.in_bitmap_red_wenable0(_d_bitmap_red_wenable0),
.in_bitmap_red_wdata0(_c_bitmap_red_wdata0),
.in_bitmap_red_addr0(_d_bitmap_red_addr0),
.in_bitmap_red_wenable1(_d_bitmap_red_wenable1),
.in_bitmap_red_wdata1(_d_bitmap_red_wdata1),
.in_bitmap_red_addr1(_d_bitmap_red_addr1),
.out_bitmap_red_rdata0(_w_mem_bitmap_red_rdata0),
.out_bitmap_red_rdata1(_w_mem_bitmap_red_rdata1)
);
M_bitmap_mem_bitmap_green __mem__bitmap_green(
.clock0(clock),
.clock1(clock),
.in_bitmap_green_wenable0(_d_bitmap_green_wenable0),
.in_bitmap_green_wdata0(_c_bitmap_green_wdata0),
.in_bitmap_green_addr0(_d_bitmap_green_addr0),
.in_bitmap_green_wenable1(_d_bitmap_green_wenable1),
.in_bitmap_green_wdata1(_d_bitmap_green_wdata1),
.in_bitmap_green_addr1(_d_bitmap_green_addr1),
.out_bitmap_green_rdata0(_w_mem_bitmap_green_rdata0),
.out_bitmap_green_rdata1(_w_mem_bitmap_green_rdata1)
);
M_bitmap_mem_bitmap_blue __mem__bitmap_blue(
.clock0(clock),
.clock1(clock),
.in_bitmap_blue_wenable0(_d_bitmap_blue_wenable0),
.in_bitmap_blue_wdata0(_c_bitmap_blue_wdata0),
.in_bitmap_blue_addr0(_d_bitmap_blue_addr0),
.in_bitmap_blue_wenable1(_d_bitmap_blue_wenable1),
.in_bitmap_blue_wdata1(_d_bitmap_blue_wdata1),
.in_bitmap_blue_addr1(_d_bitmap_blue_addr1),
.out_bitmap_blue_rdata0(_w_mem_bitmap_blue_rdata0),
.out_bitmap_blue_rdata1(_w_mem_bitmap_blue_rdata1)
);

assign _w_write_pixel = (in_bitmap_x_write>=0)&&(in_bitmap_x_write<640)&&(in_bitmap_y_write>=0)&&(in_bitmap_y_write<480)&&(in_bitmap_write==1);

always @* begin
_d_bitmap_alpha_wenable0 = _q_bitmap_alpha_wenable0;
_d_bitmap_alpha_addr0 = _q_bitmap_alpha_addr0;
_d_bitmap_alpha_wenable1 = _q_bitmap_alpha_wenable1;
_d_bitmap_alpha_wdata1 = _q_bitmap_alpha_wdata1;
_d_bitmap_alpha_addr1 = _q_bitmap_alpha_addr1;
_d_bitmap_red_wenable0 = _q_bitmap_red_wenable0;
_d_bitmap_red_addr0 = _q_bitmap_red_addr0;
_d_bitmap_red_wenable1 = _q_bitmap_red_wenable1;
_d_bitmap_red_wdata1 = _q_bitmap_red_wdata1;
_d_bitmap_red_addr1 = _q_bitmap_red_addr1;
_d_bitmap_green_wenable0 = _q_bitmap_green_wenable0;
_d_bitmap_green_addr0 = _q_bitmap_green_addr0;
_d_bitmap_green_wenable1 = _q_bitmap_green_wenable1;
_d_bitmap_green_wdata1 = _q_bitmap_green_wdata1;
_d_bitmap_green_addr1 = _q_bitmap_green_addr1;
_d_bitmap_blue_wenable0 = _q_bitmap_blue_wenable0;
_d_bitmap_blue_addr0 = _q_bitmap_blue_addr0;
_d_bitmap_blue_wenable1 = _q_bitmap_blue_wenable1;
_d_bitmap_blue_wdata1 = _q_bitmap_blue_wdata1;
_d_bitmap_blue_addr1 = _q_bitmap_blue_addr1;
_d_pix_red = _q_pix_red;
_d_pix_green = _q_pix_green;
_d_pix_blue = _q_pix_blue;
_d_bitmap_display = _q_bitmap_display;
_d_bitmap_colour_read = _q_bitmap_colour_read;
_d_index = _q_index;
// _always_pre
_d_bitmap_colour_read = (in_pix_x==in_bitmap_x_read)&&(in_pix_y==in_bitmap_y_read)?{_w_mem_bitmap_alpha_rdata0,_w_mem_bitmap_red_rdata0,_w_mem_bitmap_green_rdata0,_w_mem_bitmap_blue_rdata0}:_q_bitmap_colour_read;
_d_bitmap_alpha_addr0 = (in_pix_active?in_pix_x+1:0)+(in_pix_vblank?0:in_pix_y*640);
_d_bitmap_alpha_wenable0 = 0;
_d_bitmap_red_addr0 = (in_pix_active?in_pix_x+1:0)+(in_pix_vblank?0:in_pix_y*640);
_d_bitmap_red_wenable0 = 0;
_d_bitmap_green_addr0 = (in_pix_active?in_pix_x+1:0)+(in_pix_vblank?0:in_pix_y*640);
_d_bitmap_green_wenable0 = 0;
_d_bitmap_blue_addr0 = (in_pix_active?in_pix_x+1:0)+(in_pix_vblank?0:in_pix_y*640);
_d_bitmap_blue_wenable0 = 0;
_d_bitmap_alpha_wenable1 = 1;
_d_bitmap_red_wenable1 = 1;
_d_bitmap_green_wenable1 = 1;
_d_bitmap_blue_wenable1 = 1;
_d_bitmap_display = in_pix_active&&~_w_mem_bitmap_alpha_rdata0;
if (_w_write_pixel) begin
// __block_1
// __block_3
_d_bitmap_alpha_addr1 = in_bitmap_x_write+in_bitmap_y_write*640;
_d_bitmap_alpha_wdata1 = in_bitmap_colour_write[6+:1];
_d_bitmap_red_addr1 = in_bitmap_x_write+in_bitmap_y_write*640;
_d_bitmap_red_wdata1 = in_bitmap_colour_write[4+:2];
_d_bitmap_green_addr1 = in_bitmap_x_write+in_bitmap_y_write*640;
_d_bitmap_green_wdata1 = in_bitmap_colour_write[2+:2];
_d_bitmap_blue_addr1 = in_bitmap_x_write+in_bitmap_y_write*640;
_d_bitmap_blue_wdata1 = in_bitmap_colour_write[0+:2];
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
_d_bitmap_alpha_wenable0 = 0;
_d_bitmap_alpha_addr0 = 0;
_d_bitmap_alpha_wenable1 = 0;
_d_bitmap_alpha_wdata1 = 0;
_d_bitmap_alpha_addr1 = 0;
_d_bitmap_red_wenable0 = 0;
_d_bitmap_red_addr0 = 0;
_d_bitmap_red_wenable1 = 0;
_d_bitmap_red_wdata1 = 0;
_d_bitmap_red_addr1 = 0;
_d_bitmap_green_wenable0 = 0;
_d_bitmap_green_addr0 = 0;
_d_bitmap_green_wenable1 = 0;
_d_bitmap_green_wdata1 = 0;
_d_bitmap_green_addr1 = 0;
_d_bitmap_blue_wenable0 = 0;
_d_bitmap_blue_addr0 = 0;
_d_bitmap_blue_wenable1 = 0;
_d_bitmap_blue_wdata1 = 0;
_d_bitmap_blue_addr1 = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_6
if (1) begin
// __block_7
// __block_9
if (_d_bitmap_display) begin
// __block_10
// __block_12
_d_pix_red = _w_mem_bitmap_red_rdata0;
_d_pix_green = _w_mem_bitmap_green_rdata0;
_d_pix_blue = _w_mem_bitmap_blue_rdata0;
// __block_13
end else begin
// __block_11
end
// __block_14
// __block_15
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_8
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


module M_gpu_mem_blit1tilemap(
input      [0:0]             in_blit1tilemap_wenable0,
input       [15:0]     in_blit1tilemap_wdata0,
input      [7:0]                in_blit1tilemap_addr0,
input      [0:0]             in_blit1tilemap_wenable1,
input      [15:0]                 in_blit1tilemap_wdata1,
input      [7:0]                in_blit1tilemap_addr1,
output reg  [15:0]     out_blit1tilemap_rdata0,
output reg  [15:0]     out_blit1tilemap_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[255:0];
always @(posedge clock0) begin
  if (in_blit1tilemap_wenable0) begin
    buffer[in_blit1tilemap_addr0] <= in_blit1tilemap_wdata0;
  end else begin
    out_blit1tilemap_rdata0 <= buffer[in_blit1tilemap_addr0];
  end
end
always @(posedge clock1) begin
  if (in_blit1tilemap_wenable1) begin
    buffer[in_blit1tilemap_addr1] <= in_blit1tilemap_wdata1;
  end else begin
    out_blit1tilemap_rdata1 <= buffer[in_blit1tilemap_addr1];
  end
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
in_v_gpu_x,
in_v_gpu_y,
in_v_gpu_colour,
in_v_gpu_param0,
in_v_gpu_param1,
in_v_gpu_param2,
in_v_gpu_param3,
in_v_gpu_write,
in_dl_gpu_x,
in_dl_gpu_y,
in_dl_gpu_colour,
in_dl_gpu_param0,
in_dl_gpu_param1,
in_dl_gpu_param2,
in_dl_gpu_param3,
in_dl_gpu_write,
in_blit1_writer_tile,
in_blit1_writer_line,
in_blit1_writer_bitmap,
in_blit1_writer_active,
out_bitmap_x_write,
out_bitmap_y_write,
out_bitmap_colour_write,
out_bitmap_write,
out_gpu_active,
in_run,
out_done,
reset,
out_clock,
clock
);
input signed [10:0] in_gpu_x;
input signed [10:0] in_gpu_y;
input  [7:0] in_gpu_colour;
input signed [15:0] in_gpu_param0;
input signed [15:0] in_gpu_param1;
input signed [15:0] in_gpu_param2;
input signed [15:0] in_gpu_param3;
input  [3:0] in_gpu_write;
input signed [10:0] in_v_gpu_x;
input signed [10:0] in_v_gpu_y;
input  [6:0] in_v_gpu_colour;
input signed [10:0] in_v_gpu_param0;
input signed [10:0] in_v_gpu_param1;
input signed [10:0] in_v_gpu_param2;
input signed [10:0] in_v_gpu_param3;
input  [3:0] in_v_gpu_write;
input signed [10:0] in_dl_gpu_x;
input signed [10:0] in_dl_gpu_y;
input  [7:0] in_dl_gpu_colour;
input signed [15:0] in_dl_gpu_param0;
input signed [15:0] in_dl_gpu_param1;
input signed [15:0] in_dl_gpu_param2;
input signed [15:0] in_dl_gpu_param3;
input  [3:0] in_dl_gpu_write;
input  [3:0] in_blit1_writer_tile;
input  [3:0] in_blit1_writer_line;
input  [15:0] in_blit1_writer_bitmap;
input  [0:0] in_blit1_writer_active;
output signed [10:0] out_bitmap_x_write;
output signed [10:0] out_bitmap_y_write;
output  [6:0] out_bitmap_colour_write;
output  [0:0] out_bitmap_write;
output  [5:0] out_gpu_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [15:0] _w_mem_blit1tilemap_rdata0;
wire  [15:0] _w_mem_blit1tilemap_rdata1;
wire  [15:0] _c_blit1tilemap_wdata0;
assign _c_blit1tilemap_wdata0 = 0;
reg  [3:0] _t_write;

reg  [0:0] _d_blit1tilemap_wenable0;
reg  [0:0] _q_blit1tilemap_wenable0;
reg  [7:0] _d_blit1tilemap_addr0;
reg  [7:0] _q_blit1tilemap_addr0;
reg  [0:0] _d_blit1tilemap_wenable1;
reg  [0:0] _q_blit1tilemap_wenable1;
reg  [15:0] _d_blit1tilemap_wdata1;
reg  [15:0] _q_blit1tilemap_wdata1;
reg  [7:0] _d_blit1tilemap_addr1;
reg  [7:0] _q_blit1tilemap_addr1;
reg signed [10:0] _d_gpu_active_x;
reg signed [10:0] _q_gpu_active_x;
reg signed [10:0] _d_gpu_active_y;
reg signed [10:0] _q_gpu_active_y;
reg  [6:0] _d_gpu_active_colour;
reg  [6:0] _q_gpu_active_colour;
reg signed [10:0] _d_gpu_xc;
reg signed [10:0] _q_gpu_xc;
reg signed [10:0] _d_gpu_yc;
reg signed [10:0] _q_gpu_yc;
reg signed [10:0] _d_gpu_x1;
reg signed [10:0] _q_gpu_x1;
reg signed [10:0] _d_gpu_y1;
reg signed [10:0] _q_gpu_y1;
reg signed [10:0] _d_gpu_x2;
reg signed [10:0] _q_gpu_x2;
reg signed [10:0] _d_gpu_y2;
reg signed [10:0] _q_gpu_y2;
reg signed [10:0] _d_gpu_w;
reg signed [10:0] _q_gpu_w;
reg signed [10:0] _d_gpu_h;
reg signed [10:0] _q_gpu_h;
reg signed [10:0] _d_gpu_dx;
reg signed [10:0] _q_gpu_dx;
reg signed [10:0] _d_gpu_sx;
reg signed [10:0] _q_gpu_sx;
reg signed [10:0] _d_gpu_dy;
reg signed [10:0] _q_gpu_dy;
reg signed [10:0] _d_gpu_sy;
reg signed [10:0] _q_gpu_sy;
reg signed [10:0] _d_gpu_min_x;
reg signed [10:0] _q_gpu_min_x;
reg signed [10:0] _d_gpu_max_x;
reg signed [10:0] _q_gpu_max_x;
reg signed [10:0] _d_gpu_min_y;
reg signed [10:0] _q_gpu_min_y;
reg signed [10:0] _d_gpu_max_y;
reg signed [10:0] _q_gpu_max_y;
reg signed [10:0] _d_gpu_numerator;
reg signed [10:0] _q_gpu_numerator;
reg signed [10:0] _d_gpu_numerator2;
reg signed [10:0] _q_gpu_numerator2;
reg signed [10:0] _d_gpu_count;
reg signed [10:0] _q_gpu_count;
reg signed [10:0] _d_gpu_max_count;
reg signed [10:0] _q_gpu_max_count;
reg  [5:0] _d_gpu_tile;
reg  [5:0] _q_gpu_tile;
reg  [0:0] _d_w0;
reg  [0:0] _q_w0;
reg  [0:0] _d_w1;
reg  [0:0] _q_w1;
reg  [0:0] _d_w2;
reg  [0:0] _q_w2;
reg signed [10:0] _d_x;
reg signed [10:0] _q_x;
reg signed [10:0] _d_y;
reg signed [10:0] _q_y;
reg signed [15:0] _d_param0;
reg signed [15:0] _q_param0;
reg signed [15:0] _d_param1;
reg signed [15:0] _q_param1;
reg signed [15:0] _d_param2;
reg signed [15:0] _q_param2;
reg signed [15:0] _d_param3;
reg signed [15:0] _q_param3;
reg signed [10:0] _d_bitmap_x_write,_q_bitmap_x_write;
reg signed [10:0] _d_bitmap_y_write,_q_bitmap_y_write;
reg  [6:0] _d_bitmap_colour_write,_q_bitmap_colour_write;
reg  [0:0] _d_bitmap_write,_q_bitmap_write;
reg  [5:0] _d_gpu_active,_q_gpu_active;
reg  [1:0] _d_index,_q_index;
assign out_bitmap_x_write = _d_bitmap_x_write;
assign out_bitmap_y_write = _d_bitmap_y_write;
assign out_bitmap_colour_write = _d_bitmap_colour_write;
assign out_bitmap_write = _d_bitmap_write;
assign out_gpu_active = _d_gpu_active;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_blit1tilemap_wenable0 <= 0;
_q_blit1tilemap_addr0 <= 0;
_q_blit1tilemap_wenable1 <= 0;
_q_blit1tilemap_wdata1 <= 0;
_q_blit1tilemap_addr1 <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_blit1tilemap_wenable0 <= _d_blit1tilemap_wenable0;
_q_blit1tilemap_addr0 <= _d_blit1tilemap_addr0;
_q_blit1tilemap_wenable1 <= _d_blit1tilemap_wenable1;
_q_blit1tilemap_wdata1 <= _d_blit1tilemap_wdata1;
_q_blit1tilemap_addr1 <= _d_blit1tilemap_addr1;
_q_gpu_active_x <= _d_gpu_active_x;
_q_gpu_active_y <= _d_gpu_active_y;
_q_gpu_active_colour <= _d_gpu_active_colour;
_q_gpu_xc <= _d_gpu_xc;
_q_gpu_yc <= _d_gpu_yc;
_q_gpu_x1 <= _d_gpu_x1;
_q_gpu_y1 <= _d_gpu_y1;
_q_gpu_x2 <= _d_gpu_x2;
_q_gpu_y2 <= _d_gpu_y2;
_q_gpu_w <= _d_gpu_w;
_q_gpu_h <= _d_gpu_h;
_q_gpu_dx <= _d_gpu_dx;
_q_gpu_sx <= _d_gpu_sx;
_q_gpu_dy <= _d_gpu_dy;
_q_gpu_sy <= _d_gpu_sy;
_q_gpu_min_x <= _d_gpu_min_x;
_q_gpu_max_x <= _d_gpu_max_x;
_q_gpu_min_y <= _d_gpu_min_y;
_q_gpu_max_y <= _d_gpu_max_y;
_q_gpu_numerator <= _d_gpu_numerator;
_q_gpu_numerator2 <= _d_gpu_numerator2;
_q_gpu_count <= _d_gpu_count;
_q_gpu_max_count <= _d_gpu_max_count;
_q_gpu_tile <= _d_gpu_tile;
_q_w0 <= _d_w0;
_q_w1 <= _d_w1;
_q_w2 <= _d_w2;
_q_x <= _d_x;
_q_y <= _d_y;
_q_param0 <= _d_param0;
_q_param1 <= _d_param1;
_q_param2 <= _d_param2;
_q_param3 <= _d_param3;
_q_bitmap_x_write <= _d_bitmap_x_write;
_q_bitmap_y_write <= _d_bitmap_y_write;
_q_bitmap_colour_write <= _d_bitmap_colour_write;
_q_bitmap_write <= _d_bitmap_write;
_q_gpu_active <= _d_gpu_active;
_q_index <= _d_index;
  end
end


M_gpu_mem_blit1tilemap __mem__blit1tilemap(
.clock0(clock),
.clock1(clock),
.in_blit1tilemap_wenable0(_d_blit1tilemap_wenable0),
.in_blit1tilemap_wdata0(_c_blit1tilemap_wdata0),
.in_blit1tilemap_addr0(_d_blit1tilemap_addr0),
.in_blit1tilemap_wenable1(_d_blit1tilemap_wenable1),
.in_blit1tilemap_wdata1(_d_blit1tilemap_wdata1),
.in_blit1tilemap_addr1(_d_blit1tilemap_addr1),
.out_blit1tilemap_rdata0(_w_mem_blit1tilemap_rdata0),
.out_blit1tilemap_rdata1(_w_mem_blit1tilemap_rdata1)
);


always @* begin
_d_blit1tilemap_wenable0 = _q_blit1tilemap_wenable0;
_d_blit1tilemap_addr0 = _q_blit1tilemap_addr0;
_d_blit1tilemap_wenable1 = _q_blit1tilemap_wenable1;
_d_blit1tilemap_wdata1 = _q_blit1tilemap_wdata1;
_d_blit1tilemap_addr1 = _q_blit1tilemap_addr1;
_d_gpu_active_x = _q_gpu_active_x;
_d_gpu_active_y = _q_gpu_active_y;
_d_gpu_active_colour = _q_gpu_active_colour;
_d_gpu_xc = _q_gpu_xc;
_d_gpu_yc = _q_gpu_yc;
_d_gpu_x1 = _q_gpu_x1;
_d_gpu_y1 = _q_gpu_y1;
_d_gpu_x2 = _q_gpu_x2;
_d_gpu_y2 = _q_gpu_y2;
_d_gpu_w = _q_gpu_w;
_d_gpu_h = _q_gpu_h;
_d_gpu_dx = _q_gpu_dx;
_d_gpu_sx = _q_gpu_sx;
_d_gpu_dy = _q_gpu_dy;
_d_gpu_sy = _q_gpu_sy;
_d_gpu_min_x = _q_gpu_min_x;
_d_gpu_max_x = _q_gpu_max_x;
_d_gpu_min_y = _q_gpu_min_y;
_d_gpu_max_y = _q_gpu_max_y;
_d_gpu_numerator = _q_gpu_numerator;
_d_gpu_numerator2 = _q_gpu_numerator2;
_d_gpu_count = _q_gpu_count;
_d_gpu_max_count = _q_gpu_max_count;
_d_gpu_tile = _q_gpu_tile;
_d_w0 = _q_w0;
_d_w1 = _q_w1;
_d_w2 = _q_w2;
_d_x = _q_x;
_d_y = _q_y;
_d_param0 = _q_param0;
_d_param1 = _q_param1;
_d_param2 = _q_param2;
_d_param3 = _q_param3;
_d_bitmap_x_write = _q_bitmap_x_write;
_d_bitmap_y_write = _q_bitmap_y_write;
_d_bitmap_colour_write = _q_bitmap_colour_write;
_d_bitmap_write = _q_bitmap_write;
_d_gpu_active = _q_gpu_active;
_d_index = _q_index;
_t_write = 0;
// _always_pre
_d_blit1tilemap_addr0 = _q_gpu_tile*16+_q_gpu_active_y;
_d_blit1tilemap_wenable0 = 0;
_d_blit1tilemap_wenable1 = 1;
_d_bitmap_write = 0;
_d_bitmap_colour_write = _q_gpu_active_colour;
if (in_blit1_writer_active) begin
// __block_1
// __block_3
_d_blit1tilemap_addr1 = in_blit1_writer_tile*16+in_blit1_writer_line;
_d_blit1tilemap_wdata1 = in_blit1_writer_bitmap;
// __block_4
end else begin
// __block_2
end
// __block_5
if (in_dl_gpu_write!=0) begin
// __block_6
// __block_8
_d_x = in_dl_gpu_x;
_d_y = in_dl_gpu_y;
_d_gpu_active_colour = in_dl_gpu_colour;
_d_param0 = in_dl_gpu_param0;
_d_param1 = in_dl_gpu_param1;
_d_param2 = in_dl_gpu_param2;
_d_param3 = in_dl_gpu_param3;
_t_write = in_dl_gpu_write;
// __block_9
end else begin
// __block_7
// __block_10
if (in_v_gpu_write!=0) begin
// __block_11
// __block_13
_d_x = in_v_gpu_x;
_d_y = in_v_gpu_y;
_d_gpu_active_colour = in_v_gpu_colour;
_d_param0 = in_v_gpu_param0;
_d_param1 = in_v_gpu_param1;
_d_param2 = in_v_gpu_param2;
_d_param3 = in_v_gpu_param3;
_t_write = in_v_gpu_write;
// __block_14
end else begin
// __block_12
// __block_15
if (in_gpu_write!=0) begin
// __block_16
// __block_18
_d_x = in_gpu_x;
_d_y = in_gpu_y;
_d_gpu_active_colour = in_gpu_colour;
_d_param0 = in_gpu_param0;
_d_param1 = in_gpu_param1;
_d_param2 = in_gpu_param2;
_d_param3 = in_gpu_param3;
_t_write = in_gpu_write;
// __block_19
end else begin
// __block_17
// __block_20
_t_write = 0;
// __block_21
end
// __block_22
// __block_23
end
// __block_24
// __block_25
end
// __block_26
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
_d_blit1tilemap_wenable0 = 0;
_d_blit1tilemap_addr0 = 0;
_d_blit1tilemap_wenable1 = 0;
_d_blit1tilemap_wdata1 = 0;
_d_blit1tilemap_addr1 = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_27
if (1) begin
// __block_28
// __block_30
  case (_q_gpu_active)
  0: begin
// __block_32_case
// __block_33
  case (_t_write)
  1: begin
// __block_35_case
// __block_36
_d_bitmap_x_write = _d_x;
_d_bitmap_y_write = _d_y;
_d_bitmap_write = 1;
// __block_37
  end
  2: begin
// __block_38_case
// __block_39
_d_gpu_active_x = (_d_x<_d_param0)?(_d_x<0?0:_d_x):(_d_param0<0?0:_d_param0);
_d_gpu_active_y = (_d_y<_d_param1)?(_d_y<0?0:_d_y):(_d_param1<0?0:_d_param1);
_d_gpu_x2 = (_d_x<_d_param0)?(_d_x<0?0:_d_x):(_d_param0<0?0:_d_param0);
_d_gpu_x1 = (_d_x<_d_param0)?(_d_param0>639?639:_d_param0):(_d_x>639?639:_d_x);
_d_gpu_y1 = (_d_y<_d_param1)?(_d_param1>479?479:_d_param1):(_d_y>479?479:_d_y);
_d_gpu_active = 1;
// __block_40
  end
  3: begin
// __block_41_case
// __block_42
_d_gpu_active_x = (_d_x<_d_param0)?_d_x:_d_param0;
_d_gpu_active_y = (_d_x<_d_param0)?_d_y:_d_param1;
_d_gpu_dx = (_d_param0<_d_x)?_d_x-_d_param0:_d_param0-_d_x;
_d_gpu_dy = (_d_param1<_d_y)?_d_y-_d_param1:_d_param1-_d_y;
_d_gpu_sx = 1;
_d_gpu_sy = (_d_x<_d_param0)?((_d_y<_d_param1)?1:-1):((_d_y<_d_param1)?-1:1);
_d_gpu_count = 0;
_d_gpu_active = 2;
// __block_43
  end
  4: begin
// __block_44_case
// __block_45
_d_gpu_active_x = 0;
_d_gpu_active_y = ((_d_param0<0)?-_d_param0:_d_param0);
_d_gpu_xc = _d_x;
_d_gpu_yc = _d_y;
_d_gpu_numerator = 3-(2*((_d_param0<0)?-_d_param0:_d_param0));
_d_gpu_active = 6;
// __block_46
  end
  5: begin
// __block_47_case
// __block_48
_d_gpu_active_x = 0;
_d_gpu_active_y = 0;
_d_gpu_x1 = _d_x;
_d_gpu_y1 = _d_y;
_d_gpu_w = 15;
_d_gpu_h = 15;
_d_gpu_tile = _d_param0;
_d_gpu_active = 14;
// __block_49
  end
  6: begin
// __block_50_case
// __block_51
_d_gpu_active_x = 0;
_d_gpu_active_y = ((_d_param0<0)?((_d_param0<-4)?4:-_d_param0):((_d_param0<4)?4:_d_param0));
_d_gpu_xc = _d_x;
_d_gpu_yc = _d_y;
_d_gpu_count = ((_d_param0<0)?((_d_param0<-4)?4:-_d_param0):((_d_param0<4)?4:_d_param0));
_d_gpu_numerator = 3-(2*((_d_param0<0)?((_d_param0<-4)?4:-_d_param0):((_d_param0<4)?4:_d_param0)));
_d_gpu_active = 16;
// __block_52
  end
  7: begin
// __block_53_case
// __block_54
_d_gpu_active_x = _d_x;
_d_gpu_active_y = _d_y;
_d_gpu_x1 = _d_param0;
_d_gpu_y1 = _d_param1;
_d_gpu_x2 = _d_param2;
_d_gpu_y2 = _d_param3;
_d_gpu_active = 25;
// __block_55
  end
  default: begin
// __block_56_case
// __block_57
// __block_58
  end
endcase
// __block_34
// __block_59
  end
  1: begin
// __block_60_case
// __block_61
_d_bitmap_x_write = _q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_active_y;
_d_bitmap_write = (_q_gpu_active_x<=_q_gpu_x1)&&(_q_gpu_active_y<=_q_gpu_y1);
_d_gpu_active = ((_q_gpu_active_x==_q_gpu_x1)&&(_q_gpu_active_y==_q_gpu_y1))?0:1;
_d_gpu_active_x = (_q_gpu_active_x==_q_gpu_x1)?_q_gpu_x2:_q_gpu_active_x+1;
_d_gpu_active_y = (_d_gpu_active_x==_q_gpu_x1)?_q_gpu_active_y+1:_q_gpu_active_y;
// __block_62
  end
  2: begin
// __block_63_case
// __block_64
_d_gpu_numerator = (_q_gpu_dx>_q_gpu_dy)?(_q_gpu_dx>>1):-(_q_gpu_dy>>1);
_d_gpu_max_count = (_q_gpu_dx>_q_gpu_dy)?_q_gpu_dx:_q_gpu_dy;
_d_gpu_active = 3;
// __block_65
  end
  3: begin
// __block_66_case
// __block_67
_d_bitmap_x_write = _q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_active_y;
_d_bitmap_write = 1;
_d_gpu_active = (_q_gpu_count<_q_gpu_max_count)?4:0;
_d_gpu_numerator2 = _q_gpu_numerator;
// __block_68
  end
  4: begin
// __block_69_case
// __block_70
if (_q_gpu_numerator2>(-_q_gpu_dx)) begin
// __block_71
// __block_73
_d_gpu_numerator = _q_gpu_numerator-_q_gpu_dy;
_d_gpu_active_x = _q_gpu_active_x+_q_gpu_sx;
// __block_74
end else begin
// __block_72
end
// __block_75
_d_gpu_active = 5;
// __block_76
  end
  5: begin
// __block_77_case
// __block_78
if (_q_gpu_numerator2<_q_gpu_dy) begin
// __block_79
// __block_81
_d_gpu_numerator = _q_gpu_numerator+_q_gpu_dx;
_d_gpu_active_y = _q_gpu_active_y+_q_gpu_sy;
// __block_82
end else begin
// __block_80
end
// __block_83
_d_gpu_count = _q_gpu_count+1;
_d_gpu_active = 3;
// __block_84
  end
  6: begin
// __block_85_case
// __block_86
_d_bitmap_x_write = _q_gpu_xc+_q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_active_y;
_d_bitmap_write = 1;
_d_gpu_active = 7;
// __block_87
  end
  7: begin
// __block_88_case
// __block_89
_d_bitmap_x_write = _q_gpu_xc-_q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_active_y;
_d_bitmap_write = 1;
_d_gpu_active = 8;
// __block_90
  end
  8: begin
// __block_91_case
// __block_92
_d_bitmap_x_write = _q_gpu_xc+_q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_yc-_q_gpu_active_y;
_d_bitmap_write = 1;
_d_gpu_active = 9;
// __block_93
  end
  9: begin
// __block_94_case
// __block_95
_d_bitmap_x_write = _q_gpu_xc-_q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_yc-_q_gpu_active_y;
_d_bitmap_write = 1;
_d_gpu_active = 10;
// __block_96
  end
  10: begin
// __block_97_case
// __block_98
_d_bitmap_x_write = _q_gpu_xc+_q_gpu_active_y;
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_active_x;
_d_bitmap_write = 1;
_d_gpu_active = 11;
// __block_99
  end
  11: begin
// __block_100_case
// __block_101
_d_bitmap_x_write = _q_gpu_xc-_q_gpu_active_y;
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_active_x;
_d_bitmap_write = 1;
_d_gpu_active = 12;
// __block_102
  end
  12: begin
// __block_103_case
// __block_104
_d_bitmap_x_write = _q_gpu_xc+_q_gpu_active_y;
_d_bitmap_y_write = _q_gpu_yc-_q_gpu_active_x;
_d_bitmap_write = 1;
_d_gpu_active = 13;
// __block_105
  end
  13: begin
// __block_106_case
// __block_107
_d_bitmap_x_write = _q_gpu_xc-_q_gpu_active_y;
_d_bitmap_y_write = _q_gpu_yc-_q_gpu_active_x;
_d_bitmap_write = 1;
if (_q_gpu_active_y>=_q_gpu_active_x) begin
// __block_108
// __block_110
_d_gpu_active_x = _q_gpu_active_x+1;
if (_q_gpu_numerator>0) begin
// __block_111
// __block_113
_d_gpu_numerator = _q_gpu_numerator+4*(_d_gpu_active_x-_q_gpu_active_y)+10;
_d_gpu_active_y = _q_gpu_active_y-1;
// __block_114
end else begin
// __block_112
// __block_115
_d_gpu_numerator = _q_gpu_numerator+4*_d_gpu_active_x+6;
// __block_116
end
// __block_117
_d_gpu_active = 6;
// __block_118
end else begin
// __block_109
// __block_119
_d_gpu_active = 0;
// __block_120
end
// __block_121
// __block_122
  end
  14: begin
// __block_123_case
// __block_124
_d_gpu_active = 15;
// __block_125
  end
  15: begin
// __block_126_case
// __block_127
if (_w_mem_blit1tilemap_rdata0[15-_q_gpu_active_x+:1]) begin
// __block_128
// __block_130
_d_bitmap_x_write = _q_gpu_x1+_q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_y1+_q_gpu_active_y;
_d_bitmap_write = 1;
// __block_131
end else begin
// __block_129
end
// __block_132
_d_gpu_active = (_q_gpu_active_x<_q_gpu_w)?15:((_q_gpu_active_y<_q_gpu_h)?14:0);
_d_gpu_active_x = (_q_gpu_active_x<_q_gpu_w)?_q_gpu_active_x+1:0;
_d_gpu_active_y = (_d_gpu_active_x<_q_gpu_w)?_q_gpu_active_y:_q_gpu_active_y+1;
// __block_133
  end
  16: begin
// __block_134_case
// __block_135
_d_bitmap_x_write = _q_gpu_xc+_q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_count;
_d_bitmap_write = 1;
_d_gpu_active = 17;
// __block_136
  end
  17: begin
// __block_137_case
// __block_138
_d_bitmap_x_write = _q_gpu_xc+_q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_yc-_q_gpu_count;
_d_bitmap_write = 1;
_d_gpu_active = 18;
// __block_139
  end
  18: begin
// __block_140_case
// __block_141
_d_bitmap_x_write = _q_gpu_xc-_q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_count;
_d_bitmap_write = 1;
_d_gpu_active = 19;
// __block_142
  end
  19: begin
// __block_143_case
// __block_144
_d_bitmap_x_write = _q_gpu_xc-_q_gpu_active_x;
_d_bitmap_y_write = _q_gpu_yc-_q_gpu_count;
_d_bitmap_write = 1;
_d_gpu_active = 20;
// __block_145
  end
  20: begin
// __block_146_case
// __block_147
_d_bitmap_x_write = _q_gpu_xc+_q_gpu_count;
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_active_x;
_d_bitmap_write = 1;
_d_gpu_active = 21;
// __block_148
  end
  21: begin
// __block_149_case
// __block_150
_d_bitmap_x_write = _q_gpu_xc-_q_gpu_count;
_d_bitmap_y_write = _q_gpu_yc+_q_gpu_active_x;
_d_bitmap_write = 1;
_d_gpu_active = 22;
// __block_151
  end
  22: begin
// __block_152_case
// __block_153
_d_bitmap_x_write = _q_gpu_xc+_q_gpu_count;
_d_bitmap_y_write = _q_gpu_yc-_q_gpu_active_x;
_d_bitmap_write = 1;
_d_gpu_active = 23;
// __block_154
  end
  23: begin
// __block_155_case
// __block_156
_d_bitmap_x_write = _q_gpu_xc-_q_gpu_count;
_d_bitmap_y_write = _q_gpu_yc-_q_gpu_active_x;
_d_bitmap_write = 1;
_d_gpu_count = _q_gpu_count-1;
_d_gpu_active = (_d_gpu_count==0)?24:16;
// __block_157
  end
  24: begin
// __block_158_case
// __block_159
if (_q_gpu_active_y>=_q_gpu_active_x) begin
// __block_160
// __block_162
_d_gpu_active_x = _q_gpu_active_x+1;
if (_q_gpu_numerator>0) begin
// __block_163
// __block_165
_d_gpu_numerator = _q_gpu_numerator+4*(_d_gpu_active_x-_q_gpu_active_y)+10;
_d_gpu_active_y = _q_gpu_active_y-1;
_d_gpu_count = _d_gpu_active_y-1;
// __block_166
end else begin
// __block_164
// __block_167
_d_gpu_numerator = _q_gpu_numerator+4*_d_gpu_active_x+6;
_d_gpu_count = _q_gpu_active_y;
// __block_168
end
// __block_169
_d_gpu_active = 16;
// __block_170
end else begin
// __block_161
// __block_171
_d_bitmap_x_write = _q_gpu_xc;
_d_bitmap_y_write = _q_gpu_yc;
_d_bitmap_write = 1;
_d_gpu_active = 0;
// __block_172
end
// __block_173
// __block_174
  end
  25: begin
// __block_175_case
// __block_176
_d_gpu_min_x = (_q_gpu_active_x<_q_gpu_x1)?((_q_gpu_active_x<_q_gpu_x2)?_q_gpu_active_x:_q_gpu_x2):((_q_gpu_x1<_q_gpu_x2)?_q_gpu_x1:_q_gpu_x2);
_d_gpu_min_y = (_q_gpu_active_y<_q_gpu_y1)?((_q_gpu_active_y<_q_gpu_y2)?_q_gpu_active_y:_q_gpu_y2):((_q_gpu_y1<_q_gpu_y2)?_q_gpu_y1:_q_gpu_y2);
_d_gpu_max_x = (_q_gpu_active_x>_q_gpu_x1)?((_q_gpu_active_x>_q_gpu_x2)?_q_gpu_active_x:_q_gpu_x2):((_q_gpu_x1>_q_gpu_x2)?_q_gpu_x1:_q_gpu_x2);
_d_gpu_max_y = (_q_gpu_active_y>_q_gpu_y1)?((_q_gpu_active_y>_q_gpu_y2)?_q_gpu_active_y:_q_gpu_y2):((_q_gpu_y1>_q_gpu_y2)?_q_gpu_y1:_q_gpu_y2);
_d_gpu_active = 26;
// __block_177
  end
  26: begin
// __block_178_case
// __block_179
_d_gpu_min_x = (_q_gpu_min_x<0)?0:_q_gpu_min_x;
_d_gpu_min_y = (_q_gpu_min_y<0)?0:_q_gpu_min_y;
_d_gpu_max_x = (_d_gpu_min_x>639)?639:_q_gpu_max_x;
_d_gpu_max_y = (_d_gpu_min_y>479)?479:_q_gpu_max_y;
_d_gpu_active = 27;
// __block_180
  end
  27: begin
// __block_181_case
// __block_182
if (_q_gpu_y1<_q_gpu_active_y) begin
// __block_183
// __block_185
_d_gpu_active_x = _q_gpu_x1;
_d_gpu_active_y = _q_gpu_y1;
_d_gpu_x1 = _d_gpu_active_x;
_d_gpu_y1 = _d_gpu_active_y;
// __block_186
end else begin
// __block_184
end
// __block_187
_d_gpu_active = 28;
// __block_188
  end
  28: begin
// __block_189_case
// __block_190
if (_q_gpu_y2<_q_gpu_active_y) begin
// __block_191
// __block_193
_d_gpu_active_x = _q_gpu_x2;
_d_gpu_active_y = _q_gpu_y2;
_d_gpu_x2 = _d_gpu_active_x;
_d_gpu_y2 = _d_gpu_active_y;
// __block_194
end else begin
// __block_192
end
// __block_195
_d_gpu_active = 29;
// __block_196
  end
  29: begin
// __block_197_case
// __block_198
if (_q_gpu_x1<_q_gpu_x2) begin
// __block_199
// __block_201
_d_gpu_x2 = _q_gpu_x1;
_d_gpu_y2 = _q_gpu_y1;
_d_gpu_x1 = _d_gpu_x2;
_d_gpu_y1 = _d_gpu_y2;
// __block_202
end else begin
// __block_200
end
// __block_203
_d_gpu_active = 32;
// __block_204
  end
  30: begin
// __block_205_case
// __block_206
// __block_207
  end
  31: begin
// __block_208_case
// __block_209
// __block_210
  end
  32: begin
// __block_211_case
// __block_212
_d_gpu_sx = _q_gpu_min_x;
_d_gpu_sy = _q_gpu_min_y;
_d_gpu_count = 0;
_d_gpu_active = 33;
// __block_213
  end
  33: begin
// __block_214_case
// __block_215
_d_w0 = ((_q_gpu_x2-_q_gpu_x1)*(_q_gpu_sy-_q_gpu_y1)-(_q_gpu_y2-_q_gpu_y1)*(_q_gpu_sx-_q_gpu_x1))>=0;
_d_w1 = ((_q_gpu_active_x-_q_gpu_x2)*(_q_gpu_sy-_q_gpu_y2)-(_q_gpu_active_y-_q_gpu_y2)*(_q_gpu_sx-_q_gpu_x2))>=0;
_d_w2 = ((_q_gpu_x1-_q_gpu_active_x)*(_q_gpu_sy-_q_gpu_active_y)-(_q_gpu_y1-_q_gpu_active_y)*(_q_gpu_sx-_q_gpu_active_x))>=0;
_d_gpu_active = 34;
// __block_216
  end
  34: begin
// __block_217_case
// __block_218
_d_bitmap_x_write = _q_gpu_sx;
_d_bitmap_y_write = _q_gpu_sy;
_d_bitmap_write = (_q_w0&&_q_w1&&_q_w2);
_d_gpu_count = (_q_w0&&_q_w1&&_q_w2)?1:_q_gpu_count;
if ((_d_gpu_count==1)&&~(_q_w0&&_q_w1&&_q_w2)) begin
// __block_219
// __block_221
if ((_q_gpu_max_x-_q_gpu_sx)<(_q_gpu_sx-_q_gpu_min_x)) begin
// __block_222
// __block_224
_d_gpu_count = 0;
_d_gpu_sx = _q_gpu_max_x;
_d_gpu_sy = _q_gpu_sy+1;
_d_gpu_active = (_d_gpu_sy<=_q_gpu_max_y)?35:0;
// __block_225
end else begin
// __block_223
// __block_226
_d_gpu_count = 0;
_d_gpu_sx = _q_gpu_min_x;
_d_gpu_sy = _q_gpu_sy+1;
_d_gpu_active = (_d_gpu_sy<=_q_gpu_max_y)?33:0;
// __block_227
end
// __block_228
// __block_229
end else begin
// __block_220
// __block_230
if (_q_gpu_sx<_q_gpu_max_x) begin
// __block_231
// __block_233
_d_gpu_sx = _q_gpu_sx+1;
_d_gpu_active = 33;
// __block_234
end else begin
// __block_232
// __block_235
_d_gpu_count = 0;
_d_gpu_sy = _q_gpu_sy+1;
_d_gpu_active = (_d_gpu_sy<=_q_gpu_max_y)?35:0;
// __block_236
end
// __block_237
// __block_238
end
// __block_239
// __block_240
  end
  35: begin
// __block_241_case
// __block_242
_d_w0 = ((_q_gpu_x2-_q_gpu_x1)*(_q_gpu_sy-_q_gpu_y1)-(_q_gpu_y2-_q_gpu_y1)*(_q_gpu_sx-_q_gpu_x1))>=0;
_d_w1 = ((_q_gpu_active_x-_q_gpu_x2)*(_q_gpu_sy-_q_gpu_y2)-(_q_gpu_active_y-_q_gpu_y2)*(_q_gpu_sx-_q_gpu_x2))>=0;
_d_w2 = ((_q_gpu_x1-_q_gpu_active_x)*(_q_gpu_sy-_q_gpu_active_y)-(_q_gpu_y1-_q_gpu_active_y)*(_q_gpu_sx-_q_gpu_active_x))>=0;
_d_gpu_active = 36;
// __block_243
  end
  36: begin
// __block_244_case
// __block_245
_d_bitmap_x_write = _q_gpu_sx;
_d_bitmap_y_write = _q_gpu_sy;
_d_bitmap_write = (_q_w0&&_q_w1&&_q_w2);
_d_gpu_count = (_q_w0&&_q_w1&&_q_w2)?1:_q_gpu_count;
if ((_d_gpu_count==1)&&~(_q_w0&&_q_w1&&_q_w2)) begin
// __block_246
// __block_248
if ((_q_gpu_max_x-_q_gpu_sx)<(_q_gpu_sx-_q_gpu_min_x)) begin
// __block_249
// __block_251
_d_gpu_count = 0;
_d_gpu_sx = _q_gpu_max_x;
_d_gpu_sy = _q_gpu_sy+1;
_d_gpu_active = (_d_gpu_sy<=_q_gpu_max_y)?35:0;
// __block_252
end else begin
// __block_250
// __block_253
_d_gpu_count = 0;
_d_gpu_sx = _q_gpu_min_x;
_d_gpu_sy = _q_gpu_sy+1;
_d_gpu_active = (_d_gpu_sy<=_q_gpu_max_y)?33:0;
// __block_254
end
// __block_255
// __block_256
end else begin
// __block_247
// __block_257
if (_q_gpu_sx>_q_gpu_min_x) begin
// __block_258
// __block_260
_d_gpu_sx = _q_gpu_sx-1;
_d_gpu_active = 35;
// __block_261
end else begin
// __block_259
// __block_262
_d_gpu_count = 0;
_d_gpu_sy = _q_gpu_sy+1;
_d_gpu_active = (_d_gpu_sy<=_q_gpu_max_y)?33:0;
// __block_263
end
// __block_264
// __block_265
end
// __block_266
// __block_267
  end
  default: begin
// __block_268_case
// __block_269
_d_gpu_active = 0;
// __block_270
  end
endcase
// __block_31
// __block_271
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_29
_d_index = 3;
end
3: begin // end of gpu
end
default: begin 
_d_index = 3;
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
in_background_write,
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
input  [2:0] in_backgroundcolour_mode;
input  [2:0] in_background_write;
output  [1:0] out_pix_red;
output  [1:0] out_pix_green;
output  [1:0] out_pix_blue;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
reg  [2:0] _t_background_mode;
reg signed [9:0] _t_dotpos;
reg signed [1:0] _t_speed;

reg  [5:0] _d_background;
reg  [5:0] _q_background;
reg  [5:0] _d_background_alt;
reg  [5:0] _q_background_alt;
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
_q_background <= 0;
_q_background_alt <= 0;
_q_rand_x <= 0;
_q_frame <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_background <= _d_background;
_q_background_alt <= _d_background_alt;
_q_rand_x <= _d_rand_x;
_q_frame <= _d_frame;
_q_pix_red <= _d_pix_red;
_q_pix_green <= _d_pix_green;
_q_pix_blue <= _d_pix_blue;
_q_index <= _d_index;
  end
end




always @* begin
_d_background = _q_background;
_d_background_alt = _q_background_alt;
_d_rand_x = _q_rand_x;
_d_frame = _q_frame;
_d_pix_red = _q_pix_red;
_d_pix_green = _q_pix_green;
_d_pix_blue = _q_pix_blue;
_d_index = _q_index;
_t_background_mode = 0;
_t_dotpos = 0;
_t_speed = 0;
// _always_pre
_d_pix_red = 0;
_d_pix_green = 0;
_d_pix_blue = 0;
  case (in_background_write)
  1: begin
// __block_2_case
// __block_3
_d_background = in_backgroundcolour;
// __block_4
  end
  2: begin
// __block_5_case
// __block_6
_d_background_alt = in_backgroundcolour_alt;
// __block_7
  end
  3: begin
// __block_8_case
// __block_9
_t_background_mode = in_backgroundcolour_mode;
// __block_10
  end
  default: begin
// __block_11_case
// __block_12
// __block_13
  end
endcase
// __block_1
_d_frame = ((in_pix_x==639)&&(in_pix_y==470))?_q_frame+1:_q_frame;
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
_d_background = 0;
_d_background_alt = 0;
_t_dotpos = 0;
_t_speed = 0;
_d_rand_x = 0;
_d_frame = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_14
if (1) begin
// __block_15
// __block_17
  case (in_backgroundcolour_mode)
  0: begin
// __block_19_case
// __block_20
_d_pix_red = _d_background[4+:2];
_d_pix_green = _d_background[2+:2];
_d_pix_blue = _d_background[0+:2];
// __block_21
  end
  1: begin
// __block_22_case
// __block_23
  case ({in_pix_x[0+:1],in_pix_y[0+:1]})
  2'b00: begin
// __block_25_case
// __block_26
_d_pix_red = _d_background[4+:2];
_d_pix_green = _d_background[2+:2];
_d_pix_blue = _d_background[0+:2];
// __block_27
  end
  2'b01: begin
// __block_28_case
// __block_29
_d_pix_red = _d_background_alt[4+:2];
_d_pix_green = _d_background_alt[2+:2];
_d_pix_blue = _d_background_alt[0+:2];
// __block_30
  end
  2'b10: begin
// __block_31_case
// __block_32
_d_pix_red = _d_background_alt[4+:2];
_d_pix_green = _d_background_alt[2+:2];
_d_pix_blue = _d_background_alt[0+:2];
// __block_33
  end
  2'b11: begin
// __block_34_case
// __block_35
_d_pix_red = _d_background[4+:2];
_d_pix_green = _d_background[2+:2];
_d_pix_blue = _d_background[0+:2];
// __block_36
  end
endcase
// __block_24
// __block_37
  end
  2: begin
// __block_38_case
// __block_39
  case ({in_pix_x[1+:1],in_pix_y[1+:1]})
  2'b00: begin
// __block_41_case
// __block_42
_d_pix_red = _d_background[4+:2];
_d_pix_green = _d_background[2+:2];
_d_pix_blue = _d_background[0+:2];
// __block_43
  end
  2'b01: begin
// __block_44_case
// __block_45
_d_pix_red = _d_background_alt[4+:2];
_d_pix_green = _d_background_alt[2+:2];
_d_pix_blue = _d_background_alt[0+:2];
// __block_46
  end
  2'b10: begin
// __block_47_case
// __block_48
_d_pix_red = _d_background_alt[4+:2];
_d_pix_green = _d_background_alt[2+:2];
_d_pix_blue = _d_background_alt[0+:2];
// __block_49
  end
  2'b11: begin
// __block_50_case
// __block_51
_d_pix_red = _d_background[4+:2];
_d_pix_green = _d_background[2+:2];
_d_pix_blue = _d_background[0+:2];
// __block_52
  end
endcase
// __block_40
// __block_53
  end
  3: begin
// __block_54_case
// __block_55
  case ({in_pix_x[2+:1],in_pix_y[2+:1]})
  2'b00: begin
// __block_57_case
// __block_58
_d_pix_red = _d_background[4+:2];
_d_pix_green = _d_background[2+:2];
_d_pix_blue = _d_background[0+:2];
// __block_59
  end
  2'b01: begin
// __block_60_case
// __block_61
_d_pix_red = _d_background_alt[4+:2];
_d_pix_green = _d_background_alt[2+:2];
_d_pix_blue = _d_background_alt[0+:2];
// __block_62
  end
  2'b10: begin
// __block_63_case
// __block_64
_d_pix_red = _d_background_alt[4+:2];
_d_pix_green = _d_background_alt[2+:2];
_d_pix_blue = _d_background_alt[0+:2];
// __block_65
  end
  2'b11: begin
// __block_66_case
// __block_67
_d_pix_red = _d_background[4+:2];
_d_pix_green = _d_background[2+:2];
_d_pix_blue = _d_background[0+:2];
// __block_68
  end
endcase
// __block_56
// __block_69
  end
  4: begin
// __block_70_case
// __block_71
  case ({in_pix_x[3+:1],in_pix_y[3+:1]})
  2'b00: begin
// __block_73_case
// __block_74
_d_pix_red = _d_background[4+:2];
_d_pix_green = _d_background[2+:2];
_d_pix_blue = _d_background[0+:2];
// __block_75
  end
  2'b01: begin
// __block_76_case
// __block_77
_d_pix_red = _d_background_alt[4+:2];
_d_pix_green = _d_background_alt[2+:2];
_d_pix_blue = _d_background_alt[0+:2];
// __block_78
  end
  2'b10: begin
// __block_79_case
// __block_80
_d_pix_red = _d_background_alt[4+:2];
_d_pix_green = _d_background_alt[2+:2];
_d_pix_blue = _d_background_alt[0+:2];
// __block_81
  end
  2'b11: begin
// __block_82_case
// __block_83
_d_pix_red = _d_background[4+:2];
_d_pix_green = _d_background[2+:2];
_d_pix_blue = _d_background[0+:2];
// __block_84
  end
endcase
// __block_72
// __block_85
  end
  5: begin
// __block_86_case
// __block_87
  case (in_pix_y[6+:3])
  3'b000: begin
// __block_89_case
// __block_90
_d_pix_red = 2;
// __block_91
  end
  3'b001: begin
// __block_92_case
// __block_93
_d_pix_red = 3;
// __block_94
  end
  3'b010: begin
// __block_95_case
// __block_96
_d_pix_red = 3;
_d_pix_green = 2;
// __block_97
  end
  3'b011: begin
// __block_98_case
// __block_99
_d_pix_red = 3;
_d_pix_green = 3;
// __block_100
  end
  3'b100: begin
// __block_101_case
// __block_102
_d_pix_green = 3;
// __block_103
  end
  3'b101: begin
// __block_104_case
// __block_105
_d_pix_blue = 3;
// __block_106
  end
  3'b110: begin
// __block_107_case
// __block_108
_d_pix_red = 1;
_d_pix_blue = 2;
// __block_109
  end
  3'b111: begin
// __block_110_case
// __block_111
_d_pix_red = 1;
_d_pix_green = 2;
_d_pix_blue = 3;
// __block_112
  end
endcase
// __block_88
// __block_113
  end
  6: begin
// __block_114_case
// __block_115
_d_pix_red = in_staticGenerator[0+:2];
_d_pix_green = in_staticGenerator[0+:2];
_d_pix_blue = in_staticGenerator[0+:2];
// __block_116
  end
  7: begin
// __block_117_case
// __block_118
_d_rand_x = (in_pix_x==0)?1:_q_rand_x*31421+6927;
_t_speed = _d_rand_x[10+:2];
_t_dotpos = (_d_frame>>_t_speed)+_d_rand_x;
_d_pix_red = (in_pix_y==_t_dotpos)?_d_background[4+:2]:_d_background_alt[4+:2];
_d_pix_green = (in_pix_y==_t_dotpos)?_d_background[2+:2]:_d_background_alt[2+:2];
_d_pix_blue = (in_pix_y==_t_dotpos)?_d_background[0+:2]:_d_background_alt[0+:2];
// __block_119
  end
  default: begin
// __block_120_case
// __block_121
// __block_122
  end
endcase
// __block_18
// __block_123
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_16
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
input      [0:0]             in_tiles_0_wenable0,
input       [15:0]     in_tiles_0_wdata0,
input      [6:0]                in_tiles_0_addr0,
input      [0:0]             in_tiles_0_wenable1,
input      [15:0]                 in_tiles_0_wdata1,
input      [6:0]                in_tiles_0_addr1,
output reg  [15:0]     out_tiles_0_rdata0,
output reg  [15:0]     out_tiles_0_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_0_wenable0) begin
    buffer[in_tiles_0_addr0] <= in_tiles_0_wdata0;
  end else begin
    out_tiles_0_rdata0 <= buffer[in_tiles_0_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_0_wenable1) begin
    buffer[in_tiles_0_addr1] <= in_tiles_0_wdata1;
  end else begin
    out_tiles_0_rdata1 <= buffer[in_tiles_0_addr1];
  end
end

endmodule

module M_sprite_layer_mem_tiles_1(
input      [0:0]             in_tiles_1_wenable0,
input       [15:0]     in_tiles_1_wdata0,
input      [6:0]                in_tiles_1_addr0,
input      [0:0]             in_tiles_1_wenable1,
input      [15:0]                 in_tiles_1_wdata1,
input      [6:0]                in_tiles_1_addr1,
output reg  [15:0]     out_tiles_1_rdata0,
output reg  [15:0]     out_tiles_1_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_1_wenable0) begin
    buffer[in_tiles_1_addr0] <= in_tiles_1_wdata0;
  end else begin
    out_tiles_1_rdata0 <= buffer[in_tiles_1_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_1_wenable1) begin
    buffer[in_tiles_1_addr1] <= in_tiles_1_wdata1;
  end else begin
    out_tiles_1_rdata1 <= buffer[in_tiles_1_addr1];
  end
end

endmodule

module M_sprite_layer_mem_tiles_2(
input      [0:0]             in_tiles_2_wenable0,
input       [15:0]     in_tiles_2_wdata0,
input      [6:0]                in_tiles_2_addr0,
input      [0:0]             in_tiles_2_wenable1,
input      [15:0]                 in_tiles_2_wdata1,
input      [6:0]                in_tiles_2_addr1,
output reg  [15:0]     out_tiles_2_rdata0,
output reg  [15:0]     out_tiles_2_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_2_wenable0) begin
    buffer[in_tiles_2_addr0] <= in_tiles_2_wdata0;
  end else begin
    out_tiles_2_rdata0 <= buffer[in_tiles_2_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_2_wenable1) begin
    buffer[in_tiles_2_addr1] <= in_tiles_2_wdata1;
  end else begin
    out_tiles_2_rdata1 <= buffer[in_tiles_2_addr1];
  end
end

endmodule

module M_sprite_layer_mem_tiles_3(
input      [0:0]             in_tiles_3_wenable0,
input       [15:0]     in_tiles_3_wdata0,
input      [6:0]                in_tiles_3_addr0,
input      [0:0]             in_tiles_3_wenable1,
input      [15:0]                 in_tiles_3_wdata1,
input      [6:0]                in_tiles_3_addr1,
output reg  [15:0]     out_tiles_3_rdata0,
output reg  [15:0]     out_tiles_3_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_3_wenable0) begin
    buffer[in_tiles_3_addr0] <= in_tiles_3_wdata0;
  end else begin
    out_tiles_3_rdata0 <= buffer[in_tiles_3_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_3_wenable1) begin
    buffer[in_tiles_3_addr1] <= in_tiles_3_wdata1;
  end else begin
    out_tiles_3_rdata1 <= buffer[in_tiles_3_addr1];
  end
end

endmodule

module M_sprite_layer_mem_tiles_4(
input      [0:0]             in_tiles_4_wenable0,
input       [15:0]     in_tiles_4_wdata0,
input      [6:0]                in_tiles_4_addr0,
input      [0:0]             in_tiles_4_wenable1,
input      [15:0]                 in_tiles_4_wdata1,
input      [6:0]                in_tiles_4_addr1,
output reg  [15:0]     out_tiles_4_rdata0,
output reg  [15:0]     out_tiles_4_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_4_wenable0) begin
    buffer[in_tiles_4_addr0] <= in_tiles_4_wdata0;
  end else begin
    out_tiles_4_rdata0 <= buffer[in_tiles_4_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_4_wenable1) begin
    buffer[in_tiles_4_addr1] <= in_tiles_4_wdata1;
  end else begin
    out_tiles_4_rdata1 <= buffer[in_tiles_4_addr1];
  end
end

endmodule

module M_sprite_layer_mem_tiles_5(
input      [0:0]             in_tiles_5_wenable0,
input       [15:0]     in_tiles_5_wdata0,
input      [6:0]                in_tiles_5_addr0,
input      [0:0]             in_tiles_5_wenable1,
input      [15:0]                 in_tiles_5_wdata1,
input      [6:0]                in_tiles_5_addr1,
output reg  [15:0]     out_tiles_5_rdata0,
output reg  [15:0]     out_tiles_5_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_5_wenable0) begin
    buffer[in_tiles_5_addr0] <= in_tiles_5_wdata0;
  end else begin
    out_tiles_5_rdata0 <= buffer[in_tiles_5_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_5_wenable1) begin
    buffer[in_tiles_5_addr1] <= in_tiles_5_wdata1;
  end else begin
    out_tiles_5_rdata1 <= buffer[in_tiles_5_addr1];
  end
end

endmodule

module M_sprite_layer_mem_tiles_6(
input      [0:0]             in_tiles_6_wenable0,
input       [15:0]     in_tiles_6_wdata0,
input      [6:0]                in_tiles_6_addr0,
input      [0:0]             in_tiles_6_wenable1,
input      [15:0]                 in_tiles_6_wdata1,
input      [6:0]                in_tiles_6_addr1,
output reg  [15:0]     out_tiles_6_rdata0,
output reg  [15:0]     out_tiles_6_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_6_wenable0) begin
    buffer[in_tiles_6_addr0] <= in_tiles_6_wdata0;
  end else begin
    out_tiles_6_rdata0 <= buffer[in_tiles_6_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_6_wenable1) begin
    buffer[in_tiles_6_addr1] <= in_tiles_6_wdata1;
  end else begin
    out_tiles_6_rdata1 <= buffer[in_tiles_6_addr1];
  end
end

endmodule

module M_sprite_layer_mem_tiles_7(
input      [0:0]             in_tiles_7_wenable0,
input       [15:0]     in_tiles_7_wdata0,
input      [6:0]                in_tiles_7_addr0,
input      [0:0]             in_tiles_7_wenable1,
input      [15:0]                 in_tiles_7_wdata1,
input      [6:0]                in_tiles_7_addr1,
output reg  [15:0]     out_tiles_7_rdata0,
output reg  [15:0]     out_tiles_7_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_7_wenable0) begin
    buffer[in_tiles_7_addr0] <= in_tiles_7_wdata0;
  end else begin
    out_tiles_7_rdata0 <= buffer[in_tiles_7_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_7_wenable1) begin
    buffer[in_tiles_7_addr1] <= in_tiles_7_wdata1;
  end else begin
    out_tiles_7_rdata1 <= buffer[in_tiles_7_addr1];
  end
end

endmodule

module M_sprite_layer_mem_tiles_8(
input      [0:0]             in_tiles_8_wenable0,
input       [15:0]     in_tiles_8_wdata0,
input      [6:0]                in_tiles_8_addr0,
input      [0:0]             in_tiles_8_wenable1,
input      [15:0]                 in_tiles_8_wdata1,
input      [6:0]                in_tiles_8_addr1,
output reg  [15:0]     out_tiles_8_rdata0,
output reg  [15:0]     out_tiles_8_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_8_wenable0) begin
    buffer[in_tiles_8_addr0] <= in_tiles_8_wdata0;
  end else begin
    out_tiles_8_rdata0 <= buffer[in_tiles_8_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_8_wenable1) begin
    buffer[in_tiles_8_addr1] <= in_tiles_8_wdata1;
  end else begin
    out_tiles_8_rdata1 <= buffer[in_tiles_8_addr1];
  end
end

endmodule

module M_sprite_layer_mem_tiles_9(
input      [0:0]             in_tiles_9_wenable0,
input       [15:0]     in_tiles_9_wdata0,
input      [6:0]                in_tiles_9_addr0,
input      [0:0]             in_tiles_9_wenable1,
input      [15:0]                 in_tiles_9_wdata1,
input      [6:0]                in_tiles_9_addr1,
output reg  [15:0]     out_tiles_9_rdata0,
output reg  [15:0]     out_tiles_9_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_9_wenable0) begin
    buffer[in_tiles_9_addr0] <= in_tiles_9_wdata0;
  end else begin
    out_tiles_9_rdata0 <= buffer[in_tiles_9_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_9_wenable1) begin
    buffer[in_tiles_9_addr1] <= in_tiles_9_wdata1;
  end else begin
    out_tiles_9_rdata1 <= buffer[in_tiles_9_addr1];
  end
end

endmodule

module M_sprite_layer_mem_tiles_10(
input      [0:0]             in_tiles_10_wenable0,
input       [15:0]     in_tiles_10_wdata0,
input      [6:0]                in_tiles_10_addr0,
input      [0:0]             in_tiles_10_wenable1,
input      [15:0]                 in_tiles_10_wdata1,
input      [6:0]                in_tiles_10_addr1,
output reg  [15:0]     out_tiles_10_rdata0,
output reg  [15:0]     out_tiles_10_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_10_wenable0) begin
    buffer[in_tiles_10_addr0] <= in_tiles_10_wdata0;
  end else begin
    out_tiles_10_rdata0 <= buffer[in_tiles_10_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_10_wenable1) begin
    buffer[in_tiles_10_addr1] <= in_tiles_10_wdata1;
  end else begin
    out_tiles_10_rdata1 <= buffer[in_tiles_10_addr1];
  end
end

endmodule

module M_sprite_layer_mem_tiles_11(
input      [0:0]             in_tiles_11_wenable0,
input       [15:0]     in_tiles_11_wdata0,
input      [6:0]                in_tiles_11_addr0,
input      [0:0]             in_tiles_11_wenable1,
input      [15:0]                 in_tiles_11_wdata1,
input      [6:0]                in_tiles_11_addr1,
output reg  [15:0]     out_tiles_11_rdata0,
output reg  [15:0]     out_tiles_11_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_11_wenable0) begin
    buffer[in_tiles_11_addr0] <= in_tiles_11_wdata0;
  end else begin
    out_tiles_11_rdata0 <= buffer[in_tiles_11_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_11_wenable1) begin
    buffer[in_tiles_11_addr1] <= in_tiles_11_wdata1;
  end else begin
    out_tiles_11_rdata1 <= buffer[in_tiles_11_addr1];
  end
end

endmodule

module M_sprite_layer_mem_tiles_12(
input      [0:0]             in_tiles_12_wenable0,
input       [15:0]     in_tiles_12_wdata0,
input      [6:0]                in_tiles_12_addr0,
input      [0:0]             in_tiles_12_wenable1,
input      [15:0]                 in_tiles_12_wdata1,
input      [6:0]                in_tiles_12_addr1,
output reg  [15:0]     out_tiles_12_rdata0,
output reg  [15:0]     out_tiles_12_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[127:0];
always @(posedge clock0) begin
  if (in_tiles_12_wenable0) begin
    buffer[in_tiles_12_addr0] <= in_tiles_12_wdata0;
  end else begin
    out_tiles_12_rdata0 <= buffer[in_tiles_12_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles_12_wenable1) begin
    buffer[in_tiles_12_addr1] <= in_tiles_12_wdata1;
  end else begin
    out_tiles_12_rdata1 <= buffer[in_tiles_12_addr1];
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
wire  [15:0] _w_mem_tiles_0_rdata1;
wire  [15:0] _w_mem_tiles_1_rdata0;
wire  [15:0] _w_mem_tiles_1_rdata1;
wire  [15:0] _w_mem_tiles_2_rdata0;
wire  [15:0] _w_mem_tiles_2_rdata1;
wire  [15:0] _w_mem_tiles_3_rdata0;
wire  [15:0] _w_mem_tiles_3_rdata1;
wire  [15:0] _w_mem_tiles_4_rdata0;
wire  [15:0] _w_mem_tiles_4_rdata1;
wire  [15:0] _w_mem_tiles_5_rdata0;
wire  [15:0] _w_mem_tiles_5_rdata1;
wire  [15:0] _w_mem_tiles_6_rdata0;
wire  [15:0] _w_mem_tiles_6_rdata1;
wire  [15:0] _w_mem_tiles_7_rdata0;
wire  [15:0] _w_mem_tiles_7_rdata1;
wire  [15:0] _w_mem_tiles_8_rdata0;
wire  [15:0] _w_mem_tiles_8_rdata1;
wire  [15:0] _w_mem_tiles_9_rdata0;
wire  [15:0] _w_mem_tiles_9_rdata1;
wire  [15:0] _w_mem_tiles_10_rdata0;
wire  [15:0] _w_mem_tiles_10_rdata1;
wire  [15:0] _w_mem_tiles_11_rdata0;
wire  [15:0] _w_mem_tiles_11_rdata1;
wire  [15:0] _w_mem_tiles_12_rdata0;
wire  [15:0] _w_mem_tiles_12_rdata1;
wire  [15:0] _c_tiles_0_wdata0;
assign _c_tiles_0_wdata0 = 0;
wire  [15:0] _c_tiles_1_wdata0;
assign _c_tiles_1_wdata0 = 0;
wire  [15:0] _c_tiles_2_wdata0;
assign _c_tiles_2_wdata0 = 0;
wire  [15:0] _c_tiles_3_wdata0;
assign _c_tiles_3_wdata0 = 0;
wire  [15:0] _c_tiles_4_wdata0;
assign _c_tiles_4_wdata0 = 0;
wire  [15:0] _c_tiles_5_wdata0;
assign _c_tiles_5_wdata0 = 0;
wire  [15:0] _c_tiles_6_wdata0;
assign _c_tiles_6_wdata0 = 0;
wire  [15:0] _c_tiles_7_wdata0;
assign _c_tiles_7_wdata0 = 0;
wire  [15:0] _c_tiles_8_wdata0;
assign _c_tiles_8_wdata0 = 0;
wire  [15:0] _c_tiles_9_wdata0;
assign _c_tiles_9_wdata0 = 0;
wire  [15:0] _c_tiles_10_wdata0;
assign _c_tiles_10_wdata0 = 0;
wire  [15:0] _c_tiles_11_wdata0;
assign _c_tiles_11_wdata0 = 0;
wire  [15:0] _c_tiles_12_wdata0;
assign _c_tiles_12_wdata0 = 0;
wire  [5:0] _w_spritesize_0;
wire  [3:0] _w_xinsprite_0;
wire  [3:0] _w_yinsprite_0;
wire  [0:0] _w_xinrange_0;
wire  [0:0] _w_yinrange_0;
wire  [0:0] _w_pix_visible_0;
wire  [5:0] _w_spritesize_1;
wire  [3:0] _w_xinsprite_1;
wire  [3:0] _w_yinsprite_1;
wire  [0:0] _w_xinrange_1;
wire  [0:0] _w_yinrange_1;
wire  [0:0] _w_pix_visible_1;
wire  [5:0] _w_spritesize_2;
wire  [3:0] _w_xinsprite_2;
wire  [3:0] _w_yinsprite_2;
wire  [0:0] _w_xinrange_2;
wire  [0:0] _w_yinrange_2;
wire  [0:0] _w_pix_visible_2;
wire  [5:0] _w_spritesize_3;
wire  [3:0] _w_xinsprite_3;
wire  [3:0] _w_yinsprite_3;
wire  [0:0] _w_xinrange_3;
wire  [0:0] _w_yinrange_3;
wire  [0:0] _w_pix_visible_3;
wire  [5:0] _w_spritesize_4;
wire  [3:0] _w_xinsprite_4;
wire  [3:0] _w_yinsprite_4;
wire  [0:0] _w_xinrange_4;
wire  [0:0] _w_yinrange_4;
wire  [0:0] _w_pix_visible_4;
wire  [5:0] _w_spritesize_5;
wire  [3:0] _w_xinsprite_5;
wire  [3:0] _w_yinsprite_5;
wire  [0:0] _w_xinrange_5;
wire  [0:0] _w_yinrange_5;
wire  [0:0] _w_pix_visible_5;
wire  [5:0] _w_spritesize_6;
wire  [3:0] _w_xinsprite_6;
wire  [3:0] _w_yinsprite_6;
wire  [0:0] _w_xinrange_6;
wire  [0:0] _w_yinrange_6;
wire  [0:0] _w_pix_visible_6;
wire  [5:0] _w_spritesize_7;
wire  [3:0] _w_xinsprite_7;
wire  [3:0] _w_yinsprite_7;
wire  [0:0] _w_xinrange_7;
wire  [0:0] _w_yinrange_7;
wire  [0:0] _w_pix_visible_7;
wire  [5:0] _w_spritesize_8;
wire  [3:0] _w_xinsprite_8;
wire  [3:0] _w_yinsprite_8;
wire  [0:0] _w_xinrange_8;
wire  [0:0] _w_yinrange_8;
wire  [0:0] _w_pix_visible_8;
wire  [5:0] _w_spritesize_9;
wire  [3:0] _w_xinsprite_9;
wire  [3:0] _w_yinsprite_9;
wire  [0:0] _w_xinrange_9;
wire  [0:0] _w_yinrange_9;
wire  [0:0] _w_pix_visible_9;
wire  [5:0] _w_spritesize_10;
wire  [3:0] _w_xinsprite_10;
wire  [3:0] _w_yinsprite_10;
wire  [0:0] _w_xinrange_10;
wire  [0:0] _w_yinrange_10;
wire  [0:0] _w_pix_visible_10;
wire  [5:0] _w_spritesize_11;
wire  [3:0] _w_xinsprite_11;
wire  [3:0] _w_yinsprite_11;
wire  [0:0] _w_xinrange_11;
wire  [0:0] _w_yinrange_11;
wire  [0:0] _w_pix_visible_11;
wire  [5:0] _w_spritesize_12;
wire  [3:0] _w_xinsprite_12;
wire  [3:0] _w_yinsprite_12;
wire  [0:0] _w_xinrange_12;
wire  [0:0] _w_yinrange_12;
wire  [0:0] _w_pix_visible_12;
wire signed [10:0] _w_deltax;
wire signed [10:0] _w_deltay;

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
reg  [0:0] _d_tiles_0_wenable0;
reg  [0:0] _q_tiles_0_wenable0;
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
reg  [0:0] _d_tiles_1_wenable0;
reg  [0:0] _q_tiles_1_wenable0;
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
reg  [0:0] _d_tiles_2_wenable0;
reg  [0:0] _q_tiles_2_wenable0;
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
reg  [0:0] _d_tiles_3_wenable0;
reg  [0:0] _q_tiles_3_wenable0;
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
reg  [0:0] _d_tiles_4_wenable0;
reg  [0:0] _q_tiles_4_wenable0;
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
reg  [0:0] _d_tiles_5_wenable0;
reg  [0:0] _q_tiles_5_wenable0;
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
reg  [0:0] _d_tiles_6_wenable0;
reg  [0:0] _q_tiles_6_wenable0;
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
reg  [0:0] _d_tiles_7_wenable0;
reg  [0:0] _q_tiles_7_wenable0;
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
reg  [0:0] _d_tiles_8_wenable0;
reg  [0:0] _q_tiles_8_wenable0;
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
reg  [0:0] _d_tiles_9_wenable0;
reg  [0:0] _q_tiles_9_wenable0;
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
reg  [0:0] _d_tiles_10_wenable0;
reg  [0:0] _q_tiles_10_wenable0;
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
reg  [0:0] _d_tiles_11_wenable0;
reg  [0:0] _q_tiles_11_wenable0;
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
reg  [0:0] _d_tiles_12_wenable0;
reg  [0:0] _q_tiles_12_wenable0;
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
_q_tiles_0_wenable0 <= 0;
_q_tiles_0_addr0 <= 0;
_q_tiles_0_wenable1 <= 0;
_q_tiles_0_wdata1 <= 0;
_q_tiles_0_addr1 <= 0;
_q_tiles_1_wenable0 <= 0;
_q_tiles_1_addr0 <= 0;
_q_tiles_1_wenable1 <= 0;
_q_tiles_1_wdata1 <= 0;
_q_tiles_1_addr1 <= 0;
_q_tiles_2_wenable0 <= 0;
_q_tiles_2_addr0 <= 0;
_q_tiles_2_wenable1 <= 0;
_q_tiles_2_wdata1 <= 0;
_q_tiles_2_addr1 <= 0;
_q_tiles_3_wenable0 <= 0;
_q_tiles_3_addr0 <= 0;
_q_tiles_3_wenable1 <= 0;
_q_tiles_3_wdata1 <= 0;
_q_tiles_3_addr1 <= 0;
_q_tiles_4_wenable0 <= 0;
_q_tiles_4_addr0 <= 0;
_q_tiles_4_wenable1 <= 0;
_q_tiles_4_wdata1 <= 0;
_q_tiles_4_addr1 <= 0;
_q_tiles_5_wenable0 <= 0;
_q_tiles_5_addr0 <= 0;
_q_tiles_5_wenable1 <= 0;
_q_tiles_5_wdata1 <= 0;
_q_tiles_5_addr1 <= 0;
_q_tiles_6_wenable0 <= 0;
_q_tiles_6_addr0 <= 0;
_q_tiles_6_wenable1 <= 0;
_q_tiles_6_wdata1 <= 0;
_q_tiles_6_addr1 <= 0;
_q_tiles_7_wenable0 <= 0;
_q_tiles_7_addr0 <= 0;
_q_tiles_7_wenable1 <= 0;
_q_tiles_7_wdata1 <= 0;
_q_tiles_7_addr1 <= 0;
_q_tiles_8_wenable0 <= 0;
_q_tiles_8_addr0 <= 0;
_q_tiles_8_wenable1 <= 0;
_q_tiles_8_wdata1 <= 0;
_q_tiles_8_addr1 <= 0;
_q_tiles_9_wenable0 <= 0;
_q_tiles_9_addr0 <= 0;
_q_tiles_9_wenable1 <= 0;
_q_tiles_9_wdata1 <= 0;
_q_tiles_9_addr1 <= 0;
_q_tiles_10_wenable0 <= 0;
_q_tiles_10_addr0 <= 0;
_q_tiles_10_wenable1 <= 0;
_q_tiles_10_wdata1 <= 0;
_q_tiles_10_addr1 <= 0;
_q_tiles_11_wenable0 <= 0;
_q_tiles_11_addr0 <= 0;
_q_tiles_11_wenable1 <= 0;
_q_tiles_11_wdata1 <= 0;
_q_tiles_11_addr1 <= 0;
_q_tiles_12_wenable0 <= 0;
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
_q_tiles_0_wenable0 <= _d_tiles_0_wenable0;
_q_tiles_0_addr0 <= _d_tiles_0_addr0;
_q_tiles_0_wenable1 <= _d_tiles_0_wenable1;
_q_tiles_0_wdata1 <= _d_tiles_0_wdata1;
_q_tiles_0_addr1 <= _d_tiles_0_addr1;
_q_detect_collision_0 <= _d_detect_collision_0;
_q_tiles_1_wenable0 <= _d_tiles_1_wenable0;
_q_tiles_1_addr0 <= _d_tiles_1_addr0;
_q_tiles_1_wenable1 <= _d_tiles_1_wenable1;
_q_tiles_1_wdata1 <= _d_tiles_1_wdata1;
_q_tiles_1_addr1 <= _d_tiles_1_addr1;
_q_detect_collision_1 <= _d_detect_collision_1;
_q_tiles_2_wenable0 <= _d_tiles_2_wenable0;
_q_tiles_2_addr0 <= _d_tiles_2_addr0;
_q_tiles_2_wenable1 <= _d_tiles_2_wenable1;
_q_tiles_2_wdata1 <= _d_tiles_2_wdata1;
_q_tiles_2_addr1 <= _d_tiles_2_addr1;
_q_detect_collision_2 <= _d_detect_collision_2;
_q_tiles_3_wenable0 <= _d_tiles_3_wenable0;
_q_tiles_3_addr0 <= _d_tiles_3_addr0;
_q_tiles_3_wenable1 <= _d_tiles_3_wenable1;
_q_tiles_3_wdata1 <= _d_tiles_3_wdata1;
_q_tiles_3_addr1 <= _d_tiles_3_addr1;
_q_detect_collision_3 <= _d_detect_collision_3;
_q_tiles_4_wenable0 <= _d_tiles_4_wenable0;
_q_tiles_4_addr0 <= _d_tiles_4_addr0;
_q_tiles_4_wenable1 <= _d_tiles_4_wenable1;
_q_tiles_4_wdata1 <= _d_tiles_4_wdata1;
_q_tiles_4_addr1 <= _d_tiles_4_addr1;
_q_detect_collision_4 <= _d_detect_collision_4;
_q_tiles_5_wenable0 <= _d_tiles_5_wenable0;
_q_tiles_5_addr0 <= _d_tiles_5_addr0;
_q_tiles_5_wenable1 <= _d_tiles_5_wenable1;
_q_tiles_5_wdata1 <= _d_tiles_5_wdata1;
_q_tiles_5_addr1 <= _d_tiles_5_addr1;
_q_detect_collision_5 <= _d_detect_collision_5;
_q_tiles_6_wenable0 <= _d_tiles_6_wenable0;
_q_tiles_6_addr0 <= _d_tiles_6_addr0;
_q_tiles_6_wenable1 <= _d_tiles_6_wenable1;
_q_tiles_6_wdata1 <= _d_tiles_6_wdata1;
_q_tiles_6_addr1 <= _d_tiles_6_addr1;
_q_detect_collision_6 <= _d_detect_collision_6;
_q_tiles_7_wenable0 <= _d_tiles_7_wenable0;
_q_tiles_7_addr0 <= _d_tiles_7_addr0;
_q_tiles_7_wenable1 <= _d_tiles_7_wenable1;
_q_tiles_7_wdata1 <= _d_tiles_7_wdata1;
_q_tiles_7_addr1 <= _d_tiles_7_addr1;
_q_detect_collision_7 <= _d_detect_collision_7;
_q_tiles_8_wenable0 <= _d_tiles_8_wenable0;
_q_tiles_8_addr0 <= _d_tiles_8_addr0;
_q_tiles_8_wenable1 <= _d_tiles_8_wenable1;
_q_tiles_8_wdata1 <= _d_tiles_8_wdata1;
_q_tiles_8_addr1 <= _d_tiles_8_addr1;
_q_detect_collision_8 <= _d_detect_collision_8;
_q_tiles_9_wenable0 <= _d_tiles_9_wenable0;
_q_tiles_9_addr0 <= _d_tiles_9_addr0;
_q_tiles_9_wenable1 <= _d_tiles_9_wenable1;
_q_tiles_9_wdata1 <= _d_tiles_9_wdata1;
_q_tiles_9_addr1 <= _d_tiles_9_addr1;
_q_detect_collision_9 <= _d_detect_collision_9;
_q_tiles_10_wenable0 <= _d_tiles_10_wenable0;
_q_tiles_10_addr0 <= _d_tiles_10_addr0;
_q_tiles_10_wenable1 <= _d_tiles_10_wenable1;
_q_tiles_10_wdata1 <= _d_tiles_10_wdata1;
_q_tiles_10_addr1 <= _d_tiles_10_addr1;
_q_detect_collision_10 <= _d_detect_collision_10;
_q_tiles_11_wenable0 <= _d_tiles_11_wenable0;
_q_tiles_11_addr0 <= _d_tiles_11_addr0;
_q_tiles_11_wenable1 <= _d_tiles_11_wenable1;
_q_tiles_11_wdata1 <= _d_tiles_11_wdata1;
_q_tiles_11_addr1 <= _d_tiles_11_addr1;
_q_detect_collision_11 <= _d_detect_collision_11;
_q_tiles_12_wenable0 <= _d_tiles_12_wenable0;
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
.in_tiles_0_wenable0(_d_tiles_0_wenable0),
.in_tiles_0_wdata0(_c_tiles_0_wdata0),
.in_tiles_0_addr0(_d_tiles_0_addr0),
.in_tiles_0_wenable1(_d_tiles_0_wenable1),
.in_tiles_0_wdata1(_d_tiles_0_wdata1),
.in_tiles_0_addr1(_d_tiles_0_addr1),
.out_tiles_0_rdata0(_w_mem_tiles_0_rdata0),
.out_tiles_0_rdata1(_w_mem_tiles_0_rdata1)
);
M_sprite_layer_mem_tiles_1 __mem__tiles_1(
.clock0(clock),
.clock1(clock),
.in_tiles_1_wenable0(_d_tiles_1_wenable0),
.in_tiles_1_wdata0(_c_tiles_1_wdata0),
.in_tiles_1_addr0(_d_tiles_1_addr0),
.in_tiles_1_wenable1(_d_tiles_1_wenable1),
.in_tiles_1_wdata1(_d_tiles_1_wdata1),
.in_tiles_1_addr1(_d_tiles_1_addr1),
.out_tiles_1_rdata0(_w_mem_tiles_1_rdata0),
.out_tiles_1_rdata1(_w_mem_tiles_1_rdata1)
);
M_sprite_layer_mem_tiles_2 __mem__tiles_2(
.clock0(clock),
.clock1(clock),
.in_tiles_2_wenable0(_d_tiles_2_wenable0),
.in_tiles_2_wdata0(_c_tiles_2_wdata0),
.in_tiles_2_addr0(_d_tiles_2_addr0),
.in_tiles_2_wenable1(_d_tiles_2_wenable1),
.in_tiles_2_wdata1(_d_tiles_2_wdata1),
.in_tiles_2_addr1(_d_tiles_2_addr1),
.out_tiles_2_rdata0(_w_mem_tiles_2_rdata0),
.out_tiles_2_rdata1(_w_mem_tiles_2_rdata1)
);
M_sprite_layer_mem_tiles_3 __mem__tiles_3(
.clock0(clock),
.clock1(clock),
.in_tiles_3_wenable0(_d_tiles_3_wenable0),
.in_tiles_3_wdata0(_c_tiles_3_wdata0),
.in_tiles_3_addr0(_d_tiles_3_addr0),
.in_tiles_3_wenable1(_d_tiles_3_wenable1),
.in_tiles_3_wdata1(_d_tiles_3_wdata1),
.in_tiles_3_addr1(_d_tiles_3_addr1),
.out_tiles_3_rdata0(_w_mem_tiles_3_rdata0),
.out_tiles_3_rdata1(_w_mem_tiles_3_rdata1)
);
M_sprite_layer_mem_tiles_4 __mem__tiles_4(
.clock0(clock),
.clock1(clock),
.in_tiles_4_wenable0(_d_tiles_4_wenable0),
.in_tiles_4_wdata0(_c_tiles_4_wdata0),
.in_tiles_4_addr0(_d_tiles_4_addr0),
.in_tiles_4_wenable1(_d_tiles_4_wenable1),
.in_tiles_4_wdata1(_d_tiles_4_wdata1),
.in_tiles_4_addr1(_d_tiles_4_addr1),
.out_tiles_4_rdata0(_w_mem_tiles_4_rdata0),
.out_tiles_4_rdata1(_w_mem_tiles_4_rdata1)
);
M_sprite_layer_mem_tiles_5 __mem__tiles_5(
.clock0(clock),
.clock1(clock),
.in_tiles_5_wenable0(_d_tiles_5_wenable0),
.in_tiles_5_wdata0(_c_tiles_5_wdata0),
.in_tiles_5_addr0(_d_tiles_5_addr0),
.in_tiles_5_wenable1(_d_tiles_5_wenable1),
.in_tiles_5_wdata1(_d_tiles_5_wdata1),
.in_tiles_5_addr1(_d_tiles_5_addr1),
.out_tiles_5_rdata0(_w_mem_tiles_5_rdata0),
.out_tiles_5_rdata1(_w_mem_tiles_5_rdata1)
);
M_sprite_layer_mem_tiles_6 __mem__tiles_6(
.clock0(clock),
.clock1(clock),
.in_tiles_6_wenable0(_d_tiles_6_wenable0),
.in_tiles_6_wdata0(_c_tiles_6_wdata0),
.in_tiles_6_addr0(_d_tiles_6_addr0),
.in_tiles_6_wenable1(_d_tiles_6_wenable1),
.in_tiles_6_wdata1(_d_tiles_6_wdata1),
.in_tiles_6_addr1(_d_tiles_6_addr1),
.out_tiles_6_rdata0(_w_mem_tiles_6_rdata0),
.out_tiles_6_rdata1(_w_mem_tiles_6_rdata1)
);
M_sprite_layer_mem_tiles_7 __mem__tiles_7(
.clock0(clock),
.clock1(clock),
.in_tiles_7_wenable0(_d_tiles_7_wenable0),
.in_tiles_7_wdata0(_c_tiles_7_wdata0),
.in_tiles_7_addr0(_d_tiles_7_addr0),
.in_tiles_7_wenable1(_d_tiles_7_wenable1),
.in_tiles_7_wdata1(_d_tiles_7_wdata1),
.in_tiles_7_addr1(_d_tiles_7_addr1),
.out_tiles_7_rdata0(_w_mem_tiles_7_rdata0),
.out_tiles_7_rdata1(_w_mem_tiles_7_rdata1)
);
M_sprite_layer_mem_tiles_8 __mem__tiles_8(
.clock0(clock),
.clock1(clock),
.in_tiles_8_wenable0(_d_tiles_8_wenable0),
.in_tiles_8_wdata0(_c_tiles_8_wdata0),
.in_tiles_8_addr0(_d_tiles_8_addr0),
.in_tiles_8_wenable1(_d_tiles_8_wenable1),
.in_tiles_8_wdata1(_d_tiles_8_wdata1),
.in_tiles_8_addr1(_d_tiles_8_addr1),
.out_tiles_8_rdata0(_w_mem_tiles_8_rdata0),
.out_tiles_8_rdata1(_w_mem_tiles_8_rdata1)
);
M_sprite_layer_mem_tiles_9 __mem__tiles_9(
.clock0(clock),
.clock1(clock),
.in_tiles_9_wenable0(_d_tiles_9_wenable0),
.in_tiles_9_wdata0(_c_tiles_9_wdata0),
.in_tiles_9_addr0(_d_tiles_9_addr0),
.in_tiles_9_wenable1(_d_tiles_9_wenable1),
.in_tiles_9_wdata1(_d_tiles_9_wdata1),
.in_tiles_9_addr1(_d_tiles_9_addr1),
.out_tiles_9_rdata0(_w_mem_tiles_9_rdata0),
.out_tiles_9_rdata1(_w_mem_tiles_9_rdata1)
);
M_sprite_layer_mem_tiles_10 __mem__tiles_10(
.clock0(clock),
.clock1(clock),
.in_tiles_10_wenable0(_d_tiles_10_wenable0),
.in_tiles_10_wdata0(_c_tiles_10_wdata0),
.in_tiles_10_addr0(_d_tiles_10_addr0),
.in_tiles_10_wenable1(_d_tiles_10_wenable1),
.in_tiles_10_wdata1(_d_tiles_10_wdata1),
.in_tiles_10_addr1(_d_tiles_10_addr1),
.out_tiles_10_rdata0(_w_mem_tiles_10_rdata0),
.out_tiles_10_rdata1(_w_mem_tiles_10_rdata1)
);
M_sprite_layer_mem_tiles_11 __mem__tiles_11(
.clock0(clock),
.clock1(clock),
.in_tiles_11_wenable0(_d_tiles_11_wenable0),
.in_tiles_11_wdata0(_c_tiles_11_wdata0),
.in_tiles_11_addr0(_d_tiles_11_addr0),
.in_tiles_11_wenable1(_d_tiles_11_wenable1),
.in_tiles_11_wdata1(_d_tiles_11_wdata1),
.in_tiles_11_addr1(_d_tiles_11_addr1),
.out_tiles_11_rdata0(_w_mem_tiles_11_rdata0),
.out_tiles_11_rdata1(_w_mem_tiles_11_rdata1)
);
M_sprite_layer_mem_tiles_12 __mem__tiles_12(
.clock0(clock),
.clock1(clock),
.in_tiles_12_wenable0(_d_tiles_12_wenable0),
.in_tiles_12_wdata0(_c_tiles_12_wdata0),
.in_tiles_12_addr0(_d_tiles_12_addr0),
.in_tiles_12_wenable1(_d_tiles_12_wenable1),
.in_tiles_12_wdata1(_d_tiles_12_wdata1),
.in_tiles_12_addr1(_d_tiles_12_addr1),
.out_tiles_12_rdata0(_w_mem_tiles_12_rdata0),
.out_tiles_12_rdata1(_w_mem_tiles_12_rdata1)
);

assign _w_deltay = {{9{in_sprite_update[5+:1]}},in_sprite_update[3+:2]};
assign _w_deltax = {{9{in_sprite_update[2+:1]}},in_sprite_update[0+:2]};
assign _w_pix_visible_12 = _d_sprite_active[12]&&_w_xinrange_12&&_w_yinrange_12&&(_w_mem_tiles_12_rdata0[_w_xinsprite_12+:1]==1);
assign _w_xinrange_12 = (in_pix_x>=_d_sprite_x[12])&&(in_pix_x<(_d_sprite_x[12]+_w_spritesize_12));
assign _w_xinsprite_12 = 15-((in_pix_x-_d_sprite_x[12])>>_d_sprite_double[12]);
assign _w_spritesize_12 = _d_sprite_double[12]?32:16;
assign _w_pix_visible_11 = _d_sprite_active[11]&&_w_xinrange_11&&_w_yinrange_11&&(_w_mem_tiles_11_rdata0[_w_xinsprite_11+:1]==1);
assign _w_yinrange_11 = (in_pix_y>=_d_sprite_y[11])&&(in_pix_y<(_d_sprite_y[11]+_w_spritesize_11));
assign _w_xinrange_11 = (in_pix_x>=_d_sprite_x[11])&&(in_pix_x<(_d_sprite_x[11]+_w_spritesize_11));
assign _w_yinsprite_11 = (in_pix_y-_d_sprite_y[11])>>_d_sprite_double[11];
assign _w_xinsprite_11 = 15-((in_pix_x-_d_sprite_x[11])>>_d_sprite_double[11]);
assign _w_spritesize_11 = _d_sprite_double[11]?32:16;
assign _w_pix_visible_10 = _d_sprite_active[10]&&_w_xinrange_10&&_w_yinrange_10&&(_w_mem_tiles_10_rdata0[_w_xinsprite_10+:1]==1);
assign _w_yinrange_10 = (in_pix_y>=_d_sprite_y[10])&&(in_pix_y<(_d_sprite_y[10]+_w_spritesize_10));
assign _w_yinsprite_10 = (in_pix_y-_d_sprite_y[10])>>_d_sprite_double[10];
assign _w_yinrange_4 = (in_pix_y>=_d_sprite_y[4])&&(in_pix_y<(_d_sprite_y[4]+_w_spritesize_4));
assign _w_yinsprite_3 = (in_pix_y-_d_sprite_y[3])>>_d_sprite_double[3];
assign _w_xinrange_10 = (in_pix_x>=_d_sprite_x[10])&&(in_pix_x<(_d_sprite_x[10]+_w_spritesize_10));
assign _w_xinsprite_10 = 15-((in_pix_x-_d_sprite_x[10])>>_d_sprite_double[10]);
assign _w_xinsprite_0 = 15-((in_pix_x-_d_sprite_x[0])>>_d_sprite_double[0]);
assign _w_pix_visible_3 = _d_sprite_active[3]&&_w_xinrange_3&&_w_yinrange_3&&(_w_mem_tiles_3_rdata0[_w_xinsprite_3+:1]==1);
assign _w_pix_visible_1 = _d_sprite_active[1]&&_w_xinrange_1&&_w_yinrange_1&&(_w_mem_tiles_1_rdata0[_w_xinsprite_1+:1]==1);
assign _w_spritesize_5 = _d_sprite_double[5]?32:16;
assign _w_yinrange_6 = (in_pix_y>=_d_sprite_y[6])&&(in_pix_y<(_d_sprite_y[6]+_w_spritesize_6));
assign _w_yinsprite_4 = (in_pix_y-_d_sprite_y[4])>>_d_sprite_double[4];
assign _w_xinrange_5 = (in_pix_x>=_d_sprite_x[5])&&(in_pix_x<(_d_sprite_x[5]+_w_spritesize_5));
assign _w_xinsprite_6 = 15-((in_pix_x-_d_sprite_x[6])>>_d_sprite_double[6]);
assign _w_yinsprite_8 = (in_pix_y-_d_sprite_y[8])>>_d_sprite_double[8];
assign _w_yinsprite_2 = (in_pix_y-_d_sprite_y[2])>>_d_sprite_double[2];
assign _w_yinrange_3 = (in_pix_y>=_d_sprite_y[3])&&(in_pix_y<(_d_sprite_y[3]+_w_spritesize_3));
assign _w_spritesize_3 = _d_sprite_double[3]?32:16;
assign _w_xinsprite_2 = 15-((in_pix_x-_d_sprite_x[2])>>_d_sprite_double[2]);
assign _w_yinrange_0 = (in_pix_y>=_d_sprite_y[0])&&(in_pix_y<(_d_sprite_y[0]+_w_spritesize_0));
assign _w_yinrange_1 = (in_pix_y>=_d_sprite_y[1])&&(in_pix_y<(_d_sprite_y[1]+_w_spritesize_1));
assign _w_yinsprite_9 = (in_pix_y-_d_sprite_y[9])>>_d_sprite_double[9];
assign _w_yinsprite_0 = (in_pix_y-_d_sprite_y[0])>>_d_sprite_double[0];
assign _w_xinrange_4 = (in_pix_x>=_d_sprite_x[4])&&(in_pix_x<(_d_sprite_x[4]+_w_spritesize_4));
assign _w_xinrange_0 = (in_pix_x>=_d_sprite_x[0])&&(in_pix_x<(_d_sprite_x[0]+_w_spritesize_0));
assign _w_xinrange_1 = (in_pix_x>=_d_sprite_x[1])&&(in_pix_x<(_d_sprite_x[1]+_w_spritesize_1));
assign _w_yinsprite_5 = (in_pix_y-_d_sprite_y[5])>>_d_sprite_double[5];
assign _w_spritesize_0 = _d_sprite_double[0]?32:16;
assign _w_pix_visible_0 = _d_sprite_active[0]&&_w_xinrange_0&&_w_yinrange_0&&(_w_mem_tiles_0_rdata0[_w_xinsprite_0+:1]==1);
assign _w_spritesize_10 = _d_sprite_double[10]?32:16;
assign _w_xinrange_8 = (in_pix_x>=_d_sprite_x[8])&&(in_pix_x<(_d_sprite_x[8]+_w_spritesize_8));
assign _w_yinrange_9 = (in_pix_y>=_d_sprite_y[9])&&(in_pix_y<(_d_sprite_y[9]+_w_spritesize_9));
assign _w_yinsprite_1 = (in_pix_y-_d_sprite_y[1])>>_d_sprite_double[1];
assign _w_pix_visible_9 = _d_sprite_active[9]&&_w_xinrange_9&&_w_yinrange_9&&(_w_mem_tiles_9_rdata0[_w_xinsprite_9+:1]==1);
assign _w_yinsprite_6 = (in_pix_y-_d_sprite_y[6])>>_d_sprite_double[6];
assign _w_xinsprite_3 = 15-((in_pix_x-_d_sprite_x[3])>>_d_sprite_double[3]);
assign _w_spritesize_1 = _d_sprite_double[1]?32:16;
assign _w_xinsprite_4 = 15-((in_pix_x-_d_sprite_x[4])>>_d_sprite_double[4]);
assign _w_xinrange_2 = (in_pix_x>=_d_sprite_x[2])&&(in_pix_x<(_d_sprite_x[2]+_w_spritesize_2));
assign _w_pix_visible_8 = _d_sprite_active[8]&&_w_xinrange_8&&_w_yinrange_8&&(_w_mem_tiles_8_rdata0[_w_xinsprite_8+:1]==1);
assign _w_pix_visible_2 = _d_sprite_active[2]&&_w_xinrange_2&&_w_yinrange_2&&(_w_mem_tiles_2_rdata0[_w_xinsprite_2+:1]==1);
assign _w_xinsprite_1 = 15-((in_pix_x-_d_sprite_x[1])>>_d_sprite_double[1]);
assign _w_spritesize_2 = _d_sprite_double[2]?32:16;
assign _w_xinrange_9 = (in_pix_x>=_d_sprite_x[9])&&(in_pix_x<(_d_sprite_x[9]+_w_spritesize_9));
assign _w_pix_visible_4 = _d_sprite_active[4]&&_w_xinrange_4&&_w_yinrange_4&&(_w_mem_tiles_4_rdata0[_w_xinsprite_4+:1]==1);
assign _w_xinsprite_5 = 15-((in_pix_x-_d_sprite_x[5])>>_d_sprite_double[5]);
assign _w_spritesize_4 = _d_sprite_double[4]?32:16;
assign _w_yinrange_2 = (in_pix_y>=_d_sprite_y[2])&&(in_pix_y<(_d_sprite_y[2]+_w_spritesize_2));
assign _w_yinrange_5 = (in_pix_y>=_d_sprite_y[5])&&(in_pix_y<(_d_sprite_y[5]+_w_spritesize_5));
assign _w_yinsprite_12 = (in_pix_y-_d_sprite_y[12])>>_d_sprite_double[12];
assign _w_xinrange_3 = (in_pix_x>=_d_sprite_x[3])&&(in_pix_x<(_d_sprite_x[3]+_w_spritesize_3));
assign _w_pix_visible_5 = _d_sprite_active[5]&&_w_xinrange_5&&_w_yinrange_5&&(_w_mem_tiles_5_rdata0[_w_xinsprite_5+:1]==1);
assign _w_spritesize_6 = _d_sprite_double[6]?32:16;
assign _w_yinrange_12 = (in_pix_y>=_d_sprite_y[12])&&(in_pix_y<(_d_sprite_y[12]+_w_spritesize_12));
assign _w_xinrange_6 = (in_pix_x>=_d_sprite_x[6])&&(in_pix_x<(_d_sprite_x[6]+_w_spritesize_6));
assign _w_pix_visible_6 = _d_sprite_active[6]&&_w_xinrange_6&&_w_yinrange_6&&(_w_mem_tiles_6_rdata0[_w_xinsprite_6+:1]==1);
assign _w_spritesize_7 = _d_sprite_double[7]?32:16;
assign _w_xinsprite_7 = 15-((in_pix_x-_d_sprite_x[7])>>_d_sprite_double[7]);
assign _w_yinsprite_7 = (in_pix_y-_d_sprite_y[7])>>_d_sprite_double[7];
assign _w_yinrange_7 = (in_pix_y>=_d_sprite_y[7])&&(in_pix_y<(_d_sprite_y[7]+_w_spritesize_7));
assign _w_xinrange_7 = (in_pix_x>=_d_sprite_x[7])&&(in_pix_x<(_d_sprite_x[7]+_w_spritesize_7));
assign _w_pix_visible_7 = _d_sprite_active[7]&&_w_xinrange_7&&_w_yinrange_7&&(_w_mem_tiles_7_rdata0[_w_xinsprite_7+:1]==1);
assign _w_spritesize_8 = _d_sprite_double[8]?32:16;
assign _w_xinsprite_8 = 15-((in_pix_x-_d_sprite_x[8])>>_d_sprite_double[8]);
assign _w_yinrange_8 = (in_pix_y>=_d_sprite_y[8])&&(in_pix_y<(_d_sprite_y[8]+_w_spritesize_8));
assign _w_spritesize_9 = _d_sprite_double[9]?32:16;
assign _w_xinsprite_9 = 15-((in_pix_x-_d_sprite_x[9])>>_d_sprite_double[9]);

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
_d_tiles_0_wenable0 = _q_tiles_0_wenable0;
_d_tiles_0_addr0 = _q_tiles_0_addr0;
_d_tiles_0_wenable1 = _q_tiles_0_wenable1;
_d_tiles_0_wdata1 = _q_tiles_0_wdata1;
_d_tiles_0_addr1 = _q_tiles_0_addr1;
_d_detect_collision_0 = _q_detect_collision_0;
_d_tiles_1_wenable0 = _q_tiles_1_wenable0;
_d_tiles_1_addr0 = _q_tiles_1_addr0;
_d_tiles_1_wenable1 = _q_tiles_1_wenable1;
_d_tiles_1_wdata1 = _q_tiles_1_wdata1;
_d_tiles_1_addr1 = _q_tiles_1_addr1;
_d_detect_collision_1 = _q_detect_collision_1;
_d_tiles_2_wenable0 = _q_tiles_2_wenable0;
_d_tiles_2_addr0 = _q_tiles_2_addr0;
_d_tiles_2_wenable1 = _q_tiles_2_wenable1;
_d_tiles_2_wdata1 = _q_tiles_2_wdata1;
_d_tiles_2_addr1 = _q_tiles_2_addr1;
_d_detect_collision_2 = _q_detect_collision_2;
_d_tiles_3_wenable0 = _q_tiles_3_wenable0;
_d_tiles_3_addr0 = _q_tiles_3_addr0;
_d_tiles_3_wenable1 = _q_tiles_3_wenable1;
_d_tiles_3_wdata1 = _q_tiles_3_wdata1;
_d_tiles_3_addr1 = _q_tiles_3_addr1;
_d_detect_collision_3 = _q_detect_collision_3;
_d_tiles_4_wenable0 = _q_tiles_4_wenable0;
_d_tiles_4_addr0 = _q_tiles_4_addr0;
_d_tiles_4_wenable1 = _q_tiles_4_wenable1;
_d_tiles_4_wdata1 = _q_tiles_4_wdata1;
_d_tiles_4_addr1 = _q_tiles_4_addr1;
_d_detect_collision_4 = _q_detect_collision_4;
_d_tiles_5_wenable0 = _q_tiles_5_wenable0;
_d_tiles_5_addr0 = _q_tiles_5_addr0;
_d_tiles_5_wenable1 = _q_tiles_5_wenable1;
_d_tiles_5_wdata1 = _q_tiles_5_wdata1;
_d_tiles_5_addr1 = _q_tiles_5_addr1;
_d_detect_collision_5 = _q_detect_collision_5;
_d_tiles_6_wenable0 = _q_tiles_6_wenable0;
_d_tiles_6_addr0 = _q_tiles_6_addr0;
_d_tiles_6_wenable1 = _q_tiles_6_wenable1;
_d_tiles_6_wdata1 = _q_tiles_6_wdata1;
_d_tiles_6_addr1 = _q_tiles_6_addr1;
_d_detect_collision_6 = _q_detect_collision_6;
_d_tiles_7_wenable0 = _q_tiles_7_wenable0;
_d_tiles_7_addr0 = _q_tiles_7_addr0;
_d_tiles_7_wenable1 = _q_tiles_7_wenable1;
_d_tiles_7_wdata1 = _q_tiles_7_wdata1;
_d_tiles_7_addr1 = _q_tiles_7_addr1;
_d_detect_collision_7 = _q_detect_collision_7;
_d_tiles_8_wenable0 = _q_tiles_8_wenable0;
_d_tiles_8_addr0 = _q_tiles_8_addr0;
_d_tiles_8_wenable1 = _q_tiles_8_wenable1;
_d_tiles_8_wdata1 = _q_tiles_8_wdata1;
_d_tiles_8_addr1 = _q_tiles_8_addr1;
_d_detect_collision_8 = _q_detect_collision_8;
_d_tiles_9_wenable0 = _q_tiles_9_wenable0;
_d_tiles_9_addr0 = _q_tiles_9_addr0;
_d_tiles_9_wenable1 = _q_tiles_9_wenable1;
_d_tiles_9_wdata1 = _q_tiles_9_wdata1;
_d_tiles_9_addr1 = _q_tiles_9_addr1;
_d_detect_collision_9 = _q_detect_collision_9;
_d_tiles_10_wenable0 = _q_tiles_10_wenable0;
_d_tiles_10_addr0 = _q_tiles_10_addr0;
_d_tiles_10_wenable1 = _q_tiles_10_wenable1;
_d_tiles_10_wdata1 = _q_tiles_10_wdata1;
_d_tiles_10_addr1 = _q_tiles_10_addr1;
_d_detect_collision_10 = _q_detect_collision_10;
_d_tiles_11_wenable0 = _q_tiles_11_wenable0;
_d_tiles_11_addr0 = _q_tiles_11_addr0;
_d_tiles_11_wenable1 = _q_tiles_11_wenable1;
_d_tiles_11_wdata1 = _q_tiles_11_wdata1;
_d_tiles_11_addr1 = _q_tiles_11_addr1;
_d_detect_collision_11 = _q_detect_collision_11;
_d_tiles_12_wenable0 = _q_tiles_12_wenable0;
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
_d_tiles_0_addr0 = _q_sprite_tile_number[0]*16+_w_yinsprite_0;
_d_tiles_0_wenable0 = 0;
_d_tiles_0_wenable1 = 1;
_d_tiles_1_addr0 = _q_sprite_tile_number[1]*16+_w_yinsprite_1;
_d_tiles_1_wenable0 = 0;
_d_tiles_1_wenable1 = 1;
_d_tiles_2_addr0 = _q_sprite_tile_number[2]*16+_w_yinsprite_2;
_d_tiles_2_wenable0 = 0;
_d_tiles_2_wenable1 = 1;
_d_tiles_3_addr0 = _q_sprite_tile_number[3]*16+_w_yinsprite_3;
_d_tiles_3_wenable0 = 0;
_d_tiles_3_wenable1 = 1;
_d_tiles_4_addr0 = _q_sprite_tile_number[4]*16+_w_yinsprite_4;
_d_tiles_4_wenable0 = 0;
_d_tiles_4_wenable1 = 1;
_d_tiles_5_addr0 = _q_sprite_tile_number[5]*16+_w_yinsprite_5;
_d_tiles_5_wenable0 = 0;
_d_tiles_5_wenable1 = 1;
_d_tiles_6_addr0 = _q_sprite_tile_number[6]*16+_w_yinsprite_6;
_d_tiles_6_wenable0 = 0;
_d_tiles_6_wenable1 = 1;
_d_tiles_7_addr0 = _q_sprite_tile_number[7]*16+_w_yinsprite_7;
_d_tiles_7_wenable0 = 0;
_d_tiles_7_wenable1 = 1;
_d_tiles_8_addr0 = _q_sprite_tile_number[8]*16+_w_yinsprite_8;
_d_tiles_8_wenable0 = 0;
_d_tiles_8_wenable1 = 1;
_d_tiles_9_addr0 = _q_sprite_tile_number[9]*16+_w_yinsprite_9;
_d_tiles_9_wenable0 = 0;
_d_tiles_9_wenable1 = 1;
_d_tiles_10_addr0 = _q_sprite_tile_number[10]*16+_w_yinsprite_10;
_d_tiles_10_wenable0 = 0;
_d_tiles_10_wenable1 = 1;
_d_tiles_11_addr0 = _q_sprite_tile_number[11]*16+_w_yinsprite_11;
_d_tiles_11_wenable0 = 0;
_d_tiles_11_wenable1 = 1;
_d_tiles_12_addr0 = _q_sprite_tile_number[12]*16+_w_yinsprite_12;
_d_tiles_12_wenable0 = 0;
_d_tiles_12_wenable1 = 1;
_d_sprite_layer_display = 0;
_d_sprite_read_active = _q_sprite_active[in_sprite_set_number];
_d_sprite_read_double = _q_sprite_double[in_sprite_set_number];
_d_sprite_read_colour = _q_sprite_colour[in_sprite_set_number];
_d_sprite_read_x = _q_sprite_x[in_sprite_set_number];
_d_sprite_read_y = _q_sprite_y[in_sprite_set_number];
_d_sprite_read_tile = _q_sprite_tile_number[in_sprite_set_number];
if (in_sprite_writer_active) begin
// __block_1
// __block_3
  case (in_sprite_writer_sprite)
  0: begin
// __block_5_case
// __block_6
_d_tiles_0_addr1 = in_sprite_writer_line;
_d_tiles_0_wdata1 = in_sprite_writer_bitmap;
// __block_7
  end
  1: begin
// __block_8_case
// __block_9
_d_tiles_1_addr1 = in_sprite_writer_line;
_d_tiles_1_wdata1 = in_sprite_writer_bitmap;
// __block_10
  end
  2: begin
// __block_11_case
// __block_12
_d_tiles_2_addr1 = in_sprite_writer_line;
_d_tiles_2_wdata1 = in_sprite_writer_bitmap;
// __block_13
  end
  3: begin
// __block_14_case
// __block_15
_d_tiles_3_addr1 = in_sprite_writer_line;
_d_tiles_3_wdata1 = in_sprite_writer_bitmap;
// __block_16
  end
  4: begin
// __block_17_case
// __block_18
_d_tiles_4_addr1 = in_sprite_writer_line;
_d_tiles_4_wdata1 = in_sprite_writer_bitmap;
// __block_19
  end
  5: begin
// __block_20_case
// __block_21
_d_tiles_5_addr1 = in_sprite_writer_line;
_d_tiles_5_wdata1 = in_sprite_writer_bitmap;
// __block_22
  end
  6: begin
// __block_23_case
// __block_24
_d_tiles_6_addr1 = in_sprite_writer_line;
_d_tiles_6_wdata1 = in_sprite_writer_bitmap;
// __block_25
  end
  7: begin
// __block_26_case
// __block_27
_d_tiles_7_addr1 = in_sprite_writer_line;
_d_tiles_7_wdata1 = in_sprite_writer_bitmap;
// __block_28
  end
  8: begin
// __block_29_case
// __block_30
_d_tiles_8_addr1 = in_sprite_writer_line;
_d_tiles_8_wdata1 = in_sprite_writer_bitmap;
// __block_31
  end
  9: begin
// __block_32_case
// __block_33
_d_tiles_9_addr1 = in_sprite_writer_line;
_d_tiles_9_wdata1 = in_sprite_writer_bitmap;
// __block_34
  end
  10: begin
// __block_35_case
// __block_36
_d_tiles_10_addr1 = in_sprite_writer_line;
_d_tiles_10_wdata1 = in_sprite_writer_bitmap;
// __block_37
  end
  11: begin
// __block_38_case
// __block_39
_d_tiles_11_addr1 = in_sprite_writer_line;
_d_tiles_11_wdata1 = in_sprite_writer_bitmap;
// __block_40
  end
  12: begin
// __block_41_case
// __block_42
_d_tiles_12_addr1 = in_sprite_writer_line;
_d_tiles_12_wdata1 = in_sprite_writer_bitmap;
// __block_43
  end
endcase
// __block_4
// __block_44
end else begin
// __block_2
end
// __block_45
  case (in_sprite_layer_write)
  1: begin
// __block_47_case
// __block_48
_d_sprite_active[in_sprite_set_number] = in_sprite_set_active;
// __block_49
  end
  2: begin
// __block_50_case
// __block_51
_d_sprite_tile_number[in_sprite_set_number] = in_sprite_set_tile;
// __block_52
  end
  3: begin
// __block_53_case
// __block_54
_d_sprite_colour[in_sprite_set_number] = in_sprite_set_colour;
// __block_55
  end
  4: begin
// __block_56_case
// __block_57
_d_sprite_x[in_sprite_set_number] = in_sprite_set_x;
// __block_58
  end
  5: begin
// __block_59_case
// __block_60
_d_sprite_y[in_sprite_set_number] = in_sprite_set_y;
// __block_61
  end
  6: begin
// __block_62_case
// __block_63
_d_sprite_double[in_sprite_set_number] = in_sprite_set_double;
// __block_64
  end
  10: begin
// __block_65_case
// __block_66
_d_sprite_colour[in_sprite_set_number] = (in_sprite_update[15+:1])?in_sprite_update[9+:6]:_q_sprite_colour[in_sprite_set_number];
_d_sprite_tile_number[in_sprite_set_number] = (in_sprite_update[6+:1])?_q_sprite_tile_number[in_sprite_set_number]+1:_q_sprite_tile_number[in_sprite_set_number];
  case ({(_q_sprite_y[in_sprite_set_number]<(-16))||(_q_sprite_y[in_sprite_set_number]>480),(_q_sprite_x[in_sprite_set_number]<(-16))||(_q_sprite_x[in_sprite_set_number]>640)})
  2'b00: begin
// __block_68_case
// __block_69
_d_sprite_x[in_sprite_set_number] = _q_sprite_x[in_sprite_set_number]+_w_deltax;
_d_sprite_y[in_sprite_set_number] = _q_sprite_y[in_sprite_set_number]+_w_deltay;
// __block_70
  end
  2'b01: begin
// __block_71_case
// __block_72
_d_sprite_x[in_sprite_set_number] = (_q_sprite_x[in_sprite_set_number]<(-16))?640:-16;
_d_sprite_y[in_sprite_set_number] = _q_sprite_y[in_sprite_set_number]+_w_deltay;
_d_sprite_active[in_sprite_set_number] = (in_sprite_update[7+:1])?0:_q_sprite_active[in_sprite_set_number];
// __block_73
  end
  2'b10: begin
// __block_74_case
// __block_75
_d_sprite_x[in_sprite_set_number] = _q_sprite_x[in_sprite_set_number]+_w_deltax;
_d_sprite_y[in_sprite_set_number] = (_q_sprite_y[in_sprite_set_number]<(-16))?480:-16;
_d_sprite_active[in_sprite_set_number] = (in_sprite_update[8+:1])?0:_q_sprite_active[in_sprite_set_number];
// __block_76
  end
  2'b11: begin
// __block_77_case
// __block_78
_d_sprite_active[in_sprite_set_number] = (in_sprite_update[7+:1])||(in_sprite_update[8+:1])?0:_q_sprite_active[in_sprite_set_number];
// __block_79
  end
endcase
// __block_67
// __block_80
  end
endcase
// __block_46
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
_d_tiles_0_wenable0 = 0;
_d_tiles_0_addr0 = 0;
_d_tiles_0_wenable1 = 0;
_d_tiles_0_wdata1 = 0;
_d_tiles_0_addr1 = 0;
_d_tiles_1_wenable0 = 0;
_d_tiles_1_addr0 = 0;
_d_tiles_1_wenable1 = 0;
_d_tiles_1_wdata1 = 0;
_d_tiles_1_addr1 = 0;
_d_tiles_2_wenable0 = 0;
_d_tiles_2_addr0 = 0;
_d_tiles_2_wenable1 = 0;
_d_tiles_2_wdata1 = 0;
_d_tiles_2_addr1 = 0;
_d_tiles_3_wenable0 = 0;
_d_tiles_3_addr0 = 0;
_d_tiles_3_wenable1 = 0;
_d_tiles_3_wdata1 = 0;
_d_tiles_3_addr1 = 0;
_d_tiles_4_wenable0 = 0;
_d_tiles_4_addr0 = 0;
_d_tiles_4_wenable1 = 0;
_d_tiles_4_wdata1 = 0;
_d_tiles_4_addr1 = 0;
_d_tiles_5_wenable0 = 0;
_d_tiles_5_addr0 = 0;
_d_tiles_5_wenable1 = 0;
_d_tiles_5_wdata1 = 0;
_d_tiles_5_addr1 = 0;
_d_tiles_6_wenable0 = 0;
_d_tiles_6_addr0 = 0;
_d_tiles_6_wenable1 = 0;
_d_tiles_6_wdata1 = 0;
_d_tiles_6_addr1 = 0;
_d_tiles_7_wenable0 = 0;
_d_tiles_7_addr0 = 0;
_d_tiles_7_wenable1 = 0;
_d_tiles_7_wdata1 = 0;
_d_tiles_7_addr1 = 0;
_d_tiles_8_wenable0 = 0;
_d_tiles_8_addr0 = 0;
_d_tiles_8_wenable1 = 0;
_d_tiles_8_wdata1 = 0;
_d_tiles_8_addr1 = 0;
_d_tiles_9_wenable0 = 0;
_d_tiles_9_addr0 = 0;
_d_tiles_9_wenable1 = 0;
_d_tiles_9_wdata1 = 0;
_d_tiles_9_addr1 = 0;
_d_tiles_10_wenable0 = 0;
_d_tiles_10_addr0 = 0;
_d_tiles_10_wenable1 = 0;
_d_tiles_10_wdata1 = 0;
_d_tiles_10_addr1 = 0;
_d_tiles_11_wenable0 = 0;
_d_tiles_11_addr0 = 0;
_d_tiles_11_wenable1 = 0;
_d_tiles_11_wdata1 = 0;
_d_tiles_11_addr1 = 0;
_d_tiles_12_wenable0 = 0;
_d_tiles_12_addr0 = 0;
_d_tiles_12_wenable1 = 0;
_d_tiles_12_wdata1 = 0;
_d_tiles_12_addr1 = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_81
if (1) begin
// __block_82
// __block_84
if (in_pix_vblank) begin
// __block_85
// __block_87
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
// __block_88
end else begin
// __block_86
// __block_89
if (in_pix_active) begin
// __block_90
// __block_92
if ((_w_pix_visible_0)) begin
// __block_93
// __block_95
_d_pix_red = _d_sprite_colour[0][4+:2];
_d_pix_green = _d_sprite_colour[0][2+:2];
_d_pix_blue = _d_sprite_colour[0][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_0 = _q_detect_collision_0|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_96
end else begin
// __block_94
end
// __block_97
if ((_w_pix_visible_1)) begin
// __block_98
// __block_100
_d_pix_red = _d_sprite_colour[1][4+:2];
_d_pix_green = _d_sprite_colour[1][2+:2];
_d_pix_blue = _d_sprite_colour[1][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_1 = _q_detect_collision_1|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_101
end else begin
// __block_99
end
// __block_102
if ((_w_pix_visible_2)) begin
// __block_103
// __block_105
_d_pix_red = _d_sprite_colour[2][4+:2];
_d_pix_green = _d_sprite_colour[2][2+:2];
_d_pix_blue = _d_sprite_colour[2][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_2 = _q_detect_collision_2|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_106
end else begin
// __block_104
end
// __block_107
if ((_w_pix_visible_3)) begin
// __block_108
// __block_110
_d_pix_red = _d_sprite_colour[3][4+:2];
_d_pix_green = _d_sprite_colour[3][2+:2];
_d_pix_blue = _d_sprite_colour[3][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_3 = _q_detect_collision_3|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_111
end else begin
// __block_109
end
// __block_112
if ((_w_pix_visible_4)) begin
// __block_113
// __block_115
_d_pix_red = _d_sprite_colour[4][4+:2];
_d_pix_green = _d_sprite_colour[4][2+:2];
_d_pix_blue = _d_sprite_colour[4][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_4 = _q_detect_collision_4|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_116
end else begin
// __block_114
end
// __block_117
if ((_w_pix_visible_5)) begin
// __block_118
// __block_120
_d_pix_red = _d_sprite_colour[5][4+:2];
_d_pix_green = _d_sprite_colour[5][2+:2];
_d_pix_blue = _d_sprite_colour[5][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_5 = _q_detect_collision_5|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_121
end else begin
// __block_119
end
// __block_122
if ((_w_pix_visible_6)) begin
// __block_123
// __block_125
_d_pix_red = _d_sprite_colour[6][4+:2];
_d_pix_green = _d_sprite_colour[6][2+:2];
_d_pix_blue = _d_sprite_colour[6][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_6 = _q_detect_collision_6|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_126
end else begin
// __block_124
end
// __block_127
if ((_w_pix_visible_7)) begin
// __block_128
// __block_130
_d_pix_red = _d_sprite_colour[7][4+:2];
_d_pix_green = _d_sprite_colour[7][2+:2];
_d_pix_blue = _d_sprite_colour[7][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_7 = _q_detect_collision_7|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_131
end else begin
// __block_129
end
// __block_132
if ((_w_pix_visible_8)) begin
// __block_133
// __block_135
_d_pix_red = _d_sprite_colour[8][4+:2];
_d_pix_green = _d_sprite_colour[8][2+:2];
_d_pix_blue = _d_sprite_colour[8][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_8 = _q_detect_collision_8|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_136
end else begin
// __block_134
end
// __block_137
if ((_w_pix_visible_9)) begin
// __block_138
// __block_140
_d_pix_red = _d_sprite_colour[9][4+:2];
_d_pix_green = _d_sprite_colour[9][2+:2];
_d_pix_blue = _d_sprite_colour[9][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_9 = _q_detect_collision_9|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_141
end else begin
// __block_139
end
// __block_142
if ((_w_pix_visible_10)) begin
// __block_143
// __block_145
_d_pix_red = _d_sprite_colour[10][4+:2];
_d_pix_green = _d_sprite_colour[10][2+:2];
_d_pix_blue = _d_sprite_colour[10][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_10 = _q_detect_collision_10|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_146
end else begin
// __block_144
end
// __block_147
if ((_w_pix_visible_11)) begin
// __block_148
// __block_150
_d_pix_red = _d_sprite_colour[11][4+:2];
_d_pix_green = _d_sprite_colour[11][2+:2];
_d_pix_blue = _d_sprite_colour[11][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_11 = _q_detect_collision_11|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_151
end else begin
// __block_149
end
// __block_152
if ((_w_pix_visible_12)) begin
// __block_153
// __block_155
_d_pix_red = _d_sprite_colour[12][4+:2];
_d_pix_green = _d_sprite_colour[12][2+:2];
_d_pix_blue = _d_sprite_colour[12][0+:2];
_d_sprite_layer_display = 1;
_d_detect_collision_12 = _q_detect_collision_12|{in_collision_layer_1,in_collision_layer_2,in_collision_layer_3,_w_pix_visible_12,_w_pix_visible_11,_w_pix_visible_10,_w_pix_visible_9,_w_pix_visible_8,_w_pix_visible_7,_w_pix_visible_6,_w_pix_visible_5,_w_pix_visible_4,_w_pix_visible_3,_w_pix_visible_2,_w_pix_visible_1,_w_pix_visible_0};
// __block_156
end else begin
// __block_154
end
// __block_157
// __block_158
end else begin
// __block_91
end
// __block_159
// __block_160
end
// __block_161
if ((in_pix_x==639)&&(in_pix_y==479)) begin
// __block_162
// __block_164
_d_collision_0 = _d_detect_collision_0;
_d_collision_1 = _d_detect_collision_1;
_d_collision_2 = _d_detect_collision_2;
_d_collision_3 = _d_detect_collision_3;
_d_collision_4 = _d_detect_collision_4;
_d_collision_5 = _d_detect_collision_5;
_d_collision_6 = _d_detect_collision_6;
_d_collision_7 = _d_detect_collision_7;
_d_collision_8 = _d_detect_collision_8;
_d_collision_9 = _d_detect_collision_9;
_d_collision_10 = _d_detect_collision_10;
_d_collision_11 = _d_detect_collision_11;
_d_collision_12 = _d_detect_collision_12;
// __block_165
end else begin
// __block_163
end
// __block_166
// __block_167
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_83
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
input      [0:0]             in_tiles16x16_wenable0,
input       [15:0]     in_tiles16x16_wdata0,
input      [8:0]                in_tiles16x16_addr0,
input      [0:0]             in_tiles16x16_wenable1,
input      [15:0]                 in_tiles16x16_wdata1,
input      [8:0]                in_tiles16x16_addr1,
output reg  [15:0]     out_tiles16x16_rdata0,
output reg  [15:0]     out_tiles16x16_rdata1,
input      clock0,
input      clock1
);
reg  [15:0] buffer[511:0];
always @(posedge clock0) begin
  if (in_tiles16x16_wenable0) begin
    buffer[in_tiles16x16_addr0] <= in_tiles16x16_wdata0;
  end else begin
    out_tiles16x16_rdata0 <= buffer[in_tiles16x16_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tiles16x16_wenable1) begin
    buffer[in_tiles16x16_addr1] <= in_tiles16x16_wdata1;
  end else begin
    out_tiles16x16_rdata1 <= buffer[in_tiles16x16_addr1];
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

module M_tilemap_mem_tile(
input      [0:0]             in_tile_wenable0,
input       [4:0]     in_tile_wdata0,
input      [10:0]                in_tile_addr0,
input      [0:0]             in_tile_wenable1,
input      [4:0]                 in_tile_wdata1,
input      [10:0]                in_tile_addr1,
output reg  [4:0]     out_tile_rdata0,
output reg  [4:0]     out_tile_rdata1,
input      clock0,
input      clock1
);
reg  [4:0] buffer[1343:0];
always @(posedge clock0) begin
  if (in_tile_wenable0) begin
    buffer[in_tile_addr0] <= in_tile_wdata0;
  end else begin
    out_tile_rdata0 <= buffer[in_tile_addr0];
  end
end
always @(posedge clock1) begin
  if (in_tile_wenable1) begin
    buffer[in_tile_addr1] <= in_tile_wdata1;
  end else begin
    out_tile_rdata1 <= buffer[in_tile_addr1];
  end
end

endmodule

module M_tilemap_mem_foreground(
input      [0:0]             in_foreground_wenable0,
input       [5:0]     in_foreground_wdata0,
input      [10:0]                in_foreground_addr0,
input      [0:0]             in_foreground_wenable1,
input      [5:0]                 in_foreground_wdata1,
input      [10:0]                in_foreground_addr1,
output reg  [5:0]     out_foreground_rdata0,
output reg  [5:0]     out_foreground_rdata1,
input      clock0,
input      clock1
);
reg  [5:0] buffer[1343:0];
always @(posedge clock0) begin
  if (in_foreground_wenable0) begin
    buffer[in_foreground_addr0] <= in_foreground_wdata0;
  end else begin
    out_foreground_rdata0 <= buffer[in_foreground_addr0];
  end
end
always @(posedge clock1) begin
  if (in_foreground_wenable1) begin
    buffer[in_foreground_addr1] <= in_foreground_wdata1;
  end else begin
    out_foreground_rdata1 <= buffer[in_foreground_addr1];
  end
end

endmodule

module M_tilemap_mem_background(
input      [0:0]             in_background_wenable0,
input       [6:0]     in_background_wdata0,
input      [10:0]                in_background_addr0,
input      [0:0]             in_background_wenable1,
input      [6:0]                 in_background_wdata1,
input      [10:0]                in_background_addr1,
output reg  [6:0]     out_background_rdata0,
output reg  [6:0]     out_background_rdata1,
input      clock0,
input      clock1
);
reg  [6:0] buffer[1343:0];
always @(posedge clock0) begin
  if (in_background_wenable0) begin
    buffer[in_background_addr0] <= in_background_wdata0;
  end else begin
    out_background_rdata0 <= buffer[in_background_addr0];
  end
end
always @(posedge clock1) begin
  if (in_background_wenable1) begin
    buffer[in_background_addr1] <= in_background_wdata1;
  end else begin
    out_background_rdata1 <= buffer[in_background_addr1];
  end
end
initial begin
 buffer[0] = 7'h40;
 buffer[1] = 7'h40;
 buffer[2] = 7'h40;
 buffer[3] = 7'h40;
 buffer[4] = 7'h40;
 buffer[5] = 7'h40;
 buffer[6] = 7'h40;
 buffer[7] = 7'h40;
 buffer[8] = 7'h40;
 buffer[9] = 7'h40;
 buffer[10] = 7'h40;
 buffer[11] = 7'h40;
 buffer[12] = 7'h40;
 buffer[13] = 7'h40;
 buffer[14] = 7'h40;
 buffer[15] = 7'h40;
 buffer[16] = 7'h40;
 buffer[17] = 7'h40;
 buffer[18] = 7'h40;
 buffer[19] = 7'h40;
 buffer[20] = 7'h40;
 buffer[21] = 7'h40;
 buffer[22] = 7'h40;
 buffer[23] = 7'h40;
 buffer[24] = 7'h40;
 buffer[25] = 7'h40;
 buffer[26] = 7'h40;
 buffer[27] = 7'h40;
 buffer[28] = 7'h40;
 buffer[29] = 7'h40;
 buffer[30] = 7'h40;
 buffer[31] = 7'h40;
 buffer[32] = 7'h40;
 buffer[33] = 7'h40;
 buffer[34] = 7'h40;
 buffer[35] = 7'h40;
 buffer[36] = 7'h40;
 buffer[37] = 7'h40;
 buffer[38] = 7'h40;
 buffer[39] = 7'h40;
 buffer[40] = 7'h40;
 buffer[41] = 7'h40;
 buffer[42] = 7'h40;
 buffer[43] = 7'h40;
 buffer[44] = 7'h40;
 buffer[45] = 7'h40;
 buffer[46] = 7'h40;
 buffer[47] = 7'h40;
 buffer[48] = 7'h40;
 buffer[49] = 7'h40;
 buffer[50] = 7'h40;
 buffer[51] = 7'h40;
 buffer[52] = 7'h40;
 buffer[53] = 7'h40;
 buffer[54] = 7'h40;
 buffer[55] = 7'h40;
 buffer[56] = 7'h40;
 buffer[57] = 7'h40;
 buffer[58] = 7'h40;
 buffer[59] = 7'h40;
 buffer[60] = 7'h40;
 buffer[61] = 7'h40;
 buffer[62] = 7'h40;
 buffer[63] = 7'h40;
 buffer[64] = 7'h40;
 buffer[65] = 7'h40;
 buffer[66] = 7'h40;
 buffer[67] = 7'h40;
 buffer[68] = 7'h40;
 buffer[69] = 7'h40;
 buffer[70] = 7'h40;
 buffer[71] = 7'h40;
 buffer[72] = 7'h40;
 buffer[73] = 7'h40;
 buffer[74] = 7'h40;
 buffer[75] = 7'h40;
 buffer[76] = 7'h40;
 buffer[77] = 7'h40;
 buffer[78] = 7'h40;
 buffer[79] = 7'h40;
 buffer[80] = 7'h40;
 buffer[81] = 7'h40;
 buffer[82] = 7'h40;
 buffer[83] = 7'h40;
 buffer[84] = 7'h40;
 buffer[85] = 7'h40;
 buffer[86] = 7'h40;
 buffer[87] = 7'h40;
 buffer[88] = 7'h40;
 buffer[89] = 7'h40;
 buffer[90] = 7'h40;
 buffer[91] = 7'h40;
 buffer[92] = 7'h40;
 buffer[93] = 7'h40;
 buffer[94] = 7'h40;
 buffer[95] = 7'h40;
 buffer[96] = 7'h40;
 buffer[97] = 7'h40;
 buffer[98] = 7'h40;
 buffer[99] = 7'h40;
 buffer[100] = 7'h40;
 buffer[101] = 7'h40;
 buffer[102] = 7'h40;
 buffer[103] = 7'h40;
 buffer[104] = 7'h40;
 buffer[105] = 7'h40;
 buffer[106] = 7'h40;
 buffer[107] = 7'h40;
 buffer[108] = 7'h40;
 buffer[109] = 7'h40;
 buffer[110] = 7'h40;
 buffer[111] = 7'h40;
 buffer[112] = 7'h40;
 buffer[113] = 7'h40;
 buffer[114] = 7'h40;
 buffer[115] = 7'h40;
 buffer[116] = 7'h40;
 buffer[117] = 7'h40;
 buffer[118] = 7'h40;
 buffer[119] = 7'h40;
 buffer[120] = 7'h40;
 buffer[121] = 7'h40;
 buffer[122] = 7'h40;
 buffer[123] = 7'h40;
 buffer[124] = 7'h40;
 buffer[125] = 7'h40;
 buffer[126] = 7'h40;
 buffer[127] = 7'h40;
 buffer[128] = 7'h40;
 buffer[129] = 7'h40;
 buffer[130] = 7'h40;
 buffer[131] = 7'h40;
 buffer[132] = 7'h40;
 buffer[133] = 7'h40;
 buffer[134] = 7'h40;
 buffer[135] = 7'h40;
 buffer[136] = 7'h40;
 buffer[137] = 7'h40;
 buffer[138] = 7'h40;
 buffer[139] = 7'h40;
 buffer[140] = 7'h40;
 buffer[141] = 7'h40;
 buffer[142] = 7'h40;
 buffer[143] = 7'h40;
 buffer[144] = 7'h40;
 buffer[145] = 7'h40;
 buffer[146] = 7'h40;
 buffer[147] = 7'h40;
 buffer[148] = 7'h40;
 buffer[149] = 7'h40;
 buffer[150] = 7'h40;
 buffer[151] = 7'h40;
 buffer[152] = 7'h40;
 buffer[153] = 7'h40;
 buffer[154] = 7'h40;
 buffer[155] = 7'h40;
 buffer[156] = 7'h40;
 buffer[157] = 7'h40;
 buffer[158] = 7'h40;
 buffer[159] = 7'h40;
 buffer[160] = 7'h40;
 buffer[161] = 7'h40;
 buffer[162] = 7'h40;
 buffer[163] = 7'h40;
 buffer[164] = 7'h40;
 buffer[165] = 7'h40;
 buffer[166] = 7'h40;
 buffer[167] = 7'h40;
 buffer[168] = 7'h40;
 buffer[169] = 7'h40;
 buffer[170] = 7'h40;
 buffer[171] = 7'h40;
 buffer[172] = 7'h40;
 buffer[173] = 7'h40;
 buffer[174] = 7'h40;
 buffer[175] = 7'h40;
 buffer[176] = 7'h40;
 buffer[177] = 7'h40;
 buffer[178] = 7'h40;
 buffer[179] = 7'h40;
 buffer[180] = 7'h40;
 buffer[181] = 7'h40;
 buffer[182] = 7'h40;
 buffer[183] = 7'h40;
 buffer[184] = 7'h40;
 buffer[185] = 7'h40;
 buffer[186] = 7'h40;
 buffer[187] = 7'h40;
 buffer[188] = 7'h40;
 buffer[189] = 7'h40;
 buffer[190] = 7'h40;
 buffer[191] = 7'h40;
 buffer[192] = 7'h40;
 buffer[193] = 7'h40;
 buffer[194] = 7'h40;
 buffer[195] = 7'h40;
 buffer[196] = 7'h40;
 buffer[197] = 7'h40;
 buffer[198] = 7'h40;
 buffer[199] = 7'h40;
 buffer[200] = 7'h40;
 buffer[201] = 7'h40;
 buffer[202] = 7'h40;
 buffer[203] = 7'h40;
 buffer[204] = 7'h40;
 buffer[205] = 7'h40;
 buffer[206] = 7'h40;
 buffer[207] = 7'h40;
 buffer[208] = 7'h40;
 buffer[209] = 7'h40;
 buffer[210] = 7'h40;
 buffer[211] = 7'h40;
 buffer[212] = 7'h40;
 buffer[213] = 7'h40;
 buffer[214] = 7'h40;
 buffer[215] = 7'h40;
 buffer[216] = 7'h40;
 buffer[217] = 7'h40;
 buffer[218] = 7'h40;
 buffer[219] = 7'h40;
 buffer[220] = 7'h40;
 buffer[221] = 7'h40;
 buffer[222] = 7'h40;
 buffer[223] = 7'h40;
 buffer[224] = 7'h40;
 buffer[225] = 7'h40;
 buffer[226] = 7'h40;
 buffer[227] = 7'h40;
 buffer[228] = 7'h40;
 buffer[229] = 7'h40;
 buffer[230] = 7'h40;
 buffer[231] = 7'h40;
 buffer[232] = 7'h40;
 buffer[233] = 7'h40;
 buffer[234] = 7'h40;
 buffer[235] = 7'h40;
 buffer[236] = 7'h40;
 buffer[237] = 7'h40;
 buffer[238] = 7'h40;
 buffer[239] = 7'h40;
 buffer[240] = 7'h40;
 buffer[241] = 7'h40;
 buffer[242] = 7'h40;
 buffer[243] = 7'h40;
 buffer[244] = 7'h40;
 buffer[245] = 7'h40;
 buffer[246] = 7'h40;
 buffer[247] = 7'h40;
 buffer[248] = 7'h40;
 buffer[249] = 7'h40;
 buffer[250] = 7'h40;
 buffer[251] = 7'h40;
 buffer[252] = 7'h40;
 buffer[253] = 7'h40;
 buffer[254] = 7'h40;
 buffer[255] = 7'h40;
 buffer[256] = 7'h40;
 buffer[257] = 7'h40;
 buffer[258] = 7'h40;
 buffer[259] = 7'h40;
 buffer[260] = 7'h40;
 buffer[261] = 7'h40;
 buffer[262] = 7'h40;
 buffer[263] = 7'h40;
 buffer[264] = 7'h40;
 buffer[265] = 7'h40;
 buffer[266] = 7'h40;
 buffer[267] = 7'h40;
 buffer[268] = 7'h40;
 buffer[269] = 7'h40;
 buffer[270] = 7'h40;
 buffer[271] = 7'h40;
 buffer[272] = 7'h40;
 buffer[273] = 7'h40;
 buffer[274] = 7'h40;
 buffer[275] = 7'h40;
 buffer[276] = 7'h40;
 buffer[277] = 7'h40;
 buffer[278] = 7'h40;
 buffer[279] = 7'h40;
 buffer[280] = 7'h40;
 buffer[281] = 7'h40;
 buffer[282] = 7'h40;
 buffer[283] = 7'h40;
 buffer[284] = 7'h40;
 buffer[285] = 7'h40;
 buffer[286] = 7'h40;
 buffer[287] = 7'h40;
 buffer[288] = 7'h40;
 buffer[289] = 7'h40;
 buffer[290] = 7'h40;
 buffer[291] = 7'h40;
 buffer[292] = 7'h40;
 buffer[293] = 7'h40;
 buffer[294] = 7'h40;
 buffer[295] = 7'h40;
 buffer[296] = 7'h40;
 buffer[297] = 7'h40;
 buffer[298] = 7'h40;
 buffer[299] = 7'h40;
 buffer[300] = 7'h40;
 buffer[301] = 7'h40;
 buffer[302] = 7'h40;
 buffer[303] = 7'h40;
 buffer[304] = 7'h40;
 buffer[305] = 7'h40;
 buffer[306] = 7'h40;
 buffer[307] = 7'h40;
 buffer[308] = 7'h40;
 buffer[309] = 7'h40;
 buffer[310] = 7'h40;
 buffer[311] = 7'h40;
 buffer[312] = 7'h40;
 buffer[313] = 7'h40;
 buffer[314] = 7'h40;
 buffer[315] = 7'h40;
 buffer[316] = 7'h40;
 buffer[317] = 7'h40;
 buffer[318] = 7'h40;
 buffer[319] = 7'h40;
 buffer[320] = 7'h40;
 buffer[321] = 7'h40;
 buffer[322] = 7'h40;
 buffer[323] = 7'h40;
 buffer[324] = 7'h40;
 buffer[325] = 7'h40;
 buffer[326] = 7'h40;
 buffer[327] = 7'h40;
 buffer[328] = 7'h40;
 buffer[329] = 7'h40;
 buffer[330] = 7'h40;
 buffer[331] = 7'h40;
 buffer[332] = 7'h40;
 buffer[333] = 7'h40;
 buffer[334] = 7'h40;
 buffer[335] = 7'h40;
 buffer[336] = 7'h40;
 buffer[337] = 7'h40;
 buffer[338] = 7'h40;
 buffer[339] = 7'h40;
 buffer[340] = 7'h40;
 buffer[341] = 7'h40;
 buffer[342] = 7'h40;
 buffer[343] = 7'h40;
 buffer[344] = 7'h40;
 buffer[345] = 7'h40;
 buffer[346] = 7'h40;
 buffer[347] = 7'h40;
 buffer[348] = 7'h40;
 buffer[349] = 7'h40;
 buffer[350] = 7'h40;
 buffer[351] = 7'h40;
 buffer[352] = 7'h40;
 buffer[353] = 7'h40;
 buffer[354] = 7'h40;
 buffer[355] = 7'h40;
 buffer[356] = 7'h40;
 buffer[357] = 7'h40;
 buffer[358] = 7'h40;
 buffer[359] = 7'h40;
 buffer[360] = 7'h40;
 buffer[361] = 7'h40;
 buffer[362] = 7'h40;
 buffer[363] = 7'h40;
 buffer[364] = 7'h40;
 buffer[365] = 7'h40;
 buffer[366] = 7'h40;
 buffer[367] = 7'h40;
 buffer[368] = 7'h40;
 buffer[369] = 7'h40;
 buffer[370] = 7'h40;
 buffer[371] = 7'h40;
 buffer[372] = 7'h40;
 buffer[373] = 7'h40;
 buffer[374] = 7'h40;
 buffer[375] = 7'h40;
 buffer[376] = 7'h40;
 buffer[377] = 7'h40;
 buffer[378] = 7'h40;
 buffer[379] = 7'h40;
 buffer[380] = 7'h40;
 buffer[381] = 7'h40;
 buffer[382] = 7'h40;
 buffer[383] = 7'h40;
 buffer[384] = 7'h40;
 buffer[385] = 7'h40;
 buffer[386] = 7'h40;
 buffer[387] = 7'h40;
 buffer[388] = 7'h40;
 buffer[389] = 7'h40;
 buffer[390] = 7'h40;
 buffer[391] = 7'h40;
 buffer[392] = 7'h40;
 buffer[393] = 7'h40;
 buffer[394] = 7'h40;
 buffer[395] = 7'h40;
 buffer[396] = 7'h40;
 buffer[397] = 7'h40;
 buffer[398] = 7'h40;
 buffer[399] = 7'h40;
 buffer[400] = 7'h40;
 buffer[401] = 7'h40;
 buffer[402] = 7'h40;
 buffer[403] = 7'h40;
 buffer[404] = 7'h40;
 buffer[405] = 7'h40;
 buffer[406] = 7'h40;
 buffer[407] = 7'h40;
 buffer[408] = 7'h40;
 buffer[409] = 7'h40;
 buffer[410] = 7'h40;
 buffer[411] = 7'h40;
 buffer[412] = 7'h40;
 buffer[413] = 7'h40;
 buffer[414] = 7'h40;
 buffer[415] = 7'h40;
 buffer[416] = 7'h40;
 buffer[417] = 7'h40;
 buffer[418] = 7'h40;
 buffer[419] = 7'h40;
 buffer[420] = 7'h40;
 buffer[421] = 7'h40;
 buffer[422] = 7'h40;
 buffer[423] = 7'h40;
 buffer[424] = 7'h40;
 buffer[425] = 7'h40;
 buffer[426] = 7'h40;
 buffer[427] = 7'h40;
 buffer[428] = 7'h40;
 buffer[429] = 7'h40;
 buffer[430] = 7'h40;
 buffer[431] = 7'h40;
 buffer[432] = 7'h40;
 buffer[433] = 7'h40;
 buffer[434] = 7'h40;
 buffer[435] = 7'h40;
 buffer[436] = 7'h40;
 buffer[437] = 7'h40;
 buffer[438] = 7'h40;
 buffer[439] = 7'h40;
 buffer[440] = 7'h40;
 buffer[441] = 7'h40;
 buffer[442] = 7'h40;
 buffer[443] = 7'h40;
 buffer[444] = 7'h40;
 buffer[445] = 7'h40;
 buffer[446] = 7'h40;
 buffer[447] = 7'h40;
 buffer[448] = 7'h40;
 buffer[449] = 7'h40;
 buffer[450] = 7'h40;
 buffer[451] = 7'h40;
 buffer[452] = 7'h40;
 buffer[453] = 7'h40;
 buffer[454] = 7'h40;
 buffer[455] = 7'h40;
 buffer[456] = 7'h40;
 buffer[457] = 7'h40;
 buffer[458] = 7'h40;
 buffer[459] = 7'h40;
 buffer[460] = 7'h40;
 buffer[461] = 7'h40;
 buffer[462] = 7'h40;
 buffer[463] = 7'h40;
 buffer[464] = 7'h40;
 buffer[465] = 7'h40;
 buffer[466] = 7'h40;
 buffer[467] = 7'h40;
 buffer[468] = 7'h40;
 buffer[469] = 7'h40;
 buffer[470] = 7'h40;
 buffer[471] = 7'h40;
 buffer[472] = 7'h40;
 buffer[473] = 7'h40;
 buffer[474] = 7'h40;
 buffer[475] = 7'h40;
 buffer[476] = 7'h40;
 buffer[477] = 7'h40;
 buffer[478] = 7'h40;
 buffer[479] = 7'h40;
 buffer[480] = 7'h40;
 buffer[481] = 7'h40;
 buffer[482] = 7'h40;
 buffer[483] = 7'h40;
 buffer[484] = 7'h40;
 buffer[485] = 7'h40;
 buffer[486] = 7'h40;
 buffer[487] = 7'h40;
 buffer[488] = 7'h40;
 buffer[489] = 7'h40;
 buffer[490] = 7'h40;
 buffer[491] = 7'h40;
 buffer[492] = 7'h40;
 buffer[493] = 7'h40;
 buffer[494] = 7'h40;
 buffer[495] = 7'h40;
 buffer[496] = 7'h40;
 buffer[497] = 7'h40;
 buffer[498] = 7'h40;
 buffer[499] = 7'h40;
 buffer[500] = 7'h40;
 buffer[501] = 7'h40;
 buffer[502] = 7'h40;
 buffer[503] = 7'h40;
 buffer[504] = 7'h40;
 buffer[505] = 7'h40;
 buffer[506] = 7'h40;
 buffer[507] = 7'h40;
 buffer[508] = 7'h40;
 buffer[509] = 7'h40;
 buffer[510] = 7'h40;
 buffer[511] = 7'h40;
 buffer[512] = 7'h40;
 buffer[513] = 7'h40;
 buffer[514] = 7'h40;
 buffer[515] = 7'h40;
 buffer[516] = 7'h40;
 buffer[517] = 7'h40;
 buffer[518] = 7'h40;
 buffer[519] = 7'h40;
 buffer[520] = 7'h40;
 buffer[521] = 7'h40;
 buffer[522] = 7'h40;
 buffer[523] = 7'h40;
 buffer[524] = 7'h40;
 buffer[525] = 7'h40;
 buffer[526] = 7'h40;
 buffer[527] = 7'h40;
 buffer[528] = 7'h40;
 buffer[529] = 7'h40;
 buffer[530] = 7'h40;
 buffer[531] = 7'h40;
 buffer[532] = 7'h40;
 buffer[533] = 7'h40;
 buffer[534] = 7'h40;
 buffer[535] = 7'h40;
 buffer[536] = 7'h40;
 buffer[537] = 7'h40;
 buffer[538] = 7'h40;
 buffer[539] = 7'h40;
 buffer[540] = 7'h40;
 buffer[541] = 7'h40;
 buffer[542] = 7'h40;
 buffer[543] = 7'h40;
 buffer[544] = 7'h40;
 buffer[545] = 7'h40;
 buffer[546] = 7'h40;
 buffer[547] = 7'h40;
 buffer[548] = 7'h40;
 buffer[549] = 7'h40;
 buffer[550] = 7'h40;
 buffer[551] = 7'h40;
 buffer[552] = 7'h40;
 buffer[553] = 7'h40;
 buffer[554] = 7'h40;
 buffer[555] = 7'h40;
 buffer[556] = 7'h40;
 buffer[557] = 7'h40;
 buffer[558] = 7'h40;
 buffer[559] = 7'h40;
 buffer[560] = 7'h40;
 buffer[561] = 7'h40;
 buffer[562] = 7'h40;
 buffer[563] = 7'h40;
 buffer[564] = 7'h40;
 buffer[565] = 7'h40;
 buffer[566] = 7'h40;
 buffer[567] = 7'h40;
 buffer[568] = 7'h40;
 buffer[569] = 7'h40;
 buffer[570] = 7'h40;
 buffer[571] = 7'h40;
 buffer[572] = 7'h40;
 buffer[573] = 7'h40;
 buffer[574] = 7'h40;
 buffer[575] = 7'h40;
 buffer[576] = 7'h40;
 buffer[577] = 7'h40;
 buffer[578] = 7'h40;
 buffer[579] = 7'h40;
 buffer[580] = 7'h40;
 buffer[581] = 7'h40;
 buffer[582] = 7'h40;
 buffer[583] = 7'h40;
 buffer[584] = 7'h40;
 buffer[585] = 7'h40;
 buffer[586] = 7'h40;
 buffer[587] = 7'h40;
 buffer[588] = 7'h40;
 buffer[589] = 7'h40;
 buffer[590] = 7'h40;
 buffer[591] = 7'h40;
 buffer[592] = 7'h40;
 buffer[593] = 7'h40;
 buffer[594] = 7'h40;
 buffer[595] = 7'h40;
 buffer[596] = 7'h40;
 buffer[597] = 7'h40;
 buffer[598] = 7'h40;
 buffer[599] = 7'h40;
 buffer[600] = 7'h40;
 buffer[601] = 7'h40;
 buffer[602] = 7'h40;
 buffer[603] = 7'h40;
 buffer[604] = 7'h40;
 buffer[605] = 7'h40;
 buffer[606] = 7'h40;
 buffer[607] = 7'h40;
 buffer[608] = 7'h40;
 buffer[609] = 7'h40;
 buffer[610] = 7'h40;
 buffer[611] = 7'h40;
 buffer[612] = 7'h40;
 buffer[613] = 7'h40;
 buffer[614] = 7'h40;
 buffer[615] = 7'h40;
 buffer[616] = 7'h40;
 buffer[617] = 7'h40;
 buffer[618] = 7'h40;
 buffer[619] = 7'h40;
 buffer[620] = 7'h40;
 buffer[621] = 7'h40;
 buffer[622] = 7'h40;
 buffer[623] = 7'h40;
 buffer[624] = 7'h40;
 buffer[625] = 7'h40;
 buffer[626] = 7'h40;
 buffer[627] = 7'h40;
 buffer[628] = 7'h40;
 buffer[629] = 7'h40;
 buffer[630] = 7'h40;
 buffer[631] = 7'h40;
 buffer[632] = 7'h40;
 buffer[633] = 7'h40;
 buffer[634] = 7'h40;
 buffer[635] = 7'h40;
 buffer[636] = 7'h40;
 buffer[637] = 7'h40;
 buffer[638] = 7'h40;
 buffer[639] = 7'h40;
 buffer[640] = 7'h40;
 buffer[641] = 7'h40;
 buffer[642] = 7'h40;
 buffer[643] = 7'h40;
 buffer[644] = 7'h40;
 buffer[645] = 7'h40;
 buffer[646] = 7'h40;
 buffer[647] = 7'h40;
 buffer[648] = 7'h40;
 buffer[649] = 7'h40;
 buffer[650] = 7'h40;
 buffer[651] = 7'h40;
 buffer[652] = 7'h40;
 buffer[653] = 7'h40;
 buffer[654] = 7'h40;
 buffer[655] = 7'h40;
 buffer[656] = 7'h40;
 buffer[657] = 7'h40;
 buffer[658] = 7'h40;
 buffer[659] = 7'h40;
 buffer[660] = 7'h40;
 buffer[661] = 7'h40;
 buffer[662] = 7'h40;
 buffer[663] = 7'h40;
 buffer[664] = 7'h40;
 buffer[665] = 7'h40;
 buffer[666] = 7'h40;
 buffer[667] = 7'h40;
 buffer[668] = 7'h40;
 buffer[669] = 7'h40;
 buffer[670] = 7'h40;
 buffer[671] = 7'h40;
 buffer[672] = 7'h40;
 buffer[673] = 7'h40;
 buffer[674] = 7'h40;
 buffer[675] = 7'h40;
 buffer[676] = 7'h40;
 buffer[677] = 7'h40;
 buffer[678] = 7'h40;
 buffer[679] = 7'h40;
 buffer[680] = 7'h40;
 buffer[681] = 7'h40;
 buffer[682] = 7'h40;
 buffer[683] = 7'h40;
 buffer[684] = 7'h40;
 buffer[685] = 7'h40;
 buffer[686] = 7'h40;
 buffer[687] = 7'h40;
 buffer[688] = 7'h40;
 buffer[689] = 7'h40;
 buffer[690] = 7'h40;
 buffer[691] = 7'h40;
 buffer[692] = 7'h40;
 buffer[693] = 7'h40;
 buffer[694] = 7'h40;
 buffer[695] = 7'h40;
 buffer[696] = 7'h40;
 buffer[697] = 7'h40;
 buffer[698] = 7'h40;
 buffer[699] = 7'h40;
 buffer[700] = 7'h40;
 buffer[701] = 7'h40;
 buffer[702] = 7'h40;
 buffer[703] = 7'h40;
 buffer[704] = 7'h40;
 buffer[705] = 7'h40;
 buffer[706] = 7'h40;
 buffer[707] = 7'h40;
 buffer[708] = 7'h40;
 buffer[709] = 7'h40;
 buffer[710] = 7'h40;
 buffer[711] = 7'h40;
 buffer[712] = 7'h40;
 buffer[713] = 7'h40;
 buffer[714] = 7'h40;
 buffer[715] = 7'h40;
 buffer[716] = 7'h40;
 buffer[717] = 7'h40;
 buffer[718] = 7'h40;
 buffer[719] = 7'h40;
 buffer[720] = 7'h40;
 buffer[721] = 7'h40;
 buffer[722] = 7'h40;
 buffer[723] = 7'h40;
 buffer[724] = 7'h40;
 buffer[725] = 7'h40;
 buffer[726] = 7'h40;
 buffer[727] = 7'h40;
 buffer[728] = 7'h40;
 buffer[729] = 7'h40;
 buffer[730] = 7'h40;
 buffer[731] = 7'h40;
 buffer[732] = 7'h40;
 buffer[733] = 7'h40;
 buffer[734] = 7'h40;
 buffer[735] = 7'h40;
 buffer[736] = 7'h40;
 buffer[737] = 7'h40;
 buffer[738] = 7'h40;
 buffer[739] = 7'h40;
 buffer[740] = 7'h40;
 buffer[741] = 7'h40;
 buffer[742] = 7'h40;
 buffer[743] = 7'h40;
 buffer[744] = 7'h40;
 buffer[745] = 7'h40;
 buffer[746] = 7'h40;
 buffer[747] = 7'h40;
 buffer[748] = 7'h40;
 buffer[749] = 7'h40;
 buffer[750] = 7'h40;
 buffer[751] = 7'h40;
 buffer[752] = 7'h40;
 buffer[753] = 7'h40;
 buffer[754] = 7'h40;
 buffer[755] = 7'h40;
 buffer[756] = 7'h40;
 buffer[757] = 7'h40;
 buffer[758] = 7'h40;
 buffer[759] = 7'h40;
 buffer[760] = 7'h40;
 buffer[761] = 7'h40;
 buffer[762] = 7'h40;
 buffer[763] = 7'h40;
 buffer[764] = 7'h40;
 buffer[765] = 7'h40;
 buffer[766] = 7'h40;
 buffer[767] = 7'h40;
 buffer[768] = 7'h40;
 buffer[769] = 7'h40;
 buffer[770] = 7'h40;
 buffer[771] = 7'h40;
 buffer[772] = 7'h40;
 buffer[773] = 7'h40;
 buffer[774] = 7'h40;
 buffer[775] = 7'h40;
 buffer[776] = 7'h40;
 buffer[777] = 7'h40;
 buffer[778] = 7'h40;
 buffer[779] = 7'h40;
 buffer[780] = 7'h40;
 buffer[781] = 7'h40;
 buffer[782] = 7'h40;
 buffer[783] = 7'h40;
 buffer[784] = 7'h40;
 buffer[785] = 7'h40;
 buffer[786] = 7'h40;
 buffer[787] = 7'h40;
 buffer[788] = 7'h40;
 buffer[789] = 7'h40;
 buffer[790] = 7'h40;
 buffer[791] = 7'h40;
 buffer[792] = 7'h40;
 buffer[793] = 7'h40;
 buffer[794] = 7'h40;
 buffer[795] = 7'h40;
 buffer[796] = 7'h40;
 buffer[797] = 7'h40;
 buffer[798] = 7'h40;
 buffer[799] = 7'h40;
 buffer[800] = 7'h40;
 buffer[801] = 7'h40;
 buffer[802] = 7'h40;
 buffer[803] = 7'h40;
 buffer[804] = 7'h40;
 buffer[805] = 7'h40;
 buffer[806] = 7'h40;
 buffer[807] = 7'h40;
 buffer[808] = 7'h40;
 buffer[809] = 7'h40;
 buffer[810] = 7'h40;
 buffer[811] = 7'h40;
 buffer[812] = 7'h40;
 buffer[813] = 7'h40;
 buffer[814] = 7'h40;
 buffer[815] = 7'h40;
 buffer[816] = 7'h40;
 buffer[817] = 7'h40;
 buffer[818] = 7'h40;
 buffer[819] = 7'h40;
 buffer[820] = 7'h40;
 buffer[821] = 7'h40;
 buffer[822] = 7'h40;
 buffer[823] = 7'h40;
 buffer[824] = 7'h40;
 buffer[825] = 7'h40;
 buffer[826] = 7'h40;
 buffer[827] = 7'h40;
 buffer[828] = 7'h40;
 buffer[829] = 7'h40;
 buffer[830] = 7'h40;
 buffer[831] = 7'h40;
 buffer[832] = 7'h40;
 buffer[833] = 7'h40;
 buffer[834] = 7'h40;
 buffer[835] = 7'h40;
 buffer[836] = 7'h40;
 buffer[837] = 7'h40;
 buffer[838] = 7'h40;
 buffer[839] = 7'h40;
 buffer[840] = 7'h40;
 buffer[841] = 7'h40;
 buffer[842] = 7'h40;
 buffer[843] = 7'h40;
 buffer[844] = 7'h40;
 buffer[845] = 7'h40;
 buffer[846] = 7'h40;
 buffer[847] = 7'h40;
 buffer[848] = 7'h40;
 buffer[849] = 7'h40;
 buffer[850] = 7'h40;
 buffer[851] = 7'h40;
 buffer[852] = 7'h40;
 buffer[853] = 7'h40;
 buffer[854] = 7'h40;
 buffer[855] = 7'h40;
 buffer[856] = 7'h40;
 buffer[857] = 7'h40;
 buffer[858] = 7'h40;
 buffer[859] = 7'h40;
 buffer[860] = 7'h40;
 buffer[861] = 7'h40;
 buffer[862] = 7'h40;
 buffer[863] = 7'h40;
 buffer[864] = 7'h40;
 buffer[865] = 7'h40;
 buffer[866] = 7'h40;
 buffer[867] = 7'h40;
 buffer[868] = 7'h40;
 buffer[869] = 7'h40;
 buffer[870] = 7'h40;
 buffer[871] = 7'h40;
 buffer[872] = 7'h40;
 buffer[873] = 7'h40;
 buffer[874] = 7'h40;
 buffer[875] = 7'h40;
 buffer[876] = 7'h40;
 buffer[877] = 7'h40;
 buffer[878] = 7'h40;
 buffer[879] = 7'h40;
 buffer[880] = 7'h40;
 buffer[881] = 7'h40;
 buffer[882] = 7'h40;
 buffer[883] = 7'h40;
 buffer[884] = 7'h40;
 buffer[885] = 7'h40;
 buffer[886] = 7'h40;
 buffer[887] = 7'h40;
 buffer[888] = 7'h40;
 buffer[889] = 7'h40;
 buffer[890] = 7'h40;
 buffer[891] = 7'h40;
 buffer[892] = 7'h40;
 buffer[893] = 7'h40;
 buffer[894] = 7'h40;
 buffer[895] = 7'h40;
 buffer[896] = 7'h40;
 buffer[897] = 7'h40;
 buffer[898] = 7'h40;
 buffer[899] = 7'h40;
 buffer[900] = 7'h40;
 buffer[901] = 7'h40;
 buffer[902] = 7'h40;
 buffer[903] = 7'h40;
 buffer[904] = 7'h40;
 buffer[905] = 7'h40;
 buffer[906] = 7'h40;
 buffer[907] = 7'h40;
 buffer[908] = 7'h40;
 buffer[909] = 7'h40;
 buffer[910] = 7'h40;
 buffer[911] = 7'h40;
 buffer[912] = 7'h40;
 buffer[913] = 7'h40;
 buffer[914] = 7'h40;
 buffer[915] = 7'h40;
 buffer[916] = 7'h40;
 buffer[917] = 7'h40;
 buffer[918] = 7'h40;
 buffer[919] = 7'h40;
 buffer[920] = 7'h40;
 buffer[921] = 7'h40;
 buffer[922] = 7'h40;
 buffer[923] = 7'h40;
 buffer[924] = 7'h40;
 buffer[925] = 7'h40;
 buffer[926] = 7'h40;
 buffer[927] = 7'h40;
 buffer[928] = 7'h40;
 buffer[929] = 7'h40;
 buffer[930] = 7'h40;
 buffer[931] = 7'h40;
 buffer[932] = 7'h40;
 buffer[933] = 7'h40;
 buffer[934] = 7'h40;
 buffer[935] = 7'h40;
 buffer[936] = 7'h40;
 buffer[937] = 7'h40;
 buffer[938] = 7'h40;
 buffer[939] = 7'h40;
 buffer[940] = 7'h40;
 buffer[941] = 7'h40;
 buffer[942] = 7'h40;
 buffer[943] = 7'h40;
 buffer[944] = 7'h40;
 buffer[945] = 7'h40;
 buffer[946] = 7'h40;
 buffer[947] = 7'h40;
 buffer[948] = 7'h40;
 buffer[949] = 7'h40;
 buffer[950] = 7'h40;
 buffer[951] = 7'h40;
 buffer[952] = 7'h40;
 buffer[953] = 7'h40;
 buffer[954] = 7'h40;
 buffer[955] = 7'h40;
 buffer[956] = 7'h40;
 buffer[957] = 7'h40;
 buffer[958] = 7'h40;
 buffer[959] = 7'h40;
 buffer[960] = 7'h40;
 buffer[961] = 7'h40;
 buffer[962] = 7'h40;
 buffer[963] = 7'h40;
 buffer[964] = 7'h40;
 buffer[965] = 7'h40;
 buffer[966] = 7'h40;
 buffer[967] = 7'h40;
 buffer[968] = 7'h40;
 buffer[969] = 7'h40;
 buffer[970] = 7'h40;
 buffer[971] = 7'h40;
 buffer[972] = 7'h40;
 buffer[973] = 7'h40;
 buffer[974] = 7'h40;
 buffer[975] = 7'h40;
 buffer[976] = 7'h40;
 buffer[977] = 7'h40;
 buffer[978] = 7'h40;
 buffer[979] = 7'h40;
 buffer[980] = 7'h40;
 buffer[981] = 7'h40;
 buffer[982] = 7'h40;
 buffer[983] = 7'h40;
 buffer[984] = 7'h40;
 buffer[985] = 7'h40;
 buffer[986] = 7'h40;
 buffer[987] = 7'h40;
 buffer[988] = 7'h40;
 buffer[989] = 7'h40;
 buffer[990] = 7'h40;
 buffer[991] = 7'h40;
 buffer[992] = 7'h40;
 buffer[993] = 7'h40;
 buffer[994] = 7'h40;
 buffer[995] = 7'h40;
 buffer[996] = 7'h40;
 buffer[997] = 7'h40;
 buffer[998] = 7'h40;
 buffer[999] = 7'h40;
 buffer[1000] = 7'h40;
 buffer[1001] = 7'h40;
 buffer[1002] = 7'h40;
 buffer[1003] = 7'h40;
 buffer[1004] = 7'h40;
 buffer[1005] = 7'h40;
 buffer[1006] = 7'h40;
 buffer[1007] = 7'h40;
 buffer[1008] = 7'h40;
 buffer[1009] = 7'h40;
 buffer[1010] = 7'h40;
 buffer[1011] = 7'h40;
 buffer[1012] = 7'h40;
 buffer[1013] = 7'h40;
 buffer[1014] = 7'h40;
 buffer[1015] = 7'h40;
 buffer[1016] = 7'h40;
 buffer[1017] = 7'h40;
 buffer[1018] = 7'h40;
 buffer[1019] = 7'h40;
 buffer[1020] = 7'h40;
 buffer[1021] = 7'h40;
 buffer[1022] = 7'h40;
 buffer[1023] = 7'h40;
 buffer[1024] = 7'h40;
 buffer[1025] = 7'h40;
 buffer[1026] = 7'h40;
 buffer[1027] = 7'h40;
 buffer[1028] = 7'h40;
 buffer[1029] = 7'h40;
 buffer[1030] = 7'h40;
 buffer[1031] = 7'h40;
 buffer[1032] = 7'h40;
 buffer[1033] = 7'h40;
 buffer[1034] = 7'h40;
 buffer[1035] = 7'h40;
 buffer[1036] = 7'h40;
 buffer[1037] = 7'h40;
 buffer[1038] = 7'h40;
 buffer[1039] = 7'h40;
 buffer[1040] = 7'h40;
 buffer[1041] = 7'h40;
 buffer[1042] = 7'h40;
 buffer[1043] = 7'h40;
 buffer[1044] = 7'h40;
 buffer[1045] = 7'h40;
 buffer[1046] = 7'h40;
 buffer[1047] = 7'h40;
 buffer[1048] = 7'h40;
 buffer[1049] = 7'h40;
 buffer[1050] = 7'h40;
 buffer[1051] = 7'h40;
 buffer[1052] = 7'h40;
 buffer[1053] = 7'h40;
 buffer[1054] = 7'h40;
 buffer[1055] = 7'h40;
 buffer[1056] = 7'h40;
 buffer[1057] = 7'h40;
 buffer[1058] = 7'h40;
 buffer[1059] = 7'h40;
 buffer[1060] = 7'h40;
 buffer[1061] = 7'h40;
 buffer[1062] = 7'h40;
 buffer[1063] = 7'h40;
 buffer[1064] = 7'h40;
 buffer[1065] = 7'h40;
 buffer[1066] = 7'h40;
 buffer[1067] = 7'h40;
 buffer[1068] = 7'h40;
 buffer[1069] = 7'h40;
 buffer[1070] = 7'h40;
 buffer[1071] = 7'h40;
 buffer[1072] = 7'h40;
 buffer[1073] = 7'h40;
 buffer[1074] = 7'h40;
 buffer[1075] = 7'h40;
 buffer[1076] = 7'h40;
 buffer[1077] = 7'h40;
 buffer[1078] = 7'h40;
 buffer[1079] = 7'h40;
 buffer[1080] = 7'h40;
 buffer[1081] = 7'h40;
 buffer[1082] = 7'h40;
 buffer[1083] = 7'h40;
 buffer[1084] = 7'h40;
 buffer[1085] = 7'h40;
 buffer[1086] = 7'h40;
 buffer[1087] = 7'h40;
 buffer[1088] = 7'h40;
 buffer[1089] = 7'h40;
 buffer[1090] = 7'h40;
 buffer[1091] = 7'h40;
 buffer[1092] = 7'h40;
 buffer[1093] = 7'h40;
 buffer[1094] = 7'h40;
 buffer[1095] = 7'h40;
 buffer[1096] = 7'h40;
 buffer[1097] = 7'h40;
 buffer[1098] = 7'h40;
 buffer[1099] = 7'h40;
 buffer[1100] = 7'h40;
 buffer[1101] = 7'h40;
 buffer[1102] = 7'h40;
 buffer[1103] = 7'h40;
 buffer[1104] = 7'h40;
 buffer[1105] = 7'h40;
 buffer[1106] = 7'h40;
 buffer[1107] = 7'h40;
 buffer[1108] = 7'h40;
 buffer[1109] = 7'h40;
 buffer[1110] = 7'h40;
 buffer[1111] = 7'h40;
 buffer[1112] = 7'h40;
 buffer[1113] = 7'h40;
 buffer[1114] = 7'h40;
 buffer[1115] = 7'h40;
 buffer[1116] = 7'h40;
 buffer[1117] = 7'h40;
 buffer[1118] = 7'h40;
 buffer[1119] = 7'h40;
 buffer[1120] = 7'h40;
 buffer[1121] = 7'h40;
 buffer[1122] = 7'h40;
 buffer[1123] = 7'h40;
 buffer[1124] = 7'h40;
 buffer[1125] = 7'h40;
 buffer[1126] = 7'h40;
 buffer[1127] = 7'h40;
 buffer[1128] = 7'h40;
 buffer[1129] = 7'h40;
 buffer[1130] = 7'h40;
 buffer[1131] = 7'h40;
 buffer[1132] = 7'h40;
 buffer[1133] = 7'h40;
 buffer[1134] = 7'h40;
 buffer[1135] = 7'h40;
 buffer[1136] = 7'h40;
 buffer[1137] = 7'h40;
 buffer[1138] = 7'h40;
 buffer[1139] = 7'h40;
 buffer[1140] = 7'h40;
 buffer[1141] = 7'h40;
 buffer[1142] = 7'h40;
 buffer[1143] = 7'h40;
 buffer[1144] = 7'h40;
 buffer[1145] = 7'h40;
 buffer[1146] = 7'h40;
 buffer[1147] = 7'h40;
 buffer[1148] = 7'h40;
 buffer[1149] = 7'h40;
 buffer[1150] = 7'h40;
 buffer[1151] = 7'h40;
 buffer[1152] = 7'h40;
 buffer[1153] = 7'h40;
 buffer[1154] = 7'h40;
 buffer[1155] = 7'h40;
 buffer[1156] = 7'h40;
 buffer[1157] = 7'h40;
 buffer[1158] = 7'h40;
 buffer[1159] = 7'h40;
 buffer[1160] = 7'h40;
 buffer[1161] = 7'h40;
 buffer[1162] = 7'h40;
 buffer[1163] = 7'h40;
 buffer[1164] = 7'h40;
 buffer[1165] = 7'h40;
 buffer[1166] = 7'h40;
 buffer[1167] = 7'h40;
 buffer[1168] = 7'h40;
 buffer[1169] = 7'h40;
 buffer[1170] = 7'h40;
 buffer[1171] = 7'h40;
 buffer[1172] = 7'h40;
 buffer[1173] = 7'h40;
 buffer[1174] = 7'h40;
 buffer[1175] = 7'h40;
 buffer[1176] = 7'h40;
 buffer[1177] = 7'h40;
 buffer[1178] = 7'h40;
 buffer[1179] = 7'h40;
 buffer[1180] = 7'h40;
 buffer[1181] = 7'h40;
 buffer[1182] = 7'h40;
 buffer[1183] = 7'h40;
 buffer[1184] = 7'h40;
 buffer[1185] = 7'h40;
 buffer[1186] = 7'h40;
 buffer[1187] = 7'h40;
 buffer[1188] = 7'h40;
 buffer[1189] = 7'h40;
 buffer[1190] = 7'h40;
 buffer[1191] = 7'h40;
 buffer[1192] = 7'h40;
 buffer[1193] = 7'h40;
 buffer[1194] = 7'h40;
 buffer[1195] = 7'h40;
 buffer[1196] = 7'h40;
 buffer[1197] = 7'h40;
 buffer[1198] = 7'h40;
 buffer[1199] = 7'h40;
 buffer[1200] = 7'h40;
 buffer[1201] = 7'h40;
 buffer[1202] = 7'h40;
 buffer[1203] = 7'h40;
 buffer[1204] = 7'h40;
 buffer[1205] = 7'h40;
 buffer[1206] = 7'h40;
 buffer[1207] = 7'h40;
 buffer[1208] = 7'h40;
 buffer[1209] = 7'h40;
 buffer[1210] = 7'h40;
 buffer[1211] = 7'h40;
 buffer[1212] = 7'h40;
 buffer[1213] = 7'h40;
 buffer[1214] = 7'h40;
 buffer[1215] = 7'h40;
 buffer[1216] = 7'h40;
 buffer[1217] = 7'h40;
 buffer[1218] = 7'h40;
 buffer[1219] = 7'h40;
 buffer[1220] = 7'h40;
 buffer[1221] = 7'h40;
 buffer[1222] = 7'h40;
 buffer[1223] = 7'h40;
 buffer[1224] = 7'h40;
 buffer[1225] = 7'h40;
 buffer[1226] = 7'h40;
 buffer[1227] = 7'h40;
 buffer[1228] = 7'h40;
 buffer[1229] = 7'h40;
 buffer[1230] = 7'h40;
 buffer[1231] = 7'h40;
 buffer[1232] = 7'h40;
 buffer[1233] = 7'h40;
 buffer[1234] = 7'h40;
 buffer[1235] = 7'h40;
 buffer[1236] = 7'h40;
 buffer[1237] = 7'h40;
 buffer[1238] = 7'h40;
 buffer[1239] = 7'h40;
 buffer[1240] = 7'h40;
 buffer[1241] = 7'h40;
 buffer[1242] = 7'h40;
 buffer[1243] = 7'h40;
 buffer[1244] = 7'h40;
 buffer[1245] = 7'h40;
 buffer[1246] = 7'h40;
 buffer[1247] = 7'h40;
 buffer[1248] = 7'h40;
 buffer[1249] = 7'h40;
 buffer[1250] = 7'h40;
 buffer[1251] = 7'h40;
 buffer[1252] = 7'h40;
 buffer[1253] = 7'h40;
 buffer[1254] = 7'h40;
 buffer[1255] = 7'h40;
 buffer[1256] = 7'h40;
 buffer[1257] = 7'h40;
 buffer[1258] = 7'h40;
 buffer[1259] = 7'h40;
 buffer[1260] = 7'h40;
 buffer[1261] = 7'h40;
 buffer[1262] = 7'h40;
 buffer[1263] = 7'h40;
 buffer[1264] = 7'h40;
 buffer[1265] = 7'h40;
 buffer[1266] = 7'h40;
 buffer[1267] = 7'h40;
 buffer[1268] = 7'h40;
 buffer[1269] = 7'h40;
 buffer[1270] = 7'h40;
 buffer[1271] = 7'h40;
 buffer[1272] = 7'h40;
 buffer[1273] = 7'h40;
 buffer[1274] = 7'h40;
 buffer[1275] = 7'h40;
 buffer[1276] = 7'h40;
 buffer[1277] = 7'h40;
 buffer[1278] = 7'h40;
 buffer[1279] = 7'h40;
 buffer[1280] = 7'h40;
 buffer[1281] = 7'h40;
 buffer[1282] = 7'h40;
 buffer[1283] = 7'h40;
 buffer[1284] = 7'h40;
 buffer[1285] = 7'h40;
 buffer[1286] = 7'h40;
 buffer[1287] = 7'h40;
 buffer[1288] = 7'h40;
 buffer[1289] = 7'h40;
 buffer[1290] = 7'h40;
 buffer[1291] = 7'h40;
 buffer[1292] = 7'h40;
 buffer[1293] = 7'h40;
 buffer[1294] = 7'h40;
 buffer[1295] = 7'h40;
 buffer[1296] = 7'h40;
 buffer[1297] = 7'h40;
 buffer[1298] = 7'h40;
 buffer[1299] = 7'h40;
 buffer[1300] = 7'h40;
 buffer[1301] = 7'h40;
 buffer[1302] = 7'h40;
 buffer[1303] = 7'h40;
 buffer[1304] = 7'h40;
 buffer[1305] = 7'h40;
 buffer[1306] = 7'h40;
 buffer[1307] = 7'h40;
 buffer[1308] = 7'h40;
 buffer[1309] = 7'h40;
 buffer[1310] = 7'h40;
 buffer[1311] = 7'h40;
 buffer[1312] = 7'h40;
 buffer[1313] = 7'h40;
 buffer[1314] = 7'h40;
 buffer[1315] = 7'h40;
 buffer[1316] = 7'h40;
 buffer[1317] = 7'h40;
 buffer[1318] = 7'h40;
 buffer[1319] = 7'h40;
 buffer[1320] = 7'h40;
 buffer[1321] = 7'h40;
 buffer[1322] = 7'h40;
 buffer[1323] = 7'h40;
 buffer[1324] = 7'h40;
 buffer[1325] = 7'h40;
 buffer[1326] = 7'h40;
 buffer[1327] = 7'h40;
 buffer[1328] = 7'h40;
 buffer[1329] = 7'h40;
 buffer[1330] = 7'h40;
 buffer[1331] = 7'h40;
 buffer[1332] = 7'h40;
 buffer[1333] = 7'h40;
 buffer[1334] = 7'h40;
 buffer[1335] = 7'h40;
 buffer[1336] = 7'h40;
 buffer[1337] = 7'h40;
 buffer[1338] = 7'h40;
 buffer[1339] = 7'h40;
 buffer[1340] = 7'h40;
 buffer[1341] = 7'h40;
 buffer[1342] = 7'h40;
 buffer[1343] = 7'h40;
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
in_tile_writer_write,
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
input  [0:0] in_tile_writer_write;
input  [4:0] in_tm_scrollwrap;
output  [1:0] out_pix_red;
output  [1:0] out_pix_green;
output  [1:0] out_pix_blue;
output  [0:0] out_tilemap_display;
output  [4:0] out_tm_lastaction;
output  [5:0] out_tm_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [15:0] _w_mem_tiles16x16_rdata0;
wire  [15:0] _w_mem_tiles16x16_rdata1;
wire  [4:0] _w_mem_tile_rdata0;
wire  [4:0] _w_mem_tile_rdata1;
wire  [5:0] _w_mem_foreground_rdata0;
wire  [5:0] _w_mem_foreground_rdata1;
wire  [6:0] _w_mem_background_rdata0;
wire  [6:0] _w_mem_background_rdata1;
wire  [15:0] _c_tiles16x16_wdata0;
assign _c_tiles16x16_wdata0 = 0;
wire  [4:0] _c_tile_wdata0;
assign _c_tile_wdata0 = 0;
wire  [5:0] _c_foreground_wdata0;
assign _c_foreground_wdata0 = 0;
wire  [6:0] _c_background_wdata0;
assign _c_background_wdata0 = 0;
wire  [10:0] _w_xtmpos;
wire  [10:0] _w_ytmpos;
wire  [3:0] _w_xintm;
wire  [3:0] _w_yintm;
wire  [0:0] _w_tmpixel;

reg  [0:0] _d_tiles16x16_wenable0;
reg  [0:0] _q_tiles16x16_wenable0;
reg  [8:0] _d_tiles16x16_addr0;
reg  [8:0] _q_tiles16x16_addr0;
reg  [0:0] _d_tiles16x16_wenable1;
reg  [0:0] _q_tiles16x16_wenable1;
reg  [15:0] _d_tiles16x16_wdata1;
reg  [15:0] _q_tiles16x16_wdata1;
reg  [8:0] _d_tiles16x16_addr1;
reg  [8:0] _q_tiles16x16_addr1;
reg  [0:0] _d_tile_wenable0;
reg  [0:0] _q_tile_wenable0;
reg  [10:0] _d_tile_addr0;
reg  [10:0] _q_tile_addr0;
reg  [0:0] _d_tile_wenable1;
reg  [0:0] _q_tile_wenable1;
reg  [4:0] _d_tile_wdata1;
reg  [4:0] _q_tile_wdata1;
reg  [10:0] _d_tile_addr1;
reg  [10:0] _q_tile_addr1;
reg  [0:0] _d_foreground_wenable0;
reg  [0:0] _q_foreground_wenable0;
reg  [10:0] _d_foreground_addr0;
reg  [10:0] _q_foreground_addr0;
reg  [0:0] _d_foreground_wenable1;
reg  [0:0] _q_foreground_wenable1;
reg  [5:0] _d_foreground_wdata1;
reg  [5:0] _q_foreground_wdata1;
reg  [10:0] _d_foreground_addr1;
reg  [10:0] _q_foreground_addr1;
reg  [0:0] _d_background_wenable0;
reg  [0:0] _q_background_wenable0;
reg  [10:0] _d_background_addr0;
reg  [10:0] _q_background_addr0;
reg  [0:0] _d_background_wenable1;
reg  [0:0] _q_background_wenable1;
reg  [6:0] _d_background_wdata1;
reg  [6:0] _q_background_wdata1;
reg  [10:0] _d_background_addr1;
reg  [10:0] _q_background_addr1;
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
reg  [5:0] _d_new_tile;
reg  [5:0] _q_new_tile;
reg  [6:0] _d_new_background;
reg  [6:0] _q_new_background;
reg  [5:0] _d_new_foreground;
reg  [5:0] _q_new_foreground;
reg  [5:0] _d_scroll_tile;
reg  [5:0] _q_scroll_tile;
reg  [6:0] _d_scroll_background;
reg  [6:0] _q_scroll_background;
reg  [5:0] _d_scroll_foreground;
reg  [5:0] _q_scroll_foreground;
reg  [1:0] _d_pix_red,_q_pix_red;
reg  [1:0] _d_pix_green,_q_pix_green;
reg  [1:0] _d_pix_blue,_q_pix_blue;
reg  [0:0] _d_tilemap_display,_q_tilemap_display;
reg  [4:0] _d_tm_lastaction,_q_tm_lastaction;
reg  [5:0] _d_tm_active,_q_tm_active;
reg  [1:0] _d_index,_q_index;
assign out_pix_red = _d_pix_red;
assign out_pix_green = _d_pix_green;
assign out_pix_blue = _d_pix_blue;
assign out_tilemap_display = _d_tilemap_display;
assign out_tm_lastaction = _q_tm_lastaction;
assign out_tm_active = _q_tm_active;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_tiles16x16_wenable0 <= 0;
_q_tiles16x16_addr0 <= 0;
_q_tiles16x16_wenable1 <= 0;
_q_tiles16x16_wdata1 <= 0;
_q_tiles16x16_addr1 <= 0;
_q_tile_wenable0 <= 0;
_q_tile_addr0 <= 0;
_q_tile_wenable1 <= 0;
_q_tile_wdata1 <= 0;
_q_tile_addr1 <= 0;
_q_foreground_wenable0 <= 0;
_q_foreground_addr0 <= 0;
_q_foreground_wenable1 <= 0;
_q_foreground_wdata1 <= 0;
_q_foreground_addr1 <= 0;
_q_background_wenable0 <= 0;
_q_background_addr0 <= 0;
_q_background_wenable1 <= 0;
_q_background_wdata1 <= 0;
_q_background_addr1 <= 0;
_q_tm_offset_x <= 0;
_q_tm_offset_y <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_tiles16x16_wenable0 <= _d_tiles16x16_wenable0;
_q_tiles16x16_addr0 <= _d_tiles16x16_addr0;
_q_tiles16x16_wenable1 <= _d_tiles16x16_wenable1;
_q_tiles16x16_wdata1 <= _d_tiles16x16_wdata1;
_q_tiles16x16_addr1 <= _d_tiles16x16_addr1;
_q_tile_wenable0 <= _d_tile_wenable0;
_q_tile_addr0 <= _d_tile_addr0;
_q_tile_wenable1 <= _d_tile_wenable1;
_q_tile_wdata1 <= _d_tile_wdata1;
_q_tile_addr1 <= _d_tile_addr1;
_q_foreground_wenable0 <= _d_foreground_wenable0;
_q_foreground_addr0 <= _d_foreground_addr0;
_q_foreground_wenable1 <= _d_foreground_wenable1;
_q_foreground_wdata1 <= _d_foreground_wdata1;
_q_foreground_addr1 <= _d_foreground_addr1;
_q_background_wenable0 <= _d_background_wenable0;
_q_background_addr0 <= _d_background_addr0;
_q_background_wenable1 <= _d_background_wenable1;
_q_background_wdata1 <= _d_background_wdata1;
_q_background_addr1 <= _d_background_addr1;
_q_tm_offset_x <= _d_tm_offset_x;
_q_tm_offset_y <= _d_tm_offset_y;
_q_tm_scroll <= _d_tm_scroll;
_q_x_cursor <= _d_x_cursor;
_q_y_cursor <= _d_y_cursor;
_q_new_tile <= _d_new_tile;
_q_new_background <= _d_new_background;
_q_new_foreground <= _d_new_foreground;
_q_scroll_tile <= _d_scroll_tile;
_q_scroll_background <= _d_scroll_background;
_q_scroll_foreground <= _d_scroll_foreground;
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
.in_tiles16x16_wenable0(_d_tiles16x16_wenable0),
.in_tiles16x16_wdata0(_c_tiles16x16_wdata0),
.in_tiles16x16_addr0(_d_tiles16x16_addr0),
.in_tiles16x16_wenable1(_d_tiles16x16_wenable1),
.in_tiles16x16_wdata1(_d_tiles16x16_wdata1),
.in_tiles16x16_addr1(_d_tiles16x16_addr1),
.out_tiles16x16_rdata0(_w_mem_tiles16x16_rdata0),
.out_tiles16x16_rdata1(_w_mem_tiles16x16_rdata1)
);
M_tilemap_mem_tile __mem__tile(
.clock0(clock),
.clock1(clock),
.in_tile_wenable0(_d_tile_wenable0),
.in_tile_wdata0(_c_tile_wdata0),
.in_tile_addr0(_d_tile_addr0),
.in_tile_wenable1(_d_tile_wenable1),
.in_tile_wdata1(_d_tile_wdata1),
.in_tile_addr1(_d_tile_addr1),
.out_tile_rdata0(_w_mem_tile_rdata0),
.out_tile_rdata1(_w_mem_tile_rdata1)
);
M_tilemap_mem_foreground __mem__foreground(
.clock0(clock),
.clock1(clock),
.in_foreground_wenable0(_d_foreground_wenable0),
.in_foreground_wdata0(_c_foreground_wdata0),
.in_foreground_addr0(_d_foreground_addr0),
.in_foreground_wenable1(_d_foreground_wenable1),
.in_foreground_wdata1(_d_foreground_wdata1),
.in_foreground_addr1(_d_foreground_addr1),
.out_foreground_rdata0(_w_mem_foreground_rdata0),
.out_foreground_rdata1(_w_mem_foreground_rdata1)
);
M_tilemap_mem_background __mem__background(
.clock0(clock),
.clock1(clock),
.in_background_wenable0(_d_background_wenable0),
.in_background_wdata0(_c_background_wdata0),
.in_background_addr0(_d_background_addr0),
.in_background_wenable1(_d_background_wenable1),
.in_background_wdata1(_d_background_wdata1),
.in_background_addr1(_d_background_addr1),
.out_background_rdata0(_w_mem_background_rdata0),
.out_background_rdata1(_w_mem_background_rdata1)
);

assign _w_tmpixel = _w_mem_tiles16x16_rdata0[15-_w_xintm+:1];
assign _w_yintm = {1'b0,(in_pix_y)&15}+_d_tm_offset_y;
assign _w_xintm = {1'b0,(in_pix_x)&15}+_d_tm_offset_x;
assign _w_ytmpos = ((in_pix_vblank?0:in_pix_y+(11'd16+{{6{_d_tm_offset_y[4+:1]}},_d_tm_offset_y}))>>4)*42;
assign _w_xtmpos = (in_pix_active?(in_pix_x<640)?in_pix_x+(11'd18+{{6{_d_tm_offset_x[4+:1]}},_d_tm_offset_x}):(11'd16+{{6{_d_tm_offset_x[4+:1]}},_d_tm_offset_x}):(11'd16+{{6{_d_tm_offset_x[4+:1]}},_d_tm_offset_x}))>>4;

always @* begin
_d_tiles16x16_wenable0 = _q_tiles16x16_wenable0;
_d_tiles16x16_addr0 = _q_tiles16x16_addr0;
_d_tiles16x16_wenable1 = _q_tiles16x16_wenable1;
_d_tiles16x16_wdata1 = _q_tiles16x16_wdata1;
_d_tiles16x16_addr1 = _q_tiles16x16_addr1;
_d_tile_wenable0 = _q_tile_wenable0;
_d_tile_addr0 = _q_tile_addr0;
_d_tile_wenable1 = _q_tile_wenable1;
_d_tile_wdata1 = _q_tile_wdata1;
_d_tile_addr1 = _q_tile_addr1;
_d_foreground_wenable0 = _q_foreground_wenable0;
_d_foreground_addr0 = _q_foreground_addr0;
_d_foreground_wenable1 = _q_foreground_wenable1;
_d_foreground_wdata1 = _q_foreground_wdata1;
_d_foreground_addr1 = _q_foreground_addr1;
_d_background_wenable0 = _q_background_wenable0;
_d_background_addr0 = _q_background_addr0;
_d_background_wenable1 = _q_background_wenable1;
_d_background_wdata1 = _q_background_wdata1;
_d_background_addr1 = _q_background_addr1;
_d_tm_offset_x = _q_tm_offset_x;
_d_tm_offset_y = _q_tm_offset_y;
_d_tm_scroll = _q_tm_scroll;
_d_x_cursor = _q_x_cursor;
_d_y_cursor = _q_y_cursor;
_d_new_tile = _q_new_tile;
_d_new_background = _q_new_background;
_d_new_foreground = _q_new_foreground;
_d_scroll_tile = _q_scroll_tile;
_d_scroll_background = _q_scroll_background;
_d_scroll_foreground = _q_scroll_foreground;
_d_pix_red = _q_pix_red;
_d_pix_green = _q_pix_green;
_d_pix_blue = _q_pix_blue;
_d_tilemap_display = _q_tilemap_display;
_d_tm_lastaction = _q_tm_lastaction;
_d_tm_active = _q_tm_active;
_d_index = _q_index;
// _always_pre
_d_tile_addr0 = _w_xtmpos+_w_ytmpos;
_d_tile_wenable0 = 0;
_d_tile_wenable1 = 0;
_d_foreground_addr0 = _w_xtmpos+_w_ytmpos;
_d_foreground_wenable0 = 0;
_d_foreground_wenable1 = 0;
_d_background_addr0 = _w_xtmpos+_w_ytmpos;
_d_background_wenable0 = 0;
_d_background_wenable1 = 0;
_d_tiles16x16_addr0 = _w_mem_tile_rdata0*16+_w_yintm;
_d_tiles16x16_wenable0 = 0;
_d_tiles16x16_wenable1 = 1;
_d_tilemap_display = in_pix_active&&((_w_tmpixel)||(~_w_mem_background_rdata0[6+:1]));
if (in_tile_writer_write) begin
// __block_1
// __block_3
_d_tiles16x16_addr1 = in_tile_writer_tile*16+in_tile_writer_line;
_d_tiles16x16_wdata1 = in_tile_writer_bitmap;
// __block_4
end else begin
// __block_2
end
// __block_5
  case (in_tm_write)
  1: begin
// __block_7_case
// __block_8
_d_tile_addr1 = in_tm_x+in_tm_y*42;
_d_tile_wdata1 = in_tm_character;
_d_tile_wenable1 = 1;
_d_background_addr1 = in_tm_x+in_tm_y*42;
_d_background_wdata1 = in_tm_background;
_d_background_wenable1 = 1;
_d_foreground_addr1 = in_tm_x+in_tm_y*42;
_d_foreground_wdata1 = in_tm_foreground;
_d_foreground_wenable1 = 1;
// __block_9
  end
endcase
// __block_6
  case (in_tm_scrollwrap)
  1: begin
// __block_11_case
// __block_12
_d_tm_offset_x = (_q_tm_offset_x==(15))?0:_q_tm_offset_x+1;
_d_tm_active = (_d_tm_offset_x==(15))?1:0;
_d_tm_scroll = 1;
_d_tm_lastaction = (_d_tm_offset_x==(15))?in_tm_scrollwrap:0;
// __block_13
  end
  2: begin
// __block_14_case
// __block_15
_d_tm_offset_y = (_q_tm_offset_y==(15))?0:_q_tm_offset_y+1;
_d_tm_active = (_d_tm_offset_y==(15))?15:0;
_d_tm_scroll = 1;
_d_tm_lastaction = (_d_tm_offset_y==(15))?in_tm_scrollwrap:0;
// __block_16
  end
  3: begin
// __block_17_case
// __block_18
_d_tm_offset_x = (_q_tm_offset_x==(-15))?0:_q_tm_offset_x-1;
_d_tm_active = (_d_tm_offset_x==(-15))?8:0;
_d_tm_scroll = 1;
_d_tm_lastaction = (_d_tm_offset_x==(-15))?in_tm_scrollwrap:0;
// __block_19
  end
  4: begin
// __block_20_case
// __block_21
_d_tm_offset_y = (_q_tm_offset_y==(-15))?0:_q_tm_offset_y-1;
_d_tm_active = (_d_tm_offset_y==(-15))?22:0;
_d_tm_scroll = 1;
_d_tm_lastaction = (_d_tm_offset_y==(-15))?in_tm_scrollwrap:0;
// __block_22
  end
  5: begin
// __block_23_case
// __block_24
_d_tm_offset_x = (_q_tm_offset_x==(15))?0:_q_tm_offset_x+1;
_d_tm_active = (_d_tm_offset_x==(15))?1:0;
_d_tm_scroll = 0;
_d_tm_lastaction = (_d_tm_offset_x==(15))?in_tm_scrollwrap:0;
// __block_25
  end
  6: begin
// __block_26_case
// __block_27
_d_tm_offset_y = (_q_tm_offset_y==(15))?0:_q_tm_offset_y+1;
_d_tm_active = (_d_tm_offset_y==(15))?15:0;
_d_tm_scroll = 0;
_d_tm_lastaction = (_d_tm_offset_y==(15))?in_tm_scrollwrap:0;
// __block_28
  end
  7: begin
// __block_29_case
// __block_30
_d_tm_offset_x = (_q_tm_offset_x==(-15))?0:_q_tm_offset_x-1;
_d_tm_active = (_d_tm_offset_x==(-15))?8:0;
_d_tm_scroll = 0;
_d_tm_lastaction = (_d_tm_offset_x==(-15))?in_tm_scrollwrap:0;
// __block_31
  end
  8: begin
// __block_32_case
// __block_33
_d_tm_offset_y = (_q_tm_offset_y==(-15))?0:_q_tm_offset_y-1;
_d_tm_active = (_d_tm_offset_y==(-15))?22:0;
_d_tm_scroll = 0;
_d_tm_lastaction = (_d_tm_offset_y==(-15))?in_tm_scrollwrap:0;
// __block_34
  end
  9: begin
// __block_35_case
// __block_36
_d_tm_active = 29;
// __block_37
  end
endcase
// __block_10
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
_d_tiles16x16_wenable0 = 0;
_d_tiles16x16_addr0 = 0;
_d_tiles16x16_wenable1 = 0;
_d_tiles16x16_wdata1 = 0;
_d_tiles16x16_addr1 = 0;
_d_tile_wenable0 = 0;
_d_tile_addr0 = 0;
_d_tile_wenable1 = 0;
_d_tile_wdata1 = 0;
_d_tile_addr1 = 0;
_d_foreground_wenable0 = 0;
_d_foreground_addr0 = 0;
_d_foreground_wenable1 = 0;
_d_foreground_wdata1 = 0;
_d_foreground_addr1 = 0;
_d_background_wenable0 = 0;
_d_background_addr0 = 0;
_d_background_wenable1 = 0;
_d_background_wdata1 = 0;
_d_background_addr1 = 0;
_d_tm_offset_x = 0;
_d_tm_offset_y = 0;
// --
_d_tile_addr1 = 0;
_d_tile_wdata1 = 0;
_d_background_addr1 = 0;
_d_background_wdata1 = 64;
_d_foreground_addr1 = 0;
_d_foreground_wdata1 = 0;
_d_index = 1;
end
1: begin
// __while__block_38
if (1) begin
// __block_39
// __block_41
  case (_d_tm_active)
  1: begin
// __block_43_case
// __block_44
_d_x_cursor = 0;
_d_y_cursor = 0;
_d_tm_active = 2;
// __block_45
  end
  2: begin
// __block_46_case
// __block_47
_d_tile_addr1 = 0+(_q_y_cursor*42);
_d_foreground_addr1 = 0+(_q_y_cursor*42);
_d_background_addr1 = 0+(_q_y_cursor*42);
_d_tm_active = 3;
// __block_48
  end
  3: begin
// __block_49_case
// __block_50
_d_new_tile = (_d_tm_scroll==1)?0:_w_mem_tile_rdata1;
_d_new_foreground = (_d_tm_scroll==1)?0:_w_mem_foreground_rdata1;
_d_new_background = (_d_tm_scroll==1)?7'h40:_w_mem_background_rdata1;
_d_tm_active = 4;
// __block_51
  end
  4: begin
// __block_52_case
// __block_53
_d_tile_addr1 = (_q_x_cursor+1)+(_q_y_cursor*42);
_d_foreground_addr1 = (_q_x_cursor+1)+(_q_y_cursor*42);
_d_background_addr1 = (_q_x_cursor+1)+(_q_y_cursor*42);
_d_tm_active = 5;
// __block_54
  end
  5: begin
// __block_55_case
// __block_56
_d_scroll_tile = _w_mem_tile_rdata1;
_d_scroll_foreground = _w_mem_foreground_rdata1;
_d_scroll_background = _w_mem_background_rdata1;
_d_tm_active = 6;
// __block_57
  end
  6: begin
// __block_58_case
// __block_59
_d_tile_addr1 = (_q_x_cursor)+(_q_y_cursor*42);
_d_tile_wdata1 = _q_scroll_tile;
_d_tile_wenable1 = 1;
_d_foreground_addr1 = (_q_x_cursor)+(_q_y_cursor*42);
_d_foreground_wdata1 = _q_scroll_foreground;
_d_foreground_wenable1 = 1;
_d_background_addr1 = (_q_x_cursor)+(_q_y_cursor*42);
_d_background_wdata1 = _q_scroll_background;
_d_background_wenable1 = 1;
_d_tm_active = 7;
// __block_60
  end
  7: begin
// __block_61_case
// __block_62
if (_q_x_cursor==40) begin
// __block_63
// __block_65
_d_tile_addr1 = (41)+(_q_y_cursor*42);
_d_tile_wdata1 = _q_new_tile;
_d_tile_wenable1 = 1;
_d_foreground_addr1 = (41)+(_q_y_cursor*42);
_d_foreground_wdata1 = _q_new_foreground;
_d_foreground_wenable1 = 1;
_d_background_addr1 = (41)+(_q_y_cursor*42);
_d_background_wdata1 = _q_new_background;
_d_background_wenable1 = 1;
if (_q_y_cursor==31) begin
// __block_66
// __block_68
_d_tm_active = 0;
// __block_69
end else begin
// __block_67
// __block_70
_d_x_cursor = 0;
_d_y_cursor = _q_y_cursor+1;
_d_tm_active = 2;
// __block_71
end
// __block_72
// __block_73
end else begin
// __block_64
// __block_74
_d_x_cursor = _q_x_cursor+1;
_d_tm_active = 4;
// __block_75
end
// __block_76
// __block_77
  end
  8: begin
// __block_78_case
// __block_79
_d_x_cursor = 41;
_d_y_cursor = 0;
_d_tm_active = 9;
// __block_80
  end
  9: begin
// __block_81_case
// __block_82
_d_tile_addr1 = 41+(_q_y_cursor*42);
_d_foreground_addr1 = 41+(_q_y_cursor*42);
_d_background_addr1 = 41+(_q_y_cursor*42);
_d_tm_active = 10;
// __block_83
  end
  10: begin
// __block_84_case
// __block_85
_d_new_tile = (_d_tm_scroll==1)?0:_w_mem_tile_rdata1;
_d_new_foreground = (_d_tm_scroll==1)?0:_w_mem_foreground_rdata1;
_d_new_background = (_d_tm_scroll==1)?7'h40:_w_mem_background_rdata1;
_d_tm_active = 11;
// __block_86
  end
  11: begin
// __block_87_case
// __block_88
_d_tile_addr1 = (_q_x_cursor-1)+(_q_y_cursor*42);
_d_foreground_addr1 = (_q_x_cursor-1)+(_q_y_cursor*42);
_d_background_addr1 = (_q_x_cursor-1)+(_q_y_cursor*42);
_d_tm_active = 12;
// __block_89
  end
  12: begin
// __block_90_case
// __block_91
_d_scroll_tile = _w_mem_tile_rdata1;
_d_scroll_foreground = _w_mem_foreground_rdata1;
_d_scroll_background = _w_mem_background_rdata1;
_d_tm_active = 13;
// __block_92
  end
  13: begin
// __block_93_case
// __block_94
_d_tile_addr1 = (_q_x_cursor)+(_q_y_cursor*42);
_d_tile_wdata1 = _q_scroll_tile;
_d_tile_wenable1 = 1;
_d_foreground_addr1 = (_q_x_cursor)+(_q_y_cursor*42);
_d_foreground_wdata1 = _q_scroll_foreground;
_d_foreground_wenable1 = 1;
_d_background_addr1 = (_q_x_cursor)+(_q_y_cursor*42);
_d_background_wdata1 = _q_scroll_background;
_d_background_wenable1 = 1;
_d_tm_active = 14;
// __block_95
  end
  14: begin
// __block_96_case
// __block_97
if (_q_x_cursor==1) begin
// __block_98
// __block_100
_d_tile_addr1 = (0)+(_q_y_cursor*42);
_d_tile_wdata1 = _q_new_tile;
_d_tile_wenable1 = 1;
_d_foreground_addr1 = (0)+(_q_y_cursor*42);
_d_foreground_wdata1 = _q_new_foreground;
_d_foreground_wenable1 = 1;
_d_background_addr1 = (0)+(_q_y_cursor*42);
_d_background_wdata1 = _q_new_background;
_d_background_wenable1 = 1;
if (_q_y_cursor==31) begin
// __block_101
// __block_103
_d_tm_active = 0;
// __block_104
end else begin
// __block_102
// __block_105
_d_x_cursor = 41;
_d_y_cursor = _q_y_cursor+1;
_d_tm_active = 9;
// __block_106
end
// __block_107
// __block_108
end else begin
// __block_99
// __block_109
_d_x_cursor = _q_x_cursor-1;
_d_tm_active = 11;
// __block_110
end
// __block_111
// __block_112
  end
  15: begin
// __block_113_case
// __block_114
_d_x_cursor = 0;
_d_y_cursor = 0;
_d_tm_active = 16;
// __block_115
  end
  16: begin
// __block_116_case
// __block_117
_d_tile_addr1 = _q_x_cursor+(0*42);
_d_foreground_addr1 = _q_x_cursor+(0*42);
_d_background_addr1 = _q_x_cursor+(0*42);
_d_tm_active = 17;
// __block_118
  end
  17: begin
// __block_119_case
// __block_120
_d_new_tile = (_d_tm_scroll==1)?0:_w_mem_tile_rdata1;
_d_new_foreground = (_d_tm_scroll==1)?0:_w_mem_foreground_rdata1;
_d_new_background = (_d_tm_scroll==1)?7'h40:_w_mem_background_rdata1;
_d_tm_active = 18;
// __block_121
  end
  18: begin
// __block_122_case
// __block_123
_d_tile_addr1 = (_q_x_cursor)+(_q_y_cursor*42)+42;
_d_foreground_addr1 = (_q_x_cursor)+(_q_y_cursor*42)+42;
_d_background_addr1 = (_q_x_cursor)+(_q_y_cursor*42)+42;
_d_tm_active = 19;
// __block_124
  end
  19: begin
// __block_125_case
// __block_126
_d_scroll_tile = _w_mem_tile_rdata1;
_d_scroll_foreground = _w_mem_foreground_rdata1;
_d_scroll_background = _w_mem_background_rdata1;
_d_tm_active = 20;
// __block_127
  end
  20: begin
// __block_128_case
// __block_129
_d_tile_addr1 = (_q_x_cursor)+(_q_y_cursor*42);
_d_tile_wdata1 = _q_scroll_tile;
_d_tile_wenable1 = 1;
_d_foreground_addr1 = (_q_x_cursor)+(_q_y_cursor*42);
_d_foreground_wdata1 = _q_scroll_foreground;
_d_foreground_wenable1 = 1;
_d_background_addr1 = (_q_x_cursor)+(_q_y_cursor*42);
_d_background_wdata1 = _q_scroll_background;
_d_background_wenable1 = 1;
_d_tm_active = 21;
// __block_130
  end
  21: begin
// __block_131_case
// __block_132
if (_q_y_cursor==30) begin
// __block_133
// __block_135
_d_tile_addr1 = (_q_x_cursor)+(31*42);
_d_tile_wdata1 = _q_new_tile;
_d_tile_wenable1 = 1;
_d_foreground_addr1 = (_q_x_cursor)+(31*42);
_d_foreground_wdata1 = _q_new_foreground;
_d_foreground_wenable1 = 1;
_d_background_addr1 = (_q_x_cursor)+(31*42);
_d_background_wdata1 = _q_new_background;
_d_background_wenable1 = 1;
if (_q_x_cursor==41) begin
// __block_136
// __block_138
_d_tm_active = 0;
// __block_139
end else begin
// __block_137
// __block_140
_d_x_cursor = _q_x_cursor+1;
_d_y_cursor = 0;
_d_tm_active = 16;
// __block_141
end
// __block_142
// __block_143
end else begin
// __block_134
// __block_144
_d_y_cursor = _q_y_cursor+1;
_d_tm_active = 18;
// __block_145
end
// __block_146
// __block_147
  end
  22: begin
// __block_148_case
// __block_149
_d_x_cursor = 0;
_d_y_cursor = 31;
_d_tm_active = 23;
// __block_150
  end
  23: begin
// __block_151_case
// __block_152
_d_tile_addr1 = _q_x_cursor+(31*42);
_d_foreground_addr1 = _q_x_cursor+(31*42);
_d_background_addr1 = _q_x_cursor+(31*42);
_d_tm_active = 24;
// __block_153
  end
  24: begin
// __block_154_case
// __block_155
_d_new_tile = (_d_tm_scroll==1)?0:_w_mem_tile_rdata1;
_d_new_foreground = (_d_tm_scroll==1)?0:_w_mem_foreground_rdata1;
_d_new_background = (_d_tm_scroll==1)?7'h40:_w_mem_background_rdata1;
_d_tm_active = 25;
// __block_156
  end
  25: begin
// __block_157_case
// __block_158
_d_tile_addr1 = (_q_x_cursor)+(_q_y_cursor*42)-42;
_d_foreground_addr1 = (_q_x_cursor)+(_q_y_cursor*42)-42;
_d_background_addr1 = (_q_x_cursor)+(_q_y_cursor*42)-42;
_d_tm_active = 26;
// __block_159
  end
  26: begin
// __block_160_case
// __block_161
_d_scroll_tile = _w_mem_tile_rdata1;
_d_scroll_foreground = _w_mem_foreground_rdata1;
_d_scroll_background = _w_mem_background_rdata1;
_d_tm_active = 27;
// __block_162
  end
  27: begin
// __block_163_case
// __block_164
_d_tile_addr1 = (_q_x_cursor)+(_q_y_cursor*42);
_d_tile_wdata1 = _q_scroll_tile;
_d_tile_wenable1 = 1;
_d_foreground_addr1 = (_q_x_cursor)+(_q_y_cursor*42);
_d_foreground_wdata1 = _q_scroll_foreground;
_d_foreground_wenable1 = 1;
_d_background_addr1 = (_q_x_cursor)+(_q_y_cursor*42);
_d_background_wdata1 = _q_scroll_background;
_d_background_wenable1 = 1;
_d_tm_active = 28;
// __block_165
  end
  28: begin
// __block_166_case
// __block_167
if (_q_y_cursor==1) begin
// __block_168
// __block_170
_d_tile_addr1 = (_q_x_cursor)+(0*42);
_d_tile_wdata1 = _q_new_tile;
_d_tile_wenable1 = 1;
_d_foreground_addr1 = (_q_x_cursor)+(0*42);
_d_foreground_wdata1 = _q_new_foreground;
_d_foreground_wenable1 = 1;
_d_background_addr1 = (_q_x_cursor)+(0*42);
_d_background_wdata1 = _q_new_background;
_d_background_wenable1 = 1;
if (_q_x_cursor==41) begin
// __block_171
// __block_173
_d_tm_active = 0;
// __block_174
end else begin
// __block_172
// __block_175
_d_x_cursor = _q_x_cursor+1;
_d_y_cursor = 0;
_d_tm_active = 23;
// __block_176
end
// __block_177
// __block_178
end else begin
// __block_169
// __block_179
_d_y_cursor = _q_y_cursor-1;
_d_tm_active = 26;
// __block_180
end
// __block_181
// __block_182
  end
  29: begin
// __block_183_case
// __block_184
_d_x_cursor = 0;
_d_y_cursor = 0;
_d_tm_offset_x = 0;
_d_tm_offset_y = 0;
_d_tm_active = 30;
// __block_185
  end
  30: begin
// __block_186_case
// __block_187
_d_tile_addr1 = (_q_x_cursor)+(_q_y_cursor*42)-42;
_d_tile_wdata1 = 0;
_d_tile_wenable1 = 1;
_d_foreground_addr1 = (_q_x_cursor)+(_q_y_cursor*42)-42;
_d_foreground_wdata1 = 0;
_d_foreground_wenable1 = 1;
_d_background_addr1 = (_q_x_cursor)+(_q_y_cursor*42)-42;
_d_background_wdata1 = 64;
_d_background_wenable1 = 1;
_d_x_cursor = (_q_x_cursor==41)?0:_q_x_cursor+1;
_d_y_cursor = (_d_x_cursor==41)?_q_y_cursor+1:_q_y_cursor;
_d_tm_active = (_d_x_cursor==41)&&(_d_y_cursor==31)?0:30;
// __block_188
  end
  default: begin
// __block_189_case
// __block_190
_d_tm_active = 0;
// __block_191
  end
endcase
// __block_42
if (_d_tilemap_display) begin
// __block_192
// __block_194
_d_pix_red = _w_tmpixel?_w_mem_foreground_rdata0[4+:2]:_w_mem_background_rdata0[4+:2];
_d_pix_green = _w_tmpixel?_w_mem_foreground_rdata0[2+:2]:_w_mem_background_rdata0[2+:2];
_d_pix_blue = _w_tmpixel?_w_mem_foreground_rdata0[0+:2]:_w_mem_background_rdata0[0+:2];
// __block_195
end else begin
// __block_193
end
// __block_196
// __block_197
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_40
_d_index = 3;
end
3: begin // end of tilemap
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_vectors_mem_vertex(
input      [0:0]             in_vertex_wenable0,
input       [12:0]     in_vertex_wdata0,
input      [7:0]                in_vertex_addr0,
input      [0:0]             in_vertex_wenable1,
input      [12:0]                 in_vertex_wdata1,
input      [7:0]                in_vertex_addr1,
output reg  [12:0]     out_vertex_rdata0,
output reg  [12:0]     out_vertex_rdata1,
input      clock0,
input      clock1
);
reg  [12:0] buffer[255:0];
always @(posedge clock0) begin
  if (in_vertex_wenable0) begin
    buffer[in_vertex_addr0] <= in_vertex_wdata0;
  end else begin
    out_vertex_rdata0 <= buffer[in_vertex_addr0];
  end
end
always @(posedge clock1) begin
  if (in_vertex_wenable1) begin
    buffer[in_vertex_addr1] <= in_vertex_wdata1;
  end else begin
    out_vertex_rdata1 <= buffer[in_vertex_addr1];
  end
end

endmodule

module M_vectors (
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
in_vertices_writer_write,
in_dl_vector_block_number,
in_dl_vector_block_colour,
in_dl_vector_block_xc,
in_dl_vector_block_yc,
in_dl_draw_vector,
in_gpu_active,
out_vector_block_active,
out_gpu_x,
out_gpu_y,
out_gpu_colour,
out_gpu_param0,
out_gpu_param1,
out_gpu_write,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [3:0] in_vector_block_number;
input  [6:0] in_vector_block_colour;
input signed [10:0] in_vector_block_xc;
input signed [10:0] in_vector_block_yc;
input  [0:0] in_draw_vector;
input  [3:0] in_vertices_writer_block;
input  [5:0] in_vertices_writer_vertex;
input signed [5:0] in_vertices_writer_xdelta;
input signed [5:0] in_vertices_writer_ydelta;
input  [0:0] in_vertices_writer_active;
input  [0:0] in_vertices_writer_write;
input  [3:0] in_dl_vector_block_number;
input  [6:0] in_dl_vector_block_colour;
input signed [10:0] in_dl_vector_block_xc;
input signed [10:0] in_dl_vector_block_yc;
input  [0:0] in_dl_draw_vector;
input  [5:0] in_gpu_active;
output  [2:0] out_vector_block_active;
output signed [10:0] out_gpu_x;
output signed [10:0] out_gpu_y;
output  [6:0] out_gpu_colour;
output signed [10:0] out_gpu_param0;
output signed [10:0] out_gpu_param1;
output  [3:0] out_gpu_write;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [12:0] _w_mem_vertex_rdata0;
wire  [12:0] _w_mem_vertex_rdata1;
wire  [12:0] _c_vertex_wdata0;
assign _c_vertex_wdata0 = 0;
wire signed [10:0] _w_deltax;
wire signed [10:0] _w_deltay;

reg  [0:0] _d_vertex_wenable0;
reg  [0:0] _q_vertex_wenable0;
reg  [7:0] _d_vertex_addr0;
reg  [7:0] _q_vertex_addr0;
reg  [0:0] _d_vertex_wenable1;
reg  [0:0] _q_vertex_wenable1;
reg  [12:0] _d_vertex_wdata1;
reg  [12:0] _q_vertex_wdata1;
reg  [7:0] _d_vertex_addr1;
reg  [7:0] _q_vertex_addr1;
reg  [4:0] _d_block_number;
reg  [4:0] _q_block_number;
reg  [3:0] _d_vertices_number;
reg  [3:0] _q_vertices_number;
reg signed [10:0] _d_start_x;
reg signed [10:0] _q_start_x;
reg signed [10:0] _d_start_y;
reg signed [10:0] _q_start_y;
reg  [2:0] _d_vector_block_active,_q_vector_block_active;
reg signed [10:0] _d_gpu_x,_q_gpu_x;
reg signed [10:0] _d_gpu_y,_q_gpu_y;
reg  [6:0] _d_gpu_colour,_q_gpu_colour;
reg signed [10:0] _d_gpu_param0,_q_gpu_param0;
reg signed [10:0] _d_gpu_param1,_q_gpu_param1;
reg  [3:0] _d_gpu_write,_q_gpu_write;
reg  [1:0] _d_index,_q_index;
assign out_vector_block_active = _d_vector_block_active;
assign out_gpu_x = _q_gpu_x;
assign out_gpu_y = _q_gpu_y;
assign out_gpu_colour = _q_gpu_colour;
assign out_gpu_param0 = _q_gpu_param0;
assign out_gpu_param1 = _q_gpu_param1;
assign out_gpu_write = _q_gpu_write;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_vertex_wenable0 <= 0;
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
_q_vertex_wenable0 <= _d_vertex_wenable0;
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
_q_gpu_colour <= _d_gpu_colour;
_q_gpu_param0 <= _d_gpu_param0;
_q_gpu_param1 <= _d_gpu_param1;
_q_gpu_write <= _d_gpu_write;
_q_index <= _d_index;
  end
end


M_vectors_mem_vertex __mem__vertex(
.clock0(clock),
.clock1(clock),
.in_vertex_wenable0(_d_vertex_wenable0),
.in_vertex_wdata0(_c_vertex_wdata0),
.in_vertex_addr0(_d_vertex_addr0),
.in_vertex_wenable1(_d_vertex_wenable1),
.in_vertex_wdata1(_d_vertex_wdata1),
.in_vertex_addr1(_d_vertex_addr1),
.out_vertex_rdata0(_w_mem_vertex_rdata0),
.out_vertex_rdata1(_w_mem_vertex_rdata1)
);

assign _w_deltay = {{6{_w_mem_vertex_rdata0[5+:1]}},_w_mem_vertex_rdata0[0+:5]};
assign _w_deltax = {{6{_w_mem_vertex_rdata0[11+:1]}},_w_mem_vertex_rdata0[6+:5]};

always @* begin
_d_vertex_wenable0 = _q_vertex_wenable0;
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
_d_gpu_colour = _q_gpu_colour;
_d_gpu_param0 = _q_gpu_param0;
_d_gpu_param1 = _q_gpu_param1;
_d_gpu_write = _q_gpu_write;
_d_index = _q_index;
// _always_pre
_d_vertex_addr0 = _q_block_number*16+_q_vertices_number;
_d_vertex_wenable0 = 0;
_d_vertex_wenable1 = 1;
_d_gpu_write = 0;
if (in_vertices_writer_write) begin
// __block_1
// __block_3
_d_vertex_addr1 = in_vertices_writer_block*16+in_vertices_writer_vertex;
_d_vertex_wdata1 = {in_vertices_writer_active,in_vertices_writer_xdelta,in_vertices_writer_ydelta};
// __block_4
end else begin
// __block_2
end
// __block_5
if (in_dl_draw_vector) begin
// __block_6
// __block_8
_d_block_number = in_dl_vector_block_number;
_d_gpu_colour = in_dl_vector_block_colour;
// __block_9
end else begin
// __block_7
// __block_10
if (in_draw_vector) begin
// __block_11
// __block_13
_d_block_number = in_vector_block_number;
_d_gpu_colour = in_vector_block_colour;
// __block_14
end else begin
// __block_12
end
// __block_15
// __block_16
end
// __block_17
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
_d_vertex_wenable0 = 0;
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
// __while__block_18
if (1) begin
// __block_19
// __block_21
  case (_q_vector_block_active)
  1: begin
// __block_23_case
// __block_24
_d_vector_block_active = 2;
// __block_25
  end
  2: begin
// __block_26_case
// __block_27
_d_start_x = in_vector_block_xc+_w_deltax;
_d_start_y = in_vector_block_yc+_w_deltay;
_d_vertices_number = 1;
_d_vector_block_active = 3;
// __block_28
  end
  3: begin
// __block_29_case
// __block_30
_d_vector_block_active = 4;
// __block_31
  end
  4: begin
// __block_32_case
// __block_33
_d_vector_block_active = (_w_mem_vertex_rdata0[12+:1])?(in_gpu_active!=0)?4:5:0;
// __block_34
  end
  5: begin
// __block_35_case
// __block_36
_d_gpu_x = _q_start_x;
_d_gpu_y = _q_start_y;
_d_gpu_param0 = in_vector_block_xc+_w_deltax;
_d_gpu_param1 = in_vector_block_yc+_w_deltay;
_d_gpu_write = 3;
_d_start_x = in_vector_block_xc+_w_deltax;
_d_start_y = in_vector_block_yc+_w_deltay;
_d_vertices_number = (_q_vertices_number==15)?0:_q_vertices_number+1;
_d_vector_block_active = (_d_vertices_number==15)?0:3;
// __block_37
  end
  default: begin
// __block_38_case
// __block_39
_d_vector_block_active = (in_draw_vector)?1:(in_dl_draw_vector)?1:0;
_d_vertices_number = 0;
// __block_40
  end
endcase
// __block_22
// __block_41
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_20
_d_index = 3;
end
3: begin // end of vectors
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_displaylist_mem_dlentries(
input      [0:0]             in_dlentries_wenable0,
input       [77:0]     in_dlentries_wdata0,
input      [4:0]                in_dlentries_addr0,
input      [0:0]             in_dlentries_wenable1,
input      [77:0]                 in_dlentries_wdata1,
input      [4:0]                in_dlentries_addr1,
output reg  [77:0]     out_dlentries_rdata0,
output reg  [77:0]     out_dlentries_rdata1,
input      clock0,
input      clock1
);
reg  [77:0] buffer[31:0];
always @(posedge clock0) begin
  if (in_dlentries_wenable0) begin
    buffer[in_dlentries_addr0] <= in_dlentries_wdata0;
  end else begin
    out_dlentries_rdata0 <= buffer[in_dlentries_addr0];
  end
end
always @(posedge clock1) begin
  if (in_dlentries_wenable1) begin
    buffer[in_dlentries_addr1] <= in_dlentries_wdata1;
  end else begin
    out_dlentries_rdata1 <= buffer[in_dlentries_addr1];
  end
end

endmodule

module M_displaylist (
in_start_entry,
in_finish_entry,
in_start_displaylist,
in_writer_entry_number,
in_writer_active,
in_writer_command,
in_writer_colour,
in_writer_x,
in_writer_y,
in_writer_p0,
in_writer_p1,
in_writer_p2,
in_writer_p3,
in_writer_write,
in_gpu_active,
in_vector_block_active,
out_display_list_active,
out_read_active,
out_read_command,
out_read_colour,
out_read_x,
out_read_y,
out_read_p0,
out_read_p1,
out_read_p2,
out_read_p3,
out_gpu_x,
out_gpu_y,
out_gpu_colour,
out_gpu_param0,
out_gpu_param1,
out_gpu_param2,
out_gpu_param3,
out_gpu_write,
out_vector_block_number,
out_vector_block_colour,
out_vector_block_xc,
out_vector_block_yc,
out_draw_vector,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [4:0] in_start_entry;
input  [4:0] in_finish_entry;
input  [0:0] in_start_displaylist;
input  [4:0] in_writer_entry_number;
input  [0:0] in_writer_active;
input  [3:0] in_writer_command;
input  [6:0] in_writer_colour;
input  [10:0] in_writer_x;
input  [10:0] in_writer_y;
input  [10:0] in_writer_p0;
input  [10:0] in_writer_p1;
input  [10:0] in_writer_p2;
input  [10:0] in_writer_p3;
input  [3:0] in_writer_write;
input  [5:0] in_gpu_active;
input  [2:0] in_vector_block_active;
output  [3:0] out_display_list_active;
output  [0:0] out_read_active;
output  [3:0] out_read_command;
output  [6:0] out_read_colour;
output  [10:0] out_read_x;
output  [10:0] out_read_y;
output  [10:0] out_read_p0;
output  [10:0] out_read_p1;
output  [10:0] out_read_p2;
output  [10:0] out_read_p3;
output signed [10:0] out_gpu_x;
output signed [10:0] out_gpu_y;
output  [6:0] out_gpu_colour;
output signed [10:0] out_gpu_param0;
output signed [10:0] out_gpu_param1;
output signed [10:0] out_gpu_param2;
output signed [10:0] out_gpu_param3;
output  [3:0] out_gpu_write;
output  [4:0] out_vector_block_number;
output  [6:0] out_vector_block_colour;
output signed [10:0] out_vector_block_xc;
output signed [10:0] out_vector_block_yc;
output  [0:0] out_draw_vector;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [77:0] _w_mem_dlentries_rdata0;
wire  [77:0] _w_mem_dlentries_rdata1;
wire  [77:0] _c_dlentries_wdata0;
assign _c_dlentries_wdata0 = 0;

reg  [0:0] _d_dlentries_wenable0;
reg  [0:0] _q_dlentries_wenable0;
reg  [4:0] _d_dlentries_addr0;
reg  [4:0] _q_dlentries_addr0;
reg  [0:0] _d_dlentries_wenable1;
reg  [0:0] _q_dlentries_wenable1;
reg  [77:0] _d_dlentries_wdata1;
reg  [77:0] _q_dlentries_wdata1;
reg  [4:0] _d_dlentries_addr1;
reg  [4:0] _q_dlentries_addr1;
reg  [4:0] _d_entry_number;
reg  [4:0] _q_entry_number;
reg  [4:0] _d_finish_number;
reg  [4:0] _q_finish_number;
reg  [3:0] _d_display_list_active,_q_display_list_active;
reg  [0:0] _d_read_active,_q_read_active;
reg  [3:0] _d_read_command,_q_read_command;
reg  [6:0] _d_read_colour,_q_read_colour;
reg  [10:0] _d_read_x,_q_read_x;
reg  [10:0] _d_read_y,_q_read_y;
reg  [10:0] _d_read_p0,_q_read_p0;
reg  [10:0] _d_read_p1,_q_read_p1;
reg  [10:0] _d_read_p2,_q_read_p2;
reg  [10:0] _d_read_p3,_q_read_p3;
reg signed [10:0] _d_gpu_x,_q_gpu_x;
reg signed [10:0] _d_gpu_y,_q_gpu_y;
reg  [6:0] _d_gpu_colour,_q_gpu_colour;
reg signed [10:0] _d_gpu_param0,_q_gpu_param0;
reg signed [10:0] _d_gpu_param1,_q_gpu_param1;
reg signed [10:0] _d_gpu_param2,_q_gpu_param2;
reg signed [10:0] _d_gpu_param3,_q_gpu_param3;
reg  [3:0] _d_gpu_write,_q_gpu_write;
reg  [4:0] _d_vector_block_number,_q_vector_block_number;
reg  [6:0] _d_vector_block_colour,_q_vector_block_colour;
reg signed [10:0] _d_vector_block_xc,_q_vector_block_xc;
reg signed [10:0] _d_vector_block_yc,_q_vector_block_yc;
reg  [0:0] _d_draw_vector,_q_draw_vector;
reg  [1:0] _d_index,_q_index;
assign out_display_list_active = _q_display_list_active;
assign out_read_active = _q_read_active;
assign out_read_command = _q_read_command;
assign out_read_colour = _q_read_colour;
assign out_read_x = _q_read_x;
assign out_read_y = _q_read_y;
assign out_read_p0 = _q_read_p0;
assign out_read_p1 = _q_read_p1;
assign out_read_p2 = _q_read_p2;
assign out_read_p3 = _q_read_p3;
assign out_gpu_x = _d_gpu_x;
assign out_gpu_y = _d_gpu_y;
assign out_gpu_colour = _d_gpu_colour;
assign out_gpu_param0 = _d_gpu_param0;
assign out_gpu_param1 = _d_gpu_param1;
assign out_gpu_param2 = _d_gpu_param2;
assign out_gpu_param3 = _d_gpu_param3;
assign out_gpu_write = _d_gpu_write;
assign out_vector_block_number = _d_vector_block_number;
assign out_vector_block_colour = _d_vector_block_colour;
assign out_vector_block_xc = _d_vector_block_xc;
assign out_vector_block_yc = _d_vector_block_yc;
assign out_draw_vector = _d_draw_vector;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_dlentries_wenable0 <= 0;
_q_dlentries_addr0 <= 0;
_q_dlentries_wenable1 <= 0;
_q_dlentries_wdata1 <= 0;
_q_dlentries_addr1 <= 0;
  if (reset) begin
_q_index <= 3;
end else begin
_q_index <= 0;
end
  end else begin
_q_dlentries_wenable0 <= _d_dlentries_wenable0;
_q_dlentries_addr0 <= _d_dlentries_addr0;
_q_dlentries_wenable1 <= _d_dlentries_wenable1;
_q_dlentries_wdata1 <= _d_dlentries_wdata1;
_q_dlentries_addr1 <= _d_dlentries_addr1;
_q_entry_number <= _d_entry_number;
_q_finish_number <= _d_finish_number;
_q_display_list_active <= _d_display_list_active;
_q_read_active <= _d_read_active;
_q_read_command <= _d_read_command;
_q_read_colour <= _d_read_colour;
_q_read_x <= _d_read_x;
_q_read_y <= _d_read_y;
_q_read_p0 <= _d_read_p0;
_q_read_p1 <= _d_read_p1;
_q_read_p2 <= _d_read_p2;
_q_read_p3 <= _d_read_p3;
_q_gpu_x <= _d_gpu_x;
_q_gpu_y <= _d_gpu_y;
_q_gpu_colour <= _d_gpu_colour;
_q_gpu_param0 <= _d_gpu_param0;
_q_gpu_param1 <= _d_gpu_param1;
_q_gpu_param2 <= _d_gpu_param2;
_q_gpu_param3 <= _d_gpu_param3;
_q_gpu_write <= _d_gpu_write;
_q_vector_block_number <= _d_vector_block_number;
_q_vector_block_colour <= _d_vector_block_colour;
_q_vector_block_xc <= _d_vector_block_xc;
_q_vector_block_yc <= _d_vector_block_yc;
_q_draw_vector <= _d_draw_vector;
_q_index <= _d_index;
  end
end


M_displaylist_mem_dlentries __mem__dlentries(
.clock0(clock),
.clock1(clock),
.in_dlentries_wenable0(_d_dlentries_wenable0),
.in_dlentries_wdata0(_c_dlentries_wdata0),
.in_dlentries_addr0(_d_dlentries_addr0),
.in_dlentries_wenable1(_d_dlentries_wenable1),
.in_dlentries_wdata1(_d_dlentries_wdata1),
.in_dlentries_addr1(_d_dlentries_addr1),
.out_dlentries_rdata0(_w_mem_dlentries_rdata0),
.out_dlentries_rdata1(_w_mem_dlentries_rdata1)
);


always @* begin
_d_dlentries_wenable0 = _q_dlentries_wenable0;
_d_dlentries_addr0 = _q_dlentries_addr0;
_d_dlentries_wenable1 = _q_dlentries_wenable1;
_d_dlentries_wdata1 = _q_dlentries_wdata1;
_d_dlentries_addr1 = _q_dlentries_addr1;
_d_entry_number = _q_entry_number;
_d_finish_number = _q_finish_number;
_d_display_list_active = _q_display_list_active;
_d_read_active = _q_read_active;
_d_read_command = _q_read_command;
_d_read_colour = _q_read_colour;
_d_read_x = _q_read_x;
_d_read_y = _q_read_y;
_d_read_p0 = _q_read_p0;
_d_read_p1 = _q_read_p1;
_d_read_p2 = _q_read_p2;
_d_read_p3 = _q_read_p3;
_d_gpu_x = _q_gpu_x;
_d_gpu_y = _q_gpu_y;
_d_gpu_colour = _q_gpu_colour;
_d_gpu_param0 = _q_gpu_param0;
_d_gpu_param1 = _q_gpu_param1;
_d_gpu_param2 = _q_gpu_param2;
_d_gpu_param3 = _q_gpu_param3;
_d_gpu_write = _q_gpu_write;
_d_vector_block_number = _q_vector_block_number;
_d_vector_block_colour = _q_vector_block_colour;
_d_vector_block_xc = _q_vector_block_xc;
_d_vector_block_yc = _q_vector_block_yc;
_d_draw_vector = _q_draw_vector;
_d_index = _q_index;
// _always_pre
_d_dlentries_addr0 = _q_entry_number;
_d_dlentries_wenable0 = 0;
_d_dlentries_wenable1 = 1;
_d_vector_block_colour = _w_mem_dlentries_rdata0[66+:7];
_d_vector_block_number = _w_mem_dlentries_rdata0[33+:11];
_d_vector_block_xc = _w_mem_dlentries_rdata0[55+:11];
_d_vector_block_yc = _w_mem_dlentries_rdata0[44+:11];
_d_draw_vector = (_q_display_list_active==4)&&(_w_mem_dlentries_rdata0[73+:4]==15)?1:0;
_d_gpu_write = (_q_display_list_active==4)&&(_w_mem_dlentries_rdata0[73+:4]!=15)?_w_mem_dlentries_rdata0[73+:4]:0;
_d_gpu_colour = _w_mem_dlentries_rdata0[66+:7];
_d_gpu_x = _w_mem_dlentries_rdata0[55+:11];
_d_gpu_y = _w_mem_dlentries_rdata0[44+:11];
_d_gpu_param0 = _w_mem_dlentries_rdata0[33+:11];
_d_gpu_param1 = _w_mem_dlentries_rdata0[22+:11];
_d_gpu_param2 = _w_mem_dlentries_rdata0[11+:11];
_d_gpu_param3 = _w_mem_dlentries_rdata0[0+:11];
  case (in_writer_write)
  1: begin
// __block_2_case
// __block_3
_d_dlentries_addr1 = in_writer_entry_number;
_d_dlentries_wdata1 = {in_writer_active,in_writer_command,in_writer_colour,in_writer_x,in_writer_y,in_writer_p0,in_writer_p1,in_writer_p2,in_writer_p3};
// __block_4
  end
endcase
// __block_1
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
_d_dlentries_wenable0 = 0;
_d_dlentries_addr0 = 0;
_d_dlentries_wenable1 = 0;
_d_dlentries_wdata1 = 0;
_d_dlentries_addr1 = 0;
// --
_d_index = 1;
end
1: begin
// __while__block_5
if (1) begin
// __block_6
// __block_8
  case (_q_display_list_active)
  1: begin
// __block_10_case
// __block_11
_d_display_list_active = 2;
// __block_12
  end
  2: begin
// __block_13_case
// __block_14
_d_display_list_active = 3;
// __block_15
  end
  3: begin
// __block_16_case
// __block_17
if (_w_mem_dlentries_rdata0[77+:1]==1) begin
// __block_18
// __block_20
_d_display_list_active = (in_gpu_active==0)&&(in_vector_block_active==0)?4:3;
// __block_21
end else begin
// __block_19
// __block_22
_d_entry_number = (_q_entry_number==_q_finish_number)?in_start_entry:_q_entry_number+1;
_d_display_list_active = (_d_entry_number==_q_finish_number)?0:1;
// __block_23
end
// __block_24
// __block_25
  end
  4: begin
// __block_26_case
// __block_27
_d_display_list_active = 5;
// __block_28
  end
  5: begin
// __block_29_case
// __block_30
_d_gpu_write = 0;
_d_draw_vector = 0;
_d_entry_number = (_q_entry_number==_q_finish_number)?in_start_entry:_q_entry_number+1;
_d_display_list_active = (_d_entry_number==_q_finish_number)?0:1;
// __block_31
  end
  default: begin
// __block_32_case
// __block_33
_d_display_list_active = (in_start_displaylist==1)?1:0;
_d_entry_number = in_start_entry;
_d_finish_number = in_finish_entry;
// __block_34
  end
endcase
// __block_9
// __block_35
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_7
_d_index = 3;
end
3: begin // end of displaylist
end
default: begin 
_d_index = 3;
 end
endcase
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
input  [2:0] in_waveform;
input  [5:0] in_note;
input  [15:0] in_duration;
input  [1:0] in_apu_write;
input  [15:0] in_staticGenerator;
output  [0:0] out_audio_active;
output  [3:0] out_audio_output;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [3:0] _c_waveformtable[127:0];
assign _c_waveformtable[0] = 15;
assign _c_waveformtable[1] = 15;
assign _c_waveformtable[2] = 15;
assign _c_waveformtable[3] = 15;
assign _c_waveformtable[4] = 15;
assign _c_waveformtable[5] = 15;
assign _c_waveformtable[6] = 15;
assign _c_waveformtable[7] = 15;
assign _c_waveformtable[8] = 15;
assign _c_waveformtable[9] = 15;
assign _c_waveformtable[10] = 15;
assign _c_waveformtable[11] = 15;
assign _c_waveformtable[12] = 15;
assign _c_waveformtable[13] = 15;
assign _c_waveformtable[14] = 15;
assign _c_waveformtable[15] = 15;
assign _c_waveformtable[16] = 0;
assign _c_waveformtable[17] = 0;
assign _c_waveformtable[18] = 0;
assign _c_waveformtable[19] = 0;
assign _c_waveformtable[20] = 0;
assign _c_waveformtable[21] = 0;
assign _c_waveformtable[22] = 0;
assign _c_waveformtable[23] = 0;
assign _c_waveformtable[24] = 0;
assign _c_waveformtable[25] = 0;
assign _c_waveformtable[26] = 0;
assign _c_waveformtable[27] = 0;
assign _c_waveformtable[28] = 0;
assign _c_waveformtable[29] = 0;
assign _c_waveformtable[30] = 0;
assign _c_waveformtable[31] = 0;
assign _c_waveformtable[32] = 0;
assign _c_waveformtable[33] = 0;
assign _c_waveformtable[34] = 1;
assign _c_waveformtable[35] = 1;
assign _c_waveformtable[36] = 2;
assign _c_waveformtable[37] = 2;
assign _c_waveformtable[38] = 3;
assign _c_waveformtable[39] = 3;
assign _c_waveformtable[40] = 4;
assign _c_waveformtable[41] = 4;
assign _c_waveformtable[42] = 5;
assign _c_waveformtable[43] = 5;
assign _c_waveformtable[44] = 6;
assign _c_waveformtable[45] = 6;
assign _c_waveformtable[46] = 7;
assign _c_waveformtable[47] = 7;
assign _c_waveformtable[48] = 8;
assign _c_waveformtable[49] = 8;
assign _c_waveformtable[50] = 9;
assign _c_waveformtable[51] = 9;
assign _c_waveformtable[52] = 10;
assign _c_waveformtable[53] = 10;
assign _c_waveformtable[54] = 11;
assign _c_waveformtable[55] = 11;
assign _c_waveformtable[56] = 12;
assign _c_waveformtable[57] = 12;
assign _c_waveformtable[58] = 13;
assign _c_waveformtable[59] = 13;
assign _c_waveformtable[60] = 14;
assign _c_waveformtable[61] = 14;
assign _c_waveformtable[62] = 15;
assign _c_waveformtable[63] = 15;
assign _c_waveformtable[64] = 0;
assign _c_waveformtable[65] = 1;
assign _c_waveformtable[66] = 2;
assign _c_waveformtable[67] = 3;
assign _c_waveformtable[68] = 4;
assign _c_waveformtable[69] = 5;
assign _c_waveformtable[70] = 6;
assign _c_waveformtable[71] = 7;
assign _c_waveformtable[72] = 8;
assign _c_waveformtable[73] = 9;
assign _c_waveformtable[74] = 10;
assign _c_waveformtable[75] = 11;
assign _c_waveformtable[76] = 12;
assign _c_waveformtable[77] = 13;
assign _c_waveformtable[78] = 14;
assign _c_waveformtable[79] = 15;
assign _c_waveformtable[80] = 15;
assign _c_waveformtable[81] = 14;
assign _c_waveformtable[82] = 13;
assign _c_waveformtable[83] = 12;
assign _c_waveformtable[84] = 11;
assign _c_waveformtable[85] = 10;
assign _c_waveformtable[86] = 9;
assign _c_waveformtable[87] = 8;
assign _c_waveformtable[88] = 7;
assign _c_waveformtable[89] = 6;
assign _c_waveformtable[90] = 5;
assign _c_waveformtable[91] = 4;
assign _c_waveformtable[92] = 3;
assign _c_waveformtable[93] = 2;
assign _c_waveformtable[94] = 1;
assign _c_waveformtable[95] = 0;
assign _c_waveformtable[96] = 7;
assign _c_waveformtable[97] = 8;
assign _c_waveformtable[98] = 10;
assign _c_waveformtable[99] = 11;
assign _c_waveformtable[100] = 12;
assign _c_waveformtable[101] = 13;
assign _c_waveformtable[102] = 13;
assign _c_waveformtable[103] = 14;
assign _c_waveformtable[104] = 15;
assign _c_waveformtable[105] = 14;
assign _c_waveformtable[106] = 13;
assign _c_waveformtable[107] = 13;
assign _c_waveformtable[108] = 12;
assign _c_waveformtable[109] = 11;
assign _c_waveformtable[110] = 10;
assign _c_waveformtable[111] = 8;
assign _c_waveformtable[112] = 7;
assign _c_waveformtable[113] = 6;
assign _c_waveformtable[114] = 4;
assign _c_waveformtable[115] = 3;
assign _c_waveformtable[116] = 2;
assign _c_waveformtable[117] = 1;
assign _c_waveformtable[118] = 1;
assign _c_waveformtable[119] = 0;
assign _c_waveformtable[120] = 0;
assign _c_waveformtable[121] = 0;
assign _c_waveformtable[122] = 1;
assign _c_waveformtable[123] = 1;
assign _c_waveformtable[124] = 2;
assign _c_waveformtable[125] = 3;
assign _c_waveformtable[126] = 4;
assign _c_waveformtable[127] = 6;
wire  [15:0] _c_frequencytable[63:0];
assign _c_frequencytable[0] = 0;
assign _c_frequencytable[1] = 23889;
assign _c_frequencytable[2] = 22548;
assign _c_frequencytable[3] = 21283;
assign _c_frequencytable[4] = 20088;
assign _c_frequencytable[5] = 18961;
assign _c_frequencytable[6] = 17897;
assign _c_frequencytable[7] = 16892;
assign _c_frequencytable[8] = 15944;
assign _c_frequencytable[9] = 15049;
assign _c_frequencytable[10] = 14205;
assign _c_frequencytable[11] = 13407;
assign _c_frequencytable[12] = 12655;
assign _c_frequencytable[13] = 11945;
assign _c_frequencytable[14] = 11274;
assign _c_frequencytable[15] = 10641;
assign _c_frequencytable[16] = 10044;
assign _c_frequencytable[17] = 9480;
assign _c_frequencytable[18] = 8948;
assign _c_frequencytable[19] = 8446;
assign _c_frequencytable[20] = 7972;
assign _c_frequencytable[21] = 7525;
assign _c_frequencytable[22] = 7102;
assign _c_frequencytable[23] = 6704;
assign _c_frequencytable[24] = 6327;
assign _c_frequencytable[25] = 5972;
assign _c_frequencytable[26] = 5637;
assign _c_frequencytable[27] = 5321;
assign _c_frequencytable[28] = 5022;
assign _c_frequencytable[29] = 4740;
assign _c_frequencytable[30] = 4474;
assign _c_frequencytable[31] = 4223;
assign _c_frequencytable[32] = 3986;
assign _c_frequencytable[33] = 3762;
assign _c_frequencytable[34] = 3551;
assign _c_frequencytable[35] = 3352;
assign _c_frequencytable[36] = 3164;
assign _c_frequencytable[37] = 2896;
assign _c_frequencytable[38] = 2819;
assign _c_frequencytable[39] = 2660;
assign _c_frequencytable[40] = 2511;
assign _c_frequencytable[41] = 2370;
assign _c_frequencytable[42] = 2237;
assign _c_frequencytable[43] = 2112;
assign _c_frequencytable[44] = 1993;
assign _c_frequencytable[45] = 1881;
assign _c_frequencytable[46] = 1776;
assign _c_frequencytable[47] = 1676;
assign _c_frequencytable[48] = 1582;
assign _c_frequencytable[49] = 1493;
assign _c_frequencytable[50] = 1409;
assign _c_frequencytable[51] = 1330;
assign _c_frequencytable[52] = 1256;
assign _c_frequencytable[53] = 1185;
assign _c_frequencytable[54] = 1119;
assign _c_frequencytable[55] = 1056;
assign _c_frequencytable[56] = 997;
assign _c_frequencytable[57] = 941;
assign _c_frequencytable[58] = 888;
assign _c_frequencytable[59] = 838;
assign _c_frequencytable[60] = 791;
assign _c_frequencytable[61] = 747;
assign _c_frequencytable[62] = 705;
assign _c_frequencytable[63] = 665;
reg  [15:0] _t_milliseconds_1;
reg  [15:0] _t_milliseconds_2;
wire  [3:0] _w_audio_output_1;
wire  [15:0] _w_note_1_frequency;
wire  [3:0] _w_audio_output_2;
wire  [15:0] _w_note_2_frequency;

reg  [2:0] _d_waveform_1;
reg  [2:0] _q_waveform_1;
reg  [5:0] _d_note_1;
reg  [5:0] _q_note_1;
reg  [4:0] _d_point_1;
reg  [4:0] _q_point_1;
reg  [15:0] _d_counter25mhz_1;
reg  [15:0] _q_counter25mhz_1;
reg  [15:0] _d_counter1khz_1;
reg  [15:0] _q_counter1khz_1;
reg  [2:0] _d_waveform_2;
reg  [2:0] _q_waveform_2;
reg  [5:0] _d_note_2;
reg  [5:0] _q_note_2;
reg  [4:0] _d_point_2;
reg  [4:0] _q_point_2;
reg  [15:0] _d_counter25mhz_2;
reg  [15:0] _q_counter25mhz_2;
reg  [15:0] _d_counter1khz_2;
reg  [15:0] _q_counter1khz_2;
reg  [15:0] _d_duration_1;
reg  [15:0] _q_duration_1;
reg  [15:0] _d_duration_2;
reg  [15:0] _q_duration_2;
reg  [0:0] _d_audio_active,_q_audio_active;
reg  [3:0] _d_audio_output,_q_audio_output;
reg  [1:0] _d_index,_q_index;
assign out_audio_active = _d_audio_active;
assign out_audio_output = _d_audio_output;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_waveform_1 <= _d_waveform_1;
_q_note_1 <= _d_note_1;
_q_point_1 <= _d_point_1;
_q_counter25mhz_1 <= _d_counter25mhz_1;
_q_counter1khz_1 <= _d_counter1khz_1;
_q_waveform_2 <= _d_waveform_2;
_q_note_2 <= _d_note_2;
_q_point_2 <= _d_point_2;
_q_counter25mhz_2 <= _d_counter25mhz_2;
_q_counter1khz_2 <= _d_counter1khz_2;
_q_duration_1 <= _d_duration_1;
_q_duration_2 <= _d_duration_2;
_q_audio_active <= _d_audio_active;
_q_audio_output <= _d_audio_output;
_q_index <= _d_index;
  end
end



assign _w_note_2_frequency = _c_frequencytable[_q_note_2];
assign _w_audio_output_2 = _c_waveformtable[_q_waveform_2*32+_q_point_2];
assign _w_note_1_frequency = _c_frequencytable[_q_note_1];
assign _w_audio_output_1 = _c_waveformtable[_q_waveform_1*32+_q_point_1];

always @* begin
_d_waveform_1 = _q_waveform_1;
_d_note_1 = _q_note_1;
_d_point_1 = _q_point_1;
_d_counter25mhz_1 = _q_counter25mhz_1;
_d_counter1khz_1 = _q_counter1khz_1;
_d_waveform_2 = _q_waveform_2;
_d_note_2 = _q_note_2;
_d_point_2 = _q_point_2;
_d_counter25mhz_2 = _q_counter25mhz_2;
_d_counter1khz_2 = _q_counter1khz_2;
_d_duration_1 = _q_duration_1;
_d_duration_2 = _q_duration_2;
_d_audio_active = _q_audio_active;
_d_audio_output = _q_audio_output;
_d_index = _q_index;
_t_milliseconds_1 = 0;
_t_milliseconds_2 = 0;
// _always_pre
_d_audio_active = (_q_duration_1>0)||(_q_duration_2>0);
if ((_q_duration_1!=0)&&(_q_counter25mhz_1==0)) begin
// __block_1
// __block_3
_d_audio_output = (_q_waveform_1==4)?in_staticGenerator:_w_audio_output_1;
// __block_4
end else begin
// __block_2
end
// __block_5
if ((_q_duration_2!=0)&&(_q_counter25mhz_2==0)) begin
// __block_6
// __block_8
_d_audio_output = (_q_waveform_2==4)?in_staticGenerator:_w_audio_output_2;
// __block_9
end else begin
// __block_7
end
// __block_10
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
// --
_d_index = 1;
end
1: begin
// __while__block_11
if (1) begin
// __block_12
// __block_14
  case (in_apu_write)
  1: begin
// __block_16_case
// __block_17
_d_waveform_1 = in_waveform;
_d_note_1 = in_note;
_d_duration_1 = in_duration;
_t_milliseconds_1 = 0;
_d_point_1 = 0;
_d_counter25mhz_1 = 0;
_d_counter1khz_1 = 25000;
// __block_18
  end
  2: begin
// __block_19_case
// __block_20
_d_waveform_2 = in_waveform;
_d_note_2 = in_note;
_d_duration_2 = in_duration;
_t_milliseconds_2 = 0;
_d_point_2 = 0;
_d_counter25mhz_2 = 0;
_d_counter1khz_2 = 25000;
// __block_21
  end
  default: begin
// __block_22_case
// __block_23
if (_q_duration_1!=0) begin
// __block_24
// __block_26
_d_counter25mhz_1 = (_q_counter25mhz_1!=0)?_q_counter25mhz_1-1:_w_note_1_frequency;
_d_point_1 = (_d_counter25mhz_1!=0)?_q_point_1:_q_point_1+1;
_d_counter1khz_1 = (_q_counter1khz_1!=0)?_q_counter1khz_1-1:25000;
_d_duration_1 = (_d_counter1khz_1!=0)?_q_duration_1:_q_duration_1-1;
// __block_27
end else begin
// __block_25
end
// __block_28
if (_q_duration_2!=0) begin
// __block_29
// __block_31
_d_counter25mhz_2 = (_q_counter25mhz_2!=0)?_q_counter25mhz_2-1:_w_note_2_frequency;
_d_point_2 = (_d_counter25mhz_2!=0)?_q_point_2:_q_point_2+1;
_d_counter1khz_2 = (_q_counter1khz_2!=0)?_q_counter1khz_2-1:25000;
_d_duration_2 = (_d_counter1khz_2!=0)?_q_duration_2:_q_duration_2-1;
// __block_32
end else begin
// __block_30
end
// __block_33
// __block_34
  end
endcase
// __block_15
// __block_35
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_13
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


module M_divmod32by16 (
in_dividendh,
in_dividendl,
in_divisor,
in_start,
out_quotient,
out_remainder,
out_active,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [15:0] in_dividendh;
input  [15:0] in_dividendl;
input  [15:0] in_divisor;
input  [1:0] in_start;
output  [15:0] out_quotient;
output  [15:0] out_remainder;
output  [1:0] out_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [31:0] _d_dividend_copy;
reg  [31:0] _q_dividend_copy;
reg  [31:0] _d_divisor_copy;
reg  [31:0] _q_divisor_copy;
reg  [31:0] _d_quotient_copy;
reg  [31:0] _q_quotient_copy;
reg  [31:0] _d_remainder_copy;
reg  [31:0] _q_remainder_copy;
reg  [0:0] _d_resultsign;
reg  [0:0] _q_resultsign;
reg  [5:0] _d_bit;
reg  [5:0] _q_bit;
reg  [15:0] _d_quotient,_q_quotient;
reg  [15:0] _d_remainder,_q_remainder;
reg  [1:0] _d_active,_q_active;
reg  [1:0] _d_index,_q_index;
assign out_quotient = _q_quotient;
assign out_remainder = _q_remainder;
assign out_active = _q_active;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_dividend_copy <= _d_dividend_copy;
_q_divisor_copy <= _d_divisor_copy;
_q_quotient_copy <= _d_quotient_copy;
_q_remainder_copy <= _d_remainder_copy;
_q_resultsign <= _d_resultsign;
_q_bit <= _d_bit;
_q_quotient <= _d_quotient;
_q_remainder <= _d_remainder;
_q_active <= _d_active;
_q_index <= _d_index;
  end
end




always @* begin
_d_dividend_copy = _q_dividend_copy;
_d_divisor_copy = _q_divisor_copy;
_d_quotient_copy = _q_quotient_copy;
_d_remainder_copy = _q_remainder_copy;
_d_resultsign = _q_resultsign;
_d_bit = _q_bit;
_d_quotient = _q_quotient;
_d_remainder = _q_remainder;
_d_active = _q_active;
_d_index = _q_index;
// _always_pre
_d_index = 3;
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
  case (_q_active)
  0: begin
// __block_6_case
// __block_7
  case (in_start)
  1: begin
// __block_9_case
// __block_10
if (in_divisor!=0) begin
// __block_11
// __block_13
_d_bit = 32;
_d_quotient_copy = 0;
_d_remainder_copy = 0;
_d_dividend_copy = {in_dividendh,in_dividendl};
_d_divisor_copy = {16'b0,in_divisor};
_d_resultsign = 0;
_d_active = 1;
// __block_14
end else begin
// __block_12
// __block_15
_d_resultsign = 0;
_d_quotient_copy = 32'hffff;
_d_remainder_copy = 32'hffff;
// __block_16
end
// __block_17
// __block_18
  end
  2: begin
// __block_19_case
// __block_20
if (in_divisor!=0) begin
// __block_21
// __block_23
_d_bit = 32;
_d_quotient_copy = 0;
_d_remainder_copy = 0;
_d_dividend_copy = in_dividendh[15+:1]?-{in_dividendh,in_dividendl}:{in_dividendh,in_dividendl};
_d_divisor_copy = in_divisor[15+:1]?{16'b0,-in_divisor}:{16'b0,in_divisor};
_d_resultsign = in_dividendh[15+:1]!=in_divisor[15+:1];
_d_active = 1;
// __block_24
end else begin
// __block_22
// __block_25
_d_resultsign = 0;
_d_quotient_copy = 32'hffff;
_d_remainder_copy = 32'hffff;
// __block_26
end
// __block_27
// __block_28
  end
endcase
// __block_8
// __block_29
  end
  1: begin
// __block_30_case
// __block_31
if ($unsigned({_q_remainder_copy[0+:31],_q_dividend_copy[_q_bit-1+:1]})>=$unsigned(_q_divisor_copy)) begin
// __block_32
// __block_34
_d_remainder_copy = {_q_remainder_copy[0+:31],_q_dividend_copy[_q_bit-1+:1]}-_q_divisor_copy;
_d_quotient_copy[_q_bit-1+:1] = 1;
// __block_35
end else begin
// __block_33
// __block_36
_d_remainder_copy = {_q_remainder_copy[0+:31],_q_dividend_copy[_q_bit-1+:1]};
// __block_37
end
// __block_38
_d_bit = _q_bit-1;
_d_active = (_d_bit!=0)?1:2;
// __block_39
  end
  2: begin
// __block_40_case
// __block_41
_d_quotient = _q_resultsign?-_q_quotient_copy[0+:16]:_q_quotient_copy[0+:16];
_d_remainder = _q_remainder_copy[0+:16];
_d_active = 0;
// __block_42
  end
endcase
// __block_5
// __block_43
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of divmod32by16
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_divmod16by16 (
in_dividend,
in_divisor,
in_start,
out_quotient,
out_remainder,
out_active,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [15:0] in_dividend;
input  [15:0] in_divisor;
input  [0:0] in_start;
output  [15:0] out_quotient;
output  [15:0] out_remainder;
output  [1:0] out_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [15:0] _d_dividend_copy;
reg  [15:0] _q_dividend_copy;
reg  [15:0] _d_divisor_copy;
reg  [15:0] _q_divisor_copy;
reg  [15:0] _d_quotient_copy;
reg  [15:0] _q_quotient_copy;
reg  [15:0] _d_remainder_copy;
reg  [15:0] _q_remainder_copy;
reg  [0:0] _d_resultsign;
reg  [0:0] _q_resultsign;
reg  [5:0] _d_bit;
reg  [5:0] _q_bit;
reg  [15:0] _d_quotient,_q_quotient;
reg  [15:0] _d_remainder,_q_remainder;
reg  [1:0] _d_active,_q_active;
reg  [1:0] _d_index,_q_index;
assign out_quotient = _q_quotient;
assign out_remainder = _q_remainder;
assign out_active = _q_active;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_dividend_copy <= _d_dividend_copy;
_q_divisor_copy <= _d_divisor_copy;
_q_quotient_copy <= _d_quotient_copy;
_q_remainder_copy <= _d_remainder_copy;
_q_resultsign <= _d_resultsign;
_q_bit <= _d_bit;
_q_quotient <= _d_quotient;
_q_remainder <= _d_remainder;
_q_active <= _d_active;
_q_index <= _d_index;
  end
end




always @* begin
_d_dividend_copy = _q_dividend_copy;
_d_divisor_copy = _q_divisor_copy;
_d_quotient_copy = _q_quotient_copy;
_d_remainder_copy = _q_remainder_copy;
_d_resultsign = _q_resultsign;
_d_bit = _q_bit;
_d_quotient = _q_quotient;
_d_remainder = _q_remainder;
_d_active = _q_active;
_d_index = _q_index;
// _always_pre
_d_index = 3;
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
  case (_q_active)
  0: begin
// __block_6_case
// __block_7
if (in_start) begin
// __block_8
// __block_10
if (in_divisor!=0) begin
// __block_11
// __block_13
_d_bit = 16;
_d_quotient_copy = 0;
_d_remainder_copy = 0;
_d_dividend_copy = in_dividend[15+:1]?-in_dividend:in_dividend;
_d_divisor_copy = in_divisor[15+:1]?-in_divisor:in_divisor;
_d_resultsign = in_dividend[15+:1]!=in_divisor[15+:1];
_d_active = 1;
// __block_14
end else begin
// __block_12
// __block_15
_d_resultsign = 0;
_d_quotient_copy = 16'hffff;
_d_remainder_copy = 16'hffff;
// __block_16
end
// __block_17
// __block_18
end else begin
// __block_9
end
// __block_19
// __block_20
  end
  1: begin
// __block_21_case
// __block_22
if ($unsigned({_q_remainder_copy[0+:15],_q_dividend_copy[_q_bit-1+:1]})>=$unsigned(_q_divisor_copy)) begin
// __block_23
// __block_25
_d_remainder_copy = {_q_remainder_copy[0+:15],_q_dividend_copy[_q_bit-1+:1]}-_q_divisor_copy;
_d_quotient_copy[_q_bit-1+:1] = 1;
// __block_26
end else begin
// __block_24
// __block_27
_d_remainder_copy = {_q_remainder_copy[0+:15],_q_dividend_copy[_q_bit-1+:1]};
// __block_28
end
// __block_29
_d_bit = _q_bit-1;
_d_active = (_d_bit!=0)?1:2;
// __block_30
  end
  2: begin
// __block_31_case
// __block_32
_d_quotient = _q_resultsign?-_q_quotient_copy:_q_quotient_copy;
_d_remainder = _q_remainder_copy;
_d_active = 0;
// __block_33
  end
endcase
// __block_5
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
3: begin // end of divmod16by16
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_multi16by16to32LONGMULT (
in_factor1,
in_factor2,
in_start,
out_product,
out_active,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [15:0] in_factor1;
input  [15:0] in_factor2;
input  [1:0] in_start;
output  [31:0] out_product;
output  [0:0] out_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [31:0] _d_factor1copy;
reg  [31:0] _q_factor1copy;
reg  [15:0] _d_factor2copy;
reg  [15:0] _q_factor2copy;
reg  [0:0] _d_productsign;
reg  [0:0] _q_productsign;
reg  [31:0] _d_product,_q_product;
reg  [0:0] _d_active,_q_active;
reg  [1:0] _d_index,_q_index;
assign out_product = _q_product;
assign out_active = _q_active;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_factor1copy <= _d_factor1copy;
_q_factor2copy <= _d_factor2copy;
_q_productsign <= _d_productsign;
_q_product <= _d_product;
_q_active <= _d_active;
_q_index <= _d_index;
  end
end




always @* begin
_d_factor1copy = _q_factor1copy;
_d_factor2copy = _q_factor2copy;
_d_productsign = _q_productsign;
_d_product = _q_product;
_d_active = _q_active;
_d_index = _q_index;
// _always_pre
_d_index = 3;
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
  case (_q_active)
  0: begin
// __block_6_case
// __block_7
  case (in_start)
  1: begin
// __block_9_case
// __block_10
_d_product = 0;
_d_factor1copy = {16'b0,in_factor1};
_d_factor2copy = in_factor2;
_d_productsign = 0;
_d_active = 1;
// __block_11
  end
  2: begin
// __block_12_case
// __block_13
_d_product = 0;
_d_factor1copy = in_factor1[15+:1]?{16'b0,-in_factor1}:{16'b0,in_factor1};
_d_factor2copy = in_factor2[15+:1]?-in_factor2:in_factor2;
_d_productsign = in_factor1[15+:1]!=in_factor2[15+:1];
_d_active = 1;
// __block_14
  end
endcase
// __block_8
// __block_15
  end
  1: begin
// __block_16_case
// __block_17
if (_q_factor2copy[0+:1]) begin
// __block_18
// __block_20
_d_product = (_q_productsign)?_q_product-_q_factor1copy:_q_product+_q_factor1copy;
// __block_21
end else begin
// __block_19
end
// __block_22
_d_factor1copy = _q_factor1copy<<1;
_d_factor2copy = _q_factor2copy>>1;
_d_active = (_d_factor2copy!=0)?1:0;
// __block_23
  end
endcase
// __block_5
// __block_24
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of multi16by16to32LONGMULT
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_multi16by16to32DSP (
in_factor1,
in_factor2,
in_start,
out_product,
out_active,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [15:0] in_factor1;
input  [15:0] in_factor2;
input  [1:0] in_start;
output  [31:0] out_product;
output  [1:0] out_active;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg  [15:0] _d_factor1copy;
reg  [15:0] _q_factor1copy;
reg  [15:0] _d_factor2copy;
reg  [15:0] _q_factor2copy;
reg  [15:0] _d_factor1high;
reg  [15:0] _q_factor1high;
reg  [15:0] _d_factor1low;
reg  [15:0] _q_factor1low;
reg  [15:0] _d_factor2high;
reg  [15:0] _q_factor2high;
reg  [15:0] _d_factor2low;
reg  [15:0] _q_factor2low;
reg  [31:0] _d_nosignproduct;
reg  [31:0] _q_nosignproduct;
reg  [0:0] _d_productsign;
reg  [0:0] _q_productsign;
reg  [31:0] _d_product,_q_product;
reg  [1:0] _d_active,_q_active;
reg  [1:0] _d_index,_q_index;
assign out_product = _q_product;
assign out_active = _q_active;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_factor1copy <= _d_factor1copy;
_q_factor2copy <= _d_factor2copy;
_q_factor1high <= _d_factor1high;
_q_factor1low <= _d_factor1low;
_q_factor2high <= _d_factor2high;
_q_factor2low <= _d_factor2low;
_q_nosignproduct <= _d_nosignproduct;
_q_productsign <= _d_productsign;
_q_product <= _d_product;
_q_active <= _d_active;
_q_index <= _d_index;
  end
end




always @* begin
_d_factor1copy = _q_factor1copy;
_d_factor2copy = _q_factor2copy;
_d_factor1high = _q_factor1high;
_d_factor1low = _q_factor1low;
_d_factor2high = _q_factor2high;
_d_factor2low = _q_factor2low;
_d_nosignproduct = _q_nosignproduct;
_d_productsign = _q_productsign;
_d_product = _q_product;
_d_active = _q_active;
_d_index = _q_index;
// _always_pre
_d_index = 3;
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
  case (_q_active)
  0: begin
// __block_6_case
// __block_7
  case (in_start)
  1: begin
// __block_9_case
// __block_10
_d_product = 0;
_d_factor1copy = in_factor1;
_d_factor2copy = in_factor2;
_d_productsign = 0;
_d_active = 1;
// __block_11
  end
  2: begin
// __block_12_case
// __block_13
_d_product = 0;
_d_factor1copy = in_factor1[15+:1]?-in_factor1:in_factor1;
_d_factor2copy = in_factor2[15+:1]?-in_factor2:in_factor2;
_d_productsign = in_factor1[15+:1]!=in_factor2[15+:1];
_d_active = 1;
// __block_14
  end
endcase
// __block_8
// __block_15
  end
  1: begin
// __block_16_case
// __block_17
_d_factor1high = {8'b0,_q_factor1copy[8+:8]};
_d_factor1low = {8'b0,_q_factor1copy[0+:8]};
_d_factor2high = {8'b0,_q_factor2copy[8+:8]};
_d_factor2low = {8'b0,_q_factor2copy[0+:8]};
_d_active = 2;
// __block_18
  end
  2: begin
// __block_19_case
// __block_20
_d_nosignproduct = {16'b0,_q_factor1low*_q_factor2low}+{8'b0,_q_factor1high*_q_factor2low,8'b0}+{8'b0,_q_factor1low*_q_factor2high,8'b0}+{_q_factor1high*_q_factor2high,16'b0};
_d_active = 3;
// __block_21
  end
  3: begin
// __block_22_case
// __block_23
_d_product = _q_productsign?-_q_nosignproduct:_q_nosignproduct;
_d_active = 0;
// __block_24
  end
endcase
// __block_5
// __block_25
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_3
_d_index = 3;
end
3: begin // end of multi16by16to32DSP
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_doubleaddsub2input (
in_operand1h,
in_operand1l,
in_operand2h,
in_operand2l,
out_total,
out_difference,
out_binaryxor,
out_binaryor,
out_binaryand,
out_maximum,
out_minimum,
out_equal,
out_lessthan,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [15:0] in_operand1h;
input  [15:0] in_operand1l;
input  [15:0] in_operand2h;
input  [15:0] in_operand2l;
output  [31:0] out_total;
output  [31:0] out_difference;
output  [31:0] out_binaryxor;
output  [31:0] out_binaryor;
output  [31:0] out_binaryand;
output  [31:0] out_maximum;
output  [31:0] out_minimum;
output  [15:0] out_equal;
output  [15:0] out_lessthan;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [31:0] _w_operand1;
wire  [31:0] _w_operand2;

reg  [31:0] _d_total,_q_total;
reg  [31:0] _d_difference,_q_difference;
reg  [31:0] _d_binaryxor,_q_binaryxor;
reg  [31:0] _d_binaryor,_q_binaryor;
reg  [31:0] _d_binaryand,_q_binaryand;
reg  [31:0] _d_maximum,_q_maximum;
reg  [31:0] _d_minimum,_q_minimum;
reg  [15:0] _d_equal,_q_equal;
reg  [15:0] _d_lessthan,_q_lessthan;
reg  [1:0] _d_index,_q_index;
assign out_total = _q_total;
assign out_difference = _q_difference;
assign out_binaryxor = _q_binaryxor;
assign out_binaryor = _q_binaryor;
assign out_binaryand = _q_binaryand;
assign out_maximum = _q_maximum;
assign out_minimum = _q_minimum;
assign out_equal = _q_equal;
assign out_lessthan = _q_lessthan;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_total <= _d_total;
_q_difference <= _d_difference;
_q_binaryxor <= _d_binaryxor;
_q_binaryor <= _d_binaryor;
_q_binaryand <= _d_binaryand;
_q_maximum <= _d_maximum;
_q_minimum <= _d_minimum;
_q_equal <= _d_equal;
_q_lessthan <= _d_lessthan;
_q_index <= _d_index;
  end
end



assign _w_operand2 = {in_operand2h,in_operand2l};
assign _w_operand1 = {in_operand1h,in_operand1l};

always @* begin
_d_total = _q_total;
_d_difference = _q_difference;
_d_binaryxor = _q_binaryxor;
_d_binaryor = _q_binaryor;
_d_binaryand = _q_binaryand;
_d_maximum = _q_maximum;
_d_minimum = _q_minimum;
_d_equal = _q_equal;
_d_lessthan = _q_lessthan;
_d_index = _q_index;
// _always_pre
_d_total = _w_operand1+_w_operand2;
_d_difference = _w_operand1-_w_operand2;
_d_binaryxor = _w_operand1^_w_operand2;
_d_binaryor = _w_operand1|_w_operand2;
_d_binaryand = _w_operand1&_w_operand2;
_d_maximum = (_w_operand1>_w_operand2)?_w_operand1:_w_operand2;
_d_minimum = (_w_operand1<_w_operand2)?_w_operand1:_w_operand2;
_d_equal = {16{(_w_operand1==_w_operand2)}};
_d_lessthan = {16{(_w_operand1<_w_operand2)}};
_d_index = 3;
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
3: begin // end of doubleaddsub2input
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_doubleaddsub1input (
in_operand1h,
in_operand1l,
out_increment,
out_decrement,
out_times2,
out_divide2,
out_negation,
out_binaryinvert,
out_absolute,
out_zeroequal,
out_zeroless,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [15:0] in_operand1h;
input  [15:0] in_operand1l;
output  [31:0] out_increment;
output  [31:0] out_decrement;
output  [31:0] out_times2;
output  [31:0] out_divide2;
output  [31:0] out_negation;
output  [31:0] out_binaryinvert;
output  [31:0] out_absolute;
output  [15:0] out_zeroequal;
output  [15:0] out_zeroless;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [31:0] _w_operand1;

reg  [31:0] _d_increment,_q_increment;
reg  [31:0] _d_decrement,_q_decrement;
reg  [31:0] _d_times2,_q_times2;
reg  [31:0] _d_divide2,_q_divide2;
reg  [31:0] _d_negation,_q_negation;
reg  [31:0] _d_binaryinvert,_q_binaryinvert;
reg  [31:0] _d_absolute,_q_absolute;
reg  [15:0] _d_zeroequal,_q_zeroequal;
reg  [15:0] _d_zeroless,_q_zeroless;
reg  [1:0] _d_index,_q_index;
assign out_increment = _q_increment;
assign out_decrement = _q_decrement;
assign out_times2 = _q_times2;
assign out_divide2 = _q_divide2;
assign out_negation = _q_negation;
assign out_binaryinvert = _q_binaryinvert;
assign out_absolute = _q_absolute;
assign out_zeroequal = _q_zeroequal;
assign out_zeroless = _q_zeroless;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_increment <= _d_increment;
_q_decrement <= _d_decrement;
_q_times2 <= _d_times2;
_q_divide2 <= _d_divide2;
_q_negation <= _d_negation;
_q_binaryinvert <= _d_binaryinvert;
_q_absolute <= _d_absolute;
_q_zeroequal <= _d_zeroequal;
_q_zeroless <= _d_zeroless;
_q_index <= _d_index;
  end
end



assign _w_operand1 = {in_operand1h,in_operand1l};

always @* begin
_d_increment = _q_increment;
_d_decrement = _q_decrement;
_d_times2 = _q_times2;
_d_divide2 = _q_divide2;
_d_negation = _q_negation;
_d_binaryinvert = _q_binaryinvert;
_d_absolute = _q_absolute;
_d_zeroequal = _q_zeroequal;
_d_zeroless = _q_zeroless;
_d_index = _q_index;
// _always_pre
_d_increment = _w_operand1+1;
_d_decrement = _w_operand1-1;
_d_times2 = _w_operand1<<1;
_d_divide2 = {_w_operand1[31+:1],_w_operand1[1+:31]};
_d_negation = -_w_operand1;
_d_binaryinvert = ~_w_operand1;
_d_absolute = (_w_operand1[31+:1])?-_w_operand1:_w_operand1;
_d_zeroequal = {16{(_w_operand1==0)}};
_d_zeroless = {16{(_w_operand1<0)}};
_d_index = 3;
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
3: begin // end of doubleaddsub1input
end
default: begin 
_d_index = 3;
 end
endcase
end
endmodule


module M_memmap_io_mem_uartInBuffer(
input      [0:0]             in_uartInBuffer_wenable0,
input       [7:0]     in_uartInBuffer_wdata0,
input      [11:0]                in_uartInBuffer_addr0,
input      [0:0]             in_uartInBuffer_wenable1,
input      [7:0]                 in_uartInBuffer_wdata1,
input      [11:0]                in_uartInBuffer_addr1,
output reg  [7:0]     out_uartInBuffer_rdata0,
output reg  [7:0]     out_uartInBuffer_rdata1,
input      clock0,
input      clock1
);
reg  [7:0] buffer[4095:0];
always @(posedge clock0) begin
  if (in_uartInBuffer_wenable0) begin
    buffer[in_uartInBuffer_addr0] <= in_uartInBuffer_wdata0;
  end else begin
    out_uartInBuffer_rdata0 <= buffer[in_uartInBuffer_addr0];
  end
end
always @(posedge clock1) begin
  if (in_uartInBuffer_wenable1) begin
    buffer[in_uartInBuffer_addr1] <= in_uartInBuffer_wdata1;
  end else begin
    out_uartInBuffer_rdata1 <= buffer[in_uartInBuffer_addr1];
  end
end

endmodule

module M_memmap_io_mem_uartOutBuffer(
input      [0:0]             in_uartOutBuffer_wenable0,
input       [7:0]     in_uartOutBuffer_wdata0,
input      [7:0]                in_uartOutBuffer_addr0,
input      [0:0]             in_uartOutBuffer_wenable1,
input      [7:0]                 in_uartOutBuffer_wdata1,
input      [7:0]                in_uartOutBuffer_addr1,
output reg  [7:0]     out_uartOutBuffer_rdata0,
output reg  [7:0]     out_uartOutBuffer_rdata1,
input      clock0,
input      clock1
);
reg  [7:0] buffer[255:0];
always @(posedge clock0) begin
  if (in_uartOutBuffer_wenable0) begin
    buffer[in_uartOutBuffer_addr0] <= in_uartOutBuffer_wdata0;
  end else begin
    out_uartOutBuffer_rdata0 <= buffer[in_uartOutBuffer_addr0];
  end
end
always @(posedge clock1) begin
  if (in_uartOutBuffer_wenable1) begin
    buffer[in_uartOutBuffer_addr1] <= in_uartOutBuffer_wdata1;
  end else begin
    out_uartOutBuffer_rdata1 <= buffer[in_uartOutBuffer_addr1];
  end
end

endmodule

module M_memmap_io (
in_btns,
in_uart_rx,
in_vblank,
in_pix_active,
in_pix_x,
in_pix_y,
in_clock_50mhz,
in_video_clock,
in_video_reset,
in_memoryAddress,
in_writeData,
in_memoryWrite,
in_memoryRead,
in_resetCoPro,
out_leds,
out_uart_tx,
out_audio_l,
out_audio_r,
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
input  [0:0] in_vblank;
input  [0:0] in_pix_active;
input  [9:0] in_pix_x;
input  [9:0] in_pix_y;
input  [0:0] in_clock_50mhz;
input  [0:0] in_video_clock;
input  [0:0] in_video_reset;
input  [15:0] in_memoryAddress;
input  [15:0] in_writeData;
input  [0:0] in_memoryWrite;
input  [0:0] in_memoryRead;
input  [0:0] in_resetCoPro;
output  [7:0] out_leds;
output  [0:0] out_uart_tx;
output  [3:0] out_audio_l;
output  [3:0] out_audio_r;
output  [7:0] out_video_r;
output  [7:0] out_video_g;
output  [7:0] out_video_b;
output  [15:0] out_readData;
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
wire  [4:0] _w_tile_map_tm_lastaction;
wire  [5:0] _w_tile_map_tm_active;
wire _w_tile_map_done;
wire  [1:0] _w_bitmap_window_pix_red;
wire  [1:0] _w_bitmap_window_pix_green;
wire  [1:0] _w_bitmap_window_pix_blue;
wire  [0:0] _w_bitmap_window_bitmap_display;
wire  [6:0] _w_bitmap_window_bitmap_colour_read;
wire _w_bitmap_window_done;
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
wire  [2:0] _w_character_map_window_tpu_active;
wire _w_character_map_window_done;
wire  [1:0] _w_terminal_window_pix_red;
wire  [1:0] _w_terminal_window_pix_green;
wire  [1:0] _w_terminal_window_pix_blue;
wire  [0:0] _w_terminal_window_terminal_display;
wire  [2:0] _w_terminal_window_terminal_active;
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
wire  [5:0] _w_gpu_processor_gpu_active;
wire _w_gpu_processor_done;
wire  [2:0] _w_vector_drawer_vector_block_active;
wire signed [10:0] _w_vector_drawer_gpu_x;
wire signed [10:0] _w_vector_drawer_gpu_y;
wire  [6:0] _w_vector_drawer_gpu_colour;
wire signed [10:0] _w_vector_drawer_gpu_param0;
wire signed [10:0] _w_vector_drawer_gpu_param1;
wire  [3:0] _w_vector_drawer_gpu_write;
wire _w_vector_drawer_done;
wire  [3:0] _w_displaylist_drawer_display_list_active;
wire  [0:0] _w_displaylist_drawer_read_active;
wire  [3:0] _w_displaylist_drawer_read_command;
wire  [6:0] _w_displaylist_drawer_read_colour;
wire  [10:0] _w_displaylist_drawer_read_x;
wire  [10:0] _w_displaylist_drawer_read_y;
wire  [10:0] _w_displaylist_drawer_read_p0;
wire  [10:0] _w_displaylist_drawer_read_p1;
wire  [10:0] _w_displaylist_drawer_read_p2;
wire  [10:0] _w_displaylist_drawer_read_p3;
wire signed [10:0] _w_displaylist_drawer_gpu_x;
wire signed [10:0] _w_displaylist_drawer_gpu_y;
wire  [6:0] _w_displaylist_drawer_gpu_colour;
wire signed [10:0] _w_displaylist_drawer_gpu_param0;
wire signed [10:0] _w_displaylist_drawer_gpu_param1;
wire signed [10:0] _w_displaylist_drawer_gpu_param2;
wire signed [10:0] _w_displaylist_drawer_gpu_param3;
wire  [3:0] _w_displaylist_drawer_gpu_write;
wire  [4:0] _w_displaylist_drawer_vector_block_number;
wire  [6:0] _w_displaylist_drawer_vector_block_colour;
wire signed [10:0] _w_displaylist_drawer_vector_block_xc;
wire signed [10:0] _w_displaylist_drawer_vector_block_yc;
wire  [0:0] _w_displaylist_drawer_draw_vector;
wire _w_displaylist_drawer_done;
wire  [7:0] _w_mem_uartInBuffer_rdata0;
wire  [7:0] _w_mem_uartInBuffer_rdata1;
wire  [7:0] _w_mem_uartOutBuffer_rdata0;
wire  [7:0] _w_mem_uartOutBuffer_rdata1;
wire  [7:0] _c_uartInBuffer_wdata0;
assign _c_uartInBuffer_wdata0 = 0;
wire  [7:0] _c_uartOutBuffer_wdata0;
assign _c_uartOutBuffer_wdata0 = 0;
reg  [6:0] _t_reg_btns;

reg  [7:0] _d_uo_data_in;
reg  [7:0] _q_uo_data_in;
reg  [0:0] _d_uo_data_in_ready;
reg  [0:0] _q_uo_data_in_ready;
reg  [0:0] _d_uartInBuffer_wenable0;
reg  [0:0] _q_uartInBuffer_wenable0;
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
reg  [0:0] _d_uartOutBuffer_wenable0;
reg  [0:0] _q_uartOutBuffer_wenable0;
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
reg  [1:0] _d_coProReset;
reg  [1:0] _q_coProReset;
reg  [6:0] _d_delayed_4532_4;
reg  [6:0] _q_delayed_4532_4;
reg  [7:0] _d_leds,_q_leds;
reg  [15:0] _d_readData,_q_readData;
reg  [0:0] _d_p1hz_resetCounter,_q_p1hz_resetCounter;
reg  [0:0] _d_timer1hz_resetCounter,_q_timer1hz_resetCounter;
reg  [15:0] _d_sleepTimer_resetCount,_q_sleepTimer_resetCount;
reg  [0:0] _d_sleepTimer_resetCounter,_q_sleepTimer_resetCounter;
reg  [15:0] _d_timer1khz_resetCount,_q_timer1khz_resetCount;
reg  [0:0] _d_timer1khz_resetCounter,_q_timer1khz_resetCounter;
reg  [0:0] _d_rng_resetRandom,_q_rng_resetRandom;
reg  [5:0] _d_background_generator_backgroundcolour,_q_background_generator_backgroundcolour;
reg  [5:0] _d_background_generator_backgroundcolour_alt,_q_background_generator_backgroundcolour_alt;
reg  [2:0] _d_background_generator_backgroundcolour_mode,_q_background_generator_backgroundcolour_mode;
reg  [2:0] _d_background_generator_background_write,_q_background_generator_background_write;
reg  [5:0] _d_tile_map_tm_x,_q_tile_map_tm_x;
reg  [5:0] _d_tile_map_tm_y,_q_tile_map_tm_y;
reg  [4:0] _d_tile_map_tm_character,_q_tile_map_tm_character;
reg  [5:0] _d_tile_map_tm_foreground,_q_tile_map_tm_foreground;
reg  [6:0] _d_tile_map_tm_background,_q_tile_map_tm_background;
reg  [0:0] _d_tile_map_tm_write,_q_tile_map_tm_write;
reg  [4:0] _d_tile_map_tile_writer_tile,_q_tile_map_tile_writer_tile;
reg  [3:0] _d_tile_map_tile_writer_line,_q_tile_map_tile_writer_line;
reg  [15:0] _d_tile_map_tile_writer_bitmap,_q_tile_map_tile_writer_bitmap;
reg  [0:0] _d_tile_map_tile_writer_write,_q_tile_map_tile_writer_write;
reg  [4:0] _d_tile_map_tm_scrollwrap,_q_tile_map_tm_scrollwrap;
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
reg  [2:0] _d_apu_processor_L_waveform,_q_apu_processor_L_waveform;
reg  [5:0] _d_apu_processor_L_note,_q_apu_processor_L_note;
reg  [15:0] _d_apu_processor_L_duration,_q_apu_processor_L_duration;
reg  [1:0] _d_apu_processor_L_apu_write,_q_apu_processor_L_apu_write;
reg  [2:0] _d_apu_processor_R_waveform,_q_apu_processor_R_waveform;
reg  [5:0] _d_apu_processor_R_note,_q_apu_processor_R_note;
reg  [15:0] _d_apu_processor_R_duration,_q_apu_processor_R_duration;
reg  [1:0] _d_apu_processor_R_apu_write,_q_apu_processor_R_apu_write;
reg signed [10:0] _d_gpu_processor_gpu_x,_q_gpu_processor_gpu_x;
reg signed [10:0] _d_gpu_processor_gpu_y,_q_gpu_processor_gpu_y;
reg  [7:0] _d_gpu_processor_gpu_colour,_q_gpu_processor_gpu_colour;
reg signed [15:0] _d_gpu_processor_gpu_param0,_q_gpu_processor_gpu_param0;
reg signed [15:0] _d_gpu_processor_gpu_param1,_q_gpu_processor_gpu_param1;
reg signed [15:0] _d_gpu_processor_gpu_param2,_q_gpu_processor_gpu_param2;
reg signed [15:0] _d_gpu_processor_gpu_param3,_q_gpu_processor_gpu_param3;
reg  [3:0] _d_gpu_processor_gpu_write,_q_gpu_processor_gpu_write;
reg signed [10:0] _d_gpu_processor_v_gpu_param2,_q_gpu_processor_v_gpu_param2;
reg signed [10:0] _d_gpu_processor_v_gpu_param3,_q_gpu_processor_v_gpu_param3;
reg  [3:0] _d_gpu_processor_blit1_writer_tile,_q_gpu_processor_blit1_writer_tile;
reg  [3:0] _d_gpu_processor_blit1_writer_line,_q_gpu_processor_blit1_writer_line;
reg  [15:0] _d_gpu_processor_blit1_writer_bitmap,_q_gpu_processor_blit1_writer_bitmap;
reg  [0:0] _d_gpu_processor_blit1_writer_active,_q_gpu_processor_blit1_writer_active;
reg  [3:0] _d_vector_drawer_vector_block_number,_q_vector_drawer_vector_block_number;
reg  [6:0] _d_vector_drawer_vector_block_colour,_q_vector_drawer_vector_block_colour;
reg signed [10:0] _d_vector_drawer_vector_block_xc,_q_vector_drawer_vector_block_xc;
reg signed [10:0] _d_vector_drawer_vector_block_yc,_q_vector_drawer_vector_block_yc;
reg  [0:0] _d_vector_drawer_draw_vector,_q_vector_drawer_draw_vector;
reg  [3:0] _d_vector_drawer_vertices_writer_block,_q_vector_drawer_vertices_writer_block;
reg  [5:0] _d_vector_drawer_vertices_writer_vertex,_q_vector_drawer_vertices_writer_vertex;
reg signed [5:0] _d_vector_drawer_vertices_writer_xdelta,_q_vector_drawer_vertices_writer_xdelta;
reg signed [5:0] _d_vector_drawer_vertices_writer_ydelta,_q_vector_drawer_vertices_writer_ydelta;
reg  [0:0] _d_vector_drawer_vertices_writer_active,_q_vector_drawer_vertices_writer_active;
reg  [0:0] _d_vector_drawer_vertices_writer_write,_q_vector_drawer_vertices_writer_write;
reg  [4:0] _d_displaylist_drawer_start_entry,_q_displaylist_drawer_start_entry;
reg  [4:0] _d_displaylist_drawer_finish_entry,_q_displaylist_drawer_finish_entry;
reg  [0:0] _d_displaylist_drawer_start_displaylist,_q_displaylist_drawer_start_displaylist;
reg  [4:0] _d_displaylist_drawer_writer_entry_number,_q_displaylist_drawer_writer_entry_number;
reg  [0:0] _d_displaylist_drawer_writer_active,_q_displaylist_drawer_writer_active;
reg  [3:0] _d_displaylist_drawer_writer_command,_q_displaylist_drawer_writer_command;
reg  [6:0] _d_displaylist_drawer_writer_colour,_q_displaylist_drawer_writer_colour;
reg  [10:0] _d_displaylist_drawer_writer_x,_q_displaylist_drawer_writer_x;
reg  [10:0] _d_displaylist_drawer_writer_y,_q_displaylist_drawer_writer_y;
reg  [10:0] _d_displaylist_drawer_writer_p0,_q_displaylist_drawer_writer_p0;
reg  [10:0] _d_displaylist_drawer_writer_p1,_q_displaylist_drawer_writer_p1;
reg  [10:0] _d_displaylist_drawer_writer_p2,_q_displaylist_drawer_writer_p2;
reg  [10:0] _d_displaylist_drawer_writer_p3,_q_displaylist_drawer_writer_p3;
reg  [3:0] _d_displaylist_drawer_writer_write,_q_displaylist_drawer_writer_write;
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
reg  _lower_sprites_run;
reg  _upper_sprites_run;
reg  _character_map_window_run;
reg  _terminal_window_run;
reg  _display_run;
reg  _apu_processor_L_run;
reg  _apu_processor_R_run;
reg  _gpu_processor_run;
reg  _vector_drawer_run;
reg  _displaylist_drawer_run;
assign out_leds = _q_leds;
assign out_uart_tx = _w_usend_uart_tx;
assign out_audio_l = _w_apu_processor_L_audio_output;
assign out_audio_r = _w_apu_processor_R_audio_output;
assign out_video_r = _w_display_pix_red;
assign out_video_g = _w_display_pix_green;
assign out_video_b = _w_display_pix_blue;
assign out_readData = _d_readData;
assign out_done = (_q_index == 3);

always @(posedge clock) begin
  if (reset || !in_run) begin
_q_uo_data_in <= 0;
_q_uo_data_in_ready <= 0;
_q_uartInBuffer_wenable0 <= 0;
_q_uartInBuffer_addr0 <= 0;
_q_uartInBuffer_wenable1 <= 0;
_q_uartInBuffer_wdata1 <= 0;
_q_uartInBuffer_addr1 <= 0;
_q_uartInBufferNext <= 0;
_q_uartInBufferTop <= 0;
_q_uartOutBuffer_wenable0 <= 0;
_q_uartOutBuffer_addr0 <= 0;
_q_uartOutBuffer_wenable1 <= 0;
_q_uartOutBuffer_wdata1 <= 0;
_q_uartOutBuffer_addr1 <= 0;
_q_uartOutBufferNext <= 0;
_q_uartOutBufferTop <= 0;
_q_newuartOutBufferTop <= 0;
_q_coProReset <= 0;
_q_delayed_4532_4 <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_uo_data_in <= _d_uo_data_in;
_q_uo_data_in_ready <= _d_uo_data_in_ready;
_q_uartInBuffer_wenable0 <= _d_uartInBuffer_wenable0;
_q_uartInBuffer_addr0 <= _d_uartInBuffer_addr0;
_q_uartInBuffer_wenable1 <= _d_uartInBuffer_wenable1;
_q_uartInBuffer_wdata1 <= _d_uartInBuffer_wdata1;
_q_uartInBuffer_addr1 <= _d_uartInBuffer_addr1;
_q_uartInBufferNext <= _d_uartInBufferNext;
_q_uartInBufferTop <= _d_uartInBufferTop;
_q_uartOutBuffer_wenable0 <= _d_uartOutBuffer_wenable0;
_q_uartOutBuffer_addr0 <= _d_uartOutBuffer_addr0;
_q_uartOutBuffer_wenable1 <= _d_uartOutBuffer_wenable1;
_q_uartOutBuffer_wdata1 <= _d_uartOutBuffer_wdata1;
_q_uartOutBuffer_addr1 <= _d_uartOutBuffer_addr1;
_q_uartOutBufferNext <= _d_uartOutBufferNext;
_q_uartOutBufferTop <= _d_uartOutBufferTop;
_q_newuartOutBufferTop <= _d_newuartOutBufferTop;
_q_coProReset <= _d_coProReset;
_q_delayed_4532_4 <= _d_delayed_4532_4;
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
_q_background_generator_background_write <= _d_background_generator_background_write;
_q_tile_map_tm_x <= _d_tile_map_tm_x;
_q_tile_map_tm_y <= _d_tile_map_tm_y;
_q_tile_map_tm_character <= _d_tile_map_tm_character;
_q_tile_map_tm_foreground <= _d_tile_map_tm_foreground;
_q_tile_map_tm_background <= _d_tile_map_tm_background;
_q_tile_map_tm_write <= _d_tile_map_tm_write;
_q_tile_map_tile_writer_tile <= _d_tile_map_tile_writer_tile;
_q_tile_map_tile_writer_line <= _d_tile_map_tile_writer_line;
_q_tile_map_tile_writer_bitmap <= _d_tile_map_tile_writer_bitmap;
_q_tile_map_tile_writer_write <= _d_tile_map_tile_writer_write;
_q_tile_map_tm_scrollwrap <= _d_tile_map_tm_scrollwrap;
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
_q_gpu_processor_v_gpu_param2 <= _d_gpu_processor_v_gpu_param2;
_q_gpu_processor_v_gpu_param3 <= _d_gpu_processor_v_gpu_param3;
_q_gpu_processor_blit1_writer_tile <= _d_gpu_processor_blit1_writer_tile;
_q_gpu_processor_blit1_writer_line <= _d_gpu_processor_blit1_writer_line;
_q_gpu_processor_blit1_writer_bitmap <= _d_gpu_processor_blit1_writer_bitmap;
_q_gpu_processor_blit1_writer_active <= _d_gpu_processor_blit1_writer_active;
_q_vector_drawer_vector_block_number <= _d_vector_drawer_vector_block_number;
_q_vector_drawer_vector_block_colour <= _d_vector_drawer_vector_block_colour;
_q_vector_drawer_vector_block_xc <= _d_vector_drawer_vector_block_xc;
_q_vector_drawer_vector_block_yc <= _d_vector_drawer_vector_block_yc;
_q_vector_drawer_draw_vector <= _d_vector_drawer_draw_vector;
_q_vector_drawer_vertices_writer_block <= _d_vector_drawer_vertices_writer_block;
_q_vector_drawer_vertices_writer_vertex <= _d_vector_drawer_vertices_writer_vertex;
_q_vector_drawer_vertices_writer_xdelta <= _d_vector_drawer_vertices_writer_xdelta;
_q_vector_drawer_vertices_writer_ydelta <= _d_vector_drawer_vertices_writer_ydelta;
_q_vector_drawer_vertices_writer_active <= _d_vector_drawer_vertices_writer_active;
_q_vector_drawer_vertices_writer_write <= _d_vector_drawer_vertices_writer_write;
_q_displaylist_drawer_start_entry <= _d_displaylist_drawer_start_entry;
_q_displaylist_drawer_finish_entry <= _d_displaylist_drawer_finish_entry;
_q_displaylist_drawer_start_displaylist <= _d_displaylist_drawer_start_displaylist;
_q_displaylist_drawer_writer_entry_number <= _d_displaylist_drawer_writer_entry_number;
_q_displaylist_drawer_writer_active <= _d_displaylist_drawer_writer_active;
_q_displaylist_drawer_writer_command <= _d_displaylist_drawer_writer_command;
_q_displaylist_drawer_writer_colour <= _d_displaylist_drawer_writer_colour;
_q_displaylist_drawer_writer_x <= _d_displaylist_drawer_writer_x;
_q_displaylist_drawer_writer_y <= _d_displaylist_drawer_writer_y;
_q_displaylist_drawer_writer_p0 <= _d_displaylist_drawer_writer_p0;
_q_displaylist_drawer_writer_p1 <= _d_displaylist_drawer_writer_p1;
_q_displaylist_drawer_writer_p2 <= _d_displaylist_drawer_writer_p2;
_q_displaylist_drawer_writer_p3 <= _d_displaylist_drawer_writer_p3;
_q_displaylist_drawer_writer_write <= _d_displaylist_drawer_writer_write;
end

M_pulse1hz p1hz (
.in_resetCounter(_d_p1hz_resetCounter),
.out_counter1hz(_w_p1hz_counter1hz),
.out_done(_w_p1hz_done),
.in_run(_p1hz_run),
.reset(reset),
.clock(in_clock_50mhz)
);
M_pulse1hz timer1hz (
.in_resetCounter(_d_timer1hz_resetCounter),
.out_counter1hz(_w_timer1hz_counter1hz),
.out_done(_w_timer1hz_done),
.in_run(_timer1hz_run),
.reset(reset),
.clock(in_clock_50mhz)
);
M_pulse1khz sleepTimer (
.in_resetCount(_d_sleepTimer_resetCount),
.in_resetCounter(_d_sleepTimer_resetCounter),
.out_counter1khz(_w_sleepTimer_counter1khz),
.out_done(_w_sleepTimer_done),
.in_run(_sleepTimer_run),
.reset(reset),
.clock(in_clock_50mhz)
);
M_pulse1khz timer1khz (
.in_resetCount(_d_timer1khz_resetCount),
.in_resetCounter(_d_timer1khz_resetCounter),
.out_counter1khz(_w_timer1khz_counter1khz),
.out_done(_w_timer1khz_done),
.in_run(_timer1khz_run),
.reset(reset),
.clock(in_clock_50mhz)
);
M_random rng (
.in_resetRandom(_d_rng_resetRandom),
.out_g_noise_out(_w_rng_g_noise_out),
.out_done(_w_rng_done),
.in_run(_rng_run),
.reset(reset),
.clock(in_clock_50mhz)
);
M_uart_sender #(
.IO_DATA_IN_WIDTH(8),
.IO_DATA_IN_INIT(0),
.IO_DATA_IN_READY_WIDTH(1),
.IO_DATA_IN_READY_INIT(0),
.IO_BUSY_WIDTH(1),
.IO_BUSY_INIT(0)
) usend (
.in_io_data_in(_d_uo_data_in),
.in_io_data_in_ready(_d_uo_data_in_ready),
.out_io_busy(_w_usend_io_busy),
.out_uart_tx(_w_usend_uart_tx),
.out_done(_w_usend_done),
.in_run(_usend_run),
.reset(reset),
.clock(in_clock_50mhz)
);
M_uart_receiver #(
.IO_DATA_OUT_WIDTH(8),
.IO_DATA_OUT_INIT(0),
.IO_DATA_OUT_READY_WIDTH(1),
.IO_DATA_OUT_READY_INIT(0)
) urecv (
.in_uart_rx(in_uart_rx),
.out_io_data_out(_w_urecv_io_data_out),
.out_io_data_out_ready(_w_urecv_io_data_out_ready),
.reset(reset),
.clock(in_clock_50mhz)
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
.in_background_write(_d_background_generator_background_write),
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
.in_tile_writer_write(_d_tile_map_tile_writer_write),
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
M_bitmap bitmap_window (
.in_pix_x(in_pix_x),
.in_pix_y(in_pix_y),
.in_pix_active(in_pix_active),
.in_pix_vblank(in_vblank),
.in_bitmap_x_write(_w_gpu_processor_bitmap_x_write),
.in_bitmap_y_write(_w_gpu_processor_bitmap_y_write),
.in_bitmap_colour_write(_w_gpu_processor_bitmap_colour_write),
.in_bitmap_write(_w_gpu_processor_bitmap_write),
.in_bitmap_x_read(_d_bitmap_window_bitmap_x_read),
.in_bitmap_y_read(_d_bitmap_window_bitmap_y_read),
.out_pix_red(_w_bitmap_window_pix_red),
.out_pix_green(_w_bitmap_window_pix_green),
.out_pix_blue(_w_bitmap_window_pix_blue),
.out_bitmap_display(_w_bitmap_window_bitmap_display),
.out_bitmap_colour_read(_w_bitmap_window_bitmap_colour_read),
.out_done(_w_bitmap_window_done),
.in_run(_bitmap_window_run),
.reset(in_video_reset),
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
.reset(in_video_reset),
.clock(in_video_clock)
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
.reset(in_video_reset),
.clock(in_video_clock)
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
.in_v_gpu_x(_w_vector_drawer_gpu_x),
.in_v_gpu_y(_w_vector_drawer_gpu_y),
.in_v_gpu_colour(_w_vector_drawer_gpu_colour),
.in_v_gpu_param0(_w_vector_drawer_gpu_param0),
.in_v_gpu_param1(_w_vector_drawer_gpu_param1),
.in_v_gpu_param2(_d_gpu_processor_v_gpu_param2),
.in_v_gpu_param3(_d_gpu_processor_v_gpu_param3),
.in_v_gpu_write(_w_vector_drawer_gpu_write),
.in_dl_gpu_x(_w_displaylist_drawer_gpu_x),
.in_dl_gpu_y(_w_displaylist_drawer_gpu_y),
.in_dl_gpu_colour(_w_displaylist_drawer_gpu_colour),
.in_dl_gpu_param0(_w_displaylist_drawer_gpu_param0),
.in_dl_gpu_param1(_w_displaylist_drawer_gpu_param2),
.in_dl_gpu_param2(_w_displaylist_drawer_gpu_param3),
.in_dl_gpu_param3(_w_displaylist_drawer_gpu_param1),
.in_dl_gpu_write(_w_displaylist_drawer_gpu_write),
.in_blit1_writer_tile(_d_gpu_processor_blit1_writer_tile),
.in_blit1_writer_line(_d_gpu_processor_blit1_writer_line),
.in_blit1_writer_bitmap(_d_gpu_processor_blit1_writer_bitmap),
.in_blit1_writer_active(_d_gpu_processor_blit1_writer_active),
.out_bitmap_x_write(_w_gpu_processor_bitmap_x_write),
.out_bitmap_y_write(_w_gpu_processor_bitmap_y_write),
.out_bitmap_colour_write(_w_gpu_processor_bitmap_colour_write),
.out_bitmap_write(_w_gpu_processor_bitmap_write),
.out_gpu_active(_w_gpu_processor_gpu_active),
.out_done(_w_gpu_processor_done),
.in_run(_gpu_processor_run),
.reset(in_video_reset),
.clock(in_video_clock)
);
M_vectors vector_drawer (
.in_vector_block_number(_d_vector_drawer_vector_block_number),
.in_vector_block_colour(_d_vector_drawer_vector_block_colour),
.in_vector_block_xc(_d_vector_drawer_vector_block_xc),
.in_vector_block_yc(_d_vector_drawer_vector_block_yc),
.in_draw_vector(_d_vector_drawer_draw_vector),
.in_vertices_writer_block(_d_vector_drawer_vertices_writer_block),
.in_vertices_writer_vertex(_d_vector_drawer_vertices_writer_vertex),
.in_vertices_writer_xdelta(_d_vector_drawer_vertices_writer_xdelta),
.in_vertices_writer_ydelta(_d_vector_drawer_vertices_writer_ydelta),
.in_vertices_writer_active(_d_vector_drawer_vertices_writer_active),
.in_vertices_writer_write(_d_vector_drawer_vertices_writer_write),
.in_dl_vector_block_number(_w_displaylist_drawer_vector_block_number),
.in_dl_vector_block_colour(_w_displaylist_drawer_vector_block_colour),
.in_dl_vector_block_xc(_w_displaylist_drawer_vector_block_xc),
.in_dl_vector_block_yc(_w_displaylist_drawer_vector_block_yc),
.in_dl_draw_vector(_w_displaylist_drawer_draw_vector),
.in_gpu_active(_w_gpu_processor_gpu_active),
.out_vector_block_active(_w_vector_drawer_vector_block_active),
.out_gpu_x(_w_vector_drawer_gpu_x),
.out_gpu_y(_w_vector_drawer_gpu_y),
.out_gpu_colour(_w_vector_drawer_gpu_colour),
.out_gpu_param0(_w_vector_drawer_gpu_param0),
.out_gpu_param1(_w_vector_drawer_gpu_param1),
.out_gpu_write(_w_vector_drawer_gpu_write),
.out_done(_w_vector_drawer_done),
.in_run(_vector_drawer_run),
.reset(in_video_reset),
.clock(in_video_clock)
);
M_displaylist displaylist_drawer (
.in_start_entry(_d_displaylist_drawer_start_entry),
.in_finish_entry(_d_displaylist_drawer_finish_entry),
.in_start_displaylist(_d_displaylist_drawer_start_displaylist),
.in_writer_entry_number(_d_displaylist_drawer_writer_entry_number),
.in_writer_active(_d_displaylist_drawer_writer_active),
.in_writer_command(_d_displaylist_drawer_writer_command),
.in_writer_colour(_d_displaylist_drawer_writer_colour),
.in_writer_x(_d_displaylist_drawer_writer_x),
.in_writer_y(_d_displaylist_drawer_writer_y),
.in_writer_p0(_d_displaylist_drawer_writer_p0),
.in_writer_p1(_d_displaylist_drawer_writer_p1),
.in_writer_p2(_d_displaylist_drawer_writer_p2),
.in_writer_p3(_d_displaylist_drawer_writer_p3),
.in_writer_write(_d_displaylist_drawer_writer_write),
.in_gpu_active(_w_gpu_processor_gpu_active),
.in_vector_block_active(_w_vector_drawer_vector_block_active),
.out_display_list_active(_w_displaylist_drawer_display_list_active),
.out_read_active(_w_displaylist_drawer_read_active),
.out_read_command(_w_displaylist_drawer_read_command),
.out_read_colour(_w_displaylist_drawer_read_colour),
.out_read_x(_w_displaylist_drawer_read_x),
.out_read_y(_w_displaylist_drawer_read_y),
.out_read_p0(_w_displaylist_drawer_read_p0),
.out_read_p1(_w_displaylist_drawer_read_p1),
.out_read_p2(_w_displaylist_drawer_read_p2),
.out_read_p3(_w_displaylist_drawer_read_p3),
.out_gpu_x(_w_displaylist_drawer_gpu_x),
.out_gpu_y(_w_displaylist_drawer_gpu_y),
.out_gpu_colour(_w_displaylist_drawer_gpu_colour),
.out_gpu_param0(_w_displaylist_drawer_gpu_param0),
.out_gpu_param1(_w_displaylist_drawer_gpu_param1),
.out_gpu_param2(_w_displaylist_drawer_gpu_param2),
.out_gpu_param3(_w_displaylist_drawer_gpu_param3),
.out_gpu_write(_w_displaylist_drawer_gpu_write),
.out_vector_block_number(_w_displaylist_drawer_vector_block_number),
.out_vector_block_colour(_w_displaylist_drawer_vector_block_colour),
.out_vector_block_xc(_w_displaylist_drawer_vector_block_xc),
.out_vector_block_yc(_w_displaylist_drawer_vector_block_yc),
.out_draw_vector(_w_displaylist_drawer_draw_vector),
.out_done(_w_displaylist_drawer_done),
.in_run(_displaylist_drawer_run),
.reset(in_video_reset),
.clock(in_video_clock)
);

M_memmap_io_mem_uartInBuffer __mem__uartInBuffer(
.clock0(clock),
.clock1(clock),
.in_uartInBuffer_wenable0(_d_uartInBuffer_wenable0),
.in_uartInBuffer_wdata0(_c_uartInBuffer_wdata0),
.in_uartInBuffer_addr0(_d_uartInBuffer_addr0),
.in_uartInBuffer_wenable1(_d_uartInBuffer_wenable1),
.in_uartInBuffer_wdata1(_d_uartInBuffer_wdata1),
.in_uartInBuffer_addr1(_d_uartInBuffer_addr1),
.out_uartInBuffer_rdata0(_w_mem_uartInBuffer_rdata0),
.out_uartInBuffer_rdata1(_w_mem_uartInBuffer_rdata1)
);
M_memmap_io_mem_uartOutBuffer __mem__uartOutBuffer(
.clock0(clock),
.clock1(clock),
.in_uartOutBuffer_wenable0(_d_uartOutBuffer_wenable0),
.in_uartOutBuffer_wdata0(_c_uartOutBuffer_wdata0),
.in_uartOutBuffer_addr0(_d_uartOutBuffer_addr0),
.in_uartOutBuffer_wenable1(_d_uartOutBuffer_wenable1),
.in_uartOutBuffer_wdata1(_d_uartOutBuffer_wdata1),
.in_uartOutBuffer_addr1(_d_uartOutBuffer_addr1),
.out_uartOutBuffer_rdata0(_w_mem_uartOutBuffer_rdata0),
.out_uartOutBuffer_rdata1(_w_mem_uartOutBuffer_rdata1)
);


always @* begin
_d_uo_data_in = _q_uo_data_in;
_d_uo_data_in_ready = _q_uo_data_in_ready;
_d_uartInBuffer_wenable0 = _q_uartInBuffer_wenable0;
_d_uartInBuffer_addr0 = _q_uartInBuffer_addr0;
_d_uartInBuffer_wenable1 = _q_uartInBuffer_wenable1;
_d_uartInBuffer_wdata1 = _q_uartInBuffer_wdata1;
_d_uartInBuffer_addr1 = _q_uartInBuffer_addr1;
_d_uartInBufferNext = _q_uartInBufferNext;
_d_uartInBufferTop = _q_uartInBufferTop;
_d_uartOutBuffer_wenable0 = _q_uartOutBuffer_wenable0;
_d_uartOutBuffer_addr0 = _q_uartOutBuffer_addr0;
_d_uartOutBuffer_wenable1 = _q_uartOutBuffer_wenable1;
_d_uartOutBuffer_wdata1 = _q_uartOutBuffer_wdata1;
_d_uartOutBuffer_addr1 = _q_uartOutBuffer_addr1;
_d_uartOutBufferNext = _q_uartOutBufferNext;
_d_uartOutBufferTop = _q_uartOutBufferTop;
_d_newuartOutBufferTop = _q_newuartOutBufferTop;
_d_coProReset = _q_coProReset;
_d_delayed_4532_4 = _q_delayed_4532_4;
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
_d_background_generator_background_write = _q_background_generator_background_write;
_d_tile_map_tm_x = _q_tile_map_tm_x;
_d_tile_map_tm_y = _q_tile_map_tm_y;
_d_tile_map_tm_character = _q_tile_map_tm_character;
_d_tile_map_tm_foreground = _q_tile_map_tm_foreground;
_d_tile_map_tm_background = _q_tile_map_tm_background;
_d_tile_map_tm_write = _q_tile_map_tm_write;
_d_tile_map_tile_writer_tile = _q_tile_map_tile_writer_tile;
_d_tile_map_tile_writer_line = _q_tile_map_tile_writer_line;
_d_tile_map_tile_writer_bitmap = _q_tile_map_tile_writer_bitmap;
_d_tile_map_tile_writer_write = _q_tile_map_tile_writer_write;
_d_tile_map_tm_scrollwrap = _q_tile_map_tm_scrollwrap;
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
_d_gpu_processor_v_gpu_param2 = _q_gpu_processor_v_gpu_param2;
_d_gpu_processor_v_gpu_param3 = _q_gpu_processor_v_gpu_param3;
_d_gpu_processor_blit1_writer_tile = _q_gpu_processor_blit1_writer_tile;
_d_gpu_processor_blit1_writer_line = _q_gpu_processor_blit1_writer_line;
_d_gpu_processor_blit1_writer_bitmap = _q_gpu_processor_blit1_writer_bitmap;
_d_gpu_processor_blit1_writer_active = _q_gpu_processor_blit1_writer_active;
_d_vector_drawer_vector_block_number = _q_vector_drawer_vector_block_number;
_d_vector_drawer_vector_block_colour = _q_vector_drawer_vector_block_colour;
_d_vector_drawer_vector_block_xc = _q_vector_drawer_vector_block_xc;
_d_vector_drawer_vector_block_yc = _q_vector_drawer_vector_block_yc;
_d_vector_drawer_draw_vector = _q_vector_drawer_draw_vector;
_d_vector_drawer_vertices_writer_block = _q_vector_drawer_vertices_writer_block;
_d_vector_drawer_vertices_writer_vertex = _q_vector_drawer_vertices_writer_vertex;
_d_vector_drawer_vertices_writer_xdelta = _q_vector_drawer_vertices_writer_xdelta;
_d_vector_drawer_vertices_writer_ydelta = _q_vector_drawer_vertices_writer_ydelta;
_d_vector_drawer_vertices_writer_active = _q_vector_drawer_vertices_writer_active;
_d_vector_drawer_vertices_writer_write = _q_vector_drawer_vertices_writer_write;
_d_displaylist_drawer_start_entry = _q_displaylist_drawer_start_entry;
_d_displaylist_drawer_finish_entry = _q_displaylist_drawer_finish_entry;
_d_displaylist_drawer_start_displaylist = _q_displaylist_drawer_start_displaylist;
_d_displaylist_drawer_writer_entry_number = _q_displaylist_drawer_writer_entry_number;
_d_displaylist_drawer_writer_active = _q_displaylist_drawer_writer_active;
_d_displaylist_drawer_writer_command = _q_displaylist_drawer_writer_command;
_d_displaylist_drawer_writer_colour = _q_displaylist_drawer_writer_colour;
_d_displaylist_drawer_writer_x = _q_displaylist_drawer_writer_x;
_d_displaylist_drawer_writer_y = _q_displaylist_drawer_writer_y;
_d_displaylist_drawer_writer_p0 = _q_displaylist_drawer_writer_p0;
_d_displaylist_drawer_writer_p1 = _q_displaylist_drawer_writer_p1;
_d_displaylist_drawer_writer_p2 = _q_displaylist_drawer_writer_p2;
_d_displaylist_drawer_writer_p3 = _q_displaylist_drawer_writer_p3;
_d_displaylist_drawer_writer_write = _q_displaylist_drawer_writer_write;
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
_lower_sprites_run = 1;
_upper_sprites_run = 1;
_character_map_window_run = 1;
_terminal_window_run = 1;
_display_run = 1;
_apu_processor_L_run = 1;
_apu_processor_R_run = 1;
_gpu_processor_run = 1;
_vector_drawer_run = 1;
_displaylist_drawer_run = 1;
_t_reg_btns = 0;
// _always_pre
_t_reg_btns = _d_delayed_4532_4;
_d_delayed_4532_4 =  in_btns;
_d_uartInBuffer_wenable0 = 0;
_d_uartInBuffer_wenable1 = 1;
_d_uartInBuffer_addr0 = _q_uartInBufferNext;
_d_uartInBuffer_addr1 = _q_uartInBufferTop;
_d_uartOutBuffer_wenable0 = 0;
_d_uartOutBuffer_wenable1 = 1;
_d_uartOutBuffer_addr0 = _q_uartOutBufferNext;
_d_uartOutBuffer_addr1 = _q_uartOutBufferTop;
_d_uo_data_in_ready = 0;
_d_p1hz_resetCounter = 0;
_d_sleepTimer_resetCounter = 0;
_d_timer1hz_resetCounter = 0;
_d_timer1khz_resetCounter = 0;
_d_rng_resetRandom = 0;
if (_w_urecv_io_data_out_ready) begin
// __block_1
// __block_3
_d_uartInBuffer_wdata1 = _w_urecv_io_data_out;
_d_uartInBufferTop = _q_uartInBufferTop+1;
// __block_4
end else begin
// __block_2
end
// __block_5
if ((_q_uartOutBufferNext!=_q_uartOutBufferTop)&&(!_w_usend_io_busy)) begin
// __block_6
// __block_8
_d_uo_data_in = _w_mem_uartOutBuffer_rdata0;
_d_uo_data_in_ready = 1;
_d_uartOutBufferNext = _q_uartOutBufferNext+1;
// __block_9
end else begin
// __block_7
end
// __block_10
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
_d_uo_data_in = 0;
_d_uo_data_in_ready = 0;
_d_uartInBuffer_wenable0 = 0;
_d_uartInBuffer_addr0 = 0;
_d_uartInBuffer_wenable1 = 0;
_d_uartInBuffer_wdata1 = 0;
_d_uartInBuffer_addr1 = 0;
_d_uartInBufferNext = 0;
_d_uartInBufferTop = 0;
_d_uartOutBuffer_wenable0 = 0;
_d_uartOutBuffer_addr0 = 0;
_d_uartOutBuffer_wenable1 = 0;
_d_uartOutBuffer_wdata1 = 0;
_d_uartOutBuffer_addr1 = 0;
_d_uartOutBufferNext = 0;
_d_uartOutBufferTop = 0;
_d_newuartOutBufferTop = 0;
_d_coProReset = 0;
// --
_d_terminal_window_showterminal = 1;
_d_terminal_window_showcursor = 1;
_d_index = 1;
end
1: begin
// __while__block_11
if (1) begin
// __block_12
// __block_14
_d_uartOutBufferTop = _q_newuartOutBufferTop;
if (in_memoryRead) begin
// __block_15
// __block_17
  case (in_memoryAddress)
  16'h1000: begin
// __block_19_case
// __block_20
_d_readData = {8'b0,_w_mem_uartInBuffer_rdata0};
_d_uartInBufferNext = _q_uartInBufferNext+1;
// __block_21
  end
  16'h1002: begin
// __block_22_case
// __block_23
_d_readData = {14'b0,(_d_uartOutBufferTop+1==_d_uartOutBufferNext),(_q_uartInBufferNext!=_d_uartInBufferTop)};
// __block_24
  end
  default: begin
// __block_25_case
// __block_26
_d_readData = 0;
// __block_27
  end
endcase
// __block_18
// __block_28
end else begin
// __block_16
end
// __block_29
if (in_memoryWrite) begin
// __block_30
// __block_32
_d_coProReset = 3;
  case (in_memoryAddress)
  16'h1000: begin
// __block_34_case
// __block_35
_d_uartOutBuffer_wdata1 = in_writeData[0+:8];
_d_newuartOutBufferTop = _d_uartOutBufferTop+1;
// __block_36
  end
  16'h1004: begin
// __block_37_case
// __block_38
_d_terminal_window_terminal_character = in_writeData;
_d_terminal_window_terminal_write = 1;
// __block_39
  end
  16'h1008: begin
// __block_40_case
// __block_41
_d_leds = in_writeData;
// __block_42
  end
  default: begin
// __block_43_case
// __block_44
// __block_45
  end
endcase
// __block_33
// __block_46
end else begin
// __block_31
// __block_47
_d_coProReset = (_q_coProReset==0)?0:_q_coProReset-1;
// __block_48
end
// __block_49
if (_d_coProReset==1) begin
// __block_50
// __block_52
_d_background_generator_background_write = 0;
_d_tile_map_tile_writer_write = 0;
_d_tile_map_tm_write = 0;
_d_tile_map_tm_scrollwrap = 0;
_d_lower_sprites_sprite_layer_write = 0;
_d_lower_sprites_sprite_writer_active = 0;
_d_gpu_processor_gpu_write = 0;
_d_gpu_processor_blit1_writer_active = 0;
_d_upper_sprites_sprite_layer_write = 0;
_d_upper_sprites_sprite_writer_active = 0;
_d_character_map_window_tpu_write = 0;
_d_terminal_window_terminal_write = 0;
_d_vector_drawer_draw_vector = 0;
_d_vector_drawer_vertices_writer_write = 0;
_d_displaylist_drawer_start_displaylist = 0;
_d_displaylist_drawer_writer_write = 0;
_d_apu_processor_L_apu_write = 0;
_d_apu_processor_R_apu_write = 0;
// __block_53
end else begin
// __block_51
end
// __block_54
// __block_55
_d_index = 1;
end else begin
_d_index = 2;
end
end
2: begin
// __block_13
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


module M_main_mem_mem(
input                  [0:0] in_mem_wenable,
input       [31:0]    in_mem_wdata,
input                  [12:0]    in_mem_addr,
output reg  [31:0]    out_mem_rdata,
input                                      clock
);
reg  [31:0] buffer[8191:0];
always @(posedge clock) begin
  if (in_mem_wenable) begin
    buffer[in_mem_addr] <= in_mem_wdata;
  end
  out_mem_rdata <= buffer[in_mem_addr];
end
initial begin
 buffer[0] = 32'h00001137;
 buffer[1] = 32'h00000097;
 buffer[2] = 32'h018080e7;
 buffer[3] = 32'h00000317;
 buffer[4] = 32'h00830067;
 buffer[5] = 32'h00000000;
 buffer[6] = 32'h00008067;
 buffer[7] = 32'hff010113;
 buffer[8] = 32'h00012623;
 buffer[9] = 32'h00001737;
 buffer[10] = 32'h00270693;
 buffer[11] = 32'h0100006f;
 buffer[12] = 32'h00072783;
 buffer[13] = 32'h00f72223;
 buffer[14] = 32'h00f72423;
 buffer[15] = 32'h0006d783;
 buffer[16] = 32'h0017f793;
 buffer[17] = 32'h00078063;
 buffer[18] = 32'hfe9ff06f;
end

endmodule

module M_main (
in_btns,
in_uart_rx,
out_leds,
out_gpdi_dp,
out_gpdi_dn,
out_uart_tx,
out_audio_l,
out_audio_r,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [6:0] in_btns;
input  [0:0] in_uart_rx;
output  [7:0] out_leds;
output  [3:0] out_gpdi_dp;
output  [3:0] out_gpdi_dn;
output  [0:0] out_uart_tx;
output  [3:0] out_audio_l;
output  [3:0] out_audio_r;
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
wire  [9:0] _w_video_x;
wire  [9:0] _w_video_y;
wire  [0:0] _w_video_active;
wire  [0:0] _w_video_vblank;
wire  [3:0] _w_video_gpdi_dp;
wire  [3:0] _w_video_gpdi_dn;
wire  [7:0] _w_IO_Map_leds;
wire  [0:0] _w_IO_Map_uart_tx;
wire  [3:0] _w_IO_Map_audio_l;
wire  [3:0] _w_IO_Map_audio_r;
wire  [7:0] _w_IO_Map_video_r;
wire  [7:0] _w_IO_Map_video_g;
wire  [7:0] _w_IO_Map_video_b;
wire  [15:0] _w_IO_Map_readData;
wire _w_IO_Map_done;
wire  [11:0] _w_cpu_mem_addr;
wire  [31:0] _w_cpu_mem_wdata;
wire  [0:0] _w_cpu_mem_wen;
wire  [0:0] _w_cpu_mem_ren;
wire _w_cpu_done;
wire  [31:0] _w_mem_mem_rdata;
reg  [12:0] _t_mem_addr;

reg  [0:0] _d_mem_wenable;
reg  [0:0] _q_mem_wenable;
reg  [31:0] _d_mem_wdata;
reg  [31:0] _q_mem_wdata;
reg  [31:0] _d_icememoryReadData;
reg  [31:0] _q_icememoryReadData;
reg  [15:0] _d_IO_Map_memoryAddress,_q_IO_Map_memoryAddress;
reg  [15:0] _d_IO_Map_writeData,_q_IO_Map_writeData;
reg  [0:0] _d_IO_Map_memoryWrite,_q_IO_Map_memoryWrite;
reg  [0:0] _d_IO_Map_memoryRead,_q_IO_Map_memoryRead;
reg  [0:0] _d_IO_Map_resetCoPro,_q_IO_Map_resetCoPro;
reg  [1:0] _d_index,_q_index;
reg  _IO_Map_run;
reg  _cpu_run;
assign out_leds = _w_IO_Map_leds;
assign out_gpdi_dp = _w_video_gpdi_dp;
assign out_gpdi_dn = _w_video_gpdi_dn;
assign out_uart_tx = _w_IO_Map_uart_tx;
assign out_audio_l = _w_IO_Map_audio_l;
assign out_audio_r = _w_IO_Map_audio_r;
assign out_done = (_q_index == 3);

always @(posedge _w_clk_gen_clkout0) begin
  if (reset || !in_run) begin
_q_mem_wenable <= 0;
_q_mem_wdata <= 0;
  if (reset) begin
_q_index <= 0;
end else begin
_q_index <= 0;
end
  end else begin
_q_mem_wenable <= _d_mem_wenable;
_q_mem_wdata <= _d_mem_wdata;
_q_icememoryReadData <= _d_icememoryReadData;
_q_index <= _d_index;
  end
_q_IO_Map_memoryAddress <= _d_IO_Map_memoryAddress;
_q_IO_Map_writeData <= _d_IO_Map_writeData;
_q_IO_Map_memoryWrite <= _d_IO_Map_memoryWrite;
_q_IO_Map_memoryRead <= _d_IO_Map_memoryRead;
_q_IO_Map_resetCoPro <= _d_IO_Map_resetCoPro;
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
M_memmap_io IO_Map (
.in_btns(in_btns),
.in_uart_rx(in_uart_rx),
.in_vblank(_w_video_vblank),
.in_pix_active(_w_video_active),
.in_pix_x(_w_video_x),
.in_pix_y(_w_video_y),
.in_clock_50mhz(_w_clk_gen_clkout0),
.in_video_clock(_w_clk_gen_clkout1),
.in_video_reset(_w_vga_rstcond_out),
.in_memoryAddress(_d_IO_Map_memoryAddress),
.in_writeData(_d_IO_Map_writeData),
.in_memoryWrite(_d_IO_Map_memoryWrite),
.in_memoryRead(_d_IO_Map_memoryRead),
.in_resetCoPro(_d_IO_Map_resetCoPro),
.out_leds(_w_IO_Map_leds),
.out_uart_tx(_w_IO_Map_uart_tx),
.out_audio_l(_w_IO_Map_audio_l),
.out_audio_r(_w_IO_Map_audio_r),
.out_video_r(_w_IO_Map_video_r),
.out_video_g(_w_IO_Map_video_g),
.out_video_b(_w_IO_Map_video_b),
.out_readData(_w_IO_Map_readData),
.out_done(_w_IO_Map_done),
.in_run(_IO_Map_run),
.reset(reset),
.clock(_w_clk_gen_clkout0)
);
M_rv32i_cpu cpu (
.in_mem_rdata(_d_icememoryReadData),
.out_mem_addr(_w_cpu_mem_addr),
.out_mem_wdata(_w_cpu_mem_wdata),
.out_mem_wen(_w_cpu_mem_wen),
.out_mem_ren(_w_cpu_mem_ren),
.out_done(_w_cpu_done),
.in_run(_cpu_run),
.reset(reset),
.clock(_w_clk_gen_clkout0)
);

M_main_mem_mem __mem__mem(
.clock(_w_clk_gen_clkout0),
.in_mem_wenable(_d_mem_wenable),
.in_mem_wdata(_d_mem_wdata),
.in_mem_addr(_t_mem_addr),
.out_mem_rdata(_w_mem_mem_rdata)
);


always @* begin
_d_mem_wenable = _q_mem_wenable;
_d_mem_wdata = _q_mem_wdata;
_d_icememoryReadData = _q_icememoryReadData;
_d_IO_Map_memoryAddress = _q_IO_Map_memoryAddress;
_d_IO_Map_writeData = _q_IO_Map_writeData;
_d_IO_Map_memoryWrite = _q_IO_Map_memoryWrite;
_d_IO_Map_memoryRead = _q_IO_Map_memoryRead;
_d_IO_Map_resetCoPro = _q_IO_Map_resetCoPro;
_d_index = _q_index;
_IO_Map_run = 1;
_cpu_run = 1;
_t_mem_addr = 0;
// _always_pre
_d_IO_Map_memoryWrite = 0;
_d_IO_Map_memoryRead = 0;
_t_mem_addr = _w_cpu_mem_addr[0+:10];
if (_w_cpu_mem_wen) begin
// __block_1
// __block_3
  case (_w_cpu_mem_addr[10+:1])
  0: begin
// __block_5_case
// __block_6
_d_mem_wdata = _w_cpu_mem_wdata;
_d_mem_wenable = _w_cpu_mem_wen;
// __block_7
  end
  1: begin
// __block_8_case
// __block_9
_d_IO_Map_memoryAddress = _w_cpu_mem_addr;
_d_IO_Map_memoryWrite = 1;
// __block_10
  end
endcase
// __block_4
// __block_11
end else begin
// __block_2
end
// __block_12
if (_w_cpu_mem_ren) begin
// __block_13
// __block_15
  case (_w_cpu_mem_addr[10+:1])
  0: begin
// __block_17_case
// __block_18
_d_icememoryReadData = _w_mem_mem_rdata;
// __block_19
  end
  1: begin
// __block_20_case
// __block_21
_d_IO_Map_memoryRead = 1;
_d_icememoryReadData = _w_IO_Map_readData;
// __block_22
  end
endcase
// __block_16
// __block_23
end else begin
// __block_14
end
// __block_24
_d_index = 3;
case (_q_index)
0: begin
// _top
// var inits
_d_mem_wenable = 0;
_d_mem_wdata = 0;
_t_mem_addr = 0;
// --
_cpu_run = 0;
_d_index = 1;
end
1: begin
// __block_25
if (_w_cpu_done == 1) begin
_d_index = 2;
end else begin
_d_index = 1;
end
end
2: begin
// __block_26
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


module M_rv32i_cpu_mem_xregsA(
input                  [0:0] in_xregsA_wenable,
input      signed [31:0]    in_xregsA_wdata,
input                  [4:0]    in_xregsA_addr,
output reg signed [31:0]    out_xregsA_rdata,
input                                      clock
);
reg signed [31:0] buffer[31:0];
always @(posedge clock) begin
  if (in_xregsA_wenable) begin
    buffer[in_xregsA_addr] <= in_xregsA_wdata;
  end
  out_xregsA_rdata <= buffer[in_xregsA_addr];
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
end

endmodule

module M_rv32i_cpu_mem_xregsB(
input                  [0:0] in_xregsB_wenable,
input      signed [31:0]    in_xregsB_wdata,
input                  [4:0]    in_xregsB_addr,
output reg signed [31:0]    out_xregsB_rdata,
input                                      clock
);
reg signed [31:0] buffer[31:0];
always @(posedge clock) begin
  if (in_xregsB_wenable) begin
    buffer[in_xregsB_addr] <= in_xregsB_wdata;
  end
  out_xregsB_rdata <= buffer[in_xregsB_addr];
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
end

endmodule

module M_rv32i_cpu (
in_mem_rdata,
out_mem_addr,
out_mem_wdata,
out_mem_wen,
out_mem_ren,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [31:0] in_mem_rdata;
output  [11:0] out_mem_addr;
output  [31:0] out_mem_wdata;
output  [0:0] out_mem_wen;
output  [0:0] out_mem_ren;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire signed [31:0] _w_alu_r;
wire  [0:0] _w_alu_working;
wire  [4:0] _w_dec_write_rd;
wire  [0:0] _w_dec_jump;
wire  [0:0] _w_dec_branch;
wire  [0:0] _w_dec_load_store;
wire  [0:0] _w_dec_store;
wire  [2:0] _w_dec_loadStoreOp;
wire  [2:0] _w_dec_select;
wire  [0:0] _w_dec_select2;
wire signed [31:0] _w_dec_imm;
wire  [0:0] _w_dec_forceZero;
wire  [0:0] _w_dec_regOrPc;
wire  [0:0] _w_dec_regOrImm;
wire  [0:0] _w_cmps_j;
wire signed [31:0] _w_mem_xregsA_rdata;
wire signed [31:0] _w_mem_xregsB_rdata;
reg  [0:0] _t_xregsA_wenable;
reg signed [31:0] _t_xregsA_wdata;
reg  [4:0] _t_xregsA_addr;
reg  [0:0] _t_xregsB_wenable;
reg signed [31:0] _t_xregsB_wdata;
reg  [4:0] _t_xregsB_addr;
reg  [0:0] _t_alu_enable;
reg  [31:0] _t___block_12_tmp;
wire  [11:0] _w_next_pc;
wire  [2:0] _w_funct3;

reg  [31:0] _d_instr;
reg  [31:0] _q_instr;
reg  [11:0] _d_pc;
reg  [11:0] _q_pc;
reg  [11:0] _d_mem_addr,_q_mem_addr;
reg  [31:0] _d_mem_wdata,_q_mem_wdata;
reg  [0:0] _d_mem_wen,_q_mem_wen;
reg  [0:0] _d_mem_ren,_q_mem_ren;
reg  [9:0] _d_index,_q_index;
assign out_mem_addr = _d_mem_addr;
assign out_mem_wdata = _d_mem_wdata;
assign out_mem_wen = _d_mem_wen;
assign out_mem_ren = _d_mem_ren;
assign out_done = (_q_index == 512);

always @(posedge clock) begin
  if (reset || !in_run) begin
  if (reset) begin
_q_index <= 512;
end else begin
_q_index <= 1;
end
  end else begin
_q_instr <= _d_instr;
_q_pc <= _d_pc;
_q_mem_addr <= _d_mem_addr;
_q_mem_wdata <= _d_mem_wdata;
_q_mem_wen <= _d_mem_wen;
_q_mem_ren <= _d_mem_ren;
_q_index <= _d_index;
  end
end

M_intops alu (
.in_enable(_t_alu_enable),
.in_pc(_d_pc),
.in_xa(_w_mem_xregsA_rdata),
.in_xb(_w_mem_xregsB_rdata),
.in_imm(_w_dec_imm),
.in_select(_w_dec_select),
.in_select2(_w_dec_select2),
.in_forceZero(_w_dec_forceZero),
.in_regOrPc(_w_dec_regOrPc),
.in_regOrImm(_w_dec_regOrImm),
.out_r(_w_alu_r),
.out_working(_w_alu_working),
.reset(reset),
.clock(clock)
);
M_decode dec (
.in_instr(_q_instr),
.out_write_rd(_w_dec_write_rd),
.out_jump(_w_dec_jump),
.out_branch(_w_dec_branch),
.out_load_store(_w_dec_load_store),
.out_store(_w_dec_store),
.out_loadStoreOp(_w_dec_loadStoreOp),
.out_select(_w_dec_select),
.out_select2(_w_dec_select2),
.out_imm(_w_dec_imm),
.out_forceZero(_w_dec_forceZero),
.out_regOrPc(_w_dec_regOrPc),
.out_regOrImm(_w_dec_regOrImm),
.clock(clock)
);
M_intcmp cmps (
.in_a(_w_mem_xregsA_rdata),
.in_b(_w_mem_xregsB_rdata),
.in_select(_w_funct3),
.in_enable(_w_dec_branch),
.out_j(_w_cmps_j),
.clock(clock)
);

M_rv32i_cpu_mem_xregsA __mem__xregsA(
.clock(clock),
.in_xregsA_wenable(_t_xregsA_wenable),
.in_xregsA_wdata(_t_xregsA_wdata),
.in_xregsA_addr(_t_xregsA_addr),
.out_xregsA_rdata(_w_mem_xregsA_rdata)
);
M_rv32i_cpu_mem_xregsB __mem__xregsB(
.clock(clock),
.in_xregsB_wenable(_t_xregsB_wenable),
.in_xregsB_wdata(_t_xregsB_wdata),
.in_xregsB_addr(_t_xregsB_addr),
.out_xregsB_rdata(_w_mem_xregsB_rdata)
);

assign _w_funct3 = _d_instr[12+:3];
assign _w_next_pc = _q_pc+1;

always @* begin
_d_instr = _q_instr;
_d_pc = _q_pc;
_d_mem_addr = _q_mem_addr;
_d_mem_wdata = _q_mem_wdata;
_d_mem_wen = _q_mem_wen;
_d_mem_ren = _q_mem_ren;
_d_index = _q_index;
_t_xregsA_wenable = 0;
_t_xregsA_wdata = 0;
_t_xregsA_addr = 0;
_t_xregsB_wenable = 0;
_t_xregsB_wdata = 0;
_t_xregsB_addr = 0;
_t_alu_enable = 0;
_t___block_12_tmp = 0;
// _always_pre
_d_mem_wen = 0;
_d_mem_ren = 0;
_t_alu_enable = 0;
_t_xregsA_wenable = 0;
_t_xregsB_wenable = 0;
_t_xregsA_addr = _q_instr[15+:5];
_t_xregsB_addr = _q_instr[20+:5];
_d_index = 512;
(* parallel_case, full_case *)
case (1'b1)
_q_index[0]: begin
// _top
// var inits
_t_xregsA_wenable = 0;
_t_xregsA_wdata = 0;
_t_xregsA_addr = 0;
_t_xregsB_wenable = 0;
_t_xregsB_wdata = 0;
_t_xregsB_addr = 0;
// --
_d_mem_addr = 0;
_d_mem_ren = 1;
_d_instr = in_mem_rdata;
_d_pc = _d_mem_addr;
_t_xregsA_addr = _d_instr[15+:5];
_t_xregsB_addr = _d_instr[20+:5];
_d_index = 2;
end
_q_index[1]: begin
// __block_1
_t_alu_enable = 1;
_d_index = 4;
end
_q_index[2]: begin
// __while__block_2
if (1) begin
// __block_3
// __block_5
if (_w_dec_load_store) begin
// __block_6
// __block_8
_d_mem_addr = _w_alu_r>>2;
_d_mem_ren = 1;
_d_index = 32;
end else begin
// __block_7
// __block_89
if (_w_alu_working==0) begin
// __block_90
// __block_92
_d_mem_addr = (_w_dec_jump|_w_cmps_j)?_w_alu_r[2+:12]:_w_next_pc;
_t_xregsA_wdata = (_w_dec_jump|_w_cmps_j)?(_w_next_pc)<<2:_w_alu_r;
_t_xregsB_wdata = (_w_dec_jump|_w_cmps_j)?(_w_next_pc)<<2:_w_alu_r;
if (_w_dec_write_rd) begin
// __block_93
// __block_95
_t_xregsA_wenable = 1;
_t_xregsB_wenable = 1;
_t_xregsA_addr = _w_dec_write_rd;
_t_xregsB_addr = _w_dec_write_rd;
// __block_96
end else begin
// __block_94
end
// __block_97
_d_index = 8;
end else begin
// __block_91
_d_index = 4;
end
end
end else begin
_d_index = 8;
end
end
_q_index[5]: begin
// __block_9
if (~_w_dec_store) begin
// __block_10
// __block_12
// var inits
// --
  case (_w_dec_loadStoreOp[0+:2])
  2'b00: begin
// __block_14_case
// __block_15
  case (_w_alu_r[0+:2])
  2'b00: begin
// __block_17_case
// __block_18
_t___block_12_tmp = {{24{_w_dec_loadStoreOp[2+:1]&in_mem_rdata[7+:1]}},in_mem_rdata[0+:8]};
// __block_19
  end
  2'b01: begin
// __block_20_case
// __block_21
_t___block_12_tmp = {{24{_w_dec_loadStoreOp[2+:1]&in_mem_rdata[15+:1]}},in_mem_rdata[8+:8]};
// __block_22
  end
  2'b10: begin
// __block_23_case
// __block_24
_t___block_12_tmp = {{24{_w_dec_loadStoreOp[2+:1]&in_mem_rdata[23+:1]}},in_mem_rdata[16+:8]};
// __block_25
  end
  2'b11: begin
// __block_26_case
// __block_27
_t___block_12_tmp = {{24{_w_dec_loadStoreOp[2+:1]&in_mem_rdata[31+:1]}},in_mem_rdata[24+:8]};
// __block_28
  end
  default: begin
// __block_29_case
// __block_30
_t___block_12_tmp = 0;
// __block_31
  end
endcase
// __block_16
// __block_32
  end
  2'b01: begin
// __block_33_case
// __block_34
  case (_w_alu_r[1+:1])
  1'b0: begin
// __block_36_case
// __block_37
_t___block_12_tmp = {{16{_w_dec_loadStoreOp[2+:1]&in_mem_rdata[15+:1]}},in_mem_rdata[0+:16]};
// __block_38
  end
  1'b1: begin
// __block_39_case
// __block_40
_t___block_12_tmp = {{16{_w_dec_loadStoreOp[2+:1]&in_mem_rdata[31+:1]}},in_mem_rdata[16+:16]};
// __block_41
  end
  default: begin
// __block_42_case
// __block_43
_t___block_12_tmp = 0;
// __block_44
  end
endcase
// __block_35
// __block_45
  end
  2'b10: begin
// __block_46_case
// __block_47
_t___block_12_tmp = in_mem_rdata;
// __block_48
  end
  default: begin
// __block_49_case
// __block_50
_t___block_12_tmp = 0;
// __block_51
  end
endcase
// __block_13
_t_xregsA_wenable = 1;
_t_xregsB_wenable = 1;
_t_xregsA_wdata = _t___block_12_tmp;
_t_xregsB_wdata = _t___block_12_tmp;
_t_xregsA_addr = _w_dec_write_rd;
_t_xregsB_addr = _w_dec_write_rd;
// __block_52
_d_index = 128;
end else begin
// __block_11
// __block_53
  case (_w_dec_loadStoreOp)
  3'b000: begin
// __block_55_case
// __block_56
  case (_w_alu_r[0+:2])
  2'b00: begin
// __block_58_case
// __block_59
_d_mem_wdata = {in_mem_rdata[8+:24],_w_mem_xregsB_rdata[0+:8]};
// __block_60
  end
  2'b01: begin
// __block_61_case
// __block_62
_d_mem_wdata = {in_mem_rdata[16+:16],_w_mem_xregsB_rdata[0+:8],in_mem_rdata[0+:8]};
// __block_63
  end
  2'b10: begin
// __block_64_case
// __block_65
_d_mem_wdata = {in_mem_rdata[24+:8],_w_mem_xregsB_rdata[0+:8],in_mem_rdata[0+:16]};
// __block_66
  end
  2'b11: begin
// __block_67_case
// __block_68
_d_mem_wdata = {_w_mem_xregsB_rdata[0+:8],in_mem_rdata[0+:24]};
// __block_69
  end
endcase
// __block_57
// __block_70
  end
  3'b001: begin
// __block_71_case
// __block_72
  case (_w_alu_r[1+:1])
  1'b0: begin
// __block_74_case
// __block_75
_d_mem_wdata = {in_mem_rdata[16+:16],_w_mem_xregsB_rdata[0+:16]};
// __block_76
  end
  1'b1: begin
// __block_77_case
// __block_78
_d_mem_wdata = {_w_mem_xregsB_rdata[0+:16],in_mem_rdata[0+:16]};
// __block_79
  end
endcase
// __block_73
// __block_80
  end
  3'b010: begin
// __block_81_case
// __block_82
_d_mem_wdata = _w_mem_xregsB_rdata;
// __block_83
  end
endcase
// __block_54
_d_mem_addr = _w_alu_r>>2;
_d_mem_wen = 1;
_d_index = 256;
end
end
_q_index[3]: begin
// __block_4
_d_index = 512;
end
_q_index[7]: begin
// __block_86
_d_mem_addr = _w_next_pc;
_d_index = 8;
end
_q_index[8]: begin
// __block_84
// __block_85
_d_index = 128;
end
512: begin // end of rv32i_cpu
end
default: begin 
_d_index = 512;
 end
endcase
end
endmodule


module M_decode (
in_instr,
out_write_rd,
out_jump,
out_branch,
out_load_store,
out_store,
out_loadStoreOp,
out_select,
out_select2,
out_imm,
out_forceZero,
out_regOrPc,
out_regOrImm,
out_clock,
clock
);
input  [31:0] in_instr;
output  [4:0] out_write_rd;
output  [0:0] out_jump;
output  [0:0] out_branch;
output  [0:0] out_load_store;
output  [0:0] out_store;
output  [2:0] out_loadStoreOp;
output  [2:0] out_select;
output  [0:0] out_select2;
output signed [31:0] out_imm;
output  [0:0] out_forceZero;
output  [0:0] out_regOrPc;
output  [0:0] out_regOrImm;
output out_clock;
input clock;
assign out_clock = clock;
reg  [4:0] _t_write_rd;
reg  [0:0] _t_jump;
reg  [0:0] _t_branch;
reg  [0:0] _t_load_store;
reg  [0:0] _t_store;
reg  [2:0] _t_loadStoreOp;
reg  [2:0] _t_select;
reg  [0:0] _t_select2;
reg signed [31:0] _t_imm;
reg  [0:0] _t_forceZero;
reg  [0:0] _t_regOrPc;
reg  [0:0] _t_regOrImm;

assign out_write_rd = _t_write_rd;
assign out_jump = _t_jump;
assign out_branch = _t_branch;
assign out_load_store = _t_load_store;
assign out_store = _t_store;
assign out_loadStoreOp = _t_loadStoreOp;
assign out_select = _t_select;
assign out_select2 = _t_select2;
assign out_imm = _t_imm;
assign out_forceZero = _t_forceZero;
assign out_regOrPc = _t_regOrPc;
assign out_regOrImm = _t_regOrImm;

always @(posedge clock) begin
end




always @* begin
_t_write_rd = 0;
_t_jump = 0;
_t_branch = 0;
_t_load_store = 0;
_t_store = 0;
_t_loadStoreOp = 0;
_t_select = 0;
_t_select2 = 0;
_t_imm = 0;
_t_forceZero = 0;
_t_regOrPc = 0;
_t_regOrImm = 0;
// _always_pre
  case (in_instr[0+:7])
  7'b0010111: begin
// __block_2_case
// __block_3
_t_write_rd = in_instr[7+:5];
_t_jump = 0;
_t_branch = 0;
_t_load_store = 0;
_t_store = 0;
_t_select = 0;
_t_select2 = 0;
_t_imm = {in_instr[12+:20],12'b0};
_t_forceZero = 1;
_t_regOrPc = 1;
_t_regOrImm = 1;
// __block_4
  end
  7'b0110111: begin
// __block_5_case
// __block_6
_t_write_rd = in_instr[7+:5];
_t_jump = 0;
_t_branch = 0;
_t_load_store = 0;
_t_store = 0;
_t_select = 0;
_t_select2 = 0;
_t_imm = {in_instr[12+:20],12'b0};
_t_forceZero = 0;
_t_regOrPc = 0;
_t_regOrImm = 1;
// __block_7
  end
  7'b1101111: begin
// __block_8_case
// __block_9
_t_write_rd = in_instr[7+:5];
_t_jump = 1;
_t_branch = 0;
_t_load_store = 0;
_t_store = 0;
_t_select = 0;
_t_select2 = 0;
_t_imm = {{12{in_instr[31+:1]}},in_instr[12+:8],in_instr[20+:1],in_instr[21+:10],1'b0};
_t_forceZero = 1;
_t_regOrPc = 1;
_t_regOrImm = 1;
// __block_10
  end
  7'b1100111: begin
// __block_11_case
// __block_12
_t_write_rd = in_instr[7+:5];
_t_jump = 1;
_t_branch = 0;
_t_load_store = 0;
_t_store = 0;
_t_select = 0;
_t_select2 = 0;
_t_imm = {{20{in_instr[31+:1]}},in_instr[20+:12]};
_t_forceZero = 1;
_t_regOrPc = 0;
_t_regOrImm = 1;
// __block_13
  end
  7'b1100011: begin
// __block_14_case
// __block_15
_t_write_rd = 0;
_t_jump = 0;
_t_branch = 1;
_t_load_store = 0;
_t_store = 0;
_t_select = 0;
_t_select2 = 0;
_t_imm = {{20{in_instr[31+:1]}},in_instr[7+:1],in_instr[25+:6],in_instr[8+:4],1'b0};
_t_forceZero = 1;
_t_regOrPc = 1;
_t_regOrImm = 1;
// __block_16
  end
  7'b0000011: begin
// __block_17_case
// __block_18
_t_write_rd = in_instr[7+:5];
_t_jump = 0;
_t_branch = 1;
_t_load_store = 1;
_t_store = 0;
_t_loadStoreOp = in_instr[12+:3];
_t_select = 0;
_t_select2 = 0;
_t_imm = {{20{in_instr[31+:1]}},in_instr[20+:12]};
_t_forceZero = 1;
_t_regOrPc = 0;
_t_regOrImm = 1;
// __block_19
  end
  7'b0100011: begin
// __block_20_case
// __block_21
_t_write_rd = 0;
_t_jump = 0;
_t_branch = 0;
_t_load_store = 1;
_t_store = 1;
_t_loadStoreOp = in_instr[12+:3];
_t_select = 0;
_t_select2 = 0;
_t_imm = {{20{in_instr[31+:1]}},in_instr[25+:7],in_instr[7+:5]};
_t_forceZero = 1;
_t_regOrPc = 0;
_t_regOrImm = 1;
// __block_22
  end
  7'b0010011: begin
// __block_23_case
// __block_24
_t_write_rd = in_instr[7+:5];
_t_jump = 0;
_t_branch = 0;
_t_load_store = 0;
_t_store = 0;
_t_select = in_instr[12+:3];
_t_select2 = in_instr[30+:1]&(in_instr[12+:3]!=3'b000);
_t_imm = {{20{in_instr[31+:1]}},in_instr[20+:12]};
_t_forceZero = 1;
_t_regOrPc = 0;
_t_regOrImm = 1;
// __block_25
  end
  7'b0110011: begin
// __block_26_case
// __block_27
_t_write_rd = in_instr[7+:5];
_t_jump = 0;
_t_branch = 0;
_t_load_store = 0;
_t_store = 0;
_t_select = in_instr[12+:3];
_t_select2 = in_instr[30+:1];
_t_imm = 0;
_t_forceZero = 1;
_t_regOrPc = 0;
_t_regOrImm = 0;
// __block_28
  end
  default: begin
// __block_29_case
// __block_30
_t_write_rd = 0;
_t_jump = 0;
_t_branch = 0;
_t_load_store = 0;
_t_store = 0;
_t_select = 0;
_t_select2 = 0;
_t_imm = 0;
_t_forceZero = 0;
_t_regOrPc = 0;
_t_regOrImm = 0;
// __block_31
  end
endcase
// __block_1
end
endmodule


module M_intops (
in_enable,
in_pc,
in_xa,
in_xb,
in_imm,
in_select,
in_select2,
in_forceZero,
in_regOrPc,
in_regOrImm,
out_r,
out_working,
reset,
out_clock,
clock
);
input  [0:0] in_enable;
input  [11:0] in_pc;
input signed [31:0] in_xa;
input signed [31:0] in_xb;
input signed [31:0] in_imm;
input  [2:0] in_select;
input  [0:0] in_select2;
input  [0:0] in_forceZero;
input  [0:0] in_regOrPc;
input  [0:0] in_regOrImm;
output signed [31:0] out_r;
output  [0:0] out_working;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
reg signed [31:0] _t___block_11_tmp;
wire signed [31:0] _w_a;
wire signed [31:0] _w_b;

reg  [0:0] _d_signed;
reg  [0:0] _q_signed;
reg  [0:0] _d_dir;
reg  [0:0] _q_dir;
reg  [4:0] _d_shamt;
reg  [4:0] _q_shamt;
reg signed [31:0] _d_r,_q_r;
reg  [0:0] _d_working,_q_working;
assign out_r = _q_r;
assign out_working = _q_working;

always @(posedge clock) begin
  if (reset) begin
_q_signed <= 0;
_q_dir <= 0;
_q_shamt <= 0;
  end else begin
_q_signed <= _d_signed;
_q_dir <= _d_dir;
_q_shamt <= _d_shamt;
_q_r <= _d_r;
_q_working <= _d_working;
  end
end



assign _w_b = in_regOrImm?in_imm:(in_xb);
assign _w_a = in_regOrPc?$signed({20'b0,in_pc[0+:10],2'b0}):(in_forceZero?in_xa:$signed(32'b0));

always @* begin
_d_signed = _q_signed;
_d_dir = _q_dir;
_d_shamt = _q_shamt;
_d_r = _q_r;
_d_working = _q_working;
_t___block_11_tmp = 0;
// _always_pre
if (_q_shamt>0) begin
// __block_1
// __block_3
_d_r = _q_dir?(_q_signed?{_q_r[31+:1],_q_r[1+:31]}:{$signed(1'b0),_q_r[1+:31]}):{_q_r[0+:31],$signed(1'b0)};
_d_shamt = _q_shamt-1;
// __block_4
end else begin
// __block_2
// __block_5
if (in_enable) begin
// __block_6
// __block_8
  case (in_select)
  3'b000: begin
// __block_10_case
// __block_11
// var inits
// --
if (in_select2) begin
// __block_12
// __block_14
_t___block_11_tmp = -_w_b;
// __block_15
end else begin
// __block_13
// __block_16
_t___block_11_tmp = _w_b;
// __block_17
end
// __block_18
_d_r = _w_a+_t___block_11_tmp;
// __block_19
  end
  3'b010: begin
// __block_20_case
// __block_21
if ($signed(_w_a)<$signed(_w_b)) begin
// __block_22
// __block_24
_d_r = 32'b1;
// __block_25
end else begin
// __block_23
// __block_26
_d_r = 32'b0;
// __block_27
end
// __block_28
// __block_29
  end
  3'b011: begin
// __block_30_case
// __block_31
if ($unsigned(_w_a)<$unsigned(_w_b)) begin
// __block_32
// __block_34
_d_r = 32'b1;
// __block_35
end else begin
// __block_33
// __block_36
_d_r = 32'b0;
// __block_37
end
// __block_38
// __block_39
  end
  3'b100: begin
// __block_40_case
// __block_41
_d_r = _w_a^_w_b;
// __block_42
  end
  3'b110: begin
// __block_43_case
// __block_44
_d_r = _w_a|_w_b;
// __block_45
  end
  3'b111: begin
// __block_46_case
// __block_47
_d_r = _w_a&_w_b;
// __block_48
  end
  3'b001: begin
// __block_49_case
// __block_50
_d_r = _w_a;
_d_shamt = $unsigned(_w_b[0+:5]);
_d_signed = in_select2;
_d_dir = 0;
// __block_51
  end
  3'b101: begin
// __block_52_case
// __block_53
_d_r = _w_a;
_d_shamt = $unsigned(_w_b[0+:5]);
_d_signed = in_select2;
_d_dir = 1;
// __block_54
  end
endcase
// __block_9
// __block_55
end else begin
// __block_7
end
// __block_56
// __block_57
end
// __block_58
_d_working = (_d_shamt>0);
end
endmodule


module M_intcmp (
in_a,
in_b,
in_select,
in_enable,
out_j,
out_clock,
clock
);
input signed [31:0] in_a;
input signed [31:0] in_b;
input  [2:0] in_select;
input  [0:0] in_enable;
output  [0:0] out_j;
output out_clock;
input clock;
assign out_clock = clock;
reg  [0:0] _t_j;

assign out_j = _t_j;

always @(posedge clock) begin
end




always @* begin
_t_j = 0;
// _always_pre
  case (in_select)
  3'b000: begin
// __block_2_case
// __block_3
_t_j = in_enable&(in_a==in_b);
// __block_4
  end
  3'b001: begin
// __block_5_case
// __block_6
_t_j = in_enable&(in_a!=in_b);
// __block_7
  end
  3'b100: begin
// __block_8_case
// __block_9
_t_j = in_enable&($signed(in_a)<$signed(in_b));
// __block_10
  end
  3'b110: begin
// __block_11_case
// __block_12
_t_j = in_enable&($unsigned(in_a)<$unsigned(in_b));
// __block_13
  end
  3'b101: begin
// __block_14_case
// __block_15
_t_j = in_enable&($signed(in_a)>=$signed(in_b));
// __block_16
  end
  3'b111: begin
// __block_17_case
// __block_18
_t_j = in_enable&($unsigned(in_a)>=$unsigned(in_b));
// __block_19
  end
  default: begin
// __block_20_case
// __block_21
_t_j = 0;
// __block_22
  end
endcase
// __block_1
end
endmodule

