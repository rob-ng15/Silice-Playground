/**
 * PLL configuration
 *
 * This Verilog module was generated automatically
 * using the icepll tool from the IceStorm project.
 * Use at your own risk.
 *
 * Given input frequency:        12.000 MHz
 * Requested output frequency:   48.000 MHz
 * Achieved output frequency:    48.000 MHz
 */

module pll(
	input  clock_in,
	output clock_usb,
	output locked
	);
wire        g_clock_int;

SB_PLL40_CORE #(
		.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b0111111),	// DIVF = 63
		.DIVQ(3'b100),		// DIVQ =  4
		.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
	) uut (
		.LOCK(locked),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.REFERENCECLK(clock_in),
		.PLLOUTCORE(g_clock_int)
		);

SB_GB sbGlobalBuffer_inst(
    .USER_SIGNAL_TO_GLOBAL_BUFFER(g_clock_int),
    .GLOBAL_BUFFER_OUTPUT(clock_usb)
    );

endmodule
