
.DEFAULT: first_example.ice
	silice-make.py -s first_example.ice -b $@ -p basic -o BUILD_$(subst :,_,$@)

clean:
	rm -rf BUILD_*
