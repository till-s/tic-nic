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

      eth_tx_en         : out   std_logic := '0';
      eth_txd           : out   std_logic_vector(3 downto 0) := (others => '0');

      eth_rx_dv         : in    std_logic;
      eth_crs_dv        : in    std_logic;
      eth_rx_col        : in    std_logic;
      eth_rx_err        : in    std_logic;
      eth_rxd           : in    std_logic_vector(3 downto 0);

      -- FPGA_GPIO[0] is not usable; not wired to a GPIO-capable pin on V1 hardware
      fpga_gpio_IN      : in    std_logic_vector(7 downto 1);
      fpga_gpio_OUT     : out   std_logic_vector(7 downto 1) := (others => '0');
      fpga_gpio_OE      : out   std_logic_vector(7 downto 1) := (others => '0');

      fpga_b3_io_IN     : in    std_logic_vector(2 downto 0);
      fpga_b3_io_OUT    : out   std_logic_vector(2 downto 0) := (others => '0');
      fpga_b3_io_OE     : out   std_logic_vector(2 downto 0) := (others => '0')
   );
end entity design_top;

architecture rtl of design_top is
   attribute ASYNC_REG         : string;
   attribute SYN_PRESERVE      : boolean;

   -- must cover bulk max pkt size
   constant LD_FIFO_OUT_C      : natural :=  9;
   constant LD_FIFO_INP_C      : natural :=  9;

   constant UART_MAX_BITS_C    : natural := 8;

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

   constant AUD_SMPL_FREQ_C : natural := 48000;

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
   signal acmRate              : unsigned(31 downto 0);
   signal acmParity            : unsigned( 2 downto 0);

   signal uartRst              : std_logic := '0';

   signal uartRxDat            : std_logic_vector(UART_MAX_BITS_C - 1 downto 0) := (others => '0');
   signal uartRxDatVld         : std_logic := '0';
   signal uartTxDat            : std_logic_vector(UART_MAX_BITS_C - 1 downto 0) := (others => '0');
   signal uartTxDatVld         : std_logic := '0';
   signal uartTxDatRdy         : std_logic := '0';

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

   signal usb2Ep0ReqParam      : Usb2CtlReqParamArray( EP0_AGENT_CFG_C'range );
   signal usb2Ep0ObExt         : Usb2EndpPairObType;
   signal usb2Ep0IbExt         : Usb2EndpPairIbArray( EP0_AGENT_CFG_C'range ) := (others => USB2_ENDP_PAIR_IB_INIT_C );
   signal usb2Ep0CtlExt        : Usb2CtlExtArray( EP0_AGENT_CFG_C'range ):= (others => USB2_CTL_EXT_NAK_C);
   signal mdioClk              : std_logic;
   signal mdioDatOut           : std_logic;
   signal mdioDatInp           : std_logic;
   signal mdioDatHiZ           : std_logic;

   signal audioInpFifoDat      : std_logic_vector(47 downto 0) := (others => '0');
   signal audioInpFifoVld      : std_logic                     := '0';
   signal audioInpFifoRdy      : std_logic;
   signal audioInpSelectorSel  : unsigned(7 downto 0)          := (others => '0');
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
      acmFifoRst
   ) is
   begin
      if ( acmDTR = '0' ) then
         fifoRVld      <= acmFifoOutVld;
         uartTxDatVld  <= '0';
         acmFifoOutRen <= fifoRRdy;

         acmFifoInpDat <= fifoWDat;
         acmFifoInpWen <= fifoWVld;
         fifoWRdy      <= not acmFifoInpFull;

         uartRst       <= '1';
      else
         fifoRVld      <= '0';
         uartTxDatVld  <= acmFifoOutVld;
         acmFifoOutRen <= uartTxDatRdy;

         acmFifoInpDat <= uartRxDat;
         acmFifoInpWen <= uartRxDatVld;
         fifoWRdy      <= '0';

         uartRst       <= acmFifoRst;
      end if;
   end process P_UART_MUX;

-- default: loopback uart signals
   uartRxDat    <= uartTxDat;
   uartRxDatVld <= uartTxDatVld;
   uartTxDatRdy <= '1';

   U_CMD : entity work.CommandWrapper
   generic map (
      GIT_VERSION_G                => GIT_VERSION_C,
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

      spiSClk                      => spiSClk, --: out std_logic;
      spiMOSI                      => spiMOSI, --: out std_logic;
      spiCSb                       => spiCSb_OUT,  --: out std_logic;
      spiMISO                      => spiMISO  --: in  std_logic := '0';
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
         LD_AUD_INP_FIFO_DEPTH_G   => 9,
         CDC_ACM_ASYNC_G           => false,
         CDC_NCM_ASYNC_G           => true,
         AUD_INP_ASYNC_G           => false,
         AUD_INP_SAMPLE_FREQ_G     => AUD_SMPL_FREQ_C,
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
         acmRate                   => acmRate,
         acmParity                 => acmParity,

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
         audioInpFifoRdy           => audioInpFifoRdy,
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


         usb2CtlReqParam              => usb2Ep0ReqParam(0),
         usb2CtlExt                   => usb2Ep0CtlExt(0),
         usb2EpIb                     => usb2Ep0ObExt,
         usb2EpOb                     => usb2Ep0IbExt(0),

         mdioClk                      => mdioClk,
         mdioDatOut                   => mdioDatOut,
         mdioDatHiZ                   => mdioDatHiZ,
         mdioDatInp                   => mdioDatInp,

         speed10                      => ethMacSpeed10,
         duplexFull                   => ethMacDuplexFull,
         linkOk                       => ethMacLinkOk,
         -- full contents; above bits are for convenience
         statusRegPolled              => open
      );

   P_AUDIO : process ( ulpiClk ) is
      variable presc : natural range 0 to 1249 := 1249;
      variable smpl  : signed(23 downto 0)     := (others => '0');
      constant SCL_C : signed(23 downto 0)     := to_signed(2**23 - 17000, 24);

      type U24Array is array (integer range <>) of signed(23 downto 0);

      constant SIN_TBL_C : U24Array := (
         0 => to_signed(  548641, 24),
         1 => to_signed( 1636536, 24),
         2 => to_signed( 2696430, 24),
         3 => to_signed( 3710186, 24),
         4 => to_signed( 4660461, 24),
         5 => to_signed( 5530994, 24),
         6 => to_signed( 6306889, 24),
         7 => to_signed( 6974873, 24),
         8 => to_signed( 7523514, 24),
         9 => to_signed( 7943426, 24),
        10 => to_signed( 8227423, 24),
        11 => to_signed( 8370647, 24)
      );

      variable idx   : natural range SIN_TBL_C'range := 0;
      variable quad  : natural range 0 to 3          := 0;
      variable rep   : natural range 0 to 3          := 0;
      variable cnt   : integer range -1 to 2         := -1;
   begin
      if ( rising_edge( ulpiClk ) ) then
         if ( presc = 0 ) then
            presc := 1249;
            if ( quad < 2 ) then
               smpl :=  SIN_TBL_C(idx);
            else
               smpl := -SIN_TBL_C(idx);
            end if;
            if ( cnt >= 0 ) then
               cnt := cnt - 1;
            else
               case quad is
                  when 0 | 2 =>
                     if ( SIN_TBL_C'high = idx ) then
                        if ( quad = 0 ) then
                           quad := 1;
                        else
                           quad := 3;
                        end if;
                     else
                        idx  := idx + 1;
                     end if;
                  when 1 | 3 =>
                     if ( SIN_TBL_C'low  = idx ) then
                        if ( quad = 1 ) then
                           quad := 2;
                        else
                           quad := 0;
                        end if;
                     else
                        idx  := idx - 1;
                     end if;
               end case;
               cnt := rep - 1;
            end if;
            audioInpFifoVld <= '1';
         else
            presc := presc - 1;
         end if;
         if ( (audioInpFifoVld and audioInpFifoRdy) = '1' ) then
            audioInpFifoVld <= '0';
         end if;
         rep := to_integer( audioInpSelectorSel(1 downto 0) );
      end if;
      audioInpFifoDat             <= (others => '0');
      audioInpFifoDat(smpl'range) <= std_logic_vector( shift_right(smpl, smpl'length - 8*AUD_SMPL_SIZE_C) );
   end process P_AUDIO;

   -- LEDs are active low
   LED(7)        <= not ethMacPromisc;
   LED(6)        <= not ethMacAllMulti;
   LED(5)        <= not usb2DevStatus.suspended;
   LED(4)        <= not ethMacDuplexFull;
   LED(3)        <= not ethMacSpeed10;
   LED(2)        <= not ethMacLinkOk;
   LED(1)        <=     rmiiPllLocked; -- and rmiiClkBlink;
   LED(0)        <= '1'; -- ulpiClkBlink;

end architecture rtl;
