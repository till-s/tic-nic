# Example Kernel Module Makefile for linuxRT
# Using BuildRoot
# Will Build sis8300drv.ko

mod-objs := cdc-ncm-ptp.o
# Kernel Module:
obj-m := cdc_ncm_ptp.o
#mod-objs := cdc-ncm.o
# Kernel Module:
#obj-m := cdc_ncm.o

KERNELDIR := /lib/modules/$(shell uname -r)/build/

all:
	make -C $(KERNELDIR) M=$(PWD) modules

clean:
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions *.mod Module.symvers modules.order
