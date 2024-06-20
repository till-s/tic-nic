# Example Kernel Module Makefile for linuxRT

mod-objs := cdc-tic-nic.o
# Kernel Module:
obj-m := cdc_tic_nic.o

KERNELDIR := /lib/modules/$(shell uname -r)/build/

all: modules

modules modules_install:
	make -C $(KERNELDIR) M=$(PWD) $@

clean:
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions *.mod Module.symvers modules.order
