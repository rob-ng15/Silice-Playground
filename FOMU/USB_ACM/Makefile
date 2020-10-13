RTL_USB_DIR = tinyfpga_bx_usbserial/usb

SOURCES = \
	$(RTL_USB_DIR)/edge_detect.v \
	$(RTL_USB_DIR)/serial.v \
	$(RTL_USB_DIR)/usb_fs_in_arb.v \
	$(RTL_USB_DIR)/usb_fs_in_pe.v \
	$(RTL_USB_DIR)/usb_fs_out_arb.v \
	$(RTL_USB_DIR)/usb_fs_out_pe.v \
	$(RTL_USB_DIR)/usb_fs_pe.v \
	$(RTL_USB_DIR)/usb_fs_rx.v \
	$(RTL_USB_DIR)/usb_fs_tx_mux.v \
	$(RTL_USB_DIR)/usb_fs_tx.v \
	$(RTL_USB_DIR)/usb_reset_det.v \
	$(RTL_USB_DIR)/usb_serial_ctrl_ep.v \
	$(RTL_USB_DIR)/usb_uart_bridge_ep.v \
	$(RTL_USB_DIR)/usb_uart_core.v \
	$(RTL_USB_DIR)/usb_uart_i40.v

PIN_DEF = fomu-hacker.pcf

DEVICE = up5k
PACKAGE = uwg30

CLK_MHZ = 48

all: nb_fomu_hw.dfu nb_fomu_hw.rpt fomu_led_ctrl.dfu fomu_led_ctrl.rpt

define build_target
synth: $(1).json

$(1).json: $(1).v $(SOURCES)
	yosys -q -p 'synth_ice40 -top $(1) -json $$@' $$^

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --placer heap --$(DEVICE) --freq $(CLK_MHZ) --opt-timing --package $(PACKAGE) --pcf $(PIN_DEF) --json $$*.json --asc $$@

gui-$(1): $(PIN_DEF) $(1).json
	nextpnr-ice40 --placer heap --$(DEVICE) --package $(PACKAGE) --pcf $(PIN_DEF) --json $(1).json --asc $(1).asc --gui

%.bin: %.asc
	icepack $$< $$@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $$@ $$<

$(1).dfu: $(1).bin
	cp $(1).bin $(1).dfu
	dfu-suffix -v 1209 -p 70b1 -a $(1).dfu

clean-$(1):
	rm -f $(1).json $(1).asc $(1).bin $(1).rpt $(1).dfu
endef

$(eval $(call build_target,nb_fomu_hw))
$(eval $(call build_target,fomu_led_ctrl))

# Use df-util to load the DFU image onto the Fomu.
hw-load: nb_fomu_hw.dfu
	dfu-util -D $<

ctrl-load: fomu_led_ctrl.dfu
	dfu-util -D $<

clean: clean-nb_fomu_hw clean-fomu_led_ctrl

.SECONDARY:
.PHONY: all synth prog clean gui
