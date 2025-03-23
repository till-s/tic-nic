-- Trivial sine-wave generator using static lookup table.
-- A sine-wave of fs/48 is generated.

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity SinGen12 is
   port (
      clk            : in  std_logic;
      cen            : in  std_logic;
      sin            : out signed(23 downto 0);
      -- repeat each sample 'rep' times
      rep            : in  natural range 0 to 7 := 0
   );
end entity SinGen12;


architecture rtl of SinGen12 is
begin

   P_SING : process ( clk ) is
      variable smpl  : signed(23 downto 0)     := (others => '0');
      constant SCL_C : signed(23 downto 0)     := to_signed(2**23 - 17000, 24);

      type U24Array is array (integer range <>) of signed(23 downto 0);

      constant SIN_TBL_C : U24Array := (
         0 => to_signed(  548641, 24),
         1 => to_signed( 1636536, 24),
         2 => to_signed( 2696430, 24),
         3 => to_signed( 3710186, 24),
         4 => to_signed( 4660461, 24),
         5 => to_signed( 5530994, 24),
         6 => to_signed( 6306889, 24),
         7 => to_signed( 6974873, 24),
         8 => to_signed( 7523514, 24),
         9 => to_signed( 7943426, 24),
        10 => to_signed( 8227423, 24),
        11 => to_signed( 8370647, 24)
      );

      variable idx    : natural range SIN_TBL_C'range := 0;
      variable quad   : natural range 0 to 3          := 0;
      variable repCnt : natural range 0 to 7          := 0;
      variable cnt    : integer range -1 to 2         := -1;
   begin
      if ( rising_edge( clk ) ) then
         if ( cen = '1' ) then
            if ( quad < 2 ) then
               smpl :=  SIN_TBL_C(idx);
            else
               smpl := -SIN_TBL_C(idx);
            end if;
            if ( cnt >= 0 ) then
               cnt := cnt - 1;
            else
               case quad is
                  when 0 | 2 =>
                     if ( SIN_TBL_C'high = idx ) then
                        if ( quad = 0 ) then
                           quad := 1;
                        else
                           quad := 3;
                        end if;
                     else
                        idx  := idx + 1;
                     end if;
                  when 1 | 3 =>
                     if ( SIN_TBL_C'low  = idx ) then
                        if ( quad = 1 ) then
                           quad := 2;
                        else
                           quad := 0;
                        end if;
                     else
                        idx  := idx - 1;
                     end if;
               end case;
               cnt := repCnt - 1;
            end if;
         end if;
         repCnt := rep;
      end if;
      sin <= smpl;
   end process P_SING;

end architecture rtl;

