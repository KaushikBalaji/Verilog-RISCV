# lb_lbu.s
addi x1, x0, 0
addi x2, x0, -1      # 0xFF
sb   x2, 0(x1)

lb   x3, 0(x1)       # signed → -1
lbu  x4, 0(x1)       # unsigned → 255
ebreak
