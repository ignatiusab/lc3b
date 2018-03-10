import lc3b_types::*;

module branch_target_buffer
(
	input clk,
	input lc3b_word lookup_pc,
	input lc3b_word resolved_lookup_pc,
	input lc3b_word resolved_predicted_pc,
	input logic check_target,
	
	output lc3b_word target_pc,
	output logic hit
);

logic [4:0] lru_hit;
logic [3:0] lru_out;
logic write_bte_mux_sel;
logic [3:0] write_bte_demux_sel;
logic [3:0] write_bte_entry;

logic write_bte;
logic write_bte_0;
logic write_bte_1;
logic write_bte_2;
logic write_bte_3;
logic write_bte_4;
logic write_bte_5;
logic write_bte_6;
logic write_bte_7;
logic write_bte_8;
logic write_bte_9;
logic write_bte_10;
logic write_bte_11;
logic write_bte_12;
logic write_bte_13;
logic write_bte_14;
logic write_bte_15;

/************************************
 ************ BTB ENTRIES ***********
 ************************************/
 
 lc3b_word entry0_lookup_pc_out;
 lc3b_word entry1_lookup_pc_out;
 lc3b_word entry2_lookup_pc_out;
 lc3b_word entry3_lookup_pc_out;
 lc3b_word entry4_lookup_pc_out;
 lc3b_word entry5_lookup_pc_out;
 lc3b_word entry6_lookup_pc_out;
 lc3b_word entry7_lookup_pc_out;
 lc3b_word entry8_lookup_pc_out;
 lc3b_word entry9_lookup_pc_out;
 lc3b_word entry10_lookup_pc_out;
 lc3b_word entry11_lookup_pc_out;
 lc3b_word entry12_lookup_pc_out;
 lc3b_word entry13_lookup_pc_out;
 lc3b_word entry14_lookup_pc_out;
 lc3b_word entry15_lookup_pc_out;
 
 lc3b_word entry0_predicted_pc_out;
 lc3b_word entry1_predicted_pc_out;
 lc3b_word entry2_predicted_pc_out;
 lc3b_word entry3_predicted_pc_out;
 lc3b_word entry4_predicted_pc_out;
 lc3b_word entry5_predicted_pc_out;
 lc3b_word entry6_predicted_pc_out;
 lc3b_word entry7_predicted_pc_out;
 lc3b_word entry8_predicted_pc_out;
 lc3b_word entry9_predicted_pc_out;
 lc3b_word entry10_predicted_pc_out;
 lc3b_word entry11_predicted_pc_out;
 lc3b_word entry12_predicted_pc_out;
 lc3b_word entry13_predicted_pc_out;
 lc3b_word entry14_predicted_pc_out;
 lc3b_word entry15_predicted_pc_out;
  
btb_entry	entry0
(
	.clk,
	.write(write_bte_0),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry0_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry0_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
);

btb_entry	entry1
(
	.clk,
	.write(write_bte_1),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry1_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry1_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
);
btb_entry	entry2
(
	.clk,
	.write(write_bte_2),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry2_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry2_predicted_pc_out)

	//.taken_in,
	//.taken_out
);

btb_entry	entry3
(
	.clk,
	.write(write_bte_3),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry3_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry3_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
);

btb_entry	entry4
(
	.clk,
	.write(write_bte_4),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry4_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry4_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
); 
btb_entry	entry5
(
	.clk,
	.write(write_bte_5),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry5_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry5_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
);

btb_entry	entry6
(
	.clk,
	.write(write_bte_6),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry6_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry6_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
);
btb_entry	entry7
(
	.clk,
	.write(write_bte_7),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry7_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry7_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
);

btb_entry	entry8
(
	.clk,
	.write(write_bte_8),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry8_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry8_predicted_pc_out)

	//.taken_in,
	//.taken_out
);

btb_entry	entry9
(
	.clk,
	.write(write_bte_9),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry9_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry9_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
); 
btb_entry	entry10
(
	.clk,
	.write(write_bte_10),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry10_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry10_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
);

btb_entry	entry11
(
	.clk,
	.write(write_bte_11),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry11_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry11_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
);
btb_entry	entry12
(
	.clk,
	.write(write_bte_12),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry12_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry12_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
);

btb_entry	entry13
(
	.clk,
	.write(write_bte_13),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry13_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry13_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
);

btb_entry	entry14
(
	.clk,
	.write(write_bte_14),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry14_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry14_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
);
btb_entry	entry15
(
	.clk,
	.write(write_bte_15),
	.lookup_pc_in(resolved_lookup_pc),
	.lookup_pc_out(entry15_lookup_pc_out),
	
	.predicted_pc_in(resolved_predicted_pc),
	.predicted_pc_out(entry15_predicted_pc_out)
	
	//.taken_in,
	//.taken_out
); 



//Compare the lookup_pc with entry lookup pc's
always_comb
begin	

	lru_hit = 5'b10000;
	//Writing into the BTEs
	write_bte = 1'b0;
	write_bte_entry = 4'b0000;
	write_bte_mux_sel = 1'b0;

	if(check_target)
	begin
	write_bte = 1;
	case(resolved_lookup_pc)
		entry0_lookup_pc_out: begin
			write_bte_entry = 4'b0000;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b00000;
		end
		entry1_lookup_pc_out:  begin
			write_bte_entry = 4'b0001;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b00001;
		end
		entry2_lookup_pc_out:  begin
			write_bte_entry = 4'b0010;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b00010;
		end
		entry3_lookup_pc_out:  begin
			write_bte_entry = 4'b0011;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b00011;
		end
		entry4_lookup_pc_out: begin
			write_bte_entry = 4'b0100;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b00100;
		end
		entry5_lookup_pc_out:  begin
			write_bte_entry = 4'b0101;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b00101;
		end
		entry6_lookup_pc_out:  begin
			write_bte_entry = 4'b0110;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b00110;
		end
		entry7_lookup_pc_out:  begin
			write_bte_entry = 4'b0111;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b00111;
		end
		entry8_lookup_pc_out: begin
			write_bte_entry = 4'b1000;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b01000;
		end
		entry9_lookup_pc_out:  begin
			write_bte_entry = 4'b1001;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b01001;
		end
		entry10_lookup_pc_out:  begin
			write_bte_entry = 4'b1010;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b01010;
		end
		entry11_lookup_pc_out:  begin
			write_bte_entry = 4'b1011;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b01011;
		end
		entry12_lookup_pc_out: begin
			write_bte_entry = 4'b1100;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b01100;
		end
		entry13_lookup_pc_out:  begin
			write_bte_entry = 4'b1101;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b01101;
		end
		entry14_lookup_pc_out:  begin
			write_bte_entry = 4'b1110;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b01110;
		end
		entry15_lookup_pc_out:  begin
			write_bte_entry = 4'b1111;
			write_bte_mux_sel = 1'b1;
			lru_hit = 5'b01111;
		end
		
		default: begin
			write_bte_entry = 4'b0000;
			write_bte_mux_sel = 1'b0;
			lru_hit = {1'b0, lru_out[3:0]};
		end
	endcase
	end

	case(lookup_pc)
		entry0_lookup_pc_out: begin
			target_pc = entry0_predicted_pc_out;
			lru_hit = 5'b00000;
			hit = 1'b1;
		end
		entry1_lookup_pc_out:  begin
			target_pc = entry1_predicted_pc_out;
			lru_hit = 5'b00001;
			hit = 1'b1;
		end
		entry2_lookup_pc_out:  begin
			target_pc = entry2_predicted_pc_out;
			lru_hit = 5'b00010;
			hit = 1'b1;
		end
		entry3_lookup_pc_out:  begin
			target_pc = entry3_predicted_pc_out;
			lru_hit = 5'b00011;
			hit = 1'b1;
		end
		entry4_lookup_pc_out: begin
			target_pc = entry4_predicted_pc_out;
			lru_hit = 5'b00100;
			hit = 1'b1;
		end
		entry5_lookup_pc_out:  begin
			target_pc = entry5_predicted_pc_out;
			lru_hit = 5'b00101;
			hit = 1'b1;
		end
		entry6_lookup_pc_out:  begin
			target_pc = entry6_predicted_pc_out;
			lru_hit = 5'b00110;
			hit = 1'b1;
		end
		entry7_lookup_pc_out:  begin
			target_pc = entry7_predicted_pc_out;
			lru_hit = 5'b00111;
			hit = 1'b1;
		end
		entry8_lookup_pc_out: begin
			target_pc = entry8_predicted_pc_out;
			lru_hit = 5'b01000;
			hit = 1'b1;
		end
		entry9_lookup_pc_out:  begin
			target_pc = entry9_predicted_pc_out;
			lru_hit = 5'b01001;
			hit = 1'b1;
		end
		entry10_lookup_pc_out:  begin
			target_pc = entry10_predicted_pc_out;
			lru_hit = 5'b01010;
			hit = 1'b1;
		end
		entry11_lookup_pc_out:  begin
			target_pc = entry11_predicted_pc_out;
			lru_hit = 5'b01011;
			hit = 1'b1;
		end
		entry12_lookup_pc_out: begin
			target_pc = entry12_predicted_pc_out;
			lru_hit = 5'b01100;
			hit = 1'b1;
		end
		entry13_lookup_pc_out:  begin
			target_pc = entry13_predicted_pc_out;
			lru_hit = 5'b01101;
			hit = 1'b1;
		end
		entry14_lookup_pc_out:  begin
			target_pc = entry14_predicted_pc_out;
			lru_hit = 5'b01110;
			hit = 1'b1;
		end
		entry15_lookup_pc_out:  begin
			target_pc = entry15_predicted_pc_out;
			lru_hit = 5'b01111;
			hit = 1'b1;
		end
		
		default : begin
			target_pc = 16'd0;
			hit = 1'b0;
		end
	endcase
	
	
end



mux2 #(.width(4))write_bte_mux
(
	.sel(write_bte_mux_sel),
	.a(lru_out),
	.b(write_bte_entry),
	.f(write_bte_demux_sel)
);

demux16 #(.width(1)) write_bte_demux
(
	.sel(write_bte_demux_sel),
	.in(write_bte),
	.a(write_bte_0),
	.b(write_bte_1),
	.c(write_bte_2),
	.d(write_bte_3),
	.e(write_bte_4),
	.f(write_bte_5),
	.g(write_bte_6),
	.h(write_bte_7),
	.i(write_bte_8),
	.j(write_bte_9),
	.k(write_bte_10),
	.l(write_bte_11),
	.m(write_bte_12),
	.n(write_bte_13),
	.o(write_bte_14),
	.p(write_bte_15)
);

logic [14:0] lru_in, lru_array_out;

register #(.width(15)) btb_lru_array
(
	.clk(clk),
	.load(hit | check_target),
	.in(lru_in),
	.out(lru_array_out)
);

always_comb
begin
lru_in = lru_array_out;
case (lru_hit)
	
	5'd0 : 	begin
	
		lru_in[14] = 1'b1;
		lru_in[13] = 1'b1;
		lru_in[11] = 1'b1;
		lru_in[7] = 1'b1;
	end

	5'd1 : 	begin
		lru_in[14] = 1'b1;
		lru_in[13] = 1'b1;
		lru_in[11] = 1'b1;
		lru_in[7] = 1'b0;
	end
			
	5'd2 : 	begin
		lru_in[14] = 1'b1;
		lru_in[13] = 1'b1;
		lru_in[11] = 1'b0;
		lru_in[6] = 1'b1;
	end
			
	5'd3 : 	begin
		lru_in[14] = 1'b1;
		lru_in[13] = 1'b1;
		lru_in[11] = 1'b0;
		lru_in[6] = 1'b0;
	end
	5'd4 : 	begin
		lru_in[14] = 1'b1;
		lru_in[13] = 1'b0;
		lru_in[10] = 1'b1;
		lru_in[5] = 1'b1;
	end
			
	5'd5 : 	begin
		lru_in[14] = 1'b1;
		lru_in[13] = 1'b0;
		lru_in[10] = 1'b1;
		lru_in[5] = 1'b0;
	end
	5'd6 : 	begin
		lru_in[14] = 1'b1;
		lru_in[13] = 1'b0;
		lru_in[10] = 1'b0;
		lru_in[4] = 1'b1;
	end
			
	5'd7 : 	begin
		lru_in[14] = 1'b1;
		lru_in[13] = 1'b0;
		lru_in[10] = 1'b0;
		lru_in[4] = 1'b0;
	end
	
	5'd8 : 	begin
	
		lru_in[14] = 1'b0;
		lru_in[12] = 1'b1;
		lru_in[9] = 1'b1;
		lru_in[3] = 1'b1;
	end

	5'd9 : 	begin
		lru_in[14] = 1'b0;
		lru_in[12] = 1'b1;
		lru_in[9] = 1'b1;
		lru_in[3] = 1'b0;
	end
			
	5'd10 : 	begin
		lru_in[14] = 1'b0;
		lru_in[12] = 1'b1;
		lru_in[9] = 1'b0;
		lru_in[2] = 1'b1;
	end
			
	5'd11 : 	begin
		lru_in[14] = 1'b0;
		lru_in[12] = 1'b1;
		lru_in[9] = 1'b0;
		lru_in[2] = 1'b0;
	end
	5'd12 : 	begin
		lru_in[14] = 1'b0;
		lru_in[12] = 1'b0;
		lru_in[8] = 1'b1;
		lru_in[1] = 1'b1;
	end
			
	5'd13 : 	begin
		lru_in[14] = 1'b0;
		lru_in[12] = 1'b0;
		lru_in[8] = 1'b1;
		lru_in[1] = 1'b0;
	end
	5'd14 : 	begin
		lru_in[14] = 1'b0;
		lru_in[12] = 1'b0;
		lru_in[8] = 1'b0;
		lru_in[0] = 1'b1;
	end
			
	5'd15 : 	begin
		lru_in[14] = 1'b0;
		lru_in[12] = 1'b0;
		lru_in[8] = 1'b0;
		lru_in[0] = 1'b0;
	end
	
	default : lru_in = lru_array_out;
	
endcase
end

always_comb
begin
	casez (lru_array_out)

		15'b00?0???0??????? : 	begin
						lru_out = 4'b0000;
		end
		
		15'b00?0???1??????? : 	begin
						lru_out = 4'b0001;
		end
		15'b00?1????0?????? : 	begin
						lru_out = 4'b0010;
		end
		15'b00?1????1?????? : 	begin
						lru_out = 4'b0011;
		end
		15'b01??0????0????? : 	begin
						lru_out = 4'b0100;
		end
		15'b01??0????1????? : 	begin
						lru_out = 4'b0101;
		end
		15'b01??1?????0???? : 	begin
						lru_out = 4'b0110;
		end
		15'b01??1?????1???? : 	begin
						lru_out = 4'b0111;
		end
		15'b1?0??0?????0??? : 	begin
						lru_out = 4'b1000;
		end
		15'b1?0??0?????1??? : 	begin
						lru_out = 4'b1001;
		end
		15'b1?0??1??????0?? : 	begin
						lru_out = 4'b1010;
		end
		15'b1?0??1??????1?? :	begin
						lru_out = 4'b1011;
		end
		15'b1?1???0??????0? : 	begin
						lru_out = 4'b1100;
		end
		15'b1?1???0??????1? : 	begin
						lru_out = 4'b1101;
		end
		15'b1?1???1???????0 : 	begin
						lru_out = 4'b1110;
		end
		15'b1?1???1???????1 :	begin
						lru_out = 4'b1111;
		end
		default : lru_out = 4'b0000;
		
	endcase
end
endmodule : branch_target_buffer