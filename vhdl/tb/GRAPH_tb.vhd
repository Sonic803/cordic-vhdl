library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;  -- Per scrivere su file di testo

entity GRAPH_tb is
    generic (
        N : positive := 16;      -- larghezza del bus di ingresso e uscita
        floating : integer := 8  -- numero di bit frazionari (Q8.8)
    );
end entity;

architecture Behavioral of GRAPH_tb is

    ----------------------------------------------------------------------------
    -- Dichiarazione componente CORDIC
    ----------------------------------------------------------------------------
    component CORDIC
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            x     : in  std_logic_vector(N - 1 downto 0);
            y     : in  std_logic_vector(N - 1 downto 0);
            start : in  std_logic;
            rho   : out std_logic_vector(N - 1 downto 0);
            theta : out std_logic_vector(N - 1 downto 0);
            valid : out std_logic
        );
    end component;

    ----------------------------------------------------------------------------
    -- Segnali locali
    ----------------------------------------------------------------------------
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal x_in         : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal y_in         : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal start_in     : std_logic := '0';
    signal rho_out      : std_logic_vector(N - 1 downto 0);
    signal theta_out    : std_logic_vector(N - 1 downto 0);
    signal valid_out    : std_logic := '0';

    signal run_simulation : std_logic := '1';

    ----------------------------------------------------------------------------
    -- Parametri per la simulazione
    ----------------------------------------------------------------------------
    constant T_clk      : time := 10 ns;  -- periodo di clock = 10 ns
    constant SAMPLES    : integer := 512; -- numero di campioni in ogni dimensione

    ----------------------------------------------------------------------------
    -- File di output
    ----------------------------------------------------------------------------
    file results_file : text open write_mode is "cordic_results_512x512.txt";

    ----------------------------------------------------------------------------
    -- Funzione di conversione da std_logic_vector (signed) a real,
    -- tenendo conto del numero di bit frazionario.
    ----------------------------------------------------------------------------
    function to_real(val : signed(N-1 downto 0); fraction_bits : integer) return real is
    begin
        return real(to_integer(val)) / 2.0**fraction_bits;
    end function;

begin

    ----------------------------------------------------------------------------
    -- Istanza del CORDIC
    ----------------------------------------------------------------------------
    UUT : CORDIC
        port map(
            clk   => clk,
            rst   => rst,
            x     => x_in,
            y     => y_in,
            start => start_in,
            rho   => rho_out,
            theta => theta_out,
            valid => valid_out
        );

    ----------------------------------------------------------------------------
    -- Generazione del clock
    ----------------------------------------------------------------------------
    clk_process : process
    begin
        while run_simulation = '1' loop
            clk <= '1';
            wait for T_clk/2;
            clk <= '0';
            wait for T_clk/2;
        end loop;
        wait;  -- fermo il processo quando run_simulation = '0'
    end process clk_process;

    ----------------------------------------------------------------------------
    -- Processo di test
    ----------------------------------------------------------------------------
    test_process : process
    variable L : line;
    variable i, j : integer;
    variable real_x, real_y : real;
    variable mod_val, phase_val : real;
    begin
        ----------------------------------------------------------------------------
        -- Reset iniziale
        ----------------------------------------------------------------------------
        rst <= '1';
        start_in <= '0';
        wait for 5*T_clk;
        rst <= '0';
        wait for 5*T_clk;

        ----------------------------------------------------------------------------
        -- Loop su (i, j) per testare tutti i valori
        ----------------------------------------------------------------------------
        for i in 0 to SAMPLES-1 loop
            for j in 0 to SAMPLES-1 loop

                -- Calcolo dei valori reali corrispondenti
                real_x := -128.0 + real(i) * 256.0 / real(SAMPLES);
                real_y := -128.0 + real(j) * 256.0 / real(SAMPLES);

                -- Conversione in Q8.8 (signed)
                x_in <= std_logic_vector(to_signed(integer(floor(real_x * 2.0**floating)), N));
                y_in <= std_logic_vector(to_signed(integer(floor(real_y * 2.0**floating)), N));

                -- Avvio CORDIC
                start_in <= '1';
                wait for T_clk;
                start_in <= '0';

                -- Attendiamo che valid_out passi a '1'
                wait until valid_out = '1';
                wait for 10 ns;

                -- Acquisisco il risultato
                mod_val   := to_real(signed(rho_out), 8);     -- Q8.8
                phase_val := to_real(signed(theta_out), 13);  -- Q3.13

                ----------------------------------------------------------------------------
                -- Stampo sul file di testo: x, y, rho, theta
                ----------------------------------------------------------------------------
                -- Scrivi i valori separati da virgola
                write(L, real_x, RIGHT, 0, 6);
                write(L, string'(","));
                write(L, real_y, RIGHT, 0, 6);
                write(L, string'(","));
                write(L, mod_val, RIGHT, 0, 6);
                write(L, string'(","));
                write(L, phase_val, RIGHT, 0, 6);
                writeline(results_file, L);

                -- Piccola attesa fra un test e il successivo
                wait for 1*T_clk;

            end loop;
        end loop;

        ----------------------------------------------------------------------------
        -- Fine simulazione
        ----------------------------------------------------------------------------
        run_simulation <= '0';
        wait;
    end process test_process;

end Behavioral;
