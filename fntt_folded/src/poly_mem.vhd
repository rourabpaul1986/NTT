----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2025
-- Design Name: 
-- Module Name: poly_mem - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity poly_mem is
    port(   clk : in std_logic; --clock
            wr_en : in std_logic;   --write enable for port 0
            data_in0 : in std_logic_vector(logq-1 downto 0);   --Input data to port 0.
            data_in1 : in std_logic_vector(logq-1 downto 0);   --Input data to port 1.
            addr_in_0 : in std_logic_vector(logn-1 downto 0);    --address for port 0
            addr_in_1 : in std_logic_vector(logn-1 downto 0);    --address for port 1
            ce : in std_logic;   --enable port 0.
            rd_en : in std_logic;   --enable port 1.
            data_out_0 : out std_logic_vector(logq-1 downto 0);  --output data from port 0.
            data_out_1 : out std_logic_vector(logq-1 downto 0)   --output data from port 1.
        );
end poly_mem;

architecture Behavioral of poly_mem is

    type ram_type is array(0 to 15) of std_logic_vector(logq-1 downto 0);
    signal ram : ram_type := (
         0 => std_logic_vector(to_unsigned(2687, logq)),
         1 => std_logic_vector(to_unsigned(2727, logq)),
         2 => std_logic_vector(to_unsigned(633, logq)),
         3 => std_logic_vector(to_unsigned(570, logq)),
         4 => std_logic_vector(to_unsigned(2200, logq)),
         5 => std_logic_vector(to_unsigned(926, logq)),
         6 => std_logic_vector(to_unsigned(668, logq)),
         7 => std_logic_vector(to_unsigned(1192, logq)),
         8 => std_logic_vector(to_unsigned(1597, logq)),
         9 => std_logic_vector(to_unsigned(2896, logq)),
        10 => std_logic_vector(to_unsigned(2699, logq)),
        11 => std_logic_vector(to_unsigned(3030, logq)),
        12 => std_logic_vector(to_unsigned(1344, logq)),
        13 => std_logic_vector(to_unsigned(1569, logq)),
        14 => std_logic_vector(to_unsigned(1246, logq)),
        15 => std_logic_vector(to_unsigned(1845, logq))
    );

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if ce = '1' then
                if wr_en = '1' then
                    ram(conv_integer(addr_in_0)) <= data_in0;
                    ram(conv_integer(addr_in_1)) <= data_in1;
                end if;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if ce = '1' then
                if rd_en = '1' then
                    data_out_0 <= ram(conv_integer(addr_in_0));
                    data_out_1 <= ram(conv_integer(addr_in_1));
                end if;
            end if;
        end if;
    end process;

end Behavioral;
