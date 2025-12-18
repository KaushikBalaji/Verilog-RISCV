`timescale 1ns / 1ps
`include "data_size.vh"

module data_mem (
	input clk,
	input mem_read, mem_write,
	input [31:0] addr,
	input [31:0] write_data,
	input [1:0] mem_size,
	input mem_signed,
	output reg[31:0] mem_data_out
    );

	reg[31:0] mem[0:2047];		// 32*mem_size bits memory
    
	integer i;
	initial begin : print_mem
		// pad addresses with zeros for mem not filled by the file .... this removes xxxx values
		for (i = 0; i < 2048; i = i + 1) begin
			mem[i] = 32'b0;
		end

		$display("Loading hex file ...DATA mem module");
		$readmemh("addi_data_raw.hex", mem);
		$display("Loaded DATA_WORDS = %0d", `DATA_WORDS);
		
		$display("Finished loading hex. First words:");
		for (i = 0; i < `DATA_WORDS + 1; i = i + 1) begin
			$display(" mem[%0d] = %08x", i, mem[i]);
		end
	end

	wire [7:0] word_pos = addr[9:2];

	wire [31:0] word = mem[word_pos];

	wire [7:0] byte = (addr[1:0] == 2'b00) ? word[7:0] : 	// LB
			(addr[1:0] == 2'b01) ? word[15:8] :	// LH
			(addr[1:0] == 2'b10) ? word[23:16] :		//LW
						word[31:24];	

	wire [15:0] half = (addr[1] == 1'b0) ? word[15:0] : word[31:16];


	always @(posedge clk) begin
	if (mem_write) begin
		case (mem_size)
		2'b00: begin // SB
			case (addr[1:0])
			2'b00: mem[word_pos][7:0]   <= write_data[7:0];
			2'b01: mem[word_pos][15:8]  <= write_data[7:0];
			2'b10: mem[word_pos][23:16] <= write_data[7:0];
			2'b11: mem[word_pos][31:24] <= write_data[7:0];
			endcase
		end

		2'b01: begin // SH
			if (addr[1] == 1'b0)
			mem[word_pos][15:0] <= write_data[15:0];
			else
			mem[word_pos][31:16] <= write_data[15:0];
		end

		2'b10: begin // SW
			mem[word_pos] <= write_data;
		end
		endcase
	end
	end

	always @(*) begin
		if (mem_read) begin
			case (mem_size)
				2'b00: mem_data_out = mem_signed ? {{24{byte[7]}}, byte} : {24'b0, byte};
				2'b01: mem_data_out = mem_signed ? {{16{half[15]}}, half} : {16'b0, half};
				2'b10: mem_data_out = word;
				default: mem_data_out = 32'b0;
			endcase
		end 
		else begin
			mem_data_out = 32'b0;
		end
	end


endmodule