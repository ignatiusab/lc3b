import lc3b_types::*;

module mem_wb_state_reg
(
    input clk,
	 input load_mem_wb,
	 input flush,
	 
	 input logic				mem_wb_branch_prediction_in,
	 output logic				mem_wb_branch_prediction_out,
	 
	 input logic				mem_wb_predictor_in,
	 output logic				mem_wb_predictor_out,
	 input lc3b_word			mem_wb_flush_pc_in,
	 output lc3b_word			mem_wb_flush_pc_out,
	 
	  input logic				mem_wb_take_jump_in,
	 output logic				mem_wb_take_jump_out,
	 
	 input lc3b_word mem_wb_pc_in,
	 output lc3b_word mem_wb_pc_out,
	 
	 input lc3b_word mem_wb_pc_mux_in,
	 output lc3b_word mem_wb_pc_mux_out,
	 
	 input logic mem_wb_check_target_in,
	 output logic mem_wb_check_target_out,
	 
//	 input lc3b_word mem_wb_pc_adder_in,
//	 output lc3b_word mem_wb_pc_adder_out,
	 
//	 input lc3b_word mem_wb_dmdr_in,
//	 output lc3b_word mem_wb_dmdr_out,
	 
//	 input lc3b_word mem_wb_alu_in,
//	 output lc3b_word mem_wb_alu_out,
	 
//	 input lc3b_nzp mem_wb_ir_nzp_in,
//	 output lc3b_nzp mem_wb_ir_nzp_out,
	
	 input lc3b_control_word mem_wb_cntrl_in,
	 output lc3b_control_word mem_wb_cntrl_out,
	 
	 input lc3b_reg mem_wb_dest_in,
	 output lc3b_reg mem_wb_dest_out,
	 
	 input logic mem_wb_is_nop_in,
	 output logic mem_wb_is_nop_out,
	 
	 input lc3b_word mem_wb_regfile_in,
	 output lc3b_word mem_wb_regfile_out
	 
);

state_register #(.width(1)) mem_wb_branch_prediction_reg
(
	.clk,
	.load(load_mem_wb),
	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
	.in(mem_wb_branch_prediction_in),
	.out(mem_wb_branch_prediction_out)
);
state_register #(.width(1)) mem_wb_predictor_reg
(
	.clk,
	.load(load_mem_wb),
	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
	.in(mem_wb_predictor_in),
	.out(mem_wb_predictor_out)
);
state_register #(.width(1)) mem_wb_take_jump_reg
(
	.clk,
	.load(load_mem_wb),
	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
	.in(mem_wb_take_jump_in),
	.out(mem_wb_take_jump_out)
);

state_register #(.width(16)) mem_wb_flush_pc_reg
(
	.clk,
	.load(load_mem_wb),
	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
	.in(mem_wb_flush_pc_in),
	.out(mem_wb_flush_pc_out)
);

state_register mem_wb_pc
(
	.clk,
	.load(load_mem_wb),
	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
	.in(mem_wb_pc_in),
	.out(mem_wb_pc_out)
);



state_register mem_wb_pc_mux
(
	.clk,
	.load(load_mem_wb),
	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
	.in(mem_wb_pc_mux_in),
	.out(mem_wb_pc_mux_out)
);

state_register #(.width(1)) check_target
(
	.clk,
	.load(load_mem_wb),
	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
	.in(mem_wb_check_target_in),
	.out(mem_wb_check_target_out)
);
//state_register mem_wb_pc_adder
//(
//	.clk,
//	.load(load_mem_wb),
//	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
//	.in(mem_wb_pc_adder_in),
//	.out(mem_wb_pc_adder_out)
//);
//
//state_register mem_wb_dmdr
//(
//	.clk,
//	.load(load_mem_wb),
//	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
//	.in(mem_wb_dmdr_in),
//	.out(mem_wb_dmdr_out)
//);

//state_register mem_wb_alu
//(
//	.clk,
//	.load(load_mem_wb),
//	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
//	.in(mem_wb_alu_in),
//	.out(mem_wb_alu_out)
//);
//
//state_register #(.width(3)) mem_wb_ir_nzp
//(
//	.clk,
//	.load(load_mem_wb),
//	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
//	.in(mem_wb_ir_nzp_in),
//	.out(mem_wb_ir_nzp_out)
//);

state_register #(.width($bits(lc3b_reg))) mem_wb_dest
(
	.clk,
	.load(load_mem_wb),
	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
	.in(mem_wb_dest_in),
	.out(mem_wb_dest_out)
);

state_register #(.width($bits(lc3b_control_word))) mem_wb_cntrl 
(
	.clk,
	.load(load_mem_wb),
	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
	.in(mem_wb_cntrl_in),
	.out(mem_wb_cntrl_out)
);

nop_register #(.width(1)) mem_wb_is_nop
(
	.clk,
	.load(load_mem_wb),
	.in(mem_wb_is_nop_in | flush),
	.out(mem_wb_is_nop_out)
);

state_register #(.width($bits(lc3b_word))) mem_wb_regfile
(
	.clk,
	.load(load_mem_wb),
	.flush(flush & ~(mem_wb_cntrl_in.is_uncond_control || mem_wb_cntrl_in.opcode == op_br)),
	.in(mem_wb_regfile_in),
	.out(mem_wb_regfile_out)
);

endmodule : mem_wb_state_reg