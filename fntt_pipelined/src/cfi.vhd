library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.variant_pkg.all;
entity cfi is
    Port (
        clk          : in  std_logic;
        rst : in STD_LOGIC;
        rd_en        : in  std_logic;
        wr_t2        : in  std_logic;
        wr_t3         : in  std_logic;
        barrett_rst  : in  std_logic;
        barrett_start  : in  std_logic;
        barrett_done  : in  std_logic;
        wr_en         : in  std_logic;
        poly_mem_ce  : in  std_logic;
        uv_rst    : in  std_logic;
        cfi_fault  : out  std_logic
    );
end cfi;

architecture Behavioral of cfi is
    signal shift_reg : std_logic_vector(3 downto 0) := (others => '0');
    signal fault_cwr : std_logic_vector(3 downto 0) := (others => '0');
    --signal loop_counter   : integer range 0 to max_loop := 0;
    signal uv_wr    : std_logic := '0';
    signal barrett_ctrl    : std_logic := '0';
    signal barrett_cfi_fault  :  std_logic;
    signal uv_cfi_fault  :  std_logic;
    signal mem_cfi_fault  :  std_logic;
begin
    uv_wr<= wr_en and (not uv_rst);
    
    --barrett_ctrl<=rd_en or  wr_t2 or wr_t3 or uv_wr;
--    barrett_cfi_fault <= '0' when (barrett_start = (not barrett_rst)  and poly_mem_ce = '1' and barrett_done=wr_en) else
--                         '0' when (poly_mem_ce = '0' and barrett_done=wr_en ) else
--                         '1';
    barrett_cfi_fault <= '0' when (barrett_start = (not barrett_rst)  and (wr_t2 = '1' or wr_t3 = '1')  and barrett_done=wr_en) and rst='0'else
                         '0' when rst='1' else
                         '0' when wr_t2 = '0' and wr_t3 = '0' else
                         '1';
                     
--    mem_cfi_fault <= '0' when fault_cwr(3)=shift_reg(3) and fault_cwr(0)=shift_reg(0) and poly_mem_ce=barrett_ctrl and loop_counter <max_loop+1 else
--                     '1';
    mem_cfi_fault <= '0' when fault_cwr(3)=shift_reg(3) and fault_cwr(0)=shift_reg(0) else-- and loop_counter <max_loop+1 else
                     '1';                 
    uv_cfi_fault <= '0' when fault_cwr(0)=shift_reg(0) else
                     '1';
    process(clk)
    begin
        if rising_edge(clk) then
                fault_cwr<= rd_en & wr_t2 & wr_t3 & uv_wr;
                if rd_en = '0' then
                     shift_reg <= '0' & shift_reg(3 downto 1);  -- Right shift with '0' into MSB
                     --loop_counter<=0;
                 elsif rd_en = '1' then
                    shift_reg <= '1' & shift_reg(3 downto 1);  -- Right shift with '1' into MSB
                    --loop_counter <= loop_counter + 1;
                end if;
            end if;
        --end if;
    end process;

  cfi_fault<=barrett_cfi_fault and uv_cfi_fault and mem_cfi_fault;

end Behavioral;
