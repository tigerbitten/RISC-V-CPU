import riscv_pkg::*;

module ALU(input [31:0]      a,
           input [31:0]      b,
           input [3:0]       alu_control,
           output reg [31:0] result,
           output            zero,
           output            negative,
           output reg        overflow,
           output            carry);

    wire [32:0] adder_out;
    
    assign zero      = (result == 0);
    assign negative  = adder_out[31];
    assign carry     = !adder_out[32];
    
    assign overflow  = (alu_control == ALU_SUB) ? ((a[31] != b[31]) && (a[31] != adder_out[31])) : (a[31] == b[31]) && (a[31] != adder_out[31]); //compute overflow based off subtraction or addition operation
    assign adder_out = (alu_control == ALU_SUB || alu_control == ALU_SLT || alu_control == ALU_SLTU) ? {1'b0, a} + {1'b0, (~b)} + 1 : {1'b0, a} + {1'b0, b}; //2's complement addition for signals that need subtraction

    always_comb begin
        case (alu_control)
          ALU_AND           : result = a & b;
          ALU_OR            : result = a | b;
          ALU_ADD, ALU_SUB  : result = adder_out[31:0];
          ALU_XOR           : result = a ^ b;
          ALU_SLL           : result = a << b[4:0];
          ALU_SRL           : result = a >> b[4:0];
          ALU_SLT           : result = negative ^ overflow;
          ALU_SLTU          : result = carry;
          ALU_SRA           : result = $signed(a) >>> b[4:0];
          ALU_LUI           : result = b; //LUI -- simply passes b through to the output
        endcase
    end
endmodule
