library verilog;
use verilog.vl_types.all;
entity l2_cache is
    port(
        clk             : in     vl_logic;
        mem_read        : in     vl_logic;
        mem_write       : in     vl_logic;
        mem_address     : in     vl_logic_vector(15 downto 0);
        mem_wdata       : in     vl_logic_vector(127 downto 0);
        mem_resp        : out    vl_logic;
        mem_rdata       : out    vl_logic_vector(127 downto 0);
        pmem_resp       : in     vl_logic;
        pmem_rdata      : in     vl_logic_vector(255 downto 0);
        pmem_read       : out    vl_logic;
        pmem_write      : out    vl_logic;
        pmem_address    : out    vl_logic_vector(15 downto 0);
        pmem_wdata      : out    vl_logic_vector(255 downto 0);
        cache_hit       : out    vl_logic;
        cache_miss      : out    vl_logic
    );
end l2_cache;
