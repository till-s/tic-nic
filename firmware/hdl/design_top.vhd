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
      sdram_clk         : in  std_logic := '0';
      sdram_smpl_clk    : in  std_logic := '0';
      -- create 180-deg out of phase clock with DDIO
      sdram_clkout_HI   : out std_logic := '1';
      sdram_clkout_LO   : out std_logic := '0';

      sdram_CSb         : out std_logic := '1';
      sdram_CKE         : out std_logic := '0';
      sdram_DQML        : out std_logic := '0';
      sdram_DQMH        : out std_logic := '0';
      sdram_WEb         : out std_logic := '1';
      sdram_CASb        : out std_logic := '1';
      sdram_RASb        : out std_logic := '1';
      sdram_A           : out std_logic_vector(12 downto 0) := (others => '0');
      sdram_BA          : out std_logic_vector( 1 downto 0) := (others => '0');
      sdram_DQ_IN       : in  std_logic_vector(15 downto 0) := (others => '0');
      sdram_DQ_OUT      : out std_logic_vector(15 downto 0) := (others => '0');
      sdram_DQ_OE       : out std_logic_vector(15 downto 0) := (others => '0');

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
      sdramPllLocked    : in    std_logic := '0';

      adcClk            : in    std_logic := '0';

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
      eth_rxd           : in    std_logic_vector(3 downto 0)
   );
end entity design_top;

architecture rtl of design_top is
   attribute ASYNC_REG         : string;
   attribute SYN_PRESERVE      : boolean;

   -- must cover bulk max pkt size
   constant LD_FIFO_OUT_C      : natural :=  9;
   constant LD_FIFO_INP_C      : natural :=  9;

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
      )
   );

   signal acmFifoOutDat        : Usb2ByteType;
   signal acmFifoOutEmpty      : std_logic;
   signal acmFifoOutRen        : std_logic    := '1';
   signal acmFifoInpDat        : Usb2ByteType := (others => '0');
   signal acmFifoInpFull       : std_logic;
   signal acmFifoInpWen        : std_logic    := '0';

   signal acmFifoInpMinFill    : unsigned(LD_FIFO_INP_C - 1 downto 0) := (others=> '0');
   signal acmFifoInpTimer      : unsigned(32 - 1 downto 0) := (others=> '0');

   signal acmFifoLocal         : std_logic    := '1';

   signal acmDTR               : std_logic;
   signal acmRate              : unsigned(31 downto 0);
   signal acmParity            : unsigned( 2 downto 0);
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

   fifoRDat      <= acmFifoOutDat;
   fifoRVld      <= not acmFifoOutEmpty;
   acmFifoOutRen <= fifoRRdy;

   acmFifoInpDat <= fifoWDat;
   acmFifoInpWen <= fifoWVld;
   fifoWRdy      <= not acmFifoInpFull;

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
      LED(1) <= cnt(cnt'left);
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
      -- can blink an LED here with 'tgl'
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
         duplexFull                   => open, -- out std_logic := '0';
         linkOk                       => ethMacLinkOk,
         -- full contents; above bits are for convenience
         statusRegPolled              => open
      );

   -- LEDs are active low
   LED(7)        <= not ethMacPromisc;
   LED(6)        <= not ethMacAllMulti;
   LED(5)        <= not usb2DevStatus.suspended;
   LED(4)        <= '1';
   LED(3)        <= not ethMacSpeed10;
   LED(2)        <= not ethMacLinkOk;

   LED(0)        <= not sdramPllLocked;

end architecture rtl;
