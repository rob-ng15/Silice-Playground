j1.mem j1.bin: *.fs Makefile
	@echo ': version s" '`svnversion`'" ;' > version.fs
	date
	@date +': builddate d# %s. d# %z ;' >> version.fs
	@gforth -e 'include main.fs bye'

doc: *.fs Makefile
	gforth -e 'include ../../docforth/docforth.fs s" document.fs" document bye'
	mkdir -p html
	mv *.html html

# PRGDIR=$(HOME)/wge100_firmware/trunk/synth/programming_files/latest
PRGDIR=../hardware/synth/programming_files/latest

wge100_ip_camera.bit: $(PRGDIR)/wge100.bit j1.mem $(PRGDIR)/wge100_bd.bmm
	(. /opt/Xilinx/11.1/ISE/settings32.sh ; data2mem -bm $(PRGDIR)/wge100_bd.bmm -bd j1.mem tag jram -bt $(PRGDIR)/wge100.bit -o b wge100_ip_camera.bit )

wge100_ip_camera.mcs: wge100_ip_camera.bit
	(. /opt/Xilinx/11.1/ISE/settings32.sh ; linux32 promgen -w -p mcs -c FF -o wge100_ip_camera.mcs -u 0 wge100_ip_camera.bit >/dev/null )

defines_tcpip.fs defines_tcpip2.fs: genoffsets.py defines*py
	python genoffsets.py

download: j1.mem
	./send
	sudo python listenterminal.py

bundle: j1.bin wge100_ip_camera.mcs
	cp j1.bin wge100_ip_camera.mcs tools/*.py $(HOME)/bundle
