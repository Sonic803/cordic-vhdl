
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY ATAN_LUT is
  port (
    address  : in  std_logic_vector(3 downto 0);
    lut_out : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of ATAN_LUT is

  type LUT_t is array (natural range 0 to 9) of integer;
  constant LUT: LUT_t := (
	0 => 201,
	1 => 118,
	2 => 62,
	3 => 31,
	4 => 15,
	5 => 7,
	6 => 3,
	7 => 1,
	8 => 0,
	9 => 0
	  );

begin
--   lut_out <= std_logic_vector(to_signed(LUT(to_integer(unsigned(address))),16));
  lut_out <= (OTHERS => '1');
end architecture;
