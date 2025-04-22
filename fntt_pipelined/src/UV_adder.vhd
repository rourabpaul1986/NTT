library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.variant_pkg.all;

entity UV_adder is
    Port (
        rst : in  STD_LOGIC;
        u   : in  STD_LOGIC_VECTOR (logq-1 downto 0);
        v   : in  STD_LOGIC_VECTOR (logq-1 downto 0);
        O   : out STD_LOGIC_VECTOR (logq-1 downto 0)
    );
end UV_adder;

architecture Behavioral of UV_adder is
begin
    O <= std_logic_vector(
            to_unsigned(
                (to_integer(unsigned(u)) + to_integer(unsigned(v))) mod q, logq)
         ) when rst = '0' else (others => '0');
end Behavioral;
