LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.NUMERIC_STD.ALL;
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
    CONSTANT n_coordinates : NATURAL := 9;

    TYPE CoordinateArray IS ARRAY (0 TO n_coordinates - 1) OF Coordinate;

    -- Array of coordinates to test
    CONSTANT Coordinates : CoordinateArray := (

        (1.0, 1.0),
        (10.0, 10.0),
        (0.0, 1.0),
        (-0.1, -4.0),
        (-1.0, 1.0),
        (-1.0, 0.0),
        (-1.0, 0.1),
        (31.0, 31.0),
        (127.0, 127.0)


    );

    -- function to print values in report
    function u_to_real(val : unsigned(N-1 downto 0); fraction_bits : integer) return real is
    begin
        return  real(to_integer(val)) / 2.0**fraction_bits;
    end function;
    
    -- function to print values in report
    function s_to_real(val : signed(N-1 downto 0); fraction_bits : integer) return real is
        begin
            return  real(to_integer(val)) / 2.0**fraction_bits;
        end function;
    

    
    procedure echo(arg : in string := "") is
        begin
            std.textio.write(std.textio.output, arg & LF); -- LF ensures a newline after each message
    end procedure echo;
    

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
    
    -- test process
    test : PROCESS
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
            
            WAIT FOR 1 * T_clk;
            -- Osservazione del valore del modulo e della fase
            echo("");
            echo("Test " & integer'image(i) & " X: " & real'image(Coordinates(i).x) & " Y: " & real'image(Coordinates(i).y));
            echo("----------------------------------------");
            echo("Module (Q8.8) = " & real'image(u_to_real(unsigned(rho), 8)));
            echo("Phase  (Q3.13) = " & real'image(s_to_real(signed(theta), 13)));
            echo("----------------------------------------");

            wait for 10 * T_clk;

        END LOOP;

        run_simulation <= '0';
        WAIT;
    END PROCESS;
END ARCHITECTURE;