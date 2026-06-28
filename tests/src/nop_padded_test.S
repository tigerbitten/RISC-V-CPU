.global _start
_start:
    addi x1, x0, 5         # x1 = 5
    nop
    nop
    nop
    nop
    addi x2, x0, 3         # x2 = 3
    nop
    nop
    nop
    nop
    add  x4, x1, x2        # x4 = 8
    nop
    nop
    nop
    nop
    sub  x5, x1, x2        # x5 = 2
    nop
    nop
    nop
    nop
    addi x3, x0, 1         # x3 = 1 (pass)
