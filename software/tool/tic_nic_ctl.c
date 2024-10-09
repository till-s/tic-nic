#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <unistd.h>
#include <inttypes.h>
#include <libusb-1.0/libusb.h>

/* Utility to talk use our vendor-specific device-requests; */ 

#define MAIN_IDX 0x00  /* index to address the main control endpoint */

#define MDIO_IDX 0x01  /* MDIO control is muxed between interface and device;
                        * use this index (with recipient->device) to address
                        * the MDIO agent.
                        */
#define MDIO_PHY_IDX 0x01 /* default PHY index for MDIO register access */
/* This request transfers two bytes; a value and a mask.
 * These can be used to control the LEDs (for testing).
 * The LEDs obey the logic:
 *
 *    LED <= (fpga_logic_value and not mask) or (mask and value);
 *
 * I.e., the LEDs with a mask value of '0' are controlled by
 * the FPGA design and where mask is '1' the value is controlled
 * by the software-programmable 'value' register.
 */
#define REQ_LED  0x01
#define REQ_GPIO 0x02

/* Request handled by the MDIO controller */
#define REQ_MDIO_REG 0x01 /* register read/write */


struct Handle {
	libusb_context       *ctx;
	libusb_device_handle *dev;
};

static int vend_cmd(
	struct Handle           *h,
    unsigned                 ep,
    unsigned                 req,
    unsigned                 val,
    unsigned                 idx,
    uint8_t                 *buf,
    size_t                   len
) {
#define DEBUG
#ifdef DEBUG
	printf("CTRL REQ: ep 0x%02x, req 0x%02x, val %d, idx %d, len %zd\n", ep, req, val, idx, len);
#endif
	return libusb_control_transfer(
			h->dev,
			ep | LIBUSB_REQUEST_TYPE_VENDOR | LIBUSB_RECIPIENT_DEVICE,
			req,
			val,
			idx,
			buf,
			len,
			1000
			);
}

static int vend_cmd_rd(
	struct Handle           *h,
    unsigned                 req,
    unsigned                 val,
    unsigned                 idx,
    uint8_t                 *buf,
    size_t                   len
) {
	return vend_cmd( h, LIBUSB_ENDPOINT_IN, req, val, idx, buf, len );
}

static int vend_cmd_wr(
	struct Handle           *h,
    unsigned                 req,
    unsigned                 val,
    unsigned                 idx,
    uint8_t                 *buf,
    size_t                   len
) {
	return vend_cmd( h, LIBUSB_ENDPOINT_OUT, req, val, idx, buf, len );
}

static int vend_cmd_main_rd(
	struct Handle           *h,
    unsigned                 req,
    uint8_t                 *buf,
    size_t                   len
) {
	return vend_cmd_rd( h, req, 0x00, MAIN_IDX, buf, len );
}

static int vend_cmd_main_wr(
	struct Handle           *h,
    unsigned                 req,
    uint8_t                 *buf,
    size_t                   len
) {
	return vend_cmd_wr( h, req, 0x00, MAIN_IDX, buf, len );
}

static int vend_cmd_mdio_rd(struct Handle *h, uint8_t reg_off, uint16_t *pv)
{
    uint8_t buf[sizeof(*pv)];
    int     st;
    if ( (st = vend_cmd_rd(h, REQ_MDIO_REG, ( MDIO_PHY_IDX << 8 ) | (reg_off & 0x1f), MDIO_IDX, buf, sizeof(buf) )) < sizeof(buf) ) {
        if ( st >= 0 ) {
            st = -1;
        }
        return st;
    }
    *pv = ( buf[1] << 8 ) | buf[0];
    return 0;
}

static int vend_cmd_mdio_wr(struct Handle *h, uint8_t reg_off, uint16_t v)
{
    uint8_t buf[sizeof(v)];
    int     st;
    buf[0] =  v & 0xff;
    buf[1] = (v >> 8);
    if ( (st = vend_cmd_wr(h, REQ_MDIO_REG, ( MDIO_PHY_IDX << 8 ) | (reg_off & 0x1f), MDIO_IDX, buf, sizeof(buf) )) < sizeof(buf) ) {
        if ( st >= 0 ) {
            st = -1;
        }
        return st;
    }
    return 0;
}

static void usage(const char *nm)
{
	printf("usage: %s [-hg] [-p <product_id>] [-M reg_off[=value]] [-m <mask>] [-v <value>]\n", nm);
}


int
main(int argc, char **argv) 
{
struct Handle        *h   = calloc(sizeof(struct Handle),1);
int                   st;
int                   rv  = 1;
int                   vid = 0x1209;
int                   pid = 0x0001;
uint8_t               buf[2];
int                   msk = -1;
int                   val = -1;
int                   off;
int                   opt;
int                  *i_p;
int                   rd;
int                   haveMdio = 0;
unsigned              req     = REQ_LED;
uint16_t              vu16;
const char           *optstr  = "M:m:v:hg";
const char           *oper;

	while ( ( opt = getopt(argc, argv, optstr) ) > 0 ) {
		i_p = 0;
		switch ( opt ) {
			case 'h': usage(argv[0]); return 0;
			case 'm': i_p = &msk;     break;
			case 'v': i_p = &val;     break;
			case 'p': i_p = &pid;     break;
			case 'g': req = REQ_GPIO; break;
			case 'M': break;
			default:  fprintf(stderr, "unknown option -%c\n", opt);
				return -1;
		}
		if ( i_p && 1 != sscanf(optarg,"%i",i_p)) {
			fprintf(stderr, "unable to scan arg of option -%c\n", opt);
			return 1;
		}
	}

	if ( ! h ) {
		fprintf(stderr, "No memory\n");
		goto bail;
	}

	st = libusb_init( &h->ctx );
	if ( st ) {
		fprintf(stderr, "Error - libusb_init failed: %s\n", libusb_error_name(st));
		goto bail;
	}

	h->dev = libusb_open_device_with_vid_pid( h->ctx, vid, pid );
	if ( ! h->dev ) {
		fprintf(stderr, "Error - libusb_open_device_with_vid_pid failed\n");
		goto bail;
	}

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
			st = vend_cmd_mdio_rd( h, off, &vu16 );
		} else {
			if ( val < 0 || val > 0xffff ) {
				fprintf(stderr, "Invalid register value set for MDIO access (0..0xffff)\n");
				continue;
			}
			st = vend_cmd_mdio_wr( h, off, val   );
		}
		if ( st < 0 ) {
			fprintf(stderr, "Error - libusb_control_transfer failed for -%c %s: %s\n",
				opt, optarg, libusb_error_name(st));
		} else {
			if ( rd ) {
				printf("MDIO reg @0x%02x: 0x%04" PRIx16 "\n", off, vu16 );
			}
		}
	}

	if ( val >= 0 || msk >= 0 || ! haveMdio ) {
		/* default is readback if nothing else is desired */

		rd = (val < 0 && msk < 0);

		buf[0] = val;
		buf[1] = msk;
		if ( rd ) {
			st = vend_cmd_main_rd( h, req, buf, sizeof(buf) );
		} else {
			st = vend_cmd_main_wr( h, req, buf, sizeof(buf) );
		}
		if ( st < 0 ) {
			fprintf(stderr, "Error - libusb_control_transfer failed: %s\n", libusb_error_name(st));
			goto bail;
		}

		if ( rd ) {
			printf("Response: val 0x%02x - mask 0x%02x\n", buf[0], buf[1]);
		}

	}

	rv = 0;
bail:
	if ( h ) {
		if ( h->dev ) {
			libusb_close( h->dev );
		}
		if ( h->ctx ) {
			libusb_exit( h->ctx );
		}
	}
	return rv;
}
