import lc3b_types::*;

module ex_mem_state_reg
(
    input clk,
	 input load_ex_mem,
	 input flush,
	 
	  input logic				ex_mem_branch_prediction_in,
	 output logic				ex_mem_branch_prediction_out,
	 
	   input logic				ex_mem_predictor_in,
	 output logic				ex_mem_predictor_out,
	 
	 input lc3b_word				ex_mem_btb_target_pc_in,
	 output lc3b_word				ex_mem_btb_target_pc_out,
	 
	 input lc3b_word			ex_mem_flush_pc_in,
	 output lc3b_word			ex_mem_flush_pc_out,
	 
    input lc3b_word ex_mem_pc_in, ex_mem_pc_adder_in,ex_mem_zextvect8_in, ex_mem_alu_in, ex_mem_sr1_in, ex_mem_sr2_in,
	 output lc3b_word ex_mem_pc_out, ex_mem_pc_adder_out, ex_mem_zextvect8_out, ex_mem_alu_out, ex_mem_sr1_out, ex_mem_sr2_out,
	 
	 input lc3b_nzp ex_mem_ir_nzp_in,
	 output lc3b_nzp ex_mem_ir_nzp_out,
	 
	 input lc3b_control_word ex_mem_cntrl_in,
	 output lc3b_control_word ex_mem_cntrl_out,
	 
	 input lc3b_reg ex_mem_dest_in,
	 output lc3b_reg ex_mem_dest_out,
	 
	 input lc3b_reg ex_mem_sr2_id_in,
	 output lc3b_reg ex_mem_sr2_id_out,
	 
	 input logic ex_mem_is_nop_in,
	 output logic ex_mem_is_nop_out
);

state_register #(.width(1)) ex_mem_branch_prediction_reg
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_branch_prediction_in),
	.out(ex_mem_branch_prediction_out)
);

state_register #(.width(1)) ex_mem_predictor_reg
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_predictor_in),
	.out(ex_mem_predictor_out)
);


state_register #(.width(16)) ex_mem_btb_target_pc_reg
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_btb_target_pc_in),
	.out(ex_mem_btb_target_pc_out)
);
state_register #(.width(16)) ex_mem_flush_pc_reg
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_flush_pc_in),
	.out(ex_mem_flush_pc_out)
);

state_register ex_mem_pc
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_pc_in),
	.out(ex_mem_pc_out)
);

state_register ex_mem_sr1
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_sr1_in),
	.out(ex_mem_sr1_out)
);

state_register ex_mem_sr2
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_sr2_in),
	.out(ex_mem_sr2_out)
);

state_register ex_mem_pc_adder
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_pc_adder_in),
	.out(ex_mem_pc_adder_out)
);

state_register ex_mem_zextvect8
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_zextvect8_in),
	.out(ex_mem_zextvect8_out)
);

state_register #(.width(3)) ex_mem_ir_nzp
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_ir_nzp_in),
	.out(ex_mem_ir_nzp_out)
);

state_register ex_mem_alu
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_alu_in),
	.out(ex_mem_alu_out)
);

state_register #(.width($bits(lc3b_reg))) ex_mem_dest
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_dest_in),
	.out(ex_mem_dest_out)
);

state_register #(.width($bits(lc3b_reg))) ex_mem_sr2_id
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_sr2_id_in),
	.out(ex_mem_sr2_id_out)
);

state_register #(.width($bits(lc3b_control_word))) ex_mem_cntrl
(
	.clk,
	.load(load_ex_mem),
	.flush,
	.in(ex_mem_cntrl_in),
	.out(ex_mem_cntrl_out)
);

nop_register #(.width(1)) ex_mem_is_nop
(
	.clk,
	.load(load_ex_mem),
	.in(ex_mem_is_nop_in | flush),
	.out(ex_mem_is_nop_out)
);
endmodule : ex_mem_state_reg
