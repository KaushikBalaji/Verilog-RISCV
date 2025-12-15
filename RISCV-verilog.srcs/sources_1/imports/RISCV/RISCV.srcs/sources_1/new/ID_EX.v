`timescale 1ns / 1ps

module ID_EX(
	input clk, reset,

	input flush, write_enable,

	input [31:0] pc_in, // from ID stage
	
	input [31:0] rs1_data_in,
	input [31:0] rs2_data_in,
	input [4:0]  alu_op_in,
	input alu_src_in,
	input is_branch_in,
	input is_jump_in,
	input [2:0]  funct3_in,
	input [31:0] imm_in,

	input mem_read_in,
	input mem_write_in,
	input [1:0]  wb_sel_in,
	input reg_write_in,

	input [4:0] rs1_in,
	input [4:0] rs2_in,
	input [4:0] rd_in,
	input [1:0] mem_size_in,
	input mem_signed_in,

	output reg [31:0] pc_out,
	output reg [31:0] rs1_data_out,
	output reg [31:0] rs2_data_out,
	output reg [4:0] alu_op_out,
	output reg alu_src_out,
	output reg is_branch_out,
	output reg is_jump_out,
	output reg [2:0] funct3_out,
	output reg [31:0] imm_out,
	output reg mem_read_out,
	output reg mem_write_out,
	output reg [1:0] wb_sel_out,
	output reg reg_write_out,
	output reg [4:0] rs1_out,
	output reg [4:0] rs2_out,
	output reg [4:0] rd_out,
	output reg [1:0] mem_size_out,
	output reg mem_signed_out
);

	always @(posedge clk) begin
		if (reset ) begin
			pc_out <= 32'b0;
			rs1_data_out <= 32'b0;
			rs2_data_out <= 32'b0;
			alu_op_out <= 5'b0;
			alu_src_out <= 1'b0;
			is_branch_out <= 1'b0;
			is_jump_out <= 1'b0;
			funct3_out <= 3'b0;
			imm_out <= 32'b0;

			mem_read_out <= 1'b0;
			mem_write_out <= 1'b0;
			wb_sel_out <= 2'b0;
			reg_write_out <= 1'b0;

			rs1_out <= 5'b0;
			rs2_out <= 5'b0;
			rd_out <= 5'b0;

			mem_size_out <= 2'b0;
			mem_signed_out <= 1'b0;
		end
		else if (write_enable) begin
			pc_out <= pc_in;
			rs1_data_out <= rs1_data_in;
			rs2_data_out <= rs2_data_in;
			alu_op_out <= alu_op_in;
			alu_src_out <= alu_src_in;
			is_branch_out <= is_branch_in;
			is_jump_out <= is_jump_in;
			funct3_out <= funct3_in;
			imm_out <= imm_in;
			
			mem_read_out <= mem_read_in;
			mem_write_out <= mem_write_in;
			wb_sel_out <= wb_sel_in;
			reg_write_out <= reg_write_in;

			rs1_out <= rs1_in;
			rs2_out <= rs2_in;
			rd_out <= rd_in;

			mem_size_out <= mem_size_in;
			mem_signed_out <= mem_signed_in;
		end
		else begin
			// stall, do nothing
		end
	end
endmodule
