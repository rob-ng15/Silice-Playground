$$ uart_in_clock_freq_mhz = 50

// HDMI + UART + SDCARD + SDRAM Driver Includes
$include('../common/hdmi.ice')
$include('../common/uart.ice')
$include('../common/sdcard.ice')
$include('../common/sdram_interfaces.ice')
$include('../common/sdram_controller_autoprecharge_r16_w16.ice')
$include('../common/sdram_utils.ice')

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
$include('../memmap_io.ice')

$include('../cpu_functionblocks.ice')
$include('../mathematics.ice')

import('../common/ulx3s_clk_risc_ice_v.v')
import('../common/ulx3s_clk_risc_ice_v_2.v')
import('../common/reset_conditioner.v')

$include('../risc-ice-v.ice')
