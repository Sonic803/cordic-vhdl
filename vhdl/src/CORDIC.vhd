LIBRARY ieee;
    USE ieee.std_logic_1164.ALL;
    USE ieee.numeric_std.ALL;
ENTITY CORDIC IS

    GENERIC (
        M           : POSITIVE := 24; -- internal representation
        N           : POSITIVE := 16; -- input size
        ITERATIONS  : POSITIVE := 16; -- CORDIC algorithm iterations
        ITER_BITS   : POSITIVE := 4   -- number of bits needed to represent iterations
    );
    PORT (
        clk     : IN STD_LOGIC;
        rst     : IN STD_LOGIC;
        x       : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        y       : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        start   : IN STD_LOGIC;
        rho     : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        theta   : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        valid   : OUT STD_LOGIC
    );

END ENTITY;

ARCHITECTURE behavioral OF CORDIC IS

    -- CONSTANT k : SIGNED(N - 1 DOWNTO 0) := to_signed(1304065748, N); -- 1/(Gain factor) multiplied by 2^N-1
    CONSTANT k          :    SIGNED(M - 1 DOWNTO 0) := to_signed(INTEGER(0.6072528458 * (2 ** (M - 1))), M); -- todo se in futuro vivado si lamenta usare M-2 
    CONSTANT HALF_PI    : SIGNED(M - 1 DOWNTO 0) := to_signed(INTEGER(1.570796327 * (2 ** (M - 3))), M); -- todo documentare meglio il N-3  

    -- internal registers
    SIGNAL x_t : SIGNED(M - 1 DOWNTO 0);
    SIGNAL y_t : SIGNED(M - 1 DOWNTO 0);
    SIGNAL z_t : SIGNED(M - 1 DOWNTO 0);

    -- output registers
    SIGNAL x_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL z_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

    -- atan table address and output
    SIGNAL address : STD_LOGIC_VECTOR(ITER_BITS - 1 DOWNTO 0);
    SIGNAL atan_out : STD_LOGIC_VECTOR(M - 1 DOWNTO 0);

    SIGNAL sign : STD_LOGIC;

    -- atan table
    COMPONENT ATAN_LUT IS
        PORT (
            address : IN STD_LOGIC_VECTOR(ITER_BITS - 1 DOWNTO 0);
            lut_out : OUT STD_LOGIC_VECTOR(M - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- state type and registers
    TYPE state_t IS (WAITING, FIX_STEP, COMPUTING, FINISHED);
    SIGNAL current_state : state_t;

    -- counter for iterations
    SIGNAL counter : UNSIGNED(ITER_BITS - 1 DOWNTO 0);

BEGIN
    ----------------------------------------------
    -- ISTANTIATE ALL COMPONENTS
    ----------------------------------------------

    -- output assignment
    rho <= x_out;
    theta <= z_out;

    -- todo trovare nome migliore tipo d
    -- sign bit
    sign <= y_t(M - 1);
    -- sign <= '0' WHEN y_t > 0 ELSE '1';

    -- atan table
    atan_lut_inst : ATAN_LUT
    PORT MAP(
        address => address,
        lut_out => atan_out
    );

    -- atan table address
    address <= STD_LOGIC_VECTOR(counter);

    -- todo decidere se tenere o togliere gli assegnamenti stupidi
    -- todo forse z dovrebbe avere solo 2 bit interi e il resto frazionari
    -- aggiustare meglio spiegazione e codice per i 29 bit di atan

    ----------------------------------------------
    -- CONTROL PART
    ----------------------------------------------

    control : PROCESS (clk, rst)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF rst = '1' THEN
                current_state <= WAITING;
            ELSE

                CASE current_state IS
                    WHEN WAITING =>
                        IF start = '1' THEN
                            current_state <= FIX_STEP;
                        ELSE
                            current_state <= WAITING;
                        END IF;

                    WHEN FIX_STEP =>
                        current_state <= COMPUTING;

                    WHEN COMPUTING =>
                        IF counter = ITERATIONS - 1 THEN
                            current_state <= FINISHED;
                        ELSE
                            current_state <= COMPUTING;
                        END IF;

                    WHEN FINISHED =>
                        current_state <= WAITING;

                    WHEN OTHERS =>
                        current_state <= WAITING;

                END CASE;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------
    -- OPEATIONAL PART
    ----------------------------------------------

    OPEATIONAL : PROCESS (clk, rst)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF rst = '1' THEN
                valid   <= '0';
                x_out   <= (OTHERS => '0');
                z_out   <= (OTHERS => '0');
                counter <= (OTHERS => '0');
                x_t     <= (OTHERS => '0');
                y_t     <= (OTHERS => '0');
                z_t     <= (OTHERS => '0');
            ELSE
            
                -- Default assignment
                -- todo vedere se tenere o togliere
                -- x_t <= (OTHERS => '-');
                -- y_t <= (OTHERS => '-');
                -- z_t <= (OTHERS => '-');
                -- x_out <= (OTHERS => '-');
                -- z_out <= (OTHERS => '-');
                counter <= (OTHERS => '0');

                CASE current_state IS
                    WHEN WAITING =>
                        x_t <= shift_left(resize(signed(x), M), M - N);
                        y_t <= shift_left(resize(signed(y), M), M - N);
                        z_t <= to_signed(0, M);
                        valid <= '1';
                        x_out <= x_out;
                        z_out <= z_out;

                    WHEN FIX_STEP =>
                        IF sign = '1' THEN
                            x_t <= - y_t;
                            y_t <= x_t;
                            z_t <= z_t - HALF_PI;
                        ELSE
                            x_t <= y_t;
                            y_t <= - x_t;
                            z_t <= z_t + HALF_PI;
                        END IF;

                        valid <= '0';
                        counter <= (OTHERS => '0');

                    WHEN COMPUTING =>
                        IF sign = '1' THEN
                            -- x_t <= x_t - y_t/(2 ** to_integer(counter));
                            x_t <= x_t - shift_right(y_t, to_integer(counter));
                            -- y_t <= y_t + x_t/(2 ** to_integer(counter));
                            y_t <= y_t + shift_right(x_t, to_integer(counter));
                            z_t <= z_t - signed(atan_out);
                        ELSE
                            -- x_t <= x_t + y_t/(2 ** to_integer(counter));
                            x_t <= x_t + shift_right(y_t, to_integer(counter));
                            -- y_t <= y_t - x_t/(2 ** to_integer(counter));
                            y_t <= y_t - shift_right(x_t, to_integer(counter));
                            z_t <= z_t + signed(atan_out);
                        END IF;
                        
                        if counter < ITERATIONS - 1 then
                            counter <= counter + 1;
                        else
                            counter <= (OTHERS => '0');
                        end if;

                        valid <= '0';

                    WHEN FINISHED =>
                        x_out <= STD_LOGIC_VECTOR(resize(x_t * k / (2 ** (M - 1)), M)(M - 1 DOWNTO M - N));
                        z_out <= STD_LOGIC_VECTOR(z_t(M - 1 DOWNTO M - N));

                        valid <= '1';
                        
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;