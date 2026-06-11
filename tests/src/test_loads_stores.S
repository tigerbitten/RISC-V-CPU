# test_loads_stores.S — Load and store instruction tests
# Pass: x3 = 1
# Fail: x3 = failing test case number

.global _start
_start:
    li x3, 0        # test counter
    li x6, 0        # base address for all memory accesses

    # --- SW / LW ---

    # test 1: store and load word
    li x1, 0x12345678
    sw x1, 0(x6)
    lw x2, 0(x6)
    bne x1, x2, fail
    addi x3, x3, 1  # x3 = 1

    # test 2: store and load negative word
    li x1, -1
    sw x1, 0(x6)
    lw x2, 0(x6)
    bne x1, x2, fail
    addi x3, x3, 1  # x3 = 2

    # --- SH / LH ---

    # test 3: store and load halfword positive
    li x1, 0x1234
    sh x1, 4(x6)
    lh x2, 4(x6)
    bne x1, x2, fail
    addi x3, x3, 1  # x3 = 3

    # test 4: store and load halfword negative (sign extension)
    li x1, 0xFFFF8000  # negative halfword
    sh x1, 4(x6)
    lh x2, 4(x6)
    li x5, 0xFFFF8000
    bne x2, x5, fail
    addi x3, x3, 1  # x3 = 4

    # --- SH / LHU ---

    # test 5: load halfword unsigned (zero extension)
    li x1, 0x8000
    sh x1, 4(x6)
    lhu x2, 4(x6)
    li x5, 0x8000
    bne x2, x5, fail
    addi x3, x3, 1  # x3 = 5

    # --- SB / LB ---

    # test 6: store and load byte positive
    li x1, 0x42
    sb x1, 8(x6)
    lb x2, 8(x6)
    bne x1, x2, fail
    addi x3, x3, 1  # x3 = 6

    # test 7: store and load byte negative (sign extension)
    li x1, 0xFFFFFF80  # negative byte
    sb x1, 8(x6)
    lb x2, 8(x6)
    li x5, 0xFFFFFF80
    bne x2, x5, fail
    addi x3, x3, 1  # x3 = 7

    # --- SB / LBU ---

    # test 8: load byte unsigned (zero extension)
    li x1, 0x80
    sb x1, 8(x6)
    lbu x2, 8(x6)
    li x5, 0x80
    bne x2, x5, fail
    addi x3, x3, 1  # x3 = 8

    # --- adjacent address corruption check ---

    # test 9: write two adjacent words, verify no overlap
    li x1, 0xAAAAAAAA
    li x2, 0x55555555
    sw x1, 0(x6)
    sw x2, 4(x6)
    lw x4, 0(x6)
    bne x4, x1, fail
    addi x3, x3, 1  # x3 = 9

    # test 10: verify second word unchanged
    lw x4, 4(x6)
    bne x4, x2, fail
    addi x3, x3, 1  # x3 = 10

    # test 11: byte store does not corrupt adjacent bytes
    li x1, 0x12345678
    sw x1, 12(x6)
    li x2, 0xAB
    sb x2, 12(x6)      # overwrite only lowest byte
    lw x4, 12(x6)
    li x5, 0x123456AB  # only low byte should change
    bne x4, x5, fail
    addi x3, x3, 1  # x3 = 11

pass:
    li x3, 1
    jal x0, done

fail:
    jal x0, done

done:
    jal x0, done
