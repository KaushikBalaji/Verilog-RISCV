// id_stage_top.v
`timescale 1ns/1ps

module ID_top(
	input wire clk,
    	input wire reset,
    	input wire pc_write,
    	input wire [31:0] next_pc,
    	output wire [31:0] pc_out,
    	output wire [31:0] instr,
    	
	// expose some decode outputs for checking
	output wire [6:0]  opcode,
	output wire [4:0]  rd,
	output wire [4:0]  rs1,
	output wire [4:0]  rs2,
	output wire [2:0]  funct3,
	output wire [6:0]  funct7,
	output wire [31:0] imm,
	output wire [4:0]  alu_op,
	output wire alu_src,
	output wire reg_write,
	output wire mem_read,
	output wire mem_write,
	output wire is_branch,
	output wire is_jump,
	output wire [1:0]  wb_sel,
	output wire[31:0] rs1_data,
	output wire[31:0] rs2_data
);

    // instantiate PC (uses your pc module)
	pc u_pc (
		.clk(clk),
		.reset(reset),
		.next_pc(next_pc),
		.pc_write(pc_write),
		.pc_out(pc_out)
	);

    // instruction memory (your module)
	instr_mem u_imem (
		.addr(pc_out),
		.instr(instr)
	);

    // instruction decoder (your module)
	instr_decode u_decode (
		.instr(instr),
		.opcode(opcode),
		.rd(rd),
		.rs1(rs1),
		.rs2(rs2),
		.funct3(funct3),
		.funct7(funct7),
		.imm(imm),
		.alu_op(alu_op),
		.alu_src(alu_src),
		.reg_write(reg_write),
		.mem_read(mem_read),
		.mem_write(mem_write),
		.is_branch(is_branch),
		.is_jump(is_jump),
		.wb_sel(wb_sel),
		.mem_size(),      // leave optional connections unconnected
		.mem_signed(),
		.illegal()
	);
    
	regfile u_regfile(
		.clk(clk),
		.reset(reset),
		.reg_write(reg_write),
		.rd(rd),
		.rs1(rs1),
		.rs2(rs2),
		.write_data(32'b0),
		.rs1_data(rs1_data),	
		.rs2_data(rs2_data)		// final outputs from regfile is the data in the register
	);
	
	

endmodule
