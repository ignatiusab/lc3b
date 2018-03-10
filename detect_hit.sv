import lc3b_types::*;

module detect_hit
(
	input lc3b_c_tag tag, tag0, tag1, 
	input valid0, valid1,
	output logic hit0, hit1
);

always_comb
	begin
		if ( (tag == tag0) && (valid0 == 1'b1) )
			begin
				hit0 = 1'b1;
				hit1 = 1'b0;
			end
		else if ( (tag == tag1) && (valid1 == 1'b1) )
			begin
				hit0 = 1'b0;
				hit1 = 1'b1;
			end
		else
			begin
				hit0 = 1'b0;
				hit1 = 1'b0;
			end
	end

endmodule : detect_hit