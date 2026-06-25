# test_rgb.S — cycles register x7 through RGB colors
# x7 holds a 24-bit RGB value: bits [23:16] = R, [15:8] = G, [7:0] = B
# takes 2 cycles to change color in the single cycle implementation
# because LI gets expanded to 2 instructions.
        
.global _start
_start:

    # red
    li x7, 0xFF0000

    # green
    li x7, 0x00FF00

    # blue
    li x7, 0x0000FF

    # yellow
    li x7, 0xFFFF00

    # cyan
    li x7, 0x00FFFF

    # magenta
    li x7, 0xFF00FF

    # white
    li x7, 0xFFFFFF

    # off
    li x7, 0x000000

loop:
    jal x0, loop
