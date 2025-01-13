library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fault_RENO is
    generic (
        L : integer := 20;        -- Length of the operands
        w : integer := 4;        -- Length of the operands
        S : integer := 40;        -- Length of the operands
        k : integer := 40;         -- Width of the segments
        N : integer := 72639;
        mu : integer := 15136656     -- The modulus    
    );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           Aw,Bw : in STD_LOGIC_VECTOR (w-1 downto 0);
            i, j : in natural range 0 to l/w-1 := 0; 
           done : out STD_LOGIC;
           R : out STD_LOGIC_VECTOR (L-1 downto 0)
           );
end fault_RENO;

architecture fault_RENO_arch of fault_RENO is
 type state_type is (IDLE, C_COM, CxMU_COM, QxN_COM, FINALIZE);
  signal state : state_type;
--constant Xk : std_logic_vector(2*S-1 downto 0) := x"00000000000000000005";
--signal QN : std_logic_vector(2*s-1 downto 0);
--signal R_t : std_logic_vector(2*s-1 downto 0);
signal C_shift : std_logic_vector(s-1 downto 0) := (others => '0');
signal zero_pad : std_logic_vector(w*(l/w-1 + l/w-1)-1 downto 0) := (others => '0');
signal Q : std_logic_vector((s + k)-1 downto 0) := (others => '0'); 
signal R2 : std_logic_vector(L-1 downto 0) := (others => '0');
signal done_reg : std_logic;
begin 

    process(state, start, reset, clk)     
    begin
    
         if reset = '1' then
            state <= IDLE;
            done_reg<='0';

        elsif start='0' then
            state <= IDLE;
        elsif rising_edge(clk) then
        case state is
            when IDLE =>
              if start = '1' then
                    done_reg<='0';
                    state <= C_COM;
              else
                    state <= IDLE;     
              end if;
                        
            
            when C_COM =>   
                  if(i=0 and j=0) then --c_shift = aw*bw << (i + j) * w  #c_shift
                    C_shift(2*w-1 downto 0)<=std_logic_vector(to_unsigned((to_integer(unsigned(not Aw)+1) * to_integer(unsigned(not Bw)+1)), 2*w));
                 else
                    C_shift(2*w+(i+j)*w-1 downto 0)<=std_logic_vector(to_unsigned((to_integer(unsigned(Aw)) * to_integer(unsigned( Bw))), 2*w)) & zero_pad((i+j)*w-1 downto 0);
                  end if;
                  state <= CxMU_COM;
                  
             when CxMU_COM=>                            
                 Q <= std_logic_vector(resize(unsigned(C_shift) * to_unsigned(mu, C_shift'length), Q'length)); --c_shift*mu                
                 state <= QxN_COM;
                 
                  
             when QxN_COM=>   
                 --R1 <= std_logic_vector(resize(unsigned(Q(2*s-1 downto s)) * to_unsigned(N, R1'length), R1'length)); -- q * n
                 R2<= std_logic_vector(resize(unsigned(C_shift) - unsigned(std_logic_vector(resize(unsigned(Q(2*s-1 downto k)) * to_unsigned(N, L), L))), L)); -- r = c - q * n
                 state <= FINALIZE;
                 done_reg<='1';
                 
              when FINALIZE =>               
                state <= FINALIZE;  -- stay inside it
                done_reg<='1';
            
        end case;
        end if;
     end process;
done<=done_reg;
R<=R2;

 --   QN <= std_logic_vector(
 --           resize(
 --               unsigned(Q) * to_unsigned(N, L),
 --               2*S
 --           )
 --       ) when start='1';
        
   -- R_t<=std_logic_vector(unsigned(C xor xk(S-1 downto 0)) - unsigned(QN xor xk(2*S-1 downto 0) xor xk(2*S-1 downto 0) ))  when start='1';
-- Ensure all operands are of matching size
--R <= std_logic_vector(
--        resize(
--            unsigned(C) xor resize(Xk, S) + 
--            unsigned(
--                std_logic_vector(
--                    resize(
--                        (unsigned(Q(2*S-1 downto k)) xor resize(Xk, 2*S-k)) * 
--                        (unsigned(to_unsigned(N, S)) xor resize(Xk, S)), 
--                        L
--                    )
--                )
--            ), 
--            L
--        )
--    )  when start='1';
--R<=R_t(L-1 downto 0) xor xk(L-1 downto 0);

end fault_RENO_arch;
