import lc3b_types::*; /* Import types defined in lc3b_types.sv */

module cpu_control
(
    /* Input and output port declarations */
	 input clk,
	/* Datapath controls */
	input lc3b_opcode opcode,
	output logic load_pc, load_ir, load_regfile, load_mar, load_mdr, load_cc,
	output logic  storemux_sel, destmux_sel, offset6mux_sel, adj_9_11_sel, 
					  sr1_high_low_sel, sr1_out_mux_sel,  mdrmux_sel,mdr_to_regfile_mux_sel, mdr_zext_high_low_sel,
	output logic [1:0] alumux_sel, pcmux_sel, regfilemux_sel, marmux_sel,
	output lc3b_aluop aluop,
	input logic branch_enable,
	input logic imm5_bit,
	input logic imm4_bit,
	input logic instr_bit11,
	/* Memory signals */
	input mem_resp,
	input mem_address_lsb,
	output logic mem_read,
	output logic mem_write,
	output lc3b_mem_wmask mem_byte_enable
);

enum int unsigned {
    /* List of states */
	 fetch1,
	 fetch2,
	 fetch3,
	 decode,
	 s_add,
	 s_and,
	 s_not,
	 calc_addr,
	 calc_byte_addr,
	 calc_addrI_2,
	 calc_addrI_3,
	 ldb1,
	 ldb2,
	 ldr1,
	 ldr2,
	 lea,
	 stb1,
	 stb2,
	 str1,
	 str2,
	 br,
	 br_taken,
	 jmp,
	 jsr,
	 shf,
	 trap1,
	 trap2,
	 trap3
	 
} state, next_state;

always_comb
begin : state_actions
    /* Default output assignments */
    load_pc = 1'b0;
	 load_ir = 1'b0;
	 load_regfile = 1'b0;
	 load_mar = 1'b0;
	 load_mdr = 1'b0;
	 load_cc = 1'b0;
	 pcmux_sel = 2'b00;
	 storemux_sel = 1'b0;
	 destmux_sel = 1'b0;
	 adj_9_11_sel = 1'b0;
	 offset6mux_sel = 1'b0;
	 alumux_sel = 2'b00;
	 regfilemux_sel = 2'b00;
	 sr1_high_low_sel = 1'b0; 
	 sr1_out_mux_sel = 1'b0; 
	 mdr_to_regfile_mux_sel = 0;
	 mdr_zext_high_low_sel = 0;
	 marmux_sel = 2'b00;
	 mdrmux_sel = 1'b0;
	 aluop = alu_add;
	 mem_read = 1'b0;
	 mem_write = 1'b0;
	 mem_byte_enable = 2'b11;
	 
	 /* Actions for each state */
	 case(state)
		fetch1: begin
			/* MAR <= PC */
			marmux_sel = 2'b01;
			load_mar = 1;
			
			/* PC <= PC + 2 */
			pcmux_sel = 0;
			load_pc = 1;
		end
		
		fetch2: begin
			/* Read memory */
			mem_read = 1;
			mdrmux_sel = 1;
			load_mdr = 1;
		end
		
		fetch3: begin
			/* Load IR */
			load_ir = 1;
		end
		
		decode: /* Do nothing */;
		
		s_add: begin
			/* DR <= SRA + SRB */
			if(imm5_bit)
				alumux_sel = 2'b10;
			else
				alumux_sel = 2'b00;
			aluop = alu_add;
			load_regfile = 1;
			regfilemux_sel = 0;
			load_cc = 1;
		end
		s_and: begin
			/* DR <= SRA & SRB */
			if(imm5_bit)
				alumux_sel = 2'b10;
			else
				alumux_sel = 2'b00;
			aluop = alu_and;
			load_regfile = 1;
			regfilemux_sel = 2'b00;
			load_cc = 1;
		end
		s_not: begin
			/* DR <= NOT(SRA)*/
			aluop = alu_not;
			load_regfile = 1;
			regfilemux_sel = 2'b00;
			load_cc = 1;
		end
		calc_addr: begin
			/* MAR <= A + SEXT(IR[5:0] << 1) */
			aluop = alu_add;
			alumux_sel = 2'b01;
			load_mar = 1;
		end
		calc_byte_addr: begin
			/* MAR <= A + SEXT(IR[5:0]) */
			offset6mux_sel = 1;
			aluop = alu_add;
			alumux_sel = 2'b01;
			load_mar = 1;
		end
		calc_addrI_2: begin
			/* MDR <= M[MAR] */
			mdrmux_sel = 1;
			load_mdr = 1;
			mem_read = 1;
		end
		calc_addrI_3: begin
			/* MAR <= MDR */
			marmux_sel = 2'b10;
			load_mar = 1;
		end
		ldb1: begin
			/* MDR <= ZEXT(M[MAR]) depends on address*/
			mdrmux_sel = 1;
			load_mdr = 1;
			mem_read = 1;
		end
		ldb2: begin
			/* DR <= MDR */
			mdr_to_regfile_mux_sel = 1;
			mdr_zext_high_low_sel = mem_address_lsb;
			regfilemux_sel = 2'b01;
			load_regfile = 1;
			load_cc = 1;
		end
		ldr1: begin
			/* MDR <= M[MAR] */
			mdrmux_sel = 1;
			load_mdr = 1;
			mem_read = 1;
		end
		ldr2: begin
			/* DR <= MDR */
			regfilemux_sel = 2'b01;
			load_regfile = 1;
			load_cc = 1;
		end
		lea: begin
			/* DR <= PC + SEXT(IR[8:0] << 1) */
			regfilemux_sel = 2'b10;
			load_regfile = 1;
			load_cc = 1;
		end
		stb1: begin
			/* MDR <= SR(7:0) */
			
			//The high low selector is the mem_address_lsb
			sr1_high_low_sel = mem_address_lsb;
			
			sr1_out_mux_sel = 1;
			
			storemux_sel = 1;
			aluop = alu_pass;
			mdrmux_sel = 0; //Loads MDR with stuff on ALU line passed
			load_mdr = 1;
		end
		stb2: begin
			/* M[MAR] <= MDR */
			
			if(mem_address_lsb == 0)
				mem_byte_enable = 2'b01;
			else
				mem_byte_enable = 2'b10;
			mem_write = 1;
		end
		str1: begin
			/* MDR <= SR */
			storemux_sel = 1;
			aluop = alu_pass;
			load_mdr = 1;
		end
		str2: begin
			/* M[MAR] <= MDR */
			mem_write = 1;
		end
		br: begin
			/* Nothing */
		end
		br_taken: begin
			/* PC <= PC + SEXT(IR[8:0] << 1) */
			pcmux_sel = 2'b01;
			load_pc = 1;
		end
		jmp: begin
			/* PC <= BaseR */
			aluop = alu_pass;
			pcmux_sel = 2'b10;
			load_pc = 1;
		end
		jsr: begin
			/* R7 <= PC; 
				if (bit[11] == 0)
					PC = BaseR;
				else
					PC = PC† + (SEXT(PCoffset11) << 1);
			*/
			destmux_sel = 1;
			adj_9_11_sel = 1'b1;
			regfilemux_sel = 2'b11;
			load_regfile = 1;
			aluop = alu_pass;
			if(instr_bit11 == 0)
				pcmux_sel = 2'b10;
			else
				pcmux_sel = 2'b01;
			load_pc = 1;
				
		end
		shf: begin
			/* if (D == 0)
					DR = SR << imm4;
				else
					if (A == 0)
						DR = SR >> imm4,0;
					else
						DR = SR >> imm4,SR[15];
				setcc();
			*/
			alumux_sel = 2'b11;
			if(imm4_bit == 0) //D
				aluop = alu_sll;
			else
			begin
				if(imm5_bit == 0)
					aluop = alu_srl;
				else
					aluop = alu_sra;
			end
			
			destmux_sel = 0;
			storemux_sel = 0;
			regfilemux_sel = 0;
			load_regfile = 1;
			load_cc = 1;
		end
		trap1: begin
			/* MAR <= ZEXT(trapvect8) << 1; R7 <= PC */
			marmux_sel = 2'b11;
			load_mar = 1;
			
			destmux_sel = 1;
			regfilemux_sel = 2'b11; //pc_out
			load_regfile =  1;
		end
		trap2: begin
			/* MDR <= M[MAR]; */
			mdrmux_sel = 1;
			load_mdr = 1;
			mem_read = 1;
		end
		trap3: begin
			/* PC <= MDR */
			pcmux_sel = 2'b11;
			load_pc = 1;
		end
		default: /* Do nothing */;
	endcase
	 
end

always_comb
begin : next_state_logic
		next_state = state;
    /* Next state information and conditions (if any)
     * for transitioning between states */
	  case(state)
		fetch1: begin
			/* MAR <= PC */
			next_state = fetch2;
		end
		
		fetch2: begin
			/* Read memory */
			if(mem_resp == 0)
				next_state = fetch2;
			else
				next_state = fetch3;
		end
		fetch3: begin
			/* Load IR */
			next_state = decode;
		end
		
		decode: begin
			case(opcode)
				op_add: next_state = s_add;
				op_and: next_state = s_and;
				op_not: next_state = s_not;
				op_ldb: next_state = calc_byte_addr;
				op_ldr: next_state = calc_addr;
				op_ldi: next_state = calc_addr;
				op_lea: next_state = lea;
				op_stb: next_state = calc_byte_addr;
				op_str: next_state = calc_addr;
				op_sti: next_state = calc_addr;
				op_br: next_state = br;
				op_jmp: next_state = jmp;
				op_jsr: next_state = jsr;
				op_shf: next_state = shf;
				op_trap: next_state = trap1;
				default: /*Do nothing*/;
			endcase
		end
		
		s_add: begin
			/* DR <= SRA + SRB */
			next_state = fetch1;
		end
		s_and: begin
			/* DR <= SRA & SRB */
			next_state = fetch1;
		end
		s_not: begin
			/* DR <= NOT(SRA) */
			next_state = fetch1;
		end
		calc_addr: begin
			case(opcode)
				op_ldr: next_state = ldr1;
				op_ldi: next_state = calc_addrI_2;
				op_str: next_state = str1;
				op_sti: next_state = calc_addrI_2;
				default: /*Do nothing*/;
			endcase
		end
		calc_byte_addr: begin
			case(opcode)
				op_ldb: next_state = ldb1;
				op_stb: next_state = stb1;
				default: /*Do nothing*/;
			endcase
		end
		calc_addrI_2: begin
			if(mem_resp == 0)
				next_state = calc_addrI_2;
			else
				next_state = calc_addrI_3;
		end
		calc_addrI_3: begin
			case(opcode)
				op_ldi: next_state = ldr1;
				op_sti: next_state = str1;
				default: /*Do Nothing*/;
			endcase
		end
		ldb1: begin
			if(mem_resp == 0)
				next_state = ldb1;
			else
				next_state = ldb2;
		end
		ldb2: begin
			next_state = fetch1;
		end
		ldr1: begin
			if(mem_resp == 0)
				next_state = ldr1;
			else
				next_state = ldr2;
		end
		ldr2: begin
			next_state = fetch1;
		end
		lea: begin
			next_state = fetch1;
		end
		stb1: begin
			next_state = stb2;
		end
		stb2: begin
			if(mem_resp == 0)
				next_state = stb2;
			else
				next_state = fetch1;
		end
		str1: begin
			next_state = str2;
		end
		str2: begin
			if(mem_resp == 0)
				next_state = str2;
			else
				next_state = fetch1;
		end
		br: begin
			if(branch_enable == 1)
				next_state = br_taken;
			else
				next_state = fetch1;
		end
		br_taken: begin
			next_state = fetch1;
		end
		jmp: begin
			next_state = fetch1;
		end
		jsr:begin
			next_state = fetch1;
		end
		shf:begin
			next_state = fetch1;
		end
		trap1: begin
			next_state = trap2;
		end
		trap2: begin
			if(mem_resp == 0)
				next_state = trap2;
			else
				next_state = trap3;
		end
		trap3: begin
			next_state = fetch1;
		end
		default: /* Do nothing */;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end

endmodule : cpu_control
