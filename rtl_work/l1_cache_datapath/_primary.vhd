library verilog;
use verilog.vl_types.all;
entity l1_cache_datapath is
    port(
        clk             : in     vl_logic;
        data_in_mux_sel : in     vl_logic;
        l2_mem_address_mux_sel: in     vl_logic_vector(1 downto 0);
        lru_w           : in     vl_logic;
        dirty0_w        : in     vl_logic;
        valid0_w        : in     vl_logic;
        tag0_w          : in     vl_logic;
        data0_w         : in     vl_logic;
        dirty1_w        : in     vl_logic;
        valid1_w        : in     vl_logic;
        tag1_w          : in     vl_logic;
        data1_w         : in     vl_logic;
        index           : in     vl_logic_vector(3 downto 0);
        tag             : in     vl_logic_vector(7 downto 0);
        offset          : in     vl_logic_vector(2 downto 0);
        mem_address     : in     vl_logic_vector(15 downto 0);
        mem_write       : in     vl_logic;
        mem_byte_enable : in     vl_logic_vector(1 downto 0);
        mem_wdata       : in     vl_logic_vector(15 downto 0);
        mem_rdata       : out    vl_logic_vector(15 downto 0);
        l2_mem_rdata    : in     vl_logic_vector(127 downto 0);
        l2_mem_address  : out    vl_logic_vector(15 downto 0);
        l2_mem_wdata    : out    vl_logic_vector(127 downto 0);
        dirty0          : out    vl_logic;
        dirty1          : out    vl_logic;
        hit0            : out    vl_logic;
        hit1            : out    vl_logic;
        lru             : out    vl_logic
    );
end l1_cache_datapath;
