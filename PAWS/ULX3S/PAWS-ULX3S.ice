$$ uart_in_clock_freq_mhz = 50

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
$include('../multiplex_display.ice')
$include('../timers_random.ice')
$include('../character_map.ice')
$include('../bitmap.ice')
$include('../gpu.ice')
$include('../background.ice')
$include('../sprite_layer.ice')
$include('../tile_map.ice')
$include('../audio.ice')
$include('../io_memmap.ice')

// CPU SPECIFICATION
$$CPUISA = 0x40001005
$$cpu_B = 1
$$cpu_F = 1
$$if cpu_B == 1 then
$$CPUISA = CPUISA + 2
$$end
$$if cpu_F == 1 then
$$CPUISA = CPUISA + 0x20
$$end
$include('../cpu_functionblocks.ice')
$include('../ALU-M.ice')
$$if cpu_B == 1 then
$include('../ALU-IMB.ice')
$$else
$include('../ALU-IM.ice')
$$end
$$if cpu_F == 1 then
$include('../common/float32_thin.ice')
$include('../FPU.ice')
$include('../CPU-F.ice')
$$else
$include('../CPU-I.ice')
$$end

// MAIN
$include('../PAWS.ice')

