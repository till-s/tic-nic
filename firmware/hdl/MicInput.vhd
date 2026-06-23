library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity MicInput is
   generic (
      -- arbitray upper bound; lower bound is 2
      PRESC_HI_PERIOD_G   : positive range 2 to 10000 := 15;
      PRESC_LO_PERIOD_G   : positive range 2 to 10000 := 15;
      CEN_DLY_G           : natural   := 0;
      MIC_SEL_G           : std_logic := '0';
      MIC_DAT_CC_STAGES_G : natural   := 0
   );
   port (
      clk                 : in  std_logic;
      rst                 : in  std_logic;
      mic_dat             : in  std_logic;
      mic_clk             : out std_logic;
      mic_cen             : out std_logic;
      fifo_dat            : out std_logic_vector(7 downto 0);
      fifo_wen            : out std_logic;
      -- rising edge on 'resync' causes the
      -- mic_clk to be 'resynchronized'; this means
      -- that the data line is observed until a rising
      -- edge is seen; then the prescaler is 'hard-reset'
      -- so that mic_clk's active edge occurs 1/4
      -- period after the change in data.
      -- Works only in mono-configuration; in stereo
      -- it is impossible to detect the L/R phase.
      -- In mono it is also possible to do 'full'
      -- clock recovery by locking a PLL to the
      -- data transitions. Would work best if the input
      -- is driven by a toggling FF (i.e.  the inactive
      -- clock phase is driven with 'not mic_dat') but
      -- with sufficient frequency resolution and stability
      -- it should also work w/o that (there may be quite
      -- long stretches without any edges so the frequency
      -- must track quite accurately).
      resync              : in  std_logic := '0';
      synced              : out std_logic
   );
end entity MicInput;

architecture rtl of MicInput is

   constant MIC_DAT_ACTIVE_C : std_logic := '1';

   function PRESC_HI_F return natural is
      variable v : integer;
   begin
      v := PRESC_LO_PERIOD_G;
      if ( v < PRESC_HI_PERIOD_G ) then
         v := PRESC_HI_PERIOD_G;
      end if;
      if ( v <= 2 ) then
         v := 1;
      else
         v := integer(ceil(log2(real(v - 2)))) + 1;
      end if;
      return v + 1; -- sign bit
   end function PRESC_HI_F;

   subtype PrescalerType is signed(PRESC_HI_F downto 0);

   type RegType is record
      shift_reg : std_logic_vector(7 downto 0);
      fifo_wena : std_logic_vector(7 downto 0);
      prescaler : PrescalerType;
      mic_clk   : std_logic;
      cen       : std_logic_vector(CEN_DLY_G downto 0);
      synced    : std_logic;
      lstDat    : std_logic;
      resync    : std_logic;
   end record RegType;

   function PRESC_INIT_F(constant clkPol : in std_logic)
   return PrescalerType is
      variable v : integer;
   begin
      if ( clkPol = '1' ) then
         v := PRESC_LO_PERIOD_G;
      else
         v := PRESC_HI_PERIOD_G;
      end if;
      return to_signed( v - 2, PrescalerType'length );
   end function PRESC_INIT_F;
 
   constant REG_INIT_C : RegType := (
      shift_reg => ( others => '0' ),
      fifo_wena => ( 0 => '1', others => '0'),
      -- PRESC_INIT_F takes the *previous* clock level
      prescaler => PRESC_INIT_F('1'),
      mic_clk   => MIC_SEL_G,
      cen       => ( others => '0' ),
      synced    => '1', -- only sync on request
      -- reset to 'active' to ensure we don't see a spurious
      -- not active -> active transition after reset.
      lstDat    => MIC_DAT_ACTIVE_C,
      resync    => '0'
   );

   signal r            : RegType := REG_INIT_C;
   signal rin          : RegType;
   signal cen_in       : std_logic;

   signal mic_dat_sync : std_logic;

begin

   G_CC : if ( MIC_DAT_CC_STAGES_G > 0 ) generate
      signal syncReg      : std_logic_vector(MIC_DAT_CC_STAGES_G - 1 downto 0) := (others => MIC_DAT_ACTIVE_C);

      -- apparently 'string' works for efinity as well (manual says boolean)
      attribute ASYNC_REG : string;
      attribute ASYNC_REG of syncReg : signal is "TRUE";
   begin
      P_CC : process ( clk ) is
      begin
         if ( rising_edge( clk ) ) then
            if ( rst = '1' ) then
               syncReg <= (others => MIC_DAT_ACTIVE_C);
            else
               syncReg <= syncReg(syncReg'left - 1 downto syncReg'right) & mic_dat;
            end if;
         end if;
      end process P_CC;
      mic_dat_sync <= syncReg(syncReg'left);
   end generate G_CC;

   G_NO_CC : if ( MIC_DAT_CC_STAGES_G = 0 ) generate
   begin
      mic_dat_sync <= mic_dat;
   end generate G_NO_CC;

   P_COMB : process ( r, mic_dat_sync, cen_in, resync ) is
      variable v : RegType;
   begin
      v           := r;

      v.lstDat    := mic_dat_sync;

      v.resync    := resync;
      v.prescaler := r.prescaler - 1;
      if ( r.prescaler < 0 ) then
         v.prescaler := PRESC_INIT_F(r.mic_clk);
         v.mic_clk   := not r.mic_clk;
      end if;

      v.cen := cen_in & r.cen( r.cen'left downto 1 );

      if ( r.cen( 0 ) = '1' ) then
         v.fifo_wena := r.fifo_wena( 0 ) & r.fifo_wena( r.fifo_wena'left downto 1 );
         v.shift_reg := mic_dat_sync & r.shift_reg( r.shift_reg'left downto 1 );
      end if;

      if ( MIC_SEL_G = '1' ) then
         cen_in <= not v.mic_clk and r.mic_clk;
      else
         cen_in <= v.mic_clk and not r.mic_clk;
      end if;

      -- not very sophisticated; just hard-reset the
      -- prescaler so that a detected active edge
      -- is 1/2 clock cycle ahead of the active output clock
      if ( r.synced = '0' ) then
         if ( ( mic_dat_sync and not r.lstDat ) = MIC_DAT_ACTIVE_C ) then
           -- deactivate the clock; may cause a glitch
           -- but who cares.
           v.mic_clk   := MIC_SEL_G;
           v.prescaler := shift_right(PRESC_INIT_F( not MIC_SEL_G ), 1);
           v.synced    := '1';
         end if;
      end if;

      if ( (not r.resync and resync) = '1' ) then
         v.synced := '0';
      end if;

      rin    <= v;
   end process P_COMB;

   P_SEQ : process ( clk ) is
   begin
      if ( rising_edge( clk ) ) then
         if ( rst = '1' ) then
            r <= REG_INIT_C;
         else
            r <= rin;
         end if;
      end if;
   end process P_SEQ;

   fifo_dat <= r.shift_reg;
   fifo_wen <= r.fifo_wena(0) and r.cen(0);
   mic_clk  <= r.mic_clk;
   mic_cen  <= r.cen(0);
   synced   <= r.synced;

end architecture rtl;
