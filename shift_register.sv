module shift_register #(parameter width = 16)
(
    input clk,
    input load,
    input logic in,
    output logic [width-1:0] out
);

logic [width-1:0] data;

initial
begin
    data = 1'b0;
end

always_ff @(posedge clk)
begin
    if (load)
    begin
        data = {data[width-2:0], in};
    end
end

always_comb
begin
    out = data;
end

endmodule : shift_register
