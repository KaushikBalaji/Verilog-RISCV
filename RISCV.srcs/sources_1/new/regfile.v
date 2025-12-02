// simple 32x32 register file
module regfile(
    input wire clk,
    input wire we,                 // write enable (synchronous)
    input wire [4:0] waddr,
    input wire [31:0] wdata,
    input wire [4:0] raddr1,
    input wire [4:0] raddr2,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2
);
    reg [31:0] regs [0:31];
    integer i;
    initial begin
        for (i=0; i<32; i=i+1) regs[i] = 32'b0;
    end

    // synchronous write on rising edge
    always @(posedge clk) begin
        if (we && (waddr != 5'b0)) regs[waddr] <= wdata; // x0 is hardwired zero
    end

    // combinational read ports
    assign rdata1 = (raddr1 == 5'b0) ? 32'b0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'b0) ? 32'b0 : regs[raddr2];
endmodule