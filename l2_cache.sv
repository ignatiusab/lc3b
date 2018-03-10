import lc3b_types::*;

module l2_cache
(
	input clk,
	
	// memory input signals
	input mem_read, mem_write,
	input lc3b_word mem_address, 
	input lc3b_c_line mem_wdata,
	
	// memory output signals
	output logic mem_resp,
	output lc3b_c_line mem_rdata,
	
	// physical memory input signals
	input pmem_resp,
	input lc3b_c2_line pmem_rdata,
	
	// physical memory output signals
	output logic pmem_read, pmem_write,
	output lc3b_word pmem_address,
	output lc3b_c2_line pmem_wdata,
	
	output cache_hit, cache_miss
);

logic dirty0, dirty1, dirty2, dirty3, hit0, hit1, hit2, hit3;
logic [1:0] lru;
logic lru_w;
logic dirty0_w, valid0_w, tag0_w, data0_w;
logic dirty1_w, valid1_w, tag1_w, data1_w;
logic dirty2_w, valid2_w, tag2_w, data2_w;
logic dirty3_w, valid3_w, tag3_w, data3_w;

logic data_in_mux_sel;
logic [2:0] pmem_address_mux_sel;
logic load_pmem_wdata;
l2_cache_control l2_cache_control (
	.clk,
	
	// input signals from cache_datapath
	.dirty0, .dirty1, .dirty2, .dirty3,
	.hit0, .hit1, .hit2, .hit3,
	.lru,
	
	// output signals to cache_datapath
	.data_in_mux_sel,
	.pmem_address_mux_sel,
	.load_pmem_wdata,
	
	// write signals
	.lru_w,
	.dirty0_w, .valid0_w, .tag0_w, .data0_w,
	.dirty1_w, .valid1_w, .tag1_w, .data1_w,
	.dirty2_w, .valid2_w, .tag2_w, .data2_w,
	.dirty3_w, .valid3_w, .tag3_w, .data3_w,
	
	// memory input signals
	.mem_read, .mem_write,
	
	// memory output signals
	.mem_resp,
	
	// physical memory input signals
	.pmem_resp,
	
	// physical memory output signals
	.pmem_write, .pmem_read,
	
	.cache_hit, .cache_miss
);

l2_cache_datapath l2_cache_datapath (
	.clk,
	
	// input signals from cache_control
	.data_in_mux_sel,
	.pmem_address_mux_sel,
	.load_pmem_wdata,
	// write signals
	.lru_w,
	.dirty0_w, .valid0_w, .tag0_w, .data0_w,
	.dirty1_w, .valid1_w, .tag1_w, .data1_w,
	.dirty2_w, .valid2_w, .tag2_w, .data2_w,
	.dirty3_w, .valid3_w, .tag3_w, .data3_w,

	
	// address signals
	.tag(mem_address[15:11]),
	.index(mem_address[10:5]),
	.offset(mem_address[4]),
	
	// memory input signals
	.mem_address,
	.mem_write,
	.mem_wdata,
	
	// memory output signals
	.mem_rdata,
	
	// physical memory input signals
	.pmem_rdata,
	
	// physical memory output signals
	.pmem_address,
	.pmem_wdata,
	
	// output signals to cache_control
	.dirty0, .dirty1, .dirty2, .dirty3,
	.hit0, .hit1, .hit2, .hit3,
	.lru
);

endmodule : l2_cache