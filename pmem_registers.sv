import lc3b_types::*;

module pmem_registers
(
	input clk,
	
	
	input logic pmem_read_in,
	output logic pmem_read_out,
	
	input logic pmem_write_in,
	output logic pmem_write_out,
	
	input logic pmem_resp_in,
	output logic pmem_resp_out,
	
	input lc3b_c2_line pmem_rdata_in,
	output lc3b_c2_line pmem_rdata_out,
	
	input lc3b_c2_line pmem_wdata_in,
	output lc3b_c2_line pmem_wdata_out,
	
	input lc3b_word pmem_address_in,
	output lc3b_word pmem_address_out
);

register #(.width(1)) read_reg
(
	.clk,
	.load(1'b1),
	.in(pmem_read_in),
	.out(pmem_read_out)
);
register #(.width(1)) write_reg
(
	.clk,
	.load(1'b1),
	.in(pmem_write_in),
	.out(pmem_write_out)
);
register #(.width(1)) resp_reg
(
	.clk,
	.load(1'b1),
	.in(pmem_resp_in),
	.out(pmem_resp_out)
);

register #(.width(256)) rdata_reg
(
	.clk,
	.load(1'b1),
	.in(pmem_rdata_in),
	.out(pmem_rdata_out)
);

register #(.width(256)) wdata_reg
(
	.clk,
	.load(1'b1),
	.in(pmem_wdata_in),
	.out(pmem_wdata_out)
);


register #(.width(16)) address_reg
(
	.clk,
	.load(1'b1),
	.in(pmem_address_in),
	.out(pmem_address_out)
);
endmodule: pmem_registers