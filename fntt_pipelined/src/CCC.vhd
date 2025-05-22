library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.variant_pkg.all;
entity ccc is
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
        ccc_fault  : out  std_logic
    );
end ccc;

architecture Behavioral of ccc is
    signal shift_reg : std_logic_vector(3 downto 0) := (others => '0');
    signal fault_cwr : std_logic_vector(3 downto 0) := (others => '0');
    signal rd_loop_counter   : integer range 0 to max_loop := 0;
    signal wr_loop_counter   : integer range 0 to max_loop := 0;
    signal mem_ce_loop_counter   : integer range 0 to max_loop := 0;
    signal uv_rst_loop_counter   : integer range 0 to max_loop := 0;
    signal b_rst_loop_counter   : integer range 0 to max_loop := 0;
    signal b_strt_loop_counter   : integer range 0 to max_loop := 0;
    signal b_done_loop_counter   : integer range 0 to max_loop := 0;
    signal uv_wr    : std_logic := '0';
    signal barrett_ctrl    : std_logic := '0';
    signal barrett_ccc_fault  :  std_logic;
    signal uv_ccc_fault  :  std_logic;
    signal mem_ccc_fault  :  std_logic;
begin
    uv_wr<= wr_en and (not uv_rst);
    
    --barrett_ctrl<=rd_en or  wr_t2 or wr_t3 or uv_wr;
--    barrett_cfi_fault <= '0' when (barrett_start = (not barrett_rst)  and poly_mem_ce = '1' and barrett_done=wr_en) else
--                         '0' when (poly_mem_ce = '0' and barrett_done=wr_en ) else
--                         '1';
    barrett_ccc_fault <=  '0' when b_rst_loop_counter <max_loop+2 and b_strt_loop_counter <max_loop+2 and b_done_loop_counter <max_loop else
                         '1'; 
                     
--    mem_cfi_fault <= '0' when fault_cwr(3)=shift_reg(3) and fault_cwr(0)=shift_reg(0) and poly_mem_ce=barrett_ctrl and loop_counter <max_loop+1 else
--                     '1';
    mem_ccc_fault <= '0' when rd_loop_counter <max_loop+1 and wr_loop_counter <max_loop+1 and mem_ce_loop_counter <max_loop+4 else
                     '1';                 
    uv_ccc_fault <= '0' when uv_rst_loop_counter <max_loop+1 else
                     '1';
    process(clk)
    begin
        if rising_edge(clk) then
                if rd_en = '0' then
                     rd_loop_counter<=0;
                 elsif rd_en = '1' then
                    rd_loop_counter <= rd_loop_counter + 1;
                end if;
                
                if wr_en = '0' then
                     wr_loop_counter<=0;
                 elsif wr_en = '1' then
                    wr_loop_counter <= wr_loop_counter + 1;
                end if;
                
                
                if poly_mem_ce = '0' then
                    mem_ce_loop_counter<=0;
                 elsif poly_mem_ce = '1' then
                   mem_ce_loop_counter <= mem_ce_loop_counter + 1;
                end if;
                
                 if uv_rst = '1' then
                    uv_rst_loop_counter<=0;
                 elsif uv_rst = '0' then
                   uv_rst_loop_counter <= uv_rst_loop_counter + 1;
                end if;
                
                 if barrett_rst = '1' then
                    b_rst_loop_counter<=0;
                 elsif barrett_rst = '0' then
                   b_rst_loop_counter <= b_rst_loop_counter + 1;
                end if;
                
                if barrett_start = '0' then
                    b_strt_loop_counter<=0;
                 elsif barrett_start = '1' then
                   b_strt_loop_counter <= b_strt_loop_counter + 1;
                end if;
                
               if barrett_done = '0' then
                    b_done_loop_counter<=0;
                 elsif barrett_done = '1' then
                   b_done_loop_counter <= b_done_loop_counter + 1;
                end if;
                
            end if;
        --end if;
    end process;

  ccc_fault<=barrett_ccc_fault and uv_ccc_fault and mem_ccc_fault;

end Behavioral;
