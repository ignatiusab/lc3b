library verilog;
use verilog.vl_types.all;
entity l2_cache_lru is
    port(
        clk             : in     vl_logic;
        hit0            : in     vl_logic;
        hit1            : in     vl_logic;
        hit2            : in     vl_logic;
        hit3            : in     vl_logic;
        write           : in     vl_logic;
        index           : in     vl_logic_vector(5 downto 0);
        lru_out         : out    vl_logic_vector(1 downto 0)
    );
end l2_cache_lru;
