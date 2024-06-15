/* Helper program to test packet filtering using
 * raw sockets.
 */
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <getopt.h>
#include <unistd.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <arpa/inet.h>
#include <net/ethernet.h>

static void
usage(const char *nm)
{
	printf("usage: %s -d <ifname> [-t <hwaddr>]\n", nm);
	printf(" -t <hwaddr>    : send (bogus) message to target\n");
}

int
main(int argc, char **argv)
{
const char             *ifnam = 0;
int                     opt;
int                     rv    = 0;;
int                     sd    = -1;
struct ifreq            ifr;
struct sockaddr_ll      me, they;
int                     myidx;
socklen_t               theyl;
uint8_t                 buf[2048];
int                     got;
int                     i;
const char             *taddr = 0;

	memset( &they, 0, sizeof( they ) );
	memset( &me  , 0, sizeof( me   ) );

	while ( (opt = getopt(argc, argv, "hd:t:")) > 0 ) {
		switch( opt ) {
			case 'd':
				ifnam = optarg;
				break;

			case 't':
				taddr = optarg;
				break;

			case 'h':
				rv = 0; /* fall thru */
			default:
				if ( rv ) {
					fprintf(stderr, "Unknown option -%c\n", opt);
				}
				usage( argv[0] );
				return rv;
		}
	}

	if ( ! ifnam ) {
		fprintf(stderr, "Need interface name arg (-d <ifnam>)\n");
		goto bail;
	}

	if ( taddr ) {
		if ( ETH_ALEN != sscanf(taddr, "%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx",
				&they.sll_addr[0], &they.sll_addr[1],
				&they.sll_addr[2], &they.sll_addr[3],
				&they.sll_addr[4], &they.sll_addr[5] ) ) {
			fprintf(stderr, "Unable to scan peer hw address\n");
			goto bail;
		}
	}

	strncpy( ifr.ifr_name, ifnam, sizeof(ifr.ifr_name) );

	sd = socket( AF_PACKET, SOCK_RAW, htons( ETH_P_ALL ) );
	if ( sd < 0 ) {
		perror("unable to create socket");
		goto bail;
	}

	if ( ioctl(sd, SIOCGIFINDEX, &ifr) ) {
		perror("ioctl(SIOCGIFINDEX) failed");
		goto bail;
	}

	myidx = ifr.ifr_ifindex;

	if ( ioctl(sd, SIOCGIFHWADDR, &ifr) ) {
		perror("ioctl(SIOCGIFHWADDR) failed");
		goto bail;
	}

	printf("Interface %s has index %d; hwaddr: ", ifnam, myidx);
    for ( i = 0; i < 6; i++ ) {
		printf("%02X", (uint8_t)ifr.ifr_hwaddr.sa_data[i]);
	}
	printf("\n");

	me.sll_family     = AF_PACKET;
	me.sll_protocol   = htons( ETH_P_ALL );
	me.sll_ifindex    = myidx;

	they.sll_family   = AF_PACKET;
	they.sll_protocol = htons( ETH_P_ALL );
    they.sll_halen    = ETH_ALEN;
	they.sll_ifindex  = myidx;

	if ( bind( sd, (struct sockaddr*) &me, sizeof(me) ) ) {
		perror("bind() to interface failed");
		goto bail;
	}

	if ( taddr ) {
		i = 0;
		memcpy( buf + i, they.sll_addr, ETH_ALEN );
		i += ETH_ALEN;
		memcpy( buf + i, ifr.ifr_hwaddr.sa_data,  ETH_ALEN );
		i += ETH_ALEN;
        buf[i++] = 0x00;
        buf[i++] = 0x00;
        buf[i++] = 0xde;
        buf[i++] = 0xad;
        buf[i++] = 0xbe;
        buf[i++] = 0xef;

		got = sendto( sd, buf, i, 0, (struct sockaddr*)&they, sizeof(they) );
		if ( got != i ) {
			if ( got < 0 ) {
				perror("sendto failed");
				goto bail;
			}
			printf("Sent only %d bytes\n", got);
		}
		
	} else {
		while ( (theyl=sizeof(they),  (got = recvfrom(sd, buf, sizeof(buf), 0, (struct sockaddr*)&they, &theyl))) > 0 ) {
			printf("got %d bytes; LL header:\n", got);
			for ( i = 0; i < (got > 14 ? 14 : got); i++ ) {
				printf(" %02X", buf[i]);
			}
			printf("\n***\n");
		}
	}

bail:
	if ( sd >= 0 ) {
		close( sd );
	}
	return rv;
}
