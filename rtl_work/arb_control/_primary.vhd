library verilog;
use verilog.vl_types.all;
entity arb_control is
    port(
        clk             : in     vl_logic;
        imem_read       : in     vl_logic;
        dmem_read       : in     vl_logic;
        imem_write      : in     vl_logic;
        dmem_write      : in     vl_logic;
        L2_mem_resp     : in     vl_logic;
        arb_mem_address_mux_sel: out    vl_logic;
        arb_mem_read_mux_sel: out    vl_logic;
        arb_mem_write_mux_sel: out    vl_logic;
        arb_mem_wdata_mux_sel: out    vl_logic;
        arb_mem_rdata_mux_sel: out    vl_logic;
        arb_mem_resp_mux_sel: out    vl_logic;
        L2_mem_read_write_mux_sel: out    vl_logic;
        load_L2_mem_reg : out    vl_logic
    );
end arb_control;
