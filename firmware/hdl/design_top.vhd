library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.UlpiPkg.all;
use     work.Usb2Pkg.all;
use     work.Usb2UtilPkg.all;
use     work.Usb2AppCfgPkg.all;
use     work.Usb2DescPkg.all;
use     work.Usb2MuxEpCtlPkg.all;
use     work.Usb2EpGenericCtlPkg.all;
use     work.Usb2AppCfgPkg.all;
use     work.CommandMuxPkg.all;
use     work.BasicPkg.Slv8Array;
use     work.RMIIMacPkg.all;
use     work.GitVersionPkg.all;
use     work.UartPkg.all;

-- differences to V1
--
--       V2.1         V1         PIN      Comments (using design on V1 board)
--   fpgaGpio(5)    eth_txd(3)    54      dont' use
--   fpgaGpio(6)    eth_txd(2)    55      dont' use
--   fpgaGpio(7)    eth_rxd(2)    65      dont' use
--   gpsRstb        eth_rxd(3)    66      open or pull-up
--   gpsPps         fpgaGpio(7)   45      [3]
--   gpsRx          fpgaGpio(5)   42      UART RX on fpgaGpio(5) (fpga OUT)
--   gpsTx          fpgaGpio(6)   43      UART TX on fpgaGpio(6) (fpga INP)
--   N/C [1]        fpgaGpio(0)   36      don't use
--   fpgaGpio(0)    N/C [2]       32      don't use
--   eth_gpio_1     fpga_b3_io_2  89      don't use
--   eth_gpio_2     fpga_b3_io_1  90      don't use
--   eth_clk_out    fpga_b3_io_0  93      don't use
--
-- NOTES:
--   [1] connected to fpgaGpio(0) on V2.0
--   [2] N/C on V2.0
--   [3] pulldown on this pin not supported; if spurious LED signal
--       is a problem then strap fpgaGpio(7) to GND (V1 board).
--
entity design_top is
   port (
      ulpiClk           : in    std_logic;
      -- NOTE    : unfortunately, the ulpiClk stops while ulpiRstb is asserted...
      ulpiRstb          : out   std_logic                    := '1';
      ulpiDat_IN        : in    std_logic_vector(7 downto 0) := (others => '0');
      ulpiDat_OUT       : out   std_logic_vector(7 downto 0) := (others => '0');
      ulpiDat_OE        : out   std_logic_vector(7 downto 0) := (others => '0');
      ulpiDir           : in    std_logic                    := '0';
      ulpiNxt           : in    std_logic                    := '0';
      ulpiStp_IN        : in    std_logic                    := '0';
      ulpiStp_OUT       : out   std_logic                    := '0';
      ulpiStp_OE        : out   std_logic                    := '0';
      LED               : out   std_logic_vector(7 downto 0) := (others => '1');
      ulpiPllLocked     : in    std_logic;
      rmiiPllLocked     : in    std_logic := '0';

      spiSClk           : out   std_logic;
      spiMOSI           : out   std_logic;
      spiMISO           : in    std_logic;
      spiCSb_OUT        : out   std_logic;
      spiCSb_OE         : out   std_logic := '1';
      spiCSb_IN         : in    std_logic;

      rmii_clk          : in    std_logic;
      eth_rstb          : out   std_logic := '1';
      eth_pwrdwn_irq_IN : in    std_logic;
      eth_pwrdwn_irq_OUT: out   std_logic := '0';
      eth_pwrdwn_irq_OE : out   std_logic := '0';

      eth_mdc           : out   std_logic := '0';
      eth_mdio_IN       : in    std_logic;
      eth_mdio_OUT      : out   std_logic := '1';
      eth_mdio_OE       : out   std_logic := '0';

      eth_gpio_1_IN     : in    std_logic;
      eth_gpio_1_OUT    : out   std_logic := '0';
      eth_gpio_1_OE     : out   std_logic := '0';
      eth_gpio_2_IN     : in    std_logic;
      eth_gpio_2_OUT    : out   std_logic := '0';
      eth_gpio_2_OE     : out   std_logic := '0';
      eth_gpio_9_IN     : in    std_logic;
      eth_gpio_9_OUT    : out   std_logic := '0';
      eth_gpio_9_OE     : out   std_logic := '0';

      eth_tx_en         : out   std_logic := '0';
      eth_txd           : out   std_logic_vector(1 downto 0) := (others => '0');

      eth_rx_dv         : in    std_logic;
      eth_crs_dv        : in    std_logic;
      eth_rx_col        : in    std_logic;
      eth_rx_err        : in    std_logic;
      eth_rxd           : in    std_logic_vector(1 downto 0);

      gpsPps            : in    std_logic;
      -- to be compatible with V1 board leave Rstb floating or
      -- pulled-up.
      -- If the output is activated the FW should no longer be
      -- used on V1 hardware.
      gpsRstb_IN        : in    std_logic;
      gpsRstb_OUT       : out   std_logic := '0';
      gpsRstb_OE        : out   std_logic := '0';

      -- note: fpgaGpio[0] *not* available on V2.0 board (only starting with 2.1)
      fpgaGpio_IN       : in    std_logic_vector(7 downto 0) := (others => '0');
      fpgaGpio_OUT      : out   std_logic_vector(7 downto 0) := (others => '0');
      fpgaGpio_OE       : out   std_logic_vector(7 downto 0) := (others => '0');

      gpsRx             : out   std_logic;
      gpsTx             : in    std_logic
   );
end entity design_top;

architecture rtl of design_top is

   attribute ASYNC_REG         : string;
   attribute SYN_PRESERVE      : boolean;

   constant BOARD_VERSION_C    : std_logic_vector(7 downto 0) := x"21";

   -- must cover bulk max pkt size
   constant LD_FIFO_OUT_C      : natural :=  9;
   constant LD_FIFO_INP_C      : natural :=  9;

   constant LD_RATE_C          : natural := 22;
   constant ULPI_FREQ_C        : natural := 60000000;
   constant UART_MAX_BITS_C    : natural := 8;

   constant NCM_IF_ASSOC_IDX_C : integer := usb2NextIfcAssocDescriptor(
      USB2_APP_DESCRIPTORS_C,
      0,
      USB2_IFC_CLASS_CDC_C,
      USB2_IFC_SUBCLASS_CDC_NCM_C,
      USB2_IFC_PROTOCOL_NONE_C
   );

   constant NCM_IFC_NUM_C      : natural := to_integer( unsigned( USB2_APP_DESCRIPTORS_C( NCM_IF_ASSOC_IDX_C + 2 ) ) );

   constant EP0_AGENT_CFG_C    : Usb2CtlEpAgentConfigArray := (
      0 => usb2CtlEpMkAgentConfig(
         recipient => USB2_REQ_TYP_RECIPIENT_IFC_C,
         index     => NCM_IFC_NUM_C,
         reqType   => USB2_REQ_TYP_TYPE_VENDOR_C
      ),
      1 => usb2CtlEpMkAgentConfig(
         recipient => USB2_REQ_TYP_RECIPIENT_DEV_C,
         index     => 0,
         reqType   => USB2_REQ_TYP_TYPE_VENDOR_C
      ),
      2 => usb2CtlEpMkAgentConfig(
         recipient => USB2_REQ_TYP_RECIPIENT_DEV_C,
         index     => 1,
         reqType   => USB2_REQ_TYP_TYPE_VENDOR_C
      )
   );

   constant REQ_LED_CTL_C     : Usb2CtlRequestCodeType := x"01";
   constant REQ_GPIO_CTL_C    : Usb2CtlRequestCodeType := x"02";

   constant REQ_LED_WR_IDX_C  : natural                := 0;
   constant REQ_LED_RD_IDX_C  : natural                := 1;
   constant REQ_GPIO_WR_IDX_C : natural                := 2;
   constant REQ_GPIO_RD_IDX_C : natural                := 3;

   constant EP0_DEV_AGENT_REQS_C : Usb2EpGenericReqDefArray := (
      REQ_LED_WR_IDX_C => usb2MkEpGenericReqDef(
         dev2Host  => '0',
         request   => REQ_LED_CTL_C,
         dataSize  => 2
      ),
      REQ_LED_RD_IDX_C => usb2MkEpGenericReqDef(
         dev2Host  => '1',
         request   => REQ_LED_CTL_C,
         dataSize  => 2
      ),
      REQ_GPIO_WR_IDX_C => usb2MkEpGenericReqDef(
         dev2Host  => '0',
         request   => REQ_GPIO_CTL_C,
         dataSize  => 2
      ),
      REQ_GPIO_RD_IDX_C => usb2MkEpGenericReqDef(
         dev2Host  => '1',
         request   => REQ_GPIO_CTL_C,
         dataSize  => 2
      )
   );

   signal ep0DevAgentParmsIb   : Usb2ByteArray(0 to maxParamSize(EP0_DEV_AGENT_REQS_C) - 1) := (others => (others =>'0'));
   signal ep0DevAgentParmsOb   : Usb2ByteArray(0 to maxParamSize(EP0_DEV_AGENT_REQS_C) - 1);
   signal ep0DevAgentParmsVld  : std_logic_vector(EP0_DEV_AGENT_REQS_C'range);
   signal ep0DevAgentParmsAck  : std_logic := '1';
   signal ep0DevAgentParmsErr  : std_logic := '0';

   signal acmFifoOutDat        : Usb2ByteType;
   signal acmFifoOutEmpty      : std_logic;
   signal acmFifoOutRen        : std_logic    := '1';
   signal acmFifoOutVld        : std_logic    := '0';
   signal acmFifoInpDat        : Usb2ByteType := (others => '0');
   signal acmFifoInpFull       : std_logic;
   signal acmFifoInpWen        : std_logic    := '0';

   signal acmFifoInpMinFill    : unsigned(LD_FIFO_INP_C - 1 downto 0) := (others=> '0');
   signal acmFifoInpTimer      : unsigned(32 - 1 downto 0) := (others=> '0');

   signal acmFifoLocal         : std_logic    := '1';

   signal acmDTR               : std_logic;
   signal acmRTS               : std_logic;
   signal acmRate              : unsigned(31 downto 0);
   signal acmStopBits          : unsigned( 1 downto 0);
   signal acmDataBits          : unsigned( 4 downto 0);
   signal acmParity            : unsigned( 2 downto 0);

   signal acmLineBreak         : std_logic := '0';
   signal acmOverRun           : std_logic := '0';
   signal acmParityError       : std_logic := '0';
   signal acmFramingError      : std_logic := '0';
   signal acmRingDetect        : std_logic := '0';
   signal acmBreakState        : std_logic := '0';

   signal uartRst              : std_logic := '0';

   signal uartRxDat            : std_logic_vector(UART_MAX_BITS_C - 1 downto 0) := (others => '0');
   signal uartRxDatVld         : std_logic := '0';
   signal uartTxDat            : std_logic_vector(UART_MAX_BITS_C - 1 downto 0) := (others => '0');
   signal uartTxDatVld         : std_logic := '0';
   signal uartTxDatRdy         : std_logic := '0';

   signal uartLineBreak        : std_logic := '0';
   signal uartOverRun          : std_logic := '0';
   signal uartParityError      : std_logic := '0';
   signal uartFramingError     : std_logic := '0';
   signal uartBreakState       : std_logic := '0';

   signal uartCfgParity        : UartParityType;
   signal uartCfgStopBits      : UartStopBitType;
   signal uartCfgNumBits       : natural range 1 to UART_MAX_BITS_C;

   signal acmFifoRst           : std_logic    := '0';

   signal usb2Rst              : std_logic    := '0';
   signal usb2DevStatus        : Usb2DevStatusType := USB2_DEV_STATUS_INIT_C;

   signal ulpiIb               : UlpiIbType := ULPI_IB_INIT_C;
   signal ulpiOb               : UlpiObType := ULPI_OB_INIT_C;
   signal ulpiRx               : UlpiRxType;
   signal ulpiRst              : std_logic := '0';
   signal ulpiForceStp         : std_logic := '0';
   signal usb2HiSpeedEn        : std_logic := '1';
   signal ulpiDirB             : std_logic;
   signal ulpiClkBlink         : std_logic;
   signal rmiiClkBlink         : std_logic;

   signal fifoRDat             : Usb2ByteType;
   signal fifoRRdy             : std_logic;
   signal fifoRVld             : std_logic;
   signal fifoWDat             : Usb2ByteType;
   signal fifoWRdy             : std_logic;
   signal fifoWVld             : std_logic;

   signal ncmFifoOutDat        : std_logic_vector(7 downto 0) := (others => '0');
   signal ncmFifoOutLast       : std_logic := '0';
   signal ncmFifoOutAbrt       : std_logic := '0';
   signal ncmFifoOutEmpty      : std_logic := '0';
   signal ncmFifoOutVld        : std_logic := '0';
   signal ncmFifoOutHaveCrc    : std_logic := '0';
   signal ncmFifoOutRen        : std_logic := '1';

   signal ncmFifoInpDat        : std_logic_vector(7 downto 0) := (others => '0');
   signal ncmFifoInpLast       : std_logic := '0';
   signal ncmFifoInpAbrt       : std_logic := '0';
   signal ncmFifoInpBusy       : std_logic := '0';
   signal ncmFifoInpFull       : std_logic := '0';
   signal ncmFifoInpWen        : std_logic := '0';

   signal ncmCarrier           : std_logic := '1';
   -- ECM, 6.2.4, Tbl-8: D(4): forward filtered (ordinary) mcst,
   --                    D(3): forward (ordinary) bcst
   --                    D(2): forward (ordinary) ucst
   --                    D(1): forward all multicast
   --                    D(0): promiscuous mode
   signal ncmPacketFilter      : std_logic_vector(4 downto 0) := "11111";
   signal ncmSpeed             : unsigned(31 downto 0)        := to_unsigned( 100000000, 32 );
   signal ncmSpeed10           : std_logic;
   signal ncmMacAddr           : Usb2ByteArray(0 to 5);

   signal ncmMCFilter          : EthMulticastFilterType := ETH_MULTICAST_FILTER_ALL_C;
   signal ncmMCFilterIn        : EthMulticastFilterType := ETH_MULTICAST_FILTER_ALL_C;
   signal ncmMCFilterUpd       : std_logic              := '0';

   signal ncmMCFilterDat       : Usb2ByteType;
   signal ncmMCFilterVld       : std_logic;
   signal ncmMCFilterDon       : std_logic;

   signal ethMacMCFilter       : EthMulticastFilterType := ETH_MULTICAST_FILTER_ALL_C;
   signal ethMacAppendCrc      : std_logic := '1';
   signal ethMacRxRdy          : std_logic := '0';
   signal ethMacRxRst          : std_logic := '0';
   signal ethMacRxAbrt         : std_logic := '0';
   signal ethMacTxRst          : std_logic := '0';
   signal ethMacSpeed10        : std_logic := '0';
   signal ethMacLinkOk         : std_logic := '1';
   signal ethMacDuplexFull     : std_logic := '1';
   signal ethMacColl           : std_logic := '0';
   signal ethMacPromisc        : std_logic := '0';
   signal ethMacAllmulti       : std_logic := '1';
   signal ethMacAddr           : std_logic_vector(47 downto 0);

   -- ethMacLinkOk may be forced on (otherwise linux does not receive the
   -- DP83640 status frames!
   -- ethPhyLinkOk is the status of the physical link
   signal ethPhyLinkOk         : std_logic := '1';

   signal usb2Ep0ReqParam      : Usb2CtlReqParamArray( EP0_AGENT_CFG_C'range );
   signal usb2Ep0ObExt         : Usb2EndpPairObType;
   signal usb2Ep0IbExt         : Usb2EndpPairIbArray( EP0_AGENT_CFG_C'range ) := (others => USB2_ENDP_PAIR_IB_INIT_C );
   signal usb2Ep0CtlExt        : Usb2CtlExtArray( EP0_AGENT_CFG_C'range ):= (others => USB2_CTL_EXT_NAK_C);
   signal mdioClk              : std_logic;
   signal mdioDatOut           : std_logic;
   signal mdioDatInp           : std_logic;
   signal mdioDatHiZ           : std_logic;
   signal mdioEp0ReqParam      : Usb2CtlReqParamType;
   signal mdioEp0IbExt         : Usb2EndpPairIbType;
   signal mdioEp0CtlExt        : Usb2CtlExtType;

   signal uartRxSync           : std_logic;

   signal ledDiagRegs          : Usb2ByteArray(0 to 1) := (others => (others => '0'));
   signal ledIn                : std_logic_vector(LED'range);
   signal gpioRegs             : Usb2ByteArray(0 to 1) := (others => (others => '0'));
   signal gpioIn               : std_logic_vector(7 downto 0);

begin

   P_INI : process ( ulpiClk ) is
      variable cnt : unsigned(29 downto 0)        := (others => '1');
      variable rst : std_logic_vector(3 downto 0) := (others => '1');
      attribute ASYNC_REG of rst : variable is "TRUE";
   begin
      if ( rising_edge( ulpiClk ) ) then
         if ( cnt( cnt'left ) = '1' ) then
            cnt := cnt - 1;
         end if;
         rst := not ulpiPllLocked & rst(rst'left downto 1);
      end if;
      ulpiRst      <= rst(0);
      usb2Rst      <= rst(0);
   end process P_INI;

   acmFifoOutVld <= not acmFifoOutEmpty;

   fifoRDat      <= acmFifoOutDat;
   uartTxDat     <= acmFifoOutDat;

   P_UART_MUX : process (
      acmDTR,
      acmFifoOutVld,
      acmFifoInpFull,
      fifoRRdy,
      fifoWDat,
      fifoWVld,
      uartRxDat,
      uartRxDatVld,
      uartTxDatRdy,
      acmFifoRst,
      acmLineBreak
   ) is
   begin
      if ( acmDTR = '0' ) then
         fifoRVld      <= acmFifoOutVld;
         uartTxDatVld  <= '0';
         acmFifoOutRen <= fifoRRdy;

         acmFifoInpDat <= fifoWDat;
         acmFifoInpWen <= fifoWVld;
         fifoWRdy      <= not acmFifoInpFull;

         uartLineBreak <= '0';
         uartRst       <= '1';
      else
         fifoRVld      <= '0';
         uartTxDatVld  <= acmFifoOutVld;
         acmFifoOutRen <= uartTxDatRdy;

         acmFifoInpDat <= uartRxDat;
         acmFifoInpWen <= uartRxDatVld;
         fifoWRdy      <= '0';

         uartLineBreak <= acmLineBreak;
         uartRst       <= acmFifoRst;
      end if;
   end process P_UART_MUX;

   P_UART_CFG_COMB : process ( acmParity, acmStopBits, acmDataBits ) is
   begin
      case ( to_integer(acmParity) ) is
         when 1      => uartCfgParity <= ODD;
         when 2      => uartCfgParity <= EVEN;
         when 3      => uartCfgParity <= MARK;
         when 4      => uartCfgParity <= SPACE;
         when others => uartCfgParity <= NONE;
      end case;
      case ( to_integer(acmDataBits) ) is
         when 5 | 6 | 7 => uartCfgNumBits <= to_integer(acmDataBits);
         when others    => uartCfgNumBits <= 8;
      end case;
      case ( to_integer(acmStopBits) ) is
         when 1      => uartCfgStopBits <= ONEP5;
         when 2      => uartCfgStopBits <= TWO;
         when others => uartCfgStopBits <= ONE;
      end case;
   end process P_UART_CFG_COMB;

   U_UART : entity work.UartWrapper
      generic map (
         -- main clock frequency
         CLOCK_FREQ_G   => ULPI_FREQ_C,
         -- max # of bits of rate
         LD_RATE_G      => LD_RATE_C,
         -- max. data width
         DATA_WIDTH_G   => UART_MAX_BITS_C,
         DEBOUNCE_G     => 0
      )
      port map (
         clk            => ulpiClk,
         rst            => uartRst,

         rxData         => uartRxDat,
         rxDataRdy      => '1',
         rxDataVld      => uartRxDatVld,
         rxBreak        => uartBreakState,
         rxParityErr    => uartParityError,
         rxFramingErr   => uartFramingError,
         rxOverrunErr   => uartOverRun,

         txData         => uartTxDat,
         txDataVld      => uartTxDatVld,
         txDataRdy      => uartTxDatRdy,
         txBreak        => uartLineBreak,

         cfgParity      => uartCfgParity,
         cfgStopBits    => uartCfgStopBits,
         cfgNumBits     => uartCfgNumBits,

         cfgBitRateHz   => acmRate(LD_RATE_C - 1 downto 0),
         clearErrors    => '1',

         rxSerial       => uartRxSync,
         txSerial       => gpsRx
      );

   U_RX_SYNC : entity work.Usb2CCSync
      generic map (
         STAGES_G       => 3,
         INIT_G         => '1'
      )
      port map (
         clk            => ulpiClk,
         rst            => acmFifoRst,
         d              => gpsTx,
         q              => uartRxSync
      );

   U_CMD : entity work.CommandWrapper
   generic map (
      GIT_VERSION_G                => GIT_VERSION_C,
      BOARD_VERSION_G              => BOARD_VERSION_C,
      FIFO_FREQ_G                  => 60.0E6,
      HAVE_SPI_CMD_G               => true,
      HAVE_REG_CMD_G               => false,
      HAVE_BB_CMD_G                => false,
      HAVE_ADC_CMD_G               => false,
      REG_ASYNC_G                  => false
   )
   port map (
      clk                          => ulpiClk,
      rst                          => acmFifoRst,

      datIb                        => fifoRDat,
      vldIb                        => fifoRVld,
      rdyIb                        => fifoRRdy,
      datOb                        => fifoWDat,
      vldOb                        => fifoWVld,
      rdyOb                        => fifoWRdy,

      spiSClk                      => spiSClk,
      spiMOSI                      => spiMOSI,
      spiCSb                       => spiCSb_OUT,
      spiMISO                      => spiMISO
   );

   ulpiDat_OUT   <= ulpiOb.dat;
   ulpiIb.dat    <= ulpiDat_IN;
   ulpiDat_OE    <= (others => ulpiDirB);

   ulpiDirB      <= not ulpiDir;
   ulpiIb.dir    <= ulpiDir;

   ulpiStp_OUT   <= ulpiOb.stp;
   ulpiIb.stp    <= ulpiStp_IN;
   ulpiStp_OE    <= '1';

   ulpiIb.nxt    <= ulpiNxt;

   process ( ulpiClk ) is
      variable cnt : unsigned(25 downto 0) := (others => '0');
   begin
      if ( rising_edge( ulpiClk ) ) then
         cnt := cnt + 1;
      end if;
      ulpiClkBlink <= cnt(cnt'left);
   end process;

   U_USB_DEV : entity work.Usb2ExampleDev
      generic map (
         ULPI_CLK_MODE_INP_G       => false,
         DESCRIPTORS_G             => USB2_APP_DESCRIPTORS_C,
         DESCRIPTORS_BRAM_G        => true,
         LD_ACM_FIFO_DEPTH_INP_G   => LD_FIFO_INP_C,
         LD_ACM_FIFO_DEPTH_OUT_G   => LD_FIFO_OUT_C,
         CDC_ACM_ASYNC_G           => false,
         CDC_NCM_ASYNC_G           => true,
         ULPI_EMU_MODE_G           => NONE,
         CTL_EP0_AGENTS_CONFIG_G   => EP0_AGENT_CFG_C,
         MARK_DEBUG_ULPI_IO_G      => false,
         MARK_DEBUG_PKT_TX_G       => false,
         MARK_DEBUG_PKT_RX_G       => false,
         MARK_DEBUG_PKT_PROC_G     => false
      )
      port map (
         usb2Clk                   => ulpiClk,
         usb2Rst                   => usb2Rst,
         usb2RstOut                => open,
         ulpiRst                   => ulpiRst,
         ulpiIb                    => ulpiIb,
         ulpiOb                    => ulpiOb,
         ulpiRx                    => ulpiRx,
         ulpiForceStp              => ulpiForceStp,

         usb2HiSpeedEn             => usb2HiSpeedEn,

         usb2Ep0ReqParam           => usb2Ep0ReqParam,
         usb2Ep0ObExt              => usb2Ep0ObExt,
         usb2Ep0IbExt              => usb2Ep0IbExt,
         usb2Ep0CtlExt             => usb2Ep0CtlExt,

         usb2DevStatus             => usb2DevStatus,

         acmFifoClk                => ulpiClk,
         acmFifoOutDat             => acmFifoOutDat,
         acmFifoOutEmpty           => acmFifoOutEmpty,
         acmFifoOutRen             => acmFifoOutRen,
         acmFifoInpDat             => acmFifoInpDat,
         acmFifoInpFull            => acmFifoInpFull,
         acmFifoInpWen             => acmFifoInpWen,

         acmFifoInpMinFill         => acmFifoInpMinFill,
         acmFifoInpTimer           => acmFifoInpTimer,
         acmFifoLocal              => acmFifoLocal,

         acmDTR                    => acmDTR,
         acmRTS                    => acmRTS,

         acmRate                   => acmRate,
         acmStopBits               => acmStopBits,
         acmParity                 => acmParity,
         acmDataBits               => acmDataBits,

         acmLineBreak              => acmLineBreak,
         acmOverRun                => acmOverRun,
         acmParityError            => acmParityError,
         acmFramingError           => acmFramingError,
         acmRingDetect             => acmRingDetect,
         acmBreakState             => acmBreakState,


         ncmFifoClk                => rmii_clk,
         ncmFifoOutDat             => ncmFifoOutDat,
         ncmFifoOutLast            => ncmFifoOutLast,
         ncmFifoOutAbrt            => ncmFifoOutAbrt,
         ncmFifoOutEmpty           => ncmFifoOutEmpty,
         ncmFifoOutNeedCrc         => ncmFifoOutHaveCrc,
         ncmFifoOutRen             => ncmFifoOutRen,

         ncmFifoInpDat             => ncmFifoInpDat,
         ncmFifoInpLast            => ncmFifoInpLast,
         ncmFifoInpAbrt            => ncmFifoInpAbrt,
         ncmFifoInpBusy            => ncmFifoInpBusy,
         ncmFifoInpFull            => ncmFifoInpFull,
         ncmFifoInpWen             => ncmFifoInpWen,

         ncmCarrier                => ethMacLinkOk,
         ncmPacketFilter           => ncmPacketFilter,
         ncmSpeedInp               => ncmSpeed,
         ncmSpeedOut               => ncmSpeed,
         ncmMacAddr                => ncmMacAddr,
         ncmMCFilterDat            => ncmMCFilterDat,
         ncmMCFilterVld            => ncmMCFilterVld,
         ncmMCFilterLst            => open,
         ncmMCFilterDon            => ncmMCFilterDon
      );

   P_SPEED_SEL : process ( ncmSpeed10 ) is
   begin
      if ( ncmSpeed10 = '1' ) then
         ncmSpeed <= to_unsigned(  10000000, ncmSpeed'length );
      else
         ncmSpeed <= to_unsigned( 100000000, ncmSpeed'length );
      end if;
   end process P_SPEED_SEL;

   U_SYNC_SPEED : entity work.Usb2CCSync
      generic map ( INIT_G => '0' )
      port    map ( clk => ulpiClk,  d => ethMacSpeed10,      q => ncmSpeed10 );

   U_SYNC_AMULT : entity work.Usb2CCSync
      generic map ( INIT_G => '1' )
      port    map ( clk => rmii_clk, d => ncmPacketFilter(1), q => ethMacAllmulti );

   U_SYNC_PROMI : entity work.Usb2CCSync
      generic map ( INIT_G => '0' )
      port    map ( clk => rmii_clk, d => ncmPacketFilter(0), q => ethMacPromisc  );

   G_SYNC_MAC_BYTE : for i in ncmMacAddr'range generate
      G_SYNC_MAC_BIT : for j in ncmMacAddr(0)'range generate
         U_SYNC : entity work.Usb2CCSync
            generic map ( INIT_G => '1' )
            port    map ( clk => rmii_clk, d => ncmMacAddr(i)(j), q => ethMacAddr(8*i + j) );
      end generate G_SYNC_MAC_BIT;
   end generate G_SYNC_MAC_BYTE;

   -- only instantiates logic if setting MC filters is enabled in the descriptors
   U_SET_MC_FILT : entity work.Usb2SetMCFilter
      generic map (
         DESCRIPTORS_G    => USB2_APP_DESCRIPTORS_C
      )
      port map (
         clk              => ulpiClk,
         rst              => usb2Rst,

         mcFilterStrmDat  => ncmMCFilterDat,
         mcFilterStrmVld  => ncmMCFilterVld,
         mcFilterStrmDon  => ncmMCFilterDon,

         mcFilter         => ncmMCFilterIn,
         mcFilterUpd      => ncmMCFilterUpd
      );

   G_SYNC_MC_FILT : for i in ncmMCFilter'range generate
      U_SYNC : entity work.Usb2CCSync
         port map ( clk => rmii_clk, d => ncmMCFilter(i), q => ethMacMCFilter(i) );
   end generate G_SYNC_MC_FILT;

   -- register MC filters
   P_MC_REG : process ( ulpiClk ) is
   begin
      if ( rising_edge( ulpiClk ) ) then
         if ( usb2Rst = '1' ) then
            ncmMCFilter       <= ETH_MULTICAST_FILTER_ALL_C;
         elsif ( ncmMCFilterUpd = '1' ) then
            ncmMCFilter       <= ncmMCFilterIn;
         end if;
      end if;
   end process P_MC_REG;


   process ( rmii_clk ) is
      variable cnt : integer range -1 to 49999998 := 49999998;
      variable tgl : std_logic := '0';
   begin
      if ( rising_edge( rmii_clk ) ) then
         if ( cnt < 0 ) then
            cnt := 49999998;
            tgl := not tgl;
         else
            cnt := cnt - 1;
         end if;
      end if;
      rmiiClkBlink <= tgl;
   end process;

   ncmFifoOutVld    <= not ncmFifoOutEmpty;
   ethMacAppendCrc  <= not ncmFifoOutHaveCrc;

   U_MAC_TX : entity work.RMIIMacTx
      port map (
         clk                          => rmii_clk,
         rst                          => ethMacTxRst,
         txDat                        => ncmFifoOutDat,
         txVld                        => ncmFifoOutVld,
         txLst                        => ncmFifoOutLast,
         txRdy                        => ncmFifoOutRen,

         rmiiDat                      => eth_txd(1 downto 0),
         rmiiTxEn                     => eth_tx_en,

         coll                         => ethMacColl,
         speed10                      => ethMacSpeed10,
         linkOK                       => ethMacLinkOk,
         appendCRC                    => ethMacAppendCrc
      );

   ethMacRxRdy    <= (not ncmFifoInpBusy and not ncmFifoInpFull);
   ethMacRxRst    <= ethMacRxAbrt or ethMacColl or not ethMacLinkOk;
   ncmFifoInpAbrt <= ethMacRxRst;
   ncmFifoOutAbrt <= ethMacColl;

   U_MAC_RX : entity work.RMIIMacRx
      port map (
         clk                          => rmii_clk,
         rst                          => ethMacRxRst,

         rxDat                        => ncmFifoInpDat,
         rxVld                        => ncmFifoInpWen,
         rxLst                        => ncmFifoInpLast,
         rxRdy                        => ethMacRxRdy,
         rxAbt                        => ethMacRxAbrt,

         rmiiDat                      => eth_rxd(1 downto 0),
         rmiiDV                       => eth_rx_dv,

         macAddr                      => ethMacAddr,
         promisc                      => ethMacPromisc,
         allmulti                     => ethMacAllmulti,
         mcFilter                     => ethMacMCFilter,

         -- misc
         speed10                      => ethMacSpeed10,
         stripCRC                     => '1'
      );

   eth_mdc        <= mdioClk;
   mdioDatInp     <= eth_mdio_IN;
   eth_mdio_OUT   <= mdioDatOut;
   eth_mdio_OE    <= not mdioDatHiZ;

   U_MDIO_CTL : entity work.Usb2Ep0MDIOCtl
      generic map (
         MDC_PRESCALER_G              => 3
      )
      port map (
         usb2Clk                      => ulpiClk,
         usb2Rst                      => usb2Rst,


         usb2CtlReqParam              => mdioEp0ReqParam,
         usb2CtlExt                   => mdioEp0CtlExt,
         usb2EpIb                     => usb2Ep0ObExt,
         usb2EpOb                     => mdioEp0IbExt,

         mdioClk                      => mdioClk,
         mdioDatOut                   => mdioDatOut,
         mdioDatHiZ                   => mdioDatHiZ,
         mdioDatInp                   => mdioDatInp,

         speed10                      => ethMacSpeed10,
         duplexFull                   => ethMacDuplexFull,
         linkOk                       => ethMacLinkOk,
         physicalLinkOk               => ethPhyLinkOk,
         -- full contents; above bits are for convenience
         statusRegPolled              => open
      );

   -- mux the MDIO control endpoint between interface (driver use) and device (user/diagnostic)
   usb2Ep0CtlExt(0) <= mdioEp0CtlExt;
   usb2Ep0CtlExt(2) <= mdioEp0CtlExt;
   usb2Ep0IbExt(0)  <= mdioEp0IbExt;
   usb2Ep0IbExt(2)  <= mdioEp0IbExt;

   P_MDIO_CTL_MUX : process ( usb2Ep0ReqParam ) is
   begin
      if ( usb2Ep0ReqParam(2).vld = '1' ) then
         mdioEp0ReqParam <= usb2Ep0ReqParam(2);
      else
         mdioEp0ReqParam <= usb2Ep0ReqParam(0);
      end if;
   end process P_MDIO_CTL_MUX;

   U_EP0_DEV_CTL : entity work.Usb2EpGenericCtl
      generic map (
         HANDLE_REQUESTS_G            => EP0_DEV_AGENT_REQS_C
      )
      port map (
         usb2Clk                      => ulpiClk,
         usb2Rst                      => usb2Rst,

         usb2CtlReqParam              => usb2Ep0ReqParam(1),
         usb2CtlExt                   => usb2Ep0CtlExt(1),
         usb2EpIb                     => usb2Ep0ObExt,
         usb2EpOb                     => usb2Ep0IbExt(1),

         ctlReqVld                    => ep0DevAgentParmsVld,
         ctlReqAck                    => ep0DevAgentParmsAck,
         ctlReqErr                    => ep0DevAgentParmsErr,

         paramIb                      => ep0DevAgentParmsIb,
         paramOb                      => ep0DevAgentParmsOb
      );

   P_EP0_DEV_REG_OB : process ( ulpiClk ) is
   begin
      if ( rising_edge( ulpiClk ) ) then
         if ( ep0DevAgentParmsVld(REQ_LED_WR_IDX_C) = '1' ) then
            ledDiagRegs <= ep0DevAgentParmsOb(ledDiagRegs'range);
         elsif ( ep0DevAgentParmsVld(REQ_GPIO_WR_IDX_C) = '1' ) then
            gpioRegs    <= ep0DevAgentParmsOb(ledDiagRegs'range);
         end if;
      end if;
   end process P_EP0_DEV_REG_OB;

   P_EP0_DEV_REG_IB : process ( ep0DevAgentParmsVld, ledDiagRegs, gpioIn ) is
   begin
      ep0DevAgentParmsIb  <= (others => (others => '0'));
      ep0DevAgentParmsAck <= '1';
      ep0DevAgentParmsErr <= '0';
      ep0DevAgentParmsIb(ledDiagRegs'range) <= ledDiagRegs;
      if ( ep0DevAgentParmsVld(REQ_GPIO_RD_IDX_C) = '1' ) then
         ep0DevAgentParmsIb(0) <= gpioIn;
         ep0DevAgentParmsIb(1) <= gpioRegs(1);
      end if;
   end process P_EP0_DEV_REG_IB;

   gpioIn      (7 downto 1)  <= fpgaGpio_IN (7 downto 1);
   fpgaGpio_OUT(7 downto 1)  <= gpioRegs(0) (7 downto 1);
   fpgaGpio_OE (7 downto 1)  <= gpioRegs(1) (7 downto 1);
   gpioIn      (         0)  <= eth_gpio_9_IN;
   eth_gpio_9_OUT            <= gpioRegs(0) (         0);
   eth_gpio_9_OE             <= gpioRegs(1) (         0);

   ledIn(7)      <= ethMacPromisc;
   ledIn(6)      <= ethMacAllMulti;
   ledIn(5)      <= usb2DevStatus.suspended;
   ledIn(4)      <= ethMacDuplexFull;
   ledIn(3)      <= ethMacSpeed10;
   ledIn(2)      <= ethPhyLinkOk;
   ledIn(1)      <= not rmiiPllLocked; -- and rmiiClkBlink;
   ledIn(0)      <= gpsPps;

   -- LEDs are active low
   LED           <= not ((ledIn and not ledDiagRegs(1)) or (ledDiagRegs(1) and ledDiagRegs(0))) ;

end architecture rtl;
