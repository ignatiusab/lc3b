import lc3b_types::*;

module adder #(parameter width = 16)
(
	input [width-1:0] a, b,
	output logic [width-1:0] sum
);

always_comb
begin
	sum = a + b;
end
endmodule : adder