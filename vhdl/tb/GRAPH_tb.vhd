LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE std.textio.ALL; -- Per scrivere su file di testo

ENTITY GRAPH_tb IS
  GENERIC (
    N : POSITIVE := 16; -- larghezza del bus di ingresso e uscita
    floating : INTEGER := 8 -- numero di bit frazionari (Q8.8)
  );
END ENTITY;

ARCHITECTURE Behavioral OF GRAPH_tb IS

  ----------------------------------------------------------------------------
  -- Dichiarazione componente CORDIC
  ----------------------------------------------------------------------------
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

  ----------------------------------------------------------------------------
  -- Segnali locali
  ----------------------------------------------------------------------------
  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL rst : STD_LOGIC := '0';
  SIGNAL x_in : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL y_in : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL start_in : STD_LOGIC := '0';
  SIGNAL rho_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
  SIGNAL theta_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
  SIGNAL valid_out : STD_LOGIC := '0';

  SIGNAL run_simulation : STD_LOGIC := '1';

  ----------------------------------------------------------------------------
  -- Parametri per la simulazione
  ----------------------------------------------------------------------------
  CONSTANT T_clk : TIME := 10 ns; -- periodo di clock = 10 ns
  CONSTANT SAMPLES : INTEGER := 512; -- numero di campioni in ogni dimensione

  ----------------------------------------------------------------------------
  -- File di output
  ----------------------------------------------------------------------------
  FILE results_file : text OPEN write_mode IS "cordic_results_512x512.txt";

  ----------------------------------------------------------------------------
  -- Funzione di conversione da std_logic_vector (signed) a real,
  -- tenendo conto del numero di bit frazionario.
  ----------------------------------------------------------------------------
  FUNCTION to_real(val : unsigned(N - 1 DOWNTO 0); fraction_bits : INTEGER) RETURN real IS
  BEGIN
    RETURN real(to_integer(val)) / 2.0 ** fraction_bits;
  END FUNCTION;

  FUNCTION to_real(val : signed(N - 1 DOWNTO 0); fraction_bits : INTEGER) RETURN real IS
  BEGIN
    RETURN real(to_integer(val)) / 2.0 ** fraction_bits;
  END FUNCTION;

BEGIN

  ----------------------------------------------------------------------------
  -- Istanza del CORDIC
  ----------------------------------------------------------------------------
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
  -- Generazione del clock
  ----------------------------------------------------------------------------
  clk_process : PROCESS
  BEGIN
    WHILE run_simulation = '1' LOOP
      clk <= '1';
      WAIT FOR T_clk/2;
      clk <= '0';
      WAIT FOR T_clk/2;
    END LOOP;
    WAIT; -- fermo il processo quando run_simulation = '0'
  END PROCESS clk_process;

  ----------------------------------------------------------------------------
  -- Processo di test
  ----------------------------------------------------------------------------
  test_process : PROCESS
    VARIABLE L : line;
    VARIABLE real_x, real_y : real;
    VARIABLE mod_val, phase_val : real;
  BEGIN
    ----------------------------------------------------------------------------
    -- Reset iniziale
    ----------------------------------------------------------------------------
    rst <= '1';
    start_in <= '0';
    WAIT FOR 5 * T_clk;
    rst <= '0';
    WAIT FOR 5 * T_clk;

    ----------------------------------------------------------------------------
    -- Loop su (i, j) per testare tutti i valori
    ----------------------------------------------------------------------------
    FOR i IN 0 TO SAMPLES - 1 LOOP
      FOR j IN 0 TO SAMPLES - 1 LOOP

        -- Calcolo dei valori reali corrispondenti
        real_x := - 128.0 + eral(i) * 256.0 / real(SAMPLES);
        real_y := - 128.0 + real(j) * 256.0 / real(SAMPLES);

        -- Conversione in Q8.8 (signed)
        x_in <= STD_LOGIC_VECTOR(to_signed(INTEGER(floor(real_x * 2.0 ** floating)), N));
        y_in <= STD_LOGIC_VECTOR(to_signed(INTEGER(floor(real_y * 2.0 ** floating)), N));

        -- Avvio CORDIC
        start_in <= '1';
        WAIT FOR T_clk;
        start_in <= '0';

        -- Attendiamo che valid_out passi a '1'
        WAIT UNTIL valid_out = '1';
        WAIT FOR 10 ns;

        -- Acquisisco il risultato
        mod_val := to_real(unsigned(rho_out), 8); -- Q8.8
        phase_val := to_real(signed(theta_out), 13); -- Q3.13

        ----------------------------------------------------------------------------
        -- Stampo sul file di testo: x, y, rho, theta
        ----------------------------------------------------------------------------
        -- Scrivi i valori separati da virgola
        write(L, real_x, RIGHT, 0, 6);
        write(L, STRING'(","));
        write(L, real_y, RIGHT, 0, 6);
        write(L, STRING'(","));
        write(L, mod_val, RIGHT, 0, 6);
        write(L, STRING'(","));
        write(L, phase_val, RIGHT, 0, 6);
        writeline(results_file, L);

        -- Piccola attesa fra un test e il successivo
        WAIT FOR 1 * T_clk;

      END LOOP;
    END LOOP;

    ----------------------------------------------------------------------------
    -- Fine simulazione
    ----------------------------------------------------------------------------
    run_simulation <= '0';
    WAIT;
  END PROCESS test_process;

END Behavioral;