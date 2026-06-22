#include <libusb_vend_cmd.hpp>

#include <fwComm.h>
#include <flash.h>

#include <limits.h>
#include <stdio.h>
#include <dirent.h>
#include <termios.h>
#include <sys/select.h>
#include <unistd.h>

#include <system_error>
#include <string>

namespace libusb_vend_cmd {

namespace {
	constexpr const unsigned MAIN_IDX = 0x00; /* index to address the main control endpoint */
}

int
VendDev::vend_cmd_dev(unsigned ep, unsigned req, unsigned val, unsigned idx, uint8_t *buf, size_t len)
{
#undef DEBUG
#ifdef DEBUG
	printf("CTRL REQ: ep 0x%02x, req 0x%02x, val %d, idx %d, len %zd\n", ep, req, val, idx, len);
#endif
	int st;
	st = libusb_control_transfer(
			dev_,
			ep | LIBUSB_REQUEST_TYPE_VENDOR | LIBUSB_RECIPIENT_DEVICE,
			req,
			val,
			idx,
			buf,
			len,
			1000
			);
	if ( st < 0 ) {
		throw Err(st, "libusb_control_transfer failed: ");
	}
	return st;
}

int
VendDev::vend_cmd_dev_rd(unsigned req, unsigned val, unsigned idx, uint8_t *buf, size_t len)
{
	return vend_cmd_dev( LIBUSB_ENDPOINT_IN, req, val, idx, buf, len );
}

int
VendDev::vend_cmd_dev_wr(unsigned req, unsigned val, unsigned idx, uint8_t *buf, size_t len)
{
	return vend_cmd_dev( LIBUSB_ENDPOINT_OUT, req, val, idx, buf, len );
}

int
VendDev::vend_cmd_dev_rd(unsigned req, uint8_t *buf, size_t len)
{
	return vend_cmd_dev_rd( req, 0x00, MAIN_IDX, buf, len );
}

int
VendDev::vend_cmd_dev_wr(unsigned req, uint8_t *buf, size_t len)
{
	return vend_cmd_dev_wr( req, 0x00, MAIN_IDX, buf, len );
}

struct DevList {
	libusb_device **l_{nullptr};

	DevList(libusb_context *ctx)
	{
		int st;
		if ( (st = libusb_get_device_list( ctx, &l_ )) < 0 ) {
			throw Err(st, "Error - libusb_get_device_list failed:");
		}
	}

	libusb_device *operator[](unsigned i) {
		return l_[i];
	}

	~DevList() {
		int UNREF_DEVICES = 1;
		if ( l_ ) {
			libusb_free_device_list( l_, UNREF_DEVICES );
		}
	}
};

VendDev::VendDev(unsigned vid, unsigned pid)
	: ctx_( nullptr ),
	  dev_( nullptr )
{
int      st;
unsigned instance = 0;
	if ( (st = libusb_init( &ctx_ )) ) {
		throw Err(st, "Error - libusb_init failed:");
	}
	DevList devList( ctx_ );
	unsigned i = 0;

	libusb_device *dev = nullptr;
	while ( (dev = devList[i]) ) {
		if ( (st = libusb_get_device_descriptor( dev, &devDesc_ )) ) {
			throw Err(st, "Error - libusb_get_device_descriptor failed.");
		}
		if ( devDesc_.idVendor == vid && devDesc_.idProduct == pid ) {
			if ( instance > 0 ) {
				instance--;
			} else {
				break;
			}
		}
		++i;
	}
	if ( ! dev ) {
		throw std::runtime_error("Error - requested instance with vendor/product ID not found on USB");
	}
	st = libusb_open( dev, &dev_ );
	if ( st ) {
		throw Err(st, "Error - libusb_open failed:");
	}
}

VendDev::~VendDev()
{
	if ( dev_ ) {
		libusb_close( dev_ );
	}
	if ( ctx_ ) {
		libusb_exit( ctx_ );
	}
}

} // namespace libusb_vend_cmd
