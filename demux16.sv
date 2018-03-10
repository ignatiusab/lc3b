import lc3b_types::*;

module demux16 #(parameter width = $bits(lc3b_word))
(
	input logic [3:0] sel,
	output logic [width-1:0] a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p,
	input logic [width-1:0] in
);

always_comb
begin
	a = 0;
	b = 0;
	c = 0;
	d = 0;
	e = 0;
	f = 0;
	g = 0;
	h = 0;
	i = 0;
	j = 0;
	k = 0;
	l = 0;
	m = 0;
	n = 0;
	o = 0;
	p = 0;

	case(sel)
		4'b0000:	 a = in;
		4'b0001:	 b = in;
		4'b0010:	 c = in;
		4'b0011:	 d = in;
		4'b0100:	 e = in;
		4'b0101:	 f = in;
		4'b0110:	 g = in;
		4'b0111:	 h = in;
		4'b1000:	 i = in;
		4'b1001:	 j = in;
		4'b1010:	 k = in;
		4'b1011:	 l = in;
		4'b1100:	 m = in;
		4'b1101:	 n = in;
		4'b1110:	 o = in;
		4'b1111:	 p = in;
		default:	 /* nada */;
	endcase
end
endmodule : demux16