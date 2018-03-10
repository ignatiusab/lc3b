import lc3b_types::*;

module l1_cache
(
	input clk,
	
	// CPU -> L1 signals
	input logic				mem_read, 
	input logic				mem_write,
	input lc3b_word		mem_address,
	input lc3b_word		mem_wdata,
	input lc3b_mem_wmask	mem_byte_enable,
	
	// L1 -> CPU signals
	output logic			mem_resp,
	output lc3b_word		mem_rdata,
	
	// Arbiter -> L1 signals
	input logic				l2_mem_resp,
	input lc3b_c_line		l2_mem_rdata,
	
	// L1 -> Arbiter signals
	output logic			l2_mem_read, 
	output logic			l2_mem_write,
	output lc3b_word		l2_mem_address,
	output lc3b_c_line	l2_mem_wdata,
	
	output cache_hit, cache_miss
);

logic dirty0, dirty1, hit0, hit1, lru;
logic lru_w, dirty0_w, dirty1_w, valid0_w, valid1_w, tag0_w, tag1_w, data0_w, data1_w;
logic data_in_mux_sel;
logic [1:0] l2_mem_address_mux_sel;

l1_cache_control l1_cache_control (
	.clk,
	
	// input signals from cache_datapath
	.dirty0, .dirty1,
	.hit0, .hit1,
	.lru,
	
	// output signals to cache_datapath
	.data_in_mux_sel,
	.l2_mem_address_mux_sel,
	
	// write signals
	.lru_w,
	.dirty0_w, .valid0_w, .tag0_w, .data0_w,
	.dirty1_w, .valid1_w, .tag1_w, .data1_w,
	
	// memory input signals
	.mem_read, .mem_write,
	
	// memory output signals
	.mem_resp,
	
	// physical memory input signals
	.l2_mem_resp,
	
	// physical memory output signals
	.l2_mem_write, .l2_mem_read,
	
	.cache_hit, .cache_miss
);

l1_cache_datapath l1_cache_datapath (
	.clk,
	
	// input signals from cache_control
	.data_in_mux_sel,
	.l2_mem_address_mux_sel,
	
	// write signals
	.lru_w,
	.dirty0_w, .valid0_w, .tag0_w, .data0_w,
	.dirty1_w, .valid1_w, .tag1_w, .data1_w,
	
	// address signals
	.index(mem_address[7:4]),
	.tag(mem_address[15:8]),
	.offset(mem_address[3:1]),
	
	// memory input signals
	.mem_address,
	.mem_write,
	.mem_byte_enable,
	.mem_wdata,
	
	// memory output signals
	.mem_rdata,
	
	// physical memory input signals
	.l2_mem_rdata,
	
	// physical memory output signals
	.l2_mem_address,
	.l2_mem_wdata,
	
	// output signals to cache_control
	.dirty0, .dirty1,
	.hit0, .hit1,
	.lru
);

endmodule : l1_cache
