/*
 *
 */

#include <linux/module.h>
#include <linux/netdevice.h>
#include <linux/ctype.h>
#include <linux/etherdevice.h>
#include <linux/ethtool.h>
#include <linux/mii.h>
#include <linux/phy.h>
#include <linux/phy_led_triggers.h>
#include <linux/mdio.h>
#include <linux/usb.h>
#include <linux/atomic.h>
#include <linux/usb/usbnet.h>
#include <linux/usb/cdc.h>
#include <linux/usb/cdc_ncm.h>

#define PHY_ID 1
#define VEND_REQ_MDIO 0x01

#define STATIC

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
		printk(KERN_INFO "TSILL try_set_addr found desc\n");
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

	if ( ini ) {

		/* The NCM data altsetting is fixed, so we hard-coded it.
		 * Additionally, generic NCM devices are assumed to accept arbitrarily
		 * placed NDP.
		 */
		st = cdc_ncm_bind_common(dev, intf, CDC_NCM_DATA_ALTSETTING_NCM, 0);
		if ( 0 != st ) {
			goto not_bound;
		}

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

		return 0;

	}

	unregister_netdevice_notifier( &cdc_ncm_ptp_notifier );
notifier_not_registered:
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
	cdc_ncm_unbind( dev, intf );
not_bound:
	return st;
}

STATIC int cdc_ncm_ptp_bind(struct usbnet *dev, struct usb_interface *intf)
{
	return cdc_ncm_ptp_inifini(dev, intf, 1);
}


STATIC void cdc_ncm_ptp_unbind(struct usbnet *dev, struct usb_interface *intf)
{
	(void)cdc_ncm_ptp_inifini(dev, intf, 0);
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
int ncm_ptp_probe(struct usb_interface *udev, const struct usb_device_id *prod)
{
	struct usbnet *dev;
	int st = usbnet_probe( udev, prod );
	if ( 0 == st ) {
		/* we have FLAG_LINK_INTR set and usbnet_probe sets the initial link
		 * status to 'down' - relying on the initial notification from the
		 * endpoint. However, if e.g., the driver is re-bound then this
		 * notification never happens. Hence we query the initial link state
		 * here.
		 */
		dev = usb_get_intfdata(udev);
		if ( usbnet_get_link(dev->net) ) {
			printk(KERN_INFO "ncm_ptp_probe forcing link OK\n");
			usbnet_link_change(dev, 1, 0);
		}
	}
	return st;
}

static const struct driver_info cdc_ncm_info = {
	.description = "CDC NCM",
	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
			| FLAG_LINK_INTR | FLAG_ETHER,
    .check_connect = NULL,
	.bind = cdc_ncm_ptp_bind,
	.unbind = cdc_ncm_ptp_unbind,
	.manage_power = usbnet_manage_power,
	.status = cdc_ncm_status,
	.rx_fixup = cdc_ncm_rx_fixup,
	.tx_fixup = cdc_ncm_tx_fixup,
	.set_rx_mode = usbnet_cdc_update_filter,
};

static const struct usb_device_id cdc_ncm_ptp_devs[] = {
	/* PIDcodes 0x0001 */
	{ USB_DEVICE_AND_INTERFACE_INFO(0x1209, 0x0001,
		USB_CLASS_COMM,
		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
		.driver_info = (unsigned long)&cdc_ncm_info,
	},
	{
	}
};
MODULE_DEVICE_TABLE(usb, cdc_ncm_ptp_devs);

static struct usb_driver cdc_ncm_ptp_driver = {
	.name = "cdc_ncm_ptp",
	.id_table = cdc_ncm_ptp_devs,
	.probe = ncm_ptp_probe,
	.disconnect = usbnet_disconnect,
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
