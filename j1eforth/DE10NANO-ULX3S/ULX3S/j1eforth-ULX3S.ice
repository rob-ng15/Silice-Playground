// we are running the design at 50 MHz instead of the default 25 MHz
$$ uart_in_clock_freq_mhz = 50

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
$include('../vectors.ice')
$include('../display_list.ice')
$include('../audio.ice')

import('../common/ulx3s_clk_50_25.v')
import('../common/reset_conditioner.v')

$include('../j1eforth.ice')
