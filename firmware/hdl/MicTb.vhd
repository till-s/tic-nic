library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity micTb is
end entity micTb;

architecture sim of micTb is
   constant EXT_REG_C : boolean   := false;
   constant HPER_C    : unsigned(7 downto 0) := to_unsigned(15, 8);

   signal clk         : std_logic := '0';
   signal mic_dat     : std_logic_vector(63 downto 0) := x"0716253443526170";
   signal mic_clk     : std_logic;
   signal mic_xclk    : std_logic := '0';
   signal mic_xdat    : std_logic := '0';
   signal lst_clk     : std_logic := '0';
   signal fifo_dat    : std_logic_vector(7 downto 0);
   signal fifo_wen    : std_logic;


   signal run         : boolean   := true;

   function CEN_DLY_F return natural is
   begin
      if ( EXT_REG_C ) then
         return 2;
      else
         return 0;
      end if;
   end function CEN_DLY_F;
begin

   P_CLK : process is
   begin
      if ( not run ) then
         wait;
      else
         wait for 8.333 ns;
         clk <= not clk;
      end if;
   end process P_CLK;

   G_EXT_REG : if ( EXT_REG_C ) generate
   begin
      P_DLY : process ( clk ) is
      begin
         if ( rising_edge( clk ) ) then
            mic_xclk <= mic_clk;
            mic_xdat <= mic_dat(0);
         end if;
      end process P_DLY;
   end generate G_EXT_REG;

   G_NO_EXT_REG : if ( not EXT_REG_C ) generate
   begin
      mic_xclk <= mic_clk;
      mic_xdat <= mic_dat(0);
   end generate G_NO_EXT_REG;


   P_CTL : process ( clk ) is
      variable cnt : integer := -1;
   begin
      if ( rising_edge( clk ) ) then
         lst_clk  <= mic_xclk;
         if ( (not mic_xclk and lst_clk) = '1' ) then
            mic_dat <= mic_dat(0) & mic_dat(mic_dat'left downto 1);
         end if;
         if ( fifo_wen = '1' ) then
            if ( 8*cnt >= mic_dat'length ) then
               report "Test PASSED";
               run <= false;
            else
               -- after reset there is a first fifo_wen cycle that
	       -- should be ignored; mic_dat is rotated!
               assert cnt < 0  or mic_dat(63 downto 56) = fifo_dat severity failure;
               cnt := cnt + 1;
            end if;
         end if;
      end if;
   end process P_CTL;

   U_DUT : entity work.MicInput
      generic map (
         CEN_DLY_G       => CEN_DLY_F
      )
      port map (
         clk             => clk,
         rst             => '0',
         micDat          => mic_xdat,
         micClk          => mic_clk,
         prescPeriodLo   => HPER_C,
         prescPeriodHi   => HPER_C,
         fifoDat         => fifo_dat,
         fifoWen         => fifo_wen
      );
end architecture sim;
