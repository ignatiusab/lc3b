import lc3b_types::*;

parameter L2_SETS = 64;
module l2_cache_lru
(
	input clk, 
	
	input logic hit0, hit1, hit2, hit3, 
	input write,
	input lc3b_c2_index index, 
	
	output logic [1:0] lru_out
);

logic [2:0] lru_in, lru_array_out;

array #(.width(3), .sets(L2_SETS), .index_length($bits(lc3b_c2_index))) l2_lru_array
(
	.clk(clk),
	.write(write),
	.index(index),
	.datain(lru_in),
	.dataout(lru_array_out)
);

always_comb
begin
case ({hit0, hit1, hit2, hit3})

	4'b1000 : 	begin
					lru_in = {1'b1, 1'b1, lru_array_out[0]};
				end
			
	4'b0100 : 	begin
					lru_in = {1'b1, 1'b0, lru_array_out[0]};
				end
			
	4'b0010 : 	begin
					lru_in = {1'b0, lru_array_out[1], 1'b1};
				end
			
	4'b0001 : 	begin
					lru_in = {1'b0, lru_array_out[1], 1'b0};
				end
	
	default : lru_in = lru_array_out;
	
endcase

casez (lru_array_out)

	3'b00? : 	begin
					lru_out = 2'b00;
				end
	
	3'b01? : 	begin
					lru_out = 2'b01;
				end
				
	3'b1?0 : 	begin
					lru_out = 2'b10;
				end
				
	3'b1?1 : 	begin
					lru_out = 2'b11;
				end
				
	default : lru_out = 2'b00;
	
endcase
end
endmodule : l2_cache_lru