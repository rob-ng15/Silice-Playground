// VGA Driver Includes
$include('common/vga.ice')

import('common/de10nano_clk_100_25.v')
import('common/reset_conditioner.v')

append('jamieilesUART/baud_rate_gen.v')
append('jamieilesUART/receiver.v')
append('jamieilesUART/transmitter.v')
import('jamieilesUART/uart.v')

algorithm multiplex_display(
    input   uint10 pix_x,
    input   uint10 pix_y,
    input   uint1  pix_active,
    input   uint1  pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,

    // GPU to SET pixels
    input uint10 gpu_x,
    input uint9 gpu_y,
    input uint16 gpu_param0,
    input uint16 gpu_param1,
    input uint16 gpu_param2,
    input uint16 gpu_param3,
    input uint8 gpu_colour,
    input uint2 gpu_write,
    output uint8 gpu_active,
    
    // TPU to SET characters, background, foreground
    input uint7 tpu_x,
    input uint5 tpu_y,
    input uint8 tpu_set,
    input uint2 tpu_write,   // 0 = nothing, 1 = char, 2 = background, 3 = foreground
    
    // Terminal show/hide and cursor show/hide
    input uint8 terminal_character,
    input uint1 terminal_write, // 0 = noting, 1 = character
    input uint1 showterminal,
    input uint1 showcursor,
    input uint1 timer1hz,
    output uint3 terminal_active
) <autorun> {

    // Character ROM 8x16
    uint8 characterGenerator8x16[] = {
        $include('characterROM8x16.inc')
    };
    
    // Character ROM 8x8
    uint8 characterGenerator8x8[] = {
        $include('characterROM8x8.inc')
    };

    // 80 x 30 character buffer and foreground and background colours in { rrrgggbb }
    // Setting character to 0 allows the bitmap to show through
    dualport_bram uint8 character[2400] = uninitialized;
    dualport_bram uint8 foreground[2400] = uninitialized;
    dualport_bram uint8 background[2400] = uninitialized;
   

    // Character position on the screen x 0-79, y 0-29 * 80 ( fetch it one pixel ahead of the actual x pixel, so it is always ready )
    uint8 xcharacterpos := (pix_x+1) >> 3;
    uint12 ycharacterpos := ((pix_y) >> 4) * 80; // 16 pixel high characters
    
    // Derive the x and y coordinate within the current 8x16 character block x 0-7, y 0-15
    uint8 xincharacter := (pix_x) & 7;
    uint8 yincharacter := (pix_y) & 15;

    // Derive the actual pixel in the current character
    uint1 characterpixel := ((characterGenerator8x16[ character.rdata0 * 16 + yincharacter ] << xincharacter) >> 7) & 1;
    
    // 80 x 4 character buffer for the input/output terminal
    dualport_bram uint8 terminal[640] = uninitialized;

    uint8 terminal_x = 0;
    uint8 terminal_y = 7;

    // Character position on the terminal x 0-79, y 0-3 * 80 ( fetch it one pixel ahead of the actual x pixel, so it is always ready )
    uint8 xterminalpos := (pix_x+1) >> 3;
    uint12 yterminalpos := ((pix_y - 416) >> 3) * 80; // 8 pixel high characters

    uint1 is_cursor := ( xterminalpos == terminal_x ) & ( ( ( pix_y - 416) >> 3 ) == terminal_y );
    
    // Derive the x and y coordinate within the current 8x8 terminal character block x 0-7, y 0-7
    uint8 xinterminal := (pix_x) & 7;
    uint8 yinterminal := (pix_y) & 7;

    // Derive the actual pixel in the current terminal
    uint1 terminalpixel := ((characterGenerator8x8[ terminal.rdata0 * 8 + yinterminal ] << xinterminal) >> 7) & 1;

    // Terminal active (scroll) flag
    uint10 terminal_scroll = 0;
    uint10 terminal_scroll_next = 0;
    
    // 640 x 480 { rrrgggbb } colour bitmap
    dualport_bram uint8 bitmap[ 307200 ] = uninitialized;

    // Expansion map for { rrr } to { rrrrrr }, { ggg } to { gggggg }, { bb } to { bbbbbb }
    uint6 colourexpand3to6[8] = {  0, 9, 18, 27, 36, 45, 54, 63 };
    uint6 colourexpand2to6[4] = {  0, 21, 42, 63 };
    
    // GPU work variable storage
    uint16 gpu_active_x = 0;
    uint16 gpu_active_y = 0;
    uint8 gpu_active_colour = 0;
    int16 gpu_temp0 = 0;
    int16 gpu_temp1 = 0;
    int16 gpu_temp2 = 0;
    int16 gpu_temp3 = 0;
    int16 gpu_temp4 = 0;
    int16 gpu_temp5 = 0;
    int16 gpu_temp6 = 0;
    int16 gpu_temp7 = 0;
    
    // RGB is { 0,  0, 0 } by default
    pix_red   := 0;
    pix_green := 0;
    pix_blue  := 0;
    
    // Setup the reading of the terminal memory
    terminal.addr0 := xterminalpos + yterminalpos;
    terminal.wenable0 := 0;
    
    // Set up reading of character and attribute memory
    // character.rdata0 is the character, foreground.rdata0 and background.rdata0 are the attribute being rendered
    character.addr0 := xcharacterpos + ycharacterpos;
    character.wenable0 := 0;
    foreground.addr0 := xcharacterpos + ycharacterpos;
    foreground.wenable0 := 0;
    background.addr0 := xcharacterpos + ycharacterpos;
    background.wenable0 := 0;

    // Setup the address in the bitmap for the pixel being rendered
    bitmap.addr0 := pix_x  + pix_y * 640;
    bitmap.wenable0 := 0;
    
    // Bitmap write access for the GPU
    bitmap.wenable1 := 0;

    // BRAM write access for the TPU 
    character.addr1 := tpu_x + tpu_y * 80;
    character.wenable1 := 0;
    background.addr1 := tpu_x + tpu_y * 80;
    background.wenable1 := 0;
    foreground.addr1 := tpu_x + tpu_y * 80;
    foreground.wenable1 := 0;

    // Terminal flags
    terminal.wenable1 := 0;
    terminal_active = 0;
    
    // GPU active flag
    gpu_active = 0;
      
    while (1) {
 
        // TPU to set characters according to TPU inputs
        switch( tpu_write ) {
            case 1: {
                character.wdata1 = tpu_set;
                character.wenable1 = 1;
            }
            case 2: {
                background.wdata1 = tpu_set;
                background.wenable1 = 1;
            }
            case 3: {
                foreground.wdata1 = tpu_set;
                foreground.wenable1 = 1;
            }
            default: {}
        }

        // Terminal
        if( terminal_active == 0 ) {
            switch( terminal_write ) {
                case 1: {
                    // Display character
                    switch( terminal_character ) {
                        case 8: {
                            // BACKSPACE, move back one character
                            if( terminal_x > 0 ) {
                                terminal_x = terminal_x - 1;
                                terminal.addr1 = terminal_x - 1 + terminal_y * 80;
                                terminal.wdata1 = 0;
                                terminal.wenable1 = 1;
                            }
                        }
                        case 10: {
                            // LINE FEED, scroll
                            terminal_scroll = 0;
                            terminal_active = 1;
                        }
                        case 13: {
                            // CARRIAGE RETURN
                            terminal_x = 0;
                        }
                        default: {
                            // Display character
                            terminal.addr1 = terminal_x + terminal_y * 80;
                            terminal.wdata1 = terminal_character;
                            terminal.wenable1 = 1;
                            if( terminal_x == 79 ) {
                                terminal_x = 0;
                                terminal_scroll = 0;
                                terminal_active = 1;
                            } else {
                                terminal_x = terminal_x + 1;
                            }
                        }
                    }
                }
                default: {}
            }
        } else {
            // Terminal actions
            switch( terminal_active ) {
                case 1: {
                    // SCROLL
                    if( terminal_scroll == 560 ) {
                        // Finished Scroll, Move to blank
                        terminal_active = 4;
                    } else {
                        // Read the next character down
                        terminal.addr1 = terminal_scroll + 80;
                        terminal_active = 2;
                    }
                }
                case 2: {
                    // Retrieve the character to move up
                    terminal_scroll_next = terminal.rdata1;
                    terminal_active = 3;
                }
                case 3: {
                    // Write the character one line up and move onto the next character
                    terminal.addr1 = terminal_scroll;
                    terminal.wdata1 = terminal_scroll_next;
                    terminal.wenable1 = 1;
                    terminal_scroll = terminal_scroll + 1;
                    terminal_active = 1;
                }
                case 4: {
                    // Blank out the last line
                    terminal.addr1 = terminal_scroll;
                    terminal.wdata1 = 0;
                    terminal.wenable1 = 1;
                    if( terminal_scroll == 640 ) {
                        // Finish Blank
                        terminal_active = 0;
                    } else {
                        terminal_scroll = terminal_scroll + 1;
                    }
                }
                default: {}
            }
        }
        
        // Perform GPU Operation
        // GPU functions 1 pixel per cycle, even during hblank and vblank
        switch( gpu_active ) {
            case 0: {
                // Setup GPU operation
                switch( gpu_write ) {
                    case 1: {
                        // Setup writing a pixel colour to x,y
                        gpu_active_colour = gpu_colour;
                        gpu_active_x = gpu_x;
                        gpu_active_y = gpu_y;
                        gpu_active = 1;
                    }
                    case 2: {
                        // Setup drawing a rectangle from x,y to param0, param1 in colour
                        // Ensures that works left to right, top to bottom
                        gpu_active_colour = gpu_colour;
                        gpu_active_x = ( gpu_x < gpu_param0 ) ? gpu_x : gpu_param0;                 // left
                        gpu_active_y = ( gpu_y < gpu_param1 ) ? gpu_y : gpu_param1;                 // top
                        gpu_temp0 = ( gpu_x < gpu_param0 ) ? gpu_x : gpu_param0;                    // left - for next line
                        gpu_temp2 = ( gpu_x < gpu_param0 ) ? gpu_param0 : gpu_x;                    // right - at end of line
                        gpu_temp3 = ( gpu_y < gpu_param1 ) ? gpu_param1 : gpu_y;                    // bottom - at end of rectangle
                        gpu_active = 2; 
                    }
                    case 3: {
                        // Setup drawing a line from x,y to param0, param1 in colour
                        // Ensure that works from left to right
                        gpu_active_colour = gpu_colour;
                        gpu_active_x = gpu_x;                                                   // left
                        gpu_active_y = gpu_y;                                                   // top
                        gpu_temp0 = gpu_param0;                                                 // right
                        gpu_temp1 = gpu_param1;
                        gpu_temp2 = gpu_param0 - gpu_x;                                         // Bresenham delta x
                        gpu_temp3 = gpu_param1 - gpu_y;                                         // Bresenham delta y
                        if( (gpu_param0 - gpu_x) >= (gpu_param1 - gpu_y) ) {
                            gpu_temp4 = 2 * ( ( gpu_param1 - gpu_y ) - ( gpu_param0 - gpu_x ) );   // Bresenham error
                            gpu_active = 3;
                        } else {
                            gpu_temp4 = 2 * ( ( gpu_param0 - gpu_x ) - ( gpu_param1 - gpu_y ) );   // Bresenham error
                            gpu_active = 4;
                        }
                     }
                    default: {}
                }
            }
            
            // Write colour to x,y
            case 1: {
                bitmap.addr1 = gpu_active_x + gpu_active_y * 640;
                bitmap.wdata1 = gpu_active_colour;
                bitmap.wenable1 = 1;
                gpu_active = 0;
            }
            case 2: {
                // Rectangle of colour at x,y top left to param0, param1 bottom right
                bitmap.addr1 = gpu_active_x + gpu_active_y * 640;
                bitmap.wdata1 = gpu_active_colour;
                bitmap.wenable1 = 1;
                
                if( gpu_active_x == gpu_temp2 ) {
                    // End of line
                    if( gpu_active_y == gpu_temp3 ) {
                        // Reached bottom right
                        gpu_active = 0;
                    } else {
                        // Next line
                        gpu_active_x = gpu_temp0;
                        gpu_active_y = gpu_active_y + 1;
                    }
                } else {
                    gpu_active_x = gpu_active_x + 1;
                }
            }
            case 3: {
                // Bresenham line drawing algorithm of colour from x,y to param0,param1 (shallow line)
                if( gpu_active_x < gpu_temp0 ) {
                    // Draw the pixel and calculate the next pixel
                    bitmap.addr1 = gpu_active_x + gpu_active_y * 640;
                    bitmap.wdata1 = gpu_active_colour;
                    bitmap.wenable1 = 1;
                    if( gpu_temp4 >= 0 ) {
                        gpu_active_y = gpu_active_y + 1;                                // Move Down
                        gpu_temp4 = gpu_temp4 + 2*gpu_temp3 - 2*gpu_temp2;              // New Bresenham error
                    } else {
                        gpu_temp4 = gpu_temp4 + 2*gpu_temp3;                            // New Bresenham error
                    }
                    gpu_active_x = gpu_active_x + 1;                                    // Move Right
                } else {
                    // Reached the end of the line
                    gpu_active = 0;
                }
            }
            case 4: {
                // Bresenham line drawing algorithm of colour from x,y to param0,param1 (steep line)
                if( gpu_active_y < gpu_temp1 ) {
                    // Draw the pixel and calculate the next pixel
                    bitmap.addr1 = gpu_active_x + gpu_active_y * 640;
                    bitmap.wdata1 = gpu_active_colour;
                    bitmap.wenable1 = 1;
                    if( gpu_temp4 >= 0 ) {
                        gpu_active_x = gpu_active_x + 1;                                // Move Down
                        gpu_temp4 = gpu_temp4 + 2*gpu_temp2 - 2*gpu_temp3;              // New Bresenham error
                    } else {
                        gpu_temp4 = gpu_temp4 + 2*gpu_temp2;                            // New Bresenham error
                    }
                    gpu_active_y = gpu_active_y + 1;                                    // Move Right
                } else {
                    // Reached the end of the line
                    gpu_active = 0;
                }
            }
            default: {gpu_active = 0;}
        }
        
        // wait until vblank is over
        if (pix_vblank == 0) {
            if( pix_active ) {
                if( pix_y > 415 & showterminal ) {
                    // Display terminal 
                    switch( terminalpixel ) {
                        case 0: {
                            if( is_cursor & timer1hz ) {
                                pix_red = 63;
                                pix_green = 63;
                                pix_blue = 63;
                            } else {
                                pix_red = 0;
                                pix_green = 0;
                                pix_blue = 63;
                            }
                        }
                        case 1: {
                            if( is_cursor & timer1hz ) {
                                pix_red = 0;
                                pix_green = 0;
                                pix_blue = 63;
                            } else {
                                pix_red = 63;
                                pix_green = 63;
                                pix_blue = 63;
                            }
                        }
                    }
                } else {
                    switch( character.rdata0 ) {
                        case 0: {
                            // BITMAP
                            pix_red = colourexpand3to6[ (bitmap.rdata0 & 8he0) >> 5 ];
                            pix_green = colourexpand3to6[ (bitmap.rdata0 & 8h1c) >> 2 ];
                            pix_blue = colourexpand2to6[ (bitmap.rdata0 & 8h3) ];
                        }
                        default: {
                            // CHARACTER from characterGenerator
                            // Determine if background or foreground
                            switch( characterpixel ) {
                            case 0: {
                                    // background
                                    pix_red = colourexpand3to6[ (background.rdata0 & 8he0) >> 5 ];
                                    pix_green = colourexpand3to6[ (background.rdata0 & 8h1c) >> 2 ];
                                    pix_blue = colourexpand2to6[ (background.rdata0 & 8h3) ];
                                }
                                case 1: {
                                    // foreground
                                    pix_red = colourexpand3to6[ (foreground.rdata0 & 8he0) >> 5 ];
                                    pix_green = colourexpand3to6[ (foreground.rdata0 & 8h1c) >> 2 ];
                                    pix_blue = colourexpand2to6[ (foreground.rdata0 & 8h3) ];
                                }
                            }
                        }
                    } // character or bitmap
                }
            } // pix_active
        } // pix_vblank == 0
    }
}

// BITFIELDS to help with bit/field access

// Instruction is 3 bits 1xx = literal value, 000 = branch, 001 = 0branch, 010 = call, 011 = alu, followed by 13 bits of instruction specific data
bitfield instruction {
    uint3 is_litcallbranchalu,
    uint13 pad
}

// A literal instruction is 1 followed by a 15 bit UNSIGNED literal value
bitfield literal {
    uint1  is_literal,
    uint15 literalvalue
}

// A branch, 0branch or call instruction is 0 followed by 00 = branch, 01 = 0branch, 10 = call followed by 13bit target address 
bitfield callbranch {
    uint1  is_literal,
    uint2  is_callbranchalu,
    uint13 address
}
// An alu instruction is 0 (not literal) followed by 11 = alu
bitfield aluop {
    uint1   is_literal,
    uint2   is_callbranchalu,
    uint1   is_r2pc,                // return from subroutine
    uint4   operation,              // arithmetic / memory read/write operation to perform
    uint1   is_t2n,                 // top to next in stack
    uint1   is_t2r,                 // top to return stack
    uint1   is_n2memt,              // write to memory       
    uint1   is_j1j1plus,            // Original J1 or extra J1+ alu operations
    uint1   rdelta1,                // two's complement adjustment for rsp
    uint1   rdelta0,
    uint1   ddelta1,                // two's complement adjustment for dsp
    uint1   ddelta0
}

// Simplify access to high/low byte
bitfield bytes {
    uint8   byte1,
    uint8   byte0
}

// Simplify access to 4bit nibbles (used to extract shift left/right amount)
bitfield nibbles {
    uint4   nibble3,
    uint4   nibble2,
    uint4   nibble1,
    uint4   nibble0
}

// Create 1hz (1 second counter)
algorithm pulse1hz(
    output uint16 counter1hz
) <autorun>
{
  uint32 counter50mhz = 0;
  counter1hz = 0;
  while (1) {
        if ( counter50mhz == 50000000 ) {
            counter1hz   = counter1hz + 1;
            counter50mhz = 0;
        } else {
            counter50mhz = counter50mhz + 1;
        }
    }
}

algorithm main(
    // LEDS (8 of)
    output  uint8   leds,
    
    // USER buttons
    // input   uint8    buttons,

    // VGA
    output! uint$color_depth$ video_r,
    output! uint$color_depth$ video_g,
    output! uint$color_depth$ video_b,
    output! uint1 video_hs,
    output! uint1 video_vs,

    // UART
    output! uint1 uart_tx,
    input   uint1 uart_rx

) {

    uint8 buttons = 0; // TODO

    uint16 timer1hz = 0;
    pulse1hz p1hz( counter1hz :> timer1hz );

    // UART tx and rx
    uint8 uart_tx_data  = 0;
    uint1 uart_tx_valid = 0;
    uint1 uart_tx_busy  = 0;
    uint1 uart_tx_done  = 0;
    uint8 uart_rx_data  = 0;
    uint1 uart_rx_valid = 0;
    uint1 uart_rx_ready = 0;

    // UART from https://github.com/jamieiles/uart
    uart uart0(
        clk_50m <: clock,
        din     <: uart_tx_data,
        wr_en   <: uart_tx_valid,
        tx      :> uart_tx,
        tx_busy :> uart_tx_busy,
        rx      <: uart_rx,
        rdy     :> uart_rx_valid,
        rdy_clr <: uart_rx_ready,
        dout    :> uart_rx_data
    );

    // VGA MultiPlexed Bitmap, Text and Terminal Display
    uint1 video_reset = 0;
    uint1 video_clock = 0;
    uint1 sdram_clock = 0;
    uint1 pll_lock = 0;
    de10nano_clk_100_25 clk_gen(
        refclk    <: clock,
        outclk_0  :> sdram_clock,
        outclk_1  :> video_clock,
        locked    :> pll_lock,
        rst       <: reset
    ); 

    // --- video reset
    reset_conditioner vga_rstcond (
        rcclk <: video_clock,
        in  <: reset,
        out :> video_reset
    );

    // Status of the screen, if in range, if in vblank, actual pixel x and y
    uint1  active = 0;
    uint1  vblank = 0;
    uint10 pix_x  = 0;
    uint10 pix_y  = 0;

    // GPU for reading and writing pixels
    //uint10 gpu_x = 0;
    //uint9 gpu_y = 0;
    //uint8 gpu_colour = 0;
    //uint1 gpu_write := 0;
    
    vga vga_driver <@video_clock,!video_reset>
    (
        vga_hs :> video_hs,
        vga_vs :> video_vs,
        active :> active,
        vblank :> vblank,
        vga_x  :> pix_x,
        vga_y  :> pix_y
    );

    multiplex_display display <@video_clock,!video_reset>
    (
        pix_x      <: pix_x,
        pix_y      <: pix_y,
        pix_active <: active,
        pix_vblank <: vblank,
        pix_red    :> video_r,
        pix_green  :> video_g,
        pix_blue   :> video_b,
        timer1hz   <: timer1hz
    );

    // J1+ CPU
    // instruction being executed, plus decoding, including 5bit deltas for dsp and rsp expanded from 2bit encoded in the alu instruction
    uint16  instruction = uninitialized;
    uint16  immediate := ( literal(instruction).literalvalue );
    uint1   is_alu := ( instruction(instruction).is_litcallbranchalu == 3b011 );
    uint1   is_call := ( instruction(instruction).is_litcallbranchalu == 3b010 );
    uint1   is_lit := literal(instruction).is_literal;
    uint1   dstackWrite := ( is_lit | (is_alu & aluop(instruction).is_t2n) );
    uint1   rstackWrite := ( is_call | (is_alu & aluop(instruction).is_t2r) );
    uint8   ddelta := { {7{aluop(instruction).ddelta1}}, aluop(instruction).ddelta0 };
    uint8   rdelta := { {7{aluop(instruction).rdelta1}}, aluop(instruction).rdelta0 };
    
    // program counter
    uint13  pc = 0;
    uint13  pcPlusOne := pc + 1;
    uint13  newPC = uninitialized;

    // dstack 257x16bit (as 3256 array + stackTop) and pointer, next pointer, write line, delta
    bram uint16 dstack[256] = uninitialized; // bram (code from @sylefeb)
    uint16  stackTop = 0;
    uint8   dsp = 0;
    uint8   newDSP = uninitialized;
    uint16  newStackTop = uninitialized;

    // rstack 256x16bit and pointer, next pointer, write line
    bram uint16 rstack[256] = uninitialized; // bram (code from @sylefeb)
    uint8   rsp = 0;
    uint8   newRSP = uninitialized;
    uint16  rstackWData = uninitialized;

    uint16  stackNext = uninitialized;
    uint16  rStackTop = uninitialized;
    uint16  memoryInput = uninitialized;

    // 16bit ROM with included compiled j1eForth from https://github.com/samawati/j1eforth
    brom uint16 rom[] = {
        $include('j1eforthROM.inc')
    };
    
    dualport_bram uint16 ram[32768] = uninitialized;
    
    // CYCLE to control each stage
    // CYCLE allows 1 clock cycle for BRAM access and 3 clock cycles for SPRAM access
    // INIT to determine if copying rom to ram or executing
    // INIT 0 SPRAM, INIT 1 ROM to SPRAM, INIT 2 J1 CPU
    uint3 CYCLE = 0;
    uint2 INIT = 0;
    
    // Address for 0 to SPRAM, copying ROM, plus storage
    uint16 copyaddress = 0;
    uint16 bramREAD = 0;

    // UART input FIFO (512 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 uartInBuffer[512] = uninitialized;
    uint9 uartInBufferNext = 0;
    uint9 uartInBufferTop = 0;
    uint1 uartInHold = 1;

    // UART output FIFO (512 character) as dualport bram (code from @sylefeb)
    dualport_bram uint8 uartOutBuffer[512] = uninitialized;
    uint9 uartOutBufferNext = 0;
    uint9 uartOutBufferTop = 0;
    uint9 newuartOutBufferTop = 0;
    uint1 uartOutHold = 0;
    
    // bram for dstack and rstack write enable, maintained low, pulsed high (code from @sylefeb)
    dstack.wenable         := 0;  
    rstack.wenable         := 0;

    // dual port bram for dtsack and strack
    uartInBuffer.wenable0  := 0;  // always read  on port 0
    uartInBuffer.wenable1  := 1;  // always write on port 1
    uartInBuffer.addr0     := uartInBufferNext; // FIFO reads on next
    uartInBuffer.addr1     := uartInBufferTop;  // FIFO writes on top
    
    uartOutBuffer.wenable0 := 0; // always read  on port 0
    uartOutBuffer.wenable1 := 1; // always write on port 1    
    uartOutBuffer.addr0    := uartOutBufferNext; // FIFO reads on next
    uartOutBuffer.addr1    := uartOutBufferTop;  // FIFO writes on top

    // Setup the terminal
    display.showterminal = 1;
    display.showcursor = 1;
    
    // INIT is 0 ZERO dualport working blockram
    while( INIT == 0 ) {
        switch(CYCLE) {
            case 0: {
                ram.addr0 = copyaddress;
                ram.wdata0 = 0;
                ram.wenable0 = 1;
            }
            case 1: {
                copyaddress = copyaddress + 1;
                ram.wenable0 = 0;
            }
            case 4: {
                if( copyaddress == 32768 ) {
                    INIT = 1;
                    copyaddress = 0;
                }
            }
            default: {}
        }
        CYCLE = ( CYCLE == 4 ) ? 0 : CYCLE + 1;
    }
    
    // INIT is 1 COPY ROM TO RAM
    while( INIT == 1) {
        switch(CYCLE) {
            case 0: {
                // Setup READ from ROM
                rom.addr = copyaddress;
            }
            case 1: {
                bramREAD = rom.rdata;
            }
            case 2: {
                // WRITE to RAM
                ram.addr0 = copyaddress;
                ram.wdata0 = bramREAD;
                ram.wenable0 = 1;
            }
            case 3: {
                copyaddress = copyaddress + 1;
                ram.wenable0 = 0;
            }
            case 4: {
                if( copyaddress == 4096 ) {
                    INIT = 3;
                    copyaddress = 0;
                }
            }
            default: {
            }
        }
        CYCLE = ( CYCLE == 4 ) ? 0 : CYCLE + 1;
    }

    // INIT is 3 EXECUTE J1 CPU
    while( INIT == 3 ) {
        // Deal with VBLANK, VGA and SDRAM

        // READ from UART if character available and store
        switch( uartInHold ) {
            case 0: {
                if( uart_rx_valid ) {
                    // writes at uartInBufferTop (code from @sylefeb)
                    uartInBuffer.wdata1  = uart_rx_data;            
                    uartInBufferTop      = uartInBufferTop + 1;
                    uartInHold = 1;
                }
                uart_rx_ready = 1;
            }
            case 1: {
                // Wait for UART valid flag to flip before allowing another read
                uartInHold = ( uart_rx_valid == 0 ) ? 0 : 1;
            }
        }

        // WRITE to UART if characters in buffer and UART is ready
        switch( uartOutHold ) {
            case 0: {
                if( ~(uartOutBufferNext == uartOutBufferTop) & ~( uart_tx_busy ) ) {
                    // reads at uartOutBufferNext (code from @sylefeb)
                    uart_tx_data      = uartOutBuffer.rdata0; 
                    uart_tx_valid     = 1;
                    uartOutHold = 1;
                    uartOutBufferNext = uartOutBufferNext + 1;
                }
            }
            case 1: {
                if( ~uart_tx_busy ) {
                    uart_tx_valid = 0;
                    uartOutHold = 0;
                }
            }
        }
        uartOutBufferTop = newuartOutBufferTop;        
        
        switch( CYCLE ) {
            // Read stackNext, rStackTop
            case 0: {
                // read dtsack and rstack brams (code from @sylefeb)
                stackNext = dstack.rdata;
                rStackTop = rstack.rdata;
            
                // start READ memoryInput = [stackTop] and instruction = [pc] result ready in 1 cycles
                ram.addr0 = stackTop >> 1;
                ram.wenable0 = 0;
                ram.addr1 = pc;
                ram.wenable1 = 0;
            }
            case 1: {
                // wait then read the data from RAM
                memoryInput = ram.rdata0;
                instruction = ram.rdata1;
            }
            
            // J1 CPU Instruction Execute
            case 2: {
                // +---------------------------------------------------------------+
                // | F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
                // +---------------------------------------------------------------+
                // | 1 |                    LITERAL VALUE                          |
                // +---------------------------------------------------------------+
                // | 0 | 0 | 0 |            BRANCH TARGET ADDRESS                  |
                // +---------------------------------------------------------------+
                // | 0 | 0 | 1 |            CONDITIONAL BRANCH TARGET ADDRESS      |
                // +---------------------------------------------------------------+
                // | 0 | 1 | 0 |            CALL TARGET ADDRESS                    |
                // +---------------------------------------------------------------+
                // | 0 | 1 | 1 |R2P| ALU OPERATION |T2N|T2R|N2A|J1P| RSTACK| DSTACK|
                // +---------------------------------------------------------------+
                // | F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
                // +---------------------------------------------------------------+
                // 
                // T   : Top of data stack
                // N   : Next on data stack
                // PC  : Program Counter
                // 
                // LITERAL VALUES : push a value onto the data stack
                // CONDITIONAL    : BRANCHS pop and test the T
                // CALLS          : PC+1 onto the return stack
                // 
                // T2N : Move T to N
                // T2R : Move T to top of return stack
                // N2A : STORE T to memory location addressed by N
                // R2P : Move top of return stack to PC
                // 
                // RSTACK and DSTACK are signed values (twos compliment) that are
                // the stack delta (the amount to increment or decrement the stack
                // by for their respective stacks: return and data)

                if(is_lit) {
                    // LITERAL Push value onto stack
                    newStackTop = immediate;
                    newPC = pcPlusOne;
                    newDSP = dsp + 1;
                    newRSP = rsp;
                } else {
                    switch( callbranch(instruction).is_callbranchalu ) { // BRANCH 0BRANCH CALL ALU
                        case 2b00: {
                            // BRANCH
                            newStackTop = stackTop;
                            newPC = callbranch(instruction).address;
                            newDSP = dsp;
                            newRSP = rsp;
                        }
                        case 2b01: {
                            // 0BRANCH
                            newStackTop = stackNext;
                            newPC = ( stackTop == 0 ) ? callbranch(instruction).address : pcPlusOne;
                            newDSP = dsp - 1;
                            newRSP = rsp;
                        }
                        case 2b10: {
                            // CALL
                            newStackTop = stackTop;
                            newPC = callbranch(instruction).address;
                            newDSP = dsp;
                            newRSP = rsp + 1;
                            rstackWData = pcPlusOne << 1;
                        }
                        case 2b11: {
                            // ALU
                            switch( aluop(instruction).is_j1j1plus ) {
                                case 1b0: {
                                    switch( aluop(instruction).operation ) {
                                        case 4b0000: {newStackTop = stackTop;}
                                        case 4b0001: {newStackTop = stackNext;}
                                        case 4b0010: {newStackTop = stackTop + stackNext;}
                                        case 4b0011: {newStackTop = stackTop & stackNext;}
                                        case 4b0100: {newStackTop = stackTop | stackNext;}
                                        case 4b0101: {newStackTop = stackTop ^ stackNext;}
                                        case 4b0110: {newStackTop = ~stackTop;}
                                        case 4b0111: {newStackTop = {16{(stackNext == stackTop)}};}
                                        case 4b1000: {newStackTop = {16{(__signed(stackNext) < __signed(stackTop))}};}
                                        case 4b1001: {newStackTop = stackNext >> nibbles(stackTop).nibble0;}
                                        case 4b1010: {newStackTop = stackTop - 1;}
                                        case 4b1011: {newStackTop = rStackTop;}
                                        case 4b1100: {
                                        // UART or memoryInput
                                            switch( stackTop ) {
                                                case 16hf000: {
                                                    // INPUT from UART reads at uartInBufferNext (code from @sylefeb)
                                                    newStackTop = { 8b0, uartInBuffer.rdata0 };
                                                    uartInBufferNext = uartInBufferNext + 1;
                                                } 
                                                case 16hf001: {
                                                    // UART status register { 14b0, tx full, rx available }
                                                    newStackTop = {14b0, ( uartOutBufferTop + 1 == uartOutBufferNext ), ~( uartInBufferNext == uartInBufferTop )};
                                                }
                                                case 16hf002: {
                                                    // RGB LED status
                                                    newStackTop = leds;
                                                }
                                                case 16hf003: {
                                                    // user buttons
                                                    newStackTop = {12b0, buttons};
                                                }
                                                case 16hf004: {
                                                    // 1hz timer
                                                    newStackTop = timer1hz;
                                                }
                                                case 16hff07: {
                                                    // GPU Active Status
                                                    newStackTop = display.gpu_active;
                                                }
                                                case 16hff20: {
                                                    // Terminal Active Status
                                                    newStackTop = display.terminal_active;
                                                }
                                                default: {newStackTop = memoryInput;}
                                            }
                                        }
                                        case 4b1101: {newStackTop = stackNext << nibbles(stackTop).nibble0;}
                                        case 4b1110: {newStackTop = {rsp, dsp};}
                                        case 4b1111: {newStackTop = {16{(__unsigned(stackNext) < __unsigned(stackTop))}};}
                                    }
                                }
                                
                                case 1b1: {
                                    switch( aluop(instruction).operation ) {
                                        case 4b0000: {newStackTop = {16{(stackTop == 0)}};}
                                        case 4b0001: {newStackTop = ~{16{(stackTop == 0)}};}
                                        case 4b0010: {newStackTop = ~{16{(stackNext == stackTop)}};}
                                        case 4b0011: {newStackTop = stackTop + 1;}
                                        case 4b0100: {newStackTop = stackTop << 1;}
                                        case 4b0101: {newStackTop = stackTop >> 1;}
                                        case 4b0110: {newStackTop = {16{(__signed(stackNext) > __signed(stackTop))}};}
                                        case 4b0111: {newStackTop = {16{(__unsigned(stackNext) > __unsigned(stackTop))}};}
                                        case 4b1000: {newStackTop = {16{(__signed(stackTop) < __signed(0))}};}
                                        case 4b1001: {newStackTop = {16{(__signed(stackTop) > __signed(0))}};}
                                        case 4b1010: {newStackTop = ( __signed(stackTop) < __signed(0) ) ?  - stackTop : stackTop;}
                                        case 4b1011: {newStackTop = ( __signed(stackNext) > __signed(stackTop) ) ? stackNext : stackTop;}
                                        case 4b1100: {newStackTop = ( __signed(stackNext) < __signed(stackTop) ) ? stackNext : stackTop;}
                                        case 4b1101: {newStackTop = -stackTop;}
                                        case 4b1110: {newStackTop = stackNext - stackTop;}
                                        case 4b1111: {newStackTop = {16{(__signed(stackNext) >= __signed(stackTop))}};}
                                    }
                                }
                            } // ALU Operation
                            
                            // UPDATE newDSP newRSP
                            newDSP = dsp + ddelta;
                            newRSP = rsp + rdelta;
                            rstackWData = stackTop;

                            // Update PC for next instruction, return from call or next instruction
                            newPC = ( aluop(instruction).is_r2pc ) ? rStackTop >> 1 : pcPlusOne;

                            // n2memt mem[t] = n        
                            if( aluop(instruction).is_n2memt ) {
                                switch( stackTop ) {
                                    default: {
                                        // WRITE to SPRAM
                                        ram.addr0 = stackTop >> 1;
                                        ram.wdata0 = stackNext;
                                        ram.wenable0 = 1;
                                    }
                                    case 16hf000: {
                                        // OUTPUT to UART (dualport blockram code from @sylefeb)
                                        uartOutBuffer.wdata1 = bytes(stackNext).byte0;
                                        newuartOutBufferTop = uartOutBufferTop + 1;
                                    }
                                    case 16hf002: {
                                        // OUTPUT to led
                                        leds = stackNext;
                                    }
                                    case 16hff00: {
                                        // GPU set x
                                        display.gpu_x = stackNext;
                                    }
                                    case 16hff01: {
                                        // GPU set y
                                        display.gpu_y = stackNext;
                                    }
                                    case 16hff02: {
                                        // GPU set dot
                                        display.gpu_colour = stackNext;
                                    }
                                   case 16hff03: {
                                        // GPU set parameter 0
                                        display.gpu_param0 = stackNext;
                                    }
                                   case 16hff04: {
                                        // GPU set parameter 1
                                        display.gpu_param1 = stackNext;
                                    }
                                   case 16hff05: {
                                        // GPU set parameter 2
                                        display.gpu_param2 = stackNext;
                                    }
                                   case 16hff06: {
                                        // GPU set parameter 3
                                        display.gpu_param3 = stackNext;
                                    }
                                   case 16hff07: {
                                        // Start GPU
                                        display.gpu_write = stackNext;
                                    }
                                    case 16hff10: {
                                        // TPU set x
                                        display.tpu_x = stackNext;
                                    }
                                    case 16hff11: {
                                        // TPU set y
                                        display.tpu_y = stackNext;
                                    }
                                    case 16hff12: {
                                        // TPU set char
                                        display.tpu_set = stackNext;
                                        display.tpu_write = 1;
                                    }
                                    case 16hff13: {
                                        // TPU set background
                                        display.tpu_set = stackNext;
                                        display.tpu_write = 2;
                                    }
                                    case 16hff14: {
                                        // TPU set foreground
                                        display.tpu_set = stackNext;
                                        display.tpu_write = 3;
                                    }
                                    case 16hff20: {
                                        // Terminal set character
                                        display.terminal_character = stackNext;
                                        display.terminal_write = 1;
                                     }
                                    case 16hff21: {
                                        // Terminal set showterminal
                                        display.showterminal = stackNext;
                                     }
                               }
                            }
                        } // ALU
                    }
                }
            } // J1 CPU Instruction Execute

            // update pc and perform mem[t] = n
            case 3: {
                // Write to dstack and rstack
                if( dstackWrite ) {
                    // bram code for dstack (code from @sylefeb)
                    dstack.wenable = 1;
                    dstack.addr    = newDSP;
                    dstack.wdata   = stackTop;
                }
                if( rstackWrite ) {
                    // bram code for rstack (code from @sylefeb)
                    rstack.wenable = 1;
                    rstack.addr    = newRSP;
                    rstack.wdata   = rstackWData;
                }
            }
            
            // Update dsp, rsp, pc, stackTop
            case 4: {
                dsp = newDSP;
                pc = newPC;
                stackTop = newStackTop;
                rsp = newRSP;
                
                // Setup addresses for dstack and rstack brams (code from @sylefeb)
                dstack.addr = newDSP;
                rstack.addr = newRSP;
            
                // reset sram_readwrite
                ram.wenable0 = 0;
                
                // reset gpu, tpu and terminal
                display.gpu_write = 0;
                display.tpu_write = 0;
                display.terminal_write = 0;
            }
            
            default: {}
        } // switch(CYCLE)
        
    
        // Move to next CYCLE ( 0 to 4 , then back to 0 )
        CYCLE = ( CYCLE == 4 ) ? 0 : CYCLE + 1;
    } // (INIT==3 execute J1 CPU)

}
