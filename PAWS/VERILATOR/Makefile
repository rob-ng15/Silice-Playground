.DEFAULT: j1eforth-VERILATOR.ice
	silice-make.py -s j1eforth-VERILATOR.ice -b $@ -p basic,vga -o BUILD_$(subst :,_,$@)

clean:
	rm -rf BUILD_*
