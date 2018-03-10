import lc3b_types::*;

module forwarding_unit
(

	input lc3b_reg id_sr1_id,
	input lc3b_reg id_sr2_id,
	
	input lc3b_reg ex_sr1_id,
	input lc3b_reg ex_sr2_id,
	
	input lc3b_reg mem_dest,
	input lc3b_reg wb_dest,
	
	input mem_load_regfile,
	input wb_load_regfile,
	
	output logic id_sr1_forwarding_mux_sel,
	output logic id_sr2_forwarding_mux_sel,
	
	output logic [1:0] ex_sr1_forwarding_mux_sel,
	output logic [1:0] ex_sr2_forwarding_mux_sel,
	
	input lc3b_reg mem_sr2_id,
	output logic mem_sr2_forwarding_mux_sel
);

always_comb
begin
	ex_sr1_forwarding_mux_sel = 2'b00;
	ex_sr2_forwarding_mux_sel = 2'b00;

	if (mem_load_regfile && (mem_dest == ex_sr1_id))
		begin
			// EX -> EX SR1 Forwarding
			ex_sr1_forwarding_mux_sel = 2'b01;
		end
	else if (wb_load_regfile && (wb_dest == ex_sr1_id))
		begin
			// MEM -> EX SR1 Forwarding
			ex_sr1_forwarding_mux_sel = 2'b10;
		end
		
	if (mem_load_regfile && (mem_dest == ex_sr2_id))
		begin
			// EX -> EX SR2 Forwarding
			ex_sr2_forwarding_mux_sel = 2'b01;
		end
	else if (wb_load_regfile && (wb_dest == ex_sr2_id))
		begin
			// MEM -> EX SR2 Forwarding
			ex_sr2_forwarding_mux_sel = 2'b10;
		end
	
end

always_comb
begin
	mem_sr2_forwarding_mux_sel = 1'b0;
	
	if (wb_load_regfile && (wb_dest == mem_sr2_id))
		begin
			// MEM -> MEM SR2 Forwarding
			mem_sr2_forwarding_mux_sel = 1'b1;
		end
end

always_comb
begin
	id_sr1_forwarding_mux_sel = 1'b0;
	id_sr2_forwarding_mux_sel = 1'b0;
	
	if(wb_load_regfile && (wb_dest == id_sr2_id))
	begin
		id_sr2_forwarding_mux_sel = 1'b1;
	end
	if(wb_load_regfile && (wb_dest == id_sr1_id))
	begin
		id_sr1_forwarding_mux_sel = 1'b1;
	end
end


endmodule: forwarding_unit