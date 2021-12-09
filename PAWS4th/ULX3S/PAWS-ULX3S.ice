$$ uart_in_clock_freq_mhz = 25

$$if not SIMULATION then
// CLOCKS
import('../common/clock_system.v')
import('../common/clock_cpu.v')
import('../common/clock_video.v')
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
$include('../circuitry.ice')

// Multiplexed Display Includes
$include('../background.ice')
$include('../bitmap.ice')
$include('../character_map.ice')
$include('../GPU.ice')
$include('../sprite_layer.ice')
$include('../terminal.ice')
$include('../tile_map.ice')
$include('../multiplex_display.ice')
$include('../audio.ice')
$include('../io_memmap.ice')
$include('../video_memmap.ice')
$include('../timers_random.ice')

// MAIN
$include('../common/float16.ice')
$include('../mathematics.ice')
$include('../J1CPU.ice')
$include('../PAWS.ice')

