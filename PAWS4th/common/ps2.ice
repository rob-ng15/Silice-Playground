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
    uint1   lshift = 0;
    uint1   rshift = 0;
    uint1   capslock = 0;

    uint1   startbreak = 0;
    uint1   startmulti = 0;

    uint1   CTRL = uninitialised;
    uint1   SHIFT = uninitialised;
    uint1   CAPITAL = uninitialised;

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
        switch( { ps2valid, LATCHvalid } ) {
            case 2b10: {
                newascii = 8hff;
                switch( ps2keycode ) {
                    case 8he0: { startmulti = 1; }
                    case 8hf0: { startbreak = 1; }
                    default: {
                        switch( { startmulti, startbreak } ) {
                            case 2b00: {
                                // KEY PRESS - TRANSLATE TO ASCII
                                CTRL = lctrl | rctrl;
                                SHIFT = lshift | rshift;
                                CAPITAL = lshift | rshift | capslock;
                                switch( ps2keycode ) {
                                    case 8h1c: { newascii = CTRL ? 8h01 : CAPITAL ? 8h41 : 8h61; }  // A to Z
                                    case 8h32: { newascii = CTRL ? 8h02 : CAPITAL ? 8h42 : 8h62; }
                                    case 8h21: { newascii = CTRL ? 8h03 : CAPITAL ? 8h43 : 8h63; }
                                    case 8h23: { newascii = CTRL ? 8h04 : CAPITAL ? 8h44 : 8h64; }
                                    case 8h24: { newascii = CTRL ? 8h05 : CAPITAL ? 8h45 : 8h65; }
                                    case 8h2b: { newascii = CTRL ? 8h06 : CAPITAL ? 8h46 : 8h66; }
                                    case 8h34: { newascii = CTRL ? 8h07 : CAPITAL ? 8h47 : 8h67; }
                                    case 8h33: { newascii = CTRL ? 8h08 : CAPITAL ? 8h48 : 8h68; }
                                    case 8h43: { newascii = CTRL ? 8h09 : CAPITAL ? 8h49 : 8h69; }
                                    case 8h3b: { newascii = CTRL ? 8h0a : CAPITAL ? 8h4a : 8h6a; }
                                    case 8h42: { newascii = CTRL ? 8h0b : CAPITAL ? 8h4b : 8h6b; }
                                    case 8h4b: { newascii = CTRL ? 8h0c : CAPITAL ? 8h4c : 8h6c; }
                                    case 8h3a: { newascii = CTRL ? 8h0d : CAPITAL ? 8h4d : 8h6d; }
                                    case 8h31: { newascii = CTRL ? 8h0e : CAPITAL ? 8h4e : 8h6e; }
                                    case 8h44: { newascii = CTRL ? 8h0f : CAPITAL ? 8h4f : 8h6f; }
                                    case 8h4d: { newascii = CTRL ? 8h10 : CAPITAL ? 8h50 : 8h70; }
                                    case 8h15: { newascii = CTRL ? 8h11 : CAPITAL ? 8h51 : 8h71; }
                                    case 8h2d: { newascii = CTRL ? 8h12 : CAPITAL ? 8h52 : 8h72; }
                                    case 8h1b: { newascii = CTRL ? 8h13 : CAPITAL ? 8h53 : 8h73; }
                                    case 8h2c: { newascii = CTRL ? 8h14 : CAPITAL ? 8h54 : 8h74; }
                                    case 8h3c: { newascii = CTRL ? 8h15 : CAPITAL ? 8h55 : 8h75; }
                                    case 8h2a: { newascii = CTRL ? 8h16 : CAPITAL ? 8h56 : 8h76; }
                                    case 8h1d: { newascii = CTRL ? 8h17 : CAPITAL ? 8h57 : 8h77; }
                                    case 8h22: { newascii = CTRL ? 8h18 : CAPITAL ? 8h58 : 8h78; }
                                    case 8h35: { newascii = CTRL ? 8h19 : CAPITAL ? 8h59 : 8h79; }
                                    case 8h1a: { newascii = CTRL ? 8h1a : CAPITAL ? 8h5a : 8h7a; }
                                    case 8h54: { newascii = CTRL ? 8h1b : SHIFT ? 8h7b : 8h5b; }    // [ {
                                    case 8h5d: { newascii = CTRL ? 8h1c : SHIFT ? 8h7e : 8h23; }    // # ~
                                    case 8h5b: { newascii = CTRL ? 8h1d : SHIFT ? 8h7d : 8h5d; }    // ] }
                                    case 8h4e: { newascii = SHIFT ? 8h5f : 8h2d; }                  // - _
                                    case 8h55: { newascii = SHIFT ? 8h2b : 8h3d; }                  // + =
                                    case 8h4c: { newascii = SHIFT ? 8h3a : 8h3b; }                  // ; :
                                    case 8h52: { newascii = SHIFT ? 8h40 : 8h27; }                  // ' @
                                    case 8h41: { newascii = SHIFT ? 8h3c : 8h2c; }                  // , >
                                    case 8h49: { newascii = SHIFT ? 8h3e : 8h2e; }                  // . >
                                    case 8h4a: { newascii = SHIFT ? 8h3f : 8h2f; }                  // / ?
                                    case 8h16: { newascii = SHIFT ? 8h21 : 8h31; }                  // 1 to 0
                                    case 8h1e: { newascii = SHIFT ? 8h22 : 8h32; }
                                    case 8h26: { newascii = SHIFT ? 8ha3 : 8h33; }
                                    case 8h25: { newascii = SHIFT ? 8h24 : 8h34; }
                                    case 8h2e: { newascii = SHIFT ? 8h25 : 8h35; }
                                    case 8h36: { newascii = SHIFT ? 8h5e : 8h36; }
                                    case 8h3d: { newascii = SHIFT ? 8h26 : 8h37; }
                                    case 8h3e: { newascii = SHIFT ? 8h2a : 8h38; }
                                    case 8h46: { newascii = SHIFT ? 8h28 : 8h39; }
                                    case 8h45: { newascii = SHIFT ? 8h29 : 8h30; }
                                    case 8h58: { capslock = 1; }
                                    case 8h12: { lshift = 1; }
                                    case 8h59: { rshift = 1; }
                                    case 8h14: { lctrl = 1; }
                                    case 8h29: { newascii = 8h20; }                                 // SPACE
                                    case 8h66: { newascii = 8h08; }                                 // BACKSPACE
                                    case 8h5a: { newascii = 8h0d; }                                 // ENTER
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
                                    case 8h14: { rctrl = 1; }
                                    default: {}
                                }
                            }
                            case 2b11: {
                                // MULTICODE KEY RELEASE
                                switch( ps2keycode ) {
                                    case 8h14: { rctrl = 0; }
                                    default: {}
                                }
                                startmulti = 0; startbreak = 0;
                            }
                        }
                    }
                }

                // NEW KEYCODE RECEIVED
                switch( newascii ) {
                    case 8hff: {}
                    default: { ascii = newascii; asciivalid = 1; }
                }
            }
            default: {}
        }
        LATCHvalid = ps2valid;
    }
}

// PS/2 PORT - READS KEYCODE FROM PS/2 KEYBOARD
// MODIFIED FROM ORIGINAL CODE https://github.com/hoglet67/Ice40Beeb converted to Silice by @lawrie, optimised and simplified by @rob-ng15
algorithm ps2(
    input   uint1   ps2data_ext,
    input   uint1   ps2clk_ext,
    output  uint1   valid,
    output  uint1   error,
    output  uint8   data
) < autorun> {
    uint8 clk_filter = 8b11111111;
    uint1 ps2_clk_in = 1;
    //uint1 ps2data_ext = 1;
    uint1 clk_edge = 0;

    uint4 bit_count = 0;
    uint9 shift_reg = 0;
    uint1 parity = 0;

    valid := 0;
    error := 0;

    while(1) {
        // Filter the PS/2 clock
        clk_edge = 0;
        clk_filter = { ps2clk_ext, clk_filter[1,7] };

        switch( clk_filter ) {
            case 8hf0: { ps2_clk_in = 1; }
            case 8h0f: {
                if( ps2_clk_in ) {
                    clk_edge = 1;
                }
                ps2_clk_in = 0;
            }
            default: {}
        }

        switch( clk_edge ) {
            case 1: {
                switch( bit_count ) {
                    case 0: {
                        parity = 0;
                        //bit_count = bit_count + ( ~ps2data_ext );
                        switch( ps2data_ext ) {
                            case 1: {}
                            case 0: { bit_count = bit_count + 1; } // Start bit
                        }
                        //if (!ps2data_ext) {
                        //    bit_count = bit_count + 1; // Start bit
                        //}
                    }
                    default: {
                        bit_count = bit_count + 1;
                        shift_reg = { ps2data_ext, shift_reg[1,8] };
                        parity = parity ^ ps2data_ext;
                    }
                    case 10: {
                        switch( ps2data_ext ) {
                            case 1: {
                                bit_count = 0;
                                switch( parity ) {
                                    case 1: {
                                        data = shift_reg[0,8];
                                        valid = 1;
                                    }
                                    case 0: {
                                        error = 1;
                                    }
                                }
                            }
                            case 0: {
                                error = 1;
                                bit_count = 0;
                            }
                        }
                    }
                }
            }
            default: {}
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
