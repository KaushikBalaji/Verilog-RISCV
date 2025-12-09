`timescale 1ns/1ps

module test_EX;

	reg clk;
	reg reset;
	reg pc_write;
	reg [31:0] next_pc;

	wire [31:0] pc_out;
	wire [31:0] instr;
	wire [6:0]  opcode;
	wire [4:0]  rd;
	wire [4:0]  rs1;
	wire [4:0]  rs2;
	wire [2:0]  funct3;
	wire [6:0]  funct7;
	wire [31:0] imm;
	wire [4:0]  alu_op;
	wire alu_src;
	wire reg_write;
	wire mem_read;
	wire mem_write;
	wire is_branch;
	wire is_jump;
	wire [1:0] wb_sel;
	wire [31:0] rs1_data, rs2_data;

	wire [31:0] alu_result;
	wire is_branch_taken;
	wire [31:0] branch_target;

    // IF+ID
	ID_top dut (
		.clk(clk),
		.reset(reset),
		.pc_write(pc_write),
		.next_pc(next_pc),
		.pc_out(pc_out),
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
		.rs1_data(rs1_data),
		.rs2_data(rs2_data)
	);

	EX_top ex_stage(
		.pc(pc_out),
		.rs1_data(rs1_data),
		.rs2_data(rs2_data),
		.imm(imm),

		.alu_src(alu_src),
		.alu_op(alu_op),
		.is_branch(is_branch),
		.is_jump(is_jump),
		.funct3(funct3),

		.alu_result(alu_result),
		.is_branch_taken(is_branch_taken),
		.branch_target(branch_target)
	);

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	initial begin
		reset = 1;
		pc_write = 1;
		next_pc = 32'h00000000;

		#20 reset = 0;

		repeat (40) begin
			// if branch taken, choose target
			if (is_branch_taken)
				next_pc = branch_target;
			else
				next_pc = pc_out + 4;
	
			#10;
			if (instr == 32'h0000006f) begin
				$display("HALT encountered at PC=%h", pc_out);
				$finish;
			end
	
			$display("T=%0t PC=%08h Instr=%08h opcode=%02h rd=%0d rs1=%0d rs2=%0d imm=%08h",
				$time, pc_out, instr, opcode, rd, rs1, rs2, imm);
	
			$display("    rs1_data=%08h rs2_data=%08h alu_result=%08h taken=%b target=%08h",
				rs1_data, rs2_data, alu_result, is_branch_taken, branch_target);
	
			$display("");

		
	end 
		
		$display("======== Finished ID+EX Test ========");
		$finish;
	end

endmodule
