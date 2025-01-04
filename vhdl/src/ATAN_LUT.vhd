
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
	0 => 843314856,
	1 => 497837829,
	2 => 263043836,
	3 => 133525158,
	4 => 67021686,
	5 => 33543515,
	6 => 16775850,
	7 => 8388437,
	8 => 4194282,
	9 => 2097149,
	10 => 1048575,
	11 => 524287,
	12 => 262143,
	13 => 131071,
	14 => 65535,
	15 => 32767
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
