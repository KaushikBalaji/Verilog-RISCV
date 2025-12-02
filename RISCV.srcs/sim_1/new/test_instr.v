`timescale 1ns / 1ps

module test_instr;
	reg clk, reset, pc_write;
	reg[31:0] next_pc;
	
	wire[31:0] pc_out;
	wire[31:0] instruction;
	
	
	pc uut_pc (.clk(clk), .reset(reset), .next_pc(next_pc), .pc_write(pc_write), .pc_out(pc_out));
	
	instr_mem uut_instr_mem (.addr(pc_out), .instr(instruction));
	
	always #5 clk = ~clk;
	
	initial begin
		clk = 0;
		reset = 1;
		pc_write = 1;
		next_pc = 0;
		#10;
		
		reset = 0;
		
		repeat(10) begin
			$display ("PC=%h	Instruction=%h", pc_out, instruction);
			next_pc = pc_out+4;
			#10;
		end
		
		$finish;
	end

endmodule
