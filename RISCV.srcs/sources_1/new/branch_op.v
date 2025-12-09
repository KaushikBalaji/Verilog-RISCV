`timescale 1ns / 1ps

module branch_op(
	
	input wire[31:0] rs1_data,
	input wire[31:0] rs2_data,
	input wire[2:0] funct3,
    	output reg is_branch_taken      // for branch prediction
);


	always @(*) begin
		case (funct3)
			3'b000: is_branch_taken = (rs1_data == rs2_data); // BEQ
			3'b001: is_branch_taken = (rs1_data != rs2_data); // BNE
			3'b100: is_branch_taken = ($signed(rs1_data) < $signed(rs2_data)); // BLT
			3'b101: is_branch_taken = ($signed(rs1_data) >= $signed(rs2_data)); // BGE
			3'b110: is_branch_taken = (rs1_data < rs2_data); // BLTU
			3'b111: is_branch_taken = (rs1_data >= rs2_data); // BGEU
			default: is_branch_taken = 1'b0; // illegal funct3            
		endcase
    
	end

endmodule