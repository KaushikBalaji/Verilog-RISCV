
module instr_mem(
	input wire[31:0] addr, output wire[31:0] instr
);

reg[31:0] mem[0:2048];
	
initial begin
	$display("Loading hex file");
	$readmemh("1-even.hex", mem);
end

assign instr = mem[addr[31:2]];

endmodule

