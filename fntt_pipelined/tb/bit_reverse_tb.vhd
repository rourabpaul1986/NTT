library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.variant_pkg.all;
entity bit_reverse_tb is
end bit_reverse_tb;

architecture test of bit_reverse_tb is

    signal j : integer range 0 to N/2-1 := 0;
    signal j_r : integer range 0 to N/2-1;
    
    -- Instantiate the Unit Under Test (UUT)
    component bit_reverse
        Port (
            j     : in integer range 0 to N/2-1;
            j_r   : out integer range 0 to N/2-1
        );
    end component;

begin
    uut: bit_reverse
        port map (j => j, j_r => j_r);

    process
    begin
        for i in 0 to N/2-1 loop
            j <= i;
            wait for 10 ns;
        end loop;
        wait;
    end process;

end test;
