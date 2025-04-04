----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dr. Rourab paul
-- 
-- Create Date: 01/03/2025 02:56:33 PM
-- Design Name: 
-- Module Name: barrett_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity barrett_top is
    generic (
        L : integer := 20;        -- Length of the operands
        w : integer := 4;         -- Width of the segments
        --mu : integer := 59127;         -- # Equivalent to 2^k // N
        N : integer := 72639    -- The modulus    
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
end barrett_top;

architecture Behavioral of barrett_top is
   -- State definitions
    type state_type is (IDLE, C_COM, CxMU_COM, QxN_COM, AddR_COM, T_COM, i_CHK, FINALIZE);
    signal state : state_type;

    -- Constants

    constant k : integer := 2*l; --32 for w=4
    constant mu : integer := (2**(2*l)) / n; --2^k//n
    constant s : integer := 2*w+((l/w-1+l/w-1)*w); --32 for w=4
    constant logN : positive := positive(ceil(log2(real(N))));

    -- Internal signals
    
    signal  A_reg, B_reg : std_logic_vector(L-1 downto 0) := (others => '0'); -- No change
    signal C_reg : std_logic_vector(2*w-1 downto 0) := (others => '0'); -- No change, optimal for w-bit multiplication
    signal C_shift : std_logic_vector((2*w + ((l/w-1 + l/w-1)*w))-1 downto 0) := (others => '0'); -- Optimized bit-width
    signal zero_pad : std_logic_vector(w*(l/w-1 + l/w-1)-1 downto 0) := (others => '0'); -- Optimized
    signal Q : std_logic_vector((2*w + ((l/w-1 + l/w-1)*w) + k)-1 downto 0) := (others => '0'); -- Adjusted based on required width
    signal R1, R2, T_reg : std_logic_vector(L-1 downto 0) := (others => '0'); -- Adjusted to match modular reduction width
    signal zero_qpad : std_logic_vector(k-1 downto 0) := (others => '0'); -- No change
    signal i, j : natural range 0 to l/w-1 := 0; -- Optimized for loop index

    signal fault_reg : std_logic:= '0';
    
    
begin

    assert logN < L
    report "Error:The number of bit required to store N is greater than or equal to L. Please adjust the parameters."
    severity FAILURE; 

    -- Next state logic
    process(state, start, clk, reset)     
     variable awf_full :std_logic_vector(2*L-1 downto 0) := (others => '0');
     variable Aw: std_logic_vector(w-1 downto 0);
     variable Bw: std_logic_vector(w-1 downto 0);
    begin
    
         if reset = '1' then
            state <= IDLE;
            T_reg <= (others => '0');
            A_reg <= (others => '0');
            i <= 0;
            j <= 0;
            done <= '0';
            
        elsif rising_edge(clk) then
        case state is
            when IDLE =>
                if start = '1' then
                    state <= C_COM;
                    A_reg <= A;
                    B_reg <= B;
                    done <= '0';
                else
                    state <= IDLE;
                end if;

            when C_COM =>            
                 --C_reg <= std_logic_vector(to_unsigned((to_integer(unsigned(A_reg(w-1+i*w downto 0+i*w))) * to_integer(unsigned( B_reg(w-1+j*w downto 0+j*w)))), 2*w)) & zero_pad((i+j)*w downto 0);
                 C_reg <= std_logic_vector(to_unsigned((to_integer(unsigned(A_reg(w-1+i*w downto 0+i*w))) * to_integer(unsigned( B_reg(w-1+j*w downto 0+j*w)))), C_reg'length));                   
                 if(i=0 and j=0) then
                    C_shift(2*w-1 downto 0)<=std_logic_vector(to_unsigned((to_integer(unsigned(A_reg(w-1+i*w downto 0+i*w))) * to_integer(unsigned( B_reg(w-1+j*w downto 0+j*w)))), C_reg'length));
                 else
                    C_shift(2*w+(i+j)*w-1 downto 0)<=std_logic_vector(to_unsigned((to_integer(unsigned(A_reg(w-1+i*w downto 0+i*w))) * to_integer(unsigned( B_reg(w-1+j*w downto 0+j*w)))), C_reg'length)) & zero_pad((i+j)*w-1 downto 0);
                  end if;
                  state <= CxMU_COM;
                    
                    
             when CxMU_COM=>                            
                 Q <= std_logic_vector(resize(unsigned(C_shift) * to_unsigned(mu, C_shift'length), Q'length)); --c_shift*mu                
                 state <= QxN_COM;
                  
             when QxN_COM=>  
                 --R1 <= std_logic_vector(resize(unsigned(Q(2*s-1 downto s)) * to_unsigned(N, R1'length), R1'length)); -- q * n
                 R2<= std_logic_vector(resize(unsigned(C_shift) - unsigned(std_logic_vector(resize(unsigned(Q(2*s-1 downto k)) * to_unsigned(N, R1'length), R1'length))), R1'length)); -- r = c - q * n
                 state <= AddR_COM;

              when AddR_COM=> 
                 if unsigned(R2) >= to_unsigned(N, T_reg'length) then                 
                   T_reg<= std_logic_vector(resize(unsigned(T_reg)+unsigned(R2) - to_unsigned(N, R1'length) , R1'length));
                 else
                   T_reg<= std_logic_vector(resize(unsigned(T_reg)+unsigned(R2), R1'length));
                 end if;
                  state <= T_COM;
                
                
               when T_COM=> 
                
                 if unsigned(T_reg) >= to_unsigned(N, T_reg'length) then                 
                   T_reg<= std_logic_vector(resize(unsigned(T_reg) - to_unsigned(N, R1'length) , R1'length));
                 else
                   T_reg<= std_logic_vector(resize(unsigned(T_reg), R1'length));
                 end if;
                 if j< l/w-1 then
                      j<=j+1;
                      state <= C_COM;
                 else
                      j<=0;
                     
                      state <= i_CHK;                      
                  end if; 
                       
              when i_CHK=>     
                --if unsigned(result) >= to_unsigned(N, result'length) then
                 --result <= std_logic_vector(resize(unsigned(result) - to_unsigned(N, result'length), result'length));
                --end if;               
                 if i=l/w-1 then
                  i<=l/w-1;
                  state <= FINALIZE;
                 else 
                  i<=i+1;
                  state <= C_COM;
                 end if;
                 
            when FINALIZE =>               
                state <= FINALIZE;  -- stay inside it
                done<= '1';
        end case;
        end if;
    end process;
    fault<=fault_reg;
    T<=T_reg;

end Behavioral;
