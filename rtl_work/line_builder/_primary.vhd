library verilog;
use verilog.vl_types.all;
entity line_builder is
    port(
        mem_wdata       : in     vl_logic_vector(15 downto 0);
        mem_byte_enable : in     vl_logic_vector(1 downto 0);
        offset          : in     vl_logic_vector(2 downto 0);
        data_in         : in     vl_logic_vector(127 downto 0);
        new_line        : out    vl_logic_vector(127 downto 0)
    );
end line_builder;
