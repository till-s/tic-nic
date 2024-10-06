PROGS=pkt tic_nic_ctl

tic_nic_ctl_LIBS=usb-1.0

all: $(PROGS) .gitignore

%: %.c
	$(CC) -o $@ $^ $(addprefix -l,$($@_LIBS))

.PHONY: all clean

.gitignore: makefile
	$(RM) $@
	for prg in $(PROGS); do echo $$prg >> $@; done

clean:
	$(RM) $(PROGS)
