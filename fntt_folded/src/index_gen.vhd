library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use work.variant_pkg.all;
entity index_gen is
    generic (
        cc : integer := 4  -- Number of clock cycles per update
    );
    Port (
        clk   : in STD_LOGIC;
        reset : in STD_LOGIC;
        i     : out integer range 0 to logN-1;
        j     : out integer range 0 to N/2-1;
        k     : out integer range 0 to N/2-1;
        halflen     : out integer range 0 to N/2-1;
        wr_en : out STD_LOGIC;
        rd_en : out std_logic;   --enable port 0.
        ce : out std_logic;   --enable port 1.
        done  : out STD_LOGIC
    );
end index_gen;

architecture Behavioral of index_gen is
    signal si, si_d : integer range 0 to logN-1 := 0;  -- `si` increments every N/2 cycles
    signal sj, sj_d : integer range 0 to N-1 := 0;     -- `sj` iterates with special behavior
    signal sk : integer range 0 to N/2-1 := 0;   -- `sk` iterates from 0 to N/2 - 1 every N/2 cycles
    signal m, m_d : integer range 0 to N/2 := 0;   -- `sk` iterates from 0 to N/2 - 1 every N/2 cycles
    signal cycle_counter,cycle_counter_d : integer range 0 to N/2-1 := 0;  -- Tracks clock cycles for `si` and `sj`
    signal s_done, done_d : STD_LOGIC := '0';
    
    -- Internal signal to track stages for sj iteration behavior
    signal sj_stage : integer range 0 to 3 := 0;
     signal counter : integer := 0;
    signal clk_out : STD_LOGIC := '0';
    signal wr_t : STD_LOGIC := '1';
   
begin


    process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
            clk_out <= '0';
            wr_t <= '1';
        elsif rising_edge(clk) then
            if counter = cc - 1 then
                clk_out <= not clk_out; -- Toggle the clock
                counter <= 0;
                if done_d='0' then
                  wr_t <= not wr_t;
                end if;
                
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Process for handling `si` incrementing every N/2 clock cycles
    process(clk_out, reset)
    begin
        if reset = '1' then
            -- Reset all signals
            si <= 0;
            si_d <= 0;
            cycle_counter <= 0;
            cycle_counter_d <= 0;
            s_done <= '0';
            done_d <= '0';
             
        elsif rising_edge(clk_out) then
            done_d<=s_done;
            cycle_counter_d <=  cycle_counter; 
            si_d<=si;
            if cycle_counter = N/2 - 1 and s_done='0' then
                
                -- After N/2 clock cycles, increment `si`
                cycle_counter <= 0;               
                -- Increment `si` until it reaches N/4 - 1
                if si < logN - 1 then
                    si <= si + 1;
                    
                else
                    s_done <= '1';  -- Mark done when `si` reaches its max value
                end if;
            elsif s_done='1' then    
            else
                -- Increment cycle counter
                cycle_counter <= cycle_counter + 1;
               
            end if;
        end if;
    end process;

    -- Process for handling `sj` iteration behavior
    process(clk_out, reset)
    begin
        if reset = '1' then
            -- Reset `sj` and `sj_stage` when reset is active
            sj <= 0;
            sj_d <= 0;
            m <= N/2;
            m_d<=N/2;
        elsif rising_edge(clk_out) then
            sj_d<=sj;
            m_d<=m;
            if cycle_counter = N/2 - 1 then
               sj<=0;
               m<=m/2;
             elsif m/=0 and m/=1 and cycle_counter mod m=m-1 and cycle_counter/=0 then
                     sj<=sj+1;
              elsif m=1 then
                     sj<=sj+1;
                     

           
            end if;
        end if;
    end process;


    -- Assign outputs
    i <= si_d;
    j <= sj_d;
    k <= cycle_counter_d mod m_d when m_d/=0;
    done <= done_d;
    halflen<=m_d;
    wr_en<=wr_t;
    rd_en<=clk_out;
    ce<='1' when wr_t='0' and done_d='0' else  '0' when done_d='1' and wr_t='0';
end Behavioral;