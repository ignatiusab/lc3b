import lc3b_types::*;

module arb_control
(
    input clk,
	
	
	input logic 		imem_read, dmem_read, imem_write, dmem_write,
	input logic			L2_mem_resp,
	
	//Arbiter datapath mux signals
	output logic				arb_mem_address_mux_sel, arb_mem_read_mux_sel,
									arb_mem_write_mux_sel, arb_mem_wdata_mux_sel,
									arb_mem_rdata_mux_sel, arb_mem_resp_mux_sel,
									L2_mem_read_write_mux_sel,
									//arb_mem_byte_enable_mux_sel
	output logic				load_L2_mem_reg
);

enum int unsigned {
	idle, dcache_service, icache_service, finished
} state, next_state;

always_comb
begin : state_actions
	
	arb_mem_address_mux_sel = 1;
	arb_mem_read_mux_sel = 1;
	arb_mem_write_mux_sel = 1;
	arb_mem_wdata_mux_sel = 1;
	arb_mem_rdata_mux_sel = 1;
	arb_mem_resp_mux_sel = 1;
	//arb_mem_byte_enable_mux_sel = 1;
	load_L2_mem_reg = 1;
	L2_mem_read_write_mux_sel = 0;
	
	case (state)
	
		idle: begin
			//Default is OK
			
		end
		
		dcache_service: begin
			//Default is OK
			arb_mem_rdata_mux_sel= 1;
			arb_mem_resp_mux_sel = 1;
			// if next state is going to be icache_service, immediately switch arbiter
			if (L2_mem_resp)
				begin
					arb_mem_address_mux_sel = 0;
					arb_mem_read_mux_sel = 0;
					arb_mem_write_mux_sel = 0;
					arb_mem_wdata_mux_sel = 0;
					L2_mem_read_write_mux_sel = 1;
				end
		end
		
		icache_service: begin

			arb_mem_rdata_mux_sel = 0;
			arb_mem_resp_mux_sel = 0;
			
			if(L2_mem_resp)
			begin
					arb_mem_address_mux_sel = 1;
					arb_mem_read_mux_sel = 1;
					arb_mem_write_mux_sel = 1;
					arb_mem_wdata_mux_sel = 1;
					L2_mem_read_write_mux_sel = 1;
			end
			else
			begin
				arb_mem_address_mux_sel = 0;
					arb_mem_read_mux_sel = 0;
					arb_mem_write_mux_sel = 0;
					arb_mem_wdata_mux_sel = 0;
			end
//			// if next state is d_cache, immediately switch arbiter
//			if (~(L2_mem_resp && (dmem_read || dmem_write)))
//				begin
//					arb_mem_address_mux_sel = 0;
//					arb_mem_read_mux_sel = 0;
//					arb_mem_write_mux_sel = 0;
//					arb_mem_wdata_mux_sel = 0;
//				end
		end
		
		finished: begin
			L2_mem_read_write_mux_sel = 1;
		end
		
		default: /* do nothing */;
		
	endcase
end

always_comb
begin : next_state_logic
	next_state = state;
	
    case (state)
		
		idle: begin
			if((dmem_read || dmem_write) && L2_mem_resp)
				next_state = finished;
			else if( (dmem_read || dmem_write))
				next_state = dcache_service;
			else if ( (imem_read || imem_write))
				next_state = icache_service;
			else
				next_state = idle;
		end
		
		dcache_service: begin
			if(L2_mem_resp == 1)
			begin
				next_state = finished;
//				if(imem_read || imem_write)
//					next_state = icache_service;
//				else
//					next_state = idle;
			end
			else
				next_state = dcache_service;
		end
		
		icache_service: begin
			if(L2_mem_resp == 1)
			begin
				next_state = finished;
//				if(dmem_read || dmem_write)
//					next_state = dcache_service;
//				else
//					next_state = idle;
			end
			else
				next_state = icache_service;
		end
		
		finished: begin
			next_state = idle;
		end
		default: next_state = idle;
		
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    state <= next_state;
end

endmodule : arb_control