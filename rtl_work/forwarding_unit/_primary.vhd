library verilog;
use verilog.vl_types.all;
entity forwarding_unit is
    port(
        id_sr1_id       : in     vl_logic_vector(2 downto 0);
        id_sr2_id       : in     vl_logic_vector(2 downto 0);
        ex_sr1_id       : in     vl_logic_vector(2 downto 0);
        ex_sr2_id       : in     vl_logic_vector(2 downto 0);
        mem_dest        : in     vl_logic_vector(2 downto 0);
        wb_dest         : in     vl_logic_vector(2 downto 0);
        mem_load_regfile: in     vl_logic;
        wb_load_regfile : in     vl_logic;
        id_sr1_forwarding_mux_sel: out    vl_logic;
        id_sr2_forwarding_mux_sel: out    vl_logic;
        ex_sr1_forwarding_mux_sel: out    vl_logic_vector(1 downto 0);
        ex_sr2_forwarding_mux_sel: out    vl_logic_vector(1 downto 0);
        mem_sr2_id      : in     vl_logic_vector(2 downto 0);
        mem_sr2_forwarding_mux_sel: out    vl_logic
    );
end forwarding_unit;
