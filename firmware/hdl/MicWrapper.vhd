library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.MicPkg.all;

entity MicWrapper is
   generic (
      -- The wrapper can be used in different modes!
      -- In 'normal' mode this module drives the microphone
      -- clock (micClk output). Since there could be
      -- external delays (registering) of the data line
      -- with respect to the clock there is a generic to
      -- account for external clk->data delays in the mic-
      -- data path.
      CEN_DLY_G           : natural              := 0;
      AUDIO_DECM_WIDTH_G  : natural              := 8;
      -- If you need a single stage only set MIN=MAX.
      MIN_CIC_STAGES_G    : natural range 1 to 4 := 1;
      MAX_CIC_STAGES_G    : natural range 1 to 4 := 4;
      -- The 'L/R' level this microphone uses; must
      -- match hardware setting.
      MIC_SEL_G           : std_logic            := '0';
      -- In 'sync' mode we assume that the microphone
      -- is clocked by an external source to which we
      -- have no direct access. We observe the data
      -- line and synchronize our internal clock to
      -- an active micClk transition (depending on
      -- MIC_SEL_G). This generic activates an internal
      -- CC synchronizer for this use case; you can
      -- also do this externally and leave the generic
      -- at 0.
      MIC_DAT_CC_STAGES_G : natural              := 0;
      -- width of the prescaler (clk -> mic_clk)
      MIC_PRESC_WIDTH_G   : positive             := 8;
      -- number of significant bits in the scale
      -- factors (this must match the hardware multiplier
      -- width of the architecture this will be synthesized
      -- for!)
      SCALE_WIDTH_G       : positive             := 18
   );
   port (
      clk                 : in  std_logic;
      rst                 : in  std_logic;
      -- reset the mic input block; (tie to 'rst';
      -- this is mostly for testing the synchronization
      -- feature; resetting the input block lets you
      -- 'desynchronize').
      micInputRst         : in  std_logic;
      micDat              : in  std_logic;
      -- aux output after CC synchronizer
      micDatSync          : out std_logic;
      -- generated mic clock
      micClk              : out std_logic;
      -- request synchronization of the mic_clk generator
      -- to an 0->1 mic_dat transition. Useful if
      -- the mic is clocked by another source (must still be
      -- phase synchronous to 'clk').
      -- NOTE: does not work in stereo configurations as
      --       it is not possible to recover the R/L info.
      micSync             : in  std_logic := '0';
      -- Goes low when a 'micSync' request is detected and
      -- back high once the prescaler is synced.
      micSynced           : out std_logic;
      -- clock-enable for anything that listens to
      -- mic_data
      micCen              : out std_logic;
      -- raw mic_data bits are available here; lsbit is the
      -- oldest bit.
      micFifoDat          : out std_logic_vector(7 downto 0);
      -- asserted when a new bytes of raw data is available.
      micFifoWen          : out std_logic;
      -- prescaler for generating the microphone clock; the rate is
      -- the input ('clk') frequency divided by (prescLoPeriod + 1 + prescHiPeriod + 1),
      -- i.e., the values provided is the actual value - 1.
      -- The clock stays low for (prescLoPeriod + 1) cycles and high for
      -- (prescHiPeriod + 1) cycles;
      -- unless both values are set no clock is generated
      micPrescPeriodLo    : in  unsigned(MIC_PRESC_WIDTH_G - 1 downto 0);
      micPrescPeriodHi    : in  unsigned(MIC_PRESC_WIDTH_G - 1 downto 0);
      -- mux: 0-based index 0 -> test sinewave,
      --                 1..n -> MIN_CIC_STAGES..MAX_CIC_STAGES
      audSel              : in  unsigned(2 downto 0) := (others => '0');
      -- valid audio data (1-clk cycle)
      audCen              : out std_logic;
      audDat              : out S24Type;
      -- decimation (PDM -> PCM; zero based, i.e., actual decimation is audDecm + 1)
      audDecm             : in  unsigned(AUDIO_DECM_WIDTH_G - 1 downto 0);
      -- the SCALE_WIDTH_G most-significant bits will be used
      audScales           : in  ScaleArray(MIN_CIC_STAGES_G to MAX_CIC_STAGES_G);
      -- the shift, OTOH, is right-adjusted; i.e., the least significant bits are
      -- used
      audShifts           : in  ShiftArray(MIN_CIC_STAGES_G to MAX_CIC_STAGES_G);
      -- synthetic PDM of sinewave; can be fed back into micDat for testing
      -- the sinewave frequency is 1/48 the audio sampling frequency.
      sinPdm              : out std_logic
   );
end entity MicWrapper;

architecture rtl of MicWrapper is

   function bits(constant x : in positive) return natural is
      variable rv  : natural;
      variable cmp : natural;
   begin
      cmp := 1;
      rv  := 0;
      while ( cmp <= x ) loop
        cmp := 2*cmp;
        rv  := rv + 1;
      end loop;
      return rv;
   end function bits;

   constant LD_DECM_C        : natural := AUDIO_DECM_WIDTH_G;

   signal micClkLoc          : std_logic;
   signal micCenLoc          : std_logic;
   signal cicCen             : std_logic_vector(MIN_CIC_STAGES_G to MAX_CIC_STAGES_G);
   signal sinCen             : std_logic;
   signal audPresc           : signed(AUDIO_DECM_WIDTH_G downto 0) := (others => '0');
   signal audSin             : S24Type;
   signal audCic             : S24Array(MIN_CIC_STAGES_G to MAX_CIC_STAGES_G);
   signal cicDataIn          : signed(1 downto 0);
   signal pdmCen             : std_logic := '0';

begin

   P_PRESC : process ( clk ) is
   begin
      if ( rising_edge( clk ) ) then
         if ( rst = '1' ) then
            audPresc <= ( others => '0' );
	    sinCen   <= '0';
	 else
            if ( micCenLoc = '1' ) then
               if ( audPresc < 0 ) then
                  audPresc  <= signed( resize( audDecm, audPresc'length ) ) - 1;
                  sinCen    <= '1';
               else
                  audPresc <= audPresc - 1;
               end if;
            end if;
            if ( sinCen = '1' ) then
               sinCen <= '0';
            end if;
         end if;
      end if;
   end process P_PRESC;

   U_MIC : entity work.MicInput
      generic map (
         CEN_DLY_G           => CEN_DLY_G,
         PRESC_WIDTH_G       => MIC_PRESC_WIDTH_G,
	 MIC_SEL_G           => MIC_SEL_G,
	 MIC_DAT_CC_STAGES_G => MIC_DAT_CC_STAGES_G
      )
      port map (
         clk                 => clk,
         rst                 => micInputRst,
         micDat              => micDat,
         micClk              => micClkLoc,
         micDatSync          => micDatSync,
         micCen              => micCenLoc,
	 prescPeriodLo       => micPrescPeriodLo,
	 prescPeriodHi       => micPrescPeriodHi,
         fifoDat             => micFifoDat,
         fifoWen             => micFifoWen,
	 resync              => micSync,
	 synced              => micSynced
      );

   U_SIN : entity work.SinGen12
      port map (
         clk                 => clk,
         rst                 => rst,
         cen                 => sinCen,
         sin                 => audSin
      );

   B_PDM_CEN : block is
      signal lstMicClk : std_logic := MIC_SEL_G;
   begin

      P_PDM_CEN : process ( clk, micClkLoc ) is
      begin
         if ( rising_edge( clk ) ) then
            if ( rst = '1' ) then
               lstMicClk <= MIC_SEL_G;
	    else
               lstMicClk <= micClkLoc;
	    end if;
         end if;
      end process P_PDM_CEN;

      pdmCen <= ( micClkLoc xnor MIC_SEL_G ) and ( lstMicClk xor MIC_SEL_G );

   end block B_PDM_CEN;

   U_PDM : entity work.PDModulator
      port map (
         clk                 => clk,
         rst                 => rst,
         cen                 => pdmCen,
         sig                 => audSin,
         pdm                 => sinPdm
      );

   -- map micDat 0/1 to cicDataIn -1/+1; match
   -- existing CIC implementation from other project
   cicDataIn(0) <= '1';
   cicDataIn(1) <= not micDat;

   G_DECM : for STAGES in MIN_CIC_STAGES_G to MAX_CIC_STAGES_G generate
      constant D_W_C              : natural := cicDataIn'length + LD_DECM_C * STAGES;
      signal   cicDataOu          : signed(D_W_C - 1 downto 0);
      -- the filter is too wide; since it was designed to accommodate
      -- arbitrary decimation factors up to 2**LD_MAX_DCM_G - 1. Also,
      -- the input data width is wider than necessary since we want
      -- bipolar input data. => sign bit + max growth
      --
      --    constant GROWTH_C           : natural := max(audioDecm)**STAGES;
      --    constant LD_GROWTH_C        : natural := integer(ceil(log2(real(GROWTH_C))));
      constant LD_GROWTH_C        : natural := STAGES * LD_DECM_C;

      constant SIGNIFICANT_BITS_C : natural := 1 +  LD_GROWTH_C;
      -- FACT_W_C: multiplier width (given by hardware)
      constant FACT_W_C           : natural := SCALE_WIDTH_G;

      signal   cicData            : S24Type;
      signal   cicDataDly         : S24Type;
      signal   prod               : signed(2*FACT_W_C - 1 downto 0) := (others => '0');
      -- pipeline stages of MADDer (1 for shift, 1 for product, 1 for accumulator)
      signal   cicCenDlyIn        : std_logic;
      signal   cicCenDly          : std_logic_vector(2 downto 0)    := (others => '0');

      function mapPart(signal s : in signed; constant tgtLen : in natural; constant lshft : in natural)
         return signed is
         variable v : signed(tgtLen - 1 downto 0);
      begin
         v := (others => '0');
         if ( v'length >= s'length ) then
            v(v'left downto v'length - s'length) := shift_left(s, lshft);
         else
            v := shift_left(s, lshft)(s'left downto s'length - v'length);
         end if;
         return v;
      end function mapPart;

   begin
      U_CIC : entity work.CicFilter
         generic map (
            DATA_WIDTH_G     => cicDataIn'length,
            LD_MAX_DCM_G     => LD_DECM_C,
            NUM_STAGES_G     => STAGES
         )
         port map (
            clk              => clk,
            rst              => rst,
            cen              => micCenLoc,
            decmInp          => audDecm,
            dataInp          => cicDataIn,
            dataOut          => cicDataOu,
            strbOut          => cicCenDlyIn
         );

      -- scale the CIC output data so it fits into W = S24'length; this maps the +/-1 PDM signal to
      -- +/- 2**(W - 1) by multiplying the CIC output data by S = 2**(W-1)/CIC_growth; we want to employ
      -- a hardware multiplier with the bit width FACT_W_C for this task.
      -- S can be restated as 2**SHIFT * SCALE where SCALE is in the range 1 <= SCALE < 2
      --
      --    using ldGrowth = log2(CIC_growth)) = CIC_STAGES * log2( CIC_DECIMATION )
      --
      --    S = 2**( W - 1 - ldGrowth) = 2**(W-1-ceil(ldGrowth) - ldGrowth + ceil(ldGrowth)
      --      = 2**( W - 1 - ceil(ldGrowth)) 2**(ceil(ldGrowth) - ldGrowth)
      --
      --    SHIFT = W - 1 - ceil( ldGrowth )
      --    SCALE = 2**(ceil(ldGrowth) - ldGrowth)
      --
      -- The SCALE can be expressed as SCALE = 1 + DELTA with 0 <= DELTA < 1
      --
      -- If we renormalize DELTA * ONE  (with ONE = 2**(FACT_W_C - 1), since the multiplier is a signed
      -- multiplier) and use the FACT_W_C most significant bits of an input X (with wordlength W)
      --
      --   PROD = (X >> (W - FACT_W_C)) * (DELTA * ONE)
      --
      -- the result has to be re-scaled
      --
      --   (PROD << (W - FACT_W_C)) >> (FACT_W_C - 1)       (the RHS undes the scaling with ONE)
      --  = PROD >> (2*FACT_W_C - W - 1)
      --
      -- In summary:
      --   X = CIC_OUT << SHIFT  (right-shift if SHIFT < 0)
      --   P = (X >> (W - FACT_W_C)) * (DELTA * ONE)
      --   X = X + ( P >> (2*FACT_W_C - W -1) )
      --
      -- Assume 'SHIFT' and 'DELTA' are prepared by the user and provided in a register
      P_SCALE : process ( clk ) is
         variable scale    : signed(FACT_W_C - 1 downto 0);
	 variable shift    : integer := 0;
      begin
         if ( rising_edge(clk) ) then
            -- prod = (scale - 1)*ONE_M_C * data  (ONE_M_C, max positive number representable in multiplier)
            if ( shift >= 0 ) then
               cicData     <= resize( shift_left( cicDataOu,   shift ), cicData'length );
            else
               cicData     <= resize( shift_right( cicDataOu, -shift ), cicData'length );
            end if;
            prod           <= scale * cicData(cicData'left downto cicData'length - FACT_W_C);
            -- delay the data while the product is computed
            cicDataDly     <= cicData;
            -- add data + product; (1 + (scale - 1))*data = data + (scale-1)*data
            audCic(STAGES) <= cicDataDly + mapPart(prod, audCic(STAGES)'length, 1);
            -- delay the strobe by the number of pipeline stages (2)
            cicCenDly      <= cicCenDlyIn & cicCenDly(cicCenDly'left downto 1);
            scale          := audScales(STAGES)(ScaleType'left downto ScaleType'left - ( scale'length - 1 ));
	    -- with min. decimation ~ 50 at 1 stage the shift is 23 - 6 = 17
	    -- with max. decimation ~ 300 at 4 stages the shift is -10
	    shift          := to_integer( audShifts(STAGES)( 5 downto 0 ) );
         end if;
      end process P_SCALE;

      process (clk) is
        variable s : string(1 to cicDataOu'length);
      begin
	      if ( rising_edge( clk )  and (cicCenDlyIn = '1') ) then
--        for i in s'left to s'right loop
--	  if ( cicDataOu(cicDataOu'left + 1 - i) = '1' ) then
--             s(i) := '1';
--	  else
--             s(i) := '0';
--	  end if;
--	end loop;
--        report "0b" & s;
                report integer'image(to_integer(cicDataIn));
end if;
      end process;

      cicCen(STAGES) <= cicCenDly(0);

   end generate G_DECM;

   P_AUD_MUX : process( clk ) is
      variable sel : natural;
   begin
      if ( rising_edge( clk ) ) then
         sel := to_integer(audSel);
         audCen <= sinCen;
         audDat <= audSin;
         if ( sel >= 1 and sel <= 1 + MAX_CIC_STAGES_G - MIN_CIC_STAGES_G ) then
           audCen <= cicCen(MIN_CIC_STAGES_G + sel - 1);
           audDat <= audCic(MIN_CIC_STAGES_G + sel - 1);
         end if;
      end if;
   end process P_AUD_MUX;

   micCen       <= micCenLoc;
   micClk       <= micClkLoc;
      
end architecture rtl;
