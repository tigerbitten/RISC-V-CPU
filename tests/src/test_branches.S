# test_branches.S — Branch instruction tests
# Pass: x3 = 1
# Fail: x3 = failing test case number

.global _start
_start:
    li x3, 0        # test counter

    # --- BEQ ---

    # test 1: BEQ taken
    li x1, 5
    li x2, 5
    beq x1, x2, t1_pass
    jal x0, fail
t1_pass:
    addi x3, x3, 1  # x3 = 1

    # test 2: BEQ not taken
    li x1, 5
    li x2, 3
    beq x1, x2, fail
    addi x3, x3, 1  # x3 = 2

    # --- BNE ---

    # test 3: BNE taken
    li x1, 5
    li x2, 3
    bne x1, x2, t3_pass
    jal x0, fail
t3_pass:
    addi x3, x3, 1  # x3 = 3

    # test 4: BNE not taken
    li x1, 5
    li x2, 5
    bne x1, x2, fail
    addi x3, x3, 1  # x3 = 4

    # --- BLT signed ---

    # test 5: BLT taken
    li x1, -1
    li x2, 1
    blt x1, x2, t5_pass
    jal x0, fail
t5_pass:
    addi x3, x3, 1  # x3 = 5

    # test 6: BLT not taken (equal)
    li x1, 5
    li x2, 5
    blt x1, x2, fail
    addi x3, x3, 1  # x3 = 6

    # test 7: BLT not taken (greater)
    li x1, 5
    li x2, 3
    blt x1, x2, fail
    addi x3, x3, 1  # x3 = 7

    # --- BGE signed ---

    # test 8: BGE taken (greater)
    li x1, 5
    li x2, 3
    bge x1, x2, t8_pass
    jal x0, fail
t8_pass:
    addi x3, x3, 1  # x3 = 8

    # test 9: BGE taken (equal)
    li x1, 5
    li x2, 5
    bge x1, x2, t9_pass
    jal x0, fail
t9_pass:
    addi x3, x3, 1  # x3 = 9

    # test 10: BGE not taken
    li x1, -1
    li x2, 1
    bge x1, x2, fail
    addi x3, x3, 1  # x3 = 10

    # --- BLTU unsigned ---

    # test 11: BLTU taken
    li x1, 1
    li x2, -1       # -1 unsigned is 0xFFFFFFFF, large
    bltu x1, x2, t11_pass
    jal x0, fail
t11_pass:
    addi x3, x3, 1  # x3 = 11

    # test 12: BLTU not taken (equal)
    li x1, 5
    li x2, 5
    bltu x1, x2, fail
    addi x3, x3, 1  # x3 = 12

    # test 13: BLTU not taken (greater unsigned)
    li x1, -1       # 0xFFFFFFFF
    li x2, 1
    bltu x1, x2, fail
    addi x3, x3, 1  # x3 = 13

    # --- BGEU unsigned ---

    # test 14: BGEU taken (greater unsigned)
    li x1, -1       # 0xFFFFFFFF
    li x2, 1
    bgeu x1, x2, t14_pass
    jal x0, fail
t14_pass:
    addi x3, x3, 1  # x3 = 14

    # test 15: BGEU taken (equal)
    li x1, 5
    li x2, 5
    bgeu x1, x2, t15_pass
    jal x0, fail
t15_pass:
    addi x3, x3, 1  # x3 = 15

    # test 16: BGEU not taken
    li x1, 1
    li x2, -1       # 0xFFFFFFFF
    bgeu x1, x2, fail
    addi x3, x3, 1  # x3 = 16

pass:
    li x3, 1
    jal x0, done

fail:
    jal x0, done

done:
    jal x0, done
