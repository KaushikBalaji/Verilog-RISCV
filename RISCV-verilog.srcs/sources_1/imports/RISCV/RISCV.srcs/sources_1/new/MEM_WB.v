`timescale 1ns / 1ps


module MEM_WB(
	input clk, reset,

	input flush, write_enable,

	input wire[31:0] alu_result_in,
	input wire[31:0] mem_data_in,
	input wire[4:0] rd_in,

	input reg_write_in,
	input [1:0] wb_sel_in,
	input wire[1:0] mem_size_in,
	input wire mem_signed_in,

	output reg[31:0] alu_result_out,
	output reg[31:0] mem_data_out,
	output reg[4:0] rd_out,

	output reg reg_write_out,
	output reg [1:0] wb_sel_out,
	output reg [1:0] mem_size_out,
	output reg mem_signed_out
);

	always @(posedge clk) begin
		if (reset || flush) begin
			alu_result_out <= 32'b0;
			mem_data_out <= 32'b0;
			rd_out <= 5'b0;

			reg_write_out <= 1'b0;
			wb_sel_out <= 2'b0;
			mem_size_out <= 2'b0;
			mem_signed_out <= 1'b0;
		end
		else if (write_enable) begin
			alu_result_out <= alu_result_in;
			mem_data_out <= mem_data_in;
			rd_out <= rd_in;

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
