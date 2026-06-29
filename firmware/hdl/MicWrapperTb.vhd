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

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.MicPkg.all;
use work.DatPkg.all;

entity MicWrapperTb is
end entity MicWrapperTb;

architecture sim of MicWrapperTb is
   constant STAGE_C              : natural                        := 1;
   constant MIC_PRESC_HI_C       : unsigned(7 downto 0)           := to_unsigned(12, 8);
   constant MIC_PRESC_LO_C       : unsigned(7 downto 0)           := to_unsigned(13, 8);
   constant DECM_C               : unsigned(7 downto 0)           := to_unsigned(50 - 1, 8);
   constant SCLS_C               : ScaleArray(STAGE_C to STAGE_C) := (STAGE_C => cicScaleFactor     (DECM_C, STAGE_C, 18));
   constant SHFS_C               : ShiftArray(STAGE_C to STAGE_C) := (STAGE_C => cicScaleFactorShift(DECM_C, STAGE_C, 24));
   signal   sinPdm               : std_logic;
   signal   clk                  : std_logic := '0';
   signal   audDat               : signed(23 downto 0);
   signal   audDatCen            : std_logic;
   signal   audDatReg            : signed(23 downto 0);
   signal   micDat               : std_logic;
   signal   micClk               : std_logic;
   signal   run                  : boolean := true;
begin

   P_CLK : process is
      variable v : integer := 0;
   begin
      wait for 500 ps;
      clk <= not clk;
      if ( not run ) then
         wait;
      else
         if ( clk = '1' ) then
            v := v + 1;
         end if;
      end if;
   end process P_CLk;

   P_FEED: process ( micClk ) is
      variable idx : natural := 0;
   begin
      if ( falling_edge( micClk ) ) then
         if ( idx < DAT_C'high ) then
            idx := idx + 1;
         else
            run <= false;
         end if;
      end if;
      micDat <= DAT_C(idx);
   end process P_FEED;


   P_REG : process ( clk ) is
   begin
      if ( rising_edge( clk ) ) then
         if ( audDatCen = '1' ) then
            audDatReg <= audDat;
         end if;
      end if;
   end process P_REG;

   U_DUT : entity work.MicWrapper
      generic map (
         MIC_DAT_CC_STAGES_G => 2,
         MIN_CIC_STAGES_G    => STAGE_C,
         MAX_CIC_STAGES_G    => STAGE_C
      )
      port map (
         clk                 => clk,
         rst                 => '0',
         micInputRst         => '0',
         micDat              => sinPdm,
         micClk              => micClk,
         micPrescPeriodLo    => MIC_PRESC_LO_C,
         micPrescPeriodHi    => MIC_PRESC_HI_C,
         audSel              => to_unsigned(4, 3),
         audDecm             => DECM_C,
         audScales           => SCLS_C,
         audShifts           => SHFS_C,
         audDat              => audDat,
         audCen              => audDatCen,
         sinPdm              => sinPdm
      );
    
end architecture sim;
