library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity montgomery_mult is
    generic (
        L : integer := 32;        -- Length of the operands
        w : integer := 16;         -- Width of the segments
        --N : integer := 3329;    -- The modulus
        q : integer := 72639;    -- The modulus
        --N_prime : integer := 1;     -- Precomputed value for w=2 and 4
        q_prime : integer := 193;     -- Precomputed value for 8
        K : integer := 7     -- Precomputed value
    );
    Port (
        clk : in std_logic;                   -- Clock input
        reset : in std_logic;                 -- Reset input
        start : in std_logic;                 -- Start signal for multiplication
        A : in std_logic_vector(L-1 downto 0);-- Operand A
        B : in std_logic_vector(L-1 downto 0);-- Operand B
        done : out std_logic; -- Output T
        fault : out std_logic; -- Output T
        T : out std_logic_vector(L-1 downto 0) -- Output T
    );
end montgomery_mult;

architecture Behavioral of montgomery_mult is
    -- State definitions
    type state_type is (IDLE, COMPUTE_U, COMPUTE_T, SHIFT, ADJUST, FINALIZE);
    signal state : state_type;

    -- Constants
    constant m : integer := L / w;
    constant bx : integer := 2**w;
    constant R : integer := 2**L;
  

    

    -- Internal signals
    signal T_reg, A_reg, Af_reg : std_logic_vector(L-1 downto 0) := (others => '0');
    signal T_R_shift : unsigned(L+L-1 downto 0) := (others => '0');
    
    signal u, uf : std_logic_vector(w-1 downto 0);
    signal Aw, Awf, B0, T0 : std_logic_vector(w-1 downto 0);
    signal zero_pad : std_logic_vector(w-1 downto 0):=(others => '0');
    signal zero_lpad : std_logic_vector(l-1 downto 0):=(others => '0');
    signal counter : integer := 0;  -- To keep track of the loop index
    signal T_regt, Tf_regt : std_logic_vector(3*L-1 downto 0) := (others => '0');
    signal k1 :std_logic_vector(L-1 downto 0) := (others => '0');
   signal fault_reg : std_logic:= '0';
    

begin

    -- Next state logic
    process(state, start, clk, reset)     
     variable awf_full :std_logic_vector(2*L-1 downto 0) := (others => '0');
     variable Aw: std_logic_vector(w-1 downto 0);
    begin
    
         if reset = '1' then
            state <= IDLE;
            T_reg <= (others => '0');
            T_regt <= (others => '0');
            A_reg <= (others => '0');
            counter <= 0;
            done <= '0';
            
        elsif rising_edge(clk) then
        case state is
            when IDLE =>
                if start = '1' then
                    state <= COMPUTE_U;
                    A_reg <= A;
                    --Af_reg<= std_logic_vector(unsigned(A)*unsigned(A));
                    done <= '0';
                    --T_reg <= (others => '0');  -- Reset T
                    --counter <= 0;               -- Reset counter
                else
                    state <= IDLE;
                end if;

            when COMPUTE_U =>
                
                    T0 <= T_reg(w-1 downto 0);
                    B0 <= B(w-1 downto 0);
                    Aw := A_reg(w-1 downto 0);
                    --Awf_full:= std_logic_vector(unsigned(A_reg(w-1 downto 0)) + unsigned(k1 & std_logic_vector(to_unsigned(bx, T'length))));
                    --Awf<=Awf_full(w-1 downto 0);
                    -- Calculate u
                    u <= std_logic_vector(to_unsigned((to_integer(unsigned(T_reg(w-1 downto 0))) + (to_integer(unsigned(Aw)) * to_integer(unsigned(B(w-1 downto 0))))) * q_prime, u'length));
                    uf <= std_logic_vector(to_unsigned((to_integer(unsigned(T_reg(w-1 downto 0))) + (to_integer(unsigned(Awf_full(w-1 downto 0))) * to_integer(unsigned(B(w-1 downto 0))))) * q_prime, u'length));
                    
                    state <= COMPUTE_T;
                     
                    -- Update T_reg
             when COMPUTE_T=>  
                  -- if(uf/=u) then
                    -- fault_reg<='1';
                   --end if;
                    T_regt <= std_logic_vector(to_unsigned(to_integer(unsigned(T_reg)) + 
                          (to_integer(unsigned(Aw)) * to_integer(unsigned(B))) + 
                          (to_integer(unsigned(u)) * q), T_regt'length)); --the width of T_regt is 3*l
                    
                     Tf_regt <= std_logic_vector(to_unsigned(to_integer(unsigned(T_reg)) + 
                          (to_integer(unsigned(Awf_full)) * to_integer(unsigned(B))) + 
                          (to_integer(unsigned(uf)) * q), T_regt'length)); --the width of T_regt is 3*l
                     state <= shift;   
                       
              when shift=>     
               if(T_regt/=Tf_regt) then
                 fault_reg<='1';
                end if;                         
                    --state <= COMPUTEU;   -- Stay in compute state
               if counter < m-1 then
                counter <= counter + 1;  -- Increment counter
                T_reg<=T_regt(L-1+w downto w);      
                A_reg <= zero_pad & A_reg(L-1 downto w);
                state <= COMPUTE_U;
               else
                 T_reg<=T_regt(L-1+w downto w);      
                 A_reg <= zero_pad & A_reg(L-1 downto w);
                 counter <=m-1;
                 state <= ADJUST;   -- Move to finalize state
                end if;
                
            when ADJUST =>   
--             if to_integer(unsigned(T_reg)) >= N then
--                    --T <= std_logic_vector(to_unsigned(((to_integer(unsigned(T_reg)*R) mod N) - N), T'length));
--                    T_R_shift <= unsigned(zero_lpad & std_logic_vector(unsigned(T_reg) - to_unsigned(N, T_reg'length)));

--                    --T <= std_logic_vector(to_unsigned(to_integer(unsigned(T_reg)) - N, T_reg'length));
--                else   
--                    --T <=std_logic_vector(to_unsigned((((to_integer(unsigned(T_reg)) * R) mod N)), T'length));
--                    --T_R_shift<= unsigned(T_reg & std_logic_vector(to_unsigned(R, T'length)));
--                    T_R_shift<= unsigned(T_reg & zero_lpad);
--                    --T<=std_logic_vector(to_unsigned((to_integer(unsigned( T_reg & std_logic_vector(to_unsigned(R, T'length)))) mod N), T'length));
--                     --T<=T_reg;
--                end if;
                T_R_shift<= unsigned(T_reg & zero_lpad);
                state <= FINALIZE;
 

            when FINALIZE =>
            T <= std_logic_vector(T_R_shift mod to_unsigned(q, L));
              --T <= std_logic_vector(T_R_shift(l-1 downto 0));


                     
               
                state <= FINALIZE;  -- stay inside it
                done<= '1';
        end case;
        end if;
    end process;
    fault<=fault_reg;
end Behavioral;
