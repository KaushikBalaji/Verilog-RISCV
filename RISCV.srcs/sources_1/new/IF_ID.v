`timescale 1ns / 1ps


module IF_ID(
	input wire clk,
	input wire reset,
	input wire flush,
	input wire write_enable,

	input wire [31:0] pc_in,
	input wire [31:0] instr_in,

	output reg [31:0] pc_out,
	output reg [31:0] instr_out
);

	always @(posedge clk) begin
		if (reset) begin
			pc_out <= 32'b0;
			instr_out <= 32'b0;		// NOP
		end
		else if (flush) begin
			pc_out <= 32'b0;
			instr_out <= 32'b0;		// NOP
		end
		else if(write_enable) begin
			pc_out <= pc_in;
			instr_out <= instr_in;
		end
		else begin
			// stall, do nothing
		end
	end
endmodule