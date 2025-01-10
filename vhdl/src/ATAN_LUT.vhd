library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY ATAN_LUT is
  port (
    address  : in  std_logic_vector(3 downto 0);
    lut_out : out std_logic_vector(23 downto 0)
  );
end entity;

architecture rtl of ATAN_LUT is

  type LUT_t is array (natural range 0 to 15) of integer;
  constant LUT: LUT_t := (
  0 => 1647099,
  1 => 972339,
  2 => 513757,
  3 => 260791,
  4 => 130901,
  5 => 65514,
  6 => 32765,
  7 => 16383,
  8 => 8191,
  9 => 4095,
  10 => 2047,
  11 => 1023,
  12 => 511,
  13 => 255,
  14 => 127,
  15 => 63,
  others => 0
  );

begin

PROCESS (address)
BEGIN
  lut_out <= STD_LOGIC_VECTOR(to_signed(LUT(to_integer(unsigned(address))), 24));
END PROCESS;

end architecture;
