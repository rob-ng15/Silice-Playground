
.DEFAULT: j1eforth-DE10NANO.ice
	silice-make.py -s j1eforth-DE10NANO.ice -b $@ -p basic,vga,uart,buttons -o BUILD_$(subst :,_,$@)

clean:
	rm -rf BUILD_*
