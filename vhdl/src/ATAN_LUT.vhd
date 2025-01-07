
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

  type LUT_t is array (natural range 0 to 15) of integer;
  constant LUT: LUT_t := (
	0  => 6442,   -- arctan(1)       in Q3.13
    1  => 3803,   -- arctan(1/2)     in Q3.13
    2  => 2006,   -- arctan(1/4)     in Q3.13
    3  => 1020,   -- arctan(1/8)     in Q3.13
    4  => 512,    -- arctan(1/16)    in Q3.13
    5  => 256,    -- arctan(1/32)    in Q3.13
    6  => 128,    -- arctan(1/64)    in Q3.13
    7  => 64,     -- arctan(1/128)   in Q3.13
    8  => 32,     -- arctan(1/256)   in Q3.13
    9  => 16,     -- arctan(1/512)   in Q3.13
    10 => 8,      -- arctan(1/1024)  in Q3.13
    11 => 4,      -- arctan(1/2048)  in Q3.13
    12 => 2,      -- arctan(1/4096)  in Q3.13
    13 => 1,      -- arctan(1/8192)  in Q3.13
    14 => 1,      -- arctan(1/16384) in Q3.13
    15 => 0       -- arctan(1/32768) in Q3.13
	  );

begin

PROCESS (address)
BEGIN
  lut_out <= STD_LOGIC_VECTOR(to_signed(LUT(to_integer(unsigned(address))), 16));
END PROCESS;

end architecture;
