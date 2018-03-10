import lc3b_types::*;

module control_rom
(
	input lc3b_opcode opcode,
	input logic bit4, bit5, bit11,
	output lc3b_control_word cntrl
);

always_comb
begin
	cntrl.opcode = opcode;
	cntrl.aluop = alu_add;
	cntrl.load_cc = 1'b0;
	cntrl.load_regfile = 1'b0;
	cntrl.storemux_sel = 1'b0;
	cntrl.destmux_sel = 1'b0;
	cntrl.offset6mux_sel = 1'b0;
	cntrl.adj_9_11_sel = 1'b0;
	cntrl.sr2_out_mux_sel = 1'b0;
	cntrl.sr2mux_sel = 1'b0;
	cntrl.dmdrmux_sel = 2'b00;
	cntrl.dmdr_zhlb_mux_sel = 1'b0;
	cntrl.alumux_sel = 2'b00;
	cntrl.pcmux_sel = 2'b00;
	cntrl.regfilemux_sel = 2'b00;
	cntrl.dmarmux_sel = 2'b00;
	cntrl.is_uncond_control = 0;
	
	/* Assign control signals */
	case (opcode)
	
	op_add: begin
		cntrl.aluop = alu_add;
		cntrl.load_regfile = 1'b1;
		cntrl.load_cc = 1'b1;
		cntrl.regfilemux_sel = 2'b00; //ALU result
		if (bit5)		// bit 5 is used to determine ADD or ADDi
			cntrl.alumux_sel = 2'b10;
		else
			cntrl.alumux_sel = 2'b00;
	end
	
	op_and: begin
		cntrl.aluop = alu_and;
		cntrl.load_regfile = 1'b1;
		cntrl.load_cc = 1'b1;
		cntrl.regfilemux_sel = 2'b00; //ALU result
		if (bit5)		// bit 5 is used to determine AND or ANDi
			cntrl.alumux_sel = 2'b10;
		else
			cntrl.alumux_sel = 2'b00;
	end
	
	op_br: begin
		cntrl.pcmux_sel = 2'b01;
		//cntrl.is_uncond_control = 1;
	end
	
	op_jmp: begin
		/* PC <= BaseR */
		cntrl.aluop = alu_pass;
		cntrl.pcmux_sel = 2'b10;
		cntrl.is_uncond_control = 1;
	end
	
	op_jsr: begin
			/* R7 <= PC; 
				if (bit[11] == 0)
					PC = BaseR;
				else
					PC = PC† + (SEXT(PCoffset11) << 1);
			*/
			cntrl.is_uncond_control = 1;
			cntrl.destmux_sel = 1; //Sets the dest 
			cntrl.adj_9_11_sel = 1'b1; //let SEXT(PCoffset11) << 1 through
			cntrl.regfilemux_sel = 2'b11;
			cntrl.load_regfile = 1'b1;
			cntrl.aluop = alu_pass;
			if(bit11 == 0)
				cntrl.pcmux_sel = 2'b10; //ALU_out = BaseR
			else
				cntrl.pcmux_sel = 2'b01; ///PC_adder_out
	end
	
	op_ldb: begin
			/* MAR <= A + SEXT(IR[5:0]) */
			cntrl.offset6mux_sel = 1;
			cntrl.aluop = alu_add;
			cntrl.alumux_sel = 2'b01;
			/* MDR <= ZEXT(M[MAR]) depends on address*/
			cntrl.dmdrmux_sel = 2'b01;
			/* DR <= MDR */
			cntrl.dmdr_zhlb_mux_sel = 1'b1;
			cntrl.regfilemux_sel = 2'b01;
			cntrl.load_regfile = 1;
			cntrl.load_cc = 1;
	end
	
	op_ldi: begin					
		cntrl.aluop = alu_add;
		cntrl.alumux_sel = 2'b01;
		cntrl.dmdrmux_sel = 2'b01;
		cntrl.dmarmux_sel = 2'b00;
		cntrl.regfilemux_sel = 2'b01;
		cntrl.load_regfile = 1;
		cntrl.load_cc = 1;
	end
	
	op_ldr: begin
		cntrl.aluop = alu_add;
		cntrl.alumux_sel = 2'b01;
		cntrl.dmdrmux_sel = 2'b01;
		cntrl.regfilemux_sel = 2'b01;
		cntrl.load_regfile = 1;
		cntrl.load_cc = 1;
	end
	
	op_lea: begin
		/* DR <= PC + SEXT(IR[8:0] << 1) */
		cntrl.aluop = alu_add;
		cntrl.regfilemux_sel = 2'b10;
		cntrl.load_regfile = 1;
		cntrl.load_cc = 1;
	end
	
	op_not: begin
		cntrl.aluop = alu_not;
		cntrl.load_regfile = 1'b1;
		cntrl.load_cc = 1'b1;
		cntrl.regfilemux_sel = 2'b00;
	end
		
	op_shf: begin
		/* if (D == 0)
				DR = SR << imm4;
			else
				if (A == 0)
					DR = SR >> imm4,0;
				else
					DR = SR >> imm4,SR[15];
			setcc();
		*/
		cntrl.alumux_sel = 2'b11;
		if(bit4 == 0) //D
			cntrl.aluop = alu_sll;
		else
		begin
			if(bit5 == 0)
				cntrl.aluop = alu_srl;
			else
				cntrl.aluop = alu_sra;
		end
		
		cntrl.destmux_sel = 0;
		cntrl.storemux_sel = 0;
		cntrl.regfilemux_sel = 0;
		cntrl.load_regfile = 1;
		cntrl.load_cc = 1;
	end
	
	op_stb: begin
			/* MAR <= A + SEXT(IR[5:0]) */
			cntrl.offset6mux_sel = 1;
			cntrl.aluop = alu_add;
			cntrl.alumux_sel = 2'b01;
			
			/* MDR <= SR(7:0) */
			cntrl.sr2_out_mux_sel = 1'b1; //Set SR2_out to SR2[7:0]
			cntrl.storemux_sel = 1'b0; //Set SR1 = BaseR
			cntrl.sr2mux_sel = 1'b1; //Set SR => SR2
			
			cntrl.dmdrmux_sel = 2'b11; //Loads MDR with SwidthR2[7:0]
			
			/* M[MAR] <= MDR */
	end
	
	op_sti: begin
		cntrl.aluop = alu_add;
		cntrl.alumux_sel = 2'b01;
		cntrl.dmdrmux_sel = 2'b11; //chooses SR2 value
		cntrl.dmarmux_sel = 2'b00; //ALU line
		cntrl.storemux_sel = 1'b0;
		cntrl.sr2mux_sel = 1'b1; //Chose SR => sr2
		
		
		
	end
	
	op_str: begin
		cntrl.aluop = alu_add;
		cntrl.alumux_sel = 2'b01;
		cntrl.storemux_sel = 1'b0; //Set SR1 = BaseR
		cntrl.sr2mux_sel = 1'b1; //Choose SR => sr2
		cntrl.dmdrmux_sel = 2'b11; //This chooses SR2 value which was IR[11:9] register
		cntrl.dmarmux_sel = 2'b00; //Chooses alu_out which is good
	end
	
	op_trap: begin
			cntrl.is_uncond_control = 1;
			/* MAR <= ZEXT(trapvect8) << 1; R7 <= PC */
			cntrl.dmarmux_sel = 2'b11;
			
			cntrl.destmux_sel = 1'b1; //Set dest to R7
			cntrl.regfilemux_sel = 2'b11; //pc_out into R7
			cntrl.load_regfile =  1'b1;
			/* MDR <= M[MAR]; */
			cntrl.dmdrmux_sel = 2'b01; //Set the output of dmdrmux to the data from memory (dmem_rdata)
			/* PC <= MDR */
			cntrl.pcmux_sel = 2'b11; //set PCmux output to dmdrmux output
	end
	
	default: cntrl = 0;		// unknown opcode, stop everything
	
	endcase
end

endmodule : control_rom