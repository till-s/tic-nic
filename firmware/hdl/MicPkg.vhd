library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package MicPkg is

   subtype S24Type    is signed(23 downto 0);
   type    S24Array   is array (integer range <>) of S24Type;

   subtype ScaleType  is signed(31 downto 0);
   type    ScaleArray is array (integer range <>) of ScaleType;

   subtype ShiftType  is signed(7  downto 0);
   type    ShiftArray is array (integer range <>) of ShiftType;

   -- compute the scale factor for a CIC filter
   -- with a number of 'STAGES' at a given decimation.
   -- The result is scaled by 2**FACT_W_C, i.e.,
   -- the CIC output can be multiplied by the result
   -- of this function and the product right-shifted
   -- by FACT_W_C to obtain the result.
   -- The result is left adjusted in ScaleType.

   -- THIS FUNCTION IS NOT SYNTHESIZABLE (except if the
   -- inputs are constants and the result can be evaluated
   -- immediately).

   function cicScaleFactor(
      -- zero-based decimation
      constant audioDecm : unsigned;
      constant STAGES    : positive;
      constant FACT_W_C  : positive
   ) return ScaleType;

   -- right shift applied to CIC output to align into
   -- AUDIO_W; may be negative (-> left-shift)
   function cicScaleFactorShift(
      -- zero-based decimation
      constant audioDecm : unsigned;
      constant STAGES    : positive;
      constant AUDIO_W   : positive := S24Type'length
   ) return ShiftType;

end package MicPkg;

package body MicPkg is

   -- scale factor 2**(ceil(ld(growth)) - ld(growth)) - 1.0
   -- scaled to multiplier width and left-adjusted in to ScaleType

   function cicLdGrowth(
      -- zero-based
      constant audioDecm : unsigned;
      constant STAGES    : positive
   ) return real is
   begin
      return real(STAGES) * log2(real(to_integer(audioDecm) + 1));
   end function cicLdGrowth;

   function cicScaleFactor(
      constant audioDecm : unsigned;
      constant STAGES    : positive;
      constant FACT_W_C  : positive
   ) return ScaleType is
      constant LD_GROWTH_C : real := cicLdGrowth( audioDecm, STAGES );
      variable v           : ScaleType;
   begin
      v := to_signed( integer( round((2**(ceil(LD_GROWTH_C) - LD_GROWTH_C) - 1.0)* 2.0**(FACT_W_C - 1)) ), v'length );
      return shift_left( v, v'length - FACT_W_C );
   end function cicScaleFactor;

   function cicScaleFactorShift(
      -- zero-based decimation
      constant audioDecm : unsigned;
      constant STAGES    : positive;
      constant AUDIO_W   : positive := S24Type'length
   ) return ShiftType is
      constant LD_GROWTH_C : real := cicLdGrowth( audioDecm, STAGES );
   begin
      return to_signed( AUDIO_W  - 1 - integer(ceil(LD_GROWTH_C)), ShiftType'length );
   end function cicScaleFactorShift;

end package body MicPkg;

