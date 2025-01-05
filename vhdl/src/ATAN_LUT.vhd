
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY ATAN_LUT is
  port (
    address  : in  std_logic_vector(3 downto 0);
    lut_out : out std_logic_vector(19 downto 0)
  );
end entity;

architecture rtl of ATAN_LUT is

  type LUT_t is array (natural range 0 to 15) of integer;
  constant LUT: LUT_t := (
	0 => 102943,
	1 => 60771,
	2 => 32109,
	3 => 16299,
	4 => 8181,
	5 => 4094,
	6 => 2047,
	7 => 1023,
	8 => 511,
	9 => 255,
	10 => 127,
	11 => 63,
	12 => 31,
	13 => 15,
	14 => 7,
	15 => 3
	  );

begin

PROCESS (address)
BEGIN
  lut_out <= STD_LOGIC_VECTOR(to_signed(LUT(to_integer(unsigned(address))), 20));
END PROCESS;

end architecture;
