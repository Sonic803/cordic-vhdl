#!/bin/python

import math

stringa = """
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY {mname} is
  port (
    address  : in  std_logic_vector({length} downto 0);
    lut_out : out std_logic_vector({width} downto 0)
  );
end entity;

architecture rtl of {mname} is

  type LUT_t is array (natural range 0 to {lines}) of integer;
  constant LUT: LUT_t := (
	{lut}
	  );

begin
  lut_out <= std_logic_vector(to_signed(LUT(to_integer(unsigned(address))),{actual_width}));
end architecture;
"""

line = "{addr} => {val},"

N = 16
FRAC = 8
ITERATIONS = 10

mname = "ATAN_LUT"
length = int(math.log2(ITERATIONS))
width = N
lines = ITERATIONS - 1

values = [int(math.atan(2**(-i)) * 2**FRAC) for i in range(ITERATIONS)]

# check that the values are in the range of the width
for i in range(len(values)):
    assert values[i] >= -(2 ** (width - 1)) and values[i] < 2 ** (
        width - 1
    ), "Value out of range: {}".format(values[i])

lut = "\n\t".join([line.format(addr=i, val=value) for i, value in enumerate(values)])[
    :-1
]  # Remove last comma


result = stringa.format(
    mname=mname,
    length=length,
    width=width - 1,
    lines=lines,
    lut=lut,
    actual_width=width,
)

with open(f"{mname}.vhd", "w") as f:
    f.write(result)


An = 1

for i in range(0, ITERATIONS):
    An = An * math.sqrt(1 + 1 / (2**i) ** 2)

print(f"An = {An}")
k = 1 / An
print(f"k = {k}")
