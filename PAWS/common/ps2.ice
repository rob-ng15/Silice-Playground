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
