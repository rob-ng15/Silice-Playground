// TRANSLATE PS/2 KEYCODES TO ASCII FOR BUFFERING
algorithm ps2ascii(
    input   uint1   us2_bd_dp,
    input   uint1   us2_bd_dn,
    output  uint8   ascii,
    output  uint1   asciivalid
) <autorun> {
    uint8   newascii = 8hff;
    uint1   lctrl = 0;
    uint1   rctrl = 0;
    uint1   lshift = 0;
    uint1   rshift = 0;

    uint1   startbreak = 0;
    uint1   startmulti = 0;

    // PS2 KEYBOARD CODE READER
    uint8   ps2keycode = uninitialised;
    uint1   ps2valid = uninitialised;
    ps2 PS2(
        ps2clk_ext <: us2_bd_dp,
        ps2data_ext <: us2_bd_dn,
        data :> ps2keycode,
        valid :> ps2valid,
    );

    asciivalid := 0;

    while(1) {
        while( ~ps2valid ) {
            switch( ps2keycode ) {
                case 8he0: { startmulti = 1; }
                case 8hf0: { startbreak = 1; }
                default: {
                    switch( { startmulti, startbreak } ) {
                        case 2b00: {
                            // KEY PRESS - TRANSLATE TO ASCII
                            if( lctrl | rctrl ) {
                                // CONTROL KEY PRESSED
                                switch( ps2keycode ) {
                                    case 8h1e: { newascii = 8h00; }
                                    case 8h1c: { newascii = 8h01; }
                                    case 8h32: { newascii = 8h02; }
                                    case 8h21: { newascii = 8h03; }
                                    case 8h23: { newascii = 8h04; }
                                    case 8h24: { newascii = 8h05; }
                                    case 8h2b: { newascii = 8h06; }
                                    case 8h34: { newascii = 8h07; }
                                    case 8h33: { newascii = 8h08; }
                                    case 8h43: { newascii = 8h09; }
                                    case 8h3b: { newascii = 8h0a; }
                                    case 8h42: { newascii = 8h0b; }
                                    case 8h4b: { newascii = 8h0c; }
                                    case 8h3a: { newascii = 8h0d; }
                                    case 8h31: { newascii = 8h0e; }
                                    case 8h44: { newascii = 8h0f; }
                                    case 8h4d: { newascii = 8h10; }
                                    case 8h15: { newascii = 8h11; }
                                    case 8h2d: { newascii = 8h12; }
                                    case 8h1b: { newascii = 8h13; }
                                    case 8h2c: { newascii = 8h14; }
                                    case 8h3c: { newascii = 8h15; }
                                    case 8h2a: { newascii = 8h16; }
                                    case 8h1d: { newascii = 8h17; }
                                    case 8h22: { newascii = 8h18; }
                                    case 8h35: { newascii = 8h19; }
                                    case 8h1a: { newascii = 8h1a; }
                                    case 8h54: { newascii = 8h1b; }
                                    case 8h5d: { newascii = 8h1c; }
                                    case 8h5b: { newascii = 8h1d; }
                                    case 8h36: { newascii = 8h1e; }
                                    case 8h4e: { newascii = 8h1f; }
                                    case 8h4a: { newascii = 8h7f; }
                                    default: { newascii = 8hff; }
                                }
                            } else {
                                switch( ps2keycode ) {
                                    case 8h29: { newascii = 8h20; }
                                    case 8h66: { newascii = 8h08; }
                                    case 8h0d: { newascii = 8h09; }
                                    case 8h5a: { newascii = 8h0d; }
                                    case 8h76: { newascii = 8h1b; }
                                    default: {
                                        // INTERPRET SHIFT
                                        switch( lshift | rshift ) {
                                            case 0: {
                                                switch( ps2keycode ) {
                                                    case 8h1c: { newascii = 8h61; }
                                                    case 8h32: { newascii = 8h62; }
                                                    case 8h21: { newascii = 8h63; }
                                                    case 8h23: { newascii = 8h64; }
                                                    case 8h24: { newascii = 8h65; }
                                                    case 8h2b: { newascii = 8h66; }
                                                    case 8h34: { newascii = 8h67; }
                                                    case 8h33: { newascii = 8h68; }
                                                    case 8h43: { newascii = 8h69; }
                                                    case 8h3b: { newascii = 8h6a; }
                                                    case 8h42: { newascii = 8h6b; }
                                                    case 8h4b: { newascii = 8h6c; }
                                                    case 8h3a: { newascii = 8h6d; }
                                                    case 8h31: { newascii = 8h6e; }
                                                    case 8h44: { newascii = 8h6f; }
                                                    case 8h4d: { newascii = 8h70; }
                                                    case 8h15: { newascii = 8h71; }
                                                    case 8h2d: { newascii = 8h72; }
                                                    case 8h1b: { newascii = 8h73; }
                                                    case 8h2c: { newascii = 8h74; }
                                                    case 8h3c: { newascii = 8h75; }
                                                    case 8h2a: { newascii = 8h76; }
                                                    case 8h1d: { newascii = 8h77; }
                                                    case 8h22: { newascii = 8h78; }
                                                    case 8h35: { newascii = 8h79; }
                                                    case 8h1a: { newascii = 8h7a; }
                                                    case 8h16: { newascii = 8h21; }
                                                    case 8h52: { newascii = 8h22; }
                                                    case 8h26: { newascii = 8h23; }
                                                    case 8h25: { newascii = 8h24; }
                                                    case 8h2e: { newascii = 8h25; }
                                                    case 8h3d: { newascii = 8h26; }
                                                    case 8h46: { newascii = 8h28; }
                                                    case 8h45: { newascii = 8h29; }
                                                    case 8h3e: { newascii = 8h2a; }
                                                    case 8h55: { newascii = 8h2b; }
                                                    case 8h4c: { newascii = 8h3a; }
                                                    case 8h41: { newascii = 8h3c; }
                                                    case 8h49: { newascii = 8h3e; }
                                                    case 8h4a: { newascii = 8h3f; }
                                                    case 8h1e: { newascii = 8h40; }
                                                    case 8h36: { newascii = 8h5e; }
                                                    case 8h4e: { newascii = 8h5f; }
                                                    case 8h54: { newascii = 8h7b; }
                                                    case 8h5d: { newascii = 8h7c; }
                                                    case 8h5b: { newascii = 8h7d; }
                                                    case 8h0e: { newascii = 8h7e; }
                                                    default: { newascii = 8hff; }
                                                 }
                                            }
                                            case 1: {
                                                switch( ps2keycode ) {
                                                    case 8h1c: { newascii = 8h41; }
                                                    case 8h32: { newascii = 8h42; }
                                                    case 8h21: { newascii = 8h43; }
                                                    case 8h23: { newascii = 8h44; }
                                                    case 8h24: { newascii = 8h45; }
                                                    case 8h2b: { newascii = 8h46; }
                                                    case 8h34: { newascii = 8h47; }
                                                    case 8h33: { newascii = 8h48; }
                                                    case 8h43: { newascii = 8h49; }
                                                    case 8h3b: { newascii = 8h4a; }
                                                    case 8h42: { newascii = 8h4b; }
                                                    case 8h4b: { newascii = 8h4c; }
                                                    case 8h3a: { newascii = 8h4d; }
                                                    case 8h31: { newascii = 8h4e; }
                                                    case 8h44: { newascii = 8h4f; }
                                                    case 8h4d: { newascii = 8h50; }
                                                    case 8h15: { newascii = 8h51; }
                                                    case 8h2d: { newascii = 8h52; }
                                                    case 8h1b: { newascii = 8h53; }
                                                    case 8h2c: { newascii = 8h54; }
                                                    case 8h3c: { newascii = 8h55; }
                                                    case 8h2a: { newascii = 8h56; }
                                                    case 8h1d: { newascii = 8h57; }
                                                    case 8h22: { newascii = 8h58; }
                                                    case 8h35: { newascii = 8h59; }
                                                    case 8h1a: { newascii = 8h5a; }
                                                    case 8h45: { newascii = 8h30; }
                                                    case 8h16: { newascii = 8h31; }
                                                    case 8h1e: { newascii = 8h32; }
                                                    case 8h26: { newascii = 8h33; }
                                                    case 8h25: { newascii = 8h34; }
                                                    case 8h2e: { newascii = 8h35; }
                                                    case 8h36: { newascii = 8h36; }
                                                    case 8h3d: { newascii = 8h37; }
                                                    case 8h3e: { newascii = 8h38; }
                                                    case 8h46: { newascii = 8h39; }
                                                    case 8h52: { newascii = 8h27; }
                                                    case 8h41: { newascii = 8h2c; }
                                                    case 8h4e: { newascii = 8h2d; }
                                                    case 8h49: { newascii = 8h2e; }
                                                    case 8h4a: { newascii = 8h2f; }
                                                    case 8h4c: { newascii = 8h3b; }
                                                    case 8h55: { newascii = 8h3d; }
                                                    case 8h54: { newascii = 8h5b; }
                                                    case 8h5d: { newascii = 8h5c; }
                                                    case 8h5b: { newascii = 8h5d; }
                                                    case 8h0e: { newascii = 8h60; }
                                                    default: { newascii = 8hff; }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        case 2b01: {
                            // KEY RELEASE - SINGLE
                            startbreak = 0;
                        }
                        case 2b10: {
                            // MULTICODE KEY PRESS
                            if( ps2keycode == 8hf0 ) {
                                startbreak = 1;
                            } else {
                            }
                        }
                        case 2b11: {
                            // MULTICODE KEY RELEASE
                            startmulti = 0; startbreak = 0;
                        }
                    }
                }
            }

            // NEW KEYCODE RECEIVED
            if( newascii != 8hff ) {
                ascii = newascii;
                asciivalid = 1;
            }
        }
    }
}

// PS/2 PORT - READS KEYCODE FROM PS/2 KEYBOARD
// MODIFIED FROM ORIGINAL CODE https://github.com/hoglet67/Ice40Beeb converted to Silice by @lawrie
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
