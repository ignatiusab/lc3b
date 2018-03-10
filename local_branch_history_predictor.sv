import lc3b_types::*;

module local_branch_history_predictor
(
	input clk,
	input logic wb_take_jump,
	input logic update_branch_history,
	input lc3b_word lookup_pc, resolved_pc,
	output logic predict_taken
);

logic [3:0] local_history_out;

pattern_history_table pattern_history_table
(
	.clk,
	.update_pattern(update_branch_history),
	.wb_take_jump,
	.lookup_pc(lookup_pc),
	.resolved_pc(resolved_pc),
	.history(local_history_out),
	.predict_taken
);

logic [3:0] data [15:0];
logic [3:0] read_address, write_address;

assign read_address = lookup_pc[4:1];
assign write_address = resolved_pc[4:1];

initial
begin
    for (int i = 0; i < $size(data); i++)
    begin
        data[i] = 4'b0000;
    end
end

always_ff @(posedge clk)
begin
    if (update_branch_history)
    begin
        data[write_address] = {data[write_address][2:0], wb_take_jump};
    end
end

assign local_history_out = data[read_address];

endmodule : local_branch_history_predictor