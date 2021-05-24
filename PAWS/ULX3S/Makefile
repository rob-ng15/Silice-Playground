.DEFAULT: PAWSFPU-ULX3S.ice
	silice-make.py -s PAWSFPU-ULX3S.ice -b $@ -p audio,basic,buttons,hdmi,sdcard,sdram,uart,gpio,us2_ps2 -o BUILD_$(subst :,_,$@) -t shell

FPU: PAWSFPU-ULX3S.ice
	silice-make.py -s PAWSFPU-ULX3S.ice -b $@ -p audio,basic,buttons,hdmi,sdcard,sdram,uart,gpio,us2_ps2 -o BUILD_$(subst :,_,$@) -t shell

NOFPU: PAWS-ULX3S.ice
	silice-make.py -s PAWS-ULX3S.ice -b $@ -p audio,basic,buttons,hdmi,sdcard,sdram,uart,gpio,us2_ps2 -o BUILD_$(subst :,_,$@) -t shell

clean:
	rm -rf BUILD_*
