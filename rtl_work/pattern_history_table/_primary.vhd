library verilog;
use verilog.vl_types.all;
entity pattern_history_table is
    port(
        clk             : in     vl_logic;
        update_pattern  : in     vl_logic;
        lookup_pc       : in     vl_logic_vector(15 downto 0);
        wb_take_jump    : in     vl_logic;
        resolved_pc     : in     vl_logic_vector(15 downto 0);
        history         : in     vl_logic_vector(3 downto 0);
        predict_taken   : out    vl_logic
    );
end pattern_history_table;
