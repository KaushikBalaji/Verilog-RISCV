#!/bin/bash


#   RISC-V HEX GENERATION SCRIPT (Verilog + Raw Hex formats)


if [ $# -ne 1 ]; then
    echo "Usage: $0 <path/to/file.s>"
    exit 1
fi

SRC_PATH="$1"
SRC_NAME="$(basename "$SRC_PATH")"
BASE_NAME="${SRC_NAME%.*}"        
SCRIPT_DIR="$(dirname "$0")"

LINKER_SCRIPT="${SCRIPT_DIR}/link.ld"

OUT_DIR="${BASE_NAME}"
mkdir -p "$OUT_DIR"

echo "==> Output directory: $OUT_DIR"

cp "$SRC_PATH" "$OUT_DIR/${BASE_NAME}.s"
cp "$LINKER_SCRIPT" "$OUT_DIR/link.ld"

cd "$OUT_DIR" || exit 1


# Assembler + Linker


echo "==> Assembling..."
riscv-none-elf-as "${BASE_NAME}.s" -o "${BASE_NAME}.o"

echo "==> Linking..."
riscv-none-elf-ld -T link.ld "${BASE_NAME}.o" -o "${BASE_NAME}.elf"


# Add section sizes (for memory allocation in Verilog)

echo "==> Section sizes:"
riscv-none-elf-size -A "${BASE_NAME}.elf"

INSTR_BYTES=$(riscv-none-elf-size -A "${BASE_NAME}.elf" | awk '$1==".text"{print $2}')
DATA_BYTES=$(riscv-none-elf-size -A "${BASE_NAME}.elf" | awk '$1==".data"{print $2}')

INSTR_WORDS=$((INSTR_BYTES / 4))
DATA_WORDS=$((DATA_BYTES / 4))

echo "INSTR_WORDS = ${INSTR_WORDS}"
echo "DATA_WORDS = ${DATA_WORDS}"

cat > instr_size.vh <<EOF
\`ifndef INSTR_SIZE_VH
\`define INSTR_SIZE_VH

\`define INSTR_WORDS ${INSTR_WORDS}

\`endif
EOF

cat > data_size.vh <<EOF
\`ifndef DATA_SIZE_VH
\`define DATA_SIZE_VH

\`define DATA_WORDS ${DATA_WORDS}

\`endif
EOF




# METHOD A — Verilog-format hex using objcopy


echo "==> Generating instr.hex (Verilog)..."
riscv-none-elf-objcopy -O verilog \
    --verilog-data-width=4 \
    --only-section=.text \
    "${BASE_NAME}.elf" ${BASE_NAME}_instr.hex

echo "==> Generating data.hex (Verilog)..."
riscv-none-elf-objcopy -O verilog \
    --verilog-data-width=4 \
    --only-section=.data \
    "${BASE_NAME}.elf" ${BASE_NAME}_data.hex


# METHOD B — Raw Hex (simple 32-bit words, simulator-safe)


echo "==> Creating RAW hex from full binary..."

riscv-none-elf-objcopy -O binary "${BASE_NAME}.elf" "${BASE_NAME}.bin"

echo "==> Full raw dump: full_raw.hex"
hexdump -ve '1/4 "%08x\n"' "${BASE_NAME}.bin" > ${BASE_NAME}_full_raw.hex

# Extract TEXT region only (0x0000–0x0FFF)
echo "==> instr_raw.hex (raw binary ONLY .text)..."
dd if="${BASE_NAME}.bin" bs=1 count=$((0x1000)) status=none \
| hexdump -ve '1/4 "%08x\n"' > ${BASE_NAME}_instr_raw.hex

# Extract DATA region (starting at 0x1000)
echo "==> data_raw.hex (raw binary ONLY .data)..."
dd if="${BASE_NAME}.bin" bs=1 skip=$((0x1000)) status=none \
| hexdump -ve '1/4 "%08x\n"' > ${BASE_NAME}_data_raw.hex



echo "==> Completed!"
echo "Generated files:"
ls -l
