import lc3b_types::*;

module global_branch_history_predictor
(
	input clk,
	input logic wb_take_jump,
	input logic update_branch_history,
	input lc3b_word lookup_pc, resolved_pc,
	output logic predict_taken
);

logic [3:0] global_history_out;

shift_register #(.width(4)) global_history_reg
(
	.clk,
	.load(update_branch_history),
	.in(wb_take_jump),
	.out(global_history_out)
);

pattern_history_table pattern_history_table
(
	.clk,
	.update_pattern(update_branch_history),
	.wb_take_jump,
	.lookup_pc(lookup_pc),
	.resolved_pc(resolved_pc),
	.history(global_history_out),
	.predict_taken
);

endmodule : global_branch_history_predictor