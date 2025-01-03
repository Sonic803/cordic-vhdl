library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;


entity CORDIC is

    generic (
        N : positive := 32
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        x : in std_logic_vector(N - 1 downto 0);
        y : in std_logic_vector(N - 1 downto 0);
        start : in std_logic;
        rho : out std_logic_vector(N - 1 downto 0);
        theta : out std_logic_vector(N - 1 downto 0);
        valid : out std_logic
    );

end entity;



architecture behavioral of CORDIC is

    -- internal counter
    signal counter_rst : std_logic := '1';
    signal counter_out : std_logic_vector(4 downto 0) := (others => '0');
    signal counter_in : std_logic_vector(4 downto 0) := (others => '0');
    component counter is
        generic (
            N : positive := 5
        );

        port (
            clk : in std_logic;
            reset : in std_logic;
            dout : out std_logic_vector(N - 1 downto 0);
            din : in std_logic_vector(N - 1 downto 0)
        );
    end component;


    -- internal registers
    signal x_in : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal x_out : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal y_in : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal y_out : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal z_in : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal z_out : std_logic_vector(N - 1 downto 0) := (others => '0');
    component DFF is
        generic (
            N : positive := 8
        );
        port (
            q : out std_logic_vector(N - 1 downto 0);
            d : in std_logic_vector (N - 1 downto 0);
            clk : in std_logic;
            reset : in std_logic
        );
    end component;

    -- internal lut arctg
    signal lut_addr : std_logic_vector(4 downto 0) := (others => '0');
    signal lut_data : std_logic_vector(N - 1 downto 0);
    component LUT_arctg is
        port (
            addr            : in    std_logic_vector(4 downto 0);
            data            : out   std_logic_vector(31 downto 0)
        );
    end component;

    -- ripple carry adder
    signal x_out_adder : std_logic_vector(N - 1 downto 0);
    signal y_out_adder : std_logic_vector(N - 1 downto 0);
    signal z_out_adder : std_logic_vector(N - 1 downto 0);

    component rippleCarryAdder is
        generic (
            N : positive := 32
        );
        port (
            a : in std_logic_vector(N - 1 downto 0);
            b : in std_logic_vector(N - 1 downto 0);
            s : out std_logic_vector(N - 1 downto 0);
            cin : in std_logic;
            cout : out std_logic
        );
    end component;



    signal z_opposite : std_logic_vector(N - 1 downto 0);
    signal x_opposite : std_logic_vector(N - 1 downto 0);
    signal y_opposite : std_logic_vector(N - 1 downto 0);
    component opposite is
        generic (
            N : positive := 32
        );
        port (
            din : in std_logic_vector(N - 1 downto 0);
            dout : out std_logic_vector(N - 1 downto 0)
        );
    end component;

    -- temp signals
    signal x_temp : std_logic_vector(N - 1 downto 0);
    signal y_temp : std_logic_vector(N - 1 downto 0);
    signal z_temp : std_logic_vector(N - 1 downto 0);

    signal sign : std_logic;

    -- state type and registers
    type state_t is (WAITING,COMPUTING,FINISHED);
    signal current_state, next_state : state_t;

begin
----------------------------------------------
-- ISTANTIATE ALL COMPONENTS
----------------------------------------------
    -- istantiate x, y and z registers 
    x_reg : DFF
        generic map (
            N => N
        )
        port map (
            q => x_out,
            d => x_in,
            clk => clk,
            reset => rst
        );

    y_reg : DFF
        generic map (
            N => N
        )
        port map (
            q => y_out,
            d => y_in,
            clk => clk,
            reset => rst
        );

    z_reg : DFF
        generic map (
            N => N
        )
        port map (
            q => z_out,
            d => z_in,
            clk => clk,
            reset => rst
        );
    
    
    -- instantiate counter
    count : counter
        generic map (
            N => 5
        )
        port map (
            clk => clk,
            reset => rst,
            din => counter_in,
            dout => counter_out
        );

    -- istantiate LUT
    LUT : LUT_arctg
        port map (
            addr => counter_out,
            data => lut_data
        );

    -- istantiate opposite
    x_opp : opposite
        generic map (
            N => N
        )
        port map (
            din => x_out,
            dout => x_opposite
        );

    y_opp : opposite
        generic map (
            N => N
        )
        port map (
            din => y_out,
            dout => y_opposite
        );

    z_opp : opposite
        generic map (
            N => N
        )
        port map (
            din => lut_data,
            dout => z_opposite
        );

    -- sign process
    sign <= y_out(31);

    -- temporary signal processes (x_temp, y_temp, z_temp)
    y_temp_proc : process(x_out, x_opposite, y_out, y_opposite, lut_data, z_opposite, sign)
    begin
        -- If y is < 0
        if sign = '1' then
            x_temp <= std_logic_vector(shift_right(signed(x_out), to_integer(unsigned(counter_out))));
            y_temp <= std_logic_vector(shift_right(signed(y_opposite), to_integer(unsigned(counter_out))));
            z_temp <= z_opposite;
        else
            x_temp <= std_logic_vector(shift_right(signed(x_opposite), to_integer(unsigned(counter_out))));
            y_temp <= std_logic_vector(shift_right(signed(y_out), to_integer(unsigned(counter_out))));
            z_temp <= lut_data;
        end if;
    end process;

    -- istantiate adders
    x_adder : rippleCarryAdder
        generic map (
            N => N
        )
        port map (
            a => x_out,
            b => y_temp,
            s => x_out_adder,
            cin => '0'
        );
    
    y_adder : rippleCarryAdder
        generic map (
            N => N
        )
        port map (
            a => y_out,
            b => x_temp,
            s => y_out_adder,
            cin => '0'
        );

    z_adder : rippleCarryAdder
        generic map (
            N => N
        )
        port map (
            a => z_out,
            b => z_temp,
            s => z_out_adder,
            cin => '0'
        );

    -- sample input process
    sample_proc : process(start,x,y,x_out_adder,y_out_adder,z_out_adder,current_state)
    begin
        
        if rising_edge(start) and current_state = WAITING then
            x_in <= x;
            y_in <= y;
            z_in <= (others => '0');
        else
            x_in <= x_out_adder;
            y_in <= y_out_adder;
            z_in <= z_out_adder;
        end if;

    end process;


    -- FSM PROCESSES
    
    -- update state process
    state_proc: process(clk,rst)
    begin
        if (rst = '1') then
            -- reset state
            current_state <= WAITING;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- state transition process
    tran_proc : process(current_state,x,y,start)
    begin

        -- default update to avoid latches
        current_state <= next_state;

        case current_state is

            when WAITING =>

                -- if start then start counting
                if (start = '1') then

                    -- start the counter
                    

                end if;

            when COMPUTING =>

                -- if n == n - 1 then go to finished

            when FINISHED =>

                -- reset counter


            when others =>
                next_state <= WAITING;

        end case;

    end process;

    
end architecture;