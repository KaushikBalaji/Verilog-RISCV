
module instr_mem(
	input wire[31:0] addr, output wire[31:0] instr
);

reg[31:0] mem[0:2048];
	
integer i;
    initial begin
        $display("Loading hex file ...");
        $readmemh("1-even.hex", mem);

        // pad addresses with zeros for mem not filled by the file .... this removes xxxx values
        for (i = 27; i <= 2048; i = i + 1) begin
            mem[i] = 32'b0;
        end

        $display("Finished loading hex. First words:");
        for (i = 0; i < 16; i = i + 1) $display(" mem[%0d] = %08x", i, mem[i]);
    end

assign instr = mem[addr[31:2]];

endmodule

