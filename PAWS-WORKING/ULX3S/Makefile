.DEFAULT: PAWS-ULX3S.ice
	silice-make.py -s PAWS-ULX3S.ice -b $@ -p audio,basic,buttons,hdmi,sdcard,sdram,uart,gpio,us2_ps2 -o BUILD_$(subst :,_,$@) -t shell

verilator:
	silice-make.py -s PAWS-ULX3S.ice -b $@ -p basic,vga,sdram -o BUILD_$(subst :,_,$@) -t shell

clean:
	rm -rf BUILD_*
