# Tic-NIC -- A PTP-capable USB Ethernet Adapter

While there is certainly no lack of cheap USB-ethernet adapters
and most modern laptops and networking cards feature PTP-capable
network adapters it is surprisingly difficult to find a cheap
product that provides access to hardware pins that can be used
to generate precisely synchronized events or capture PTP
timestamps.

This is the niche tic-nic tries to fill. It is a very portable
USB gadget with a PTP PHY and clock providing a handfull of
GPIO pins that can be controlled in a synchronous fashion.

## Features

 - DP83640 PHY with several GPIO pins that are available to
   the user.
 - DP83640 is well supported by linux.
 - PTP in the PHY avoids any delays between PHY and MAC.
 - Fully open-source project (hard-, firm- and software).
 - Low cost (PHY plus FPGA are in the order of $20).
   Uses an Efinix Trion T8 or T20 (recommended) device.
 - Remaining FPGA logic and pins for user application.

## Project Structure

The project consists of a kicad hardware design, FPGA
firmware written in VHDL and software.

### Hardware Design

The kicad design files are located in the `kicad` subdirectory.
Note that the project name (`trion-8-test.pro`) and some of
the sheet names are unfortunate and due to legacy reasons.

The design features an SDRAM chip. This component is unused
(I have used the same PCB design for a different project
which exercises this SDRAM). The SDRAM may safely be omitted.

### Firmware

Firmware is located in the `firmware` folder.

The top-level firmware file along with the constraints
and tool-specific project files is located under `efx/`.

The heavy lifting is done by firmware libraries which
are attached as submodules under `firmware/modules`.

We find the `mecatica-usb` and `eth-rmii-mac` modules
which provide the usb device and endpoint implementation
and the ethernet MAC functionality.

The third module `acm-toolbox` is borrowed from another
project. It provides an ACM interface and some software
which allow accessing the configuration flash on the
board. It could also be used as a side-channel to peek/poke
at user FPGA resources.

### Software

The most important software component is the linux driver
which builds on top of the vanilla `cdc_ncm` USB class
driver. Our driver adds functionality to access the PTP
PHY via vendor-specific USB requests. The driver also
establishes a link between the PHY and the ethernet
interface. With these bits in place the heavy machinery of
linux networking and PTP support can be leveraged without
further ado.

Some useful helper programs are not found in the `software`
directory but reside in the submodules.

