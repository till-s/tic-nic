library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity MicInput is
   generic (
      PRESC_WIDTH_G       : positive  := 8;
      CEN_DLY_G           : natural   := 0;
      MIC_SEL_G           : std_logic := '0';
      MIC_DAT_CC_STAGES_G : natural   := 0
   );
   port (
      clk                 : in  std_logic;
      rst                 : in  std_logic;
      mic_dat             : in  std_logic;
      mic_clk             : out std_logic;
      mic_dat_sync        : out std_logic;
      mic_cen             : out std_logic;
      fifo_dat            : out std_logic_vector(7 downto 0);
      fifo_wen            : out std_logic;
      -- prescaler for generating the microphone clock; the rate is
      -- the input ('clk') frequency divided by (prescPeriodLo + 1 + prescPeriodHi + 1),
      -- i.e., the values provided is the actual value - 1.
      -- The clock stays low for (prescPeriodLo + 1) cycles and high for
      -- (prescPeriodHi + 1) cycles;
      -- unless both values are set no clock is generated
      prescPeriodLo       : in  unsigned(PRESC_WIDTH_G - 1 downto 0);
      prescPeriodHi       : in  unsigned(PRESC_WIDTH_G - 1 downto 0);
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

   -- add a sign bit
   subtype PrescalerType is signed(PRESC_WIDTH_G downto 0);

   type RegType is record
      shift_reg : std_logic_vector(7 downto 0);
      fifo_wena : std_logic_vector(7 downto 0);
      prescaler : PrescalerType;
      perLo     : PrescalerType;
      perHi     : PrescalerType;
      mic_clk   : std_logic;
      cen       : std_logic_vector(CEN_DLY_G downto 0);
      synced    : std_logic;
      lstDat    : std_logic;
      resync    : std_logic;
   end record RegType;

   constant REG_INIT_C : RegType := (
      shift_reg => ( others => '0' ),
      fifo_wena => ( 0 => '1', others => '0'),
      prescaler => ( others => '0' ), -- first clock registers periods;
      perLo     => ( others => '1' ),
      perHi     => ( others => '1' ),
      mic_clk   => MIC_SEL_G,
      cen       => ( others => '0' ),
      synced    => '1', -- only sync on request
      -- reset to 'active' to ensure we don't see a spurious
      -- not active -> active transition after reset.
      lstDat    => MIC_DAT_ACTIVE_C,
      resync    => '0'
   );

   signal r                : RegType := REG_INIT_C;
   signal rin              : RegType;
   signal cen_in           : std_logic;

   signal mic_dat_sync_loc : std_logic;

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
      mic_dat_sync_loc <= syncReg(syncReg'left);
   end generate G_CC;

   G_NO_CC : if ( MIC_DAT_CC_STAGES_G = 0 ) generate
   begin
      mic_dat_sync_loc <= mic_dat;
   end generate G_NO_CC;

   P_COMB : process ( r, mic_dat_sync_loc, cen_in, resync, prescPeriodLo, prescPeriodHi ) is
      variable v : RegType;
   begin
      v           := r;

      v.lstDat    := mic_dat_sync_loc;

      v.perLo     := signed( resize( prescPeriodLo, v.perLo'length ) );
      v.perHi     := signed( resize( prescPeriodHi, v.perHi'length ) );

      v.resync    := resync;

      if ( r.prescaler < 0 ) then
         if ( r.mic_clk = '1' ) then
            v.prescaler := r.perLo - 1;
         else
            v.prescaler := r.perHi - 1;
         end if;
         v.mic_clk   := not r.mic_clk;
      end if;

      v.prescaler := v.prescaler - 1;

      v.cen := cen_in & r.cen( r.cen'left downto 1 );

      if ( r.cen( 0 ) = '1' ) then
         v.fifo_wena := r.fifo_wena( 0 ) & r.fifo_wena( r.fifo_wena'left downto 1 );
         v.shift_reg := mic_dat_sync_loc & r.shift_reg( r.shift_reg'left downto 1 );
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
         if ( ( mic_dat_sync_loc and not r.lstDat ) = MIC_DAT_ACTIVE_C ) then
           -- deactivate the clock; may cause a glitch
           -- but who cares.
           v.mic_clk   := MIC_SEL_G;
           if ( not MIC_SEL_G = '1' ) then
              v.prescaler := shift_right(r.perLo, 1);
           else
              v.prescaler := shift_right(r.perHi, 1);
           end if;
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

   fifo_dat     <= r.shift_reg;
   fifo_wen     <= r.fifo_wena(0) and r.cen(0);
   mic_clk      <= r.mic_clk;
   mic_cen      <= r.cen(0);
   synced       <= r.synced;
   mic_dat_sync <= mic_dat_sync_loc;

end architecture rtl;
