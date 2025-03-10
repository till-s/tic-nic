library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mic is
   generic (
      PRESC_HALF_PERIOD_G : natural := 15;
      CEN_DLY_G           : natural := 0
   );
   port (
      clk                 : in  std_logic;
      mic_dat             : in  std_logic;
      mic_clk             : out std_logic;
      fifo_dat            : out std_logic_vector(7 downto 0);
      fifo_wen            : out std_logic
   );
end entity mic;

architecture rtl of mic is

   subtype PrescalerType is signed(5 downto 0);

   function PRESC_INIT_F return PrescalerType is
   begin
      return to_signed( PRESC_HALF_PERIOD_G - 2, PrescalerType'length );
   end function PRESC_INIT_F;

   type RegType is record
      shift_reg : std_logic_vector(7 downto 0);
      fifo_wena : std_logic_vector(7 downto 0);
      prescaler : PrescalerType;
      mic_clk   : std_logic;
      cen       : std_logic_vector(CEN_DLY_G downto 0);
   end record RegType;
 
   constant REG_INIT_C : RegType := (
      shift_reg => ( others => '0' ),
      fifo_wena => ( 0 => '1', others => '0'),
      prescaler => PRESC_INIT_F,
      mic_clk   => '0',
      cen       => ( others => '0' )
   );

   signal r            : RegType := REG_INIT_C;
   signal rin          : RegType;
   signal cen_in       : std_logic;

begin

   P_COMB : process ( r, mic_dat, cen_in ) is
      variable v : RegType;
   begin
      v   := r;

      v.prescaler := r.prescaler - 1;
      if ( r.prescaler < 0 ) then
         v.prescaler := PRESC_INIT_F;
         v.mic_clk   := not r.mic_clk;
      end if;
      v.cen := cen_in & r.cen( r.cen'left downto 1 );

      if ( r.cen( 0 ) = '1' ) then
         v.fifo_wena := r.fifo_wena( 0 ) & r.fifo_wena( r.fifo_wena'left downto 1 );
	 v.shift_reg := mic_dat & r.shift_reg( r.shift_reg'left downto 1 );
      end if;

      cen_in <= v.mic_clk and not r.mic_clk;
      rin    <= v;
   end process P_COMB;

   P_SEQ : process ( clk ) is
   begin
      if ( rising_edge( clk ) ) then
         r <= rin;
      end if;
   end process P_SEQ;

   fifo_dat <= r.shift_reg;
   fifo_wen <= r.fifo_wena(0) and r.cen(0);
   mic_clk  <= r.mic_clk;

end architecture rtl;
