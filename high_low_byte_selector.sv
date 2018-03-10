import lc3b_types::*;

module high_low_byte_selector #(parameter width = 8)
(
	 input logic sel,
    input lc3b_byte in,
    output lc3b_word out
);

always_comb
begin
	if(sel == 0)
		out = {8'h00, in};
	else
		out = {in, 8'h00};
end

endmodule : high_low_byte_selector