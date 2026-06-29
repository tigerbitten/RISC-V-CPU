# hazard_test.S
# Tests data hazards caused by back-to-back dependent instructions.
# Without forwarding, add x3,x1,x2 reads stale x1/x2 values (0) from the
# register file and produces the wrong result.
# With forwarding, x3 = 8, then x3 = 8 - 7 = 1 (pass).
#
# Note: j done (infinite loop) requires jump logic to be working in the
# pipeline. Until then, simulate for exactly 14 cycles after reset to
# avoid garbage instructions corrupting x3.

.global _start
_start:
    addi x1, x0, 5         # x1 = 5
    addi x2, x0, 3         # x2 = 3 (hazard: back-to-back)
    add  x3, x1, x2        # x3 should be 8, but will be wrong without forwarding
    addi x3, x3, -7        # x3 = 8 - 7 = 1 (pass) if forwarding works
done: j done
