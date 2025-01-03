library ieee;
    use ieee.std_logic_1164.all;


entity fullAdder is

    port (
        a : in std_logic;
        b : in std_logic;
        cin : in std_logic;
        cout : out std_logic;
        s : out std_logic
    );

end entity;


architecture dataflow of fullAdder is
begin

    -- asynchronous
    s <= a xor b xor cin;
    cout <= (a and cin) or (b and cin) or (a and b);

end architecture;