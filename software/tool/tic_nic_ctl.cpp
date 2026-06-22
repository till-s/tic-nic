#include <ticnic.hpp>

#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <unistd.h>

#include <cinttypes>
#include <string>

/* Diagnostic utility to talk using our vendor-specific device-requests; */ 

using namespace ticnic;

// Control requests to talk to the MDIO interface (strictly diagnostic; this is really
// handled by the kernel driver!)
class MDIOVendDev : public TicNic {
	static constexpr const unsigned MDIO_IDX     = 0x01; /* MDIO control is muxed between interface and device;
	                                                      * use this index (with recipient->device) to address
	                                                      * the MDIO agent.
	                                                      */
	static constexpr const unsigned MDIO_PHY_IDX = 0x01; /* default PHY index for MDIO register access */

	/* Request handled by the MDIO controller */
	static constexpr const unsigned REQ_MDIO_REG = 0x01; /* register read/write */

 public:
	MDIOVendDev(unsigned vid, unsigned pid)
	: TicNic( vid, pid )
	{
	}

	uint16_t
	vend_cmd_mdio_rd(uint8_t regOff);

	void
	vend_cmd_mdio_wr(uint8_t regOff, uint16_t val);

	~MDIOVendDev() = default;
};

uint16_t
MDIOVendDev::vend_cmd_mdio_rd(uint8_t reg_off)
{
    uint8_t buf[sizeof(uint16_t)];
    int     st;
    if ( (st = vend_cmd_dev_rd(REQ_MDIO_REG, ( MDIO_PHY_IDX << 8 ) | (reg_off & 0x1f), MDIO_IDX, buf, sizeof(buf) )) < sizeof(buf) ) {
		throw std::runtime_error("MDIOVendDev::vend_cmd_mdio_rd() - incomplete data read");
    }
    return ( buf[1] << 8 ) | buf[0];
}

void
MDIOVendDev::vend_cmd_mdio_wr(uint8_t reg_off, uint16_t v)
{
    uint8_t buf[sizeof(v)];
    int     st;
    buf[0] =  v & 0xff;
    buf[1] = (v >> 8);
    if ( (st = vend_cmd_dev_wr(REQ_MDIO_REG, ( MDIO_PHY_IDX << 8 ) | (reg_off & 0x1f), MDIO_IDX, buf, sizeof(buf) )) < sizeof(buf) ) {
		throw std::runtime_error("MDIOVendDev::vend_cmd_mdio_wr() - incomplete data written");
    }
}

static void usage(const char *nm)
{
	printf("usage: %s [-hg] [-p <product_id>] [-M reg_off[=value]] [-m <mask>] [-v <value>]\n", nm);
}


int
main(int argc, char **argv) 
{
int                   st;
int                   rv  = 1;
int                   vid = 0x1209;
int                   pid = 0x8851;
int                   msk = -1;
int                   val = -1;
int                   off;
int                   opt;
int                  *i_p;
int                   rd;
uint16_t              vu16;
int                   haveMdio = 0;
bool                  reqLED   = true;
bool                  showVers = false;
const char           *optstr   = "VM:m:v:hg";

	while ( ( opt = getopt(argc, argv, optstr) ) > 0 ) {
		i_p = 0;
		switch ( opt ) {
			case 'h': usage(argv[0]);           return 0;
			case 'm': i_p      = &msk;          break;
			case 'v': i_p      = &val;          break;
			case 'V': showVers = true;          break;
			case 'p': i_p      = &pid;          break;
			case 'g': reqLED   = false;         break;
			case 'M':                           break;
			default:  fprintf(stderr, "unknown option -%c\n", opt);
				return -1;
		}
		if ( i_p && 1 != sscanf(optarg,"%i",i_p)) {
			fprintf(stderr, "unable to scan arg of option -%c\n", opt);
			return 1;
		}
	}

	MDIOVendDev ticNic( vid, pid );

	optind = 1;
	while ( (opt = getopt(argc, argv, optstr)) > 0 ) {
		switch ( opt ) {
			default:
				continue;
			case 'M': break;
		}
		haveMdio = 1;
		switch ( (st = sscanf( optarg, "%i=%i", &off, &val )) ) {
			default:
				fprintf(stderr, "Unable to scan -M argument: %s\n", optarg);
				continue;
			case 1: rd = 1; break;
			case 2: rd = 0; break;
		}
		if ( off < 0 || off > 31 ) {
			fprintf(stderr, "Invalid register offset for MDIO access (0..31)\n");
			continue;
		}
		if ( rd ) {
			vu16 = ticNic.vend_cmd_mdio_rd( off );
		} else {
			if ( val < 0 || val > 0xffff ) {
				fprintf(stderr, "Invalid register value set for MDIO access (0..0xffff)\n");
				continue;
			}
			ticNic.vend_cmd_mdio_wr( off, val   );
		}
		if ( rd ) {
			printf("MDIO reg @0x%02x: 0x%04" PRIx16 "\n", off, vu16 );
		}
	}

	if ( val >= 0 || msk >= 0 || ! haveMdio ) {
		/* default is readback if nothing else is desired */

		rd = (val < 0 && msk < 0);

		TicNic::GPIOVal gval;
		gval.val_  = val;
		gval.mask_ = msk;

		if ( rd ) {
			if ( reqLED ) {
				ticNic.getLED( gval );
			} else {
				ticNic.getGPIO( gval );
			}
		} else {
			if ( reqLED ) {
				ticNic.setLED( gval );
			} else {
				ticNic.setGPIO( gval );
			}
		}
		if ( rd ) {
			printf("Response: val 0x%02x - mask 0x%02x\n", gval.val_, gval.mask_);
		}
	} else {
		// nothing to do; show versions
		showVers = true;
	}

	if ( showVers ) {
		ticNic.printVersion( stdout );
	}

	rv = 0;
bail:
	return rv;
}
