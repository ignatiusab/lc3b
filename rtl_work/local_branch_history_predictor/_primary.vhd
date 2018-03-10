library verilog;
use verilog.vl_types.all;
entity local_branch_history_predictor is
    port(
        clk             : in     vl_logic;
        wb_take_jump    : in     vl_logic;
        update_branch_history: in     vl_logic;
        lookup_pc       : in     vl_logic_vector(15 downto 0);
        resolved_pc     : in     vl_logic_vector(15 downto 0);
        predict_taken   : out    vl_logic
    );
end local_branch_history_predictor;
