library verilog;
use verilog.vl_types.all;
entity demux16 is
    generic(
        width           : integer := 16
    );
    port(
        sel             : in     vl_logic_vector(3 downto 0);
        a               : out    vl_logic_vector;
        b               : out    vl_logic_vector;
        c               : out    vl_logic_vector;
        d               : out    vl_logic_vector;
        e               : out    vl_logic_vector;
        f               : out    vl_logic_vector;
        g               : out    vl_logic_vector;
        h               : out    vl_logic_vector;
        i               : out    vl_logic_vector;
        j               : out    vl_logic_vector;
        k               : out    vl_logic_vector;
        l               : out    vl_logic_vector;
        m               : out    vl_logic_vector;
        n               : out    vl_logic_vector;
        o               : out    vl_logic_vector;
        p               : out    vl_logic_vector;
        \in\            : in     vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end demux16;
