# test_jalr.S — JALR instruction tests (corrected)
# Pass: x3 = 1
# Fail: x3 = 0xDEAD (jumped to fail handler)

.global _start
_start:
    li x3, 0

    # test 1: basic JAL then JALR return
    jal x1, func1       # x1 = return address, jump to func1
    addi x3, x3, 1      # x3 = 1 — reached only if JALR returns here
    jal x0, test2
func1:
    jalr x0, x1, 0      # return to caller
    jal x0, fail        # should never reach here

    # test 2: JALR with nonzero immediate
test2:
    auipc x1, 0         # x1 = current PC
    addi x1, x1, 24     # x1 = PC + 24 (address of t2_land, skips 3 fail jumps)
    jalr x0, x1, 0      # jump to x1 + 0
    jal x0, fail
    jal x0, fail
    jal x0, fail
t2_land:
    addi x3, x3, 1      # x3 = 2

    # test 3: JALR with negative immediate
    auipc x1, 0         # x1 = current PC
    addi x1, x1, 20     # x1 = PC + 20 (so x1 - 4 lands on t3_land)
    jalr x0, x1, -4     # x1 - 4 should land at t3_land
    jal x0, fail
t3_land:
    addi x3, x3, 1      # x3 = 3

    # test 4: JALR LSB clearing
    auipc x1, 0         # x1 = current PC
    addi x1, x1, 17     # x1 = PC + 17 (odd) — clears to PC+16
    jalr x0, x1, 0      # LSB should be cleared, lands on addi below
    jal x0, fail
    addi x3, x3, 1      # x3 = 4

    # test 5: JALR writes correct return address
    auipc x5, 0         # capture PC
    addi x5, x5, 12     # expected return address (PC of jal + 4)
    jal x1, func2
    jal x0, t5_check
func2:
    jalr x0, x1, 0
t5_check:
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 5

    # test 6: JALR rd and rs1 same register
    auipc x1, 0         # x1 = current PC
    addi x1, x1, 24     # x1 = address of t6_land (skips 3 fail jumps)
    jalr x1, x1, 0      # x1 used as both base and destination
    jal x0, fail
    jal x0, fail
    jal x0, fail
t6_land:
    addi x3, x3, 1      # x3 = 6

pass:
    li x3, 1
    jal x0, done

fail:
    li x3, 0xDEAD       # unambiguous failure marker
    jal x0, done

done:
    jal x0, done
