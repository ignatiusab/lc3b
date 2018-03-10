library verilog;
use verilog.vl_types.all;
entity demux2 is
    generic(
        width           : integer := 16
    );
    port(
        sel             : in     vl_logic;
        \in\            : in     vl_logic_vector;
        out_a           : out    vl_logic_vector;
        out_b           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end demux2;
