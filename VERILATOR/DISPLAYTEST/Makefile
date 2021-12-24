.DEFAULT: test.ice
	silice-make.py -s test.ice -b $@ -p basic,hdmi -o BUILD_$(subst :,_,$@) -t shell

verilator:
	silice-make.py -s test.ice -b $@ -p basic,vga -o BUILD_$(subst :,_,$@) -t shell

clean:
	rm -rf BUILD_*
