library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL; -- For text I/O
use work.variant_pkg.all;
use STD.TEXTIO.ALL;            -- For file I/O

entity index_gen_tb is
    generic (
        cc : integer := 4  -- Number of clock cycles per update
    );
end index_gen_tb;

architecture Behavioral of index_gen_tb is
    -- Component declaration
    component index_gen
        generic (
        cc : integer := 1  -- Number of clock cycles per update
    );
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            i : out integer range 0 to logN-1;
            j : out integer range 0 to N/2;
            k : out integer range 0 to N/2;
            halflen     : out integer range 0 to N/2-1;
            wr_en : out STD_LOGIC;
            rd_en : out std_logic;   --enable port 0.
            ce : out std_logic;   --enable port 1.
            done : out STD_LOGIC
        );
    end component;

    -- Signals for testbench
    signal clk_tb : STD_LOGIC := '0';
    signal reset_tb : STD_LOGIC := '0';
    signal i_tb : integer range 0 to logN+1;
    signal j_tb : integer range 0 to N/2;
    signal k_tb : integer range 0 to N/2;
    signal halflen : integer range 0 to N/2;
    signal done_tb : STD_LOGIC;
    signal wr_en : STD_LOGIC;
     signal rd_en : STD_LOGIC;
      signal ce : STD_LOGIC;

    -- Clock generation
    constant clk_period : time := 10 ns;

    -- File for output
    file sim_output : text open write_mode is "simulation_output.txt";

begin
    -- DUT instantiation
    DUT: index_gen
       generic map (
        cc => cc  -- Change this as needed
    )
        port map (
            clk => clk_tb,
            reset => reset_tb,
            i => i_tb,
            j => j_tb,
            k => k_tb,
            halflen=>halflen,
            wr_en=>wr_en,
            rd_en=>rd_en,
            ce=>ce,
            done => done_tb
        );

    -- Clock process
    clk_process: process
    begin
        while True loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus_process: process
        variable line_text : line; -- Variable to store formatted output
    begin
        -- Reset the DUT
        reset_tb <= '1';
        wait for clk_period;
        reset_tb <= '0';
        wait for clk_period;
        

        -- Run the simulation and write values to the file
        for sim_time in 0 to 100 loop
            
            write(line_text, string'("Time: "));
            write(line_text, now); -- Append current simulation time
            write(line_text, string'(" | i: "));
            write(line_text, i_tb); -- Append signal `i`
            write(line_text, string'(", j: "));
            write(line_text, j_tb); -- Append signal `j`
            write(line_text, string'(", k: "));
            write(line_text, k_tb); -- Append signal `k`
            write(line_text, string'(", done: "));
            write(line_text, done_tb); -- Append signal `done`
            writeline(sim_output, line_text); -- Write to file
            wait for clk_period;

        end loop;

        -- Close the file after simulation
        file_close(sim_output);

        -- Stop the simulation
        wait;
    end process;

end Behavioral;