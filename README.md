### To load an assembly to the processor, make it to .hex

```bash
riscv-none-elf-objcopy -O binary 1-even.elf 1-even.bin
hexdump -ve '1/4 "%08x\n"' 1-even.bin > prog.hex
```

### What's being done

 - This project began with a simple "childish" intention: to run my simple assembly level game on my own made RISCV processor. 
 - Feel free to modify anything, as you see fit for your needs.
 - bash script file added to convert assembly level code to .hex files into separate folder.
 - Added a python program to get back the assembly program from the generated outputs from this processor, so its easy to debug.
 - Added few more testcases to check.
 - The bash script now creates separate hex files for data and instruction counts header files, so these can be imported dynamically when adding these to memory.

##### _PS._
To use this project, just download this and choose open project in Vivado.
If issue arises, modify the file paths, in the .xpr file.


