#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <unistd.h>
#include <libusb-1.0/libusb.h>

/* Utility to talk use our vendor-specific device-requests;
 */ 

static void usage(const char *nm)
{
	printf("usage: %s [-h] [-p <product_id>] [-m <mask>] [-v <value>]\n", nm);
}

struct Handle {
	libusb_context       *ctx;
	libusb_device_handle *dev;
};

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
#define REQ_LED 0x01

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
int                   opt;
int                  *i_p;
int                   rd;

	while ( (opt = getopt(argc, argv, "m:v:h")) > 0 ) {
		i_p = 0;
		switch ( opt ) {
			case 'h': usage(argv[0]); return 0;
			case 'm': i_p = &msk;     break;
			case 'v': i_p = &val;     break;
			case 'p': i_p = &pid;     break;
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

	rd = (val < 0 && msk < 0);

	buf[0] = val;
	buf[1] = msk;
	st = libusb_control_transfer(
			h->dev,
			(rd ? LIBUSB_ENDPOINT_IN : LIBUSB_ENDPOINT_OUT) | LIBUSB_REQUEST_TYPE_VENDOR | LIBUSB_RECIPIENT_DEVICE,
			REQ_LED,
			0x00,
			0x00,
			buf,
			sizeof(buf),
			1000
			);
	if ( st < 0 ) {
		fprintf(stderr, "Error - libusb_control_transfer failed: %s\n", libusb_error_name(st));
		goto bail;
	}

	if ( rd ) {
		printf("Response: val 0x%02x - mask 0x%02x\n", buf[0], buf[1]);
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
