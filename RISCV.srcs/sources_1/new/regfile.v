// simple 32x32 register file
module regfile(
	input clk, input reset,
	input reg_write,
	input wire[4:0] rd,
	input wire[4:0] rs1,
	input wire[4:0] rs2,
	input wire[31:0] write_data,
	output wire[31:0] rs1_data,
	output wire[31:0] rs2_data 
);
	reg[31:0] regfile[0:31];
	integer i;
	
	initial begin
		for(i=0;i<32;i=i+1) begin
			regfile[i] <= 32'b0;
		end
	end
	
	assign rs1_data = (rs1 == 0) ? 32'b0 : regfile[rs1];
	assign rs2_data = (rs2 == 0) ? 32'b0 : regfile[rs2];
	
	always @(posedge clk) begin
		if(reset) begin
			 for(i=0;i<32;i=i+1) begin
					regfile[i] <= 32'b0;
				end
		end
		
		else if(reg_write && rd != 0)
			regfile[rd] <= write_data;
	end
	 
endmodule