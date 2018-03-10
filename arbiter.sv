import lc3b_types::*;

module arbiter
(
	input clk,
	
	//From i-cache and d-cache
	input lc3b_word				imem_address, dmem_address,
	input logic					imem_read, dmem_read,
	input logic					imem_write, dmem_write,
	input lc3b_c_line			imem_wdata, dmem_wdata,

	//From L2
	input logic					L2_mem_resp,
	input lc3b_c_line			L2_mem_rdata,
	
	//To i-cache and d-cache
	output lc3b_c_line			imem_rdata, dmem_rdata,
	output logic				imem_resp, dmem_resp,
	
	//To L2 Cache
	output lc3b_word			L2_mem_address,
	output logic				L2_mem_read, L2_mem_write,
	output lc3b_c_line			L2_mem_wdata
);

//Internal signals for (de)muxes
logic	arb_mem_address_mux_sel;
logic arb_mem_read_mux_sel;
logic arb_mem_write_mux_sel;
logic arb_mem_wdata_mux_sel;
logic	arb_mem_rdata_mux_sel;
logic arb_mem_resp_mux_sel;
logic load_L2_mem_reg;
logic L2_mem_read_write_mux_sel;
//logic	arb_mem_byte_enable_mux_sel;

arb_datapath	arbiter_datapath
(
	.clk,
	//From i-cache and d-cache
	.imem_address, .dmem_address,
	.imem_read, .dmem_read,
	.imem_write, .dmem_write,
	.imem_wdata, .dmem_wdata,
	
	//From L2
	.L2_mem_resp,
	.L2_mem_rdata,
	
	//From arb_control
	.arb_mem_address_mux_sel, .arb_mem_read_mux_sel,
	.arb_mem_write_mux_sel, .arb_mem_wdata_mux_sel,
	.arb_mem_rdata_mux_sel, .arb_mem_resp_mux_sel,
	.load_L2_mem_reg, .L2_mem_read_write_mux_sel,
	
	//To i-cache and d-cache
	.imem_rdata, .dmem_rdata,
	.imem_resp, .dmem_resp,
	
	//To L2 Cache
	.L2_mem_address,
	.L2_mem_read, .L2_mem_write,
	.L2_mem_wdata
);

arb_control		arbiter_control
(
	.clk,
	//From i-cache and d-cache
	.imem_read, .dmem_read, .imem_write, .dmem_write,
	
	//From L2 cache
	.L2_mem_resp,
	
	//To datapath
	.arb_mem_address_mux_sel, .arb_mem_read_mux_sel,
	.arb_mem_write_mux_sel, .arb_mem_wdata_mux_sel,
	.arb_mem_rdata_mux_sel, .arb_mem_resp_mux_sel,
	.L2_mem_read_write_mux_sel,
	.load_L2_mem_reg
);

endmodule: arbiter