library verilog;
use verilog.vl_types.all;
library work;
entity branch_predictor is
    port(
        clk             : in     vl_logic;
        opcode          : in     vl_logic_vector(3 downto 0);
        pc_offset_sign  : in     vl_logic;
        take_jump       : in     vl_logic;
        wb_take_jump    : in     vl_logic;
        wb_predict_taken: in     vl_logic;
        wb_predictor    : in     vl_logic;
        mem_opcode      : in     work.lc3b_types.lc3b_opcode;
        mem_predict_taken: in     vl_logic;
        mem_is_nop      : in     vl_logic;
        bad_uncond_jump : in     vl_logic;
        if_btb_hit      : in     vl_logic;
        lookup_pc       : in     vl_logic_vector(15 downto 0);
        resolved_pc     : in     vl_logic_vector(15 downto 0);
        update_branch_history: in     vl_logic;
        br_is_uncond    : out    vl_logic;
        flush           : out    vl_logic;
        flush_pc_sel    : out    vl_logic;
        predict_taken   : out    vl_logic;
        predictor       : out    vl_logic
    );
end branch_predictor;
