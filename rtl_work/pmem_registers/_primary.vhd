library verilog;
use verilog.vl_types.all;
entity pmem_registers is
    port(
        clk             : in     vl_logic;
        pmem_read_in    : in     vl_logic;
        pmem_read_out   : out    vl_logic;
        pmem_write_in   : in     vl_logic;
        pmem_write_out  : out    vl_logic;
        pmem_resp_in    : in     vl_logic;
        pmem_resp_out   : out    vl_logic;
        pmem_rdata_in   : in     vl_logic_vector(255 downto 0);
        pmem_rdata_out  : out    vl_logic_vector(255 downto 0);
        pmem_wdata_in   : in     vl_logic_vector(255 downto 0);
        pmem_wdata_out  : out    vl_logic_vector(255 downto 0);
        pmem_address_in : in     vl_logic_vector(15 downto 0);
        pmem_address_out: out    vl_logic_vector(15 downto 0)
    );
end pmem_registers;
