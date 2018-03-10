library verilog;
use verilog.vl_types.all;
entity detect_hit is
    port(
        tag             : in     vl_logic_vector(7 downto 0);
        tag0            : in     vl_logic_vector(7 downto 0);
        tag1            : in     vl_logic_vector(7 downto 0);
        valid0          : in     vl_logic;
        valid1          : in     vl_logic;
        hit0            : out    vl_logic;
        hit1            : out    vl_logic
    );
end detect_hit;
