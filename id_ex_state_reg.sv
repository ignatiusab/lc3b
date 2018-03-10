import lc3b_types::*;

module id_ex_state_reg
(
    input clk,
	 input logic			load_id_ex,
	 
	 input logic				id_ex_branch_prediction_in,
	 output logic				id_ex_branch_prediction_out,
	 input logic				id_ex_predictor_in,
	 output logic				id_ex_predictor_out,
	 input lc3b_word			id_ex_flush_pc_in,
	 output lc3b_word			id_ex_flush_pc_out,
	 input lc3b_word				id_ex_btb_target_pc_in,
	 output lc3b_word				id_ex_btb_target_pc_out,	 
	 input lc3b_word 		id_ex_pc_in,
	 output lc3b_word 	id_ex_pc_out,
	 
	 input lc3b_word 		id_ex_zextvect8_in, id_ex_zext4_in, id_ex_sext5_in, 
								id_ex_off6_in, id_ex_adj_9_11_in, id_ex_sr1_in, id_ex_sr2_in,

	 output lc3b_word 	id_ex_zextvect8_out, id_ex_zext4_out, id_ex_sext5_out, 
								id_ex_off6_out, id_ex_adj_9_11_out, id_ex_sr1_out, id_ex_sr2_out,
						  
	 input lc3b_nzp 		id_ex_ir_nzp_in,
	 output lc3b_nzp 		id_ex_ir_nzp_out,
	 
	 input lc3b_control_word 	id_ex_cntrl_in,
	 output lc3b_control_word 	id_ex_cntrl_out,
	 
	 input lc3b_reg id_ex_dest_in,
	 output lc3b_reg id_ex_dest_out,
	 
	 input lc3b_reg id_ex_sr1_id_in,
	 output lc3b_reg id_ex_sr1_id_out,
	 
	 input lc3b_reg id_ex_sr2_id_in,
	 output lc3b_reg id_ex_sr2_id_out,
	 
	 input logic id_ex_is_nop_in,
	 output logic id_ex_is_nop_out,
	 
	 input logic flush
);

state_register #(.width(1)) id_ex_branch_prediction_reg
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_branch_prediction_in),
	.out(id_ex_branch_prediction_out)
);


state_register #(.width(1)) id_ex_predictor_reg
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_predictor_in),
	.out(id_ex_predictor_out)
);

state_register #(.width(16)) id_ex_btb_target_pc_reg
(
	.clk,
	.flush,
	.load(load_id_ex),
	.in(id_ex_btb_target_pc_in),
	.out(id_ex_btb_target_pc_out)
);
state_register #(.width(16)) id_ex_flush_pc_reg
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_flush_pc_in),
	.out(id_ex_flush_pc_out)
);


state_register id_ex_pc
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_pc_in),
	.out(id_ex_pc_out)
);

state_register id_ex_zextvect8
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_zextvect8_in),
	.out(id_ex_zextvect8_out)
);

state_register id_ex_zext4
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_zext4_in),
	.out(id_ex_zext4_out)
);

state_register id_ex_sext5
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_sext5_in),
	.out(id_ex_sext5_out)
);

state_register id_ex_off6
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_off6_in),
	.out(id_ex_off6_out)
);

state_register id_ex_adj_9_11
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_adj_9_11_in),
	.out(id_ex_adj_9_11_out)
);

state_register id_ex_sr1
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_sr1_in),
	.out(id_ex_sr1_out)
);

state_register id_ex_sr2
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_sr2_in),
	.out(id_ex_sr2_out)
);

state_register #(.width(3)) id_ex_ir_nzp
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_ir_nzp_in),
	.out(id_ex_ir_nzp_out)
);

state_register #(.width($bits(lc3b_reg))) id_ex_dest
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_dest_in),
	.out(id_ex_dest_out)
);

state_register #(.width($bits(lc3b_control_word))) id_ex_cntrl
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_cntrl_in),
	.out(id_ex_cntrl_out)
);

state_register #(.width($bits(lc3b_reg))) id_ex_sr1_id
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_sr1_id_in),
	.out(id_ex_sr1_id_out)
);

state_register #(.width($bits(lc3b_reg))) id_ex_sr2_id
(
	.clk,
	.load(load_id_ex),
	.flush,
	.in(id_ex_sr2_id_in),
	.out(id_ex_sr2_id_out)
);

nop_register #(.width(1)) id_ex_is_nop
(
	.clk,
	.load(load_id_ex),
	.in(id_ex_is_nop_in | flush),
	.out(id_ex_is_nop_out)
);

endmodule : id_ex_state_reg