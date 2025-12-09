`timescale 1ns / 1ps

module alu(
	input wire[31:0] a,
	input wire[31:0] b,
	input wire[4:0] alu_op,
	output reg[31:0] result 
	);
	
	always @(*) begin
		case(alu_op)
			5'b00000: result = a + b;          // ADD
			5'b00001: result = a - b;          // SUB
			5'b00010: result = a & b;          // AND
			5'b00011: result = a | b;          // OR
			5'b00100: result = a ^ b;          // XOR
			5'b00101: result = a << b[4:0];   // SLL
			5'b00110: result = a >> b[4:0];   // SRL
			5'b00111: result = $signed(a) >>> b[4:0]; // SRA
			5'b01000: result = ( $signed(a) < $signed(b) ) ? 32'b1 : 32'b0; // SLT
			5'b01001: result = ( a < b ) ? 32'b1 : 32'b0; // SLTU
			5'b01010: result = b;                     // PASS
			5'b01011: result = a + 32'd4;            // ADDPC
			
			5'b01100: result = $signed(a) * $signed(b); // MUL
			5'b01101: result = ( ($signed(a) * $signed(b)) >> 32 ); // MULH
			5'b01110: result = ( ($signed(a) * b) >> 32 ); // MULHSU
			5'b01111: result = ( (a * b) >> 32 ); // MULHU
			5'b10000: result = $signed(a) / $signed(b); // DIV
			5'b10001: result = a / b; // DIVU
			5'b10010: result = $signed(a) % $signed(b); // REM
            5'b10011: result = a % b; // REMU

            default:   result = 32'hdeadbeef; // illegal alu_op
		endcase	
	end
	
endmodule 
