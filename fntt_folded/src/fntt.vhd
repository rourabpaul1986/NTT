----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/03/2025 10:41:33 AM
-- Design Name: 
-- Module Name: fntt - Behavioral
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
use work.variant_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fntt is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           spo   : out std_logic_vector(logq-1 downto 0);
           done : out STD_LOGIC);
end fntt;

architecture Behavioral of fntt is
--component poly_memA is
--port(
-- clk  : in  std_logic;
-- a   : in  std_logic_vector(logn-1 downto 0);
-- spo   : out std_logic_vector(logq-1 downto 0)
--);
--end component;

component w_mem is
port(
 clk  : in  std_logic;
 a   : in  std_logic_vector(logn-1 downto 0);
 spo   : out std_logic_vector(logq-1 downto 0)
);
end component;
signal  i   :  integer range 0 to logN-1;
signal  k   :  integer range 0 to N/2-1;
signal  halflen   :  integer range 0 to N/2-1;
signal  j, j_r   :  integer range 0 to N/2-1;
signal index_done : std_logic;
signal barrett_rst : std_logic;
signal barrett_fault : std_logic;
signal barrett_done : std_logic;
signal uv_rst : std_logic;
signal j_addr, k_addr0,k_addr1 : std_logic_vector(logn-1 downto 0):=(others=>'0');
signal w : std_logic_vector(logq-1 downto 0):=(others=>'0');
signal A0,A1 : std_logic_vector(logq-1 downto 0):=(others=>'0');
signal U,O1, V : std_logic_vector(logq-1 downto 0):=(others=>'0');
signal UV_add_O : std_logic_vector(logq-1 downto 0):=(others=>'0');
signal UV_sub_O : std_logic_vector(logq-1 downto 0):=(others=>'0');
signal wr_en,  rd_en ,  ce : std_logic:='0';
begin
--    poly_memA_DUT : poly_memA 
--     port map (   
--        clk   =>clk,
--        a =>k_addr,
--        spo  =>A
--        ); 
spo<=UV_add_O xor UV_sub_O;
  poly_mem_DUT : entity work.poly_mem 
        port map (
        clk   =>clk,
        wr_en =>wr_en,
       data_in0 =>UV_add_O,
       data_in1 =>UV_sub_O,
       addr_in_0 =>k_addr0,
       addr_in_1 =>k_addr1,
       rd_en => rd_en,
       ce => ce,
       data_out_0 =>U,
       data_out_1 =>O1
        ); 
        
    w_mem_DUT : w_mem 
     port map (   
        clk   =>clk,
        a =>j_addr,
        spo  =>w
        );  

   ijk_gen_DUT: entity work.index_gen
        port map (
        clk   =>clk,
        reset =>rst,
        i     =>i,
        j     =>j,
        k     =>k,
        halflen=>halflen,
        wr_en =>wr_en,
        rd_en =>rd_en,
        ce =>ce,
        done  =>index_done
        ); 

   bit_reverse_DUT: entity work.bit_reverse
        generic map (
            bit_length => N/2
        )
        port map (
        j     =>j,
        j_r   =>j_r
        ); 
   j_addr<=std_logic_vector(to_unsigned(j_r, logN));
   k_addr1<=std_logic_vector(to_unsigned(k+halflen+2*j*halflen, logN));
   k_addr0<=std_logic_vector(to_unsigned(k+2*j*halflen, logN));
   
    barrett_rst<=not rd_en;
     barrett_DUT: entity work.barrett_top
        generic map (
            L => logq,
            w=>logq
        )
        port map (
            clk => clk,
            reset => barrett_rst,
            start => rd_en,
            A => O1,
            B => w,
            done => barrett_done,
            fault => barrett_fault,
            T => V
        );
    uv_rst<=not ce;    
        
        UV_adder_DUT: entity work.UV_adder 
       Port map (
        rst =>uv_rst,
        U   =>U,
        V   =>V,
        O   =>UV_add_O
    );
    
            UV_sub_DUT: entity work.UV_sub
       Port map (
        rst =>uv_rst,
        U   =>U,
        V   =>V,
        O   =>UV_sub_O
    );
    done<=index_done;
end Behavioral;
