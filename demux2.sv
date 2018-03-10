import lc3b_types::*;
module demux2 #(parameter width = $bits(lc3b_word))
(
	input logic sel,
	input logic [width-1:0] in,
	output logic [width-1:0] out_a, out_b
);

always_comb
begin
	if (sel == 0)
	begin
		out_a = in;
		out_b = 0;
	end
	else
	begin
		out_a = 0;
		out_b = in;
	end
end

endmodule : demux2