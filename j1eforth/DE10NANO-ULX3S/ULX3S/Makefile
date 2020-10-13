
.DEFAULT: j1eforth-ULX3S.ice
	silice-make.py -s j1eforth-ULX3S.ice -b $@ -p basic,hdmi,uart,usb -o BUILD_$(subst :,_,$@) -t shell

clean:
	rm -rf BUILD_*
