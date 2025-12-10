`timescale 1ns / 1ps

module MEM_top #(parameter mem_size = 2048)(
	input wire clk,
	input wire mem_read,
	input wire mem_write,

	input wire[31:0] alu_result,
	input wire[31:0] rs2_data,
	input wire[1:0] wb_sel,

	output wire[31:0] wb_data,
	// For testing purpose
	output wire[31:0] mem_data_out
);

	wire [31:0] mem_read_data;

	data_mem #(mem_size) DATA_MEM_inst (
		.clk(clk),
		.mem_read(mem_read),
		.mem_write(mem_write),
		.addr(alu_result),
		.write_data(rs2_data),
		.mem_data_out(mem_read_data)
	);

	assign mem_data_out = mem_read_data;

	assign wb_data = (wb_sel == 2'b00) ? alu_result : mem_read_data;

endmodule
