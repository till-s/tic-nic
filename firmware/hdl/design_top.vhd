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
use     work.RegPkg.all;
use     work.GenRegPkg.all;

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

      -- reconfiguration
      cfg_CONFIG        : out   std_logic                    := '0';
      cfg_ENA           : out   std_logic                    := '0';
      cfg_CBSEL         : out   std_logic_vector(1 downto 0) := (others => '0');
      cfg_CDONE         : in    std_logic;
      cfg_ERROR         : in    std_logic;

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

      eth_gpio_9_IN     : in    std_logic;
      eth_gpio_9_OUT    : out   std_logic := '0';
      eth_gpio_9_OE     : out   std_logic := '0';

      eth_tx_en         : out   std_logic := '0';
      eth_txd           : out   std_logic_vector(1 downto 0) := (others => '0');

      eth_rx_dv         : in    std_logic;
      eth_crs_dv        : in    std_logic;
      eth_rx_col        : in    std_logic;
      eth_rx_err        : in    std_logic;
      eth_rxd           : in    std_logic_vector(3 downto 0);

      -- note: fpgaGpio[0] *not* available on V2.0 board (only starting with 2.1)
      fpgaGpio_IN       : in    std_logic_vector(7 downto 1) := (others => '0');
      fpgaGpio_OUT      : out   std_logic_vector(7 downto 1) := (others => '0');
      fpgaGpio_OE       : out   std_logic_vector(7 downto 1) := (others => '0');

      fpga_b3_io_IN     : in    std_logic_vector(2 downto 0);
      fpga_b3_io_OUT    : out   std_logic_vector(2 downto 0) := (others => '0');
      fpga_b3_io_OE     : out   std_logic_vector(2 downto 0) := (others => '0')
   );
end entity design_top;

architecture rtl of design_top is

   attribute ASYNC_REG         : string;
   attribute SYN_PRESERVE      : boolean;

   constant BOARD_VERSION_C    : std_logic_vector(7 downto 0) := x"10";

   -- must cover bulk max pkt size
   constant LD_FIFO_OUT_C      : natural :=  9;
   constant LD_FIFO_INP_C      : natural :=  9;

   constant UART_MAX_BITS_C    : natural :=  8;

   constant MIC_SEL_C          : std_logic := '0';

   -- delay in external registers (clk + dat)
   constant MIC_DELAY_C        : natural := 2;

   constant NCM_IF_ASSOC_IDX_C : integer := usb2NextIfcAssocDescriptor(
      USB2_APP_DESCRIPTORS_C,
      0,
      USB2_IFC_CLASS_CDC_C,
      USB2_IFC_SUBCLASS_CDC_NCM_C,
      USB2_IFC_PROTOCOL_NONE_C
   );

   constant NCM_IFC_NUM_C      : natural := to_integer( unsigned( USB2_APP_DESCRIPTORS_C( NCM_IF_ASSOC_IDX_C + 2 ) ) );

   constant NCM_ENBL_MC_FLT_C  : boolean := usb2GetNumMCFilters( USB2_APP_DESCRIPTORS_C, NCM_IF_ASSOC_IDX_C, USB2_IFC_SUBCLASS_CDC_NCM_C ) > 0;

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
      ),
      3 => usb2CtlEpMkAgentConfig(
         recipient => USB2_REQ_TYP_RECIPIENT_DEV_C,
         index     => 2,
         reqType   => USB2_REQ_TYP_TYPE_VENDOR_C
      )
   );

   constant MICR_UAC2_IFC_ASSOC_IDX_C          : integer :=
      usb2NextUAC2IfcAssocDescriptor(
         USB2_APP_DESCRIPTORS_C,
         0,
         USB2_CS_IFC_HDR_UAC2_CATEGORY_MICROPHONE
      );

   constant AUD_SMPL_SIZE_C                    : integer :=
      usb2GetUAC2SubSlotSize(
         USB2_APP_DESCRIPTORS_C,
         MICR_UAC2_IFC_ASSOC_IDX_C
   );

   -- AUD_SMPL_FREQ_C should divide the ULPI clock (60MHz)
   constant ULPI_CLK_FREQ_C    : natural := 60000000;
   constant AUD_SMPL_FREQ_C    : natural := 48000;
   -- mic @ 2MHz
   constant MIC_PRESC_C        : natural := 25;
   constant MIC_PRESC_HI_C     : natural := (MIC_PRESC_C / 2);
   constant MIC_PRESC_LO_C     : natural := ((MIC_PRESC_C + 1) / 2);
   constant AUDIO_DECM_C       : natural := 50; -- ulpi_freq/mic_pres/audio_freq
   constant LD_AUD_FIFO_DEPTH_C: natural := 6;

   constant REQ_LED_CTL_C     : Usb2CtlRequestCodeType := x"01";
   constant REQ_GPIO_CTL_C    : Usb2CtlRequestCodeType := x"02";
   constant REQ_UMUX_CTL_C    : Usb2CtlRequestCodeType := x"03";
   constant REQ_VERS_CTL_C    : Usb2CtlRequestCodeType := x"04";

   constant REQ_LED_WR_IDX_C  : natural                := 0;
   constant REQ_LED_RD_IDX_C  : natural                := 1;
   constant REQ_GPIO_WR_IDX_C : natural                := 2;
   constant REQ_GPIO_RD_IDX_C : natural                := 3;
   constant REQ_UMUX_WR_IDX_C : natural                := 4;
   constant REQ_UMUX_RD_IDX_C : natural                := 5;
   constant REQ_VERS_RD_IDX_C : natural                := 6;

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
      ),
      REQ_UMUX_WR_IDX_C => usb2MkEpGenericReqDef(
         dev2Host  => '0',
         request   => REQ_UMUX_CTL_C,
         dataSize  => 1
      ),
      REQ_UMUX_RD_IDX_C => usb2MkEpGenericReqDef(
         dev2Host  => '1',
         request   => REQ_UMUX_CTL_C,
         dataSize  => 1
      ),
      REQ_VERS_RD_IDX_C => usb2MkEpGenericReqDef(
         dev2Host  => '1',
         request   => REQ_VERS_CTL_C,
         dataSize  => 6
      )
   );

   type UmuxRegType is record
      lastDTR      : std_logic;
      selInternal  : std_logic;
      holdMux      : std_logic;
   end record UmuxRegType;

   constant UMUX_REG_INIT_C : UmuxRegType := (
      lastDTR      => '0',
      selInternal  => '0',
      holdMux      => '0'
   );

   signal umuxR                : UmuxRegType := UMUX_REG_INIT_C;

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
   signal acmSelUart           : std_logic;
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

   signal acmFifoRst           : std_logic    := '0';

   signal uartRxDat            : std_logic_vector(UART_MAX_BITS_C - 1 downto 0) := (others => '0');
   signal uartRxDatVld         : std_logic := '0';
   signal uartTxDat            : std_logic_vector(UART_MAX_BITS_C - 1 downto 0) := (others => '0');
   signal uartTxDatVld         : std_logic := '0';
   signal uartTxDatRdy         : std_logic := '0';

   signal uartLineBreak        : std_logic := '0';

   signal usb2Rst              : std_logic := '0';
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

   signal ledDiagRegs          : Usb2ByteArray(0 to 1) := (others => (others => '0'));
   signal ledIn                : std_logic_vector(LED'range);
   signal gpioRegs             : Usb2ByteArray(0 to 1) := (others => (others => '0'));
   signal gpioIn               : std_logic_vector(7 downto 0);

   signal usb2DisconnectReq    : std_logic;
   signal usb2DisconnectAck    : std_logic;

   signal genRegReq            : GenRegOutType;
   signal genRegRep            : GenRegInpType;

   signal audioInpFifoDat      : std_logic_vector(47 downto 0):= (others => '0');
   signal audioInpFifoVld      : std_logic                    := '0';
   signal audioInpSelectorSel  : unsigned(7 downto 0)         := (others => '0');
   signal audioInpVolMaster    : signed(15 downto 0)          := (others => '0');
   signal micPcmDat            : signed(23 downto 0);
   signal micInputSel          : unsigned(2 downto 0);
   signal micInputRst          : std_logic := '0';

   signal mic_clk              : std_logic := '0';
   signal mic_clk_loc          : std_logic := '0';
   signal mic_dat              : std_logic := '0';
   signal mic_sel              : std_logic := MIC_SEL_C;
   signal mic_resync           : std_logic := '0';
   signal mic_synced           : std_logic;

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

   acmSelUart    <= not umuxR.selInternal;

   P_UART_MUX : process (
      acmSelUart,
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
      if ( acmSelUart = '0' ) then
         fifoRVld      <= acmFifoOutVld;
         uartTxDatVld  <= '0';
         acmFifoOutRen <= fifoRRdy;

         acmFifoInpDat <= fifoWDat;
         acmFifoInpWen <= fifoWVld;
         fifoWRdy      <= not acmFifoInpFull;
	 uartLineBreak <= '0';
      else
         fifoRVld      <= '0';
         uartTxDatVld  <= acmFifoOutVld;
         acmFifoOutRen <= uartTxDatRdy;

         acmFifoInpDat <= uartRxDat;
         acmFifoInpWen <= uartRxDatVld;
         fifoWRdy      <= '0';
	 uartLineBreak <= acmLineBreak;
      end if;
   end process P_UART_MUX;

-- default: loopback uart signals
   -- uartRx driven by mic
   --uartRxDat    <= uartTxDat;
   --uartRxDatVld <= uartTxDatVld;
   uartTxDatRdy <= '1';

   U_CMD : entity work.CommandWrapper
   generic map (
      GIT_VERSION_G                => GIT_VERSION_C,
      SPI_CLK_FREQ_G               => real(ULPI_CLK_FREQ_C)
   )
   port map (
      clk                          => ulpiClk,
      rst                          => acmFifoRst,

      boardVersion                 => BOARD_VERSION_C,

      datIb                        => fifoRDat,
      vldIb                        => fifoRVld,
      rdyIb                        => fifoRRdy,
      datOb                        => fifoWDat,
      vldOb                        => fifoWVld,
      rdyOb                        => fifoWRdy,

      genRegOb                     => genRegReq,
      genRegIb                     => genRegRep,

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
         LD_AUD_INP_FIFO_DEPTH_G   => LD_AUD_FIFO_DEPTH_C,
         CDC_ACM_ASYNC_G           => false,
         CDC_NCM_ASYNC_G           => true,
         AUD_INP_ASYNC_G           => false,
         AUD_INP_SAMPLE_FREQ_G     => AUD_SMPL_FREQ_C,
         AUD_INP_VOL_RNG_MIN_G     => -16*6*256,
         AUD_INP_VOL_RNG_MAX_G     => + 7*6*256,
         AUD_INP_VOL_RNG_RES_G     => + 1*6*256,
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
         usb2DisconnectReq         => usb2DisconnectReq,
         usb2DisconnectAck         => usb2DisconnectAck,

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
         ncmMCFilterDon            => ncmMCFilterDon,

         audioInpFifoClk           => ulpiClk,
         audioInpFifoDat           => audioInpFifoDat,
         audioInpFifoVld           => audioInpFifoVld,
         audioInpVolMaster         => audioInpVolMaster,
         audioInpSelectorSel       => audioInpSelectorSel
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
         ENABLE_G         => NCM_ENBL_MC_FLT_C
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

   B_DIV : block is
      type DivRegType is record
         quot         : signed  (7 downto 0);
         quotr        : signed  (7 downto 0);
         divisor      : unsigned(7 downto 0);
         dividend     : unsigned(7 downto 0);
         sign         : std_logic;
      end record DivRegType;

      constant DIV_REG_INIT_C : DivRegType := (
         quot         => (others => '0'),
         quotr        => (others => '0'),
         divisor      => to_unsigned(6, 8),
         dividend     => (others => '0'),
         sign         => '0'
      );

      signal r        : DivRegType := DIV_REG_INIT_C;
      signal rin      : DivRegType := DIV_REG_INIT_C;

   begin

      P_COMB : process (r, micPcmDat, audioInpVolMaster, audioInpSelectorSel ) is
         variable shft : integer;
         variable v    : DivRegType;
      begin
         v   := r;
         if ( r.dividend < r.divisor ) then
            if (r.sign = '1') then
               v.quotr    := -r.quot;
            else
               v.quotr    :=  r.quot;
            end if;
            v.quot     := (others => '0');
            v.sign     := audioInpVolMaster(audioInpVolMaster'left);
            if ( audioInpVolMaster < 0 ) then
               v.dividend := unsigned( - audioInpVolMaster(15 downto 8) );
            else
               v.dividend := unsigned(   audioInpVolMaster(15 downto 8) );
            end if;
         else
            v.dividend := r.dividend - r.divisor;
            v.quot     := r.quot + 1;
         end if;

         shft                             := to_integer( r.quotr );
         audioInpFifoDat                  <= (others => '0');
         audioInpFifoDat(micPcmDat'range) <= std_logic_vector( shift_right(micPcmDat, micPcmDat'length - 8*AUD_SMPL_SIZE_C - shft) );
         -- audioInpSelectorSel is 1-based, micInputSel 0-based
         micInputSel                      <= audioInpSelectorSel(2 downto 0) - 1;

         rin <= v;
      end process P_COMB;

      P_SEQ : process ( ulpiClk ) is
      begin
         if ( rising_edge( ulpiClk ) ) then
            r <= rin;
         end if;
      end process P_SEQ;

   end block B_DIV;

   U_MIC : entity work.MicWrapper
      generic map (
         CEN_DLY_G                    => MIC_DELAY_C,
         -- 2 MHz mic clock: ulpiClk / (2 * HALF_PERIOD)
         --
         PRESC_HI_PERIOD_G            => MIC_PRESC_HI_C,
         PRESC_LO_PERIOD_G            => MIC_PRESC_LO_C,
         AUDIO_DECM_G                 => AUDIO_DECM_C,
	 MIC_SEL_G                    => MIC_SEL_C,
	 MIC_DAT_CC_STAGES_G          => 2
      )
      port map (
         clk                          => ulpiClk,
         rst                          => usb2Rst,
	 micInputRst                  => micInputRst,
         micDat                       => mic_dat,
         micClk                       => mic_clk,
         micCen                       => open,
	 micSync                      => mic_resync,
	 micSynced                    => mic_synced,

         micFifoDat                   => open,
         micFifoWen                   => open,

         audSel                       => micInputSel,
         audCen                       => audioInpFifoVld,
         audDat                       => micPcmDat
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
            ledDiagRegs       <= ep0DevAgentParmsOb(ledDiagRegs'range);
         end if;
         if ( ep0DevAgentParmsVld(REQ_GPIO_WR_IDX_C) = '1' ) then
            gpioRegs          <= ep0DevAgentParmsOb(ledDiagRegs'range);
         end if;
         if ( ep0DevAgentParmsVld(REQ_UMUX_WR_IDX_C) = '1' ) then
            umuxR.selInternal <= ep0DevAgentParmsOb(0)(0);
            umuxR.holdMux     <= ep0DevAgentParmsOb(0)(1);
         end if;
         umuxR.lastDTR <= acmDTR;
         -- when DTR drops reset mux
         if ( (not acmDTR and umuxR.lastDTR and not umuxR.holdMux) = '1' ) then
            umuxR.selInternal <= '0';
         end if;
         if ( (usb2Rst or usb2DevStatus.usb2Rst) = '1' ) then
            umuxR <= UMUX_REG_INIT_C;
         end if;
      end if;
   end process P_EP0_DEV_REG_OB;

   P_EP0_DEV_REG_IB : process (
      ep0DevAgentParmsVld,
      ledDiagRegs,
      gpioIn,
      gpioRegs,
      umuxR
   ) is
   begin
      ep0DevAgentParmsIb  <= (others => (others => '0'));
      ep0DevAgentParmsAck <= '1';
      ep0DevAgentParmsErr <= '0';
      if ( ep0DevAgentParmsVld(REQ_GPIO_RD_IDX_C) = '1' ) then
         ep0DevAgentParmsIb(0)                 <= gpioIn;
         ep0DevAgentParmsIb(1)                 <= gpioRegs(1);
      end if;
      if ( ep0DevAgentParmsVld(REQ_LED_RD_IDX_C) = '1' ) then
         ep0DevAgentParmsIb(ledDiagRegs'range) <= ledDiagRegs;
      end if;
      if ( ep0DevAgentParmsVld(REQ_UMUX_RD_IDX_C) = '1' ) then
         ep0DevAgentParmsIb(0)(0)              <= umuxR.selInternal;
         ep0DevAgentParmsIb(0)(1)              <= umuxR.holdMux;
      end if;
      if ( ep0DevAgentParmsVld(REQ_VERS_RD_IDX_C) = '1' ) then
         ep0DevAgentParmsIb(5)                 <= BOARD_VERSION_C;
         ep0DevAgentParmsIb(4)                 <= mkApiVersion( CMD_API_FUNCTION_GENERIC_C );
         for i in 3 downto 0 loop
            ep0DevAgentParmsIb(i)              <= GIT_VERSION_C(8*i + 7 downto 8*i);
         end loop;
      end if;
   end process P_EP0_DEV_REG_IB;

   gpioIn      (7 downto 1)  <= fpgaGpio_IN (7 downto 1);

   fpgaGpio_OUT(7 downto 7)  <= gpioRegs(0) (7 downto 7);
   fpgaGpio_OE (7 downto 7)  <= gpioRegs(1) (7 downto 7);
   fpgaGpio_OE (         3)  <= '0'; -- mic in

--   mic_dat                   <= fpgaGpio_IN(3);
--   fpgaGpio_OE (         1)  <= '1';
--   fpgaGpio_OUT(         1)  <= mic_sel;
--   fpgaGpio_OE (         2)  <= '1'; -- mic in
   fpgaGpio_OUT(         2)  <= mic_clk;

   P_MIC_CLK : process (ulpiClk) is
      variable cnt : integer := 0;
   begin
      if ( rising_edge( ulpiClk ) ) then
         if ( cnt < 0 ) then
            if ( mic_clk_loc = '0' ) then
               cnt := MIC_PRESC_HI_C - 2;
            else
               cnt := MIC_PRESC_LO_C - 2;
            end if;
            mic_clk_loc <= not mic_clk_loc;
         else
            cnt := cnt - 1;
         end if;
      end if;
   end process P_MIC_CLK;

   mic_dat                   <= fpga_b3_io_IN(0);
   fpga_b3_io_OE (       1)  <= '1';
   fpga_b3_io_OUT(       1)  <= mic_sel;
   fpga_b3_io_OE (       2)  <= '1'; -- mic in
   fpga_b3_io_OUT(       2)  <= mic_clk_loc;


   gpioIn      (         0)  <= eth_gpio_9_IN;
   eth_gpio_9_OUT            <= gpioRegs(0) (         0);
   eth_gpio_9_OE             <= gpioRegs(1) (         0);

   ledIn(7)                  <= ethMacPromisc;
   ledIn(6)                  <= ethMacAllMulti;
   ledIn(5)                  <= usb2DevStatus.suspended;
   ledIn(4)                  <= ethMacDuplexFull;
   ledIn(3)                  <= ethMacSpeed10;
   ledIn(2)                  <= ethPhyLinkOk;
   ledIn(1)                  <= not rmiiPllLocked; -- and rmiiClkBlink;
   ledIn(0)                  <= '0'; --gpsPps;

   -- LEDs are active low
   LED                       <= not ((ledIn and not ledDiagRegs(1)) or (ledDiagRegs(1) and ledDiagRegs(0))) ;

   micInputRst               <= gpioRegs(0)(5);
   mic_resync                <= gpioRegs(0)(4);

   -- reconfiguration interface
   genRegRep.reconfigurable  <= '1';
   cfg_ENA                   <= genRegRep.reconfigurable;
   -- initiate device disconnect from usb when reconfiguration is
   -- requested as soon as DTR drops.
   usb2DisconnectReq         <= (genRegReq.reconfigure and not acmDTR);
   -- once disconnection is complete proceed to reconfigure
   cfg_CONFIG                <= usb2DisconnectAck;

end architecture rtl;
