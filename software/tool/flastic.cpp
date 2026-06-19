#include <ticnic.hpp>

#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <unistd.h>

#include <cinttypes>
#include <string>

// TicNic flash utility

using namespace ticnic;
using std::string;

static void usage(const char *nm, int level)
{
	bool        verbose = (level > 1);
	const char *verbmsg = (verbose ? " [-v <vendor_id>] [-p <product_id] [-a <flash_address>] [-d <tty_device>] [-C]" : "" );
	printf("usage: %s [-hV] [-f <file_name>] [-r <read_size>]%s\n", nm, verbmsg);
	printf("  -h                 : print this message; use twice for more info.\n");
	printf("  -V                 : print version info (default if -f not used).\n");
	printf("  -f <file_name>     : 'firmware.hex.bin' file to write or read from flash.\n");
	if ( verbose ) {
	printf("  -r <read_size>     : if this option is given then data are *read* from the\n");
	printf("                       flash. The defaul is to program the device.\n");
	printf("  -v <vendor_id>     : USB vendor id (default: 0x%04x).\n",  TicNic::VID_PIDCODES );
	printf("  -p <product_id>    : USB product id (default: 0x%04x).\n", TicNic::PID_TICNIC   );
	printf("  -a <flash_address> : starting address in the flash (default: 0).\n");
	printf("  -d <tty_device>    : TTY device to use (by default this is found\n");
	printf("                       automatically).\n");
	printf("  -C                 : skip reconfiguration of FPGA after writing flash.\n");
	printf("                       By default, an attempt to reconfigure (if supported\n");
	printf("                       by firmware) is make.\n");
	}
}

int
main(int argc, char **argv) 
{
int                   st;
int                   rv                = 1;
int                   vid               = TicNic::VID_PIDCODES;
int                   pid               = TicNic::PID_TICNIC;
int                   flash_addr        = 0;
int                   flash_size        = 0;
int                   opt;
int                  *i_p;
int                   level             = 0;
const char           *optstr            = "hCVv:p:a:d:f:r:";
bool                  showVers          = false;
string                ttyDev;
string                fnam;
bool                  reconfigureFPGA   = true;

	while ( ( opt = getopt(argc, argv, optstr) ) > 0 ) {
		i_p = 0;
		switch ( opt ) {
			case 'h': ++level;                   break;
			case 'V': showVers = true;           break;
			case 'v': i_p      = &vid;           break;
			case 'p': i_p      = &pid;           break;
			case 'd': ttyDev   = string(optarg); break;
			case 'f': fnam     = string(optarg); break;
			case 'a': i_p      = &flash_addr;    break;
			case 'r': i_p      = &flash_size;    break;
			case 'C': reconfigureFPGA = false;   break;

			default:  fprintf(stderr, "unknown option -%c\n", opt);
				return -1;
		}
		if ( i_p && 1 != sscanf(optarg,"%i",i_p)) {
			fprintf(stderr, "unable to scan arg of option -%c\n", opt);
			return 1;
		}
	}

	if ( level ) {
		usage( argv[0], level );
		return 0;
	}

	if ( flash_addr < 0 ) {
		fprintf(stderr, "Invalid flash address; must be > 0\n");
		return 1;
	}

	if ( flash_size < 0 ) {
		fprintf(stderr, "Invalid flash read size; must be > 0\n");
		return 1;
	}

	if ( ! showVers && 0 == fnam.size() ) {
		printf("No -f <file_name> given; to write the TicNic flash use:\n\n");
		printf("   %s -f <flash_file_name>\n", argv[0]);
		return 0;
	}

	TicNic ticNic( vid, pid, ttyDev );


	if ( showVers ) {
		ticNic.printVersion( stdout );
	}

	if ( fnam.size() ) {
		if ( flash_size ) {
			ticNic.flashRead(fnam, flash_size, flash_addr);
		} else {
			ticNic.flashWrite(fnam, flash_addr, reconfigureFPGA);
		}
	}


	rv = 0;
bail:
	return rv;
}
