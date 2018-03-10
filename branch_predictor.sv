import lc3b_types::*;

module branch_predictor
(	
	input logic clk,
	input [3:0] opcode,
	input logic pc_offset_sign,
	input logic take_jump, wb_take_jump,
	
	input logic wb_predict_taken,
	input logic wb_predictor,
	
	input lc3b_opcode mem_opcode,
	input logic mem_predict_taken,
	
	input logic mem_is_nop,
	input logic bad_uncond_jump,
	input logic if_btb_hit,
	
	input lc3b_word lookup_pc, resolved_pc,
	input logic update_branch_history,
	
	output logic br_is_uncond,
	output logic flush,
	output logic flush_pc_sel,
	output logic predict_taken,
	output logic predictor
);

logic btfnt_predict_taken, global_predict_taken, local_predict_taken;
logic [1:0] tournament_counter;

//assign predict_taken = global_predict_taken;

/*********************************************************
 ***************** Tournament Predictor ******************
 *********************************************************/
 
// predictor signal - 0 = local ; 1 = global
initial
begin
	tournament_counter = 2'b01; //initialize at weakly local
end

assign predictor = tournament_counter[1];

always_comb
begin
	if (tournament_counter[1] == 1'b0)
		predict_taken = local_predict_taken;
	else
		predict_taken = global_predict_taken;
end

always_ff @(posedge clk)
begin
	if (update_branch_history)
	begin
		casez ({wb_predictor, tournament_counter})
		
		3'b0?0 : begin
			if (wb_take_jump != wb_predict_taken)
			begin
				tournament_counter = 2'b01;
			end
			else
			begin
				tournament_counter = 2'b00;
			end
		end
		
		3'b0?1 : begin
			if (wb_take_jump != wb_predict_taken)
			begin
				tournament_counter = 2'b10;
			end
			else
			begin
				tournament_counter = 2'b00;
			end
		end
		
		3'b1?0 : begin
			if (wb_take_jump != wb_predict_taken)
			begin
				tournament_counter = 2'b01;
			end
			else
			begin
				tournament_counter = 2'b11;
			end
		end
		
		3'b1?1 : begin
			if (wb_take_jump != wb_predict_taken)
			begin
				tournament_counter = 2'b10;
			end
			else
			begin
				tournament_counter = 2'b11;
			end
		end
		
		endcase
	end
end

/*********************************************************
 ******************** BTFNT Predictor ********************
 *********************************************************/
 
always_comb
begin
	btfnt_predict_taken = 1'b0;
	flush_pc_sel = 1'b0;
	case(opcode)
	op_br:	begin
		if(pc_offset_sign)	// backwards -> predict taken
		begin
			btfnt_predict_taken = 1'b1;
			flush_pc_sel = predict_taken;
		end
		else
		begin
			btfnt_predict_taken = if_btb_hit;
			flush_pc_sel = predict_taken;
		end
	end
	op_jmp:	begin
		btfnt_predict_taken = if_btb_hit;
		
	end
	op_jsr:	begin
		btfnt_predict_taken = if_btb_hit;
		
	end
	op_trap:	begin
		btfnt_predict_taken = if_btb_hit;
	end
	default: /* nada */;
	endcase
end

/*********************************************************
 ******************** Global Predictor *******************
 *********************************************************/
logic global_predictor_out;
 
global_branch_history_predictor	global_predictor
(
	.clk,
	.wb_take_jump,
	.update_branch_history,
	.lookup_pc, 
	.resolved_pc,
	.predict_taken(global_predictor_out)
);
logic[1:0] global_predict_taken_mux_sel;

always_comb
begin
	if(opcode == op_br)
		global_predict_taken_mux_sel = 2'b00;
	else if (opcode == op_jmp || opcode == op_jsr || opcode == op_trap)
		global_predict_taken_mux_sel = 2'b01;
	else
		global_predict_taken_mux_sel = 2'b10;
end

mux4 #(.width(1)) global_predict_taken_mux
(
	.sel(global_predict_taken_mux_sel),
	.a(global_predictor_out | if_btb_hit), //global for BR
	.b(if_btb_hit), //for JMP/JSR/JSRR/RET/TRAP
	.c(1'b0), //NON BRANCH
	.d(1'b0),
	.f(global_predict_taken)
);

/*********************************************************
 ******************** Local Predictor *******************
 *********************************************************/
logic local_predictor_out;
 
local_branch_history_predictor	local_predictor
(
	.clk,
	.wb_take_jump,
	.update_branch_history,
	.lookup_pc, 
	.resolved_pc,
	.predict_taken(local_predictor_out)
);
logic[1:0] local_predict_taken_mux_sel;

always_comb
begin
	if(opcode == op_br)
		local_predict_taken_mux_sel = 2'b00;
	else if (opcode == op_jmp || opcode == op_jsr || opcode == op_trap)
		local_predict_taken_mux_sel = 2'b01;
	else
		local_predict_taken_mux_sel = 2'b10;
end

mux4 #(.width(1)) local_predict_taken_mux
(
	.sel(local_predict_taken_mux_sel),
	.a(local_predictor_out | if_btb_hit), //local for BR
	.b(if_btb_hit), //for JMP/JSR/JSRR/RET/TRAP
	.c(1'b0), //NON BRANCH
	.d(1'b0),
	.f(local_predict_taken)
);

// Unconditional decoding

always_comb
begin
	case(opcode)
		op_jmp: begin
			br_is_uncond = 1'b1;
		end
		op_jsr: begin
			br_is_uncond = 1'b1;
		end
		op_trap: begin
			br_is_uncond = 1'b1;
		end
		default: br_is_uncond = 1'b0;
	endcase
end

// checker - fixes prediction mistakes
always_comb
begin
	flush = 1'b0;

	if ( (mem_opcode == op_br && ~mem_is_nop  && mem_predict_taken != take_jump) || 
			(mem_opcode == op_jmp && bad_uncond_jump) || (mem_opcode == op_jsr && bad_uncond_jump) || 
			(mem_opcode == op_trap && bad_uncond_jump)  ) 
	begin
		flush = 1'b1;
	end
end

endmodule : branch_predictor