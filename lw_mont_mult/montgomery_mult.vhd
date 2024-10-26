library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity montgomery_mult is
    generic (
        L : integer := 16;        -- Length of the operands
        w : integer := 4;         -- Width of the segments
        N : integer := 72639;    -- The modulus
        N_prime : integer := 1     -- Precomputed value
    );
    Port (
        clk : in std_logic;                   -- Clock input
        reset : in std_logic;                 -- Reset input
        start : in std_logic;                 -- Start signal for multiplication
        A : in std_logic_vector(L-1 downto 0);-- Operand A
        B : in std_logic_vector(L-1 downto 0);-- Operand B
        --R : in std_logic_vector(L-1 downto 0);-- R value
        T : out std_logic_vector(L-1 downto 0) -- Output T
    );
end montgomery_mult;

architecture Behavioral of montgomery_mult is
    -- State definitions
    type state_type is (IDLE, COMPUTE_U, COMPUTE_T, SHIFT, FINALIZE);
    signal state : state_type;

    -- Constants
    constant m : integer := L / w;
    constant bx : integer := 2**w;

    -- Internal signals
    signal T_reg, A_reg : std_logic_vector(L-1 downto 0) := (others => '0');
    
    signal u : std_logic_vector(w-1 downto 0);
    signal Aw, B0, T0 : std_logic_vector(w-1 downto 0);
    signal zero_pad : std_logic_vector(w-1 downto 0):=(others => '0');
    signal counter : integer := 0;  -- To keep track of the loop index
    signal T_regt : std_logic_vector(3*L-1 downto 0) := (others => '0');

begin

    -- Next state logic
    process(state, start, clk, reset)
    
    begin
    
         if reset = '1' then
            state <= IDLE;
            T_reg <= (others => '0');
            T_regt <= (others => '0');
            A_reg <= (others => '0');
            counter <= 0;
            
        elsif rising_edge(clk) then
        case state is
            when IDLE =>
                if start = '1' then
                    state <= COMPUTE_U;
                    A_reg <= A;
                    --T_reg <= (others => '0');  -- Reset T
                    --counter <= 0;               -- Reset counter
                else
                    state <= IDLE;
                end if;

            when COMPUTE_U =>
                
                    T0 <= T_reg(w-1 downto 0);
                    B0 <= B(w-1 downto 0);
                    Aw <= A_reg(w-1 downto 0);
                    -- Calculate u
                    u <= std_logic_vector(to_unsigned((to_integer(unsigned(T_reg(w-1 downto 0))) + (to_integer(unsigned(A_reg(w-1 downto 0))) * to_integer(unsigned(B(w-1 downto 0))))) * N_prime, u'length));
                    state <= COMPUTE_T;
                     
                    -- Update T_reg
             when COMPUTE_T=>  
                    T_regt <= std_logic_vector(to_unsigned(to_integer(unsigned(T_reg)) + 
                          (to_integer(unsigned(Aw)) * to_integer(unsigned(B))) + 
                          (to_integer(unsigned(u)) * N), T_regt'length));
                     state <= shift;   
                       
              when shift=>                              
                    --state <= COMPUTEU;   -- Stay in compute state
               if counter < m then
                counter <= counter + 1;  -- Increment counter
                T_reg<=T_regt(L-1+w downto w);      
                A_reg <= zero_pad & A_reg(L-1 downto w);
                state <= COMPUTE_U;
               else
                 state <= FINALIZE;   -- Move to finalize state
                end if;

            when FINALIZE =>
                -- Final subtraction if T >= N
                if to_integer(unsigned(T_reg)) >= N then
                    T <= std_logic_vector(to_unsigned(to_integer(unsigned(T_reg)) - N, T_reg'length));
                else   
                     T <= T_reg;  -- Output the result 
                end if;

                -- Final reduction by R (optional, uncomment if needed)
                -- T <= std_logic_vector((unsigned(T_reg) * unsigned(R)) mod unsigned(N));
               
                state <= FINALIZE;  -- Go back to IDLE after finishing
        end case;
        end if;
    end process;
end Behavioral;
