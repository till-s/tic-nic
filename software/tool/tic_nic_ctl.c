#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <unistd.h>
#include <libusb-1.0/libusb.h>

/* Utility to talk use our vendor-specific device-requests;
 */ 

static void usage(const char *nm)
{
	printf("usage: %s [-hi] [-m <mask>] [-v <value>]\n", nm);
}

struct Handle {
	libusb_context       *ctx;
	libusb_device_handle *dev;
	uint8_t               bb_state;
};

#define CSEL_BIT (1<<3)
#define SCLK_BIT (1<<2)
#define MOSI_BIT (1<<1)
#define MISO_BIT (1<<0)

static int xf(struct Handle *h, int val) {
	uint8_t buf[2];
	buf[0] = val;
	buf[1] = 0x00;
	int st = libusb_control_transfer(
			h->dev,
			(val < 0 ? LIBUSB_ENDPOINT_IN : LIBUSB_ENDPOINT_OUT) | LIBUSB_REQUEST_TYPE_VENDOR | LIBUSB_RECIPIENT_DEVICE,
			val < 0 ? 0x02 : 0x01,
			0x00,
			0x00,
			buf,
			sizeof(buf),
			1000
	);
	return st >= 0 ? buf[0] : st;
}

/* assume CS asserted */
static int bit(struct Handle *h, int val) {
	int st;
	h->bb_state &= ~(SCLK_BIT | MOSI_BIT);
	if ( val ) {
		h->bb_state |= MOSI_BIT;
	}
	if ( xf(h, h->bb_state) < 0 ) {
		return -1;
	} 
	h->bb_state |= SCLK_BIT;
	if ( xf(h, h->bb_state) < 0 ) {
		return -1;
	} 
	st = xf(h, -1);
	return st < 0 ? st : !! (st & MISO_BIT);
}

static int byte(struct Handle *h, uint8_t val) {
	int i,st;
	int rv = 0;
	for ( i = 0x80; i; i>>=1 ) {
		st = bit(h, !!(val&i));	
		if ( st < 0 ) {
			return st;
		}
		rv = (rv<<1) | (st ? 1 : 0);
	} 
	return rv;
}

static int vec(struct Handle *h, uint8_t *val, size_t sz) {
	int i, st;
	h->bb_state = 0;
	if ( xf(h, h->bb_state) < 0 ) {
		return -1;
	}
	h->bb_state = CSEL_BIT;
	if ( xf(h, h->bb_state) < 0 ) {
		return -1;
	}
	for (i = 0; i < sz; i++) {
		if ( (st = byte(h, val[i])) < 0 ) {
			goto bail;
		}
		val[i] = st;
	}
	st = 0;
bail:
	h->bb_state = CSEL_BIT;
	if ( xf(h, h->bb_state) < 0 ) {
		return -1;
	}
	h->bb_state = 0;
	if ( xf(h, h->bb_state) < 0 ) {
		return -1;
	}
	return st;
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
int                   opt;
int                  *i_p;
int                   rd;
int                   id = 0;
int                   rst = 0;

	while ( (opt = getopt(argc, argv, "m:v:ir")) > 0 ) {
		i_p = 0;
		switch ( opt ) {
			case 'h': usage(argv[0]); return 0;
			case 'm': i_p = &msk;     break;
			case 'v': i_p = &val;     break;
			case 'i': id = 1;         break;
            case 'r': rst = 1;        break;
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

	if ( id ) {
		uint8_t idmsg[] = { 0x9f, 0xff, 0xff, 0xff, 0xff, 0xff };
		int i;
		if ( vec(h, idmsg, sizeof(idmsg)) < 0 ) {
			fprintf(stderr,"Sending bit-banged vector failed\n");
			goto bail;
		}
		printf("ID:");
		for ( i = 0; i < sizeof(idmsg); ++i ) {
			printf(" 0x%02x", idmsg[i]);
		}
		printf("\n");
	} else if ( rst ) {
		uint8_t msg[] = { 0xAB };
		if ( vec(h, msg, sizeof(msg)) < 0 ) {
			fprintf(stderr,"Sending bit-banged vector failed\n");
			goto bail;
		}
	} else {

		rd = (val < 0 && msk < 0);

		buf[0] = val;
		buf[1] = msk;
		st = libusb_control_transfer(
				h->dev,
				(rd ? LIBUSB_ENDPOINT_IN : LIBUSB_ENDPOINT_OUT) | LIBUSB_REQUEST_TYPE_VENDOR | LIBUSB_RECIPIENT_DEVICE,
				rd ? 0x02 : 0x01,
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
