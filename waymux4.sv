import lc3b_types::*;
module waymux4 #(parameter width = $bits(lc3b_word))
(
	input logic hit0, hit1, hit2, hit3,
	input [width-1:0] a, b, c, d,
	output logic [width-1:0] f
);

always_comb
begin
	case({hit0,hit1,hit2,hit3})
		4'b1000:	f = a;
		4'b0100:	f = b;
		4'b0010:	f = c;
		4'b0001:	f = d;
		default:	f = 0;
	endcase
end
endmodule : waymux4