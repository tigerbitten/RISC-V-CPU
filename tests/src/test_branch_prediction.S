# test_branch_prediction.S
# Showcases gshare dynamic branch prediction on highly predictable loops.
# Each loop has a branch taken the vast majority of iterations — the PHT
# trains to strongly-taken after a few cycles, reducing subsequent taken-branch
# penalties from 2 cycles to 0. Without prediction every taken branch pays 2.
# Pass: x3 = 1

.global _start
_start:
    li x3, 0

    # test 1: sum 1..100 = 5050
    # branch taken 99 consecutive times, not-taken once on exit
    li x1, 0
    li x2, 1
    li x4, 100
sum_loop:
    add  x1, x1, x2
    addi x2, x2, 1
    bge  x4, x2, sum_loop
    li   x5, 5050
    bne  x1, x5, fail
    addi x3, x3, 1          # x3 = 1

    # test 2: nested loop — 10 outer x 20 inner = 200 total iterations
    # inner branch taken 19/20 times per outer, outer branch taken 9/10 times
    # two independent PHT entries both train quickly to strongly-taken
    li x1, 0
    li x6, 10
outer_loop:
    li x2, 20
inner_loop:
    addi x1, x1, 1
    addi x2, x2, -1
    bne  x2, x0, inner_loop
    addi x6, x6, -1
    bne  x6, x0, outer_loop
    li   x5, 200
    bne  x1, x5, fail
    addi x3, x3, 1          # x3 = 2

    # test 3: fibonacci — compute F(20) = 6765
    # branch taken 18 consecutive times, not-taken once on exit
    li x1, 0                # F(0)
    li x2, 1                # F(1)
    li x4, 19               # iterate 19 times to reach F(20)
fib_loop:
    add  x5, x1, x2
    mv   x1, x2
    mv   x2, x5
    addi x4, x4, -1
    bne  x4, x0, fib_loop
    li   x5, 6765
    bne  x2, x5, fail
    addi x3, x3, 1          # x3 = 3

pass:
    li   x3, 1
    j    done

fail:
    li   x3, 0xDEAD
    j    done

done:
    j done
