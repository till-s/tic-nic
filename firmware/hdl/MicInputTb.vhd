--LB-MIT
--
-- MIT License
--
-- Copyright (c) 2026 Till Straumann
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--
--LE-MIT

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity MicInputTb is
end entity MicInputTb;

architecture sim of MicInputTb is
   constant HPER_C : unsigned(7 downto 0) := to_unsigned(15, 8);
   signal clk      : std_logic := '0';
   signal mic_clk  : std_logic;
   signal moc_clk  : std_logic := '0';
   signal mic_dat  : std_logic := '0';
   signal cnt      : integer := 10;
   signal resync   : std_logic := '0';
begin
   P_CLK : process is
   begin
      wait for 1 us;
      clk <= not clk;
      if ( cnt < 0 ) then
         wait;
      end if;
   end process P_CLK;

   P_SYNC : process ( clk ) is
      variable scnt : integer := 30;
      variable mcnt : integer := 0;
   begin
      if ( rising_edge( clk) ) then
         resync <= '0';
	 if ( scnt = 0 ) then
	    resync <= '1';
	 end if;
	 if ( scnt >= 0 ) then
	    scnt := scnt - 1;
	 end if;
	 if ( mcnt < 0 ) then
	    moc_clk <= not moc_clk;
	    mcnt := to_integer(HPER_C) - 2;
	 else
	    mcnt := mcnt - 1;
	 end if;
      end if;
   end process P_SYNC;

   P_MIC : process ( moc_clk ) is
      variable dat : std_logic := '0';
   begin
      if ( rising_edge(moc_clk) ) then
         dat     := not dat;
	 mic_dat <= dat;
         cnt     <= cnt - 1;
      end if;
      if ( falling_edge(moc_clk) ) then
         mic_dat <= '0';
      end if;
   end process P_MIC;

   U_DUT : entity work.MicInput
      port map (
         clk     => clk,
         rst     => '0',
	 micDat  => mic_dat,
	 micClk  => mic_clk,
	 resync  => resync,
	 prescPeriodLo => HPER_C,
	 prescPeriodHi => HPER_C
      );
end architecture sim;
