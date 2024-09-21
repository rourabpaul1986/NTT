----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/20/2024 02:47:48 PM
-- Design Name: 
-- Module Name: coeff_adder - Behavioral
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.ntt_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity coeff_adder is
    Port ( clk : in STD_LOGIC;
           coeff : in STD_LOGIC_VECTOR (logq-1 downto 0);
           reset : in STD_LOGIC;
           adder_op : out STD_LOGIC_VECTOR (logq-1 downto 0);
           done : out STD_LOGIC);
end coeff_adder;

architecture Behavioral of coeff_adder is
   signal counter : integer range 0 to n-1:=0;
   signal sum : STD_LOGIC_VECTOR (logq downto 0);
   signal final_sum : STD_LOGIC_VECTOR (logq-1 downto 0);
   signal done_buf : STD_LOGIC;
begin

process(clk, reset)
begin
    if reset = '1' then
    counter<=0;
    done_buf<='0';
    sum<=(others=>'0');
    elsif rising_edge(clk) then
       if counter=n-1 then
        done_buf<='1';
        final_sum <= std_logic_vector(to_unsigned(to_integer(unsigned(sum+coeff)) mod q, final_sum'length));
        sum<=(others=>'0');
        counter<=0;
       else
        sum<=sum+coeff;
        counter<=counter+1;
       end if;
    end if;
end process;
adder_op<=final_sum;
done<=done_buf;
end Behavioral;
