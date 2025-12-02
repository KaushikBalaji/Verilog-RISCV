// tb_id_stage.v
`timescale 1ns/1ps

module test_ID;

    reg clk;
    reg reset;
    reg pc_write;
    reg [31:0]  next_pc;

    wire [31:0] pc_out;
    wire [31:0] instr;
    wire [6:0]  opcode;
    wire [4:0]  rd;
    wire [4:0]  rs1;
    wire [4:0]  rs2;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] imm;
    wire [4:0]  alu_op;
    wire alu_src;
    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire is_branch;
    wire is_jump;
    wire [1:0] wb_sel;

    ID_top dut (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .next_pc(next_pc),
        .pc_out(pc_out),
        .instr(instr),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7),
        .imm(imm),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .is_branch(is_branch),
        .is_jump(is_jump),
        .wb_sel(wb_sel)
    );

    // clk gen
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns period
    end

    initial begin
        // initial values
        reset = 1;
        pc_write = 1;
        next_pc = 32'h00000000;
        #20;
        reset = 0;

        // run for N instructions
        repeat (40) begin
            next_pc = pc_out + 4;
            #10; // one clock period (pos edge occurs at each #5)
            $display("Time=%0t PC=%08h Instruction=%08h opcode=%02h rd=%0d rs1=%0d rs2=%0d imm=%08h alu_op=%02h regw=%b memr=%b memw=%b branch=%b jump=%b",
                     $time, pc_out, instr, opcode, rd, rs1, rs2, imm, alu_op, reg_write, mem_read, mem_write, is_branch, is_jump);
        end

        $display("Finished testbench");
        $finish;
    end

endmodule
