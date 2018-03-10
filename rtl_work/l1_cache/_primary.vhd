library verilog;
use verilog.vl_types.all;
entity l1_cache is
    port(
        clk             : in     vl_logic;
        mem_read        : in     vl_logic;
        mem_write       : in     vl_logic;
        mem_address     : in     vl_logic_vector(15 downto 0);
        mem_wdata       : in     vl_logic_vector(15 downto 0);
        mem_byte_enable : in     vl_logic_vector(1 downto 0);
        mem_resp        : out    vl_logic;
        mem_rdata       : out    vl_logic_vector(15 downto 0);
        l2_mem_resp     : in     vl_logic;
        l2_mem_rdata    : in     vl_logic_vector(127 downto 0);
        l2_mem_read     : out    vl_logic;
        l2_mem_write    : out    vl_logic;
        l2_mem_address  : out    vl_logic_vector(15 downto 0);
        l2_mem_wdata    : out    vl_logic_vector(127 downto 0);
        cache_hit       : out    vl_logic;
        cache_miss      : out    vl_logic
    );
end l1_cache;
