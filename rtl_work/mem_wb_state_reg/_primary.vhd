library verilog;
use verilog.vl_types.all;
library work;
entity mem_wb_state_reg is
    port(
        clk             : in     vl_logic;
        load_mem_wb     : in     vl_logic;
        flush           : in     vl_logic;
        mem_wb_branch_prediction_in: in     vl_logic;
        mem_wb_branch_prediction_out: out    vl_logic;
        mem_wb_predictor_in: in     vl_logic;
        mem_wb_predictor_out: out    vl_logic;
        mem_wb_flush_pc_in: in     vl_logic_vector(15 downto 0);
        mem_wb_flush_pc_out: out    vl_logic_vector(15 downto 0);
        mem_wb_take_jump_in: in     vl_logic;
        mem_wb_take_jump_out: out    vl_logic;
        mem_wb_pc_in    : in     vl_logic_vector(15 downto 0);
        mem_wb_pc_out   : out    vl_logic_vector(15 downto 0);
        mem_wb_pc_mux_in: in     vl_logic_vector(15 downto 0);
        mem_wb_pc_mux_out: out    vl_logic_vector(15 downto 0);
        mem_wb_check_target_in: in     vl_logic;
        mem_wb_check_target_out: out    vl_logic;
        mem_wb_cntrl_in : in     work.lc3b_types.lc3b_control_word;
        mem_wb_cntrl_out: out    work.lc3b_types.lc3b_control_word;
        mem_wb_dest_in  : in     vl_logic_vector(2 downto 0);
        mem_wb_dest_out : out    vl_logic_vector(2 downto 0);
        mem_wb_is_nop_in: in     vl_logic;
        mem_wb_is_nop_out: out    vl_logic;
        mem_wb_regfile_in: in     vl_logic_vector(15 downto 0);
        mem_wb_regfile_out: out    vl_logic_vector(15 downto 0)
    );
end mem_wb_state_reg;
