`timescale 1ns / 1ps


module EX_top(
        input wire[31:0] pc, rs1_data, rs2_data, imm,
        input wire[4:0] alu_op,
        input wire alu_src,
        input wire is_branch, is_jump,
        input wire[2:0] funct3,

        output wire[31:0] alu_result,
        output wire is_branch_taken,
        output wire[31:0] branch_target
);

        wire [31:0] alu_b;

        assign alu_b = alu_src ? imm : rs2_data;

        alu ALU_inst(
                .a(rs1_data),
                .b(alu_b),
                .alu_op(alu_op),
                .result(alu_result)
        );

        branch_op BRANCH_inst(
                .rs1_data(rs1_data),
                .rs2_data(rs2_data),
                .funct3(funct3),
                .is_branch_taken(is_taken)
        );

	assign is_branch_taken = is_branch & is_taken;

        // funct3 = 0 -> JAL , so pc + imm, else JALR , so rs1 + imm

        assign branch_target = is_jump ? ((funct3 == 3'b000) ? (pc + imm) : (rs1_data + imm)) : (pc + imm);

endmodule
