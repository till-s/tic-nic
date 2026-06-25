-- PDM modulator

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity PDModulator is
   generic (
      SIG_WIDTH_G    : natural := 24
   );
   port (
      clk            : in  std_logic;
      rst            : in  std_logic;
      cen            : in  std_logic;
      sig            : in  signed(SIG_WIDTH_G - 1 downto 0);
      -- repeat each sample 'rep' times
      pdm            : out std_logic
   );
end entity PDModulator;

architecture rtl of PDModulator is

   function ONE_F(constant w : natural) return signed is
      variable v : signed(w - 1 downto 0) := (others => '1');
   begin
      v(v'left) := '0';
      return v;
   end function ONE_F;


   type RegType is record
      -- guard bit; see below
      accu           : signed(SIG_WIDTH_G downto 0);
   end record RegType;

   constant ONE_C : signed := ONE_F(SIG_WIDTH_G);

   constant REG_INIT_C : RegType := (
      accu           => ( others => '0' )
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   P_COMB : process ( r, sig ) is
      variable v : RegType;
   begin
      v          := r;
      -- if 'accu' is small but positive and the input signal is
      -- large but negative then the result becomes up to sig - ONE_C
      -- and we need a guard bit. Assuming the signal changes slowly
      -- further iterations will find 'accu' < 0 but keep adding
      -- (sig + ONE_C) which is positive (|sig| <= ONE_C)
      if ( r.accu >= 0 ) then
         v.accu := r.accu + (resize(sig, r.accu'length) - resize(ONE_C, r.accu'length));
      else
         v.accu := r.accu + (resize(sig, r.accu'length) + resize(ONE_C, r.accu'length));
      end if;

      rin        <= v;
   end process P_COMB;

   P_SEQ : process ( clk ) is
   begin
      if ( rising_edge( clk ) ) then
         if    ( rst = '1' ) then
            r <= REG_INIT_C;
         elsif ( cen = '1' ) then
            report "input " & integer'image(to_integer(sig)) & " accu " & integer'image(to_integer(rin.accu));
            r <= rin;
         end if;
      end if;
   end process P_SEQ;

   pdm <= r.accu(r.accu'left);
   
end architecture rtl;
