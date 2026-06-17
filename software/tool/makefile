PROGS=pkt tic_nic_ctl

tic_nic_ctl_LIBS=usb-1.0

all: $(PROGS) .gitignore

VPATH=../../firmware/modules/acm-toolbox/sw

%.o: %.cpp
	$(CXX) -I. -I$(VPATH) -c -g $^ 

%.o: %.c
	$(CC) -I. -I$(VPATH) -c -g $^ 

tic_nic_ctl: tic_nic_ctl.o libusb.o fwComm.o cmdXfer.o at25Sup.o flash.o
	$(CXX) -o $@ $^ $(addprefix -l,$($@_LIBS))

.PHONY: all clean

.gitignore: makefile
	$(RM) $@
	for prg in $(PROGS); do echo $$prg >> $@; done

clean:
	$(RM) $(PROGS)
