set_location_assignment PIN_W15  -to LED0
set_location_assignment PIN_AA24 -to LED1
set_location_assignment PIN_V16  -to LED2
set_location_assignment PIN_V15  -to LED3
set_location_assignment PIN_AF26 -to LED4
set_location_assignment PIN_AE26 -to LED5
set_location_assignment PIN_Y16  -to LED6
set_location_assignment PIN_AA23 -to LED7

set_location_assignment PIN_V11  -to clk

set_location_assignment PIN_AG11 -to rx
set_location_assignment PIN_AH9  -to tx
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to rx
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tx
