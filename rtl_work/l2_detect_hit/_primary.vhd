library verilog;
use verilog.vl_types.all;
entity l2_detect_hit is
    port(
        tag             : in     vl_logic_vector(4 downto 0);
        tag0            : in     vl_logic_vector(4 downto 0);
        tag1            : in     vl_logic_vector(4 downto 0);
        tag2            : in     vl_logic_vector(4 downto 0);
        tag3            : in     vl_logic_vector(4 downto 0);
        valid0          : in     vl_logic;
        valid1          : in     vl_logic;
        valid2          : in     vl_logic;
        valid3          : in     vl_logic;
        hit0            : out    vl_logic;
        hit1            : out    vl_logic;
        hit2            : out    vl_logic;
        hit3            : out    vl_logic
    );
end l2_detect_hit;
