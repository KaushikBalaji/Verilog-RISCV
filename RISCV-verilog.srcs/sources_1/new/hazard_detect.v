module hazard_detection_unit(
    input wire ID_EX_mem_read,
    input wire [4:0] ID_EX_rd,

    input wire [4:0] IF_ID_rs1,
    input wire [4:0] IF_ID_rs2,

    output reg pc_write,
    output reg IF_ID_write,
    output reg ID_EX_flush
);

    always @(*) begin
        // Default: no stall
        pc_write = 1'b1;
        IF_ID_write = 1'b1;
        ID_EX_flush = 1'b0;

        // Load-use hazard
        if (ID_EX_mem_read &&
            (ID_EX_rd != 0) &&
            ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)))
        begin
            pc_write = 1'b0;  // stall PC
            IF_ID_write = 1'b0;  // stall IF/ID
            ID_EX_flush = 1'b1;  // insert bubble
        end
    end

endmodule
