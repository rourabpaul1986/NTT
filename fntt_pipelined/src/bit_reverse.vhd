----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2025 01:32:24 PM
-- Design Name: 
-- Module Name: bit_reverse - Behavioral
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
--use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.variant_pkg.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bit_reverse is
    generic (
        bit_length : integer := 4  -- Number of clock cycles per update
    );
    Port (
        j     : in integer range 0 to bit_length-1;
        j_r     : out integer range 0 to bit_length-1
    );
end bit_reverse;

architecture Behavioral of bit_reverse is
signal shift, index : std_logic_vector(logNby2-1 downto 0):=(others=>'0');
begin



  shift<=std_logic_vector(to_unsigned(j, logNby2));
   bit_reverse_inner : for q in 0 to logNby2-1 generate
      index(q)<=shift(lognby2-1-q);
   end generate bit_reverse_inner; 


j_r <= to_integer(unsigned(index));
end behavioral;