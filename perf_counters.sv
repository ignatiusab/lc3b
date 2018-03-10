import lc3b_types::*;

module perf_counters
(
	input clk,
	
	input lc3b_word address,
	input logic clear,
	output lc3b_word counter_rdata,
	
	input logic i_cache_hit, i_cache_miss,
	input logic d_cache_hit, d_cache_miss,
	input logic l2_cache_hit, l2_cache_miss,
	input logic i_cache_stall, d_cache_stall,
	input logic non_cond_stall,
	input logic br_mispredict,
	input logic total_branches,
	input logic is_instruction
);

lc3b_word internal_address;
assign internal_address = {address[15], address[15:1]};

logic [20:0] i_cache_hit_counter;			// offset: -1
logic [19:0] i_cache_miss_counter;			// offset: -2
logic [19:0] d_cache_hit_counter;			// offset: -3
logic [19:0] d_cache_miss_counter;			// offset: -4
logic [19:0] l2_cache_hit_counter;			// offset: -5
logic [19:0] l2_cache_miss_counter;		// offset: -6
logic [19:0] i_cache_stall_counter;		// offset: -7
logic [19:0] d_cache_stall_counter;		// offset: -8
logic [19:0] non_cond_stall_counter;		// offset: -9
logic [19:0] br_mispredict_counter;		// offset: -10
logic [19:0] br_correct_predict_counter;	// offset: -11
logic [19:0] total_branches_counter;		// offset: -12
logic [21:0] total_instructions;

initial
begin
	i_cache_hit_counter = 21'd0; //Offset: -1
	i_cache_miss_counter = 20'd0;//Offset: -2
	d_cache_hit_counter = 20'd0;//Offset: -3
	d_cache_miss_counter = 20'd0;//Offset: -4
	l2_cache_hit_counter = 20'd0;//Offset: -5
	l2_cache_miss_counter = 20'd0;//Offset: -6
	i_cache_stall_counter = 20'd0;//Offset: -7
	d_cache_stall_counter = 20'd0;//Offset: -8
	non_cond_stall_counter = 20'd0;//Offset: -9
	br_mispredict_counter = 20'd0;//Offset: -10
	total_branches_counter = 20'd0;//Offset: -12
	total_instructions = 22'd0;
end

always_comb
begin
	case (internal_address)
	
		16'hffff : counter_rdata = i_cache_hit_counter[15:0];
		
		16'hfffe : counter_rdata = i_cache_miss_counter[15:0];
		
		16'hfffd : counter_rdata = d_cache_hit_counter[15:0];
		
		16'hfffc : counter_rdata = d_cache_miss_counter[15:0];
		
		16'hfffb : counter_rdata = l2_cache_hit_counter[15:0];
		
		16'hfffa : counter_rdata = l2_cache_miss_counter[15:0];
		
		16'hfff9 : counter_rdata = i_cache_stall_counter[15:0];
		
		16'hfff8 : counter_rdata = d_cache_stall_counter[15:0];
		
		16'hfff7 : counter_rdata = non_cond_stall_counter[15:0];
		
		16'hfff6 : counter_rdata = br_mispredict_counter[15:0];
		
		16'hfff5 : counter_rdata = br_correct_predict_counter[15:0];
		
		16'hfff4 : counter_rdata = total_branches_counter[15:0];
		
		default : counter_rdata = 16'd0;
	endcase
end

always_ff @( posedge clk)
begin
	if(clear && internal_address == 16'hffff)
		i_cache_hit_counter <= 0;
	else if(i_cache_hit)
		i_cache_hit_counter <= i_cache_hit_counter + 16'd1;
	else
		i_cache_hit_counter <= i_cache_hit_counter;
		
	if(clear && internal_address == 16'hfffe)
		i_cache_miss_counter <= 0;
	else if(i_cache_miss)
		i_cache_miss_counter <= i_cache_miss_counter + 16'd1;
	else
		i_cache_miss_counter <= i_cache_miss_counter;
		
	if(clear && internal_address == 16'hfffd)
		d_cache_hit_counter <= 0;
	else if(d_cache_hit)
		d_cache_hit_counter <= d_cache_hit_counter + 16'd1;
	else
		d_cache_hit_counter <= d_cache_hit_counter;
		
	if(clear && internal_address == 16'hfffc)
		d_cache_miss_counter <= 0;
	else if(d_cache_miss)
		d_cache_miss_counter <= d_cache_miss_counter + 16'd1;
	else
		d_cache_miss_counter <= d_cache_miss_counter;
		
	if(clear && internal_address == 16'hfffb)
		l2_cache_hit_counter <= 0;
	else if(l2_cache_hit)
		l2_cache_hit_counter <= l2_cache_hit_counter + 16'd1;
	else
		l2_cache_hit_counter <= l2_cache_hit_counter;
		
	if(clear && internal_address == 16'hfffa)
		l2_cache_miss_counter <= 0;
	else if(l2_cache_miss)
		l2_cache_miss_counter <= l2_cache_miss_counter + 16'd1;
	else
		l2_cache_miss_counter <= l2_cache_miss_counter;
	
	if(clear && internal_address == 16'hfff4)
		total_branches_counter <= 0;
	else if(total_branches)
		total_branches_counter <= total_branches_counter + 16'd1;
	else
		total_branches_counter <= total_branches_counter;
		
	if(clear && internal_address == 16'hfff6)
		br_mispredict_counter <= 0;
	else if(br_mispredict)
		br_mispredict_counter <= br_mispredict_counter + 16'd1;
	else
		br_mispredict_counter <= br_mispredict_counter;
		
	if(is_instruction)
		total_instructions <= total_instructions + 16'd1;
	else
		total_instructions <= total_instructions;
		
end

logic i_cache_stall_reg_out, d_cache_stall_reg_out, non_cond_stall_reg_out;

register #(.width(1)) i_cache_stall_reg
(
	.clk,
	.load(1'b1),
	.in(i_cache_stall),
	.out(i_cache_stall_reg_out)
);

register #(.width(1)) d_cache_stall_reg
(
	.clk,
	.load(1'b1),
	.in(d_cache_stall),
	.out(d_cache_stall_reg_out)
);

register #(.width(1)) non_cond_stall_reg
(
	.clk,
	.load(1'b1),
	.in(non_cond_stall),
	.out(non_cond_stall_reg_out)
);

always_ff @( posedge clk)
begin
	if(clear && internal_address == 16'hfff9)
		i_cache_stall_counter <= 0;
	else if(i_cache_stall & ~i_cache_stall_reg_out)
		i_cache_stall_counter <= i_cache_stall_counter + 16'd1;
	else
		i_cache_stall_counter <= i_cache_stall_counter;
end

always_ff @( posedge clk)
begin
	if(clear && internal_address == 16'hfff8)
		d_cache_stall_counter <= 0;
	else if(d_cache_stall & ~d_cache_stall_reg_out)
		d_cache_stall_counter <= d_cache_stall_counter + 16'd1;
	else
		d_cache_stall_counter <= d_cache_stall_counter;
end

always_ff @( posedge clk)
begin
	if(clear && internal_address == 16'hfff7)
		non_cond_stall_counter <= 0;
	else if(non_cond_stall & ~non_cond_stall_reg_out)
		non_cond_stall_counter <= non_cond_stall_counter + 16'd1;
	else
		non_cond_stall_counter <= non_cond_stall_counter;
end

always_comb
begin
	br_correct_predict_counter = total_branches_counter - br_mispredict_counter;
end

endmodule : perf_counters