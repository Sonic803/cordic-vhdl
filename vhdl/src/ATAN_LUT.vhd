
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ATAN_LUT IS
	PORT (
		address : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		lut_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE rtl OF ATAN_LUT IS

	TYPE LUT_t IS ARRAY (NATURAL RANGE 0 TO 9) OF INTEGER;
	CONSTANT LUT : LUT_t := (
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

BEGIN

	PROCESS (address)
	BEGIN
		IF (to_integer(unsigned(address)) < 10) THEN
			lut_out <= STD_LOGIC_VECTOR(to_signed(LUT(to_integer(unsigned(address))), 16));
		ELSE
			lut_out <= (OTHERS => '0');
		END IF;
	END PROCESS;
END ARCHITECTURE;