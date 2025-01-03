library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fault_detection is
    generic (
        n : integer := 8; -- Number of `i` levels (default: 4 for i=0 to 3)
       logn : integer := 3   
    );
    port (
        i       : in  unsigned(logn downto 0); -- 2 bits for i (0 to n-1)
        j       : in  unsigned(n downto 0); -- 4 bits for j (0 to 15)
        k       : in  unsigned(n downto 0); -- 4 bits for k (0 to 15)
        valid   : out std_logic             -- 1 if valid, 0 if fault
    );
end entity;

architecture behavioral of fault_detection is
    signal max_j : unsigned(n downto 0); -- Signal for max value of j
    signal max_k : unsigned(n downto 0); -- Signal for max value of k
begin
    -- Generative logic for max_j and max_k
    max_j <= to_unsigned((2 ** to_integer(i)) - 1, n); -- max_j = 2^i - 1
    process (i)
    begin
        -- max_j depends on `i`
--        if to_integer(i) < n - 1 then
--            max_j <= to_unsigned((2 ** to_integer(i)) - 1, 4); -- max_j = 2^i - 1
--        else
--            max_j <= to_unsigned(7, 4); -- Special case for i=n-1: max_j=7
--        end if;

        -- max_k depends on `i`
        if to_integer(i) = 0 then
            max_k <= to_unsigned(7, n); -- max_k = 7 for i=0
        elsif to_integer(i) = 1 then
            max_k <= to_unsigned(3, n); -- max_k = 3 for i=1
        elsif to_integer(i) = 2 then
            max_k <= to_unsigned(1, n); -- max_k = 1 for i=2
        else
            max_k <= to_unsigned(0, n); -- max_k = 0 for i=n-1
        end if;
    end process;

    -- Validate `j` and `k` using comparisons
    valid <= '1' when (j <= max_j and k <= max_k) else '0';

end architecture;
