`timescale 1ns / 1ps

module Forwarding_unit(
	wire [4:0] ID_EX_rs1, ID_EX_rs2,
	wire [4:0] EX_MEM_rd,
	wire EX_MEM_reg_write,
	wire [4:0] MEM_WB_rd,
	wire MEM_WB_reg_write,
	output reg [1:0] forwardA,
	output reg [1:0] forwardB
);
	always @(*) begin
		// Initialize forwarding signals to no forwarding
		// forwardA = 2'b01 means forward from EX stage
		// forwardA = 2'b10 means forward from MEM stage
		// same for forwardB
		forwardA = 2'b00;
		forwardB = 2'b00;

		// Check for hazard from EX stage
		if (EX_MEM_reg_write && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs1)) begin
			forwardA = 2'b01;
		end
		if (EX_MEM_reg_write && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs2)) begin
			forwardB = 2'b01;
		end

		// Check for hazard from MEM stage
		if (MEM_WB_reg_write && (MEM_WB_rd != 5'b0) && !(EX_MEM_reg_write && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs1)) && (MEM_WB_rd == ID_EX_rs1)) begin
			forwardA = 2'b10;
		end
		if (MEM_WB_reg_write && (MEM_WB_rd != 5'b0) && !(EX_MEM_reg_write && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs2)) && (MEM_WB_rd == ID_EX_rs2)) begin
			forwardB = 2'b10;
		end
	end


endmodule
