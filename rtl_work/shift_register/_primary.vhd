library verilog;
use verilog.vl_types.all;
entity shift_register is
    generic(
        width           : integer := 16
    );
    port(
        clk             : in     vl_logic;
        load            : in     vl_logic;
        \in\            : in     vl_logic;
        \out\           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end shift_register;
