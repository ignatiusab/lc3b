import lc3b_types::*;

module eviction_write_buffer_modified
(
	input clk, 
	
	// memory input signals
	input ewb_mem_read, ewb_mem_write,
	input lc3b_word ewb_mem_address, 
	input lc3b_c2_line ewb_mem_wdata,
	
	// memory output signals
	output logic ewb_mem_resp,
	output lc3b_c2_line ewb_mem_rdata,
	
	// physical memory input signals
	input pmem_resp,
	input lc3b_c2_line pmem_rdata,
	
	// physical memory output signals
	output logic pmem_read, pmem_write,
	output lc3b_word pmem_address,
	output lc3b_c2_line pmem_wdata
);

lc3b_c2_line ewb_data_out;
lc3b_word ewb_address_out;
logic ewb_load_data, ewb_load_valid;
logic ewb_valid_in, ewb_valid_out;
logic ewb_rdata_mux_sel, pmem_address_mux_sel;
logic pmem_resp_out, pmem_read_in, pmem_write_in;
lc3b_word pmem_address_in;
lc3b_c2_line pmem_rdata_out, pmem_wdata_in;

//assign pmem_address = ewb_address_out;
assign pmem_wdata_in = ewb_data_out;

//Mux for address to be sent to physical memory
//Sends ewb_mem_address(from L2) unless we are writing back to memory
//from this EWB (use stored address)
mux2 #(.width($bits(lc3b_word))) pmem_address_mux
(
	.sel(pmem_address_mux_sel),
	.a(ewb_mem_address),
	.b(ewb_address_out),
	.f(pmem_address_in)
);

register #(.width($bits(lc3b_c2_line))) ewb_data
(
    .clk,
    .load(ewb_load_data),
    .in(ewb_mem_wdata),
    .out(ewb_data_out)
);

register #(.width($bits(lc3b_word))) ewb_address
(
    .clk,
    .load(ewb_load_data),
    .in(ewb_mem_address),
    .out(ewb_address_out)
);

register #(.width(1)) ewb_data_valid
(
    .clk,
    .load(ewb_load_valid),
    .in(ewb_valid_in),
    .out(ewb_valid_out)
	
);

mux2 #(.width($bits(lc3b_c2_line))) ewb_rdata_mux
(
	.sel(ewb_rdata_mux_sel),
	.a(pmem_rdata_out),
	.b(ewb_data_out),
	.f(ewb_mem_rdata)
);


register #(.width(1)) read_reg
(
	.clk,
	.load(1'b1),
	.in(pmem_read_in),
	.out(pmem_read)
);
register #(.width(1)) write_reg
(
	.clk,
	.load(1'b1),
	.in(pmem_write_in),
	.out(pmem_write)
);

register #(.width(256)) wdata_reg
(
	.clk,
	.load(1'b1),
	.in(pmem_wdata_in),
	.out(pmem_wdata)
);


register #(.width(16)) address_reg
(
	.clk,
	.load(1'b1),
	.in(pmem_address_in),
	.out(pmem_address)
);


//FROM PMEM
register #(.width(1)) resp_reg
(
	.clk,
	.load(1'b1),
	.in(pmem_resp),
	.out(pmem_resp_out)
);

register #(.width(256)) rdata_reg
(
	.clk,
	.load(1'b1),
	.in(pmem_rdata),
	.out(pmem_rdata_out)
);



enum int unsigned {
	empty_buffer, write_back_buffer, hold_data
} state, next_state;

always_comb
begin : state_actions
	
	ewb_load_data = 1'b0;
	ewb_load_valid = 1'b0;
	ewb_valid_in = 1'b0;
	ewb_mem_resp = 1'b0;
	pmem_read_in = 1'b0;
	pmem_write_in = 1'b0;
	ewb_rdata_mux_sel = 1'b0;
	pmem_address_mux_sel = 1'b0; //By default, we pass through the address
	
	case (state)
	
		empty_buffer: begin
			if(ewb_mem_write)
			begin
				ewb_mem_resp = 1'b1;
				ewb_load_data = 1'b1;
				ewb_load_valid = 1'b1;
				ewb_valid_in = 1'b1;
			end
			else
			begin
				pmem_read_in = ewb_mem_read;
				ewb_mem_resp = pmem_resp_out;
			end
		end
		
		write_back_buffer: begin
			pmem_address_mux_sel = 1'b1; //During write-back, we use the stored address
			
			/*
			if (ewb_mem_read && ewb_mem_address != ewb_address_out)
			begin
				pmem_write = 1'b0;
				pmem_read = ewb_mem_read;
				ewb_mem_resp = pmem_resp;
				
			end
			else
				*/
			pmem_write_in = 1'b1;
			if(~pmem_resp_out)
			begin
				
				if(ewb_mem_read && ewb_mem_address == ewb_address_out)
				begin
					ewb_mem_resp = 1'b1;
					ewb_rdata_mux_sel = 1'b1;
				end
			end
			else
			begin
				//pmem_write = 1'b0;
				ewb_load_valid = 1'b1;
				if(ewb_mem_read && ewb_mem_address == ewb_address_out)
				begin
					ewb_mem_resp = 1'b1;
					ewb_rdata_mux_sel = 1'b1;
				end
				else if(ewb_mem_write)
				begin
					ewb_mem_resp = 1'b1;
					ewb_load_data = 1'b1;
					ewb_valid_in = 1'b1;
				end
				else
				begin
					ewb_valid_in = 1'b0;
				end
			end
		end
		
		hold_data: begin
			if(ewb_mem_read && ewb_mem_address == ewb_address_out)
			begin
				ewb_mem_resp = 1'b1;
				ewb_rdata_mux_sel = 1'b1;
			end
			else if (ewb_mem_read)
			begin
				pmem_read_in = ewb_mem_read;
				ewb_mem_resp = pmem_resp_out;
			end
			else
			begin
				//Initiate write
				//pmem_write = 1'b1;
				//pmem_address_mux_sel = 1'b1; //Use stored address for data in buffer
			end
		end
		
		default: /* do nothing */;
		
	endcase
end

always_comb
begin : next_state_logic
	next_state = state;
	
    case (state)
	
		empty_buffer: begin
			if(ewb_mem_write)
				next_state = hold_data;
			else
				next_state = empty_buffer;
		end
		
		write_back_buffer: begin
			if(ewb_mem_read && ewb_mem_address != ewb_address_out)
			begin
				next_state = hold_data;
			end
			else if(pmem_resp_out)
			begin
				if(ewb_mem_write)
					next_state = hold_data;
				else
					next_state = empty_buffer;
			end
			else
				next_state = write_back_buffer;
		end
		
		hold_data: begin
			if(~ewb_mem_read)
				next_state = write_back_buffer;
			else
				next_state = hold_data;
		end
		
		default: next_state = empty_buffer;
		
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    state <= next_state;
end


endmodule : eviction_write_buffer_modified