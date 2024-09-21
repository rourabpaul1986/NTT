----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2024 02:48:02 PM
-- Design Name: 
-- Module Name: pol_mult - Behavioral
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

entity pol_mult is
    Port ( clk : in STD_LOGIC;
           a,w : in STD_LOGIC_VECTOR (logq-1 downto 0);
           reset : in STD_LOGIC;
           ena : in STD_LOGIC;
           busy : out STD_LOGIC;
           c : out STD_LOGIC_VECTOR (logq-1 downto 0));
end pol_mult;

architecture Behavioral of pol_mult is
signal c1 : STD_LOGIC_VECTOR (2*logq-1 downto 0):=(others=>'0');
signal ena1, ena2,ena3 : STD_LOGIC;
begin


process(clk, ena)
begin
if rising_edge(clk) then
ena1<=ena; 
ena2<=ena1; 
ena3<=ena2;
end if;
end process;


process(clk, ena2)
begin
if ena2='0' then
 c1<=(others=>'0');
elsif rising_edge(clk) and ena2='1' then
--c1<=a*w;
c1 <= std_logic_vector(to_unsigned(((to_integer(unsigned(a)) * to_integer(unsigned(w))) mod q), c1'length));
end if;
end process;
c<=c1(logq-1 downto 0);
busy<=ena3;
end Behavioral;
