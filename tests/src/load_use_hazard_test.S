# load_use_hazard_test.S
# Tests load-use hazard detection and stalling.
# A load immediately followed by an instruction that uses the loaded value
# requires a one-cycle stall — the hazard detection unit must insert a bubble.
# Pass: x3 = 1

.global _start
_start:
    addi x1, x0, 42        # x1 = 42
    sw   x1, 0(x0)         # store 42 to address 0
    nop
    nop
    nop
    nop
    lw   x2, 0(x0)         # load 42 into x2
    addi x3, x2, -41       # x3 = 42 - 41 = 1 (load-use hazard: x2 used immediately after lw)
done: j done
