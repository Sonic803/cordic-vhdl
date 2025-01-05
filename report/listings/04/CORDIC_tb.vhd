LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.math_real.ALL;

ENTITY CORDIC_TB IS
    GENERIC (
        N : POSITIVE := 20;
        floating : INTEGER := 10
    );
END CORDIC_TB;

ARCHITECTURE Behavioral OF CORDIC_TB IS
    -- Component declaration for CORDIC

    COMPONENT CORDIC
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

    -- Clock period definition
    CONSTANT T_clk : TIME := 10 ns;

    -- Coordinate type
    TYPE Coordinate IS RECORD
        x : real;
        y : real;
    END RECORD;
    CONSTANT n_coordinates : NATURAL := 6;

    TYPE CoordinateArray IS ARRAY (0 TO n_coordinates - 1) OF Coordinate;

    -- Array of coordinates to test
    CONSTANT Coordinates : CoordinateArray := (

        (1.0, 0.0),
        (10.0, 10.0),
        (0.1, 3.0),
        (-0.1, -4.0),
        (-1.0, 1.0),
        (-1.0, 0.0)

    );
BEGIN
    -- Instantiate the CORDIC component
    cordic_inst : CORDIC
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

    -- todo fix behavior if cordic is not ready / does not work

    clk <= (NOT(clk) AND run_simulation) AFTER T_clk / 2;
    -- Stimulus process
    STIMULI : PROCESS
        VARIABLE i : INTEGER := 0;
    BEGIN
        reset <= '1';
        start <= '0';
        WAIT FOR 2 * T_clk;

        reset <= '0';

        FOR i IN 0 TO n_coordinates - 1 LOOP

            IF valid = '0' THEN
                WAIT UNTIL valid = '1';
            END IF;

            x <= STD_LOGIC_VECTOR(to_signed(INTEGER(Coordinates(i).x * 2.0 ** floating), N));
            y <= STD_LOGIC_VECTOR(to_signed(INTEGER(Coordinates(i).y * 2.0 ** floating), N));
            start <= '1';

            WAIT FOR 5 * T_clk;

            start <= '0';

            IF valid = '0' THEN
                WAIT UNTIL valid = '1';
            END IF;

            wait for 10 * T_clk;

        END LOOP;


        run_simulation <= '0';

        WAIT;
    END PROCESS;
END ARCHITECTURE;