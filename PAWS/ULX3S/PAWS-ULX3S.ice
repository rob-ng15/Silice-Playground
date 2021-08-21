$$ uart_in_clock_freq_mhz = 25

$$if not SIMULATION then
// CLOCKS
import('../common/ulx3s_clk_risc_ice_v.v')
import('../common/ulx3s_clk_risc_ice_v_2.v')
import('../common/ulx3s_clk_risc_ice_v_3.v')
$$end

// HDMI + UART + SDCARD + SDRAM Driver Includes
$$if HDMI then
$include('../common/hdmi.ice')
$$end

$$if VGA then
$include('vga.ice')
$$end

$include('../common/uart.ice')
$include('../common/sdcard.ice')
// PS2 KEYBOARD
$include('../common/ps2.ice')

$include('../common/sdram_interfaces.ice')
$include('../common/sdram_controller_autoprecharge_r16_w16.ice')
$include('../common/sdram_utils.ice')
$include('../common/clean_reset.ice')

// Headers
$include('../definitions.ice')
$include('../circuitry.ice')

// Multiplexed Display Includes
$include('../background.ice')
$include('../bitmap.ice')
$include('../character_map.ice')
$include('../gpu.ice')
$include('../sprite_layer.ice')
$include('../terminal.ice')
$include('../tile_map.ice')
$include('../multiplex_display.ice')
$include('../audio.ice')
$include('../video_memmap.ice')
$include('../io_memmap.ice')
$include('../timers_random.ice')

// CPU SPECIFICATION
$$CPUISA = 0x40001025
$include('../cpu_functionblocks.ice')
$include('../ALU-IM.ice')
$include('../common/float32.ice')
$include('../FPU.ice')
$include('../CPU-F.ice')

// MAIN
$include('../PAWS.ice')

