
.DEFAULT: risc-ice-v-ULX3S.ice
	silice-make.py -s risc-ice-v-ULX3S.ice -b $@ -p basic,hdmi,uart,buttons,audio -o BUILD_$(subst :,_,$@) -t shell

clean:
	rm -rf BUILD_*
