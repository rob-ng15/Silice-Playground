
.DEFAULT: j1eforth-DE10NANO.ice
	silice-make.py -s j1eforth-DE10NANO.ice -b $@ -p basic,vga,uart2 -o BUILD_$(subst :,_,$@)

clean:
	rm -rf BUILD_*
