
module instr_decode(
	input wire[31:0] instr,
	output wire[6:0] opcode,
	output wire[4:0] rd,
	output wire[4:0] rs1,
	output wire[4:0] rs2,
	output wire[2:0] funct3,
	output wire[6:0] funct7,
	output wire[31:0] imm,
	output wire alu_op, reg_write, mem_read, mem_write, is_branch, is_jump, alu_src, mem_to_reg
);	
	// basic string splitting
	assign opcode = instr[6:0];
	assign rd = instr[11:7];
	assign funct3 = instr[14:12];
	assign rs1 = instr[19:15];
	assign rs2 = instr[20:24];
	assign funct7 = instr[31:25];
	
	
	
	
endmodule