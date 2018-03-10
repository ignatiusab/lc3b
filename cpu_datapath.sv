
import lc3b_types::*;

module cpu_datapath
(
	input clk,
	
	// i-cache signals
	input logic					imem_resp,
	input lc3b_word			imem_rdata,
	output logic				imem_read,
	output logic				imem_write,
	output lc3b_word			imem_address,
	output lc3b_mem_wmask	imem_byte_enable,
	output lc3b_word			imem_wdata,
	
	// d-cache signals
	input logic					dmem_resp,
	input lc3b_word			dmem_rdata,
	output logic				dmem_read,	
	output logic				dmem_write,
	output lc3b_word			dmem_address,
	output lc3b_mem_wmask	dmem_byte_enable,
	output lc3b_word			dmem_wdata,
	
	//perf counter signals
	output logic i_cache_stall, d_cache_stall, branch_stall, flush, is_branch, is_instruction
);
assign imem_write = 0;

logic cc_comp_out;
lc3b_nzp gencc_out, cc_out;
lc3b_word wb_regfile_in;

logic id_is_nop, mem_is_nop, ex_is_nop, wb_is_nop;
lc3b_word mem_pc, wb_pc, wb_pcmux_out;
logic wb_check_target;
logic bad_uncond_jump;
lc3b_control_word id_cntrl, ex_cntrl, mem_cntrl, wb_cntrl;
logic pc_stall;


/*********************************************************************
 STAGE - IF - Instruction Fetch
*********************************************************************/
 
logic 		take_jump, wb_take_jump, if_predict_taken;
logic 		mem_predict_taken;
lc3b_word	mem_flush_pc;

lc3b_word id_btb_target_pc, ex_btb_target_pc, mem_btb_target_pc;

lc3b_word 	pc_out, pcmux_out, pc_plus2_out, take_jump_mux_out;
lc3b_word 	if_pc;		// this is incremented PC
lc3b_word 	predicted_pc, branch_predictor_pc_out;
logic [1:0] take_jump_mux_sel;
logic wb_predict_taken;
lc3b_word if_flush_pc, wb_flush_pc;
logic flush_pc_sel;
logic i_cache_stall_reg_out;

assign imem_read = 1'b1 & ~(((take_jump & ~mem_predict_taken) | flush | bad_uncond_jump) & i_cache_stall_reg_out);
assign i_cache_stall = ~imem_resp;
assign is_instruction = ~wb_is_nop;

// BTB signals
logic check_target;
logic btb_hit;
lc3b_word btb_target_pc;

register #(.width(1)) i_cache_stall_reg
(
	.clk,
	.load(1'b1),
	.in(i_cache_stall),
	.out(i_cache_stall_reg_out)
);

/**************************************************
 ********** IMEM_ADDRESS CALCULATION **************
 **************************************************/
assign imem_address = pc_out;
assign imem_byte_enable = 2'b11;
assign imem_wdata = 16'd0;
assign if_pc = pc_plus2_out;
assign pc_stall = i_cache_stall | d_cache_stall;


plus2 #(.width($bits(lc3b_word))) pc_plus2
(
	.in(pc_out),
	.out(pc_plus2_out)
);

mux4 take_jump_mux
(
	.sel(take_jump_mux_sel),
	.a(pc_plus2_out),
	.b(pcmux_out),
	.c(predicted_pc),
	.d(mem_flush_pc),
	.f(take_jump_mux_out)
);

always_comb
begin
	if (flush & ~mem_cntrl.is_uncond_control)
	begin
		take_jump_mux_sel <= 2'b11;
	end
	else if ((if_predict_taken || btb_hit) && ~(flush))
	begin
		take_jump_mux_sel <= 2'b10;
	end
	else
	begin
		take_jump_mux_sel <= {1'b0, (take_jump & ~mem_predict_taken) | (bad_uncond_jump) };
	end
end

adder #(.width($bits(lc3b_word))) branch_predictor_adder
(
	.a({{6{imem_rdata[8]}}, imem_rdata[8:0], 1'b0}),
	.b(pc_plus2_out),
	.sum(branch_predictor_pc_out)
);
logic br_is_uncond;

always_comb
begin
	case({ br_is_uncond ,btb_hit})
	2'b00: predicted_pc = branch_predictor_pc_out;
	2'b01: predicted_pc = btb_target_pc;
	2'b10: predicted_pc = pc_plus2_out;
	2'b11: predicted_pc = btb_target_pc;
	default: predicted_pc = 0;
	endcase
end
//mux4 btb_predictor_mux
//(
//	.sel({ br_is_uncond ,btb_hit}),
//	.a(branch_predictor_pc_out),
//	.b(btb_target_pc),
//	.c(pc_plus2_out),
//	.d(btb_target_pc),
//	.f(predicted_pc)
//);
logic if_predictor, id_predictor, ex_predictor, mem_predictor, wb_predictor;
// Branch Predictor
branch_predictor branch_predictor
(
	.clk,
	.opcode(imem_rdata[15:12]),
	.br_is_uncond,
	.pc_offset_sign(imem_rdata[8]),
	.take_jump(take_jump),
	.wb_take_jump(wb_take_jump),
	.mem_opcode(mem_cntrl.opcode),
	.mem_predict_taken(mem_predict_taken),
	.wb_predict_taken,
	.if_btb_hit(btb_hit),
	.bad_uncond_jump,
	.flush,
	.flush_pc_sel,
	
	.update_branch_history(wb_check_target),
	.lookup_pc(if_pc),
	.resolved_pc(wb_pc),
	
	.predictor(if_predictor),
	.wb_predictor,
	.predict_taken(if_predict_taken),
	.mem_is_nop
);

// Branch Target Buffer
branch_target_buffer branch_target_buffer
(
	.clk,
	.lookup_pc(pc_out), //changing
	.resolved_lookup_pc(wb_pc - 16'd2),
	.resolved_predicted_pc(wb_pcmux_out),
	.check_target(wb_check_target),
	.target_pc(btb_target_pc),
	.hit(btb_hit)
);

//assign btb_hit = 1'b0;
//assign btb_target_pc = 16'd0;

mux2 #(.width(16)) flush_pc_mux
(
	.sel(flush_pc_sel),
	.a(predicted_pc),
	.b(pc_plus2_out),
	.f(if_flush_pc)
);

register pc
(
    .clk,
    .load(~(pc_stall) | (take_jump & ~mem_predict_taken) | flush | bad_uncond_jump),
    .in(take_jump_mux_out),
    .out(pc_out)
);


/*********************************************************************
 STATE REGISTER - IF -> ID
*********************************************************************/

logic load_if_id;
lc3b_word		id_pc;
lc3b_opcode 	opcode;
lc3b_reg 		id_dest, id_sr1, id_sr2;
lc3b_offset6 	offset6;
lc3b_trapvect8 	trapvect8;
lc3b_offset9 	offset9;
lc3b_offset11 	offset11;
lc3b_imm5		imm5;
lc3b_imm4 		imm4;
logic 			bit5, bit4, bit11;
logic 			id_predict_taken;
lc3b_word		id_flush_pc;

assign load_if_id = ~(d_cache_stall) & ~(branch_stall & i_cache_stall); //needs to be changed

if_id_state_reg if_id_state_reg
(
	.clk,
	.flush,
	.load_if_id,
	.i_cache_stall(i_cache_stall),
	.branch_stall(branch_stall),
	.if_id_pc_in(if_pc),
	.if_id_pc_out(id_pc),
	
	.if_id_branch_prediction_in(if_predict_taken),
	.if_id_branch_prediction_out(id_predict_taken),
	
	.if_id_predictor_in(if_predictor),
	.if_id_predictor_out(id_predictor),
	
	.if_id_btb_target_pc_in(btb_target_pc),
	.if_id_btb_target_pc_out(id_btb_target_pc),
	
	.if_id_flush_pc_in(if_flush_pc),
	.if_id_flush_pc_out(id_flush_pc),
	
	.ir_input(imem_rdata),
	
	.opcode,
	.dest(id_dest),
	.sr1(id_sr1),
	.sr2(id_sr2),
	.offset6,
	.trapvect8,
	.offset9,
	.offset11,
	.imm5,
	.imm4,
	.bit5, .bit4, .bit11,
	.is_nop(id_is_nop)
);

/*********************************************************************
 STAGE - ID - Instruction Decode
*********************************************************************/

lc3b_word 	adj6_out, sext6_out;
lc3b_word 	zext8_out;
lc3b_word 	adj11_out, adj9_out;
lc3b_reg 	destmux_out, storemux_out, ex_dest, mem_dest, wb_dest, sr2mux_out;
lc3b_word 	id_zextvect8, id_zext4, id_sext5, id_off6, id_sr1_out, id_sr2_out;
lc3b_word 	id_adj_9_11;

/*********************
 Branch Resolutiong
**********************/

always_comb
begin	
	if ((wb_cntrl.opcode == op_br) || (wb_cntrl.opcode == op_jmp) || (wb_cntrl.opcode == op_jsr) || (wb_cntrl.opcode == op_trap) & ~wb_is_nop)
		is_branch <= 1'b1;
	else
		is_branch <= 1'b0;
end

//assign branch_stall = (id_branch_stall | ex_branch_stall | mem_branch_stall | wb_branch_stall);
assign branch_stall = 1'b0;
// Control ROM
control_rom 	CNTRL
(
	.opcode(opcode),
	.bit5,
	.bit4,
	.bit11,
	.cntrl(id_cntrl)
);

// SEXT, ZEXT, ADJ
adj #(.width(6)) adj6
(
	.in(offset6),
	.out(adj6_out)
);

sext #(.width(6)) sext6
(
	.in(offset6),
	.out(sext6_out)
);

mux2 offset6mux
(
	.sel(id_cntrl.offset6mux_sel),
	.a(adj6_out),
	.b(sext6_out),
	.f(id_off6)
);

sext #(.width(5)) sext5
(
	.in(imm5),
	.out(id_sext5)
);

zext #(.width(4)) zext4
(
	.in(imm4),
	.out(id_zext4)
);

zext #(.width(8)) zext8
(
	.in(trapvect8),
	.out(zext8_out)
);

adj #(.width(11)) adj11
(
	.in(offset11),
	.out(adj11_out)
);

adj #(.width(9)) adj9
(
	.in(offset9),
	.out(adj9_out)
);

mux2 adj_9_11_mux
(
	.sel(id_cntrl.adj_9_11_sel),
	.a(adj9_out),
	.b(adj11_out),
	.f(id_adj_9_11)
);

// Register File Components
mux2 #(.width($bits(lc3b_reg))) destmux
(
	.sel(id_cntrl.destmux_sel), // use dest from write_back stage
	.a(id_dest),
	.b(3'b111),
	.f(destmux_out)
);


mux2 #(.width($bits(lc3b_reg))) storemux
(
    .sel(id_cntrl.storemux_sel),
    .a(id_sr1),
    .b(id_dest),
    .f(storemux_out)
);

mux2 #(.width($bits(lc3b_reg))) sr2mux
(
	.sel(id_cntrl.sr2mux_sel),
	.a(id_sr2),
	.b(id_dest),
	.f(sr2mux_out)
);

regfile regfile
(
	.clk,
	.load(wb_cntrl.load_regfile),
	.in(wb_regfile_in),
	.src_a(storemux_out),
	.src_b(sr2mux_out),
	.dest(wb_dest),
	.reg_a(id_sr1_out),
	.reg_b(id_sr2_out)
);
logic id_sr1_forwarding_mux_sel, id_sr2_forwarding_mux_sel;
lc3b_word id_sr1_forwarding_mux_out, id_sr2_forwarding_mux_out;
mux2 #(.width($bits(lc3b_word))) id_sr1_forwarding_mux
(
	.sel(id_sr1_forwarding_mux_sel),
	.a(id_sr1_out),
	.b(wb_regfile_in),
	.f(id_sr1_forwarding_mux_out)
);

mux2 #(.width($bits(lc3b_word))) id_sr2_forwarding_mux
(
	.sel(id_sr2_forwarding_mux_sel),
	.a(id_sr2_out),
	.b(wb_regfile_in),
	.f(id_sr2_forwarding_mux_out)
);
/*********************************************************************
 STATE REGISTER - ID -> EX
*********************************************************************/

logic 		load_id_ex;
lc3b_nzp 	id_ir_nzp, ex_ir_nzp;
lc3b_word 	ex_zextvect8, ex_zext4, ex_sext5, ex_off6, ex_adj_9_11, ex_sr1, ex_sr2;
lc3b_word 	ex_pc;
lc3b_reg	ex_sr1_id, ex_sr2_id;
logic 		ex_predict_taken;
lc3b_word	ex_flush_pc;

assign load_id_ex = ~(d_cache_stall) & ~(branch_stall & i_cache_stall);
//assign load_id_ex = ~(stall);
assign id_ir_nzp = id_dest;
assign id_zextvect8 = zext8_out << 1;

id_ex_state_reg id_ex_state_reg
(
	.clk,
	.flush,
	.load_id_ex,
	
	.id_ex_pc_in(id_pc),
	.id_ex_pc_out(ex_pc),
	
	.id_ex_zextvect8_in(id_zextvect8),
	.id_ex_zextvect8_out(ex_zextvect8),
	
	.id_ex_zext4_in(id_zext4),
	.id_ex_zext4_out(ex_zext4),
	
	.id_ex_sext5_in(id_sext5),
	.id_ex_sext5_out(ex_sext5),
	
	.id_ex_off6_in(id_off6),
	.id_ex_off6_out(ex_off6), 
	
	.id_ex_adj_9_11_in(id_adj_9_11),
	.id_ex_adj_9_11_out(ex_adj_9_11),
	
	.id_ex_dest_in(destmux_out),
	.id_ex_dest_out(ex_dest),
	
	.id_ex_sr1_in(id_sr1_forwarding_mux_out),
	.id_ex_sr1_out(ex_sr1),
	
	.id_ex_sr2_in(id_sr2_forwarding_mux_out),
	.id_ex_sr2_out(ex_sr2),
						  
	.id_ex_ir_nzp_in(id_ir_nzp),
	.id_ex_ir_nzp_out(ex_ir_nzp),
	 
	.id_ex_cntrl_in(id_cntrl),
	.id_ex_cntrl_out(ex_cntrl),
	
	.id_ex_sr1_id_in(storemux_out),
	.id_ex_sr1_id_out(ex_sr1_id),
	
	.id_ex_sr2_id_in(sr2mux_out),
	.id_ex_sr2_id_out(ex_sr2_id),
	
	.id_ex_is_nop_in(id_is_nop),
	.id_ex_is_nop_out(ex_is_nop),
	
	.id_ex_branch_prediction_in(id_predict_taken),
	.id_ex_branch_prediction_out(ex_predict_taken),
	
	.id_ex_predictor_in(id_predictor),
	.id_ex_predictor_out(ex_predictor),
	
	.id_ex_btb_target_pc_in(id_btb_target_pc),
	.id_ex_btb_target_pc_out(ex_btb_target_pc),
	
	.id_ex_flush_pc_in(id_flush_pc),
	.id_ex_flush_pc_out(ex_flush_pc)
);

/*********************************************************************
 STAGE - EX - Execute
*********************************************************************/
lc3b_word 	ex_pc_adder_out;
lc3b_word 	ex_alu_out;
lc3b_word 	alumux_out, mem_alu_out;
//lc3b_word alu_mux_out; // mux for B operand of ALU
lc3b_word ex_sr2_high_low_out, ex_sr2_mux_out;
lc3b_word mem_to_ex_sr1_data, mem_to_ex_sr2_data;
logic [1:0] ex_sr1_forwarding_mux_sel, ex_sr2_forwarding_mux_sel;
lc3b_word ex_sr1_forwarding_mux_out, ex_sr2_forwarding_mux_out;

mux4 #(.width($bits(lc3b_word))) ex_sr1_forwarding_mux
(
	.sel(ex_sr1_forwarding_mux_sel),
	.a(ex_sr1),
	.b(mem_to_ex_sr1_data), //Not necessarily...
	.c(wb_regfile_in),
	.d(16'd0),
	.f(ex_sr1_forwarding_mux_out)
);

mux4 #(.width($bits(lc3b_word))) ex_sr2_forwarding_mux
(
	.sel(ex_sr2_forwarding_mux_sel),
	.a(ex_sr2),
	.b(mem_to_ex_sr2_data),
	.c(wb_regfile_in),
	.d(16'd0),
	.f(ex_sr2_forwarding_mux_out)
);

adder #(.width($bits(lc3b_word))) pc_adder
(
	.a(ex_adj_9_11),
	.b(ex_pc),
	.sum(ex_pc_adder_out)
);

high_low_byte_selector ex_sr2_high_low //Used for STB!
(
	.sel(ex_alu_out[0]), //LSB of mem_address computed from ALU in STB!
	.in(ex_sr2_forwarding_mux_out[7:0]),
	.out(ex_sr2_high_low_out)
);

mux2 ex_sr2_mux
(
	.sel(ex_cntrl.sr2_out_mux_sel),
	.a(ex_sr2_forwarding_mux_out),
	.b(ex_sr2_high_low_out),
	.f(ex_sr2_mux_out)
);

// ALU
mux4 alumux
(
	.sel(ex_cntrl.alumux_sel),
	.a(ex_sr2_forwarding_mux_out),
	.b(ex_off6),
	.c(ex_sext5),
	.d(ex_zext4),
	.f(alumux_out)
);

alu ALU
(
	.aluop(ex_cntrl.aluop),
	.a(ex_sr1_forwarding_mux_out),
	.b(alumux_out),
	.f(ex_alu_out)
);

/*********************************************************************
 COMPONENT - Forwarding Unit
*********************************************************************/

lc3b_reg mem_sr2_id;
logic mem_sr2_forwarding_mux_sel;

forwarding_unit forwarding_unit
(
	.id_sr1_id(storemux_out),
	.id_sr2_id(sr2mux_out),
	
	.ex_sr1_id(ex_sr1_id),
	.ex_sr2_id(ex_sr2_id),
	
	.mem_dest(mem_dest),
	.wb_dest(wb_dest),
	
	.mem_load_regfile(mem_cntrl.load_regfile),
	.wb_load_regfile(wb_cntrl.load_regfile),
	
	.id_sr1_forwarding_mux_sel,
	.id_sr2_forwarding_mux_sel,
	
	.ex_sr1_forwarding_mux_sel,
	.ex_sr2_forwarding_mux_sel,
	
	.mem_sr2_id(mem_sr2_id),
	.mem_sr2_forwarding_mux_sel
);

/*********************************************************************
 STATE REGISTER - EX -> MEM
*********************************************************************/

logic 		load_ex_mem;
lc3b_word 	mem_pc_adder_out, mem_zextvect8;
lc3b_nzp 	mem_ir_nzp;
lc3b_word 	mem_sr1, mem_sr2;

assign load_ex_mem = ~(d_cache_stall) & ~(branch_stall & i_cache_stall);

ex_mem_state_reg ex_mem_state_reg
(
    .clk,
	.flush,
	.load_ex_mem,
		
    .ex_mem_pc_in(ex_pc),
	.ex_mem_pc_out(mem_pc),
	
	.ex_mem_pc_adder_in(ex_pc_adder_out),
	.ex_mem_pc_adder_out(mem_pc_adder_out),
	
	.ex_mem_zextvect8_in(ex_zextvect8),
	.ex_mem_zextvect8_out(mem_zextvect8),
	
	.ex_mem_ir_nzp_in(ex_ir_nzp),
	.ex_mem_ir_nzp_out(mem_ir_nzp),
	
	.ex_mem_alu_in(ex_alu_out),
	.ex_mem_alu_out(mem_alu_out),
	
	.ex_mem_sr1_in(ex_sr1_forwarding_mux_out),
	.ex_mem_sr1_out(mem_sr1),
	
	.ex_mem_sr2_in(ex_sr2_mux_out),
	.ex_mem_sr2_out(mem_sr2),
	
	.ex_mem_dest_in(ex_dest),
	.ex_mem_dest_out(mem_dest),
	
	.ex_mem_cntrl_in(ex_cntrl),
	.ex_mem_cntrl_out(mem_cntrl),
	
	.ex_mem_sr2_id_in(ex_sr2_id),
	.ex_mem_sr2_id_out(mem_sr2_id),
	
	.ex_mem_is_nop_in(ex_is_nop),
	.ex_mem_is_nop_out(mem_is_nop),
	
	.ex_mem_branch_prediction_in(ex_predict_taken),
	.ex_mem_branch_prediction_out(mem_predict_taken),
	
	.ex_mem_predictor_in(ex_predictor),
	.ex_mem_predictor_out(mem_predictor),
	
	.ex_mem_btb_target_pc_in(ex_btb_target_pc),
	.ex_mem_btb_target_pc_out(mem_btb_target_pc),
	
	.ex_mem_flush_pc_in(ex_flush_pc),
	.ex_mem_flush_pc_out(mem_flush_pc)
);

/*********************************************************************
 STAGE - MEM - Memory
*********************************************************************/

lc3b_word 	mem_dmdr_out, dmdr_mux_out, dmem_rdata_reg_out;
lc3b_word	dmdr_zext_high_low_out;
lc3b_word	dmarmux_out, mem_regfile_in;
lc3b_word	mem_sr2_forwarding_mux_out;
logic		ldi_sti_counter, load_ldi_sti_counter_reg, load_dmem_rdata_reg;

assign dmem_wdata = dmdr_mux_out;

always_comb
begin
	dmem_read = 1'b0;
	dmem_write = 1'b0;
	dmem_byte_enable = 2'b11;
	load_ldi_sti_counter_reg = 1'b0;
	load_dmem_rdata_reg = 1'b0;
	d_cache_stall = 1'b0;
	
	case(mem_cntrl.opcode)
	
		op_ldr:	
		begin
			dmem_read = 1'b1;
			d_cache_stall = ~dmem_resp;
		end

		
		op_str:	
		begin
			dmem_write = 1'b1;
			d_cache_stall = ~dmem_resp;
		end
		
		op_ldb:
		begin
			dmem_read = 1'b1;
			d_cache_stall = ~dmem_resp;
			
			if(mem_alu_out[0] == 1'b0)
				dmem_byte_enable = 2'b01;
			else
				dmem_byte_enable = 2'b10;
		end
		
		op_stb:
		begin
			dmem_write = 1'b1;
			d_cache_stall = ~dmem_resp;
			
			//for STB, mem_address[0] is mem_alu_out[0]
			if(mem_alu_out[0] == 1'b0)
				dmem_byte_enable = 2'b01;
			else
				dmem_byte_enable = 2'b10;
		end
		
		op_trap:
		begin
			dmem_read = 1'b1; //Read trap vector...
			d_cache_stall = ~dmem_resp;
		end
		
		op_ldi:
		begin
			dmem_read = 1'b1;
			case({dmem_resp, ldi_sti_counter})
				2'b00: begin //dmem_resp = 0, ldi_sti_counter = 0
					d_cache_stall = 1'b1;
					load_ldi_sti_counter_reg = 1'b0;
				end
				2'b01: begin //dmem_resp = 0, ldi_sti_counter = 1
					load_ldi_sti_counter_reg = 1'b0;
					d_cache_stall = 1'b1;
					
				end
				2'b10: begin //dmem_resp = 1, ldi_sti_counter = 0
					load_ldi_sti_counter_reg = 1'b1;
					d_cache_stall = 1'b1;
					load_dmem_rdata_reg = 1'b1;
				end
				2'b11: begin //dmem_resp = 1, ldi_sti_counter = 1
					load_ldi_sti_counter_reg = 1'b1;
					d_cache_stall = 1'b0;
				end		
			endcase
			
		end
		
		op_sti:
		begin
			case({dmem_resp, ldi_sti_counter})
				2'b00: begin //dmem_resp = 0, ldi_sti_counter = 0
					dmem_read = 1'b1;
					d_cache_stall = 1'b1;
					load_ldi_sti_counter_reg = 1'b0;
				end
				2'b01: begin //dmem_resp = 0, ldi_sti_counter = 1
						dmem_write = 1'b1;
					load_ldi_sti_counter_reg = 1'b0;
					d_cache_stall = 1'b1;
					
				end
				2'b10: begin //dmem_resp = 1, ldi_sti_counter = 0
					dmem_read = 1'b1;
					load_ldi_sti_counter_reg = 1'b1;
					d_cache_stall = 1'b1;
					load_dmem_rdata_reg = 1'b1;
				end
				2'b11: begin //dmem_resp = 1, ldi_sti_counter = 1
					dmem_write = 1'b1;
					load_ldi_sti_counter_reg = 1'b1;
					d_cache_stall = 1'b0;
				end
			endcase
		end
		
		default: /* Optional */;
	endcase
end

always_comb
begin
	dmem_address = dmarmux_out;
	if(ldi_sti_counter)
		dmem_address = dmem_rdata_reg_out;
end



register #(.width(1)) ldi_sti_counter_reg
(
	.clk,
	.load(load_ldi_sti_counter_reg),
	.in(~ldi_sti_counter),
	.out(ldi_sti_counter)
);

register dmem_rdata_reg
(
	.clk,
	.load(load_dmem_rdata_reg),
	.in(dmem_rdata),
	.out(dmem_rdata_reg_out)
);

mux2 mem_sr2_forwarding_mux
(
	.sel(mem_sr2_forwarding_mux_sel & (wb_cntrl.opcode != op_ldb)),
	.a(mem_sr2),
	.b(wb_regfile_in),
	.f(mem_sr2_forwarding_mux_out)
);

mux4 dmdrmux
(
    .sel(mem_cntrl.dmdrmux_sel),
    .a(mem_alu_out),
    .b(dmem_rdata),
	.c(mem_sr1),
	.d(mem_sr2_forwarding_mux_out), //Added for STR instruction
    .f(dmdr_mux_out)
);
 
zext_high_low_byte 	dmdr_zext_high_low
(
	.sel(dmem_address[0]), //LSB of mem_address we access always!
	.in(dmdr_mux_out),
	.out(dmdr_zext_high_low_out)
);


mux2 dmdr_zhlb_mux
(
	.sel(mem_cntrl.dmdr_zhlb_mux_sel),
	.a(dmdr_mux_out),
	.b(dmdr_zext_high_low_out),
	.f(mem_dmdr_out)
);

mux4 dmarmux
(
    .sel(mem_cntrl.dmarmux_sel),
    .a(mem_alu_out),
    .b(mem_pc),
	.c(dmdr_mux_out),
	.d(mem_zextvect8),
    .f(dmarmux_out)
);

always_comb
begin
	//mem_to_ex_data = mem_alu_out; //Generally, this is true
	case(mem_cntrl.opcode)
		op_lea: begin
			mem_to_ex_sr1_data <= mem_pc_adder_out;
			mem_to_ex_sr2_data <= mem_pc_adder_out;
		end
		op_trap: begin
			mem_to_ex_sr1_data <= mem_pc;
			mem_to_ex_sr2_data <= mem_pc;
		end
		op_jsr: begin
			mem_to_ex_sr1_data <= mem_pc;
			mem_to_ex_sr2_data <= mem_pc;
		end
		op_ldr: begin 
			mem_to_ex_sr1_data <= mem_dmdr_out;
			mem_to_ex_sr2_data <= mem_dmdr_out;
		end
		op_ldb: begin 
			mem_to_ex_sr1_data <= mem_dmdr_out;
			mem_to_ex_sr2_data <= mem_dmdr_out;
		end
		op_ldi: begin
			mem_to_ex_sr1_data <= mem_dmdr_out;
			mem_to_ex_sr2_data <= mem_dmdr_out;
		end
		op_str: begin
			mem_to_ex_sr2_data <= mem_sr2;
			mem_to_ex_sr1_data <= mem_sr1;
		end
		op_stb: begin
			mem_to_ex_sr2_data <= mem_sr2;
			mem_to_ex_sr1_data <= mem_sr1;
		end
		
		default: begin
			mem_to_ex_sr1_data <= mem_alu_out;
			mem_to_ex_sr2_data <= mem_alu_out;
		end
	endcase
end

always_comb
begin
	//take_jump = 1'b0;
	if(mem_cntrl.opcode == op_br & ~mem_is_nop) begin
		check_target = 1'b1;
		if (cc_comp_out)
			take_jump = 1'b1;
		else
			take_jump = 1'b0;
	end
	else if(mem_cntrl.opcode == op_jmp) begin
		take_jump = 1'b1;
		check_target = 1'b1;
	end
	else if(mem_cntrl.opcode == op_jsr) begin
		take_jump = 1'b1;
		check_target = 1'b1;
	end
	else if(mem_cntrl.opcode == op_trap) begin
		take_jump = 1'b1;
		check_target = 1'b1;
	end
	else begin
		take_jump = 1'b0;
		check_target = 1'b0;
	end
end
always_comb
begin
	bad_uncond_jump = 1'b0;
	if(mem_cntrl.opcode == op_jmp && mem_btb_target_pc != pcmux_out)
	begin
		bad_uncond_jump = 1'b1;
	end
	else if(mem_cntrl.opcode == op_jsr && mem_btb_target_pc != pcmux_out)
	begin
		bad_uncond_jump = 1'b1;
	end
	else if(mem_cntrl.opcode == op_trap && mem_btb_target_pc != pcmux_out)
	begin
		bad_uncond_jump = 1'b1;
	end
end
mux4 regfilemux
(
	.sel(mem_cntrl.regfilemux_sel),
	.a(mem_alu_out),
	.b(mem_dmdr_out),
	.c(mem_pc_adder_out),
	.d(mem_pc),
	.f(mem_regfile_in) // writes back to the regfile in ID stage
);

mux4 pcmux
(
    .sel(mem_cntrl.pcmux_sel),
    .a(mem_pc),
    .b(mem_pc_adder_out),
	.c(mem_alu_out),
	.d(mem_dmdr_out),
    .f(pcmux_out)
);

// Condition Code Generation
gencc GENCC
(
	.in(mem_regfile_in),
	.out(gencc_out)
);

cc_register #(.width($bits(lc3b_nzp))) CC
(
	.clk,
	.load(mem_cntrl.load_cc),
	.in(gencc_out),
	.out(cc_out)
);

cc_comp cccomp
(
	.nzp(cc_out),
	.instr_nzp(mem_ir_nzp),
	.branch_enable(cc_comp_out)
);

/*********************************************************************
 STATE REGISTER - MEM -> WB
*********************************************************************/

logic load_mem_wb;
lc3b_word wb_pc_adder_out, wb_dmdr_out, wb_alu_out;


assign load_mem_wb = ~(d_cache_stall) & ~(branch_stall & i_cache_stall);

mem_wb_state_reg mem_wb_state_reg
(
    .clk,
	.flush,
	.load_mem_wb,
	 
    .mem_wb_pc_in(mem_pc),
	.mem_wb_pc_out(wb_pc),
	
	.mem_wb_pc_mux_in(pcmux_out),
	.mem_wb_pc_mux_out(wb_pcmux_out),
	
		.mem_wb_check_target_in(check_target),
	.mem_wb_check_target_out(wb_check_target),
	
	.mem_wb_take_jump_in(take_jump),
	.mem_wb_take_jump_out(wb_take_jump),
	
//	 
//	.mem_wb_pc_adder_in(mem_pc_adder_out),
//	.mem_wb_pc_adder_out(wb_pc_adder_out),
	 
//	.mem_wb_dmdr_in(mem_dmdr_out),
//	.mem_wb_dmdr_out(wb_dmdr_out),
//	 
//	.mem_wb_alu_in(mem_alu_out),
//	.mem_wb_alu_out(wb_alu_out),
	 
//	.mem_wb_ir_nzp_in(mem_ir_nzp),
//	.mem_wb_ir_nzp_out(wb_ir_nzp),
	 
	.mem_wb_cntrl_in(mem_cntrl),
	.mem_wb_cntrl_out(wb_cntrl),
	 
	.mem_wb_dest_in(mem_dest),
	.mem_wb_dest_out(wb_dest),
	
	.mem_wb_is_nop_in(mem_is_nop),
	.mem_wb_is_nop_out(wb_is_nop),
	
	.mem_wb_branch_prediction_in(mem_predict_taken),
	.mem_wb_branch_prediction_out(wb_predict_taken),
	
	.mem_wb_predictor_in(mem_predictor),
	.mem_wb_predictor_out(wb_predictor),
	
	.mem_wb_flush_pc_in(mem_flush_pc),
	.mem_wb_flush_pc_out(wb_flush_pc),
	
	.mem_wb_regfile_in(mem_regfile_in),
	.mem_wb_regfile_out(wb_regfile_in)
);

/*********************************************************************
 STAGE - WB - Write Back
*********************************************************************/

endmodule: cpu_datapath