`timescale 1ns / 1ps

module data_mem #(parameter mem_size = 2048)(
	input clk,
	input mem_read, mem_write,
	input [31:0] addr,
	input [31:0] write_data,
	output reg[31:0] mem_data_out
    );

	reg[31:0] mem[0:mem_size-1];		// 32*mem_size bits memory
    
	integer i;
	initial begin
		// pad addresses with zeros for mem not filled by the file .... this removes xxxx values
		for (i = 0; i < mem_size; i = i + 1) begin
			mem[i] = 32'b0;
		end

		$display("Loading hex file ...DATA mem module");
		$readmemh("data_raw.hex", mem);
		
		$display("Finished loading hex. First words:");
		for (i = 0; i < 5; i = i + 1) $display(" mem[%0d] = %08x", i, mem[i]);
	end

	wire [7:0] word_pos = addr[9:2];

	always @(*) begin
		if(mem_write)
			mem[word_pos] <= write_data;
		if(mem_read)
			mem_data_out <= mem[word_pos];	
	end


endmodule