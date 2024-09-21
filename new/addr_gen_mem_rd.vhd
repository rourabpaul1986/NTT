library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.ntt_pkg.all;

entity addr_gen_mem_rd is
    Port ( clk   : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           ready : out STD_LOGIC;
           addra : out std_logic_vector(logn*n downto 0);
           done  : out STD_LOGIC);
end addr_gen_mem_rd;

architecture Behavioral of addr_gen_mem_rd is
signal     addra_buf1 : std_logic_vector(logn*n downto 0) := (others => '0');
signal     addra_buf2 : std_logic_vector(logn*n downto 0) := (others => '0');
signal     ready_buf, ready_buf1, ready_buf2, done_buf3, done_buf2, done_buf1 : std_logic := '0';

begin

process(clk, reset)
begin
    if reset = '1' then
        addra_buf1 <= (others => '0');
        addra_buf2 <= (others => '0');
        ready_buf  <= '0';
        ready_buf1 <= '0';
        ready_buf2 <= '0';
        done_buf1  <= '0';
        done_buf2  <= '0';
        done_buf3  <= '0';
    elsif rising_edge(clk) then
        addra_buf2 <= addra_buf1;  -- Update addra_buf2 with the current address
        done_buf2  <= done_buf1;   -- Update done_buf2 with done_buf1
        done_buf3  <= done_buf2;   -- Update done_buf2 with done_buf1
        -- Address increment logic
        if to_integer(unsigned(addra_buf1)) = 2*n*n-1 then
            ready_buf1  <= '0';           -- De-assert ready when the address reaches 2*n-1
            ready_buf2  <= ready_buf1;           -- De-assert ready when the address reaches 2*n-1
            ready_buf   <= ready_buf2;           -- De-assert ready when the address reaches 2*n-1
            done_buf1  <= '1';           -- Indicate done
            addra_buf1 <= addra_buf1;     -- Hold the address at 2*n-1
        else
            addra_buf1 <= addra_buf1 + 1; -- Increment address until it reaches 2*n-1
            ready_buf  <= '1';           -- Keep ready high during the counting phase
            ready_buf1  <= '1';           -- Keep ready high during the counting phase
            ready_buf2  <= '1';           -- Keep ready high during the counting phase
            done_buf1  <= '0';           -- Ensure done is de-asserted while counting
        end if;
    end if;
end process;

-- Output assignments
ready <= ready_buf;
addra <= addra_buf2;--(logn downto 0);   -- Output the address (one cycle delayed)
done  <= done_buf3;

end Behavioral;
