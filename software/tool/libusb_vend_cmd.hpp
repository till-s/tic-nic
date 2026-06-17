#pragma once

#include <libusb-1.0/libusb.h>
#include <stdexcept>
#include <sys/types.h>
#include <cstdint>
#include <string>

struct FWInfo;

namespace libusb_vend_cmd {

class Err : public std::runtime_error {
  public:
    Err(int code, const std::string &msg)
	: std::runtime_error(msg + " " + libusb_error_name(code)) {}
};

// support for sending vendor-specific control requests to the device
class VendDev {
	libusb_context           *ctx_;
	libusb_device_handle     *dev_;
	libusb_device_descriptor  devDesc_;

    int
	vend_cmd_dev(unsigned ep, unsigned req, unsigned val, unsigned idx, uint8_t *buf, size_t len);

protected:

	libusb_context*
	getCtx()
	{
		return ctx_;
	}

	libusb_device_handle*
	getDevHandle()
	{
		return dev_;
	}

	const libusb_device_descriptor &
	getDevDesc()
	{
		return devDesc_;
	}

	int
	vend_cmd_dev_rd(unsigned req, unsigned val, unsigned idx, uint8_t *buf, size_t len);

	int
	vend_cmd_dev_wr(unsigned req, unsigned val, unsigned idx, uint8_t *buf, size_t len);

public:
	VendDev(unsigned vid, unsigned pid);

	const libusb_device_descriptor &devDesc() { return devDesc_; }

	int
	vend_cmd_dev_rd(unsigned req, uint8_t *buf, size_t len);
	int
	vend_cmd_dev_wr(unsigned req, uint8_t *buf, size_t len);

	virtual ~VendDev();
};

} // namespace libus_vend_cmd 
