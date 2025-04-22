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
            data_in1 : in std_logic_vector(logq-1 downto 0);   --Input data to port 0.
            addr_rd_0 : in std_logic_vector(logn-1 downto 0);    --address for port 0
            addr_rd_1 : in std_logic_vector(logn-1 downto 0);    --address for port 1
            addr_wr_0 : in std_logic_vector(logn-1 downto 0);    --address for port 0
            addr_wr_1 : in std_logic_vector(logn-1 downto 0);    --address for port 1
            ce : in std_logic;   --enable port 0.
            rd_en : in std_logic;   --enable port 1.
            data_out_0 : out std_logic_vector(logq-1 downto 0);  --output data from port 0.
            data_out_1 : out std_logic_vector(logq-1 downto 0)   --output data from port 1.
        );
end poly_mem;

architecture Behavioral of poly_mem is

    type ram_type is array(0 to 31) of std_logic_vector(logq-1 downto 0);
    signal ram : ram_type := (
         0 => std_logic_vector(to_unsigned(2487, logq)),
         1 => std_logic_vector(to_unsigned(3137, logq)),
         2 => std_logic_vector(to_unsigned(1208, logq)),
         3 => std_logic_vector(to_unsigned(953, logq)),
         4 => std_logic_vector(to_unsigned(89, logq)),
         5 => std_logic_vector(to_unsigned(164, logq)),
         6 => std_logic_vector(to_unsigned(1428, logq)),
         7 => std_logic_vector(to_unsigned(41, logq)),
         8 => std_logic_vector(to_unsigned(3163, logq)),
         9 => std_logic_vector(to_unsigned(1639, logq)),
        10 => std_logic_vector(to_unsigned(3109, logq)),
        11 => std_logic_vector(to_unsigned(1424, logq)),
        12 => std_logic_vector(to_unsigned(696, logq)),
        13 => std_logic_vector(to_unsigned(876, logq)),
        14 => std_logic_vector(to_unsigned(2679, logq)),
        15 => std_logic_vector(to_unsigned(2972, logq)),
        16 => std_logic_vector(to_unsigned(2833, logq)),
        17 => std_logic_vector(to_unsigned(2531, logq)),
        18 => std_logic_vector(to_unsigned(614, logq)),
        19 => std_logic_vector(to_unsigned(630, logq)),
        20 => std_logic_vector(to_unsigned(709, logq)),
        21 => std_logic_vector(to_unsigned(1555, logq)),
        22 => std_logic_vector(to_unsigned(2426, logq)),
        23 => std_logic_vector(to_unsigned(1064, logq)),
        24 => std_logic_vector(to_unsigned(2711, logq)),
        25 => std_logic_vector(to_unsigned(2113, logq)),
        26 => std_logic_vector(to_unsigned(408, logq)),
        27 => std_logic_vector(to_unsigned(557, logq)),
        28 => std_logic_vector(to_unsigned(1128, logq)),
        29 => std_logic_vector(to_unsigned(3046, logq)),
        30 => std_logic_vector(to_unsigned(833, logq)),
        31 => std_logic_vector(to_unsigned(1162, logq))
    );

begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            --For port 0. Writing.
            if(ce = '1') then    --see if write enable is ON.
                if(wr_en = '1') then    --see if write enable is ON.
                    ram(conv_integer(addr_wr_0)) <= data_in0;
                    ram(conv_integer(addr_wr_1)) <= data_in1;
                end if;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
    if(rising_edge(clk)) then
            --For port 0. Writing.
            if(ce = '1') then    --see if write enable is ON.
                if(rd_en = '1') then    --see if write enable is ON.
                    data_out_0 <= ram(conv_integer(addr_rd_0));
                    data_out_1 <= ram(conv_integer(addr_rd_1));
                end if;
            end if;
        end if;
    end process;


end Behavioral;
