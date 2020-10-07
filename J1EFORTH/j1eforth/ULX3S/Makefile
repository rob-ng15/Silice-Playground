
.DEFAULT: j1eforth-ULX3S.ice
	silice-make.py -s j1eforth-ULX3S.ice -b $@ -p basic,hdmi -o BUILD_$(subst :,_,$@)

clean:
	rm -rf BUILD_*
