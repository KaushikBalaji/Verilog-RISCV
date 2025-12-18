`timescale 1ns/1ps
`include "instr_size.vh"

module instr_mem(input wire[31:0] addr,
                 output wire[31:0] instr);
    
    reg[31:0] mem[0:2048];
    
    integer read, i;
    initial begin : print_mem
        // pad addresses with zeros for mem not filled by the file .... this removes xxxx values
        for (i = 0; i < 2048; i = i + 1) begin
            mem[i] = 32'b0;
        end
        $display("Loading hex file ... INSTR mem module");
        $readmemh("addi_instr_raw.hex", mem);
	$display("Loaded INSTR_WORDS = %0d", `INSTR_WORDS);
//        if(!read)
//        	$display("Could not find the 1-even.hex file");
        
        
        $display("Finished loading hex. First words:");
        for (i = 0; i < `INSTR_WORDS + 1 ; i = i + 1) begin
		$display(" mem[%0d] = %08x", i, mem[i]);
	end
    end
    
    assign instr = mem[addr[31:2]];
    
endmodule
    
