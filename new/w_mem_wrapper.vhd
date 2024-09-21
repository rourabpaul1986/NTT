----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/18/2024 12:38:56 PM
-- Design Name: 
-- Module Name: w_mem_wrapper - Behavioral
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

entity w_mem_wrapper is
    Port ( clka : in STD_LOGIC;
           addra : in std_logic_vector(logn*n downto 0); --two polynomials
           ena :  in std_logic;
           --done :  out std_logic;
           douta: out std_logic_vector(logq-1 downto 0)
           );
end w_mem_wrapper;

architecture Behavioral of w_mem_wrapper is
component w_mem is
    Port ( clka : in STD_LOGIC;
           addra : in std_logic_vector(logn-1 downto 0); --two polynomials
           ena :  in std_logic;
           douta: out std_logic_vector(logq-1 downto 0))
;
end component;
signal     addr_offset:  std_logic_vector(logn-1 downto 0):=(others=>'0');
signal     k,m : std_logic_vector(n downto 0):=(others=>'0');
begin
omega_read : w_mem 
port map (
    clka =>clka,
    addra =>addr_offset,
    ena=>ena,
    douta=>douta
 );

process(clka)
begin
if ena='0' then
 k<=(others=>'0');
 m<=(others=>'0');
elsif rising_edge(clka) and ena='1' then
   if (to_integer(unsigned(addra+1)) mod (2*n)) = 0 and addra /= std_logic_vector(to_unsigned(0, addra'length)) and m/= std_logic_vector(to_unsigned(n-1, m'length)) then
     m<=m+1;
     k<=(others=>'0');
   elsif m = n and to_integer(unsigned(addra+1))=2*n*n-1 then
      m<=std_logic_vector(to_unsigned(n-1, m'length)); 
      k<=k;
   elsif m/=n and to_integer(unsigned(addra))/=2*n*n-1 then
     if k=n-m then
        k<=(others=>'0');
      else
       k <= std_logic_vector(to_unsigned(((to_integer(unsigned(k)) + to_integer(unsigned(m))) mod n), k'length));
       --k<=k+m;
      end if; 
 end if;
end if;
end process;

addr_offset<=k(logn-1 downto 0);
end Behavioral;
