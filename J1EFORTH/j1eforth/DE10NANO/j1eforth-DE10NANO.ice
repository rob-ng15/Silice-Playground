// VGA/HDMI Driver Includes
$include('../common/vga.ice')

$include('../terminal.ice')
$include('../character_map.ice')
$include('../bitmap.ice')
$include('../gpu.ice')
$include('../background.ice')

import('../common/de10nano_clk_100_25.v')
import('../common/reset_conditioner.v')

append('jamieilesUART/baud_rate_gen.v')
append('jamieilesUART/receiver.v')
append('jamieilesUART/transmitter.v')
import('jamieilesUART/uart.v')

$include('../j1eforth.ice')
