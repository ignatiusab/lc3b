import lc3b_types::*;

module line_builder
(
	input lc3b_word mem_wdata,
	input lc3b_mem_wmask mem_byte_enable,
	input lc3b_c_offset offset,
	input lc3b_c_line data_in,
	output lc3b_c_line new_line
);

// combines mem_wdata with the current data line into a new line, must be byte addressable

always_comb
begin
	
	new_line = data_in;	// first set output to the entire input block, then rewrite new bytes
	
	case (offset)
		3'b000: begin
			if (mem_byte_enable == 2'b01)
				new_line[7:0] = mem_wdata[7:0];		// only write lower byte
			else if (mem_byte_enable == 2'b10)
				new_line[15:8] = mem_wdata[15:8];	// only write upper byte
			else
				new_line[15:0] = mem_wdata;			// write entire word
		end
		
		3'b001: begin
			if (mem_byte_enable == 2'b01)
				new_line[23:16] = mem_wdata[7:0];		// only write lower byte
			else if (mem_byte_enable == 2'b10)
				new_line[31:24] = mem_wdata[15:8];	// only write upper byte
			else
				new_line[31:16] = mem_wdata;			// write entire word
		end
		
		3'b010: begin
			if (mem_byte_enable == 2'b01)
				new_line[39:32] = mem_wdata[7:0];		// only write lower byte
			else if (mem_byte_enable == 2'b10)
				new_line[47:40] = mem_wdata[15:8];	// only write upper byte
			else
				new_line[47:32] = mem_wdata;			// write entire word
		end
		
		3'b011: begin
			if (mem_byte_enable == 2'b01)
				new_line[55:48] = mem_wdata[7:0];		// only write lower byte
			else if (mem_byte_enable == 2'b10)
				new_line[63:56] = mem_wdata[15:8];	// only write upper byte
			else
				new_line[63:48] = mem_wdata;			// write entire word
		end
		
		3'b100: begin
			if (mem_byte_enable == 2'b01)
				new_line[71:64] = mem_wdata[7:0];		// only write lower byte
			else if (mem_byte_enable == 2'b10)
				new_line[79:72] = mem_wdata[15:8];	// only write upper byte
			else
				new_line[79:64] = mem_wdata;			// write entire word
		end
		
		3'b101: begin
			if (mem_byte_enable == 2'b01)
				new_line[87:80] = mem_wdata[7:0];		// only write lower byte
			else if (mem_byte_enable == 2'b10)
				new_line[95:88] = mem_wdata[15:8];	// only write upper byte
			else
				new_line[95:80] = mem_wdata;			// write entire word
		end
		
		3'b110: begin
			if (mem_byte_enable == 2'b01)
				new_line[103:96] = mem_wdata[7:0];		// only write lower byte
			else if (mem_byte_enable == 2'b10)
				new_line[111:104] = mem_wdata[15:8];	// only write upper byte
			else
				new_line[111:96] = mem_wdata;			// write entire word
		end
		
		3'b111: begin
			if (mem_byte_enable == 2'b01)
				new_line[119:112] = mem_wdata[7:0];		// only write lower byte
			else if (mem_byte_enable == 2'b10)
				new_line[127:120] = mem_wdata[15:8];	// only write upper byte
			else
				new_line[127:112] = mem_wdata;			// write entire word
		end
		
	endcase
end

endmodule : line_builder