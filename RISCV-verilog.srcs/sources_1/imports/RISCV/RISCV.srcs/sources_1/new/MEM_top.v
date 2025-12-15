`timescale 1ns / 1ps

module MEM_top(
	input wire clk,
	input wire mem_read,
	input wire mem_write,

	input wire[31:0] alu_result,
	input wire[31:0] rs2_data,
	// input wire[1:0] wb_sel,
	input wire[1:0] mem_size,
	input wire mem_signed,

	// output wire[31:0] wb_data,
	// For testing purpose
	output wire[31:0] mem_data_out
);

	wire [31:0] mem_read_data;

	data_mem DATA_MEM_inst (
		.clk(clk),
		.mem_read(mem_read),
		.mem_write(mem_write),
		.addr(alu_result),
		.write_data(rs2_data),
		.mem_size(mem_size),
		.mem_signed(mem_signed),
		.mem_data_out(mem_read_data)
	);

	assign mem_data_out = mem_read_data;


endmodule
