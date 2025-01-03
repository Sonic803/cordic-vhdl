library ieee;
    use ieee.std_logic_1164.all;

entity LUT_arctg is

    port (

        addr            : in    std_logic_vector(4 downto 0);
        data            : out   std_logic_vector(31 downto 0)

    );

end entity;

architecture Behavioral of LUT_arctg is

    signal addr_int : integer range 0 to 31;

    type arctg_array is array (0 to 31) of std_logic_vector(31 downto 0);
    constant arctg_values : arctg_array := (
        "00000000000000001100100100010000", -- arctan(2^-0) = 0.7853981634
        "00000000000000000111011010110010", -- arctan(2^-1) = 0.4636476090
        "00000000000000000011111010110111", -- arctan(2^-2) = 0.2449786631
        "00000000000000000001111111010110", -- arctan(2^-3) = 0.1243549945
        "00000000000000000000111111111011", -- arctan(2^-4) = 0.0624188100
        "00000000000000000000011111111111", -- arctan(2^-5) = 0.0312398334
        "00000000000000000000010000000000", -- arctan(2^-6) = 0.0156237286
        "00000000000000000000001000000000", -- arctan(2^-7) = 0.0078123411
        "00000000000000000000000100000000", -- arctan(2^-8) = 0.0039062301
        "00000000000000000000000010000000", -- arctan(2^-9) = 0.0019531225
        "00000000000000000000000001000000", -- arctan(2^-10) = 0.0009765622
        "00000000000000000000000000100000", -- arctan(2^-11) = 0.0004882812
        "00000000000000000000000000010000", -- arctan(2^-12) = 0.0002441406
        "00000000000000000000000000001000", -- arctan(2^-13) = 0.0001220703
        "00000000000000000000000000000100", -- arctan(2^-14) = 0.0000610352
        "00000000000000000000000000000010", -- arctan(2^-15) = 0.0000305176
        "00000000000000000000000000000001", -- arctan(2^-16) = 0.0000152588
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000", -- these values are zeros
        "00000000000000000000000000000000" -- these values are zeros
    );

    -- are the values over the 17ht even necessary (???)

begin

    addr_int <= to_integer(unsigend(addr));
    data <= arctg_array(addr_int);

end architecture;
