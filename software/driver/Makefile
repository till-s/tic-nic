# Example Kernel Module Makefile for linuxRT
#
# module name and version (1.0) here and in dkms.conf must match!
mod-version := 1.0

mod-objs := cdc-tic-nic.o
# Kernel Module:
obj-m := cdc_tic_nic.o

KERNELDIR := /lib/modules/$(shell uname -r)/build/

all: modules

modules modules_install:
	make -C $(KERNELDIR) M=$(PWD) $@

clean:
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions *.mod Module.symvers modules.order

dkms-src-path:=/usr/src/$(mod-objs:%.o=%)-$(mod-version)

dkms-files:=$(obj-m:%.o=%.c) dkms.conf Makefile

$(dkms-src-path):
	mkdir -p $(dkms-src-path)

$(dkms-src-path)/%:% $(dkms-src-path)
	cp $< $(dkms-src-path)

dkms-src-install: $(addprefix $(dkms-src-path)/,$(dkms-files))
