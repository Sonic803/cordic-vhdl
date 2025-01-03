library ieee;
    use ieee.std_logic_1164.all;

entity rippleCarryAdder is

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

end entity;

architecture structural of rippleCarryAdder is

    component fullAdder is
        
        port (
            a : in std_logic;
            b : in std_logic;
            cin : in std_logic;
            cout : out std_logic;
            s : out std_logic
        );

    end component;

    signal wire : std_logic_vector(N - 2 downto 0);

begin

    generate_fullAdder : for i in 0 to N - 1 generate
        generate_first : if (i = 0) generate

            i_fullAdder : fullAdder port map (
                a => a(i),
                b => b(i),
                s => s(i),
                cin => cin,
                cout => wire(i)
            );

        end generate;

        generate_internal : if (i > 0) and (i < N - 1) generate

            i_fullAdder : fullAdder port map (
                a => a(i),
                b => b(i),
                s => s(i),
                cin => wire(i - 1),
                cout => wire(i)
            );

        end generate;


        generate_last : if (i = N - 1) generate

            i_fullAdder : fullAdder port map (
                a => a(i),
                b => b(i),
                s => s(i),
                cin => wire(i - 1),
                cout => cout
            );

        end generate;
    
    end generate;

end architecture;