import lc3b_types::*;
module mux4 #(parameter width = $bits(lc3b_word))
(
	input logic [1:0] sel,
	input [width-1:0] a, b, c, d,
	output logic [width-1:0] f
);

always_comb
begin
	case(sel)
		2'b00:	f = a;
		2'b01:	f = b;
		2'b10:	f = c;
		2'b11:	f = d;
		default:	f = 0;
	endcase
end
endmodule : mux4