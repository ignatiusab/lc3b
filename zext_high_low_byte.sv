import lc3b_types::*;

module zext_high_low_byte
(
	 input logic sel,
    input lc3b_word in,
    output lc3b_word out
);

always_comb
begin
	if(sel == 0)
		out = $unsigned(in[7:0]);
	else
		out = $unsigned(in[15:8]);
end

endmodule : zext_high_low_byte 