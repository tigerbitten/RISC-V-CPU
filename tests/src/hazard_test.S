.global _start
_start:
    addi x1, x0, 5         # x1 = 5
    addi x2, x0, 3         # x2 = 3 (hazard: back-to-back)
    add  x3, x1, x2        # x3 should be 8, but will be wrong without forwarding
