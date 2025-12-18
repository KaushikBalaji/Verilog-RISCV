addi x1, x0, 0
li   x2, 0x8001
sh   x2, 0(x1)

lh   x3, 0(x1)
lhu  x4, 0(x1)
ebreak
