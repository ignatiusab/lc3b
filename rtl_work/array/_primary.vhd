library verilog;
use verilog.vl_types.all;
entity \array\ is
    generic(
        width           : integer := 128;
        sets            : integer := 8;
        index_length    : integer := 4
    );
    port(
        clk             : in     vl_logic;
        write           : in     vl_logic;
        index           : in     vl_logic_vector;
        datain          : in     vl_logic_vector;
        dataout         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
    attribute mti_svvh_generic_type of sets : constant is 1;
    attribute mti_svvh_generic_type of index_length : constant is 1;
end \array\;
