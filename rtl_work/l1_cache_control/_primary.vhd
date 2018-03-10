library verilog;
use verilog.vl_types.all;
entity l1_cache_control is
    port(
        clk             : in     vl_logic;
        dirty0          : in     vl_logic;
        dirty1          : in     vl_logic;
        hit0            : in     vl_logic;
        hit1            : in     vl_logic;
        lru             : in     vl_logic;
        data_in_mux_sel : out    vl_logic;
        l2_mem_address_mux_sel: out    vl_logic_vector(1 downto 0);
        lru_w           : out    vl_logic;
        dirty0_w        : out    vl_logic;
        valid0_w        : out    vl_logic;
        tag0_w          : out    vl_logic;
        data0_w         : out    vl_logic;
        dirty1_w        : out    vl_logic;
        valid1_w        : out    vl_logic;
        tag1_w          : out    vl_logic;
        data1_w         : out    vl_logic;
        mem_read        : in     vl_logic;
        mem_write       : in     vl_logic;
        mem_resp        : out    vl_logic;
        l2_mem_resp     : in     vl_logic;
        l2_mem_write    : out    vl_logic;
        l2_mem_read     : out    vl_logic;
        cache_hit       : out    vl_logic;
        cache_miss      : out    vl_logic
    );
end l1_cache_control;
