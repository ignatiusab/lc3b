library verilog;
use verilog.vl_types.all;
entity branch_target_buffer is
    port(
        clk             : in     vl_logic;
        lookup_pc       : in     vl_logic_vector(15 downto 0);
        resolved_lookup_pc: in     vl_logic_vector(15 downto 0);
        resolved_predicted_pc: in     vl_logic_vector(15 downto 0);
        check_target    : in     vl_logic;
        target_pc       : out    vl_logic_vector(15 downto 0);
        hit             : out    vl_logic
    );
end branch_target_buffer;
