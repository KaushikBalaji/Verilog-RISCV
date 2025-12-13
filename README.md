# To load an assembly to the processor, make it to .hex

```bash
riscv-none-elf-objcopy -O binary 1-even.elf 1-even.bin
hexdump -ve '1/4 "%08x\n"' 1-even.bin > prog.hex
```

### Note

 - This project began with a simple "childish" intention: to run my simple assembly level game on my own made RISCV processor. 
 - Feel free to modify anything, as you see fit for your needs.
 - bash script file added to convert assembly level code to .hex files (instruction and data parts separately)
 - Added a python program to get back the assembly program from the generated outputs from this processor, so its easy to debug 

##### _PS._
To use this project, just download this and choose open project in Vivado.
If issue arises, modify the file paths, in the .xpr file.


