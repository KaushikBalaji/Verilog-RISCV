addi x1, x0, -1
addi x2, x0, 1

blt x1, x2, less
addi x3, x0, 0
less:
addi x3, x0, 9

bge x2, x1, ge
addi x4, x0, 0
ge:
addi x4, x0, 8
ebreak
