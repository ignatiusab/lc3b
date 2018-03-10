library verilog;
use verilog.vl_types.all;
entity btb_entry is
    port(
        clk             : in     vl_logic;
        write           : in     vl_logic;
        lookup_pc_in    : in     vl_logic_vector(15 downto 0);
        lookup_pc_out   : out    vl_logic_vector(15 downto 0);
        predicted_pc_in : in     vl_logic_vector(15 downto 0);
        predicted_pc_out: out    vl_logic_vector(15 downto 0)
    );
end btb_entry;
