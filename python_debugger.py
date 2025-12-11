import re

def sign_extend(value, bits):
	if value & (1 << (bits - 1)):
		return value - (1 << bits)
	return value


assembly = []
def decode_instrs(instr_hex):
	instr = int(instr_hex, 16)
	opcode = instr & 0x7F
	rd     = (instr >> 7)  & 0x1F
	funct3 = (instr >> 12) & 0x7
	rs1    = (instr >> 15) & 0x1F
	rs2    = (instr >> 20) & 0x1F
	funct7 = (instr >> 25) & 0x7F

	if opcode == 0x33:
		if funct7 == 0x00 and funct3 == 0x0:
			out = f"add x{rd}, x{rs1}, x{rs2}"
			assembly.append(out)
			return out
		if funct7 == 0x20 and funct3 == 0x0:
			out = f"sub x{rd}, x{rs1}, x{rs2}"
			assembly.append(out)
			return out
		if funct7 == 0x00 and funct3 == 0x7:
			out = f"and x{rd}, x{rs1}, x{rs2}"
			assembly.append(out)
			return out
		if funct7 == 0x00 and funct3 == 0x6:
			out = f"or x{rd}, x{rs1}, x{rs2}"
			assembly.append(out)
			return out
		if funct7 == 0x00 and funct3 == 0x4:
			out = f"xor x{rd}, x{rs1}, x{rs2}"
			assembly.append(out)
			return out
		return f"R-type opcode33 (funct3={funct3}, funct7={funct7})"
	

	if opcode == 0x13:  # ADDI etc.
		imm = sign_extend(instr >> 20, 12)
		if funct3 == 0x0:
			out = f"addi x{rd}, x{rs1}, {imm:#x}"
			assembly.append(out)
			return out
		return f"I-type opcode13 (funct3={funct3})"

	if opcode == 0x03:  # LOAD
		imm = sign_extend(instr >> 20, 12)
		if funct3 == 0x2:
			out = f"lw x{rd}, {imm}(x{rs1})"
			assembly.append(out)
			return out
		return f"LOAD opcode03 (funct3={funct3})"
	

	if opcode == 0x23:
		imm = (((instr >> 25) & 0x7F) << 5) | ((instr >> 7) & 0x1F)
		imm = sign_extend(imm, 12)
		if funct3 == 0x2:
			out = f"sw x{rs2}, {imm}(x{rs1})"
			assembly.append(out)
			return out
		return f"STORE opcode23"
	

	if opcode == 0x63:
		# B-type immediate decoding:
		# imm[12] = bit31
		# imm[10:5] = bits30:25
		# imm[4:1] = bits11:8
		# imm[11] = bit7
		# imm[0] = 0
		imm = 0
		imm |= ((instr >> 7)  & 0x1) << 11
		imm |= ((instr >> 8)  & 0xF) << 1
		imm |= ((instr >> 25) & 0x3F) << 5
		imm |= ((instr >> 31) & 0x1) << 12
		imm = sign_extend(imm, 13)

		if funct3 == 0x0:
			out = f"beq x{rs1}, x{rs2}, {imm:#x}"
			assembly.append(out)
			return out
		if funct3 == 0x1:
			out = f"bne x{rs1}, x{rs2}, {imm:#x}"
			assembly.append(out)
			return out
		if funct3 == 0x4:
			out = f"blt x{rs1}, x{rs2}, {imm:#x}"
			assembly.append(out)
			return out
		if funct3 == 0x5:
			out = f"bge x{rs1}, x{rs2}, {imm:#x}"
			assembly.append(out)
			return out
		if funct3 == 0x6:
			out = f"bltu x{rs1}, x{rs2}, {imm:#x}"
			assembly.append(out)
			return out
		if funct3 == 0x7:
			out = f"bgeu x{rs1}, x{rs2}, {imm:#x}"
			assembly.append(out)
			return out

		return f"branch opcode63 funct3={funct3}"
	

	if opcode == 0x6F:
		imm = ((instr >> 21) & 0x3FF) << 1
		imm |= ((instr >> 20) & 0x1) << 11
		imm |= ((instr >> 12) & 0xFF) << 12
		imm |= (instr >> 31) << 20
		imm = sign_extend(imm, 21)
		out = f"jal x{rd}, {imm:#x}"
		assembly.append(out)
		return out

	if instr_hex == "0000006f":
		return "halt"

	return f"Unknown opcode {opcode:#x}"


def parse_debug_output(file_path):
	debug_data = {}
	with open(file_path, 'r') as f:
		lines = f.readlines()

	collect = False
	for line in lines:
		line = line.strip()

		# Detect key fields
		if line.startswith("PC"):
			debug_data["pc"] = line.split("=")[1].strip()
		elif line.startswith("Instr"):
			debug_data["instr"] = line.split("=")[1].strip()
		elif line.startswith("rs1_data"):
			debug_data["rs1_val"] = line.split("=")[1].strip()
		elif line.startswith("rs2_data"):
			debug_data["rs2_val"] = line.split("=")[1].strip()
		elif line.startswith("wb_data"):
			debug_data["wb"] = line.split("=")[1].strip()
		elif line.startswith("reg_write"):
			debug_data["write"] = line.split("=")[1].strip()

		# Block end (separator line)
		elif line.startswith("---------------------------------------------------"):
			if "pc" in debug_data and "instr" in debug_data:
				asm = decode_instrs(debug_data["instr"])
				print(f"{debug_data['pc']}: {debug_data['instr']}   {asm}")
				if debug_data.get("write") == "1":
					print(f"    → writeback: {debug_data.get('wb')}")
				print()
			debug_data = {}
		

def print_assembly():
	for instr in assembly:
		print(instr)


if __name__ == "__main__":
	logfile = "RISCV.sim/sim_1/behav/xsim/simulate.log"
	parse_debug_output(logfile)
	print_assembly()