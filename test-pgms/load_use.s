addi x1, x0, 0
addi x2, x0, 99
sw   x2, 0(x1)
lw   x3, 0(x1)
add  x4, x3, x3
ebreak
