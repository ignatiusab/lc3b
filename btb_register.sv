module btb_register 
(
    input clk,
    input load,
    input [15:0] in,
    output logic [15:0] out
);

logic [15:0] data;

/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    data = 16'hffff;
end

always_ff @(posedge clk)
begin
    if (load)
    begin
        data = in;
    end
end

always_comb
begin
    out = data;
end

endmodule : btb_register
