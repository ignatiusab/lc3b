import lc3b_types::*;

parameter NUM_L1_SETS = 16;

module l1_cache_datapath
(
	input clk,
	
	// input signals from cache_control
	input data_in_mux_sel,
	input [1:0] l2_mem_address_mux_sel,
	
	// write signals
	input lru_w,
	input dirty0_w, valid0_w, tag0_w, data0_w,
	input dirty1_w, valid1_w, tag1_w, data1_w,
	
	// address signals
	input lc3b_c_index index,
	input lc3b_c_tag tag,
	input lc3b_c_offset offset,
	
	// memory input signals from processor
	input lc3b_word mem_address,
	input mem_write,
	input lc3b_mem_wmask mem_byte_enable,
	input lc3b_word mem_wdata,
	
	// memory output signals
	output lc3b_word mem_rdata, //To processor
	
	// L2 cache input signals
	input lc3b_c_line l2_mem_rdata, 
	
	// L2 cache output signals
	output lc3b_word l2_mem_address,
	output lc3b_c_line l2_mem_wdata,
	
	// output signals to cache_control
	output logic dirty0, dirty1,
	output logic hit0, hit1,
	output logic lru
);

lc3b_c_tag tag0_out, tag1_out;
logic valid0_out, valid1_out;
lc3b_c_line data_in, data0_out, data1_out, new_line;
lc3b_c_line data_way_mux_out;
//Hit Detection

detect_hit detect_hit
(
	.tag(tag),
	.tag0(tag0_out),
	.tag1(tag1_out),
	.valid0(valid0_out),
	.valid1(valid1_out),
	.hit0(hit0),
	.hit1(hit1)
);


// LRU

array #(.width(1), .sets(NUM_L1_SETS), .index_length($bits(lc3b_c_index))) lru_array
(
	.clk,
	.write(lru_w),
	.index(index),
	.datain(hit0),
	.dataout(lru)
);

// Way 0

array #(.width(1), .sets(NUM_L1_SETS), .index_length($bits(lc3b_c_index))) dirty_array_0
(
	.clk,
	.write(dirty0_w),
	.index(index),
	.datain(mem_write),
	.dataout(dirty0)
);

array #(.width(1), .sets(NUM_L1_SETS), .index_length($bits(lc3b_c_index))) valid_array_0
(
	.clk,
	.write(valid0_w),
	.index(index),
	.datain(1'b1),
	.dataout(valid0_out)
);

array #(.width($bits(lc3b_c_tag)), .sets(NUM_L1_SETS), .index_length($bits(lc3b_c_index))) tag_array_0
(
	.clk,
	.write(tag0_w),
	.index(index),
	.datain(tag),
	.dataout(tag0_out)
);

array #(.width(128), .sets(NUM_L1_SETS), .index_length($bits(lc3b_c_index))) data_array_0
(
	.clk,
	.write(data0_w),
	.index(index),
	.datain(data_in),
	.dataout(data0_out)
);

// Way 1

array #(.width(1), .sets(NUM_L1_SETS), .index_length($bits(lc3b_c_index))) dirty_array_1
(
	.clk,
	.write(dirty1_w),
	.index(index),
	.datain(mem_write),
	.dataout(dirty1)
);

array #(.width(1), .sets(NUM_L1_SETS), .index_length($bits(lc3b_c_index))) valid_array_1
(
	.clk,
	.write(valid1_w),
	.index(index),
	.datain(1'b1),
	.dataout(valid1_out)
);

array #(.width($bits(lc3b_c_tag)), .sets(NUM_L1_SETS), .index_length($bits(lc3b_c_index))) tag_array_1
(
	.clk,
	.write(tag1_w),
	.index(index),
	.datain(tag),
	.dataout(tag1_out)
);

array #(.width(128), .sets(NUM_L1_SETS), .index_length($bits(lc3b_c_index))) data_array_1
(
	.clk(clk),
	.write(data1_w),
	.index(index),
	.datain(data_in),
	.dataout(data1_out)
);

// Output
always_comb
begin
	case(hit1)
	1'b0: data_way_mux_out = data0_out;
	1'b1: data_way_mux_out = data1_out;
	default: data_way_mux_out = 0;
	endcase
end
//mux2 #(.width(128)) data_way_mux
//(
//	.sel(hit1),
//	.a(data0_out),
//	.b(data1_out),
//	.f(data_way_mux_out)
//);
always_comb
begin
	case(offset)
	3'b000: mem_rdata = data_way_mux_out[15:0];
	3'b001: mem_rdata = data_way_mux_out[31:16];
	3'b010: mem_rdata = data_way_mux_out[47:32];
	3'b011: mem_rdata = data_way_mux_out[63:48];
	3'b100: mem_rdata = data_way_mux_out[79:64];
	3'b101: mem_rdata = data_way_mux_out[95:80];
	3'b110: mem_rdata = data_way_mux_out[111:96];
	3'b111: mem_rdata = data_way_mux_out[127:112];
	default: mem_rdata = 16'd0;
	endcase
end

//mux8 #(.width(16)) data_word_mux
//(
//	.sel(offset),
//	.a(data_way_mux_out[15:0]),
//	.b(data_way_mux_out[31:16]),
//	.c(data_way_mux_out[47:32]),
//	.d(data_way_mux_out[63:48]),
//	.e(data_way_mux_out[79:64]),
//	.f(data_way_mux_out[95:80]),
//	.g(data_way_mux_out[111:96]),
//	.h(data_way_mux_out[127:112]),
//	.out(mem_rdata)
//);
									
mux2 #(.width(128)) write_back_mux
(
	.sel(lru),
	.a(data0_out),
	.b(data1_out),
	.f(l2_mem_wdata)
);

mux4 #(.width(16)) l2_mem_address_mux
(
	.sel(l2_mem_address_mux_sel),
	.a(mem_address),
	.b({tag0_out,index,4'h0}),
	.c({tag1_out,index,4'h0}),
	.d(),
	.f(l2_mem_address)
);

// Input

mux2 #(.width(128)) data_in_mux
(
	.sel(data_in_mux_sel),
	.a(l2_mem_rdata),
	.b(new_line),
	.f(data_in)
);

line_builder line_builder
(
	.mem_wdata(mem_wdata),
	.mem_byte_enable(mem_byte_enable),
	.offset(offset),
	.data_in(data_way_mux_out),
	.new_line(new_line)
);

endmodule : l1_cache_datapath