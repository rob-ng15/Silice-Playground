project_new build -overwrite
set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEBA6U23I7
set_global_assignment -name TOP_LEVEL_ENTITY top
set_global_assignment -name VERILOG_FILE build.v
set_global_assignment -name SDC_FILE /home/rob/Development/github/Silice/frameworks/boards/de10nano/build.sdc
source /home/rob/Development/github/Silice/frameworks/boards/de10nano/pins.tcl
