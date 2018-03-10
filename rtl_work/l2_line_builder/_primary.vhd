library verilog;
use verilog.vl_types.all;
entity l2_line_builder is
    port(
        mem_wdata       : in     vl_logic_vector(127 downto 0);
        offset          : in     vl_logic;
        data_in         : in     vl_logic_vector(255 downto 0);
        new_line        : out    vl_logic_vector(255 downto 0)
    );
end l2_line_builder;
