LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY fntt_tb IS
END fntt_tb;

ARCHITECTURE behavior OF fntt_tb IS 
    
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT fntt
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         done : OUT  std_logic
        );
    END COMPONENT;
   
   -- Signals
   SIGNAL clk_tb : std_logic := '0';
   SIGNAL rst_tb : std_logic := '0';
   SIGNAL done_tb : std_logic;
   
   -- Clock period definition
   CONSTANT clk_period : time := 10 ns;
   
BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: fntt PORT MAP (
          clk => clk_tb,
          rst => rst_tb,
          done => done_tb
        );

    -- Clock process
    clk_process :process
    begin
       -- while now < 1000 ns loop  -- Run for a fixed time
            clk_tb <= '0';
            wait for clk_period/2;
            clk_tb <= '1';
            wait for clk_period/2;
        --end loop;
       -- wait;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin	    
        rst_tb <= '1';  -- Apply reset
        wait for 20 ns;
        rst_tb <= '0';  -- Deassert reset
        
        --wait for 100 ns;  -- Wait for some time
        
        -- Add any additional test cases here
        
        wait;
    end process;

END behavior;
