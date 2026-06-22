#pragma once

#include <libusb_vend_cmd.hpp>

#include <stdio.h>

namespace ticnic {

class TicNic : public libusb_vend_cmd::VendDev {
public:

	struct GPIOVal {
		uint8_t val_;
		uint8_t mask_;
	};

private:

	FWInfo     *fw_;
	int         fd_;
	std::string ttyName_;

protected:
	void rd(uint8_t req, GPIOVal &v);
	void wr(uint8_t req, const GPIOVal &v);

	// check that bcdDevice is >= minVersion and throw
	void requireBCDDevice(uint16_t minVersion);

	FWInfo *fw();
public:
	static constexpr unsigned VID_PIDCODES = 0x1209;
	static constexpr unsigned PID_TICNIC   = 0x8851;

	// try to locate the TTY automatically when NULL
	TicNic(const std::string &ttyName = std::string());
	// in case test IDs are being used
	TicNic(unsigned vid, unsigned pid, const std::string &ttyName = std::string());

	void setLED (const GPIOVal &);
	void setGPIO(const GPIOVal &);

	void getLED (GPIOVal &);
	void getGPIO(GPIOVal &);

	enum class ACMSelection { UART, TOOL };
	void setSelection(ACMSelection);
	ACMSelection getSelection();

	struct Version {
		uint32_t gitHash_;
		uint8_t  acmToolboxApiVersion_;
		uint8_t  acmToolboxApiFunction_;
		uint8_t  hardware_;
	};

	void getVersion(Version &);

	void printVersion(FILE *f);

	// read binary flash contents of 'length' (starting at 'flashAddr') to 'dstFile'
	void flashRead(const std::string &dstFileName, size_t length, unsigned flashAddr = 0);

	// write flash contents (starting at 'flashAddr') from 'srcFile' (a 'xxx.hex.bin')
	void flashWrite(const std::string &srcFileName, unsigned flashAddr = 0, bool reconfigureFPGA = true);

	virtual ~TicNic();
};

} // namespace ticnic

