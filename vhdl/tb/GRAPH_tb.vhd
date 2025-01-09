LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE std.textio.ALL;

ENTITY GRAPH_tb IS
  GENERIC (
    N : POSITIVE := 16;
    floating : INTEGER := 8 -- (Q8.8)
  );
END ENTITY;

ARCHITECTURE Behavioral OF GRAPH_tb IS

  -------------------------------------------------------------
  -- CORDIC component
  -------------------------------------------------------------
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

  -------------------------------------------------------------
  -- Signals
  -------------------------------------------------------------
  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL rst : STD_LOGIC := '0';
  SIGNAL x_in : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL y_in : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL start_in : STD_LOGIC := '0';
  SIGNAL rho_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
  SIGNAL theta_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
  SIGNAL valid_out : STD_LOGIC := '0';

  SIGNAL run_simulation : STD_LOGIC := '1';

  -------------------------------------------------------------
  -- Simulation parameters
  -------------------------------------------------------------
  
  CONSTANT T_clk : TIME := 20 ns; -- clock period = 20 ns
  CONSTANT SAMPLES : INTEGER := 512; -- samples per dimension

  -------------------------------------------------------------
  -- Output file
  -------------------------------------------------------------

  FILE results_file : text OPEN write_mode IS "cordic_results_512x512.txt";

  -------------------------------------------------------------
  -- Conversion function from std_logic_vector to real
  -------------------------------------------------------------

  FUNCTION to_real(val : unsigned(N - 1 DOWNTO 0); fraction_bits : INTEGER) RETURN real IS
  BEGIN
    RETURN real(to_integer(val)) / 2.0 ** fraction_bits;
  END FUNCTION;

  FUNCTION to_real(val : signed(N - 1 DOWNTO 0); fraction_bits : INTEGER) RETURN real IS
  BEGIN
    RETURN real(to_integer(val)) / 2.0 ** fraction_bits;
  END FUNCTION;

BEGIN

  -------------------------------------------------------------
  -- CORDIC declaration
  -------------------------------------------------------------
  UUT : CORDIC
  PORT MAP(
    clk => clk,
    rst => rst,
    x => x_in,
    y => y_in,
    start => start_in,
    rho => rho_out,
    theta => theta_out,
    valid => valid_out
  );

  ----------------------------------------------------------------------------
  -- CLK process
  ----------------------------------------------------------------------------
  clk_process : PROCESS
  BEGIN
    WHILE run_simulation = '1' LOOP
      clk <= '1';
      WAIT FOR T_clk/2;
      clk <= '0';
      WAIT FOR T_clk/2;
    END LOOP;
    WAIT; -- end process when run_simulation = '0'
  END PROCESS clk_process;

  ----------------------------------------------------------------------------
  -- Test process
  ----------------------------------------------------------------------------
  test_process : PROCESS
    VARIABLE L : line;
    VARIABLE real_x, real_y : real;
    VARIABLE mod_val, phase_val : real;
  BEGIN
    ----------------------------------------------------------------------------
    -- Power on reset
    ----------------------------------------------------------------------------
    rst <= '1';
    start_in <= '0';
    WAIT FOR 5 * T_clk;
    rst <= '0';
    WAIT FOR 5 * T_clk;

    ----------------------------------------------------------------------------
    -- Loop over (i, j) to test all values
    ----------------------------------------------------------------------------
    FOR i IN 0 TO SAMPLES - 1 LOOP
      FOR j IN 0 TO SAMPLES - 1 LOOP

        real_x := - 128.0 + eral(i) * 256.0 / real(SAMPLES);
        real_y := - 128.0 + real(j) * 256.0 / real(SAMPLES);

        -- Q8.8 Conversion (signed)
        x_in <= STD_LOGIC_VECTOR(to_signed(INTEGER(floor(real_x * 2.0 ** floating)), N));
        y_in <= STD_LOGIC_VECTOR(to_signed(INTEGER(floor(real_y * 2.0 ** floating)), N));

        start_in <= '1';
        WAIT FOR 2*T_clk;
        start_in <= '0';

        WAIT UNTIL valid_out = '1';
        WAIT FOR 10 ns;

        mod_val := to_real(unsigned(rho_out), 8); -- Q8.8
        phase_val := to_real(signed(theta_out), 13); -- Q3.13

        ---------------------------------------------------------------------
        -- Write on text file: x, y, rho, theta
        ---------------------------------------------------------------------
        -- Comma separated values
        write(L, real_x, RIGHT, 0, 6);
        write(L, STRING'(","));
        write(L, real_y, RIGHT, 0, 6);
        write(L, STRING'(","));
        write(L, mod_val, RIGHT, 0, 6);
        write(L, STRING'(","));
        write(L, phase_val, RIGHT, 0, 6);
        writeline(results_file, L);

        WAIT FOR 1 * T_clk;

      END LOOP;
    END LOOP;

    ----------------------------------------------------------------------------
    -- End simulation
    ----------------------------------------------------------------------------
    run_simulation <= '0';
    WAIT;
  END PROCESS test_process;

END Behavioral;