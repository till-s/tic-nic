library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity micTb is
end entity micTb;

architecture sim of micTb is
   constant EXT_REG_C : boolean   := false;

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
      variable cnt : integer := 0;
   begin
      if ( rising_edge( clk ) ) then
         lst_clk  <= mic_xclk;
	 if ( (not mic_xclk and lst_clk) = '1' ) then
            mic_dat <= '0' & mic_dat(mic_dat'left downto 1);
         end if;
         if ( cnt > 10 ) then
            run <= false;
         elsif ( fifo_wen = '1' ) then
            cnt := cnt + 1;
	 end if;
      end if;
   end process P_CTL;

   U_DUT : entity work.mic
      generic map (
         CEN_DLY_G => CEN_DLY_F
      )
      port map (
         clk       => clk,
         mic_dat   => mic_xdat,
         mic_clk   => mic_clk,
         fifo_dat  => fifo_dat,
         fifo_wen  => fifo_wen
      );
end architecture sim;
