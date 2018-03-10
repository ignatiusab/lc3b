import lc3b_types::*;

module l2_line_builder
(
	input lc3b_c_line mem_wdata,
	//input lc3b_mem_wmask mem_byte_enable,
	input lc3b_c2_offset offset,
	input lc3b_c2_line data_in,
	output lc3b_c2_line new_line
);

// combines mem_wdata with the current data line into a new line, must be byte addressable

always_comb
begin
	new_line = data_in;	// first set output to the entire input block, then rewrite new bytes
	if(offset)
			new_line[255:128] = mem_wdata;
		else 
			new_line[127:0] = mem_wdata;		
end

endmodule : l2_line_builder