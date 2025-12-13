`timescale 1ns / 1ps

module main_cpu(
	input wire clk,
	input wire reset
);

	// ============================================================
	// IF STAGE
	// ============================================================

	wire [31:0] pc_out;
	reg  [31:0] next_pc;
	wire pc_write = 1'b1;    // hazard unit later

	pc PC_inst(
		.clk(clk),
		.reset(reset),
		.pc_write(pc_write),
		.next_pc(next_pc),
		.pc_out(pc_out)
	);

	wire [31:0] instr;
	wire [31:0] EX_MEM_alu;

	instr_mem IMEM_inst(
		.addr(pc_out),
		.instr(instr)
	);


	// ============================================================
	// IF/ID PIPELINE REGISTER
	// ============================================================

	wire [31:0] IF_ID_pc, IF_ID_instr;

	wire IF_ID_flush = 1'b0;   // later: branch flush
	wire IF_ID_write = 1'b1;   // later: stall

	IF_ID IF_ID_inst(
		.clk(clk),
		.reset(reset),
		.flush(IF_ID_flush),
		.write_enable(IF_ID_write),
		.pc_in(pc_out),
		.instr_in(instr),
		.pc_out(IF_ID_pc),
		.instr_out(IF_ID_instr)
	);


	// ============================================================
	// ID STAGE
	// ============================================================

	wire [4:0] ID_rs1, ID_rs2, ID_rd;
	wire [2:0] ID_funct3;
	wire [6:0] ID_funct7;
	wire [31:0] ID_imm;

	wire [4:0] ID_alu_op;
	wire ID_alu_src;
	wire ID_reg_write, ID_mem_read, ID_mem_write;
	wire ID_is_branch, ID_is_jump;
	wire [1:0] ID_wb_sel;

	wire [31:0] ID_rs1_data, ID_rs2_data;

	instr_decode DEC_inst(
		.instr(IF_ID_instr),
		.opcode(),  // not needed separately
		.rd(ID_rd),
		.rs1(ID_rs1),
		.rs2(ID_rs2),
		.funct3(ID_funct3),
		.funct7(ID_funct7),
		.imm(ID_imm),
		.alu_op(ID_alu_op),
		.alu_src(ID_alu_src),
		.reg_write(ID_reg_write),
		.mem_read(ID_mem_read),
		.mem_write(ID_mem_write),
		.is_branch(ID_is_branch),
		.is_jump(ID_is_jump),
		.wb_sel(ID_wb_sel),
		.mem_size(),
		.mem_signed(),
		.illegal()
	);

	// -------- Register File --------
	wire [31:0] WB_data;
	wire WB_reg_write;
	wire [4:0] WB_rd;

	regfile RF_inst(
		.clk(clk),
		.reset(reset),
		.reg_write(WB_reg_write),
		.rd(WB_rd),
		.rs1(ID_rs1),
		.rs2(ID_rs2),
		.write_data(WB_data),
		.rs1_data(ID_rs1_data),
		.rs2_data(ID_rs2_data)
	);


	// ============================================================
	// ID/EX PIPELINE REGISTER
	// ============================================================

	wire [31:0] ID_EX_pc, ID_EX_rs1, ID_EX_rs2, ID_EX_imm;
	wire [4:0] ID_EX_rs1_addr, ID_EX_rs2_addr, ID_EX_rd;
	wire [4:0] ID_EX_alu_op;
	wire ID_EX_alu_src, ID_EX_is_branch, ID_EX_is_jump;
	wire [2:0] ID_EX_funct3;
	wire ID_EX_reg_write, ID_EX_mem_read, ID_EX_mem_write;
	wire [1:0]  ID_EX_wb_sel;

	wire ID_EX_flush = 1'b0;
	wire ID_EX_write = 1'b1;

	ID_EX ID_EX_inst(
		.clk(clk),
		.reset(reset),
		.flush(ID_EX_flush),
		.write_enable(ID_EX_write),

		.pc_in(IF_ID_pc),
		.rs1_data_in(ID_rs1_data),
		.rs2_data_in(ID_rs2_data),
		.imm_in(ID_imm),

		.rs1_in(ID_rs1),
		.rs2_in(ID_rs2),
		.rd_in(ID_rd),

		.alu_op_in(ID_alu_op),
		.alu_src_in(ID_alu_src),
		.is_branch_in(ID_is_branch),
		.is_jump_in(ID_is_jump),
		.funct3_in(ID_funct3),

		.mem_read_in(ID_mem_read),
		.mem_write_in(ID_mem_write),
		.wb_sel_in(ID_wb_sel),
		.reg_write_in(ID_reg_write),

		.pc_out(ID_EX_pc),
		.rs1_data_out(ID_EX_rs1),
		.rs2_data_out(ID_EX_rs2),
		.imm_out(ID_EX_imm),
		.rs1_out(ID_EX_rs1_addr),
		.rs2_out(ID_EX_rs2_addr),
		.rd_out(ID_EX_rd),

		.alu_op_out(ID_EX_alu_op),
		.alu_src_out(ID_EX_alu_src),
		.is_branch_out(ID_EX_is_branch),
		.is_jump_out(ID_EX_is_jump),
		.funct3_out(ID_EX_funct3),

		.mem_read_out(ID_EX_mem_read),
		.mem_write_out(ID_EX_mem_write),
		.wb_sel_out(ID_EX_wb_sel),
		.reg_write_out(ID_EX_reg_write)
	);


	// ============================================================
	// EX STAGE (with forwarding added)
	// ============================================================

	// ---------- Forwarding Wires ----------
	wire [1:0] ForwardA, ForwardB;

	// forwarded ALU operands
	reg [31:0] EX_rs1_fwd;
	reg [31:0] EX_rs2_fwd;

	// ---------- Forwarding Unit ----------
	forwarding_unit FU_inst(
		.ID_EX_rs1(ID_EX_rs1_addr),
		.ID_EX_rs2(ID_EX_rs2_addr),

		.EX_MEM_reg_write(EX_MEM_reg_write),
		.EX_MEM_rd(EX_MEM_rd),

		.MEM_WB_reg_write(MEM_WB_reg_write),
		.MEM_WB_rd(MEM_WB_rd),

		.forwardA(ForwardA),
		.forwardB(ForwardB)
	);


	// ---------- Forwarding Muxes ----------
	always @(*) begin

	// Forwarding for RS1
	case (ForwardA)
		2'b00: EX_rs1_fwd = ID_EX_rs1;    // from ID/EX
		2'b01: EX_rs1_fwd = EX_MEM_alu;   // from EX/MEM
		2'b10: EX_rs1_fwd = WB_data;      // from MEM/WB
		default: EX_rs1_fwd = ID_EX_rs1;
	endcase

	// Forwarding for RS2
	case (ForwardB)
		2'b00: EX_rs2_fwd = ID_EX_rs2;
		2'b01: EX_rs2_fwd = EX_MEM_alu;
		2'b10: EX_rs2_fwd = WB_data;
		default: EX_rs2_fwd = ID_EX_rs2;
	endcase
	end


	// ---------- EX Top ----------
	wire [31:0] EX_alu_result;
	wire EX_branch_taken;
	wire [31:0] EX_branch_target;

	EX_top EX_inst(
		.pc(ID_EX_pc),
		.rs1_data(EX_rs1_fwd),
		.rs2_data(EX_rs2_fwd),
		.imm(ID_EX_imm),
		.alu_op(ID_EX_alu_op),
		.alu_src(ID_EX_alu_src),
		.is_branch(ID_EX_is_branch),
		.is_jump(ID_EX_is_jump),
		.funct3(ID_EX_funct3),

		.alu_result(EX_alu_result),
		.is_branch_taken(EX_branch_taken),
		.branch_target(EX_branch_target)
	);



	// ============================================================
	// EX/MEM PIPELINE REGISTER
	// ============================================================

	wire [31:0] EX_MEM_pc, EX_MEM_rs2, EX_MEM_branch_target;
	wire EX_MEM_taken, EX_MEM_is_branch, EX_MEM_is_jump;
	wire EX_MEM_mem_read, EX_MEM_mem_write;
	wire [1:0] EX_MEM_wb_sel;

	wire EX_MEM_flush = 1'b0;
	wire EX_MEM_write = 1'b1;

	EX_MEM EX_MEM_inst(
		.clk(clk),
		.reset(reset),
		.flush(EX_MEM_flush),
		.write_enable(EX_MEM_write),

		.pc_in(ID_EX_pc),
		.rs2_data_in(EX_rs2_fwd),
		.alu_result_in(EX_alu_result),

		.branch_target_in(EX_branch_target),
		.is_branch_taken_in(EX_branch_taken),

		.is_branch_in(ID_EX_is_branch),
		.is_jump_in(ID_EX_is_jump),

		.mem_read_in(ID_EX_mem_read),
		.mem_write_in(ID_EX_mem_write),
		.wb_sel_in(ID_EX_wb_sel),
		.reg_write_in(ID_EX_reg_write),
		.rd_in(ID_EX_rd),

		.pc_out(EX_MEM_pc),
		.rs2_data_out(EX_MEM_rs2),
		.alu_result_out(EX_MEM_alu),
		.branch_target_out(EX_MEM_branch_target),
		.is_branch_taken_out(EX_MEM_taken),
		.is_branch_out(EX_MEM_is_branch),
		.is_jump_out(EX_MEM_is_jump),

		.mem_read_out(EX_MEM_mem_read),
		.mem_write_out(EX_MEM_mem_write),
		.wb_sel_out(EX_MEM_wb_sel),
		.reg_write_out(EX_MEM_reg_write),
		.rd_out(EX_MEM_rd)
	);


	// ============================================================
	// MEM STAGE
	// ============================================================

	wire [31:0] MEM_data_out;

	MEM_top #(.mem_size(2048)) DMEM_inst(
		.clk(clk),
		.mem_read(EX_MEM_mem_read),
		.mem_write(EX_MEM_mem_write),
		.alu_result(EX_MEM_alu),
		.rs2_data(EX_MEM_rs2),
		.mem_data_out(MEM_data_out)
	);


	// ============================================================
	// MEM/WB PIPELINE REGISTER
	// ============================================================

	wire [31:0] MEM_WB_alu, MEM_WB_mem;
	wire [1:0]  MEM_WB_wb_sel;

	wire MEM_WB_flush = 1'b0;
	wire MEM_WB_write = 1'b1;

	MEM_WB MEM_WB_inst(
		.clk(clk),
		.reset(reset),
		.flush(MEM_WB_flush),
		.write_enable(MEM_WB_write),

		.alu_result_in(EX_MEM_alu),
		.mem_data_in(MEM_data_out),

		.wb_sel_in(EX_MEM_wb_sel),
		.reg_write_in(EX_MEM_reg_write),
		.rd_in(EX_MEM_rd),

		.alu_result_out(MEM_WB_alu),
		.mem_data_out(MEM_WB_mem),
		.wb_sel_out(MEM_WB_wb_sel),
		.reg_write_out(MEM_WB_reg_write),
		.rd_out(MEM_WB_rd)
	);


	// ============================================================
	// WB STAGE
	// ============================================================

	WB_top WB_inst(
		.wb_sel(MEM_WB_wb_sel),
		.alu_result(MEM_WB_alu),
		.mem_data_out(MEM_WB_mem),
		.pc_plus_4(EX_MEM_pc + 4),   // alternative: carry PC+4 in ID/EX
		.wb_data(WB_data)
	);

	assign WB_rd = MEM_WB_rd;
	assign WB_reg_write = MEM_WB_reg_write;


	// ============================================================
	// NEXT PC LOGIC
	// ============================================================

	always @(*) begin
		if (EX_MEM_taken)
			next_pc = EX_MEM_branch_target;
		else
			next_pc = pc_out + 4;
	end

endmodule
