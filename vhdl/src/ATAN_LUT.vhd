
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY ATAN_LUT is
  port (
    address  : in  std_logic_vector(3 downto 0);
    lut_out : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of ATAN_LUT is

  type LUT_t is array (natural range 0 to 15) of integer;
  constant LUT: LUT_t := (
	0 => 51471,
	1 => 30385,
	2 => 16054,
	3 => 8149,
	4 => 4090,
	5 => 2047,
	6 => 1023,
	7 => 511,
	8 => 255,
	9 => 127,
	10 => 63,
	11 => 31,
	12 => 15,
	13 => 7,
	14 => 3,
	15 => 1
	  );

begin

PROCESS (address)
BEGIN
  IF (to_integer(unsigned(address)) <= 15 ) THEN
    lut_out <= STD_LOGIC_VECTOR(to_signed(LUT(to_integer(unsigned(address))), 32));
  ELSE
    lut_out <= (OTHERS => '0');
  END IF;
END PROCESS;

end architecture;
