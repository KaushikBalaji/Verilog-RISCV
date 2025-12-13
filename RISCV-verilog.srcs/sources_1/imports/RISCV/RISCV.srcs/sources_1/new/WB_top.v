`timescale 1ns / 1ps


module WB_top(
	input wire[31:0] alu_result,
	input wire[31:0] mem_data_out,
	input wire[1:0] wb_sel,
	input wire[31:0] pc_plus_4, 
	output reg[31:0] wb_data

);

	always @(*) begin
		case(wb_sel)
			2'b00: wb_data = alu_result;
			2'b01: wb_data = mem_data_out;
			2'b10: wb_data = pc_plus_4;
			default: wb_data = alu_result; // default case
		endcase
	end

endmodule
