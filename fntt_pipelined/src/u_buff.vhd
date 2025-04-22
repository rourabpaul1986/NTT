----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/11/2025 04:16:23 PM
-- Design Name: 
-- Module Name: u_buff - Behavioral
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
use work.variant_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity u_buff is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           u : in std_logic_vector(logq-1 downto 0);    --address for port 0
           u_d : out std_logic_vector(logq-1 downto 0)
            );
end u_buff;

architecture Behavioral of u_buff is
signal u_d1, u_d2 :  std_logic_vector(logq-1 downto 0);
begin

    process(clk)
    begin
        if(rising_edge(clk)) then
            --For port 0. Writing.
            if(rst = '1') then
                --addr_wr_3<=(others=>'0');
            elsif(rst = '0') then    --see if write enable is ON.
              u_d1<=u;
              u_d2<=u_d1;
            end if;
        end if;
    end process;
    u_d<=u_d2;
end Behavioral;
