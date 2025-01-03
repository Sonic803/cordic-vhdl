library ieee;
    use ieee.std_logic_1164.all;


entity DFF is

    generic (

        N : positive := 8

    );

    port (

        q : out std_logic_vector (N - 1 downto 0);
        d : in std_logic_vector (N - 1 downto 0);
        clk : in std_logic;
        reset : in std_logic

    );

end entity;


architecture structural of DFF is
    -- empty declarative part
begin

    main : process(clk,reset)
    begin

        if (reset = '1') then
            q <= '0';
        elsif rising_edge(clk) then
            q <= d;
        end if;

    end process;

end architecture;