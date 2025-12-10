module main_cpu(
    input  wire clk,
    input  wire reset
);

    // ======================
    // IF Stage
    // ======================
    wire [31:0] pc_out;
    reg  [31:0] next_pc;
    wire [31:0] instr;
    wire is_branch_taken;
    wire [31:0] branch_target;

    // PC
    pc PC_inst(
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc_write(1'b1),
        .pc_out(pc_out)
    );

    // Instruction Memory
    instr_mem IMEM_inst(
        .addr(pc_out),
        .instr(instr)
    );


    // ======================
    // ID Stage
    // ======================
    wire [6:0]  opcode;
    wire [4:0]  rd, rs1, rs2;
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
    wire [31:0] rs1_data, rs2_data;

    instr_decode DEC_inst(
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
        .wb_sel(wb_sel),
	.mem_size(),
	.mem_signed(),	// not used currently
        .illegal()
    );

    // Register File (WB not connected yet → reg values ALWAYS 0)
    regfile REGFILE_inst(
        .clk(clk),
        .reset(reset),
        .reg_write(1'b0),       // disabled for now
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .write_data(32'b0),     // will connect from WB later
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );


    // ======================
    // EX Stage
    // ======================
    wire [31:0] alu_result;

    EX_top EX_inst(
        .pc(pc_out),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .is_branch(is_branch),
        .is_jump(is_jump),
        .funct3(funct3),
        .alu_result(alu_result),
        .is_branch_taken(is_branch_taken),
        .branch_target(branch_target)
    );


    // ======================
    // MEM Stage
    // ======================
    wire [31:0] mem_data_out;

    MEM_top #(2048) DMEM_inst(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_result(alu_result),
        .rs2_data(rs2_data),
	.wb_sel(wb_sel),
	.wb_data(),               // will connect to WB later
        .mem_data_out(mem_data_out)
    );


    // ======================
    // Next PC Logic (IF stage completion)
    // ======================
    always @(*) begin
        if (is_branch_taken)
            next_pc = branch_target;
        else
            next_pc = pc_out + 4;
    end

endmodule
