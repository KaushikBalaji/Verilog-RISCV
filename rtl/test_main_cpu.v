`timescale 1ns/1ps

module test_main_cpu;

	wire clk;
	wire reset;

	wire pc_write;
	wire [31:0] next_pc;
	wire [31:0] pc_out;
	wire [31:0] instr;

	wire [6:0]  opcode;
	wire [4:0]  rd, rs1, rs2;
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

	wire [31:0] rs1_data;
	wire [31:0] rs2_data;

	// ===== EX Stage =====
	wire [31:0] alu_result;
	wire is_branch_taken;
	wire [31:0] branch_target;

	// ===== MEM Stage =====
	wire [31:0] wb_data;
	wire [31:0] mem_debug_out;


	ID_top id_stage (
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

	// EX stage instance

	EX_top ex_stage(
		.pc(pc_out),
		.rs1_data(rs1_data),
		.rs2_data(rs2_data),
		.imm(imm),
		.alu_op(alu_op),
		.alu_src(alu_src),
		.is_branch(is_branch),
		.is_jump(is_jump),
		.funct3(funct3),
		.alu_result(alu_result),
		.is_branch_taken(is_branch_taken),
		.branch_target(branch_target)
	);


	// MEM stage instance
	MEM_top mem_stage(
		.clk(clk),
		.mem_read(mem_read),
		.mem_write(mem_write),
		.alu_result(alu_result),
		.rs2_data(rs2_data),
		.wb_sel(wb_sel),
		.wb_data(wb_data),
		.mem_data_out(mem_debug_out)
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

		$display("===== CPU Simulation Start =====");

		repeat (80) begin
			
			// control PC update
			if (is_branch_taken)
				next_pc = branch_target;
			else
				next_pc = pc_out + 4;

			#10;

			$display("[%0t] PC=%08h | Instr=%08h", $time, pc_out, instr);
			$display("  Decode: rd=%0d rs1=%0d rs2=%0d funct3=%0h imm=%08h", 
				rd, rs1, rs2, funct3, imm);
			$display("  Exec:   ALU=%08h BranchTaken=%b Target=%08h",
				alu_result, is_branch_taken, branch_target);
			$display("  MEM:    Read=%b Write=%b -> Data=%08h", 
				mem_read, mem_write, wb_data);
			$display("");

			// HALT (j halt = 0000006F)
			if (instr == 32'h0000006F) begin
				$display("===== HALT encountered at PC=%08h =====", pc_out);
				$finish;
			end
		end

		$display("===== CPU Simulation Timeout =====");
		$finish;

	end
endmodule



