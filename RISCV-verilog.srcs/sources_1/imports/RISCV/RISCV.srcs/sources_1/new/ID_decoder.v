`timescale 1ns/1ps

module instr_decode(
	input wire[31:0] instr,
	output wire[6:0] opcode,
	output wire[4:0] rd,
	output wire[4:0] rs1,
	output wire[4:0] rs2,
	output wire[2:0] funct3,
	output wire[6:0] funct7,
	output reg [31:0] imm,
	output reg [4:0] alu_op,
	output reg alu_src,
	output reg reg_write,
	output reg mem_read,
	output reg mem_write,
	output reg is_branch,
	output reg is_jump,
	output reg [1:0] wb_sel,
	output reg [1:0] mem_size,
	output reg mem_signed,
	output reg illegal
);
	assign opcode = instr[6:0];
	assign rd = instr[11:7];
	assign funct3 = instr[14:12];
	assign rs1 = instr[19:15];
	assign rs2 = instr[24:20];
	assign funct7 = instr[31:25];

	localparam ALU_ADD = 5'b00000;
	localparam ALU_SUB = 5'b00001;
	localparam ALU_AND = 5'b00010;
	localparam ALU_OR  = 5'b00011;
	localparam ALU_XOR = 5'b00100;
	localparam ALU_SLL = 5'b00101;
	localparam ALU_SRL = 5'b00110;
	localparam ALU_SRA = 5'b00111;
	localparam ALU_SLT = 5'b01000;
	localparam ALU_SLTU= 5'b01001;
	localparam ALU_PASS= 5'b01010;
	localparam ALU_ADDPC=5'b01011;

	localparam ALU_MUL = 5'b01100;
	localparam ALU_MULH= 5'b01101;
	localparam ALU_MULHSU=5'b01110;
	localparam ALU_MULHU= 5'b01111;
	localparam ALU_DIV = 5'b10000;
	localparam ALU_DIVU= 5'b10001;
	localparam ALU_REM = 5'b10010;
	localparam ALU_REMU= 5'b10011;

	always @(*) begin
		reg_write = 0;
		mem_read = 0;
		mem_write = 0;
		alu_src = 0;
		alu_op = ALU_ADD;
		wb_sel = 2'b00;
		illegal = 1'b0;
		is_branch = 1'b0;
		is_jump = 1'b0;
		mem_size = 2'b00;
		mem_signed = 1'b0;
		imm = 32'b0;

		case (opcode)
			7'b0110011: begin
				// R-type (including M-extension when funct7 == 0000001)
				case (funct7)
					7'b0000000: begin
						case (funct3)
							3'b000: alu_op = ALU_ADD;
							3'b001: alu_op = ALU_SLL;
							3'b010: alu_op = ALU_SLT;
							3'b011: alu_op = ALU_SLTU;
							3'b100: alu_op = ALU_XOR;
							3'b101: alu_op = ALU_SRL;
							3'b110: alu_op = ALU_OR;
							3'b111: alu_op = ALU_AND;
						endcase
						reg_write = 1;
						wb_sel = 2'b00;
					end
					7'b0100000: begin
						case (funct3)
							3'b000: alu_op = ALU_SUB;
							3'b101: alu_op = ALU_SRA;
						endcase
						reg_write = 1;
						wb_sel = 2'b00;
					end
					7'b0000001: begin
						case (funct3)
							3'b000: alu_op = ALU_MUL;
							3'b001: alu_op = ALU_MULH;
							3'b010: alu_op = ALU_MULHSU;
							3'b011: alu_op = ALU_MULHU;
							3'b100: alu_op = ALU_DIV;
							3'b101: alu_op = ALU_DIVU;
							3'b110: alu_op = ALU_REM;
							3'b111: alu_op = ALU_REMU;
						endcase
						reg_write = 1;
						wb_sel = 2'b00;
					end
					default: begin
						illegal = 1'b1;
					end
				endcase
			end

			7'b0010011: begin
				// I-type ALU immediates
				alu_src = 1;
				reg_write = 1;
				wb_sel = 2'b00;
				imm = {{20{instr[31]}}, instr[31:20]};
				case (funct3)
					3'b000: alu_op = ALU_ADD;
					3'b001: alu_op = ALU_SLL;
					3'b010: alu_op = ALU_SLT;
					3'b011: alu_op = ALU_SLTU;
					3'b100: alu_op = ALU_XOR;
					3'b101: begin
						// distinguish SRLI / SRAI via instr[30] (funct7[5])
						if (funct7[5]) alu_op = ALU_SRA;
						else alu_op = ALU_SRL;
					end
					3'b110: alu_op = ALU_OR;
					3'b111: alu_op = ALU_AND;
				endcase
			end

			7'b0000011: begin
				// Loads (I-type)
				mem_read = 1;
				reg_write = 1;
				wb_sel = 2'b01;
				imm = {{20{instr[31]}}, instr[31:20]};
				case (funct3)
					3'b000: begin mem_size = 2'b00; mem_signed = 1'b1; end // lb
					3'b001: begin mem_size = 2'b01; mem_signed = 1'b1; end // lh
					3'b010: begin mem_size = 2'b10; mem_signed = 1'b1; end // lw
					3'b100: begin mem_size = 2'b00; mem_signed = 1'b0; end // lbu
					3'b101: begin mem_size = 2'b01; mem_signed = 1'b0; end // lhu
				endcase
				alu_op = ALU_ADD;
				alu_src = 1;
			end

			7'b0100011: begin
				// Stores (S-type)
				mem_write = 1;
				alu_src = 1;
				imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
				case (funct3)
					3'b000: mem_size = 2'b00; // sb
					3'b001: mem_size = 2'b01; // sh
					3'b010: mem_size = 2'b10; // sw
				endcase
				alu_op = ALU_ADD;
			end

			7'b1100011: begin
				// Branches (B-type)
				is_branch = 1;
				// imm[12]=instr[31], imm[11]=instr[7], imm[10:5]=instr[30:25], imm[4:1]=instr[11:8], imm[0]=0
				imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
				alu_src = 0;
				case (funct3)
					3'b000: alu_op = ALU_SUB;  // beq
					3'b001: alu_op = ALU_SUB;  // bne
					3'b100: alu_op = ALU_SLT;  // blt
					3'b101: alu_op = ALU_SLT;  // bge
					3'b110: alu_op = ALU_SLTU; // bltu
					3'b111: alu_op = ALU_SLTU; // bgeu
				endcase
			end

			7'b1101111: begin
				// JAL (J-type)
				is_jump = 1;
				reg_write = 1;
				wb_sel = 2'b10; // write PC+4
				// imm[20]=instr[31], imm[19:12]=instr[19:12], imm[11]=instr[20], imm[10:1]=instr[30:21], imm[0]=0
				imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
				alu_op = ALU_ADDPC;
			end

			7'b1100111: begin
				// JALR (I-type)
				is_jump = 1;
				reg_write = 1;
				wb_sel = 2'b10;
				alu_src = 1;
				imm = {{20{instr[31]}}, instr[31:20]};
				alu_op = ALU_ADDPC;
			end

			7'b0110111: begin
				// LUI
				reg_write = 1;
				wb_sel = 2'b11;
				alu_op = ALU_PASS;
				imm = {instr[31:12], 12'b0};
			end

			7'b0010111: begin
				// AUIPC
				reg_write = 1;
				wb_sel = 2'b11;
				alu_op = ALU_ADDPC;
				imm = {instr[31:12], 12'b0};
			end

			7'b0001111: begin
				// FENCE - no-op for simple core
			end

			default: begin
				illegal = 1'b1;
			end
		endcase
	end
endmodule
