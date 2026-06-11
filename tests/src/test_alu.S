# test_alu.S — ALU R-type instruction tests
# Pass: x3 = 1
# Fail: x3 = failing test case number

.global _start
_start:

    # test 1: ADD
    li x1, 5            # load 5 into x1
    li x2, 3            # load 3 into x2
    add x4, x1, x2      # x4 = x1 + x2 = 8
    li x5, 8            # load expected value 8
    bne x4, x5, fail    # if x4 != 8 jump to fail
    addi x3, x3, 1      # increment test counter, x3 = 1

    # test 2: SUB
    sub x4, x1, x2      # x4 = x1 - x2 = 2
    li x5, 2            # expected value
    bne x4, x5, fail    # fail if wrong
    addi x3, x3, 1      # x3 = 2

pass:
    li x3, 1            # overwrite counter with 1 to signal pass
    jal x0, done        # jump to done

fail:
    # x3 already holds the last passing test number + 1
    # which identifies the failing test
    jal x0, done

done:
    jal x0, done        # infinite loop
