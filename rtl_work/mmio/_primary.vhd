library verilog;
use verilog.vl_types.all;
entity mmio is
    port(
        dmem_read       : in     vl_logic;
        dmem_write      : in     vl_logic;
        dmem_address    : in     vl_logic_vector(15 downto 0);
        dmem_wdata      : in     vl_logic_vector(15 downto 0);
        dmem_resp       : out    vl_logic;
        dmem_rdata      : out    vl_logic_vector(15 downto 0);
        l1_mem_resp     : in     vl_logic;
        l1_mem_rdata    : in     vl_logic_vector(15 downto 0);
        l1_mem_read     : out    vl_logic;
        l1_mem_write    : out    vl_logic;
        l1_mem_address  : out    vl_logic_vector(15 downto 0);
        l1_mem_wdata    : out    vl_logic_vector(15 downto 0);
        counter_rdata   : in     vl_logic_vector(15 downto 0);
        clear           : out    vl_logic
    );
end mmio;
