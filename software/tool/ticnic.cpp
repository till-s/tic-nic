
#include <ticnic.hpp>

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

namespace ticnic {

namespace {
	/* These requests transfertwo bytes; a value and a mask.
	 * These can be used to control the LEDs (for testing).
	 * The LEDs obey the logic:
	 *
	 *    LED <= (fpga_logic_value and not mask) or (mask and value);
	 *
	 * I.e., the LEDs with a mask value of '0' are controlled by
	 * the FPGA design and where mask is '1' the value is controlled
	 * by the software-programmable 'value' register.
	 */
	constexpr const unsigned  REQ_LED  = 0x01;
	constexpr const unsigned  REQ_GPIO = 0x02;
	/* Only available for firmware bcdDevice >= 0x0101 */
	constexpr const unsigned  REQ_UMUX = 0x03; // control uart mux (was acmDTR on older firmware)
	constexpr const unsigned  REQ_VERS = 0x04; // obtain versions (w/o having to use the ACM)

	constexpr const uint8_t   UMUX_SEL_TOOL = 0x01;
	constexpr const uint8_t   UMUX_SEL_UART = 0x00;
};


TicNic::TicNic( const std::string &ttyName )
: TicNic( VID_PIDCODES, PID_TICNIC, ttyName )
{
}

TicNic::TicNic(unsigned vid, unsigned pid, const std::string &ttyName )
: libusb_vend_cmd::VendDev( vid, pid ), fw_( nullptr ), fd_( -1 ), ttyName_( ttyName )
{
	fw();
}

struct Dir {
	DIR *dir_;
	Dir(const char *path)
	{
		dir_ = opendir( path );
		if ( ! dir_ ) {
			throw std::system_error( errno, std::generic_category(), std::string("Unable to open: ") + path + " - specify device manually" );
		}
	}

	struct dirent *next()
	{
		errno = 0;

		struct dirent *de = readdir( dir_ );

		while ( de ) {
			if ( '.' != de->d_name[0] || ( (0 != de->d_name[1]) && ('.' != de->d_name[1]) ) ) {
				return de;
			}
			de = readdir( dir_ );
		}
		if ( errno ) {
			throw std::system_error( errno, std::generic_category(), std::string("readdir failed") );
		}
		return nullptr;
	}

	~Dir()
	{
		closedir( dir_ );
	}
};

struct FIFO {
	int fd_;

	FIFO(int fd) : fd_( fd )
	{
	}

	// clear out left-over UART stuff
	void
	drain()
	{
		fd_set          rfd;
		struct timeval  ztime;
		while (1) {
			FD_ZERO( &rfd );
			FD_SET( fd_, &rfd );
			ztime.tv_sec  = 0;
			ztime.tv_usec = 0;
			if ( 0 == select( fd_ + 1, &rfd, nullptr, nullptr, &ztime ) ) {
				// no work
				return;
			}
			uint8_t dump[256];
		}
	}

	int
	fd()
	{
		return fd_;
	}

	int
	release()
	{
		int fd = fd_;
		fd_ = -1;
		return fd;
	}

	~FIFO()
	{
		if ( fd_ >= 0 ) {
			fifoClose( fd_ );
		}
	}
};

FWInfo *
TicNic::fw()
{
	if ( fw_ ) {
		// already open
		return fw_;
	}

	char           path[PATH_MAX];

	const char     *nm    = nullptr;
	if ( ttyName_.size() > 0 ) {
		nm = ttyName_.c_str();
	}
	libusb_device *usbdev = libusb_get_device( getDevHandle() );

	if ( ! nm ) {
		// try to figure out the path ourselves
		uint8_t ports[20];
		int got = libusb_get_port_numbers( usbdev, ports, sizeof(ports) );
		if ( got < 0 ) {
			throw libusb_vend_cmd::Err(got, "libusb_get_port_numbers failed");
		}
		if ( 0 == got ) {
			throw std::runtime_error("libusb_get_port_numbers returned no ports");
		}
		size_t  sz = sizeof( path );
		int    pos = 0;
		pos += snprintf( path, sizeof(path) - pos, "/sys/bus/usb/devices/%d-%d", libusb_get_bus_number( usbdev ), ports[0] );
		for ( int i = 1; i < got; ++i ) {
			pos += snprintf(path + pos, sizeof(path) - pos, ".%d", ports[i]);
		}
		// don't bother with the descriptors
		unsigned config = 1;
		unsigned acm_if = 0;
		pos += snprintf( path + pos, sizeof(path) - pos, ":%d.%d/tty", config, acm_if );
		Dir dir( path );
		struct dirent *de = dir.next();
		if ( ! de ) {
			throw std::runtime_error( std::string("readdir of '") + path + "' turned up nothing" );
		}
		snprintf( path, sizeof(path), "/dev/%s", de->d_name );
		nm = path;
	}

	bool legacyConnection = ( getDevDesc().bcdDevice < 0x0101 );

	// legacy FW connection dropped DTR to mux the ACM connection
	// between UART and ACM tool box (flash writer).
	FIFO fifo( fifoOpen( nm, legacyConnection ? B0 : B115200 ) );
	if ( fifo.fd() < 0 ) {
		throw std::runtime_error("fifoOpen() failed");
	}

	ACMSelection previous;
	if ( ! legacyConnection ) {
		previous = getSelection();
		setSelection( ACMSelection::TOOL );
	}

	// clear out stuff after switching the mux
	fifo.drain();

	if ( ! ( fw_ = fw_open_fd( fifo.fd() ) ) ) {
		if ( ! legacyConnection ) {
			setSelection( previous );
		}
		throw std::runtime_error("fw_open_fd() failed");
	}
	fd_ = fifo.release();
	return fw_;
}

void
TicNic::rd(uint8_t req, GPIOVal &v)
{
	uint8_t buf[2];
	vend_cmd_dev_rd( req, buf, sizeof(buf) );
	v.val_  = buf[0];
	v.mask_ = buf[1];
}

void
TicNic::wr(uint8_t req, const GPIOVal &v)
{
	uint8_t buf[2];
	buf[0] = v.val_;
	buf[1] = v.mask_;
	vend_cmd_dev_wr( req, buf, sizeof(buf) );
}

void
TicNic::setLED (const GPIOVal &v)
{
	wr( REQ_LED, v );
}

void
TicNic::setGPIO(const GPIOVal &v)
{
	wr( REQ_GPIO, v );
}

void
TicNic::getLED (GPIOVal &v)
{
	rd( REQ_LED, v );
}

void
TicNic::getGPIO(GPIOVal &v)
{
	rd( REQ_GPIO, v );
}

void
TicNic::getVersion(Version &v)
{
	if ( getDevDesc().bcdDevice >= 0x0101 ) {
		uint8_t buf[6];
		vend_cmd_dev_rd( REQ_VERS, buf, sizeof(buf) );
		v.gitHash_ = 0;
		for ( int i = 3; i >= 0; --i ) {
			v.gitHash_ = (v.gitHash_ << 8) | buf[i];
		}
		v.acmToolboxApiVersion_  = (buf[4] >> 0) & 0x0f;
		v.acmToolboxApiFunction_ = (buf[4] >> 4) & 0x0f;
		v.hardware_              = buf[5];
	} else {
		// fall back to talking via ACM; must take over the connection for that
		v.gitHash_               = fw_get_version      ( fw() );
		v.acmToolboxApiVersion_  = fw_get_api_version  ( fw() );
		v.acmToolboxApiFunction_ = fw_get_api_function ( fw() );
		v.hardware_              = fw_get_board_version( fw() );
	}
}

void
TicNic::setSelection(TicNic::ACMSelection sel)
{
	requireBCDDevice( 0x0101 );
	uint8_t buf[1];
	buf[0] = (sel == ACMSelection::TOOL ? UMUX_SEL_TOOL : UMUX_SEL_UART);
	vend_cmd_dev_wr( REQ_UMUX, buf, sizeof(buf) );
}

TicNic::ACMSelection
TicNic::getSelection()
{
	requireBCDDevice( 0x0101 );
	uint8_t buf[1];
	vend_cmd_dev_rd( REQ_UMUX, buf, sizeof(buf) );
	return (!! (buf[0] & UMUX_SEL_TOOL)) ? ACMSelection::TOOL : ACMSelection::UART;
}

TicNic::~TicNic()
{
	if ( fw_ ) {
		fw_close( fw_ );
	}
	if ( fd_ >= 0 ) {
		fifoClose( fd_ );
	}
}

void
TicNic::flashRead(const std::string &dstFileName, size_t length, unsigned flashAddr)
{
	int st = flash_read_into_file( fw(), dstFileName.c_str(), length, flashAddr );
	if ( st < 0 ) {
		throw std::system_error( -st, std::generic_category(), "reading flash contents to file failed" );
	}
}

void
TicNic::flashWrite(const std::string &srcFileName, unsigned flashAddr, bool reconfigureFPGA)
{
	FlashStdioProgressData progressContext;
	flash_stdio_progress_data_init( &progressContext );
	int st = flash_write_from_file( fw(), srcFileName.c_str(), flashAddr, flash_stdio_progress, &progressContext );
	if ( st < 0 ) {
		throw std::system_error( -st, std::generic_category(), "writing flash failed" );
	}
	if ( reconfigureFPGA ) {
		int st = fw_reconfigure_fpga_on_close( fw(), 1 );
		if ( st < 0 ) {
			fprintf(stderr, "WARNING: FPGA reconfiguration not supported by firmware; you must manually reset or power-cycle\n");
		}
	}
}

void
TicNic::requireBCDDevice(uint16_t minVersion)
{
	if ( getDevDesc().bcdDevice < minVersion ) {
		char c_str[20];
		snprintf( c_str, sizeof(c_str), "0x%04x", static_cast<unsigned>( minVersion ) );
		throw std::runtime_error( std::string( "not supported by this firmware; need bcdDevice >= " ) + c_str );
	}
}

void
TicNic::printVersion(FILE *f)
{
	if ( ! f ) {
		f = stdout;
	}
	TicNic::Version v;
	getVersion( v );
	fprintf(f, "TicNic Version:\n");
	fprintf(f, " Git Hash              : %08x\n", v.gitHash_              );
	fprintf(f, " ACM Tool API Function : %1x\n",  v.acmToolboxApiFunction_);
	fprintf(f, " ACM Tool API Version  : %1x\n",  v.acmToolboxApiVersion_ );
	fprintf(f, " Board/Hw Revision     : %02x\n", v.hardware_             );
}

} // namespace ticnic
