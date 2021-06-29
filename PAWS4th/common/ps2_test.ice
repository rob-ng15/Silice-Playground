// TRANSLATE PS/2 KEYCODES TO ASCII FOR BUFFERING
algorithm ps2ascii(
    input   uint1   clock_25mhz,
    input   uint1   us2_bd_dp,
    input   uint1   us2_bd_dn,
    output  uint8   ascii,
    output  uint1   asciivalid
) <autorun> {
    uint1   LATCHvalid = 0;
    uint8   newascii = 8hff;

    uint1   lctrl = 0;
    uint1   rctrl = 0;
    uint1   ctrl <: lctrl | rctrl;

    uint1   lshift = 0;
    uint1   rshift = 0;
    uint1   shift <: lshift | rshift;

    uint1   capslock = 0;

    uint1   startbreak = 0;
    uint1   startmulti = 0;

    // PS2 KEYBOARD CODE READER
    uint8   ps2keycode = uninitialised;
    uint1   ps2valid = uninitialised;
    ps2 PS2 <@clock_25mhz> (
        ps2clk_ext <: us2_bd_dp,
        ps2data_ext <: us2_bd_dn,
        data :> ps2keycode,
        valid :> ps2valid,
    );

    asciivalid := 0;

    while(1) {
        newascii = 8hff;
        if( ps2valid  && ~LATCHvalid ) {
            switch( ps2keycode ) {
                case 8he0: { startmulti = 1; }
                case 8hf0: { startbreak = 1; }
                default: {
                    switch( { startmulti, startbreak } ) {
                        case 2b00: {
                            switch( ps2keycode ) {
                                case 8h1c: { newascii = ctrl ? 8h01 : shift ? 8h41 : 8h61; } // A
                                case 8h32: { newascii = ctrl ? 8h02 : shift ? 8h42 : 8h62; } // B
                                case 8h21: { newascii = ctrl ? 8h03 : shift ? 8h43 : 8h63; } // C
                                case 8h23: { newascii = ctrl ? 8h04 : shift ? 8h44 : 8h64; } // D
                                case 8h24: { newascii = ctrl ? 8h05 : shift ? 8h45 : 8h65; } // E
                                case 8h2b: { newascii = ctrl ? 8h06 : shift ? 8h46 : 8h66; } // F
                                case 8h34: { newascii = ctrl ? 8h07 : shift ? 8h47 : 8h67; } // G
                                case 8h33: { newascii = ctrl ? 8h08 : shift ? 8h48 : 8h68; } // H
                                case 8h43: { newascii = ctrl ? 8h09 : shift ? 8h49 : 8h69; } // I
                                case 8h3b: { newascii = ctrl ? 8h0a : shift ? 8h4a : 8h6a; } // J
                                case 8h42: { newascii = ctrl ? 8h0b : shift ? 8h4b : 8h6b; } // K
                                case 8h4b: { newascii = ctrl ? 8h0c : shift ? 8h4c : 8h6c; } // L
                                case 8h3a: { newascii = ctrl ? 8h0d : shift ? 8h4d : 8h6d; } // M
                                case 8h31: { newascii = ctrl ? 8h0e : shift ? 8h4e : 8h6e; } // N
                                case 8h44: { newascii = ctrl ? 8h0f : shift ? 8h4f : 8h6f; } // O
                                case 8h4d: { newascii = ctrl ? 8h10 : shift ? 8h50 : 8h70; } // P
                                case 8h15: { newascii = ctrl ? 8h11 : shift ? 8h51 : 8h71; } // Q
                                case 8h2d: { newascii = ctrl ? 8h12 : shift ? 8h52 : 8h72; } // R
                                case 8h1b: { newascii = ctrl ? 8h13 : shift ? 8h53 : 8h73; } // S
                                case 8h2c: { newascii = ctrl ? 8h14 : shift ? 8h54 : 8h74; } // T
                                case 8h3c: { newascii = ctrl ? 8h15 : shift ? 8h55 : 8h75; } // U
                                case 8h2a: { newascii = ctrl ? 8h16 : shift ? 8h56 : 8h76; } // V
                                case 8h1d: { newascii = ctrl ? 8h17 : shift ? 8h57 : 8h77; } // W
                                case 8h22: { newascii = ctrl ? 8h18 : shift ? 8h58 : 8h78; } // X
                                case 8h35: { newascii = ctrl ? 8h19 : shift ? 8h59 : 8h79; } // Y
                                case 8h1a: { newascii = ctrl ? 8h1a : shift ? 8h5a : 8h7a; } // Z
                                case 8h0e: { newascii = shift ? 8hac : 8h60; } // ` ¬
                                case 8h16: { newascii = shift ? 8h21 : 8h31; } // 1
                                case 8h1e: { newascii = shift ? 8h22 : 8h32; } // 2
                                case 8h26: { newascii = shift ? 8ha3 : 8h33; } // 3
                                case 8h25: { newascii = shift ? 8h24 : 8h34; } // 4
                                case 8h2e: { newascii = shift ? 8h25 : 8h35; } // 5
                                case 8h36: { newascii = shift ? 8h5e : 8h36; } // 6
                                case 8h3d: { newascii = shift ? 8h26 : 8h37; } // 7
                                case 8h3e: { newascii = shift ? 8h2a : 8h38; } // 8
                                case 8h46: { newascii = shift ? 8h28 : 8h39; } // 9
                                case 8h45: { newascii = shift ? 8h29 : 8h30; } // 0
                                case 8h4e: { newascii = shift ? 8h2d : 8h5f; } // - _
                                case 8h55: { newascii = shift ? 8h2b : 8h3d; } // = +
                                case 8h54: { newascii = ctrl ? 8h1b : shift ? 8h7b : 8h5b; } // [ {
                                case 8h5d: { newascii = ctrl ? 8h1c : shift ? 8h7c : 8h5c; } // reverse slash |
                                case 8h5b: { newascii = ctrl ? 8h1d : shift ? 8h7d : 8h5d; } // ] }
                                case 8h4c: { newascii = shift ? 8h3a : 8h3b; } // ; :
                                case 8h52: { newascii = shift ? 8h40 : 8h27; } // ' @
                                // case : { newascii = shift ? 8h7e : 8h23; } // # ~
                                case 8h41: { newascii = shift ? 8h3c : 8h2c; } // , <
                                case 8h49: { newascii = shift ? 8h3e : 8h2c; } // . >
                                case 8h4a: { newascii = shift ? 8h3f : 8h2f; } // / ?
                                case 8h66: { newascii = 8h08; } // BACKSPACE
                                case 8h5a: { newascii = 8h0d; } // ENTER
                                case 8h76: { newascii = 8h1b; } // ESCAPE
                                case 8h0d: { newascii = 8h08; } // TAB
                                case 8h29: { newascii = 8h20; } // SPACE
                                case 8h58: { capslock = 1; }
                                case 8h12: { lshift = 1; }
                                case 8h59: { rshift = 1; }
                                case 8h11: { lctrl = 1; }
                                case 8h58: { rctrl = 1; }
                                default: {}
                            }
                        }
                        case 2b01: {
                            // KEY RELEASE - SINGLE
                            switch( ps2keycode ) {
                                case 8h58: { capslock = 0; }
                                case 8h12: { lshift = 0; }
                                case 8h59: { rshift = 0; }
                                case 8h11: { lctrl = 0; }
                                case 8h58: { rctrl = 0; }
                                default: {}
                            }
                            startbreak = 0;
                        }
                        case 2b10: {
                            // MULTICODE KEY PRESS
                            switch( ps2keycode ) {
                                case 8hf0: { startbreak = 1; }
                                case 8h5a: { newascii = 8h0d; }
                                case 8h7a: { newascii = 8h08; }
                                default: {}
                            }
                        }
                        case 2b11: {
                            // MULTICODE KEY RELEASE
                            startmulti = 0; startbreak = 0;
                        }
                    }
                }
            }
        }

        // NEW KEYCODE RECEIVED
        if( newascii != 8hff) {
             ascii = newascii; asciivalid = 1;
        }

        LATCHvalid = ps2valid;
    }
}

// PS/2 PORT - READS KEYCODE FROM PS/2 KEYBOARD
// MODIFIED FROM ORIGINAL CODE https://github.com/hoglet67/Ice40Beeb converted to Silice by @lawrie, simplified by @rob-ng15
algorithm ps2(
    input   uint1   ps2data_ext,
    input   uint1   ps2clk_ext,
    output  uint1   valid,
    output  uint1   error,
    output  uint8   data
) < autorun> {
    uint8 clk_filter = 8hff;
    uint1 ps2_clk_in = 1;
    uint1 ps2_dat_in = 1;
    uint1 clk_edge = 0;

    uint4 bit_count = 0;
    uint9 shift_reg = 0;
    uint1 parity = 0;

    valid := 0;
    error := 0;

    while(1) {
        // Filter the PS/2 clock
        ps2_dat_in = ps2data_ext;
        clk_edge = 0;
        clk_filter = {ps2clk_ext, clk_filter[1,7]};

        if (clk_filter == 8hff) {
            ps2_clk_in = 1;
        } else {
            if (clk_filter == 0) {
                if (ps2_clk_in) {
                    clk_edge = 1;
                }
                ps2_clk_in = 0;
            }
        }

        // Shift in the data
        valid = 0;
        error = 0;

        if (clk_edge) {
            if (bit_count == 0) {
                parity = 0;
                if (!ps2_dat_in) {
                    bit_count = bit_count + 1; // Start bit
                }
            } else {
                if (bit_count < 10) {
                    bit_count = bit_count + 1;
                    shift_reg = {ps2_dat_in, shift_reg[1,8]};
                    parity = parity ^ ps2_dat_in;
                } else {
                    if (ps2_dat_in) {
                        bit_count = 0;
                        if (parity) {
                            data = shift_reg[0,8];
                            valid = 1;
                        } else {
                            error = 1;
                        }
                    } else {
                        error = 1;
                        bit_count = 0;
                    }
                }
            }
        }
    }
}

//  ZX Spectrum for Altera DE1
//
//  Copyright (c) 2009-2011 Mike Stirling
//
//  All rights reserved
//
//  Redistribution and use in source and synthezised forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//  * Redistributions in synthesized form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
//  * Neither the name of the author nor the names of other contributors may
//    be used to endorse or promote products derived from this software without
//    specific prior written agreement from the author.
//
//  * License is granted for non-commercial use only.  A fee may not be charged
//    for redistributions as source code or in synthesized/hardware form without
//    specific prior written agreement from the author.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  PS/2 interface (input only)
//  Based loosely on ps2_ctrl.vhd (c) ALSE. http://www.alse-fr.com
