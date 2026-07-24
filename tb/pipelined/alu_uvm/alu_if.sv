import riscv_pkg::*;

interface alu_if;
    logic [31:0] a;
    logic [31:0] b;
    alu_control_t alu_control;

    logic [31:0]  result;
    logic         zero;
    logic         negative;
    logic         overflow;
    logic         carry;
endinterface
