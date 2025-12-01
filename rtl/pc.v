
module pc(input wire clk,
          input wire reset,
          input wire [31:0] next_pc,
          input wire pc_write,
          output reg[31:0] pc_out);
    always @ (posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'b0;
        else if (pc_write == 1)
            pc_out <= next_pc;
        else
            pc_out <= pc_out;
    end
endmodule
    
    
    
    
    
