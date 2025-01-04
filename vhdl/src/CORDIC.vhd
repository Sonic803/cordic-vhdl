LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY CORDIC IS

    GENERIC (
        N : POSITIVE := 32;
        ITERATIONS : POSITIVE := 16;
        ITER_BITS : POSITIVE := 4
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

END ENTITY;

ARCHITECTURE behavioral OF CORDIC IS

    CONSTANT k : SIGNED(N - 1 DOWNTO 0) := to_signed(INTEGER(0.6072529351031394 * (2 ** (N - 1))), N); -- todo documentare meglio il N-1

    -- internal registers
    SIGNAL x_t : SIGNED(N - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL y_t : SIGNED(N - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL z_t : SIGNED(N - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL x_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL z_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL shift_reg : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL address : STD_LOGIC_VECTOR(ITER_BITS - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL atan_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL sign : STD_LOGIC;

    -- atan table
    COMPONENT ATAN_LUT IS
        PORT (
            address : IN STD_LOGIC_VECTOR(ITER_BITS - 1 DOWNTO 0);
            lut_out : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- state type and registers
    TYPE state_t IS (WAITING, FIX_STEP, COMPUTING, FINISHED);
    SIGNAL current_state : state_t := WAITING;

    SIGNAL counter : UNSIGNED(ITER_BITS - 1 DOWNTO 0) := (OTHERS => '0');

BEGIN
    ----------------------------------------------
    -- ISTANTIATE ALL COMPONENTS
    ----------------------------------------------

    -- output assignment
    rho <= x_out;
    theta <= z_out;

    -- sign bit
    sign <= '0' WHEN y_t > 0 ELSE
        '1';

    -- atan table
    -- todo probably needs fix (next clock)
    atan_lut_inst : ATAN_LUT
    PORT MAP(
        address => address,
        lut_out => atan_out
    );

    -- atan table address
    address <= STD_LOGIC_VECTOR(counter);

    -- todo decidere se tenere o togliere gli assegnamenti stupidi

    -- control part
    controllo : PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            current_state <= WAITING;

        ELSIF (rising_edge(clk)) THEN
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
    END PROCESS;

    -- operation part
    operativa : PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            valid <= '0';
        ELSIF (rising_edge(clk)) THEN
            CASE current_state IS
                WHEN WAITING =>

                    x_t <= signed(x);
                    y_t <= signed(y);
                    z_t <= to_signed(0, N);
                    valid <= '1';
                    x_out <= x_out;
                    z_out <= z_out;
                    counter <= (OTHERS => '0');

                WHEN FIX_STEP =>
                    if sign = '0' then
                        x_t <= y_t;
                        y_t <= -x_t;
                        z_t <= z_t + to_signed(INTEGER(1.570796327 * (2 ** (16))), N);
                        else
                        x_t <= -y_t;
                        y_t <= x_t;
                        z_t <= z_t - to_signed(INTEGER(1.570796327 * (2 ** (16))), N);
                        end if; 

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

                    counter <= counter + 1;
                    valid <= '0';
                WHEN FINISHED =>
                    x_out <= STD_LOGIC_VECTOR(resize(x_t * k/(2 ** (N - 1)), N));
                    -- x_out <= STD_LOGIC_VECTOR(x_t);
                    z_out <= STD_LOGIC_VECTOR(z_t);
                    valid <= '1';
            END CASE;
        END IF;

    END PROCESS;
END ARCHITECTURE;