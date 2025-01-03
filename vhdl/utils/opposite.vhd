library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;


entity opposite is

    generic (
        N : positive := 32
    );
    port (
        din : in std_logic_vector(N - 1 downto 0);
        dout : out std_logic_vector(N - 1 downto 0)
    );

end entity;


architecture dataflow of opposite is

    component rippleCarryAdder is

        -- parametric rippleCarryAdder
        generic (
            N : positive := 8
        );

        port (

            a : in std_logic_vector(N - 1 downto 0);
            b : in std_logic_vector(N - 1 downto 0);
            s : out std_logic_vector(N - 1 downto 0);
            cin : in std_logic;
            cout : out std_logic

        );

    end component;

    signal not_din : std_logic_vector(N - 1 downto 0) := (others => '0');

begin

    not_din <= not din;

    -- initialize adder
    adder : rippleCarryAdder
    generic map (
        N => N
    )
    port map (
        a => (others => '0'),
        b => not_din,
        cin => '0',
        s => dout
        -- do not need to track carry out
    );


end architecture;