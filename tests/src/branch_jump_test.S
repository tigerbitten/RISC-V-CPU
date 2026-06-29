# branch_jump_test.S
# Tests branch and jump flushing.
# Verifies that taken branches and jumps correctly flush the pipeline
# and redirect the PC without executing wrong instructions.
# Pass: x3 = 1

.global _start
_start:
    # test JAL
    jal  x0, target1        # jump forward, x0 discards return address
    addi x3, x0, 99        # should be flushed, never execute
target1:

    # test BEQ taken
    addi x1, x0, 5
    addi x2, x0, 5
    beq  x1, x2, target2   # should be taken
    addi x3, x0, 99        # should be flushed, never execute
target2:

    # test BNE not taken (falls through)
    addi x1, x0, 5
    addi x2, x0, 5
    bne  x1, x2, target3   # should NOT be taken
    addi x3, x0, 1         # should execute — x3 = 1 (pass)
    j done
target3:
    addi x3, x0, 99        # should never reach here

done: j done
