module state_register #(parameter width = 16)
(
    input clk,
	 input flush,
    input load,
    input [width-1:0] in,
    output logic [width-1:0] out
);

logic [width-1:0] data;

/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    data = 1'b0;
end

always_ff @(posedge clk)
begin
	if(flush)
	begin
		data = 0;
	end
	else if (load)
   begin
		data = in;
   end
end

always_comb
begin
    out = data;
end

endmodule : state_register
