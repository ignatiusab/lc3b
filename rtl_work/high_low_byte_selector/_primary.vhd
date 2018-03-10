library verilog;
use verilog.vl_types.all;
entity high_low_byte_selector is
    generic(
        width           : integer := 8
    );
    port(
        sel             : in     vl_logic;
        \in\            : in     vl_logic_vector(7 downto 0);
        \out\           : out    vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end high_low_byte_selector;
