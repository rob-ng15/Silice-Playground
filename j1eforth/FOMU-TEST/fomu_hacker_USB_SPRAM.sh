#!/bin/bash
rm build*

silice -f frameworks/fomu_USB_SPRAM.v $1 -o build.v

yosys -D HACKER=1 -p 'synth_ice40 -abc2 -retime -relut -dsp -top top -json build.json' \
                       usb_cdc/bulk_endp.v\
                       usb_cdc/ctrl_endp.v \
                       usb_cdc/sie.v \
                       usb_cdc/phy_rx.v \
                       usb_cdc/phy_tx.v \
                       usb_cdc/usb_cdc.v \
                       pll.v \
                       build.v

nextpnr-ice40 --placer heap --up5k --freq 12 --opt-timing --package uwg30 --pcf pcf/fomu-hacker.pcf --json build.json --asc build.asc
icepack build.asc build.bit
icetime -d up5k -mtr build.rpt build.asc
cp build.bit build.dfu
dfu-suffix -v 1209 -p 70b1 -a build.dfu
