import lc3b_types::*;

module l2_detect_hit
(
	input lc3b_c2_tag tag, tag0, tag1, tag2, tag3,
	input valid0, valid1, valid2, valid3,
	output logic hit0, hit1, hit2, hit3
);

always_comb
	begin
		if ( (tag == tag0) && (valid0 == 1'b1) )
			begin
				{hit0, hit1, hit2, hit3} = 4'b1000;
			end
		else if ( (tag == tag1) && (valid1 == 1'b1) )
			begin
				{hit0, hit1, hit2, hit3} = 4'b0100;
			end
		else if ( (tag == tag2) && (valid2 == 1'b1) )
			begin
				{hit0, hit1, hit2, hit3} = 4'b0010;
			end
		else if ( (tag == tag3) && (valid3 == 1'b1) )
			begin
				{hit0, hit1, hit2, hit3} = 4'b0001;
			end
		else
			begin
				{hit0, hit1, hit2, hit3} = 4'b0000;
			end
	end

endmodule : l2_detect_hit