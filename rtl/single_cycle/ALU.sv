import riscv_pkg::*;

module ALU(input [31:0]      a,
           input [31:0]      b,
           input [3:0]       alu_control,
           output reg [31:0] result,
           output            zero,
           output            negative,
           output reg        overflow,
           output            carry);

    wire [32:0] sub_ext; //33 bit temp subtraction for carry flag
    
    assign zero     = (result == 0);
    assign negative = result[31];
    assign overflow = (alu_control == ALU_SUB) ? ((a[31] != b[31]) && (a[31] != result[31])) : (a[31] == b[31]) && (a[31] != result[31]); //compute overflow based off subtraction or addition operation
    assign sub_ext  = {1'b0, a} - {1'b0, b};
    assign carry    = sub_ext[32];

    always_comb begin
        case (alu_control)
          ALU_AND  : result = a & b;
          ALU_OR   : result = a | b;
          ALU_ADD  : result = a + b;
          ALU_XOR  : result = a ^ b;
          ALU_SLL  : result = a << b;
          ALU_SRL  : result = a >> b;
          ALU_SUB  : result = a - b;
          ALU_SLT  : result = ($signed(a) < $signed(b)) ? 1 : 0;
          ALU_SLTU : result = (a < b) ? 1 : 0;
          ALU_SRA  : result = $signed(a) >>> b;
          ALU_LUI  : result = b; //LUI -- simply passes b through to the output
        endcase
    end
endmodule
           
