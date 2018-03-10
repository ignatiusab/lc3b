import lc3b_types::*;

module l1_cache_control
(
    input clk,
	
	// input signals from cache_datapath
	input dirty0, dirty1,
	input hit0, hit1,
	input lru,
	
	// output signals to cache_datapath
	output logic data_in_mux_sel,
	output logic [1:0] l2_mem_address_mux_sel,
	
	// write signals
	output logic lru_w,
	output logic dirty0_w, valid0_w, tag0_w, data0_w,
	output logic dirty1_w, valid1_w, tag1_w, data1_w,
	
	// memory input signals
	input mem_read, mem_write,
	
	// memory output signals
	output logic mem_resp,
	
	// physical memory input signals
	input l2_mem_resp,
	
	// physical memory output signals
	output logic l2_mem_write, l2_mem_read,
	
	output logic cache_hit, cache_miss
);



enum int unsigned {
	hit, write_back, replace
} state, next_state;

always_comb
begin : state_actions
	
	data_in_mux_sel = 1'b0;
	l2_mem_address_mux_sel = 2'b00;
	lru_w = 1'b0;
	dirty0_w = 1'b0;
	valid0_w = 1'b0;
	tag0_w = 1'b0;
	data0_w = 1'b0;
	dirty1_w = 1'b0;
	valid1_w = 1'b0;
	tag1_w = 1'b0;
	data1_w = 1'b0;
	mem_resp = 1'b0;
	l2_mem_write = 1'b0;
	l2_mem_read = 1'b0;
	cache_hit = 1'b0;
	
	case (state)
	
		hit: begin
			if ( mem_read == 1'b1 && (hit0 == 1'b1 || hit1 == 1'b1) )
				begin
					// successful read hit
					cache_hit = 1'b1;
					mem_resp = 1'b1;
					lru_w = 1'b1;
				end
			else if ( mem_write == 1'b1 && (hit0 == 1'b1 || hit1 == 1'b1) )
				begin
					cache_hit = 1'b1;
					mem_resp = 1'b1;
					lru_w = 1'b1;
					data_in_mux_sel = 1'b1;
					if (hit0 == 1'b1)
						begin
							// successful write to WAY 0
							dirty0_w = 1'b1;
							valid0_w = 1'b1;
							tag0_w = 1'b1;
							data0_w = 1'b1;
						end
					else
						begin
							// successful write to WAY 1
							dirty1_w = 1'b1;
							valid1_w = 1'b1;
							tag1_w = 1'b1;
							data1_w = 1'b1;
						end
				end
		end
		
		write_back: begin
			// write line back to physical memory
			if(mem_read != 1'b0 || mem_write != 1'b0)
			begin
				l2_mem_write = 1'b1;
				if (lru == 1'b0)
					l2_mem_address_mux_sel = 2'b01;	// write back Way 0 line
				else
					l2_mem_address_mux_sel = 2'b10;	// write back Way 1 line
			end
		end
		
		replace: begin
			// replace line with new data from physical memory
			if(mem_read != 1'b0 || mem_write != 1'b0)
			begin
				l2_mem_read = 1'b1;
				if (lru == 1'b0)
					begin
						// write new data to Way 0
						if (l2_mem_resp == 1'b1) begin
							dirty0_w = 1'b1;
							valid0_w = 1'b1;
							tag0_w = 1'b1;
							data0_w = 1'b1;	// wait until physical memory is ready before writing data
						end
					end
				else
					begin
						// write new data to Way 1
						if (l2_mem_resp == 1'b1) begin
							dirty1_w = 1'b1;
							valid1_w = 1'b1;
							tag1_w = 1'b1;
							data1_w = 1'b1;	// wait until physical memory is ready before writing data
						end
					end
			end
		end
		
		default: /* do nothing */;
		
	endcase
end

always_comb
begin : next_state_logic
	next_state = state;
	cache_miss = 1'b0;
    case (state)
		
		hit: begin
			if ( (hit0 == 1'b1 || hit1 == 1'b1) || (mem_write == 1'b0 && mem_read == 1'b0) )
			begin
				// stay in hit state for hits or when memory is not being used
				next_state = hit;
				cache_miss = 1'b0;
			end
			else
				begin
					cache_miss = 1'b1;
					if ( (lru == 1'b0 && dirty0 == 1'b1) || (lru == 1'b1 && dirty1 == 1'b1) )
						// line is dirty, write line back to physical memory
						next_state = write_back;
					else
						// line is clean, immediately replace
						next_state = replace;
				end
		end
		
		write_back: begin
			if(mem_read == 0 && mem_write == 0)
				next_state = hit;
			else if (l2_mem_resp == 1'b1)
				// go directly to replace state once physical memory finishes
				// next_state = hit;
				next_state = replace;
			else
				// stay in write_back while physical memory is working
				next_state = write_back;
		end
		
		replace: begin
			if(mem_read == 0 && mem_write == 0)
				next_state = hit;
			else 
			if (l2_mem_resp == 1'b1)
				// go back to hit state once physical memory finishes
				next_state = hit;
			else
				// stay in replace while physical memory is working
				next_state = replace;
		end
		
		default: next_state = hit;
		
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    state <= next_state;
end

endmodule : l1_cache_control