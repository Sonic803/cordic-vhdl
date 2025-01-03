LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY CORDIC IS

    GENERIC (
        N : POSITIVE := 16;
        FRAC : POSITIVE := 8;
        ITERATIONS : POSITIVE := 10
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

    CONSTANT k : SIGNED(N - 1 DOWNTO 0) := to_signed(integer(0.6072533210898752 * (2 ** FRAC)), N);

    -- internal registers
    SIGNAL x_t : SIGNED(N - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL y_t : SIGNED(N - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL z_t : SIGNED(N - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL x_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL y_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL z_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL address : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL atan_out : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL sign : STD_LOGIC;

    -- atan table
    COMPONENT ATAN_LUT IS
        PORT (
            address : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            lut_out : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- state type and registers
    TYPE state_t IS (WAITING, COMPUTING, FINISHED);
    SIGNAL current_state : state_t := WAITING;

    SIGNAL counter : UNSIGNED(3 DOWNTO 0) := (OTHERS => '0');

BEGIN
    ----------------------------------------------
    -- ISTANTIATE ALL COMPONENTS
    ----------------------------------------------

    rho <= x_out;
    theta <= z_out;
    -- sign = -1 if y(n-1) = 1 else 1
    sign <= '0' WHEN y_t > 0 ELSE
        '1';

    -- atan table
    atan_lut_inst : ATAN_LUT
    PORT MAP(
        address => address,
        lut_out => atan_out
    );

    address <= STD_LOGIC_VECTOR(counter);

    -- state transition process
    tran_proc : PROCESS (clk, rst)
    BEGIN

        -- default update to avoid latches
        CASE current_state IS

            WHEN WAITING =>

                -- if start then start counting
                IF (start = '1') THEN
                    -- start the counter
                    current_state <= COMPUTING;
                    x_t <= signed(x);
                    y_t <= signed(y);
                    z_t <= to_signed(0, N);
                    valid <= '0';
                END IF;

            WHEN COMPUTING =>
                IF sign = '1' THEN
                    x_t <= x_t - y_t/(2 ** to_integer(counter));
                    y_t <= y_t + x_t/(2 ** to_integer(counter));
                    z_t <= z_t - signed(atan_out);
                ELSE
                    x_t <= x_t + y_t/(2 ** to_integer(counter));
                    y_t <= y_t - x_t/(2 ** to_integer(counter));
                    z_t <= z_t + signed(atan_out);
                END IF;

                counter <= counter + 1;
                IF counter = ITERATIONS - 1 THEN
                    current_state <= FINISHED;
                END IF;

            WHEN FINISHED =>
                -- reset STD_LOGIC_VECTORcounter
                counter <= (OTHERS => '0');
                current_state <= WAITING;
                x_out <= STD_LOGIC_VECTOR(resize(x_t*k/2**FRAC,N));
                -- x_out <= STD_LOGIC_VECTOR(x_t);
                z_out <= STD_LOGIC_VECTOR(z_t);
                valid <= '1';
            WHEN OTHERS =>
                current_state <= WAITING;

        END CASE;

    END PROCESS;
END ARCHITECTURE;