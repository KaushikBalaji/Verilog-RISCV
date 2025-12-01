
module pc_tb; 

    reg clk, reset, pc_write; 
    reg [31:0] next_pc; 
    wire [31:0] pc_out; 
    
    pc uut (.clk(clk), .reset(reset), .next_pc(next_pc), .pc_write(pc_write), .pc_out(pc_out));

// clock gen
always #5 clk = ~clk;

initial begin
    // Initialize inputs
    clk      = 0;
    reset    = 1;
    pc_write = 1;
    next_pc  = 0;
    #10;
    
    reset = 0;
    
    repeat (5) begin
        next_pc = next_pc + 4;
        #10;
    end
    $finish;
end

endmodule
