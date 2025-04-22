----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/11/2025 02:26:03 PM
-- Design Name: 
-- Module Name: addr_buf - Behavioral
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

entity addr_buf is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
            addr_rd_0 : in std_logic_vector(logn-1 downto 0);    --address for port 0
            addr_rd_1 : in std_logic_vector(logn-1 downto 0);    --address for port 1
            addr_wr_0 : out std_logic_vector(logn-1 downto 0);    --address for port 0
            addr_wr_1 : out std_logic_vector(logn-1 downto 0)
           );
end addr_buf;

architecture Behavioral of addr_buf is
signal addr_wr_0_0 :  std_logic_vector(logn-1 downto 0);
signal addr_wr_0_1  :  std_logic_vector(logn-1 downto 0);
signal addr_wr_1_0 :  std_logic_vector(logn-1 downto 0);
signal addr_wr_1_1 :  std_logic_vector(logn-1 downto 0);
begin

    process(clk)
    begin
        if(rising_edge(clk)) then
            --For port 0. Writing.
            if(rst = '1') then
                --addr_wr_3<=(others=>'0');
            elsif(rst = '0') then    --see if write enable is ON.
              addr_wr_0_0 <=addr_rd_0;
              addr_wr_1_0 <=addr_rd_1;
              
              addr_wr_0_1 <=addr_wr_0_0;
              addr_wr_1_1 <=addr_wr_1_0;
              
                            
              addr_wr_0 <=addr_wr_0_1;
              addr_wr_1 <=addr_wr_1_1;
            end if;
        end if;
    end process;

end Behavioral;
