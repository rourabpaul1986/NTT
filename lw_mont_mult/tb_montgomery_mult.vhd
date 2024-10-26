library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_montgomery_mult is
end tb_montgomery_mult;

architecture Behavioral of tb_montgomery_mult is
    -- Generic parameter L for bit width
   constant L : integer := 16;  -- Set desired bit width for the testbench
   constant N : integer := 72639; 
   constant N_prime : integer := 1; 
    -- Signals for the testbench
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal start : std_logic := '0';
    signal A, B, R : std_logic_vector(L-1 downto 0);
    signal T : std_logic_vector(L-1 downto 0);

    -- Clock generation process
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the montgomery_mult module with L as a generic
    uut: entity work.montgomery_mult
        generic map (
            L => L,
            N => N,
            N_prime => N_prime
        )
        port map (
            clk => clk,
            reset => reset,
            start => start,
            A => A,
            B => B,
            --R => (others => '1'),  -- Set R to a large value, typically 1 << L
            T => T
        );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Test process
    stimulus : process
    begin
        -- Initialize inputs
        reset <= '1';
        start <= '0';
        wait for clk_period;

        reset <= '0';
        start <= '1';
        A <= conv_std_logic_vector(5792, L);     -- A = 5792
        B <= conv_std_logic_vector(1229, L);     -- B = 1229
        
        -- Allow time for calculations
        wait for 10 * clk_period;

        -- Check output T
       
        -- Stop simulation
        wait;
    end process;
end Behavioral;
