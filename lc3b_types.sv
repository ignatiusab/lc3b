package lc3b_types;

// general types
typedef logic [15:0]	lc3b_word;
typedef logic [7:0]		lc3b_byte;

// datapath types
typedef logic [10:0]	lc3b_offset11;
typedef logic [8:0]		lc3b_offset9;
typedef logic [7:0]		lc3b_trapvect8;
typedef logic [5:0]		lc3b_offset6;
typedef logic [4:0]		lc3b_imm5;
typedef logic [3:0]		lc3b_imm4;
typedef logic [2:0]		lc3b_reg;
typedef logic [2:0]		lc3b_nzp;
typedef logic [1:0]		lc3b_mem_wmask;

// cache types
typedef logic [15:0]	lc3b_c_addr;
typedef logic [127:0]	lc3b_c_line;
typedef logic [7:0]		lc3b_c_tag;
typedef logic [3:0]		lc3b_c_index;
typedef logic [2:0]		lc3b_c_offset;

// l2 cache types
typedef logic [15:0]	lc3b_c2_addr;
typedef logic [255:0]	lc3b_c2_line;
typedef logic [4:0]		lc3b_c2_tag;
typedef logic [5:0]		lc3b_c2_index;
typedef logic 			lc3b_c2_offset;

// opcode definitions
typedef enum bit [3:0] {
    op_add  = 4'b0001,
    op_and  = 4'b0101,
    op_br   = 4'b0000,
    op_jmp  = 4'b1100,   /* also RET */
    op_jsr  = 4'b0100,   /* also JSRR */
    op_ldb  = 4'b0010,
    op_ldi  = 4'b1010,
    op_ldr  = 4'b0110,
    op_lea  = 4'b1110,
    op_not  = 4'b1001,
    op_rti  = 4'b1000,		/* not used */
    op_shf  = 4'b1101,
    op_stb  = 4'b0011,
    op_sti  = 4'b1011,
    op_str  = 4'b0111,
    op_trap = 4'b1111
} lc3b_opcode;

// ALU operations definitions
typedef enum bit [3:0] {
    alu_add,
    alu_and,
    alu_not,
    alu_pass,
    alu_sll,
    alu_srl,
    alu_sra
} lc3b_aluop;

// control types
typedef struct packed {
	lc3b_opcode opcode;
	lc3b_aluop aluop;
	logic load_cc;
	logic load_regfile;
	logic storemux_sel;
	logic destmux_sel;
	logic offset6mux_sel;
	logic adj_9_11_sel;
	logic sr2_out_mux_sel;
	logic sr2mux_sel;
	logic [1:0] dmdrmux_sel;
	logic dmdr_zhlb_mux_sel;
	logic [1:0] alumux_sel;
	logic [1:0] pcmux_sel;
	logic [1:0] regfilemux_sel;
	logic [1:0] dmarmux_sel;
	logic is_uncond_control;
} lc3b_control_word;

endpackage : lc3b_types