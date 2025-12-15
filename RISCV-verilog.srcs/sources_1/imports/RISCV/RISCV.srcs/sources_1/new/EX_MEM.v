`timescale 1ns / 1ps

module EX_MEM(
	input clk, reset,

	input flush, write_enable,

	input wire[31:0] pc_in,
	input wire[31:0] alu_result_in,
	input wire[31:0] rs2_data_in,
	input wire[4:0] rd_in,

	input mem_read_in,
	input mem_write_in,
	input reg_write_in,
	input [1:0] wb_sel_in,

	input is_branch_in,
	input is_jump_in,
	input [31:0] branch_target_in,
	input is_branch_taken_in,
	input wire [1:0] mem_size_in,
	input wire mem_signed_in,

	output reg[31:0] pc_out,
	output reg[31:0] alu_result_out,
	output reg[31:0] rs2_data_out,
	output reg[4:0] rd_out,

	output reg mem_read_out,
	output reg mem_write_out,
	output reg reg_write_out,
	output reg [1:0] wb_sel_out,

	output reg is_branch_out,
	output reg is_jump_out,
	output reg[31:0] branch_target_out,
	output reg is_branch_taken_out,
	output reg [1:0] mem_size_out,
	output reg mem_signed_out
);

	always @(posedge clk) begin
		if (reset || flush) begin
			pc_out <= 32'b0;
			alu_result_out <= 32'b0;
			rs2_data_out <= 32'b0;
			rd_out <= 5'b0;

			is_branch_out <= 1'b0;
			is_jump_out <= 1'b0;
			branch_target_out <= 32'b0;
			is_branch_taken_out <= 1'b0;
			mem_read_out <= 1'b0;
			mem_write_out <= 1'b0;
			reg_write_out <= 1'b0;
			wb_sel_out <= 2'b0;
			mem_size_out <= 2'b0;
			mem_signed_out <= 1'b0;
		end
		else if (write_enable) begin
			pc_out <= pc_in;
			alu_result_out <= alu_result_in;
			rs2_data_out <= rs2_data_in;
			rd_out <= rd_in;

			is_branch_out <= is_branch_in;
			is_jump_out <= is_jump_in;
			branch_target_out <= branch_target_in;
			is_branch_taken_out <= is_branch_taken_in;

			mem_read_out <= mem_read_in;
			mem_write_out <= mem_write_in;
			reg_write_out <= reg_write_in;
			wb_sel_out <= wb_sel_in;
			mem_size_out <= mem_size_in;
			mem_signed_out <= mem_signed_in;
		end
		else begin
			// stall, do nothing
		end
	end

	
endmodule
