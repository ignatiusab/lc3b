library verilog;
use verilog.vl_types.all;
entity cpu_datapath is
    port(
        clk             : in     vl_logic;
        imem_resp       : in     vl_logic;
        imem_rdata      : in     vl_logic_vector(15 downto 0);
        imem_read       : out    vl_logic;
        imem_write      : out    vl_logic;
        imem_address    : out    vl_logic_vector(15 downto 0);
        imem_byte_enable: out    vl_logic_vector(1 downto 0);
        imem_wdata      : out    vl_logic_vector(15 downto 0);
        dmem_resp       : in     vl_logic;
        dmem_rdata      : in     vl_logic_vector(15 downto 0);
        dmem_read       : out    vl_logic;
        dmem_write      : out    vl_logic;
        dmem_address    : out    vl_logic_vector(15 downto 0);
        dmem_byte_enable: out    vl_logic_vector(1 downto 0);
        dmem_wdata      : out    vl_logic_vector(15 downto 0);
        i_cache_stall   : out    vl_logic;
        d_cache_stall   : out    vl_logic;
        branch_stall    : out    vl_logic;
        flush           : out    vl_logic;
        is_branch       : out    vl_logic;
        is_instruction  : out    vl_logic
    );
end cpu_datapath;
