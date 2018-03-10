import lc3b_types::*;

module mp3
(
	input logic clk,
	
	// Memory -> Arbiter signals
	input logic				pmem_resp,
	//input lc3b_c_line		pmem_rdata,
	input lc3b_c2_line		pmem_rdata,
	
	// Arbiter -> Memory signals
	output logic			pmem_read,
	output logic			pmem_write,
	output lc3b_c_addr		pmem_address,
	//output lc3b_c_line		pmem_wdata
	output lc3b_c2_line		pmem_wdata
);

// i_cpu & d_cpu signals
logic imem_resp, dmem_resp, imem_read, dmem_read, imem_write, dmem_write;
lc3b_word imem_address, dmem_address, imem_rdata, dmem_rdata, imem_wdata, dmem_wdata;
lc3b_mem_wmask imem_byte_enable, dmem_byte_enable;

// i_arb & d_arb signals
logic i_arb_mem_resp, i_arb_mem_read, i_arb_mem_write;
logic d_arb_mem_resp, d_arb_mem_read, d_arb_mem_write;
lc3b_word i_arb_mem_address, d_arb_mem_address;
lc3b_c_line i_arb_mem_rdata, i_arb_mem_wdata;
lc3b_c_line d_arb_mem_rdata, d_arb_mem_wdata;

// arb_l2 signals 
logic arb_l2_mem_resp;
logic arb_l2_mem_read;
logic arb_l2_mem_write;
lc3b_word arb_l2_mem_address;
lc3b_c_line arb_l2_mem_rdata;
lc3b_c_line arb_l2_mem_wdata;

// arb_l2 EWB signals
logic arb_l2_ewb_mem_resp;
logic arb_l2_ewb_mem_read;
logic arb_l2_ewb_mem_write;
lc3b_word arb_l2_ewb_mem_address;
lc3b_c_line arb_l2_ewb_mem_rdata;
lc3b_c_line arb_l2_ewb_mem_wdata;

// l2 and ewb signals
logic ewb_mem_read, ewb_mem_write, ewb_mem_resp;
lc3b_c2_line ewb_mem_wdata, ewb_mem_rdata;
lc3b_word ewb_mem_address;

// performance counter signals
lc3b_word counter_rdata;
logic clear;
logic l1_mem_resp, l1_mem_read, l1_mem_write;
lc3b_word l1_mem_rdata;
lc3b_word l1_mem_wdata;
lc3b_word l1_mem_address;
logic i_cache_hit, i_cache_miss, d_cache_hit, d_cache_miss;
logic l2_cache_hit, l2_cache_miss;
logic i_cache_stall, d_cache_stall, branch_stall, flush, is_branch, is_instruction;

// CPU
cpu_datapath CPU_datapath
(
	.clk,
	
	// i-cache signals
	.imem_resp,
	.imem_rdata,
	.imem_read,
	.imem_write,
	.imem_address,
	.imem_byte_enable,
	.imem_wdata,
	
	// d-cache signals
	.dmem_resp,
	.dmem_rdata,
	.dmem_read,	
	.dmem_write,
	.dmem_address,
	.dmem_byte_enable,
	.dmem_wdata,
	
	.i_cache_stall, .d_cache_stall, .branch_stall, .flush, .is_branch, .is_instruction
);

perf_counters perf_counters
(
	.clk,
	
	.address(dmem_address),
	.clear,
	.counter_rdata,
	
	.i_cache_hit, .i_cache_miss,
	.d_cache_hit, .d_cache_miss,
	.l2_cache_hit, .l2_cache_miss,
	.i_cache_stall,
	.d_cache_stall,
	.non_cond_stall(branch_stall),
	.br_mispredict(flush),
	.total_branches(is_branch),
	.is_instruction
);

mmio mmio
(
	.dmem_read, 
	.dmem_write,
	.dmem_address,
	.dmem_wdata,
	
	.dmem_resp,
	.dmem_rdata,
	
	.l1_mem_resp,
	.l1_mem_rdata,
	
	.l1_mem_read, 
	.l1_mem_write,
	.l1_mem_address,
	.l1_mem_wdata,
	
	.counter_rdata,
	.clear
);

// I-Cache
l1_cache i_cache
(
	.clk,
	
	// CPU -> i_cache signals
	.mem_read(imem_read), 
	.mem_write(imem_write),
	.mem_address(imem_address),
	.mem_wdata(imem_wdata),
	.mem_byte_enable(imem_byte_enable),
	
	// i_cache -> CPU signals
	.mem_resp(imem_resp),
	.mem_rdata(imem_rdata),
	
	// Arbiter -> i_cache signals
	.l2_mem_resp(i_arb_mem_resp),
	.l2_mem_rdata(i_arb_mem_rdata),
	
	// i_cache -> Arbiter signals
	.l2_mem_read(i_arb_mem_read), 
	.l2_mem_write(i_arb_mem_write),
	.l2_mem_address(i_arb_mem_address),
	.l2_mem_wdata(i_arb_mem_wdata),
	
	.cache_hit(i_cache_hit),
	.cache_miss(i_cache_miss)
);

// D-Cache
l1_cache d_cache
(
	.clk,
	
	// CPU -> d_cache signals
	.mem_read(l1_mem_read), 
	.mem_write(l1_mem_write),
	.mem_address(l1_mem_address),
	.mem_wdata(l1_mem_wdata),
	.mem_byte_enable(dmem_byte_enable),
	
	// d_cache -> CPU signals
	.mem_resp(l1_mem_resp),
	.mem_rdata(l1_mem_rdata),
	
	// Arbiter -> d_cache signals
	.l2_mem_resp(d_arb_mem_resp),
	.l2_mem_rdata(d_arb_mem_rdata),
	
	// d_cache -> Arbiter signals
	.l2_mem_read(d_arb_mem_read), 
	.l2_mem_write(d_arb_mem_write),
	.l2_mem_address(d_arb_mem_address),
	.l2_mem_wdata(d_arb_mem_wdata),
	
	.cache_hit(d_cache_hit),
	.cache_miss(d_cache_miss)
);

//Arbiter to L2
arbiter arbiter
(
	.clk,
	
	// from i-cache
	.imem_address(i_arb_mem_address),
	.imem_read(i_arb_mem_read),
	.imem_write(i_arb_mem_write),
	.imem_wdata(i_arb_mem_wdata),
	
	// to i-cache
	.imem_rdata(i_arb_mem_rdata),
	.imem_resp(i_arb_mem_resp),
	
	// from d-cache
	.dmem_address(d_arb_mem_address),
	.dmem_read(d_arb_mem_read),
	.dmem_write(d_arb_mem_write),
	.dmem_wdata(d_arb_mem_wdata),
	
	// to d-cache
	.dmem_rdata(d_arb_mem_rdata),
	.dmem_resp(d_arb_mem_resp),
	
	// from L2 Memory
	.L2_mem_resp(arb_l2_mem_resp),
	.L2_mem_rdata(arb_l2_mem_rdata),
	
	// to L2 Memory
	.L2_mem_address(arb_l2_mem_address),
	.L2_mem_read(arb_l2_mem_read),
	.L2_mem_write(arb_l2_mem_write),
	.L2_mem_wdata(arb_l2_mem_wdata)
);

//EWB -> L2
//eviction_write_buffer_arb_L2 eviction_write_buffer_arb_L2
//(
//	.clk,
//
//	// memory input signals
//	.ewb_mem_read(arb_l2_mem_read),
//	.ewb_mem_write(arb_l2_mem_write),
//	.ewb_mem_address(arb_l2_mem_address),
//	.ewb_mem_wdata(arb_l2_mem_wdata),
//	
//	// memory output signals					
//
//	.ewb_mem_resp(arb_l2_mem_resp),
//	.ewb_mem_rdata(arb_l2_mem_rdata),
//	
//	// physical memory input signals
//	.pmem_resp(arb_l2_ewb_mem_resp),
//	.pmem_rdata(arb_l2_ewb_mem_rdata),
//	
//	// physical memory output signals
//	.pmem_read(arb_l2_ewb_mem_read),
//	.pmem_write(arb_l2_ewb_mem_write),
//	.pmem_address(arb_l2_ewb_mem_address),
//	.pmem_wdata(arb_l2_ewb_mem_wdata)
//);

// L2 cache to EWB
l2_cache L2_cache
(
	.clk,

	//Without EWB between Arbiter and L2
	// memory input signals
	.mem_read(arb_l2_mem_read),
	.mem_write(arb_l2_mem_write),
	.mem_address(arb_l2_mem_address),
	.mem_wdata(arb_l2_mem_wdata),
	// memory output signals					
	.mem_resp(arb_l2_mem_resp),
	.mem_rdata(arb_l2_mem_rdata),
	
	//With EWB between Arbiter and L2
//	// memory input signals
//	.mem_read(arb_l2_ewb_mem_read),
//	.mem_write(arb_l2_ewb_mem_write),
//	.mem_address(arb_l2_ewb_mem_address),
//	.mem_wdata(arb_l2_ewb_mem_wdata),
//	// memory output signals					
//	.mem_resp(arb_l2_ewb_mem_resp),
//	.mem_rdata(arb_l2_ewb_mem_rdata),
//	
	
	// physical memory input signals
	.pmem_resp(ewb_mem_resp),
	.pmem_rdata(ewb_mem_rdata),
	
	// physical memory output signals
	.pmem_read(ewb_mem_read),
	.pmem_write(ewb_mem_write),
	.pmem_address(ewb_mem_address),
	.pmem_wdata(ewb_mem_wdata),
	
	.cache_hit(l2_cache_hit),
	.cache_miss(l2_cache_miss)
);
//// L2 cache to Physical Memory
//l2_cache L2_cache
//(
//	.clk,
//
//	// memory input signals
//	.mem_read(arb_l2_mem_read),
//	.mem_write(arb_l2_mem_write),
//	.mem_address(arb_l2_mem_address),
//	.mem_wdata(arb_l2_mem_wdata),
//	
//	// memory output signals					
//
//	.mem_resp(arb_l2_mem_resp),
//	.mem_rdata(arb_l2_mem_rdata),
//	
//	// physical memory input signals
//	.pmem_resp,
//	.pmem_rdata,
//	
//	// physical memory output signals
//	.pmem_read,
//	.pmem_write,
//	.pmem_address,
//	.pmem_wdata
//);

logic pmem_ewb_resp, ewb_pmem_read, ewb_pmem_write;
lc3b_word ewb_pmem_address;
lc3b_c2_line pmem_ewb_rdata, ewb_pmem_wdata;
//EWB -> Physical Mem
eviction_write_buffer eviction_write_buffer
(
	.clk,

	// memory input signals
	.ewb_mem_read,
	.ewb_mem_write,
	.ewb_mem_address,
	.ewb_mem_wdata,
	
	// memory output signals					

	.ewb_mem_resp,
	.ewb_mem_rdata,
	
	// physical memory input signals
	.pmem_resp,
	.pmem_rdata,
	
	// physical memory output signals
	.pmem_read,
	.pmem_write,
	.pmem_address,
	.pmem_wdata
	
	
//	// physical memory input signals
//	.pmem_resp(pmem_ewb_resp),
//	.pmem_rdata(pmem_ewb_rdata),
//	
//	// physical memory output signals
//	.pmem_read(ewb_pmem_read),
//	.pmem_write(ewb_pmem_write),
//	.pmem_address(ewb_pmem_address),
//	.pmem_wdata(ewb_pmem_wdata)
);
	
//pmem_registers	PMEM_registers
//(
//	.clk,
//	.pmem_read_in(ewb_pmem_read),
//	.pmem_read_out(pmem_read),
//	
//	.pmem_write_in(ewb_pmem_write),
//	.pmem_write_out(pmem_write),
//	
//	.pmem_resp_in(pmem_resp),
//	.pmem_resp_out(pmem_ewb_resp),
//	
//	.pmem_rdata_in(pmem_rdata),
//	.pmem_rdata_out(pmem_ewb_rdata),
//	
//	.pmem_wdata_in(ewb_pmem_wdata),
//	.pmem_wdata_out(pmem_wdata),
//	
//	.pmem_address_in(ewb_pmem_address),
//	.pmem_address_out(pmem_address)
//);
endmodule : mp3