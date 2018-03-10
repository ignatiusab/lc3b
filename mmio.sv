import lc3b_types::*;

module mmio
(
	input logic				dmem_read, 
	input logic				dmem_write,
	input lc3b_word			dmem_address,
	input lc3b_word			dmem_wdata,
	
	output logic			dmem_resp,
	output lc3b_word		dmem_rdata,
	
	input logic				l1_mem_resp,
	input lc3b_word			l1_mem_rdata,
	
	output logic			l1_mem_read, 
	output logic			l1_mem_write,
	output lc3b_word		l1_mem_address,
	output lc3b_word		l1_mem_wdata,
	
	input lc3b_word			counter_rdata,
	output logic 			clear
);

logic counter_sel;

assign l1_mem_wdata = dmem_wdata;
assign l1_mem_address = dmem_address;

always_comb
begin
//	counter_sel = 1'b0;
//	clear = 1'b0;
	if (dmem_address[15:8] == 8'hff)
	begin
		counter_sel = 1'b1;
		clear = dmem_write;
	end
	else
	begin
		counter_sel = 1'b0;
		clear = 1'b0;
	end
end

always_comb
begin
	case(counter_sel)
	1'b0:	begin
			l1_mem_read = dmem_read;
			l1_mem_write = dmem_write;
			dmem_resp = l1_mem_resp;
			dmem_rdata = l1_mem_rdata;
			end
	1'b1:	begin
			l1_mem_read = 1'b0;
			l1_mem_write = 1'b0;
			dmem_resp = 1'b1;
			dmem_rdata = counter_rdata;
			end
	endcase
end


endmodule : mmio