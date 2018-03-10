library verilog;
use verilog.vl_types.all;
entity perf_counters is
    port(
        clk             : in     vl_logic;
        address         : in     vl_logic_vector(15 downto 0);
        clear           : in     vl_logic;
        counter_rdata   : out    vl_logic_vector(15 downto 0);
        i_cache_hit     : in     vl_logic;
        i_cache_miss    : in     vl_logic;
        d_cache_hit     : in     vl_logic;
        d_cache_miss    : in     vl_logic;
        l2_cache_hit    : in     vl_logic;
        l2_cache_miss   : in     vl_logic;
        i_cache_stall   : in     vl_logic;
        d_cache_stall   : in     vl_logic;
        non_cond_stall  : in     vl_logic;
        br_mispredict   : in     vl_logic;
        total_branches  : in     vl_logic;
        is_instruction  : in     vl_logic
    );
end perf_counters;
