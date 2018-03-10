import lc3b_types::*;

module if_id_state_reg
(
    input clk,
		
	 input logic 				load_if_id,
	 input logic				i_cache_stall,
	 input logic				branch_stall,
	 //input logic				branch_resolved,
    input lc3b_word 			if_id_pc_in,
	 output lc3b_word 		if_id_pc_out,
	 
	 input logic				if_id_branch_prediction_in,
	 output logic				if_id_branch_prediction_out,
	 
	 input logic				if_id_predictor_in,
	 output logic				if_id_predictor_out,
	 
	 input lc3b_word				if_id_btb_target_pc_in,
	 output lc3b_word				if_id_btb_target_pc_out,
	 
	 input lc3b_word			if_id_flush_pc_in,
	 output lc3b_word			if_id_flush_pc_out,
	 
	 input logic				flush,
	 
	 input lc3b_word 			ir_input,
	 //input load_ir,
	
	 
	 output lc3b_opcode 		opcode,
    output lc3b_reg 			dest, sr1, sr2,
    output lc3b_offset6 	offset6,
	 output lc3b_trapvect8 	trapvect8,
    output lc3b_offset9 	offset9,
	 output lc3b_offset11 	offset11,
	 output lc3b_imm5			imm5,
	 output lc3b_imm4 		imm4,
	 output logic 				bit5, bit4, bit11,
	 output logic				is_nop
	
	 
);

lc3b_word ir_in, if_id_pc_reg_in;

state_register #(.width(1)) if_id_branch_prediction_reg
(
	.clk,
	.flush,
	.load(load_if_id),
	.in(if_id_branch_prediction_in),
	.out(if_id_branch_prediction_out)
);

state_register #(.width(1)) if_id_predictor_reg
(
	.clk,
	.flush,
	.load(load_if_id),
	.in(if_id_predictor_in),
	.out(if_id_predictor_out)
);

state_register #(.width(16)) if_id_btb_target_pc_reg
(
	.clk,
	.flush,
	.load(load_if_id),
	.in(if_id_btb_target_pc_in),
	.out(if_id_btb_target_pc_out)
);

state_register #(.width(16)) if_id_flush_pc_reg
(
	.clk,
	.load(load_if_id),
	.flush,
	.in(if_id_flush_pc_in),
	.out(if_id_flush_pc_out)
);

state_register if_id_pc
(
	.clk,
	.load(load_if_id),
	.flush,
	.in(if_id_pc_reg_in),
	.out(if_id_pc_out)
	//.out(if_id_pc_reg_out)
);

mux2 #(.width($bits(lc3b_word))) pc_reg
(
	.sel((i_cache_stall | branch_stall) | flush),
	.a(if_id_pc_in),
	.b(16'd0),
	.f(if_id_pc_reg_in)
);

mux2 #(.width($bits(lc3b_word))) ir_in_reg
(
	//.sel(1'b0),
	.sel((i_cache_stall | branch_stall) | flush),
	.a(ir_input),
	.b(16'd0),
	.f(ir_in)
);


ir instr_reg
(
	.clk,
	.load(load_if_id),
	.in(ir_in), //From MDR output
	.opcode,
	.dest(dest),
	.src1(sr1),
	.src2(sr2),
	.offset6,
	.trapvect8,
	.offset9,
	.offset11,
	.imm5,
	.imm4,
	.imm5_bit(bit5),
	.imm4_bit(bit4),
	.instr_bit11(bit11)
);

logic is_nop_in;
nop_register #(.width(1)) is_nop_reg
(
	.clk,
	.load(load_if_id),
	.in(is_nop_in),
	.out(is_nop)
);
always_comb
begin

	if(ir_in == 16'd0)
		is_nop_in = 1;
	else
		is_nop_in = 0;
end

endmodule : if_id_state_reg
