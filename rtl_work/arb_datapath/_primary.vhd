library verilog;
use verilog.vl_types.all;
entity arb_datapath is
    port(
        clk             : in     vl_logic;
        imem_address    : in     vl_logic_vector(15 downto 0);
        dmem_address    : in     vl_logic_vector(15 downto 0);
        imem_read       : in     vl_logic;
        dmem_read       : in     vl_logic;
        imem_write      : in     vl_logic;
        dmem_write      : in     vl_logic;
        imem_wdata      : in     vl_logic_vector(127 downto 0);
        dmem_wdata      : in     vl_logic_vector(127 downto 0);
        L2_mem_resp     : in     vl_logic;
        L2_mem_rdata    : in     vl_logic_vector(127 downto 0);
        arb_mem_address_mux_sel: in     vl_logic;
        arb_mem_read_mux_sel: in     vl_logic;
        arb_mem_write_mux_sel: in     vl_logic;
        arb_mem_wdata_mux_sel: in     vl_logic;
        arb_mem_rdata_mux_sel: in     vl_logic;
        arb_mem_resp_mux_sel: in     vl_logic;
        load_L2_mem_reg : in     vl_logic;
        L2_mem_read_write_mux_sel: in     vl_logic;
        imem_rdata      : out    vl_logic_vector(127 downto 0);
        dmem_rdata      : out    vl_logic_vector(127 downto 0);
        imem_resp       : out    vl_logic;
        dmem_resp       : out    vl_logic;
        L2_mem_address  : out    vl_logic_vector(15 downto 0);
        L2_mem_read     : out    vl_logic;
        L2_mem_write    : out    vl_logic;
        L2_mem_wdata    : out    vl_logic_vector(127 downto 0)
    );
end arb_datapath;
