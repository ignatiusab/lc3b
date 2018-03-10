import lc3b_types::*;

module btb_entry
(
	input logic clk,
	input logic write,
	input lc3b_word lookup_pc_in,
	output lc3b_word lookup_pc_out,
	
	input lc3b_word predicted_pc_in,
	output lc3b_word predicted_pc_out
	
	//input logic taken_in,
	//output logic taken_out

);

btb_register 	lookup_pc
(
	.clk,
	.load(write),
	.in(lookup_pc_in),
	.out(lookup_pc_out)
);

register 	predicted_pc
(
	.clk,
	.load(write),
	.in(predicted_pc_in),
	.out(predicted_pc_out)
);

endmodule: btb_entry