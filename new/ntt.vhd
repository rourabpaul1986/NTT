----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2024 10:10:33 AM
-- Design Name: 
-- Module Name: ntt - Behavioral
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

entity ntt is
    Port ( clk : in STD_LOGIC;
           pols : in STD_LOGIC_VECTOR (logq-1 downto 0);
           reset : in STD_LOGIC;
           pol_op : out STD_LOGIC_VECTOR (logq-1 downto 0);
           done : out STD_LOGIC);
end ntt;

architecture Behavioral of ntt is
signal pols_buf, omega : STD_LOGIC_VECTOR (logq-1 downto 0);
signal     addr, addr_wr:  std_logic_vector(logn downto 0):=(others=>'0');
signal     addr_rd:  std_logic_vector(logn*n downto 0):=(others=>'0');
signal     mode :  std_logic_vector(1 downto 0):=(others=>'0');
signal     ready,ready_rd, ready_wr :  std_logic:='0';
signal     wr_done, rd_done :  std_logic:='0';
signal     mul_start :  std_logic:='0';
signal     wea :  std_logic:='0';
signal     not_rst :  std_logic:='0';
signal     start_add, not_start_add :  std_logic:='0';
signal pol_mult_op : STD_LOGIC_VECTOR (logq-1 downto 0);
----------------------------------------------------------------
component pols_mem is
   -- generic (
--base_addr_multiplicand:   natural range 0 to 255;
---base_addr_multipyer:   natural range 0 to 255);
    Port ( clka : in STD_LOGIC;
           addra : in std_logic_vector(logn downto 0); --two polynomials
           dina:  in  std_logic_vector(logq-1 downto 0);
           ena :  in std_logic;
           wea :  in std_logic;
           douta: out std_logic_vector(logq-1 downto 0))
;
end component;
component addr_gen_mem_rd is
    Port ( clk : in STD_LOGIC;
           --mode : in std_logic_vector(1 downto 0);
           reset : in STD_LOGIC;
           ready : out STD_LOGIC;
           addra : out std_logic_vector(logn*n downto 0);
           done : out std_logic
           );
end component;
----------------------------------------------------------------
component addr_gen_mem_wr is
    Port ( clk : in STD_LOGIC;
          -- mode : in std_logic_vector(1 downto 0);
           reset : in STD_LOGIC;
           ready : out STD_LOGIC;
           addra : out std_logic_vector(logn downto 0);
           done : out std_logic
           );
end component;
----------------------------------------------------------------
component pol_mult is
    Port ( clk : in STD_LOGIC;
           a  : in STD_LOGIC_VECTOR (logq-1 downto 0);
           w : in STD_LOGIC_VECTOR (logq-1 downto 0);
           reset : in STD_LOGIC;
           ena : in STD_LOGIC;
            busy : out STD_LOGIC;
           c : out STD_LOGIC_VECTOR (logq-1 downto 0));
end component;
----------------------------------------------------------------
component w_mem_wrapper is
    Port ( clka : in STD_LOGIC;
           addra : in std_logic_vector(logn*n downto 0); --two polynomials
           --dina:  in  std_logic_vector(logq-1 downto 0);
           ena :  in std_logic;
           douta: out std_logic_vector(logq-1 downto 0))
;
end component;
----------------------------------------------------------------
component coeff_adder is
    Port ( clk : in STD_LOGIC;
           coeff : in STD_LOGIC_VECTOR (logq-1 downto 0);
           reset : in STD_LOGIC;
           adder_op : out STD_LOGIC_VECTOR (logq-1 downto 0);
           done : out STD_LOGIC);
end component;
------------------------------------------------

begin
not_rst<=not reset and not rd_done;
--not_rst<=not reset;
--------------------------------------
poly_memory : pols_mem 
port map (
    clka =>clk,
    addra =>addr,
    dina=>pols,
    ena=>not_rst,
    wea=>wea,
    douta=>pols_buf
 );
---------------------------------------------
addr_gen_wr : addr_gen_mem_wr 
port map (
    clk =>clk,
    reset =>reset,
    ready=>ready_wr,
    addra =>addr_wr,
    done =>wr_done
 );
 ---------------------------------------------
addr_gen_rd : addr_gen_mem_rd 
port map (
    clk =>clk,
    reset =>wea,
    ready=>ready_rd,
    addra =>addr_rd,
    done =>rd_done
 );
 
 --mode<="00" when pols_ready='0' else "01";
 wea<=not wr_done;
 addr<=addr_wr when wr_done='0' else addr_rd(logn downto 0);
 --ready<=ready_wr when wr_done='0' else ready_rd;
 
 
 --------------------------------------
omega_read_wrapper : w_mem_wrapper 
port map (
    clka =>clk,
    addra =>addr_rd,
    --dina=>pols,
    ena=>wr_done,
    douta=>omega
 );
---------------------------------------------
pol_mult_uut : pol_mult 
    port map ( 
               clk => clk,
               a=>pols_buf,
               w=>omega,
               reset =>reset,
               ena =>ready_rd,
               busy=>start_add,
               c=> pol_mult_op
               );
 not_start_add<=not start_add;
               
poly_adder_uut : coeff_adder 
    Port map (
           clk =>clk,
           coeff =>pol_mult_op,
           reset =>not_start_add,
           adder_op => pol_op,
           done =>done
           );

end Behavioral;
