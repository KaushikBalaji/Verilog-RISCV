`timescale 1ns / 1ps

module forwarding_unit(
    input wire [4:0] ID_EX_rs1,
    input wire [4:0] ID_EX_rs2,

    input wire EX_MEM_reg_write,
    input wire [4:0] EX_MEM_rd,

    input wire MEM_WB_reg_write,
    input wire [4:0] MEM_WB_rd,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);

    always @(*) begin
        forwardA = 2'b00;
        forwardB = 2'b00;

        // EX/MEM forwarding
        if (EX_MEM_reg_write && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs1)
            forwardA = 2'b01;

        if (EX_MEM_reg_write && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs2)
            forwardB = 2'b01;

        // MEM/WB forwarding (only if EX/MEM didn't match)
        if (MEM_WB_reg_write && MEM_WB_rd != 0 &&
            !(EX_MEM_reg_write && EX_MEM_rd == ID_EX_rs1) &&
             MEM_WB_rd == ID_EX_rs1)
            forwardA = 2'b10;

        if (MEM_WB_reg_write && MEM_WB_rd != 0 &&
            !(EX_MEM_reg_write && EX_MEM_rd == ID_EX_rs2) &&
             MEM_WB_rd == ID_EX_rs2)
            forwardB = 2'b10;
    end

endmodule
