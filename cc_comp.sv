import lc3b_types::*;
module cc_comp
(
	input lc3b_nzp nzp, instr_nzp,
	output logic branch_enable
);

always_comb
begin
	if( (nzp[2] && instr_nzp[2]) || (nzp[1] && instr_nzp[1]) || (nzp[0] && instr_nzp[0]))
		branch_enable = 1;
	else
		branch_enable = 0;
end
endmodule : cc_comp