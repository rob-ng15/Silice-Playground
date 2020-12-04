$$ uart_in_clock_freq_mhz = 25

// VGA/HDMI + UART Driver Includes
$include('../common/hdmi.ice')
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

import('../common/ulx3s_clk_risc_ice_v.v')
import('../common/reset_conditioner.v')

$include('../risc-ice-v.ice')
