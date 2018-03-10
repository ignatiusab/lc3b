import lc3b_types::*;

module arb_datapath
(
	input clk,
	//From i-cache and d-cache
	input lc3b_word			imem_address, dmem_address,
	input logic					imem_read, dmem_read,
	input logic					imem_write, dmem_write,
	input lc3b_c_line			imem_wdata, dmem_wdata,
	
	//From L2
	input logic					L2_mem_resp,
	input lc3b_c_line			L2_mem_rdata,
	
	//From arb_control
	input logic					arb_mem_address_mux_sel, arb_mem_read_mux_sel,
									arb_mem_write_mux_sel, arb_mem_wdata_mux_sel,
									arb_mem_rdata_mux_sel, arb_mem_resp_mux_sel,
	input logic					load_L2_mem_reg, L2_mem_read_write_mux_sel,
	
	//To i-cache and d-cache
	output lc3b_c_line		imem_rdata, dmem_rdata,
	output logic				imem_resp, dmem_resp,
	
	//To L2 Cache
	output lc3b_word			L2_mem_address,
	output logic				L2_mem_read, L2_mem_write,
	output lc3b_c_line		L2_mem_wdata
);

//Internal Signals
lc3b_word arb_mem_address_mux_out;
logic arb_mem_read_mux_out, arb_mem_write_mux_out;
lc3b_c_line arb_mem_wdata_mux_out;
lc3b_c_line imem_rdata_reg_out, dmem_rdata_reg_out;
logic imem_resp_reg_out, dmem_resp_reg_out, L2_mem_read_reg_in, L2_mem_write_reg_in;

mux2 arb_mem_address_mux
(
	.sel(arb_mem_address_mux_sel),
	.a(imem_address),
	.b(dmem_address),
	.f(arb_mem_address_mux_out)
);

//assign L2_mem_address = arb_mem_address_mux_out;
register #(.width($bits(L2_mem_address))) L2_mem_address_reg
(
	.clk,
	.load(load_L2_mem_reg),
	.in(arb_mem_address_mux_out),
	.out(L2_mem_address)
);
mux2 #(.width(1)) arb_mem_read_mux
(
	.sel(arb_mem_read_mux_sel),
	.a(imem_read),
	.b(dmem_read),
	.f(arb_mem_read_mux_out)
);
//assign L2_mem_read = arb_mem_read_mux_out;
register #(.width($bits(L2_mem_read))) L2_mem_read_reg
(
	.clk,
	.load(load_L2_mem_reg),
	.in(L2_mem_read_reg_in),
	.out(L2_mem_read)
);

mux2 #(.width($bits(L2_mem_read))) L2_mem_read_mux
(
	.sel(L2_mem_read_write_mux_sel),
	.a(arb_mem_read_mux_out),
	.b(1'b0),
	.f(L2_mem_read_reg_in)
);

mux2 #(.width(1)) arb_mem_write_mux
(
	.sel(arb_mem_write_mux_sel),
	.a(imem_write),
	.b(dmem_write),
	.f(arb_mem_write_mux_out)
);
//assign L2_mem_write = arb_mem_write_mux_out;

register #(.width($bits(L2_mem_write))) L2_mem_write_reg
(
	.clk,
	.load(load_L2_mem_reg),
	.in(L2_mem_write_reg_in),
	.out(L2_mem_write)
);

mux2 #(.width($bits(L2_mem_write))) L2_mem_write_mux
(
	.sel(L2_mem_read_write_mux_sel),
	.a(arb_mem_write_mux_out),
	.b(1'b0),
	.f(L2_mem_write_reg_in)
);

mux2 #(.width($bits(lc3b_c_line))) arb_mem_wdata_mux
(
	.sel(arb_mem_wdata_mux_sel),
	.a(imem_wdata),
	.b(dmem_wdata),
	.f(arb_mem_wdata_mux_out)
);

//assign L2_mem_wdata = arb_mem_wdata_mux_out;
register #(.width($bits(L2_mem_wdata))) L2_mem_wdata_reg
(
	.clk,
	.load(load_L2_mem_reg),
	.in(arb_mem_wdata_mux_out),
	.out(L2_mem_wdata)
);

demux2 #(.width($bits(lc3b_c_line))) arb_mem_rdata_mux
(
	.sel(arb_mem_rdata_mux_sel),
	.in(L2_mem_rdata),
	.out_a(imem_rdata_reg_out),
	.out_b(dmem_rdata_reg_out)
);

//assign imem_rdata = imem_rdata_reg_out;
//assign dmem_rdata = dmem_rdata_reg_out;
register #(.width($bits(lc3b_c_line))) imem_rdata_reg
(
	.clk,
	.load(load_L2_mem_reg),
	.in(imem_rdata_reg_out),
	.out(imem_rdata)
);

register #(.width($bits(lc3b_c_line))) dmem_rdata_reg
(
	.clk,
	.load(load_L2_mem_reg),
	.in(dmem_rdata_reg_out),
	.out(dmem_rdata)
);

demux2 #(.width(1)) arb_mem_resp_mux
(
	.sel(arb_mem_resp_mux_sel),
	.in(L2_mem_resp),
	.out_a(imem_resp_reg_out),
	.out_b(dmem_resp_reg_out)
);

//assign imem_resp = imem_resp_reg_out;
//assign dmem_resp = dmem_resp_reg_out;
register #(.width(1)) imem_resp_reg
(
	.clk,
	.load(load_L2_mem_reg),
	.in(imem_resp_reg_out),
	.out(imem_resp)
);

register #(.width(1)) dmem_resp_reg
(
	.clk,
	.load(load_L2_mem_reg),
	.in(dmem_resp_reg_out),
	.out(dmem_resp)
);

endmodule: arb_datapath