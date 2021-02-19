$$ uart_in_clock_freq_mhz = 50
$$read_burst_length = 1

// CLOCKS
import('../common/ulx3s_clk_risc_ice_v.v')
import('../common/ulx3s_clk_risc_ice_v_2.v')
import('../common/ulx3s_clk_risc_ice_v_3.v')

// PS2 KEYBOARD
import('../common/ps2.v')

// USB
import('../common/USB/usb_phy.v')
import('../common/USB/usb_rx_phy.v')
import('../common/USB/usb_tx_phy.v')
import('../common/USB/usbh_sie.v')
import('../common/USB/usbh_crc5.v')
import('../common/USB/usbh_crc16.v')
import('../common/USB/usbh_host_hid.v')

// HDMI + UART + SDCARD + SDRAM Driver Includes
$include('../common/hdmi.ice')
$include('../common/uart.ice')
$include('../common/sdcard.ice')
$include('../common/sdram_interfaces.ice')
$include('../common/sdram_controller_autoprecharge_r16_w16.ice')
$include('../common/sdram_utils.ice')
$include('../common/clean_reset.ice')

// Headers
$include('../definitions.ice')
$include('../circuitry.ice')

// Multiplexed Display Includes
$include('../multiplex_display.ice')
$include('../timers_random.ice')
$include('../character_map.ice')
$include('../bitmap.ice')
$include('../gpu.ice')
$include('../background.ice')
$include('../sprite_layer.ice')
$include('../tile_map.ice')
$include('../audio.ice')
$include('../memmap_io_50mhz.ice')

// CPU
$include('../cpu_functionblocks.ice')
$include('../mathematics.ice')
$include('../cpu.ice')

// MAIN
$include('../PAWS.ice')

