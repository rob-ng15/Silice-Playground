// VGA/HDMI + UART Driver Includes
$include('../common/hdmi.ice')
$include('../common/uart.ice')

// Multiplexed Display Includes
$include('../terminal.ice')
$include('../character_map.ice')
$include('../bitmap.ice')
$include('../gpu.ice')
$include('../background.ice')

import('../common/ulx3s_clk_100_25.v')
import('../common/reset_conditioner.v')
$include('../j1eforth.ice')

