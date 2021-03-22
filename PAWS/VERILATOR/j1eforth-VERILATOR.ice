$$NUM_BTNS = 1;

// VGA/HDMI Driver Includes
$include('../common/vga.ice')

// Not used for verilator, just a placeholder
$$ uart_in_clock_freq_mhz = 50
$include('../common/uart.ice')

// Multiplexed Display Includes
$include('../multiplex_display.ice')
$include('../timers_random.ice')
$include('../terminal.ice')
$include('../character_map.ice')
$include('../bitmap.ice')
$include('../gpu.ice')
$include('../background.ice')
$include('../sprite_layer.ice')
$include('../tile_map.ice')
$include('../audio.ice')
$include('../mathematics.ice')
$include('../memmap_io.ice')

import('../common/de10nano_clk_100_25.v')
import('../common/reset_conditioner.v')

$include('../j1eforth.ice')
