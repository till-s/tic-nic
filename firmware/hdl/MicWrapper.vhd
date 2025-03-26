library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity MicWrapper is
   generic (
      PRESC_HI_PERIOD_G   : natural := 15;
      PRESC_LO_PERIOD_G   : natural := 15;
      -- audio period in multiples of the prescaler
      -- period.
      AUDIO_DECM_G        : natural;
      MIN_CIC_STAGES_G    : natural range 1 to 4 := 1;
      MAX_CIC_STAGES_G    : natural range 1 to 4 := 4
   );
   port (
      clk                 : in  std_logic;
      rst                 : in  std_logic;
      micDat              : in  std_logic;
      micClk              : out std_logic;
      micSel              : in  std_logic := '0';
      micCen              : out std_logic;
      micFifoDat          : out std_logic_vector(7 downto 0);
      micFifoWen          : out std_logic;
      -- mux: 0-based index 0 -> test sinewave,
      --                 1..n -> MIN_CIC_STAGES..MAX_CIC_STAGES
      audSel              : in  unsigned(2 downto 0) := (others => '0');
      audCen              : out std_logic;
      audDat              : out signed(23 downto 0)
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

   subtype S24Type           is signed(23 downto 0);
   type    S24Array          is array (integer range <>) of S24Type;

   constant LD_DECM_C        : natural := bits(AUDIO_DECM_G);

   -- CicFilter takes the decimation factor minus one on its
   -- 'decmInp' port.
   constant DECM_Z_BASED_C   : unsigned(LD_DECM_C - 1 downto 0) := to_unsigned(AUDIO_DECM_G - 1, LD_DECM_C);

   signal micCenLoc          : std_logic;
   signal cicCen             : std_logic_vector(MIN_CIC_STAGES_G to MAX_CIC_STAGES_G);
   signal sinCen             : std_logic;
   signal audPresc           : integer range -1 to AUDIO_DECM_G - 2 := AUDIO_DECM_G - 2;
   signal audSin             : S24Type;
   signal audCic             : S24Array(MIN_CIC_STAGES_G to MAX_CIC_STAGES_G);
   signal cicDataIn          : signed(1 downto 0);

begin

   P_PRESC : process ( clk ) is
   begin
      if ( rising_edge( clk ) ) then
         if ( micCenLoc = '1' ) then
            if ( audPresc < 0 ) then
               audPresc  <= AUDIO_DECM_G - 2;
               sinCen    <= '1';
            else
               audPresc <= audPresc - 1;
            end if;
         end if;
         if ( sinCen = '1' ) then
            sinCen <= '0';
         end if;
      end if;
   end process P_PRESC;

   U_MIC : entity work.MicInput
      generic map (
         PRESC_HI_PERIOD_G   => PRESC_HI_PERIOD_G,
         PRESC_LO_PERIOD_G   => PRESC_LO_PERIOD_G
      )
      port map (
         clk                 => clk,
         mic_dat             => micDat,
         mic_clk             => micClk,
         mic_sel             => micSel,
         mic_cen             => micCenLoc,
         fifo_dat            => micFifoDat,
         fifo_wen            => micFifoWen
      );

   U_SIN : entity work.SinGen12
      port map (
         clk                 => clk,
         cen                 => sinCen,
         sin                 => audSin
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
      constant GROWTH_C           : natural := AUDIO_DECM_G**STAGES;
      constant LD_GROWTH_C        : natural := integer(ceil(log2(real(GROWTH_C))));
      constant SIGNIFICANT_BITS_C : natural := 1 +  LD_GROWTH_C;
      -- FACT_W_C: multiplier width (given by hardware)
      constant FACT_W_C         : natural := 18;
      signal   cicData            : S24Type;
      signal   cicDataDly         : S24Type;
      signal   prod               : signed(2*FACT_W_C - 1 downto 0) := (others => '0');
      -- pipeline stages of MADDer (1 for product, 1 for accumulator)
      signal   cicCenDlyIn        : std_logic;
      signal   cicCenDly          : std_logic_vector(1 downto 0)    := (others => '0');

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
            decmInp          => DECM_Z_BASED_C,
            dataInp          => cicDataIn,
            dataOut          => cicDataOu,
            strbOut          => cicCenDlyIn
         );

      P_MAP : process ( cicDataOu ) is
      begin
         cicData <= mapPart(cicDataOu, cicData'length, cicDataOu'length - SIGNIFICANT_BITS_C);
      end process P_MAP;

      -- scale with (2**LD_GROWTH_C - 1)/GROWTH_C; this scale is always between 1 and 2
      -- => out = in + in * ( 1 - scale ); the multiplication with 1-scale saves one bit
      -- in the multiplier

      P_SCALE : process ( clk ) is
         -- represents 'one' but does not directly fit
         -- into the multiplier (largest positive number is ONE_C - 1).
         constant ONE_C    : natural := 2**(FACT_W_C - 1);
         -- scale as a real number full-scale => 2**LD_GROWTH_C - 1
         -- RSCALE_C = ((full_scale/growth) - 1) * ONE_C, i.e., the deviation from one normalized to ONE_C
         -- (so that we can perform integer multiplication)
         constant RSCALE_C : real    := real((2**LD_GROWTH_C - 1) - GROWTH_C)*real(ONE_C)/real(GROWTH_C);

         -- scale factor, renormalized to ONE_C, as a signed number matching the multiplier port width
         -- (FACT_W_C).
         constant SCALE_C  : signed(FACT_W_C - 1 downto 0) := to_signed(integer(round(RSCALE_C)), FACT_W_C);
      begin
         if ( rising_edge(clk) ) then
            -- prod = (scale - 1)*ONE_C * data
            prod           <= SCALE_C * cicData(cicData'left downto cicData'length - FACT_W_C);
            -- delay the data while the product is computed
            cicDataDly     <= cicData;
            -- add data + product; (1 + (scale - 1))*data = data + (scale-1)*data
            audCic(STAGES) <= cicDataDly + mapPart(prod, audCic(STAGES)'length, 1);
            -- delay the strobe by the number of pipeline stages (2)
            cicCenDly      <= cicCenDlyIn & cicCenDly(cicCenDly'left downto 1);
         end if;
      end process P_SCALE;

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
      
end architecture rtl;
