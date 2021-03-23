// we are running the design at 50 MHz instead of the default 25 MHz
$$ uart_in_clock_freq_mhz = 50

// VGA/HDMI + UART Driver + PS/2 DRIVER Includes
$include('../common/hdmi.ice')
$include('../common/uart.ice')
$include('../common/ps2.ice')

// Multiplexed Display Includes
$include('../gpu.ice')
$include('../multiplex_display.ice')
$include('../timers_random.ice')
$include('../terminal.ice')
$include('../character_map.ice')
$include('../bitmap.ice')
$include('../background.ice')
$include('../sprite_layer.ice')
$include('../tile_map.ice')
$include('../audio.ice')
$include('../mathematics.ice')
$include('../memmap_io.ice')

import('../common/ulx3s_clk_50_25.v')
import('../common/reset_conditioner.v')

$include('../j1eforth.ice')
