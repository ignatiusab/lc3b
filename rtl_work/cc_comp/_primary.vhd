library verilog;
use verilog.vl_types.all;
entity cc_comp is
    port(
        nzp             : in     vl_logic_vector(2 downto 0);
        instr_nzp       : in     vl_logic_vector(2 downto 0);
        branch_enable   : out    vl_logic
    );
end cc_comp;
