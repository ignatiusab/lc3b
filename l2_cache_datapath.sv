import lc3b_types::*;


parameter NUM_L2_SETS = 64;


module l2_cache_datapath
(
	input clk,
	
	// From l2_cache_control
	input data_in_mux_sel,
	input [2:0] pmem_address_mux_sel,
	input load_pmem_wdata,
	input lru_w,
	input dirty0_w, valid0_w, tag0_w, data0_w,
	input dirty1_w, valid1_w, tag1_w, data1_w,
	input dirty2_w, valid2_w, tag2_w, data2_w,
	input dirty3_w, valid3_w, tag3_w, data3_w,
	
	// To l2_cache_control
	output logic dirty0, dirty1, dirty2, dirty3,
	output logic hit0, hit1, hit2, hit3,
	output logic [1:0] lru,
	
	// Split Address
	input lc3b_c2_tag		tag,
	input lc3b_c2_index	index,
	input lc3b_c2_offset	offset,
	
	// From L1
	input lc3b_word		mem_address,
	input logic				mem_write,
	input lc3b_c_line		mem_wdata,
	
	// To L1
	output lc3b_c_line	mem_rdata,
	
	// From PMEM
	input lc3b_c2_line	pmem_rdata,
	
	// To PMEM
	output lc3b_word		pmem_address,
	output lc3b_c2_line	pmem_wdata
	
	
);

lc3b_c2_tag		tag0_out, tag1_out, tag2_out, tag3_out;
logic				valid0_out, valid1_out, valid2_out, valid3_out;
lc3b_c2_line	data_in, data0_out, data1_out, data2_out, data3_out, new_line;
lc3b_c2_line	data_way_mux_out;
lc3b_c2_line write_back_mux_out;

///////////////////////// Hit Detection /////////////////////////
l2_detect_hit l2_detect_hit
(
	.tag(tag),
	.tag0(tag0_out),
	.tag1(tag1_out),
	.tag2(tag2_out),
	.tag3(tag3_out),
	.valid0(valid0_out),
	.valid1(valid1_out),
	.valid2(valid2_out),
	.valid3(valid3_out),
	.hit0(hit0),
	.hit1(hit1),
	.hit2(hit2),
	.hit3(hit3)
);
/////////////////////////// LRU /////////////////////////////////

l2_cache_lru l2_cache_lru
(
	.clk(clk),
	.hit0(hit0),
	.hit1(hit1),
	.hit2(hit2),
	.hit3(hit3),
	.write(lru_w),
	.index(index),
	.lru_out(lru)
);

/////////////////////////// Way 0 ///////////////////////////////

array #(.width(1), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) dirty_array_0
(
	.clk(clk),
	.write(dirty0_w),
	.index(index),
	.datain(mem_write),
	.dataout(dirty0)
);

array #(.width(1), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) valid_array_0
(
	.clk(clk),
	.write(valid0_w),
	.index(index),
	.datain(1'b1),
	.dataout(valid0_out)
);

array #(.width($bits(lc3b_c2_tag)), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) tag_array_0
(
	.clk(clk),
	.write(tag0_w),
	.index(index),
	.datain(tag),
	.dataout(tag0_out)
);

array #(.width($bits(lc3b_c2_line)), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) data_array_0
(
	.clk(clk),
	.write(data0_w),
	.index(index),
	.datain(data_in),
	.dataout(data0_out)
);

/////////////////////////// Way 1 ///////////////////////////////

array #(.width(1), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) dirty_array_1
(
	.clk(clk),
	.write(dirty1_w),
	.index(index),
	.datain(mem_write),
	.dataout(dirty1)
);

array #(.width(1), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) valid_array_1(
	.clk(clk),
	.write(valid1_w),
	.index(index),
	.datain(1'b1),
	.dataout(valid1_out)
);

array #(.width($bits(lc3b_c2_tag)), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) tag_array_1
(
	.clk(clk),
	.write(tag1_w),
	.index(index),
	.datain(tag),
	.dataout(tag1_out)
);

array #(.width($bits(lc3b_c2_line)), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) data_array_1
(
	.clk(clk),
	.write(data1_w),
	.index(index),
	.datain(data_in),
	.dataout(data1_out)
);

/////////////////////////// Way 2 ///////////////////////////////

array #(.width(1), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) dirty_array_2
(
	.clk(clk),
	.write(dirty2_w),
	.index(index),
	.datain(mem_write),
	.dataout(dirty2)
);

array #(.width(1), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) valid_array_2(
	.clk(clk),
	.write(valid2_w),
	.index(index),
	.datain(1'b1),
	.dataout(valid2_out)
);

array #(.width($bits(lc3b_c2_tag)), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) tag_array_2
(
	.clk(clk),
	.write(tag2_w),
	.index(index),
	.datain(tag),
	.dataout(tag2_out)
);

array #(.width($bits(lc3b_c2_line)), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) data_array_2
(
	.clk(clk),
	.write(data2_w),
	.index(index),
	.datain(data_in),
	.dataout(data2_out)
);

/////////////////////////// Way 3 ///////////////////////////////

array #(.width(1), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) dirty_array_3
(
	.clk(clk),
	.write(dirty3_w),
	.index(index),
	.datain(mem_write),
	.dataout(dirty3)
);

array #(.width(1), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) valid_array_3(
	.clk(clk),
	.write(valid3_w),
	.index(index),
	.datain(1'b1),
	.dataout(valid3_out)
);

array #(.width($bits(lc3b_c2_tag)), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) tag_array_3
(
	.clk(clk),
	.write(tag3_w),
	.index(index),
	.datain(tag),
	.dataout(tag3_out)
);

array #(.width($bits(lc3b_c2_line)), .sets(NUM_L2_SETS), .index_length($bits(lc3b_c2_index))) data_array_3
(
	.clk(clk),
	.write(data3_w),
	.index(index),
	.datain(data_in),
	.dataout(data3_out)
);

//////////////////////////// Output /////////////////////////////

waymux4 #(.width($bits(lc3b_c2_line))) data_way_mux
(
	.hit0(hit0),
	.hit1(hit1),
	.hit2(hit2),
	.hit3(hit3),
	.a(data0_out),
	.b(data1_out),
	.c(data2_out),
	.d(data3_out),
	.f(data_way_mux_out)
);

mux2 #(.width($bits(lc3b_c_line))) get_128_mux
(
	.sel(offset),
	.a(data_way_mux_out[127:0]),
	.b(data_way_mux_out[255:128]),
	.f(mem_rdata)
);
									
mux4 #(.width($bits(lc3b_c2_line))) write_back_mux
(
	.sel(lru),
	.a(data0_out),
	.b(data1_out),
	.c(data2_out),
	.d(data3_out),
	.f(pmem_wdata)
);
/*
register #(.width($bits(lc3b_c2_line))) pmem_wdata_mux
(
	.clk,
	.load(load_pmem_wdata),
	.in(write_back_mux_out),
	.out(pmem_wdata)
);
*/
//mux8 #(.width(16)) pmem_address_mux
//(
//	.sel(pmem_address_mux_sel),
//	.a(mem_address),
//	.b({tag0_out,index,5'd0}),
//	.c({tag1_out,index,5'd0}),
//	.d({tag2_out,index,5'd0}),
//	.e({tag3_out,index,5'd0}),
//	.f(16'd0),
//	.g(16'd0),
//	.h(16'd0),
//	.out(pmem_address)
//);
always_comb
begin
	case(pmem_address_mux_sel)
		3'b000: pmem_address = mem_address;
		3'b001: pmem_address = {tag0_out,index,5'd0};
		3'b010: pmem_address = {tag1_out,index,5'd0};
		3'b011: pmem_address = {tag2_out,index,5'd0};
		3'b100: pmem_address = {tag3_out,index,5'd0};
		default: pmem_address = 16'd0;
	endcase
end

/////////////////////////// Input //////////////////////////////

mux2 #(.width($bits(lc3b_c2_line))) data_in_mux
(
	.sel(data_in_mux_sel),
	.a(pmem_rdata),
	.b(new_line),
	.f(data_in)
);

l2_line_builder l2_line_builder
(
	.mem_wdata(mem_wdata),
	.offset(offset),
	.data_in(data_way_mux_out),
	.new_line(new_line)
);

endmodule : l2_cache_datapath