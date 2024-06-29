/*
 * cdc_tic_nic.c
 *
 * Copyright Till Straumann, 2024.
 *
 * Parts of this code are derived from cdc_ncm.c:
 *
 * Copyright (C) ST-Ericsson 2010-2012
 * Contact: Alexey Orishko <alexey.orishko@stericsson.com>
 * Original author: Hans Petter Selasky <hans.petter.selasky@stericsson.com>
 *
 * USB Host Driver for Network Control Model (NCM)
 * http://www.usb.org/developers/docs/devclass_docs/NCM10_012011.zip
 *
 * The NCM encoding, decoding and initialization logic
 * derives from FreeBSD 8.x. if_cdce.c and if_cdcereg.h
 *
 * This software is available to you under a choice of one of two
 * licenses. You may choose this file to be licensed under the terms
 * of the GNU General Public License (GPL) Version 2 or the 2-clause
 * BSD license listed below:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <linux/module.h>
#include <linux/netdevice.h>
#include <linux/ctype.h>
#include <linux/etherdevice.h>
#include <linux/ethtool.h>
#include <linux/if_arp.h>
#include <linux/mii.h>
#include <linux/phy.h>
#include <linux/phy_led_triggers.h>
#include <linux/mdio.h>
#include <linux/usb.h>
#include <linux/atomic.h>
#include <linux/usb/usbnet.h>
#include <linux/usb/cdc.h>
#include <linux/usb/cdc_ncm.h>
#include <linux/rtnetlink.h>

#define PHY_ID 1
#define VEND_REQ_MDIO 0x01

#define STATIC

static bool random_mac_addr = 1;
module_param(random_mac_addr, bool, 0);
MODULE_PARM_DESC(random_mac_addr, "Use random MAC address (default == TRUE)");

struct cdc_ncm_ptp_priv {
	struct mii_bus     *mdiobus;
	struct phy_device  *phydev;
};

STATIC int cdc_ncm_ptp_mdio_read(struct mii_bus *bus, int phy_id, int idx)
{
	int err;
	struct usbnet *dev = (struct usbnet*)bus->priv;

	u8 buf[2];

	u8 cmd     = VEND_REQ_MDIO;
	u8 reqtype = USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_INTERFACE;
	u16 value  = ((phy_id) << 8) | idx;
	u16 index  = dev->intf->cur_altsetting->desc.bInterfaceNumber;

	err = usbnet_read_cmd( dev, cmd, reqtype, value, index, buf, sizeof(buf) );
	if ( err < 0 ) {
		return err;
	}
	if ( err < 2 ) {
		return -EIO;
	}
	return (buf[1]<<8) | buf[0];
}

STATIC int cdc_ncm_ptp_mdio_write(struct mii_bus *bus, int phy_id, int idx, u16 regval)
{
	struct usbnet *dev = (struct usbnet*)bus->priv;
	int            st;

	u8 buf[2];

	u8 cmd     = VEND_REQ_MDIO;
	u8 reqtype = USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_INTERFACE;
	u16 value  = ((phy_id) << 8) | idx;
	u16 index  = dev->intf->cur_altsetting->desc.bInterfaceNumber;

	buf[0] = (regval >> 0) & 0xff;
	buf[1] = (regval >> 8) & 0xff;

	st = usbnet_write_cmd( dev, cmd, reqtype, value, index, buf, sizeof(buf) );
	return st < 0 ? st : 0;
}

/* mac-address has already been set in the netdevice; just propagate to the firmware */
STATIC int set_addr(struct usbnet *dev)
{
	int st = usbnet_write_cmd( dev,
		                       USB_CDC_SET_NET_ADDRESS,
		                       (USB_TYPE_CLASS | USB_DIR_OUT | USB_RECIP_INTERFACE),
		                       0,
		                       dev->intf->cur_altsetting->desc.bInterfaceNumber,
		                       dev->net->dev_addr, ETH_ALEN );
	return st < 0 ? st : 0;
}

STATIC int try_set_addr(struct usbnet *dev)
{
	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx*)dev->data[0]; /* how ugly is that! */

	/* cdc_ncm unfortunately does not export cdc_ncm_flags :-( */
	if ( ctx->func_desc && (ctx->func_desc->bmNetworkCapabilities & USB_CDC_NCM_NCAP_NET_ADDRESS) ) {
		/* see if we would succeed; netdevice still holds our old address */
		return set_addr( dev );
	}
	return -ENOTSUPP;
}

STATIC int ndev_handler(struct notifier_block *nblk, unsigned long event, void *closure)
{
	struct net_device                  *ndev = netdev_notifier_info_to_dev( closure );
	struct usbnet                      *dev  = netdev_priv( ndev );
	int                                 st   = 0;

	switch ( event ) {
		case NETDEV_PRE_CHANGEADDR:
			st = try_set_addr( dev );
			break;

		case NETDEV_CHANGEADDR:
			/* dev_set_mac_address does not check the return value and it has already
			 * changed the cached mac_address in the network stack. This
			 * following call must not fail!
			 */
			st = set_addr( dev );
			break;

		default: break;
	}

	return ( 0 == st ) ? NOTIFY_DONE : NOTIFY_BAD;
}

static struct notifier_block cdc_ncm_ptp_notifier = {
	.notifier_call = ndev_handler
};

STATIC int cdc_ncm_ptp_inifini(struct usbnet *dev, struct usb_interface *intf, int ini)
{
	struct cdc_ncm_ptp_priv *priv    = dev->driver_priv;
	struct mii_bus          *mdiobus = NULL;
	struct phy_device       *phydev  = NULL;
	int                      st      = !ini ? 0 : -ENODEV;
	struct sockaddr          sarnd;

	if ( ini ) {

		/* cdc_ncm does not (luckliy) seem to use driver_priv -- they attach
		 * their data to dev->data[0]!
		 */
		BUG_ON( dev->driver_priv != NULL );

		if ( ! (priv = kzalloc( sizeof(*priv), GFP_KERNEL )) ) {
			st = -ENOMEM;
			goto priv_not_alloced;
		}
		dev->driver_priv  = priv;

		if ( ! (mdiobus = mdiobus_alloc()) ) {
			st = -ENOMEM;
			goto mdiobus_not_alloced;
		}
		priv->mdiobus = mdiobus;

		mdiobus->phy_mask = ~(1u << (PHY_ID));
		mdiobus->priv     = dev;
		mdiobus->read     = cdc_ncm_ptp_mdio_read;
		mdiobus->write    = cdc_ncm_ptp_mdio_write;
		mdiobus->name     = "cdc-ncm-ptp-mdio";
		mdiobus->parent   = &dev->udev->dev;

		BUG_ON( ! intf->cur_altsetting );

		snprintf(mdiobus->id, ARRAY_SIZE(mdiobus->id),
				"usb-%03d:%03d.%d",
				dev->udev->bus->busnum,
				dev->udev->devnum,
				intf->cur_altsetting->desc.bInterfaceNumber);

		st = mdiobus_register(mdiobus);
		if ( st ) {
			netdev_err(dev->net, "Unable to register MDIO bus %d\n", st);
			goto mdiobus_not_registered;
		}

		phydev = mdiobus_get_phy( priv->mdiobus, PHY_ID );
		if ( ! phydev ) {
			netdev_err(dev->net, "PHY not found!\n");
			st = -ENODEV;
			goto phy_not_found;
		}
		priv->phydev = phydev;

		st = phy_attach_direct( dev->net, phydev, 0, PHY_INTERFACE_MODE_INTERNAL );
		if ( st ) {
			netdev_err(dev->net, "Unable to attach PHY to network adapter '%d'\n", st);
			goto phy_not_attached;
		}

		st = register_netdevice_notifier( &cdc_ncm_ptp_notifier );
		if ( st ) {
			netdev_err(dev->net, "Unable to register notifier '%d'\n", st);
			goto notifier_not_registered;
		}

        /*
         * The address from the descriptors might be generic (multiple firmwares
         * with the same descriptors and hence MAC addr). Unless told otherwise
         * by module parameter we randomize the address...
		 * Note that we need our 'cdc_ncm_ptp_notifier' installed for this to
		 * work.
		 */
		if ( random_mac_addr ) {
			sarnd.sa_family = ARPHRD_ETHER;
			random_ether_addr( sarnd.sa_data );

			rtnl_lock();
			st = dev_set_mac_address( dev->net, &sarnd, NULL );
			rtnl_unlock();
			if ( st < 0 ) {
				netdev_err( dev->net, "Unable to set random MAC address: %d\n", st );
			} else {
				netdev_info( dev->net, "Using a random MAC address\n");
			}
		}

		return 0;

	}

	unregister_netdevice_notifier( &cdc_ncm_ptp_notifier );
notifier_not_registered:
	/* the dp83640 driver will complain:
     *  'expected to find an attached netdevice'
	 * but phy_detach deattaches the netdevice before it calls
	 * the driver 'remove' function which will cause this message...
	 */
	phy_detach( priv->phydev );
phy_not_attached:
phy_not_found:
	mdiobus_unregister( priv->mdiobus );
mdiobus_not_registered:
	mdiobus_free( priv->mdiobus );
mdiobus_not_alloced:
	kfree( dev->driver_priv );
	dev->driver_priv = NULL;
priv_not_alloced:
	return st;
}

STATIC int cdc_ncm_ptp_bind(struct usbnet *dev, struct usb_interface *intf)
{
	/* The NCM data altsetting is fixed, so we hard-coded it.
	 * Additionally, generic NCM devices are assumed to accept arbitrarily
	 * placed NDP.
	 */
	int rv = cdc_ncm_bind_common(dev, intf, CDC_NCM_DATA_ALTSETTING_NCM, 0);
	return rv;
}

/* Unfortunately not public :-( */
STATIC void
cdc_ncm_speed_change(struct usbnet *dev,
             struct usb_cdc_speed_change *data)
{
    /* RTL8156 shipped before 2021 sends notification about every 32ms. */
    dev->rx_speed = le32_to_cpu(data->DLBitRRate);
    dev->tx_speed = le32_to_cpu(data->ULBitRate);
}

STATIC void cdc_ncm_status(struct usbnet *dev, struct urb *urb)
{
	struct usb_cdc_notification *event;

	if (urb->actual_length < sizeof(*event))
		return;

	/* test for split data in 8-byte chunks */
	if (test_and_clear_bit(EVENT_STS_SPLIT, &dev->flags)) {
		cdc_ncm_speed_change(dev,
		      (struct usb_cdc_speed_change *)urb->transfer_buffer);
		return;
	}

	event = urb->transfer_buffer;

	switch (event->bNotificationType) {
	case USB_CDC_NOTIFY_NETWORK_CONNECTION:
		/*
		 * According to the CDC NCM specification ch.7.1
		 * USB_CDC_NOTIFY_NETWORK_CONNECTION notification shall be
		 * sent by device after USB_CDC_NOTIFY_SPEED_CHANGE.
		 */
		/* RTL8156 shipped before 2021 sends notification about
		 * every 32ms. Don't forward notification if state is same.
		 */
		if (netif_carrier_ok(dev->net) != !!event->wValue)
			usbnet_link_change(dev, !!event->wValue, 0);
		break;

	case USB_CDC_NOTIFY_SPEED_CHANGE:
		if (urb->actual_length < (sizeof(*event) +
					sizeof(struct usb_cdc_speed_change)))
			set_bit(EVENT_STS_SPLIT, &dev->flags);
		else
			cdc_ncm_speed_change(dev,
					     (struct usb_cdc_speed_change *)&event[1]);
		break;

	default:
		dev_dbg(&dev->udev->dev,
			"NCM: unexpected notification 0x%02x!\n",
			event->bNotificationType);
		break;
	}
}

STATIC
int ncm_ptp_probe(struct usb_interface *intf, const struct usb_device_id *prod)
{
	struct usbnet *dev;
	int st = usbnet_probe( intf, prod );
	if ( 0 == st ) {
		dev = usb_get_intfdata(intf);

		st = cdc_ncm_ptp_inifini(dev, intf, 1);

		if ( st < 0 ) {
			usbnet_disconnect(intf);
			return st;
		}

		/* we have FLAG_LINK_INTR set and usbnet_probe sets the initial link
		 * status to 'down' - relying on the initial notification from the
		 * endpoint. However, if e.g., the driver is re-bound then this
		 * notification never happens. Hence we query the initial link state
		 * here.
		 */
		if ( usbnet_get_link(dev->net) ) {
			usbnet_link_change(dev, 1, 0);
		}
	}
	return st;
}

STATIC
void ncm_ptp_disconnect(struct usb_interface *intf)
{
	struct usbnet *dev = usb_get_intfdata(intf);
	if ( ! dev ) {
		/* usbnet_disconnect has this test also */
		return;
	}
	cdc_ncm_ptp_inifini(dev, intf, 0);
	usbnet_disconnect(intf);
}

STATIC
void update_filter(struct usbnet *dev)
{
    struct net_device   *net = dev->net;
    u16                  cdc_filter;
	int                  st = 0;

	/* Enable all directed filters */
    cdc_filter =    USB_CDC_PACKET_TYPE_DIRECTED
	              | USB_CDC_PACKET_TYPE_BROADCAST
	              | USB_CDC_PACKET_TYPE_MULTICAST;

    /* filtering on the device is an optional feature and not worth
     * the hassle so we just roughly care about snooping and if any
     * multicast is requested, we take every multicast
     */
    if (net->flags & IFF_PROMISC) {
        cdc_filter |= USB_CDC_PACKET_TYPE_PROMISCUOUS;
    } else if (net->flags & IFF_ALLMULTI) {
        cdc_filter |= USB_CDC_PACKET_TYPE_ALL_MULTICAST;
    } else {

		u8                    *mc_buf = 0;
		unsigned               mc_cnt = 0;
		struct netdev_hw_addr *ha;
		u8                    *p;
		unsigned               bufl;

		mc_cnt = netdev_mc_count( net );
		bufl   = mc_cnt * ETH_ALEN;

		st = 0;
		if ( mc_cnt > 0 ) {
			if ( ( mc_buf = kmalloc( bufl, GFP_KERNEL ) ) ) {
				p = mc_buf;
				netdev_for_each_mc_addr( ha, net ) {
					memcpy( p, ha->addr, ETH_ALEN );
					p += ETH_ALEN;
				}
			} else {
				st = -1;
			}
		}

		if ( 0 == st ) {
			/* we also get here if we clear the list (mc_cnt == 0) */
			st = usb_control_msg(dev->udev,
					usb_sndctrlpipe(dev->udev, 0),
					USB_CDC_SET_ETHERNET_MULTICAST_FILTERS,
					USB_TYPE_CLASS | USB_RECIP_INTERFACE,
					mc_cnt,
					dev->intf->cur_altsetting->desc.bInterfaceNumber,
					mc_buf,
					bufl,
					USB_CTRL_SET_TIMEOUT
					);

			if ( st < (int)bufl ) {
				netdev_warn( net, "Failed to set multicast filters (st = %d); falling back to allmulti\n", st );
			}
		}
		if ( st < 0 ) {
       		cdc_filter |= USB_CDC_PACKET_TYPE_ALL_MULTICAST;
		}
		if ( mc_buf ) {
			kfree( mc_buf );
		}
	}

	st = usb_control_msg(dev->udev,
            usb_sndctrlpipe(dev->udev, 0),
            USB_CDC_SET_ETHERNET_PACKET_FILTER,
            USB_TYPE_CLASS | USB_RECIP_INTERFACE,
            cdc_filter,
            dev->intf->cur_altsetting->desc.bInterfaceNumber,
            NULL,
            0,
            USB_CTRL_SET_TIMEOUT
        );

	if ( st < 0 ) {
		netdev_err( net, "Failed to set packet filters (st = %d); hope the device passes everything up\n", st);
	}
}

static const struct driver_info cdc_ncm_ptp_info = {
	.description = "CDC NCM with PTP Phy",
	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
			| FLAG_LINK_INTR | FLAG_ETHER,
    .check_connect = NULL,
	.bind = cdc_ncm_ptp_bind,
	.unbind = cdc_ncm_unbind,
	.manage_power = usbnet_manage_power,
	.status = cdc_ncm_status,
	.rx_fixup = cdc_ncm_rx_fixup,
	.tx_fixup = cdc_ncm_tx_fixup,
	.set_rx_mode = update_filter,
};

static const struct usb_device_id cdc_ncm_ptp_devs[] = {
	/* PIDcodes 0x0001 */
	{ USB_DEVICE_AND_INTERFACE_INFO(0x1209, 0x0001,
		USB_CLASS_COMM,
		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
		.driver_info = (unsigned long)&cdc_ncm_ptp_info,
	},
	{
	}
};
MODULE_DEVICE_TABLE(usb, cdc_ncm_ptp_devs);

static struct usb_driver cdc_ncm_ptp_driver = {
	.name = "cdc_tic_nic",
	.id_table = cdc_ncm_ptp_devs,
	.probe = ncm_ptp_probe,
	.disconnect = ncm_ptp_disconnect,
	.suspend = usbnet_suspend,
	.resume = usbnet_resume,
	.reset_resume =	usbnet_resume,
	.supports_autosuspend = 1,
	.disable_hub_initiated_lpm = 1,
};

module_usb_driver(cdc_ncm_ptp_driver);

MODULE_AUTHOR("Till Straumann");
MODULE_DESCRIPTION("USB CDC NCM host driver wrapper with USB connection to DP83640 PHY");
MODULE_LICENSE("Dual BSD/GPL");
