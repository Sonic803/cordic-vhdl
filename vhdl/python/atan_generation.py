#!/bin/python

import math

stringa = """library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY {mname} is
  port (
    address  : in  std_logic_vector({addr_bits} downto 0);
    lut_out : out std_logic_vector({width} downto 0)
  );
end entity;

architecture rtl of {mname} is

  type LUT_t is array (natural range 0 to {lines}) of integer;
  constant LUT: LUT_t := (
  {lut}
  others => 0
  );

begin

PROCESS (address)
BEGIN
  lut_out <= STD_LOGIC_VECTOR(to_signed(LUT(to_integer(unsigned(address))), {actual_width}));
END PROCESS;

end architecture;
"""

line = "{addr} => {val},"

M = 24
N = 16
FRAC = 8
angle_FRAC = M - 3
ITERATIONS = 16

mname = "ATAN_LUT"
addr_bits = int(math.log2(ITERATIONS - 1)) + 1
width = M
lines = 2**addr_bits

values = [int(math.atan(2 ** (-i)) * 2 ** (angle_FRAC)) for i in range(2**addr_bits)]

# check that the values are in the range of the width
for i in range(len(values)):
    assert values[i] >= -(2 ** (width - 1)) and values[i] < 2 ** (
        width - 1
    ), "Value out of range: {}".format(values[i])

lut = "\n  ".join([line.format(addr=i, val=value) for i, value in enumerate(values)])

result = stringa.format(
    mname=mname,
    addr_bits=addr_bits - 1,
    width=width - 1,
    lines=lines - 1,
    lut=lut,
    actual_width=width,
)

with open(f"vhdl/src/{mname}.vhd", "w") as f:
    f.write(result)

