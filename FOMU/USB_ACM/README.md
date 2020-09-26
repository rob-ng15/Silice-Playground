# Non-blinky fomu Hello World

FPGA hello world demos seem to focus on blinking an LED. Since the fomu has a usb port and the D+/D- pins are directly exposed it makes sense to use this as a USB serial port (aka CDC/ACM) and print "hello world" and control the led from the serial port.

This repo contains two such demos. For building these you need the [yosys](http://www.clifford.at/yosys/)/[nextpnr](https://github.com/YosysHQ/nextpnr/)/[icestorm](http://www.clifford.at/icestorm/) toolchain, futhermore you need the [tinyfpga usbserial](https://github.com/davidthings/tinyfpga_bx_usbserial) from David Williams (this is a git submodule of this repo, so just clone it recursively). For loading this on the fomu you need dfu-util.

## nb_fomu_hw
This prints helloworld onto the USB serial port, on linux you can enjoy this by connecting to `/dev/ttyACM0`

For loading this on your fomu and connecting to it just run: `make hw-load && screen /dev/ttyACM0`

## fomu_led_ctrl
This demo allows you to connect to the fomu on `/dev/ttyACM0` and controlling the colors by send the chars `r`,`g` or `b`, any other character shuts off the LED, you also get feedback on the serial port about your actions.

For loading this on your fomu and connecting to it just run: `make ctrl-load && screen /dev/ttyACM0`
