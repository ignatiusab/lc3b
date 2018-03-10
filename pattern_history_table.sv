import lc3b_types::*;

module pattern_history_table
(
	input clk,
	input logic update_pattern,
	input lc3b_word lookup_pc,
	input logic wb_take_jump,
	input lc3b_word resolved_pc,
	input [3:0] history,
	
	output logic predict_taken
);

logic [3:0] read_address, write_address;
logic [1:0] data [15:0];

/**** These addresses need to be changed to appropriate values ***/
assign read_address = lookup_pc[4:1] ^ history;
assign write_address = resolved_pc[4:1] ^ history; 

initial
begin
    for (int i = 0; i < $size(data); i++)
    begin
        data[i] = 2'b10;
    end
end

always_ff @(posedge clk)
begin
    if (update_pattern == 1)
    begin
        case ({wb_take_jump, data[write_address]})
			3'b000: begin
				data[write_address] = 2'b00;
			end
			3'b001: begin
				data[write_address] = 2'b00;
			end
			3'b010: begin
				data[write_address] = 2'b01;
			end
			3'b011: begin
				data[write_address] = 2'b10;
			end
			3'b100: begin
				data[write_address] = 2'b01;
			end
			3'b101: begin
				data[write_address] = 2'b10;
			end
			3'b110: begin
				data[write_address] = 2'b11;
			end
			3'b111: begin
				data[write_address] = 2'b11;
			end
		  endcase
    end
end

assign predict_taken = data[read_address][1]; //Taken if this bit is positive


endmodule : pattern_history_table