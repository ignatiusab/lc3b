library verilog;
use verilog.vl_types.all;
entity waymux4 is
    generic(
        width           : integer := 16
    );
    port(
        hit0            : in     vl_logic;
        hit1            : in     vl_logic;
        hit2            : in     vl_logic;
        hit3            : in     vl_logic;
        a               : in     vl_logic_vector;
        b               : in     vl_logic_vector;
        c               : in     vl_logic_vector;
        d               : in     vl_logic_vector;
        f               : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end waymux4;
