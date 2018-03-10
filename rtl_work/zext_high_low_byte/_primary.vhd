library verilog;
use verilog.vl_types.all;
entity zext_high_low_byte is
    port(
        sel             : in     vl_logic;
        \in\            : in     vl_logic_vector(15 downto 0);
        \out\           : out    vl_logic_vector(15 downto 0)
    );
end zext_high_low_byte;
