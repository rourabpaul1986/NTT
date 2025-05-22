library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant_pkg.all;
entity MARC is

    port (
        i     : in integer range 0 to logN-1;
        j     : in integer range 0 to N/2-1;
        k     : in integer range 0 to N/2-1;
        halflen     : in integer range 0 to N/2-1;
        addr_fault   : out std_logic             -- 1 if valid, 0 if fault
    );
end entity;

architecture behavioral of MARC is
    signal max_j : integer range 0 to N/2-1;
    signal max_k : integer range 0 to N/2-1;
begin
    -- Generative logic for max_j and max_k
    max_j <= 2**i-1; -- max_j = 2^i - 1
    


    -- Validate `j` and `k` using comparisons
    addr_fault <= '0' when (j <= max_j and k <= halflen) else '1';

end architecture;