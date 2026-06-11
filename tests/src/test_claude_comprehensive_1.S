# test_comprehensive.S — Comprehensive RV32I test
# Tests edge cases, instruction interactions, and corner cases
# Pass: x3 = 1
# Fail: x3 = failing test case number

.global _start
_start:
    li x3, 0

    # --- x0 write immunity ---

    # test 1: x0 cannot be written
    li x0, 0xDEADBEEF
    bne x0, x0, fail    # x0 should still be 0, this branch never taken
    addi x3, x3, 1      # x3 = 1

    # test 2: x0 as source is always 0
    add x1, x0, x0
    bne x1, x0, fail
    addi x3, x3, 1      # x3 = 2

    # --- ALU boundary values ---

    # test 3: ADD overflow wraps around
    li x1, 0x7FFFFFFF   # max positive signed
    li x2, 1
    add x1, x1, x2      # should wrap to 0x80000000
    li x5, 0x80000000
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 3

    # test 4: SUB underflow wraps around
    li x1, 0x80000000   # min negative signed
    li x2, 1
    sub x1, x1, x2      # should wrap to 0x7FFFFFFF
    li x5, 0x7FFFFFFF
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 4

    # test 5: AND with 0 gives 0
    li x1, 0xFFFFFFFF
    and x1, x1, x0
    bne x1, x0, fail
    addi x3, x3, 1      # x3 = 5

    # test 6: OR with all ones gives all ones
    li x1, 0x00000000
    li x2, 0xFFFFFFFF
    or x1, x1, x2
    bne x1, x2, fail
    addi x3, x3, 1      # x3 = 6

    # test 7: XOR with self gives 0
    li x1, 0xDEADBEEF
    xor x1, x1, x1
    bne x1, x0, fail
    addi x3, x3, 1      # x3 = 7

    # test 8: XOR with all ones flips all bits
    li x1, 0xAAAAAAAA
    li x2, 0xFFFFFFFF
    xor x1, x1, x2
    li x5, 0x55555555
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 8

    # --- Shift edge cases ---

    # test 9: SLL by 0 is identity
    li x1, 0x12345678
    slli x2, x1, 0
    bne x2, x1, fail
    addi x3, x3, 1      # x3 = 9

    # test 10: SLL by 31
    li x1, 1
    slli x1, x1, 31     # should give 0x80000000
    li x5, 0x80000000
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 10

    # test 11: SRL by 31
    li x1, 0x80000000
    srli x1, x1, 31     # should give 1
    li x5, 1
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 11

    # test 12: SRA preserves sign bit
    li x1, 0x80000000   # most negative
    srai x1, x1, 1      # arithmetic right shift, should give 0xC0000000
    li x5, 0xC0000000
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 12

    # test 13: SRA by 31 fills with sign bit
    li x1, 0x80000000
    srai x1, x1, 31     # should give 0xFFFFFFFF
    li x5, 0xFFFFFFFF
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 13

    # test 14: SRL does not sign extend
    li x1, 0x80000000
    srli x1, x1, 1      # should give 0x40000000 not 0xC0000000
    li x5, 0x40000000
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 14

    # --- SLT edge cases ---

    # test 15: SLT with equal values
    li x1, 5
    slt x2, x1, x1
    bne x2, x0, fail    # should be 0
    addi x3, x3, 1      # x3 = 15

    # test 16: SLT most negative < most positive
    li x1, 0x80000000   # most negative signed
    li x2, 0x7FFFFFFF   # most positive signed
    slt x4, x1, x2
    li x5, 1
    bne x4, x5, fail
    addi x3, x3, 1      # x3 = 16

    # test 17: SLTU treats 0xFFFFFFFF as largest
    li x1, 0xFFFFFFFF
    li x2, 0
    sltu x4, x2, x1     # 0 < 0xFFFFFFFF unsigned
    li x5, 1
    bne x4, x5, fail
    addi x3, x3, 1      # x3 = 17

    # --- ADDI immediate edge cases ---

    # test 18: ADDI max positive immediate
    li x1, 0
    addi x1, x1, 2047   # max 12-bit signed immediate
    li x5, 2047
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 18

    # test 19: ADDI max negative immediate
    li x1, 0
    addi x1, x1, -2048  # min 12-bit signed immediate
    li x5, -2048
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 19

    # --- LUI ---

    # test 20: LUI loads upper 20 bits
    lui x1, 1           # should give 0x00001000
    li x5, 0x00001000
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 20

    # test 21: LUI + ADDI builds full 32-bit value
    lui x1, 0xDEADB     # upper 20 bits
    addi x1, x1, 0x7EF  # lower 12 bits — note: 0xEEF would sign extend negatively
    li x5, 0xDEADB7EF
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 21

    # --- AUIPC ---

    # test 22: AUIPC result is nonzero (PC dependent)
    auipc x1, 1         # PC + 0x1000, result depends on PC
    beq x1, x0, fail    # result should never be 0
    addi x3, x3, 1      # x3 = 22

    # --- JAL return address ---

    # test 23: JAL writes correct return address
    auipc x5, 0         # capture current PC into x5
    addi x5, x5, 12     # expected return address is current PC + 12 (this instr + jal + landing)
    jal x1, t23_land
    jal x0, fail
t23_land:
    bne x1, x5, fail
    addi x3, x3, 1      # x3 = 23

    # --- Memory interaction with ALU ---

    # test 24: store ALU result, load and verify
    li x1, 0x12345678
    li x2, 0x0000000F
    and x4, x1, x2      # x4 = 0x00000008
    sw x4, 0(x0)
    lw x5, 0(x0)
    bne x4, x5, fail
    addi x3, x3, 1      # x3 = 24

    # test 25: byte load sign extension from MSB set
    li x1, 0xFF
    sb x1, 20(x0)
    lb x2, 20(x0)
    li x5, 0xFFFFFFFF
    bne x2, x5, fail
    addi x3, x3, 1      # x3 = 25

    # test 26: byte load unsigned no sign extension
    lbu x2, 20(x0)
    li x5, 0xFF
    bne x2, x5, fail
    addi x3, x3, 1      # x3 = 26

pass:
    li x3, 1
    jal x0, done

fail:
    jal x0, done

done:
    jal x0, done
