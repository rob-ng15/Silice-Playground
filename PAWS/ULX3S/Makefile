.DEFAULT: PAWS-ULX3S.ice
	silice-make.py -s PAWS-ULX3S.ice -b $@ -p audio,basic,buttons,hdmi,sdcard,sdram,uart,gpio -o BUILD_$(subst :,_,$@) -t shell

clean:
	rm -rf BUILD_*
