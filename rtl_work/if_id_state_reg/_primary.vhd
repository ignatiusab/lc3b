library verilog;
use verilog.vl_types.all;
library work;
entity if_id_state_reg is
    port(
        clk             : in     vl_logic;
        load_if_id      : in     vl_logic;
        i_cache_stall   : in     vl_logic;
        branch_stall    : in     vl_logic;
        if_id_pc_in     : in     vl_logic_vector(15 downto 0);
        if_id_pc_out    : out    vl_logic_vector(15 downto 0);
        if_id_branch_prediction_in: in     vl_logic;
        if_id_branch_prediction_out: out    vl_logic;
        if_id_predictor_in: in     vl_logic;
        if_id_predictor_out: out    vl_logic;
        if_id_btb_target_pc_in: in     vl_logic_vector(15 downto 0);
        if_id_btb_target_pc_out: out    vl_logic_vector(15 downto 0);
        if_id_flush_pc_in: in     vl_logic_vector(15 downto 0);
        if_id_flush_pc_out: out    vl_logic_vector(15 downto 0);
        flush           : in     vl_logic;
        ir_input        : in     vl_logic_vector(15 downto 0);
        opcode          : out    work.lc3b_types.lc3b_opcode;
        dest            : out    vl_logic_vector(2 downto 0);
        sr1             : out    vl_logic_vector(2 downto 0);
        sr2             : out    vl_logic_vector(2 downto 0);
        offset6         : out    vl_logic_vector(5 downto 0);
        trapvect8       : out    vl_logic_vector(7 downto 0);
        offset9         : out    vl_logic_vector(8 downto 0);
        offset11        : out    vl_logic_vector(10 downto 0);
        imm5            : out    vl_logic_vector(4 downto 0);
        imm4            : out    vl_logic_vector(3 downto 0);
        bit5            : out    vl_logic;
        bit4            : out    vl_logic;
        bit11           : out    vl_logic;
        is_nop          : out    vl_logic
    );
end if_id_state_reg;
