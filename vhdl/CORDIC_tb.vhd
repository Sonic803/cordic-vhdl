library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CORDIC_TB is
end CORDIC_TB;

architecture Behavioral of CORDIC_TB is
    -- Component declaration for CORDIC
    component CORDIC
        Port (
            clk     : in  std_logic;
            reset   : in  std_logic;
            x_in    : in  signed(31 downto 0);
            y_in    : in  signed(31 downto 0);
            z_in    : in  signed(31 downto 0);
            x_out   : out signed(31 downto 0);
            y_out   : out signed(31 downto 0);
            z_out   : out signed(31 downto 0)
        );
    end component;

    -- Signals for CORDIC inputs and outputs
    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';
    signal x_in    : signed(31 downto 0) := (others => '0');
    signal y_in    : signed(31 downto 0) := (others => '0');
    signal z_in    : signed(31 downto 0) := (others => '0');
    signal x_out   : signed(31 downto 0);
    signal y_out   : signed(31 downto 0);
    signal z_out   : signed(31 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;
begin
    -- Instantiate the CORDIC component
    UUT: CORDIC
        Port map (
            clk     => clk,
            reset   => reset,
            x_in    => x_in,
            y_in    => y_in,
            z_in    => z_in,
            x_out   => x_out,
            y_out   => y_out,
            z_out   => z_out
        );

    -- Clock process
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus: process
    begin
        -- Test 1: Reset CORDIC
        reset <= '1';
        wait for clk_period * 2;
        reset <= '0';

        -- Test 2: Input a simple vector and angle
        x_in <= to_signed(1073741824, 32); -- 0.5 in Q1.31
        y_in <= to_signed(1073741824, 32); -- 0.5 in Q1.31
        z_in <= to_signed(0, 32);          -- 0 rad
        wait for clk_period * 50;

        -- Test 3: Rotate by 45 degrees
        reset <= '1';
        wait for clk_period * 2;
        reset <= '0';
        x_in <= to_signed(1073741824, 32); -- 0.5 in Q1.31
        y_in <= to_signed(1073741824, 32); -- 0.5 in Q1.31
        z_in <= to_signed(536870912, 32);  -- pi/4 (45 degrees) in Q1.31
        wait for clk_period * 50;

        -- Test 4: Rotate by -45 degrees
        reset <= '1';
        wait for clk_period * 2;
        reset <= '0';
        x_in <= to_signed(1073741824, 32); -- 0.5 in Q1.31
        y_in <= to_signed(-1073741824, 32); -- -0.5 in Q1.31
        z_in <= to_signed(-536870912, 32); -- -pi/4 (-45 degrees) in Q1.31
        wait for clk_period * 50;

        -- Stop simulation
        wait;
    end process;
end architecture;
