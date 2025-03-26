library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.MicDataPkg.all;

entity wrpTb is
end entity wrpTb;

architecture sim of wrpTb is
  signal clk    : std_logic := '0';
  signal micClk : std_logic;
  signal micDat : std_logic := '0';
  signal audCen : std_logic := '0';
  signal audDat : signed(23 downto 0);

  signal idx    : integer := 0;
begin

  P_CLK : process is
  begin
    if ( idx >= MIC_DAT_C'length ) then
      wait;
    end if;
    wait for 5 us;
    clk <= not clk;
  end process P_CLK;

  micDat <= MIC_DAT_C(idx);

  P_MIC : process (micClk) is
  begin
    if ( falling_edge(micClk) ) then
      idx    <= idx + 1;
    end if;
  end process P_MIC;

  P_REP : process( clk ) is
  begin
    if ( rising_edge(clk) ) then
      if ( audCen = '1' ) then
        report integer'image(to_integer(audDat));
      end if;
    end if;
  end process P_REP;

  U_DUT : entity work.MicWrapper
    generic map (
      PRESC_HI_PERIOD_G => 1,
      PRESC_LO_PERIOD_G => 1,
      MIN_CIC_STAGES_G  => 3,
      MAX_CIC_STAGES_G  => 3,
      AUDIO_DECM_G      => 50
    )
    port map (
      clk => clk,
      rst => '0',
      micDat => micDat,
      micClk => micClk,
      audSel => to_unsigned(1,3),
      audCen => audCen,
      audDat => audDat
    );

end architecture sim;
