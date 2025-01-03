LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.fixed_pkg.ALL;
USE ieee.math_real.ALL;

ENTITY CORDIC_TB IS
    GENERIC (
        N : POSITIVE := 16;
        floating : INTEGER := 8
    );
END CORDIC_TB;

ARCHITECTURE Behavioral OF CORDIC_TB IS
    -- Component declaration for CORDIC

    COMPONENT CORDIC
        GENERIC (
            N : POSITIVE;
            FRAC : POSITIVE
        );
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            x : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            start : IN STD_LOGIC;
            rho : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            theta : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            valid : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Signals for CORDIC inputs and outputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';
    SIGNAL x : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL y : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL start : STD_LOGIC := '0';
    SIGNAL rho : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL theta : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL valid : STD_LOGIC := '0';
    SIGNAL run_simulation : STD_LOGIC := '1';
    SIGNAL d_clock_cycle : INTEGER := 0; -- Temporary signal for debugging
    SIGNAL floating_rho : REAL;
    SIGNAL floating_theta : REAL;
    -- Clock period definition
    CONSTANT T_clk : TIME := 10 ns;
BEGIN
    -- Instantiate the CORDIC component
    UUT : CORDIC
    GENERIC MAP(
        N => N,
        FRAC => floating
    )
    PORT MAP(
        clk => clk,
        rst => reset,
        x => x,
        y => y,
        start => start,
        rho => rho,
        theta => theta,
        valid => valid
    );

    clk <= (NOT(clk) AND run_simulation) AFTER T_clk / 2;
    floating_rho <= REAL(to_integer(signed(rho))) / 2.0 ** floating;
    floating_theta <= REAL(to_integer(signed(theta))) / 2.0 ** floating;
    -- Stimulus process
    STIMULI : PROCESS (clk) -- process used to make the testbench signals change synchronously with the rising edge of the clock
        VARIABLE clock_cycle : INTEGER := 0; -- variable used to count the clock cycle after the reset
    BEGIN
        IF (rising_edge(clk)) THEN
            CASE (clock_cycle) IS
                WHEN 1 =>
                    reset <= '1';
                    start <= '0';
                WHEN 100 =>
                    reset <= '0';
                    x <= STD_LOGIC_VECTOR(to_signed(10 * 2 ** floating, N));
                    y <= STD_LOGIC_VECTOR(to_signed(0 * 2 ** floating, N));
                    start <= '1';
                WHEN 101 =>
                    start <= '0';
                WHEN 200 =>
                    run_simulation <= '0';
                WHEN OTHERS => NULL; -- Specifying that nothing happens in the other cases

            END CASE; -- Test 1: Reset CORDIC
            -- Stop simulation
            -- WAIT;
            clock_cycle := clock_cycle + 1; -- the variable is updated exactly here (try to move this statement before the "case(t) is" one and watch the difference in the simulation)
            d_clock_cycle <= clock_cycle;

        END IF;
    END PROCESS;
END ARCHITECTURE;