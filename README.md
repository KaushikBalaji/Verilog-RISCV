**To load an assembly to the processor, make it to .hex**

```bash
riscv-none-elf-objcopy -O binary 1-even.elf 1-even.bin
hexdump -ve '1/4 "%08x\n"' 1-even.bin > prog.hex
```
